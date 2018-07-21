<a id="[id]"></a>
<div class="post">
  <div class="user_info">
    <div class="username">
      <img  width="32" height="32" class="unread" [case:[Unread]|src="[special:skin]/_images/onepost_gray.svg" alt="Rd">|src="[special:skin]/_images/onepost.svg" alt="URd">]
      <a class="user_name" href="/!userinfo/[UserName]">[UserName]</a>
    </div>
    <div class="avatar">
      <img class="avatar" alt="(ツ)" src="/!avatar/[UserName]?v=[AVer]">
      <div class="user_pcnt">Posts: [UserPostCount]</div>
    </div>
  </div>
  <div class="post_text">
    <div class="post_info">
      <div class="last_edit">
        <a href="#[id]">#[id]</a>
        [case:[EditUser]|Created: [PostTime]|Last edited: [EditTime] by <a href="/!userinfo/[EditUser]">[EditUser]</a>], read: [ReadCount] [case:[ReadCount]|times|time|times]
      </div>
      <div class="edit_tools">
        [case:[special:canpost]| |<a title="Quote this post" href="[id]/!post"><img src="[special:skin]/_images/quote.svg" alt="Quote"></a>]
        [case:[special:canedit]| |<a title="Edit this post" href="[id]/!edit"><img src="[special:skin]/_images/edit.svg" alt="Edit"></a>]
        [case:[special:candel] | |<a title="Delete this post" href="[id]/!del"><img src="[special:skin]/_images/del.svg" alt="Del"></a>]
        [case:[HistoryCount]||[case:[special:isadmin]| |<a title="Show the post history" href="/[id]/!history"><img src="[special:skin]/_images/history.svg" alt="History"></a>]]
      </div>
    </div>
    <article>
      [html:[Rendered]]
    </article>
  </div>
</div>
