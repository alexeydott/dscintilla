#define MyAppName "Scintilla based source code files preview handler"
#define MyAppPublisher "alexey.t"
#define MyAppExeName "DSciSrcVwr.64.dll"
#define MyScintillaDllName "scintilla64.dll"

#ifndef MyAppVersion
  #define MyAppVersion "1.5.6.1"
#endif

#ifndef PreviewDllSource
  #define PreviewDllSource "..\..\bin64\DSciSrcVwr.64.dll"
#endif

#ifndef ScintillaDllSource
  #define ScintillaDllSource "..\..\bin64\scintilla64.dll"
#endif

#ifndef InstallerOutputDir
  #define InstallerOutputDir "Output"
#endif

[Setup]
AppId={{9C8B238F-3C73-4D9F-8B13-6EAE5296C79C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL=https://github.com/alexeydott/dscintilla
DefaultDirName={autopf64}\DScintilla\DSciSrcVwr
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\{#MyAppExeName}
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
ChangesAssociations=yes
OutputDir={#InstallerOutputDir}
OutputBaseFilename=DSciSrcVwr-PreviewHandler-x64-{#MyAppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "{#PreviewDllSource}"; DestDir: "{app}"; DestName: "{#MyAppExeName}"; Flags: ignoreversion
Source: "{#ScintillaDllSource}"; DestDir: "{app}"; DestName: "{#MyScintillaDllName}"; Flags: ignoreversion

[Run]
Filename: "{sys}\regsvr32.exe"; Parameters: "/s ""{app}\{#MyAppExeName}"""; StatusMsg: "Registering preview handler..."; Flags: runhidden waituntilterminated

[UninstallRun]
Filename: "{sys}\regsvr32.exe"; Parameters: "/s /u ""{app}\{#MyAppExeName}"""; RunOnceId: "UnregisterDSciSrcVwr"; Flags: runhidden waituntilterminated

[Code]
procedure UnregisterExistingPreviewHandler;
var
  ExistingDll: string;
  ResultCode: Integer;
begin
  ExistingDll := ExpandConstant('{app}\{#MyAppExeName}');
  if not FileExists(ExistingDll) then
    exit;

  Log('Unregistering previous preview handler copy: ' + ExistingDll);
  if Exec(
    ExpandConstant('{sys}\regsvr32.exe'),
    '/s /u "' + ExistingDll + '"',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode) then
  begin
    Log('Previous copy unregistration exit code: ' + IntToStr(ResultCode));
  end
  else
  begin
    Log('Unable to start regsvr32 for previous preview handler copy; continuing.');
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Result := '';
  UnregisterExistingPreviewHandler;
end;
