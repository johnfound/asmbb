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
  <div class="post-header">
    <a href="#[id]">
      [case:[Unread]||<svg width="16" height="16" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <path d="m12.2 12.4 3.78-11.6 3.78 11.6 12.2 4e-4-9.89 7.19 3.78 11.6-9.89-7.18-9.89 7.19 3.78-11.6-9.89-7.19z"/>
      </svg>]
      #[id]
    </a>

    <img class="avatar" alt="(ツ)" src="/!avatar/[url:[html:[UserName]]]?v=[AVer]">

    [case:[UserID]|<span|<a href="/!userinfo/[url:[html:[UserName]]]" class="user_name">
    [usr:[UserName]][case:[UserID]|</span>|</a>]

    <div>[case:[editUserID]|[const:tCreated]|[const:tEdited] <a href="/!userinfo/[url:[html:[EditUser]]]">[usr:[html:[EditUser]]]</a>], [const:tRead]</div>

    <div class="spacer"></div>

    <a title="[const:ttlQuote]" href="[case:[special:userid]|/!login|[id]/!post]" class="btn img-btn">
      <svg version="1.1" width="16" height="16" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <path d="m9.02 3s-9.02 1.22-9.02 10.8v14.2h14v-14h-7.83s-1.55-1.98-.751-4.38c.801-3.2
                 4.76-3.81 4.76-3.81zm18 0s-9.02 1.22-9.02
                 10.8v14.2h14v-14h-7.83s-1.62-1.98-.814-4.38c.801-3.2 4.82-3.81 4.82-3.81z"/>
      </svg>
    </a>

    [case:[special:canedit]| |<a title="[const:ttlEdit]" href="[id]/!edit" class="btn img-btn">
      <svg version="1.1" width="16" height="16" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <path d="m19 4-14 14-5 14 14-5 14-14-9-9zm-13 16.4 5.6 5.6-5.6 2-2-2 2-5.6z"/>
        <path d="m20 3 9 9 3-3-9-9z"/>
      </svg>
    </a>]

    [case:[special:candel] | |<a title="[const:ttlDel]" href="[id]/!del" class="btn img-btn">
      <svg version="1.1" width="16" height="16" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <path d="m5 9 3 23h16l3-23z"/>
        <rect x="5" y="4" width="22" height="3"/>
        <rect x="10" y="1.55e-15" width="2" height="4"/>
        <rect x="10" width="12" height="2"/>
        <rect x="20" width="2" height="4"/>
      </svg>
    </a>]

    [case:[HistoryFlag]||[case:[special:isadmin]| |<a title="[const:ttlHist]" href="/[id]/!history" class="btn img-btn">
      <svg version="1.1" width="16" height="16" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
       <circle cx="3" cy="29" r="3"/>
       <circle cx="16" cy="29" r="3"/>
       <circle cx="29" cy="29" r="3"/>
       <rect x="7" y="28" width="5" height="2"/>
       <rect x="20" y="28" width="5" height="2"/>
       <path d="m16 2c-6.08 0-11 4.92-11 11 0 6.08 4.92 11 11 11 6.08 0 11-4.92 11-11 0-6.08-4.92-11-11-11zm-1 2h2v8h6v2h-6v1.5h-2v-1.5h-1.5v-2h1.5z"/>
      </svg>
    </a>]]
  </div>

  <article class="post-text">
    [html:[[case:[format]|minimag:[include:minimag_suffix.tpl]|bbcode:][Content]]]

  </article>

    <div class="attachments">
      [attachments:[id]]
    </div>

</div>
