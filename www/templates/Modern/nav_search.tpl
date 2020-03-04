[css:navigation.css]
[css:posts.css]
[css:search.css]

[case:[special:lang]|
  [equ:btnBack=Back]
  [equ:btnSettings=Settings]
  [equ:btnConsole=SQL console]
|
  [equ:btnBack=Назад]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзола]
|
  [equ:btnBack=Назад]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзоль]
|
  [equ:btnBack=Retour]
  [equ:btnSettings=Paramètres]
  [equ:btnConsole=Console SQL]
|
  [equ:btnBack=Zurück]
  [equ:btnSettings=Einstellungen]
  [equ:btnConsole=SQL-Konsole]
]

<div class="ui">
  <a class="btn left" href="..">[const:btnBack]</a>
  <span class="spacer"></span>
  [case:[special:isadmin] | |
    <a class="btn right" href="/!settings[special:urltag]">[const:btnSettings]</a>
    <a class="btn right" href="/!sqlite">[const:btnConsole]</a>
  ]
</div>
