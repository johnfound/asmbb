[css:navigation.css]
[css:login.css]

<div class="login">
  <div class="ui">
    <a class="ui" href="/">Threads</a>
  </div>
  <form class="login-block" method="post" target="_self" action="/!login">
    <h1>Login</h1>
    <input type="text" value="" placeholder="Username" name="username" class="username" autofocus maxlength="256">
    <input type="password" value="" placeholder="Password" name="password" class="password" maxlength="1024" autocomplete="off">
    <input type="hidden" value="[special:referer]" name="backlink" id="backlink">
    <input type="checkbox" name="persistent" id="pr" value="1"><label for="pr">Persistent login</label>
    <input type="hidden" value="[ticket]" name="ticket" id="ticket">
    <input type="submit" name="submit" class="submit" value="Submit">
  </form>
  <article>
    <p>If you forgot your password, <b><a href="/!resetpassword">click here</a></b>. You have limited reset attempts.</p>
    [case:[special:canregister]||<p>If you don't have an account, you should <b><a href="/!register">register one</a></b>.</p>]
    <p></p>
    <p>The login process uses cookies. If the "Persistent login" checkbox is checked, the cookie will be stored persistently in your browser.</p>
    <p>If the "Persistent login" checkbox is not checked (default), AsmBB uses so called "session cookies" that are automatically removed when you close your browser.</p>
    <p>When you logout from the forum, all cookies are removed as well.</p>
  </article>
</div>