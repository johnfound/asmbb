DEFAULT_PAGE_LENGTH = 20

; User permissions status flags:

permLogin       = 1
permPost        = 4
permThreadStart = 8
permEditOwn     = 16
permEditAll     = 32
permDelOwn      = 64
permDelAll      = 128
permAdmin       = $80000000



struct TSpecialParams
  .start_time      dd ?

; request parameters

  .params          dd ?
  .post_array      dd ?

  .dir             dd ?                 ; /tag_name/
  .thread          dd ?                 ; /thread_slug/
  .page_num        dd ?                 ; /1234

; forum global variables.

  .page_title      dd ?
  .page_length     dd ?
  .setupmode       dd ?

; logged user info.

  .userID          dd ?
  .userName        dd ?
  .userStatus      dd ?

  .userLang        dd ?         ; not used right now.
  .userSkin        dd ?         ; not used right now.
  .session         dd ?
  .remoteIP        dd ?
ends




proc ServeOneRequest, .hSocket, .requestID, .pParams2, .pPost2, .start_time

.root     dd ?
.uri      dd ?
.filename dd ?
.mime     dd ?

.date     TDateTime
.timelo   dd ?
.timehi   dd ?

.timeRet  rd 2


.special TSpecialParams

begin
        pushad

        xor     eax, eax
        mov     [.root], eax
        mov     [.uri], eax
        mov     [.filename], eax

        lea     edi, [.special]
        mov     ecx, sizeof.TSpecialParams / 4
        rep stosd

        mov     eax, [.start_time]
        mov     [.special.start_time], eax

        mov     eax, [.pParams2]
        mov     [.special.params], eax

        stdcall DecodePostData, [.pPost2], [.special.params]
        jc      .post_ok

        mov     [.special.post_array], eax

.post_ok:

        stdcall GetParam, "forum_title", gpString
        jnc     .title_ok

        stdcall StrDupMem, "AsmBB: "

.title_ok:
        mov     [.special.page_title], eax


        stdcall GetParam, 'page_length', gpInteger
        jnc     .page_length_ok

        mov     eax, DEFAULT_PAGE_LENGTH

.page_length_ok:
        mov     [.special.page_length], eax

        stdcall StrNew
        mov     edi, eax

        stdcall ValueByName, [.special.params], "DOCUMENT_ROOT"
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

        mov     [ebx+string.len], eax
        mov     byte [ebx+eax], 0

.root_ok:

        stdcall ValueByName, [.pParams2], "REQUEST_URI"
        jc      .error400

        stdcall StrSplitList, eax, '?', FALSE
        mov     ebx, eax

        cmp     [ebx+TArray.count], 0
        je      .error400

        xor     eax, eax
        xchg    eax, [ebx+TArray.array]

        stdcall StrURLDecode, eax
        mov     [.uri], eax

        stdcall ListFree, ebx, StrDel


; first check for supported file format.

        stdcall StrPtr, [.root]

        stdcall StrDupMem, eax
        stdcall StrCat, eax, [.uri]
        mov     [.filename], eax

        stdcall StrMatchPattern, "*.well-known/*", [.uri]
        jnc     .check_file_type

        mov     [.mime], mimeText
        jmp     .get_file_if_newer

.check_file_type:

        stdcall StrExtractExt, [.filename]
        jc      .analize_uri

        push    eax

        stdcall GetMimeType, eax
        stdcall StrDel ; from the stack
        jc      .analize_uri

        mov     [.mime], eax

.get_file_if_newer:

        mov     [.timelo], 0
        mov     [.timehi], 0

        stdcall ValueByName, [.special.params], "HTTP_IF_MODIFIED_SINCE"
        jc      .get_file

        lea     edx, [.date]
        stdcall DecodeHTTPDate, eax, edx
        jc      .get_file

        stdcall DateTimeToTime, edx
        mov     [.timelo], eax
        mov     [.timehi], edx

.get_file:

        if defined options.DebugMode & options.DebugMode

           Message "File request: "

           stdcall StrPtr, [.filename]
           Output  eax

           DebugMsg

        end if


        lea     eax, [.timeRet]
        stdcall GetFileIfNewer, [.filename], [.timelo], [.timehi], eax
        jc      .error404_no_list_free

        DebugMsg "File exists."

        test    eax, eax
        jz      .send_304_not_modified

        DebugMsg "File is to be returned."

        mov     esi, eax

; serve the file.

        stdcall StrCat, edi, <"Cache-control: max-age=1000000", 13, 10>

        stdcall FormatHTTPTime, [.timeRet], [.timeRet+4]
        stdcall StrCat, edi, "Last-modified: "
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        stdcall StrCat, edi, <13, 10, "Content-type: ">
        stdcall StrCat, edi, [.mime]

        stdcall StrCharCat, edi, $0a0d0a0d

        stdcall StrPtr, edi
        stdcall FCGI_output, [.hSocket], [.requestID], eax, [eax+string.len], FALSE
        jc      .error500

        stdcall FCGI_output, [.hSocket], [.requestID], esi, ecx, TRUE
        jc      .error500

        stdcall FreeMem, esi

        jmp     .final_clean


.send_304_not_modified:
        DebugMsg "File is cached, not to be send."

        stdcall StrCat, edi, <"Status: 304 Not Modified", 13, 10, 13, 10>
        jmp     .send_simple_result2

.error500:
        lea     eax, [.special]
        stdcall AppendError, edi, "500 Unexpected server error", eax
        jmp     .send_simple_result2

.error400:
        lea     eax, [.special]
        stdcall AppendError, edi, "400 Bad Request", eax
        jmp     .send_simple_result2                            ; without freeing the list in ESI!


.error404_no_list_free:
        lea     eax, [.special]
        stdcall AppendError, edi, "404 Not Found", eax
        jmp     .send_simple_result2



.error403:
        lea     eax, [.special]
        stdcall AppendError, edi, "403 Forbidden", eax
        jmp     .send_simple_result



.error404:
        lea     eax, [.special]
        stdcall AppendError, edi, "404 Not Found", eax
        jmp     .send_simple_result



.output_forum_html:     ; Status: 200 OK

        stdcall StrCat, edi, <"Content-type: text/html; charset=utf-8", 13, 10, 13, 10>

        lea     edx, [.special]
        stdcall StrCatTemplate, edi, "main_html_start", 0, edx

        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        stdcall StrCatTemplate, edi, "main_html_end", 0, edx


.send_simple_result:    ; it is a result containing only a string data in EDI

        stdcall ListFree, esi, StrDel

.send_simple_result2:

        stdcall StrPtr, edi
        stdcall FCGI_output, [.hSocket], [.requestID], eax, [eax+string.len], TRUE

.final_clean:

        stdcall StrDel, edi
        stdcall StrDel, [.root]
        stdcall StrDel, [.uri]
        stdcall StrDel, [.filename]

        stdcall StrDel, [.special.userName]
        stdcall StrDel, [.special.session]
        stdcall StrDel, [.special.dir]
        stdcall StrDel, [.special.thread]
        stdcall StrDel, [.special.page_title]

        stdcall FreePostDataArray, [.special.post_array]

        popad
        return


.send_simple_replace:     ; replaces the EDI string with new one and sends it as a simple result

        stdcall StrDel, edi
        mov     edi, eax
        jmp     .send_simple_result


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.analize_uri:

;        DebugMsg "Analyze URL"

        stdcall StrSplitList, [.uri], '/', FALSE        ; split the URI in order to analize it better.
        mov     esi, eax

        lea     eax, [.special]
        stdcall GetLoggedUser, eax

        mov     ecx, CreateAdminAccount
        cmp     [.special.setupmode], 0
        jne     .exec_command

        call    .pop_array_item
        jz      .show_thread_list

;.is_it_root_command:

        push    eax
        stdcall StrPtr, eax
        cmp     byte [eax], '!'
        pop     eax
        jne     .is_it_tag

        mov     ecx, UserAvatar
        stdcall StrCompNoCase, eax, txt "!avatar"
        jc      .exec_command2

        mov     ecx, UserLogin
        stdcall StrCompNoCase, eax, txt "!login"
        jc      .exec_command

        mov     ecx, UserLogout
        stdcall StrCompNoCase, eax, txt "!logout"
        jc      .exec_command

        mov     ecx, RegisterNewUser
        stdcall StrCompNoCase, eax, txt "!register"
        jc      .exec_command

        mov     ecx, ChangePassword
        stdcall StrCompNoCase, eax, txt "!changepassword"
        jc      .exec_command

        mov     ecx, ChangeEmail
        stdcall StrCompNoCase, eax, txt "!changemail"
        jc      .exec_command

        mov     ecx, SQLiteConsole
        stdcall StrCompNoCase, eax, txt "!sqlite"         ; sqlite console. only for admins.
        jc      .exec_command

        mov     ecx, BoardSettings
        stdcall StrCompNoCase, eax, txt "!settings"
        jc      .exec_command

        mov     ecx, ShowForumMessage
        stdcall StrCompNoCase, eax, txt "!message"
        jc      .exec_command2

        mov     ecx, ActivateAccount
        stdcall StrCompNoCase, eax, txt "!activate"
        jc      .exec_command2

        mov     ecx, ShowUserInfo
        stdcall StrCompNoCase, eax, txt "!userinfo"
        jc      .exec_command2

        mov     ecx, UpdateUserAvatar
        stdcall StrCompNoCase, eax, txt "!avatar_upload"
        jc      .exec_command2

        mov     ecx, RenderAll
        stdcall StrCompNoCase, eax, txt "!render_all"
        jc      .exec_command

        mov     ecx, UserActivityTable
        stdcall StrCompNoCase, eax, txt "!users_online"
        jc      .exec_command


if defined options.DebugWeb & options.DebugWeb
        mov     ecx, PostDebug
        stdcall StrCompNoCase, eax, txt "!postdebug"
        jc      .exec_command
end if


.is_it_tag:

;        DebugMsg "Is it a tag?"

        stdcall InTags, eax
        jnc     .is_it_thread

;        DebugMsg "Tag detected"

        mov     [.special.dir], eax
        call    .pop_array_item
        jz      .show_thread_list


.is_it_thread:

;        DebugMsg "Is it a thread?"

        stdcall InThreads, eax
        jnc     .is_it_number

;        DebugMsg "Thread detected"

        mov     [.special.thread], eax
        call    .pop_array_item
        jz      .show_one_thread

.is_it_number:

;        DebugMsg "Is it a number?"

        stdcall InNumbers, eax
        jnc     .is_it_command

;        DebugMsg "Number detected"

        mov     [.special.page_num], edx
        stdcall StrDel, eax

        call    .pop_array_item
        jnz     .is_it_command

        cmp     [.special.thread], eax  ; eax==0 here
        je      .show_thread_list
        jmp     .show_one_thread


.is_it_command:

;        DebugMsg "Is it a command?"

        push    eax
        stdcall StrPtr, eax
        cmp     byte [eax], '!'
        pop     eax
        jne     .bad_command


        mov     ecx, MarkThreadRead
        stdcall StrCompNoCase, eax, txt "!markread"
        jc      .exec_command

        mov     ecx, PostUserMessage
        stdcall StrCompNoCase, eax, txt "!post"
        jc      .exec_command

        mov     ecx, EditUserMessage
        stdcall StrCompNoCase, eax, txt "!edit"
        jc      .exec_command

        mov     ecx, DeleteConfirmation
        stdcall StrCompNoCase, eax, txt "!confirm"
        jc      .exec_command

        mov     ecx, DeletePost
        stdcall StrCompNoCase, eax, txt "!del"
        jc      .exec_command

        mov     ecx, PinThread
        stdcall StrCompNoCase, eax, txt "!pinit"
        jc      .exec_command

        mov     ecx, PostByID
        stdcall StrCompNoCase, eax, txt "!by_id"
        jc      .exec_command

        mov     ecx, ShowSearchResults2
        stdcall StrCompNoCase, eax, txt "!search"
        jc      .exec_command2


.bad_command:
;        DebugMsg "Command not detected."

        stdcall StrDel, eax
        jmp     .error404


;..................................................................................
;
; Execute command procedure with 1 argument = ptr to TSpecialParams

.show_thread_list:
        mov     ecx, ListThreads
        jmp     .exec_command


.show_one_thread:
        mov     ecx, ShowThread


.exec_command:

        lea     eax, [.special]
        stdcall ecx, eax
        jc      .send_simple_replace

        test    eax, eax
        jz      .error404

        jmp     .output_forum_html



;..................................................................................
;
; Executes command procedure with 2 arguments: 1:hString and 2:ptr to TSpecialParams

.exec_command2:

        xor     edx, edx
        cmp     [esi+TArray.count], edx
        je      .arg_ok

        mov     edx, [esi+TArray.array]

.arg_ok:
        lea     eax, [.special]
        stdcall ecx, edx, eax
        jc      .send_simple_replace

        test    eax, eax
        jz      .error404

        jmp     .output_forum_html


;..................................................................................



.pop_array_item:

        xor     eax, eax
        cmp     [esi+TArray.count], eax
        je      .end_pop

        mov     eax, [esi+TArray.array]
        stdcall DeleteArrayItems, esi, 0, 1
        mov     esi, edx
        cmp     eax, edx        ; always not equal!

.end_pop:
        retn


endp









sqlMarkThreadRead text "delete from UnreadPosts where UserID = ?1 and ( ?2 is NULL or PostID in (select P.id from Posts P left join Threads T on P.ThreadID = T.id where T.Slug = ?2))"

proc MarkThreadRead, .pSpecial
.stmt dd ?
begin
        pushad

        mov     esi, [.pSpecial]

        cmp     [esi+TSpecialParams.userID], 0
        je      .finish

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlMarkThreadRead, sqlMarkThreadRead.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.userID]

        mov     edx, [esi+TSpecialParams.thread]
        test    edx, edx
        jz      .step_it

        stdcall StrLen, edx
        mov     ecx, eax
        stdcall StrPtr, edx
        cinvoke sqliteBindText, [.stmt], 2, eax, ecx, SQLITE_STATIC


.step_it:
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

.finish:
        stdcall GetBackLink, esi
        push    eax

        stdcall StrMakeRedirect, 0, eax
        stdcall StrDel ; from the stack

        mov     [esp+4*regEAX], eax
        stc
        popad
        return
endp






proc CreatePagesLinks2, .current, .count, .suffix, .page
begin
        pushad

        stdcall StrDupMem, '<div class="page_row">'
        mov     edi, eax

        mov     eax, [.count]
        cdq
        mov     ecx, [.page]
        div     ecx

        test    edx, edx
        jz      @f
        inc     eax
@@:
        cmp     eax, 1
        je      .finish

        mov     ebx, eax        ; pages count
        xor     ecx, ecx

        xor     esi, esi

.loop:
        cmp     ecx, ebx
        jae     .finish

        cmp     [.count], 30
        jbe     .regular

; first 5
        cmp     ecx, 5
        jb      .regular

; last 5
        mov     eax, ebx
        sub     eax, 5
        cmp     ecx, eax
        jae     .regular

; 5 around the current
        mov     eax, [.current]
        lea     edx, [eax-2]
        lea     eax, [eax+2]

        cmp     ecx, edx
        jb      .middle_left

        cmp     ecx, eax
        jbe     .regular

; 5 in the middle between current and beginning
.middle_left:
        mov     eax, [.current]
        shr     eax, 1
        lea     edx, [eax-2]
        lea     eax, [eax+2]

        cmp     ecx, edx
        jb      .middle_right

        cmp     ecx, eax
        jbe     .regular

; 5 in the middle beween current and the end
.middle_right:
        mov     eax, [.current]
        add     eax, ebx
        shr     eax, 1
        lea     edx, [eax-2]
        lea     eax, [eax+2]

        cmp     ecx, edx
        jb      .skip

        cmp     ecx, eax
        ja      .skip


.regular:
        inc     esi

        stdcall NumToStr, ecx, ntsDec or ntsUnsigned

        cmp     ecx, [.current]
        jne     .current_ok

        stdcall StrCat, edi, '<span class="current_page">'
        jmp     .link_ok

.current_ok:
        stdcall StrCat, edi, '<a class="page_link" href="'
        test    ecx, ecx
        jnz     .non_zero

        stdcall StrCharCat, edi, "."
        jmp     .href_ok

.non_zero:
        stdcall StrCat, edi, eax

.href_ok:
        cmp     [.suffix], 0
        je      .close_href

        stdcall StrCat, edi, [.suffix]

.close_href:
        stdcall StrCat, edi, txt '">'
.link_ok:
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        cmp     ecx, [.current]
        jne     .current_ok2

        stdcall StrCat, edi, '</span> '
        jmp     .next

.current_ok2:
        stdcall StrCat, edi, txt "</a> "

.next:
        inc     ecx
        jmp     .loop


.skip:
        test    esi, esi
        jz      .next

        stdcall StrCat, edi, '<span class="page_hole">....</span>'

        xor     esi, esi
        jmp     .next


.finish:
        stdcall StrCat, edi, "</div>"
        mov     [esp+4*regEAX], edi
        popad
        return
endp







sqlGetSession    text "select userID, nick, status, last_seen from sessions left join users on id = userID where sid = ?"
sqlGetUserExists text "select 1 from users limit 1"

; returns:
;   EAX: string with the logged user name
;   ECX: string with the session ID
;   EDX: logged user ID

proc GetLoggedUser, .pSpecial
.stmt dd ?
begin
        pushad

        mov     edi, [.pSpecial]

        xor     eax, eax
        mov     [edi+TSpecialParams.userID], eax
        mov     [edi+TSpecialParams.userName], eax
        mov     [edi+TSpecialParams.userStatus], eax
        mov     [edi+TSpecialParams.session], eax
        mov     [edi+TSpecialParams.remoteIP], eax

        stdcall GetParam, "anon_perm", gpInteger
        jc      .anon_ok

        mov     [edi+TSpecialParams.userStatus], eax

.anon_ok:

        stdcall ValueByName, [edi+TSpecialParams.params], "REMOTE_ADDR"
        jc      .ip_ok

        stdcall StrIP2Num, eax
        jc      .ip_ok

        mov     [edi+TSpecialParams.remoteIP], eax

.ip_ok:
        xor     ebx, ebx

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUserExists, sqlGetUserExists.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        je      .setupmode_ok

        inc     ebx

.setupmode_ok:
        cinvoke sqliteFinalize, [.stmt]
        mov     [edi+TSpecialParams.setupmode], ebx

        test    ebx, ebx
        jnz     .finish

        stdcall GetCookieValue, [edi+TSpecialParams.params], txt 'sid'
        jc      .finish

        mov     ebx, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetSession, -1, eax, 0

        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_ROW
        jne     .finish_sql

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [edi+TSpecialParams.userID], eax

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrDupMem, eax

        mov     [edi+TSpecialParams.userName], eax

        cinvoke sqliteColumnInt, [.stmt], 2
        mov     [edi+TSpecialParams.userStatus], eax

        stdcall StrDup, ebx
        mov     [edi+TSpecialParams.session], eax

.finish_sql:
        cinvoke sqliteFinalize, [.stmt]
        stdcall StrDel, ebx

        mov     eax, [edi+TSpecialParams.userID]
        test    eax, eax
        jz      .finish

        stdcall SetUserLastSeen, eax

.finish:
        stdcall InsertGuest, [.pSpecial]
        popad
        return
endp



sqlLogBadCookie text "insert into BadCookies values (?, ?, ?)"


proc GetCookieValue, .pParams, .name
.stmt dd ?
begin
        pushad

        or      ebx, -1

        stdcall ValueByName, [.pParams], "HTTP_COOKIE"
        jc      .finish

        stdcall StrSplitList, eax, ";", FALSE
        mov     esi, eax
        mov     ecx, [esi+TArray.count]

.loop:
        dec     ecx
        js      .end_loop

        stdcall StrSplitList, [esi+TArray.array+4*ecx], "=", FALSE
        mov     edi, eax

        cmp     [edi+TArray.count], 2
        jne     .next

        stdcall StrCompNoCase, [edi+TArray.array], [.name]
        jc      .found

; log not matching cookies.

        pushad

        mov     ebx, [esi+TArray.array+4*ecx]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlLogBadCookie, -1, eax, 0

        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 1, eax, -1, SQLITE_STATIC

        stdcall ValueByName, [.pParams], "HTTP_USER_AGENT"
        jc      .agent_ok

        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, -1, SQLITE_STATIC

.agent_ok:
        stdcall ValueByName, [.pParams], "REMOTE_ADDR"
        jc      .remote_ok

        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 3, eax, -1, SQLITE_STATIC

.remote_ok:

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        popad

        jmp     .next

.found:
        xor     eax, eax
        xchg    eax, [edi+TArray.array+4]
        mov     [esp+4*regEAX], eax
        xor     ecx, ecx                        ; force the loop end, after freeing the list in edi
        xor     ebx, ebx

.next:
        stdcall ListFree, edi, StrDel
        jmp     .loop


.end_loop:
        stdcall ListFree, esi, StrDel

.finish:
        shr     ebx, 1          ; set the CF!
        popad
        return
endp





proc AppendError, .hString, .code, .special
begin
        stdcall StrCat, [.hString], "Status: "
        stdcall StrCat, [.hString], [.code]
        stdcall StrCharCat, [.hString], $0a0d
        stdcall StrCat, [.hString], <"Content-type: text/html", 13, 10, 13, 10>

        stdcall StrCatTemplate, [.hString], "error_html_start", 0, [.special]
        stdcall StrCat, [.hString], txt "<h1>"
        stdcall StrCat, [.hString], [.code]
        stdcall StrCat, [.hString], txt "</h1>"

        stdcall StrCatTemplate, [.hString], "error_html_end", 0, [.special]
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

        mov     eax, mimeXML
        stdcall StrCompNoCase, [.extension], txt ".xml"
        jc      .mime_ok

        mov     eax, mimeJson
        stdcall StrCompNoCase, [.extension], txt ".json"
        jc      .mime_ok

        xor     eax, eax
        stc
        return

.mime_ok:
        clc
        return

endp


mimeIcon  text "image/x-icon"
mimeHTML  text "text/html; charset=utf-8"
mimeXML   text "text/xml"
mimeJson  text "application/json"
mimeText  text "text/plain; charset=utf-8"
mimeCSS   text "text/css; charset=utf-8"
mimePNG   text "image/png"
mimeJPEG  text "image/jpeg"
mimeSVG   text "image/svg+xml; charset=utf-8"
mimeGIF   text "image/gif"






sqlSelectNotSent text "select id, nick, email, a_secret as secret, (select val from Params where id='host') as host, salt from WaitingActivation where time_email is NULL order by time_reg"
sqlCleanWaiting  text "delete from WaitingActivation where time_reg < (strftime('%s','now') - 86400) and time_email is not NULL"

proc ProcessActivationEmails
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectNotSent, -1, eax, 0

.account_loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .process_end

        stdcall SendActivationEmail, [.stmt]
        jmp     .account_loop


.process_end:
        cinvoke sqliteFinalize, [.stmt]
        cinvoke sqliteExec, [hMainDatabase], sqlCleanWaiting, 0, 0, 0

        popad
        return
endp


sqlUpdateEmailTime text "update WaitingActivation set time_email = strftime('%s','now') where id = ?"

proc SendActivationEmail, .stmt

.stmt2     dd ?
.subj      dd ?
.body      dd ?

.host      dd ?
.from      dd ?
.to        dd ?
.smtp_addr dd ?
.smtp_port dd ?

begin
        pushad

        xor     eax, eax
        mov     [.host], eax
        mov     [.from], eax
        mov     [.to], eax
        mov     [.smtp_addr], eax
        mov     [.subj], eax
        mov     [.body], eax


        stdcall GetParam, txt "host", gpString
        jc      .finish

        mov     [.host], eax


        stdcall GetParam, txt "smtp_user", gpString
        jc      .finish

        mov     [.from], eax

        cinvoke sqliteColumnText, [.stmt], 2    ; the user email
        stdcall StrDupMem, eax

        mov     [.to], eax


        stdcall GetParam, "smtp_addr", gpString
        jc      .finish

        mov     [.smtp_addr], eax


        stdcall GetParam, "smtp_port", gpInteger
        jc      .finish

        mov     [.smtp_port], eax


        stdcall StrNew
        mov     [.subj], eax

        stdcall StrCatTemplate, eax, "activation_email_subject", [.stmt], 0
        jc      .finish


        stdcall StrNew
        mov     [.body], eax

        stdcall StrCatTemplate, eax, "activation_email_text", [.stmt], 0
        jc      .finish


; now try to update the data of the record!

        lea     eax, [.stmt2]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateEmailTime, -1, eax, 0

        cinvoke sqliteColumnInt, [.stmt], 0
        cinvoke sqliteBindInt, [.stmt2], 1, eax

        cinvoke sqliteStep, [.stmt2]
        push    eax
        cinvoke sqliteFinalize, [.stmt2]

        pop     eax
        cmp     eax, SQLITE_DONE
        jne     .error_update


        stdcall SendEmail, [.smtp_addr], [.smtp_port], [.host], [.from], [.to], [.subj], [.body], 0
        stdcall LogEvent, "EmailSent", logText, eax, 0
        stdcall StrDel, eax

.finish:
        pushf

        stdcall StrDel, [.smtp_addr]
        stdcall StrDel, [.host]
        stdcall StrDel, [.from]
        stdcall StrDel, [.to]
        stdcall StrDel, [.subj]
        stdcall StrDel, [.body]

        popf
        popad
        return


.error_update:          ; the time_email field was not updated to the time of email, so the email was not sent
                        ; in order to prevent spam to the user mailbox.

        stc
        jmp     .finish

endp




gpString  = 0
gpInteger = 1


sqlGetParam      text "select val from params where id = ?"

proc GetParam, .key, .type
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetParam, -1, eax, 0

        stdcall StrPtr, [.key]
        cinvoke sqliteBindText, [.stmt], 1, eax, -1, SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error

        cmp     [.type], gpString
        je      .get_string

        cinvoke sqliteColumnInt, [.stmt], 0
        jmp     .finish

.get_string:
        cinvoke sqliteColumnText, [.stmt], 0
        stdcall StrDupMem, eax

.result:
        clc

.finish:
        pushf
        push    eax

        cinvoke sqliteFinalize, [.stmt]

        pop     eax
        popf
        mov     [esp+4*regEAX], eax
        popad
        return

.error:
        stc
        mov     eax, [esp+4*regEAX]
        jmp     .finish

endp












sqlSetUserTime text "update users set LastSeen = strftime('%s','now') where id = ?"


proc SetUserLastSeen, .userID
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSetUserTime, sqlSetUserTime.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.userID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        popad
        return
endp



sqlInsertGuest   text "insert or replace into Guests values (?, strftime('%s','now'))"
sqlClipGuests    text "delete from Guests where LastSeen < strftime('%s','now') - 864000"     ; 10 days = 864000 seconds

proc InsertGuest, .pSpecial
.stmt dd ?
begin
        pushad

        mov     esi, [.pSpecial]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertGuest, sqlInsertGuest.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.remoteIP]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        cinvoke sqliteExec, [hMainDatabase], sqlClipGuests, 0, 0, 0
        popad
        return
endp







sqlIncReadCount text "update Posts set ReadCount = ReadCount + 1 where id = ?"


proc PostIncrementReadCount, .postID
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlIncReadCount, sqlIncReadCount.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.postID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        popad
        return
endp



sqlSetUnread text "insert or replace into UnreadPosts (UserID, PostID, `Time`) select U.id, ?, strftime('%s','now') from users U where (strftime('%s','now') - U.LastSeen < 2592000)"

proc RegisterUnreadPost, .postID
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSetUnread, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.postID]
        cinvoke sqliteStep, [.stmt]
        mov     [esp+4*regEAX], eax

        cinvoke sqliteFinalize, [.stmt]

        popad
        return
endp




sqlSetRead text "delete from UnreadPosts where UserID = ? and PostID = ?"

proc SetPostRead, .userID, .postID
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSetRead, -1, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.userID]
        cinvoke sqliteBindInt, [.stmt], 2, [.postID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        popad
        return
endp



sqlSetTicket text "update Sessions set Ticket = ? where sid = ?"


proc SetUniqueTicket, .sid
.stmt dd ?
begin
        pushad
        stdcall GetRandomString, 32
        mov     ebx, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSetTicket, sqlSetTicket.length, eax, 0

        stdcall StrLen, ebx
        mov     ecx, eax
        stdcall StrPtr, ebx

        cinvoke sqliteBindText, [.stmt], 1, eax, ecx, SQLITE_STATIC

        stdcall StrLen, [.sid]
        mov     ecx, eax
        stdcall StrPtr, [.sid]

        cinvoke sqliteBindText, [.stmt], 2, eax, ecx, SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        mov     edi, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     edi, SQLITE_DONE
        clc
        je      .finish

        stdcall StrDel, ebx
        mov     ebx, [esp+4*regEAX]
        stc

.finish:
        mov     [esp+4*regEAX], ebx
        popad
        return
endp




proc ClearTicket, .sid
.stmt dd ?
begin
        pushad

        cmp     [.sid], 0
        je      .finish

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSetTicket, sqlSetTicket.length, eax, 0

        stdcall StrLen, [.sid]
        mov     ecx, eax
        stdcall StrPtr, [.sid]

        cinvoke sqliteBindText, [.stmt], 2, eax, ecx, SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

.finish:
        popad
        return
endp




sqlCheckTicket text "select 1 from sessions where ticket = ? and sid = ?"

proc CheckTicket, .ticket, .sid
.stmt dd ?
begin
        pushad

        cmp     [.ticket], 0
        je      .error

        cmp     [.sid], 0
        je      .error

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCheckTicket, sqlCheckTicket.length, eax, 0

        stdcall StrLen, [.ticket]
        mov     ecx, eax
        stdcall StrPtr, [.ticket]

        cinvoke sqliteBindText, [.stmt], 1, eax, ecx, SQLITE_STATIC

        stdcall StrLen, [.sid]
        mov     ecx, eax
        stdcall StrPtr, [.sid]

        cinvoke sqliteBindText, [.stmt], 2, eax, ecx, SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_ROW
        jne     .error

        clc
        popad
        return

.error:
        stc
        popad
        return

endp






proc GetFileIfNewer, .filename, .time_lo, .time_hi, .ptrRetModified

.file_info TFileInfo

begin
        pushad

        stdcall FileOpenAccess, [.filename], faReadOnly
        jc      .finish

        mov     ebx, eax

        lea     eax, [.file_info]
        stdcall GetFileInfo, ebx, eax

        mov     eax, dword [.file_info.timeModified]
        mov     edx, dword [.file_info.timeModified+4]
        mov     ecx, [.ptrRetModified]

        mov     [ecx], eax
        mov     [ecx+4], edx

        cmp     edx, [.time_hi]
        ja      .read_it              ; the file is newer
        jb      .finish_older         ; returns EAX = 0 and CF=0 if the date is older.

        cmp     eax, [.time_lo]
        jbe     .finish_older

.read_it:
        stdcall FileSize, ebx
        mov     ecx, eax

        stdcall GetMem, ecx
        mov     esi, eax

        stdcall FileRead, ebx, esi, ecx

        cmp     eax, ecx
        je      .read_ok

; read is not ok - return CF = 1
        stdcall FreeMem, esi
        stc
        jmp     .finish_close


.finish_older:

        xor     esi, esi
        xor     ecx, ecx

.read_ok:
        mov     [esp+4*regEAX], esi
        mov     [esp+4*regECX], ecx
        clc

.finish_close:
        pushf
        stdcall FileClose, ebx
        popf

.finish:
        popad
        return
endp




sqlInTags text "select 1 from Tags where Tag = ?"

proc InTags, .hTag
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInTags, sqlInTags.length, eax, 0

        stdcall StrLen, [.hTag]
        mov     ecx, eax

        stdcall StrPtr, [.hTag]
        cinvoke sqliteBindText, [.stmt], 1, eax, ecx, SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_ROW
        jne     .not_tag

        stc
        popad
        return


.not_tag:
        clc
        popad
        return
endp



sqlInThreads text "select 1 from Threads where Slug = ?"

proc InThreads, .hSlug
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInThreads, sqlInThreads.length, eax, 0

        stdcall StrLen, [.hSlug]
        mov     ecx, eax

        stdcall StrPtr, [.hSlug]
        cinvoke sqliteBindText, [.stmt], 1, eax, ecx, SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_ROW
        jne     .not_thread

        stc
        popad
        return


.not_thread:
        clc
        popad
        return
endp


proc InNumbers, .hString
begin
        pushad

        stdcall StrToNumEx, [.hString]
        jc      .finish

        mov     [esp+4*regEDX], eax

.finish:
        cmc
        popad
        return
endp