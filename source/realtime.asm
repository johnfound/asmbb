

proc EventsRealTime, .pSpecial
begin
        pushad

        mov     esi, [.pSpecial]
        xor     ebx, ebx
        xor     edi, edi

        stdcall GetQueryParam, esi, txt 'events='
        jc      .error_400

        push    eax
        stdcall StrToNumEx, eax
        stdcall StrDel ; from the stack
        jc      .error_400

        or      edi, eax
        and     edi, evmAllEventsLo
        and     ebx, evmAllEventsHi

        test    ebx, evmUsersOnline or evmUserChanged or evmMessage
        jz      .permissions_ok

        stdcall ChatPermissions, esi
        jc      .error_no_permissions

.permissions_ok:
        stdcall InitEventSession, esi, edi, ebx
        jc      .exit

        test    edi, evmMessage
        jz      .message_log_ok

        stdcall SendMessageLog, eax  ; eax is the events session.

.message_log_ok:

        test    edi, evmUsersOnline
        jz      .users_ok

        stdcall SendUsersOnline, eax

.users_ok:

        stdcall StrDel, eax

.exit:
        popad
        xor     eax, eax
        stc                      ; all communications here are finished: CF=1 and EAX=0.
        return

.error_no_permissions:

        stdcall TextCreate, sizeof.TText
        stdcall AppendError, eax, "403 Forbidden", esi

.send_error:
        stdcall FCGI_outputText, [esi+TSpecialParams.hSocket], [esi+TSpecialParams.requestID], edx, TRUE
        stdcall TextFree, edx
        jmp     .exit

.error_400:
        stdcall TextCreate, sizeof.TText
        stdcall AppendError, eax, "400 Invalid events mask", esi
        jmp     .exit

endp



proc AddActivitySimple, .i18nString, .pSpecial
begin
        pushad

        mov     esi, [.pSpecial]
        mov     edi, [.i18nString]

        mov     eax, DEFAULT_UI_LANG
        stdcall GetParam, "default_lang", gpInteger
        lea     edi, [edi+8*eax]

        stdcall UserNameLink, esi
        stdcall StrCat, eax, [edi]
        stdcall AddActivity, eax, edx
        stdcall StrDel, eax

        popad
        return
endp



cTrue text 'true'
cFalse text 'false'

proc AddActivity, .hHTML, .fBot
begin
        push    eax ebx

        stdcall StrDupMem, '{ "activity": "'
        mov     ebx, eax

        stdcall StrURLEncode, [.hHTML]
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCat, ebx, txt '", "robot": '
        mov     eax, cTrue
        cmp     [.fBot], 0
        jne     @f
        mov     eax, cFalse
@@:
        stdcall StrCat, ebx, eax
        stdcall StrCat, ebx, txt ' }'

        stdcall AddEvent, evUserActivity, ebx, 0
        stdcall StrDel, ebx

        pop     ebx eax
        return
endp


; returns EAX - html with a link to the user
; profile, or simply the "RobotXX" or "GuestXX"
; depending on the IsBot procedure guess.
; EDX: 0 if not robot. 1 if robot.

proc UserNameLink, .pSpecial
begin
        pushad

        xor     edi, edi

        mov     esi, [.pSpecial]
        cmp     [esi+TSpecialParams.userName], 0
        jne     .logged

        xor     eax, eax
        stdcall ValueByName, [esi+TSpecialParams.params], 'HTTP_USER_AGENT'
        jc      .bot

        stdcall IsBot, eax
        jc      .bot

        stdcall StrDupMem, '<span class="guest">Guest'
        jmp     .number

.bot:
        stdcall StrDupMem, '<span class="robot">Robot'
        inc     edi

.number:
        mov     ebx, eax
        mov     eax, [esi+TSpecialParams.remoteIP]
        movzx   edx, al
        xor     dl, ah
        shr     eax, 16
        xor     dl, al
        xor     dl, ah

        stdcall NumToStr, edx, ntsHex or ntsFixedWidth + 2
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCat, ebx, txt '</span>'
        jmp     .finish

.logged:
        stdcall StrDupMem, '<span class="user"><a href="/!userinfo/'
        mov     ebx, eax
        stdcall StrCat, ebx, [esi+TSpecialParams.userName]
        stdcall StrCat, ebx, txt '">'
        stdcall StrCat, ebx, [esi+TSpecialParams.userName]
        stdcall StrCat, ebx, txt '</a></span>'

.finish:
        mov     [esp+4*regEAX], ebx
        mov     [esp+4*regEDX], edi
        popad
        return
endp