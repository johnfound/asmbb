<div class="post">
  <div class="user_info unread[Unread]">
    [case:[EditUser]|
      <a class="user_name" href="/!userinfo/[PostUser]">[PostUser]<img class="avatar" alt=":)" src="/!avatar/[PostUser]?v=[AVerP]"></a>|
      <a class="user_name" href="/!userinfo/[EditUser]">[EditUser]<img class="avatar" alt=":)" src="/!avatar/[EditUser]?v=[AVerE]"></a>]
  </div>
  <div class="post_text">
    <div class="post_info">
      <div class="last_edit">
        [case:[rowid]|<a href="#current">#current</a>|<a href="#[rowid]">#[rowid]</a>]
        [case:[EditUser]|Created: [PostTime] by <a href="/!userinfo/[PostUser]">[PostUser]</a>|Last edited: [EditTime] by <a href="/!userinfo/[EditUser]">[EditUser]</a>]
      </div>
      <div class="edit_tools">
        [case:[rowid]||<a class="icon_rest" title="Restore the post to this content."  href="/[rowid]/!restore"></a>]
      </div>
    </div>
    <article>
      [minimag:[Content]]
    </article>
  </div>
</div>
