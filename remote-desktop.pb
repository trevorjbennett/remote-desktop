Macro IncFiles()
  
CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
  
DataSection
  nodejsa:
  IncludeBinary "bin\node-v10.15.3-win-x64.exe"
  nodejsb:
EndDataSection

DataSection
  evta:
  IncludeBinary "bin\event-x64.exe"
  evtb:
EndDataSection

CompilerElse
  
DataSection
  nodejsa:
  IncludeBinary "bin\node-v10.15.3-win-x86.exe"
  nodejsb:
EndDataSection

DataSection
  evta:
  IncludeBinary "bin\event-x86.exe"
  evtb:
EndDataSection

CompilerEndIf


DataSection
  indexa:
  IncludeBinary "index.html"
  indexb:
EndDataSection

DataSection
  serverjsa:
  IncludeBinary "server.js"
  serverjsb:
EndDataSection

DataSection
  jquerya:
  IncludeBinary "jquery-3.4.1.min.js"
  jqueryb:
EndDataSection
  
EndMacro
Macro Vars()
  
Global title$
Global temp$
Global appdata$
Global nodejs$
Global quality
Global port
Global imgrefreshinterval
Global screenshotinterval$
Global settingsfile$
Global launchserver$
Global launchwithwindows$
Global settings$
Global hideintray$
Global hideintrayb$
Global portnumber$
Global setssi$
Global setii$
Global imgrefreshinterval$
Global ms$
Global runserver$
Global stopserver$
Global visitwebsite$
Global sethit$
Global setsrv$
Global setport$
Global setsww$
Global alreadyrunning$
Global prog

Global hMapFile = CreateFileMapping_(#INVALID_HANDLE_VALUE,#Null,#PAGE_READWRITE,0,256,"e43493074cec29be07ed0c8e65db3506")
Global pBuf = MapViewOfFile_(hMapFile,#FILE_MAP_ALL_ACCESS,0,0,256)

  title$ = "Remote Desktop v1.0"
  quality=7
  launchserver$="Launch server automatically"
  launchwithwindows$="Start with Windows"
  settings$="Settings"
  hideintray$="Hide in tray automatically"
  portnumber$="Port number"
  screenshotinterval$="Screen capture interval"
  imgrefreshinterval$="Image refresh interval"
  hideintrayb$="Hide in tray"
  runserver$="Run Server"
  stopserver$="Stop Server"
  visitwebsite$="Visit Website"
  ms$="(ms)"
  
  alreadyrunning$ = "An instance of this application is already running"
  
  setsrv$="launchserver"
  sethit$="hideintray"
  setsww$="startwithwindows"
  setport$="port"
  setsi$="screenshotinterval"
  setii$="imagerefreshinterval"
  
EndMacro
Macro SaveSettings()
  
  WriteSettings(sethit$,Str(GetGadgetState(hit)))
  WriteSettings(setsrv$,Str(GetGadgetState(ls)))
  WriteSettings(setsww$,Str(GetGadgetState(lww)))
  WriteSettings(setport$,Str(GetGadgetState(pn)))
  WriteSettings(setsi$,GetGadgetText(si))
  WriteSettings(setii$,GetGadgetText(ii))
    
EndMacro

UseJPEGImageEncoder():IncFiles():Vars()

Procedure CloseNodeJS()

If IsProgram(prog)
  
If ProgramRunning(prog)
  
  KillProgram(prog)
  
EndIf

  CloseProgram(prog)

EndIf
  
EndProcedure
Procedure Quit()
  
  CloseNodeJS()
  DeleteDirectory(temp$,"*.*")
  
  End
  
EndProcedure
Procedure FileExists(filename.s)
  
  f=ReadFile(#PB_Any, filename,#PB_File_SharedRead)
  
If f
  
  CloseFile(f)
  r=1
  
EndIf

  ProcedureReturn r

EndProcedure
Procedure.s ReadSettings(key$,def$)

  OpenPreferences(settingsfile$)
  s$=ReadPreferenceString(key$,def$)
  ClosePreferences()
  
  ProcedureReturn s$
  
EndProcedure
Procedure WriteSettings(key$,value$)

If FileExists(settingsfile$)
  OpenPreferences(settingsfile$)
Else
  CreatePreferences(settingsfile$)
EndIf

  WritePreferenceString(key$,value$)
  ClosePreferences()

  ProcedureReturn
  
EndProcedure
Procedure FilePutContents(filename.s, *mem, size)
  
  f=CreateFile(#PB_Any,filename)

If f
  
  res=WriteData(f,*mem,size)
  CloseFile(f)
  
If res=size
  r=1
Else
  r=0
EndIf
  
EndIf

  ProcedureReturn r

EndProcedure
Procedure.s AddBackslash(path.s)
  
If Right(path,1)<> "\"
  path=path+"\"
EndIf

ProcedureReturn path

EndProcedure
Procedure.s CreateTempDir()
  
  temp$=GetTemporaryDirectory()
  
  *mem = AllocateMemory(1024)
  
  GetTempFileName_(temp$,"", #Null, *mem)
  
  temp$ = PeekS(*mem)
  
  FreeMemory(*mem)
  
  DeleteFile(temp$)
  
  temp$ = AddBackslash(temp$)
  
  CreateDirectory(temp$)
  
  ProcedureReturn temp$
  
EndProcedure
Procedure Autostart(a)
  
  autostart$=Space(2000)
  SHGetSpecialFolderPath_(#Null,autostart$,#CSIDL_STARTUP,0)
  autostart$=Trim(autostart$)
  autostart$=AddBackslash(autostart$)
  f$=autostart$+"remote-desktop.bat"
  
If a=1
  
  CreateFile(0,f$)
  WriteStringFormat(0,#PB_Ascii)
  WriteString(0, "start "+Chr(34)+Chr(34)+" "+Chr(34)+ProgramFilename()+Chr(34))
  CloseFile(0)
  
Else
  
  DeleteFile(f$)
  
EndIf
  
  ProcedureReturn
  
EndProcedure
Procedure Icon2Image(IconID, HG_Col = - 1)
  
Protected IconBr, IconHo, IconInfo.ICONINFO
Protected ImgNr, ImgID, ImgHDC
  
If GetIconInfo_(IconID, @IconInfo)
  
  IconBr = IconInfo\xHotspot * 2
  IconHo = IconInfo\yHotspot * 2
  
If IconBr <= 0 Or IconHo <=0
  
  ProcedureReturn 0
  
EndIf 

  ImgNr = CreateImage(#PB_Any, IconBr, IconHo)
  ImgHDC = StartDrawing(ImageOutput(ImgNr))
  
If HG_Col<0 : HG_Col = GetSysColor_(#COLOR_3DFACE): EndIf

  Box(0, 0, IconBr, IconHo, HG_Col)
  #DI_NORMAL = 3
  DrawIconEx_(ImgHDC, 0, 0, IconID, IconBr, IconHo, 0, 0, #DI_NORMAL)
  StopDrawing()
 
EndIf

  ProcedureReturn ImgNr
  
EndProcedure  
Procedure GetCurrentCursor(*pt.Point)
  
  hWindow.l
  dwThreadID.l
  dwCurrentThreadID.l
  Result = 0
  Static wfp
  
If wfp=0
  
  l=OpenLibrary(#PB_Any,"user32.dll")
  wfp = GetFunction(l, "WindowFromPoint")
  CloseLibrary(l) 
  
EndIf
  
If GetCursorPos_(*pt)
 
  hWindow = CallFunctionFast(wfp,*pt\x,*pt\y)
    
If IsWindow_(hWindow)
  
  dwThreadID = GetWindowThreadProcessId_(hWindow, @nil)
  dwCurrentThreadID = GetCurrentThreadId_()
     
If (dwCurrentThreadID <> dwThreadID)
  
If AttachThreadInput_(dwCurrentThreadID, dwThreadID, 1)
  
  Result = GetCursor_()
  AttachThreadInput_(dwCurrentThreadID, dwThreadID, 0)
  
EndIf

Else
  
  Result = GetCursor_()
  
EndIf

EndIf

EndIf

ProcedureReturn Result

EndProcedure
Procedure MakeScreenshot()

  ExamineDesktops()
  
  w=DesktopWidth(0)
  h=DesktopHeight(0)
  
  i = CreateImage(#PB_Any,w,h)
  
If i
  
  hDC = StartDrawing(ImageOutput(i))
   
If hDC
  
  DeskDC = GetDC_(GetDesktopWindow_())
  
If DeskDC
  
  BitBlt_(hDC,0,0,w,h,DeskDC,0,0,#SRCCOPY)
  
EndIf

  hCursor = GetCurrentCursor(@pt.Point)
    
  StopDrawing()
  ic=Icon2Image(hCursor)
  hDC = StartDrawing(ImageOutput(i))
  iw=0:ih=0
  
If ic>0 
  
If IsImage(ic)  
  
  iw=ImageWidth(ic)/2:ih=ImageHeight(ic)/2
  FreeImage(ic)
  
EndIf

EndIf
  
  DrawIcon_(hDC, (pt\x-capX)-iw, (pt\y-capY)-ih ,hCursor)
    
  ReleaseDC_(GetDesktopWindow_(),DeskDC)

EndIf

  res = SaveImage(i,temp$+"img.jpg",#PB_ImagePlugin_JPEG,quality)
  
  CopyFile(temp$+"img.jpg",temp$+"screen.jpg")
  
  DeleteFile(temp$+"img.jpg")
  
  Delay(10)
  
  StopDrawing()
  FreeImage(i)

EndIf

  ProcedureReturn res

EndProcedure
Procedure Screenshot(var)

Repeat
    
  MakeScreenshot()
  Delay(var)
  
ForEver
  
ProcedureReturn

EndProcedure
Procedure CreateJSFiles(temp$,pn,ii)

  s$ = PeekS(?indexa, ?indexb-?indexa,#PB_UTF8)
  
  s$ = ReplaceString(s$,"500", Str(GetGadgetState(ii)))
  
  CreateFile(0, temp$+"index.html")
  WriteStringFormat(0,#PB_Ascii)
  WriteString(0,s$)
  CloseFile(0)
  
  s$ = PeekS(?serverjsa, ?serverjsb-?serverjsa,#PB_UTF8)
  
  s$ = ReplaceString(s$,"8000",Str(GetGadgetState(pn)))
    
  CreateFile(0, temp$+"server.js")
  WriteStringFormat(0,#PB_Ascii)
  WriteString(0,s$)
  CloseFile(0)
  
EndProcedure
Procedure Window(nodejs$,p$)
  
  hIcon = ExtractIcon_(#Null, ProgramFilename(), 0)
  
  sinterval=Val(ReadSettings(setsi$,"1000"))
  iinterval=Val(ReadSettings(setii$,"1000"))
  hidewin = Val(ReadSettings(sethit$,"0"))
  launchserver = Val(ReadSettings(setsrv$,"0"))
  startwithwindows = Val(ReadSettings(setsww$,"0"))
  port = Val(ReadSettings(setport$,"8000"))
    
If startwithwindows = 1 
  
  Autostart(1)
  
Else
  
  Autostart(0)
  startwithwindows=0
  
EndIf
  
  height=180
  
  width=420
  
  x=20
  y=30
    
  
If OpenWindow(0, 0, 0, width, height, title$, #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered | #PB_Window_Invisible)
  
  FrameGadget(#PB_Any,5,2,width-10,height-50,settings$)
  
  ls = CheckBoxGadget(#PB_Any,x,y,150,20,launchserver$)
  
  SetGadgetState(ls,launchserver)
  
  hit = CheckBoxGadget(#PB_Any,x,y+30,150,20,hideintray$)
  
  SetGadgetState(hit,hidewin)
  
  lww = CheckBoxGadget(#PB_Any,x,y+60,150,20,launchwithwindows$)
  
  SetGadgetState(lww,startwithwindows)
  
  TextGadget(#PB_Any,x+180,y+2,80,20,portnumber$+":")
  
  pn = SpinGadget(#PB_Any,x+300,y,60,20,1,65535,#PB_String_Numeric)
  
  SetGadgetText(pn,Str(port)):SetGadgetState(pn,port)
  
  TextGadget(#PB_Any,x+180,y+32,150,20,screenshotinterval$+":")
  
  si = SpinGadget(#PB_Any,x+300,y+30,60,20,500,100000,#PB_String_Numeric)
  
  SetGadgetText(si,Str(sinterval)):SetGadgetState(si,sinterval)
  
  TextGadget(#PB_Any,x+365,y+32,20,20,ms$)
  
  TextGadget(#PB_Any,x+180,y+62,150,20,imgrefreshinterval$+":")
  
  ii = SpinGadget(#PB_Any,x+300,y+60,60,20,500,100000,#PB_String_Numeric)
  
  SetGadgetText(ii,Str(iinterval)):SetGadgetState(ii,iinterval)
      
  TextGadget(#PB_Any,x+365,y+62,20,20,ms$)
  
  server = ButtonGadget(#PB_Any,70,height-40,132,30,runserver$)
  
  hide = ButtonGadget(#PB_Any,214,height-40,132,30,hideintrayb$)

  
  AddWindowTimer(0,0,1000)
  
If hidewin=1
      
    AddSysTrayIcon(1,WindowID(0),hIcon)
  
Else
    
  hidewin=0
  HideWindow(0,0)
  
EndIf

If launchserver=1
  
  SaveSettings()
  CreateJSFiles(temp$,pn,ii)
  
  prog = RunProgram(nodejs$, p$ ,temp$,#PB_Program_Hide|#PB_Program_Open)
  tr = CreateThread(@Screenshot(),GetGadgetState(si))
  SetGadgetText(server, stopserver$)
  
  s = 1
  
EndIf
  
Repeat
  
  Event = WaitWindowEvent()
  
If Event = #PB_Event_Timer 
  
If s=1 And ProgramRunning(prog) = 0
  
  CloseNodeJS()

  SetGadgetText(server, runserver$)
  
  s=0
  
EndIf
  
EndIf
  
If Event = #PB_Event_CloseWindow
  
  SaveSettings()
  Autostart(GetGadgetState(lww))
  
  Break
  
EndIf

If Event = #PB_Event_SysTray
  
If EventType() = #PB_EventType_LeftClick
  
  HideWindow(0,0)
  RemoveSysTrayIcon(1)
  
EndIf

EndIf


If event = #PB_Event_Gadget
  
Select EventGadget()
    
Case pn
  
If GetGadgetState(pn)<>pns
  
  SetGadgetText(pn, Str(GetGadgetState(pn)))
  
Else
  
  SetGadgetState(pn,Val(GetGadgetText(pn)))
  
EndIf

  pns=GetGadgetState(pn)
  
Case si
  
If GetGadgetState(si)<>sis
  
  SetGadgetText(si, Str(GetGadgetState(si)))
  
Else
  
  SetGadgetState(si,Val(GetGadgetText(si)))
  
EndIf

  sis=GetGadgetState(si)
    
Case hide
  
  HideWindow(0,1)
  AddSysTrayIcon(1,WindowID(0),hIcon)
  
Case server
  
If s=1
  
If IsThread(tr)
  
  KillThread(tr)
  
EndIf

  CloseNodeJS()

  SetGadgetText(server, runserver$)
  
  s=0
  
Else
  
  SaveSettings()
  CreateJSFiles(temp$,pn,ii)
    
  prog = RunProgram(nodejs$, p$ ,temp$,#PB_Program_Hide|#PB_Program_Open)
  tr = CreateThread(@Screenshot(),GetGadgetState(si))
  SetGadgetText(server, stopserver$)
  
  s = 1
  
EndIf

   
EndSelect
    
EndIf
  
ForEver
  
EndIf

  ProcedureReturn

EndProcedure
Procedure Main()
  
If PeekL(pbuf+4)=1
  
  MessageRequester("",alreadyrunning$,#PB_MessageRequester_Info)
  End
  
EndIf

  PokeL(pBuf+4,1)

  appdata$ = AddBackslash(GetUserDirectory(#PB_Directory_ProgramData))
  
  appdata$+"rd\"
  
  nodejs$ = appdata$+"nodejs.exe"

  CreateDirectory(appdata$)

  settingsfile$=appdata$+"settings.ini"

  FilePutContents(appdata$+"nodejs.exe", ?nodejsa, ?nodejsb-?nodejsa)
  
  RunProgram(nodejs$,"-o -y","",#PB_Program_Hide|#PB_Program_Wait)
  
  DeleteFile(nodejs$)
  
CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
  nodejs$ = appdata$+"node-v10.15.3-win-x64\node.exe"
CompilerElse
  nodejs$ = appdata$+"node-v10.15.3-win-x86\node.exe"
CompilerEndIf
  
  temp$ = CreateTempDir()

  FilePutContents(temp$+"jquery-3.4.1.min.js", ?jquerya, ?jqueryb-?jquerya)

  FilePutContents(temp$+"event.exe", ?evta, ?evtb-?evta)

  Window(nodejs$,Chr(34)+temp$+"server.js"+Chr(34))
  
  Quit()
  
EndProcedure

Main()
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; Folding = AAA+
; EnableThread
; EnableXP
; UseIcon = icon.ico
; Executable = remote-desktop-x64.exe
; CPU = 1