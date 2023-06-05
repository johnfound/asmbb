function fixVideos() {
  var all = document.getElementsByTagName("video");
  for(var i = all.length-1; i >= 0; i--) {
     var v = all[i];
     var url = new URL(v.childNodes[0].src);
     var pa = url.pathname.split("/").filter(e =>  e);

     var id = "";
     var eu = "";

     switch (url.hostname) {
       case "www.youtube.com":
         if (pa[0] === 'watch') {
           id = url.searchParams.get("v");
           eu = "https://www.youtube.com/embed/";
         } else if (pa[0] === 'shorts') {
           id = pa[1];
           eu = "https://www.youtube.com/embed/";
         }
         break;
       case "youtu.be":
         id = pa[0];
         eu = "https://www.youtube.com/embed/";
         break;
       case "vimeo.com":
         id = pa[0];
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
