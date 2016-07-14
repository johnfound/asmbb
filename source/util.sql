/* This file contains some useful scripts for administration of AsmBB forum using the SQLite console. */

-- Displays the IP addresses of the active guests from the last 5 minutes.

select (addr >> 24 & 255)||'.'||(addr >> 16 & 255)||'.'||(addr >> 8 & 255)||'.'||(addr & 255)
from Guests where LastSeen > strftime('%s', 'now') - 300;

select (addr >> 24 & 255)||'.'||(addr >> 16 & 255)||'.'||(addr >> 8 & 255)||'.'||(addr & 255) as IP, datetime(LastSeen, 'unixepoch')
from Guests order by lastseen;

