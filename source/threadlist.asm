


sqlSelectThreads text "select ",                                                                                                                                \
                                                                                                                                                                \
                        "T.id, ",                                                                                                                               \
                        "T.Slug, ",                                                                                                                             \
                        "Caption, ",                                                                                                                            \
                        "strftime('%d.%m.%Y %H:%M:%S', LastChanged, 'unixepoch') as TimeChanged, ",                                                             \
                        "(select count() from posts where threadid = T.id) as PostCount, ",                                                                     \
                        "(select count() from posts P, UnreadPosts U where P.id = U.PostID and P.threadID = T.id and U.userID = ?3 ) as Unread, ",              \
                        "(select P2.userid from posts P2 where threadid =T.id order by P2.id limit 1) as StarterID, ",                                          \
                        "UU.nick as StarterName, ",                                                                                                             \
                        "T.Pinned ",                                                                                                                            \
                                                                                                                                                                \
                      "from Threads T left join Users UU on UU.id = StarterID ",                                                                                \
                                                                                                                                                                \
                      "where ?4 is null or ?4 in (select tag from threadtags tt where tt.threadid = t.id) ",                                                    \
                      "order by Pinned desc, T.LastChanged desc ",                                                                                              \
                                                                                                                                                                \
                      "limit  ?1 ",                                                                                                                             \
                      "offset ?2 "

sqlThreadsCount  text "select count(1) from Threads t where ?1 is null or ?1 in (select tag from threadtags tt where tt.threadid = t.id)"


proc ListThreads, .pSpecial

.stmt  dd ?
.list  dd ?

begin
        pushad

        mov     esi, [.pSpecial]

        stdcall StrNew
        mov     edi, eax

; make the title

        mov     ebx, [esi+TSpecialParams.page_title]
        stdcall StrCat, ebx, "Threads list "

        cmp     [esi+TSpecialParams.dir], 0
        je      .no_tag

        stdcall StrCat, ebx, [esi+TSpecialParams.dir]

.no_tag:
        stdcall StrCharCat, ebx, "/"

        cmp     [esi+TSpecialParams.page_num], 0
        je      .page_ok

        stdcall StrCat, ebx, " page: "
        stdcall NumToStr, [esi+TSpecialParams.page_num], ntsDec or ntsUnsigned
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

.page_ok:
        mov     [esi+TSpecialParams.page_title], ebx


        stdcall StrCat, edi, '<div class="threads_list">'

; navigation tool bar

        stdcall StrCatTemplate, edi, "nav_list", 0, esi


; links to the pages.
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlThreadsCount, -1, eax, 0

        cmp     [esi+TSpecialParams.dir], 0
        je      .tag_ok

        stdcall StrPtr, [esi+TSpecialParams.dir]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

.tag_ok:
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        stdcall CreatePagesLinks2, [esi+TSpecialParams.page_num], ebx
        mov     [.list], eax

        stdcall StrCat, edi, eax

; now append the list itself.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectThreads, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, PAGE_LENGTH

        mov     eax, [esi+TSpecialParams.page_num]
        imul    eax, PAGE_LENGTH
        cinvoke sqliteBindInt, [.stmt], 2, eax

        cinvoke sqliteBindInt, [.stmt], 3, [esi+TSpecialParams.userID]

        xor     ebx, ebx

        cmp     [esi+TSpecialParams.dir], 0
        je      .loop

        stdcall StrPtr, [esi+TSpecialParams.dir]
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish

        inc     ebx                     ; post count

        stdcall StrCatTemplate, edi, "thread_info", [.stmt], esi

        jmp     .loop


.finish:
        cmp     ebx, 5
        jbe     .back_navigation_ok

        stdcall StrCat, edi, [.list]
        stdcall StrCatTemplate, edi, "nav_list", 0, esi

.back_navigation_ok:
        stdcall StrCat, edi, "</div>"   ; div.threads_list

        stdcall StrDel, [.list]
        cinvoke sqliteFinalize, [.stmt]

        mov     [esp+4*regEAX], edi
        popad
        return
endp



