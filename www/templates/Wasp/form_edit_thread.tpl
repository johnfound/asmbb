[css:navigation.css]
[css:posts.css]
[css:postnew.css]
[css:threadnew.css]

[case:[special:lang]|
  [equ:ttlTitle=Title]
  [equ:phTitle=Thread title]
  [equ:ttlTags=Tags: <span class="small">(max 3, comma delimited, no spaces)</span>]
  [equ:phTags=some tags here]
  [equ:ttlPin=Pin the thread on top]
  [equ:ttlLimited=Limited access thread]
  [equ:ttlInvited=Invited users (comma separated list)]
  [equ:btnSubmit=Submit]
  [equ:btnRevert=Revert]
|
  [equ:ttlTitle=Заглавие]
  [equ:phTitle=Заглавие на темата]
  [equ:ttlTags=Тагове: <span class="small">(макс. 3, разделени със запетаи, без шпации)</span>]
  [equ:phTags=някакви тагове тук]
  [equ:ttlPin=Дръж темата най-отгоре]
  [equ:ttlLimited=Тема с ограничен достъп]
  [equ:ttlInvited=Поканени в темата (разделени със запетаи)]
  [equ:btnSubmit=Запиши]
  [equ:btnRevert=Отказ]
|
  [equ:ttlTitle=Название темы]
  [equ:phTitle=Название темы]
  [equ:ttlTags=Ярлыки: <span class="small">(макс. 3, через запятую, без пробелов)</span>]
  [equ:phTags=теги пишутся здесь]
  [equ:ttlPin=Закрепить наверху]
  [equ:ttlLimited=Тема с ограниченным доступом]
  [equ:ttlInvited=Приглашенные участники (список через запятую)]
  [equ:btnSubmit=Записать]
  [equ:btnRevert=Отказатся]
|
  [equ:ttlTitle=Titre]
  [equ:phTitle=Titre du sujet]
  [equ:ttlTags=Mots-clés: <span class="small">(3 maximum, séparés par une virgule t sans espace)</span>]
  [equ:phTags=quelques mots-clés]
  [equ:ttlPin=Épingler ce sujet]
  [equ:ttlLimited=Sujet restreint]
  [equ:ttlInvited=Inviter des utilisateurs (séparés par une virgule)]
  [equ:btnSubmit=Soumettre]
  [equ:btnRevert=Annuler]
|
  [equ:ttlTitle=Titel]
  [equ:phTitle=Titel des Themas]
  [equ:ttlTags=Tags: <span class="small">(max. 3, durch Kommas getrennt, keine Leerzeichen)</span>]
  [equ:phTags=hier einige Tags]
  [equ:ttlPin=Das Thema oben anheften]
  [equ:ttlLimited=Thema mit beschränktem Zugang]
  [equ:ttlInvited=Eingeladene Mitglieder (durch Kommas getrennt)]
  [equ:btnSubmit=Absenden]
  [equ:btnRevert=Zurücksetzen]
]

<div class="new_editor">
  <div class="ui">
    <a class="ui left" href=".">The thread</a>
  </div>
  <form id="editform" action="!edit_thread" method="post">

    <p>[const:ttlTitle]:</p>
    <input type="edit" value="[caption]" placeholder="[const:phTitle]" name="title" autofocus>
    <p>[const:ttlTags] [case:[special:dir]| |+ "[special:dir]"]</p>
    <input type="edit" value="[tags]" name="tags" id="tags" placeholder="[const:phTags]" oninput="OnKeyboard(this)" onkeydown="EditKeyDown(event, this)" getlist="/!tagmatch/">
    [case:[special:isadmin]||<input type="checkbox" id="pinned" name="pinned" value="1" [case:[Pinned]||checked]><label for="pinned">[const:ttlPin]</label>]
    <input type="checkbox" id="limited" name="limited" value="1" [case:[limited]||checked]><label for="limited">[const:ttlLimited]</label>
    <div id="users_invited">
      <p>[const:ttlInvited]:</p>
      <input id="invited" type="edit" value="[invited]" name="invited" oninput="OnKeyboard(this)" onkeydown="EditKeyDown(event, this)" getlist="/!usersmatch/">
    </div>
    <div class="panel">
      <input type="submit" name="submit" value="[const:btnSubmit]" >
      <input type="hidden" name="ticket" value="[Ticket]" >
      <input type="reset" value="[const:btnRevert]" >
    </div>
  </form>
</div>

[raw:autocomplete.js]
