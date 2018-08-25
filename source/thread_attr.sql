select
  id,
  caption,
  ?2 as Ticket,
  ( select
      group_concat(tag, ", ")
    from
      threadtags
    where
      threadid=id
  ) as tags,
  ( select
      group_concat(U.nick, ", ")
    from
      PrivateThreads PT left join Users U on U.id = PT.userid
      where threadid = threads.id
  ) as invited,
  ( select
      userid
    from
      posts
    where
      threadid = threads.id
    order by posts.id
    limit 1
  ) as userid,
  Pinned,
  exists (select 1 from PrivateThreads where threadid=threads.id) as private
from
  threads
where
  slug = ?1;
