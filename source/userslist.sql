select
  nick as UserName,
  status,
  av_time,
  strftime('%d.%m.%Y %H:%M:%S', Register, 'unixepoch') as RegisterStr,
  strftime('%d.%m.%Y %H:%M:%S', LastSeen, 'unixepoch') as LastSeenStr,
  Skin,
  PostCount,
  (Register is not null) as fRegister,
  (LastSeen is not null) as fLast
from
  users
[case:[special:order]|
order by id|
order by UserName|
order by UserName desc|
order by av_time, nick|
order by av_time desc, nick|
order by Skin, nick|
order by Skin desc, nick|
order by PostCount, nick|
order by PostCount desc, nick|
order by Register, id, nick|
order by Register desc, id desc, nick|
order by LastSeen, nick|
order by LastSeen desc, nick|
order by id
]
limit ?1
offset ?2
