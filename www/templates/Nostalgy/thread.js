<script src="[special:skin]/highlight.js"></script>

<script>
  document.addEventListener('DOMContentLoaded', (event) => {
    document.querySelectorAll('pre>code').forEach((block) => {
      hljs.highlightBlock(block);
    });
  });

  WantEvents = WantEvents + 0x40  // + evmThreadRating

  listSourceEvents.push(
    {
      event: 'thread_rating',
      handler: OnThreadRatingChange
    }
  );

  function OnThreadRatingChange(e) {
    var ev = JSON.parse(e.data);
    var cl = "thread_rating" + ev.threadid;
    var all = document.getElementsByClassName(cl);

    for (var i=0; i<all.length; i++) {
      all^[i^].innerText = ev.rating;
    };
  }

  [case:[special:canvote]||
  function OnVote(host, inc) {
    var http = new XMLHttpRequest();

    if (host.classList.contains("voted")) {
      inc = 0;
    }

    http.onreadystatechange = function() {
      if (this.readyState == 4 && this.status == 200) {

        var all = Array.from(document.getElementsByClassName("voted"));
        for (var i=0; i<all.length; i++) {
          all^[i^].classList.remove("voted");
        };

        var ret = this.responseText;

        if ( (ret !== "vote_0") && (ret === "vote_up" ^|^| ret === "vote_dn") ) {
          var all = Array.from(document.getElementsByClassName(ret));
          for (var i=0; i<all.length; i++) {
            all^[i^].classList.add("voted");
          };
        }
      }
    }

    http.open("POST", "!vote", true);
    http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

    var p = "vote=" + inc;
    http.send(p);
  }
  ]

</script>

