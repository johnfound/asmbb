select
  nick,
  status,
  av_time,
  strftime('%d.%m.%Y %H:%M:%S', Register, 'unixepoch') as RegisterStr,
  strftime('%d.%m.%Y %H:%M:%S', LastSeen, 'unixepoch') as LastSeenStr,
  Skin,
  PostCount
from
  users
[case:[special:order]|
order by id|
order by nick|
order by nick desc|
order by av_time, nick|
order by av_time desc, nick|
order by Skin, nick|
order by Skin desc, nick|
order by PostCount, nick|
order by PostCount desc, nick|
order by Register, nick|
order by Register desc, nick|
order by LastSeen, nick|
order by LastSeen desc, nick|
order by id
]
limit ?1
offset ?2
