LIMIT_POST_LENGTH = 16*1024
LIMIT_POST_CAPTION = 512
LIMIT_TAG_DESCRIPTION = 1024


sqlGetQuote      text "select U.nick, P.content, P.format from Posts P left join Users U on U.id = P.userID where P.id = ?"

sqlInsertThread  text "insert into Threads ( Limited ) values ( ?1 )"
sqlInsertPost    text "insert into Posts ( ThreadID, UserID, Content, format) values (?1, ?2, ?3, ?4)"

sqlCheckForDrafts text "select P.id as PostID, T.ID as ThreadID, T.Caption, T.slug, T.LastChanged, ?2 as Ticket from posts P left join threads T on P.threadid = T.id where P.userID = ?1 and P.postTime is null"
sqlDelDraftPost   text "delete from posts where id = ?1"
sqlDelDraftThread text "delete from threads where id = ?1"


proc PostUserMessage, .pSpecial
.stmt  dd ?

.threadID dd ?
.postID   dd ?

.draftPostID    dd ?
.draftThreadID  dd ?
.draftNewThread dd ?

.source   dd ?
.ticket   dd ?

.fLimited dd ?
.iFormat  dd ?

begin
        pushad

        mov     esi, [.pSpecial]

        mov     eax, [esi+TSpecialParams.Limited]
        mov     [.fLimited], eax

        xor     eax, eax
        mov     [.threadID], eax
        mov     [.postID], eax
        mov     [.draftPostID], eax
        mov     [.draftThreadID], eax
        mov     [.draftNewThread], eax
        mov     [.source], eax
        mov     [.ticket], eax
        mov     [.iFormat], eax

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

        cmp     [esi+TSpecialParams.thread], 0
        je      .thread_ok

; get existing thread ID

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadID, sqlGetThreadID.length, eax, 0

        stdcall StrPtr, [esi+TSpecialParams.thread]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_thread_not_exists

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.threadID], eax

        cinvoke sqliteFinalize, [.stmt]

.thread_ok:

; check for existing draft

        stdcall SetUniqueTicket, [esi+TSpecialParams.session]
        jc      .error_bad_ticket

        mov     [.ticket], eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCheckForDrafts, sqlCheckForDrafts.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.userID]

        stdcall StrPtr, [.ticket]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cmp     eax, SQLITE_ROW
        jne     .finalize_check_drafts

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.draftPostID], eax

        cinvoke sqliteColumnInt, [.stmt], 1
        mov     [.draftThreadID], eax

        cinvoke sqliteColumnType, [.stmt], 4    ; LastChanged
        cmp     eax, SQLITE_NULL
        jne     @f
        inc     [.draftNewThread]
@@:
        cmp     [esi+TSpecialParams.post_array], 0
        je      .show_form_dialog

.finalize_check_drafts:
        cinvoke sqliteFinalize, [.stmt]

        cmp     [esi+TSpecialParams.post_array], 0
        je      .create_post_and_edit


.execute_post_request:

; ok, get the action:

;        stdcall DumpPostArray, esi

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt 'ticket', 0
        push    eax

        stdcall CheckTicket, eax, [esi+TSpecialParams.session]
        stdcall StrDel ; from the stack
        jc      .error_bad_ticket

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "action", 0
        push    eax

        test    eax, eax
        jz      .cancel_action

        stdcall StrCompNoCase, eax, txt "delete"
        jc      .delete_draft

        stdcall StrCompNoCase, eax, txt "edit"
        jc      .edit_draft


.cancel_action:
; redirect to back.
        stdcall StrDel ; from the stack

        stdcall TextMakeRedirect, edi, txt "." ;; eax
        jmp     .finish_clear


.edit_draft:
        stdcall StrDel ; from the stack

        push    [.draftPostID]

.redirect_to_editor:
        stdcall StrDupMem, txt "/"
        mov     ebx, eax

        pop     eax
        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

        stdcall StrCat, ebx, "/!edit"
        stdcall TextMakeRedirect, edi, ebx
        jmp     .finish_clear


.delete_draft:
        stdcall StrDel ; from the stack

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDelDraftPost, sqlDelDraftPost.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.draftPostID]
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_thread_not_exists

        cmp     [.draftNewThread], 0
        je      .create_post_and_edit

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDelDraftThread, sqlDelDraftThread.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.draftThreadID]
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_thread_not_exists


; create the post/thread and redirect to the editor.

.create_post_and_edit:

        stdcall LogUserActivity, esi, uaWritingPost, 0

; get default post format.

        xor     ecx, ecx
        xor     eax, eax
        stdcall GetParam, txt "markup_languages", gpInteger

.floop:
        shr     eax, 1
        lea     ecx, [ecx+1]
        jz      .format_ok
        jnc     .floop

.format_ok:
        mov     [.iFormat], ecx

        mov     ebx, [esi+TSpecialParams.page_num]
        test    ebx, ebx
        jz      .quote_ok

; get the quoted text

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetQuote, sqlGetQuote.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, ebx

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finalize_quote

        cinvoke sqliteColumnInt, [.stmt], 2     ; format.
        mov     [.iFormat], eax

        cmp     eax, 1  ; MiniMag
        je      .minimag_quote

;.bbcode_quote:
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

        cinvoke sqliteColumnText, [.stmt], 1    ; the quoted post content.
        stdcall StrCat, [.source], eax

        stdcall StrCat, [.source]       ; the second argument from the stack.

.finalize_quote:

        cinvoke sqliteFinalize, [.stmt]

.quote_ok:

; now, create the new post and if needed a new thread.

; begin transaction!
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlBegin, sqlBegin.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

        cmp     [.threadID], 0
        jne     .post_in_thread

; create new thread, from the post data

        DebugMsg "Create new thread"

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertThread, sqlInsertThread.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.fLimited]

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

        cinvoke sqliteLastInsertRowID, [hMainDatabase]
        mov     [.threadID], eax

        cmp     [esi+TSpecialParams.dir], 0
        je      .tags_ok

; here process the tags
        DebugMsg "Thread is created. Write the tags"
        stdcall SaveThreadTags, 0, [esi+TSpecialParams.dir], [.threadID]

.tags_ok:
; Process invited users for the limited access thread:
        DebugMsg "Thread is created. Write invited."
        stdcall SaveInvited, [.fLimited], 0, [esi+TSpecialParams.userName], [.threadID]

.post_in_thread:
        DebugMsg "Post in this thread."

; insert new post

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlInsertPost, sqlInsertPost.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.userID]

        stdcall StrPtr, [.source]
        test    eax, eax
        jz      @f
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC
@@:
        cinvoke sqliteBindInt, [.stmt], 4, [.iFormat]

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]
        cinvoke sqliteLastInsertRowID, [hMainDatabase]
        mov     [.postID], eax

; commit transaction

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCommit, sqlCommit.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

; redirect to the editor

        push    [.postID]
        jmp     .redirect_to_editor


.show_form_dialog:

        stdcall RenderTemplate, edi, txt "form_draft_dlg.tpl", [.stmt], esi
        mov     edi, eax

        cinvoke sqliteFinalize, [.stmt]
        clc
        jmp     .finish


.finish_clear:
        stdcall ClearTicket3, [.ticket]
        stc

.finish:
        stdcall StrDel, [.source]
        stdcall StrDel, [.ticket]

        mov     [esp+4*regEAX], edi
        popad
        return


.rollback:      ; the transaction failed because of unknown reason

        cinvoke sqliteFinalize, [.stmt]         ; finalize the bad statement.

        call    .do_rollback

        mov     eax, [.pSpecial]
        stdcall TextMakeRedirect, edi, "/!message/error_cant_write/"
        jmp     .finish_clear


.error_invalid_caption:

        call    .do_rollback

        mov     eax, [.pSpecial]
        stdcall TextMakeRedirect, edi, "/!message/error_invalid_caption/"
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

; empty the TText structure.
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
        jne     .split

        stdcall CreateArray, 4
        mov     esi, eax
        jmp     .process_list

.split:
        stdcall StrSplitList, [.tags], ",", FALSE
        mov     esi, eax

.process_list:
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



; Not implemented personalized notifications. ;)
proc SendNewPostNotifications, .postID, .threadSlug, .threadCaption, .forUser
begin


        return
endp