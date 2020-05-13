[case:[special:lang]|
  [equ:ttlPinned=Pinned thread]
  [equ:ttlLimited=Limited access thread]
  [equ:ttlUnread=[case:[Unread]|No unread messages|Go to first unread]]
  [equ:tPosts=post[case:[PostCount]|s||s]]
  [equ:ttlMark=Mark thread read]
  [equ:tViews=view[case:[ReadCount]|s||s]]
  [equ:Posters=Participants]
  [equ:Invited=Invited]
  [equ:Tags=Tags]
|
  [equ:ttlPinned=Забодена отгоре]
  [equ:ttlLimited=Тема с ограничен достъп]
  [equ:ttlUnread=[case:[Unread]|Няма нови съобщения|Към първото непрочетено]]
  [equ:tPosts=съобщени[case:[PostCount]|я|е|я]]
  [equ:ttlMark=Маркирай темата като прочетена]
  [equ:tViews=преглед[case:[ReadCount]|а||а]]
  [equ:Posters=Участници]
  [equ:Invited=Поканени]
  [equ:Tags=Тагове]
|
  [equ:ttlPinned=Прикрепленная на верху]
  [equ:ttlLimited=Тема ограниченным доступом]
  [equ:ttlUnread=[case:[Unread]|Нет новых сообщений|К первому непрочитанному]]
  [equ:tPosts=сообщени[case:[PostCount]|й|е|й]]
  [equ:ttlMark=Отметить тему прочитанной]
  [equ:tViews=просмотр[case:[ReadCount]|ов||ов]]
  [equ:Posters=Участники]
  [equ:Invited=Приглашенные]
  [equ:Tags=Ярлыки]
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
]


<div class="thread-summary">

  <div class="ts-info">
    <div class="tsi-link">
      <p>[case:[Pinned]||
        <svg class="svg-yellow" width="24" height="24" version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" title="[const:ttlPinned]">
          <path d="m0 9h4l17-6v18l-17-6h-4z"/>
          <path d="m3 15 3 9 4.5-1.5-2.5-7.5z"/>
          <circle cx="21" cy="12" r="3"/>
        </svg>]
        <a href="[Slug]/">[Caption]</a>
        [case:[Unread]||<span class="unread-info"><a class="unread-info" href="[FirstUnread]/!by_id" title="[const:ttlUnread]">
          ( [Unread] unread )</a> <a href="[Slug]/!markread" title="[const:ttlMark]">
        <svg version="1.1" width="12" height="12" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">
          <path d="m1.5 14.5 13-13" fill="none" stroke-linecap="round" stroke-width="4"/>
          <path d="m1.5 1.5 13 13" fill="none" stroke-linecap="round" stroke-width="4"/>
        </svg></a></span>]
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
      <p>[TimeChanged]</p>
    </div>
  </div>

  <div class="ts-tags">
    [const:Tags]:
    <ul class="comma">[html:[ThreadTags]]</ul>
  </div>
</div>
