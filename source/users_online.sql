select

  (select nick from Users where id = userID) as nick,
  Activity,
  Param,
  strftime('%H:%M:%S', max(time), 'unixepoch') as Time,
  remoteIP,
  Client

from

  UserLog

where

  time > strftime('%s', 'now')-300

group by userid, remoteIP, Client
order by time desc;
