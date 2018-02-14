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

;LINUX_INTERPRETER equ './ld-musl-i386.so'

@BinaryType console, compact

options.DebugMode = 1

sqlitePrepare_v2 equ _sqlitePrepare_v2
sqliteFinalize equ _sqliteFinalize

include "%lib%/freshlib.asm"
include "../sqlite3.asm"
include "../render2.asm"
include "../commands.asm"

uses sqlite3:"../%TargetOS%/sqlite3.inc"


uglobal
  hMainDatabase dd ?

  Special TSpecialParams
endg

iglobal
  sqlCreateDB StripText '../create.sql', SQL
              dd   0
  sqlTest     StripText '../showthread.sql', SQL
  sqlGetThreadInfo text "select T.id, T.caption, T.slug, (select userID from Posts P where P.threadID=T.id order by P.id limit 1) as UserID from Threads T where T.slug = ?1 limit 1"
endg

  cDatabaseFilename text "./test.sqlite"

  cVersion text "VERSION: This is a test project for Render2!"

start:
        InitializeAll

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


; prepare the Special structure:

        stdcall GetFineTimestamp
        mov     [Special.start_time], eax

        mov     [Special.params], 0
        mov     [Special.post_array], 0
        mov     [Special.dir], 0

        stdcall StrDupMem, "learning-the-asmbb-source-64"
        mov     [Special.thread], eax

        mov     [Special.page_num], 0
        mov     [Special.cmd_type], 0   ; no command, show thread


        stdcall StrDupMem, "..::AsmBB::.. test"
        mov     [Special.page_title], eax

        stdcall StrDupMem, "Render2 demo"
        mov     [Special.page_header], eax

        stdcall StrDupMem, txt "Render2 demo pages."
        mov     [Special.description], eax

        stdcall StrDupMem, txt "asmbb, asm, assembly, assembler, assembly language, forum, message board, buletin board"
        mov     [Special.keywords], eax

        mov     [Special.page_length], 20
        mov     [Special.setupmode], 0          ; not setup mode!

        stdcall CreateArray, 4
        mov     [Special.pStyles], eax

        mov     [Special.userID], 1

        stdcall StrDupMem, "johnfound"
        mov     [Special.userName], eax

        mov     [Special.userStatus], 349
        mov     [Special.userLang], 0

        stdcall StrDupMem, "../../www/templates/Wasp/"
        mov     [Special.userSkin], eax

        stdcall TextCreate, sizeof.TText
        mov     esi, eax

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        stdcall TestRender, esi, edi
        mov     esi, eax
        mov     edi, edx

        cinvoke sqliteClose, [hMainDatabase]

        stdcall FileOpenAccess, './output.html', faCreateAlways or faWriteOnly
        mov     ebx, eax

        stdcall TextCompact, edi
        mov     ecx, eax
        mov     edi, edx

        stdcall FileWrite, ebx, edi, ecx

        stdcall TextCompact, esi
        mov     ecx, eax
        mov     esi, edx

        stdcall FileWrite, ebx, esi, ecx

        stdcall FileClose, ebx

        stdcall TextFree, esi
        stdcall TextFree, edi

.finish:
        FinalizeAll
        stdcall TerminateAll, 0



proc TestRender, .pTextPosts, .pTextBegin
.stmt          dd ?
.stmt2         dd ?
.start_time    dd ?
begin
        pushad
        mov     esi, [.pTextPosts]
        mov     edi, [.pTextBegin]

        lea     eax, [.stmt2]
        cinvoke _sqlitePrepare_v2, [hMainDatabase], sqlGetThreadInfo, sqlGetThreadInfo.length, eax, 0

        stdcall StrPtr, [Special.thread]
        cinvoke sqliteBindText, [.stmt2], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt2]

        stdcall GetFineTimestamp
        mov     [.start_time], eax

        stdcall RenderTemplate, esi, "../../www/templates/Wasp/nav_thread.tpl", [.stmt2], Special
        mov     esi, eax

        stdcall GetFineTimestamp
        sub     eax, [.start_time]
        OutputValue "Rendering time nav_thread [us]: ", eax, 10, -1


        lea     eax, [.stmt]
        cinvoke _sqlitePrepare_v2, [hMainDatabase], sqlTest, sqlTest.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, 64
        cinvoke sqliteBindInt, [.stmt], 2, 20
        cinvoke sqliteBindInt, [.stmt], 3, 0
        cinvoke sqliteBindText, [.stmt], 4, 'learning-the-asmbb-source-64', -1, SQLITE_STATIC
        cinvoke sqliteBindInt, [.stmt], 5, 2


.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .end_query

        stdcall GetFineTimestamp
        mov     [.start_time], eax

        stdcall RenderTemplate, esi, "../../www/templates/Wasp/post_view.tpl", [.stmt], Special
        mov     esi, eax

        stdcall GetFineTimestamp
        sub     eax, [.start_time]
        OutputValue "Rendering time [us]: ", eax, 10, -1

        jmp     .loop

.end_query:
        cinvoke _sqliteFinalize, [.stmt]

        stdcall GetFineTimestamp
        mov     [.start_time], eax

        stdcall RenderTemplate, esi, "../../www/templates/Wasp/nav_thread.tpl", [.stmt2], Special
        mov     esi, eax

        stdcall GetFineTimestamp
        sub     eax, [.start_time]
        OutputValue "Rendering time nav_thread [us]: ", eax, 10, -1


        stdcall GetFineTimestamp
        mov     [.start_time], eax

        stdcall RenderTemplate, edi, "../../www/templates/Wasp/main_html_start.tpl", 0, Special
        mov     edi, eax

        stdcall GetFineTimestamp
        sub     eax, [.start_time]
        OutputValue "Rendering time main_html_start [us]: ", eax, 10, -1


        stdcall GetFineTimestamp
        mov     [.start_time], eax

        stdcall RenderTemplate, esi, "../../www/templates/Wasp/main_html_end.tpl", 0, Special
        mov     esi, eax

        stdcall GetFineTimestamp
        sub     eax, [.start_time]
        OutputValue "Rendering time main_html_end [us]: ", eax, 10, -1

        cinvoke _sqliteFinalize, [.stmt2]

        mov     [esp+4*regEAX], esi
        mov     [esp+4*regEDX], edi
        popad
        return
endp



; chat enabled!

proc ChatPermissions
begin
        clc
        return
endp