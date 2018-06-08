[css:navigation.css]
[css:delete.css]
[css:markdown.css]

<div class="confirm">
  <form id="editform" method="post">
    <h1 class="msg warning">Restore post?</h1>
    <p>Do you <b>really</b> want to restore this post to the previous version?</p>
    <div class="post_preview">[minimag:[content]]</div>
    <div class="panel">
      <input type="submit" value="Restore" >
      <a class="button" href="/[postID]/!history#[version]">Cancel</a>
      <input type="hidden" name="version" value="[version]" >
      <input type="hidden" name="ticket" value="[Ticket]" >
    </div>
  </form>
</div>
