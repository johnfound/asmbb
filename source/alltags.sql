select
  Tag,
  ThreadCnt,
  Description,
  ( select
      count()
    from
      unreadposts up
    left join
      threadtags tt on tt.threadid = up.threadid
    where up.userid = ?1 and tt.tag = tags.tag and tt.Limited = ?2
  ) as unread
from
  Tags
where
  Importance > -1
order by
