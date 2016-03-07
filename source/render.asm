


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

        stdcall StrCat, [.html], '<div class="userinfo">'

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUserInfo, sqlUserInfo.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.Uid]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .invalid_user

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

        cinvoke sqliteFinalize, [.stmt]

.finish:
        stdcall StrCat, [.html], '</div>'  ; div.userinfo

        popad
        return

.invalid_user:
        stdcall StrCat, [.html], '<div class="usernull">NULL user</div>'
        jmp     .finish
endp


