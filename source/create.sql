BEGIN TRANSACTION;

/* Data tables */

create table Params (
  id  text primary key,
  val text
);


insert into Params values ('user_perm', 1887);  -- permLogin + permRead + permPost + permThreadStart + permEditOwn + permDelOwn + permChat + permDownload + permAttach
insert into Params values ('anon_perm', 3);     -- permLogin + permRead
insert into Params values ('log_events', 0);
insert into Params values ('chat_enabled', 1);
insert into Params values ('default_skin', 'Wasp');
insert into Params values ('default_mobile_skin', 'mobile');
insert into Params values ('email_confirm', 1);
insert into Params values ('forum_header', '<img src="/images/title.svg" alt=
" ▄▄             ▄▄▄  ▄▄▄ Power
█  █ ▄▄▄▄ ▄▄▄▄▄ █  █ █  █
█▄▄█ █▄▄▄ █ █ █ █▀▀▄ █▀▀▄
█  █ ▄▄▄█ █ █ █ █▄▄▀ █▄▄▀
">
);

create table Guests (
  addr     integer primary key not null,
  LastSeen integer,
  Client   text
);

create index idxGuests_time on Guests(LastSeen);
create index idxGuestsDesc on Guests(addr desc);

create table GuestRequests (
  addr integer references Guests(addr) on delete cascade,
  time integer,
  method text,
  request text,
  referer text,
  client text
);

create index idxGuestRequests on GuestRequests(addr);


create table Users (
  id        integer primary key autoincrement,
  nick      text unique collate nocase,
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

-- create index idxUsers_nick on Users (nick collate nocase); - not needed because of the UNIQUE clause.
create index idxUsers_email on Users (email);
create index idxUsersX on Users(id, nick, avatar);
create index idxUsers_LastSeen on Users(LastSeen);

CREATE TABLE UserLog (
  userID integer,
  remoteIP integer,
  Time integer,
  Activity integer,
  Param integer,
  Client text,
  foreign key (userID) references Users(id) on delete cascade on update cascade
);

create index idxUserLogIP on userlog(remoteIP);
create index idxUserLogTime on UserLog(time);  -- Any other index on UserLog ruins the performance. See users_online.sql for the query.

create table WaitingActivation (
  a_secret text primary key,
  operation integer not null,    -- 0 = Registering account; 1 = change email; 2 = reseting password.
  nick text unique collate nocase,
  passHash text unique,
  salt  text unique,
  email text unique,
  ip_from    integer not null,
  time_reg   integer,
  time_email integer
);


create table Threads (
  id          integer primary key autoincrement,
  Slug        text unique,
  Caption     text,
  LastChanged integer,
  UserID      integer references Users(id),
  Pinned      integer default 0
);

create index idxThreadsPinnedLastChanged on Threads (Pinned desc, LastChanged desc);
create index idxThreadsSlug on Threads (Slug);


create table ThreadsHistory (
  threadid    integer,
  Slug        text,
  Caption     text,
  LastChanged integer,
  UserID      integer,
  Pinned      integer
);

-- in order to avoid duplicated information in the history.
create unique index idxThreadsHistory on ThreadsHistory(Slug, Caption, Pinned);

create trigger ThreadsAU after update of Slug, Caption, UserID, Pinned on Threads begin
  insert or ignore into ThreadsHistory(threadid, Slug, Caption, LastChanged, Pinned) values (
    old.id,
    old.Slug,
    old.Caption,
    old.LastChanged,
    old.Pinned
  );
end;

create trigger ThreadsAD after delete on Threads begin
  insert or ignore into ThreadsHistory(threadid, Slug, Caption, LastChanged, Pinned) values (
    old.id,
    old.Slug,
    old.Caption,
    old.LastChanged,
    old.Pinned
  );
end;


create table Posts (
  id          integer primary key autoincrement,
  threadID    integer references Threads(id) on delete cascade,
  userID      integer references Users(id) on delete cascade,
  postTime    integer,
  editUserID  integer default NULL references Users(id) on delete cascade,
  editTime    integer default NULL,
  Content     text,
  Rendered    text
);


create index idxPosts_UserID   on Posts (userID);
create index idxPosts_ThreadID on Posts (threadID);
create index idxPostsThreadUser on posts(threadid, userid);


create table PostCnt (
  postID integer references Posts(id) on delete cascade on update cascade,
  count  integer
);

create index idxPostCount on PostCnt(postid);

create table PostsHistory (
  postID     integer,
  threadID   integer,
  userID     integer,
  postTime   integer,
  editUserID integer,
  editTime   integer,
  Content  text
);

create unique index idxPostsHistory on PostsHistory(postID, Content);

CREATE VIRTUAL TABLE PostFTS using fts5(Content, Caption, slug, User, Tags, prefix="1 2 3", tokenize='porter unicode61 remove_diacritics 1');

CREATE TRIGGER PostsAI AFTER INSERT ON Posts BEGIN
  insert into PostFTS(rowid, Content, Caption, slug, user, tags) VALUES (
    new.id,
    new.Content,
    (select Caption from Threads where id=new.threadid),
    (select slug from Threads where id = new.threadid),
    (select nick from users where id = new.userid),
    (select group_concat(TT.Tag, ", ") from ThreadTags TT where TT.threadID = new.threadid)
  );
  insert into PostCNT(postid,count) VALUES (new.id, 0);
  update Users set PostCount = PostCount + 1 where Users.id = new.UserID;
END;

CREATE TRIGGER PostsAD AFTER DELETE ON Posts BEGIN
  delete from PostFTS where rowid = old.id;
  delete from PostCNT where postid = old.id;
  update Users set PostCount = PostCount - 1 where Users.id = old.UserID;

  insert or ignore into PostsHistory(postID, threadID, userID, postTime, editUserID, editTime, Content) values (
    old.id,
    old.threadID,
    old.userID,
    old.postTime,
    old.editUserID,
    old.editTime,
    old.Content
  );
END;

CREATE TRIGGER PostsAU AFTER UPDATE OF Content, editTime, editUserID, threadID ON Posts BEGIN
  update PostFTS set
    rowid = new.id,
    Content = new.Content,
    Caption = (select Caption from Threads where id=new.threadid),
    slug = (select slug from Threads where id = new.threadid),
    user = (select nick from users where id = new.userid),
    tags = (select group_concat(TT.Tag, ", ") from ThreadTags TT where TT.threadID = new.threadid)
  where rowid = old.id;
  insert or ignore into PostsHistory(postID, threadID, userID, postTime, editUserID, editTime, Content) values (
    old.id,
    old.threadID,
    old.userID,
    old.postTime,
    old.editUserID,
    old.editTime,
    old.Content
  );
END;


create table LimitedAccessThreads (
  threadID integer references Threads(id) on delete cascade,
  userID   integer references Users(id) on delete cascade
);

create unique index idxLimitedAccessThreads on LimitedAccessThreads(threadID, userID);


create table Tags (
  Tag         text primary key,
  Importance  integer not null default 0,
  Description text
);

create index idxTagImportance on Tags(Importance desc);
create index idxTagsTagImp on Tags(tag, importance desc);


/* Relation tables */

create table ThreadTags (
  ThreadID integer references Threads(id) on delete cascade,
  Tag      text references Tags(Tag) on delete cascade on update cascade
);

create unique index idxThreadTagsUnique on ThreadTags ( ThreadID, Tag );
create index idxThreadsTagsTags on ThreadTags (Tag);


create table UnreadPosts (
  UserID integer references Users(id) on delete cascade,
  PostID integer references Posts(id) on delete cascade,
  Time   integer
);


create unique index idxUnreadPosts on UnreadPosts(UserID, PostID);
create index idxUnreadPostsPostID on UnreadPosts(PostID);


create table Attachments (
  id       integer primary key autoincrement,
  postID   integer references Posts(id) on delete cascade,
  filename text,
  changed  integer,
  file     blob,
  key      blob,        -- the random key for xor encrypting the blob
  md5sum   text
);

create index idxAttachments on Attachments(postID);
create unique index idxAttachmentsUnique on Attachments(postID, md5sum);

create table AttachCnt (
  fileID integer references Attachments(id) on delete cascade,
  count  integer not null default 0
);

create index idxAttachCnt on AttachCnt(fileID);

create trigger AttachmentsAI after insert on Attachments begin
  insert into AttachCnt(fileid, count) VALUES (new.id, 0);
end;



create table Sessions (
  id        integer primary key autoincrement,
  userID    integer references Users(id) on delete cascade on update cascade,
  fromIP    text,
  fromPort  integer,
  sid       text,
  last_seen integer,
  unique (userID, fromIP)
);


create index idxSessions_UserID on Sessions(UserID);
create index idxSessions_Sid on Sessions(sid);


create table Tickets (
  ssn     integer references Sessions(id) on delete cascade on update cascade,
  time    integer,
  ticket  text unique
);

create index idxTickets_time on Tickets(time);


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


insert into Messages VALUES ('missing_query','Looking for something,
Unknown but so desired.
Do meditate first.
','What are you looking for?',NULL);

insert into Messages VALUES ('cant_read','Knocking on the door
Please introduce yourself.
Are you expected?
','Private place!','<a href="/!login">Login first</a>');


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


create table ScratchPad (
  name   text primary key not null,
  source text
);


create table BadCookies (
  cookie text,
  agent  text,
  remote text
);


create table ChatLog (
  id          integer primary key autoincrement,
  time        integer,
  user        text,
  original    text,
  Message     text
);


create table EventSessions (
  session     text unique not null,
  time        integer,
  username    text,
  original    text,
  status      integer
);


create index idxEventSessionsTime on EventSessions(time);
create index idxEventSessionsOrig on EventSessions(original);

create table EventQueue (
  id         integer primary key autoincrement,
  type       integer,
  event      text,
  receiver   text    -- the sessionID of the receiver. If NULL then broadcast to all subscribed.
);



COMMIT;
