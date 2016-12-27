select

  id,
  Slug,
  Caption,
  Pinned,
  strftime('%d.%m.%Y %H:%M:%S', LastChanged, 'unixepoch') as TimeChanged,
  (select count() from posts P where P.threadID = T.id) as PostCount,
  (select count() from posts P2, UnreadPosts U where P2.id = U.PostID and P2.threadID = T.id and U.userID = ?3 ) as Unread,
  (select PostID from posts P3, UnreadPosts U2 where P3.id = U2.PostID and P3.threadID = T.id and U2.userID = ?3 limit 1) as FirstUnread

from
  Threads T

where ?4 is null or ?4 in (select Tag from ThreadTags TT where TT.threadID = T.id)

order by Pinned desc, LastChanged desc

limit  ?1
offset ?2
