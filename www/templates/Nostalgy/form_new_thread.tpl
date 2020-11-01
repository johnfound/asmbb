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

<div id="editor-window" class="editor">
  <div class="navigation3 btn-bar">
      <input form="editform" type="hidden" name="ticket" value="[Ticket]" >
      <input form="editform" class="btn" id="preview-btn" formaction="!post#preview" type="submit" name="preview" onclick="this.form.cmd='preview'" value="[const:btnPreview]" title="[const:hintPreview]">
      <input form="editform" class="btn" type="submit" name="submit" onclick="this.form.cmd='submit'" value="[const:btnSubmit]" title="[const:hintSubmit]">
      <div class="spacer"></div>
      <a id="btn-close" class="btn img-btn" href=".">
        <svg version="1.1" width="12" height="12" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">
           <rect transform="rotate(45)" x=".635" y="-1.53" width="21.4" height="3.05" rx="1.53" ry="1.53"/>
           <rect transform="rotate(135)" x="-10.7" y="-12.8" width="21.4" height="3.05" rx="1.53" ry="1.53"/>
        </svg>
      </a>
  </div>
  <form id="editform" action="!post" method="post" onsubmit="previewIt(event)" enctype="multipart/form-data">
    <div class="dropdown tabbed-form">

      <input id="tab1" name="tabselector" type="radio" value="0" checked>
      <label for="tab1">[const:ttlEditorTab]</label>
      <section>
        <div class="editgroup">
          <div>
            <p>[const:ttlTitle]:</p>
            <input type="text" value="[caption]" placeholder="[const:ttlTitle]" name="title" autofocus required>
          </div>
          <div>
            <p>[const:ttlTags] [case:[special:dir]| |+ "[special:dir]"]</p>
            <input type="text" value="[tags]" name="tags" id="tags" placeholder="[const:phTags]" oninput="OnKeyboard(this)" onkeydown="EditKeyDown(event, this)" getlist="/!tagmatch/">
          </div>
        </div>
        <div class="checkbox">
          <input type="checkbox" id="limited" name="limited" value="1" [case:[limited]||checked]><label for="limited">[const:ttlLimited]</label>
          <div class="editgroup" id="users_invited">
            <div>
              <p>[const:ttlInvited]:</p>
              <input type="text" id="invited" value="[invited]" name="invited" oninput="OnKeyboard(this)" onkeydown="EditKeyDown(event, this)" getlist="/!usersmatch/">
            </div>
          </div>
        </div>
  [case:[special:canupload]||
        <div class="editgroup">
          <div>
            <p>[const:ttlAttach]:</p>
            <div class="file-browse">
              <label for="input-file-browse" id="browse-txt"></label>
              <input type="file" placeholder="[const:phSelect]" id="input-file-browse" name="attach" multiple="multiple" data-multiselect="[const:MultiFiles]">
              <label id="browse-btn" class="btn" for="input-file-browse">Browse</label>
            </div>
          </div>
        </div>
  ]
        <p>[const:ttlPost]:</p>

        [include:edit_toolbar.tpl]

        <textarea name="source" id="source" placeholder="[const:phText]" required>[source]</textarea>
      </section>

      [case:[special:markup=0]||
      <input id="tab2" name="tabselector" type="radio" value="1">
      <label for="tab2">
        <svg version="1.1" width="16" height="16" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
          <path d="m16 0a16 16 0 00-16 16 16 16 0 0016 16 16 16 0 0016-16 16 16 0
                   00-16-16zm.154 6c2.13 0 3.8.503 5.01 1.51 1.22.998 1.83 2.38 1.83
                   4.14 0 .904-.198 1.72-.594 2.43-.386.718-1.11 1.47-2.18
                   2.27l-1.03.77c-.611.457-1.07.919-1.37 1.38-.296.466-.459.978-.486
                   1.54h-3.6c.0539-.951.311-1.8.77-2.54.467-.746 1.15-1.44 2.05-2.1.961-.69
                   1.64-1.3 2.04-1.82.395-.531.594-1.12.594-1.76
                   0-.821-.262-1.47-.783-1.94-.512-.476-1.24-.715-2.2-.715-.907
                   0-1.67.276-2.29.826-.611.55-.97 1.28-1.08 2.18l-3.84-.168c.243-1.89.992-3.37
                   2.25-4.42 1.26-1.05 2.89-1.58 4.9-1.58zm-2.52 16.2h3.89v3.78h-3.89v-3.78z"/>
        </svg>
        MiniMag
      </label>
      <section class="post post-text help">
        [html:
          [minimag:
            [include:minimag_suffix.tpl]
            [raw:help-minimag.txt]
          ]
        ]
      </section>
      ]

      [case:[special:markup=1]||
      <input id="tab3" name="tabselector" type="radio" value="2">
      <label for="tab3">
        <svg version="1.1" width="16" height="16" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
          <path d="m16 0a16 16 0 00-16 16 16 16 0 0016 16 16 16 0 0016-16 16 16 0
                   00-16-16zm.154 6c2.13 0 3.8.503 5.01 1.51 1.22.998 1.83 2.38 1.83
                   4.14 0 .904-.198 1.72-.594 2.43-.386.718-1.11 1.47-2.18
                   2.27l-1.03.77c-.611.457-1.07.919-1.37 1.38-.296.466-.459.978-.486
                   1.54h-3.6c.0539-.951.311-1.8.77-2.54.467-.746 1.15-1.44 2.05-2.1.961-.69
                   1.64-1.3 2.04-1.82.395-.531.594-1.12.594-1.76
                   0-.821-.262-1.47-.783-1.94-.512-.476-1.24-.715-2.2-.715-.907
                   0-1.67.276-2.29.826-.611.55-.97 1.28-1.08 2.18l-3.84-.168c.243-1.89.992-3.37
                   2.25-4.42 1.26-1.05 2.89-1.58 4.9-1.58zm-2.52 16.2h3.89v3.78h-3.89v-3.78z"/>
        </svg>
        BBCode
      </label>
      <section class="post post-text help">
        [html:
          [bbcode:
            [raw:help-bbcode.txt]
          ]
        ]
      </section>
      ]

    </div>
  </form>
</div>


<script src="[special:skin]/highlight.js"></script>
<script src="[special:skin]/editors.js"></script>
<script src="[special:skin]/file-browse.js"></script>
<script src="[special:skin]/autocomplete.js"></script>
