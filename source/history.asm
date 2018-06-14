
sqlPostHistory StripText "posthistory.sql", SQL


proc ShowHistory, .pSpecial
.stmt dd ?
.cnt  dd ?
begin
        pushad

        xor     edi, edi
        mov     esi, [.pSpecial]
        mov     [.cnt], edi

        cmp     [esi+TSpecialParams.page_num], edi
        je      .exit                                   ; CF = 0 and EDI=0 ---> error 404

        test    [esi+TSpecialParams.userStatus], permAdmin
        jz      .perm_error

        stdcall StrCat, [esi+TSpecialParams.page_title], cHistoryTitle

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        stdcall LogUserActivity, esi, uaAdminThings, 0

        stdcall TextCat, edi, txt '<div class="thread">'
        stdcall RenderTemplate, edx, "nav_history.tpl", 0, esi
        mov     edi, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlPostHistory, sqlPostHistory.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.page_num]

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .end_query

        cinvoke sqliteColumnType, [.stmt], 0
        mov     ebx, eax
        cmp     ebx, SQLITE_NULL
        jne     .current_ok

        stdcall TextAddStr2, edi, -1, '<div class="current_version">', 100
        mov     edi, edx

.current_ok:
        stdcall RenderTemplate, edi, "post_history.tpl", [.stmt], esi
        mov     edi, eax

        cmp     ebx, SQLITE_NULL
        jne     .current_ok2

        stdcall TextAddStr2, edi, -1, '</div>', 100
        mov     edi, edx

.current_ok2:

        inc     [.cnt]
        jmp     .loop

.end_query:
        cinvoke sqliteFinalize, [.stmt]

        cmp     [.cnt], 5
        jbe     .back_navigation_ok

        stdcall RenderTemplate, edi, "nav_history.tpl", 0, esi
        mov     edi, eax

.back_navigation_ok:

        stdcall TextCat, edi, txt "</div>"   ; div.thread
        mov     edi, edx

.exit:
        clc
        mov     [esp+4*regEAX], edi
        popad
        return

.perm_error:
        stdcall TextMakeRedirect, 0, "/!message/only_for_admins"

        stc
        mov     [esp+4*regEAX], edi
        popad
        return
endp



sqlRestoreConfirmInfo text "select rowid as version, postID, Content, ?2 as Ticket from PostsHistory where rowid = ?1"
sqlGetPostVersion     text "select postID, threadID, userID, postTime, editUserID, editTime, Content from PostsHistory where rowid = ?1"
sqlRestorePost StripText "restore.sql", SQL

proc RestorePost, .pSpecial
.stmt  dd ?
.stmt2 dd ?
.postid dd ?
begin
        pushad

        xor     edi, edi
        xor     ebx, ebx
        mov     [.postid], ebx

        mov     esi, [.pSpecial]
        cmp     [esi+TSpecialParams.page_num], edi
        je      .exit                                   ; CF = 0 and EDI=0 ---> error 404

        test    [esi+TSpecialParams.userStatus], permAdmin
        jz      .perm_error

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        stdcall LogUserActivity, esi, uaAdminThings, 0

        cmp     [esi+TSpecialParams.post_array], 0
        jne     .post_request

; get request, show the confirmation form:

        stdcall SetUniqueTicket, [esi+TSpecialParams.session]
        jc      .perm_error

        mov     ebx, eax

        stdcall StrCat, [esi+TSpecialParams.page_title], cPostRestoreTitle

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlRestoreConfirmInfo, sqlDelConfirmInfo.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.page_num]

        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        je      .render

.error_missing_row:

        stdcall TextMakeRedirect, edi, "/!message/error_post_not_exists"
        stc
        jmp     .finalize

.render:
        stdcall RenderTemplate, edi, "restore_confirm.tpl", [.stmt], esi
        mov     edi, eax
        clc

.finalize:
        pushf
        cinvoke sqliteFinalize, [.stmt]
        popf

.exit:
        stdcall StrDel, ebx
        mov     [esp+4*regEAX], edi
        popad
        return

.perm_error:
        stdcall TextMakeRedirect, edi, "/!message/only_for_admins"
        stc
        jmp     .exit


.post_request:

        stdcall GetPostString, [esi+TSpecialParams.post_array], "ticket", 0
        test    eax, eax
        jz      .perm_error1



        mov     ebx, eax
        stdcall CheckTicket, ebx, [esi+TSpecialParams.session]
        stdcall ClearTicket3, ebx
        jc      .perm_error2

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetPostVersion, sqlGetPostVersion.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.page_num]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_missing_row

        lea     eax, [.stmt2]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlRestorePost, sqlRestorePost.length, eax, 0

        cinvoke sqliteColumnInt, [.stmt], 0     ; postID
        mov     [.postid], eax
        cinvoke sqliteBindInt, [.stmt2], 8, eax

        cinvoke sqliteColumnInt, [.stmt], 1     ; threadID
        cinvoke sqliteBindInt, [.stmt2], 1, eax

        cinvoke sqliteColumnType, [.stmt], 2
        cmp     eax, SQLITE_NULL
        je      .userid_ok
        cinvoke sqliteColumnInt, [.stmt], 2     ; userID
        cinvoke sqliteBindInt, [.stmt2], 2, eax
.userid_ok:

        cinvoke sqliteColumnType, [.stmt], 3
        cmp     eax, SQLITE_NULL
        je      .posttime_ok
        cinvoke sqliteColumnInt, [.stmt], 3     ; postTime
        cinvoke sqliteBindInt, [.stmt2], 3, eax
.posttime_ok:

        cinvoke sqliteColumnType, [.stmt], 4
        cmp     eax, SQLITE_NULL
        je      .edituser_ok
        cinvoke sqliteColumnInt, [.stmt], 4     ; editUserID
        cinvoke sqliteBindInt, [.stmt2], 4, eax
.edituser_ok:

        cinvoke sqliteColumnType, [.stmt], 5
        cmp     eax, SQLITE_NULL
        je      .edittime_ok
        cinvoke sqliteColumnInt, [.stmt], 5     ; editTime
        cinvoke sqliteBindInt, [.stmt2], 5, eax
.edittime_ok:

        push    esi edi ebx

        cinvoke sqliteColumnBytes, [.stmt], 6
        mov     ebx, eax
        cinvoke sqliteColumnText, [.stmt], 6
        mov     esi, eax
        cinvoke sqliteBindText, [.stmt2], 6, esi, ebx, SQLITE_STATIC

        stdcall FormatPostText2, esi, [.pSpecial]
        mov     edi, eax

        stdcall StrPtr, edi
        cinvoke sqliteBindText, [.stmt2], 7, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt2]
        push    eax

        cinvoke sqliteFinalize, [.stmt2]
        stdcall StrDel, edi

        pop     eax ebx edi esi
        cmp     eax, SQLITE_DONE
        je      .restored_ok

;        OutputValue "Error writing SQLite: ", eax, 10, -1
;
;        cinvoke sqliteErrMsg, [hMainDatabase]
;        stdcall FileWriteString, [STDERR], eax
;        stdcall FileWriteString, [STDERR], cCRLF2

        stdcall TextMakeRedirect, edi, "/!message/error_cant_write"
        stc
        jmp     .finalize

.perm_error1:
        DebugMsg "No ticket get!"
        jmp      .perm_error

.perm_error2:
        DebugMsg "Wrong ticket value!"
        jmp      .perm_error


.restored_ok:


        stdcall NumToStr, [.postid], ntsDec or ntsUnsigned
        push    eax
        stdcall StrInsert, eax, txt '/', 0
        stdcall StrCat, eax, "/!by_id"
        stdcall TextMakeRedirect, edi, eax
        stdcall StrDel ; from the stack
        stc
        jmp     .finalize


endp




