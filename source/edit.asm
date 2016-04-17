


sqlReadPost    text "select P.id, T.caption, P.content as source, ?2 as Ticket from Posts P left join Threads T on T.id = P.threadID where P.id = ?1"
sqlEditedPost  text "select P.id, T.caption, ?3 as source, ?2 as Ticket from Posts P left join Threads T on T.id = P.threadID where P.id = ?1"
sqlSavePost    text "update Posts set content = substr( ?1, 1, ?3 ), postTime = strftime('%s','now') where id = ?2"
sqlGetPostUser text "select userID, threadID from Posts where id = ?"


proc EditUserMessage, .pSpecial
.stmt dd ?

.source   dd ?
.ticket   dd ?

.res      dd ?
.threadID dd ?
.userID   dd ?

begin
        pushad

        xor     ebx, ebx
        mov     [.source], ebx
        mov     [.ticket], ebx

        mov     esi, [.pSpecial]

        stdcall StrNew
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

        stdcall StrCat, [esi+TSpecialParams.page_title], "Editing page: "

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrCat, [esi+TSpecialParams.page_title], eax

        stdcall StrCatTemplate, edi, "form_edit", [.stmt], esi

        stdcall StrCatTemplate, edi, "preview", [.stmt], esi

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

        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.page_num]
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
        stdcall StrCatRedirectToPost, edi, [esi+TSpecialParams.page_num], esi

.finish_clear:

        stdcall ClearTicket, [esi+TSpecialParams.session]
        stc


.finish:
        stdcall StrDel, [.source]
        stdcall StrDel, [.ticket]
        mov     [esp+4*regEAX], edi
        popad
        return


.error_post_id:

        stdcall AppendError, edi, "404 Not Found", esi
        stc
        jmp     .finish


.error_bad_ticket:

        stdcall StrMakeRedirect, edi, "/!message/error_bad_ticket/"
        jmp     .finish_clear


.error_wrong_permissions:

        stdcall StrMakeRedirect, edi, "/!message/error_cant_post/"
        jmp     .finish_clear


.error_missing_post:

        cinvoke sqliteFinalize, [.stmt]
        stdcall StrMakeRedirect, edi, "/!message/error_post_not_exists/"
        stc
        jmp     .finish


.error_write:

        cinvoke sqliteExec, [hMainDatabase], sqlRollback, 0, 0, 0
        stdcall StrMakeRedirect, edi, "/!message/error_cant_write/"
        jmp     .finish_clear

endp






