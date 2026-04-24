unit DOSrcVwrLog;

{.$DEFINE use_dopus_logging}

interface

uses
  DOpusPluginHelpers;

procedure LogError(const AMessage: string); overload;
procedure LogInfo(const AMessage: string); overload;
procedure LogDebug(const AMessage: string); overload;
procedure LogError(const AFmt: string; const AArgs: array of const); overload;
procedure LogInfo(const AFmt: string; const AArgs: array of const); overload;
procedure LogDebug(const AFmt: string; const AArgs: array of const); overload;

procedure InitLogging(ALevel: TDOpusPluginLogLevel = dpllInfo);
procedure ShutdownLogging;
procedure SetLogEnabled(AEnabled: Boolean);
procedure SetLogLevel(ALevel: TDOpusPluginLogLevel);
procedure SetLogOutput(AOutput: Integer);
function GetDefaultLogPath: string;
procedure RelocateLogToDir(const ADir: string);

implementation

uses
  Winapi.Windows,
  System.IOUtils,
  System.SysUtils,
  DScintillaLogger;

const
  cDOSrcVwrLogSource = 'DOSrcVwr';
  cDOpusHelperLogSource = 'DOpusHelper';
  �DOLogSubDir = 'GPSoftware\Directory Opus\Logs';
  cDOSrcVwrFileName = 'dosrcvwr.log';

var
  GConfiguredLogLevel: TDOpusPluginLogLevel = dpllError;

function GetDefaultLogPath: string;
var
  basePath: string;
begin
  BasePath := GetEnvironmentVariable('APPDATA');
  if BasePath.IsEmpty then
    BasePath := TPath.GetTempPath;
  if BasePath.IsEmpty then
    BasePath := TDirectory.GetCurrentDirectory;
  Result := TPath.Combine(BasePath, �DOLogSubDir);
  Result := TPath.Combine(Result, cDOSrcVwrFileName);
end;

function ShouldEmitLog(ALevel: TDOpusPluginLogLevel): Boolean;
begin
  Result := GetDSciLogEnabled and (ALevel <> dpllNone) and
    (Ord(ALevel) <= GetDSciLogLevel);
end;

procedure ApplyHelperLogLevel;
begin
  if GetDSciLogEnabled then
    SetDOpusPluginLogLevel(GConfiguredLogLevel)
  else
    SetDOpusPluginLogLevel(dpllNone);
end;

function FormatFallbackMessage(const ASource, AMessage: string): string;
begin
  if ASource <> '' then
    Result := Format('[%s] %s', [ASource, AMessage])
  else
    Result := AMessage;
end;

function TryLogViaDOpus(ALevel: TDOpusPluginLogLevel; const ASource,
  AMessage: string): Boolean;
begin
{$IFDEF use_dopus_logging}
  Result := TryDOpusLogDiagnostic(ASource, AMessage, ALevel <> dpllError);
{$ELSE}
  Result := False;
{$ENDIF}
end;

procedure DoLog(ALevel: TDOpusPluginLogLevel; const AMessage: string;
  const ASource: string = cDOSrcVwrLogSource);
begin
  if not ShouldEmitLog(ALevel) then
    Exit;

  if not TryLogViaDOpus(ALevel, ASource, AMessage) then
    DSciLog(FormatFallbackMessage(ASource, AMessage), Ord(ALevel));
end;

procedure LogError(const AMessage: string);
begin
  DoLog(dpllError, AMessage);
end;

procedure LogInfo(const AMessage: string);
begin
  DoLog(dpllInfo, AMessage);
end;

procedure LogDebug(const AMessage: string);
begin
  DoLog(dpllDebug, AMessage);
end;

procedure LogError(const AFmt: string; const AArgs: array of const);
begin
  DoLog(dpllError, Format(AFmt, AArgs));
end;

procedure LogInfo(const AFmt: string; const AArgs: array of const);
begin
  DoLog(dpllInfo, Format(AFmt, AArgs));
end;

procedure LogDebug(const AFmt: string; const AArgs: array of const);
begin
  DoLog(dpllDebug, Format(AFmt, AArgs));
end;

procedure DOpusLogHandler(ALevel: TDOpusPluginLogLevel; const AMessage: string);
begin
  DoLog(ALevel, AMessage, cDOpusHelperLogSource);
end;

procedure InitLogging(ALevel: TDOpusPluginLogLevel);
begin
  GConfiguredLogLevel := ALevel;
  SetDSciLogPath(GetDefaultLogPath);
  SetDSciLogEnabled(True);
  SetDSciLogLevel(Ord(ALevel));
  SetDSciLogOutput(cDSciOutputFile);
  SetDOpusPluginLogProc(DOpusLogHandler);
  ApplyHelperLogLevel;
  LogInfo('InitLogging: level set to %d', [Ord(ALevel)]);
end;

procedure ShutdownLogging;
begin
  LogInfo('ShutdownLogging: closing log');
  SetDOpusPluginLogProc(nil);
end;

procedure SetLogEnabled(AEnabled: Boolean);
begin
  SetDSciLogEnabled(AEnabled);
  ApplyHelperLogLevel;
end;

procedure SetLogLevel(ALevel: TDOpusPluginLogLevel);
begin
  GConfiguredLogLevel := ALevel;
  SetDSciLogLevel(Ord(ALevel));
  ApplyHelperLogLevel;
end;

procedure SetLogOutput(AOutput: Integer);
begin
  if AOutput = cDSciOutputFile then
    SetDSciLogPath(GetDefaultLogPath);
  SetDSciLogOutput(AOutput);
end;

procedure RelocateLogToDir(const ADir: string);
var
  LNewPath: string;
begin
  LNewPath := TPath.Combine(ADir, cDOSrcVwrFileName);
  LogInfo('RelocateLogToDir: redirecting log to %s', [LNewPath]);
  SetDSciLogPath(LNewPath);
end;

initialization
  InitLogging({$ifdef debug}TDOpusPluginLogLevel.dpllDebug{$else}TDOpusPluginLogLevel.dpllError{$endif});
  LogInfo('=== DOSrcVwr DLL loaded (PID=%d) ===', [GetCurrentProcessId]);

finalization
  LogInfo('=== DOSrcVwr DLL unloading ===');
  ShutdownLogging();

end.
