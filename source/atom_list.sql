select
  S.threadid,
  T.LastChanged,
  T.Caption,
  T.Slug,
  strftime('%Y-%m-%dT%H:%M:%SZ', T.LastChanged, 'unixepoch') as TimeChanged,
  nick as UserName,
  'AllThreads' as FeedID,
  '' as tag
from
  (select
    id as threadid
  from
    threads
  where
    limited = 0
  order by
    LastChanged desc
  limit ?1
  ) as S
left join threads T on T.id = S.threadid
left join Users U on U.id = T.UserID;
