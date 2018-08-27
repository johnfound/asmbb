-- This is the fastest variant I was able to invent...
select
  t.Tag,
  t.importance,
  t.Description,
  ( select
      count()
    from
      threadtags tt
      [case:[special:isadmin]|left join LimitedAccessThreads LT on LT.threadID = TT.threadID|]
    where
      [case:[special:isadmin]|(LT.userID is null or LT.userID = ?1) and|] tt.tag=t.tag
  ) as cnt,
  ( select
      count()
    from
      threadtags tt2
      [case:[special:isadmin]|left join LimitedAccessThreads LT on LT.threadID=tt2.threadID|]
      left join posts p on p.threadid = tt2.threadid
    where
      [case:[special:isadmin]|(LT.userID is null or LT.userID = ?1) and|]
      tt2.tag = t.tag
  ) as postcnt,
  ( select
      count()
    from
      unreadposts up2
      left join posts p2 on p2.id = up2.postid
      left join threadtags tt3 on tt3.threadid = p2.threadid
    where
      up2.userid = ?1 and tt3.tag = t.tag
  ) as unread
from
  tags t
where
  t.importance >= 0 and t.Description is not null
order by
  importance desc;
