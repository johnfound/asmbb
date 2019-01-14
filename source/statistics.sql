select
  (select val from Counters where id = 'posts') as posts,
  (select val from Counters where id = 'threads') as threads,
  (select count() from users) as users,
  (select nick from users order by id desc limit 1) as lastuser,
  (select count() from guests where LastSeen > strftime('%s', 'now') - 24*60*60) as guests24;
