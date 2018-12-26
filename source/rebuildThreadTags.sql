begin transaction;

drop trigger PostsAI;
drop trigger PostsAU;
drop trigger PostsAD;


create table ThreadTags2 (
  ThreadID integer references Threads(id) on delete cascade,
  Tag      text references Tags(Tag) on delete cascade on update cascade,
  pinned   integer default 0,
  LastChanged integer default 0
);

insert into ThreadTags2(ThreadID, Tag, pinned, LastChanged)
select
  threadid,
  tag,
  pinned,
  lastchanged
from
  threadtags
left join
  threads on threadid = id;


drop table ThreadTags;

alter table ThreadTags2 rename to ThreadTags;

create unique index idxThreadTagsUnique on ThreadTags ( ThreadID, Tag );
create index idxThreadsTagsTags on ThreadTags (Tag);
create index idxThreadTagsTagPinnedLastChanged on ThreadTags(tag, pinned desc, lastchanged desc);


CREATE TRIGGER ThreadTagsAI AFTER INSERT ON ThreadTags BEGIN
  update tags set cnt = cnt + 1 where tag = new.tag;
END;

CREATE TRIGGER ThreadTagsAD AFTER DELETE ON ThreadTags BEGIN
  update tags set cnt = cnt - 1 where tag = old.tag;
END;

CREATE TRIGGER ThreadTagsAU AFTER UPDATE OF tag ON ThreadTags BEGIN
  update tags set cnt = cnt - 1 where tag = old.tag;
  update tags set cnt = cnt + 1 where tag = new.tag;
END;

CREATE TRIGGER ThreadsAUtt AFTER UPDATE OF LastChanged, Pinned ON Threads BEGIN
  update threadtags set LastChanged = new.LastChanged, Pinned = new.Pinned where threadid = new.id;
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



commit;
