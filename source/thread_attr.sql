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
  Pinned
from
  threads
where
  slug = ?1;