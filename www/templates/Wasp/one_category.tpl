[case:[special:lang]|
  [equ:altNew=New]
  [equ:ttlThreads=Threads]
  [equ:ttlPosts=Posts]
  [equ:ttlUnread=Unread]
|
  [equ:altNew=Нови]
  [equ:ttlThreads=Теми]
  [equ:ttlPosts=Мнения]
  [equ:ttlUnread=Нови]
|
  [equ:altNew=Новые]
  [equ:ttlThreads=Темы]
  [equ:ttlPosts=Мнения]
  [equ:ttlUnread=Новые]
|
  [equ:altNew=Nouveau]
  [equ:ttlThreads=Sujets]
  [equ:ttlPosts=Messages]
  [equ:ttlUnread=Non-lus]
|
  [equ:altNew=Neu]
  [equ:ttlThreads=Themen]
  [equ:ttlPosts=Beiträge]
  [equ:ttlUnread=Ungelesen]
]

<div class="category">
 <div>
 [case:[Unread]|
   <img src="[special:skin]/_images/tag_gray.svg" alt="">|
   <img src="[special:skin]/_images/tag.svg" alt="[const:altNew]">
 ]
 </div>
 <a href="/[Tag]/"><span>[Tag]: </span>[Description]</a>
 <div>[const:ttlThreads]<br><span>[ThreadCnt]</span></div>
 <div>[const:ttlPosts]<br><span>[PostCnt]</span></div>
 [case:[special:userid]||<div>[const:ttlUnread]<br><span>[unread]</span></div>]
</div>