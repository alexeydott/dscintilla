unit DSciPreviewBase;
// IPreviewHandler infrastructure for DSciSrcVwr.
interface

uses
  Windows, Messages, ActiveX, ComObj, ShlObj, Winapi.PropSys, Winapi.ShLwApi,
  Classes, Graphics, Controls, Forms, SysUtils;


type
	///<summary>Init state for control</summary>
  TDSciInitType = (isNotInited, isInitedWithStream, isInitedWithParentAndItem, isInitedWithShellItem, isInitedWithFile);

  TDSciPreviewExtension      = class;
  TDSciPreviewExtensionClass = class of TDSciPreviewExtension;

	{$region '  TDSciPreviewExtensionForm'}
	///<summary>Base control used as the preview panel</summary>
  TDSciPreviewExtensionForm = class(TForm)
  private
    // Saved HWND during csRecreating — prevents VCL from destroying and
    // recreating the window (and losing Scintilla's internal state).
    FSavedHandle: HWND;
  protected
    procedure ClearPreview; virtual;
    function  TranslateAccelerator(const AMessage: TMsg): Boolean; virtual;
    // Handle preservation during RecreateWnd (e.g. VCL style change).
    procedure DestroyWnd; override;
    procedure CreateWnd;  override;
  public
    procedure AfterConstruction; override;
    // Override: WM_ACTIVATE is not sent to WS_CHILD windows so FActive stays
    // False; inherited TCustomForm.SetFocus raises EInvalidOperation when
    // the form is embedded via ParentWindow (no VCL Parent).
    procedure SetFocus; override;
    function SelectFirstControl: Boolean;
    function SelectLastControl: Boolean;
    function SelectNextControl(ACheckOnly: Boolean = False): Boolean;
  end;
	{$endregion}

	{$region '  TDSciPreviewExtension'}
	///<summary>Implementation for Shell IPreviewHandler stack.</summary>
  TDSciPreviewExtension = class(TComObject,
    IPreviewHandler, IPreviewHandlerVisuals, IOleWindow, IObjectWithSite,
    IPersistStream, IParentAndItem, IPersistFile,
    IInitializeWithStream, IInitializeWithItem, IInitializeWithFile)
  private
    { init state }
    FInitType:   TDSciInitType;
    FOpenMode:   DWORD;
    FStream:     IStream;
    FFolder:     IShellFolder;
    FChild:      PItemIDList;
    FShellItem:  IShellItem;
    FFileName:   UnicodeString;

    { preview-handler window state }
    FParent:      HWND;
    FRect:        TRect;
    FRectInited:  Boolean;
    FControl:     TDSciPreviewExtensionForm;

    { site / frame }
    FPreviewHandlerFrame: IPreviewHandlerFrame;
    FSite:               IUnknown;

    { visuals }
    FAutoBackgroundColor:      Boolean;
    FAutoFont:                 Boolean;
    FAutoFontColor:            Boolean;
    FBackgroundColor:          TColorRef;
    FBackgroundColorInited:    Boolean;
    FFont:                     TLogFont;
    FFontInited:               Boolean;
    FFontColor:                TColorRef;
    FFontColorInited:          Boolean;

  public
    procedure Initialize; override;
    destructor Destroy; override;

    { class-level virtual API }
    class function  GetClassID:    TCLSID; virtual;
    class function  GetDescription: UnicodeString; virtual;
    class procedure FillProgIDList(AList: TStrings); virtual;
    class procedure Register;

  protected
    { virtual preview API }
    procedure SetSite(const ASite: IUnknown); virtual;
    function  CreatePreview(AParent: HWND): TDSciPreviewExtensionForm; virtual;
    procedure LoadPreviewFromStream(AStream: TStream; AOpenMode: DWORD;
      APreview: TDSciPreviewExtensionForm); virtual;
    procedure LoadPreviewFromIStream(AStream: IStream; AOpenMode: DWORD;
      APreview: TDSciPreviewExtensionForm); virtual;
    procedure LoadPreviewFromFile(const AFileName: UnicodeString; AOpenMode: DWORD;
      APreview: TDSciPreviewExtensionForm); virtual;
    procedure Clear; virtual;

    { visual knobs (set by IPreviewHandlerVisuals before DoPreview) }
    property AutoBackgroundColor: Boolean read FAutoBackgroundColor write FAutoBackgroundColor;
    property AutoFont:            Boolean read FAutoFont            write FAutoFont;
    property AutoFontColor:       Boolean read FAutoFontColor       write FAutoFontColor;

    { init state accessors }
    property InitType: TDSciInitType read FInitType;
    property OpenMode: DWORD         read FOpenMode;
    function GetCurrentFileName(AIncludePath: Boolean = False): UnicodeString;
    function GetCurrentIStream: IStream;

  private
    { Implementation helpers }
    procedure DoPreviewInternal;

    { IPersist (shared GetClassID for IPersistStream and IPersistFile) }
    function IPersist_GetClassID(out classID: TCLSID): HRESULT; stdcall;

    { IPersistStream }
    function IPersistStream.GetClassID  = IPersist_GetClassID;
    function IPersistStream_IsDirty: HRESULT; stdcall;
    function IPersistStream_Load(const AStream: IStream): HRESULT; stdcall;
    function IPersistStream_Save(const AStream: IStream; AClearDirty: BOOL): HRESULT; stdcall;
    function IPersistStream_GetSizeMax(out ASize: Largeint): HRESULT; stdcall;
    function IPersistStream.IsDirty    = IPersistStream_IsDirty;
    function IPersistStream.Load       = IPersistStream_Load;
    function IPersistStream.Save       = IPersistStream_Save;
    function IPersistStream.GetSizeMax = IPersistStream_GetSizeMax;

    { IParentAndItem }
    function IParentAndItem_SetParentAndItem(pidlParent: PItemIDList;
      const psf: IShellFolder; pidlChild: PItemIDList): HRESULT; stdcall;
    function IParentAndItem_GetParentAndItem(var ppidlParent: PItemIDList;
      out ppsf: IShellFolder; out ppidlChild: PItemIDList): HRESULT; stdcall;
    function IParentAndItem.SetParentAndItem = IParentAndItem_SetParentAndItem;
    function IParentAndItem.GetParentAndItem = IParentAndItem_GetParentAndItem;

    { IPersistFile }
    function IPersistFile.GetClassID    = IPersist_GetClassID;
    function IPersistFile_IsDirty: HRESULT; stdcall;
    function IPersistFile_Load(AFileName: POleStr; AOpenMode: Longint): HRESULT; stdcall;
    function IPersistFile_Save(AFileName: POleStr; ARemember: BOOL): HRESULT; stdcall;
    function IPersistFile_SaveCompleted(AFileName: POleStr): HRESULT; stdcall;
    function IPersistFile_GetCurFile(out AFileName: POleStr): HRESULT; stdcall;
    function IPersistFile.IsDirty        = IPersistFile_IsDirty;
    function IPersistFile.Load           = IPersistFile_Load;
    function IPersistFile.Save           = IPersistFile_Save;
    function IPersistFile.SaveCompleted  = IPersistFile_SaveCompleted;
    function IPersistFile.GetCurFile     = IPersistFile_GetCurFile;

    { IInitializeWithStream }
    function IInitializeWithStream_Initialize(const AStream: IStream; AOpenMode: DWORD): HRESULT; stdcall;
    function IInitializeWithStream.Initialize = IInitializeWithStream_Initialize;

    { IInitializeWithItem }
    function IInitializeWithItem_Initialize(const AShellItem: IShellItem; AOpenMode: DWORD): HRESULT; stdcall;
    function IInitializeWithItem.Initialize = IInitializeWithItem_Initialize;

		{ IInitializeWithFile }
    function IInitializeWithFile_Initialize(AFilePath: LPCWSTR; AOpenMode: DWORD): HRESULT; stdcall;
    function IInitializeWithFile.Initialize = IInitializeWithFile_Initialize;

		{ IObjectWithSite }
    function IObjectWithSite_SetSite(const ASite: IUnknown): HRESULT; stdcall;
    function IObjectWithSite_GetSite(const AIID: TIID; out ASite: IUnknown): HRESULT; stdcall;
    function IObjectWithSite.SetSite = IObjectWithSite_SetSite;
    function IObjectWithSite.GetSite = IObjectWithSite_GetSite;

    { IPreviewHandler }
    function IPreviewHandler_SetWindow(AWnd: HWND; var ARect: TRect): HRESULT; stdcall;
    function IPreviewHandler_SetRect(var ARect: TRect): HRESULT; stdcall;
    function IPreviewHandler_DoPreview: HRESULT; stdcall;
    function IPreviewHandler_Unload: HRESULT; stdcall;
    function IPreviewHandler_SetFocus: HRESULT; stdcall;
    function IPreviewHandler_QueryFocus(var AWnd: HWND): HRESULT; stdcall;
    function IPreviewHandler_TranslateAccelerator(var AMessage: TMsg): HRESULT; stdcall;
    function IPreviewHandler.SetWindow = IPreviewHandler_SetWindow;
    function IPreviewHandler.SetRect = IPreviewHandler_SetRect;
    function IPreviewHandler.DoPreview = IPreviewHandler_DoPreview;
    function IPreviewHandler.Unload = IPreviewHandler_Unload;
    function IPreviewHandler.SetFocus = IPreviewHandler_SetFocus;
    function IPreviewHandler.QueryFocus = IPreviewHandler_QueryFocus;
    function IPreviewHandler.TranslateAccelerator = IPreviewHandler_TranslateAccelerator;

    { IPreviewHandlerVisuals }
    function IPreviewHandlerVisuals_SetBackgroundColor(AColor: TColorRef): HRESULT; stdcall;
    function IPreviewHandlerVisuals_SetFont(const ALogFont: TLogFont): HRESULT; stdcall;
    function IPreviewHandlerVisuals_SetTextColor(AColor: TColorRef): HRESULT; stdcall;
    function IPreviewHandlerVisuals.SetBackgroundColor = IPreviewHandlerVisuals_SetBackgroundColor;
    function IPreviewHandlerVisuals.SetFont = IPreviewHandlerVisuals_SetFont;
    function IPreviewHandlerVisuals.SetTextColor = IPreviewHandlerVisuals_SetTextColor;

    { IOleWindow }
    function IOleWindow_GetWindow(out AWnd: HWnd): HRESULT; stdcall;
    function IOleWindow_ContextSensitiveHelp(AEnterMode: BOOL): HRESULT; stdcall;
    function IOleWindow.GetWindow             = IOleWindow_GetWindow;
    function IOleWindow.ContextSensitiveHelp  = IOleWindow_ContextSensitiveHelp;
  end;
{$endregion}

  {$region '  TDSciPreviewFactory'}
	///<summary> COM factory that writes preview-handler-specific registry entries in addition to the standard COM CLSID entries.</summary>
  TDSciPreviewFactory = class(TComObjectFactory)
  public
    procedure UpdateRegistry(ARegister: Boolean); override;
  end;
{$endregion}

  {$region '  Helpers'}
function IsRunningOnWOW64: Boolean;
function IsWindowsDarkTheme: Boolean;
function ThemedColor(AColor: TColor): TColor;
function UnicodeStringToString(const S: UnicodeString): string; inline;
function HResultFromException(AException: Exception): HRESULT;
{$endregion}

implementation

uses
  Themes, ComServ;

{$region '  Helper utilities'}
const
  // AppID used when process isolation is active (WOW64 / 32-bit host on 64-bit OS)
  cAppID_WOW64  = '{534A1E02-D58F-44f0-B58B-36CBED287C7C}';
  // AppID for native (same-bitness) hosting
  cAppID_Native = '{6D2B5079-2F0B-48DD-AB7F-97CEC514D30B}';
  // Preview handler shell extension GUID (constant across all preview handlers)
  cPreviewHandlerGUID = '{8895B1C6-B41F-4C1C-A562-0D564250836F}';
  // Windows PreviewHandlers list key
  cPreviewHandlerListKey = 'SOFTWARE\Microsoft\Windows\CurrentVersion\PreviewHandlers';

  STGM_SHARE_DENY_NONE = $40;

function IsRunningOnWOW64: Boolean;
var
  LIsWow64: BOOL;
begin
  LIsWow64 := False;
  IsWow64Process(GetCurrentProcess, LIsWow64);
  Result := LIsWow64;
end;

function UnicodeStringToString(const S: UnicodeString): string; inline;
begin
  Result := S;
end;

function HResultFromException(AException: Exception): HRESULT;
begin
  if AException is EOleSysError then
    Result := EOleSysError(AException).ErrorCode
  else
    Result := E_FAIL;
end;

// Registry helpers
procedure DSciCreateRegKeyValue(ARootKey: HKEY; const AKey, AValueName,
  AValue: UnicodeString);
var
  LKey: HKEY;
  LDisp: DWORD;
  LData: UnicodeString;
begin
  if RegCreateKeyExW(ARootKey, PWideChar(AKey), 0, nil, REG_OPTION_NON_VOLATILE,
      KEY_SET_VALUE or KEY_CREATE_SUB_KEY, nil, LKey, @LDisp) = ERROR_SUCCESS then
  try
    LData := AValue;
    RegSetValueExW(LKey, PWideChar(AValueName), 0, REG_SZ, Pointer(LData),
      (Length(LData) + 1) * SizeOf(WideChar));
  finally
    RegCloseKey(LKey);
  end;
end;

function DSciReadRegKeyDword(ARootKey: HKEY; const AKey, AValueName: UnicodeString; out AValue: DWORD): Boolean;
var
  LKey: HKEY;
  LDataSize: DWORD;
  LRegType: DWORD;
begin
  Result := False;
  if RegOpenKeyExW(ARootKey, PWideChar(AKey), 0, KEY_READ, LKey) = ERROR_SUCCESS then
  try
    LDataSize := SizeOf(DWORD);
    if (RegQueryValueExW(LKey, PWideChar(AValueName), nil, @LRegType,
        @AValue, @LDataSize) = ERROR_SUCCESS) and (LRegType = REG_DWORD) then
      Result := True;
  finally
    RegCloseKey(LKey);
  end;
end;

procedure DSciDeleteRegKey(ARootKey: HKEY; const AKey: UnicodeString);
begin
  RegDeleteKeyW(ARootKey, PWideChar(AKey));
end;

procedure DSciDeleteRegValue(ARootKey: HKEY; const AKey,
  AValueName: UnicodeString);
var
  LKey: HKEY;
begin
  if RegOpenKeyExW(ARootKey, PWideChar(AKey), 0, KEY_SET_VALUE,
      LKey) = ERROR_SUCCESS then
  try
    RegDeleteValueW(LKey, PWideChar(AValueName));
  finally
    RegCloseKey(LKey);
  end;
end;

function IsWindowsDarkTheme: Boolean;
var
  LValue: DWORD;
begin
  Result := False;
  if DSciReadRegKeyDword(HKEY_CURRENT_USER,
      'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize',
      'AppsUseLightTheme', LValue) then
  begin
    Result := (LValue = 0);
  end;
end;

function ThemedColor(AColor: TColor): TColor;
begin
  Result := TStyleManager.ActiveStyle.GetSystemColor(AColor);
end;

{$endregion}

{$region '  TDSciPreviewExtensionForm'}

{ TDSciPreviewExtensionForm }
procedure TDSciPreviewExtensionForm.AfterConstruction;
begin
  inherited AfterConstruction;
  BorderStyle := bsNone;
  if IsWindowsDarkTheme then
    EnableImmersiveDarkMode(True)
  else
    EnableImmersiveDarkMode(False)
end;

procedure TDSciPreviewExtensionForm.ClearPreview;
begin
  // override to clear editor content
end;

function TDSciPreviewExtensionForm.TranslateAccelerator(
  const AMessage: TMsg): Boolean;
begin
  Result := False;
end;

procedure TDSciPreviewExtensionForm.SetFocus;
begin
  // WM_ACTIVATE is not delivered to WS_CHILD windows, so TCustomForm.FActive
  // stays False for a Shell-embedded form (ParentWindow set, no VCL Parent).
  // TCustomForm.SetFocus then raises EInvalidOperation (SCannotFocus /
  // "ControlHasNoParentWindow") when not (Visible and Enabled).
  // Bypass TCustomForm routing and call Win32 SetFocus directly.
  if (Parent = nil) and HandleAllocated then
    Winapi.Windows.SetFocus(Handle)
  else
    inherited SetFocus;
end;

procedure TDSciPreviewExtensionForm.DestroyWnd;
begin
  if csRecreating in ControlState then
  begin
    // Detach the window to Application temporarily rather than destroying it.
    // This keeps child windows (Scintilla editor) alive with their internal
    // state (document content, undo history, etc.) intact.
    // Restored in CreateWnd when csRecreating is still in ControlState.
    Winapi.Windows.SetParent(WindowHandle, Application.Handle);
    FSavedHandle := WindowHandle;
    WindowHandle := 0;
  end
  else
  begin
    FSavedHandle := 0;
    inherited DestroyWnd;
  end;
end;

procedure TDSciPreviewExtensionForm.CreateWnd;
begin
  if (FSavedHandle <> 0) and IsWindow(FSavedHandle) then
  begin
    // Reclaim the preserved HWND instead of creating a new window.
    WindowHandle := FSavedHandle;
    FSavedHandle := 0;
    // Restore the correct parent (Shell host or VCL parent).
    if ParentWindow <> 0 then
      Winapi.Windows.SetParent(WindowHandle, ParentWindow)
    else if Parent <> nil then
      Winapi.Windows.SetParent(WindowHandle, Parent.Handle);
    // Sync window geometry to the current VCL Left/Top/Width/Height.
    Winapi.Windows.MoveWindow(WindowHandle, Left, Top, Width, Height, True);
    Realign;
  end
  else
    inherited CreateWnd;
end;

function TDSciPreviewExtensionForm.SelectFirstControl: Boolean;
var
  LCtl: TWinControl;
begin
  LCtl := FindNextControl(nil, True, True, False);
  Result := LCtl <> nil;
  if Result and LCtl.HandleAllocated then
    // Win32 directly: bypasses FocusControl to SetActiveControl which raises
    // EInvalidOperation(SCannotFocus) when not CanFocus, and TCustomForm.SetFocus
    // which raises for WS_CHILD forms (FActive is never True via WM_ACTIVATE).
    Winapi.Windows.SetFocus(LCtl.Handle);
  // If no handle yet, skip silently -- Shell will retry after DoPreview.
end;

function TDSciPreviewExtensionForm.SelectLastControl: Boolean;
var
  LCtl: TWinControl;
begin
  LCtl := FindNextControl(nil, False, True, False);
  Result := LCtl <> nil;
  if Result and LCtl.HandleAllocated then
    Winapi.Windows.SetFocus(LCtl.Handle);
end;

function TDSciPreviewExtensionForm.SelectNextControl(
  ACheckOnly: Boolean): Boolean;
var
  LFocused: TWinControl;
  LNext: TWinControl;
begin
  LFocused := nil;
  if (ActiveControl <> nil) and (ActiveControl is TWinControl) then
    LFocused := ActiveControl as TWinControl;
  LNext := FindNextControl(LFocused, True, True, False);
  Result := LNext <> nil;
  if Result and not ACheckOnly and LNext.HandleAllocated then
    Winapi.Windows.SetFocus(LNext.Handle);
end;

class function TDSciPreviewExtension.GetClassID: TCLSID;
begin
  FillChar(Result, SizeOf(Result), 0);
end;

class function TDSciPreviewExtension.GetDescription: UnicodeString;
begin
  Result := '';
end;

class procedure TDSciPreviewExtension.FillProgIDList(AList: TStrings);
begin
  // override to populate AList with handled file extensions (e.g. '.pas', '.cpp')
end;

class procedure TDSciPreviewExtension.Register;
begin
  TDSciPreviewFactory.Create(ComServer, Self, GetClassID, '',
    GetDescription, ciMultiInstance, tmApartment);
end;
{$endregion}

{$region '  TDSciPreviewExtension'}
{ TDSciPreviewExtension }
procedure TDSciPreviewExtension.Initialize;
begin
  inherited Initialize;
  FInitType            := isNotInited;
  FAutoBackgroundColor := True;
  FAutoFont            := True;
  FAutoFontColor       := True;
end;

destructor TDSciPreviewExtension.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TDSciPreviewExtension.Clear;
begin
  if FControl <> nil then
  begin
    FControl.ClearPreview;
    // Detach from the shell host window BEFORE hiding/destroying the form.
    // The host process (Explorer.exe) is blocked waiting for our COM
    // IPreviewHandler.UnloadPreview call to return. ShowWindow(SW_HIDE) on a
    // window whose parent is in the host process sends a synchronous
    // cross-process WM_ACTIVATE/WM_SETFOCUS message to activate Explorer's UI
    // thread — but that thread is already blocked on us. Deadlock.
    // Reparenting to Application.Handle (prevhost.exe's own hidden window) first
    // keeps all subsequent hide/destroy operations in-process.
    if FControl.HandleAllocated then
      Winapi.Windows.SetParent(FControl.Handle, Application.Handle);
    FControl.Hide;
    FreeAndNil(FControl);
  end;
  FStream    := nil;
  FFolder    := nil;
  FShellItem := nil;
  if FChild <> nil then
  begin
    CoTaskMemFree(FChild);
    FChild := nil;
  end;
  FFileName := '';
  FInitType := isNotInited;
  FOpenMode := 0;
end;

procedure TDSciPreviewExtension.SetSite(const ASite: IUnknown);
begin
  FSite := ASite;
  FPreviewHandlerFrame := nil;
  if ASite <> nil then
    ASite.QueryInterface(IPreviewHandlerFrame, FPreviewHandlerFrame);
end;

function TDSciPreviewExtension.CreatePreview( AParent: HWND): TDSciPreviewExtensionForm;
begin
  Result := TDSciPreviewExtensionForm.CreateParented(AParent);
end;

procedure TDSciPreviewExtension.LoadPreviewFromStream(AStream: TStream; AOpenMode: DWORD; APreview: TDSciPreviewExtensionForm);
begin
  // override in subclass
end;

procedure TDSciPreviewExtension.LoadPreviewFromIStream(AStream: IStream;
  AOpenMode: DWORD; APreview: TDSciPreviewExtensionForm);
const
  CBufSize = 8192;
var
  LMem:    TMemoryStream;
  LBuf:    array[0..CBufSize - 1] of Byte;
  LRead:   Cardinal;
  LNewPos: UInt64;
begin
  LMem := TMemoryStream.Create;
  try
    AStream.Seek(0, STREAM_SEEK_SET, LNewPos);
    repeat
      LRead := 0;
      AStream.Read(@LBuf[0], CBufSize, @LRead);
      if LRead > 0 then
        LMem.WriteBuffer(LBuf[0], LRead);
    until LRead = 0;
    LMem.Position := 0;
    LoadPreviewFromStream(LMem, AOpenMode, APreview);
  finally
    LMem.Free;
  end;
end;

procedure TDSciPreviewExtension.LoadPreviewFromFile(
  const AFileName: UnicodeString; AOpenMode: DWORD;
  APreview: TDSciPreviewExtensionForm);
begin
  // override in subclass
end;

function TDSciPreviewExtension.GetCurrentFileName(AIncludePath: Boolean): UnicodeString;
var
  LStat: TStatStg;
  LBuf: array[0..MAX_PATH - 1] of WideChar;
  LStrRet: TStrRet;
  LPw: LPWSTR;
begin
  Result := '';
  case FInitType of
    isInitedWithStream:
    begin
      ZeroMemory(@LStat, SizeOf(LStat));
      if (FStream <> nil) and
          Succeeded(FStream.Stat(LStat, STATFLAG_DEFAULT)) then
      try
        Result := LStat.pwcsName;
      finally
        CoTaskMemFree(LStat.pwcsName);
      end;
    end;

    isInitedWithParentAndItem:
    begin
      if FFolder <> nil then
      begin
        ZeroMemory(@LStrRet, SizeOf(LStrRet));
        if Succeeded(FFolder.GetDisplayNameOf(FChild, SHGDN_FORPARSING,
            LStrRet)) then
        begin
          StrRetToBufW(@LStrRet, FChild, @LBuf[0], MAX_PATH);
          Result := LBuf;
        end;
      end;
    end;

    isInitedWithShellItem:
    begin
      if FShellItem <> nil then
      begin
        LPw := nil;
        if Succeeded(FShellItem.GetDisplayName(SIGDN_FILESYSPATH, LPw)) then
        try
          Result := LPw;
        finally
          CoTaskMemFree(LPw);
        end;
      end;
    end;

    isInitedWithFile:
      Result := FFileName;
  end;

  if not AIncludePath then
    Result := ExtractFileName(Result);
end;

function TDSciPreviewExtension.GetCurrentIStream: IStream;
var
  LFileName: UnicodeString;
begin
  Result := nil;
  case FInitType of
    isInitedWithStream:
      Result := FStream;
    isInitedWithParentAndItem, isInitedWithShellItem, isInitedWithFile:
    begin
      LFileName := GetCurrentFileName(True);
      if LFileName <> '' then
        SHCreateStreamOnFileW(PWideChar(LFileName),
          STGM_READ or STGM_SHARE_DENY_NONE, Result);
    end;
  end;
end;

procedure TDSciPreviewExtension.DoPreviewInternal;
var
  LFileName: UnicodeString;
  LStream:   IStream;
begin
  if FControl = nil then
  begin
    FControl := CreatePreview(FParent);
    // Apply visuals before the control is shown
    if FAutoBackgroundColor and FBackgroundColorInited then
      FControl.Color := FBackgroundColor;
    if FAutoFont and FFontInited then
      FControl.Font.Handle := CreateFontIndirectW(FFont);
    if FAutoFontColor and FFontColorInited then
      FControl.Font.Color := FFontColor;
  end;

  if FRectInited then
  begin
    FControl.SetBounds(FRect.Left, FRect.Top,
      FRect.Right - FRect.Left, FRect.Bottom - FRect.Top);
    SetWindowPos(FControl.Handle, 0, FRect.Left, FRect.Top,
      FRect.Right - FRect.Left, FRect.Bottom - FRect.Top,
      SWP_NOZORDER or SWP_NOACTIVATE);
  end;

  // Determine what to load
  LFileName := '';
  case FInitType of
    isInitedWithParentAndItem, isInitedWithShellItem:
    begin
      LFileName := GetCurrentFileName(True);
      if not FileExists(LFileName) then
        LFileName := '';
    end;
    isInitedWithFile:
      LFileName := GetCurrentFileName(True);
  end;

  if LFileName <> '' then
    LoadPreviewFromFile(LFileName, FOpenMode, FControl)
  else
  begin
    LStream := GetCurrentIStream;
    if LStream <> nil then
      LoadPreviewFromIStream(LStream, FOpenMode, FControl);
  end;

  FControl.Show;
  FControl.Update;
end;

function TDSciPreviewExtension.IPreviewHandler_SetWindow(AWnd: HWND; var ARect: TRect): HRESULT;
begin
  try
    FParent    := AWnd;
    FRect      := ARect;
    FRectInited := True;
    if FControl <> nil then
    begin
      Windows.SetParent(FControl.Handle, FParent);
      SetWindowPos(FControl.Handle, 0, ARect.Left, ARect.Top,
        ARect.Right - ARect.Left, ARect.Bottom - ARect.Top,
        SWP_NOZORDER or SWP_NOACTIVATE);
    end;
    Result := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IPreviewHandler_SetRect(
  var ARect: TRect): HRESULT;
begin
  try
    FRect      := ARect;
    FRectInited := True;
    if FControl <> nil then
      SetWindowPos(FControl.Handle, 0, ARect.Left, ARect.Top,
        ARect.Right - ARect.Left, ARect.Bottom - ARect.Top,
        SWP_NOZORDER or SWP_NOACTIVATE);
    Result := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IPreviewHandler_DoPreview: HRESULT;
begin
  try
    if FInitType = isNotInited then
    begin
      Result := E_FAIL;
      Exit;
    end;
    DoPreviewInternal;
    Result := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IPreviewHandler_Unload: HRESULT;
begin
  try
    Clear;
    Result := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IPreviewHandler_SetFocus: HRESULT;
begin
  try
    if (FControl <> nil) and FControl.HandleAllocated then
    begin
      // Shell passes focus forward (Tab) when VK_SHIFT is up, backward (Shift+Tab) when VK_SHIFT is down
      if GetKeyState(VK_SHIFT) >= 0 then
        FControl.SelectFirstControl
      else
        FControl.SelectLastControl;
    end;
    Result := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IPreviewHandler_QueryFocus(
  var AWnd: HWND): HRESULT;
begin
  try
    AWnd   := GetFocus;
    Result := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IPreviewHandler_TranslateAccelerator(var AMessage: TMsg): HRESULT;
begin
  Result := S_FALSE;
  try
    if FControl = nil then Exit;

    // Tab / Shift+Tab cycle focus within the preview panel
    if (AMessage.message = WM_KEYDOWN) and (AMessage.wParam = VK_TAB) then
    begin
      if GetKeyState(VK_SHIFT) < 0 then
        FControl.SelectLastControl
      else
        FControl.SelectNextControl;
      Result := S_OK;
      Exit;
    end;

    // Let the form's own accelerator handler try first
    if FControl.TranslateAccelerator(AMessage) then
    begin
      Result := S_OK;
      Exit;
    end;

    // Forward to Explorer's frame
    if FPreviewHandlerFrame <> nil then
      Result := FPreviewHandlerFrame.TranslateAccelerator(AMessage);
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IPreviewHandlerVisuals_SetBackgroundColor(AColor: TColorRef): HRESULT;
begin
  FBackgroundColor      := AColor;
  FBackgroundColorInited := True;
  if FAutoBackgroundColor and (FControl <> nil) then
    FControl.Color := AColor;
  Result := S_OK;
end;

function TDSciPreviewExtension.IPreviewHandlerVisuals_SetFont(const ALogFont: TLogFont): HRESULT;
begin
  FFont      := ALogFont;
  FFontInited := True;
  if FAutoFont and (FControl <> nil) then
    FControl.Font.Handle := CreateFontIndirectW(FFont);
  Result := S_OK;
end;

function TDSciPreviewExtension.IPreviewHandlerVisuals_SetTextColor(AColor: TColorRef): HRESULT;
begin
  FFontColor      := AColor;
  FFontColorInited := True;
  if FAutoFontColor and (FControl <> nil) then
    FControl.Font.Color := AColor;
  Result := S_OK;
end;

function TDSciPreviewExtension.IOleWindow_GetWindow(out AWnd: HWnd): HRESULT;
begin
  try
    if FControl <> nil then
      AWnd := FControl.Handle
    else
      AWnd := FParent;
    Result := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IOleWindow_ContextSensitiveHelp(AEnterMode: BOOL): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TDSciPreviewExtension.IObjectWithSite_SetSite(const ASite: IUnknown): HRESULT;
begin
  try
    SetSite(ASite);
    Result := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IObjectWithSite_GetSite(const AIID: TIID; out ASite: IUnknown): HRESULT;
begin
  if FSite <> nil then
    Result := FSite.QueryInterface(AIID, ASite)
  else
  begin
    ASite  := nil;
    Result := E_NOINTERFACE;
  end;
end;

function TDSciPreviewExtension.IPersist_GetClassID(out classID: TCLSID): HRESULT;
begin
  try
    classID := GetClassID;
    Result  := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IPersistStream_IsDirty: HRESULT;
begin
  Result := S_FALSE;
end;

function TDSciPreviewExtension.IPersistStream_Load(const AStream: IStream): HRESULT;
begin
  try
    if FInitType <> isNotInited then
    begin
      Result := E_UNEXPECTED;
      Exit;
    end;
    FStream   := AStream;
    FOpenMode := STGM_READ;
    FInitType := isInitedWithStream;
    Result    := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IPersistStream_Save(const AStream: IStream; AClearDirty: BOOL): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TDSciPreviewExtension.IPersistStream_GetSizeMax(
  out ASize: Largeint): HRESULT;
begin
  ASize  := 0;
  Result := E_NOTIMPL;
end;

function TDSciPreviewExtension.IParentAndItem_SetParentAndItem(pidlParent: PItemIDList; const psf: IShellFolder;pidlChild: PItemIDList): HRESULT;
begin
  try
    if FInitType <> isNotInited then
    begin
      Result := E_UNEXPECTED;
      Exit;
    end;
    FFolder := psf;
    if pidlChild <> nil then
      FChild := ILClone(pidlChild)
    else
      FChild := nil;
    FOpenMode := STGM_READ;
    FInitType := isInitedWithParentAndItem;
    Result    := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IParentAndItem_GetParentAndItem(var ppidlParent: PItemIDList; out ppsf: IShellFolder; out ppidlChild: PItemIDList): HRESULT;
begin
  try
    ppidlParent := nil;     // parent PIDL not stored; return nil
    ppsf        := FFolder;
    ppidlChild  := ILClone(FChild);
    Result      := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IPersistFile_IsDirty: HRESULT;
begin
  Result := S_FALSE;
end;

function TDSciPreviewExtension.IPersistFile_Load(AFileName: POleStr; AOpenMode: Longint): HRESULT;
begin
  try
    if FInitType <> isNotInited then
    begin
      Result := E_UNEXPECTED;
      Exit;
    end;
    FFileName := AFileName;
    FOpenMode := DWORD(AOpenMode);
    FInitType := isInitedWithFile;
    Result    := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IPersistFile_Save(AFileName: POleStr; ARemember: BOOL): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TDSciPreviewExtension.IPersistFile_SaveCompleted(AFileName: POleStr): HRESULT;
begin
  Result := S_OK;
end;

function TDSciPreviewExtension.IPersistFile_GetCurFile(out AFileName: POleStr): HRESULT;
var
  LName: UnicodeString;
begin
  try
    LName     := GetCurrentFileName(True);
    AFileName := CoTaskMemAlloc((Length(LName) + 1) * SizeOf(WideChar));
    if AFileName <> nil then
    begin
      CopyMemory(AFileName, PWideChar(LName), (Length(LName) + 1) * SizeOf(WideChar));
      Result := S_OK;
    end
    else
      Result := E_OUTOFMEMORY;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;


function TDSciPreviewExtension.IInitializeWithStream_Initialize(const AStream: IStream; AOpenMode: DWORD): HRESULT;
begin
  try
    if FInitType <> isNotInited then
    begin
      Result := E_UNEXPECTED;
      Exit;
    end;
    FStream   := AStream;
    FOpenMode := AOpenMode;
    FInitType := isInitedWithStream;
    Result    := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IInitializeWithItem_Initialize(const AShellItem: IShellItem; AOpenMode: DWORD): HRESULT;
begin
  try
    if FInitType <> isNotInited then
    begin
      Result := E_UNEXPECTED;
      Exit;
    end;
    FShellItem := AShellItem;
    FOpenMode  := AOpenMode;
    FInitType  := isInitedWithShellItem;
    Result     := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;

function TDSciPreviewExtension.IInitializeWithFile_Initialize(AFilePath: LPCWSTR; AOpenMode: DWORD): HRESULT;
begin
  try
    if FInitType <> isNotInited then
    begin
      Result := E_UNEXPECTED;
      Exit;
    end;
    FFileName := AFilePath;
    FOpenMode := AOpenMode;
    FInitType := isInitedWithFile;
    Result    := S_OK;
  except
    on E: Exception do Result := HResultFromException(E);
  end;
end;
{$endregion}

{$region '  TDSciPreviewFactory'}
{ TDSciPreviewFactory }
procedure TDSciPreviewFactory.UpdateRegistry(ARegister: Boolean);
var
  LExt:     TDSciPreviewExtensionClass;
  LClassID: string;
  LAppID:   string;
  LProgIDs: TStringList;
  I:        Integer;
begin
  inherited UpdateRegistry(ARegister);

  LExt     := TDSciPreviewExtensionClass(ComClass);
  LClassID := GUIDToString(LExt.GetClassID);

  if IsRunningOnWOW64 then
    LAppID := cAppID_WOW64
  else
    LAppID := cAppID_Native;

  LProgIDs := TStringList.Create;
  try
    LExt.FillProgIDList(LProgIDs);

    if ARegister then
    begin
      // AppID (required for cross-process hosting / low-integrity preview pane)
      DSciCreateRegKeyValue(HKEY_CLASSES_ROOT,
        'CLSID\' + LClassID, 'AppID', LAppID);

      // Per-extension shell preview association
      for I := 0 to LProgIDs.Count - 1 do
        DSciCreateRegKeyValue(HKEY_CLASSES_ROOT,
          LProgIDs[I] + '\ShellEx\' + cPreviewHandlerGUID, '', LClassID);

      // Global preview handlers list (needed for Windows to discover the handler)
      DSciCreateRegKeyValue(HKEY_LOCAL_MACHINE,
        cPreviewHandlerListKey, LClassID, LExt.GetDescription);
    end
    else
    begin
      // Per-extension entries
      for I := 0 to LProgIDs.Count - 1 do
        DSciDeleteRegKey(HKEY_CLASSES_ROOT,
          LProgIDs[I] + '\ShellEx\' + cPreviewHandlerGUID);

      // Global list entry
      DSciDeleteRegValue(HKEY_LOCAL_MACHINE, cPreviewHandlerListKey, LClassID);
    end;
  finally
    LProgIDs.Free;
  end;
end;
{$endregion}

end.
