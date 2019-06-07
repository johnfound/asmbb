[case:[special:lang]|
  [equ:ttlPinned=Pinned thread]
  [equ:ttlLimited=Limited access thread]
  [equ:ttlUnread=[case:[Unread]|No unread messages|Go to first unread]]
  [equ:tPosts=post[case:[PostCount]|s||s]]
  [equ:ttlMark=Mark thread read]
  [equ:tViews=[case:[ReadCount]|views|view|views]]
  [equ:Posters=Participants: ]
  [equ:Invited=Invited: ]
|
  [equ:ttlPinned=Забодена отгоре]
  [equ:ttlLimited=Тема с ограничен достъп]
  [equ:ttlUnread=[case:[Unread]|Няма нови съобщения|Към първото непрочетено]]
  [equ:tPosts=съобщени[case:[PostCount]|я|е|я]]
  [equ:ttlMark=Маркирай темата като прочетена]
  [equ:tViews=преглед[case:[ReadCount]|а||а]]
  [equ:Posters=Участници: ]
  [equ:Invited=Поканени: ]
|
  [equ:ttlPinned=Прикрепленная на верху]
  [equ:ttlLimited=Тема ограниченным доступом]
  [equ:ttlUnread=[case:[Unread]|Нет новых сообщений|К первому непрочитанному]]
  [equ:tPosts=сообщени[case:[PostCount]|й|е|й]]
  [equ:ttlMark=Отметить тему прочитанной]
  [equ:tViews=просмотр[case:[ReadCount]|ов||ов]]
  [equ:Posters=Участники: ]
  [equ:Invited=Приглашенные: ]
|
  [equ:ttlPinned=Sujet épinglé]
  [equ:ttlLimited=Sujet à accès limité]
  [equ:ttlUnread=[case:[Unread]|Pas de messages non-lus|Allez au premier non-lu]]
  [equ:tPosts=post[case:[PostCount]|s||s]]
  [equ:ttlMark=Marquer le sujet comme lu]
  [equ:tViews=vue[case:[ReadCount]|s||s]]
  [equ:Posters=Participants: ]
  [equ:Invited=Invités: ]
|
  [equ:ttlPinned=Angeheftetes Thema]
  [equ:ttlLimited=Beschränktes Thema]
  [equ:ttlUnread=[case:[Unread]|Keine ungelesenen Beiträge|Springe zum ersten ungelesenen Beitrag]]
  [equ:tPosts=Beitr[case:[PostCount]|äge|ag|äge]]
  [equ:ttlMark=Thema als gelesen kennzeichnen]
  [equ:tViews=[case:[ReadCount]|Ansichten|Ansicht|Ansichten]]
  [equ:Posters=Teilnehmer: ]
  [equ:Invited=Eingeladen: ]
]

<div class="thread_summary">
      [case:[Pinned]||<img class="pinned" src="[special:skin]/_images/pinned.png" alt="!" title="[const:ttlPinned]">]
      [case:[limited]||<img height="32" width="32" class="unread" src="[special:skin]/_images/limited.svg" alt="#" title="[const:ttlLimited]">]
      [case:[Unread]||<a href="[FirstUnread]/!by_id">]<img height="32" width="32" class="unread" src="[special:skin]/_images/posts[case:[Unread]|_gray|].svg" alt="[case:[Unread]||&gt;]" title="[const:ttlUnread]">[case:[Unread]||</a>]
  <div class="thread_link">
    <a class="thread_link" href="[Slug]/">[Caption]</a><br>
    <label><input type="checkbox" class="collapseit"><ul class="small comma posters">[const:Posters][html:[Posters]]</ul></label>
    [case:[limited]||<label><input type="checkbox" class="collapseit"><ul class="small comma invited">[const:Invited][html:[Invited]]</ul></label>]
  </div>
  <ul class="thread_tags">[html:[ThreadTags]]</ul>
  <div class="col_date">
      [PostCount] [const:tPosts]<br>
    [case:[Unread]||<div class="unread_cnt">( [Unread] unread ) <a href="[Slug]/!markread" title="[const:ttlMark]"><img width="16" height="16" src="[special:skin]/_images/markread.svg" alt="X"></a></div>]
    <span class="small">[TimeChanged]</span>
  </div>
  <div class="col_cnt">
    [ReadCount]<br>[const:tViews]
  </div>
</div>
