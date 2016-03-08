








proc ServeOneRequest, .hSocket, .requestID, .pParams, .pPost

.root dd ?
.uri  dd ?
.filename dd ?

begin
        pushad

        xor     eax, eax
        mov     [.root], eax
        mov     [.uri], eax
        mov     [.filename], eax


        stdcall StrNew
        mov     edi, eax

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
        stdcall ValueByName, [.pParams], "REQUEST_URI"
        jc      .error400

        stdcall StrDup, eax
        mov     [.uri], eax

; first check for supported file format.

        stdcall StrDup, [.root]
        stdcall StrCat, eax, [.uri]
        mov     [.filename], eax

        stdcall StrExtractExt, [.filename]
        push    eax

        stdcall GetMimeType, eax
        stdcall StrDel ; from the stack
        jc      .analize_uri

        stdcall FileExists, [.filename]
        jc      .analize_uri

; serve the file.

        stdcall StrCat, edi, <"Status: 200 OK", 13, 10, "Content-type: ">
        stdcall StrCat, edi, eax
        stdcall StrCharCat, edi, $0a0d0a0d

        stdcall StrPtr, edi
        stdcall FCGI_output, [.hSocket], [.requestID], eax, [eax+string.len], FALSE

        stdcall LoadBinaryFile, [.filename]
        stdcall FCGI_output, [.hSocket], [.requestID], eax, ecx, TRUE
        stdcall FreeMem, eax

        jmp     .final_clean


.error400:
        stdcall AppendError, edi, "400 Bad Request"
        jmp     .send_simple_result


.error403:
        stdcall AppendError, edi, "403 Forbidden"
        jmp     .send_simple_result


.error404:
        stdcall AppendError, edi, "404 Not Found"


.send_simple_result:    ; it is a result containing only a string data in EDI

        stdcall StrPtr, edi
        stdcall FCGI_output, [.hSocket], [.requestID], eax, [eax+string.len], TRUE


.final_clean:

        stdcall StrDel, edi
        stdcall StrDelNull, [.root]
        stdcall StrDelNull, [.uri]
        stdcall StrDelNull, [.filename]

        clc
        popad
        return


locals
  .start  dd  ?
endl


.analize_uri:

        mov     [.start], 0

        stdcall StrSplitList, [.uri], '/', FALSE
        mov     esi, eax

        cmp     [esi+TArray.count], 0
        je      .show_thread_list               ; default behavior on the main page

        cmp     [esi+TArray.count], 2
        jne     .end_forum_request

        stdcall StrCompNoCase, [esi+TArray.array], "threads"
        jnc     .end_forum_request

        stdcall StrToNum, [esi+TArray.array+4]
        cmp     eax, -1
        jne     .show_one_thread


.end_forum_request:

        stdcall ListFree, esi, StrDel
        jmp     .final_clean




.show_thread_list:

        stdcall  ListThreads, [.start]


.output_forum_html:

        stdcall StrCat, edi, <"Status: 200 OK", 13, 10, "Content-type: text/html", 13, 10, 13, 10>
        stdcall StrCat, edi, htmlHeader
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, htmlFooter

        stdcall StrDel, eax

        stdcall ListFree, esi, StrDel
        jmp     .send_simple_result


.show_one_thread:

        stdcall ShowThread, eax, [.start]

        jmp     .output_forum_html

endp




htmlHeader  text '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Thread list</title><link rel="stylesheet" href="/all.css"></head><body><h1>This is simply experiment. Better go to <a href="http://asm32.info">my home page</a></h1>'
htmlFooter  text '</body></html>'





sqlSelectThreads text "select *, (select count() from posts where threadid = Threads.id) as PostCount from Threads limit 20 offset ?"


proc ListThreads, .start

.stmt  dd ?

begin
        pushad

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

; now make the HTML

        stdcall StrCat, edi, '<div class="thread_summary">'

; thread posts count

        stdcall StrCat, edi, '<div class="post_count">'

        cinvoke sqliteColumnInt, [.stmt], 3

        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        stdcall StrCat, edi, '</div>'   ; div.post_count

; link to the thread

        stdcall StrCat, edi, '<a class="thread_link" href="/threads/'

        cinvoke sqliteColumnInt, [.stmt], 0    ; threadID

        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        stdcall StrCharCat, edi, '">'


        cinvoke sqliteColumnText, [.stmt], 1    ; thread caption

        stdcall StrCat, edi, eax                ; thread caption
        stdcall StrCat, edi, txt '</a>'

        stdcall StrCat, edi, "</div>"   ; thread_summary.

        jmp     .loop


.finish:
        stdcall StrCat, edi, "</div>"   ; threadlist

        cinvoke sqliteFinalize, [.stmt]

        mov     [esp+4*regEAX], edi
        popad
        return
endp








sqlSelectPosts text "select * from Posts where threadID = ? limit 20 offset ?"


proc ShowThread, .threadID, .start

.stmt  dd ?

begin
        pushad

        stdcall StrNew
        mov     edi, eax

        stdcall StrCat, edi, '<div class="thread">'

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectPosts, -1, eax, 0

        OutputValue "SQL prepare:", eax, 10, -1

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        OutputValue "SQL bind:", eax, 10, -1

        cinvoke sqliteBindInt, [.stmt], 2, [.start]
        OutputValue "SQL bind:", eax, 10, -1

.loop:
        DebugMsg "SQL step"

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

        mov     [esp+4*regEAX], edi
        popad
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





proc StrDelNull, .hString
begin
        cmp     [.hString], 0
        jz      @f

        stdcall StrDel, [.hString]

@@:
        return
endp





proc GetMimeType, .extension
begin
        mov     eax, mimeIcon
        stdcall StrCompNoCase, [.extension], txt ".ico"
        jc      .mime_ok

        mov     eax, mimeHTML
        stdcall StrCompNoCase, [.extension], txt ".html"
        jc      .mime_ok

        stdcall StrCompNoCase, [.extension], txt ".html"
        jc      .mime_ok

        mov     eax, mimeCSS
        stdcall StrCompNoCase, [.extension], txt ".css"
        jc      .mime_ok

        mov     eax, mimePNG
        stdcall StrCompNoCase, [.extension], txt ".png"
        jc      .mime_ok

        mov     eax, mimeJPEG
        stdcall StrCompNoCase, [.extension], txt ".jpg"
        jc      .mime_ok

        stdcall StrCompNoCase, [.extension], txt ".jpeg"
        jc      .mime_ok

        mov     eax, mimeSVG
        stdcall StrCompNoCase, [.extension], txt ".svg"
        jc      .mime_ok

        mov     eax, mimeGIF
        stdcall StrCompNoCase, [.extension], txt ".gif"
        jc      .mime_ok

        mov     eax, mimeText
        stdcall StrCompNoCase, [.extension], txt ".txt"
        jc      .mime_ok

        xor     eax, eax
        stc
        return

.mime_ok:
        clc
        return

endp


mimeIcon  text "image/x-icon"
mimeHTML  text "text/html"
mimeText  text "text/plain"
mimeCSS   text "text/css"
mimePNG   text "image/png"
mimeJPEG  text "image/jpeg"
mimeSVG   text "image/svg+xml"
mimeGIF   text "image/gif"








; DEBUGGING CODE!


;
; This procedure is called when some request is fully received and need to be
; processed.
;
; This is part of the web application, not the FastCGI framework. It need to
; generate only the output stream.
;
; ServeOneRequestTest is debugging procedure that returns
; some server specific information - the environment variables, the content of
; FCGI_PARAMS stream, etc.
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


