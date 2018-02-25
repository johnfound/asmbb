


sqlReadPost    text "select P.id, T.caption, P.content as source, ?2 as Ticket, (select nick from users U where U.id = ?4) as UserName from Posts P left join Threads T on T.id = P.threadID where P.id = ?1"
sqlEditedPost  text "select P.id, T.caption, ?3 as source, ?2 as Ticket, (select nick from users U where U.id = ?4) as UserName from Posts P left join Threads T on T.id = P.threadID where P.id = ?1"

sqlSavePost    text "update Posts set content = ?1, rendered = ?2, postTime = strftime('%s','now') where id = ?3"
sqlGetPostUser text "select userID, threadID from Posts where id = ?"


proc EditUserMessage, .pSpecial
.stmt dd ?

.source   dd ?
.rendered dd ?
.ticket   dd ?

.res      dd ?
.threadID dd ?
.userID   dd ?

begin
        pushad

        xor     ebx, ebx
        mov     [.source], ebx
        mov     [.rendered], ebx
        mov     [.ticket], ebx

        mov     esi, [.pSpecial]

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        cmp     [esi+TSpecialParams.page_num], ebx
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

        test    [esi+TSpecialParams.userStatus], permEditOwn or permEditAll or permAdmin
        jz      .error_wrong_permissions

        test    [esi+TSpecialParams.userStatus], permEditAll or permAdmin
        jnz     .permissions_ok

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

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "source", 0
        mov     [.source], eax

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "submit", 0
        stdcall StrDel, eax
        test    eax, eax
        jnz     .save_post_and_exit

.show_edit_form:

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

.source_ok:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_missing_post

        stdcall StrCat, [esi+TSpecialParams.page_title], cEditingPageTitle

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrCat, [esi+TSpecialParams.page_title], eax

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

        stdcall StrLen, [.source]
        cmp     eax, 0
        je      .end_save

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
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSavePost, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 3, [esi+TSpecialParams.page_num]

        stdcall StrByteUtf8, [.source], LIMIT_POST_LENGTH
        stdcall StrTrim, [.source], eax

; render the source

        stdcall FormatPostText2, [.source], esi
        mov     [.rendered], eax

; bind the source

        stdcall StrPtr, [.source]

        mov     ecx, [eax+string.len]
        test    ecx, ecx
        jz      .error_write

        cinvoke sqliteBindText, [.stmt], 1, eax, ecx, SQLITE_STATIC

; bind the html

        stdcall StrPtr, [.rendered]

        mov     ecx, [eax+string.len]
        test    ecx, ecx
        jz      .error_write

        cinvoke sqliteBindText, [.stmt], 2, eax, ecx, SQLITE_STATIC


        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_write            ; strange write fault.

; update the last changed time of the thread.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateThreads, -1, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_write


        stdcall RegisterUnreadPost, [esi+TSpecialParams.page_num]
        cmp     eax, SQLITE_DONE
        jne     .error_write


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCommit, -1, eax, 0
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_write

.end_save:
        stdcall StrRedirectToPost, [esi+TSpecialParams.page_num], esi
        stdcall TextMakeRedirect, edi, eax
        stdcall StrDel, eax

.finish_clear:

        stdcall ClearTicket3, [.ticket]
        stc

.finish:
        stdcall StrDel, [.source]
        stdcall StrDel, [.rendered]
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

        cinvoke sqliteExec, [hMainDatabase], sqlRollback, 0, 0, 0
        stdcall TextMakeRedirect, edi, "/!message/error_cant_write/"
        jmp     .finish_clear

endp


iglobal
  sqlGetAllThreadAttr StripText "thread_attr.sql", SQL
endg

sqlSavePostTitle text "update threads set slug = ?1, Caption = ?2, LastChanged = strftime('%s','now') where id = ?3"
sqlUpdatePinned  text "update threads set pinned = ?1 where id = ?2"

proc EditThreadAttr, .pSpecial
.stmt dd ?

.ticket   dd ?
.caption  dd ?
.slug     dd ?
.tags     dd ?
.pinned   dd ?

.threadID dd ?
.userID   dd ?

begin
        pushad

        xor     eax, eax

; strings for freeing at the end.
        mov     [.ticket], eax
        mov     [.caption], eax
        mov     [.slug], eax
        mov     [.tags], eax
        mov     [.pinned], eax

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

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.threadID], eax

        cinvoke sqliteColumnInt, [.stmt], 4
        mov     [.userID], eax

; check the permissions.

        test    [esi+TSpecialParams.userStatus], permEditOwn or permEditAll or permAdmin
        jz      .error_wrong_permissions

        test    [esi+TSpecialParams.userStatus], permEditAll or permAdmin
        jnz     .permissions_ok

        cmp     [esi+TSpecialParams.userID], eax
        jne     .error_wrong_permissions

.permissions_ok:

        stdcall LogUserActivity, esi, uaEditingThread, 0

        cmp     [esi+TSpecialParams.post_array], 0
        jne     .save_attributes

; show edit form.

        stdcall StrCat, [esi+TSpecialParams.page_title], cEditingThreadTitle

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrCat, [esi+TSpecialParams.page_title], eax

        stdcall RenderTemplate, edi, "form_edit_thread.tpl", [.stmt], esi
        mov     edi, eax
        cinvoke sqliteFinalize, [.stmt]

        clc

.finish:
        stdcall StrDel, [.ticket]
        stdcall StrDel, [.caption]
        stdcall StrDel, [.slug]
        stdcall StrDel, [.tags]
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
        stdcall StrCharCat, [.slug], "."
        stdcall StrCat, [.slug], eax
        stdcall StrDel, eax

; Get the tags

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "tags", 0
        mov     [.tags], eax
        test    eax, eax
        jz      .tags_ok

        cmp     [esi+TSpecialParams.dir], 0
        je      .tags_ok

        stdcall StrCharCat, [.tags], ','
        stdcall StrCat, [.tags], [esi+TSpecialParams.dir]

.tags_ok:

; Get the pinned

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "pinned", 0
        test    eax, eax
        jz      .pinned_ok

        stdcall StrDel, eax
        xor     eax, eax
        inc     eax

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

        stdcall SaveThreadTags, [.tags], [.threadID]

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
        stdcall StrCharCat, eax, "/"

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
