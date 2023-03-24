LIMIT_POST_LENGTH = 16*1024
LIMIT_POST_CAPTION = 512
LIMIT_TAG_DESCRIPTION = 1024

cNewPostForm     text "form_new_post.tpl"
cNewThreadForm   text "form_new_thread.tpl"

sqlSelectConst   text "select ?1 as slug, ?2 as caption, ?3 as source, ?4 as ticket, ?5 as tags, ?6 as limited, ?7 as invited, ?8 as UserName, ?9 as format"
sqlGetQuote      text "select U.nick, P.content from Posts P left join Users U on U.id = P.userID where P.id = ?"

sqlInsertPost    text "insert into Posts ( ThreadID, UserID, PostTime, Content, format) values (?, ?, strftime('%s','now'), ?, ?)"
sqlUpdateThreads text "update Threads set LastChanged = strftime('%s','now') where id = ?"
sqlInsertThread  text "insert into Threads ( Caption ) values ( ? )"
sqlSetThreadSlug text "update Threads set slug = ?1, Limited=?3 where id = ?2"


proc PostUserMessage, .pSpecial
.stmt  dd ?
.stmt2 dd ?

.slug     dd ?

.caption  dd ?
.tags     dd ?
.fLimited dd ?
.iFormat  dd ?
.invited  dd ?
.count    dd ?

.source   dd ?
.ticket   dd ?

.softPreview dd ?

begin
        pushad

        mov     esi, [.pSpecial]

        mov     eax, [esi+TSpecialParams.Limited]
        mov     [.fLimited], eax

        xor     eax, eax
        mov     [.softPreview], eax
        mov     [.slug], eax
        mov     [.source], eax
        mov     [.caption], eax
        mov     [.tags], eax
        mov     [.invited], eax
        mov     [.ticket], eax
        mov     [.stmt], eax
        mov     [.stmt2], eax

        stdcall GetParam, txt "default_format", gpInteger       ; eax must == 0 before this call.
        mov     [.iFormat], eax


        stdcall TextCreate, sizeof.TText
        mov     edi, eax

; check the permissions.

        mov     eax, permThreadStart
        cmp     [esi+TSpecialParams.thread], 0
        je      .perm_ok

        mov     eax, permPost

.perm_ok:
        or      eax, permAdmin

        test    [esi+TSpecialParams.userStatus], eax
        jz      .error_wrong_permissions

        stdcall LogUserActivity, esi, uaWritingPost, 0

; get the additional post/thread parameters

        cmp     [esi+TSpecialParams.thread], 0
        jne     .get_caption_from_thread


        cmp     [esi+TSpecialParams.post_array], 0
        je      .show_edit_form

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "title", 0
        mov     [.caption], eax
        test    eax, eax
        jz      .title_ok

        stdcall StrByteUtf8, [.caption], LIMIT_POST_CAPTION
        stdcall StrTrim, [.caption], eax

.title_ok:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "tags", 0
;        stdcall UniqueTagList, eax, [esi+TSpecialParams.dir]
        mov     [.tags], eax

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "limited", txt "0"
        push    eax
        stdcall StrToNumEx, eax
        stdcall StrDel ; from the stack
        mov     [.fLimited], eax

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "invited", 0
        mov     [.invited], eax

        jmp     .thread_ok


.get_caption_from_thread:

        lea     eax, [.stmt]

        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadInfo, sqlGetThreadInfo.length, eax, 0

        stdcall StrPtr, [esi+TSpecialParams.thread]
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

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "ticket", 0
        mov     [.ticket], eax

; get the source

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "source", 0
        mov     [.source], eax
        test    eax, eax
        jz      .source_ok2

        mov     eax, LIMIT_POST_LENGTH
        stdcall GetParam, 'max_post_length', gpInteger

        mov     ecx, [esi+TSpecialParams.userMaxPostLen]
        test    ecx, ecx
        jz      .max_len_ok

        cmp     eax, ecx
        cmovg   eax, ecx

.max_len_ok:
        stdcall StrByteUtf8, [.source], eax
        stdcall StrTrim, [.source], eax

.source_ok2:

; get the format.

        stdcall NumToStr, [.iFormat], ntsUnsigned or ntsDec
        push    eax
        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "format", eax
        push    eax
        stdcall StrToNumEx, eax
        stdcall StrDel ; from the stack
        stdcall StrDel ; from the stack
        mov     [.iFormat], eax

; check the post interval limits

        mov     ecx, [esi+TSpecialParams.userPostInterval]
        test    ecx, ecx
        jz      .interval_ok

        stdcall GetTime
        sub     eax, dword [esi+TSpecialParams.userLastPostTime]
        sbb     edx, dword [esi+TSpecialParams.userLastPostTime + 4]
        jnz     .show_edit_form

        cmp     eax, ecx
        jl      .show_edit_form

.interval_ok:
; ok, get the action then:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "submit", 0
        stdcall StrDel, eax
        test    eax, eax
        jnz     .create_post_and_exit

        cmp     [.source], 0
        jne     .show_edit_form

        mov     ebx, [esi+TSpecialParams.page_num]
        test    ebx, ebx
        jz      .show_edit_form

; get the quoted text

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetQuote, sqlGetQuote.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, ebx
        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_ROW
        jne     .finalize_quote

        xor     eax, eax
        inc     eax     ; Default MiniMag
        stdcall GetParam, txt "markup_languages", gpInteger
        test    eax, 1
        jnz     .minimag_quote

        pushx   txt "[/quote]", 13, 10
        pushx   txt "]"
        pushx   txt "[quote="
        jmp     .do_quote

.minimag_quote:
        pushx   txt 13, 10, ";end quote", 13, 10
        pushx   txt 13, 10
        pushx   ";quote "

.do_quote:
        stdcall StrDupMem       ; argument from the stack
        mov     [.source], eax          ; [.source] should be 0 at this point!!!

        cinvoke sqliteColumnText, [.stmt], 0    ; the user nick name.
        stdcall StrCat, [.source], eax

        stdcall StrCat, [.source]       ; the second argument from the stack.

        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrCat, [.source], eax

        stdcall StrCat, [.source]       ; the second argument from the stack.

.finalize_quote:

        cinvoke sqliteFinalize, [.stmt]


.show_edit_form:
        stdcall ValueByName, [esi+TSpecialParams.params], "QUERY_STRING"
        mov     ebx, eax

        stdcall GetQueryItem, ebx, txt "cmd=", 0
        test    eax, eax
        jz      .js_preview_ok

        stdcall StrCompNoCase, eax, "preview"
        stdcall StrDel, eax
        jnc     .js_preview_ok

        inc     [.softPreview]

.js_preview_ok:
        mov     eax, [esi+TSpecialParams.userLang]

        cmp     [.caption], 0
        je      .title_new_thread

        stdcall StrCat, [esi+TSpecialParams.page_title], [cPostingInTitle+8*eax]
        stdcall StrEncodeHTML, [.caption]
        stdcall StrCat, [esi+TSpecialParams.page_title], eax
        stdcall StrDel, eax
        jmp     .title_set

.title_new_thread:

        stdcall StrCat, [esi+TSpecialParams.page_title], [cNewThreadTitle+8*eax]

.title_set:

        cmp     [.ticket], 0
        jne     .ticket_ok

        stdcall SetUniqueTicket, [esi+TSpecialParams.session]
        jc      .error_bad_ticket

        mov     [.ticket], eax

.ticket_ok:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectConst, sqlSelectConst.length, eax, 0

        cmp     [esi+TSpecialParams.thread], 0
        je      .slug_ok

        stdcall StrPtr, [esi+TSpecialParams.thread]
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

        cinvoke sqliteBindInt, [.stmt], 6, [.fLimited]

        stdcall StrPtr, [.invited]
        test    eax, eax
        jz      .invited_ok

        cinvoke sqliteBindText, [.stmt], 7, eax, [eax+string.len], SQLITE_STATIC

.invited_ok:

        stdcall StrPtr, [esi+TSpecialParams.userName]
        test    eax, eax
        jz      .username_ok

        cinvoke sqliteBindText, [.stmt], 8, eax, [eax+string.len], SQLITE_STATIC

.username_ok:

        cinvoke sqliteBindInt, [.stmt], 9, [.iFormat]
        cinvoke sqliteStep, [.stmt]

; is it request from JS?
        shr     [.softPreview], 1
        jnc     .render_all

        stdcall TextAddStr2, edi, 0, cHeadersJSON, cHeadersJSON.length
        stdcall RenderTemplate, edx, "edit.json", [.stmt], esi
        mov     edi, eax

        cinvoke sqliteFinalize, [.stmt]

        stc
        jmp     .finish


.render_all:
        mov     ecx, cNewThreadForm
        cmp     [esi+TSpecialParams.thread], 0
        je      .make_form

        mov     ecx, cNewPostForm

.make_form:

        stdcall RenderTemplate, edi, ecx, [.stmt], esi
        mov     edi, eax

        stdcall RenderTemplate, edi, "preview.tpl", [.stmt], esi
        mov     edi, eax

        cinvoke sqliteFinalize, [.stmt]
        clc
        jmp     .finish


;...............................................................................................

.create_post_and_exit:

        cmp     [.caption], 0
        je      .show_edit_form

        cmp     [.source], 0
        je      .show_edit_form

; check the SEC_FETCH_MODE header. Only "navigate" mode is allowed.
        stdcall CheckSecMode, [esi+TSpecialParams.params]
        cmp     eax, secNavigate
        jne     .error_bad_ticket

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

        cmp     [esi+TSpecialParams.thread], 0
        je      .new_thread

        stdcall StrDup, [esi+TSpecialParams.thread]
        mov     [.slug], eax

        jmp     .post_in_thread


; create new thread, from the post data

.new_thread:

locals
  .threadID dd ?
endl

        DebugMsg "Create new thread"

        stdcall StrSlugify, [.caption]
        mov     [.slug], eax

        stdcall StrLen, eax
        test    eax, eax
        jz      .error_invalid_caption

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertThread, sqlInsertThread.length, eax, 0

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

        stdcall StrCat, [.slug], txt "."
        stdcall StrCat, [.slug], eax
        stdcall StrDel, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSetThreadSlug, sqlSetThreadSlug.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 2, [.threadID]

        cinvoke sqliteBindInt, [.stmt], 3, [.fLimited]

        stdcall StrPtr, [.slug]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

        DebugMsg "Thread is created. Write the tags"

; here process the tags

        stdcall SaveThreadTags, [.tags], [esi+TSpecialParams.dir], [.threadID]

        DebugMsg "Thread is created. Write invited."

; Process invited users for the limited access thread:
        stdcall SaveInvited, [.fLimited], [.invited], [esi+TSpecialParams.userName], [.threadID]

.post_in_thread:

        DebugMsg "Post in this thread."

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadInfo, sqlGetThreadInfo.length, eax, 0

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
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertPost, sqlInsertPost.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, ebx
        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.userID]

        cmp     [.source], 0
        je      .error_invalid_content

; bind the source

        stdcall StrPtr, [.source]

        mov     ecx, [eax+string.len]
        test    ecx, ecx
        jz      .error_invalid_content

        cinvoke sqliteBindText, [.stmt], 3, eax, ecx, SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 4, [.iFormat]

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

        cinvoke sqliteLastInsertRowID, [hMainDatabase]
        mov     esi, eax                                                ; ESI is now the inserted postID!!!!

; Save the attachments:

;        stdcall DumpPostArray, [.pSpecial]

;        stdcall DelAttachments, esi, [.pSpecial]        ; ??? what attachments to del???
        stdcall WriteAttachments, esi, [.pSpecial]
;       jc      .attachments_error_uploading            ; ??? What we should do here? Rollback? Ignore? Format the HDD?

; Update thread LastChanged

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateThreads, sqlUpdateThreads.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, ebx
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

; register as unread for all active users.

        stdcall RegisterUnreadPost, esi, ebx

; commit transaction

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCommit, sqlCommit.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

; Here the post has been written. Notify the users for the new post.

        stdcall UserNameLink, [.pSpecial]
        mov     ebx, eax
        push    edx             ; see below the AddActivity call

        mov     eax, DEFAULT_UI_LANG
        stdcall GetParam, "default_lang", gpInteger
        stdcall StrCat, ebx, [cActivityNewPost + 8*eax]

        stdcall StrCat, ebx, txt '<a href="/'

        stdcall NumToStr, esi, ntsDec or ntsUnsigned
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

        stdcall StrCat, ebx, txt '/!by_id">▶</a>'

        mov     eax, [.pSpecial]
        stdcall AddActivity, ebx, atPosting, [eax+TSpecialParams.userID] ; fBot flag from the stack.
        stdcall StrDel, ebx

; then redirect the user to the new post.

        stdcall StrRedirectToPost, esi, [.pSpecial]
        stdcall TextMakeRedirect, edi, eax
        stdcall StrDel, eax

.finish_clear:
        mov     eax, [.pSpecial]
        stdcall ClearTicket3, [.ticket]
        stc

.finish:
        stdcall StrDel, [.slug]
        stdcall StrDel, [.source]
        stdcall StrDel, [.caption]
        stdcall StrDel, [.tags]
        stdcall StrDel, [.invited]
        stdcall StrDel, [.ticket]

        mov     [esp+4*regEAX], edi
        popad
        return


.rollback:      ; the transaction failed because of unknown reason

        cinvoke sqliteFinalize, [.stmt]         ; finalize the bad statement.
        cinvoke sqliteFinalize, [.stmt2]        ; finalize the bad statement.

        call    .do_rollback

        mov     eax, [.pSpecial]
        stdcall TextMakeRedirect, edi, "/!message/error_cant_write/"
        jmp     .finish_clear


.error_invalid_caption:

        call    .do_rollback

        mov     eax, [.pSpecial]
        stdcall TextMakeRedirect, edi, "/!message/error_invalid_caption/"
        jmp     .finish_clear


.error_invalid_content:

        cinvoke sqliteFinalize, [.stmt]         ; finalize the bad statement.

        call    .do_rollback

        stdcall TextMakeRedirect, edi, "/!message/error_invalid_content"
        jmp     .finish_clear


.do_rollback:

        cinvoke sqliteExec, [hMainDatabase], sqlRollback, 0, 0, 0
        retn


.error_wrong_permissions:

        stdcall TextMakeRedirect, edi, "/!message/error_cant_post"
        jmp     .finish_clear



.error_thread_not_exists:

        stdcall TextMakeRedirect, edi, "/!message/error_thread_not_exists"
        jmp     .finish_clear


.error_bad_ticket:
        xor     eax, eax
        mov     [edi+TText.GapBegin], eax
        mov     eax, [edi+TText.Length]
        mov     [edi+TText.GapEnd], eax
        stdcall TextMakeRedirect, edi, "/!message/error_bad_ticket"
        jmp     .finish_clear
endp




sqlDelAllTags        text  "delete from ThreadTags where threadID = ?1"
sqlInsertTags        text  "insert or ignore into Tags (tag, description) values (lower(?1), ?2)"
sqlInsertThreadTags  text  "insert into ThreadTags(tag, threadID) values (lower(?1), ?2)"

proc SaveThreadTags, .tags, .dir, .threadID
.stmt  dd ?
.stmt2 dd ?
begin
        pushad

        xor     eax, eax
        mov     [.stmt], eax
        mov     [.stmt2], eax

; remove all tags

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDelAllTags, sqlDelAllTags.length, eax, 0
        test    eax, eax
        jnz     .end_del

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

.end_del:
        cmp     [.tags], 0
        je      .finish

        stdcall StrSplitList, [.tags], ",", FALSE
        mov     esi, eax

        stdcall UniqueTagList, esi, [.dir]

        mov     ebx, [esi+TArray.count] ; the count can be max 4
        test    ebx, ebx
        jz      .finish_list

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertTags, sqlInsertTags.length, eax, 0

        lea     eax, [.stmt2]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertThreadTags, sqlInsertThreadTags.length, eax, 0

        cinvoke sqliteBindInt,  [.stmt2], 2, [.threadID]

.tag_loop:
        dec     ebx
        js      .finish_tags

        stdcall StrSplitList, [esi+TArray.array+4*ebx], ":", FALSE
        mov     edi, eax

        cmp     [edi+TArray.count], 0   ; is it possible?
        je      .next_tag

        cmp     [edi+TArray.count], 2
        jb      .description_ok

        stdcall StrByteUtf8, [edi+TArray.array+4], LIMIT_TAG_DESCRIPTION
        stdcall StrTrim, [edi+TArray.array+4], eax

        stdcall StrPtr, [edi+TArray.array+4]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

.description_ok:

        stdcall StrTagify, [edi+TArray.array]
        stdcall StrPtr, [edi+TArray.array]

        cmp     [eax+string.len], 0
        je      .next_tag

        push    eax
        cinvoke sqliteBindText, [.stmt],  1, eax, [eax+string.len], SQLITE_STATIC

        pop     eax
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

.finish_list:

        stdcall ListFree, esi, StrDel

.finish:
        popad
        return
endp




proc UniqueTagList, .pList, .hDir
begin
        pushad
        mov     edx, [.pList]

        mov     edi, [.hDir]
        test    edi, edi
        jz      .outer

        stdcall StrDup, edi
        mov     edi, eax

        mov     ecx, [edx+TArray.count]

.remove_dir:
        dec     ecx
        js      .outer

        stdcall TagCmp, [edx+4*ecx+TArray.array], edi
        test    eax, eax
        jnz     .remove_dir

        stdcall StrLen, [edx+4*ecx+TArray.array]
        mov     ebx, eax

        stdcall StrLen, edi
        cmp     eax, ebx
        jae     .len_ok1

        pushd   [edx+4*ecx+TArray.array] edi
        popd    [edx+4*ecx+TArray.array] edi

.len_ok1:
        stdcall StrDel, [edx+4*ecx+TArray.array]
        stdcall DeleteArrayItems, edx, ecx, 1
        jmp     .remove_dir

.outer:
        DebugMsg "Sorting array"

        mov     ecx, [edx+TArray.count]
        xor     ebx, ebx

.inner:
        dec     ecx
        jle     .next

        stdcall TagCmp, [edx+4*ecx+TArray.array], [edx+4*ecx+TArray.array-4]
        test    eax, eax
        jns     .inner

        pushd   [edx+4*ecx+TArray.array] [edx+4*ecx+TArray.array-4]
        popd    [edx+4*ecx+TArray.array] [edx+4*ecx+TArray.array-4]
        inc     ebx
        jmp     .inner

.next:
        test    ebx, ebx
        jnz     .outer

        DebugMsg "Array sorted, remove duplicates."

        mov     ecx, [edx+TArray.count]

.unique:
        dec     ecx
        jle     .end_unique

        stdcall TagCmp, [edx+4*ecx+TArray.array], [edx+4*ecx+TArray.array-4]
        test    eax, eax
        jnz     .unique

        stdcall StrLen, [edx+4*ecx+TArray.array]
        mov     ebx, eax

        stdcall StrLen, [edx+4*ecx+TArray.array-4]
        cmp     eax, ebx
        jae     .len_ok

        pushd   [edx+4*ecx+TArray.array] [edx+4*ecx+TArray.array-4]   ; try to preserve the tag description.
        popd    [edx+4*ecx+TArray.array] [edx+4*ecx+TArray.array-4]

.len_ok:
        stdcall StrDel, [edx+4*ecx+TArray.array]
        stdcall DeleteArrayItems, edx, ecx, 1
        jmp     .unique

.end_unique:

        mov     ecx, 3
        test    edi, edi
        jnz     .do_free

        inc     ecx

.do_free:
        mov     ebx, ecx        ; the desired size of the array

.free_loop:
        cmp     ecx, [edx+TArray.count]
        jae     .end_free

        stdcall StrDel, [edx+4*ecx+TArray.array]
        inc     ecx
        jmp     .free_loop

.end_free:
        cmp     ebx, [edx+TArray.count]
        cmova   ebx, [edx+TArray.count]
        mov     [edx+TArray.count], ebx

        test    edi, edi
        jz      .finish

        stdcall AddArrayItems, edx, 1
        mov     [eax], edi
        xor     edi, edi

.finish:
        DebugMsg "Array sorted, remove duplicates."

        stdcall StrDel, edi
        mov     [esp+4*regESI], edx
        popad
        return
endp


proc TagCmp, .hTag1, .hTag2
begin
        pushad

        stdcall StrSplitList, [.hTag1], ":", FALSE
        mov     esi, eax

        stdcall StrSplitList, [.hTag2], ":", FALSE
        mov     edi, eax

        mov     eax, [esi+TArray.count]
        test    eax, eax
        lea     eax, [eax+1]
        jz      .finish

        mov     eax, [edi+TArray.count]
        dec     eax
        js      .finish

        stdcall StrCompSort2, [esi+TArray.array], [edi+TArray.array], FALSE

.finish:
        mov     [esp+4*regEAX], eax
        stdcall ListFree, esi, StrDel
        stdcall ListFree, edi, StrDel

        popad
        return
endp



sqlDelAllInvited  text  "delete from LimitedAccessThreads where threadID = ?1"
sqlInsertInvited  text  "insert into LimitedAccessThreads(threadID, userID) values (?1, ?2)"

proc SaveInvited, .fLimited, .invited, .self, .threadID
.stmt  dd ?
begin
        pushad

        xor     eax, eax
        mov     [.stmt], eax

; remove all currently invited users...

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDelAllInvited, sqlDelAllInvited.length, eax, 0
        test    eax, eax
        jnz     .end_del

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

.end_del:
        cmp     [.fLimited], 0
        je      .finish         ; only make the thread public!

        cmp     [.invited], 0
        jne     .split

        stdcall CreateArray, 4
        mov     esi, eax
        jmp     .process_list

.split:
        stdcall StrSplitList, [.invited], ",", FALSE
        mov     esi, eax

.process_list:
        stdcall UniqueInvitedList, esi, [.self]

        mov     ebx, [esi+TArray.count]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertInvited, sqlInsertInvited.length, eax, 0

.user_loop:
        dec     ebx
        js      .finish_users

        cinvoke sqliteBindInt,  [.stmt], 1, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 2, [esi+TArray.array + 4*ebx]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteClearBindings, [.stmt]
        cinvoke sqliteReset, [.stmt]
        jmp     .user_loop


.finish_users:

        stdcall FreeMem, esi
        cinvoke sqliteFinalize, [.stmt]

.finish:
        popad
        return
endp


sqlGetUserID text "select id from users where nick = ?1"

proc UniqueInvitedList, .pList, .hSelf
.stmt dd ?
begin
        pushad
        mov     edx, [.pList]

        mov     edi, [.hSelf]
        test    edi, edi
        jz      .outer

        mov     ecx, [edx+TArray.count]

.loop_remove_self:
        dec     ecx
        js      .outer

        stdcall StrCompNoCase, [edx+4*ecx+TArray.array], [.hSelf]
        jnc     .loop_remove_self

        stdcall StrDel, [edx+4*ecx+TArray.array]
        stdcall DeleteArrayItems, edx, ecx, 1
        jmp     .loop_remove_self

.outer:
        DebugMsg "Sorting invited array"

        mov     ecx, [edx+TArray.count]
        xor     ebx, ebx

.inner:
        dec     ecx
        jle     .next

        stdcall StrCompSort2, [edx+4*ecx+TArray.array], [edx+4*ecx+TArray.array-4], FALSE
        test    eax, eax
        jns     .inner

        pushd   [edx+4*ecx+TArray.array] [edx+4*ecx+TArray.array-4]
        popd    [edx+4*ecx+TArray.array] [edx+4*ecx+TArray.array-4]
        inc     ebx
        jmp     .inner

.next:
        test    ebx, ebx
        jnz     .outer

        DebugMsg "Array sorted, remove duplicated users."

        mov     ecx, [edx+TArray.count]

.unique:
        dec     ecx
        jle     .end_unique

        stdcall StrCompNoCase, [edx+4*ecx+TArray.array], [edx+4*ecx+TArray.array-4]
        jnc     .unique

        stdcall StrDel, [edx+4*ecx+TArray.array]
        stdcall DeleteArrayItems, edx, ecx, 1
        jmp     .unique

.end_unique:

; add self:

        stdcall StrDup, [.hSelf]
        mov     edi, eax

        stdcall AddArrayItems, edx, 1
        mov     [eax], edi

; now replace the nicks with IDs:

        mov     edi, edx

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUserID, sqlGetUserID.length, eax, 0

        mov     ebx, [edi+TArray.count]

.id_loop:
        dec     ebx
        js      .list_ok

        stdcall StrPtr, [edi+TArray.array + 4*ebx]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        je      .get_id

        stdcall StrDel, [edi+TArray.array + 4*ebx]
        stdcall DeleteArrayItems, edi, ebx, 1
        mov     edi, edx
        jmp     .next_user

.get_id:
        cinvoke sqliteColumnInt, [.stmt], 0
        xchg    eax, [edi+TArray.array + 4*ebx]
        stdcall StrDel, eax

.next_user:
        cinvoke sqliteReset, [.stmt]
        cinvoke sqliteClearBindings, [.stmt]
        jmp     .id_loop

.list_ok:
        cinvoke sqliteFinalize, [.stmt]
        mov     [esp+4*regESI], edi
        popad
        return
endp




proc SendNewPostNotifications, .postID, .threadSlug, .threadCaption, .forUser
begin


        return
endp