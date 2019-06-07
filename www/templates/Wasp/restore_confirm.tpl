[css:navigation.css]
[css:delete.css]
[css:markdown.css]

[case:[special:lang]|
  [equ:hRestore=Restore post?]
  [equ:pQuestion=Do you <b>really</b> want to restore this post to the previous version?]
  [equ:btnRestore=Restore]
  [equ:btnCancel=Cancel]
|
  [equ:hRestore=Възстановяване?]
  [equ:pQuestion=<b>Наистина ли</b> желаете да възстановите това съобщение до предишна версия?]
  [equ:btnRestore=Възстанови]
  [equ:btnCancel=Отказ]
|
  [equ:hRestore=Восстановить пост?]
  [equ:pQuestion=Вы <b>действительно</b> хотите восстановить это сообщение в предыдущей версии?]
  [equ:btnRestore=Восстановить]
  [equ:btnCancel=Отменить]
|
  [equ:hRestore=Restaurer le message?]
  [equ:pQuestion=Voulez-vous <b>vraiment</b> restaurer ce message dans sa précédente version?]
  [equ:btnRestore=Restaurer]
  [equ:btnCancel=Annuler]
|
  [equ:hRestore=Beitrag wiederherstellen?]
  [equ:pQuestion=Möchten Sie diesen Beitrag <b>wirklich</b> auf die vorherige Version zurücksetzen?]
  [equ:btnRestore=Wiederherstellen]
  [equ:btnCancel=Abbrechen]
]

<div class="confirm">
  <form id="editform" method="post">
    <h1 class="msg warning">[const:hRestore]</h1>
    <p>[const:pQuestion]</p>
    <div class="post_preview">
      <div class="post_text">
        <article>
          [html:[[case:[format]|minimag:[include:minimag_suffix.tpl]|bbcode:][Content]]]
        </article>
      </div>
    </div>
    <div class="panel">
      <input type="submit" value="[const:btnRestore]" >
      <a class="button" href="/[postID]/!history#[version]">[const:btnCancel]</a>
      <input type="hidden" name="version" value="[version]" >
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
  </form>
</div>
