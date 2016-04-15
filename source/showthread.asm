
sqlSelectPosts StripText "showthread.sql", SQL

sqlGetPostCount  text "select count(1) from Posts where ThreadID = ?"
sqlGetThreadInfo text "select id, caption, slug from Threads where slug = ? limit 1"



proc ShowThread, .pSpecial

.stmt  dd ?
.stmt2 dd ?

.threadID dd ?

.list dd ?
.cnt  dd ?

;if defined options.DebugMode & options.DebugMode
;  .start dd ?
;end if

begin
        pushad

        stdcall StrNew
        mov     edi, eax
        mov     esi, [.pSpecial]

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

        stdcall StrCat, edi, '<div class="thread">'

        stdcall StrCatTemplate, edi, "nav_thread", [.stmt2], esi

        stdcall StrCat, edi, '<h1 class="thread_caption">'

        cinvoke sqliteColumnText, [.stmt2], 1

        stdcall StrEncodeHTML, eax
        stdcall StrCat, edi, eax
        stdcall StrCat, [esi+TSpecialParams.page_title], eax
        stdcall StrDel, eax

        stdcall StrCat, edi, '</h1>'


; pages links

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetPostCount, sqlGetPostCount.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]

        cinvoke sqliteStep, [.stmt]

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.cnt], eax

        cinvoke sqliteFinalize, [.stmt]


        stdcall CreatePagesLinks, [esi+TSpecialParams.page_num], [.cnt], 0
        mov     [.list], eax

        stdcall StrCat, edi, [.list]


;if defined options.DebugMode & options.DebugMode
;        stdcall GetFineTimestamp
;        mov     [.start], eax
;end if


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectPosts, sqlSelectPosts.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 2, PAGE_LENGTH

        mov     eax, [esi+TSpecialParams.page_num]
        imul    eax, PAGE_LENGTH
        cinvoke sqliteBindInt, [.stmt], 3, eax

        stdcall StrPtr, [esi+TSpecialParams.thread]
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 5, [esi+TSpecialParams.userID]

        mov     [.cnt], 0

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish

        inc     [.cnt]

        stdcall StrCatTemplate, edi, "post_view", [.stmt], esi

        cinvoke sqliteColumnInt, [.stmt], 0

        stdcall PostIncrementReadCount, eax

        mov     ebx, [esi+TSpecialParams.userID]
        test    ebx, ebx
        jz      .loop

        stdcall SetPostRead, ebx, eax

        jmp     .loop


.finish:

;if defined options.DebugMode & options.DebugMode
;        stdcall GetFineTimestamp
;        sub     eax, [.start]
;
;        OutputValue "Thread fetch query time [us]: ", eax, 10, -1
;end if

        cmp     [.cnt], 5
        jbe     .back_navigation_ok

        stdcall StrCat, edi, [.list]
        stdcall StrCatTemplate, edi, "nav_thread", [.stmt2], esi

.back_navigation_ok:

        stdcall StrDel, [.list]

        stdcall StrCat, edi, "</div>"   ; div.thread

        cinvoke sqliteFinalize, [.stmt]

.exit:

        cinvoke sqliteFinalize, [.stmt2]

        cinvoke sqliteExec, [hMainDatabase], sqlCommit, 0, 0, 0

        clc
        mov     [esp+4*regEAX], edi
        popad
        return

.error:
        stdcall StrDel, edi
        xor     edi, edi
        jmp     .exit

endp







proc PostByID, .pSpecial
begin
        pushad

        mov     esi, [.pSpecial]

        cmp     [esi+TSpecialParams.page_num], 0
        je      .err404

        stdcall StrNew
        stdcall StrCatRedirectToPost, eax, [esi+TSpecialParams.page_num], esi

        stc

.finish:
        mov     [esp+4*regEAX], eax
        popad
        return

.err404:
        xor     eax, eax
        clc
        jmp     .finish

endp




sqlGetThreadID text "select P.ThreadID, T.Slug from Posts P left join Threads T on P.threadID = T.id where P.id = ?"

sqlGetThePostIndex text "select count() from Posts p where threadID = ?1 and id < ?2 order by id"

proc StrCatRedirectToPost, .hString, .postID, .pSpecial
.stmt dd ?

.page dd ?
.slug dd ?

begin
        pushad

        mov     [.slug], 0

        mov     esi, [.pSpecial]

        stdcall StrCat, [.hString], <"Status: 302 Found", 13, 10, "Location: /">

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

        mov     ecx, PAGE_LENGTH
        div     ecx
        mov     [.page], eax

        cinvoke sqliteFinalize, [.stmt]

; now compose the redirection string

        cmp     [esi+TSpecialParams.dir], 0
        je      .dir_ok

        stdcall StrCat, [.hString], [esi+TSpecialParams.dir]
        stdcall StrCharCat, [.hString], "/"

.dir_ok:
        stdcall StrCat, [.hString], [.slug]
        stdcall StrCharCat, [.hString], "/"

        cmp     [.page], 0
        je      .page_ok

        stdcall NumToStr, [.page], ntsDec or ntsUnsigned
        stdcall StrCat, [.hString], eax
        stdcall StrDel, eax

.page_ok:
        stdcall StrCharCat, [.hString], "#"

        stdcall NumToStr, [.postID], ntsDec or ntsUnsigned
        stdcall StrCat, [.hString], eax
        stdcall StrDel, eax

.finish:

        stdcall StrCharCat, [.hString], $0a0d0a0d
        stdcall StrDel, [.slug]

        popad
        return

.error:
        cinvoke sqliteFinalize, [.stmt]
        jmp     .finish

endp


