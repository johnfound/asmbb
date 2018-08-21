[css:navigation.css]
[css:sqlite.css]

<div class="console">
  <div class="ui_panel">
    <a class="ui left" href="/">Thread list</a>
    <span class="spacer"></span>
    <a class="ui right" href="/!settings">Settings</a>
    <a class="ui right" target="_blank" href="/!sqlite">SQL console</a>
  </div>
  <form id="editform" action="/!sqlite/#sql_result" method="post">
    <p>Script name:</p>
    <div class="toolbar">
      <input class="title" size="40" type="edit" value="" placeholder="Script name" name="name">
      <a class="button" href="/">Edit</a>
      <a class="button" href="/">Save</a>
      <a class="button" href="/">Del</a>
    </div>
    <p>SQL statement:</p>
    <textarea class="sql_editor" name="source" id="source"  placeholder="SQL">[source]</textarea>
    <div class="panel">
      <a id="sql_result" style="visibility: hidden; margin: 0px; padding: 0px;"></a>
      <input class="ui left" type="submit" value="Exec" >
      <input class="ui left" type="reset" value="Revert" >
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
  </form>
</div>
