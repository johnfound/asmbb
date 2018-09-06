
if defined options.DebugWeb & options.DebugWeb

  proc PostDebug, .pSpecial
  begin
          stdcall RenderTemplate, 0, "form_post_debug", 0, [.pSpecial]
          clc
          return
  endp

else

  PostDebug = 0

end if



proc DumpPostArray, .pSpecial
begin
        pushad
        mov     esi, [.pSpecial]

        mov     edx, [esi+TSpecialParams.post_array]
        xor     ecx, ecx

.loop:
        cmp     ecx, [edx+TArray.count]
        jae     .finish

        stdcall FileWriteString, [STDERR], [edx+TArray.array + 8*ecx]
        stdcall FileWriteString, [STDERR], txt ' : '
        stdcall FileWriteString, [STDERR], [edx+TArray.array + 8*ecx + 4]
        stdcall FileWriteString, [STDERR], <txt 13, 10>

        inc     ecx
        jmp     .loop

.finish:
        popad
        return
endp