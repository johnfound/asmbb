[css:navigation.css]
[css:delete.css]
[css:markdown.css]

<div class="confirm">
  <form id="editform" method="post">
    <h1 class="msg warning">Delete [case:[cnt_thread]| |post and thread|post]?</h1>
    <p>Do you <b>really</b> want to delete the post written by <b>"[UserName]"</b>?</p>
    <div class="post_preview">[minimag:[content]]</div>
    <p>[case:[cnt_thread]| |Notice that this is the <b>last post</b> in the thread and the <b>thread will be deleted</b> as well!|Notice, that deletion can break the thread!]</p>
    <div class="panel">
      <input type="submit" value="Delete" >
      <a class="button" href="!by_id">Cancel</a>
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
  </form>
</div>
