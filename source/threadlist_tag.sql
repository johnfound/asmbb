select
  TT.threadid as id,
  Slug,
  Caption,
  TT.Pinned,
  strftime('%d.%m.%Y %H:%M:%S', TT.LastChanged, 'unixepoch') as TimeChanged,
  T.PostCount,
  Unread,
  FirstUnread,
  ReadCount,
  (select group_concat('<li><a href="/!userinfo/'||url_encode(nick)||'">'||html_encode(nick)||'</a></li>','') from ThreadPosters left join Users on userID = id where threadID = TT.threadid order by firstPost) as Posters,
  (select group_concat('<li><a href="/!userinfo/'||url_encode(nick)||'">'||html_encode(nick)||'</a></li>','') from LimitedAccessThreads left join Users on id = userid where threadID = TT.threadid) as Invited,
  (select group_concat('<li><a href="/'||url_encode(TT2.tag)||'/" title="['||TT2.tag||']">'||TT.tag||'</a></li>','') from ThreadTags TT2 where TT2 = TT.threadid) as ThreadTags,
  LT.userid as limited
from
  ThreadTags TT
left join Threads T on T.id = TT.ThreadID
left join (select count() as Unread, min(UP7.PostID) as FirstUnread, UP7.threadid as ti from unreadposts UP7 where userid=?3 group by ti) on ti = T.id
left join LimitedAccessThreads LT on LT.threadid = T.id
where LT.userid is null or LT.userid = ?3

where TT.tag = ?4

order by TT.pinned desc, TT.LastChanged desc

limit  ?1
offset ?2;
