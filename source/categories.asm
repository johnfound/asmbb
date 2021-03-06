
sqlReadCats StripText 'categories.sql', SQL

proc Categories, .pSpecial
.stmt dd ?
begin
        pushad

        mov     esi, [.pSpecial]
        test    [esi+TSpecialParams.userStatus], permRead or permAdmin
        jz      .error_cant_read

        stdcall LogUserActivity, esi, uaCategoriesList, 0

        stdcall StrCat, [esi+TSpecialParams.page_title], ' Categories'

        stdcall TextCreate, sizeof.TText
        stdcall TextCat, eax, '<div class="threads_list">'
        stdcall RenderTemplate, edx, "nav_categories.tpl", 0, esi
        stdcall TextCat, eax, '<div class="multi_content">'
        mov     edi, edx

        stdcall TextCreate, sizeof.TText
        mov     edx, eax

        stdcall TextAddStr2, edx, 0, sqlReadCats, sqlReadCats.length
        stdcall RenderTemplate, edx, 0, 0, esi
        stdcall TextCompact, eax
        push    edx

        lea     ecx, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], edx, eax, ecx, 0
        stdcall TextFree ; from the stack

        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.userID]

.loop:
        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_ROW
        jne     .end_cats

        stdcall RenderTemplate, edi, "one_category.tpl", [.stmt], esi
        mov     edi, eax
        jmp     .loop

.end_cats:
        cinvoke sqliteFinalize, [.stmt]

        stdcall TextCat, edi, '</div></div>'
        mov     [esp+4*regEAX], edx

        clc
        popad
        return

; the user have no permissions to read posts!
.error_cant_read:

        stdcall TextMakeRedirect, 0, "/!message/cant_read/"
        mov     [esp+4*regEAX], edi
        stc
        popad
        return


endp