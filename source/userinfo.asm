MAX_AVATAR_SIZE = 50*1024
MAX_USER_DESC   = 10*1024
MAX_SKIN_NAME   = 256



sqlGetFullUserInfo text "select ",                                                                      \
                          "id as userid, ",                                                             \
                          "nick as username, ",                                                         \
                          "av_time as AVer, ",                                                          \
                          "status, ",                                                                   \
                          "user_desc, ",                                                                \
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
                        "where nick = ?"

sqlUpdateUserDesc   text "update users set user_desc = ? where nick = ?"


proc ShowUserInfo, .UserName, .pSpecial
.stmt dd ?
begin
        pushad

        xor     edi, edi
        cmp     [.UserName], edi
        je      .exit

        stdcall StrNew
        mov     edi, eax
        mov     esi, [.pSpecial]

        cmp     [esi+TSpecialParams.post_array], 0
        jne     .save_user_info

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetFullUserInfo, sqlGetFullUserInfo.length, eax, 0

        stdcall StrPtr, [.UserName]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .missing_user

        stdcall LogUserActivity, esi, uaUserProfile, [.UserName]

        stdcall StrCat, [esi+TSpecialParams.page_title], cUserProfileTitle
        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrCat, [esi+TSpecialParams.page_title], eax


        stdcall StrCat, edi, '<div class="user_profile">'

        stdcall StrCatTemplate, edi, "userinfo", [.stmt], esi

        test    [esi+TSpecialParams.userStatus], permAdmin
        jnz     .put_edit_form

        cinvoke sqliteColumnInt, [.stmt], 0

        cmp     eax, [esi+TSpecialParams.userID]
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

.exit:
        mov     [esp+4*regEAX], edi
        popad
        return


.missing_user:
        stdcall AppendError, edi, "404 Not Found", [.pSpecial]
        stc
        jmp     .finish


.save_user_info:

locals
  .user_desc    dd ?
endl

        and     [.user_desc], 0

        test    [esi+TSpecialParams.userStatus], permAdmin
        jnz     .permissions_ok

        stdcall StrCompCase, [.UserName], [esi+TSpecialParams.userName]
        jnc     .permissions_fail

.permissions_ok:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateUserDesc, sqlUpdateUserDesc.length, eax, 0

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "user_desc", 0
        mov     [.user_desc], eax
        test    eax, eax
        jz      .update_end

        stdcall StrByteUtf8, [.user_desc], MAX_USER_DESC
        stdcall StrTrim, [.user_desc], eax

        stdcall StrPtr, [.user_desc]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        stdcall StrPtr, [.UserName]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]

.update_end:

        stdcall StrDupMem, "/!userinfo/"
        stdcall StrCat, eax, [.UserName]
        push    eax

        stdcall StrMakeRedirect, edi, eax
        stdcall StrDel ; from the stack

        stdcall StrDel, [.user_desc]

        stc
        jmp     .finish

.permissions_fail:

        stdcall AppendError, edi, "403 Forbidden", [.pSpecial]
        stc
        jmp     .finish

endp






sqlGetUserAvatar    text "select avatar, av_time from Users where nick = ? and avatar is not null"

proc UserAvatar, .UserName, .pSpecial
.stmt      dd ?

.date      TDateTime

.timeRetLo dd ?
.timeRetHi dd ?

begin
        pushad

        xor     edi, edi
        mov     [.stmt], edi
        mov     [.timeRetLo], edi
        mov     [.timeRetHi], edi

        cmp     [.UserName], edi
        je      .exit

        stdcall StrNew
        mov     edi, eax
        mov     esi, [.pSpecial]

        stdcall ValueByName, [esi+TSpecialParams.params], "HTTP_IF_MODIFIED_SINCE"
        jc      .time_ok

        lea     edx, [.date]
        stdcall DecodeHTTPDate, eax, edx
        jc      .time_ok

        stdcall DateTimeToTime, edx

        mov     [.timeRetLo], eax
        mov     [.timeRetHi], edx

.time_ok:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUserAvatar, sqlGetUserAvatar.length, eax, 0

        stdcall StrPtr, [.UserName]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .default_avatar

        cinvoke sqliteColumnInt64, [.stmt], 1

        cmp     edx, [.timeRetHi]
        ja      .get_avatar
        jb      .not_changed

        cmp     eax, [.timeRetLo]
        ja      .get_avatar

.not_changed:

        stdcall StrCat, edi, <"Status: 304 Not Modified", 13, 10, 13, 10>
        stc
        jmp     .finish


.default_avatar:

        lea     eax, [.timeRetLo]
        stdcall GetFileIfNewer, "images/anon.png", [.timeRetLo], [.timeRetHi], eax
        jc      .error_read

        test    eax, eax
        jz      .not_changed

        mov     esi, eax
        mov     ebx, ecx

        call    .compose_answer

        stdcall FreeMem, esi
        stc
        jmp     .finish


.error_read:

        DebugMsg "Error reading default avatar."

        stdcall StrDel, edi
        xor     edi, edi
        clc
        jmp     .finish


.get_avatar:
        mov     [.timeRetHi], edx
        mov     [.timeRetLo], eax

        cinvoke sqliteColumnBytes, [.stmt], 0
        mov     ebx, eax
        cinvoke sqliteColumnBlob, [.stmt], 0
        mov     esi, eax

.return_avatar:

        call    .compose_answer
        stc

.finish:
        pushf
        cinvoke sqliteFinalize, [.stmt]
        popf

.exit:
        mov     [esp+4*regEAX], edi
        popad
        return


.compose_answer:
        stdcall StrCat, edi, <"Cache-control: max-age=1000000">

        stdcall FormatHTTPTime, [.timeRetLo], [.timeRetHi]
        stdcall StrCat, edi, <13, 10, "Last-modified: ">
        stdcall StrCat, edi, eax
        stdcall StrDel, eax

        stdcall StrCat, edi, <13, 10, "Content-type: image/png", 13, 10, 13, 10>

        stdcall StrCatMem, edi, esi, ebx
        retn

endp





sqlUpdateUserAvatar text "update Users set avatar = ?, av_time = strftime('%s','now') where nick = ?"


proc UpdateUserAvatar, .UserName, .pSpecial
.stmt      dd ?
.img_ptr   dd ?    ; pointer to TByteStream

begin
        pushad

        xor     edi, edi
        mov     [.stmt], edi
        mov     [.img_ptr], edi
        mov     esi, [.pSpecial]

        cmp     [.UserName], edi
        je      .exit

        cmp     [esi+TSpecialParams.post_array], edi
        je      .exit

        stdcall StrNew
        mov     edi, eax

        test    [esi+TSpecialParams.userStatus], permAdmin
        jnz     .permissions_ok

        stdcall StrCompCase, [.UserName], [esi+TSpecialParams.userName]
        jnc     .permissions_fail

.permissions_ok:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateUserAvatar, sqlUpdateUserAvatar.length, eax, 0

        stdcall ValueByName, [esi+TSpecialParams.post_array], txt "avatar"
        jc      .update_end

        test    eax, eax
        jz      .update_end

        cmp     eax, $c0000000
        jae     .update_end              ; because of some reason, the avatar is posted as a string.

        cmp     [eax+TArray.count], 1
        jne     .update_end              ; multiple images has been posted.

        lea     ebx, [eax+TArray.array]

        stdcall StrCompCase, [ebx+TPostFileItem.mime], "image/png"
        jnc     .update_end

; First check the forum limits:

        stdcall GetParam, "avatar_max_size", gpInteger
        jnc     @f
        mov     eax, MAX_AVATAR_SIZE
@@:
        cmp     [ebx+TPostFileItem.size], eax
        ja      .update_end


        stdcall GetParam, "avatar_width", gpInteger
        jnc     @f
        mov     eax, 128
@@:
        mov     ecx, eax

        stdcall GetParam, "avatar_height", gpInteger
        jnc     @f
        mov     eax, 128
@@:

        stdcall SanitizeImagePng, [ebx+TPostFileItem.data], [ebx+TPostFileItem.size], ecx, eax
        jc      .update_end

        mov     [.img_ptr], eax

        lea     ecx, [eax+TByteStream.data]
        cinvoke sqliteBindBlob, [.stmt], 1, ecx, [eax+TByteStream.size], SQLITE_STATIC

        stdcall StrPtr, [.UserName]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]


.update_end:
        stdcall StrDupMem, "/!userinfo/"
        stdcall StrCat, eax, [.UserName]
        push    eax

        stdcall StrMakeRedirect, edi, eax
        stdcall StrDel ; from the stack

        stdcall FreeMem, [.img_ptr]
        jmp     .finish


.permissions_fail:

        stdcall AppendError, edi, "403 Forbidden", [.pSpecial]

        jmp     .finish


.finish:
        cinvoke sqliteFinalize, [.stmt]
        stc

.exit:
        mov     [esp+4*regEAX], edi
        popad
        return


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


endp



sqlUpdateUserSkin text "update Users set skin = ? where nick = ?"


proc UpdateUserSkin, .UserName, .pSpecial
  .stmt      dd ?
  .skin_name dd ?
begin
        pushad

        xor     edi, edi
        mov     esi, [.pSpecial]

        cmp     [.UserName], edi
        je      .exit

        cmp     [esi+TSpecialParams.post_array], edi
        je      .exit

        stdcall StrNew
        mov     edi, eax

        test    [esi+TSpecialParams.userStatus], permAdmin
        jnz     .permissions_ok

        stdcall StrCompCase, [.UserName], [esi+TSpecialParams.userName]
        jnc     .permissions_fail

.permissions_ok:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateUserSkin, sqlUpdateUserSkin.length, eax, 0

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "skin", 0
        mov     ebx, eax
        test    eax, eax
        jz      .update_end

        stdcall StrByteUtf8, ebx, MAX_SKIN_NAME
        stdcall StrTrim, ebx, eax

        stdcall StrPtr, ebx
        cmp     byte [eax], "0"
        jne     .bind_skin
        cmp     [eax+string.len], 1
        jne     .bind_skin

        cinvoke sqliteBindNull, [.stmt], 1              ; default skin!
        jmp     .bind_user

.bind_skin:
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

.bind_user:
        stdcall StrPtr, [.UserName]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        stdcall StrDel, ebx

.update_end:
        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDupMem, "/!userinfo/"
        stdcall StrCat, eax, [.UserName]
        push    eax

        stdcall StrMakeRedirect, edi, eax
        stdcall StrDel ; from the stack

        jmp     .finish

.permissions_fail:

        stdcall AppendError, edi, "403 Forbidden", [.pSpecial]

.finish:
        stc

.exit:
        mov     [esp+4*regEAX], edi
        popad
        return
endp