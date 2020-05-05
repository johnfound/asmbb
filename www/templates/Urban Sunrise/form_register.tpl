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
  <form class="register-block" method="post" action="/!register/">
    <h1>[const:ttlRegister]</h1>

    <h3>[const:phUser]:</h3>
    <input type="text" value="" name="username" class="username" maxlength="256" autofocus>

    <div [case:[email_flag]|class="pi_email"|]>
      <h3>[const:phEmail]:</h3>
      <input type="text" value="" name="email" maxlength="320">
    </div>

    <h3>[const:phPass]:</h3>
    <input type="password" value="" name="password" class="password" maxlength="1024" autocomplete="off">

    <h3>[const:phPass2]:</h3>
    <input type="password" value="" name="password2" class="password" maxlength="1024" autocomplete="off">

    <input type="text" value="[ticket]" name="ticket" id="ticket" class="pi_tick">

    <p></p>
    <div class="btn-bar"><label class="btn" for="submit"><input type="image" name="submit" id="submit" value="Submit">[const:btnSubmit]</label></div>
  </form>
  <article>
    [const:helpRegister]
  </article>
</div>
