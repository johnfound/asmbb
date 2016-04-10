MAX_AVATAR_SIZE = 50*1024
MAX_USER_DESC   = 10*1024



sqlGetFullUserInfo text "select ",                                                                      \
                          "id as userid, ",                                                             \
                          "nick as username, ",                                                         \
                          "status, ",                                                                   \
                          "user_desc, ",                                                                \
                          "avatar, ",                                                                   \
                          "strftime('%d.%m.%Y %H:%M:%S', LastSeen, 'unixepoch') as LastSeen, ",         \
                          "(select count(1) from posts p where p.userid = u.id ) as totalposts, ",      \
                          "(select status & 1 <> 0) as canlogin, ",                                     \
                          "(select status & 4 <> 0) as canpost, ",                                      \
                          "(select status & 8 <> 0) as canstart, ",                                     \
                          "(select status & 16 <> 0) as caneditown, ",                                  \
                          "(select status & 32 <> 0) as caneditall, ",                                  \
                          "(select status & 64 <> 0) as candelown, ",                                   \
                          "(select status & 128 <> 0) as candelall, ",                                  \
                          "(select status & 0x80000000 <> 0) as isadmin ",                              \
                        "from users u ",                                                                \
                        "where userid = ?"


sqlUpdateUserInfo text "update users set avatar = ?, user_desc = ? where id = ?"


proc ShowUserInfo, .userID, .pSpecial
.stmt dd ?
begin
        pushad

        stdcall StrNew
        mov     edi, eax
        mov     esi, [.pSpecial]

        cmp     [esi+TSpecialParams.post], 0
        jne     .save_user_info


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetFullUserInfo, sqlGetFullUserInfo.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.userID]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .missing_user


        stdcall StrCat, [esi+TSpecialParams.page_title], "Profile for: "
        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrCat, [esi+TSpecialParams.page_title], eax


        stdcall StrCat, edi, '<div class="user_profile">'

        stdcall StrCatTemplate, edi, "userinfo", [.stmt], esi

        test    [esi+TSpecialParams.userStatus], permAdmin
        jnz     .put_edit_form

        mov     eax, [esi+TSpecialParams.userID]
        cmp     eax, [.userID]
        jne     .edit_form_ok

.put_edit_form:

        stdcall StrCatTemplate, edi, "form_editinfo", [.stmt], esi

.edit_form_ok:

        stdcall StrCat, edi, '</div>'
        clc

.finish:

        pushf
        cinvoke sqliteFinalize, [.stmt]
        popf

        mov     [esp+4*regEAX], edi
        popad
        return


.missing_user:
        stdcall AppendError, edi, "404 Not Found", [.pSpecial]
        stc
        jmp     .finish


.save_user_info:

locals
  .avatar       dd ?
  .user_desc    dd ?
endl

        test    [esi+TSpecialParams.userStatus], permAdmin
        jnz     .permissions_ok

        mov     eax, [esi+TSpecialParams.userID]
        cmp     eax, [.userID]
        jne     .permissions_fail

.permissions_ok:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateUserInfo, sqlUpdateUserInfo.length, eax, 0

        stdcall GetQueryItem, [esi+TSpecialParams.post], "avatar=", 0
        mov     [.avatar], eax
        test    eax, eax
        jz      .avatar_ok

        stdcall StrLen, [.avatar]
        cmp     eax, MAX_AVATAR_SIZE
        ja      .avatar_ok

        stdcall StrPtr, [.avatar]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

.avatar_ok:

        stdcall GetQueryItem, [esi+TSpecialParams.post], "user_desc=", 0
        mov     [.user_desc], eax
        test    eax, eax
        jz      .user_desc_ok

        stdcall StrByteUtf8, [.user_desc], MAX_USER_DESC
        stdcall StrTrim, [.user_desc], eax

        stdcall StrPtr, [.user_desc]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

.user_desc_ok:

        cinvoke sqliteBindInt, [.stmt], 3, [.userID]

        cinvoke sqliteStep, [.stmt]

.update_end:

        stdcall StrDupMem, "/userinfo/"
        mov     ebx, eax
        stdcall NumToStr, [.userID], ntsDec or ntsUnsigned
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

        stdcall StrMakeRedirect, edi, ebx
        stdcall StrDel, ebx

        stdcall StrDel, [.avatar]
        stdcall StrDel, [.user_desc]

        stc
        jmp     .finish

.permissions_fail:

        stdcall AppendError, edi, "403 Forbidden", [.pSpecial]
        stc
        jmp     .finish

endp