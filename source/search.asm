

;sqlSearchCnt    StripText "search_cnt.sql", SQL
;sqlSearchPrefix  StripText "search.sql", SQL

sqlSearchPrefix text    "select ",                                                                                              \
                        "  PostFTS.rowid, ",                                                                                    \
                        "  PostFTS.user as UserName, ",                                                                          \
                        "  P.userID, ",                                                                                         \
                        "  U.av_time as AVer, ",                                                                                \
                        "  PostFTS.slug, ",                                                                                     \
                        "  strftime('%d.%m.%Y %H:%M:%S', P.postTime, 'unixepoch') as PostTime, ",                               \
                        "  P.ReadCount, ",                                                                                      \
                        "  snippet(PostFTS, PostFTS.Content, '*', '*', '...', 16) as Content, ",                                  \
                        "  PostFTS.Caption, ",                                                                                  \
                        "  (select count() from UnreadPosts UP where UP.UserID = ?4 and UP.PostID = PostFTS.rowid) as Unread ", \
                        "from ",                                                                                                \
                        "  PostFTS ",                                                                                           \
                        "  left join Posts P on P.id = PostFTS.rowid ",                                                         \
                        "  left join Users U on U.id = P.userID "


sqlSearchCntPrefix text "select count() from PostFTS "

sqlSearchWhere text    " where PostFTS match  ?1 "
sqlOrderBy     text    " order by "
sqlSearchLimit text    " limit ?2 "
sqlSearchOffs  text    " offset ?3 "


proc ShowSearchResults2, .hStart, .pSpecial
.pages      dd ?
.stmt       dd ?
.query_str  dd ?        ; don't free it at the end.
.query      dd ?
.order      dd ?
.start      dd ?

.sql_search dd ?
.sql_cnt    dd ?

.hLinkArg     dd ?

.sqlSearchCnt dd ?
.sqlSearch    dd ?

begin
        pushad

        stdcall StrNew
        mov     [.query], eax

        stdcall StrNew
        mov     [.order], eax

        mov     esi, [.pSpecial]

        mov     eax, [.hStart]
        test    eax, eax
        jz      .start_ok

        stdcall StrToNumEx, eax

.start_ok:
        mov     [.start],eax

        stdcall ValueByName, [esi+TSpecialParams.params], "QUERY_STRING"
        jc      .missing_query

        mov     [.query_str], eax

        stdcall GetQueryItem, [.query_str], txt "s=", 0
        test    eax, eax
        jz      .txt_ok

        push    eax
        stdcall StrLen, eax
        test    eax, eax
        jz      .free_txt

        mov     eax, [esp]
        stdcall StrCat, [.query], txt '( content: '
        stdcall StrCat, [.query], eax
        stdcall StrCat, [.query], ' OR caption: '
        stdcall StrCat, [.query], eax
        stdcall StrCat, [.query], txt ')'

        stdcall StrCat, [.order], txt " order by rank"

.free_txt:
        stdcall StrDel ; from the stack

.txt_ok:
        stdcall GetQueryItem, [.query_str], txt "u=", 0
        test    eax, eax
        jz      .user_ok

        push    eax
        stdcall StrLen, eax
        test    eax, eax
        jz      .user_free

        mov     eax, [esp]
        stdcall StrCatNotEmpty, [.query], txt " AND "
        stdcall StrCat, [.query], txt 'user: '
        stdcall StrCat, [.query], eax

.user_free:
        stdcall StrDel ; from the stack

.user_ok:
        cmp     [esi+TSpecialParams.thread], 0
        je      .slug_ok

        stdcall StrCatNotEmpty, [.query], txt " AND "
        stdcall StrCat, [.query], txt 'slug: "'
        stdcall StrCat, [.query], [esi+TSpecialParams.thread]
        stdcall StrCat, [.query], txt '"'

.slug_ok:
        cmp     [esi+TSpecialParams.dir], 0
        je      .tags_ok

        stdcall StrCatNotEmpty, [.query], txt " AND "
        stdcall StrCat, [.query], txt 'tags: "'
        stdcall StrCat, [.query], [esi+TSpecialParams.dir]
        stdcall StrCat, [.query], txt '"'

.tags_ok:

        stdcall StrLen, [.order]
        test    eax, eax
        jnz     .order_ok

        stdcall StrCat, [.order], txt " order by P.postTime desc"

.order_ok:

;        stdcall FileWriteString, [STDERR], [.order]
;        stdcall FileWriteString, [STDERR], cCRLF2

; Create SQL queries depending on the search options.

        stdcall StrDupMem, sqlSearchCntPrefix
        mov     ebx, eax

        stdcall StrDupMem, sqlSearchPrefix
        mov     edi, eax

        stdcall StrLen, [.query]
        test    eax, eax
        jz      .where_ok

        stdcall StrCat, ebx, sqlSearchWhere
        stdcall StrCat, edi, sqlSearchWhere

.where_ok:
        stdcall StrCat, edi, [.order]
        stdcall StrCat, edi, sqlSearchLimit

        cmp     [.start], 0
        je      .offs_ok

        stdcall StrCat, edi, sqlSearchOffs

.offs_ok:

        mov     [.sql_cnt], ebx
        mov     [.sql_search], edi

;        stdcall FileWriteString, [STDERR], [.sql_cnt]
;        stdcall FileWriteString, [STDERR], cCRLF2
;
;        stdcall FileWriteString, [STDERR], [.sql_search]
;        stdcall FileWriteString, [STDERR], cCRLF2

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; counts the number of the search results in order to make the page links.

        lea     ecx, [.stmt]
        stdcall StrPtr, [.sql_cnt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], eax, [eax+string.len], ecx, 0

        stdcall StrPtr, [.query]
        cmp     [eax+string.len], 0
        je      .match_ok

        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

.match_ok:

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteColumnInt, [.stmt], 0
        mov     edi, eax
        cinvoke sqliteFinalize, [.stmt]

        mov     [.pages], edi
        test    edi, edi
        jz      .pages_ok

        stdcall StrDupMem, txt "?"
        stdcall StrCat, eax, [.query_str]
        push    eax

        stdcall CreatePagesLinks2, [.start], edi, eax, [esi+TSpecialParams.page_length]
        stdcall StrDel ; from the stack
        mov     [.pages], eax

.pages_ok:

; end of the page generation: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;        stdcall FileWriteString, [STDERR], [.query]
;        stdcall FileWriteString, [STDERR], cCRLF2

        stdcall StrNew
        mov     edi, eax

        stdcall StrCat, edi, '<div class="thread">'

        stdcall StrCatTemplate, edi, "nav_search.tpl", 0, esi

        cmp     [.pages], 0
        je      .search_ok      ; this means the total results count is 0, not the pages.

        stdcall StrCat, edi, [.pages]

        lea     ecx, [.stmt]
        stdcall StrPtr, [.sql_search]
        cinvoke sqlitePrepare_v2, [hMainDatabase], eax, [eax+string.len], ecx, 0

        stdcall StrPtr, [.query]
        cmp     [eax+string.len], 0
        je      .match_ok2

        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

.match_ok2:

        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.page_length]

        mov     eax, [.start]
        imul    eax, [esi+TSpecialParams.page_length]
        cinvoke sqliteBindInt, [.stmt], 3, eax
        cinvoke sqliteBindInt, [.stmt], 4, [esi+TSpecialParams.userID]

.search_loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finalize

        stdcall StrCatTemplate, edi, "search_result.tpl", [.stmt], esi

        jmp     .search_loop

.finalize:

        cinvoke sqliteFinalize, [.stmt]

        stdcall StrCat, edi, [.pages]
        stdcall StrDel, [.pages]

        stdcall StrCatTemplate, edi, "nav_search.tpl", 0, esi

.search_ok:
        stdcall StrCat, edi, '</div>'

        clc

.finish:
        stdcall StrDel, [.order]
        stdcall StrDel, [.query]
        stdcall StrDel, [.sql_cnt]
        stdcall StrDel, [.sql_search]
        mov     [esp+4*regEAX], edi
        popad
        return


.missing_query:

        stdcall StrMakeRedirect, 0, "/!message/missing_query/"
        mov     edi, eax
        stc
        jmp     .finish
endp



proc StrCatNotEmpty, .hDest, .hSuffix
begin
        pushad

        stdcall StrLen, [.hDest]

        OutputValue "StrCatNotEmpty length: ", eax, 10, -1

        test    eax, eax
        jz      @f

        stdcall StrCat, [.hDest], [.hSuffix]

@@:
        popad
        return
endp