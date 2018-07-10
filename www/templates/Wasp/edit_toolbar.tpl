[css:editor.css]

<div>
  <a class="editbtn icon_bold"      onclick="insertTag('source', '*', '*', 1)" title="Bold"></a>
  <a class="editbtn icon_italic"    onclick="insertTag('source', '/', '/', 1)" title="Italic"></a>
  <a class="editbtn icon_underline" onclick="insertTag('source', '_', '_', 1)" title="Underlined"></a>
  <a class="editbtn icon_strike"    onclick="insertTag('source', '-', '-', 1)" title="Strikethrough"></a>
  <a class="editbtn icon_code"      onclick="insertTag('source', '`', '`', 1)" title="Inline code"></a>
  <a class="editbtn icon_link"      onclick="insertTag('source', '[', '][]', 1)" title="Link [url][description]"></a>
  <a class="editbtn icon_picture"   onclick="insertTag('source', '[!', '][]', 1)" title="Picture [!url][alt text]"></a>

  <a class="editbtn icon_quote"     onclick="insertTag('source', ';quote', ';end', 0)" title="Block quote"></a>
  <a class="editbtn icon_blockcode" onclick="insertTag('source', ';begin', ';end', 0)" title="Code block"></a>

  <a class="editbtn icon_smile" onclick="insertTag('source', '[?:-)]', '', 1)" title="Emoticon smile"></a>
  <a class="editbtn icon_lol"   onclick="insertTag('source', '[?:-D]', '', 1)" title="Emoticon LOL"></a>
  <a class="editbtn icon_rofl"  onclick="insertTag('source', '[?rofl]', '', 1)" title="Emoticon ROFL"></a>
  <a class="editbtn icon_wink"  onclick="insertTag('source', '[?;-)]', '', 1)" title="Emoticon wink"></a>
  <a class="editbtn icon_tongue" onclick="insertTag('source', '[?:-P]', '', 1)" title="Emoticon tongue"></a>
  <a class="editbtn icon_sad"   onclick="insertTag('source', '[?:-(]', '', 1)" title="Emoticon sad"></a>
  <a class="editbtn icon_cry"   onclick="insertTag('source', '[?:\'-(]', '', 1)" title="Emoticon cry"></a>
  <a class="editbtn icon_angry" onclick="insertTag('source', '[?>:-(]', '', 1)" title="Emoticon angry"></a>
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