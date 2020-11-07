[css:posts.css]
[css:markdown.css]

[case:[special:lang]|
  [equ:btnList=Threads]
  [equ:btnNewPost=Answer]
  [equ:ttlEditThread=Edit the thread attributes.]
|
  [equ:btnList=Теми]
  [equ:btnNewPost=Отговор]
  [equ:ttlEditThread=Редактиране на атрибутите на темата.]
|
  [equ:btnList=Темы]
  [equ:btnNewPost=Ответить]
  [equ:ttlEditThread=Редакция атрибутов темы]
|
  [equ:btnList=Liste des sujets]
  [equ:btnNewPost=Répondre]
  [equ:ttlEditThread=Éditer le titre du sujet et les mots-clés.]
|
  [equ:btnList=Themen]
  [equ:btnNewPost=Antworten]
  [equ:ttlEditThread=Themenoptionen ändern.]
]

[css:highlight.css]

<h1 class="thread_caption">
[caption]
[case:[special:canedit]||<a href="!edit_thread" title="[const:ttlEditThread]" class="btn img-btn">
  <img width="16" height="16" alt="✎" src="[special:skin]/_images/edit.png">
</a>]
<div class="vote jsonly">
  <span class="thread_rating[id]">[Rating]</span>
  [case:[special:canvote]||
    <a class="vote_dn [case:[VoteStatus]|voted|]" onclick="OnVote(this, -1)">▼</a>
    <a class="vote_up [case:[VoteStatus]|||voted]" onclick="OnVote(this, 1)">▲</a>
  ]
</div>
</h1>
<ul class="thread_tags">[special:threadtags=[id]]</ul>

<div class="navigation3 btn-bar">
<table class="toolbar light-btns"><tr>
  <td><a href="..">[const:btnList]</a>
  <td>[case:[special:userid]|<a href="/!login">[const:btnNewPost]</a>|<a href="!post">[const:btnNewPost]</a>]
  <td class="spacer">
</tr></table>
