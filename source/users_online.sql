select
  (select nick from Users where id = U.userID) as nick,
  Activity,
  Param,
  strftime('%H:%M:%S', max(time), 'unixepoch') as Time,
  remoteIP,
  Client,
  case when Activity in (5, 6, 12) then
    case when (select Limited from Threads where slug = cast(Param as text)) then
      '<span>Private</span>'
    else
      '<a href="/' || Param || '/">' || (select html_encode(Caption) from Threads where slug = cast(Param as text)) || '</a>'
    end
  end as Link
from

  UserLog U

where

  time > strftime('%s', 'now')-300

group by U.userid, remoteIP, Client
order by time desc;