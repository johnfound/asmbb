[case:[special:lang]|
  [equ:tThread=Thread]
  [equ:tPost=Post]
  [equ:tMore=read more...]
|
  [equ:tThread=Тема]
  [equ:tPost=Съобщение]
  [equ:tMore=повече...]
|
  [equ:tThread=Тема]
  [equ:tPost=Сообщение]
  [equ:tMore=больше...]
|
  [equ:tThread=Sujet]
  [equ:tPost=Message]
  [equ:tMore=lire la suite...]
|
  [equ:tThread=Thema]
  [equ:tPost=Beitrag]
  [equ:tMore=weiterlesen...]
]

<div class="post">
  <div class="search_info">
    <img  width="32" height="32" class="unread" [case:[Unread]|src="[special:skin]/_images/onepost_gray.svg" alt="Rd">|src="[special:skin]/_images/onepost.svg" alt="URd">]    <a class="user_name" href="/!userinfo/[url:[UserName]]">[UserName]</a>
    <img class="smallavatar" src="/!avatar/[url:[username]]?v=[AVer]" alt="(ツ)">
    <div class="changed">[PostTime]</div>
  </div>
  <div class="post_thread">
    [const:tThread]: <a href="../[case:[special:thread]|[Slug]/|]">[Caption]</a>
    [const:tPost]: <a href="../[rowid]/!by_id">#[rowid]</a>
  </div>
  <div class="post_sum">
    <pre>[content]</pre>
    <div class="post_link"><a href="../[rowid]/!by_id">[const:tMore]</a></div>
  </div>
</div>
