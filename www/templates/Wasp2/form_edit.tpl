[css:navigation.css]
[css:posts.css]
[css:posteditor.css]

[case:[special:lang]|
  [equ:Caption=Thread title]
  [equ:Content=Post content]
  [equ:btnPreview=Preview]
  [equ:hintPreview=Ctrl+Enter for preview]
  [equ:btnSubmit=Submit]
  [equ:hintSubmit=Ctrl+S for submit]
  [equ:Attach=Attach file(s)]
  [equ:tabText=Text]
  [equ:tabAttach=Attachments]
  [equ:FileLimit=(count ≤ 10, size ≤ 1MB)]
|
  [equ:Caption=Заглавие на темата]
  [equ:Content=Съдържание на поста]
  [equ:btnPreview=Преглед]
  [equ:hintPreview=Ctrl+Enter за преглед]
  [equ:btnSubmit=Публикувай]
  [equ:hintSubmit=Ctrl+S за публикуване]
  [equ:Attach=Прикачи файл(ове)]
  [equ:tabText=Текст]
  [equ:tabAttach=Файлове]
  [equ:FileLimit=(брой ≤ 10, размер ≤ 1MB)]
|
  [equ:Caption=Название темы]
  [equ:Content=Содержание поста]
  [equ:btnPreview=Просмотр]
  [equ:hintPreview=Ctrl+Enter для предварительного просмотра]
  [equ:btnSubmit=Отправить]
  [equ:hintSubmit=Ctrl+S чтобы отправить]
  [equ:Attach=Прикрепить файл(ы)]
  [equ:tabText=Текст]
  [equ:tabAttach=Вложения]
  [equ:FileLimit=(количество ≤ 10, размер ≤ 1MB)]
|
  [equ:Caption=Titre du sujet]
  [equ:Content=Contenu du message]
  [equ:btnPreview=Prévisualiser]
  [equ:hintPreview=Ctrl+Entrée pour prévisualiser]
  [equ:btnSubmit=Soumettre]
  [equ:hintSubmit=Ctrl+S pour soumettre]
  [equ:Attach=Pièce(s) jointe(s)]
  [equ:tabText=Texte]
  [equ:tabAttach=Pièces jointes]
  [equ:FileLimit=(count ≤ 10, size ≤ 1MB)]
|
  [equ:Caption=Titel des Themas]
  [equ:Content=Inhalt des Beitrags]
  [equ:btnPreview=Vorschau]
  [equ:hintPreview=Strg+Eingabe für eine Vorschau]
  [equ:btnSubmit=Absenden]
  [equ:hintSubmit=Strg+S zum Absenden]
  [equ:Attach=Datei(en) anhängen]
  [equ:tabText=Text]
  [equ:tabAttach=Anhänge]
  [equ:FileLimit=(Anzahl ≤ 10, Größe ≤ 1MB)]
]

<div class="editor" id="editor">
  <div class="ui" id="draghere">
    <span class="spacer"></span>
    <a class="ui right" href="!by_id"><img src="[special:skin]/_images/close.svg" alt="Close" height="16"></a>
  </div>
  <form id="editform" action="!edit" method="post" onsubmit="previewIt(event)" enctype="multipart/form-data">
    <p>[const:Caption]:</p>
    <h1 class="fakeedit">[caption]</h1>
    <div class="tabbed">
      <input id="rad1" name="tabselector" type="radio" checked>
      <label for="rad1">[const:tabText]</label>
      <section>
        [include:edit_toolbar.tpl]
        <p>[const:Content]:</p>
        <textarea class="editor" name="source" id="source">[source]</textarea>
      </section>

      <input id="rad2" name="tabselector" type="radio">
      <label for="rad2">[const:tabAttach]</label>
      <section>
        [case:[special:canupload]||<p>[const:Attach]: <span class="small">[const:FileLimit]</span></p><input id="browse" type="file" placeholder="Select file to attach" name="attach" multiple="multiple">]
        <div id="attachments" class="attach_del">
          [attach_edit:[id]]
        </div>
      </section>
    </div>

    <div class="panel">
      <input type="submit" name="preview" value="[const:btnPreview]" onclick="this.form.cmd='preview'" title="[const:hintPreview]">
      <input type="submit" name="submit" value="[const:btnSubmit]" onclick="this.form.cmd='submit'" title="[const:hintSubmit]" >
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
  </form>
</div>


<script>
dragElement(document.getElementById("editor"),document.getElementById("draghere") );

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

    var newx = e.clientX - posX;
    var newy = e.clientY - posY;

    var maxx = window.innerWidth - 32;
    var maxy = window.innerHeight - 16;

    if (newx < 0) newx=0;
    if (newy < 0) newy=0;
    if (newx > maxx) newx = maxx;
    if (newy > maxy) newy = maxy;

    elmnt.style.left =  newx + 'px';
    elmnt.style.top = newy + 'px';
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
