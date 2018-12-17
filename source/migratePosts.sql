PRAGMA foreign_keys;
PRAGMA foreign_keys = OFF;
PRAGMA foreign_keys;

begin transaction;

create table Posts2 (
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

insert into Posts2
  (id, threadID, userID, anon, postTime, editUserID, editTime, format, Content)
select id, threadID, userID, NULL, postTime, editUserID, editTime, 0, Content from Posts;

select count() from Posts2;
select count() from Posts;

drop table Posts;

select count() from PostCnt;

alter table Posts2 rename to Posts;

create index idxPosts_UserID   on Posts (userID);
create index idxPosts_ThreadID on Posts (threadID);
create index idxPostsThreadUser on posts(threadid, userid);


create table PostsHistory2 (
  postID     integer,
  threadID   integer,
  userID     integer,
  anon       text,
  postTime   integer,
  editUserID integer,
  editTime   integer,
  format     integer,
  Content    text
);

insert into PostsHistory2 (postID, threadID, userID, anon, postTime, editUserID, editTime, format, Content)
select postID, threadID, userID, NULL, postTime, editUserID, editTime, format, Content from PostsHistory;

drop table PostsHistory;
alter table PostsHistory2 rename to PostsHistory;

create unique index idxPostsHistory on PostsHistory(postID, Content);

select count() from PostsHistory;


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
END;

CREATE TRIGGER PostsAD AFTER DELETE ON Posts BEGIN
  delete from PostFTS where rowid = old.id;
  update Users set PostCount = PostCount - 1 where Users.id = old.UserID;
  update Threads set PostCount = PostCount - 1 where id = old.threadID;
  delete from ThreadPosters where threadid = old.threadid and userid = old.userid;
  insert into ThreadPosters(firstPost, threadID, userID) select min(id), threadid, userid from posts where threadid = old.threadid and userid = old.userid;

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
END;




PRAGMA foreign_key_check;

rollback;

PRAGMA foreign_keys = ON;
PRAGMA foreign_keys;
