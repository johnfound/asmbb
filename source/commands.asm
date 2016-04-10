PAGE_LENGTH = 20

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
  .params          dd ?
  .post            dd ?
;  .query           dd ?
;  .search          dd ?
;  .tag             dd ?
  .dir             dd ?
  .thread          dd ?
  .page_num        dd ?

  .userID          dd ?
  .userName        dd ?
  .userStatus      dd ?
  .userLang        dd ?
  .session         dd ?
  .setupmode       dd ?
  .page_title      dd ?
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

        stdcall GetParam, "forum_title", gpString
        jnc     .title_ok

        stdcall StrDupMem, "AsmBB: "

.title_ok:
        mov     [.special.page_title], eax

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

        stdcall ListFree, ebx, StrDel


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

        stdcall StrCat, edi, <"Status: 200 OK", 13, 10, "Cache-control: max-age=1000000", 13, 10>

        stdcall FormatHTTPTime, [.timeRet], [.timeRet+4]
        stdcall StrCat, edi, "Last-modified: "
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        stdcall StrCat, edi, <13, 10, "Content-type: ">
        stdcall StrCat, edi, [.mime]

        stdcall StrCat, edi, <13, 10, "Content-length: ">
        stdcall NumToStr, ecx, ntsDec or ntsUnsigned
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

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
        stdcall StrDel, [.root]
        stdcall StrDel, [.uri]
        stdcall StrDel, [.filename]

        stdcall StrDel, [.special.post]
        stdcall StrDel, [.special.userName]
        stdcall StrDel, [.special.session]
        stdcall StrDel, [.special.dir]
        stdcall StrDel, [.special.thread]
        stdcall StrDel, [.special.page_title]

        popad
        return


.send_simple_replace:     ; replaces the EDI string with new one and sends it as a simple result

        stdcall StrDel, edi
        mov     edi, eax
        jmp     .send_simple_result


.analize_uri:

;        DebugMsg "Analyze URL"

        stdcall StrSplitList, [.uri], '/', FALSE        ; split the URI in order to analize it better.
        mov     esi, eax

        lea     eax, [.special]
        stdcall GetLoggedUser, eax

        stdcall StrCompNoCase, [esi+TArray.array], txt "adminrulez"
        jc      .set_admin_account

        cmp     [.special.setupmode], 0
        jne     .settings




        call    .pop_array_item
        jz      .show_thread_list

; .is_it_tag:

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

        stdcall StrCompNoCase, eax, txt "by_id"
        jc      .show_post_in_thread

        stdcall StrCompNoCase, eax, txt "markread"
        jc      .mark_read_theme

        stdcall StrCompNoCase, eax, txt "message"
        jc      .show_message

        stdcall StrCompNoCase, eax, txt "login"
        jc      .user_login

        stdcall StrCompNoCase, eax, txt "logout"
        jc      .user_logout

        stdcall StrCompNoCase, eax, txt "register"
        jc      .user_register

        stdcall StrCompNoCase, eax, txt "activate"
        jc      .activate_account

        stdcall StrCompNoCase, eax, txt "changepassword"
        jc      .change_password

        stdcall StrCompNoCase, eax, txt "changemail"
        jc      .change_email

        stdcall StrCompNoCase, eax, txt "post"
        jc      .post_message

        stdcall StrCompNoCase, eax, txt "edit"
        jc      .edit_message

        stdcall StrCompNoCase, eax, txt "confirm"
        jc      .delete_confirm

        stdcall StrCompNoCase, eax, txt "del"
        jc      .delete_post

        stdcall StrCompNoCase, eax, txt "sqlite"         ; sqlite console. only for admins.
        jc      .sqlite

        stdcall StrCompNoCase, eax, txt "pinit"
        jc      .pinthread

        stdcall StrCompNoCase, eax, txt "search"
        jc      .search

        stdcall StrCompNoCase, eax, txt "userinfo"
        jc      .user_info

        stdcall StrCompNoCase, eax, txt "settings"
        jc      .settings


;        DebugMsg "Command not detected."


        jmp     .error404


.redirect_to_the_list:

        stdcall StrMakeRedirect, edi, "/list"

        jmp     .send_simple_result

;..................................................................................

.set_admin_account:

        cmp     [.special.setupmode], 0
        je      .error403

        lea     eax, [.special]
        stdcall CreateAdminAccount, eax

        jmp     .send_simple_replace

;..................................................................................


.sqlite:
        test    [.special.userStatus], permAdmin
        jz      .error403

        stdcall StrCat, [.special.page_title], "SQLite console"

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
        stdcall ShowSearchResults2, 0, ebx, eax
        jc      .send_simple_replace

        jmp     .output_forum_html



;..................................................................................


.show_thread_list:

        lea     eax, [.special]      ; the special parameters data pointer.
        stdcall ListThreads, eax

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

        lea     eax, [.special]
        stdcall ShowThread, eax
        jnc     .output_forum_html

        jmp     .error404


;..................................................................................

.show_post_in_thread:

        cmp     [esi+TArray.count], 2
        jne     .error404

        stdcall StrToNumEx, [esi+TArray.array+4]
        mov     ebx, eax

        stdcall StrCatRedirectToPost, edi, ebx, [.special.dir]

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

        stdcall StrCat, [.special.page_title], "Register new user"
        stdcall ShowRegisterPage
        jmp     .output_forum_html


;..................................................................................

.activate_account:

        cmp     [esi+TArray.count], 2
        jne     .error404

        stdcall ActivateAccount, [esi+TArray.array+4]

        jmp     .send_simple_replace

;..................................................................................


.change_password:

        cmp     [esi+TArray.count], 1
        jne     .error404

        lea     eax, [.special]
        stdcall ChangePassword, eax

        jmp     .send_simple_replace


;..................................................................................


.change_email:

        cmp     [esi+TArray.count], 1
        jne     .error404

        lea     eax, [.special]
        stdcall ChangeEmail, eax

        jmp     .send_simple_replace


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
        jne     .error404

        stdcall StrToNumEx, [esi+TArray.array+4]
        jc      .error404

        lea     ecx, [.special]
        stdcall EditUserMessage, eax, ecx

        jmp     .send_simple_replace


;..................................................................................

.delete_confirm:

        cmp     [esi+TArray.count], 2
        jne     .error404

        stdcall StrToNumEx, [esi+TArray.array+4]
        jc      .error404

        lea     ecx, [.special]

        stdcall DeleteConfirmation, eax, ecx
        jc      .send_simple_replace

        test    eax, eax
        jz      .error404

        jmp     .output_forum_html



.delete_post:

        cmp     [esi+TArray.count], 2
        jne     .error404

        stdcall StrToNumEx, [esi+TArray.array+4]
        jc      .error404

        lea     ecx, [.special]
        stdcall DeletePost, eax, ecx
        test    eax, eax
        jz      .error404

        jmp     .send_simple_replace


;..................................................................................


.user_info:

        cmp     [esi+TArray.count], 2
        jne     .error404

        stdcall StrToNumEx, [esi+TArray.array+4]
        jc      .error404

        lea     ecx, [.special]
        stdcall ShowUserInfo, eax, ecx
        jnc     .output_forum_html

        jmp     .send_simple_replace


;..................................................................................

.settings:
        cmp     [.special.setupmode], 0
        jne     .force_settings

        test    [.special.userStatus], permAdmin
        jz      .error403

.force_settings:
        lea     ecx, [.special]
        stdcall BoardSettings, ecx

        jnc     .output_forum_html

        jmp     .send_simple_replace




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
        stdcall StrCatTemplate, eax, "logout", 0, [.pSpecial]           ; goto back to the page from where came.
        push    eax

        stdcall StrMakeRedirect, 0, eax
        stdcall StrDel ; from the stack

        mov     [esp+4*regEAX], eax
        popad
        return
endp






proc CreatePagesLinks2, .current, .count
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
        stdcall StrCat, edi, eax
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
        stdcall StrCat, [esi+TSpecialParams.page_title], eax

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

        stdcall GetBackLink, [.pSpecial]
        pushf
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        popf
        jnc     .back

        stdcall StrCat, edi, '">Home</a>'
        jmp     .finalize

.back:
        stdcall StrCat, edi, '">Go back</a>'

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
        popad
        return
endp






proc GetCookieValue, .pParams, .name
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
        jnc     .next

; found
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











sqlGetThePostIndex text "select count(*) from Posts p where threadID = ?1 and ( p.PostTime <= (select PostTime from Posts where id = ?2) and id < ?2 ) order by PostTime, id"

sqlGetThreadID text "select P.ThreadID, T.Slug from Posts P left join Threads T on P.threadID = T.id where P.id = ?"

proc StrCatRedirectToPost, .hString, .postID, .dir
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

        cmp     [.dir], 0
        je      .dir_ok

        stdcall StrCat, edi, [.dir]
        stdcall StrCharCat, edi, "/"

.dir_ok:

        stdcall StrCat, [.hString], [.slug]

        cmp     [.page], 0
        je      .page_ok

        stdcall StrCharCat, [.hString], "/"
        stdcall NumToStr, [.page], ntsDec or ntsUnsigned
        stdcall StrCat, [.hString], eax
        stdcall StrDel, eax

.page_ok:
        stdcall StrCharCat, [.hString], "#"

        stdcall NumToStr, [.postID], ntsDec or ntsUnsigned
        stdcall StrCat, [.hString], eax
        stdcall StrDel, eax

.finish:

        stdcall StrCharCat, [.hString], $0a0d0a0d
        stdcall StrDel, [.slug]

        popad
        return

.error:
        cinvoke sqliteFinalize, [.stmt]
        jmp     .finish

endp










sqlPinToggle text "update threads set pinned = (pinned is NULL) or ( (pinned +1)%2) where id = ?"

proc PinThread, .threadID, .pSpecial
.stmt dd ?
begin
        pushad

        mov     esi, [.pSpecial]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlPinToggle, sqlPinToggle.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stdcall StrNew
        push    eax
        stdcall StrCatTemplate, eax, "logout", 0, esi

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
        jb      .finish_ok     ; returns EAX = 0 and CF=0 if the date is older.

        cmp     eax, [.time_lo]
        jbe     .finish_ok


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