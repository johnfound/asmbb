
sqlReadCats StripText 'categories.sql', SQL

proc Categories, .pSpecial
.stmt dd ?
begin
        pushad

        mov     esi, [.pSpecial]

        stdcall StrCat, [esi+TSpecialParams.page_title], ' Categories'

        stdcall TextCreate, sizeof.TText
        stdcall TextCat, eax, '<div class="threads_list">'
        stdcall RenderTemplate, edx, "nav_categories.tpl", 0, esi
        mov     edi, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlReadCats, sqlReadCats.length, eax, 0
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

        stdcall TextCat, edi, '</div>'
        mov     [esp+4*regEAX], edx

        clc
        popad
        return
endp