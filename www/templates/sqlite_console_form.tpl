<div class="new_editor">
  <div class="ui">
    <a class="ui" href="/list">Root</a>
  </div>
  <form id="editform" action="/sqlite/" method="post">
    <p>SQL statement:</p>
    <textarea class="sql_editor" name="source" id="source">[source]</textarea>
    <div class="panel">
      <input type="submit" value="Exec" >
      <input type="reset" value="Revert" >
    </div>
  </form>
</div>
