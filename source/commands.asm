
interface FCGI_pack_processor, .pPack, .pList




proc Listen
begin

.loop:
        stdcall SocketAccept, [STDIN], 0
        jc      .finish

        stdcall ThreadCreate, procServeRequest, eax
        jmp     .loop

.finish:
        return
endp




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



proc procServeRequest, .hSocket

.requestID     dd ?
.requestFlags  dd ?
.requestParams dd ?


begin
        pushad

        DebugMsg "FCGI thread started"


        mov     [.requestParams], 0

.main_loop:
        xor     eax, eax

        cmp     [.requestParams], eax
        je      .params_ok

        stdcall FreeNameValueArray, [.requestParams]
        mov     [.requestParams], eax

.params_ok:

        mov     [.requestFlags], eax
        mov     [.requestID], eax

.pack_loop:
        DebugMsg "Now wait for some package"

        stdcall FCGI_read_pack, [.hSocket]
        jc      .finish

        mov     esi, eax
        movzx   eax, [esi+FCGI_Header.type]

        OutputValue "Package received. Type = ", eax, 10, -1

        cmp     eax, FCGI_BEGIN_REQUEST
        je      .begin_request

        cmp     eax, FCGI_PARAMS
        je      .get_params

        cmp     eax, FCGI_ABORT_REQUEST
        je      .abort_request

; send back unknown type record.

        xor     edx, edx
        mov     dx, word [esi+FCGI_Header.requestIdB1]
        xchg    dl, dh

        stdcall FCGI_send_unknown_type, [.hSocket], edx, eax


.free_pack:
        stdcall FreeMem, esi
        jmp     .pack_loop



; Processing of FCGI_BEGIN_REQUEST

.begin_request:

        xor     eax, eax
        xor     edx, edx
        mov     ax, [esi+FCGI_BeginRequest.header.requestId]
        mov     dx, [esi+FCGI_BeginRequest.body.role]
        xchg    al, ah
        xchg    dl, dh

        cmp     dx, FCGI_RESPONDER
        jne     .unknown_role

        cmp     [.requestID], 0
        jne     .mx_disabled

        mov     [.requestID], eax

        movzx   ecx, [esi+FCGI_BeginRequest.body.flags]
        mov     [.requestFlags], ecx

        jmp     .free_pack


.unknown_role:

        DebugMsg "Unknown role!"

        stdcall FCGI_send_end_request, [.hSocket], eax, FCGI_UNKNOWN_ROLE
        jmp     .free_pack


.mx_disabled:

        DebugMsg "MX disabled!"

        stdcall FCGI_send_end_request, [.hSocket], eax, FCGI_CANT_MPX_CONN
        jmp     .free_pack


.abort_request:

        DebugMsg "Abort request received!"

        xor     eax, eax
        mov     ax, [esi+FCGI_Header.requestId]
        xchg    al, ah

        stdcall FCGI_send_end_request, [.hSocket], eax, FCGI_REQUEST_COMPLETE

        jmp     .main_loop


; Processing of FCGI_PARAMS


.get_params:

        xor     eax, eax
        mov     ax, [esi+FCGI_Header.requestId]
        xchg    al, ah

        cmp     eax, [.requestID]
        jne     .mx_disabled

        xor     edx, edx
        mov     dx, [esi+FCGI_Header.contentLength]
        xchg    dl, dh

        OutputValue "Params length: ", edx, 10, -1


        test    edx, edx
        jz      .serve_request          ; this is the last part of FCGI_PARAMS stream, so go to serve the request.

; add the package to the name/value pairs list.

        lea     edi, [esi+sizeof.FCGI_Header]

        stdcall FCGI_Decode_name_value_pairs, [.requestParams], edi, edx
        mov     [.requestParams], eax

        jmp     .free_pack


; Processing of the request. Here all data is ready, so serve the request!

.serve_request:

        stdcall FreeMem, esi

        stdcall ServeOneRequest, [.hSocket], [.requestID], [.requestParams]
        jc      .finish

        stdcall FCGI_send_end_request, [.hSocket], [.requestID], FCGI_REQUEST_COMPLETE

        test    [.requestFlags], FCGI_KEEP_CONN
        jnz     .main_loop

.finish:
        DebugMsg "Terminate thread FCGI"

        stdcall SocketClose, [.hSocket]
        popad
        return

endp






proc ServeOneRequest, .hSocket, .requestID, .pParams
begin
        pushad

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
        stdcall FCGI_output, [.hSocket], [.requestID], edi
        stdcall StrDel, edi

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




proc ReturnError, .code
begin
        stdcall FileWriteString, [STDOUT], "Status: "
        stdcall FileWriteString, [STDOUT], [.code]
        stdcall FileWrite,       [STDOUT], <txt 13, 10>, 2
        stdcall FileWriteString, [STDOUT], <"Content-type: text/html", 13, 10, 13, 10>
        stdcall FileWrite,       [STDOUT], errorHeader, errorHeader.length
        stdcall FileWriteString, [STDOUT], txt "<h1>"


        stdcall FileWriteString, [STDOUT], [.code]

        stdcall FileWriteString, [STDOUT], "</h1><p>Time:"

        stdcall GetTimestamp
        sub     eax, [StartTime]

        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        stdcall FileWriteString, [STDOUT], eax
        stdcall FileWriteString, [STDOUT], " ms</p>"

        stdcall FileWrite,       [STDOUT], errorFooter, errorFooter.length
        return
endp