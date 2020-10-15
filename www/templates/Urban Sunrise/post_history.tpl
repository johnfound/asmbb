[case:[special:lang]|
  [equ:tCreated=Created: [PostTime] by]
  [equ:tEdited=Еdited: [EditTime] by]
  [equ:ttlRestore=Restore the message to this version.]
|
  [equ:tCreated=Създадено на [PostTime] от]
  [equ:tEdited=Редактирано на [EditTime] от]
  [equ:ttlRestore=Възстанови съобщението до тази версия.]
|
  [equ:tCreated=Создано [PostTime], участником]
  [equ:tEdited=Отредактировано [EditTime], участником]
  [equ:ttlRestore=Восстановить сообщение до этой версии.]
|
  [equ:tCreated=Crée le: [PostTime] par]
  [equ:tEdited=Édité le: [EditTime] par]
  [equ:ttlRestore=Restaurer le post sur ce contenu.]
|
  [equ:tCreated=Erstellt: [PostTime] von]
  [equ:tEdited=Geändert: [EditTime] von]
  [equ:ttlRestore=Beitrag auf diese Version zurücksetzen.]
]

[case:[editUserID]|
  [equ:ttlUser=[html:[PostUser]]]
  [equ:averUser=[AVerP]]
|
  [equ:ttlUser=[html:[EditUser]]]
  [equ:averUser=[AVerE]]
]


<div class="post" id="[case:[rowid]|current|[rowid]]">
  <div class="post-header">
    [case:[rowid]|<a href="#current">#current</a>|<a href="#[rowid]">#[rowid]</a>]

    <img class="avatar" alt="(ツ)" src="/!avatar/[url:[const:ttlUser]]?v=[const:averUser]">

    <a href="/!userinfo/[url:[const:ttlUser]]" class="user_name">[usr:[const:ttlUser]]</a>

    <div>[case:[editUserID]|[const:tCreated]|[const:tEdited]] <a href="/!userinfo/[url:[const:ttlUser]]">[usr:[const:ttlUser]]</a></div>

    <div class="spacer"></div>

    [case:[rowid]||<a class="btn img-btn" title="[const:ttlRestore]"  href="/[rowid]/!restore">
      <svg version="1.1" width="16" height="16" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <circle cx="16" cy="16" r="6"/>
        <path d="m16 0a16 16 0 00-16 16h4a12 12 0 0112-12 12 12 0 0112 12 12 12 0 01-12 12 12 12 0 01-8.48-3.52l-2.83 2.83a16 16 0 0011.3 4.69 16 16 0 0016-16 16 16 0 00-16-16z"/>
        <path d="m-4 16h12l-6 8z"/>
      </svg>
    </a>]

  </div>
  <article class="post-text">
    [html:[[case:[format]|minimag:[include:minimag_suffix.tpl]|bbcode:][Content]]]
  </article>
</div>
