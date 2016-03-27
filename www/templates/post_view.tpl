<div class="post">
  <div class="user_info">
    <img class="unread_icon" src="/images/[case:[Unread]|onepost_gray.svg|onepost.svg]">
    <div class="user_name">[UserName]</div>
    <div class="user_pcnt">Posts: [UserPostCount]</div>
  </div>
  <div class="post_info">
    <a id="[id]" href="#[id]">#[id]</a>
    Публикуван: [PostTime], видян: [ReadCount] [case:[ReadCount]|пъти|път|пъти]
    <div class="edit_tools">
      [case:[sql: select ([special:permissions] & 0x80000004 <> 0)]
      | |
      <a class="quote_btn" href="/post/[slug]/[id]">
	<img class="quote_icon" src="/images/quote.svg">
      </a>
      ]
      [case:[sql: select (cast(? as integer) = [special:userid]) and ([special:permissions] & 16 <> 0) or ([special:permissions] & 0x80000020 <> 0)|[UserID]]
      | | <a class="edit_btn" href="/edit/[id]">
	    <img class="edit_icon" src="/images/edit_gray.svg">
	  </a>
	  <a class="del_btn" href="/delete/[id]">
	    <img class="del_icon" src="/images/del_gray.svg">
	  </a>
      ]
    </div>
  </div>
  <div class="post_text">
    [minimag:[content]]
  </div>
</div>
