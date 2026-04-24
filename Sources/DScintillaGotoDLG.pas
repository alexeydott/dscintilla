unit DScintillaGotoDLG;

interface

uses
  System.Classes, System.SysUtils, System.Math,
  Winapi.Windows,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.Forms, Vcl.StdCtrls;

type
  TDSciGotoMode = (
    dgmLine,
    dgmPosition
  );

  TDSciGotoResult = record
    Accepted: Boolean;
    Mode: TDSciGotoMode;
    Value: NativeInt;
  end;

  TDSciGotoDialog = class(TForm)
  private const
    cDialogWidth = 340;
    cDialogHeight = 200;
    cPadding = 12;
    cRowGap = 10;
    cLabelWidth = 120;
    cInputHeight = 26;
    cButtonWidth = 80;
    cButtonHeight = 28;
  private
    FModePanel: TPanel;
    FLineRadio: TRadioButton;
    FPositionRadio: TRadioButton;
    FCurrentLabel: TLabel;
    FCurrentValueLabel: TLabel;
    FGotoLabel: TLabel;
    FGotoEdit: TEdit;
    FMaxLabel: TLabel;
    FMaxValueLabel: TLabel;
    FGoButton: TButton;
    FCancelButton: TButton;
    FCurrentLine: NativeInt;
    FCurrentPos: NativeInt;
    FMaxLine: NativeInt;
    FMaxPos: NativeInt;
    procedure GoButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure ModeChanged(Sender: TObject);
    procedure GotoEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure UpdateLabels;
    procedure BuildUI;
    class function Dpi: Integer; static;
    class function Scale(AValue: Integer): Integer; static;
  protected
    // When hosted in a Low-IL COM preview handler, ShowModal sets fsModal before
    // creating the HWND. VCL's CreateParams then picks LPopupMode=pmAuto and sets
    // WndParent=Application.ActiveFormHandle, which is the preview frame's child HWND
    // embedded in Explorer's Medium-IL pane. CreateWindowEx rejects this cross-IL owner
    // assignment with ERROR_ACCESS_DENIED (Code 5). Force Desktop as the owner window
    // so handle creation always succeeds regardless of the calling IL context.
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    function Execute(ACurrentLine, AMaxLine: NativeInt;
      ACurrentPos, AMaxPos: NativeInt): TDSciGotoResult;
  end;

implementation

{ TDSciGotoDialog }

class function TDSciGotoDialog.Dpi: Integer;
begin
  Result := Screen.PixelsPerInch;
end;

class function TDSciGotoDialog.Scale(AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, Dpi, 96);
end;

procedure TDSciGotoDialog.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if not (csDesigning in ComponentState) then
    Params.WndParent := GetDesktopWindow;
end;

constructor TDSciGotoDialog.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Scaled := False;
  BorderStyle := bsDialog;
  BorderIcons := [biSystemMenu];
  Caption := 'Go To...';
  Position := poScreenCenter;
  KeyPreview := True;
  BuildUI;
end;

procedure TDSciGotoDialog.BuildUI;
var
  lTop, lFormW, lContentW: Integer;
  lPad, lLabelW, lInputH, lBtnW, lBtnH, lRowGap: Integer;
begin
  lPad := Scale(cPadding);
  lLabelW := Scale(cLabelWidth);
  lInputH := Scale(cInputHeight);
  lBtnW := Scale(cButtonWidth);
  lBtnH := Scale(cButtonHeight);
  lRowGap := Scale(cRowGap);
  lFormW := Scale(cDialogWidth);
  lTop := lPad;

  Width := lFormW;
  lContentW := ClientWidth;

  { Mode radio buttons }
  FModePanel := TPanel.Create(Self);
  FModePanel.Parent := Self;
  FModePanel.BevelOuter := bvNone;
  FModePanel.SetBounds(lPad, lTop, lContentW - lPad * 2, lInputH);

  FLineRadio := TRadioButton.Create(Self);
  FLineRadio.Parent := FModePanel;
  FLineRadio.Caption := 'Line';
  FLineRadio.Checked := True;
  FLineRadio.SetBounds(0, 0, Scale(80), lInputH);
  FLineRadio.OnClick := ModeChanged;

  FPositionRadio := TRadioButton.Create(Self);
  FPositionRadio.Parent := FModePanel;
  FPositionRadio.Caption := 'Position';
  FPositionRadio.SetBounds(Scale(90), 0, Scale(100), lInputH);
  FPositionRadio.OnClick := ModeChanged;

  Inc(lTop, lInputH + lRowGap);

  { You are here }
  FCurrentLabel := TLabel.Create(Self);
  FCurrentLabel.Parent := Self;
  FCurrentLabel.Caption := 'You are here:';
  FCurrentLabel.SetBounds(lPad, lTop + 3, lLabelW, lInputH);

  FCurrentValueLabel := TLabel.Create(Self);
  FCurrentValueLabel.Parent := Self;
  FCurrentValueLabel.SetBounds(lPad + lLabelW, lTop + 3,
    lContentW - lPad * 2 - lLabelW, lInputH);

  Inc(lTop, lInputH + lRowGap);

  { Go to }
  FGotoLabel := TLabel.Create(Self);
  FGotoLabel.Parent := Self;
  FGotoLabel.Caption := 'Go to:';
  FGotoLabel.SetBounds(lPad, lTop + 3, lLabelW, lInputH);

  FGotoEdit := TEdit.Create(Self);
  FGotoEdit.Parent := Self;
  FGotoEdit.SetBounds(lPad + lLabelW, lTop,
    lContentW - lPad * 2 - lLabelW - lBtnW - lPad, lInputH);
  FGotoEdit.NumbersOnly := True;
  FGotoEdit.OnKeyDown := GotoEditKeyDown;

  FGoButton := TButton.Create(Self);
  FGoButton.Parent := Self;
  FGoButton.Caption := 'Go!';
  FGoButton.Default := True;
  FGoButton.SetBounds(lContentW - lPad - lBtnW, lTop, lBtnW, lBtnH);
  FGoButton.OnClick := GoButtonClick;

  Inc(lTop, Max(lInputH, lBtnH) + lRowGap);

  { Maximum value }
  FMaxLabel := TLabel.Create(Self);
  FMaxLabel.Parent := Self;
  FMaxLabel.Caption := 'Maximum value:';
  FMaxLabel.SetBounds(lPad, lTop + 3, lLabelW, lInputH);

  FMaxValueLabel := TLabel.Create(Self);
  FMaxValueLabel.Parent := Self;
  FMaxValueLabel.SetBounds(lPad + lLabelW, lTop + 3,
    lContentW - lPad * 2 - lLabelW - lBtnW - lPad, lInputH);

  FCancelButton := TButton.Create(Self);
  FCancelButton.Parent := Self;
  FCancelButton.Caption := 'Cancel';
  FCancelButton.Cancel := True;
  FCancelButton.SetBounds(lContentW - lPad - lBtnW, lTop, lBtnW, lBtnH);
  FCancelButton.OnClick := CancelButtonClick;

  { Set form height to fit content }
  ClientHeight := lTop + Max(lInputH, lBtnH) + lPad;
end;

procedure TDSciGotoDialog.UpdateLabels;
begin
  if FLineRadio.Checked then
  begin
    FCurrentValueLabel.Caption := IntToStr(FCurrentLine);
    FMaxValueLabel.Caption := IntToStr(FMaxLine);
  end
  else
  begin
    FCurrentValueLabel.Caption := IntToStr(FCurrentPos);
    FMaxValueLabel.Caption := IntToStr(FMaxPos);
  end;
end;

procedure TDSciGotoDialog.ModeChanged(Sender: TObject);
begin
  UpdateLabels;
  FGotoEdit.Text := '';
  FGotoEdit.SetFocus;
end;

procedure TDSciGotoDialog.GoButtonClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TDSciGotoDialog.CancelButtonClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TDSciGotoDialog.GotoEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    ModalResult := mrCancel;
    Key := 0;
  end;
end;

function TDSciGotoDialog.Execute(ACurrentLine, AMaxLine: NativeInt;
  ACurrentPos, AMaxPos: NativeInt): TDSciGotoResult;
begin
  FCurrentLine := ACurrentLine;
  FMaxLine := AMaxLine;
  FCurrentPos := ACurrentPos;
  FMaxPos := AMaxPos;
  FLineRadio.Checked := True;
  UpdateLabels;
  FGotoEdit.Text := '';

  Result.Accepted := False;
  Result.Mode := dgmLine;
  Result.Value := 0;

  if ShowModal = mrOk then
  begin
    Result.Accepted := True;
    if FLineRadio.Checked then
      Result.Mode := dgmLine
    else
      Result.Mode := dgmPosition;
    Result.Value := StrToIntDef(Trim(FGotoEdit.Text), -1);
  end;
end;

end.
