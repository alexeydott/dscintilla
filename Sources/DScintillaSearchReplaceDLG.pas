unit DScintillaSearchReplaceDLG;

interface

uses
  System.Classes, System.Math, System.SysUtils, System.Types,
  Winapi.Windows,
  Vcl.ComCtrls, Vcl.Controls, Vcl.ExtCtrls, Vcl.Forms, Vcl.Graphics, Vcl.StdCtrls,
  DScintillaLogger;

type
  TDSciSearchMode = (
    dsmNormal,
    dsmExtended,
    dsmRegularExpression
  );

  TDSciSearchConfig = record
    Query: string;
    MatchCase: Boolean;
    WholeWord: Boolean;
    WrapAround: Boolean;
    InSelection: Boolean;
    SearchMode: TDSciSearchMode;
    { New in v2 – populated only when a Replace action is dispatched. }
    ReplaceText: string;
    SearchBackward: Boolean;
    RegexDotMatchesNewline: Boolean;
  end;

  TDSciFindDialogAction = (
    fdaFindNext,
    fdaFindPrevious,
    fdaCount,
    fdaFindAll,
    fdaMarkAllBookmarks,
    fdaReplace,
    fdaReplaceAll
  );

  TDSciFindDialogExecuteEvent = procedure(Sender: TObject;
    const AConfig: TDSciSearchConfig; AAction: TDSciFindDialogAction) of object;

  TDSciSearchReplaceDialog = class(TForm)
  private const
    cDialogWidth         = 700;
    cDialogHeight        = 360;   { compact: was 430 }
    cMinDialogWidth      = 580;
    cMinDialogHeight     = 320;   { compact: was 400 }
    cDialogPadding       = 8;     { compact: was 12  }
    cSectionGap          = 6;     { compact: was 10  }
    cRowGap              = 4;     { compact: was 8   }
    cButtonHeight        = 28;    { compact: was 34  }
    cInputHeight         = 24;    { compact: was 30  }
    cActionPanelWidth    = 180;
    cSelectionGroupWidth = 180;
    cGroupPadding        = 6;     { compact: was 8   }
    cCheckHeight         = 20;    { compact: was 24  }
    cMinFieldGap         = 8;
    cSwapButtonWidth     = 50;
    cSmallNavButtonWidth = 75;
    cFindPrevButtonWidth = 40;
  private
    // ── Find tab ──────────────────────────────────────────────────────────
    FPageControl: TPageControl;
    FFindTab: TTabSheet;
    FRootPanel: TPanel;
    FTopRowPanel: TPanel;
    FSearchPanel: TPanel;
    FSearchLabelHost: TPanel;
    FSearchFieldHost: TPanel;
    FSearchLabel: TLabel;
    FSearchCombo: TComboBox;
    FNavigationPanel: TPanel;
    FFindPreviousButton: TButton;
    FFindNextButton: TButton;
    FBodyPanel: TPanel;
    FActionsPanel: TPanel;
    FCountButton: TButton;
    FFindAllButton: TButton;
    FMarkAllButton: TButton;
    FCloseButton: TButton;
    FActionsSpacer: TPanel;
    FGroupsRowPanel: TPanel;
    FMainPanel: TPanel;
    FResultLabel: TLabel;
    FOptionsGroup: TGroupBox;
    FWholeWordCheck: TCheckBox;
    FMatchCaseCheck: TCheckBox;
    FWrapAroundCheck: TCheckBox;
    FSelectionGroup: TGroupBox;
    FInSelectionCheck: TCheckBox;
    FSearchModeGroup: TGroupBox;
    FNormalModeRadio: TRadioButton;
    FExtendedModeRadio: TRadioButton;
    FRegexModeRadio: TRadioButton;
    FRegexDotNewlineCheck: TCheckBox;

    // ── Replace tab ───────────────────────────────────────────────────────
    FReplaceTab: TTabSheet;
    FReplaceRootPanel: TPanel;
    FReplaceActionsPanel: TPanel;
    FSwapButton: TButton;
    FReplaceFindPreviousButton: TButton;
    FReplaceFindNextButton: TButton;
    FReplaceButton: TButton;
    FReplaceAllButton: TButton;
    FReplaceCloseButton: TButton;
    FReplaceBodyPanel: TPanel;
    FReplaceRow1Panel: TPanel;
    FReplaceRow2Panel: TPanel;
    FReplaceNavPanel: TPanel;
    FReplaceNavRowPanel: TPanel;
    FReplaceFieldsPanel: TPanel;
    FReplaceComboResultArea: TPanel;
    FReplaceResultPanel: TPanel;
    FReplaceGroupsRowPanel: TPanel;
    FReplaceSearchLabel: TLabel;
    FReplaceSearchCombo: TComboBox;
    FReplaceWithLabel: TLabel;
    FReplaceWithCombo: TComboBox;
    FReplaceInSelectionCheck: TCheckBox;
    FReplaceResultLabel: TLabel;
    FReplaceOptionsGroup: TGroupBox;
    FReplaceScopeGroup: TGroupBox;
    FReplaceWholeWordCheck: TCheckBox;
    FReplaceMatchCaseCheck: TCheckBox;
    FReplaceWrapAroundCheck: TCheckBox;
    FReplaceSearchModeGroup: TGroupBox;
    FReplaceNormalModeRadio: TRadioButton;
    FReplaceExtendedModeRadio: TRadioButton;
    FReplaceRegexModeRadio: TRadioButton;
    FReplaceRegexDotNewlineCheck: TCheckBox;

    // ── State ─────────────────────────────────────────────────────────────
    FOnExecuteSearch: TDSciFindDialogExecuteEvent;
    FUpdatingLayout: Boolean;
    FReplaceUpdatingLayout: Boolean;
    FReadOnly: Boolean;
    FUpdatingSync: Boolean;

    // ── Internal helpers ──────────────────────────────────────────────────
    function GetSearchConfig: TDSciSearchConfig;
    function MeasureSingleLineTextHeight(AFont: TFont): Integer;
    function MeasureSingleLineTextWidth(AFont: TFont; const AText: string): Integer;
    procedure BuildUi;
    procedure BuildReplaceTab;
    procedure DispatchAction(AAction: TDSciFindDialogAction);

    // Find tab handlers
    procedure FindNextButtonClick(Sender: TObject);
    procedure FindPreviousButtonClick(Sender: TObject);
    procedure FindRegexModeChanged(Sender: TObject);
    procedure CountButtonClick(Sender: TObject);
    procedure FindAllButtonClick(Sender: TObject);
    procedure MarkAllButtonClick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);

    // Replace tab handlers
    procedure SwapButtonClick(Sender: TObject);
    procedure ReplaceFindPreviousButtonClick(Sender: TObject);
    procedure ReplaceFindNextButtonClick(Sender: TObject);
    procedure ReplaceButtonClick(Sender: TObject);
    procedure ReplaceAllButtonClick(Sender: TObject);
    procedure ReplaceCloseButtonClick(Sender: TObject);
    procedure ReplaceRegexModeChanged(Sender: TObject);

    // Tab switching
    procedure PageControlChange(Sender: TObject);
    procedure SyncFindToReplace;
    procedure SyncReplaceToFind;

    procedure DialogClose(Sender: TObject; var Action: TCloseAction);
    procedure DialogKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    // Layout
    procedure LayoutCheckBox(AControl: TButtonControl; ALeft, ATop, AWidth,
      AHeight: Integer);
    procedure LayoutGroupBoxContent(AGroup: TGroupBox;
      const AControls: array of TButtonControl; ADesiredHeight: Integer;
      out AFinalHeight: Integer);
    procedure RefreshLayout;
    procedure RefreshReplaceLayout;
    procedure SetSearchMode(AMode: TDSciSearchMode);
    procedure SetReplaceSearchMode(AMode: TDSciSearchMode);
    procedure SetReadOnly(AValue: Boolean);
    procedure UpdateReplaceButtonStates;

    class function Dpi: Integer; static;
    class function Scale(AValue: Integer): Integer; static;
  protected
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure CreateWnd; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;

    procedure AddSearchHistory(const AText: string);
    procedure AddReplaceHistory(const AText: string);
    procedure ApplySearchConfig(const AConfig: TDSciSearchConfig);
    procedure FocusSearchText;
    procedure SetMatchSummary(const ASummary: string);
    procedure ShowFindTab;
    procedure ShowReplaceTab;

    property OnExecuteSearch: TDSciFindDialogExecuteEvent
      read FOnExecuteSearch write FOnExecuteSearch;
    property SearchConfig: TDSciSearchConfig read GetSearchConfig;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
  end;

  { Backward-compatibility alias for code that still references TDSciFindDialog. }
  TDSciFindDialog = TDSciSearchReplaceDialog;

implementation

type
  TGroupBoxAccess = class(TGroupBox);

// ── Class helpers ─────────────────────────────────────────────────────────────

class function TDSciSearchReplaceDialog.Dpi: Integer;
begin
  Result := Screen.PixelsPerInch;
end;

class function TDSciSearchReplaceDialog.Scale(AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, Dpi, 96);
end;

// ── Construction ──────────────────────────────────────────────────────────────

constructor TDSciSearchReplaceDialog.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  AutoScroll := False;
  BorderStyle := bsSizeable;
  BorderIcons := [biSystemMenu];
  Caption := 'Find / Replace';
  KeyPreview := True;
  Position := poMainFormCenter;
  Width := Scale(cDialogWidth);
  Height := Scale(cDialogHeight);
  Constraints.MinWidth := Scale(cMinDialogWidth);
  Constraints.MinHeight := Scale(cMinDialogHeight);
  OnClose := DialogClose;
  OnKeyDown := DialogKeyDown;

  BuildUi;
  RefreshLayout;
  RefreshReplaceLayout;
  DSciLog('Compact layout active: padding=8 sectionGap=6 rowGap=4 btn=28 input=24',
    cDSciLogDebug);
end;

procedure TDSciSearchReplaceDialog.BuildUi;

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

  function CreateDialogButton(AParent: TWinControl; const ACaption: string;
    AClick: TNotifyEvent): TButton;
  begin
    Result := TButton.Create(Self);
    Result.Parent := AParent;
    Result.Caption := ACaption;
    Result.Height := Scale(cButtonHeight);
    Result.OnClick := AClick;
  end;

  function CreateCheckBox(AParent: TWinControl; const ACaption: string;
    AChecked: Boolean = False): TCheckBox;
  begin
    Result := TCheckBox.Create(Self);
    Result.Parent := AParent;
    Result.Caption := ACaption;
    Result.Checked := AChecked;
    Result.Visible := True;
  end;

  function CreateRadioButton(AParent: TWinControl; const ACaption: string): TRadioButton;
  begin
    Result := TRadioButton.Create(Self);
    Result.Parent := AParent;
    Result.Caption := ACaption;
    Result.Visible := True;
  end;

begin
  FPageControl := TPageControl.Create(Self);
  FPageControl.Parent := Self;
  FPageControl.Align := alClient;
  FPageControl.OnChange := PageControlChange;

  FFindTab := TTabSheet.Create(Self);
  FFindTab.PageControl := FPageControl;
  FFindTab.Caption := 'Find';

  FRootPanel := CreateHostPanel(FFindTab);
  FRootPanel.Align := alClient;
  // Padding set in RefreshLayout

  // ── Top row: [Search label | combo] [▲ ▼] ──────────────────────────────
  FTopRowPanel := CreateHostPanel(FRootPanel);
  FTopRowPanel.Align := alTop;
  FTopRowPanel.AlignWithMargins := True;
  // Height and Margins.Bottom set in RefreshLayout

  FNavigationPanel := CreateHostPanel(FTopRowPanel);
  FNavigationPanel.Align := alRight;
  FNavigationPanel.AlignWithMargins := True;
  // Width and Margins.Left set in RefreshLayout

  FFindPreviousButton := CreateDialogButton(FNavigationPanel, #$25B2, FindPreviousButtonClick);
  FFindPreviousButton.Font.Name := 'Segoe UI Symbol';
  FFindPreviousButton.Hint := 'Find Previous';
  FFindPreviousButton.ShowHint := True;
  // Position (vertical centering) set in RefreshLayout

  FFindNextButton := CreateDialogButton(FNavigationPanel, #$25BC, FindNextButtonClick);
  FFindNextButton.Font.Name := 'Segoe UI Symbol';
  FFindNextButton.Hint := 'Find Next';
  FFindNextButton.ShowHint := True;
  // Position set in RefreshLayout

  FSearchPanel := CreateHostPanel(FTopRowPanel);
  FSearchPanel.Align := alClient;

  FSearchLabelHost := CreateHostPanel(FSearchPanel);
  FSearchLabelHost.Align := alLeft;
  // Width set in RefreshLayout

  FSearchLabel := TLabel.Create(Self);
  FSearchLabel.Parent := FSearchLabelHost;
  FSearchLabel.Align := alClient;          // fills host panel
  FSearchLabel.AutoSize := False;
  FSearchLabel.Alignment := taLeftJustify;
  FSearchLabel.Layout := tlCenter;         // VCL vertical centering, no manual SetBounds needed
  FSearchLabel.WordWrap := False;
  FSearchLabel.Caption := 'Find what:';

  FSearchFieldHost := CreateHostPanel(FSearchPanel);
  FSearchFieldHost.Align := alClient;
  FSearchFieldHost.AlignWithMargins := True;
  // Margins.Left set in RefreshLayout

  FSearchCombo := TComboBox.Create(Self);
  FSearchCombo.Parent := FSearchFieldHost;
  FSearchCombo.AutoComplete := False;
  FSearchCombo.Align := alTop;
  FSearchCombo.AlignWithMargins := True;
  // Margins.Top for vertical centering set in RefreshLayout;
  // Width auto-managed by alTop (fills parent width)

  // ── Body: [Main panel] [Actions panel] ──────────────────────────────────
  FBodyPanel := CreateHostPanel(FRootPanel);
  FBodyPanel.Align := alClient;

  FActionsPanel := CreateHostPanel(FBodyPanel);
  FActionsPanel.Align := alRight;
  FActionsPanel.AlignWithMargins := True;
  // Width and Margins.Left set in RefreshLayout

  // Spacer: aligns Count button with the groups row (skips result label area)
  FActionsSpacer := CreateHostPanel(FActionsPanel);
  FActionsSpacer.Align := alTop;
  // Height set in RefreshLayout

  FCountButton := CreateDialogButton(FActionsPanel, 'Count', CountButtonClick);
  FCountButton.Align := alTop;
  FCountButton.AlignWithMargins := True;
  // Height and Margins.Bottom set in RefreshLayout; Width auto from alTop

  FFindAllButton := CreateDialogButton(FActionsPanel, 'Find All', FindAllButtonClick);
  FFindAllButton.Align := alTop;
  FFindAllButton.AlignWithMargins := True;

  FMarkAllButton := CreateDialogButton(FActionsPanel, 'Mark All', MarkAllButtonClick);
  FMarkAllButton.Align := alTop;
  FMarkAllButton.AlignWithMargins := True;

  FCloseButton := CreateDialogButton(FActionsPanel, 'Close', CloseButtonClick);
  FCloseButton.Align := alTop;
  // No bottom margin for last button

  FMainPanel := CreateHostPanel(FBodyPanel);
  FMainPanel.Align := alClient;

  FResultLabel := TLabel.Create(Self);
  FResultLabel.Parent := FMainPanel;
  FResultLabel.Align := alTop;
  FResultLabel.AlignWithMargins := True;
  FResultLabel.AutoSize := False;
  FResultLabel.Layout := tlCenter;
  FResultLabel.WordWrap := False;
  FResultLabel.Caption := '0 matches';
  // Height and Margins.Bottom set in RefreshLayout

  // Row panel: Options group (left) + Scope group (right) side by side
  FGroupsRowPanel := CreateHostPanel(FMainPanel);
  FGroupsRowPanel.Align := alTop;
  FGroupsRowPanel.AlignWithMargins := True;
  // Height and Margins.Bottom set in RefreshLayout
  // FOptionsGroup and FSelectionGroup use manual SetBounds inside FGroupsRowPanel

  FOptionsGroup := CreateGroupSection(FGroupsRowPanel, 'Search Options');
  FWholeWordCheck := CreateCheckBox(FOptionsGroup, 'Whole word only');
  FMatchCaseCheck := CreateCheckBox(FOptionsGroup, 'Match case');
  FWrapAroundCheck := CreateCheckBox(FOptionsGroup, 'Wrap around', True);

  FSelectionGroup := CreateGroupSection(FGroupsRowPanel, 'Scope');
  FInSelectionCheck := CreateCheckBox(FSelectionGroup, 'In selection');

  FSearchModeGroup := CreateGroupSection(FMainPanel, 'Search Mode');
  FSearchModeGroup.Align := alTop;
  // Height set by LayoutGroupBoxContent; VCL positions after FGroupsRowPanel

  FNormalModeRadio := CreateRadioButton(FSearchModeGroup, 'Normal');
  FNormalModeRadio.OnClick := FindRegexModeChanged;
  FExtendedModeRadio := CreateRadioButton(FSearchModeGroup,
    'Extended (\n, \r, \t, \0, \x...)');
  FExtendedModeRadio.OnClick := FindRegexModeChanged;
  FRegexModeRadio := CreateRadioButton(FSearchModeGroup, 'Regular expression');
  FRegexModeRadio.OnClick := FindRegexModeChanged;

  FRegexDotNewlineCheck := TCheckBox.Create(Self);
  FRegexDotNewlineCheck.Parent := FSearchModeGroup;
  FRegexDotNewlineCheck.Caption := '. matches newline';
  FRegexDotNewlineCheck.Enabled := False;
  FRegexDotNewlineCheck.Visible := True;

  SetSearchMode(dsmNormal);

  BuildReplaceTab;
end;

procedure TDSciSearchReplaceDialog.BuildReplaceTab;

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

  function CreateDialogButton(AParent: TWinControl; const ACaption: string;
    AClick: TNotifyEvent): TButton;
  begin
    Result := TButton.Create(Self);
    Result.Parent := AParent;
    Result.Caption := ACaption;
    Result.Height := Scale(cButtonHeight);
    Result.OnClick := AClick;
  end;

  function CreateCheckBox(AParent: TWinControl; const ACaption: string;
    AChecked: Boolean = False): TCheckBox;
  begin
    Result := TCheckBox.Create(Self);
    Result.Parent := AParent;
    Result.Caption := ACaption;
    Result.Checked := AChecked;
    Result.Visible := True;
  end;

begin
  FReplaceTab := TTabSheet.Create(Self);
  FReplaceTab.PageControl := FPageControl;
  FReplaceTab.Caption := 'Replace';

  FReplaceRootPanel := CreateHostPanel(FReplaceTab);
  FReplaceRootPanel.Align := alClient;
  // Padding set in RefreshReplaceLayout

  // ── Actions panel (right): [▲▼ nav row] + [Replace] + [Replace All] + [Close] ─
  FReplaceActionsPanel := CreateHostPanel(FReplaceRootPanel);
  FReplaceActionsPanel.Align := alRight;
  FReplaceActionsPanel.AlignWithMargins := True;
  // Width and Margins.Left set in RefreshReplaceLayout

  // Nav row: [Find Previous (smaller)] [Find Next (wider)] side by side
  FReplaceNavRowPanel := CreateHostPanel(FReplaceActionsPanel);
  FReplaceNavRowPanel.Align := alTop;
  FReplaceNavRowPanel.AlignWithMargins := True;
  // Height and Margins.Bottom set in RefreshReplaceLayout

  FReplaceFindPreviousButton := CreateDialogButton(FReplaceNavRowPanel, #$25B2,
    ReplaceFindPreviousButtonClick);
  FReplaceFindPreviousButton.Font.Name := 'Segoe UI Symbol';
  FReplaceFindPreviousButton.Hint := 'Find Previous';
  FReplaceFindPreviousButton.ShowHint := True;
  // Bounds (small width) set via SetBounds in RefreshReplaceLayout

  FReplaceFindNextButton := CreateDialogButton(FReplaceNavRowPanel, #$25BC,
    ReplaceFindNextButtonClick);
  FReplaceFindNextButton.Font.Name := 'Segoe UI Symbol';
  FReplaceFindNextButton.Hint := 'Find Next';
  FReplaceFindNextButton.ShowHint := True;
  // Bounds (wider) set via SetBounds in RefreshReplaceLayout

  FReplaceButton := CreateDialogButton(FReplaceActionsPanel, 'Replace',
    ReplaceButtonClick);
  FReplaceButton.Align := alTop;
  FReplaceButton.AlignWithMargins := True;

  FReplaceAllButton := CreateDialogButton(FReplaceActionsPanel, 'Replace All',
    ReplaceAllButtonClick);
  FReplaceAllButton.Align := alTop;
  FReplaceAllButton.AlignWithMargins := True;

  FReplaceCloseButton := CreateDialogButton(FReplaceActionsPanel, 'Close',
    ReplaceCloseButtonClick);
  FReplaceCloseButton.Align := alTop;
  // Heights and margins set in RefreshReplaceLayout

  // ── Body panel ──────────────────────────────────────────────────────────────
  FReplaceBodyPanel := CreateHostPanel(FReplaceRootPanel);
  FReplaceBodyPanel.Align := alClient;

  // ── Fields panel (alTop): holds swap panel (alRight) + combo+result area (alClient) ─
  // FReplaceNavPanel is alRight with no alTop/alBottom siblings, so VCL gives it the
  // full panel height. FReplaceComboResultArea (alClient) fills the remaining width.
  FReplaceFieldsPanel := CreateHostPanel(FReplaceBodyPanel);
  FReplaceFieldsPanel.Align := alTop;
  FReplaceFieldsPanel.AlignWithMargins := True;
  // Height and Margins.Bottom set in RefreshReplaceLayout

  // Swap panel (alRight in FReplaceFieldsPanel): spans full height, holds only FSwapButton
  FReplaceNavPanel := CreateHostPanel(FReplaceFieldsPanel);
  FReplaceNavPanel.Align := alRight;
  FReplaceNavPanel.AlignWithMargins := True;
  // Width and Margins set in RefreshReplaceLayout

  FSwapButton := CreateDialogButton(FReplaceNavPanel, #$21C5, SwapButtonClick);
  FSwapButton.Font.Name := 'Segoe UI Symbol';
  FSwapButton.Hint := 'Swap Find / Replace texts';
  FSwapButton.ShowHint := True;
  // Vertically centered via SetBounds in RefreshReplaceLayout

  // Combo+result area (alClient): holds both combo rows and the result label.
  // By being alClient (not alTop/alBottom) it does not consume FReplaceNavPanel's height.
  FReplaceComboResultArea := CreateHostPanel(FReplaceFieldsPanel);
  FReplaceComboResultArea.Align := alClient;

  // Row 1: [Find what: label | combo] inside FReplaceComboResultArea
  FReplaceRow1Panel := CreateHostPanel(FReplaceComboResultArea);
  FReplaceRow1Panel.Align := alTop;
  FReplaceRow1Panel.AlignWithMargins := True;
  // Height and Margins set in RefreshReplaceLayout

  FReplaceSearchLabel := TLabel.Create(Self);
  FReplaceSearchLabel.Parent := FReplaceRow1Panel;
  FReplaceSearchLabel.Align := alLeft;
  FReplaceSearchLabel.AutoSize := False;
  FReplaceSearchLabel.Alignment := taLeftJustify;
  FReplaceSearchLabel.Layout := tlCenter;
  FReplaceSearchLabel.WordWrap := False;
  FReplaceSearchLabel.Caption := 'Find what:';
  // Width set in RefreshReplaceLayout

  FReplaceSearchCombo := TComboBox.Create(Self);
  FReplaceSearchCombo.Parent := FReplaceRow1Panel;
  FReplaceSearchCombo.AutoComplete := False;
  FReplaceSearchCombo.Align := alClient;
  FReplaceSearchCombo.AlignWithMargins := True;
  // Margins.Left set in RefreshReplaceLayout

  // Row 2: [Replace with: label | combo] inside FReplaceComboResultArea
  FReplaceRow2Panel := CreateHostPanel(FReplaceComboResultArea);
  FReplaceRow2Panel.Align := alTop;
  // Height set in RefreshReplaceLayout (no bottom margin — last row before result panel)

  FReplaceWithLabel := TLabel.Create(Self);
  FReplaceWithLabel.Parent := FReplaceRow2Panel;
  FReplaceWithLabel.Align := alLeft;
  FReplaceWithLabel.AutoSize := False;
  FReplaceWithLabel.Alignment := taLeftJustify;
  FReplaceWithLabel.Layout := tlCenter;
  FReplaceWithLabel.WordWrap := False;
  FReplaceWithLabel.Caption := 'Replace with:';
  // Width set in RefreshReplaceLayout

  FReplaceWithCombo := TComboBox.Create(Self);
  FReplaceWithCombo.Parent := FReplaceRow2Panel;
  FReplaceWithCombo.AutoComplete := False;
  FReplaceWithCombo.Align := alClient;
  FReplaceWithCombo.AlignWithMargins := True;
  // Margins.Left set in RefreshReplaceLayout

  // ── Result / status label – alTop panel in FReplaceBodyPanel, directly after
  // FReplaceFieldsPanel. Keeping it outside FReplaceFieldsPanel ensures
  // FReplaceNavPanel (alRight) always gets the full two-row height.
  FReplaceResultPanel := CreateHostPanel(FReplaceBodyPanel);
  FReplaceResultPanel.Align := alTop;
  FReplaceResultPanel.AlignWithMargins := True;
  // Height and Margins set in RefreshReplaceLayout

  FReplaceResultLabel := TLabel.Create(Self);
  FReplaceResultLabel.Parent := FReplaceResultPanel;
  FReplaceResultLabel.Align := alClient;
  FReplaceResultLabel.AutoSize := False;
  FReplaceResultLabel.Layout := tlCenter;
  FReplaceResultLabel.WordWrap := False;
  FReplaceResultLabel.Caption := '0 matches';

  // ── Groups row: Search Options (left) + Scope (right) side-by-side ──────────
  FReplaceGroupsRowPanel := CreateHostPanel(FReplaceBodyPanel);
  FReplaceGroupsRowPanel.Align := alTop;
  FReplaceGroupsRowPanel.AlignWithMargins := True;
  // Height and Margins.Bottom set in RefreshReplaceLayout

  FReplaceOptionsGroup := CreateGroupSection(FReplaceGroupsRowPanel, 'Search Options');
  FReplaceWholeWordCheck := CreateCheckBox(FReplaceOptionsGroup, 'Whole word only');
  FReplaceMatchCaseCheck := CreateCheckBox(FReplaceOptionsGroup, 'Match case');
  FReplaceWrapAroundCheck := CreateCheckBox(FReplaceOptionsGroup, 'Wrap around', True);

  FReplaceScopeGroup := CreateGroupSection(FReplaceGroupsRowPanel, 'Scope');
  FReplaceInSelectionCheck := CreateCheckBox(FReplaceScopeGroup, 'In selection');

  // ── Search Mode group ────────────────────────────────────────────────────────
  FReplaceSearchModeGroup := CreateGroupSection(FReplaceBodyPanel, 'Search Mode');
  FReplaceSearchModeGroup.Align := alTop;

  FReplaceNormalModeRadio := TRadioButton.Create(Self);
  FReplaceNormalModeRadio.Parent := FReplaceSearchModeGroup;
  FReplaceNormalModeRadio.Caption := 'Normal';
  FReplaceNormalModeRadio.OnClick := ReplaceRegexModeChanged;
  FReplaceNormalModeRadio.Visible := True;

  FReplaceExtendedModeRadio := TRadioButton.Create(Self);
  FReplaceExtendedModeRadio.Parent := FReplaceSearchModeGroup;
  FReplaceExtendedModeRadio.Caption := 'Extended (\n, \r, \t, \0, \x...)';
  FReplaceExtendedModeRadio.OnClick := ReplaceRegexModeChanged;
  FReplaceExtendedModeRadio.Visible := True;

  FReplaceRegexModeRadio := TRadioButton.Create(Self);
  FReplaceRegexModeRadio.Parent := FReplaceSearchModeGroup;
  FReplaceRegexModeRadio.Caption := 'Regular expression';
  FReplaceRegexModeRadio.OnClick := ReplaceRegexModeChanged;
  FReplaceRegexModeRadio.Visible := True;

  FReplaceRegexDotNewlineCheck := TCheckBox.Create(Self);
  FReplaceRegexDotNewlineCheck.Parent := FReplaceSearchModeGroup;
  FReplaceRegexDotNewlineCheck.Caption := '. matches newline';
  FReplaceRegexDotNewlineCheck.Enabled := False;
  FReplaceRegexDotNewlineCheck.Visible := True;

  SetReplaceSearchMode(dsmNormal);
end;

// ── Window lifecycle ──────────────────────────────────────────────────────────

procedure TDSciSearchReplaceDialog.CreateWnd;
begin
  inherited CreateWnd;
  RefreshLayout;
  RefreshReplaceLayout;
end;

procedure TDSciSearchReplaceDialog.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  RefreshLayout;
  RefreshReplaceLayout;
end;

procedure TDSciSearchReplaceDialog.Resize;
begin
  inherited Resize;
  RefreshLayout;
  RefreshReplaceLayout;
end;

// ── Text measurement ──────────────────────────────────────────────────────────

function TDSciSearchReplaceDialog.MeasureSingleLineTextWidth(AFont: TFont;
  const AText: string): Integer;
var
  lDc: HDC;
  lRect: TRect;
  lSavedFont: HGDIOBJ;
begin
  lDc := GetDC(0);
  try
    lSavedFont := SelectObject(lDc, AFont.Handle);
    try
      lRect := Rect(0, 0, 0, 0);
      DrawText(lDc, PChar(AText), Length(AText), lRect,
        DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX);
      Result := lRect.Right - lRect.Left;
    finally
      SelectObject(lDc, lSavedFont);
    end;
  finally
    ReleaseDC(0, lDc);
  end;
end;

function TDSciSearchReplaceDialog.MeasureSingleLineTextHeight(AFont: TFont): Integer;
var
  lDc: HDC;
  lRect: TRect;
  lSavedFont: HGDIOBJ;
begin
  lDc := GetDC(0);
  try
    lSavedFont := SelectObject(lDc, AFont.Handle);
    try
      lRect := Rect(0, 0, 0, 0);
      DrawText(lDc, 'Ag', 2, lRect, DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX);
      Result := lRect.Bottom - lRect.Top;
    finally
      SelectObject(lDc, lSavedFont);
    end;
  finally
    ReleaseDC(0, lDc);
  end;
end;

// ── Layout helpers ────────────────────────────────────────────────────────────

procedure TDSciSearchReplaceDialog.LayoutCheckBox(AControl: TButtonControl;
  ALeft, ATop, AWidth, AHeight: Integer);
begin
  AControl.SetBounds(ALeft, ATop, AWidth, AHeight);
end;

procedure TDSciSearchReplaceDialog.LayoutGroupBoxContent(AGroup: TGroupBox;
  const AControls: array of TButtonControl; ADesiredHeight: Integer;
  out AFinalHeight: Integer);
var
  lContentRect: TRect;
  lControl: TButtonControl;
  lIndex: Integer;
  lInnerLeft: Integer;
  lInnerTop: Integer;
  lInnerWidth: Integer;
  lPadding: Integer;
  lRowGap: Integer;
  lRowHeight: Integer;
begin
  lPadding := Scale(cGroupPadding);
  lRowGap := Scale(cRowGap);
  lRowHeight := Max(Scale(cCheckHeight),
    MeasureSingleLineTextHeight(Font) + Scale(4));

  lContentRect := AGroup.ClientRect;
  TGroupBoxAccess(AGroup).AdjustClientRect(lContentRect);

  lInnerLeft := lContentRect.Left + lPadding;
  lInnerTop := lContentRect.Top + lPadding;
  lInnerWidth := Max(0, (lContentRect.Right - lContentRect.Left) - (lPadding * 2));

  for lIndex := 0 to High(AControls) do
  begin
    lControl := AControls[lIndex];
    LayoutCheckBox(lControl, lInnerLeft, lInnerTop, lInnerWidth, lRowHeight);
    Inc(lInnerTop, lRowHeight + lRowGap);
  end;

  AFinalHeight := Max(ADesiredHeight,
    lInnerTop + Max(lPadding, AGroup.ClientHeight - lContentRect.Bottom));
  AGroup.Height := AFinalHeight;
end;

// ── Find tab layout ───────────────────────────────────────────────────────────

procedure TDSciSearchReplaceDialog.RefreshLayout;
var
  lAdditionalClientHeight: Integer;
  lActionButtonHeight: Integer;
  lButtonGap: Integer;
  lGroupHeight: Integer;
  lInputHeight: Integer;
  lLabelHeight: Integer;
  lLabelWidth: Integer;
  lMainWidth: Integer;
  lModeGroupHeight: Integer;
  lNavButtonWidth: Integer;
  lNavigationWidth: Integer;
  lPadding: Integer;
  lResultHeight: Integer;
  lSectionGap: Integer;
  lSelectionGroupHeight: Integer;
  lSelectionGroupLeft: Integer;
  lSelectionGroupWidth: Integer;
  lNeededRootHeight: Integer;
  lTopRowHeight: Integer;
begin
  if FUpdatingLayout then
    Exit;
  if not HandleAllocated then
    Exit;
  if (FRootPanel = nil) or (FMainPanel = nil) or (FOptionsGroup = nil) then
    Exit;

  FUpdatingLayout := True;
  try
    lPadding           := Scale(cDialogPadding);
    lSectionGap        := Scale(cSectionGap);
    lButtonGap         := Scale(cRowGap);
    lInputHeight       := Scale(cInputHeight);
    lActionButtonHeight:= Scale(cButtonHeight);
    lLabelHeight       := MeasureSingleLineTextHeight(Font);
    lLabelWidth        := MeasureSingleLineTextWidth(Font, FSearchLabel.Caption) + lButtonGap;
    lNavButtonWidth    := Scale(cSmallNavButtonWidth);
    lNavigationWidth   := lNavButtonWidth * 2 + lButtonGap;
    lTopRowHeight      := Max(lInputHeight, lActionButtonHeight);
    lResultHeight      := lLabelHeight + Scale(4);

    // ── Root panel inner padding ───────────────────────────────────────────
    FRootPanel.Padding.Left   := lPadding;
    FRootPanel.Padding.Top    := lPadding;
    FRootPanel.Padding.Right  := lPadding;
    FRootPanel.Padding.Bottom := lPadding;

    // ── Top row ────────────────────────────────────────────────────────────
    FTopRowPanel.Height         := lTopRowHeight;
    FTopRowPanel.Margins.Bottom := lSectionGap;

    // Navigation panel (▲ ▼): fixed width, gap from search panel
    FNavigationPanel.Width          := lNavigationWidth;
    FNavigationPanel.Margins.Left   := lButtonGap;
    FNavigationPanel.Margins.Top    := 0;
    FNavigationPanel.Margins.Bottom := 0;
    FNavigationPanel.Margins.Right  := 0;
    FFindPreviousButton.SetBounds(
      0,
      (lTopRowHeight - lActionButtonHeight) div 2,
      lNavButtonWidth, lActionButtonHeight);
    FFindNextButton.SetBounds(
      lNavButtonWidth + lButtonGap,
      (lTopRowHeight - lActionButtonHeight) div 2,
      lNavButtonWidth, lActionButtonHeight);

    // Label host: width drives FSearchLabel (alClient + tlCenter = no manual centering)
    FSearchLabelHost.Width := lLabelWidth;

    // Combo: alTop + AlignWithMargins; Margins.Top centers it vertically
    FSearchFieldHost.Margins.Left := Scale(cMinFieldGap);
    FSearchCombo.Margins.Top := (lTopRowHeight - lInputHeight) div 2;
    // Width auto-managed by Align=alTop inside FSearchFieldHost

    // ── Actions panel (right of body) ──────────────────────────────────────
    FActionsPanel.Width        := Scale(cActionPanelWidth);
    FActionsPanel.Margins.Left := lButtonGap;

    // Spacer height = result label area; aligns Count button with groups row
    FActionsSpacer.Height := lResultHeight + lSectionGap;

    // Buttons: Align=alTop; only height and bottom margin needed
    FCountButton.Height         := lActionButtonHeight;
    FCountButton.Margins.Bottom := lButtonGap;
    FFindAllButton.Height         := lActionButtonHeight;
    FFindAllButton.Margins.Bottom := lButtonGap;
    FMarkAllButton.Height         := lActionButtonHeight;
    FMarkAllButton.Margins.Bottom := lButtonGap;
    FCloseButton.Height := lActionButtonHeight;
    // Width auto-managed by Align=alTop; Y position auto-managed by VCL stacking

    // ── Main panel: alTop stack ─────────────────────────────────────────────
    FResultLabel.Height         := lResultHeight;
    FResultLabel.Margins.Bottom := lSectionGap;

    // Groups row: Options (left) + Scope (right), manual side-by-side layout
    lMainWidth         := FMainPanel.ClientWidth;
    lSelectionGroupWidth := Scale(cSelectionGroupWidth);
    lSelectionGroupLeft  := Max(0, lMainWidth - lSelectionGroupWidth);

    FSelectionGroup.SetBounds(lSelectionGroupLeft, 0, lSelectionGroupWidth, Scale(72));
    LayoutGroupBoxContent(FSelectionGroup, [FInSelectionCheck], Scale(72),
      lSelectionGroupHeight);
    FSelectionGroup.SetBounds(lSelectionGroupLeft, 0, lSelectionGroupWidth,
      lSelectionGroupHeight);

    FOptionsGroup.SetBounds(0, 0, Max(0, lSelectionGroupLeft - lButtonGap),
      lSelectionGroupHeight);
    LayoutGroupBoxContent(FOptionsGroup,
      [FWholeWordCheck, FMatchCaseCheck, FWrapAroundCheck],
      lSelectionGroupHeight, lGroupHeight);
    FOptionsGroup.SetBounds(0, 0, Max(0, lSelectionGroupLeft - lButtonGap), lGroupHeight);

    FGroupsRowPanel.Height         := Max(lGroupHeight, lSelectionGroupHeight);
    FGroupsRowPanel.Margins.Bottom := lSectionGap;
    // FSearchModeGroup is Align=alTop; VCL positions it after FGroupsRowPanel

    LayoutGroupBoxContent(FSearchModeGroup,
      [FNormalModeRadio, FExtendedModeRadio, FRegexModeRadio, FRegexDotNewlineCheck],
      Scale(110), lModeGroupHeight);
    // FSearchModeGroup.Height already set by LayoutGroupBoxContent

    // ── Form height check ──────────────────────────────────────────────────
    // FRootPanel content = top-row + sectionGap + alTop stack in FMainPanel + padding*2
    lNeededRootHeight :=
      (lTopRowHeight + lSectionGap) +
      (lResultHeight + lSectionGap) +
      FGroupsRowPanel.Height + lSectionGap +
      lModeGroupHeight +
      lPadding * 2;

    Constraints.MinHeight := Max(Scale(cMinDialogHeight),
      Height - FRootPanel.ClientHeight + lNeededRootHeight);
    lAdditionalClientHeight := lNeededRootHeight - FRootPanel.ClientHeight;
    if lAdditionalClientHeight > 0 then
      ClientHeight := ClientHeight + lAdditionalClientHeight;

    DSciLog(Format('Find dialog layout refreshed (%d x %d)',
      [ClientWidth, ClientHeight]), cDSciLogDebug);
  finally
    FUpdatingLayout := False;
  end;
end;

// ── Replace tab layout ────────────────────────────────────────────────────────

procedure TDSciSearchReplaceDialog.RefreshReplaceLayout;
var
  lAdditionalClientHeight: Integer;
  lActionButtonHeight: Integer;
  lButtonGap: Integer;
  lFieldsPanelHeight: Integer;
  lFindPrevW: Integer;
  lFindNextW: Integer;
  lGroupHeight: Integer;
  lLabelWidth: Integer;
  lModeGroupHeight: Integer;
  lNavRowWidth: Integer;
  lNeededRootHeight: Integer;
  lPadding: Integer;
  lScopeGroupHeight: Integer;
  lScopeGroupLeft: Integer;
  lScopeGroupWidth: Integer;
  lSectionGap: Integer;
  lSwapW: Integer;
begin
  if FReplaceUpdatingLayout then
    Exit;
  if not HandleAllocated then
    Exit;
  if (FReplaceRootPanel = nil) or (FReplaceBodyPanel = nil) or
     (FReplaceOptionsGroup = nil) or (FReplaceResultPanel = nil) then
    Exit;

  FReplaceUpdatingLayout := True;
  try
    lPadding            := Scale(cDialogPadding);
    lSectionGap         := Scale(cSectionGap);
    lButtonGap          := Scale(cRowGap);
    lActionButtonHeight := Scale(cButtonHeight);
    lSwapW              := Scale(cSwapButtonWidth);
    lFindPrevW          := Scale(cFindPrevButtonWidth);

    // Label width: widest of the two labels + field gap
    lLabelWidth := Max(
      MeasureSingleLineTextWidth(Font, FReplaceSearchLabel.Caption),
      MeasureSingleLineTextWidth(Font, FReplaceWithLabel.Caption)
    ) + Scale(cMinFieldGap);

    // ── Root panel padding ──────────────────────────────────────────────────
    FReplaceRootPanel.Padding.Left   := lPadding;
    FReplaceRootPanel.Padding.Top    := lPadding;
    FReplaceRootPanel.Padding.Right  := lPadding;
    FReplaceRootPanel.Padding.Bottom := lPadding;

    // ── Actions panel (right): nav row + action buttons ─────────────────────
    FReplaceActionsPanel.Width        := Scale(cActionPanelWidth);
    FReplaceActionsPanel.Margins.Left := lButtonGap;

    lNavRowWidth := Scale(cActionPanelWidth);
    lFindNextW   := Max(0, lNavRowWidth - lFindPrevW - lButtonGap);

    // Nav row: [Find Previous (small)] [Find Next (wider)]
    FReplaceNavRowPanel.Height         := lActionButtonHeight;
    FReplaceNavRowPanel.Margins.Bottom := lButtonGap;
    FReplaceFindPreviousButton.SetBounds(0, 0, lFindPrevW, lActionButtonHeight);
    FReplaceFindNextButton.SetBounds(lFindPrevW + lButtonGap, 0, lFindNextW,
      lActionButtonHeight);

    // Action buttons
    FReplaceButton.Height            := lActionButtonHeight;
    FReplaceButton.Margins.Bottom    := lButtonGap;
    FReplaceAllButton.Height         := lActionButtonHeight;
    FReplaceAllButton.Margins.Bottom := lButtonGap;
    FReplaceCloseButton.Height       := lActionButtonHeight;

    // ── Fields panel (alTop): two combo rows + swap panel (alRight) ─────────
    // FReplaceResultPanel is a sibling in FReplaceBodyPanel (not inside here)
    // so FReplaceNavPanel (alRight) always gets the full two-row height.
    lFieldsPanelHeight := (lActionButtonHeight + lButtonGap) + lActionButtonHeight;
    FReplaceFieldsPanel.Height         := lFieldsPanelHeight;
    FReplaceFieldsPanel.Margins.Bottom := lSectionGap;

    // Swap panel (alRight, spans full lFieldsPanelHeight): center swap button in the two-row combo area
    FReplaceNavPanel.Width          := lSwapW;
    FReplaceNavPanel.Margins.Left   := lButtonGap;
    FReplaceNavPanel.Margins.Top    := 0;   // zero so it spans the full fields-panel height
    FReplaceNavPanel.Margins.Bottom := 0;
    // Combo area height = row1 + gap + row2; center = (comboAreaH + buttonH) / 2 from top
    FSwapButton.SetBounds(0, (lActionButtonHeight + lButtonGap) div 2,
      lSwapW, lActionButtonHeight);

    // Row 1 (Find what) — zero out all side/top margins so rows span the same width
    FReplaceRow1Panel.Height         := lActionButtonHeight;
    FReplaceRow1Panel.Margins.Top    := 0;
    FReplaceRow1Panel.Margins.Left   := 0;
    FReplaceRow1Panel.Margins.Right  := 0;
    FReplaceRow1Panel.Margins.Bottom := lButtonGap;
    FReplaceSearchLabel.Width        := lLabelWidth;
    FReplaceSearchCombo.Margins.Left := Scale(cMinFieldGap);

    // Row 2 (Replace with)
    FReplaceRow2Panel.Height         := lActionButtonHeight;
    FReplaceRow2Panel.Margins.Bottom := 0;
    FReplaceWithLabel.Width          := lLabelWidth;
    FReplaceWithCombo.Margins.Left   := Scale(cMinFieldGap);

    // ── Result panel (alTop in FReplaceBodyPanel, after FReplaceFieldsPanel) ──
    FReplaceResultPanel.Height          := lActionButtonHeight;
    FReplaceResultPanel.Margins.Top     := 0;
    FReplaceResultPanel.Margins.Bottom  := lSectionGap;
    FReplaceResultPanel.Margins.Left    := 0;
    FReplaceResultPanel.Margins.Right   := 0;

    // ── Groups row: Options (left) + Scope (right), manual side-by-side ─────
    lScopeGroupWidth := Scale(cSelectionGroupWidth);
    lScopeGroupLeft  := Max(0, FReplaceBodyPanel.ClientWidth - lScopeGroupWidth);

    FReplaceScopeGroup.SetBounds(lScopeGroupLeft, 0, lScopeGroupWidth, Scale(72));
    LayoutGroupBoxContent(FReplaceScopeGroup, [FReplaceInSelectionCheck], Scale(72),
      lScopeGroupHeight);
    FReplaceScopeGroup.SetBounds(lScopeGroupLeft, 0, lScopeGroupWidth, lScopeGroupHeight);

    FReplaceOptionsGroup.SetBounds(0, 0, Max(0, lScopeGroupLeft - lButtonGap),
      lScopeGroupHeight);
    LayoutGroupBoxContent(FReplaceOptionsGroup,
      [FReplaceWholeWordCheck, FReplaceMatchCaseCheck, FReplaceWrapAroundCheck],
      lScopeGroupHeight, lGroupHeight);
    FReplaceOptionsGroup.SetBounds(0, 0, Max(0, lScopeGroupLeft - lButtonGap),
      lGroupHeight);

    FReplaceGroupsRowPanel.Height         := Max(lGroupHeight, lScopeGroupHeight);
    FReplaceGroupsRowPanel.Margins.Bottom := lSectionGap;

    // ── Search Mode group ────────────────────────────────────────────────────
    LayoutGroupBoxContent(FReplaceSearchModeGroup,
      [FReplaceNormalModeRadio, FReplaceExtendedModeRadio, FReplaceRegexModeRadio,
       FReplaceRegexDotNewlineCheck],
      Scale(110), lModeGroupHeight);

    UpdateReplaceButtonStates;

    // ── Form height check ────────────────────────────────────────────────────
    lNeededRootHeight :=
      lFieldsPanelHeight + lSectionGap +              // fields panel (rows) + Margins.Bottom
      lActionButtonHeight + lSectionGap +             // result panel + Margins.Bottom
      FReplaceGroupsRowPanel.Height + lSectionGap +   // groups row + gap
      lModeGroupHeight +                              // mode group
      lPadding * 2;                                   // root padding

    Constraints.MinHeight := Max(Scale(cMinDialogHeight),
      Height - FReplaceRootPanel.ClientHeight + lNeededRootHeight);
    lAdditionalClientHeight := lNeededRootHeight - FReplaceRootPanel.ClientHeight;
    if lAdditionalClientHeight > 0 then
      ClientHeight := ClientHeight + lAdditionalClientHeight;

    DSciLog(Format('Replace dialog layout refreshed (%d x %d)',
      [ClientWidth, ClientHeight]), cDSciLogDebug);
  finally
    FReplaceUpdatingLayout := False;
  end;
end;

// ── Search config accessors ───────────────────────────────────────────────────

function TDSciSearchReplaceDialog.GetSearchConfig: TDSciSearchConfig;
begin
  if (FPageControl <> nil) and (FPageControl.ActivePage = FReplaceTab) then
  begin
    Result.Query := FReplaceSearchCombo.Text;
    Result.MatchCase := FReplaceMatchCaseCheck.Checked;
    Result.WholeWord := FReplaceWholeWordCheck.Checked;
    Result.WrapAround := FReplaceWrapAroundCheck.Checked;
    Result.InSelection := FReplaceInSelectionCheck.Checked;
    if FReplaceExtendedModeRadio.Checked then
      Result.SearchMode := dsmExtended
    else if FReplaceRegexModeRadio.Checked then
      Result.SearchMode := dsmRegularExpression
    else
      Result.SearchMode := dsmNormal;
    Result.ReplaceText := FReplaceWithCombo.Text;
    Result.SearchBackward := False;
    Result.RegexDotMatchesNewline := FReplaceRegexDotNewlineCheck.Checked;
  end
  else
  begin
    Result.Query := FSearchCombo.Text;
    Result.MatchCase := FMatchCaseCheck.Checked;
    Result.WholeWord := FWholeWordCheck.Checked;
    Result.WrapAround := FWrapAroundCheck.Checked;
    Result.InSelection := FInSelectionCheck.Checked;
    if FExtendedModeRadio.Checked then
      Result.SearchMode := dsmExtended
    else if FRegexModeRadio.Checked then
      Result.SearchMode := dsmRegularExpression
    else
      Result.SearchMode := dsmNormal;
    Result.ReplaceText := '';
    Result.SearchBackward := False;
    Result.RegexDotMatchesNewline :=
      (FRegexDotNewlineCheck <> nil) and FRegexDotNewlineCheck.Checked;
  end;
end;

// ── Mode setters ──────────────────────────────────────────────────────────────

procedure TDSciSearchReplaceDialog.SetSearchMode(AMode: TDSciSearchMode);
begin
  FNormalModeRadio.Checked := AMode = dsmNormal;
  FExtendedModeRadio.Checked := AMode = dsmExtended;
  FRegexModeRadio.Checked := AMode = dsmRegularExpression;
  if FRegexDotNewlineCheck <> nil then
    FRegexDotNewlineCheck.Enabled := AMode = dsmRegularExpression;
end;

procedure TDSciSearchReplaceDialog.SetReplaceSearchMode(AMode: TDSciSearchMode);
begin
  FReplaceNormalModeRadio.Checked := AMode = dsmNormal;
  FReplaceExtendedModeRadio.Checked := AMode = dsmExtended;
  FReplaceRegexModeRadio.Checked := AMode = dsmRegularExpression;
  FReplaceRegexDotNewlineCheck.Enabled := AMode = dsmRegularExpression;
end;

// ── ReadOnly ──────────────────────────────────────────────────────────────────

procedure TDSciSearchReplaceDialog.SetReadOnly(AValue: Boolean);
begin
  if FReadOnly = AValue then
    Exit;
  FReadOnly := AValue;
  DSciLog(Format('[DSCI-DIALOG] ReadOnly → %s.', [BoolToStr(AValue, True)]),
    cDSciLogDebug);
  UpdateReplaceButtonStates;
end;

procedure TDSciSearchReplaceDialog.UpdateReplaceButtonStates;
begin
  if (FReplaceButton = nil) or (FReplaceAllButton = nil) then
    Exit;
  FReplaceButton.Enabled := not FReadOnly;
  FReplaceAllButton.Enabled := not FReadOnly;
end;

// ── Tab synchronization ───────────────────────────────────────────────────────

procedure TDSciSearchReplaceDialog.SyncFindToReplace;
var
  lMode: TDSciSearchMode;
begin
  if FUpdatingSync then
    Exit;
  FUpdatingSync := True;
  try
    FReplaceSearchCombo.Text := FSearchCombo.Text;
    FReplaceMatchCaseCheck.Checked := FMatchCaseCheck.Checked;
    FReplaceWholeWordCheck.Checked := FWholeWordCheck.Checked;
    FReplaceWrapAroundCheck.Checked := FWrapAroundCheck.Checked;
    FReplaceInSelectionCheck.Checked := FInSelectionCheck.Checked;
    if FExtendedModeRadio.Checked then
      lMode := dsmExtended
    else if FRegexModeRadio.Checked then
      lMode := dsmRegularExpression
    else
      lMode := dsmNormal;
    SetReplaceSearchMode(lMode);
    FReplaceRegexDotNewlineCheck.Checked :=
      (FRegexDotNewlineCheck <> nil) and FRegexDotNewlineCheck.Checked;
  finally
    FUpdatingSync := False;
  end;
end;

procedure TDSciSearchReplaceDialog.SyncReplaceToFind;
var
  lMode: TDSciSearchMode;
begin
  if FUpdatingSync then
    Exit;
  FUpdatingSync := True;
  try
    FSearchCombo.Text := FReplaceSearchCombo.Text;
    FMatchCaseCheck.Checked := FReplaceMatchCaseCheck.Checked;
    FWholeWordCheck.Checked := FReplaceWholeWordCheck.Checked;
    FWrapAroundCheck.Checked := FReplaceWrapAroundCheck.Checked;
    FInSelectionCheck.Checked := FReplaceInSelectionCheck.Checked;
    if FReplaceExtendedModeRadio.Checked then
      lMode := dsmExtended
    else if FReplaceRegexModeRadio.Checked then
      lMode := dsmRegularExpression
    else
      lMode := dsmNormal;
    SetSearchMode(lMode);
    if FRegexDotNewlineCheck <> nil then
    begin
      FRegexDotNewlineCheck.Checked := FReplaceRegexDotNewlineCheck.Checked;
      FRegexDotNewlineCheck.Enabled := FRegexModeRadio.Checked;
    end;
  finally
    FUpdatingSync := False;
  end;
end;

procedure TDSciSearchReplaceDialog.PageControlChange(Sender: TObject);
begin
  if FPageControl.ActivePage = FReplaceTab then
  begin
    SyncFindToReplace;
    RefreshReplaceLayout;
    DSciLog('[DSCI-DIALOG] Switched to Replace tab.', cDSciLogDebug);
  end
  else
  begin
    SyncReplaceToFind;
    DSciLog('[DSCI-DIALOG] Switched to Find tab.', cDSciLogDebug);
  end;
end;

// ── Action dispatch ───────────────────────────────────────────────────────────

procedure TDSciSearchReplaceDialog.DispatchAction(AAction: TDSciFindDialogAction);
begin
  if Assigned(FOnExecuteSearch) then
    FOnExecuteSearch(Self, SearchConfig, AAction);
end;

// ── Find tab button handlers ──────────────────────────────────────────────────

procedure TDSciSearchReplaceDialog.FindNextButtonClick(Sender: TObject);
begin
  DispatchAction(fdaFindNext);
end;

procedure TDSciSearchReplaceDialog.FindPreviousButtonClick(Sender: TObject);
begin
  DispatchAction(fdaFindPrevious);
end;

procedure TDSciSearchReplaceDialog.CountButtonClick(Sender: TObject);
begin
  DispatchAction(fdaCount);
end;

procedure TDSciSearchReplaceDialog.FindAllButtonClick(Sender: TObject);
begin
  DispatchAction(fdaFindAll);
end;

procedure TDSciSearchReplaceDialog.MarkAllButtonClick(Sender: TObject);
begin
  DispatchAction(fdaMarkAllBookmarks);
end;

procedure TDSciSearchReplaceDialog.CloseButtonClick(Sender: TObject);
begin
  Hide;
end;

// ── Replace tab button handlers ───────────────────────────────────────────────

procedure TDSciSearchReplaceDialog.SwapButtonClick(Sender: TObject);
var
  lTemp: string;
begin
  lTemp := FReplaceSearchCombo.Text;
  FReplaceSearchCombo.Text := FReplaceWithCombo.Text;
  FReplaceWithCombo.Text := lTemp;
  FSearchCombo.Text := FReplaceSearchCombo.Text;
  DSciLog('[DSCI-DIALOG] Swapped Find/Replace texts.', cDSciLogDebug);
end;

procedure TDSciSearchReplaceDialog.ReplaceFindPreviousButtonClick(Sender: TObject);
begin
  DispatchAction(fdaFindPrevious);
end;

procedure TDSciSearchReplaceDialog.ReplaceFindNextButtonClick(Sender: TObject);
begin
  DispatchAction(fdaFindNext);
end;

procedure TDSciSearchReplaceDialog.ReplaceButtonClick(Sender: TObject);
begin
  if FReadOnly then
  begin
    DSciLog('[DSCI-DIALOG] Replace blocked: editor is read-only.', cDSciLogInfo);
    Exit;
  end;
  AddReplaceHistory(FReplaceWithCombo.Text);
  DispatchAction(fdaReplace);
end;

procedure TDSciSearchReplaceDialog.ReplaceAllButtonClick(Sender: TObject);
begin
  if FReadOnly then
  begin
    DSciLog('[DSCI-DIALOG] Replace All blocked: editor is read-only.', cDSciLogInfo);
    Exit;
  end;
  AddReplaceHistory(FReplaceWithCombo.Text);
  DispatchAction(fdaReplaceAll);
end;

procedure TDSciSearchReplaceDialog.ReplaceCloseButtonClick(Sender: TObject);
begin
  Hide;
end;

procedure TDSciSearchReplaceDialog.ReplaceRegexModeChanged(Sender: TObject);
begin
  FReplaceRegexDotNewlineCheck.Enabled := FReplaceRegexModeRadio.Checked;
end;

procedure TDSciSearchReplaceDialog.FindRegexModeChanged(Sender: TObject);
begin
  if FRegexDotNewlineCheck <> nil then
    FRegexDotNewlineCheck.Enabled := FRegexModeRadio.Checked;
end;

// ── Dialog-level keyboard / close ─────────────────────────────────────────────

procedure TDSciSearchReplaceDialog.DialogClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TDSciSearchReplaceDialog.DialogKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      begin
        if ssShift in Shift then
          DispatchAction(fdaFindPrevious)
        else
          DispatchAction(fdaFindNext);
        Key := 0;
      end;
    VK_ESCAPE:
      begin
        Hide;
        Key := 0;
      end;
  end;
end;

// ── Public API ────────────────────────────────────────────────────────────────

procedure TDSciSearchReplaceDialog.AddSearchHistory(const AText: string);
var
  lIndex: Integer;
begin
  if Trim(AText) = '' then
    Exit;
  lIndex := FSearchCombo.Items.IndexOf(AText);
  if lIndex >= 0 then
    FSearchCombo.Items.Delete(lIndex);
  FSearchCombo.Items.Insert(0, AText);

  lIndex := FReplaceSearchCombo.Items.IndexOf(AText);
  if lIndex >= 0 then
    FReplaceSearchCombo.Items.Delete(lIndex);
  FReplaceSearchCombo.Items.Insert(0, AText);
end;

procedure TDSciSearchReplaceDialog.AddReplaceHistory(const AText: string);
var
  lIndex: Integer;
begin
  if Trim(AText) = '' then
    Exit;
  lIndex := FReplaceWithCombo.Items.IndexOf(AText);
  if lIndex >= 0 then
    FReplaceWithCombo.Items.Delete(lIndex);
  FReplaceWithCombo.Items.Insert(0, AText);
end;

procedure TDSciSearchReplaceDialog.ApplySearchConfig(const AConfig: TDSciSearchConfig);
begin
  FSearchCombo.Text := AConfig.Query;
  FMatchCaseCheck.Checked := AConfig.MatchCase;
  FWholeWordCheck.Checked := AConfig.WholeWord;
  FWrapAroundCheck.Checked := AConfig.WrapAround;
  FInSelectionCheck.Checked := AConfig.InSelection;
  SetSearchMode(AConfig.SearchMode);

  FReplaceSearchCombo.Text := AConfig.Query;
  FReplaceMatchCaseCheck.Checked := AConfig.MatchCase;
  FReplaceWholeWordCheck.Checked := AConfig.WholeWord;
  FReplaceWrapAroundCheck.Checked := AConfig.WrapAround;
  FReplaceInSelectionCheck.Checked := AConfig.InSelection;
  SetReplaceSearchMode(AConfig.SearchMode);

  if AConfig.ReplaceText <> '' then
    FReplaceWithCombo.Text := AConfig.ReplaceText;
  if FRegexDotNewlineCheck <> nil then
    FRegexDotNewlineCheck.Checked := AConfig.RegexDotMatchesNewline;
  FReplaceRegexDotNewlineCheck.Checked := AConfig.RegexDotMatchesNewline;
end;

procedure TDSciSearchReplaceDialog.FocusSearchText;
begin
  if (FPageControl <> nil) and (FPageControl.ActivePage = FReplaceTab) then
  begin
    FReplaceSearchCombo.SetFocus;
    FReplaceSearchCombo.SelectAll;
  end
  else
  begin
    FSearchCombo.SetFocus;
    FSearchCombo.SelectAll;
  end;
end;

procedure TDSciSearchReplaceDialog.SetMatchSummary(const ASummary: string);
begin
  FResultLabel.Caption := ASummary;
  FReplaceResultLabel.Caption := ASummary;
end;

procedure TDSciSearchReplaceDialog.ShowFindTab;
begin
  FPageControl.ActivePage := FFindTab;
end;

procedure TDSciSearchReplaceDialog.ShowReplaceTab;
begin
  FPageControl.ActivePage := FReplaceTab;
  SyncFindToReplace;
  RefreshReplaceLayout;
end;

end.
