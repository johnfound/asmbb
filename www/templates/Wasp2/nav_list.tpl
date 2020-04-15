[css:navigation.css]
[css:thread_list.css]

[case:[special:lang]|
  [equ:btnCats=Categories]
  [equ:btnNewThread=New Thread]
  [equ:btnMarkRead=Mark all as read]
  [equ:btnChat=Chat]
  [equ:btnSettings=Settings]
  [equ:btnConsole=SQL console]
  [equ:rssfeed=Subscribe]
|
  [equ:btnCats=Категории]
  [equ:btnNewThread=Нова тема]
  [equ:btnMarkRead=Маркирай всички]
  [equ:btnChat=Чат]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзола]
  [equ:rssfeed=Абонирай се]
|
  [equ:btnCats=Категории]
  [equ:btnNewThread=Новая тема]
  [equ:btnMarkRead=Отметить все]
  [equ:btnChat=Чат]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзоль]
  [equ:rssfeed=Подпишитесь]
|
  [equ:btnCats=Catégories]
  [equ:btnNewThread=Nouveau sujet]
  [equ:btnMarkRead=Tout marquer comme lu]
  [equ:btnChat=Тchat]
  [equ:btnSettings=Paramètres]
  [equ:btnConsole=Console SQL]
  [equ:rssfeed=Suivre]
|
  [equ:btnCats=Kategorien]
  [equ:btnNewThread=Neues Thema]
  [equ:btnMarkRead=Alle als gelesen kennzeichnen]
  [equ:btnChat=Chat]
  [equ:btnSettings=Einstellungen]
  [equ:btnConsole=SQL-Konsole]
  [equ:rssfeed=Abonnieren]
]


<div class="navigation3 btn-bar">
  [case:[special:userid]  | |<a class="btn" href="!markread">[const:btnMarkRead]</a>]
  [case:[special:canstart]| |<a class="btn" href="!post">[const:btnNewThread]</a>]
</div>
