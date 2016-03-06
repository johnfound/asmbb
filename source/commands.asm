

sqlSelectThreads text "select *, (select count() from posts where threadid = Threads.id) as PostCount from Threads limit 20 offset ?"


proc ListThreads

.stmt  dd ?
.stmt2 dd ?

.start dd ?

.threadID      dd ?
.threadCaption dd ?
.threadStart   dd ?

begin
        stdcall GetQueryItem, [hQuery], txt "start=", 0
        test    eax, eax
        jz      .default

        push    eax
        stdcall StrToNum, eax
        stdcall StrDel ; from the stack

.default:
        mov     [.start], eax

        stdcall StrNew
        mov     edi, eax

        stdcall StrCat, edi, '<div class="threadlist">'

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectThreads, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.start]

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.threadID], eax

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrDupMem, eax
        mov     [.threadCaption], eax

        cinvoke sqliteColumnInt, [.stmt], 2
        mov     [.threadStart], eax

        stdcall StrCat, edi, '<div class="thread_summary">'

; thread posts count

        stdcall StrCat, edi, '<div class="post_count">'

        cinvoke sqliteColumnInt, [.stmt], 3

        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        stdcall StrCat, edi, '</div>'

; link to the thread

        stdcall StrCat, edi, '<a class="thread_link" href="index.cgi?cmd=1&amp;threadid='

        stdcall NumToStr, [.threadID], ntsDec or ntsUnsigned
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        stdcall StrCharCat, edi, '">'
        stdcall StrCat, edi, [.threadCaption]
        stdcall StrCat, edi, txt '</a>'

        stdcall StrCat, edi, "</div>"   ; thread_summary.

        jmp     .loop


.finish:
        stdcall StrCat, edi, "</div>"   ; threadlist

        cinvoke sqliteFinalize, [.stmt]

; now output the whole file!

        stdcall FileWriteString, [STDOUT], <"Status: 200 OK", 13, 10>
        stdcall FileWriteString, [STDOUT], <"Content-type: text/html", 13, 10, 13, 10>


        stdcall FileWrite, [STDOUT], htmlHeader, htmlHeader.length
        stdcall FileWriteString, [STDOUT], edi

        stdcall WriteTimestamp

        stdcall FileWrite, [STDOUT], htmlFooter, htmlFooter.length

        stdcall StrDel, edi
        stdcall StrDel, [.threadCaption]

        return
endp



htmlHeader  text '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Thread list</title><link rel="stylesheet" href="/all.css"></head><body><h1>This is simply experiment. Better go to <a href="http://asm32.info">my home page</a></h1>'
htmlFooter  text '</body></html>'






sqlSelectPosts text "select * from Posts where threadID = ? limit 20 offset ?"



proc ShowThread
.start dd ?
.stmt  dd ?
.threadID dd ?

begin
        stdcall GetQueryItem, [hQuery], txt "threadid=", 0
        test    eax, eax
        jz      .err400

        push    eax
        stdcall StrToNum, eax
        stdcall StrDel ; from the stack

        mov     [.threadID], eax

        OutputValue "Thread ID:", eax, 10, -1


        stdcall GetQueryItem, [hQuery], txt "start=", 0
        test    eax, eax
        jz      .start_ok

        push    eax
        stdcall StrToNum, eax
        stdcall StrDel ; from the stack

.start_ok:
        mov     [.start], eax

        stdcall StrNew
        mov     edi, eax

        stdcall StrCat, edi, '<div class="thread">'

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectPosts, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 2, [.start]

.loop:
        cinvoke sqliteStep, [.stmt]

        OutputValue "sql step result:", eax, 10, -1

        cmp     eax, SQLITE_ROW
        jne     .finish

        stdcall StrCat, edi, '<div class="post">'

        cinvoke sqliteColumnInt, [.stmt], 2             ; userID

        stdcall RenderUserInfo, edi, eax

        cinvoke sqliteColumnInt, [.stmt], 3             ; post time

        stdcall RenderPostTime, edi, eax

        cinvoke sqliteColumnText, [.stmt], 4            ; Content

        stdcall RenderPostContent, edi, eax

        stdcall StrCat, edi, "</div>"            ; div.post

        jmp     .loop


.finish:
        stdcall StrCat, edi, "</div>"   ; dic.thread

        cinvoke sqliteFinalize, [.stmt]

; now output the whole html!

        stdcall FileWriteString, [STDOUT], <"Status: 200 OK", 13, 10>
        stdcall FileWriteString, [STDOUT], <"Content-type: text/html", 13, 10, 13, 10>


        stdcall FileWrite, [STDOUT], htmlHeader, htmlHeader.length
        stdcall FileWriteString, [STDOUT], edi

        stdcall WriteTimestamp

        stdcall FileWrite, [STDOUT], htmlFooter, htmlFooter.length

        return


.err400:
        stdcall ReturnError, "400 Bad Request"
        return
endp









proc SavePost
begin

        stdcall FileWriteString, [STDOUT], <"Status: 200 OK", 13, 10>
        stdcall FileWriteString, [STDOUT], <"Content-type: text/plain", 13, 10, 13, 10>

        stdcall FileWriteString, [STDOUT], "Not implemented!"

        return
endp







proc WriteTimestamp
begin

        stdcall FileWriteString, [STDOUT], '<p class="timestamp">Script runtime: '

        stdcall GetTimestamp
        sub     eax, [StartTime]
        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        push    eax
        stdcall FileWriteString, [STDOUT], eax
        stdcall StrDel ; from the stack

        stdcall FileWriteString, [STDOUT], txt 'ms</p>'

        return
endp