[css:navigation.css]
[css:posts.css]
[css:postnew.css]

<div class="new_editor">
  <div class="ui">
    <a class="ui left" href="[case:[special:page]||../]../">Thread list</a>
    <a class="ui left" href="[case:[special:page]|./|!by_id]">Thread</a>
  </div>
  <form id="editform" action="!post#preview" method="post">
    <p>Thread title:</p>
    <h1 class="fakeedit">[caption]</h1>
    <p>Post content:</p>
    [include:edit_toolbar.tpl]
    <textarea class="editor" name="source" id="source" placeholder="Answer the wrong one here">[source]</textarea>
    <div class="panel">
      <input type="submit" name="preview" value="Preview" >
      <input type="submit" name="submit" value="Submit" >
      <input type="hidden" name="ticket" value="[Ticket]" >
      <input type="reset" value="Revert" >
    </div>
  </form>
</div>
