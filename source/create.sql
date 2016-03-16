BEGIN TRANSACTION;

/* Data tables */

create table if not exists Users (
  id	    integer primary key autoincrement,
  nick	    text unique,
  passHash  text,
  status    integer,  -- active, banned, etc.
  user_desc text,     -- free text user description.
  email     text      -- user email
);


INSERT INTO Users VALUES
 (1,'johnfound','',NULL,NULL,'johnfound@asm32.info'),
 (2,'asm_newbee','','','','newbee@asm32.info'),
 (3,'Troll','','','','troll@somewhere.invalid');


create table if not exists WaitingActivation(
  id integer primary key,
  nick text,
  passHash text,
  salt	text,
  email text,
  time_reg   integer,
  time_email integer,
  a_secret text
);


create table if not exists Threads (
  id	    integer primary key autoincrement,
  Slug	    text,			-- slugifyed version of the caption. Can be set independently.
  Caption   text,
  StartPost integer
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


create table if not exists Sessions (
  userID    integer references Users(id),
  fromIP    text,
  sid	    text,
  last_seen integer,
  unique (userID, fromIP)
);



create table if not exists errors (
  err  text primary key,
  msg  text
);


INSERT INTO `errors` VALUES ('login_bad_password','Bad password or user name.');
INSERT INTO `errors` VALUES ('login_missing_data','Missing data in login field.');
INSERT INTO `errors` VALUES ('register_passwords_different','The confirmation password does not match.');
INSERT INTO `errors` VALUES ('register_short_pass','The password is too short.');
INSERT INTO `errors` VALUES ('register_user_exists','User name already exists.');
INSERT INTO `errors` VALUES ('register_short_name','User name too short.');
INSERT INTO `errors` VALUES ('register_short_email','User email address invalid.');


create table if not exists templates (
  id text primary key,
  template text
);


INSERT INTO templates VALUES ('main_html_start', '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Title</title></head><body><h1>Title</h1><div class="login_interface">$special:loglink$</div>');

INSERT INTO templates VALUES ('main_html_end',	 '<pre>$special:environment$</pre>$special:timestamp$</body></html>');

INSERT INTO templates VALUES ('thread_info', '<div class="thread_summary">
<div class="thread_info">Posts:<br>$PostCount$</div>
<div class="thread_link">
<a class="thread_link" href="/threads/$Slug$/">$Caption$</a>
</div>
</div>'
);

INSERT INTO templates VALUES ('post_view', '<div class="post">
<div class="user_info">
<div class="user_name">$UserName$</div>
<div class="user_pcnt">Posts: $UserPostCount$</div>
</div>
<div class="post_info">Posted: $PostTime$</div>
<div class="post_text">$Content$</div>
</div>'
);

INSERT INTO `templates` VALUES ('login_form','<form class="login-block" method="post" target="_self" action="/login/">
<h1>Login</h1>
<input type="text" value="" placeholder="Username" name="username" id="username" autofocus="on" maxlength="256">
<input type="password" value="" placeholder="Password" name="password" id="password" maxlength="1024">
<input type="submit" name="submit" id="submit" value="Submit">
</form>'
);

INSERT INTO `templates` VALUES ('register_form', '<form class="register-block" method="post" target="_self" action="/register/">
<h1>Register</h1>
<input type="text" value="" placeholder="Username" name="username" id="username" maxlength="256" autofocus="on">
<input type="text" value="" placeholder="e-mail" name="email" id="email" maxlength="320">
<input type="password" value="" placeholder="Password" name="password" id="password" maxlength="1024">
<input type="password" value="" placeholder="Password again" name="password2" id="password2" maxlength="1024">
<input type="submit" name="submit" id="submit" value="Submit">
</form>
');

COMMIT;
