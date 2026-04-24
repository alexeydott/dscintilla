unit DOSrcVwrConfigDlg;

interface

uses
  Winapi.Windows;

function ShowConfigureDialog(AParentWnd: HWND; ANotifyWnd: HWND;
  ANotifyData: DWORD): HWND;
function ShowAboutDialog(AParentWnd: HWND): HWND;

implementation

uses
  System.SysUtils, System.IOUtils, System.Math, System.SyncObjs,
  Winapi.Messages,
  Vcl.Forms,
  DScintillaVisualSettingsDLG,
  DScintillaVisualConfig,
  DOpusViewerPlugins,
  DOpusPluginHelpers,
  DOSrcVwrRuntime,
  DOSrcVwrHost,
  DOSrcVwrLog,
  DOSrcVwrVersion;

type
  { Helper that lives as long as the modeless config dialog.
    Handles save / notify / logging when the user clicks OK. }
  TConfigDialogHelper = class
  private
    FConfigFile: string;
    FNotifyWnd: HWND;
    FNotifyData: DWORD;
    procedure HandleApplyConfig(AConfig: TDSciVisualConfig);
    procedure HandleDialogDestroy(Sender: TObject);
  end;

var
  GDialogHelper: TConfigDialogHelper;
  GDialogHandle: HWND;

procedure TConfigDialogHelper.HandleApplyConfig(AConfig: TDSciVisualConfig);
begin
  LogInfo('ConfigDialogHelper.Apply: saving config (groups=%d)...',
    [AConfig.StyleOverrides.Groups.Count]);
  try
    ForceDirectories(ExtractFileDir(FConfigFile));
    { Backup before save }
    if FileExists(FConfigFile) then
    begin
      try
        TFile.Copy(FConfigFile, FConfigFile + '.bak', True);
      except
        on E: Exception do
          LogError('ConfigDialogHelper: backup failed: %s', [E.Message]);
      end;
    end;
    AConfig.SaveToFile(FConfigFile);
    LogInfo('ConfigDialogHelper: saved to %s', [FConfigFile]);

    { Apply logging settings immediately }
    SetLogEnabled(AConfig.LogEnabled);
    SetLogLevel(TDOpusPluginLogLevel(EnsureRange(AConfig.LogLevel, 0, 3)));
    SetLogOutput(EnsureRange(AConfig.LogOutput, 0, 1));

    { Notify DOpus to reinitialize viewer instances (per SDK contract) }
    if FNotifyWnd <> 0 then
    begin
      LogInfo('ConfigDialogHelper: posting DVPLUGINMSG_REINITIALIZE to $%x lParam=$%x',
        [FNotifyWnd, FNotifyData]);
      PostMessage(FNotifyWnd, DVPLUGINMSG_REINITIALIZE, 0, LPARAM(FNotifyData));
    end;
    NotifyViewersConfigChanged;
  except
    on E: Exception do
      LogError('ConfigDialogHelper.Apply: [%s] %s', [E.ClassName, E.Message]);
  end;
end;

procedure TConfigDialogHelper.HandleDialogDestroy(Sender: TObject);
begin
  LogInfo('ConfigDialogHelper: dialog destroyed, cleaning up');
  GDialogHandle := 0;
  if GDialogHelper = Self then
    GDialogHelper := nil;
  Free;
end;

function ResolveConfigFileName: string;
begin
  Result := PluginHelper.ConfigFile;
end;

function ShowConfigureDialog(AParentWnd: HWND; ANotifyWnd: HWND;
  ANotifyData: DWORD): HWND;
var
  LDialog: TDSciVisualSettingsDialog;
  LConfig: TDSciVisualConfig;
  LConfigFile: string;
  LSettingsDir: string;
begin
  Result := 0;
  LogInfo('ShowConfigureDialog: enter (Thread=%d, Parent=$%x)',
    [GetCurrentThreadId, AParentWnd]);

  { If a dialog is already open, bring it to front and return its handle. }
  if (GDialogHandle <> 0) and IsWindow(GDialogHandle) then
  begin
    LogInfo('ShowConfigureDialog: already open ($%x), activating', [GDialogHandle]);
    SetForegroundWindow(GDialogHandle);
    Result := GDialogHandle;
    Exit;
  end;

  LConfigFile := ResolveConfigFileName;
  LSettingsDir := ExtractFileDir(LConfigFile);
  LogInfo('ShowConfigureDialog: config=%s', [LConfigFile]);

  try
    PluginHelper.EnsureConfigFile;
  except
    on E: Exception do
      LogError('ShowConfigureDialog: EnsureConfigFile: %s', [E.Message]);
  end;

  LConfig := TDSciVisualConfig.Create;
  try
    try
      if FileExists(LConfigFile) then
        LConfig.LoadFromFile(LConfigFile);
    except
      on E: Exception do
        LogError('ShowConfigureDialog: LoadFromFile: %s', [E.Message]);
    end;
    LogInfo('ShowConfigureDialog: loaded config, groups=%d',
      [LConfig.StyleOverrides.Groups.Count]);

    { Create the helper that handles save/notify when user clicks OK }
    FreeAndNil(GDialogHelper);
    GDialogHelper := TConfigDialogHelper.Create;
    GDialogHelper.FConfigFile := LConfigFile;
    GDialogHelper.FNotifyWnd := ANotifyWnd;
    GDialogHelper.FNotifyData := ANotifyData;

    LogInfo('ShowConfigureDialog: creating dialog...');
    LDialog := TDSciVisualSettingsDialog.Create(nil);
    try
      LDialog.Position := poScreenCenter;
      { Make the dialog owned by the DOpus window so it stays on top. }
      if AParentWnd <> 0 then
      begin
        LDialog.HandleNeeded;
        SetWindowLongPtr(LDialog.Handle, GWLP_HWNDPARENT, AParentWnd);
      end;
      LDialog.OnApplyConfig := GDialogHelper.HandleApplyConfig;
      LDialog.OnDestroy := GDialogHelper.HandleDialogDestroy;
      LogInfo('ShowConfigureDialog: showing modeless dialog...');
      LDialog.ShowSettingsModeless(LSettingsDir, LConfigFile, LConfig);
      Result := LDialog.Handle;
      GDialogHandle := Result;
      LogInfo('ShowConfigureDialog: modeless dialog shown, HWND=$%x', [Result]);
    except
      on E: Exception do
      begin
        LogError('ShowConfigureDialog: [%s] %s', [E.ClassName, E.Message]);
        LDialog.Free;
        FreeAndNil(GDialogHelper);
        GDialogHandle := 0;
      end;
    end;
  finally
    LConfig.Free;
  end;
  LogInfo('ShowConfigureDialog: exit => $%x', [Result]);
end;

function ShowAboutDialog(AParentWnd: HWND): HWND;
var
  LText: string;
begin
  LText := cPluginAboutTitle + #13#10 +
    'Version ' + PluginVersionText + #13#10#13#10 +
    cPluginDescription + #13#10 +
    cPluginCopyrightNotice + #13#10 +
    cPluginHomepageURL + #13#10#13#10 +
    'Uses Scintilla editor component (scintilla.org)';
  LogInfo('ShowAboutDialog requested');
  MessageBoxW(AParentWnd, PWideChar(LText), 'About DOSrcVwr',
    MB_OK or MB_ICONINFORMATION);
  Result := 0;
end;

initialization

finalization
  FreeAndNil(GDialogHelper);
  GDialogHandle := 0;

end.
