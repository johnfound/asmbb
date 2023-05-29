function fixVideos() {
  var all = document.getElementsByTagName("video");
  for(var i = all.length-1; i >= 0; i--) {
     var v = all[i];
     var url = new URL(v.childNodes[0].src);

     var id = "";
     var eu = "";

     switch (url.hostname) {
       case "www.youtube.com":
         id = url.searchParams.get("v");
         eu = "https://www.youtube.com/embed/";
         break;
       case "youtu.be":
         id = url.pathname.replace(/\//, "");
         eu = "https://www.youtube.com/embed/";
         break;
       case "vimeo.com":
         id = url.pathname.replace(/\//, "");
         eu = "https://player.vimeo.com/video/";
         break;
     }


     if (id !== "") {
       var f = document.createElement('iframe');
       f.width = 560;
       f.height = 315;
       f.allow = "fullscreen;";
       f.frameborder = 0;

       f.src = eu + id;

       v.parentNode.replaceChild(f, v);
     }
  }
}

document.addEventListener('DOMContentLoaded', fixVideos);
