
sqlGetUsersList  StripText "userslist.sql", SQL
sqlGetUsersCount text "select count() from users;"


proc UsersList, .pSpecial
.stmt dd ?
.cnt  dd ?
.list dd ?
begin
        pushad

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        mov     esi, [.pSpecial]

        stdcall LogUserActivity, esi, uaReadingUserlist, 0

        mov     edx, [esi+TSpecialParams.cmd_list]
        mov     eax, [edx+TArray.count]
        test    eax, eax
        jz      .page_ok1

        stdcall StrToNumEx, [edx+TArray.array]
        mov     [esi+TSpecialParams.page_num], eax

.page_ok1:

; make the title

        mov     ebx, [esi+TSpecialParams.page_title]

        stdcall StrCat, ebx, txt ' Users list'

        cmp     [esi+TSpecialParams.page_num], 0
        je      .page_ok

        stdcall StrCat, ebx, ", page: "
        stdcall NumToStr, [esi+TSpecialParams.page_num], ntsDec or ntsUnsigned
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

.page_ok:
        mov     [esi+TSpecialParams.page_title], ebx

        stdcall TextCat, edi, txt '<div class="users_list">'
        stdcall RenderTemplate, edx, "nav_userslist.tpl", 0, esi
        mov     edi, eax

; pages links

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUsersCount, sqlGetUsersCount.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.cnt], eax
        cinvoke sqliteFinalize, [.stmt]

        xor     ebx, ebx
        stdcall GetQueryParam, esi, txt "sort="
        jc      .suffix_ok

        test    eax, eax
        jz      .suffix_ok

        push    eax eax
        stdcall StrDupMem, "?sort="
        mov     ebx, eax
        stdcall StrCat, ebx ; from the stack
        stdcall StrDel ; from the stack

.suffix_ok:
        stdcall CreatePagesLinks2, [esi+TSpecialParams.page_num], [.cnt], ebx, [esi+TSpecialParams.page_length]
        mov     [.list], eax

        stdcall StrDel, ebx

        stdcall TextCat, edi, [.list]
        stdcall RenderTemplate, edx, 'userslist_hdr.tpl', 0, esi
        mov     edi, eax

        stdcall TextCreate, sizeof.TText
        mov     ebx, eax

        stdcall TextAddStr2, ebx, 0, sqlGetUsersList, sqlGetUsersList.length
        stdcall RenderTemplate, edx, 0, 0, esi
        stdcall TextCompact, eax
        mov     ebx, edx

        lea     ecx, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], ebx, eax, ecx, 0
        stdcall TextFree, ebx

        cmp     eax, SQLITE_OK
        jne     .end_users

        mov     ebx, [esi+TSpecialParams.page_length]
        cinvoke sqliteBindInt, [.stmt], 1, ebx

        imul    ebx, [esi+TSpecialParams.page_num]
        cinvoke sqliteBindInt, [.stmt], 2, ebx

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .end_users

        stdcall RenderTemplate, edi, "one_user.tpl", [.stmt], esi
        mov     edi, eax

        jmp     .loop

.end_users:

        cinvoke sqliteFinalize, [.stmt]

        stdcall TextCat, edi, txt "</table>"
        stdcall TextCat, edx, [.list]
        stdcall RenderTemplate, edx, "nav_userslist.tpl", 0, esi
        stdcall TextCat, eax, txt "</div>"

        mov     [esp+4*regEAX], edx
        clc
        popad
        return
endp