[case:[special:lang]|
  [equ:tPosts=Posts]
  [equ:tCreated=Created [PostTime]]
  [equ:tEdited=Last edited: [EditTime] by]
  [equ:tRead=read: [ReadCount] [case:[ReadCount]|times|time|times]]
  [equ:ttlQuote=Quote this post]
  [equ:ttlEdit=Edit this post]
  [equ:ttlDel=Delete this post]
  [equ:ttlHist=Show the post history]
|
  [equ:tPosts=Постове]
  [equ:tCreated=Създадено на [PostTime]]
  [equ:tEdited=Последно редактирано на [EditTime] от]
  [equ:tRead=видяно: [ReadCount] пъти.]
  [equ:ttlQuote=Цитирай това съобщение]
  [equ:ttlEdit=Редактирай това съобщение]
  [equ:ttlDel=Изтрий това съобщение]
  [equ:ttlHist=Покажи историята на измененията]
|
  [equ:tPosts=Посты]
  [equ:tCreated=Создано [PostTime]]
  [equ:tEdited=Отредактировано [EditTime], участником]
  [equ:tRead=прочитано [ReadCount] раз]
  [equ:ttlQuote=Цитировать это сообщение]
  [equ:ttlEdit=Редактировать это сообщение]
  [equ:ttlDel=Удалить сообщение]
  [equ:ttlHist=Показать историю изменений]
|
  [equ:tPosts=Messages]
  [equ:tCreated=Crée le: [PostTime]]
  [equ:tEdited=Édité le: [EditTime] by]
  [equ:tRead=lu: [ReadCount] fois]
  [equ:ttlQuote=Citer ce message]
  [equ:ttlEdit=Éditer ce message]
  [equ:ttlDel=Supprimer ce message]
  [equ:ttlHist=Montrer l'historique du message]
|
  [equ:tPosts=Posts]
  [equ:tCreated=Erstellt am [PostTime]]
  [equ:tEdited=Zuletzt geändert: [EditTime] von]
  [equ:tRead=gelesen: [ReadCount]-mal]
  [equ:ttlQuote=Diesen Beitrag zitieren]
  [equ:ttlEdit=Diesen Beitrag ändern]
  [equ:ttlDel=Diesen Beitrag löschen]
  [equ:ttlHist=Beitragsverlauf anzeigen]
]

<div class="post" id="[id]">
  <table class="toolbar post-header"><tr>
    <td><a href="#[id]">
      [case:[Unread]||<img width="16" height="16" alt="★" src="[special:skin]/_images/go-unread.png">]
      #[id]
    </a>

    <td><div><img class="avatar" alt="(ツ)" src="/!avatar/[url:[html:[UserName]]]?v=[AVer]"></div>

    <td>[case:[UserID]|<span|<a href="/!userinfo/[url:[html:[UserName]]]" class="user_name">
    [usr:[UserName]][case:[UserID]|</span>|</a>]

    <td><div>[case:[editUserID]|[const:tCreated]|[const:tEdited] <a href="/!userinfo/[url:[html:[EditUser]]]">[usr:[html:[EditUser]]]</a>], [const:tRead]</div>

    <td class="spacer">

    <td><a title="[const:ttlQuote]" href="[case:[special:userid]|/!login|[id]/!post]" class="btn img-btn"><img width="16" height="16" alt="Quote" src="[special:skin]/_images/quote.png"></a>
    [case:[special:canedit]| |<td><a title="[const:ttlEdit]" href="[id]/!edit" class="btn img-btn"><img width="16" height="16" alt="Edit" src="[special:skin]/_images/edit.png"></a>]
    [case:[special:candel] | |<td><a title="[const:ttlDel]" href="[id]/!del" class="btn img-btn"><img width="16" height="16" alt="Delete" src="[special:skin]/_images/del.png"></a>]
    [case:[HistoryFlag]||[case:[special:isadmin]| |<td><a title="[const:ttlHist]" href="/[id]/!history" class="btn img-btn"><img width="16" height="16" alt="History" src="[special:skin]/_images/history.png"></a>]]
  </table>

  <article class="post-text">
    [html:[[case:[format]|minimag:[include:minimag_suffix.tpl]|bbcode:][Content]]]
  </article>

  <div class="attachments">
    [attachments:[id]]
  </div>

</div>
