<script>
  WantEvents = WantEvents + 0x40  // + evmThreadRating

  listSourceEvents.push(
    {
      event: 'thread_rating',
      handler: OnThreadRatingChange
    }
  );

  function OnThreadRatingChange(e) {
    var ev = JSON.parse(e.data);
    var id = "thread_rating" + ev.threadid;
    var el = document.getElementById(id);

    el.innerText = ev.rating;
  }
</script>
