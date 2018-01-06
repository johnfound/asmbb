

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
        stdcall StrCat, edi, '<a href="/!userinfo/'
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt '">'
        stdcall StrCat, edi, eax
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
 uaReadingThread = 5     ; ThreadID.
 uaWritingPost   = 6     ; ThreadID where.
 uaEditingPost   = 7     ; PostID editting.
 uaDeletingPost  = 8
 uaUserProfile   = 9     ; UserName reading.
 uaAdminThings   = 10
 uaTrackingUsers = 11
 uaEditingThread = 12    ; ThreadID
 uaChatting      = 13



sqlLogUserActivity text "insert into UserLog(userID, remoteIP, Time, Activity, Param, Client) values (?1, ?2, strftime('%s','now'), ?3, ?4, ?5)"
sqlClipHistory     text "delete from UserLog where Time < strftime('%s','now') - 864000"

proc LogUserActivity, .pSpecialData, .activity, .param
.stmt dd ?
begin
        pushad

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

        xor     edx, edx
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

        cmp     ebx, uaUserProfile
        jne     .no_profile

        mov     edx, [.param]
        jmp     .param_ok

.no_profile:

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

        stdcall StrCat, [esi+TSpecialParams.page_title], cUsersOnlineTitle

        stdcall StrNew
        mov     edi, eax

        stdcall LogUserActivity, esi, uaTrackingUsers, 0

        stdcall ListAddDistinct, [esi+TSpecialParams.pStyles], "users_online.css"
        mov     [esi+TSpecialParams.pStyles], edx

        stdcall StrCat, edi, '<div class="users_online"><table class="users_table"><tr><th>User</th><th>Time</th><th>Activity</th>'

        test    [esi+TSpecialParams.userStatus], permAdmin
        jz      .admin_ok

        stdcall StrCat, edi, '<th>IP address</th><th>User agent</ht>'

.admin_ok:
        stdcall StrCat, edi, '</tr>'

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUsersActivity, sqlGetUsersActivity.length, eax, 0
        cmp     eax, SQLITE_OK
        jne     .finish

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finalize

        stdcall StrCat, edi, txt '<tr>'


; user name
        stdcall StrCat, edi, txt '<td>'

        cinvoke sqliteColumnText, [.stmt], 0
        test    eax, eax
        jnz     .make_user

        cinvoke sqliteColumnText, [.stmt], 5
        test    eax, eax
        jz      .bot

        stdcall IsBot, eax
        jc      .bot

        stdcall StrCat, edi, txt "Guest"
        jmp     .user_ok

.bot:
        stdcall StrCat, edi, txt "Robot"

.user_ok:

        cinvoke sqliteColumnInt, [.stmt], 4
        movzx   edx, al
        xor     dl, ah
        shr     eax, 16
        xor     dl, al
        xor     dl, ah

        stdcall NumToStr, edx, ntsHex or ntsFixedWidth or 2
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        jmp     .end_user

.make_user:
        stdcall StrCat, edi, '<a href="/!userinfo/'
        stdcall StrCat, edi, eax
        stdcall StrCharCat, edi, '">'
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt '</a>'

.end_user:
        stdcall StrCat, edi, txt '</td>'


; date

        stdcall StrCat, edi, txt '<td>'
        cinvoke sqliteColumnText, [.stmt], 3
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt '</td>'

; activity

        stdcall StrCat, edi, txt '<td>'

        stdcall GetActivityArgs, [.stmt]
        stdcall StrCatTemplate, edi, eax, ebx, esi

        stdcall StrDel, eax
        cinvoke sqliteFinalize, ebx

        stdcall StrCat, edi, txt '</td>'

; if admin, put some details:

        test    [esi+TSpecialParams.userStatus], permAdmin
        jz      .admin_ok2

        stdcall StrCat, edi, txt '<td>'

        cinvoke sqliteColumnInt, [.stmt], 4
        stdcall IP2Str, eax
        stdcall StrCat, edi, eax

        stdcall StrCat, edi, ' <a class="ban_link" href="/!ban_ip/'
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt '"></a></td><td>'

        cinvoke sqliteColumnText, [.stmt], 5
        test    eax, eax
        jz      @f
        stdcall StrCat, edi, eax
@@:
        stdcall StrCat, edi, txt '</td>'

.admin_ok2:
; end of the row

        stdcall StrCat, edi, txt '</tr>'

        jmp     .loop

.finalize:

        cinvoke sqliteFinalize, [.stmt]

.finish:
        stdcall StrCat, edi, txt '</table></div>'

        mov     [esp+4*regEAX], edi
        clc
        popad
        return
endp


proc IsBot, .hClient
begin
        stdcall StrMatchPatternNoCase, txt "*+http*", [.hClient]
        jc      .yes
        stdcall StrMatchPatternNoCase, txt "*bot*", [.hClient]
        jc      .yes
        stdcall StrMatchPatternNoCase, txt "*crawl*", [.hClient]
        jc      .yes
        stdcall StrMatchPatternNoCase, txt "*spider*", [.hClient]
.yes:
        return
endp





; returns:
;
;   name of the template in eax
;   SQLite statement in ebx
;


  sqlOnlineParam text "select ?1 as Param"


proc GetActivityArgs, .sqlStatement
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlOnlineParam, sqlOnlineParam.length, eax, 0

        stdcall StrDupMem, "activity"
        mov     [esp+4*regEAX], eax
        mov     ebx, eax

        cinvoke sqliteColumnText, [.sqlStatement], 1
        stdcall StrCat, ebx, eax

        cinvoke sqliteColumnText, [.sqlStatement], 2
        cinvoke sqliteBindText, [.stmt], 1, eax, -1, SQLITE_TRANSIENT

        cinvoke sqliteStep, [.stmt]

        mov     ebx, [.stmt]
        mov     [esp+4*regEBX], ebx

        popad
        return
endp
