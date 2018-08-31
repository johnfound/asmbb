[css:common.css]
[css:settings.css]

<div class="set_page">
[case:[message]||<h1 id="message" class="msg [case:[error]|info|error]">[message]</h1>]
<form class="settings msgbox" method="post" action="/!settings">
  <h1>Forum engine settings</h1>
  <input type="submit" name="save" class="button" value="Save">

  <h2>HTML/CSS options:</h2>

  <h3>Forum title:</h3>
  <input type="text" value="[forum_title]" name="forum_title" class="settings" maxlength="512">

  <h3>Forum header:</h3>
  <textarea rows="6" class="settings" name="forum_header">[forum_header]</textarea>

  <h3>Description:</h3>
  <input type="text" value="[description]" name="description" class="settings" maxlength="256">

  <h3>Keywords:</h3>
  <input type="text" value="[keywords]" name="keywords" class="settings" maxlength="256">

  <table><tr><td>
    <input type="checkbox" [embeded_css] name="embeded_css" id="embeded_css"><label for="embeded_css">Embeded CSS</label>
  </td></tr></table>

  <h2>Server settings:</h2>

  <h3>Host:</h3>
  <input type="text" value="[host]" name="host" class="settings" maxlength="320">

  <h3>SMTP server/port:</h3>
  <input type="text" value="[smtp_addr]" name="smtp_addr" class="settings" maxlength="256">
  <input type="text" value="[smtp_port]" name="smtp_port" class="settings" maxlength="5">

  <h3>SMTP account:</h3>
  <input type="text" value="[smtp_user]" name="smtp_user" class="settings" maxlength="256">

  <table><tr><td>
    <input type="checkbox" [email_confirm] name="email_confirm" id="email_confirm" class="checkbox"><label for="email_confirm">Confirm by email</label>
  </td></tr></table>

  <h2>Default permissions:</h2>

  <h3>For new users:</h3>
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

  <h3>For guests:</h3>
  <table><tr>
    <td>
      <input type="checkbox" [anon_perm0]  name="anon_perm" id="ap0"  value="1"><label for="ap0">Login</label>
      <input type="checkbox" [anon_perm1]  name="anon_perm" id="ap1"  value="2"><label for="ap1">Read</label>
      <input type="checkbox" [anon_perm2]  name="anon_perm" id="ap2"  value="4"><label for="ap2">Post</label>
      <input type="checkbox" [anon_perm3]  name="anon_perm" id="ap3"  value="8"><label for="ap3">Start threads</label>
    </td><td>
      <input type="checkbox" [anon_perm4]  name="anon_perm" id="ap4"  value="16"><label for="ap4">Edit own posts</label>
      <input type="checkbox" [anon_perm5]  name="anon_perm" id="ap5"  value="32"><label for="ap5">Edit all posts</label>
      <input type="checkbox" [anon_perm6]  name="anon_perm" id="ap6"  value="64"><label for="ap6">Delete own posts</label>
      <input type="checkbox" [anon_perm7]  name="anon_perm" id="ap7"  value="128"><label for="ap7">Delete all posts</label>
    </td><td>
      <input type="checkbox" [anon_perm8]  name="anon_perm" id="ap8"  value="256"><label for="ap8">Chat</label>
      <input type="checkbox" [anon_perm9]  name="anon_perm" id="ap9"  value="512"><label for="ap9">Download files</label>
      <input type="checkbox" [anon_perm10] name="anon_perm" id="ap10" value="1024"><label for="ap10">Attach files</label>
      <input type="checkbox" [anon_perm31] name="anon_perm" id="ap31" value="$80000000"><label for="ap31">Administrator</label>
  </tr></table>

  <h2>Forum features:</h2>

  <h3>Page length:</h3>
  <input type="text" value="[page_length]" name="page_length" class="settings" maxlength="256">

  <h3>Default skin:</h3>
  <select class="settings" name="default_skin" >[special:skins=[default_skin]]</select>

  <h3>Default mobile skin:</h3>
  <select class="settings" name="default_mobile_skin">[special:skins=[default_mobile_skin]]</select>

  <table><tr>
    <td><input type="checkbox" [chat_enabled] name="chat_enabled" id="chat_enabled"><label for="chat_enabled">Enable chat</label></td>
  </tr></table>

  <input type="hidden" name="ticket" value="[Ticket]" >
  <input type="submit" name="save" class="button" value="Save">
</form>
</div>

<script type="text/javascript">
<!--
 if (document.getElementById('message'))
   setTimeout( function() {
                            document.getElementById('message').style.display = "none";
                          }, 3000
             );
// -->
</script>