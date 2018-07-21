[css:editor.css]

<div>
  <a class="editbtn" onclick="insertTag('source', '*', '*',   1)" title="Bold"                    ><img class="icon_bold"      src="[special:skin]/_images/toolbar.svg" alt="B"></a>
  <a class="editbtn" onclick="insertTag('source', '/', '/',   1)" title="Italic"                  ><img class="icon_italic"    src="[special:skin]/_images/toolbar.svg" alt="I"></a>
  <a class="editbtn" onclick="insertTag('source', '_', '_',   1)" title="Underlined"              ><img class="icon_underline" src="[special:skin]/_images/toolbar.svg" alt="U"></a>
  <a class="editbtn" onclick="insertTag('source', '-', '-',   1)" title="Strikethrough"           ><img class="icon_strike"    src="[special:skin]/_images/toolbar.svg" alt="S"></a>
  <a class="editbtn" onclick="insertTag('source', '`', '`',   1)" title="Inline code"             ><img class="icon_code"      src="[special:skin]/_images/toolbar.svg" alt="Mono"></a>
  <a class="editbtn" onclick="insertTag('source', '[', '][]', 1)" title="Link [url][description]" ><img class="icon_link"      src="[special:skin]/_images/toolbar.svg" alt="Link"></a>
  <a class="editbtn" onclick="insertTag('source', '[!','][]', 1)" title="Picture [!url][alt text]"><img class="icon_picture"   src="[special:skin]/_images/toolbar.svg" alt="Image"></a>

  <a class="editbtn" onclick="insertTag('source', ';quote', ';end', 0)" title="Block quote"       ><img class="icon_quote" src="[special:skin]/_images/toolbar.svg" alt="Quote"></a>
  <a class="editbtn" onclick="insertTag('source', ';begin', ';end', 0)" title="Code block"        ><img class="icon_blockcode" src="[special:skin]/_images/toolbar.svg" alt="Code"></a>

  <a class="editbtn" onclick="insertTag('source', '[?:-)]', '', 1)" title="Emoticon smile"        ><img class="icon_smile" src="[special:skin]/_images/toolbar.svg" alt="Smile"></a>
  <a class="editbtn" onclick="insertTag('source', '[?:-D]', '', 1)" title="Emoticon LOL"          ><img class="icon_lol" src="[special:skin]/_images/toolbar.svg" alt="LOL"></a>
  <a class="editbtn" onclick="insertTag('source', '[?rofl]', '', 1)" title="Emoticon ROFL"        ><img class="icon_rofl" src="[special:skin]/_images/toolbar.svg" alt="ROFL"></a>
  <a class="editbtn" onclick="insertTag('source', '[?;-)]', '', 1)" title="Emoticon wink"         ><img class="icon_wink" src="[special:skin]/_images/toolbar.svg" alt="Wink"></a>
  <a class="editbtn" onclick="insertTag('source', '[?:-P]', '', 1)" title="Emoticon tongue"       ><img class="icon_tongue" src="[special:skin]/_images/toolbar.svg" alt="Tongue"></a>
  <a class="editbtn" onclick="insertTag('source', '[?:-(]', '', 1)" title="Emoticon sad"          ><img class="icon_sad" src="[special:skin]/_images/toolbar.svg" alt="Sad"></a>
  <a class="editbtn" onclick="insertTag('source', '[?:\'-(]', '', 1)" title="Emoticon cry"        ><img class="icon_cry" src="[special:skin]/_images/toolbar.svg" alt="Cry"></a>
  <a class="editbtn" onclick="insertTag('source', '[?>:-(]', '', 1)" title="Emoticon angry"       ><img class="icon_angry" src="[special:skin]/_images/toolbar.svg" alt="Angry"></a>
</div>

<script>
  function insertTag(id, opentag, closetag, fInline) {
    var target = document.getElementById(id);
    if ( ! target ) return 0;

    var startPos = target.selectionStart;
    var endPos = target.selectionEnd;
    var sel = target.value.substring(startPos, endPos);
    var prevch = (startPos == 0) ? '' : target.value.substr(startPos-1,1);
    var nextch = target.value.substr(endPos,1);
    var lastch = (endPos == 0) ? '' : target.value.substr(endPos-1, 1);

    var newpos = endPos + opentag.length;
    if ( sel !== '' ) newpos += closetag.length;

    if (fInline) {
      if ( /[a-zA-Z0-9\]]/.test(prevch) || ! prevch ) {
        opentag = ' ' + opentag;
        newpos++;
      };

      if ( /[a-zA-Z0-9]/.test(nextch) || ! nextch) {
        closetag = closetag + ' ';
      };

    } else {
      if ( prevch != '\n' && prevch != '' ) {
        opentag = '\r\n' + opentag;
        newpos++;
      };

      opentag = opentag + '\r\n';

      if (sel !== '') {
        newpos++;
        if (lastch !== '\n') {
          closetag = '\r\n' + closetag;
          newpos++;
        };
      } else {
        closetag = '\r\n' + closetag;
      };

      if ( nextch != '\n' ) {
        closetag = closetag + '\r\n';
        newpos++;
      };
    };

    target.focus();
    if (! document.execCommand('insertText', false, opentag + sel + closetag)) {
      target.value = target.value.substring(0, startPos) + opentag + sel + closetag + target.value.substring(endPos, target.value.length);
    };
    target.setSelectionRange(newpos, newpos);
  };
</script>