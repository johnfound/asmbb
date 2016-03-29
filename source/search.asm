
; select rowid, Content from PostFTS where PostFTS match 'post OR sim*';
;
; select rowid, highlight(PostFTS, 0, '<u>', '</u>') from PostFTS where PostFTS match 'post OR sim*';


sqlSearchCnt text "select count() from PostFTS where PostFTS match ?"

sqlSearch text "select ",                                                                                                       \
                 "U.nick as UserName, ",                                                                                        \
                 "T.slug, ",                                                                                                    \
                 "strftime('%d.%m.%Y %H:%M:%S', P.postTime, 'unixepoch') as PostTime, ",                                        \
                 "P.ReadCount, ",                                                                                               \
                 "PostFTS.rowid, ",                                                                                             \
                 "snippet(PostFTS, 0, '', '', '...', 16) as Content, ",                                                         \
                 "T.Caption ",                                                                                                  \
               "from PostFTS ",                                                                                                 \
               "left join Posts P on P.id = PostFTS.rowid ",                                                                    \
               "left join Threads T on T.id = P.threadID ",                                                                     \
               "left join Users U on P.userID = U.id ",                                                                         \
               "where PostFTS match ? order by rank limit ? offset ?"


proc ShowSearchResults, .start, .pSpecial
.query      dd ?
.pages      dd ?

.query_orig dd ?        ; don't free it!


.stmt       dd ?

begin
        pushad

        mov     esi, [.pSpecial]

        stdcall ValueByName, [esi+TSpecialParams.params], "QUERY_STRING"
        jc      .missing_query

        mov     [.query_orig], eax

        stdcall StrLen, eax
        test    eax, eax
        jz      .missing_query

        stdcall StrDup, [.query_orig]
        push    eax

        stdcall StrSplit, eax, 2
        stdcall StrDel ; from the stack

        stdcall StrURLDecode, eax
        mov     [.query], eax   ; only the query string!


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSearchCnt, sqlSearchCnt.length, eax, 0

        stdcall StrPtr, [.query]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteColumnInt, [.stmt], 0
        mov     edi, eax
        cinvoke sqliteFinalize, [.stmt]

        OutputValue "Results count:", edi, 10, -1

        mov     [.pages], edi
        test    edi, edi
        jz      .pages_ok

        stdcall CreatePagesLinks, "/search/", [.query_orig], [.start], edi
        mov     [.pages], eax

.pages_ok:
        stdcall StrNew
        mov     edi, eax

        stdcall StrCat, edi, '<div class="thread">'

        stdcall StrCatTemplate, edi, "nav_search", 0, esi

        cmp     [.pages], 0
        je      .search_ok

        stdcall StrCat, edi, [.pages]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSearch, sqlSearch.length, eax, 0

        stdcall StrPtr, [.query]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 2, PAGE_LENGTH

        mov     eax, [.start]
        imul    eax, PAGE_LENGTH
        cinvoke sqliteBindInt, [.stmt], 3, eax

.search_loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finalize

        stdcall StrCatTemplate, edi, "search_result", [.stmt], esi

        jmp     .search_loop

.finalize:

        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDel, [.query]

        stdcall StrCat, edi, [.pages]
        stdcall StrDel, [.pages]

        stdcall StrCatTemplate, edi, "nav_search", 0, esi

.search_ok:
        stdcall StrCat, edi, '</div>'

        clc

.finish:
        mov     [esp+4*regEAX], edi
        popad
        return



.missing_query:


        stdcall StrMakeRedirect, 0, "/message/missing_query/"
        mov     edi, eax
        stc
        jmp     .finish

endp