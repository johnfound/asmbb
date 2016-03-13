


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







proc StrCatTemplate, .hString, .strTemplate, .sql_statement, .p_special
begin
        pushad

        stdcall StrPtr, [.strTemplate]
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
        jz      .end_of_file

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

.end_of_file:
        popad
        return
endp





proc StrCatColumnByName, .string, .pname, .len, .statement, .p_special
.i dd ?
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

        cinvoke sqliteColumnCount, [.statement]
        mov     ebx, eax
        and     [.i], 0

.loop:
        cmp     [.i], ebx
        jae     .finish

        cinvoke sqliteColumnName, [.statement], [.i]
        stdcall StrCompNoCase, eax, edi
        jc      .found

        inc     [.i]
        jmp     .loop

.found:
        cinvoke sqliteColumnText, [.statement], [.i]
        test    eax, eax
        jz      .finish

        stdcall StrDupMem, eax
        stdcall StrDecodeHTML, eax
        stdcall StrCat, [.string], eax
        stdcall StrDel, eax

.finish:
        stdcall StrDel, edi
        popad
        return


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

.cat_environment:
; this is only for special purposes.

if defined options.DebugMode & options.DebugMode


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


.cat_username:
        mov     esi, [.p_special]
        mov     edx, [esi+TSpecialParams.userName]
        test    edx, edx
        jz      .finish

        stdcall StrCat, [.string], edx
        jmp     .finish




.cat_loglink:

        mov     esi, [.p_special]
        mov     edx, [esi+TSpecialParams.userName]
        test    edx, edx
        jz      .login

; log out:
        stdcall StrCat, [.string], '<a class="logout" target="_self" href="/logout/">Logout ['
        stdcall StrCat, [.string], edx
        stdcall StrCat, [.string], ']</a>'
        jmp     .common


.login:
        stdcall StrCat, [.string], '<a class="login" target="_self" href="/login/">Login</a>'

.common:
        stdcall StrCat, [.string], '<span class="separator"></span><a class="register" target="_self" href="/register/">Register</a>'
        jmp     .finish


endp