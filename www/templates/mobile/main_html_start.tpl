<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>[special:title]</title>
  <meta name="description" content="[special:description]">
  <meta name="keywords" content="[special:keywords]">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <link rel="stylesheet" href="/[special:skin]common.css" type="text/css">
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
</head>

<body>
  <div class="header">
    <h1>AsmBB&nbsp;demo</h1>
    <div class="login_interface">
      [case:[special:userid]|<a href="/!login/">Login</a><br><a href="/!register/">Register</a>|
      <a href="/!logout">Logout ( [special:username] )</a><br><a href="/!userinfo/[special:username]">User profile</a>]
    </div>
  </div>

  <form class="tags" id="search_form" action="[case:[special:dir]|/|[case:[special:search]||../]]!search/" method="get" >
    <input class="search_line" type="search" name="s" placeholder="search" value="[special:search]">
    <input class="icon_btn search_icon"  type="submit" value="">
  </form>

  <label class="drop_down">Tags ▼ [case:[special:dir]||([special:dir])]
    <input type="checkbox" class="drop_down">
    <div class="tags"><a class="tagicon [case:[special:dir]|current|not_current]" title="Show all threads" href="/"></a>[special:alltags]</div>
  </label>
