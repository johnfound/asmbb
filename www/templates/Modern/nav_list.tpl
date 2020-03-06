[css:navigation.css]
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
  <span class="spacer"></span>
  [case:[special:limited]|<a class="btn" href="!feed" title="[const:rssfeed]"><svg class="listfeed" height="19" width="19" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
    <title>RSS</title>
    <path d="m8.8 27.6c0 2.43-1.97 4.4-4.4 4.4s-4.4-1.97-4.4-4.4 1.97-4.4 4.4-4.4 4.4 1.97 4.4 4.4z"/>
    <path d="m21.2 32h-6.2c0-8.2-6.8-15-15-15v-6.2c11.8 0 21.2 9.4 21.2 21.2z"/>
    <path d="m25.6 32c0-14.2-11.4-25.6-25.6-25.6v-6.4c17.6 0 32 14.4 32 32z"/>
  </svg></a>|]
</div>
