[css:common.css]
[css:toaster.css]

[case:[special:lang]|
  [equ:ttlPublic=Public threads]
  [equ:ttlLimited=Limited access threads]
  [equ:btnPublic=Public]
  [equ:btnLimited=Limited]
  [equ:btnRegister=Register]
  [equ:btnLogin=Login]
  [equ:btnLogout=Logout]
  [equ:btnProfile=Profile]
  [equ:ttlSearchTxt=text search]
  [equ:ttlSearchUsr=user search]
  [equ:ttlSearchBtn=Search]
  [equ:ttlAllThreads=All tags]
  [equ:ttlTags=Tags]
  [equ:ttlNotifications=Off/On the real time notifications]
  [equ:btnCats=Categories]
  [equ:btnSettings=Settings]
  [equ:btnConsole=SQL console]
  [equ:btnChat=Chat]
  [equ:btnList=Threads]
  [equ:rssfeed=Subscribe]
|
  [equ:ttlPublic=Публични теми]
  [equ:ttlLimited=Теми с ограничен достъп]
  [equ:btnPublic=Публични]
  [equ:btnLimited=Ограничени]
  [equ:btnRegister=Регистрация]
  [equ:btnLogin=Вход]
  [equ:btnLogout=Изход]
  [equ:btnProfile=Профил]
  [equ:ttlSearchTxt=търсене на текст]
  [equ:ttlSearchUsr=потребител]
  [equ:ttlSearchBtn=Търсене]
  [equ:ttlAllThreads=Всички теми]
  [equ:ttlTags=Тагове]
  [equ:ttlNotifications=Изкл/Вкл на нотификациите в реално време]
  [equ:btnCats=Категории]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзола]
  [equ:btnChat=Чат]
  [equ:btnList=Теми]
  [equ:rssfeed=Абонирай се]
|
  [equ:ttlPublic=Публичные темы]
  [equ:ttlLimited=Темы с ограниченным доступом]
  [equ:btnPublic=Публичные]
  [equ:btnLimited=Ограниченные]
  [equ:btnRegister=Регистрация]
  [equ:btnLogin=Вход]
  [equ:btnLogout=Выйти]
  [equ:btnProfile=Профиль]
  [equ:ttlSearchTxt=поиск текста]
  [equ:ttlSearchUsr=пользователь]
  [equ:ttlSearchBtn=Поиск]
  [equ:ttlAllThreads=Все темы]
  [equ:ttlTags=Ярлыки]
  [equ:ttlNotifications=Выкл/Вкл нотификации в реальном времени]
  [equ:btnCats=Категории]
  [equ:btnSettings=Настройки]
  [equ:btnConsole=SQL конзоль]
  [equ:btnChat=Чат]
  [equ:btnList=Темы]
  [equ:rssfeed=Подпишитесь]
|
  [equ:ttlPublic=Discussions publiques]
  [equ:ttlLimited=Discussions restreintes]
  [equ:btnPublic=Publiques]
  [equ:btnLimited=Restreintes]
  [equ:btnRegister=Inscription]
  [equ:btnLogin=Connexion]
  [equ:btnLogout=Se déconnecter]
  [equ:btnProfile=Profil]
  [equ:ttlSearchTxt=recherche de texte]
  [equ:ttlSearchUsr=recherche d'utilisateur]
  [equ:ttlSearchBtn=Rechercher]
  [equ:ttlAllThreads=Montrer tous les sujets]
  [equ:ttlTags=Mots-clés]
  [equ:ttlNotifications=Off/On the real time notifications]
  [equ:btnCats=Catégories]
  [equ:btnSettings=Paramètres]
  [equ:btnConsole=Console SQL]
  [equ:btnChat=Тchat]
  [equ:btnList=Liste des sujets]
  [equ:rssfeed=Suivre]
|
  [equ:ttlPublic=Öffentliche Themen]
  [equ:ttlLimited=Themen mit beschränktem Zugang]
  [equ:btnPublic=Öffentliche]
  [equ:btnLimited=Beschränkt]
  [equ:btnRegister=Registrieren]
  [equ:btnLogin=Anmelden]
  [equ:btnLogout=Abmelden]
  [equ:btnProfile=Profil]
  [equ:ttlSearchTxt=Textsuche]
  [equ:ttlSearchUsr=Benutzersuche]
  [equ:ttlSearchBtn=Suchen]
  [equ:ttlAllThreads=Alle Themen zeigen]
  [equ:ttlTags=Tags]
  [equ:ttlNotifications=Off/On the real time notifications]
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
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">

  <noscript>
    <style> .jsonly { display: none !important } </style>
  </noscript>

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

  <script>
    var ActiveSkin = '[special:skin]';
    [raw:realtime.js]
  </script>

<body>
 [case:[special:limited]||<b>Limited</b>]

 <div id="header">[special:header]</div>
 <div class="layout">

   <table class="toolbar"><tr>

   [case:[special:userid]||
   <td><a href="/[case:[special:dir]||[special:dir]/]" title="[const:ttlPublic]" accesskey="p">[const:btnPublic][special:unread]</a>
   <td><a href="/(o)/[case:[special:dir]||[special:dir]/]" title="[const:ttlLimited]" accesskey="l">[const:btnLimited][special:unreadLAT]</a>]
   <td class="spacer">

   <td>
     <form method="post" action="/!skincookie">
       <select name="skin" onchange="this.form.submit()">
         <option value="0">(Default)</option>
         [special:skins=[special:skincookie]]
       </select>
       <noscript>
         <input type="submit" value="Go">
       </noscript>
     </form>


 [case:[special:userid]|
   <td><a class="btn" href="/!login">[const:btnLogin]</a>
     [case:[special:canregister]||
       <td><a class="btn" href="/!register">[const:btnRegister]</a>
     ]
 |
   <td><a href="/!userinfo/[url:[special:username]]" title="[enc:[special:username]]">[const:btnProfile]</a>

   <td><form id="logoutform" method="post" action="/!logout"><input for="logoutform" type="submit" name="logout" title="[enc:[special:username]]" value="[const:btnLogout]"></form>
 ]
 </table>
 </div>

 <div class="layout">
   <form action="[case:[special:cmdtype]||/|../]!search/" method="get" >
     <table class="toolbar"><tr>
       <td><input type="search" name="s" placeholder="[case:[special:lang]|text search|търсене на текст|поиск текста|recherche de texte|Textsuche]" value="[special:search]" size="40">
       <td><input type="search" name="u" placeholder="[case:[special:lang]|user search|потребител|пользователь|recherche d'utilisateur|Benutzersuche]" value="[special:usearch]" size="20">
       <td><button type="submit" title="[case:[special:lang]|Search|Търсене|Поиск|Rechercher|Suchen]"><img alt=">" width="24" height="24" src="[special:skin]/_images/search.png"></button>
     </table>
   </form>
 </div>

<div class="layout">
  <div class="linkbar">
    <table class="toolbar"><tr>
      <td><a class="btn" href="/!categories">[const:btnCats]</a>

      [case:[special:canchat]||<td class="jsonly"><a class="btn" href="/!chat" accesskey="c">[const:btnChat]</a>]

      <td class="jsonly"><a class="btn img-btn" onclick="switchNotificationCookie();" title="[const:ttlNotifications]"><img width="16" height="16" src="[special:skin]/_images/bell.png"></a>

      <td class="spacer">

      [case:[special:isadmin] | |
        <td><a class="btn" href="/!settings" accesskey="s">[const:btnSettings]</a>
        <td><a class="btn" href="/!sqlite" accesskey="k">[const:btnConsole]</a>
        <td><a class="btn" href="/!debuginfo">Debug info</a>
      ]
      [case:[special:limited]|<td><a class="btn img-btn" href="!feed" title="[const:rssfeed]"><img width="16" height="16" src="[special:skin]/_images/rss.png"></a>|]
    </table>
  </div>

  <table id="layout-table"><tr>
    <td id="taglist" lang="en">
      <a href="/[case:[special:limited]||(o)/]" title="[const:ttlAllThreads]"><img width="24" height="24" src="[special:skin]/_images/all-tags.png"></a>
      [special:alltags]
      <td id="content">
