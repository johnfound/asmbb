alter table users add LastPostTime integer default 0;
alter table users add PostInterval integer default 0;
alter table users add PostIntervalInc integer default 0;
alter table users add MaxPostLen      integer default 0;

drop trigger PostsAI;

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

  update Users set PostCount = PostCount + 1, LastPostTime = strftime('%s', 'now'), PostInterval = max(0, PostInterval + PostIntervalInc) where Users.id = new.UserID;
  update Threads set PostCount = PostCount + 1 where id = new.threadID;
  update Counters set val = val + 1 where id = 'posts';
  update Tags set PostCnt = PostCnt + 1 where Tags.tag in (select tag from ThreadTags where ThreadID = new.ThreadID);
END;
