[css:settings.css]

<div class="set_page">
[case:[message]|<h1 class="hidden msg">Message</h1>|<h1 id="message" class="msg [case:[error]|info|error]">[message]</h1>]
<form class="settings" method="post" action="/!settings">
  <h1>Forum engine settings</h1>
  <label>Forum title:</label><input type="text" value="[forum_title]" name="forum_title" class="settings" size="30" maxlength="512"><br>
  <label>Description:</label><input type="text" value="[description]" name="description" class="settings" size="30" maxlength="256"><br>
  <label>Keywords:</label><input type="text" value="[keywords]" name="keywords" class="settings" size="30" maxlength="256"><br>
  <br>
  <label>Host:</label><input type="text" value="[host]" name="host" class="settings" size="30" maxlength="320"><br>
  <label>SMTP server/port:</label><input type="text" value="[smtp_addr]" name="smtp_addr" class="settings" size="20" maxlength="256"><input type="text" value="[smtp_port]" name="smtp_port" class="settings" size="5" maxlength="5"><br>
  <label>SMTP account:</label><input type="text" value="[smtp_user]" name="smtp_user" class="settings" size="30" maxlength="256"><br>
  <label>Page length:</label><input type="text" value="[page_length]" name="page_length" class="settings" size="30" maxlength="256"><br>
  <label>Default skin:</label><select class="settings" name="default_skin" size:"20">[special:skins=[default_skin]]</select><br>
  <label>Default mobile skin:</label><select class="settings" name="default_mobile_skin">[special:skins=[default_mobile_skin]]</select><br><br>

  <label>Default user permissions:</label><table>
  <tr><td>
  <label class="checkbox"><input type="checkbox" [user_perm0] name="user_perm0" value="1" class="checkbox"><span>&nbsp;</span> Login</label><br>
  <label class="checkbox"><input type="checkbox" [user_perm2] name="user_perm2" value="4" class="checkbox"><span>&nbsp;</span> Post</label><br>
  <label class="checkbox"><input type="checkbox" [user_perm3] name="user_perm3" value="8" class="checkbox"><span>&nbsp;</span> Start threads</label><br>
  <label class="checkbox"><input type="checkbox" [user_perm4] name="user_perm4" value="16" class="checkbox"><span>&nbsp;</span> Edit own posts</label><br>
  <label class="checkbox"><input type="checkbox" [user_perm8] name="user_perm8" value="256" class="checkbox"><span>&nbsp;</span> Chat</label><br>
  </td><td>
  <label class="checkbox" style="color: maroon"><input type="checkbox" [user_perm5] name="user_perm5" value="32" class="checkbox"><span>&nbsp;</span> Edit all posts</label><br>
  <label class="checkbox" style="color: maroon"><input type="checkbox" [user_perm6] name="user_perm6" value="64" class="checkbox"><span>&nbsp;</span> Delete own posts</label><br>
  <label class="checkbox" style="color: maroon"><input type="checkbox" [user_perm7] name="user_perm7" value="128" class="checkbox"><span>&nbsp;</span> Delete all posts</label><br>
  <label class="checkbox" style="color: red"><input type="checkbox" [user_perm31] name="user_perm31"  value="$80000000" class="checkbox"><span>&nbsp;</span> Administrator</label><br>
  </td></tr></table><br><br>

  <label for="chat_enabled">Enable chat:</label><label class="checkbox"><input type="checkbox" [chat_enabled] name="chat_enabled" id="chat_enabled" class="checkbox"><span>&nbsp;</span></label><br>
  <label for="chat_anon">Anonymous chat:</label><label class="checkbox"><input type="checkbox" [chat_anon] name="chat_anon" id="chat_anon" class="checkbox"><span>&nbsp;</span></label><br><br>

  <label for="email_confirm">Confirm by email:</label><label class="checkbox"><input type="checkbox" [email_confirm] name="email_confirm" id="email_confirm" class="checkbox"><span>&nbsp;</span></label><br><br>

  <input type="submit" name="save" class="button" value="Save">
</form>
</div>

<script type="text/javascript">
<!--
setTimeout(function(){ document.getElementById('message').style.opacity = "0.0"; }, 3000)
// -->
</script>