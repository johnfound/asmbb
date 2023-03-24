

sqlUsersOnline  text "select U.nick from Users U where (U.LastSeen > (strftime('%s', 'now')-300)) and exists (select 1 from Sessions S where S.userID = U.id)"
sqlGuestsOnline text "select count(1) from Guests where (LastSeen > strftime('%s', 'now')-300)"

proc UsersOnline
.stmt dd ?
begin
        pushad

        stdcall StrNew
        mov     edi, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUsersOnline, sqlUsersOnline.length, eax, 0

        xor     ebx, ebx

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .end_loop

        cinvoke sqliteColumnText, [.stmt], 0

        test    ebx, ebx
        jz      .comma_ok

        stdcall StrCat, edi, txt ", "

.comma_ok:
        stdcall StrEncodeHTML, eax
        mov     ecx, eax
        stdcall StrURLEncode, eax

        stdcall StrCat, edi, '<a href="/!userinfo/'
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt '">'
        stdcall StrCat, edi, ecx
        stdcall StrDel, ecx
        stdcall StrCat, edi, txt "</a>"

        inc     ebx
        jmp     .loop

.end_loop:
        cinvoke sqliteFinalize, [.stmt]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGuestsOnline, sqlGuestsOnline.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish

        test    ebx, ebx
        jz      .and_ok

        stdcall StrCat, edi, " and "

.and_ok:
        cinvoke sqliteColumnInt, [.stmt], 0
        sub     eax, ebx
        jns     .count_ok

        xor     eax, eax

.count_ok:
        mov     ebx, eax

        stdcall NumToStr, ebx, ntsDec or ntsUnsigned
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, " guest"
        cmp     ebx, 1
        je      .finish

        stdcall StrCat, edi, txt "s"

.finish:
        cinvoke sqliteFinalize, [.stmt]

        mov     [esp+4*regEAX], edi
        popad
        return
endp





; Users tracking/activities.


 uaUnknown       = 0
 uaLoggingIn     = 1
 uaLoggingOut    = 2
 uaRegistering   = 3
 uaThreadList    = 4     ; The tag ID or NULL.
 uaReadingThread = 5     ; Thread slug.
 uaWritingPost   = 6     ; Thread slug where.
 uaEditingPost   = 7     ; PostID editting.
 uaDeletingPost  = 8
 uaUserProfile   = 9     ; UserName reading.
 uaAdminThings   = 10
 uaTrackingUsers = 11
 uaEditingThread = 12    ; Thread slug
 uaChatting      = 13
 uaResetingRequest   = 14       ; the page with reset request.
 uaResetRequestSent  = 15       ; the POST with reset request.
 uaResetingForm      = 16       ; the reset password form.
 uaResetingPassword  = 17
 uaReadingUserlist   = 18
 uaCategoriesList    = 19       ; /!categories
 uaAtomFeedUpdate    = 20



sqlLogUserActivity text "insert into UserLog(userID, remoteIP, Time, Activity, Param, Client) values (?1, ?2, strftime('%s','now'), ?3, ?4, ?5)"
sqlClipHistory     text "delete from UserLog where Time < strftime('%s','now') - 864000"

proc LogUserActivity, .pSpecialData, .activity, .param
.stmt dd ?
begin
        pushad

        cmp [.activity], uaLoggingIn ; we don't exit if user is logging in, we need save ticket for login process
        je      .noskiplogin

        cmp     [ThreadCnt], MAX_THREAD_CNT/2
        jge     .finish

.noskiplogin:

        mov     esi, [.pSpecialData]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlLogUserActivity, sqlLogUserActivity.length, eax, 0
        cmp     eax, SQLITE_OK
        jne     .finish

        mov     ebx, [.activity]
        mov     eax, [esi+TSpecialParams.userID]
        test    eax, eax
        jz      .userOK

        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.userID]

.userOK:
        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.remoteIP]
        cinvoke sqliteBindInt, [.stmt], 3, ebx

        mov     edx, [.param]
        xor     ecx, ecx        ; param type. 0 = string

        cmp     ebx, uaThreadList
        jne     .no_list

        mov     edx, [esi+TSpecialParams.dir]
        jmp     .param_ok

.no_list:

        cmp     ebx, uaReadingThread
        jne     .no_thread

        mov     edx, [esi+TSpecialParams.thread]
        jmp     .param_ok

.no_thread:

        cmp     ebx, uaWritingPost
        jne     .no_writing

        mov     edx, [esi+TSpecialParams.thread]
        jmp     .param_ok

.no_writing:

        cmp     ebx, uaEditingPost
        jne     .no_edit

        mov     edx, [esi+TSpecialParams.page_num]
        dec     ecx
        jmp     .param_ok

.no_edit:

        cmp     ebx, uaDeletingPost
        jne     .no_delete

        mov     edx, [esi+TSpecialParams.page_num]
        dec     ecx
        jmp     .param_ok

.no_delete:

        cmp     ebx, uaEditingThread
        jne     .no_edit_thread

        mov     edx, [esi+TSpecialParams.thread]
        jmp     .param_ok

.no_edit_thread:

.param_ok:
        test    ecx, ecx
        jz      .bind_string

        cinvoke sqliteBindInt, [.stmt], 4, edx
        jmp     .bind_ok

.bind_string:
        test    edx, edx
        jz      .bind_ok

        stdcall StrPtr, edx
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_STATIC

.bind_ok:

        stdcall ValueByName, [esi+TSpecialParams.params], "HTTP_USER_AGENT"
        jc      .client_ok

        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 5, eax, [eax+string.len], SQLITE_STATIC

.client_ok:
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        cinvoke sqliteExec, [hMainDatabase], sqlClipHistory, 0, 0, 0

.finish:
        popad
        return
endp



iglobal
  sqlGetUsersActivity StripText 'users_online.sql', SQL
endg

proc UserActivityTable, .pSpecialData

.stmt dd ?

begin
        pushad

        mov     esi, [.pSpecialData]

        test    [esi+TSpecialParams.userStatus], permRead or permAdmin
        jz      .error_cant_read

        stdcall CheckSecMode, [esi+TSpecialParams.params]
        cmp     eax, secNavigate
        jne     .error_cant_read

        mov     eax, [esi+TSpecialParams.userLang]
        stdcall StrCat, [esi+TSpecialParams.page_title], [cUsersOnlineTitle+8*eax]
        stdcall LogUserActivity, esi, uaTrackingUsers, 0

        stdcall StrDupMem, txt "users_online.css"
        stdcall ListAddDistinct, [esi+TSpecialParams.pStyles], eax
        mov     [esi+TSpecialParams.pStyles], edx

        stdcall TextCreate, sizeof.TText
        stdcall TextCat, eax, txt '<div class="users_online"><table class="users_table"><tr><th>User</th><th>Time</th><th>Activity</th>'

        test    [esi+TSpecialParams.userStatus], permAdmin
        jz      .admin_ok

        stdcall TextCat, edx, txt '<th>IP address</th><th>User agent</ht>'

.admin_ok:
        stdcall TextCat, edx, txt '</tr>'
        mov     edi, edx

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUsersActivity, sqlGetUsersActivity.length, eax, 0
        cmp     eax, SQLITE_OK
        jne     .finish

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finalize

        stdcall TextCat, edi, txt '<tr>'

; user name
        stdcall TextCat, edx, txt '<td>'
        mov     edi, edx

        cinvoke sqliteColumnText, [.stmt], 0
        test    eax, eax
        jnz     .make_user

        cinvoke sqliteColumnText, [.stmt], 5
        test    eax, eax
        jz      .bot

        stdcall IsBot, eax
        jc      .bot

        stdcall TextCat, edi, txt "Guest"
        mov     edi, edx
        jmp     .user_ok

.bot:
        stdcall TextCat, edi, txt "Robot"
        mov     edi, edx

.user_ok:

        cinvoke sqliteColumnInt, [.stmt], 4
        movzx   edx, al
        xor     dl, ah
        shr     eax, 16
        xor     dl, al
        xor     dl, ah

        stdcall NumToStr, edx, ntsHex or ntsFixedWidth or 2

        stdcall TextCat, edi, eax
        stdcall StrDel, eax
        jmp     .end_user

.make_user:
        stdcall StrEncodeHTML, eax
        mov     ecx, eax
        stdcall StrURLEncode, eax

        stdcall TextCat, edi, '<a href="/!userinfo/'
        stdcall TextCat, edx, eax
        stdcall StrDel, eax

        stdcall TextCat, edx, txt '">'
        stdcall TextCat, edx, ecx
        stdcall StrDel, ecx
        stdcall TextCat, edx, txt '</a>'

.end_user:
        stdcall TextCat, edx, txt '</td>'


; date

        stdcall TextCat, edx, txt '<td>'
        mov     edi, edx

        cinvoke sqliteColumnText, [.stmt], 3

        stdcall TextCat, edi, eax
        stdcall TextCat, edx, txt '</td>'

; activity

        stdcall TextCat, edx, txt '<td>'

        push    edx

        stdcall StrDupMem, 'activity'
        mov     ebx, eax
        cinvoke sqliteColumnInt, [.stmt], 1
        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        stdcall StrCat, ebx, eax
        stdcall StrCat, ebx, txt '.tpl'
        stdcall StrDel, eax

        pop     edx
        stdcall RenderTemplate, edx, ebx, [.stmt], esi
        mov     edi, eax

        stdcall StrDel, ebx

        stdcall TextCat, edi, txt '</td>'
        mov     edi, edx

; if admin, put some details:

        test    [esi+TSpecialParams.userStatus], permAdmin
        jz      .admin_ok2

        stdcall TextCat, edi, txt '<td>'
        mov     edi, edx

        cinvoke sqliteColumnInt, [.stmt], 4

        stdcall IP2Str, eax
        stdcall TextCat, edi, eax
        stdcall TextCat, edx, txt '<a class="ban_link" href="/!ip-report/'
        stdcall TextCat, edx, eax
        stdcall StrDel, eax
        stdcall TextCat, edx, txt '"></a></td><td>'
        mov     edi, edx

        cinvoke sqliteColumnText, [.stmt], 5
        test    eax, eax
        jz      @f
        stdcall StrEncodeHTML, eax
        stdcall TextCat, edi, eax
        stdcall StrDel, eax
        mov     edi, edx
@@:
        stdcall TextCat, edi, txt '</td>'
        mov     edi, edx

.admin_ok2:
; end of the row
        stdcall TextCat, edi, txt '</tr>'
        mov     edi, edx
        jmp     .loop

.finalize:

        cinvoke sqliteFinalize, [.stmt]

.finish:
        stdcall TextCat, edi, txt '</table></div>'
        mov     [esp+4*regEAX], edx
        clc
        popad
        return

; the user have no permissions to read information from the forum!
.error_cant_read:

        stdcall TextMakeRedirect, 0, "/!message/cant_read/"
        mov     [esp+4*regEAX], edi
        stc
        popad
        return
endp


proc IsBot, .hClient
begin
        stdcall StrMatchPatternNoCase, txt "*http*", [.hClient]
        jc      .yes
        stdcall StrMatchPatternNoCase, txt "*bot*", [.hClient]
        jc      .yes
        stdcall StrMatchPatternNoCase, txt "*crawl*", [.hClient]
        jc      .yes
        stdcall StrMatchPatternNoCase, txt "*spider*", [.hClient]
        jc      .yes
        stdcall StrMatchPatternNoCase, txt "*favicon*", [.hClient]
        jc      .yes
        stdcall StrLen, [.hClient]
        cmp     eax, 55                 ; CF=1 if below.
.yes:
        return
endp

