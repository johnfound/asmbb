; _______________________________________________________________________________________
;|                                                                                       |
;| ..:: Fresh IDE ::..  template project.                                                |
;|_______________________________________________________________________________________|
;
;  Description: AsmBoard is assembly written message board engine working over FastCGI
;
;  Target OS: Any, supported by FreshLib
;
;  Dependencies: FreshLib
;
;  Notes:
;_________________________________________________________________________________________

include "%lib%/freshlib.inc"

LINUX_INTERPRETER equ './ld-musl-i386.so'   ;'./ld-linux.so.2'

@BinaryType console, compact

options.ShowSkipped = 0
options.ShowSizes = 1

options.DebugMode = 1
options.AlignCode = 0
options.ShowImported = 1

HeapManager  equ ASM


include "%lib%/freshlib.asm"

uses sqlite3:"sqlite3.inc"

include "sqlite3.asm"   ; sqlite utility functions.
include "get.asm"
include "commands.asm"
include "render.asm"


iglobal
  sqlCreateDB file 'create.sql'
              dd   0

  cDatabaseFilename text "board.sqlite"
endg

uglobal
  hMainDatabase dd ?

  StartTime     dd ?
endg


cmdListThreads = 0
cmdShowThread  = 1
cmdSavePost    = 2

cmdMax         = 2


start:
        stdcall GetTimestamp
        mov     [StartTime], eax

        InitializeAll

        stdcall InitScriptVariables

        mov     ebx, [Command]
        cmp     ebx, cmdMax
        ja      .err400

; command in range, so open the database.

        stdcall StrDup, [hDocRoot]
        push    eax
        stdcall StrCat, eax, cDatabaseFilename
        stdcall StrPtr, eax

        stdcall OpenOrCreate, eax, hMainDatabase, sqlCreateDB
        stdcall StrDel ; from the stack
        jc      .err400

; execute the command

        stdcall [procCommands+4*ebx]

; close the database

        cinvoke sqliteClose, [hMainDatabase]

.finish:
        FinalizeAll
        stdcall TerminateAll, 0


.err400:
        stdcall ReturnError, "400 Bad Request"
        jmp     .finish




procCommands dd ListThreads, ShowThread, SavePost



errorHeader  text '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>HTTP response</title><link rel="stylesheet" href="/error.css"></head><body>'
errorFooter  text '</body></html>'




proc ReturnError, .code
begin
        stdcall FileWriteString, [STDOUT], "Status: "
        stdcall FileWriteString, [STDOUT], [.code]
        stdcall FileWrite,       [STDOUT], <txt 13, 10>, 2
        stdcall FileWriteString, [STDOUT], <"Content-type: text/html", 13, 10, 13, 10>
        stdcall FileWrite,       [STDOUT], errorHeader, errorHeader.length
        stdcall FileWriteString, [STDOUT], txt "<h1>"


        stdcall FileWriteString, [STDOUT], [.code]

        stdcall FileWriteString, [STDOUT], "</h1><p>Time:"

        stdcall GetTimestamp
        sub     eax, [StartTime]

        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        stdcall FileWriteString, [STDOUT], eax
        stdcall FileWriteString, [STDOUT], " ms</p>"

        stdcall FileWrite,       [STDOUT], errorFooter, errorFooter.length
        return
endp