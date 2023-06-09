[css:navigation.css]
[css:chat.css]

<script>


function notify(Msg) {
  var notify;
  if (!("Notification" in window)) {
    alert("This browser does not support desktop notification");
  } else if (Notification.permission === "granted") {
           notify = new Notification(Msg);
         } else if (Notification.permission !== "denied") {
                  Notification.requestPermission( function (permission) {
                    if (permission === "granted") {
                      notify = new Notification(Msg);
                    }
                  });
                }
}


// essential code.

var edit_line;
var user_line;
var chat_log;
var sys_log;
var total_cnt = 0;
var title = document.title;
var do_notify = false;
var cdate;   // current date

WantEvents = 15;             // + the chat events.

function ScrollBottom(force) {
  if ( force || ! do_notify ) chat_log.scrollTop = chat_log.scrollHeight - chat_log.clientHeight;
}


// Entering the chat.

listSourceEvents.find(o=>o.event === "message").handler = OnFullChatMessage;

listSourceEvents.push(
  {
    event: 'open',
    handler:
      function() {
        edit_line.style.backgroundColor = null;
      }
  }
);

listSourceEvents.push(
  {
    event: 'error',
    handler:
      function(e) {
        edit_line.style.backgroundColor = "#ffa0a0";
        user_line.value = '';
        UserStatusChange(2);
        while (sys_log.firstChild) {
          sys_log.removeChild(sys_log.lastChild);
        }
      }
  }
);


listSourceEvents.push(
  {
    event: 'users_online',
    handler: OnUsersOnline
  }
);

listSourceEvents.push(
  {
    event: 'user_changed',
    handler: OnUserChanged
  }
);


window.addEventListener('load',
  function () {
    user_line = document.getElementById("chat_user");
    edit_line = document.getElementById("chat_message");
    chat_log  = document.getElementById("chatlog");
    sys_log   = document.getElementById("syslog");
  }
);


window.addEventListener('beforeunload',
  function (e) {
    if (source) disconnect();
    UserStatusChange(0);
    return null;
  }
);


//  Leaving the chat.


document.addEventListener("visibilitychange",
  function() {
    if ( ! document.hidden ) {
      total_cnt = 0;
      document.title = title;
      UserStatusChange(1);
      ScrollBottom(true);
    } else {
      if ( source ) UserStatusChange(2);
    }
  }
);



function KeyPress(e, proc) {
  if (e.keyCode == '13') {
    proc();
  }
}



function InsertNick(element) {
  edit_line.value = '@' + element.textContent + ': ' + edit_line.value;
  edit_line.focus();
}



function UserRename() {
  var http = new XMLHttpRequest();

  http.open("POST", "/!chat?session=" + session, true);
  http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
  http.send("cmd=rename&username=" + encodeURIComponent(user_line.value));
}



function UserStatusChange(status) {
  var http = new XMLHttpRequest();

  http.open("POST", "/!chat?session=" + session, true);
  http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
  http.send("cmd=status&status=" + status);
}


function SendMessage() {
  var txt = edit_line.value;
  if (txt) {

      var http = new XMLHttpRequest();
      http.open("POST", "/!chat?session=" + session, true);
      http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

      var p = "cmd=message&chat_message=" + encodeURIComponent(txt);
      http.send(p);

    edit_line.value = "";
    edit_line.focus();
  }
}



function CreateUserSpan(user, original) {
  var c = "user";
  if (user != original) {
    c += " fake_user";
  }
  return '<span onclick="InsertNick(this)" class="' + c + '" title="' + original + '">' + user + '</span>: ';
}



function OnFullChatMessage(e) {

  var msgset = JSON.parse(e.data);
  var ntf = "";
  var cnt = 0;
  var all = document.createDocumentFragment();

  for (var i = 0; i < msgset.msgs.length; i++) {
    var msg = msgset.msgs^[i^];

    if ( ! document.getElementById("chat" + msg.id) ) {
      var date = new Date(msg.time*1000);
      var day = ("0" + date.getDate()).substr(-2);
      var mon = ("0" + ( date.getMonth() + 1 )).substr(-2);
      var fdate =  day + '.' + mon + '.' + date.getFullYear();
      var hours = ("0" + date.getHours()).substr(-2);
      var minutes = ("0" + date.getMinutes()).substr(-2);
      var seconds = ("0" + date.getSeconds()).substr(-2);

      if ( cdate != fdate ) {
        cdate = fdate;
        var h4 = document.createElement('h4');
        h4.classList.add("hline");
        h4.innerHTML = '<span class="date">'+cdate+'</span>';
        all.appendChild(h4);
      }

      var p = document.createElement('p');
      p.id = "chat" + msg.id;
      p.classList.add("message");
      p.innerHTML = '<span class="time">(' + hours + ':' + minutes + ':' + seconds + ')</span> ' + CreateUserSpan(msg.user, msg.originalname) + replaceEmoticons(linkify(msg.text));
      all.appendChild(p);
      cnt++;

      if (ntf !== "") ntf += ", ";
      ntf += msg.user;
    }
  }

  do_notify = ( Math.abs((chat_log.scrollTop + chat_log.clientHeight) - chat_log.scrollHeight) > 128 );

  if ( (! total_cnt) && (do_notify || document.hidden) && cnt ) {
    var last = chat_log.lastChild;
    if ( last && (last.tagName != 'h4') ) {
      var h4 = document.createElement('h4');
      h4.classList.add("hline");
      chat_log.appendChild(h4);
    }
  }

  chat_log.appendChild(all);
  ScrollBottom(false);

  if (  ! (do_notify || document.hidden)) {
      total_cnt = 0;
      document.title = title;
  }

  if (cnt && document.hidden) notify("New messages in the chat from: " + ntf);

  if (cnt && (document.hidden || do_notify)) {
    total_cnt = total_cnt + cnt;
    document.title = '(' + total_cnt.toString() + ') ' + title;
  }
}

function user_node(usr) {
  var p = document.createElement('p');
  p.id = 'user'+usr.sid;
  p.classList.add("user");
  if (usr.status == 2) p.classList.add("gray_user");
  if (usr.originalname !== usr.user) p.classList.add("fake_user");
  p.setAttribute( "onclick", "InsertNick(this);" );
  p.innerHTML = usr.user;

  if ( session && session.startsWith(usr.sid) ) {
    user_line.innerHTML = usr.user;
    user_line.value = user_line.textContent;
    if ( (usr.status !== 2) && document.hidden ) UserStatusChange(2);
  }

  return p;
}

function OnUsersOnline (e) {
  var msgset = JSON.parse(e.data);

  while (sys_log.firstChild) {
    sys_log.removeChild(sys_log.lastChild);
  }

  for (var i = 0; i < msgset.users.length; i++) {
    if (msgset.users^[i^].events & 3 !== 0) {          // Chat events mask == 7
      var p = user_node(msgset.users^[i^]);
      sys_log.appendChild(p);
    }
  }
  ScrollBottom(false);
}

function OnUserChanged (e) {
  var usr = JSON.parse(e.data);
  var pold = document.getElementById('user'+usr.sid);

  if ( (usr.status == 0) || (!(usr.events & 3)) )  {
    if ( pold ) sys_log.removeChild(pold);
  } else {
    var p = user_node(usr);
    if ( pold ) sys_log.replaceChild(p, pold)
    else sys_log.insertBefore(p, sys_log.firstChild);
  }
}

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
|
  [equ:btnForum=Forum]
  [equ:phNick=Benutzername]
  [equ:phText=Hier eingeben]
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

