

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
uaThreadList    = 3     ; The tag ID or NULL.
uaReadingThread = 4     ; ThreadID.
uaWritingPost   = 5     ; ThreadID where.
uaEditingPost   = 6     ; PostID editting.
uaUserProfile   = 7     ; UserID reading.
uaAdminThings   = 8
uaTrackingUsers = 9


;create table UserLog (
;  userID integer  default NULL references Users(id) on delete cascade on update cascade,     -- If == NULL, it means the user is not logged in. See userAddr.
;  userAddr integer,                                                                          -- The IP address of the user or the guests;
;  Time   integer,                                                                            -- time the user make some action.
;  Place  integer default NULL,                                                               -- id of the forum place. This constant depends on the engine.
;  PlaceID integer default NULL                                                               -- if the place has some ID, write it here. It depends on Place value and can be thread ID, post ID or user profile ID, etc.
;);


sqlLogUserActivity text "insert into UserLog values userID = ?1, userAddr = ?2, Time = strftime('%s','now'), Activity = ?3, Param = ?4"


proc LogUserActivity, .userID, .activity, .param
begin









        return
endp