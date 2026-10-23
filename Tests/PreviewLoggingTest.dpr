program PreviewLoggingTest;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.IOUtils, Winapi.ActiveX,
  DScintillaLogger, DSciPreviewLogging;

var
  Root, ConfigFile, LogFile: string;
  Passed: Integer;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
  Inc(Passed);
end;

procedure CheckNoFile(const ACase, AXml: string);
var
  Directory: string;
begin
  Directory := TPath.Combine(Root, ACase);
  LogFile := TPath.Combine(Directory, 'dscisrcvwr.log');
  ConfigFile := TPath.Combine(Root, ACase + '.xml');
  if AXml <> '' then
    TFile.WriteAllText(ConfigFile, AXml, TEncoding.UTF8);
  ConfigurePreviewLogging(ConfigFile, LogFile);
  DSciLog('must not create a file', cDSciLogError);
  Check(not FileExists(LogFile), ACase + ': log created');
  Check(not DirectoryExists(Directory), ACase + ': log directory created');
end;

begin
  CoInitialize(nil);
  try
    try
      Root := TPath.Combine(TPath.GetTempPath, 'DSciPreviewLogging-' + TPath.GetRandomFileName);
      ForceDirectories(Root);
      CheckNoFile('missing', '');
      Check(not GetDSciLogEnabled, 'Missing config must default to disabled');
      CheckNoFile('disabled', '<DScintillaConfig><Logging Enabled="no" Level="3" Output="1"/></DScintillaConfig>');
      Check(not GetDSciLogEnabled, 'Disabled flag was ignored');
      CheckNoFile('no-logging-node', '<DScintillaConfig/>');
      CheckNoFile('malformed', '<DScintillaConfig><Logging');
      Check(not GetDSciLogEnabled, 'Malformed config must disable logging');
      CheckNoFile('debug-output', '<DScintillaConfig><Logging Enabled="yes" Level="3" Output="0"/></DScintillaConfig>');
      Check(GetDSciLogEnabled, 'Debug-output logging should remain enabled');
      CheckNoFile('level-none', '<DScintillaConfig><Logging Enabled="yes" Level="0" Output="1"/></DScintillaConfig>');
      ConfigFile := TPath.Combine(Root, 'enabled.xml');
      LogFile := TPath.Combine(Root, 'enabled\dscisrcvwr.log');
      TFile.WriteAllText(ConfigFile,
        '<DScintillaConfig><Logging Enabled="yes" Level="3" Output="1"/></DScintillaConfig>', TEncoding.UTF8);
      ConfigurePreviewLogging(ConfigFile, LogFile);
      Check(GetDSciLogEnabled, 'File logging should be enabled');
      DSciLog('enabled marker', cDSciLogInfo);
      Check(FileExists(LogFile), 'Enabled log was not created');
      Check(Pos('enabled marker', TFile.ReadAllText(LogFile)) > 0, 'Enabled message missing');
      CheckNoFile('disabled-after-enabled', '<DScintillaConfig><Logging Enabled="no" Level="3" Output="1"/></DScintillaConfig>');
      Writeln('PASS: ', Passed, ' preview logging checks. Artifacts: ', Root);
    except
      on E: Exception do
      begin
        Writeln(E.ClassName, ': ', E.Message);
        ExitCode := 1;
      end;
    end;
  finally
    CoUninitialize;
  end;
end.
