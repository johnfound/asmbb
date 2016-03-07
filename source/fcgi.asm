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












proc FCGI_output, .hSocket, .RequestID, .hString

.header FCGI_Header

begin
        pushad

        mov     [.header.version], 1
        mov     [.header.type], FCGI_STDOUT

        mov     eax, [.RequestID]
        mov     [.header.requestIdB1], ah
        mov     [.header.requestIdB0], al

        stdcall StrLen, [.hString]
        mov     edx, eax

        stdcall StrPtr, [.hString]
        mov     esi, eax

        mov     [.header.contentLengthB1], dh
        mov     [.header.contentLengthB0], dl

        mov     [.header.paddingLength], 0

        lea     eax, [.header]
        stdcall SocketSend, [.hSocket], eax, sizeof.FCGI_Header, 0
        jc      .finish

        stdcall SocketSend, [.hSocket], esi, edx, 0

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