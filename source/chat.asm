CHAT_MAX_USER_NAME = 20
CHAT_MAX_MESSAGE = 1000
CHAT_BACKLOG_DEFAULT = 100

sqlSelectChat           text "select id, time, user, original, message from chatlog where id in (select id from chatlog where id > ?1 order by id desc limit ?2)"
sqlSelectUsers          text "select time, session, username, original, status, force from ChatUsers where status<>0 order by original;"

sqlUpdateChatSession    text "update ChatUsers set time = strftime('%s', 'now'), force = NULL where session = ?1;"
sqlDeleteClosedSessions text "update ChatUsers set status = 0 where time < strftime('%s', 'now') - 10; delete from ChatUsers where time < strftime('%s', 'now') - 86400;"           ; 10 seconds timeout of the chat session.

cContentTypeEvent text 'Content-Type: text/event-stream', 13, 10, "X-Accel-Buffering: no", 13, 10, 13, 10, "retry: 1000", 13, 10, 13, 10  ;"X-Accel-Buffering: no", 13, 10, "Transfer-Encoding: chunked", 13, 10, 13, 10
cKeepAlive        text ': ', 13, 10, 13, 10

cTrue   text "true"
cFalse  text "false"

proc ChatRealTime, .pSpecialParams
.stmt    dd ?
.session dd ?
.cnt     dd ?
.total   dd ?

.msg_from   dd ?
.prev_users dd ?
.chat_backlog_len dd ?

begin
        pushad

        DebugMsg "Started chat events connection!"

        mov     esi, [.pSpecialParams]
        xor     edi, edi
        mov     [.prev_users], edi

        stdcall ChatPermissions, esi
        jc      .error_no_permissions

        stdcall GetCookieValue, [esi+TSpecialParams.params], "chatsid"
        jnc     .session_ok

        stdcall GetRandomString, 32

.session_ok:
        mov     [.session], eax

; set cookie.

        stdcall StrNew
        stdcall StrCat, eax, "Set-Cookie: chatsid="
        stdcall StrCat, eax, [.session]
        stdcall StrCat, eax, <"; Path=/", 13, 10>

        push    eax
        stdcall StrPtr, eax
        stdcall FCGI_output, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], eax, [eax+string.len], FALSE
        stdcall StrDel ; from the stack

        stdcall FCGI_output, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], cContentTypeEvent, cContentTypeEvent.length, FALSE
        jc      .finish

        stdcall EnterChat, esi, [.session]

        mov     eax, CHAT_BACKLOG_DEFAULT
        stdcall GetParam, 'chat_backlog_length', gpInteger
        mov     [.chat_backlog_len], eax

        and     [.msg_from], 0

        stdcall ValueByName, [esi+TSpecialParams.params], "Last-Event-ID"
        jc      .event_loop_msg

        stdcall StrToNumEx, eax
        mov     [.msg_from], eax

        OutputValue "Read messages from ID: ", eax, 10, -1

.event_loop_msg:

; From here handles the new chat messages.

        and     [.cnt], 0       ; the count of the fetched messages.
        and     [.total], 0

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectChat, sqlSelectChat.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.msg_from]
        cinvoke sqliteBindInt, [.stmt], 2, [.chat_backlog_len]

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

        inc     [.cnt]
        inc     [.total]
        jmp     .fetch_loop_msg

.finish_msg_set:

        cinvoke sqliteFinalize, [.stmt]

        cmp     [.cnt], 0
        je      .messages_ok

        stdcall StrCat, edi, <txt " ] }", 13, 10>
        stdcall StrCat, edi, txt "id: "
        stdcall NumToStr, [.msg_from], ntsDec or ntsUnsigned
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, <txt 13, 10, 13, 10>
        stdcall StrPtr, edi
        stdcall FCGI_output, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], eax, [eax+string.len], FALSE
        jc      .finish

.messages_ok:

        cinvoke sqliteExec, [hMainDatabase], sqlDeleteClosedSessions, 0, 0, 0
;        cinvoke sqliteChanges, [hMainDatabase]

; From here, send the users list.

        and     [.cnt], 0

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectUsers, sqlSelectUsers.length, eax, 0

        stdcall StrDel, edi
        stdcall StrDupMem, <txt 'event: users_online', 13, 10, 'data: { "users": [ '>         ; start of the messages data set.
        mov     edi, eax

.fetch_loop_user:

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish_user_set

        cinvoke sqliteColumnInt, [.stmt], 5

; is there previous record?
        cmp     [.cnt], 0
        je      .comma_ok2

        stdcall StrCat, edi, txt ", "

.comma_ok2:

        stdcall StrCat, edi, '{ "flagSelf": '

        cinvoke sqliteColumnText, [.stmt], 1
        mov     ecx, cTrue
        stdcall StrCompCase, eax, [.session]
        jc      @f
        mov     ecx, cFalse
@@:
        stdcall StrCat, edi, ecx
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
        test    eax, eax
        jz      @f
        stdcall StrCat, edi, eax
@@:
        stdcall StrCat, edi, txt '", "status": '
        cinvoke sqliteColumnText, [.stmt], 4
        stdcall StrCat, edi, eax

        stdcall StrCat, edi, txt ' }'

        cinvoke sqliteColumnInt, [.stmt], 5
        test    eax, eax
        jz      .force_ok

; force sending the users!
        xor     eax, eax
        xchg    eax, [.prev_users]
        stdcall StrDel, eax

.force_ok:

        inc     [.cnt]
        jmp     .fetch_loop_user

.finish_user_set:

        cinvoke sqliteFinalize, [.stmt]

        stdcall StrCat, edi, <txt " ] }", 13, 10, 13, 10>

        stdcall StrCompCase, edi, [.prev_users]
        stdcall StrDel, [.prev_users]
        mov     [.prev_users], edi
        mov     edi, 0
        jc      .users_ok

        stdcall StrPtr, [.prev_users]
        stdcall FCGI_output, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], eax, [eax+string.len], FALSE
        jc      .finish

.users_ok:

; Update the time and force fields of the current user.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateChatSession, sqlUpdateChatSession.length, eax, 0
        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        mov     [esi+TSpecialParams.needEventsLo], evmMessage or evmUser
        and     [esi+TSpecialParams.needEventsHi], 0
        or      [esi+TSpecialParams.fDontFree], -1

.finish:

        stdcall StrDel, edi
        stdcall StrDel, [.prev_users]
        stdcall StrDel, [.session]

.exit:
        popad
        xor     eax, eax
        stc                      ; all communications here are finished.
        return


.error_no_permissions:

        DebugMsg "Finished chat long life thread with ERROR 403!"

        stdcall TextCreate, sizeof.TText
        stdcall AppendError, eax, "403 Forbidden", esi
        stdcall FCGI_outputText, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], edx, TRUE
        stdcall TextFree, edx
        jmp     .exit

endp




sqlPostChatMessage text "insert into chatlog (time, user, original, message) values (?1, ?2, ?3, ?4);"
sqlGetChatUser     text "select username from chatusers where session = ?1;"

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
        stdcall GetCookieValue, [esi+TSpecialParams.params], "chatsid"
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

        stdcall ChatUserName, [.pSpecial]
        mov     [.original], eax


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlPostChatMessage, sqlPostChatMessage.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.time]

        stdcall StrPtr, [.user]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.original]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.text]
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteLastInsertRowID, [hMainDatabase]
        mov     [.id], eax

.finish_query:

        cinvoke sqliteFinalize, [.stmt]
        stdcall FormatJsonMessage, [.id], [.time], [.user], [.original], [.text]
        stdcall AddEvent, evmMessage, 0, eax
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
        stdcall ChatUserName, esi
        stdcall RenameChatUser, edi, edx, eax

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

        stdcall SetUserStatus, edi, eax
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



sqlEnterChat         text "insert into ChatUsers(session, time, username, original, status) values ( ?1, strftime('%s', 'now'), ?2, ?2, 1 );"
sqlActivateSession   text "update ChatUsers set time=strftime('%s', 'now'), original=?2, status=1, username = (case when username <> original then username else ?2 end) where session=?1;"

proc EnterChat, .pSpecial, .session
.stmt dd ?
begin
        pushad

        stdcall ChatUserName, [.pSpecial]
        mov     esi, eax

        mov     edx, sqlEnterChat
        call    .ExecSQL

        cmp     ebx, SQLITE_DONE
        je      .notify

        mov     edx, sqlActivateSession
        call    .ExecSQL

        cmp     ebx, SQLITE_DONE
        je      .notify

        stc
        jmp     .finish

.notify:
        stdcall SignalNewEvent
        clc

.finish:
        stdcall StrDel, esi
        popad
        return

.error:
        stc
        popad
        return

.ExecSQL:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], edx, -1, eax, 0

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, esi
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]
        retn

endp



sqlRenameChatUser text "update ChatUsers set username=?2, original=?3, time=strftime('%s', 'now'), force=1 where session=?1;"

proc RenameChatUser, .session, .newname, .original
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
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlRenameChatUser, sqlRenameChatUser.length, eax, 0

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

        stdcall SignalNewEvent

.finish:
        popad
        return
endp



sqlSetUserStatus text "update ChatUsers set status = ?2, time = strftime('%s', 'now') where session = ?1;"

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

        cinvoke sqliteChanges, [hMainDatabase]
        test    eax, eax
        jz      .finish

        stdcall SignalNewEvent

.finish:
        popad
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
