macro EventNames lbl, [name] {
common
local ..cnt
..cnt = 0

label lbl dword

forward
local ..name
     dd ..name
     ..cnt = ..cnt + 1

common
     rd 64 - ..cnt

forward
  ..name db name
         db 0

common
  repeat 64-..cnt
    store dword $ at lbl + 4*..cnt
    db 'event', '0'+..cnt/10, '0'+..cnt mod 10
    db 0
    ..cnt = ..cnt + 1
  end repeat
}



struct TEventsListener
  .pPrev     dd ?
  .pNext     dd ?

  .hSocket   dd ?       ; the socket events to be sent.
  .requestID dd ?       ; the requestID of the events request.
  .typesLo   dd ?       ; what type of events to be sent.
  .typesHi   dd ?
ends


uglobal
  mxListeners    TMutex
  pFirstListener dd ?
endg


iglobal

; definition of the used event masks and names.

  evmMessage = 1
  evmUser    = 2

  EventNames tblEventNames,                     \
    'message',                                  \
    'user'
endg


sqlGetInitialId text "select rowid from EventQueue order by rowid desc limit 1;"
sqlGetEvents    text "select id, type, event from EventQueue where id > ?1;"


proc sseServiceThread, .lparam
.stmt  dd ?
.futex dd ?
.minid dd ?
.type  rd 2
begin
        stdcall MutexCreate, 0, mxListeners
        stdcall MutexRelease, mxListeners

        xor     ebx, ebx

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetInitialId, sqlGetInitialId.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     @f
        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax
@@:
        cinvoke sqliteFinalize, [.stmt]
        mov     [.minid], ebx

.main_loop:
        cmp     [fEventsTerminate], 0
        jne     .finish_thread

        mov     eax, [pEventsFutex]
        mov     eax, [eax]
        mov     [.futex], eax                ; the value of the futex in the beginning of the cycle.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetEvents, sqlGetEvents.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.minid]

.fetch_loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finalize

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.minid], eax

        cinvoke sqliteColumnInt64, [.stmt], 1
        mov     dword [.type], eax
        mov     dword [.type+4], edx

        cinvoke sqliteColumnText, [.stmt], 2

        stdcall DispatchEvent, [.minid], [.type], [.type+4], eax
        jmp     .fetch_loop


.finalize:
        cinvoke sqliteFinalize, [.stmt]
        stdcall WaitForEvents, [.futex]
        jmp     .main_loop

.finish_thread:
        stdcall MutexDestroy, mxListeners
        stdcall Terminate, 0
        return
endp



proc DispatchEvent, .evID, .evTypeLo, .evTypeHi, .evText
.pNames dd ?
begin
        pushad

        OutputValue "Dispatch one event:", [.evID], 10, -1

        mov     esi, [.evTypeLo]
        mov     edi, [.evTypeHi]
        xor     ebx, ebx

        OutputValue "Event type: ", esi, 10, -1

        stdcall CreateArray, 4
        mov     edx, eax

.bitloop:
        test    esi, esi
        jnz     .hasbits
        test    edi, edi
        jz      .endnames

.hasbits:
        test    esi, 1
        jz      .nextbit

        mov     ecx, [tblEventNames + 4*ebx]
        stdcall AddArrayItems, edx, 1
        mov     [eax], ecx

.nextbit:
        inc     ebx
        shr     edi, 1
        rcr     esi, 1
        jmp     .bitloop

.endnames:
        mov     [.pNames], edx

        stdcall WaitForMutex, mxListeners, 10
        jc      .error_mutex

        mov     edi, [pFirstListener]

.listeners_loop:
        test    edi, edi
        jz      .finishok

        OutputValue "Listener: ", edi, 16, 8

        mov     eax, [.evTypeLo]
        mov     edx, [.evTypeHi]

        test    eax, [edi+TEventsListener.typesLo]
        jnz     .sendit
        test    edx, [edi+TEventsListener.typesHi]
        jz      .next_listener

.sendit:
        mov     esi, [.pNames]
        mov     ecx, [esi+TArray.count]

        OutputValue "Send types count: ", ecx, 10, -1

.types_loop:
        dec     ecx
        js      .next_listener

        stdcall TextCreate, sizeof.TText
        mov     edx, eax

        stdcall TextCat, edx, txt "event: "
        stdcall TextCat, edx, [esi+4*ecx+TArray.array]
        stdcall TextCat, edx, <txt 13, 10, "data: ">
        stdcall TextAddString, edx, -1, [.evText]
        stdcall TextCat, edx, <txt 13, 10, 13, 10>

        stdcall TextCompact, edx
        stdcall FileWrite, [STDERR], edx, eax

        stdcall FCGI_outputText, [edi+TEventsListener.hSocket], [edi+TEventsListener.requestID], edx , FALSE
        pushf
        stdcall TextFree, edx
        popf
        jnc     .types_loop

.error_send:

; remove the listener from the queue

        OutputValue "Remove listener: ", edi, 16, 8

        stdcall SocketClose, [edi+TEventsListener.hSocket]

        mov     ebx, [edi+TEventsListener.pPrev]
        mov     ecx, [edi+TEventsListener.pNext]
        mov     eax, [pFirstListener]

        test    ebx, ebx
        cmovz   eax, ecx
        jz      .prevok

        mov     [ebx+TEventsListener.pNext], ecx        ; connect prev to next

.prevok:
        test    ecx, ecx
        jz      .nextok

        mov     [ecx+TEventsListener.pPrev], ebx

.nextok:
        mov     [pFirstListener], eax
        stdcall FreeMem, edi
        mov     edi, ecx
        jmp     .listeners_loop


.next_listener:
        mov     edi, [edi+TEventsListener.pNext]
        jmp     .listeners_loop

.finishok:
        stdcall MutexRelease, mxListeners
        clc

.finish:
        pushf
        stdcall FreeMem, [.pNames]
        popf
        popad
        return

.error_mutex:

        DebugMsg "mxListeners can't be locked."
        stc
        jmp     .finish


endp



proc AddEventListener, .hSocket, .requestID, .evTypesLo, .evTypesHi
begin
        pushad

        stdcall WaitForMutex, mxListeners, 1000
        jc      .finish

        stdcall GetMem, sizeof.TEventsListener
        jc      .finish_release

        mov     edi, eax

        mov     ebx, [.hSocket]
        mov     ecx, [.requestID]
        mov     eax, [.evTypesLo]
        mov     edx, [.evTypesHi]
        mov     [edi+TEventsListener.hSocket], ebx
        mov     [edi+TEventsListener.requestID], ecx
        mov     [edi+TEventsListener.typesLo], eax
        mov     [edi+TEventsListener.typesHi], edx

        mov     eax, [pFirstListener]

        and     [edi+TEventsListener.pPrev], 0
        mov     [edi+TEventsListener.pNext], eax

        mov     [pFirstListener], edi
        test    eax, eax
        jz      .finish_release

        mov     [eax+TEventsListener.pPrev], edi

.finish_release:

        OutputValue "Listener added: ", edi, 16, 8

        stdcall SocketSetOption, [.hSocket], soSendTimeout, 0
        stdcall MutexRelease, mxListeners
        clc

.finish:
        popad
        return
endp




sqlInsertEvent text "insert into EventQueue(type, event) values (?1, ?2);"

proc AddEvent, .typeLo, .typeHi, .event
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2,[hMainDatabase], sqlInsertEvent, sqlInsertEvent.length, eax, 0
        cinvoke sqliteBindInt64, [.stmt], 1, [.typeLo], [.typeHi]

        stdcall StrLen, [.event]
        mov     ecx, eax

        stdcall StrPtr, [.event]

        cinvoke sqliteBindText, [.stmt], 2, eax, ecx, SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stdcall SignalNewEvent
        popad
        return
endp