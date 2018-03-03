



proc GetQueryItem, .hQuery, .itemname, .default
begin
        push    ecx esi

        cmp     [.hQuery], 0
        je      .not_found

        stdcall StrLen, [.itemname]
        mov     ecx, eax

        stdcall StrPos, [.hQuery], [.itemname]
        test    eax, eax
        jnz     .item_found

.not_found:
        mov     eax, [.default]
        test    eax, eax
        jz      .finish

        stdcall StrDupMem, eax
        jmp     .item_ok

.item_found:

        lea     esi, [eax+ecx]
        stdcall StrCharPos, esi, '&'
        jnz     .copy_item

        stdcall StrLen, esi
        lea     eax, [esi+eax]

.copy_item:
        sub     eax, esi
        stdcall StrExtract, esi, 0, eax

.item_ok:
        stdcall StrURLDecode, eax

.finish:
        pop     esi ecx
        return
endp



; returns 2 strings:
;
; eax - hashed password.
; edx - the salt used.


proc HashPassword, .hPassword
begin
; First the salt:

        stdcall GetRandomString, 32
        jc      .finish

        mov     edx, eax
        stdcall StrDup, eax
        push    eax

        stdcall StrCat, eax, [.hPassword]
        stdcall StrMD5, eax
        stdcall StrDel  ; from the stack
        clc

.finish:
        return
endp



; Sends an email to the SMTP server:
;
; Arguments:
;
;  .ip_smtp - String with the IP address of the smtp server.
;  .port    - port of the smtp server
;  .host    - string for the full domain name of the host. For example: "board.asm32.info"
;  .from    - The local user name. For example: "admin"
;  .to      - the full email address of the recipient.
;  .subject - string with the subject phrase.
;  .body    - string with the message body.
;  attachment - not user, for future use, when attachment files are to be implemented.
;
; Return:
;
;  EAX - string with the whole communication log. Can be used for debugging, loging or
;        to be discarded by calling StrDel
;
;  CF = 0 - the process of message sending finished successfuly.
;
;  CF = 1 - the email is not send, because of the different reasons.
;           Additional information on the fail reasons can be found in the log string.

proc SendEmail, .smtp_addr, .port, .host, .from, .to, .subject, .body, .attachment
.address TSocketAddressIn
.exit    dd ?
.time    dd ?
begin
        pushad

        stdcall GetEmailTimestamp
        mov     [.time], eax

        or      [.exit], -1

        stdcall StrNew
        mov     edi, eax

        stdcall SocketCreate, PF_INET, SOCK_STREAM, 0
        jc      .error_socket

        mov     ebx, eax
        mov     [.address.saFamily], AF_INET

        stdcall ResolveDomainIP, [.smtp_addr]
        bswap   eax

        stdcall LogEvent, "SMTP_IP", logNumber, eax, 0

        mov     edx, [.port]
        xchg    dl, dh

        mov     [.address.saPort], dx
        mov     [.address.saAddress], eax
        xor     eax, eax
        mov     dword [.address.saZero], eax
        mov     dword [.address.saZero+4], eax

        lea     eax, [.address]
        stdcall SocketConnect, ebx, eax
        jc      .error_connect


        xor     edx, edx

        stdcall ReadSMTPresponse, ebx, edx

        stdcall StrCat, edi, ecx
        stdcall StrDel, ecx

        cmp     eax, 220                        ; Ready response
        jne     .quit

        stdcall StrDupMem, "HELO "
        stdcall StrCat, eax, [.host]
        stdcall StrCat, eax, <txt 13, 10>

        stdcall StrCat, edi, eax
        stdcall SocketSendStr, ebx, eax
        stdcall StrDel, eax

        stdcall ReadSMTPresponse, ebx, edx
        stdcall StrCat, edi, ecx
        stdcall StrDel, ecx

        cmp     eax, 250                        ; OK response
        jne     .quit

        stdcall StrDupMem, "MAIL FROM: "
        stdcall StrCat, eax, [.from]
        stdcall StrCat, eax, txt "@"
        stdcall StrCat, eax, [.host]
        stdcall StrCat, eax, <txt 13, 10>

        stdcall StrCat, edi, eax
        stdcall SocketSendStr, ebx, eax
        stdcall StrDel, eax

        stdcall ReadSMTPresponse, ebx, edx
        stdcall StrCat, edi, ecx
        stdcall StrDel, ecx

        cmp     eax, 250                        ; OK response
        jne     .quit

        stdcall StrDupMem, "RCPT TO: "
        stdcall StrCat, eax, [.to]
        stdcall StrCat, eax, <txt 13, 10>

        stdcall StrCat, edi, eax
        stdcall SocketSendStr, ebx, eax
        stdcall StrDel, eax

        stdcall ReadSMTPresponse, ebx, edx
        stdcall StrCat, edi, ecx
        stdcall StrDel, ecx

        cmp     eax, 250                        ; OK response
        jne     .quit


        stdcall StrDupMem, <txt "DATA", 13, 10>

        stdcall StrCat, edi, eax
        stdcall SocketSendStr, ebx, eax
        stdcall StrDel, eax

        stdcall ReadSMTPresponse, ebx, edx
        stdcall StrCat, edi, ecx
        stdcall StrDel, ecx

        cmp     eax, 354                        ; OK response
        jne     .quit

; the email data composing.

        stdcall StrDupMem, "From: "
        stdcall StrCat, eax, [.from]
        stdcall StrCat, eax, txt "@"
        stdcall StrCat, eax, [.host]
        stdcall StrCat, eax, <txt 13, 10>

; to email:

        stdcall StrCat, eax, txt "To: "
        stdcall StrCat, eax, [.to]
        stdcall StrCat, eax, <txt 13, 10>

; timestamp:
        stdcall StrCat, eax, txt "Date: "
        stdcall StrCat, eax, [.time]
        stdcall StrCat, eax, <txt 13, 10>

; subject
        stdcall StrCat, eax, txt "Subject: "
        stdcall StrCat, eax, [.subject]
        stdcall StrCat, eax, <txt 13, 10, 13, 10>

; body
        stdcall StrCat, eax, [.body]
        stdcall StrCat, eax, <txt 13, 10>
        stdcall StrCat, eax, <txt ".", 13, 10>

        stdcall StrCat, edi, eax
        stdcall SocketSendStr, ebx, eax
        stdcall StrDel, eax


        stdcall ReadSMTPresponse, ebx, edx
        stdcall StrCat, edi, ecx
        stdcall StrDel, ecx

        cmp     eax, 250                ; the email is accepted!
        jne     .quit

        and     [.exit], 0

.quit:
        stdcall SocketSendStr, ebx, <"QUIT", 13, 10>

        stdcall ReadSMTPresponse, ebx, edx
        stdcall StrCat, edi, ecx
        stdcall StrDel, ecx

        stdcall SocketClose, ebx
        clc

.finish:
        stdcall StrDel, [.time]
        mov     [esp+4*regEAX], edi
        shr     [.exit], 1                      ; CF = 1 on error!
        popad
        return


.error_connect:
        stdcall StrCat, edi, <"Error host connecting.", 13, 10>
        stdcall SocketClose, ebx
        jmp     .finish

.error_socket:
        stdcall StrCat, edi, <"Error creating socket.", 13, 10>
        jmp     .finish
endp






proc ReadSMTPresponse, .hSocket, .buffer
.str dd ?
.res dd ?
begin
        pushad

        stdcall StrNew
        mov     [.str], eax
        mov     [.res], 0

        mov     edi, [.buffer]
        xor     ebx, ebx

.read_loop:
        stdcall SocketReadLine, [.hSocket], edi, 15000
        test    eax, eax
        jz      .end_of_read

        mov     edi, edx
        mov     ebx, eax

        stdcall StrCat, [.str], ebx
        stdcall StrCat, [.str], <txt 13, 10>

        stdcall StrToNum, ebx
        jc      .next_str

        mov     [.res], eax

        stdcall StrPtr, ebx
        movzx   eax, byte [eax+edx]

.next_str:
        stdcall StrDel, ebx
        cmp     eax, " "
        jne     .read_loop

.end_of_read:
        mov     eax, [.res]
        mov     ecx, [.str]

        mov     [esp+4*regEAX], eax
        mov     [esp+4*regECX], ecx
        mov     [esp+4*regEDX], edi

        popad
        return
endp






proc CheckEmail, .hEmail
begin
        push    eax

        stdcall StrCharPos, [.hEmail], "@"
        test    eax, eax
        jz      .bad

        stdcall StrLen, [.hEmail]
        cmp     eax, 5
        jb      .bad

        cmp     eax, 320
        ja      .bad

        clc
        pop     eax
        return

.bad:
        stc
        pop     eax
        return
endp




