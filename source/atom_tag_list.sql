select
  S.threadid,
  T.LastChanged,
  T.Caption,
  T.Slug,
  T.PostCount,
  T.ReadCount,
  strftime('%Y-%m-%dT%H:%M:%SZ', T.LastChanged, 'unixepoch') as TimeChanged,
  (select group_concat('<b>' || html_encode(nick) || '</b>',', ')
   from ThreadPosters left join Users on userID = id where threadID = T.id order by firstPost
  ) as Posters,
  ?2 as FeedID,
  'Threads for tag [' || ?2 || ']' as FeedTitle,
  ?2 || '/' as URL,
  ?2 || '/' as tag
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
left join threads T on T.id = S.threadid;
