GENERAL_LIMIT_MAX_POST_LENGTH = 1024*1024   ; 1MB general limit on post data length. Everything above will be trunkated.

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
.addr TSocketAddressUn
begin

.loop:

        stdcall SocketAccept, [STDIN], 0
        jc      .make_socket

        stdcall ThreadCreate, procServeRequest, eax

        jmp     .loop

.make_socket:

        cmp     [fOwnSocket], 0
        jne     .finish

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

        stdcall SocketListen, [STDIN], 1
        jnc     .loop


.finish:
        return
endp


pathMySocket text "./engine.sock"


;create table if not exists RequestsLog (
;  process_id integer,      -- the unique process id
;  timestamp  integer,
;  event      integer,      -- what event is logged - start process, end process, start request, end request
;  value      text          -- details in variable form.
;)

; GOOD report queries:
;
; select process_id, strftime('%d.%m.%Y %H:%M:%S', timestamp, 'unixepoch') as `Time`, E.name, value from log L left join Events E on event = E.id order by timestamp desc;
;
; select strftime('%d.%m.%Y %H:%M:%S', timestamp, 'unixepoch') as `Time`, E.name, value from log L left join Events E on L.event = E.id where L.event = 3 order by L.timestamp, L.rowID desc;
;
;
; -- Gives the 10 slower requests, value in [ms]:
;
; select E.name || " : " || value, cast(L.runtime as float)/1000 from log L left join Events E on L.event = E.id where L.event = 3 order by runtime desc limit 10;
;
;
; -- Shows the process start and end events:
;
; select strftime('%d.%m.%Y %H:%M:%S', L.timestamp, 'unixepoch') as Time, process_id, E.name, L.value, L.runtime from log L left join Events E on (L.event = E.id) where E.name in ("ScriptStart", "ScriptEnd") order by L.rowID;
;
;

sqlLogEvent text "insert into Log (process_id, timestamp, event, value, runtime) values (?1, strftime('%s','now'), ?2, ?3, ?4 )"
sqlCleanLog text "delete from Log where timestamp < strftime('%s','now') - 86400"


logNULL   = 0
logNumber = 1
logText   = 2


proc LogEvent, .event, .log_type, .value, .runtime
.stmt dd ?
begin
        pushad

        stdcall GetParam, "log_events", gpInteger
        test    eax, eax
        jz      .finish

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlLogEvent, sqlLogEvent.length, eax, 0

        cinvoke sqliteBindInt, [.stmt], 1, [ProcessID]

        cmp     [.event], 0
        je      .event_ok

        stdcall StrLen, [.event]
        mov     ecx, eax
        stdcall StrPtr, [.event]
        cinvoke sqliteBindText, [.stmt], 2, eax, ecx, SQLITE_STATIC

.event_ok:
        cmp     [.log_type], logNULL
        je      .value_ok

        cmp     [.log_type], logNumber
        je      .value_number

        cmp     [.log_type], logText
        je      .value_text

        jmp     .value_ok

.value_number:
        cinvoke sqliteBindInt, [.stmt], 3, [.value]
        jmp     .value_ok

.value_text:
        stdcall StrLen, [.value]
        mov     ecx, eax
        stdcall StrPtr, [.value]
        cinvoke sqliteBindText, [.stmt], 3, eax, ecx, SQLITE_STATIC

.value_ok:
        cmp     [.runtime], 0
        je      .runtime_ok

        cinvoke sqliteBindInt, [.stmt], 4, [.runtime]

.runtime_ok:
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        cinvoke sqliteExec, [hMainDatabase], sqlCleanLog, 0, 0, 0

.finish:
        popad
        return
endp




uglobal
  UniqueID   dd ?
  UniqueLock dd ?
endg



proc GetUniqueID
begin
        xor     eax, eax
        dec     eax

.loop:
        xchg    eax, [UniqueLock]
        test    eax, eax
        jz      .locked

        stdcall Sleep, 1
        jmp     .loop


.locked:
        mov     eax, [UniqueID]
        inc     [UniqueID]

        mov     [UniqueLock], 0
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

.start_time     dd ?

.threadID       dd ?
.thread_start   dd ?

begin
        xor     eax, eax
        mov     [.requestParams], eax
        mov     [.requestPost], eax
        xor     esi, esi

        stdcall GetUniqueID
        mov     [.threadID], eax

        stdcall GetFineTimestamp
        mov     [.thread_start], eax

        stdcall LogEvent, "ThreadStart", logNumber, [.threadID], 0


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
        or      [.requestFlags], ffcgiExpectParams

        movzx   ecx, [esi+FCGI_BeginRequest.body.flags]
        or      [.requestFlags], ecx

        stdcall LogEvent, "RequestStart", logNumber, [.threadID], 0

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
        jnz     .pack_loop

        stdcall ValueByName, [.requestParams], "REQUEST_METHOD"
        jc      .serve_request                                          ; not found method

        stdcall StrCompNoCase, eax, txt "POST"
        jnc     .serve_request                          ; it is not the POST request, so no need to wait for more data.

; some post data is expected.

        or      [.requestFlags], ffcgiExpectStdIn
        jmp     .pack_loop



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

        test    ecx, ecx
        jz      .stdin_received           ; no more packages to wait for FCGI_STDIN

; add the package to the post data byte stream.

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

        cmp     [ebx+TByteStream.size], GENERAL_LIMIT_MAX_POST_LENGTH
        ja      .stdin_received

        pop     esi
        jmp     .pack_loop


.stdin_received:

        and     [.requestFlags], not ffcgiExpectStdIn

        test    [.requestFlags], ffcgiExpectParams
        jz      .serve_request

        jmp     .pack_loop


; Processing of the request. Here all data is ready, so serve the request!

.serve_request:
        stdcall ValueByName, [.requestParams], "REQUEST_URI"
        stdcall LogEvent, "RequestServeStart", logText, eax, 0

        stdcall ServeOneRequest, [.hSocket], [.requestID], [.requestParams], [.requestPost], [.start_time]

        stdcall LogEvent, "RequestServeEnd", logNULL, 0, 0


.request_complete:

        stdcall FCGI_send_end_request, [.hSocket], [.requestID], FCGI_REQUEST_COMPLETE
        jc      .finish

        stdcall GetFineTimestamp
        sub     eax, [.start_time]

        stdcall LogEvent, "RequestEnd", logNumber, [.threadID], eax

        test    [.requestFlags], FCGI_KEEP_CONN
        jnz     .main_loop


.finish:
        stdcall FreeMem, esi
        call    .FreeAllocations

        stdcall SocketClose, [.hSocket]

        stdcall GetFineTimestamp
        sub     eax, [.thread_start]

        stdcall LogEvent, "ThreadEnd", logNumber, [.threadID], eax

        stdcall Terminate, 0

;...............................................................


.FreeAllocations:
        xor     eax, eax

        cmp     [.requestParams], eax
        je      .params_ok

        stdcall FreeNameValueArray, [.requestParams]
        mov     [.requestParams], eax

.params_ok:
        cmp     [.requestPost], eax
        je      .post_ok

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






