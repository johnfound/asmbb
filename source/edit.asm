LIMIT_POST_LENGTH = 16*1024
LIMIT_POST_CAPTION = 512
LIMIT_TAG_DESCRIPTION = 1024


sqlReadPost    StripText "readpost.sql", SQL
sqlEditedPost  StripText "editedpost.sql", SQL

sqlGetPostUser    text "select userID, nick, threadID, (?1 = (select id from posts where threadid = P.threadid order by rowid limit 1)) as ThreadEdit from Posts P left join users U on U.id = P.userID where P.id = ?1"

sqlUpdatePinned         text "update threads set pinned = ?2 where id = ?1"
sqlUpdateThreadChanged  text "update Threads set LastChanged = strftime('%s','now') where id = ?1"


sqlCreatePost     text "insert into Posts(threadID, userID, postTime, format, content) values (?1, ?2, strftime('%s','now'), ?3, ?4)"
sqlSavePost       text "update Posts set content = ?4, format = ?3, editUserID = ?2, editTime = strftime('%s','now') where id = ?1"

sqlCreateThread   text "insert into Threads(userID) values (?1)"
sqlSaveThreadAttr text "update threads set slug = ?2, Caption = ?3, LastChanged = strftime('%s','now'), Limited = ?4 where id = ?1"

sqlThreadFirstPost text "select id from Posts where threadid = ?1 order by rowid limit 1"

sqlGetQuote      text "select U.nick, P.content, P.format from Posts P left join Users U on U.id = P.userID where P.id = ?1"


proc EditUserMessage, .pSpecial
.stmt dd ?


.locdata:

; thread attributes

.threadID dd ?
.caption  dd ?
.slug     dd ?
.tags     dd ?
.invited  dd ?
.fLimited dd ?
.pinned   dd ?

; Post attributes

.postID   dd ?
.source   dd ?
.format   dd ?

; User attributes

.userID      dd ?
.userName    dd ?

; Other attributes

.fEditThread dd ?

.ticket      dd ?

.softPreview dd ?

.loclen = ($ - .locdata)/4

begin
        pushad

        DebugMsg "Edit user message."

        xor     eax, eax
        mov     ecx, .loclen
        lea     edi, [.locdata]
        rep stosd

        mov     esi, [.pSpecial]

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        mov     ebx, [esi+TSpecialParams.page_num]

        stdcall StrCompNoCase, [esi+TSpecialParams.cmd], txt "!edit"
        jnc     .quote

        mov     [.postID], ebx
        test    ebx, ebx
        jnz     .read_post_info
        jmp     .new_post

.quote:
        cmp     [esi+TSpecialParams.post_array], 0
        jne     .new_post  ; if POST, don't quote again.

; get the quoted text

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetQuote, sqlGetQuote.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, ebx    ; ebx == quoted post ID

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finalize_quote

        cinvoke sqliteColumnInt, [.stmt], 2     ; format.
        mov     [.format], eax

        test    eax, eax  ; MiniMag
        jz      .minimag_quote

;.bbcode_quote:
        pushx   txt "[/quote]", 13, 10
        pushx   txt "]"
        pushx   txt "[quote="
        jmp     .do_quote

.minimag_quote:
        pushx   txt 13, 10, ";end quote", 13, 10
        pushx   txt 13, 10
        pushx   ";quote "

.do_quote:
        stdcall StrDupMem       ; argument from the stack
        mov     [.source], eax          ; [.source] should be 0 at this point!!!

        cinvoke sqliteColumnText, [.stmt], 0    ; the user nick name.
        stdcall StrCat, [.source], eax

        stdcall StrCat, [.source]       ; the second argument from the stack.

        cinvoke sqliteColumnText, [.stmt], 1    ; the quoted post content.
        stdcall StrCat, [.source], eax

        stdcall StrCat, [.source]       ; the second argument from the stack.

.finalize_quote:

        cinvoke sqliteFinalize, [.stmt]

.new_post:
        mov     eax, [esi+TSpecialParams.userID]
        mov     [.userID], eax

        stdcall StrDup, [esi+TSpecialParams.userName]
        mov     [.userName], eax

        mov     [.fEditThread], 1       ; default edit thread on new post/new thread.

        cmp     [esi+TSpecialParams.thread], 0        ; the thread slug
        je      .check_permissions

; new post in existing thread

        DebugMsg "New post in existing thread."

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadID, -1, eax, 0
        stdcall StrPtr, [esi+TSpecialParams.thread]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_missing_post

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.threadID], eax

        cinvoke sqliteFinalize, [.stmt]

        mov     [.fEditThread], 0       ; on new post in existing thread the thread editor should be disabled. Only the first post in the thread edits the thread attributes.
        jmp     .check_permissions


.read_post_info:
; read the userID and threadID for the post.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetPostUser, -1, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.postID]
        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_ROW
        jne     .error_missing_post

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.userID], eax

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrDupMem, eax
        mov     [.userName], eax

        cinvoke sqliteColumnInt, [.stmt], 2
        mov     [.threadID], eax

        cinvoke sqliteColumnInt, [.stmt], 3
        mov     [.fEditThread], eax

        cinvoke sqliteFinalize, [.stmt]


.check_permissions:
; check the permissions.

        cmp     [.threadID], 0
        je      .limited_ok

        stdcall CheckLimitedAccess, [.threadID], [esi+TSpecialParams.userID]            ; Other users must have permission to view the thread in order to be able to edit it.
        jz      .error_wrong_permissions

.limited_ok:

        cmp     [.postID], 0
        jne     .check_edit_permissions

        cmp     [.threadID], 0
        je      .check_thread_start_permissions

; check posting permissions.

        test    [esi+TSpecialParams.userStatus], permPost or permAdmin
        jz      .error_wrong_permissions
        jmp     .new_post_permissions_ok

.check_thread_start_permissions:

        test    [esi+TSpecialParams.userStatus], permThreadStart or permAdmin
        jz      .error_wrong_permissions

.new_post_permissions_ok:

        stdcall LogUserActivity, esi, uaWritingPost, 0
        jmp     .permissions_ok

.check_edit_permissions:

        test    [esi+TSpecialParams.userStatus], permEditAll or permAdmin               ; the moderators have permission to edit limited access threads if they are invited.
        jnz     .edit_permissions_ok

        test    [esi+TSpecialParams.userStatus], permEditOwn                            ; all other can edit only their own posts and only if have permission to edit.
        jz      .error_wrong_permissions

        mov     eax, [.userID]
        cmp     eax, [esi+TSpecialParams.userID]
        jne     .error_wrong_permissions

.edit_permissions_ok:

        stdcall LogUserActivity, esi, uaEditingPost, 0

.permissions_ok:

        cmp     [esi+TSpecialParams.post_array], 0
        je      .show_edit_form

; ok, process the POST data:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "ticket", 0
        mov     [.ticket], eax

        cmp     [.fEditThread], 0
        je      .caption_ok

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "title", 0

        xchg    eax, [.caption]
        stdcall StrDel, eax

.caption_ok:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "tags", 0
        mov     [.tags], eax

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "invited", 0
        mov     [.invited], eax

        stdcall GetPostInt, [esi+TSpecialParams.post_array], txt "limited", 0
        mov     [.fLimited], eax

        stdcall GetPostInt, [esi+TSpecialParams.post_array], txt "pinned", 0
        mov     [.pinned], eax

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "source", 0
        mov     [.source], eax

        stdcall GetPostInt, [esi+TSpecialParams.post_array], txt "format", 0
        mov     [.format], eax

; check the post interval limits

        mov     ecx, [esi+TSpecialParams.userPostInterval]
        test    ecx, ecx
        jz      .interval_ok

        stdcall GetTime
        sub     eax, dword [esi+TSpecialParams.userLastPostTime]
        sbb     edx, dword [esi+TSpecialParams.userLastPostTime + 4]
        jnz     .show_edit_form

        cmp     eax, ecx
        jl      .show_edit_form

.interval_ok:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "submit", 0
        stdcall StrDel, eax
        test    eax, eax
        jnz     .save_post_and_exit

        stdcall ValueByName, [esi+TSpecialParams.params], "QUERY_STRING"
        mov     ebx, eax

        stdcall GetQueryItem, ebx, txt "cmd=", 0
        test    eax, eax
        jz      .show_edit_form

        stdcall StrCompNoCase, eax, "preview"
        stdcall StrDel, eax
        jnc     .show_edit_form

        inc     [.softPreview]

.show_edit_form:

        DebugMsg "SHOW edit form."

        cmp     [.ticket], 0
        jne     .ticket_ok

        stdcall SetUniqueTicket, [esi+TSpecialParams.session]
        jc      .error_bad_ticket

        mov     [.ticket], eax

.ticket_ok:
        mov     ecx, sqlEditedPost

        cmp     [esi+TSpecialParams.post_array], 0
        jne     .sql_ok

        cmp     [.postID], 0
        je      .sql_ok

        mov     ecx, sqlReadPost

.sql_ok:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], ecx, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.postID]

        stdcall StrPtr, [.ticket]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cmp     [.postID], 0
        je      .new_post_sql

        cmp     [esi+TSpecialParams.post_array], 0
        je      .parameters_ok

; Parameters only for sqlEditedPost

.new_post_sql:

        cinvoke sqliteBindInt, [.stmt], 3, [.threadID]

        stdcall StrPtr, [.caption]
        test    eax, eax
        jz      @f
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC
@@:

        stdcall StrPtr, [.tags]
        test    eax, eax
        jz      @f
        cinvoke sqliteBindText, [.stmt], 5, eax, [eax+string.len], SQLITE_STATIC
@@:

        stdcall StrPtr, [.invited]
        test    eax, eax
        jz      @f
        cinvoke sqliteBindText, [.stmt], 6, eax, [eax+string.len], SQLITE_STATIC
@@:

        cinvoke sqliteBindInt, [.stmt], 7, [.pinned]

        cinvoke sqliteBindInt, [.stmt], 8, [.fLimited]

        stdcall StrPtr, [.source]
        test    eax, eax
        jz      @f
        cinvoke sqliteBindText, [.stmt], 9, eax, [eax+string.len], SQLITE_STATIC
@@:
        cinvoke sqliteBindInt, [.stmt], 10, [.format]

        stdcall StrPtr, [.userName]
        cinvoke sqliteBindText, [.stmt], 11, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 12, [.fEditThread]

.parameters_ok:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_missing_post

        mov     eax, [esi+TSpecialParams.userLang]
        stdcall StrCat, [esi+TSpecialParams.page_title], [cEditingPageTitle+8*eax]

        cinvoke sqliteColumnText, [.stmt], 1 ; the thread caption.
        test    eax, eax
        jz      @f
        stdcall StrEncodeHTML, eax
        stdcall StrCat, [esi+TSpecialParams.page_title], eax
        stdcall StrDel, eax
@@:

; deal with the attachments:

        cmp     [esi+TSpecialParams.post_array], 0
        je      .attch_ok

        stdcall DelAttachments, [.postID], [.userID], esi
        stdcall WriteAttachments, [.postID], [.userID], esi

.attch_ok:
        shr     [.softPreview], 1
        jnc     .render_all

; JS call request:

        stdcall TextAddStr2, edi, 0, cHeadersJSON, cHeadersJSON.length

        stdcall RenderTemplate, edi, "edit.json", [.stmt], esi
        mov     edi, eax

        cinvoke sqliteFinalize, [.stmt]

        stc
        jmp     .finish

.render_all:
        stdcall RenderTemplate, edi, "form_edit.tpl", [.stmt], esi
        stdcall RenderTemplate, eax, "preview.tpl", [.stmt], esi
        mov     edi, eax

        cinvoke sqliteFinalize, [.stmt]

        clc
        jmp     .finish


;...............................................................................................

.save_post_and_exit:

        cmp     [.source], 0
        je      .show_edit_form

        stdcall CheckTicket, [.ticket], [esi+TSpecialParams.session]
        jc      .error_bad_ticket

; check the caption and create a slug

        cmp     [.fEditThread], 0
        je      @f

        cmp     [.caption], 0
        je      .show_edit_form

        stdcall StrByteUtf8, [.caption], LIMIT_POST_CAPTION
        stdcall StrTrim, [.caption], eax

@@:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlBegin, sqlBegin.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_write

        cinvoke sqliteFinalize, [.stmt]

        cmp     [.fEditThread], 0
        je      .thread_ok

; save the thread attributes

        cmp     [.threadID], 0
        jne     .save_thread_attr

; create new thread.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCreateThread, sqlCreateThread.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.userID]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_write

        cinvoke sqliteFinalize, [.stmt]

        cinvoke sqliteLastInsertRowID, [hMainDatabase]
        mov     [.threadID], eax

.save_thread_attr:

        stdcall StrSlugify, [.caption]
        mov     [.slug], eax

        stdcall NumToStr, [.threadID], ntsDec or ntsUnsigned
        stdcall StrCat, [.slug], txt "."
        stdcall StrCat, [.slug], eax
        stdcall StrDel, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSaveThreadAttr, sqlSaveThreadAttr.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]

        stdcall StrPtr, [.slug]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.caption]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 4, [.fLimited]

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_write            ; strange write fault.

        cinvoke sqliteFinalize, [.stmt]

.save_tags:
        stdcall SaveThreadTags, [.tags], [esi+TSpecialParams.dir], [.threadID]

; save the invited users

        stdcall SaveInvited, [.fLimited], [.invited], [esi+TSpecialParams.userName], [.threadID]

; save the pinned value in separate query. Only for admins!

        test    [esi+TSpecialParams.userStatus], permAdmin
        jz      .pinned_updated

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdatePinned, sqlUpdatePinned.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 2, [.pinned]
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_write

.pinned_updated:


.thread_ok:
; save the post content

        mov     edx, sqlSavePost
        mov     ecx, sqlSavePost.length

        cmp     [.postID], 0
        jne     .update_or_insert

        mov     edx, sqlCreatePost
        mov     ecx, sqlCreatePost.length

.update_or_insert:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], edx, ecx, eax, 0

        mov     ecx, [.postID]
        test    ecx, ecx
        cmovz   ecx, [.threadID]

        cinvoke sqliteBindInt, [.stmt], 1, ecx  ; threadID or postID
        cinvoke sqliteBindInt, [.stmt], 2, [.userID]
        cinvoke sqliteBindInt, [.stmt], 3, [.format]

        mov     eax, LIMIT_POST_LENGTH
        stdcall GetParam, 'max_post_length', gpInteger
        stdcall StrByteUtf8, [.source], eax
        stdcall StrTrim, [.source], eax

        stdcall StrPtr, [.source]
        cmp     [eax+string.len], 0
        je      .error_write

        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_write            ; strange write fault.

        cinvoke sqliteFinalize, [.stmt]

        cmp     [.postID], 0
        jne     .postid_ok

        cinvoke sqliteLastInsertRowID, [hMainDatabase]
        mov     [.postID], eax

.postid_ok:
; deal with the attachments.

        stdcall DelAttachments, [.postID], [.userID], esi
        stdcall WriteAttachments, [.postID], [.userID], esi
        stdcall UpdateAttachmentsPost, [.postID], [.userID]

; update the last changed time of the thread.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateThreadChanged, sqlUpdateThreadChanged.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_write

        cinvoke sqliteFinalize, [.stmt]

        stdcall RegisterUnreadPost, [.postID], [.threadID]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCommit, sqlCommit.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_write

        cinvoke sqliteFinalize, [.stmt]

.end_save:
        stdcall StrRedirectToPost, [.postID], esi
        stdcall TextMakeRedirect, edi, eax
        stdcall StrDel, eax

.finish_clear:

        stdcall ClearTicket3, [.ticket]
        stc

.finish:
; delete all temp strings
        stdcall StrDel, [.caption]
        stdcall StrDel, [.slug]
        stdcall StrDel, [.tags]
        stdcall StrDel, [.invited]
        stdcall StrDel, [.source]
        stdcall StrDel, [.userName]
        stdcall StrDel, [.ticket]

        mov     [esp+4*regEAX], edi
        popad
        return

.error_invalid_caption:

        stdcall TextMakeRedirect, edi, "/!message/error_invalid_caption/"
        jmp     .finish_clear


.error_post_id:

        stdcall AppendError, edi, "404 Not Found", esi
        mov     edi, edx
        stc
        jmp     .finish


.error_bad_ticket:

        stdcall TextMakeRedirect, edi, "/!message/error_bad_ticket/"
        jmp     .finish_clear


.error_wrong_permissions:

        stdcall TextMakeRedirect, edi, "/!message/error_cant_post/"
        jmp     .finish_clear


.error_missing_post:

        cinvoke sqliteFinalize, [.stmt]
        stdcall TextMakeRedirect, edi, "/!message/error_post_not_exists/"
        stc
        jmp     .finish


.error_write:
        OutputValue "Post edit write fault: ", eax, 10, -1

        cinvoke sqliteFinalize, [.stmt]
        cinvoke sqliteExec, [hMainDatabase], sqlRollback, 0, 0, 0
        stdcall TextMakeRedirect, edi, "/!message/error_cant_write/"
        jmp     .finish_clear

endp






proc EditThreadAttr, .pSpecial

.stmt dd ?

begin
        pushad

        mov     esi, [.pSpecial]

        stdcall TextCreate, sizeof.TText
        mov     edi, eax        ; the result string!

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadID, sqlGetThreadID.length , eax, 0

        mov     eax, [esi+TSpecialParams.thread]
        test    eax, eax
        jz      .error_missing_thread

        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_missing_thread

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlThreadFirstPost, sqlThreadFirstPost.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, ebx
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_missing_thread

        cinvoke sqliteColumnInt, [.stmt], 0     ; postID
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]

        stdcall NumToStr, ebx, ntsDec or ntsUnsigned
        stdcall StrCat, eax, txt "/!edit"
        push    eax

        stdcall TextMakeRedirect, edi, eax
        stdcall StrDel ; from the stack
        jmp     .finish


.error_missing_thread:
        cinvoke sqliteFinalize, [.stmt]
        stdcall TextMakeRedirect, edi, "/!message/error_thread_not_exists/"

.finish:
        stc
        mov     [esp+4*regEAX], edi
        popad
        return
endp









sqlDelAllTags        text  "delete from ThreadTags where threadID = ?1"
sqlInsertTags        text  "insert or ignore into Tags (tag, description) values (lower(?1), ?2)"
sqlInsertThreadTags  text  "insert into ThreadTags(tag, threadID) values (lower(?1), ?2)"

proc SaveThreadTags, .tags, .dir, .threadID
.stmt  dd ?
.stmt2 dd ?
begin
        pushad

        xor     eax, eax
        mov     [.stmt], eax
        mov     [.stmt2], eax

; remove all tags

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDelAllTags, sqlDelAllTags.length, eax, 0
        test    eax, eax
        jnz     .end_del

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

.end_del:
        cmp     [.tags], 0
        jne     .split

        stdcall CreateArray, 4
        mov     esi, eax
        jmp     .process_list

.split:
        stdcall StrSplitList, [.tags], ",", FALSE
        mov     esi, eax

.process_list:
        stdcall UniqueTagList, esi, [.dir]

        mov     ebx, [esi+TArray.count] ; the count can be max 4
        test    ebx, ebx
        jz      .finish_list

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertTags, sqlInsertTags.length, eax, 0

        lea     eax, [.stmt2]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertThreadTags, sqlInsertThreadTags.length, eax, 0

        cinvoke sqliteBindInt,  [.stmt2], 2, [.threadID]

.tag_loop:
        dec     ebx
        js      .finish_tags

        stdcall StrSplitList, [esi+TArray.array+4*ebx], ":", FALSE
        mov     edi, eax

        cmp     [edi+TArray.count], 0   ; is it possible?
        je      .next_tag

        cmp     [edi+TArray.count], 2
        jb      .description_ok

        stdcall StrByteUtf8, [edi+TArray.array+4], LIMIT_TAG_DESCRIPTION
        stdcall StrTrim, [edi+TArray.array+4], eax

        stdcall StrPtr, [edi+TArray.array+4]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

.description_ok:

        stdcall StrTagify, [edi+TArray.array]
        stdcall StrPtr, [edi+TArray.array]

        cmp     [eax+string.len], 0
        je      .next_tag

        push    eax
        cinvoke sqliteBindText, [.stmt],  1, eax, [eax+string.len], SQLITE_STATIC

        pop     eax
        cinvoke sqliteBindText, [.stmt2], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteStep, [.stmt2]

        cinvoke sqliteClearBindings, [.stmt]
        cinvoke sqliteReset, [.stmt]
        cinvoke sqliteReset, [.stmt2]

.next_tag:
        stdcall ListFree, edi, StrDel
        jmp     .tag_loop


.finish_tags:

        cinvoke sqliteFinalize, [.stmt]
        cinvoke sqliteFinalize, [.stmt2]

.finish_list:

        stdcall ListFree, esi, StrDel

.finish:
        popad
        return
endp




proc UniqueTagList, .pList, .hDir
begin
        pushad
        mov     edx, [.pList]

        mov     edi, [.hDir]
        test    edi, edi
        jz      .outer

        stdcall StrDup, edi
        mov     edi, eax

        mov     ecx, [edx+TArray.count]

.remove_dir:
        dec     ecx
        js      .outer

        stdcall TagCmp, [edx+4*ecx+TArray.array], edi
        test    eax, eax
        jnz     .remove_dir

        stdcall StrLen, [edx+4*ecx+TArray.array]
        mov     ebx, eax

        stdcall StrLen, edi
        cmp     eax, ebx
        jae     .len_ok1

        pushd   [edx+4*ecx+TArray.array] edi
        popd    [edx+4*ecx+TArray.array] edi

.len_ok1:
        stdcall StrDel, [edx+4*ecx+TArray.array]
        stdcall DeleteArrayItems, edx, ecx, 1
        jmp     .remove_dir

.outer:
        DebugMsg "Sorting array"

        mov     ecx, [edx+TArray.count]
        xor     ebx, ebx

.inner:
        dec     ecx
        jle     .next

        stdcall TagCmp, [edx+4*ecx+TArray.array], [edx+4*ecx+TArray.array-4]
        test    eax, eax
        jns     .inner

        pushd   [edx+4*ecx+TArray.array] [edx+4*ecx+TArray.array-4]
        popd    [edx+4*ecx+TArray.array] [edx+4*ecx+TArray.array-4]
        inc     ebx
        jmp     .inner

.next:
        test    ebx, ebx
        jnz     .outer

        DebugMsg "Array sorted, remove duplicates."

        mov     ecx, [edx+TArray.count]

.unique:
        dec     ecx
        jle     .end_unique

        stdcall TagCmp, [edx+4*ecx+TArray.array], [edx+4*ecx+TArray.array-4]
        test    eax, eax
        jnz     .unique

        stdcall StrLen, [edx+4*ecx+TArray.array]
        mov     ebx, eax

        stdcall StrLen, [edx+4*ecx+TArray.array-4]
        cmp     eax, ebx
        jae     .len_ok

        pushd   [edx+4*ecx+TArray.array] [edx+4*ecx+TArray.array-4]   ; try to preserve the tag description.
        popd    [edx+4*ecx+TArray.array] [edx+4*ecx+TArray.array-4]

.len_ok:
        stdcall StrDel, [edx+4*ecx+TArray.array]
        stdcall DeleteArrayItems, edx, ecx, 1
        jmp     .unique

.end_unique:

        mov     ecx, 3
        test    edi, edi
        jnz     .do_free

        inc     ecx

.do_free:
        mov     ebx, ecx        ; the desired size of the array

.free_loop:
        cmp     ecx, [edx+TArray.count]
        jae     .end_free

        stdcall StrDel, [edx+4*ecx+TArray.array]
        inc     ecx
        jmp     .free_loop

.end_free:
        cmp     ebx, [edx+TArray.count]
        cmova   ebx, [edx+TArray.count]
        mov     [edx+TArray.count], ebx

        test    edi, edi
        jz      .finish

        stdcall AddArrayItems, edx, 1
        mov     [eax], edi
        xor     edi, edi

.finish:
        DebugMsg "Array sorted, remove duplicates."

        stdcall StrDel, edi
        mov     [esp+4*regESI], edx
        popad
        return
endp


proc TagCmp, .hTag1, .hTag2
begin
        pushad

        stdcall StrSplitList, [.hTag1], ":", FALSE
        mov     esi, eax

        stdcall StrSplitList, [.hTag2], ":", FALSE
        mov     edi, eax

        mov     eax, [esi+TArray.count]
        test    eax, eax
        lea     eax, [eax+1]
        jz      .finish

        mov     eax, [edi+TArray.count]
        dec     eax
        js      .finish

        stdcall StrCompSort2, [esi+TArray.array], [edi+TArray.array], FALSE

.finish:
        mov     [esp+4*regEAX], eax
        stdcall ListFree, esi, StrDel
        stdcall ListFree, edi, StrDel

        popad
        return
endp



sqlDelAllInvited  text  "delete from LimitedAccessThreads where threadID = ?1"
sqlInsertInvited  text  "insert into LimitedAccessThreads(threadID, userID) values (?1, ?2)"

proc SaveInvited, .fLimited, .invited, .self, .threadID
.stmt  dd ?
begin
        pushad

        xor     eax, eax
        mov     [.stmt], eax

; remove all currently invited users...

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDelAllInvited, sqlDelAllInvited.length, eax, 0
        test    eax, eax
        jnz     .end_del

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

.end_del:
        cmp     [.fLimited], 0
        je      .finish         ; only make the thread public!

        cmp     [.invited], 0
        jne     .split

        stdcall CreateArray, 4
        mov     esi, eax
        jmp     .process_list

.split:
        stdcall StrSplitList, [.invited], ",", FALSE
        mov     esi, eax

.process_list:
        stdcall UniqueInvitedList, esi, [.self]

        mov     ebx, [esi+TArray.count]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertInvited, sqlInsertInvited.length, eax, 0

.user_loop:
        dec     ebx
        js      .finish_users

        cinvoke sqliteBindInt,  [.stmt], 1, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 2, [esi+TArray.array + 4*ebx]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteClearBindings, [.stmt]
        cinvoke sqliteReset, [.stmt]
        jmp     .user_loop


.finish_users:

        stdcall FreeMem, esi
        cinvoke sqliteFinalize, [.stmt]

.finish:
        popad
        return
endp


sqlGetUserID text "select id from users where nick = ?1"

proc UniqueInvitedList, .pList, .hSelf
.stmt dd ?
begin
        pushad
        mov     edx, [.pList]

        mov     edi, [.hSelf]
        test    edi, edi
        jz      .outer

        mov     ecx, [edx+TArray.count]

.loop_remove_self:
        dec     ecx
        js      .outer

        stdcall StrCompNoCase, [edx+4*ecx+TArray.array], [.hSelf]
        jnc     .loop_remove_self

        stdcall StrDel, [edx+4*ecx+TArray.array]
        stdcall DeleteArrayItems, edx, ecx, 1
        jmp     .loop_remove_self

.outer:
        DebugMsg "Sorting invited array"

        mov     ecx, [edx+TArray.count]
        xor     ebx, ebx

.inner:
        dec     ecx
        jle     .next

        stdcall StrCompSort2, [edx+4*ecx+TArray.array], [edx+4*ecx+TArray.array-4], FALSE
        test    eax, eax
        jns     .inner

        pushd   [edx+4*ecx+TArray.array] [edx+4*ecx+TArray.array-4]
        popd    [edx+4*ecx+TArray.array] [edx+4*ecx+TArray.array-4]
        inc     ebx
        jmp     .inner

.next:
        test    ebx, ebx
        jnz     .outer

        DebugMsg "Array sorted, remove duplicated users."

        mov     ecx, [edx+TArray.count]

.unique:
        dec     ecx
        jle     .end_unique

        stdcall StrCompNoCase, [edx+4*ecx+TArray.array], [edx+4*ecx+TArray.array-4]
        jnc     .unique

        stdcall StrDel, [edx+4*ecx+TArray.array]
        stdcall DeleteArrayItems, edx, ecx, 1
        jmp     .unique

.end_unique:

; add self:

        stdcall StrDup, [.hSelf]
        mov     edi, eax

        stdcall AddArrayItems, edx, 1
        mov     [eax], edi

; now replace the nicks with IDs:

        mov     edi, edx

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUserID, sqlGetUserID.length, eax, 0

        mov     ebx, [edi+TArray.count]

.id_loop:
        dec     ebx
        js      .list_ok

        stdcall StrPtr, [edi+TArray.array + 4*ebx]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        je      .get_id

        stdcall StrDel, [edi+TArray.array + 4*ebx]
        stdcall DeleteArrayItems, edi, ebx, 1
        mov     edi, edx
        jmp     .next_user

.get_id:
        cinvoke sqliteColumnInt, [.stmt], 0
        xchg    eax, [edi+TArray.array + 4*ebx]
        stdcall StrDel, eax

.next_user:
        cinvoke sqliteReset, [.stmt]
        cinvoke sqliteClearBindings, [.stmt]
        jmp     .id_loop

.list_ok:
        cinvoke sqliteFinalize, [.stmt]
        mov     [esp+4*regESI], edi
        popad
        return
endp



; Not implemented personalized notifications. ;)
proc SendNewPostNotifications, .postID, .threadSlug, .threadCaption, .forUser
begin


        return
endp