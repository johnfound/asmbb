
sqlSelectPosts StripText "showthread.sql", SQL

sqlGetPostCount  text "select count(1) from Posts where ThreadID = ?"
sqlGetThreadInfo text "select T.id, T.caption, T.slug, (select userID from Posts P where P.threadID=T.id order by P.id limit 1) as UserID from Threads T where T.slug = ?1 limit 1"
sqlIncReadCount  text "update PostCNT set Count = Count + 1 where postid in ("
sqlSetPostsRead  text "delete from UnreadPosts where UserID = ?1 and PostID in ("


proc ShowThread, .pSpecial

.stmt  dd ?
.stmt2 dd ?

.threadID dd ?

.list dd ?
.cnt  dd ?

.rendered dd ?

 BenchVar .temp

begin
        pushad

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        mov     esi, [.pSpecial]

        stdcall StrNew
        mov     [.rendered], eax

        stdcall LogUserActivity, esi, uaReadingThread, 0

        cinvoke sqliteExec, [hMainDatabase], sqlBegin, 0, 0, 0

        lea     eax, [.stmt2]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadInfo, sqlGetThreadInfo.length, eax, 0

        stdcall StrPtr, [esi+TSpecialParams.thread]
        cinvoke sqliteBindText, [.stmt2], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt2]
        cmp     eax, SQLITE_ROW
        jne     .error

        cinvoke sqliteColumnInt, [.stmt2], 0
        mov     [.threadID], eax

; make the title

        mov     ebx, [esi+TSpecialParams.page_title]

        stdcall StrCharCat, ebx, ' "'
        cinvoke sqliteColumnText, [.stmt2], 1

        stdcall StrCat, ebx, eax
        stdcall StrCharCat, ebx, '"'

        cmp     [esi+TSpecialParams.page_num], 0
        je      .page_ok

        stdcall StrCat, ebx, ", page: "
        stdcall NumToStr, [esi+TSpecialParams.page_num], ntsDec or ntsUnsigned
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

.page_ok:
        mov     [esi+TSpecialParams.page_title], ebx

        stdcall TextCat, edi, txt '<div class="thread">'
        stdcall RenderTemplate, edx, "nav_thread.tpl", [.stmt2], esi
        mov     edi, eax

; pages links

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetPostCount, sqlGetPostCount.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]

        cinvoke sqliteStep, [.stmt]

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.cnt], eax

        cinvoke sqliteFinalize, [.stmt]


        stdcall CreatePagesLinks2, [esi+TSpecialParams.page_num], [.cnt], 0, [esi+TSpecialParams.page_length]
        mov     [.list], eax

        stdcall TextCat, edi, [.list]
        mov     edi, edx

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectPosts, sqlSelectPosts.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.page_length]

        mov     eax, [esi+TSpecialParams.page_num]
        imul    eax, [esi+TSpecialParams.page_length]
        cinvoke sqliteBindInt, [.stmt], 3, eax

        stdcall StrPtr, [esi+TSpecialParams.thread]
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 5, [esi+TSpecialParams.userID]  ; the current user.

        mov     [.cnt], 0

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish

        inc     [.cnt]

        stdcall RenderTemplate, edi, "post_view.tpl", [.stmt], esi
        mov     edi, eax

        cinvoke sqliteColumnInt, [.stmt], 0

        stdcall StrCatNotEmpty, [.rendered], txt ","
        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        stdcall StrCat, [.rendered], eax
        stdcall StrDel, eax

        jmp     .loop


.finish:
        cinvoke sqliteFinalize, [.stmt]

        BenchmarkStart .temp

;        jmp     .skip_writes           ; not write the posts read count and clearing the unread posts.
                                        ; this is acceptable on very high loads for boosting performance.

        mov     ebx, [esi+TSpecialParams.userID]
        test    ebx, ebx
        jz      .posts_read_ok

        stdcall StrDupMem, sqlSetPostsRead
        stdcall StrCat, eax, [.rendered]
        stdcall StrCat, eax, txt ")"

        push    eax

        lea     ecx, [.stmt]
        stdcall StrPtr, eax
        cinvoke sqlitePrepare_v2, [hMainDatabase], eax, [eax+string.len], ecx, 0
        stdcall StrDel ; from the stack

        cinvoke sqliteBindInt, [.stmt], 1, ebx
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        Benchmark  "Posts set unread [us]: "

.posts_read_ok:

        stdcall StrDupMem, sqlIncReadCount
        xchg    eax, [.rendered]

        stdcall StrCat, [.rendered], eax
        stdcall StrDel, eax
        stdcall StrCat, [.rendered], txt ")"

        lea     ecx, [.stmt]
        stdcall StrPtr, [.rendered]
        cinvoke sqlitePrepare_v2, [hMainDatabase], eax, [eax+string.len], ecx, 0
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

;.skip_writes:
        stdcall StrDel, [.rendered]

        Benchmark  "Posts increment count and set unread [us]: "
        BenchmarkEnd

        cmp     [.cnt], 5
        jbe     .back_navigation_ok

        stdcall TextCat, edi, [.list]
        stdcall RenderTemplate, edx, "nav_thread.tpl", [.stmt2], esi
        mov     edi, eax

.back_navigation_ok:

        stdcall StrDel, [.list]
        stdcall TextCat, edi, txt "</div>"   ; div.thread
        mov     edi, edx

.exit:
        cinvoke sqliteFinalize, [.stmt2]
        cinvoke sqliteExec, [hMainDatabase], sqlCommit, 0, 0, 0

        clc
        mov     [esp+4*regEAX], edi
        popad
        return

.error:
        stdcall TextFree, edi
        xor     edi, edi
        jmp     .exit

endp







proc PostByID, .pSpecial
begin
        pushad

        xor     edi, edi
        mov     esi, [.pSpecial]
        cmp     [esi+TSpecialParams.page_num], edi
        je      .finish

        stdcall StrRedirectToPost, [esi+TSpecialParams.page_num], esi
        stdcall TextMakeRedirect, 0, eax
        stdcall StrDel, eax
        stc

.finish:
        mov     [esp+4*regEAX], edi
        popad
        return

.err404:
        xor     eax, eax
        clc
        jmp     .finish

endp




sqlGetThreadID text "select P.ThreadID, T.Slug from Posts P left join Threads T on P.threadID = T.id where P.id = ?"

sqlGetThePostIndex text "select count() from Posts p where threadID = ?1 and id < ?2 order by id"

proc StrRedirectToPost, .postID, .pSpecial
.stmt dd ?

.page dd ?
.slug dd ?

begin
        pushad

        mov     [.slug], 0

        mov     esi, [.pSpecial]

        stdcall StrDupMem, txt "/"
        mov     edi, eax

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

        mov     ecx, [esi+TSpecialParams.page_length]
        div     ecx
        mov     [.page], eax

        cinvoke sqliteFinalize, [.stmt]

; now compose the redirection string

        cmp     [esi+TSpecialParams.dir], 0
        je      .dir_ok

        stdcall StrCat, edi, [esi+TSpecialParams.dir]
        stdcall StrCat, edi, txt "/"

.dir_ok:
        stdcall StrCat, edi, [.slug]
        stdcall StrCat, edi, txt "/"

        cmp     [.page], 0
        je      .page_ok

        stdcall NumToStr, [.page], ntsDec or ntsUnsigned
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

.page_ok:
        stdcall StrCat, edi, txt "#"

        stdcall NumToStr, [.postID], ntsDec or ntsUnsigned
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

.finish:
        stdcall StrDel, [.slug]

        stdcall FileWriteString, [STDERR], edi
        stdcall FileWriteString, [STDERR], <txt 13, 10>

        mov     [esp+4*regEAX], edi
        popad
        return

.error:
        cinvoke sqliteFinalize, [.stmt]
        jmp     .finish

endp


