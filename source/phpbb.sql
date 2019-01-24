-- The first attempt to port phpbb forum to AsmBB forum database.
-- Experimental, Not stable, not working! Need to be finished.

attach 'phpbb.sqlite' as phpbb;

begin;

-- drop all indices:

drop index idxGuests_time;
drop index idxGuestsDesc;
drop index idxGuestRequests;
drop index idxUsers_email;
drop index idxUsersX;
drop index idxUsers_LastSeen;
drop index idxUsersBack;
drop index idxUserLogIP;
drop index idxUserLogTime;
drop index idxThreadsPinnedLastChanged;
drop index idxThreadsSlug;
drop index idxThreadPosters;
drop index idxThreadPostersOrder;
drop index idxThreadsHistory;
drop index idxPosts_UserID;
drop index idxPosts_ThreadID;
drop index idxPostsThreadUser;
drop index idxPostCount;
drop index idxPostsHistory;
drop index idxLimitedAccessThreads;
drop index idxTagImportance;
drop index idxTagsTagImp;
drop index idxThreadTagsUnique;
drop index idxThreadsTagsTags;
drop index idxThreadTagsTagPinnedLastChanged;
drop index idxUnreadPosts;
drop index idxThreadUnread;
drop index idxUnreadPostsPostID;
drop index idxAttachments;
drop index idxAttachmentsUnique;
drop index idxAttachCnt;
drop index idxSessions_UserID;
drop index idxSessions_Sid;
drop index idxTickets_time;
drop index idxEventSessionsTime;
drop index idxEventSessionsOrig;

-- drop all triggers

drop trigger ThreadsAU;
drop trigger ThreadsAD;
drop trigger PostsAI;
drop trigger PostsAD;
drop trigger PostsAU;
drop trigger AttachmentsAI;
drop trigger ThreadTagsAI;
drop trigger ThreadTagsAU;
drop trigger ThreadTagsAD;
drop trigger ThreadsAUtt;


-- Start copy data

delete from users where status <> -1;   -- delete all but the admin.

insert into users (id, nick, passhash, email, user_desc, status, Register, LastSeen, PostCount)
select
  user_id,
  username,
  user_password || '|' || lower(hex(randomblob(8))),
  (user_email) as email,
  (' [' || user_website || '][Home page]

Location: ' || user_from || '

Signature:

' || user_sig ) as user_desc,
  1887 as status,
  user_regdate,
  user_lastvisit,
  user_posts
from
  phpbb_users
where user_id <> 3688;  -- this user has duplicated email address.

insert into users (id, nick, passhash, email, user_desc, status, Register, LastSeen, PostCount)
select
  user_id,
  username,
  user_password || '|' || lower(hex(randomblob(8))),
  'conflicting_email@conflicting.com' as email,
  ('[' || user_website || '][Home page]
Location: ' || user_from || '
Signature: ' || user_sig ) as user_desc,
  1887 as status,
  user_regdate,
  user_lastvisit,
  user_posts
from
  phpbb_users
where user_id = 3688;  -- this user has duplicated email address.


create index phpbb.phpbbPostTopic on phpbb_posts(topic_id);


delete from threads;

insert into threads(id, slug,  Caption, LastChanged, UserID, Pinned, PostCount, ReadCount)
select
  topic_id as id,
  (slugify(topic_title) || "." || topic_id) as slug,
  phpbb(topic_title) as Caption,
  topic_time as LastChanged,
  (select poster_id from phpbb_posts p where p.topic_id = t.topic_id order by p.post_id limit 1) as UserID,
  topic_type as Pinned,
  topic_replies+1 as PostCount,
  topic_views as ReadCount
from
  phpbb_topics t
where t.topic_status <> 2;


delete from posts;

insert into posts(id, threadID, userID, anon, postTime, editUserID, editTime, format, Content)
select
  p.post_id as id,
  topic_id as threadID,
  poster_id as userID,
  null,
  post_time as postTime,
  null,
  null,
  1,
  phpbb(post_text)
from
  phpbb_posts p left join phpbb_posts_text t on p.post_id = t.post_id;



delete from tags;

insert into tags(tag, Description, Importance)
select tagify(forum_name), forum_desc, 100*(5-cat_id) - forum_order as importance from phpbb_forums order by cat_id, forum_order;

delete from threadtags;

insert into threadtags(threadID, tag)
select
  topic_id,
  (select tagify(forum_name) from phpbb_forums f where t.forum_id = f.forum_id) as tag
from
  phpbb_topics t
where t.topic_status <> 2;


-- Private messages!!!

create unique index idxLimitedAccessThreads on LimitedAccessThreads(threadID, userID);

create index phpbb.idx3 on phpbb_privmsgs(privmsgs_id);
create index phpbb.idx4 on phpbb_privmsgs_text(privmsgs_text_id);

create table privmsgs(
  id integer primary key autoincrement,
  type integer,
  subject text,
  fromid integer,
  toid integer,
  time integer,
  message text
);

insert into privmsgs(subject, fromid, toid, time, message)
select
  slugify(phpbb(privmsgs_subject)),
  privmsgs_from_userid,
  privmsgs_to_userid,
  privmsgs_date,
  phpbb(privmsgs_text)
from
  phpbb_privmsgs m
left join
  phpbb_privmsgs_text t on m.privmsgs_id = t.privmsgs_text_id
where
  m.privmsgs_type in (0, 1, 5);


create index idx1 on privmsgs(fromid);
create index idx2 on privmsgs(toid);


create trigger lat_posts after insert on posts begin
  insert or ignore into LimitedAccessThreads(threadid, userid) values (new.threadid, new.userid);
  insert or ignore into LimitedAccessThreads(threadid, userid) values (new.threadid, new.format);
  update posts set format = 1 where id = new.id;
end;

create trigger lat_threads after insert on threads begin
  update threads set slug = new.slug || '.' || new.id where id = new.id;
end;

create trigger lat_threads2 after update on threads begin
  insert or ignore into posts(threadid, userid, posttime, format, content)
  select
    new.id,
    fromid,
    time,
    toid,
    message
  from
    privmsgs
  where
    fromid = new.userid and subject = old.slug
  union
  select
    new.id,
    fromid,
    time,
    toid,
    message
  from
    privmsgs
  where
    (fromid = new.userid or toid = new.userid) and subject = 're-' || old.slug
  order by time;
end;


-- The constants for the privmsgs_type field:
-- PRIVMSGS_READ_MAIL = 0
-- PRIVMSGS_NEW_MAIL = 1
-- PRIVMSGS_SENT_MAIL = 2
-- PRIVMSGS_SAVED_IN_MAIL = 3
-- PRIVMSGS_SAVED_OUT_MAIL = 4
-- PRIVMSGS_UNREAD_MAIL = 5

CREATE INDEX phpbb.phpbb_privmsgs_idx_fbae154c ON phpbb_privmsgs(privmsgs_type);

insert or ignore into threads(slug, caption, lastchanged, userid)
select
  slugify(phpbb(privmsgs_subject)),
  phpbb(privmsgs_subject),
  privmsgs_date,
  privmsgs_from_userid
from
  phpbb_privmsgs
where
  privmsgs_type in (0, 1, 5) and privmsgs_subject not like 'Re: %';


drop trigger lat_threads2;
drop trigger lat_threads;
drop trigger lat_posts;

drop index idx1;
drop index idx2;
drop index phpbb.idx3;
drop index phpbb.idx4;

drop table privmsgs;


-- Attachments:

create index idxAttachments on attached_files(id);

delete from attachments;

insert or ignore into attachments (id, postid, filename, changed, file, key, md5sum)
select
  a.attach_id,
  a.post_id,
  d.real_filename,
  d.filetime,
  f.file,
  randomblob(256) as key,
  md5(f.file)
from
  phpbb_attachments a
left join
  phpbb_attachments_desc d on d.attach_id = a.attach_id
left join
  attached_files f on f.id = a.attach_id;

-- encrypt files

update attachments set file = xorblob(file, key);

delete from AttachCnt;
insert into AttachCnt(fileid, count)
select
  a.id,
  d.download_count
from
  attachments a left join phpbb_attachments_desc d on a.id = d.attach_id;



-- recreate the indices

create index idxGuests_time on Guests(LastSeen);
create index idxGuestsDesc on Guests(addr desc);
create index idxGuestRequests on GuestRequests(addr);
create index idxUsers_email on Users (email);
create index idxUsersX on Users(id, nick, avatar);
create index idxUsers_LastSeen on Users(LastSeen);
create index idxUsersBack on Users(id desc);
create index idxUserLogIP on userlog(remoteIP);
create index idxUserLogTime on UserLog(time);  -- Any other index on UserLog ruins the performance. See users_online.sql for the query.
create index idxThreadsPinnedLastChanged on Threads (Pinned desc, LastChanged desc);
create index idxThreadsSlug on Threads (Slug);
create unique index idxThreadPosters on ThreadPosters(threadID, userID);
create index idxThreadPostersOrder on ThreadPosters(threadid, firstPost, userid);
create unique index idxThreadsHistory on ThreadsHistory(Slug, Caption, Pinned);
create index idxPosts_UserID   on Posts (userID);
create index idxPosts_ThreadID on Posts (threadID);
create index idxPostsThreadUser on posts(threadid, userid);
create index idxPostCount on PostCnt(postid);
create unique index idxPostsHistory on PostsHistory(postID, Content);
create index idxTagImportance on Tags(Importance desc);
create index idxTagsTagImp on Tags(tag, importance desc);
create unique index idxThreadTagsUnique on ThreadTags ( ThreadID, Tag );
create index idxThreadsTagsTags on ThreadTags (Tag);
create index idxThreadTagsTagPinnedLastChanged on ThreadTags(tag, pinned desc, lastchanged desc);
create unique index idxUnreadPosts on UnreadPosts(UserID, PostID);
create index idxThreadUnread on UnreadPosts(userID, threadID);
create index idxUnreadPostsPostID on UnreadPosts(PostID);
create index idxAttachments on Attachments(postID);
create unique index idxAttachmentsUnique on Attachments(postID, md5sum);
create index idxAttachCnt on AttachCnt(fileID);
create index idxSessions_UserID on Sessions(UserID);
create index idxSessions_Sid on Sessions(sid);
create index idxTickets_time on Tickets(time);
create index idxEventSessionsTime on EventSessions(time);
create index idxEventSessionsOrig on EventSessions(original);


-- Update the full text search table.

drop table if exists PostFTS;
CREATE VIRTUAL TABLE PostFTS using fts5(Content, Caption, slug, User, Tags, prefix="1 2 3", tokenize='porter unicode61 remove_diacritics 1');

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

-- clean up history

delete from ThreadsHistory;
delete from PostsHistory;

-- update all the fields normally updated by the triggers.

delete from threadposters;
insert into threadposters(firstPost,threadid, userid)
select
  min(id),
  threadid,
  userid
from
  posts
group by
  threadid,
  userid;

update Users set PostCount = (select count() from Posts P where P.userid = Users.id);

update Threads set
  PostCount = (select count() from Posts P where P.threadid = Threads.id),
  Limited = exists (select 1 from LimitedAccessThreads LA where LA.threadid = id),
  LastChanged = (select ifnull(editTime, postTime) from posts p where p.threadID = threads.id order by p.id desc limit 1);

update ThreadTags set
  Pinned = (select Pinned from threads where id = threadid),
  LastChanged = (select LastChanged from threads where id = threadid),
  Limited = (select Limited from threads where id = threadid);

update Tags set
  TCnt = (select count() from threadtags tt where tt.tag = tags.tag and tt.limited = 0)
, LCnt = (select count() from threadtags tt where tt.tag = tags.tag and tt.limited <> 0)
, PTCnt = (select count() from posts P left join threadtags tt on tt.threadid = P.threadid where tt.tag = tags.tag and tt.limited = 0)
, PLCnt = (select count() from posts P left join threadtags tt on tt.threadid = P.threadid where tt.tag = tags.tag and tt.limited <> 0);


-- recreate the triggers

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
  update Tags set PTCnt = PTCnt + 1 where tags.tag in (select tag from threadtags where threadid = new.threadid and limited = 0);
  update Tags set PLCnt = PLCnt + 1 where tags.tag in (select tag from threadtags where threadid = new.threadid and limited <> 0);
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
  update Counters set val = val - 1 where id = 'posts';
  update Tags set PTCnt = PTCnt - 1 where tags.tag in (select tag from threadtags where threadid = old.threadid and limited = 0);
  update Tags set PLCnt = PLCnt - 1 where tags.tag in (select tag from threadtags where threadid = old.threadid and limited <> 0);
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

  update Tags set PTCnt = PTCnt - 1 where tags.tag in (select tag from threadtags where threadid = old.threadid and limited = 0);
  update Tags set PLCnt = PLCnt - 1 where tags.tag in (select tag from threadtags where threadid = old.threadid and limited <> 0);
  update Tags set PTCnt = PTCnt + 1 where tags.tag in (select tag from threadtags where threadid = new.threadid and limited = 0);
  update Tags set PLCnt = PLCnt + 1 where tags.tag in (select tag from threadtags where threadid = new.threadid and limited <> 0);
END;

CREATE TRIGGER ThreadTagsAI AFTER INSERT ON ThreadTags BEGIN
  update Tags set TCnt = TCnt + (new.Limited = 0), LCnt = LCnt + (new.Limited <> 0) where tag = new.tag;
END;

CREATE TRIGGER ThreadTagsAD AFTER DELETE ON ThreadTags BEGIN
  update Tags set TCnt = TCnt - (old.Limited = 0), LCnt = LCnt - (old.Limited <> 0) where tag = old.tag;
END;

CREATE TRIGGER ThreadTagsAU AFTER UPDATE OF Tag, Limited ON ThreadTags BEGIN
  update Tags set TCnt = TCnt - (old.Limited = 0), LCnt = LCnt - (old.Limited <> 0) where tag = old.tag;
  update Tags set TCnt = TCnt + (new.Limited = 0), LCnt = LCnt + (new.Limited <> 0) where tag = new.tag;
END;

CREATE TRIGGER ThreadsAUtt AFTER UPDATE OF LastChanged, Pinned, Limited ON Threads BEGIN
  update threadtags set LastChanged = new.LastChanged, Pinned = new.Pinned, Limited = new.Limited where threadid = new.id;
  update LimitedAccessThreads set LastChanged = new.LastChanged where threadid = new.id;

  update Tags set PTCnt = PTCnt - (old.limited = 0)*(select count() from posts where threadid = old.id) where tag in (select tag from threadtags tt where tt.threadid = old.id);
  update Tags set PTCnt = PTCnt + (new.limited = 0)*(select count() from posts where threadid = new.id) where tag in (select tag from threadtags tt where tt.threadid = new.id);

  update Tags set PLCnt = PLCnt - (old.limited <> 0)*(select count() from posts where threadid = old.id) where tag in (select tag from threadtags tt where tt.threadid = old.id);
  update Tags set PLCnt = PLCnt + (new.limited <> 0)*(select count() from posts where threadid = new.id) where tag in (select tag from threadtags tt where tt.threadid = new.id);
END;


create trigger AttachmentsAI after insert on Attachments begin
  insert into AttachCnt(fileid, count) VALUES (new.id, 0);
end;



commit;

