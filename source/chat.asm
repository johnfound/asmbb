; select not processed messages but not older than 1h.
sqlSelectChat text "select id, time, user, original, status, message from ChatLog where id > ?1 and time >  strftime('%s', 'now') - 3600;"

cContentTypeEvent text 'Content-Type: text/event-stream', 13, 10, 13, 10  ;"X-Accel-Buffering: no", 13, 10, "Transfer-Encoding: chunked", 13, 10, 13, 10
cKeepAlive        text ': AsmBB', 13, 10, 13, 10


proc ChatRealTime, .hSocket, .requestID, .pSpecialParams
.stmt    dd ?
.current dd ?
.futex   dd ?
begin
        pushad

        DebugMsg "Started chat long life thread!"

        mov     esi, [.pSpecialParams]

        cmp     [fChatTerminate], 0
        jne     .finish_socket

        call    ChatPermissions
        jc      .error_no_permissions

        stdcall FCGI_output, [.hSocket], [.requestID], cContentTypeEvent, cContentTypeEvent.length, FALSE
        jc      .finish

        xor     ebx, ebx
        mov     [.current], ebx
        jmp     .event_loop

.main_loop:

        cinvoke sqliteFinalize, [.stmt]

.event_loop:

        mov     eax, [pChatFutex]       ; get the old value of the sync futex.
        mov     eax, [eax]
        mov     [.futex], eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectChat, sqlSelectChat.length, eax, 0
        cmp     eax, SQLITE_OK
        jne     .finish_socket

        cinvoke sqliteBindInt, [.stmt], 1, ebx

.fetch_loop:
        cmp     [fChatTerminate], 0
        jne     .finish_all

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .reset_and_pause

        stdcall StrDupMem, txt 'data: { "id":'
        mov     edi, eax

        cinvoke sqliteColumnText, [.stmt], 0
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt ', "time": '

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt ', "user": "'

        cinvoke sqliteColumnText, [.stmt], 2
        stdcall StrEncodeHTML, eax

        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt '", '
        stdcall StrDel, eax

        stdcall StrCat, edi, txt '"originalname": "'
        cinvoke sqliteColumnText, [.stmt], 3
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt '", '

        cinvoke sqliteColumnType, [.stmt], 5
        cmp     eax, SQLITE_NULL
        jne     .message_event

        stdcall StrInsert, edi, <txt 'event: status', 13, 10>, 0

        stdcall StrCat, edi, txt '"status": "'
        cinvoke sqliteColumnText, [.stmt], 4
        jmp     .json_end

.message_event:
        stdcall StrInsert, edi, <txt 'event: message', 13, 10>, 0
        stdcall StrCat, edi, txt '"text": "'
        cinvoke sqliteColumnText, [.stmt], 5

.json_end:
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, <txt '" }', 13, 10, 13, 10>

        stdcall StrPtr, edi
        stdcall FCGI_output, [.hSocket], [.requestID], eax, [eax+string.len], FALSE
        stdcall StrDel, edi
        jc      .finish_socket_error

        cinvoke sqliteColumnInt, [.stmt], 0
        cmp     ebx, eax
        cmovb   ebx, eax
        jmp     .fetch_loop

.reset_and_pause:

        cmp     ebx, [.current]
        jne     .keep_ok

        stdcall FCGI_output, [.hSocket], [.requestID], cKeepAlive, cKeepAlive.length, FALSE
        jc      .finish_socket_error

.keep_ok:
        mov     [.current], ebx

        cmp     [fChatTerminate], 0
        jne     .finish_all

        stdcall WaitForChatMessages, [.futex]
        jc      .finish_all
        jmp     .main_loop

.finish_socket:

        stdcall FCGI_output, [.hSocket], [.requestID], 0, 0, TRUE
        jmp     .finish

.finish_all:

        stdcall FCGI_output, [.hSocket], [.requestID], 0, 0, TRUE

.finish_socket_error:

        cinvoke sqliteFinalize, [.stmt]

.finish:

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




sqlPostChatMessage text "insert into chatlog (time, user, original, status, message) values (strftime('%s', 'now'), ?1, ?2, ?3, ?4);"
sqlChatParams      text "select ?1 as username;"

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
        stdcall StrPtr ; from the stack
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

        stdcall GetPostString, [esi+TSpecialParams.post_array], "chat_message", 0
        mov     ebx, eax

        stdcall GetPostString, [esi+TSpecialParams.post_array], "username", 0
        test    eax, eax
        jnz     .user_ok

        stdcall ChatUserName, [.pSpecial]

.user_ok:
        mov     edi, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlPostChatMessage, sqlPostChatMessage.length, eax, 0

        test    ebx, ebx
        jz      .status_msg

        stdcall StrClipSpacesR, ebx
        stdcall StrClipSpacesL, ebx
        stdcall StrLen, ebx
        test    eax, eax
        jz      .finish_query

        stdcall StrEncodeHTML, ebx
        stdcall StrDel, ebx
        mov     ebx, eax

        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC
        jmp     .bind_username

.status_msg:

        stdcall GetPostString, [esi+TSpecialParams.post_array], "status", 0
        push    eax
        stdcall StrToNumEx, eax
        stdcall StrDel ; from the stack
        cinvoke sqliteBindInt, [.stmt], 3, eax

.bind_username:

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

        stdcall StrDel, ebx
        stdcall StrDel, edi

        stdcall SignalNewMessage

.finish_post:

        stdcall StrDupMem, <"Content-type: text/plain", 13, 10, 13, 10, "OK">
        mov     edi, eax

.finish_replace:
        stc
        mov     [esp+4*regEAX], edi
        popad
        return

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



;proc LogToChat, .hTxt
;.stmt dd ?
;begin
;        pushad
;
;        lea     eax, [.stmt]
;        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlPostChatMessage, sqlPostChatMessage.length, eax, 0
;
;        cinvoke sqliteBindText, [.stmt], 1, txt "AsmBB", 5, SQLITE_STATIC
;
;        stdcall StrPtr, [.hTxt]
;        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC
;
;        cinvoke sqliteStep, [.stmt]
;        cinvoke sqliteFinalize, [.stmt]
;
;        stdcall SignalNewMessage
;
;        popad
;        return
;endp



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