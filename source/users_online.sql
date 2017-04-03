select

  (select nick from Users where id = UL.userID) as nick,
  UL.Activity,
  UL.Param,
  strftime('%H:%M:%S', UL.Time, 'unixepoch') as Time,
  remoteIP

from

  UserLog UL

where

  UL.time > strftime('%s', 'now')-300

group by userid, remoteIP
order by rowid desc;
