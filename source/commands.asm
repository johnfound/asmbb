proc ServeOneRequest, .hSocket, .requestID, .pParams, .pPost

.root dd ?
.uri  dd ?

begin
        pushad

        mov     [.root], 0
        mov     [.uri], 0


        stdcall StrNew
        mov     edi, eax

        DebugMsg "Get document root."

        stdcall ValueByName, [.pParams], "DOCUMENT_ROOT"
        jc      .error400

        stdcall StrDup, eax
        mov     [.root], eax

        stdcall StrPtr, [.root]
        mov     ebx, eax
        mov     eax, [ebx+string.len]

        test    eax, eax
        jz      .root_ok

        dec     eax
        cmp     byte [ebx+eax], "/"
        jne     .root_ok

        mov     byte [ebx+eax], 0
        mov     [ebx+string.len], eax

.root_ok:
        DebugMsg "Get request URI."

        stdcall ValueByName, [.pParams], "REQUEST_URI"
        jc      .error400

        stdcall StrDup, eax
        mov     [.uri], eax

; first check for supported file format.

        DebugMsg "Get request URI."

        stdcall StrDup, [.root]
        stdcall StrCat, eax, [.uri]
        mov     esi, eax

if defined options.DebugMode & options.DebugMode

        stdcall Output, "Filename to be check:"

        stdcall StrPtr, esi
        stdcall Output, eax
        DebugMsg

end if

        stdcall FileExists, esi
        jnc     .serve_real_file


        DebugMsg "File not exists. So, send 404 not found."

        stdcall AppendError, edi, "Status: 404 Not Found"


.send_simple_result:

        DebugMsg "Send simple string result!"

        stdcall StrPtr, edi
        stdcall FCGI_output, [.hSocket], [.requestID], eax, [eax+string.len], TRUE
        stdcall StrDel, edi


.final_clean:

        xor     eax, eax
        cmp     [.root], eax
        je      @f

        stdcall StrDel, [.root]

@@:
        cmp     [.uri], eax
        je      @f

        stdcall StrDel, [.uri]
@@:
        clc
        popad
        return




.serve_real_file:

        DebugMsg "File exists. So, serve it maybe."

        stdcall GetMimeType, esi
        jc      .error403

        stdcall StrCat, edi, <"Status: 200 OK", 13, 10, "Content-type: ">
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCharCat, edi, $0a0d0a0d

        stdcall StrPtr, edi
        stdcall FCGI_output, [.hSocket], [.requestID], eax, [eax+string.len], FALSE
        stdcall StrDel, edi

        stdcall LoadBinaryFile, esi
        stdcall FCGI_output, [.hSocket], [.requestID], eax, ecx, TRUE
        stdcall FreeMem, eax

        clc
        popad
        return


.error403:
        stdcall AppendError, edi, "Status: 403 Forbidden"
        jmp     .send_simple_result


.error400:
        stdcall AppendError, edi, "Status: 400 Bad Request"
        jmp     .send_simple_result


endp





proc GetMimeType, .filename
begin
        pushad

        stdcall StrExtractExt, [.filename]
        jc      .error                         ; no extension. Such files are not to be served!

        mov     esi, eax

        mov     ebx, mimeIcon
        stdcall StrCompNoCase, esi, txt ".ico"
        jc      .mime_ok

        mov     ebx, mimeHTML
        stdcall StrCompNoCase, esi, txt ".html"
        jc      .mime_ok

        stdcall StrCompNoCase, esi, txt ".html"
        jc      .mime_ok

        mov     ebx, mimeCSS
        stdcall StrCompNoCase, esi, txt ".css"
        jc      .mime_ok

        mov     ebx, mimePNG
        stdcall StrCompNoCase, esi, txt ".png"
        jc      .mime_ok

        mov     ebx, mimeJPEG
        stdcall StrCompNoCase, esi, txt ".jpg"
        jc      .mime_ok

        stdcall StrCompNoCase, esi, txt ".jpeg"
        jc      .mime_ok

        mov     ebx, mimeSVG
        stdcall StrCompNoCase, esi, txt ".svg"
        jc      .mime_ok

        mov     ebx, mimeGIF
        stdcall StrCompNoCase, esi, txt ".gif"
        jc      .mime_ok

        jmp     .error

.mime_ok:
        stdcall StrDupMem, "Content-type: "
        stdcall StrCat, eax, ebx
        mov     [esp+4*regEAX], eax
        clc

.finish:
        stdcall StrDel, esi
        popad
        return

.error:
        stc
        jmp     .finish
endp


mimeIcon  text "image/x-icon"
mimeHTML  text "text/html"
mimeText  text "text/plain"
mimeCSS   text "text/css"
mimePNG   text "image/png"
mimeJPEG  text "image/jpeg"
mimeSVG   text "image/svg+xml"
mimeGIF   text "image/gif"






;        mov     ebx, [Command]
;        cmp     ebx, cmdMax
;        ja      .err400
;
;; command in range, so open the database.
;
;        stdcall StrDup, [hDocRoot]
;        push    eax
;        stdcall StrCat, eax, cDatabaseFilename
;        stdcall StrPtr, eax
;
;        stdcall OpenOrCreate, eax, hMainDatabase, sqlCreateDB
;        stdcall StrDel ; from the stack
;        jc      .err400
;
;; execute the command
;
;        stdcall [procCommands+4*ebx]
;
;; close the database
;
;        cinvoke sqliteClose, [hMainDatabase]

;procCommands dd ListThreads, ShowThread, SavePost




;
; This procedure is called when some request is fully received and need to be
; processed.
;
; This is part of the web application, not the FastCGI framework. It need to
; generate only the output stream.
;

proc ServeOneRequestTest, .hSocket, .requestID, .pParams, .pPost
begin
        pushad

        DebugMsg "Beginnign ServeOneRequest"

        stdcall StrDupMem, <"Status: 200 OK", 13, 10, "Content-type: text/plain", 13, 10, 13, 10, "Test FCGI!", 13, 10, 13, 10, "Environment variables:", 13, 10, 13, 10>
        mov     edi, eax

        stdcall EnvironmentToStr, edi

        stdcall StrCat, edi, <"The FCGI_PARAMS stream parsed:", 13, 10, 13, 10>

        mov     esi, [.pParams]
        xor     ecx, ecx

.loop_params:
        cmp     ecx, [esi+TArray.count]
        jae     .end_params

        stdcall StrCat, edi, [esi+TArray.array+8*ecx]   ; name
        stdcall StrCharCat, edi, " = "
        stdcall StrCat, edi, [esi+TArray.array+8*ecx+4] ; value
        stdcall StrCharCat, edi, $0a0d

        inc     ecx
        jmp     .loop_params

.end_params:

        mov     esi, [.pPost]
        test    esi, esi
        jz      .finish_processing

        stdcall StrCat, edi, <13, 10, "POST data available:", 13, 10>

        OutputValue "Post data length:", [esi+TByteStream.size], 10, -1

        lea     esi, [esi+TByteStream.data]

        stdcall StrCat, edi, esi
        stdcall StrCharCat, edi, $0a0d0a0d


.finish_processing:

        DebugMsg "Output the result block."

        stdcall StrPtr, edi

        stdcall FCGI_output, [.hSocket], [.requestID], eax, [eax+string.len]
        stdcall StrDel, edi

        clc
        popad
        return
endp











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

        stdcall StrCat, edi, "</div>"                   ; div.post

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








; some utility procedures for debug and testing.


proc EnvironmentToStr, .hString
begin
        pushad

        stdcall GetAllEnvironment
        test    eax, eax
        jz      .finish_env

        push    eax
        mov     esi, eax

.env_out:
        mov     ebx, esi

.env_in:
        mov     cl, [esi]
        lea     esi, [esi+1]
        test    cl, cl
        jnz     .env_in

        stc
        mov     eax, esi
        sbb     eax, ebx
        jz      .end_env

        stdcall StrCat, [.hString], ebx
        stdcall StrCharCat, [.hString], $0a0d
        jmp     .env_out

.end_env:
        stdcall FreeMem ; from the stack

.finish_env:
        stdcall StrCharCat, [.hString], $0a0d0a0d

        stdcall StrCat, [.hString], 'Current directory: '

        stdcall GetCurrentDir
        jc      .finish

        stdcall StrCat, [.hString], eax
        stdcall StrDel, eax

        stdcall StrCharCat, [.hString], $0a0d0a0d

.finish:

        popad
        return
endp







errorHeader  text '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>HTTP response</title><link rel="stylesheet" href="/error.css"></head><body>'
errorFooter  text '</body></html>'




proc AppendError, .hString, .code
begin
        stdcall StrCat, [.hString], "Status: "
        stdcall StrCat, [.hString], [.code]
        stdcall StrCharCat, [.hString], $0a0d
        stdcall StrCat, [.hString], <"Content-type: text/html", 13, 10, 13, 10>

        stdcall StrCat, [.hString], errorHeader
        stdcall StrCat, [.hString], txt "<h1>"
        stdcall StrCat, [.hString], [.code]
        stdcall StrCat, [.hString], txt "</h1>"

        stdcall StrCat, [.hString], errorFooter
        return
endp