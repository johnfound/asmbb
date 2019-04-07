


proc RealTimeEvents, .pSpecial
begin
        pushad

        mov     esi, [.pSpecial]

        stdcall InitEventSession, esi, evmUserActivity, 0  ; if CF=0 returns session string in EAX
        jc      .exit

        stdcall StrDel, eax

.exit:
        popad
        xor     eax, eax
        stc                      ; all communications here are finished: CF=1 and EAX=0.
        return
endp
