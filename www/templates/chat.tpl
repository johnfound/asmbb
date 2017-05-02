  <script type='text/javascript'>
    var source = null;
    var connected = false;
    document.body.onload = connect();

    function linkify(inputText) {
        var replacedText, replacePattern1;

        //URLs starting with http://, https://, or ftp://
        replacePattern1 = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim;
        replacedText = inputText.replace(replacePattern1, '<a href="$1" target="_blank">$1</a>');

        return replacedText;
    }

    function KeyPress(e) {
     var keyCode = e.keyCode;
     if (keyCode == '13') SendMessage();
    };

    function SendMessage() {
      var edit = document.getElementById("chat_message");
      if (edit.value) {
        var http = new XMLHttpRequest();
        var params = "chat_message="+encodeURIComponent(edit.value);

        http.open("POST", "!chat", true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.send(params);

        edit.value = "";
        edit.focus();
      };
    };

    function OnPush(event) {

      var msg = JSON.parse(event.data);

      if ( msg.user == "AsmBB" ) {
        var el = document.getElementById("syslog");
      } else {
        var el = document.getElementById("chatlog");
      };

      if ( document.getElementById("chat" + msg.id) == null ) {
        var date = new Date(msg.time*1000);
        var hours = "0" + date.getHours();
        var minutes = "0" + date.getMinutes();
        var seconds = "0" + date.getSeconds();
        var Time = hours.substr(-2) + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);

        var para = '<p id="chat' + msg.id + '"><span>(' + Time + ')</span> ';

        if ( msg.user != "AsmBB" ) {
          para += '<b>' + msg.user + '</b>: ';
        };

        para += linkify(msg.text) + '</p>';

        el.innerHTML += para;
        el.scrollTop = el.scrollHeight;
      };
    };

    function OnConnect(e) {
      if ( ! connected ) {
        var el = document.getElementById("syslog");
        el.innerHTML += "<p>Connection established.</p>";
        el.scrollTop = el.scrollHeight;
        connected = true;
      };
    };

    function OnError(e) {
      if ( connected ) {
        var el = document.getElementById("syslog");
        el.innerHTML += "<p>Connection interrupted. Reconnecting...</p>";
        el.scrollTop = el.scrollHeight;
        connected = false;
      };
    };

    function connect() {
      if (source != null) {
        source.onmessage = null;
        source.onerror = null;
        source.onopen = null;
      };
      source = null;
      source = new EventSource("/!chat_events");
      source.onmessage = OnPush;
      source.onopen = OnConnect;
      source.onerror = OnError;
    };

  </script>

  <div class="threads_list">
  <div class="ui">
    <a class="ui" href="/">Forum</a>
  </div>
  <div id="syslog"></div>
  <div id="chatlog"></div>
  <div id="chat_form">
    <input class="search_line" type="edit" placeholder="Type here" id="chat_message" autofocus onkeypress="KeyPress(event)">
    <img class="icon_btn" id="chat_submit" src="/images/edit_white.svg" alt="?" onclick="SendMessage()">
  </div>
  </div>