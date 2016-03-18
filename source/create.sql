BEGIN TRANSACTION;

/* Data tables */

create table if not exists Params (
  id  text primary key,
  val text
);


INSERT INTO `Params` VALUES ('host','board.asm32.info');
INSERT INTO `Params` VALUES ('email','admin');
INSERT INTO `Params` VALUES ('smtp_ip','164.138.218.50');
INSERT INTO `Params` VALUES ('smtp_port','25');


create table if not exists Users (
  id	    integer primary key autoincrement,
  nick	    text unique,
  passHash  text unique,
  salt	    text unique,
  status    integer,	     -- see permXXXXX constants.
  user_desc text,	     -- free text user description.
  email     text unique      -- user email
);



create table if not exists WaitingActivation(
  id integer primary key,
  nick text unique,
  passHash text unique,
  salt	text unique,
  email text unique,
  ip_from text,
  time_reg   integer,
  time_email integer,
  a_secret text unique
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



create table if not exists Tags (
  id	      integer primary key autoincrement,
  Tag	      text,
  Description text
);


/* Relation tables */

create table if not exists ThreadTags (
  ThreadID integer references Threads(id),
  TagID    integer references Tags(id)
);


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



CREATE TABLE "messages" (
	`id`	text,
	`msg`	text,
	`header`	TEXT,
	`link`	TEXT,
	PRIMARY KEY(id)
)

INSERT INTO `messages` VALUES ('login_bad_password','Bad password or user name.', 'ERROR!', NULL);
INSERT INTO `messages` VALUES ('login_missing_data','Missing data in login field.', 'ERROR!', NULL);
INSERT INTO `messages` VALUES ('register_passwords_different','The confirmation password does not match.', 'ERROR!', NULL);
INSERT INTO `messages` VALUES ('register_short_pass','The password is too short.', 'ERROR!', NULL);
INSERT INTO `messages` VALUES ('register_user_exists','User name already exists.', 'ERROR!', NULL);
INSERT INTO `messages` VALUES ('register_short_name','User name too short.', 'ERROR!', NULL);
INSERT INTO `messages` VALUES ('register_short_email','User email address invalid.', 'ERROR!', NULL);


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
