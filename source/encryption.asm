

proc DecryptionKey, .pSpecial
.stmt dd ?
begin
        pushad
        mov     esi, [.pSpecial]

        cmp     [esi+TSpecialParams.post_array], 0
        jne     .try_to_decrypt

; render the password page:

        stdcall RenderTemplate, 0, 'crypto.tpl', 0, esi
        mov     [esp+4*regEAX], eax
        stc
        popad
        return


.try_to_decrypt:

        stdcall StrDupMem, "pragma key='"
        mov     ebx, eax

        stdcall ValueByName, [esi+TSpecialParams.post_array], 'initpass'
        jc      .redirect

        push    eax
        stdcall StrMD5, eax
        stdcall StrNull ; from the stack

        stdcall StrCat, ebx, eax
        stdcall StrNull, eax
        stdcall StrDel, eax

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
        mov     ecx, [eax+string.len]
        xor     eax, eax
        mov     [edi+string.len], eax
        rep stosb

        popad

.finish:
        return
endp