[case:[special:lang]|
  [equ:ttlPinned=Pinned thread]
  [equ:ttlLimited=Limited access thread]
  [equ:ttlUnread=Go to first unread]
  [equ:tPosts=post[case:[PostCount]|s||s]]
  [equ:ttlMark=Mark thread read]
  [equ:tViews=[case:[ReadCount]|views|view|views]]
  [equ:Posters=Participants: ]
  [equ:Invited=Invited: ]
  [equ:Tags=Tags: ]
  [equ:unread=unread]
  [equ:Rating=Rating]
|
  [equ:ttlPinned=Забодена отгоре]
  [equ:ttlLimited=Тема с ограничен достъп]
  [equ:ttlUnread=Към първото непрочетено]
  [equ:tPosts=съобщени[case:[PostCount]|я|е|я]]
  [equ:ttlMark=Маркирай темата като прочетена]
  [equ:tViews=преглед[case:[ReadCount]|а||а]]
  [equ:Posters=Участници: ]
  [equ:Invited=Поканени: ]
  [equ:Tags=Тагове: ]
  [equ:unread=непрочетен[case:[Unread]|и|о|и]]
  [equ:Rating=Рейтинг]
|
  [equ:ttlPinned=Прикрепленная на верху]
  [equ:ttlLimited=Тема ограниченным доступом]
  [equ:ttlUnread=К первому непрочитанному]
  [equ:tPosts=сообщени[case:[PostCount]|й|е|й]]
  [equ:ttlMark=Отметить тему прочитанной]
  [equ:tViews=просмотр[case:[ReadCount]|ов||ов]]
  [equ:Posters=Участники: ]
  [equ:Invited=Приглашенные: ]
  [equ:Tags=Ярлыки: ]
  [equ:unread=непрочитанн[case:[Unread]|ых|ое|ых]]
  [equ:Rating=Рейтинг]
|
  [equ:ttlPinned=Sujet épinglé]
  [equ:ttlLimited=Sujet à accès limité]
  [equ:ttlUnread=Allez au premier non-lu]
  [equ:tPosts=post[case:[PostCount]|s||s]]
  [equ:ttlMark=Marquer le sujet comme lu]
  [equ:tViews=vue[case:[ReadCount]|s||s]]
  [equ:Posters=Participants: ]
  [equ:Invited=Invités: ]
  [equ:Tags=Mots-clés: ]
  [equ:unread=non-lu[case:[Unread]|s||s]]
  [equ:Rating=Évaluation]
|
  [equ:ttlPinned=Angeheftetes Thema]
  [equ:ttlLimited=Beschränktes Thema]
  [equ:ttlUnread=Springe zum ersten ungelesenen Beitrag]
  [equ:tPosts=Beitr[case:[PostCount]|äge|ag|äge]]
  [equ:ttlMark=Thema als gelesen kennzeichnen]
  [equ:tViews=[case:[ReadCount]|Ansichten|Ansicht|Ansichten]]
  [equ:Posters=Teilnehmer: ]
  [equ:Invited=Eingeladen: ]
  [equ:Tags=Tags: ]
  [equ:unread=ungelesene]
  [equ:Rating=Bewertung]
]

<div class="thread_summary">
  <h2>

[case:[Pinned]||<svg viewBox="0 -4 24 24" width="24" height="24" style="overflow:visible" xmlns="http://www.w3.org/2000/svg">
  <title>[const:ttlPinned]</title>
  <path d="m0 8h4l17-6v18l-17-6h-4z"/>
  <path d="m3 14 3 9 4.5-1.5-2.5-7.5z"/>
  <circle cx="21" cy="11" r="3"/>
</svg>]

[case:[limited]||<svg width="24" height="24" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
  <title>[const:ttlLimited]</title>
  <path d="m4 10-3 3v3h-1v3h1v6h-1v3h1v4h6v-4h2v4h6v-4h2v4h6v-4h2v4h6v-4h1v-3h-1v-6h1v-3h-1v-3l-3-3-3 3v3h-2v-3l-3-3-3 3v3h-2v-3l-3-3-3 3v3h-2v-3zm3 9h2v6h-2zm8 0h2v6h-2zm8 0h2v6h-2z"/>
</svg>]

[case:[Unread]||<a href="[Slug]/!unread" title="[const:ttlUnread]"><svg version="1.1" width="16" height="16" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
    <path d="m32 16-16-16v8h-16v16h16v8z"/>
  </svg></a>]

<a class="thread_link" href="[Slug]/">[Caption]</a>

[case:[Unread]||<span class="small nowrap">&nbsp;(&nbsp;[Unread]&nbsp;[const:unread]&nbsp;)&nbsp;<a href="[Slug]/!markread"
  title="[const:ttlMark]"><svg version="1.1" width="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">
    <path d="m9.9 8 5.7-5.7c.525-.525.525-1.38 0-1.9-.525-.525-1.38-.525-1.9
             0l-5.7 5.7-5.7-5.7c-.525-.525-1.38-.525-1.9 0-.525.525-.525 1.38
             0 1.9l5.7 5.7-5.7 5.7c-.525.525-.525 1.38 0 1.9.525.525 1.38.525
             1.9 0l5.7-5.7 5.7 5.7c.525.525 1.38.525 1.9 0 .525-.525.525-1.38 0-1.9z"/>
  </svg></a></span>]
  </h2>
  [PostCount] [const:tPosts] ・ [ReadCount] [const:tViews] ・ [TimeChanged]
  <label><input type="checkbox" class="collapseit"><ul class="small comma posters">[const:Posters][html:[Posters]]</ul></label>
  [case:[limited]||<label><input type="checkbox" class="collapseit"><ul class="small comma invited">[const:Invited][html:[Invited]]</ul></label>]
  [case:[ThreadTags]||<ul class="small comma thread_tags">[const:Tags][html:[ThreadTags]]</ul>]
  <div class="thread_tags">[const:Rating]: <span id="thread_rating[id]">[Rating]</span></div>
</div>
