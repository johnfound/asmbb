select
  S.threadid,
  T.Caption,
  T.Slug,
  strftime('%Y-%m-%dT%H:%M:%SZ', T.LastChanged, 'unixepoch') as TimeChanged,
  nick as UserName
from
  (
  select
    threadid
  from
    threadtags tt
  where
    tag = ?4 and limited = 0
  order by
    LastChanged desc
  limit ?1
  ) as S
left join threads T on T.id = S.threadid
left join Users U on U.id = T.UserID;
