struct TMemoryCache
  .Mutex TMutex
  .array dd ?
ends


uglobal

  AvatarCache TMemoryCache

endg


sqlGetAvatar text "select avatar from users where id = ?"


proc GetUserAvatar, .uid
begin
;        push    ebx

;        stdcall GetFineTimestamp
;        mov     ebx, eax

        stdcall GetCachedString, AvatarCache, sqlGetAvatar, [.uid]
;        push    eax

;        stdcall GetFineTimestamp
;        sub     eax, ebx

;        OutputValue "Get avatar: ", eax, 10, -1
;
;        pop     eax
;        pop     ebx
        return
endp




proc CreateMemoryCache, .pVarCache
begin
        pushad

        mov     edi, [.pVarCache]
        stdcall MutexCreate, 0, edi

        stdcall CreateArray, 8
        mov     [edi+TMemoryCache.array], eax

        stdcall MutexRelease, edi

        popad
        return
endp




proc GetCachedString, .pVarCache, .pGetQuery, .id
.stmt dd ?
begin
        pushad
        mov     edi, [.pVarCache]

        stdcall WaitForMutex, edi, -1

        mov     edi, [.pVarCache]
        mov     edx, [edi+TMemoryCache.array]

        stdcall SearchSortedArray, edx, [.id]
        jc      .fetch_and_add


        mov     eax, [edx+TArray.array+8*eax+4]

.finish_ok:
        mov     [esp+4*regEAX], eax
        clc

.finish:
        stdcall MutexRelease, edi
        popad
        return


.fetch_and_add:

        mov     ebx, eax        ; index, where to insert

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], [.pGetQuery], -1, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.id]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_fetch

        cinvoke sqliteColumnText, [.stmt], 0
        test    eax, eax
        jz      .fetch_ok

        stdcall StrDupMem, eax

.fetch_ok:
        mov     esi, eax

        cinvoke sqliteFinalize, [.stmt]

        mov     edx, [edi+TMemoryCache.array]
        stdcall InsertArrayItems, edx, ebx, 1
        mov     [edi+TMemoryCache.array], edx
        jc      .insert_ok

        pushd   [.id]
        popd    [eax]
        mov     [eax+4], esi

.insert_ok:
        mov     eax, esi
        jmp     .finish_ok


.error_fetch:
        cinvoke sqliteFinalize, [.stmt]
        stc
        jmp     .finish
endp



; binary search [.value] in the array.
; returns:
;   eax, the index where the element has been found or the index where the element has to be inserted, if not found
;   CF = 0 - element has been found.
;   CF = 1 - element not found.

proc SearchSortedArray, .pArray, .id
begin
        pushad

        mov     esi, [.pArray]

        xor     eax, eax
        xor     ecx, ecx                ; left
        mov     edx, [esi+TArray.count] ; right

        dec     edx
        js      .not_found

        mov     ebx, [.id]

.loop:
        cmp     edx, ecx
        jl      .not_found

        lea     eax, [ecx+edx]
        sar     eax, 1

        cmp     ebx, [esi+TArray.array+ 8*eax]
        je      .found

        ja      .goto_right

; goto left
        lea     edx, [eax-1]
        jmp     .loop


.goto_right:
        inc     eax
        mov     ecx, eax
        jmp     .loop

.found:
        clc

.finish:
        mov     [esp+4*regEAX], eax
        popad
        return

.not_found:
        stc
        jmp     .finish
endp
