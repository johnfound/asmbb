; select not processed messages but not older than 1h.
sqlSelectChat text "select * from ChatLog order by id where id > ?1 and time >  strftime('%s', 'now') - 3600 ;"

cContentTypeEvent text 'Content-Type: text/event-stream;', 13, 10, "Transfer-Encoding: chunked;", 13, 10, "Cache-Control: no-cache;" ,13, 10, 13, 10
cChatTest         text 'data: This is a chat test.', 13, 10, 13, 10


proc ChatRealTime, .hSocket, .requestID, .pSpecialParams
.stmt dd ?
begin
        pushad

;        lea     eax, [.stmt]
;        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectChat, sqlSelectChat.length, eax, 0

        stdcall FileWriteString, [STDERR], "Chat thread started. Socket="
        stdcall NumToStr, [.hSocket], ntsHex or ntsFixedWidth  or ntsUnsigned + 8
        push    eax
        stdcall FileWriteString, [STDERR], eax
        stdcall StrDel ; from the stack.
        stdcall FileWriteString, [STDERR], cNewLine

        stdcall FCGI_output, [.hSocket], [.requestID], cContentTypeEvent, cContentTypeEvent.length, FALSE
        jc      .finish_events

        xor     ebx, ebx  ; the latest sent message ID

.event_loop:

        stdcall FCGI_output, [.hSocket], [.requestID], cChatTest, cChatTest.length, FALSE
        jc      .finish_events

        stdcall Sleep, 1000
        jmp     .event_loop

.finish_events:

        stdcall FCGI_output, [.hSocket], [.requestID], 0, 0, TRUE
;        cinvoke sqliteFinalize, [.stmt]

        stdcall FileWriteString, [STDERR], "Chat thread ended. Socket="
        stdcall NumToStr, [.hSocket], ntsHex or ntsFixedWidth  or ntsUnsigned + 8
        push    eax
        stdcall FileWriteString, [STDERR], eax
        stdcall StrDel ; from the stack.
        stdcall FileWriteString, [STDERR], cNewLine

        popad
        return
endp





proc ChatPage, .pSpecial
begin
        stdcall StrNew
        stdcall StrCatTemplate, eax, txt "chat", 0, [.pSpecial]
        return
endp