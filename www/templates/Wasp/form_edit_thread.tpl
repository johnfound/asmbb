[css:navigation.css]
[css:posts.css]
[css:postnew.css]
[css:threadnew.css]

<div class="new_editor">
  <div class="ui">
    <a class="ui left" href=".">The thread</a>
  </div>
  <form id="editform" action="!edit_thread" method="post">

    <p>Title:</p>
    <input type="edit" value="[caption]" placeholder="Thread title" name="title" autofocus>
    <p>Tags: <span class="small">(max 3, comma delimited, no spaces)</span> [case:[special:dir]| |+ "[special:dir]"]</p>
    <input type="edit" value="[tags]" name="tags" id="tags" placeholder="some tags here" oninput="OnKeyboard(this)" onkeydown="EditKeyDown(event, this)" getlist="/!tagmatch/">
    [case:[special:isadmin]||<input type="checkbox" id="pinned" name="pinned" value="1" [case:[Pinned]||checked]><label for="pinned">Pin the thread on top</label>]
    <input type="checkbox" id="limited" name="limited" value="1" [case:[limited]||checked]><label for="limited">Limited access thread</label>
    <div id="users_invited">
      <p>Invited users (comma separated list):</p>
      <input id="invited" type="edit" value="[invited]" name="invited" oninput="OnKeyboard(this)" onkeydown="EditKeyDown(event, this)" getlist="/!usersmatch/">
    </div>
    <div class="panel">
      <input type="submit" name="submit" value="Submit" >
      <input type="hidden" name="ticket" value="[Ticket]" >
      <input type="reset" value="Revert" >
    </div>
  </form>
</div>

[include:autocomplete.js]
