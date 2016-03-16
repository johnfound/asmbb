

proc InitScriptVariables
begin

; first read document root.
        stdcall GetEnvVariable, 'SCRIPT_FILENAME'
        jnc     .root_ok

        stdcall StrDupMem, txt "./"

.root_ok:
        mov     [hDocRoot], eax
        stdcall StrSplitFilename, eax
        stdcall StrDel, eax

; then read query string

        stdcall GetEnvVariable, 'QUERY_STRING'
        jnc     .query_ok

        stdcall StrNew

.query_ok:
        mov     [hQuery], eax

; parse query arguments

        stdcall GetQueryItem, [hQuery], txt 'cmd=', txt '0'
        push    eax

        stdcall StrToNum, eax
        mov     [Command], eax

        stdcall StrDel ; from the stack


        clc
        return
endp




proc GetQueryItem, .hQuery, .itemname, .default
begin
        push    ecx esi

        stdcall StrLen, [.itemname]
        mov     ecx, eax

        stdcall StrPos, [.hQuery], [.itemname]
        jnz     .item_found

        mov     eax, [.default]
        test    eax, eax
        jz      .finish

        stdcall StrDupMem, eax
        jmp     .item_ok

.item_found:
        lea     esi, [eax+ecx]
        stdcall StrCharPos, esi, '&'
        jnz     .copy_item

        stdcall StrLen, esi
        lea     eax, [esi+eax]

.copy_item:
        sub     eax, esi
        stdcall StrExtract, esi, 0, eax

.item_ok:
        stdcall StrURLDecode, eax

.finish:
        pop     esi ecx
        return
endp



; returns 2 strings:
;
; eax - hashed password.
; edx - the salt used.


proc HashPassword, .hPassword
begin
; First the salt:

        stdcall GetRandomString, 32
        jc      .finish

        mov     edx, eax
        stdcall StrDup, eax
        push    eax

        stdcall StrCat, eax, [.hPassword]
        stdcall StrMD5, eax
        stdcall StrDel  ; from the stack
        clc

.finish:
        return
endp