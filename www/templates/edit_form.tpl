<script type='text/javascript'>
  window.onscroll=function(){
    document.getElementById('editor').style.marginTop = window.scrollY.toString()+"px";
  };
</script>

<div class="editor" id="editor">
  <form id="editform" action="/edit/$id$" method="post">
    <p>Thread title:</p>
    <h1 class="fakeedit">$caption$</h1>
    <p>Post content:</p>
    <textarea class="editor" name="source" id="source">$source$</textarea>
    <div class="panel">
      <input type="submit" name="submit" value="Submit" >
      <input type="submit" name="preview" value="Preview" >
      <input type="reset" value="Revert" >
    </div>
  </form>
</div>