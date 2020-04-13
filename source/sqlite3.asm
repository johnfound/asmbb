sqlCheckEmpty text 'select count() from sqlite_master'

;-------------------------------------------------------------------
; If the file in [.ptrFileName] exists, the function opens it.
; if the file does not exists, new database is created and the
; initialization script from [.ptrInitScript] is executed on it.
;
; Returns:
;    CF: 0 - database was open successfully
;      eax = 0 - Existing database was open successfuly.
;      eax = 1 - Existing database was open, but it is encrypted and needs a key.
;      eax = 2 - New database was created and init script was executed successfully.
;      eax = 3 - New database was created, but the init script was executed with errors.
;    CF: 1 - the database could not be open. (error)
;-------------------------------------------------------------------
proc OpenOrCreate, .ptrFileName, .ptrDatabase, .ptrInitScript
   .hSQL dd ?
begin
        pushad

        xor     edi, edi
        mov     esi, [.ptrDatabase]

; try to open

        cinvoke sqliteOpen_v2, [.ptrFileName], esi, SQLITE_OPEN_READWRITE or SQLITE_OPEN_FULLMUTEX, 0
        test    eax, eax
        jz      .openok

; try to create.

        cinvoke sqliteOpen_v2, [.ptrFileName], esi, SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE or SQLITE_OPEN_FULLMUTEX, 0
        test    eax, eax
        jnz     .error          ; can't create

        inc     edi
        inc     edi

        cinvoke sqliteExec, [esi], [.ptrInitScript], NULL, NULL, NULL
        cmp     eax, SQLITE_OK
        je      .finish

        inc     edi
        jmp     .finish

.error:
        stc
        popad
        return


.openok:
        xor     ebx, ebx

        lea     eax, [.hSQL]
        cinvoke sqlitePrepare_v2, [esi], sqlCheckEmpty, sqlCheckEmpty.length, eax, 0
        cinvoke sqliteStep, [.hSQL]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.hSQL]

        cmp     ebx, SQLITE_ROW
        je      .finish

        inc     edi

.finish:
        mov     [esp+4*regEAX], edi
        clc
        popad
        return
endp


SQLITE_DETERMINISTIC = $800

proc SQLiteRegisterFunctions, .ptrDatabase
begin
        cinvoke sqliteCreateFunction_v2, [.ptrDatabase], txt "url_encode", 1, SQLITE_UTF8 or SQLITE_DETERMINISTIC, 0, sqliteURLEncode, 0, 0, 0
        cinvoke sqliteCreateFunction_v2, [.ptrDatabase], txt "html_encode", 1, SQLITE_UTF8 or SQLITE_DETERMINISTIC, 0, sqliteHTMLEncode, 0, 0, 0
        cinvoke sqliteCreateFunction_v2, [.ptrDatabase], txt "slugify", 1, SQLITE_UTF8 or SQLITE_DETERMINISTIC, 0, sqliteSlugify, 0, 0, 0
        cinvoke sqliteCreateFunction_v2, [.ptrDatabase], txt "tagify", 1, SQLITE_UTF8 or SQLITE_DETERMINISTIC, 0, sqliteTagify, 0, 0, 0
        cinvoke sqliteCreateFunction_v2, [.ptrDatabase], txt "phpbb", 1, SQLITE_UTF8 or SQLITE_DETERMINISTIC, 0, sqliteConvertPhpBBText, 0, 0, 0
        cinvoke sqliteCreateFunction_v2, [.ptrDatabase], txt "xorblob", 2, SQLITE_ANY or SQLITE_DETERMINISTIC, 0, sqliteXorBlob, 0, 0, 0
        cinvoke sqliteCreateFunction_v2, [.ptrDatabase], txt "md5", 1, SQLITE_ANY or SQLITE_DETERMINISTIC, 0, sqliteMD5Blob, 0, 0, 0
        cinvoke sqliteCreateFunction_v2, [.ptrDatabase], txt "base64", 1, SQLITE_ANY or SQLITE_DETERMINISTIC, 0, sqliteBase64, 0, 0, 0
        cinvoke sqliteCreateFunction_v2, [.ptrDatabase], txt "fuzzytime", 1, SQLITE_ANY or SQLITE_DETERMINISTIC, 0, sqliteHumanTime, 0, 0, 0
        return
endp



proc sqliteURLEncode, .context, .num, .pValue
begin
        mov     eax, [.pValue]
        cinvoke sqliteValueText, [eax]
        test    eax, eax
        jz      .null

        stdcall StrURLEncode, eax
        push    eax
        stdcall StrPtr, eax

.result:
        cinvoke sqliteResultText, [.context], eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack
        cret

.null:
        cinvoke sqliteResultNULL, [.context]
        cret
endp


proc sqliteMD5Blob, .context, .num, .pValue
begin
        push    ebx esi

        mov     esi, [.pValue]

        cinvoke sqliteValueBytes, [esi]
        test    eax, eax
        jz      .null

        mov     ebx, eax

        cinvoke sqliteValueBlob, [esi]
        test    eax, eax
        jz      .null

        stdcall DataMD5, eax, ebx
        push    eax
        stdcall StrPtr, eax

        cinvoke sqliteResultText, [.context], eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack
        pop     esi ebx
        cret

.null:
        cinvoke sqliteResultNULL, [.context]
        pop     esi ebx
        cret
endp


proc sqliteHTMLEncode, .context, .num, .pValue
begin
        mov     eax, [.pValue]
        cinvoke sqliteValueText, [eax]
        test    eax, eax
        jz      .null

        stdcall StrEncodeHTML, eax
        push    eax
        stdcall StrPtr, eax

.result:
        cinvoke sqliteResultText, [.context], eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack
        cret

.null:
        cinvoke sqliteResultNULL, [.context]
        cret
endp


proc sqliteSlugify, .context, .num, .pValue
begin
        mov     eax, [.pValue]
        cinvoke sqliteValueText, [eax]
        test    eax, eax
        jz      .null

        stdcall StrSlugify, eax
        push    eax
        stdcall StrPtr, eax

.result:
        cinvoke sqliteResultText, [.context], eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack
        cret

.null:
        cinvoke sqliteResultNULL, [.context]
        cret
endp


proc sqliteTagify, .context, .num, .pValue
begin
        mov     eax, [.pValue]
        cinvoke sqliteValueText, [eax]
        test    eax, eax
        jz      .null

        stdcall StrDupMem, eax
        stdcall StrTagify, eax
        push    eax
        stdcall StrPtr, eax

        cinvoke sqliteResultText, [.context], eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack
        cret

.null:
        cinvoke sqliteResultNULL, [.context]
        cret
endp



proc sqliteConvertPhpBBText, .context, .num, .pValue
begin
        push    edi

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        mov     eax, [.pValue]
        cinvoke sqliteValueText, [eax]
        test    eax, eax
        jz      .null

        stdcall TextAddString, edi, 0, eax
        stdcall ConvertPhpBB, edx
        stdcall TextCompact, edx
        push    edx

        cinvoke sqliteResultText, [.context], edx, [edx+TText.GapBegin], SQLITE_TRANSIENT
        stdcall TextFree ; from the stack
        pop     edi
        cret

.null:
        cinvoke sqliteResultNULL, [.context]
        pop     edi
        cret
endp



proc ConvertPhpBB, .pText
begin
        pushad

        mov     edx, [.pText]

        stdcall TextMoveGap, edx, 0
        mov     ebx, [edx+TText.GapEnd]
        dec     ebx

.loop:
        inc     ebx
        cmp     ebx, [edx+TText.Length]
        jae     .end_of_text

        mov     al, [edx+ebx]
        cmp     al, "["
        je      .tag_loop

        cmp     al, "&"
        jne     .loop

        call    .decode_html
        jmp     .loop

; tag start here:

.tag_loop:
        inc     ebx
        cmp     ebx, [edx+TText.Length]
        jae     .end_of_text

        mov     al, [edx+ebx]

        cmp     al, ":"
        je      .del_from_here

        cmp     al, "]"
        je      .loop   ; tag ended here

        cmp     al, "&"
        jne     .tag_loop

        call    .decode_html
        jmp     .tag_loop


.del_from_here:
        mov     al, [edx+ebx+1]
        cmp     al, '/'
        je      .tag_loop

        mov     eax, ebx
        sub     eax, [edx+TText.GapEnd]
        add     eax, [edx+TText.GapBegin]

        stdcall TextMoveGap, edx, eax

.del_loop:
        inc     ebx
        cmp     ebx, [edx+TText.Length]
        jae     .end_of_text

        mov     al, [edx+ebx]

        cmp     al, "]"
        je      .del_end_tag

        cmp     al, "="
        jne     .del_loop

        mov     [edx+TText.GapEnd], ebx
        jmp     .tag_loop

.del_end_tag:
        mov     [edx+TText.GapEnd], ebx
        jmp     .loop


.end_of_text:
        mov     [esp+4*regEDX], edx
        popad
        return


.decode_html:

        mov     eax, ebx
        sub     eax, [edx+TText.GapEnd]
        add     eax, [edx+TText.GapBegin]

        stdcall TextSetGapSize, edx, 8
        stdcall TextMoveGap, edx, eax
        mov     ebx, [edx+TText.GapEnd]

;        int3
;        lea     eax, [edx+ebx]          ; for debug only!!!

        inc     ebx

        mov     ecx, [edx+TText.Length]
        sub     ecx, ebx
        cmp     ecx, 5
        jb      .skip5

        mov     eax, $a0
        mov     edi, 6
        cmp     dword [edx+ebx], 'nbsp'
        jne     .no_nbsp
        cmp     byte [edx+ebx+4], ';'
        je      .replace

.no_nbsp:
        mov     eax, '"'
        cmp     dword [edx+ebx], 'quot'
        jne     .no_quot
        cmp     byte [edx+ebx+4], ';'
        je      .replace

.no_quot:
        mov     eax, "'"
        cmp     dword [edx+ebx], 'apos'
        jne     .skip5
        cmp     byte [edx+ebx+4], ';'
        je      .replace

.skip5:
        cmp     ecx, 4
        jb      .skip4

        mov     eax, '&'
        mov     edi, 5
        cmp     dword [edx+ebx], 'amp;'
        je      .replace

.skip4:
        cmp     ecx, 3
        jb      .skip3

        mov     eax, '<'
        mov     edi, 4
        cmp     dword [edx+ebx-1], '&lt;'
        je      .replace

        mov     eax, '>'
        cmp     dword [edx+ebx-1], '&gt;'
        je      .replace

.skip3:
        cmp     ecx, 2
        jb      .ignore

        mov     edi, 3
        cmp     byte [edx+ebx], '#'
        jne     .ignore

        xor     esi, esi
        mov     ecx, $10
        inc     ebx

        cmp     byte [edx+ebx], 'x'
        je      .get_num
        cmp     byte [edx+ebx], 'X'
        je      .get_num

        mov     ecx, $0a
        dec     ebx
        dec     edi

.get_num:
        inc     ebx
        cmp     ebx, [edx+TText.Length]
        jae     .ignore

        inc     edi
        movzx   eax, byte [edx+ebx]
        cmp     al, ';'
        je      .num_end

        sub     al, '0'
        js      .ignore

        cmp     al, 10
        jb      .mulit

        cmp     ecx, 10
        ja      .ignore

        or      al, $20 ; lower case.
        cmp     al, $31
        jb      .ignore
        cmp     al, $36
        ja      .ignore

        sub     al, $27

.mulit:
        imul    esi, ecx
        add     esi, eax
        jmp     .get_num

.num_end:
        mov     eax, esi

.replace:
        push    edx
        stdcall EncodeUtf8, eax
        mov     ecx, edx
        pop     edx

        add     [edx+TText.GapEnd], edi ; remove the encoded entity.
        mov     ebx, [edx+TText.GapBegin]
        mov     [edx+ebx], eax
        add     [edx+TText.GapBegin], ecx
        mov     ebx, [edx+TText.GapEnd]
        dec     ebx

.ignore:
        retn

endp



proc sqliteXorBlob, .context, .num, .pValues
.pfile dd ?
.lfile dd ?
.pkey dd ?
.lkey dd ?
begin
        push    ebx esi edi

        mov     esi, [.pValues]

        cinvoke sqliteValueBytes, [esi]
        test    eax, eax
        jz      .null

        mov     [.lfile], eax

        cinvoke sqliteValueBlob, [esi]
        test    eax, eax
        jz      .null

        mov     esi, eax
        stdcall GetMem, [.lfile]

        mov     edi, eax
        mov     [.pfile], eax

        mov     ecx, [.lfile]
        rep movsb

        mov     esi, [.pValues]
        cinvoke sqliteValueBytes, [esi+4]
        test    eax, eax
        jz      .null

        mov     [.lkey], eax

        cinvoke sqliteValueBlob, [esi+4]
        test    eax, eax
        jz      .null

        mov     [.pkey], eax

        stdcall XorMemory, [.pfile], [.lfile], [.pkey], [.lkey]

        cinvoke sqliteResultBlob, [.context], [.pfile], [.lfile], SQLITE_TRANSIENT

        stdcall FreeMem, [.pfile]
        pop     edi esi ebx
        cret

.null:
        cinvoke sqliteResultNULL, [.context]
        pop     edi esi ebx
        cret
endp


proc sqliteBase64, .context, .num, .pValue
begin
        push    ebx esi

        mov     esi, [.pValue]

        cinvoke sqliteValueBytes, [esi]
        test    eax, eax
        jz      .null

        mov     ebx, eax

        cinvoke sqliteValueBlob, [esi]
        test    eax, eax
        jz      .null

        stdcall EncodeBase64, eax, ebx
        push    eax
        stdcall StrPtr, eax

        cinvoke sqliteResultText, [.context], eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack
        pop     esi ebx
        cret

.null:
        cinvoke sqliteResultNULL, [.context]
        pop     esi ebx
        cret
endp





proc sqliteHumanTime, .context, .num, .pValue
.time     rd 2
.datetime TDateTime
begin
        push    ebx

        mov     eax, [.pValue]
        cinvoke sqliteValueType, [eax]
        cmp     eax, SQLITE_NULL
        je      .exit

        mov     eax, [.pValue]
        cinvoke sqliteValueInt64, [eax]
        mov     [.time], eax
        and     [.time+4], edx

        lea     eax, [.time]
        lea     edx, [.datetime]
        stdcall TimeToDateTime, eax, edx

        stdcall StrNew
        mov     ebx, eax

        stdcall GetTime

        sub     eax, [.time]
        sbb     edx, [.time+4]
        jnz     .only_date

        cmp     eax, 24*60*60   ; 24 hours
        jl      .only_time

        cmp     eax, 2*24*60*60
        jae     .only_date

; short date and time:
        mov     cl, 2
        call    .to_date
        stdcall StrCat, ebx, txt " "
        call    .to_time
        jmp     .finish

.only_time:
        call    .to_time
        jmp     .finish

.only_date:
        mov     cl, 4
        call    .to_date

.finish:
        stdcall StrPtr, ebx
        cinvoke sqliteResultText, [.context], eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel, ebx

.exit:
        xor     eax, eax
        pop     ebx
        cret


.to_time:
        stdcall NumToStr, [.datetime.hour], ntsUnsigned or ntsFixedWidth or ntsDec + 2
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCat, ebx, txt ':'
        stdcall NumToStr, [.datetime.minute], ntsUnsigned or ntsFixedWidth or ntsDec + 2
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        retn

.to_date:
        stdcall NumToStr, [.datetime.date], ntsUnsigned or ntsFixedWidth or ntsDec + 2
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCat, ebx, txt '.'
        stdcall NumToStr, [.datetime.month], ntsUnsigned or ntsFixedWidth or ntsDec + 2
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCat, ebx, txt '.'

        and     ecx, $ff
        or      ecx, ntsSigned or ntsFixedWidth or ntsDec
        stdcall NumToStr, [.datetime.year], ecx
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        retn

endp


