select
  id,
  caption,
  ?2 as Ticket,
  ( select
      group_concat(tag, ",")
    from
      threadtags
    where
      threadid=id
  ) as tags,
  ( select
      userid
    from
      posts
    where
      threadid = threads.id
  ) as userid
from
  threads
where
  slug = ?1;