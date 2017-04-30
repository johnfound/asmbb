; select not processed messages but not older than 1h.
sqlSelectChat text "select id, time(time, 'unixepoch') as time, user, message from ChatLog where id > ?1 and time >  strftime('%s', 'now') - 3600;"

cContentTypeEvent text 'Content-Type: text/event-stream', 13, 10, "X-Accel-Buffering: no", 13, 10, "Transfer-Encoding: chunked", 13, 10, 13, 10
cKeepAlive        text ': AsmBB', 13, 10, 13, 10


proc ChatRealTime, .hSocket, .requestID, .pSpecialParams
.stmt dd ?
begin
        pushad

;        stdcall FileWriteString, [STDERR], "Chat thread started. Socket="
;        stdcall NumToStr, [.hSocket], ntsHex or ntsFixedWidth  or ntsUnsigned + 8
;        push    eax
;        stdcall FileWriteString, [STDERR], eax
;        stdcall StrDel ; from the stack.
;        stdcall FileWriteString, [STDERR], cNewLine

        stdcall FCGI_output, [.hSocket], [.requestID], cContentTypeEvent, cContentTypeEvent.length, FALSE
        jc      .finish_events

        xor     ebx, ebx  ; the latest sent message ID

.event_loop:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectChat, sqlSelectChat.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, ebx

.fetch_loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .reset_and_pause

        stdcall StrDupMem, txt "data: <p><span>("
        mov     edi, eax

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt ")</span> "

        cinvoke sqliteColumnText, [.stmt], 2
        stdcall StrEncodeHTML, eax

        stdcall StrCat, edi, txt " <b>"
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt "</b>: "
        stdcall StrDel, eax

        cinvoke sqliteColumnText, [.stmt], 3
        stdcall StrEncodeHTML, eax

        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        stdcall StrCat, edi, <txt "</p>", 13, 10, 13, 10>

        stdcall StrPtr, edi
        stdcall FCGI_output, [.hSocket], [.requestID], eax, [eax+string.len], FALSE
        jc      .finish_events

        cinvoke sqliteColumnInt, [.stmt], 0
        cmp     ebx, eax
        cmovb   ebx, eax
        jmp     .fetch_loop

.reset_and_pause:

        test    ebx, ebx
        jnz     .keep_ok

        stdcall FCGI_output, [.hSocket], [.requestID], cKeepAlive, cKeepAlive.length, FALSE
        jc      .finish_events

.keep_ok:
        cinvoke sqliteFinalize, [.stmt]
        stdcall Sleep, 100
        jmp     .event_loop

.finish_events:

        cinvoke sqliteFinalize, [.stmt]
        stdcall FCGI_output, [.hSocket], [.requestID], 0, 0, TRUE

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
cAnonymous         text "Anon"

proc ChatPage, .pSpecial
.stmt dd ?
begin
        pushad

        stdcall StrNew
        mov     edi, eax

        mov     esi, [.pSpecial]
        cmp     [esi+TSpecialParams.post_array], 0
        jne     .post_new_message

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

        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        xor     ecx, ecx
        mov     edx, [esi+TSpecialParams.userName]
        test    edx, edx
        jnz     @f

        mov     edx, cAnonymous
        mov     eax, [esi+TSpecialParams.remoteIP]
        mov     cl, al
        xor     cl, ah
        shr     eax, 16
        xor     cl, al
        xor     cl, ah

@@:
        stdcall StrDup, edx
        mov     ebx, eax
        jecxz   @f

        stdcall NumToStr, ecx, ntsHex or ntsUnsigned or ntsFixedWidth + 2
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
@@:
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