unit uSciConfGenRunner;

interface

procedure GenerateSciConfGenArtifacts(const ASettingsDirectory, ASeedConfigFileName,
  AOutputConfigFileName, AOutputXmlFileName, AOutputUnitFileName, AOutputRcFileName,
  AOutputResFileName, AThemeName, AResourceName: string; ACompileResources: Boolean = True);
procedure RunSciConfGen;

implementation

uses
  System.Classes, System.IOUtils, System.StrUtils, System.SysUtils,
  Winapi.Windows,
  DScintillaVisualConfig,
  uSciConfGenImport;

type
  TSciConfGenOptions = record
    ProjectRoot: string;
    SettingsDirectory: string;
    SeedConfigFileName: string;
    OutputConfigFileName: string;
    OutputXmlFileName: string;
    OutputUnitFileName: string;
    OutputRcFileName: string;
    OutputResFileName: string;
    ThemeName: string;
    ResourceName: string;
  end;

function FindProjectRoot(const AStartDirectory: string): string;
var
  lCurrent: string;
begin
  lCurrent := ExcludeTrailingPathDelimiter(ExpandFileName(AStartDirectory));
  while lCurrent <> '' do
  begin
    if DirectoryExists(TPath.Combine(lCurrent, 'source')) and
       FileExists(TPath.Combine(lCurrent, 'settings\stylers.model.xml')) and
       FileExists(TPath.Combine(lCurrent, 'settings\langs.model.xml')) then
      Exit(lCurrent);

    if SameText(lCurrent, ExtractFileDrive(lCurrent) + PathDelim) then
      Break;
    lCurrent := ExcludeTrailingPathDelimiter(ExtractFileDir(lCurrent));
  end;
  Result := '';
end;

procedure WriteUsage;
begin
  Writeln('Usage: SciConfGen.exe [options]');
  Writeln('  --project-root=<path>');
  Writeln('  --settings-dir=<path>');
  Writeln('  --seed-config=<path>');
  Writeln('  --out-config=<path>');
  Writeln('  --out-xml=<path>');
  Writeln('  --out-unit=<path>');
  Writeln('  --out-rc=<path>');
  Writeln('  --out-res=<path>');
  Writeln('  --theme=<name>');
  Writeln('  --resource-name=<name>');
end;

function RemoveQuotedPrefix(const AText, APrefix: string): string;
begin
  Result := Copy(AText, Length(APrefix) + 1, MaxInt);
  if (Length(Result) >= 2) and (Result[1] = '"') and (Result[Length(Result)] = '"') then
    Result := Copy(Result, 2, Length(Result) - 2);
end;

procedure ApplyOption(var AOptions: TSciConfGenOptions; const AArgument: string);
begin
  if StartsText('--project-root=', AArgument) then
    AOptions.ProjectRoot := ExpandFileName(RemoveQuotedPrefix(AArgument, '--project-root='))
  else if StartsText('--settings-dir=', AArgument) then
    AOptions.SettingsDirectory := ExpandFileName(RemoveQuotedPrefix(AArgument, '--settings-dir='))
  else if StartsText('--seed-config=', AArgument) then
    AOptions.SeedConfigFileName := ExpandFileName(RemoveQuotedPrefix(AArgument, '--seed-config='))
  else if StartsText('--out-config=', AArgument) then
    AOptions.OutputConfigFileName := ExpandFileName(RemoveQuotedPrefix(AArgument, '--out-config='))
  else if StartsText('--out-xml=', AArgument) then
    AOptions.OutputXmlFileName := ExpandFileName(RemoveQuotedPrefix(AArgument, '--out-xml='))
  else if StartsText('--out-unit=', AArgument) then
    AOptions.OutputUnitFileName := ExpandFileName(RemoveQuotedPrefix(AArgument, '--out-unit='))
  else if StartsText('--out-rc=', AArgument) then
    AOptions.OutputRcFileName := ExpandFileName(RemoveQuotedPrefix(AArgument, '--out-rc='))
  else if StartsText('--out-res=', AArgument) then
    AOptions.OutputResFileName := ExpandFileName(RemoveQuotedPrefix(AArgument, '--out-res='))
  else if StartsText('--theme=', AArgument) then
    AOptions.ThemeName := RemoveQuotedPrefix(AArgument, '--theme=')
  else if StartsText('--resource-name=', AArgument) then
    AOptions.ResourceName := RemoveQuotedPrefix(AArgument, '--resource-name=')
  else
    raise EArgumentException.CreateFmt('Unsupported argument: %s', [AArgument]);
end;

function ResolveOptions: TSciConfGenOptions;
var
  lArgument: string;
  lArgumentIndex: Integer;
  lProjectRoot: string;
begin
  if (ParamCount > 0) and SameText(ParamStr(1), '--help') then
  begin
    WriteUsage;
    Halt(0);
  end;

  lProjectRoot := FindProjectRoot(GetCurrentDir);
  if lProjectRoot = '' then
    lProjectRoot := FindProjectRoot(ExtractFilePath(ParamStr(0)));
  if lProjectRoot = '' then
    raise Exception.Create('Could not locate the project root from the current directory or executable path.');

  Result.ProjectRoot := lProjectRoot;
  Result.SettingsDirectory := TPath.Combine(lProjectRoot, 'settings');
  Result.SeedConfigFileName := TPath.Combine(Result.SettingsDirectory, 'DScintilla.config.xml');
  Result.OutputConfigFileName := Result.SeedConfigFileName;
  Result.OutputXmlFileName := TPath.Combine(lProjectRoot, 'source\DScintillaDefaultConfig.xml');
  Result.OutputUnitFileName := TPath.Combine(lProjectRoot, 'source\DScintillaDefaultConfig.pas');
  Result.OutputRcFileName := TPath.Combine(lProjectRoot, 'source\DScintillaDefaultConfig.rc');
  Result.OutputResFileName := TPath.Combine(lProjectRoot, 'source\DScintillaDefaultConfig.res');
  Result.ResourceName := 'DSCI_DEFAULT_CONFIG';
  Result.ThemeName := '';

  for lArgumentIndex := 1 to ParamCount do
  begin
    lArgument := ParamStr(lArgumentIndex);
    ApplyOption(Result, lArgument);
  end;
end;

function QuoteArgument(const AValue: string): string;
begin
  Result := '"' + StringReplace(AValue, '"', '\"', [rfReplaceAll]) + '"';
end;

function FindBrcc32: string;
var
  lCandidate: string;
  lFilePart: PChar;
begin
  lCandidate := Trim(GetEnvironmentVariable('BDSBIN'));
  if lCandidate <> '' then
  begin
    lCandidate := TPath.Combine(lCandidate, 'brcc32.exe');
    if FileExists(lCandidate) then
      Exit(lCandidate);
  end;

  SetLength(lCandidate, MAX_PATH);
  lFilePart := nil;
  if SearchPath(nil, 'brcc32.exe', nil, MAX_PATH, PChar(lCandidate), lFilePart) > 0 then
  begin
    SetLength(lCandidate, StrLen(PChar(lCandidate)));
    Exit(lCandidate);
  end;

  raise EFileNotFoundException.Create(
    'brcc32.exe was not found. Run SciConfGen from an initialized RAD Studio environment.');
end;

procedure RunProcess(const ACommandLine, AWorkingDirectory: string);
var
  lCommandLine: string;
  lExitCode: Cardinal;
  lProcessInfo: TProcessInformation;
  lStartupInfo: TStartupInfo;
  lWaitResult: Cardinal;
begin
  FillChar(lStartupInfo, SizeOf(lStartupInfo), 0);
  lStartupInfo.cb := SizeOf(lStartupInfo);
  FillChar(lProcessInfo, SizeOf(lProcessInfo), 0);

  lCommandLine := ACommandLine;
  if not CreateProcess(nil, PChar(lCommandLine), nil, nil, False, CREATE_NO_WINDOW, nil,
    PChar(AWorkingDirectory), lStartupInfo, lProcessInfo) then
    RaiseLastOSError;
  try
    lWaitResult := WaitForSingleObject(lProcessInfo.hProcess, INFINITE);
    if lWaitResult <> WAIT_OBJECT_0 then
      raise Exception.CreateFmt('Waiting for process failed with code %d', [lWaitResult]);

    if not GetExitCodeProcess(lProcessInfo.hProcess, lExitCode) then
      RaiseLastOSError;
    if lExitCode <> 0 then
      raise Exception.CreateFmt('External process failed with exit code %d', [lExitCode]);
  finally
    CloseHandle(lProcessInfo.hThread);
    CloseHandle(lProcessInfo.hProcess);
  end;
end;

procedure CompileResourceFile(const ARcFileName, AResFileName: string);
var
  lBrcc32: string;
  lCommandLine: string;
  lWorkingDirectory: string;
begin
  lBrcc32 := FindBrcc32;
  lWorkingDirectory := ExtractFileDir(ARcFileName);
  lCommandLine := QuoteArgument(lBrcc32) + ' -fo' + QuoteArgument(AResFileName) + ' ' +
    QuoteArgument(ExtractFileName(ARcFileName));
  RunProcess(lCommandLine, lWorkingDirectory);
end;

procedure WriteTextFile(const AFileName, AContent: string;
  AEncoding: TEncoding = nil);
var
  lDirectory: string;
begin
  lDirectory := ExtractFileDir(AFileName);
  if lDirectory <> '' then
    ForceDirectories(lDirectory);
  if AEncoding = nil then
    AEncoding := TEncoding.UTF8;
  TFile.WriteAllText(AFileName, AContent, AEncoding);
end;

procedure WriteRcFile(const AFileName, AResourceName, AXmlFileName: string);
begin
  WriteTextFile(AFileName,
    AResourceName + ' RCDATA "' + ExtractFileName(AXmlFileName) + '"' + sLineBreak,
    TEncoding.ASCII);
end;

procedure WriteUnitFile(const AFileName, AResFileName, AResourceName: string);
const
  UnitTemplate =
'unit DScintillaDefaultConfig;' + sLineBreak +
'' + sLineBreak +
'interface' + sLineBreak +
'' + sLineBreak +
'uses' + sLineBreak +
'  System.Classes;' + sLineBreak +
'' + sLineBreak +
'const' + sLineBreak +
'  DSCI_DEFAULT_CONFIG_FILE_NAME = ''DScintilla.config.xml'';' + sLineBreak +
'  DSCI_DEFAULT_CONFIG_RESOURCE_NAME = ''%s'';' + sLineBreak +
'' + sLineBreak +
'function OpenDefaultConfigStream: TResourceStream;' + sLineBreak +
'function EnsureDefaultConfigFile(const AFileName: string): Boolean;' + sLineBreak +
'procedure SaveDefaultConfigToFile(const AFileName: string);' + sLineBreak +
'' + sLineBreak +
'implementation' + sLineBreak +
'' + sLineBreak +
'uses' + sLineBreak +
'  System.IOUtils, System.SysUtils, Winapi.Windows;' + sLineBreak +
'' + sLineBreak +
'{$R %s}' + sLineBreak +
'' + sLineBreak +
'function OpenDefaultConfigStream: TResourceStream;' + sLineBreak +
'begin' + sLineBreak +
'  Result := TResourceStream.Create(HInstance, DSCI_DEFAULT_CONFIG_RESOURCE_NAME, RT_RCDATA);' + sLineBreak +
'end;' + sLineBreak +
'' + sLineBreak +
'procedure SaveDefaultConfigToFile(const AFileName: string);' + sLineBreak +
'var' + sLineBreak +
'  lDirectory: string;' + sLineBreak +
'  lStream: TResourceStream;' + sLineBreak +
'begin' + sLineBreak +
'  if Trim(AFileName) = '''' then' + sLineBreak +
'    raise EArgumentException.Create(''AFileName must not be empty.'');' + sLineBreak +
'' + sLineBreak +
'  lDirectory := ExtractFileDir(AFileName);' + sLineBreak +
'  if lDirectory <> '''' then' + sLineBreak +
'    ForceDirectories(lDirectory);' + sLineBreak +
'' + sLineBreak +
'  lStream := OpenDefaultConfigStream;' + sLineBreak +
'  try' + sLineBreak +
'    lStream.SaveToFile(AFileName);' + sLineBreak +
'  finally' + sLineBreak +
'    lStream.Free;' + sLineBreak +
'  end;' + sLineBreak +
'end;' + sLineBreak +
'' + sLineBreak +
'function EnsureDefaultConfigFile(const AFileName: string): Boolean;' + sLineBreak +
'begin' + sLineBreak +
'  Result := not FileExists(AFileName);' + sLineBreak +
'  if Result then' + sLineBreak +
'    SaveDefaultConfigToFile(AFileName);' + sLineBreak +
'end;' + sLineBreak +
'' + sLineBreak +
'end.' + sLineBreak;
begin
  WriteTextFile(AFileName,
    Format(UnitTemplate, [AResourceName, ExtractFileName(AResFileName)]));
end;

procedure GenerateSciConfGenArtifacts(const ASettingsDirectory, ASeedConfigFileName,
  AOutputConfigFileName, AOutputXmlFileName, AOutputUnitFileName, AOutputRcFileName,
  AOutputResFileName, AThemeName, AResourceName: string; ACompileResources: Boolean = True);
var
  lConfig: TDSciVisualConfig;
  lStep: string;
begin
  lConfig := TDSciVisualConfig.Create;
  try
    try
      lStep := 'import legacy settings';
      BuildConfigFromLegacySettings(ASettingsDirectory, ASeedConfigFileName, AThemeName, lConfig);

      lStep := 'write merged config';
      lConfig.SaveToFile(AOutputConfigFileName);

      lStep := 'write default-config xml';
      lConfig.SaveToFile(AOutputXmlFileName);

      lStep := 'write resource script';
      WriteRcFile(AOutputRcFileName, AResourceName, AOutputXmlFileName);

      lStep := 'write resource unit';
      WriteUnitFile(AOutputUnitFileName, AOutputResFileName, AResourceName);

      if ACompileResources then
      begin
        lStep := 'compile resource';
        CompileResourceFile(AOutputRcFileName, AOutputResFileName);
      end;
    except
      on E: Exception do
        raise Exception.CreateFmt('SciConfGen %s failed: %s - %s',
          [lStep, E.ClassName, E.Message]);
    end;
  finally
    lConfig.Free;
  end;
end;

procedure GenerateArtifacts(const AOptions: TSciConfGenOptions);
begin
  GenerateSciConfGenArtifacts(AOptions.SettingsDirectory, AOptions.SeedConfigFileName,
    AOptions.OutputConfigFileName, AOptions.OutputXmlFileName, AOptions.OutputUnitFileName,
    AOptions.OutputRcFileName, AOptions.OutputResFileName, AOptions.ThemeName,
    AOptions.ResourceName, True);
end;

procedure RunSciConfGen;
var
  lOptions: TSciConfGenOptions;
begin
  lOptions := ResolveOptions;
  GenerateArtifacts(lOptions);

  Writeln('Generated config: ' + lOptions.OutputConfigFileName);
  Writeln('Generated resource XML: ' + lOptions.OutputXmlFileName);
  Writeln('Generated resource unit: ' + lOptions.OutputUnitFileName);
  Writeln('Generated resource script: ' + lOptions.OutputRcFileName);
  Writeln('Generated resource binary: ' + lOptions.OutputResFileName);
end;

end.
