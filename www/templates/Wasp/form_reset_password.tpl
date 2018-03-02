[css:navigation.css]
[css:login.css]

<div class="login">
  <div class="ui">
    <a class="ui" href="/">Threads</a>
  </div>
  <form class="register-block" method="post">
    <h1>Reset password</h1>
    <input type="text" value="[nick]" name="username" class="username" maxlength="256" readonly>
    <input type="password" value="" placeholder="Password" name="password" class="password" maxlength="1024" autocomplete="off" autofocus>
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
