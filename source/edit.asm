
sqlReadPost    text "select P.id, T.caption, P.content as source, format, ?2 as Ticket, (select nick from users U where U.id = ?4) as UserName, T.limited, T.Pinned from Posts P left join Threads T on T.id = P.threadID where P.id = ?1"
sqlEditedPost  text "select P.id, T.caption, ?3 as source, ?5 as format, ?2 as Ticket, (select nick from users U where U.id = ?4) as UserName, T.limited, T.Pinned from Posts P left join Threads T on T.id = P.threadID where P.id = ?1"

sqlEditedAll   text "select ?1 as EditThread, ?2 as Caption, ?3 as Pinned, ?4 as Limited, ?5 as Invited, ?6 as PostID, ?7 as Source, ?8 as Format, ?9 as UserName, ?10 as Ticket"

sqlSavePost    text "update Posts set content = ?1, format = ?5, editUserID = ?4, editTime = strftime('%s','now') where id = ?3"
sqlGetPostUser text "select userID, threadID from Posts where id = ?"


proc EditUserMessage, .pSpecial
.stmt dd ?

.caption  dd ?
.source   dd ?
.ticket   dd ?
.format   dd ?

.slug     dd ?

.res      dd ?
.threadID dd ?
.postID   dd ?
.userID   dd ?

.softPreview dd ?

begin
        pushad

        DebugMsg "Edit user message."

        xor     ebx, ebx
        mov     [.caption], ebx
        mov     [.source], ebx
        mov     [.ticket], ebx
        mov     [.format], ebx
        mov     [.softPreview], ebx

        mov     esi, [.pSpecial]

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        mov     eax, [esi+TSpecialParams.page_num]
        mov     [.postID], eax

        test    eax, eax
        jnz     .get_user_and_thread

; new post or new thread

        mov     eax, [esi+TSpecialParams.userID]
        mov     [.userID], eax

        mov     eax, [esi+TSpecialParams.thread]
        mov     [.slug], eax

        test    eax, eax
        jz      .new_thread

; get the threadID

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadID, sqlGetThreadID.length, eax, 0
        stdcall StrPtr, [.slug]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_missing_post

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.threadID], eax

        cinvoke sqliteFinalize, [.stmt]
        jmp     .check_permissions

.new_thread:
        mov     [.threadID], eax
        jmp     .check_permissions


; read the userID and threadID for the post.
.get_user_and_thread:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetPostUser, -1, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.postID]
        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_ROW
        jne     .error_missing_post

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.userID], eax

        cinvoke sqliteColumnInt, [.stmt], 1
        mov     [.threadID], eax

        cinvoke sqliteFinalize, [.stmt]

; check the permissions.

.check_permissions:

        test    [esi+TSpecialParams.userStatus], permAdmin                              ; the admin is always allowed to edit!
        jnz     .permissions_ok

        stdcall CheckLimitedAccess, [.threadID], [esi+TSpecialParams.userID]            ; Other users must have permission to view the thread in order to be able to edit it.
        jz      .error_wrong_permissions

        test    [esi+TSpecialParams.userStatus], permEditAll                            ; the moderators have permission to edit limited access threads if they are invited.
        jnz     .permissions_ok

        test    [esi+TSpecialParams.userStatus], permEditOwn                            ; all other can edit only their own posts and only if have permission to edit.
        jz      .error_wrong_permissions

        mov     eax, [.userID]
        cmp     eax, [esi+TSpecialParams.userID]
        jne     .error_wrong_permissions


.permissions_ok:

        stdcall LogUserActivity, esi, uaEditingPost, 0

        cmp     [esi+TSpecialParams.post_array], 0
        je      .show_edit_form

        DebugMsg "POST request."

; ok, get the action then:

;        stdcall DumpPostArray, esi

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "ticket", 0
        mov     [.ticket], eax

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "source", 0
        mov     [.source], eax

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "format", 0
        test    eax, eax
        jz      .format_ok

        push    eax
        stdcall StrToNumEx, eax
        stdcall StrDel ; from the stack

.format_ok:
        mov     [.format], eax

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
        mov     ecx, sqlReadPost
        cmp     [.source], 0
        je      .sql_ok

        mov     ecx, sqlEditedPost

.sql_ok:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], ecx, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.page_num]
        cinvoke sqliteBindInt, [.stmt], 4, [.userID]

        stdcall StrPtr, [.ticket]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cmp     [.source], 0
        je      .source_ok

        stdcall StrPtr, [.source]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteBindInt, [.stmt], 5, [.format]

.source_ok:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_missing_post

        mov     eax, [esi+TSpecialParams.userLang]
        stdcall StrCat, [esi+TSpecialParams.page_title], [cEditingPageTitle+8*eax]

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrEncodeHTML, eax
        stdcall StrCat, [esi+TSpecialParams.page_title], eax
        stdcall StrDel, eax

; deal with the attachments:

        cmp     [esi+TSpecialParams.post_array], 0
        je      .attch_ok

        cinvoke sqliteColumnInt, [.stmt], 0     ; postID
        mov     ebx, eax

        stdcall DelAttachments, ebx, esi
        stdcall WriteAttachments, ebx, esi

.attch_ok:
        shr     [.softPreview], 1
        jnc     .render_all

; JS call request:

        stdcall TextAddStr2, edi, 0, cHeadersJSON, cHeadersJSON.length

        stdcall RenderTemplate, edi, "edit.json", [.stmt], esi
        mov     edi, eax

        cinvoke sqliteFinalize, [.stmt]

;        stdcall TextCompact, edi
;        mov     edi, edx
;        stdcall FileWrite, [STDERR], edi, eax
;        stdcall FileWriteString, [STDERR], <txt 13, 10>

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
        je      .end_save

; Empty post - is it normal?
;        stdcall StrLen, [.source]
;        cmp     eax, 0
;        je      .end_save

        stdcall CheckTicket, [.ticket], [esi+TSpecialParams.session]
        jc      .error_bad_ticket

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlBegin, sqlBegin.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .end_save               ; the transaction does not begin.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSavePost, sqlSavePost.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 3, [esi+TSpecialParams.page_num]
        cinvoke sqliteBindInt, [.stmt], 4, [esi+TSpecialParams.userID]
        cinvoke sqliteBindInt, [.stmt], 5, [.format]

        mov     eax, LIMIT_POST_LENGTH
        stdcall GetParam, 'max_post_length', gpInteger
        stdcall StrByteUtf8, [.source], eax
        stdcall StrTrim, [.source], eax

        stdcall StrPtr, [.source]
        mov     ecx, [eax+string.len]
        test    ecx, ecx
        jz      .error_write

        cinvoke sqliteBindText, [.stmt], 1, eax, ecx, SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_write            ; strange write fault.

        cinvoke sqliteFinalize, [.stmt]

; deal with the attachments.

        stdcall DelAttachments, [esi+TSpecialParams.page_num], esi
        stdcall WriteAttachments, [esi+TSpecialParams.page_num], esi

; update the last changed time of the thread.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateThreads, -1, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_write

        cinvoke sqliteFinalize, [.stmt]

        stdcall RegisterUnreadPost, [esi+TSpecialParams.page_num], [.threadID]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCommit, -1, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_write

        cinvoke sqliteFinalize, [.stmt]

.end_save:
        stdcall StrRedirectToPost, [esi+TSpecialParams.page_num], esi
        stdcall TextMakeRedirect, edi, eax
        stdcall StrDel, eax

.finish_clear:

        stdcall ClearTicket3, [.ticket]
        stc

.finish:
        stdcall StrDel, [.source]
        stdcall StrDel, [.ticket]
        mov     [esp+4*regEAX], edi
        popad
        return

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


iglobal
  sqlGetAllThreadAttr StripText "thread_attr.sql", SQL
endg

sqlSavePostTitle text "update threads set slug = ?1, Caption = ?2, LastChanged = strftime('%s','now'), Limited = ?4 where id = ?3"
sqlUpdatePinned  text "update threads set pinned = ?1 where id = ?2"

proc EditThreadAttr, .pSpecial
.stmt dd ?

.ticket   dd ?
.caption  dd ?
.slug     dd ?
.tags     dd ?
.invited  dd ?
.pinned   dd ?

.fLimited dd ?

.threadID dd ?
.userID   dd ?
.userName dd ?

begin
        pushad

        xor     eax, eax

; strings for freeing at the end.
        mov     [.ticket], eax
        mov     [.caption], eax
        mov     [.slug], eax
        mov     [.tags], eax
        mov     [.pinned], eax
        mov     [.userName], eax

; default integer values
        mov     [.threadID], eax
        dec     eax
        mov     [.userID], eax

        mov     esi, [.pSpecial]

        stdcall TextCreate, sizeof.TText
        mov     edi, eax        ; the result string!

; read all properties of the thread.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetAllThreadAttr, -1, eax, 0

        mov     eax, [esi+TSpecialParams.thread]
        test    eax, eax
        jz      .error_missing_thread

        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        mov     eax, [esi+TSpecialParams.session]
        test    eax, eax
        jz      .error_wrong_permissions

        cmp     [esi+TSpecialParams.post_array], 0
        je      .set_ticket

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "ticket", 0
        test    eax, eax
        jz      .error_bad_ticket
        jmp     .ticket_ok

.set_ticket:

        stdcall SetUniqueTicket, eax
        jc      .error_bad_ticket

.ticket_ok:
        mov     [.ticket], eax

        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_ROW
        jne     .error_missing_thread

        cinvoke sqliteColumnInt, [.stmt], 0     ; threadID
        mov     [.threadID], eax

        cinvoke sqliteColumnInt, [.stmt], 5     ; userID
        mov     [.userID], eax

; check the permissions.

        test    [esi+TSpecialParams.userStatus], permAdmin                              ; the admin is always allowed to edit!
        jnz     .permissions_ok

        stdcall CheckLimitedAccess, [.threadID], [esi+TSpecialParams.userID]            ; Other users must have permission to view the thread in order to be able to edit it.
        jz      .error_wrong_permissions

        mov     eax, [.userID]
        cmp     eax, [esi+TSpecialParams.userID]
        jne     .error_wrong_permissions                                                ; the thread attributes can be editted only by the thread owner and the administrators. No moderator access.

        test    [esi+TSpecialParams.userStatus], permEditAll or permEditOwn
        jz      .error_wrong_permissions

.permissions_ok:

        stdcall LogUserActivity, esi, uaEditingThread, 0

        cmp     [esi+TSpecialParams.post_array], 0
        jne     .save_attributes

; show edit form.

        mov     eax, [esi+TSpecialParams.userLang]
        stdcall StrCat, [esi+TSpecialParams.page_title], [cEditingThreadTitle+8*eax]

        cinvoke sqliteColumnText, [.stmt], 1    ; Thread caption.
        stdcall StrEncodeHTML, eax
        stdcall StrCat, [esi+TSpecialParams.page_title], eax
        stdcall StrDel, eax

        stdcall RenderTemplate, edi, "form_edit_thread.tpl", [.stmt], esi
        mov     edi, eax
        cinvoke sqliteFinalize, [.stmt]

        clc

.finish:
        stdcall StrDel, [.ticket]
        stdcall StrDel, [.caption]
        stdcall StrDel, [.slug]
        stdcall StrDel, [.tags]
        stdcall StrDel, [.invited]
        stdcall StrDel, [.userName]
        mov     [esp+4*regEAX], edi
        popad
        return



.save_attributes:

        stdcall CheckTicket, [.ticket], [esi+TSpecialParams.session]
        jc      .error_bad_ticket

        cinvoke sqliteFinalize, [.stmt]

; Get the caption and create the slug string.

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "title", 0
        test    eax, eax
        jz      .error_invalid_caption

        mov     [.caption], eax
        stdcall StrByteUtf8, [.caption], LIMIT_POST_CAPTION
        stdcall StrTrim, [.caption], eax

        stdcall StrSlugify, [.caption]
        mov     [.slug], eax

        stdcall StrLen, eax
        test    eax, eax
        jz      .error_invalid_caption

        stdcall NumToStr, [.threadID], ntsDec or ntsUnsigned
        stdcall StrCat, [.slug], txt "."
        stdcall StrCat, [.slug], eax
        stdcall StrDel, eax

; Get the tags

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "tags", 0
        mov     [.tags], eax

; get the invited
        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "invited", 0
        mov     [.invited], eax

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "limited", txt "0"
        push    eax
        stdcall StrToNumEx, eax
        stdcall StrDel ; from the stack
        mov     [.fLimited], eax

; Get the pinned

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "pinned", 0
        test    eax, eax
        jz      .pinned_ok

        push    eax
        stdcall StrToNumEx, eax
        stdcall StrDel ; from the stack

.pinned_ok:
        mov     [.pinned], eax

; Now we have all the data prepared, so start the thread update in a transaction.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlBegin, sqlBegin.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_write               ; the transaction failed to begin.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSavePostTitle, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 4, [.fLimited]

        cinvoke sqliteBindInt, [.stmt], 3, [.threadID]

        stdcall StrPtr, [.caption]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.slug]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_write            ; strange write fault.

        stdcall SaveThreadTags, [.tags], [esi+TSpecialParams.dir], [.threadID]

; save the invited users

        stdcall SaveInvited, [.fLimited], [.invited], [esi+TSpecialParams.userName], [.threadID]

; save the pinned flag. Only for admins!

        test    [esi+TSpecialParams.userStatus], permAdmin
        jz      .pinned_updated

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdatePinned, sqlUpdatePinned.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 2, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 1, [.pinned]
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_write

.pinned_updated:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCommit, -1, eax, 0
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_write

.end_save:

        stdcall ClearTicket3, [.ticket]

        stdcall StrDupMem, txt "../"
        push    eax
        stdcall StrCat, eax, [.slug]
        stdcall StrCat, eax, txt "/"

        stdcall TextMakeRedirect, edi, eax
        stdcall StrDel ; from the stack

        stc
        jmp     .finish

.finish_clear:

        stdcall ClearTicket3, [.ticket]
        stc
        jmp     .finish


.error_invalid_caption:

        stdcall TextMakeRedirect, edi, "/!message/error_invalid_caption/"
        jmp     .finish_clear

.error_write:
        cinvoke sqliteExec, [hMainDatabase], sqlRollback, 0, 0, 0

        stdcall TextMakeRedirect, edi, "/!message/error_cant_write/"
        jmp     .finish_clear

.error_wrong_permissions:
        cinvoke sqliteFinalize, [.stmt]
        stdcall TextMakeRedirect, edi, "/!message/error_cant_post/"
        jmp     .finish_clear

.error_missing_thread:
        cinvoke sqliteFinalize, [.stmt]
        stdcall TextMakeRedirect, edi, "/!message/error_thread_not_exists/"
        jmp     .finish_clear

.error_bad_ticket:
        cinvoke sqliteFinalize, [.stmt]
        stdcall TextMakeRedirect, edi, "/!message/error_bad_ticket/"
        jmp     .finish_clear

endp
