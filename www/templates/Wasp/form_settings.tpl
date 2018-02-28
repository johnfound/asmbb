[css:settings.css]

<div class="set_page">
[case:[message]|<h1 class="hidden msg">Message</h1>|<h1 id="message" class="msg [case:[error]|info|error]">[message]</h1>]
<form class="settings" method="post" action="/!settings">
  <h1>Forum engine settings</h1>
  <input type="submit" name="save" class="button" value="Save">
  <table>
  <tr><td class="grp" colspan="3">HTML/CSS options:</td></tr>

  <tr><td class="lbl">Forum title:</td><td colspan="2"><input type="text" value="[forum_title]" name="forum_title" class="settings" maxlength="512"></td></tr>
  <tr><td class="lbl">Forum header:</td><td colspan="2"><input type="text" value="[forum_header]" name="forum_header" class="settings" maxlength="512"></td></tr>
  <tr><td class="lbl">Description:</td><td colspan="2"><input type="text" value="[description]" name="description" class="settings" maxlength="256"></td></tr>
  <tr><td class="lbl">Keywords:</td><td colspan="2"><input type="text" value="[keywords]" name="keywords" class="settings" maxlength="256"></td></tr>

  <tr><td class="grp" colspan="3">Server settings:</td></tr>

  <tr><td class="lbl">Host:</label></td><td colspan="2"><input type="text" value="[host]" name="host" class="settings" maxlength="320"></td></tr>
  <tr><td class="lbl">SMTP server/port:</td><td><input type="text" value="[smtp_addr]" name="smtp_addr" class="settings" maxlength="256"></td>
                                               <td class="small"><input type="text" value="[smtp_port]" name="smtp_port" class="settings" maxlength="5"></td></tr>
  <tr><td class="lbl">SMTP account:</td><td colspan="2"><input type="text" value="[smtp_user]" name="smtp_user" class="settings" maxlength="256"></td></tr>
  <tr><td class="lbl"><label for="email_confirm">Confirm by email:</label></td><td colspan="2"><label class="checkbox"><input type="checkbox" [email_confirm] name="email_confirm" id="email_confirm" class="checkbox"><span>&nbsp;</span></label></td></tr>

  <tr><td class="grp" colspan="3">Default user permissions:</td></tr>
  <tr><th colspan="3">
  <table><tr><th>
  <table>
  <tr><td class="lblc"><label class="checkbox" for="user_perm0"><input type="checkbox" [user_perm0] name="user_perm0" id="user_perm0" value="1"><span>&nbsp;</span> Login</label></td></tr>
  <tr><td class="lblc"><label class="checkbox" for="user_perm2"><input type="checkbox" [user_perm2] name="user_perm2" id="user_perm2" value="4" class="checkbox"><span>&nbsp;</span> Post</label></td></tr>
  <tr><td class="lblc"><label class="checkbox" for="user_perm3"><input type="checkbox" [user_perm3] name="user_perm3" id="user_perm3" value="8" class="checkbox"><span>&nbsp;</span> Start threads</label></td></tr>
  <tr><td class="lblc"><label class="checkbox" for="user_perm4"><input type="checkbox" [user_perm4] name="user_perm4" id="user_perm4" value="16" class="checkbox"><span>&nbsp;</span> Edit own posts</label></td></tr>
  <tr><td class="lblc"><label class="checkbox" for="user_perm8"><input type="checkbox" [user_perm8] name="user_perm8" id="user_perm8" value="256" class="checkbox"><span>&nbsp;</span> Chat</label></td></tr>
  </table>
  </th>
  <th>
  <table>
  <tr><td class="lblc lblm"><label class="checkbox" for="user_perm5"><input type="checkbox" [user_perm5] name="user_perm5" id="user_perm5" value="32" class="checkbox"><span>&nbsp;</span> Edit all posts</label></td></tr>
  <tr><td class="lblc lblm"><label class="checkbox" for="user_perm6"><input type="checkbox" [user_perm6] name="user_perm6" id="user_perm6" value="64" class="checkbox"><span>&nbsp;</span> Delete own posts</label></td></tr>
  <tr><td class="lblc lblm"><label class="checkbox" for="user_perm7"><input type="checkbox" [user_perm7] name="user_perm7" id="user_perm7" value="128" class="checkbox"><span>&nbsp;</span> Delete all posts</label></td></tr>
  <tr><td class="lblc lblr"><label class="checkbox" for="user_perm31"><input type="checkbox" [user_perm31] name="user_perm31" id="user_perm31"  value="$80000000" class="checkbox"><span>&nbsp;</span> Administrator</label></td></tr>
  </table>
  </th></tr></table>

  <tr><td class="grp" colspan="3">Forum features:</td></tr>

  <tr><td class="lbl">Page length:</td><td colspan="2"><input type="text" value="[page_length]" name="page_length" class="settings" maxlength="256"></td></tr>
  <tr><td class="lbl">Default skin:</td><td colspan="2"><select class="settings" name="default_skin" >[special:skins=[default_skin]]</select></td></tr>
  <tr><td class="lbl">Default mobile skin:</td><td colspan="2"><select class="settings" name="default_mobile_skin">[special:skins=[default_mobile_skin]]</select></td></tr>
  <tr><td class="lbl"><label for="chat_enabled">Enable chat:</label></td><td colspan="2"><label class="checkbox"><input type="checkbox" [chat_enabled] name="chat_enabled" id="chat_enabled" class="checkbox"><span>&nbsp;</span></label></td></tr>
  <tr><td class="lbl"><label for="chat_anon">Anonymous chat:</label></td><td colspan="2"><label class="checkbox"><input type="checkbox" [chat_anon] name="chat_anon" id="chat_anon" class="checkbox"><span>&nbsp;</span></label></td></tr>
  <tr><td class="lbl"><label for="embeded_css">Embeded CSS:</label></td><td colspan="2"><label class="checkbox"><input type="checkbox" [embeded_css] name="embeded_css" id="embeded_css" class="checkbox"><span>&nbsp;</span></label></td></tr>

  </table></br></br>
  <input type="hidden" name="ticket" value="[Ticket]" >
  <input type="submit" name="save" class="button" value="Save">
</form>
</div>

<script type="text/javascript">
<!--
setTimeout(function(){ document.getElementById('message').style.opacity = "0.0"; }, 3000)
// -->
</script>