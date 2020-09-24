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
  <div class="post_thread">
    [const:tThread]: <a href="../[case:[special:thread]|[Slug]/|]">[Caption]</a>
    [const:tPost]: <a href="../[rowid]/!by_id">#[rowid]</a>
    <div class="changed">[PostTime]</div>
  </div>
  <div class="post_text">
    <span class="nickname">[usr:[UserName]]</span>
    <img width="64" height="64" class="avatar" src="/!avatar/[url:[html:[UserName]]]?v=[AVer]" alt="(ツ)">
    <article>
      <pre>[content]</pre>
    </article>
  </div>
  <div class="post_link"><a href="../[rowid]/!by_id">[const:tMore]</a></div>
</div>
