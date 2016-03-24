BEGIN TRANSACTION;
CREATE TABLE Messages (
  id	 text primary key,
  msg	 text,
  header text,
  link	 text
);
INSERT INTO `Messages` VALUES ('login_bad_password','Грешна парола,
или юзър. Tака е то.
Опитай пак.','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('register_passwords_different','Двете пароли,
толкова различни са.
Еднакви искам.','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('register_short_pass','Къса парола,
избра си ти. Oбаче,
не съм съгласен!','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('login_missing_data','Полета много
трябва да попълваш,
но има празни.','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('register_user_exists','С това име,
никога няма да стане.
Заето е вече.
','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('register_short_name','Късото име,
не ти дава предимства.
Вземи по-дълго.

','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('register_short_email','Чуден е-мейл,
невиждан досега,
не ми харесва.','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('register_technical','Предчувствие лошо,
бърза сянка в зимния ден.
Умира сървър.
','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('user_created','Малко остана.
Тайната връзка, вълшебна,
дали ще получиш?

(Погледни в пощенската си
кутия за писмо с връзка за
активация на акаунта.)','Да!','<a target="_self" href="/list/">Към началото</a>');
INSERT INTO `Messages` VALUES ('congratulations','Боят завърши.
Самураите за малко спират
на прага.','Ура!','<a target="_self" href="/login/">Добре дошъл</a>');
INSERT INTO `Messages` VALUES ('bad_secret','Редуват се 
в живота поражения с победи. 
Сега е първото.
','К''о? Не!','<a target="_self" href="/list/">Към началото</a>');
INSERT INTO `Messages` VALUES ('login_bad_permissions','Правата да влизаш,
някой ти е взел в потайна доба.
Защо ли?','Забрана!',NULL);
INSERT INTO `Messages` VALUES ('error_cant_post','Да пишеш тук,
все още нямаш право.
Или вече.
','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('error_cant_create_threads','Нова тема,
нови страсти, но 
не за теб.
','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('register_bad_email','Дори на мене,
не ми изглежда добре
твоя адрес.','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('error_post_not_exists','Какъв е резултатът,
след редактиране на 
липсващ пост?
','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('error_cant_write','Не зная защо,
но записът е невъзможен.
Навярно съдба.','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('error_thread_not_exists','       Как да отговориш
    на незададен 
 въпрос,
в тема, 
  която
    липсва?   
','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('error_invalid_caption','Заглавието,
важно е за темата!
Напиши едно.','Проблем!',NULL);
INSERT INTO `Messages` VALUES ('error_invalid_content','Мълчанието е 
злато, но ти мълчиш 
във писмен вид.
','Проблем!',NULL);
CREATE INDEX idxUsers_nick  on Users (nick);
CREATE INDEX idxUsers_email on Users (email);
CREATE UNIQUE INDEX idxUnreadPosts on UnreadPosts(UserID, PostID);
CREATE INDEX idxThreads_Slug	  on Threads (Slug);
CREATE INDEX idxThreads_LastChanged on Threads (LastChanged desc);
CREATE INDEX idxPosts_UserID   on Posts (userID);
CREATE INDEX idxPosts_Time     on Posts (postTime, id);
CREATE INDEX idxPosts_ThreadID on Posts (threadID);
COMMIT;
