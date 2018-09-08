[css:navigation.css]
[css:posts.css]
[css:posteditor.css]

<div class="editor" id="editor">
  <div class="ui" id="draghere">
    <span class="spacer"></span>
    <a class="ui right" href="!by_id">X</a>
  </div>
  <form id="editform" action="!edit" method="post" onsubmit="previewIt(event)">
    <p>Thread title:</p>
    <h1 class="fakeedit">[caption]</h1>
    <div class="tabbed">
      <input id="rad1" name="tabselector" type="radio" checked>
      <label for="rad1">Text</label>
      <section>
        <p>Post content:</p>
        [include:edit_toolbar.tpl]
        <textarea class="editor" name="source" id="source">[source]</textarea>
      </section>

      <input id="rad2" name="tabselector" type="radio">
      <label for="rad2">Attachments</label>
      <section>
        [case:[special:canupload]||
          <div class="attach">
            <input type="file" placeholder="Select file to attach" name="attach" multiple="multiple" id="browse" onchange="GetSelectedFiles()">
            <label class="browse" for="browse">Browse</label>
            <span class="showfiles" id="showfiles"></span>
          </div>
        ]
        <div id="attachments" class="attach_del">
          [attach_edit:[id]]
        </div>
      </section>
    </div>

    <div class="panel">
      <input class="ui left" type="submit" name="preview" value="Preview" onclick="this.form.cmd='preview'" title="Ctrl+Enter for preview">
      <input class="ui left" type="submit" name="submit" value="Submit" onclick="this.form.cmd='submit'" title="Ctrl+S for submit" >
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
  </form>
</div>


<script>
dragElement(document.getElementById("editor"),document.getElementById("draghere") );

var measure = document.getElementById("measure");
var cx = measure.offsetWidth/1000;
var cy = measure.offsetHeight/1000;

function dragElement(elmnt, hdr) {
  var posX = 0, posY = 0;
  hdr.onmousedown = dragMouseDown;

  function dragMouseDown(e) {
    e = e || window.event;
    posX = e.clientX - elmnt.offsetLeft;
    posY = e.clientY - elmnt.offsetTop;
    document.onmouseup = closeDragElement;
    document.onmousemove = elementDrag;
    e.preventDefault();
  }

  function elementDrag(e) {
    e = e || window.event;

    var newx = Math.floor((e.clientX - posX)/cx);
    var newy = Math.floor((e.clientY - posY)/cy);

    var maxx = Math.floor(window.innerWidth/cx) - 3;
    var maxy = Math.floor(window.innerHeight/cy) - 2;

    if (newx < 0) newx=0;
    if (newy < 0) newy=0;
    if (newx > maxx) newx = maxx;
    if (newy > maxy) newy = maxy;

    elmnt.style.left = newx * cx + 'px';
    elmnt.style.top = newy * cy + 'px';
    e.preventDefault();
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
        var attch = document.getElementById("attachments");
        var resp = JSON.parse(event.target.response);

        prv.innerHTML = resp.preview;
        attch.innerHTML = resp.attach_del;
      }
      document.getElementById("browse").value = '';
      document.getElementById("showfiles").innerText = '';
      document.getElementById("source").focus();
    };

    var formData = new FormData(document.getElementById("editform"));
    xhr.send(formData);
  }
}

document.onkeyup = function(e) {
  var key = e.which || e.keyCode;
  var frm = document.getElementById("editform");
  if (e.ctrlKey && key == 13) {
    frm.preview.click();
  } else if (key == 27) {
    window.location.href = "!by_id";
  } else if (e.ctrlKey && key == 83) {
    frm.submit.click();
    e.preventDefault();
  }
  return false;
};

document.onkeydown = function(e) {
  var key = e.which || e.keyCode;
  if (e.ctrlKey && key == 83) {
    var frm = document.getElementById("editform");
    frm.submit.click();
    e.preventDefault();
    return false;
  }
};

function GetSelectedFiles() {
  var where = document.getElementById("showfiles");
  var browse = document.getElementById("browse");
  if (browse.files.length == 0) where.innerText = '';
  else if (browse.files.length == 1) where.innerText = browse.files^[0^].name;
  else where.innerText = browse.files.length + " files are selected";
}



</script>