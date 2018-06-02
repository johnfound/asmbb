[css:navigation.css]
[css:login.css]

<div class="login">
  <div class="ui">
    <a class="ui" href="/">Threads</a>
  </div>
  <form class="login-block" method="post" target="_self" action="/!forgetuser">
    <h1>Delete account!</h1>
    <input type="text" value="" placeholder="Username" name="username" class="username" autofocus maxlength="256">
    <input type="password" value="" placeholder="Password" name="password" class="password" maxlength="1024" autocomplete="off">
    <input type="hidden" value="[special:referer]" name="backlink" id="backlink">
    <input type="hidden" value="[ticket]" name="ticket" id="ticket">
    <input type="submit" name="submit" class="submit" value="Forget me!">
  </form>

  <article>
    <p><b>Important!</b> This form will delete all personal information about you!</p>
    <p>After entering your user name and correct password your account will be deleted and
    all your posts on the forum will be assigned to anonymous user that can not be associated with you in any way.</p>

    <p>After this operation, you will never be able to take back this account.</p>

    <p><b>Here is the list of operations that will be performed:</b></p>

    <ul>
      <li>Your password hash and salt will be deleted from the database.</li>
      <li>Your nickname will be replaced with AnonNNNN where NNNN is some random number.</li>
      <li>The user data provided by you in your profile will be deleted from the database.</li>
      <li>Your avatar image will be deleted from the database.</li>
      <li>Your email address will be deleted as well. This way the administrators will not be able to contact you anymore.</li>
      <li>All records from the logs related to your account will be deleted.</li>
    </ul>

    <p>Your posts will not be automatically deleted, in order to not break the threads consistency, but will not be accociated with
    you as a person anymore. If some of these posts contains private and identifying information, please edit them before you delete your account!
    Or ask the administrator of the forum to edit this information for you (if for example you don't have editing priviledges).</p>
    <p><b>Vandalizing the threads by mass deletes and edits is extremely undesirable!</b> Delete only the information that can deanonymize you as a person.</p>
    <p>The personal data in the posts, associated with deleted accounts can be further edited by the administration with or without implicit request in order to anonymize the posts as much as possible.</p>
  </article>
</div>
