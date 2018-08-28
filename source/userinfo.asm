MAX_AVATAR_SIZE = 50*1024
MAX_USER_DESC   = 10*1024
MAX_SKIN_NAME   = 256


sqlGetFullUserInfo StripText "userinfo.sql", SQL
sqlUpdateUserDesc   text "update users set user_desc = ?1 where nick = ?2"


proc ShowUserInfo, .pSpecial
.stmt dd ?
.ticket dd ?
begin
        pushad

        mov     esi, [.pSpecial]

        xor     edi, edi
        mov     [.ticket],edi

        mov     edx, [esi+TSpecialParams.cmd_list]
        cmp     [edx+TArray.count], edi
        je      .exit

        mov     ebx, [edx+TArray.array]
        test    ebx, ebx
        jz      .exit

        cmp     [esi+TSpecialParams.post_array], edi
        jne     .save_user_info

        cmp     [esi+TSpecialParams.session], edi
        je      .ticket_ok

        cmp     [esi+TSpecialParams.userName], edi
        je      .ticket_ok

        test    [esi+TSpecialParams.userStatus], permAdmin
        jnz     .set_ticket

        stdcall StrCompCase, ebx, [esi+TSpecialParams.userName]
        jnc     .ticket_ok

.set_ticket:
        stdcall SetUniqueTicket, [esi+TSpecialParams.session]
        mov     [.ticket], eax

.ticket_ok:

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetFullUserInfo, sqlGetFullUserInfo.length, eax, 0

        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

        cmp     [.ticket], 0
        je      .ticket_ok2

        stdcall StrPtr, [.ticket]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

.ticket_ok2:

        cinvoke sqliteBindInt, [.stmt], 3, [esi+TSpecialParams.userID]

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .missing_user

        stdcall LogUserActivity, esi, uaUserProfile, ebx

        stdcall StrCat, [esi+TSpecialParams.page_title], cUserProfileTitle
        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrCat, [esi+TSpecialParams.page_title], eax

        stdcall TextCat, edi, txt '<div class="user_profile">'
        stdcall RenderTemplate, edx, "userinfo.tpl", [.stmt], esi
        mov     edi, eax

        test    [esi+TSpecialParams.userStatus], permAdmin
        jnz     .put_edit_form

        cinvoke sqliteColumnInt, [.stmt], 0
        cmp     eax, [esi+TSpecialParams.userID]
        jne     .edit_form_ok

.put_edit_form:

        stdcall RenderTemplate, edi, "form_editinfo.tpl", [.stmt], esi
        mov     edi, eax

.edit_form_ok:
        cinvoke sqliteFinalize, [.stmt]
        stdcall TextCat, edi, txt '</div>'
        mov     edi, edx
        clc

.finish:
        stdcall StrDel, [.ticket]

.exit:
        mov     [esp+4*regEAX], edi
        popad
        return

.missing_user:
        cinvoke sqliteFinalize, [.stmt]
        stdcall AppendError, edi, "404 Not Found", [.pSpecial]
        mov     edi, edx
        stc
        jmp     .finish


.save_user_info:

locals
  .user_desc    dd ?
endl

        and     [.user_desc], 0

        test    [esi+TSpecialParams.userStatus], permAdmin
        jnz     .permissions_ok

        stdcall StrCompCase, ebx, [esi+TSpecialParams.userName]
        jnc     .permissions_fail

.permissions_ok:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "ticket", 0
        test    eax, eax
        jz      .permissions_fail

        mov     [.ticket], eax
        stdcall CheckTicket, eax, [esi+TSpecialParams.session]
        jc      .permissions_fail

        stdcall ClearTicket3, [.ticket]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateUserDesc, sqlUpdateUserDesc.length, eax, 0

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "user_desc", 0
        mov     [.user_desc], eax
        test    eax, eax
        jz      .text_ok

        stdcall StrByteUtf8, [.user_desc], MAX_USER_DESC
        stdcall StrTrim, [.user_desc], eax

        stdcall StrPtr, [.user_desc]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

.text_ok:
        stdcall StrPtr, ebx
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDupMem, "/!userinfo/"
        stdcall StrCat, eax, ebx

        stdcall TextMakeRedirect, 0, eax
        stdcall StrDel, eax

        stdcall StrDel, [.user_desc]

        stc
        jmp     .finish

.permissions_fail:
        stdcall TextCreate, sizeof.TText
        stdcall AppendError, eax, "403 Forbidden", [.pSpecial]
        mov     edi, edx
        stc
        jmp     .finish

endp






sqlGetUserAvatar    text "select avatar, av_time from Users where nick = ? and avatar is not null"

proc UserAvatar, .pSpecial
.stmt      dd ?

.date      TDateTime

.timeRetLo dd ?
.timeRetHi dd ?

begin
        pushad

        mov     esi, [.pSpecial]

        xor     edi, edi
        mov     [.stmt], edi
        mov     [.timeRetLo], edi
        mov     [.timeRetHi], edi

        mov     edx, [esi+TSpecialParams.cmd_list]
        mov     ebx, [edx+TArray.count]
        test    ebx, ebx
        jz      .exit

        mov     ebx, [edx+TArray.array]

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

        stdcall StrPtr, ebx
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

        stdcall TextCreate, sizeof.TText
        stdcall TextCat, eax, <"Status: 304 Not Modified", 13, 10, 13, 10>
        mov     edi, edx
        stc
        jmp     .finish


.default_avatar:

        stdcall StrDup, [hCurrentDir]
        stdcall StrCat, eax, [esi+TSpecialParams.userSkin]
        stdcall StrCat, eax, "/_images/anon.png"
        push    eax

        lea     ecx, [.timeRetLo]
        stdcall GetFileIfNewer, eax, [.timeRetLo], [.timeRetHi], ecx, mimePNG, 0
        stdcall StrDel ; from the stack
        jc      .error_read

        test    eax, eax
        jz      .not_changed

        mov     edi, eax
        call    .add_headers

        stc
        jmp     .finish


.error_read:

        DebugMsg "Error reading default avatar."

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

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        call    .add_headers
        stdcall TextMoveGap, edi, -1
        stdcall TextSetGapSize, edi, ebx

        mov     edi, [edx+TText.GapBegin]
        add     [edx+TText.GapBegin], ebx
        add     edi, edx

        mov     ecx, ebx
        and     ecx, 3
        rep movsb

        mov     ecx, ebx
        shr     ecx, 2
        rep movsd

        mov     edi, edx
        stc

.finish:
        pushf
        cinvoke sqliteFinalize, [.stmt]
        popf

.exit:
        mov     [esp+4*regEAX], edi
        popad
        return


.add_headers:
        stdcall TextAddStr2, edi, 0, <"Cache-control: max-age=1000000", 13, 10, "Last-modified: ">, 100
        stdcall FormatHTTPTime, [.timeRetLo], [.timeRetHi]
        push    eax
        stdcall TextAddStr2, edx, [edx+TText.GapBegin], eax, 100
        stdcall StrDel ; from the stack
        stdcall TextAddStr2, edx, [edx+TText.GapBegin], <txt 13, 10, "Content-type: image/png", 13, 10, 13, 10>, 100
        mov     edi, edx
        retn

endp





sqlUpdateUserAvatar text "update Users set avatar = ?, av_time = strftime('%s','now') where nick = ?"


proc UpdateUserAvatar, .pSpecial
.stmt      dd ?
.img_ptr   dd ?    ; pointer to TByteStream
.username  dd ?
begin
        pushad

        xor     edi, edi
        mov     [.stmt], edi
        mov     [.img_ptr], edi
        mov     esi, [.pSpecial]

        mov     edx, [esi+TSpecialParams.cmd_list]
        cmp     [edx+TArray.count], edi
        je      .exit
        mov     ebx, [edx+TArray.array]
        test    ebx, ebx
        jz      .exit

        mov     [.username], ebx

        cmp     [esi+TSpecialParams.post_array], edi
        je      .exit

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        test    [esi+TSpecialParams.userStatus], permAdmin
        jnz     .permissions_ok

        stdcall StrCompCase, [.username], [esi+TSpecialParams.userName]
        jnc     .permissions_fail

.permissions_ok:

        stdcall GetPostString, [esi+TSpecialParams.post_array], "ticket", 0
        test    eax, eax
        jz      .permissions_fail

        mov     ebx, eax

        stdcall CheckTicket, ebx, [esi+TSpecialParams.session]
        pushf
        stdcall ClearTicket3, ebx
        stdcall StrDel, ebx
        popf
        jc      .permissions_fail


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateUserAvatar, sqlUpdateUserAvatar.length, eax, 0

        stdcall ValueByName, [esi+TSpecialParams.post_array], txt "avatar"
        jc      .pic_ok

        test    eax, eax
        jz      .pic_ok

        cmp     eax, $c0000000
        jae     .pic_ok                   ; because of some reason, the avatar is posted as a string.

        cmp     [eax+TArray.count], 1
        jne     .pic_ok                   ; multiple images has been posted.

        lea     ebx, [eax+TArray.array]

        cmp     [ebx+TPostFileItem.size], 0
        jle     .pic_ok

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

.pic_ok:
        stdcall StrPtr, [.username]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]

.update_end:
        stdcall StrDupMem, "/!userinfo/"
        stdcall StrCat, eax, [.username]

        stdcall TextMakeRedirect, edi, eax
        stdcall StrDel, eax

        stdcall FreeMem, [.img_ptr]
        cinvoke sqliteFinalize, [.stmt]

.exit:
        mov     [esp+4*regEAX], edi
        stc
        popad
        return


.permissions_fail:
        stdcall AppendError, edi, "403 Forbidden", [.pSpecial]
        mov     edi, edx
        jmp     .exit

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


endp



sqlUpdateUserSkin text "update Users set skin = ? where nick = ?"


proc UpdateUserSkin, .pSpecial
  .stmt      dd ?
  .skin_name dd ?
  .username  dd ?
begin
        pushad

        xor     edi, edi
        mov     esi, [.pSpecial]

        mov     edx, [esi+TSpecialParams.cmd_list]
        cmp     [edx+TArray.count], edi
        je      .exit
        mov     ebx, [edx+TArray.array]
        test    ebx, ebx                        ; after text, CF=0!
        jz      .exit

        mov     [.username], ebx

        cmp     [esi+TSpecialParams.post_array], edi
        je      .exit

        test    [esi+TSpecialParams.userStatus], permAdmin
        jnz     .permissions_ok

        stdcall StrCompCase, [.username], [esi+TSpecialParams.userName]
        jnc     .permissions_fail

.permissions_ok:

        stdcall GetPostString, [esi+TSpecialParams.post_array], "ticket", 0
        test    eax, eax
        jz      .permissions_fail

        mov     ebx, eax
        stdcall CheckTicket, ebx, [esi+TSpecialParams.session]
        pushf
        stdcall ClearTicket3, ebx
        stdcall StrDel, ebx
        popf
        jc      .permissions_fail

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
        stdcall StrPtr, [.username]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]
        stdcall StrDel, ebx

.update_end:
        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDupMem, "/!userinfo/"
        stdcall StrCat, eax, [.username]
        push    eax

        stdcall TextMakeRedirect, 0, eax
        stdcall StrDel ; from the stack
        jmp     .finish

.permissions_fail:
        stdcall TextCreate, sizeof.TText
        stdcall AppendError, eax, "403 Forbidden", [.pSpecial]
        mov     edi, edx

.finish:
        stc

.exit:
        mov     [esp+4*regEAX], edi
        popad
        return
endp






proc SkinCookie, .pSpecial
begin
        pushad

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        mov     esi, [.pSpecial]
        cmp     [esi+TSpecialParams.post_array], 0
        jne     .get_post

        mov     eax, [esi+TSpecialParams.cmd_list]
        cmp     [eax+TArray.count], 0
        je      .set_default

        mov     ebx, [eax+TArray.array]
        test    ebx, ebx
        jz      .set_default
        jmp     .set_cookie

.get_post:
        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "skin", 0
        mov     ebx, eax
        test    eax, eax
        jz      .set_default

        stdcall StrCompNoCase, ebx, txt "0"
        jc      .default_free

; now, set session cookie.

.set_cookie:
        stdcall TextCat, edi, "Set-Cookie: skin="
        stdcall TextCat, edx, ebx
        stdcall TextCat, edx, "; HttpOnly; Path=/; "
        stdcall TextCat, edx, <txt 13, 10>
        mov     edi, edx

        stdcall StrDel, ebx
        jmp     .finish

.default_free:
        stdcall StrDel, ebx

.set_default:
; simply delete the cookie.
        stdcall TextCat, edi, <"Set-Cookie: skin=; HttpOnly; Path=/; Max-Age=0", 13, 10>
        mov     edi, edx

.finish:
        stdcall GetBackLink, esi
        stdcall TextMakeRedirect, edi, eax
        stdcall StrDel, eax
        mov     [esp+4*regEAX], edi
        stc
        popad
        return
endp