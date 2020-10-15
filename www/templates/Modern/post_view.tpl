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
  [equ:tPosts=Posts]
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

<div class="post [case:[unread]||unread]" id="[id]">
  <div class="post_text">
    [case:[UserID]||<a class="user_name" title="[UserName] profile." href="/!userinfo/[url:[html:[UserName]]]">]
      <span class="nickname">[usr:[UserName]]</span>
      <img width="96" height="96" class="avatar" alt="(ツ)" src="/!avatar/[url:[html:[UserName]]]?v=[AVer]">
    [case:[UserID]||</a>]
    <article>
      [html:[[case:[format]|minimag:[include:minimag_suffix.tpl]|bbcode:][Content]]]

      <div class="attachments">
        [attachments:[id]]
      </div>
    </article>
  </div>
  <div class="post_info">
    <a href="#[id]">#[id]</a>
    <div class="last_edit">
      [case:[editUserID]|[const:tCreated]|[const:tEdited] <a href="/!userinfo/[url:[html:[EditUser]]]">[usr:[EditUser]]</a>], [const:tRead]
    </div>
    <div class="edit_tools">
      [case:[special:canpost]||<a class="btn round" title="[const:ttlQuote]" href="[id]/!post">
        <svg version="1.1" width="20" height="20" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
          <path d="m9.02 3s-9.02 1.22-9.02 10.8v14.2h14v-14h-7.83s-1.55-1.98-.751-4.38c.801-3.2
                   4.76-3.81 4.76-3.81zm18 0s-9.02 1.22-9.02
                   10.8v14.2h14v-14h-7.83s-1.62-1.98-.814-4.38c.801-3.2 4.82-3.81 4.82-3.81z"
          />
        </svg>
      </a>]
      [case:[special:canedit]||<a class="btn round" title="[const:ttlEdit]" href="[id]/!edit"><svg version="1.1" width="20" height="20" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
         <path d="m19 4-14 14-5 14 14-5 14-14-9-9zm-13 16.4 5.6 5.6-5.6 2-2-2 2-5.6z"/>
         <path d="m20 3 9 9 3-3-9-9z"/>
        </svg></a>]
      [case:[special:candel]||<a class="btn round" title="[const:ttlDel]" href="[id]/!del"><svg version="1.1" width="20" height="20" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <path d="m5 9 3 23h16l3-23z"/>
        <rect x="5" y="4" width="22" height="3"/>
        <rect x="10" y="1.55e-15" width="2" height="4"/>
        <rect x="10" width="12" height="2"/>
        <rect x="20" width="2" height="4"/>
      </svg></a>]
      [case:[HistoryFlag]||[case:[special:isadmin]| |<a class="btn round" title="[const:ttlHist]" href="/[id]/!history">
        <svg version="1.1" width="20" height="20" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
         <circle cx="3" cy="29" r="3"/>
         <circle cx="16" cy="29" r="3"/>
         <circle cx="29" cy="29" r="3"/>
         <rect x="7" y="28" width="5" height="2"/>
         <rect x="20" y="28" width="5" height="2"/>
         <path d="m16 2c-6.08 0-11 4.92-11 11 0 6.08 4.92 11 11 11 6.08 0 11-4.92 11-11 0-6.08-4.92-11-11-11zm-1 2h2v8h6v2h-6v1.5h-2v-1.5h-1.5v-2h1.5z"/>
        </svg>
      </a>]]
    </div>
  </div>
</div>
