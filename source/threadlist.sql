select

  id,
  Slug,
  Caption,
  Pinned,
  strftime('%d.%m.%Y %H:%M:%S', LastChanged, 'unixepoch') as TimeChanged,
  (select count() from posts P where P.threadID = T.id) as PostCount,
  (select count() from posts P, UnreadPosts U where id = PostID and P.threadID = T.id and U.userID = ?3 ) as Unread,
  (select PostID from posts P, UnreadPosts U where id = PostID and P.threadID = T.id and U.userID = ?3 limit 1) as FirstUnread,
  (select Count from PostCnt where postid = (select id from Posts P where P.threadID = T.id limit 1)) as ReadCount,
  (select group_concat('<li><a href="/!userinfo/'||nick||'">'||nick||'</a></li>','') from (select url_encode(nick) as nick from threadposters TP left join users on userID = id where TP.threadid = T.id order by firstPost)) as Posters,
  (select group_concat('<li><a href="/!userinfo/'||url_encode(nick)||'">'||nick||'</a></li>','') from LimitedAccessThreads LA left join Users on id = userid where LA.threadID = T.id) as Invited,
  (select group_concat('<li><a href="/'||url_encode(html_encode(TT.tag))||'/" title="'||html_encode(T.description)||'">'||html_encode(TT.tag)||'</a></li>','') from ThreadTags TT left join Tags T on T.tag = TT.tag where TT.threadID=T.id) as ThreadTags,
[case:[special:isadmin]|
  LT.userid
|
  exists (select 1 from LimitedAccessThreads LA where LA.threadid = T.id)
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
