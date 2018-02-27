[css:navigation.css]
[css:posts.css]
[css:posteditor.css]

<div class="editor" id="editor">
  <div class="ui">
    <a class="ui left" href="../">Thread list</a>
    <a class="ui left" href="!by_id">Back</a>
  </div>
  <form id="editform" action="!edit" method="post">
    <p>Thread title:</p>
    <h1 class="fakeedit">[caption]</h1>
    <p>Post content:</p>
    <textarea class="editor" name="source" id="source">[source]</textarea>
    <div class="panel">
      <input type="submit" name="submit" value="Submit" >
      <input type="submit" name="preview" value="Preview" >
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
  </form>
</div>