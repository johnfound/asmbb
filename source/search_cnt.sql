select
  count()
from
  PostFTS

left join
  Posts P on P.id = PostFTS.rowid

left join
  Threads T on T.id = P.threadID

left join
  ThreadTags TT on TT.ThreadID = T.id and TT.Tag = ?5

where
  (?1 is NULL or PostFTS match ?1) and ( ?4 is null or T.slug = ?4) and (?5 is null or TT.tag = ?5) and (?6 is null or P.userID = ?6)
