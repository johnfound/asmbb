select
  id,
  Slug,
  Caption,
  Pinned,
  strftime('%d.%m.%Y %H:%M:%S', LastChanged, 'unixepoch') as TimeChanged,
  T.PostCount,
  Unread,
  FirstUnread,
  ReadCount,
  (select group_concat('<li><a href="/!userinfo/'||url_encode(nick)||'">'||html_encode(nick)||'</a></li>','') from ThreadPosters left join Users on userID = id where threadID = T.id order by firstPost) as Posters,
  (select group_concat('<li><a href="/!userinfo/'||url_encode(nick)||'">'||html_encode(nick)||'</a></li>','') from LimitedAccessThreads left join Users on id = userid where threadID = T.id) as Invited,
  group_concat('<li><a href="/'||url_encode(TT.tag)||'/" title="['||TT.tag||'] '||ifnull(html_encode(TG.description),'')||'">'||TT.tag||'</a></li>','') ThreadTags,
[case:[special:isadmin]|
  LT.userid
|
  exists (select 1 from LimitedAccessThreads where threadid = T.id)
] as limited

from
  Threads T

left join ThreadTags TT on T.id = TT.ThreadID
left join Tags TG on TG.tag = TT.tag
left join (select count() as Unread, min(UP7.PostID) as FirstUnread, UP7.threadid as ti from unreadposts UP7 where userid=?3 group by ti) on ti = T.id

[case:[special:isadmin]|
left join LimitedAccessThreads LT on LT.threadid = T.id
|]

[case:[special:isadmin]|
 where (LT.userid is null or LT.userid = ?3)
|]

group by T.id, Pinned, LastChanged
having ?4 is null or max(TT.tag = ?4)

limit  ?1
offset ?2;
