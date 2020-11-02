[case:[special:lang]|
  [equ:ttlPinned=Pinned thread]
  [equ:ttlLimited=Limited access thread]
  [equ:ttlUnread=[case:[Unread]|Go to last message|Go to first unread]]
  [equ:tPosts=post[case:[PostCount]|s||s]]
  [equ:ttlMark=Mark thread read]
  [equ:tViews=view[case:[ReadCount]|s||s]]
  [equ:Invited=Invited]
  [equ:Rating=Rating]
|
  [equ:ttlPinned=Забодена отгоре]
  [equ:ttlLimited=Тема с ограничен достъп]
  [equ:ttlUnread=[case:[Unread]|Към последното|Към първото непрочетено]]
  [equ:tPosts=съобщени[case:[PostCount]|я|е|я]]
  [equ:ttlMark=Маркирай темата като прочетена]
  [equ:tViews=преглед[case:[ReadCount]|а||а]]
  [equ:Invited=Поканени]
  [equ:Rating=Рейтинг]
|
  [equ:ttlPinned=Прикрепленная на верху]
  [equ:ttlLimited=Тема ограниченным доступом]
  [equ:ttlUnread=[case:[Unread]|В край темы|К первому непрочитанному]]
  [equ:tPosts=сообщени[case:[PostCount]|й|е|й]]
  [equ:ttlMark=Отметить тему прочитанной]
  [equ:tViews=просмотр[case:[ReadCount]|ов||ов]]
  [equ:Invited=Приглашенные]
  [equ:Rating=Рейтинг]
|
  [equ:ttlPinned=Sujet épinglé]
  [equ:ttlLimited=Sujet à accès limité]
  [equ:ttlUnread=[case:[Unread]|Pas de messages non-lus|Allez au premier non-lu]]
  [equ:tPosts=post[case:[PostCount]|s||s]]
  [equ:ttlMark=Marquer le sujet comme lu]
  [equ:tViews=vue[case:[ReadCount]|s||s]]
  [equ:Invited=Invités]
  [equ:Rating=Évaluation]
|
  [equ:ttlPinned=Angeheftetes Thema]
  [equ:ttlLimited=Beschränktes Thema]
  [equ:ttlUnread=[case:[Unread]|Keine ungelesenen Beiträge|Springe zum ersten ungelesenen Beitrag]]
  [equ:tPosts=Beitr[case:[PostCount]|äge|ag|äge]]
  [equ:ttlMark=Thema als gelesen kennzeichnen]
  [equ:tViews=[case:[ReadCount]|Ansichten|Ansicht|Ansichten]]
  [equ:Invited=Eingeladen]
  [equ:Rating=Bewertung]
]

  <table class="toolbar"><tr>


  <td><div>[case:[Pinned]||<img width="24" height="24" title="[const:ttlPinned]" alt="📢" src="[special:skin]/_images/pinned.png">]
    <a class="thread-link" href="[Slug]/">[Caption]</a>
    <span class="unread-info">
      <a href="[Slug]/!unread" title="[const:ttlUnread]">
      [case:[Unread]|<img width="13" height="13" alt="►" src="[special:skin]/_images/go-last.png">|<img width="16" height="16" alt="★" src="[special:skin]/_images/go-unread.png"> ( [Unread] unread )
    </a><a class="btn img-btn" href="[Slug]/!markread" title="[const:ttlMark]"><img width="12" height="12" alt="Х" src="[special:skin]/_images/mark-read.png">
      ]
    </a></span></div>
  <td class="spacer">
  [case:[limited]||
  <ul class="comma linelist">
    [const:Invited]:
    [html:[Invited]]
  </ul>
  ]

  <td> [TimeChanged], [PostCount] [const:tPosts]

  </table>
