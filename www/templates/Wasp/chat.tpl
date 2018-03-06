[css:navigation.css]
[css:chat.css]

  <script type='text/javascript'>

// some extras and utilities

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
      var url = "[special:skin]/_images/chatemoticons/";
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
    var total_cnt = 0;
    var title = document.title;
    var do_notify = false;

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

    function CreateUserSpan(user, original) {
      var usr = document.createElement('span');
      usr.classList.add('user');
      usr.onclick = function() { InsertNick(this) };
      usr.title = original;
      usr.appendChild( document.createTextNode(user));

      if (user != original) {
        usr.classList.add('fake');
      };

      return usr;
    }

    function CreateTimeSpan(time) {
      var date = new Date(time*1000);
      var hours = "0" + date.getHours();
      var minutes = "0" + date.getMinutes();
      var seconds = "0" + date.getSeconds();

      var Time = document.createElement('span');
      Time.appendChild( document.createTextNode ( '(' + hours.substr(-2) + ':' + minutes.substr(-2) + ':' + seconds.substr(-2) + ') ' ) );
      return Time;
    }

    function OnMessage(e) {

      var msgset = JSON.parse(e.data);
      var cnt = 0;

      var all = document.createDocumentFragment();

      for (var i in msgset.msgs) {
        var msg = msgset.msgs[i];

        if ( ! document.getElementById("chat" + msg.id) ) {

          var p = document.createElement('p');
          p.id = "chat" + msg.id;

          p.appendChild( CreateTimeSpan(msg.time) );
          p.appendChild( CreateUserSpan(msg.user, msg.originalname) );

          p.innerHTML += ': ' + replaceEmoticons(linkify(msg.text));

          all.appendChild(p);
          cnt++;
        };
      };

      do_notify = (Math.abs((chat_log.scrollTop + chat_log.clientHeight) - chat_log.scrollHeight));

      if ( (! total_cnt) && (do_notify || document.hidden) && cnt ) {
        if ( chat_log.lastChild.tagName != 'HR' ) chat_log.appendChild(document.createElement('HR'));
      };

      chat_log.appendChild(all);

      if (  ! do_notify ) {
        chat_log.scrollTop = chat_log.scrollHeight - chat_log.clientHeight;
        if (! document.hidden) {
          total_cnt = 0;
          document.title = title;
        };
      };

      if (cnt && document.hidden) notify("New messages in the chat.");

      if (cnt && (document.hidden || do_notify)) {
        total_cnt = total_cnt + cnt;
        document.title = '(' + total_cnt.toString() + ') ' + title;
      };
    };

    document.onvisibilitychange = function() {
      if ( ! document.hidden ) {
        total_cnt = 0;
        document.title = title;
        UserStatusChange(1);
        chat_log.scrollTop = chat_log.scrollHeight - chat_log.clientHeight;
      } else {
        UserStatusChange(2);
      };
    };

    function OnUserOnline (e) {
      var msgset = JSON.parse(e.data);

      while (sys_log.firstChild) {
        sys_log.removeChild(sys_log.lastChild);
      }

      for (var i in msgset.users) {
        var usr = msgset.users[i];
        var p = document.createElement('p');

        p.classList.add( usr.originalname == usr.user ? "user" : "fake_user");
        if (usr.status == 2) p.classList.add("gray_user");
        p.onclick = function() { InsertNick(this) };
        p.appendChild( document.createTextNode( usr.user ));

        sys_log.appendChild(p);

        if (usr.flagSelf) {
          user_line.innerHTML = usr.user;
          user_line.value = user_line.textContent;
        };
      };
      if (  ! do_notify ) chat_log.scrollTop = chat_log.scrollHeight - chat_log.clientHeight;
    };

    function OnConnect(e) {
      // display connection status here.
    };

    function OnError(e) {
      UserStatusChange(2);
    };

  </script>

  <div class="chat">
    <div class="ui">
      <a class="ui" href="/">Forum</a>
    </div>
    <div class="flex">
      <div id="chatlog"></div>
      <div id="syslog"></div>
    </div>
    <div id="chat_form">
      <input class="chat_user" type="edit" placeholder="Username" id="chat_user" onkeypress="KeyPress(event, UserRename)" onChange="UserRename()">
      <input class="chat_line" type="edit" placeholder="Type here" id="chat_message" autofocus onkeypress="KeyPress(event, SendMessage)">
      <a class="icon_btn" id="chat_submit" alt="?" onclick="SendMessage()"></a>
    </div>
  </div>

