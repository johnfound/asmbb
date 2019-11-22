<span id="__ruler"></span>
<ul id="autocomplete"></ul>

<script>

var cache = {};

function VisibleWidth(s) {
  var l = s.split(",");
  if (l.length > 0) l.length--;
  for (var i = 0; i < l.length; i++) l[i] = l[i].trim();

  var r = document.getElementById("__ruler");
  r.innerHTML = l.join(', ');
  return r.offsetWidth;
}

function SplitAndTrim(inp) {
  var list = inp.value.split(",");
  for (var i = 0; i < list.length; i++) list[i] = list[i].trim();
  return list;
}


function Complete(nm, inpid) {
  var inp = document.getElementById(inpid);
  var list = SplitAndTrim(inp);
  list[list.length - 1] = nm + ', ';
  inp.value = list.join(", ");
  inp.focus();
  ShowAutocomplete("[]", inp);
}


function ShowAutocomplete(users, inp) {
  var list = document.getElementById('autocomplete');

  list.parentEditor = inp;
  list.style.left = ( inp.offsetLeft + VisibleWidth(inp.value)) + "px";
  list.style.top = (inp.offsetTop + inp.offsetHeight) + "px";
//  list.style.width = (list.offsetWidth + 32) + "px";  // something is wrong here!

  var ul = JSON.parse(users);

  while (list.firstChild) {
    list.removeChild(list.lastChild);
  }

  if (ul.length != 0) {
    for (var i = 0; i < ul.length; i++) {
      var li = document.createElement('li');
      li.setAttribute('onclick', 'Complete("' + ul[i] + '", "' + inp.id + '");');
      li.setAttribute('onkeydown', 'ListKeyDown(event)');
      li.tabIndex = 0;
      li.innerHTML = ul[i];
      list.appendChild(li);
    }
    list.style.display = "block";
  } else list.style.display = "none";
}


function InputChanged(inp) {
  var list = SplitAndTrim(inp);
  var last = list[list.length-1];
  if (last !== "" && cache[inp.id] && cache[inp.id][last])
    ShowAutocomplete(cache[inp.id][last], inp);
  else if (last) {
    var url = inp.attributes.getlist.value + last;
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url);
    xhr.onload = function(net) {
      if (net.target.status == 200) {
        if (! (inp.id in cache)) cache[inp.id] = {};
        cache[inp.id][last] = net.target.response;
        ShowAutocomplete(cache[inp.id][last], inp);
      }
    };
    xhr.send();
  } else ShowAutocomplete("[]", inp);
}


var delay = null;

function OnKeyboard(inp) {
  if (delay != null) clearTimeout(delay);
  delay = setTimeout(function(){ InputChanged(inp); }, 500);
}


function EditKeyDown(e, inp) {
  var list = document.getElementById('autocomplete');
  var ignore = true;

  if (list.style.display === "block" ) {
    var key = e.which || e.keyCode;
    switch (key) {
      case 40:
        list.firstChild.focus();
        break;
      case 38:
        list.lastChild.focus();
        break;
      case 13:
        list.firstChild.click();
        break
      case 27:
        list.style.display = "none";
        break;
      default:
        ignore = false;
    }
    if (ignore) e.preventDefault();
  }
}


function ListKeyDown(e) {
  var src = e.srcElement;
  var key = e.which || e.keyCode;
  var ignore = true;

  switch (key) {
    case 40:
      if (src.nextSibling) src.nextSibling.focus();
      else if (src.parentElement.parentEditor) src.parentElement.parentEditor.focus();
           else src.parentElement.firstChild.focus();
      break;

    case 38:
      if (src.previousSibling) src.previousSibling.focus();
      else if (src.parentElement.parentEditor) src.parentElement.parentEditor.focus();
           else src.parentElement.lastChild.focus();
      break;

    case 13:
      src.click();
      break;

    case 27:
      src.parentElement.style.display = "none";
      src.parentElement.parentEditor.focus();
      break;

    default:
      ignore = false;
  }

  if (ignore) e.preventDefault();
  return false;
}


</script>