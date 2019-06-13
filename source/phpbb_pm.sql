attach 'fasm2.sqlite' as phpbb;

drop table if exists privmsgs;

create table privmsgs(
  id integer primary key autoincrement,
  type integer,
  subject text,
  fromid integer,
  toid integer,
  time integer,
  message text
);

insert into privmsgs(type, subject, fromid, toid, time, message)
select
  m.privmsgs_type,
  phpbb(privmsgs_subject),
  privmsgs_from_userid,
  privmsgs_to_userid,
  privmsgs_date,
  phpbb(privmsgs_text)
from
  phpbb_privmsgs m
left join
  phpbb_privmsgs_text t on m.privmsgs_id = t.privmsgs_text_id;

create index idxPrivTo on privmsgs(toid, type);
create index idxPrivFrom on privmsgs(fromid, type);


create trigger lat_threads after insert on threads begin
  update threads set slug = new.slug || '.' || new.id where id = new.id;
  insert into LimitedAccessThreads(threadid, userid) values (new.id, new.userid);
end;

create trigger lat_threads2 after update on threads begin
  insert or ignore into posts(threadid, userid, posttime, format, content)
  select
    new.id,
    fromid,
    time,
    1,
    '[c]Subject: [/c]' || subject || '

' || message
  from
    privmsgs
  where
    toid = new.userid and type in (0, 1, 3, 5)
  order by time;
end;



insert into threads (slug, caption, lastchanged, userid, limited)
select
  'phpbb-pm-archive-inbox',
  'phpBB PM archive INBOX',
  strftime('%s', 'now'),
  id,
  1
from
  users u where exists (select 1 from phpbb_privmsgs pm where pm.privmsgs_to_userid = u.id and  pm.privmsgs_type in (0, 1, 3, 5));


drop trigger lat_threads2;

create trigger lat_threads2 after update on threads begin
  insert or ignore into posts(threadid, userid, posttime, format, content)
  select
    new.id,
    fromid,
    time,
    1,
'[c]Subject: [/c]' || subject || '

[c]     To: [/c]' || (select nick from users where id = toid) || '

' || message
  from
    privmsgs
  where
    fromid = new.userid and type in (2, 4)
  order by time;
end;


insert into threads (slug, caption, lastchanged, userid, limited)
select
  'phpbb-pm-archive-sent',
  'phpBB PM archive SENT',
  strftime('%s', 'now'),
  id,
  1
from
  users u where exists (select 1 from phpbb_privmsgs pm where pm.privmsgs_to_userid = u.id and  pm.privmsgs_type in (2, 4));


drop trigger lat_threads;
drop trigger lat_threads2;
drop table if exists privmsgs;
