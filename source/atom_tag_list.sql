select
  S.threadid,
  T.LastChanged,
  T.Caption,
  T.Slug,
  strftime('%Y-%m-%dT%H:%M:%SZ', T.LastChanged, 'unixepoch') as TimeChanged,
  nick as UserName,
  ?2 as FeedID,
  ?2 || '/' as tag,
  'Threads for tag [' || ?2 || ']' as FeedTitle,
  ?2 || '/' as URL
from
  (
  select
    threadid
  from
    threadtags tt
  where
    tag = ?2 and limited = 0
  order by
    LastChanged desc
  limit ?1
  ) as S
left join threads T on T.id = S.threadid
left join Users U on U.id = T.UserID;
