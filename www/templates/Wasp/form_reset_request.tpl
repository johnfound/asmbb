[css:navigation.css]
[css:login.css]

<div class="login">
  <div class="ui">
    <a class="ui" href="/">Threads</a>
  </div>
  <form class="register-block" method="post">
    <h1>Reset password request</h1>
    <input type="text" value="" placeholder="Username" name="username" class="username" maxlength="256" autofocus>
    <input type="hidden" value="[ticket]" name="ticket" id="ticket">
    <input type="submit" name="submit" class="submit" value="Submit">
  </form>
  <article>
    <p>When you click "submit", an email with the password reset link will be sent to your account email address.</p>
    <p>Notice, that if you used invalid email on the registration, the reset process will fail.</p>
    <p>In this case, the only option is to create a new account.</p>
  </article>
</div>
