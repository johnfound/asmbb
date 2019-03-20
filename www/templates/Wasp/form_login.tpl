[css:navigation.css]
[css:login.css]

[case:[special:lang]|
  [equ:btnThreads=Threads]
  [equ:ttlLogin=Login]
  [equ:phUser=Username]
  [equ:phPass=Password]
  [equ:lblPers=Persistent login]
  [equ:btnSubmit=Submit]
  [equ:helpLogin=
    [case:[email_flag]||<p>If you forgot your password, <b><a href="/!resetpassword">click here</a></b>. You have limited reset attempts.</p>]
    [case:[special:canregister]||<p>If you don't have an account, you should <b><a href="/!register">register one</a></b>.</p>]
    <p></p>
    <p>The login process uses cookies. If the "Persistent login" checkbox is checked, the cookie will be stored persistently in your browser.</p>
    <p>If the "Persistent login" checkbox is not checked (default), AsmBB uses so called "session cookies" that are automatically removed when you close your browser.</p>
    <p>When you logout from the forum, all cookies are removed as well.</p>
  ]
|
  [equ:btnThreads=Теми]
  [equ:ttlLogin=Включване]
  [equ:phUser=Потребител]
  [equ:phPass=Парола]
  [equ:lblPers=Постоянно включване]
  [equ:btnSubmit=Включи се]
  [equ:helpLogin=
    [case:[email_flag]||<p>Ако сте забравили паролата, <b><a href="/!resetpassword">натиснете тук</a></b>. Имате ограничен брой опити за нулиране.</p>]
    [case:[special:canregister]||<p>Ако не сте регистрирани, можете да <b><a href="/!register">регистрате потребител</a></b>.</p>]
    <p></p>
    <p>За запомняне на включването се използват т.н. бисквитки (cookies). Ако сте избрали опцията "Постоянно включване", бисквитката се записва постоянно в браузъра.</p>
    <p>Ако тази опция не е избрана (по подразбиране е така) се използват временни бисквитки, които се изтриват автоматично при затваряне на браузъва.</p>
    <p>При ръчно изключване от форума, всички бисквитки се изтриват независимо от това дали са временни или постоянни.</p>
  ]
|
  [equ:btnThreads=Темы]
  [equ:ttlLogin=Включение]
  [equ:phUser=Потребитель]
  [equ:phPass=Пароль]
  [equ:lblPers=Постоянный логин]
  [equ:btnSubmit=Войти]
  [equ:helpLogin=
    [case:[email_flag]||<p>Если вы забыли пароль, <b><a href="/!resetpassword">нажмите здесь</a></b>. У вас ограниченное число попыток сброса.</p>]
    [case:[special:canregister]||<p>Если у вас нет учетной записи, можете <b><a href="/!register">зарегистроваться здесь</a></b>.</p>]
    <p></p>
    <p>Процесс входа использует куки. Если флажок «Постоянный логин» установлен, куки будут постоянно сохраняться в вашем браузере.</p>
    <p>Если флажок «Постоянный логин» не установлен (по умолчанию), AsmBB использует так называемые «сеансовые куки», которые автоматически удаляются при закрытии браузера.</p>
    <p>Когда вы выходите из форума, все куки также удаляются.</p>
  ]
|
  [equ:btnThreads=Sujetss]
  [equ:ttlLogin=Connexion]
  [equ:phUser=Pseudo]
  [equ:phPass=Mot de passe]
  [equ:lblPers=Rester connecté]
  [equ:btnSubmit=Submit]
  [equ:helpLogin=
    [case:[email_flag]||<p>Si vous avez oublié votre mot de passe, <b><a href="/!resetpassword">cliquez ici</a></b>.</p>]
    [case:[special:canregister]||<p>Si vous n'avez pas de compte, vous pouvez <b><a href="/!register">en créer un</a></b>.</p>]
    <p></p>
    <p>La connexion installe un cookie. Si vous cochez la case "Rester connecté", ce cookie sera conservé indéfiniment.</p>
    <p>Si la case "Resté connecté" n'est pas cochée, AsmBB utilisera un cookie de sessions qui sera automatiquement détruit lorsque vous quitterez le site.</p>
    <p>Lorsque vous vous déconnectez, tous les cookies seront également détruits.</p>
  ]
|
  [equ:btnThreads=Themen]
  [equ:ttlLogin=Anmelden]
  [equ:phUser=Benutzername]
  [equ:phPass=Passwort]
  [equ:lblPers=Dauerhaft anmelden]
  [equ:btnSubmit=Absenden]
  [equ:helpLogin=
    [case:[email_flag]||<p>Falls Sie Ihr Passwort vergessen haben, <b><a href="/!resetpassword">klicken Sie hier</a></b>. Ihre Versuche zur Zurücksetzung sind begrenzt.</p>]
    [case:[special:canregister]||<p>Falls Sie noch kein Konto haben, sollten Sie <b><a href="/!register">sich registrieren</a></b>.</p>]
    <p></p>
    <p>Der Anmeldevorgang verwendet Cookies. Falls Sie das Häkchen für die dauerhafte Anmeldung gesetzt haben, so wird es in Ihrem Browser aufbewahrt.</p>
    <p>Ist es nicht gesetzt (das ist der Standard), so verwendet AsmBB so genannte "Sitzungscookies", die automatisch gelöscht werden, wenn Sie Ihren Browser schließen.</p>
    <p>Wenn Sie sich im Forum abmelden, werden ebenfalls alle Cookies entfernt.</p>
  ]
]

<div class="login">
  <div class="ui">
    <a class="ui" href="/">[const:btnThreads]</a>
  </div>
  <form class="login-block" method="post" target="_self" action="/!login">
    <h1>[const:ttlLogin]</h1>
    <p class="pi_nick"><input type="text" value="" placeholder="[const:phUser]" name="username" class="username" autofocus maxlength="256"></p>
    <p class="pi_pass"><input type="password" value="" placeholder="[const:phPass]" name="password" class="password" maxlength="1024" autocomplete="off"></p>
    <p class="pi_tick"><input type="text" value="[special:referer]" name="backlink" id="backlink"></p>
    <p class="pi_nick"><input type="checkbox" name="persistent" id="pr" value="1"><label for="pr">[const:lblPers]</label></p>
    <p class="pi_tick"><input type="text" value="[ticket]" name="ticket" id="ticket"></p>
    <noscript>
       <p class="pi_tick">
       <input type="text" name="submit.x" value="0">
       <input type="text" name="submit.y" value="0">
       </p>
    </noscript>
    <input type="image" name="submit" id="submit" value="Submit"><label class="submit" for="submit">[const:btnSubmit]</label>
  </form>
  <article>
    [const:helpLogin]
  </article>
</div>