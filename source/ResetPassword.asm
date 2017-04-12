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

start:
        InitializeAll

        stdcall GetCmdArguments

        xor     ecx, ecx
        cmp     [eax+TArray.count], 2
        jb      .show_help

        cmp     [eax+TArray.count], 3
        jb      .new_salt

        mov     ecx, [eax+TArray.array+8]

.new_salt:
        stdcall HashPassword, [eax+TArray.array+4], ecx

        push    eax
        stdcall FileWriteString, [STDOUT], "Hash: "
        stdcall FileWriteString, [STDOUT] ; from the stack
        stdcall FileWriteString, [STDOUT], cCRLF
        stdcall FileWriteString, [STDOUT], "Salt: "
        stdcall FileWriteString, [STDOUT], edx
        stdcall FileWriteString, [STDOUT], cCRLF

.finish:
        FinalizeAll
        stdcall TerminateAll, 0

cCRLF text 13, 10
CRLF equ 13, 10

.show_help:

        stdcall FileWriteString, [STDOUT], <"This program computes the hash of password for AsmBB,", CRLF, "using the given salt or generating a new salt string.", CRLF, CRLF, "Syntax:", CRLF, CRLF, "ResetPassword password [salt]", CRLF, CRLF>
        jmp     .finish


proc HashPassword, .hPassword, .hSalt
begin
; First the salt:

        mov     eax, [.hSalt]
        test    eax, eax
        jnz     .salt_ok

        stdcall GetRandomString, 32
        jc      .finish

.salt_ok:
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
