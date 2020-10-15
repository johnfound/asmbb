[css:common.css]
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
  [equ:ttlTags=Tags]
  [equ:btnCats=Categories]
  [equ:btnSettings=Settings]
  [equ:btnConsole=SQL console]
  [equ:btnChat=Chat]
  [equ:btnList=Threads]
  [equ:rssfeed=Subscribe]
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
  [equ:ttlTags=Тагове]
  [equ:btnCats=Категории]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзола]
  [equ:btnChat=Чат]
  [equ:btnList=Теми]
  [equ:rssfeed=Абонирай се]
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
  [equ:ttlTags=Ярлыки]
  [equ:btnCats=Категории]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзоль]
  [equ:btnChat=Чат]
  [equ:btnList=Темы]
  [equ:rssfeed=Подпишитесь]
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
  [equ:ttlTags=Mots-clés]
  [equ:btnCats=Catégories]
  [equ:btnSettings=Paramètres]
  [equ:btnConsole=Console SQL]
  [equ:btnChat=Тchat]
  [equ:btnList=Liste des sujets]
  [equ:rssfeed=Suivre]
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
  [equ:ttlTags=Tags]
  [equ:btnCats=Kategorien]
  [equ:btnSettings=Einstellungen]
  [equ:btnConsole=SQL-Konsole]
  [equ:btnChat=Chat]
  [equ:btnList=Themen]
  [equ:rssfeed=Abonnieren]
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

  [special:allstyles]

  <noscript>
    <style> .jsonly { display: none !important } </style>
  </noscript>

  <script>
    var ActiveSkin = '[special:skin]';
    [raw:realtime.js]
  </script>

</head>

<body [case:[special:limited]||class="limited-access"]>

<svg id="background" xmlns='http://www.w3.org/2000/svg' width='100%'>
  <defs>
    <pattern patternUnits='userSpaceOnUse' id='tri' width='487' height='405' x='0' y='0' viewBox='0 0 1080 900'>
      <g fill-opacity='0.17'>
        <polygon fill='#444' points='90 150 0 300 180 300'/>
        <polygon points='90 150 180 0 0 0'/>
        <polygon fill='#AAA' points='270 150 360 0 180 0'/>
        <polygon fill='#DDD' points='450 150 360 300 540 300'/>
        <polygon fill='#999' points='450 150 540 0 360 0'/>
        <polygon points='630 150 540 300 720 300'/>
        <polygon fill='#DDD' points='630 150 720 0 540 0'/>
        <polygon fill='#444' points='810 150 720 300 900 300'/>
        <polygon fill='#FFF' points='810 150 900 0 720 0'/>
        <polygon fill='#DDD' points='990 150 900 300 1080 300'/>
        <polygon fill='#444' points='990 150 1080 0 900 0'/>
        <polygon fill='#DDD' points='90 450 0 600 180 600'/>
        <polygon points='90 450 180 300 0 300'/>
        <polygon fill='#666' points='270 450 180 600 360 600'/>
        <polygon fill='#AAA' points='270 450 360 300 180 300'/>
        <polygon fill='#DDD' points='450 450 360 600 540 600'/>
        <polygon fill='#999' points='450 450 540 300 360 300'/>
        <polygon fill='#999' points='630 450 540 600 720 600'/>
        <polygon fill='#FFF' points='630 450 720 300 540 300'/>
        <polygon points='810 450 720 600 900 600'/>
        <polygon fill='#DDD' points='810 450 900 300 720 300'/>
        <polygon fill='#AAA' points='990 450 900 600 1080 600'/>
        <polygon fill='#444' points='990 450 1080 300 900 300'/>
        <polygon fill='#222' points='90 750 0 900 180 900'/>
        <polygon points='270 750 180 900 360 900'/>
        <polygon fill='#DDD' points='270 750 360 600 180 600'/>
        <polygon points='450 750 540 600 360 600'/>
        <polygon points='630 750 540 900 720 900'/>
        <polygon fill='#444' points='630 750 720 600 540 600'/>
        <polygon fill='#AAA' points='810 750 720 900 900 900'/>
        <polygon fill='#666' points='810 750 900 600 720 600'/>
        <polygon fill='#999' points='990 750 900 900 1080 900'/>
        <polygon fill='#999' points='180 0 90 150 270 150'/>
        <polygon fill='#444' points='360 0 270 150 450 150'/>
        <polygon fill='#FFF' points='540 0 450 150 630 150'/>
        <polygon points='900 0 810 150 990 150'/>
        <polygon fill='#222' points='0 300 -90 450 90 450'/>
        <polygon fill='#FFF' points='0 300 90 150 -90 150'/>
        <polygon fill='#FFF' points='180 300 90 450 270 450'/>
        <polygon fill='#666' points='180 300 270 150 90 150'/>
        <polygon fill='#222' points='360 300 270 450 450 450'/>
        <polygon fill='#FFF' points='360 300 450 150 270 150'/>
        <polygon fill='#444' points='540 300 450 450 630 450'/>
        <polygon fill='#222' points='540 300 630 150 450 150'/>
        <polygon fill='#AAA' points='720 300 630 450 810 450'/>
        <polygon fill='#666' points='720 300 810 150 630 150'/>
        <polygon fill='#FFF' points='900 300 810 450 990 450'/>
        <polygon fill='#999' points='900 300 990 150 810 150'/>
        <polygon points='0 600 -90 750 90 750'/>
        <polygon fill='#666' points='0 600 90 450 -90 450'/>
        <polygon fill='#AAA' points='180 600 90 750 270 750'/>
        <polygon fill='#444' points='180 600 270 450 90 450'/>
        <polygon fill='#444' points='360 600 270 750 450 750'/>
        <polygon fill='#999' points='360 600 450 450 270 450'/>
        <polygon fill='#666' points='540 600 630 450 450 450'/>
        <polygon fill='#222' points='720 600 630 750 810 750'/>
        <polygon fill='#FFF' points='900 600 810 750 990 750'/>
        <polygon fill='#222' points='900 600 990 450 810 450'/>
        <polygon fill='#DDD' points='0 900 90 750 -90 750'/>
        <polygon fill='#444' points='180 900 270 750 90 750'/>
        <polygon fill='#FFF' points='360 900 450 750 270 750'/>
        <polygon fill='#AAA' points='540 900 630 750 450 750'/>
        <polygon fill='#FFF' points='720 900 810 750 630 750'/>
        <polygon fill='#222' points='900 900 990 750 810 750'/>
        <polygon fill='#222' points='1080 300 990 450 1170 450'/>
        <polygon fill='#FFF' points='1080 300 1170 150 990 150'/>
        <polygon points='1080 600 990 750 1170 750'/>
        <polygon fill='#666' points='1080 600 1170 450 990 450'/>
        <polygon fill='#DDD' points='1080 900 1170 750 990 750'/>
      </g>
    </pattern>
  </defs>
  <rect x='0' y='0' fill='url(#tri)' width='100%' height='100%'/>
</svg>


<div class="header noselect">
  [special:header]

  <div class="spacer"></div>

  <form method="POST" action="/!skincookie">
    <select class="skin" name="skin" onchange="this.form.submit()">
      <option value="0">Skin: (Default)</option>
      [special:skins=[special:skincookie]]
    </select>
    <noscript><input type="submit" class="btn" value="Go"></noscript>
  </form>

    <label for="searchDown" class="btn"><svg width="16" height="16" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <path d="m8 9h16l-8 16z" fill="#fff"/>
      </svg>[const:ttlSearchBtn]
    </label>

  [case:[special:userid]
      |<a class="btn" href="/!login/">[const:Login]</a> [case:[special:canregister]||<a class="btn" href="/!register/">[const:Register]</a>]
      |<form method="POST" action="/!logout"><input class="btn" type="submit" name="logout" value="[const:Logout] ([enc:[special:username]])"></form>
      <a class="btn" href="/!userinfo/[url:[special:username]]">[const:Profile]</a>
  ]

  <a class="jsonly btn round" onclick="switchNotificationCookie();" title="[const:ttlNotifications]">
    <svg width="16" height="16" version="1.1" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
     <circle cx="10" cy="17" r="3" />
     <path d="m20 17h-20c0-1.37 1.7-1.08 2-3 .663-4.28 1.1-11 8-11 7.12 0 7.41 6.61 8 11 .239 1.78 2 1.73 2 3z"/>
     <path d="m10 0a3 3 0 00-3 3 3 3 0 003 3 3 3 0 003-3 3 3 0 00-3-3zm0 2a1 1 0 011 1 1 1 0 01-1 1 1 1 0 01-1-1 1 1 0 011-1z"/>
     <line id="notiStroked" x1="0" y1="20" x2="20" y2="0" style="stroke-width:4;stroke:hsl(0, 70%, 50%);visibility:hidden;"/>
    </svg>
  </a>

  [case:[special:limited]|<a class="btn round" href="!feed" title="[const:rssfeed]"><svg height="16" width="16" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
      <path d="m8.8 27.6c0 2.43-1.97 4.4-4.4 4.4s-4.4-1.97-4.4-4.4 1.97-4.4 4.4-4.4 4.4 1.97 4.4 4.4z"/>
      <path d="m21.2 32h-6.2c0-8.2-6.8-15-15-15v-6.2c11.8 0 21.2 9.4 21.2 21.2z"/>
      <path d="m25.6 32c0-14.2-11.4-25.6-25.6-25.6v-6.4c17.6 0 32 14.4 32 32z"/>
  </svg></a>|]

  <input type="checkbox" class="dropdown" id="searchDown">
  <form id="search_form" action="[case:[special:cmdtype]||/|../]!search/" method="get" >
    <input class="search_line" type="search" name="s" placeholder="[const:ttlSearchTxt]" value="[special:search]">
    <input class="search_line" type="search" name="u" placeholder="[const:ttlSearchUsr]" value="[special:usearch]">
    <label class="btn round">
      <input type="submit">
      <svg version="1.1" width="20" height="20" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <path d="m30.2 26.9-6.45-6.48c-.0347-.0348-.0753-.0588-.111-.0912 1.32-1.92
                 2.04-4.32 2.04-6.84 0-6.96-5.51-12.5-12.3-12.5-6.81 0-12.3 5.52-12.3
                 12.4 0 6.84 5.51 12.4 12.3 12.4 2.51 0 4.79-.744
                 6.81-2.04.0323.036.0563.0768.091.112l6.45 6.48c.981.984 2.51.984 3.59 0
                 .981-.984.981-2.52 0-3.6zm-16.8-5.4c-4.43 0-8.01-3.6-8.01-8.04 0-4.44
                 3.59-8.04 8.01-8.04 4.43 0 8.01 3.6 8.01 8.04 0 4.44-3.59 8.04-8.01 8.04z"/>
      </svg>
    </label>
  </form>
</div>

<div class="ui" id="global_toolbar">

  [case:[special:userid]||
    <a class="btn" href="/[case:[special:dir]||[special:dir]/]" title="[const:ttlPublic]">[const:Public][special:unread]</a>
    <a class="btn" href="/(o)/[case:[special:dir]||[special:dir]/]" title="[const:ttlLimited]">[const:Limited][special:unreadLAT]</a>
  ]

  <a class="btn" href="/[special:dir][case:[special:dir]||/]">[const:btnList]</a>

  <label class="btn" for="tagsCollapse">
    <svg width="16" height="16" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
      <path d="m8 9h16l-8 16z" fill="#fff"/>
    </svg>[const:ttlTags]: <strong>[case:[special:dir]|[const:ttlAllThreads]|#[special:dir]]</strong>
  </label>

  <a class="btn" href="/!categories">[const:btnCats]</a>

  [case:[special:canchat] | |<a class="btn" href="/!chat">[const:btnChat]</a>]

  <div class="spacer"></div>

  [case:[special:isadmin] | |
    <a class="btn" href="/!settings">[const:btnSettings]</a>
    <a class="btn" href="/!sqlite">[const:btnConsole]</a>
    <a class="btn" href="/!debuginfo">Debug info</a>]

</div>

  <input type="checkbox" class="dropdown" id="tagsCollapse">
  <div id="taglinks">
    <a class="taglink [case:[special:variant]|current_tag|current_tag|] alltags"
    href="/[case:[special:limited]||(o)/]"><svg class="alltags" version="1.1" width="24" height="24" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
      <path d="m15 .00195c-1.24 0-2.97.717-3.85 1.59l-10.5 10.5c-.877.877-.877
               2.31 0 3.19l8.09 8.08c.877.877 2.31.877 3.19 0l10.5-10.5c.877-.877
               1.59-2.61 1.59-3.85v-6.76c-4.5e-5-1.24-1.02-2.26-2.26-2.26l-.0019-.00195zm3.77
               3.01c1.24 0 2.25 1.01 2.25 2.25 0 1.24-1.01 2.25-2.25 2.25s-2.25-1.01-2.25-2.25c0-1.24
               1.01-2.25 2.25-2.25zm6.25.999v6.02c0 1.24-.718 2.97-1.59 3.85l-10.5
               10.5c-.877.877-2.31.877-3.19 0l3 3c.877.877 2.31.877 3.19 0l10.5-10.5c.877-.877
               1.59-2.61 1.59-3.85v-6.76c-4.5e-5-1.24-1.02-2.26-2.26-2.26l-.0019-.00195zm4.01
               4v6.02c0 1.24-.718 2.97-1.59 3.85l-10.5 10.5c-.877.877-2.31.877-3.19 0l3 3c.877.877
               2.31.877 3.19 0l10.5-10.5c.877-.877 1.59-2.61
               1.59-3.85v-6.76c-4.5e-5-1.24-1.02-2.26-2.26-2.26l-.0019-.00195z"
      />
    </svg>[const:ttlAllThreads]</a>
    [special:alltags]
  </div>
