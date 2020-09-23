

sqlGetThreadID   text "select id from threads where slug = ?1"
sqlVoteForThread text "insert or replace into ThreadVoters(threadID, userID, Vote) values (?1, ?2, ?3)"
sqlUnvote        text "delete from ThreadVoters where threadID = ?1 and userID = ?2"
sqlGetThreadRating text "select Rating from Threads where id = ?1"

respVoteOK              text "Status: 200 Voted", 13, 10, "Content-Type: text/plain", 13, 10, 13, 10
respVoteBadRequest      text "Status: 400 Bad Request", 13, 10, "Content-Type: text/plain", 13, 10, 13, 10
respVoteUnauthorized    text "Status: 401 Unauthorized", 13, 10, "Content-Type: text/plain", 13, 10, 13, 10
respVotePermissions     text "Status: 403 No vote permissions", 13, 10, "Content-Type: text/plain", 13, 10, 13, 10
respVoteThreadMissing   text "Status: 404 Thread not exists", 13, 10, "Content-Type: text/plain", 13, 10, 13, 10
respVoteMethod          text "Status: 405 Method not allowed", 13, 10, "Content-Type: text/plain", 13, 10, 13, 10
respVoteServer          text "Status: 500 Internal Server Error", 13, 10, "Content-Type: text/plain", 13, 10, 13, 10

voteNeutral text "vote_0"
voteUp      text "vote_up"
voteDn      text "vote_dn"


proc Vote, .pSpecial
.stmt dd ?
.threadID dd ?
.vote     dd ?

begin
        pushad
        mov     esi, [.pSpecial]

        mov     edi, respVoteMethod
        cmp     [esi+TSpecialParams.post_array], 0
        je      .finish

        mov     edi, respVoteUnauthorized
        cmp     [esi+TSpecialParams.userID], 0
        je      .finish

; check the permissions.

        mov     edi, respVotePermissions
        test    [esi+TSpecialParams.userStatus], permVote or permAdmin
        jz      .finish

        mov     edi, respVoteThreadMissing
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

        mov     edi, respVoteBadRequest

        stdcall GetPostString, [esi+TSpecialParams.post_array], txt 'vote', 0
        test    eax, eax
        jz      .finish

        push    eax
        stdcall StrToNumEx, eax
        stdcall StrDel ; from the stack

        cdq
        neg     eax
        adc     edx, edx        ; edx == sign(eax)
        mov     [.vote], edx

        mov     edi, respVoteServer

        test    edx, edx
        jnz     .do_vote

; delete the previous votes for this thread.

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUnvote, sqlUnvote.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.userID]
        jmp     .sql_step

.do_vote:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlVoteForThread, sqlVoteForThread.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.userID]
        cinvoke sqliteBindInt, [.stmt], 3, [.vote]

.sql_step:
        cinvoke sqliteStep, [.stmt]
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

        cmp     ebx, SQLITE_DONE
        jne     .finish

        mov     edi, respVoteOK

.finish:
        stdcall TextCreate, sizeof.TText
        stdcall TextCat, eax, edi

        cmp     edi, respVoteOK
        jne     .exit

        mov     edi, voteNeutral
        cmp     [.vote], 0
        je      .vote_result

        mov     edi, voteUp
        cmp     [.vote], 1
        je      .vote_result

        mov     edi, voteDn

.vote_result:
        stdcall TextCat, edx, edi

        stdcall ThreadRating_AddEvent, [.threadID]

.exit:
        stc
        mov     [esp+4*regEAX], edx
        popad
        return
endp




proc ThreadRating_AddEvent, .threadID
.stmt dd ?
begin
        pushad
        xor     ebx, ebx

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadRating, sqlGetThreadRating.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finalize

        stdcall StrDupMem, txt '{ "threadid":'
        mov     ebx, eax

        stdcall NumToStr, [.threadID], ntsDec or ntsUnsigned
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

        stdcall StrCat, ebx, txt ', "rating":'


        cinvoke sqliteColumnInt, [.stmt], 0

        stdcall NumToStr, eax, ntsDec or ntsSigned
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

        stdcall StrCat, ebx, txt '}'

.finalize:
        cinvoke sqliteFinalize, [.stmt]

        test    ebx, ebx
        jz      .finish

        stdcall AddEvent, evThreadRating, ebx, 0
        stdcall StrDel, ebx

.finish:
        popad
        return
endp
