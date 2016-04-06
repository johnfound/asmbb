<div class="set_page">
[case:[special:setupmode]| |
<form class="settings" method="post" action="/adminrulez">
  <h1>Admin account setup</h1>
  <label>Admin nick:</label><input type="text" value="" name="admin" class="settings" size="30" maxlength="320"><br>
  <label>Admin email:</label><input type="text" value="" name="email" class="settings" size="30" maxlength="320"><br>
  <label>Password:</label><input type="password" value="" name="password" class="settings" size="30" maxlength="1024"><br>
  <label>Password again:</label><input type="password" value="" name="password2" class="settings" size="30" maxlength="1024"><br>

  <input type="submit" name="submit" class="button" value="Setup admin">
</form>
]

[case:[message]|<h1 class="hidden msg">Message</h1>|<h1 id="message" class="msg [case:[error]|info|error]">[message]</h1>]
<form class="settings" method="post" action="/settings[special:urltag]">
  <h1>Forum engine settings</h1>
  <label>Host:</label><input type="text" value="[host]" name="host" class="settings" size="30" maxlength="320"><br>
  <label>SMTP server/port:</label><input type="text" value="[smtp_addr]" name="smtp_addr" class="settings" size="20" maxlength="256"><input type="text" value="[smtp_port]" name="smtp_port" class="settings" size="5" maxlength="5"><br>
  <label>SMTP account:</label><input type="text" value="[smtp_user]" name="smtp_user" class="settings" size="30" maxlength="256"><br>
  <label for="file_caching">File caching:</label><label class="checkbox"><input type="checkbox" [file_cache] name="file_cache" id="file_cache" class="checkbox"><span>.</span></label><br>
  <label for="log_events">Log events:</label><label class="checkbox"><input type="checkbox" [log_events] name="log_events" id="log_events" class="checkbox"><span>.</span></label><br>
  <label>Default user permissions:</label><br>
  <label></label><label class="checkbox"><input type="checkbox" [user_perm0] name="user_perm0" value="1" class="checkbox"><span>.</span> Login</label><br>
  <label></label><label class="checkbox"><input type="checkbox" [user_perm2] name="user_perm2" value="4" class="checkbox"><span>.</span> Post</label><br>
  <label></label><label class="checkbox"><input type="checkbox" [user_perm3] name="user_perm3" value="8" class="checkbox"><span>.</span> Strart threads</label><br>
  <label></label><label class="checkbox"><input type="checkbox" [user_perm4] name="user_perm4" value="16" class="checkbox"><span>.</span> Edit own posts</label><br>
  <label></label><label class="checkbox" style="color: maroon"><input type="checkbox" [user_perm5] name="user_perm5" value="32" class="checkbox"><span>.</span> Edit all posts</label><br>
  <label></label><label class="checkbox" style="color: maroon"><input type="checkbox" [user_perm6] name="user_perm6" value="64" class="checkbox"><span>.</span> Delete own posts</label><br>
  <label></label><label class="checkbox" style="color: maroon"><input type="checkbox" [user_perm7] name="user_perm7" value="128" class="checkbox"><span>.</span> Delete all posts</label><br>
  <label></label><label class="checkbox" style="color: red"><input type="checkbox" [user_perm31] name="user_perm31"  value="$80000000" class="checkbox"><span>.</span> Administrator</label><br>

  <input type="submit" name="save" class="button" value="Save">
</form>
</div>

<script type="text/javascript">
<!-- 
setTimeout(function(){ document.getElementById('message').style.opacity = "0.0"; }, 3000)
// -->
</script>