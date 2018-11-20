[css:navigation.css]
[css:login.css]

<div class="login">
  <div class="ui">
    <a class="ui" href="/">Threads</a>
  </div>
  <form class="register-block" method="post" action="/!register/">
    <h1>Register</h1>
    <p class="pi_nick"><input type="text" value="" placeholder="Username" name="username" class="username" maxlength="256" autofocus></p>
    <p class="[case:[email_flag]|pi_email|pi_nick]"><input type="text" value="" placeholder="e-mail" name="email" class="email" maxlength="320"></p>
    <p class="pi_pass"><input type="password" value="" placeholder="Password" name="password" class="password" maxlength="1024" autocomplete="off"></p>
    <p class="pi_pass"><input type="password" value="" placeholder="Password again" name="password2" class="password" maxlength="1024" autocomplete="off"></p>
    <p class="pi_tick"><input type="text" value="[ticket]" name="ticket" id="ticket" class="ticket"></p>
    <label class="submit" for="submit">Submit</label><input type="image" name="submit" id="submit" value="Submit">
  </form>
  <article>
    <p>To choose strong password and write it down on a paper is better than to choose easy to remember password.</p>
    <p>Because the humans are not very good in remembering random strings, but pretty good in keeping small sheets of paper.</p>
    <p>But don't stick it on your monitor. Simply keep it in your wallet...</p>
    <p>... or use some password manager program.</p>
  </article>
</div>
