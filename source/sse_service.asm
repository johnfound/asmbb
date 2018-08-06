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

  .idSession dd ?       ; Event session ID.
ends


uglobal
  mxListeners    TMutex
  pFirstListener dd ?
endg


iglobal

; definition of the used event masks and names.

  evUsersOnline        = 0
  evUserChanged        = 1
  evMessage            = 2

  evmUsersOnline       = 1 shl evUsersOnline
  evmUserChanged       = 1 shl evUserChanged
  evmMessage           = 1 shl evMessage

  EventNames tblEventNames,                     \
    'users_online',                             \
    'user_changed',                             \
    'message'
endg


sqlGetInitialId text "select id from EventQueue order by id desc limit 1;"
sqlGetEvents    text "select id, type, event, receiver from EventQueue where id > ?1;"
sqlCleanEvents  text "delete from EventQueue where id <= ?1;"

proc sseServiceThread, .lparam
.stmt  dd ?
.futex dd ?
.minid dd ?
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
        xor     ebx, ebx

.fetch_loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finalize

        inc     ebx

        cinvoke sqliteColumnInt, [.stmt], 0     ; id
        mov     [.minid], eax

        stdcall DispatchEvent, [.stmt]
        jmp     .fetch_loop

.finalize:
        cinvoke sqliteFinalize, [.stmt]

        test    ebx, ebx
        jnz     .heartbeat_ok

        stdcall SendHeartbeatAll

.heartbeat_ok:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCleanEvents, sqlCleanEvents.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.minid]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stdcall UpdateAndCleanSessions
        stdcall WaitForEvents, [.futex]
        jmp     .main_loop


.finish_thread:

        stdcall MutexDestroy, mxListeners
        stdcall Terminate, 0
        return
endp


cHeartbeat text ":", 13, 10, 13, 10

proc SendHeartbeatAll
begin
        pushad

        stdcall WaitForMutex, mxListeners, 10
        jc      .finish

        mov     edi, [pFirstListener]

.listeners_loop:
        test    edi, edi
        jz      .finishok

        stdcall FCGI_output, [edi+TEventsListener.hSocket], [edi+TEventsListener.requestID], cHeartbeat, cHeartbeat.length, FALSE
        jc      .error_send

.next_listener:
        mov     edi, [edi+TEventsListener.pNext]
        jmp     .listeners_loop

.error_send:
        stdcall RemoveEventListener, edi
        mov     edi, eax
        jmp     .listeners_loop

.finishok:
        stdcall MutexRelease, mxListeners
        clc

.finish:
        popad
        return
endp


sqlUpdateEventSession    text "update EventSessions set time = strftime('%s', 'now') where session = ?1;"
sqlCloseInactiveSessions text "update EventSessions set status = 0 where status <> 0 and time < strftime('%s', 'now') - 10;"  ; 10 seconds timeout of the chat session.
sqlDeleteOldSessions     text "delete from EventSessions where status <> 0 and time < strftime('%s', 'now') - 86400;"         ; 24h timeout to delete events session.

proc UpdateAndCleanSessions
.stmt dd ?
begin
        pushad

        stdcall WaitForMutex, mxListeners, 100
        jc      .finish

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateEventSession, sqlUpdateEventSession.length, eax, 0

        mov     edi, [pFirstListener]

.listeners_loop:
        test    edi, edi
        jz      .finishok

        stdcall StrPtr, [edi+TEventsListener.idSession]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteReset, [.stmt]

.next_listener:
        mov     edi, [edi+TEventsListener.pNext]
        jmp     .listeners_loop

.error_send:
        stdcall RemoveEventListener, edi
        mov     edi, eax
        jmp     .listeners_loop

.finishok:
        cinvoke sqliteFinalize, [.stmt]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCloseInactiveSessions, sqlCloseInactiveSessions.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        cinvoke sqliteChanges, [hMainDatabase]
        test    eax, eax
        jz      .changes_ok

        stdcall SendUsersOnline, 0

.changes_ok:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDeleteOldSessions, sqlDeleteOldSessions.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stdcall MutexRelease, mxListeners
        clc

.finish:
        popad
        return
endp


; The SQL statement [.stmt] points to one row of the table EventQueue
; the procedure gets the needed data and sends events to all registered listeners,
; according to the subscribed events and receiver parameter of the event.
;
; select id, type, event, receiver from EventQueue where id > ?1;

proc DispatchEvent, .stmt
.evMask rd 2
begin
        pushad

        cinvoke sqliteColumnInt, [.stmt], 1     ; type
        mov     ecx, eax
        and     ecx, $3f
        mov     ebx, ecx        ; the event number

        xor     eax, eax
        xor     edx, edx
        mov     [.evMask], eax
        mov     [.evMask+4], edx
        inc     eax

        cmp     ecx, 32
        jb      @f
        inc     edx
        sub     ecx, 32
@@:
        shl     eax, cl
        mov     [.evMask+4*edx], eax    ; bit mask of the event type

        cinvoke sqliteColumnText, [.stmt], 2    ; event text
        mov     esi, eax

        cinvoke sqliteColumnText, [.stmt], 0    ; id
        mov     edx, eax

        stdcall StrDupMem, txt "event: "
        stdcall StrCat, eax, [tblEventNames + 4*ebx]
        stdcall StrCat, eax, <txt 13, 10, "data: ">

        test    esi, esi
        jz      .txt_ok
        stdcall StrCat, eax, esi
.txt_ok:
        stdcall StrCat, eax, <txt 13, 10, "id: ">
        stdcall StrCat, eax, edx
        stdcall StrCat, eax, <txt 13, 10, 13, 10>
        mov     ebx, eax

        cinvoke sqliteColumnText, [.stmt], 3    ; receiver
        mov     esi, eax

        stdcall WaitForMutex, mxListeners, 10
        jc      .error_mutex

        mov     edi, [pFirstListener]
        mov     ecx, [.evMask]
        mov     edx, [.evMask+4]

.listeners_loop:
        test    edi, edi
        jz      .finishok

        test    esi, esi
        jz      .can_receive

        stdcall StrCompCase, esi, [edi+TEventsListener.idSession]
        jnc     .next_listener

.can_receive:
        test    ecx, [edi+TEventsListener.typesLo]
        jnz     .sendit
        test    edx, [edi+TEventsListener.typesHi]
        jz      .next_listener

.sendit:
        stdcall StrPtr, ebx
        stdcall FCGI_output, [edi+TEventsListener.hSocket], [edi+TEventsListener.requestID], eax, [eax+string.len], FALSE
        jc      .error_send

.next_listener:
        mov     edi, [edi+TEventsListener.pNext]
        jmp     .listeners_loop

.error_send:
        stdcall RemoveEventListener, edi
        mov     edi, eax
        jmp     .listeners_loop

.finishok:
        stdcall MutexRelease, mxListeners
        stdcall StrDel, ebx
        clc

.finish:
        popad
        return

.error_mutex:
        stdcall StrDel, ebx
        stc
        jmp     .finish
endp




; returns the next listener in the list or 0 if the last listener is removed.
proc RemoveEventListener, .pListener
.stmt dd ?
begin
        pushad

        OutputValue "Remove event listener: ", [.pListener], 16, 8

        mov     edi, [.pListener]

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
        mov     [esp+4*regEAX], ecx     ; the next listener.

; delete the removed session.

;        stdcall SetEventStatus, [edi+TEventsListener.idSession], evsClosed

        stdcall StrDel, [edi+TEventsListener.idSession]
        stdcall FreeMem, edi
        popad
        return
endp


proc AddEventListener, .hSocket, .requestID, .evTypesLo, .evTypesHi, .session
begin
        pushad

        stdcall WaitForMutex, mxListeners, 1000
        jc      .finish

        stdcall GetMem, sizeof.TEventsListener
        jc      .finish_release

        mov     edi, eax

        stdcall StrDup, [.session]
        mov     [edi+TEventsListener.idSession], eax

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

        stdcall SocketSetOption, [.hSocket], soSendTimeout, 10
        stdcall MutexRelease, mxListeners
        clc

.finish:
        popad
        return
endp




sqlInsertEvent text "insert into EventQueue(type, event, receiver) values (?1, ?2, ?3);"

proc AddEvent, .evNumber, .evText, .receiver
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2,[hMainDatabase], sqlInsertEvent, sqlInsertEvent.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.evNumber]

        cmp     [.evText], 0
        je      .text_ok

        stdcall StrPtr, [.evText]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

.text_ok:
        cmp     [.receiver], 0
        je      .receiver_ok

        stdcall StrPtr, [.receiver]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

.receiver_ok:
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stdcall SignalNewEvent
        popad
        return
endp


evsClosed    = 0
evsActive    = 1
evsNonActive = 2

sqlNewEventSession       text "insert into EventSessions(session, time, username, original, status) values (?1, strftime('%s', 'now'), ?2, ?2, ?3);"
sqlExistsEventSession    text "select 1 from EventSessions where session = ?1"

proc AddEventSession, .pSpecial, .session
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlExistsEventSession, sqlExistsEventSession.length, eax, 0

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_ROW
        jne     .insertnew

.activate:
        stdcall SetEventStatus, [.session], evsActive

        popad
        return

.insertnew:

        stdcall EventUserName, [.pSpecial]
        mov     esi, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlNewEventSession, sqlNewEventSession.length, eax, 0

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, esi
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 3, evsClosed
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDel, esi
        jmp     .activate
endp



sqlRenameEventUser text "update EventSessions set username=?2, original=?3, time=strftime('%s', 'now') where session=?1;"

proc RenameEventUser, .session, .newname, .original
.stmt dd ?
begin
        pushad

        stdcall StrByteUtf8, [.newname], CHAT_MAX_USER_NAME
        stdcall StrTrim, [.newname], eax

        stdcall StrClipSpacesR, [.newname]
        stdcall StrClipSpacesL, [.newname]
        stdcall StrLen, [.newname]
        test    eax, eax
        jnz     .name_ok

        stdcall StrCopy, [.newname], [.original]

.name_ok:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlRenameEventUser, sqlRenameEventUser.length, eax, 0

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.newname]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.original]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        cinvoke sqliteChanges, [hMainDatabase]
        test    eax, eax
        jz      .finish

        stdcall SendUserChanged, [.session]

.finish:
        popad
        return
endp



sqlSetStatusEventSession text "update EventSessions set status = ?2 where session = ?1 and status <> ?2;"

proc SetEventStatus, .session, .status
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSetStatusEventSession, sqlSetStatusEventSession.length, eax, 0

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteBindInt, [.stmt], 2, [.status]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        cinvoke sqliteChanges, [hMainDatabase]
        test    eax, eax
        jz      .changes_ok

        stdcall SendUserChanged, [.session]

.changes_ok:
        popad
        return
endp


cContentTypeEvent text 'Content-Type: text/event-stream', 13, 10, "X-Accel-Buffering: no", 13, 10, 13, 10, "retry: 1000", 13, 10, 13, 10  ;"X-Accel-Buffering: no", 13, 10, "Transfer-Encoding: chunked", 13, 10, 13, 10

proc InitEventSession, .pSpecial, .evMaskLo, .evMaskHi
.session dd ?
begin
        pushad

        mov     esi, [.pSpecial]
        or      [esi+TSpecialParams.fDontFree], -1

        stdcall GetCookieValue, [esi+TSpecialParams.params], "eventsid"
        jnc     .session_ok

        stdcall GetRandomString, 32

.session_ok:
        mov     [.session], eax

; set cookie.
        stdcall StrNew
        stdcall StrCat, eax, "Set-Cookie: eventsid="
        stdcall StrCat, eax, [.session]
        stdcall StrCat, eax, <"; Path=/", 13, 10>

        push    eax
        stdcall StrPtr, eax
        stdcall FCGI_output, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], eax, [eax+string.len], FALSE
        stdcall StrDel ; from the stack

        stdcall FCGI_output, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], cContentTypeEvent, cContentTypeEvent.length, FALSE
        jc      .error

        stdcall AddEventListener, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], [.evMaskLo], [.evMaskHi], [.session]
        stdcall AddEventSession, esi, [.session]
        clc
        popad
        mov     eax, [.session]
        return

.error:
        stdcall SetEventStatus, [.session], evsClosed
        stdcall StrDel, [.session]
        stc
        popad
        return
endp


proc EventUserName, .pSpecial
begin
        pushad
        mov     esi, [.pSpecial]

        mov     edx, [esi+TSpecialParams.userName]
        test    edx, edx
        jnz     .real_name

        stdcall StrDupMem, cAnonName
        mov     edx, eax

        movzx   eax, byte [esi+TSpecialParams.remoteIP]
        xor     al, byte [esi+TSpecialParams.remoteIP+1]
        xor     al, byte [esi+TSpecialParams.remoteIP+2]
        xor     al, byte [esi+TSpecialParams.remoteIP+3]
        stdcall NumToStr, eax, ntsHex or ntsUnsigned or ntsFixedWidth + 2
        stdcall StrCat, edx, eax
        stdcall StrDel, eax
        jmp     .name_ok

.real_name:
        stdcall StrDup, edx
        mov     edx, eax

.name_ok:
        mov     [esp+4*regEAX], edx
        popad
        return
endp



sqlSelectUsers text "select time, session, username, original, status from EventSessions where status<>0 order by original;"

proc SendUsersOnline, .session
.stmt dd ?
begin
        pushad

        xor     ebx, ebx        ; record counter.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectUsers, sqlSelectUsers.length, eax, 0

        stdcall StrDupMem, txt '{ "users": [ '
        mov     edi, eax

.fetch_loop_user:

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish_user_set

        test    ebx, ebx        ; is there previous record?
        je      .comma_ok2

        stdcall StrCat, edi, txt ", "

.comma_ok2:

        stdcall StrCat, edi, '{ "sid": "'

        cinvoke sqliteColumnText, [.stmt], 1    ; session
        stdcall StrDupMem, eax
        stdcall StrTrim, eax, 8
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt '", "user": "'

        cinvoke sqliteColumnText, [.stmt], 2    ; username
        test    eax, eax
        jz      @f
        stdcall StrEncodeJS, eax
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
@@:
        stdcall StrCat, edi, txt '", "originalname": "'

        cinvoke sqliteColumnText, [.stmt], 3    ; original
        test    eax, eax
        jz      @f
        stdcall StrCat, edi, eax
@@:
        stdcall StrCat, edi, txt '", "status": '
        cinvoke sqliteColumnText, [.stmt], 4   ; status
        stdcall StrCat, edi, eax

        stdcall StrCat, edi, txt ' }'

        inc     ebx
        jmp     .fetch_loop_user

.finish_user_set:

        cinvoke sqliteFinalize, [.stmt]
        stdcall StrCat, edi, txt " ] }"

        stdcall AddEvent, evUsersOnline, edi, [.session]
        stdcall StrDel, edi
        popad
        return
endp



sqlSelectOneUser text "select session, username, original, status from EventSessions where session = ?1;"

proc SendUserChanged, .session
.stmt dd ?
begin
        pushad

        xor     ebx, ebx        ; record counter.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectOneUser, sqlSelectOneUser.length, eax, 0

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finalize

        stdcall StrDupMem, txt '{ "sid": "'
        mov     edi, eax

        cinvoke sqliteColumnText, [.stmt], 0    ; session
        stdcall StrDupMem, eax
        stdcall StrTrim, eax, 8
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt '", "user": "'

        cinvoke sqliteColumnText, [.stmt], 1    ; username
        test    eax, eax
        jz      @f
        stdcall StrEncodeJS, eax
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
@@:
        stdcall StrCat, edi, txt '", "originalname": "'

        cinvoke sqliteColumnText, [.stmt], 2    ; original
        test    eax, eax
        jz      @f
        stdcall StrCat, edi, eax
@@:
        stdcall StrCat, edi, txt '", "status": '
        cinvoke sqliteColumnText, [.stmt], 3   ; status
        stdcall StrCat, edi, eax

        stdcall StrCat, edi, txt '}'

        stdcall AddEvent, evUserChanged, edi, 0
        stdcall StrDel, edi

.finalize:
        cinvoke sqliteFinalize, [.stmt]
        popad
        return
endp




proc StrEncodeJS, .hString
begin
        pushad

        stdcall StrLen, [.hString]
        mov     ecx, eax

        stdcall StrNew
        mov     [esp+4*regEAX], eax

        shl     ecx, 3                  ; memory x8

        stdcall StrSetCapacity, eax, ecx
        mov     edi, eax
        mov     ebx, eax

        stdcall StrPtr, [.hString]
        mov     esi, eax

        xor     eax, eax

.loop:
        lodsb

        test    al, al
        jz      .end_of_string

        cmp     al, ' '
        jb      .loop

        cmp     al, '<'
        je      .char_less_then
        cmp     al, '>'
        je      .char_greater_then
        cmp     al, '"'
        je      .char_quote
        cmp     al, '&'
        je      .char_amp

        cmp     al, "\"
        jne     .store

        stosb
.store:
        stosb
        jmp     .loop

.end_of_string:
        mov     [edi], eax
        sub     edi, ebx
        mov     [ebx+string.len], edi

        popad
        return


.char_less_then:
        mov     dword [edi], '&lt;'
        add     edi, 4
        jmp     .loop

.char_greater_then:
        mov     dword [edi], '&gt;'
        add     edi, 4
        jmp     .loop


.char_quote:
        mov     dword [edi], '&quo'
        mov     word [edi+4],'t;'
        add     edi, 6
        jmp     .loop

.char_amp:
        mov     dword [edi], '&amp'
        mov     byte [edi+4], ';'
        add     edi, 5
        jmp     .loop

endp


