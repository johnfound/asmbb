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
order by nick collate nocase|
order by nick collate nocase desc|
order by av_time, nick collate nocase|
order by av_time desc, nick collate nocase|
order by Skin, nick collate nocase|
order by Skin desc, nick collate nocase|
order by PostCount, nick collate nocase|
order by PostCount desc, nick collate nocase|
order by Register, nick collate nocase|
order by Register desc, nick collate nocase|
order by LastSeen, nick collate nocase|
order by LastSeen desc, nick collate nocase|
order by id
]
limit ?1
offset ?2
