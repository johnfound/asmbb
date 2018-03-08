-- One example how to rebuild the users table without data loss.

PRAGMA foreign_keys;
PRAGMA foreign_keys = OFF;
PRAGMA foreign_keys;

begin transaction;

create table Users2 (
  id        integer primary key autoincrement,
  nick      text unique,
  passHash  text unique,
  salt      text unique,
  status    integer,           -- see permXXXXX constants.
  user_desc text,              -- free text user description.
  avatar    blob,              -- copy of the user avatar.
  av_time   integer,           -- the time the avatar has been latest changed.
  email     text unique,       -- user email.
  Register  integer,           -- the time when the user has activated the account.
  LastSeen  integer,           -- the time when the user has been last seen by taking some action.
  Lang      text,              -- the language of the user interface.
  Skin      text,              -- the name of the UI skin.
  PostCount integer default 0  -- Speed optimization in order to not count the posts every time. Need automatic count.
);

insert into Users2(id, nick, passHash, salt, status, user_desc, avatar, av_time, email, Register, LastSeen, Skin, PostCount)
select id, nick, passHash, salt, status, user_desc, avatar, av_time, email, Register, LastSeen, Skin, PostCount from Users;

select count() from users2;

drop table Users;

alter table Users2 rename to Users;

create index idxUsers_nick on Users (nick);
create index idxUsers_email on Users (email);
create index idxUsersX on Users(id, nick, avatar);
create index idxUsers_LastSeen on Users(LastSeen);

PRAGMA foreign_key_check;

rollback;

PRAGMA foreign_keys = ON;
PRAGMA foreign_keys;



-- probably outdated view, that has been deleted.
-- CREATE VIEW UsersX as select *, (select count(1) from Posts as P where P.UserID = U.id) as PostCount from Users as U

