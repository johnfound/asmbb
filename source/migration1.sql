BEGIN;

-- Create the new table and index.

create table PostCnt (
  postID integer references Posts(id) on delete cascade on update cascade,
  count  integer
);

create index idxPostCount on PostCnt(postid);

-- Recreate the triggers on Posts

drop trigger PostsAI;
drop trigger PostsAD;

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
END;


-- Copy the values from Posts to PostCNT

insert into PostCnt(postid, count) select id, ReadCount from Posts;

-- Fix the WaitingActivation table to less restrictive settings.

drop table WaitingActivation;

create table WaitingActivation(
  id integer primary key,
  nick text unique,
  passHash text unique,
  salt  text unique,
  email text unique,
  ip_from text,
  time_reg   integer,
  time_email integer,
  a_secret text unique
);

create index idxUserLogIP on userlog(remoteIP);


-- new sessions/ticket table

drop index idxSessions_UserID;
drop index idxSessions_Sid;

create table Sessions2 (
  id        integer primary key autoincrement,
  userID    integer references Users(id) on delete cascade on update cascade,
  fromIP    text,
  sid       text,
  last_seen integer,
  unique (userID, fromIP)
);

insert into Sessions2(userID, fromIP, sid, last_seen) select userID, fromIP, sid, last_seen from Sessions;

drop table Sessions;

alter table Sessions2 rename to Sessions;

create index idxSessions_UserID on Sessions(UserID);
create index idxSessions_Sid on Sessions(sid);

create table Tickets (
  ssn     integer references Sessions(id) on delete cascade on update cascade,
  time    integer,
  ticket  text unique
);

create index idxTickets_time on Tickets(time);

COMMIT;