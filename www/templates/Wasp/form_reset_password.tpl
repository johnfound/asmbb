[css:navigation.css]
[css:login.css]

<div class="login">
  <div class="ui">
    <a class="ui" href="/">Threads</a>
  </div>
  <article>
    <p>Check your mail box for confirmation e-mail. Copy the <b>secret code</b> from the e-mail to this form "Secret token" field. Fill in <b>all</b> remaining fields. Submit the form.</p>
  </article>
  <form class="register-block" method="post" action="/!resetpassword/3">
    <h1>Reset password</h1>
    <input type="text" value="" placeholder="User name" name="username" class="username" maxlength="256" autofocus>
    <input type="text" value="" placeholder="e-mail" name="email" class="email" maxlength="320">
    <input type="text" value="" name="secret" placeholder="Secret token" class="password" maxlength="32">
    <input type="password" value="" placeholder="Password" name="password" class="password" maxlength="1024" autocomplete="off">
    <input type="password" value="" placeholder="Password again" name="password2" class="password" maxlength="1024" autocomplete="off">
    <input type="hidden" value="[ticket]" name="ticket" id="ticket">
    <input type="submit" name="submit" class="submit" value="Submit">
  </form>
  <article>
    <p>To choose strong password and write it down on a paper is better than to choose easy to remember password.</p>
    <p>Because the humans are not very good in remembering random strings, but pretty good in keeping small sheets of paper.</p>
    <p>But don't stick it on your monitor. Simply keep it in your wallet...</p>
    <p>... or use some password manager program.</p>
  </article>
</div>
