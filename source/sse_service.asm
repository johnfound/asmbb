; This file contains the SSE (server side events) handling code.
; It consists of a thread procedure sseServiceThread and other
; auxiliary procedures for handling the events queue.


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

EVENT_WAKE_TIMEOUT = 3


struct TEventsListener
  .pPrev     dd ?
  .pNext     dd ?

  .hSocket   dd ?       ; the socket events to be sent.
  .requestID dd ?       ; the requestID of the events request.
  .typesLo   dd ?       ; what type of events to be sent.
  .typesHi   dd ?

  .idSession dd ?       ; Event session ID.
ends


struct TEventsIPC
  .EventsFutex       dd ?

  .EventsID          dd ?       ; the minimal ID in EventQueue table that can be safely deleted.
  .EventsCNT         dd ?       ; how many times the CleanEventsQueue procedure (from different engine instances!)
                                ; considered EventsID safe. When all attached processes check this counter 8 times,
                                ; the queue is cleaned up to this ID.
                                ; This algorithm provides relatively safe and CPU friendly way of cleaning the
                                ; EventQueue table.
ends


uglobal
  mxListeners    TMutex

  pFirstListener dd ?

  fEventsTerminate    dd ?

  sSharedIPC          dd ?      ; shared memory segment ID
  pSharedIPC          dd ?      ; shared memory attached pointer

  lockQueue     dd ?
endg


evUsersOnline        = 0
evUserChanged        = 1
evMessage            = 2
evUserActivity       = 3
evSession            = 4      ; sent only once on connection initialization.

evmUsersOnline       = 1 shl evUsersOnline
evmUserChanged       = 1 shl evUserChanged
evmMessage           = 1 shl evMessage
evmUserActivity      = 1 shl evUserActivity
evmSession           = 1 shl evSession        ; always received

evmAllEventsLo = (evmUsersOnline or evmUserChanged or evmMessage or evmUserActivity) and $ffffffff
evmAllEventsHi = ((evmUsersOnline or evmUserChanged or evmMessage or evmUserActivity) shr 32) and $ffffffff


iglobal
; definition of the used event masks and names. The order is according to the related evXXXXX constant defined above!
  EventNames tblEventNames,                     \
    'users_online',                             \
    'user_changed',                             \
    'message',                                  \
    'user_activity',                            \
    'session'
endg


cFileLockIPC text "./asmbb_ipc.lock"
cFileLockQueue text "./asmbb_queue.lock"

sqlGetInitialId text "select seq from sqlite_sequence where name = 'EventQueue'"
sqlGetEvents    text "select id, type, event, receiver from EventQueue where id > ?1"

sqlClearEventSessions text "delete from EventSessions"
sqlClearEvents        text "delete from EventQueue"


proc sseServiceThread, .lparam
.stmt  dd ?
.futex dd ?
.minid dd ?
begin
        stdcall MutexCreate, 0, mxListeners
        stdcall MutexRelease, mxListeners

        stdcall FileOpenAccess, cFileLockQueue, faReadOnly or faOpenAlways or faNonBlocking
        jc      .finish_thread

        mov     [lockQueue], eax

        stdcall FileOpenAccess, cFileLockIPC, faReadOnly or faOpenAlways or faNonBlocking
        jc      .finish_thread

; obtain exclusive lock if possible.

        mov     ebx, eax

        stdcall FileLock, ebx, lockExclusive or lockTryOnly
        jc      .event_tables_ok                                ; someone else initialized everything.

;.init_the_events_tables:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlClearEventSessions, sqlClearEventSessions.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlClearEvents, sqlClearEvents.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        mov     eax, [pSharedIPC]
        or      dword [eax + TEventsIPC.EventsID], -1
        and     dword [eax + TEventsIPC.EventsCNT], 0


.event_tables_ok:

        stdcall FileLock, ebx, lockShared       ; downgrade to shared lock (or wait for initialization end)

; Here the initialization stage of the events engine ends. Start normal processing.

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

        mov     eax, [pSharedIPC]
        mov     eax, [eax+TEventsIPC.EventsFutex]
        mov     [.futex], eax                ; the value of the futex in the beginning of the cycle.

        stdcall CleanEventsQueue, [.minid]

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

        stdcall WaitForEvents, [.futex]
        jmp     .main_loop


.finish_thread:

; close all connections and delete the sessions.

        stdcall WaitForMutex, mxListeners, 10

.loop:
        mov     ecx, [pFirstListener]
        jecxz   .cons_closed

        stdcall _RemoveEventListener, ecx
        jmp     .loop

.cons_closed:
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
        stdcall _RemoveEventListener, edi
        mov     edi, eax
        jmp     .listeners_loop

.finishok:
        stdcall MutexRelease, mxListeners
        clc

.finish:
        popad
        return
endp


; The following procedure cleans the old EventQueue records.
; The algorithm used is a little bit questionable, but it seems to works somehow.
; on my tests.

sqlCleanEvents  text "delete from EventQueue where id <= ?1"

proc CleanEventsQueue, .id_start
.stmt  dd ?
.ds    shmid64_ds
begin
        pushad

        stdcall FileLock, [lockQueue], lockExclusive or lockTryOnly
        jc      .finish

        mov     eax, sys_ipc
        mov     ebx, SHMCTL
        mov     ecx, [sSharedIPC]
        mov     edx, IPC_STAT or IPC_64
        lea     edi, [.ds]
        int     $80
        test    eax, eax
        jnz     .unlock          ; should not happen!!!

        mov     eax, [.ds.shm_nattch]

        lea     edx, [8*eax]     ; 8 turns for robustness

        mov     ebx, [.id_start]
        mov     esi, [pSharedIPC]

        cmp     ebx, [esi + TEventsIPC.EventsID]
        jae     .increment

        mov     [esi + TEventsIPC.EventsID], ebx
        and     [esi + TEventsIPC.EventsCNT], 0
        jmp     .unlock

.increment:
        inc     [esi + TEventsIPC.EventsCNT]
        cmp     [esi + TEventsIPC.EventsCNT], edx
        jbe     .unlock

; set a new limit.
        xchg    ebx, [esi + TEventsIPC.EventsID]        ; ebx is the previous ID - delete up to it.
        and     [esi + TEventsIPC.EventsCNT], 0
        cmp     ebx, [esi + TEventsIPC.EventsID]
        je      .unlock                                 ; don't clean if the new and old values are equal.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCleanEvents, sqlCleanEvents.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, ebx
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

.unlock:
        stdcall FileLock, [lockQueue], lockUnlock

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
        cmp     ecx, evmSession
        je      .sendit

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
        stdcall _RemoveEventListener, edi
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




evsClosed    = 0        ; not used ?????
evsActive    = 1
evsNonActive = 2

sqlNewEventSession       text "insert into EventSessions(session, username, original, status, events) values (?1, ?2, ?2, ?3, ?4)"

proc AddEventListener, .pSpecial, .evTypesLo, .evTypesHi, .session
.stmt dd ?
begin
        pushad

        stdcall WaitForMutex, mxListeners, 1000
        jc      .finish

        mov     esi, [.pSpecial]

        stdcall GetMem, sizeof.TEventsListener
        jc      .error_release

        mov     edi, eax

        stdcall StrDup, [.session]
        mov     [edi+TEventsListener.idSession], eax

        mov     ebx, [esi+TSpecialParams.hSocket]
        mov     ecx, [esi+TSpecialParams.requestID]
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
        jz      .add_session

        mov     [eax+TEventsListener.pPrev], edi

.add_session:

; add session to the EventSessions table

        stdcall EventUserName, [.pSpecial]
        mov     esi, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlNewEventSession, sqlNewEventSession.length, eax, 0

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, esi
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 3, evsActive
        cinvoke sqliteBindInt64, [.stmt], 4, [.evTypesLo], [.evTypesHi]

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDel, esi

; final settings to the socket.

        OutputValue "Listener added: ", edi, 16, 8

        stdcall SocketSetOption, [edi+TEventsListener.hSocket], soSendTimeout, 10
        stdcall MutexRelease, mxListeners

        stdcall AddEvent, evSession, [.session], [.session]
        stdcall SendUserChanged, [.session]
        clc

.finish:
        popad
        return


.error_release:

        stdcall MutexRelease, mxListeners
        stc
        popad
        return
endp



; returns the next listener in the list or 0 if the last listener is removed.

sqlDeleteEventSession text "delete from EventSessions where session = ?1"

proc _RemoveEventListener, .pListener
.stmt dd ?
begin
        pushad

        OutputValue "Remove event listener: ", [.pListener], 16, 8

        mov     edi, [.pListener]

        stdcall FCGI_output, [edi+TEventsListener.hSocket], [edi+TEventsListener.requestID], 0, 0, TRUE
        stdcall FCGI_send_end_request, [edi+TEventsListener.hSocket], [edi+TEventsListener.requestID], FCGI_REQUEST_COMPLETE
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

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2,[hMainDatabase], sqlDeleteEventSession, sqlDeleteEventSession.length, eax, 0

        stdcall StrPtr, [edi+TEventsListener.idSession]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stdcall SendUserClosed, [edi+TEventsListener.idSession]

; free the memory.
        stdcall StrDel, [edi+TEventsListener.idSession]
        stdcall FreeMem, edi
        popad
        return
endp



proc RemoveSession, .session
.stmt dd ?
begin
        pushad
        stdcall WaitForMutex, mxListeners, 1000
        jc      .finish

        mov     edi, [pFirstListener]

.loop:
        test    edi, edi
        jz      .not_found

        stdcall StrCompCase, [.session], [edi+TEventsListener.idSession]
        jc      .found

        mov     edi, [edi+TEventsListener.pNext]
        jmp     .loop

.not_found:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2,[hMainDatabase], sqlDeleteEventSession, sqlDeleteEventSession.length, eax, 0

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stdcall SendUserClosed, [.session]
        jmp     .release

.found:
        stdcall _RemoveEventListener, edi

.release:
        stdcall MutexRelease, mxListeners

.finish:
        popad
        return
endp






sqlRenameEventUser text "update EventSessions set username=?2, original=?3 where session=?1"

proc RenameEventUser, .session, .newname, .original
.stmt dd ?
begin
        pushad

        if defined options.DebugMode & options.DebugMode
           stdcall FileWriteString, [STDERR], txt "Rename user with session: <"
           stdcall FileWriteString, [STDERR], [.session]
           stdcall FileWriteString, [STDERR], txt "> to ["
           stdcall FileWriteString, [STDERR], [.newname]
           stdcall FileWriteString, [STDERR], <txt "] ", 13, 10>
        end if

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

        DebugMsg "Rename user - send changed"

        stdcall SendUserChanged, [.session]

.finish:
        popad
        return
endp




sqlSetStatusEventSession text "update EventSessions set status = ?2 where session = ?1 and (status <> ?2)"

proc SetEventUserStatus, .session, .status
.stmt dd ?
begin
        pushad
        cmp     [.status], 0
        je      .delete_session

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

.send_changed:
        stdcall SendUserChanged, [.session]

.changes_ok:
        popad
        return

.delete_session:
        stdcall RemoveSession, [.session]
        jmp     .changes_ok

endp





; Adds an event to the event queue.
; if [.receiver] == 0 then the event is broadcaseted to all registered listeners.

sqlInsertEvent text "insert into EventQueue(type, event, receiver) values (?1, ?2, ?3)"

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




cContentTypeEvent text 'Content-Type: text/event-stream', 13, 10, "X-Accel-Buffering: no", 13, 10, 13, 10, "retry: 1000", 13, 10, 13, 10  ;"X-Accel-Buffering: no", 13, 10, "Transfer-Encoding: chunked", 13, 10, 13, 10

proc InitEventSession, .pSpecial, .evMaskLo, .evMaskHi
.session dd ?
begin
        pushad

        mov     esi, [.pSpecial]

        stdcall FCGI_output, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], cContentTypeEvent, cContentTypeEvent.length, FALSE
        jc      .error

        stdcall GetRandomString, 32
        mov     [.session], eax

        stdcall AddEventListener, esi, [.evMaskLo], [.evMaskHi], [.session]
        jc      .error

        or      [esi+TSpecialParams.fDontFree], -1
        clc
        popad
        mov     eax, [.session]
        return

.error:
        stdcall StrDel, [.session]
        stc
        popad
        return
endp


;==============================================================================================================
; The IPC code.
; Create and attach shared memory block to be used for the IPC futex and other objects
; shared between several instances of AsmBB engine.
;
; NOTE: Some web servers will spawn several running instances of AsmBB engine.
;       for example apache or lighttpt can spawn FastCGI processes.
;       But the events are global, so need to be processed by all instances of the engine.
;
; This procedure is called once as a part of engine initialization (before connecting to the database).

proc InitEventsIPC
.lock dd ?
begin
        pushad

        and     [fEventsTerminate], 0     ; it is 0 anyway, but...

        mov     eax, sys_ipc
        mov     ebx, SHMGET
        mov     ecx, 'ASM!'
        mov     edx, sizeof.TEventsIPC
        mov     esi, IPC_CREAT or 600o
        int     $80

        test    eax, eax
        js      .error

        mov     ecx, eax                 ; shmid
        mov     [sSharedIPC], eax        ; for future use.

        mov     eax, sys_ipc
        mov     ebx, SHMAT
        xor     edx, edx
        xor     edi, edi

        mov     [pSharedIPC], edi
        mov     esi, pSharedIPC
        int     $80

        test    eax, eax
        js      .error

        clc
        popad
        return

.error:
        stc
        popad
        return
endp




proc WaitForEvents, .value
.timeout lnx_timespec
begin
        pushad

        mov     [.timeout.tv_sec], EVENT_WAKE_TIMEOUT
        mov     [.timeout.tv_nsec], 0

        mov     eax, sys_futex
        mov     ebx, [pSharedIPC]
;        lea     ebx, [ebx+TEventsIPC.EventsFutex]      TEventsIPC.EventsFutex == 0 !!!

        mov     ecx, FUTEX_WAIT
        mov     edx, [.value]
        lea     esi, [.timeout]

        cmp     edx, [ebx]      ; don't make system call if obvious.
        jne     .no_wait

        int     $80
        test    eax, eax
        jz      .no_wait

        cmp     eax, EINTR
        je      .forced_exit

.no_wait:
        clc
        popad
        return

.forced_exit:
        stc
        popad
        return
endp




proc SignalNewEvent
begin
        pushad

        mov     ebx, [pSharedIPC]
        lock inc dword [ebx + TEventsIPC.EventsFutex]

        mov     eax, sys_futex
        mov     ecx, FUTEX_WAKE
        mov     edx, $7fffffff
        int     $80

        popad
        return
endp











; utility and event handling procedures.



proc EventUserName, .pSpecial
begin
        pushad
        mov     esi, [.pSpecial]

        mov     edx, [esi+TSpecialParams.userName]
        test    edx, edx
        jnz     .real_name

        mov     eax, [esi+TSpecialParams.userLang]
        stdcall StrDupMem, [cAnonName+8*eax]
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



sqlSelectUsers text "select session, username, original, status, events from EventSessions"

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

        stdcall StrCat, edi, txt ', "events": '
        cinvoke sqliteColumnText, [.stmt], 4   ; events
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



sqlSelectOneUser text "select session, username, original, status, events from EventSessions where session = ?1"

proc SendUserChanged, .session
.stmt dd ?
begin
        pushad

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

        stdcall StrCat, edi, txt ', "events": '
        cinvoke sqliteColumnText, [.stmt], 4   ; events
        stdcall StrCat, edi, eax

        stdcall StrCat, edi, txt '}'

        stdcall AddEvent, evUserChanged, edi, 0
        stdcall StrDel, edi

.finalize:
        cinvoke sqliteFinalize, [.stmt]
        popad
        return
endp



proc SendUserClosed, .session
begin
        pushad
        stdcall StrDupMem, txt '{ "sid": "'
        mov     edi, eax

        stdcall StrDup, [.session]
        stdcall StrTrim, eax, 8
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt '", "user": "", "originalname": "", "status": 0, "events": 3}'

        stdcall AddEvent, evUserChanged, edi, 0
        stdcall StrDel, edi

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


