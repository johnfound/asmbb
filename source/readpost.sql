select
  P.id,
  T.Caption,
  P.content as Source,
  Format,
  ?2 as Ticket,
  ( select
      nick
    from
      users U
    where
      U.id = ?4
  ) as UserName,
  ?1 = (select id from posts where threadid = P.threadid order by rowid limit 1) as EditThread,
  T.Pinned
from
  Posts P
left join
  Threads T on T.id = P.threadID
where
  P.id = ?1
