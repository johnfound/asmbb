select
  t.Id,
  t.Slug,
  t.Caption,
  [case:[special:variant]|0 as Pinned|t.Pinned],
  strftime('%d.%m.%Y %H:%M:%S', t.LastChanged, 'unixepoch') as TimeChanged,
  t.PostCount,
  t.ReadCount,
  t.Limited,
  (select
     group_concat('<li><a href="/!userinfo/'||url_encode(nick)||'">'||html_encode(nick)||'</a></li>','')
   from (
     select nick, firstpost from ThreadPosters left join Users on userID = id where threadID = s.threadid order by firstPost
   )
  ) as Posters,
[case:[special:limited]|
  NULL
|
  (select group_concat('<li><a href="/!userinfo/' ^|^| url_encode(nick) ^|^| '">' ^|^| html_encode(nick) ^|^| '</a></li>','') from LimitedAccessThreads left join Users on id = userid where threadID = s.threadid)
] as Invited,
  (select group_concat('<li><a href="/' || url_encode(TT.tag) || '/" title="^[' || TT.tag || '^] ' || ifnull(html_encode(TG.description),'') || '">' || TT.tag || '</a></li>','')
  from ThreadTags tt left join tags tg on tg.tag = tt.tag where TT.threadid = s.threadid
  ) as  ThreadTags,
  ifnull(Unread,0) as Unread,
  ifnull(FirstUnread,0) as FirstUnread
from (
[case:[special:variant]|
  select
    id as threadid
  from
    threads
  where
    limited = 0
  order by
    LastChanged desc
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
left join (select count() as Unread, min(UP7.PostID) as FirstUnread, UP7.threadid as ti from unreadposts UP7 where userid=?3 group by ti) on ti = s.threadid;
