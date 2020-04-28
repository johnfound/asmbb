[case:[special:lang]|
  [equ:tThread=Thread]
  [equ:tMore=read more...]
|
  [equ:tThread=Тема]
  [equ:tMore=повече...]
|
  [equ:tThread=Тема]
  [equ:tMore=больше...]
|
  [equ:tThread=Sujet]
  [equ:tMore=lire la suite...]
|
  [equ:tThread=Thema]
  [equ:tMore=weiterlesen...]
]

<div class="post">
  <div class="post-header">
    [case:[Unread]||<svg width="16" height="16" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
      <path d="m12.2 12.4 3.78-11.6 3.78 11.6 12.2 4e-4-9.89 7.19 3.78 11.6-9.89-7.18-9.89 7.19 3.78-11.6-9.89-7.19z"/>
    </svg>]

    <a class="post-link" href="../[rowid]/!by_id">#[rowid]</a>

    <img class="avatar" src="/!avatar/[url:[UserName]]?v=[AVer]" alt="(ツ)">
    <p><a class="user_name" href="/!userinfo/[url:[UserName]]">[UserName]</a>; [const:tThread]: <b><a href="../[case:[special:thread]|[Slug]/|]">[Caption]</a></b>; [PostTime]</p>
  </div>
  <div class="post-text">
    <pre>[content]</pre>
    <a class="post-link" href="../[rowid]/!by_id">[const:tMore]</a>
  </div>
</div>
