select
  T.id,
  T.caption,
  (select userID from Posts where threadID=T.id order by id limit 1) as UserID,
  Limited,
  Rating,
  ifnull(Vote, 0) + 1 as VoteStatus
from
  Threads T
left join
  ThreadVoters TV on TV.threadid = T.id and TV.userID = ?2
where
  T.slug = ?1;
