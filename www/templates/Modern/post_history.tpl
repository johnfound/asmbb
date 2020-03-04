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


<div class="post" id="[case:[rowid]|current|[rowid]]">
  <div class="post_text">
    <a class="user_name"
      [case:[EditUser]|
        title="[PostUser] profile." href="/!userinfo/[url:[PostUser]]"><span class="nickname">[PostUser]</span><img width="128" height="128" class="avatar" alt="(ツ)" src="/!avatar/[url:[PostUser]]?v=[AVerP]">|
        title="[EditUser] profile." href="/!userinfo/[url:[EditUser]]"><span class="nickname">[EditUser]</span><img width="128" height="128" class="avatar" alt="(ツ)" src="/!avatar/[url:[EditUser]]?v=[AVerE]">
      ]
    </a>
    <article>
      [html:[[case:[format]|minimag:[include:minimag_suffix.tpl]|bbcode:][Content]]]
    </article>
  </div>

  <div class="post_info">
    <div class="last_edit">
      [case:[rowid]|<a href="#current">#current</a>|<a href="#[rowid]">#[rowid]</a>]
      [case:[EditUser]|[const:tCreated] <a href="/!userinfo/[url:[PostUser]]">[PostUser]</a>|[const:tEdited] <a href="/!userinfo/[url:[EditUser]]">[EditUser]</a>]
    </div>
    <div class="edit_tools">
      [case:[rowid]||<a  class="btn_svg" title="[const:ttlRestore]"  href="/[rowid]/!restore">
      <svg width="32" height="32" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <title>Restore</title>
        <path d="m18.29 2c-7.572 0-13.71 6.269-13.71 14h-4.572l6.095 6.222 6.095-6.222h-4.572c0-6.012
                 4.777-10.89 10.66-10.89 5.887 0 10.66 4.877 10.66 10.89 0 6.01-4.777 10.89-10.66
                 10.89-2.309 0-4.434-0.7547-6.187-2.03l-2.156 2.232c2.316 1.82 5.204 2.909 8.343 2.909
                 7.572 0 13.71-6.269 13.71-14 0-7.732-6.141-14-13.71-14z" />
        <path d="m23.24 16.11c0-2.763-2.238-5-5-5-2.762 0-5 2.237-5 5 0 2.763 2.238 5 5 5 2.762 0
                 5-2.237 5-5z"/>
      </svg>


      </a>]
    </div>
  </div>
</div>
