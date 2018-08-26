select
  count()
from
  Threads T
left join ThreadTags TT on T.id = TT.threadid and TT.tag = ?1
left join PrivateThreads PT on PT.threadid = T.id
where
  (?1 is null or ?1 = TT.Tag) and
  (PT.userid is null or PT.userid = ?2);
