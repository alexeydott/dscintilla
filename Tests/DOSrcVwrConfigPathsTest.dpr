program DOSrcVwrConfigPathsTest;
{$APPTYPE CONSOLE}
uses
  System.SysUtils, System.IOUtils, System.Classes, Winapi.Windows,
  DOpusPluginHelpers, DOpusPluginSupport, DOSrcVwrConfigPaths,
  DOSrcVwrSettings;

var
  Root, ConfigRoot, Preferred, Legacy, MockRoot, SavedAppData: string;
  Passed: Integer;

function GetConfigPathW(Kind: Integer; Buffer: LPWSTR; Capacity: UINT): BOOL; cdecl;
begin
  Result := (Kind = OPUSPATH_CONFIG) and (Capacity > UINT(Length(MockRoot)));
  if Result then StrPLCopy(Buffer, MockRoot, Capacity - 1);
end;
exports GetConfigPathW;

procedure Check(Value: Boolean; const MessageText: string);
begin
  if not Value then raise Exception.Create(MessageText);
  Inc(Passed);
end;

procedure NewCase(const Name: string);
begin
  ConfigRoot := TPath.Combine(Root, Name + '\ConfigFiles\Plugins');
  Preferred := TPath.Combine(Root, Name + '\User Data\dosrcvwr');
  Legacy := TPath.Combine(ConfigRoot, 'dosrcvwr');
end;

procedure Put(const Path, Text: string);
begin
  ForceDirectories(ExtractFileDir(Path));
  TFile.WriteAllText(Path, Text, TEncoding.UTF8);
end;

procedure RunTests;
var
  ConfigFile, BackupFile, Actual: string;
  Backups: TArray<string>;
  Locked: THandle;
  Helper: TDOpusPluginHelperConfig;
  Settings: TDOSrcVwrSettings;
begin
  NewCase('fresh');
  Check(SameFileName(ResolveDOSrcVwrConfigDir(ConfigRoot), Preferred), 'Fresh install path');
  Check(not DirectoryExists(Legacy), 'Fresh install created legacy directory');

  NewCase('migration-кириллица');
  ConfigFile := TPath.Combine(Legacy, 'dosrcvwr.config.xml');
  Put(ConfigFile, '<Config/>');
  Put(ConfigFile + '.bak', 'previous XML');
  Put(TPath.Combine(Legacy, 'themes\nested\theme.xml'), 'theme');
  Put(TPath.Combine(Legacy, 'dosrcvwr.settings'), 'WordWrap=1');
  ForceDirectories(TPath.Combine(Legacy, 'empty-folder'));
  Check(SameFileName(ResolveDOSrcVwrConfigDir(ConfigRoot + '\'), Preferred), 'Migration path');
  Check(not DirectoryExists(Legacy), 'Legacy directory not removed');
  Check(TFile.ReadAllText(TPath.Combine(Preferred, 'dosrcvwr.config.xml')) = '<Config/>', 'XML lost');
  Check(TFile.ReadAllText(TPath.Combine(Preferred, 'dosrcvwr.config.xml.bak')) = 'previous XML', '.bak lost');
  Check(TFile.ReadAllText(TPath.Combine(Preferred, 'themes\nested\theme.xml')) = 'theme', 'Nested theme lost');
  Check(DirectoryExists(TPath.Combine(Preferred, 'empty-folder')), 'Empty directory lost');
  Check(SameFileName(ResolveDOSrcVwrConfigDir(ConfigRoot), Preferred), 'Migration not idempotent');

  NewCase('both-exist');
  Put(TPath.Combine(Preferred, 'dosrcvwr.config.xml'), 'new XML');
  Put(TPath.Combine(Legacy, 'dosrcvwr.config.xml'), 'old XML');
  Put(TPath.Combine(Legacy, 'themes\extra.xml'), 'extra theme');
  Check(SameFileName(ResolveDOSrcVwrConfigDir(ConfigRoot), Preferred), 'Preferred directory priority');
  Check(not DirectoryExists(Legacy), 'Merged legacy folder still exists');
  Check(TFile.ReadAllText(TPath.Combine(Preferred, 'dosrcvwr.config.xml')) = 'new XML', 'New XML overwritten');
  Check(TFile.ReadAllText(TPath.Combine(Preferred, 'themes\extra.xml')) = 'extra theme', 'Missing file not merged');
  Backups := TDirectory.GetDirectories(TPath.Combine(Preferred, 'Legacy ConfigFiles Backup'));
  Check(Length(Backups) = 1, 'Legacy backup missing');
  BackupFile := TPath.Combine(Backups[0], 'dosrcvwr.config.xml');
  Check(TFile.ReadAllText(BackupFile) = 'old XML', 'Conflicting original lost');
  ResolveDOSrcVwrConfigDir(ConfigRoot);
  Check(Length(TDirectory.GetDirectories(TPath.Combine(Preferred, 'Legacy ConfigFiles Backup'))) = 1,
    'Repeated migration created extra backup');

  NewCase('blocked-destination');
  Put(Preferred, 'blocking file');
  Put(TPath.Combine(Legacy, 'dosrcvwr.config.xml'), 'keep me');
  Check(SameFileName(ResolveDOSrcVwrConfigDir(ConfigRoot), Legacy), 'Migration failure fallback');
  Check(TFile.ReadAllText(TPath.Combine(Legacy, 'dosrcvwr.config.xml')) = 'keep me', 'Failed migration lost source');
  Check(TFile.ReadAllText(Preferred) = 'blocking file', 'Destination collision overwritten');

  NewCase('locked-source');
  Put(TPath.Combine(Legacy, 'dosrcvwr.config.xml'), 'locked source');
  Locked := CreateFile(PChar(Legacy), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE,
    nil, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, 0);
  if Locked = INVALID_HANDLE_VALUE then RaiseLastOSError;
  try
    Actual := ResolveDOSrcVwrConfigDir(ConfigRoot);
    Check(SameFileName(Actual, Legacy), 'Locked source fallback');
    Check(not DirectoryExists(Preferred), 'Failed rename published partial settings');
  finally
    CloseHandle(Locked);
  end;
  Check(SameFileName(ResolveDOSrcVwrConfigDir(ConfigRoot), Preferred), 'Retry after lock release');
  Check(not DirectoryExists(Legacy), 'Retry did not remove old directory');

  NewCase('portable-profile');
  MockRoot := ConfigRoot;
  Helper := TDOpusPluginHelperConfig.Create(GetModuleHandle(nil));
  try
    Check(SameFileName(GetDOSrcVwrConfigDir(Helper), Preferred), 'Opus API path ignored');
    Settings := TDOSrcVwrSettings.Create(Helper);
    try
      Settings.WordWrap := True;
      Settings.SaveSettings;
      Check(SameFileName(Settings.ConfigFilePath, TPath.Combine(Preferred, 'dosrcvwr.settings')),
        'Settings writer uses different root');
      Settings.WordWrap := False;
      Settings.LoadSettings;
      Check(Settings.WordWrap, 'Settings read/write round trip');
      Check(not DirectoryExists(Legacy), 'Settings writer recreated legacy path');
    finally
      Settings.Free;
    end;
  finally
    Helper.Free;
  end;

  SetEnvironmentVariable('APPDATA', PChar(TPath.Combine(Root, 'fallback')));
  Check(SameFileName(GetDOSrcVwrConfigDir(nil), TPath.Combine(Root,
    'fallback\GPSoftware\Directory Opus\User Data\dosrcvwr')), 'APPDATA fallback');
end;

begin
  SavedAppData := GetEnvironmentVariable('APPDATA');
  Root := TPath.Combine(TPath.GetTempPath, 'DOSrcVwr-paths-' + TPath.GetRandomFileName);
  ForceDirectories(Root);
  try
    try
      RunTests;
      Writeln('PASS: ', Passed, ' config path/migration/settings checks. Artifacts: ', Root);
    except
      on E: Exception do
      begin
        Writeln(E.ClassName, ': ', E.Message, ' Artifacts: ', Root);
        ExitCode := 1;
      end;
    end;
  finally
    SetEnvironmentVariable('APPDATA', PChar(SavedAppData));
  end;
end.
