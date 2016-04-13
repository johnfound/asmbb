select
  count()
from
  PostFTS

left join
  Posts P on P.id = PostFTS.rowid

left join
  Threads T on T.id = P.threadID

left join
  ThreadTags TT on TT.ThreadID = T.id

where
  PostFTS match ?1 and ( ?4 is null or T.slug = ?4) and (?5 is null or TT.tag = ?5)
