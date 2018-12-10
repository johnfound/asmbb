<div class="post">
  <div class="user_info">
    [case:[EditUser]|
      <a class="user_name" href="/!userinfo/[url:[PostUser]]">[PostUser]</a><div class="avatar"><img class="avatar" alt="(ツ)" src="/!avatar/[url:[PostUser]]?v=[AVerP]"></div>|
      <a class="user_name" href="/!userinfo/[url:[EditUser]]">[EditUser]</a><div class="avatar"><img class="avatar" alt="(ツ)" src="/!avatar/[url:[EditUser]]?v=[AVerE]"></div>]
  </div>
  <div class="post_text">
    <div class="post_info">
      <div class="last_edit">
        [case:[rowid]|<a href="#current">#current</a>|<a href="#[rowid]">#[rowid]</a>]
        [case:[EditUser]|Created: [PostTime] by <a href="/!userinfo/[url:[PostUser]]">[PostUser]</a>|Last edited: [EditTime] by <a href="/!userinfo/[url:[EditUser]]">[EditUser]</a>]
      </div>
      <div class="edit_tools">
        [case:[rowid]||<a title="Restore the post to this content."  href="/[rowid]/!restore"><img src="[special:skin]/_images/restore.svg" alt="Restore"></a>]
      </div>
    </div>
    <article>
      [html:[[case:[format]|minimag:[include:minimag_suffix.tpl]|bbcode:][Content]]]
    </article>
  </div>
</div>
