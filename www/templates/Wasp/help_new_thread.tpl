<style>
div.popup { display: none };
</style>

<input type="checkbox" id="help">
<div class="popup post_text">
<label class="popup close" for="help"></label>
[minimag:

#Post editing help

 *Tags:*

Some of the existing tags can (and should) be reused, or the thread starter can define his own tags. The format of the new created tags is:

;begin
  TAGNAME[:TAG_DESCRIPTION]
;end

The `TAGNAME` should not contains spaces and should be kept as short as possible. The `TAG_DESCRIPTION` can be much longer and
can contain spaces and other punctuation.
--------------------------

 *Text formatting:*

* Separate paragraphs by empty line.

--------------------------
* Inline formatting:
;begin
*bold*, /italic/, _underlined_, -striked-, -_*combined*_-, `monospaced`
;end

Renders as: *bold*, /italic/, _underlined_, -striked-, -_*combined*_-, `monospaced`

--------------------------

* Inline link: `Visit [http://board.asm32.info][AsmBB demo forum]`. Don't start it at the first text column.
  Renders to: "Visit [http://board.asm32.info][AsmBB demo forum]".

* Link-label. Define it on the first column of a line, before or after the place where will use it:

;begin
[AsmBB demo forum] https://board.asm32.info
;end

Use in the text only by the label: `Visit [AsmBB demo forum]`. Renders to "Visit [AsmBB demo forum]".

--------------------------

* Images are the same as the links (inline or link-labels), but the label starts with `?` (inline image) or `!` (block image):

;begin
[?asmbb] /images/favicons/android-chrome-48x48.png
[!asmbb] /images/favicons/android-chrome-48x48.png
;end

 `[?asmbb]` renders as [?asmbb].

 `[!asmbb]` renders as: [!asmbb]

The following smiles are predefined and can be directly used in the posts:

;begin
 [?:)], [?:-)], [?smile]
 [?;)], [?;-)], [?wink]
 [?:D], [?:-D], [?lol] [?rofl]
 [?:(], [?:-(], [?sad]
 [?:'(], [?:'-(], [?cry]
 [?:P], [?:-P]
 [?>:(], [?>:-(], [?angry]
;end

They renders to:

  [?:)] [?;)] [?:D] [?:(] [?:'(] [?:P] [?>:(]
--------------------------

* Blockquotes:
;begin
 ;quote johnfound
   This is a quoted text.

   It can contain *formatting* as well.
 ;end
;end

;quote johnfound
   This is a quoted text

   It can contain *formatting* as well.
;end

--------------------------
* Block of code:

;begin
 ;begin
      mov  eax, ebx
      add  eax, ecx
      xchg eax, ecx
 ;end
;end

Renders to:

;begin
     mov  eax, ebx
     add  eax, ecx
     xchg eax, ecx
;end
--------------------------
]
</div>
