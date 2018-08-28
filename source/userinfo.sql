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
  (select status & 1 <> 0) as canlogin,
  (select status & 4 <> 0) as canpost,
  (select status & 8 <> 0) as canstart,
  (select status & 16 <> 0) as caneditown,
  (select status & 32 <> 0) as caneditall,
  (select status & 64 <> 0) as candelown,
  (select status & 128 <> 0) as candelall,
  (select status & 0x80000000 <> 0) as isadmin,
  ?2 as Ticket
from users u
where nick = ?1
