select

  id,
  Slug,
  Caption,
  Pinned,
  strftime('%d.%m.%Y %H:%M:%S', LastChanged, 'unixepoch') as TimeChanged,
  (select count() from posts P where P.threadID = T.id) as PostCount,
  (select count() from posts P2, UnreadPosts U where P2.id = U.PostID and P2.threadID = T.id and U.userID = ?3 ) as Unread,
  (select PostID from posts P3, UnreadPosts U2 where P3.id = U2.PostID and P3.threadID = T.id and U2.userID = ?3 limit 1) as FirstUnread,
  (select Count from PostCnt PC where PC.postid = (select id from Posts P4 where P4.threadID = T.id limit 1)) as ReadCount,
  (select group_concat('<li><a href="/!userinfo/'||nick||'">'||nick||'</a></li>','') from (select nick from threadposters left join users on userID = id where threadid = T.id order by firstPost)) as ThreadPosters,
  (select group_concat('<li><a href="/!userinfo/'||nick||'">'||nick||'</a></li>','') from LimitedAccessThreads left join Users on id = userid where threadID = T.id) as Invited,
  [case:[special:isadmin]|
  LT.userid
|
  exists (select 1 from LimitedAccessThreads where threadid = T.id)
] as limited

from
  Threads T

left join ThreadTags TT on T.id = TT.ThreadID and TT.Tag = ?4

[case:[special:isadmin]|
left join LimitedAccessThreads LT on LT.threadid = T.id
|]

where

  (?4 is null or TT.Tag = ?4)

[case:[special:isadmin]|
  and (LT.userid is null or LT.userid = ?3)
|]

order by Pinned desc, LastChanged desc

limit  ?1
offset ?2;