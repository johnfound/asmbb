BEGIN TRANSACTION;

/* Data tables */

create table if not exists Users (
  id	    integer primary key autoincrement,
  nick	    text,
  passHash  text,
  status    integer,  -- active, banned, etc.
  user_desc text,     -- free text user description.
  email     text      -- user email
);


INSERT INTO Users VALUES
 (1,'johnfound','',NULL,NULL,'johnfound@asm32.info'),
 (2,'asm_newbee','','','','newbee@asm32.info'),
 (3,'Troll','','','','troll@somewhere.invalid');


create table if not exists Threads (
  id	    integer primary key autoincrement,
  Slug	    text,			-- slugifyed version of the caption. Can be set independently.
  Caption   text,
  StartPost integer references Posts(id)
);


INSERT INTO Threads VALUES
 (1,'welcome', 'Welcome',1),
 (2,'how_to_program_assembly', 'How to program assembly',2);


create table if not exists Posts (
  id	      integer primary key autoincrement,
  threadID    integer references Threads(id),
  userID      integer references Users(id),

  postTime    integer,	-- based on postTime the posts are sorted in the thread.
  Content     text
);


INSERT INTO Posts VALUES
 (1,1,1,1457118799,'Welcome in AsmBB. This is forum engine implemented using assembly language.'),
 (2,2,2,1457118900,'I want to ask a question, about how to program in assembly language.'),
 (3,2,1,1457119000,'It is easy, just install Fresh IDE and start from the examples.'),
 (4,2,3,1457120000,'Asm is dead! Learn better some Java! Java rulez! But C# is also OK.');


create table if not exists Tags (
  id	      integer primary key autoincrement,
  Tag	      text,
  Description text
);

INSERT INTO `Tags` VALUES
 (1,'asm,assembly language,асемблер','The most advanced programming language.'),
 (2,'chat,free talk,heap','Talks for everything'),
 (3,'C,C++,C#','Talks about C/C++/C# languages');


/* Relation tables */

create table if not exists ThreadTags (
  ThreadID integer references Threads(id),
  TagID    integer references Tags(id)
);


INSERT INTO `ThreadTags` VALUES
 (1,2),
 (1,1);


create table if not exists UnreadPosts (
  UserID integer references Users(id),
  PostID integer references Posts(id),
  Time	 integer
);


create table if not exists Attachements (
  postID   integer references Posts(id),
  filename text,
  notes    text,
  file	   blob
);

COMMIT;
