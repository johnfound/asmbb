iglobal
  sqlCheckEmpty db 'select count(*) from sqlite_master',0
endg



;-------------------------------------------------------------------
; If the file in [.ptrFileName] exists, the function opens it.
; if the file does not exists, new database is created and the
; initialization script from [.ptrInitScript] is executed on it.
;
; Returns:
;    CF: 0 - database was open successfully
;      eax = 0 - Existing database was open successfuly.
;      eax = 1 - New database was created and init script was executed successfully.
;      eax = 2 - New database was created but init script exits with error.
;    CF: 1 - the database could not be open. (error)
;-------------------------------------------------------------------
proc OpenOrCreate, .ptrFileName, .ptrDatabase, .ptrInitScript
   .hSQL dd ?
.ptrNext dd ?
begin
        push    edi esi ebx

        mov     esi, [.ptrDatabase]
        cinvoke sqliteOpen, [.ptrFileName], esi
        test    eax, eax
        jz      .openok

.error:
        stc
        pop     esi
        return

.openok:
        xor     ebx, ebx
        lea     eax, [.hSQL]
        lea     ecx, [.ptrNext]
        cinvoke sqlitePrepare, [esi], sqlCheckEmpty, -1, eax, ecx
        cinvoke sqliteStep, [.hSQL]
        cinvoke sqliteColumnInt, [.hSQL], 0
        push    eax
        cinvoke sqliteFinalize, [.hSQL]
        pop     eax
        test    eax, eax
        jnz     .finish

        inc     ebx
        cinvoke sqliteExec, [esi], [.ptrInitScript], NULL, NULL, NULL
        test    eax, eax
        jz      .finish

        inc     ebx

.finish:
        mov     eax, ebx
        clc
        pop     ebx esi edi
        return
endp
