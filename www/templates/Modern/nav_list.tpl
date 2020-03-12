[css:thread_list.css]

[case:[special:lang]|
  [equ:btnNewThread=New Thread]
  [equ:btnMarkRead=Mark all as read]
  [equ:rssfeed=Subscribe]
|
  [equ:btnNewThread=Нова тема]
  [equ:btnMarkRead=Маркирай всички]
  [equ:rssfeed=Абонирай се]
|
  [equ:btnNewThread=Новая тема]
  [equ:btnMarkRead=Отметить все]
  [equ:rssfeed=Подпишитесь]
|
  [equ:btnNewThread=Nouveau sujet]
  [equ:btnMarkRead=Tout marquer comme lu]
  [equ:rssfeed=Suivre]
|
  [equ:btnNewThread=Neues Thema]
  [equ:btnMarkRead=Alle als gelesen kennzeichnen]
  [equ:rssfeed=Abonnieren]
]


<div class="ui">
  [case:[special:userid]  | |<a class="btn" href="!markread">[const:btnMarkRead]</a>]
  [case:[special:canstart]| |<a class="btn" href="!post">[const:btnNewThread]</a>]
</div>
