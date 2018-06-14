insert or replace into Posts (
  id,
  threadID,
  userID,
  postTime,
  editUserID,
  editTime,
  Content,
  Rendered
) values (
  ?8, ?1, ?2, ?3, ?4, ?5, ?6, ?7
);
