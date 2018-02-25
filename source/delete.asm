

;                               |       0      |      1    |        2          |      3        |     4    |                                      5                                       |    6

sqlDelConfirmInfo  text  "select P.id as PostID, P.threadID, U.nick as UserName, U.id as UserID, P.Content, (select count(1) from Posts P2 where P2.threadID = P.threadID ) as cnt_thread, T.Slug, ?2 as Ticket ",    \
                         "from Posts P left join Users U on U.id = P.userID left join Threads T on T.id = P.threadID where P.id = ?1"

sqlDelPost text "delete from Posts where id = ?"
sqlDelThread text "delete from Threads where id = ?"

proc DeletePost, .pSpecial
.stmt dd ?

.threadID dd ?
.post_cnt dd ?
.ticket   dd ?

begin
        pushad

        xor     edi, edi
        mov     [.threadID], edi
        mov     [.post_cnt], edi
        mov     [.ticket], edi

        mov     esi, [.pSpecial]

        cmp     [esi+TSpecialParams.page_num], edi
        je      .exit                                   ; CF = 0 and EDI=0 ---> error 404

; read post info and check permissions.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDelConfirmInfo, sqlDelConfirmInfo.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.page_num]

        stdcall SetUniqueTicket, [esi+TSpecialParams.session]
        jc      .perm_not_ok

        mov     [.ticket], eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish1

        cinvoke sqliteColumnInt, [.stmt], 1
        mov     [.threadID], eax                                ; threadID

        cinvoke sqliteColumnInt, [.stmt], 5
        mov     [.post_cnt], eax                                ; post_cnt

        test    [esi+TSpecialParams.userStatus], permDelAll
        jnz     .perm_ok

        test    [esi+TSpecialParams.userStatus], permDelOwn
        jz      .perm_not_ok

        cinvoke sqliteColumnInt, [.stmt], 3                     ; UserID
        cmp     eax, [esi+TSpecialParams.userID]
        je      .perm_ok

.perm_not_ok:
        cinvoke sqliteFinalize, [.stmt]
        stdcall TextMakeRedirect, 0, "/!message/error_cant_delete"
        jmp     .finish2

.perm_ok:

        stdcall LogUserActivity, esi, uaDeletingPost, 0
        stdcall StrCat, [esi+TSpecialParams.page_title], cPostDeleteTitle

        cmp     [esi+TSpecialParams.post_array], edi    ; edi is 0 here
        jne     .do_delete

        stdcall RenderTemplate, 0, "del_confirm.tpl", [.stmt], [.pSpecial]
        mov     edi, eax

.finish1:

        cinvoke sqliteFinalize, [.stmt]

.exit:
        stdcall StrDel, [.ticket]
        clc
        mov     [esp+4*regEAX], edi     ; 0 or TText with HTML
        popad
        return


.do_delete:
        stdcall ClearTicket3, [.ticket]

        stdcall GetPostString, [esi+TSpecialParams.post_array], 'ticket', 0
        test    eax, eax
        jz      .perm_not_ok

        mov     ebx, eax
        stdcall CheckTicket, ebx, [esi+TSpecialParams.session]
        pushf
        stdcall ClearTicket3, ebx
        stdcall StrDel, ebx
        popf
        jc      .perm_not_ok

        cinvoke sqliteFinalize, [.stmt]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlBegin, sqlBegin.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        clc
        jne     .finish2

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDelPost, sqlDelPost.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.page_num]
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .write_failure

        cmp     [.post_cnt], 1
        ja      .commit

; delete the thread

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDelThread, sqlDelThread.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .write_failure

.commit:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCommit, sqlCommit.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .write_failure

        cmp     [.post_cnt], 1
        ja      .finish_redirect_thread

.finish_redirect_list:
        stdcall TextMakeRedirect, 0, txt "../../"
        jmp     .finish2


.finish_redirect_thread:
        stdcall TextMakeRedirect, 0, txt "../"
        jmp     .finish2


.write_failure:
        cinvoke sqliteExec, [hMainDatabase], sqlRollback, 0, 0, 0
        stdcall TextMakeRedirect, 0, "/!message/error_cant_write"

.finish2:
        stdcall StrDel, [.ticket]
        stc
        mov     [esp+4*regEAX], edi
        popad
        return
endp