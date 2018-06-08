DEFAULT_PAGE_LENGTH = 20

; User permissions status flags:

permLogin       = 1
permPost        = 4
permThreadStart = 8
permEditOwn     = 16
permEditAll     = 32
permDelOwn      = 64
permDelAll      = 128
permChat        = 256

permAdmin       = $80000000



struct TSpecialParams
  .start_time      dd ?

  .hSocket         dd ?         ; the "low level" request data.
  .requestID       dd ?         ;

; request parameters

  .params          dd ?
  .post_array      dd ?

  .dir             dd ?                 ; /tag_name/
  .thread          dd ?                 ; /thread_slug/
  .page_num        dd ?                 ; /1234 - can be the number of the page, or the ID of a post.

  .cmd_list        dd ?         ; pointer to an array with splitted URL for analizing.
  .cmd_type        dd ?         ; 0 - no command, 1 - root cmd, 2 - top command

; forum global variables.

  .page_title      dd ?
  .page_header     dd ?
  .description     dd ?
  .keywords        dd ?
  .page_length     dd ?
  .setupmode       dd ?
  .pStyles         dd ?

; logged user info.

  .userID          dd ?
  .userName        dd ?
  .userStatus      dd ?

  .userLang        dd ?         ; not used right now.
  .userSkin        dd ?
  .session         dd ?
  .remoteIP        dd ?
  .remotePort      dd ?
ends


if used tablePreCommands

PList tablePreCommands, tpl_func,                  \
      "!avatar",          UserAvatar,              \
      "!login",           UserLogin,               \
      "!logout",          UserLogout,              \
      "!register",        RegisterNewUser,         \
      "!resetpassword",   ResetPassword,           \
      "!changepassword",  ChangePassword,          \
      "!changemail",      ChangeEmail,             \
      "!sqlite",          SQLiteConsole,           \
      "!settings",        BoardSettings,           \
      "!message",         ShowForumMessage,        \
      "!activate",        ActivateAccount,         \
      "!userinfo",        ShowUserInfo,            \
      "!avatar_upload",   UpdateUserAvatar,        \
      "!setskin",         UpdateUserSkin,          \
      "!render_all",      RenderAll,               \
      "!users_online",    UserActivityTable,       \
      "!chat",            ChatPage,                \
      "!chat_events",     ChatRealTime,            \
      "!echo_events",     EchoRealTime,            \    ; optional, depending on the options.DebugWebSSE
      "!postdebug",       PostDebug,               \    ; optional, depending on the options.DebugWeb
      "!debuginfo",       DebugInfo,               \    ; optional, depending on the options.DebugSQLite
      "!users",           UsersList,               \
      "!categories",      Categories
end if

if used tablePostCommands

PList tablePostCommands, tpl_func,                 \
      "!markread",        MarkThreadRead,          \
      "!post",            PostUserMessage,         \
      "!edit",            EditUserMessage,         \
      "!edit_thread",     EditThreadAttr,          \
      "!del",             DeletePost,              \
      "!by_id",           PostByID,                \
      "!history",         ShowHistory,             \
      "!restore",         RestorePost,             \
      "!search",          ShowSearchResults2
end if


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

        mov     eax, [.hSocket]
        mov     ecx, [.requestID]
        mov     [.special.hSocket], eax
        mov     [.special.requestID], ecx

        mov     eax, [.pParams2]
        mov     [.special.params], eax

        lea     eax, [.special]
        stdcall GetDefaultSkin, eax
        mov     [.special.userSkin], eax

        stdcall DecodePostData, [.pPost2], [.special.params]
        jc      .post_ok

        mov     [.special.post_array], eax

.post_ok:

        stdcall GetParam, "forum_title", gpString
        jnc     .title_ok

        stdcall StrDupMem, "AsmBB: "

.title_ok:
        mov     [.special.page_title], eax

        stdcall GetParam, "forum_header", gpString
        jnc     .header_ok

        stdcall StrDupMem, "AsmBB demo"

.header_ok:
        mov     [.special.page_header], eax

        stdcall GetParam, "desription", gpString
        jnc     .description_ok

        stdcall StrDupMem, txt "AsmBB forum demo installation."

.description_ok:
        mov     [.special.description], eax

        stdcall GetParam, "keywords", gpString
        jnc     .keywords_ok

        stdcall StrDupMem, txt "asmbb, asm, assembly, assembler, assembly language, forum, message board, buletin board"

.keywords_ok:
        mov     [.special.keywords], eax

        stdcall CreateArray, 4
        mov     [.special.pStyles], eax

        stdcall GetParam, 'page_length', gpInteger
        jnc     .page_length_ok

        mov     eax, DEFAULT_PAGE_LENGTH

.page_length_ok:
        mov     [.special.page_length], eax

        stdcall TextCreate, sizeof.TText
        mov     edx, eax

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

; check for skin redirection.

        stdcall StrPtr, [.uri]
        cmp     word [eax], "/~"
        je      .redirect_to_skin

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
        lea     eax, [.special]
        stdcall GetLoggedUser, eax

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

        lea     edi, [.date]
        stdcall DecodeHTTPDate, eax, edi
        jc      .get_file

        push    edx
        stdcall DateTimeToTime, edi
        mov     [.timelo], eax
        mov     [.timehi], edx
        pop     edx

.get_file:

        lea     eax, [.timeRet]
        lea     ecx, [.special]
        stdcall GetFileIfNewer, [.filename], [.timelo], [.timehi], eax, [.mime], ecx
        jc      .error404_no_list_free

        test    eax, eax
        jz      .send_304_not_modified

        mov     esi, eax

; serve the file.

        stdcall TextCat, edx, <"Cache-control: max-age=1000000", 13, 10>

        stdcall FormatHTTPTime, [.timeRet], [.timeRet+4]
        stdcall TextCat, edx, "Last-modified: "
        stdcall TextCat, edx, eax
        stdcall StrDel, eax

        stdcall TextCat, edx, <13, 10, "Content-type: ">
        stdcall TextCat, edx, [.mime]
        stdcall TextCat, edx, <txt 13, 10, 13, 10>

        stdcall FCGI_outputText, [.hSocket], [.requestID], edx, FALSE
        jc      .free_file

        stdcall FCGI_outputText, [.hSocket], [.requestID], esi, TRUE

.free_file:
        stdcall TextFree, esi
        jmp     .final_clean


.redirect_to_skin:

        lea     edi, [eax+2]

        lea     eax, [.special]
        stdcall GetLoggedUser, eax

        stdcall StrDup, [.special.userSkin]
        stdcall StrCat, eax, edi
        stdcall TextMakeRedirect, edx, eax
        stdcall StrDel, eax
        jmp     .send_simple_result

.send_304_not_modified:
        stdcall TextCat, edx, <"Status: 304 Not Modified", 13, 10, 13, 10>
        jmp     .send_simple_result


;.error500:
;        lea     eax, [.special]
;        stdcall AppendError, edx, "500 Unexpected server error", eax
;        jmp     .send_simple_result


.error400:
        lea     eax, [.special]
        stdcall AppendError, edx, "400 Bad Request", eax
        jmp     .send_simple_result


.error404_no_list_free:
        lea     eax, [.special]
        stdcall AppendError, edx, "404 Not Found", eax
        jmp     .send_simple_result



.error403:
        lea     eax, [.special]
        stdcall AppendError, edx, "403 Forbidden", eax
        jmp     .send_simple_result



.error404:
        lea     eax, [.special]
        stdcall AppendError, edx, "404 Not Found", eax
        jmp     .send_simple_result


.output_forum_html:     ; Status: 200 OK

        OutputValue "TText address to concatenate: ", eax, 16, 8

        push    eax eax ; store for use.

        stdcall TextCat, edx, <"Content-type: text/html; charset=utf-8", 13, 10, 13, 10>

        lea     edi, [.special]
        stdcall RenderTemplate, edx, "main_html_start.tpl", 0, edi
        mov     edx, eax

        stdcall TextAddText, edx, -1 ; source from the stack
        stdcall TextFree ; from the stack

        stdcall RenderTemplate, edx, "main_html_end.tpl", 0, edi
        mov     edx, eax


.send_simple_result:

        stdcall FCGI_outputText, [.hSocket], [.requestID], edx, TRUE

.final_clean:

        stdcall TextFree, edx
        stdcall StrDel, [.root]
        stdcall StrDel, [.uri]
        stdcall StrDel, [.filename]

        stdcall ListFree, [.special.cmd_list], StrDel
        stdcall ListFree, [.special.pStyles], StrDel

        stdcall StrDel, [.special.userName]
        stdcall StrDel, [.special.userSkin]
        stdcall StrDel, [.special.session]
        stdcall StrDel, [.special.dir]
        stdcall StrDel, [.special.thread]
        stdcall StrDel, [.special.page_title]
        stdcall StrDel, [.special.page_header]
        stdcall StrDel, [.special.description]
        stdcall StrDel, [.special.keywords]

        stdcall FreePostDataArray, [.special.post_array]

        popad
        return


.send_simple_replace:     ; replaces the EDI string with new one and sends it as a simple result

        stdcall TextFree, edx
        mov     edx, eax
        jmp     .send_simple_result


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.analize_uri:

;        DebugMsg "Analyze URL"

        stdcall StrSplitList, [.uri], '/', FALSE        ; split the URI in order to analize it better.
        mov     [.special.cmd_list], eax

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

        mov     [.special.cmd_type], 1

        stdcall SearchInHashTable, eax, tablePreCommands
        jnc     .is_it_command2

        stdcall StrDel, eax
        jmp     .exec_command

.is_it_tag:

        mov     [.special.cmd_type], 0

        stdcall InTags, eax
        jnc     .is_it_thread

        mov     [.special.dir], eax
        call    .pop_array_item
        jz      .show_thread_list


.is_it_thread:

        stdcall InThreads, eax
        jnc     .is_it_number

        mov     [.special.thread], eax
        call    .pop_array_item
        jz      .show_one_thread

.is_it_number:

        stdcall InNumbers, eax
        jc      .is_it_command

        mov     [.special.page_num], ecx
        stdcall StrDel, eax

        call    .pop_array_item
        jnz     .is_it_command

        cmp     [.special.thread], eax  ; eax==0 here
        je      .show_thread_list
        jmp     .show_one_thread


.is_it_command:

        push    eax
        stdcall StrPtr, eax
        cmp     byte [eax], '!'
        pop     eax
        jne     .bad_command

.is_it_command2:
        mov     [.special.cmd_type], 2

        stdcall SearchInHashTable, eax, tablePostCommands
        stdcall StrDel, eax
        jc      .exec_command
        jmp     .error404

.bad_command:
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
; On empty list, the ZF is set!
; On non empty list, ZF is cleared and eax is the next command from the list.
.pop_array_item:
        push    edx
        mov     edx, [.special.cmd_list]
        xor     eax, eax
        cmp     [edx+TArray.count], eax
        je      .end_pop

        mov     eax, [edx+TArray.array]
        stdcall DeleteArrayItems, edx, 0, 1
        mov     [.special.cmd_list], edx
        cmp     eax, edx        ; always not equal!

.end_pop:
        pop     edx
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

        stdcall TextMakeRedirect, 0, eax
        stdcall StrDel ; from the stack

        mov     [esp+4*regEAX], edi
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

        stdcall StrCat, edi, txt "."
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







sqlGetSession    text "select S.userID, U.nick, U.status, S.last_seen, U.Skin from sessions S left join users U on U.id = S.userID where S.sid = ?"
sqlGetUserExists text "select 1 from users limit 1"
SKIN_CHECK_FILE  text "/main_html_start.tpl"

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

        stdcall ValueByName, [edi+TSpecialParams.params], "REMOTE_PORT"
        jc      .port_ok

        stdcall StrToNumEx, eax
        mov     [edi+TSpecialParams.remotePort], eax


.port_ok:

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

; user skin

        cinvoke sqliteColumnText, [.stmt], 4
        test    eax, eax
        jz      .skin_ok

        push    eax

        stdcall StrDupMem, "/templates/"
        stdcall StrCat, eax ; from the stack
        mov     edx, eax

; check skin existence.

        stdcall StrDup, [hCurrentDir]
        push    eax
        stdcall StrCat, eax, edx
        stdcall StrCat, eax, SKIN_CHECK_FILE

        stdcall FileExists, eax
        stdcall StrDel ; from the stack
        jc      .free_skin

        xchg    edx, [edi+TSpecialParams.userSkin]

.free_skin:
        stdcall StrDel, edx

.skin_ok:

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
        jnc     .next

;.found:
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



; Returns the result in EDX

proc AppendError, .pText, .code, .special
begin
        push    eax
        mov     edx, [.pText]
        stdcall TextCat, edx, "Status: "
        stdcall TextCat, edx, [.code]
        stdcall TextCat, edx, <txt 13, 10>
        stdcall TextCat, edx, <"Content-type: text/html", 13, 10, 13, 10>

        stdcall RenderTemplate, edx, "error_html_start.tpl", 0, [.special]
        mov     edx, eax

        stdcall TextCat, edx, txt "<h1>"
        stdcall TextCat, edx, [.code]
        stdcall TextCat, edx, txt "</h1>"

        stdcall RenderTemplate, edx, "error_html_end.tpl", 0, [.special]
        mov     edx, eax
        pop     eax
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

        stdcall StrCompNoCase, [.extension], txt ".htm"
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

        mov     eax, mimeJS
        stdcall StrCompNoCase, [.extension], txt ".js"
        jc      .mime_ok

        mov     eax, mimeTTF
        stdcall StrCompNoCase, [.extension], txt ".ttf"
        jc      .mime_ok

        mov     eax, mimeMP3
        stdcall StrCompNoCase, [.extension], txt ".mp3"
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
mimeJS    text "text/javascript"
mimeText  text "text/plain; charset=utf-8"
mimeCSS   text "text/css; charset=utf-8"
mimePNG   text "image/png"
mimeJPEG  text "image/jpeg"
mimeSVG   text "image/svg+xml; charset=utf-8"
mimeGIF   text "image/gif"
mimeTTF   text "font/ttf"
mimeMP3   text "audio/mpeg"





sqlSelectNotSent text "select operation, nick, email, a_secret as secret, (select val from Params where id='host') as host, salt from WaitingActivation where time_email is NULL order by time_reg"
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


sqlUpdateEmailTime text "update WaitingActivation set time_email = strftime('%s','now') where a_secret = ?"

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

        stdcall RenderTemplate, 0, "activation_email_subject.tpl", [.stmt], 0
        mov     [.subj], eax

        stdcall RenderTemplate, 0, "activation_email_text.tpl", [.stmt], 0
        mov     [.body], eax

; now try to update the data of the record!

        lea     eax, [.stmt2]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateEmailTime, -1, eax, 0

        cinvoke sqliteColumnText, [.stmt], 3    ; secret
        cinvoke sqliteBindText, [.stmt2], 1, eax, -1, SQLITE_STATIC

        cinvoke sqliteStep, [.stmt2]
        push    eax
        cinvoke sqliteFinalize, [.stmt2]

        pop     eax
        cmp     eax, SQLITE_DONE
        jne     .error_update

        stdcall TextCompact, [.subj]
        stdcall TextCompact, [.body]

        stdcall SendEmail, [.smtp_addr], [.smtp_port], [.host], [.from], [.to], [.subj], [.body], 0
        stdcall LogEvent, "EmailSent", logText, eax, 0
        stdcall StrDel, eax

        clc

.finish:
        pushf

        stdcall StrDel, [.smtp_addr]
        stdcall StrDel, [.host]
        stdcall StrDel, [.from]
        stdcall StrDel, [.to]
        stdcall TextFree, [.subj]
        stdcall TextFree, [.body]

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
        jmp     .result

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



sqlInsertGuest          text "insert into Guests values (?1, strftime('%s','now'), ?2)"
sqlUpdateGuest          text "update Guests set LastSeen = strftime('%s','now'), Client = ?2 where addr = ?1"
sqlInsertGuestRequest   text "insert into GuestRequests values (?1, strftime('%s','now'), ?2, ?3, ?4, ?5)"
sqlClipGuests           text "delete from Guests where LastSeen < strftime('%s','now') - 864000"     ; 10 days = 864000 seconds

proc InsertGuest, .pSpecial
.stmt    dd ?
.client  dd ?
.method  dd ?
.request dd ?
.referer dd ?

begin
        pushad

        mov     esi, [.pSpecial]

        xor     eax, eax
        stdcall ValueByName, [esi+TSpecialParams.params], "HTTP_USER_AGENT"
        mov     [.client], eax

        xor     eax, eax
        stdcall ValueByName, [esi+TSpecialParams.params], "REQUEST_METHOD"
        mov     [.method], eax

        xor     eax, eax
        stdcall ValueByName, [esi+TSpecialParams.params], "REQUEST_URI"
        mov     [.request], eax

        xor     eax, eax
        stdcall ValueByName, [esi+TSpecialParams.params], "HTTP_REFERER"
        mov     [.referer], eax


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertGuest, sqlInsertGuest.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.remoteIP]
        cmp     [.client], 0
        je      @f
        stdcall StrPtr, [.client]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC
@@:
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        je      .row_ok

        cmp     ebx, SQLITE_CONSTRAINT
        jne     .finish

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateGuest, sqlUpdateGuest.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.remoteIP]
        cmp     [.client], 0
        je      @f
        stdcall StrPtr, [.client]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC
@@:
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

.row_ok:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertGuestRequest, sqlInsertGuestRequest.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.remoteIP]

        cmp     [.method], 0
        je      @f
        stdcall StrPtr, [.method]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC
@@:
        cmp     [.request], 0
        je      @f
        stdcall StrPtr, [.request]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC
@@:
        cmp     [.referer], 0
        je      @f
        stdcall StrPtr, [.referer]
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC
@@:
        cmp     [.client], 0
        je      @f
        stdcall StrPtr, [.client]
        cinvoke sqliteBindText, [.stmt], 5, eax, [eax+string.len], SQLITE_STATIC
@@:
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

.finish:
        cinvoke sqliteExec, [hMainDatabase], sqlClipGuests, 0, 0, 0
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



sqlInsertTicket text "insert into Tickets (ssn, time, ticket) values ((select id from sessions where sid=?1), strftime('%s','now'), ?2)"

proc SetUniqueTicket, .session
.stmt dd ?
begin
        pushad
        stdcall GetRandomString, 32
        mov     ebx, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertTicket, sqlInsertTicket.length, eax, 0

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

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



sqlClearTicket1 text "delete from Tickets where ticket = ?1"
sqlClearTicket2 text "delete from Tickets where time < strftime('%s','now')-14400"

proc ClearTicket3, .ticket
.stmt dd ?
begin
        pushad

        cmp     [.ticket], 0
        je      .cleanup_old

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlClearTicket1, sqlClearTicket1.length, eax, 0

        stdcall StrPtr, [.ticket]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

.cleanup_old:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlClearTicket2, sqlClearTicket2.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        popad
        return
endp




sqlCheckTicket text "select 1 from Tickets where ssn = (select id from sessions where sid=?1) and ticket = ?2"

; returns CF=1 if the check failed.
;         CF=0 if the check pass.

proc CheckTicket, .ticket, .session
.stmt dd ?
begin
        pushad

        cmp     [.ticket], 0
        je      .error

        cmp     [.session], 0
        je      .error

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCheckTicket, sqlCheckTicket.length, eax, 0

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.ticket]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC


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




proc GetFileIfNewer, .filename, .time_lo, .time_hi, .ptrRetModified, .mime, .pSpecial

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
        ja      .read_it

.finish_older:
        xor     esi, esi
        xor     ecx, ecx
        jmp     .read_ok

.read_it:
        stdcall FileSize, ebx
        mov     ecx, eax

        stdcall TextCreate, sizeof.TText
        mov     edx, eax

        stdcall TextSetGapSize, edx, ecx
        mov     [edx+TText.GapBegin], ecx

        stdcall FileRead, ebx, edx, ecx
        cmp     eax, ecx
        je      .read_file_ok

; read is not ok - return CF = 1
        stdcall TextFree, edx
        stc
        jmp     .finish_close

.read_file_ok:
        cmp     [.mime], mimeCSS
        jne     .read_ok

        stdcall RenderTemplate, edx, 0, 0, [.pSpecial]

.read_ok:
        mov     [esp+4*regEAX], edx
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
        push    eax
        stdcall StrToNumEx, [.hString]
        cmovnc   ecx, eax
        pop     eax
        return
endp


proc SearchInHashTable, .hName, .pTable
begin
        pushad

        stdcall StrPtr, [.hName]
        mov     esi, eax
        mov     edx, [eax+string.len]
        xor     ebx, ebx
        xor     ecx, ecx

.loop:
        cmp     ecx, edx
        je      .end_hash

        mov     al, [esi+ecx]
        mov     ah, al
        and     ah, $40
        shr     ah, 1
        or      al, ah  ; case insensitive hash function.

        xor     bl, al
        mov     bl, [ tpl_func + ebx]

        inc     ecx
        jmp     .loop

.end_hash:
        mov     edx, [.pTable]
        mov     eax, esi

.get_key_name:
        mov     edi, [edx + sizeof.TPHashItem*ebx + TPHashItem.pKeyname]
        test    edi, edi
        jz      .not_found

        mov     esi, eax
        mov     ecx, [esi+string.len]
        repe cmpsb
        je      .found

        inc     bl
        jmp     .get_key_name   ; collisions resolving.

.found:
        mov     ecx, [edx + sizeof.TPHashItem*ebx + TPHashItem.procCommand]
        mov     [esp+4*regECX], ecx
        stc
        popad
        return

.not_found:
        clc
        popad
        return
endp