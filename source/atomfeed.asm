
iglobal
  sqlAtomList       StripText "atom_list.sql", SQL
  sqlAtomTagList    StripText "atom_tag_list.sql", SQL
  sqlAtomThread     StripText "atom_one_thread.sql", SQL
endg

tplPost text "atom_entry_post.tpl"
tplThread text "atom_entry_thread.tpl"



proc CreateAtomFeed, .pSpecial
.stmt dd ?

.date TDateTime
.timeLo dd ?
.timeHi dd ?
  BenchVar .rss

begin
        pushad

        BenchmarkStart .rss

        xor     edi, edi
        mov     esi, [.pSpecial]

        cmp     [esi+TSpecialParams.Limited], edi
        clc
        jne     .finish                              ; no limited threads in the feed. return 404 not found

        stdcall LogUserActivity, esi, uaAtomFeedUpdate, 0

        stdcall TextCreate, sizeof.TText
        mov     edi, eax

        mov     ecx, sqlAtomThread
        mov     ebx, tplPost
        cmp     [esi+TSpecialParams.thread], 0
        jne     .sql_ok

        mov     ecx, sqlAtomTagList
        mov     ebx, tplThread

        cmp     [esi+TSpecialParams.dir], 0
        jne     .sql_ok

        mov     ecx, sqlAtomList

.sql_ok:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], ecx, -1, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.page_length]

        mov     eax, [esi+TSpecialParams.thread]
        test    eax, eax
        cmovz   eax, [esi+TSpecialParams.dir]
        test    eax, eax
        jz      .param_ok

        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

.param_ok:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_404

; compare the browser cached date:

        mov     [.timeLo], 0
        mov     [.timeHi], 0

        stdcall ValueByName, [esi+TSpecialParams.params], txt "HTTP_IF_MODIFIED_SINCE"
        jc      .do_create

        lea     edx, [.date]
        stdcall DecodeHTTPDate, eax, edx
        jc      .do_create

        stdcall DateTimeToTime, edx
        mov     [.timeLo], eax
        mov     [.timeHi], edx

        cinvoke sqliteColumnInt64, [.stmt], 1   ; the time is always column 1 in the queries!!!

        cmp     edx, [.timeHi]
        ja      .do_create
        jb      .not_changed_304

        cmp     eax, [.timeLo]
        jbe     .not_changed_304

; Create the XML file of the feed...
.do_create:

        stdcall TextCat, edi, <txt "Content-Type: application/atom+xml; charset=UTF-8", 13, 10, "Cache-control: max-age=3600", 13, 10, "Last-modified: ">
        mov     edi, edx

        cinvoke sqliteColumnInt64, [.stmt], 1   ; the time is always column 1 in the queries!!!
        stdcall FormatHTTPTime, eax, edx
        stdcall TextCat, edi, eax
        stdcall StrDel, eax
        stdcall TextCat, edx, <txt 13, 10, 13, 10>

        stdcall RenderTemplate, edi, "atom_start.tpl", [.stmt], esi
        mov     edi, eax

.loop:
        stdcall RenderTemplate, edi, ebx, [.stmt], esi
        mov     edi, eax

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        je      .loop

        stdcall TextCat, edi, txt "</feed>"     ; finalizes the <feed> tag.
        mov     edi, edx

.finalize:

        cinvoke sqliteFinalize, [.stmt]
        stc

.finish:
        pushf
        Benchmark "Atom feed processing: "
        BenchmarkEnd
        popf

        mov     [esp+4*regEAX], edi
        popad
        return

.error_404:
        cinvoke sqliteFinalize, [.stmt]

        stdcall TextFree, edi
        xor     edi, edi
        clc
        jmp     .finalize


.not_changed_304:
        stdcall TextCat, edi, <"Status: 304 Not Modified", 13, 10, 13, 10>
        mov     edi, edx
        jmp     .finalize
endp

