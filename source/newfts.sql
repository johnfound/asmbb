drop trigger PostsAI;
drop trigger PostsAD;
drop trigger PostsAU;

drop table PostFTS;

CREATE VIRTUAL TABLE
  PostFTS using fts5(Content, Caption, slug, User, Tags, prefix="1 2 3", tokenize='porter unicode61 remove_diacritics 1');

CREATE TRIGGER PostsAI AFTER INSERT ON Posts BEGIN
  insert into PostFTS(rowid, Content, Caption, slug, user, tags) VALUES (
    new.id,
    new.Content,
    (select Caption from Threads where id=new.threadid),
    (select slug from Threads where id = new.threadid),
    (select nick from users where id = new.userid),
    (select group_concat(TT.Tag, ", ") from ThreadTags TT where TT.threadID = new.threadid)
  );
  update Users set PostCount = PostCount + 1 where Users.id = new.UserID;
END;

CREATE TRIGGER PostsAD AFTER DELETE ON Posts BEGIN
  delete from PostFTS where rowid = old.id;
  update Users set PostCount = PostCount - 1 where Users.id = old.UserID;
END;

CREATE TRIGGER PostsAU AFTER UPDATE ON Posts BEGIN
  update PostFTS set
    rowid = new.id,
    Content = new.Content,
    Caption = (select Caption from Threads where id=new.threadid),
    slug = (select slug from Threads where id = new.threadid),
    user = (select nick from users where id = new.userid),
    tags = (select group_concat(TT.Tag, ", ") from ThreadTags TT where TT.threadID = new.threadid)
  where rowid = old.id;
END;


insert into PostFTS(rowid, Content, Caption, slug, user, tags)
select
  P.id,
  P.Content,
  T.Caption,
  T.slug,
  U.nick,
  (select group_concat(TT.Tag, ", ") from ThreadTags TT where TT.threadID = T.id)
from
  Posts P
left join
  Threads T on T.id = P.threadID
left join
  Users U on U.id = P.userID;


select
  PostFTS.rowid,
  PostFTS.User as UserName,
  P.userID,
  U.av_time as AVer,
  PostFTS.slug,
  strftime('%d.%m.%Y %H:%M:%S', P.postTime, 'unixepoch') as PostTime ,
  P.ReadCount,
  snippet(PostFTS, PostFTS.Content, '', '', '...', 16) as Content,
  PostFTS.Caption,
  (select count() from UnreadPosts UP where UP.UserID = ?6 and UP.PostID = PostFTS.rowid) as Unread
from PostFTS
left join Posts P on P.id = PostFTS.rowid
left join Users U on U.id = P.userID
where
  PostFTS match "Content: test "
limit 20;
