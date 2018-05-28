select
  NULL as rowid,
  id as postsID,
  threadID,
  userID,
  editUserID,
  (select nick from Users U where U.id = editUserID) as EditUser,
  (select nick from Users U where U.id = userID) as PostUser,
  (select av_time from Users U where U.id = editUserID) as AVerE,
  (select av_time from Users U where U.id = userID) as AVerP,
  strftime('%d.%m.%Y %H:%M:%S', postTime, 'unixepoch') as PostTime,
  strftime('%d.%m.%Y %H:%M:%S', editTime, 'unixepoch') as EditTime,
  Content
from
  Posts
where
  id = ?1
union
select
  rowid,
  postsID,
  threadID,
  userID,
  editUserID,
  (select nick from Users U where U.id = editUserID) as EditUser,
  (select nick from Users U where U.id = userID) as PostUser,
  (select av_time from Users U where U.id = editUserID) as AVerE,
  (select av_time from Users U where U.id = userID) as AVerP,
  strftime('%d.%m.%Y %H:%M:%S', postTime, 'unixepoch') as PostTime,
  strftime('%d.%m.%Y %H:%M:%S', editTime, 'unixepoch') as EditTime,
  Content
from
  PostsHistory
where
  postsID = ?1
order by editTime desc;