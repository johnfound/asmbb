[css:common.css]
<!DOCTYPE html>
<html lang="[case:[special:lang]|en|bg|ru|fr|de]">
<head>
  <meta charset="utf-8">
  <title>[special:title]</title>
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

</head>

<body>
  <div class="header">
    <h1>[special:header]</h1>
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
      [case:[special:userid]|<a href="/!login/">[case:[special:lang]|Login|Вход|Вход|Connexion|Anmelden]</a><br>[case:[special:canregister]||<a href="/!register/">[case:[special:lang]|Register|Регистрация|Регистрация|Inscription|Registrieren]</a>]|
      <form method="POST" action="/!logout"><input class="logout" type="submit" name="logout" value="[case:[special:lang]|Logout|Изход|Выйти|De déconnecter|Abmelden] ([special:username])"></form>
      <a href="/!userinfo/[url:[special:username]]">[case:[special:lang]|User profile|Профил|Профиль|Profil|Profil]</a>]
    </div>
  </div>

  <form class="tags" id="search_form" action="[case:[special:cmdtype]||/|../]!search/" method="get" >
    <input class="search_line" type="search" name="s" placeholder="[case:[special:lang]|text search|търсене на текст|поиск текста|rechercher du texte|Textsuche]" value="[special:search]">
    <input class="search_line" type="search" name="u" placeholder="[case:[special:lang]|user search|потребител|потребитель|recherche d'utilisateur|Benutzersuche]" value="[special:usearch]">
    <a class="icon_btn"><input class="img_input" type="image" width="32" height="32" src="[special:skin]/_images/search.svg" alt="&nbsp;Search&nbsp;" title="[case:[special:lang]|Search|Търсене|Поиск|Rechercher|Suchen]"></a>
  </form>

  <div class="tags">
    <a href="/[case:[special:limited]||(o)/]"><img class="tagicon" src="[special:skin]/_images/alltags[case:[special:variant]|||_gray].svg" alt="/" title="[case:[special:lang]|Show all threads|Покажи всички теми|Показать все темы|Montrer tous les sujets|Alle Themen zeigen]">

</a>
    <a href="/[case:[special:limited]|(o)/|][case:[special:dir]||[special:dir]/]"><img class="tagicon" src="[special:skin]/_images/limited[case:[special:limited]|_gray|].svg" alt="/" title="[case:[special:lang]|Limited access threads|Теми с ограничен достъ

п|Темы с ограниченным доступом|Discussions d'accès limité|Themen mit beschränktem Zugang]"></a>
    [special:alltags]
  </div>
