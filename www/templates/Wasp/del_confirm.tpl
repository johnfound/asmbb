[css:navigation.css]
[css:delete.css]
[css:markdown.css]

<div class="confirm">
  <form id="editform" method="post">
    <h1 class="msg warning">[case:[special:lang]|
Delete [case:[cnt_thread]| |post and thread|post]|
Изтриване на [case:[cnt_thread]| |мнението и темата|мнението]|
Удалить [case:[cnt_thread]| |мнение и темы|мнение]|
Supprimer le [case:[cnt_thread]| |sujet et le message|message]|
[case:[cnt_thread]| |Beitrag und Thema|Beitrag] löschen]?</h1>
    [case:[special:lang]|
<p>Do you <b>really</b> want to delete the post written by <b>"[usr:[UserName]]"</b>?</p>|
<p><b>Наистина</b> ли искате да изтриете мнението на <b>"[usr:[UserName]]"</b>?</p>|
<p>Вы <b>действительно</b> хотите удалить мнение <b>"[usr:[UserName]]"</b>?</p>|
<p>Voulez-vous <b>vraiment</b> supprimer le message écrit par <b>"[usr:[UserName]]"</b>?</p>|
<p>Wollen Sie <b>wirklich</b> den Beitrag von <b>"[usr:[UserName]]"</b> löschen?</p>]
    <div class="post_preview">
      <div class="post_text">
        <article>
          [html:[[case:[format]|minimag:[include:minimag_suffix.tpl]|bbcode:][Content]]]
        </article>
      </div>
    </div>
    <p>
[case:[cnt_thread]| |
  [case:[special:lang]|
    Notice that this is the <b>last post</b> in the thread and the <b>thread will be deleted</b> as well!|
    Това е <b>последното</b> мнение в темата и изтриването му ще <b>изтрие също и темата</b>!|
    Это <b>последний</b> пост в ветке, удаление которого также приведет к <b>удалению темы</b>!|
    Remarquez que ceci est le <b>dernier message</b> dans ce sujet et que <b>le sujet sera supprimé</b> également!|
    Beachten Sie, dass dies der <b>letzte Beitrag</b> im Thema ist und das <b>Thema auch gelöscht</b> werden wird!]
|
  [case:[special:lang]|
    Notice, that deletion can break the thread!|
    Изтриването му може да навреди на темата!|
    Удаление может навредить обсуждения!|
    Notice, that deletion can break the thread!|
    Beachten Sie, dass Löschen das Thema ruinieren kann!]
]</p>
    <div class="panel">
      <input type="submit" value="[case:[special:lang]|Delete|Изтрий|Удалить|Supprimer|Löschen]" >
      <a class="button" href="!by_id">[case:[special:lang]|Cancel|Връщане|Отменить|Annuler|Abbrechen]</a>
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
  </form>
</div>
