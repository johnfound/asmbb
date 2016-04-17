


proc PostDebug, .pSpecial
begin
        stdcall StrNew
        stdcall StrCatTemplate, eax, "form_post_debug", 0, [.pSpecial]
        clc
        return
endp