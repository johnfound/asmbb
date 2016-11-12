; _______________________________________________________________________________________
;|                                                                                       |
;| ..:: Fresh IDE ::..  template project.                                                |
;|_______________________________________________________________________________________|
;
;  Description: FreshLib portable console application.
;
;  Target OS: Any, supported by FreshLib
;
;  Dependencies: FreshLib
;
;  Notes:
;_________________________________________________________________________________________

include "%lib%/freshlib.inc"

@BinaryType console, compact

include "%lib%/freshlib.asm"

; include your includes here.

start:
        InitializeAll

; place your code here.

        stdcall GetCmdArguments

        stdcall HashPassword, [eax+TArray.array+4]

        stdcall FileWriteString, [STDOUT], eax
        stdcall FileWriteString, [STDOUT], cCRLF
        stdcall FileWriteString, [STDOUT], edx
        stdcall FileWriteString, [STDOUT], cCRLF

        FinalizeAll
        stdcall TerminateAll, 0

cCRLF text 13, 10


proc HashPassword, .hPassword
begin
; First the salt:

        stdcall GetRandomString, 32
        jc      .finish

        mov     edx, eax
        stdcall StrDup, eax
        push    eax

        stdcall StrCat, eax, [.hPassword]
        stdcall StrMD5, eax
        stdcall StrDel  ; from the stack
        clc

.finish:
        return
endp
