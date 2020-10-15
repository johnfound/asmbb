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
]
<div class="post">
  <div class="post_thread">
    [const:tThread]: <a href="../[case:[special:thread]|[Slug]/|]">[Caption]</a>
    [const:tPost]: <a href="../[rowid]/!by_id">#[rowid]</a> <div class="changed">[PostTime]</div>
  </div>
  <div class="post_sum">
    <div class="avatar">
      <img class="smallavatar" src="/!avatar/[url:[html:[UserName]]]?v=[AVer]">
    </div>
    <pre>[content]</pre>
    <a class="block_link" href="../[rowid]/!by_id">[const:tMore]</a>
  </div>
  <div class="user_name">Posted by: <a href="/!userinfo/[url:[html:[UserName]]]">[usr:[UserName]]</a></div>
</div>
