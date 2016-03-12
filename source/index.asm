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

LINUX_INTERPRETER equ './ld-musl-i386.so'

@BinaryType console, compact

options.ShowSkipped = 0
options.ShowSizes = 1

options.DebugMode = 0
options.AlignCode = 0
options.ShowImported = 1

;HeapManager  equ ASM
;LinuxThreads equ native


include "%lib%/freshlib.asm"

uses sqlite3:"sqlite3.inc"

include "sqlite3.asm"   ; sqlite utility functions.
include "get.asm"
include "commands.asm"
include "render.asm"
include "fcgi.asm"


iglobal
  sqlCreateDB file 'create.sql'
              dd   0

  cDatabaseFilename text "./board.sqlite"
endg

uglobal
  hMainDatabase dd ?
endg


rb 173

start:
        InitializeAll

        cinvoke sqliteConfig, SQLITE_CONFIG_SERIALIZED
        cinvoke sqliteInitialize

        stdcall OpenOrCreate, cDatabaseFilename, hMainDatabase, sqlCreateDB
        jc      .finish

        cinvoke sqliteExec, [hMainDatabase], "PRAGMA journal_mode = WAL", 0, 0, 0


        stdcall Listen

; close the database

        cinvoke sqliteClose, [hMainDatabase]
        cinvoke sqliteShutdown

.finish:
        FinalizeAll
        stdcall TerminateAll, 0



