[css:chat.css]

[case:[special:lang]|
  [equ:btnForum=Forum]
  [equ:phNick=Nickname]
  [equ:phText=Type here. Ctrl+Enter sends the message.]
  [equ:noscript=Chat requires JS because of its nature. Use the forum messages instead.]
|
  [equ:btnForum=Форум]
  [equ:phNick=Ник]
  [equ:phText=Пиши тук.  Ctrl+Enter изпраща съобщението.]
  [equ:noscript=Чата изисква JS поради самата си същност. Вместо него, използвайте форума.]
|
  [equ:btnForum=Форум]
  [equ:phNick=Ник]
  [equ:phText=Напиши здесь. Ctrl+Enter отправляет сообщение.]
  [equ:noscript=Чат требует JS из за своей сущности. Вместо него используйте сообщения форума.]
|
  [equ:btnForum=Forum]
  [equ:phNick=Nom d'utilisateur]
  [equ:phText=Taper ici. Ctrl+Enter envoie le message.]
  [equ:noscript=Le chat demande JS en raison de sa nature. Utilisez plutôt les messages du forum.]
|
  [equ:btnForum=Forum]
  [equ:phNick=Nom d'utilisateur]
  [equ:phText=Tippen Sie hier. Mit Strg+Enter wird die Nachricht gesendet.]
  [equ:noscript=Chat erfordert aufgrund seiner Beschaffenheit JS. Verwenden Sie stattdessen die Forumsbeiträge.]
]

<svg version="1.1" style="position:absolute; width:0px; height:0px;" xmlns="http://www.w3.org/2000/svg">
 <defs>
  <radialGradient id="a" cx="9.71" cy="8.79" r="7.5" gradientTransform="matrix(0 1.34 -2.22 -8.04e-7 34.5 10.1)" gradientUnits="userSpaceOnUse">
   <stop stop-color="#fffffa" offset="0"/>
   <stop stop-color="#ffd963" offset=".51"/>
   <stop stop-color="#f90" offset="1"/>
  </radialGradient>
  <linearGradient id="b" x1=".983" x2="14.2" y1="5.36" y2="5.98" gradientTransform="matrix(.133 1.82 -2.84 .0852 32 -4.72)" gradientUnits="userSpaceOnUse">
   <stop stop-color="#fff" offset="0"/>
   <stop stop-color="#fff" stop-opacity="0" offset="1"/>
  </linearGradient>
 </defs>
</svg>

<noscript>
  <h1 class="noscript">[const:noscript]</h1>
</noscript>

<div id="chat-window">

  <div class="btn-bar">
    <a class="btn" href="/">[const:btnForum]</a>
    <div class="spacer"></div>
    <span><svg width="18" height="18" style="vertical-align: middle" version="1.1" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <circle cx="16" cy="9" r="9"/>
        <path d="m16 16a16 16 0 00-16 16h32a16 16 0 00-16-16z"/>
      </svg><input type="text" placeholder="[const:phNick]" id="chat_user" onkeypress="KeyPress(event, UserRename)" onChange="UserRename()">
    </span>
  </div>

  <div class="chatflex">
    <div id="chatlog"></div>
    <div id="syslog"></div>
  </div>

  <div id="chat_form">
    <textarea rows="4" placeholder="[const:phText]" id="chat_message" autofocus onkeypress="KeyPress(event, SendMessage)"></textarea>
    <div class="v-btn-bar">
      <div class="dropdown emo-btn-bar">
        <input id="emo-drop-down" type="checkbox" onfocus="this.blur()">
        <label for="emo-drop-down" class="btn img-btn">
          <svg version="1.1" width="18" height="18" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
           <path d="m31.5 16a15.5 15.5 0 01-15.5 15.5 15.5 15.5 0 01-15.5-15.5 15.5 15.5 0 0115.5-15.5 15.5 15.5 0 0115.5 15.5z" style="fill:url(#a) !important;stroke-linecap:round;stroke-linejoin:round;stroke:#000"/>
           <path d="m17 20.2a11.4 8.84 2.04 01-12-8.49 11.4 8.84 2.04 0110.7-9.19 11.4 8.84 2.04 0112 8.49 11.4 8.84 2.04 01-10.7 9.19z" style="fill:url(#b) !important;stroke-width:1"/>
           <path d="m7 16c0 6.66 4.39 8.87 8.84 8.87 4.42 0 8.9-2.22 8.9-8.87" style="fill:none !important;stroke:#000;stroke-linecap:round;stroke-linejoin:round;stroke-width:1"/>
           <path d="m14 9.34a2.22 2.22 0 01-2.22 2.22 2.22 2.22 0 01-2.22-2.22 2.22 2.22 0 012.22-2.22 2.22 2.22 0 012.22 2.22z" style="fill:#000 !important;stroke:#000;stroke-linecap:round;stroke-linejoin:round;stroke-width:1px"/>
           <path d="m23 9.34a2.22 2.22 0 01-2.22 2.22 2.22 2.22 0 01-2.22-2.22 2.22 2.22 0 012.22-2.22 2.22 2.22 0 012.22 2.22z" style="fill:#000 !important;stroke:#000;stroke-linecap:round;stroke-linejoin:round;stroke-width:1px"/>
          </svg>
        </label>
        <div id="emolib">[raw:all-emoji.txt]</div>
      </div>
      <a class="btn img-btn" onclick="SendMessage()">
        <svg version="1.1" width="16" height="16" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
         <path d="m3 4 29 12-29 12c5-12 5-12 0-24z"/>
        </svg>
      </a>
    </div>
  </div>

</div>

<script src="[special:skin]/chat.js"></script>

