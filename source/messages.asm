


sqlGetErrorText text "select msg, header, link from messages where id = ?"

cGoRoot       text "/"
cUnknownError text "unknown_error"


proc ShowForumMessage, .pSpecial
.stmt dd ?
begin
        pushad

        mov     esi, [.pSpecial]

        mov     edx, [esi+TSpecialParams.cmd_list]
        mov     ebx, cUnknownError
        cmp     [edx+TArray.count], 0
        cmovne  ebx, [edx+TArray.array]

        stdcall TextCreate, sizeof.TText
        stdcall TextCat, eax, txt '<div class="message_block"><h1>'
        mov     edi, edx

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetErrorText, -1, eax, 0

        stdcall StrLen, ebx
        mov     ecx, eax
        stdcall StrPtr, ebx

        cinvoke sqliteBindText, [.stmt], 1, eax, ecx, SQLITE_STATIC
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .unknown_msg

        cinvoke sqliteColumnText, [.stmt], 1

        stdcall StrCat, [esi+TSpecialParams.page_title], eax
        stdcall TextCat, edi, eax
        stdcall TextCat, edx, txt '</h1><div class="message">'
        mov     edi, edx

        cinvoke sqliteColumnText, [.stmt], 0
        stdcall TextCat, edi, eax
        stdcall TextCat, edx, txt '</div><br>'
        mov     edi, edx

        cinvoke sqliteColumnType, [.stmt], 2
        cmp     eax, SQLITE_NULL
        je      .add_back_link

        cinvoke sqliteColumnText, [.stmt], 2
        stdcall TextCat, edi, eax
        jmp     .finalize

; now insert link to the previous page.

.add_back_link:
        stdcall TextCat, edi, txt '<a href="'

        stdcall GetBackLink, esi
        pushf
        stdcall TextCat, edx, eax
        stdcall StrDel, eax
        popf
        jnc     .back

        stdcall TextCat, edx, txt '">Home</a>'
        jmp     .finalize

.back:
        stdcall TextCat, edx, txt '">Go back</a>'

.finalize:
        stdcall TextCat, edx, txt '</div>'
        mov     [esp+4*regEAX], edx

        cinvoke sqliteFinalize, [.stmt]

        clc
        popad
        return


.unknown_msg:
        stdcall TextCat, edi, <'ERROR!</h1><div class="message">',     \
                            'Three things are certain:', 13, 10,                                   \
                            'Death, taxes and lost data.', 13, 10,                                 \
                            'Guess which has occurred.', 13, 10,                                   \
                            '</div><br>', 13, 10 >
        mov     edi, edx
        jmp     .add_back_link
endp





