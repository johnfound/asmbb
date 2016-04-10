
;        stdcall SQLiteConsole, [.pPost], [.pParams], eax

sqlSource  text 'select ? as source'

proc SQLiteConsole, .pSpecial
.stmt dd ?
.source dd ?
.next   dd ?

.start dd ?
begin
        pushad

        stdcall StrNew
        mov     edi, eax

        mov     eax, [.pSpecial]
        stdcall GetQueryItem, [eax+TSpecialParams.post], "source=", 0
        mov     [.source], eax

; first output the form

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSource, -1, eax, 0

        cmp     [.source], 0
        je      .bind_ok

        stdcall StrPtr, [.source]
        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC

.bind_ok:
        cinvoke sqliteStep, [.stmt]


.make_the_form:

        stdcall StrCatTemplate, edi, "form_sqlite_console", [.stmt], [.pSpecial]

        cinvoke sqliteFinalize, [.stmt]

        cmp     [.source], 0
        je      .finish

; here execute the source.

        stdcall StrCat, edi, '<div class="sql_exec">'

        stdcall StrClipSpacesR, [.source]
        stdcall StrClipSpacesL, [.source]

        stdcall StrPtr, [.source]
        mov     esi, eax

.sql_loop:
        cmp     byte [esi], 0
        je      .finish_exec

        stdcall GetFineTimestamp
        mov     [.start],eax

        lea     ecx, [.stmt]
        lea     eax, [.next]
        cinvoke sqlitePrepare_v2, [hMainDatabase], esi, -1, ecx, eax

        test    eax, eax
        jnz     .error

        stdcall StrNew

        mov     edx, [.next]
        sub     edx, esi
        stdcall StrCatMem, eax, esi, edx
        push    eax

        stdcall StrEncodeHTML, eax
        stdcall StrDel ; from the stack

        stdcall StrCat, edi, "<h5>Statement executed:</h5><pre>"
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, "</pre>"

; first step
        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_ROW
        je      .fetch_rows

.done:
        cmp     eax, SQLITE_DONE
        je      .finalize


.error:
        cinvoke sqliteDBMutex, [hMainDatabase]
        cinvoke sqliteMutexEnter, eax

        cinvoke sqliteErrMsg, [hMainDatabase]

        stdcall StrCat, edi, '<p class="result_msg">'
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt '</p>'

        cinvoke sqliteDBMutex, [hMainDatabase]
        cinvoke sqliteMutexLeave, eax


.finalize:
        cinvoke sqliteFinalize, [.stmt]

        stdcall GetFineTimestamp
        sub     eax, [.start]

        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        push    eax eax

        stdcall StrCat, edi, "<p>Execution time: "
        stdcall StrCat, edi ; from the stack
        stdcall StrDel ; from the stack
        stdcall StrCat, edi, txt "us</p>"

        xchg    esi, [.next]
        cmp     esi, [.next]
        jne     .sql_loop

.finish_exec:

        stdcall StrCat, edi, '</div>'

.finish:
        stdcall StrDel, [.source]

        mov     [esp+4*regEAX], edi
        popad
        return



.fetch_rows:

locals
  .count dd ?
endl

; first the table

        stdcall StrCat, edi, '<table class="sql_rows"><tr>'

        cinvoke sqliteColumnCount, [.stmt]
        mov     [.count], eax

        xor     ebx, ebx

.col_loop:
        cmp     ebx, [.count]
        jae     .end_columns

        cinvoke sqliteColumnName, [.stmt], ebx

        stdcall StrEncodeHTML, eax

        stdcall StrCat, edi, txt "<th>"
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt "</th>"

        inc     ebx
        jmp     .col_loop

.end_columns:

        stdcall StrCat, edi, txt "</tr>"

.row_loop:

        stdcall StrCat, edi, txt "<tr>"

        xor     ebx, ebx

.val_loop:
        cmp     ebx, [.count]
        jae     .end_vals

        cinvoke sqliteColumnText, [.stmt], ebx
        test    eax, eax
        jnz     .txt_ok

        mov     eax, .cNULL

.txt_ok:
        stdcall StrEncodeHTML, eax
        stdcall StrCat, edi, txt "<td>"
        stdcall StrCat, edi, eax
        stdcall StrDel, eax
        stdcall StrCat, edi, txt "</td>"

        inc     ebx
        jmp     .val_loop

.end_vals:
        stdcall StrCat, edi, txt "</tr>"

        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_ROW
        je      .row_loop

        stdcall StrCat, edi, "</table>"

        jmp     .done

.cNULL db "NULL", 0

endp

