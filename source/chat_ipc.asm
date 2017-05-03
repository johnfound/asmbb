SHARED_BLOCK_SIZE = 4096

uglobal
  fChatTerminate dd ?
  pChatFutex     dd ?
endg



proc InitChatIPC
begin
        pushad

        and     [fChatTerminate], 0     ; it is 0 anyway, but...

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

        mov     [pChatFutex], eax
        stdcall FileClose, edi

        OutputValue "Shared memory allocated at addr: ", [pChatFutex], 16, 8

        clc
        popad
        return

.error:
        stc
        popad
        return
endp




proc WaitForChatMessages, .value
.timeout lnx_timespec
begin
        pushad

        mov     [.timeout.tv_sec], 3
        mov     [.timeout.tv_nsec], 0

        mov     eax, sys_futex
        mov     ebx, [pChatFutex]
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


proc SignalNewMessage
begin
        pushad

        mov     ebx, [pChatFutex]
        lock inc dword [ebx]

        mov     eax, sys_futex
        mov     ecx, FUTEX_WAKE
        mov     edx, $7fffffff
        int     $80

        popad
        return
endp