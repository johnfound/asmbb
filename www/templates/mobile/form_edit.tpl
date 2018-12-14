[css:navigation.css]
[css:posts.css]
[css:posteditor.css]

<div class="ui">
  <a class="ui left" href="../">The thread</a>
  <a class="ui left" href="!by_id">Back</a>
</div>

<form id="editform" action="!edit#preview" onsubmit="previewIt(event)" method="post" enctype="multipart/form-data">
    <p>Thread title:</p>
    <h1 class="fakeedit">[caption]</h1>
    [include:edit_toolbar.tpl]
    <p>Post content:</p>
    <textarea class="editor" name="source" id="source">[source]</textarea>
    [case:[special:canupload]||<p>Attach file(s): <span class="small">(count&le;10, size&le;1MB)</span></p><input id="browse" type="file" placeholder="Select file to attach" name="attach" multiple="multiple">]
    <div id="attachments" class="attach_del">
      [attach_edit:[id]]
    </div>
    <div class="panel">
      <input type="submit" name="preview" value="Preview" onclick="this.form.cmd='preview'" title="Ctrl+Enter for preview">
      <input type="submit" name="submit" value="Submit" onclick="this.form.cmd='submit'" title="Ctrl+S for submit" >
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
</form>

<script>
function previewIt(e) {

  if (e.target.cmd === "preview") {
    e.preventDefault();

    var xhr = new XMLHttpRequest();
    xhr.open("POST", "!edit?cmd=preview");

    xhr.onload = function(event){
      if (event.target.status === 200) {
        var prv = document.getElementById("preview");
        var attch = document.getElementById("attachments");
        var resp = JSON.parse(event.target.response);

        prv.innerHTML = resp.preview;
        attch.innerHTML = resp.attach_del;
      }
      document.getElementById("browse").value = '';
      document.getElementById("source").focus();
    };

    var formData = new FormData(document.getElementById("editform"));
    xhr.send(formData);
  }
}

document.onkeydown = function(e) {
  var key = e.which || e.keyCode;
  var frm = document.getElementById("editform");
  var stop = true;

  if (e.ctrlKey && key == 13) {
    frm.preview.click();
  } else if (key == 27) {
    window.location.href = "!by_id";
  } else if (e.ctrlKey && key == 83) {
    frm.submit.click();
  } else stop = false;

  if (stop) e.preventDefault();
};


</script>