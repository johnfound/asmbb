[css:posts.css]
[css:postnew.css]
[css:threadnew.css]
[css:navigation.css]

[case:[special:lang]|
  [equ:btnList=Thread list]
  [equ:ttlTitle=Title]
  [equ:phTitle=Thread title]
  [equ:ttlTags=Tags: <span class="small">(max 3, comma delimited, no spaces)</span>]
  [equ:phTags=some tags here]
  [equ:ttlLimited=Limited access thread]
  [equ:ttlInvited=Invited users (comma separated list)]
  [equ:ttlPost=Post content]
  [equ:phText=Share your thoughts here]
  [equ:ttlAttach=Attach file(s)]
  [equ:phSelect=Select file to attach]
  [equ:btnPreview=Preview]
  [equ:btnSubmit=Submit]
  [equ:btnRevert=Revert]
|
  [equ:btnList=Списък теми]
  [equ:ttlTitle=Заглавие]
  [equ:phTitle=Заглавие на темата]
  [equ:ttlTags=Тагове: <span class="small">(макс. 3, разделени със запетаи, без шпации)</span>]
  [equ:phTags=някакви тагове тук]
  [equ:ttlLimited=Тема с ограничен достъп]
  [equ:ttlInvited=Поканени в темата (разделени със запетаи)]
  [equ:ttlPost=Съобщение]
  [equ:phText=Сподели мислите си тук]
  [equ:ttlAttach=Прикачи файл(ове)]
  [equ:phSelect=Избери файл(ове) за прикачане]
  [equ:btnPreview=Преглед]
  [equ:btnSubmit=Запис]
  [equ:btnRevert=Отказ]
|
  [equ:btnList=Список тем]
  [equ:ttlTitle=Название темы]
  [equ:phTitle=Название темы]
  [equ:ttlTags=Ярлыки: <span class="small">(макс. 3, через запятую, без пробелов)</span>]
  [equ:phTags=теги пишутся здесь]
  [equ:ttlLimited=Тема с ограниченным доступом]
  [equ:ttlInvited=Приглашенные участники (список через запятую)]
  [equ:ttlPost=Текст сообщения]
  [equ:phText=Поделитесь своими мыслями здесь]
  [equ:ttlAttach=Прикрепленные файл(ы)]
  [equ:phSelect=Выберите файл для вложения]
  [equ:btnPreview=Преглед]
  [equ:btnSubmit=Записать]
  [equ:btnRevert=Отказ]
|
  [equ:btnList=Liste des sujets]
  [equ:ttlTitle=Titre]
  [equ:phTitle=Titre du sujet]
  [equ:ttlTags=Mots-clés: <span class="small">(3 maximum, séparés par une virgule t sans espace)</span>]
  [equ:phTags=quelques mots-clés]
  [equ:ttlLimited=Sujet à accès limité]
  [equ:ttlInvited=Inviter des utilisateurs (séparés par une virgule)]
  [equ:ttlPost=Contenu du message]
  [equ:phText=Partagez vos idées ici]
  [equ:ttlAttach=Pièce(s) jointe(s)]
  [equ:phSelect=Sélectionner un fichier à attacher]
  [equ:btnPreview=Prévisualiser]
  [equ:btnSubmit=Poster]
  [equ:btnRevert=Annuler]
|
  [equ:btnList=Liste der Themen]
  [equ:ttlTitle=Titel]
  [equ:phTitle=Titel des Themas]
  [equ:ttlTags=Tags: <span class="small">(max. 3, durch Kommas getrennt, keine Leerzeichen)</span>]
  [equ:phTags=hier einige Tags]
  [equ:ttlLimited=Thema mit beschränktem Zugriff]
  [equ:ttlInvited=Eingeladene Mitglieder (durch Kommas getrennt)]
  [equ:ttlPost=Inhalt des Beitrags]
  [equ:phText=Teilen Sie hier Ihre Gedanken mit]
  [equ:ttlAttach=Datei(en) anhängen]
  [equ:phSelect=Wählen Sie eine Datei als Anhang aus]
  [equ:btnPreview=Vorschau]
  [equ:btnSubmit=Absenden]
  [equ:btnRevert=Zurücksetzen]
]

<div class="new_editor">
  <div class="ui">
    <a class="ui" href=".">[const:btnList]</a>
    <div class="spacer"></div>
  </div>
  <form id="editform" action="!post" method="post" enctype="multipart/form-data">
    <div class="edit_groupL">
      <p>[const:ttlTitle]:</p>
      <input type="edit" value="[caption]" placeholder="[const:ttlTitle]" name="title" autofocus>
    </div><div class="edit_groupR">
      <p>[const:ttlTags] [case:[special:dir]| |+ "[special:dir]"]</p>
      <input type="edit" value="[tags]" name="tags" id="tags" placeholder="[const:phTags]" oninput="OnKeyboard(this)" onkeydown="EditKeyDown(event, this)" getlist="/!tagmatch/">
    </div>
    <input type="checkbox" id="limited" name="limited" value="1" [case:[limited]||checked]><label for="limited">[const:ttlLimited]</label>
    <div id="users_invited">
      <p>[const:ttlInvited]:</p>
      <input id="invited" type="edit" value="[invited]" name="invited" oninput="OnKeyboard(this)" onkeydown="EditKeyDown(event, this)" getlist="/!usersmatch/">
    </div>
    [include:edit_toolbar.tpl]
    <p>[const:ttlPost]:</p>
    <textarea class="editor" name="source" id="source" placeholder="[const:phText]">[source]</textarea>
    [case:[special:canupload]||<p class="panel">[const:ttlAttach]:</p><div class="attach"><input type="file" placeholder="[const:phSelect]" name="attach" multiple="multiple" tabindex="-1"></div>]
    <div class="attachments">
      [attach_edit:[id]]
    </div>
    <div class="panel">
      <input type="submit" name="preview" value="[const:btnPreview]" >
      <input type="submit" name="submit" value="[const:btnSubmit]" >
      <input type="hidden" name="ticket" value="[Ticket]" >
      <input type="reset" value="[const:btnRevert]" >
    </div>
  </form>
</div>

[raw:autocomplete.js]
