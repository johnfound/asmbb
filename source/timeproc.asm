
; contains some Date/Time procedures needed for HTTP communications...


iglobal

  if used HTTPmonths
    HTTPmonths dd 'Jan ', 'Feb ', 'Mar ', 'Apr ', 'May ', 'Jun ', 'Jul ', 'Aug ', 'Sep ', 'Oct ', 'Nov ', 'Dec '
  end if


  if used HTTPdays
    HTTPdays   dd  "Mon,", "Tue,", "Wed,", "Thu,", "Fri,", "Sat,", "Sun,"
  end if

endg



proc FormatHTTPTime, .timeLo, .timeHi
.date_time TDateTime
begin
        pushad

        lea     eax, [.timeLo]
        lea     ecx, [.date_time]

        stdcall TimeToDateTime, eax, ecx

        stdcall StrNew
        mov     ebx, eax

; week day

        mov     eax, [.date_time.day]

        stdcall StrCharCat, ebx, [HTTPdays+4*eax]
        stdcall StrCharCat, ebx, ' '

; date
        stdcall NumToStr, [.date_time.date], ntsUnsigned or ntsFixedWidth or ntsDec + 2
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCharCat, ebx, ' '

        mov     eax, [.date_time.month]
        stdcall StrCharCat, ebx, [HTTPmonths+4*eax-4]

        stdcall NumToStr, [.date_time.year], ntsSigned or ntsFixedWidth or ntsDec + 4
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCharCat, ebx, ' '

; time
        stdcall NumToStr, [.date_time.hour], ntsUnsigned or ntsFixedWidth or ntsDec + 2
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCharCat, ebx, ':'
        stdcall NumToStr, [.date_time.minute], ntsUnsigned or ntsFixedWidth or ntsDec + 2
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax
        stdcall StrCharCat, ebx, ':'
        stdcall NumToStr, [.date_time.second], ntsUnsigned or ntsFixedWidth or ntsDec + 2
        stdcall StrCat, ebx, eax
        stdcall StrDel, eax

        stdcall StrCat, ebx, txt " GMT"


        mov     [esp+4*regEAX], ebx
        popad
        return
endp






proc GetEmailTimestamp
begin
        pushad
        stdcall GetTime
        stdcall FormatHTTPTime, eax, edx
        mov     [esp+4*regEAX], eax
        popad
        return
endp







proc DecodeHTTPDate, .hDate, .pDateTime
.date dd ?
begin
        pushad

        mov     edi, [.pDateTime]

        stdcall StrDup, [.hDate]
        mov     [.date], eax

        stdcall StrConvertWhiteSpace, eax, " "
        stdcall StrCleanDupSpaces, eax
        stdcall StrClipSpacesR, eax
        stdcall StrClipSpacesL, eax

        stdcall StrPtr, eax
        mov     esi, eax

        cmp     [esi+string.len], 29
        jne     .error

; day of week.

        mov     eax, [esi]
        mov     edx, 6

.day_loop:
        cmp     eax, [HTTPdays+4*edx]
        je      .found_day

        dec     edx
        js      .error
        jmp     .day_loop

.found_day:

        mov     [edi+TDateTime.day], edx
        add     esi, 5

; date:
        stdcall StrToNum, esi
        jc      .error

        cmp     byte [esi+edx], ' '
        jne     .error

        cmp     eax, 31
        ja      .error
        cmp     eax, 1
        jb      .error

        mov     [edi+TDateTime.date], eax

        add     esi, 3

; month:

        mov     edx, 11
        mov     eax, [esi]

.month_loop:
        cmp     eax, [HTTPmonths+4*edx]
        je      .found_month

        dec     edx
        js      .error
        jmp     .month_loop

.found_month:

        inc     edx
        mov     [edi+TDateTime.month], edx
        add     esi, 4


; year:
        stdcall StrToNum, esi
        jc      .error

        cmp     byte [esi+edx], ' '
        jne     .error

        mov     [edi+TDateTime.year], eax
        add     esi, 5

; hour

        stdcall StrToNum, esi
        jc      .error

        cmp     eax, 23
        ja      .error

        cmp     byte [esi+edx], ':'
        jne     .error

        mov     [edi+TDateTime.hour], eax
        add     esi, 3

; minute

        stdcall StrToNum, esi
        jc      .error

        cmp     eax, 59
        ja      .error

        cmp     byte [esi+edx], ':'
        jne     .error

        mov     [edi+TDateTime.minute], eax
        add     esi, 3

; second

        stdcall StrToNum, esi
        jc      .error

        cmp     eax, 60
        ja      .error

        cmp     byte [esi+edx], ' '
        jne     .error

        mov     [edi+TDateTime.second], eax
        add     esi, 2

        cmp     dword [esi], " GMT"
        jne     .error

        clc

.finish:
        stdcall StrDel, [.date]
        popad
        return

.error:
        stc
        jmp     .finish
endp

