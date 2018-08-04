SHARED_BLOCK_SIZE = 4096
CHAT_WAKE_TIMEOUT = 3


uglobal
  fEventsTerminate   dd ?
  pEventsFutex       dd ?
endg



proc InitEventsIPC
begin
        pushad

        and     [fEventsTerminate], 0     ; it is 0 anyway, but...

        stdcall FileOpenAccess, "./asmbb_ipc.bin", faReadWrite or faOpenAlways
        jc      .error

        mov     edi, eax
;        mov     [hSharedFile], edi

; ensure the file size if bigger than the needed memory.

        stdcall FileTruncateTo, edi, SHARED_BLOCK_SIZE
        jc      .error

.size_ok:

        push    ebp

        mov     eax, sys_mmap2
        xor     ebx, ebx
        mov     ecx, SHARED_BLOCK_SIZE
        mov     edx, PROT_READ or PROT_WRITE
        mov     esi, MAP_SHARED
        xor     ebp, ebp
        int     $80

        pop     ebp

        cmp     eax, -EACCES
        je      .error
        cmp     eax, -EBADF
        je      .error

        mov     [pEventsFutex], eax
        stdcall FileClose, edi

        OutputValue "Shared memory allocated at addr: ", [pEventsFutex], 16, 8

        clc
        popad
        return

.error:
        stc
        popad
        return
endp




proc WaitForEvents, .value
.timeout lnx_timespec
begin
        pushad

        mov     [.timeout.tv_sec], CHAT_WAKE_TIMEOUT
        mov     [.timeout.tv_nsec], 0

        mov     eax, sys_futex
        mov     ebx, [pEventsFutex]
        mov     ecx, FUTEX_WAIT
        mov     edx, [.value]
        lea     esi, [.timeout]

        cmp     edx, [ebx]      ; don't make system call if obvious.
        jne     .no_wait

        int     $80
        test    eax, eax
        jz      .no_wait

        cmp     eax, EINTR
        je      .forced_exit

.no_wait:
        clc
        popad
        return

.forced_exit:
        stc
        popad
        return
endp


proc SignalNewEvent
begin
        pushad

        mov     ebx, [pEventsFutex]
        lock inc dword [ebx]

        mov     eax, sys_futex
        mov     ecx, FUTEX_WAKE
        mov     edx, $7fffffff
        int     $80

        popad
        return
endp