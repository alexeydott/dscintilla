unit DOSrcVwrConfigPaths;

interface

uses DOpusPluginHelpers;

// OPUSPATH_CONFIG is the ConfigFiles\Plugins directory, including for USB installs.
function ResolveDOSrcVwrConfigDir(const APluginConfigRoot: string): string;
function GetDOSrcVwrConfigDir(AHelper: TDOpusPluginHelperConfig): string;

implementation

uses
  Winapi.Windows, System.SysUtils, System.IOUtils, DOSrcVwrLog, DOpusPluginSupport;

procedure CheckConfigTree(const ADirectory: string);
var
  LEntry: string;
  LAttributes: DWORD;
begin
  LAttributes := GetFileAttributes(PChar(ADirectory));
  if (LAttributes = INVALID_FILE_ATTRIBUTES) or
     ((LAttributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0) then
    raise EInOutError.Create('Cannot migrate a missing or linked settings directory');
  for LEntry in TDirectory.GetFileSystemEntries(ADirectory) do
  begin
    LAttributes := GetFileAttributes(PChar(LEntry));
    if (LAttributes = INVALID_FILE_ATTRIBUTES) or
       ((LAttributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0) then
      raise EInOutError.Create('Cannot migrate a missing or linked settings entry');
    if (LAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
      CheckConfigTree(LEntry);
  end;
end;

procedure CopyConfigTree(const ASource, ADestination: string);
var
  LEntry, LTarget: string;
  LAttributes: DWORD;
begin
  LAttributes := GetFileAttributes(PChar(ASource));
  if (LAttributes = INVALID_FILE_ATTRIBUTES) or
     ((LAttributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0) then
    raise EInOutError.Create('Cannot migrate a missing or linked settings directory');
  if not ForceDirectories(ADestination) then
    raise EInOutError.Create('Cannot create settings migration directory');
  for LEntry in TDirectory.GetFileSystemEntries(ASource) do
  begin
    LTarget := TPath.Combine(ADestination, ExtractFileName(LEntry));
    LAttributes := GetFileAttributes(PChar(LEntry));
    if (LAttributes = INVALID_FILE_ATTRIBUTES) or
       ((LAttributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0) then
      raise EInOutError.Create('Cannot migrate a missing or linked settings entry');
    if (LAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
      CopyConfigTree(LEntry, LTarget)
    else
      if not FileExists(LTarget) then
        TFile.Copy(LEntry, LTarget, False);
  end;
end;

function ResolveDOSrcVwrConfigDir(const APluginConfigRoot: string): string;
var
  LRoot, LPreferred, LLegacy, LHistorical, LBackup: string;
  LMutex: THandle;
  LWait: DWORD;
  LID: TGUID;
begin
  if Trim(APluginConfigRoot) = '' then
    raise EArgumentException.Create('Plugin config root must not be empty');
  LRoot := ExcludeTrailingPathDelimiter(TPath.GetFullPath(APluginConfigRoot));
  LPreferred := TPath.GetFullPath(TPath.Combine(LRoot,
    '..\..\User Data\dosrcvwr'));
  LLegacy := TPath.Combine(LRoot, 'dosrcvwr');
  LHistorical := TPath.Combine(ExtractFileDir(LRoot), 'dosrcvwr');
  if not DirectoryExists(LLegacy) and DirectoryExists(LHistorical) then
    LLegacy := LHistorical;
  // Fresh installs also read/write User Data. Only a failed migration falls back.
  Result := LPreferred;
  if not DirectoryExists(LLegacy) then
    Exit;
  LMutex := CreateMutex(nil, False, 'Local\DOSrcVwr.ConfigMigration.v1');
  if LMutex = 0 then
  begin
    if not DirectoryExists(LPreferred) then Result := LLegacy;
    Exit;
  end;
  try
    LWait := WaitForSingleObject(LMutex, 5000);
    if (LWait <> WAIT_OBJECT_0) and (LWait <> WAIT_ABANDONED) then
    begin
      if not DirectoryExists(LPreferred) then Result := LLegacy;
      Exit;
    end;
    try
      try
        if not DirectoryExists(LLegacy) then Exit;
        CheckConfigTree(LLegacy);
        if not ForceDirectories(ExtractFileDir(LPreferred)) then
          raise EInOutError.Create('Cannot create User Data directory');
        if not DirectoryExists(LPreferred) then
        begin
          // Rename the whole directory on the same volume: no partial copy,
          // no deletion before publication, and no replacement of a target.
          if not MoveFileEx(PChar(LLegacy), PChar(LPreferred), MOVEFILE_WRITE_THROUGH) then
            RaiseLastOSError;
        end
        else
        begin
          // Existing User Data wins. Add missing files, retain all original
          // versions (including conflicts and .bak files) in a backup below it.
          CheckConfigTree(LPreferred);
          CopyConfigTree(LLegacy, LPreferred);
          CreateGUID(LID);
          LBackup := TPath.Combine(LPreferred,
            'Legacy ConfigFiles Backup\' + GUIDToString(LID));
          if not ForceDirectories(ExtractFileDir(LBackup)) then
            raise EInOutError.Create('Cannot create legacy settings backup');
          if not MoveFileEx(PChar(LLegacy), PChar(LBackup), MOVEFILE_WRITE_THROUGH) then
            RaiseLastOSError;
        end;
        LogInfo('Settings moved from %s to %s', [LLegacy, LPreferred]);
      except
        on E: Exception do
        begin
          if not DirectoryExists(LPreferred) then Result := LLegacy;
          LogError('Settings migration failed; using %s: %s', [Result, E.Message]);
        end;
      end;
    finally
      ReleaseMutex(LMutex);
    end;
  finally
    CloseHandle(LMutex);
  end;
end;

function GetDOSrcVwrConfigDir(AHelper: TDOpusPluginHelperConfig): string;
var
  LBuffer: array[0..MAX_PATH] of WideChar;
  LRoot: string;
begin
  FillChar(LBuffer, SizeOf(LBuffer), 0);
  if (AHelper <> nil) and
     AHelper.GetConfigPath(OPUSPATH_CONFIG, @LBuffer[0], Length(LBuffer)) and
     (LBuffer[0] <> #0) then
    LRoot := string(LBuffer)
  else
    LRoot := TPath.Combine(GetEnvironmentVariable('APPDATA'),
      'GPSoftware\Directory Opus\ConfigFiles\Plugins');
  Result := ResolveDOSrcVwrConfigDir(LRoot);
end;

end.
