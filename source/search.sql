select distinct

  U.nick as UserName,
  U.id as UserID,
  U.avatar as avatar,
  T.slug,
  strftime('%d.%m.%Y %H:%M:%S', P.postTime, 'unixepoch') as PostTime,
  P.ReadCount,
  PostFTS.rowid,
  snippet(PostFTS, 0, '', '', '...', 16) as Content,
  T.Caption,
  (select count() from UnreadPosts UP where UP.UserID = ?4 and UP.PostID = PostFTS.rowid) as Unread

from
  PostFTS

left join
  Posts P on P.id = PostFTS.rowid

left join
  Threads T on T.id = P.threadID

left join
  ThreadTags TT on TT.ThreadID = T.id

left join
  Users U on P.userID = U.id

where
  PostFTS match ?1 and ( ?4 is null or T.slug = ?4) and (?5 is null or TT.tag = ?5)

order by rank

limit ?2

offset ?3
