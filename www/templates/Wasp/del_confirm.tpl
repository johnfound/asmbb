[css:navigation.css]
[css:delete.css]
[css:markdown.css]

<div class="confirm">
  <form id="editform" method="post">
    <h1 class="msg warning">[case:[special:lang]|
Delete [case:[cnt_thread]| |post and thread|post]|
Изтриване на [case:[cnt_thread]| |мнението и темата|мнението]|
Удалить [case:[cnt_thread]| |мнение и темы|мнение]|
Delete [case:[cnt_thread]| |post and thread|post]] ?</h1>
    [case:[special:lang]|
<p>Do you <b>really</b> want to delete the post written by <b>"[UserName]"</b>?</p>|
<p><b>Наистина</b> ли искате да изтриете мнението на <b>"[UserName]"</b>?</p>|
<p>Вы <b>действительно</b> хотите удалить мнение <b>"[UserName]"</b>?</p>|
<p>Do you <b>really</b> want to delete the post written by <b>"[UserName]"</b>?</p>]
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
    Notice that this is the <b>last post</b> in the thread and the <b>thread will be deleted</b> as well!]
|
  [case:[special:lang]|
    Notice, that deletion can break the thread!|
    Изтриването му може да навреди на темата!|
    Удаление может навредить обсуждения!|
    Notice, that deletion can break the thread!]
]</p>
    <div class="panel">
      <input type="submit" value="[case:[special:lang]|Delete|Изтрий|Удалить|Delete]" >
      <a class="button" href="!by_id">[case:[special:lang]|Cancel|Връщане|Отменить|Cancel]</a>
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
  </form>
</div>
