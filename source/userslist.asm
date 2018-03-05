

sqlGetUsersList  text "select nick, status, av_time, ",                                         \
                      "strftime('%d.%m.%Y %H:%M:%S', Register, 'unixepoch') as Registered, ",   \
                      "strftime('%d.%m.%Y %H:%M:%S', LastSeen, 'unixepoch') as LastSeen,   ",   \
                      "Skin, PostCount from users order by PostCount desc limit ?2 offset ?3"

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

        stdcall CreatePagesLinks2, [esi+TSpecialParams.page_num], [.cnt], 0, [esi+TSpecialParams.page_length]
        mov     [.list], eax

        stdcall TextCat, edi, [.list]
        stdcall TextCat, edx, txt '<table><tr><th>User</th><th>Avatar</th><th>Post count</th><th>Registered</th><th>Last seen</th></tr>'
        mov     edi, edx

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUsersList, sqlGetUsersList.length, eax, 0

;        cinvoke sqliteBindText, [.stmt], 1, txt "PostCount desc", -1, SQLITE_STATIC

        mov     ebx, [esi+TSpecialParams.page_length]
        cinvoke sqliteBindInt, [.stmt], 2, ebx

        imul    ebx, [esi+TSpecialParams.page_num]
        cinvoke sqliteBindInt, [.stmt], 3, ebx

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