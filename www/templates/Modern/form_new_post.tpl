[css:posts.css]
[css:posteditor.css]
[css:threadnew.css]

[case:[special:lang]|
  [equ:btnThread=Thread]
  [equ:ttlTitle=Thread title]
  [equ:phText=Someone is wrong on the Internet]
  [equ:ttlAttach=Attach file(s)]
  [equ:phSelect=Select file to attach]
  [equ:btnPreview=Preview]
  [equ:btnSubmit=Submit]
  [equ:hintPreview=Ctrl+Enter for preview]
  [equ:hintSubmit=Ctrl+S for submit]
|
  [equ:btnThread=Тема]
  [equ:ttlTitle=Заглавие на темата]
  [equ:phText=Някой в Интернет греши]
  [equ:ttlAttach=Прикачи файл(ове)]
  [equ:phSelect=Избери файл(ове) за прикачане]
  [equ:btnPreview=Преглед]
  [equ:btnSubmit=Запис]
  [equ:hintPreview=Ctrl+Enter за преглед]
  [equ:hintSubmit=Ctrl+S за запис]
|
  [equ:btnThread=Тема]
  [equ:ttlTitle=Название темы]
  [equ:phText=В Интернете кто-то неправ]
  [equ:ttlAttach=Прикрепленные файл(ы)]
  [equ:phSelect=Выберите файл для вложения]
  [equ:btnPreview=Преглед]
  [equ:btnSubmit=Записать]
  [equ:hintPreview=Ctrl+Enter для предварительного просмотра]
  [equ:hintSubmit=Ctrl+S чтобы записать]
|
  [equ:btnThread=Sujet]
  [equ:ttlTitle=Titre du sujet]
  [equ:phText=Quelqu'un a tort sur internet.]
  [equ:ttlAttach=Pièce(s) jointe(s)]
  [equ:phSelect=Joindre un fichier]
  [equ:btnPreview=Prévisualiser]
  [equ:btnSubmit=Poster]
  [equ:hintPreview=Ctrl+Entrée pour prévisualiser]
  [equ:hintSubmit=Ctrl+S pour soumettre]
|
  [equ:btnThread=Thema]
  [equ:ttlTitle=Titel des Themas]
  [equ:phText=Jemand hat Unrecht im Internet]
  [equ:ttlAttach=Datei(en) anhängen]
  [equ:phSelect=Wählen Sie eine Datei als Anhang aus]
  [equ:btnPreview=Vorschau]
  [equ:btnSubmit=Absenden]
  [equ:hintPreview=Strg+Eingabe für eine Vorschau]
  [equ:hintSubmit=Strg+S zum Absenden]
]

<div class="editor">
  <div class="ui">
    <input form="editform" type="hidden" name="ticket" value="[Ticket]" >
    <input form="editform" class="btn" type="submit" name="preview" onclick="this.form.cmd='preview'" value="[const:btnPreview]" title="[const:hintPreview]">
    <input form="editform" class="btn" type="submit" name="submit" onclick="this.form.cmd='submit'" value="[const:btnSubmit]"  title="[const:hintSubmit]">
    <div class="spacer"></div>
    <a class="btn round" href="[case:[special:page]|./|!by_id]"><svg version="1.1" width="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">
       <rect transform="rotate(45)" x=".635" y="-1.53" width="21.4" height="3.05" rx="1.53" ry="1.53"/>
       <rect transform="rotate(135)" x="-10.7" y="-12.8" width="21.4" height="3.05" rx="1.53" ry="1.53"/>
      </svg></a>
  </div>
  <form id="editform" action="!post#preview" method="post" onsubmit="previewIt(event)" enctype="multipart/form-data">
    <div class="notabs">
      [include:edit_toolbar.tpl]
      <textarea name="source" id="source" placeholder="[const:phText]">[source]</textarea>
      <div>
        [case:[special:canupload]||<p>[const:ttlAttach]:</p><input type="file" placeholder="[const:phSelect]" name="attach" multiple="multiple" tabindex="-1">]
      </div>
    </div>
  </form>
</div>


<script>

function previewIt(e) {

  if (e.target.cmd === "preview") {
    e.preventDefault();

    var xhr = new XMLHttpRequest();
    xhr.open("POST", "!post?cmd=preview");

    xhr.onload = function(event){
      if (event.target.status === 200) {
        var prv = document.getElementById("preview");
        var resp = JSON.parse(event.target.response);

        prv.innerHTML = resp.preview;
      }
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
