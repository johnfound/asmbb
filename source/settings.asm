
sqlParameters StripText 'settings.sql', SQL

proc BoardSettings, .pSpecial

.stmt    dd ?
.message dd ?
.error   dd ?
.ticket  dd ?

begin
        pushad

        and     [.message], 0
        and     [.ticket], 0
        and     [.error], 0

        mov     esi, [.pSpecial]

        test    [esi+TSpecialParams.userStatus], permAdmin
        jz      .for_admins_only

        stdcall LogUserActivity, esi, uaAdminThings, 0

        cmp     [esi+TSpecialParams.post_array], 0
        jne     .save_settings

        stdcall StrCat, [esi+TSpecialParams.page_title], cForumSettingsTitle

        stdcall SetUniqueTicket, [esi+TSpecialParams.session]
        jc      .for_admins_only

        mov     [.ticket], eax

        stdcall ValueByName, [esi+TSpecialParams.params], "QUERY_STRING"
        mov     ebx, eax

        stdcall GetQueryItem, ebx, txt "err=", 0
        test    eax, eax
        jz      .error_ok

        inc     [.error]
        stdcall StrDel, eax

.error_ok:
        stdcall GetQueryItem, ebx, txt "msg=", 0
        test    eax, eax
        jz      .show_settings_form

        mov     [.message], eax

.show_settings_form:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlParameters, sqlParameters.length, eax, 0

        stdcall StrPtr, [.ticket]
        cinvoke sqliteBindText, [.stmt], 28, eax, [eax+string.len], SQLITE_STATIC

        stdcall GetParam, txt "host", gpString
        jc      .host_ok

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

.host_ok:

        stdcall GetParam, txt "smtp_addr", gpString
        jc      .smtp_addr_ok

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

.smtp_addr_ok:

        stdcall GetParam, txt "smtp_port", gpInteger
        jnc     .smtp_port_ok

        mov     eax, 25

.smtp_port_ok:

        cinvoke sqliteBindInt, [.stmt], 3, eax

        stdcall GetParam, txt "smtp_user", gpString
        jc      .email_ok

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

.email_ok:

        stdcall GetParam, txt "forum_title", gpString
        jc      .title_ok

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 5, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

.title_ok:

        stdcall GetParam, txt "forum_header", gpString
        jc      .header_ok

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 26, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

.header_ok:

        stdcall GetParam, txt "description", gpString
        jc      .description_ok

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 19, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

.description_ok:

        stdcall GetParam, txt "keywords", gpString
        jc      .keywords_ok

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 20, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

.keywords_ok:

        cmp     [.message], 0
        je      .message_ok

        stdcall StrPtr, [.message]
        cinvoke sqliteBindText, [.stmt], 7, eax, [eax+string.len], SQLITE_STATIC

.message_ok:

        cinvoke sqliteBindInt, [.stmt], 8, [.error]


        stdcall GetParam, "page_length", gpInteger
        jnc     .page_size_ok

        mov     eax, DEFAULT_PAGE_LENGTH

.page_size_ok:
        cinvoke sqliteBindInt, [.stmt], 9, eax

; Default users permissions:

        xor     eax, eax
        stdcall GetParam, "user_perm", gpInteger
        stdcall BindSQLBits, [.stmt], eax, 200, txt 'checked'

; Default guests permissions:

        xor     eax, eax
        stdcall GetParam, "anon_perm", gpInteger
        stdcall BindSQLBits, [.stmt], eax, 300, txt 'checked'

; Chat settings:

        stdcall GetParam, txt "chat_enabled", gpInteger
        jc      .chat_enabled_ok
        test    eax, eax
        jz      .chat_enabled_ok

        cinvoke sqliteBindText, [.stmt], 21, "checked", -1, SQLITE_STATIC

.chat_enabled_ok:

        stdcall GetParam, txt "email_confirm", gpInteger
        jc      .email_confirm_ok
        test    eax, eax
        jz      .email_confirm_ok

        cinvoke sqliteBindText, [.stmt], 23, "checked", -1, SQLITE_STATIC

.email_confirm_ok:

        stdcall GetParam, txt "embeded_css", gpInteger
        jc      .embeded_css_ok
        test    eax, eax
        jz      .embeded_css_ok

        cinvoke sqliteBindText, [.stmt], 27, "checked", -1, SQLITE_STATIC

.embeded_css_ok:

        stdcall GetParam, txt "default_skin", gpString
        jc      .skin_ok

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 24, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

.skin_ok:

        stdcall GetParam, txt "default_mobile_skin", gpString
        jc      .mob_skin_ok

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 25, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

.mob_skin_ok:

        cinvoke sqliteStep, [.stmt]

        stdcall RenderTemplate, 0, "form_settings.tpl", [.stmt], esi
        mov     [esp+4*regEAX], eax

        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDel, [.message]
        stdcall StrDel, [.ticket]

        clc
        popad
        return


;.............................................................................................................

.save_settings:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "ticket", 0
        test    eax, eax
        jz      .for_admins_only

        mov     ebx, eax
        stdcall CheckTicket, ebx, [esi+TSpecialParams.session]
        pushf
        stdcall ClearTicket3, ebx
        stdcall StrDel, ebx
        popf
        jc      .for_admins_only

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlBegin, sqlBegin.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_transaction

        cinvoke sqliteFinalize, [.stmt]

; save host

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "host", 0
        stdcall SetParamStr, txt "host", eax
        jc      .error_write

 ;.save_smtp_addr:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "smtp_addr", 0
        stdcall SetParamStr, txt "smtp_addr", eax
        jc      .error_write

;.save_smtp_port:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "smtp_port", 0
        stdcall SetParamInt, txt "smtp_port", eax
        jnc     .save_smtp_user

        test    eax, eax
        jz      .error_invalid_number
        jmp     .error_write


.save_smtp_user:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "smtp_user", 0
        stdcall SetParamStr, txt "smtp_user", eax
        jc      .error_write

;.save_default_skin:
        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "default_skin", 0
        stdcall SetParamStr, txt "default_skin", eax
        jc      .error_write

;.save_default_mobile_skin:
        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "default_mobile_skin", 0
        stdcall SetParamStr, txt "default_mobile_skin", eax
        jc      .error_write

;.save_forum_title:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "forum_title", 0
        stdcall SetParamStr, txt "forum_title", eax
        jc      .error_write

;.save_forum_header:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "forum_header", 0
        stdcall SetParamStr, txt "forum_header", eax
        jc      .error_write

;.save_description:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "description", 0
        stdcall SetParamStr, txt "description", eax
        jc      .error_write

;.save_keywords:

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "keywords", 0
        stdcall SetParamStr, txt "keywords", eax
        jc      .error_write

;.save_emile_confirm:

        xor     ebx, ebx

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "email_confirm", 0
        test    eax, eax
        jz      .save_email_confirm

        inc     ebx
        stdcall StrDel, eax

.save_email_confirm:

        stdcall SetParamInt, txt "email_confirm", ebx
        jc      .error_write

; save_embeded_css

        xor     ebx, ebx

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "embeded_css", 0
        test    eax, eax
        jz      .embeded_ok

        inc     ebx
        stdcall StrDel, eax

.embeded_ok:

        stdcall SetParamInt, txt "embeded_css", ebx
        jc      .error_write

; save chat enabled

        xor     ebx, ebx

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "chat_enabled", 0
        test    eax, eax
        jz      .save_chat_enabled

        inc     ebx
        stdcall StrDel, eax

.save_chat_enabled:
        stdcall SetParamInt, txt "chat_enabled", ebx
        jc      .error_write

; save page_length

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt "page_length", 0
        stdcall SetParamInt, txt "page_length", eax
        jnc     .save_perm

        test    eax, eax
        jz      .error_invalid_page_len
        jmp     .error_write

.save_perm:

        stdcall GetPostPermissions, 'user_perm', esi
        jc      .error_invalid_permissions

        stdcall SetParamInt, txt "user_perm", eax
        jc      .error_write

        stdcall GetPostPermissions, 'anon_perm', esi
        jc      .error_invalid_permissions

        and     eax, permLogin or permRead or permChat or permDownload

        stdcall SetParamInt, txt "anon_perm", eax
        jc      .error_write

; everything is OK

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCommit, sqlCommit.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_commit

        stdcall StrDupMem, "The settings have been saved"

.end_save:
        mov     ebx, eax

        stdcall StrDupMem, "/!settings?msg="
        push    eax

        stdcall StrCat, eax, ebx
        stdcall StrDel, ebx

        cmp     [.error], 0
        je      .errok
        stdcall StrCat, eax, "&err=1"
.errok:
        stdcall TextMakeRedirect, 0, eax
        stdcall StrDel ; from the stack

.exit:
        mov     [esp+4*regEAX], edi
        stc
        popad
        return


.for_admins_only:

        stdcall TextMakeRedirect, 0, "/!message/only_for_admins"
        jmp     .exit


.error_invalid_number:

        stdcall StrDupMem, "Error: Invalid number as SMTP port."
        jmp     .error_write


.error_invalid_page_len:

        stdcall StrDupMem, "Error: Invalid number as page length."
        jmp     .error_write

.error_invalid_permissions:

        stdcall StrDupMem, "Error: Missing or invalid permissions parameters."
        jmp     .error_write

.error_transaction:
.error_commit:

        cinvoke sqliteErrMsg, [hMainDatabase]
        push    eax

        stdcall StrDupMem, 'The save failed with the following message: "'
        stdcall StrCat, eax ; second from the stack
        stdcall StrCat, eax, txt '"'


.error_write:
        push    eax

        cinvoke sqliteExec, [hMainDatabase], sqlRollback, 0, 0, 0

        inc     [.error]

        pop     eax
        jmp     .end_save

endp


sqlUpdateParams text "insert or replace into Params values (?, ?)"
sqlDeleteParams text "delete from Params where id = ?"

proc SetParamStr, .ParamName, .hParamValue
.stmt dd ?
begin
        pushad

        mov     ebx, [.hParamValue]
        test    ebx, ebx
        jnz     .update_it

.del_param:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDeleteParams, sqlDeleteParams.length, eax, 0
        jmp     .bind_name

.update_it:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateParams, sqlUpdateParams.length, eax, 0

        stdcall StrPtr, [.hParamValue]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel, [.hParamValue]

.bind_name:
        cinvoke sqliteBindText, [.stmt], 1, [.ParamName], -1, SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .error_get_msg

        clc
        popad
        return

.error_get_msg:

        cinvoke sqliteErrMsg, [hMainDatabase]
        push    eax

        stdcall StrDupMem, 'The save failed with the following message: "'
        stdcall StrCat, eax ; second from the stack
        stdcall StrCat, eax, txt '"'

.finish_error:
        mov     [esp+4*regEAX], eax
        stc
        popad
        return
endp





proc SetParamInt, .ParamName, .hParamValue
.stmt dd ?
begin
        pushad

        mov     ebx, [.hParamValue]
        test    ebx, $c0000000
        jz      .number

        stdcall StrToNumEx, ebx
        stdcall StrDel, ebx
        jc      .error_invalid_number
        mov     ebx, eax

.number:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateParams, sqlUpdateParams.length, eax, 0
        cinvoke sqliteBindInt,  [.stmt], 2, ebx
        jmp     SetParamStr.bind_name

.error_invalid_number:
        xor     eax, eax
        jmp     SetParamStr.finish_error
endp







sqlCreateAdmin   text  "insert into Users ( nick, passHash, salt, status, email ) values ( ?, ?, ?, -1, ?)"
sqlMessage       text  "select ? as message, ? as error"

proc CreateAdminAccount, .pSpecial
.stmt    dd ?

.message dd ?
.error   dd ?
begin
        pushad

        mov     esi, [.pSpecial]

        mov     ebx, [esi+TSpecialParams.post_array]
        test    ebx, ebx
        jnz     .create_account


; show the admin creation dialog.

        stdcall StrCat, [esi+TSpecialParams.page_title], cCreateAdminTitle

        stdcall ValueByName, [esi+TSpecialParams.params], "QUERY_STRING"
        mov     ebx, eax

        and     [.error], 0

        stdcall GetQueryItem, ebx, txt "err=", 0
        test    eax, eax
        jz      .error_ok

        inc     [.error]
        stdcall StrDel, eax

.error_ok:
        stdcall GetQueryItem, ebx, txt "msg=", 0
        mov     [.message], eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlMessage, sqlMessage.length, eax, 0

        cmp     [.message], 0
        je      .message_bnd

        stdcall StrPtr, [.message]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

.message_bnd:

        cinvoke sqliteBindInt, [.stmt], 2, [.error]
        cinvoke sqliteStep, [.stmt]

        stdcall RenderTemplate, 0, "form_setup.tpl", [.stmt], esi
        mov     [esp+4*regEAX], eax

        cinvoke sqliteFinalize, [.stmt]
        stdcall StrDel, [.message]

        clc
        popad
        return


.create_account:
        stdcall StrDupMem, "/?err=1&msg="
        mov     [.message], eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare, [hMainDatabase], sqlCreateAdmin, sqlCreateAdmin.length, eax, 0

        stdcall GetPostString, ebx, "admin", 0
        test    eax, eax
        jz      .error_no_data

        mov     edi, eax

        stdcall StrLen, eax
        test    eax, eax
        jz      .error_del_edi

        stdcall StrPtr, edi
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel, edi

        stdcall GetPostString, ebx, "password", 0
        test    eax, eax
        jz      .error_no_data

        mov     edi, eax

        stdcall StrLen, edi
        test    eax, eax
        jz      .error_del_edi


        stdcall GetPostString, ebx, "password2", 0
        test    eax, eax
        jz      .error_wrong_password

        stdcall StrCompCase, edi, eax
        jnc     .error_diff_pass

        stdcall StrDel, eax

        stdcall HashPassword, edi
        stdcall StrDel, edi

        push    eax
        push    edx
        push    edx

        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_TRANSIENT

        stdcall StrPtr ; from the stack
        cinvoke sqliteBindText, [.stmt], 3, eax, [eax+string.len], SQLITE_TRANSIENT

        stdcall StrDel ; from the stack
        stdcall StrDel ; from the stack

        stdcall GetPostString, ebx, txt "email", 0
        test    eax, eax
        jz      .error_no_data

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_sql

        cinvoke sqliteFinalize, [.stmt]
        stdcall TextMakeRedirect, 0, "/!login"

.finish:
        mov     [esp+4*regEAX], edi
        stdcall StrDel, [.message]

        stc
        popad
        return

; .........................................

.error_diff_pass:

        stdcall StrURLEncode, "Error: Passwords different!"
        stdcall StrCat, [.message], eax
        stdcall StrDel, eax
        jmp     .error_del_eax

.error_sql:
        mov     ecx, eax
        stdcall StrURLEncode, "Error: SQL return code "
        mov     edx, eax

        stdcall NumToStr, ecx, ntsDec
        stdcall StrCat, edx, eax
        stdcall StrDel, eax
        stdcall StrCat, [.message], edx
        stdcall StrDel, edx
        jmp     .error_finalize



.error_no_data:
        stdcall StrURLEncode, "Error: POST data invalid!"
        stdcall StrCat, [.message], eax
        stdcall StrDel, eax
        jmp     .error_finalize


.error_wrong_password:
        stdcall StrURLEncode, "Error: Passwords different!"
        stdcall StrCat, [.message], eax
        stdcall StrDel, eax
        jmp     .error_del_edi

.error_del_eax:

        stdcall StrDel, eax

.error_del_edi:

        stdcall StrDel, edi

.error_finalize:

        cinvoke sqliteFinalize, [.stmt]

        stdcall TextMakeRedirect, 0, [.message]
        jmp     .finish

endp




; Retrives from the POST data the user permissions encoded in the POST group .hGroupName
; Notice, that the checkboxes in the group should have numeric values, according to the
; permXXXX values, defined in 'commands.asm' file!

proc GetPostPermissions, .hGroupName, .pSpecial
begin
        pushad
        mov     esi, [.pSpecial]

        xor     ebx, ebx
        mov     edx, [esi+TSpecialParams.post_array]
        test    edx, edx
        jz      .error

        mov     ecx, [edx+TArray.count]

.loop:
        dec     ecx
        js      .end_collect_perm

        stdcall StrCompNoCase, [edx+TArray.array + 8*ecx], [.hGroupName]
        jnc     .loop

        mov     eax, [edx+TArray.array + 8*ecx + 4]
        cmp     eax, $c0000000
        jb      .error                   ; not a string!

        stdcall StrToNumEx, eax
        jc      .error                   ; not a number!

        or      ebx, eax                ; permissions mask
        jmp     .loop

.end_collect_perm:
        clc

.finish:
        mov     [esp+4*regEAX], ebx
        popad
        return

.error:
        xor     ebx, ebx
        stc
        jmp     .finish
endp


; binds a bit-field parameters group to the SQLite statement, according to the bits
; of the [.bitmask] argument.

proc BindSQLBits, .stmt, .bitmask, .bindOffset, .pBindConst
begin
        pushad
        mov     ebx, [.bitmask]
        mov     edi, [.bindOffset]
        mov     esi, 32

.bit_loop:
        shr     ebx, 1
        jnc     .next_bit

        cinvoke sqliteBindText, [.stmt], edi, [.pBindConst], -1, SQLITE_STATIC

.next_bit:
        inc     edi
        dec     esi
        jnz     .bit_loop

        popad
        return
endp