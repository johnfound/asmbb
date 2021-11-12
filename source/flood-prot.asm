

sqlAddFlood text "insert into FloodTrack(time, UserID) values ()"
sqlLimitFlood text "delete from FloodTrack where UserID = ?1 and time < (select min(time) from (select time from FloodTrack where UserID = ?1 order by time desc limit 5))"


proc CheckFlooder, .pSpecial
.stmt dd ?
.userID dq ?
begin
        pushad

        mov     esi, [.pSpecial]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlAddFlood, sqlAddFlood.length, eax, 0
        cinvoke sqlite




        popad
        return
endp

;
; Kind of bad style flood check for all threads and users.
;
; select
;   *
; from
; (select
;  *,
;  count() as c
; from
; (select
;   threadid,
;   userid,
;   id-lag(id) over w as Diff
; from Posts
; window w as ( partition by threadid, userid order by id)
; )
; where diff = 1
; group by threadid, userid)
; where c > 4;
;

FLOOD_COUNT_DEFAULT = 4
FLOOD_INTERVAL_DEFAULT = 600

sqlCheckThreadFlood text "select count(id), max(postTime) - min(postTime) from ( select id, userid, postTime from posts where threadid = ?1 order by id desc limit ?2 ) where userid = ?3"
;sqlCheckCrossFlood  text "

proc CheckThreadFlooder, .userID, .threadID
.stmt dd ?
begin
        pushad

        xor     edi, edi

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlCheckThreadFlood, sqlCheckThreadFlood.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]

        mov     eax, FLOOD_COUNT_DEFAULT
        stdcall GetParam, 'flood_count', gpInteger
        mov     ebx, eax
        cinvoe  sqliteBindInt, [.stmt], 2, ebx

        cinvoke sqliteBindInt, [.stmt], 3, [.userID]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .flood_ok

        cinvoke sqliteColumnInt, [.stmt], 0
        cmp     eax, ebx
        jne     .flood_ok

        mov     eax, FLOOD_INTERVAL_DEFAULT
        stdcall GetParam, 'flood_interval', gpInteger
        imul    eax, ebx
        mov     esi, eax

        cinvoke sqliteColumnInt, [.stmt], 1
        cmp     eax, esi
        jg      .flood_ok

        or      edi, 1

.flood_ok:
        cinvoke sqliteFinalize, [.stmt]
        test    edi, edi
        jnz     .finish



.finish:
        shr     edi, 1
        popad
        return
endp