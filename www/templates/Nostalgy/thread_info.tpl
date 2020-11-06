[case:[special:lang]|
  [equ:ttlPinned=Pinned thread]
  [equ:ttlLimited=Limited access thread]
  [equ:ttlUnread=[case:[Unread]|Go to last message|Go to first unread]]
  [equ:tPosts=post[case:[PostCount]|s||s]]
  [equ:ttlMark=Mark thread read]
  [equ:tViews=view[case:[ReadCount]|s||s]]
  [equ:Posters=Participants]
  [equ:Invited=Invited]
  [equ:Tags=Tags]
  [equ:Rating=Rating]
|
  [equ:ttlPinned=Забодена отгоре]
  [equ:ttlLimited=Тема с ограничен достъп]
  [equ:ttlUnread=[case:[Unread]|Към последното|Към първото непрочетено]]
  [equ:tPosts=съобщени[case:[PostCount]|я|е|я]]
  [equ:ttlMark=Маркирай темата като прочетена]
  [equ:tViews=преглед[case:[ReadCount]|а||а]]
  [equ:Posters=Участници]
  [equ:Invited=Поканени]
  [equ:Tags=Тагове]
  [equ:Rating=Рейтинг]
|
  [equ:ttlPinned=Прикрепленная на верху]
  [equ:ttlLimited=Тема ограниченным доступом]
  [equ:ttlUnread=[case:[Unread]|В край темы|К первому непрочитанному]]
  [equ:tPosts=сообщени[case:[PostCount]|й|е|й]]
  [equ:ttlMark=Отметить тему прочитанной]
  [equ:tViews=просмотр[case:[ReadCount]|ов||ов]]
  [equ:Posters=Участники]
  [equ:Invited=Приглашенные]
  [equ:Tags=Ярлыки]
  [equ:Rating=Рейтинг]
|
  [equ:ttlPinned=Sujet épinglé]
  [equ:ttlLimited=Sujet à accès limité]
  [equ:ttlUnread=[case:[Unread]|Pas de messages non-lus|Allez au premier non-lu]]
  [equ:tPosts=post[case:[PostCount]|s||s]]
  [equ:ttlMark=Marquer le sujet comme lu]
  [equ:tViews=vue[case:[ReadCount]|s||s]]
  [equ:Posters=Participants]
  [equ:Invited=Invités]
  [equ:Tags=Mots-clés]
  [equ:Rating=Évaluation]
|
  [equ:ttlPinned=Angeheftetes Thema]
  [equ:ttlLimited=Beschränktes Thema]
  [equ:ttlUnread=[case:[Unread]|Keine ungelesenen Beiträge|Springe zum ersten ungelesenen Beitrag]]
  [equ:tPosts=Beitr[case:[PostCount]|äge|ag|äge]]
  [equ:ttlMark=Thema als gelesen kennzeichnen]
  [equ:tViews=[case:[ReadCount]|Ansichten|Ansicht|Ansichten]]
  [equ:Posters=Teilnehmer]
  [equ:Invited=Eingeladen]
  [equ:Tags=Tags]
  [equ:Rating=Bewertung]
]


<table class="thread-info">
  <tr>
    <td class="tsi-link">
      <p>
      [case:[Pinned]||<img width="24" height="24" src="[special:skin]/_images/pinned.png" title="[const:ttlPinned]">]
      <a href="[Slug]/">[Caption]</a>
        <span class="unread-info">
        <a href="[Slug]/!unread" title="[const:ttlUnread]">
          [case:[Unread]
          |
          <img width="13" height="13" src="[special:skin]/_images/go-last.png">
          |
          <img width="16" height="16" src="[special:skin]/_images/go-unread.png"> ( [Unread] unread )
        </a>
            <a href="[Slug]/!markread" title="[const:ttlMark]"><img width="12" height="12" src="[special:skin]/_images/mark-read.png">
          ]
        </a></span>

      <div class="gray">[const:Posters]:
        <ul class="comma linelist">
          [html:[Posters]]
        </ul>
      </div>

      [case:[limited]||
      <div class="gray">[const:Invited]:
        <ul class="comma linelist">
          [html:[Invited]]
        </ul>
      </div>]

    <td class="tsi-stat">
      <p>[PostCount] [const:tPosts] | [ReadCount] [const:tViews]</p>
      <p>[const:Rating]: <span id="thread_rating[id]">[Rating]</span>
      <p>[TimeChanged]</p>

  <tr>
    <td class="tsi-tags" colspan="2">
      [const:Tags]:
      <ul class="comma linelist">[html:[ThreadTags]]</ul>

</table>