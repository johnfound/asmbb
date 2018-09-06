[css:posts.css]
[css:postnew.css]
[css:threadnew.css]
[css:navigation.css]

<div class="ui_panel">
  <a class="ui left" href=".">Thread list</a>
</div>

<div class="new_editor">
  <form id="editform" action="!post" method="post" enctype="multipart/form-data">
    <table><tr>
      <td class="l">
        <p>Title:</p>
        <input class="title" type="edit" value="[caption]" placeholder="Thread title" name="title" autofocus>
      </td>
      <td class="r">
        <p>Tags: <span class="small">(max 3, comma delimited, no spaces)</span> [case:[special:dir]| |+ "[special:dir]"]</p>
        <input class="tags"  type="edit" value="[tags]" name="tags" placeholder="some tags here">
      </td>
    </tr>
    </table>
    <p>Post content:</p>
    [include:edit_toolbar.tpl]
    <textarea class="editor" name="source" id="source" placeholder="Share your thoughts here">[source]</textarea>
    [case:[special:canupload]||
      <p class="panel">Attach file(s):</p>
      <div class="attach">
        <input type="file" placeholder="Select file to attach" name="attach" multiple="multiple" id="browse" onchange="GetSelectedFiles()">
        <label class="browse" for="browse">Browse</label>
        <span class="showfiles" id="showfiles"></span>
      </div>
    ]
    <div class="attachments">
      [attach_edit:[id]]
    </div>
    <div class="panel">
      <input class="ui left" type="submit" name="preview" value="Preview" >
      <input class="ui left" type="submit" name="submit" value="Submit" >
      <input type="hidden" name="ticket" value="[Ticket]" >
      <input class="ui left" type="reset" value="Revert" >
    </div>
  </form>
</div>

<script>
  function GetSelectedFiles() {
    var where = document.getElementById("showfiles");
    var browse = document.getElementById("browse");
    if (browse.files.length == 1) where.innerText = browse.files[0].name;
    else where.innerText = browse.files.length + " files are selected";
  }
</script>

