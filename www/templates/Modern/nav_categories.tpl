[css:navigation.css]
[css:thread_list.css]

[case:[special:lang]|
  [equ:btnAll=All threads]
  [equ:btnMarkRead=Mark all as read]
  [equ:btnChat=Chat]
|
  [equ:btnAll=Всички теми]
  [equ:btnMarkRead=Маркирай всички]
  [equ:btnChat=Chat]
|
  [equ:btnAll=Все темы]
  [equ:btnMarkRead=Отметить все]
  [equ:btnChat=Чат]
|
  [equ:btnAll=Tous les sujets]
  [equ:btnMarkRead=Tout marquer comme lu]
  [equ:btnChat=Тchat]
|
  [equ:btnAll=Alle Themen]
  [equ:btnMarkRead=Alle als gelesen kennzeichnen]
  [equ:btnChat=Chat]
]

<div class="ui">
  <a class="btn" href="/">[const:btnAll]</a>
  [case:[special:userid]  | |<a class="btn" href="!markread">[const:btnMarkRead]</a>]
</div>
