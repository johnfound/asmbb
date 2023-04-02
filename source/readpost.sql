select
-- Thread fields

  P.threadID,
  T.Caption,
  ( select
      group_concat(tag, ", ")
    from
      threadtags
    where
      threadid=P.threadID
  ) as tags,
  ( select
      group_concat(U.nick, ", ")
    from
      LimitedAccessThreads LT left join Users U on U.id = LT.userid
      where threadid = P.threadID
  ) as invited,
  T.Pinned,
  T.Limited,

-- Post fields

  P.id,
  P.content as Source,
  Format,

-- User fields

  U.nick as UserName,

-- Common flags and data

  ?1 = (select id from posts where threadid = P.threadid order by rowid limit 1) as EditThread,
  ?2 as Ticket

from
  Posts P
left join
  Threads T on T.id = P.threadID
left join
  Users U on U.id = P.userID
where
  P.id = ?1
