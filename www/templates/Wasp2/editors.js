// Highlighter functions. Use it on every change of the preview.

function highlightIt(Element) {
  Element.querySelectorAll('pre>code').forEach((block) => {
    hljs.highlightBlock(block);
  });
}

highlightIt(document);


// edit [type="file] customizer

var browseBtn = document.getElementById('browse-btn');
var browseTxt = document.getElementById('browse-txt');
var browseEdt = document.getElementById('attach');

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


function previewIt(e) {
  if ((e == undefined) || (e.target.cmd === "preview")) {
    if (e) e.preventDefault();

    var form = document.getElementById("editform");

    var xhr = new XMLHttpRequest();
    xhr.open("POST", form.action + "?cmd=preview");

    xhr.onload = function(event){
      if (event.target.status === 200) {
        var prv = document.getElementById("preview");
        var attch = document.getElementById("attachments");
        var resp = JSON.parse(event.target.response);

        if (attch) attch.innerHTML = resp.attach_del;
        prv.innerHTML = resp.preview;
        highlightIt(prv);
      }
      if (e) {
        document.getElementById("source").focus();
        browseEdt.value = null;
        browseEdt.onchange();
      }
    };

    var formData = new FormData(form);
    xhr.send(formData);
  }
}

window.addEventListener('load', previewIt());


// Form keyboard hot keys.

document.onkeydown = function(e) {
  var key = e.which || e.keyCode;
  var frm = document.getElementById("editform");
  var btnclose = document.getElementById("btn-close");
  var stop = true;

  if (e.ctrlKey && key == 13) {
    frm.preview.click();
  } else if (key == 27) {
    btnclose.click();
  } else if (e.ctrlKey && key == 83) {
    frm.submit.click();
  } else stop = false;

  if (stop) e.preventDefault();
};



// Emoji picker

var emolib = document.getElementById('emolib');
var emolinks = emolib.querySelectorAll("a");

[].forEach.call(emolinks, function(e) {
  e.onclick = function() {
    var target = document.getElementById('source');
    if ( ! target ) return 0;

    var emoji = this.innerText;

    var startPos = target.selectionStart;
    var endPos = target.selectionEnd;

    target.focus();
    target.value = target.value.substring(0, startPos) + emoji + ' ' + target.value.substring(endPos, target.value.length);
    target.setSelectionRange(startPos+3, startPos+3);
  }
});
