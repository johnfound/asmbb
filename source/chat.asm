CHAT_MAX_USER_NAME = 20
CHAT_MAX_MESSAGE = 1000
CHAT_BACKLOG_DEFAULT = 100

;sqlUpdateChatSession    text "update ChatUsers set time = strftime('%s', 'now'), force = NULL where session = ?1;"
;sqlDeleteClosedSessions text "update ChatUsers set status = 0 where time < strftime('%s', 'now') - 10; delete from ChatUsers where time < strftime('%s', 'now') - 86400;"           ; 10 seconds timeout of the chat session.


proc ChatRealTime, .pSpecial
begin
        pushad

        mov     esi, [.pSpecial]

        stdcall ChatPermissions, esi
        jc      .error_no_permissions

        stdcall InitEventSession, esi, evmMessage or evmUsersOnline, 0  ; if CF=0 returns session string in EAX
        jc      .exit

        stdcall ChatInitialEvents, eax
        stdcall StrDel, eax

.exit:
        popad
        xor     eax, eax
        stc                      ; all communications here are finished: CF=1 and EAX=0.
        return

.error_no_permissions:

        stdcall TextCreate, sizeof.TText
        stdcall AppendError, eax, "403 Forbidden", esi
        stdcall FCGI_outputText, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], edx, TRUE
        stdcall TextFree, edx
        jmp     .exit
endp



sqlSelectChat  text "select id, time, user, original, message from ChatLog where id in (select id from chatlog order by id desc limit ?1)"

proc ChatInitialEvents, .session
.stmt             dd ?
begin
        pushad

        xor     ebx, ebx       ; the count of the fetched messages.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectChat, sqlSelectChat.length, eax, 0

        mov     eax, CHAT_BACKLOG_DEFAULT
        stdcall GetParam, 'chat_backlog_length', gpInteger
        cinvoke sqliteBindInt, [.stmt], 1, eax

        stdcall StrDupMem, <txt '{ "msgs": [ '>         ; start of the messages data set.
        mov     edi, eax

.fetch_loop_msg:

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish_msg_set

; is there previous record?

        test    ebx, ebx
        jz      .comma_ok1

        stdcall StrCat, edi, txt ", "

.comma_ok1:

        stdcall StrCat, edi, '{ "id": '

        cinvoke sqliteColumnText, [.stmt], 0
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt ', "time": '

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt ', "user": "'

        cinvoke sqliteColumnText, [.stmt], 2
        test    eax, eax
        jz      @f
        stdcall StrEncodeJS, eax
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
@@:
        stdcall StrCat, edi, txt '", "originalname": "'

        cinvoke sqliteColumnText, [.stmt], 3
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt '", "text": "'
        cinvoke sqliteColumnText, [.stmt], 4
        stdcall StrEncodeJS, eax
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt '" }'

        inc     ebx
        jmp     .fetch_loop_msg

.finish_msg_set:

        cinvoke sqliteFinalize, [.stmt]

        test    ebx, ebx
        jz      .messages_ok

        stdcall StrCat, edi, txt " ] }"
        stdcall AddEvent, evMessage, edi, [.session], [.session]

.messages_ok:
        stdcall StrDel, edi
        stdcall AddEvent, evUsersOnline, 0, [.session], [.session]
        popad
        return
endp



sqlPostChatMessage text "insert into chatlog (time, user, original, message) values (?1, ?2, ?3, ?4);"
sqlGetChatUser     text "select username from EventSessions where session = ?1;"

proc ChatPage, .pSpecial
.stmt dd ?
begin
        pushad

        mov     esi, [.pSpecial]

; the user permissions

        stdcall ChatPermissions, esi
        jc      .error_no_permissions

        cmp     [esi+TSpecialParams.post_array], 0
        jne     .post_new_message

        stdcall StrCat, [esi+TSpecialParams.page_title], cChatTitle
        stdcall LogUserActivity, esi, uaChatting, 0

        stdcall RenderTemplate, 0, txt "chat.tpl", 0, [.pSpecial]

        clc
        mov     [esp+4*regEAX], eax
        popad
        return

.error_no_permissions:
        stdcall TextCreate, sizeof.TText
        stdcall AppendError, eax, "403 Forbidden", esi
        jmp     .finish_replace


.post_new_message:

        xor     edi, edi
        stdcall GetCookieValue, [esi+TSpecialParams.params], "eventsid"
        jc      .error_no_permissions

        mov     edi, eax

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "cmd", 0
        test    eax, eax
        jz      .finish

        mov     ecx, .post_message
        stdcall StrCompCase, eax, txt "message"
        jc      .do_it

        mov     ecx, .rename_user
        stdcall StrCompCase, eax, txt "rename"
        jc      .do_it

        mov     ecx, .change_status
        stdcall StrCompCase, eax, txt "status"
        jc      .do_it

        mov     ecx, .finish

.do_it:
        stdcall StrDel, eax
        jmp     ecx


.post_message:

locals
  .id       dd ?
  .time     dd ?
  .user     dd ?
  .original dd ?
  .text     dd ?
endl

        stdcall GetTime
        xor     ecx, ecx
        mov     [.id], ecx
        mov     [.time], eax
        mov     [.user], ecx
        mov     [.original], ecx
        mov     [.text], ecx

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "chat_message", 0
        mov     [.text], eax
        test    eax, eax
        jz      .finish

; message text sanitation

        stdcall StrByteUtf8, [.text], CHAT_MAX_MESSAGE
        stdcall StrTrim, [.text], eax

        stdcall StrClipSpacesR, [.text]
        stdcall StrClipSpacesL, [.text]

        stdcall StrLen, [.text]
        test    eax, eax
        jz      .finish

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetChatUser, sqlGetChatUser.length, eax, 0

        stdcall StrPtr, edi
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .username_ok

        cinvoke sqliteColumnText, [.stmt], 0
        stdcall StrDupMem, eax
        mov     [.user], eax

.username_ok:
        cinvoke sqliteFinalize, [.stmt]

        stdcall EventUserName, [.pSpecial]
        mov     [.original], eax

        cinvoke sqliteExec, [hMainDatabase], sqlBegin, 0, 0, 0

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlPostChatMessage, sqlPostChatMessage.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.time]

        cmp     [.user], 0
        je      .username_ok2

        stdcall StrPtr, [.user]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

.username_ok2:
        stdcall StrPtr, [.original]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.text]
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        mov     ebx, sqlRollback
        cmp     eax, SQLITE_DONE
        jne     .finish_query

        mov     ebx, sqlCommit
        cinvoke sqliteLastInsertRowID, [hMainDatabase]
        mov     [.id], eax

.finish_query:

        cinvoke sqliteFinalize, [.stmt]
        cinvoke sqliteExec, [hMainDatabase], ebx, 0, 0, 0

        cmp     [.id], 0        ; the insert in the chatlog has been failed and the ID is unknown.
        je      .finish         ; ... so, don't create an event.

        stdcall FormatJsonMessage, [.id], [.time], [.user], [.original], [.text]

        stdcall AddEvent, evMessage, eax, 0, 0
        stdcall StrDel, eax

.finish:
        stdcall StrDel, [.user]
        stdcall StrDel, [.original]
        stdcall StrDel, [.text]
        stdcall StrDel, edi     ; the chatsid string.

        stdcall TextCreate, sizeof.TText
        stdcall TextCat, eax, <"Content-type: text/plain", 13, 10, 13, 10, "OK", 13, 10>

.finish_replace:
        stc
        mov     [esp+4*regEAX], edx
        popad
        return


.rename_user:
        stdcall GetPostString, [esi+TSpecialParams.post_array], "username", txt "  "

        mov     edx, eax
        stdcall EventUserName, esi
        stdcall RenameEventUser, edi, edx, eax

        stdcall StrDel, eax
        stdcall StrDel, edx
        jmp     .finish


.change_status:
        stdcall GetPostString, [esi+TSpecialParams.post_array], "status", 0
        test    eax, eax
        jz      .finish

        push    eax
        stdcall StrToNumEx, eax
        stdcall StrDel ; from the stack

        stdcall SetEventStatus, edi, eax
        jmp     .finish


endp





proc ChatPermissions, .pSpecial
begin
        push    eax esi

        mov     esi, [.pSpecial]

        stdcall GetParam, "chat_enabled", gpInteger
        jc      .not_ok

        test    eax, eax
        jz      .not_ok

        stdcall GetParam, "chat_anon", gpInteger
        jc      .check_permissions

        test    eax, eax
        jnz     .permissions_ok

.check_permissions:

        test    [esi+TSpecialParams.userStatus], permChat or permAdmin
        jnz     .permissions_ok

.not_ok:
        stc
        pop     esi eax
        return

.permissions_ok:
        clc
        pop     esi eax
        return
endp




proc FormatJsonMessage, .id, .time, .user, .original, .text
begin
        pushad

        stdcall StrDupMem, txt '{ "msgs": [ '
        mov     edi, eax

        stdcall StrCat, edi, '{ "id": '
        stdcall NumToStr, [.id], ntsDec or ntsUnsigned
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt ', "time": '

        stdcall NumToStr, [.time], ntsDec or ntsUnsigned
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt ', "user": "'

        cmp     [.user], 0
        je      @f
        stdcall StrEncodeJS, [.user]
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
@@:
        stdcall StrCat, edi, txt '", "originalname": "'

        stdcall StrCat, edi, [.original]
        stdcall StrCat, edi, txt '", "text": "'
        stdcall StrEncodeJS, [.text]
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt '" } ] }'

        mov     [esp+4*regEAX], edi
        popad
        return
endp




cCRLF2 text 13, 10, 13, 10

if defined options.DebugWebSSE & options.DebugWebSSE

cContentTypeEvent2 text 'Content-Type: text/event-stream', 13, 10, "X-Accel-Buffering: yes", 13, 10, 13, 10, "retry: 1000", 13, 10, 13, 10


proc EchoRealTime, .pSpecialParams
.bytes dd ?
begin
        pushad

        DebugMsg "Started echo long life thread!"

        mov     esi, [.pSpecialParams]

        cmp     [fEventsTerminate], 0
        jne     .finish_socket

        mov     edi, cContentTypeEvent
        mov     ecx, cContentTypeEvent.length
        cmp     [esi+TSpecialParams.page_num], 0
        je      @f

        mov     edi, cContentTypeEvent2
        mov     ecx, cContentTypeEvent2.length

@@:
        stdcall FCGI_output, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], edi, ecx, FALSE

        stdcall StrDupMem, <txt 'event: message', 13, 10, 'data: '>        ; echo message
        mov     edi, eax

        mov     ebx, cContentTypeEvent.length

.event_loop_msg:

        stdcall StrPtr, edi
        stdcall FCGI_output, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], eax, [eax+string.len], FALSE
        jc      .finish

        stdcall NumToStr, ebx, ntsDec or ntsUnsigned or ntsFixedWidth + 6
        push    eax

        stdcall StrPtr, eax
        stdcall FCGI_output, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], eax, [eax+string.len], FALSE
        stdcall StrDel ; from the stack
        jc      .finish

        stdcall FCGI_output, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], cCRLF2, cCRLF2.length, FALSE
        jc      .finish

        cmp     [fEventsTerminate], 0
        jne     .finish_socket

        add     ebx, 32 ; one event lenght

        stdcall Sleep, 100
        jmp     .event_loop_msg


.finish_socket:

        stdcall FCGI_output, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], 0, 0, TRUE

.finish:

        stdcall StrDel, edi

        DebugMsg "Finished echo long life thread!"

        popad
        xor     eax, eax
        stc
        return
endp

else
  EchoRealTime = 0
end if
