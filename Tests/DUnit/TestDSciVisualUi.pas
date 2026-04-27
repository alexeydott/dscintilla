unit TestDSciVisualUi;

interface

uses
  TestFramework;

type
  TTestDSciVisualUi = class(TTestCase)
  published
    procedure TestSettingsDialogFieldColumnsAlignWithThemeRow;
    procedure TestFindDialogCreates;
    procedure TestFindDialogGroupBoxesContainControls;
    procedure TestFindDialogInnerControlsStayVisible;
    procedure TestFindDialogActionButtonsStartAtScopeLevel;
    procedure TestFindDialogLayoutDoesNotOverlapWhenScaled;
    procedure TestFindDialogSearchFieldKeepsGapFromLabel;
    procedure TestFindDialogIsCompact;
    procedure TestReplaceTabResultLabelIsBelowCombos;
    procedure TestReplaceTabCombosHaveEqualWidth;
    procedure TestVisualCatalogUsesConfigSnapshot;
    procedure TestVisualCatalogLoadsLanguageExtensions;
    procedure TestSettingsDialogDoesNotNeedVerticalScrollWhenShown;
    procedure TestSettingsDialogDoesNotUseScrollContainer;
    procedure TestSettingsDialogExtensionsUseEditWithHint;
    procedure TestSettingsDialogGroupBoxesUseDefaultPainting;
    procedure TestSettingsDialogStacksStartBelowGroupBoxCaptions;
    procedure TestSettingsDialogLayoutDoesNotOverlapWhenScaled;
    procedure TestSettingsDialogGroupBoxesContainControls;
    procedure TestSettingsDialogMiscCheckBoxesAreVisible;
    procedure TestSettingsDialogOptionPairRowsAlign;
    procedure TestSettingsDialogSectionOrder;
    procedure TestSettingsDialogStyleGroupFitsContent;
    procedure TestSettingsDialogStyleFieldOrder;
    procedure TestSettingsDialogTallCardsFitContent;
    procedure TestSettingsDialogWidthIsCompact;
    procedure TestSettingsDialogMiscOptionsExposeSearchSyncAndFileSizeLimit;
    procedure TestSettingsDialogGeneralCategoryExposesRenderingControls;
    procedure TestSettingsDialogImportThemeCopiesThemeIntoConfigThemesDirectory;
    procedure TestSettingsDialogLoadsThemesFromConfigDirectoryAndAppliesSelection;
    procedure TestSettingsDialogUsesGroupBoxes;
    procedure TestSettingsDialogUsesStackPanelsInsideGroupBoxes;
    procedure TestSettingsDialogUsesStandardComboBoxes;
    procedure TestSettingsDialogHighlightLabelUsesSingleLine;
    procedure TestSciConfGenBuildsConfigAndDefaultResourceSources;
    procedure TestVisualConfigLoadFailureKeepsPreviousState;
    procedure TestVisualConfigSaveLoadRoundTrip;
    procedure TestLoggingConfigBackwardCompatFromToFile;
    procedure TestSettingsDialogBootstrapsFromConfigWithoutLegacyCatalog;
    procedure TestVisualFormCreatesCustomNamedConfigFile;
    procedure TestVisualFormLoadsConfigWithoutSettingsDirectory;
    procedure TestVisualFormUsesTaskbarWindowStyles;
    procedure TestVisualFormAppliesConfiguredGutters;
    procedure TestVisualFormAppliesLineNumberPadding;
    procedure TestVisualFormXmlFoldingTogglesOnOpen;
    procedure TestVisualFormUnknownExtensionFallsBackToPlainLexer;
    procedure TestVisualFormActionscriptUsesCppRuntimeLexerOnFirstSelection;
    procedure TestVisualFormNfoKeepsPlainLexerButRetainsLanguageGroup;
    procedure TestVisualFormHtmlFileFallsBackWhenHtmlLexerIsUnavailable;
    procedure TestVisualFormGroupsLexerPopupByFirstLetter;
    procedure TestVisualFormShowStatusBarFollowsConfigVisibility;
    procedure TestVisualFormBeginOpenFileShowsLoadingStatus;
    procedure TestVisualFormSettingsReapplyKeepsXmlFolding;
    procedure TestVisualFormOpenFileUsesBackgroundDocumentLoader;
    procedure TestVisualFormPreferredEncodingSelectionAppliesToNextOpenModes;
    procedure TestVisualFormEncodingSwitchReloadsCurrentFileSynchronously;
    procedure TestVisualFormFileSizeLimitBlocksOversizedFiles;
    procedure TestVisualFormMarkAllBookmarksMarksMatchingLines;
    procedure TestVisualFormSearchSyncMirrorsFindDialogToInlineSearch;
    procedure TestLoggerDefaultsAreDisabled;
    procedure TestLoggerFileOutputWritesToDisk;
    procedure TestLoggerLevelFiltersMessages;
    procedure TestLoggerLegacyAliasesShareStorage;
    procedure TestLoggerSciBridgeLogDelegatesToDSciLog;
    procedure TestSettingsDialogExitsWhenCancelledDuringModalLoop;
  end;

implementation

uses
  System.Classes, System.IOUtils, System.Math, System.SysUtils, System.Types,
  Winapi.Windows,
  Vcl.ComCtrls, Vcl.Controls, Vcl.ExtCtrls, Vcl.Forms, Vcl.Graphics, Vcl.Samples.Spin,
  Vcl.Menus, Vcl.StdCtrls, Vcl.WinXPanels,
  Xml.XMLDoc, Xml.XMLIntf,
  DScintilla, DScintillaSearchReplaceDLG, DScintillaLogger, DScintillaTypes,
  DScintillaVisualConfig,
  DScintillaVisualSettingsDLG,
  uDSciVisualTestMain, uSciConfGenRunner;

type
  TGroupBoxAccess = class(TGroupBox);
  TAutoCloseDialog = class
  private
    FDialog: TCustomForm;
    FTimer: TTimer;
  public
    destructor Destroy; override;

    procedure Attach(ADialog: TCustomForm);
    procedure TimerTick(Sender: TObject);
  end;

  TThemeSelectionDialog = class
  private
    FDialog: TCustomForm;
    FThemeName: string;
    FTimer: TTimer;
  public
    destructor Destroy; override;

    procedure Attach(ADialog: TCustomForm; const AThemeName: string);
    procedure TimerTick(Sender: TObject);
  end;

  TModalDialogResponder = class
  private
    FDialogClass: TCustomFormClass;
    FHandled: Boolean;
    FModalResult: TModalResult;
    FTimer: TTimer;
  public
    destructor Destroy; override;

    procedure Arm(ADialogClass: TCustomFormClass; AModalResult: TModalResult);
    procedure TimerTick(Sender: TObject);

    property Handled: Boolean read FHandled;
  end;

destructor TAutoCloseDialog.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end;

procedure TAutoCloseDialog.Attach(ADialog: TCustomForm);
begin
  FDialog := ADialog;
  FreeAndNil(FTimer);
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 1;
  FTimer.OnTimer := TimerTick;
  FTimer.Enabled := True;
end;

procedure TAutoCloseDialog.TimerTick(Sender: TObject);
begin
  if FTimer <> nil then
    FTimer.Enabled := False;
  if FDialog <> nil then
    FDialog.ModalResult := mrCancel;
end;

destructor TThemeSelectionDialog.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end;

function DescribeControl(AControl: TControl): string;
begin
  Result := AControl.ClassName;
  if AControl is TLabel then
    Result := Result + ' "' + TLabel(AControl).Caption + '"'
  else if AControl is TCheckBox then
    Result := Result + ' "' + TCheckBox(AControl).Caption + '"'
  else if AControl is TButton then
    Result := Result + ' "' + TButton(AControl).Caption + '"'
  else if AControl is TComboBox then
    Result := Result + ' "' + TComboBox(AControl).Text + '"'
  else if AControl is TGroupBox then
    Result := Result + ' "' + TGroupBox(AControl).Caption + '"';
end;

function FindGroupBoxByCaption(AOwner: TComponent; const ACaption: string): TGroupBox;
var
  lIndex: Integer;
begin
  Result := nil;
  for lIndex := 0 to AOwner.ComponentCount - 1 do
    if (AOwner.Components[lIndex] is TGroupBox) and
       SameText(TGroupBox(AOwner.Components[lIndex]).Caption, ACaption) then
      Exit(TGroupBox(AOwner.Components[lIndex]));
end;

function IsEffectivelyVisible(AControl: TControl): Boolean;
begin
  Result := AControl <> nil;
  while Result and (AControl <> nil) do
  begin
    Result := AControl.Visible;
    AControl := AControl.Parent;
  end;
end;

function FindVisibleGroupBoxByCaption(AOwner: TComponent;
  const ACaption: string): TGroupBox;
var
  lIndex: Integer;
begin
  Result := nil;
  for lIndex := 0 to AOwner.ComponentCount - 1 do
    if (AOwner.Components[lIndex] is TGroupBox) and
       SameText(TGroupBox(AOwner.Components[lIndex]).Caption, ACaption) and
       IsEffectivelyVisible(TGroupBox(AOwner.Components[lIndex])) then
      Exit(TGroupBox(AOwner.Components[lIndex]));
end;

function IsDescendantOf(AControl: TControl; AAncestor: TWinControl): Boolean;
begin
  Result := False;
  while AControl <> nil do
  begin
    if AControl = AAncestor then
      Exit(True);
    AControl := AControl.Parent;
  end;
end;

function FindLabelByCaption(AOwner: TComponent; const ACaption: string): TLabel;
var
  lIndex: Integer;
begin
  Result := nil;
  for lIndex := 0 to AOwner.ComponentCount - 1 do
    if (AOwner.Components[lIndex] is TLabel) and
       SameText(TLabel(AOwner.Components[lIndex]).Caption, ACaption) then
      Exit(TLabel(AOwner.Components[lIndex]));
end;

function FindVisibleLabelByCaption(AOwner: TComponent; const ACaption: string): TLabel;
var
  lIndex: Integer;
begin
  Result := nil;
  for lIndex := 0 to AOwner.ComponentCount - 1 do
    if (AOwner.Components[lIndex] is TLabel) and
       SameText(TLabel(AOwner.Components[lIndex]).Caption, ACaption) and
       IsEffectivelyVisible(TLabel(AOwner.Components[lIndex])) then
      Exit(TLabel(AOwner.Components[lIndex]));
end;

function FindCheckBoxByCaption(AOwner: TComponent; const ACaption: string): TCheckBox;
var
  lIndex: Integer;
begin
  Result := nil;
  for lIndex := 0 to AOwner.ComponentCount - 1 do
    if (AOwner.Components[lIndex] is TCheckBox) and
       SameText(TCheckBox(AOwner.Components[lIndex]).Caption, ACaption) then
      Exit(TCheckBox(AOwner.Components[lIndex]));
end;

function FindButtonByCaption(AOwner: TComponent; const ACaption: string): TButton;
var
  lIndex: Integer;
begin
  Result := nil;
  for lIndex := 0 to AOwner.ComponentCount - 1 do
    if (AOwner.Components[lIndex] is TButton) and
       SameText(TButton(AOwner.Components[lIndex]).Caption, ACaption) then
      Exit(TButton(AOwner.Components[lIndex]));
end;

function FindRadioButtonByCaption(AOwner: TComponent; const ACaption: string): TRadioButton;
var
  lIndex: Integer;
begin
  Result := nil;
  for lIndex := 0 to AOwner.ComponentCount - 1 do
    if (AOwner.Components[lIndex] is TRadioButton) and
       SameText(TRadioButton(AOwner.Components[lIndex]).Caption, ACaption) then
      Exit(TRadioButton(AOwner.Components[lIndex]));
end;

function FindMenuItemByCaption(AOwner: TComponent; const ACaption: string): TMenuItem;
var
  lIndex: Integer;
begin
  Result := nil;
  for lIndex := 0 to AOwner.ComponentCount - 1 do
    if (AOwner.Components[lIndex] is TMenuItem) and
       SameText(TMenuItem(AOwner.Components[lIndex]).Caption, ACaption) then
      Exit(TMenuItem(AOwner.Components[lIndex]));
end;

function FindChildMenuItemByCaption(AParent: TMenuItem; const ACaption: string): TMenuItem;
var
  lIndex: Integer;
begin
  Result := nil;
  if AParent = nil then
    Exit;

  for lIndex := 0 to AParent.Count - 1 do
    if SameText(AParent.Items[lIndex].Caption, ACaption) then
      Exit(AParent.Items[lIndex]);
end;

function FindOwnedComponent(AOwner: TComponent; AClass: TComponentClass): TComponent;
var
  lIndex: Integer;
begin
  Result := nil;
  if AOwner = nil then
    Exit;
  for lIndex := 0 to AOwner.ComponentCount - 1 do
    if AOwner.Components[lIndex] is AClass then
      Exit(AOwner.Components[lIndex]);
end;

function FindOwnedComponentByName(AOwner: TComponent; const AName: string): TComponent;
var
  lIndex: Integer;
begin
  Result := nil;
  if AOwner = nil then
    Exit;
  for lIndex := 0 to AOwner.ComponentCount - 1 do
    if SameText(AOwner.Components[lIndex].Name, AName) then
      Exit(AOwner.Components[lIndex]);
end;

function FindStatusBarPanelIndex(AStatusBar: TStatusBar; const APrefix: string): Integer;
var
  lIndex: Integer;
begin
  Result := -1;
  if (AStatusBar = nil) or (APrefix = '') then
    Exit;

  for lIndex := 0 to AStatusBar.Panels.Count - 1 do
    if SameText(Copy(AStatusBar.Panels[lIndex].Text, 1, Length(APrefix)), APrefix) then
      Exit(lIndex);
end;

function FindScrollBox(AOwner: TComponent): TScrollBox;
var
  lIndex: Integer;
begin
  Result := nil;
  for lIndex := 0 to AOwner.ComponentCount - 1 do
    if AOwner.Components[lIndex] is TScrollBox then
      Exit(TScrollBox(AOwner.Components[lIndex]));
end;

function FindCardPanel(AOwner: TComponent): TCardPanel;
begin
  Result := FindOwnedComponent(AOwner, TCardPanel) as TCardPanel;
end;

function FindDescendantControl(AParent: TWinControl; AControlClass: TControlClass): TControl;
var
  lChild: TControl;
  lIndex: Integer;
begin
  Result := nil;
  if AParent = nil then
    Exit;

  for lIndex := 0 to AParent.ControlCount - 1 do
  begin
    lChild := AParent.Controls[lIndex];
    if lChild is AControlClass then
      Exit(lChild);

    if lChild is TWinControl then
    begin
      Result := FindDescendantControl(TWinControl(lChild), AControlClass);
      if Result <> nil then
        Exit;
    end;
  end;
end;

function FindDescendantLabelByCaption(AParent: TWinControl;
  const ACaption: string): TLabel;
var
  lChild: TControl;
  lIndex: Integer;
begin
  Result := nil;
  if AParent = nil then
    Exit;

  for lIndex := 0 to AParent.ControlCount - 1 do
  begin
    lChild := AParent.Controls[lIndex];
    if (lChild is TLabel) and SameText(TLabel(lChild).Caption, ACaption) and
       IsEffectivelyVisible(lChild) then
      Exit(TLabel(lChild));

    if lChild is TWinControl then
    begin
      Result := FindDescendantLabelByCaption(TWinControl(lChild), ACaption);
      if Result <> nil then
        Exit;
    end;
  end;
end;

function FindFieldForLabel(ALabel: TLabel; AControlClass: TControlClass): TControl;
var
  lChild: TControl;
  lFieldHost: TControl;
  lIndex: Integer;
  lLabelHost: TControl;
  lMinLeft: Integer;
  lRowHost: TWinControl;
begin
  Result := nil;
  if (ALabel = nil) or (ALabel.Parent = nil) or (ALabel.Parent.Parent = nil) then
    Exit;

  if not (ALabel.Parent.Parent is TWinControl) then
    Exit;

  lRowHost := TWinControl(ALabel.Parent.Parent);
  lLabelHost := TControl(ALabel.Parent);
  lFieldHost := nil;
  lMinLeft := lLabelHost.Left + lLabelHost.Width;
  for lIndex := 0 to lRowHost.ControlCount - 1 do
  begin
    lChild := lRowHost.Controls[lIndex];
    if (lChild <> lLabelHost) and (lChild.Left >= lMinLeft) and
       ((lFieldHost = nil) or (lChild.Left < lFieldHost.Left)) then
      lFieldHost := lChild;
  end;

  if lFieldHost is AControlClass then
    Exit(lFieldHost);

  if lFieldHost is TWinControl then
  begin
    Result := FindDescendantControl(TWinControl(lFieldHost), AControlClass);
    if Result <> nil then
      Exit;
  end;

  Result := FindDescendantControl(lRowHost, AControlClass);
end;

function FindSiblingControlToRight(ALabel: TLabel; AControlClass: TControlClass): TControl;
var
  lBestLeft: Integer;
  lChild: TControl;
  lIndex: Integer;
  lMinLeft: Integer;
begin
  Result := nil;
  if (ALabel = nil) or (ALabel.Parent = nil) then
    Exit;

  lBestLeft := MaxInt;
  lMinLeft := ALabel.Left + ALabel.Width;
  for lIndex := 0 to ALabel.Parent.ControlCount - 1 do
  begin
    lChild := ALabel.Parent.Controls[lIndex];
    if (lChild is AControlClass) and (lChild.Left >= lMinLeft) and
       (lChild.Left < lBestLeft) then
    begin
      Result := lChild;
      lBestLeft := lChild.Left;
    end;
  end;
end;

procedure SettleForm(AForm: TCustomForm; AShow: Boolean = False); forward;

procedure ActivateSettingsCategory(ATest: TTestCase;
  ADialog: TDSciVisualSettingsDialog; const ACategory: string);
var
  lCategoryCombo: TComboBox;
  lCategoryLabel: TLabel;
  lIndex: Integer;
begin
  SettleForm(ADialog, True);
  lCategoryLabel := FindLabelByCaption(ADialog, 'Category');
  lCategoryCombo := FindFieldForLabel(lCategoryLabel, TComboBox) as TComboBox;
  ATest.Check(lCategoryLabel <> nil, 'Settings dialog should expose the Category label');
  ATest.Check(lCategoryCombo <> nil, 'Settings dialog should expose the Category combo');
  lIndex := lCategoryCombo.Items.IndexOf(ACategory);
  ATest.Check(lIndex >= 0,
    Format('Settings dialog should expose the "%s" category', [ACategory]));
  lCategoryCombo.ItemIndex := lIndex;
  if Assigned(lCategoryCombo.OnChange) then
    lCategoryCombo.OnChange(lCategoryCombo);
  SettleForm(ADialog, True);
end;

procedure TThemeSelectionDialog.Attach(ADialog: TCustomForm;
  const AThemeName: string);
begin
  FDialog := ADialog;
  FThemeName := AThemeName;
  FreeAndNil(FTimer);
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 1;
  FTimer.OnTimer := TimerTick;
  FTimer.Enabled := True;
end;

procedure TThemeSelectionDialog.TimerTick(Sender: TObject);
var
  lThemeCombo: TComboBox;
  lThemeIndex: Integer;
  lThemeLabel: TLabel;
begin
  if FTimer <> nil then
    FTimer.Enabled := False;
  if FDialog = nil then
    Exit;

  lThemeLabel := FindLabelByCaption(FDialog, 'Theme');
  lThemeCombo := FindFieldForLabel(lThemeLabel, TComboBox) as TComboBox;
  if lThemeCombo <> nil then
  begin
    lThemeIndex := lThemeCombo.Items.IndexOf(FThemeName);
    if lThemeIndex >= 0 then
    begin
      lThemeCombo.ItemIndex := lThemeIndex;
      if Assigned(lThemeCombo.OnChange) then
        lThemeCombo.OnChange(lThemeCombo);
    end;
  end;

  FDialog.ModalResult := mrOk;
end;

destructor TModalDialogResponder.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end;

procedure TModalDialogResponder.Arm(ADialogClass: TCustomFormClass;
  AModalResult: TModalResult);
begin
  FDialogClass := ADialogClass;
  FModalResult := AModalResult;
  FHandled := False;
  FreeAndNil(FTimer);
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 1;
  FTimer.OnTimer := TimerTick;
  FTimer.Enabled := True;
end;

procedure TModalDialogResponder.TimerTick(Sender: TObject);
var
  lIndex: Integer;
  lForm: TCustomForm;
begin
  for lIndex := 0 to Screen.CustomFormCount - 1 do
  begin
    lForm := Screen.CustomForms[lIndex];
    if (lForm <> nil) and (FDialogClass <> nil) and (lForm is FDialogClass) and
       lForm.Visible then
    begin
      FHandled := True;
      if FTimer <> nil then
        FTimer.Enabled := False;
      lForm.ModalResult := FModalResult;
      Exit;
    end;
  end;
end;

function MeasureSingleLineTextWidth(AFont: TFont; const ACaption: string): Integer;
var
  lDC: HDC;
  lRect: TRect;
  lSavedFont: HGDIOBJ;
begin
  lDC := GetDC(0);
  try
    lSavedFont := SelectObject(lDC, AFont.Handle);
    try
      lRect := Rect(0, 0, 0, 0);
      DrawText(lDC, PChar(ACaption), Length(ACaption), lRect,
        DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX);
      Result := lRect.Right - lRect.Left;
    finally
      SelectObject(lDC, lSavedFont);
    end;
  finally
    ReleaseDC(0, lDC);
  end;
end;

procedure SettleForm(AForm: TCustomForm; AShow: Boolean = False);
begin
  AForm.HandleNeeded;
  if AShow and not AForm.Visible then
    AForm.Show;
  AForm.Realign;
  Application.ProcessMessages;
  AForm.Realign;
  Application.ProcessMessages;
  AForm.Realign;
end;

function ShrinkRect(const ARect: TRect): TRect;
begin
  Result := ARect;
  if (Result.Right - Result.Left) > 2 then
  begin
    Inc(Result.Left);
    Dec(Result.Right);
  end;
  if (Result.Bottom - Result.Top) > 2 then
  begin
    Inc(Result.Top);
    Dec(Result.Bottom);
  end;
end;

procedure CheckChildrenStayWithinParent(ATest: TTestCase; AParent: TWinControl;
  const AContext: string);
var
  lBounds: TRect;
  lChild: TControl;
  lClient: TRect;
  lIndex: Integer;
begin
  lClient := AParent.ClientRect;
  for lIndex := 0 to AParent.ControlCount - 1 do
  begin
    lChild := AParent.Controls[lIndex];
    if not lChild.Visible then
      Continue;

    if not (AParent is TScrollBox) then
    begin
      lBounds := lChild.BoundsRect;
      ATest.Check(lBounds.Left >= lClient.Left,
        Format('%s: %s starts before the client area', [AContext, DescribeControl(lChild)]));
      ATest.Check(lBounds.Top >= lClient.Top,
        Format('%s: %s starts above the client area', [AContext, DescribeControl(lChild)]));
      ATest.Check(lBounds.Right <= lClient.Right,
        Format('%s: %s exceeds the client width (child right=%d, client right=%d)',
          [AContext, DescribeControl(lChild), lBounds.Right, lClient.Right]));
      ATest.Check(lBounds.Bottom <= lClient.Bottom,
        Format('%s: %s exceeds the client height (child bottom=%d, client bottom=%d)',
          [AContext, DescribeControl(lChild), lBounds.Bottom, lClient.Bottom]));
    end;

    if lChild is TWinControl then
      CheckChildrenStayWithinParent(ATest, TWinControl(lChild),
        AContext + ' > ' + DescribeControl(lChild));
  end;
end;

procedure CheckChildrenDoNotOverlap(ATest: TTestCase; AParent: TWinControl;
  const AContext: string);
var
  lFirstBounds: TRect;
  lIntersect: TRect;
  lSecondBounds: TRect;
  lFirst: TControl;
  lIndex: Integer;
  lOtherIndex: Integer;
  lSecond: TControl;
begin
  for lIndex := 0 to AParent.ControlCount - 1 do
  begin
    lFirst := AParent.Controls[lIndex];
    if not lFirst.Visible then
      Continue;

    lFirstBounds := ShrinkRect(lFirst.BoundsRect);
    if IsRectEmpty(lFirstBounds) then
      Continue;

    for lOtherIndex := lIndex + 1 to AParent.ControlCount - 1 do
    begin
      lSecond := AParent.Controls[lOtherIndex];
      if not lSecond.Visible then
        Continue;

      lSecondBounds := ShrinkRect(lSecond.BoundsRect);
      if IsRectEmpty(lSecondBounds) then
        Continue;

      if IntersectRect(lIntersect, lFirstBounds, lSecondBounds) then
        ATest.Fail(Format('%s: %s overlaps %s', [AContext, DescribeControl(lFirst),
          DescribeControl(lSecond)]));
    end;

    if lFirst is TWinControl then
      CheckChildrenDoNotOverlap(ATest, TWinControl(lFirst),
        AContext + ' > ' + DescribeControl(lFirst));
  end;
end;

function ResolveSettingsDir: string;
begin
  Result := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..\settings');
end;

function CreateWritableTempDir: string;
var
  lBaseDir: string;
begin
  lBaseDir := Trim(TPath.GetTempPath);
  if lBaseDir = '' then
    lBaseDir := TPath.Combine(ExtractFilePath(ParamStr(0)), 'temp');
  ForceDirectories(lBaseDir);
  Result := TPath.Combine(lBaseDir, TPath.GetRandomFileName);
  ForceDirectories(Result);
end;

function FoldLevelHasHeader(AEditor: TDScintilla; ALine: NativeInt): Boolean;
begin
  Result := (AEditor.SendEditor(SCI_GETFOLDLEVEL, WPARAM(ALine), 0) and
    SC_FOLDLEVELHEADERFLAG) <> 0;
end;

function FindFirstFoldHeaderLine(AEditor: TDScintilla): NativeInt;
var
  lLine: NativeInt;
begin
  Result := -1;
  for lLine := 0 to AEditor.LineCount - 1 do
    if FoldLevelHasHeader(AEditor, lLine) then
      Exit(lLine);
end;

procedure AssertEditorCanToggleFirstFold(ATest: TTestCase; AEditor: TDScintilla;
  const AContext: string);
var
  lChildLine: NativeInt;
  lHeaderLine: NativeInt;
  lLastChild: NativeInt;
begin
  lHeaderLine := FindFirstFoldHeaderLine(AEditor);
  ATest.Check(lHeaderLine >= 0,
    Format('%s: expected at least one fold header line', [AContext]));
  if lHeaderLine < 0 then
    Exit;

  lLastChild := AEditor.SendEditor(SCI_GETLASTCHILD, WPARAM(lHeaderLine), LPARAM(-1));
  ATest.Check(lLastChild > lHeaderLine,
    Format('%s: fold header line %d should own at least one child line', [AContext, lHeaderLine]));
  if lLastChild <= lHeaderLine then
    Exit;

  lChildLine := lHeaderLine + 1;
  if not AEditor.LineVisible[lChildLine] then
    AEditor.ToggleFold(lHeaderLine);
  Application.ProcessMessages;

  ATest.Check(AEditor.LineVisible[lChildLine],
    Format('%s: child line %d should start visible before collapsing', [AContext, lChildLine]));
  AEditor.ToggleFold(lHeaderLine);
  Application.ProcessMessages;
  ATest.Check(not AEditor.LineVisible[lChildLine],
    Format('%s: child line %d should hide after collapsing line %d', [AContext, lChildLine, lHeaderLine]));
  AEditor.ToggleFold(lHeaderLine);
  Application.ProcessMessages;
  ATest.Check(AEditor.LineVisible[lChildLine],
    Format('%s: child line %d should reappear after expanding line %d', [AContext, lChildLine, lHeaderLine]));
end;

procedure TTestDSciVisualUi.TestFindDialogCreates;
var
  lDialog: TDSciFindDialog;
begin
  lDialog := TDSciFindDialog.Create(nil);
  try
    CheckEquals('Find / Replace', lDialog.Caption);
  finally
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestFindDialogGroupBoxesContainControls;
var
  lDialog: TDSciFindDialog;
  lInSelection: TCheckBox;
  lMarkAllButton: TButton;
  lModeGroup: TGroupBox;
  lOptionsGroup: TGroupBox;
  lRegexRadio: TRadioButton;
  lScopeGroup: TGroupBox;
begin
  lDialog := TDSciFindDialog.Create(nil);
  try
    SettleForm(lDialog, True);

    lOptionsGroup := FindGroupBoxByCaption(lDialog, 'Search Options');
    lScopeGroup := FindGroupBoxByCaption(lDialog, 'Scope');
    lModeGroup := FindGroupBoxByCaption(lDialog, 'Search Mode');
    lInSelection := FindCheckBoxByCaption(lDialog, 'In selection');
    lRegexRadio := FindDescendantControl(lModeGroup, TRadioButton) as TRadioButton;
    lMarkAllButton := FindButtonByCaption(lDialog, 'Mark All');

    Check(lOptionsGroup <> nil, 'Find dialog should expose a Search Options group');
    Check(lScopeGroup <> nil, 'Find dialog should expose a Scope group');
    Check(lModeGroup <> nil, 'Find dialog should expose a Search Mode group');
    Check((lInSelection <> nil) and IsDescendantOf(lInSelection, lScopeGroup),
      'In selection should live inside the Scope group');
    Check((lRegexRadio <> nil) and IsDescendantOf(lRegexRadio, lModeGroup),
      'Search mode radios should live inside the Search Mode group');
    Check(lMarkAllButton <> nil, 'Find dialog should expose a Mark All button');
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestFindDialogInnerControlsStayVisible;
var
  lDialog: TDSciFindDialog;
  lGroup: TGroupBox;
  lMatchCase: TCheckBox;
  lNormalMode: TRadioButton;
  lRegexMode: TRadioButton;
  lRect: TRect;
  lWholeWord: TCheckBox;

  procedure CheckVisibleInsideGroup(AControl: TControl; AParentGroup: TGroupBox;
    const ACaption: string);
  begin
    Check(AControl <> nil, ACaption + ' should exist');
    Check(AControl.Visible, ACaption + ' should be visible');
    Check((AControl.Width > 0) and (AControl.Height > 0),
      ACaption + ' should have a non-zero size');
    lRect.TopLeft := AParentGroup.ScreenToClient(AControl.ClientToScreen(Point(0, 0)));
    lRect.BottomRight := AParentGroup.ScreenToClient(
      AControl.ClientToScreen(Point(AControl.Width, AControl.Height)));
    Check(lRect.Left >= 0, ACaption + ' should not start before the group box');
    Check(lRect.Top >= 0, ACaption + ' should not start above the group box');
    Check(lRect.Right <= AParentGroup.ClientWidth,
      ACaption + ' should fit within the group box width');
    Check(lRect.Bottom <= AParentGroup.ClientHeight,
      ACaption + ' should fit within the group box height');
  end;
begin
  lDialog := TDSciFindDialog.Create(nil);
  try
    lDialog.ScaleForPPI(Screen.DefaultPixelsPerInch * 2);
    SettleForm(lDialog, True);

    lGroup := FindGroupBoxByCaption(lDialog, 'Search Options');
    lWholeWord := FindCheckBoxByCaption(lDialog, 'Whole word only');
    lMatchCase := FindCheckBoxByCaption(lDialog, 'Match case');
    Check(lGroup <> nil, 'Search Options group should exist');
    CheckVisibleInsideGroup(lWholeWord, lGroup, 'Whole word only');
    CheckVisibleInsideGroup(lMatchCase, lGroup, 'Match case');

    lGroup := FindGroupBoxByCaption(lDialog, 'Search Mode');
    lNormalMode := FindDescendantControl(lGroup, TRadioButton) as TRadioButton;
    lRegexMode := FindRadioButtonByCaption(lDialog, 'Regular expression');
    Check(lGroup <> nil, 'Search Mode group should exist');
    CheckVisibleInsideGroup(lNormalMode, lGroup, 'Normal search mode');
    CheckVisibleInsideGroup(lRegexMode, lGroup, 'Regular expression mode');
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestFindDialogActionButtonsStartAtScopeLevel;
var
  lCountButton: TButton;
  lDialog: TDSciFindDialog;
  lScopeGroup: TGroupBox;
  lTopDelta: Integer;
begin
  lDialog := TDSciFindDialog.Create(nil);
  try
    SettleForm(lDialog, True);

    lCountButton := FindButtonByCaption(lDialog, 'Count');
    lScopeGroup := FindGroupBoxByCaption(lDialog, 'Scope');
    Check(lCountButton <> nil, 'Find dialog should expose the Count button');
    Check(lScopeGroup <> nil, 'Find dialog should expose the Scope group');

    lTopDelta := Abs(
      lDialog.ScreenToClient(lCountButton.ClientToScreen(Point(0, 0))).Y -
      lDialog.ScreenToClient(lScopeGroup.ClientToScreen(Point(0, 0))).Y);
    Check(lTopDelta <= 2,
      Format('Count button block should start at the same vertical level as Scope (delta=%d)',
        [lTopDelta]));
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestFindDialogLayoutDoesNotOverlapWhenScaled;
var
  lDialog: TDSciFindDialog;
begin
  lDialog := TDSciFindDialog.Create(nil);
  try
    lDialog.ScaleForPPI(Screen.DefaultPixelsPerInch * 2);
    SettleForm(lDialog, True);

    CheckChildrenStayWithinParent(Self, lDialog, 'Find dialog');
    CheckChildrenDoNotOverlap(Self, lDialog, 'Find dialog');
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestFindDialogSearchFieldKeepsGapFromLabel;
var
  lDialog: TDSciFindDialog;
  lLabel: TLabel;
  lSearchCombo: TComboBox;
  lGap: Integer;
begin
  lDialog := TDSciFindDialog.Create(nil);
  try
    SettleForm(lDialog, True);

    lLabel := FindLabelByCaption(lDialog, 'Find what:');
    lSearchCombo := FindDescendantControl(lDialog, TComboBox) as TComboBox;
    Check(lLabel <> nil, 'Find dialog should expose the Find what label');
    Check(lSearchCombo <> nil, 'Find dialog should expose the search combo box');

    lGap := lDialog.ScreenToClient(lSearchCombo.ClientToScreen(Point(0, 0))).X -
      lDialog.ScreenToClient(lLabel.ClientToScreen(Point(lLabel.Width, 0))).X;
    Check(lGap >= 6,
      Format('Search field should keep a visible gap from the Find what label (gap=%d)', [lGap]));
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestFindDialogIsCompact;
var
  lDialog: TDSciFindDialog;
  lMaxHeight: Integer;
  lMaxMinHeight: Integer;
begin
  lDialog := TDSciFindDialog.Create(nil);
  try
    SettleForm(lDialog, True);

    lMaxHeight    := MulDiv(400, Screen.PixelsPerInch, 96);
    lMaxMinHeight := MulDiv(350, Screen.PixelsPerInch, 96);

    Check(lDialog.Height <= lMaxHeight,
      Format('Find dialog should be compact after layout (height=%d, max=%d at %d PPI)',
        [lDialog.Height, lMaxHeight, Screen.PixelsPerInch]));
    Check(lDialog.Constraints.MinHeight <= lMaxMinHeight,
      Format('Find dialog MinHeight constraint should be compact (actual=%d, max=%d)',
        [lDialog.Constraints.MinHeight, lMaxMinHeight]));
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestReplaceTabResultLabelIsBelowCombos;
var
  lComboBottomY: Integer;
  lDialog: TDSciFindDialog;
  lPageControl: TPageControl;
  lPageIdx: Integer;
  lReplaceTab: TTabSheet;
  lReplaceWithCombo: TComboBox;
  lReplaceWithLabel: TLabel;
  lResultLabel: TLabel;
  lResultTopY: Integer;
begin
  lDialog := TDSciFindDialog.Create(nil);
  try
    lPageControl := FindDescendantControl(lDialog, TPageControl) as TPageControl;
    Check(lPageControl <> nil, 'Dialog should contain a page control');

    lReplaceTab := nil;
    for lPageIdx := 0 to lPageControl.PageCount - 1 do
      if SameText(lPageControl.Pages[lPageIdx].Caption, 'Replace') then
      begin
        lReplaceTab := lPageControl.Pages[lPageIdx];
        Break;
      end;
    Check(lReplaceTab <> nil, 'Dialog should have a Replace tab');

    lPageControl.ActivePage := lReplaceTab;
    SettleForm(lDialog, True);

    lReplaceWithLabel := FindDescendantLabelByCaption(lReplaceTab, 'Replace with:');
    Check(lReplaceWithLabel <> nil, 'Replace tab should expose a "Replace with:" label');

    lReplaceWithCombo := FindSiblingControlToRight(lReplaceWithLabel, TComboBox) as TComboBox;
    Check(lReplaceWithCombo <> nil, 'Replace tab should have a combo box next to "Replace with:"');

    lResultLabel := FindDescendantLabelByCaption(lReplaceTab, '0 matches');
    Check(lResultLabel <> nil, 'Replace tab should expose the result label');

    lComboBottomY := lDialog.ScreenToClient(
      lReplaceWithCombo.ClientToScreen(Point(0, lReplaceWithCombo.Height))).Y;
    lResultTopY := lDialog.ScreenToClient(
      lResultLabel.ClientToScreen(Point(0, 0))).Y;

    Check(lResultTopY >= lComboBottomY,
      Format('Result label (top=%d) should be below the Replace with combo (bottom=%d)',
        [lResultTopY, lComboBottomY]));
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestReplaceTabCombosHaveEqualWidth;
var
  lDialog: TDSciFindDialog;
  lFindWhatCombo: TComboBox;
  lFindWhatLabel: TLabel;
  lPageControl: TPageControl;
  lPageIdx: Integer;
  lReplaceTab: TTabSheet;
  lReplaceWithCombo: TComboBox;
  lReplaceWithLabel: TLabel;
begin
  lDialog := TDSciFindDialog.Create(nil);
  try
    lPageControl := FindDescendantControl(lDialog, TPageControl) as TPageControl;
    Check(lPageControl <> nil, 'Dialog should contain a page control');

    lReplaceTab := nil;
    for lPageIdx := 0 to lPageControl.PageCount - 1 do
      if SameText(lPageControl.Pages[lPageIdx].Caption, 'Replace') then
      begin
        lReplaceTab := lPageControl.Pages[lPageIdx];
        Break;
      end;
    Check(lReplaceTab <> nil, 'Dialog should have a Replace tab');

    lPageControl.ActivePage := lReplaceTab;
    SettleForm(lDialog, True);

    lFindWhatLabel    := FindDescendantLabelByCaption(lReplaceTab, 'Find what:');
    lReplaceWithLabel := FindDescendantLabelByCaption(lReplaceTab, 'Replace with:');
    Check(lFindWhatLabel <> nil,    'Replace tab should expose a "Find what:" label');
    Check(lReplaceWithLabel <> nil, 'Replace tab should expose a "Replace with:" label');

    lFindWhatCombo    := FindSiblingControlToRight(lFindWhatLabel, TComboBox) as TComboBox;
    lReplaceWithCombo := FindSiblingControlToRight(lReplaceWithLabel, TComboBox) as TComboBox;
    Check(lFindWhatCombo <> nil,    'Replace tab should have a combo box for Find what');
    Check(lReplaceWithCombo <> nil, 'Replace tab should have a combo box for Replace with');

    CheckEquals(lFindWhatCombo.Width, lReplaceWithCombo.Width,
      Format('Find what combo (w=%d) and Replace with combo (w=%d) should have equal width',
        [lFindWhatCombo.Width, lReplaceWithCombo.Width]));
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestVisualCatalogUsesConfigSnapshot;
var
  lCatalog: TDSciVisualCatalog;
  lCppGroup: TDSciVisualStyleGroup;
  lConfig: TDSciVisualConfig;
begin
  lConfig := TDSciVisualConfig.Create;
  try
    lConfig.LoadFromFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
    lCatalog := TDSciVisualCatalog.Create;
    try
      lCatalog.LoadFromConfig(lConfig);
      lCppGroup := lCatalog.FindLanguage('cpp');
      Check(lCppGroup <> nil, 'Config-backed catalog should expose the cpp language group');
      Check(Pos('cpp', LowerCase(lCppGroup.Extensions)) > 0,
        'Config-backed catalog should expose imported language extensions');

      lConfig.StyleOverrides.FindGroup('cpp').Extensions := 'broken';

      lCppGroup := lCatalog.FindLanguage('cpp');
      Check(lCppGroup <> nil,
        'Catalog snapshot should survive mutations to the source config after load');
      Check(Pos('cpp', LowerCase(lCppGroup.Extensions)) > 0,
        'Catalog snapshot should keep the original imported extensions');
    finally
      lCatalog.Free;
    end;
  finally
    lConfig.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogFieldColumnsAlignWithThemeRow;
var
  lDialog: TDSciVisualSettingsDialog;
  lImportThemeButton: TButton;
  lLanguageCombo: TControl;
  lLanguageLabel: TLabel;
  lStyleCombo: TControl;
  lStyleLabel: TLabel;
  lThemeCombo: TControl;
  lThemeLabel: TLabel;
  lThemeLeft: Integer;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    SettleForm(lDialog, True);
    ActivateSettingsCategory(Self, lDialog, 'Styles');

    lThemeLabel := FindLabelByCaption(lDialog, 'Theme');
    lLanguageLabel := FindLabelByCaption(lDialog, 'Language');
    lStyleLabel := FindLabelByCaption(lDialog, 'Style');
    lThemeCombo := FindFieldForLabel(lThemeLabel, TComboBox);
    lImportThemeButton := FindButtonByCaption(lDialog, 'Import...');
    lLanguageCombo := FindFieldForLabel(lLanguageLabel, TComboBox);
    lStyleCombo := FindFieldForLabel(lStyleLabel, TComboBox);

    Check(lThemeCombo <> nil, 'Theme row should contain a combo box');
    Check(lImportThemeButton <> nil, 'Theme row should contain the Import theme button');
    Check(lLanguageCombo <> nil, 'Language row should contain a combo box');
    Check(lStyleCombo <> nil, 'Style row should contain a combo box');

    lThemeLeft := lThemeCombo.ClientToScreen(Point(0, 0)).X;

    Check(Abs(lThemeLeft - lLanguageCombo.ClientToScreen(Point(0, 0)).X) <= 4,
      Format('Language field should align with Theme field left edge (theme=%d, language=%d)',
        [lThemeLeft, lLanguageCombo.ClientToScreen(Point(0, 0)).X]));

    Check(Abs(lThemeLeft - lStyleCombo.ClientToScreen(Point(0, 0)).X) <= 4,
      Format('Style field should align with Theme field left edge (theme=%d, style=%d)',
        [lThemeLeft, lStyleCombo.ClientToScreen(Point(0, 0)).X]));
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestVisualCatalogLoadsLanguageExtensions;
var
  lCatalog: TDSciVisualCatalog;
  lConfig: TDSciVisualConfig;
  lCppGroup: TDSciVisualStyleGroup;
begin
  lConfig := TDSciVisualConfig.Create;
  try
    lConfig.LoadFromFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
    lCatalog := TDSciVisualCatalog.Create;
    try
      lCatalog.LoadFromConfig(lConfig);
      lCppGroup := lCatalog.FindLanguage('cpp');
      Check(lCppGroup <> nil, 'Catalog should expose the cpp language group');
      Check(Pos('cpp', LowerCase(lCppGroup.Extensions)) > 0,
        'cpp language extensions should be available from DScintilla.config.xml');
      Check(Pos('hpp', LowerCase(lCppGroup.Extensions)) > 0,
        'cpp language extensions should include header extensions from DScintilla.config.xml');
    finally
      lCatalog.Free;
    end;
  finally
    lConfig.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogDoesNotNeedVerticalScrollWhenShown;
var
  lButtonTop: Integer;
  lCancelButton: TButton;
  lCardPanel: TCardPanel;
  lDialog: TDSciVisualSettingsDialog;
  lScrollBox: TScrollBox;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    SettleForm(lDialog, True);

    lScrollBox := FindScrollBox(lDialog);
    lCardPanel := FindCardPanel(lDialog);
    lCancelButton := FindButtonByCaption(lDialog, 'Cancel');

    Check(lScrollBox = nil, 'Settings dialog should fit without a scroll box');
    Check(lCardPanel <> nil, 'Settings dialog should expose a TCardPanel host');
    Check(lCancelButton <> nil, 'Settings dialog should expose dialog buttons');
    lButtonTop := lDialog.ScreenToClient(lCancelButton.ClientToScreen(Point(0, 0))).Y;
    Check(lCardPanel.Top + lCardPanel.Height <= lButtonTop,
      Format('Settings content should fit above the button row (content bottom=%d, button top=%d)',
        [lCardPanel.Top + lCardPanel.Height, lButtonTop]));
    CheckChildrenStayWithinParent(Self, lDialog, 'Settings dialog');
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogGroupBoxesContainControls;
var
  lDialog: TDSciVisualSettingsDialog;
  lExtensionsLabel: TLabel;
  lHighlightLabel: TLabel;
  lLanguageCombo: TComboBox;
  lMarginsGroup: TGroupBox;
  lLineWrapping: TCheckBox;
  lSearchHighlightGroup: TGroupBox;
  lStyleGroup: TGroupBox;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    SettleForm(lDialog, True);
    ActivateSettingsCategory(Self, lDialog, 'Styles');

    lStyleGroup := FindVisibleGroupBoxByCaption(lDialog, 'Style Options');
    lExtensionsLabel := FindLabelByCaption(lDialog, 'Extensions');
    lLanguageCombo := FindFieldForLabel(FindLabelByCaption(lDialog, 'Language'), TComboBox) as TComboBox;

    Check(lStyleGroup <> nil, 'Style Options must be a TGroupBox');
    Check((lExtensionsLabel <> nil) and IsDescendantOf(lExtensionsLabel, lStyleGroup),
      'Extensions label should be inside Style Options');
    Check((lLanguageCombo <> nil) and IsDescendantOf(lLanguageCombo, lStyleGroup),
      'Language combo should be inside Style Options');

    ActivateSettingsCategory(Self, lDialog, 'Selection && Highlighting');
    lSearchHighlightGroup := FindVisibleGroupBoxByCaption(lDialog, 'Search Highlight');
    lHighlightLabel := FindVisibleLabelByCaption(lDialog, 'Highlight color');
    Check((lSearchHighlightGroup <> nil) and (lHighlightLabel <> nil) and
      IsDescendantOf(lHighlightLabel, lSearchHighlightGroup),
      'Highlight color label should be inside the Search Highlight section');

    ActivateSettingsCategory(Self, lDialog, 'Wrapping');
    lMarginsGroup := FindVisibleGroupBoxByCaption(lDialog, 'Margins');
    lLineWrapping := FindCheckBoxByCaption(lDialog, 'Line wrapping');
    Check((lMarginsGroup <> nil) and (lLineWrapping <> nil) and
      IsDescendantOf(lLineWrapping, lMarginsGroup),
      'Line wrapping checkbox should live inside the Margins section');
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogDoesNotUseScrollContainer;
var
  lDialog: TDSciVisualSettingsDialog;
  lIndex: Integer;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    for lIndex := 0 to lDialog.ComponentCount - 1 do
      Check(not (lDialog.Components[lIndex] is TScrollBox),
        'Settings dialog should no longer create a TScrollBox');
  finally
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogExtensionsUseEditWithHint;
var
  lDialog: TDSciVisualSettingsDialog;
  lExtensionsEdit: TEdit;
  lExtensionsLabel: TLabel;
  lIndex: Integer;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    SettleForm(lDialog, True);

    lExtensionsLabel := FindLabelByCaption(lDialog, 'Extensions');
    lExtensionsEdit := FindFieldForLabel(lExtensionsLabel, TEdit) as TEdit;

    Check(lExtensionsEdit <> nil, 'Extensions should use a TEdit field');
    Check(Pos('space', LowerCase(lExtensionsEdit.Hint)) > 0,
      'Extensions hint should mention spaces as separators');
    Check(Pos('comma', LowerCase(lExtensionsEdit.Hint)) > 0,
      'Extensions hint should mention commas as separators');
    Check(Pos('semicolon', LowerCase(lExtensionsEdit.Hint)) > 0,
      'Extensions hint should mention semicolons as separators');

    for lIndex := 0 to lDialog.ComponentCount - 1 do
      Check(not (lDialog.Components[lIndex] is TMemo),
        'Settings dialog should not create a TMemo for Extensions anymore');
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogGroupBoxesUseDefaultPainting;
var
  lDialog: TDSciVisualSettingsDialog;
  lSelectionGroup: TGroupBox;
  lSearchHighlightGroup: TGroupBox;
  lStyleGroup: TGroupBox;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    SettleForm(lDialog, True);
    ActivateSettingsCategory(Self, lDialog, 'Styles');

    lStyleGroup := FindVisibleGroupBoxByCaption(lDialog, 'Style Options');

    Check(lStyleGroup <> nil, 'Style Options group should exist');
    Check(lStyleGroup.ParentBackground,
      'Style Options should keep default parent background painting so the caption is visible');
    Check(not SameText(Trim(lStyleGroup.Caption), ''),
      'Style Options caption should stay assigned');

    ActivateSettingsCategory(Self, lDialog, 'Selection && Highlighting');
    lSelectionGroup := FindVisibleGroupBoxByCaption(lDialog, 'Selection');
    lSearchHighlightGroup := FindVisibleGroupBoxByCaption(lDialog, 'Search Highlight');
    Check(lSelectionGroup <> nil, 'Selection group should exist');
    Check(lSearchHighlightGroup <> nil, 'Search Highlight group should exist');
    Check(lSelectionGroup.ParentBackground,
      'Selection should keep default parent background painting so the caption is visible');
    Check(lSearchHighlightGroup.ParentBackground,
      'Search Highlight should keep default parent background painting so the caption is visible');
    Check(not SameText(Trim(lSelectionGroup.Caption), ''),
      'Selection caption should stay assigned');
    Check(not SameText(Trim(lSearchHighlightGroup.Caption), ''),
      'Search Highlight caption should stay assigned');
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogStacksStartBelowGroupBoxCaptions;
var
  lAdjusted: TRect;
  lDialog: TDSciVisualSettingsDialog;
  lSearchHighlightGroup: TGroupBox;
  lSearchHighlightStack: TStackPanel;
  lSelectionGroup: TGroupBox;
  lSelectionStack: TStackPanel;
  lStyleGroup: TGroupBox;
  lStyleStack: TStackPanel;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    SettleForm(lDialog, True);
    ActivateSettingsCategory(Self, lDialog, 'Styles');

    lStyleGroup := FindVisibleGroupBoxByCaption(lDialog, 'Style Options');
    lStyleStack := FindDescendantControl(lStyleGroup, TStackPanel) as TStackPanel;

    Check(lStyleGroup <> nil, 'Style Options group should exist');
    Check(lStyleStack <> nil, 'Style Options should contain a stack panel');

    lAdjusted := lStyleGroup.ClientRect;
    TGroupBoxAccess(lStyleGroup).AdjustClientRect(lAdjusted);
    Check(lStyleStack.Top >= lAdjusted.Top,
      Format('Style stack should start below the group box caption area (stack=%d, adjusted=%d)',
        [lStyleStack.Top, lAdjusted.Top]));

    ActivateSettingsCategory(Self, lDialog, 'Selection && Highlighting');
    lSelectionGroup := FindVisibleGroupBoxByCaption(lDialog, 'Selection');
    lSearchHighlightGroup := FindVisibleGroupBoxByCaption(lDialog, 'Search Highlight');
    lSelectionStack := FindDescendantControl(lSelectionGroup, TStackPanel) as TStackPanel;
    lSearchHighlightStack := FindDescendantControl(lSearchHighlightGroup, TStackPanel) as TStackPanel;

    Check(lSelectionGroup <> nil, 'Selection group should exist');
    Check(lSearchHighlightGroup <> nil, 'Search Highlight group should exist');
    Check(lSelectionStack <> nil, 'Selection should contain a stack panel');
    Check(lSearchHighlightStack <> nil, 'Search Highlight should contain a stack panel');

    lAdjusted := lSelectionGroup.ClientRect;
    TGroupBoxAccess(lSelectionGroup).AdjustClientRect(lAdjusted);
    Check(lSelectionStack.Top >= lAdjusted.Top,
      Format('Selection stack should start below the group box caption area (stack=%d, adjusted=%d)',
        [lSelectionStack.Top, lAdjusted.Top]));

    lAdjusted := lSearchHighlightGroup.ClientRect;
    TGroupBoxAccess(lSearchHighlightGroup).AdjustClientRect(lAdjusted);
    Check(lSearchHighlightStack.Top >= lAdjusted.Top,
      Format('Search Highlight stack should start below the group box caption area (stack=%d, adjusted=%d)',
        [lSearchHighlightStack.Top, lAdjusted.Top]));
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogLayoutDoesNotOverlapWhenScaled;
var
  lDialog: TDSciVisualSettingsDialog;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    lDialog.ScaleForPPI(Screen.DefaultPixelsPerInch * 2);
    SettleForm(lDialog, True);

    CheckChildrenStayWithinParent(Self, lDialog, 'Settings dialog');
    CheckChildrenDoNotOverlap(Self, lDialog, 'Settings dialog');
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogMiscCheckBoxesAreVisible;
var
  lBookmarkGutter: TCheckBox;
  lDialog: TDSciVisualSettingsDialog;
  lFoldGutter: TCheckBox;
  lGutterStyleCombo: TComboBox;
  lGutterStyleLabel: TLabel;
  lLineNumbering: TCheckBox;
  lLineWrapping: TCheckBox;
  lMarginsGroup: TGroupBox;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    ActivateSettingsCategory(Self, lDialog, 'Wrapping');

    lMarginsGroup := FindVisibleGroupBoxByCaption(lDialog, 'Margins');
    lLineNumbering := FindCheckBoxByCaption(lDialog, 'Line numbering');
    lBookmarkGutter := FindCheckBoxByCaption(lDialog, 'Bookmark gutter');
    lFoldGutter := FindCheckBoxByCaption(lDialog, 'Fold gutter');
    lLineWrapping := FindCheckBoxByCaption(lDialog, 'Line wrapping');
    lGutterStyleLabel := FindLabelByCaption(lDialog, 'Gutter style');
    lGutterStyleCombo := FindFieldForLabel(lGutterStyleLabel, TComboBox) as TComboBox;

    Check(lMarginsGroup <> nil, 'Settings dialog should expose a Margins group');
    Check(lLineNumbering <> nil, 'Margins group should contain the Line numbering checkbox');
    Check(lBookmarkGutter <> nil, 'Margins group should contain the Bookmark gutter checkbox');
    Check(lFoldGutter <> nil, 'Margins group should contain the Fold gutter checkbox');
    Check(lLineWrapping <> nil, 'Margins group should contain the Line wrapping checkbox');
    Check(lGutterStyleLabel <> nil, 'Margins group should expose the Gutter style label');
    Check(lGutterStyleCombo <> nil, 'Margins group should expose the Gutter style combo');
    Check(lMarginsGroup.ScreenToClient(lLineNumbering.ClientToScreen(Point(0,
      lLineNumbering.Height))).Y <= lMarginsGroup.ClientHeight,
      'Line numbering should be visible inside Margins');
    Check(lMarginsGroup.ScreenToClient(lBookmarkGutter.ClientToScreen(Point(0,
      lBookmarkGutter.Height))).Y <= lMarginsGroup.ClientHeight,
      'Bookmark gutter should be visible inside Margins');
    Check(lMarginsGroup.ScreenToClient(lFoldGutter.ClientToScreen(Point(0,
      lFoldGutter.Height))).Y <= lMarginsGroup.ClientHeight,
      'Fold gutter should be visible inside Margins');
    Check(lMarginsGroup.ScreenToClient(lLineWrapping.ClientToScreen(Point(0,
      lLineWrapping.Height))).Y <= lMarginsGroup.ClientHeight,
      'Line wrapping should be visible inside Margins');
    Check(IsDescendantOf(lGutterStyleCombo, lMarginsGroup),
      'Gutter style combo should live inside the Margins group');
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogMiscOptionsExposeSearchSyncAndFileSizeLimit;
var
  lDialog: TDSciVisualSettingsDialog;
  lFileSizeEdit: TSpinEdit;
  lFileSizeLabel: TLabel;
  lDocumentGroup: TGroupBox;
  lSearchSync: TCheckBox;
  lSearchGroup: TGroupBox;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    ActivateSettingsCategory(Self, lDialog, 'Selection && Highlighting');
    lSearchGroup := FindVisibleGroupBoxByCaption(lDialog, 'Search');
    lSearchSync := FindCheckBoxByCaption(lDialog, 'Sync inline search with Find dialog');
    Check(lSearchGroup <> nil, 'Selection && Highlighting should expose the Search group');
    Check(lSearchSync <> nil, 'Search group should expose the SearchSync checkbox');
    Check(lSearchSync.Visible, 'SearchSync checkbox should stay visible');
    Check(IsDescendantOf(lSearchSync, lSearchGroup),
      'SearchSync checkbox should live inside the Search group');

    ActivateSettingsCategory(Self, lDialog, 'Folding && Limits');
    lFileSizeLabel := FindLabelByCaption(lDialog, 'File size limit');
    lFileSizeEdit := FindFieldForLabel(lFileSizeLabel, TSpinEdit) as TSpinEdit;
    lDocumentGroup := FindVisibleGroupBoxByCaption(lDialog, 'Document');

    Check(lDocumentGroup <> nil, 'Folding && Limits should expose the Document group');
    Check(lFileSizeLabel <> nil, 'Document should expose the File size limit label');
    Check(lFileSizeEdit <> nil, 'File size limit should use a spin edit');
    Check(IsDescendantOf(lFileSizeLabel, lDocumentGroup),
      'File size limit label should live inside the Document group');
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogGeneralCategoryExposesRenderingControls;
var
  lAutoClose: TAutoCloseDialog;
  lBackendCombo: TComboBox;
  lBackendLabel: TLabel;
  lCategoryCombo: TComboBox;
  lCategoryLabel: TLabel;
  lConfig: TDSciVisualConfig;
  lDialog: TDSciVisualSettingsDialog;
  lFontLocaleEdit: TEdit;
  lFontLocaleLabel: TLabel;
  lFontQualityCombo: TComboBox;
  lFontQualityLabel: TLabel;
  lGeneralGroup: TGroupBox;
  lLabelRect: TRect;
  lMinFieldWidth: Integer;
  lScalePPI: Integer;
  lTempConfigFile: string;
  lTempDir: string;

  procedure CheckFieldLayout(ALabel: TLabel; AField: TControl; const ACaption: string);
  var
    lFieldRect: TRect;
  begin
    Check(AField.Visible, ACaption + ' should stay visible');
    lLabelRect.TopLeft := lGeneralGroup.ScreenToClient(ALabel.ClientToScreen(Point(0, 0)));
    lLabelRect.BottomRight := lGeneralGroup.ScreenToClient(
      ALabel.ClientToScreen(Point(ALabel.Width, ALabel.Height)));
    lFieldRect.TopLeft := lGeneralGroup.ScreenToClient(AField.ClientToScreen(Point(0, 0)));
    lFieldRect.BottomRight := lGeneralGroup.ScreenToClient(
      AField.ClientToScreen(Point(AField.Width, AField.Height)));

    Check(lFieldRect.Left >= lLabelRect.Right,
      ACaption + ' field should start after its label');
    Check(lFieldRect.Right <= lGeneralGroup.ClientWidth,
      ACaption + ' field should fit within the group box width');
    Check(lFieldRect.Bottom <= lGeneralGroup.ClientHeight,
      ACaption + ' field should fit within the group box height');
    Check(AField.Width >= lMinFieldWidth,
      ACaption + ' field should keep a practical width on HighDPI');
  end;
begin
  lTempDir := CreateWritableTempDir;
  try
    lTempConfigFile := TPath.Combine(lTempDir, 'rendering-ui.config.xml');
    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.Technology := sctDIRECT_WRITE_D_C;
      lConfig.FontQuality := scfqQUALITY_ANTIALIASED;
      lConfig.FontLocale := 'ru-RU';

      lDialog := TDSciVisualSettingsDialog.Create(nil);
      lAutoClose := TAutoCloseDialog.Create;
      try
        lAutoClose.Attach(lDialog);
        Check(not lDialog.EditSettings('', lTempConfigFile, lConfig),
          'Auto-close harness should dismiss the dialog with Cancel');

        lScalePPI := Screen.DefaultPixelsPerInch * 2;
        lDialog.ScaleForPPI(lScalePPI);
        lCategoryLabel := FindLabelByCaption(lDialog, 'Category');
        lCategoryCombo := FindFieldForLabel(lCategoryLabel, TComboBox) as TComboBox;
        Check(lCategoryCombo <> nil, 'Settings dialog should expose the Category selector');
        Check(lCategoryCombo.Items.Count > 0, 'Category selector should contain items');
        CheckEquals('General', lCategoryCombo.Items[0],
          'General should stay the first settings category');
        ActivateSettingsCategory(Self, lDialog, 'General');
        lGeneralGroup := FindVisibleGroupBoxByCaption(lDialog, 'General');
        lBackendLabel := FindVisibleLabelByCaption(lDialog, 'Rendering backend');
        lFontQualityLabel := FindVisibleLabelByCaption(lDialog, 'Font quality');
        lFontLocaleLabel := FindVisibleLabelByCaption(lDialog, 'Font locale');
        lBackendCombo := FindFieldForLabel(lBackendLabel, TComboBox) as TComboBox;
        lFontQualityCombo := FindFieldForLabel(lFontQualityLabel, TComboBox) as TComboBox;
        lFontLocaleEdit := FindFieldForLabel(lFontLocaleLabel, TEdit) as TEdit;

        Check(lGeneralGroup <> nil, 'General category should expose the General group');
        Check(lBackendCombo <> nil, 'General category should expose the rendering backend combo');
        Check(lFontQualityCombo <> nil, 'General category should expose the font quality combo');
        Check(lFontLocaleEdit <> nil, 'General category should expose the font locale edit');
        Check(IsDescendantOf(lBackendCombo, lGeneralGroup),
          'Rendering backend combo should live inside the General group');
        Check(IsDescendantOf(lFontQualityCombo, lGeneralGroup),
          'Font quality combo should live inside the General group');
        Check(IsDescendantOf(lFontLocaleEdit, lGeneralGroup),
          'Font locale edit should live inside the General group');
        CheckEquals('DirectWrite DC', lBackendCombo.Text);
        CheckEquals('Antialiased', lFontQualityCombo.Text);
        CheckEquals('ru-RU', lFontLocaleEdit.Text);
        Check(FindVisibleLabelByCaption(lDialog, 'Highlight color') = nil,
          'General category should not expose stale Search Highlight rows');
        Check(FindVisibleLabelByCaption(lDialog, 'Transparency') = nil,
          'General category should not expose stale transparency rows');

        lMinFieldWidth := MulDiv(150, lScalePPI, 96);
        CheckFieldLayout(lBackendLabel, lBackendCombo, 'Rendering backend');
        CheckFieldLayout(lFontQualityLabel, lFontQualityCombo, 'Font quality');
        CheckFieldLayout(lFontLocaleLabel, lFontLocaleEdit, 'Font locale');
      finally
        lAutoClose.Free;
        lDialog.Free;
      end;
    finally
      lConfig.Free;
    end;
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogOptionPairRowsAlign;
var
  lBackgroundBox: TPanel;
  lBackgroundLabel: TLabel;
  lDialog: TDSciVisualSettingsDialog;
  lForegroundBox: TPanel;
  lForegroundLabel: TLabel;
  lSearchHighlightGroup: TGroupBox;
  lHighlightBox: TPanel;
  lHighlightLabel: TLabel;
  lOutlineEdit: TSpinEdit;
  lOutlineLabel: TLabel;
  lTransparencyEdit: TSpinEdit;
  lTransparencyLabel: TLabel;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    SettleForm(lDialog, True);
    ActivateSettingsCategory(Self, lDialog, 'Styles');

    lForegroundLabel := FindVisibleLabelByCaption(lDialog, 'Foreground');
    lBackgroundLabel := FindVisibleLabelByCaption(lDialog, 'Background');

    lForegroundBox := FindSiblingControlToRight(lForegroundLabel, TPanel) as TPanel;
    lBackgroundBox := FindSiblingControlToRight(lBackgroundLabel, TPanel) as TPanel;

    Check(lForegroundBox <> nil, 'Foreground row should contain a preview box');
    Check(lBackgroundBox <> nil, 'Background row should contain a preview box');
    Check(Abs(lForegroundBox.Width - lBackgroundBox.Width) <= 2,
      Format('Foreground and Background previews should have matching widths (%d vs %d)',
        [lForegroundBox.Width, lBackgroundBox.Width]));
    Check(lBackgroundBox.Width >= 80,
      Format('Background preview should keep a usable width (actual=%d)', [lBackgroundBox.Width]));

    ActivateSettingsCategory(Self, lDialog, 'Selection && Highlighting');
    lSearchHighlightGroup := FindVisibleGroupBoxByCaption(lDialog, 'Search Highlight');
    Check(lSearchHighlightGroup <> nil, 'Selection && Highlighting should expose Search Highlight');
    lHighlightLabel := FindDescendantLabelByCaption(lSearchHighlightGroup, 'Highlight color');
    lTransparencyLabel := FindDescendantLabelByCaption(lSearchHighlightGroup, 'Transparency');
    lOutlineLabel := FindDescendantLabelByCaption(lSearchHighlightGroup, 'Outline');
    lHighlightBox := FindFieldForLabel(lHighlightLabel, TPanel) as TPanel;
    lTransparencyEdit := FindFieldForLabel(lTransparencyLabel, TSpinEdit) as TSpinEdit;
    lOutlineEdit := FindFieldForLabel(lOutlineLabel, TSpinEdit) as TSpinEdit;

    Check(lHighlightBox <> nil, 'Highlight color row should contain a preview box');
    Check(lTransparencyEdit <> nil, 'Transparency row should contain a spin edit');
    Check(lOutlineEdit <> nil, 'Outline row should contain a spin edit');
    Check(Abs(lDialog.ScreenToClient(lHighlightBox.ClientToScreen(Point(0, 0))).X -
      lDialog.ScreenToClient(lTransparencyEdit.ClientToScreen(Point(0, 0))).X) <= 2,
      'Highlight color and Transparency should share the same field column');
    Check(Abs(lDialog.ScreenToClient(lTransparencyEdit.ClientToScreen(Point(0, 0))).X -
      lDialog.ScreenToClient(lOutlineEdit.ClientToScreen(Point(0, 0))).X) <= 2,
      'Transparency and Outline should share the same field column');
    Check(Abs(lDialog.ScreenToClient(lTransparencyLabel.ClientToScreen(Point(0, 0))).X -
      lDialog.ScreenToClient(lOutlineLabel.ClientToScreen(Point(0, 0))).X) <= 2,
      'Transparency and Outline labels should share the same label column');
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogSectionOrder;
var
  lCardPanel: TCardPanel;
  lCategoryLabel: TLabel;
  lDialog: TDSciVisualSettingsDialog;
  lSearchGroup: TGroupBox;
  lSearchHighlightGroup: TGroupBox;
  lSelectionGroup: TGroupBox;
  lSmartHighlightGroup: TGroupBox;
  lCategoryTop: Integer;
  lStyleGroup: TGroupBox;
  lThemeTop: Integer;
  lThemeLabel: TLabel;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    SettleForm(lDialog, True);
    ActivateSettingsCategory(Self, lDialog, 'Styles');

    lThemeLabel := FindLabelByCaption(lDialog, 'Theme');
    lCategoryLabel := FindLabelByCaption(lDialog, 'Category');
    lCardPanel := FindCardPanel(lDialog);
    lStyleGroup := FindVisibleGroupBoxByCaption(lDialog, 'Style Options');

    Check(lThemeLabel <> nil, 'Settings dialog should expose a Theme label');
    Check(lCategoryLabel <> nil, 'Settings dialog should expose a Category label');
    Check(lCardPanel <> nil, 'Settings dialog should expose a TCardPanel');
    Check(lStyleGroup <> nil, 'Styles card should expose the Style Options group');
    lThemeTop := lThemeLabel.ClientToScreen(Point(0, 0)).Y;
    lCategoryTop := lCategoryLabel.ClientToScreen(Point(0, 0)).Y;
    Check(lCategoryTop < lCardPanel.ClientToScreen(Point(0, 0)).Y,
      Format('Category selector should be above the card panel (category=%d, card=%d)',
        [lCategoryTop, lCardPanel.ClientToScreen(Point(0, 0)).Y]));
    Check(lThemeTop >= lCardPanel.ClientToScreen(Point(0, 0)).Y,
      Format('Theme selector should now live inside the Styles card (theme=%d, card top=%d)',
        [lThemeTop, lCardPanel.ClientToScreen(Point(0, 0)).Y]));
    Check(lThemeTop < lStyleGroup.ClientToScreen(Point(0, 0)).Y,
      Format('Theme selector should stay above Style Options inside the Styles card (theme=%d, style=%d)',
        [lThemeTop, lStyleGroup.ClientToScreen(Point(0, 0)).Y]));

    ActivateSettingsCategory(Self, lDialog, 'Selection && Highlighting');
    Check(FindVisibleLabelByCaption(lDialog, 'Theme') = nil,
      'Theme selector should be hidden outside the Styles category');
    lSelectionGroup := FindVisibleGroupBoxByCaption(lDialog, 'Selection');
    lSearchHighlightGroup := FindVisibleGroupBoxByCaption(lDialog, 'Search Highlight');
    lSmartHighlightGroup := FindVisibleGroupBoxByCaption(lDialog, 'Smart Highlighting');
    lSearchGroup := FindVisibleGroupBoxByCaption(lDialog, 'Search');
    Check(lSelectionGroup <> nil, 'Selection group should exist');
    Check(lSearchHighlightGroup <> nil, 'Search Highlight group should exist');
    Check(lSmartHighlightGroup <> nil, 'Smart Highlighting group should exist');
    Check(lSearchGroup <> nil, 'Search group should exist');
    Check(lSelectionGroup.Top < lSearchHighlightGroup.Top,
      'Selection should be above Search Highlight');
    Check(lSearchHighlightGroup.Top < lSmartHighlightGroup.Top,
      'Search Highlight should be above Smart Highlighting');
    Check(lSmartHighlightGroup.Top < lSearchGroup.Top,
      'Smart Highlighting should be above Search');
  finally
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogTallCardsFitContent;
var
  lCardPanel: TCardPanel;
  lDialog: TDSciVisualSettingsDialog;
  lPrintingGroup: TGroupBox;
  lSearchGroup: TGroupBox;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    ActivateSettingsCategory(Self, lDialog, 'Selection && Highlighting');
    lCardPanel := FindCardPanel(lDialog);
    lSearchGroup := FindVisibleGroupBoxByCaption(lDialog, 'Search');
    Check(lCardPanel <> nil, 'Settings dialog should expose a TCardPanel');
    Check(lSearchGroup <> nil, 'Selection && Highlighting should expose the Search group');
    Check(lCardPanel.ScreenToClient(lSearchGroup.ClientToScreen(Point(0, lSearchGroup.Height))).Y <=
      lCardPanel.ClientHeight,
      'Selection && Highlighting content should fit vertically inside the active card');
    CheckChildrenStayWithinParent(Self, lDialog, 'Selection && Highlighting settings');

    ActivateSettingsCategory(Self, lDialog, 'Folding && Limits');
    lPrintingGroup := FindVisibleGroupBoxByCaption(lDialog, 'Printing');
    Check(lPrintingGroup <> nil, 'Folding && Limits should expose the Printing group');
    Check(lCardPanel.ScreenToClient(lPrintingGroup.ClientToScreen(Point(0, lPrintingGroup.Height))).Y <=
      lCardPanel.ClientHeight,
      'Folding && Limits content should fit vertically inside the active card');
    CheckChildrenStayWithinParent(Self, lDialog, 'Folding && Limits settings');
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogStyleGroupFitsContent;
var
  lBottomGap: Integer;
  lDialog: TDSciVisualSettingsDialog;
  lStyleGroup: TGroupBox;
  lUnderlineCheck: TCheckBox;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    SettleForm(lDialog, True);
    ActivateSettingsCategory(Self, lDialog, 'Styles');

    lStyleGroup := FindGroupBoxByCaption(lDialog, 'Style Options');
    lUnderlineCheck := FindCheckBoxByCaption(lDialog, 'Underline');

    Check(lStyleGroup <> nil, 'Settings dialog should expose a Style Options group');
    Check(lUnderlineCheck <> nil, 'Style Options should contain the Underline checkbox');

    lBottomGap := lStyleGroup.ClientHeight -
      lStyleGroup.ScreenToClient(lUnderlineCheck.ClientToScreen(
        Point(0, lUnderlineCheck.Height))).Y;
    Check(lBottomGap >= 0, 'Underline should be visible inside Style Options');
    Check(lBottomGap <= 48,
      Format('Style Options should not leave a large empty area after the last row (gap=%d)',
        [lBottomGap]));
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogStyleFieldOrder;
var
  lDialog: TDSciVisualSettingsDialog;
  lExtensionsLabel: TLabel;
  lLanguageLabel: TLabel;
  lStyleLabel: TLabel;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    SettleForm(lDialog, True);
    ActivateSettingsCategory(Self, lDialog, 'Styles');

    lLanguageLabel := FindLabelByCaption(lDialog, 'Language');
    lExtensionsLabel := FindLabelByCaption(lDialog, 'Extensions');
    lStyleLabel := FindLabelByCaption(lDialog, 'Style');

    Check(lLanguageLabel <> nil, 'Settings dialog should expose a Language label');
    Check(lExtensionsLabel <> nil, 'Settings dialog should expose an Extensions label');
    Check(lStyleLabel <> nil, 'Settings dialog should expose a Style label');
    Check(lLanguageLabel.ClientToScreen(Point(0, 0)).Y <
      lExtensionsLabel.ClientToScreen(Point(0, 0)).Y,
      'Extensions should be located below Language');
    Check(lExtensionsLabel.ClientToScreen(Point(0, 0)).Y <
      lStyleLabel.ClientToScreen(Point(0, 0)).Y,
      'Style should remain below Extensions');
  finally
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogWidthIsCompact;
var
  lDialog: TDSciVisualSettingsDialog;
  lImportThemeButton: TButton;
  lThemeCombo: TComboBox;
  lThemeLabel: TLabel;
  lThemeRow: TWinControl;
  lTrailingGap: Integer;
  lUsedWidth: Integer;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    SettleForm(lDialog, True);
    ActivateSettingsCategory(Self, lDialog, 'Styles');

    lThemeLabel := FindLabelByCaption(lDialog, 'Theme');
    lThemeCombo := FindFieldForLabel(lThemeLabel, TComboBox) as TComboBox;
    lImportThemeButton := FindButtonByCaption(lDialog, 'Import...');

    Check(lThemeCombo <> nil, 'Theme row should contain a combo box');
    Check(lImportThemeButton <> nil, 'Theme row should contain the Import theme button');
    Check(lDialog.ClientWidth <= MulDiv(680, Screen.DefaultPixelsPerInch, 96),
      Format('Settings dialog should keep a compact client width (actual=%d)',
        [lDialog.ClientWidth]));

    lThemeRow := TWinControl(lThemeLabel.Parent.Parent);
    lUsedWidth := Max(
      TWinControl(lThemeCombo.Parent).Left + lThemeCombo.Left + lThemeCombo.Width,
      TWinControl(lImportThemeButton.Parent).Left + lImportThemeButton.Left +
        lImportThemeButton.Width);
    lTrailingGap := lThemeRow.ClientWidth - lUsedWidth;
    Check((lTrailingGap >= 0) and (lTrailingGap <= 16),
      Format('Theme row should not keep a large trailing gap (gap=%d)', [lTrailingGap]));
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogUsesGroupBoxes;
var
  lCaption: string;
  lDialog: TDSciVisualSettingsDialog;
  lGroupBox: TGroupBox;
const
  REQUIRED_GROUPS: array[0..12] of string = (
    'Style Options',
    'Editor',
    'Selection',
    'Search Highlight',
    'Smart Highlighting',
    'Search',
    'Line Wrapping',
    'Margins',
    'Caret',
    'Copy && Paste',
    'Code Folding',
    'Document',
    'Printing'
  );
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    for lCaption in REQUIRED_GROUPS do
    begin
      lGroupBox := FindGroupBoxByCaption(lDialog, lCaption);
      Check(lGroupBox <> nil,
        Format('Settings dialog should expose the "%s" group box', [lCaption]));
    end;
  finally
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogUsesStackPanelsInsideGroupBoxes;
var
  lCaption: string;
  lDialog: TDSciVisualSettingsDialog;
  lGroupBox: TGroupBox;
const
  STACK_GROUPS: array[0..8] of string = (
    'Style Options',
    'Editor',
    'Selection',
    'Search Highlight',
    'Smart Highlighting',
    'Line Wrapping',
    'Caret',
    'Copy && Paste',
    'Code Folding'
  );
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    SettleForm(lDialog, True);
    for lCaption in STACK_GROUPS do
    begin
      lGroupBox := FindGroupBoxByCaption(lDialog, lCaption);
      Check(lGroupBox <> nil, Format('%s group should exist', [lCaption]));
      Check(FindDescendantControl(lGroupBox, TStackPanel) <> nil,
        Format('%s should contain a TStackPanel layout container', [lCaption]));
    end;
  finally
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogUsesStandardComboBoxes;
var
  lComboBox: TComboBox;
  lComboCount: Integer;
  lDialog: TDSciVisualSettingsDialog;
  lIndex: Integer;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    lComboCount := 0;
    for lIndex := 0 to lDialog.ComponentCount - 1 do
      if lDialog.Components[lIndex] is TComboBox then
      begin
        lComboBox := TComboBox(lDialog.Components[lIndex]);
        Inc(lComboCount);
        Check(lComboBox.Style in [csDropDown, csDropDownList, csSimple],
          Format('Unexpected combo style %d at component index %d',
            [Ord(lComboBox.Style), lIndex]));
        Check(not (lComboBox.Style in [csOwnerDrawFixed, csOwnerDrawVariable]),
          Format('ComboBox at component index %d must use standard VCL painting', [lIndex]));
      end;

    Check(lComboCount > 0, 'Settings dialog should contain ComboBox controls');
  finally
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestSciConfGenBuildsConfigAndDefaultResourceSources;
var
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lRcFileName: string;
  lResFileName: string;
  lTempDir: string;
  lUnitSource: string;
  lUnitFileName: string;
  lXmlFileName: string;
begin
  lTempDir := CreateWritableTempDir;
  try
    lConfigFileName := TPath.Combine(lTempDir, 'generated.config.xml');
    lXmlFileName := TPath.Combine(lTempDir, 'GeneratedDefaultConfig.xml');
    lUnitFileName := TPath.Combine(lTempDir, 'GeneratedDefaultConfig.pas');
    lRcFileName := TPath.Combine(lTempDir, 'GeneratedDefaultConfig.rc');
    lResFileName := TPath.Combine(lTempDir, 'GeneratedDefaultConfig.res');

    GenerateSciConfGenArtifacts(ResolveSettingsDir,
      TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'),
      lConfigFileName, lXmlFileName, lUnitFileName, lRcFileName, lResFileName, '',
      'DSCI_TEST_DEFAULT_CONFIG', False);

    Check(FileExists(lConfigFileName), 'SciConfGen should emit the merged DScintilla.config.xml');
    Check(FileExists(lXmlFileName), 'SciConfGen should emit the default-config XML resource source');
    Check(FileExists(lUnitFileName), 'SciConfGen should emit the default-config resource unit');
    Check(FileExists(lRcFileName), 'SciConfGen should emit the resource script');
    Check(not FileExists(lResFileName),
      'Resource compilation should stay optional when GenerateSciConfGenArtifacts is called with ACompileResources=False');

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(lConfigFileName);
      CheckEquals('cpp', lConfig.ResolveLanguageByFileName('sample.cpp'));
      Check(lConfig.StyleOverrides.FindGroup('default') <> nil,
        'SciConfGen should preserve the default/global style group');
    finally
      lConfig.Free;
    end;

    lUnitSource := TFile.ReadAllText(lUnitFileName, TEncoding.UTF8);
    Check(Pos('DSCI_TEST_DEFAULT_CONFIG', lUnitSource) > 0,
      'Generated resource unit should embed the requested resource name');
    Check(Pos('{$R GeneratedDefaultConfig.res}', lUnitSource) > 0,
      'Generated resource unit should include the generated .res file');

    lUnitSource := TFile.ReadAllText(lRcFileName, TEncoding.UTF8);
    Check(Pos('DSCI_TEST_DEFAULT_CONFIG RCDATA "GeneratedDefaultConfig.xml"', lUnitSource) > 0,
      'Generated .rc file should bind the XML payload to the requested resource name');
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualConfigLoadFailureKeepsPreviousState;
var
  lConfig: TDSciVisualConfig;
  lFileName: string;
  lStyle: TDSciVisualStyleData;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  try
    lFileName := TPath.Combine(lTempDir, 'broken.config.xml');
    TFile.WriteAllText(lFileName,
      '<Config><Theme Name="Broken"><Styles><Style name="cpp"><WordStyles></Config>',
      TEncoding.UTF8);

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.ThemeName := 'Monokai';
      lConfig.HighlightColor := clRed;
      lConfig.HighlightAlpha := $44;
      lConfig.HighlightOutlineAlpha := $99;
      lConfig.SmartHighlightFillAlpha := $5A;
      lConfig.SmartHighlightOutlineAlpha := $7B;
      lConfig.SelectionAlpha := 123;
      lConfig.FileSizeLimit := 12345;
      lConfig.LineNumbering := False;
      lConfig.LineWrapping := False;
      lConfig.SearchSync := True;
      lConfig.TabWidth := 8;
      lStyle := lConfig.EnsureStyleOverride('cpp', 'DEFAULT', dvskLexer);
      lStyle.HasForeColor := True;
      lStyle.ForeColor := clLime;

      try
        lConfig.LoadFromFile(lFileName);
        Fail('Invalid XML must raise an exception');
      except
        on E: Exception do
          Check(E.Message <> '', 'Broken XML should preserve the parser error message');
      end;

      CheckEquals('Monokai', lConfig.ThemeName);
      CheckEquals(Integer(ColorToRGB(clRed)), Integer(ColorToRGB(lConfig.HighlightColor)));
      CheckEquals($44, lConfig.HighlightAlpha);
      CheckEquals($99, lConfig.HighlightOutlineAlpha);
      CheckEquals($5A, Integer(lConfig.SmartHighlightFillAlpha));
      CheckEquals($7B, Integer(lConfig.SmartHighlightOutlineAlpha));
      CheckEquals(123, lConfig.SelectionAlpha);
      CheckEquals(Int64(12345), lConfig.FileSizeLimit);
      Check(not lConfig.LineNumbering, 'Broken load must not reset line numbering');
      Check(not lConfig.LineWrapping, 'Broken load must not reset line wrapping');
      Check(lConfig.SearchSync, 'Broken load must not reset SearchSync');
      CheckEquals(8, lConfig.TabWidth);
      Check(lConfig.FindStyleOverride('cpp', 'DEFAULT', dvskLexer) <> nil,
        'Broken load must keep the previous style overrides');
    finally
      lConfig.Free;
    end;
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogHighlightLabelUsesSingleLine;
var
  lDialog: TDSciVisualSettingsDialog;
  lHighlightLabel: TLabel;
  lRequiredWidth: Integer;
begin
  lDialog := TDSciVisualSettingsDialog.Create(nil);
  try
    ActivateSettingsCategory(Self, lDialog, 'Selection && Highlighting');

    lHighlightLabel := FindVisibleLabelByCaption(lDialog, 'Highlight color');
    Check(lHighlightLabel <> nil, 'Settings dialog should expose the Highlight color label');
    Check(not lHighlightLabel.WordWrap,
      'Highlight color should stay on a single line');

    lRequiredWidth := MeasureSingleLineTextWidth(lHighlightLabel.Font,
      lHighlightLabel.Caption);
    Check(lHighlightLabel.Width >= lRequiredWidth,
      Format('Highlight color label should fit in one line (actual=%d, required=%d)',
        [lHighlightLabel.Width, lRequiredWidth]));
  finally
    lDialog.Hide;
    lDialog.Free;
  end;
end;

procedure TTestDSciVisualUi.TestVisualConfigSaveLoadRoundTrip;
var
  lConfig: TDSciVisualConfig;
  lKeywordStyle: TDSciVisualStyleData;
  lLoaded: TDSciVisualConfig;
  lFileName: string;
  lSavedStyle: TDSciVisualStyleData;
  lLoadedStyle: TDSciVisualStyleData;
  lLoadedGroup: TDSciVisualStyleGroup;
  lLoadedKeywordStyle: TDSciVisualStyleData;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  try
    lFileName := TPath.Combine(lTempDir, 'visual.config.xml');

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.ThemeName := 'Monokai';
      lConfig.HighlightColor := RGB($12, $34, $56);
      lConfig.HighlightAlpha := $44;
      lConfig.HighlightOutlineAlpha := $99;
      lConfig.SmartHighlightFillAlpha := $5A;
      lConfig.SmartHighlightOutlineAlpha := $7B;
      lConfig.SelectionAlpha := 123;
      lConfig.FileSizeLimit := $102030;
      lConfig.LineNumbering := False;
      lConfig.BookmarkMarginVisible := False;
      lConfig.FoldMarginVisible := False;
      lConfig.LineWrapping := False;
      lConfig.SearchSync := True;
      lConfig.TabWidth := 8;
      lConfig.LogEnabled := True;
      lConfig.LogLevel := 3;
      lConfig.LogOutput := 1;

      lSavedStyle := lConfig.EnsureStyleOverride('default', 'Default Style', dvskGlobal);
      lSavedStyle.HasForeColor := True;
      lSavedStyle.ForeColor := clRed;
      lSavedStyle.HasBackColor := True;
      lSavedStyle.BackColor := clBlue;
      lSavedStyle.FontName := 'Consolas';
      lSavedStyle.HasFontSize := True;
      lSavedStyle.FontSize := 11;

      lConfig.StyleOverrides.EnsureGroup('cpp').HasLexerID := True;
      lConfig.StyleOverrides.FindGroup('cpp').LexerID := 99;
      lKeywordStyle := lConfig.EnsureStyleOverride('cpp', 'INSTRUCTION WORD', dvskLexer);
      lKeywordStyle.HasStyleID := True;
      lKeywordStyle.StyleID := 5;
      lKeywordStyle.KeywordClass := 'instre1';
      lKeywordStyle.HasKeywordsID := True;
      lKeywordStyle.KeywordsID := 0;
      lKeywordStyle.KeywordsText := 'int return';

      lConfig.SaveToFile(lFileName);
      Check(FileExists(lFileName), 'Visual config XML must be written to disk');
    finally
      lConfig.Free;
    end;

    lLoaded := TDSciVisualConfig.Create;
    try
      lLoaded.LoadFromFile(lFileName);

      CheckEquals('Monokai', lLoaded.ThemeName);
      CheckEquals(Integer(RGB($12, $34, $56)), Integer(ColorToRGB(lLoaded.HighlightColor)));
      CheckEquals($44, lLoaded.HighlightAlpha);
      CheckEquals($99, lLoaded.HighlightOutlineAlpha);
      CheckEquals($5A, Integer(lLoaded.SmartHighlightFillAlpha));
      CheckEquals($7B, Integer(lLoaded.SmartHighlightOutlineAlpha));
      CheckEquals(123, lLoaded.SelectionAlpha);
      CheckEquals(Int64($102030), lLoaded.FileSizeLimit);
      Check(not lLoaded.LineNumbering, 'Line numbering should survive config round-trip');
      Check(not lLoaded.BookmarkMarginVisible,
        'Bookmark gutter visibility should survive config round-trip');
      Check(not lLoaded.FoldMarginVisible,
        'Fold gutter visibility should survive config round-trip');
      Check(not lLoaded.LineWrapping, 'Line wrapping should survive config round-trip');
      Check(lLoaded.SearchSync, 'SearchSync should survive config round-trip');
      CheckEquals(8, lLoaded.TabWidth);
      Check(lLoaded.LogEnabled, 'LogEnabled should survive config round-trip');
      CheckEquals(3, lLoaded.LogLevel);
      CheckEquals(1, lLoaded.LogOutput);

      lLoadedStyle := lLoaded.FindStyleOverride('default', 'Default Style', dvskGlobal);
      Check(lLoadedStyle <> nil, 'Saved style override must survive config round-trip');
      Check(lLoadedStyle.HasForeColor, 'Foreground override should survive config round-trip');
      CheckEquals(Integer(ColorToRGB(clRed)), Integer(ColorToRGB(lLoadedStyle.ForeColor)));
      Check(lLoadedStyle.HasBackColor, 'Background override should survive config round-trip');
      CheckEquals(Integer(ColorToRGB(clBlue)), Integer(ColorToRGB(lLoadedStyle.BackColor)));
      CheckEquals('Consolas', lLoadedStyle.FontName);
      Check(lLoadedStyle.HasFontSize, 'Font size override should survive config round-trip');
      CheckEquals(11, lLoadedStyle.FontSize);

      lLoadedGroup := lLoaded.StyleOverrides.FindGroup('cpp');
      Check(lLoadedGroup <> nil, 'Config round-trip should preserve lexer groups');
      Check(lLoadedGroup.HasLexerID, 'Lexer id should survive config round-trip');
      CheckEquals(99, lLoadedGroup.LexerID);

      lLoadedKeywordStyle := lLoaded.FindStyleOverride('cpp', 'INSTRUCTION WORD', dvskLexer);
      Check(lLoadedKeywordStyle <> nil, 'Keyword style should survive config round-trip');
      Check(lLoadedKeywordStyle.HasKeywordsID, 'Keyword id should survive config round-trip');
      CheckEquals(0, lLoadedKeywordStyle.KeywordsID);
      CheckEquals('instre1', lLoadedKeywordStyle.KeywordClass);
      CheckEquals('int return', lLoadedKeywordStyle.KeywordsText);
    finally
      lLoaded.Free;
    end;
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogBootstrapsFromConfigWithoutLegacyCatalog;
var
  lAutoClose: TAutoCloseDialog;
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lDialog: TDSciVisualSettingsDialog;
  lLanguageCombo: TComboBox;
  lLanguageLabel: TLabel;
  lMissingSettingsDir: string;
  lStyleCombo: TComboBox;
  lStyleLabel: TLabel;
  lTempDir: string;
  lThemeCombo: TComboBox;
  lThemeLabel: TLabel;
begin
  lTempDir := CreateWritableTempDir;
  try
    lMissingSettingsDir := TPath.Combine(lTempDir, 'missing-settings');
    lConfigFileName := TPath.Combine(lTempDir, 'config-only.visual.settings.xml');
    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
      lConfig.ThemeName := 'Config Only Theme';

      lDialog := TDSciVisualSettingsDialog.Create(nil);
      lAutoClose := TAutoCloseDialog.Create;
      try
        lAutoClose.Attach(lDialog);
        Check(not lDialog.EditSettings(lMissingSettingsDir, lConfigFileName, lConfig),
          'Auto-close harness should dismiss the dialog with Cancel');
        SettleForm(lDialog);

        lThemeLabel := FindLabelByCaption(lDialog, 'Theme');
        lLanguageLabel := FindLabelByCaption(lDialog, 'Language');
        lStyleLabel := FindLabelByCaption(lDialog, 'Style');
        lThemeCombo := FindFieldForLabel(lThemeLabel, TComboBox) as TComboBox;
        lLanguageCombo := FindFieldForLabel(lLanguageLabel, TComboBox) as TComboBox;
        lStyleCombo := FindFieldForLabel(lStyleLabel, TComboBox) as TComboBox;

        Check(lThemeCombo <> nil, 'Settings dialog should still create the theme selector');
        Check(lLanguageCombo <> nil, 'Settings dialog should still create the language selector');
        Check(lStyleCombo <> nil, 'Settings dialog should still create the style selector');
        Check(not lThemeCombo.Enabled,
          'Theme selector should become read-only when legacy catalog files are missing');
        CheckEquals('Config Only Theme', lThemeCombo.Text);
        Check(lLanguageCombo.Items.IndexOf('cpp') >= 0,
          'Config-only dialog should populate language names from the loaded config');
        Check(lStyleCombo.Items.Count > 0,
          'Config-only dialog should populate styles without stylers.model.xml');
      finally
        lAutoClose.Free;
        lDialog.Free;
      end;
    finally
      lConfig.Free;
    end;
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogLoadsThemesFromConfigDirectoryAndAppliesSelection;
var
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lDefaultStyle: TDSciVisualStyleData;
  lDialog: TDSciVisualSettingsDialog;
  lDefaultThemeGroup: TDSciVisualStyleGroup;
  lImportThemeButton: TButton;
  lTempDir: string;
  lThemeCombo: TComboBox;
  lThemeLabel: TLabel;
  lThemeModel: TDSciVisualStyleModel;
  lThemeSelection: TThemeSelectionDialog;
  lThemeStyle: TDSciVisualStyleData;
  lThemesDirectory: string;
begin
  lTempDir := CreateWritableTempDir;
  try
    lConfigFileName := TPath.Combine(lTempDir, 'user.visual.settings.xml');
    lThemesDirectory := TPath.Combine(lTempDir, 'themes');
    ForceDirectories(lThemesDirectory);
    TFile.Copy(TPath.Combine(ResolveSettingsDir, 'themes\Bespin.xml'),
      TPath.Combine(lThemesDirectory, 'Bespin.xml'), True);

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
      lConfig.ThemeName := '';

      lDialog := TDSciVisualSettingsDialog.Create(nil);
      lThemeSelection := TThemeSelectionDialog.Create;
      try
        lThemeSelection.Attach(lDialog, 'Bespin');
        Check(lDialog.EditSettings('', lConfigFileName, lConfig),
          'Theme selection harness should accept the dialog');
        SettleForm(lDialog);

        lThemeLabel := FindLabelByCaption(lDialog, 'Theme');
        lThemeCombo := FindFieldForLabel(lThemeLabel, TComboBox) as TComboBox;
        lImportThemeButton := FindButtonByCaption(lDialog, 'Import...');
        Check(lThemeCombo <> nil, 'Settings dialog should expose the theme selector');
        Check(lImportThemeButton <> nil,
          'Settings dialog should expose the Import theme button next to the selector');
        Check(lThemeCombo.Enabled,
          'Theme selector should enable when themes live next to the config file');
        Check(lThemeCombo.Items.IndexOf('Bespin') >= 0,
          'Theme selector should list themes found in the config-adjacent themes folder');
        CheckEquals('Bespin', lConfig.ThemeName);

        lThemeModel := LoadThemeStyleModelFromFile(TPath.Combine(lThemesDirectory, 'Bespin.xml'));
        try
          lDefaultThemeGroup := lThemeModel.FindGroup('default');
          Check(lDefaultThemeGroup <> nil, 'Theme file should expose the default style group');
          lThemeStyle := lDefaultThemeGroup.FindStyle('Default Style', dvskGlobal);
          lDefaultStyle := lConfig.FindStyleOverride('default', 'Default Style', dvskGlobal);
          Check(lThemeStyle <> nil, 'Theme file should expose the default global style');
          Check(lDefaultStyle <> nil, 'Applied config should expose the default global style');
          Check(lDefaultStyle.HasForeColor, 'Applied theme should keep the global foreground');
          Check(lDefaultStyle.HasBackColor, 'Applied theme should keep the global background');
          CheckEquals(Integer(ColorToRGB(lThemeStyle.ForeColor)),
            Integer(ColorToRGB(lDefaultStyle.ForeColor)));
          CheckEquals(Integer(ColorToRGB(lThemeStyle.BackColor)),
            Integer(ColorToRGB(lDefaultStyle.BackColor)));
          CheckEquals(lThemeStyle.FontName, lDefaultStyle.FontName);
        finally
          lThemeModel.Free;
        end;
      finally
        lThemeSelection.Free;
        lDialog.Free;
      end;
    finally
      lConfig.Free;
    end;
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogImportThemeCopiesThemeIntoConfigThemesDirectory;
var
  lAutoClose: TAutoCloseDialog;
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lDialog: TDSciVisualSettingsDialog;
  lImportedThemeName: string;
  lSourceThemeFileName: string;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  try
    lConfigFileName := TPath.Combine(lTempDir, 'user.visual.settings.xml');
    lSourceThemeFileName := TPath.Combine(lTempDir, 'IncomingBespin.xml');
    TFile.Copy(TPath.Combine(ResolveSettingsDir, 'themes\Bespin.xml'),
      lSourceThemeFileName, True);

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));

      lDialog := TDSciVisualSettingsDialog.Create(nil);
      lAutoClose := TAutoCloseDialog.Create;
      try
        lAutoClose.Attach(lDialog);
        Check(not lDialog.EditSettings('', lConfigFileName, lConfig),
          'Auto-close harness should dismiss the dialog with Cancel');

        lImportedThemeName := lDialog.ImportThemeFile(lSourceThemeFileName, True);
        CheckEquals('IncomingBespin', lImportedThemeName);
        Check(FileExists(TPath.Combine(lTempDir, 'themes', 'IncomingBespin.xml')),
          'ImportThemeFile should copy the theme into the config-adjacent themes directory');
      finally
        lAutoClose.Free;
        lDialog.Free;
      end;
    finally
      lConfig.Free;
    end;
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormCreatesCustomNamedConfigFile;
var
  lConfig: TDSciVisualConfig;
  lCustomConfigFile: string;
  lForm: TDSciVisualTestForm;
  lOldConfigFile: string;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  lOldConfigFile := GetEnvironmentVariable('DSCI_CONFIG_FILE');
  try
    lCustomConfigFile := TPath.Combine(lTempDir, 'user-defined.visual.settings.xml');
    SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lCustomConfigFile));

    lForm := TDSciVisualTestForm.Create(nil);
    try
      Check(FileExists(lCustomConfigFile),
        'Visual form should create the missing config file at the user-provided name');

      lConfig := TDSciVisualConfig.Create;
      try
        lConfig.LoadFromFile(lCustomConfigFile);
        CheckEquals(Int64(512 * 1024 * 1024), lConfig.FileSizeLimit);
        CheckEquals(4, lConfig.TabWidth);
        Check(not lConfig.SearchSync, 'Default SearchSync should come from the bundled config');
      finally
        lConfig.Free;
      end;
    finally
      lForm.Free;
    end;
  finally
    if lOldConfigFile <> '' then
      SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lOldConfigFile))
    else
      SetEnvironmentVariable('DSCI_CONFIG_FILE', nil);
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormLoadsConfigWithoutSettingsDirectory;
var
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lCppFileName: string;
  lEditor: TDScintilla;
  lForm: TDSciVisualTestForm;
  lOldConfigFile: string;
  lOldSettingsDir: string;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  lOldConfigFile := GetEnvironmentVariable('DSCI_CONFIG_FILE');
  lOldSettingsDir := GetEnvironmentVariable('DSCI_SETTINGS_DIR');
  try
    lConfigFileName := TPath.Combine(lTempDir, 'config-only.visual.settings.xml');
    lCppFileName := TPath.Combine(lTempDir, 'sample.cpp');

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
      lConfig.TabWidth := 7;
      lConfig.LineWrapping := False;
      lConfig.SaveToFile(lConfigFileName);
    finally
      lConfig.Free;
    end;

    TFile.WriteAllText(lCppFileName, 'int main() { return 0; }', TEncoding.UTF8);
    SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lConfigFileName));
    SetEnvironmentVariable('DSCI_SETTINGS_DIR',
      PChar(TPath.Combine(lTempDir, 'missing-settings')));

    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      lEditor := TDScintilla(FindOwnedComponent(lForm, TDScintilla));
      Check(lEditor <> nil, 'Visual form should own a TDScintilla editor');
      CheckEquals(7, lEditor.TabWidth);
      CheckEquals(0, Ord(lEditor.WrapMode));

      Check(lForm.OpenFile(lCppFileName),
        'Visual form should still open files when only a config file is available');
      CheckEquals('cpp', lEditor.Settings.CurrentLanguage);
      CheckEquals(16, lEditor.StyleAt[0],
        'Config-only startup should still activate lexer styling for known extensions');
    finally
      lForm.Hide;
      lForm.Free;
    end;
  finally
    if lOldConfigFile <> '' then
      SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lOldConfigFile))
    else
      SetEnvironmentVariable('DSCI_CONFIG_FILE', nil);
    if lOldSettingsDir <> '' then
      SetEnvironmentVariable('DSCI_SETTINGS_DIR', PChar(lOldSettingsDir))
    else
      SetEnvironmentVariable('DSCI_SETTINGS_DIR', nil);
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormUsesTaskbarWindowStyles;
var
  lExStyle: NativeInt;
  lForm: TDSciVisualTestForm;
begin
  lForm := TDSciVisualTestForm.Create(nil);
  try
    lForm.HandleNeeded;
    lExStyle := GetWindowLongPtr(lForm.Handle, GWL_EXSTYLE);
    Check((lExStyle and WS_EX_TOOLWINDOW) = 0,
      'Visual form should not use the tool-window style because it hides the app from the taskbar');
    Check((lExStyle and WS_EX_APPWINDOW) <> 0,
      'Visual form should request an application window style so the shell can surface it on the taskbar');
  finally
    lForm.Hide;
    lForm.Free;
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormAppliesConfiguredGutters;
var
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lEditor: TDScintilla;
  lForm: TDSciVisualTestForm;
  lOldConfigFile: string;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  lOldConfigFile := GetEnvironmentVariable('DSCI_CONFIG_FILE');
  try
    lConfigFileName := TPath.Combine(lTempDir, 'gutters.config.xml');
    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
      lConfig.LineNumbering := False;
      lConfig.BookmarkMarginVisible := False;
      lConfig.FoldMarginVisible := False;
      lConfig.EnsureStyleOverride('default', 'Bookmark margin', dvskGlobal).HasBackColor := True;
      lConfig.FindStyleOverride('default', 'Bookmark margin', dvskGlobal).BackColor := RGB($22, $44, $66);
      lConfig.SaveToFile(lConfigFileName);
    finally
      lConfig.Free;
    end;

    SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lConfigFileName));
    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      lEditor := TDScintilla(FindOwnedComponent(lForm, TDScintilla));
      Check(lEditor <> nil, 'Visual form should own a TDScintilla editor');
      CheckEquals(0, lEditor.MarginWidthN[0], 'Config should hide the line-number gutter');
      CheckEquals(0, lEditor.MarginWidthN[1], 'Config should hide the line-number pad spacer');
      CheckEquals(0, lEditor.MarginWidthN[2], 'Config should hide the bookmark gutter');
      CheckEquals(0, lEditor.MarginWidthN[3], 'Config should hide the fold gutter');
      CheckEquals(Integer(ColorToRGB(RGB($22, $44, $66))),
        Integer(ColorToRGB(lEditor.MarginBackN[2])),
        'Bookmark gutter background should come from the config style override');
    finally
      lForm.Hide;
      lForm.Free;
    end;
  finally
    if lOldConfigFile <> '' then
      SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lOldConfigFile))
    else
      SetEnvironmentVariable('DSCI_CONFIG_FILE', nil);
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormAppliesLineNumberPadding;
const
  cPadLeft = 20;
  cPadRight = 30;
  cFixedDigits = 6;
var
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lEditor: TDScintilla;
  lExpected: Integer;
  lForm: TDSciVisualTestForm;
  lOldConfigFile: string;
  lTextWidth: Integer;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  lOldConfigFile := GetEnvironmentVariable('DSCI_CONFIG_FILE');
  try
    lConfigFileName := TPath.Combine(lTempDir, 'padding.config.xml');
    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
      lConfig.LineNumbering := True;
      lConfig.LineNumberWidthMode := lnwmFixed;
      lConfig.LineNumberPaddingLeft := cPadLeft;
      lConfig.LineNumberPaddingRight := cPadRight;
      lConfig.SaveToFile(lConfigFileName);
    finally
      lConfig.Free;
    end;

    SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lConfigFileName));
    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      lEditor := TDScintilla(FindOwnedComponent(lForm, TDScintilla));
      Check(lEditor <> nil, 'Visual form should own a TDScintilla editor');

      lTextWidth := lEditor.TextWidth(STYLE_LINENUMBER,
        StringOfChar('9', cFixedDigits));
      Check(lTextWidth > 0,
        'TextWidth for line-number style should return a positive value');
      lExpected := cPadLeft + lTextWidth;
      CheckEquals(lExpected, lEditor.MarginWidthN[0],
        Format('Line-number margin should be padLeft + textWidth (%d + %d = %d)',
          [cPadLeft, lTextWidth, lExpected]));
      CheckEquals(cPadRight, lEditor.MarginWidthN[1],
        Format('Line-number pad spacer should equal padRight (%d)', [cPadRight]));
    finally
      lForm.Hide;
      lForm.Free;
    end;
  finally
    if lOldConfigFile <> '' then
      SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lOldConfigFile))
    else
      SetEnvironmentVariable('DSCI_CONFIG_FILE', nil);
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormXmlFoldingTogglesOnOpen;
var
  lEditor: TDScintilla;
  lFileName: string;
  lForm: TDSciVisualTestForm;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  try
    lFileName := TPath.Combine(lTempDir, 'folding-open.xml');
    TFile.WriteAllText(lFileName,
      '<root>' + sLineBreak +
      '  <section>' + sLineBreak +
      '    <item>value</item>' + sLineBreak +
      '  </section>' + sLineBreak +
      '</root>',
      TEncoding.UTF8);

    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      Check(lForm.OpenFile(lFileName), 'Visual form should open the XML sample');
      SettleForm(lForm, True);

      lEditor := TDScintilla(FindOwnedComponent(lForm, TDScintilla));
      Check(lEditor <> nil, 'Visual form should own a TDScintilla editor');
      CheckEquals('xml', lEditor.Settings.CurrentLanguage,
        'XML sample should activate the XML lexer on open');
      AssertEditorCanToggleFirstFold(Self, lEditor, 'XML folding on open');
    finally
      lForm.Hide;
      lForm.Free;
    end;
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormUnknownExtensionFallsBackToPlainLexer;
var
  lEditor: TDScintilla;
  lFileName: string;
  lForm: TDSciVisualTestForm;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  try
    lFileName := TPath.Combine(lTempDir, 'book.fb2');
    TFile.WriteAllText(lFileName,
      '<FictionBook>' + sLineBreak +
      '  <body>fallback</body>' + sLineBreak +
      '</FictionBook>',
      TEncoding.UTF8);

    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      Check(lForm.OpenFile(lFileName),
        'Visual form should open files with unknown extensions instead of failing');
      SettleForm(lForm, True);

      lEditor := TDScintilla(FindOwnedComponent(lForm, TDScintilla));
      Check(lEditor <> nil, 'Visual form should own a TDScintilla editor');
      CheckEquals('', lEditor.Settings.CurrentLanguage,
        'Unknown extensions should silently fall back to the default/plain lexer');
      CheckEquals('', lEditor.LexerLanguage,
        'Unknown extensions should leave the editor on the default/plain lexer');
      Check(lEditor.TextLength > 0,
        'Unknown-extension fallback should still load the document text');
    finally
      lForm.Hide;
      lForm.Free;
    end;
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormNfoKeepsPlainLexerButRetainsLanguageGroup;
var
  lEditor: TDScintilla;
  lFileName: string;
  lForm: TDSciVisualTestForm;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  try
    lFileName := TPath.Combine(lTempDir, 'sample.nfo');
    TFile.WriteAllText(lFileName,
      'ANSI ART' + sLineBreak +
      'SCLEX_NULL should still keep the nfo style group active.',
      TEncoding.UTF8);

    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      Check(lForm.OpenFile(lFileName),
        'Visual form should open .nfo files without treating them as unknown extensions');
      SettleForm(lForm, True);

      lEditor := TDScintilla(FindOwnedComponent(lForm, TDScintilla));
      Check(lEditor <> nil, 'Visual form should own a TDScintilla editor');
      CheckEquals('nfo', lEditor.Settings.CurrentLanguage,
        'Style-only .nfo files should retain their configured language group');
      CheckEquals(Integer(sclNULL), Integer(lEditor.Lexer),
        '.nfo files should stay on the plain/null Scintilla lexer');
      CheckEquals('', lEditor.LexerLanguage,
        'Style-only .nfo files should not advertise a missing Lexilla lexer name');
      Check(lEditor.TextLength > 0,
        'Style-only .nfo handling should still load the document text');
    finally
      lForm.Hide;
      lForm.Free;
    end;
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormActionscriptUsesCppRuntimeLexerOnFirstSelection;
var
  lABucketItem: TMenuItem;
  lActionScriptItem: TMenuItem;
  lEditor: TDSciVisualEditor;
  lForm: TDSciVisualTestForm;
  lLexerPanelIndex: Integer;
  lPopup: TPopupMenu;
  lStatusBar: TStatusBar;
begin
  lForm := TDSciVisualTestForm.Create(nil);
  try
    SettleForm(lForm, True);
    lEditor := TDSciVisualEditor(FindOwnedComponent(lForm, TDScintilla));
    lPopup := FindOwnedComponentByName(lEditor, 'StatusLexerPopupMenu') as TPopupMenu;
    lStatusBar := lEditor.StatusBar;

    Check(lEditor <> nil, 'Visual form should own a TDSciVisualEditor');
    if lEditor = nil then
      Exit;
    Check(lPopup <> nil, 'TDScintilla should create the lexer popup menu');
    if lPopup = nil then
      Exit;
    Check(lStatusBar <> nil, 'TDScintilla should create a managed status bar');
    if lStatusBar = nil then
      Exit;

    lLexerPanelIndex := FindStatusBarPanelIndex(lStatusBar, 'Lexer: ');
    Check(lLexerPanelIndex >= 0,
      'Managed status bar should expose a lexer panel');
    if lLexerPanelIndex < 0 then
      Exit;

    lABucketItem := FindChildMenuItemByCaption(lPopup.Items, 'A');
    Check(lABucketItem <> nil,
      'Lexer popup should group ActionScript inside the A bucket');
    if lABucketItem = nil then
      Exit;

    lActionScriptItem := FindChildMenuItemByCaption(lABucketItem, 'actionscript');
    Check(lActionScriptItem <> nil,
      'Lexer popup should expose the ActionScript visual language entry');
    if lActionScriptItem = nil then
      Exit;

    lActionScriptItem.Click;
    Application.ProcessMessages;
    SettleForm(lForm, True);

    CheckEquals('actionscript', lEditor.Settings.CurrentLanguage,
      'Manual ActionScript selection should preserve the requested visual language');
    CheckEquals(Integer(sclCPP), Integer(lEditor.Lexer),
      'ActionScript should activate the shared C/C++ Scintilla lexer on first selection');
    CheckEquals('cpp', LowerCase(lEditor.LexerLanguage),
      'Manual ActionScript selection should resolve to the cpp runtime lexer name');
    Check(Pos('actionscript', LowerCase(lStatusBar.Panels[lLexerPanelIndex].Text)) > 0,
      'Status bar should keep showing the requested ActionScript language instead of the shared runtime lexer name');
  finally
    lForm.Hide;
    lForm.Free;
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormHtmlFileFallsBackWhenHtmlLexerIsUnavailable;
var
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lEditor: TDScintilla;
  lFileName: string;
  lForm: TDSciVisualTestForm;
  lHtmlGroup: TDSciVisualStyleGroup;
  lMissingGroup: TDSciVisualStyleGroup;
  lOldConfigFile: string;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  lOldConfigFile := GetEnvironmentVariable('DSCI_CONFIG_FILE');
  try
    lConfigFileName := TPath.Combine(lTempDir, 'missing-html-lexer.visual.config.xml');
    lFileName := TPath.Combine(lTempDir, 'fallback.html');

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
      lHtmlGroup := lConfig.StyleOverrides.FindGroup('html');
      if lHtmlGroup <> nil then
        lHtmlGroup.Extensions := '.html-disabled';

      lMissingGroup := lConfig.StyleOverrides.EnsureGroup('html_missing_test');
      lMissingGroup.Extensions := '.html';
      lConfig.SaveToFile(lConfigFileName);
    finally
      lConfig.Free;
    end;

    TFile.WriteAllText(lFileName,
      '<html>' + sLineBreak +
      '  <body>fallback</body>' + sLineBreak +
      '</html>',
      TEncoding.UTF8);
    SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lConfigFileName));

    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      Check(lForm.OpenFile(lFileName),
        'Visual form should still open HTML files when the configured HTML lexer is unavailable');
      SettleForm(lForm, True);

      lEditor := TDScintilla(FindOwnedComponent(lForm, TDScintilla));
      Check(lEditor <> nil, 'Visual form should own a TDScintilla editor');
      CheckEquals('', lEditor.Settings.CurrentLanguage,
        'Unavailable HTML lexer should fall back to the default/plain lexer in the visual host');
      CheckEquals('', lEditor.LexerLanguage,
        'Fallback HTML open should leave the editor on the default/plain lexer');
      Check(lEditor.TextLength > 0,
        'Fallback HTML open should still load the document text into the editor');
    finally
      lForm.Hide;
      lForm.Free;
    end;
  finally
    if lOldConfigFile <> '' then
      SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lOldConfigFile))
    else
      SetEnvironmentVariable('DSCI_CONFIG_FILE', nil);
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormGroupsLexerPopupByFirstLetter;
var
  lBucketItem: TMenuItem;
  lCppItem: TMenuItem;
  lEditor: TDSciVisualEditor;
  lForm: TDSciVisualTestForm;
  lLexerPanelIndex: Integer;
  lPopup: TPopupMenu;
  lStatusBar: TStatusBar;
begin
  lForm := TDSciVisualTestForm.Create(nil);
  try
    SettleForm(lForm, True);
    lEditor := TDSciVisualEditor(FindOwnedComponent(lForm, TDScintilla));
    Check(lEditor <> nil, 'Visual form should own a TDSciVisualEditor');
    if lEditor = nil then
      Exit;

    lPopup := FindOwnedComponentByName(lEditor, 'StatusLexerPopupMenu') as TPopupMenu;
    lStatusBar := lEditor.StatusBar;
    Check(lPopup <> nil, 'Visual form should create the lexer popup menu');
    if lPopup = nil then
      Exit;
    Check(lPopup.Owner = lEditor,
      'Status popup menus should be owned by the editor to avoid teardown-order issues');
    Check(lStatusBar <> nil, 'TDScintilla should create a managed status bar');
    if lStatusBar = nil then
      Exit;
    Check(lPopup.Items.Count > 3,
      'Lexer popup should contain service items plus grouped syntax buckets');
    lLexerPanelIndex := FindStatusBarPanelIndex(lStatusBar, 'Lexer: ');
    Check(lLexerPanelIndex >= 0,
      'Managed status bar should expose a lexer panel');
    if lLexerPanelIndex < 0 then
      Exit;

    lBucketItem := FindChildMenuItemByCaption(lPopup.Items, 'C');
    Check(lBucketItem <> nil,
      'Lexer popup should group syntaxes into submenus by their first letter');
    if lBucketItem = nil then
      Exit;
    Check(lBucketItem.Count > 0,
      'Letter bucket should contain concrete syntax menu items');

    lCppItem := FindChildMenuItemByCaption(lBucketItem, 'cpp');
    Check(lCppItem <> nil, 'cpp should live inside the C bucket submenu');
    if lCppItem = nil then
      Exit;

    lCppItem.Click;
    Check(Pos('cpp', LowerCase(lStatusBar.Panels[lLexerPanelIndex].Text)) > 0,
      'Choosing a grouped syntax item should still apply the manual lexer override');
  finally
    lForm.Hide;
    lForm.Free;
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormShowStatusBarFollowsConfigVisibility;
var
  lOldConfigFile: string;
  lTempDir: string;

  procedure CheckStatusBarVisibility(AVisible: Boolean; const AConfigFileName: string);
  var
    lConfig: TDSciVisualConfig;
    lEditor: TDSciVisualEditor;
    lForm: TDSciVisualTestForm;
    lPositionPanelIndex: Integer;
    lStatusBar: TStatusBar;
    lVisibleText: string;
  begin
    if AVisible then
      lVisibleText := 'True'
    else
      lVisibleText := 'False';

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
      lConfig.ShowStatusBar := AVisible;
      lConfig.SaveToFile(AConfigFileName);
    finally
      lConfig.Free;
    end;

    SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(AConfigFileName));
    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      lEditor := TDSciVisualEditor(FindOwnedComponent(lForm, TDScintilla));
      Check(lEditor <> nil, 'Visual form should own a TDSciVisualEditor');
      if lEditor = nil then
        Exit;

      lStatusBar := lEditor.StatusBar;
      Check(lStatusBar <> nil, 'TDScintilla should create a managed status bar');
      if lStatusBar = nil then
        Exit;
      Check(lEditor.StatusBarVisible = AVisible,
        Format('StatusBarVisible should follow ShowStatusBar=%s.',
          [lVisibleText]));
      Check(lStatusBar.Visible = AVisible,
        Format('Managed status bar visibility should follow ShowStatusBar=%s.',
          [lVisibleText]));
      if AVisible then
      begin
        lPositionPanelIndex := FindStatusBarPanelIndex(lStatusBar, 'Ln ');
        Check(lPositionPanelIndex >= 0,
          'Managed status bar should initialize the position panel before the first UI update');
        if lPositionPanelIndex < 0 then
          Exit;
        CheckEquals('Ln 1, Col 1', lStatusBar.Panels[lPositionPanelIndex].Text,
          'Visible status bar should initialize the caret position text immediately');
      end;
    finally
      lForm.Hide;
      lForm.Free;
    end;
  end;

begin
  lTempDir := CreateWritableTempDir;
  lOldConfigFile := GetEnvironmentVariable('DSCI_CONFIG_FILE');
  try
    CheckStatusBarVisibility(False,
      TPath.Combine(lTempDir, 'statusbar-hidden.config.xml'));
    CheckStatusBarVisibility(True,
      TPath.Combine(lTempDir, 'statusbar-visible.config.xml'));
  finally
    if lOldConfigFile <> '' then
      SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lOldConfigFile))
    else
      SetEnvironmentVariable('DSCI_CONFIG_FILE', nil);
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormOpenFileUsesBackgroundDocumentLoader;
var
  lEditor: TDSciVisualEditor;
  lFileName: string;
  lForm: TDSciVisualTestForm;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  try
    lFileName := TPath.Combine(lTempDir, 'background-load.cpp');
    TFile.WriteAllText(lFileName, 'int main() {' + sLineBreak + '  return 42;' + sLineBreak + '}',
      TEncoding.UTF8);

    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      lEditor := TDSciVisualEditor(FindOwnedComponent(lForm, TDScintilla));
      Check(lEditor <> nil, 'Visual form should own a TDSciVisualEditor');
      CheckEquals(0, lEditor.BackgroundDocumentLoadCount,
        'Background loader counter should start at zero');

      Check(lForm.OpenFile(lFileName), 'OpenFile should load UTF-8 files through the background loader');
      CheckEquals(1, lEditor.BackgroundDocumentLoadCount,
        'OpenFile should switch documents through SCI_CREATELOADER');
      CheckEquals('int main() {' + sLineBreak + '  return 42;' + sLineBreak + '}',
        lEditor.GetText, 'Background document loading should preserve the decoded file text');
    finally
      lForm.Hide;
      lForm.Free;
    end;
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormPreferredEncodingSelectionAppliesToNextOpenModes;
var
  lAsyncFileName: string;
  lEncodingItem: TMenuItem;
  lEncodingPopup: TPopupMenu;
  lExpandedAsyncFileName: string;
  lExpandedSyncFileName: string;
  lEditor: TDSciVisualEditor;
  lForm: TDSciVisualTestForm;
  lReady: Boolean;
  lStartTick: Cardinal;
  lSyncFileName: string;
  lTempDir: string;
  lUtf8Bom: TEncoding;
begin
  lTempDir := CreateWritableTempDir;
  lUtf8Bom := TUTF8Encoding.Create(True);
  try
    lSyncFileName := TPath.Combine(lTempDir, 'preferred-sync.fb2');
    TFile.WriteAllText(lSyncFileName,
      '<FictionBook>' + sLineBreak +
      '  <body>sync</body>' + sLineBreak +
      '</FictionBook>',
      lUtf8Bom);
    lExpandedSyncFileName := ExpandFileName(lSyncFileName);

    lAsyncFileName := TPath.Combine(lTempDir, 'preferred-async.fb2');
    TFile.WriteAllText(lAsyncFileName,
      '<FictionBook>' + sLineBreak +
      '  <body>async</body>' + sLineBreak +
      '</FictionBook>',
      lUtf8Bom);
    lExpandedAsyncFileName := ExpandFileName(lAsyncFileName);

    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      lEditor := TDSciVisualEditor(FindOwnedComponent(lForm, TDScintilla));
      Check(lEditor <> nil, 'Visual form should own a TDSciVisualEditor');
      if lEditor = nil then
        Exit;

      lEncodingPopup := FindOwnedComponentByName(lEditor, 'StatusEncodingPopupMenu') as TPopupMenu;
      Check(lEncodingPopup <> nil, 'TDScintilla should create the encoding popup menu');
      if lEncodingPopup = nil then
        Exit;
      Check(lEncodingPopup.Owner = lEditor,
        'Encoding popup should be owned by the editor to avoid teardown-order issues');

      lEncodingItem := FindChildMenuItemByCaption(lEncodingPopup.Items, 'ANSI');
      Check(lEncodingItem <> nil,
        'Encoding popup should expose the ANSI item used for preferred-encoding checks');
      if lEncodingItem = nil then
        Exit;
      lEncodingItem.Click;
      Check(lEditor.PreferredFileEncoding = dsfeAnsi,
        'Selecting ANSI from the status bar should update PreferredFileEncoding');

      Check(lForm.OpenFile(lSyncFileName),
        'Parameterless OpenFile should still open the selected file');
      CheckEquals(1, lEditor.BackgroundDocumentLoadCount,
        'OpenFile should attach exactly one background-loaded document');
      CheckEquals(lExpandedSyncFileName, lEditor.CurrentFileName,
        'OpenFile should attach the requested document');
      CheckEquals(Integer(dsfeAnsi), Integer(lEditor.FileLoadStatus.Encoding),
        'Parameterless OpenFile should honor PreferredFileEncoding on the next open');

      Check(lForm.BeginOpenFile(lAsyncFileName),
        'Parameterless BeginOpenFile should start asynchronous loading');
      lReady := False;
      lStartTick := GetTickCount;
      while (GetTickCount - lStartTick < 10000) and not lReady do
      begin
        Application.ProcessMessages;
        lReady := (lEditor.FileLoadStatus.Stage = sflsCompleted) and
          SameText(lEditor.CurrentFileName, lExpandedAsyncFileName);
        Sleep(5);
      end;

      Check(lReady,
        'Async open should complete before preferred-encoding assertions run');
      CheckEquals(2, lEditor.BackgroundDocumentLoadCount,
        'BeginOpenFile should attach one additional background-loaded document');
      CheckEquals(Integer(dsfeAnsi), Integer(lEditor.FileLoadStatus.Encoding),
        'Parameterless BeginOpenFile should honor PreferredFileEncoding on the next open');
    finally
      lForm.Hide;
      lForm.Free;
    end;
  finally
    lUtf8Bom.Free;
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormEncodingSwitchReloadsCurrentFileSynchronously;
var
  lEncodingPanelIndex: Integer;
  lEditor: TDSciVisualEditor;
  lEncodingItem: TMenuItem;
  lEncodingPopup: TPopupMenu;
  lFileName: string;
  lForm: TDSciVisualTestForm;
  lReady: Boolean;
  lStartTick: Cardinal;
  lStatusBar: TStatusBar;
  lTempDir: string;
  lUtf8Bom: TEncoding;
begin
  lTempDir := CreateWritableTempDir;
  lUtf8Bom := TUTF8Encoding.Create(True);
  try
    lFileName := TPath.Combine(lTempDir, 'encoding-reload.fb2');
    TFile.WriteAllText(lFileName,
      '<FictionBook>' + sLineBreak +
      '  <body>reload</body>' + sLineBreak +
      '</FictionBook>',
      lUtf8Bom);

    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      lEditor := TDSciVisualEditor(FindOwnedComponent(lForm, TDScintilla));
      Check(lEditor <> nil, 'Visual form should own a TDSciVisualEditor');
      if lEditor = nil then
        Exit;

      lEncodingPopup := FindOwnedComponentByName(lEditor, 'StatusEncodingPopupMenu') as TPopupMenu;
      lStatusBar := lEditor.StatusBar;
      Check(lEncodingPopup <> nil, 'TDScintilla should expose the encoding popup menu');
      if lEncodingPopup = nil then
        Exit;
      Check(lEncodingPopup.Owner = lEditor,
        'Encoding popup should be owned by the editor to avoid teardown-order issues');
      Check(lStatusBar <> nil, 'TDScintilla should expose a managed status bar');
      if lStatusBar = nil then
        Exit;
      lEncodingPanelIndex := FindStatusBarPanelIndex(lStatusBar, 'Encoding: ');
      Check(lEncodingPanelIndex >= 0,
        'Managed status bar should expose an encoding panel');
      if lEncodingPanelIndex < 0 then
        Exit;

      Check(lForm.BeginOpenFile(lFileName),
        'Visual form should start the initial open through the background loader');
      lReady := False;
      lStartTick := GetTickCount;
      while (GetTickCount - lStartTick < 10000) and not lReady do
      begin
        Application.ProcessMessages;
        lReady := lEditor.FileLoadStatus.Stage = sflsCompleted;
        Sleep(5);
      end;
      Check(lReady, 'Initial background load should complete before switching encoding');
      CheckEquals(1, lEditor.BackgroundDocumentLoadCount,
        'Initial open should attach one background-loaded document');

      lEncodingItem := FindChildMenuItemByCaption(lEncodingPopup.Items, 'UTF-8 with BOM');
      Check(lEncodingItem <> nil,
        'Encoding popup should expose the UTF-8 with BOM item used for reload checks');
      if lEncodingItem = nil then
        Exit;
      lEncodingItem.Click;
      lReady := False;
      lStartTick := GetTickCount;
      while (GetTickCount - lStartTick < 10000) and not lReady do
      begin
        Application.ProcessMessages;
        lReady := Pos('Encoding: UTF-8 with BOM',
          lStatusBar.Panels[lEncodingPanelIndex].Text) > 0;
        Sleep(5);
      end;
      SettleForm(lForm, True);

      CheckEquals(1, lEditor.BackgroundDocumentLoadCount,
        'Encoding switch should reload synchronously instead of attaching a second background document');
      CheckEquals('', lEditor.Settings.CurrentLanguage,
        'Unknown-extension files should stay on the default/plain lexer after encoding reload');
      Check(Pos('Encoding: UTF-8 with BOM',
        lStatusBar.Panels[lEncodingPanelIndex].Text) > 0,
        'Encoding switch should refresh the status bar text for the selected encoding');
      Check(lEditor.TextLength > 0,
        'Encoding switch should keep the document text available after reload');
      Check(Pos('reload', lEditor.GetText) > 0,
        'Encoding switch should preserve the decoded document text after synchronous reload');
    finally
      lForm.Hide;
      lForm.Free;
    end;
  finally
    lUtf8Bom.Free;
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormSettingsReapplyKeepsXmlFolding;
var
  lDialogResponder: TModalDialogResponder;
  lEditor: TDScintilla;
  lFileName: string;
  lForm: TDSciVisualTestForm;
  lSettingsItem: TMenuItem;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  try
    lFileName := TPath.Combine(lTempDir, 'folding-reapply.xml');
    TFile.WriteAllText(lFileName,
      '<root>' + sLineBreak +
      '  <section>' + sLineBreak +
      '    <item>value</item>' + sLineBreak +
      '  </section>' + sLineBreak +
      '</root>',
      TEncoding.UTF8);

    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      Check(lForm.OpenFile(lFileName), 'Visual form should open the XML sample');
      SettleForm(lForm, True);

      lEditor := TDScintilla(FindOwnedComponent(lForm, TDScintilla));
      lSettingsItem := FindMenuItemByCaption(lForm, '&Editor Settings...');
      Check(lEditor <> nil, 'Visual form should own a TDScintilla editor');
      Check(lSettingsItem <> nil, 'Visual form should expose the Editor Settings menu item');
      CheckEquals('xml', lEditor.Settings.CurrentLanguage,
        'XML sample should activate the XML lexer before settings reapply');
      AssertEditorCanToggleFirstFold(Self, lEditor, 'XML folding before settings reapply');

      lDialogResponder := TModalDialogResponder.Create;
      try
        lDialogResponder.Arm(TDSciVisualSettingsDialog, mrOk);
        lSettingsItem.Click;
        Check(lDialogResponder.Handled,
          'Settings menu should show the settings dialog so the reapply path runs');
      finally
        lDialogResponder.Free;
      end;
      SettleForm(lForm, True);

      AssertEditorCanToggleFirstFold(Self, lEditor, 'XML folding after settings reapply');
    finally
      lForm.Hide;
      lForm.Free;
    end;
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormBeginOpenFileShowsLoadingStatus;
var
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lCompleted: Boolean;
  lEditor: TDSciVisualEditor;
  lFileName: string;
  lForm: TDSciVisualTestForm;
  lLoadPanelIndex: Integer;
  lOldConfigFile: string;
  lStartedLoading: Boolean;
  lStatusBar: TStatusBar;
  lStartTick: Cardinal;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  lOldConfigFile := GetEnvironmentVariable('DSCI_CONFIG_FILE');
  try
    lConfigFileName := TPath.Combine(lTempDir, 'async-load.config.xml');
    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
      lConfig.FileSizeLimit := 8 * 1024 * 1024;
      lConfig.SaveToFile(lConfigFileName);
    finally
      lConfig.Free;
    end;
    SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lConfigFileName));

    lFileName := TPath.Combine(lTempDir, 'async-visual-load.cpp');
    TFile.WriteAllText(lFileName,
      StringOfChar('a', 2 * 1024 * 1024) + sLineBreak +
      StringOfChar('b', 2 * 1024 * 1024),
      TEncoding.UTF8);

    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      lEditor := TDSciVisualEditor(FindOwnedComponent(lForm, TDScintilla));
      Check(lEditor <> nil, 'Visual form should own a TDSciVisualEditor');
      if lEditor = nil then
        Exit;

      lStatusBar := lEditor.StatusBar;
      Check(lStatusBar <> nil, 'TDScintilla should expose a managed status bar');
      if lStatusBar = nil then
        Exit;
      lLoadPanelIndex := FindStatusBarPanelIndex(lStatusBar, 'Load: ');
      Check(lLoadPanelIndex >= 0,
        'Managed status bar should expose a load-status panel');
      if lLoadPanelIndex < 0 then
        Exit;

      Check(lForm.BeginOpenFile(lFileName),
        'BeginOpenFile should start asynchronous file loading');
      CheckEquals('Load: preparing', lStatusBar.Panels[lLoadPanelIndex].Text,
        'Visual status bar should reflect the preparing state immediately after BeginOpenFile');
      lStartedLoading := True;

      lCompleted := False;
      lStartTick := GetTickCount;
      while (GetTickCount - lStartTick < 10000) and not lCompleted do
      begin
        Application.ProcessMessages;
        lCompleted := SameText(lStatusBar.Panels[lLoadPanelIndex].Text, 'Load: ready');
        Sleep(5);
      end;

      Check(lStartedLoading,
        'Visual status bar should reflect that the file is being loaded');
      Check(lCompleted,
        'Visual status bar should return to a ready state after async loading');
      CheckEquals(1, lEditor.BackgroundDocumentLoadCount,
        'Async BeginOpenFile should still switch documents through SCI_CREATELOADER');
      Check(lEditor.TextLength > 0,
        'Async BeginOpenFile should populate the editor document');
    finally
      lForm.Hide;
      lForm.Free;
    end;
  finally
    if lOldConfigFile <> '' then
      SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lOldConfigFile))
    else
      SetEnvironmentVariable('DSCI_CONFIG_FILE', nil);
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormFileSizeLimitBlocksOversizedFiles;
var
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lDefaultConfigFile: string;
  lEditor: TDScintilla;
  lForm: TDSciVisualTestForm;
  lLargeFileName: string;
  lOldConfigFile: string;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  lOldConfigFile := GetEnvironmentVariable('DSCI_CONFIG_FILE');
  try
    lDefaultConfigFile := TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml');
    lConfigFileName := TPath.Combine(lTempDir, 'size-limited.config.xml');
    lLargeFileName := TPath.Combine(lTempDir, 'too-large.txt');

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(lDefaultConfigFile);
      lConfig.FileSizeLimit := 8;
      lConfig.SaveToFile(lConfigFileName);
    finally
      lConfig.Free;
    end;

    TFile.WriteAllText(lLargeFileName, 'This text is larger than the configured limit.', TEncoding.UTF8);
    SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lConfigFileName));

    lForm := TDSciVisualTestForm.Create(nil);
    try
      lEditor := TDScintilla(FindOwnedComponent(lForm, TDScintilla));
      Check(lEditor <> nil, 'Visual form should own a TDScintilla editor');
      Check(not lForm.OpenFile(lLargeFileName),
        'OpenFile should reject files that exceed the configured FileSizeLimit');
      CheckEquals('DScintilla Visual Test', lForm.Caption);
      CheckEquals(0, lEditor.TextLength);
    finally
      lForm.Free;
    end;
  finally
    if lOldConfigFile <> '' then
      SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lOldConfigFile))
    else
      SetEnvironmentVariable('DSCI_CONFIG_FILE', nil);
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormMarkAllBookmarksMarksMatchingLines;
var
  lConfigFileName: string;
  lEditor: TDScintilla;
  lFileName: string;
  lFindDialog: TDSciFindDialog;
  lFindDialogMenu: TMenuItem;
  lForm: TDSciVisualTestForm;
  lMarkAllButton: TButton;
  lOldConfigFile: string;
  lSearchConfig: TDSciSearchConfig;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  lOldConfigFile := GetEnvironmentVariable('DSCI_CONFIG_FILE');
  try
    lConfigFileName := TPath.Combine(lTempDir, 'bookmark-search.config.xml');
    lFileName := TPath.Combine(lTempDir, 'bookmark-search.txt');
    TFile.WriteAllText(lFileName,
      'Needle one'#13#10 +
      'Other line'#13#10 +
      'Needle two'#13#10 +
      'Needle Needle',
      TEncoding.UTF8);
    SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lConfigFileName));

    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      Check(lForm.OpenFile(lFileName), 'Visual form should load the file used for bookmark marking');

      lFindDialogMenu := FindMenuItemByCaption(lForm, 'Find &Dialog...');
      Check(lFindDialogMenu <> nil, 'Visual form should expose the Find dialog menu item');
      lFindDialogMenu.Click;
      Application.ProcessMessages;

      lFindDialog := TDSciFindDialog(FindOwnedComponent(lForm, TDSciFindDialog));
      Check(lFindDialog <> nil, 'Find dialog should be created before marking search results');

      lSearchConfig.Query := 'Needle';
      lSearchConfig.MatchCase := False;
      lSearchConfig.WholeWord := False;
      lSearchConfig.WrapAround := True;
      lSearchConfig.InSelection := False;
      lSearchConfig.SearchMode := dsmNormal;
      lFindDialog.ApplySearchConfig(lSearchConfig);

      lMarkAllButton := FindButtonByCaption(lFindDialog, 'Mark All');
      Check(lMarkAllButton <> nil, 'Find dialog should expose the Mark All button');
      lMarkAllButton.Click;
      Application.ProcessMessages;

      lEditor := TDScintilla(FindOwnedComponent(lForm, TDScintilla));
      Check(lEditor <> nil, 'Visual form should own a TDScintilla editor');
      Check(lEditor.MarkerGet(0) <> 0, 'First matching line should receive a bookmark');
      CheckEquals(0, lEditor.MarkerGet(1), 'Non-matching lines should not receive a bookmark');
      Check(lEditor.MarkerGet(2) <> 0, 'Later matching line should receive a bookmark');
      Check(lEditor.MarkerGet(3) <> 0, 'Multiple matches on one line should still mark that line');
    finally
      lForm.Hide;
      lForm.Free;
    end;
  finally
    if lOldConfigFile <> '' then
      SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lOldConfigFile))
    else
      SetEnvironmentVariable('DSCI_CONFIG_FILE', nil);
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestVisualFormSearchSyncMirrorsFindDialogToInlineSearch;
var
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lFindDialog: TDSciFindDialog;
  lFindDialogMenu: TMenuItem;
  lForm: TDSciVisualTestForm;
  lInlineFindMenu: TMenuItem;
  lMatchCase: TCheckBox;
  lOldConfigFile: string;
  lSearchConfig: TDSciSearchConfig;
  lSearchEdit: TEdit;
  lTempDir: string;
  lWholeWord: TCheckBox;
begin
  lTempDir := CreateWritableTempDir;
  lOldConfigFile := GetEnvironmentVariable('DSCI_CONFIG_FILE');
  try
    lConfigFileName := TPath.Combine(lTempDir, 'search-sync.config.xml');

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
      lConfig.SearchSync := True;
      lConfig.SaveToFile(lConfigFileName);
    finally
      lConfig.Free;
    end;

    SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lConfigFileName));
    lForm := TDSciVisualTestForm.Create(nil);
    try
      SettleForm(lForm, True);
      lFindDialogMenu := FindMenuItemByCaption(lForm, 'Find &Dialog...');
      lInlineFindMenu := FindMenuItemByCaption(lForm, '&Inline Find');
      Check(lFindDialogMenu <> nil, 'Visual form should expose the Find dialog menu item');
      Check(lInlineFindMenu <> nil, 'Visual form should expose the inline find menu item');

      lFindDialogMenu.Click;
      Application.ProcessMessages;
      lFindDialog := TDSciFindDialog(FindOwnedComponent(lForm, TDSciFindDialog));
      Check(lFindDialog <> nil, 'Find dialog should be created on demand');

      lSearchConfig.Query := 'Needle';
      lSearchConfig.MatchCase := True;
      lSearchConfig.WholeWord := True;
      lSearchConfig.WrapAround := True;
      lSearchConfig.InSelection := False;
      lSearchConfig.SearchMode := dsmNormal;
      lFindDialog.ApplySearchConfig(lSearchConfig);

      lInlineFindMenu.Click;
      Application.ProcessMessages;

      lSearchEdit := FindDescendantControl(lForm, TEdit) as TEdit;
      lMatchCase := FindCheckBoxByCaption(lForm, 'Match case');
      lWholeWord := FindCheckBoxByCaption(lForm, 'Whole words');
      Check(lSearchEdit <> nil, 'Inline find should expose a search edit');
      Check(lMatchCase <> nil, 'Inline find should expose Match case');
      Check(lWholeWord <> nil, 'Inline find should expose Whole words');
      CheckEquals('Needle', lSearchEdit.Text);
      Check(lMatchCase.Checked, 'SearchSync should mirror Match case from the Find dialog');
      Check(lWholeWord.Checked, 'SearchSync should mirror Whole word from the Find dialog');
    finally
      lForm.Hide;
      lForm.Free;
    end;
  finally
    if lOldConfigFile <> '' then
      SetEnvironmentVariable('DSCI_CONFIG_FILE', PChar(lOldConfigFile))
    else
      SetEnvironmentVariable('DSCI_CONFIG_FILE', nil);
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestLoggingConfigBackwardCompatFromToFile;
var
  lConfig: TDSciVisualConfig;
  lFileName: string;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  try
    lFileName := TPath.Combine(lTempDir, 'legacy.config.xml');
    TFile.WriteAllText(lFileName,
      '<?xml version="1.0"?>' +
      '<DScintillaVisualConfig>' +
      '<Logging ToFile="yes" Level="2"/>' +
      '</DScintillaVisualConfig>',
      TEncoding.UTF8);

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(lFileName);
      Check(lConfig.LogEnabled, 'Legacy ToFile=yes must set LogEnabled=True');
      CheckEquals(1, lConfig.LogOutput, 'Legacy ToFile=yes must set LogOutput to File (1)');
      CheckEquals(2, lConfig.LogLevel, 'Legacy Level=2 must set LogLevel to Info');
    finally
      lConfig.Free;
    end;
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestLoggerDefaultsAreDisabled;
var
  lSavedEnabled: Boolean;
  lSavedLevel: Integer;
  lSavedOutput: Integer;
begin
  lSavedEnabled := _DSciLogEnabled;
  lSavedLevel := _DSciLogLevel;
  lSavedOutput := _DSciLogOutput;
  try
    _DSciLogEnabled := False;
    _DSciLogLevel := cDSciLogError;
    _DSciLogOutput := cDSciOutputODS;
    Check(not _DSciLogEnabled, 'Logger must default to disabled');
    CheckEquals(cDSciLogError, _DSciLogLevel, 'Default level must be Error');
    CheckEquals(cDSciOutputODS, _DSciLogOutput, 'Default output must be ODS');
  finally
    _DSciLogEnabled := lSavedEnabled;
    _DSciLogLevel := lSavedLevel;
    _DSciLogOutput := lSavedOutput;
  end;
end;

procedure TTestDSciVisualUi.TestLoggerFileOutputWritesToDisk;
var
  lSavedEnabled: Boolean;
  lSavedLevel: Integer;
  lSavedOutput: Integer;
  lSavedPath: string;
  lTempDir: string;
  lLogFile: string;
  lContent: string;
begin
  lSavedEnabled := _DSciLogEnabled;
  lSavedLevel := _DSciLogLevel;
  lSavedOutput := _DSciLogOutput;
  lSavedPath := _DSciLogPath;
  lTempDir := TPath.Combine(TPath.GetTempPath, 'dsci_logger_test_' + IntToStr(GetTickCount));
  ForceDirectories(lTempDir);
  lLogFile := TPath.Combine(lTempDir, 'test_log.txt');
  try
    _DSciLogEnabled := True;
    _DSciLogLevel := cDSciLogDebug;
    _DSciLogOutput := cDSciOutputFile;
    _DSciLogPath := lLogFile;

    DSciLog('TestFileOutputLine1', cDSciLogError);
    DSciLog('TestFileOutputLine2', cDSciLogInfo);

    Check(FileExists(lLogFile), 'Log file must be created');
    lContent := TFile.ReadAllText(lLogFile);
    Check(Pos('TestFileOutputLine1', lContent) > 0,
      'Log file must contain first message');
    Check(Pos('TestFileOutputLine2', lContent) > 0,
      'Log file must contain second message');
  finally
    _DSciLogEnabled := lSavedEnabled;
    _DSciLogLevel := lSavedLevel;
    _DSciLogOutput := lSavedOutput;
    _DSciLogPath := lSavedPath;
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestLoggerLevelFiltersMessages;
var
  lSavedEnabled: Boolean;
  lSavedLevel: Integer;
  lSavedOutput: Integer;
  lSavedPath: string;
  lTempDir: string;
  lLogFile: string;
  lContent: string;
begin
  lSavedEnabled := _DSciLogEnabled;
  lSavedLevel := _DSciLogLevel;
  lSavedOutput := _DSciLogOutput;
  lSavedPath := _DSciLogPath;
  lTempDir := TPath.Combine(TPath.GetTempPath, 'dsci_logger_lvl_' + IntToStr(GetTickCount));
  ForceDirectories(lTempDir);
  lLogFile := TPath.Combine(lTempDir, 'level_test.txt');
  try
    _DSciLogEnabled := True;
    _DSciLogLevel := cDSciLogError;
    _DSciLogOutput := cDSciOutputFile;
    _DSciLogPath := lLogFile;

    DSciLog('ErrorMsg', cDSciLogError);
    DSciLog('InfoMsg', cDSciLogInfo);
    DSciLog('DebugMsg', cDSciLogDebug);

    Check(FileExists(lLogFile), 'Log file must be created for error level');
    lContent := TFile.ReadAllText(lLogFile);
    Check(Pos('ErrorMsg', lContent) > 0,
      'Error message must pass Error-level filter');
    Check(Pos('InfoMsg', lContent) = 0,
      'Info message must be filtered at Error level');
    Check(Pos('DebugMsg', lContent) = 0,
      'Debug message must be filtered at Error level');
  finally
    _DSciLogEnabled := lSavedEnabled;
    _DSciLogLevel := lSavedLevel;
    _DSciLogOutput := lSavedOutput;
    _DSciLogPath := lSavedPath;
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestLoggerLegacyAliasesShareStorage;
var
  lSavedEnabled: Boolean;
  lSavedLevel: Integer;
  lSavedOutput: Integer;
begin
  lSavedEnabled := _DSciLogEnabled;
  lSavedLevel := _DSciLogLevel;
  lSavedOutput := _DSciLogOutput;
  try
    _DSciLogEnabled := True;
    Check(_SciBridgeLogEnabled, 'Legacy read alias must reflect canonical Enabled');

    _DSciLogLevel := cDSciLogInfo;
    CheckEquals(cDSciLogInfo, _SciBridgeLogLevel,
      'Legacy read alias must reflect canonical LogLevel');

    _DSciLogOutput := cDSciOutputFile;
    CheckEquals(cDSciOutputFile, _SciBridgeLogOutput,
      'Legacy read alias must reflect canonical Output');

    CheckEquals(cSciBridgeLogError, cDSciLogError,
      'Legacy constant cSciBridgeLogError must equal cDSciLogError');
    CheckEquals(cSciBridgeOutputFile, cDSciOutputFile,
      'Legacy constant cSciBridgeOutputFile must equal cDSciOutputFile');
  finally
    _DSciLogEnabled := lSavedEnabled;
    _DSciLogLevel := lSavedLevel;
    _DSciLogOutput := lSavedOutput;
  end;
end;

procedure TTestDSciVisualUi.TestLoggerSciBridgeLogDelegatesToDSciLog;
var
  lSavedEnabled: Boolean;
  lSavedLevel: Integer;
  lSavedOutput: Integer;
  lSavedPath: string;
  lTempDir: string;
  lLogFile: string;
  lContent: string;
begin
  lSavedEnabled := _DSciLogEnabled;
  lSavedLevel := _DSciLogLevel;
  lSavedOutput := _DSciLogOutput;
  lSavedPath := _DSciLogPath;
  lTempDir := TPath.Combine(TPath.GetTempPath, 'dsci_legacy_' + IntToStr(GetTickCount));
  ForceDirectories(lTempDir);
  lLogFile := TPath.Combine(lTempDir, 'legacy_test.txt');
  try
    _DSciLogEnabled := True;
    _DSciLogLevel := cDSciLogDebug;
    _DSciLogOutput := cDSciOutputFile;
    _DSciLogPath := lLogFile;

    SciBridgeLog('LegacyWrapperTest', cSciBridgeLogInfo);

    Check(FileExists(lLogFile), 'SciBridgeLog must write via DSciLog');
    lContent := TFile.ReadAllText(lLogFile);
    Check(Pos('LegacyWrapperTest', lContent) > 0,
      'SciBridgeLog message must appear in log file');
  finally
    _DSciLogEnabled := lSavedEnabled;
    _DSciLogLevel := lSavedLevel;
    _DSciLogOutput := lSavedOutput;
    _DSciLogPath := lSavedPath;
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDSciVisualUi.TestSettingsDialogExitsWhenCancelledDuringModalLoop;
var
  lAutoClose: TAutoCloseDialog;
  lConfig: TDSciVisualConfig;
  lDialog: TDSciVisualSettingsDialog;
  lTempConfigFile: string;
  lTempDir: string;
begin
  // Regression test for preview handler ClearPreview / CancelAndFreeDialogs fix:
  // When ClearPreview (or WMDestroy) is invoked while the settings dialog is in its
  // ShowModal loop, the fix sets ModalResult := mrCancel on the live dialog instance.
  // This test verifies that TDSciVisualSettingsDialog.EditSettings returns False when
  // ModalResult is set externally from outside its ShowModal loop exactly the
  // mechanism relied upon by ClearPreview's FVisualSettingsDialog cancellation.
  lTempDir := CreateWritableTempDir;
  try
    lTempConfigFile := TPath.Combine(lTempDir, 'cancel-modal-loop.config.xml');
    lConfig := TDSciVisualConfig.Create;
    try
      lDialog := TDSciVisualSettingsDialog.Create(nil);
      lAutoClose := TAutoCloseDialog.Create;
      try
        lAutoClose.Attach(lDialog);
        Check(not lDialog.EditSettings('', lTempConfigFile, lConfig),
          'EditSettings must return False when ModalResult is set to mrCancel externally');
        CheckEquals(mrCancel, lDialog.ModalResult,
          'ModalResult must be mrCancel after external cancellation inside the modal loop');
      finally
        lAutoClose.Free;
        lDialog.Free;
      end;
    finally
      lConfig.Free;
    end;
  finally
    if TDirectory.Exists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

initialization
  RegisterTest(TTestDSciVisualUi.Suite);

end.
