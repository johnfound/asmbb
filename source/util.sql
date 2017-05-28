/* This file contains some useful scripts for administration of AsmBB forum using the SQLite console. */

-- Displays a report about the Guests active from the last 5 minutes.

select datetime(LastSeen, 'unixepoch') as Date, (addr >> 24 & 255)||'.'||(addr >> 16 & 255)||'.'||(addr >> 8 & 255)||'.'||(addr & 255) as IP, Client
from Guests where LastSeen > strftime('%s', 'now') - 300 order by LastSeen;


/* Rebuilds the full text search table */

drop table PostFTS;
CREATE VIRTUAL TABLE PostFTS using fts5( Content, content=Posts, content_rowid=id, tokenize='porter unicode61 remove_diacritics 1');
insert into PostFTS(rowid, Content) select id, Content from Posts;


