unit DOSrcVwrRuntime;

interface

uses
  Winapi.Windows,
  DOpusViewerPlugins,
  DOpusPluginHelpers;

type
  { Singleton wrapper around TDOpusPluginHelperConfig.
    Created lazily on first access via PluginHelper.
    Owns the DOpus API helper and caches resolved paths. }
  TDOSrcVwrHelper = class
  private
    FInner: TDOpusPluginHelperConfig;
    FConfigDir: string;
    FConfigFile: string;
    function ResolveConfigDir: string;
  public
    constructor Create;
    destructor Destroy; override;
    { Lazily resolved plugin config directory
      (e.g. ...\ConfigFiles\dosrcvwr). }
    function ConfigDir: string;
    { Full path to dosrcvwr.config.xml inside ConfigDir. }
    function ConfigFile: string;
    { Creates the config file from embedded resource if missing. }
    procedure EnsureConfigFile;
    { The underlying DOpus API helper. }
    property Inner: TDOpusPluginHelperConfig read FInner;
  end;

function HandleInitEx(AInitData: LPDVPINITEXDATA): BOOL;
procedure HandleUninit;
function HandleUSBSafe(AUSBSafeData: LPOPUSUSBSAFEDATA): BOOL;

function OpusMsgWindow: HWND;
function IsInitialized: Boolean;
{ Returns the singleton helper, creating it on first call. }
function PluginHelper: TDOSrcVwrHelper;

implementation

uses
  System.SysUtils, System.IOUtils, System.Math,
  Vcl.Forms,
  DOpusPluginSupport,
  DScintillaVisualConfig,
  DScintillaDefaultConfig,
  DOSrcVwrLog;

var
  GOpusMsgWindow: HWND;
  GInitialized: Boolean;
  GHelper: TDOSrcVwrHelper;
  GVCLInitialized: Boolean;

type
  TAppExceptionHandler = class
    procedure HandleException(Sender: TObject; E: Exception);
  end;

var
  GExceptionHandler: TAppExceptionHandler;

procedure TAppExceptionHandler.HandleException(Sender: TObject; E: Exception);
begin
  LogError('Application.OnException: [%s] %s', [E.ClassName, E.Message]);
end;

procedure EnsureVCL;
begin
  if GVCLInitialized then
  begin
    LogDebug('EnsureVCL: already initialized');
    Exit;
  end;
  LogInfo('EnsureVCL: initializing VCL...');
  if Application = nil then
    Vcl.Forms.Application.Initialize;
  GExceptionHandler := TAppExceptionHandler.Create;
  Application.OnException := GExceptionHandler.HandleException;
  GVCLInitialized := True;
  LogInfo('EnsureVCL: done (Application.OnException hooked)');
end;

{ --- TDOSrcVwrHelper --- }

constructor TDOSrcVwrHelper.Create;
begin
  inherited Create;
  FInner := TDOpusPluginHelperConfig.Create;
end;

destructor TDOSrcVwrHelper.Destroy;
begin
  FInner.Free;
  inherited;
end;

function TDOSrcVwrHelper.ResolveConfigDir: string;
var
  LBuf: array[0..MAX_PATH] of WideChar;
begin
  if FInner.GetConfigPath(OPUSPATH_CONFIG, @LBuf[0], MAX_PATH + 1) then
    Result := TPath.Combine(string(LBuf), 'dosrcvwr')
  else
  begin
    Result := TPath.Combine(
      TPath.Combine(GetEnvironmentVariable('APPDATA'),
        'GPSoftware\Directory Opus\ConfigFiles'),
      'dosrcvwr');
    LogInfo('TDOSrcVwrHelper.ResolveConfigDir: API unavailable, fallback to %s', [Result]);
  end;
end;

function TDOSrcVwrHelper.ConfigDir: string;
begin
  if FConfigDir = '' then
    FConfigDir := ResolveConfigDir;
  Result := FConfigDir;
end;

function TDOSrcVwrHelper.ConfigFile: string;
begin
  if FConfigFile = '' then
    FConfigFile := TPath.Combine(ConfigDir, 'dosrcvwr.config.xml');
  Result := FConfigFile;
end;

procedure TDOSrcVwrHelper.EnsureConfigFile;
begin
  DScintillaDefaultConfig.EnsureDefaultConfigFile(ConfigFile);
end;

{ --- Module-level functions --- }

function OpusMsgWindow: HWND;
begin
  Result := GOpusMsgWindow;
end;

function IsInitialized: Boolean;
begin
  Result := GInitialized;
end;

function PluginHelper: TDOSrcVwrHelper;
begin
  if GHelper = nil then
    GHelper := TDOSrcVwrHelper.Create;
  Result := GHelper;
end;

function HandleInitEx(AInitData: LPDVPINITEXDATA): BOOL;
begin
  LogInfo('HandleInitEx: enter, AInitData=%p', [Pointer(AInitData)]);
  if AInitData = nil then
  begin
    LogError('HandleInitEx: AInitData is nil');
    Exit(False);
  end;
  LogInfo('HandleInitEx: cbSize=%d, expected=%d', [AInitData^.cbSize, SizeOf(DVPINITEXDATA)]);
  if AInitData^.cbSize < SizeOf(DVPINITEXDATA) then
  begin
    LogError('HandleInitEx: cbSize too small');
    Exit(False);
  end;

  // Initialize logging level (file logging already active from unit init)
  InitLogging({$IFDEF DEBUG}dpllDebug{$ELSE}dpllInfo{$ENDIF});

  LogInfo('HandleInitEx: hwndDOpusMsgWindow=$%x', [AInitData^.hwndDOpusMsgWindow]);
  GOpusMsgWindow := AInitData^.hwndDOpusMsgWindow;

  // Bootstrap VCL for the DLL
  EnsureVCL;

  // Ensure the singleton helper exists (may already exist from DVP_Identify)
  LogInfo('HandleInitEx: ensuring helper singleton...');
  PluginHelper;
  LogInfo('HandleInitEx: helper ready');

  // Log USB/portable install status
  if PluginHelper.Inner.IsUSBInstall then
    LogInfo('HandleInitEx: USB/portable install detected')
  else
    LogInfo('HandleInitEx: standard (non-USB) install');

  GInitialized := True;

  // Apply logging settings from config if available
  try
    var LCfgFile := PluginHelper.ConfigFile;
    if FileExists(LCfgFile) then
    begin
      var LCfg := TDSciVisualConfig.Create;
      try
        LCfg.LoadFromFile(LCfgFile);
        SetLogEnabled(LCfg.LogEnabled);
        SetLogLevel(TDOpusPluginLogLevel(EnsureRange(LCfg.LogLevel, 0, 3)));
        SetLogOutput(EnsureRange(LCfg.LogOutput, 0, 1));
      finally
        LCfg.Free;
      end;
    end;
  except
    on E: Exception do
      LogError('HandleInitEx: failed to apply logging config: %s', [E.Message]);
  end;

  // For portable/USB installs, redirect log to plugin config dir (overrides default path)
  if PluginHelper.Inner.IsUSBInstall then
  begin
    LogInfo('HandleInitEx: portable install - redirecting log to config dir');
    RelocateLogToDir(PluginHelper.ConfigDir);
  end;

  LogInfo('HandleInitEx: plugin initialized OK');
  Result := True;
end;

procedure HandleUninit;
begin
  LogInfo('HandleUninit: enter');
  LogInfo('HandleUninit: freeing helper...');
  FreeAndNil(GHelper);
  FreeAndNil(GExceptionHandler);
  GInitialized := False;
  GOpusMsgWindow := 0;
  LogInfo('HandleUninit: done, calling ShutdownLogging');
  ShutdownLogging;
end;

function HandleUSBSafe(AUSBSafeData: LPOPUSUSBSAFEDATA): BOOL;
begin
  if (AUSBSafeData <> nil) and (AUSBSafeData^.cbSize >= SizeOf(OPUSUSBSAFEDATA)) then
  begin
    if (AUSBSafeData^.pszOtherExports <> nil) and (AUSBSafeData^.cchOtherExports > 0) then
      StrPLCopy(AUSBSafeData^.pszOtherExports, 'scintilla64.dll', AUSBSafeData^.cchOtherExports);
  end;
  Result := True;
end;

end.
