  <script type='text/javascript'>

// some extras and utilities

    function linkify(inputText) {
        var replacedText, replacePattern1;
        //URLs starting with http://, https://, or ftp://
        replacePattern1 = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim;
        replacedText = inputText.replace(replacePattern1, '<a href="$1" target="_blank">$1</a>');
        return replacedText;
    }


// essential code.

    var source = null;
    var connected = false;
    var edit_line;
    var user_line;
    var chat_log;
    var sys_log;
    var old_user = "[username]";

// Entering the chat.

    document.body.onload = function () {
      user_line = document.getElementById("chat_user");
      edit_line = document.getElementById("chat_message");
      chat_log  = document.getElementById("chatlog");
      sys_log   = document.getElementById("syslog");

      source = new EventSource("/!chat_events");

      source.onmessage = OnPush;
      source.onopen = OnConnect;
      source.onerror = OnError;

      source.addEventListener('message', OnPush);
      source.addEventListener('status', OnUserStatus);

      UserRename();
    };

//  Leaving the chat.

    window.onbeforeunload = function (e) {
      UserStatusChange(old_user, 0);
      return null;
    };

    function KeyPress(e) {
     var keyCode = e.keyCode;
     if (keyCode == '13') SendMessage();
    };

    function KeyPress2(e) {
     var keyCode = e.keyCode;
     if (keyCode == '13') UserRename();
    };

    function UserRename(e) {
     var new_user = user_line.value;
     if (new_user && new_user != old_user) {
       UserStatusChange(old_user, 0);
       UserStatusChange(new_user, 1);
       old_user = new_user;
     };
    };

    function UserStatusChange (username, new_status) {
      if (username) {
        var http = new XMLHttpRequest();

        http.open("POST", "!chat", true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.send("username=" + encodeURIComponent(username) + "&status=" + new_status);
      };
    };

    function SendMessage() {
      if (edit_line.value) {
        var http = new XMLHttpRequest();

        http.open("POST", "!chat", true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.send("chat_message=" + encodeURIComponent(edit_line.value) + "&username=" + encodeURIComponent(old_user));

        edit_line.value = "";
        edit_line.focus();
      };
    };

    function OnPush(e) {

      var msg = JSON.parse(e.data);

      if ( ! document.getElementById("chat" + msg.id) ) {
        var date = new Date(msg.time*1000);
        var hours = "0" + date.getHours();
        var minutes = "0" + date.getMinutes();
        var seconds = "0" + date.getSeconds();
        var Time = hours.substr(-2) + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);

        var para = '<p id="chat' + msg.id + '"><span>(' + Time + ')</span> <b>' + msg.user + '</b>: ';

        para += linkify(msg.text) + '</p>';

        chat_log.innerHTML += para;
        chat_log.scrollTop = chat_log.scrollHeight;
      };
    };

    function OnUserStatus (e) {
      var msg = JSON.parse(e.data);

      var userid = encodeURIComponent('user:' + msg.originalname);
      var userel = document.getElementById(userid);
      var para = '<p class="user" id="' + userid + '">' + msg.user + ' <span>(' + msg.originalname + ')</span></p>';

      if ( userel ) {

        if ( msg.status == 0 ) {
          userel.parentNode.removeChild(userel);
        };

        if ( msg.status == 2 ) {
          userel.className = "gray_user";
        };

        if ( msg.status == 1 ) {
          userel.className = "user";
        }

      } else {
        if ( msg.status != 0 ) {
          sys_log.innerHTML += para;
          userel = document.getElementById(userid);
          if ( msg.status == 2 ) {
            userel.className = "gray_user";
          };
        };
      };
    };

    function OnConnect(e) {
      if ( ! connected ) {
//        sys_log.innerHTML += "<p>Connection established.</p>";
//        sys_log.scrollTop = sys_log.scrollHeight;
        connected = true;
        UserStatusChange(old_user, 1);
      };
    };

    function OnError(e) {
      if ( connected ) {
//        sys_log.innerHTML += "<p>Connection interrupted. Reconnecting...</p>";
//        sys_log.scrollTop = sys_log.scrollHeight;
        connected = false;
        UserStatusChange(old_user, 2);
      };
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
      <input class="chat_user" type="edit" placeholder="Username" id="chat_user" value="[username]" onkeypress="KeyPress2(event)" onChange="UserRename()">
      <input class="chat_line" type="edit" placeholder="Type here" id="chat_message" autofocus onkeypress="KeyPress(event)">
      <img class="icon_btn" id="chat_submit" src="/images/edit_white.svg" alt="?" onclick="SendMessage()">
    </div>
  </div>