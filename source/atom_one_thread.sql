select
  P.id as PostID,
  T.Caption,
  U.nick as UserName,
  strftime('%Y-%m-%dT%H:%M:%SZ', P.postTime, 'unixepoch') as PostTime,
  P.Content,
  P.format
from
  Posts P
  left join Users U on U.id = P.userID
  left join (select id, Caption from threads where slug = ?2) as T on T.id = P.threadid
where
  P.threadID = (select id from threads where slug = ?2)
order by
  P.postTime desc
limit ?1
