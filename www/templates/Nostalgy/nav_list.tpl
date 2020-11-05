[css:thread_list.css]

[case:[special:lang]|
  [equ:btnNewThread=New Thread]
  [equ:btnMarkRead=Mark all as read]
|
  [equ:btnNewThread=Нова тема]
  [equ:btnMarkRead=Маркирай всички]
|
  [equ:btnNewThread=Новая тема]
  [equ:btnMarkRead=Отметить все]
|
  [equ:btnNewThread=Nouveau sujet]
  [equ:btnMarkRead=Tout marquer comme lu]
|
  [equ:btnNewThread=Neues Thema]
  [equ:btnMarkRead=Alle als gelesen kennzeichnen]
]


<table class="toolbar"><tr>
  [case:[special:userid]
    |
      <td><a href="/!login"><button>[const:btnNewThread]</button></a>
    |
      <td><a href="!markread"><button>[const:btnMarkRead]</button></a>
      <td><a class="btn" href="!post"><button>[const:btnNewThread]</button></a>
  ]
  <td class="spacer">
</table>
