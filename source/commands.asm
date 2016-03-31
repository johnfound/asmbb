LIMIT_POST_LENGTH equ 8*1024
PAGE_LENGTH = 20

; User permissions status flags:

permLogin       = 1
permRead        = 2
permPost        = 4
permThreadStart = 8
permEditOwn     = 16
permEditAll     = 32
permAdmin       = $80000000



struct TSpecialParams
  .start_time      dd ?
  .params          dd ?
  .post            dd ?
  .query           dd ?
  .search          dd ?
  .tag             dd ?
  .userID          dd ?
  .userName        dd ?
  .userStatus      dd ?
  .session         dd ?
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

        mov     eax, [.pPost2]
        test    eax, eax
        jz      .post_ok

        lea     edx, [eax+TByteStream.data]
        mov     ecx, [eax+TByteStream.size]

        stdcall StrNew
        stdcall StrCatMem, eax, edx, ecx

.post_ok:

        mov     [.special.post], eax


; debug only

;        lea     eax, [.special]
;        stdcall __DoProcessTemplate2, "[special:environment]", 0, eax, FALSE
;        push    eax
;
;        stdcall FileWriteString, [STDERR], eax
;        stdcall FileWriteString, [STDERR], <13, 10, 13, 10, "----------------------------------------------------------", 13, 10, 13, 10>
;
;        stdcall StrDel ; from the stack

; end of debug



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
        mov     [.uri], eax

        stdcall ListFree, ebx, StrDelNull


; QUERY_STRING analizing

        stdcall ValueByName, [.special.params], "QUERY_STRING"
        jc      .query_ok

        stdcall StrDup, eax
        mov     [.special.query], eax

        stdcall GetQueryItem, [.special.query], txt "s=", 0
        mov     [.special.search], eax
        test    eax, eax
        jz      .search_ok

        stdcall StrLen, eax
        test    eax, eax
        jnz     .search_ok

        xchg    eax, [.special.search]
        stdcall StrDel, eax

.search_ok:

        stdcall GetQueryItem, [.special.query], txt "tag=", 0
        mov     [.special.tag], eax
        test    eax, eax
        jz      .tag_ok

        stdcall StrLen, eax
        test    eax, eax
        jnz     .tag_ok

        xchg    eax, [.special.tag]
        stdcall StrDel, eax

.tag_ok:

.query_ok:

; first check for supported file format.

        stdcall StrPtr, [.root]

        stdcall StrDupMem, eax
        stdcall StrCat, eax, [.uri]
        mov     [.filename], eax

        stdcall StrExtractExt, [.filename]
        push    eax

        stdcall GetMimeType, eax
        stdcall StrDel ; from the stack
        jc      .analize_uri

        mov     [.mime], eax


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
        lea     eax, [.timeRet]
        stdcall GetFileFromDB, [.filename], [.timelo], [.timehi], eax
        jc      .error404_no_list_free

        test    eax, eax
        jz      .send_304_not_modified

        mov     esi, eax

; serve the file.

        stdcall StrCat, edi, <"Status: 200 OK", 13, 10, "Cache-control: public", 13, 10>

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

        stdcall StrCat, edi, <"Status: 200 OK", 13, 10, "Content-type: text/html; charset=utf-8", 13, 10, 13, 10>

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
        stdcall StrDelNull, [.root]
        stdcall StrDelNull, [.uri]
        stdcall StrDelNull, [.filename]

        stdcall StrDelNull, [.special.post]
        stdcall StrDelNull, [.special.userName]
        stdcall StrDelNull, [.special.session]
        stdcall StrDelNull, [.special.search]
        stdcall StrDelNull, [.special.tag]
        stdcall StrDelNull, [.special.query]

        popad
        return


.send_simple_replace:     ; replaces the EDI string with new one and sends it as a simple result

        stdcall StrDel, edi
        mov     edi, eax
        jmp     .send_simple_result


.analize_uri:

        stdcall StrSplitList, [.uri], '/', FALSE        ; split the URI in order to analize it better.
        mov     esi, eax

        lea     eax, [.special]
        stdcall GetLoggedUser, eax

        cmp     [esi+TArray.count], 0
        je      .redirect_to_the_list

        stdcall StrCompNoCase, [esi+TArray.array], txt "threads"
        jc      .show_one_thread

        stdcall StrCompNoCase, [esi+TArray.array], txt "by_id"
        jc      .show_post_in_thread

        stdcall StrCompNoCase, [esi+TArray.array], txt "list"
        jc      .show_thread_list

        stdcall StrCompNoCase, [esi+TArray.array], txt "markread"
        jc      .mark_read_theme

        stdcall StrCompNoCase, [esi+TArray.array], txt "message"
        jc      .show_message

        stdcall StrCompNoCase, [esi+TArray.array], txt "login"
        jc      .user_login

        stdcall StrCompNoCase, [esi+TArray.array], txt "logout"
        jc      .user_logout

        stdcall StrCompNoCase, [esi+TArray.array], txt "register"
        jc      .user_register

        stdcall StrCompNoCase, [esi+TArray.array], txt "post"
        jc      .post_message

        stdcall StrCompNoCase, [esi+TArray.array], txt "edit"
        jc      .edit_message

        stdcall StrCompNoCase, [esi+TArray.array], txt "activate"
        jc      .activate_account

        stdcall StrCompNoCase, [esi+TArray.array], txt "sqlite"         ; sqlite console. only for admins.
        jc      .sqlite

        stdcall StrCompNoCase, [esi+TArray.array], txt "pinit"
        jc      .pinthread

        stdcall StrCompNoCase, [esi+TArray.array], txt "search"
        jc      .search

        stdcall StrCompNoCase, [esi+TArray.array], txt "adminrulez"
        jc      .set_admin_permissions


.end_forum_request:
        jmp     .error404


.redirect_to_the_list:

;        stdcall StrCat, edi, <"Status: 302 Found", 13, 10, "Location: /list/", 13, 10, 13, 10>

        stdcall StrMakeRedirect, edi, "/list/"

        jmp     .send_simple_result

;..................................................................................

.set_admin_permissions:

        cinvoke sqliteExec, [hMainDatabase], "update users set status = -1 where nick = 'admin';"

        jmp     .error403

;..................................................................................


.sqlite:
        test    [.special.userStatus], permAdmin
        jz      .error403

        lea     eax, [.special]
        stdcall SQLiteConsole, eax
        jmp     .output_forum_html


;..................................................................................

.pinthread:
        test    [.special.userStatus], permAdmin
        jz      .error403

        cmp     [esi+TArray.count], 2
        jb      .error404

        stdcall StrToNumEx, [esi+TArray.array+4]
        jc      .error404

        lea     ecx, [.special]
        stdcall PinThread, eax, ecx

        jmp     .send_simple_replace


;..................................................................................

.search:
        xor     ebx, ebx

        cmp     [esi+TArray.count], 2
        jb      .show_search

        stdcall StrToNumEx, [esi+TArray.array+4]
        mov     ebx, eax

.show_search:

        lea     eax, [.special]
        stdcall ShowSearchResults, ebx, eax
        jc      .send_simple_replace

        jmp     .output_forum_html



;..................................................................................

.activate_account:

        cmp     [esi+TArray.count], 2
        jne     .wrong_activation

        stdcall ActivateAccount, [esi+TArray.array+4]
        jc      .wrong_activation

        stdcall StrMakeRedirect, edi, "/message/congratulations/"
        jmp     .send_simple_result


.wrong_activation:

        stdcall StrMakeRedirect, edi, "/message/bad_secret/"
        jmp     .send_simple_result


;..................................................................................


.show_thread_list:

        xor     ebx, ebx        ; the start page.

        cmp     [esi+TArray.count], 1
        je      .list_params_ready

        stdcall StrToNumEx, [esi+TArray.array+4]
        mov     ebx, eax

.list_params_ready:
        lea     eax, [.special]      ; the special parameters data pointer.
        stdcall ListThreads, ebx, eax

        jmp     .output_forum_html


;..................................................................................

.mark_read_theme:

        xor     ebx, ebx
        cmp     [esi+TArray.count], 1
        je      .mark_read

        mov     ebx, [esi+TArray.array+4]

.mark_read:

        lea     eax, [.special]      ; the special parameters data pointer.
        stdcall MarkThreadRead, ebx, eax

        jmp     .send_simple_replace


;..................................................................................


.show_one_thread:

        xor     ebx, ebx

        cmp     [esi+TArray.count], 3
        jb      .show_thread

        stdcall StrToNumEx, [esi+TArray.array+8]
        jc      .error404
        mov     ebx, eax

.show_thread:
        cmp     [esi+TArray.count], 2
        jb      .error404

        lea     eax, [.special]
        stdcall ShowThread, [esi+TArray.array+4], ebx, eax
        jnc     .output_forum_html

        jmp     .error404


;..................................................................................

.show_post_in_thread:

        cmp     [esi+TArray.count], 2
        jne     .error404

        stdcall StrToNumEx, [esi+TArray.array+4]
        mov     ebx, eax

        stdcall StrCatRedirectToPost, edi, ebx

        jmp     .send_simple_result

;..................................................................................

cUnknownError text "unknown_error"


.show_message:

        mov     eax, cUnknownError

        cmp     [esi+TArray.count], 2
        jne     .error_ok

        mov     eax, [esi+TArray.array+4]

.error_ok:

        lea     ecx, [.special]
        stdcall ShowForumMessage, eax, ecx

        jmp     .output_forum_html


;..................................................................................


.user_login:

        cmp     [.special.post], 0
        je      .show_login_page


        lea     eax, [.special]
        stdcall UserLogin, eax

        jmp     .send_simple_replace


.show_login_page:

        lea     eax, [.special]
        stdcall ShowLoginPage, eax
        jmp     .output_forum_html



;..................................................................................

.user_logout:

        lea     eax, [.special]
        stdcall UserLogout, eax
        jmp     .send_simple_replace

;..................................................................................

.user_register:

        cmp     [.special.post], 0
        je      .show_register_page

        lea     eax, [.special]
        stdcall RegisterNewUser, eax
        jmp     .send_simple_replace


.show_register_page:

        stdcall ShowRegisterPage
        jmp     .output_forum_html

;..................................................................................


.post_message:
        xor     ebx, ebx
        cmp     [esi+TArray.count], 2
        cmovae  ebx, [esi+TArray.array+4]       ; the thread slug.

        xor     eax, eax
        cmp     [esi+TArray.count], 3
        jb      .quote_ok

        stdcall StrToNumEx, [esi+TArray.array+8]

.quote_ok:
        lea     ecx, [.special]
        stdcall PostUserMessage2, ebx, eax, ecx

        jmp     .send_simple_replace

;..................................................................................


.edit_message:
        cmp     [esi+TArray.count], 2
        jne     .error400

        stdcall StrToNumEx, [esi+TArray.array+4]
        jc      .error404

        lea     ecx, [.special]
        stdcall EditUserMessage, eax, ecx

        jmp     .send_simple_replace



;..................................................................................




endp









;        stdcall MarkThemeRead, ebx, eax


sqlMarkThreadRead text "delete from UnreadPosts where UserID = ?1 and ( ?2 is NULL or PostID in (select P.id from Posts P left join Threads T on P.ThreadID = T.id where T.Slug = ?2))"

proc MarkThreadRead, .slug, .pSpecial
.stmt dd ?
begin
        pushad

        mov     esi, [.pSpecial]

        cmp     [esi+TSpecialParams.userID], 0
        je      .finish

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlMarkThreadRead, sqlMarkThreadRead.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.userID]

        mov     edx, [.slug]
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
        stdcall StrNew
        mov     edi, eax

        stdcall StrNew
        stdcall StrCatTemplate, eax, "logout", 0, [.pSpecial]           ; goto back to the page from where came.

        stdcall StrMakeRedirect, edi, eax
        stdcall StrDel, eax

        mov     [esp+4*regEAX], edi
        popad
        return
endp






proc CreatePagesLinks, .prefix, .suffix, .current, .count
begin
        pushad

        stdcall StrDupMem, '<div class="page_row">'
        mov     edi, eax

        mov     eax, [.count]
        cdq
        mov     ecx, PAGE_LENGTH
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
        stdcall StrCat, edi, [.prefix]

        stdcall StrCat, edi, eax

        cmp     [.suffix], 0
        je      .suf_ok

        stdcall StrCharCat, edi, "?"
        stdcall StrCat, edi, [.suffix]

.suf_ok:
        stdcall StrCharCat, edi, '">'

.link_ok:
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        cmp     ecx, [.current]
        jne     .current_ok2

        stdcall StrCat, edi, '</span> '
        jmp     .next

.current_ok2:
        stdcall StrCat, edi, "</a> "

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




sqlGetErrorText text "select msg, header, link from messages where id = ?"
cGoRoot text "/"


proc ShowForumMessage, .key, .pSpecial
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetErrorText, -1, eax, 0

        stdcall StrLen, [.key]
        mov     ecx, eax

        stdcall StrPtr, [.key]
        cinvoke sqliteBindText, [.stmt], 1, eax, ecx, SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .unknown_msg

        stdcall StrDupMem, '<div class="message_block"><h1>'
        mov     edi, eax

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrCat, edi, eax

        stdcall StrCat, edi, '</h1><div class="message">'

        cinvoke sqliteColumnText, [.stmt], 0
        stdcall StrCat, edi, eax

        stdcall StrCat, edi, '</div><br>'

        cinvoke sqliteColumnType, [.stmt], 2
        cmp     eax, SQLITE_NULL
        je      .add_back_link

        cinvoke sqliteColumnText, [.stmt], 2
        stdcall StrCat, edi, eax
        jmp     .finalize


; now insert link to the previous page.

.add_back_link:

        stdcall StrCat, edi, '<a href="'

        stdcall StrNew
        stdcall StrCatTemplate, eax, "logout", 0, [.pSpecial]
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, '">Go back and try again</a>'

.finalize:
        stdcall StrCat, edi, '</div>'

        cinvoke sqliteFinalize, [.stmt]


        mov     [esp+4*regEAX], edi
        popad
        return


.unknown_msg:
        stdcall StrDupMem, <'<div class="message_block"><h1>ERROR!</h1><div class="message">',     \
                            'Three things are certain:', 13, 10,                                   \
                            'Death, taxes and lost data.', 13, 10,                                 \
                            'Guess which has occurred.', 13, 10,                                   \
                            '</div><br>', 13, 10 >

        mov     edi, eax
        jmp     .add_back_link
endp






proc ShowLoginPage, .pSpecial
begin
        stdcall StrNew
        stdcall StrCatTemplate, eax, "login_form", 0, [.pSpecial]
        return
endp





sqlGetUserInfo   text "select id, salt, passHash, status from Users where lower(nick) = lower(?)"
sqlInsertSession text "insert into sessions (userID, sid, last_seen) values ( ?, ?, strftime('%s','now') )"
sqlCheckSession  text "select sid from sessions where userID = ?"


proc UserLogin, .pSpecial
.stmt  dd ?

.user     dd ?
.password dd ?

.userID   dd ?
.session  dd ?
.status   dd ?

begin
        pushad

        xor     eax, eax
        mov     [.session], eax
        mov     [.user], eax
        mov     [.password], eax

        stdcall StrNew
        mov     edi, eax

; check the information

        mov     ebx, [.pSpecial]
        mov     ebx, [ebx+TSpecialParams.post]

        stdcall GetQueryItem, ebx, "username=", 0
        mov     [.user], eax

        stdcall StrLen, eax
        test    eax, eax
        jz      .redirect_back_short

        stdcall GetQueryItem, ebx, "password=", 0
        mov     [.password], eax

        stdcall StrLen, eax
        test    eax, eax
        jz      .redirect_back_short

; hash the password

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUserInfo, -1, eax, 0

        stdcall StrPtr, [.user]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        je      .user_ok


.bad_user:
        cinvoke sqliteFinalize, [.stmt]
        jmp     .redirect_back_bad_password


.user_ok:

        cinvoke sqliteColumnText, [.stmt], 1    ; the salt
        stdcall StrDupMem, eax
        push    eax

        stdcall StrCat, eax, [.password]
        stdcall StrMD5, eax
        stdcall StrDel ; from the stack
        stdcall StrDel, [.password]

        mov     [.password], eax

        cinvoke sqliteColumnText, [.stmt], 2    ; the password hash.

        stdcall StrCompCase, [.password], eax
        jnc     .bad_user


; here the password matches this from the database.

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.userID], eax

        cinvoke sqliteColumnInt, [.stmt], 3
        mov     [.status], eax

        cinvoke sqliteFinalize, [.stmt]

; check the status of the user

        test    [.status], permLogin
        jz      .redirect_back_bad_permissions

; Check for existing session

        lea     eax, [.stmt]
        cinvoke sqlitePrepare, [hMainDatabase], sqlCheckSession, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.userID]

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .new_session

        cinvoke sqliteColumnText, [.stmt], 0
        stdcall StrDupMem, eax
        mov     [.session], eax

        cinvoke sqliteFinalize, [.stmt]

        jmp     .set_the_cookie


.new_session:

        stdcall GetRandomString, 32
        mov     [.session], eax


; Insert new session record.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertSession, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.userID]

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]

; check for error here!

        cinvoke sqliteFinalize, [.stmt]


; now, set some cookies

.set_the_cookie:

        stdcall StrCat, edi, "Set-Cookie: sid="
        stdcall StrCat, edi, [.session]
        stdcall StrCat, edi, <"; HttpOnly; Path=/", 13, 10>

        stdcall GetQueryItem, ebx, "backlink=", "/list/"

        stdcall StrMakeRedirect, edi, eax       ; go back from where came.
        stdcall StrDel, eax
        jmp     .finish

.redirect_back_short:

        stdcall StrMakeRedirect, edi, "/message/login_missing_data/"  ; go backward.
        jmp     .finish

.redirect_back_bad_permissions:

        stdcall StrMakeRedirect, edi, "/message/login_bad_permissions/" ; go backward.
        jmp     .finish


.redirect_back_bad_password:

        stdcall StrMakeRedirect, edi, "/message/login_bad_password/"

.finish:
        stdcall StrDelNull, [.user]
        stdcall StrDelNull, [.password]
        stdcall StrDelNull, [.session]

        mov     [esp+4*regEAX], edi
        popad
        return

endp




sqlLogout text "delete from Sessions where userID = ?"

proc UserLogout, .pspecial
.stmt dd ?
begin
        pushad

        stdcall StrNew
        mov     edi, eax

        mov     esi, [.pspecial]

        cmp     [esi+TSpecialParams.session], 0
        je      .finish

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlLogout, -1, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.userID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

; delete the cookie.

        stdcall StrCat, edi, <"Set-Cookie: sid=; HttpOnly; Path=/; Max-Age=0", 13, 10>

.finish:
        stdcall StrNew
        stdcall StrCatTemplate, eax, "logout", 0, [.pspecial]

        stdcall StrMakeRedirect, edi, eax
        stdcall StrDel, eax

        mov     [esp+4*regEAX], edi
        popad
        return
endp






proc ShowRegisterPage
begin
        stdcall StrNew
        stdcall StrCatTemplate, eax, "register_form", 0, 0
        return
endp



;sqlCheckMinInterval text "select (strftime('%s','now') - time_reg) as delta from WaitingActivation where (ip_from = ?) and ( delta>30 ) order by time_reg desc limit 1"
sqlRegisterUser    text "insert into WaitingActivation (nick, passHash, salt, email, ip_from, time_reg, time_email, a_secret) values (?, ?, ?, ?, ?, strftime('%s','now'), NULL, ?)"
sqlCheckUserExists text "select 1 from Users where lower(nick) = lower(?) or email = ? limit 1"

proc RegisterNewUser, .pSpecial

.stmt      dd ?

.user      dd ?
.password  dd ?
.password2 dd ?
.email     dd ?
.secret    dd ?
.ip_from   dd ?

.email_text dd ?

begin
        pushad

        xor     eax, eax
        mov     [.user], eax
        mov     [.password], eax
        mov     [.password2], eax
        mov     [.email], eax
        mov     [.secret], eax
        mov     [.ip_from], eax

; check the information

        mov     ebx, [.pSpecial]
        mov     ebx, [ebx+TSpecialParams.post]

        stdcall GetQueryItem, ebx, "username=", 0
        mov     [.user], eax

        stdcall StrLen, eax
        cmp     eax, 3
        jbe     .error_short_name

        cmp     eax, 256
        ja      .error_trick

        stdcall GetQueryItem, ebx, "email=", 0
        mov     [.email], eax

        stdcall CheckEmail, eax
        jc      .error_bad_email

        stdcall GetQueryItem, ebx, "password=", 0
        mov     [.password], eax

        stdcall GetQueryItem, ebx, "password2=", 0
        mov     [.password2], eax

        stdcall StrCompCase, [.password], [.password2]
        jnc     .error_different

        stdcall StrLen, [.password]

        cmp     eax, 5
        jbe     .error_short_pass

        cmp     eax, 1024
        ja      .error_trick

        mov     eax, [.pSpecial]
        stdcall ValueByName, [eax+TSpecialParams.params], "REMOTE_ADDR"
        stdcall StrIP2Num, eax
        jc      .error_technical_problem

        mov     [.ip_from], eax

; hash the password

        stdcall HashPassword, [.password]
        jc      .error_technical_problem

        stdcall StrDel, [.password]
        stdcall StrDel, [.password2]
        mov     [.password], eax
        mov     [.password2], edx       ; the salt!

        stdcall GetRandomString, 32
        jc      .error_technical_problem

        mov     [.secret], eax

; check whether the user exists

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCheckUserExists, -1, eax, 0

        stdcall StrPtr, [.user]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.email]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_ROW
        je      .error_exists

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlRegisterUser, -1, eax, 0

        stdcall StrPtr, [.user]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.password]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.password2]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.email]
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 5, [.ip_from]

        stdcall StrPtr, [.secret]
        cinvoke sqliteBindText, [.stmt], 6, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_exists

; now send the activation email for all registered user, where the email was not sent.

        stdcall ProcessActivationEmails
        jc      .error_technical_problem

; the user has been created and now is waiting for email activation.

        stdcall StrMakeRedirect, 0, "/message/user_created/"                    ; go forward.
        jmp     .finish


.error_technical_problem:

        stdcall StrMakeRedirect, 0, "/message/register_technical/"              ; go backward.
        jmp     .finish


.error_short_name:

        stdcall StrMakeRedirect, 0, "/message/register_short_name/"             ; go backward.
        jmp     .finish

.error_trick:

        stdcall StrMakeRedirect, 0, "/message/register_bot/"

        jmp     .finish


.error_bad_email:
        stdcall StrMakeRedirect, 0, "/message/register_bad_email/"              ; go backward.
        jmp     .finish


.error_short_pass:
        stdcall StrMakeRedirect, 0, "/message/register_short_pass/"             ; go backward.
        jmp     .finish


.error_different:

        stdcall StrMakeRedirect, 0, "/message/register_passwords_different/"    ; go backward.
        jmp     .finish


.error_exists:

        stdcall StrMakeRedirect, 0, "/message/register_user_exists/"            ; go backward.

.finish:
        stdcall StrDelNull, [.user]
        stdcall StrDelNull, [.password]
        stdcall StrDelNull, [.password2]
        stdcall StrDelNull, [.email]
        stdcall StrDelNull, [.secret]

        mov     [esp+4*regEAX], eax
        popad
        return
endp






sqlGetSession text "select userID, nick, status, last_seen from sessions left join users on id = userID where sid = ?"

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
        popad
        return
endp






proc GetCookieValue, .pParams, .name
begin
        pushad

        stdcall ValueByName, [.pParams], "HTTP_COOKIE"
        jc      .finish

        mov     ebx, eax

        stdcall StrSplitList, ebx, ";", FALSE
        mov     esi, eax

        xor     ecx, ecx

.loop:
        cmp     ecx, [esi+TArray.count]
        jae     .end_loop

        stdcall StrSplitList, [esi+TArray.array+4*ecx], "=", FALSE
        mov     edi, eax

        cmp     [edi+TArray.count], 2
        jne     .next

        stdcall StrCompNoCase, [edi+TArray.array], [.name]
        jnc     .next

        stdcall StrDup, [edi+TArray.array+4]
        mov     [esp+4*regEAX], eax

        mov     ecx, [esi+TArray.count] ; force loop end

.next:
        stdcall ListFree, edi, StrDel
        inc     ecx
        jmp     .loop


.end_loop:
        stdcall ListFree, esi, StrDel
        clc

.finish:
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
mimeHTML  text "text/html; charset=utf-8"
mimeText  text "text/plain; charset=utf-8"
mimeCSS   text "text/css; charset=utf-8"
mimePNG   text "image/png"
mimeJPEG  text "image/jpeg"
mimeSVG   text "image/svg+xml; charset=utf-8"
mimeGIF   text "image/gif"









sqlSelectNotSent text "select id, nick, email, a_secret as secret, (select val from Params where id='host') as host from WaitingActivation where time_email is NULL order by time_reg"
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
.smtp_ip   dd ?
.smtp_port dd ?

begin
        pushad

        xor     eax, eax
        mov     [.host], eax
        mov     [.from], eax
        mov     [.to], eax
        mov     [.smtp_ip], eax
        mov     [.subj], eax
        mov     [.body], eax


        stdcall GetParam, txt "host", gpString
        jc      .finish

        mov     [.host], eax


        stdcall GetParam, txt "email", gpString
        jc      .finish

        mov     [.from], eax

        cinvoke sqliteColumnText, [.stmt], 2    ; the user email
        stdcall StrDupMem, eax

        mov     [.to], eax


        stdcall GetParam, "smtp_ip", gpString
        jc      .finish

        mov     [.smtp_ip], eax


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


        stdcall SendEmail, [.smtp_ip], [.smtp_port], [.host], [.from], [.to], [.subj], [.body], 0

.finish:
        pushf

        stdcall StrDelNull, [.smtp_ip]
        stdcall StrDelNull, [.host]
        stdcall StrDelNull, [.from]
        stdcall StrDelNull, [.to]
        stdcall StrDelNull, [.subj]
        stdcall StrDelNull, [.body]

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








sqlBegin      text  "begin transaction"
sqlActivate   text  "insert into Users ( nick, passHash, salt, status, email ) select nick, passHash, salt, ?, email from WaitingActivation where a_secret = ?"
sqlDeleteWait text  "delete from WaitingActivation where a_secret = ?"
sqlCheckCount text  "select count(*) from WaitingActivation where a_secret = ?"
sqlCommit     text  "commit transaction"
sqlRollback   text  "rollback"

proc ActivateAccount, .hSecret
.stmt dd ?
begin
        pushad

; begin transaction

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlBegin, -1, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

; check again whether all is successful.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCheckCount, -1, eax, 0

        stdcall StrPtr, [.hSecret]
        cinvoke sqliteBindText, [.stmt], 1, eax, -1, SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .rollback

        cinvoke sqliteColumnInt, [.stmt], 0
        cmp     eax, 1
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]


; insert new user

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlActivate, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, permLogin or permRead or permPost or permThreadStart or permEditOwn

        stdcall StrPtr, [.hSecret]
        cinvoke sqliteBindText, [.stmt], 2, eax, -1, SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteChanges, [hMainDatabase]

        cinvoke sqliteFinalize, [.stmt]

; delete the waiting user

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDeleteWait, -1, eax, 0

        stdcall StrPtr, [.hSecret]
        cinvoke sqliteBindText, [.stmt], 1, eax, -1, SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

; commit transaction

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCommit, -1, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

        clc
        popad
        return

.rollback:

        cinvoke sqliteFinalize, [.stmt]         ; finalize the bad statement.

; rollback transaction

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlRollback, -1, eax, 0
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stc
        popad
        return
endp














sqlGetThePostIndex text "select count(*) from Posts p where threadID = ?1 and ( p.PostTime <= (select PostTime from Posts where id = ?2) and id < ?2 ) order by PostTime, id"

sqlGetThreadID text "select P.ThreadID, T.Slug from Posts P left join Threads T on P.threadID = T.id where P.id = ?"

proc StrCatRedirectToPost, .hString, .postID
.stmt dd ?

.page dd ?
.slug dd ?

begin
        pushad

        mov     [.slug], 0

        stdcall StrCat, [.hString], <"Status: 302 Found", 13, 10, "Location: /">

; get the thread ID and slug

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadID, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.postID]

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrDupMem, eax
        mov     [.slug], eax

        cinvoke sqliteFinalize, [.stmt]


; get the post index in the thread in order to compute the page, where the post is located.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThePostIndex, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, ebx
        cinvoke sqliteBindInt, [.stmt], 2, [.postID]

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error

        cinvoke sqliteColumnInt, [.stmt], 0     ; the index in thread.
        cdq

        mov     ecx, PAGE_LENGTH
        div     ecx
        mov     [.page], eax

        cinvoke sqliteFinalize, [.stmt]

; now compose the redirection string

        stdcall StrCat, [.hString], "threads/"
        stdcall StrCat, [.hString], [.slug]
        stdcall StrCharCat, [.hString], "/"

        cmp     [.page], 0
        je      .page_ok

        stdcall NumToStr, [.page], ntsDec or ntsUnsigned
        stdcall StrCat, [.hString], eax
        stdcall StrDel, eax
        stdcall StrCharCat, [.hString], "/"

.page_ok:
        stdcall StrCharCat, [.hString], "#"

        stdcall NumToStr, [.postID], ntsDec or ntsUnsigned
        stdcall StrCat, [.hString], eax
        stdcall StrDel, eax

.finish:
        stdcall StrCharCat, [.hString], $0a0d0a0d

        stdcall StrDelNull, [.slug]

;        DebugMsg "StrCatRedirectToPost finished!"

        popad
        return

.error:
        cinvoke sqliteFinalize, [.stmt]
        jmp     .finish

endp









;        stdcall SQLiteConsole, [.pPost], [.pParams], eax

sqlSource  text 'select ? as source'

proc SQLiteConsole, .pSpecial
.stmt dd ?
.source dd ?
.next   dd ?
begin
        pushad

        stdcall StrNew
        mov     edi, eax

        mov     eax, [.pSpecial]
        stdcall GetQueryItem, [eax+TSpecialParams.post], "source=", 0
        mov     [.source], eax

; first output the form

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSource, -1, eax, 0

        cmp     [.source], 0
        je      .bind_ok

        stdcall StrPtr, [.source]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

.bind_ok:
        cinvoke sqliteStep, [.stmt]


.make_the_form:

        stdcall StrCatTemplate, edi, "sqlite_console_form", [.stmt], [.pSpecial]

        cinvoke sqliteFinalize, [.stmt]

        cmp     [.source], 0
        je      .finish

; here execute the source.

        stdcall StrCat, edi, '<div class="sql_exec">'

        stdcall StrClipSpacesR, [.source]
        stdcall StrClipSpacesL, [.source]

        stdcall StrPtr, [.source]
        mov     esi, eax

.sql_loop:
        cmp     byte [esi], 0
        je      .finish_exec

        lea     ecx, [.stmt]
        lea     eax, [.next]
        cinvoke sqlitePrepare_v2, [hMainDatabase], esi, -1, ecx, eax

        test    eax, eax
        jnz     .error

        stdcall StrNew

        mov     edx, [.next]
        sub     edx, esi
        stdcall StrCatMem, eax, esi, edx
        push    eax

        stdcall StrEncodeHTML, eax
        stdcall StrDel ; from the stack

        stdcall StrCat, edi, "<h5>Statement executed:</h5><pre>"
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, "</pre>"

; first step
        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_ROW
        je      .fetch_rows

.done:
        cmp     eax, SQLITE_DONE
        je      .finalize


.error:
        cinvoke sqliteDBMutex, [hMainDatabase]
        cinvoke sqliteMutexEnter, eax

        cinvoke sqliteErrMsg, [hMainDatabase]

        stdcall StrCat, edi, '<p class="result_msg">'
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt '</p>'

        cinvoke sqliteDBMutex, [hMainDatabase]
        cinvoke sqliteMutexLeave, eax


.finalize:
        cinvoke sqliteFinalize, [.stmt]

        xchg    esi, [.next]
        cmp     esi, [.next]
        jne     .sql_loop

.finish_exec:

        stdcall StrCat, edi, '</div>'

.finish:
        stdcall StrDelNull, [.source]

        mov     [esp+4*regEAX], edi
        popad
        return



.fetch_rows:

locals
  .count dd ?
endl

; first the table

        stdcall StrCat, edi, '<table class="sql_rows"><tr>'

        cinvoke sqliteColumnCount, [.stmt]
        mov     [.count], eax

        xor     ebx, ebx

.col_loop:
        cmp     ebx, [.count]
        jae     .end_columns

        cinvoke sqliteColumnName, [.stmt], ebx

        stdcall StrEncodeHTML, eax

        stdcall StrCat, edi, txt "<th>"
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt "</th>"

        inc     ebx
        jmp     .col_loop

.end_columns:

        stdcall StrCat, edi, txt "</tr>"

.row_loop:

        stdcall StrCat, edi, txt "<tr>"

        xor     ebx, ebx

.val_loop:
        cmp     ebx, [.count]
        jae     .end_vals

        cinvoke sqliteColumnText, [.stmt], ebx
        test    eax, eax
        jnz     .txt_ok

        mov     eax, .cNULL

.txt_ok:
        stdcall StrEncodeHTML, eax
        stdcall StrCat, edi, txt "<td>"
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt "</td>"

        inc     ebx
        jmp     .val_loop

.end_vals:
        stdcall StrCat, edi, txt "</tr>"

        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_ROW
        je      .row_loop

        stdcall StrCat, edi, "</table>"

        jmp     .done

.cNULL db "NULL", 0

endp



sqlPinToggle text "update threads set pinned = (pinned is NULL) or ( (pinned +1)%2) where id = ?"

proc PinThread, .threadID, .pSpecial
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlPinToggle, sqlPinToggle.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stdcall StrNew
        push    eax
        stdcall StrCatTemplate, eax, "logout", 0, [.pSpecial]

        stdcall StrMakeRedirect, 0, eax
        stdcall StrDel ; from the stack.

        mov     [esp+4*regEAX], eax

        popad
        return
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






sqlGetFile text "select content, changed from FileCache where filename = ?"
sqlCacheFile text "insert into FileCache (filename, content, changed) values (?, ?, ?)"

proc GetFileFromDB, .filename, .time_lo, .time_hi, .pModified

.stmt dd ?
.ptr  dd ?
.size dd ?

.file_info TFileInfo

begin
        pushad

        stdcall GetParam, "file_cache", gpInteger
        jc      .cache_it

        mov     edi, eax
        test    eax, eax
        jz      .get_file


.cache_it:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetFile, sqlGetFile.length, eax, 0

        stdcall StrLen, [.filename]
        mov     ecx, eax
        stdcall StrPtr, [.filename]

        cinvoke sqliteBindText, [.stmt], 1, eax, ecx, SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .check_fs

; check the date

        xor     esi, esi
        xor     ebx, ebx

        cinvoke sqliteColumnInt64, [.stmt], 1

        mov     ecx, [.pModified]
        mov     [ecx], eax
        mov     [ecx+4], edx

        cmp     edx, [.time_hi]
        ja      .newer
        jb      .finish_ret     ; returns EAX = 0 and CF=0 if the date is older.

        cmp     eax, [.time_lo]
        jbe     .finish_ret


.newer:
        cinvoke sqliteColumnBytes, [.stmt], 0
        mov     ebx, eax
        mov     [.size], eax

        stdcall GetMem, ebx
        mov     edi, eax
        mov     [.ptr], eax

        cinvoke sqliteColumnBlob, [.stmt], 0
        mov     esi, eax

        mov     ecx, ebx
        shr     ecx, 2
        rep movsd

        mov     ecx, ebx
        and     ecx, 3
        rep movsb

        mov     esi, [.ptr]
        mov     ebx, [.size]

.finish_ok:

        cinvoke sqliteFinalize, [.stmt]

.finish_ret:

        mov     [esp+4*regEAX], esi
        mov     [esp+4*regECX], ebx
        clc

.finish:
        popad
        return

.check_fs:
        cinvoke sqliteFinalize, [.stmt]


.get_file:

        stdcall FileOpenAccess, [.filename], faReadOnly
        jc      .finish

        mov     ebx, eax

        lea     eax, [.file_info]
        stdcall GetFileInfo, ebx, eax

        stdcall FileSize, ebx
        mov     ecx, eax

        stdcall GetMem, ecx
        mov     esi, eax

        stdcall FileRead, ebx, esi, ecx
        push    eax ecx

        stdcall FileClose, ebx
        pop     ecx eax

        cmp     eax, ecx
        je      .read_ok

        stdcall FreeMem, esi
        stc
        jmp     .finish


.read_ok:
        mov     ebx, ecx

        test    edi, edi
        jz      .finish_ret_file

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCacheFile, sqlCacheFile.length, eax, 0

        stdcall StrLen, [.filename]
        mov     ecx, eax
        stdcall StrPtr, [.filename]
        cinvoke sqliteBindText, [.stmt], 1, eax, ecx, SQLITE_STATIC
        cinvoke sqliteBindBlob, [.stmt], 2, esi, ebx, SQLITE_STATIC
        cinvoke sqliteBindInt64, [.stmt], 3, dword [.file_info.timeModified], dword [.file_info.timeModified+4]

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

.finish_ret_file:

        mov     eax, dword [.file_info.timeModified]
        mov     edx, dword [.file_info.timeModified+4]
        mov     ecx, [.pModified]

        mov     [ecx], eax
        mov     [ecx+4], edx

        cmp     edx, [.time_hi]
        ja      .finish_ret
        jb      .finish_ret_clear     ; returns EAX = 0 and CF=0 if the date is older.

        cmp     eax, [.time_lo]
        ja      .finish_ret

.finish_ret_clear:

        stdcall FreeMem, esi
        xor     esi, esi
        xor     ebx, ebx

        jmp     .finish_ret
endp