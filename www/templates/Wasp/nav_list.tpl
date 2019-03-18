[css:navigation.css]
[css:thread_list.css]

[case:[special:lang]|
  [equ:btnCats=Categories]
  [equ:btnNewThread=New Thread]
  [equ:btnMarkRead=Mark all as read]
  [equ:btnChat=Chat]
  [equ:btnSettings=Settings]
  [equ:btnConsole=SQL console]
|
  [equ:btnCats=Категории]
  [equ:btnNewThread=Нова тема]
  [equ:btnMarkRead=Маркирай всички]
  [equ:btnChat=Chat]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзола]
|
  [equ:btnCats=Категории]
  [equ:btnNewThread=Новая тема]
  [equ:btnMarkRead=Отметить все]
  [equ:btnChat=Чат]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзоль]
|
  [equ:btnCats=Catégories]
  [equ:btnNewThread=Nouveau sujet]
  [equ:btnMarkRead=Tout marquer comme lu]
  [equ:btnChat=Тchat]
  [equ:btnSettings=Paramètres]
  [equ:btnConsole=Console SQL]
]


<div class="ui">
  <a class="ui left" href="/!categories">[const:btnCats]</a>
  [case:[special:userid]  | |<a class="ui left" href="!markread">[const:btnMarkRead]</a>]
  [case:[special:canstart]| |<a class="ui left" href="!post">[const:btnNewThread]</a>]
  [case:[special:canchat] | |<a class="ui left" href="/!chat">[const:btnChat]</a>]
  <span class="spacer"></span>
  [case:[special:isadmin] | |
    <a class="ui right" href="/!settings[special:urltag]">[const:btnSettings]</a>
    <a class="ui right" href="/!sqlite">[const:btnConsole]</a>
  ]
</div>
