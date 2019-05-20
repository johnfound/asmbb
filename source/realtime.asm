

cTrue text 'true'
cFalse text 'false'

proc AddActivity, .hHTML, .userID
begin
        push    eax ebx

        stdcall StrDupMem, '{ "activity": "'
        mov     ebx, eax

        stdcall StrURLEncode, [.hHTML]
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCat, ebx, txt '", "robot": '
        mov     eax, cTrue
        cmp     [.userID], 0
        je      @f
        mov     eax, cFalse
@@:
        stdcall StrCat, ebx, eax
        stdcall StrCat, ebx, txt ' }'

        stdcall AddEvent, evUserActivity, ebx, 0
        stdcall StrDel, ebx

        pop     ebx eax
        return
endp




proc UserNameLink, .pSpecial
begin
        pushad

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
        popad
        return
endp