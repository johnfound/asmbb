; NOTICE that this limit is only a second level of the protection.
; The proper limit must be set to the web server in order to be handled much earlier
; in the chain!
GENERAL_LIMIT_MAX_POST_LENGTH = 10*1024*1024   ; 10MB general limit on post data length.


; The types for FCGI_Header.type

FCGI_BEGIN_REQUEST      =  1
FCGI_ABORT_REQUEST      =  2
FCGI_END_REQUEST        =  3
FCGI_PARAMS             =  4
FCGI_STDIN              =  5
FCGI_STDOUT             =  6
FCGI_STDERR             =  7
FCGI_DATA               =  8
FCGI_GET_VALUES         =  9
FCGI_GET_VALUES_RESULT  = 10
FCGI_UNKNOWN_TYPE       = 11
FCGI_MAXTYPE            = FCGI_UNKNOWN_TYPE


struct FCGI_Header
  .version              db ?
  .type                 db ?

  .requestIdB1          db ?
  .requestIdB0          db ?
     label .requestId word at .requestIdB1

  .contentLengthB1      db ?
  .contentLengthB0      db ?
     label .contentLength word at .contentLengthB1

  .paddingLength        db ?
  .reserved             db ?
ends



; Values for role component of FCGI_BeginRequestBody

FCGI_RESPONDER   = 1
FCGI_AUTHORIZER  = 2
FCGI_FILTER      = 3


; Mask for flags component of FCGI_BeginRequestBody

FCGI_KEEP_CONN   = 1


struct FCGI_BeginRequestBody
  .roleB1   db ?
  .roleB0   db ?
     label .role word at .roleB1

  .flags    db ?
  .reserved rb 5
ends


struct FCGI_BeginRequest
  .header FCGI_Header
  .body   FCGI_BeginRequestBody
ends



; Values for protocolStatus component of FCGI_EndRequestBody

FCGI_REQUEST_COMPLETE   =  0
FCGI_CANT_MPX_CONN      =  1
FCGI_OVERLOADED         =  2
FCGI_UNKNOWN_ROLE       =  3



struct FCGI_EndRequestBody
  .appStatusB3          db ?
  .appStatusB2          db ?
  .appStatusB1          db ?
  .appStatusB0          db ?
  .protocolStatus       db ?
  .reserved             rb 3
ends


struct FCGI_EndRequest
  .header FCGI_Header
  .body   FCGI_EndRequestBody
ends



struct FCGI_UnknownTypeBody
  .type         db  ?          ; the unknown type that can't be processed.
  .reserved     rb  7
ends


struct FCGI_UnknownType
  .header  FCGI_Header
  .body    FCGI_UnknownTypeBody
ends





struct FCGI_NameValuePair11
  .nameLengthB0   db ?
  .valueLengthB0  db ?
  .data:
ends



struct FCGI_NameValuePair14
  .nameLengthB0   db ?
  .valueLengthB3  db ?
  .valueLengthB2  db ?
  .valueLengthB1  db ?
  .valueLengthB0  db ?
  .data:
ends


struct FCGI_NameValuePair41
  .nameLengthB3   db ?
  .nameLengthB2   db ?
  .nameLengthB1   db ?
  .nameLengthB0   db ?
  .valueLengthB0  db ?
  .data:
ends


struct FCGI_NameValuePair44
  .nameLengthB3   db ?
  .nameLengthB2   db ?
  .nameLengthB1   db ?
  .nameLengthB0   db ?
  .valueLengthB3  db ?
  .valueLengthB2  db ?
  .valueLengthB1  db ?
  .valueLengthB0  db ?
  .data:
ends


MAX_THREAD_CNT = 20

uglobal
  ThreadCnt dd ?
endg


;
; The main FastCGI listening loop.
;
; On accepting connection, starts a new thread in the procedure procServeRequest
; and continues to listen for new connections.
;

proc Listen
.addr TSocketAddressUn
begin

.loop:
        cmp     [ThreadCnt], MAX_THREAD_CNT
        jl      .accept_new

.wait_threads:
        stdcall Sleep, 1
        cmp     [ThreadCnt], MAX_THREAD_CNT/2
        jg      .wait_threads

.accept_new:
        stdcall SocketAccept, [STDIN], 0
        jc      .make_socket

        stdcall ThreadCreate, procServeRequest, eax

        jmp     .loop

.make_socket:

        cmp     [fOwnSocket], 0
        jne     .finish

; delete the socket file, if remaining from the previous crash.
        stdcall FileDelete, pathMySocket

        stdcall SocketCreate, PF_UNIX, SOCK_STREAM, 0
        jc      .finish

        mov     [STDIN], eax
        mov     [fOwnSocket], 1

        stdcall SocketSetOption, [STDIN], soReuseAddr, TRUE
        stdcall SocketSetOption, [STDIN], soLinger, 5

        mov     [.addr.saFamily], AF_UNIX

        mov     esi, pathMySocket
        mov     ecx, pathMySocket.length + 1
        lea     edi, [.addr.saPath]

        rep movsb

        lea     eax, [.addr]
        stdcall SocketBind, [STDIN], eax
        jc      .finish

; Make the socket writable for everyone. This allows the web server and
; the AsmBB engine run with different users.

        mov     eax, sys_chmod
        mov     ebx, pathMySocket
        mov     ecx, 666o
        int     80h

        stdcall SocketListen, [STDIN], -1       ; maximum allowed by the system.
        jnc     .loop


.finish:
        return
endp


pathMySocket text "./engine.sock"





; One connection serving thread procedure.


ffcgiExpectStdIn  = $80000000
ffcgiExpectParams = $40000000


proc procServeRequest, .hSocket

.requestID      dd ?
.requestFlags   dd ?
.requestParams  dd ?
.requestPost    dd ?    ; pointer to TByteStream

.start_time     dd ?

begin
        lock inc [ThreadCnt]

        xor     eax, eax
        mov     [.requestParams], eax
        mov     [.requestPost], eax
        xor     esi, esi

.main_loop:

        call    .FreeAllocations

.pack_loop:
        stdcall FreeMem, esi
        xor     esi, esi

        stdcall FCGI_read_pack, [.hSocket]
        jc      .finish

        mov     esi, eax
        movzx   eax, [esi+FCGI_Header.type]

        cmp     eax, FCGI_BEGIN_REQUEST
        je      .begin_request

        cmp     eax, FCGI_PARAMS
        je      .get_params

        cmp     eax, FCGI_STDIN
        je      .get_stdin

        cmp     eax, FCGI_ABORT_REQUEST
        je      .request_complete

; send back unknown type record.

        xor     edx, edx
        mov     dx, [esi+FCGI_Header.requestId]
        xchg    dl, dh

        stdcall FCGI_send_unknown_type, [.hSocket], edx, eax

        jmp     .pack_loop


; Processing of FCGI_BEGIN_REQUEST

.begin_request:

        xor     eax, eax
        xor     edx, edx
        mov     ax, [esi+FCGI_BeginRequest.header.requestId]
        mov     dx, [esi+FCGI_BeginRequest.body.role]
        xchg    al, ah
        xchg    dl, dh

        cmp     dx, FCGI_RESPONDER
        jne     .unknown_role

        cmp     [.requestID], 0
        jne     .mx_disabled

        mov     [.requestID], eax
        or      [.requestFlags], ffcgiExpectParams or ffcgiExpectStdIn

        movzx   ecx, [esi+FCGI_BeginRequest.body.flags]
        or      [.requestFlags], ecx

        stdcall GetFineTimestamp
        mov     [.start_time], eax

        jmp     .pack_loop


.unknown_role:

        stdcall FCGI_send_end_request, [.hSocket], eax, FCGI_UNKNOWN_ROLE
        jmp     .pack_loop


.mx_disabled:

        stdcall FCGI_send_end_request, [.hSocket], eax, FCGI_CANT_MPX_CONN
        jmp     .pack_loop


; Processing of FCGI_PARAMS


.get_params:

        xor     eax, eax
        mov     ax, [esi+FCGI_Header.requestId]
        xchg    al, ah

        cmp     eax, [.requestID]
        jne     .mx_disabled

        xor     edx, edx
        mov     dx, [esi+FCGI_Header.contentLength]
        xchg    dl, dh

        test    edx, edx
        jz      .param_received          ; this is the last part of FCGI_PARAMS stream, so go to serve the request.

; add the package to the name/value pairs list.

        lea     edi, [esi+sizeof.FCGI_Header]

        stdcall FCGI_Decode_name_value_pairs, [.requestParams], edi, edx
        mov     [.requestParams], eax

        jmp     .pack_loop


.param_received:
        and     [.requestFlags], not ffcgiExpectParams

        test    [.requestFlags], ffcgiExpectStdIn
        jz      .serve_request

        jmp     .pack_loop


; Processing FCGI_STDIN data stream on the post requests.

.get_stdin:

        xor     eax, eax
        mov     ax, [esi+FCGI_Header.requestId]
        xchg    al, ah

        xor     ecx, ecx
        mov     cx, [esi+FCGI_Header.contentLength]
        xchg    cl, ch

        test    ecx, ecx
        jz      .stdin_received           ; no more packages to wait for FCGI_STDIN

; add the package to the post data byte stream.

        push    esi

        cmp     [.requestPost], 0
        jne     .bytes_ok

        stdcall BytesCreate, 4096
        mov     [.requestPost], eax

.bytes_ok:

        lea     esi, [esi+sizeof.FCGI_Header]

        stdcall BytesGetRoom, [.requestPost], ecx
        mov     [.requestPost], ebx

        rep movsb
        xor     eax, eax
        stosd

        pop     esi

        cmp     [ebx+TByteStream.size], GENERAL_LIMIT_MAX_POST_LENGTH
        ja      .error_request_too_big

        jmp     .pack_loop


.stdin_received:
        and     [.requestFlags], not ffcgiExpectStdIn

        test    [.requestFlags], ffcgiExpectParams
        jz      .serve_request

        jmp     .pack_loop


.error_request_too_big:         ; this request should not be passed to the ServeOneRequest procedure,
                                ; because it contains invalid data.

cError413 text "Status: 413 Payload Too Large", 13, 10, "Content-type: text/html", 13, 10, 13, 10, "<html><head></head><body><h1>Payload Too Large</h1></body></html>", 13, 10

        and     [.requestFlags], not FCGI_KEEP_CONN     ; force the connection close!

        stdcall FCGI_output, [.hSocket], [.requestID], cError413, cError413.length, TRUE
        jmp     .request_complete


; Processing of the request. Here all data is ready, so serve the request!

.serve_request:

        ; SERVE THE REQUEST HERE
        ; returns CF=1 if the socket must to be added to the events listener list
        ; EDX:EAX in this case contains the events mask that the request want to receive.
        ; if CF=0 the request is entirely served.

        stdcall ServeOneRequest, [.hSocket], [.requestID], [.requestParams], [.requestPost], [.start_time]
        jc      .exit    ; long living connection

.request_complete:

        stdcall FCGI_send_end_request, [.hSocket], [.requestID], FCGI_REQUEST_COMPLETE
        jc      .finish

        test    [.requestFlags], FCGI_KEEP_CONN
        jnz     .main_loop

.finish:
        stdcall SocketClose, [.hSocket]

.exit:
        stdcall FreeMem, esi
        call    .FreeAllocations

        lock dec [ThreadCnt]

        stdcall Terminate, 0

;...............................................................


.FreeAllocations:
        xor     eax, eax

        cmp     [.requestParams], eax
        je      .params_ok

        stdcall FreeNameValueArray, [.requestParams]
        mov     [.requestParams], eax

.params_ok:
        mov     edi, [.requestPost]
        test    edi, edi
        jz      .post_ok

; paranoid post data cleanup...

        mov     edx, [edi+TByteStream.size]
        lea     edi, [edi+TByteStream.data]

        mov     ecx, edx
        shr     ecx, 2
        rep stosd

        mov     ecx, edx
        and     ecx, 3
        rep stosb

; free the post data array...

        stdcall FreeMem, [.requestPost]
        mov     [.requestPost], eax

.post_ok:
        mov     [.requestFlags], eax
        mov     [.requestID], eax

        retn
endp




;_______________________________________________________________________________________________
;
; proc FCGI_output
;
; Outputs data to the FCGI_STDOUT stream. The data can be split among multiply FCGI records
; with maximal size of 65535 bytes.
;
; Arguments:
;
;  .hSocket   - The socket where the data will be streamed.
;  .RequestID - The ID of the request the data belongs to.
;  .pData     - Pointer to the data buffer.
;  .Size      - The size of the data. 0 is valid size and causes the stream to be closed.
;  .final     - boolean flag, specifying whether this is the final block of the stream.
;
; Returns:
;  CF = 0 The transmission completed successfuly.
;  CF = 1 Some error occured.
;
;_______________________________________________________________________________________________

proc FCGI_output, .hSocket, .RequestID, .pData, .Size, .final

.header FCGI_Header
.buffer rb 16

begin
        pushad

        xor     eax, eax
        lea     edi, [.header]
        mov     ecx, ( sizeof.FCGI_Header + 16 ) / 4
        rep stosd


        mov     [.header.version], 1
        mov     [.header.type], FCGI_STDOUT

        mov     eax, [.RequestID]
        mov     [.header.requestIdB1], ah
        mov     [.header.requestIdB0], al

        mov     edx, [.Size]
        mov     esi, [.pData]


.data_loop:
        mov     ecx, $ffff
        cmp     edx, ecx
        cmovb   ecx, edx                        ; ecx = min($ffff, edx)

        lea     ebx, [ecx+7]
        and     ebx, $fffffff8
        sub     ebx, ecx                        ; ebx = padding bytes count.

        mov     [.header.contentLengthB1], ch
        mov     [.header.contentLengthB0], cl
        mov     [.header.paddingLength], bl

        mov     eax, [.final]
        or      eax, ecx
        jz      .end_ok         ; exit without finalizing the stream.

        lea     eax, [.header]

        stdcall SocketSendAll, [.hSocket], eax, sizeof.FCGI_Header
        jc      .finish

        test    edx, edx
        jz      .end_ok

        stdcall SocketSendAll, [.hSocket], esi, ecx
        jc      .finish

        test    ebx, ebx
        jz      .padding_ok

        lea     eax, [.buffer]
        stdcall SocketSendAll, [.hSocket], eax, ebx   ; send 0 as a padding bytes.
        jc      .finish

.padding_ok:
        add     esi, ecx
        sub     edx, ecx
        jmp     .data_loop

.end_ok:
        clc

.finish:
        popad
        return
endp




proc FCGI_outputText, .hSocket, .RequestID, .pText, .final
begin
        pushad

        xor     ecx, ecx
        mov     edx, [.pText]
        test    edx, edx
        jz      .send_second

        mov     ecx, [edx+TText.Length]
        mov     ebx, [edx+TText.GapBegin]
        sub     ecx, [edx+TText.GapEnd]

        xor     eax, eax
        test    ecx, ecx
        cmovz   eax, [.final]

        test    ebx, ebx
        jz      .first_ok

        stdcall FCGI_output, [.hSocket], [.RequestID], edx, ebx, eax
        jc      .finish

.first_ok:
        test    ecx, ecx
        jnz     .second

        test    ebx, ebx
        jnz     .finish

.second:
        add     edx, [edx+TText.GapEnd]

.send_second:

        stdcall FCGI_output, [.hSocket], [.RequestID], edx, ecx, [.final]

.finish:
        popad
        return
endp




proc FCGI_send_end_request, .hSocket, .RequestID, .status

.rec    FCGI_EndRequest

begin
        pushad

        xor     eax, eax
        lea     edi, [.rec]
        mov     ecx, sizeof.FCGI_EndRequest / 4
        rep stosd

        mov     [.rec.header.version], 1
        mov     [.rec.header.type], FCGI_END_REQUEST

        mov     eax, [.RequestID]
        mov     [.rec.header.requestIdB1], ah
        mov     [.rec.header.requestIdB0], al

        mov     [.rec.header.contentLengthB0], sizeof.FCGI_EndRequestBody

        mov     al, byte [.status]
        mov     [.rec.body.protocolStatus], al

        lea     eax, [.rec]
        stdcall SocketSendAll, [.hSocket], eax, sizeof.FCGI_EndRequest

        popad
        return
endp




proc FCGI_send_unknown_type, .hSocket, .RequestID, .unknown_type

.rec FCGI_UnknownType

begin
        pushad

        xor     eax, eax
        lea     edi, [.rec]
        mov     ecx, sizeof.FCGI_UnknownType / 4
        rep stosd

        mov     [.rec.header.version], 1
        mov     [.rec.header.type], FCGI_UNKNOWN_TYPE

        mov     eax, [.RequestID]
        mov     [.rec.header.requestIdB1], ah
        mov     [.rec.header.requestIdB0], al

        mov     [.rec.header.contentLengthB0], sizeof.FCGI_UnknownType

        mov     al, byte [.unknown_type]
        mov     [.rec.body.type], al

        lea     eax, [.rec]
        stdcall SocketSendAll, [.hSocket], eax, sizeof.FCGI_UnknownType

        popad
        return
endp




proc FCGI_read_pack, .hSocket
.header FCGI_Header
.ptr    dd ?
begin
        pushad

        lea     eax, [.header]
        stdcall SocketReceive, [.hSocket], eax, sizeof.FCGI_Header, 0
        jc      .error
        test    eax, eax
        jz      .error

        mov     al, [.header.contentLengthB0]
        mov     ah, [.header.contentLengthB1]

        movzx   ebx, ax
        movzx   eax, [.header.paddingLength]
        add     ebx, eax

        lea     ecx, [ebx+sizeof.FCGI_Header]

        stdcall GetMem, ecx
        mov             edi, eax
        mov     [.ptr], eax

        lea     esi, [.header]
        mov     ecx, sizeof.FCGI_Header/4
        rep movsd

        test    ebx, ebx
        jz      .finish

.read_data:
        stdcall SocketReceive, [.hSocket], edi, ebx, 0
        jc      .error2
        test    eax, eax
        jz      .error2

        add     edi, eax
        sub     ebx, eax
        jnz     .read_data


.finish:
        popad
        mov     eax, [.ptr]
        clc
        return

.error2:

        stdcall FreeMem, [.ptr]

.error:

        stc
        popad
        return
endp







proc FCGI_Decode_name_value_pairs, .pArray, .pData, .size
.name  dd ?
.value dd ?
begin
        pushad


        mov     esi, [.pData]
        mov     edx, [.pArray]
        test    edx, edx
        jnz     .array_ok

        stdcall CreateArray, 8
        mov     edx, eax

.array_ok:


.loop:
        call    .get_length              ; name length
        mov     ecx, eax

        call    .get_length              ; value length
        push    eax

        stdcall StrNew
        mov     [.name], eax

        stdcall StrSetCapacity, eax, ecx
        mov     [eax+string.len], ecx
        sub     [.size], ecx

        mov     edi, eax
        rep movsb
        xor     eax, eax
        stosd

        pop     ecx
        stdcall StrNew
        mov     [.value], eax

        stdcall StrSetCapacity, eax, ecx
        mov     [eax+string.len], ecx
        sub     [.size], ecx

        mov     edi, eax
        rep movsb
        xor     eax, eax
        stosd

        stdcall AddArrayItems, edx, 1

        pushd   [.value] [.name]
        popd    [eax] [eax+4]

        cmp     [.size], 0
        jg      .loop


        mov     [esp+4*regEAX], edx
        popad
        return


.get_length:

        test    byte [esi], $80
        jz      .one_byte

; four byte length
        mov     eax, [esi]
        and     al, $7f

        bswap   eax
        add     esi, 4
        sub     [.size], 4
        retn

.one_byte:
        movzx   eax, byte [esi]
        inc     esi
        dec     [.size]
        retn

endp




proc FreeNameValueArray, .pArray
begin
        pushad

        mov     esi, [.pArray]
        test    esi, esi
        jz      .finish

        mov     ecx, [esi+TArray.count]

.loop:
        dec     ecx
        js      .free_array

        stdcall StrDel, [esi+TArray.array+8*ecx]
        stdcall StrDel, [esi+TArray.array+8*ecx+4]
        jmp     .loop

.free_array:
        stdcall FreeMem, [.pArray]

.finish:
        popad
        return
endp








proc ValueByName, .pArray, .name
begin
        pushad

        mov     esi, [.pArray]
        test    esi, esi
        jz      .not_found

        xor     ecx, ecx

.loop:
        cmp     ecx, [esi+TArray.count]
        jae     .not_found

        stdcall StrCompNoCase, [esi+TArray.array+8*ecx], [.name]
        jc      .found

        inc     ecx
        jmp     .loop

.not_found:
        stc
        popad
        return

.found:
        mov     eax, [esi+TArray.array+8*ecx+4] ; the value
        mov     [esp+4*regEAX], eax
        popad
        clc
        return
endp






