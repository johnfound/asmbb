[case:[special:lang]|
  [equ:ttlLong=long ago]
  [equ:ttlNever=never]
  [equ:ttlSkin=Skin]
  [equ:ttlPostCnt=Posts]
  [equ:ttlRegist=Registered]
  [equ:ttlSeen=Last seen]
|
  [equ:ttlLong=Много отдавна]
  [equ:ttlNever=Никога]
  [equ:ttlSkin=Тема]
  [equ:ttlPostCnt=Постове]
  [equ:ttlRegist=Регистриран]
  [equ:ttlSeen=Онлайн]
|
  [equ:ttlLong=очень давно]
  [equ:ttlNever=никогда]
  [equ:ttlSkin=Тема]
  [equ:ttlPostCnt=Посты]
  [equ:ttlRegist=Зарегистрирован]
  [equ:ttlSeen=Онлайн]
|
  [equ:ttlLong=Il y a longtemps]
  [equ:ttlNever=Jamais]
  [equ:ttlSkin=Thème]
  [equ:ttlPostCnt=Nombre de messages]
  [equ:ttlRegist=Date d'inscription]
  [equ:ttlSeen=Dernière connexion]
|
  [equ:ttlLong=vor langer Zeit]
  [equ:ttlNever=niemals]
  [equ:ttlSkin=Theme]
  [equ:ttlPostCnt=Beiträge]
  [equ:ttlRegist=Registriert]
  [equ:ttlSeen=Zuletzt gesehen]
]

<a class="oneuser" href="/!userinfo/[url:[html:[UserName]]]">
    <div class="nick">[usr:[UserName]]</div>
    <img class="avatar" src="/!avatar/[url:[html:[UserName]]]?v=[av_time]" alt=":)">
    <div><span>[const:ttlSkin]: </span>[case:[Skin]|default|[Skin]]</div>
    <div><span>[const:ttlPostCnt]: </span>[PostCount]</div>
    <div class="small"><span>[const:ttlRegist]: </span>[case:[fRegister]|[const:ttlLong]|[RegisterStr]]</div>
    <div class="small"><span>[Const:ttlSeen]: </span>[case:[fLast]|[const:ttlNever]|[LastSeenStr]]</div>
</a>
