[css:login.css]
[css:userinfo.css]
[css:markdown.css]

  <div class="user_desc">
    <img class="profile_avatar" src="/!avatar/[username]?v=[AVer]">
    <h1>[username]</h1>
    [minimag:[user_desc]]
  </div>
  <div class="user_stat">
    <h1>Statistics for [username]:</h1>
    <ul>
      <li>Last seen on <b>[LastSeen]</b></li>
      <br>
      [case:[isadmin]| |<li>Is <b>administrator</b></li>]
      <li>Can [case:[canlogin]  |<b>not</b>|] <b>login</b></li>
      <li>Can [case:[canpost]   |<b>not</b>|] <b>answer</b> in threads</li>
      <li>Can [case:[canstart]  |<b>not</b>|] <b>start</b> threads</li>
      <li>Can [case:[caneditown]|<b>not</b>|] <b>edit</b> its own posts.</li>
      <li>Can [case:[caneditall]|<b>not</b>|] <b>edit</b> others posts.</li>
      <li>Can [case:[candelown]|<b>not</b>|] <b>delete</b> its own posts.</li>
      <li>Can [case:[candelall]|<b>not</b>|] <b>delete</b> others posts.</li>
      <br>
      <li>Has written <b>[totalposts]</b> post[case:[totalposts]|s||s] on the forum.</li>
    </ul>
  </div>
