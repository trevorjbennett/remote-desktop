Procedure MouseEvent(Event.l) 
  
  Mem.l=GlobalAlloc_(0,8) 
  GetCursorPos_(Mem) 
  mouse_event_(Event|#MOUSEEVENTF_ABSOLUTE,PeekL(Mem)*($FFFF/GetSystemMetrics_(0)),PeekL(Mem+4)*($FFFF/GetSystemMetrics_(1)),0,GetMessageExtraInfo_()) 
  GlobalFree_(Mem) 
  
EndProcedure 

c$=Trim(ProgramParameter(0))

If c$ = "/ld"
  MouseEvent(#MOUSEEVENTF_LEFTDOWN) 
  End
EndIf

If c$ = "/rd"
  MouseEvent(#MOUSEEVENTF_RIGHTDOWN) 
  End
EndIf

If c$ = "/lu"
  MouseEvent(#MOUSEEVENTF_LEFTUP) 
  End
EndIf

If c$ = "/ru"
  MouseEvent(#MOUSEEVENTF_RIGHTUP) 
  End
EndIf

If c$ = "/ku"
  
  s$=StringField(PeekS(GetCommandLine_()),2,":")
  s$=RemoveString(s$,Chr(34))
  s$=Trim(RemoveString(s$,"}"))
  vk=Val(s$)

  keybd_event_(vk,1,#KEYEVENTF_KEYUP,0) 
  
  End
  
EndIf

If c$ = "/kd"
  
  s$=StringField(PeekS(GetCommandLine_()),2,":")
  s$=RemoveString(s$,Chr(34))
  s$=Trim(RemoveString(s$,"}"))
  vk=Val(s$)
  
  keybd_event_(vk,1,0,0)
  
    
  End
  
EndIf

ExamineDesktops()

  x$ = Trim(StringField(StringField(c$,2,","),2,":"))
  y$ = Trim(RemoveString(StringField(StringField(c$,3,","),2,":"),"}"))

  x.f = Val(x$)*(DesktopWidth(0)/10000)
  y.f = Val(y$)*(DesktopHeight(0)/10000)

  SetCursorPos_(x,y)
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; ExecutableFormat = Console
; Folding = +
; Executable = event-x86.exe
; CPU = 1
; DisableDebugger