-- The first attempt to port phpbb forum to AsmBB forum database.
-- Experimental, Not stable, not working! Need to be finished.

attach 'phpbb.sqlite' as phpbb;

insert into users (nick, email, user_desc, status, Register, LastSeen, PostCount)
select
  username,
  (user_email) as email,
  (user_website || x'0d0a' || user_from) as user_desc,
  1887 as status,
  user_regdate,
  user_lastvisit,
  user_posts
from
  phpbb_users
where user_id <> 3688;  -- this user has duplicated email address.


create index phpbb.phpbbPostTopic on phpbb_posts(topic_id);


delete from threads;

insert into threads(id, slug,  Caption, LastChanged, UserID, Pinned, PostCount, ReadCount)
select
  topic_id as id,
  (slugify(topic_title) || "." || topic_id) as slug,
  topic_title as Caption,
  topic_time as LastChanged,
  (select poster_id from phpbb_posts p where p.topic_id = t.topic_id order by p.post_id limit 1) as UserID,
  topic_type as Pinned,
  topic_replies+1 as PostCount,
  topic_views as ReadCount
from
  phpbb_topics t


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
  post_text
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
  phpbb_topics t;


-- Update the threads LastChanged and PostCount fields.

update threads set LastChanged = (select ifnull(editTime, postTime) from posts p where p.threadID = threads.id order by p.id desc limit 1);
update threads set PostCount = (select count() from posts p where p.threadID = threads.id);