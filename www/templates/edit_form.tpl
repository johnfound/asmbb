<div class="editor" id="editor">
  <div class="ui">
    <a class="ui" href="/list">Root</a>
    <a class="ui" href="/by_id/$id$">Back</a>
  </div>
  <form id="editform" action="/edit/$id$" method="post">
    <p>Thread title:</p>
    <h1 class="fakeedit">$caption$</h1>
    <p>Post content:</p>
    <textarea class="editor" name="source" id="source">$source$</textarea>
    <div class="panel">
      <input type="submit" name="submit" value="Submit" >
      <input type="submit" name="preview" value="Preview" >
      <input type="reset" value="Revert" >
    </div>
  </form>
</div>