[css:navigation.css]
[css:userslist.css]

[case:[special:lang]|
  [equ:btnCats=Categories]
  [equ:btnList=Threads]
  [equ:btnSettings=Settings]
  [equ:btnConsole=SQL console]
|
  [equ:btnCats=Категории]
  [equ:btnList=Теми]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзола]
|
  [equ:btnCats=Категории]
  [equ:btnList=Темы]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзоль]
|
  [equ:btnCats=Catégories]
  [equ:btnList=Liste des sujets]
  [equ:btnSettings=Paramètres]
  [equ:btnConsole=Console SQL]
|
  [equ:btnCats=Kategorien]
  [equ:btnList=Themen]
  [equ:btnSettings=Einstellungen]
  [equ:btnConsole=SQL-Konsole]
]

<div class="ui">
  <a class="btn" href="/!categories">[const:btnCats]</a>
  <a class="btn" href="/">[const:btnList]</a>
  <span class="spacer"></span>
  [case:[special:isadmin] | |
    <a class="btn" href="/!settings[special:urltag]">[const:btnSettings]</a>
    <a class="btn" href="/!sqlite">[const:btnConsole]</a>
  ]
</div>