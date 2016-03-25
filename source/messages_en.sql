INSERT OR REPLACE INTO `Messages` VALUES ('login_bad_password','Login incorrect.
Only perfect spellers may
enter this system.','Incorrect user or password!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('register_passwords_different','Passwords different.
Only perfect spellers may
register this forum.','Not matching passwords!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('register_short_pass','Short password 
has been chosen. However,
I disagree !','The password is too short!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('login_missing_data','So many fields, 
you have to fill.
Missed some.','Empty field!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('register_user_exists','With this nickname
you will never succeed!
It is taken.','Not available nickname!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('register_short_name','Short nick is not an 
advantage, but burden.
Get longer.','The nickname too short!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('register_short_email','Queer email,
never saw alike before.
Don''t like it!','Too short email address!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('register_technical','Foreboding of evil,
quick shadow in very cold day.
A server is dying.

','Server problem!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('user_created','Just step remains,
the secret, magic mail
you shall receive.','Yes!','<a target="_self" href="/list/">Home</a>');
INSERT OR REPLACE INTO `Messages` VALUES ('congratulations','It happened, 
the journey ended at the door.
You''re welcome.
','Hooray!','<a target="_self" href="/login/">Come in</a>');
INSERT OR REPLACE INTO `Messages` VALUES ('bad_secret','Defeats and wins 
take turns each other.
Now is the first.
','Oh, no!','<a target="_self" href="/list/">Home</a>');
INSERT OR REPLACE INTO `Messages` VALUES ('login_bad_permissions','You are a sinner,
because some man of power
have banned you.','Forbidden!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('error_cant_post','You can''t post here, 
still have no privileges.
Or have no longer.

','Missing privileges!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('error_cant_create_threads','New thread,
new hurricane of passions,
but not for you.','Can''t start threads!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('register_bad_email','This email 
does not looks like real.
It shall not pass!','Invalid email address!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('error_post_not_exists','With searching comes loss
and the presence of absence:
post not exists.','Missing post!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('error_cant_write','Write has failed.
I can''t tell you where or why.
Lazy programmers.

','Unknown error!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('error_thread_not_exists','With searching comes loss
and the presence of absence:
thread not exists.','Missing thread!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('error_invalid_caption','The title is
missing, it''s pointless 
to post, after all.','Empty title!',NULL);
INSERT OR REPLACE INTO `Messages` VALUES ('error_invalid_content','Silence is golden.
But try to be silent without 
posting void.','Empty post body!',NULL);
CREATE INDEX idxUsers_nick  on Users (nick);
CREATE INDEX idxUsers_email on Users (email);
CREATE UNIQUE INDEX idxUnreadPosts on UnreadPosts(UserID, PostID);
CREATE INDEX idxThreads_Slug	  on Threads (Slug);
CREATE INDEX idxThreads_LastChanged on Threads (LastChanged desc);
CREATE INDEX idxPosts_UserID   on Posts (userID);
CREATE INDEX idxPosts_Time     on Posts (postTime, id);
CREATE INDEX idxPosts_ThreadID on Posts (threadID);
COMMIT;
