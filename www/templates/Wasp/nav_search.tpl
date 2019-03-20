[css:navigation.css]
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
  <a class="ui left" href="..">[const:btnBack]</a>
  <span class="spacer"></span>
  [case:[special:isadmin] | |
    <a class="ui right" href="/!settings[special:urltag]">[const:btnSettings]</a>
    <a class="ui right" href="/!sqlite">[const:btnConsole]</a>
  ]
</div>
