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
insert or ignore into Params values ('file_cache', '0');


create table if not exists Users (
  id	    integer primary key autoincrement,
  nick	    text unique,
  passHash  text unique,
  salt	    text unique,
  status    integer,	     -- see permXXXXX constants.
  user_desc text,	     -- free text user description.
  avatar    blob,	     -- copy of the user avatar.
  email     text unique,     -- user email.
  Register  integer,	     -- the time when the user has activated the account.
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
  ip_from text unique,
  time_reg   integer,
  time_email integer,
  a_secret text unique
);



create table if not exists Threads (
  id	      integer primary key autoincrement,
  Slug	      text unique,
  Caption     text,
  LastChanged integer,
  Pinned      integer default 0
);


create index if not exists idxThreads_LastChanged on Threads (LastChanged desc);
create index if not exists idxThreads_Slug	  on Threads (Slug);



create table if not exists Posts (
  id	      integer primary key autoincrement,
  threadID    integer references Threads(id) on delete cascade,
  userID      integer references Users(id) on delete cascade,

  postTime    integer,	-- based on postTime the posts are sorted in the thread.
  ReadCount   integer,
  Content     text
);


create index if not exists idxPosts_UserID   on Posts (userID);
create index if not exists idxPosts_ThreadID on Posts (threadID);
create index if not exists idxPosts_Time     on Posts (postTime, id);


create table if not exists Tags (
  Tag	      text primary key,
  Importance  integer not null default 0,
  Description text
);


/* Relation tables */

create table if not exists ThreadTags (
  ThreadID integer references Threads(id) on delete cascade,
  Tag	   text references Tags(Tag) on delete cascade on update cascade
);


create unique index idxThreadTagsUnique on ThreadTags ( ThreadID, Tag );


create table if not exists UnreadPosts (
  UserID integer references Users(id) on delete cascade,
  PostID integer references Posts(id) on delete cascade,
  Time	 integer
);


create unique index idxUnreadPosts on UnreadPosts(UserID, PostID);


create table if not exists Attachements (
  id	   integer primary key autoincrement,
  postID   integer references Posts(id) on delete cascade,
  filename text,
  notes    text,
  file	   blob
);



create table if not exists Sessions (
  userID    integer references Users(id) on delete cascade,
  fromIP    text,
  sid	    text,
  last_seen integer,
  ticket    text,
  unique (userID, fromIP)
);



create table if not exists Messages (
  id	 text primary key,
  msg	 text,
  header text,
  link	 text
);



insert or ignore into Messages VALUES ('login_bad_password','Login incorrect.
Only perfect spellers may
enter this system.','Incorrect user or password!',NULL);


insert or ignore into Messages VALUES ('register_passwords_different','Passwords different.
Only perfect spellers may
register this forum.','Not matching passwords!',NULL);


insert or ignore into Messages VALUES ('register_short_pass','Short password
has been chosen. However,
I disagree !','The password is too short!',NULL);


insert or ignore into Messages VALUES ('login_missing_data','So many fields,
you have to fill.
Missed some.','Empty field!',NULL);


insert or ignore into Messages VALUES ('register_user_exists','With this nickname
you will never succeed!
It is taken.','Not available nickname!',NULL);


insert or ignore into Messages VALUES ('register_short_name','Short nick is not an
advantage, but burden.
Get longer.','The nickname too short!',NULL);


insert or ignore into Messages VALUES ('register_short_email','Queer email,
never saw alike before.
Don''t like it!','Too short email address!',NULL);


insert or ignore into Messages VALUES ('register_technical','Foreboding of evil,
quick shadow in very cold day.
A server is dying.','Server problem!',NULL);


insert or ignore into Messages VALUES ('user_created','Just step remains,
the secret, magic mail
you shall receive.','Yes!','<a target="_self" href="/list/">Home</a>');


insert or ignore into Messages VALUES ('congratulations','It happened,
the journey ended at the door.
You''re welcome.','Hooray!','<a target="_self" href="/login/">Come in</a>');


insert or ignore into Messages VALUES ('bad_secret','Defeats and wins
take turns each other.
Now is the first.','Oh, no!','<a target="_self" href="/list/">Home</a>');


insert or ignore into Messages VALUES ('login_bad_permissions','You are a sinner,
because some man of power
have banned you.','Forbidden!',NULL);


insert or ignore into Messages VALUES ('error_cant_post','You can''t post here,
still have no privileges.
Or have no longer.','Missing privileges!',NULL);


insert or ignore into Messages VALUES ('error_cant_create_threads','New thread,
new hurricane of passions,
but not for you.','Can''t start threads!',NULL);


insert or ignore into Messages VALUES ('register_bad_email','This email
does not looks like real.
It shall not pass!','Invalid email address!',NULL);


insert or ignore into Messages VALUES ('error_post_not_exists','With searching comes loss
and the presence of absence:
post not exists.','Missing post!',NULL);


insert or ignore into Messages VALUES ('error_cant_write','Write has failed.
I can''t tell you where or why.
Lazy programmers.','Unknown error!',NULL);


insert or ignore into Messages VALUES ('error_thread_not_exists','With searching comes loss
and the presence of absence:
thread not exists.','Missing thread!',NULL);


insert or ignore into Messages VALUES ('error_invalid_caption','The title is
missing, it''s pointless
to post, after all.','Empty title!',NULL);


insert or ignore into Messages VALUES ('error_invalid_content','Silence is golden.
But try to be silent without
posting void.','Empty post body!',NULL);


insert or ignore into Messages VALUES ('register_bot','Attempt to cheat
was miserable failure.
So, shame on you!','Cheat attempt detected!',NULL);


insert or ignore into Messages VALUES ('error_bad_ticket','Simple, deep, and still.
The old masters were patient.
Without desires.','Can''t post right now!',NULL);


insert or ignore into Messages VALUES ('password_changed','Your worthy password,
successfully has been changed.
You''r on the safe side.','Pasword changed!','<a target="_self" href="/login/">Login</a>');


insert or ignore into Messages VALUES ('change_different','Passwords different.
Only perfect spellers may
change their password.','Not matching passwords!',NULL);


insert or ignore into Messages VALUES ('change_password','Your present password,
you must provide as evidence
of your intentions.','Password does not match!',NULL);


insert or ignore into Messages VALUES ('email_activation_sent','The secret token
was sent to your new email.
To check the channel.','Check your mailbox!',NULL);


insert or ignore into Messages VALUES ('email_changed','The new address to send
a messages will never change
the old relationship.','E-mail has been changed!','<a target="_self" href="/list/">Home</a>');



create table if not exists FileCache (
  filename  text primary key,
  content   blob,
  changed   integer
);


create table if not exists Events (
  id   integer primary key autoincrement,
  name text
);


insert or ignore into Events values (1,'ScriptStart');
insert or ignore into Events values (2,'RequestStart');
insert or ignore into Events values (3,'RequestEnd');
insert or ignore into Events values (4,'Error');
insert or ignore into Events values (5,'ScriptEnd');
insert or ignore into Events values (6,'ThreadStart');
insert or ignore into Events values (7,'ThreadEnd');
insert or ignore into Events values (8,'RequestServeStart');
insert or ignore into Events values (9,'RequestServeEnd');



create table if not exists Log (
  process_id integer,				 -- the unique process id
  timestamp  integer,
  event      integer references events(id),	 -- what event is logged - start process, end process, start request, end request
  value      text,				 -- details in variable form.
  runtime    integer
);



create table if not exists ProcessID (
  id integer primary key autoincrement
);


create table if not exists Templates (
  id text primary key,
  template text
);


CREATE VIRTUAL TABLE PostFTS using fts5( `Content`, content=Posts, content_rowid=id, tokenize='porter unicode61 remove_diacritics 1');


CREATE TRIGGER PostsAI AFTER INSERT ON Posts BEGIN
  INSERT INTO PostFTS(rowid, Content) VALUES (new.id, new.Content);
END;

CREATE TRIGGER PostsAD AFTER DELETE ON Posts BEGIN
  INSERT INTO PostFTS(PostFTS, rowid, Content) VALUES('delete', old.id, old.Content);
END;

CREATE TRIGGER PostsAU AFTER UPDATE ON Posts BEGIN
  INSERT INTO PostFTS(PostFTS, rowid, Content) VALUES('delete', old.id, old.Content);
  INSERT INTO PostFTS(rowid, Content) VALUES (new.id, new.Content);
END;




COMMIT;
