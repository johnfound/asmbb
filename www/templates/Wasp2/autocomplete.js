var auto_list = document.createElement("UL");
auto_list.id = "autocomplete";

var __ruler = document.createElement("SPAN");
var cache = {};


function VisibleWidth(s) {
  var l = s.split(",");
  if (l.length > 0) l.length--;
  for (var i = 0; i < l.length; i++) l[i] = l[i].trim();

  __ruler.innerHTML = l.join(', ');
  return __ruler.offsetWidth;
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


function ShowAutocomplete(comp_list, inp) {
  inp.parentElement.style.position = "relative";
  inp.parentElement.appendChild(auto_list);

  auto_list.parentEditor = inp;
  auto_list.style.left = ( inp.offsetLeft + VisibleWidth(inp.value)) + "px";
  auto_list.style.top = (inp.offsetTop + inp.offsetHeight) + "px";

  var ul = JSON.parse(comp_list);

  while (auto_list.firstChild) {
    auto_list.removeChild(auto_list.lastChild);
  }

  if (ul.length != 0) {
    for (var i = 0; i < ul.length; i++) {
      var li = document.createElement('li');
      li.setAttribute('onclick', 'Complete("' + ul[i] + '", "' + inp.id + '");');
      li.setAttribute('onkeydown', 'ListKeyDown(event)');
      li.tabIndex = 0;
      li.innerHTML = ul[i];
      auto_list.appendChild(li);
    }
    auto_list.style.display = "block";
  } else auto_list.style.display = "none";
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
  var ignore = true;

  if (auto_list.style.display === "block" ) {
    var key = e.which || e.keyCode;
    switch (key) {
      case 40:
        auto_list.firstChild.focus();
        break;
      case 38:
        auto_list.lastChild.focus();
        break;
      case 13:
        auto_list.firstChild.click();
        break
      case 27:
        auto_list.style.display = "none";
        break;
      default:
        ignore = false;
    }
    if (ignore) {
      e.preventDefault();
      e.stopPropagation();
    }
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

  if (ignore) {
    e.preventDefault();
    e.stopPropagation();
  }
}
