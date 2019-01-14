-- This is the fastest variant I was able to invent...
select
  t.Tag,
  t.importance,
  t.Description,
  t.PostCnt,
  t.ThreadCnt,
  ( select
      count()
    from
      unreadposts up
      left join threadtags tt on tt.threadid = up.threadid
    where
      up.userid = ?1 and tt.tag = t.tag
  ) as unread
from
  tags t
where
  t.importance >= 0 and t.Description is not null
order by
  importance desc;
