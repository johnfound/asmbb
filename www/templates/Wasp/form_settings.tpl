[css:settings.css]

<div class="set_page">
[case:[message]|<h1 class="hidden msg">Message</h1>|<h1 id="message" class="msg [case:[error]|info|error]">[message]</h1>]
<form class="settings" method="post" action="/!settings">
  <h1>Forum engine settings</h1>
  <input type="submit" name="save" class="button" value="Save">

  <h2>HTML/CSS options:</h2>

  <label>Forum title:</label>
  <input type="text" value="[forum_title]" name="forum_title" class="settings" maxlength="512">

  <label>Forum header:</label>
  <input type="text" value="[forum_header]" name="forum_header" class="settings" maxlength="512">

  <label>Description:</label>
  <input type="text" value="[description]" name="description" class="settings" maxlength="256">

  <label>Keywords:</label>
  <input type="text" value="[keywords]" name="keywords" class="settings" maxlength="256">

  <h2>Server settings:</h2>

  <label>Host:</label>
  <input type="text" value="[host]" name="host" class="settings" maxlength="320">

  <label>SMTP server/port:</label>
  <input type="text" value="[smtp_addr]" name="smtp_addr" class="settings" maxlength="256">
  <input type="text" value="[smtp_port]" name="smtp_port" class="settings" maxlength="5">

  <label>SMTP account:</label><input type="text" value="[smtp_user]" name="smtp_user" class="settings" maxlength="256">

  <input type="checkbox" [email_confirm] name="email_confirm" id="email_confirm" class="checkbox">
  <label for="email_confirm" class="right">Confirm by email:</label>

  <h2>Default user permissions:</h2>

  <section>
    <input type="checkbox" [user_perm0] name="user_perm0" id="up0" value="1"><label for="up0">Login</label>
    <input type="checkbox" [user_perm2] name="user_perm2" id="up2" value="4"><label for="up2">Post</label>
    <input type="checkbox" [user_perm3] name="user_perm3" id="up3" value="8"><label for="up3">Start threads</label>
    <input type="checkbox" [user_perm4] name="user_perm4" id="up4" value="16"><label for="up4">Edit own posts</label>
    <input type="checkbox" [user_perm8] name="user_perm8" id="up8" value="256"><label for="up8">Chat</label>

    <input type="checkbox" [user_perm5] name="user_perm5" id="up5" value="32"><label for="up5">Edit all posts</label>
    <input type="checkbox" [user_perm6] name="user_perm6" id="up6" value="64"><label for="up6">Delete own posts</label>
    <input type="checkbox" [user_perm7] name="user_perm7" id="up7" value="128"><label for="up7">Delete all posts</label>
    <input type="checkbox" [user_perm31] name="user_perm31" id="up31" value="$80000000"><label for="up31">Administrator</label>
  </section>

  <h2>Forum features:</h2>

  <label>Page length:</label>
  <input type="text" value="[page_length]" name="page_length" class="settings" maxlength="256">

  <label>Default skin:</label>
  <select class="settings" name="default_skin" >[special:skins=[default_skin]]</select>

  <label>Default mobile skin:</label>
  <select class="settings" name="default_mobile_skin">[special:skins=[default_mobile_skin]]</select>

  <input type="checkbox" [chat_enabled] name="chat_enabled" id="chat_enabled"><label for="chat_enabled">Enable chat:</label>
  <input type="checkbox" [chat_anon] name="chat_anon" id="chat_anon"><label for="chat_anon">Anonymous chat:</label>
  <input type="checkbox" [embeded_css] name="embeded_css" id="embeded_css"><label for="embeded_css">Embeded CSS:</label>

  <input type="hidden" name="ticket" value="[Ticket]" >
  <input type="submit" name="save" class="button" value="Save">
</form>
</div>

<script type="text/javascript">
<!--
 if (document.getElementById('message')) setTimeout(function(){ document.getElementById('message').style.opacity = "0.0"; }, 3000);
// -->
</script>