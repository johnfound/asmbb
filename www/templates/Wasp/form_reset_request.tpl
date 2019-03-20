[css:navigation.css]
[css:login.css]
[css:settings.css]

[case:[special:lang]|
  [equ:ttlRequest=Reset password request]
  [equ:phUser=Username]
  [equ:phEmail=e-mail]
  [equ:btnSubmit=Submit]
  [equ:helpRequest=
    <p>You have one reset attempt in 24 hours.</p>
    <p>Fill in your user name and the e-mail associated with your account.</p>
    <p>When you click "submit", an email with the password reset link will be sent to your account email address.</p>
    <p>Notice, that if you used invalid email on the registration, the reset process will fail.</p>
    <p>In this case, the only option is to create a new account.</p>
  ]
|
  [equ:ttlRequest=Заявка за възстановяване на парола]
  [equ:phUser=Потребител]
  [equ:phEmail=e-mail]
  [equ:btnSubmit=Изпрати]
  [equ:helpRequest=
    <p>Имате един опит за нулиране на 24 часа.</p>
    <p>Въведете потребителското си име и имейла, свързан с акаунта.</p>
    <p>Когато натиснете "изпрати", ще ви бъде изпратено писмо с връзка за продължаване на процеса.</p>
    <p>Забележете, че ако сде дали невалиден адрес при регистрацията, процеса на нулиране ще е неуспешен.</p>
    <p>В този случай, единственото решение е да създадене нов акаунт.</p>
  ]
|
  [equ:ttlRequest=Запрос сброса пароля]
  [equ:phUser=Потребитель]
  [equ:phEmail=Адрес электронной почты]
  [equ:btnSubmit=Отправить]
  [equ:helpRequest=
    <p>У вас есть одна попытка сброса за 24 часа.</p>
    <p>Введите ваше имя пользователя и адрес электронной почты, связанный с вашей учетной записью.</p>
    <p>Когда вы нажимаете «отправить», на адрес электронной почты вашей учетной записи будет отправлено письмо со ссылкой для сброса пароля.</p>
    <p>Обратите внимание, что если вы использовали неверный адрес электронной почты при регистрации, процесс сброса не удастся.</p>
    <p>В этом случае единственный вариант - создать новую учетную запись.</p>
  ]
|
  [equ:ttlRequest=Réinitialiser la demande de mot de passe]
  [equ:phUser=Nom d'utilisateur]
  [equ:phEmail=email]
  [equ:btnSubmit=Envoyer]
  [equ:helpRequest=
    <p>Vous avez droit à une réinitialisation toutes les 24h.</p>
    <p>Remplissez le champ nom d'utilisateur et e-mail associé à votre compte.</p>
    <p>Lorque vous cliquez sur "Envoyer", un email comptenant un lien de réinitialisation de mot de passe sera envoyé à votre adresse email.</p>
    <p>Si vous avez fourni un email invalide lors de votre inscription, cela ne fonctionnera pas.</p>
    <p>Dans ce cas, la seule solution est de recréer un compte.</p>
  ]
|
  [equ:ttlRequest=Anforderung der Passwortzurücksetzung]
  [equ:phUser=Benutzername]
  [equ:phEmail=E-Mail-Adresse]
  [equ:btnSubmit=Absenden]
  [equ:helpRegister=
    <p>Ihnen steht eine Zurücksetzung je 24 Stunden zur Verfügung.</p>
    <p>Geben Sie Ihren Benutzernamen und die E-Mail-Adresse Ihres Benutzerkontos an.</p>
    <p>Wenn Sie auf "Absenden" klicken, wird eine E-Mail mit einem Link zur Zurücksetzung des Passworts an Ihre E-Mail-Adresse gesendet.</p>
    <p>Beachten Sie, dass, falls Sie bei der Registrierung eine ungültige E-Mail-Adresse angegeben haben, dieser Vorgang fehlschlagen wird.</p>
    <p>In diesem Fall ist Ihre einzige Option die Registrierung eines neuen Kontos.</p>
  ]
]

<div class="login">
  <div class="ui">
    <a class="ui" href="/">Threads</a>
  </div>
  <form class="register-block" method="post" action="/!resetpassword/1">
    <h1>[const:ttlRequest]</h1>
    <input type="text" value="" placeholder="[const:phUser]" name="username" class="username" maxlength="256" autofocus>
    <input type="text" value="" placeholder="[const:phEmail]" name="email" class="email" maxlength="320">
    <input type="hidden" value="[ticket]" name="ticket" id="ticket">
    <input type="submit" name="submit" class="button" value="[const:btnSubmit]">
  </form>
  <article>
    [const:helpRequest]
  </article>
</div>
