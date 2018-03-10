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
    var chat_log;
    var sys_log;
    var total_cnt = 0;
    var title = document.title;
    var do_notify = false;

// Entering the chat.

    document.body.onload = function () {
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

    function UserRename(new_name) {
      var http = new XMLHttpRequest();

      http.open("POST", "!chat", true);
      http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      http.send("cmd=rename&username=" + encodeURIComponent(new_name));
    };

    function UserStatusChange(status) {
      var http = new XMLHttpRequest();

      http.open("POST", "!chat", true);
      http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      http.send("cmd=status&status=" + status);
    };


    function SendMessage() {
      var txt = edit_line.value;
      if (txt) {

        if ( /^!.+$/.test(txt) ) {

          if (/^!+$/.test(txt)) {
            UserRename( '' );
          } else {
            UserRename(txt.replace(/^!(.+)$/,'$1'));
          };

          edit_line.value = "";
          edit_line.focus();
        } else {

          var http = new XMLHttpRequest();

          http.open("POST", "!chat", true);
          http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

          var p = "cmd=message&chat_message=" + encodeURIComponent(edit_line.value);
          http.send(p);

          edit_line.value = "";
          edit_line.focus();
        };
      };
    };

    function CreateUserSpan(user, original) {
      if (user == original) {
        var c = "user";
      } else {
        var c = "user fake";
      };
      return '<span onclick="InsertNick(this)" class="' + c + '" title="' + original + '">' + user + '</span>: ';
    };

    function CreateTimeSpan(time) {
      var date = new Date(time*1000);
      var hours = "0" + date.getHours();
      var minutes = "0" + date.getMinutes();
      var seconds = "0" + date.getSeconds();

      return '<span>(' + hours.substr(-2) + ':' + minutes.substr(-2) + ':' + seconds.substr(-2) + ')</span> ';
    };

    function OnMessage(e) {

      var msgset = JSON.parse(e.data);
      var ntf = "";
      var cnt = 0;

      var all = document.createDocumentFragment();

      for (var i in msgset.msgs) {
        var msg = msgset.msgs[i];

        if ( ! document.getElementById("chat" + msg.id) ) {

          var p = document.createElement('p');
          p.id = "chat" + msg.id;
          p.innerHTML = CreateTimeSpan(msg.time) + CreateUserSpan(msg.user, msg.originalname) + replaceEmoticons(linkify(msg.text));
          all.appendChild(p);
          cnt++;

          if (ntf != "") { ntf += ", "};
          ntf += msg.user;
        };
      };

      do_notify = (Math.abs((chat_log.scrollTop + chat_log.clientHeight) - chat_log.scrollHeight));

      if ( (! total_cnt) && (do_notify || document.hidden) && cnt ) {
        var last = chat_log.lastChild;
        if ( last && (last.tagName != 'HR') ) chat_log.appendChild(document.createElement('HR'));
      };

      chat_log.appendChild(all);

      if (  ! do_notify ) {
        chat_log.scrollTop = chat_log.scrollHeight - chat_log.clientHeight;
        if (! document.hidden) {
          total_cnt = 0;
          document.title = title;
        };
      };

      if (cnt && document.hidden) notify("New messages in the chat from: " + ntf);

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
      };

      for (var i in msgset.users) {
        var usr = msgset.users[i];
        var p = document.createElement('p');

        p.classList.add( usr.originalname == usr.user ? "user" : "fake_user");
        if (usr.status == 2) p.classList.add("gray_user");
        p.onclick = function() { InsertNick(this) };
        p.appendChild( document.createTextNode( usr.user ));

        sys_log.appendChild(p);

        if (usr.flagSelf) {
          edit_line.placeholder = "Chat as: " + usr.user + " (!new_name, !! default)";
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

  <div id="syslog"></div>
  <div id="chatboard">
    <a id="back" href="/"></a>
    <input class="edit" type="text" id="chat_message" autofocus onkeypress="KeyPress(event, SendMessage)">
    <div id="chatlog"></div>
  </div>

