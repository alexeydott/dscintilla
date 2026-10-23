program DialogEscapeTest;
{$APPTYPE CONSOLE}
uses
  System.SysUtils, System.IOUtils, System.Classes, Winapi.Windows, Winapi.Messages,
  Vcl.Forms, Vcl.ExtCtrls, Vcl.Controls,
  DScintillaVisualConfig, DScintillaVisualSettingsDLG,
  DScintillaSearchReplaceDLG, DScintillaGotoDLG;

type
  TEscapeProbe = class
  private
    Timer: TTimer;
    Ticks: Integer;
    procedure Tick(Sender: TObject);
    procedure Destroyed(Sender: TObject);
  public
    Dialog: TForm;
    Failed: Boolean;
    constructor Create(AForm: TForm);
    destructor Destroy; override;
    procedure WaitUntilClosed;
  end;

constructor TEscapeProbe.Create(AForm: TForm);
begin
  inherited Create;
  Dialog := AForm;
  Dialog.OnDestroy := Destroyed;
  Timer := TTimer.Create(nil);
  Timer.Interval := 25;
  Timer.OnTimer := Tick;
end;

procedure TEscapeProbe.Destroyed(Sender: TObject);
begin
  Dialog := nil;
  Timer.Enabled := False;
end;

destructor TEscapeProbe.Destroy;
begin
  Timer.Free;
  if Dialog <> nil then Dialog.OnDestroy := nil;
  inherited;
end;

procedure TEscapeProbe.Tick(Sender: TObject);
var Target: HWND;
begin
  Inc(Ticks);
  if Dialog = nil then Exit;
  if (Ticks = 2) and Dialog.Visible then
  begin
    Target := Dialog.Handle;
    if Dialog.ActiveControl <> nil then Target := Dialog.ActiveControl.Handle;
    PostMessage(Target, WM_KEYDOWN, VK_ESCAPE, 1);
    PostMessage(Target, WM_KEYUP, VK_ESCAPE, $C0010001);
  end;
  if Ticks >= 40 then
  begin
    Failed := Dialog.Visible;
    Timer.Enabled := False;
    // Watchdog prevents a regression from leaving a modal test hung forever.
    if fsModal in Dialog.FormState then Dialog.ModalResult := mrCancel
    else Dialog.Close;
  end;
end;

procedure TEscapeProbe.WaitUntilClosed;
var Deadline: UInt64;
begin
  Deadline := GetTickCount64 + 1500;
  repeat
    Application.ProcessMessages;
    if (Dialog = nil) or not Dialog.Visible then Break;
    Sleep(1);
  until GetTickCount64 >= Deadline;
  Timer.Enabled := False;
  if Failed or ((Dialog <> nil) and Dialog.Visible) then
    raise Exception.Create('ESC did not close the dialog');
end;

var
  Config: TDSciVisualConfig;
  Settings: TDSciVisualSettingsDialog;
  Search: TDSciSearchReplaceDialog;
  GotoDialog: TDSciGotoDialog;
  Probe: TEscapeProbe;
  Parent: TForm;
  Root, ConfigFile: string;
  ResultData: TDSciGotoResult;
begin
  Application.Initialize;
  try
    Root := TPath.Combine(TPath.GetTempPath, 'dsci-escape-' + TPath.GetRandomFileName);
    ForceDirectories(Root);
    ConfigFile := TPath.Combine(Root, 'config.xml');
    Parent := TForm.CreateNew(nil);
    Config := TDSciVisualConfig.Create;
    try
      Parent.Show;
      Settings := TDSciVisualSettingsDialog.Create(nil);
      Probe := TEscapeProbe.Create(Settings);
      try
        if Settings.EditSettings('', ConfigFile, Config) or Probe.Failed then
          raise Exception.Create('ESC accepted or failed to cancel modal settings');
        if not Parent.Enabled then raise Exception.Create('Modal ESC left parent disabled');
        Writeln('PASS: modal settings ESC cancels and restores parent');
      finally
        Settings.Free;
        Probe.Free;
      end;
      Settings := TDSciVisualSettingsDialog.Create(nil);
      Probe := TEscapeProbe.Create(Settings);
      try
        Settings.ShowSettingsModeless('', ConfigFile, Config);
        Probe.WaitUntilClosed;
        if FileExists(ConfigFile) then raise Exception.Create('ESC saved settings');
        Writeln('PASS: modeless settings ESC closes without saving');
      finally
        if Probe.Dialog <> nil then Probe.Dialog.Free;
        Probe.Free;
      end;
      Search := TDSciSearchReplaceDialog.Create(nil);
      try
        Search.ShowFindTab;
        Probe := TEscapeProbe.Create(Search);
        try
          Search.Show;
          Probe.WaitUntilClosed;
          Writeln('PASS: Find ESC hides dialog');
        finally Probe.Free; end;
        Search.ShowReplaceTab;
        Probe := TEscapeProbe.Create(Search);
        try
          Search.Show;
          Probe.WaitUntilClosed;
          Writeln('PASS: Replace ESC hides dialog');
        finally Probe.Free; end;
      finally Search.Free; end;
      GotoDialog := TDSciGotoDialog.Create(nil);
      Probe := TEscapeProbe.Create(GotoDialog);
      try
        ResultData := GotoDialog.Execute(1, 10, 0, 100);
        if ResultData.Accepted or Probe.Failed then raise Exception.Create('Go To ESC failed');
        if not Parent.Enabled then raise Exception.Create('Go To ESC left parent disabled');
        Writeln('PASS: Go To ESC cancels and restores parent');
      finally
        GotoDialog.Free;
        Probe.Free;
      end;
    finally
      Config.Free;
      Parent.Free;
    end;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
