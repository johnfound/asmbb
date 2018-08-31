select
  id as userid,
  nick as username,
  av_time as AVer,
  status,
  user_desc,
  skin,
  strftime('%d.%m.%Y %H:%M:%S', LastSeen, 'unixepoch') as LastSeen,
  email,
  (select count() from posts p left join LimitedAccessThreads lt on lt.threadid = p.threadid where p.userid = u.id and (lt.userid is null or lt.userid = ?3)) as totalposts,
  ?2 as Ticket,

  case when (status & 1)        then 'checked' end user_perm0,
  case when (status & 2)        then 'checked' end user_perm1,
  case when (status & 4)        then 'checked' end user_perm2,
  case when (status & 8)        then 'checked' end user_perm3,
  case when (status & 16)       then 'checked' end user_perm4,
  case when (status & 32)       then 'checked' end user_perm5,
  case when (status & 64)       then 'checked' end user_perm6,
  case when (status & 128)      then 'checked' end user_perm7,
  case when (status & 256)      then 'checked' end user_perm8,
  case when (status & 512)      then 'checked' end user_perm9,
  case when (status & 1024)     then 'checked' end user_perm10,
  case when (status & 0x80000000) then 'checked' end user_perm31

from users u
where nick = ?1
