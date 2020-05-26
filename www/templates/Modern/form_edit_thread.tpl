[css:posteditor.css]
[css:threadnew.css]

<style>
  body {
    width: initial !important;
    margin: 8px !important;
  }
</style>

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

<div class="thread_editor">
  <div class="ui">
    <input class="btn" form="editform" type="submit" name="submit" value="[const:btnSubmit]" >
    <input class="btn" form="editform" type="hidden" name="ticket" value="[Ticket]" >
    <input class="btn" form="editform" type="reset" value="[const:btnRevert]" >
    <div class="spacer"></div>
    <a class="btn round" href="."><svg version="1.1" width="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">
       <rect transform="rotate(45)" x=".635" y="-1.53" width="21.4" height="3.05" rx="1.53" ry="1.53"/>
       <rect transform="rotate(135)" x="-10.7" y="-12.8" width="21.4" height="3.05" rx="1.53" ry="1.53"/>
    </svg></a>
  </div>
  <form id="editform" action="!edit_thread" method="post">
    <div class="notabs">
      <div class="editgroup">
        <div>
          <p>[const:ttlTitle]:</p>
          <input type="text" value="[caption]" placeholder="[const:phTitle]" name="title" autofocus>
        </div>
      </div>
      <div class="editgroup">
        <div>
          <p>[const:ttlTags] [case:[special:dir]| |+ "[special:dir]"]</p>
          <input type="text" value="[tags]" name="tags" id="tags" placeholder="[const:phTags]" oninput="OnKeyboard(this)" onkeydown="EditKeyDown(event, this)" getlist="/!tagmatch/">
        </div>
      </div>
      [case:[special:isadmin]||<div class="editgroup">
        <div>
          <input type="checkbox" id="pinned" name="pinned" value="1" [case:[Pinned]||checked]><label for="pinned">[const:ttlPin]</label>
        </div>
      </div>]

      <input type="checkbox" id="limited" name="limited" value="1" [case:[limited]||checked]><label for="limited">[const:ttlLimited]</label>
      <div class="editgroup" id="users_invited">
        <div>
          <p>[const:ttlInvited]:</p>
          <input id="invited" type="text" value="[invited]" name="invited" oninput="OnKeyboard(this)" onkeydown="EditKeyDown(event, this)" getlist="/!usersmatch/">
        </div>
      </div>
    </div>
  </form>
</div>

[raw:autocomplete.js]
