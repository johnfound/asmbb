
; Pearsons hash function table:

if used tpl_func

tpl_func:
          db 148,  24,  71,  46, 179,   0, 106, 157,  70,   1, 102, 126, 120, 134, 151, 183
          db  47, 103,  92, 201,  62, 156,  13,  10, 254, 218, 248,  28,  85, 185, 245, 112
          db 236, 237, 150,  37, 172,  63, 203, 198, 116, 196,  25, 107, 239,  44,  15, 175
          db  38, 161, 140,  98,  33,  79,  99, 133,   2,  59, 174, 115,  69, 188,  51,  36
          db 229, 143, 231,  84,  22,  78,  89, 166, 104, 145,  34, 225, 180,  12, 230, 205
          db  97,  39,  49, 190, 182, 202,  17, 219, 176, 170,  80,  74,  73, 194,  41,  26
          db 243, 142,  60, 131, 244, 249, 119,  61, 138,  16,  77,  54, 210,  23,  29, 147
          db 204, 110, 130,  93, 213, 223, 146, 216, 123, 247,  90, 124,  75, 135,  57, 128
          db 226,  50, 224, 127, 139, 152, 193, 101, 207, 122,   9,  58, 184, 250,  96,  67
          db 241, 109,  87, 168, 187, 167, 240, 171, 233, 155, 173, 215,  43, 227, 160,   5
          db 246, 129,  20,  14, 100, 209, 137, 169,  68,  40,  42, 165, 121, 113, 200,  95
          db 189, 251,  82,  72, 154, 235, 195, 136, 186,  55, 212,  35,  32, 253,  66, 132
          db 214,  88, 192,   4,  31,  65, 114, 211,  19,  83,  21,   3,   6, 177,  76, 255
          db 252, 199, 141,  56, 105,  11, 117, 163, 220,  27, 222, 234, 178,  52,  64, 221
          db  18, 232, 164,  53, 206, 153, 118,  48, 158, 162, 159, 191, 242, 125, 144,  94
          db 108,  91, 197, 111,  30,   7,  81, 181, 149,  45, 217, 208,  86, 238,   8, 228


end if


struct TPHashItem
  .pKeyname    dd ?
  .procCommand dd ?
ends

; builds static Pearsons hash table.

macro PList table, Pfunc, [key, proc] {
common
  local ..error
  ..error = 0

  if defined options.ShowSizes & options.ShowSizes
    disp 3, 'Hash table "', `table, '"', 9
  end if

  table dd 256 dup(0,0)

forward
local ..keynm, ..len, ..hash, ..char, ..prev
  ..keynm db key
  ..len = $ - ..keynm
         db 0

  if proc
    ..hash = 0
    repeat ..len
      load ..char byte from ..keynm + % - 1
      if ..char and $40
        ..char = ..char or $20
      end if
      ..hash = ..hash xor ..char
      load ..hash byte from Pfunc + ..hash
    end repeat

    if defined options.ShowSizes & options.ShowSizes
      disp 3,'Keyword hash : ', <..hash, 10>, ' on "', key, '"', 10
    end if

    load ..prev dword from table + ..hash * 8

    if ..prev = 0
      store dword ..keynm at table + ..hash * 8
      store dword proc at table + ..hash * 8 + 4
    else
      disp 2,'Hash collision: ', <..hash, 10>, ' on "', key, '"', 10
      ..error = 1
    end if
  end if

common
  if defined options.ShowSizes & options.ShowSizes
    disp 6, '---', 13
  end if
  assert ~..error
}

struc phash Pfunc, key {
local ..keynm, ..len, ..hash, ..char

  virtual at 0
    ..keynm::
      db key
    ..len = $
  end virtual

  ..hash = 0
  repeat ..len
    load ..char byte from ..keynm:(% - 1)
    if ..char and $40
      ..char = ..char or $20
    end if
    ..hash = ..hash xor ..char
    load ..hash byte from Pfunc + ..hash
  end repeat

;  disp 3,'Keyword hash : ', <..hash, 10>, ' on "', key, '"', 10

  . = ..hash
}


if used RenderTemplate
        PList tableRenderCmd, tpl_func,                         \
              'special:',     RenderTemplate.cmd_special,       \
              'include:',     RenderTemplate.cmd_include,       \
              'minimag:',     RenderTemplate.cmd_minimag,       \   ; HTML, no encoding.
              'html:',        RenderTemplate.cmd_html,          \   ; HTML, disables the encoding.
              'attachments:', RenderTemplate.cmd_attachments,   \   ; HTML, no encoding.
              'attach_edit:', RenderTemplate.cmd_attachedit,    \   ; HTML, no encoding.
              'url:',         RenderTemplate.cmd_url,           \   ; Needs encoding!
              'json:',        RenderTemplate.cmd_json,          \   ; No encoding.
              'css:',         RenderTemplate.cmd_css,           \   ; No output, no encoding.
              'case:',        RenderTemplate.cmd_case,          \   ; No encoding.
              'sql:',         RenderTemplate.cmd_sql            ; Needs encoding!


        PList tableSpecial, tpl_func,                                 \
              "visitors",    RenderTemplate.sp_visitors,              \ ; HTML no encoding
              "version",     RenderTemplate.sp_version,               \ ; no encoding
              "cmdtype",     RenderTemplate.sp_cmdtype,               \ ; 0/1/2 no encoding
              "stats",       RenderTemplate.sp_stats,                 \ ; HTML no encoding
              "timestamp",   RenderTemplate.sp_timestamp,             \ ; NUMBER no encoding
              "title",       RenderTemplate.sp_title,                 \ ; Controlled source, no encoding
              "header",      RenderTemplate.sp_header,                \ ; Controlled source, no encoding
              "allstyles",   RenderTemplate.sp_allstyles,             \ ; CSS, from controlled source, no encoding.
              "description", RenderTemplate.sp_description,           \ ; Controlled source, no encoding
              "keywords",    RenderTemplate.sp_keywords,              \ ; Controlled source, no encoding
              "username",    RenderTemplate.sp_username,              \ ; Needs encoding!
              "userid",      RenderTemplate.sp_userid,                \ ; NUMBER, no encoding.
              "skin",        RenderTemplate.sp_skin,                  \ ; Controlled source, no encoding???
              "skincookie",  RenderTemplate.sp_skincookie,            \
              "page",        RenderTemplate.sp_page,                  \ ; Number, no encoding.
              "dir",         RenderTemplate.sp_dir,                   \ ; Needs encoding!
              "thread",      RenderTemplate.sp_thread,                \ ; Needs encoding!
              "permissions", RenderTemplate.sp_permissions,           \ ; NUMBER, no encoding
              "isadmin",     RenderTemplate.sp_isadmin,               \ ; 1/0 no encoding
              "canlogin",    RenderTemplate.sp_canlogin,              \ ; 1/0 no encoding
              "canpost",     RenderTemplate.sp_canpost,               \ ; 1/0 no encoding
              "canstart",    RenderTemplate.sp_canstart,              \ ; 1/0 no encoding
              "canedit",     RenderTemplate.sp_canedit,               \ ; 1/0 no encoding
              "candel",      RenderTemplate.sp_candelete,             \ ; 1/0 no encoding
              "canchat",     RenderTemplate.sp_canchat,               \ ; 1/0 no encoding
              "canupload",   RenderTemplate.sp_canupload,             \ ; 1/0 no encoding
              "referer",     RenderTemplate.sp_referer,               \ ; 1/0 no encoding
              "alltags",     RenderTemplate.sp_alltags,               \ ; HTML no encoding
              "setupmode",   RenderTemplate.sp_setupmode,             \ ; no encoding
              "search",      RenderTemplate.sp_search,                \ ; Needs encoding!
              "order",       RenderTemplate.sp_sort,                  \ ; Needs encoding!
              "usearch",     RenderTemplate.sp_usearch,               \ ; Needs encoding!
              "skins=",      RenderTemplate.sp_skins,                 \ ; HTML no encoding
              "posters=",    RenderTemplate.sp_posters,               \
              "invited=",    RenderTemplate.sp_invited,               \
              "threadtags=", RenderTemplate.sp_threadtags,            \
              "environment", RenderTemplate.sp_environment              ; optional, depends on options.DebugWeb
end if

useridHash phash tpl_func, "userid"

struct TFieldSlot
  .pName dd ?
  .Index dd ?
ends


; returns the rendered template in EAX

proc RenderTemplate, .pText, .hTemplate, .sqlite_statement, .pSpecial
.fEncode dd ?

.stmt dd ?

.separators rd 256
.sepindex   rd 16
.sepcnt     dd ?
.seplvl     dd ?

.tblFields TFieldSlot
           rb 255 * sizeof.TFieldSlot       ; a hash table of the statement field names.
begin
        pushad

        xor     eax, eax
        mov     [.sepcnt], eax
        mov     [.seplvl], eax

        cmp     [.sqlite_statement], eax
        je      .hash_ok

        lea     edi, [.tblFields]
        mov     ecx, 256 * sizeof.TFieldSlot / 4
        rep stosd

        call    .build_hash_table       ; creates a hash table for the SQL statement field names.

.hash_ok:
        mov     [.fEncode], 1

        mov     edx, [.pText]
        test    edx, edx
        jnz     .text_ok

        stdcall TextCreate, sizeof.TText
        mov     edx, eax

.text_ok:
        xor     ecx, ecx
        cmp     [.hTemplate], ecx
        je      .start_render           ; the template is already loaded in the structure.

        stdcall TextMoveGap, edx, -1

; create the full filename.

        stdcall StrDup, [hCurrentDir]
        mov     ebx, eax
        mov     eax, [.pSpecial]
        test    eax, eax
        jz      .fallback

        stdcall StrCat, ebx, [eax+TSpecialParams.userSkin]
        jmp     .add_template

.fallback:
        stdcall StrCat, ebx, "/templates/"
        stdcall GetParam, txt "default_skin", gpString
        jnc     @f
        stdcall StrDupMem, cDefaultSkin
@@:
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

.add_template:
        stdcall StrCat, ebx, txt '/'
        stdcall StrCat, ebx, [.hTemplate]

        stdcall FileOpenAccess, ebx, faReadOnly
        stdcall StrDel, ebx
        mov     ebx, eax
        jc      .exit

        stdcall FileSize, ebx
        push    eax
        stdcall TextSetGapSize, edx, eax

        mov     ecx, [edx+TText.GapBegin]
        mov     eax, ecx
        add     eax, edx

        stdcall FileRead, ebx, eax ; the size from the stack.
        add     [edx+TText.GapBegin], eax

        stdcall FileClose, ebx

.start_render:
        or      eax, -1
        push    eax

        dec     ecx

.loop:
        inc     ecx

        mov     eax, ecx
        cmp     ecx, [edx+TText.GapBegin]
        jb      @f
        add     eax, [edx+TText.GapEnd]
        sub     eax, [edx+TText.GapBegin]
@@:
        cmp     eax, [edx+TText.Length]
        jae     .finish

        cmp     byte [edx+eax], '|'
        je      .separator

        cmp     byte [edx+eax], ']'
        je      .end_param

        cmp     byte [edx+eax], '['
        jne     .loop

;.start_param:
; here something have to be done abour HTML encoding of the generated text!

        cmp     dword [edx+eax+1], 'mini'
        jne     .check_html

        cmp     dword [edx+eax+5], 'mag:'
        je      .disable_encoding

.check_html:
        cmp     dword [edx+eax+1], 'html'
        jne     .not_html
        cmp     byte [edx+eax+5], ':'
        jne     .not_html

.disable_encoding:
        mov     [.fEncode], 0         ; special processing for html: command.

.not_html:
        mov     eax, [.sepcnt]
        mov     esi, [.seplvl]
        mov     [.sepindex + 4*esi], eax
        inc     esi
        and     esi, $0f
        mov     [.seplvl], esi

        push    ecx             ; one level up...
        jmp     .loop

.separator:
        mov     eax, [.sepcnt]
        mov     [.separators+4*eax], ecx
        inc     al
        mov     [.sepcnt], eax
        jmp     .loop

.end_param:

        cmp     dword [esp], -1
        je      .loop          ; wrong nesting parameters. Ignore this.

        mov     eax, [.sepcnt]
        or      [.separators + 4*eax], -1
        or      [.separators + 4*eax + 4], -1

        mov     eax, [.seplvl]
        dec     eax
        and     eax, $0f
        mov     [.seplvl], eax
        mov     eax, [.sepindex + 4*eax]
        mov     [.sepcnt], eax

; here, [.sepcnt] points in [.separators] array to the start of the current parameter separators.
; the end is an item -1 in the array.

        pop     esi            ; points to "[" - the start of the parameter name. ECX is the end of the parameter name and points to "]".
        mov     edi, esi       ; where to replace.
        xor     ebx, ebx

.hash:
        inc     esi
        cmp     esi, ecx
        je      .check_fields

        mov     eax, esi
        cmp     esi, [edx+TText.GapBegin]
        jb      @f
        add     eax, [edx+TText.GapEnd]
        sub     eax, [edx+TText.GapBegin]
@@:
        mov     al, [edx+eax]
        mov     ah, al
        and     ah, $40
        shr     ah, 1
        or      al, ah  ; case insensitive hash function.

        xor     bl, al
        mov     bl, [ tpl_func + ebx]

        cmp     al, ":"
        je      .command

        jmp     .hash

.check_fields:

        cmp     [.sqlite_statement], 0
        je      .loop

.get_field_name:
        mov     esi, [.tblFields.pName + sizeof.TFieldSlot * ebx]
        test    esi, esi
        jz      .loop

        push    edi

        inc     edi
        cmp     edi, [edx+TText.GapBegin]
        jb      @f
        add     edi, [edx+TText.GapEnd]
        sub     edi, [edx+TText.GapBegin]
@@:
        add     edi, edx

.cmp_loop:
        mov     al, [esi]
        mov     ah, [edi]

        test    al, al
        jz      .field_match

        and     eax, $4040
        shr     al, 1
        shr     ah, 1
        or      al, [esi]
        or      ah, [edi]

        inc     esi
        inc     edi

        cmp     al, ah
        je      .cmp_loop

        pop     edi
        inc     bl
        jmp     .get_field_name


.field_match:

        pop     edi

        push    ecx edx
        cinvoke sqliteColumnText, [.sqlite_statement], [.tblFields.Index + sizeof.TFieldSlot * ebx]
        pop     edx ecx
        push    eax             ; pointer to the column text.

        push    ecx edx
        cinvoke sqliteColumnBytes, [.sqlite_statement], [.tblFields.Index + sizeof.TFieldSlot * ebx]
        pop     edx ecx
        push    eax             ; the length in bytes of the column text.

        cmp     [.fEncode], 0
        je      @f
        shl     eax, 3          ; if encoded, we need more space.
@@:
        stdcall TextSetGapSize, edx, eax
        stdcall TextMoveGap, edx, edi           ; the start of the field name.

        lea     eax, [ecx+1]
        sub     eax, edi
        add     [edx+TText.GapEnd], eax
        lea     ecx, [edi-1]

        pop     eax     ; field text length
        pop     esi     ; pointer to the field text

        add     edi, edx

        cmp     [.fEncode], 0
        je      .copy_not_encoded

        push    ecx
        xor     ebx, ebx
        mov     ecx, eax
        jecxz   .end_encode

.encode_loop:
        lodsb

        cmp     al, '<'
        je      .char_less_then
        cmp     al, '>'
        je      .char_greater_then
        cmp     al, '"'
        je      .char_quote
        cmp     al, '&'
        je      .char_amp

        stosb
        inc     ebx

.next_encode:
        loop    .encode_loop

.end_encode:

        pop     ecx
        add     ecx, ebx
        add     [edx+TText.GapBegin], ebx
        jmp     .loop


.char_less_then:
        mov     dword [edi], '&lt;'
        add     edi, 4
        add     ebx, 4
        jmp     .next_encode

.char_greater_then:
        mov     dword [edi], '&gt;'
        add     edi, 4
        add     ebx, 4
        jmp     .next_encode


.char_quote:
        mov     dword [edi], '&quo'
        mov     word [edi+4],'t;'
        add     edi, 6
        add     ebx, 6
        jmp     .next_encode

.char_amp:
        mov     dword [edi], '&amp'
        mov     byte [edi+4], ';'
        add     edi, 5
        add     ebx, 5
        jmp     .next_encode


.copy_not_encoded:
        add     [edx+TText.GapBegin], eax
        add     ecx, eax
        push    ecx

        mov     ecx, eax
        shr     eax, 2
        and     ecx, 3
        rep movsb
        mov     ecx, eax
        rep movsd

        pop     ecx
        jmp     .loop

; ...................................................................


.command:
        mov     eax, [tableRenderCmd + sizeof.TPHashItem * ebx + TPHashItem.procCommand]
        test    eax, eax
        jz      .loop

        jmp     eax


; ...................................................................

.cmd_minimag:
; here esi points to ":" of the "minimag:" command. edi points to the start "[" and ecx points to the end "]"

        stdcall TextMoveGap, edx, ecx
        stdcall TextSetGapSize, edx, 4
        mov     dword [edx+ecx], 0

        inc     [edx+TText.GapEnd]
        lea     ecx, [edi-1]

        push    ecx

        mov     ebx, [.pSpecial]
        stdcall StrDup, [hCurrentDir]
        stdcall StrCat, eax, [ebx+TSpecialParams.userSkin]
        stdcall StrCat, eax, "/minimag_suffix.tpl"
        push    eax

        stdcall FileOpenAccess, eax, faReadOnly
        stdcall StrDel ; from the stack.
        jc      .suffix_ok
        mov     ebx, eax

        stdcall FileSize, ebx
        jc      .suffix_close

        mov     ecx, eax
        add     eax, 4

        stdcall TextSetGapSize, edx, eax
        jc      .suffix_close

        mov     esi, [edx+TText.GapBegin]
        add     esi, edx

        stdcall FileRead, ebx, esi, ecx
        add     esi, eax
        mov     dword [esi], 0

.suffix_close:

        stdcall FileClose, ebx

.suffix_ok:
        pop     ecx

        lea     esi, [edx + edi + 9]    ; the start of the minimag source.
        stdcall FormatPostText, esi
        push    eax

        mov     [edx+TText.GapBegin], edi
        stdcall TextAddString, edx, edi, eax
        stdcall StrDel ; from the stack

        add     ecx, eax

        mov     [.fEncode], 1
        jmp     .loop

; ...................................................................

.cmd_include:
; here esi points to ":" of the "include:" command. edi points to the start "[" and ecx points to the end "]"

        stdcall TextMoveGap, edx, ecx
        inc     [edx+TText.GapEnd]

        call    .clip_and_copy
        mov     ebx, eax

        mov     [edx+TText.GapBegin], edi
        lea     ecx, [edi-1]                    ; moves ecx at the start of the included template.

        mov     esi, [.pSpecial]

        stdcall StrDup, [hCurrentDir]
        stdcall StrCat, eax, [esi+TSpecialParams.userSkin]
        stdcall StrCat, eax, txt "/"
        stdcall StrCat, eax, ebx
        stdcall StrDel, ebx
        push    eax

        stdcall FileOpenAccess, eax, faReadOnly
        stdcall StrDel ; from the stack
        jc      .loop

        mov     ebx, eax

        stdcall FileSize, ebx
        jc      .file_close

        stdcall TextSetGapSize, edx, eax

        mov     esi, [edx+TText.GapBegin]
        add     esi, edx
        stdcall FileRead, ebx, esi, eax
        add     [edx+TText.GapBegin], eax

.file_close:
        stdcall FileClose, ebx
        jmp     .loop


; ...................................................................

.cmd_html:
; here esi points to ":" of the "html:" command. edi points to the start "[" and ecx points to the end "]"
; simply remove the "[html:" and "]" and the remaining is the html that need no more processing.
        stdcall TextMoveGap, edx, ecx
        inc     [edx+TText.GapEnd]

        stdcall TextMoveGap, edx, edi
        add     [edx+TText.GapEnd], 6

        sub     ecx, 7

        mov     [.fEncode], 1
        jmp     .loop

; ...................................................................

sqlGetAttachments text "select id, filename, length(file), strftime('%d.%m.%Y', changed, 'unixepoch'), count, md5sum from Attachments left join AttachCnt on fileid = id where postID = ?1"

.cmd_attachments:
; here esi points to the ":" char of the "attachments" command, ecx at the end "]" and edi at the start "["

locals
  .fileid     dd ?
  .filename   dd ?
  .filesize   dd ?
  .uploadtime dd ?
  .count      dd ?
  .md5sum     dd ?
  .fEdit      dd ?
endl

        mov     [.fEdit], 0

.do_attachments:

        call    .get_number     ; returns the ID in the ebx.

        stdcall TextMoveGap, edx, ecx
        inc     [edx+TText.GapEnd]
        mov     [edx+TText.GapBegin], edi       ; clear the whole command.

        mov     edi, edx
        mov     esi, [.pSpecial]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetAttachments, sqlGetAttachments.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, ebx

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .end_of_attachments

        mov     edx, edi

        stdcall TextIns, edx, txt '<table><tr><td class="head" colspan="5">Attached files:</td></tr><tr>'
        cmp     [.fEdit], 0
        je      .edit_ok

        stdcall TextIns, edx, txt '<th>Del</th>'

.edit_ok:
        stdcall TextIns, edx, txt '<th>File</th><th>Size</th><th>Uploaded</th><th>Downloads</th>'
        cmp     [.fEdit], 0
        jne     .head_md5_ok
        stdcall TextIns, edx, txt '<th>MD5 hash</th>'
.head_md5_ok:
        stdcall TextIns, edx, txt '</tr>'
        mov     edi, edx

.att_loop:
        cinvoke sqliteColumnText, [.stmt], 0             ; ID of the file.
        mov     [.fileid], eax

        cinvoke sqliteColumnText, [.stmt], 1            ; filename of the file.
        mov     [.filename], eax

        cinvoke sqliteColumnInt, [.stmt], 2             ; file size
        mov     [.filesize], eax

        cinvoke sqliteColumnText, [.stmt], 3            ; upload time
        mov     [.uploadtime], eax

        cinvoke sqliteColumnText, [.stmt], 4             ; download count
        mov     [.count], eax

        cinvoke sqliteColumnText, [.stmt], 5             ; MD5 checksum
        mov     [.md5sum], eax

        mov     edx, edi

        stdcall TextIns, edx, txt '<tr>'

        cmp     [.fEdit], 0
        je      .edit_ok2

        stdcall TextIns, edx, txt '<td class="delcheck"><input type="checkbox" autocomplete="off" name="attch_del" id="attch'
        stdcall TextIns, edx, [.fileid]
        stdcall TextIns, edx, txt '" value="'
        stdcall TextIns, edx, [.fileid]
        stdcall TextIns, edx, txt '"><label for="attch'
        stdcall TextIns, edx, [.fileid]
        stdcall TextIns, edx, txt '"></label></td>'

.edit_ok2:
        stdcall TextIns, edx, txt '<td class="filename"><a href="/!attached/'
        stdcall TextIns, edx, [.fileid]
        stdcall TextIns, edx, txt '">'

        stdcall StrEncodeHTML, [.filename]
        stdcall TextAddStr2, edx, [edx+TText.GapBegin], eax, 0
        stdcall StrDel, eax
        stdcall TextIns, edx, txt '</a></td><td class="filesize">'

        stdcall FormatFileSize, [.filesize]
        stdcall TextIns, edx, eax
        stdcall StrDel, eax

        stdcall TextIns, edx, txt '</td><td class="filetime">'
        stdcall TextIns, edx, [.uploadtime]
        stdcall TextIns, edx, txt '</td><td class="filecnt">'
        stdcall TextIns, edx, [.count]

        cmp     [.fEdit], 0
        jne     .checksum_ok

        stdcall TextIns, edx, txt '</td><td class="checksum">'
        stdcall TextIns, edx, [.md5sum]

.checksum_ok:

        stdcall TextIns, edx, txt '</td></tr>'
        mov     edi, edx

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        je      .att_loop

        stdcall TextIns, edi, txt '</table>'
        mov     edi, edx

.end_of_attachments:

        cinvoke sqliteFinalize, [.stmt]

        mov     edx, edi
        mov     ecx, [edx+TText.GapBegin]
        dec     ecx

        mov     [.fEncode], 1
        jmp     .loop


.cmd_attachedit:
        mov     [.fEdit], 1
        jmp     .do_attachments


; ...................................................................
; here esi points to ":" of the "css:" command. edi points to the start "[" and ecx points to the end "]"

.cmd_css:
        cmp     [.pSpecial], 0
        je      .loop

        stdcall TextMoveGap, edx, ecx
        inc     [edx+TText.GapEnd]

        call    .clip_and_copy

        mov     [edx+TText.GapBegin], edi
        lea     ecx, [edi-1]

        push    edx

        mov     esi, [.pSpecial]
        stdcall ListAddDistinct, [esi+TSpecialParams.pStyles], eax
        mov     [esi+TSpecialParams.pStyles], edx

        pop     edx
        jmp     .loop


.cmd_url:
; here esi points to ":" of the "[url:" command. edi points to the start "[" and ecx points to the end "]"
        mov       eax, ecx
        sub       eax, esi
        shl       eax, 2        ; 4*length
        stdcall  TextSetGapSize, edx, eax
        stdcall  TextMoveGap, edx, edi
        add      [edx+TText.GapEnd], 5
        sub      ecx, 6

        mov     esi, [edx+TText.GapEnd]
        xor     eax, eax

.url_loop:
        mov     al, [edx+esi]
        cmp     al, $80
        jae     .store_url
        cmp     al, "]"
        je      .end_url

        movzx   ebx, al
        shr     ebx, 5
        and     eax, $1f
        bt      dword [URLCharTable+4*ebx], eax
        mov     al, [edx+esi]
        jnc     .store_url

; encode:
        mov     byte [edx+edi], '%'
        mov     ah, al
        inc     edi
        inc     ecx

        shr     al, 4
        cmp     al, $0a
        sbb     al, $69
        das

        mov     [edx+edi], al
        inc     edi
        inc     ecx

        mov     al, ah
        and     al, $0f
        cmp     al, $0a
        sbb     al, $69
        das

.store_url:
        mov     [edx+edi], al
        inc     esi
        inc     edi
        jmp     .url_loop

.end_url:
        inc     esi
        mov     [edx+TText.GapBegin], edi
        mov     [edx+TText.GapEnd], esi
        dec     ecx
        jmp     .loop


.cmd_json:
; here esi points to ":" of the "[json:" command. edi points to the start "[" and ecx points to the end "]"
        mov       eax, ecx
        sub       eax, esi
        shl       eax, 1        ; 2*length
        stdcall  TextSetGapSize, edx, eax
        stdcall  TextMoveGap, edx, edi
        add      [edx+TText.GapEnd], 6
        sub      ecx, 6

        mov     ebx, ecx
        add     ebx, [edx+TText.GapEnd]
        sub     ebx, [edx+TText.GapBegin]

        mov     esi, [edx+TText.GapEnd]

;        lea     eax, [edx+ebx-4]
;        stdcall OutputMemoryByte, eax, 9
        xor     eax, eax

.json_loop:
        cmp     esi, ebx
        je      .end_json

        mov     al, [edx+esi]

        cmp     al, '"'
        je      .json_enc

        cmp     al, '\'
        je      .json_enc

        cmp     al, '/'
        je      .json_enc

        cmp     al, ' '
        jae     .store_char

        mov     al, [.json_ctrl + eax]
        cmp     al, ' '
        je      .store_char

.json_enc:
        mov     byte [edx+edi], '\'
        inc     edi
        inc     ecx

.store_char:
        mov     [edx+edi], al
        inc     esi
        inc     edi
        jmp     .json_loop

.end_json:
        inc     esi
        mov     [edx+TText.GapBegin], edi
        mov     [edx+TText.GapEnd], esi

        dec     ecx
        jmp     .loop

.json_ctrl db ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '
           db 'b', 't', 'n', ' ', 'f', 'r', ' ', ' '
           db ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '
           db ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '

.cmd_sql:
; here esi points to ":" of the "[sql:" command. edi points to the start "[" and ecx points to the end "]"
        pushad

        stdcall TextMoveGap, edx, ecx

        mov     ebx, [.sepcnt]
        mov     ecx, [.separators + 4*ebx]
        test    ecx, ecx
        cmovs   ecx, [esp+4*regECX]
        inc     esi

        sub     ecx, esi
        jle     .end_sql

        lea     esi, [edx+esi]
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2,[hMainDatabase], esi, ecx, eax, 0
        cmp     eax, SQLITE_OK
        jne     .end_sql

        xor     edi, edi
        mov     [esp+4*regESI], edi

.bind_loop:
        inc     ebx
        inc     edi
        mov     ecx, [.separators + 4*ebx - 4]
        mov     eax, [.separators + 4*ebx]
        test    eax, eax
        cmovs   eax, [esp+4*regECX]

        inc     ecx
        jz      .end_bind

        sub     eax, ecx
        jle     .bind_loop

        add     ecx, [esp+4*regEDX]
        cinvoke sqliteBindText, [.stmt], edi, ecx, eax, SQLITE_STATIC
        cmp     eax, SQLITE_OK
        je      .bind_loop

.end_bind:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finalize_sql

        cinvoke sqliteColumnText, [.stmt], 0
        stdcall StrEncodeHTML, eax
        mov     [esp+4*regESI], eax

.finalize_sql:
        cinvoke sqliteFinalize, [.stmt]

.end_sql:
        popad

        mov     [edx+TText.GapBegin], edi
        inc     [edx+TText.GapEnd]
        lea     ecx, [edi-1]

        test    esi, esi
        jz      .loop

        stdcall TextAddString, edx, edi, esi
        stdcall StrDel, esi
        add     ecx, eax
        jmp     .loop


.cmd_case:
; here esi points to ":" of the "special:" command. edi points to the start "[" and ecx points to the end "]"

        xor     ebx, ebx

.get_case_int:
        inc     esi

        mov     eax, esi
        cmp     esi, [edx+TText.GapBegin]
        jb      @f
        add     eax, [edx+TText.GapEnd]
        sub     eax, [edx+TText.GapBegin]
@@:
        mov     al, [edx+eax]

        cmp     al, ' '
        jbe     .get_case_int

        cmp     al, "0"
        jb      .end_case_int
        cmp     al, "9"
        ja      .end_case_int

        and     eax, $0f
        shl     ebx, 1
        lea     ebx, [4*ebx+ebx]
        add     ebx, eax
        jmp     .get_case_int

.end_case_int:
        cmp     al, '|'
        je      .int_ok

        mov     ebx, [.sepcnt]
        mov     ebx, [.separators+4*ebx]
        sub     ebx, edi
        sub     ebx, 6          ; the length of the value string.

.int_ok:
        mov     eax, [.sepcnt]
        dec     eax
        mov     esi, ecx

.search_sep:
        inc     eax
        cmp     [.separators + 4*eax], -1
        je      .found_sep

        mov     esi, [.separators + 4*eax]
        inc     esi

        dec     ebx
        jns     .search_sep

.found_sep:
        stdcall TextMoveGap, edx, esi
        sub     esi, edi
        sub     [edx+TText.GapBegin], esi
        sub     ecx, esi

; next separator
        push    esi
        mov     esi, [.separators + 4*eax + 4]
        pop     eax
        test    esi, esi
        js      .clean_the_end

        sub     esi, eax
        stdcall TextMoveGap, edx, esi
        sub     esi, ecx
        neg     esi
        add     [edx+TText.GapEnd], esi
        sub     ecx, esi

.clean_the_end:
        stdcall TextMoveGap, edx, ecx
        inc     [edx+TText.GapEnd]
        dec     ecx

;        stdcall TextMoveGap, edx, -1
        jmp     .loop

; ...................................................................
; here esi points to ":" of the "special:" command. edi points to the start "[" and ecx points to the end "]"

.cmd_special:


;        DebugMsg "Special"

        xor     ebx, ebx
        cmp     [.pSpecial], ebx
        je      .loop

.hash2:
        inc     esi
        cmp     esi, ecx
        je      .what_special

        mov     eax, esi
        cmp     esi, [edx+TText.GapBegin]
        jb      @f
        add     eax, [edx+TText.GapEnd]
        sub     eax, [edx+TText.GapBegin]
@@:
        mov     al, [edx+eax]
        mov     ah, al
        and     ah, $40
        shr     ah, 1
        or      al, ah  ; case insensitive hash function.

        xor     bl, al
        mov     bl, [ tpl_func + ebx]

        cmp     al, "="
        je      .what_special

        jmp     .hash2

.what_special:

        mov     eax, [tableSpecial + sizeof.TPHashItem * ebx + TPHashItem.procCommand]
        test    eax, eax
        jz      .unknown_special

        mov     ebx, [.pSpecial]
        jmp     eax

.unknown_special:
        lea     eax, [ecx+1]
        stdcall TextMoveGap, edx, eax
        mov     [edx+TText.GapBegin], edi
        lea     ecx, [edi-1]
        jmp     .loop

; ...................................................................
; here edi points to the start "[" and ecx = esi points to the end "]"

; NOT FINISHED! Needs separate procedure GetEnvironment. An example code is accessible in the old render: render.asm

if defined options.DebugWeb & options.DebugWeb
.sp_environment:
        lea     eax, [ecx+1]
        stdcall TextMoveGap, edx, eax
        mov     [edx+TText.GapBegin], edi
        lea     ecx, [edi-1]
        jmp     .loop
else
  .sp_environment = 0
end if

; ...................................................................
; here edi points to the start "[" and ecx = esi points to the end "]"

.sp_username:

        mov     eax, [ebx+TSpecialParams.userName]

.special_string:
        stdcall TextMoveGap, edx, edi

        test    eax, eax
        jz      .string_ok

        stdcall TextAddString, edx, edi, eax

.string_ok:
        sub     esi, edi
        inc     esi

        add     [edx+TText.GapEnd], esi
        sub     ecx, esi
        add     ecx, eax

        jmp     .loop

.sp_title:
        mov     eax, [ebx+TSpecialParams.page_title]
        jmp     .special_string

.sp_header:
        mov     eax, [ebx+TSpecialParams.page_header]
        jmp     .special_string

.sp_description:
        mov     eax, [ebx+TSpecialParams.description]
        jmp     .special_string

.sp_keywords:
        mov     eax, [ebx+TSpecialParams.keywords]
        jmp     .special_string

.sp_thread:
        mov     eax, [ebx+TSpecialParams.thread]
        jmp     .special_string

.sp_dir:
        mov     eax, [ebx+TSpecialParams.dir]
        jmp     .special_string

.sp_skin:
        mov     eax, [ebx+TSpecialParams.userSkin]
        jmp     .special_string

.sp_skincookie:
        xor     eax, eax
        stdcall GetCookieValue, [ebx+TSpecialParams.params], txt "skin"
        jmp     .special_string_free

.sp_version:
        mov     eax, cVersion
        jmp     .special_string

; ...................................................................

.sp_userid:

        mov     eax, [ebx+TSpecialParams.userID]

.special_int:

        stdcall NumToStr, eax, ntsDec

.special_string_free:

        stdcall TextMoveGap, edx, edi

        test    eax, eax
        jz      .string_free_ok

        push    eax
        stdcall TextAddString, edx, edi, eax
        stdcall StrDel ; from the stack

.string_free_ok:
        sub     esi, edi
        inc     esi

        add     [edx+TText.GapEnd], esi
        sub     ecx, esi
        add     ecx, eax

        jmp     .loop

.sp_cmdtype:
        mov     eax, [ebx+TSpecialParams.cmd_type]
        jmp     .special_int

.sp_page:
        mov     eax, [ebx+TSpecialParams.page_num]
        jmp     .special_int

.sp_setupmode:
        mov     eax, [ebx+TSpecialParams.setupmode]
        jmp     .special_int

.sp_permissions:
        mov     eax, [ebx+TSpecialParams.userStatus]
        jmp     .special_int


.sp_timestamp:

        stdcall GetFineTimestamp
        sub     eax, [ebx+TSpecialParams.start_time]

        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        mov     ebx, eax

        stdcall StrLen, eax
        sub     eax, 3
        jg      .point_ok

        neg     eax
        inc     eax

.zero_loop:
        stdcall StrCharInsert, ebx, "0", 0
        dec     eax
        jnz     .zero_loop

        inc     eax

.point_ok:
        stdcall StrCharInsert, ebx, ".", eax
        mov     eax, ebx
        jmp     .special_string_free

; ...................................................................

.sp_visitors:

        stdcall UsersOnline
        jmp     .special_string_free

.sp_referer:
        stdcall GetBackLink, [.pSpecial]
        jmp     .special_string_free

.sp_search:
        stdcall GetQueryParam, [.pSpecial], txt "s="
        jmp     .special_string_free

.sp_sort:
        stdcall GetQueryParam, [.pSpecial], txt "sort="
        jmp     .special_string_free

.sp_usearch:
        stdcall GetQueryParam, [.pSpecial], txt "u="
        jmp     .special_string_free

; ...................................................................

.sp_isadmin:
        mov     eax, permAdmin

.one_permission:
        and     eax, [ebx+TSpecialParams.userStatus]
        cmovz   eax, [.cBoolean]
        cmovnz  eax, [.cBoolean+4]
        jmp     .special_string

.sp_canlogin:
        mov     eax, permLogin
        jmp     .one_permission

.sp_canpost:
        mov     eax, permPost
        jmp     .one_permission

.sp_canstart:
        mov     eax, permThreadStart
        jmp     .one_permission

.sp_canupload:
        mov     eax, permAttach
        jmp     .one_permission

.sp_canchat:
        stdcall ChatPermissions, [.pSpecial]
        cmovc   eax, [.cBoolean]
        cmovnc  eax, [.cBoolean+4]
        jmp     .special_string

locals
  .permOwn dd ?
  .permAll dd ?
endl

.sp_canedit:
        mov     [.permOwn], permEditOwn
        mov     [.permAll], permEditAll or permAdmin

.complex_permission:

        mov     eax, [ebx+TSpecialParams.userStatus]
        and     eax, [.permAll]
        cmovnz  eax, [.cBoolean+4]      ; 1
        jnz     .special_string

        mov     eax, [.cBoolean]        ; 0
        cmp     [.sqlite_statement], 0
        je      .special_string

        cmp     [.tblFields.pName + sizeof.TFieldSlot * useridHash], 0  ; userid field existence
        je      .special_string

        push    eax ecx edx
        cinvoke sqliteColumnInt, [.sqlite_statement], [.tblFields.Index + sizeof.TFieldSlot * useridHash]
        cmp     eax, [ebx+TSpecialParams.userID]
        pop     edx ecx eax
        jne     .special_string

        mov     eax, [ebx+TSpecialParams.userStatus]
        and     eax, [.permOwn]
        cmovz   eax, [.cBoolean]
        cmovnz  eax, [.cBoolean+4]
        jmp     .special_string


.sp_candelete:
        mov     [.permOwn], permDelOwn
        mov     [.permAll], permDelAll or permAdmin
        jmp     .complex_permission



.cBoolean     dd .cStringFALSE, .cStringTRUE
.cStringFALSE db "0", 0, 0, 0
.cStringTRUE  db "1", 0, 0, 0


; ...................................................................

.sp_allstyles:
        push    ebx ecx edx esi edi

        mov     esi, ebx

        mov     ebx, [esi+TSpecialParams.pStyles]
        xor     ecx, ecx

        stdcall TextCreate, sizeof.TText
        mov     edx, eax

        stdcall GetParam, 'embeded_css', gpInteger
        jc      .external_css

        test    eax, eax
        jz      .external_css

;.embeded_css:

        stdcall TextCat, edx, txt '<style>'

.loop_styles:
        cmp     ecx, [ebx+TArray.count]
        jae     .end_styles2

        stdcall RenderTemplate, edx, [ebx+TArray.array+4*ecx], 0, esi
        mov     edx, eax

        inc     ecx
        jmp     .loop_styles

.end_styles2:

        stdcall TextCat, edx, '</style>'

.end_styles:
        mov     eax, edx

        pop     edi esi edx ecx ebx

.special_ttext:
        push    eax
        stdcall TextAddText, edx, edi, eax
        stdcall TextFree ; from the stack

        sub     esi, edi
        inc     esi

        add     [edx+TText.GapEnd], esi
        sub     ecx, esi
        add     ecx, eax

        jmp     .loop


.external_css:
        cmp     ecx, [ebx+TArray.count]
        jae     .end_styles

        stdcall TextCat, edx, '<link rel="stylesheet" href="'
        stdcall TextCat, edx, [esi+TSpecialParams.userSkin]
        stdcall TextCat, edx, txt '/'
        stdcall TextCat, edx, [ebx+TArray.array+4*ecx]
        stdcall TextCat, edx, txt '?skin='
        stdcall TextCat, edx, [esi+TSpecialParams.userSkin]
        stdcall TextCat, edx, <txt '" type="text/css">', 13, 10>

        inc     ecx
        jmp     .external_css


.sp_alltags:
        stdcall GetAllTags, [.pSpecial]
        jmp     .special_ttext


.sp_stats:
        stdcall Statistics, [.pSpecial]
        jmp     .special_ttext

.sp_skins:
; here esi points to the "=" char, ecx at the end "]" and edi at the start "["
        stdcall TextMoveGap, edx, ecx
        call    .clip_and_copy
        mov     esi, ecx
        stdcall GetAllSkins, eax
        jmp     .special_ttext


.sp_posters:
; here esi points to the "=" char, ecx at the end "]" and edi at the start "["
        call    .get_number
        stdcall GetPosters, ebx
        jmp     .special_string_free

.sp_invited:
; here esi points to the "=" char, ecx at the end "]" and edi at the start "["
        call    .get_number
        stdcall GetInvited, ebx
        jmp     .special_string_free

.sp_threadtags:
; here esi points to the "=" char, ecx at the end "]" and edi at the start "["
        call    .get_number
        stdcall GetThreadTags, ebx
        jmp     .special_string_free


.finish:
        cmp     dword [esp], -1
        jne     .exit
        add     esp, 4
        jmp     .finish

.exit:
        mov     [esp+4*regEAX], edx
        popad
        return



; ...................................................................

.build_hash_table:
        pushad
        xor     ecx, ecx

.col_loop:
        push    ecx
        cinvoke sqliteColumnName, [.sqlite_statement], ecx
        pop     ecx
        test    eax, eax
        jz      .end_cols

        mov     esi, eax
        mov     ebx, eax

        xor     edx, edx
        mov     edi, tpl_func

.loop_hash:
        lodsb
        test    al, al
        jz      .end_name

        mov     ah, al
        and     ah, $40
        shr     ah, 1
        or      al, ah

        xor     dl, al
        mov     dl, [edi+edx]
        jmp     .loop_hash

.end_name:
        mov     eax, ecx

.empty_slot:
        xchg    ebx, [.tblFields.pName + 8*edx]     ; the name address
        xchg    eax, [.tblFields.Index + 8*edx]     ; the field index

        inc     dl
        test    ebx, ebx
        jnz     .collision

        inc     ecx
        jmp     .col_loop

.collision:
        OutputLn  ebx
        OutputValue "Collision on field #", eax, 10, -1
        jmp         .empty_slot


.end_cols:

        popad
        retn


.get_number:
        xor     ebx, ebx
        xor     eax, eax

.num_loop:
        inc     esi
        cmp     esi, ecx
        je      .end_num

        mov     eax, esi
        cmp     esi, [edx+TText.GapBegin]
        jb      @f
        add     eax, [edx+TText.GapEnd]
        sub     eax, [edx+TText.GapBegin]
@@:

        movzx   eax, byte [edx+eax]
        cmp     al, ' '
        jbe     .num_loop

        shl     ebx, 1
        and     al, $0f
        lea     ebx, [5*ebx]
        add     ebx, eax
        jmp     .num_loop

.end_num:
        retn


; here ecx points one char after the string, esi points one character before the string.
; destroys esi!!! preserves ecx
; returns string in eax

.clip_and_copy:

        push    ecx

.left_clip:
        inc     esi
        cmp     esi, ecx
        je      .end_clip

        cmp     byte [edx+esi], ' '
        jbe     .left_clip

.right_clip:
        dec     ecx
        cmp     ecx, esi
        je      .end_clip

        cmp     byte [edx+ecx], ' '
        jbe     .right_clip

        inc     ecx

.end_clip:
        stdcall StrNew
        sub     ecx, esi
        jz      .end_copy
        stdcall StrCopyPart, eax, edx, esi, ecx

.end_copy:
        pop     ecx
        retn

endp






proc ListAddDistinct, .pList, .hString
begin
        pushad

        mov     ebx, [.hString]
        mov     edx, [.pList]
        mov     ecx, [edx+TArray.count]

.loop:
        dec     ecx
        js      .not_found

        stdcall StrCompCase, [edx+TArray.array+4*ecx], ebx
        jnc     .loop

        stdcall StrDel, ebx

.finish:
        mov     [esp+4*regEDX], edx
        popad
        return

.not_found:
        stdcall AddArrayItems, edx, 1
        mov     [eax], ebx
        jmp     .finish
endp



;sqlGetMaxTagUsed text "select max(cnt) from (select count(*) as cnt from ThreadTags group by tag)"
;sqlGetAllTags    text "select TT.tag, count(TT.tag) as cnt, T.Description from ThreadTags TT left join Tags T on TT.tag=T.tag group by TT.tag order by TT.tag"
sqlGetMaxTagUsed text "select max(cnt) from (select (select count() from ThreadTags TT where TT.tag = T.tag) as cnt from tags T where importance > -1)"
;sqlGetAllTags    text "select TT.tag, count(TT.tag) as cnt, T.Description from ThreadTags TT left join Tags T on TT.tag=T.tag where T.Importance >= 0 group by TT.tag order by TT.tag"
sqlGetAllTags    text "select T.Tag, (select count() from threadtags where Tag = T.tag) as cnt, T.Description from Tags T where T.Importance > -1 order by T.Tag"

proc GetAllTags, .pSpecial
  .max   dd ?
  .cnt   dd ?
  .stmt  dd ?
begin
        pushad

        mov     esi, [.pSpecial]

        stdcall TextCreate, sizeof.TText
        mov     ebx, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetMaxTagUsed, sqlGetMaxTagUsed.length, eax, 0
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .end_tags

        cinvoke sqliteColumnInt, [.stmt], 0
        test    eax, eax
        jz      .end_tags

        mov     [.max], eax

        cinvoke sqliteFinalize, [.stmt]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetAllTags, sqlGetAllTags.length, eax, 0

.tag_loop:
        cinvoke sqliteStep, [.stmt]

        cmp     eax, SQLITE_ROW
        jne     .end_tags

        cinvoke sqliteColumnInt, [.stmt], 1     ; the count used
        mov     [.cnt], eax
        mov     ecx, 32
        mul     ecx
        div     [.max]
        test    eax, eax
        jz      .tag_loop

        cmp     eax, ecx          ;
        cmova   eax, ecx          ; should never happen!
        push    eax     ; from 1 to 32

        stdcall TextCat, ebx, txt  '<a class="taglink tagsize'
        mov     ebx, edx

        pop     eax
        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        stdcall TextCat, ebx, eax
        stdcall StrDel, eax
        mov     ebx, edx

        cmp     [esi+TSpecialParams.dir], 0
        je      .current_ok

        cinvoke sqliteColumnText, [.stmt], 0
        stdcall StrCompNoCase, eax, [esi+TSpecialParams.dir]
        jnc     .current_ok

        stdcall TextCat, ebx, txt ' current_tag'
        mov     ebx, edx

.current_ok:

        stdcall TextCat, ebx, txt '" title="'
        mov     ebx, edx

        cinvoke sqliteColumnText, [.stmt], 0
        stdcall StrEncodeHTML, eax
        mov     edi, eax

        stdcall TextCat, ebx, txt "["   ;"«"
        stdcall TextCat, edx, edi
        stdcall TextCat, edx, txt "]: " ;"»: "
        mov     ebx, edx

        cinvoke sqliteColumnText, [.stmt], 2
        test    eax, eax
        jz      .title_ok

        stdcall StrEncodeHTML, eax
        stdcall TextCat, ebx, eax
        stdcall TextCat, edx, txt "; "
        mov     ebx, edx
        stdcall StrDel, eax

.title_ok:

        stdcall NumToStr, [.cnt], ntsDec or ntsUnsigned
        stdcall TextCat, ebx, eax
        stdcall StrDel, eax

        stdcall TextCat, edx, txt ' thread'
        cmp     [.cnt], 1
        je      .plural_ok

        stdcall TextCat, edx, txt 's'

.plural_ok:
        stdcall TextCat, edx, txt '." href="/'
        stdcall TextCat, edx, edi
        stdcall TextCat, edx, txt '/">'
        stdcall TextCat, edx, edi
        stdcall TextCat, edx, <txt '</a>', 13, 10>
        mov     ebx, edx

        stdcall StrDel, edi
        jmp     .tag_loop


.end_tags:
        cinvoke sqliteFinalize, [.stmt]
        mov     [esp+4*regEAX], ebx
        popad
        return
endp




proc TextCat, .pText, .hString
begin
        push    eax
        stdcall TextAddStr2, [.pText], -1, [.hString], 256
        pop     eax
        return
endp


proc TextIns, .pText, .hString
begin
        push    eax
        mov     edx, [.pText]
        stdcall TextAddStr2, edx, [edx+TText.GapBegin], [.hString], 256
        pop     eax
        return
endp


proc FormatPostText, .ptrMinimag

.result TMarkdownResults

begin
        lea     eax, [.result]
        stdcall TranslateMarkdown2, [.ptrMinimag], FixMiniMagLink, 0, eax, 0

        stdcall StrDel, [.result.hIndex]
        stdcall StrDel, [.result.hKeywords]
        stdcall StrDel, [.result.hDescription]

        mov     eax, [.result.hContent]
        return
endp


proc FormatPostText2, .hMinimag, .pSpecial
begin
        pushad
        mov     edi, [.pSpecial]

        stdcall StrDup, [.hMinimag]
        mov     ebx, eax

        stdcall StrDup, [hCurrentDir]
        stdcall StrCat, eax, [edi+TSpecialParams.userSkin]
        stdcall StrCat, eax, "/minimag_suffix.tpl"
        push    eax
        stdcall LoadBinaryFile, eax
        stdcall StrDel ; from the stack
        jc      .suffix_ok

        push    eax
        stdcall StrCat, ebx, eax
        stdcall FreeMem ; from the stack

.suffix_ok:
        stdcall FormatPostText, ebx
        mov     [esp+4*regEAX], eax

        stdcall StrDel, ebx
        popad
        return
endp



proc FixMiniMagLink, .ptrLink, .ptrBuffer, .lParam
begin
        pushad

        mov     edi, [.ptrBuffer]
        mov     esi, [.ptrLink]

        cmp     byte [esi], '#'
        je      .finish         ; it is internal link

.start_loop:
        lodsb
        cmp     al, $0d
        je      .not_absolute
        cmp     al, $0a
        je      .not_absolute
        cmp     al, ']'
        je      .not_absolute
        test    al,al
        jz      .not_absolute

        cmp     al, 'A'
        jb      .found
        cmp     al, 'Z'
        jbe     .start_loop

        cmp     al, 'a'
        jb      .found
        cmp     al, 'z'
        jb      .start_loop

.found:
        cmp     al, ':'
        jne     .not_absolute

        mov     ecx, [.ptrLink]
        sub     ecx, esi

        cmp     ecx, -11
        jne     .not_js

        cmp     dword [esi+ecx], "java"
        jne     .not_js

        cmp     dword [esi+ecx+4], "scri"
        jne     .not_js

        cmp     word [esi+ecx+8], "pt"
        jne     .not_js

.add_https:
        mov     dword [edi], "http"
        mov     dword [edi+4], "s://"
        lea     edi, [edi+8]
        jmp     .protocol_ok

.not_js:
        cmp     dword [esi+ecx], "http"         ; ECX < 0 here!!!
        jne     .add_https

.not_absolute:
.protocol_ok:
        mov     esi, [.ptrLink]

; it is absolute URL, exit
.finish:
        mov     [esp+4*regEAX], edi     ; return where to copy the remaining of the address. Destination!
        mov     [esp+4*regEDX], esi     ; return from where to copy the remaining of the address. Source!

        popad
        return
endp







;sqlGetThreadPosters  text "select (select nick from users where id = P.userid) from Posts P where P.threadID = ?1 order by P.id limit 20;"
; sqlGetThreadPosters  text "select nick from users where id in (select distinct userid from Posts P where P.threadID = ?1)"

sqlGetThreadStarter  text "select u.id, nick from posts p left join users u on p.userid = u.id where p.threadid = ?1 order by p.id"
sqlGetThreadPosters  text "select id, nick from (select distinct userid from posts where threadid = ?1) left join Users on id = userid"

proc GetPosters, .threadID
  .stmt  dd ?
  .starter dd ?
begin
        pushad

        stdcall StrNew
        mov     ebx, eax

; read the thread starter:

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadStarter, sqlGetThreadStarter.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .end_thread_posters

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     [.starter], eax

        call    .adduser
        cinvoke sqliteFinalize, [.stmt]

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadPosters, sqlGetThreadPosters.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]

.thread_posters_loop:

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .end_thread_posters

        cinvoke sqliteColumnInt, [.stmt], 0
        cmp     eax, [.starter]
        je      .thread_posters_loop

        call    .adduser

        jmp     .thread_posters_loop

.end_thread_posters:

        cinvoke sqliteFinalize, [.stmt]
        mov     [esp+4*regEAX], ebx
        popad
        return

.adduser:
        cinvoke sqliteColumnText, [.stmt], 1
        stdcall StrEncodeHTML, eax
        mov     ecx, eax
        stdcall StrURLEncode, eax

        stdcall StrCat, ebx, '<a href="/!userinfo/'
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCat, ebx, txt '">'
        stdcall StrCat, ebx, ecx
        stdcall StrDel, ecx
        stdcall StrCat, ebx, txt '</a>'
        retn

endp



sqlGetThreadInvited text "select u.nick from LimitedAccessThreads LT left join Users U on U.id = LT.userid where threadID = ?1 order by U.nick;"

proc GetInvited, .threadID
  .stmt  dd ?
begin
        pushad

        stdcall StrNew
        mov     ebx, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadInvited, sqlGetThreadInvited.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]

.fetch:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finalize

        stdcall StrCat, ebx, '<a href="/!userinfo/'

        cinvoke sqliteColumnText, [.stmt], 0
        stdcall StrEncodeHTML, eax
        mov     ecx, eax
        stdcall StrURLEncode, eax

        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCat, ebx, txt '">'
        stdcall StrCat, ebx, ecx
        stdcall StrCat, ebx, txt '</a>'
        stdcall StrDel, ecx
        jmp     .fetch

.finalize:
        cinvoke sqliteFinalize, [.stmt]
        mov     [esp+4*regEAX], ebx
        popad
        return
endp



;sqlStatistics StripText "statistics.sql", SQL
;
;proc Statistics, .pSpecial
;.stmt dd ?
;begin
;        pushad
;
;        stdcall TextCreate, sizeof.TText
;        mov     edi, eax
;
;        lea     eax, [.stmt]
;        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlStatistics, sqlStatistics.length, eax, 0
;
;        cinvoke sqliteStep, [.stmt]
;        cmp     eax, SQLITE_ROW
;        jne     .end_loop
;
;        stdcall RenderTemplate, edi, "../../www/templates/Wasp/statistics.tpl", [.stmt], [.pSpecial]
;        mov     edi, eax
;
;.end_loop:
;        cinvoke sqliteFinalize, [.stmt]
;        mov     [esp+4*regEAX], edi
;        popad
;        return
;endp
;
;




proc GetAllSkins, .hCurrent
begin
        pushad

        stdcall TextCreate, sizeof.TText
        mov     edx, eax

        stdcall StrDup, [hCurrentDir]
        stdcall StrCat, eax, "/templates/"
        push    eax

        stdcall DirectoryRead, eax

        stdcall StrDel ; from the stack.
        jc      .finish_skins

        mov     edi, eax
        stdcall SortDirArray, edi, fdsByType

        mov     ecx, [edi+TArray.count]


.dir_loop:
        dec     ecx
        js      .end_of_dir

        cmp     [edi+TArray.array+8*ecx+TDirItem.Type], ftDirectory
        jne     .next_file

        stdcall StrPtr, [edi+TArray.array+8*ecx+TDirItem.hFilename]
        jc      .next_file

        cmp     byte [eax], '_'
        je      .next_file

        cmp     byte [eax], '.'
        je      .next_file

        stdcall TextCat, edx, txt '<option value="'
        stdcall TextCat, edx, [edi+TArray.array+8*ecx+TDirItem.hFilename]
        stdcall TextCat, edx, txt '" '

        stdcall StrCompCase, [edi+TArray.array+8*ecx+TDirItem.hFilename], [.hCurrent]
        jnc     .selected_ok

        stdcall TextCat, edx, txt ' selected="selected"'

.selected_ok:
        stdcall TextCat, edx, txt '>'
        stdcall TextCat, edx, [edi+TArray.array+8*ecx+TDirItem.hFilename]
        stdcall TextCat, edx, <txt '</option>', 13, 10>

.next_file:
        stdcall StrDel, [edi+TArray.array+8*ecx+TDirItem.hFilename]
        jmp     .dir_loop

.end_of_dir:

        stdcall FreeMem, edi

.finish_skins:

        stdcall StrDel, [.hCurrent]
        mov     [esp+4*regEAX], edx
        popad
        return
endp



sqlGetThreadTags    text "select TT.tag, (select T.description from Tags T where T.tag = TT.tag) from ThreadTags TT where TT.threadID=?1"
;sqlGetThreadTags    text "select TT.tag, T.Description from ThreadTags TT left join Tags T on TT.tag=T.tag where TT.threadID=? order by TT.tag"

proc GetThreadTags, .threadID
.stmt dd ?
begin
        pushad

        stdcall StrNew
        mov     ebx, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadTags, sqlGetAllTags.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]

.thread_tag_loop:

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .end_thread_tags

        stdcall StrCat, ebx, txt '<a '

        cinvoke sqliteColumnText, [.stmt], 1
        test    eax, eax
        jz      .link_title_ok

        stdcall StrEncodeHTML, eax

        stdcall StrCat, ebx, txt 'title="'
        stdcall StrCat, ebx, eax
        stdcall StrCat, ebx, txt '" '
        stdcall StrDel, eax

.link_title_ok:

        stdcall StrCat, ebx, 'href="/'

        cinvoke sqliteColumnText, [.stmt], 0
        stdcall StrEncodeHTML, eax

        stdcall StrCat, ebx, eax
        stdcall StrCat, ebx, txt '/">'
        stdcall StrCat, ebx, eax
        stdcall StrCat, ebx, txt '</a>'
        stdcall StrDel, eax

        jmp     .thread_tag_loop

.end_thread_tags:

        cinvoke sqliteFinalize, [.stmt]

.end_thread_tags2:
        mov     [esp+4*regEAX], ebx
        popad
        return
endp







proc StrSlugify, .hString
begin
        stdcall Utf8ToAnsi, [.hString], KOI8R
        push    eax
        stdcall StrCyrillicFix, eax
        stdcall StrDel ; from the stack

        stdcall StrMaskBytes, eax, $0, $7f
        stdcall StrLCase2, eax

        stdcall StrConvertWhiteSpace, eax, " "
        stdcall StrConvertPunctuation, eax

        stdcall StrCleanDupSpaces, eax
        stdcall StrClipSpacesR, eax
        stdcall StrClipSpacesL, eax

        stdcall StrConvertWhiteSpace, eax, "-"          ; according to google rules.

        return
endp



proc StrTagify, .hString
begin
        pushad

        mov     ebx, [.hString]

        stdcall StrConvertWhiteSpace, ebx, " "
        stdcall StrConvertPunctuation, ebx

        stdcall StrCleanDupSpaces, ebx
        stdcall StrClipSpacesR, ebx
        stdcall StrClipSpacesL, ebx

        stdcall StrByteUtf8, ebx, 16

        stdcall StrTrim, ebx, eax

        stdcall StrClipSpacesR, ebx
        stdcall StrClipSpacesL, ebx

        stdcall StrConvertWhiteSpace, ebx, "."        ; google don't like underscores.

        popad
        return
endp



proc StrConvertWhiteSpace, .hString, .toChar
begin
        pushad

        stdcall StrLen, [.hString]
        mov     ecx, eax
        jecxz   .finish

        stdcall StrPtr, [.hString]
        mov     esi, eax

        mov     edx, [.toChar]

.loop:
        mov     al, [esi]
        cmp     al, " "
        ja      .next

        mov     [esi], dl

.next:
        inc     esi
        loop    .loop

.finish:
        popad
        return
endp


proc StrConvertPunctuation, .hString
begin
        pushad

        stdcall StrLen, [.hString]
        mov     ecx, eax
        jecxz   .finish

        stdcall StrPtr, [.hString]
        mov     esi, eax

.loop:
        mov     al, [esi]
        cmp     al, $80         ; unicode
        jae     .next
        cmp     al, '_'
        je      .next
        cmp     al, '-'
        je      .next

        or      al, $20
        cmp     al, "a"
        jb      .not_letter
        cmp     al, "z"
        jbe     .next

.not_letter:
        cmp     al, "0"
        jb      .convert
        cmp     al, "9"
        jbe     .next

.convert:
        mov     byte [esi], " "

.next:
        inc     esi
        loop    .loop

.finish:
        popad
        return
endp



proc StrMaskBytes, .hString, .orMask, .andMask
begin
        pushad

        stdcall StrLen, [.hString]
        mov     ecx, eax
        jecxz   .finish

        stdcall StrPtr, [.hString]
        mov     esi, eax

        mov     dl, byte [.orMask]
        mov     dh, byte [.andMask]

.loop:
        mov     al, [esi]
        or      al, dl
        and     al, dh
        mov     [esi], al
        inc     esi
        loop    .loop

.finish:
        popad
        return
endp




proc StrCyrillicFix, .hString
begin
        pushad

        stdcall StrNew
        mov     edi, eax

        stdcall StrPtr, [.hString]
        mov     esi, eax

.loop:
        movzx   eax, byte [esi]
        inc     esi

        test    al, al
        jz      .finish

        mov     ebx, eax

        cmp     bl, $e0
        jb      .less

        sub     bl, $20

.less:
        cmp     bl, $c0
        jb      .cat

        sub     bl, $db
        and     bl, $1f
        cmp     bl, 5
        ja      .cat

        mov     eax, [.table+4*ebx]

.cat:
        stdcall StrCharCat, edi, eax
        jmp     .loop


.finish:
        mov     [esp+4*regEAX], edi
        popad
        return

.table  dd      "sh"    ; sh
        dd      "e"
        dd      "sht"
        dd      "ch"
        dd      "a"
        dd      "yu"

endp



; returns the redirect TText in EDI

proc TextMakeRedirect, .pText, .hWhere
begin
        push    eax edx

        mov     edx, [.pText]
        test    edx, edx
        jnz     @f

        stdcall TextCreate, sizeof.TText
        mov     edx, eax

@@:
        stdcall TextAddStr2,  edx, 0, <"Status: 302 Found", 13, 10>, 256
        stdcall TextMoveGap, edx, -1

        mov     eax, [edx+TText.GapBegin]

        sub     eax, 2
        cmp     word [edx+eax], $0a0d
        je      @f

        stdcall TextCat, edx, <txt 13, 10>

@@:
        stdcall TextCat, edx, "Location: "
        stdcall TextCat, edx, [.hWhere]
        stdcall TextCat, edx, <txt 13, 10, 13, 10>

        mov     edi, edx
        pop     edx eax
        return
endp






proc GetBackLink, .pSpecial
begin
        pushad

        mov     esi, [.pSpecial]


        stdcall ValueByName, [esi+TSpecialParams.params], "HTTP_REFERER"
        jc      .root

        mov     ebx, eax

        stdcall ValueByName, [esi+TSpecialParams.params], "HTTP_HOST"
        jc      .root

        push    eax

        stdcall StrLen, eax
        mov     ecx, eax

        stdcall StrPos, ebx     ; pattern from the stack
        test    eax, eax
        jz      .root

        add     ecx, eax

        stdcall StrMatchPatternNoCase, "/!message/*", ecx
        jc      .root

        stdcall StrMatchPatternNoCase, "/!sqlite*", ecx
        jc      .root

        stdcall StrMatchPatternNoCase, "*/!post*", ecx
        jc      .root

        stdcall StrMatchPatternNoCase, "/!register*", ecx
        jc      .root

        stdcall StrMatchPatternNoCase, "*/!edit/*", ecx
        cmp     eax, ecx
        je      .root

        stdcall StrDupMem, ecx
        clc
        jmp     .finish

.root:
        stdcall StrDupMem, txt "/"
        stc

.finish:
        pushf
        push    eax
        stdcall StrEncodeHTML, eax
        stdcall StrDel ; from the stack
        popf

        mov     [esp+4*regEAX], eax
        popad
        return
endp




sqlSelectAllPosts text "select id, content from Posts where rendered is null limit 1000"
sqlUpdateHTML     text "update Posts set Rendered = ?1 where id = ?2"

proc RenderAll, .pSpecial
.stmt dd ?
.stmt2 dd ?
begin
        pushad

        mov     esi, [.pSpecial]

        test    [esi+TSpecialParams.userStatus], permAdmin
        jz      .for_admins_only

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlSelectAllPosts, -1, eax, 0

        lea     eax, [.stmt2]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateHTML, -1, eax, 0

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax

        cinvoke sqliteColumnText, [.stmt], 1

        stdcall FormatPostText2, eax, esi
        mov     edi, eax

        cinvoke sqliteBindInt, [.stmt2], 2, ebx

        stdcall StrPtr, edi
        cinvoke sqliteBindText, [.stmt2], 1, eax, [eax+string.len], SQLITE_STATIC

        cinvoke sqliteStep, [.stmt2]
        cinvoke sqliteReset, [.stmt2]

        stdcall StrDel, edi

        jmp     .loop

.finish:
        cinvoke sqliteFinalize, [.stmt2]
        cinvoke sqliteFinalize, [.stmt]

.finish2:
        stdcall GetBackLink, esi
        push    eax

        stdcall TextMakeRedirect, 0, eax
        stdcall StrDel ; from the stack

.exit:
        mov     [esp+4*regEAX], edi
        stc
        popad
        return

.for_admins_only:

        stdcall TextMakeRedirect, 0, "/!message/only_for_admins"
        stc
        jmp     .exit
endp



cDefaultSkin       text "Wasp"
cDefaultMobileSkin text "mobile"

proc GetDefaultSkin, .pSpecial
begin
        pushad

        mov     esi, [.pSpecial]
        stdcall StrDupMem, "/templates/"
        mov     ebx, eax

        test    esi, esi
        jz      .desktop

        stdcall GetCookieValue, [esi+TSpecialParams.params], txt "skin"
        jnc     .found_cookie

.by_user_agent:
        stdcall ValueByName, [esi+TSpecialParams.params], "HTTP_USER_AGENT"
        jc      .desktop

        stdcall StrMatchPattern, txt "*Mobi*", eax
        jc      .mobile

.desktop:
        stdcall GetParam, txt "default_skin", gpString
        jnc     .found

        stdcall StrDupMem, cDefaultSkin
        jmp     .found

.mobile:
        stdcall GetParam, txt "default_mobile_skin", gpString
        jnc     .found

        stdcall StrDupMem, cDefaultMobileSkin

.found:
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

        mov     [esp+4*regEAX], ebx
        popad
        return

.found_cookie:
        mov     edx, eax

        stdcall StrDup, [hCurrentDir]
        stdcall StrCat, eax, "/templates/"
        push    eax
        stdcall StrCat, eax, edx
        stdcall StrCat, eax, SKIN_CHECK_FILE

        stdcall FileExists, eax
        stdcall StrDel ; from the stack
        mov     eax, edx
        jnc     .found

        stdcall StrDel, eax
        jmp     .by_user_agent

endp



proc GetQueryParam, .pSpecial, .param
begin
        push    esi
        mov     esi, [.pSpecial]

        xor     eax, eax
        stdcall ValueByName, [esi+TSpecialParams.params], "QUERY_STRING"
        jc      .finish

        stdcall GetQueryItem, eax, [.param], 0
        test    eax, eax
        jz      .finish

        push    eax
        stdcall StrEncodeHTML, eax
        stdcall StrDel ; from the stack
        clc

.finish:
        pop     esi
        return
endp



; Later can be made to compose KB/MB/GB suffixes.

proc FormatFileSize, .size
begin
        stdcall NumToStr, [.size], ntsDec or ntsUnsigned
        stdcall StrCat, eax, txt " bytes"
        return
endp
