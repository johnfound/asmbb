[css:navigation.css]
[css:sqlite.css]

<div class="console">
  <div class="ui">
    <a class="ui" href="/">Thread list</a>
    <a class="uir" target="_blank" href="/!sqlite">SQL console</a><a class="uir" href="/!settings">Settings</a>
  </div>
  <form id="editform" action="/!sqlite/" method="post">
    <p>Script name:</p>
    <div class="toolbar">
      <input class="title" type="edit" value="" placeholder="Script name" name="name">
      <a class="button btn_edit" href="/"></a>
      <a class="button btn_save" href="/"></a>
      <a class="button btn_del"  href="/"></a>
    </div>
    <p>SQL statement:</p>
    <textarea class="sql_editor" name="source" id="source"  placeholder="SQL">[source]</textarea>
    <div class="panel">
      <input type="submit" value="Exec" >
      <input type="reset" value="Revert" >
    </div>
  </form>
</div>
