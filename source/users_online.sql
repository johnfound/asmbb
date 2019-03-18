select
  (select nick from Users where id = userID) as nick,
  Activity,
  Param,
  strftime('%H:%M:%S', max(time), 'unixepoch') as Time,
  remoteIP,
  Client,
  case
    when Activity in (5, 6, 12) then (select Caption from Threads T where T.slug = Param)
  end as Caption
from

  UserLog

where

  time > strftime('%s', 'now')-300

group by userid, remoteIP, Client
order by time desc;
