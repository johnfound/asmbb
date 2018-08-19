[css:editor.css]

<div class="toolbar">
  <a class="editbtn" onclick="insertTag('source', '*', '*',   1)" title="Bold"                    ><span class="icon_bold">B</span></a>
  <a class="editbtn" onclick="insertTag('source', '/', '/',   1)" title="Italic"                  ><span class="icon_italic">I</span></a>
  <a class="editbtn" onclick="insertTag('source', '_', '_',   1)" title="Underlined"              ><span class="icon_underline">U</span></a>
  <a class="editbtn" onclick="insertTag('source', '-', '-',   1)" title="Strikethrough"           ><span class="icon_strike">S</span></a>
  <a class="editbtn" onclick="insertTag('source', '`', '`',   1)" title="Inline code"             ><span class="icon_code">Mono</span></a>
  <a class="editbtn" onclick="insertTag('source', '[', '][]', 1)" title="Link [url][description]" ><span class="icon_link">Link</span></a>
  <a class="editbtn" onclick="insertTag('source', '[!','][]', 1)" title="Picture [!url][alt text]"><span class="icon_picture">Image</span></a>

  <a class="editbtn" onclick="insertTag('source', ';quote', ';end', 0)" title="Block quote"       ><span class="icon_quote">Quote</span></a>
  <a class="editbtn" onclick="insertTag('source', ';begin', ';end', 0)" title="Code block"        ><span class="icon_blockcode">Code</span></a>

  <a class="editbtn" onclick="insertTag('source', '[?:-)]', '', 1)" title="Emoticon smile"        ><span class="icon_smile">Smile</span></a>
  <a class="editbtn" onclick="insertTag('source', '[?:-D]', '', 1)" title="Emoticon LOL"          ><span class="icon_lol">LOL</span></a>
  <a class="editbtn" onclick="insertTag('source', '[?rofl]', '', 1)" title="Emoticon ROFL"        ><span class="icon_rofl">ROFL</span></a>
  <a class="editbtn" onclick="insertTag('source', '[?;-)]', '', 1)" title="Emoticon wink"         ><span class="icon_wink">Wink</span></a>
  <a class="editbtn" onclick="insertTag('source', '[?:-P]', '', 1)" title="Emoticon tongue"       ><span class="icon_tongue">Tongue</span></a>
  <a class="editbtn" onclick="insertTag('source', '[?:-(]', '', 1)" title="Emoticon sad"          ><span class="icon_sad">Sad</span></a>
  <a class="editbtn" onclick="insertTag('source', '[?:\'-(]', '', 1)" title="Emoticon cry"        ><span class="icon_cry">Cry</span></a>
  <a class="editbtn" onclick="insertTag('source', '[?>:-(]', '', 1)" title="Emoticon angry"       ><span class="icon_angry">Angry</span></a>
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