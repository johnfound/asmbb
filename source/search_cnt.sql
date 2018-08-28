select
  count()
from
  PostFTS
left join
  Posts P on P.id = PostFTS.rowid
left join
  LimitedAccessThreads LT on LT.threadID = P.threadID
