// Integration regression: run with opus <DOSrcVwr.dll> <fixtures-directory>.
// Fixtures: sample.pas/.cpp/.xml/.json/.py/.ps1, UTF-8 without BOM.
// Builds with the demo DOpusViewerPlugins unit on the compiler search path.
program DOSrcVwrUnloadTest;
{$APPTYPE CONSOLE}
uses System.SysUtils, System.Types, System.IOUtils, Winapi.Windows,
  Winapi.ActiveX, Winapi.ShlObj, Winapi.PropSys, System.Win.ComObj,
  Vcl.Forms, Winapi.Messages, DOpusViewerPlugins;
type
  PWindowHandle = ^HWND;
  TConfigure = function(Parent, Notify: HWND; Data: DWORD): HWND; cdecl;
  TCreateViewer = function(Parent: HWND; Bounds: PRect; Flags: DWORD): HWND; cdecl;
const
  Extensions: array[0..5] of string = ('pas','cpp','xml','json','py','ps1');
  LexerIDs: array[0..5] of Integer = (18,3,5,120,2,88);
var
  Lib: HMODULE; Host: TForm; Bounds: TRect; Viewer: HWND;
  InitData: DVPINITEXDATA; InitOpus: PFNDVPINITEX; UninitOpus: PFNDVPUNINIT;
  Configure: TConfigure;
  CreateViewer: TCreateViewer;
  USBSafe: PFNDVPUSBSAFE;
  USBData: OPUSUSBSAFEDATA;
  USBBuffer: array[0..31] of WideChar;
  I, Cycle: Integer; FileName: string;
function FindEditor(Child: HWND; Param: LPARAM): BOOL; stdcall;
var Name: array[0..255] of Char;
begin
  GetClassName(Child, Name, Length(Name));
  Result := Pos('scintilla', LowerCase(string(Name))) = 0;
  if not Result then PWindowHandle(Param)^ := Child;
end;
function FindSettingsWindow(Wnd: HWND; Param: LPARAM): BOOL; stdcall;
var Name: array[0..255] of Char; PID: DWORD;
begin
  GetWindowThreadProcessId(Wnd, @PID);
  GetClassName(Wnd, Name, Length(Name));
  if (PID = GetCurrentProcessId) and (string(Name) = 'TDSciVisualSettingsDialog') then
    PWindowHandle(Param)^ := Wnd;
  Result := True;
end;

procedure CheckSettingsEscape(Parent: HWND; AccelViewer: HWND = 0);
var
  DialogWnd, FocusWnd: HWND;
  GUI: TGUIThreadInfo;
  KeyMsg: TMsg;
  Deadline: UInt64;
begin
  DialogWnd := 0;
  EnumWindows(@FindSettingsWindow, LPARAM(@DialogWnd));
  if DialogWnd = 0 then raise Exception.Create('Settings dialog was not shown');
  FillChar(GUI, SizeOf(GUI), 0);
  GUI.cbSize := SizeOf(GUI);
  FocusWnd := DialogWnd;
  if GetGUIThreadInfo(GetWindowThreadProcessId(DialogWnd, nil), GUI) and
     IsChild(DialogWnd, GUI.hwndFocus) then
    FocusWnd := GUI.hwndFocus;
  if AccelViewer <> 0 then
  begin
    FillChar(KeyMsg, SizeOf(KeyMsg), 0);
    KeyMsg.hwnd := FocusWnd;
    KeyMsg.message := WM_KEYDOWN;
    KeyMsg.wParam := VK_ESCAPE;
    if SendMessage(AccelViewer, DVPLUGINMSG_TRANSLATEACCEL, 0, LPARAM(@KeyMsg)) = 0 then
      raise Exception.Create('Settings Escape escaped into Opus accelerators');
    Application.ProcessMessages;
    KeyMsg.message := WM_KEYUP;
    if SendMessage(AccelViewer, DVPLUGINMSG_TRANSLATEACCEL, 0, LPARAM(@KeyMsg)) = 0 then
      raise Exception.Create('Settings Escape key-up escaped into Opus');
    if not IsWindow(AccelViewer) then raise Exception.Create('Escape destroyed viewer');
  end
  else
  begin
    PostMessage(FocusWnd, WM_KEYDOWN, VK_ESCAPE, 1);
    PostMessage(FocusWnd, WM_KEYUP, VK_ESCAPE, $C0010001);
  end;
  Deadline := GetTickCount64 + 2000;
  while IsWindow(DialogWnd) and (GetTickCount64 < Deadline) do
  begin
    Application.ProcessMessages;
    Sleep(1);
  end;
  if IsWindow(DialogWnd) then raise Exception.Create('ESC did not destroy settings dialog');
  if not IsWindowEnabled(Parent) then raise Exception.Create('ESC left the parent disabled');
  Writeln('PASS: settings ESC closes dialog and re-enables parent');
end;

procedure CheckViewerBounds(ViewerWnd, ParentWnd: HWND; const Expected: TRect);
var Actual: TRect;
begin
  GetWindowRect(ViewerWnd, Actual);
  MapWindowPoints(0, ParentWnd, Actual, 2);
  if not EqualRect(Actual, Expected) then
    raise Exception.CreateFmt('Viewer bounds (%d,%d,%d,%d), expected (%d,%d,%d,%d)',
      [Actual.Left, Actual.Top, Actual.Right, Actual.Bottom,
       Expected.Left, Expected.Top, Expected.Right, Expected.Bottom]);
end;

procedure CheckEditor(Parent: HWND; const AFileName: string; ExpectedLexer: Integer);
var Editor: HWND; Count: NativeInt; Text, Expected: TBytes;
begin
  Editor := 0;
  EnumChildWindows(Parent, @FindEditor, LPARAM(@Editor));
  if Editor = 0 then raise Exception.Create('Scintilla HWND missing');
  Count := SendMessage(Editor, 2183, 0, 0);
  Expected := TFile.ReadAllBytes(AFileName);
  if Count <> Length(Expected) then
    raise Exception.CreateFmt('Text byte count: %d instead of %d', [Count, Length(Expected)]);
  SetLength(Text, Count + 1);
  SendMessage(Editor, 2182, Count + 1, LPARAM(@Text[0]));
  if (Count > 0) and not CompareMem(@Text[0], @Expected[0], Count) then
    raise Exception.Create('Displayed UTF-8 text differs from input');
  if ExpectedLexer = 88 then
    if (SendMessage(Editor, 2482, 7, 0) <> $362A28) or
       (SendMessage(Editor, 2482, 11, 0) <> $362A28) or
       (SendMessage(Editor, 2482, 12, 0) <> $362A28) then
      raise Exception.Create('PowerShell token background is not Dracula default');
  if SendMessage(Editor, 4002, 0, 0) <> ExpectedLexer then
    raise Exception.CreateFmt('Unexpected lexer ID: %d', [SendMessage(Editor, 4002, 0, 0)]);
end;
begin
  OleCheck(CoInitialize(nil));
  try
    try
      Application.Initialize;
      for Cycle := 1 to 20 do
      begin
      Writeln('CYCLE: ', Cycle); Flush(Output);
      Lib := LoadLibrary(PChar(ParamStr(2)));
      if Lib = 0 then RaiseLastOSError;
      try
        Host := TForm.CreateNew(nil);
        try
          Host.SetBounds(0, 0, 800, 600);
          Bounds := Rect(17, 53, 817, 653);
          begin
            @InitOpus := GetProcAddress(Lib, 'DVP_InitEx');
            @UninitOpus := GetProcAddress(Lib, 'DVP_Uninit');
            @CreateViewer := GetProcAddress(Lib, 'DVP_CreateViewer');
            @Configure := GetProcAddress(Lib, 'DVP_Configure');
            @USBSafe := GetProcAddress(Lib, 'DVP_USBSafe');
            for I := Low(USBBuffer) to High(USBBuffer) do USBBuffer[I] := 'X';
            FillChar(USBData, SizeOf(USBData), 0);
            USBData.cbSize := SizeOf(USBData);
            USBData.pszOtherExports := @USBBuffer[0];
            USBData.cchOtherExports := 1;
            if not USBSafe(@USBData) or (USBBuffer[0] <> #0) or (USBBuffer[1] <> 'X') then
              raise Exception.Create('DVP_USBSafe buffer bounds');
            USBData.cchOtherExports := Length(USBBuffer);
            if not USBSafe(@USBData) or
               (string(PWideChar(@USBBuffer[0])) <>
                 {$IFDEF WIN64}'scintilla64.dll'{$ELSE}'scintilla.dll'{$ENDIF}) then
              raise Exception.Create('DVP_USBSafe dependency');
            FillChar(InitData, SizeOf(InitData), 0);
            InitData.cbSize := SizeOf(InitData);
            InitData.dwOpusVerMajor := 13;
            Writeln('STEP: init'); Flush(Output);
            if not InitOpus(@InitData) then raise Exception.Create('DVP_InitEx failed');
            try
              Writeln('STEP: create'); Flush(Output);
              Viewer := CreateViewer(Host.Handle, @Bounds, 0);
              if Viewer = 0 then raise Exception.Create('DVP_CreateViewer failed');
              CheckViewerBounds(Viewer, Host.Handle, Bounds);
              // Opus positions the HWND itself, then requests content resizing.
              // The zero content origin must not move the plugin over toolbars.
              SendMessage(Viewer, DVPLUGINMSG_RESIZE, 0, MakeLParam(800, 600));
              CheckViewerBounds(Viewer, Host.Handle, Bounds);
              try
                for I := Low(Extensions) to High(Extensions) do
                begin
                  FileName := IncludeTrailingPathDelimiter(ParamStr(3)) + 'sample.' + Extensions[I];
                  Writeln('STEP: load ',FileName); Flush(Output);
                  if SendMessage(Viewer, DVPLUGINMSG_LOADW, 0, LPARAM(PChar(FileName))) = 0 then
                    raise Exception.Create('LOADW failed: ' + FileName);
                  Application.ProcessMessages;
                  CheckEditor(Viewer, FileName, LexerIDs[I]);
                  CheckViewerBounds(Viewer, Host.Handle, Bounds);
                  Writeln('PASS: opus ', Extensions[I], ' text and lexer');
                  SendMessage(Viewer, DVPLUGINMSG_CLEAR, 0, 0);
                end;
                Configure(Host.Handle, 0, 0);
                CheckSettingsEscape(Host.Handle, Viewer);
              finally Writeln('STEP: destroy'); Flush(Output); DestroyWindow(Viewer); end;
            finally Writeln('STEP: uninit'); Flush(Output); UninitOpus; Writeln('STEP: uninited'); Flush(Output); end;
            if not InitOpus(@InitData) then raise Exception.Create('Reinit failed');
            try
              Configure(Host.Handle, 0, 0);
              CheckSettingsEscape(Host.Handle);
              Configure(0, 0, 0); // also cover shutdown with a dialog still open
            finally
              UninitOpus;
            end;
            UninitOpus; // idempotent shutdown
          end
        finally Writeln('STEP: free host'); Flush(Output); Host.Free; Writeln('STEP: host freed'); Flush(Output); end;
      finally Writeln('STEP: free library'); Flush(Output); if not FreeLibrary(Lib) then RaiseLastOSError;
      if GetModuleHandle(PChar(ParamStr(2))) <> 0 then raise Exception.Create('DLL still loaded');
      Writeln('PASS: DLL fully unloaded'); Flush(Output); end;
      Writeln('PASS: plugin lifecycle completed');
      end;
    except on E: Exception do begin Writeln(E.ClassName, ': ', E.Message); ExitCode := 1; end; end;
  finally CoUninitialize; end;
end.
