[case:[special:lang]|
  [equ:tPosts=Posts]
  [equ:tCreated=Created [PostTime]]
  [equ:tEdited=Last edited: [EditTime] by]
  [equ:tRead=read: [ReadCount] [case:[ReadCount]|times|time|times]]
  [equ:ttlQuote=Quote this post]
  [equ:ttlEdit=Edit this post]
  [equ:ttlDel=Delete this post]
  [equ:ttlHist=Show the post history]
  [equ:altQuote=Quote]
  [equ:altEdit=Edit]
  [equ:altDel=Del]
  [equ:altHist=History]
|
  [equ:tPosts=Постове]
  [equ:tCreated=Създадено на [PostTime]]
  [equ:tEdited=Последно редактирано на [EditTime] от]
  [equ:tRead=видяно: [ReadCount] пъти.]
  [equ:ttlQuote=Цитирай това съобщение]
  [equ:ttlEdit=Редактирай това съобщение]
  [equ:ttlDel=Изтрий това съобщение]
  [equ:ttlHist=Покажи историята на измененията]
  [equ:altQuote=Цитирай]
  [equ:altEdit=Редактирай]
  [equ:altDel=Изтрий]
  [equ:altHist=История]
|
  [equ:tPosts=Посты]
  [equ:tCreated=Создано [PostTime]]
  [equ:tEdited=Отредактировано [EditTime], участником]
  [equ:tRead=прочитано [ReadCount] раз]
  [equ:ttlQuote=Цитировать это сообщение]
  [equ:ttlEdit=Редактировать это сообщение]
  [equ:ttlDel=Удалить сообщение]
  [equ:ttlHist=Показать историю изменений]
  [equ:altQuote=Цитировать]
  [equ:altEdit=Редактировать]
  [equ:altDel=Удалить]
  [equ:altHist=История]
|
  [equ:tPosts=Messages]
  [equ:tCreated=Crée le: [PostTime]]
  [equ:tEdited=Édité le: [EditTime] by]
  [equ:tRead=lu: [ReadCount] fois]
  [equ:ttlQuote=Citer ce message]
  [equ:ttlEdit=Éditer ce message]
  [equ:ttlDel=Supprimer ce message]
  [equ:ttlHist=Montrer l'historique du message]
  [equ:altQuote=Citer]
  [equ:altEdit=Éditer]
  [equ:altDel=Supprimer]
  [equ:altHist=Historique]
|
  [equ:tPosts=Beiträge]
  [equ:tCreated=Erstellt am [PostTime]]
  [equ:tEdited=Zuletzt geändert: [EditTime] von]
  [equ:tRead=gelesen: [ReadCount]-mal]
  [equ:ttlQuote=Diesen Beitrag zitieren]
  [equ:ttlEdit=Diesen Beitrag ändern]
  [equ:ttlDel=Diesen Beitrag löschen]
  [equ:ttlHist=Beitragsverlauf anzeigen]
  [equ:altQuote=Zitat]
  [equ:altEdit=Ändern]
  [equ:altDel=Löschen]
  [equ:altHist=Verlauf]
]

<div class="post" id="[id]">
  <div class="user_info">
    <div class="username">
      <img width="32" height="32" class="unread" [case:[Unread]|src="[special:skin]/_images/onepost_gray.svg" alt="">|src="[special:skin]/_images/onepost.svg" alt="&gt;">]
      [case:[UserID]||<a class="user_name" href="/!userinfo/[url:[html:[UserName]]]">][usr:[UserName]][case:[UserID]||</a>]
    </div>
    <div class="avatar">
      <img class="avatar" alt="(ツ)" src="/!avatar/[url:[html:[UserName]]]?v=[AVer]">
      <div class="user_pcnt">[const:tPosts]: [UserPostCount]</div>
    </div>
  </div>
  <div class="post_text">
    <div class="post_info">
      <div class="last_edit">
        <a href="#[id]">#[id]</a>
        [case:[editUserID]|[const:tCreated]|[const:tEdited] <a href="/!userinfo/[url:[html:[EditUser]]]">[usr:[EditUser]]</a>], [const:tRead]
      </div>
      <div class="edit_tools">
        [case:[special:canpost]| |<a title="[const:ttlQuote]" href="[id]/!quote"><img src="[special:skin]/_images/quote.svg" alt="[const:altQuote]"></a>]
        [case:[special:canedit]| |<a title="[const:ttlEdit]" href="[id]/!edit"><img src="[special:skin]/_images/edit.svg" alt="[const:altEdit]"></a>]
        [case:[special:candel] | |<a title="[const:ttlDel]" href="[id]/!del"><img src="[special:skin]/_images/del.svg" alt="[const:altDel]"></a>]
        [case:[HistoryFlag]||[case:[special:isadmin]| |<a title="[const:ttlHist]" href="/[id]/!history"><img src="[special:skin]/_images/history.svg" alt="[const:altHist]"></a>]]
      </div>
    </div>
    <article>
      [html:[[case:[format]|minimag:[include:minimag_suffix.tpl]|bbcode:][Content]]]

      <div class="attachments">
        [attachments:[id]]
      </div>
    </article>
  </div>
</div>
