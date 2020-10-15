[css:posts.css]
[css:markdown.css]

[case:[special:lang]|
  [equ:btnNewPost=Answer]
  [equ:ttlEditThread=Edit the thread attributes.]
|
  [equ:btnNewPost=Отговор]
  [equ:ttlEditThread=Редактиране на атрибутите на темата.]
|
  [equ:btnNewPost=Ответить]
  [equ:ttlEditThread=Редакция атрибутов темы]
|
  [equ:btnNewPost=Répondre]
  [equ:ttlEditThread=Éditer le titre du sujet et les mots-clés.]
|
  [equ:btnNewPost=Antworten]
  [equ:ttlEditThread=Themenoptionen ändern.]
]

<div class="ui">
  [case:[special:canpost]| |<a class="btn" href="!post">[const:btnNewPost]</a>]
</div>
<h1 class="thread_caption">
[caption]
[case:[special:canedit]||<a class="btn round" href="!edit_thread" title="[const:ttlEditThread]"><svg version="1.1" width="20" height="20" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
 <path d="m19 4-14 14-5 14 14-5 14-14-9-9zm-13 16.4 5.6 5.6-5.6 2-2-2 2-5.6z"/>
 <path d="m20 3 9 9 3-3-9-9z"/>
</svg></a>]
<div class="spacer"></div>
<div class="vote">
  <span class="thread_rating[id]">[Rating]</span>
  [case:[special:canvote]||
    <button class="btn round vote_dn [case:[VoteStatus]|voted|]" onclick="OnVote(this, -1)">
      <svg width="16" height="16" version="1.1" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg" style="stroke-width:1.5">
       <line x1="5" x2="11" y1="8" y2="8" />
      </svg>
    </button>
    <button class="btn round vote_up [case:[VoteStatus]|||voted]" onclick="OnVote(this, 1)">
      <svg width="16" height="16" version="1.1" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg" style="stroke-width:1.5">
       <line x1="4" x2="12" y1="8" y2="8" />
       <line x1="8" x2="8" y1="4" y2="12" />
      </svg>
    </button>
  ]
</div>

</h1>
<ul class="thread_tags">[special:threadtags=[id]]</ul>

