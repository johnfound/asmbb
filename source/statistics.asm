iglobal
  sqlStatistics StripText "statistics.sql", SQL
endg

proc Statistics, .pSpecialData
.stmt dd ?
begin
        pushad

        stdcall StrNew
        mov     edi, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlStatistics, sqlStatistics.length, eax, 0

        xor     ebx, ebx

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .end_loop

        stdcall StrCatTemplate, edi, "statistics", [.stmt], [.pSpecialData]

.end_loop:
        cinvoke sqliteFinalize, [.stmt]

        mov     [esp+4*regEAX], edi
        popad
        return
endp
