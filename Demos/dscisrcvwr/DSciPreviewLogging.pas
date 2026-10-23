unit DSciPreviewLogging;

interface

procedure ConfigurePreviewLogging(const AConfigFileName, ALogFileName: string);

implementation

uses
  System.SysUtils, DScintillaLogger, DScintillaVisualConfig;

procedure ConfigurePreviewLogging(const AConfigFileName, ALogFileName: string);
var
  LConfig: TDSciVisualConfig;
  LDirectory: string;
begin
  // Configuration parsing and missing/malformed settings must not create a log.
  SetDSciLogEnabled(False);
  SetDSciLogPath(ALogFileName);
  SetDSciLogLevel(cDSciLogError);
  SetDSciLogOutput(cDSciOutputFile);
  LConfig := TDSciVisualConfig.Create;
  try
    try
      if FileExists(AConfigFileName) then
        LConfig.LoadFromFile(AConfigFileName);
      SetDSciLogLevel(LConfig.LogLevel);
      SetDSciLogOutput(LConfig.LogOutput);
      if LConfig.LogEnabled and (LConfig.LogLevel > cDSciLogNone) and
        (LConfig.LogOutput = cDSciOutputFile) then
      begin
        LDirectory := ExtractFileDir(ALogFileName);
        if (LDirectory <> '') and not ForceDirectories(LDirectory) then
          Exit;
      end;
      SetDSciLogEnabled(LConfig.LogEnabled);
    except
      // Logging is optional; failure to configure it must not break a shell host.
      SetDSciLogEnabled(False);
    end;
  finally
    LConfig.Free;
  end;
end;

end.
