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
      all[i].innerText = Number(all[i].innerText) + ev.change;
    };
  }

  function OnVote(inc) {
    var http = new XMLHttpRequest();
    http.open("POST", "!vote", true);
    http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

    var p = "vote=" + inc;
    http.send(p);
  }

</script>

