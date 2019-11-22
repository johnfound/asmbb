[css:common.css]
[css:navigation.css]
[css:toaster.css]

[case:[special:lang]|
  [equ:ttlPublic=Public threads]
  [equ:ttlLimited=Limited access threads]
  [equ:Public=Public]
  [equ:Limited=Limited]
  [equ:Register=Register]
  [equ:Login=Login]
  [equ:Logout=Logout]
  [equ:Profile=User profile]
  [equ:ttlSearchTxt=text search]
  [equ:ttlSearchUsr=user search]
  [equ:ttlSearchBtn=Search]
  [equ:ttlAllThreads=All tags]
|
  [equ:ttlPublic=Публични теми]
  [equ:ttlLimited=Теми с ограничен достъп]
  [equ:Public=Публични]
  [equ:Limited=Ограничени]
  [equ:Register=Регистрация]
  [equ:Login=Вход]
  [equ:Logout=Изход]
  [equ:Profile=Профил]
  [equ:ttlSearchTxt=търсене на текст]
  [equ:ttlSearchUsr=потребител]
  [equ:ttlSearchBtn=Търсене]
  [equ:ttlAllThreads=Всички теми]
|
  [equ:ttlPublic=Публичные темы]
  [equ:ttlLimited=Темы с ограниченным доступом]
  [equ:Public=Публичные]
  [equ:Limited=Ограниченные]
  [equ:Register=Регистрация]
  [equ:Login=Вход]
  [equ:Logout=Выйти]
  [equ:Profile=Профиль]
  [equ:ttlSearchTxt=поиск текста]
  [equ:ttlSearchUsr=пользователь]
  [equ:ttlSearchBtn=Поиск]
  [equ:ttlAllThreads=Все темы]
|
  [equ:ttlPublic=Discussions publiques]
  [equ:ttlLimited=Discussions restreintes]
  [equ:Public=Publiques]
  [equ:Limited=Restreintes]
  [equ:Register=Inscription]
  [equ:Login=Connexion]
  [equ:Logout=Se déconnecter]
  [equ:Profile=Profil]
  [equ:ttlSearchTxt=recherche de texte]
  [equ:ttlSearchUsr=recherche d'utilisateur]
  [equ:ttlSearchBtn=Rechercher]
  [equ:ttlAllThreads=Montrer tous les sujets]
|
  [equ:ttlPublic=Öffentliche Themen]
  [equ:ttlLimited=Themen mit beschränktem Zugang]
  [equ:Public=Öffentliche]
  [equ:Limited=Beschränkt]
  [equ:Register=Registrieren]
  [equ:Login=Anmelden]
  [equ:Logout=Abmelden]
  [equ:Profile=Profil]
  [equ:ttlSearchTxt=Textsuche]
  [equ:ttlSearchUsr=Benutzersuche]
  [equ:ttlSearchBtn=Suchen]
  [equ:ttlAllThreads=Alle Themen zeigen]
]


<!DOCTYPE html>
<html lang="[case:[special:lang]|en|bg|ru|fr|de]">
<head>
  <meta charset="utf-8">
  <title>[special:title]</title>
  [case:[special:limited]|<link href="!feed" type="application/atom+xml" rel="alternate" title="Atom feed">|]
  <meta name="description" content="[special:description]">
  <meta name="keywords" content="[special:keywords]">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scallable=no">
  [special:allstyles]
  <link rel="apple-touch-icon" sizes="57x57" href="/images/favicons/apple-touch-icon-57x57.png">
  <link rel="apple-touch-icon" sizes="60x60" href="/images/favicons/apple-touch-icon-60x60.png">
  <link rel="apple-touch-icon" sizes="72x72" href="/images/favicons/apple-touch-icon-72x72.png">
  <link rel="apple-touch-icon" sizes="76x76" href="/images/favicons/apple-touch-icon-76x76.png">
  <link rel="apple-touch-icon" sizes="114x114" href="/images/favicons/apple-touch-icon-114x114.png">
  <link rel="apple-touch-icon" sizes="120x120" href="/images/favicons/apple-touch-icon-120x120.png">
  <link rel="apple-touch-icon" sizes="144x144" href="/images/favicons/apple-touch-icon-144x144.png">
  <link rel="apple-touch-icon" sizes="152x152" href="/images/favicons/apple-touch-icon-152x152.png">
  <link rel="apple-touch-icon" sizes="180x180" href="/images/favicons/apple-touch-icon-180x180.png">
  <link rel="icon" type="image/png" href="/images/favicons/favicon-32x32.png" sizes="32x32">
  <link rel="icon" type="image/png" href="/images/favicons/favicon-194x194.png" sizes="194x194">
  <link rel="icon" type="image/png" href="/images/favicons/favicon-96x96.png" sizes="96x96">
  <link rel="icon" type="image/png" href="/images/favicons/android-chrome-192x192.png" sizes="192x192">
  <link rel="icon" type="image/png" href="/images/favicons/favicon-16x16.png" sizes="16x16">
  <link rel="manifest" href="/images/favicons/manifest.json">
  <link rel="mask-icon" href="/images/favicons/safari-pinned-tab.svg">
  <link rel="shortcut icon" href="/images/favicons/favicon.ico">
  <meta name="msapplication-TileColor" content="#ffffff">
  <meta name="msapplication-TileImage" content="/images/favicons/mstile-144x144.png">
  <meta name="msapplication-config" content="/images/favicons/browserconfig.xml">
  <meta name="theme-color" content="#ffcc40">

  <noscript>
    <style> .jsonly { display: none !important } </style>
  </noscript>

  <script type='text/javascript'>
    [raw:realtime.js]
  </script>

</head>

<body>

<div id="header_panel" class="panel">
  <div class="header">
    <h1>AsmBB</h1>
    <div class="spacer"></div>
    <form method="POST" action="/!skincookie">
      <select class="skin" name="skin" onchange="this.form.submit()">
        <option value="0">(Default)</option>
        [special:skins=[special:skincookie]]
      </select>
      <noscript><input type="submit" value="Go"></noscript>
    </form>

    <div>
      [case:[special:userid]
        |<a href="/!login/">[const:Login]</a><br>
          [case:[special:canregister]||<a href="/!register/">[const:Register]</a>]
        |<form method="POST" action="/!logout"><input class="logout" type="submit" name="logout"
         value="[const:Logout] ([special:username])"></form>
         <a href="/!userinfo/[url:[special:username]]">[const:Profile]</a>
      ]
    </div>

  </div>
  <form id="search_form" action="[case:[special:cmdtype]||/|../]!search/" method="get" >
    <input class="search_line" type="search" name="s" placeholder="[const:ttlSearchTxt]" value="[special:search]">
    <input class="search_line" type="search" name="u" placeholder="[const:ttlSearchUsr]" value="[special:usearch]">
    <a class="icon_btn"><input class="img_input" type="image" width="32" height="32" src="[special:skin]/_images/search.svg" alt="&nbsp;Search&nbsp;" title="[ttlSearchBtn]"></a>
  </form>
</div>


<div id="layout">

    <div id="tagsPanel">
      <div>
      [case:[special:userid]||
        <a class="[case:[special:limited]|ui|ui3] left" href="/[case:[special:dir]||[special:dir]/]" title="[const:ttlPublic]">[const:Public][special:unread]</a>
        <a class="[case:[special:limited]|ui3|ui]" href="/(o)/[case:[special:dir]||[special:dir]/]" title="[const:ttlLimited]">[const:Limited][special:unreadLAT]</a>
      ]
      </div>
      <a class="taglink [case:[special:variant]|current_tag|current_tag|] alltags"
      href="/[case:[special:limited]||(o)/]"><img class="tagicon" src="[special:skin]/_images/alltags[case:[special:variant]|||_gray].svg" alt="/" title="[const:ttlAllThreads]">[const:ttlAllThreads]</a>
      [special:alltags2]
    </div>
