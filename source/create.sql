BEGIN TRANSACTION;

/* Data tables */

create table Params (
  id  text primary key,
  val text
);


insert into Params values ('user_perm', '29');  -- permLogin + permPost + permThreadStart + permEditOwn
insert into Params values ('log_events', '0');


create table Guests (
  addr     integer primary key not null,
  LastSeen integer
);

create index idxGuests_time on Guests(LastSeen);


create table Users (
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

create index idxUsers_nick on Users (nick);
create index idxUsers_email on Users (email);
create index idxUsersX on Users(id, nick, avatar);
create index idxUsers_LastSeen on Users(LastSeen);


CREATE TABLE UserLog (
  userID integer,
  remoteIP integer,
  Time integer,
  Activity integer,
  Param integer,
  foreign key (userID) references Users(id) on delete cascade on update cascade
);

create index idxUserLogTime on UserLog(time);
create index idxUserLogUserIP on UserLog(UserID, remoteIP);
create index idxUserLogUserID on UserLog(UserID);


create table WaitingActivation(
  id integer primary key,
  nick text unique,
  passHash text unique,
  salt  text unique,
  email text unique,
  ip_from text unique,
  time_reg   integer,
  time_email integer,
  a_secret text unique
);



create table Threads (
  id          integer primary key autoincrement,
  Slug        text unique,
  Caption     text,
  LastChanged integer,
  Pinned      integer default 0
);

create index idxThreadsPinnedLastChanged on Threads (Pinned desc, LastChanged desc);
create index idxThreadsSlug on Threads (Slug);



create table Posts (
  id          integer primary key autoincrement,
  threadID    integer references Threads(id) on delete cascade,
  userID      integer references Users(id) on delete cascade,

  postTime    integer,  -- based on postTime the posts are sorted in the thread.
  ReadCount   integer,
  Content     text,
  Rendered    text
);


create index idxPosts_UserID   on Posts (userID);
create index idxPosts_ThreadID on Posts (threadID);
create index idxPostsThreadUser on posts(threadid, userid);


create table Tags (
  Tag         text primary key,
  Importance  integer not null default 0,
  Description text
);


/* Relation tables */

create table ThreadTags (
  ThreadID integer references Threads(id) on delete cascade,
  Tag      text references Tags(Tag) on delete cascade on update cascade
);


create unique index idxThreadTagsUnique on ThreadTags ( ThreadID, Tag );


create table UnreadPosts (
  UserID integer references Users(id) on delete cascade,
  PostID integer references Posts(id) on delete cascade,
  Time   integer
);


create unique index idxUnreadPosts on UnreadPosts(UserID, PostID);
create index idxUnreadPostsPostID on UnreadPosts(PostID);

create table Attachements (
  id       integer primary key autoincrement,
  postID   integer references Posts(id) on delete cascade,
  filename text,
  notes    text,
  file     blob
);



create table Sessions (
  userID    integer references Users(id) on delete cascade,
  fromIP    text,
  sid       text,
  last_seen integer,
  ticket    text,
  unique (userID, fromIP)
);


create index idxSessions_UserID on Sessions(UserID);
create index idxSessions_Sid on Sessions(sid);


create table Messages (
  id     text primary key,
  msg    text,
  header text,
  link   text
);


insert into Messages VALUES ('login_bad_password','Login incorrect.
Only perfect spellers may
enter this system.','Incorrect user or password!',NULL);


insert into Messages VALUES ('register_passwords_different','Passwords different.
Only perfect spellers may
register this forum.','Not matching passwords!',NULL);


insert into Messages VALUES ('register_short_pass','Short password
has been chosen. However,
I disagree !','The password is too short!',NULL);


insert into Messages VALUES ('login_missing_data','So many fields,
you have to fill.
Missed some.','Empty field!',NULL);


insert into Messages VALUES ('register_user_exists','With this nickname
you will never succeed!
It is taken.','Not available nickname!',NULL);


insert into Messages VALUES ('register_short_name','Short nick is not an
advantage, but burden.
Get longer.','The nickname too short!',NULL);


insert into Messages VALUES ('register_short_email','Queer email,
never saw alike before.
Don''t like it!','Too short email address!',NULL);


insert into Messages VALUES ('register_technical','Foreboding of evil,
quick shadow in very cold day.
A server is dying.','Server problem!',NULL);


insert into Messages VALUES ('user_created','Just step remains,
the secret, magic mail
you shall receive.','Yes!','<a href="/">Home</a>');


insert into Messages VALUES ('congratulations','It happened,
the journey ended at the door.
You''re welcome.','Hooray!','<a href="/!login/">Come in</a>');


insert into Messages VALUES ('bad_secret','Defeats and wins
take turns each other.
Now is the first.','Oh, no!','<a href="/">Home</a>');


insert into Messages VALUES ('login_bad_permissions','You are a sinner,
because some man of power
have banned you.','Forbidden!',NULL);


insert into Messages VALUES ('error_cant_post','You can''t post here,
still have no privileges.
Or have no longer.','Missing privileges!',NULL);


insert into Messages VALUES ('error_cant_create_threads','New thread,
new hurricane of passions,
but not for you.','Can''t start threads!',NULL);


insert into Messages VALUES ('register_bad_email','This email
does not looks like real.
It shall not pass!','Invalid email address!',NULL);


insert into Messages VALUES ('error_post_not_exists','With searching comes loss
and the presence of absence:
post not exists.','Missing post!',NULL);


insert into Messages VALUES ('error_cant_write','Write has failed.
I can''t tell you where or why.
Lazy programmers.','Unknown error!',NULL);


insert into Messages VALUES ('error_thread_not_exists','With searching comes loss
and the presence of absence:
thread not exists.','Missing thread!',NULL);


insert into Messages VALUES ('error_invalid_caption','The title is
missing, it''s pointless
to post, after all.','Empty title!',NULL);


insert into Messages VALUES ('error_invalid_content','Silence is golden.
But try to be silent without
posting void.','Empty post body!',NULL);


insert into Messages VALUES ('register_bot','Attempt to cheat
was miserable failure.
So, shame on you!','Cheat attempt detected!',NULL);


insert into Messages VALUES ('error_bad_ticket','Simple, deep, and still.
The old masters were patient.
Without desires.','Can''t post right now!',NULL);


insert into Messages VALUES ('password_changed','Your worthy password,
successfully has been changed.
You''r on the safe side.','Pasword changed!','<a href="/!login/">Login</a>');


insert into Messages VALUES ('change_different','Passwords different.
Only perfect spellers may
change their password.','Not matching passwords!',NULL);


insert into Messages VALUES ('change_password','Your present password,
you must provide as evidence
of your intentions.','Password does not match!',NULL);


insert into Messages VALUES ('email_activation_sent','The secret token
was sent to your new email.
To check the channel.','Check your mailbox!',NULL);


insert into Messages VALUES ('email_changed','The new address to send
a messages will never change
the old relationship.','E-mail has been changed!','<a href="/">Home</a>');


insert into Messages VALUES ('error_cant_delete','You can''t delete it,
still have no privileges.
Or have no longer.','Missing privileges!',NULL);


insert into Messages VALUES ('only_for_admins','Too dangerous place.
Not allowed to enter right now.
Maybe some day...
','For administrators only!','<a href="/">Home</a>');




create table Log (
  process_id integer,   -- the unique process id
  timestamp  integer,
  event      text,      -- what event is logged - start process, end process, start request, end request
  value      text,      -- details in variable form.
  runtime    integer
);



create table ProcessID (
  id integer primary key autoincrement
);



CREATE VIRTUAL TABLE PostFTS using fts5( Content, content=Posts, content_rowid=id, tokenize='porter unicode61 remove_diacritics 1');


CREATE TRIGGER PostsAI AFTER INSERT ON Posts BEGIN
  insert into PostFTS(rowid, Content) VALUES (new.id, new.Content);
  update Users set PostCount = PostCount + 1 where Users.id = new.UserID;
END;

CREATE TRIGGER PostsAD AFTER DELETE ON Posts BEGIN
  insert into PostFTS(PostFTS, rowid, Content) VALUES('delete', old.id, old.Content);
  update Users set PostCount = PostCount - 1 where Users.id = old.UserID;
END;

CREATE TRIGGER PostsAU AFTER UPDATE ON Posts BEGIN
  INSERT INTO PostFTS(PostFTS, rowid, Content) VALUES('delete', old.id, old.Content);
  INSERT INTO PostFTS(rowid, Content) VALUES (new.id, new.Content);
END;



create table ScratchPad (
  name   text primary key not null,
  source text
);


create table BadCookies (
  cookie text,
  agent  text,
  remote text
);

COMMIT;
