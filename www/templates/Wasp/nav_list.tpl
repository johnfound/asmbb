[css:navigation.css]
[css:thread_list.css]

<div class="ui">
  [case:[special:canstart]| |<a class="ui left" href="!post">New Thread</a>]
  [case:[special:userid]  | |<a class="ui left" href="!markread">Mark all as read</a>]
  [case:[special:canchat] | |<a class="ui left" href="/!chat">Chat</a>]
  <span class="spacer"></span>
  [case:[special:isadmin] | |
    <a class="ui right" href="/!render_all">Render all</a>
    <a class="ui right" href="/!settings[special:urltag]">Settings</a>
    <a class="ui right" href="/!sqlite">SQL console</a>
  ]
</div>
