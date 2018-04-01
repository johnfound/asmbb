[css:navigation.css]
[css:posts.css]
[css:posteditor.css]

<div class="editor" id="editor">
  <div class="ui" id="draghere">
    <a class="ui left" href="../">Thread list</a>
    <a class="ui left" href="!by_id">Back</a>
  </div>
  <form id="editform" action="!edit" method="post">
    <p>Thread title:</p>
    <h1 class="fakeedit">[caption]</h1>
    <p>Post content:</p>
    [include:edit_toolbar.tpl]
    <textarea class="editor" name="source" id="source">[source]</textarea>
    <div class="panel">
      <input type="submit" name="submit" value="Submit" >
      <input type="submit" name="preview" value="Preview" >
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
</script>