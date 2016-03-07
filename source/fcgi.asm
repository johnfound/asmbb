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
        test    eax, eax
        jz      .error
        jc      .error

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

.read_data:
        stdcall SocketReceive, [.hSocket], edi, ebx, 0
        jc      .error2
        test    eax, eax
        jz      .error2

        add     edi, eax
        sub     ebx, eax
        jnz     .read_data

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