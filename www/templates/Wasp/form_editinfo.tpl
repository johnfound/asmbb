<form class="user_edit_info settings" method="post" action="/!userinfo/[username]">
  <h2>User description:<span class="small"> (Formatted text)</span></h2>
  <textarea class="user_desc" name="user_desc">[user_desc]</textarea>
  [case:[special:isadmin]|
  <h2>User permissions:</h2>
  <table><tr>
    <td>
      <input type="checkbox" [user_perm0]  name="user_perm" id="up0"  value="1"><label for="up0">Login</label>
      <input type="checkbox" [user_perm1]  name="user_perm" id="up1"  value="2"><label for="up1">Read</label>
      <input type="checkbox" [user_perm2]  name="user_perm" id="up2"  value="4"><label for="up2">Post</label>
      <input type="checkbox" [user_perm3]  name="user_perm" id="up3"  value="8"><label for="up3">Start threads</label>
    </td><td>
      <input type="checkbox" [user_perm4]  name="user_perm" id="up4"  value="16"><label for="up4">Edit own posts</label>
      <input type="checkbox" [user_perm5]  name="user_perm" id="up5"  value="32"><label for="up5">Edit all posts</label>
      <input type="checkbox" [user_perm6]  name="user_perm" id="up6"  value="64"><label for="up6">Delete own posts</label>
      <input type="checkbox" [user_perm7]  name="user_perm" id="up7"  value="128"><label for="up7">Delete all posts</label>
    </td><td>
      <input type="checkbox" [user_perm8]  name="user_perm" id="up8"  value="256"><label for="up8">Chat</label>
      <input type="checkbox" [user_perm9]  name="user_perm" id="up9"  value="512"><label for="up9">Download files</label>
      <input type="checkbox" [user_perm10] name="user_perm" id="up10" value="1024"><label for="up10">Attach files</label>
      <input type="checkbox" [user_perm31] name="user_perm" id="up31" value="$80000000"><label for="up31">Administrator</label>
  </tr></table>
  ]
  <input type="hidden" name="ticket" value="[Ticket]">
  <input type="submit" name="save" class="submit" value="Save">
</form>

<form class="user_edit_info settings" method="post" enctype="multipart/form-data" action="/!avatar_upload/[username]">
  <h2>Avatar:<span class="small">(.png only; Maximal size: 10KB; Size: 128x128px)</span></h2>
  <input type="file" class="browse" name="avatar">
  <input type="hidden" name="ticket" value="[Ticket]">
  <input type="submit" name="submit" class="submit" value="Upload">
</form>

<form class="user_edit_info settings" method="post" action="/!setskin/[username]">
  <h2>Forum skin:</h2>
  <select class="skin" name="skin">
    <option value="0">(Default)</option>
    [special:skins=[skin]]
  </select>
  <input type="hidden" name="ticket" value="[Ticket]">
  <input type="submit" name="save" class="submit" value="Save">
</form>


[case:[sql: select ? = ?|[userid]|[special:userid]]| |
<form class="user_edit_pass settings" method="post" action="/!changepassword">
  <h2>Change password:</h2>
  <input type="password" value="" placeholder="Present password" name="oldpass" class="password" maxlength="1024" autocomplete="off">
  <input type="password" value="" placeholder="New password" name="newpass" class="password" maxlength="1024" autocomplete="off">
  <input type="password" value="" placeholder="New password again" name="newpass2" class="password" maxlength="1024" autocomplete="off">
  <input type="hidden" name="ticket" value="[Ticket]">
  <input type="submit" name="changepass" class="submit" value="Change password">
</form>

<form class="user_edit_pass settings" method="post" action="/!changemail">
  <h2>Change e-mail:</h2>
  <input type="password" value="" placeholder="Password" name="password" class="password" maxlength="1024" autocomplete="off">
  <input type="text" value="[email]" placeholder="New e-mail" name="email" class="email" maxlength="320">
  <input type="hidden" name="ticket" value="[Ticket]">
  <input type="submit" name="changeemail" class="submit" value="Change email">
</form>
]
