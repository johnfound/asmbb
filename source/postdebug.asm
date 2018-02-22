
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