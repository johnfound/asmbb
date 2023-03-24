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

LIB_MODE equ NOGUI

options.ShowSkipped = 0
options.ShowSizes = 0

options.DebugMode = 0
options.AlignCode = 0
options.ShowImported = 0

options.DebugWeb = 0
options.DebugPost = 0           ; save the latest POST request data in the file "post_data.txt"
options.DebugSQLite = 1

options.DebugWebSSE = 0         ; debug server sent events - creates a command "!echo_events" for debugging SSE.
options.Benchmark = 0

;HeapManager  equ ASM
;LinuxThreads equ native


include "%lib%/freshlib.asm"

EMOTICONS_PATH equ '/~/_images/emoticons/'      ; defines the emoticons path for the bbcode translator.
HTML_IMG_ATTR equ ' '                           ; HTML_IMG_ATTR equ ' crossorigin="anonymous" ' - notice the spaces!

include "%lib%/data/bbcode.asm"
include "%lib%/data/minimag.asm"

include "benchmark.asm"

uses sqlite3:"%TargetOS%/sqlite3.inc"

include "text_constants.asm"

include "sqlite3.asm"   ; sqlite utility functions.
include "http.asm"
include "timeproc.asm"  ; date/time utility procedures.
include "render2.asm"
include "commands.asm"
include "fcgi.asm"
include "sse_service.asm"
include "post_data.asm"
include "threadlist.asm"
include "showthread.asm"
include "search.asm"
include "post.asm"
include "edit.asm"
include "delete.asm"
include "userinfo.asm"
include "accounts.asm"
include "users_online.asm"
include "userslist.asm"
include "statistics.asm"
include "settings.asm"
include "sqlite_console.asm"
include "messages.asm"
include "version.asm"
include "images_png.asm"
include "categories.asm"
include "history.asm"
include "encryption.asm"
include "votes.asm"

include "chat.asm"

include "realtime.asm"

include "postdebug.asm"
include "attachments.asm"

include "atomfeed.asm"




iglobal
  sqlCreateDB StripText 'create.sql', SQL
              dd   0

  cDatabaseFilename text "./board.sqlite"
endg

uglobal
  hMainDatabase dd ?
  hCurrentDir   dd ?
  fOwnSocket    dd ?

  fNeedKey      dd ?
endg


;rb 123


; process exit codes:

exitNormal = 0          ; normal exit.
exitException = 1       ; some exception happened.
exitSharedMem = 2       ; shared memory allocation fault.



start:
        InitializeAll

        if ~( defined options.DebugSQLite & options.DebugSQLite )
          mov   eax, [_sqlitePrepare_v2]
          mov   ecx, [_sqliteFinalize]
          mov   [sqlitePrepare_v2], eax
          mov   [sqliteFinalize], ecx
        else
          stdcall  InitSQLStmtDebugger
        end if

        stdcall SetSegmentationFaultHandler, OnException
        stdcall SetForcedTerminateHandler, OnForcedTerminate

        stdcall GetCurrentDir
        mov     [hCurrentDir], eax

        cinvoke sqliteConfig, SQLITE_CONFIG_SERIALIZED
        cinvoke sqliteInitialize

        stdcall OpenOrCreate, cDatabaseFilename, hMainDatabase, sqlCreateDB
        jc      .finish

        cmp     eax, 1
        jne     .crypto_ok

        inc     [fNeedKey]

.crypto_ok:

        stdcall SQLiteRegisterFunctions, [hMainDatabase]
        stdcall SetDatabaseMode

        mov     eax, exitSharedMem
        stdcall InitEventsIPC
        jc      .terminate

        stdcall ThreadCreate, sseServiceThread, 0       ; the events handling thread.

        stdcall Listen

; close the database

        mov     eax, exitNormal

.terminate:
        push    eax

        mov     ebx, 30        ; 300x10ms = 300ms

.wait_close:
        cinvoke sqliteClose, [hMainDatabase]
        cmp     eax, SQLITE_BUSY
        jne     .database_closed

        stdcall Sleep, 10
        dec     ebx
        jnz     .wait_close

        push    eax
        stdcall FileWriteString, [STDERR], <"The database remained open! Check for not finished SQLite statements!", 13, 10>
        pop     eax

.database_closed:
        and     [hMainDatabase], 0
        OutputValue "Result of sqliteClose:", eax, 10, -1
        cinvoke sqliteShutdown

.finish:
        FinalizeAll
        stdcall TerminateAll ; from the stack



proc OnForcedTerminate as procForcedTerminateHandler
begin
        DebugMsg "OnForcedTerminate"

        call    __ForceTerminate

        mov     eax, exitNormal
        jmp     start.terminate         ; the stack is not important here!
endp



proc OnException as procForcedTerminateHandler
begin
        DebugMsg "OnException"

        call    __ForceTerminate

        mov     eax, exitException
        jmp     start.terminate         ; the stack is not important here!
endp



proc __ForceTerminate
begin
        lock inc [fEventsTerminate]
        stdcall SignalNewEvent        ; should close the connections!

        stdcall Sleep, 100

        cmp     [fOwnSocket], 0
        je      .finish

        stdcall SocketClose, [STDIN]
        stdcall FileDelete, pathMySocket

.finish:
        return
endp



struct TStmtList
  .stmt    dd ?
  .call    dd ?
  .dup     dd ?
  .res     dd ?
ends


; debug replacement for sqlitePrepare_v2 and sqliteFinalize !!!

if defined options.DebugSQLite & options.DebugSQLite
  sqlitePrepare_v2 dd my_sqlitePrepare_v2
  sqliteFinalize   dd my_sqliteFinalize

  uglobal
    mxSQLite TMutex
    ptrSQList dd ?
  endg


proc InitSQLStmtDebugger
begin
        stdcall MutexCreate, 0, mxSQLite
        stdcall MutexRelease, mxSQLite

        stdcall CreateArray, sizeof.TStmtList
        mov     [ptrSQList], eax
        return
endp



proc DebugInfo, .pSpecial
begin
        push    edx

        mov     edx, [.pSpecial]
        test    [edx+TSpecialParams.userStatus], permAdmin
        jz      .error_for_admins_only

        stdcall CheckSecMode, [esi+TSpecialParams.params]
        cmp     eax, secNavigate
        jne     .error_for_admins_only

        stdcall TextCreate, sizeof.TText
        stdcall ListSQLiteStatus, eax, edx
        clc
        pop     edx
        return

.error_for_admins_only:

        push    edi
        stdcall TextMakeRedirect, 0, "/!message/only_for_admins"
        mov     eax, edi
        pop     edi edx
        stc
        return
endp


else

  sqlitePrepare_v2 dd 0
  sqliteFinalize   dd 0

  DebugInfo = 0

end if


proc my_sqlitePrepare_v2, .ptrDB, .ptrSQL, .lenSQL, .ptrVarStmt, .ptrVarNext
begin
        cinvoke  _sqlitePrepare_v2, [.ptrDB], [.ptrSQL], [.lenSQL], [.ptrVarStmt], [.ptrVarNext]

        pushad

        stdcall WaitForMutex, mxSQLite, 1000
        jc      .finish

        stdcall AddArrayItems, [ptrSQList], 1
        mov     [ptrSQList], edx

        mov     esi, [ebp+4]
        mov     edi, [.ptrVarStmt]
        mov     edi, [edi]

        mov     [eax+TStmtList.call], esi
        mov     [eax+TStmtList.stmt], edi
        mov     [eax+TStmtList.dup], 0

;        OutputValue "Added $", edi, 16, 8

        stdcall MutexRelease, mxSQLite

.finish:
        popad

        cret
endp


proc my_sqliteFinalize, .stmt
begin
        pushad

        stdcall WaitForMutex, mxSQLite, 1000
        jc      .finish

        mov     esi, [ptrSQList]
        mov     ecx, [esi+TArray.count]

        mov     eax, ecx
        shl     eax, 4

        lea     esi, [esi+TArray.array + eax]
        mov     ebx, [.stmt]

.loop:
        sub     esi, sizeof.TStmtList
        dec     ecx
        js      .release

        cmp     [esi+TStmtList.stmt], ebx
        jne     .loop

        stdcall DeleteArrayItems, [ptrSQList], ecx, 1
        mov     [ptrSQList], edx

.release:
        stdcall MutexRelease, mxSQLite

.finish:
        popad
        cinvoke _sqliteFinalize, [.stmt]
        cret
endp




proc ListSQLiteStatus, .pText, .pSpecial
begin
        pushad

        mov     esi, [.pSpecial]

        stdcall StrDupMem, txt "debug.css"
        stdcall ListAddDistinct, [esi+TSpecialParams.pStyles], eax
        mov     [esi+TSpecialParams.pStyles], edx

        mov     edx, [.pText]
        stdcall TextCat, edx, txt '<div class="debug"><article><h1>Not finalized SQLite statements</h1><table class="debug_table"><tr><th>Statement</th><th>Called from</th></tr>'

        stdcall WaitForMutex, mxSQLite, 1000
        jc      .finish_sqlite

        mov     esi, [ptrSQList]
        mov     ecx, [esi+TArray.count]
        xor     ebx, ebx
        test    ecx, ecx
        jnz     .loop

        stdcall TextCat, edx, txt '<tr><td colspan="2">None</td></tr>'
        jmp     .end_sqlite

.loop:
        stdcall TextCat, edx, txt "<tr><td>"

        stdcall NumToStr, [esi+TArray.array + ebx + TStmtList.stmt], ntsHex or ntsUnsigned or ntsFixedWidth + 8
        stdcall TextCat, edx, eax
        stdcall StrDel, eax

        stdcall TextCat, edx, txt "</td><td>"

        stdcall NumToStr, [esi+TArray.array + ebx + TStmtList.call], ntsHex or ntsUnsigned or ntsFixedWidth + 8
        stdcall TextCat, edx, eax
        stdcall StrDel, eax

        stdcall TextCat, edx, txt "</td><tr>"

        add     ebx, sizeof.TStmtList
        loop    .loop

.end_sqlite:
        stdcall MutexRelease, mxSQLite

.finish_sqlite:
        stdcall TextCat, edx, txt "</table></article><article><h1>SSE listeners</h1>"

; SSE listeners

        stdcall WaitForMutex, mxListeners, 1000
        jc      .finish_sse

        mov     edi, [pFirstListener]
        xor     ecx, ecx

.listeners_loop:
        test    edi, edi
        jz      .finishok

        mov     edi, [edi+TEventsListener.pNext]
        inc     ecx
        jmp     .listeners_loop


.finishok:
        stdcall MutexRelease, mxListeners

        stdcall TextCat, edx, txt "<p>SSE listeners: "
        stdcall NumToStr, ecx, ntsDec or ntsUnsigned
        stdcall TextCat, edx, eax
        stdcall TextCat, edx, txt "</p>"
        stdcall StrDel, eax

.finish_sse:

        stdcall TextCat, edx, txt "</article><article><h1>Engine overload.</h1><p>Overload is "
        cmp     [ThreadCnt], MAX_THREAD_CNT/2
        jge     .ovl_ok
        stdcall TextCat, edx, txt "<b>not</b> "
.ovl_ok:
        stdcall TextCat, edx, txt "detected. </p>"


;StrLib statistics:
        stdcall TextCat, edx, txt "</article><article><h1>StrLib statistics</h1>"

; StrLib statistics

        stdcall WaitForMutex, StrMutex, 1000
        jc      .end_strlib

        mov     esi, [ptrStrTable]
        mov     ecx, [esi+TArray.count]
        xor     ebx, ebx

        stdcall TextCat, edx, txt "<p>Strings array size: "
        stdcall NumToStr, ecx, ntsDec or ntsUnsigned
        stdcall TextCat, edx, eax
        stdcall StrDel, eax
        stdcall TextCat, edx, txt "</p>"

.count:
        dec     ecx
        js      .end_count

        cmp     dword [esi+TArray.array + 4*ecx], 0
        je      .count

        inc     ebx
        jmp     .count

.end_count:
        stdcall TextCat, edx, txt "<p>Allocated strings: "
        stdcall NumToStr, ebx, ntsDec or ntsUnsigned
        stdcall TextCat, edx, eax
        stdcall StrDel, eax
        stdcall TextCat, edx, txt "</p>"

        stdcall TextCat, edx, txt "<p>Next slot to search: "
        stdcall NumToStr, [esi+TArray.lparam], ntsDec or ntsUnsigned
        stdcall TextCat, edx, eax
        stdcall StrDel, eax
        stdcall TextCat, edx, txt '</p><p>All allocated strings:</p><table class="debug_table"><tr><th>Handle</th><th>Content</th></tr>'

        xor     ecx, ecx
        dec     ecx

.loop2:
        inc     ecx
        cmp     ecx, [esi+TArray.count]
        jae     .end_strings

        cmp     [esi+TArray.array+4*ecx], 0
        je      .loop2

        stdcall TextCat, edx, txt "<tr><td>$"

        lea     ebx, [ecx+$c0000000]

        stdcall NumToStr, ebx, ntsHex or ntsUnsigned or ntsFixedWidth + 8
        stdcall TextCat, edx, eax
        stdcall StrDel, eax

        stdcall TextCat, edx, txt "</td><td>"

        stdcall StrEncodeHTML, ebx
        stdcall TextCat, edx, eax
        stdcall StrDel, eax

        stdcall TextCat, edx, txt "</td></tr>"
        jmp     .loop2

.end_strings:
        stdcall TextCat, edx, txt "</table>"


        stdcall MutexRelease, StrMutex

.end_strlib:
        stdcall TextCat, edx, "</article></div>"

        mov     [esp+4*regEAX], edx
        popad
        return
endp


; Here are the pragmas and calls that set the needed SQLite engine and database mode.
; There is no error check and if the database is encrypted some of these calls will fail
; so they need to be called again after successful sqliteKey call.

proc SetDatabaseMode
begin
        pushad
        cinvoke sqliteBusyTimeout, [hMainDatabase], 5000
        cinvoke sqliteExec, [hMainDatabase], "PRAGMA foreign_keys = TRUE", 0, 0, 0
        cinvoke sqliteExec, [hMainDatabase], "PRAGMA recursive_triggers = TRUE", 0, 0, 0
        cinvoke sqliteExec, [hMainDatabase], "PRAGMA threads = 2", 0, 0, 0
        cinvoke sqliteExec, [hMainDatabase], "PRAGMA secure_delete = FALSE", 0, 0, 0
        cinvoke sqliteExec, [hMainDatabase], "PRAGMA journal_mode = WAL", 0, 0, 0
        cinvoke sqliteExec, [hMainDatabase], "PRAGMA synchronous = OFF", 0, 0, 0
        popad
        return
endp