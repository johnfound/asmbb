  <style>
    .tags { display: none; }
  </style>


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
        ':-)' : 'smile.svg',
        ':)'  : 'smile.svg',
        ':-D' : 'lol.svg',
        ':D'  : 'lol.svg',
        ':-Д' : 'lol.svg',
        ':Д'  : 'lol.svg',
        '&gt;:-(': 'angry.svg',
        '&gt;:(' : 'angry.svg',
        ':-(' : 'sad.svg',
        ':('  : 'sad.svg',
        ':`-(': 'cry.svg',
        ':ч-(': 'cry.svg',
        ':ч(' : 'cry.svg',
        ':`(' : 'cry.svg',
        ';-)' : 'wink.svg',
        ';)'  : 'wink.svg',
        ':-P' : 'tongue2.svg',
        ':P'  : 'tongue2.svg',
        ':-Р' : 'tongue2.svg',
        ':Р'  : 'tongue2.svg',
        ':-П' : 'tongue2.svg',
        ':П'  : 'tongue2.svg'
      };
      var url = "/images/chatemoticons/";
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

//    replaceEmoticons('this is a simple test :-) :-| :D :)');


// essential code.

    var source;
    var edit_line;
    var user_line;
    var chat_log;
    var sys_log;
    var old_user = "[username]";
    var session = "[session]";

// Entering the chat.

    document.body.onload = function () {
      user_line = document.getElementById("chat_user");
      edit_line = document.getElementById("chat_message");
      chat_log  = document.getElementById("chatlog");
      sys_log   = document.getElementById("syslog");

      source = new EventSource("/!chat_events?sid="+session);

      source.onmessage = OnPush;
      source.onopen = OnConnect;
      source.onerror = OnError;

      source.addEventListener('message', OnPush);
      source.addEventListener('status', OnUserStatus);
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
      var new_user = user_line.value;

      if ( new_user != old_user ) {
        DoUserRename(new_user);
//        old_user = new_user;
      };
    };

    function DoUserRename (newname) {
      var http = new XMLHttpRequest();

      http.open("POST", "!chat", true);
      http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      http.send("username=" + encodeURIComponent(newname) + "&sid=" + session);
    };

    function UserStatusChange(status) {
      var http = new XMLHttpRequest();

      http.open("POST", "!chat", true);
      http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      http.send("status=" + status + "&sid=" + session);
    };


    function SendMessage() {
      if (edit_line.value) {
        var http = new XMLHttpRequest();

        http.open("POST", "!chat", true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

        var p = "chat_message=" + encodeURIComponent(edit_line.value) + "&sid=" + session;
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


    function OnPush(e) {

      var msgset = JSON.parse(e.data);

      for (var i in msgset.msgs) {
        var msg = msgset.msgs[i];

        if ( ! document.getElementById("chat" + msg.id) ) {
          var date = new Date(msg.time*1000);
          var hours = "0" + date.getHours();
          var minutes = "0" + date.getMinutes();
          var seconds = "0" + date.getSeconds();
          var Time = hours.substr(-2) + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);

          var para = '<p id="chat' + msg.id + '"><span>(' + Time + ')</span> ' + MakeUserStr(msg.user, msg.originalname) + ': ' + linkify(replaceEmoticons(msg.text)) + '</p>';

          chat_log.innerHTML += para;
          chat_log.scrollTop = chat_log.scrollHeight;
        };
      };
    };

    function OnUserStatus (e) {
      var msgset = JSON.parse(e.data);

      for (var i in msgset.users) {
        var usr = msgset.users[i];

        var userid = 'user_' + usr.session;
        var userel = document.getElementById(userid);
        var para = '<p class="user" onclick="InsertNick(this)" id="' + userid + '" title="' + usr.originalname + '">' + usr.user + '</p>';

        if (usr.session == session) {
          user_line.innerHTML = usr.user;
          user_line.value = user_line.textContent;
          old_user = user_line.textContent;
        };

        if ( userel ) {

          userel.innerHTML = usr.user;

          if ( usr.status == 0 ) {
            userel.parentNode.removeChild(userel);
          };

          if ( usr.status == 2 ) {
            userel.className = "gray_user";
          };

          if ( usr.status == 1 ) {
            if ( usr.originalname != usr.user) {
              userel.className = "fake_user";
            } else {
              userel.className = "user";
            };
          };

        } else {
          if ( usr.status != 0 ) {
            sys_log.innerHTML += para;
            userel = document.getElementById(userid);

            if ( usr.originalname != usr.user) {
              userel.className = "fake_user";
            };

            if ( usr.status == 2 ) {
              userel.className = "gray_user";
            };
          };
        };
      };
    };

    function OnConnect(e) {
      // display connection status here.
    };

    function OnError(e) {
      UserStatusChange(2);
    };

  </script>

  <div class="threads_list">
    <div class="ui">
      <a class="ui" href="/">Forum</a>
    </div>
    <div class="flex">
      <div id="chatlog"></div>
      <div id="syslog"></div>
    </div>
    <div id="chat_form">
      <input class="chat_user" type="edit" placeholder="Username" id="chat_user" value="[username]" onkeypress="KeyPress(event, UserRename)" onChange="UserRename()">
      <input class="chat_line" type="edit" placeholder="Type here" id="chat_message" autofocus onkeypress="KeyPress(event, SendMessage)">
      <img class="icon_btn" id="chat_submit" src="/images/edit_white.svg" alt="?" onclick="SendMessage()">
    </div>
  </div>
