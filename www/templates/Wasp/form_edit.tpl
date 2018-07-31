[css:navigation.css]
[css:posts.css]
[css:posteditor.css]

<div class="editor" id="editor">
  <div class="ui" id="draghere">
    <span class="spacer"></span>
    <a class="ui right" href="!by_id"><img src="[special:skin]/_images/close.svg" alt="Close" height="16"></a>
  </div>
  <form id="editform" action="!edit" method="post" onsubmit="previewIt(event)">
    <p>Thread title:</p>
    <h1 class="fakeedit">[caption]</h1>
    <p>Post content:</p>
    [include:edit_toolbar.tpl]
    <textarea class="editor" name="source" id="source">[source]</textarea>
    <div class="panel">
      <input type="submit" name="preview" value="Preview" onclick="this.form.cmd='preview'" title="Ctrl+Enter for preview">
      <input type="submit" name="submit" value="Submit" onclick="this.form.cmd='submit'" title="Ctrl+S for submit" >
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
  </form>
</div>


<script>
dragElement(document.getElementById("editor"),document.getElementById("draghere") );

function dragElement(elmnt, hdr) {
  var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
  hdr.onmousedown = dragMouseDown;

  function dragMouseDown(e) {
    e = e || window.event;
    pos3 = e.clientX;
    pos4 = e.clientY;
    document.onmouseup = closeDragElement;
    document.onmousemove = elementDrag;
  }

  function elementDrag(e) {
    e = e || window.event;
    pos1 = pos3 - e.clientX;
    pos2 = pos4 - e.clientY;
    pos3 = e.clientX;
    pos4 = e.clientY;
    elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
    elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
  }

  function closeDragElement() {
    document.onmouseup = null;
    document.onmousemove = null;
  }
}


function previewIt(e) {

  if (e.target.cmd === "preview") {
    e.preventDefault();

    var xhr = new XMLHttpRequest();
    xhr.open("POST", "!edit?cmd=preview");

    xhr.onload = function(event){
      if (event.target.status === 200) {
        var prv = document.getElementById("preview");
        prv.outerHTML = event.target.response;
      }
      document.getElementById("source").focus();
    };

    var formData = new FormData(document.getElementById("editform"));
    xhr.send(formData);
  }
}

document.onkeyup = function(e) {
  var key = e.which || e.keyCode;
  if (e.ctrlKey && key == 13) {
    var frm = document.getElementById("editform");
    frm.preview.click();
  } else if (key == 27) {
    window.location.href = "!by_id";
  } else if (e.ctrlKey && key == 83) {
    var frm = document.getElementById("editform");
    frm.submit.click();
    e.preventDefault();
  }
  return false;
}

document.onkeydown = function(e) {
  var key = e.which || e.keyCode;
  if (e.ctrlKey && key == 83) {
    var frm = document.getElementById("editform");
    frm.submit.click();
    e.preventDefault();
    return false;
  }
}


</script>