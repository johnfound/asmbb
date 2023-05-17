[css:navigation.css]
[css:posts.css]
[css:markdown.css]

[case:[special:lang]|
  [equ:btnCats=Categories]
  [equ:btnList=Threads]
  [equ:btnNewPost=Answer]
  [equ:btnSettings=Settings]
  [equ:btnConsole=SQL console]
  [equ:ttlEditThread=Edit the thread attributes.]
  [equ:altEdit=Edit]
  [equ:rssfeed=Subscribe to this thread]
|
  [equ:btnCats=Категории]
  [equ:btnList=Теми]
  [equ:btnNewPost=Отговор]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзола]
  [equ:ttlEditThread=Редактиране на атрибутите на темата.]
  [equ:altEdit=Редактиране]
  [equ:rssfeed=Абонирай се за тази тема]
|
  [equ:btnCats=Категории]
  [equ:btnList=Темы]
  [equ:btnNewPost=Ответить]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзоль]
  [equ:ttlEditThread=Редакция атрибутов темы]
  [equ:altEdit=Редакция]
  [equ:rssfeed=Подпишитесь на эту тему]
|
  [equ:btnCats=Catégories]
  [equ:btnList=Liste des sujets]
  [equ:btnNewPost=Répondre]
  [equ:btnSettings=Paramètres]
  [equ:btnConsole=Console SQL]
  [equ:ttlEditThread=Éditer le titre du sujet et les mots-clés.]
  [equ:altEdit=Éditer]
  [equ:rssfeed=Suivre ce sujet]
|
  [equ:btnCats=Kategorien]
  [equ:btnList=Themen]
  [equ:btnNewPost=Antworten]
  [equ:btnSettings=Einstellungen]
  [equ:btnConsole=SQL-Konsole]
  [equ:ttlEditThread=Themenoptionen ändern.]
  [equ:altEdit=Ändern]
  [equ:rssfeed=Dieses Thema abonnieren]
]

<div class="ui">
  <a class="ui left" href="/!categories">[const:btnCats]</a>
  <a class="ui left" href="..">[const:btnList]</a>
  [case:[special:canpost]| |<a class="ui left" href="!edit">[const:btnNewPost]</a>]
  <span class="spacer"></span>
  [case:[special:isadmin] | |
    <a class="ui right" href="/!settings[special:urltag]">[const:btnSettings]</a>
    <a class="ui right" href="/!sqlite">[const:btnConsole]</a>
  ]
</div>
<h1 class="thread_caption">
[caption]
[case:[special:canedit]||<a href="!edit_thread" title="[const:ttlEditThread]"><img src="[special:skin]/_images/edit.svg" alt="[const:altEdit]"></a>]
[case:[special:limited]|<a href="!feed" title="[const:rssfeed]"><img src="[special:skin]/_images/rss.svg" alt="RSS"></a>|]

  <div class="vote">
    <span class="thread_rating[id]">[Rating]</span>
    [case:[special:canvote]||
      <button class="icon_btn vote_dn [case:[VoteStatus]|voted|]" onclick="OnVote(this, -1)">
        <svg width="16" height="16" version="1.1" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg" style="stroke-width:2">
         <line x1="2" x2="14" y1="8" y2="8" />
        </svg>
      </button>
      <button class="icon_btn vote_up [case:[VoteStatus]|||voted]" onclick="OnVote(this, 1)">
        <svg width="16" height="16" version="1.1" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg" style="stroke-width:2            ">
         <line x1="0" x2="16" y1="8" y2="8" />
         <line x1="8" x2="8" y1="0" y2="16" />
        </svg>
      </button>
    ]
  </div>
</h1>
<ul class="thread_tags">[special:threadtags=[id]]</ul>
