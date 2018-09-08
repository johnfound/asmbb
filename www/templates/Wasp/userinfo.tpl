[css:login.css]
[css:userinfo.css]
[css:markdown.css]
[css:settings.css]

  <div class="user_desc">
    <img class="profile_avatar" src="/!avatar/[username]?v=[AVer]" alt="(ツ)">
    <h1>[username]</h1>
    [html:[minimag:[user_desc]]]
  </div>
  <div class="user_stat">
    <h1>Statistics for [username]:</h1>
    <ul>
      <li>Last seen on <b>[LastSeen]</b></li>
      <br>
      [case:[user_perm31]||<li>Is <b>administrator</b></li>]
      <li>Can [case:[user_perm0]|<b>not</b> |]<b>login</b></li>
      <li>Can [case:[user_perm1]|<b>not</b> |]<b>read</b> posts</li>
      <li>Can [case:[user_perm9]|<b>not</b> |]<b>download</b> attached files</li>

      <li>Can [case:[user_perm2]|<b>not</b> |]<b>answer</b> in threads</li>
      <li>Can [case:[user_perm3]|<b>not</b> |]<b>start</b> new threads</li>
      <li>Can [case:[user_perm10]|<b>not</b> |]<b>attach</b> files</li>
      <li>Can [case:[user_perm4]|<b>not</b> |]<b>edit</b> his own posts</li>
      <li>Can [case:[user_perm6]|<b>not</b> |]<b>delete</b> his own posts</li>

      <li>Can [case:[user_perm5]|<b>not</b> |]<b>edit</b> others posts</li>
      <li>Can [case:[user_perm7]|<b>not</b> |]<b>delete</b> others posts</li>
      <li>Can [case:[user_perm8]|<b>not</b> |]<b>chat</b></li>
      <br>
      <li>Has written [case:[totalposts]||<a href="/!search/?u=[url:[username]]" >]<b>[totalposts]</b> post[case:[totalposts]|s||s][case:[totalposts]||</a>] on the forum.</li>
    </ul>
  </div>
