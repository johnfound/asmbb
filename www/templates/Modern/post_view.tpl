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

<div class="post" id="[id]">
  <div class="post_text">
    [case:[UserID]||<a class="user_name" title="[UserName] profile." href="/!userinfo/[url:[UserName]]">]
      <span class="nickname">[UserName]</span>
      <img width="128" height="128" class="avatar" alt="(ツ)" src="/!avatar/[url:[UserName]]?v=[AVer]">
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
      [case:[EditUser]|[const:tCreated]|[const:tEdited] <a href="/!userinfo/[url:[EditUser]]">[EditUser]</a>], [const:tRead]
    </div>
    <div class="edit_tools">
      [case:[special:canpost]||<a class="btn round" title="[const:ttlQuote]" href="[id]/!post">
        <svg version="1.1" width="20" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
          <path d="m9.02 3s-9.02 1.22-9.02 10.8v14.2h14v-14h-7.83s-1.55-1.98-.751-4.38c.801-3.2
                   4.76-3.81 4.76-3.81zm18 0s-9.02 1.22-9.02
                   10.8v14.2h14v-14h-7.83s-1.62-1.98-.814-4.38c.801-3.2 4.82-3.81 4.82-3.81z"
          />
        </svg>
      </a>]
      [case:[special:canedit]||<a class="btn round" title="[const:ttlEdit]" href="[id]/!edit"><svg version="1.1" width="20" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
         <path d="m19 4-14 14-5 14 14-5 14-14-9-9zm-13 16.4 5.6 5.6-5.6 2-2-2 2-5.6z"/>
         <path d="m20 3 9 9 3-3-9-9z"/>
        </svg></a>]
      [case:[special:candel]||<a class="btn round" title="[const:ttlDel]" href="[id]/!del"><svg version="1.1" width="20" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <path d="m7.31 29.8s.488 2.17 3 2.17h11.4c2.51 0 3-2.17 3-2.17l2.25-21.3h-21.9l2.25 21.3zm13.1-18.1c0-.589.49-1.07
                 1.09-1.07s1.09.478 1.09 1.07l-1.09 16c0 .589-.49 1.07-1.09 1.07s-1.09-.478-1.09-1.07zm-5.46 0c0-.589.49-1.07
                 1.09-1.07s1.09.478 1.09 1.07v16c0 .589-.49 1.07-1.09 1.07s-1.09-.478-1.09-1.07zm-4.37-1.07c.603 0 1.09.478
                 1.09 1.07l1.09 16c0 .589-.49 1.07-1.09 1.07s-1.09-.478-1.09-1.07l-1.05-16c0-.589.49-1.07
                 1.09-1.07zm15.7-6.4h-4.81v-2.13c0-1.61-.488-2.12-2.2-2.12h-6.59c-1.46 0-2.14.715-2.14 2.13v2.13h-4.81c-.966
                 0-1.75.716-1.75 1.6 0 .884.781 1.6 1.75 1.6h20.5c.966 0 1.75-.716 1.75-1.6 0-.884-.781-1.6-1.75-1.6zm-6.99
                 0h-6.56l.000122-2.13h6.56v2.13z"
               style="clip-rule:evenodd;fill-rule:evenodd"
        />
      </svg></a>]
      [case:[HistoryFlag]||[case:[special:isadmin]| |<a class="btn round" title="[const:ttlHist]" href="/[id]/!history">
        <svg version="1.1" width="20" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
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
