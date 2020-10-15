select
  count()
from
[case:[special:variant]|
    threads
  where
    limited = 0
|
    LimitedAccessThreads
  where
    userid = ?2
|
    threadtags tt
  where
    tag = ?1 and limited = 0
|
    LimitedAccessThreads LA
  left join
    ThreadTags TT on TT.threadid = LA.threadid
  where
    userid = ?2 and TT.tag = ?1
]
