


proc RenderPostContent, .html, .PostText
begin
        pushad


        stdcall StrCat, [.html], '<p class="posttext">'


        stdcall StrCat, [.html], [.PostText]


        stdcall StrCat, [.html], txt '</p>'  ; div.posttext


        popad
        return
endp




proc RenderPostTime, .html, .time
.dtime dq ?
.DateTime TDateTime
begin

        stdcall StrCat, [.html], '<div class="posttime">'

        mov     eax, [.time]
        cdq

        mov     dword [.dtime], eax
        mov     dword [.dtime+4], edx

        lea     eax, [.dtime]
        lea     edx, [.DateTime]
        stdcall TimeToDateTime, eax, edx
        stdcall DateTimeToStr, edx, 0

        stdcall StrCat, [.html], eax
        stdcall StrDel, eax


        stdcall StrCat, [.html], '</div>'  ; div.posttime

        return
endp


sqlUserInfo text 'select U.nick, (select count() from Posts P where P.userID=U.id) as postcount from Users as U where U.id=?'


proc RenderUserInfo, .html, .Uid
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUserInfo, sqlUserInfo.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.Uid]

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        je      .user_ok

        stdcall StrCat, [.html], '<div class="usernull">NULL user</div>'
        jmp     .finish

.user_ok:
        stdcall StrCat, [.html], '<div class="username">'

        cinvoke sqliteColumnText, [.stmt], 0
        stdcall StrCat, [.html], eax

        stdcall StrCat, [.html], '</div>'  ; div.username

        stdcall StrCat, [.html], '<div class="userpcnt">'

        cinvoke sqliteColumnInt, [.stmt], 1
        stdcall NumToStr, eax, ntsDec or ntsUnsigned

        stdcall StrCat, [.html], eax
        stdcall StrDel, eax

        stdcall StrCat, [.html], '</div>'  ; div.userpcnt

.finish:
        cinvoke sqliteFinalize, [.stmt]
        popad
        return
endp




sqlGetTemplate text "select template from templates where id = ?"


proc StrCatTemplate, .hString, .strTemplateID, .sql_statement, .p_special
.stmt dd ?
.free dd ?
begin
        pushad
        and     [.free], 0

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetTemplate, sqlGetTemplate.length+1, eax, 0

        stdcall StrLen, [.strTemplateID]
        mov     ecx, eax
        stdcall StrPtr, [.strTemplateID]

        cinvoke sqliteBindText, [.stmt], 1, eax, ecx, SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        je      .get_template


        stdcall StrDupMem, "templates/"
        stdcall StrCat, eax, [.strTemplateID]
        stdcall StrCharCat, eax, ".tpl"
        push    eax

        stdcall LoadBinaryFile, eax
        stdcall StrDel ; from the stack
        jc      .error

;        OutputValue "Template from file. Length:", ecx, 10, -1

        mov     [.free], eax
        mov     esi, eax
        and     dword [eax+ecx], 0
        jmp     .outer


.get_template:

        cinvoke sqliteColumnText, [.stmt], 0
        mov     esi, eax

.outer:
        mov     ebx, esi

.inner:
        mov     cl, [esi]
        inc     esi

        test    cl, cl
        jz      .found

        cmp     cl, '$'
        jne     .inner

.found:
        mov     eax, esi
        sub     eax, ebx
        dec     eax

        stdcall StrCatMem, [.hString], ebx, eax

        test    cl, cl
        jz      .end_of_template

        mov     ebx, esi

.varname:
        mov     cl, [esi]
        inc     esi

        test    cl, cl
        jz      .found_var

        cmp     cl, '$'
        jne     .varname

.found_var:
        mov     edx, esi
        sub     edx, ebx
        dec     edx

        stdcall StrCatColumnByName, [.hString], ebx, edx, [.sql_statement], [.p_special]

        test    cl, cl
        jnz     .outer

.end_of_template:

        cinvoke sqliteFinalize, [.stmt]

        stdcall FreeMem, [.free]
        popad
        return

.error:
        DebugMsg "Error read template!"

        stdcall StrCat, [.hString], "Unknown template!"
        jmp     .end_of_template

endp





proc StrCatColumnByName, .string, .pname, .len, .statement, .p_special
.i dd ?
.formatted dd ?
begin
        pushad

        stdcall StrNew
        mov     edi, eax
        stdcall StrCatMem, edi, [.pname], [.len]

; first check for special names

        stdcall StrCompNoCase, edi, "special:timestamp"
        jc      .cat_timestamp

        stdcall StrCompNoCase, edi, "special:environment"
        jc      .cat_environment

        stdcall StrCompNoCase, edi, "special:username"
        jc      .cat_username

        stdcall StrCompNoCase, edi, "special:loglink"
        jc      .cat_loglink

        cmp     [.statement], 0
        je      .finish

        stdcall StrPos, edi, "plural:"
        test    eax, eax
        jnz     .cat_plural

        mov     [.formatted], 0

        stdcall StrPos, edi, "minimag:"
        test    eax, eax
        jz      .process_columns

        or      [.formatted], 1

        stdcall StrSplit, edi, 8
        stdcall StrDel, edi
        mov     edi, eax
        jmp     .process_columns


.process_columns:

        call    .get_column_number
        jnc     .finish

        cinvoke sqliteColumnText, [.statement], [.i]
        test    eax, eax
        jz      .finish

        stdcall StrDupMem, eax
        stdcall StrDecodeHTML, eax
        cmp     [.formatted], 0
        je      .add_field

        stdcall FormatPostText, eax

.add_field:
        stdcall StrCat, [.string], eax
        stdcall StrDel, eax

.finish:
        stdcall StrDel, edi
        popad
        return



.get_column_number:

        cinvoke sqliteColumnCount, [.statement]
        mov     ebx, eax
        and     [.i], 0

.loop:
        cmp     [.i], ebx
        jae     .not_found

        cinvoke sqliteColumnName, [.statement], [.i]
        stdcall StrCompNoCase, eax, edi
        jc      .found

        inc     [.i]
        jmp     .loop

.not_found:     ; here CF=0
.found:         ; here CF=1
        retn



;..................................................................


.cat_plural:

        stdcall StrSplit, edi, 7
        stdcall StrDel, edi
        mov     edi, eax

        stdcall StrSplitList, edi, '|', FALSE
        mov     esi, eax

        cmp     [esi+TArray.count], 4
        jne     .end_plural

        stdcall StrCopy, edi, [esi+TArray.array]

        call    .get_column_number
        jnc     .end_plural

        cinvoke sqliteColumnInt, [.statement], [.i]
        inc     eax
        cmp     eax, 3
        jbe     @f
        mov     eax, 3
@@:
        stdcall StrCat, [.string], [esi+TArray.array+4*eax]

.end_plural:
        stdcall ListFree, esi, StrDel

        jmp     .finish


;..................................................................



.cat_timestamp:

        mov     esi, [.p_special]
        mov     edx, [esi+TSpecialParams.start_time]

        stdcall StrCat, [.string], '<p class="timestamp">Script runtime: '

        stdcall GetTimestamp
        sub     eax, edx
        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        stdcall StrCat, [.string], eax
        stdcall StrDel, eax

        stdcall StrCat, [.string], txt 'ms</p>'

        jmp     .finish


;..................................................................


.cat_environment:
; this is only for special purposes.

if defined options.DebugWeb & options.DebugWeb

        DebugMsg "Special:environment!"


        mov     esi, [.p_special]
        mov     edx, [esi+TSpecialParams.params]

        xor     ecx, ecx

.loop_env:
        cmp     ecx, [edx+TArray.count]
        jae     .finish

        stdcall StrCat,     [.string], [edx+TArray.array+8*ecx]
        stdcall StrCharCat, [.string], " = "
        stdcall StrCat,     [.string], [edx+TArray.array+8*ecx+4]
        stdcall StrCharCat, [.string], $0a0d

        inc     ecx
        jmp     .loop_env

else
        jmp     .finish

end if



;..................................................................



.cat_username:
        mov     esi, [.p_special]
        mov     edx, [esi+TSpecialParams.userName]
        test    edx, edx
        jz      .finish

        stdcall StrCat, [.string], edx
        jmp     .finish


;..................................................................


.cat_loglink:

        mov     esi, [.p_special]
        mov     edx, [esi+TSpecialParams.userName]
        test    edx, edx
        jz      .login

; log out:
        stdcall StrCat, [.string], '<a class="logout" href="/logout/">Logout</a> ( <b>'
        stdcall StrCat, [.string], edx
        stdcall StrCat, [.string], '</b> )'
        jmp     .common


.login:
        stdcall StrCat, [.string], '<a class="login" href="/login/">Login</a>'
        stdcall StrCat, [.string], '<span class="separator"></span><a class="register" href="/register/">Register</a>'

.common:
        jmp     .finish


endp







proc FormatPostText, .hText

.result TMarkdownResults

begin
        lea     eax, [.result]

        stdcall StrCatTemplate, [.hText], "minimag_suffix", 0, 0
        stdcall TranslateMarkdown, [.hText], 0, 0, eax

        stdcall StrDel, [.hText]
        stdcall StrDel, [.result.hIndex]
        stdcall StrDel, [.result.hKeywords]
        stdcall StrDel, [.result.hDescription]

        mov     eax, [.result.hContent]
        return
endp