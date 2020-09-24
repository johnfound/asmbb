[css:common.css]
[css:navigation.css]
[css:toaster.css]

[case:[special:lang]|
  [equ:ttlPublic=Public threads]
  [equ:ttlLimited=Limited access threads]
  [equ:Public=Public]
  [equ:Limited=Limited]
|
  [equ:ttlPublic=Публични теми]
  [equ:ttlLimited=Теми с ограничен достъп]
  [equ:Public=Публични]
  [equ:Limited=Ограничени]
|
  [equ:ttlPublic=Публичные темы]
  [equ:ttlLimited=Темы с ограниченным доступом]
  [equ:Public=Публичные]
  [equ:Limited=Ограниченные]
|
  [equ:ttlPublic=Discussions publiques]
  [equ:ttlLimited=Discussions restreintes]
  [equ:Public=Publiques]
  [equ:Limited=Restreintes]
|
  [equ:ttlPublic=Öffentliche Themen]
  [equ:ttlLimited=Themen mit beschränktem Zugang]
  [equ:Public=Öffentliche]
  [equ:Limited=Beschränkt]
]


<!DOCTYPE html>
<html lang="[case:[special:lang]|en|bg|ru|fr|de]">
<head>
  <meta charset="utf-8">
  <title>[special:title]</title>
  [case:[special:limited]|<link href="!feed" type="application/atom+xml" rel="alternate" title="Atom feed">|]
  <meta name="description" content="[special:description]">
  <meta name="keywords" content="[special:keywords]">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
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

  <script>
    var ActiveSkin = '[special:skin]';
    [raw:realtime.js]
  </script>

</head>

<body>
  <div class="header">
    [special:header]
    <div class="spacer"></div>
    <div style="text-align: left">
      <form method="POST" action="/!skincookie">
        <select class="skin" name="skin" onchange="this.form.submit()">
          <option value="0">(Default)</option>
          [special:skins=[special:skincookie]]
        </select>
        <noscript style="display: inline; margin-left: 0px">
          <input type="submit" value="Go">
        </noscript>
      </form>
    </div>
    <div>
      [case:[special:userid]
        |<a href="/!login/">[case:[special:lang]|Login|Вход|Вход|Connexion|Anmelden]</a><br>
          [case:[special:canregister]||<a href="/!register/">[case:[special:lang]|Register|Регистрация|Регистрация|Inscription|Registrieren]</a>]
        |<form method="POST" action="/!logout"><input class="logout" type="submit" name="logout"
         value="[case:[special:lang]|Logout|Изход|Выйти|Se déconnecter|Abmelden] ([enc:[special:username]])"></form>
         <a href="/!userinfo/[url:[special:username]]">[case:[special:lang]|User profile|Профил|Профиль|Profil|Profil]</a>
      ]
    </div>
  </div>

  <form class="tags" id="search_form" action="[case:[special:cmdtype]||/|../]!search/" method="get" >
    <input class="search_line" type="search" name="s" placeholder="[case:[special:lang]|text search|търсене на текст|поиск текста|recherche de texte|Textsuche]" value="[special:search]">
    <input class="search_line" type="search" name="u" placeholder="[case:[special:lang]|user search|потребител|пользователь|recherche d'utilisateur|Benutzersuche]" value="[special:usearch]">
    <a class="icon_btn"><input class="img_input" type="image" width="32" height="32" src="[special:skin]/_images/search.svg" alt="&nbsp;Search&nbsp;" title="[case:[special:lang]|Search|Търсене|Поиск|Rechercher|Suchen]"></a>
  </form>

  <div class="alone">
  [case:[special:userid]||
    <a class="[case:[special:limited]|ui|ui3] left" href="/[case:[special:dir]||[special:dir]/]" title="[const:ttlPublic]">[const:Public][special:unread]</a>
    <a class="[case:[special:limited]|ui3|ui] left" href="/(o)/[case:[special:dir]||[special:dir]/]" title="[const:ttlLimited]">[const:Limited][special:unreadLAT]</a>
  ]

  <a class="jsonly ui3 left" onclick="switchNotificationCookie();" title="[const:ttlNotifications]">
    <svg width="16" height="16" version="1.1" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
     <circle cx="10" cy="17" r="3" />
     <path d="m20 17h-20c0-1.37 1.7-1.08 2-3 .663-4.28 1.1-11 8-11 7.12 0 7.41 6.61 8 11 .239 1.78 2 1.73 2 3z"/>
     <path d="m10 0a3 3 0 00-3 3 3 3 0 003 3 3 3 0 003-3 3 3 0 00-3-3zm0 2a1 1 0 011 1 1 1 0 01-1 1 1 1 0 01-1-1 1 1 0 011-1z"/>
     <line id="notiStroked" x1="0" y1="20" x2="20" y2="0" style="stroke-width:4;stroke:hsl(0, 70%, 50%);visibility:hidden;"/>
    </svg>
  </a>

  </div>



  <div class="tags">
    <a href="/[case:[special:limited]||(o)/]"><img class="tagicon" src="[special:skin]/_images/alltags[case:[special:variant]|||_gray].svg" alt="/"
    title="[case:[special:lang]|Show all threads|Покажи всички теми|Показать все темы|Montrer tous les sujets|Alle Themen zeigen]"></a>
    [special:alltags]
  </div>
