
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


PHashTable tableRenderCmd, tpl_func,                      \
        'special:',     RenderTemplate.cmd_special,       \
        'raw:',         RenderTemplate.cmd_raw,           \
        'include:',     RenderTemplate.cmd_include,       \
        'minimag:',     RenderTemplate.cmd_minimag,       \   ; HTML, no encoding.
        'bbcode:',      RenderTemplate.cmd_bbcode,        \   ; HTML, no encoding.
        'html:',        RenderTemplate.cmd_html,          \   ; HTML, disables the encoding.
        'attachments:', RenderTemplate.cmd_attachments,   \   ; HTML, no encoding.
        'attach_edit:', RenderTemplate.cmd_attachedit,    \   ; HTML, no encoding.
        'url:',         RenderTemplate.cmd_url,           \   ; Needs encoding!
        'json:',        RenderTemplate.cmd_json,          \   ; No encoding.
        'css:',         RenderTemplate.cmd_css,           \   ; No output, no encoding.
        'equ:',         RenderTemplate.cmd_equ,           \
        'const:',       RenderTemplate.cmd_const,         \
        'enc:',         RenderTemplate.cmd_encode,        \   ; encode the content in html encoding.
        'usr:',         RenderTemplate.cmd_user_encode    \   ; encodes the unicode content of the user nickname for unicode-clones distinction.

PHashTable tableSpecial, tpl_func,                              \
        "visitors",    RenderTemplate.sp_visitors,              \ ; HTML no encoding
        "version",     RenderTemplate.sp_version,               \ ; no encoding
        "sqliteversion", RenderTemplate.sp_sqlite_version,      \ ; no encoding
        "cmdtype",     RenderTemplate.sp_cmdtype,               \ ; 0/1/2 no encoding
        "stats",       RenderTemplate.sp_stats,                 \ ; HTML no encoding
        "timestamp",   RenderTemplate.sp_timestamp,             \ ; NUMBER no encoding
        "title",       RenderTemplate.sp_title,                 \ ; Controlled source, no encoding
        "header",      RenderTemplate.sp_header,                \ ; Controlled source, no encoding
        "tagprefix",   RenderTemplate.sp_tagprefix,             \ ; for the Atom feed ID use
        "hostroot",    RenderTemplate.sp_hostroot,              \
        "allstyles",   RenderTemplate.sp_allstyles,             \ ; CSS, from controlled source, no encoding.
        "description", RenderTemplate.sp_description,           \ ; Controlled source, no encoding
        "keywords",    RenderTemplate.sp_keywords,              \ ; Controlled source, no encoding
        "username",    RenderTemplate.sp_username,              \ ; Needs encoding!
        "userid",      RenderTemplate.sp_userid,                \ ; NUMBER, no encoding.
        "skin",        RenderTemplate.sp_skin,                  \ ; Controlled source, no encoding???
        "lang",        RenderTemplate.sp_lang,                  \
        "skincookie",  RenderTemplate.sp_skincookie,            \
        "page",        RenderTemplate.sp_page,                  \ ; Number, no encoding.
        "dir",         RenderTemplate.sp_dir,                   \ ; Needs encoding!
        "limited",     RenderTemplate.sp_limited,               \ ; 0 = the user is in the regular threads path; 1 = the user is in the limited access path.
        "variant",     RenderTemplate.sp_variant,               \ ; 0 = "/"; 1 = "/(o)/"; 2 = "/some_tag/"; 3 = "/(o)/some_tag/"
        "thread",      RenderTemplate.sp_thread,                \ ; Needs encoding!
        "permissions", RenderTemplate.sp_permissions,           \ ; NUMBER, no encoding
        "isadmin",     RenderTemplate.sp_isadmin,               \ ; 1/0 no encoding
        "canregister", RenderTemplate.sp_canregister,           \ ; 1/0 no encoding
        "canpost",     RenderTemplate.sp_canpost,               \ ; 1/0 no encoding
        "canstart",    RenderTemplate.sp_canstart,              \ ; 1/0 no encoding
        "canedit",     RenderTemplate.sp_canedit,               \ ; 1/0 no encoding
        "candel",      RenderTemplate.sp_candelete,             \ ; 1/0 no encoding
        "canchat",     RenderTemplate.sp_canchat,               \ ; 1/0 no encoding
        "canupload",   RenderTemplate.sp_canupload,             \ ; 1/0 no encoding
        "canvote",     RenderTemplate.sp_canvote,               \ ; 1/0 no encoding
        "referer",     RenderTemplate.sp_referer,               \ ; 1/0 no encoding
        "unreadLAT",   RenderTemplate.sp_unreadLAT,             \
        "unread",      RenderTemplate.sp_unread,                \
        "alltags",     RenderTemplate.sp_alltags,               \ ; HTML no encoding
        "alltags2",    RenderTemplate.sp_alltags2,              \ ; HTML no encoding
        "allusers",    RenderTemplate.sp_allusers,              \ ; returns JSON array.
        "setupmode",   RenderTemplate.sp_setupmode,             \ ; no encoding
        "search",      RenderTemplate.sp_search,                \ ; Needs encoding!
        "order",       RenderTemplate.sp_sort,                  \ ; Needs encoding!
        "usearch",     RenderTemplate.sp_usearch,               \ ; Needs encoding!
        "skins=",      RenderTemplate.sp_skins,                 \ ; HTML no encoding
        "posters=",    RenderTemplate.sp_posters,               \
        "invited=",    RenderTemplate.sp_invited,               \
        "threadtags=", RenderTemplate.sp_threadtags,            \
        "markup=",     RenderTemplate.sp_markups,               \
        "environment", RenderTemplate.sp_environment              ; optional, depends on options.DebugWeb

useridHash phash tpl_func, "userid"

struct TFieldSlot
  .pName dd ?
  .Index dd ?
ends

struct TConstSlot
  .hName  dd ?
  .hValue dd ?
ends


ESCAPE_CHAR = "^"

; returns the rendered template in EAX

proc RenderTemplate, .pText, .hTemplate, .sqlite_statement, .pSpecial
.fEncode dd ?

.stmt dd ?
.esp        dd ?

  BenchVar .render2

.tblConst   TConstSlot
            rb 255 * sizeof.TConstSlot  ; hash table of the constants...

.tblFields TFieldSlot
           rb 255 * sizeof.TFieldSlot       ; a hash table of the statement field names.
begin
        pushad
        mov     [.esp], esp

        BenchmarkStart .render2

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
        jc      .exit                   ; missing file.

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

        xor     eax, eax

        lea     edi, [.tblFields]
        mov     ecx, 256 * sizeof.TFieldSlot / 4
        rep stosd

        lea     edi, [.tblConst]
        mov     ecx, 256 * sizeof.TConstSlot / 4
        rep stosd

        cmp     [.sqlite_statement], eax
        je      .hash_ok

        call    .build_hash_table       ; creates a hash table for the SQL statement field names.

.hash_ok:
        or      eax, -1
        push    eax

.loop_dec:
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

        cmp     byte [edx+eax], ESCAPE_CHAR
        je      .delete_escape

        cmp     byte [edx+eax], '|'
        je      .separator

        cmp     byte [edx+eax], ']'
        je      .end_param

        cmp     byte [edx+eax], '['
        jne     .loop

        cmp     dword [edx+eax+1], 'html'
        jne     .not_html
        cmp     byte [edx+eax+5], ':'
        jne     .not_html

.disable_encoding:
        mov     [.fEncode], 0         ; special processing for html: command.

.not_html:
        push    ecx             ; one level up...
        jmp     .loop

.delete_escape:
        cmp     byte [edx+eax+1], "|"
        je      .escape
        cmp     byte [edx+eax+1], "["
        je      .escape
        cmp     byte [edx+eax+1], "]"
        je      .escape
        cmp     byte [edx+eax+1], ESCAPE_CHAR
        jne     .loop

.escape:
        stdcall TextMoveGap, edx, ecx
        inc     [edx+TText.GapEnd]
        jmp     .loop   ; Don't decrease ecx here, because the next char after the escape should be skipped.

.separator:
; here check for [case:] command:
        mov     ebx, [esp]
        test    ebx, ebx
        js      .loop   ; [esp] == -1

        stdcall TextMoveGap, edx, ebx           ; the gap is just before "[case:"
        add     ebx, [edx+TText.GapEnd]
        sub     ebx, [edx+TText.GapBegin]

        mov     eax, [edx+TText.Length]
        sub     eax, ebx
        cmp     eax, 6                          ; at least "[case:|"
        jl      .loop

        cmp     dword [edx+ebx], '[cas'
        jne     .loop

        cmp     word [edx+ebx+4], 'e:'
        jne     .loop

; here we have case operator with already computed value:

        add     esp, 4  ; pop the last "[" from the stack this case operator will be fully processed here.
        add     ebx, 6
        xor     esi, esi
        xor     eax, eax

; get the case value:
.get_case_val:
        cmp     ebx, [edx+TText.Length]
        jae     .loop

        mov     al, [edx+ebx]

        cmp     al, '|'
        je      .end_case_val

        cmp     al, ' '
        jbe     .next_case_val          ; the white space characters are simply ignored.

        sub     al, '0'
        jl      .inc_val

        cmp     al, 9
        ja      .inc_val

        lea     esi, [5*esi]
        shl     esi, 1

        add     esi, eax

.next_case_val:
        inc     ebx
        jmp     .get_case_val

.inc_val:               ; the non digit characters simply increment the case value.
        inc     esi
        inc     ebx
        jmp     .get_case_val


.end_case_val:

        xor     ah, ah     ; the nesting level

.loop_ext:
        mov     ecx, [edx+TText.GapBegin] ; from where to scan the text, after processing of case operator.
        mov     [edx+TText.GapEnd], ebx   ; the previous separator.
        inc     [edx+TText.GapEnd]

.loop_int:
        inc     ebx
        cmp     ebx, [edx+TText.Length]
        jae     .case_result

        mov     al, [edx+ebx]

        cmp     al, ESCAPE_CHAR
        je      .escape2

        cmp     al, ']'
        je      .level

        cmp     al, '['
        je      .level

        test    ah, ah
        jnz     .loop_int

        test    esi, esi
        js      .loop_int

        cmp     al, '|'
        jne     .loop_int

        dec     esi
        jns     .loop_ext

; here [TText.GapEnd] is the offset of result start, ebx is the offset of the result end

        push    eax

        call    .delete_ws

        mov     eax, ebx
        sub     eax, [edx+TText.GapEnd]
        add     eax, [edx+TText.GapBegin]
        stdcall TextMoveGap, edx, eax
        mov     ebx, [edx+TText.GapEnd]
        inc     [edx+TText.GapEnd]
        call    .delete_ws

        pop     eax
        jmp     .loop_int

.escape2:
        cmp     byte [edx+ebx+1], "|"
        je      .doescape2
        cmp     byte [edx+ebx+1], "["
        je      .doescape2
        cmp     byte [edx+ebx+1], "]"
        je      .doescape2
        cmp     byte [edx+ebx+1], ESCAPE_CHAR
        jne     .loop_int

.doescape2:
        inc     ebx             ; ignore the next character.
        jmp     .loop_int

.level:
        sub     al, '\'         ; +1 or -1
        sub     ah, al
        jns     .loop_int

; this "]" end the case, so delete to here...

.case_result:
        test    esi, esi
        jns     .last_result

        inc     ebx
        mov     [edx+TText.GapEnd], ebx
        jmp     .loop_dec

.last_result:   ; delete only the closing bracket.
        mov     eax, ebx
        sub     eax, [edx+TText.GapEnd]
        add     eax, [edx+TText.GapBegin]
        stdcall TextMoveGap, edx, eax
        inc     [edx+TText.GapEnd]
        jmp     .loop_dec


; The closing "]" of a parameter or command here:
.end_param:
        cmp     dword [esp], -1
        je      .loop          ; wrong nesting parameters. Ignore this.

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
        mov     bl, [tpl_func + ebx]

        cmp     al, ":"
        je      .command        ; it is a command, not query field.

        jmp     .hash


; It is a sql query field. Check for the name...
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
        je      .char_less_than
        cmp     al, '>'
        je      .char_greater_than
        cmp     al, '"'
        je      .char_quote
        cmp     al, '&'
        je      .char_amp
        cmp     al, '|'
        je      .char_vert

        stosb
        inc     ebx

.next_encode:
        loop    .encode_loop

.end_encode:

        pop     ecx
        add     ecx, ebx
        add     [edx+TText.GapBegin], ebx

        jmp     .loop

.char_vert:
        mov     dword [edi], '&ver'
        mov     word [edi+4], 't;'
        add     edi, 6
        add     ebx, 6
        jmp     .next_encode


.char_less_than:
        mov     dword [edi], '&lt;'
        add     edi, 4
        add     ebx, 4
        jmp     .next_encode

.char_greater_than:
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

; it is a command with syntax: [command:parameters]
.command:
        mov     eax, [tableRenderCmd + sizeof.TPHashItem * ebx + TPHashItem.Value]
        test    eax, eax
        jz      .loop

        jmp     eax


; ...................................................................

.cmd_minimag:
locals
  BenchVar .minimag_time
endl
        BenchmarkStart .minimag_time

; here esi points to ":" of the "minimag:" command. edi points to the start "[" and ecx points to the end "]"

        stdcall TextMoveGap, edx, ecx
        stdcall TextSetGapSize, edx, 4
        mov     dword [edx+ecx], 0
        add     [edx+TText.GapBegin], 4
        inc     [edx+TText.GapEnd]              ; delete the end "]"

        stdcall TextMoveGap, edx, edi
        add     [edx+TText.GapEnd], 9

        stdcall TranslateMiniMag, edx, edi, SanitizeURL

        add     [edx+TText.GapEnd], 4
        mov     ecx, [edx+TText.GapBegin]

        Benchmark "MiniMag markup rendering: "
        BenchmarkEnd

        jmp     .loop_dec


; ...................................................................
.cmd_bbcode:
; here esi points to ":" of the "bbcode:" command. edi points to the start "[" and ecx points to the end "]"

locals
  BenchVar .bbcode_time
endl

        BenchmarkStart .bbcode_time

        stdcall TextMoveGap, edx, ecx
        stdcall TextSetGapSize, edx, 4
        mov     dword [edx+ecx], 0
        add     [edx+TText.GapBegin], 4
        inc     [edx+TText.GapEnd]              ; delete the end "]"

        stdcall TextMoveGap, edx, edi
        add     [edx+TText.GapEnd], 8

        stdcall TranslateBBCode, edx, edi, SanitizeURL

        add     [edx+TText.GapEnd], 4
        mov     ecx, [edx+TText.GapBegin]

        Benchmark "BBCode markup rendering: "
        BenchmarkEnd

        jmp     .loop_dec

; ...................................................................

.cmd_include:
; here esi points to ":" of the "include:" command. edi points to the start "[" and ecx points to the end "]"
        pushd   0
        jmp     .cmd_incraw

.cmd_raw:
; here esi points to ":" of the "raw:" command. edi points to the start "[" and ecx points to the end "]"
        pushd   -1

.cmd_incraw:
        stdcall TextMoveGap, edx, ecx
        inc     [edx+TText.GapEnd]
        call    .delete_ws

        call    .clip_and_copy
        mov     ebx, eax

        mov     [edx+TText.GapBegin], edi

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
        AND     [esp], eax

.file_close:
        stdcall FileClose, ebx
        pop     eax
        lea     ecx, [edi+eax-1]   ; increment with the size of the included file if it was "raw" include.
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

.cmd_encode:
; here esi points to ":" of the "enc:" command. edi points to the start "[" and ecx points to the end "]"
        pushad

        stdcall TextMoveGap, edx, ecx
        inc     [edx+TText.GapEnd]
        mov     ebx, [edx+TText.GapEnd]         ; where to stop scanning

        stdcall TextMoveGap, edx, edi
        add     [edx+TText.GapEnd], 5

        mov     esi, [edx+TText.GapEnd]
        mov     edi, [edx+TText.GapBegin]

.enc_loop:
        cmp     esi, ebx
        jae     .end_scan

        mov     al, [edx+esi]
        inc     esi

        cmp     al, '<'
        je      .enc_less_than
        cmp     al, '>'
        je      .enc_greater_than
        cmp     al, '"'
        je      .enc_quote
        cmp     al, '&'
        je      .enc_amp
        cmp     al, '|'
        je      .enc_vert

        mov     [edx+edi], al
        inc     edi
        jmp     .enc_loop


.enc_less_than:
        call    .space_for_enc
        mov     dword [edx+edi], '&lt;'
        add     edi, 4
        jmp     .enc_loop

.enc_greater_than:
        call    .space_for_enc
        mov     dword [edx+edi], '&gt;'
        add     edi, 4
        jmp     .enc_loop


.enc_quote:
        call    .space_for_enc
        mov     dword [edx+edi], '&quo'
        mov     word [edx+edi+4],'t;'
        add     edi, 6
        jmp     .enc_loop

.enc_amp:
        call    .space_for_enc
        mov     dword [edx+edi], '&amp'
        mov     byte [edx+edi+4], ';'
        add     edi, 5
        jmp     .enc_loop

.enc_vert:
        call    .space_for_enc
        mov     dword [edx+edi], '&ver'
        mov     word  [edx+edi+4], 't;'
        add     edi, 6
        jmp     .enc_loop

.end_scan:
        mov     [edx+TText.GapEnd], esi
        mov     [edx+TText.GapBegin], edi
        mov     [esp+4*regEDX], edx
        popad

        mov     ecx, [edx+TText.GapBegin]
        jmp     .loop_dec


.space_for_enc:
        mov     [edx+TText.GapEnd], esi
        mov     [edx+TText.GapBegin], edi

        sub     ebx, [edx+TText.GapEnd]
        add     ebx, [edx+TText.GapBegin]

        stdcall TextSetGapSize, edx, 16

        add     ebx, [edx+TText.GapEnd]
        sub     ebx, [edx+TText.GapBegin]
        mov     esi, [edx+TText.GapEnd]
        retn

; ...................................................................

.cmd_user_encode:
; here esi points to ":" of the "usr:" command. edi points to the start "[" and ecx points to the end "]"
        pushad

        stdcall TextMoveGap, edx, ecx
        inc     [edx+TText.GapEnd]              ; delete the end "]"
        mov     ebx, [edx+TText.GapEnd]         ; where to stop scanning

        stdcall TextMoveGap, edx, edi
        add     [edx+TText.GapEnd], 5           ; delete "[usr:"

        mov     esi, [edx+TText.GapEnd]
        mov     edi, [edx+TText.GapBegin]

        cmp     esi, ebx
        jae     .finish_usr_scan

        mov     al, [edx+esi]
        inc     esi
        mov     [edx+edi], al
        inc     edi

        mov     ecx, '<u >'

.usr_loop:
        cmp     esi, ebx
        jae     .end_usr_scan

        mov     ah, al
        mov     al, [edx+esi]
        inc     esi

        xor     ah, al
        jns     .tag_ok

        call    .space_for_enc
        mov     dword [edx+edi], ecx
        add     edi, 4
        xor     ecx, '<u >' xor '</u>' ; turns "<u >" into "</u>" and vice versa

.tag_ok :
        mov     [edx+edi], al
        inc     edi
        jmp     .usr_loop

.end_usr_scan:
        cmp     ch, '/'
        jne     .finish_usr_scan

        call    .space_for_enc
        mov     dword [edx+edi], ecx
        add     edi, 4

.finish_usr_scan:
        mov     [edx+TText.GapEnd], esi
        mov     [edx+TText.GapBegin], edi
        mov     [esp+4*regEDX], edx
        popad

        mov     ecx, [edx+TText.GapBegin]
        jmp     .loop_dec

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
        push    eax
        stdcall TextAddStr2, edx, [edx+TText.GapBegin], eax, 0
        stdcall StrDel ; from the stack
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
        jmp     .loop_dec


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
        call    .delete_ws

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
        jmp     .loop_dec


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
        jmp     .loop_dec

.json_ctrl db ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '
           db 'b', 't', 'n', ' ', 'f', 'r', ' ', ' '
           db ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '
           db ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '


; command "equ" defined named constants. Syntax: [equ:name=value]
.cmd_equ:
; here esi points to ":" of the "[equ:" command. edi points to the start "[" and ecx points to the end "]"
        pushad

        stdcall TextMoveGap, edx, ecx

        xor     ebx, ebx

.hash_name:
        inc     esi
        cmp     esi, ecx
        je      .end_equ        ; simply ignore this command and delete it from the text.

        mov     al, [edx+esi]
        cmp     al, '='
        je      .name_ok

        xor     bl, al
        mov     bl, [tpl_func + ebx]
        jmp     .hash_name

.name_ok:
        mov     ecx, ebx
        mov     eax, esi
        mov     esi, [esp+4*regESI]

        sub     eax, esi
        dec     eax
        jz      .end_equ

        push    eax     ; name length
        inc     esi
        push    esi     ; name start.

        lea     esi, [esi+eax+1]        ; points at the start of the value

        stdcall StrExtract, edx ; remaining arguments from the stack
        mov     ebx, eax

        mov     eax, ecx        ; the hash value.

.search_slot:
        cmp     dword [.tblConst.hName + sizeof.TConstSlot*eax], 0
        je      .store_const

        stdcall StrCompCase, ebx, [.tblConst.hName + sizeof.TConstSlot*eax]
        jc      .store_const                                    ; the constant redefinition here!!!

        inc     al
        cmp     eax, ecx
        jne     .search_slot

; no free slot...

        stdcall StrDel, ebx
        jmp     .end_equ

.store_const:

        lea     edi, [.tblConst + sizeof.TConstSlot*eax]
        xchg    ebx, [edi + TConstSlot.hName]
        test    ebx, ebx
        jz      .slot_ok

        stdcall StrDel, ebx
        xor     eax, eax
        xchg    eax, [edi+TConstSlot.hValue]
        stdcall StrDel, eax

.slot_ok:
        mov     eax, [esp+4*regECX]
        sub     eax, esi
        stdcall StrExtract, edx, esi, eax
        mov     [edi + TConstSlot.hValue], eax

.end_equ:
        popad
        mov     [edx+TText.GapBegin], edi
        inc     [edx+TText.GapEnd]
        call    .delete_ws

        mov     ecx, edi
        jmp     .loop_dec


.cmd_const:
; here esi points to ":" of the "[equ:" command. edi points to the start "[" and ecx points to the end "]"
        pushad

        stdcall TextMoveGap, edx, ecx

; delete the label...
        mov     [edx+TText.GapBegin], edi
        inc     [edx+TText.GapEnd]

        inc     esi
        sub     ecx, esi
        jle     .end_const

        stdcall StrExtract, edx, esi, ecx       ; the name
        mov     ebx, eax

        stdcall StrPearsonHash, ebx, tpl_func
        mov     ecx, eax

.loop_const:
        cmp     [.tblConst.hName + sizeof.TConstSlot*eax], 0
        je      .end_const_free

        stdcall StrCompCase, ebx, [.tblConst.hName + sizeof.TConstSlot*eax]
        jc      .slot_found

        inc     al
        cmp     eax, ecx
        jne     .loop_const

.end_const_free:

        stdcall StrDel, ebx

.end_const:
        popad
        mov     ecx, [edx+TText.GapBegin]
        dec     ecx
        jmp     .loop

.slot_found:
        cmp     [.tblConst.hValue + sizeof.TConstSlot*eax], 0
        je      .end_const_free

        stdcall TextAddString, edx, [edx+TText.GapBegin], [.tblConst.hValue + sizeof.TConstSlot*eax]
        mov     [esp+4*regEDX], edx
        jmp     .end_const_free

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

        mov     eax, [tableSpecial + sizeof.TPHashItem * ebx + TPHashItem.Value]
        test    eax, eax
        jz      .unknown_special

        mov     ebx, [.pSpecial]
        jmp     eax

.unknown_special:
        lea     eax, [ecx+1]
        stdcall TextMoveGap, edx, eax
        mov     [edx+TText.GapBegin], edi
        mov     ecx, edi
        jmp     .loop_dec

; ...................................................................
; here edi points to the start "[" and ecx = esi points to the end "]"

; NOT FINISHED! Needs separate procedure GetEnvironment. An example code is accessible in the old render: render.asm

if defined options.DebugWeb & options.DebugWeb
.sp_environment:
        lea     eax, [ecx+1]
        stdcall TextMoveGap, edx, eax
        mov     [edx+TText.GapBegin], edi
        mov     ecx, edi
        jmp     .loop_dec
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


sqlGetFirstDate text "select strftime('%Y-%m-%d:', Register, 'unixepoch') from Users where Register is not null order by register limit 1;"
sLocalHost      text "localhost"
locals
  .stmt2 dd ?
endl

.sp_tagprefix:
        pushad

        stdcall StrDupMem, txt "tag:"
        mov     edi, eax

        mov     eax, sLocalHost
        stdcall ValueByName, [ebx+TSpecialParams.params], txt "HTTP_HOST"
        stdcall StrCat, edi, eax
        stdcall StrCat, edi, txt ","

        lea     eax, [.stmt2]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetFirstDate, sqlGetFirstDate.length, eax, 0
        cinvoke sqliteStep, [.stmt2]
        cmp     eax, SQLITE_ROW
        jne     .end_tag

        cinvoke sqliteColumnText, [.stmt2], 0
        stdcall StrCat, edi, eax

.end_tag:
        cinvoke sqliteFinalize, [.stmt2]

        mov     [esp+4*regEAX], edi
        popad
        jmp     .special_string_free

.sp_hostroot:
        push    edi

        stdcall ValueByName, [ebx+TSpecialParams.params], txt "REQUEST_SCHEME"
        stdcall StrDup, eax
        mov     edi, eax

        stdcall StrCat, edi, txt "://"
        stdcall ValueByName, [ebx+TSpecialParams.params], txt "HTTP_HOST"
        stdcall StrCat, edi, eax

        mov     eax, edi
        pop     edi
        jmp     .special_string_free


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
        mov     eax, [ebx+TSpecialParams.userSkinURL]
        jmp     .special_string

.sp_lang:
        mov     eax, [ebx+TSpecialParams.userLang]
        jmp     .special_int

.sp_skincookie:
        xor     eax, eax
        stdcall GetCookieValue, [ebx+TSpecialParams.params], txt "skin"
        jmp     .special_string_free

.sp_version:
        mov     eax, cVersion
        jmp     .special_string

.sp_sqlite_version:
        push    ebx esi

        stdcall StrDupMem, txt '<b>SQLite v'
        mov     ebx, eax

        stdcall StrCat, ebx, [sqliteVersion]
        stdcall StrCat, ebx, txt '</b> (check-in: <a href="http://sqlite.org/cgi/src/info/'

        cinvoke sqliteSourceID
        lea     esi, [eax+20]                   ; skip the date/time of the string.
        stdcall StrCatMem, ebx, esi, 16
        stdcall StrCat, ebx, txt '">'
        stdcall StrCatMem, ebx, esi, 16
        stdcall StrCat, ebx, txt '</a>)'
        mov     eax, ebx
        pop     esi ebx
        jmp     .special_string_free

; ...................................................................

.sp_unread:
        stdcall GetUnread, [ebx+TSpecialParams.userID], 0
        jmp     .special_string_free

.sp_unreadLAT:
        stdcall GetUnread, [ebx+TSpecialParams.userID], 1
        jmp     .special_string_free

.sp_limited:
        mov     eax, [ebx+TSpecialParams.Limited]
        jmp     .special_int

.sp_variant:
        push    ecx

        xor     eax, eax
        xor     ecx, ecx
        cmp     [ebx+TSpecialParams.dir], eax
        setnz   al
        cmp     [ebx+TSpecialParams.Limited], ecx
        setnz   cl

        lea     eax, [2*eax+ecx]
        pop     ecx
        jmp     .special_int


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

.sp_canregister:
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

.sp_canvote:
        mov     eax, permVote or permAdmin
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

        test    ebx, ebx
        jz      .end_styles

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
        stdcall TextCat, edx, [esi+TSpecialParams.userSkinURL]
        stdcall TextCat, edx, txt '/'
        stdcall TextCat, edx, [ebx+TArray.array+4*ecx]
        stdcall TextCat, edx, txt '?skin='
        stdcall TextCat, edx, [esi+TSpecialParams.userSkinURL]
        stdcall TextCat, edx, <txt '" type="text/css">', 13, 10>

        inc     ecx
        jmp     .external_css


.sp_alltags:
        stdcall GetAllTags, [.pSpecial], 0
        jmp     .special_ttext

.sp_alltags2:
        stdcall GetAllTags, [.pSpecial], 1
        jmp     .special_ttext

.sp_allusers:
        stdcall GetAllUsers
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

.sp_markups:
; here esi points to the "=" char, ecx at the end "]" and edi at the start "["
        call    .get_number
        and     ebx, $1f

        push    ecx

        xor     ecx, ecx
        inc     ecx
        mov     eax, ecx        ; the default value if there is no parameter in the database!
        xchg    ebx, ecx
        shl     ebx, cl

        pop     ecx

; eax == 1 here!!!
        stdcall GetParam, txt "markup_languages", gpInteger
        and     eax, ebx

        cmovz   eax, [.cBoolean]
        cmovnz  eax, [.cBoolean+4]
        jmp     .special_string

.finish:
;        cmp     dword [esp], -1
;        jne     .exit
;        add     esp, 4
;        jmp     .finish


.exit:
        mov     ecx, 256

.free_const:
        stdcall StrDel, [.tblConst.hName + sizeof.TConstSlot*ecx - sizeof.TConstSlot]
        stdcall StrDel, [.tblConst.hValue + sizeof.TConstSlot*ecx - sizeof.TConstSlot]
        loop    .free_const

.end_free_const:
        mov     esp, [.esp]
        mov     [esp+4*regEAX], edx

if defined options.Benchmark & options.Benchmark
        cmp     [.hTemplate], 0
        je      @f
        stdcall FileWriteString, [STDERR], [.hTemplate]
@@:
end if
        Benchmark " rendering time: "
        BenchmarkEnd

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

; deletes the control characters and spaces.

.delete_ws:
        mov     eax, [edx+TText.GapEnd]
        dec     eax

.del_ws_loop:
        inc     eax
        cmp     eax, [edx+TText.Length]
        jae     .exit_del_ws

        cmp     byte [edx+eax], ' '
        jbe     .del_ws_loop

.exit_del_ws:
        mov     [edx+TText.GapEnd], eax
        retn

endp






proc ListAddDistinct, .pList, .hString
begin
        pushad

        mov     ebx, [.hString]
        mov     edx, [.pList]
        test    edx, edx
        jnz     .array_ok

        stdcall CreateArray, 4
        mov     edx, eax

.array_ok:
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



sqlGetAllUsers text "select nick from Users"
proc GetAllUsers
.stmt dd ?
begin
        pushad

        stdcall TextCreate, sizeof.TText
        mov     ebx, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetAllUsers, sqlGetAllUsers.length, eax, 0

.loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finish

        cinvoke sqliteColumnText, [.stmt], 0

        stdcall TextCat, ebx, txt '<option value="'
        stdcall TextCat, edx, eax
        stdcall TextCat, edx, txt '">'
        mov     ebx, edx
        jmp     .loop

.finish:
        cinvoke sqliteFinalize, [.stmt]
        mov     [esp+4*regEAX], ebx
        popad
        return
endp


sqlGetAllTags StripText "alltags.sql", SQL
sqlTagSortAlpha text " Tag"
sqlTagSortThreads text " ThreadCnt desc, Tag"

; Returns all tags.
; .sort = 0 - sorts alphabetically.
; .sort <> 0 - sorts by threads count.

proc GetAllTags, .pSpecial, .sort
  .max   dd ?
  .stmt  dd ?
begin
        pushad

        mov     esi, [.pSpecial]

        stdcall TextCreate, sizeof.TText
        mov     ebx, eax

        mov     [.max], 1

        stdcall StrDupMem, sqlGetAllTags
        mov     ecx, eax

        mov     eax, sqlTagSortAlpha
        cmp     [.sort], 0
        je      .sort_ok
        mov     eax, sqlTagSortThreads
.sort_ok:
        stdcall StrCat, ecx, eax

        lea     edx, [.stmt]
        push    ecx
        stdcall StrPtr, ecx
        cinvoke sqlitePrepare_v2, [hMainDatabase], eax, [eax+string.len], edx, 0
        cinvoke sqliteBindInt, [.stmt], 1, [esi+TSpecialParams.userID]
        cinvoke sqliteBindInt, [.stmt], 2, [esi+TSpecialParams.Limited]

        stdcall StrDel ; from the stack

        push    0       ; end marker

.tag_loop:
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .fix_loop

        cinvoke sqliteColumnInt, [.stmt], 1     ; the count used
        test    eax, eax
        jz      .tag_loop

        push    eax

        mov     ecx, [.max]
        cmp     ecx, eax
        cmovb   ecx, eax
        mov     [.max], ecx

        stdcall TextCat, ebx, txt  '<a class="taglink tagsize32'
        mov     ebx, edx

        push    [ebx+TText.GapBegin]    ; points at the end of "tagsize32" word

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

        mov     eax, [esp+4]    ; the current count
        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        stdcall TextCat, ebx, eax
        stdcall StrDel, eax

        stdcall TextCat, edx, txt ' thread'
        cmp     dword [esp+4], 1               ; the current count pushed!
        je      .plural_ok

        stdcall TextCat, edx, txt 's'

.plural_ok:
        stdcall TextCat, edx, txt '." href="/'
        cmp     [esi+TSpecialParams.Limited], 0
        je      .limited_ok

        stdcall TextCat, edx, txt "(o)/"

.limited_ok:
        stdcall TextCat, edx, edi
        stdcall TextCat, edx, txt '/">'
        stdcall TextCat, edx, edi
        mov     ebx, edx

        cinvoke sqliteColumnInt, [.stmt], 3
        test    eax, eax
        jz      .unread_ok

        stdcall TextCat, ebx, txt '<span class="ntf">'
        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        stdcall TextCat, edx, eax
        stdcall StrDel, eax
        stdcall TextCat, edx, txt '</span>'
        mov     ebx, edx

.unread_ok:
        stdcall TextCat, ebx, <txt '</a>', 13, 10>
        mov     ebx, edx

        stdcall StrDel, edi
        jmp     .tag_loop

.fix_loop:
        pop     esi
        test    esi, esi
        jz      .end_fix

        pop     eax

        mov     ecx, 32
        mul     ecx
        div     [.max]
        mov     ecx, 10

        xor     edx,edx
        div     ecx
        add     dl, '0'
        mov     [ebx+esi-1], dl

        xor     edx,edx
        div     ecx
        add     dl, '0'
        mov     [ebx+esi-2], dl
        jmp     .fix_loop

.end_fix:
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




;proc FixMiniMagLink, .ptrLink, .ptrBuffer, .lParam
;begin
;        pushad
;
;        mov     edi, [.ptrBuffer]
;        mov     esi, [.ptrLink]
;
;        cmp     byte [esi], '#'
;        je      .finish         ; it is internal link
;
;.start_loop:
;        lodsb
;        cmp     al, $0d
;        je      .not_absolute
;        cmp     al, $0a
;        je      .not_absolute
;        cmp     al, ']'
;        je      .not_absolute
;        test    al,al
;        jz      .not_absolute
;
;        cmp     al, 'A'
;        jb      .found
;        cmp     al, 'Z'
;        jbe     .start_loop
;
;        cmp     al, 'a'
;        jb      .found
;        cmp     al, 'z'
;        jb      .start_loop
;
;.found:
;        cmp     al, ':'
;        jne     .not_absolute
;
;        mov     ecx, [.ptrLink]
;        sub     ecx, esi
;
;        cmp     ecx, -11
;        jne     .not_js
;
;        cmp     dword [esi+ecx], "java"
;        jne     .not_js
;
;        cmp     dword [esi+ecx+4], "scri"
;        jne     .not_js
;
;        cmp     word [esi+ecx+8], "pt"
;        jne     .not_js
;
;.add_https:
;        mov     dword [edi], "http"
;        mov     dword [edi+4], "s://"
;        lea     edi, [edi+8]
;        jmp     .protocol_ok
;
;.not_js:
;        cmp     dword [esi+ecx], "http"         ; ECX < 0 here!!!
;        jne     .add_https
;
;.not_absolute:
;.protocol_ok:
;        mov     esi, [.ptrLink]
;
;; it is absolute URL, exit
;.finish:
;        mov     [esp+4*regEAX], edi     ; return where to copy the remaining of the address. Destination!
;        mov     [esp+4*regEDX], esi     ; return from where to copy the remaining of the address. Source!
;
;        popad
;        return
;endp







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
        stdcall SortArray, edi, DirItemCompare, dsByName or fdsDirsFirst

        mov     ecx, [edi+TArray.count]
        lea     esi, [edi+TArray.array]

.dir_loop:
        dec     ecx
        js      .end_of_dir

        cmp     [esi+TDirItem.Type], ftDirectory
        jne     .next_file

        stdcall StrPtr, [esi+TDirItem.hFilename]
        jc      .next_file

        cmp     byte [eax], '_'
        je      .next_file

        cmp     byte [eax], '.'
        je      .next_file

        stdcall TextCat, edx, txt '<option value="'
        stdcall TextCat, edx, [esi+TDirItem.hFilename]
        stdcall TextCat, edx, txt '" '

        stdcall StrCompCase, [esi+TDirItem.hFilename], [.hCurrent]
        jnc     .selected_ok

        stdcall TextCat, edx, txt ' selected="selected"'

.selected_ok:
        stdcall TextCat, edx, txt '>'
        stdcall TextCat, edx, [esi+TDirItem.hFilename]
        stdcall TextCat, edx, <txt '</option>', 13, 10>

.next_file:
        stdcall StrDel, [esi+TDirItem.hFilename]
        add     esi, sizeof.TDirItem
        jmp     .dir_loop

.end_of_dir:

        stdcall FreeMem, edi

.finish_skins:

        stdcall StrDel, [.hCurrent]
        mov     [esp+4*regEAX], edx
        popad
        return
endp



sqlGetThreadTags    text "select TT.tag, (select T.description from Tags T where T.tag = TT.tag) from ThreadTags TT where TT.threadID=?1;"
;sqlGetThreadTags    text "select TT.tag, T.Description from ThreadTags TT left join Tags T on TT.tag=T.tag where TT.threadID=? order by TT.tag"

proc GetThreadTags, .threadID
.stmt dd ?
begin
        pushad

        stdcall StrNew
        mov     ebx, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetThreadTags, sqlGetThreadTags.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.threadID]

.thread_tag_loop:

        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .end_thread_tags

        stdcall StrCat, ebx, txt '<li><a '

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
        stdcall StrCat, ebx, txt '</a></li>'
        stdcall StrDel, eax

        jmp     .thread_tag_loop

.end_thread_tags:

        cinvoke sqliteFinalize, [.stmt]

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
        stdcall StrLCase, eax

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

        stdcall StrLCaseUtf8, ebx

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



proc StrLCaseUtf8, .str
begin
        pushad

        stdcall StrPtr, [.str]
        mov     esi, eax
        mov     edi, eax
        mov     ecx, [eax+string.len]

.loop:
        dec     ecx
        js      .finish

        stdcall DecodeUtf8, [esi]
        cmp     edx, 1
        ja      .skip

        mov     ah, al
        and     ah, 40h
        shr     ah, 1
        or      al, ah
        mov     [esi], al

.skip:
        add     esi, edx
        jmp     .loop

.finish:
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
;        stdcall TextCat, edx, <txt 13, 10, 'Content-Length: 0', 13, 10, 13, 10>
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

        stdcall StrDup, [hCurrentDir]
        push    eax
        stdcall StrCat, eax, ebx
        stdcall StrCat, eax, SKIN_CHECK_FILE

        stdcall FileExists, eax
        stdcall StrDel ; from the stack
        jnc     .finish

        stdcall StrDel, ebx
        stdcall StrDupMem, "/templates/"
        mov     ebx, eax
        stdcall StrCat, ebx, cDefaultSkin

.finish:
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


sqlGetUnread text "select count() from unreadposts up left join threads t on t.id = up.threadid where up.userid = ?1 and t.limited = ?2"

proc GetUnread, .UserID, .Limited
.stmt dd ?
begin
        pushad

        stdcall StrNew
        mov     ebx, eax

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetUnread, sqlGetUnread.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.UserID]
        cinvoke sqliteBindInt, [.stmt], 2, [.Limited]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .finalize

        cinvoke sqliteColumnInt, [.stmt], 0
        test    eax, eax
        jz      .finalize

        stdcall StrCat, ebx, txt '<span class="ntf">'
        stdcall NumToStr, eax, ntsDec or ntsUnsigned
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCat, ebx, txt "</span>"

.finalize:
        cinvoke sqliteFinalize, [.stmt]
        mov     [esp+4*regEAX], ebx
        popad
        return
endp

; Later can be made to compose KB/MB/GB suffixes.

proc FormatFileSize, .size
begin
        stdcall NumToStr, [.size], ntsDec or ntsUnsigned
        stdcall StrCat, eax, txt " bytes"
        return
endp





proc SanitizeURL, .pURL, .len
.split TSplitURL
begin
        pushad

        lea     eax, [.split]
        stdcall StrSplitURLMem, [.pURL], [.len], eax

        stdcall StrNew
        mov     ebx, eax

        cmp     [.split.scheme], 0
        je      .default_scheme

        stdcall StrCompNoCase, [.split.scheme], txt 'https'
        jc      .scheme_ok

        stdcall StrCompNoCase, [.split.scheme], txt 'http'
        jnc     .end_url        ; return empty URL

.scheme_ok:
        stdcall StrCat, ebx, [.split.scheme]
        stdcall StrCat, ebx, txt '://'
        jmp     .add_host

.default_scheme:
        cmp     [.split.host], 0
        je      .add_path

        stdcall StrCat, ebx, txt 'https://'

.add_host:
        cmp     [.split.host], 0
        je      .add_path

        stdcall StrURLEncode, [.split.host]
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

        cmp     [.split.port], 0
        je      .add_path

        stdcall StrToNum, [.split.port]
        test    eax, eax
        js      .add_path

        cmp     eax, $ffff
        ja      .add_path

        mov     ecx, eax

        stdcall StrLen, [.split.port]
        cmp     eax, edx
        jne     .add_path

        stdcall NumToStr, ecx, ntsDec or ntsUnsigned

        stdcall StrCat, ebx, txt ':'
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

.add_path:
        stdcall StrCat, ebx, txt '/'

        cmp     [.split.path], 0
        je      .path_ok
        stdcall StrCat, ebx, [.split.path]
.path_ok:
        stdcall StrPtr, ebx
        mov     ecx, [eax+string.len]
        sub     eax, sizeof.string
        add     ecx, sizeof.string

        cmp     [.split.query], 0
        je      .add_fragment

        stdcall StrCat, ebx, txt '?'
        stdcall StrCat, ebx, [.split.query]

.add_fragment:
        cmp     [.split.fragment], 0
        je      .end_url

        stdcall StrCat, ebx, txt "#"

        stdcall StrURLEncode, [.split.fragment]
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

.end_url:
        stdcall StrDel, [.split.scheme]
        stdcall StrDel, [.split.host]
        stdcall StrDel, [.split.port]
        stdcall StrDel, [.split.path]
        stdcall StrDel, [.split.query]
        stdcall StrDel, [.split.fragment]

        mov     [esp+4*regEAX], ebx
        popad
        return
endp



; Encodes the path in URL encoding, but without encoding "/" characters.

proc StrURLEncode2, .hstr
.res dd ?
begin
        push    ebx ecx edx esi edi
        stdcall StrPtr, [.hstr]
        mov     esi, eax

        stdcall StrLen, esi
        mov     ecx, eax
        lea     edx, [3*eax]        ; the encoded string can be max 3x long as original string.

        stdcall StrNew
        mov     [.res], eax
        jecxz   .finish

        stdcall StrSetCapacity, eax, edx
        mov     edi, eax
        xor     edx, edx
        xor     ebx, ebx

        push    eax

.encode:
        lodsb
        cmp     al, $80
        jae     .store          ; it is a hack, but I hope save enough.

        cmp     al, '/'
        je      .store
        cmp     al, '\'
        jne     @f
        mov     al, '/'
        jmp     .store

@@:
        cmp     al, ' '
        jne     @f
        mov     al, '+'
        jmp     .store
@@:
        mov     dl, al
        mov     bl, al
        shr     edx, 5
        and     ebx, $1f
        bt      dword [URLCharTable+4*edx], ebx
        jnc     .store

        mov     ah, al
        mov     al, '%'
        stosb
        mov     al, ah
        shr     al, 4
        cmp     al, $0a
        sbb     al, $69
        das
        stosb
        mov     al, ah
        and     al, $0f
        cmp     al, $0a
        sbb     al, $69
        das

.store:
        stosb
        loop    .encode

        xor     al, al
        mov     [edi], al

        pop     eax
        sub     edi, eax
        mov     [eax+string.len], edi

.finish:
        mov     eax, [.res]
        pop     edi esi edx ecx ebx
        return
endp

