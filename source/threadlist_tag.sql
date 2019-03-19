select
  t.Id,
  t.Slug,
  t.Caption,
  t.Pinned,
  t.LastChanged as TimeChanged,
  t.PostCount,
  t.ReadCount,
  t.Limited,
  (select
     group_concat('<li><a href="/!userinfo/'||url_encode(nick)||'">'||html_encode(nick)||'</a></li>','')
   from (
     select nick from ThreadPosters left join Users on userID = id where threadID = s.threadid order by firstPost limit 20
   )
  ) as Posters,
  NULL as Invited,
  (select group_concat('<li><a href="/'||url_encode(TT.tag)||'/" title="['||TT.tag||'] '|| ifnull(html_encode(TG.description),'') || '">'||TT.tag||'</a></li>','')
  from ThreadTags tt left join tags tg on tg.tag = tt.tag where TT.threadid = s.threadid
  ) as  ThreadTags,
  ifnull(Unread,0) as Unread,
  ifnull(FirstUnread,0) as FirstUnread
from (
  select
    threadid
  from
    threadtags tt
  where
    tag = ?4 and limited = 0
  order by
    Pinned desc, LastChanged desc
  limit ?1
  offset ?2
) as S
left join threads t on t.id = s.threadid
left join (select count() as Unread, min(UP7.PostID) as FirstUnread, UP7.threadid as ti from unreadposts UP7 where userid=?3 group by ti) on ti = s.threadid;
