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
|
  [equ:Caption=Заглавие на темата]
  [equ:Content=Съдържание на поста]
  [equ:btnPreview=Преглед]
  [equ:hintPreview=Ctrl+Enter за преглед]
  [equ:btnSubmit=Публикувай]
  [equ:hintSubmit=Ctrl+S за публикуване]
  [equ:Attach=Прикачи файл(ове)]
|
  [equ:Caption=Название темы]
  [equ:Content=Содержание поста]
  [equ:btnPreview=Просмотр]
  [equ:hintPreview=Ctrl+Enter для предварительного просмотра]
  [equ:btnSubmit=Отправить]
  [equ:hintSubmit=Ctrl+S чтобы отправить]
  [equ:Attach=Прикрепить файл(ы)]
|
  [equ:Caption=Titre du sujet]
  [equ:Content=Contenu du message]
  [equ:btnPreview=Prévisualiser]
  [equ:hintPreview=Ctrl+Entrée pour prévisualiser]
  [equ:btnSubmit=Soumettre]
  [equ:hintSubmit=Ctrl+S pour soumettre]
  [equ:Attach=Pièce(s) jointe(s)]
]

<div class="ui">
  <a class="ui left" href="../">The thread</a>
  <a class="ui left" href="!by_id">Back</a>
</div>

<form id="editform" action="!edit#preview" onsubmit="previewIt(event)" method="post" enctype="multipart/form-data">
    <p>[const:Caption]:</p>
    <h1 class="fakeedit">[caption]</h1>
    [include:edit_toolbar.tpl]
        <p>[const:Content]:</p>
    <textarea class="editor" name="source" id="source">[source]</textarea>
        [case:[special:canupload]||<p>[const:Attach]: <span class="small">(count&le;10, size&le;1MB)</span></p><input id="browse" type="file" placeholder="Select file to attach" name="attach" multiple="multiple">]
    <div id="attachments" class="attach_del">
      [attach_edit:[id]]
    </div>
    <div class="panel">
      <input type="submit" name="preview" value="[const:btnPreview]" onclick="this.form.cmd='preview'" title="[const:hintPreview]">
      <input type="submit" name="submit" value="[const:btnSubmit]" onclick="this.form.cmd='submit'" title="[const:hintSubmit]" >
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
