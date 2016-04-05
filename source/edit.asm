


sqlReadPost    text "select P.id, T.caption, P.content as source, ?2 as Ticket from Posts P left join Threads T on T.id = P.threadID where P.id = ?1"
sqlEditedPost  text "select P.id, T.caption, ?3 as source, ?2 as Ticket from Posts P left join Threads T on T.id = P.threadID where P.id = ?1"
sqlSavePost    text "update Posts set content = substr( ?1, 1, ?3 ), postTime = strftime('%s','now') where id = ?2"
sqlGetPostUser text "select userID, threadID from Posts where id = ?"


proc EditUserMessage, .postID, .pSpecial
.stmt dd ?

.fPreview dd ?
.source   dd ?
.ticket   dd ?

.res      dd ?
.threadID dd ?
.userID   dd ?

begin
        pushad

        mov     [.fPreview], 1  ; preview by default when handling GET requests.
        mov     [.source], 0
        mov     [.ticket], 0

        mov     esi, [.pSpecial]

        stdcall StrNew
        mov     edi, eax

; read the userID and threadID for the post.

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

        test    [esi+TSpecialParams.userStatus], permEditOwn or permEditAll or permAdmin
        jz      .error_wrong_permissions

        test    [esi+TSpecialParams.userStatus], permEditAll or permAdmin
        jnz     .permissions_ok

        mov     eax, [.userID]
        cmp     eax, [esi+TSpecialParams.userID]

        jne     .error_wrong_permissions


.permissions_ok:
        cmp     [esi+TSpecialParams.post], 0
        je      .show_edit_form

; ok, get the action then:

        stdcall GetQueryItem, [esi+TSpecialParams.post], "ticket=", 0
        mov     [.ticket], eax

        stdcall GetQueryItem, [esi+TSpecialParams.post], "source=", 0
        mov     [.source], eax

        stdcall GetQueryItem, [esi+TSpecialParams.post], "submit=", 0
        stdcall StrDel, eax
        test    eax, eax
        jnz     .save_post_and_exit

        stdcall GetQueryItem, [esi+TSpecialParams.post], "preview=", 0
        stdcall StrDel, eax
        mov     [.fPreview], eax


.show_edit_form:

        stdcall StrCat, edi, <"Status: 200 OK", 13, 10, "Content-type: text/html", 13, 10, 13, 10>
        stdcall StrCatTemplate, edi, "main_html_start", 0, esi

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

        cinvoke sqliteBindInt, [.stmt], 1, [.postID]

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

        stdcall StrCatTemplate, edi, "edit_form", [.stmt], esi

        cmp     [.fPreview], 0
        je      .preview_ok

        stdcall StrCatTemplate, edi, "preview", [.stmt], esi

.preview_ok:

        cinvoke sqliteFinalize, [.stmt]

        stdcall StrCatTemplate, edi, "main_html_end", 0, esi

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

        cinvoke sqliteBindInt, [.stmt], 2, [.postID]
        cinvoke sqliteBindInt, [.stmt], 3, LIMIT_POST_LENGTH

        stdcall StrPtr, [.source]

        mov     ecx, [eax+string.len]
        test    ecx, ecx
        jz      .error_write

        cinvoke sqliteBindText, [.stmt], 1, eax, ecx, SQLITE_STATIC

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


        stdcall RegisterUnreadPost, [.postID]
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
        stdcall StrCatRedirectToPost, edi, [.postID], [esi+TSpecialParams.tag]

.finish_clear:

        stdcall ClearTicket, [esi+TSpecialParams.session]

.finish:
        stdcall StrDelNull, [.source]
        stdcall StrDelNull, [.ticket]
        mov     [esp+4*regEAX], edi
        popad
        return


.error_bad_ticket:

        stdcall StrDel, edi
        stdcall StrNew
        mov     edi, eax
        stdcall StrMakeRedirect, edi, "/message/error_bad_ticket/"
        jmp     .finish_clear


.error_wrong_permissions:

        stdcall StrMakeRedirect, edi, "/message/error_cant_post/"
        jmp     .finish_clear


.error_missing_post:

        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDel, edi
        stdcall StrNew
        mov     edi, eax

        stdcall StrMakeRedirect, edi, "/message/error_post_not_exists/"
        jmp     .finish


.error_write:

; rollback:

        cinvoke sqliteExec, [hMainDatabase], sqlRollback, 0, 0, 0

        stdcall StrMakeRedirect, edi, "/message/error_cant_write/"
        jmp     .finish_clear

endp






