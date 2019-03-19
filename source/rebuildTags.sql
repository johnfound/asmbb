PRAGMA foreign_keys;
PRAGMA foreign_keys = OFF;
PRAGMA foreign_keys;
begin transaction;

drop trigger ThreadTagsAI;
drop trigger ThreadTagsAD;
drop trigger ThreadTagsAU;
drop trigger ThreadsAUtt;

drop trigger PostsAI;
drop trigger PostsAD;
drop trigger PostsAU;


create table Tags2 (
  Tag         text primary key,
  Importance  integer default 0,
  ThreadCnt   integer default 0,
  PostCnt     integer default 0,
  Description text
) without rowid;


insert into Tags2(tag, importance, ThreadCnt, PostCnt, Description)
select
  tag,
  importance,
  (select count() from threadtags tt where tt.tag = tags.tag),
  (select count() from posts P where P.threadid in (select threadid from threadtags tt where tt.tag = tags.tag)),
  Description
from
  tags;

drop table Tags;

alter table Tags2 rename to Tags;

create index idxTagImportance on Tags(Importance desc);
create index idxTagsTagImp on Tags(tag, importance desc);


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





PRAGMA foreign_key_check;

commit;

PRAGMA foreign_keys = ON;
PRAGMA foreign_keys;
