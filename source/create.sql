BEGIN TRANSACTION;

/* Data tables */

create table Counters (
  id text primary key,
  val integer default 0
) without rowid;

insert into Counters(id) values ('posts'), ('threads');


create table Params (
  id  text primary key,
  val text
) without rowid;

insert into Params values ('default_lang', 0);
insert into Params values ('user_perm', 1887);  -- permLogin + permRead + permPost + permThreadStart + permEditOwn + permDelOwn + permChat + permDownload + permAttach
insert into Params values ('anon_perm', 3);     -- permLogin + permRead
insert into Params values ('chat_enabled', 1);
insert into Params values ('default_skin', 'Wasp');
insert into Params values ('default_mobile_skin', 'mobile');
insert into Params values ('email_confirm', 1);
insert into Params values ('forum_header', '<img src="/images/title.svg" alt=
" ▄▄             ▄▄▄  ▄▄▄ Power
█  █ ▄▄▄▄ ▄▄▄▄▄ █  █ █  █
█▄▄█ █▄▄▄ █ █ █ █▀▀▄ █▀▀▄
█  █ ▄▄▄█ █ █ █ █▄▄▀ █▄▄▀
">'
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

create index idxUsersRegister on Users(Register);
create index idxUsers_email on Users(email);
create index idxUsersX on Users(id, nick, avatar);
create index idxUsers_LastSeen on Users(LastSeen);
create index idxUsersBack on Users(id desc);

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
  Pinned      integer default 0,
  PostCount   integer default 0,
  ReadCount   integer default 0,
  Limited     integer default 0
);

create index idxThreadsPinnedLastChangedLimited on threads (Limited, Pinned desc, Lastchanged desc);
create index idxThreadsPinnedLastChanged on Threads (Pinned desc, Lastchanged desc);  -- needed for the old threadlist sql!
create index idxThreadsLimitedLastChanged on Threads(Limited, LastChanged desc);
create index idxThreadsSlug on Threads (Slug);

create table ThreadPosters (
  firstPost   integer references Posts(id) on delete cascade on update cascade,
  threadID    integer references Threads(id) on delete cascade on update cascade,
  userID      integer references Users(id) on delete cascade on update cascade
);

create unique index idxThreadPosters on ThreadPosters(threadID, userID);
create index idxThreadPostersOrder on ThreadPosters(threadid, firstPost, userid);


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

create trigger ThreadsAI after insert on Threads begin
  update Counters set val = val + 1 where id = 'threads';
end;

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
  update Counters set val = val - 1 where id = 'threads';
end;


create table Posts (
  id          integer primary key autoincrement,
  threadID    integer references Threads(id) on delete cascade,
  userID      integer references Users(id) on delete cascade,
  anon        text,
  postTime    integer,
  editUserID  integer default NULL references Users(id) on delete cascade,
  editTime    integer default NULL,
  format      integer,
  Content     text
);


create index idxPosts_UserID   on Posts (userID);
create index idxPosts_ThreadID on Posts (threadID);
create index idxPostsThreadUser on posts(threadid, userid);
create index idxPosts_ThreadID_ID on Posts(threadID, id);


create table PostCnt (
  postID integer references Posts(id) on delete cascade on update cascade,
  count  integer
);

create index idxPostCount on PostCnt(postid);

create table PostsHistory (
  postID     integer,
  threadID   integer,
  userID     integer,
  anon       text,
  postTime   integer,
  editUserID integer,
  editTime   integer,
  format     integer,
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
    ifnull((select nick from users where id = new.userid), new.anon),
    (select group_concat(TT.Tag, ", ") from ThreadTags TT where TT.threadID = new.threadid)
  );
  insert into PostCNT(postid,count) VALUES (new.id, 0);
  insert or ignore into ThreadPosters(firstPost, threadID, userID) values (new.id, new.threadID, new.userID);

  update Users set PostCount = PostCount + 1 where Users.id = new.UserID;
  update Threads set PostCount = PostCount + 1 where id = new.threadID;
  update Counters set val = val + 1 where id = 'posts';
  update Tags set PostCnt = PostCnt + 1 where Tags.tag in (select tag from ThreadTags where ThreadID = new.ThreadID);
END;

CREATE TRIGGER PostsAD AFTER DELETE ON Posts BEGIN
  delete from PostFTS where rowid = old.id;
  delete from ThreadPosters where threadid = old.threadid and userid = old.userid;
  insert or ignore into ThreadPosters(firstPost, threadID, userID) select min(id), threadid, userid from posts where threadid = old.threadid and userid = old.userid;

  update Users set PostCount = PostCount - 1 where Users.id = old.UserID;
  update Threads set PostCount = PostCount - 1 where id = old.threadID;
  update Counters set val = val - 1 where id = 'posts';
  update Tags set PostCnt = PostCnt - 1 where Tags.tag in (select tag from threadtags where threadid = old.threadid);

  insert or ignore into PostsHistory(postID, threadID, userID, anon, postTime, editUserID, editTime, format, Content) values (
    old.id,
    old.threadID,
    old.userID,
    old.anon,
    old.postTime,
    old.editUserID,
    old.editTime,
    old.format,
    old.Content
  );
END;

CREATE TRIGGER PostsAU AFTER UPDATE OF Content, editTime, editUserID, threadID, format ON Posts BEGIN
  update PostFTS set
    rowid = new.id,
    Content = new.Content,
    Caption = (select Caption from Threads where id=new.threadid),
    slug = (select slug from Threads where id = new.threadid),
    user = ifnull((select nick from users where id = new.userid), new.anon),
    tags = (select group_concat(TT.Tag, ", ") from ThreadTags TT where TT.threadID = new.threadid)
  where rowid = old.id;
  insert or ignore into PostsHistory(postID, threadID, userID, anon, postTime, editUserID, editTime, format, Content) values (
    old.id,
    old.threadID,
    old.userID,
    old.anon,
    old.postTime,
    old.editUserID,
    old.editTime,
    old.format,
    old.Content
  );
  update Threads set PostCount = PostCount - 1 where id = old.threadID;
  update Threads set PostCount = PostCount + 1 where id = new.threadID;

  update Tags set PostCnt = PostCnt - 1 where tags.tag in (select tag from threadtags where threadid = old.threadid);
  update Tags set PostCnt = PostCnt + 1 where tags.tag in (select tag from threadtags where threadid = new.threadid);
END;


create table LimitedAccessThreads (
  threadID integer references Threads(id) on delete cascade,
  userID   integer references Users(id) on delete cascade,
  LastChanged integer default 0
);

create unique index idxLimitedAccessThreads on LimitedAccessThreads(threadID, userID);
create index idxLimitedAccessThreadsLastChanged on LimitedAccessThreads(LastChanged desc);
create index idxLimitedAccessThreadsUserLastChanged on LimitedAccessThreads(userID, LastChanged desc);


create trigger LimitedAccessThreadsAI after insert on LimitedAccessThreads begin
  update LimitedAccessThreads set LastChanged = (select LastChanged from threads where id = new.threadid);
end;


create table Tags (
  Tag         text primary key,
  Importance  integer default 0,
  ThreadCnt   integer default 0,
  PostCnt     integer default 0,
  Description text
) without rowid;

create index idxTagImportance on Tags(Importance desc);
create index idxTagsTagImp on Tags(tag, importance desc);


/* Relation tables */

create table ThreadTags (
  ThreadID integer references Threads(id) on delete cascade,
  Tag      text references Tags(Tag) on delete cascade on update cascade,
  Pinned   integer default 0,
  LastChanged integer default 0,
  Limited     integer default 0
);

create unique index idxThreadTagsUnique on ThreadTags ( ThreadID, Tag );

-- no need for so many indixes!!!???
create index idxThreadsTagsTags on ThreadTags (Tag);
create index idxThreadTagsTagLimitedPinnedLastChanged ON ThreadTags(Tag, Limited, Pinned desc, LastChanged desc);
create index idxThreadTagsTagPinnedLastChanged on ThreadTags(tag, pinned desc, lastchanged desc);
create index idxThreadTagsLimitedTag on ThreadTags(Limited, tag);
create index idxThreadTagsLimitedTagThread on ThreadTags (Limited, tag, threadid);
create index idxThreadTagsTagLimitedLastChanged on ThreadTags (tag, Limited, LastChanged desc);


CREATE TRIGGER ThreadTagsAI AFTER INSERT ON ThreadTags BEGIN
  update Tags set ThreadCnt = ThreadCnt + 1 where tag = new.tag;
END;

CREATE TRIGGER ThreadTagsAD AFTER DELETE ON ThreadTags BEGIN
  update Tags set ThreadCnt = ThreadCnt - 1 where tag = old.tag;
END;

CREATE TRIGGER ThreadTagsAU AFTER UPDATE OF Tag, Limited ON ThreadTags BEGIN
  update Tags set ThreadCnt = ThreadCnt - 1 where tag = old.tag;
  update Tags set ThreadCnt = ThreadCnt + 1 where tag = new.tag;
END;

CREATE TRIGGER ThreadsAUtt AFTER UPDATE OF LastChanged, Pinned, Limited ON Threads BEGIN
  update threadtags set LastChanged = new.LastChanged, Pinned = new.Pinned, Limited = new.Limited where threadid = new.id;
  update LimitedAccessThreads set LastChanged = new.LastChanged where threadid = new.id;
END;


create table UnreadPosts (
  UserID integer references Users(id) on delete cascade,
  PostID integer references Posts(id) on delete cascade,
  ThreadID integer references Threads(id) on delete cascade on update cascade,
  Time   integer
);


create unique index idxUnreadPosts on UnreadPosts(UserID, PostID);
create index idxThreadUnread on UnreadPosts(userID, threadID);
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


insert into Messages VALUES ('register_user_exists','Maybe the nickname,
or maybe the email,
is already taken.','Not available nickname or email!',NULL);


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

insert into Messages VALUES ('closed_registration','This very place
Is not a place for you.
Go elsewhere now.
','Closed forum!','<a href="https://duckduckgo.com">A good place to start</a>');


create table ScratchPad (
  name   text primary key not null,
  source text
);


create table ChatLog (
  id          integer primary key autoincrement,
  time        integer,
  user        text,
  original    text,
  Message     text
);


create table EventSessions (
  session     text primary key not null,
  username    text,
  original    text,
  status      integer,
  events      integer default 0
) without rowid;


create table EventQueue (
  id         integer primary key autoincrement,
  type       integer,
  event      text,
  receiver   text    -- the sessionID of the receiver. If NULL then broadcast to all subscribed.
);


COMMIT;
