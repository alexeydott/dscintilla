unit DOSrcVwrExports;

{$R-}{$Q-}

interface

uses
  Winapi.Windows,
  DOpusViewerPlugins;

function DVP_InitEx(AInitData: LPDVPINITEXDATA): BOOL; cdecl;
procedure DVP_Uninit; cdecl;
function DVP_USBSafe(AUSBSafeData: LPOPUSUSBSAFEDATA): BOOL; cdecl;
function DVP_IdentifyW(APluginInfo: LPVIEWERPLUGININFOW): BOOL; cdecl;
function DVP_IdentifyFileW(AWnd: HWND; AFileName: LPWSTR;
  AFileInfo: LPVIEWERPLUGINFILEINFOW; AAbortEvent: THandle): BOOL; cdecl;
function DVP_CreateViewer(AParentWnd: HWND; ARect: PRECT;
  AFlags: DWORD): HWND; cdecl;
function DVP_Configure(AParentWnd: HWND; ANotifyWnd: HWND;
  ANotifyData: DWORD): HWND; cdecl;
function DVP_About(AParentWnd: HWND): HWND; cdecl;

implementation

uses
  System.SysUtils,
  DOSrcVwrRuntime,
  DOSrcVwrHost,
  DOSrcVwrIdentify,
  DOSrcVwrLog;

function DVP_InitEx(AInitData: LPDVPINITEXDATA): BOOL; cdecl;
begin
  LogInfo('>>> DVP_InitEx(AInitData=%p)', [Pointer(AInitData)]);
  try
    Result := DOSrcVwrRuntime.HandleInitEx(AInitData);
  except
    on E: Exception do
    begin
      LogError('!!! DVP_InitEx exception: %s', [E.Message]);
      Result := False;
    end;
  end;
  LogInfo('<<< DVP_InitEx => %s', [BoolToStr(Result, True)]);
end;

procedure DVP_Uninit; cdecl;
begin
  LogInfo('>>> DVP_Uninit');
  try
    DOSrcVwrRuntime.HandleUninit;
  except
    on E: Exception do
      LogError('!!! DVP_Uninit exception: %s', [E.Message]);
  end;
  LogInfo('<<< DVP_Uninit');
end;

function DVP_USBSafe(AUSBSafeData: LPOPUSUSBSAFEDATA): BOOL; cdecl;
begin
  LogInfo('>>> DVP_USBSafe(AUSBSafeData=%p)', [Pointer(AUSBSafeData)]);
  try
    Result := DOSrcVwrRuntime.HandleUSBSafe(AUSBSafeData);
  except
    on E: Exception do
    begin
      LogError('!!! DVP_USBSafe exception: %s', [E.Message]);
      Result := True;
    end;
  end;
  LogInfo('<<< DVP_USBSafe => %s', [BoolToStr(Result, True)]);
end;

function DVP_IdentifyW(APluginInfo: LPVIEWERPLUGININFOW): BOOL; cdecl;
begin
  LogInfo('>>> DVP_IdentifyW(APluginInfo=%p)', [Pointer(APluginInfo)]);
  try
    Result := DOSrcVwrIdentify.HandleIdentify(APluginInfo);
  except
    on E: Exception do
    begin
      LogError('!!! DVP_IdentifyW exception: %s', [E.Message]);
      Result := False;
    end;
  end;
  LogInfo('<<< DVP_IdentifyW => %s', [BoolToStr(Result, True)]);
end;

function DVP_IdentifyFileW(AWnd: HWND; AFileName: LPWSTR;
  AFileInfo: LPVIEWERPLUGINFILEINFOW; AAbortEvent: THandle): BOOL; cdecl;
var
  LName: string;
begin
  if AFileName <> nil then
    LName := string(AFileName)
  else
    LName := '(nil)';
  LogInfo('>>> DVP_IdentifyFileW(AWnd=$%x, File=%s)', [AWnd, LName]);
  try
    Result := DOSrcVwrIdentify.HandleIdentifyFile(AWnd, AFileName, AFileInfo, AAbortEvent);
  except
    on E: Exception do
    begin
      LogError('!!! DVP_IdentifyFileW exception: %s', [E.Message]);
      Result := False;
    end;
  end;
  LogInfo('<<< DVP_IdentifyFileW => %s', [BoolToStr(Result, True)]);
end;

function DVP_CreateViewer(AParentWnd: HWND; ARect: PRECT;
  AFlags: DWORD): HWND; cdecl;
begin
  LogInfo('>>> DVP_CreateViewer(Parent=$%x, Flags=$%x)', [AParentWnd, AFlags]);
  try
    Result := DOSrcVwrHost.HandleCreateViewer(AParentWnd, ARect, AFlags);
  except
    on E: Exception do
    begin
      LogError('!!! DVP_CreateViewer exception: %s', [E.Message]);
      Result := 0;
    end;
  end;
  LogInfo('<<< DVP_CreateViewer => $%x', [Result]);
end;

function DVP_Configure(AParentWnd: HWND; ANotifyWnd: HWND;
  ANotifyData: DWORD): HWND; cdecl;
begin
  LogInfo('>>> DVP_Configure(Parent=$%x, Notify=$%x)', [AParentWnd, ANotifyWnd]);
  try
    Result := DOSrcVwrHost.HandleConfigure(AParentWnd, ANotifyWnd, ANotifyData);
  except
    on E: Exception do
    begin
      LogError('!!! DVP_Configure exception: %s', [E.Message]);
      Result := 0;
    end;
  end;
  LogInfo('<<< DVP_Configure => $%x', [Result]);
end;

function DVP_About(AParentWnd: HWND): HWND; cdecl;
begin
  LogInfo('>>> DVP_About(Parent=$%x)', [AParentWnd]);
  try
    Result := DOSrcVwrHost.HandleAbout(AParentWnd);
  except
    on E: Exception do
    begin
      LogError('!!! DVP_About exception: %s', [E.Message]);
      Result := 0;
    end;
  end;
  LogInfo('<<< DVP_About => $%x', [Result]);
end;

end.
