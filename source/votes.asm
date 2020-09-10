


sqlVoteForThread text "update Threads set Rating = Rating + ?2 where id = ?1"
sqlRegisterVoter text "insert into ThreadVoters(threadID, userID, Vote) values (?1, ?2, ?3)"



proc Vote, .pSpecial
.stmt dd ?
begin
        pushad
        mov     esi, [.pSpecial]

        cmp     [esi+TSpecialParams.post_array], 0
        je      .bad_method

        cmp     [esi+TSpecialParams.userID], 0
        je      .must_be_logged_in

; check the permissions.

        test    [esi+TSpecialParams.userStatus], permVote or permAdmin
        jz      .no_permissions






.must_be_logged_in:


.no_permissions:

        popad
        return
endp