update
  Posts
set
  threadID = ?1,
  userID = ?2,
  postTime = ?3,
  editUserID = ?4,
  editTime = ?5,
  Content = ?6,
  Rendered = ?7
where
  id = ?8;
