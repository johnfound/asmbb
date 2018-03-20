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
    <form id="editform" action="!post" method="post">
      <div class="edit_groupL">
        <p>Title:</p>
        <input class="title" type="edit" value="[caption]" placeholder="Thread title" name="title" autofocus>
      </div><div class="edit_groupR">
        <p>Tags: <span class="small">(max 3, comma delimited, no spaces)</span> [case:[special:dir]| |+ "[special:dir]"]</p>
        <input class="tags"  type="edit" value="[tags]" name="tags" placeholder="some tags here">
      </div>
      <p>Post content:</p>
      [include:edit_toolbar.tpl]
      <textarea class="editor" name="source" id="source" placeholder="Share you thoughs here">[source]</textarea>
      <div class="panel">
        <input type="submit" name="submit" value="Submit" >
        <input type="submit" name="preview" value="Preview" >
        <input type="hidden" name="ticket" value="[Ticketl]" >
        <input type="reset" value="Revert" >
      </div>
    </form>
  </div>
</div>
