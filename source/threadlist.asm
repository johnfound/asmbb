
iglobal
  sqlSelectThreads StripText "threadlist.sql", SQL
  sqlThreadsCount  StripText "threadcount.sql", SQL
endg

proc ListThreads, .pSpecial

.stmt  dd ?
.list  dd ?

begin
        pushad

        mov     esi, [.pSpecial]

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        test    [esi+TSpecialParams.userStatus], permRead or permAdmin
        jz      .error_cant_read

        cmp     [esi+TSpecialParams.Limited], 0
        je      .read_ok

        cmp     [esi+TSpecialParams.userID], 0
        je      .error_cant_read

.read_ok:
        stdcall LogUserActivity, esi, uaThreadList, 0
        stdcall AddActivitySimple, cActivityList, esi

; make the title

        mov     ebx, [esi+TSpecialParams.page_title]
        mov     eax, [esi+TSpecialParams.userLang]
        stdcall StrCat, ebx, [cThreadListTitle+8*eax]

        cmp     [esi+TSpecialParams.dir], 0
        je      .no_tag

        stdcall StrCat, ebx, [esi+TSpecialParams.dir]

.no_tag:
        stdcall StrCat, ebx, txt "/"

        cmp     [esi+TSpecialParams.page_num], 0
        je      .page_ok

        stdcall StrCat, ebx, " page: "
        stdcall NumToStr, [esi+TSpecialParams.page_num], ntsDec or ntsUnsigned
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

.page_ok:
        stdcall TextCat, edi, <txt '<div class="threads_list">', 13, 10>
        stdcall RenderTemplate, edx, "nav_list.tpl", 0, esi   ; navigation tool bar
        mov     edi, eax

; links to the pages.
        stdcall TextCreate, sizeof.TText
        mov     edx, eax

        stdcall TextAddStr2, edx, 0, sqlThreadsCount, sqlThreadsCount.length
        stdcall RenderTemplate, edx, 0, 0, esi
        stdcall TextCompact, eax
        push    edx

        lea     ecx, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], edx, eax, ecx, 0
        stdcall TextFree ; from the stack

        cmp     [esi+TSpecialParams.dir], 0
        je      .tag_ok

        stdcall StrPtr, [esi+TSpecialParams.dir]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

.tag_ok:
        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.userID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        stdcall CreatePagesLinks2, [esi+TSpecialParams.page_num], ebx, 0, [esi+TSpecialParams.page_length]
        mov     [.list], eax

        stdcall TextCat, edi, eax
        stdcall TextCat, edx, <txt '<div class="multi_content">', 13, 10>
        mov     edi, edx

; now append the list itself.

        stdcall TextCreate, sizeof.TText
        mov     edx, eax

        stdcall TextAddStr2, edx, 0, sqlSelectThreads, sqlSelectThreads.length

        stdcall RenderTemplate, edx, 0, 0, esi
        stdcall TextCompact, eax
        push    edx

; DEBUG ONLY!!!
;        pushad
;        stdcall FileWrite, [STDERR], edx, eax
;        stdcall FileWriteString, [STDERR], <txt 13, 10, 13, 10>
;        popad
; END OF DEBUG SECTION!

        lea     ecx, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], edx, eax, ecx, 0
        stdcall TextFree ; from the stack.

        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.page_length]

        mov     eax, [esi+TSpecialParams.page_num]
        imul    eax, [esi+TSpecialParams.page_length]
        cinvoke sqliteBindInt, [.stmt], 2, eax

        cinvoke sqliteBindInt, [.stmt], 3, [esi+TSpecialParams.userID]

        xor     ebx, ebx

        cmp     [esi+TSpecialParams.dir], 0
        je      .dir_ok

        stdcall StrPtr, [esi+TSpecialParams.dir]
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC

.dir_ok:

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish

        inc     ebx                     ; post count

        stdcall RenderTemplate, edi, "thread_info.tpl", [.stmt], esi
        mov     edi, eax
        jmp     .loop

.finish:
        stdcall TextCat, edi, <txt "</div>", 13, 10>   ; div.multi_content
        mov     edi, edx

        cmp     ebx, 5
        jbe     .back_navigation_ok

        stdcall TextCat, edi, [.list]
        stdcall RenderTemplate, edx, "nav_list.tpl", 0, esi
        mov     edi, eax

.back_navigation_ok:
        stdcall TextCat, edi, <txt "</div>", 13, 10>   ; div.threads_list
        mov     edi, edx

        stdcall StrDel, [.list]
        cinvoke sqliteFinalize, [.stmt]

        mov     [esp+4*regEAX], edi
        clc
        popad
        return


; the user have no permissions to read posts!
.error_cant_read:

        stdcall TextMakeRedirect, edi, "/!message/cant_read/"
        mov     [esp+4*regEAX], edi
        stc
        popad
        return


endp



