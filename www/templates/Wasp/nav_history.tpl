[css:navigation.css]
[css:posts.css]
[css:markdown.css]

[case:[special:lang]|
  [equ:btnBack=Back to the thread]
  [equ:btnSettings=Settings]
  [equ:btnConsole=SQL console]
|
  [equ:btnBack=Обратно в темата]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзола]
|
  [equ:btnBack=Вернуться к теме]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзоль]
|
  [equ:btnBack=Retour au fil]
  [equ:btnSettings=Paramètres]
  [equ:btnConsole=Console SQL]
|
  [equ:btnBack=Zurück zum Thema]
  [equ:btnSettings=Einstellungen]
  [equ:btnConsole=SQL-Konsole]
]

<div class="ui">
  <a class="ui left" href="/[special:page]/!by_id">[const:btnBack]</a>
  <span class="spacer"></span>
  [case:[special:isadmin] | |
    <a class="ui right" href="/!settings[special:urltag]">[const:btnSettings]</a>
    <a class="ui right" href="/!sqlite">[const:btnConsole]</a>
  ]
</div>
