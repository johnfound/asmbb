<a id="[id]"></a>
<div class="post">
  <div class="user_info unread[Unread]">
    <a class="user_name" href="/!userinfo/[UserName]">[UserName]
    <img class="avatar" alt=":)" src="/!avatar/[UserName]?v=[AVer]"></a>
    <div class="user_pcnt">Posts: [UserPostCount]</div>
  </div>
  <div class="post_text">
    <div class="post_info">
      <div class="last_edit">
        <a href="#[id]">#[id]</a>
        [case:[EditUser]|Created: [PostTime]|Last edited: [EditTime] by <a href="/!userinfo/[EditUser]">[EditUser]</a>], read: [ReadCount] [case:[ReadCount]|times|time|times]
      </div>
      <div class="edit_tools">
        [case:[special:canpost]| |<a class="icon_quote" href="[id]/!post"></a>]
        [case:[special:canedit]| |<a class="icon_edit"  href="[id]/!edit"></a>]
        [case:[special:candel] | |<a class="icon_del"   href="[id]/!del"></a>]
        [case:[editUserID]||[case:[special:isadmin]| |<a class="icon_hist"  href="/[id]/!history"></a>]]
      </div>
    </div>
    <article>
      [html:[Rendered]]
    </article>
  </div>
</div>
