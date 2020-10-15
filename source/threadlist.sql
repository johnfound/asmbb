select
  t.Id,
  t.Slug,
  t.Caption,
  [case:[special:variant]|(t.Pinned > 1)|0|t.Pinned] as Pinned,
  fuzzytime(LastChanged) as TimeChanged,
  t.PostCount,
  t.ReadCount,
  t.Limited,
  t.Rating,
  (select group_concat('<li><a href="/!userinfo/'^|^|url_encode(nick)^|^|'">'^|^|html_encode(nick)^|^|'</a></li>','')
   from ( select nick from ThreadPosters left join Users on userID = id where threadID = s.threadid order by firstPost limit 10)) as Posters,
[case:[special:limited]|
  NULL
|
  (select group_concat('<li><a href="/!userinfo/' ^|^| url_encode(nick) ^|^| '">' ^|^| html_encode(nick) ^|^| '</a></li>','') from LimitedAccessThreads left join Users on id = userid where threadID = s.threadid)
] as Invited,
  (select group_concat('<li><a href="/' ^|^| url_encode(TT.tag) ^|^| '/" title="^[' ^|^| TT.tag ^|^| '^] ' ^|^| ifnull(html_encode(TG.description),'') ^|^| '">' ^|^| TT.tag ^|^| '</a></li>','')
  from ThreadTags tt left join tags tg on tg.tag = tt.tag where TT.threadid = s.threadid
  ) as  ThreadTags,
  Unread
from (
[case:[special:variant]|
  select
    id as threadid
  from
    threads
  where
    limited = 0
  order by
    (Pinned > 1) desc, LastChanged desc
|
  select
    threadid
  from
    LimitedAccessThreads
  where
    userid = ?3
  order by
    LastChanged desc
|
  select
    threadid
  from
    threadtags tt
  where
    tag = ?4 and limited = 0
  order by
    Pinned desc, LastChanged desc
|
  select
    TT.threadid
  from
    threadtags TT
  left join
    LimitedAccessThreads LA on LA.threadid = TT.threadid
  where
    LA.userid = ?3 and TT.tag = ?4
  order by
    Pinned desc, TT.LastChanged desc
]
  limit ?1
  offset ?2 ) as S
left join threads t on t.id = s.threadid
left join (select count() as Unread, UP7.threadid as ti from unreadposts UP7 where userid=?3 group by ti) on ti = s.threadid;

