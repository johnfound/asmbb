


sqlGetUserInfo   text "select id, salt, passHash, status from Users where lower(nick) = lower(?)"
sqlInsertSession text "insert into sessions (userID, sid, FromIP, last_seen) values ( ?, ?, ?, strftime('%s','now') )"
sqlUpdateSession text "update Sessions set userID = ?, FromIP = ?3, last_seen = strftime('%s','now') where sid = ?2"
sqlCheckSession  text "select sid from sessions where userID = ? and fromIP = ?"
sqlCleanSessions text "delete from sessions where last_seen < (strftime('%s','now') - 2592000)"


proc UserLogin, .pSpecial
.stmt  dd ?

.user     dd ?
.password dd ?

.userID   dd ?
.session  dd ?
.status   dd ?

.ip dd ?

begin
        pushad

        xor     eax, eax
        mov     [.session], eax
        mov     [.user], eax
        mov     [.password], eax

        stdcall StrNew
        mov     edi, eax

        cinvoke sqliteExec, [hMainDatabase], sqlCleanSessions, sqlCleanSessions.length, 0, 0

; check the information

        mov     esi, [.pSpecial]
        mov     ebx, [esi+TSpecialParams.post_array]
        test    ebx, ebx
        jnz     .do_login_user


        stdcall StrCat, [esi+TSpecialParams.page_title], "Login dialog"
        stdcall StrCatTemplate, edi, "form_login", 0, esi

        mov     [esp+4*regEAX], edi
        clc
        popad
        return


.do_login_user:

        stdcall ValueByName, [esi+TSpecialParams.params], "REMOTE_ADDR"
        jc      .ip_ok

        stdcall StrIP2Num, eax
        jc      .ip_ok

        mov     [.ip], eax
.ip_ok:

        stdcall GetPostString, ebx, "username", 0
        mov     [.user], eax

        test    eax, eax
        jz      .redirect_back_short

        stdcall StrLen, eax
        test    eax, eax
        jz      .redirect_back_short

        stdcall GetPostString, ebx, "password", 0
        mov     [.password], eax

        test    eax, eax
        jz      .redirect_back_short

        stdcall StrLen, eax
        test    eax, eax
        jz      .redirect_back_short

; hash the password

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUserInfo, -1, eax, 0

        stdcall StrPtr, [.user]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        je      .user_ok


.bad_user:
        cinvoke sqliteFinalize, [.stmt]
        jmp     .redirect_back_bad_password


.user_ok:

        cinvoke sqliteColumnText, [.stmt], 1    ; the salt
        stdcall StrDupMem, eax
        push    eax

        stdcall StrCat, eax, [.password]
        stdcall StrMD5, eax
        stdcall StrDel ; from the stack
        stdcall StrDel, [.password]

        mov     [.password], eax

        cinvoke sqliteColumnText, [.stmt], 2    ; the password hash.

        stdcall StrCompCase, [.password], eax
        jnc     .bad_user


; here the password matches this from the database.

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.userID], eax

        cinvoke sqliteColumnInt, [.stmt], 3
        mov     [.status], eax

        cinvoke sqliteFinalize, [.stmt]

; check the status of the user

        test    [.status], permLogin
        jz      .redirect_back_bad_permissions


; Check for existing session

        lea     eax, [.stmt]
        cinvoke sqlitePrepare, [hMainDatabase], sqlCheckSession, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.userID]
        cinvoke sqliteBindInt, [.stmt], 2, [.ip]

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .new_session

        cinvoke sqliteColumnText, [.stmt], 0
        stdcall StrDupMem, eax
        mov     [.session], eax


.new_session:
        cinvoke sqliteFinalize, [.stmt]

        mov     ecx, sqlUpdateSession

        cmp     [.session], 0
        jne     .session_ok

        stdcall GetRandomString, 32
        mov     [.session], eax

        mov     ecx, sqlInsertSession

.session_ok:

; Insert new session record.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], ecx, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.userID]

        stdcall StrPtr, [.session]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 3, [.ip]

        cinvoke sqliteStep, [.stmt]
        mov     esi, eax

        cinvoke sqliteFinalize, [.stmt]

        cmp     esi, SQLITE_DONE
        jne     .finalize               ; it is some error in the database, so don't set the cookie!


; now, set some cookies (It is session cookie only!)

        stdcall StrCat, edi, "Set-Cookie: sid="
        stdcall StrCat, edi, [.session]
        stdcall StrCat, edi, <"; HttpOnly; Path=/", 13, 10>


.finalize:
        stdcall GetPostString, ebx, "backlink", 0
        test    eax, eax
        jnz     .go_back

        stdcall StrMakeRedirect, edi, "/list"
        jmp     .finish

.go_back:
        stdcall StrMakeRedirect, edi, eax
        stdcall StrDel, eax
        jmp     .finish

.redirect_back_short:

        stdcall StrMakeRedirect, edi, "/!message/login_missing_data/"
        jmp     .finish

.redirect_back_bad_permissions:

        stdcall StrMakeRedirect, edi, "/!message/login_bad_permissions/"
        jmp     .finish


.redirect_back_bad_password:

        stdcall StrMakeRedirect, edi, "/!message/login_bad_password/"

.finish:
        stdcall StrDel, [.user]
        stdcall StrDel, [.password]
        stdcall StrDel, [.session]

        mov     [esp+4*regEAX], edi
        stc
        popad
        return

endp




sqlLogout text "delete from Sessions where userID = ?"

proc UserLogout, .pspecial
.stmt dd ?
begin
        pushad

        stdcall StrNew
        mov     edi, eax

        mov     esi, [.pspecial]

        cmp     [esi+TSpecialParams.session], 0
        je      .finish

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlLogout, -1, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.userID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

; delete the cookie.

        stdcall StrCat, edi, <"Set-Cookie: sid=; HttpOnly; Path=/; Max-Age=0", 13, 10>

.finish:
        stdcall GetBackLink, esi
        push    eax

        stdcall StrMakeRedirect, edi, eax
        stdcall StrDel ; from the stack

        mov     [esp+4*regEAX], edi
        stc
        popad
        return
endp







;sqlCheckMinInterval text "select (strftime('%s','now') - time_reg) as delta from WaitingActivation where (ip_from = ?) and ( delta>30 ) order by time_reg desc limit 1"
sqlRegisterUser    text "insert into WaitingActivation (nick, passHash, salt, email, ip_from, time_reg, time_email, a_secret) values (?, ?, ?, ?, ?, strftime('%s','now'), NULL, ?)"
sqlCheckUserExists text "select 1 from Users where lower(nick) = lower(?) or email = ? limit 1"

proc RegisterNewUser, .pSpecial

.stmt      dd ?

.user      dd ?
.password  dd ?
.password2 dd ?
.email     dd ?
.secret    dd ?
.ip_from   dd ?

.email_text dd ?

begin
        pushad

        xor     eax, eax
        mov     [.user], eax
        mov     [.password], eax
        mov     [.password2], eax
        mov     [.email], eax
        mov     [.secret], eax
        mov     [.ip_from], eax

; check the information

        mov     esi, [.pSpecial]
        mov     ebx, [esi+TSpecialParams.post_array]
        test    ebx, ebx
        jnz     .do_register_user


        stdcall StrNew
        stdcall StrCatTemplate, eax, "form_register", 0, 0

        mov     [esp+4*regEAX], eax
        clc
        popad
        return



.do_register_user:

        stdcall GetPostString, ebx, "username", 0
        mov     [.user], eax

        test    eax, eax
        jz      .error_short_name

        stdcall StrLen, eax
        cmp     eax, 3
        jbe     .error_short_name

        cmp     eax, 256
        ja      .error_trick

        stdcall GetPostString, ebx, "email", 0
        mov     [.email], eax

        stdcall CheckEmail, eax
        jc      .error_bad_email

        stdcall GetPostString, ebx, txt "password", 0
        mov     [.password], eax
        test    eax, eax
        jz      .error_short_pass

        stdcall GetPostString, ebx, txt "password2", 0
        mov     [.password2], eax
        test    eax, eax
        jz      .error_short_pass

        stdcall StrCompCase, [.password], [.password2]
        jnc     .error_different

        stdcall StrLen, [.password]

        cmp     eax, 5
        jbe     .error_short_pass

        cmp     eax, 1024
        ja      .error_trick

        mov     eax, [.pSpecial]
        stdcall ValueByName, [eax+TSpecialParams.params], "REMOTE_ADDR"
        stdcall StrIP2Num, eax
        jc      .error_technical_problem

        mov     [.ip_from], eax

; hash the password

        stdcall HashPassword, [.password]
        jc      .error_technical_problem

        stdcall StrDel, [.password]
        stdcall StrDel, [.password2]
        mov     [.password], eax
        mov     [.password2], edx       ; the salt!

        stdcall GetRandomString, 32
        jc      .error_technical_problem

        mov     [.secret], eax

; check whether the user exists

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCheckUserExists, -1, eax, 0

        stdcall StrPtr, [.user]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.email]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_ROW
        je      .error_exists

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlRegisterUser, -1, eax, 0

        stdcall StrPtr, [.user]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.password]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.password2]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.email]
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 5, [.ip_from]

        stdcall StrPtr, [.secret]
        cinvoke sqliteBindText, [.stmt], 6, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_exists

; now send the activation email for all registered user, where the email was not sent.

        stdcall ProcessActivationEmails
        jc      .error_technical_problem

; the user has been created and now is waiting for email activation.

        stdcall StrMakeRedirect, 0, "/!message/user_created/"
        jmp     .finish


.error_technical_problem:

        stdcall StrMakeRedirect, 0, "/!message/register_technical/"
        jmp     .finish


.error_short_name:

        stdcall StrMakeRedirect, 0, "/!message/register_short_name/"
        jmp     .finish

.error_trick:

        stdcall StrMakeRedirect, 0, "/!message/register_bot/"

        jmp     .finish


.error_bad_email:
        stdcall StrMakeRedirect, 0, "/!message/register_bad_email/"
        jmp     .finish


.error_short_pass:
        stdcall StrMakeRedirect, 0, "/!message/register_short_pass/"
        jmp     .finish


.error_different:

        stdcall StrMakeRedirect, 0, "/!message/register_passwords_different/"
        jmp     .finish


.error_exists:

        stdcall StrMakeRedirect, 0, "/!message/register_user_exists/"

.finish:
        stdcall StrDel, [.user]
        stdcall StrDel, [.password]
        stdcall StrDel, [.password2]
        stdcall StrDel, [.email]
        stdcall StrDel, [.secret]

        mov     [esp+4*regEAX], eax
        stc
        popad
        return
endp






sqlBegin      text  "begin transaction;"
sqlActivate   text  "insert into Users ( nick, passHash, salt, status, email ) select nick, passHash, salt, ?, email from WaitingActivation where a_secret = ?"
sqlDeleteWait text  "delete from WaitingActivation where a_secret = ?"
sqlCheckCount text  "select count(1), salt from WaitingActivation where a_secret = ?"
sqlCommit     text  "commit transaction"
sqlRollback   text  "rollback"

sqlUpdateUserEmail text "update users set email = (select email from WaitingActivation where a_secret = ?1) where nick = (select nick from WaitingActivation where a_secret = ?1)"


proc ActivateAccount, .hSecret, .pSpecial
.stmt dd ?
.type dd ?
begin
        pushad

        xor     eax, eax
        cmp     [.hSecret], eax
        je      .exit                   ; CF=0 if jump is taken

; begin transaction

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlBegin, sqlBegin.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

; check again whether all is successful.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCheckCount, sqlCheckCount.length, eax, 0

        stdcall StrPtr, [.hSecret]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .rollback

        cinvoke sqliteColumnInt, [.stmt], 0
        cmp     eax, 1
        jne     .rollback

        cinvoke sqliteColumnType, [.stmt], 1    ; the salt if exists
        mov     [.type], eax

        cinvoke sqliteFinalize, [.stmt]

        cmp     [.type], SQLITE_NULL
        jne     .insert_new_user

; update user email

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateUserEmail, sqlUpdateUserEmail.length, eax, 0

        stdcall StrPtr, [.hSecret]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        jmp     .finalize_delete_from_waiting


; insert new user

.insert_new_user:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlActivate, sqlActivate.length, eax, 0

        stdcall GetParam, "user_perm", gpInteger
        jc      .rollback

        cinvoke sqliteBindInt, [.stmt], 1, eax

        stdcall StrPtr, [.hSecret]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_DONE
        jne     .rollback


.finalize_delete_from_waiting:

        cinvoke sqliteFinalize, [.stmt]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDeleteWait, sqlDeleteWait.length, eax, 0

        stdcall StrPtr, [.hSecret]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

; commit transaction

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCommit, sqlCommit.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

        cmp     [.type], SQLITE_NULL
        jne     .msg_new_account

        stdcall StrMakeRedirect, 0, "/!message/email_changed"
        jmp     .finish


.msg_new_account:
        stdcall StrMakeRedirect, 0, "/!message/congratulations"


.finish:
        stc

.exit:
        mov     [esp+4*regEAX], eax
        popad
        return


.rollback:

        cinvoke sqliteFinalize, [.stmt]         ; finalize the bad statement.

; rollback transaction

        cinvoke sqliteExec, [hMainDatabase], sqlRollback, 0, 0, 0

        stdcall StrMakeRedirect, 0, "/!message/bad_secret"
        jmp     .finish

endp



sqlGetUserPass   text "select nick, salt, passHash from Users where id = ?"
sqlUpdateUserPass text "update users set passHash = ?, salt = ? where id = ?"


proc ChangePassword, .pSpecial

.stmt     dd ?

.oldpass  dd ?
.newpass  dd ?
.newpass2 dd ?
begin
        pushad

        xor     eax, eax
        mov     [.oldpass], eax
        mov     [.newpass], eax
        mov     [.newpass2], eax

        mov     esi, [.pSpecial]
        mov     ebx, [esi+TSpecialParams.post_array]

        stdcall GetPostString, ebx, "oldpass", 0
        test    eax, eax
        jz      .bad_parameter

        mov     [.oldpass], eax

        stdcall StrLen, eax
        test    eax, eax
        jz      .bad_parameter


        stdcall GetPostString, ebx, txt "newpass", 0
        test    eax, eax
        jz      .bad_parameter

        mov     [.newpass], eax

        stdcall StrLen, eax
        test    eax, eax
        jz      .bad_parameter

        cmp     eax, 5
        jbe     .error_short_pass

        stdcall GetPostString, ebx, txt "newpass2", 0
        test    eax, eax
        jz      .bad_parameter

        mov     [.newpass2], eax

        stdcall StrLen, eax
        test    eax, eax
        jz      .bad_parameter

        stdcall StrCompCase, [.newpass], [.newpass2]
        jnc     .error_different


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUserPass, sqlGetUserPass.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.userID]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .bad_user

        cinvoke sqliteColumnText, [.stmt], 1    ; salt
        stdcall StrDupMem, eax
        push    eax

        stdcall StrCat, eax, [.oldpass]
        stdcall StrMD5, eax
        stdcall StrDel ; from the stack
        stdcall StrDel, [.oldpass]
        mov     [.oldpass], eax

        cinvoke sqliteColumnText, [.stmt], 2    ; the password hash.
        stdcall StrCompCase, [.oldpass], eax
        jnc     .bad_password

        cinvoke sqliteFinalize, [.stmt]


        stdcall HashPassword, [.newpass]
        stdcall StrDel, [.newpass]
        stdcall StrDel, [.newpass2]

        mov     [.newpass], eax         ; hash
        mov     [.newpass2], edx        ; salt

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateUserPass, sqlUpdateUserPass.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 3, [esi+TSpecialParams.userID]

        stdcall StrPtr, [.newpass]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.newpass2]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_update

        cinvoke sqliteFinalize, [.stmt]

        stdcall UserLogout, [.pSpecial]
        stdcall StrDel, eax

        stdcall StrMakeRedirect, 0, "/!message/password_changed"

.finish:

        stdcall StrDel, [.oldpass]
        stdcall StrDel, [.newpass]
        stdcall StrDel, [.newpass2]

        mov     [esp+4*regEAX], eax
        stc
        popad
        return


.bad_user:

        cinvoke sqliteFinalize, [.stmt]
        stdcall StrMakeRedirect, 0, "/!message/register_bot"
        jmp     .finish


.bad_password:

        cinvoke sqliteFinalize, [.stmt]
        stdcall StrMakeRedirect, 0, "/!message/change_password"
        jmp     .finish


.bad_parameter:

        stdcall StrMakeRedirect, 0, "/!message/login_missing_data"
        jmp     .finish


.error_different:

        stdcall StrMakeRedirect, 0, "/!message/change_different"
        jmp     .finish


.error_update:

        stdcall StrMakeRedirect, 0, "/!message/error_cant_write"
        jmp     .finish


.error_short_pass:
        stdcall StrMakeRedirect, 0, "/!message/register_short_pass/"
        jmp     .finish

endp





proc ChangeEmail, .pSpecial

.stmt     dd ?

.nick     dd ?
.password dd ?
.email    dd ?
.secret   dd ?

begin
        pushad

        xor     eax, eax
        mov     [.nick], eax
        mov     [.password], eax
        mov     [.email], eax
        mov     [.secret], eax

        mov     esi, [.pSpecial]
        mov     ebx, [esi+TSpecialParams.post_array]

        stdcall GetPostString, ebx, txt "password", 0
        test    eax, eax
        jz      .bad_parameter

        mov     [.password], eax

        stdcall StrLen, eax
        test    eax, eax
        jz      .bad_parameter


        stdcall GetPostString, ebx, txt "email", 0
        test    eax, eax
        jz      .bad_parameter

        mov     [.email], eax

        stdcall CheckEmail, eax
        jc      .bad_email

        stdcall GetRandomString, 32
        jc      .error_technical_problem

        mov     [.secret], eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUserPass, sqlGetUserPass.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.userID]

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .bad_user

        cinvoke sqliteColumnText, [.stmt], 1    ; salt
        stdcall StrDupMem, eax
        push    eax

        stdcall StrCat, eax, [.password]
        stdcall StrMD5, eax
        stdcall StrDel ; from the stack
        stdcall StrDel, [.password]
        mov     [.password], eax

        cinvoke sqliteColumnText, [.stmt], 2    ; the password hash.
        stdcall StrCompCase, [.password], eax
        jnc     .bad_password

        cinvoke sqliteColumnText, [.stmt], 0    ; the user nick
        stdcall StrDupMem, eax
        mov     [.nick], eax

        cinvoke sqliteFinalize, [.stmt]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlRegisterUser, sqlRegisterUser.length, eax, 0

        stdcall StrPtr, [.nick]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC        ; user nickname

        stdcall StrPtr, [.email]
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC        ; new email

        stdcall StrPtr, [.secret]
        cinvoke sqliteBindText, [.stmt], 6, eax, [eax+string.len], SQLITE_STATIC        ; the secret

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_update

        cinvoke sqliteFinalize, [.stmt]

        stdcall ProcessActivationEmails
        jc      .error_technical_problem

        stdcall StrMakeRedirect, 0, "/!message/email_activation_sent"

.finish:

        stdcall StrDel, [.nick]
        stdcall StrDel, [.password]
        stdcall StrDel, [.email]
        stdcall StrDel, [.secret]

        mov     [esp+4*regEAX], eax
        stc
        popad
        return


.bad_user:

        cinvoke sqliteFinalize, [.stmt]
        stdcall StrMakeRedirect, 0, "/!message/register_bot"
        jmp     .finish


.bad_password:

        cinvoke sqliteFinalize, [.stmt]
        stdcall StrMakeRedirect, 0, "/!message/change_password"
        jmp     .finish


.bad_parameter:

        stdcall StrMakeRedirect, 0, "/!message/login_missing_data"
        jmp     .finish


.error_update:

        stdcall StrMakeRedirect, 0, "/!message/error_cant_write"
        jmp     .finish


.bad_email:
        stdcall StrMakeRedirect, 0, "/!message/register_bad_email"
        jmp     .finish


.error_technical_problem:

        stdcall StrMakeRedirect, 0, "/!message/register_technical"
        jmp     .finish

endp

