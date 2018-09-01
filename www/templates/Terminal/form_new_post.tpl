[css:navigation.css]
[css:posts.css]
[css:postnew.css]

  <div class="ui">
    <a class="ui left" href="[case:[special:page]||../]../">Thread list</a>
    <a class="ui left" href="[case:[special:page]|./|!by_id]">Thread</a>
  </div>
<div class="new_editor">
  <form id="editform" action="!post#preview" method="post" enctype="multipart/form-data">
    <p>Thread title:</p>
    <h1 class="fakeedit">[caption]</h1>
    <p>Post content:</p>
    [include:edit_toolbar.tpl]
    <textarea class="editor" name="source" id="source" placeholder="Answer the wrong one here">[source]</textarea>
    [case:[special:canupload]||
      <p class="panel">Attach file(s):</p>
      <div class="attach">
        <input type="file" name="attach" id="attach" multiple="multiple" onchange="GetSelectedFiles()">
        <label class="browse" for="attach">Browse</label>
        <span class="showfiles" id="showfiles"></span>
      </div>
    ]
    <div class="attachments">
      [attach_edit:[id]]
    </div>
    <div class="panel">
      <input type="submit" name="preview" value="Preview" >
      <input type="submit" name="submit" value="Submit" >
      <input type="hidden" name="ticket" value="[Ticket]" >
      <input type="reset" value="Revert" >
    </div>
  </form>
</div>

<script>
  function GetSelectedFiles() {
    var where = document.getElementById("showfiles");
    var browse = document.getElementById("attach");
    if (browse.files.length == 1) where.innerText = browse.files[0].name;
    else where.innerText = browse.files.length + " files are selected";
  }
</script>

