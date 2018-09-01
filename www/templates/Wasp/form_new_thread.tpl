[css:posts.css]
[css:postnew.css]
[css:threadnew.css]
[css:navigation.css]
[css:markdown.css]

<div class="new_editor">
  <div class="ui">
    <a class="ui" href=".">Thread list</a>
    <div class="spacer"></div>
  </div>
    <form id="editform" action="!post" method="post" enctype="multipart/form-data">
      <div class="edit_groupL">
        <p>Title:</p>
        <input type="edit" value="[caption]" placeholder="Thread title" name="title" autofocus>
      </div><div class="edit_groupR">
        <p>Tags: <span class="small">(max 3, comma delimited, no spaces)</span> [case:[special:dir]| |+ "[special:dir]"]</p>
        <input type="edit" value="[tags]" name="tags" placeholder="some tags here">
      </div>
      <input type="checkbox" id="limited" name="limited" value="1" [case:[limited]||checked]><label for="limited">Limited access thread</label>
      <div id="users_invited">
        <p>Invited users (comma separated list):</p>
        <input id="invited" type="edit" value="[invited]" name="invited">
      </div>
      <p>Post content:</p>
      [include:edit_toolbar.tpl]
      <textarea class="editor" name="source" id="source" placeholder="Share your thoughts here">[source]</textarea>
      [case:[special:canupload]||<p class="panel">Attach file(s):</p><div class="attach"><input type="file" placeholder="Select file to attach" name="attach" multiple="multiple"></div>]
      <div class="attachments">
        [attach_edit:[id]]
      </div>
    <div class="panel">
        <input type="submit" name="preview" value="Preview" >
        <input type="submit" name="submit" value="Submit" >
        <input type="hidden" name="ticket" value="[Ticket]" >
        <input type="reset" value="Revert" >
      </div>
    </form>
  </div>
</div>
