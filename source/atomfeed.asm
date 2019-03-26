
iglobal
  sqlAtomList       StripText "atom_list.sql", SQL
  sqlAtomTagList    StripText "atom_tag_list.sql", SQL
  sqlAtomThread     StripText "atom_one_thread.sql", SQL
endg




proc CreateAtomFeed, .pSpecial
begin
        pushad

        mov     esi, [.pSpecial]
        cmp     [esi+TSpecialParams.Limited], 0
        jne     .error_404                              ; no limited threads in the feed.


        stdcall TextCreate, sizeof.TText
        mov     edx, eax





.error_404:

        popad
        return
endp