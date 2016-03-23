BEGIN TRANSACTION;

/* Data tables */

create table if not exists Params (
  id  text primary key,
  val text
);

insert or ignore into Params values ('host','board.asm32.info');
insert or ignore into Params values ('email','admin');
insert or ignore into Params values ('smtp_ip','164.138.218.50');
insert or ignore into Params values ('smtp_port','25');


create table if not exists Users (
  id	    integer primary key autoincrement,
  nick	    text unique,
  passHash  text unique,
  salt	    text unique,
  status    integer,	     -- see permXXXXX constants.
  user_desc text,	     -- free text user description.
  email     text unique,     -- user email.
  LastSeen  integer	     -- the time when the user has been last seen by taking some action.
);


create index if not exists idxUsers_nick  on Users (nick);
create index if not exists idxUsers_email on Users (email);


create table if not exists WaitingActivation(
  id integer primary key,
  nick text unique,
  passHash text unique,
  salt	text unique,
  email text unique,
  ip_from text,
  time_reg   integer,
  time_email integer,
  a_secret text unique
);



create table if not exists Threads (
  id	      integer primary key autoincrement,
  Slug	      text unique,
  Caption     text,
  LastChanged integer
);


create index if not exists idxThreads_LastChanged on Threads (LastChanged desc);
create index if not exists idxThreads_Slug	  on Threads (Slug);



create table if not exists Posts (
  id	      integer primary key autoincrement,
  threadID    integer references Threads(id),
  userID      integer references Users(id),

  postTime    integer,	-- based on postTime the posts are sorted in the thread.
  Content     text
);


create index if not exists idxPosts_UserID   on Posts (userID);
create index if not exists idxPosts_ThreadID on Posts (threadID);
create index if not exists idxPosts_Time     on Posts (postTime, id);


create table if not exists Tags (
  id	      integer primary key autoincrement,
  Tag	      text,
  Description text
);


/* Relation tables */

create table if not exists ThreadTags (
  ThreadID integer references Threads(id),
  TagID    integer references Tags(id)
);


create table if not exists UnreadPosts (
  UserID integer references Users(id),
  PostID integer references Posts(id),
  Time	 integer
);


create unique index idxUnreadPosts on UnreadPosts(UserID, PostID);


create table if not exists Attachements (
  postID   integer references Posts(id),
  filename text,
  notes    text,
  file	   blob
);


create table if not exists Sessions (
  userID    integer references Users(id),
  fromIP    text,
  sid	    text,
  last_seen integer,
  unique (userID, fromIP)
);



create table if not exists Messages (
  id	 text primary key,
  msg	 text,
  header text,
  link	 text
);


insert or ignore into Messages values ('bad_secret',	  'Bad activation secret!', 'ERROR!', '<a target="_self" href="/list/">Goto threads list</a>');
insert or ignore into Messages values ('congratulations', 'Your account has been activated.', 'Congratulations!', '<a href="/login/">Welcome!</a>');
insert or ignore into Messages values ('error_cant_create_threads', 'You do not have permissions to create new threads!', 'ERROR!', NULL);
insert or ignore into Messages values ('error_cant_post', 'You do not have permissions to post in this forum!', 'ERROR!', NULL);
insert or ignore into Messages values ('login_bad_password','Bad password or user name.', 'ERROR!', NULL);
insert or ignore into Messages values ('login_bad_permissions', 'You do not have permissions to login.', 'ERROR!', NULL);
insert or ignore into Messages values ('login_missing_data','Missing data in login field.', 'ERROR!', NULL);
insert or ignore into Messages values ('register_bad_email','This address does not seems to be valid email.', 'ERROR!', NULL);
insert or ignore into Messages values ('register_passwords_different','The confirmation password does not match.', 'ERROR!', NULL);
insert or ignore into Messages values ('register_short_email','User email address invalid.', 'ERROR!', NULL);
insert or ignore into Messages values ('register_short_name','User name too short.', 'ERROR!', NULL);
insert or ignore into Messages values ('register_short_pass','The password is too short.', 'ERROR!', NULL);
insert or ignore into Messages values ('register_technical','Because of some technical problems you can not register right now.', 'ERROR!', NULL);
insert or ignore into Messages values ('register_user_exists','User name already exists.', 'ERROR!', NULL);
insert or ignore into Messages values ('user_create','Your accout has been created, but is still inactive. Avtivation email has been sent to you.', 'Success!', '<a target="_self" href="/list/">Goto threads list</a>');


create table if not exists Templates (
  id text primary key,
  template text
);




COMMIT;
