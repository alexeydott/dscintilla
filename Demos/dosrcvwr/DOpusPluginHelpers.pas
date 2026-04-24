unit DOpusPluginHelpers;

interface

uses
  System.SysUtils,  Winapi.Windows,  DOpusPluginSupport;

type
  TDOpusPluginLogLevel = (dpllNone, dpllError, dpllInfo, dpllDebug);
  TDOpusPluginLogProc = procedure(ALevel: TDOpusPluginLogLevel; const AMessage: string);

procedure SetDOpusPluginLogProc(AProc: TDOpusPluginLogProc);
procedure SetDOpusPluginLogLevel(ALevel: TDOpusPluginLogLevel);
function GetDOpusPluginLogLevel: TDOpusPluginLogLevel;
function IsDOpusLogDiagnosticAvailable(AModule: HMODULE = 0): Boolean;
function TryDOpusLogDiagnostic(const ASource, AMessage: string; APlain: Boolean;
  AModule: HMODULE = 0): Boolean;

type
  TDOpusPluginHelperBase = class
  private
    FModule: HMODULE;
  protected
    function Dll: HMODULE; inline;
    procedure Log(ALevel: TDOpusPluginLogLevel; const AMessage: string);
    function ResolveProc(const AName: string): Pointer;
  public
    constructor Create(AModule: HMODULE = 0); virtual;
    function TryResolveProc(const AName: string; out AProc: Pointer): Boolean;
    property ModuleHandle: HMODULE read FModule;
  end;

  TDOpusPluginHelperConfig = class(TDOpusPluginHelperBase)
  private
    FPfnGetConfigPath: PFNGETCONFIGPATH;
    FPfnLoadOrSaveConfig: PFNLOADORSAVECONFIG;
    FPfnGetThumbnailPrefs: PFNGETTHUMBNAILPREFS;
    FPfnIsUSBInstall: PFNISUSBINSTALL;
    FPfnGetProgramDir: PFNGETPROGRAMDIR;
  public
    constructor Create(AModule: HMODULE = 0); override;
    function GetConfigPath(iPathType: Integer; pszBuf: LPWSTR; cchMax: UINT): BOOL;
    function LoadOrSaveConfig(iOperation: Integer; lpCfgData: LPDOPUSPLUGINCONFIGDATA): BOOL;
    function GetThumbnailPrefs(lpThumbData: LPDOPUSTHUMBNAILPREFSDATA): BOOL;
    function IsUSBInstall: BOOL;
    function GetProgramDir(pszBuf: LPWSTR; cchBufSize: Integer): BOOL;
  end;

  TDOpusPluginHelperFunction = class(TDOpusPluginHelperBase)
  private
    FPfnShowFunctionNewNameDlg: PFNSHOWFUNCTIONNEWNAMEDLG;
    FPfnGetWildNewName: PFNGETWILDNEWNAME;
    FPfnShowFunctionErrorDlg: PFNSHOWFUNCTIONERRORDLG;
    FPfnShowFunctionReplaceDlg: PFNSHOWFUNCTIONREPLACEDLG;
    FPfnShowFunctionInitialDeleteDlg: PFNSHOWFUNCTIONINITIALDELETEDLG;
    FPfnShowFunctionDeleteDlg: PFNSHOWFUNCTIONDELETEDLG;
    FPfnFilterFunctionFile: PFNFILTERFUNCTIONFILE;
    FPfnAddFunctionFileChange: PFNADDFUNCTIONFILECHANGE;
    FPfnUpdateFunctionProgressBar: PFNUPDATEFUNCTIONPROGRESSBAR;
    FPfnGetFunctionWindow: PFNGETFUNCTIONWINDOW;
  public
    constructor Create(AModule: HMODULE = 0); override;
    function ShowFunctionNewNameDlg(lpFuncData: Pointer; lpszOldName: LPWSTR; cchOldNameMax: Integer; lpszNewName: LPWSTR; cchNewNameMax: Integer; fMove: BOOL): Integer;
    function GetWildNewName(lpszOldPattern, lpszNewPattern, lpszFileName: LPCWSTR; lpszNewName: LPWSTR; cchNewNameMax: Integer): BOOL;
    function ShowFunctionErrorDlg(lpFuncData: Pointer; uiType: UINT; iErrorCode: Integer; uiAction: UINT; lpszName: LPCWSTR; lpszErrMsg: LPCWSTR = nil): Integer;
    function ShowFunctionReplaceDlg(lpFuncData: Pointer; pszSource: LPCWSTR; pwfdSource: PWin32FindDataW; pszDest: LPCWSTR; pwfdDest: PWin32FindDataW; pszNewName: LPWSTR; cchNewNameMax: Integer; dwFlags: DWORD): Integer;
    function ShowFunctionInitialDeleteDlg(lpFuncData: Pointer; pszFileName: LPCWSTR): Integer;
    function ShowFunctionDeleteDlg(lpFuncData: Pointer; pszFileName: LPCWSTR; fFolder: BOOL; dwFileCount, dwFileSizeHigh, dwFileSizeLow: DWORD): Integer;
    function FilterFunctionFile(lpFuncData: Pointer; lpszFile: LPCWSTR; lpWFD: PWin32FindDataW; fSubFolderFilter: BOOL): BOOL;
    procedure AddFunctionFileChange(lpFuncData: Pointer; fIsDest: BOOL; iType: Integer; lpszFile: LPCWSTR);
    procedure UpdateFunctionProgressBar(lpFuncData: Pointer; uiAction: UINT; dwData: DWORD_PTR);
    function GetFunctionWindow(lpFuncData: Pointer): HWND;
  end;

  TDOpusPluginHelperXML = class(TDOpusPluginHelperBase)
  private
    FPfnXMLLoadFile: PFNXMLLOADFILE;
    FPfnXMLSaveFile: PFNXMLSAVEFILE;
    FPfnXMLCreateFile: PFNXMLCREATEFILE;
    FPfnXMLFreeFile: PFNXMLFREEFILE;
    FPfnXMLAddChildNode: PFNXMLADDCHILDNODE;
    FPfnXMLDeleteChild: PFNXMLDELETECHILD;
    FPfnXMLDeleteAllChildNodes: PFNXMLDELETEALLCHILDNODES;
    FPfnXMLFirstChildNode: PFNXMLFIRSTCHILDNODE;
    FPfnXMLNextNode: PFNXMLNEXTNODE;
    FPfnXMLFindChildNode: PFNXMLFINDCHILDNODE;
    FPfnXMLEnumChildNodes: PFNXMLENUMCHILDNODES;
    FPfnXMLGetNodeName: PFNXMLGETNODENAME;
    FPfnXMLSetNodeName: PFNXMLSETNODENAME;
    FPfnXMLGetNodeValue: PFNXMLGETNODEVALUE;
    FPfnXMLSetNodeValue: PFNXMLSETNODEVALUE;
    FPfnXMLGetNodeBoolValue: PFNXMLGETNODEBOOLVALUE;
    FPfnXMLSetNodeBoolValue: PFNXMLSETNODEBOOLVALUE;
    FPfnXMLGetNodeIntValue: PFNXMLGETNODEINTVALUE;
    FPfnXMLSetNodeIntValue: PFNXMLSETNODEINTVALUE;
    FPfnXMLGetNodeDWORDValue: PFNXMLGETNODEDWORDVALUE;
    FPfnXMLSetNodeDWORDValue: PFNXMLSETNODEDWORDVALUE;
    FPfnXMLGetNodeDWORDLongValue: PFNXMLGETNODEDWORDLONGVALUE;
    FPfnXMLSetNodeDWORDLongValue: PFNXMLSETNODEDWORDLONGVALUE;
    FPfnXMLGetNodeLogFontValue: PFNXMLGETNODELOGFONTVALUE;
    FPfnXMLSetNodeLogFontValue: PFNXMLSETNODELOGFONTVALUE;
    FPfnXMLGetNodeBinaryValue: PFNXMLGETNODEBINARYVALUE;
    FPfnXMLSetNodeBinaryValue: PFNXMLSETNODEBINARYVALUE;
    FPfnXMLGetNodeAttribute: PFNXMLGETNODEATTRIBUTE;
    FPfnXMLSetNodeAttribute: PFNXMLSETNODEATTRIBUTE;
    FPfnXMLGetNodeBoolAttribute: PFNXMLGETNODEBOOLATTRIBUTE;
    FPfnXMLSetNodeBoolAttribute: PFNXMLSETNODEBOOLATTRIBUTE;
    FPfnXMLGetNodeIntAttribute: PFNXMLGETNODEINTATTRIBUTE;
    FPfnXMLSetNodeIntAttribute: PFNXMLSETNODEINTATTRIBUTE;
    FPfnXMLGetNodeDWORDAttribute: PFNXMLGETNODEDWORDATTRIBUTE;
    FPfnXMLSetNodeDWORDAttribute: PFNXMLSETNODEDWORDATTRIBUTE;
    FPfnXMLGetNodeDWORDLongAttribute: PFNXMLGETNODEDWORDLONGATTRIBUTE;
    FPfnXMLSetNodeDWORDLongAttribute: PFNXMLSETNODEDWORDLONGATTRIBUTE;
    FPfnXMLDeleteNodeAttribute: PFNXMLDELETENODEATTRIBUTE;
    FPfnXMLDeleteAllNodeAttributes: PFNXMLDELETEALLNODEATTRIBUTES;
  public
    constructor Create(AModule: HMODULE = 0); override;
    function XMLLoadFile(pszFile: LPCWSTR): THandle;
    function XMLSaveFile(hXML: THandle; pszFile: LPCWSTR): BOOL;
    function XMLCreateFile: THandle;
    procedure XMLFreeFile(hXML: THandle);
    function XMLAddChildNode(hXML: THandle; pszName: LPCWSTR): THandle;
    function XMLDeleteChild(hXML, hChild: THandle): BOOL;
    function XMLDeleteAllChildNodes(hXML: THandle): BOOL;
    function XMLFirstChildNode(hXML: THandle): THandle;
    function XMLNextNode(hXML: THandle): THandle;
    function XMLFindChildNode(hXML: THandle; pszName: LPCWSTR): THandle;
    function XMLEnumChildNodes(hXML: THandle; pszName: LPCWSTR; hPrev: THandle): THandle;
    function XMLGetNodeName(hXML: THandle; pszName: LPWSTR; pcchMax: PInteger): BOOL;
    function XMLSetNodeName(hXML: THandle; pszName: LPCWSTR): BOOL;
    function XMLGetNodeValue(hXML: THandle; pszValue: LPWSTR; pcchMax: PInteger): BOOL;
    function XMLSetNodeValue(hXML: THandle; pszValue: LPCWSTR): BOOL;
    function XMLGetNodeBoolValue(hXML: THandle; pfValue: PBOOL): BOOL;
    function XMLSetNodeBoolValue(hXML: THandle; fValue: BOOL): BOOL;
    function XMLGetNodeIntValue(hXML: THandle; piValue: PInteger): BOOL;
    function XMLSetNodeIntValue(hXML: THandle; iValue: Integer): BOOL;
    function XMLGetNodeDWORDValue(hXML: THandle; pdwValue: PDWORD): BOOL;
    function XMLSetNodeDWORDValue(hXML: THandle; dwValue: DWORD): BOOL;
    function XMLGetNodeDWORDLongValue(hXML: THandle; pdwlValue: PDWORDLONG): BOOL;
    function XMLSetNodeDWORDLongValue(hXML: THandle; dwlValue: DWORDLONG): BOOL;
    function XMLGetNodeLogFontValue(hXML: THandle; plfValue: PLogFontW): BOOL;
    function XMLSetNodeLogFontValue(hXML: THandle; plfValue: PLogFontW): BOOL;
    function XMLGetNodeBinaryValue(hXML: THandle; pValue: Pointer; pdwSize: PDWORD): BOOL;
    function XMLSetNodeBinaryValue(hXML: THandle; pValue: Pointer; dwSize: DWORD): BOOL;
    function XMLGetNodeAttribute(hXML: THandle; pszAttrName: LPCWSTR; pszAttrValue: LPWSTR; pcchMax: PInteger): BOOL;
    function XMLSetNodeAttribute(hXML: THandle; pszAttrName, pszAttrValue: LPCWSTR): BOOL;
    function XMLGetNodeBoolAttribute(hXML: THandle; pszAttrName: LPCWSTR; pfAttrValue: PBOOL): BOOL;
    function XMLSetNodeBoolAttribute(hXML: THandle; pszAttrName: LPCWSTR; fAttrValue: BOOL): BOOL;
    function XMLGetNodeIntAttribute(hXML: THandle; pszAttrName: LPCWSTR; piAttrValue: PInteger): BOOL;
    function XMLSetNodeIntAttribute(hXML: THandle; pszAttrName: LPCWSTR; iAttrValue: Integer): BOOL;
    function XMLGetNodeDWORDAttribute(hXML: THandle; pszAttrName: LPCWSTR; pdwAttrValue: PDWORD): BOOL;
    function XMLSetNodeDWORDAttribute(hXML: THandle; pszAttrName: LPCWSTR; dwAttrValue: DWORD): BOOL;
    function XMLGetNodeDWORDLongAttribute(hXML: THandle; pszAttrName: LPCWSTR; pdwlAttrValue: PDWORDLONG): BOOL;
    function XMLSetNodeDWORDLongAttribute(hXML: THandle; pszAttrName: LPCWSTR; dwlAttrValue: DWORDLONG): BOOL;
    function XMLDeleteNodeAttribute(hXML: THandle; pszAttrName: LPCWSTR): BOOL;
    function XMLDeleteAllNodeAttributes(hXML: THandle): BOOL;
  end;

  TDOpusPluginHelperRegistry = class(TDOpusPluginHelperBase)
  private
    FPfnOpusRegOpenKeyW: PFNOPUSREGOPENKEYW;
    FPfnOpusRegCreateKeyW: PFNOPUSREGCREATEKEYW;
    FPfnOpusRegQueryValueW: PFNOPUSREGQUERYVALUEW;
    FPfnOpusRegCloseKey: PFNOPUSREGCLOSEKEY;
    FPfnOpusRegDeleteKeyW: PFNOPUSREGDELETEKEYW;
    FPfnOpusRegDeleteValueW: PFNOPUSREGDELETEVALUEW;
    FPfnOpusRegSetValueW: PFNOPUSREGSETVALUEW;
    FPfnOpusRegCheckElevation: PFNOPUSREGCHECKELEVATION;
  public
    constructor Create(AModule: HMODULE = 0); override;
    function OpusRegOpenKeyW(hKey: OPUSREGKEY; lpSubKey: LPCWSTR; samDesired: REGSAM; phkResult: POPUSREGKEY): Longint;
    function OpusRegCreateKeyW(hKey: OPUSREGKEY; lpSubKey: LPCWSTR; samDesired: REGSAM; phkResult: POPUSREGKEY): Longint;
    function OpusRegQueryValueW(hKey: OPUSREGKEY; lpValueName: LPCWSTR; lpType: PDWORD; lpData: LPBYTE; lpcbData: PDWORD): Longint;
    function OpusRegCloseKey(hKey: OPUSREGKEY): Longint;
    function OpusRegDeleteKeyW(hKey: OPUSREGKEY; lpSubKey: LPCWSTR): Longint;
    function OpusRegDeleteValueW(hKey: OPUSREGKEY; lpValueName: LPCWSTR): Longint;
    function OpusRegSetValueW(hKey: OPUSREGKEY; lpValueName: LPCWSTR; dwType: DWORD; lpData: LPCBYTE; cbData: DWORD): Longint;
    function OpusRegCheckElevation(hKey: OPUSREGKEY; hWnd: HWND): Longint;
  end;

  TDOpusPluginHelperUtil = class(TDOpusPluginHelperBase)
  private
    FPfnDOpusChooseFont: PFNDOPUSCHOOSEFONT;
    FPfnShowRequestDlg: PFNSHOWREQUESTDLG;
    FPfnDrawPictureFrameInDIB: PFNDRAWPICTUREFRAMEINDIB;
    FPfnCalcCRC32: PFNCALCCRC32;
    FPfnLogDiagnostic: PFNLOGDIAGNOSTIC;
    FHasLogDiagnostic: Boolean;
  public
    constructor Create(AModule: HMODULE = 0); override;
    function DOpusChooseFont(hWnd: HWND; lpChoose: LPDOPUSCHOOSEFONT): BOOL;
    function ShowRequestDlg(lpDlgData: LPSHOWREQUESTDLGDATA): Integer;
    function DrawPictureFrameInDIB(pBMI: PBitmapInfo; pBits: Pointer; prc: PRect; iFrameSize: Integer = 0; iShadowSize: Integer = 0): BOOL;
    function CalcCRC32(dwCRCIn: DWORD; pData: LPCBYTE; dwSize: DWORD): DWORD;
    // Reverse-engineered helper export from dopus.exe; not part of the official SDK docs.
    procedure LogDiagnostic(pszSource, pszMessage: LPCWSTR; fPlain: BOOL);
    property HasLogDiagnostic: Boolean read FHasLogDiagnostic;
  end;

  TDOpusPluginHelperWow64 = class(TDOpusPluginHelperBase)
  private
    FPfnDisableWow64Redirection: PFNDISABLEWOW64REDIRECTION;
    FPfnRevertWow64Redirection: PFNREVERTWOW64REDIRECTION;
  public
    constructor Create(AModule: HMODULE = 0); override;
    function DisableWow64Redirection: THandle;
    procedure RevertWow64Redirection(hHandle: THandle);
  end;

  TDOpusPluginHelper = class
  private
    FConfig: TDOpusPluginHelperConfig;
    FFunctionHelper: TDOpusPluginHelperFunction;
    FXML: TDOpusPluginHelperXML;
    FRegistry: TDOpusPluginHelperRegistry;
    FUtil: TDOpusPluginHelperUtil;
    FWow64: TDOpusPluginHelperWow64;
  public
    constructor Create(AModule: HMODULE = 0);
    destructor Destroy; override;
    property Config: TDOpusPluginHelperConfig read FConfig;
    property FunctionHelper: TDOpusPluginHelperFunction read FFunctionHelper;
    property XML: TDOpusPluginHelperXML read FXML;
    property Registry: TDOpusPluginHelperRegistry read FRegistry;
    property Util: TDOpusPluginHelperUtil read FUtil;
    property Wow64: TDOpusPluginHelperWow64 read FWow64;
  end;

  TDOpusPluginAutoWow64Helper = class(TDOpusPluginHelperWow64)
  private
    FHandle: THandle;
  public
    constructor Create(AModule: HMODULE = 0); override;
    destructor Destroy; override;
    property Handle: THandle read FHandle;
  end;

implementation

var
  GDOpusPluginLogLevel: TDOpusPluginLogLevel = dpllError;
  GDOpusPluginLogProc: TDOpusPluginLogProc;

function ResolveLogDiagnosticProc(AModule: HMODULE): PFNLOGDIAGNOSTIC;
var
  LModule: HMODULE;
  LAnsiName: AnsiString;
begin
  if AModule <> 0 then
    LModule := AModule
  else
    LModule := GetModuleHandle('dopus.exe');

  if LModule = 0 then
    Exit(nil);

  LAnsiName := AnsiString(FUNCNAME_LOGDIAGNOSTIC);
  Result := PFNLOGDIAGNOSTIC(GetProcAddress(LModule, PAnsiChar(LAnsiName)));
end;

function ToOptionalWideChar(const AValue: string): LPCWSTR;
begin
  if AValue = '' then
    Result := nil
  else
    Result := PWideChar(AValue);
end;

procedure EmitLog(ALevel: TDOpusPluginLogLevel; const AMessage: string);
const
  LEVEL_NAMES: array[TDOpusPluginLogLevel] of string = ('NONE', 'ERROR', 'INFO', 'DEBUG');
var
  LLine: string;
begin
  if (ALevel > GDOpusPluginLogLevel) or (ALevel = dpllNone) then
    Exit;

  LLine := Format('[DOpusPluginHelpers][%s] %s', [LEVEL_NAMES[ALevel], AMessage]);
  OutputDebugString(PChar(LLine));
  if Assigned(GDOpusPluginLogProc) then
    GDOpusPluginLogProc(ALevel, AMessage);
end;

procedure SetDOpusPluginLogProc(AProc: TDOpusPluginLogProc);
begin
  GDOpusPluginLogProc := AProc;
end;

procedure SetDOpusPluginLogLevel(ALevel: TDOpusPluginLogLevel);
begin
  GDOpusPluginLogLevel := ALevel;
end;

function GetDOpusPluginLogLevel: TDOpusPluginLogLevel;
begin
  Result := GDOpusPluginLogLevel;
end;

function IsDOpusLogDiagnosticAvailable(AModule: HMODULE): Boolean;
begin
  Result := Assigned(ResolveLogDiagnosticProc(AModule));
end;

function TryDOpusLogDiagnostic(const ASource, AMessage: string; APlain: Boolean;
  AModule: HMODULE): Boolean;
var
  LProc: PFNLOGDIAGNOSTIC;
begin
  LProc := ResolveLogDiagnosticProc(AModule);
  Result := Assigned(LProc);
  if Result then
    LProc(ToOptionalWideChar(ASource), ToOptionalWideChar(AMessage), BOOL(APlain));
end;

constructor TDOpusPluginHelperBase.Create(AModule: HMODULE);
begin
  inherited Create;
  if AModule <> 0 then
    FModule := AModule
  else
    FModule := GetModuleHandle('dopus.exe');
  Log(dpllDebug, Format('%s initialized, module=0x%x', [ClassName, NativeUInt(FModule)]));
end;

function TDOpusPluginHelperBase.Dll: HMODULE;
begin
  Result := FModule;
end;

procedure TDOpusPluginHelperBase.Log(ALevel: TDOpusPluginLogLevel; const AMessage: string);
begin
  EmitLog(ALevel, AMessage);
end;

function TDOpusPluginHelperBase.ResolveProc(const AName: string): Pointer;
var
  LAnsiName: AnsiString;
begin
  if FModule = 0 then
  begin
    Log(dpllError, Format('ResolveProc(%s) failed: dopus.exe is not loaded', [AName]));
    Exit(nil);
  end;

  LAnsiName := AnsiString(AName);
  Result := GetProcAddress(FModule, PAnsiChar(LAnsiName));
  if not Assigned(Result) then
    Log(dpllError, Format('ResolveProc(%s) failed for module 0x%x', [AName, NativeUInt(FModule)]));
end;

function TDOpusPluginHelperBase.TryResolveProc(const AName: string; out AProc: Pointer): Boolean;
begin
  AProc := ResolveProc(AName);
  Result := Assigned(AProc);
end;

constructor TDOpusPluginHelperConfig.Create(AModule: HMODULE);
begin
  inherited Create(AModule);
  FPfnGetConfigPath := PFNGETCONFIGPATH(ResolveProc(FUNCNAME_GETCONFIGPATH));
  FPfnLoadOrSaveConfig := PFNLOADORSAVECONFIG(ResolveProc(FUNCNAME_LOADORSAVECONFIG));
  FPfnGetThumbnailPrefs := PFNGETTHUMBNAILPREFS(ResolveProc(FUNCNAME_GETTHUMBNAILPREFS));
  FPfnIsUSBInstall := PFNISUSBINSTALL(ResolveProc(FUNCNAME_ISUSBINSTALL));
  FPfnGetProgramDir := PFNGETPROGRAMDIR(ResolveProc(FUNCNAME_GETPROGRAMDIR));
end;

function TDOpusPluginHelperConfig.GetConfigPath(iPathType: Integer; pszBuf: LPWSTR; cchMax: UINT): BOOL;
begin
  if Assigned(FPfnGetConfigPath) then
    Result := FPfnGetConfigPath(iPathType, pszBuf, cchMax)
  else
    Result := False;
end;

function TDOpusPluginHelperConfig.LoadOrSaveConfig(iOperation: Integer; lpCfgData: LPDOPUSPLUGINCONFIGDATA): BOOL;
begin
  if Assigned(FPfnLoadOrSaveConfig) then
    Result := FPfnLoadOrSaveConfig(iOperation, lpCfgData)
  else
    Result := False;
end;

function TDOpusPluginHelperConfig.GetThumbnailPrefs(lpThumbData: LPDOPUSTHUMBNAILPREFSDATA): BOOL;
begin
  if Assigned(FPfnGetThumbnailPrefs) then
    Result := FPfnGetThumbnailPrefs(lpThumbData)
  else
    Result := False;
end;

function TDOpusPluginHelperConfig.IsUSBInstall: BOOL;
begin
  if Assigned(FPfnIsUSBInstall) then
    Result := FPfnIsUSBInstall()
  else
    Result := False;
end;

function TDOpusPluginHelperConfig.GetProgramDir(pszBuf: LPWSTR; cchBufSize: Integer): BOOL;
begin
  if Assigned(FPfnGetProgramDir) then
    Result := FPfnGetProgramDir(pszBuf, cchBufSize)
  else
    Result := False;
end;

constructor TDOpusPluginHelperFunction.Create(AModule: HMODULE);
begin
  inherited Create(AModule);
  FPfnShowFunctionNewNameDlg := PFNSHOWFUNCTIONNEWNAMEDLG(ResolveProc(FUNCNAME_SHOWFUNCTIONNEWNAMEDLG));
  FPfnGetWildNewName := PFNGETWILDNEWNAME(ResolveProc(FUNCNAME_GETWILDNEWNAME));
  FPfnShowFunctionErrorDlg := PFNSHOWFUNCTIONERRORDLG(ResolveProc(FUNCNAME_SHOWFUNCTIONERRORDLG));
  FPfnShowFunctionReplaceDlg := PFNSHOWFUNCTIONREPLACEDLG(ResolveProc(FUNCNAME_SHOWFUNCTIONREPLACEDLG));
  FPfnShowFunctionInitialDeleteDlg := PFNSHOWFUNCTIONINITIALDELETEDLG(ResolveProc(FUNCNAME_SHOWFUNCTIONINITIALDELETEDLG));
  FPfnShowFunctionDeleteDlg := PFNSHOWFUNCTIONDELETEDLG(ResolveProc(FUNCNAME_SHOWFUNCTIONDELETEDLG));
  FPfnFilterFunctionFile := PFNFILTERFUNCTIONFILE(ResolveProc(FUNCNAME_FILTERFUNCTIONFILE));
  FPfnAddFunctionFileChange := PFNADDFUNCTIONFILECHANGE(ResolveProc(FUNCNAME_ADDFUNCTIONFILECHANGE));
  FPfnUpdateFunctionProgressBar := PFNUPDATEFUNCTIONPROGRESSBAR(ResolveProc(FUNCNAME_UPDATEFUNCTIONPROGRESSBAR));
  FPfnGetFunctionWindow := PFNGETFUNCTIONWINDOW(ResolveProc(FUNCNAME_GETFUNCTIONWINDOW));
end;

function TDOpusPluginHelperFunction.ShowFunctionNewNameDlg(lpFuncData: Pointer; lpszOldName: LPWSTR; cchOldNameMax: Integer; lpszNewName: LPWSTR; cchNewNameMax: Integer; fMove: BOOL): Integer;
begin
  if Assigned(FPfnShowFunctionNewNameDlg) then
    Result := FPfnShowFunctionNewNameDlg(lpFuncData, lpszOldName, cchOldNameMax, lpszNewName, cchNewNameMax, fMove)
  else
    Result := 0;
end;

function TDOpusPluginHelperFunction.GetWildNewName(lpszOldPattern, lpszNewPattern, lpszFileName: LPCWSTR; lpszNewName: LPWSTR; cchNewNameMax: Integer): BOOL;
begin
  if Assigned(FPfnGetWildNewName) then
    Result := FPfnGetWildNewName(lpszOldPattern, lpszNewPattern, lpszFileName, lpszNewName, cchNewNameMax)
  else
    Result := False;
end;

function TDOpusPluginHelperFunction.ShowFunctionErrorDlg(lpFuncData: Pointer; uiType: UINT; iErrorCode: Integer; uiAction: UINT; lpszName: LPCWSTR; lpszErrMsg: LPCWSTR): Integer;
begin
  if Assigned(FPfnShowFunctionErrorDlg) then
    Result := FPfnShowFunctionErrorDlg(lpFuncData, uiType, iErrorCode, uiAction, lpszName, lpszErrMsg)
  else
    Result := 0;
end;

function TDOpusPluginHelperFunction.ShowFunctionReplaceDlg(lpFuncData: Pointer; pszSource: LPCWSTR; pwfdSource: PWin32FindDataW; pszDest: LPCWSTR; pwfdDest: PWin32FindDataW; pszNewName: LPWSTR; cchNewNameMax: Integer; dwFlags: DWORD): Integer;
begin
  if Assigned(FPfnShowFunctionReplaceDlg) then
    Result := FPfnShowFunctionReplaceDlg(lpFuncData, pszSource, pwfdSource, pszDest, pwfdDest, pszNewName, cchNewNameMax, dwFlags)
  else
    Result := 0;
end;

function TDOpusPluginHelperFunction.ShowFunctionInitialDeleteDlg(lpFuncData: Pointer; pszFileName: LPCWSTR): Integer;
begin
  if Assigned(FPfnShowFunctionInitialDeleteDlg) then
    Result := FPfnShowFunctionInitialDeleteDlg(lpFuncData, pszFileName)
  else
    Result := 0;
end;

function TDOpusPluginHelperFunction.ShowFunctionDeleteDlg(lpFuncData: Pointer; pszFileName: LPCWSTR; fFolder: BOOL; dwFileCount, dwFileSizeHigh, dwFileSizeLow: DWORD): Integer;
begin
  if Assigned(FPfnShowFunctionDeleteDlg) then
    Result := FPfnShowFunctionDeleteDlg(lpFuncData, pszFileName, fFolder, dwFileCount, dwFileSizeHigh, dwFileSizeLow)
  else
    Result := 0;
end;

function TDOpusPluginHelperFunction.FilterFunctionFile(lpFuncData: Pointer; lpszFile: LPCWSTR; lpWFD: PWin32FindDataW; fSubFolderFilter: BOOL): BOOL;
begin
  if Assigned(FPfnFilterFunctionFile) then
    Result := FPfnFilterFunctionFile(lpFuncData, lpszFile, lpWFD, fSubFolderFilter)
  else
    Result := False;
end;

procedure TDOpusPluginHelperFunction.AddFunctionFileChange(lpFuncData: Pointer; fIsDest: BOOL; iType: Integer; lpszFile: LPCWSTR);
begin
  if Assigned(FPfnAddFunctionFileChange) then
    FPfnAddFunctionFileChange(lpFuncData, fIsDest, iType, lpszFile);
end;

procedure TDOpusPluginHelperFunction.UpdateFunctionProgressBar(lpFuncData: Pointer; uiAction: UINT; dwData: DWORD_PTR);
begin
  if Assigned(FPfnUpdateFunctionProgressBar) then
    FPfnUpdateFunctionProgressBar(lpFuncData, uiAction, dwData);
end;

function TDOpusPluginHelperFunction.GetFunctionWindow(lpFuncData: Pointer): HWND;
begin
  if Assigned(FPfnGetFunctionWindow) then
    Result := FPfnGetFunctionWindow(lpFuncData)
  else
    Result := 0;
end;

constructor TDOpusPluginHelperXML.Create(AModule: HMODULE);
begin
  inherited Create(AModule);
  FPfnXMLLoadFile := PFNXMLLOADFILE(ResolveProc(FUNCNAME_XMLLOADFILE));
  FPfnXMLSaveFile := PFNXMLSAVEFILE(ResolveProc(FUNCNAME_XMLSAVEFILE));
  FPfnXMLCreateFile := PFNXMLCREATEFILE(ResolveProc(FUNCNAME_XMLCREATEFILE));
  FPfnXMLFreeFile := PFNXMLFREEFILE(ResolveProc(FUNCNAME_XMLFREEFILE));
  FPfnXMLAddChildNode := PFNXMLADDCHILDNODE(ResolveProc(FUNCNAME_XMLADDCHILDNODE));
  FPfnXMLDeleteChild := PFNXMLDELETECHILD(ResolveProc(FUNCNAME_XMLDELETECHILD));
  FPfnXMLDeleteAllChildNodes := PFNXMLDELETEALLCHILDNODES(ResolveProc(FUNCNAME_XMLDELETEALLCHILDNODES));
  FPfnXMLFirstChildNode := PFNXMLFIRSTCHILDNODE(ResolveProc(FUNCNAME_XMLFIRSTCHILDNODE));
  FPfnXMLNextNode := PFNXMLNEXTNODE(ResolveProc(FUNCNAME_XMLNEXTNODE));
  FPfnXMLFindChildNode := PFNXMLFINDCHILDNODE(ResolveProc(FUNCNAME_XMLFINDCHILDNODE));
  FPfnXMLEnumChildNodes := PFNXMLENUMCHILDNODES(ResolveProc(FUNCNAME_XMLENUMCHILDNODES));
  FPfnXMLGetNodeName := PFNXMLGETNODENAME(ResolveProc(FUNCNAME_XMLGETNODENAME));
  FPfnXMLSetNodeName := PFNXMLSETNODENAME(ResolveProc(FUNCNAME_XMLSETNODENAME));
  FPfnXMLGetNodeValue := PFNXMLGETNODEVALUE(ResolveProc(FUNCNAME_XMLGETNODEVALUE));
  FPfnXMLSetNodeValue := PFNXMLSETNODEVALUE(ResolveProc(FUNCNAME_XMLSETNODEVALUE));
  FPfnXMLGetNodeBoolValue := PFNXMLGETNODEBOOLVALUE(ResolveProc(FUNCNAME_XMLGETNODEBOOLVALUE));
  FPfnXMLSetNodeBoolValue := PFNXMLSETNODEBOOLVALUE(ResolveProc(FUNCNAME_XMLSETNODEBOOLVALUE));
  FPfnXMLGetNodeIntValue := PFNXMLGETNODEINTVALUE(ResolveProc(FUNCNAME_XMLGETNODEINTVALUE));
  FPfnXMLSetNodeIntValue := PFNXMLSETNODEINTVALUE(ResolveProc(FUNCNAME_XMLSETNODEINTVALUE));
  FPfnXMLGetNodeDWORDValue := PFNXMLGETNODEDWORDVALUE(ResolveProc(FUNCNAME_XMLGETNODEDWORDVALUE));
  FPfnXMLSetNodeDWORDValue := PFNXMLSETNODEDWORDVALUE(ResolveProc(FUNCNAME_XMLSETNODEDWORDVALUE));
  FPfnXMLGetNodeDWORDLongValue := PFNXMLGETNODEDWORDLONGVALUE(ResolveProc(FUNCNAME_XMLGETNODEDWORDLONGVALUE));
  FPfnXMLSetNodeDWORDLongValue := PFNXMLSETNODEDWORDLONGVALUE(ResolveProc(FUNCNAME_XMLSETNODEDWORDLONGVALUE));
  FPfnXMLGetNodeLogFontValue := PFNXMLGETNODELOGFONTVALUE(ResolveProc(FUNCNAME_XMLGETNODELOGFONTVALUE));
  FPfnXMLSetNodeLogFontValue := PFNXMLSETNODELOGFONTVALUE(ResolveProc(FUNCNAME_XMLSETNODELOGFONTVALUE));
  FPfnXMLGetNodeBinaryValue := PFNXMLGETNODEBINARYVALUE(ResolveProc(FUNCNAME_XMLGETNODEBINARYVALUE));
  FPfnXMLSetNodeBinaryValue := PFNXMLSETNODEBINARYVALUE(ResolveProc(FUNCNAME_XMLSETNODEBINARYVALUE));
  FPfnXMLGetNodeAttribute := PFNXMLGETNODEATTRIBUTE(ResolveProc(FUNCNAME_XMLGETNODEATTRIBUTE));
  FPfnXMLSetNodeAttribute := PFNXMLSETNODEATTRIBUTE(ResolveProc(FUNCNAME_XMLSETNODEATTRIBUTE));
  FPfnXMLGetNodeBoolAttribute := PFNXMLGETNODEBOOLATTRIBUTE(ResolveProc(FUNCNAME_XMLGETNODEBOOLATTRIBUTE));
  FPfnXMLSetNodeBoolAttribute := PFNXMLSETNODEBOOLATTRIBUTE(ResolveProc(FUNCNAME_XMLSETNODEBOOLATTRIBUTE));
  FPfnXMLGetNodeIntAttribute := PFNXMLGETNODEINTATTRIBUTE(ResolveProc(FUNCNAME_XMLGETNODEINTATTRIBUTE));
  FPfnXMLSetNodeIntAttribute := PFNXMLSETNODEINTATTRIBUTE(ResolveProc(FUNCNAME_XMLSETNODEINTATTRIBUTE));
  FPfnXMLGetNodeDWORDAttribute := PFNXMLGETNODEDWORDATTRIBUTE(ResolveProc(FUNCNAME_XMLGETNODEDWORDATTRIBUTE));
  FPfnXMLSetNodeDWORDAttribute := PFNXMLSETNODEDWORDATTRIBUTE(ResolveProc(FUNCNAME_XMLSETNODEDWORDATTRIBUTE));
  FPfnXMLGetNodeDWORDLongAttribute := PFNXMLGETNODEDWORDLONGATTRIBUTE(ResolveProc(FUNCNAME_XMLGETNODEDWORDLONGATTRIBUTE));
  FPfnXMLSetNodeDWORDLongAttribute := PFNXMLSETNODEDWORDLONGATTRIBUTE(ResolveProc(FUNCNAME_XMLSETNODEDWORDLONGATTRIBUTE));
  FPfnXMLDeleteNodeAttribute := PFNXMLDELETENODEATTRIBUTE(ResolveProc(FUNCNAME_XMLDELETENODEATTRIBUTE));
  FPfnXMLDeleteAllNodeAttributes := PFNXMLDELETEALLNODEATTRIBUTES(ResolveProc(FUNCNAME_XMLDELETEALLNODEATTRIBUTES));
end;

function TDOpusPluginHelperXML.XMLLoadFile(pszFile: LPCWSTR): THandle;
begin
  if Assigned(FPfnXMLLoadFile) then Result := FPfnXMLLoadFile(pszFile) else Result := 0;
end;

function TDOpusPluginHelperXML.XMLSaveFile(hXML: THandle; pszFile: LPCWSTR): BOOL;
begin
  if Assigned(FPfnXMLSaveFile) then Result := FPfnXMLSaveFile(hXML, pszFile) else Result := False;
end;

function TDOpusPluginHelperXML.XMLCreateFile: THandle;
begin
  if Assigned(FPfnXMLCreateFile) then Result := FPfnXMLCreateFile() else Result := 0;
end;

procedure TDOpusPluginHelperXML.XMLFreeFile(hXML: THandle);
begin
  if Assigned(FPfnXMLFreeFile) then FPfnXMLFreeFile(hXML);
end;

function TDOpusPluginHelperXML.XMLAddChildNode(hXML: THandle; pszName: LPCWSTR): THandle;
begin
  if Assigned(FPfnXMLAddChildNode) then Result := FPfnXMLAddChildNode(hXML, pszName) else Result := 0;
end;

function TDOpusPluginHelperXML.XMLDeleteChild(hXML, hChild: THandle): BOOL;
begin
  if Assigned(FPfnXMLDeleteChild) then Result := FPfnXMLDeleteChild(hXML, hChild) else Result := False;
end;

function TDOpusPluginHelperXML.XMLDeleteAllChildNodes(hXML: THandle): BOOL;
begin
  if Assigned(FPfnXMLDeleteAllChildNodes) then Result := FPfnXMLDeleteAllChildNodes(hXML) else Result := False;
end;

function TDOpusPluginHelperXML.XMLFirstChildNode(hXML: THandle): THandle;
begin
  if Assigned(FPfnXMLFirstChildNode) then Result := FPfnXMLFirstChildNode(hXML) else Result := 0;
end;

function TDOpusPluginHelperXML.XMLNextNode(hXML: THandle): THandle;
begin
  if Assigned(FPfnXMLNextNode) then Result := FPfnXMLNextNode(hXML) else Result := 0;
end;

function TDOpusPluginHelperXML.XMLFindChildNode(hXML: THandle; pszName: LPCWSTR): THandle;
begin
  if Assigned(FPfnXMLFindChildNode) then Result := FPfnXMLFindChildNode(hXML, pszName) else Result := 0;
end;

function TDOpusPluginHelperXML.XMLEnumChildNodes(hXML: THandle; pszName: LPCWSTR; hPrev: THandle): THandle;
begin
  if Assigned(FPfnXMLEnumChildNodes) then Result := FPfnXMLEnumChildNodes(hXML, pszName, hPrev) else Result := 0;
end;

function TDOpusPluginHelperXML.XMLGetNodeName(hXML: THandle; pszName: LPWSTR; pcchMax: PInteger): BOOL;
begin
  if Assigned(FPfnXMLGetNodeName) then Result := FPfnXMLGetNodeName(hXML, pszName, pcchMax) else Result := False;
end;

function TDOpusPluginHelperXML.XMLSetNodeName(hXML: THandle; pszName: LPCWSTR): BOOL;
begin
  if Assigned(FPfnXMLSetNodeName) then Result := FPfnXMLSetNodeName(hXML, pszName) else Result := False;
end;

function TDOpusPluginHelperXML.XMLGetNodeValue(hXML: THandle; pszValue: LPWSTR; pcchMax: PInteger): BOOL;
begin
  if Assigned(FPfnXMLGetNodeValue) then Result := FPfnXMLGetNodeValue(hXML, pszValue, pcchMax) else Result := False;
end;

function TDOpusPluginHelperXML.XMLSetNodeValue(hXML: THandle; pszValue: LPCWSTR): BOOL;
begin
  if Assigned(FPfnXMLSetNodeValue) then Result := FPfnXMLSetNodeValue(hXML, pszValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLGetNodeBoolValue(hXML: THandle; pfValue: PBOOL): BOOL;
begin
  if Assigned(FPfnXMLGetNodeBoolValue) then Result := FPfnXMLGetNodeBoolValue(hXML, pfValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLSetNodeBoolValue(hXML: THandle; fValue: BOOL): BOOL;
begin
  if Assigned(FPfnXMLSetNodeBoolValue) then Result := FPfnXMLSetNodeBoolValue(hXML, fValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLGetNodeIntValue(hXML: THandle; piValue: PInteger): BOOL;
begin
  if Assigned(FPfnXMLGetNodeIntValue) then Result := FPfnXMLGetNodeIntValue(hXML, piValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLSetNodeIntValue(hXML: THandle; iValue: Integer): BOOL;
begin
  if Assigned(FPfnXMLSetNodeIntValue) then Result := FPfnXMLSetNodeIntValue(hXML, iValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLGetNodeDWORDValue(hXML: THandle; pdwValue: PDWORD): BOOL;
begin
  if Assigned(FPfnXMLGetNodeDWORDValue) then Result := FPfnXMLGetNodeDWORDValue(hXML, pdwValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLSetNodeDWORDValue(hXML: THandle; dwValue: DWORD): BOOL;
begin
  if Assigned(FPfnXMLSetNodeDWORDValue) then Result := FPfnXMLSetNodeDWORDValue(hXML, dwValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLGetNodeDWORDLongValue(hXML: THandle; pdwlValue: PDWORDLONG): BOOL;
begin
  if Assigned(FPfnXMLGetNodeDWORDLongValue) then Result := FPfnXMLGetNodeDWORDLongValue(hXML, pdwlValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLSetNodeDWORDLongValue(hXML: THandle; dwlValue: DWORDLONG): BOOL;
begin
  if Assigned(FPfnXMLSetNodeDWORDLongValue) then Result := FPfnXMLSetNodeDWORDLongValue(hXML, dwlValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLGetNodeLogFontValue(hXML: THandle; plfValue: PLogFontW): BOOL;
begin
  if Assigned(FPfnXMLGetNodeLogFontValue) then Result := FPfnXMLGetNodeLogFontValue(hXML, plfValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLSetNodeLogFontValue(hXML: THandle; plfValue: PLogFontW): BOOL;
begin
  if Assigned(FPfnXMLSetNodeLogFontValue) then Result := FPfnXMLSetNodeLogFontValue(hXML, plfValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLGetNodeBinaryValue(hXML: THandle; pValue: Pointer; pdwSize: PDWORD): BOOL;
begin
  if Assigned(FPfnXMLGetNodeBinaryValue) then Result := FPfnXMLGetNodeBinaryValue(hXML, pValue, pdwSize) else Result := False;
end;

function TDOpusPluginHelperXML.XMLSetNodeBinaryValue(hXML: THandle; pValue: Pointer; dwSize: DWORD): BOOL;
begin
  if Assigned(FPfnXMLSetNodeBinaryValue) then Result := FPfnXMLSetNodeBinaryValue(hXML, pValue, dwSize) else Result := False;
end;

function TDOpusPluginHelperXML.XMLGetNodeAttribute(hXML: THandle; pszAttrName: LPCWSTR; pszAttrValue: LPWSTR; pcchMax: PInteger): BOOL;
begin
  if Assigned(FPfnXMLGetNodeAttribute) then Result := FPfnXMLGetNodeAttribute(hXML, pszAttrName, pszAttrValue, pcchMax) else Result := False;
end;

function TDOpusPluginHelperXML.XMLSetNodeAttribute(hXML: THandle; pszAttrName, pszAttrValue: LPCWSTR): BOOL;
begin
  if Assigned(FPfnXMLSetNodeAttribute) then Result := FPfnXMLSetNodeAttribute(hXML, pszAttrName, pszAttrValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLGetNodeBoolAttribute(hXML: THandle; pszAttrName: LPCWSTR; pfAttrValue: PBOOL): BOOL;
begin
  if Assigned(FPfnXMLGetNodeBoolAttribute) then Result := FPfnXMLGetNodeBoolAttribute(hXML, pszAttrName, pfAttrValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLSetNodeBoolAttribute(hXML: THandle; pszAttrName: LPCWSTR; fAttrValue: BOOL): BOOL;
begin
  if Assigned(FPfnXMLSetNodeBoolAttribute) then Result := FPfnXMLSetNodeBoolAttribute(hXML, pszAttrName, fAttrValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLGetNodeIntAttribute(hXML: THandle; pszAttrName: LPCWSTR; piAttrValue: PInteger): BOOL;
begin
  if Assigned(FPfnXMLGetNodeIntAttribute) then Result := FPfnXMLGetNodeIntAttribute(hXML, pszAttrName, piAttrValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLSetNodeIntAttribute(hXML: THandle; pszAttrName: LPCWSTR; iAttrValue: Integer): BOOL;
begin
  if Assigned(FPfnXMLSetNodeIntAttribute) then Result := FPfnXMLSetNodeIntAttribute(hXML, pszAttrName, iAttrValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLGetNodeDWORDAttribute(hXML: THandle; pszAttrName: LPCWSTR; pdwAttrValue: PDWORD): BOOL;
begin
  if Assigned(FPfnXMLGetNodeDWORDAttribute) then Result := FPfnXMLGetNodeDWORDAttribute(hXML, pszAttrName, pdwAttrValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLSetNodeDWORDAttribute(hXML: THandle; pszAttrName: LPCWSTR; dwAttrValue: DWORD): BOOL;
begin
  if Assigned(FPfnXMLSetNodeDWORDAttribute) then Result := FPfnXMLSetNodeDWORDAttribute(hXML, pszAttrName, dwAttrValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLGetNodeDWORDLongAttribute(hXML: THandle; pszAttrName: LPCWSTR; pdwlAttrValue: PDWORDLONG): BOOL;
begin
  if Assigned(FPfnXMLGetNodeDWORDLongAttribute) then Result := FPfnXMLGetNodeDWORDLongAttribute(hXML, pszAttrName, pdwlAttrValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLSetNodeDWORDLongAttribute(hXML: THandle; pszAttrName: LPCWSTR; dwlAttrValue: DWORDLONG): BOOL;
begin
  if Assigned(FPfnXMLSetNodeDWORDLongAttribute) then Result := FPfnXMLSetNodeDWORDLongAttribute(hXML, pszAttrName, dwlAttrValue) else Result := False;
end;

function TDOpusPluginHelperXML.XMLDeleteNodeAttribute(hXML: THandle; pszAttrName: LPCWSTR): BOOL;
begin
  if Assigned(FPfnXMLDeleteNodeAttribute) then Result := FPfnXMLDeleteNodeAttribute(hXML, pszAttrName) else Result := False;
end;

function TDOpusPluginHelperXML.XMLDeleteAllNodeAttributes(hXML: THandle): BOOL;
begin
  if Assigned(FPfnXMLDeleteAllNodeAttributes) then Result := FPfnXMLDeleteAllNodeAttributes(hXML) else Result := False;
end;

constructor TDOpusPluginHelperRegistry.Create(AModule: HMODULE);
begin
  inherited Create(AModule);
  FPfnOpusRegOpenKeyW := PFNOPUSREGOPENKEYW(ResolveProc(FUNCNAME_OPUSREGOPENKEYW));
  FPfnOpusRegCreateKeyW := PFNOPUSREGCREATEKEYW(ResolveProc(FUNCNAME_OPUSREGCREATEKEYW));
  FPfnOpusRegQueryValueW := PFNOPUSREGQUERYVALUEW(ResolveProc(FUNCNAME_OPUSREGQUERYVALUEW));
  FPfnOpusRegCloseKey := PFNOPUSREGCLOSEKEY(ResolveProc(FUNCNAME_OPUSREGCLOSEKEY));
  FPfnOpusRegDeleteKeyW := PFNOPUSREGDELETEKEYW(ResolveProc(FUNCNAME_OPUSREGDELETEKEYW));
  FPfnOpusRegDeleteValueW := PFNOPUSREGDELETEVALUEW(ResolveProc(FUNCNAME_OPUSREGDELETEVALUEW));
  FPfnOpusRegSetValueW := PFNOPUSREGSETVALUEW(ResolveProc(FUNCNAME_OPUSREGSETVALUEW));
  FPfnOpusRegCheckElevation := PFNOPUSREGCHECKELEVATION(ResolveProc(FUNCNAME_OPUSREGCHECKELEVATION));
end;

function TDOpusPluginHelperRegistry.OpusRegOpenKeyW(hKey: OPUSREGKEY; lpSubKey: LPCWSTR; samDesired: REGSAM; phkResult: POPUSREGKEY): Longint;
begin
  if Assigned(FPfnOpusRegOpenKeyW) then Result := FPfnOpusRegOpenKeyW(hKey, lpSubKey, samDesired, phkResult) else Result := ERROR_CALL_NOT_IMPLEMENTED;
end;

function TDOpusPluginHelperRegistry.OpusRegCreateKeyW(hKey: OPUSREGKEY; lpSubKey: LPCWSTR; samDesired: REGSAM; phkResult: POPUSREGKEY): Longint;
begin
  if Assigned(FPfnOpusRegCreateKeyW) then Result := FPfnOpusRegCreateKeyW(hKey, lpSubKey, samDesired, phkResult) else Result := ERROR_CALL_NOT_IMPLEMENTED;
end;

function TDOpusPluginHelperRegistry.OpusRegQueryValueW(hKey: OPUSREGKEY; lpValueName: LPCWSTR; lpType: PDWORD; lpData: LPBYTE; lpcbData: PDWORD): Longint;
begin
  if Assigned(FPfnOpusRegQueryValueW) then Result := FPfnOpusRegQueryValueW(hKey, lpValueName, lpType, lpData, lpcbData) else Result := ERROR_CALL_NOT_IMPLEMENTED;
end;

function TDOpusPluginHelperRegistry.OpusRegCloseKey(hKey: OPUSREGKEY): Longint;
begin
  if Assigned(FPfnOpusRegCloseKey) then Result := FPfnOpusRegCloseKey(hKey) else Result := ERROR_CALL_NOT_IMPLEMENTED;
end;

function TDOpusPluginHelperRegistry.OpusRegDeleteKeyW(hKey: OPUSREGKEY; lpSubKey: LPCWSTR): Longint;
begin
  if Assigned(FPfnOpusRegDeleteKeyW) then Result := FPfnOpusRegDeleteKeyW(hKey, lpSubKey) else Result := ERROR_CALL_NOT_IMPLEMENTED;
end;

function TDOpusPluginHelperRegistry.OpusRegDeleteValueW(hKey: OPUSREGKEY; lpValueName: LPCWSTR): Longint;
begin
  if Assigned(FPfnOpusRegDeleteValueW) then Result := FPfnOpusRegDeleteValueW(hKey, lpValueName) else Result := ERROR_CALL_NOT_IMPLEMENTED;
end;

function TDOpusPluginHelperRegistry.OpusRegSetValueW(hKey: OPUSREGKEY; lpValueName: LPCWSTR; dwType: DWORD; lpData: LPCBYTE; cbData: DWORD): Longint;
begin
  if Assigned(FPfnOpusRegSetValueW) then Result := FPfnOpusRegSetValueW(hKey, lpValueName, dwType, lpData, cbData) else Result := ERROR_CALL_NOT_IMPLEMENTED;
end;

function TDOpusPluginHelperRegistry.OpusRegCheckElevation(hKey: OPUSREGKEY; hWnd: HWND): Longint;
begin
  if Assigned(FPfnOpusRegCheckElevation) then Result := FPfnOpusRegCheckElevation(hKey, hWnd) else Result := ERROR_CALL_NOT_IMPLEMENTED;
end;

constructor TDOpusPluginHelperUtil.Create(AModule: HMODULE);
begin
  inherited Create(AModule);
  FPfnDOpusChooseFont := PFNDOPUSCHOOSEFONT(ResolveProc(FUNCNAME_DOPUSCHOOSEFONT));
  FPfnShowRequestDlg := PFNSHOWREQUESTDLG(ResolveProc(FUNCNAME_SHOWREQUESTDLG));
  FPfnDrawPictureFrameInDIB := PFNDRAWPICTUREFRAMEINDIB(ResolveProc(FUNCNAME_DRAWPICTUREFRAMEINDIB));
  FPfnCalcCRC32 := PFNCALCCRC32(ResolveProc(FUNCNAME_CALCCRC32));
  FPfnLogDiagnostic := ResolveLogDiagnosticProc(Dll);
  FHasLogDiagnostic := Assigned(FPfnLogDiagnostic);
end;

function TDOpusPluginHelperUtil.DOpusChooseFont(hWnd: HWND; lpChoose: LPDOPUSCHOOSEFONT): BOOL;
begin
  if Assigned(FPfnDOpusChooseFont) then Result := FPfnDOpusChooseFont(hWnd, lpChoose) else Result := False;
end;

function TDOpusPluginHelperUtil.ShowRequestDlg(lpDlgData: LPSHOWREQUESTDLGDATA): Integer;
begin
  if Assigned(FPfnShowRequestDlg) then Result := FPfnShowRequestDlg(lpDlgData) else Result := 0;
end;

function TDOpusPluginHelperUtil.DrawPictureFrameInDIB(pBMI: PBitmapInfo; pBits: Pointer; prc: PRect; iFrameSize: Integer; iShadowSize: Integer): BOOL;
begin
  if Assigned(FPfnDrawPictureFrameInDIB) then Result := FPfnDrawPictureFrameInDIB(pBMI, pBits, prc, iFrameSize, iShadowSize) else Result := False;
end;

function TDOpusPluginHelperUtil.CalcCRC32(dwCRCIn: DWORD; pData: LPCBYTE; dwSize: DWORD): DWORD;
begin
  if Assigned(FPfnCalcCRC32) then Result := FPfnCalcCRC32(dwCRCIn, pData, dwSize) else Result := 0;
end;

procedure TDOpusPluginHelperUtil.LogDiagnostic(pszSource, pszMessage: LPCWSTR; fPlain: BOOL);
begin
  if Assigned(FPfnLogDiagnostic) then
    FPfnLogDiagnostic(pszSource, pszMessage, fPlain);
end;

constructor TDOpusPluginHelperWow64.Create(AModule: HMODULE);
begin
  inherited Create(AModule);
  FPfnDisableWow64Redirection := PFNDISABLEWOW64REDIRECTION(ResolveProc(FUNCNAME_DISABLEWOW64REDIRECTION));
  FPfnRevertWow64Redirection := PFNREVERTWOW64REDIRECTION(ResolveProc(FUNCNAME_REVERTWOW64REDIRECTION));
end;

function TDOpusPluginHelperWow64.DisableWow64Redirection: THandle;
begin
  if Assigned(FPfnDisableWow64Redirection) then Result := FPfnDisableWow64Redirection() else Result := 0;
end;

procedure TDOpusPluginHelperWow64.RevertWow64Redirection(hHandle: THandle);
begin
  if Assigned(FPfnRevertWow64Redirection) and (hHandle <> 0) then
    FPfnRevertWow64Redirection(hHandle);
end;

constructor TDOpusPluginHelper.Create(AModule: HMODULE);
begin
  inherited Create;
  FConfig := TDOpusPluginHelperConfig.Create(AModule);
  FFunctionHelper := TDOpusPluginHelperFunction.Create(AModule);
  FXML := TDOpusPluginHelperXML.Create(AModule);
  FRegistry := TDOpusPluginHelperRegistry.Create(AModule);
  FUtil := TDOpusPluginHelperUtil.Create(AModule);
  FWow64 := TDOpusPluginHelperWow64.Create(AModule);
end;

destructor TDOpusPluginHelper.Destroy;
begin
  FWow64.Free;
  FUtil.Free;
  FRegistry.Free;
  FXML.Free;
  FFunctionHelper.Free;
  FConfig.Free;
  inherited Destroy;
end;

constructor TDOpusPluginAutoWow64Helper.Create(AModule: HMODULE);
begin
  inherited Create(AModule);
  FHandle := DisableWow64Redirection;
end;

destructor TDOpusPluginAutoWow64Helper.Destroy;
begin
  RevertWow64Redirection(FHandle);
  inherited Destroy;
end;

end.
