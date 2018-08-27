select
  count()
from
  Threads T
left join ThreadTags TT on T.id = TT.threadid and TT.tag = ?1
[case:[special:isadmin]|left join LimitedAccessThreads LT on LT.threadid = T.id|]
where
  (?1 is null or ?1 = TT.Tag)
  [case:[special:isadmin]|and (LT.userid is null or LT.userid = ?2)|]
