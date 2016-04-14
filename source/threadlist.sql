select

  id,
  Slug,
  Caption,
  Pinned,
  strftime('%d.%m.%Y %H:%M:%S', LastChanged, 'unixepoch') as TimeChanged,
  (select count() from posts P where P.threadID = T.id) as PostCount,
  (select count() from posts P2, UnreadPosts U where P2.id = U.PostID and P2.threadID = T.id and U.userID = ?3 ) as Unread

from
  Threads T

where ?4 is null or ?4 in (select Tag from ThreadTags TT where TT.threadID = T.id)

order by Pinned desc, LastChanged desc

limit  ?1
offset ?2
