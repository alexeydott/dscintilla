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
  Vcl.Forms, Vcl.ExtCtrls,
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
    FParentWnd: HWND;      // DOpus parent to re-enable when dialog closes
    FParentGuard: TTimer;  // polls parent validity; closes dialog if parent gone
    procedure HandleApplyConfig(AConfig: TDSciVisualConfig);
    procedure HandleDialogDestroy(Sender: TObject);
    procedure HandleParentGuardTimer(Sender: TObject);
  end;

var
  GDialogHelper: TConfigDialogHelper;
  GDialogHandle: HWND;
  { Weak reference to the open modeless dialog.  Used only at finalization to
    clear callbacks before GDialogHelper is freed, preventing a dangling
    method-pointer if the DLL is unloaded while the dialog is still open. }
  GDialog: TDSciVisualSettingsDialog;

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
  { Stop the guard timer before any cleanup so it cannot fire mid-teardown }
  FreeAndNil(FParentGuard);
  GDialog := nil;
  GDialogHandle := 0;
  if GDialogHelper = Self then
    GDialogHelper := nil;
  { Re-enable DOpus parent window that was disabled while the dialog was open }
  if (FParentWnd <> 0) and IsWindow(FParentWnd) then
  begin
    EnableWindow(FParentWnd, True);
    LogInfo('ConfigDialogHelper: re-enabled parent $%x', [FParentWnd]);
    { Explicitly restore focus to parent. Without an owner relationship,
      Windows picks an arbitrary window to activate when the dialog closes -
      which may be from another process.  EnableWindow must be called first
      so the target window can actually receive focus. }
    SetForegroundWindow(FParentWnd);
    LogInfo('ConfigDialogHelper: restored foreground to parent $%x', [FParentWnd]);
  end;
  Free;
end;

procedure TConfigDialogHelper.HandleParentGuardTimer(Sender: TObject);
begin
  { If the DOpus parent window was closed/destroyed while our settings dialog
    is still open, close the dialog so DOpus can fully shut down. }
  if (FParentWnd <> 0) and not IsWindow(FParentWnd) then
  begin
    LogInfo('ParentGuard: parent $%x gone - closing settings dialog', [FParentWnd]);
    FParentGuard.Enabled := False;
    { Clear FParentWnd so HandleDialogDestroy does not attempt to re-enable
      or set foreground on an already-destroyed window handle. }
    FParentWnd := 0;
    if GDialogHandle <> 0 then
      PostMessage(GDialogHandle, WM_CLOSE, 0, 0);
  end;
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

  { If a dialog is already open, bring it to front; caller should NOT block. }
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
    GDialogHelper.FParentWnd := AParentWnd;

    LogInfo('ShowConfigureDialog: creating dialog...');
    LDialog := TDSciVisualSettingsDialog.Create(nil);
    try
      LDialog.Position := poScreenCenter;
      { Do NOT set DOpus window as VCL owner - that causes VCL to
        interact with DOpus window enable/disable states when any internal
        sub-dialog (colour picker, etc.) opens.  The dialog is made TOPMOST
        after Show so it remains visible above DOpus windows without
        requiring an ownership relationship. }
      LDialog.OnApplyConfig := GDialogHelper.HandleApplyConfig;
      LDialog.OnDestroy := GDialogHelper.HandleDialogDestroy;
      LogInfo('ShowConfigureDialog: showing modeless dialog...');
      { Disable DOpus parent while dialog is open - mirrors proper modal behavior,
        prevents Preferences from being re-entered, and allows us to re-enable it
        ourselves in HandleDialogDestroy without relying on DOpus to do so. }
      if (AParentWnd <> 0) and IsWindow(AParentWnd) then
      begin
        EnableWindow(AParentWnd, False);
        LogInfo('ShowConfigureDialog: disabled parent $%x', [AParentWnd]);
      end;
      LDialog.ShowSettingsModeless(LSettingsDir, LConfigFile, LConfig);
      SetWindowPos(LDialog.Handle, HWND_TOPMOST, 0, 0, 0, 0,
        SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
      Result := LDialog.Handle;
      GDialogHandle := Result;
      GDialog := LDialog;
      { Start parent-guard timer: if the DOpus Preferences window is destroyed
        while the settings dialog is open, the timer will close the dialog. }
      if AParentWnd <> 0 then
      begin
        GDialogHelper.FParentGuard := TTimer.Create(nil);
        GDialogHelper.FParentGuard.Interval := 250;
        GDialogHelper.FParentGuard.OnTimer := GDialogHelper.HandleParentGuardTimer;
        GDialogHelper.FParentGuard.Enabled := True;
        LogInfo('ShowConfigureDialog: parent guard timer started for $%x', [AParentWnd]);
      end;
      LogInfo('ShowConfigureDialog: dialog shown HWND=$%x (parent $%x disabled)',
        [Result, AParentWnd]);
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
  { If the DLL is unloaded while the dialog is still open, clear the callbacks
    before freeing the helper so there is no dangling method-pointer when
    Windows later destroys the orphaned window. }
  if GDialog <> nil then
  begin
    GDialog.OnApplyConfig := nil;
    GDialog.OnDestroy := nil;
    GDialog := nil;
  end;
  { Signal the done event and re-enable parent so any blocked DVP_Configure
    worker thread is not left waiting indefinitely during DLL unload. }
  if GDialogHelper <> nil then
  begin
    if (GDialogHelper.FParentWnd <> 0) and IsWindow(GDialogHelper.FParentWnd) then
    begin
      EnableWindow(GDialogHelper.FParentWnd, True);
      LogInfo('Finalization: re-enabled parent $%x during DLL unload',
        [GDialogHelper.FParentWnd]);
    end;
  end;
  FreeAndNil(GDialogHelper);
  GDialogHandle := 0;

end.
