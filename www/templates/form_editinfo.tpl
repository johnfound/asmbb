<form class="user_edit_info" method="post" action="/!userinfo/[username]">
  <label>Avatar:<span class="small"> (base64 encoded image, 128x128px native size)</span></label>
  <textarea class="avatar" name="avatar">[avatar]</textarea>
  <label>User description:<span class="small"> (formatted text)</span></label>
  <textarea class="user_desc" name="user_desc">[user_desc]</textarea>
  <input type="submit" name="save" class="submit" value="Save">
</form>

[case:[sql: select [userid] = [special:userid]]| |
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