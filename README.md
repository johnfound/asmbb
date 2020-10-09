# AsmBB forum engine

## What is AsmBB?

AsmBB is a modern web forum engine, written entirely in assembly language
([FlatAssembler aka FASM](https://flatassembler.net))

AsmBB is high performance and lightweight web application.  

It can work on a really weak web server and in the same time to serve huge 
amount of visitors without lags and delays.

AsmBB uses [SQLite](https://sqlite.org) with [SQLeet](https://github.com/resilar/sqleet) extension
as a back-end storage database and FastCGI interface to the web server.

In addition, because of the very few dependencies and the very aggressive testing,
AsmBB is highly secure forum engine. 

In fact, so far, there is no major security issues and
only several minor issues, already fixed.

Also, AsmBB can use encrypted database, this way, protecting the forum information even
in cases of very serious server security breaches.

AsmBB is open source project, distributed under the terms of EUPL-1.1 license.

The source code is managed by a [fossil-scm](https://fossil-scm.org/) repository at address: [https://asm32.info/fossil/asmbb/]

There is a read-only [mirror on GitHub](https://github.com/johnfound/asmbb) as well.

## Recuirements

AsmBB has very few requirements to the running environment:

   - x86 Linux server. No matter 32 or 64bit. No need to have any specially preinstalled libraries.
     The smallest/cheapest VPS is fine. Shared hosting is fine as well (if supports FastCGI).

   - A web server supporting FastCGI interface. 
     AsmBB has been tested with Nginx, Apache, Lighttpd, Hiawatha and of course RWASA. 

## Demo installation

There is a demo and support forum of the project, running on [https://board.asm32.info](https://board.asm32.info).

