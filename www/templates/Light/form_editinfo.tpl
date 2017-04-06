<div class="user_flex">

  <form class="user_edit_info" method="post" action="/!userinfo/[username]">
    <label>User description:<span class="small"> (Formatted text)</span></label>
    <textarea class="user_desc" name="user_desc">[user_desc]</textarea>
    <input type="submit" name="save" class="submit" value="Save">
  </form>

  <div>
    <form class="user_edit_attr" method="post" enctype="multipart/form-data" action="/!avatar_upload/[username]">
      <label>Avatar:<span class="small">(.png only; Maximal size: 10KB; Size: 128x128px)</span></label>
      <input type="file" class="browse" name="avatar">
      <input type="submit" name="submit" class="submit" value="Upload">
    </form>

    <form class="user_edit_attr" method="post" action="/!setskin/[username]">
      <label>Forum skin:</label>
      <select class="skin" name="skin">
        <option value="0">(Default)</option>
        [special:skins]
      </select>
      <input type="submit" name="save" class="submit" value="Save">
    </form>
  </div>

</div>

<div class="user_flex">
  [case:[sql: select ? = ?|[userid]|[special:userid]]| |
  <form class="user_edit_pass" method="post" action="/!changepassword">
    <h1>Change password:</h1>
    <input type="password" value="" placeholder="Present password" name="oldpass" class="password" maxlength="1024">
    <input type="password" value="" placeholder="New password" name="newpass" class="password" maxlength="1024">
    <input type="password" value="" placeholder="New password again" name="newpass2" class="password" maxlength="1024">
    <input type="submit" name="changepass" class="submit" value="Change password">
  </form>

  <form class="user_edit_pass" method="post" action="/!changemail">
    <h1>Change e-mail:</h1>
    <input type="password" value="" placeholder="Password" name="password" class="password" maxlength="1024">
    <input type="text" value="" placeholder="New e-mail" name="email" class="email" maxlength="320">
    <input type="submit" name="changeemail" class="submit" value="Change email">
  </form>
  ]
</div>