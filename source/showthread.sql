select

  P.id,
  P.threadID,
  strftime('%d.%m.%Y %H:%M:%S', P.postTime, 'unixepoch') as PostTime,
  P.Rendered,
  U.id as UserID,
  U.nick as UserName,
  U.PostCount as UserPostCount,
  U.av_time as AVer,
  ?4 as Slug,
  (select count() from UnreadPosts UP where UP.UserID = ?5 and UP.PostID = P.id) as Unread,
  PC.count as ReadCount

from Posts P
left join PostCNT PC on PC.postid = P.id
left join Users U on U.id = P.userID
where P.id in (select id from posts where threadid=?1 limit ?2 offset ?3);
