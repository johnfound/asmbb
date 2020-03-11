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
]

<div class="thread_summary">
  <h2>

[case:[Pinned]||<svg viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
  <title>[const:ttlPinned]</title>
  <path d="m17.972 3.054-12.366 4.946h-3.356c-1.24 0-2.25 1.01-2.25 2.25v2.75c0 1.178.925 2 2.25 2h.85l.908
           6.356c.053.37.369.644.742.644h3c.214 0 .417-.091.56-.25.142-.159.21-.371.186-.584l-.59-5.246
           10.065 4.026c.091.036.185.054.279.054.147 0
           .295-.044.421-.129.206-.14.329-.372.329-.621v-15.5c0-.249-.123-.481-.329-.621-.207-.14-.469-.168-.699-.075z"
  />
  <path d="m21.219 9.336 2.5-2c.323-.259.376-.731.117-1.055-.26-.322-.731-.374-1.055-.117l-2.5
           2c-.323.259-.376.731-.117 1.055.148.184.366.281.586.281.165 0 .33-.054.469-.164z"
  />
  <path d="m21.219 14.664c-.322-.257-.794-.205-1.055.117-.259.323-.206.796.117 1.055l2.5 2c.139.11.304.164.469.164.22
           0 .438-.097.586-.281.259-.323.206-.796-.117-1.055z"/><path d="m23.25 11.25h-2.5c-.414
           0-.75.336-.75.75s.336.75.75.75h2.5c.414 0 .75-.336.75-.75s-.336-.75-.75-.75z"
  />
</svg>]

[case:[limited]||<svg width="24" height="24" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
  <title>[const:ttlLimited]</title>
  <path d="m4 4-3 3v3h-1v3h1v6h-1v3h1v4h6v-4h2v4h6v-4h2v4h6v-4h2v4h6v-4h1v-3h-1v-6h1v-3h-1v-3l-3-3-3 3v3h-2v-3l-3-3-3 3v3h-2v-3l-3-3-3 3v3h-2v-3zm3 9h2v6h-2zm8 0h2v6h-2zm8 0h2v6h-2z"/>
</svg>]

[case:[Unread]||<a href="[FirstUnread]/!by_id" title="[const:ttlUnread]"><svg version="1.1" width="16" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
    <path d="m32 16-16-16v8h-16v16h16v8z"/>
  </svg></a>]

<a class="thread_link" href="[Slug]/">[Caption]</a>

[case:[Unread]||<span class="small nowrap">&nbsp;(&nbsp;[Unread]&nbsp;[const:unread]&nbsp;)&nbsp;<a href="[Slug]/!markread"
  title="[const:ttlMark]"><svg version="1.1" width="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">
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
</div>
