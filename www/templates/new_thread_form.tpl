<div class="new_editor">
  <div class="ui">
    <a class="ui" href="/list">Root</a>
  </div>
  <form id="editform" action="/post/" method="post">
    <p>Thread title:</p>
    <input class="title" type="edit" value="$caption$" name="title" autofocus="on"><br>
    <p>Post content:</p>
    <textarea class="editor" name="source" id="source">$source$</textarea><br>
    <div class="panel">
      <input type="submit" name="submit" value="Submit" >
      <input type="submit" name="preview" value="Preview" >
      <input type="reset" value="Revert" >
    </div>
  </form>
</div>
