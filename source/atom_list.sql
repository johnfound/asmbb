select
  T.id as threadid,
  T.LastChanged,
  T.Caption,
  T.Slug,
  T.PostCount,
  T.ReadCount,
  strftime('%Y-%m-%dT%H:%M:%SZ', T.LastChanged, 'unixepoch') as TimeChanged,
  (select group_concat('<b>' || html_encode(nick) || '</b>',', ')
   from ThreadPosters left join Users on userID = id where threadID = T.id order by firstPost
  ) as Posters,
  'AllThreads' as FeedID,
  'All threads' as FeedTitle,
  '' as URL,
  '' as tag
from
  threads T
where
  limited = 0
order by
  LastChanged desc
limit ?1;
