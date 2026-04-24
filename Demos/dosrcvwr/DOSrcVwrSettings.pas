unit DOSrcVwrSettings;

interface

uses
  System.SysUtils,
  Winapi.Windows,
  DOpusPluginHelpers;

type
  TDOSrcVwrSettings = class
  private
    FConfigFilePath: string;
    FHelper: TDOpusPluginHelperConfig;
    FShowLineNumbers: Boolean;
    FShowFolding: Boolean;
    FWordWrap: Boolean;
  public
    constructor Create(AHelper: TDOpusPluginHelperConfig);
    function ResolveConfigFilePath: string;
    procedure LoadSettings;
    procedure SaveSettings;
    procedure ResetDefaults;
    property ConfigFilePath: string read FConfigFilePath;
    property ShowLineNumbers: Boolean read FShowLineNumbers write FShowLineNumbers;
    property ShowFolding: Boolean read FShowFolding write FShowFolding;
    property WordWrap: Boolean read FWordWrap write FWordWrap;
  end;

implementation

uses
  System.IOUtils, System.Classes, System.StrUtils,
  DOSrcVwrLog;

const
  cSettingsFileName = 'dosrcvwr.settings';

constructor TDOSrcVwrSettings.Create(AHelper: TDOpusPluginHelperConfig);
begin
  inherited Create;
  FHelper := AHelper;
  ResetDefaults;
end;

procedure TDOSrcVwrSettings.ResetDefaults;
begin
  FShowLineNumbers := True;
  FShowFolding := True;
  FWordWrap := False;
end;

function TDOSrcVwrSettings.ResolveConfigFilePath: string;
var
  LBuf: array[0..MAX_PATH] of WideChar;
  LConfigRoot: string;
begin
  if FConfigFilePath <> '' then
    Exit(FConfigFilePath);

  if (FHelper <> nil) and FHelper.GetConfigPath(0, @LBuf[0], MAX_PATH + 1) then
    LConfigRoot := TPath.Combine(string(LBuf), 'dosrcvwr')
  else
    LConfigRoot := TPath.Combine(TPath.GetHomePath, 'dosrcvwr');

  FConfigFilePath := TPath.Combine(LConfigRoot, cSettingsFileName);

  LogInfo('Config path resolved: ' + FConfigFilePath);
  Result := FConfigFilePath;
end;

procedure TDOSrcVwrSettings.LoadSettings;
var
  LPath: string;
  LLines: TStringList;
  I: Integer;
  LKey, LVal: string;
begin
  LPath := ResolveConfigFilePath;
  if not TFile.Exists(LPath) then
  begin
    LogInfo('LoadSettings: no config file, using defaults');
    Exit;
  end;

  LLines := TStringList.Create;
  try
    try
      LLines.LoadFromFile(LPath);
      for I := 0 to LLines.Count - 1 do
      begin
        LKey := LLines.Names[I];
        LVal := LLines.ValueFromIndex[I];
        if SameText(LKey, 'ShowLineNumbers') then
          FShowLineNumbers := SameText(LVal, '1')
        else if SameText(LKey, 'ShowFolding') then
          FShowFolding := SameText(LVal, '1')
        else if SameText(LKey, 'WordWrap') then
          FWordWrap := SameText(LVal, '1');
      end;
      LogInfo('LoadSettings: loaded from ' + LPath);
    except
      on E: Exception do
        LogError('LoadSettings failed: ' + E.Message);
    end;
  finally
    LLines.Free;
  end;
end;

procedure TDOSrcVwrSettings.SaveSettings;
var
  LPath: string;
  LLines: TStringList;
begin
  LPath := ResolveConfigFilePath;
  LLines := TStringList.Create;
  try
    try
      LLines.Add('ShowLineNumbers=' + IfThen(FShowLineNumbers, '1', '0'));
      LLines.Add('ShowFolding=' + IfThen(FShowFolding, '1', '0'));
      LLines.Add('WordWrap=' + IfThen(FWordWrap, '1', '0'));
      ForceDirectories(ExtractFileDir(LPath));
      LLines.SaveToFile(LPath);
      LogInfo('SaveSettings: saved to ' + LPath);
    except
      on E: Exception do
        LogError('SaveSettings failed: ' + E.Message);
    end;
  finally
    LLines.Free;
  end;
end;

end.
