#ifndef MyAppVersion
  #define MyAppVersion GetFileVersion("..\..\bin64\DOSrcVwr.dll")
#endif
#ifndef PluginDllSource
  #define PluginDllSource "..\..\bin64\DOSrcVwr.dll"
#endif
#ifndef ScintillaDllSource
  #define ScintillaDllSource "..\..\bin64\scintilla64.dll"
#endif
#ifndef InstallerOutputDir
  #define InstallerOutputDir "..\..\bin64"
#endif

[Setup]
AppId={{8C0A271B-4C50-4D77-AC0A-83D3FD3BC627}
AppName=DOSrcVwr - Directory Opus source code viewer
AppVersion={#MyAppVersion}
AppPublisher=alexey.t
AppPublisherURL=https://github.com/alexeydott/dscintilla
DefaultDirName={code:DefaultOpusDirectory}
UsePreviousAppDir=no
AppendDefaultDirName=no
DisableDirPage=no
DisableProgramGroupPage=yes
DirExistsWarning=no
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
CloseApplications=no
RestartApplications=no
; Opus owns Viewers/. Do not place an uninstaller there or remove a shared DLL.
Uninstallable=no
OutputDir={#InstallerOutputDir}
OutputBaseFilename=DOSrcVwr-DOpusPlugin-x64-{#MyAppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "{#PluginDllSource}"; DestDir: "{app}\Viewers"; DestName: "DOSrcVwr.dll"; Flags: ignoreversion
Source: "{#ScintillaDllSource}"; DestDir: "{app}\Viewers"; DestName: "scintilla64.dll"; Flags: ignoreversion

[Code]
var
  DetectedOpusDirectory: string;
  RestartPending: Boolean;
  WmiServices: Variant;

function GetBinaryType(lpApplicationName: string; var lpBinaryType: LongWord): Boolean;
  external 'GetBinaryTypeW@kernel32.dll stdcall';
function GetTickCount64: Int64;
  external 'GetTickCount64@kernel32.dll stdcall';

function ValidOpusDirectory(const Directory: string): Boolean;
var
  BinaryType: LongWord;
begin
  Result := FileExists(AddBackslash(Directory) + 'dopusrt.exe') and
    GetBinaryType(AddBackslash(Directory) + 'dopus.exe', BinaryType);
  if Result then
    Result := BinaryType = 6; { SCS_64BIT_BINARY }
end;

function RegistryOpusDirectory(RootKey: Integer): string;
var
  ExePath: string;
begin
  Result := '';
  if RegQueryStringValue(RootKey,
    'Software\Microsoft\Windows\CurrentVersion\App Paths\dopus.exe', '', ExePath) then
  begin
    ExePath := RemoveQuotes(Trim(ExePath));
    if ValidOpusDirectory(ExtractFileDir(ExePath)) then
      Result := ExtractFileDir(ExePath);
  end;
end;

function DefaultOpusDirectory(Param: string): string;
begin
  Result := DetectedOpusDirectory;
  if Result = '' then
    Result := ExpandConstant('{autopf64}\GPSoftware\Directory Opus');
end;

function InitializeSetup: Boolean;
var
  SilentDirectory: string;
begin
  DetectedOpusDirectory := RegistryOpusDirectory(HKCU64);
  if DetectedOpusDirectory = '' then
    DetectedOpusDirectory := RegistryOpusDirectory(HKLM64);
  if DetectedOpusDirectory = '' then
    DetectedOpusDirectory := RegistryOpusDirectory(HKCU32);
  if DetectedOpusDirectory = '' then
    DetectedOpusDirectory := RegistryOpusDirectory(HKLM32);
  if (DetectedOpusDirectory = '') and
    ValidOpusDirectory(ExpandConstant('{autopf64}\GPSoftware\Directory Opus')) then
    DetectedOpusDirectory := ExpandConstant('{autopf64}\GPSoftware\Directory Opus');
  Result := True;
  if WizardSilent then
  begin
    SilentDirectory := ExpandConstant('{param:DIR|}');
    if SilentDirectory = '' then
      SilentDirectory := DefaultOpusDirectory('');
    Result := ValidOpusDirectory(SilentDirectory);
    if not Result then
      SuppressibleMsgBox('A valid 64-bit Directory Opus installation is required. ' +
        'Specify its folder with /DIR="path".', mbError, MB_OK, IDOK);
  end;
end;

procedure InitializeWizard;
begin
  WizardForm.ReadyLabel.Caption := 'Setup will install the viewer plugin. If Directory Opus is running, ' +
    'it will be closed before copying files and restarted afterwards.';
  WizardForm.SelectDirLabel.Caption :=
    'Select the Directory Opus installation folder containing dopus.exe. ' +
    'The plugin will be installed in its Viewers subfolder.';
  if DetectedOpusDirectory = '' then
    WizardForm.SelectDirLabel.Caption := WizardForm.SelectDirLabel.Caption + #13#10#13#10 +
      'Directory Opus was not detected automatically. Browse to your 64-bit installation.';
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    Result := ValidOpusDirectory(WizardDirValue);
    if not Result then
      SuppressibleMsgBox('Select an existing 64-bit Directory Opus installation folder ' +
        'containing dopus.exe and dopusrt.exe.', mbError, MB_OK, IDOK);
  end;
end;

function IsOpusRunning: Boolean;
var
  Locator, Processes: Variant;
  ExePath: string;
begin
  Locator := CreateOleObject('WbemScripting.SWbemLocator');
  WmiServices := Locator.ConnectServer('', 'root\CIMV2');
  ExePath := ExpandConstant('{app}\dopus.exe');
  StringChangeEx(ExePath, '\', '\\', True);
  StringChangeEx(ExePath, '''', '\''', True);
  Processes := WmiServices.ExecQuery(
    'SELECT ProcessId FROM Win32_Process WHERE Name = ''dopus.exe'' AND ExecutablePath = ''' + ExePath + '''');
  Result := Processes.Count > 0;
end;

procedure RestartOpus;
var
  ResultCode: Integer;
begin
  if not RestartPending then
    exit;
  try
    if IsOpusRunning then
    begin
      RestartPending := False;
      exit;
    end;
    Log('Restarting Directory Opus as the original user.');
    if ExecAsOriginalUser(ExpandConstant('{app}\dopus.exe'), '',
      ExpandConstant('{app}'), SW_SHOWNORMAL, ewNoWait, ResultCode) then
      RestartPending := False
    else
      Log('Unable to restart Directory Opus: ' + IntToStr(ResultCode));
  except
    Log('Unable to restart Directory Opus: ' + GetExceptionMessage);
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): string;
var
  ResultCode: Integer;
  Deadline: Int64;
begin
  Result := '';
  if not ValidOpusDirectory(ExpandConstant('{app}')) then
  begin
    Result := 'The destination must be an existing 64-bit Directory Opus installation.';
    exit;
  end;
  try
    if not IsOpusRunning then
      exit;
    RestartPending := True;
    Log('Requesting a normal Directory Opus shutdown.');
    if not ExecAsOriginalUser(ExpandConstant('{app}\dopusrt.exe'), '/CMD Close PROGRAM',
      ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, ResultCode) or (ResultCode <> 0) then
    begin
      Result := 'Unable to request Directory Opus shutdown. Close it and retry.';
      exit;
    end;
    Deadline := GetTickCount64 + 20000;
    while GetTickCount64 < Deadline do
    begin
      if not IsOpusRunning then
        exit;
      Sleep(200);
    end;
    Result := 'Directory Opus is still running. Close it in all Windows sessions and retry. No files have been replaced.';
  except
    Result := 'Unable to verify Directory Opus shutdown: ' + GetExceptionMessage;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssDone then
  begin
    RestartOpus;
    if RestartPending then
      SuppressibleMsgBox('The plugin was installed, but Directory Opus could not be restarted. ' +
        'Please start dopus.exe from the selected installation folder.', mbError, MB_OK, IDOK);
  end;
end;

procedure DeinitializeSetup;
begin
  { Also restore Opus after a cancelled or failed installation following shutdown. }
  RestartOpus;
end;
