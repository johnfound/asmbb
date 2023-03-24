MIN_PASSWORD_RESET_LIMIT = 3600         ; 1h
DEFAULT_PASSWORD_RESET_LIMIT = 86400    ; 24h


MIN_PASS_LENGTH = 6
MAX_PASS_LENGTH = 1024

PERSISTENT_MAX_AGE equ "31536000"       ; 1 year persistent cookie.

NEW_USER_POST_INTERVAL          = 300   ; 5 minutes initial interval.
NEW_USER_POST_INTERVAL_INC      = -1    ; 300 posts to unlimited access.
sNEW_USER_POST_INTERVAL     text "300"
sNEW_USER_POST_INTERVAL_INC text "-1"


uopCreateAccount = 0
uopChangeEmail   = 1
uopResetPassword = 2
; uopDeleteAccount ?


sqlGetUserInfo   text "select id, salt, passHash, status from Users where nick = ?"
sqlInsertSession text "insert into sessions (userID, sid, FromIP, last_seen) values ( ?1, ?2, ?3, strftime('%s','now') )"
sqlUpdateSession text "update Sessions set userID = ?1, FromIP = ?3, last_seen = strftime('%s','now') where sid = ?2"
sqlCheckSession  text "select sid from sessions where userID = ? and fromIP = ?"
sqlCleanSessions text "delete from sessions where last_seen < (strftime('%s','now') - 2592000)"

sqlLoginTicket text "select ?1 as ticket, ?2 as email_flag"
sqlCheckLoginTicket text "select 1 from userlog where remoteIP=?1 and Client = ?2 and Param = ?3 and Activity = ?4"
sqlClearLoginTicket text "update userlog set Param = NULL where remoteIP=?1 and Activity in (1, 3, 14, 15, 16, 17)"


proc UserLogin, .pSpecial
.stmt  dd ?

.user     dd ?
.password dd ?

.userID   dd ?
.session  dd ?
.status   dd ?

.ticket   dd ?
.email_flag dd ?

begin
        pushad

        xor     eax, eax
        mov     [.session], eax
        mov     [.user], eax
        mov     [.password], eax
        mov     [.ticket], eax

        cinvoke sqliteExec, [hMainDatabase], sqlCleanSessions, sqlCleanSessions.length, eax, eax

        xor     eax, eax                                ; default no?
        stdcall GetParam, "email_confirm", gpInteger
        mov     [.email_flag], eax

; check the information

        mov     esi, [.pSpecial]
        mov     ebx, [esi+TSpecialParams.post_array]
        test    ebx, ebx
        jnz     .do_login_user

        mov     eax, [esi+TSpecialParams.userLang]
        stdcall StrCat, [esi+TSpecialParams.page_title], [cLoginDialogTitle+8*eax]

        stdcall GetRandomString, 32
        mov     ebx, eax

        stdcall LogUserActivity, esi, uaLoggingIn, ebx

        lea     ecx, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlLoginTicket, sqlLoginTicket.length, ecx, 0

        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len],  SQLITE_STATIC
        cinvoke sqliteBindInt, [.stmt], 2, [.email_flag]
        cinvoke sqliteStep, [.stmt]

        stdcall RenderTemplate, 0, "form_login.tpl", [.stmt], esi
        mov     [esp+4*regEAX], eax

        cinvoke sqliteFinalize, [.stmt]
        stdcall StrDel, ebx

        clc
        popad
        return


.do_login_user:
        stdcall CheckSecMode, [esi+TSpecialParams.params]
        cmp     eax, secNavigate
        jne     .redirect_back_bad_permissions

        stdcall ValueByName, [esi+TSpecialParams.post_array], txt "submit.x"
        jc      .redirect_back_bad_permissions

        stdcall ValueByName, [esi+TSpecialParams.post_array], txt "submit.y"
        jc      .redirect_back_bad_permissions

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

        stdcall GetPostString, ebx, "ticket", 0
        mov     [.ticket], eax

        test    eax, eax
        jz      .redirect_back_short

        stdcall StrLen, eax
        test    eax, eax
        jz      .redirect_back_short

; check the ticket

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCheckLoginTicket, sqlCheckLoginTicket.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.remoteIP]

        stdcall ValueByName, [esi+TSpecialParams.params], "HTTP_USER_AGENT"
        jc      .client_ok

        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

.client_ok:

        stdcall StrPtr, [.ticket]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 4, uaLoggingIn

        cinvoke sqliteStep, [.stmt]
        push    eax

        cinvoke sqliteFinalize, [.stmt]

        pop     eax
        cmp     eax, SQLITE_ROW
        jne     .redirect_back_short

; hash the password

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUserInfo, sqlGetUserInfo.length, eax, 0

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
        test    eax, eax
        jnz     .asmbb_standard

; It is phpbb type password.

        cinvoke sqliteColumnText, [.stmt], 2
        test    eax, eax
        jz      .redirect_back_bad_permissions

        push    ebx

        stdcall StrSplitList, eax, '|', FALSE
        mov     ebx, eax

        stdcall StrDup, [.password]
        mov     edi, eax

        stdcall StrPtr, [ebx+TArray.array]
        cmp     byte [eax], '$'
        je      .pass_ok

        stdcall StrMD5, edi
        stdcall StrDel, edi
        mov     edi, eax

.pass_ok:

        stdcall StrPtr, edi
        mov     edx, eax

        stdcall StrPtr, [ebx+TArray.array]

        cinvoke crypt,  edx, eax

        stdcall StrCompCase, eax, [ebx+TArray.array]
        pushf

        stdcall ListFree, ebx, StrDel
        stdcall StrDel, edi

        popf
        pop     ebx
        jc      .password_match
        jmp     .bad_user


.asmbb_standard:
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

.password_match:

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
        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.remoteIP]

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

        cinvoke sqliteBindInt, [.stmt], 3, [esi+TSpecialParams.remoteIP]

        cinvoke sqliteStep, [.stmt]
        push    eax

        cinvoke sqliteFinalize, [.stmt]

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        pop     eax
        cmp     eax, SQLITE_DONE
        jne     .cookie_ok               ; it is some error in the database, so don't set the cookie!

; now, set session cookie.

        stdcall TextCat, edi, "Set-Cookie: sid="
        stdcall TextCat, edx, [.session]
        stdcall TextCat, edx, "; HttpOnly; Path=/; "

        stdcall GetPostString, ebx, "persistent", 0
        test    eax, eax
        jz      .max_age_ok

        stdcall StrDel, eax
        stdcall TextCat, edx, <" Max-Age=", PERSISTENT_MAX_AGE, ";">

.max_age_ok:

        stdcall TextCat, edx, <txt 13, 10>
        mov     edi, edx

.cookie_ok:
        stdcall GetPostString, ebx, "backlink", 0
        test    eax, eax
        jnz     .go_back

        stdcall TextMakeRedirect, edi, txt "/"
        jmp     .finish_logged

.go_back:
        stdcall TextMakeRedirect, edi, eax
        stdcall StrDel, eax
        jmp     .finish_logged

.redirect_back_short:

        stdcall TextMakeRedirect, 0, "/!message/login_missing_data/"
        jmp     .finish

.redirect_back_bad_permissions:

        stdcall TextMakeRedirect, 0, "/!message/login_bad_permissions/"
        jmp     .finish


.redirect_back_bad_password:

        stdcall TextMakeRedirect, 0, "/!message/login_bad_password/"
        jmp     .finish

.finish_logged:
        mov     ecx, [.user]
        mov     edx, [.userID]

        xchg    ecx, [esi+TSpecialParams.userName]
        xchg    edx, [esi+TSpecialParams.userID]

        stdcall AddActivitySimple, cActivityLogin, atEnter, esi

        xchg    edx, [esi+TSpecialParams.userID]
        xchg    ecx, [esi+TSpecialParams.userName]

.finish:
        mov     [esp+4*regEAX], edi     ; the result

; clean the possible tickets:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlClearLoginTicket, sqlClearLoginTicket.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.remoteIP]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDel, [.user]
        stdcall StrDel, [.password]
        stdcall StrDel, [.session]
        stdcall StrDel, [.ticket]

        stc
        popad
        return

endp




sqlLogout text "delete from Sessions where userID = ?"

proc UserLogout, .pspecial
.stmt dd ?
begin
        pushad

        mov     esi, [.pspecial]

        OutputValue "Logout POST parameters: ", [esi+TSpecialParams.post_array], 16, 8

        stdcall CheckSecMode, [esi+TSpecialParams.params]
        cmp     eax, secNavigate
        jne     .error_trick                            ; this functions must be invoked only by navigation.

        cmp     [esi+TSpecialParams.post_array], 0      ; this function must be invoked only by POST request!
        je      .error_trick

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        stdcall LogUserActivity, esi, uaLoggingOut, 0

        cmp     [esi+TSpecialParams.session], 0
        je      .finish

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlLogout, -1, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.userID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

; delete the cookie.

        stdcall TextCat, edi, <"Set-Cookie: sid=; HttpOnly; Path=/; Max-Age=0", 13, 10>
        mov     edi, edx

        stdcall AddActivitySimple, cActivityLogout, atLeave, esi

.finish:
        stdcall GetBackLink, esi
        push    eax

        stdcall TextMakeRedirect, edi, eax
        stdcall StrDel ; from the stack

        mov     [esp+4*regEAX], edi
        stc
        popad
        return

.error_trick:
        xor     eax, eax
        mov     [esp+4*regEAX], eax
        clc
        popad
        return

endp






;sqlCheckMinInterval text "select (strftime('%s','now') - time_reg) as delta from WaitingActivation where (ip_from = ?) and ( delta>30 ) order by time_reg desc limit 1"
sqlRegisterUser    text "insert or replace into WaitingActivation (nick, passHash, salt, email, ip_from, time_reg, time_email, a_secret, operation) values (?1, ?2, ?3, ?4, ?5, strftime('%s','now'), NULL, ?6, ?7)"
sqlCheckUserExists text "select 1 from Users where nick = ? or email = ? limit 1"

proc RegisterNewUser, .pSpecial

.stmt      dd ?

.user      dd ?
.password  dd ?
.password2 dd ?
.email     dd ?
.secret    dd ?
.ticket    dd ?

.email_flag dd ?

begin
        pushad

        xor     eax, eax
        mov     [.user], eax
        mov     [.password], eax
        mov     [.password2], eax
        mov     [.email], eax
        mov     [.secret], eax
        mov     [.ticket], eax

; check the information

        xor     eax, eax                                ; default no?
        stdcall GetParam, "email_confirm", gpInteger
        mov     [.email_flag], eax

        mov     esi, [.pSpecial]
        cmp     [esi+TSpecialParams.userID], 0
        jne     .error_trick

        stdcall CheckSecMode, [esi+TSpecialParams.params]
        cmp     eax, secNavigate
        jne     .error_trick

        test    [esi+TSpecialParams.userStatus], permLogin      ; For the guests, permLogin == permRegister
        jz      .error_closed_registration

        mov     ebx, [esi+TSpecialParams.post_array]
        test    ebx, ebx
        jnz     .do_register_user

        stdcall GetRandomString, 32
        mov     ebx, eax

        stdcall LogUserActivity, esi, uaRegistering, ebx

        lea     ecx, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlLoginTicket, sqlLoginTicket.length, ecx, 0

        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len],  SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 2, [.email_flag]

        cinvoke sqliteStep, [.stmt]

        stdcall RenderTemplate, 0, "form_register.tpl", [.stmt], esi
        mov     [esp+4*regEAX], eax

        cinvoke sqliteFinalize, [.stmt]
        stdcall StrDel, ebx

        clc
        popad
        return


.do_register_user:

        stdcall ValueByName, [esi+TSpecialParams.post_array], txt "submit.x"
        jc      .error_trick

        stdcall ValueByName, [esi+TSpecialParams.post_array], txt "submit.y"
        jc      .error_trick

        stdcall GetPostString, ebx, "username", 0
        mov     [.user], eax

        test    eax, eax
        jz      .error_short_name

        stdcall StrClipSpacesR, eax
        stdcall StrClipSpacesL, eax

        stdcall ValidateUserName, eax
        jnc     .error_short_name         ; the name contains special characters actually!

        stdcall StrLen, eax
        cmp     eax, 2
        jbe     .error_short_name

        cmp     eax, 256
        ja      .error_trick

        stdcall GetPostString, ebx, "email", 0
        mov     [.email], eax

        cmp     [.email_flag], 0
        jne     .check_email

; Use the email field as a honeypot, if the activation emails are disabled.
; Some kind of bot protection...

        test    eax, eax
        jz      .check_password

        stdcall StrLen, eax
        test    eax, eax
        jz      .check_password

        jmp     .error_trick

; Check the email in case the activation email will be sent
.check_email:
        test    eax, eax
        jz      .error_bad_email

        stdcall StrClipSpacesR, eax
        stdcall StrClipSpacesL, eax

        stdcall CheckEmail, eax
        jc      .error_bad_email

.check_password:

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

        cmp     eax, MIN_PASS_LENGTH
        jb      .error_short_pass

        cmp     eax, MAX_PASS_LENGTH
        ja      .error_trick

        stdcall GetPostString, ebx, "ticket", 0
        mov     [.ticket], eax

        test    eax, eax
        jz      .error_trick

        stdcall StrLen, eax
        test    eax, eax
        jz      .error_trick

; check the ticket

        DebugMsg "Check the ticket."

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCheckLoginTicket, sqlCheckLoginTicket.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.remoteIP]

        stdcall ValueByName, [esi+TSpecialParams.params], "HTTP_USER_AGENT"
        jc      .client_ok

        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

.client_ok:

        stdcall StrPtr, [.ticket]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 4, uaRegistering

        cinvoke sqliteStep, [.stmt]
        push    eax

        cinvoke sqliteFinalize, [.stmt]
        pop     eax

        cmp     eax, SQLITE_ROW
        jne     .error_trick

; hash the password

        DebugMsg "The ticket is OK"

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

        cmp     [.email], 0
        je      .email_ok2

        stdcall StrPtr, [.email]
        cmp     [eax+string.len], 0
        je      .email_ok2

        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

.email_ok2:

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_ROW
        je      .error_exists

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlRegisterUser, sqlRegisterUser.length, eax, 0

        stdcall StrPtr, [.user]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.password]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.password2]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

        cmp     [.email], 0
        je      .email_ok

        stdcall StrPtr, [.email]
        cmp     [eax+string.len], 0
        je      .email_ok

        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC

.email_ok:

        cinvoke sqliteBindInt, [.stmt], 5, [esi+TSpecialParams.remoteIP]

        stdcall StrPtr, [.secret]
        cinvoke sqliteBindText, [.stmt], 6, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 7, uopCreateAccount

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_exists

        cmp     [.email_flag], 0
        je      .no_confirm

; now send the activation email for all registered user, where the email was not sent.

        stdcall ProcessActivationEmails

; the user has been created and now is waiting for email activation.

        stdcall TextMakeRedirect, 0, "/!message/user_created/"
        jmp     .finish

.no_confirm:

        stdcall StrDupMem, "/!activate/"
        stdcall StrCat, eax, [.secret]
        push    eax

        stdcall TextMakeRedirect, 0, eax
        stdcall StrDel ; from the stack
        jmp     .finish


.error_technical_problem:

        stdcall TextMakeRedirect, 0, "/!message/register_technical/"
        jmp     .finish


.error_short_name:

        stdcall TextMakeRedirect, 0, "/!message/register_short_name/"
        jmp     .finish

.error_trick:

        stdcall TextMakeRedirect, 0, "/!message/register_bot/"
        jmp     .finish


.error_bad_email:
        stdcall TextMakeRedirect, 0, "/!message/register_bad_email/"
        jmp     .finish


.error_short_pass:
        stdcall TextMakeRedirect, 0, "/!message/register_short_pass/"
        jmp     .finish

.error_closed_registration:
        stdcall TextMakeRedirect, 0, "/!message/closed_registration/"
        jmp     .finish

.error_different:

        stdcall TextMakeRedirect, 0, "/!message/register_passwords_different/"
        jmp     .finish


.error_exists:

        stdcall TextMakeRedirect, 0, "/!message/register_user_exists/"

.finish:
        mov     [esp+4*regEAX], edi

; clean the possible tickets:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlClearLoginTicket, sqlClearLoginTicket.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.remoteIP]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDel, [.user]
        stdcall StrDel, [.password]
        stdcall StrDel, [.password2]
        stdcall StrDel, [.email]
        stdcall StrDel, [.secret]
        stdcall StrDel, [.ticket]

        stc
        popad
        return
endp



sqlBegin      text  "begin transaction;"
sqlActivate   StripText 'activate.sql', SQL
sqlDeleteWait text  "delete from WaitingActivation where a_secret = ?1"
sqlCheckType  text  "select operation, time_reg, time_email from WaitingActivation where a_secret = ?1"
sqlCommit     text  "commit transaction"
sqlRollback   text  "rollback"

sqlUpdateUserEmail text "update users set email = (select email from WaitingActivation where a_secret = ?1) where nick = (select nick from WaitingActivation where a_secret = ?1)"


proc ActivateAccount, .pSpecial
.stmt dd ?
.type dd ?
.min_time dd ?
.time_reg   dq ?
.time_email dq ?
begin
        pushad

        mov     esi, [.pSpecial]
        xor     edi, edi

        mov     edx, [esi+TSpecialParams.cmd_list]
        cmp     [edx+TArray.count], edi
        je      .exit

        stdcall CheckSecMode, [esi+TSpecialParams.params]
        cmp     eax, secNavigate
        jne     .exit

        mov     ebx, [edx+TArray.array]

; begin transaction

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlBegin, sqlBegin.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        cinvoke sqliteFinalize, [.stmt]

; check again whether all is successful.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCheckType, sqlCheckType.length, eax, 0

        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .rollback               ; there is no such record in the WaitingActivation table.

        cinvoke sqliteColumnInt, [.stmt], 0    ; the operation
        mov     [.type], eax

        cinvoke sqliteColumnInt64, [.stmt], 1  ; the time of the operation.
        mov     dword [.time_reg], eax
        mov     dword [.time_reg+4], edx

        cinvoke sqliteColumnInt64, [.stmt], 2  ; the time of the operation.
        mov     dword [.time_email], eax
        mov     dword [.time_email+4], edx

        cinvoke sqliteFinalize, [.stmt]

        cmp     [.type], uopCreateAccount
        je      .insert_new_user

        cmp     [.type], uopChangeEmail
        jne     .rollback

; update user email

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateUserEmail, sqlUpdateUserEmail.length, eax, 0

        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .rollback

        jmp     .finalize_delete_from_waiting


; insert new user

.insert_new_user:
        stdcall GetParam, 'activate_min_interval', gpInteger
        jc      .time_ok
        mov     ecx, eax

        stdcall GetTime
        sub     eax, dword [.time_reg]
        sbb     edx, dword [.time_reg+4]
        jnz     .error_too_early

        sub     ecx, eax
        jg      .error_too_early

.time_ok:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlActivate, sqlActivate.length, eax, 0

        stdcall GetParam, "user_perm", gpInteger
        jc      .rollback

        cinvoke sqliteBindInt, [.stmt], 1, eax

        mov     eax, NEW_USER_POST_INTERVAL
        stdcall GetParam, "nu_post_interval", gpInteger
        cinvoke sqliteBindInt, [.stmt], 2, eax

        mov     eax, NEW_USER_POST_INTERVAL_INC
        stdcall GetParam, "nu_post_interval_inc", gpInteger
        cinvoke sqliteBindInt, [.stmt], 3, eax

        xor     eax, eax
        stdcall GetParam, "nu_max_post_length", gpInteger
        cinvoke sqliteBindInt, [.stmt], 4, eax

        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 5, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_DONE
        jne     .rollback


.finalize_delete_from_waiting:

        cinvoke sqliteFinalize, [.stmt]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDeleteWait, sqlDeleteWait.length, eax, 0

        stdcall StrPtr, ebx
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

        cmp     [.type], uopCreateAccount
        je      .msg_new_account

        stdcall TextMakeRedirect, 0, "/!message/email_changed"
        jmp     .finish


.msg_new_account:
        stdcall TextMakeRedirect, 0, "/!message/congratulations"


.finish:
        stc

.exit:
        mov     [esp+4*regEAX], edi
        popad
        return


.rollback:
        cinvoke sqliteFinalize, [.stmt]         ; finalize the bad statement.

; rollback transaction

        cinvoke sqliteExec, [hMainDatabase], sqlRollback, 0, 0, 0

        stdcall TextMakeRedirect, 0, "/!message/bad_secret"
        jmp     .finish

.error_too_early:

; rollback transaction and then make a special minimal size page in order to wait for activation.
        push    ecx
        cinvoke sqliteExec, [hMainDatabase], sqlRollback, 0, 0, 0
        pop     ecx

        stdcall TextCreate, sizeof.TText
        mov     edx, eax

        stdcall TextAddString, edx, [edx+TText.GapBegin], cActivatePage1

        stdcall NumToStr, ecx, ntsDec or ntsUnsigned
        stdcall TextAddString, edx, [edx+TText.GapBegin], eax
        stdcall StrDel, eax

        stdcall TextAddString, edx, [edx+TText.GapBegin], cActivatePage2
        mov     edi, edx
        jmp     .finish
endp

cActivatePage1 text 'Content-type: text/html; charset=utf-8', 13, 10, 13, 10,           \
                    '<!DOCTYPE html><html><head><script>setInterval(function(){a=document.getElementById("t"); t=a.innerHTML; if (t>0) a.innerHTML=t-1; else location.reload()},1000);</script>', \
                    '<body><p>Activation after <b id="t">'
cActivatePage2 text '</b> seconds. Wait!'





proc ResetPassword, .pSpecial

.stmt      dd ?

.username  dd ?
.email     dd ?
.password  dd ?
.password2 dd ?
.hash      dd ?
.salt      dd ?
.ticket    dd ?
.secret    dd ?

begin
        pushad

        xor     eax, eax
        mov     [.username], eax
        mov     [.email], eax
        mov     [.password], eax
        mov     [.password2], eax
        mov     [.hash], eax
        mov     [.salt], eax
        mov     [.ticket], eax
        mov     [.secret], eax

        mov     esi, [.pSpecial]

        stdcall CheckSecMode, [esi+TSpecialParams.params]
        cmp     eax, secNavigate
        jne     .error_trick

        mov     edx, [esi+TSpecialParams.cmd_list]
        cmp     [edx+TArray.count], 0
        je      .show_request_form          ; the first step.

        mov     ebx, [edx+TArray.array] ; the step number.

        stdcall StrLen, ebx
        cmp     eax, 1
        jne     .error_trick

        stdcall StrPtr, ebx
        mov     al, [eax]

        cmp     al, '1'         ; the 1st post request.
        je      .write_reset_request

        cmp     al, '2'
        je      .show_reset_form

        cmp     al, '3'
        je      .do_reset_password

        jmp     .error_trick


;---------------------------------------------------------------
; Step 0 - display the reset request form.

.show_request_form:

        cmp     [esi+TSpecialParams.post_array], 0
        jne     .error_trick

        stdcall GetRandomString, 32
        mov     [.ticket], eax

        stdcall LogUserActivity, esi, uaResetingRequest, [.ticket]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlLoginTicket, sqlLoginTicket.length, eax, 0

        stdcall StrPtr, [.ticket]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]

        stdcall RenderTemplate, 0, 'form_reset_request.tpl', [.stmt], esi
        mov     [esp+4*regEAX], eax

        cinvoke sqliteFinalize, [.stmt]

        clc

.finish:
        stdcall StrDel, [.username]
        stdcall StrDel, [.email]
        stdcall StrDel, [.password]
        stdcall StrDel, [.password2]
        stdcall StrDel, [.hash]
        stdcall StrDel, [.salt]
        stdcall StrDel, [.ticket]
        stdcall StrDel, [.secret]

        popad
        return

;---------------------------------------------------------------
; Step 1 - the request has been posted here.

sqlCheckTime    text "select 1 from UserLog where remoteIP = ?1 and Activity = 15 and time > strftime('%s','now') - ?2"
sqlGetUserEmail text "select email from Users where nick = ?1"
sqlResetRequest text "insert into WaitingActivation (nick, email, ip_from, time_reg, a_secret, operation) values (?1, ?2, ?3, strftime('%s','now'), ?4, ?5)"


.write_reset_request:

        cmp     [esi+TSpecialParams.post_array], 0
        je      .error_trick

; check the visitor last reset request.

        mov     eax, DEFAULT_PASSWORD_RESET_LIMIT
        mov     ecx, MIN_PASSWORD_RESET_LIMIT

        stdcall GetParam, "reset_password_limit", gpInteger     ; in seconds between two reset attempts.
        mov     ebx, eax
        cmp     ebx, ecx
        cmovb   ebx, ecx

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCheckTime, sqlCheckTime.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.remoteIP]
        cinvoke sqliteBindInt, [.stmt], 2, ebx
        cinvoke sqliteStep, [.stmt]
        mov     ebx,eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_ROW
        je      .error_bad_user

        stdcall GetPostString, [esi+TSpecialParams.post_array], "username", 0
        test    eax, eax
        jz      .error_bad_user

        mov     [.username], eax

        stdcall GetPostString, [esi+TSpecialParams.post_array], "email", 0
        test    eax, eax
        jz      .error_bad_user

        mov     [.email], eax

; check the email from the database.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUserEmail, sqlGetUserEmail.length, eax, 0

        stdcall StrPtr, [.username]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_unknown_user

        cinvoke sqliteColumnText, [.stmt], 0

        stdcall StrCompCase, eax, [.email]
        jnc     .error_unknown_user

        cinvoke sqliteFinalize, [.stmt]

; check the ticket

        mov     eax, uaResetingRequest  ; the ticket from the previous form.
        call    .check_the_ticket
        jc      .error_trick

        stdcall LogUserActivity, esi, uaResetRequestSent, 0

; Register the user for password reset.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlResetRequest, sqlResetRequest.length, eax, 0

        stdcall StrPtr, [.username]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.email]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteBindInt, [.stmt], 3, [esi+TSpecialParams.remoteIP]

        stdcall GetRandomString, 32
        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

        cinvoke sqliteBindInt, [.stmt], 5, uopResetPassword
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_write

        stdcall ProcessActivationEmails

; delete possible tickets.

        call    .cleanup_tickets

        stdcall TextMakeRedirect, 0, "/!resetpassword/2"
        jmp     .finish_redirect



;---------------------------------------------------------------
; Step 2 - the request has been sent, so show the reset form.

.show_reset_form:

        stdcall GetRandomString, 32
        mov     [.ticket], eax

        stdcall LogUserActivity, esi, uaResetingForm, [.ticket]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlLoginTicket, sqlLoginTicket.length, eax, 0

        stdcall StrPtr, [.ticket]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]

        stdcall RenderTemplate, 0, 'form_reset_password.tpl', [.stmt], esi
        mov     [esp+4*regEAX], eax

        cinvoke sqliteFinalize, [.stmt]
        clc

        jmp     .finish


;---------------------------------------------------------------
; Step 3 - check the parameters and actually reset the password

sqlGetWaiting   text "select operation, nick, email, time_reg from WaitingActivation where a_secret = ?1"
sqlSetUserPass  text "update users set passHash = ?1, salt = ?2 where nick = ?3"

.do_reset_password:

        mov     edi, [esi+TSpecialParams.post_array]
        test    edi, edi
        jz      .error_trick

        stdcall GetPostString, edi, "username", 0
        test    eax, eax
        jz      .error_trick

        mov     [.username], eax

        stdcall GetPostString, edi, "email", 0
        test    eax, eax
        jz      .error_trick

        mov     [.email], eax

        stdcall GetPostString, edi, "secret", 0
        test    eax, eax
        jz      .error_trick

        mov     [.secret], eax

        stdcall GetPostString, edi, "ticket", 0
        test    eax, eax
        jz      .error_trick

        mov     [.ticket], eax

        stdcall GetPostString, edi, "password", 0
        test    eax, eax
        jz      .error_trick

        mov     [.password], eax

        stdcall GetPostString, edi, "password2", 0
        test    eax, eax
        jz      .error_trick

        mov     [.password2], eax


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetWaiting, sqlGetWaiting.length, eax, 0

        stdcall StrPtr, [.secret]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_missing_request

        cinvoke sqliteColumnInt, [.stmt], 0     ; the operation
        cmp     eax, uopResetPassword
        jne     .error_missing_request

        cinvoke sqliteColumnText, [.stmt], 1    ; the nick field.
        stdcall StrCompCase, eax, [.username]
        jnc     .error_missing_request

        cinvoke sqliteColumnText, [.stmt], 2    ; the email used in the request.
        stdcall StrCompCase, eax, [.email]
        jnc     .error_missing_request

        cinvoke sqliteFinalize, [.stmt]


        stdcall StrCompCase, [.password], [.password2]
        jnc     .error_not_match

        stdcall StrLen, [.password]
        cmp     eax, MIN_PASS_LENGTH
        jb      .error_short_password

        cmp     eax, MAX_PASS_LENGTH
        ja      .error_trick

        stdcall HashPassword, [.password]
        mov     [.hash], eax
        mov     [.salt], edx

; check the ticket

        mov     eax, uaResetingForm
        call    .check_the_ticket
        jc      .error_trick

; everything is OK, so do reset the password.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSetUserPass, sqlSetUserPass.length, eax, 0

        stdcall StrPtr, [.hash]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.salt]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.username]
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_write

; delete WaitingActivation record

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDeleteWait, sqlDeleteWait.length, eax, 0

        stdcall StrPtr, [.secret]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

; delete possible tickets.

        call    .cleanup_tickets

        stdcall TextMakeRedirect, 0, "/!message/congratulations"
        jmp     .finish_redirect

;.............................................................................................

.error_write:
        stdcall TextMakeRedirect, 0, "/!message/error_cant_write"
        jmp     .finish_redirect

.error_unknown_user:

        cinvoke sqliteFinalize, [.stmt]

.error_bad_user:

        stdcall TextMakeRedirect, 0, "/!message/register_technical"
        jmp     .finish_redirect

.error_trick:

        stdcall TextMakeRedirect, 0, "/!message/register_bot"
        jmp     .finish_redirect

.error_short_password:

        stdcall TextMakeRedirect, 0, "/!message/register_short_pass"
        jmp     .finish_redirect

.error_not_match:

        stdcall TextMakeRedirect, 0, "/!message/register_passwords_different"
        jmp     .finish_redirect

.error_missing_request:

        cinvoke sqliteFinalize, [.stmt]
        stdcall TextMakeRedirect, 0, "/!message/bad_secret"

.finish_redirect:
        mov     [esp+4*regEAX], edi
        stc
        jmp     .finish



.check_the_ticket:
        pushad

;"select 1 from userlog where remoteIP=?1 and Client = ?2 and Param = ?3 and Activity = ?4"

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCheckLoginTicket, sqlCheckLoginTicket.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.remoteIP]

        stdcall ValueByName, [esi+TSpecialParams.params], "HTTP_USER_AGENT"
        jc      .no_ticket

        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        stdcall GetPostString, [esi+TSpecialParams.post_array], "ticket", 0
        test    eax, eax
        jz      .no_ticket

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

        mov     eax, [esp+4*regEAX]
        cinvoke sqliteBindInt, [.stmt], 4, eax

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .no_ticket

        cinvoke sqliteFinalize, [.stmt]
        clc
        popad
        retn

.no_ticket:
        cinvoke sqliteFinalize, [.stmt]
        stc
        popad
        retn


.cleanup_tickets:
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlClearLoginTicket, sqlClearLoginTicket.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.remoteIP]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        popad
        retn
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
        test    ebx, ebx
        jz      .bad_parameter

        stdcall CheckSecMode, [esi+TSpecialParams.params]
        cmp     eax, secNavigate
        jne     .bad_parameter

        stdcall GetPostString, ebx, "ticket", 0
        test    eax, eax
        jz      .bad_parameter

        mov     edi, eax
        stdcall CheckTicket, edi, [esi+TSpecialParams.session]
        pushf
        stdcall ClearTicket3, edi
        stdcall StrDel, edi
        popf
        jc      .bad_parameter


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

        stdcall TextMakeRedirect, 0, "/!message/password_changed"

.finish:

        stdcall StrDel, [.oldpass]
        stdcall StrDel, [.newpass]
        stdcall StrDel, [.newpass2]

        mov     [esp+4*regEAX], edi
        stc
        popad
        return


.bad_user:

        cinvoke sqliteFinalize, [.stmt]
        stdcall TextMakeRedirect, 0, "/!message/register_bot"
        jmp     .finish


.bad_password:

        cinvoke sqliteFinalize, [.stmt]
        stdcall TextMakeRedirect, 0, "/!message/change_password"
        jmp     .finish


.bad_parameter:

        stdcall TextMakeRedirect, 0, "/!message/login_missing_data"
        jmp     .finish


.error_different:

        stdcall TextMakeRedirect, 0, "/!message/change_different"
        jmp     .finish


.error_update:

        stdcall TextMakeRedirect, 0, "/!message/error_cant_write"
        jmp     .finish


.error_short_pass:
        stdcall TextMakeRedirect, 0, "/!message/register_short_pass/"
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
        test    ebx, ebx
        jz      .bad_parameter

        stdcall CheckSecMode, [esi+TSpecialParams.params]
        cmp     eax, secNavigate
        jne     .bad_parameter

        stdcall GetPostString, ebx, "ticket", 0
        test    eax, eax
        jz      .bad_parameter

        mov     edi, eax
        stdcall CheckTicket, edi, [esi+TSpecialParams.session]
        pushf
        stdcall ClearTicket3, edi
        stdcall StrDel, edi
        popf
        jc      .bad_parameter

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

        cinvoke sqliteBindInt, [.stmt], 5, [esi+TSpecialParams.remoteIP]

        stdcall StrPtr, [.secret]
        cinvoke sqliteBindText, [.stmt], 6, eax, [eax+string.len], SQLITE_STATIC        ; the secret

        cinvoke sqliteBindInt, [.stmt], 7, uopChangeEmail

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_update

        stdcall GetParam, "email_confirm", gpInteger
        jc      .send_emails

        test    eax, eax
        jnz     .send_emails

        stdcall StrDupMem, "/!activate/"
        stdcall StrCat, eax, [.secret]
        push    eax

        stdcall TextMakeRedirect, 0, eax
        stdcall StrDel ; from the stack
        jmp     .finish

.send_emails:

        stdcall ProcessActivationEmails
        stdcall TextMakeRedirect, 0, "/!message/email_activation_sent"

.finish:

        stdcall StrDel, [.nick]
        stdcall StrDel, [.password]
        stdcall StrDel, [.email]
        stdcall StrDel, [.secret]

        mov     [esp+4*regEAX], edi
        stc
        popad
        return


.bad_user:

        cinvoke sqliteFinalize, [.stmt]
        stdcall TextMakeRedirect, 0, "/!message/register_bot"
        jmp     .finish


.bad_password:

        cinvoke sqliteFinalize, [.stmt]
        stdcall TextMakeRedirect, 0, "/!message/change_password"
        jmp     .finish


.bad_parameter:

        stdcall TextMakeRedirect, 0, "/!message/login_missing_data"
        jmp     .finish


.error_update:

        stdcall TextMakeRedirect, 0, "/!message/error_cant_write"
        jmp     .finish


.bad_email:
        stdcall TextMakeRedirect, 0, "/!message/register_bad_email"
        jmp     .finish


.error_technical_problem:

        stdcall TextMakeRedirect, 0, "/!message/register_technical"
        jmp     .finish

endp




proc ValidateUserName, .hName
begin
        push    eax
        stdcall StrEncodeHTML, [.hName]
        stdcall StrCompCase, [.hName], eax
        stdcall StrDel, eax
        pop     eax
        return
endp