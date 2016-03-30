<div class="ui">
  [case:[sql: select ([special:permissions] & 0x08 <> 0)]
  | |<a class="ui" href="/post/?tag=[special:tag]">New Thread</a>]
  [case:[special:userid]| |<a class="ui" href="/markread/">Mark all as read</a>]
  [case:[sql: select ([special:permissions] & 0x80000000 <> 0)]
  | |<a class="uir" href="/sqlite">SQL console</a>]
</div>