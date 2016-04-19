

proc SanitizeImagePng, .pPNGImage, .Size, .width, .height

  .start:

  .Width         dd ?    ;
  .Height        dd ?
  .BitDepth      dd ?
  .ColorType     dd ?

  .fPalette      dd ?
  .PaletteCnt    dd ?

  .pData         dd ?    ; compressed data.
  .DataSize      dd ?
  .DataCapacity  dd ?

  .BitsPerPixel  dd ?

  .end:

  .res           dd ?
  .pEnd          dd ?

begin

        pushad

        mov     ecx, (.end - .start)/4
        lea     edi, [.start]
        xor     eax, eax
        rep stosd

        stdcall BytesCreate, 1024
        mov     [.res], eax

        mov     esi, [.pPNGImage]
        mov     edx, [.Size]

        cmp     edx, 8 + 12 + 13 + 12           ; header + IHDR + IEND the minimal size.
        jb      .error_unexpected_end

        add     edx, esi                ; the end pointer of the image.
        mov     [.pEnd], edx

; first, check the header.

; ...copy to the output

        push    esi

        stdcall BytesGetRoom, [.res], 16
        mov     [.res], ebx

        mov     ecx, 4
        rep movsd

        pop     esi

        mov     ecx, 4                   ; the size of the PNG header in dwords
        mov     edi, .hdrPNGImage
        repe cmpsd
        jne     .error_structure


; we are now in the IHDR chunk - it is always the first after the signature!

; copy IHDR to the output

        push    esi

        stdcall BytesGetRoom, [.res], sizeof.TchunkIHDR + 4     ; the header with the checksum.
        mov     ecx, sizeof.TchunkIHDR + 4
        rep movsb
        pop     esi

; check the IHDR checksum and parameters.

        lea     eax, [esi-4]
        stdcall DataCRC32, eax, sizeof.TchunkIHDR + 4
        bswap   eax
        cmp     eax, [esi+sizeof.TchunkIHDR]
        jne     .error_checksum

        cmp     [esi+TchunkIHDR.Filter], 0
        jne     .error_structure        ; unsupported filter type!

        cmp     [esi+TchunkIHDR.Compression], 0
        jne     .error_structure        ; unsupported compression method!

;        DebugMsg "Header seems to be OK."

        mov     eax, [esi+TchunkIHDR.Width]
        mov     ecx, [esi+TchunkIHDR.Height]
        bswap   eax
        bswap   ecx

;        OutputValue "Width: ", eax, 10, -1
;        OutputValue "Height: ", ecx, 10, -1

        cmp     eax, [.width]
        jne     .error_requirements

        cmp     ecx, [.height]
        jne     .error_requirements

        movzx   ecx, [esi+TchunkIHDR.BitDepth]
        movzx   eax, [esi+TchunkIHDR.ColorType]
        mov     [.BitDepth], ecx
        mov     [.ColorType], eax

        mov     edx, ecx

        test    [.ColorType], pngCTPalette
        jnz     .size_raw_ok

        test    [.ColorType], pngCTColor
        jz      .raw_color_ok

        lea     edx, [3*edx]

.raw_color_ok:
        test    [.ColorType], pngCTAlpha
        jz      .size_raw_ok

        add     edx, ecx        ; one more sample for the alpha channel.

.size_raw_ok:
        mov     [.BitsPerPixel], edx

; Image size:
        mov     eax, [esi+TchunkIHDR.Width]
        mov     ecx, [esi+TchunkIHDR.Height]
        bswap   eax
        bswap   ecx
        mov     [.Width], eax
        mov     [.Height], ecx

; end of IHDR chunk:
        add     esi, sizeof.TchunkIHDR + 4


.chunk_loop:
        cmp     esi, [.pEnd]
        jae     .error_unexpected_end

;        OutputMemoryByte esi, 16

        lodsd
        bswap   eax
        mov     ecx, eax                ; chunk length in bytes
        lea     edx, [eax+4]
        lea     eax, [esi+edx]

        cmp     eax, [.pEnd]
        jae     .error_unexpected_end

        stdcall DataCRC32, esi, edx
        bswap   eax
        cmp     eax, [esi+edx]
        jne     .error_checksum

        lodsd

        cmp     eax, 'PLTE'
        je      .PLTE

        cmp     eax, 'IDAT'
        je      .IDAT

        cmp     eax, 'IEND'
        je      .IEND

        cmp     eax, 'tRNS'
        je      .tRNS

; ignore chunk if unknown
        add     esi, ecx

.next_chunk:
        add     esi, 4  ; check sum
        jmp     .chunk_loop


.copy_chunk:
        push    ebx ecx edi

        sub     esi, 8
        mov     ecx, [esi]      ; chunk length
        bswap   ecx
        add     ecx, 12         ;

        stdcall BytesGetRoom, [.res], ecx
        mov     [.res], ebx
        rep movsb

        pop     edi ecx ebx
        retn


.tRNS:
        cmp     [.fPalette], 0
        je      .error_structure

        cmp     ecx, [.PaletteCnt]
        ja      .error_structure

        call    .copy_chunk
        jmp     .chunk_loop


.PLTE:
        cmp     [.fPalette], 0
        jne     .error_structure        ; the palette can be only one!

        cmp     [.pData], 0
        jne     .error_structure        ; the palette must resides before the first IDAT!

        inc     [.fPalette]

        mov     eax, ecx
        cdq
        mov     ebx, 3
        div     ebx
        test    edx, edx
        jnz     .error_structure        ; the palette must contains multiple of 3 bytes.

        mov     [.PaletteCnt], eax

        call    .copy_chunk
        jmp     .chunk_loop


.IDAT:
        mov     edi, [.pData]
        test    edi, edi
        jnz     .buffer_allocated

        lea     eax, [ecx*2]
        mov     [.DataCapacity], eax

        stdcall GetMem, eax
        jc      .error_memory_allocation

        mov     edi, eax
        mov     [.pData], eax

.buffer_allocated:

        mov     eax, ecx
        add     eax, [.DataSize]
        cmp     eax, [.DataCapacity]
        jbe     .capacity_enough

        shl     eax, 1
        mov     [.DataCapacity], eax

        stdcall ResizeMem, edi, eax
        jc      .error_memory_allocation

        mov     [.pData], eax
        mov     edi, eax

.capacity_enough:
        add     edi, [.DataSize]
        add     [.DataSize], ecx

        push    esi
        rep movsb
        pop     esi

        call    .copy_chunk
        jmp     .chunk_loop


.IEND:
; so, all data must be collected - process it.

        cmp     [.pData], 0
        je      .error_no_image

        call    .copy_chunk

; decompressed data buffer:

        mov     edx, [.Width]
        imul    edx, [.BitsPerPixel]
        add     edx, 7
        shr     edx, 3  ; round up and compute the byte count.
        inc     edx                      ; one more byte for the filter byte.
        imul    edx, [.Height]

        stdcall GetMem, edx
        mov     edi, eax

        mov     esi, [.pData]
        mov     ecx, [.DataSize]

        add     esi, 2          ; first 2 bytes are ZLIB data format header. Ignore them.
        sub     ecx, 2+4        ; the last 4 bytes

        stdcall Inflate, edi, edx, esi, ecx
        jc      .error_decompression

        stdcall FreeMem, [.pData]
        stdcall FreeMem, edi

        mov     eax, [.res]
        mov     [esp+4*regEAX], eax

        clc
        popad
        return


.error_requirements:
;        dbrk

.error_invalid_filter:
;        dbrk

.error_decompression:
;        dbrk

.error_no_image:
;        dbrk

.error_memory_allocation:
;        dbrk

.error_checksum:
;        dbrk

.error_structure:
;        dbrk

.error_unexpected_end:
;        dbrk

        stdcall FreeMem, [.pData]
        stdcall FreeMem, [.res]

        stc
        popad
        return


  .hdrPNGImage  dd  $474e5089, $0a1a0a0d, $0d000000, 'IHDR'
endp