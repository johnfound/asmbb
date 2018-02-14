
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

  disp 3, 'Hash table "', `table, '"', 9

  table dd 256 dup(0,0)

forward
local ..keynm, ..len, ..hash, ..char, ..prev
  ..keynm db key
  ..len = $ - ..keynm
         db 0

  ..hash = 0
  repeat ..len
    load ..char byte from ..keynm + % - 1
    if ..char and $40
      ..char = ..char or $20
    end if
    ..hash = ..hash xor ..char
    load ..hash byte from Pfunc + ..hash
  end repeat

  disp 3,'Keyword hash : ', <..hash, 10>, ' on "', key, '"', 10

  load ..prev dword from table + ..hash * 8

  if ..prev = 0
    store dword ..keynm at table + ..hash * 8
    store dword proc at table + ..hash * 8 + 4
  else
    disp 2,'Hash collision: ', <..hash, 10>, ' on "', key, '"', 10
    ..error = 1
  end if

common
  disp 6, '---', 13
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

  disp 3,'Keyword hash : ', <..hash, 10>, ' on "', key, '"', 10

  . = ..hash
}






if used RenderTemplate
        PList tableCommands, tpl_func,                  \
              'special:', RenderTemplate.cmd_special,   \
              'minimag:', RenderTemplate.cmd_minimag,   \
              'html:',    RenderTemplate.cmd_html,      \
              'url:',     RenderTemplate.cmd_url,       \
              'css:',     RenderTemplate.cmd_css,       \
              'case:',    RenderTemplate.cmd_case,      \
              'and:',     RenderTemplate.cmd_and,       \
              'sql:',     RenderTemplate.cmd_sql


        PList tableSpecial, tpl_func,                                 \
              "visitors",    RenderTemplate.sp_visitors,              \
              "version",     RenderTemplate.sp_version,               \
              "cmdtype",     RenderTemplate.sp_cmdtype,               \
              "stats",       RenderTemplate.sp_stats,                 \
              "timestamp",   RenderTemplate.sp_timestamp,             \
              "title",       RenderTemplate.sp_title,                 \
              "header",      RenderTemplate.sp_header,                \
              "allstyles",   RenderTemplate.sp_allstyles,             \
              "description", RenderTemplate.sp_description,           \
              "keywords",    RenderTemplate.sp_keywords,              \
              "username",    RenderTemplate.sp_username,              \
              "userid",      RenderTemplate.sp_userid,                \
              "skin",        RenderTemplate.sp_skin,                  \
              "page",        RenderTemplate.sp_page,                  \
              "dir",         RenderTemplate.sp_dir,                   \
              "thread",      RenderTemplate.sp_thread,                \
              "permissions", RenderTemplate.sp_permissions,           \
              "isadmin",     RenderTemplate.sp_isadmin,               \
              "canlogin",    RenderTemplate.sp_canlogin,              \
              "canpost",     RenderTemplate.sp_canpost,               \
              "canstart",    RenderTemplate.sp_canstart,              \
              "canedit",     RenderTemplate.sp_canedit,               \
              "candel",      RenderTemplate.sp_candelete,             \
              "canchat",     RenderTemplate.sp_canchat,               \
              "referer",     RenderTemplate.sp_referer,               \
              "alltags",     RenderTemplate.sp_alltags,               \
              "setupmode",   RenderTemplate.sp_setupmode,             \
              "search",      RenderTemplate.sp_search,                \
              "usearch",     RenderTemplate.sp_usearch,               \
              "skins=",      RenderTemplate.sp_skins,                 \
              "posters=",    RenderTemplate.sp_posters,               \
              "threadtags=", RenderTemplate.sp_threadtags

end if

useridHash phash tpl_func, "userid"


;call RenderTemplate

struct TFieldSlot
  .pName  dd ?
  .Index  dd ?
ends


proc RenderTemplate, .pText, .hTemplate, .sqlite_statement, .pSpecial
.result dd ?
.fEncode dd ?

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
        mov     edx, [.pText]
        stdcall TextMoveGap, edx, -1

        stdcall FileOpenAccess, [.hTemplate], faReadOnly
        mov     ebx, eax

        stdcall FileSize, ebx
        push    eax
        stdcall TextSetGapSize, edx, eax

        mov     ecx, [edx+TText.GapBegin]
        mov     eax, ecx
        add     eax, edx

        stdcall FileRead, ebx, eax ; the size from the stack.
        add     [edx+TText.GapBegin], eax

        stdcall FileClose, ebx

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

;        DebugMsg "Check database fields."

        cmp     [.sqlite_statement], 0
        je      .loop

        mov     eax, [.tblFields.pName + sizeof.TFieldSlot * ebx]
        test    eax, eax
        jz      .loop

        push    ecx edx
        cinvoke sqliteColumnText, [.sqlite_statement], [.tblFields.Index + sizeof.TFieldSlot * ebx]
        pop     edx ecx
        push    eax             ; pointer to the column text.

        push    ecx edx
        cinvoke sqliteColumnBytes, [.sqlite_statement], [.tblFields.Index + sizeof.TFieldSlot * ebx]
        pop     edx ecx
        push    eax             ; the length in bytes of the column text.

        stdcall TextSetGapSize, edx, eax
        stdcall TextMoveGap, edx, edi           ; the start of the field name.

;        int3

        lea     eax, [ecx+1]
        sub     eax, edi
        add     [edx+TText.GapEnd], eax
        lea     ecx, [edi-1]

        pop     eax     ; field text length
        pop     esi     ; pointer to the field text

        add     ecx, eax
        push    ecx

        add     [edx+TText.GapBegin], eax

        add     edi, edx
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
        mov     eax, [tableCommands + sizeof.TPHashItem * ebx + TPHashItem.procCommand]
        test    eax, eax
        jz      .loop

        jmp     eax

; ...................................................................

.cmd_html:
; here esi points to ":" of the "html:" command. edi points to the start "[" and ecx points to the end "]"
; simply remove the "[html:" and "]" and the remaining is the html that need no more processing.
        stdcall TextMoveGap, edx, ecx
        inc     [edx+TText.GapEnd]

        stdcall TextMoveGap, edx, edi
        add     [edx+TText.GapEnd], 6

        sub     ecx, 7
        jmp     .loop


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

.cmd_minimag:

.cmd_url:

.cmd_and:

.cmd_sql:
        jmp     .loop


.cmd_case:
; here esi points to ":" of the "special:" command. edi points to the start "[" and ecx points to the end "]"

;        stdcall TextMoveGap, edx, -1
;        lea     ebx, [edx+esi]
;        int3

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
        jz      .loop

;        OutputLn [tableSpecial + sizeof.TPHashItem * ebx + TPHashItem.pKeyname]

        mov     ebx, [.pSpecial]
        jmp     eax

; ...................................................................
; here edi points to the start "[" and ecx = esi points to the end "]"

.sp_username:

        mov     eax, [ebx+TSpecialParams.userName]

.special_string:
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

.sp_version:
        mov     eax, cVersion
        jmp     .special_string



; ...................................................................

.sp_userid:

        mov     eax, [ebx+TSpecialParams.userID]

.special_int:

        stdcall NumToStr, eax, ntsDec

.special_string_free:

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

.sp_canchat:
        call    ChatPermissions
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



.cBoolean dd .cStringFALSE, .cStringTRUE
.cStringFALSE db "0", 0, 0, 0
.cStringTRUE  db "1", 0, 0, 0


; ...................................................................

.sp_allstyles:
        push    ebx ecx edx esi edi

        mov     esi, ebx

        mov     edx, [esi+TSpecialParams.pStyles]
        xor     ecx, ecx

        stdcall StrNew
        mov     ebx, eax

        jmp     .external_css

;        stdcall GetParam, 'embeded_css', gpInteger
        jc      .external_css

        test    eax, eax
        jz      .external_css

;.embeded_css:
        stdcall StrCat, ebx, '<style>'

.loop_styles:
        cmp     ecx, [edx+TArray.count]
        jae     .end_styles2

;        stdcall StrCatTemplate, ebx, [edx+TArray.array+4*ecx], NULL, esi

.next_css:
        inc     ecx
        jmp     .loop_styles

.end_styles2:

        stdcall StrCat, ebx, '</style>'
        jmp     .end_styles

.external_css:

        cmp     ecx, [edx+TArray.count]
        jae     .end_styles

        stdcall StrCat, ebx, '<link rel="stylesheet" href="'
        stdcall StrCat, ebx, [esi+TSpecialParams.userSkin]
        stdcall StrCat, ebx, [edx+TArray.array+4*ecx]
        stdcall StrCat, ebx, '?skin='
        stdcall StrCat, ebx, [esi+TSpecialParams.userSkin]
        stdcall StrCat, ebx, <txt '" type="text/css">', 13, 10>

        inc     ecx
        jmp     .external_css


.end_styles:

        mov     eax, ebx
        pop     edi esi edx ecx ebx
        jmp     .special_string_free




.sp_visitors:
.sp_stats:
.sp_skin:
.sp_referer:
.sp_alltags:
.sp_search:
.sp_usearch:
.sp_skins:
.sp_posters:
.sp_threadtags:

        jmp     .loop


.finish:
        cmp     dword [esp], -1
        jne     @f
        add     esp, 4
@@:
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
        jnz     .empty_slot

        inc     ecx
        jmp     .col_loop

.end_cols:

        popad
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
