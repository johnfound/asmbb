[css:navigation.css]
[css:chat.css]

  <script type='text/javascript'>

// some extras and utilities

    //show online user in mobille
    function ShowOnline() {
      if (document.getElementById("syslog").classList.contains('show_div')) {
        document.getElementById("syslog").classList.remove('show_div');
      } else {
        document.getElementById("syslog").classList.add('show_div');
      }
    }

    function linkify(inputText) {
        var replacedText, replacePattern1;
        //URLs starting with http://, https://, or ftp://
        replacePattern1 = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim;
        replacedText = inputText.replace(replacePattern1, '<a href="$1" target="_blank">$1</a>');
        return replacedText;
    }


    function replaceEmoticons(text) {
      var emoticons = {
        ':LOL:': 'rofl.gif',
        ':lol:': 'rofl.gif',
        ':ЛОЛ:': 'rofl.gif',
        ':лол:': 'rofl.gif',
        ':-)' : 'smile.gif',
        ':)'  : 'smile.gif',
        ':-D' : 'lol.gif',
        ':D'  : 'lol.gif',
        ':-Д' : 'lol.gif',
        ':Д'  : 'lol.gif',
        '&gt;:-(': 'angry.gif',
        '&gt;:(' : 'angry.gif',
        ':-(' : 'sad.gif',
        ':('  : 'sad.gif',
        ':`-(': 'cry.gif',
        ':`(' : 'cry.gif',
        ':\'-(': 'cry.gif',
        ':\'(':  'cry.gif',
        ';-)' : 'wink.gif',
        ';)'  : 'wink.gif',
        ':-P' : 'tongue.gif',
        ':P'  : 'tongue.gif',
        ':-П' : 'tongue.gif',
        ':П'  : 'tongue.gif'
      };
      var url = "/[special:skin]_images/chatemoticons/";
      var patterns = [];
      var metachars = /[[\]{}()*+?.\\|^$\-,&#\s]/g;

      // build a regex pattern for each defined property
      for (var i in emoticons) {
        if (emoticons.hasOwnProperty(i)) { // escape metacharacters
          patterns.push('('+i.replace(metachars, "\\$&")+')');
        }
      }

      // build the regular expression and replace
      return text.replace(new RegExp(patterns.join('|'),'g'), function (match) {
        return typeof emoticons[match] != 'undefined' ? '<img src="'+url+emoticons[match]+'">' : match;
      });
    }

    function notify(Msg) {
      if (!("Notification" in window)) {
        alert("This browser does not support desktop notification");
      } else if (Notification.permission === "granted") {
               var notification = new Notification(Msg);
             } else if (Notification.permission !== "denied") {
                      Notification.requestPermission( function (permission) {
                        if (permission === "granted") {
                          var notification = new Notification(Msg);
                        }
                      });
                    }
    }

// essential code.

    var source;
    var edit_line;
    var user_line;
    var chat_log;
    var sys_log;

// user interface handling.

    function DrawerShow(f) {
      document.getElementById("toggle_page").checked = f;
    }

// Entering the chat.

    document.body.onload = function () {
      user_line = document.getElementById("chat_user");
      edit_line = document.getElementById("chat_message");
      chat_log  = document.getElementById("chatlog");
      sys_log   = document.getElementById("syslog");

      source = new EventSource("/!chat_events");

      source.onmessage = OnMessage;
      source.onopen = OnConnect;
      source.onerror = OnError;

      source.addEventListener('message', OnMessage);
      source.addEventListener('users_online', OnUserOnline);
    };

//  Leaving the chat.

    window.onbeforeunload = function (e) {
      source.close();
      UserStatusChange(0);
      return null;
    };

    function KeyPress(e, proc) {
      if (e.keyCode == '13') {
        proc();
      };
    };

    function InsertNick(element) {
      edit_line.value = '@' + element.textContent + ': ' + edit_line.value;
      edit_line.focus();
    };

    function UserRename(e) {
      var http = new XMLHttpRequest();

      http.open("POST", "!chat", true);
      http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      http.send("cmd=rename&username=" + encodeURIComponent(user_line.value));
    };

    function UserStatusChange(status) {
      var http = new XMLHttpRequest();

      http.open("POST", "!chat", true);
      http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      http.send("cmd=status&status=" + status);
    };


    function SendMessage() {
      if (edit_line.value) {
        var http = new XMLHttpRequest();

        http.open("POST", "!chat", true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        var p = "cmd=message&chat_message=" + encodeURIComponent(edit_line.value);
        http.send(p);

        edit_line.value = "";
        edit_line.focus();
      };
    };

    function MakeUserStr(user, original) {
      if (user == original) {
        var c = "user";
      } else {
        var c = "user fake";
      };
      return '<span onclick="InsertNick(this)" class="' + c + '" title="' + original + '">' + user + '</span>';
    }


    function OnMessage(e) {

      var msgset = JSON.parse(e.data);
      var cnt = 0;

      for (var i in msgset.msgs) {
        var msg = msgset.msgs[i];

        if ( ! document.getElementById("chat" + msg.id) ) {
          var date = new Date(msg.time*1000);
          var hours = "0" + date.getHours();
          var minutes = "0" + date.getMinutes();
          var seconds = "0" + date.getSeconds();
          var Time = hours.substr(-2) + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);

          var para = '<p id="chat' + msg.id + '"><span>(' + Time + ')</span> ' + MakeUserStr(msg.user, msg.originalname) + ': ' + replaceEmoticons(linkify(msg.text)) + '</p>';

          chat_log.innerHTML += para;
          chat_log.scrollTop = chat_log.scrollHeight;
          cnt++;
        };
      };

      if (cnt && document.hidden) notify("New messages in the chat.");
    };

    function OnUserOnline (e) {
      var msgset = JSON.parse(e.data);
      var html = "";

      for (var i in msgset.users) {
        var usr = msgset.users[i];
        var uclass;

        if (usr.originalname == usr.user) {
          uclass = "user";
        } else {
          uclass = "fake_user";
        };

        html += '<p class="' + uclass + '" onclick="InsertNick(this)" title="' + usr.originalname + '">' + usr.user + '</p>';

        if (usr.flagSelf) {
          user_line.innerHTML = usr.user;
          user_line.value = user_line.textContent;
        };
      };

      sys_log.innerHTML = html;
    };

    function OnConnect(e) {
      // display connection status here.
    };

    function OnError(e) {
      UserStatusChange(2);
    };

  </script>

  <a id="header" href="/">
    AsmBB chat
  </a>

  <div id="chat">
    <input type="checkbox" id="toggle_page">

    <div id="chatboard">
      <label for="toggle_page"></label>
      <div id="chatlog"></div>
      <input class="edit" type="text" placeholder="Type here" id="chat_message" autofocus onkeypress="KeyPress(event, SendMessage)" onfocus="DrawerShow(false)">
    </div>

    <div id="drawer">
      <label for="toggle_page"></label>
      <div id="syslog"></div>
      <input class="edit" type="text" placeholder="Username" id="chat_user" onkeypress="KeyPress(event, UserRename)" onChange="UserRename()" onfocus="DrawerShow(true)">
    </div>
  </div>

