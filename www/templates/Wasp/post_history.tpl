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


<div class="post">
  <div class="user_info">
    [case:[editUserID]|
      <a class="user_name" href="/!userinfo/[url:[html:[PostUser]]]">[usr:[PostUser]]</a><div class="avatar"><img class="avatar" alt="(ツ)" src="/!avatar/[url:[html:[PostUser]]]?v=[AVerP]"></div>|
      <a class="user_name" href="/!userinfo/[url:[html:[EditUser]]]">[usr:[EditUser]]</a><div class="avatar"><img class="avatar" alt="(ツ)" src="/!avatar/[url:[html:[EditUser]]]?v=[AVerE]"></div>]
  </div>
  <div class="post_text">
    <div class="post_info">
      <div class="last_edit">
        [case:[rowid]|<a href="#current">#current</a>|<a href="#[rowid]">#[rowid]</a>]
        [case:[editUserID]|[const:tCreated] <a href="/!userinfo/[url:[html:[PostUser]]]">[usr:[PostUser]]</a>|[const:tEdited] <a href="/!userinfo/[url:[html:[EditUser]]]">[usr:[EditUser]]</a>]
      </div>
      <div class="edit_tools">
        [case:[rowid]||<a title="[const:ttlRestore]"  href="/[rowid]/!restore"><img src="[special:skin]/_images/restore.svg" alt="Restore"></a>]
      </div>
    </div>
    <article>
      [html:[[case:[format]|minimag:[include:minimag_suffix.tpl]|bbcode:][Content]]]
    </article>
  </div>
</div>
