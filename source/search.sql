select
  PostFTS.rowid,
  PostFTS.user as UserName,
  P.userID,
  U.av_time as AVer,
  PostFTS.slug,
  fuzzytime(P.postTime) as PostTime,
  PC.count as ReadCount,
  snippet(PostFTS, 0, '*', '*', '...', 16) as Content,
  PostFTS.Caption,
  (select count() from UnreadPosts UP where UP.UserID = ?4 and UP.PostID = PostFTS.rowid) as Unread
from
  PostFTS
  left join Posts P on P.id = PostFTS.rowid
  left join PostCnt PC on PC.postID = P.id
  left join Users U on U.id = P.userID
  left join LimitedAccessThreads LT on LT.threadID = P.threadID
