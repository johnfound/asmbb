


sqlSelectPosts   text "select ",                                                                                        \
                                                                                                                        \
                        "Posts.id, ",                                                                                   \
                        "Posts.threadID, ",                                                                             \
                        "strftime('%d.%m.%Y %H:%M:%S', Posts.postTime, 'unixepoch') as PostTime, ",                     \
                        "Posts.Content, ",                                                                              \
                        "Users.id as UserID, ",                                                                         \
                        "Users.nick as UserName,",                                                                      \
                        "(select count() from Posts X where X.userID = Posts.UserID) as UserPostCount, ",               \
                        "?4 as Slug, ",                                                                                 \
                        "(select count() from UnreadPosts U where UserID = ?5 and PostID = Posts.id) as Unread, ",      \
                        "ReadCount ",                                                                                   \
                                                                                                                        \
                      "from ",                                                                                          \
                                                                                                                        \
                        "Posts left join Users on ",                                                                    \
                          "Users.id = Posts.userID ",                                                                   \
                                                                                                                        \
                      "where ",                                                                                         \
                                                                                                                        \
                        "threadID = ?1 ",                                                                               \
                                                                                                                        \
                      "order by ",                                                                                      \
                                                                                                                        \
                        "Posts.id ",                                                                                    \
                                                                                                                        \
                      "limit ?2 ",                                                                                      \
                      "offset ?3"

sqlGetPostCount text "select count(1) from Posts where ThreadID = ?"

sqlGetThreadInfo text "select id, caption, slug from Threads where slug = ? limit 1"



proc ShowThread, .threadSlug, .start, .pSpecial

.stmt  dd ?
.stmt2 dd ?

.threadID dd ?

.list dd ?
.cnt  dd ?

begin
        pushad

        stdcall StrNew
        mov     edi, eax

        mov     esi, [.pSpecial]

        lea     eax, [.stmt2]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadInfo, -1, eax, 0

        stdcall StrPtr, [.threadSlug]
        cinvoke sqliteBindText, [.stmt2], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt2]
        cmp     eax, SQLITE_ROW
        jne     .error

        cinvoke sqliteColumnInt, [.stmt2], 0
        mov     [.threadID], eax

        OutputValue "Thread ID:", eax, 10, -1

        stdcall StrCat, edi, '<div class="thread">'

        stdcall StrCatTemplate, edi, "nav_thread", [.stmt2], esi

        stdcall StrCat, edi, '<h1 class="thread_caption">'

        cinvoke sqliteColumnText, [.stmt2], 1

        stdcall StrEncodeHTML, eax
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        stdcall StrCat, edi, '</h1>'


; pages links

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetPostCount, -1, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.cnt], eax
        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDup, txt "/threads/"
        stdcall StrCat, eax, [.threadSlug]
        stdcall StrCharCat, eax, "/"

        stdcall CreatePagesLinks, eax, 0, [.start], [.cnt]
        mov     [.list], eax

        stdcall StrCat, edi, [.list]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectPosts, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 2, PAGE_LENGTH

        mov     eax, [.start]
        imul    eax, PAGE_LENGTH
        cinvoke sqliteBindInt, [.stmt], 3, eax

        stdcall StrPtr, [.threadSlug]
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
        cmp     [.cnt], 5
        jbe     .back_navigation_ok

        stdcall StrCat, edi, [.list]
        stdcall StrCatTemplate, edi, "nav_thread", [.stmt2], esi

.back_navigation_ok:
        stdcall StrDel, [.list]
        stdcall StrCat, edi, "</div>"   ; div.thread

        cinvoke sqliteFinalize, [.stmt]
        cinvoke sqliteFinalize, [.stmt2]

        clc
        mov     [esp+4*regEAX], edi
        popad
        return

.error:
        cinvoke sqliteFinalize, [.stmt2]
        stdcall StrDel, edi
        stc
        popad
        return

endp






