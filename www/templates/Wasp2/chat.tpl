[css:chat.css]

<script>
  [raw:chat.js]
</script>


[case:[special:lang]|
  [equ:btnForum=Forum]
  [equ:phNick=Nickname]
  [equ:phText=Type here. Ctrl+Enter sends the message.]
|
  [equ:btnForum=Форум]
  [equ:phNick=Ник]
  [equ:phText=Пиши тук.  Ctrl+Enter изпраща съобщението.]
|
  [equ:btnForum=Форум]
  [equ:phNick=Ник]
  [equ:phText=Напиши здесь. Ctrl+Enter отправляет сообщение.]
|
  [equ:btnForum=Forum]
  [equ:phNick=Nom d'utilisateur]
  [equ:phText=Taper ici. Ctrl+Enter envoie le message.]
|
  [equ:btnForum=Forum]
  [equ:phNick=Nom d'utilisateur]
  [equ:phText=Tippen Sie hier. Mit Strg+Enter wird die Nachricht gesendet.]
]

  <div class="chat">
    <div class="btn-bar">
      <a class="btn" href="/">[const:btnForum]</a>
      <div class="spacer"></div>
      <span>Nickname: </span><input type="text" placeholder="[const:phNick]" id="chat_user" onkeypress="KeyPress(event, UserRename)" onChange="UserRename()">
    </div>
    <div class="chatflex">
      <div id="chatlog"></div>
      <div id="syslog"></div>
    </div>
    <div id="chat_form">
      <textarea rows="4" placeholder="[const:phText]" id="chat_message" autofocus onkeypress="KeyPress(event, SendMessage)"></textarea>
      <a class="btn img-btn" onclick="SendMessage()">
        <svg version="1.1" width="16" height="16" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
         <path d="m3 4 29 12-29 12c5-12 5-12 0-24z"/>
        </svg>
      </a>
    </div>
  </div>

