select
  P.id as postid,
  P.postTime,
  T.Caption,
  T.PostCount,
  U.nick as UserName,
  strftime('%Y-%m-%dT%H:%M:%SZ', P.postTime, 'unixepoch') as TimeChanged,
  P.Content,
  P.format,
  'Thread' || P.threadID as FeedID,
  T.Caption as FeedTitle,
  ?2 || '/' as URL
from
  Posts P
  left join Users U on U.id = P.userID
  left join (select id, Caption, PostCount from threads where slug = ?2) as T on T.id = P.threadid
where
  P.threadID = (select id from threads where slug = ?2)
order by
  P.postTime desc
limit ?1
