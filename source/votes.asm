

sqlGetThreadID   text "select id from threads where slug = ?1"
sqlVoteForThread text "update Threads set Rating = Rating + ?2 where id = ?1"
sqlRegisterVoter text "insert into ThreadVoters(threadID, userID, Vote) values (?1, ?2, ?3)"

respVoteOK              text "Status: 200 Voted", 13, 10, 13, 10
respVoteBadRequest      text "Status: 400 Bad Request", 13, 10, 13, 10
respVoteUnauthorized    text "Status: 401 Unauthorized", 13, 10, 13, 10
respVotePermissions     text "Status: 403 No vote permissions", 13, 10, 13, 10
respVoteThreadMissing   text "Status: 404 Thread not exists", 13, 10, 13, 10
respVoteMethod          text "Status: 405 Method not allowed", 13, 10, 13, 10
respVoteServer          text "Status: 500 Internal Server Error", 13, 10, 13, 10



proc Vote, .pSpecial
.stmt dd ?
.threadID dd ?
.vote     dd ?
.response dd ?

begin
        pushad
        mov     esi, [.pSpecial]

        mov     [.response], respVoteMethod
        cmp     [esi+TSpecialParams.post_array], 0
        je      .finish

        mov     [.response], respVoteUnauthorized
        cmp     [esi+TSpecialParams.userID], 0
        je      .finish

; check the permissions.

        mov     [.response], respVotePermissions
        test    [esi+TSpecialParams.userStatus], permVote or permAdmin
        jz      .finish

        mov     [.response], respVoteThreadMissing
        cmp     [esi+TSpecialParams.thread], 0
        je      .finish                     ; no thread specified.

; get the thread ID

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadID, sqlGetThreadID.length, eax, 0

        stdcall StrPtr, [esi+TSpecialParams.thread]

        cinvoke sqliteBindText, [.stmt], 1, eax, [eax+string.len], SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cmp     eax, SQLITE_ROW
        jne     .id_ok

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.threadID], eax

.id_ok:
        cinvoke sqliteFinalize, [.stmt]
        cmp     ebx, SQLITE_ROW
        jne     .finish             ; here the error is still 404 from the previous check


; get vote up or down

        mov     [.response], respVoteBadRequest

        stdcall GetPostString, [esi+TSpecialParams.post_array], 'vote', 0
        test    eax, eax
        jz      .finish

        push    eax
        stdcall StrToNumEx, eax
        stdcall StrDel ; from the stack

        cdq
        neg     eax
        adc     edx, edx        ; edx == sign(eax)
        jz      .finish

        mov     [.vote], edx

; start the transaction and process the request.

        cinvoke sqliteExec, [hMainDatabase], sqlBegin, 0, 0, 0

        mov     edi, sqlRollback
        mov     [.response], respVoteServer

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlVoteForThread, sqlVoteForThread.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 2, [.vote]

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_OK
        jne     .commit_rollback

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlRegisterVoter, sqlRegisterVoter.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.userID]
        cinvoke sqliteBindInt, [.stmt], 3, [.vote]

        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax

        cinvoke sqliteFinalize, [.stmt]
        cmp     ebx, SQLITE_OK
        jne     .commit_rollback

        mov     edi, sqlCommit
        mov     [.response], respVoteOK

.commit_rollback:

        cinvoke sqliteExec, [hMainDatabase], edi, 0, 0, 0
        cmp     edi, sqlCommit
        jne     .finish

        stdcall ThreadRating_AddEvent, [.threadID], [.vote]

.finish:
        stdcall TextCreate, sizeof.TText
        stdcall TextCat, eax, [.response]

        stc
        mov     [esp+4*regEAX], edx
        popad
        return
endp



proc ThreadRating_AddEvent, .thread, .vote
begin
        stdcall StrDupMem, txt '{ threadid:'
        mov     ebx, eax

        stdcall NumToStr, [.thread], ntsDec or ntsUnsigned
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

        stdcall StrCat, ebx, txt ', change:'
        stdcall NumToStr, [.vote], ntsDec or ntsSigned
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

        stdcall StrCat, ebx, txt '}'

        stdcall AddEvent, evThreadRating, ebx, 0
        stdcall StrDel, ebx

        return
endp