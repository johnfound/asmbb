[css:editor.css]

[case:[special:lang]|
  [equ:Bold=Bold]
  [equ:Italic=Italic]
  [equ:Underlined=Underlined]
  [equ:Strikethrough=Strikethrough]
  [equ:CodeBlock=Code block]
  [equ:InlineCode=Monospaced]
  [equ:BlockQuote=Block quote]
  [equ:Link=Link ^[url^]^[description^]]
  [equ:Image=Picture ^[!url^]^[alt text^]]

  [equ:EmoSmile=Emoticon smile]
  [equ:EmoLOL=Emoticon LOL]
  [equ:EmoROFL=Emoticon ROFL]
  [equ:EmoWink=Emoticon wink]
  [equ:EmoTongue=Emoticon tongue]
  [equ:EmoSad=Emoticon sad]
  [equ:EmoCry=Emoticon cry]
  [equ:EmoAngry=Emoticon angry]
|
  [equ:Bold=Удебелен]
  [equ:Italic=Курсив]
  [equ:Underlined=Подчертано]
  [equ:Strikethrough=Зачертано]
  [equ:CodeBlock=Блок код]
  [equ:InlineCode=Моноширинен]
  [equ:BlockQuote=Цитат]
  [equ:Link=Връзка ^[url^]^[description^]]
  [equ:Image=Picture ^[!url^]^[alt text^]]

  [equ:EmoSmile=Емотикон усмивка]
  [equ:EmoLOL=Емотикон LOL]
  [equ:EmoROFL=Емотикон ROFL]
  [equ:EmoWink=Емотикон намигане]
  [equ:EmoTongue=Емотикон плезене]
  [equ:EmoSad=Емотикон тъжен]
  [equ:EmoCry=Емотикон плач]
  [equ:EmoAngry=Емотикон ядосан]
|
  [equ:Bold=Жирный]
  [equ:Italic=Курсив]
  [equ:Underlined=Подчёркнутый]
  [equ:Strikethrough=Зачеркнутый]
  [equ:CodeBlock=Исходники]
  [equ:InlineCode=Моноширинный]
  [equ:BlockQuote=Цитата]
  [equ:Link=Ссылка ^[url^]^[description^]]
  [equ:Image=Picture ^[!url^]^[alt text^]]

  [equ:EmoSmile=Смайлик улыбка]
  [equ:EmoLOL=Смайлик LOL]
  [equ:EmoROFL=Смайлик ROFL]
  [equ:EmoWink=Смайлик подмигивание]
  [equ:EmoTongue=Смайлик язык]
  [equ:EmoSad=Смайлик грустный]
  [equ:EmoCry=Смайлик плачет]
  [equ:EmoAngry=Смайлик гневный]
|
  [equ:Bold=Gras]
  [equ:Italic=Italique]
  [equ:Underlined=Souligné]
  [equ:Strikethrough=Barré]
  [equ:CodeBlock=Code source]
  [equ:InlineCode=Chasse]
  [equ:BlockQuote=Citation]
  [equ:Link=Lien ^[url^]^[description^]]
  [equ:Image=Image ^[!url^]^[alt text^]]

  [equ:EmoSmile=Emoticone content]
  [equ:EmoLOL=Emoticone MDR]
  [equ:EmoROFL=Emoticone PTDR]
  [equ:EmoWink=Emoticone clin d'oeil]
  [equ:EmoTongue=Emoticone langue]
  [equ:EmoSad=Emoticone triste]
  [equ:EmoCry=Emoticone pleure]
  [equ:EmoAngry=Emoticone fâché]
|
  [equ:Bold=Fett]
  [equ:Italic=Kursiv]
  [equ:Underlined=Unterstrichen]
  [equ:Strikethrough=Durchgestrichen]
  [equ:CodeBlock=Codeblock]
  [equ:InlineCode=Feste Breite]
  [equ:BlockQuote=Zitat]
  [equ:Link=Link ^[url^]^[description^]]
  [equ:Image=Bild ^[!url^]^[alt text^]]

  [equ:EmoSmile=Emoticon Lächeln]
  [equ:EmoLOL=Emoticon LOL]
  [equ:EmoROFL=Emoticon ROFL]
  [equ:EmoWink=Emoticon Zwinkern]
  [equ:EmoTongue=Emoticon Zunge raus]
  [equ:EmoSad=Emoticon traurig]
  [equ:EmoCry=Emoticon weinen]
  [equ:EmoAngry=Emoticon wütend]
]

<div class="jsonly">
  <div class="toolbar">
    [case:[special:markup=0]|<section><input name="format" value="1" type="hidden"></section>|
    [case:[special:markup=0]||[case:[special:markup=1]||
    <input id="mark0" name="format" type="radio" [case:[format]|checked|] value="0">
    <label for="mark0" style="top: 0px;"><span>MiniMag</span></label>
    ]]
    <section>
      <a class="editbtn" onclick="insertTag('source', '*', '*', 1)" title="[const:Bold]"><img class="icon_bold" src="/images/empty.png" alt="B"></a>
      <a class="editbtn" onclick="insertTag('source', '/', '/', 1)" title="[const:Italic]"><img class="icon_italic" src="/images/empty.png" alt="I"></a>
      <a class="editbtn" onclick="insertTag('source', '_', '_', 1)" title="[const:Underlined]"><img class="icon_underline" src="/images/empty.png" alt="U"></a>
      <a class="editbtn" onclick="insertTag('source', '-', '-', 1)" title="[const:Strikethrough]"><img class="icon_strike" src="/images/empty.png" alt="S"></a>
      <a class="editbtn" onclick="insertTag('source', '`', '`', 1)" title="[const:InlineCode]"><img class="icon_code" src="/images/empty.png" alt="Mono"></a>
      <a class="editbtn" onclick="insertTag('source', '^[', '^]^[My link^]', 1)" title="[const:Link]"><img class="icon_link" src="/images/empty.png" alt="Link"></a>
      <a class="editbtn" onclick="insertTag('source', '^[!','^]^[My picture^]', 1)" title="[const:Image]"><img class="icon_picture" src="/images/empty.png" alt="Image"></a>

      <a class="editbtn" onclick="insertTag('source', ';quote', ';end', 0)" title="[const:BlockQuote]"><img class="icon_quote" src="/images/empty.png" alt="Quote"></a>
      <a class="editbtn" onclick="insertTag('source', ';begin', ';end', 0)" title="[const:CodeBlock]"><img class="icon_blockcode" src="/images/empty.png" alt="Code"></a>

      <a class="editbtn" onclick="insertTag('source', '^[?:-)^]', '', 1)" title="[const:EmoSmile]"><img class="icon_smile" src="/images/empty.png" alt="Smile"></a>
      <a class="editbtn" onclick="insertTag('source', '^[?:-D^]', '', 1)" title="[const:EmoLOL]"><img class="icon_lol" src="/images/empty.png" alt="LOL"></a>
      <a class="editbtn" onclick="insertTag('source', '^[?rofl^]', '', 1)" title="[const:EmoROFL]"><img class="icon_rofl" src="/images/empty.png" alt="ROFL"></a>
      <a class="editbtn" onclick="insertTag('source', '^[?;-)^]', '', 1)" title="[const:EmoWink]"><img class="icon_wink" src="/images/empty.png" alt="Wink"></a>
      <a class="editbtn" onclick="insertTag('source', '^[?:-P^]', '', 1)" title="[const:EmoTongue]"><img class="icon_tongue" src="/images/empty.png" alt="Tongue"></a>
      <a class="editbtn" onclick="insertTag('source', '^[?:-(^]', '', 1)" title="[const:EmoSad]"><img class="icon_sad" src="/images/empty.png" alt="Sad"></a>
      <a class="editbtn" onclick="insertTag('source', '^[?:\'-(^]', '', 1)" title="[const:EmoCry]"><img class="icon_cry" src="/images/empty.png" alt="Cry"></a>
      <a class="editbtn" onclick="insertTag('source', '^[?>:-(^]', '', 1)" title="[const:EmoAngry]"><img class="icon_angry" src="/images/empty.png" alt="Angry"></a>
    </section>
    ]

    [case:[special:markup=1]|<section><input name="format" value="0" type="hidden"></section>|
    [case:[special:markup=1]||[case:[special:markup=0]||
    <input id="mark1" name="format" type="radio" [case:[format]||checked] value="1">
    <label for="mark1" style="top: 50%;"><span>BBcode</span></label>
    ]]
    <section class="bbcode">
      <a class="editbtn" onclick="insertTag('source', '^[b^]', '^[/b^]', 1)" title="[const:Bold]"><img class="icon_bold" src="/images/empty.png" alt="B"></a>
      <a class="editbtn" onclick="insertTag('source', '^[i^]', '^[/i^]', 1)" title="[const:Italic]"><img class="icon_italic" src="/images/empty.png" alt="I"></a>
      <a class="editbtn" onclick="insertTag('source', '^[u^]', '^[/u^]', 1)" title="[const:Underlined]"><img class="icon_underline" src="/images/empty.png" alt="U"></a>
      <a class="editbtn" onclick="insertTag('source', '^[s^]', '^[/s^]', 1)" title="[const:Strikethrough]"><img class="icon_strike" src="/images/empty.png" alt="S"></a>
      <a class="editbtn" onclick="insertTag('source', '^[c^]', '^[/c^]', 1)" title="[const:InlineCode]"><img class="icon_code" src="/images/empty.png" alt="Mono"></a>
      <a class="editbtn" onclick="insertTag('source', '^[url=^]', '^[/url^]', 1)" title="[const:Link]"><img class="icon_link" src="/images/empty.png" alt="Link"></a>
      <a class="editbtn" onclick="insertTag('source', '^[img=^]', '^[/img^]', 1)" title="[const:Image]"><img class="icon_picture" src="/images/empty.png" alt="Image"></a>

      <a class="editbtn" onclick="insertTag('source', '^[quote=^]', '^[/quote^]', 0)" title="[const:BlockQuote]"><img class="icon_quote" src="/images/empty.png" alt="Quote"></a>
      <a class="editbtn" onclick="insertTag('source', '^[code^]', '^[/code^]', 0)" title="[const:CodeBlock]"><img class="icon_blockcode" src="/images/empty.png" alt="Code"></a>

      <a class="editbtn" onclick="insertTag('source', '^[:)^]', '', 1)" title="[const:EmoSmile]"><img class="icon_smile" src="/images/empty.png" alt="Smile"></a>
      <a class="editbtn" onclick="insertTag('source', '^[:D^]', '', 1)" title="[const:EmoLOL]"><img class="icon_lol" src="/images/empty.png" alt="LOL"></a>
      <a class="editbtn" onclick="insertTag('source', '^[:rofl:^]', '', 1)" title="[const:EmoROFL]"><img class="icon_rofl" src="/images/empty.png" alt="ROFL"></a>
      <a class="editbtn" onclick="insertTag('source', '^[;)^]', '', 1)" title="[const:EmoWink]"><img class="icon_wink" src="/images/empty.png" alt="Wink"></a>
      <a class="editbtn" onclick="insertTag('source', '^[:P^]', '', 1)" title="[const:EmoTongue]"><img class="icon_tongue" src="/images/empty.png" alt="Tongue"></a>
      <a class="editbtn" onclick="insertTag('source', '^[:(^]', '', 1)" title="[const:EmoSad]"><img class="icon_sad" src="/images/empty.png" alt="Sad"></a>
      <a class="editbtn" onclick="insertTag('source', '^[:`(^]', '', 1)" title="[const:EmoCry]"><img class="icon_cry" src="/images/empty.png" alt="Cry"></a>
      <a class="editbtn" onclick="insertTag('source', '^[>:(^]', '', 1)" title="[const:EmoAngry]"><img class="icon_angry" src="/images/empty.png" alt="Angry"></a>
    </section>
    ]
  </div>
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
      if ( /^[a-zA-Z0-9\n\^]^]/.test(prevch) || ! prevch ) {
        opentag = ' ' + opentag;
        newpos++;
      };

      if ( /^[a-zA-Z0-9^]/.test(nextch) || ! nextch) {
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


var timer = setInterval(function(){
  var val = document.getElementById("remval");
  if (val) {
    var time = val.innerHTML;
    if (time > 0) {
      val.innerHTML = time - 1;
    } else {
      document.getElementById("remains").hidden = true;
    }
  }
}, 1000);


</script>