unit DScintillaVisualSettingsDLG;

interface

uses
  System.Classes,
  Winapi.Windows,
  Vcl.Controls, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Forms, Vcl.Graphics,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.WinXPanels,
  DScintillaVisualConfig;

type
  TDSciVisualConfigApplyEvent = procedure(AConfig: TDSciVisualConfig) of object;

  TDSciVisualSettingsDialog = class(TForm)
  private
    FSettingsDirectory: string;
    FConfigFileName: string;
    FCatalog: TDSciVisualCatalog;
    FConfig: TDSciVisualConfig;
    FEmbeddedDefaultConfig: TDSciVisualConfig;
    FHasSettingsCatalog: Boolean;
    FThemeDirectories: TStringList;
    FUpdatingControls: Boolean;
    FUpdatingLayout: Boolean;
    FModeless: Boolean;
    FOnApplyConfig: TDSciVisualConfigApplyEvent;

    FContentPanel: TPanel;
    FButtonsPanel: TPanel;
    FThemePanel: TPanel;
    FCategoryPanel: TPanel;
    FCardPanel: TCardPanel;
    FStyleCard: TCard;
    FGeneralCard: TCard;
    FEditorCard: TCard;
    FSelectionCard: TCard;
    FWrappingCard: TCard;
    FCaretPasteCard: TCard;
    FFoldingCard: TCard;
    FStyleSection: TGroupBox;
    FMiscSection: TGroupBox;
    FStyleStack: TStackPanel;
    FMiscStack: TStackPanel;
    FSearchHighlightSection: TGroupBox;
    FSelectionSection: TGroupBox;
    FSmartHighlightSection: TGroupBox;
    FSearchSection: TGroupBox;
    FEditorSection: TGroupBox;
    FWrappingSection: TGroupBox;
    FMarginsSection: TGroupBox;
    FCaretSection: TGroupBox;
    FCopyPasteSection: TGroupBox;
    FFoldingSection: TGroupBox;
    FDocumentSection: TGroupBox;
    FPrintingSection: TGroupBox;
    FLineNumberingSection: TGroupBox;
    FTextPaddingSection: TGroupBox;
    FStatusBarPanelsRow: TPanel;
    FLanguagePanel: TPanel;
    FExtensionsPanel: TPanel;
    FStylePanel: TPanel;
    FFontNamePanel: TPanel;
    FFontSizePanel: TPanel;
    FStyleColorsRow: TPanel;
    FFontStylesRow: TPanel;
    FHighlightPanel: TPanel;
    FTechnologyPanel: TPanel;
    FFontLocalePanel: TPanel;
    FFontQualityPanel: TPanel;
    FMiscOptionsRow: TPanel;
    FTabWidthPanel: TPanel;
    FFileSizeLimitPanel: TPanel;
    FMiscChecksRow: TPanel;
    FGutterChecksRow: TPanel;
    FGutterStylePanel: TPanel;
    FGutterColorsRow: TPanel;
    FSearchSyncRow: TPanel;
    FColorDialog: TColorDialog;
    FOpenThemeDialog: TOpenDialog;
    FOkButton: TButton;
    FCancelButton: TButton;

    FThemeLabel: TLabel;
    FThemeCombo: TComboBox;
    FThemeImportButton: TButton;
    FCategoryLabel: TLabel;
    FCategoryCombo: TComboBox;
    FLanguageLabel: TLabel;
    FLanguageCombo: TComboBox;
    FStyleLabel: TLabel;
    FStyleCombo: TComboBox;
    FFontNameLabel: TLabel;
    FFontNameCombo: TComboBox;
    FFontSizeLabel: TLabel;
    FFontSizeEdit: TSpinEdit;
    FForegroundLabel: TLabel;
    FForegroundBox: TPanel;
    FBackgroundLabel: TLabel;
    FBackgroundBox: TPanel;
    FBoldCheck: TCheckBox;
    FItalicCheck: TCheckBox;
    FUnderlineCheck: TCheckBox;
    FExtensionsLabel: TLabel;
    FExtensionsEdit: TEdit;

    FHighlightLabel: TLabel;
    FHighlightBox: TPanel;
    FTechnologyLabel: TLabel;
    FTechnologyCombo: TComboBox;
    FFontLocaleLabel: TLabel;
    FFontLocaleEdit: TEdit;
    FFontQualityLabel: TLabel;
    FFontQualityCombo: TComboBox;
    FTransparencyLabel: TLabel;
    FTransparencyEdit: TSpinEdit;
    FOutlineLabel: TLabel;
    FOutlineEdit: TSpinEdit;
    FShowStatusBarCheck: TCheckBox;
    FStatusPanelFileCheck: TCheckBox;
    FStatusPanelPosCheck: TCheckBox;
    FStatusPanelLexerCheck: TCheckBox;
    FStatusPanelEncodingCheck: TCheckBox;
    FStatusPanelThemeCheck: TCheckBox;
    FStatusPanelLoadCheck: TCheckBox;
    FBackSpaceUnIndentsCheck: TCheckBox;
    FIndentationGuidesLabel: TLabel;
    FIndentationGuidesCombo: TComboBox;
    FWhiteSpaceStyleLabel: TLabel;
    FWhiteSpaceStyleCombo: TComboBox;
    FWhiteSpaceSizeLabel: TLabel;
    FWhiteSpaceSizeEdit: TSpinEdit;
    FUpperLineSpacingLabel: TLabel;
    FUpperLineSpacingEdit: TSpinEdit;
    FLowerLineSpacingLabel: TLabel;
    FLowerLineSpacingEdit: TSpinEdit;
    FSelectFullLineCheck: TCheckBox;
    FUseSelectionForeColorCheck: TCheckBox;
    FSelectionForeColorBox: TPanel;
    FSelectionAlphaLabel: TLabel;
    FSelectionAlphaEdit: TSpinEdit;
    FSmartHighlightStyleLabel: TLabel;
    FSmartHighlightStyleCombo: TComboBox;
    FSmartHighlightFillAlphaLabel: TLabel;
    FSmartHighlightFillAlphaEdit: TSpinEdit;
    FSmartHighlightOutlineAlphaLabel: TLabel;
    FSmartHighlightOutlineAlphaEdit: TSpinEdit;
    FWrapModeLabel: TLabel;
    FWrapModeCombo: TComboBox;
    FWrapFlagEndCheck: TCheckBox;
    FWrapFlagStartCheck: TCheckBox;
    FWrapFlagMarginCheck: TCheckBox;
    FWrapLocationEndCheck: TCheckBox;
    FWrapLocationStartCheck: TCheckBox;
    FCaretBeyondLineEndingsCheck: TCheckBox;
    FWrapCursorAtLineStartCheck: TCheckBox;
    FStickyCaretLabel: TLabel;
    FStickyCaretCombo: TComboBox;
    FMultiPasteCheck: TCheckBox;
    FPasteConvertEndingsCheck: TCheckBox;
    FFoldingLinesCheck: TCheckBox;
    FFoldingTextLabel: TLabel;
    FFoldingTextEdit: TEdit;
    FFoldDisplayTextStyleLabel: TLabel;
    FFoldDisplayTextStyleCombo: TComboBox;
    FFoldMarkerStyleLabel: TLabel;
    FFoldMarkerStyleCombo: TComboBox;
    FTabWidthLabel: TLabel;
    FTabWidthEdit: TSpinEdit;
    FFileSizeLimitLabel: TLabel;
    FFileSizeLimitEdit: TSpinEdit;
    FLineNumberingCheck: TCheckBox;
    FLineNumDynamicRadio: TRadioButton;
    FLineNumFixedRadio: TRadioButton;
    FLineNumPaddingLeftLabel: TLabel;
    FLineNumPaddingLeftEdit: TSpinEdit;
    FLineNumPaddingRightLabel: TLabel;
    FLineNumPaddingRightEdit: TSpinEdit;
    FTextPaddingLeftLabel: TLabel;
    FTextPaddingLeftEdit: TSpinEdit;
    FTextPaddingRightLabel: TLabel;
    FTextPaddingRightEdit: TSpinEdit;
    FBookmarkMarginCheck: TCheckBox;
    FFoldMarginCheck: TCheckBox;
    FLineWrappingCheck: TCheckBox;
    FGutterStyleLabel: TLabel;
    FGutterStyleCombo: TComboBox;
    FGutterForegroundLabel: TLabel;
    FGutterForegroundBox: TPanel;
    FGutterBackgroundLabel: TLabel;
    FGutterBackgroundBox: TPanel;
    FSearchSyncCheck: TCheckBox;
    FLogSection: TGroupBox;
    FLogEnabledCheck: TCheckBox;
    FLogSeverityPanel: TPanel;
    FLogSeverityLabel: TLabel;
    FLogSeverityCombo: TComboBox;
    FLogOutputPanel: TPanel;
    FLogOutputLabel: TLabel;
    FLogOutputCombo: TComboBox;
    FPrintMagnificationLabel: TLabel;
    FPrintMagnificationEdit: TSpinEdit;

    procedure BuildUi;
    procedure AddThemeDirectoryCandidate(const ABaseDirectory: string);
    procedure ApplyThemeSelection(const AThemeName: string);
    procedure DiscoverThemeDirectories;
    procedure LogLayoutHeightChange(const ASection: string; AHeight: Integer);
    procedure LogPairRowLayout(const ARow: string; ALeftWidth, ARightWidth: Integer);
    procedure LogThemeLoadTiming(const AThemeName: string; ACatalogMs,
      AReplaceMs, AUiMs: Int64);
    function MeasureCheckBoxWidth(ACheckBox: TCheckBox): Integer;
    function MeasureLabelColumnWidth: Integer;
    function MeasureSingleLineLabelHeight: Integer;
    function MeasureSingleLineLabelWidth(const ACaption: string): Integer;
    procedure RefreshSectionLayout;
    procedure SizeCheckBox(ACheckBox: TCheckBox);
    function NormalizeExtensions(const AText: string): string;
    function SelectedLanguage: TDSciVisualStyleGroup;
    function SelectedStyle: TDSciVisualStyleData;
    function SelectedGutterStyleName: string;
    function SelectedThemeName: string;
    function ResolveThemeFileName(const AThemeName: string): string;
    procedure LoadThemeList;
    procedure LoadLanguageList(const APreferredLanguage: string = '');
    procedure LoadStyleList(const APreferredStyle: string = '');
    procedure LoadMiscControls;
    procedure LoadSelectedGutterStyleControls;
    procedure LoadSelectedStyleControls;
    procedure RefreshCatalog(const APreferredLanguage: string = '';
      const APreferredStyle: string = '');
    procedure SyncMiscToConfig;
    procedure SyncSelectedGutterStyleToConfig;
    procedure SyncSelectedStyleToConfig;

    procedure ImportThemeButtonClick(Sender: TObject);
    procedure CategoryComboChange(Sender: TObject);
    procedure ThemeComboChange(Sender: TObject);
    procedure GutterStyleComboChange(Sender: TObject);
    procedure LanguageComboChange(Sender: TObject);
    procedure StyleComboChange(Sender: TObject);
    procedure StyleControlChange(Sender: TObject);
    procedure ColorPanelClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure ModelessFormClose(Sender: TObject; var Action: TCloseAction);
    class function Dpi: Integer; static;
    class function Scale(AValue: Integer): Integer; static;
  protected
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    // Force Desktop as owner window to prevent UIPI Code 5 when ShowModal is
    // called from a Low-IL COM preview handler. See TDSciGotoDialog.CreateParams.
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function ImportThemeFile(const ASourceFileName: string;
      AOverwriteExisting: Boolean): string;
    function EditSettings(const ASettingsDirectory, AConfigFileName: string;
      AConfig: TDSciVisualConfig): Boolean;
    procedure ShowSettingsModeless(const ASettingsDirectory, AConfigFileName: string;
      AConfig: TDSciVisualConfig);

    property OnApplyConfig: TDSciVisualConfigApplyEvent read FOnApplyConfig write FOnApplyConfig;
  end;

implementation

uses
  System.SysUtils, System.Math, System.IOUtils, System.UITypes,
  DScintillaDefaultConfig, DScintillaLogger, DScintillaTypes;

const
  cButtonWidth = 92;
  cButtonsPanelHeight = 48;
  cColorPreviewHeight = 24;
  cDialogPadding = 5;
  cFieldGap = 8;
  cHighlightPreviewWidth = 180;
  cImportThemeButtonWidth = 110;
  cInputHeight = 26;
  cLabelWidth = 160;
  cRowGap = 5;
  cSectionGap = 8;
  cSpinWidth = 92;

type
  TDSciVisualNamedStyle = class
  public
    Caption: string;
    Style: TDSciVisualStyleData;
  end;

  TCheckBoxAccess = class(TCheckBox);
  TGroupBoxAccess = class(TGroupBox);

procedure AddComboIntItem(ACombo: TComboBox; const ACaption: string; AValue: Integer);
begin
  ACombo.Items.AddObject(ACaption, TObject(NativeInt(AValue)));
end;

function ComboSelectedInt(ACombo: TComboBox; ADefault: Integer): Integer;
begin
  if (ACombo <> nil) and (ACombo.ItemIndex >= 0) and (ACombo.ItemIndex < ACombo.Items.Count) then
    Exit(NativeInt(ACombo.Items.Objects[ACombo.ItemIndex]));
  Result := ADefault;
end;

procedure SelectComboInt(ACombo: TComboBox; AValue: Integer);
var
  lIndex: Integer;
begin
  if ACombo = nil then
    Exit;

  for lIndex := 0 to ACombo.Items.Count - 1 do
    if NativeInt(ACombo.Items.Objects[lIndex]) = AValue then
    begin
      ACombo.ItemIndex := lIndex;
      Exit;
    end;
end;

class function TDSciVisualSettingsDialog.Dpi: Integer;
var
  lControl: TWinControl;
  lMonitor: VCL.Forms.TMonitor;
begin
  lControl := Screen.ActiveControl;
  if lControl = nil then
  begin
    if not Application.Active then
      lControl := Screen.ActiveForm
    else
      lControl := Screen.ActiveCustomForm;
  end;

  if lControl = nil then
    lControl := Application.MainForm;


  if Assigned(lControl) and lControl.HandleAllocated then // not ready.
  begin
    lMonitor := Screen.MonitorFromWindow(lControl.Handle);
  end
  else
    lMonitor := Screen.PrimaryMonitor;

  if not Assigned(lMonitor) then // last fallback..
    Result := Screen.PixelsPerInch
  else
    Result := lMonitor.PixelsPerInch;
end;

class function TDSciVisualSettingsDialog.Scale(AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, Dpi, 96);
end;

constructor TDSciVisualSettingsDialog.Create(AOwner: TComponent);
var
  lStream: TResourceStream;
begin
  inherited CreateNew(AOwner);
  FCatalog := TDSciVisualCatalog.Create;
  FConfig := TDSciVisualConfig.Create;
  FEmbeddedDefaultConfig := TDSciVisualConfig.Create;
  FThemeDirectories := TStringList.Create;
  FThemeDirectories.CaseSensitive := False;
  FThemeDirectories.Duplicates := dupIgnore;

  lStream := nil;
  try
    lStream := OpenDefaultConfigStream;
    FEmbeddedDefaultConfig.LoadFromStream(lStream);
  finally
    lStream.Free;
  end;

  DefaultMonitor := dmActiveForm;
  AutoScroll := False;
  BorderStyle := bsDialog;
  BorderIcons := [biSystemMenu];
  Caption := 'Editor Settings';
  KeyPreview := True;
  Position := poOwnerFormCenter;
  Scaled := False;
  Width := Scale(540);
  Height := Scale(540);
  Constraints.MinWidth := Scale(500);
  Constraints.MinHeight := Scale(480);

  BuildUi;
  RefreshSectionLayout;
end;

destructor TDSciVisualSettingsDialog.Destroy;
var
  lIndex: Integer;
begin
  for lIndex := 0 to FStyleCombo.Items.Count - 1 do
    FStyleCombo.Items.Objects[lIndex].Free;
  FThemeDirectories.Free;
  FEmbeddedDefaultConfig.Free;
  FCatalog.Free;
  FConfig.Free;
  inherited Destroy;
end;

procedure TDSciVisualSettingsDialog.AddThemeDirectoryCandidate(
  const ABaseDirectory: string);
var
  lThemeDirectory: string;
begin
  if Trim(ABaseDirectory) = '' then
    Exit;

  lThemeDirectory := ExpandFileName(TPath.Combine(ABaseDirectory, 'themes'));
  if not DirectoryExists(lThemeDirectory) then
    Exit;

  if FThemeDirectories.IndexOf(lThemeDirectory) < 0 then
    FThemeDirectories.Add(lThemeDirectory);
end;

procedure TDSciVisualSettingsDialog.DiscoverThemeDirectories;
begin
  FThemeDirectories.Clear;
  if Trim(FConfigFileName) <> '' then
    AddThemeDirectoryCandidate(ExtractFileDir(FConfigFileName));
end;

function TDSciVisualSettingsDialog.ResolveThemeFileName(
  const AThemeName: string): string;
var
  lCandidate: string;
  lThemeDirectory: string;
  lThemeName: string;
begin
  Result := '';
  lThemeName := Trim(AThemeName);
  if lThemeName = '' then
    Exit;

  if FileExists(lThemeName) then
    Exit(ExpandFileName(lThemeName));

  for lThemeDirectory in FThemeDirectories do
  begin
    lCandidate := TPath.Combine(lThemeDirectory, lThemeName);
    if FileExists(lCandidate) then
      Exit(ExpandFileName(lCandidate));

    if ExtractFileExt(lCandidate) = '' then
    begin
      lCandidate := lCandidate + '.xml';
      if FileExists(lCandidate) then
        Exit(ExpandFileName(lCandidate));
    end;
  end;

  raise EFileNotFoundException.CreateFmt('Theme file not found: %s', [AThemeName]);
end;

function TDSciVisualSettingsDialog.ImportThemeFile(const ASourceFileName: string;
  AOverwriteExisting: Boolean): string;
var
  lSourceFileName: string;
  lTargetDirectory: string;
  lTargetFileName: string;
  lThemeModel: TDSciVisualStyleModel;
begin
  lSourceFileName := ExpandFileName(Trim(ASourceFileName));
  if lSourceFileName = '' then
    raise EArgumentException.Create('ASourceFileName must not be empty.');
  if not FileExists(lSourceFileName) then
    raise EFileNotFoundException.CreateFmt('Theme file not found: %s', [ASourceFileName]);
  if Trim(FConfigFileName) = '' then
    raise EInvalidOpException.Create('Theme import requires a config file location.');

  lThemeModel := LoadThemeStyleModelFromFile(lSourceFileName);
  try
    if lThemeModel.Groups.Count = 0 then
      raise EInvalidOpException.Create('Selected XML file does not contain any theme styles.');
  finally
    lThemeModel.Free;
  end;

  lTargetDirectory := ExpandFileName(TPath.Combine(ExtractFileDir(FConfigFileName), 'themes'));
  ForceDirectories(lTargetDirectory);
  lTargetFileName := TPath.Combine(lTargetDirectory, ExtractFileName(lSourceFileName));

  if SameText(lSourceFileName, lTargetFileName) then
    Exit(ChangeFileExt(ExtractFileName(lTargetFileName), ''));

  if FileExists(lTargetFileName) and not AOverwriteExisting then
    raise EAbort.CreateFmt('Theme file already exists: %s', [ExtractFileName(lTargetFileName)]);

  TFile.Copy(lSourceFileName, lTargetFileName, True);
  Result := ChangeFileExt(ExtractFileName(lTargetFileName), '');
end;

procedure TDSciVisualSettingsDialog.ApplyThemeSelection(const AThemeName: string);
var
  lThemeModel: TDSciVisualStyleModel;
begin
  if Trim(AThemeName) = '' then
  begin
    FConfig.ReplaceStyleModel(FEmbeddedDefaultConfig.StyleOverrides, True);
    FConfig.ThemeName := '';
    Exit;
  end;

  lThemeModel := LoadThemeStyleModelFromFile(ResolveThemeFileName(AThemeName));
  try
    FConfig.ReplaceStyleModel(lThemeModel, True);
    FConfig.ThemeName := Trim(AThemeName);
  finally
    lThemeModel.Free;
  end;
end;

procedure TDSciVisualSettingsDialog.ImportThemeButtonClick(Sender: TObject);
var
  lTargetDirectory: string;
  lTargetFileName: string;
  lThemeName: string;
begin
  if not FOpenThemeDialog.Execute(Handle) then
    Exit;

  try
    lTargetDirectory := ExpandFileName(TPath.Combine(ExtractFileDir(FConfigFileName), 'themes'));
    lTargetFileName := TPath.Combine(lTargetDirectory,
      ExtractFileName(FOpenThemeDialog.FileName));

    if FileExists(lTargetFileName) and
       not SameText(ExpandFileName(FOpenThemeDialog.FileName), lTargetFileName) and
       (MessageDlg(Format('Theme "%s" already exists. Overwrite it?',
          [ExtractFileName(lTargetFileName)]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then
      Exit;

    lThemeName := ImportThemeFile(FOpenThemeDialog.FileName, True);
    LoadThemeList;

    if FThemeCombo.Items.IndexOf(lThemeName) >= 0 then
    begin
      FThemeCombo.ItemIndex := FThemeCombo.Items.IndexOf(lThemeName);
      ThemeComboChange(FThemeCombo);
    end;
  except
    on EAbort do
      Exit;
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TDSciVisualSettingsDialog.CategoryComboChange(Sender: TObject);
begin
  if FCardPanel = nil then
    Exit;

  if (FCategoryCombo <> nil) and (FCategoryCombo.ItemIndex >= 0) and
     (FCategoryCombo.ItemIndex < FCategoryCombo.Items.Count) then
    FCardPanel.ActiveCard := TCard(FCategoryCombo.Items.Objects[FCategoryCombo.ItemIndex])
  else
    FCardPanel.ActiveCard := FStyleCard;

  RefreshSectionLayout;
end;

procedure TDSciVisualSettingsDialog.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  RefreshSectionLayout;
end;

procedure TDSciVisualSettingsDialog.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if not (csDesigning in ComponentState) then
    Params.WndParent := GetDesktopWindow;
end;

procedure TDSciVisualSettingsDialog.CreateWnd;
begin
  inherited CreateWnd;
  RefreshSectionLayout;
end;

procedure TDSciVisualSettingsDialog.Resize;
begin
  inherited Resize;
  RefreshSectionLayout;
end;

procedure TDSciVisualSettingsDialog.LogLayoutHeightChange(const ASection:
    string; AHeight: Integer);
begin
{$IFDEF DEBUG}
  DSciLog(Format('TDSciVisualSettingsDialog %s height=%d',
    [ASection, AHeight]), cDSciLogDebug);
{$ENDIF}
end;

procedure TDSciVisualSettingsDialog.LogPairRowLayout(const ARow: string;
  ALeftWidth, ARightWidth: Integer);
begin
{$IFDEF DEBUG}
  DSciLog(Format(
    'TDSciVisualSettingsDialog %s leftWidth=%d rightWidth=%d',
    [ARow, ALeftWidth, ARightWidth]), cDSciLogDebug);
{$ENDIF}
end;

procedure TDSciVisualSettingsDialog.LogThemeLoadTiming(const AThemeName: string;
  ACatalogMs, AReplaceMs, AUiMs: Int64);
{$IFDEF DEBUG}
var
  lThemeName: string;
{$ENDIF}
begin
{$IFDEF DEBUG}
  if Trim(AThemeName) = '' then
    lThemeName := '(Base styles)'
  else
    lThemeName := AThemeName;
  DSciLog(Format(
    'TDSciVisualSettingsDialog theme="%s" catalog=%dms replace=%dms ui=%dms total=%dms',
    [lThemeName, ACatalogMs, AReplaceMs, AUiMs, ACatalogMs + AReplaceMs + AUiMs]),
    cDSciLogDebug);
{$ENDIF}
end;

function TDSciVisualSettingsDialog.MeasureSingleLineLabelHeight: Integer;
begin
  Canvas.Font.Assign(Font);
  Result := Max(Scale(17), Canvas.TextHeight('Hg'));
end;

function TDSciVisualSettingsDialog.MeasureSingleLineLabelWidth(const ACaption:
    string): Integer;
begin
  Canvas.Font.Assign(Font);
  Result := Canvas.TextWidth(ACaption);
end;

function TDSciVisualSettingsDialog.MeasureLabelColumnWidth: Integer;
begin
  Result := Scale(cLabelWidth);
  Result := Max(Result, MeasureSingleLineLabelWidth('Category'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Theme'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Language'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Extensions'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Style'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Font name'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Font size'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Foreground'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Background'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Highlight color'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Transparency'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Outline'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Indentation guide style'));
  Result := Max(Result, MeasureSingleLineLabelWidth('White space style'));
  Result := Max(Result, MeasureSingleLineLabelWidth('White space size'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Upper line spacing'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Lower line spacing'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Selection alpha'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Highlighting style'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Filling alpha'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Outline alpha'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Wrap mode'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Gutter style'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Sticky caret mode'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Folding text'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Folding text style'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Fold marker style'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Magnification'));
  Result := Max(Result, MeasureSingleLineLabelWidth('Tab width'));
  Result := Max(Result, MeasureSingleLineLabelWidth('File size limit'));
  Inc(Result, Scale(cFieldGap));
end;

function TDSciVisualSettingsDialog.MeasureCheckBoxWidth(ACheckBox: TCheckBox):
    Integer;
begin
  Canvas.Font.Assign(ACheckBox.Font);
  Result := Canvas.TextWidth(ACheckBox.Caption) + Scale(24);
end;

procedure TDSciVisualSettingsDialog.SizeCheckBox(ACheckBox: TCheckBox);
begin
  if ACheckBox = nil then
    Exit;

  Canvas.Font.Assign(ACheckBox.Font);
  TCheckBoxAccess(ACheckBox).AutoSize := False;
  ACheckBox.Width := MeasureCheckBoxWidth(ACheckBox);
  ACheckBox.Height := Max(Scale(cInputHeight), Canvas.TextHeight('Hg') + Scale(8));
end;

procedure TDSciVisualSettingsDialog.RefreshSectionLayout;
var
  lActiveCard: TCard;
  lButtonHeight: Integer;
  lCardClientHeight: Integer;
  lCardClientWidth: Integer;
  lCardContentHeight: Integer;
  lCheckHeight: Integer;
  lCheckTop: Integer;
  lContentNonClientHeight: Integer;
  lContentLeft: Integer;
  lContentWidth: Integer;
  lDialogClientWidth: Integer;
  lFieldWidth: Integer;
  lFormClientHeight: Integer;
  lGroupNonClientWidth: Integer;
  lInnerTop: Integer;
  lLabelHeight: Integer;
  lLabelTop: Integer;
  lLabelWidth: Integer;
  lNeededContentHeight: Integer;
  lOuterPadding: Integer;
  lOptionPairLabelWidth: Integer;
  lRowHeight: Integer;
  lSectionHorizontalPadding: Integer;
  lSectionClientWidth: Integer;
  lSectionContentRect: TRect;
  lSectionTop: Integer;
  lSectionWidth: Integer;

  function MeasureStackHeight(AStack: TStackPanel): Integer;
  var
    lChild: TControl;
    lControlIndex: Integer;
  begin
    Result := 0;
    if AStack = nil then
      Exit;

    for lControlIndex := 0 to AStack.ControlCount - 1 do
    begin
      lChild := AStack.Controls[lControlIndex];
      if lChild.Visible then
        Result := Max(Result, lChild.Top + lChild.Height);
    end;
  end;

  function MeasureControlTextWidth(const AText: string): Integer;
  begin
    Canvas.Font.Assign(Font);
    Result := Canvas.TextWidth(AText);
  end;

  function MeasureComboDisplayWidth(ACombo: TComboBox; AMinWidth,
    AMaxWidth: Integer): Integer;
  var
    lIndex: Integer;
    lTextWidth: Integer;
  begin
    lTextWidth := MeasureControlTextWidth(ACombo.Text);
    for lIndex := 0 to ACombo.Items.Count - 1 do
      lTextWidth := Max(lTextWidth, MeasureControlTextWidth(ACombo.Items[lIndex]));
    Result := EnsureRange(lTextWidth + Scale(36), AMinWidth, AMaxWidth);
  end;

  function MeasureEditDisplayWidth(AEdit: TCustomEdit; AMinWidth,
    AMaxWidth: Integer): Integer;
  var
    lText: string;
  begin
    lText := Trim(AEdit.Text);
    if lText = '' then
      lText := '*';
    Result := EnsureRange(MeasureControlTextWidth(lText) + Scale(24),
      AMinWidth, AMaxWidth);
  end;

  function MeasureDesiredClientWidth: Integer;
  var
    lButtonsWidth: Integer;
    lChecksWidth: Integer;
    lFieldDisplayWidth: Integer;
    lPairedControlWidth: Integer;
    lPairedRowWidth: Integer;
    lSingleRowWidth: Integer;
  begin
    lFieldDisplayWidth := Scale(cHighlightPreviewWidth);
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FThemeCombo, Scale(180), Scale(260)) +
      Scale(cFieldGap) + Scale(cImportThemeButtonWidth));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FCategoryCombo, Scale(180), Scale(280)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FTechnologyCombo, Scale(180), Scale(300)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FFontQualityCombo, Scale(180), Scale(280)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureEditDisplayWidth(FFontLocaleEdit, Scale(120), Scale(180)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FLanguageCombo, Scale(180), Scale(260)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureEditDisplayWidth(FExtensionsEdit, Scale(120), Scale(180)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FStyleCombo, Scale(220), Scale(320)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FFontNameCombo, Scale(180), Scale(280)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FIndentationGuidesCombo, Scale(180), Scale(280)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FWhiteSpaceStyleCombo, Scale(180), Scale(280)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FSmartHighlightStyleCombo, Scale(220), Scale(320)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FWrapModeCombo, Scale(180), Scale(280)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FGutterStyleCombo, Scale(180), Scale(240)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FStickyCaretCombo, Scale(180), Scale(240)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FFoldDisplayTextStyleCombo, Scale(180), Scale(240)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth,
      MeasureComboDisplayWidth(FFoldMarkerStyleCombo, Scale(180), Scale(240)));
    lFieldDisplayWidth := Max(lFieldDisplayWidth, Scale(cSpinWidth));

    lSingleRowWidth := lLabelWidth + Scale(cFieldGap) + lFieldDisplayWidth;

    lPairedControlWidth := Max(Scale(120), Scale(cSpinWidth));
    lPairedRowWidth := ((lOptionPairLabelWidth + Scale(cFieldGap) +
      lPairedControlWidth) * 2) + Scale(cFieldGap * 2);

    lChecksWidth := FBoldCheck.Width + FItalicCheck.Width + FUnderlineCheck.Width +
      Scale(cFieldGap * 4);
    lChecksWidth := Max(lChecksWidth,
      Max(FLineNumberingCheck.Width, FBookmarkMarginCheck.Width));
    lChecksWidth := Max(lChecksWidth, FFoldMarginCheck.Width);
    lChecksWidth := Max(lChecksWidth, FSearchSyncCheck.Width);
    lChecksWidth := Max(lChecksWidth, FLogEnabledCheck.Width);
    lChecksWidth := Max(lChecksWidth, FShowStatusBarCheck.Width);
    lChecksWidth := Max(lChecksWidth, FStatusPanelFileCheck.Width +
      FStatusPanelPosCheck.Width + FStatusPanelLexerCheck.Width + Scale(cFieldGap * 4));
    lChecksWidth := Max(lChecksWidth, FBackSpaceUnIndentsCheck.Width);
    lChecksWidth := Max(lChecksWidth, FSelectFullLineCheck.Width);
    lChecksWidth := Max(lChecksWidth, FUseSelectionForeColorCheck.Width + Scale(60));
    lChecksWidth := Max(lChecksWidth, FCaretBeyondLineEndingsCheck.Width);
    lChecksWidth := Max(lChecksWidth, FWrapCursorAtLineStartCheck.Width);
    lChecksWidth := Max(lChecksWidth, FMultiPasteCheck.Width);
    lChecksWidth := Max(lChecksWidth, FPasteConvertEndingsCheck.Width);
    lChecksWidth := Max(lChecksWidth, FFoldingLinesCheck.Width);
    lChecksWidth := Max(lChecksWidth, FWrapFlagEndCheck.Width);
    lChecksWidth := Max(lChecksWidth, FWrapFlagStartCheck.Width);
    lChecksWidth := Max(lChecksWidth, FWrapFlagMarginCheck.Width);
    lChecksWidth := Max(lChecksWidth, FWrapLocationEndCheck.Width);
    lChecksWidth := Max(lChecksWidth, FWrapLocationStartCheck.Width);

    lSectionClientWidth := Max(lSingleRowWidth, lPairedRowWidth);
    lSectionClientWidth := Max(lSectionClientWidth, lChecksWidth);
    Inc(lSectionClientWidth, Scale(cDialogPadding * 2) + lGroupNonClientWidth);

    lButtonsWidth := (Scale(cButtonWidth) * 2) + Scale(cFieldGap) +
      Scale(cDialogPadding * 2);

    Result := Max(lSectionClientWidth, lButtonsWidth);
    Result := Max(Result, lSingleRowWidth + (lOuterPadding * 2));
    Result := Max(Result, Scale(620));
  end;

  procedure LayoutButtons;
  var
    lRight: Integer;
    lTop: Integer;
  begin
    FButtonsPanel.Height := Scale(cButtonsPanelHeight);
    lButtonHeight := Max(FOkButton.Height, Scale(cInputHeight + 4));
    lTop := Max(Scale(cDialogPadding), (FButtonsPanel.ClientHeight - lButtonHeight) div 2);
    lRight := FButtonsPanel.ClientWidth - Scale(cDialogPadding);

    FOkButton.SetBounds(lRight - Scale(cButtonWidth), lTop,
      Scale(cButtonWidth), lButtonHeight);
    lRight := FOkButton.Left - Scale(cFieldGap);
    FCancelButton.SetBounds(lRight - Scale(cButtonWidth), lTop,
      Scale(cButtonWidth), lButtonHeight);
  end;

  procedure LayoutLabeledRow(ARow: TPanel; ALabel: TLabel; AFieldHost: TPanel;
    var ATop: Integer; AFieldHeight: Integer);
  var
    lRowLabelHeight: Integer;
  begin
    lRowLabelHeight := MeasureSingleLineLabelHeight;
    lRowHeight := Max(AFieldHeight, lRowLabelHeight);
    ARow.SetBounds(lContentLeft, ATop, lContentWidth, lRowHeight);

    TPanel(ALabel.Parent).SetBounds(0, 0, lLabelWidth, lRowHeight);
    ALabel.SetBounds(0, Max(0, (lRowHeight - lRowLabelHeight) div 2),
      lLabelWidth, lRowLabelHeight);

    AFieldHost.SetBounds(lLabelWidth + Scale(cFieldGap),
      Max(0, (lRowHeight - AFieldHeight) div 2), lFieldWidth, AFieldHeight);

    ATop := ATop + lRowHeight + Scale(cRowGap);
  end;

  procedure LayoutPairedRow(ARow: TPanel; ALeftLabel, ARightLabel: TLabel;
    ALeftControl, ARightControl: TControl; var ATop: Integer; AControlHeight,
    ALeftDesiredWidth, ARightDesiredWidth: Integer);
  var
    lAvailableFieldWidth: Integer;
    lControlTop: Integer;
    lLeftControlWidth: Integer;
    lPairGap: Integer;
    lPairWidth: Integer;
    lRightColumnLeft: Integer;
    lRightControlWidth: Integer;
  begin
    lPairGap := Scale(cFieldGap * 2);
    lPairWidth := Max(0, (lContentWidth - lPairGap) div 2);
    lAvailableFieldWidth := Max(0,
      lPairWidth - lOptionPairLabelWidth - Scale(cFieldGap));
    lRowHeight := Max(AControlHeight, lLabelHeight);
    ARow.SetBounds(lContentLeft, ATop, lContentWidth, lRowHeight);

    lLabelTop := Max(0, (lRowHeight - lLabelHeight) div 2);
    lControlTop := Max(0, (lRowHeight - AControlHeight) div 2);

    ALeftLabel.SetBounds(0, lLabelTop, lOptionPairLabelWidth, lLabelHeight);
    if ALeftDesiredWidth > 0 then
      lLeftControlWidth := Min(ALeftDesiredWidth, lAvailableFieldWidth)
    else
      lLeftControlWidth := lAvailableFieldWidth;
    ALeftControl.SetBounds(lOptionPairLabelWidth + Scale(cFieldGap), lControlTop,
      lLeftControlWidth, AControlHeight);

    lRightColumnLeft := lPairWidth + lPairGap;
    ARightLabel.SetBounds(lRightColumnLeft, lLabelTop, lOptionPairLabelWidth, lLabelHeight);
    if ARightDesiredWidth > 0 then
      lRightControlWidth := Min(ARightDesiredWidth, lAvailableFieldWidth)
    else
      lRightControlWidth := lAvailableFieldWidth;
    ARightControl.SetBounds(
      lRightColumnLeft + lOptionPairLabelWidth + Scale(cFieldGap),
      lControlTop, lRightControlWidth, AControlHeight);

    ATop := ATop + lRowHeight + Scale(cRowGap);
  end;

  procedure BeginGroupLayout(ASection: TGroupBox; AStack: TStackPanel;
    ATop: Integer; out ASectionClientWidth: Integer; out ABottomInset: Integer);
  begin
    ASection.Width := lSectionWidth;
    ASection.SetBounds(0, ATop, lSectionWidth, Max(ASection.Height, Scale(96)));
    lSectionContentRect := ASection.ClientRect;
    TGroupBoxAccess(ASection).AdjustClientRect(lSectionContentRect);
    ASectionClientWidth := Max(0, (lSectionContentRect.Right - lSectionContentRect.Left) -
      (lSectionHorizontalPadding * 2));
    ABottomInset := Max(Scale(cDialogPadding),
      (ASection.ClientHeight - lSectionContentRect.Bottom) + Scale(cDialogPadding));
    AStack.SetBounds(lSectionContentRect.Left + lSectionHorizontalPadding,
      lSectionContentRect.Top + Scale(cDialogPadding), ASectionClientWidth,
      Max(AStack.Height, Scale(cInputHeight)));
    AStack.Realign;
  end;

  function ActiveSettingsCard: TCard;
  begin
    Result := nil;
    if (FCategoryCombo <> nil) and (FCategoryCombo.ItemIndex >= 0) and
       (FCategoryCombo.ItemIndex < FCategoryCombo.Items.Count) then
      Result := TCard(FCategoryCombo.Items.Objects[FCategoryCombo.ItemIndex]);
    if Result = nil then
      Result := FGeneralCard;
  end;

  function MeasureVisibleChildBottom(AParent: TWinControl): Integer;
  var
    lChildIndex: Integer;
    lControl: TControl;
  begin
    Result := 0;
    if AParent = nil then
      Exit;
    for lChildIndex := 0 to AParent.ControlCount - 1 do
    begin
      lControl := AParent.Controls[lChildIndex];
      if lControl.Visible then
        Result := Max(Result, lControl.Top + lControl.Height);
    end;
  end;

  function SectionStack(ASection: TGroupBox): TStackPanel;
  begin
    Result := nil;
    if (ASection <> nil) and (ASection.ControlCount > 0) and
       (ASection.Controls[0] is TStackPanel) then
      Result := TStackPanel(ASection.Controls[0]);
  end;

  procedure PrepareSection(ASection: TGroupBox; out AContentRect: TRect;
    out ASectionClientWidth: Integer; out ABottomInset: Integer);
  begin
    ASection.Width := lSectionWidth;
    if ASection.Height < Scale(72) then
      ASection.Height := Scale(72);
    AContentRect := ASection.ClientRect;
    TGroupBoxAccess(ASection).AdjustClientRect(AContentRect);
    ASectionClientWidth := Max(0, (AContentRect.Right - AContentRect.Left) -
      (lSectionHorizontalPadding * 2));
    ABottomInset := Max(Scale(cDialogPadding),
      (ASection.ClientHeight - AContentRect.Bottom) + Scale(cDialogPadding));
  end;

  procedure LayoutCheckRow(ARow: TPanel; ACheckBox: TCheckBox; var ATop: Integer);
  begin
    lRowHeight := Max(Scale(cInputHeight), ACheckBox.Height);
    ARow.SetBounds(lContentLeft, ATop, lContentWidth, lRowHeight);
    ACheckBox.Align := alNone;
    ACheckBox.SetBounds(0, Max(0, (lRowHeight - ACheckBox.Height) div 2),
      ACheckBox.Width, ACheckBox.Height);
    ATop := ATop + lRowHeight + Scale(cRowGap);
  end;

  procedure LayoutSelectionColorRow(ARow: TPanel; ACheckBox: TCheckBox;
    APreview: TPanel; var ATop: Integer);
  var
    lPreviewHeight: Integer;
    lPreviewLeft: Integer;
  begin
    lPreviewHeight := Scale(cColorPreviewHeight);
    lRowHeight := Max(lPreviewHeight, ACheckBox.Height);
    ARow.SetBounds(lContentLeft, ATop, lContentWidth, lRowHeight);
    ACheckBox.Align := alNone;
    ACheckBox.SetBounds(0, Max(0, (lRowHeight - ACheckBox.Height) div 2),
      ACheckBox.Width, ACheckBox.Height);
    lPreviewLeft := Min(Max(0, lContentWidth - Scale(56)),
      ACheckBox.Left + ACheckBox.Width + Scale(cFieldGap));
    APreview.SetBounds(lPreviewLeft, Max(0, (lRowHeight - lPreviewHeight) div 2),
      Min(Scale(52), Max(0, lContentWidth - lPreviewLeft)), lPreviewHeight);
    ATop := ATop + lRowHeight + Scale(cRowGap);
  end;

  procedure LayoutDualCheckRow(ARow: TPanel; ALeftCheck, ARightCheck: TCheckBox;
    var ATop: Integer);
  var
    lRightLeft: Integer;
  begin
    lRowHeight := Max(ALeftCheck.Height, ARightCheck.Height);
    ARow.SetBounds(lContentLeft, ATop, lContentWidth, lRowHeight);

    ALeftCheck.Align := alNone;
    ALeftCheck.SetBounds(0, Max(0, (lRowHeight - ALeftCheck.Height) div 2),
      ALeftCheck.Width, ALeftCheck.Height);

    if ARightCheck.Visible then
    begin
      ARightCheck.Align := alNone;
      lRightLeft := ALeftCheck.Left + ALeftCheck.Width + Scale(cFieldGap * 2);
      ARightCheck.SetBounds(lRightLeft,
        Max(0, (lRowHeight - ARightCheck.Height) div 2),
        ARightCheck.Width, ARightCheck.Height);
    end;

    ATop := ATop + lRowHeight + Scale(cRowGap);
  end;

  procedure LayoutCurrentCard;
  var
    lBottomInset: Integer;
    lCardTop: Integer;
    lSectionStack: TStackPanel;
  begin
    lCardTop := 0;

    if lActiveCard = FGeneralCard then
    begin
      lSectionStack := SectionStack(FMiscSection);
      if lSectionStack <> nil then
      begin
        PrepareSection(FMiscSection, lSectionContentRect, lSectionClientWidth, lBottomInset);
        lContentLeft := 0;
        lContentWidth := lSectionClientWidth;
        lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
        lInnerTop := 0;
        lSectionStack.SetBounds(lSectionContentRect.Left + lSectionHorizontalPadding,
          lSectionContentRect.Top + Scale(cDialogPadding), lSectionClientWidth,
          Max(lSectionStack.Height, Scale(cInputHeight)));

        LayoutLabeledRow(FTechnologyPanel, FTechnologyLabel, TPanel(FTechnologyCombo.Parent),
          lInnerTop, Scale(cInputHeight));
        FTechnologyCombo.SetBounds(0, 0, TPanel(FTechnologyCombo.Parent).ClientWidth,
          Scale(cInputHeight));

        LayoutLabeledRow(FFontQualityPanel, FFontQualityLabel,
          TPanel(FFontQualityCombo.Parent), lInnerTop, Scale(cInputHeight));
        FFontQualityCombo.SetBounds(0, 0, TPanel(FFontQualityCombo.Parent).ClientWidth,
          Scale(cInputHeight));

        LayoutLabeledRow(FFontLocalePanel, FFontLocaleLabel, TPanel(FFontLocaleEdit.Parent),
          lInnerTop, Scale(cInputHeight));
        FFontLocaleEdit.SetBounds(0, 0, TPanel(FFontLocaleEdit.Parent).ClientWidth,
          Scale(cInputHeight));

        lSectionStack.Height := MeasureStackHeight(lSectionStack);
        FMiscSection.Height := lSectionStack.Top + lSectionStack.Height + lBottomInset;
      end;

      { Line numbering section }
      lSectionStack := SectionStack(FLineNumberingSection);
      if lSectionStack <> nil then
      begin
        lCardTop := FMiscSection.Top + FMiscSection.Height + Scale(cRowGap);
        BeginGroupLayout(FLineNumberingSection, lSectionStack, lCardTop, lSectionClientWidth,
          lBottomInset);
        lContentLeft := 0;
        lContentWidth := lSectionClientWidth;
        lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
        lInnerTop := 0;

        LayoutCheckRow(TPanel(FLineNumberingCheck.Parent), FLineNumberingCheck, lInnerTop);

        lRowHeight := Max(Scale(cInputHeight), FLineNumDynamicRadio.Height);
        TPanel(FLineNumDynamicRadio.Parent).SetBounds(lContentLeft, lInnerTop,
          lContentWidth, lRowHeight);
        FLineNumDynamicRadio.Align := alNone;
        FLineNumDynamicRadio.SetBounds(0, Max(0, (lRowHeight - FLineNumDynamicRadio.Height) div 2),
          FLineNumDynamicRadio.Width, FLineNumDynamicRadio.Height);
        FLineNumFixedRadio.Align := alNone;
        FLineNumFixedRadio.SetBounds(FLineNumDynamicRadio.Left + FLineNumDynamicRadio.Width +
          Scale(cFieldGap * 2), Max(0, (lRowHeight - FLineNumFixedRadio.Height) div 2),
          FLineNumFixedRadio.Width, FLineNumFixedRadio.Height);
        Inc(lInnerTop, lRowHeight + Scale(cRowGap));

        LayoutLabeledRow(TPanel(FLineNumPaddingLeftEdit.Parent.Parent),
          FLineNumPaddingLeftLabel, TPanel(FLineNumPaddingLeftEdit.Parent),
          lInnerTop, Scale(cInputHeight));
        FLineNumPaddingLeftEdit.SetBounds(0, 0,
          TPanel(FLineNumPaddingLeftEdit.Parent).ClientWidth, Scale(cInputHeight));

        LayoutLabeledRow(TPanel(FLineNumPaddingRightEdit.Parent.Parent),
          FLineNumPaddingRightLabel, TPanel(FLineNumPaddingRightEdit.Parent),
          lInnerTop, Scale(cInputHeight));
        FLineNumPaddingRightEdit.SetBounds(0, 0,
          TPanel(FLineNumPaddingRightEdit.Parent).ClientWidth, Scale(cInputHeight));

        lSectionStack.Height := MeasureStackHeight(lSectionStack);
        FLineNumberingSection.Height := lSectionStack.Top + lSectionStack.Height + lBottomInset;
      end;

      { Logging section }
      lSectionStack := SectionStack(FLogSection);
      if lSectionStack <> nil then
      begin
        lCardTop := FLineNumberingSection.Top + FLineNumberingSection.Height + Scale(cRowGap);
        BeginGroupLayout(FLogSection, lSectionStack, lCardTop, lSectionClientWidth,
          lBottomInset);
        lContentLeft := 0;
        lContentWidth := lSectionClientWidth;
        lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
        lInnerTop := 0;

        FLogEnabledCheck.SetBounds(lContentLeft, lInnerTop,
          FLogEnabledCheck.Width, Scale(cInputHeight));
        Inc(lInnerTop, Scale(cInputHeight) + Scale(cRowGap));

        LayoutLabeledRow(FLogSeverityPanel, FLogSeverityLabel, TPanel(FLogSeverityCombo.Parent),
          lInnerTop, Scale(cInputHeight));
        FLogSeverityCombo.SetBounds(0, 0, TPanel(FLogSeverityCombo.Parent).ClientWidth,
          Scale(cInputHeight));

        LayoutLabeledRow(FLogOutputPanel, FLogOutputLabel, TPanel(FLogOutputCombo.Parent),
          lInnerTop, Scale(cInputHeight));
        FLogOutputCombo.SetBounds(0, 0, TPanel(FLogOutputCombo.Parent).ClientWidth,
          Scale(cInputHeight));

        lSectionStack.Height := MeasureStackHeight(lSectionStack);
        FLogSection.Height := lSectionStack.Top + lSectionStack.Height + lBottomInset;
      end;

      Exit;
    end;

    if lActiveCard = FStyleCard then
    begin
      lContentLeft := 0;
      lContentWidth := lSectionWidth;
      lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
      lInnerTop := 0;

      LayoutLabeledRow(FThemePanel, FThemeLabel, TPanel(FThemeCombo.Parent),
        lInnerTop, Scale(cInputHeight));
      FThemeImportButton.SetBounds(
        Max(0, TPanel(FThemeCombo.Parent).ClientWidth - Scale(cImportThemeButtonWidth)),
        0, Min(Scale(cImportThemeButtonWidth), TPanel(FThemeCombo.Parent).ClientWidth),
        Scale(cInputHeight));
      FThemeCombo.SetBounds(0, 0,
        Max(0, FThemeImportButton.Left - Scale(cFieldGap)),
        Scale(cInputHeight));

      lCardTop := lInnerTop;
      BeginGroupLayout(FStyleSection, FStyleStack, lCardTop, lSectionClientWidth,
        lBottomInset);
      lContentLeft := 0;
      lContentWidth := lSectionClientWidth;
      lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
      lInnerTop := 0;

      LayoutLabeledRow(FLanguagePanel, FLanguageLabel, TPanel(FLanguageCombo.Parent),
        lInnerTop, Scale(cInputHeight));
      FLanguageCombo.SetBounds(0, 0, TPanel(FLanguageCombo.Parent).ClientWidth,
        Scale(cInputHeight));

      LayoutLabeledRow(FExtensionsPanel, FExtensionsLabel, TPanel(FExtensionsEdit.Parent),
        lInnerTop, Scale(cInputHeight));
      FExtensionsEdit.SetBounds(0, 0, TPanel(FExtensionsEdit.Parent).ClientWidth,
        Scale(cInputHeight));

      LayoutLabeledRow(FStylePanel, FStyleLabel, TPanel(FStyleCombo.Parent),
        lInnerTop, Scale(cInputHeight));
      FStyleCombo.SetBounds(0, 0, TPanel(FStyleCombo.Parent).ClientWidth,
        Scale(cInputHeight));

      LayoutLabeledRow(FFontNamePanel, FFontNameLabel, TPanel(FFontNameCombo.Parent),
        lInnerTop, Scale(cInputHeight));
      FFontNameCombo.SetBounds(0, 0, TPanel(FFontNameCombo.Parent).ClientWidth,
        Scale(cInputHeight));

      LayoutLabeledRow(FFontSizePanel, FFontSizeLabel, TPanel(FFontSizeEdit.Parent),
        lInnerTop, Scale(cInputHeight));
      FFontSizeEdit.SetBounds(0, 0, Scale(cSpinWidth), Scale(cInputHeight));

      LayoutPairedRow(FStyleColorsRow, FForegroundLabel, FBackgroundLabel,
        FForegroundBox, FBackgroundBox, lInnerTop, Scale(cColorPreviewHeight), 0, 0);
      LogPairRowLayout('Style Colors', FForegroundBox.Width, FBackgroundBox.Width);

      lCheckHeight := Max(FBoldCheck.Height, Max(FItalicCheck.Height, FUnderlineCheck.Height));
      FFontStylesRow.SetBounds(lContentLeft, lInnerTop, lContentWidth, lCheckHeight);
      lCheckTop := Max(0, (lCheckHeight - FBoldCheck.Height) div 2);
      FBoldCheck.SetBounds(0, lCheckTop, FBoldCheck.Width, FBoldCheck.Height);
      FItalicCheck.SetBounds(FBoldCheck.Left + FBoldCheck.Width + Scale(cFieldGap * 2),
        Max(0, (lCheckHeight - FItalicCheck.Height) div 2),
        FItalicCheck.Width, FItalicCheck.Height);
      FUnderlineCheck.SetBounds(FItalicCheck.Left + FItalicCheck.Width +
        Scale(cFieldGap * 2),
        Max(0, (lCheckHeight - FUnderlineCheck.Height) div 2),
        FUnderlineCheck.Width, FUnderlineCheck.Height);

      FStyleStack.Height := MeasureStackHeight(FStyleStack);
      FStyleSection.Height := FStyleStack.Top + FStyleStack.Height + lBottomInset;
      Exit;
    end;

    if lActiveCard = FEditorCard then
    begin
      lSectionStack := SectionStack(FEditorSection);
      if lSectionStack <> nil then
      begin
        PrepareSection(FEditorSection, lSectionContentRect, lSectionClientWidth, lBottomInset);
        lContentLeft := 0;
        lContentWidth := lSectionClientWidth;
        lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
        lInnerTop := 0;
        lSectionStack.SetBounds(lSectionContentRect.Left + lSectionHorizontalPadding,
          lSectionContentRect.Top + Scale(cDialogPadding), lSectionClientWidth,
          Max(lSectionStack.Height, Scale(cInputHeight)));

        LayoutCheckRow(TPanel(FShowStatusBarCheck.Parent), FShowStatusBarCheck,
          lInnerTop);

        { Status bar panel visibility grid: 2 rows x 3 columns inside Editor section }
        begin
          var lGridRow: TPanel := FStatusBarPanelsRow;
          var lCheckHeight: Integer := FStatusPanelFileCheck.Height;
          var lColGap: Integer := Scale(cFieldGap * 2);
          var lRowGapLocal: Integer := Scale(cRowGap);
          var lCol1Width: Integer := Max(FStatusPanelFileCheck.Width, FStatusPanelEncodingCheck.Width);
          var lCol2Width: Integer := Max(FStatusPanelPosCheck.Width, FStatusPanelThemeCheck.Width);
          var lCol3Width: Integer := Max(FStatusPanelLexerCheck.Width, FStatusPanelLoadCheck.Width);
          var lCol1X: Integer := Scale(cFieldGap * 3);
          var lCol2X: Integer := lCol1X + lCol1Width + lColGap;
          var lCol3X: Integer := lCol2X + lCol2Width + lColGap;
          var lGridHeight: Integer := lCheckHeight * 2 + lRowGapLocal;

          lGridRow.SetBounds(lContentLeft, lInnerTop, lContentWidth, lGridHeight);
          Inc(lInnerTop, lGridHeight + Scale(cRowGap));

          FStatusPanelFileCheck.SetBounds(lCol1X, 0, FStatusPanelFileCheck.Width, lCheckHeight);
          FStatusPanelPosCheck.SetBounds(lCol2X, 0, FStatusPanelPosCheck.Width, lCheckHeight);
          FStatusPanelLexerCheck.SetBounds(lCol3X, 0, FStatusPanelLexerCheck.Width, lCheckHeight);
          FStatusPanelEncodingCheck.SetBounds(lCol1X, lCheckHeight + lRowGapLocal,
            FStatusPanelEncodingCheck.Width, lCheckHeight);
          FStatusPanelThemeCheck.SetBounds(lCol2X, lCheckHeight + lRowGapLocal,
            FStatusPanelThemeCheck.Width, lCheckHeight);
          FStatusPanelLoadCheck.SetBounds(lCol3X, lCheckHeight + lRowGapLocal,
            FStatusPanelLoadCheck.Width, lCheckHeight);
        end;
        LayoutCheckRow(TPanel(FBackSpaceUnIndentsCheck.Parent), FBackSpaceUnIndentsCheck,
          lInnerTop);
        LayoutLabeledRow(TPanel(FIndentationGuidesCombo.Parent.Parent), FIndentationGuidesLabel,
          TPanel(FIndentationGuidesCombo.Parent), lInnerTop, Scale(cInputHeight));
        LayoutLabeledRow(TPanel(FWhiteSpaceStyleCombo.Parent.Parent), FWhiteSpaceStyleLabel,
          TPanel(FWhiteSpaceStyleCombo.Parent), lInnerTop, Scale(cInputHeight));
        LayoutLabeledRow(TPanel(FWhiteSpaceSizeEdit.Parent.Parent), FWhiteSpaceSizeLabel,
          TPanel(FWhiteSpaceSizeEdit.Parent), lInnerTop, Scale(cInputHeight));
        FWhiteSpaceSizeEdit.SetBounds(0, 0, Scale(cSpinWidth), Scale(cInputHeight));
        LayoutLabeledRow(TPanel(FUpperLineSpacingEdit.Parent.Parent), FUpperLineSpacingLabel,
          TPanel(FUpperLineSpacingEdit.Parent), lInnerTop, Scale(cInputHeight));
        FUpperLineSpacingEdit.SetBounds(0, 0, Scale(cSpinWidth), Scale(cInputHeight));
        LayoutLabeledRow(TPanel(FLowerLineSpacingEdit.Parent.Parent), FLowerLineSpacingLabel,
          TPanel(FLowerLineSpacingEdit.Parent), lInnerTop, Scale(cInputHeight));
        FLowerLineSpacingEdit.SetBounds(0, 0, Scale(cSpinWidth), Scale(cInputHeight));
        LayoutLabeledRow(FTabWidthPanel, FTabWidthLabel, TPanel(FTabWidthEdit.Parent),
          lInnerTop, Scale(cInputHeight));
        FTabWidthEdit.SetBounds(0, 0, Scale(cSpinWidth), Scale(cInputHeight));

        lSectionStack.Height := MeasureStackHeight(lSectionStack);
        FEditorSection.Height := lSectionStack.Top + lSectionStack.Height + lBottomInset;
      end;

      { Padding section }
      lSectionStack := SectionStack(FTextPaddingSection);
      if lSectionStack <> nil then
      begin
        lCardTop := FEditorSection.Top + FEditorSection.Height + Scale(cRowGap);
        BeginGroupLayout(FTextPaddingSection, lSectionStack, lCardTop, lSectionClientWidth,
          lBottomInset);
        lContentLeft := 0;
        lContentWidth := lSectionClientWidth;
        lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
        lInnerTop := 0;

        LayoutLabeledRow(TPanel(FTextPaddingLeftEdit.Parent.Parent),
          FTextPaddingLeftLabel, TPanel(FTextPaddingLeftEdit.Parent),
          lInnerTop, Scale(cInputHeight));
        FTextPaddingLeftEdit.SetBounds(0, 0,
          TPanel(FTextPaddingLeftEdit.Parent).ClientWidth, Scale(cInputHeight));

        LayoutLabeledRow(TPanel(FTextPaddingRightEdit.Parent.Parent),
          FTextPaddingRightLabel, TPanel(FTextPaddingRightEdit.Parent),
          lInnerTop, Scale(cInputHeight));
        FTextPaddingRightEdit.SetBounds(0, 0,
          TPanel(FTextPaddingRightEdit.Parent).ClientWidth, Scale(cInputHeight));

        lSectionStack.Height := MeasureStackHeight(lSectionStack);
        FTextPaddingSection.Height := lSectionStack.Top + lSectionStack.Height + lBottomInset;
      end;

      Exit;
    end;

    if lActiveCard = FSelectionCard then
    begin
      lSectionStack := SectionStack(FSelectionSection);
      if lSectionStack <> nil then
      begin
        PrepareSection(FSelectionSection, lSectionContentRect, lSectionClientWidth, lBottomInset);
        lContentLeft := 0;
        lContentWidth := lSectionClientWidth;
        lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
        lInnerTop := 0;
        lSectionStack.SetBounds(lSectionContentRect.Left + lSectionHorizontalPadding,
          lSectionContentRect.Top + Scale(cDialogPadding), lSectionClientWidth,
          Max(lSectionStack.Height, Scale(cInputHeight)));
        LayoutCheckRow(TPanel(FSelectFullLineCheck.Parent), FSelectFullLineCheck, lInnerTop);
        LayoutSelectionColorRow(TPanel(FUseSelectionForeColorCheck.Parent),
          FUseSelectionForeColorCheck, FSelectionForeColorBox, lInnerTop);
        LayoutLabeledRow(TPanel(FSelectionAlphaEdit.Parent.Parent), FSelectionAlphaLabel,
          TPanel(FSelectionAlphaEdit.Parent), lInnerTop, Scale(cInputHeight));
        FSelectionAlphaEdit.SetBounds(0, 0, Scale(cSpinWidth), Scale(cInputHeight));
        lSectionStack.Height := MeasureStackHeight(lSectionStack);
        FSelectionSection.Height := lSectionStack.Top + lSectionStack.Height + lBottomInset;
        lCardTop := FSelectionSection.Top + FSelectionSection.Height + Scale(cSectionGap);
      end;

      lSectionStack := SectionStack(FSearchHighlightSection);
      if lSectionStack <> nil then
      begin
        BeginGroupLayout(FSearchHighlightSection, lSectionStack, lCardTop, lSectionClientWidth,
          lBottomInset);
        lContentLeft := 0;
        lContentWidth := lSectionClientWidth;
        lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
        lInnerTop := 0;
        LayoutLabeledRow(TPanel(FHighlightBox.Parent.Parent), FHighlightLabel,
          TPanel(FHighlightBox.Parent), lInnerTop, Scale(cColorPreviewHeight));
        FHighlightBox.SetBounds(0, 0,
          Min(Scale(cHighlightPreviewWidth), TPanel(FHighlightBox.Parent).ClientWidth),
          Scale(cColorPreviewHeight));
        LayoutLabeledRow(TPanel(FTransparencyEdit.Parent.Parent), FTransparencyLabel,
          TPanel(FTransparencyEdit.Parent), lInnerTop, Scale(cInputHeight));
        FTransparencyEdit.SetBounds(0, 0, Scale(cSpinWidth), Scale(cInputHeight));
        LayoutLabeledRow(TPanel(FOutlineEdit.Parent.Parent), FOutlineLabel,
          TPanel(FOutlineEdit.Parent), lInnerTop, Scale(cInputHeight));
        FOutlineEdit.SetBounds(0, 0, Scale(cSpinWidth), Scale(cInputHeight));
        lSectionStack.Height := MeasureStackHeight(lSectionStack);
        FSearchHighlightSection.Height := lSectionStack.Top + lSectionStack.Height + lBottomInset;
        lCardTop := FSearchHighlightSection.Top + FSearchHighlightSection.Height +
          Scale(cSectionGap);
      end;

      lSectionStack := SectionStack(FSmartHighlightSection);
      if lSectionStack <> nil then
      begin
        BeginGroupLayout(FSmartHighlightSection, lSectionStack, lCardTop,
          lSectionClientWidth, lBottomInset);
        lContentLeft := 0;
        lContentWidth := lSectionClientWidth;
        lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
        lInnerTop := 0;
        LayoutLabeledRow(TPanel(FSmartHighlightStyleCombo.Parent.Parent),
          FSmartHighlightStyleLabel, TPanel(FSmartHighlightStyleCombo.Parent), lInnerTop,
          Scale(cInputHeight));
        LayoutLabeledRow(TPanel(FSmartHighlightFillAlphaEdit.Parent.Parent),
          FSmartHighlightFillAlphaLabel, TPanel(FSmartHighlightFillAlphaEdit.Parent), lInnerTop,
          Scale(cInputHeight));
        FSmartHighlightFillAlphaEdit.SetBounds(0, 0, Scale(cSpinWidth),
          Scale(cInputHeight));
        LayoutLabeledRow(TPanel(FSmartHighlightOutlineAlphaEdit.Parent.Parent),
          FSmartHighlightOutlineAlphaLabel, TPanel(FSmartHighlightOutlineAlphaEdit.Parent),
          lInnerTop, Scale(cInputHeight));
        FSmartHighlightOutlineAlphaEdit.SetBounds(0, 0, Scale(cSpinWidth),
          Scale(cInputHeight));
        lSectionStack.Height := MeasureStackHeight(lSectionStack);
        FSmartHighlightSection.Height := lSectionStack.Top + lSectionStack.Height + lBottomInset;
        lCardTop := FSmartHighlightSection.Top + FSmartHighlightSection.Height +
          Scale(cSectionGap);
      end;

      FSearchSection.Width := lSectionWidth;
      FSearchSection.SetBounds(0, lCardTop, lSectionWidth, Max(FSearchSection.Height,
        Scale(64)));
      lSectionContentRect := FSearchSection.ClientRect;
      TGroupBoxAccess(FSearchSection).AdjustClientRect(lSectionContentRect);
      lSectionClientWidth := Max(0, (lSectionContentRect.Right - lSectionContentRect.Left) -
        (lSectionHorizontalPadding * 2));
      lContentLeft := lSectionContentRect.Left + lSectionHorizontalPadding;
      lContentWidth := lSectionClientWidth;
      FSearchSyncRow.SetBounds(lContentLeft, lSectionContentRect.Top + Scale(cDialogPadding),
        lContentWidth, FSearchSyncCheck.Height);
      FSearchSyncCheck.Align := alNone;
      FSearchSyncCheck.SetBounds(0, 0, FSearchSyncCheck.Width, FSearchSyncCheck.Height);
      FSearchSection.Height := FSearchSyncRow.Top + FSearchSyncRow.Height +
        Max(Scale(cDialogPadding),
          (FSearchSection.ClientHeight - lSectionContentRect.Bottom) + Scale(cDialogPadding));
      Exit;
    end;

    if lActiveCard = FWrappingCard then
    begin
      lSectionStack := SectionStack(FWrappingSection);
      if lSectionStack <> nil then
      begin
        PrepareSection(FWrappingSection, lSectionContentRect, lSectionClientWidth, lBottomInset);
        lContentLeft := 0;
        lContentWidth := lSectionClientWidth;
        lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
        lInnerTop := 0;
        lSectionStack.SetBounds(lSectionContentRect.Left + lSectionHorizontalPadding,
          lSectionContentRect.Top + Scale(cDialogPadding), lSectionClientWidth,
          Max(lSectionStack.Height, Scale(cInputHeight)));
        LayoutLabeledRow(TPanel(FWrapModeCombo.Parent.Parent), FWrapModeLabel,
          TPanel(FWrapModeCombo.Parent), lInnerTop, Scale(cInputHeight));
        LayoutCheckRow(TPanel(FWrapFlagEndCheck.Parent), FWrapFlagEndCheck, lInnerTop);
        LayoutCheckRow(TPanel(FWrapFlagStartCheck.Parent), FWrapFlagStartCheck, lInnerTop);
        LayoutCheckRow(TPanel(FWrapFlagMarginCheck.Parent), FWrapFlagMarginCheck, lInnerTop);
        LayoutCheckRow(TPanel(FWrapLocationEndCheck.Parent), FWrapLocationEndCheck, lInnerTop);
        LayoutCheckRow(TPanel(FWrapLocationStartCheck.Parent), FWrapLocationStartCheck, lInnerTop);
        lSectionStack.Height := MeasureStackHeight(lSectionStack);
        FWrappingSection.Height := lSectionStack.Top + lSectionStack.Height + lBottomInset;
        lCardTop := FWrappingSection.Top + FWrappingSection.Height + Scale(cSectionGap);
      end;

      FMarginsSection.Width := lSectionWidth;
      FMarginsSection.SetBounds(0, lCardTop, lSectionWidth, Max(FMarginsSection.Height,
        Scale(64)));
      lSectionContentRect := FMarginsSection.ClientRect;
      TGroupBoxAccess(FMarginsSection).AdjustClientRect(lSectionContentRect);
      lSectionClientWidth := Max(0, (lSectionContentRect.Right - lSectionContentRect.Left) -
        (lSectionHorizontalPadding * 2));
      lContentLeft := lSectionContentRect.Left + lSectionHorizontalPadding;
      lContentWidth := lSectionClientWidth;
      lInnerTop := 0;
      LayoutCheckRow(FMiscChecksRow, FBookmarkMarginCheck, lInnerTop);
      LayoutCheckRow(FGutterChecksRow, FFoldMarginCheck, lInnerTop);
      LayoutLabeledRow(FGutterStylePanel, FGutterStyleLabel, TPanel(FGutterStyleCombo.Parent),
        lInnerTop, Scale(cInputHeight));
      FGutterStyleCombo.SetBounds(0, 0, TPanel(FGutterStyleCombo.Parent).ClientWidth,
        Scale(cInputHeight));
      LayoutPairedRow(FGutterColorsRow, FGutterForegroundLabel, FGutterBackgroundLabel,
        FGutterForegroundBox, FGutterBackgroundBox, lInnerTop, Scale(cColorPreviewHeight),
        0, 0);
      FMarginsSection.Height := FGutterColorsRow.Top + FGutterColorsRow.Height +
        Max(Scale(cDialogPadding),
          (FMarginsSection.ClientHeight - lSectionContentRect.Bottom) + Scale(cDialogPadding));
      Exit;
    end;

    if lActiveCard = FCaretPasteCard then
    begin
      lSectionStack := SectionStack(FCaretSection);
      if lSectionStack <> nil then
      begin
        PrepareSection(FCaretSection, lSectionContentRect, lSectionClientWidth, lBottomInset);
        lContentLeft := 0;
        lContentWidth := lSectionClientWidth;
        lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
        lInnerTop := 0;
        lSectionStack.SetBounds(lSectionContentRect.Left + lSectionHorizontalPadding,
          lSectionContentRect.Top + Scale(cDialogPadding), lSectionClientWidth,
          Max(lSectionStack.Height, Scale(cInputHeight)));
        LayoutCheckRow(TPanel(FCaretBeyondLineEndingsCheck.Parent),
          FCaretBeyondLineEndingsCheck, lInnerTop);
        LayoutCheckRow(TPanel(FWrapCursorAtLineStartCheck.Parent),
          FWrapCursorAtLineStartCheck, lInnerTop);
        LayoutLabeledRow(TPanel(FStickyCaretCombo.Parent.Parent), FStickyCaretLabel,
          TPanel(FStickyCaretCombo.Parent), lInnerTop, Scale(cInputHeight));
        lSectionStack.Height := MeasureStackHeight(lSectionStack);
        FCaretSection.Height := lSectionStack.Top + lSectionStack.Height + lBottomInset;
        lCardTop := FCaretSection.Top + FCaretSection.Height + Scale(cSectionGap);
      end;

      lSectionStack := SectionStack(FCopyPasteSection);
      if lSectionStack <> nil then
      begin
        BeginGroupLayout(FCopyPasteSection, lSectionStack, lCardTop, lSectionClientWidth,
          lBottomInset);
        lContentLeft := 0;
        lContentWidth := lSectionClientWidth;
        lInnerTop := 0;
        LayoutCheckRow(TPanel(FMultiPasteCheck.Parent), FMultiPasteCheck, lInnerTop);
        LayoutCheckRow(TPanel(FPasteConvertEndingsCheck.Parent), FPasteConvertEndingsCheck,
          lInnerTop);
        lSectionStack.Height := MeasureStackHeight(lSectionStack);
        FCopyPasteSection.Height := lSectionStack.Top + lSectionStack.Height + lBottomInset;
      end;
      Exit;
    end;

    if lActiveCard = FFoldingCard then
    begin
      lSectionStack := SectionStack(FFoldingSection);
      if lSectionStack <> nil then
      begin
        PrepareSection(FFoldingSection, lSectionContentRect, lSectionClientWidth, lBottomInset);
        lContentLeft := 0;
        lContentWidth := lSectionClientWidth;
        lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
        lInnerTop := 0;
        lSectionStack.SetBounds(lSectionContentRect.Left + lSectionHorizontalPadding,
          lSectionContentRect.Top + Scale(cDialogPadding), lSectionClientWidth,
          Max(lSectionStack.Height, Scale(cInputHeight)));
        LayoutCheckRow(TPanel(FFoldingLinesCheck.Parent), FFoldingLinesCheck, lInnerTop);
        LayoutLabeledRow(TPanel(FFoldingTextEdit.Parent.Parent), FFoldingTextLabel,
          TPanel(FFoldingTextEdit.Parent), lInnerTop, Scale(cInputHeight));
        LayoutLabeledRow(TPanel(FFoldDisplayTextStyleCombo.Parent.Parent),
          FFoldDisplayTextStyleLabel, TPanel(FFoldDisplayTextStyleCombo.Parent), lInnerTop,
          Scale(cInputHeight));
        LayoutLabeledRow(TPanel(FFoldMarkerStyleCombo.Parent.Parent),
          FFoldMarkerStyleLabel, TPanel(FFoldMarkerStyleCombo.Parent), lInnerTop,
          Scale(cInputHeight));
        lSectionStack.Height := MeasureStackHeight(lSectionStack);
        FFoldingSection.Height := lSectionStack.Top + lSectionStack.Height + lBottomInset;
        lCardTop := FFoldingSection.Top + FFoldingSection.Height + Scale(cSectionGap);
      end;

      FDocumentSection.Width := lSectionWidth;
      FDocumentSection.SetBounds(0, lCardTop, lSectionWidth, Max(FDocumentSection.Height,
        Scale(64)));
      lSectionContentRect := FDocumentSection.ClientRect;
      TGroupBoxAccess(FDocumentSection).AdjustClientRect(lSectionContentRect);
      lSectionClientWidth := Max(0, (lSectionContentRect.Right - lSectionContentRect.Left) -
        (Scale(cDialogPadding) * 2));
      lContentLeft := 0;
      lContentWidth := lSectionClientWidth;
      lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
      lInnerTop := 0;
      LayoutLabeledRow(FFileSizeLimitPanel, FFileSizeLimitLabel, TPanel(FFileSizeLimitEdit.Parent),
        lInnerTop, Scale(cInputHeight));
      FFileSizeLimitEdit.SetBounds(0, 0, Max(Scale(cSpinWidth), Scale(120)),
        Scale(cInputHeight));
      FDocumentSection.Height := FFileSizeLimitPanel.Top + FFileSizeLimitPanel.Height +
        Max(Scale(cDialogPadding),
          (FDocumentSection.ClientHeight - lSectionContentRect.Bottom) + Scale(cDialogPadding));
      lCardTop := FDocumentSection.Top + FDocumentSection.Height + Scale(cSectionGap);

      lSectionStack := SectionStack(FPrintingSection);
      if lSectionStack <> nil then
      begin
        BeginGroupLayout(FPrintingSection, lSectionStack, lCardTop, lSectionClientWidth,
          lBottomInset);
        lContentLeft := 0;
        lContentWidth := lSectionClientWidth;
        lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
        lInnerTop := 0;
        LayoutLabeledRow(TPanel(FPrintMagnificationEdit.Parent.Parent), FPrintMagnificationLabel,
          TPanel(FPrintMagnificationEdit.Parent), lInnerTop, Scale(cInputHeight));
        FPrintMagnificationEdit.SetBounds(0, 0, Scale(cSpinWidth), Scale(cInputHeight));
        lSectionStack.Height := MeasureStackHeight(lSectionStack);
        FPrintingSection.Height := lSectionStack.Top + lSectionStack.Height + lBottomInset;
      end;
    end;
  end;
begin
  if FUpdatingLayout then
    Exit;
  if (FContentPanel = nil) or (FButtonsPanel = nil) or (FThemePanel = nil) or
     (FCategoryPanel = nil) or (FCardPanel = nil) or (FStyleSection = nil) then
    Exit;
  if FContentPanel.ClientWidth <= Scale(cDialogPadding * 2) then
    Exit;

  SizeCheckBox(FBoldCheck);
  SizeCheckBox(FItalicCheck);
  SizeCheckBox(FUnderlineCheck);
  SizeCheckBox(FLineNumberingCheck);
  SizeCheckBox(FBookmarkMarginCheck);
  SizeCheckBox(FFoldMarginCheck);
  SizeCheckBox(FLineWrappingCheck);
  SizeCheckBox(FSearchSyncCheck);
  SizeCheckBox(FLogEnabledCheck);
  SizeCheckBox(FShowStatusBarCheck);
  SizeCheckBox(FStatusPanelFileCheck);
  SizeCheckBox(FStatusPanelPosCheck);
  SizeCheckBox(FStatusPanelLexerCheck);
  SizeCheckBox(FStatusPanelEncodingCheck);
  SizeCheckBox(FStatusPanelThemeCheck);
  SizeCheckBox(FStatusPanelLoadCheck);
  SizeCheckBox(FBackSpaceUnIndentsCheck);
  SizeCheckBox(FSelectFullLineCheck);
  SizeCheckBox(FUseSelectionForeColorCheck);
  SizeCheckBox(FCaretBeyondLineEndingsCheck);
  SizeCheckBox(FWrapCursorAtLineStartCheck);
  SizeCheckBox(FMultiPasteCheck);
  SizeCheckBox(FPasteConvertEndingsCheck);
  SizeCheckBox(FFoldingLinesCheck);
  SizeCheckBox(FWrapFlagEndCheck);
  SizeCheckBox(FWrapFlagStartCheck);
  SizeCheckBox(FWrapFlagMarginCheck);
  SizeCheckBox(FWrapLocationEndCheck);
  SizeCheckBox(FWrapLocationStartCheck);

  Canvas.Font.Assign(FLineNumDynamicRadio.Font);
  FLineNumDynamicRadio.Width := Canvas.TextWidth(FLineNumDynamicRadio.Caption) + Scale(24);
  FLineNumDynamicRadio.Height := Max(Scale(cInputHeight), Canvas.TextHeight('Hg') + Scale(8));
  FLineNumFixedRadio.Width := Canvas.TextWidth(FLineNumFixedRadio.Caption) + Scale(24);
  FLineNumFixedRadio.Height := FLineNumDynamicRadio.Height;

  FUpdatingLayout := True;
  try
    FContentPanel.DisableAlign;
    try
      lOuterPadding := Scale(cDialogPadding);
      lSectionHorizontalPadding := Max(Scale(2), Scale(cDialogPadding div 2));
      lGroupNonClientWidth := Max(Scale(4),
        FStyleSection.Width - FStyleSection.ClientWidth);
      lLabelWidth := MeasureLabelColumnWidth;
      lLabelHeight := MeasureSingleLineLabelHeight;
      lOptionPairLabelWidth := Max(MeasureSingleLineLabelWidth(FForegroundLabel.Caption),
        MeasureSingleLineLabelWidth(FBackgroundLabel.Caption));
      lOptionPairLabelWidth := Max(lOptionPairLabelWidth,
        MeasureSingleLineLabelWidth(FTransparencyLabel.Caption));
      lOptionPairLabelWidth := Max(lOptionPairLabelWidth,
        MeasureSingleLineLabelWidth(FOutlineLabel.Caption));

      lDialogClientWidth := MeasureDesiredClientWidth;
      if ClientWidth <> lDialogClientWidth then
        ClientWidth := lDialogClientWidth;
      Constraints.MinWidth := Width;

      lContentLeft := lOuterPadding;
      lContentWidth := Max(0, FContentPanel.ClientWidth - (lContentLeft * 2));
      lSectionWidth := Max(0, FCardPanel.ClientWidth);
      lFieldWidth := Max(0, lContentWidth - lLabelWidth - Scale(cFieldGap));
      LayoutButtons;

      lSectionTop := Scale(cDialogPadding);
      LayoutLabeledRow(FCategoryPanel, FCategoryLabel, TPanel(FCategoryCombo.Parent),
        lSectionTop, Scale(cInputHeight));
      FCategoryCombo.SetBounds(0, 0, TPanel(FCategoryCombo.Parent).ClientWidth,
        Scale(cInputHeight));

      FCardPanel.SetBounds(lOuterPadding, lSectionTop, lContentWidth, Scale(240));
      lActiveCard := ActiveSettingsCard;
      FCardPanel.ActiveCard := lActiveCard;
      lCardClientWidth := FCardPanel.ClientWidth;
      lCardClientHeight := FCardPanel.ClientHeight;
      lSectionWidth := lCardClientWidth;

      if lActiveCard <> nil then
      begin
        lActiveCard.SetBounds(0, 0, lCardClientWidth, lCardClientHeight);
        LayoutCurrentCard;
        lActiveCard.Realign;
      end;

      lCardContentHeight := MeasureVisibleChildBottom(lActiveCard) +
        Scale(cDialogPadding * 2);
      FCardPanel.Height := Max(Scale(120), lCardContentHeight);
      LogLayoutHeightChange('CardPanel', FCardPanel.Height);

      lNeededContentHeight := FCardPanel.Top + FCardPanel.Height + Scale(cDialogPadding);
      lFormClientHeight := lNeededContentHeight + FButtonsPanel.Height;
      if ClientHeight <> lFormClientHeight then
        ClientHeight := lFormClientHeight;
      Constraints.MinHeight := Height;
      lContentNonClientHeight := FContentPanel.Height - FContentPanel.ClientHeight;
      FContentPanel.Height := lNeededContentHeight + lContentNonClientHeight;
      LayoutButtons;
    finally
      FContentPanel.EnableAlign;
    end;
  finally
    FUpdatingLayout := False;
  end;
end;

procedure TDSciVisualSettingsDialog.BuildUi;
var
  lFieldHost: TPanel;
  lLocalStack: TStackPanel;
  lRow: TPanel;

  function CreateHostPanel(AParent: TWinControl): TPanel;
  begin
    Result := TPanel.Create(Self);
    Result.Parent := AParent;
    Result.BevelOuter := bvNone;
    Result.ParentBackground := False;
    Result.Caption := '';
  end;

  function CreateGroupSection(AParent: TWinControl; const ACaption: string): TGroupBox;
  begin
    Result := TGroupBox.Create(Self);
    Result.Parent := AParent;
    Result.Caption := ACaption;
    Result.ParentBackground := True;
    Result.ParentColor := True;
  end;

  function CreateCard(const ACaption: string): TCard;
  begin
    Result := TCard.Create(Self);
    Result.Parent := FCardPanel;
    Result.Caption := ACaption;
    Result.Color := Color;
  end;

  procedure RegisterCard(const ACaption: string; ACard: TCard);
  begin
    FCategoryCombo.Items.AddObject(ACaption, ACard);
  end;

  function CreateStackPanel(AParent: TWinControl; AOrientation: TStackPanelOrientation;
    ASpacing: Integer; AAutoSize: Boolean = True): TStackPanel;
  begin
    Result := TStackPanel.Create(Self);
    Result.Parent := AParent;
    Result.BevelOuter := bvNone;
    Result.ParentBackground := False;
    Result.AutoSize := AAutoSize;
    Result.Orientation := AOrientation;
    Result.Spacing := ASpacing;
    if AOrientation = spoVertical then
    begin
      Result.HorizontalPositioning := sphpFill;
      Result.VerticalPositioning := spvpTop;
    end
    else
      Result.VerticalPositioning := spvpCenter;
  end;

  procedure ConfigureManualSectionStack(AStack: TStackPanel);
  begin
    if AStack = nil then
      Exit;
    AStack.AlignWithMargins := False;
    AStack.Align := alNone;
  end;

  procedure ConfigureManualSectionRow(AControl: TControl);
  begin
    if AControl = nil then
      Exit;
    AControl.AlignWithMargins := False;
    AControl.Align := alNone;
  end;

  procedure ConfigureVerticalStackChild(AStack: TStackPanel; AControl: TControl);
  begin
    AControl.AlignWithMargins := True;
    AControl.Margins.Left := 0;
    AControl.Margins.Top := 0;
    AControl.Margins.Right := 0;
    AControl.Margins.Bottom := 0;
    AStack.ControlHorizontalPositioning[AControl] := sphpFill;
  end;

  function CreateLabeledRow(AParent: TWinControl; const ACaption: string;
    out ALabel: TLabel; out AFieldHost: TPanel; AFieldHeight: Integer): TPanel;
  var
    lLabelHost: TPanel;
  begin
    Result := CreateHostPanel(AParent);
    Result.Height := AFieldHeight;

    lLabelHost := CreateHostPanel(Result);
    lLabelHost.Align := alLeft;
    lLabelHost.Width := Scale(cLabelWidth);
    ALabel := TLabel.Create(Self);
    ALabel.Parent := lLabelHost;
    ALabel.AutoSize := False;
    ALabel.Align := alClient;
    ALabel.Layout := tlCenter;
    ALabel.WordWrap := False;
    ALabel.Caption := ACaption;

    AFieldHost := CreateHostPanel(Result);
    AFieldHost.Align := alClient;
  end;

  function CreateCheckRow(AParent: TWinControl; const ACaption: string;
    out ACheckBox: TCheckBox; AHeight: Integer): TPanel;
  begin
    Result := CreateHostPanel(AParent);
    Result.Height := AHeight;
    ACheckBox := TCheckBox.Create(Self);
    ACheckBox.Parent := Result;
    ACheckBox.Align := alLeft;
    ACheckBox.Caption := ACaption;
  end;

  procedure ConfigureColorPreviewPanel(APanel: TPanel);
  begin
    APanel.ParentBackground := False;
    APanel.ParentColor := False;
    APanel.StyleElements := [seFont, seBorder];
  end;

begin
  FButtonsPanel := TPanel.Create(Self);
  FButtonsPanel.Parent := Self;
  FButtonsPanel.Align := alBottom;
  FButtonsPanel.BevelOuter := bvNone;
  FButtonsPanel.ParentBackground := False;
  FButtonsPanel.Height := Scale(cButtonsPanelHeight);

  FContentPanel := TPanel.Create(Self);
  FContentPanel.Parent := Self;
  FContentPanel.Align := alClient;
  FContentPanel.BevelOuter := bvNone;
  FContentPanel.ParentBackground := False;

  FColorDialog := TColorDialog.Create(Self);
  FOpenThemeDialog := TOpenDialog.Create(Self);
  FOpenThemeDialog.Filter := 'Notepad++ themes|*.xml|XML files|*.xml|All files|*.*';
  FOpenThemeDialog.Options := [ofFileMustExist, ofPathMustExist, ofEnableSizing];

  FCancelButton := TButton.Create(Self);
  FCancelButton.Parent := FButtonsPanel;
  FCancelButton.Caption := 'Cancel';
  FCancelButton.Width := Scale(cButtonWidth);
  FCancelButton.OnClick := CancelButtonClick;

  FOkButton := TButton.Create(Self);
  FOkButton.Parent := FButtonsPanel;
  FOkButton.Caption := 'OK';
  FOkButton.Width := Scale(cButtonWidth);
  FOkButton.OnClick := OkButtonClick;

  FCategoryPanel := CreateLabeledRow(FContentPanel, 'Category', FCategoryLabel, lFieldHost, Scale(cInputHeight));
  FCategoryCombo := TComboBox.Create(Self);
  FCategoryCombo.AlignWithMargins := True;
  FCategoryCombo.Parent := lFieldHost;
  FCategoryCombo.Style := csDropDownList;
  FCategoryCombo.OnChange := CategoryComboChange;

  FCardPanel := TCardPanel.Create(Self);
  FCardPanel.Parent := FContentPanel;
  FCardPanel.BevelOuter := bvNone;
  FCardPanel.ParentBackground := False;

  FGeneralCard := CreateCard('General');
  RegisterCard('General', FGeneralCard);
  FStyleCard := CreateCard('Styles');
  RegisterCard('Styles', FStyleCard);
  FEditorCard := CreateCard('Editor');
  RegisterCard('Editor', FEditorCard);
  FSelectionCard := CreateCard('Selection & Highlighting');
  RegisterCard('Selection & Highlighting', FSelectionCard);
  FWrappingCard := CreateCard('Wrapping');
  RegisterCard('Wrapping', FWrappingCard);
  FCaretPasteCard := CreateCard('Caret & Paste');
  RegisterCard('Caret & Paste', FCaretPasteCard);
  FFoldingCard := CreateCard('Folding & Limits');
  RegisterCard('Folding & Limits', FFoldingCard);
  if FCategoryCombo.Items.Count > 0 then
    FCategoryCombo.ItemIndex := 0;
  FCardPanel.ActiveCard := FGeneralCard;

  FThemePanel := CreateLabeledRow(FStyleCard, 'Theme', FThemeLabel, lFieldHost, Scale(cInputHeight));
  FThemeCombo := TComboBox.Create(Self);
  FThemeCombo.Parent := lFieldHost;
  FThemeCombo.Style := csDropDownList;
  FThemeCombo.OnChange := ThemeComboChange;

  FThemeImportButton := TButton.Create(Self);
  FThemeImportButton.Parent := lFieldHost;
  FThemeImportButton.Caption := 'Import...';
  FThemeImportButton.OnClick := ImportThemeButtonClick;

  FStyleSection := CreateGroupSection(FStyleCard, 'Style Options');
  FStyleStack := CreateStackPanel(FStyleSection, spoVertical, Scale(cRowGap), False);

  FLanguagePanel := CreateLabeledRow(FStyleStack, 'Language', FLanguageLabel, lFieldHost,
    Scale(cInputHeight));
  ConfigureVerticalStackChild(FStyleStack, FLanguagePanel);
  FLanguageCombo := TComboBox.Create(Self);
  FLanguageCombo.Parent := lFieldHost;
  FLanguageCombo.Style := csDropDownList;
  FLanguageCombo.OnChange := LanguageComboChange;

  FExtensionsPanel := CreateLabeledRow(FStyleStack, 'Extensions', FExtensionsLabel, lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(FStyleStack, FExtensionsPanel);
  FExtensionsEdit := TEdit.Create(Self);
  FExtensionsEdit.Parent := lFieldHost;
  FExtensionsEdit.Hint := 'Allowed separators: space, comma, semicolon';
  FExtensionsEdit.ShowHint := True;
  FExtensionsEdit.OnChange := StyleControlChange;

  FStylePanel := CreateLabeledRow(FStyleStack, 'Style', FStyleLabel, lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(FStyleStack, FStylePanel);
  FStyleCombo := TComboBox.Create(Self);
  FStyleCombo.Parent := lFieldHost;
  FStyleCombo.Style := csDropDownList;
  FStyleCombo.OnChange := StyleComboChange;

  FFontNamePanel := CreateLabeledRow(FStyleStack, 'Font name', FFontNameLabel, lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(FStyleStack, FFontNamePanel);
  FFontNameCombo := TComboBox.Create(Self);
  FFontNameCombo.Parent := lFieldHost;
  FFontNameCombo.Style := csDropDownList;
  FFontNameCombo.Items.Assign(Screen.Fonts);
  FFontNameCombo.OnChange := StyleControlChange;

  FFontSizePanel := CreateLabeledRow(FStyleStack, 'Font size', FFontSizeLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(FStyleStack, FFontSizePanel);
  FFontSizeEdit := TSpinEdit.Create(Self);
  FFontSizeEdit.Parent := lFieldHost;
  FFontSizeEdit.MinValue := 6;
  FFontSizeEdit.MaxValue := 48;
  FFontSizeEdit.OnChange := StyleControlChange;

  FStyleColorsRow := CreateHostPanel(FStyleStack);
  ConfigureVerticalStackChild(FStyleStack, FStyleColorsRow);
  FForegroundLabel := TLabel.Create(Self);
  FForegroundLabel.Parent := FStyleColorsRow;
  FForegroundLabel.AutoSize := False;
  FForegroundLabel.Caption := 'Foreground';

  FForegroundBox := TPanel.Create(Self);
  FForegroundBox.Parent := FStyleColorsRow;
  FForegroundBox.BevelOuter := bvRaised;
  ConfigureColorPreviewPanel(FForegroundBox);
  FForegroundBox.Color := clWhite;
  FForegroundBox.OnClick := ColorPanelClick;

  FBackgroundLabel := TLabel.Create(Self);
  FBackgroundLabel.Parent := FStyleColorsRow;
  FBackgroundLabel.AutoSize := False;
  FBackgroundLabel.Caption := 'Background';

  FBackgroundBox := TPanel.Create(Self);
  FBackgroundBox.Parent := FStyleColorsRow;
  FBackgroundBox.BevelOuter := bvRaised;
  ConfigureColorPreviewPanel(FBackgroundBox);
  FBackgroundBox.Color := clBlack;
  FBackgroundBox.OnClick := ColorPanelClick;

  FFontStylesRow := CreateHostPanel(FStyleStack);
  ConfigureVerticalStackChild(FStyleStack, FFontStylesRow);
  FBoldCheck := TCheckBox.Create(Self);
  FBoldCheck.Parent := FFontStylesRow;
  FBoldCheck.Caption := 'Bold';
  FBoldCheck.OnClick := StyleControlChange;

  FItalicCheck := TCheckBox.Create(Self);
  FItalicCheck.Parent := FFontStylesRow;
  FItalicCheck.Caption := 'Italic';
  FItalicCheck.OnClick := StyleControlChange;

  FUnderlineCheck := TCheckBox.Create(Self);
  FUnderlineCheck.Parent := FFontStylesRow;
  FUnderlineCheck.Caption := 'Underline';
  FUnderlineCheck.OnClick := StyleControlChange;

  FMiscSection := CreateGroupSection(FGeneralCard, 'General');
  FMiscStack := CreateStackPanel(FMiscSection, spoVertical, Scale(cRowGap), False);

  FTechnologyPanel := CreateLabeledRow(FMiscStack, 'Rendering backend',
    FTechnologyLabel, lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(FMiscStack, FTechnologyPanel);
  FTechnologyCombo := TComboBox.Create(Self);
  FTechnologyCombo.Parent := lFieldHost;
  FTechnologyCombo.Style := csDropDownList;
  AddComboIntItem(FTechnologyCombo, 'Default', TDSciTechnologyToInt(sctDEFAULT));
  AddComboIntItem(FTechnologyCombo, 'DirectWrite', TDSciTechnologyToInt(sctDIRECT_WRITE));
  AddComboIntItem(FTechnologyCombo, 'DirectWrite retain', TDSciTechnologyToInt(sctDIRECT_WRITE_RETAIN));
  AddComboIntItem(FTechnologyCombo, 'DirectWrite DC', TDSciTechnologyToInt(sctDIRECT_WRITE_D_C));
  AddComboIntItem(FTechnologyCombo, 'DirectWrite 1', TDSciTechnologyToInt(sctDIRECT_WRITE_1));
  FTechnologyCombo.OnChange := StyleControlChange;

  FFontQualityPanel := CreateLabeledRow(FMiscStack, 'Font quality',
    FFontQualityLabel, lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(FMiscStack, FFontQualityPanel);
  FFontQualityCombo := TComboBox.Create(Self);
  FFontQualityCombo.Parent := lFieldHost;
  FFontQualityCombo.Style := csDropDownList;
  AddComboIntItem(FFontQualityCombo, 'Default', TDSciFontQualityToInt(scfqQUALITY_DEFAULT));
  AddComboIntItem(FFontQualityCombo, 'Non-antialiased', TDSciFontQualityToInt(scfqQUALITY_NON_ANTIALIASED));
  AddComboIntItem(FFontQualityCombo, 'Antialiased', TDSciFontQualityToInt(scfqQUALITY_ANTIALIASED));
  AddComboIntItem(FFontQualityCombo, 'LCD optimized', TDSciFontQualityToInt(scfqQUALITY_LCD_OPTIMIZED));
  FFontQualityCombo.OnChange := StyleControlChange;

  FFontLocalePanel := CreateLabeledRow(FMiscStack, 'Font locale',
    FFontLocaleLabel, lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(FMiscStack, FFontLocalePanel);
  FFontLocaleEdit := TEdit.Create(Self);
  FFontLocaleEdit.Parent := lFieldHost;
  FFontLocaleEdit.Hint := 'Leave empty to use the current Windows locale automatically';
  FFontLocaleEdit.ShowHint := True;
  FFontLocaleEdit.OnChange := StyleControlChange;

  FHighlightPanel := CreateLabeledRow(FMiscStack, 'Highlight color', FHighlightLabel,
    lFieldHost, Scale(cColorPreviewHeight));
  ConfigureVerticalStackChild(FMiscStack, FHighlightPanel);
  FHighlightBox := TPanel.Create(Self);
  FHighlightBox.Parent := lFieldHost;
  FHighlightBox.BevelOuter := bvRaised;
  ConfigureColorPreviewPanel(FHighlightBox);
  FHighlightBox.Color := clLime;
  FHighlightBox.OnClick := ColorPanelClick;

  FMiscOptionsRow := CreateHostPanel(FMiscStack);
  ConfigureVerticalStackChild(FMiscStack, FMiscOptionsRow);
  FTransparencyLabel := TLabel.Create(Self);
  FTransparencyLabel.Parent := FMiscOptionsRow;
  FTransparencyLabel.AutoSize := False;
  FTransparencyLabel.Caption := 'Transparency';

  FTransparencyEdit := TSpinEdit.Create(Self);
  FTransparencyEdit.Parent := FMiscOptionsRow;
  FTransparencyEdit.MinValue := 0;
  FTransparencyEdit.MaxValue := 255;
  FTransparencyEdit.OnChange := StyleControlChange;

  FOutlineLabel := TLabel.Create(Self);
  FOutlineLabel.Parent := FMiscOptionsRow;
  FOutlineLabel.AutoSize := False;
  FOutlineLabel.Caption := 'Outline';

  FOutlineEdit := TSpinEdit.Create(Self);
  FOutlineEdit.Parent := FMiscOptionsRow;
  FOutlineEdit.MinValue := 0;
  FOutlineEdit.MaxValue := 255;
  FOutlineEdit.OnChange := StyleControlChange;

  FTabWidthPanel := CreateLabeledRow(FMiscStack, 'Tab width', FTabWidthLabel, lFieldHost,
    Scale(cInputHeight));
  ConfigureVerticalStackChild(FMiscStack, FTabWidthPanel);
  FTabWidthEdit := TSpinEdit.Create(Self);
  FTabWidthEdit.Parent := lFieldHost;
  FTabWidthEdit.MinValue := 1;
  FTabWidthEdit.MaxValue := 16;
  FTabWidthEdit.OnChange := StyleControlChange;

  FFileSizeLimitPanel := CreateLabeledRow(FMiscStack, 'File size limit (0=no limit)',
    FFileSizeLimitLabel, lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(FMiscStack, FFileSizeLimitPanel);
  FFileSizeLimitEdit := TSpinEdit.Create(Self);
  FFileSizeLimitEdit.Parent := lFieldHost;
  FFileSizeLimitEdit.MinValue := 0;
  FFileSizeLimitEdit.MaxValue := MaxInt;
  FFileSizeLimitEdit.OnChange := StyleControlChange;

  FMiscChecksRow := CreateHostPanel(FMiscStack);
  ConfigureVerticalStackChild(FMiscStack, FMiscChecksRow);

  FBookmarkMarginCheck := TCheckBox.Create(Self);
  FBookmarkMarginCheck.Parent := FMiscChecksRow;
  FBookmarkMarginCheck.Caption := 'Bookmark gutter';
  FBookmarkMarginCheck.OnClick := StyleControlChange;

  FLineWrappingCheck := TCheckBox.Create(Self);
  FLineWrappingCheck.Parent := FMiscChecksRow;
  FLineWrappingCheck.Caption := 'Line wrapping';
  FLineWrappingCheck.OnClick := StyleControlChange;

  FGutterChecksRow := CreateHostPanel(FMiscStack);
  ConfigureVerticalStackChild(FMiscStack, FGutterChecksRow);
  FFoldMarginCheck := TCheckBox.Create(Self);
  FFoldMarginCheck.Parent := FGutterChecksRow;
  FFoldMarginCheck.Caption := 'Fold gutter';
  FFoldMarginCheck.OnClick := StyleControlChange;

  FSearchSyncRow := CreateHostPanel(FMiscStack);
  ConfigureVerticalStackChild(FMiscStack, FSearchSyncRow);
  FSearchSyncCheck := TCheckBox.Create(Self);
  FSearchSyncCheck.Parent := FSearchSyncRow;
  FSearchSyncCheck.Caption := 'Sync inline search with Find dialog';
  FSearchSyncCheck.OnClick := StyleControlChange;

  { Line numbering section on General card }
  FLineNumberingSection := CreateGroupSection(FGeneralCard, 'Line Numbering');
  lLocalStack := CreateStackPanel(FLineNumberingSection, spoVertical, Scale(cRowGap), False);
  ConfigureManualSectionStack(lLocalStack);

  lRow := CreateHostPanel(lLocalStack);
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FLineNumberingCheck := TCheckBox.Create(Self);
  FLineNumberingCheck.Parent := lRow;
  FLineNumberingCheck.Caption := 'Display';
  FLineNumberingCheck.OnClick := StyleControlChange;

  lRow := CreateHostPanel(lLocalStack);
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FLineNumDynamicRadio := TRadioButton.Create(Self);
  FLineNumDynamicRadio.Parent := lRow;
  FLineNumDynamicRadio.Caption := 'Dynamic width';
  FLineNumDynamicRadio.OnClick := StyleControlChange;

  FLineNumFixedRadio := TRadioButton.Create(Self);
  FLineNumFixedRadio.Parent := lRow;
  FLineNumFixedRadio.Caption := 'Fixed width';
  FLineNumFixedRadio.OnClick := StyleControlChange;

  lRow := CreateLabeledRow(lLocalStack, 'Left',
    FLineNumPaddingLeftLabel, lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FLineNumPaddingLeftEdit := TSpinEdit.Create(Self);
  FLineNumPaddingLeftEdit.Parent := lFieldHost;
  FLineNumPaddingLeftEdit.MinValue := 0;
  FLineNumPaddingLeftEdit.MaxValue := 100;
  FLineNumPaddingLeftEdit.OnChange := StyleControlChange;

  lRow := CreateLabeledRow(lLocalStack, 'Right',
    FLineNumPaddingRightLabel, lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FLineNumPaddingRightEdit := TSpinEdit.Create(Self);
  FLineNumPaddingRightEdit.Parent := lFieldHost;
  FLineNumPaddingRightEdit.MinValue := 0;
  FLineNumPaddingRightEdit.MaxValue := 100;
  FLineNumPaddingRightEdit.OnChange := StyleControlChange;

  { Logging section on General card }
  FLogSection := CreateGroupSection(FGeneralCard, 'Logging');
  lLocalStack := CreateStackPanel(FLogSection, spoVertical, Scale(cRowGap), False);
  ConfigureManualSectionStack(lLocalStack);

  FLogEnabledCheck := TCheckBox.Create(Self);
  FLogEnabledCheck.Parent := lLocalStack;
  FLogEnabledCheck.Caption := 'Enable logging';
  FLogEnabledCheck.OnClick := StyleControlChange;
  ConfigureVerticalStackChild(lLocalStack, FLogEnabledCheck);

  FLogSeverityPanel := CreateLabeledRow(lLocalStack, 'Severity', FLogSeverityLabel, lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, FLogSeverityPanel);
  FLogSeverityCombo := TComboBox.Create(Self);
  FLogSeverityCombo.Parent := lFieldHost;
  FLogSeverityCombo.Style := csDropDownList;
  AddComboIntItem(FLogSeverityCombo, 'Error', 1);
  AddComboIntItem(FLogSeverityCombo, 'Info', 2);
  AddComboIntItem(FLogSeverityCombo, 'Debug', 3);
  FLogSeverityCombo.OnChange := StyleControlChange;

  FLogOutputPanel := CreateLabeledRow(lLocalStack, 'Output', FLogOutputLabel, lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, FLogOutputPanel);
  FLogOutputCombo := TComboBox.Create(Self);
  FLogOutputCombo.Parent := lFieldHost;
  FLogOutputCombo.Style := csDropDownList;
  AddComboIntItem(FLogOutputCombo, 'ODS', 0);
  AddComboIntItem(FLogOutputCombo, 'File', 1);
  FLogOutputCombo.OnChange := StyleControlChange;

  FEditorSection := CreateGroupSection(FEditorCard, 'Editor');
  FEditorSection.Align := alTop;
  FEditorSection.Height := Scale(300);
  lLocalStack := CreateStackPanel(FEditorSection, spoVertical, Scale(cRowGap), False);
  ConfigureManualSectionStack(lLocalStack);

  lRow := CreateCheckRow(lLocalStack, 'Show status bar', FShowStatusBarCheck, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FShowStatusBarCheck.OnClick := StyleControlChange;

  { Status bar panel visibility grid (2 rows x 3 columns) inside Editor section }
  FStatusBarPanelsRow := CreateHostPanel(lLocalStack);
  ConfigureVerticalStackChild(lLocalStack, FStatusBarPanelsRow);

  FStatusPanelFileCheck := TCheckBox.Create(Self);
  FStatusPanelFileCheck.Parent := FStatusBarPanelsRow;
  FStatusPanelFileCheck.Caption := 'File path';
  FStatusPanelFileCheck.OnClick := StyleControlChange;

  FStatusPanelPosCheck := TCheckBox.Create(Self);
  FStatusPanelPosCheck.Parent := FStatusBarPanelsRow;
  FStatusPanelPosCheck.Caption := 'Position';
  FStatusPanelPosCheck.OnClick := StyleControlChange;

  FStatusPanelLexerCheck := TCheckBox.Create(Self);
  FStatusPanelLexerCheck.Parent := FStatusBarPanelsRow;
  FStatusPanelLexerCheck.Caption := 'Lexer';
  FStatusPanelLexerCheck.OnClick := StyleControlChange;

  FStatusPanelEncodingCheck := TCheckBox.Create(Self);
  FStatusPanelEncodingCheck.Parent := FStatusBarPanelsRow;
  FStatusPanelEncodingCheck.Caption := 'Encoding';
  FStatusPanelEncodingCheck.OnClick := StyleControlChange;

  FStatusPanelThemeCheck := TCheckBox.Create(Self);
  FStatusPanelThemeCheck.Parent := FStatusBarPanelsRow;
  FStatusPanelThemeCheck.Caption := 'Theme';
  FStatusPanelThemeCheck.OnClick := StyleControlChange;

  FStatusPanelLoadCheck := TCheckBox.Create(Self);
  FStatusPanelLoadCheck.Parent := FStatusBarPanelsRow;
  FStatusPanelLoadCheck.Caption := 'Load';
  FStatusPanelLoadCheck.OnClick := StyleControlChange;

  lRow := CreateCheckRow(lLocalStack, 'Backspace unindents', FBackSpaceUnIndentsCheck, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FBackSpaceUnIndentsCheck.OnClick := StyleControlChange;

  lRow := CreateLabeledRow(lLocalStack, 'Indentation guide style', FIndentationGuidesLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FIndentationGuidesCombo := TComboBox.Create(Self);
  FIndentationGuidesCombo.Parent := lFieldHost;
  FIndentationGuidesCombo.Align := alClient;
  FIndentationGuidesCombo.Style := csDropDownList;
  AddComboIntItem(FIndentationGuidesCombo, 'Invisible', 0);
  AddComboIntItem(FIndentationGuidesCombo, 'Real indentation', 1);
  AddComboIntItem(FIndentationGuidesCombo, 'Python style', 2);
  AddComboIntItem(FIndentationGuidesCombo, 'Standard style', 3);
  FIndentationGuidesCombo.OnChange := StyleControlChange;

  lRow := CreateLabeledRow(lLocalStack, 'White space style', FWhiteSpaceStyleLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FWhiteSpaceStyleCombo := TComboBox.Create(Self);
  FWhiteSpaceStyleCombo.Parent := lFieldHost;
  FWhiteSpaceStyleCombo.Align := alClient;
  FWhiteSpaceStyleCombo.Style := csDropDownList;
  AddComboIntItem(FWhiteSpaceStyleCombo, 'Invisible', 0);
  AddComboIntItem(FWhiteSpaceStyleCombo, 'Always visible', 1);
  AddComboIntItem(FWhiteSpaceStyleCombo, 'After indentation', 2);
  AddComboIntItem(FWhiteSpaceStyleCombo, 'Only indentation', 3);
  FWhiteSpaceStyleCombo.OnChange := StyleControlChange;

  lRow := CreateLabeledRow(lLocalStack, 'White space size', FWhiteSpaceSizeLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FWhiteSpaceSizeEdit := TSpinEdit.Create(Self);
  FWhiteSpaceSizeEdit.Parent := lFieldHost;
  FWhiteSpaceSizeEdit.Align := alLeft;
  FWhiteSpaceSizeEdit.Width := Scale(cSpinWidth);
  FWhiteSpaceSizeEdit.MinValue := -50;
  FWhiteSpaceSizeEdit.MaxValue := 50;
  FWhiteSpaceSizeEdit.OnChange := StyleControlChange;

  lRow := CreateLabeledRow(lLocalStack, 'Upper line spacing', FUpperLineSpacingLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FUpperLineSpacingEdit := TSpinEdit.Create(Self);
  FUpperLineSpacingEdit.Parent := lFieldHost;
  FUpperLineSpacingEdit.Align := alLeft;
  FUpperLineSpacingEdit.Width := Scale(cSpinWidth);
  FUpperLineSpacingEdit.MinValue := -10;
  FUpperLineSpacingEdit.MaxValue := MaxInt;
  FUpperLineSpacingEdit.OnChange := StyleControlChange;

  lRow := CreateLabeledRow(lLocalStack, 'Lower line spacing', FLowerLineSpacingLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FLowerLineSpacingEdit := TSpinEdit.Create(Self);
  FLowerLineSpacingEdit.Parent := lFieldHost;
  FLowerLineSpacingEdit.Align := alLeft;
  FLowerLineSpacingEdit.Width := Scale(cSpinWidth);
  FLowerLineSpacingEdit.MinValue := -10;
  FLowerLineSpacingEdit.MaxValue := MaxInt;
  FLowerLineSpacingEdit.OnChange := StyleControlChange;

  FTabWidthPanel.Parent := lLocalStack;
  ConfigureVerticalStackChild(lLocalStack, FTabWidthPanel);

  { Padding section on Editor card }
  FTextPaddingSection := CreateGroupSection(FEditorCard, 'Padding');
  FTextPaddingSection.Align := alTop;
  FTextPaddingSection.Height := Scale(80);
  lLocalStack := CreateStackPanel(FTextPaddingSection, spoVertical, Scale(cRowGap), False);
  ConfigureManualSectionStack(lLocalStack);

  lRow := CreateLabeledRow(lLocalStack, 'Left',
    FTextPaddingLeftLabel, lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FTextPaddingLeftEdit := TSpinEdit.Create(Self);
  FTextPaddingLeftEdit.Parent := lFieldHost;
  FTextPaddingLeftEdit.MinValue := 0;
  FTextPaddingLeftEdit.MaxValue := 100;
  FTextPaddingLeftEdit.OnChange := StyleControlChange;

  lRow := CreateLabeledRow(lLocalStack, 'Right',
    FTextPaddingRightLabel, lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FTextPaddingRightEdit := TSpinEdit.Create(Self);
  FTextPaddingRightEdit.Parent := lFieldHost;
  FTextPaddingRightEdit.MinValue := 0;
  FTextPaddingRightEdit.MaxValue := 100;
  FTextPaddingRightEdit.OnChange := StyleControlChange;

  FSelectionSection := CreateGroupSection(FSelectionCard, 'Selection');
  FSelectionSection.Align := alTop;
  FSelectionSection.Height := Scale(120);
  lLocalStack := CreateStackPanel(FSelectionSection, spoVertical, Scale(cRowGap), False);
  ConfigureManualSectionStack(lLocalStack);

  lRow := CreateCheckRow(lLocalStack, 'Select full line', FSelectFullLineCheck, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FSelectFullLineCheck.OnClick := StyleControlChange;

  lRow := CreateHostPanel(lLocalStack);
  lRow.Height := Scale(cInputHeight);
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FUseSelectionForeColorCheck := TCheckBox.Create(Self);
  FUseSelectionForeColorCheck.Parent := lRow;
  FUseSelectionForeColorCheck.Caption := 'Text color';
  FUseSelectionForeColorCheck.Left := 0;
  FUseSelectionForeColorCheck.Top := 0;
  FUseSelectionForeColorCheck.OnClick := StyleControlChange;
  FSelectionForeColorBox := TPanel.Create(Self);
  FSelectionForeColorBox.Parent := lRow;
  FSelectionForeColorBox.SetBounds(Scale(150), 0, Scale(48), Scale(cColorPreviewHeight));
  FSelectionForeColorBox.BevelOuter := bvRaised;
  ConfigureColorPreviewPanel(FSelectionForeColorBox);
  FSelectionForeColorBox.OnClick := ColorPanelClick;

  lRow := CreateLabeledRow(lLocalStack, 'Selection alpha', FSelectionAlphaLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FSelectionAlphaEdit := TSpinEdit.Create(Self);
  FSelectionAlphaEdit.Parent := lFieldHost;
  FSelectionAlphaEdit.Align := alLeft;
  FSelectionAlphaEdit.Width := Scale(cSpinWidth);
  FSelectionAlphaEdit.MinValue := 0;
  FSelectionAlphaEdit.MaxValue := 256;
  FSelectionAlphaEdit.OnChange := StyleControlChange;

  FSearchHighlightSection := CreateGroupSection(FSelectionCard, 'Search Highlight');
  FSearchHighlightSection.Align := alTop;
  FSearchHighlightSection.Height := Scale(130);
  lLocalStack := CreateStackPanel(FSearchHighlightSection, spoVertical, Scale(cRowGap), False);
  ConfigureManualSectionStack(lLocalStack);

  lRow := CreateLabeledRow(lLocalStack, 'Highlight color', FHighlightLabel,
    lFieldHost, Scale(cColorPreviewHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FHighlightBox.Parent := lFieldHost;
  FHighlightBox.Align := alLeft;
  FHighlightBox.Width := Scale(cHighlightPreviewWidth);

  lRow := CreateLabeledRow(lLocalStack, 'Transparency', FTransparencyLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FTransparencyEdit.Parent := lFieldHost;
  FTransparencyEdit.Align := alLeft;
  FTransparencyEdit.Width := Scale(cSpinWidth);

  lRow := CreateLabeledRow(lLocalStack, 'Outline', FOutlineLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FOutlineEdit.Parent := lFieldHost;
  FOutlineEdit.Align := alLeft;
  FOutlineEdit.Width := Scale(cSpinWidth);

  // These rows were temporary bootstrap hosts before the dedicated
  // Selection/Search Highlight rows were created. Keep them out of the
  // General card so that rendering controls remain the only content there.
  FHighlightPanel.Visible := False;
  FMiscOptionsRow.Visible := False;

  FSmartHighlightSection := CreateGroupSection(FSelectionCard, 'Smart Highlighting');
  FSmartHighlightSection.Align := alTop;
  FSmartHighlightSection.Height := Scale(130);
  lLocalStack := CreateStackPanel(FSmartHighlightSection, spoVertical, Scale(cRowGap), False);
  ConfigureManualSectionStack(lLocalStack);

  lRow := CreateLabeledRow(lLocalStack, 'Highlighting style', FSmartHighlightStyleLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FSmartHighlightStyleCombo := TComboBox.Create(Self);
  FSmartHighlightStyleCombo.Parent := lFieldHost;
  FSmartHighlightStyleCombo.Align := alClient;
  FSmartHighlightStyleCombo.Style := csDropDownList;
  AddComboIntItem(FSmartHighlightStyleCombo, 'Underlined (straight line)', 0);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Underlined (squiggly)', 1);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Underlined (T shapes)', 2);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Underlined (diag. hatches)', 3);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Strike out', 4);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Invisible', 5);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Straight box', 6);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Filled rounded box', 7);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Filled straight box (distinct)', 8);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Underlined (dashed)', 9);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Underlined (dotted)', 10);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Underlined (squiggly small)', 11);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Dotted box', 12);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Underlined (squiggly, fast)', 13);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Underlined (2px, inset)', 14);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Underlined (1px, inset)', 15);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Filled straight box (full)', 16);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Colorized text', 17);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Triangle at start', 18);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Triangle at first character', 19);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Gradient top/down', 20);
  AddComboIntItem(FSmartHighlightStyleCombo, 'Gradient center/borders', 21);
  FSmartHighlightStyleCombo.OnChange := StyleControlChange;

  lRow := CreateLabeledRow(lLocalStack, 'Filling alpha', FSmartHighlightFillAlphaLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FSmartHighlightFillAlphaEdit := TSpinEdit.Create(Self);
  FSmartHighlightFillAlphaEdit.Parent := lFieldHost;
  FSmartHighlightFillAlphaEdit.Align := alLeft;
  FSmartHighlightFillAlphaEdit.Width := Scale(cSpinWidth);
  FSmartHighlightFillAlphaEdit.MinValue := 0;
  FSmartHighlightFillAlphaEdit.MaxValue := 255;
  FSmartHighlightFillAlphaEdit.OnChange := StyleControlChange;

  lRow := CreateLabeledRow(lLocalStack, 'Outline alpha', FSmartHighlightOutlineAlphaLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FSmartHighlightOutlineAlphaEdit := TSpinEdit.Create(Self);
  FSmartHighlightOutlineAlphaEdit.Parent := lFieldHost;
  FSmartHighlightOutlineAlphaEdit.Align := alLeft;
  FSmartHighlightOutlineAlphaEdit.Width := Scale(cSpinWidth);
  FSmartHighlightOutlineAlphaEdit.MinValue := 0;
  FSmartHighlightOutlineAlphaEdit.MaxValue := 255;
  FSmartHighlightOutlineAlphaEdit.OnChange := StyleControlChange;

  FSearchSection := CreateGroupSection(FSelectionCard, 'Search');
  FSearchSection.Align := alTop;
  FSearchSection.Height := Scale(70);
  FSearchSyncRow.Parent := FSearchSection;
  ConfigureManualSectionRow(FSearchSyncRow);

  FWrappingSection := CreateGroupSection(FWrappingCard, 'Line Wrapping');
  FWrappingSection.Align := alTop;
  FWrappingSection.Height := Scale(200);
  lLocalStack := CreateStackPanel(FWrappingSection, spoVertical, Scale(cRowGap), False);
  ConfigureManualSectionStack(lLocalStack);

  lRow := CreateLabeledRow(lLocalStack, 'Wrap mode', FWrapModeLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FWrapModeCombo := TComboBox.Create(Self);
  FWrapModeCombo.Parent := lFieldHost;
  FWrapModeCombo.Align := alClient;
  FWrapModeCombo.Style := csDropDownList;
  AddComboIntItem(FWrapModeCombo, 'No line wrapping', 0);
  AddComboIntItem(FWrapModeCombo, 'Word boundaries', 1);
  AddComboIntItem(FWrapModeCombo, 'Any character', 2);
  AddComboIntItem(FWrapModeCombo, 'Whitespace characters', 3);
  FWrapModeCombo.OnChange := StyleControlChange;

  lRow := CreateCheckRow(lLocalStack, 'End of subline', FWrapFlagEndCheck, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FWrapFlagEndCheck.OnClick := StyleControlChange;
  lRow := CreateCheckRow(lLocalStack, 'Start of subline', FWrapFlagStartCheck, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FWrapFlagStartCheck.OnClick := StyleControlChange;
  lRow := CreateCheckRow(lLocalStack, 'Line number margin', FWrapFlagMarginCheck, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FWrapFlagMarginCheck.OnClick := StyleControlChange;
  lRow := CreateCheckRow(lLocalStack, 'Subline end near text', FWrapLocationEndCheck, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FWrapLocationEndCheck.OnClick := StyleControlChange;
  lRow := CreateCheckRow(lLocalStack, 'Subline start near text', FWrapLocationStartCheck, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FWrapLocationStartCheck.OnClick := StyleControlChange;

  FMarginsSection := CreateGroupSection(FWrappingCard, 'Margins');
  FMarginsSection.Align := alTop;
  FMarginsSection.Height := Scale(180);
  FMiscChecksRow.Parent := FMarginsSection;
  ConfigureManualSectionRow(FMiscChecksRow);
  FGutterChecksRow.Parent := FMarginsSection;
  ConfigureManualSectionRow(FGutterChecksRow);
  FLineWrappingCheck.Visible := False;

  FGutterStylePanel := CreateLabeledRow(FMiscStack, 'Gutter style', FGutterStyleLabel,
    lFieldHost, Scale(cInputHeight));
  FGutterStylePanel.Parent := FMarginsSection;
  ConfigureManualSectionRow(FGutterStylePanel);
  FGutterStyleCombo := TComboBox.Create(Self);
  FGutterStyleCombo.Parent := lFieldHost;
  FGutterStyleCombo.Align := alClient;
  FGutterStyleCombo.Style := csDropDownList;
  FGutterStyleCombo.Items.Add('Line number margin');
  FGutterStyleCombo.Items.Add('Bookmark margin');
  FGutterStyleCombo.Items.Add('Fold margin');
  FGutterStyleCombo.OnChange := GutterStyleComboChange;

  FGutterColorsRow := CreateHostPanel(FMiscStack);
  FGutterColorsRow.Parent := FMarginsSection;
  ConfigureManualSectionRow(FGutterColorsRow);
  FGutterForegroundLabel := TLabel.Create(Self);
  FGutterForegroundLabel.Parent := FGutterColorsRow;
  FGutterForegroundLabel.AutoSize := False;
  FGutterForegroundLabel.Caption := 'Foreground';

  FGutterForegroundBox := TPanel.Create(Self);
  FGutterForegroundBox.Parent := FGutterColorsRow;
  FGutterForegroundBox.BevelOuter := bvRaised;
  ConfigureColorPreviewPanel(FGutterForegroundBox);
  FGutterForegroundBox.OnClick := ColorPanelClick;

  FGutterBackgroundLabel := TLabel.Create(Self);
  FGutterBackgroundLabel.Parent := FGutterColorsRow;
  FGutterBackgroundLabel.AutoSize := False;
  FGutterBackgroundLabel.Caption := 'Background';

  FGutterBackgroundBox := TPanel.Create(Self);
  FGutterBackgroundBox.Parent := FGutterColorsRow;
  FGutterBackgroundBox.BevelOuter := bvRaised;
  ConfigureColorPreviewPanel(FGutterBackgroundBox);
  FGutterBackgroundBox.OnClick := ColorPanelClick;

  FCaretSection := CreateGroupSection(FCaretPasteCard, 'Caret');
  FCaretSection.Align := alTop;
  FCaretSection.Height := Scale(130);
  lLocalStack := CreateStackPanel(FCaretSection, spoVertical, Scale(cRowGap), False);
  ConfigureManualSectionStack(lLocalStack);

  lRow := CreateCheckRow(lLocalStack, 'Caret beyond line endings', FCaretBeyondLineEndingsCheck, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FCaretBeyondLineEndingsCheck.OnClick := StyleControlChange;
  lRow := CreateCheckRow(lLocalStack, 'Wrap caret at line start', FWrapCursorAtLineStartCheck, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FWrapCursorAtLineStartCheck.OnClick := StyleControlChange;
  lRow := CreateLabeledRow(lLocalStack, 'Sticky caret mode', FStickyCaretLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FStickyCaretCombo := TComboBox.Create(Self);
  FStickyCaretCombo.Parent := lFieldHost;
  FStickyCaretCombo.Align := alClient;
  FStickyCaretCombo.Style := csDropDownList;
  AddComboIntItem(FStickyCaretCombo, 'Off', 0);
  AddComboIntItem(FStickyCaretCombo, 'Always on', 1);
  AddComboIntItem(FStickyCaretCombo, 'On after white space', 2);
  FStickyCaretCombo.OnChange := StyleControlChange;

  FCopyPasteSection := CreateGroupSection(FCaretPasteCard, 'Copy & Paste');
  FCopyPasteSection.Align := alTop;
  FCopyPasteSection.Height := Scale(90);
  lLocalStack := CreateStackPanel(FCopyPasteSection, spoVertical, Scale(cRowGap), False);
  ConfigureManualSectionStack(lLocalStack);

  lRow := CreateCheckRow(lLocalStack, 'Multi paste', FMultiPasteCheck, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FMultiPasteCheck.OnClick := StyleControlChange;
  lRow := CreateCheckRow(lLocalStack, 'Convert EOL on paste', FPasteConvertEndingsCheck, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FPasteConvertEndingsCheck.OnClick := StyleControlChange;

  FFoldingSection := CreateGroupSection(FFoldingCard, 'Code Folding');
  FFoldingSection.Align := alTop;
  FFoldingSection.Height := Scale(130);
  lLocalStack := CreateStackPanel(FFoldingSection, spoVertical, Scale(cRowGap), False);
  ConfigureManualSectionStack(lLocalStack);

  lRow := CreateCheckRow(lLocalStack, 'Folding lines', FFoldingLinesCheck, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FFoldingLinesCheck.OnClick := StyleControlChange;
  lRow := CreateLabeledRow(lLocalStack, 'Folding text', FFoldingTextLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FFoldingTextEdit := TEdit.Create(Self);
  FFoldingTextEdit.Parent := lFieldHost;
  FFoldingTextEdit.Align := alClient;
  FFoldingTextEdit.OnChange := StyleControlChange;
  lRow := CreateLabeledRow(lLocalStack, 'Folding text style', FFoldDisplayTextStyleLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FFoldDisplayTextStyleCombo := TComboBox.Create(Self);
  FFoldDisplayTextStyleCombo.Parent := lFieldHost;
  FFoldDisplayTextStyleCombo.Align := alClient;
  FFoldDisplayTextStyleCombo.Style := csDropDownList;
  AddComboIntItem(FFoldDisplayTextStyleCombo, 'Hidden', 0);
  AddComboIntItem(FFoldDisplayTextStyleCombo, 'Standard', 1);
  AddComboIntItem(FFoldDisplayTextStyleCombo, 'Boxed', 2);
  FFoldDisplayTextStyleCombo.OnChange := StyleControlChange;
  lRow := CreateLabeledRow(lLocalStack, 'Fold marker style', FFoldMarkerStyleLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FFoldMarkerStyleCombo := TComboBox.Create(Self);
  FFoldMarkerStyleCombo.Parent := lFieldHost;
  FFoldMarkerStyleCombo.Align := alClient;
  FFoldMarkerStyleCombo.Style := csDropDownList;
  AddComboIntItem(FFoldMarkerStyleCombo, 'Arrow', Ord(fmsArrow));
  AddComboIntItem(FFoldMarkerStyleCombo, 'Plus / Minus', Ord(fmsPlusMinus));
  AddComboIntItem(FFoldMarkerStyleCombo, 'Circle tree', Ord(fmsCircleTree));
  AddComboIntItem(FFoldMarkerStyleCombo, 'Box tree', Ord(fmsBoxTree));
  FFoldMarkerStyleCombo.OnChange := StyleControlChange;

  FDocumentSection := CreateGroupSection(FFoldingCard, 'Document');
  FDocumentSection.Align := alTop;
  FDocumentSection.Height := Scale(70);
  FFileSizeLimitPanel.Parent := FDocumentSection;
  ConfigureManualSectionRow(FFileSizeLimitPanel);

  FPrintingSection := CreateGroupSection(FFoldingCard, 'Printing');
  FPrintingSection.Align := alTop;
  FPrintingSection.Height := Scale(70);
  lLocalStack := CreateStackPanel(FPrintingSection, spoVertical, Scale(cRowGap), False);
  ConfigureManualSectionStack(lLocalStack);

  lRow := CreateLabeledRow(lLocalStack, 'Magnification', FPrintMagnificationLabel,
    lFieldHost, Scale(cInputHeight));
  ConfigureVerticalStackChild(lLocalStack, lRow);
  FPrintMagnificationEdit := TSpinEdit.Create(Self);
  FPrintMagnificationEdit.Parent := lFieldHost;
  FPrintMagnificationEdit.Align := alLeft;
  FPrintMagnificationEdit.Width := Scale(cSpinWidth);
  FPrintMagnificationEdit.MinValue := -10;
  FPrintMagnificationEdit.MaxValue := MaxInt;
  FPrintMagnificationEdit.OnChange := StyleControlChange;

  RefreshSectionLayout;
end;

function TDSciVisualSettingsDialog.NormalizeExtensions(const AText: string): string;
var
  lValue: string;
begin
  lValue := StringReplace(AText, #13, ' ', [rfReplaceAll]);
  lValue := StringReplace(lValue, #10, ' ', [rfReplaceAll]);
  lValue := StringReplace(lValue, #9, ' ', [rfReplaceAll]);
  lValue := StringReplace(lValue, ',', ' ', [rfReplaceAll]);
  lValue := StringReplace(lValue, ';', ' ', [rfReplaceAll]);
  while Pos('  ', lValue) > 0 do
    lValue := StringReplace(lValue, '  ', ' ', [rfReplaceAll]);
  Result := Trim(lValue);
end;

function TDSciVisualSettingsDialog.SelectedThemeName: string;
begin
  if (FThemeCombo.ItemIndex < 0) or (FThemeCombo.Items.Count = 0) then
    Exit(Trim(FConfig.ThemeName));

  if SameText(FThemeCombo.Items[FThemeCombo.ItemIndex], '(Embedded defaults)') then
    Exit('');
  Result := Trim(FThemeCombo.Items[FThemeCombo.ItemIndex]);
end;

function TDSciVisualSettingsDialog.SelectedLanguage: TDSciVisualStyleGroup;
begin
  if FLanguageCombo.ItemIndex < 0 then
    Exit(nil);
  Result := TDSciVisualStyleGroup(FLanguageCombo.Items.Objects[FLanguageCombo.ItemIndex]);
end;

function TDSciVisualSettingsDialog.SelectedStyle: TDSciVisualStyleData;
var
  lNamedStyle: TDSciVisualNamedStyle;
begin
  if FStyleCombo.ItemIndex < 0 then
    Exit(nil);
  lNamedStyle := TDSciVisualNamedStyle(FStyleCombo.Items.Objects[FStyleCombo.ItemIndex]);
  if lNamedStyle = nil then
    Exit(nil);
  Result := lNamedStyle.Style;
end;

function TDSciVisualSettingsDialog.SelectedGutterStyleName: string;
begin
  if (FGutterStyleCombo = nil) or (FGutterStyleCombo.ItemIndex < 0) or
     (FGutterStyleCombo.ItemIndex >= FGutterStyleCombo.Items.Count) then
    Exit('');
  Result := Trim(FGutterStyleCombo.Items[FGutterStyleCombo.ItemIndex]);
end;

procedure TDSciVisualSettingsDialog.LoadThemeList;
var
  lThemeFileName: string;
  lThemeName: string;
  lThemeNames: TStringList;
  lThemeDirectory: string;
begin
  FThemeCombo.Items.BeginUpdate;
  try
    FThemeCombo.Items.Clear;
    DiscoverThemeDirectories;

    lThemeNames := TStringList.Create;
    try
      lThemeNames.CaseSensitive := False;
      lThemeNames.Sorted := True;
      lThemeNames.Duplicates := dupIgnore;

      for lThemeDirectory in FThemeDirectories do
        for lThemeFileName in TDirectory.GetFiles(lThemeDirectory, '*.xml') do
        begin
          lThemeName := ChangeFileExt(ExtractFileName(lThemeFileName), '');
          if Trim(lThemeName) <> '' then
            lThemeNames.Add(lThemeName);
        end;

      if lThemeNames.Count = 0 then
      begin
        FCatalog.PopulateThemeNames(FThemeCombo.Items);
        FThemeCombo.ItemIndex := 0;
        FThemeCombo.Enabled := False;
        Exit;
      end;

      FThemeCombo.Items.Add('(Embedded defaults)');
      FThemeCombo.Items.AddStrings(lThemeNames);
      if (Trim(FConfig.ThemeName) <> '') and
         (FThemeCombo.Items.IndexOf(FConfig.ThemeName) < 0) then
        FThemeCombo.Items.Add(FConfig.ThemeName);

      if Trim(FConfig.ThemeName) <> '' then
        FThemeCombo.ItemIndex := Max(0, FThemeCombo.Items.IndexOf(FConfig.ThemeName))
      else
        FThemeCombo.ItemIndex := 0;
      if FThemeCombo.ItemIndex < 0 then
        FThemeCombo.ItemIndex := 0;
      FThemeCombo.Enabled := True;
    finally
      lThemeNames.Free;
    end;
  finally
    FThemeCombo.Items.EndUpdate;
  end;
end;

procedure TDSciVisualSettingsDialog.LoadLanguageList(const APreferredLanguage: string);
var
  lIndex: Integer;
  lName: string;
begin
  FCatalog.PopulateLanguageNames(FLanguageCombo.Items);
  for lIndex := 0 to FLanguageCombo.Items.Count - 1 do
  begin
    lName := FLanguageCombo.Items[lIndex];
    FLanguageCombo.Items.Objects[lIndex] := FCatalog.FindLanguage(lName);
  end;

  if APreferredLanguage <> '' then
    FLanguageCombo.ItemIndex := FLanguageCombo.Items.IndexOf(APreferredLanguage)
  else
    FLanguageCombo.ItemIndex := Max(0, FLanguageCombo.Items.IndexOf('default'));
  if FLanguageCombo.ItemIndex < 0 then
    FLanguageCombo.ItemIndex := 0;
end;

procedure TDSciVisualSettingsDialog.LoadStyleList(const APreferredStyle: string);
var
  lGroup: TDSciVisualStyleGroup;
  lIndex: Integer;
  lNamedStyle: TDSciVisualNamedStyle;
  lStyle: TDSciVisualStyleData;
begin
  for lIndex := 0 to FStyleCombo.Items.Count - 1 do
    FStyleCombo.Items.Objects[lIndex].Free;
  FStyleCombo.Items.Clear;

  lGroup := SelectedLanguage;
  if lGroup = nil then
    Exit;

  for lStyle in lGroup.Styles do
  begin
    lNamedStyle := TDSciVisualNamedStyle.Create;
    lNamedStyle.Style := lStyle;
    if lStyle.Kind = dvskGlobal then
      lNamedStyle.Caption := lStyle.Name + ' (Global)'
    else
      lNamedStyle.Caption := lStyle.Name;
    FStyleCombo.Items.AddObject(lNamedStyle.Caption, lNamedStyle);
  end;

  if APreferredStyle <> '' then
    for lIndex := 0 to FStyleCombo.Items.Count - 1 do
    begin
      lNamedStyle := TDSciVisualNamedStyle(FStyleCombo.Items.Objects[lIndex]);
      if (lNamedStyle <> nil) and SameText(lNamedStyle.Style.Name, APreferredStyle) then
      begin
        FStyleCombo.ItemIndex := lIndex;
        Break;
      end;
    end;

  if FStyleCombo.ItemIndex < 0 then
    FStyleCombo.ItemIndex := 0;
end;

procedure TDSciVisualSettingsDialog.LoadMiscControls;
begin
  SelectComboInt(FTechnologyCombo, TDSciTechnologyToInt(FConfig.Technology));
  SelectComboInt(FFontQualityCombo, TDSciFontQualityToInt(FConfig.FontQuality));
  FFontLocaleEdit.Text := FConfig.FontLocale;
  FHighlightBox.Color := FConfig.HighlightColor;
  FTransparencyEdit.Value := FConfig.HighlightAlpha;
  FOutlineEdit.Value := FConfig.HighlightOutlineAlpha;
  FTabWidthEdit.Value := FConfig.TabWidth;
  FFileSizeLimitEdit.Value := Integer(EnsureRange(FConfig.FileSizeLimit, Int64(0), Int64(MaxInt)));
  FLineNumberingCheck.Checked := FConfig.LineNumbering;
  FLineNumDynamicRadio.Checked := FConfig.LineNumberWidthMode = lnwmDynamic;
  FLineNumFixedRadio.Checked := FConfig.LineNumberWidthMode = lnwmFixed;
  FLineNumPaddingLeftEdit.Value := FConfig.LineNumberPaddingLeft;
  FLineNumPaddingRightEdit.Value := FConfig.LineNumberPaddingRight;
  FTextPaddingLeftEdit.Value := FConfig.TextPaddingLeft;
  FTextPaddingRightEdit.Value := FConfig.TextPaddingRight;
  FBookmarkMarginCheck.Checked := FConfig.BookmarkMarginVisible;
  FFoldMarginCheck.Checked := FConfig.FoldMarginVisible;
  FLineWrappingCheck.Checked := FConfig.LineWrapping;
  FSearchSyncCheck.Checked := FConfig.SearchSync;

  { Logging }
  FLogEnabledCheck.Checked := FConfig.LogEnabled;
  SelectComboInt(FLogSeverityCombo, FConfig.LogLevel);
  SelectComboInt(FLogOutputCombo, FConfig.LogOutput);
  { Editor settings }
  FShowStatusBarCheck.Checked := FConfig.ShowStatusBar;
  FStatusPanelFileCheck.Checked := FConfig.StatusPanelFileVisible;
  FStatusPanelPosCheck.Checked := FConfig.StatusPanelPosVisible;
  FStatusPanelLexerCheck.Checked := FConfig.StatusPanelLexerVisible;
  FStatusPanelEncodingCheck.Checked := FConfig.StatusPanelEncodingVisible;
  FStatusPanelThemeCheck.Checked := FConfig.StatusPanelThemeVisible;
  FStatusPanelLoadCheck.Checked := FConfig.StatusPanelLoadVisible;
  FBackSpaceUnIndentsCheck.Checked := FConfig.BackSpaceUnIndents;
  SelectComboInt(FIndentationGuidesCombo, TDSciIndentViewToInt(FConfig.IndentationGuides));
  SelectComboInt(FWhiteSpaceStyleCombo, TDSciWhiteSpaceToInt(FConfig.WhiteSpaceStyle));
  FWhiteSpaceSizeEdit.Value := FConfig.WhiteSpaceSize;
  FUpperLineSpacingEdit.Value := FConfig.UpperLineSpacing;
  FLowerLineSpacingEdit.Value := FConfig.LowerLineSpacing;
  FSelectFullLineCheck.Checked := FConfig.SelectFullLine;
  FUseSelectionForeColorCheck.Checked := FConfig.UseSelectionForeColor;
  FSelectionForeColorBox.Color := FConfig.SelectionForeColor;
  FSelectionAlphaEdit.Value := FConfig.SelectionAlpha;
  SelectComboInt(FSmartHighlightStyleCombo, TDSciIndicatorStyleToInt(FConfig.SmartHighlightStyle));
  FSmartHighlightFillAlphaEdit.Value := FConfig.SmartHighlightFillAlpha;
  FSmartHighlightOutlineAlphaEdit.Value := FConfig.SmartHighlightOutlineAlpha;
  SelectComboInt(FWrapModeCombo, TDSciWrapToInt(FConfig.WrapMode));
  FWrapFlagEndCheck.Checked :=
    scwvfEND in FConfig.WrapVisualFlags;
  FWrapFlagStartCheck.Checked :=
    scwvfSTART in FConfig.WrapVisualFlags;
  FWrapFlagMarginCheck.Checked :=
    scwvfMARGIN in FConfig.WrapVisualFlags;
  FWrapLocationEndCheck.Checked :=
    scwvlEND_BY_TEXT in FConfig.WrapVisualFlagsLocation;
  FWrapLocationStartCheck.Checked :=
    scwvlSTART_BY_TEXT in FConfig.WrapVisualFlagsLocation;
  FCaretBeyondLineEndingsCheck.Checked := FConfig.CaretBeyondLineEndings;
  FWrapCursorAtLineStartCheck.Checked := FConfig.WrapCursorAtLineStart;
  SelectComboInt(FStickyCaretCombo, TDSciCaretStickyToInt(FConfig.CaretSticky));
  FMultiPasteCheck.Checked := FConfig.MultiPaste;
  FPasteConvertEndingsCheck.Checked := FConfig.PasteConvertEndings;
  FFoldingLinesCheck.Checked := FConfig.FoldingLines;
  FFoldingTextEdit.Text := FConfig.FoldingText;
  SelectComboInt(FFoldDisplayTextStyleCombo,
    TDSciFoldDisplayTextStyleToInt(FConfig.FoldDisplayTextStyle));
  SelectComboInt(FFoldMarkerStyleCombo, Ord(FConfig.FoldMarkerStyle));
  FPrintMagnificationEdit.Value := FConfig.PrintMagnification;
  if FGutterStyleCombo.Items.Count > 0 then
  begin
    if FGutterStyleCombo.ItemIndex < 0 then
      FGutterStyleCombo.ItemIndex := 0;
    LoadSelectedGutterStyleControls;
  end;
end;

procedure TDSciVisualSettingsDialog.LoadSelectedGutterStyleControls;
var
  lEffectiveStyle: TDSciVisualStyleData;
  lOverride: TDSciVisualStyleData;
  lStyleName: string;
begin
  lStyleName := SelectedGutterStyleName;
  if lStyleName = '' then
    Exit;

  lEffectiveStyle := FCatalog.BuildEffectiveStyle('default', lStyleName, dvskGlobal);
  try
    lOverride := FConfig.FindStyleOverride('default', lStyleName, dvskGlobal);
    if lOverride = nil then
      lOverride := FConfig.FindStyleOverride('default', lStyleName, dvskLexer);
    if lOverride <> nil then
      lEffectiveStyle.Assign(lOverride);

    FUpdatingControls := True;
    try
      if lEffectiveStyle.HasForeColor then
        FGutterForegroundBox.Color := lEffectiveStyle.ForeColor
      else
        FGutterForegroundBox.Color := clBtnText;

      if lEffectiveStyle.HasBackColor then
        FGutterBackgroundBox.Color := lEffectiveStyle.BackColor
      else
        FGutterBackgroundBox.Color := clBtnFace;
    finally
      FUpdatingControls := False;
    end;
  finally
    lEffectiveStyle.Free;
  end;
end;

procedure TDSciVisualSettingsDialog.LoadSelectedStyleControls;
var
  lEffectiveStyle: TDSciVisualStyleData;
  lGroup: TDSciVisualStyleGroup;
  lOverride: TDSciVisualStyleData;
  lOverrideGroup: TDSciVisualStyleGroup;
  lStyle: TDSciVisualStyleData;
begin
  lGroup := SelectedLanguage;
  lStyle := SelectedStyle;
  if (lGroup = nil) or (lStyle = nil) then
    Exit;

  lEffectiveStyle := FCatalog.BuildEffectiveStyle(lGroup.Name, lStyle.Name, lStyle.Kind);
  try
    lOverride := FConfig.FindStyleOverride(lGroup.Name, lStyle.Name, lStyle.Kind);
    lOverrideGroup := FConfig.StyleOverrides.FindGroup(lGroup.Name);
    if lOverride <> nil then
      lEffectiveStyle.Assign(lOverride);

    FUpdatingControls := True;
    try
      FForegroundBox.Color := clWhite;
      FBackgroundBox.Color := clBlack;
      if lEffectiveStyle.FontName <> '' then
        FFontNameCombo.ItemIndex := FFontNameCombo.Items.IndexOf(lEffectiveStyle.FontName)
      else
        FFontNameCombo.ItemIndex := -1;
      if lEffectiveStyle.HasFontSize then
        FFontSizeEdit.Value := lEffectiveStyle.FontSize
      else
        FFontSizeEdit.Value := 10;
      if lEffectiveStyle.HasForeColor then
        FForegroundBox.Color := lEffectiveStyle.ForeColor;
      if lEffectiveStyle.HasBackColor then
        FBackgroundBox.Color := lEffectiveStyle.BackColor;
      FBoldCheck.Checked := lEffectiveStyle.HasFontStyle and ((lEffectiveStyle.FontStyle and 1) <> 0);
      FItalicCheck.Checked := lEffectiveStyle.HasFontStyle and ((lEffectiveStyle.FontStyle and 2) <> 0);
      FUnderlineCheck.Checked := lEffectiveStyle.HasFontStyle and ((lEffectiveStyle.FontStyle and 4) <> 0);
      FExtensionsEdit.Text := lGroup.Extensions;
      if (lOverrideGroup <> nil) and (lOverrideGroup.Extensions <> '') then
        FExtensionsEdit.Text := lOverrideGroup.Extensions;
    finally
      FUpdatingControls := False;
    end;
  finally
    lEffectiveStyle.Free;
  end;
end;

procedure TDSciVisualSettingsDialog.RefreshCatalog(
  const APreferredLanguage: string; const APreferredStyle: string);
begin
  FCatalog.LoadFromConfig(FConfig);
  LoadLanguageList(APreferredLanguage);
  LoadStyleList(APreferredStyle);
  LoadMiscControls;
  LoadSelectedStyleControls;
  LoadSelectedGutterStyleControls;
end;

procedure TDSciVisualSettingsDialog.SyncMiscToConfig;
var
  lWrapFlags: TDSciWrapVisualFlagSet;
  lWrapLocations: TDSciWrapVisualLocationSet;
begin
  FConfig.ThemeName := SelectedThemeName;
  FConfig.Technology := TDSciTechnologyFromInt(
    ComboSelectedInt(FTechnologyCombo, TDSciTechnologyToInt(FConfig.Technology)));
  FConfig.FontQuality := TDSciFontQualityFromInt(
    ComboSelectedInt(FFontQualityCombo, TDSciFontQualityToInt(FConfig.FontQuality)));
  FConfig.FontLocale := Trim(FFontLocaleEdit.Text);
  FConfig.HighlightColor := FHighlightBox.Color;
  FConfig.HighlightAlpha := Byte(EnsureRange(FTransparencyEdit.Value, 0, 255));
  FConfig.HighlightOutlineAlpha := Byte(EnsureRange(FOutlineEdit.Value, 0, 255));
  FConfig.TabWidth := Max(1, FTabWidthEdit.Value);
  FConfig.FileSizeLimit := Max(Int64(0), FFileSizeLimitEdit.Value);
  FConfig.LineNumbering := FLineNumberingCheck.Checked;
  if FLineNumFixedRadio.Checked then
    FConfig.LineNumberWidthMode := lnwmFixed
  else
    FConfig.LineNumberWidthMode := lnwmDynamic;
  FConfig.LineNumberPaddingLeft := FLineNumPaddingLeftEdit.Value;
  FConfig.LineNumberPaddingRight := FLineNumPaddingRightEdit.Value;
  FConfig.TextPaddingLeft := FTextPaddingLeftEdit.Value;
  FConfig.TextPaddingRight := FTextPaddingRightEdit.Value;
  FConfig.BookmarkMarginVisible := FBookmarkMarginCheck.Checked;
  FConfig.FoldMarginVisible := FFoldMarginCheck.Checked;
  FConfig.LineWrapping := FLineWrappingCheck.Checked;
  FConfig.SearchSync := FSearchSyncCheck.Checked;

  { Logging }
  FConfig.LogEnabled := FLogEnabledCheck.Checked;
  FConfig.LogLevel := ComboSelectedInt(FLogSeverityCombo, FConfig.LogLevel);
  FConfig.LogOutput := ComboSelectedInt(FLogOutputCombo, FConfig.LogOutput);
  { Editor settings }
  FConfig.ShowStatusBar := FShowStatusBarCheck.Checked;
  FConfig.StatusPanelFileVisible := FStatusPanelFileCheck.Checked;
  FConfig.StatusPanelPosVisible := FStatusPanelPosCheck.Checked;
  FConfig.StatusPanelLexerVisible := FStatusPanelLexerCheck.Checked;
  FConfig.StatusPanelEncodingVisible := FStatusPanelEncodingCheck.Checked;
  FConfig.StatusPanelThemeVisible := FStatusPanelThemeCheck.Checked;
  FConfig.StatusPanelLoadVisible := FStatusPanelLoadCheck.Checked;
  FConfig.BackSpaceUnIndents := FBackSpaceUnIndentsCheck.Checked;
  FConfig.IndentationGuides := TDSciIndentViewFromInt(
    ComboSelectedInt(FIndentationGuidesCombo, TDSciIndentViewToInt(FConfig.IndentationGuides)));
  FConfig.WhiteSpaceStyle := TDSciWhiteSpaceFromInt(
    ComboSelectedInt(FWhiteSpaceStyleCombo, TDSciWhiteSpaceToInt(FConfig.WhiteSpaceStyle)));
  FConfig.WhiteSpaceSize := FWhiteSpaceSizeEdit.Value;
  FConfig.UpperLineSpacing := FUpperLineSpacingEdit.Value;
  FConfig.LowerLineSpacing := FLowerLineSpacingEdit.Value;
  FConfig.SelectFullLine := FSelectFullLineCheck.Checked;
  FConfig.UseSelectionForeColor := FUseSelectionForeColorCheck.Checked;
  FConfig.SelectionForeColor := FSelectionForeColorBox.Color;
  FConfig.SelectionAlpha := EnsureRange(FSelectionAlphaEdit.Value, 0, 256);
  FConfig.SmartHighlightStyle := TDSciIndicatorStyleFromInt(
    ComboSelectedInt(FSmartHighlightStyleCombo,
      TDSciIndicatorStyleToInt(FConfig.SmartHighlightStyle)));
  FConfig.SmartHighlightFillAlpha := Byte(
    EnsureRange(FSmartHighlightFillAlphaEdit.Value, 0, 255));
  FConfig.SmartHighlightOutlineAlpha := Byte(
    EnsureRange(FSmartHighlightOutlineAlphaEdit.Value, 0, 255));
  FConfig.WrapMode := TDSciWrapFromInt(
    ComboSelectedInt(FWrapModeCombo, TDSciWrapToInt(FConfig.WrapMode)));
  lWrapFlags := [];
  if FWrapFlagEndCheck.Checked then
    Include(lWrapFlags, scwvfEND);
  if FWrapFlagStartCheck.Checked then
    Include(lWrapFlags, scwvfSTART);
  if FWrapFlagMarginCheck.Checked then
    Include(lWrapFlags, scwvfMARGIN);
  FConfig.WrapVisualFlags := lWrapFlags;
  lWrapLocations := [];
  if FWrapLocationEndCheck.Checked then
    Include(lWrapLocations, scwvlEND_BY_TEXT);
  if FWrapLocationStartCheck.Checked then
    Include(lWrapLocations, scwvlSTART_BY_TEXT);
  FConfig.WrapVisualFlagsLocation := lWrapLocations;
  FConfig.LineWrapping := FConfig.WrapMode <> scwNONE;
  FConfig.CaretBeyondLineEndings := FCaretBeyondLineEndingsCheck.Checked;
  FConfig.WrapCursorAtLineStart := FWrapCursorAtLineStartCheck.Checked;
  FConfig.CaretSticky := TDSciCaretStickyFromInt(
    ComboSelectedInt(FStickyCaretCombo, TDSciCaretStickyToInt(FConfig.CaretSticky)));
  FConfig.MultiPaste := FMultiPasteCheck.Checked;
  FConfig.PasteConvertEndings := FPasteConvertEndingsCheck.Checked;
  FConfig.FoldingLines := FFoldingLinesCheck.Checked;
  FConfig.FoldingText := FFoldingTextEdit.Text;
  FConfig.FoldDisplayTextStyle := TDSciFoldDisplayTextStyleFromInt(
    ComboSelectedInt(FFoldDisplayTextStyleCombo,
      TDSciFoldDisplayTextStyleToInt(FConfig.FoldDisplayTextStyle)));
  FConfig.FoldMarkerStyle := TDSciFoldMarkerStyle(EnsureRange(
    ComboSelectedInt(FFoldMarkerStyleCombo, Ord(FConfig.FoldMarkerStyle)),
    0, Ord(High(TDSciFoldMarkerStyle))));
  FConfig.PrintMagnification := FPrintMagnificationEdit.Value;
end;

procedure TDSciVisualSettingsDialog.SyncSelectedGutterStyleToConfig;
var
  lEffectiveStyle: TDSciVisualStyleData;
  lOverride: TDSciVisualStyleData;
  lStyleName: string;
begin
  lStyleName := SelectedGutterStyleName;
  if lStyleName = '' then
    Exit;

  lEffectiveStyle := FCatalog.BuildEffectiveStyle('default', lStyleName, dvskGlobal);
  try
    lOverride := FConfig.EnsureStyleOverride('default', lStyleName, dvskGlobal);
    lOverride.Kind := dvskGlobal;
    lOverride.Name := lStyleName;
    lOverride.HasStyleID := lEffectiveStyle.HasStyleID;
    lOverride.StyleID := lEffectiveStyle.StyleID;
    lOverride.HasForeColor := True;
    lOverride.ForeColor := FGutterForegroundBox.Color;
    lOverride.HasBackColor := True;
    lOverride.BackColor := FGutterBackgroundBox.Color;
  finally
    lEffectiveStyle.Free;
  end;
end;

procedure TDSciVisualSettingsDialog.SyncSelectedStyleToConfig;
var
  lFontStyle: Integer;
  lGroup: TDSciVisualStyleGroup;
  lOverride: TDSciVisualStyleData;
  lOverrideGroup: TDSciVisualStyleGroup;
  lStyle: TDSciVisualStyleData;
begin
  if FUpdatingControls then
    Exit;

  SyncMiscToConfig;
  SyncSelectedGutterStyleToConfig;

  lGroup := SelectedLanguage;
  lStyle := SelectedStyle;
  if (lGroup = nil) or (lStyle = nil) then
    Exit;

  lOverrideGroup := FConfig.StyleOverrides.EnsureGroup(lGroup.Name);
  lOverrideGroup.Description := lGroup.Description;
  lOverrideGroup.Extensions := NormalizeExtensions(FExtensionsEdit.Text);

  lOverride := FConfig.EnsureStyleOverride(lGroup.Name, lStyle.Name, lStyle.Kind);
  lOverride.Kind := lStyle.Kind;
  lOverride.Name := lStyle.Name;
  lOverride.StyleID := lStyle.StyleID;
  lOverride.HasStyleID := lStyle.HasStyleID;
  lOverride.HasForeColor := True;
  lOverride.ForeColor := FForegroundBox.Color;
  lOverride.HasBackColor := True;
  lOverride.BackColor := FBackgroundBox.Color;
  lOverride.FontName := Trim(FFontNameCombo.Text);
  lOverride.HasFontSize := True;
  lOverride.FontSize := FFontSizeEdit.Value;
  lFontStyle := 0;
  if FBoldCheck.Checked then
    lFontStyle := lFontStyle or 1;
  if FItalicCheck.Checked then
    lFontStyle := lFontStyle or 2;
  if FUnderlineCheck.Checked then
    lFontStyle := lFontStyle or 4;
  lOverride.HasFontStyle := True;
  lOverride.FontStyle := lFontStyle;
end;

procedure TDSciVisualSettingsDialog.ThemeComboChange(Sender: TObject);
var
  lCatalogMs: Int64;
  lReplaceMs: Int64;
  lSelectedLanguage: string;
  lSelectedStyle: string;
  lSelectedTheme: string;
  lStartTick: UInt64;
  lUiMs: Int64;
begin
  if FUpdatingControls then
    Exit;

  if SelectedLanguage <> nil then
    lSelectedLanguage := SelectedLanguage.Name
  else
    lSelectedLanguage := '';
  if SelectedStyle <> nil then
    lSelectedStyle := SelectedStyle.Name
  else
    lSelectedStyle := '';

  lSelectedTheme := SelectedThemeName;
  if SameText(Trim(FConfig.ThemeName), lSelectedTheme) then
  begin
    SyncMiscToConfig;
    Exit;
  end;

  lCatalogMs := 0;
  lStartTick := GetTickCount64;
  ApplyThemeSelection(lSelectedTheme);
  lReplaceMs := GetTickCount64 - lStartTick;

  FUpdatingControls := True;
  try
    lStartTick := GetTickCount64;
    RefreshCatalog(lSelectedLanguage, lSelectedStyle);
    lUiMs := GetTickCount64 - lStartTick;
  finally
    FUpdatingControls := False;
  end;

  LogThemeLoadTiming(lSelectedTheme, lCatalogMs, lReplaceMs, lUiMs);
end;

procedure TDSciVisualSettingsDialog.GutterStyleComboChange(Sender: TObject);
begin
  if FUpdatingControls then
    Exit;
  LoadSelectedGutterStyleControls;
end;

procedure TDSciVisualSettingsDialog.LanguageComboChange(Sender: TObject);
begin
  if FUpdatingControls then
    Exit;
  FUpdatingControls := True;
  try
    LoadStyleList;
    LoadSelectedStyleControls;
  finally
    FUpdatingControls := False;
  end;
end;

procedure TDSciVisualSettingsDialog.StyleComboChange(Sender: TObject);
begin
  if FUpdatingControls then
    Exit;
  LoadSelectedStyleControls;
end;

procedure TDSciVisualSettingsDialog.StyleControlChange(Sender: TObject);
begin
  SyncSelectedStyleToConfig;
end;

procedure TDSciVisualSettingsDialog.ColorPanelClick(Sender: TObject);
begin
  if not (Sender is TPanel) then
    Exit;

  FColorDialog.Color := TPanel(Sender).Color;
  if not FColorDialog.Execute(Handle) then
    Exit;

  TPanel(Sender).Color := FColorDialog.Color;
  if (Sender = FGutterForegroundBox) or (Sender = FGutterBackgroundBox) then
  begin
    SyncMiscToConfig;
    SyncSelectedGutterStyleToConfig;
    Exit;
  end;

  SyncSelectedStyleToConfig;
end;

procedure TDSciVisualSettingsDialog.OkButtonClick(Sender: TObject);
begin
  SyncSelectedStyleToConfig;
  if FModeless then
  begin
    if Assigned(FOnApplyConfig) then
      FOnApplyConfig(FConfig);
    Close;
  end
  else
    ModalResult := mrOk;
end;

procedure TDSciVisualSettingsDialog.CancelButtonClick(Sender: TObject);
begin
  if FModeless then
    Close
  else
    ModalResult := mrCancel;
end;

procedure TDSciVisualSettingsDialog.ModelessFormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

function TDSciVisualSettingsDialog.EditSettings(const ASettingsDirectory,
  AConfigFileName: string;
  AConfig: TDSciVisualConfig): Boolean;
begin
  FSettingsDirectory := ASettingsDirectory;
  FConfigFileName := AConfigFileName;
  FConfig.Assign(AConfig);
  FHasSettingsCatalog := False;
  FCatalog.LoadFromConfig(FConfig);

  FUpdatingControls := True;
  try
    LoadThemeList;
    RefreshCatalog('default');
  finally
    FUpdatingControls := False;
  end;
  CategoryComboChange(FCategoryCombo);

  Result := ShowModal = mrOk;
  if Result then
    AConfig.Assign(FConfig);
end;

procedure TDSciVisualSettingsDialog.ShowSettingsModeless(
  const ASettingsDirectory, AConfigFileName: string;
  AConfig: TDSciVisualConfig);
begin
  FModeless := True;
  OnClose := ModelessFormClose;

  FSettingsDirectory := ASettingsDirectory;
  FConfigFileName := AConfigFileName;
  FConfig.Assign(AConfig);
  FHasSettingsCatalog := False;
  FCatalog.LoadFromConfig(FConfig);

  FUpdatingControls := True;
  try
    LoadThemeList;
    RefreshCatalog('default');
  finally
    FUpdatingControls := False;
  end;
  CategoryComboChange(FCategoryCombo);

  Show;
end;

end.
