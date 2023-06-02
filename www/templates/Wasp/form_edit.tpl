[css:navigation.css]
[css:posts.css]
[css:posteditor.css]

[case:[special:lang]|
  [equ:Caption=Thread title]
  [equ:ttlTitle=Title]
  [equ:phTitle=Thread title]
  [equ:ttlTags=Tags: <span class="small">(max 3, comma delimited, no spaces)</span>]
  [equ:phTags=some tags here]
  [equ:ttlLimited=Limited access thread]
  [equ:ttlInvited=Invited users (comma separated list)]
  [equ:Content=Post content]
  [equ:btnPreview=Preview]
  [equ:hintPreview=Ctrl+Enter for preview]
  [equ:btnSubmit=Submit]
  [equ:hintSubmit=Ctrl+S for submit]
  [equ:Attach=Attach file(s)]
  [equ:FileLimit=(count ≤ 10, size ≤ 1MB)]
  [equ:ttlPin=Important thread, rank]
  [equ:lblAfter=after: ]
|
  [equ:Caption=Заглавие на темата]
  [equ:ttlTitle=Заглавие]
  [equ:phTitle=Заглавие на темата]
  [equ:ttlTags=Тагове: <span class="small">(макс. 3, разделени със запетаи, без шпации)</span>]
  [equ:phTags=някакви тагове тук]
  [equ:ttlLimited=Тема с ограничен достъп]
  [equ:ttlInvited=Поканени в темата (разделени със запетаи)]
  [equ:Content=Съдържание на поста]
  [equ:btnPreview=Преглед]
  [equ:hintPreview=Ctrl+Enter за преглед]
  [equ:btnSubmit=Публикувай]
  [equ:hintSubmit=Ctrl+S за публикуване]
  [equ:Attach=Прикачи файл(ове)]
  [equ:FileLimit=(брой ≤ 10, размер ≤ 1MB)]
  [equ:ttlPin=Дръж темата най-отгоре]
  [equ:ttlPin=Важна тема, ранг]
  [equ:lblAfter=след: ]
|
  [equ:Caption=Название темы]
  [equ:ttlTitle=Название темы]
  [equ:phTitle=Название темы]
  [equ:ttlTags=Ярлыки: <span class="small">(макс. 3, через запятую, без пробелов)</span>]
  [equ:phTags=теги пишутся здесь]
  [equ:ttlLimited=Тема с ограниченным доступом]
  [equ:ttlInvited=Приглашенные участники (список через запятую)]
  [equ:Content=Содержание поста]
  [equ:btnPreview=Просмотр]
  [equ:hintPreview=Ctrl+Enter для предварительного просмотра]
  [equ:btnSubmit=Отправить]
  [equ:hintSubmit=Ctrl+S чтобы отправить]
  [equ:Attach=Прикрепить файл(ы)]
  [equ:FileLimit=(количество ≤ 10, размер ≤ 1MB)]
  [equ:ttlPin=Важная тема, ранг]
  [equ:lblAfter=через: ]
|
  [equ:Caption=Titre du sujet]
  [equ:ttlTitle=Titre]
  [equ:phTitle=Titre du sujet]
  [equ:ttlTags=Mots-clés: <span class="small">(3 maximum, séparés par une virgule t sans espace)</span>]
  [equ:phTags=quelques mots-clés]
  [equ:ttlLimited=Sujet à accès limité]
  [equ:ttlInvited=Inviter des utilisateurs (séparés par une virgule)]
  [equ:Content=Contenu du message]
  [equ:btnPreview=Prévisualiser]
  [equ:hintPreview=Ctrl+Entrée pour prévisualiser]
  [equ:btnSubmit=Soumettre]
  [equ:hintSubmit=Ctrl+S pour soumettre]
  [equ:Attach=Pièce(s) jointe(s)]
  [equ:FileLimit=(count ≤ 10, size ≤ 1MB)]
  [equ:ttlPin=Sujet important, classement]
  [equ:lblAfter=après: ]
|
  [equ:Caption=Titel des Themas]
  [equ:ttlTitle=Titel]
  [equ:phTitle=Titel des Themas]
  [equ:ttlTags=Tags: <span class="small">(max. 3, durch Kommas getrennt, keine Leerzeichen)</span>]
  [equ:phTags=hier einige Tags]
  [equ:ttlLimited=Thema mit beschränktem Zugriff]
  [equ:ttlInvited=Eingeladene Mitglieder (durch Kommas getrennt)]
  [equ:Content=Inhalt des Beitrags]
  [equ:btnPreview=Vorschau]
  [equ:hintPreview=Strg+Eingabe für eine Vorschau]
  [equ:btnSubmit=Absenden]
  [equ:hintSubmit=Strg+S zum Absenden]
  [equ:Attach=Datei(en) anhängen]
  [equ:FileLimit=(Anzahl ≤ 10, Größe ≤ 1MB)]
  [equ:ttlPin=Wichtiges Thema, Rang]
  [equ:lblAfter=nach: ]
]

<div class="editor" id="editor">
  <div class="ui" id="draghere">
    <span class="spacer"></span>
    <a id="btn-close" class="ui right" href="[case:[id]|[case:[special:page]|.|!by_id]|!by_id]"><img src="[special:skin]/_images/close.svg" alt="Close" height="16"></a>
  </div>
  <form id="editform" action="[special:cmd]" method="post" onsubmit="previewIt(event)" enctype="multipart/form-data">
  [case:[EditThread]|
        <input type="hidden" value="[caption]" name="title">
  |
    <div>
      <div class="edit_groupL">
        <p>[const:ttlTitle]:</p>
        <input type="text" value="[caption]" placeholder="[const:ttlTitle]" name="title" autofocus>
      </div><div class="edit_groupR">
        <p>[const:ttlTags] [case:[special:dir]| |+ "[special:dir]"]</p>
        <input type="text" value="[tags]" name="tags" id="tags" placeholder="[const:phTags]" oninput="OnKeyboard(this)" onkeydown="EditKeyDown(event, this)" getlist="/!tagmatch/">
      </div>
      [case:[special:isadmin]||<p><input class="settings" type="number" min="0" max="5" value="[Pinned]" name="pinned"> [const:ttlPin].</p>]
      <input type="checkbox" id="limited" name="limited" value="1" [case:[limited]||checked]><label for="limited">[const:ttlLimited]</label>
      <div id="users_invited">
        <p>[const:ttlInvited]:</p>
        <input id="invited" type="text" value="[invited]" name="invited" oninput="OnKeyboard(this)" onkeydown="EditKeyDown(event, this)" getlist="/!usersmatch/">
      </div>
    </div>
  ]

    [include:edit_toolbar.tpl]
    <p></p>

  <div>
    [case:[special:canupload]||<p>[const:Attach]: <span class="small">[const:FileLimit]</span></p><input id="browse" type="file" placeholder="Select file to attach" name="attach" multiple="multiple">]
  </div>

    <p>[const:Content]:</p>

    <textarea class="editor" name="source" id="source">[source]</textarea>

    <div class="panel">
      <input type="submit" name="preview" value="[const:btnPreview]" onclick="this.form.cmd='preview'" title="[const:hintPreview]">
      <button form="editform" type="submit" name="submit" onclick="this.form.cmd='submit'" title="[const:hintSubmit]">
        [const:btnSubmit]&nbsp;
        [case:[special:wait2post]||<span id="remains">[const:lblAfter]<span id="remval">[special:wait2post]</span> s</span>]
      </button>
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
  </form>
</div>

<script src="[special:skin]/autocomplete.js"></script>
<script src="[special:skin]/embeded.js"></script>

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
  if ((e == undefined) || (e.target.cmd === "preview")) {
    if (e) e.preventDefault();

    var form = document.getElementById("editform");

    var xhr = new XMLHttpRequest();
    xhr.open("POST", form.action + "?cmd=preview");

    xhr.onload = function(event){
      if (event.target.status === 200) {
        var prv = document.getElementById("preview");
        var attch = document.getElementById("attachments");
        var resp = JSON.parse(event.target.response);

        var focus = document.activeElement;

        if (attch) attch.innerHTML = resp.attach_del;
        prv.innerHTML = resp.preview;

        focus.focus();
        fixVideos();
      }
      if (e) document.getElementById("source").focus();
    };

    var formData = new FormData(form);
    xhr.send(formData);

    document.getElementById("browse").value = null;
    document.location = "#preview";
  }
}

document.onkeydown = function(e) {
  var key = e.which || e.keyCode;
  var frm = document.getElementById("editform");
  var btnclose = document.getElementById("btn-close");
  var stop = true;

  if (e.ctrlKey && key == 13) {
    frm.preview.click();
  } else if (key == 27) {
    btnclose.click();
  } else if (e.ctrlKey && key == 83) {
    frm.submit.click();
  } else stop = false;

  if (stop) e.preventDefault();
};


</script>


