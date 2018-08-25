[css:navigation.css]
[css:posts.css]
[css:postnew.css]
[css:threadnew.css]

<div class="new_editor">
  <div class="ui">
    <a class="ui" href=".">The thread</a>
  </div>
  <form id="editform" action="!edit_thread" method="post">

    <p>Title:</p>
    <input type="edit" value="[caption]" placeholder="Thread title" name="title" autofocus>
    <p>Tags: <span class="small">(max 3, comma delimited, no spaces)</span> [case:[special:dir]| |+ "[special:dir]"]</p>
    <input type="edit" value="[tags]" name="tags" placeholder="some tags here">
    [case:[special:isadmin]||<input type="checkbox" id="pinned" name="pinned" value="1" [case:[Pinned]||checked]><label for="pinned">Pin the thread on top</label>]
    <input type="checkbox" id="private" name="private" value="1" [case:[private]||checked]><label for="private">Private thread</label>
    <div id="users_invited">
      <p>Invited users (comma separated list):</p>
      <input id="invited" type="edit" value="[invited]" name="invited">
    </div>
    <div class="panel">
      <input type="submit" name="submit" value="Submit" >
      <input type="hidden" name="ticket" value="[Ticket]" >
      <input type="reset" value="Revert" >
    </div>
  </form>
</div>
