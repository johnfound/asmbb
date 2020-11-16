[css:posts.css]
[css:posteditor.css]
[css:threadnew.css]
[css:markdown.css]
[css:highlight.css]

[case:[special:lang]|
  [equ:ttlEditorTab=New Thread]
  [equ:ttlTitle=Title]
  [equ:phTitle=Thread title]
  [equ:ttlTags=Tags: <span class="small">(comma separated list)</span>]
  [equ:phTags=some tags here]
  [equ:ttlLimited=Limited access thread]
  [equ:ttlInvited=Invited users <span class="small">(comma separated list)</span>]
  [equ:phText=Share your thoughts here]
  [equ:ttlAttach=Attach file(s)]
  [equ:phSelect=Select file to attach]
  [equ:btnPreview=Preview]
  [equ:btnSubmit=Submit]
  [equ:hintPreview=Ctrl+Enter for preview]
  [equ:hintSubmit=Ctrl+S for submit]
  [equ:ttlPost=Post content]
  [equ:MultiFiles= files selected.]
|
  [equ:ttlEditorTab=Нова тема]
  [equ:ttlTitle=Заглавие]
  [equ:phTitle=Заглавие на темата]
  [equ:ttlTags=Тагове: <span class="small">(разделени със запетаи)</span>]
  [equ:phTags=някакви тагове тук]
  [equ:ttlLimited=Тема с ограничен достъп]
  [equ:ttlInvited=Поканени в темата <span class="small">(разделени със запетаи)</span>]
  [equ:phText=Сподели мислите си тук]
  [equ:ttlAttach=Прикачи файл(ове)]
  [equ:phSelect=Избери файл(ове) за прикачане]
  [equ:btnPreview=Преглед]
  [equ:btnSubmit=Запис]
  [equ:hintPreview=Ctrl+Enter за преглед]
  [equ:hintSubmit=Ctrl+S за запис]
  [equ:ttlPost=Съобщение]
  [equ:MultiFiles= файла са избрани.]
|
  [equ:ttlEditorTab=Новая тема]
  [equ:ttlTitle=Название темы]
  [equ:phTitle=Название темы]
  [equ:ttlTags=Ярлыки: <span class="small">(список через запятую)</span>]
  [equ:phTags=теги пишутся здесь]
  [equ:ttlLimited=Тема с ограниченным доступом]
  [equ:ttlInvited=Приглашенные участники <span class="small">(список через запятую)</span>]
  [equ:phText=Поделитесь своими мыслями здесь]
  [equ:ttlAttach=Прикрепленные файл(ы)]
  [equ:phSelect=Выберите файл для вложения]
  [equ:btnPreview=Преглед]
  [equ:btnSubmit=Записать]
  [equ:hintPreview=Ctrl+Enter для предварительного просмотра]
  [equ:hintSubmit=Ctrl+S чтобы записать]
  [equ:ttlPost=Текст сообщения]
  [equ:MultiFiles= выбранные файлы.]
|
  [equ:ttlEditorTab=Nouveau sujet]
  [equ:ttlTitle=Titre]
  [equ:phTitle=Titre du sujet]
  [equ:ttlTags=Mots-clés: <span class="small">(séparés par une virgule)</span>]
  [equ:phTags=quelques mots-clés]
  [equ:ttlLimited=Sujet à accès limité]
  [equ:ttlInvited=Inviter des utilisateurs <span class="small">(séparés par une virgule)</span>]
  [equ:phText=Partagez vos idées ici]
  [equ:ttlAttach=Pièce(s) jointe(s)]
  [equ:phSelect=Sélectionner un fichier à attacher]
  [equ:btnPreview=Prévisualiser]
  [equ:btnSubmit=Poster]
  [equ:hintPreview=Ctrl+Entrée pour prévisualiser]
  [equ:hintSubmit=Ctrl+S pour soumettre]
  [equ:ttlPost=Contenu du message]
  [equ:MultiFiles= dossiers sélectionnés.]
|
  [equ:ttlEditorTab=Neues Thema]
  [equ:ttlTitle=Titel]
  [equ:phTitle=Titel des Themas]
  [equ:ttlTags=Tags: <span class="small">(durch Kommas getrennt)</span>]
  [equ:phTags=hier einige Tags]
  [equ:ttlLimited=Thema mit beschränktem Zugriff]
  [equ:ttlInvited=Eingeladene Mitglieder <span class="small">(durch Kommas getrennt)</span>]
  [equ:phText=Teilen Sie hier Ihre Gedanken mit]
  [equ:ttlAttach=Datei(en) anhängen]
  [equ:phSelect=Wählen Sie eine Datei als Anhang aus]
  [equ:btnPreview=Vorschau]
  [equ:btnSubmit=Absenden]
  [equ:hintPreview=Strg+Eingabe für eine Vorschau]
  [equ:hintSubmit=Strg+S zum Absenden]
  [equ:ttlPost=Inhalt des Beitrags]
  [equ:MultiFiles= ausgewählte Dateien.]
]


<table id="editor-layout"><tr>
<td>
  <form id="editform" action="!post" method="post" onsubmit="previewIt(event)" enctype="multipart/form-data">
    <input type="hidden" name="ticket" value="[Ticket]" >
    <table class="toolbar light-btns"><tr>
      <td><input class="submit" type="submit" id="preview-btn" formaction="!post#preview" name="preview" onclick="this.form.cmd='preview'" value="[const:btnPreview]" title="[const:hintPreview]">
      <td><input class="submit" type="submit" name="submit" onclick="this.form.cmd='submit'" value="[const:btnSubmit]" title="[const:hintSubmit]">
      <td class="spacer">
      <td><a class="img-btn" href="."><img width="16" height="16" src="[special:skin]/_images/close.png"></a>

      [case:[special:markup=0]|<input name="format" value="1" type="hidden">|[case:[special:markup=1]||
      <tr><td colspan="4"><p><label><input class="inp-check" name="format" type="radio" [case:[format]|checked|] value="0">MiniMag</label>
      ]]
      [case:[special:markup=1]|<input name="format" value="0" type="hidden">|[case:[special:markup=0]||
      <label><input class="inp-check" name="format" type="radio" [case:[format]||checked] value="1">BBcode</label>
      ]]
    </table>

    <table class="edit-group toolbar">
      <tr>
        <td>
          <p>[const:ttlTitle]:
          <p><input class="inp-text" type="text" value="[caption]" placeholder="[const:ttlTitle]" name="title" id="inp-title" autofocus required>
        <td>
          <p>[const:ttlTags] [case:[special:dir]| |+ "[special:dir]"]
          <p><input class="inp-text" type="text" value="[tags]" name="tags" id="tags" placeholder="[const:phTags]" oninput="OnKeyboard(this)" onkeydown="EditKeyDown(event, this)" getlist="/!tagmatch/">
      <tr>
        <td colspan="2">
          <p><label><input class="inp-check" type="checkbox" name="limited" value="1" [case:[limited]||checked]>[const:ttlLimited]</label>
      <tr>
        <td colspan="2">
          <p>[const:ttlInvited]:
          <p><input class="inp-text" type="text" id="invited" value="[invited]" name="invited" oninput="OnKeyboard(this)" onkeydown="EditKeyDown(event, this)" getlist="/!usersmatch/">

  [case:[special:canupload]||
      <tr>
        <td colspan="2">
          <p>[const:ttlAttach]:</p>
          <p><input class="inp-file" type="file" placeholder="[const:phSelect]" id="input-file-browse" name="attach" multiple="multiple" data-multiselect="[const:MultiFiles]">
  ]

    </table>

    <p>[const:ttlPost]:</p>
    <textarea rows="20" name="source" id="source" placeholder="[const:phText]" required>[source]</textarea>

  </form>


[case:[special:markup=0]||
  <details>
    <summary>MiniMag formatting</summary>
    <section class="post post-text help">
      [html:
        [minimag:
          [include:minimag_suffix.tpl]
          [raw:help-minimag.txt]
        ]
      ]
    </section>
  </details>
]

[case:[special:markup=1]||
  <details>
    <summary>BBCode formatting</summary>
      <section class="post post-text help">
        [html:
          [bbcode:
            [raw:help-bbcode.txt]
          ]
        ]
      </section>
  </details>
]

<script src="[special:skin]/highlight.js"></script>
<script src="[special:skin]/editors.js"></script>
<script src="[special:skin]/autocomplete.js"></script>
