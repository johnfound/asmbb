drop trigger if exists ThreadsAI;
drop trigger if exists ThreadsAU;
drop trigger if exists ThreadsAD;
drop trigger if exists PostsAI;
drop trigger if exists PostsAD;
drop trigger if exists PostsAU;
drop trigger if exists LimitedAccessThreadsAI;
drop trigger if exists ThreadTagsAI;
drop trigger if exists ThreadTagsAD;
drop trigger if exists ThreadTagsAU;
drop trigger if exists ThreadsAUtt;
drop trigger if exists AttachmentsAI;

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

create trigger LimitedAccessThreadsAI after insert on LimitedAccessThreads begin
  update LimitedAccessThreads set LastChanged = (select LastChanged from threads where id = new.threadid);
end;

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


create trigger AttachmentsAI after insert on Attachments begin
  insert into AttachCnt(fileid, count) VALUES (new.id, 0);
end;
