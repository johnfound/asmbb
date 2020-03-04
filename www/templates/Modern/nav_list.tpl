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


<div class="ui">
  <a class="btn" href="/!categories">[const:btnCats]</a>
  [case:[special:userid]  | |<a class="btn" href="!markread">[const:btnMarkRead]</a>]
  [case:[special:canstart]| |<a class="btn" href="!post">[const:btnNewThread]</a>]
  [case:[special:canchat] | |<a class="btn" href="/!chat">[const:btnChat]</a>]
  <span class="spacer"></span>
  [case:[special:isadmin] | |
    <a class="btn" href="/!settings[special:urltag]">[const:btnSettings]</a>
    <a class="btn" href="/!sqlite">[const:btnConsole]</a>
  ]
  [case:[special:limited]|<a class="btn" href="!feed" title="[const:rssfeed]"><svg class="listfeed" height="19" width="19" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
    <title>RSS</title>
    <path d="m8.8 27.6c0 2.43-1.97 4.4-4.4 4.4s-4.4-1.97-4.4-4.4 1.97-4.4 4.4-4.4 4.4 1.97 4.4 4.4z"/>
    <path d="m21.2 32h-6.2c0-8.2-6.8-15-15-15v-6.2c11.8 0 21.2 9.4 21.2 21.2z"/>
    <path d="m25.6 32c0-14.2-11.4-25.6-25.6-25.6v-6.4c17.6 0 32 14.4 32 32z"/>
  </svg></a>|]
</div>
