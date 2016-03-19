

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
  .userID          dd ?
  .userName        dd ?
  .userStatus      dd ?
  .session         dd ?
ends




proc ServeOneRequest, .hSocket, .requestID, .pParams, .pPost, .start_time

.root dd ?
.uri  dd ?
.filename dd ?

.special TSpecialParams

begin
        pushad

        xor     eax, eax
        mov     [.root], eax
        mov     [.uri], eax
        mov     [.filename], eax

        mov     eax, [.start_time]
        mov     [.special.start_time], eax

        mov     eax, [.pParams]
        mov     [.special.params], eax

        lea     eax, [.special]
        stdcall GetLoggedUser, [.pParams], eax

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

        stdcall StrSplitList, [.uri], '/', FALSE        ; split the URI in order to analize it better.
        mov     esi, eax

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
        jc      .error404

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
        lea     eax, [.special]
        stdcall AppendError, edi, "400 Bad Request", eax
        jmp     .send_simple_result2                            ; without freeing the list in ESI!


.error403:
        lea     eax, [.special]
        stdcall AppendError, edi, "403 Forbidden", eax
        jmp     .send_simple_result


.error404:
        lea     eax, [.special]
        stdcall AppendError, edi, "404 Not Found", eax
        jmp     .send_simple_result



.output_forum_html:     ; Status: 200 OK

        stdcall StrCat, edi, <"Status: 200 OK", 13, 10, "Content-type: text/html", 13, 10, 13, 10>

        lea     edx, [.special]
        stdcall StrCatTemplate, edi, "main_html_start", 0, edx

        stdcall StrCat, edi, eax

        stdcall StrCatTemplate, edi, "main_html_end", 0, edx

        stdcall StrDel, eax


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

        stdcall StrDelNull, [.special.userName]

        clc
        popad
        return


.send_simple_replace:     ; replaces the EDI string with new one and sends it as a simple result

        stdcall StrDel, edi
        mov     edi, eax
        jmp     .send_simple_result


.analize_uri:

        OutputValue "Request count:", [esi+TArray.count], 10, -1

        cmp     [esi+TArray.count], 0
        je      .redirect_to_the_list

        stdcall StrCompNoCase, [esi+TArray.array], txt "threads"
        jc      .show_one_thread

        stdcall StrCompNoCase, [esi+TArray.array], txt "list"
        jc      .show_thread_list

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

        stdcall StrCompNoCase, [esi+TArray.array], txt "activate"
        jc      .activate_account


.end_forum_request:
        jmp     .error404


.redirect_to_the_list:

        stdcall StrCat, edi, <"Status: 302 Found", 13, 10, "Location: /list/", 13, 10, 13, 10>
        jmp     .send_simple_result



;..................................................................................

.activate_account:

        cmp     [esi+TArray.count], 2
        jne     .wrong_activation

        stdcall ActivateAccount, [esi+TArray.array+4]
        jc      .wrong_activation

        stdcall StrCat, edi, <"Status: 302 Found", 13, 10, "Location: /message/congratulations/", 13, 10, 13, 10>
        jmp     .send_simple_result


.wrong_activation:

        stdcall StrCat, edi, <"Status: 302 Found", 13, 10, "Location: /message/bad_secret/", 13, 10, 13, 10>
        jmp     .send_simple_result


;..................................................................................


.show_thread_list:

        xor     ebx, ebx        ; the start page.

        cmp     [esi+TArray.count], 1
        je      .list_params_ready

        stdcall StrToNum, [esi+TArray.array+4]
        cmp     eax, -1
        je      .page_ready

        mov     ebx, eax

.page_ready:


; here put some hash analizing code for the hash tags. Not implemented yet.


.list_params_ready:

        lea     eax, [.start_time]      ; the special parameters data pointer.

        stdcall ListThreads, ebx, eax

        jmp     .output_forum_html



;..................................................................................


.show_one_thread:

        xor     ebx, ebx

        cmp     [esi+TArray.count], 3
        jb      .show_thread

        stdcall StrToNum, [esi+TArray.array+8]
        mov     ebx, eax

.show_thread:
        lea     eax, [.start_time]
        stdcall ShowThread, [esi+TArray.array+4], ebx, eax

        jmp     .output_forum_html




;..................................................................................

cUnknownError text "unknown_error"


.show_message:

        mov     eax, cUnknownError

        cmp     [esi+TArray.count], 2
        jne     .error_ok

        mov     eax, [esi+TArray.array+4]

.error_ok:

        stdcall ShowForumMessage, eax, [.pParams]

        jmp     .output_forum_html


;..................................................................................


.user_login:

        cmp     [.pPost], 0
        je      .show_login_page


        stdcall UserLogin, [.pPost], [.pParams]
        jmp     .send_simple_replace


.show_login_page:

        stdcall ShowLoginPage
        jmp     .output_forum_html



;..................................................................................

.user_logout:

        lea     eax, [.special]
        stdcall UserLogout, eax
        jmp     .send_simple_replace

;..................................................................................

.user_register:

        cmp     [.pPost], 0
        je      .show_register_page

        stdcall RegisterNewUser, [.pPost], [.pParams]
        jmp     .send_simple_replace


.show_register_page:

        stdcall ShowRegisterPage
        jmp     .output_forum_html

;..................................................................................


.post_message:
        xor     ebx, ebx
        cmp     [esi+TArray.count], 2
        cmovae  ebx, [esi+TArray.array+4]       ; the thread slug.

        test    [.special.userStatus], permPost
        jz      .error_cant_post

        cmp     [esi+TArray.count], 2
        jae     .can_post

        test    [.special.userStatus], permThreadStart
        jz      .error_cant_start_threads

.can_post:
        cmp     [.pPost], 0
        je      .show_post_form

        lea     eax, [.special]
        stdcall PostUserMessage, ebx, [.pPost], eax
        jc      .error_cant_post

        OutputValue "Now redirect to post ID=", eax, 10, -1

        stdcall StrCatRedirectToPost, edi, eax
        jmp     .send_simple_result


.show_post_form:

        lea     ecx, [.special]
        stdcall ShowPostForm, ebx, 0, ecx
        jmp     .output_forum_html


.error_cant_post:
        stdcall StrCat, edi, <"Status: 302 Found", 13, 10, "Location: /message/error_cant_post/", 13, 10, 13, 10>
        jmp     .send_simple_result


.error_cant_start_threads:
        stdcall StrCat, edi, <"Status: 302 Found", 13, 10, "Location: /message/error_cant_create_threads/", 13, 10, 13, 10>
        jmp     .send_simple_result


;..................................................................................



endp




sqlSelectThreads text "select id, Slug, Caption, strftime('%d.%m.%Y %H:%M:%S', LastChanged, 'unixepoch') as TimeChanged, (select count() from posts where threadid = Threads.id) as PostCount from Threads order by LastChanged desc limit ? offset ?"
sqlThreadsCount  text "select count() from Threads"


proc ListThreads, .start, .p_special

.stmt  dd ?
.list  dd ?

begin
        pushad

        stdcall StrNew
        mov     edi, eax

        stdcall StrCat, edi, '<div class="threads_list">'

; navigation tool bar

        stdcall StrCatTemplate, edi, "nav_list", 0, 0


; links to the pages.
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlThreadsCount, -1, eax, 0
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        stdcall CreatePagesLinks, txt "/list/", [.start], ebx
        mov     [.list], eax

        stdcall StrCat, edi, eax

; now append the list itself.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectThreads, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, PAGE_LENGTH

        mov     eax, [.start]
        imul    eax, PAGE_LENGTH
        cinvoke sqliteBindInt, [.stmt], 2, eax

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish

        stdcall StrCatTemplate, edi, "thread_info", [.stmt], [.p_special]

        jmp     .loop


.finish:
        stdcall StrCat, edi, [.list]
        stdcall StrDel, [.list]
        stdcall StrCat, edi, "</div>"   ; div.threads_list

        cinvoke sqliteFinalize, [.stmt]

        mov     [esp+4*regEAX], edi
        popad
        return
endp








sqlSelectPosts   text "select Posts.id, Posts.threadID, strftime('%d.%m.%Y %H:%M:%S', Posts.postTime, 'unixepoch') as PostTime, Posts.Content, Users.id as UserID, Users.nick as UserName,",            \
                      "(select count() from Posts as X where X.userID = Posts.UserID) as UserPostCount from Posts left join Users on Users.id = Posts.userID where threadID = ? order by Posts.postTime, Posts.id limit ? offset ?"

sqlGetPostCount text "select count() from Posts where ThreadID = ?"

sqlGetThreadInfo text "select id, caption, slug from Threads where slug = ? limit 1"



proc ShowThread, .threadSlug, .start, .p_special

.stmt  dd ?

.threadID dd ?

.list dd ?

begin
        pushad

        stdcall StrNew
        mov     edi, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadInfo, -1, eax, 0

        stdcall StrPtr, [.threadSlug]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.threadID], eax

        stdcall StrCat, edi, '<div class="thread">'

        stdcall StrCatTemplate, edi, "nav_thread", [.stmt], [.p_special]

        stdcall StrCat, edi, '<h1 class="thread_caption">'

        cinvoke sqliteColumnText, [.stmt], 1

        stdcall StrDupMem, eax
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        stdcall StrCat, edi, '</h1>'

        cinvoke sqliteFinalize, [.stmt]


; pages links

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetPostCount, -1, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDup, txt "/threads/"
        stdcall StrCat, eax, [.threadSlug]
        stdcall StrCharCat, eax, "/"

        stdcall CreatePagesLinks, eax, [.start], ebx
        mov     [.list], eax

        stdcall StrCat, edi, [.list]


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectPosts, -1, eax, 0

        stdcall StrPtr, [.threadSlug]

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 2, PAGE_LENGTH

        mov     eax, [.start]
        imul    eax, PAGE_LENGTH
        cinvoke sqliteBindInt, [.stmt], 3, eax

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish

        stdcall StrCatTemplate, edi, "post_view", [.stmt], [.p_special]

        jmp     .loop


.finish:
        stdcall StrCat, edi, [.list]
        stdcall StrCat, edi, "</div>"   ; div.thread

        cinvoke sqliteFinalize, [.stmt]

        mov     [esp+4*regEAX], edi
        clc
        popad
        return

.error:
        DebugMsg "Error show thread."

        cinvoke sqliteFinalize, [.stmt]
        stdcall StrDel, edi
        stc
        popad
        return

endp








proc CreatePagesLinks, .prefix, .current, .count
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
        stdcall StrCharCat, edi, '/">'

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


proc ShowForumMessage, .key, .pParams
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

        stdcall ValueByName, [.pParams], "HTTP_REFERER"
        jnc     .referer_ok

        mov     eax, cGoRoot

.referer_ok:
        stdcall StrCat, edi, eax
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






proc ShowLoginPage
begin
        stdcall StrNew
        stdcall StrCatTemplate, eax, "login_form", 0, 0
        return
endp





sqlGetUserInfo   text "select id, salt, passHash, status from Users where lower(nick) = lower(?)"
sqlInsertSession text "insert into sessions (userID, sid, last_seen) values ( ?, ?, strftime('%s','now') )"
sqlCheckSession  text "select sid from sessions where userID = ?"


proc UserLogin, .pPost, .pParams
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

        stdcall StrDupMem, <"Status: 302 Found", 13, 10>
        mov     edi, eax

; check the information

        stdcall StrNew
        mov     ebx, eax

        mov     edx, [.pPost]
        lea     eax, [edx+TByteStream.data]
        stdcall StrCatMem, ebx, eax, [edx+TByteStream.size]

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
        stdcall StrCat, edi, <"Location: /list/", 13, 10, 13, 10>       ; go forward.

        jmp     .finish

.redirect_back_short:

        stdcall StrCat, edi, <"Location: /message/login_missing_data/", 13, 10, 13, 10>       ; go backward.
        jmp     .finish

.redirect_back_bad_permissions:

        stdcall StrCat, edi, <"Location: /message/login_bad_permissions/", 13, 10, 13, 10>       ; go backward.
        jmp     .finish


.redirect_back_bad_password:
        stdcall StrCat, edi, <"Location: /message/login_bad_password/", 13, 10, 13, 10>       ; go backward.


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

        stdcall StrDupMem, <"Status: 302 Found", 13, 10>
        mov     edi, eax

        mov     esi, [.pspecial]

        cmp     [esi+TSpecialParams.session], 0
        je      .finish

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlLogout, -1, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.userID]
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .finish

; delete the cookie.

        DebugMsg "Now delete the cookie!"

        stdcall StrCat, edi, <"Set-Cookie: sid=; HttpOnly; Path=/; Max-Age=0", 13, 10>

.finish:
        stdcall StrCat, edi, <"Location: /list/", 13, 10, 13, 10>       ; go forward.
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

proc RegisterNewUser, .pPost, .pParams

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

        stdcall StrDupMem, <"Status: 302 Found", 13, 10>
        mov     edi, eax

; check the information

        stdcall StrNew
        mov     ebx, eax

        mov     edx, [.pPost]
        lea     eax, [edx+TByteStream.data]
        stdcall StrCatMem, ebx, eax, [edx+TByteStream.size]

        stdcall GetQueryItem, ebx, "username=", 0
        mov     [.user], eax

        stdcall StrLen, eax
        cmp     eax, 3
        jbe     .error_short_name

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


        stdcall ValueByName, [.pParams], "REMOTE_ADDR"
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

        stdcall StrCat, edi, <"Location: /message/user_created/", 13, 10, 13, 10>       ; go forward.
        jmp     .finish


.error_technical_problem:
        stdcall StrCat, edi, <"Location: /message/register_technical/", 13, 10, 13, 10>       ; go backward.
        jmp     .finish


.error_short_name:
        stdcall StrCat, edi, <"Location: /message/register_short_name/", 13, 10, 13, 10>       ; go backward.
        jmp     .finish


.error_bad_email:
        stdcall StrCat, edi, <"Location: /message/register_bad_email/", 13, 10, 13, 10>       ; go backward.
        jmp     .finish


.error_short_pass:
        stdcall StrCat, edi, <"Location: /message/register_short_pass/", 13, 10, 13, 10>       ; go backward.
        jmp     .finish


.error_different:
        stdcall StrCat, edi, <"Location: /message/register_passwords_different/", 13, 10, 13, 10>       ; go backward.
        jmp     .finish


.error_exists:
        stdcall StrCat, edi, <"Location: /message/register_user_exists/", 13, 10, 13, 10>       ; go backward.


.finish:
        stdcall StrDelNull, [.user]
        stdcall StrDelNull, [.password]
        stdcall StrDelNull, [.password2]
        stdcall StrDelNull, [.email]
        stdcall StrDelNull, [.secret]

        mov     [esp+4*regEAX], edi
        popad
        return
endp






sqlGetSession text "select userID, nick, status, last_seen from sessions left join users on id = userID where sid = ?"

; returns:
;   EAX: string with the logged user name
;   ECX: string with the session ID
;   EDX: logged user ID

proc GetLoggedUser, .pParams, .special
.stmt dd ?
begin
        pushad

        mov     edi, [.special]

        xor     eax, eax
        mov     [edi+TSpecialParams.userID], eax
        mov     [edi+TSpecialParams.userName], eax
        mov     [edi+TSpecialParams.session], eax

        stdcall GetCookieValue, [.pParams], txt 'sid'
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
mimeHTML  text "text/html"
mimeText  text "text/plain"
mimeCSS   text "text/css"
mimePNG   text "image/png"
mimeJPEG  text "image/jpeg"
mimeSVG   text "image/svg+xml"
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








sqlInsertPost text "insert into Posts ( ThreadID, UserID, PostTime, Content) values (?, ?, strftime('%s','now'), ?)"
sqlUpdateThreads text "update Threads set LastChanged = strftime('%s','now') where id = ?"
sqlInsertThread text "insert into Threads ( Slug, Caption ) values (?, ?)"


; returns  EAX = Posts.id of the inserted/updated post.
;          CF =1 on error.

proc PostUserMessage, .hSlug, .pPost, .pSpecial
.stmt dd ?

.post    dd ?
.caption dd ?
.source  dd ?
.slug    dd ?

begin
        pushad

;        DebugMsg "Post user message!"

        xor     eax, eax
        mov     [.slug], eax
        mov     [.caption], eax
        mov     [.source], eax


        stdcall StrNew
        mov     [.post], eax

        mov     edx, [.pPost]
        lea     eax, [edx+TByteStream.data]
        stdcall StrCatMem, [.post], eax, [edx+TByteStream.size]

; begin transaction!

;        DebugMsg "Begin transaction"

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlBegin, -1, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

        cmp     [.hSlug], 0
        je      .new_thread

        stdcall StrDup, [.hSlug]
        mov     [.slug], eax

        jmp     .post_in_thread


; create new thread, from the post data

.new_thread:

;        DebugMsg "New thread started!"

        stdcall GetQueryItem, [.post], "title=", 0
        mov     [.caption], eax

        stdcall StrSlugify, [.caption]
        mov     [.slug], eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertThread, -1, eax, 0

;        OutputValue "Error prepade insert thread:", eax, 10, -1

        stdcall StrPtr, [.slug]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.caption]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]

;        OutputValue "Error insert thread:", eax, 10, -1

        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

;        DebugMsg "New thread created!"

.post_in_thread:

; get the thread id

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadInfo, -1, eax, 0

        stdcall StrPtr, [.slug]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .rollback

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]

; insert new post

;        DebugMsg "Now insert new post!"


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertPost, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, ebx

        mov     eax, [.pSpecial]
        cinvoke sqliteBindInt, [.stmt], 2, [eax+TSpecialParams.userID]

        stdcall GetQueryItem, [.post], "source=", 0
        mov     [.source], eax

        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

        cinvoke sqliteLastInsertRowID, [hMainDatabase]
        mov     [esp+4*regEAX], eax

;        OutputValue "Post inserted with ID=", eax, 10, -1

; Update thread LastChanged

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateThreads, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, ebx
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

;        DebugMsg "Transaction commited!"

        call    .cleanup
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

;        DebugMsg "Transaction rollback!"

        call    .cleanup
        stc
        popad
        return


.cleanup:
        stdcall StrDelNull, [.source]
        stdcall StrDelNull, [.caption]
        stdcall StrDelNull, [.slug]
        stdcall StrDel, [.post]

        retn

endp




;        stdcall ShowPostForm, esi, eax

cEditPostForm text "edit_form"
cNewThreadForm text "new_thread_form"

sqlSelectConst text "select ? as slug, ? as caption, ? as source"

proc ShowPostForm, .hSlug, .source, .pSpecial
.stmt dd ?
.caption dd ?
begin
        pushad

        and     [.caption], 0

        stdcall StrNew
        mov     edi, eax

; check the thread existence

        mov     esi, cNewThreadForm

        cmp     [.hSlug], 0
        je      .thread_ok

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadInfo, -1, eax, 0

        stdcall StrPtr, [.hSlug]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrDupMem, eax
        mov     [.caption], eax

        cinvoke sqliteFinalize, [.stmt]

        mov     esi, cEditPostForm


.thread_ok:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectConst, -1, eax, 0

        cmp     [.hSlug], 0
        je      .slug_ok

        stdcall StrPtr, [.hSlug]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

.slug_ok:
        cmp     [.caption], 0
        je      .caption_ok

        stdcall StrPtr, [.caption]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

.caption_ok:
        cmp     [.source], 0
        je      .source_ok

        stdcall StrPtr, [.source]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

.source_ok:

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error

        Output  "Form template used: "
        Output  esi
        DebugMsg

        stdcall StrCatTemplate, edi, esi, [.stmt], [.pSpecial]

.error:
        cinvoke sqliteFinalize, [.stmt]
        mov     [esp+4*regEAX], edi
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

        OutputValue "Prepare get post index:", eax, 10, -1

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

        OutputValue "The post is on page ", eax, 10, -1

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

        DebugMsg "StrCatRedirectToPost finished!"

        popad
        return

.error:
        cinvoke sqliteFinalize, [.stmt]
        jmp     .finish

endp





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

proc ServeOneRequestTest, .hSocket, .requestID, .pParams, .pPost, .p_special
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



