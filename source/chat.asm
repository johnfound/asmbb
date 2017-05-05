; select not processed messages but not older than 1h.
sqlSelectChat text "select id, time, user, original, message from ChatLog where id > ?1 and time >  strftime('%s', 'now') - 3600;"
sqlSelectUsers text "select time, session, username, original, status, _ROWID_ from ChatUsers where _ROWID_ > ?1;"

cContentTypeEvent text 'Content-Type: text/event-stream', 13, 10, "Access-Control-Allow-Origin: *", 13, 10, 13, 10  ;"X-Accel-Buffering: no", 13, 10, "Transfer-Encoding: chunked", 13, 10, 13, 10
cKeepAlive        text ': AsmBB', 13, 10, 13, 10


proc ChatRealTime, .hSocket, .requestID, .pSpecialParams
.stmt    dd ?
.futex   dd ?
.unique  dd ?
.session dd ?
.cnt     dd ?
.total   dd ?

.msg_from  dd ?
.user_from dd ?

.rowID  dd ?

begin
        pushad

        DebugMsg "Started chat long life thread!"

        mov     esi, [.pSpecialParams]
        xor     edi, edi

        cmp     [fChatTerminate], 0
        jne     .finish_socket

        call    ChatPermissions
        jc      .error_no_permissions

        stdcall FCGI_output, [.hSocket], [.requestID], cContentTypeEvent, cContentTypeEvent.length, FALSE
        jc      .finish

        stdcall GetRandomString, 16
        mov     [.unique], eax

        stdcall ValueByName, [esi+TSpecialParams.params], "QUERY_STRING"
        stdcall GetQueryItem, eax, txt "sid=", 0
        mov     [.session], eax
        test    eax, eax
        jz      .finish_socket

        stdcall EnterChat, esi, [.session]
        mov     [.rowID], eax

        xor     eax, eax
        mov     [.msg_from], eax
        mov     [.user_from], eax

.event_loop_msg:

; From here handles the new chat messages.

        and     [.cnt], 0       ; the count of the fetched messages.
        and     [.total], 0

        mov     eax, [pChatFutex]       ; get the old value of the sync futex.
        mov     eax, [eax]
        mov     [.futex], eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectChat, sqlSelectChat.length, eax, 0
        cmp     eax, SQLITE_OK
        jne     .finish_socket

        cinvoke sqliteBindInt, [.stmt], 1, [.msg_from]

        OutputValue "Fetch messages from: ", [.msg_from], 10, -1

        stdcall StrDel, edi
        stdcall StrDupMem, <txt 'event: message', 13, 10, 'data: { "msgs": [ '>         ; start of the messages data set.
        mov     edi, eax

.fetch_loop_msg:

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish_msg_set

; is there previous record?

        cmp     [.cnt], 0
        je      .comma_ok1

        stdcall StrCat, edi, txt ", "

.comma_ok1:
        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.msg_from], eax

        stdcall StrCat, edi, '{ "id": '
        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt ', "time": '

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt ', "user": "'

        cinvoke sqliteColumnText, [.stmt], 2
        stdcall StrEncodeHTML, eax
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt '", "originalname": "'

        cinvoke sqliteColumnText, [.stmt], 3
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt '", "text": "'
        cinvoke sqliteColumnText, [.stmt], 4
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt '" }'

        inc     [.cnt]
        inc     [.total]
        jmp     .fetch_loop_msg

.finish_msg_set:

        cinvoke sqliteFinalize, [.stmt]

        cmp     [.cnt], 0
        je      .messages_ok

        stdcall StrCat, edi, <txt " ] }", 13, 10, 13, 10>
        stdcall StrPtr, edi
        stdcall FCGI_output, [.hSocket], [.requestID], eax, [eax+string.len], FALSE
        jc      .finish

.messages_ok:

; From here, send the users status changes.

        and     [.cnt], 0       ; the count of the fetched records.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectUsers, sqlSelectUsers.length, eax, 0
        cmp     eax, SQLITE_OK
        jne     .finish_socket

        cinvoke sqliteBindInt, [.stmt], 1, [.user_from]

        stdcall StrDel, edi
        stdcall StrDupMem, <txt 'event: status', 13, 10, 'data: { "users": [ '>         ; start of the messages data set.
        mov     edi, eax

.fetch_loop_user:

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish_user_set

        cinvoke sqliteColumnInt, [.stmt], 5
        mov     [.user_from], eax

; is there previous record?
        cmp     [.cnt], 0
        je      .comma_ok2

        stdcall StrCat, edi, txt ", "

.comma_ok2:

        stdcall StrCat, edi, '{ "session": "'

        cinvoke sqliteColumnText, [.stmt], 1
        test    eax, eax
        jz      @f
        stdcall StrCat, edi, eax
@@:
        stdcall StrCat, edi, txt '", "user": "'

        cinvoke sqliteColumnText, [.stmt], 2
        test    eax, eax
        jz      @f
        stdcall StrEncodeHTML, eax
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
@@:
        stdcall StrCat, edi, txt '", "originalname": "'

        cinvoke sqliteColumnText, [.stmt], 3
        test    eax, eax
        jz      @f
        stdcall StrCat, edi, eax
@@:
        stdcall StrCat, edi, txt '", "status": '
        cinvoke sqliteColumnText, [.stmt], 4
        test    eax, eax
        jz      @f
        stdcall StrCat, edi, eax
@@:
        stdcall StrCat, edi, txt ' }'

        inc     [.cnt]
        inc     [.total]
        jmp     .fetch_loop_user

.finish_user_set:

        cinvoke sqliteFinalize, [.stmt]

        cmp     [.cnt], 0
        je      .users_ok

        stdcall StrCat, edi, <txt " ] }", 13, 10, 13, 10>
        stdcall StrPtr, edi
        stdcall FCGI_output, [.hSocket], [.requestID], eax, [eax+string.len], FALSE
        jc      .finish

.users_ok:

        cmp     [fChatTerminate], 0
        jne     .finish_socket

        cmp     [.total], 0
        jne     .keep_alive_ok

        stdcall FCGI_output, [.hSocket], [.requestID], cKeepAlive, cKeepAlive.length, FALSE
        jc      .finish

.keep_alive_ok:
        stdcall WaitForChatMessages, [.futex]
        jc      .finish_socket
        jmp     .event_loop_msg


.finish_socket:

        stdcall FCGI_output, [.hSocket], [.requestID], 0, 0, TRUE

.finish:
        stdcall ExitChat, esi, [.session], [.rowID]

        stdcall StrDel, edi
        stdcall StrDel, [.unique]
        stdcall StrDel, [.session]

        DebugMsg "Finished chat long life thread!"

        popad
        return

.error_no_permissions:

        DebugMsg "Finished chat long life thread with ERROR 403!"

        stdcall StrNew
        push    eax
        stdcall AppendError, eax, "403 Forbidden", esi

        stdcall StrPtr, eax
        stdcall FCGI_output, [.hSocket], [.requestID], eax, [eax+string.len], TRUE
        stdcall StrDel ; from the stack

        popad
        return
endp




sqlPostChatMessage text "insert into chatlog (time, user, original, message) values (strftime('%s', 'now'), (select username from chatusers where session = ?1), ?2, ?3);"
sqlChatParams      text "select ?1 as username, ?2 as session;"

proc ChatPage, .pSpecial
.stmt dd ?
begin
        pushad

        mov     esi, [.pSpecial]

; the user permissions

        call    ChatPermissions
        jc      .error_no_permissions

        cmp     [esi+TSpecialParams.post_array], 0
        jne     .post_new_message

        stdcall StrCat, [esi+TSpecialParams.page_title], cChatTitle
        stdcall LogUserActivity, esi, uaChatting, 0

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlChatParams, sqlChatParams.length, eax, 0

        stdcall ChatUserName, [.pSpecial]
        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

        stdcall GetRandomString, 32
        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

        cinvoke sqliteStep, [.stmt]

        stdcall StrNew
        mov     edi, eax

        stdcall StrCatTemplate, edi, txt "chat", [.stmt], [.pSpecial]

        cinvoke sqliteFinalize, [.stmt]

        clc
        mov     [esp+4*regEAX], edi
        popad
        return

.error_no_permissions:

        stdcall StrNew
        mov     edi, eax
        stdcall AppendError, edi, "403 Forbidden", esi
        jmp     .finish_replace


.post_new_message:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "sid", 0
        mov     edi, eax
        test    eax, eax
        jz      .error_no_permissions

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "chat_message", 0
        mov     ebx, eax
        test    eax, eax
        jz      .user_status_change

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlPostChatMessage, sqlPostChatMessage.length, eax, 0

        stdcall StrClipSpacesR, ebx
        stdcall StrClipSpacesL, ebx
        stdcall StrLen, ebx
        test    eax, eax
        jz      .finish_query

        stdcall StrEncodeHTML, ebx
        stdcall StrDel, ebx
        mov     ebx, eax

        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

        stdcall ChatUserName, [.pSpecial]
        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

        stdcall StrPtr, edi
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]

.finish_query:

        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDel, edi
        stdcall StrDel, ebx

        stdcall SignalNewMessage

.finish:
        stdcall StrDupMem, <"Content-type: text/plain", 13, 10, 13, 10, "OK">
        mov     edi, eax

.finish_replace:
        stc
        mov     [esp+4*regEAX], edi
        popad
        return


.user_status_change:

        stdcall ChatUserName, esi
        mov     edx, eax

        stdcall GetPostString, [esi+TSpecialParams.post_array], "username", 0
        test    eax, eax
        jz      .maybe_status_change

        stdcall RenameChatUser, edi, eax, edx
        stdcall StrDel, edi
        stdcall StrDel, edx
        jmp     .finish


.maybe_status_change:

        stdcall StrDel, edx

        stdcall GetPostString, [esi+TSpecialParams.post_array], "status", 0
        test    eax, eax
        jz      .status_ok

        push    eax
        stdcall StrToNumEx, eax
        stdcall StrDel ; from the stack

        stdcall SetUserStatus, edi, eax

.status_ok:
        stdcall StrDel, edi
        jmp     .finish


endp




proc ChatUserName, .pSpecial
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




proc ChatDisabled
begin
        push    eax

        stdcall GetParam, "chat_enabled", gpInteger
        jc      .finish

        test    eax, eax
        jnz     .finish

        stc

.finish:
        pop     eax
        return
endp


proc ChatPermissions    ; esi is pointer to TSpecialParams
begin
        stdcall GetParam, "chat_anon", gpInteger
        jc      .check_permissions

        test    eax, eax
        jnz     .permissions_ok

.check_permissions:

        test    [esi+TSpecialParams.userStatus], permChat
        jnz     .permissions_ok

        stc
        return

.permissions_ok:
        clc
        return
endp



sqlEnterChat text "insert or replace into ChatUsers(session, time, username, original, status) values ( ?1, strftime('%s', 'now'), ?3, ?3, 1 );"

proc EnterChat, .pSpecial, .session
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlEnterChat, sqlEnterChat.length, eax, 0

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall ChatUserName, [.pSpecial]
        mov     esi, eax

        stdcall StrPtr, esi
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]
        stdcall StrDel, esi

        cmp     ebx, SQLITE_DONE
        jne     .error

        cinvoke sqliteLastInsertRowID, [hMainDatabase]
        mov     [esp+4*regEAX], eax

        stdcall SignalNewMessage

        clc
        popad
        return

.error:
        stc
        popad
        return
endp




sqlLogoutChat text "insert or replace into ChatUsers(time, session, username, original, status) select time, session, username, original, 0 from ChatUsers where session = ?1 and _ROWID_ = ?2;"

proc ExitChat, .pSpecialParams, .session, .rowid
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlLogoutChat, sqlLogoutChat.length, eax, 0

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteBindInt, [.stmt], 2, [.rowid]
        cinvoke sqliteStep, [.stmt]

        cinvoke sqliteChanges, [hMainDatabase]
        stdcall NumToStr, eax, ntsDec

        cinvoke sqliteFinalize, [.stmt]

        stdcall SignalNewMessage

.finish:
        popad
        return
endp


sqlRenameChatUser text "insert or replace into ChatUsers(time, session, username, original, status) select strftime('%s', 'now'), session, ?2, original, status from ChatUsers where session = ?1;"

proc RenameChatUser, .session, .newname, .original
.stmt dd ?
begin
        pushad

        stdcall StrByteUtf8, [.newname], 20
        stdcall StrTrim, [.newname], eax

        stdcall StrClipSpacesR, [.newname]
        stdcall StrClipSpacesL, [.newname]
        stdcall StrLen, [.newname]
        test    eax, eax
        jnz     .name_ok

        stdcall StrCopy, [.newname], [.original]

.name_ok:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlRenameChatUser, sqlRenameChatUser.length, eax, 0

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.newname]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        cinvoke sqliteChanges, [hMainDatabase]
        test    eax, eax
        jz      .finish

        stdcall SignalNewMessage

.finish:
        popad
        return
endp



sqlSetUserStatus text "insert or replace into ChatUsers(time, session, username, original, status) select strftime('%s', 'now'), session, username, original, ?2 from ChatUsers where session = ?1;"

proc SetUserStatus, .session, .status
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSetUserStatus, sqlSetUserStatus.length, eax, 0

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteBindInt, [.stmt], 2, [.status]
        cinvoke sqliteStep, [.stmt]

        cinvoke sqliteFinalize, [.stmt]

        stdcall SignalNewMessage

        popad
        return
endp
