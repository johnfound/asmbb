  <script type='text/javascript'>
    var source = null;

    function OnPush(event) {
      var el = document.getElementById("chatlog");
      el.innerHTML += event.data + "<br>";
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
  <form id="chat_form">
    <input class="search_line" type="edit" placeholder="Type here" id="chat_message" autofocus>
    <img class="icon_btn" id="chat_submit" src="/images/search.svg" alt="?" onclick="SendMessage()">
  </form>
