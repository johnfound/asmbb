

sqlParameters   text "select ? as host, ? as smtp_addr, ? as smtp_port, ? as smtp_user, ? as file_cache, ? as log_events"


proc BoardSettings, .pSpecial

.stmt dd ?

begin
        pushad

        mov     esi, [.pSpecial]

        stdcall StrNew
        mov     edi, eax

        cmp     [esi+TSpecialParams.post], 0
        jne     .save_settings

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

        stdcall GetParam, txt "email", gpString
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

        cinvoke sqliteStep, [.stmt]

        stdcall StrCatTemplate, edi, "form_settings", [.stmt], esi

        cinvoke sqliteFinalize, [.stmt]
        clc

.finish:
        mov     [esp+4*regEAX], edi
        popad
        return



.save_settings:

        stc
        jmp     .finish
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