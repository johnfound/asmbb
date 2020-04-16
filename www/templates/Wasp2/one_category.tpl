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
    <svg class="svg-[case:[Unread]|gray|yellow]" version="1.1" width="24" height="24" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
      <path d="m29 2.5e-7h-9c-1.7 0-4 .96-5.1 2.1l-14 14c-1.2 1.2-1.2 3.1 0
               4.3l11 11c1.2 1.2 3.1 1.2 4.3 0l14-14c1.2-1.2 2.1-3.5 2.1-5.1v-9c-6e-5-1.7-1.4-3-3-3zm-4
               10c-1.7 0-3-1.3-3-3s1.3-3 3-3c1.7 0 3 1.3 3 3s-1.3 3-3 3z"/>
    </svg>
  </div>
  <a href="/[Tag]/"><span>[Tag]: </span>[Description]</a>
  <div>[const:ttlThreads]<br><span>[ThreadCnt]</span></div>
  <div>[const:ttlPosts]<br><span>[PostCnt]</span></div>
  [case:[special:userid]||<div>[const:ttlUnread]<br><span>[unread]</span></div>]
</div>