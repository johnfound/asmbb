[css:settings.css]

[case:[special:lang]|
  [equ:ttlError=Error! Another not finished post exists.]
  [equ:errExplain1=Can't create new post, because exists not finished post by you in]
  [equ:errExplain2=a new thread.]
  [equ:errExplain3=the thread:]
  [equ:errQuestion=What to do with the existing post/thread?]
  [equ:actCancel=Do nothing. Cancel the current operation.]
  [equ:actDelete=Delete the existing draft and create new post.]
  [equ:actEdit=Let me finish the existing draft first.]
|
  [equ:ttlError=Грешка! Имате незавършен пост.]
  [equ:errExplain1=Не мога да създам нов пост/тема, защото имате незавършен пост в]
  [equ:errExplain2=новосъздадена тема.]
  [equ:errExplain3=темата:]
  [equ:errQuestion=Какво да правя със съществуващият пост/тема?]
  [equ:actCancel=Не прави нищо. Върни ме обратно.]
  [equ:actDelete=Изтрий предишната чернова и създай нов пост.]
  [equ:actEdit=Дай ми да завърша недовършения пост.]
|
  [equ:ttlError=Ошибка! У вас есть незаконченный пост.]
  [equ:errExplain1=Не могу создать новый пост, потому что уже существует ваш черновик в]
  [equ:errExplain2=новой теме.]
  [equ:errExplain3=в теме:]
  [equ:errQuestion=Что делать с сущестующим черновиком?]
  [equ:actCancel=Ничего не делай. Верни меня назад.]
  [equ:actDelete=Удали существующий черновик и создай новое сообщение.]
  [equ:actEdit=Давай сначала я закончу с существующим черновиком.]
|
  [equ:ttlError=Erreur! Un autre message non terminé existe.]
  [equ:errExplain1=Impossible de créer un nouveau message, car il n'existe pas de message terminé de votre part dans]
  [equ:errExplain2=un nouveau fil de discussion.]
  [equ:errExplain3=:]
  [equ:errQuestion=Que faire des brouillons?]
  [equ:actCancel=Ne rien faire. Annuler l'opération en cours.]
  [equ:actDelete=Supprimer le brouillon existant et créer un nouveau message.]
  [equ:actEdit=Je finirai d'abord le projet existant.]
|
  [equ:ttlError=Fehler! Ein weiterer nicht beendeter Beitrag existiert.]
  [equ:errExplain1=Kann keinen neuen Beitrag erstellen, da ein noch nicht abgeschlossener Beitrag von Ihnen in]
  [equ:errExplain2= einem neuen Thema existiert.]
  [equ:errExplain3=:]
  [equ:errQuestion=Was tun mit dem bestehenden Beitrag/Thread?]
  [equ:actCancel=Er tut nichts. Bring mich zurück.]
  [equ:actDelete=Löschen Sie den vorhandenen Entwurf und erstellen Sie einen neuen Beitrag.]
  [equ:actEdit=Lassen Sie mich zuerst den bestehenden Entwurf fertigstellen.]
]


<form class="settings msgbox" method="post">
  <input type="hidden" name="ticket" value="[ticket]">

  <h1>[const:ttlError]</h1>

  <p>[const:errExplain1] [case:[LastChanged]|[const:errExplain2]|[const:errExplain3]

  <a href="/[slug]/"><h2><center>[Caption]</center></h2></a>

  ]

  <p>[const:errQuestion]
  <p>
  <p><a class="btn" href=".">[const:actCancel]</a>
  <p><button class="btn" type="submit" name="action" value="delete">[const:actDelete]</button>
  <p><button class="btn" type="submit" name="action" value="edit">[const:actEdit]</button>
</form>
