  <script type='text/javascript'>
    var source = null;

    function KeyPress(e) {
     var keyCode = e.keyCode;
     if (keyCode == '13') SendMessage();
    };

    function SendMessage() {
      var edit = document.getElementById("chat_message");
      if (edit.value) {
        var http = new XMLHttpRequest();
        var params = "chat_message="+edit.value;

        http.open("POST", "!chat", true);
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.send(params);

        edit.value = "";
        edit.focus();
      };
    };

    function OnPush(event) {
      var el = document.getElementById("chatlog");
      el.innerHTML += event.data;
      el.scrollTop = el.scrollHeight;
      el = null;
    };

    function OnError(e) {
      var el = document.getElementById("chatlog");
      el.innerHTML = "Error connecting!<br>";
      el.scrollTop = el.scrollHeight;
      el = null;
    };

    function connect() {
      if (source != null) source.onmessage = null;
      source = null;
      source = new EventSource('/!chat_events');
      source.onmessage = OnPush;
      source.onerror = OnError;
    }

    connect();
  </script>

  <div id="chatlog">Here you can chat.<br></div>
  <div id="chat_form">
    <input class="search_line" type="edit" placeholder="Type here" id="chat_message" autofocus onkeypress="KeyPress(event)">
    <img class="icon_btn" id="chat_submit" src="/images/edit_white.svg" alt="?" onclick="SendMessage()">
  </div>
