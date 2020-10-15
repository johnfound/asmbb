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


<div class="thread-summary">

  <div class="ts-info">
    <div class="tsi-link">
      <p[case:[Pinned]|>| title="[const:ttlPinned]">
        <svg class="svg-yellow" width="24" height="24" version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m0 9h4l17-6v18l-17-6h-4z"/>
          <path d="m3 15 3 9 4.5-1.5-2.5-7.5z"/>
          <circle cx="21" cy="12" r="3"/>
        </svg>]
        <a href="[Slug]/">[Caption]</a>
        <span class="unread-info">
        <a href="[Slug]/!unread" title="[const:ttlUnread]">
          [case:[Unread]|
            <svg class="go-last" version="1.1" width="13" height="13" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
              <path d="m0 0v32l32-16z"/>
            </svg>
          |
            <svg class="go-first" width="16" height="16" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
              <path d="m12.2 12.4 3.78-11.6 3.78 11.6 12.2 4e-4-9.89 7.19 3.78 11.6-9.89-7.18-9.89 7.19 3.78-11.6-9.89-7.19z"/>
            </svg>
            ( [Unread] unread )
        </a>
            <a href="[Slug]/!markread" title="[const:ttlMark]">
              <svg class="mark-read" version="1.1" width="12" height="12" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">
                <path d="m1.5 14.5 13-13" fill="none" stroke-linecap="round" stroke-width="4"/>
                <path d="m1.5 1.5 13 13" fill="none" stroke-linecap="round" stroke-width="4"/>
              </svg>
          ]
        </a></span>
      </p>

      <div>[const:Posters]:
        <ul class="comma posters">
          [html:[Posters]]
        </ul>
      </div>

      [case:[limited]||
      <div>[const:Invited]:
        <ul class="comma invited">
          [html:[Invited]]
        </ul>
      </div>]

    </div>
    <div class="tsi-stat">
      <p>[PostCount] [const:tPosts] | [ReadCount] [const:tViews]</p>
      <p>[const:Rating]: <span id="thread_rating[id]">[Rating]</span>
      <p>[TimeChanged]</p>
    </div>
  </div>

  <div class="ts-tags">
    [const:Tags]:
    <ul class="comma">[html:[ThreadTags]]</ul>
  </div>
</div>
