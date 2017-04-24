<div class="new_editor">
  <div class="ui">
    <a class="ui" href=".">The thread</a>
  </div>
  <form id="editform" action="!edit_thread" method="post">
    <p>Title:</p>
    <input class="title" type="edit" value="[caption]" placeholder="Thread title" name="title" autofocus>
    <br><br>
    <p>Tags: <span class="small">(max 3, comma delimited, no spaces)</span> [case:[special:dir]| |+ "[special:dir]"]</p>
    <input class="tags"  type="edit" value="[tags]" name="tags" placeholder="some tags here"><br>
    <br>
    <div class="panel">
      <input type="submit" name="submit" value="Submit" >
      <input type="hidden" name="ticket" value="[Ticket]" >
      <input type="reset" value="Revert" >
    </div>
  </form>
</div>
