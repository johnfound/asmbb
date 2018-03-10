/* This file contains some useful scripts for administration of AsmBB forum using the SQLite console. */

-- Displays a report about the Guests active from the last 5 minutes.

select datetime(LastSeen, 'unixepoch') as Date, (addr >> 24 & 255)||'.'||(addr >> 16 & 255)||'.'||(addr >> 8 & 255)||'.'||(addr & 255) as IP, Client
from Guests where LastSeen > strftime('%s', 'now') - 300 order by LastSeen;

select
  (g.addr >> 24 & 255)||'.'||(g.addr >> 16 & 255)||'.'||(g.addr >> 8 & 255)||'.'||(g.addr & 255) as IP,
  datetime(g.LastSeen, 'unixepoch') as Time,
  gr.method,
  gr.request,
  gr.client,
  gr.referer
from
  guests g
left join
  guestrequests gr on g.addr = gr.addr
where
  g.rowid in (select rowid from guests order by rowid desc limit 200) and
  IP <> '149.62.201.127';  -- this is the current my IP.

/* Rebuilds the full text search table */

drop table PostFTS;
CREATE VIRTUAL TABLE PostFTS using fts5( Content, content=Posts, content_rowid=id, tokenize='porter unicode61 remove_diacritics 1');
insert into PostFTS(rowid, Content) select id, Content from Posts;



create View PostsView as select P.id, P.Content, P.ThreadID, (select group_concat(Tag, ' ') from ThreadTags TT where TT.ThreadID = P.ThreadID ) as Tags from Posts P;
drop table PostFTS;
CREATE VIRTUAL TABLE PostFTS using fts5( Content, ThreadID, Tags, content=PostsView, content_rowid=id, tokenize='porter unicode61 remove_diacritics 1');
insert into PostFTS(rowid, Content, ThreadID, Tags) select id, Content, ThreadID, Tags from PostsView;


drop table PostFTS;
CREATE VIRTUAL TABLE PostFTS using fts5( Content, ThreadID, UserID, PostTime, ReadCount, Tags, content=Posts, content_rowid=id, tokenize='porter unicode61 remove_diacritics 1');

insert into PostFTS(rowid, Content, ThreadID, UserID, PostTime, ReadCount, Tags)
select P.id, P.Content, P.ThreadID, P.UserID, P.PostTime, P.ReadCount, (select group_concat(Tag, ' ') from ThreadTags TT where TT.ThreadID = P.ThreadID ) as Tags from Posts P;

