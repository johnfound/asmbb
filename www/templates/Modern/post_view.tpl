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
    <svg class="onepost [case:[Unread]||newpost]" version="1.1" width="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
      [case:[Unread]||<title>New post</title>]
      <path d="m4 2c-2.23 0-4 1.86-4 4v14c0 2.15 1.79 4 4 4h1v6l10-6h13c2.21 0 4-1.85
               4-4v-14c0-2.12-1.84-4-4-4-7.89.00208-16.1 0-24 0zm3.54 13.6c-1.18
               0-2.14-1.09-2.14-2.08-1e-7-.994.957-2.08 2.14-2.08 1.18 0 2.14.932
               2.14 2.08 0 1.15-.957 2.08-2.14 2.08zm8.55 0c-1.18 0-2.14-.932-2.14-2.08
               0-1.15.957-2.08 2.14-2.08 1.18 0 2.14.932 2.14 2.08 0 1.15-.957 2.08-2.14
               2.08zm8.54 0c-1.18 0-2.14-.932-2.14-2.08 0-1.15.957-2.08 2.14-2.08 1.18 0
               2.14.932 2.14 2.08.00012 1.15-.957 2.08-2.14 2.08z"
             style="clip-rule:evenodd;fill-rule:evenodd"
      />
    </svg><a href="#[id]">#[id]</a>
    <div class="last_edit">
      [case:[EditUser]|[const:tCreated]|[const:tEdited] <a href="/!userinfo/[url:[EditUser]]">[EditUser]</a>], [const:tRead]
    </div>
    <div class="edit_tools">
      [case:[special:canpost]||<a title="[const:ttlQuote]" href="[id]/!post"><svg class="quote" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <title>Quote</title>
        <path d="m4 2c-2.23 0-4 1.86-4 4v14c0 2.15 1.79 4 4 4h1v6l10-6h13c2.21 0 4-1.85
                 4-4v-14c0-2.12-1.84-4-4-4-7.89.00208-16.1 0-24 0zm3.54 13.6c-1.18
                 0-2.14-1.09-2.14-2.08-1e-7-.994.957-2.08 2.14-2.08 1.18 0 2.14.932
                 2.14 2.08 0 1.15-.957 2.08-2.14 2.08zm8.55 0c-1.18 0-2.14-.932-2.14-2.08
                 0-1.15.957-2.08 2.14-2.08 1.18 0 2.14.932 2.14 2.08 0 1.15-.957 2.08-2.14
                 2.08zm8.54 0c-1.18 0-2.14-.932-2.14-2.08 0-1.15.957-2.08 2.14-2.08 1.18 0
                 2.14.932 2.14 2.08.00012 1.15-.957 2.08-2.14 2.08z"
              style="clip-rule:evenodd;fill-rule:evenodd"
        />
      </svg></a>]
      [case:[special:canedit]||<a title="[const:ttlEdit]" href="[id]/!edit"><svg class="edit" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <title>Edit</title>
        <path d="m19.2 6.7c-.835-.84-2.2-.84-3.02 0l-.755.76-10.6 10.6.00273.0027-.334.335s-1.06 1.07-3.45
                 8.85l-.125.19c-.0436.19-.0854.381-.129.381-.0398.19-.0778.381-.118.381l-.0987.381c-.0761.255-.153.514-.231.782-.173.588-.594
                 1.92-.117 2.4.459.461 1.79.0556 2.37-.118.264-.0788.522-.156.774-.232.116-.0352.23-.0697.343-.105.122-.0373.245-.0744.362-.111.151-.0464.3-.0921.444-.138.0435-.0135.0861-.027.129-.0404
                 7.38-2.3 8.71-3.39 8.8-3.48.000833-.000594.000833-.000594.0014-.0012.0046-.0044.0078-.0072.0078-.0072l.342-.345.023.023
                 10.6-10.6-.000118-.000119.755-.76c.835-.84.835-2.21 0-3.03l-6.05-6.07zm-6.87
                 19.4c-.0093.0063-.0218.0145-.0351.023-.0073.0047-.0162.0103-.025.0158-.0089.0055-.0186.0116-.0288.0179-.0091.0055-.0186.0112-.0288.0175-.353.211-1.39.758-3.89
                 1.67-.292.106-.611.219-.947.335l-3.57-3.58c.116-.339.23-.661.336-.956.907-2.51 1.45-3.58
                 1.66-3.92.0051-.0084.00973-.0162.0143-.0238.00734-.0122.0142-.0234.0207-.0339.0051-.0082.0104-.0168.0149-.0238.00842-.0131.0166-.0259.023-.0352l.262-.263 6.47
                 6.49-.268.268zm19-19.4-6.05-6.07c-.835-.84-2.2-.84-3.02 0l-1.42 1.51c-.835.84-.835 2.21 0 3.03l6.05 6.07c.835.84 2.2.84 3.02 0l1.51-1.52c.835-.84.835-2.21 0-3.03z"
              style="clip-rule:evenodd;fill-rule:evenodd"
        />
      </svg></a>]
      [case:[special:candel]||<a title="[const:ttlDel]" href="[id]/!del"><svg class="delbtn" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <title>Del</title>
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
      [case:[HistoryFlag]||[case:[special:isadmin]| |<a title="[const:ttlHist]" href="/[id]/!history"><svg class="history" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <title>History</title>
        <path d="m7.75 5.26h16.5c1.52 0 2.74-1.17 2.74-2.62 0-1.48-1.22-2.64-2.74-2.64h-16.5c-1.52 0-2.74 1.17-2.74 2.62s1.23 2.64 2.74 2.64z" />
        <path d="m24.3 26.8h-16.5c-1.52 0-2.74 1.17-2.74 2.62 0 1.45 1.22 2.62 2.74 2.62h16.5c1.52 0 2.74-1.17 2.74-2.62 0-1.42-1.22-2.62-2.74-2.62z"/>
        <path d="m24.1 7.01v-.484h-16.1v.484c0 4.12 2.18 7.65 5.27 9-3.09 1.35-5.3 4.86-5.3 9v.484h16.1v-.484c0-4.12-2.18-7.65-5.27-9 3.11-1.35 5.32-4.86 5.32-9z"/>
      </svg></a>]]
    </div>
  </div>
</div>
