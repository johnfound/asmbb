iglobal
  sqlStatistics StripText "statistics.sql", SQL
endg

proc Statistics, .pSpecialData
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlStatistics, sqlStatistics.length, eax, 0

        xor     ebx, ebx

        cinvoke sqliteStep, [.stmt]
        stdcall RenderTemplate, 0, "statistics.tpl", [.stmt], [.pSpecialData]
        mov     [esp+4*regEAX], eax

        cinvoke sqliteFinalize, [.stmt]

        popad
        return
endp

