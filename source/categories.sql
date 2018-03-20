-- This is the fastest variant I was able to invent...
select
  t.Tag,
  t.importance,
  t.Description,
  ( select count() from threadtags tt where tt.tag = t.tag) as cnt,
  ( select count() from threadtags tt2 left join posts p on p.threadid = tt2.threadid where tt2.tag = t.tag ) as postcnt,
  ( select count() from unreadposts up2 left join posts p2 on p2.id = up2.postid left join threadtags tt3 on tt3.threadid = p2.threadid where up2.userid = 41 and tt3.tag = t.tag) as unread
from
  tags t
where
  t.importance >= 0 and t.Description is not null
order by
  importance desc;
