
sqlSelectPosts StripText "showthread.sql", SQL

;sqlCheckAccess   text "select (select count() from LimitedAccessThreads where threadID = ?1 and userid = ?2) > 0 or not exists (select 1 from LimitedAccessThreads where threadID = ?1);"
sqlCheckAccess   text "select not count() or sum(userID = ?2) from LimitedAccessThreads where threadID = ?1;"


sqlGetPostCount  text "select PostCount from threads where id = ?1"

; IMPORTANT: userID is needed because of [special:canedit] template statement!
sqlGetThreadInfo StripText "threadinfo.sql"

sqlIncReadCount  text "update PostCNT set Count = Count + 1 where postid in ("
sqlSetPostsRead  text "delete from UnreadPosts where UserID = ?1 and PostID in ("

sqlIncThreadReadCount text "update Threads set ReadCount = ReadCount + 1 where id = ?1"

; Checks the permissions of the thread, towards some user.
;
; Returns ZF=0 if the user has permissions to view the thread.
;         ZF=1 otherwize.
;
; It always return ZF=0 for the public threads and
; for the limited access threads where the user is included
; in the list of the invited users.

proc CheckLimitedAccess, .threadID, .userID
.stmt dd ?
begin
        pushad
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCheckAccess, sqlCheckAccess.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.userID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]
        test    ebx, ebx
        popad
        return
endp



proc ShowThread, .pSpecial

.stmt  dd ?
.stmt2 dd ?

.threadID dd ?

.list dd ?
.cnt  dd ?

.rendered dd ?

begin
        pushad

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        mov     esi, [.pSpecial]

; check permissions

        test    [esi+TSpecialParams.userStatus], permRead or permAdmin
        jz      .error_cant_read

        cmp     [esi+TSpecialParams.Limited], 0
        je      .read_ok

        cmp     [esi+TSpecialParams.userID], 0
        je      .error_cant_read

.read_ok:
        stdcall StrNew
        mov     [.rendered], eax

        cinvoke sqliteExec, [hMainDatabase], sqlBegin, 0, 0, 0

        lea     eax, [.stmt2]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadInfo, sqlGetThreadInfo.length, eax, 0

        stdcall StrPtr, [esi+TSpecialParams.thread]
        cinvoke sqliteBindText, [.stmt2], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteBindInt, [.stmt2], 2, [esi+TSpecialParams.userID]

        cinvoke sqliteStep, [.stmt2]
        cmp     eax, SQLITE_ROW
        jne     .error

        cinvoke sqliteColumnInt, [.stmt2], 0
        mov     [.threadID], eax

        cinvoke sqliteColumnInt, [.stmt2], 3
        mov     [esi+TSpecialParams.Limited], eax ; OVERRIDE the limited parameter, according to the real state of the thread.

; make the title

        mov     ebx, [esi+TSpecialParams.page_title]

        stdcall StrCat, ebx, txt ' "'
        cinvoke sqliteColumnText, [.stmt2], 1

        stdcall StrEncodeHTML, eax
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCat, ebx, txt '"'

        cmp     [esi+TSpecialParams.page_num], 0
        je      .page_ok

        stdcall StrCat, ebx, ", page: "
        stdcall NumToStr, [esi+TSpecialParams.page_num], ntsDec or ntsUnsigned
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

.page_ok:
        mov     [esi+TSpecialParams.page_title], ebx

        test    [esi+TSpecialParams.userStatus], permAdmin      ; the admins have always access, but not the morerators!
        jnz     .have_access

; check for limited access thread

        stdcall CheckLimitedAccess, [.threadID], [esi+TSpecialParams.userID]
        jz      .limited_not_for_you

.have_access:
        stdcall RenderTemplate, edi, "thread.js", [.stmt2], esi

        stdcall TextCat, eax, txt '<div class="thread">'
        stdcall RenderTemplate, edx, "nav_thread.tpl", [.stmt2], esi
        mov     edi, eax

; pages links

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetPostCount, sqlGetPostCount.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]

        cinvoke sqliteStep, [.stmt]

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]


        stdcall CreatePagesLinks2, [esi+TSpecialParams.page_num], ebx, 0, [esi+TSpecialParams.page_length]
        mov     [.list], eax

        stdcall TextCat, edi, eax
        stdcall TextCat, edx, <txt '<div class="multi_content">', 13, 10>
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

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish

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

        cmp     [ThreadCnt], MAX_THREAD_CNT/2    ; not write the posts read count and clearing the unread posts.
        jge     .skip_writes                     ; this is acceptable on very high loads for boosting performance.


; Send activity events... if the thread is not LAT!

        cmp     [esi+TSpecialParams.Limited], 0
        jne     .notifications_ok

        stdcall LogUserActivity, esi, uaReadingThread, 0

        stdcall UserNameLink, esi
        mov     ebx, eax
        push    edx             ; see below the AddActivity call

        mov     eax, DEFAULT_UI_LANG
        stdcall GetParam, "default_lang", gpInteger
        stdcall StrCat, ebx, [cActivityRead + 8*eax]

        stdcall StrCat, ebx, txt '<a href="/'
        stdcall StrEncodeHTML, [esi+TSpecialParams.thread]
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCat, ebx, txt '/">'

        cinvoke sqliteColumnText, [.stmt2], 1
        stdcall StrEncodeHTML, eax
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCat, ebx, txt '</a>'

        stdcall AddActivity, ebx, atReading, [esi+TSpecialParams.userID] ; fBot flag from the stack.
        stdcall StrDel, ebx

.notifications_ok:

; Mark rendered posts as read. If the user is logged-in

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

.posts_read_ok:

        stdcall ValueByName, [esi+TSpecialParams.params], "HTTP_CACHE_CONTROL"
        jc      .do_increments

        stdcall StrCompCase, eax, "max-age=0"
        jc      .skip_writes                           ; soft refresh

        stdcall StrCompCase, eax, "no-cache"           ; hard refresh
        jc      .skip_writes

.do_increments:

; Increment thread read counter

        stdcall ValueByName, [esi+TSpecialParams.params], "HTTP_REFERER"
        jc      .thread_counter_ok

        stdcall StrPos, eax, [esi+TSpecialParams.thread]        ; don't increment on browsing thread pages.
        test    eax, eax
        jnz     .thread_counter_ok

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlIncThreadReadCount, sqlThreadsCount.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

.thread_counter_ok:

; Increment posts read counters

        stdcall StrDupMem, sqlIncReadCount
        stdcall StrCat, eax, [.rendered]
        stdcall StrCat, eax, txt ")"
        push    eax

        lea     ecx, [.stmt]
        stdcall StrPtr, eax
        cinvoke sqlitePrepare_v2, [hMainDatabase], eax, [eax+string.len], ecx, 0
        stdcall StrDel ; from the stack

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

.skip_writes:

        stdcall StrDel, [.rendered]

        stdcall TextCat, edi, <txt "</div>", 13, 10>   ; div.multi_content
        mov     edi, edx

        stdcall TextCat, edi, [.list]
        stdcall RenderTemplate, edx, "nav_thread.tpl", [.stmt2], esi
        mov     edi, eax

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

.limited_not_for_you:

        stdcall TextFree, edi
        xor     edi, edi
        jmp     .exit

; the user have no permissions to read posts!
.error_cant_read:

        stdcall TextMakeRedirect, edi, "/!message/cant_read/"
        mov     [esp+4*regEAX], edi
        stc
        popad
        return

endp





sqlFirstUnread text "select PostID from UnreadPosts where (UserID = ?1) and (ThreadID = (select id from threads where Slug = ?2)) limit 1"
sqlLastInThread text "select id from Posts where ThreadID = (select id from threads where Slug = ?2) order by rowid desc limit 1"

proc GotoFirstUnread, .pSpecial
.stmt dd ?
begin
        pushad

        mov     esi, [.pSpecial]

        mov     edi, sqlFirstUnread
        mov     ecx, sqlFirstUnread.length
        jmp     .prepare

.search_last_post:
        cmp     edi, sqlLastInThread
        je      .goto_root

        mov     edi, sqlLastInThread
        mov     ecx, sqlLastInThread.length

.prepare:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], edi, ecx, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.userID]

        cmp     [esi+TSpecialParams.thread], 0
        je      .thread_ok

        stdcall StrPtr, [esi+TSpecialParams.thread]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

.thread_ok:
        xor     ebx, ebx

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finalize

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax

.finalize:
        cinvoke sqliteFinalize, [.stmt]

        test    ebx, ebx
        jz      .search_last_post

        stdcall StrRedirectToPost, ebx, esi
        stdcall TextMakeRedirect, 0, eax
        stdcall StrDel, eax

.finish:
        stc
        mov     dword [esp+4*regEAX], edi
        popad
        return

.goto_root:

        stdcall TextMakeRedirect, 0, txt "/"
        jmp     .finish
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




sqlGetThreadForPost text "select P.ThreadID, T.Slug, T.Limited from Posts P left join Threads T on P.threadID = T.id where P.id = ?"

sqlGetThePostIndex text "select count() from Posts p where threadID = ?1 and id < ?2"

proc StrRedirectToPost, .postID, .pSpecial
.stmt dd ?

.page dd ?
.slug dd ?
.limited dd ?

begin
        pushad

        mov     [.slug], 0

        mov     esi, [.pSpecial]

        stdcall StrDupMem, txt "/"
        mov     edi, eax

; get the thread ID and slug

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadForPost, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.postID]

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrDupMem, eax
        mov     [.slug], eax

        cinvoke sqliteColumnInt, [.stmt], 2
        mov     [.limited], eax

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

        cmp     [.limited], 0
        je      .limited_ok

        stdcall StrCat, edi, txt "(o)/"

.limited_ok:
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
        mov     [esp+4*regEAX], edi
        popad
        return

.error:
        cinvoke sqliteFinalize, [.stmt]
        jmp     .finish

endp


