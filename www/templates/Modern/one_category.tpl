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

<a class="category" href="/[Tag]/">
  <h2>
    <svg [case:[Unread]|class="disabled"|] version="1.1" width="32" hwight="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
      <path d="m29 2.5e-7h-9c-1.7 0-4 .96-5.1 2.1l-14 14c-1.2 1.2-1.2 3.1 0
               4.3l11 11c1.2 1.2 3.1 1.2 4.3 0l14-14c1.2-1.2 2.1-3.5 2.1-5.1v-9c-6e-5-1.7-1.4-3-3-3zm-4
               10c-1.7 0-3-1.3-3-3s1.3-3 3-3c1.7 0 3 1.3 3 3s-1.3 3-3 3z"
      />
    </svg>
    <span>[Tag]:&nbsp;</span>[Description]
  </h2>
 <div>
   <p>[const:ttlThreads]: <b>[ThreadCnt]</b></p>
   <p>[const:ttlPosts]: <b>[PostCnt]</b></p>
   [case:[special:userid]||<p>[const:ttlUnread]: <b>[unread]</b></p>]
 </div>
</a>
