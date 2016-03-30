<div class="ui">
  <a class="ui" style="color: white" href="/list/?tag=[special:tag]">Thread list</a>
  [case:[sql: select ([special:permissions] & 0x80000004 <> 0)]
  | |<a class="ui" href="/post/[slug]">Answer</a>]
  [case:[sql: select ([special:permissions] & 0x80000000 <> 0)]
  | |<a class="uir" href="/sqlite">SQL console</a>]
</div>
