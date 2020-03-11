

proc DecryptionKey, .pSpecial
.stmt dd ?
begin
        pushad
        mov     esi, [.pSpecial]

        cmp     [esi+TSpecialParams.post_array], 0
        jne     .try_to_decrypt

; render the password page:

        stdcall TextCreate, sizeof.TText
        mov     edx, eax

        stdcall TextCat, edx, <"Content-type: text/html; charset=utf-8", 13, 10, 13, 10>
        stdcall RenderTemplate, edx, 'crypto.tpl', 0, esi
        mov     [esp+4*regEAX], eax

        stc
        popad
        return


.try_to_decrypt:

        stdcall ValueByName, [esi+TSpecialParams.post_array], 'pagesize'
        jc      .page_size_ok

        test    eax, eax
        jz      .page_size_ok

        stdcall StrToNumEx, eax
        jc      .page_size_ok

        cmp     eax, 512
        jb      .page_size_ok
        cmp     eax, 65536
        ja      .page_size_ok

        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        push    eax eax

        stdcall StrDupMem, "pragma page_size="
        stdcall StrCat, eax ; from the stack
        stdcall StrDel ; from the stack

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteExec, [hMainDatabase], eax, 0, 0, 0
        stdcall StrDel ; from the stack

.page_size_ok:

        stdcall ValueByName, [esi+TSpecialParams.post_array], 'initpass'
        jc      .redirect

        test    eax, eax
        jz      .redirect

        push    eax
        stdcall StrMD5, eax
        stdcall StrNull ; from the stack

        push    eax eax eax

        stdcall StrDupMem, "pragma key='"
        mov     ebx, eax

        stdcall StrCat, ebx ; from the stack
        stdcall StrNull     ; from the stack
        stdcall StrDel      ; from the stack

        stdcall StrCat, ebx, txt "';"

        lea     edx, [.stmt]
        stdcall StrPtr, ebx
        cinvoke sqlitePrepare_v2, [hMainDatabase], eax, [eax+string.len],  edx, 0
        cinvoke sqliteStep, [.stmt]
        mov     esi, eax
        cinvoke sqliteFinalize, [.stmt]

        stdcall StrNull, ebx
        stdcall StrDel, ebx

        cmp     esi, SQLITE_ROW
        jne     .redirect

        xor     eax, eax
        mov     [fNeedKey], eax

        stdcall SetDatabaseMode

.redirect:
        stdcall TextMakeRedirect, 0, txt "/"
        mov     [esp+4*regEAX], edi
        stc
        popad
        return
endp



proc StrNull, .hString
begin
        cmp     [.hString], 0
        je      .finish

        pushad

        stdcall StrPtr, [.hString]
        mov     edi, eax
        mov     edx, [eax+string.len]

        xor     eax, eax
        mov     [edi+string.len], eax

        mov     ecx, edx
        shr     ecx, 2
        rep stosd

        mov     ecx, edx
        and     ecx, 3
        rep stosb

        popad

.finish:
        return
endp