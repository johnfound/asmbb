
sqlPostHistory StripText "posthistory.sql", SQL


proc ShowHistory, .pSpecial
.stmt dd ?
.cnt  dd ?
begin
        pushad

        DebugMsg "History start."

        xor     edi, edi
        mov     esi, [.pSpecial]
        mov     [.cnt], edi

        cmp     [esi+TSpecialParams.page_num], edi
        je      .exit                                   ; CF = 0 and EDI=0 ---> error 404

        test    [esi+TSpecialParams.userStatus], permAdmin
        jz      .perm_error

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        stdcall LogUserActivity, esi, uaAdminThings, 0


        DebugMsg "History log actility"

        stdcall TextCat, edi, txt '<div class="thread">'
        stdcall RenderTemplate, edx, "nav_history.tpl", 0, esi
        mov     edi, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlPostHistory, sqlPostHistory.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.page_num]

        DebugMsg "History SQL prepared"

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .end_query

        DebugMsg "History post rendering start."

        stdcall RenderTemplate, edi, "post_history.tpl", [.stmt], esi
        mov     edi, eax

        DebugMsg "History post rendering end."

        inc     [.cnt]
        jmp     .loop

.end_query:
        DebugMsg "History end query."

        cinvoke sqliteFinalize, [.stmt]

        cmp     [.cnt], 5
        jbe     .back_navigation_ok

        stdcall RenderTemplate, edi, "nav_history.tpl", 0, esi
        mov     edi, eax

.back_navigation_ok:

        DebugMsg "History close div"

        stdcall TextCat, edi, txt "</div>"   ; div.thread
        mov     edi, edx

.exit:
        DebugMsg "History normal end"

        clc
        mov     [esp+4*regEAX], edi
        popad
        return

.perm_error:
        DebugMsg "History not admin"

        stdcall TextMakeRedirect, 0, "/!message/only_for_admins"

        stc
        mov     [esp+4*regEAX], edi
        popad
        return
endp






;
;proc ShowThread, .pSpecial
;
;.stmt  dd ?
;.stmt2 dd ?
;
;.threadID dd ?
;
;.list dd ?
;.cnt  dd ?
;
;.rendered dd ?
;
; BenchVar .temp
;
;begin
;        pushad
;
;        stdcall TextCreate, sizeof.TText
;        mov     edi, eax
;
;        mov     esi, [.pSpecial]
;
;        stdcall StrNew
;        mov     [.rendered], eax
;
;        stdcall LogUserActivity, esi, uaReadingThread, 0
;
;        cinvoke sqliteExec, [hMainDatabase], sqlBegin, 0, 0, 0
;
;        lea     eax, [.stmt2]
;        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadInfo, sqlGetThreadInfo.length, eax, 0
;
;        stdcall StrPtr, [esi+TSpecialParams.thread]
;        cinvoke sqliteBindText, [.stmt2], 1, eax, [eax+string.len], SQLITE_STATIC
;
;        cinvoke sqliteStep, [.stmt2]
;        cmp     eax, SQLITE_ROW
;        jne     .error
;
;        cinvoke sqliteColumnInt, [.stmt2], 0
;        mov     [.threadID], eax
;
;; make the title
;
;        mov     ebx, [esi+TSpecialParams.page_title]
;
;        stdcall StrCat, ebx, txt ' "'
;        cinvoke sqliteColumnText, [.stmt2], 1
;
;        stdcall StrEncodeHTML, eax
;        stdcall StrCat, ebx, eax
;        stdcall StrDel, eax
;        stdcall StrCat, ebx, txt '"'
;
;        cmp     [esi+TSpecialParams.page_num], 0
;        je      .page_ok
;
;        stdcall StrCat, ebx, ", page: "
;        stdcall NumToStr, [esi+TSpecialParams.page_num], ntsDec or ntsUnsigned
;        stdcall StrCat, ebx, eax
;        stdcall StrDel, eax
;
;.page_ok:
;        mov     [esi+TSpecialParams.page_title], ebx
;
;        stdcall TextCat, edi, txt '<div class="thread">'
;        stdcall RenderTemplate, edx, "nav_thread.tpl", [.stmt2], esi
;        mov     edi, eax
;
;; pages links
;
;        lea     eax, [.stmt]
;        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetPostCount, sqlGetPostCount.length, eax, 0
;        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
;
;        cinvoke sqliteStep, [.stmt]
;
;        cinvoke sqliteColumnInt, [.stmt], 0
;        mov     [.cnt], eax
;
;        cinvoke sqliteFinalize, [.stmt]
;
;
;        stdcall CreatePagesLinks2, [esi+TSpecialParams.page_num], [.cnt], 0, [esi+TSpecialParams.page_length]
;        mov     [.list], eax
;
;        stdcall TextCat, edi, [.list]
;        mov     edi, edx
;
;        lea     eax, [.stmt]
;        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectPosts, sqlSelectPosts.length, eax, 0
;
;        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
;        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.page_length]
;
;        mov     eax, [esi+TSpecialParams.page_num]
;        imul    eax, [esi+TSpecialParams.page_length]
;        cinvoke sqliteBindInt, [.stmt], 3, eax
;
;        stdcall StrPtr, [esi+TSpecialParams.thread]
;        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC
;
;        cinvoke sqliteBindInt, [.stmt], 5, [esi+TSpecialParams.userID]  ; the current user.
;
;        mov     [.cnt], 0
;
;.loop:
;        cinvoke sqliteStep, [.stmt]
;        cmp     eax, SQLITE_ROW
;        jne     .finish
;
;        inc     [.cnt]
;
;        stdcall RenderTemplate, edi, "post_view.tpl", [.stmt], esi
;        mov     edi, eax
;
;        cinvoke sqliteColumnInt, [.stmt], 0
;
;        stdcall StrCatNotEmpty, [.rendered], txt ","
;        stdcall NumToStr, eax, ntsDec or ntsUnsigned
;        stdcall StrCat, [.rendered], eax
;        stdcall StrDel, eax
;
;        jmp     .loop
;
;
;.finish:
;        cinvoke sqliteFinalize, [.stmt]
;
;        BenchmarkStart .temp
;
;;        jmp     .skip_writes           ; not write the posts read count and clearing the unread posts.
;                                        ; this is acceptable on very high loads for boosting performance.
;
;        mov     ebx, [esi+TSpecialParams.userID]
;        test    ebx, ebx
;        jz      .posts_read_ok
;
;        stdcall StrDupMem, sqlSetPostsRead
;        stdcall StrCat, eax, [.rendered]
;        stdcall StrCat, eax, txt ")"
;
;        push    eax
;
;        lea     ecx, [.stmt]
;        stdcall StrPtr, eax
;        cinvoke sqlitePrepare_v2, [hMainDatabase], eax, [eax+string.len], ecx, 0
;        stdcall StrDel ; from the stack
;
;        cinvoke sqliteBindInt, [.stmt], 1, ebx
;        cinvoke sqliteStep, [.stmt]
;        cinvoke sqliteFinalize, [.stmt]
;
;        Benchmark  "Posts set unread [us]: "
;
;.posts_read_ok:
;
;        stdcall StrDupMem, sqlIncReadCount
;        xchg    eax, [.rendered]
;
;        stdcall StrCat, [.rendered], eax
;        stdcall StrDel, eax
;        stdcall StrCat, [.rendered], txt ")"
;
;        lea     ecx, [.stmt]
;        stdcall StrPtr, [.rendered]
;        cinvoke sqlitePrepare_v2, [hMainDatabase], eax, [eax+string.len], ecx, 0
;        cinvoke sqliteStep, [.stmt]
;        cinvoke sqliteFinalize, [.stmt]
;
;;.skip_writes:
;        stdcall StrDel, [.rendered]
;
;        Benchmark  "Posts increment count and set unread [us]: "
;        BenchmarkEnd
;
;        cmp     [.cnt], 5
;        jbe     .back_navigation_ok
;
;        stdcall TextCat, edi, [.list]
;        stdcall RenderTemplate, edx, "nav_thread.tpl", [.stmt2], esi
;        mov     edi, eax
;
;.back_navigation_ok:
;
;        stdcall StrDel, [.list]
;        stdcall TextCat, edi, txt "</div>"   ; div.thread
;        mov     edi, edx
;
;.exit:
;        cinvoke sqliteFinalize, [.stmt2]
;        cinvoke sqliteExec, [hMainDatabase], sqlCommit, 0, 0, 0
;
;        clc
;        mov     [esp+4*regEAX], edi
;        popad
;        return
;
;.error:
;        stdcall TextFree, edi
;        xor     edi, edi
;        jmp     .exit
;
;endp
