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

[case:[message]|<h1 class="msg hidden">Message</h1>|<h1 id="message" class="msg [case:[error]|info|error]">[message]</h1>]
<form class="settings" method="post" action="/settings">
  <h1>Forum engine settings</h1>
  <label>Host:</label><input type="text" value="[host]" name="host" class="settings" size="30" maxlength="320"><br>
  <label>SMTP server/port:</label><input type="text" value="[smtp_addr]" name="smtp_addr" class="settings" size="20" maxlength="256"><input type="text" value="[smtp_port]" name="smtp_port" class="settings" size="5" maxlength="5"><br>
  <label>SMTP account:</label><input type="text" value="[smtp_user]" name="smtp_user" class="settings" size="30" maxlength="256"><br>
  <label for="file_caching">File caching:</label><label class="checkbox"><input type="checkbox" [file_cache] name="file_cache" id="file_cache" class="checkbox"><span>.</span></label><br>
  <label for="log_events">Log events:</label><label class="checkbox"><input type="checkbox" [log_events] name="log_events" id="log_events" class="checkbox"><span>.</span></label><br><br>

  <input type="submit" name="save" class="button" value="Save">
</form>
</div>

<script type="text/javascript">
<!-- 
  document.getElementById('message').style.opacity = "0.0"; 
// -->
</script>