; select not processed messages but not older than 1h.
sqlSelectChat text "select id, time, user, message from ChatLog where id > ?1 and time >  strftime('%s', 'now') - 3600;"

cContentTypeEvent text 'Content-Type: text/event-stream', 13, 10, 13, 10  ;"X-Accel-Buffering: no", 13, 10, "Transfer-Encoding: chunked", 13, 10, 13, 10
cKeepAlive        text ': AsmBB', 13, 10, 13, 10


proc ChatRealTime, .hSocket, .requestID, .pSpecialParams
.stmt dd ?
.current dd ?
begin
        pushad

        mov     esi, [.pSpecialParams]

;        stdcall FileWriteString, [STDERR], "Chat thread started. Socket="
;        stdcall NumToStr, [.hSocket], ntsHex or ntsFixedWidth  or ntsUnsigned + 8
;        push    eax
;        stdcall FileWriteString, [STDERR], eax
;        stdcall StrDel ; from the stack.
;        stdcall FileWriteString, [STDERR], cNewLine

        stdcall StrDupMem, 'The user <b class=\"chatuser\">'
        mov     edi, eax
        stdcall ChatUserName, esi
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, "</b> entered chat. Connection #"
        stdcall NumToStr, [.hSocket], ntsDec or ntsUnsigned
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        stdcall LogToChat, edi
        stdcall StrDel, edi

        stdcall FCGI_output, [.hSocket], [.requestID], cContentTypeEvent, cContentTypeEvent.length, FALSE
        jc      .finish_events

        xor     ebx, ebx
        mov     [.current], ebx

.event_loop:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectChat, sqlSelectChat.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, ebx

.fetch_loop:
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
        stdcall StrCat, edi, txt '", "text": "'
        stdcall StrDel, eax

        cinvoke sqliteColumnText, [.stmt], 3
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, <txt '" }', 13, 10, 13, 10>

        stdcall StrPtr, edi
        stdcall FCGI_output, [.hSocket], [.requestID], eax, [eax+string.len], FALSE
        stdcall StrDel, edi
        jc      .finish_events

        cinvoke sqliteColumnInt, [.stmt], 0
        cmp     ebx, eax
        cmovb   ebx, eax
        jmp     .fetch_loop

.reset_and_pause:

        cmp     ebx, [.current]
        jne     .keep_ok

        stdcall FCGI_output, [.hSocket], [.requestID], cKeepAlive, cKeepAlive.length, FALSE
        jc      .finish_events

.keep_ok:
        mov     [.current], ebx
        cinvoke sqliteFinalize, [.stmt]
        stdcall Sleep, 100
        jmp     .event_loop

.finish_events:

        cinvoke sqliteFinalize, [.stmt]
        stdcall FCGI_output, [.hSocket], [.requestID], 0, 0, TRUE

        stdcall StrDupMem, 'The user <b class=\"chatuser\">'
        mov     edi, eax
        stdcall ChatUserName, esi
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, "</b> leaved chat. Connection #"
        stdcall NumToStr, [.hSocket], ntsDec or ntsUnsigned
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        stdcall LogToChat, edi
        stdcall StrDel, edi

;        stdcall FileWriteString, [STDERR], "Chat thread ended. Socket="
;        stdcall NumToStr, [.hSocket], ntsHex or ntsFixedWidth  or ntsUnsigned + 8
;        push    eax
;        stdcall FileWriteString, [STDERR], eax
;        stdcall StrDel ; from the stack.
;        stdcall FileWriteString, [STDERR], cNewLine

        popad
        return
endp




sqlPostChatMessage text "insert into chatlog (time, user, message) values (strftime('%s', 'now'), ?1, ?2);"

proc ChatPage, .pSpecial
.stmt dd ?
begin
        pushad

        stdcall StrNew
        mov     edi, eax

        mov     esi, [.pSpecial]
        cmp     [esi+TSpecialParams.post_array], 0
        jne     .post_new_message

        stdcall LogUserActivity, esi, uaChatting, 0

        stdcall StrCatTemplate, edi, txt "chat", 0, [.pSpecial]

        clc
        mov     [esp+4*regEAX], edi
        popad
        return

.post_new_message:

        stdcall GetPostString, [esi+TSpecialParams.post_array], "chat_message", 0
        test    eax, eax
        jz      .finish_post

        mov     ebx, eax

; debug only!!!
;        stdcall FileWriteString, [STDERR], ebx
;        stdcall FileWriteString, [STDERR], cNewLine

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlPostChatMessage, sqlPostChatMessage.length, eax, 0

        stdcall StrEncodeHTML, ebx
        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

        stdcall ChatUserName, esi
        mov     ebx, eax

        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDel, ebx

.finish_post:
        stdcall StrCat, edi, <"Content-type: text/plain", 13, 10, 13, 10, "OK">
        stc
        mov     [esp+4*regEAX], edi
        popad
        return

endp


cAnonymous         text "Anon"

proc ChatUserName, .pSpecial
begin
        pushad
        mov     esi, [.pSpecial]

        mov     edx, [esi+TSpecialParams.userName]
        test    edx, edx
        jnz     .real_name

        stdcall StrDupMem, cAnonymous
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


;sqlPostChatMessage text "insert into chatlog (time, user, message) values (strftime('%s', 'now'), ?1, ?2);"

proc LogToChat, .hTxt
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlPostChatMessage, sqlPostChatMessage.length, eax, 0

        cinvoke sqliteBindText, [.stmt], 1, txt "AsmBB", 5, SQLITE_STATIC

        stdcall StrPtr, [.hTxt]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

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