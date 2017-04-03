<div class="new_editor">
  <div class="ui">
    <a class="ui" href="/">Thread list</a>
    <a class="uir" target="_blank" href="/!sqlite">SQL console</a><a class="uir" href="/!settings">Settings</a>
  </div>
  <form id="editform" action="/!sqlite/" method="post">
    <p>Script name:</p>
    <input class="title" style="width: 80%; height: 32px;" size="40" type="edit" value="" placeholder="Script name" name="name">
    <a href="/"><img class="icon_btn" src="/images/edit_white.svg"></a>
    <a href="/"><img class="icon_btn" src="/images/save.svg"></a>
    <a href="/"><img class="icon_btn" src="/images/del_white.svg"></a>
    <p>SQL statement:</p>
    <textarea class="sql_editor" name="source" id="source"  placeholder="SQL">[source]</textarea>
    <div class="panel">
      <input type="submit" value="Exec" >
      <input type="reset" value="Revert" >
    </div>
  </form>
</div>
