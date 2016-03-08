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


;
; The main FastCGI listening loop.
;
; On accepting connection, starts a new thread in the procedure procServeRequest
; and continues to listen for new connections.
;

proc Listen
begin

.loop:
        stdcall SocketAccept, [STDIN], 0
        jc      .finish

        stdcall ThreadCreate, procServeRequest, eax
        jmp     .loop

.finish:
        return
endp






; One connection serving thread procedure.


ffcgiExpectStdIn  = $80000000
ffcgiExpectParams = $40000000


proc procServeRequest, .hSocket

.requestID      dd ?
.requestFlags   dd ?
.requestParams  dd ?
.requestPost    dd ?    ; pointer to TByteStream

begin
        pushad

        DebugMsg "FCGI thread started"


        xor     eax, eax
        mov     [.requestParams], eax
        mov     [.requestPost], eax

.main_loop:
        DebugMsg "Main loop enter."

        xor     eax, eax

        cmp     [.requestParams], eax
        je      .params_ok

        stdcall FreeNameValueArray, [.requestParams]
        mov     [.requestParams], eax

.params_ok:
        cmp     [.requestPost], eax
        je      .post_ok

        stdcall FreeMem, [.requestPost]
        mov     [.requestPost], 0

.post_ok:

        mov     [.requestFlags], eax
        mov     [.requestID], eax


.pack_loop:
        DebugMsg "Now wait for some package"

        stdcall FCGI_read_pack, [.hSocket]
        jc      .finish

        mov     esi, eax
        movzx   eax, [esi+FCGI_Header.type]

        OutputValue "Package received. Type = ", eax, 10, -1

        cmp     eax, FCGI_BEGIN_REQUEST
        je      .begin_request

        cmp     eax, FCGI_PARAMS
        je      .get_params

        cmp     eax, FCGI_STDIN
        je      .get_stdin

        cmp     eax, FCGI_ABORT_REQUEST
        je      .abort_request

; send back unknown type record.

        xor     edx, edx
        mov     dx, word [esi+FCGI_Header.requestIdB1]
        xchg    dl, dh

        stdcall FCGI_send_unknown_type, [.hSocket], edx, eax


.free_pack:
        stdcall FreeMem, esi
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
        or      [.requestFlags], ffcgiExpectParams

        movzx   ecx, [esi+FCGI_BeginRequest.body.flags]
        or      [.requestFlags], ecx

        jmp     .free_pack


.unknown_role:

        DebugMsg "Unknown role!"

        stdcall FCGI_send_end_request, [.hSocket], eax, FCGI_UNKNOWN_ROLE
        jmp     .free_pack


.mx_disabled:

        DebugMsg "MX disabled!"

        stdcall FCGI_send_end_request, [.hSocket], eax, FCGI_CANT_MPX_CONN
        jmp     .free_pack


.abort_request:

        DebugMsg "Abort request received!"

        xor     eax, eax
        mov     ax, [esi+FCGI_Header.requestId]
        xchg    al, ah

        stdcall FCGI_send_end_request, [.hSocket], eax, FCGI_REQUEST_COMPLETE

        jmp     .main_loop


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

        OutputValue "Params length: ", edx, 10, -1


        test    edx, edx
        jz      .param_received          ; this is the last part of FCGI_PARAMS stream, so go to serve the request.

; add the package to the name/value pairs list.

        lea     edi, [esi+sizeof.FCGI_Header]

        stdcall FCGI_Decode_name_value_pairs, [.requestParams], edi, edx
        mov     [.requestParams], eax

        jmp     .free_pack


.param_received:

        DebugMsg "All FCGI_PARAMS blocks received."

        and     [.requestFlags], not ffcgiExpectParams

        test    [.requestFlags], ffcgiExpectStdIn
        jnz     .free_pack

        DebugMsg "Still no FCGI_STDIN blocks, so check the method."

        stdcall ValueByName, [.requestParams], "REQUEST_METHOD"
        jc      .serve_request                                          ; not found method

        DebugMsg "Method is?"

        stdcall StrCompNoCase, eax, txt "POST"
        jnc     .serve_request                          ; it is not the POST request, so no need to wait for more data.

        DebugMsg "Method is POST!"

        or      [.requestFlags], ffcgiExpectStdIn
        jmp     .free_pack



; Processing FCGI_STDIN data stream on the post requests.

.get_stdin:

        xor     eax, eax
        mov     ax, [esi+FCGI_Header.requestId]
        xchg    al, ah

        cmp     eax, [.requestID]
        jne     .mx_disabled

        xor     ecx, ecx
        mov     cx, [esi+FCGI_Header.contentLength]
        xchg    cl, ch

        OutputValue "STDIN length: ", ecx, 10, -1

        test    ecx, ecx
        jz      .stdin_received           ; no more packages to wait for FCGI_STDIN

; add the package to the name/value pairs list.

        push    esi

        cmp     [.requestPost], 0
        jne     .bytes_ok

        stdcall BytesCreate, 1024
        mov     [.requestPost], eax

.bytes_ok:

        lea     esi, [esi+sizeof.FCGI_Header]

        stdcall BytesGetRoom, [.requestPost], ecx
        mov     [.requestPost], ebx

        rep movsb
        xor     eax, eax
        stosd

        pop     esi
        jmp     .free_pack

.stdin_received:
        and     [.requestFlags], not ffcgiExpectStdIn

        test    [.requestFlags], ffcgiExpectParams
        jz      .serve_request

        jmp     .free_pack


; Processing of the request. Here all data is ready, so serve the request!

.serve_request:

        stdcall FreeMem, esi

        DebugMsg "Going to call ServeOneRequest"

        stdcall ServeOneRequest, [.hSocket], [.requestID], [.requestParams], [.requestPost]
        jc      .finish

        DebugMsg "ServeOneRequest returned"

        stdcall FCGI_send_end_request, [.hSocket], [.requestID], FCGI_REQUEST_COMPLETE
        jc      .finish

        test    [.requestFlags], FCGI_KEEP_CONN
        jnz     .main_loop

.finish:
        DebugMsg "Terminate thread FCGI"

        stdcall SocketClose, [.hSocket]
        popad
        return

endp













proc FCGI_output, .hSocket, .RequestID, .pData, .Size, .final

.header FCGI_Header
.buffer rb 16

begin
        pushad

        mov     [.header.version], 1
        mov     [.header.type], FCGI_STDOUT

        xor     eax, eax
        mov     dword [.buffer], eax
        mov     dword [.buffer+4], eax

        mov     eax, [.RequestID]
        mov     [.header.requestIdB1], ah
        mov     [.header.requestIdB0], al

        mov     edx, [.Size]
        mov     esi, [.pData]


.data_loop:
        cmp     [.final], 0
        jne     .final_ok

        test    edx, edx
        jz      .end_ok


.final_ok:
        mov     ecx, edx
        cmp     ecx, $10000
        jb      .size_ok

        mov     ecx, $ffff

.size_ok:
        sub     edx, ecx

        OutputValue "Output STDOUT length:", ecx, 10, -1

        mov     [.header.contentLengthB1], ch
        mov     [.header.contentLengthB0], cl

        lea     ebx, [ecx+7]
        and     ebx, $fffffff8
        sub     ebx, ecx

        OutputValue "Output STDOUT padding:", ebx, 10, -1

        mov     [.header.paddingLength], bl

        lea     eax, [.header]
        stdcall SocketSend, [.hSocket], eax, sizeof.FCGI_Header, 0
        jc      .finish

        DebugMsg "Header sent"

        test    ecx, ecx
        jz      .end_ok

.send_part:

        OutputValue "Count to send:", ecx, 10, -1

        stdcall SocketSend, [.hSocket], esi, ecx, 0
        jc      .finish

        OutputValue "Count really sent:", eax, 10, -1

        add     esi, eax
        sub     ecx, eax
        jnz     .send_part

        OutputValue "Padding to sent:", ebx, 10, -1

        test    ebx, ebx
        jz      .padding_ok

        lea     eax, [.buffer]
        stdcall SocketSend, [.hSocket], eax, ebx, 0     ; send 0 as a padding bytes.
        jc      .finish

.padding_ok:
        OutputValue "More date to loop?", edx, 10, -1

        jmp     .data_loop

;        test    edx, edx
;        jnz     .data_loop


.end_ok:
        clc

.finish:
        popad
        return
endp



proc FCGI_send_end_request, .hSocket, .RequestID, .status

.rec    FCGI_EndRequest

begin
        pushad

        mov     [.rec.header.version], 1
        mov     [.rec.header.type], FCGI_END_REQUEST

        mov     eax, [.RequestID]
        mov     [.rec.header.requestIdB1], ah
        mov     [.rec.header.requestIdB0], al

        mov     [.rec.header.contentLengthB1], 0
        mov     [.rec.header.contentLengthB0], sizeof.FCGI_EndRequestBody
        mov     [.rec.header.paddingLength], 0

        mov     dword [.rec.body.appStatusB3], 0
        mov     al, byte [.status]
        mov     [.rec.body.protocolStatus], al

        lea     eax, [.rec]
        stdcall SocketSend, [.hSocket], eax, sizeof.FCGI_EndRequest, 0

        popad
        return
endp




proc FCGI_send_unknown_type, .hSocket, .RequestID, .unknown_type

.rec FCGI_UnknownType

begin
        pushad

        mov     [.rec.header.version], 1
        mov     [.rec.header.type], FCGI_UNKNOWN_TYPE

        mov     eax, [.RequestID]
        mov     [.rec.header.requestIdB1], ah
        mov     [.rec.header.requestIdB0], al

        mov     [.rec.header.contentLengthB1], 0
        mov     [.rec.header.contentLengthB0], sizeof.FCGI_UnknownType
        mov     [.rec.header.paddingLength], 0

        mov     al, byte [.unknown_type]
        mov     [.rec.body.type], al

        lea     eax, [.rec]
        stdcall SocketSend, [.hSocket], eax, sizeof.FCGI_UnknownType, 0

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
        mov     edi, eax
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
        DebugMsg "Read pack: error2"

        stdcall FreeMem, [.ptr]

.error:
        DebugMsg "Read pack: error1"

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