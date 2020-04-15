[css:navigation.css]
[css:chat.css]

<script>
  [raw:chat.js]
</script>


[case:[special:lang]|
  [equ:btnForum=Forum]
  [equ:phNick=Nickname]
  [equ:phText=Type here]
|
  [equ:btnForum=Форум]
  [equ:phNick=Ник]
  [equ:phText=Пиши тук]
|
  [equ:btnForum=Форум]
  [equ:phNick=Ник]
  [equ:phText=Напиши здесь]
|
  [equ:btnForum=Forum]
  [equ:phNick=Nom d'utilisateur]
  [equ:phText=Taper ici]
]

  <div class="chat">
    <div class="ui">
      <a class="ui" href="/">[const:btnForum]</a>
    </div>
    <div class="chatflex">
      <div id="chatlog"></div>
      <div id="syslog"></div>
    </div>
    <div id="chat_form">
      <input class="chat_input" type="edit" placeholder="[const:phNick]" id="chat_user" onkeypress="KeyPress(event, UserRename)" onChange="UserRename()">
      <input class="chat_input" type="edit" placeholder="[const:phText]" id="chat_message" autofocus onkeypress="KeyPress(event, SendMessage)">
      <a class="icon_btn" onclick="SendMessage()"><img class="img_btn" src="[special:skin]/_images/edit_white.svg" alt="&nbsp;Post&nbsp;"></a>
    </div>
  </div>

