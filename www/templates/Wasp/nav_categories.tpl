[css:navigation.css]
[css:thread_list.css]

[case:[special:lang]|
  [equ:btnAll=All threads]
  [equ:btnMarkRead=Mark all as read]
  [equ:btnChat=Chat]
  [equ:btnSettings=Settings]
  [equ:btnConsole=SQL console]
|
  [equ:btnAll=Всички теми]
  [equ:btnMarkRead=Маркирай всички]
  [equ:btnChat=Chat]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзола]
|
  [equ:btnAll=Все темы]
  [equ:btnMarkRead=Отметить все]
  [equ:btnChat=Чат]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзоль]
|
  [equ:btnAll=Tous les sujets]
  [equ:btnMarkRead=Tout marquer comme lu]
  [equ:btnChat=Тchat]
  [equ:btnSettings=Paramètres]
  [equ:btnConsole=Console SQL]
]

<div class="ui">
  <a class="ui left" href="/">[const:btnAll]</a>
  [case:[special:userid]  | |<a class="ui left" href="!markread">[const:btnMarkAll]</a>]
  [case:[special:canchat] | |<a class="ui left" href="/!chat">[const:btnChat]</a>]
  <span class="spacer"></span>
  [case:[special:isadmin] | |
    <a class="ui right" href="/!settings[special:urltag]">[const:btnSettings]</a>
    <a class="ui right" href="/!sqlite">[const:btnConsole]</a>
  ]
</div>
