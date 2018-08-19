[css:common.css]
<!DOCTYPE html>
<html lang="en">
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
</head>

<body>
<div id="ruler" title="Double click for reset."></div>
<div id="body">
<!-----
 ▄▄▄            ▄▄▄  ▄▄▄  Power
█  █ ▄▄▄▄ ▄▄▄▄  █  █ █  █
█▄▄█ █▄▄▄ █ █ █ █▀▀▄ █▀▀▄
█  █ ▄▄▄█ █ █ █ █▄▄▀ █▄▄▀
    ___                   ____  ____
   /   |  _________ ___  / __ )/ __ ) Power
  / /| | / ___/ __ `__ \/ __  / __  |
 / ___ |(__  ) / / / / / /_/ / /_/ /
/_/  |_/____/_/ /_/ /_/_____/_____/
    ____                 ____  ____
   / __ \_________ ___  / __ \/ __ \ Power
  / /_/ / ___/ __ `__ \/ __  / __  /
 / __  /__  / / / / / / /_/ / /_/ /
/_/ /_/____/_/ /_/ /_/_____/_____/
 ▄▄▄             ▄▄▄▄  ▄▄▄▄ Power
█   █ ▄▄▄▄ ▄▄▄▄▄ █   █ █   █
█▄▄▄█ █▄▄▄ █ █ █ █▀▀▀▄ █▀▀▀▄
█   █ ▄▄▄█ █ █ █ █▄▄▄▀ █▄▄▄▀
------->
  <div class="header">
    <div id="userlinks">
      [case:[special:userid]|<a href="/!login/">Login</a><br><a href="/!register/">Register</a>|
      <a href="/!logout">Logout ( [special:username] )</a><br><a href="/!userinfo/[special:username]">User profile</a>]
    </div>
    <form id="skinform" method="POST" action="/!skincookie">
      <select class="skin" name="skin" onchange="this.form.submit()">
        <option value="0">(Default)</option>
        [special:skins=[special:skincookie]]
      </select>
      <noscript style="display: inline; margin-left: 0px">
        <input type="submit" value="Go">
      </noscript>
    </form>
<div id="header">
 ▄▄             ▄▄▄  ▄▄▄ Power
█  █ ▄▄▄▄ ▄▄▄▄▄ █  █ █  █
█▄▄█ █▄▄▄ █ █ █ █▀▀▄ █▀▀▄
█  █ ▄▄▄█ █ █ █ █▄▄▀ █▄▄▀
</div>
    <div class="clear"></div>
  </div>

  <form id="search_form" action="[case:[special:cmdtype]||/|../]!search/" method="get" >
    <table><tr>
    <td class="l"><input size="36" class="search" type="search" name="s" placeholder="text search" value="[special:search]"></td>
    <td class="l"><input size="36" class="search" type="search" name="u" placeholder="user search" value="[special:usearch]"></td>
    <td class="r"><input class="submit" type="submit" value="Search"></td>
    </tr>
    </table>
  </form>

  <div id="tags">
    <a class="taglink [case:[special:dir]|current_tag|]" href="/">/</a>
    [special:alltags]
  </div>

  <div id="measure" style="width: 1000ch; height: 1187.5rem; border: none; margin: 0; padding:0; display: block; position:fixed; z-index:-9999"></div>

  <script>
    var measure = document.getElementById("measure");
    var cx = measure.offsetWidth/1000;
    var cy = measure.offsetHeight/1000;

    function getCookie(cname) {
        var name = cname + "=";
        var decodedCookie = decodeURIComponent(document.cookie);
        var ca = decodedCookie.split(';');
        for(var i = 0; i <ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
            }
        }
        return "";
    }

    function RefreshRuler(scrW, w, ml) {
      scrW = Number(scrW);
      w = Number(w);
      ml = Number(ml);

      var ruler = document.getElementById('ruler');
      var rulertxt = "";
      for (var i = 0; i < scrW; i++) {
        if (i == ml) rulertxt += '<span class="dragpos" onmousedown="DragPosStart()" title="Drag to move">';
        if (i == (w+ml-1)) rulertxt += '<span class="dragsz" onmousedown="DragSizeStart()" title="Drag to resize">';

        if ((i-ml) % 10) rulertxt += "'"
        else rulertxt += "|";

        if (i == (w+ml-1)) rulertxt += '</span>';
        if (i==ml) rulertxt += '</span>';
      }
      ruler.innerHTML = rulertxt;
    }


    function DragSizeStart(e) {
      e = e || window.event;
      document.onmouseup = DragEnd;
      document.onmousemove = DragSizeMove;
      e.preventDefault();
    }

    function DragSizeMove(e) {
      e = e || window.event;
      var bd = document.getElementById('body');
      var ml = Math.floor(bd.offsetLeft/cx);
      var newW = Math.floor(e.clientX/cx) - ml;
      var scrW = Math.floor(window.innerWidth/cx);
      var cw = Math.floor(bd.offsetWidth/cx);

      if (newW < 40) newW = 40;
      if (newW > scrW - 4) newW = scrW - 4;

      bd.style.width = newW + 'ch';
      document.cookie = "contentWidth="+newW+"; path=/;";
      RefreshRuler(scrW, newW, ml);
      e.preventDefault();
      return false;
    }

    function DragPosStart(e) {
      e = e || window.event;
      document.onmouseup = DragEnd;
      document.onmousemove = DragPosMove;
      e.preventDefault();
    }

    function DragEnd(e) {
      document.onmouseup = null;
      document.onmousemove = null;
      e.preventDefault();
    }

    function DragPosMove(e) {
      e = e || window.event;
      var bd = document.getElementById('body');
      var newx = Math.floor(e.clientX/cx);
      var scrW = Math.floor(window.innerWidth/cx);
      var cw = Math.floor(bd.offsetWidth/cx);

      if (newx < 0) newx = 0;
      if (newx > scrW - cw - 1) newx = scrW - cw - 1;

      bd.style.marginLeft = newx + 'ch';
      document.cookie = "marginLeft="+newx+"; path=/;";
      RefreshRuler(scrW, cw, newx);
      e.preventDefault();
    }

    function SetContentPos() {
      var bd = document.getElementById('body');
      var scrW = Math.floor(window.innerWidth/cx);
      var ml = Number(getCookie("marginLeft"));
      var cw = Number(getCookie("contentWidth"));

      if ( ml == 0 ) ml = 4;
      if ( cw == 0) cw = scrW - 2*ml - 1 ;

      if (ml < 0) ml = 0;
      if (cw < 40) cw = 40;

      bd.style.marginLeft = ml + 'ch';
      bd.style.width = cw + 'ch';
      RefreshRuler(scrW, cw, ml);
    }

    function ResetMargins(e) {
      e = e || window.event;
      document.cookie = "marginLeft=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT";
      document.cookie = "contentWidth=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT";
      SetContentPos();
      e.preventDefault();
    }

    function MouseDownRuler(e) {
      e = e || window.event;
      e.preventDefault();
    }

    document.getElementById('ruler').onmousedown = MouseDownRuler;
    document.getElementById('ruler').ondblclick = ResetMargins;
    window.onresize = SetContentPos;
    SetContentPos();

  </script>
