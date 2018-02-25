[css:navigation.css]
[css:sqlite.css]

<div class="console">
  <div class="ui">
    <a class="ui" href="/">Thread list</a>
    <span class="spacer"></span>
    <a class="ui" href="/!settings">Settings</a>
    <a class="ui" target="_blank" href="/!sqlite">SQL console</a>
  </div>
  <form id="editform" action="/!sqlite/#sql_result" method="post">
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
      <a id="sql_result">
      <input type="submit" value="Exec" >
      <input type="reset" value="Revert" >
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
  </form>
</div>
