insert into
Users (
  nick,
  passHash,
  salt,
  status,
  email,
  Register,
  LastPostTime,
  PostInterval,
  PostIntervalInc,
  MaxPostLen
) select
  nick,
  passHash,
  salt,
  ?1,
  email,
  time_reg,
  strftime('%s','now'),
  ?2,
  ?3,
  ?4
from
  WaitingActivation
where
  a_secret = ?5