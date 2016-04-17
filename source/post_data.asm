

struct TPostDataItem
  .name         dd ?            ; the name of the form field.
  .data         dd ?            ; pointer to the TArray of TFileItem or handle of a string.
ends


struct TPostFileItem
  .filename dd ?
  .mime     dd ?
  .size     dd ?
  .data     dd ?
ends



cContentDisposition text "Content-Disposition: form-data; "
cContentType        text "Content-Type: "


proc DecodePostData, .pPostData, .pCGIParams

.end_data dd ?
.post_array dd ?

.boundary dd ?
.pbound   dd ?  ; pointer to the boundary string
.sbound   dd ?  ; size of the boundary string

.name     dd ?
.filename dd ?
.mime     dd ?


begin
        pushad

        xor     eax, eax
        mov     [.name], eax
        mov     [.filename], eax
        mov     [.mime], eax
        mov     [.boundary], eax
        mov     [.post_array], eax

        mov     esi, [.pPostData]
        test    esi, esi
        jz      .finish_not_ok

        mov     eax, [esi+TByteStream.size]
        lea     esi, [esi+TByteStream.data]

        add     eax, esi
        mov     [.end_data],eax

        stdcall CreateArray, sizeof.TPostDataItem
        mov     [.post_array], eax

        stdcall ValueByName, [.pCGIParams], 'CONTENT_TYPE'
        jc      .bad_request

        stdcall StrCompNoCase, eax, 'application/x-www-form-urlencoded'
        jc      .url_encoded_post

        stdcall GetQueryItem, eax, 'multipart/form-data; boundary=', 0
        test    eax, eax
        jz      .bad_request

        stdcall StrClipQuotes, eax
        mov     [.boundary], eax            ; separator string.

        stdcall StrPtr, eax
        mov     [.pbound], eax

        mov     eax, [eax+string.len]
        mov     [.sbound], eax

        call    .search_boundary
        jnc     .bad_request            ; the post data must start with boundary string!

.section_loop:
        mov     [.mime], 0

        cmp     word [esi], '--'        ; end of the POST data?
        je      .end_of_sections

        cmp     word [esi], $0a0d       ; CR,LF means start of section
        jne     .bad_request

        add     esi, 2

; look for Content-disposition header:

        mov     edi, cContentDisposition
        mov     ecx, cContentDisposition.length

        lea     eax, [esi+ecx]
        cmp     eax, [.end_data]
        jae     .bad_request

        repe cmpsb
        jne     .bad_request

        lea     eax, [esi+7]            ; name=""
        cmp     eax, [.end_data]
        jae     .bad_request

        cmp     dword [esi], 'name'
        jne     .bad_request

        cmp     word [esi+4], '="'
        jne     .bad_request

        lea     esi, [esi+6]
        mov     ebx, esi

        call    .search_quote
        jnc     .bad_request

        mov     ecx, esi
        sub     ecx, ebx

        stdcall StrNew
        stdcall StrCatMem, eax, ebx, ecx
        mov     [.name], eax            ; temporary storage for the name

; search for filename...

        inc     esi
        cmp     esi, [.end_data]
        jae     .bad_request

        cmp     word [esi], '; '
        jne     .get_content            ; expects double CR/LF at esi!


.it_is_file:
        add     esi, 2

        lea     eax, [esi+11]            ; filename=""
        cmp     eax, [.end_data]
        jae     .bad_request

        cmp     dword [esi], 'file'
        jne     .bad_request

        cmp     dword [esi+4], 'name'
        jne     .bad_request

        cmp     word [esi+8], '="'
        jne     .bad_request

        lea     esi, [esi+10]
        mov     ebx, esi

        call    .search_quote
        jnc     .bad_request

        mov     ecx, esi
        sub     ecx, ebx

        stdcall StrNew
        stdcall StrCatMem, eax, ebx, ecx
        mov     [.filename], eax            ; temporary storage for the filename


        inc     esi

        lea     eax, [esi+4]
        cmp     eax, [.end_data]
        jae     .bad_request

        cmp     dword [esi], $0a0d0a0d
        je      .get_content2

        cmp     word [esi], $0a0d
        jne     .bad_request

        add     esi, 2

        mov     edi, cContentType
        mov     ecx, cContentType.length

        lea     eax, [esi+ecx]
        cmp     eax, [.end_data]
        jae     .bad_request

        repe cmpsb
        jne     .bad_request

        mov     ebx, esi

        call    .search_crlf
        jnc     .bad_request

        mov     ecx, esi
        sub     ecx, ebx

        stdcall StrNew
        stdcall StrCatMem, eax, ebx, ecx
        mov     [.mime], eax            ; temporary storage for the mime type.


.get_content:
        cmp     dword [esi], $0a0d0a0d
        jne     .bad_request

.get_content2:

        add     esi, 4          ; here ESI points to the start of the data!
        mov     ebx, esi

        call    .search_boundary
        jnc     .bad_request

        sub     edx, 4

        cmp     word [edx], $0a0d
        jne     .bad_request

        mov     ecx, edx
        sub     ecx, ebx

        cmp     [.mime], 0
        jne     .content_file

; content string

        stdcall AddArrayItems, [.post_array], 1
        mov     [.post_array], edx
        mov     edi, eax

        xor     eax, eax
        xchg    eax, [.name]
        mov     [edi+TPostDataItem.name], eax

        stdcall StrNew
        stdcall StrCatMem, eax, ebx, ecx
        mov     [edi+TPostDataItem.data], eax

        jmp     .section_loop


.content_file:

; search the [.post_array] for existing item name.

        mov     edi, [.post_array]
        mov     eax, [edi+TArray.count]
        lea     edi, [edi+TArray.array]

.name_loop:
        dec     eax
        js      .add_new_name

        stdcall StrCompNoCase, [.name], [edi+8*eax]
        jnc     .name_loop

        lea     edi, [edi+8*eax]
        xor     eax, eax
        xchg    eax, [.name]
        stdcall StrDel, eax     ; the name is not needed from here.
        jmp     .add_file


.add_new_name:

; create new file set

        stdcall AddArrayItems, [.post_array], 1
        mov     [.post_array], edx
        mov     edi, eax

        xor     eax, eax
        xchg    eax, [.name]
        mov     [edi+TPostDataItem.name], eax

        stdcall CreateArray, sizeof.TPostFileItem
        mov     [edi+TPostDataItem.data], eax


.add_file:

; add file to existing file set

        stdcall AddArrayItems, [edi+TPostDataItem.data], 1
        mov     [edi+TPostDataItem.data], edx
        mov     edi, eax

        xor     eax, eax
        xor     edx, edx
        xchg    eax, [.filename]
        xchg    edx, [.mime]

        mov     [edi+TPostFileItem.filename], eax
        mov     [edi+TPostFileItem.mime], edx
        mov     [edi+TPostFileItem.size], ecx
        mov     [edi+TPostFileItem.data], ebx

        jmp     .section_loop


.end_of_sections:

; cleanup and return success

        stdcall StrDel, [.boundary]

.finish_ok:

        mov     eax, [.post_array]
        mov     [esp+4*regEAX], eax

        clc
        popad
        return


.bad_request:

; clean everything and exit.

        stdcall StrDel, [.boundary]
        stdcall StrDel, [.name]
        stdcall StrDel, [.mime]
        stdcall StrDel, [.filename]

        stdcall FreePostDataArray, [.post_array]

.finish_not_ok:

        stc
        popad
        return


; much simpler case of URL encoded items.


.url_encoded_post:

        cmp     esi, [.end_data]
        jae     .finish_ok

        mov     ebx, esi

.loop_name:
        cmp     byte [esi], '='
        je      .name_found

        inc     esi
        cmp     esi, [.end_data]
        jae     .bad_request

        jmp     .loop_name

.name_found:

        mov     ecx, esi
        sub     ecx, ebx

        stdcall StrNew
        stdcall StrCatMem, eax, ebx, ecx
        stdcall StrURLDecode, eax
        mov     [.name], eax

        inc     esi
        mov     ebx, esi

.loop_value:
        cmp     esi, [.end_data]
        jae     .value_found

        cmp     byte [esi], '&'
        je      .value_found

        inc     esi
        jmp     .loop_value


.value_found:

        mov     ecx, esi
        sub     ecx, ebx
        inc     esi

        stdcall AddArrayItems, [.post_array], 1
        mov     [.post_array], edx
        mov     edi, eax

        xor     eax, eax
        xchg    eax, [.name]

        mov     [edi+TPostDataItem.name], eax
        jecxz   .url_encoded_post

        stdcall StrNew
        stdcall StrCatMem, eax, ebx, ecx
        stdcall StrURLDecode, eax

        mov     [edi+TPostDataItem.data], eax
        jmp     .url_encoded_post



;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Some local subroutines, called when needed:


; searches [esi] for CR/LF and moves esi to point it.
; returns:
;          CF=1 if found
;          CF=0 the end of data has been reached.

.search_crlf:
        cmp     byte [esi], 13
        je      .cr_found

        inc     esi
        cmp     esi, [.end_data]
        jb      .search_crlf

.crlf_not_found:
        clc
        retn

.cr_found:
        inc     esi
        cmp     esi, [.end_data]
        jae     .crlf_not_found

        cmp     byte [esi], 10
        jne     .search_crlf

        dec     esi
        stc
        retn



; searches [esi] for '"' and moves esi to point it.
; returns:
;          CF=1 if found
;          CF=0 the end of data or end of a line has been reached without quote character found.

.search_quote:
        cmp     byte [esi], '"'
        je      .quote_found

        cmp     byte [esi], ' '
        jb      .quote_not_found

        inc     esi
        cmp     esi, [.end_data]
        jb      .search_quote

.quote_not_found:
        clc
        retn

.quote_found:
        stc
        retn



; Returns CF=1 if boundary has been found
;         ESI points at the end of the boundary string.
;         EDX points at the start of the boundary string.
;
;         CF=0 if reached to the end of the data.

.search_boundary:
        push    eax ecx edi


.boundary_loop:
        cmp     esi, [.end_data]
        jae     .boundary_exit

        cmp     word [esi], '--'
        je      .boundary_start_found

        inc     esi
        jmp     .boundary_loop


.boundary_start_found:

        add     esi, 2
        mov     edx, esi

        mov     ecx, [.sbound]
        mov     edi, [.pbound]

        lea     eax, [esi+ecx]
        cmp     eax, [.end_data]
        jae     .boundary_exit

        repe cmpsb
        jz      .boundary_found

        mov     esi, [edx-1]
        jmp     .boundary_loop

.boundary_found:
        stc

.boundary_exit:
        pop     edi ecx eax
        retn


endp











proc FreePostDataArray, .pPostDataArray
begin
        pushad

        mov     esi, [.pPostDataArray]
        test    esi, esi
        jz      .finish

        mov     ecx, [esi+TArray.count]
        lea     esi, [esi+TArray.array]

.loop:
        dec     ecx
        js      .free_array

        stdcall StrDel, [esi+TPostDataItem.name]

        mov     eax, [esi+TPostDataItem.data]
        test    eax, eax

        mov     ebx, StrDel
        cmp     eax, $c0000000
        jae     .free_data

        mov     ebx, FreePostFileSet

.free_data:

        stdcall ebx, eax

        add     esi, sizeof.TPostDataItem
        jmp     .loop

.free_array:
        stdcall FreeMem, [.pPostDataArray]

.finish:
        popad
        return
endp



proc FreePostFileSet, .pFileSet
begin
        pushad

        mov     esi, [.pFileSet]
        test    esi, esi
        jz      .finish

        mov     ecx, [esi+TArray.count]
        lea     esi, [esi+TArray.array]

.loop:
        dec     ecx
        js      .free_array

        stdcall StrDel, [esi+TPostFileItem.filename]
        stdcall StrDel, [esi+TPostFileItem.mime]

        add     esi, sizeof.TPostFileItem
        jmp     .loop

.free_array:
        stdcall FreeMem, [.pFileSet]

.finish:
        popad
        return
endp





proc GetPostString, .post_array, .name, .default
begin
        stdcall ValueByName, [.post_array], [.name]
        jc      .get_default

        cmp     eax, $c0000000
        jae     .found

.get_default:
        mov     eax, [.default]
        test    eax, eax
        jz      .finish

.found:
        stdcall StrDup, eax

.finish:
        return
endp