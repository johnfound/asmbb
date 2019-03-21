[css:navigation.css]
[css:login.css]

[case:[special:lang]|
  [equ:btnThreads=Threads]
  [equ:ttlRegister=Register]
  [equ:phUser=Username]
  [equ:phEmail=e-mail]
  [equ:phPass=Password]
  [equ:phPass2=Password again]
  [equ:btnSubmit=Submit]
  [equ:helpRegister=
    <p>To choose strong password and write it down on a paper is better than to choose easy to remember password.</p>
    <p>Because the humans are not very good in remembering random strings, but pretty good in keeping small sheets of paper.</p>
    <p>But don't stick it on your monitor. Simply keep it in your wallet...</p>
    <p>... or use some password manager program.</p>
  ]
|
  [equ:btnThreads=Теми]
  [equ:ttlRegister=Регистрация]
  [equ:phUser=Потребител]
  [equ:phEmail=e-mail]
  [equ:phPass=Парола]
  [equ:phPass2=Паролата отново]
  [equ:btnSubmit=Регистрирай]
  [equ:helpRegister=
    <p>По добре да си изберете силна парола и да я запишете на листче, отколкото да си изберете лесна за запомняне парола.</p>
    <p>Защото хората не са много добри в помнене на случайни символи, но са много добре в пазенето на малки листчета хартия.</p>
    <p>Само не лепете листчето на монитора! Просто го сложете в портфейла си...</p>
    <p>... или използвайте програма – менажер на пароли.</p>
  ]
|
  [equ:btnThreads=Темы]
  [equ:ttlRegister=Регистрация]
  [equ:phUser=Потребитель]
  [equ:phEmail=Адрес электронной почты]
  [equ:phPass=Пароль]
  [equ:phPass2=Пароль еще раз]
  [equ:btnSubmit=Регистрируй]
  [equ:helpRegister=
    <p>Лучше выбрать надежный пароль и написать его на бумаге, чем выбрать пароль, которого легко запомнить.</p>
    <p>Потому что люди не очень хорошо запоминают случайные символы, но хорошо умеют хранить бумаги.</p>
    <p>Только не наклеивайте пароль на монитор! Просто положите его в свой кошелек...</p>
    <p>...или используйте программу менеджера паролей.</p>
  ]
|
  [equ:btnThreads=Sujets]
  [equ:ttlRegister=Inscription]
  [equ:phUser=Nom d'utilisateur]
  [equ:phEmail=e-mail]
  [equ:phPass=Mot de passe]
  [equ:phPass2=Retaper le mot de passe]
  [equ:btnSubmit=Envoyer]
  [equ:helpRegister=
    <p>Choisir un mot de passe compliqué et l'écrire sur un papier vaut mieux qu'un mot de passe trop simple.</p>
    <p>Les humains ne sont pas vraiment capables de se souvenir de mot de cominaisons compliquées mais sont meilleurs pour garder des bouts de papiers.</p>
    <p>Mais ne les collez pas sur votre écran. Gardez-les plutôt dans une pochette ...</p>
    <p>... ou utiliser un gestionnaire de mots de passe.</p>
  ]
|
  [equ:btnThreads=Themen]
  [equ:ttlRegister=Registrieren]
  [equ:phUser=Benutzername]
  [equ:phEmail=E-Mail-Adresse]
  [equ:phPass=Passwort]
  [equ:phPass2=Passwort (noch mal)]
  [equ:btnSubmit=Absenden]
  [equ:helpRegister=
    <p>Ein starkes Passwort zu wählen und es aufzuschreiben ist besser als eines zu verwenden, das Sie sich leicht merken können.</p>
    <p>Weil Menschen nicht besonders gut darin sind, sich zufällige Zeichenfolgen zu merken, aber ziemlich gut darin, kleine Stücke Papier aufzubewahren.</p>
    <p>Aber kleben Sie es nicht an Ihren Bildschirm. Stecken Sie es einfach in Ihr Portemonnaie...</p>
    <p>... oder benutzen Sie irgendein Programm zur Passwortverwaltung-</p>
  ]
]


<div class="login">
  <div class="ui">
    <a class="ui" href="/">Threads</a>
  </div>
  <form class="register-block" method="post" action="/!register/">
    <h1>[const:ttlRegister]</h1>
    <p class="pi_nick"><input type="text" value="" placeholder="[const:phUser]" name="username" class="username" maxlength="256" autofocus></p>
    <p class="[case:[email_flag]|pi_email|pi_nick]"><input type="text" value="" placeholder="[const:phEmail]" name="email" class="email" maxlength="320"></p>
    <p class="pi_pass"><input type="password" value="" placeholder="[const:phPass]" name="password" class="password" maxlength="1024" autocomplete="off"></p>
    <p class="pi_pass"><input type="password" value="" placeholder="[const:phPass2]" name="password2" class="password" maxlength="1024" autocomplete="off"></p>
    <p class="pi_tick"><input type="text" value="[ticket]" name="ticket" id="ticket" class="ticket"></p>
    <label class="submit" for="submit">[const:btnSubmit]</label><input type="image" name="submit" id="submit" value="Submit">
  </form>
  <article>
    [const:helpRegister]
  </article>
</div>
