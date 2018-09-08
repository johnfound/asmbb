[css:navigation.css]
[css:chat.css]

  <script type='text/javascript'>

// some extras and utilities

    function getCookie(cname) {
        var name = cname + "=";
        var decodedCookie = decodeURIComponent(document.cookie);
        var ca = decodedCookie.split(';');
        for(var i = 0; i < ca.length; i++) {
            var c = ca^[i^];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
            }
        }
        return "";
    }

    function linkify(inputText) {
        var replacedText, replacePattern1;
        //URLs starting with http://, https://, or ftp://
        replacePattern1 = /(\b(https?|ftp):\/\/^[-A-Z0-9+&@#\/%?=~_|!:,.;^]*^[-A-Z0-9+&@#\/%=~_|^])/gim;
        replacedText = inputText.replace(replacePattern1, '<a class="chatlink" href="$1" target="_blank">$1</a>');
        return replacedText;
    }


    function replaceEmoticons(text) {
      var emoticons = {
        ':LOL:'  : ^['rofl.gif', ':D'^],
        ':lol:'  : ^['rofl.gif', ':D'^],
        ':ЛОЛ:'  : ^['rofl.gif', ':D'^],
        ':лол:'  : ^['rofl.gif', ':D'^],
        ':-)'    : ^['smile.gif', ':)'^],
        ':)'     : ^['smile.gif', ':)'^],
        ':-D'    : ^['lol.gif', ':D'^],
        ':D'     : ^['lol.gif', ':D'^],
        ':-Д'    : ^['lol.gif', ':D'^],
        ':Д'     : ^['lol.gif', ':D'^],
        '&gt;:-(': ^['angry.gif', '>:('^],
        '&gt;:(' : ^['angry.gif', '>:('^],
        ':-('    : ^['sad.gif', ':(' ^],
        ':('     : ^['sad.gif', ':(' ^],
        ':`-('   : ^['cry.gif', ':`('^],
        ':`('    : ^['cry.gif', ':`('^],
        ':\'-('  : ^['cry.gif', ':`('^],
        ':\'('   : ^['cry.gif', ':`('^],
        ';-)'    : ^['wink.gif', ';)'^],
        ';)'     : ^['wink.gif', ';)'^],
        ':-P'    : ^['tongue.gif', ':P'^],
        ':P'     : ^['tongue.gif', ':P'^],
        ':-П'    : ^['tongue.gif', ':P'^],
        ':П'     : ^['tongue.gif', ':P'^]
      };
      var url = "[special:skin]/_images/chatemoticons/";
      var patterns = ^[^];
      var metachars = /^[^[\^]{}()*+?.\\|^$\-,&#\s^]/g;

      // build a regex pattern for each defined property
      for (var i in emoticons) {
        if (emoticons.hasOwnProperty(i)) { // escape metacharacters
          patterns.push('('+i.replace(metachars, "\\$&")+')');
        }
      }

      // build the regular expression and replace
      return text.replace(new RegExp(patterns.join('|'),'g'), function (match) {
//ONLY THE TEXT:  return typeof emoticons^[match^] != 'undefined' ? '<span class="emo">'+emoticons^[match^]^[1^]+'</span>' : match;
        return typeof emoticons^[match^] != 'undefined' ? '<img class="emo" style="width: 2ch; height: 1.2em;" src="'+url+emoticons^[match^]^[0^]+'" alt="'+emoticons^[match^]^[1^]+'">' : match;
      });
    }

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

    var EventSource = window.EventSource;

    var source;
    var edit_line;
    var user_line;
    var chat_log;
    var sys_log;
    var total_cnt = 0;
    var title = document.title;
    var do_notify = false;
    var cdate;   // current date


    function ScrollBottom(force) {
      if ( force || ! do_notify ) chat_log.scrollTop = chat_log.scrollHeight - chat_log.clientHeight;
    }


// Entering the chat.

    function connect() {
      source = new EventSource("/!chat_events");

      source.onmessage = OnMessage;
      source.onopen = OnConnect;
      source.onerror = OnError;

      source.addEventListener('message', OnMessage);
      source.addEventListener('users_online', OnUsersOnline);
      source.addEventListener('user_changed', OnUserChanged);
    }

    document.body.onload = function () {
      user_line = document.getElementById("chat_user");
      edit_line = document.getElementById("chat_message");
      chat_log  = document.getElementById("chatlog");
      sys_log   = document.getElementById("syslog");
      connect();
    };

//  Leaving the chat.

    window.onbeforeunload = function (e) {
      if (source) source.close();
      source = null;
      UserStatusChange(0);
      return null;
    };

    document.addEventListener("visibilitychange", function() {
      if ( ! document.hidden ) {
        total_cnt = 0;
        document.title = title;
        UserStatusChange(1);
        ScrollBottom(true);
      } else {
        if ( source ) UserStatusChange(2);
      }
    });

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

      http.open("POST", "/!chat", true);
      http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      http.send("cmd=rename&username=" + encodeURIComponent(user_line.value));
    }

    function UserStatusChange(status) {
      var http = new XMLHttpRequest();

      http.open("POST", "/!chat", true);
      http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      http.send("cmd=status&status=" + status);
    }


    function SendMessage() {
      if (edit_line.value) {
        var http = new XMLHttpRequest();

        http.open("POST", "/!chat", true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        var p = "cmd=message&chat_message=" + encodeURIComponent(edit_line.value);
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

    function OnMessage(e) {

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

      var mysid = getCookie("eventsid").substr(0, 8);
      if (usr.sid === mysid ) {
        user_line.innerHTML = usr.user;
        user_line.value = user_line.textContent;
      }

      return p;
    }

    function OnUsersOnline (e) {
      var msgset = JSON.parse(e.data);

      while (sys_log.firstChild) {
        sys_log.removeChild(sys_log.lastChild);
      }

      for (var i = 0; i < msgset.users.length; i++) {
        var p = user_node(msgset.users^[i^]);
        sys_log.appendChild(p);
      }
      ScrollBottom(false);
    }

    function OnUserChanged (e) {
      var usr = JSON.parse(e.data);
      var pold = document.getElementById('user'+usr.sid);

      if ( usr.status == 0 ) {
        sys_log.removeChild(pold);
      } else {
        var p = user_node(usr);
        if ( pold ) sys_log.replaceChild(p, pold)
        else sys_log.insertBefore(p, sys_log.firstChild);
      }
    }

    function OnConnect(e) {
      edit_line.style.backgroundColor = null;
      UserStatusChange(1);
    }

    function OnError(e) {
      edit_line.style.backgroundColor = "#ffa0a0";
      setTimeout( function() {
        connect();
      }, 2000 );
      UserStatusChange(2);
    }

  </script>

  <div class="chat">
    <div class="ui">
      <a class="ui left" href="/">Forum</a>
    </div>
    <div class="chatflex">
      <div id="chatlog"></div>
      <div id="syslog"></div>
    </div>
    <div id="chat_form">
      <input class="chat_input" type="edit" placeholder="Username" id="chat_user" onkeypress="KeyPress(event, UserRename)" onChange="UserRename()">
      <input class="chat_input" type="edit" placeholder="Type here" id="chat_message" autofocus onkeypress="KeyPress(event, SendMessage)">
      <a class="sendbtn" onclick="SendMessage()">Send</a>
    </div>
  </div>

