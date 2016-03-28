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

options.DebugWeb = 0

;HeapManager  equ ASM
;LinuxThreads equ native


include "%lib%/freshlib.asm"


uses sqlite3:"%TargetOS%/sqlite3.inc"

include "sqlite3.asm"   ; sqlite utility functions.
include "http.asm"
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
  ProcessID     dd ?
  ProcessStart  dd ?
endg


;rb 273

start:
        InitializeAll


        stdcall SetForcedTerminateHandler, OnForcedTerminate

        cinvoke sqliteConfig, SQLITE_CONFIG_SERIALIZED
        cinvoke sqliteInitialize

        stdcall OpenOrCreate, cDatabaseFilename, hMainDatabase, sqlCreateDB
        jc      .finish

        cinvoke sqliteBusyTimeout, [hMainDatabase], 5000
        cinvoke sqliteExec, [hMainDatabase], "PRAGMA journal_mode = WAL", 0, 0, 0
        cinvoke sqliteExec, [hMainDatabase], "PRAGMA foreign_keys = TRUE", 0, 0, 0
        cinvoke sqliteExec, [hMainDatabase], "PRAGMA synchronous = OFF", 0, 0, 0
        cinvoke sqliteExec, [hMainDatabase], "PRAGMA threads = 2", 0, 0, 0
        cinvoke sqliteExec, [hMainDatabase], "PRAGMA secure_delete = FALSE", 0, 0, 0

        cinvoke sqliteExec, [hMainDatabase], "insert into ProcessID(id) values (NULL)", 0, 0, 0

        cinvoke sqliteLastInsertRowID, [hMainDatabase]
        mov     [ProcessID], eax
        cinvoke sqliteExec, [hMainDatabase], "delete from ProcessID", 0, 0, 0

        stdcall GetTimestamp
        mov     [ProcessStart], eax

        stdcall LogEvent, "ScriptStart", logNULL, 0, 0


        stdcall Listen


; close the database

.terminate:

        stdcall GetTimestamp
        sub     eax, [ProcessStart]

        stdcall LogEvent, "ScriptEnd", logNULL, 0, eax

        cinvoke sqliteClose, [hMainDatabase]
        cinvoke sqliteShutdown

.finish:
        FinalizeAll
        stdcall TerminateAll, 0



proc OnForcedTerminate as procForcedTerminateHandler
begin
        jmp     start.terminate         ; the stack is not important here!
endp
