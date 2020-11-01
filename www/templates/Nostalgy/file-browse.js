// edit [type="file] customizer

var browseBtn = document.getElementById('browse-btn');
var browseTxt = document.getElementById('browse-txt');
var browseEdt = document.getElementById('input-file-browse');

browseEdt.style.width = 0;
browseBtn.style.display = 'inline-flex';
browseTxt.style.display = 'block';

browseEdt.onchange = function() {
  var cnt = browseEdt.files.length;

  if (cnt == 0)
    browseTxt.innerText = browseTxt.getAttribute("data-empty");
  else if (cnt == 1)
    browseTxt.innerText = browseEdt.files[0].name;
  else {
    browseTxt.innerText = cnt + browseEdt.getAttribute("data-multiselect");
    var allFiles = '';
    for (i = 0; i<cnt; i++) {
      allFiles += (browseEdt.files[i].name + '\n');
    };
    browseTxt.title = allFiles;
  }
};

browseEdt.onchange();
