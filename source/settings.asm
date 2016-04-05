

sqlParameters   text "select ? as host, ? as smtp_addr, ? as smtp_port, ? as smtp_user, ? as file_cache, ? as log_events, ? as message, ? as error"
sqlUpdateParams text "insert or replace into Params values (?, ?)"



proc BoardSettings, .pSpecial

.stmt    dd ?
.message dd ?
.error   dd ?

begin
        pushad

        and     [.message], 0
        and     [.error], 0

        mov     esi, [.pSpecial]

        cmp     [esi+TSpecialParams.post], 0
        je      .show_settings_form

        call    .save_settings
        mov     [.message], eax


.show_settings_form:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlParameters, sqlParameters.length, eax, 0

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
        stdcall GetParam, txt "file_cache", gpInteger
        jc      .file_cache_ok
        test    eax, eax
        jz      .file_cache_ok

        cinvoke sqliteBindText, [.stmt], 5, "checked", -1, SQLITE_STATIC

.file_cache_ok:

        stdcall GetParam, txt "log_events", gpInteger
        jc      .log_events_ok
        test    eax, eax
        jz      .log_events_ok

        cinvoke sqliteBindText, [.stmt], 6, "checked", -1, SQLITE_STATIC

.log_events_ok:

        cmp     [.message], 0
        je      .message_ok

        stdcall StrPtr, [.message]
        cinvoke sqliteBindText, [.stmt], 7, eax, [eax+string.len], SQLITE_STATIC

.message_ok:

        cinvoke sqliteBindInt, [.stmt], 8, [.error]


        cinvoke sqliteStep, [.stmt]

        stdcall StrNew
        mov     [esp+4*regEAX], eax

        stdcall StrCatTemplate, eax, "form_settings", [.stmt], esi

        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDelNull, [.message]

        popad
        return


;.............................................................................................................

.save_settings:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlBegin, sqlBegin.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_transaction

        cinvoke sqliteFinalize, [.stmt]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateParams, sqlUpdateParams.length, eax, 0

; save host

        stdcall GetQueryItem, [esi+TSpecialParams.post], txt "host=", 0
        test    eax, eax
        jz      .error_post_request

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_TRANSIENT
        cinvoke sqliteBindText, [.stmt], 1, txt "host", -1, SQLITE_STATIC
        stdcall StrDel ; from the stack.

        call    .exec_write
        jc      .error_write

; save smtp_addr

        stdcall GetQueryItem, [esi+TSpecialParams.post], txt "smtp_addr=", 0
        test    eax, eax
        jz      .error_post_request

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_TRANSIENT
        cinvoke sqliteBindText, [.stmt], 1, txt "smtp_addr", -1, SQLITE_STATIC
        stdcall StrDel ; from the stack.

        call    .exec_write
        jc      .error_write

; save smtp_port

        stdcall GetQueryItem, [esi+TSpecialParams.post], txt "smtp_port=", 0
        test    eax, eax
        jz      .error_post_request

        push    eax
        stdcall StrToNumEx, eax
        stdcall StrDel ; from the stack.
        jc      .error_invalid_number

        cinvoke sqliteBindInt,  [.stmt], 2, eax
        cinvoke sqliteBindText, [.stmt], 1, txt "smtp_port", -1, SQLITE_STATIC

        call    .exec_write
        jc      .error_write

; save smtp_user

        stdcall GetQueryItem, [esi+TSpecialParams.post], txt "smtp_user=", 0
        test    eax, eax
        jz      .error_post_request

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_TRANSIENT
        cinvoke sqliteBindText, [.stmt], 1, txt "smtp_user", -1, SQLITE_STATIC
        stdcall StrDel ; from the stack.

        call    .exec_write
        jc      .error_write


; save bool file_cache

        xor     ebx, ebx

        stdcall GetQueryItem, [esi+TSpecialParams.post], txt "file_cache=", 0
        test    eax, eax
        jz      .bind_cache

        inc     ebx
        stdcall StrDel, eax

.bind_cache:
        cinvoke sqliteBindInt,  [.stmt], 2, ebx
        cinvoke sqliteBindText, [.stmt], 1, txt "file_cache", -1, SQLITE_STATIC

        call    .exec_write
        jc      .error_write

; save bool log_events

        xor     ebx, ebx

        stdcall GetQueryItem, [esi+TSpecialParams.post], txt "log_events=", 0
        test    eax, eax
        jz      .bind_log

        inc     ebx
        stdcall StrDel, eax

.bind_log:
        cinvoke sqliteBindInt,  [.stmt], 2, ebx
        cinvoke sqliteBindText, [.stmt], 1, txt "log_events", -1, SQLITE_STATIC

        call    .exec_write
        jc      .error_write

; everything is OK

        cinvoke sqliteFinalize, [.stmt]


        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCommit, sqlCommit.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_commit

        cinvoke sqliteFinalize, [.stmt]

        stdcall StrDupMem, "The settings has been saved"

        retn



.error_post_request:

        stdcall StrDupMem, "Error: Strange, there is missing value in the POST request. Hack attempt? "
        jmp     .error_write

.error_invalid_number:

        stdcall StrDupMem, "Error: Invalid number as an SMTP port."
        jmp     .error_write


.error_transaction:
.error_commit:

        call    .error_get_msg

.error_write:
        push    eax

        cinvoke sqliteFinalize, [.stmt]

        cinvoke sqliteExec, [hMainDatabase], sqlRollback, 0, 0, 0

        inc     [.error]

        pop     eax
        retn




.exec_write:

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_get_msg

        cinvoke sqliteReset, [.stmt]
        cinvoke sqliteClearBindings, [.stmt]

        clc
        retn

.error_get_msg:

        cinvoke sqliteErrMsg, [hMainDatabase]
        push    eax

        stdcall StrDupMem, 'The save failed with the following message: "'
        stdcall StrCat, eax ; second from the stack
        stdcall StrCharCat, eax, '"'

        stc
        retn
endp








sqlCreateAdmin   text  "insert into Users ( nick, passHash, salt, status, email ) values ( ?, ?, ?, -1, ?)"


proc CreateAdminAccount, .pSpecial
.stmt dd ?
begin
        pushad

        mov     esi, [.pSpecial]
        mov     ebx, [esi+TSpecialParams.post]
        test    ebx, ebx
        jz      .error_no_post

        lea     eax, [.stmt]
        cinvoke sqlitePrepare, [hMainDatabase], sqlCreateAdmin, sqlCreateAdmin.length, eax, 0

        stdcall GetQueryItem, ebx, "admin=", 0
        test    eax, eax
        jz      .error_no_data

        mov     edi, eax

        stdcall StrLen, eax
        test    eax, eax
        jz      .error_del_edi

        stdcall StrPtr, edi
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel, edi

        stdcall GetQueryItem, ebx, "password=", 0
        test    eax, eax
        jz      .error_no_data

        mov     edi, eax

        stdcall StrLen, edi
        test    eax, eax
        jz      .error_del_edi


        stdcall GetQueryItem, ebx, "password2=", 0
        test    eax, eax
        jz      .error_del_edi

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

        stdcall GetQueryItem, ebx, "email=", 0
        test    eax, eax
        jz      .error_no_data

        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_DONE
        jne     .error_no_data

        cinvoke sqliteFinalize, [.stmt]
        stdcall StrMakeRedirect, 0, "/login"

.finish:
        mov     [esp+4*regEAX], eax
        popad
        return

; .........................................

.error_diff_pass:

        stdcall StrDel, eax

.error_del_edi:

        stdcall StrDel, edi

.error_no_data:

        cinvoke sqliteFinalize, [.stmt]

.error_no_post:
        stdcall StrMakeRedirect, 0, "/settings"
        jmp     .finish

endp