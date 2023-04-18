
sqlReadPost    StripText "readpost.sql", SQL
sqlEditedPost  StripText "editedpost.sql", SQL

sqlGetPostUser    text "select userID, threadID from Posts where id = ?1"

sqlSaveThreadAttr       text "update threads set slug = ?2, Caption = ?3, LastChanged = strftime('%s','now'), Limited = ?4 where id = ?1"
sqlUpdatePinned         text "update threads set pinned = ?2 where id = ?1"
sqlUpdateThreadChanged  text "update Threads set LastChanged = strftime('%s','now') where id = ?1"


sqlSavePost       text "update Posts set content = ?2, format = ?3, ", \
                       "postTime = case when postTime is null then strftime('%s','now') else postTime end, ", \
                       "editUserID = case when postTime is null then null else ?4 end, ", \
                       "editTime   = case when postTime is null then null else strftime('%s','now') end ", \
                       "where id = ?1"

sqlThreadFirstPost text "select id from Posts where threadid = ?1 order by rowid limit 1"


proc EditUserMessage, .pSpecial
.stmt dd ?

; thread attributes

.locdata:

.threadID dd ?
.caption  dd ?
.slug     dd ?
.tags     dd ?
.invited  dd ?
.fLimited dd ?
.pinned   dd ?

; Post attributes

.source   dd ?
.format   dd ?

; User attributes

.userID   dd ?

; Other attributes

.ticket   dd ?

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

        cmp     [esi+TSpecialParams.page_num], 0
        je      .error_post_id

; read the userID and threadID for the post.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetPostUser, -1, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.page_num]
        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_ROW
        jne     .error_missing_post

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.userID], eax

        cinvoke sqliteColumnInt, [.stmt], 1
        mov     [.threadID], eax

        cinvoke sqliteFinalize, [.stmt]

; check the permissions.

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

; ok, get the action then:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "ticket", 0
        mov     [.ticket], eax

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "title", 0
        test    eax, eax
        jz      .error_invalid_caption

        mov     [.caption], eax
        stdcall StrByteUtf8, [.caption], LIMIT_POST_CAPTION
        stdcall StrTrim, [.caption], eax

.caption_ok:
        stdcall StrSlugify, [.caption]
        mov     [.slug], eax

        stdcall StrLen, eax
        test    eax, eax
        jz      .error_invalid_caption

        stdcall NumToStr, [.threadID], ntsDec or ntsUnsigned
        stdcall StrCat, [.slug], txt "."
        stdcall StrCat, [.slug], eax
        stdcall StrDel, eax

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
        mov     ecx, sqlReadPost

        cmp     [esi+TSpecialParams.post_array], 0
        je      .sql_ok

        mov     ecx, sqlEditedPost

.sql_ok:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], ecx, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.page_num]

        stdcall StrPtr, [.ticket]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cmp     [esi+TSpecialParams.post_array], 0
        je      .parameters_ok

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

        stdcall DelAttachments, [esi+TSpecialParams.page_num], esi
        stdcall WriteAttachments, [esi+TSpecialParams.page_num], esi

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
        je      .end_save

        stdcall CheckTicket, [.ticket], [esi+TSpecialParams.session]
        jc      .error_bad_ticket

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlBegin, sqlBegin.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_write

        cinvoke sqliteFinalize, [.stmt]

; save the thread attributes

; check to save the thread. (now in the transaction!)
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlThreadFirstPost, sqlThreadFirstPost.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_write

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, [esi+TSpecialParams.page_num]      ; the postID
        jne     .thread_ok

; yes, save the thread attributes.

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

        stdcall SaveThreadTags, [.tags], [esi+TSpecialParams.dir], [.threadID]

; save the invited users

        stdcall SaveInvited, [.fLimited], [.invited], [esi+TSpecialParams.userName], [.threadID]

; save the pinned flag in separate query. Only for admins!

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

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSavePost, sqlSavePost.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.page_num]  ; postID

        mov     eax, LIMIT_POST_LENGTH
        stdcall GetParam, 'max_post_length', gpInteger
        stdcall StrByteUtf8, [.source], eax
        stdcall StrTrim, [.source], eax

        stdcall StrPtr, [.source]
        cmp     [eax+string.len], 0
        je      .error_write

        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 3, [.format]
        cinvoke sqliteBindInt, [.stmt], 4, [esi+TSpecialParams.userID]

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_write            ; strange write fault.

        cinvoke sqliteFinalize, [.stmt]

; deal with the attachments.

        stdcall DelAttachments, [esi+TSpecialParams.page_num], esi
        stdcall WriteAttachments, [esi+TSpecialParams.page_num], esi

; update the last changed time of the thread.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateThreadChanged, sqlUpdateThreadChanged.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_write

        cinvoke sqliteFinalize, [.stmt]

        stdcall RegisterUnreadPost, [esi+TSpecialParams.page_num], [.threadID]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCommit, sqlCommit.length, eax, 0
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
; delete all temp strings
        stdcall StrDel, [.caption]
        stdcall StrDel, [.slug]
        stdcall StrDel, [.tags]
        stdcall StrDel, [.invited]
        stdcall StrDel, [.source]
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
