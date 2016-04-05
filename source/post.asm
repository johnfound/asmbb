LIMIT_POST_LENGTH = 16*1024
LIMIT_POST_CAPTION = 512
LIMIT_TAG_DESCRIPTION = 1024


cNewPostForm   text "new_post_form"
cNewThreadForm text "new_thread_form"

sqlSelectConst text "select ? as slug, ? as caption, ? as source, ? as ticket, ? as tags"

sqlGetQuote   text "select U.nick, P.content from Posts P left join Users U on U.id = P.userID where P.id = ?"

sqlInsertPost text "insert into Posts ( ThreadID, UserID, PostTime, Content, ReadCount) values (?, ?, strftime('%s','now'), ?, 0)"
sqlUpdateThreads text "update Threads set LastChanged = strftime('%s','now') where id = ?"
sqlInsertThread  text "insert into Threads ( Caption ) values ( ? )"
sqlSetThreadSlug text "update Threads set slug = ? where id = ?"


proc PostUserMessage2, .hSlug, .idQuote, .pSpecial
.stmt  dd ?
.stmt2 dd ?

.fPreview dd ?

.slug     dd ?

.caption  dd ?
.tags     dd ?
.count    dd ?

.source   dd ?
.ticket   dd ?

.postID   dd ?
.threadID dd ?

begin
        pushad

        xor     eax, eax
        mov     [.fPreview], eax  ; preview by default when handling GET requests.
        mov     [.slug], eax
        mov     [.source], eax
        mov     [.caption], eax
        mov     [.tags], eax
        mov     [.ticket], eax
        mov     [.stmt], eax
        mov     [.stmt2], eax

        mov     esi, [.pSpecial]

        stdcall StrNew
        mov     edi, eax

; check the permissions.

        mov     eax, permThreadStart
        cmp     [.hSlug], 0
        je      .perm_ok

        mov     eax, permPost

.perm_ok:
        or      eax, permAdmin

        test    [esi+TSpecialParams.userStatus], eax
        jz      .error_wrong_permissions


; get the additional post/thread parameters

        cmp     [.hSlug], 0
        jne     .get_caption_from_thread


        cmp     [esi+TSpecialParams.post], 0
        je      .show_edit_form

        stdcall GetQueryItem, [esi+TSpecialParams.post], "title=", 0
        mov     [.caption], eax
        test    eax, eax
        jz      .title_ok

        stdcall StrByteUtf8, [.caption], 512
        stdcall StrTrim, [.caption], eax

.title_ok:

        stdcall GetQueryItem, [esi+TSpecialParams.post], "tags=", 0
        mov     [.tags], eax
        test    eax, eax
        jz      .tags_ok

        cmp     [esi+TSpecialParams.tag], 0
        je      .tags_ok

        stdcall StrCharCat, [.tags], ', '
        stdcall StrCat, [.tags], [esi+TSpecialParams.tag]

.tags_ok:
        jmp     .thread_ok


.get_caption_from_thread:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadInfo, -1, eax, 0

        stdcall StrPtr, [.hSlug]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_ROW
        jne     .error_thread_not_exists

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrDupMem, eax
        mov     [.caption], eax

        cinvoke sqliteFinalize, [.stmt]

.thread_ok:

; get the ticket if any

        stdcall GetQueryItem, [esi+TSpecialParams.post], "ticket=", 0
        mov     [.ticket], eax

; get the source

        stdcall GetQueryItem, [esi+TSpecialParams.post], "source=", 0
        mov     [.source], eax
        test    eax, eax
        jz      .source_ok2

        stdcall StrByteUtf8, [.source], LIMIT_POST_LENGTH
        stdcall StrTrim, [.source], eax

.source_ok2:

; ok, get the action then:

        stdcall GetQueryItem, [esi+TSpecialParams.post], "submit=", 0
        stdcall StrDel, eax
        test    eax, eax
        jnz     .create_post_and_exit


        stdcall GetQueryItem, [esi+TSpecialParams.post], "preview=", 0
        stdcall StrDel, eax
        mov     [.fPreview], eax


        cmp     [.idQuote], 0
        je      .show_edit_form

        cmp     [.source], 0
        jne     .show_edit_form

; get the quoted text

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetQuote, -1, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.idQuote]
        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_ROW
        jne     .finalize_quote

        stdcall StrDupMem, ";quote "
        mov     [.source], eax          ; [.source] should be 0 at this point!!!

        cinvoke sqliteColumnText, [.stmt], 0    ; the user nick name.

        stdcall StrCat, [.source], eax
        stdcall StrCharCat, [.source], $0a0d

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrCat, [.source], eax

        stdcall StrCat, [.source], <13, 10, ";end quote", 13, 10>

.finalize_quote:

        cinvoke sqliteFinalize, [.stmt]


.show_edit_form:

        stdcall StrCat, edi, <"Status: 200 OK", 13, 10, "Content-type: text/html", 13, 10, 13, 10>
        stdcall StrCatTemplate, edi, "main_html_start", 0, esi

        cmp     [.ticket], 0
        jne     .ticket_ok

        stdcall SetUniqueTicket, [esi+TSpecialParams.session]
        jc      .error_bad_ticket

        mov     [.ticket], eax

.ticket_ok:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectConst, -1, eax, 0

        cmp     [.hSlug], 0
        je      .slug_ok

        stdcall StrPtr, [.hSlug]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

.slug_ok:

        cmp     [.caption], 0
        je      .caption_ok

        stdcall StrPtr, [.caption]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

.caption_ok:

        cmp     [.source], 0
        je      .source_ok

        stdcall StrPtr, [.source]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

.source_ok:

        stdcall StrPtr, [.ticket]
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC

        cmp     [.tags], 0
        je      .tags_zero

        stdcall StrPtr, [.tags]
        cinvoke sqliteBindText, [.stmt], 5, eax, [eax+string.len], SQLITE_STATIC

.tags_zero:

        cinvoke sqliteStep, [.stmt]

        mov     ecx, cNewThreadForm
        cmp     [.hSlug], 0
        je      .make_form

        mov     ecx, cNewPostForm

.make_form:

        stdcall StrCatTemplate, edi, ecx, [.stmt], esi

        cmp     [.fPreview], 0
        je      .preview_ok

        stdcall StrCatTemplate, edi, "preview", [.stmt], esi

.preview_ok:

        cinvoke sqliteFinalize, [.stmt]

        stdcall StrCatTemplate, edi, "main_html_end", 0, esi
        jmp     .finish


;...............................................................................................

.create_post_and_exit:

; check the ticket

        stdcall CheckTicket, [.ticket], [esi+TSpecialParams.session]
        jc      .error_bad_ticket

; begin transaction!

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlBegin, sqlBegin.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

        cmp     [.hSlug], 0
        je      .new_thread

        stdcall StrDup, [.hSlug]
        mov     [.slug], eax

        jmp     .post_in_thread


; create new thread, from the post data

.new_thread:

        stdcall StrSlugify, [.caption]
        mov     [.slug], eax
        stdcall StrLen, eax
        test    eax, eax
        jz      .error_invalid_caption

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertThread, -1, eax, 0

        cmp     [.caption], 0
        je      .rollback

        stdcall StrPtr, [.caption]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

        cinvoke sqliteLastInsertRowID, [hMainDatabase]
        mov     [.threadID], eax

        stdcall NumToStr, eax, ntsDec or ntsUnsigned

        stdcall StrCharCat, [.slug], "."
        stdcall StrCat, [.slug], eax
        stdcall StrDel, eax


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSetThreadSlug, sqlSetThreadSlug.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 2, [.threadID]

        stdcall StrPtr, [.slug]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

; here process the tags

        cmp     [.tags], 0
        je      .post_in_thread

        pushad

        stdcall StrSplitList, [.tags], ",", FALSE
        mov     esi, eax

        mov     ebx, [esi+TArray.count]

        test    ebx, ebx
        jz      .finish_tags

        mov     [.count], 4

sqlInsertTags        text "insert or ignore into Tags (tag, description) values (lower(?), ?)"
sqlInsertThreadTags  text "insert into ThreadTags(tag, threadID) values (lower(?), ?)"


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertTags, sqlInsertTags.length, eax, 0
        test    eax, eax
        jnz     .rollback

        lea     eax, [.stmt2]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertThreadTags, sqlInsertThreadTags.length, eax, 0
        test    eax, eax
        jnz     .rollback

        cinvoke sqliteBindInt,  [.stmt2], 2, [.threadID]

.tag_loop:
        dec     ebx
        js      .finish_tags

        dec     [.count]
        js      .finish_tags    ; 4 tags limit!

        stdcall StrSplitList, [esi+TArray.array+4*ebx], ":", FALSE
        mov     edi, eax

        cmp     [edi+TArray.count], 0
        je      .next_tag

        cmp     [edi+TArray.count], 2
        jb      .description_ok

        stdcall StrByteUtf8, [edi+TArray.array+4], LIMIT_TAG_DESCRIPTION
        stdcall StrTrim, [edi+TArray.array+4]

        stdcall StrPtr, [edi+TArray.array+4]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

.description_ok:

        stdcall StrTagify, [edi+TArray.array]

        stdcall StrPtr, [edi+TArray.array]

        cmp     [eax+string.len], 0
        je      .next_tag

        cinvoke sqliteBindText, [.stmt],  1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [edi+TArray.array]
        cinvoke sqliteBindText, [.stmt2], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]

        cinvoke sqliteStep, [.stmt2]

        cinvoke sqliteClearBindings, [.stmt]
        cinvoke sqliteReset, [.stmt]
        cinvoke sqliteReset, [.stmt2]

.next_tag:
        stdcall ListFree, edi, StrDel
        jmp     .tag_loop

.finish_tags:
        cinvoke sqliteFinalize, [.stmt]
        cinvoke sqliteFinalize, [.stmt2]

        stdcall ListFree, esi, StrDel

        popad


.post_in_thread:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadInfo, -1, eax, 0

        stdcall StrPtr, [.slug]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .rollback

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]

; insert new post

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertPost, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, ebx
        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.userID]

        cmp     [.source], 0
        je      .error_invalid_content

        stdcall StrPtr, [.source]

        mov     ecx, [eax+string.len]
        test    ecx, ecx
        jz      .error_invalid_content

        cinvoke sqliteBindText, [.stmt], 3, eax, ecx, SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

        cinvoke sqliteLastInsertRowID, [hMainDatabase]
        mov     esi, eax                                                ; ESI is now the inserted postID!!!!

; Update thread LastChanged

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateThreads, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, ebx
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

; register as unread for all active users.

        stdcall RegisterUnreadPost, esi

; commit transaction

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCommit, -1, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

        mov     eax, [.pSpecial]
        stdcall StrCatRedirectToPost, edi, esi, [eax+TSpecialParams.tag]

.finish_clear:
        mov     eax, [.pSpecial]
        stdcall ClearTicket, [eax+TSpecialParams.session]

.finish:
        stdcall StrDelNull, [.slug]
        stdcall StrDelNull, [.source]
        stdcall StrDelNull, [.caption]
        stdcall StrDelNull, [.tags]
        stdcall StrDelNull, [.ticket]

        mov     [esp+4*regEAX], edi
        popad
        return


.rollback:      ; the transaction failed because of unknown reason

        cinvoke sqliteFinalize, [.stmt]         ; finalize the bad statement.
        cinvoke sqliteFinalize, [.stmt2]        ; finalize the bad statement.

        call    .do_rollback

        stdcall StrMakeRedirect, edi, "/message/error_cant_write/"
        jmp     .finish_clear


.error_invalid_caption:

        call    .do_rollback
        stdcall StrMakeRedirect, edi, "/message/error_invalid_caption/"
        jmp     .finish_clear


.error_invalid_content:

        cinvoke sqliteFinalize, [.stmt]         ; finalize the bad statement.
        call    .do_rollback

        stdcall StrMakeRedirect, edi, "/message/error_invalid_content"
        jmp     .finish_clear


.do_rollback:

        cinvoke sqliteExec, [hMainDatabase], sqlRollback, 0, 0, 0

        retn


.error_wrong_permissions:

        stdcall StrMakeRedirect, edi, "/message/error_cant_post"
        jmp     .finish_clear



.error_thread_not_exists:

        stdcall StrMakeRedirect, edi, "/message/error_thread_not_exists"
        jmp     .finish_clear


.error_bad_ticket:
        stdcall StrDel, edi
        stdcall StrMakeRedirect, 0, "/message/error_bad_ticket"
        mov     edi, eax
        jmp     .finish_clear



endp




