unit DOSrcVwrViewerFrame;

{$R-}{$Q-}

interface

uses
  System.Types, System.Classes, System.Generics.Collections,
  Winapi.Windows, Winapi.Messages,

  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,

  DScintilla, DScintillaTypes, DScintillaSearchReplaceDLG, DScintillaGotoDLG,
  DScintillaVisualConfig, DScintillaVisualSettingsDLG,
  DOpusViewerPlugins;

type
  TDSciSearchMatch = record
    StartPos: NativeInt;
    EndPos: NativeInt;
  end;

  TDOSrcVwrViewerFrame = class(TCustomControl)
  private const
    cLineNumberMargin = 0;
    cBookmarkMargin = 1;
    cFoldMargin = 2;
    cBookmarkMarker = 2;
    cBookmarkMask = 1 shl cBookmarkMarker;
    cFoldMask = -33554432; // SC_MASK_FOLDERS
    cSearchIndicator = 0;
    cOccurrenceIndicator = 1;
    cHighlightSelectionMatchesMessage = WM_APP + 1;
  private
    FParentOpusWnd: HWND;
    FFlags: DWORD;
    FEditor: TDScintilla;
    FConfigFileName: string;
    FCurrentFileName: string;
    FHighlightedIdentifier: string;
    FAbortEvent: THandle;
    // Inline search bar
    FSearchPanel: TPanel;
    FSearchRowPanel: TPanel;
    FSearchOptionsPanel: TPanel;
    FSearchEdit: TEdit;
    FSearchCaseCheck: TCheckBox;
    FSearchWholeWordCheck: TCheckBox;
    FSearchPrevButton: TButton;
    FSearchNextButton: TButton;
    FSearchCancelButton: TButton;
    FSearchStatusLabel: TLabel;
    // Find dialog
    FFindDialog: TDSciFindDialog;
    // Goto dialog (non-nil only while OpenGotoDialog is executing)
    FGotoDialog: TDSciGotoDialog;
    // Settings dialog (modeless, owned; non-nil while open)
    FSettingsDialog: TDSciVisualSettingsDialog;
    // Set to True at the very start of Destroy to guard all callbacks
    FDestroying: Boolean;
    // Search state
    FSearchMatches: TList<TDSciSearchMatch>;
    FCurrentSearchIndex: Integer;
    FActiveSearchConfig: TDSciSearchConfig;
    FHasActiveSearchConfig: Boolean;
    FUpdatingSearchControls: Boolean;
    class function ScaleDpi(AValue: Integer): Integer; static;
    procedure ConfigureEditorSurface;
    procedure ConfigureBookmarkMarker;
    procedure ConfigureFoldMarkers;
    procedure ConfigureOccurrenceIndicator;
    procedure ConfigureSearchIndicator;
    procedure ApplyFoldProperties;
    procedure ReapplyEditorPresentation;
    procedure UpdateLineNumberMarginWidth;
    procedure BuildSearchBar;
    procedure ResolveAndLoadConfig;

    // Search operations
    procedure ExecuteSearch(const AConfig: TDSciSearchConfig; APreferNearestToCaret: Boolean; ASelectResult: Boolean = True);
    procedure UpdateSearch(APreferNearestToCaret: Boolean);
    procedure ClearSearchHighlights;
    procedure SelectSearchResult(AIndex: Integer);
    function SelectRelativeSearchResult(ADelta: Integer; AWrapAround: Boolean = True): Boolean;
    function FindNearestSearchResultIndex(ACaretPos: NativeInt): Integer;
    function BuildInlineSearchConfig: TDSciSearchConfig;
    function BuildSearchFlags(const AConfig: TDSciSearchConfig): TDSciFindOptionSet;
    function SameSearchConfig(const ALeft, ARight: TDSciSearchConfig): Boolean;
    function ExtractSearchWordFromSelection: string;
    function IsIdentifierText(const AText: string): Boolean;
    procedure ClearOccurrenceHighlights;
    procedure HighlightIdentifierOccurrences(const AIdentifier: string);
    procedure ToggleBookmarkAtLine(ALine: NativeInt);
    // Editor event handlers
    procedure EditorDblClick(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditorMarginClick(ASender: TObject; AModifiers: Integer; APosition: NativeInt; AMargin: Integer);
    procedure EditorChanged(Sender: TObject);
    procedure WMHighlightSelectionMatches(var AMessage: TMessage); message cHighlightSelectionMatchesMessage;
    procedure SyncFindDialogSummary(const ASummary: string);
    procedure EnsureFindDialog;
    // Settings dialog helpers
    function GetDialogOwnerWnd: HWND;
    procedure SettingsApplyConfig(AConfig: TDSciVisualConfig);
    procedure SettingsDialogDestroy(Sender: TObject);
    // Search bar event handlers
    procedure SearchEditChange(Sender: TObject);
    procedure SearchEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchOptionClick(Sender: TObject);
    procedure SearchPrevButtonClick(Sender: TObject);
    procedure SearchNextButtonClick(Sender: TObject);
    procedure SearchCancelButtonClick(Sender: TObject);
    // Context menu
    procedure EditorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ShowEditorContextMenu(const AScreenPoint: TPoint);
    // Find dialog callback
    procedure ExecuteFindDialogAction(Sender: TObject; const AConfig: TDSciSearchConfig; AAction: TDSciFindDialogAction);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Resize; override;
  public
    constructor CreateForOpus(AParentWnd: HWND; ARect: PRECT; AFlags: DWORD);
    destructor Destroy; override;
    function LoadFile(const AFileName: string): Boolean;
    procedure ClearContent;
    procedure ReloadConfig;
    procedure OpenInlineSearch;
    procedure CloseInlineSearch;
    procedure OpenFindDialog;
    procedure OpenGotoDialog;
    procedure OpenSettingsDialog;
    procedure HandleKeyDown(var Key: Word; Shift: TShiftState);
    function FindDialogHandle: HWND;
    procedure CancelAndFreeDialogs;
    { Set FDestroying and cancel all dialogs. Called from WM_DESTROY (before
      the frame object is freed in WM_NCDESTROY) so that the FDestroying flag
      is active during the window between WM_DESTROY and the destructor. }
    procedure BeginDestroying;
    property ParentOpusWnd: HWND read FParentOpusWnd;
    property Flags: DWORD read FFlags;
    property Editor: TDScintilla read FEditor;
    property CurrentFileName: string read FCurrentFileName;
    property ConfigFileName: string read FConfigFileName;
    property AbortEvent: THandle read FAbortEvent write FAbortEvent;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.Math, System.Character,

  DOpusPluginHelpers,
  DOSrcVwrLog, DOSrcVwrRuntime, DOSrcVwrHost;

function GetOwnDllDir: string;
var
  LBuf: array[0..MAX_PATH] of Char;
  LModule: HMODULE;
begin
  LModule := FindClassHInstance(TDOSrcVwrViewerFrame);
  SetString(Result, LBuf, GetModuleFileName(LModule, LBuf, Length(LBuf)));
  Result := ExtractFilePath(Result);
end;

function MatchSummary(ACount: Integer): string;
begin
  if ACount = 1 then
    Result := '1 match'
  else
    Result := Format('%d matches', [ACount]);
end;

constructor TDOSrcVwrViewerFrame.CreateForOpus(AParentWnd: HWND; ARect: PRECT; AFlags: DWORD);
begin
  LogInfo('ViewerFrame.CreateForOpus: enter Parent=$%x Flags=$%x', [AParentWnd, AFlags]);
  FParentOpusWnd := AParentWnd;
  FFlags := AFlags;
  FSearchMatches := TList<TDSciSearchMatch>.Create;
  FCurrentSearchIndex := -1;
  LogInfo('ViewerFrame: calling inherited CreateParented...');
  inherited CreateParented(AParentWnd);
  LogInfo('ViewerFrame: CreateParented done, Handle=$%x', [Handle]);
  if ARect <> nil then
    SetBounds(ARect^.Left, ARect^.Top,
      ARect^.Right - ARect^.Left, ARect^.Bottom - ARect^.Top);

  LogInfo('ViewerFrame: building search bar...');
  BuildSearchBar;

  LogInfo('ViewerFrame: creating TDScintilla...');
  FEditor := TDScintilla.Create(Self);

  // Set full path to Scintilla DLL next to our plugin DLL,
  // because Opus loads us from its own working directory.
  // MUST be set before Parent assignment which triggers HandleNeeded.
  FEditor.DllModule := GetOwnDllDir + 'Scintilla64.dll';
  LogInfo('ViewerFrame: DllModule=%s', [FEditor.DllModule]);

  FEditor.Parent := Self;
  FEditor.Align := alClient;

  LogInfo('ViewerFrame: calling HandleNeeded...');
  FEditor.HandleNeeded;
  LogInfo('ViewerFrame: Scintilla Handle=$%x', [FEditor.Handle]);
  LogInfo('ViewerFrame: configuring editor surface...');
  ConfigureEditorSurface;
  ConfigureSearchIndicator;

  LogInfo('ViewerFrame: loading config...');
  ResolveAndLoadConfig;

  FEditor.ReadOnly := True;

  LogInfo('ViewerFrame: created OK');
end;

destructor TDOSrcVwrViewerFrame.Destroy;
begin
  LogInfo('ViewerFrame.Destroy: enter');
  if not FDestroying then
    BeginDestroying;
  FSearchMatches.Free;
  FreeAndNil(FEditor);
  LogInfo('ViewerFrame.Destroy: done');
  inherited;
end;

procedure TDOSrcVwrViewerFrame.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN;
  if (FFlags and DVPCVF_Border) <> 0 then
    Params.ExStyle := Params.ExStyle or WS_EX_CLIENTEDGE;
end;

procedure TDOSrcVwrViewerFrame.Resize;
begin
  inherited;
  if Assigned(FEditor) then
    UpdateLineNumberMarginWidth;
end;

{ Editor setup }

class function TDOSrcVwrViewerFrame.ScaleDpi(AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, Screen.PixelsPerInch, 96);
end;

procedure TDOSrcVwrViewerFrame.ConfigureEditorSurface;
begin
  FEditor.UseDefaultContextMenu := False;
  FEditor.OnMouseUp := EditorMouseUp;
  FEditor.OnDblClick := EditorDblClick;
  FEditor.OnKeyDown := EditorKeyDown;
  FEditor.OnMarginClick := EditorMarginClick;
  FEditor.OnChange := EditorChanged;

  ApplyFoldProperties;
  ConfigureBookmarkMarker;
  ConfigureFoldMarkers;
  ConfigureOccurrenceIndicator;

  FEditor.MarginTypeN[cLineNumberMargin] := scmtNUMBER;
  FEditor.MarginSensitiveN[cLineNumberMargin] := False;
  UpdateLineNumberMarginWidth;

  FEditor.MarginTypeN[cBookmarkMargin] := scmtSYMBOL;
  FEditor.MarginMaskN[cBookmarkMargin] := cBookmarkMask;
  FEditor.MarginSensitiveN[cBookmarkMargin] := True;
  FEditor.MarginWidthN[cBookmarkMargin] := 18;

  FEditor.MarginTypeN[cFoldMargin] := scmtSYMBOL;
  FEditor.MarginMaskN[cFoldMargin] := cFoldMask;
  FEditor.MarginSensitiveN[cFoldMargin] := True;
  FEditor.MarginWidthN[cFoldMargin] := 20;
end;

procedure TDOSrcVwrViewerFrame.ApplyFoldProperties;
begin
  FEditor.SetProperty('fold', '1');
  FEditor.SetProperty('fold.compact', '1');
  FEditor.SetProperty('fold.comment', '1');
  FEditor.SetProperty('fold.preprocessor', '1');
  FEditor.SetProperty('fold.html', '1');
  FEditor.SetProperty('fold.xml', '1');
end;

procedure TDOSrcVwrViewerFrame.ReapplyEditorPresentation;
begin
  ApplyFoldProperties;
  ConfigureBookmarkMarker;
  ConfigureFoldMarkers;
  ConfigureOccurrenceIndicator;
  ConfigureSearchIndicator;
  if Assigned(FEditor) then
    FEditor.RefreshManagedStatusBar;
end;


procedure TDOSrcVwrViewerFrame.ConfigureBookmarkMarker;
begin
  FEditor.MarkerDefine(cBookmarkMarker, scmsBOOKMARK);
  FEditor.MarkerFore[cBookmarkMarker] := $FFFFFF; // white
  FEditor.MarkerBack[cBookmarkMarker] := $0080FF; // orange highlight
end;

procedure TDOSrcVwrViewerFrame.ConfigureFoldMarkers;
begin
  FEditor.MarkerDefine(SC_MARKNUM_FOLDEROPEN, scmsBOX_MINUS);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDER, scmsBOX_PLUS);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDERSUB, scmsV_LINE);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDERTAIL, scmsL_CORNER);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDEREND, scmsBOX_PLUS_CONNECTED);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDEROPENMID, scmsBOX_MINUS_CONNECTED);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDERMIDTAIL, scmsT_CORNER);
end;

procedure TDOSrcVwrViewerFrame.ConfigureSearchIndicator;
begin
  FEditor.IndicStyle[cSearchIndicator] := scisROUND_BOX;
  FEditor.IndicFore[cSearchIndicator] := $0080FF;  // Orange highlight
  FEditor.IndicUnder[cSearchIndicator] := False;
  FEditor.IndicSetAlphaValue(cSearchIndicator, 80);
  FEditor.IndicSetOutlineAlphaValue(cSearchIndicator, 200);
end;

procedure TDOSrcVwrViewerFrame.ConfigureOccurrenceIndicator;
begin
  FEditor.IndicStyle[cOccurrenceIndicator] := scisROUND_BOX;
  FEditor.IndicFore[cOccurrenceIndicator] := $0080FF;
  FEditor.IndicUnder[cOccurrenceIndicator] := True;
  FEditor.IndicSetAlphaValue(cOccurrenceIndicator, 60);
  FEditor.IndicSetOutlineAlphaValue(cOccurrenceIndicator, 180);
end;

procedure TDOSrcVwrViewerFrame.UpdateLineNumberMarginWidth;
var
  LConfig: TObject;
  LLineCount: NativeInt;
  LDigits: Integer;
  LWidth: Integer;
begin
  if not Assigned(FEditor) then
    Exit;
  // Honour the line-numbering visibility set by ApplyConfigLineNumbering.
  // When line numbers are disabled the settings system sets width=0; do not
  // override that with a computed positive value.
  if FEditor.Settings.GetCurrentConfig(LConfig) and
     not (LConfig as TDSciVisualConfig).LineNumbering then
  begin
    LogInfo('UpdateLineNumberMarginWidth: line numbering disabled, skipping');
    Exit;
  end;
  LLineCount := FEditor.LineCount;
  LDigits := 1;
  while LLineCount >= 10 do
  begin
    Inc(LDigits);
    LLineCount := LLineCount div 10;
  end;
  if LDigits < 4 then
    LDigits := 4;
  LWidth := FEditor.TextWidth(STYLE_LINENUMBER, StringOfChar('9', LDigits + 1));
  FEditor.MarginWidthN[cLineNumberMargin] := LWidth;
end;

procedure TDOSrcVwrViewerFrame.ResolveAndLoadConfig;
begin
  FConfigFileName := PluginHelper.ConfigFile;
  LogInfo('ViewerFrame.ResolveAndLoadConfig: %s', [FConfigFileName]);
  try
    PluginHelper.EnsureConfigFile;
    FEditor.Settings.LoadConfigFile(FConfigFileName);
    ReapplyEditorPresentation;
    LogInfo('ViewerFrame.ResolveAndLoadConfig: loaded OK');
  except
    on E: Exception do
      LogError('ViewerFrame.ResolveAndLoadConfig FAILED: %s', [E.Message]);
  end;
end;

{ Context menu }

procedure TDOSrcVwrViewerFrame.EditorMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LScreenPt: TPoint;
begin
  if Button = mbRight then
  begin
    { TDScintilla.WMRButtonUp shows FGutterContextMenu for margin-area clicks
      BEFORE calling inherited (which fires this OnMouseUp). Suppress the
      viewer's own context menu for margin clicks so only one popup appears. }
    if not FEditor.IsPointInMarginArea(Point(X, Y)) then
    begin
      LScreenPt := FEditor.ClientToScreen(Point(X, Y));
      ShowEditorContextMenu(LScreenPt);
    end;
  end;
end;

procedure TDOSrcVwrViewerFrame.ShowEditorContextMenu(const AScreenPoint: TPoint);
const
  cCmdCopy = 1;
  cCmdCopyHtml = 2;
  cCmdSelectAll = 3;
  cCmdFind = 4;
  cCmdSettings = 5;
  cCmdFoldAll = 10;
  cCmdUnfoldAll = 11;
  cCmdFoldCurrent = 12;
  cCmdUnfoldCurrent = 13;
  cCmdFoldNested = 14;
  cCmdUnfoldNested = 15;
var
  LMenu: HMENU;
  LFoldMenu: HMENU;
  LCmd: UINT;
  LCopyFlags: UINT;
  LCurLine, LFoldHeaderLine: NativeInt;
  LFoldLevel: Integer;
begin
  LMenu := CreatePopupMenu;
  if LMenu = 0 then Exit;
  LFoldMenu := CreatePopupMenu;
  if LFoldMenu = 0 then
  begin
    DestroyMenu(LMenu);
    Exit;
  end;
  try
    if FEditor.SelectionEmpty then
      LCopyFlags := MF_STRING or MF_GRAYED
    else
      LCopyFlags := MF_STRING;

    AppendMenu(LMenu, LCopyFlags, cCmdCopy, 'Copy');
    AppendMenu(LMenu, LCopyFlags, cCmdCopyHtml, 'Copy with Syntax Highlighting');
    AppendMenu(LMenu, MF_STRING, cCmdSelectAll, 'Select All');
    AppendMenu(LMenu, MF_SEPARATOR, 0, nil);
    AppendMenu(LMenu, MF_STRING, cCmdFind, 'Find...');
    AppendMenu(LMenu, MF_STRING, cCmdSettings, 'Editor Settings...');
    AppendMenu(LMenu, MF_SEPARATOR, 0, nil);

    AppendMenu(LFoldMenu, MF_STRING, cCmdFoldAll, 'Fold All');
    AppendMenu(LFoldMenu, MF_STRING, cCmdUnfoldAll, 'Unfold All');
    AppendMenu(LFoldMenu, MF_SEPARATOR, 0, nil);
    AppendMenu(LFoldMenu, MF_STRING, cCmdFoldCurrent, 'Fold Current');
    AppendMenu(LFoldMenu, MF_STRING, cCmdUnfoldCurrent, 'Unfold Current');
    AppendMenu(LFoldMenu, MF_SEPARATOR, 0, nil);
    AppendMenu(LFoldMenu, MF_STRING, cCmdFoldNested, 'Fold Nested');
    AppendMenu(LFoldMenu, MF_STRING, cCmdUnfoldNested, 'Unfold Nested');

    AppendMenu(LMenu, MF_POPUP, UINT_PTR(LFoldMenu), 'Folding');

    LCmd := UINT(TrackPopupMenu(LMenu,
      TPM_RETURNCMD or TPM_RIGHTBUTTON or TPM_NONOTIFY,
      AScreenPoint.X, AScreenPoint.Y, 0, FEditor.Handle, nil));

    LCurLine := FEditor.LineFromPosition(FEditor.CurrentPos);

    case LCmd of
      cCmdCopy:          FEditor.Copy;
      cCmdCopyHtml:      FEditor.CopySelectionAsHtml;
      cCmdSelectAll:     FEditor.SelectAll;
      cCmdFind:          OpenInlineSearch;
      cCmdSettings:      OpenSettingsDialog;
      cCmdFoldAll:       FEditor.FoldAll(scfaCONTRACT_EVERY_LEVEL);
      cCmdUnfoldAll:     FEditor.FoldAll(scfaEXPAND);
      cCmdFoldCurrent, cCmdUnfoldCurrent, cCmdFoldNested, cCmdUnfoldNested:
      begin
        LFoldLevel := FEditor.SendEditor(SCI_GETFOLDLEVEL, WPARAM(LCurLine), 0);
        if (LFoldLevel and SC_FOLDLEVELHEADERFLAG) <> 0 then
          LFoldHeaderLine := LCurLine
        else
          LFoldHeaderLine := FEditor.FoldParent[LCurLine];
        if LFoldHeaderLine >= 0 then
          case LCmd of
            cCmdFoldCurrent:   FEditor.FoldLine(LFoldHeaderLine, scfaCONTRACT);
            cCmdUnfoldCurrent: FEditor.FoldLine(LFoldHeaderLine, scfaEXPAND);
            cCmdFoldNested:    FEditor.FoldChildren(LFoldHeaderLine, scfaCONTRACT);
            cCmdUnfoldNested:  FEditor.FoldChildren(LFoldHeaderLine, scfaEXPAND);
          end;
      end;
    end;
  finally
    DestroyMenu(LMenu);
  end;
end;

{ Search bar UI }

procedure TDOSrcVwrViewerFrame.BuildSearchBar;
begin
  FSearchPanel := TPanel.Create(Self);
  FSearchPanel.Parent := Self;
  FSearchPanel.Align := alBottom;
  FSearchPanel.BevelOuter := bvNone;
  FSearchPanel.Height := ScaleDpi(72);
  FSearchPanel.Visible := False;

  FSearchRowPanel := TPanel.Create(Self);
  FSearchRowPanel.Parent := FSearchPanel;
  FSearchRowPanel.Align := alTop;
  FSearchRowPanel.BevelOuter := bvNone;
  FSearchRowPanel.Height := ScaleDpi(36);
  FSearchRowPanel.Padding.Left := ScaleDpi(6);
  FSearchRowPanel.Padding.Top := ScaleDpi(4);
  FSearchRowPanel.Padding.Right := ScaleDpi(6);

  { Row 1 right to left (alRight): last created → rightmost.
    Visual order left→right: [Edit][▲][▼][×] }
  FSearchPrevButton := TButton.Create(Self);
  FSearchPrevButton.Parent := FSearchRowPanel;
  FSearchPrevButton.AlignWithMargins := True;
  FSearchPrevButton.Align := alRight;
  FSearchPrevButton.Caption := #$25B2; // ▲ prev
  FSearchPrevButton.Hint := 'Find Previous (Shift+F3)';
  FSearchPrevButton.ShowHint := True;
  FSearchPrevButton.Width := ScaleDpi(36);
  FSearchPrevButton.OnClick := SearchPrevButtonClick;

  FSearchNextButton := TButton.Create(Self);
  FSearchNextButton.Parent := FSearchRowPanel;
  FSearchNextButton.AlignWithMargins := True;
  FSearchNextButton.Align := alRight;
  FSearchNextButton.Caption := #$25BC; // ▼ next
  FSearchNextButton.Hint := 'Find Next (F3)';
  FSearchNextButton.ShowHint := True;
  FSearchNextButton.Width := ScaleDpi(36);
  FSearchNextButton.OnClick := SearchNextButtonClick;

  FSearchCancelButton := TButton.Create(Self);
  FSearchCancelButton.Parent := FSearchRowPanel;
  FSearchCancelButton.AlignWithMargins := True;
  FSearchCancelButton.Align := alRight;
  FSearchCancelButton.Caption := #$00D7; // × close
  FSearchCancelButton.Hint := 'Close (Esc)';
  FSearchCancelButton.ShowHint := True;
  FSearchCancelButton.Width := ScaleDpi(36);
  FSearchCancelButton.OnClick := SearchCancelButtonClick;

  FSearchEdit := TEdit.Create(Self);
  FSearchEdit.Parent := FSearchRowPanel;
  FSearchEdit.AlignWithMargins := True;
  FSearchEdit.Align := alClient;
  FSearchEdit.TextHint := 'Search...';
  FSearchEdit.OnChange := SearchEditChange;
  FSearchEdit.OnKeyDown := SearchEditKeyDown;

  { Row 2 options panel: checkboxes on left, results label on right. }
  FSearchOptionsPanel := TPanel.Create(Self);
  FSearchOptionsPanel.Parent := FSearchPanel;
  FSearchOptionsPanel.Align := alClient;
  FSearchOptionsPanel.BevelOuter := bvNone;
  FSearchOptionsPanel.Padding.Left := ScaleDpi(6);
  FSearchOptionsPanel.Padding.Right := ScaleDpi(6);

  FSearchStatusLabel := TLabel.Create(Self);
  FSearchStatusLabel.Parent := FSearchOptionsPanel;
  FSearchStatusLabel.AlignWithMargins := True;
  FSearchStatusLabel.Align := alRight;
  FSearchStatusLabel.Alignment := taRightJustify;
  FSearchStatusLabel.AutoSize := False;
  FSearchStatusLabel.Width := ScaleDpi(90);
  FSearchStatusLabel.Layout := tlCenter;
  FSearchStatusLabel.Caption := '';

  FSearchCaseCheck := TCheckBox.Create(Self);
  FSearchCaseCheck.Parent := FSearchOptionsPanel;
  FSearchCaseCheck.AlignWithMargins := True;
  FSearchCaseCheck.Align := alLeft;
  FSearchCaseCheck.Caption := 'Match case';
  FSearchCaseCheck.Width := ScaleDpi(100);
  FSearchCaseCheck.OnClick := SearchOptionClick;

  FSearchWholeWordCheck := TCheckBox.Create(Self);
  FSearchWholeWordCheck.Parent := FSearchOptionsPanel;
  FSearchWholeWordCheck.AlignWithMargins := True;
  FSearchWholeWordCheck.Align := alLeft;
  FSearchWholeWordCheck.Caption := 'Whole words';
  FSearchWholeWordCheck.Width := ScaleDpi(110);
  FSearchWholeWordCheck.OnClick := SearchOptionClick;
end;

{ File operations }

function TDOSrcVwrViewerFrame.LoadFile(const AFileName: string): Boolean;
begin
  LogInfo('ViewerFrame.LoadFile: %s', [AFileName]);
  Result := False;
  if not TFile.Exists(AFileName) then
  begin
    LogError('ViewerFrame.LoadFile: file not found');
    Exit;
  end;

  try
    Result := FEditor.LoadFromFile(AFileName);
    if not Result then
    begin
      LogError('ViewerFrame.LoadFile: FEditor.LoadFromFile returned False');
      Exit;
    end;

    ReapplyEditorPresentation;
    FEditor.ReadOnly := True;
    FEditor.GotoPos(0);
    UpdateLineNumberMarginWidth;

    FCurrentFileName := FEditor.CurrentFileName;
    LogInfo('ViewerFrame.LoadFile: OK (%d chars)', [FEditor.TextLength]);
  except
    on E: Exception do
    begin
      LogError('ViewerFrame.LoadFile FAILED: %s', [E.Message]);
      FEditor.ReadOnly := True;
    end;
  end;
end;

procedure TDOSrcVwrViewerFrame.ClearContent;
begin
  FEditor.ReadOnly := False;
  FEditor.ClearAll;
  FEditor.ReadOnly := True;
  FCurrentFileName := '';
  ClearSearchHighlights;
end;

procedure TDOSrcVwrViewerFrame.ReloadConfig;
begin
  LogInfo('ViewerFrame.ReloadConfig');
  try
    FEditor.Settings.LoadConfigFile(FConfigFileName);
    ReapplyEditorPresentation;
    if FCurrentFileName <> '' then
    begin
      FEditor.ReapplyPreferredLanguageSelection;
      FEditor.Colourise(0, -1);
    end;
    LogInfo('ViewerFrame.ReloadConfig: done');
  except
    on E: Exception do
      LogError('ViewerFrame.ReloadConfig FAILED: %s', [E.Message]);
  end;
end;

{ Search operations }

procedure TDOSrcVwrViewerFrame.ClearSearchHighlights;
begin
  FEditor.IndicatorCurrent := cSearchIndicator;
  FEditor.IndicatorClearRange(0, FEditor.TextLength);
  FSearchMatches.Clear;
  FCurrentSearchIndex := -1;
end;

function TDOSrcVwrViewerFrame.BuildInlineSearchConfig: TDSciSearchConfig;
begin
  Result.Query := FSearchEdit.Text;
  Result.MatchCase := FSearchCaseCheck.Checked;
  Result.WholeWord := FSearchWholeWordCheck.Checked;
  Result.WrapAround := True;
  Result.InSelection := False;
  Result.SearchMode := dsmNormal;
end;

function TDOSrcVwrViewerFrame.BuildSearchFlags(
  const AConfig: TDSciSearchConfig): TDSciFindOptionSet;
begin
  Result := [];
  if AConfig.MatchCase then
    Include(Result, scfoMATCH_CASE);
  if AConfig.WholeWord then
    Include(Result, scfoWHOLE_WORD);
  if AConfig.SearchMode = dsmRegularExpression then
    Include(Result, scfoREG_EXP);
end;

function TDOSrcVwrViewerFrame.SameSearchConfig(
  const ALeft, ARight: TDSciSearchConfig): Boolean;
begin
  Result :=
    (ALeft.Query = ARight.Query) and
    (ALeft.MatchCase = ARight.MatchCase) and
    (ALeft.WholeWord = ARight.WholeWord) and
    (ALeft.WrapAround = ARight.WrapAround) and
    (ALeft.InSelection = ARight.InSelection) and
    (ALeft.SearchMode = ARight.SearchMode);
end;

function TDOSrcVwrViewerFrame.ExtractSearchWordFromSelection: string;
begin
  Result := Trim(FEditor.GetSelText);
  if (Result = '') or (Pos(#13, Result) > 0) or (Pos(#10, Result) > 0) or
     (Pos(#9, Result) > 0) then
    Result := '';
end;

function TDOSrcVwrViewerFrame.FindNearestSearchResultIndex(
  ACaretPos: NativeInt): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FSearchMatches.Count - 1 do
    if (FSearchMatches[I].StartPos <= ACaretPos) and
       (FSearchMatches[I].EndPos >= ACaretPos) then
      Exit(I);

  for I := 0 to FSearchMatches.Count - 1 do
    if FSearchMatches[I].StartPos >= ACaretPos then
      Exit(I);

  if FSearchMatches.Count > 0 then
    Result := 0;
end;

procedure TDOSrcVwrViewerFrame.SelectSearchResult(AIndex: Integer);
var
  LMatch: TDSciSearchMatch;
begin
  if (AIndex < 0) or (AIndex >= FSearchMatches.Count) then
    Exit;

  FCurrentSearchIndex := AIndex;
  LMatch := FSearchMatches[AIndex];
  FEditor.SetSelection(LMatch.EndPos, LMatch.StartPos);
  FEditor.ScrollCaret;
  FSearchStatusLabel.Caption := Format('%d / %d', [AIndex + 1, FSearchMatches.Count]);
  SyncFindDialogSummary(FSearchStatusLabel.Caption);
end;

function TDOSrcVwrViewerFrame.SelectRelativeSearchResult(ADelta: Integer;
  AWrapAround: Boolean): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  if FSearchMatches.Count = 0 then
    Exit;

  if FCurrentSearchIndex < 0 then
    LIndex := FindNearestSearchResultIndex(FEditor.CurrentPos)
  else
    LIndex := FCurrentSearchIndex;

  Inc(LIndex, ADelta);
  if AWrapAround then
    LIndex := (LIndex + FSearchMatches.Count) mod FSearchMatches.Count
  else if (LIndex < 0) or (LIndex >= FSearchMatches.Count) then
    Exit;

  SelectSearchResult(LIndex);
  Result := True;
end;

procedure TDOSrcVwrViewerFrame.ExecuteSearch(const AConfig: TDSciSearchConfig;
  APreferNearestToCaret: Boolean; ASelectResult: Boolean);
var
  LQuery: string;
  LRangeStart, LRangeEnd: NativeInt;
  LMatchStart: NativeInt;
  LMatch: TDSciSearchMatch;
  LSelectedIndex: Integer;
begin
  FActiveSearchConfig := AConfig;
  FHasActiveSearchConfig := AConfig.Query <> '';
  ClearSearchHighlights;

  LQuery := AConfig.Query;
  if LQuery = '' then
  begin
    FHasActiveSearchConfig := False;
    FSearchStatusLabel.Caption := '';
    SyncFindDialogSummary('0 matches');
    Exit;
  end;

  if AConfig.InSelection then
  begin
    LRangeStart := FEditor.SelectionStart;
    LRangeEnd := FEditor.SelectionEnd;
    if LRangeEnd <= LRangeStart then
    begin
      FSearchStatusLabel.Caption := '0 matches';
      SyncFindDialogSummary('Select text first');
      Exit;
    end;
  end
  else
  begin
    LRangeStart := 0;
    LRangeEnd := FEditor.TextLength;
  end;

  FEditor.SearchFlags := BuildSearchFlags(AConfig);
  FEditor.IndicatorCurrent := cSearchIndicator;
  FEditor.IndicatorValue := 1;

  LMatchStart := LRangeStart;
  while LMatchStart <= LRangeEnd do
  begin
    FEditor.TargetStart := LMatchStart;
    FEditor.TargetEnd := LRangeEnd;
    LMatch.StartPos := FEditor.SearchInTarget(LQuery);
    if LMatch.StartPos < 0 then
      Break;

    LMatch.EndPos := FEditor.TargetEnd;
    if LMatch.EndPos <= LMatch.StartPos then
      Break;

    FSearchMatches.Add(LMatch);
    FEditor.IndicatorFillRange(LMatch.StartPos, LMatch.EndPos - LMatch.StartPos);
    LMatchStart := LMatch.EndPos;
  end;

  if FSearchMatches.Count = 0 then
  begin
    FSearchStatusLabel.Caption := '0 matches';
    SyncFindDialogSummary('0 matches');
    Exit;
  end;

  if not ASelectResult then
  begin
    FSearchStatusLabel.Caption := MatchSummary(FSearchMatches.Count);
    SyncFindDialogSummary(FSearchStatusLabel.Caption);
    Exit;
  end;

  if APreferNearestToCaret then
    LSelectedIndex := FindNearestSearchResultIndex(FEditor.CurrentPos)
  else
    LSelectedIndex := 0; // no caret preference start from first match

  SelectSearchResult(LSelectedIndex);
end;

procedure TDOSrcVwrViewerFrame.UpdateSearch(APreferNearestToCaret: Boolean);
begin
  ExecuteSearch(BuildInlineSearchConfig, APreferNearestToCaret);
end;

procedure TDOSrcVwrViewerFrame.SyncFindDialogSummary(const ASummary: string);
begin
  if Assigned(FFindDialog) and FFindDialog.Visible then
    FFindDialog.SetMatchSummary(ASummary);
end;

procedure TDOSrcVwrViewerFrame.EnsureFindDialog;
var
  LOpusRootWnd: HWND;
begin
  if FFindDialog = nil then
  begin
    FFindDialog := TDSciFindDialog.Create(nil);
    FFindDialog.OnExecuteSearch := ExecuteFindDialogAction;
    FFindDialog.ReadOnly := True;  // viewer is read-only; disables Replace/ReplaceAll buttons
    { Re-own the modeless dialog to the top-level DOpus window so it stays
      above the Opus frame in Z-order regardless of DVPN_FOCUSCHANGE activity.
      Mirrors the same pattern used in ShowConfigureDialog. }
    LOpusRootWnd := GetAncestor(FParentOpusWnd, GA_ROOT);
    if LOpusRootWnd <> 0 then
    begin
      FFindDialog.HandleNeeded;
      SetWindowLongPtr(FFindDialog.Handle, GWLP_HWNDPARENT, LOpusRootWnd);
      LogInfo('EnsureFindDialog: set owner to DO root $%x', [LOpusRootWnd]);
    end;
  end;
end;

{ Search bar event handlers }

procedure TDOSrcVwrViewerFrame.SearchEditChange(Sender: TObject);
begin
  if FUpdatingSearchControls then
    Exit;
  UpdateSearch(True);
end;

procedure TDOSrcVwrViewerFrame.SearchEditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      begin
        if ssShift in Shift then
          SelectRelativeSearchResult(-1)
        else
          SelectRelativeSearchResult(1);
        Key := 0;
      end;
    VK_ESCAPE:
      begin
        CloseInlineSearch;
        Key := 0;
      end;
  end;
end;

procedure TDOSrcVwrViewerFrame.SearchOptionClick(Sender: TObject);
begin
  if FUpdatingSearchControls then
    Exit;
  UpdateSearch(True);
end;

procedure TDOSrcVwrViewerFrame.SearchPrevButtonClick(Sender: TObject);
begin
  SelectRelativeSearchResult(-1);
end;

procedure TDOSrcVwrViewerFrame.SearchNextButtonClick(Sender: TObject);
begin
  SelectRelativeSearchResult(1);
end;

procedure TDOSrcVwrViewerFrame.SearchCancelButtonClick(Sender: TObject);
begin
  CloseInlineSearch;
end;

{ Find dialog callback }

procedure TDOSrcVwrViewerFrame.ExecuteFindDialogAction(Sender: TObject;
  const AConfig: TDSciSearchConfig; AAction: TDSciFindDialogAction);
begin
  if FDestroying then
    Exit;
  EnsureFindDialog;
  FFindDialog.AddSearchHistory(AConfig.Query);

  case AAction of
    fdaFindNext:
      begin
        if FHasActiveSearchConfig and SameSearchConfig(FActiveSearchConfig, AConfig) and
           (FSearchMatches.Count > 0) then
        begin
          if not SelectRelativeSearchResult(1, AConfig.WrapAround) then
            SyncFindDialogSummary('Reached end');
        end
        else
          ExecuteSearch(AConfig, True);
      end;

    fdaFindPrevious:
      begin
        if FHasActiveSearchConfig and SameSearchConfig(FActiveSearchConfig, AConfig) and
           (FSearchMatches.Count > 0) then
        begin
          if not SelectRelativeSearchResult(-1, AConfig.WrapAround) then
            SyncFindDialogSummary('Reached beginning');
        end
        else
        begin
          ExecuteSearch(AConfig, True);
          if FSearchMatches.Count > 0 then
            SelectRelativeSearchResult(-1, AConfig.WrapAround);
        end;
      end;

    fdaCount:
      begin
        ExecuteSearch(AConfig, False, False);
        SyncFindDialogSummary(MatchSummary(FSearchMatches.Count));
      end;

    fdaFindAll:
      begin
        ExecuteSearch(AConfig, False, False);
        if FSearchMatches.Count = 1 then
          SyncFindDialogSummary('1 match highlighted')
        else
          SyncFindDialogSummary(Format('%d matches highlighted', [FSearchMatches.Count]));
      end;

    fdaMarkAllBookmarks:
      begin
        ExecuteSearch(AConfig, False, False);
        SyncFindDialogSummary(MatchSummary(FSearchMatches.Count) + ' bookmarked');
      end;
  end;
end;

{ Occurrence highlights and editor events }

function TDOSrcVwrViewerFrame.IsIdentifierText(const AText: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  if AText = '' then
    Exit;
  if not (AText[1].IsLetter or (AText[1] = '_')) then
    Exit;
  for I := 2 to Length(AText) do
    if not (AText[I].IsLetterOrDigit or (AText[I] = '_')) then
      Exit;
  Result := True;
end;

procedure TDOSrcVwrViewerFrame.ClearOccurrenceHighlights;
begin
  FEditor.IndicatorCurrent := cOccurrenceIndicator;
  FEditor.IndicatorClearRange(0, FEditor.TextLength);
  FHighlightedIdentifier := '';
end;

procedure TDOSrcVwrViewerFrame.HighlightIdentifierOccurrences(
  const AIdentifier: string);
var
  LPreviousFlags: TDSciFindOptionSet;
  LRangeEnd: NativeInt;
  LSearchStart: NativeInt;
  LMatchStart: NativeInt;
  LMatchEnd: NativeInt;
begin
  ClearOccurrenceHighlights;
  if not IsIdentifierText(AIdentifier) then
    Exit;

  LRangeEnd := FEditor.TextLength;
  LPreviousFlags := FEditor.SearchFlags;
  try
    FEditor.SearchFlags := [scfoMATCH_CASE, scfoWHOLE_WORD];
    FEditor.IndicatorCurrent := cOccurrenceIndicator;
    FEditor.IndicatorValue := 1;

    LSearchStart := 0;
    while LSearchStart <= LRangeEnd do
    begin
      FEditor.TargetStart := LSearchStart;
      FEditor.TargetEnd := LRangeEnd;
      LMatchStart := FEditor.SearchInTarget(AIdentifier);
      if LMatchStart < 0 then
        Break;
      LMatchEnd := FEditor.TargetEnd;
      if LMatchEnd <= LMatchStart then
        Break;
      FEditor.IndicatorFillRange(LMatchStart, LMatchEnd - LMatchStart);
      LSearchStart := LMatchEnd;
    end;
  finally
    FEditor.SearchFlags := LPreviousFlags;
  end;

  FHighlightedIdentifier := AIdentifier;
end;

procedure TDOSrcVwrViewerFrame.ToggleBookmarkAtLine(ALine: NativeInt);
begin
  if (FEditor.MarkerGet(ALine) and cBookmarkMask) <> 0 then
    FEditor.MarkerDelete(ALine, cBookmarkMarker)
  else
    FEditor.MarkerAdd(ALine, cBookmarkMarker);
end;

procedure TDOSrcVwrViewerFrame.EditorDblClick(Sender: TObject);
begin
  PostMessage(Handle, cHighlightSelectionMatchesMessage, 0, 0);
end;

procedure TDOSrcVwrViewerFrame.EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if not (Key in [VK_SHIFT, VK_CONTROL, VK_MENU]) then
    ClearOccurrenceHighlights;
end;

procedure TDOSrcVwrViewerFrame.EditorMarginClick(ASender: TObject;
  AModifiers: Integer; APosition: NativeInt; AMargin: Integer);
var
  LLine: NativeInt;
begin
  LLine := FEditor.LineFromPosition(APosition);
  if AMargin = cBookmarkMargin then
  begin
    ToggleBookmarkAtLine(LLine);
    Exit;
  end;
  if AMargin = cFoldMargin then
    FEditor.ToggleFold(LLine);
end;

procedure TDOSrcVwrViewerFrame.EditorChanged(Sender: TObject);
begin
  UpdateLineNumberMarginWidth;
  ClearOccurrenceHighlights;
  if FHasActiveSearchConfig then
    ExecuteSearch(FActiveSearchConfig, False, False);
end;

procedure TDOSrcVwrViewerFrame.WMHighlightSelectionMatches(
  var AMessage: TMessage);
var
  LQuery: string;
begin
  LQuery := ExtractSearchWordFromSelection;
  if not IsIdentifierText(LQuery) then
    Exit;
  HighlightIdentifierOccurrences(LQuery);
  if FEditor.HandleAllocated then
    Winapi.Windows.SetFocus(FEditor.Handle);
end;

{ Public methods }

procedure TDOSrcVwrViewerFrame.OpenInlineSearch;
var
  LSelectedText: string;
begin
  FSearchPanel.Visible := True;
  // Ensure child handles are created (panel was initially invisible)
  FSearchPanel.HandleNeeded;
  FSearchEdit.HandleNeeded;

  LSelectedText := ExtractSearchWordFromSelection;
  if LSelectedText <> '' then
  begin
    FUpdatingSearchControls := True;
    try
      FSearchEdit.Text := LSelectedText;
    finally
      FUpdatingSearchControls := False;
    end;
  end;

  if Trim(FSearchEdit.Text) <> '' then
    UpdateSearch(True);
  FSearchEdit.SelectAll;
  if FSearchEdit.HandleAllocated and FSearchEdit.Visible then
    Winapi.Windows.SetFocus(FSearchEdit.Handle);
end;

procedure TDOSrcVwrViewerFrame.CloseInlineSearch;
begin
  FSearchPanel.Visible := False;
  FSearchEdit.Clear;
  ClearSearchHighlights;
  FHasActiveSearchConfig := False;
  FSearchStatusLabel.Caption := '';
  if FEditor.HandleAllocated then
    Winapi.Windows.SetFocus(FEditor.Handle);
end;

procedure TDOSrcVwrViewerFrame.OpenFindDialog;
var
  LConfig: TDSciSearchConfig;
  LSelectedText: string;
begin
  if FDestroying then
    Exit;
  EnsureFindDialog;

  if FHasActiveSearchConfig then
    LConfig := FActiveSearchConfig
  else
    LConfig := BuildInlineSearchConfig;

  LSelectedText := ExtractSearchWordFromSelection;
  if LSelectedText <> '' then
    LConfig.Query := LSelectedText;

  FFindDialog.ApplySearchConfig(LConfig);
  FFindDialog.SetMatchSummary(FSearchStatusLabel.Caption);
  FFindDialog.Show;
  FFindDialog.BringToFront;
  FFindDialog.FocusSearchText;
end;

function TDOSrcVwrViewerFrame.FindDialogHandle: HWND;
begin
  { Only return a valid handle when the dialog is actually visible.
    A hidden FFindDialog must not be fed to IsDialogMessage otherwise it
    silently intercepts Tab / Enter / Escape that should go to inline search. }
  if Assigned(FFindDialog) and FFindDialog.HandleAllocated and FFindDialog.Visible then
    Result := FFindDialog.Handle
  else
    Result := 0;
end;

procedure TDOSrcVwrViewerFrame.BeginDestroying;
begin
  { Set the guard flag first so all callbacks and keyboard handlers reject
    calls immediately, even before the objects are freed. }
  FDestroying := True;
  CancelAndFreeDialogs;
end;

procedure TDOSrcVwrViewerFrame.CancelAndFreeDialogs;
var
  LSettings: TDSciVisualSettingsDialog;
begin
  { Called from BeginDestroying (via WM_DESTROY and destructor) so that all
    dialogs are closed before the viewer's HWND and editor are torn down.

    GotoDialog (modal): set ModalResult so ShowModal's loop exits on its next
    iteration, which calls EnableTaskWindows and returns control to the finally
    block in OpenGotoDialog. Do NOT Free or nil her the form must outlive
    the modal loop iteration; the finally block owns the FreeAndNil.

    FindDialog (modeless): safe to free directly.

    SettingsDialog (modeless): call CloseFromOwnerDestroy first (clears callbacks,
    prevents applying config to the dying editor, closes the window), then Free. }

  if FGotoDialog <> nil then
  begin
    LogInfo('CancelAndFreeDialogs: cancelling GotoDialog (ModalResult := mrCancel)');
    FGotoDialog.ModalResult := mrCancel;
    { Do NOT nil FGotoDialog here the finally block in OpenGotoDialog is
      responsible for FreeAndNil.  Nil-ing early would leave the object
      allocated but unreachable (memory leak). }
  end;

  if FFindDialog <> nil then
  begin
    LogInfo('CancelAndFreeDialogs: freeing FindDialog');
    FreeAndNil(FFindDialog);
  end;

  LSettings := FSettingsDialog;
  FSettingsDialog := nil;
  if LSettings <> nil then
  begin
    LogInfo('CancelAndFreeDialogs: closing SettingsDialog');
    LSettings.CloseFromOwnerDestroy;
    LSettings.Free;
  end;
end;

procedure TDOSrcVwrViewerFrame.OpenGotoDialog;
var
  LResult: TDSciGotoResult;
  LLine, LMaxLine: NativeInt;
  LPos, LMaxPos: NativeInt;
  LTarget: NativeInt;
  LOpusRootWnd: HWND;
begin
  if FDestroying then
    Exit;

  { Guard against reentrancy (Ctrl+G pressed while dialog is already showing). }
  if FGotoDialog <> nil then
  begin
    LogInfo('OpenGotoDialog: already open, bringing to front');
    if FGotoDialog.HandleAllocated then
      SetForegroundWindow(FGotoDialog.Handle);
    Exit;
  end;

  LLine := FEditor.LineFromPosition(FEditor.CurrentPos) + 1;
  LMaxLine := FEditor.LineCount;
  LPos := FEditor.CurrentPos;
  LMaxPos := FEditor.TextLength;

  LogInfo('GotoDialog: current line=%d max=%d pos=%d maxpos=%d',
    [LLine, LMaxLine, LPos, LMaxPos]);

  { FGotoDialog is non-nil for the entire duration of ShowModal.
    CancelAndFreeDialogs (called from WM_DESTROY) can set ModalResult := mrCancel
    on this field to unblock the modal loop and let ShowModal return cleanly,
    which triggers EnableTaskWindows and unblocks the caller thread. }
  FGotoDialog := TDSciGotoDialog.Create(nil);
  try
    LOpusRootWnd := GetAncestor(FParentOpusWnd, GA_ROOT);
    if LOpusRootWnd <> 0 then
    begin
      FGotoDialog.HandleNeeded;
      SetWindowLongPtr(FGotoDialog.Handle, GWLP_HWNDPARENT, LOpusRootWnd);
      LogInfo('OpenGotoDialog: set owner to DO root $%x', [LOpusRootWnd]);
    end;
    LResult := FGotoDialog.Execute(LLine, LMaxLine, LPos, LMaxPos);
  finally
    FreeAndNil(FGotoDialog);
  end;

  if not LResult.Accepted then
  begin
    LogInfo('GotoDialog: cancelled');
    Exit;
  end;

  { Guard: viewer may have been destroyed while the dialog was open. }
  if FDestroying then
  begin
    LogInfo('GotoDialog: viewer destroyed during dialog, skipping navigation');
    Exit;
  end;

  { Guard: viewer window may have been destroyed while the dialog was open. }
  if (FEditor = nil) or not FEditor.HandleAllocated then
  begin
    LogInfo('GotoDialog: editor no longer available, skipping navigation');
    Exit;
  end;

  if LResult.Value < 0 then
  begin
    LogInfo('GotoDialog: invalid value %d', [LResult.Value]);
    Exit;
  end;

  case LResult.Mode of
    dgmLine:
    begin
      LTarget := EnsureRange(LResult.Value, 1, LMaxLine) - 1;
      LogInfo('GotoDialog: go to line %d (0-based %d)', [LResult.Value, LTarget]);
      FEditor.GotoLine(LTarget);
      FEditor.SetSel(FEditor.PositionFromLine(LTarget),
        FEditor.LineEndPosition[LTarget]);
    end;
    dgmPosition:
    begin
      LTarget := EnsureRange(LResult.Value, 0, LMaxPos);
      LogInfo('GotoDialog: go to position %d', [LTarget]);
      FEditor.GotoPos(LTarget);
      LLine := FEditor.LineFromPosition(LTarget);
      FEditor.SetSel(FEditor.PositionFromLine(LLine),
        FEditor.LineEndPosition[LLine]);
    end;
  end;
  FEditor.ScrollCaret;
  if FEditor.HandleAllocated then
    Winapi.Windows.SetFocus(FEditor.Handle);
end;

function TDOSrcVwrViewerFrame.GetDialogOwnerWnd: HWND;
begin
  { Return the root (top-level) ancestor of the DOpus host window.
    A top-level owner is required by WinAPI for owned windows to have correct
    Z-order, lifecycle binding, and activation behaviour. }
  Result := 0;
  if FParentOpusWnd <> 0 then
    Result := GetAncestor(FParentOpusWnd, GA_ROOT);
  if Result = 0 then
  begin
    if HandleAllocated then
      Result := GetAncestor(Handle, GA_ROOT);
    if Result = 0 then
      Result := Application.Handle;
  end;
end;

procedure TDOSrcVwrViewerFrame.OpenSettingsDialog;
var
  LConfig: TDSciVisualConfig;
begin
  if FDestroying then
    Exit;

  { Singleton bring existing dialog to front. }
  if FSettingsDialog <> nil then
  begin
    if FSettingsDialog.HandleAllocated then
      SetForegroundWindow(FSettingsDialog.Handle);
    Exit;
  end;

  LConfig := TDSciVisualConfig.Create;
  try
    try
      if FileExists(FConfigFileName) then
        LConfig.LoadFromFile(FConfigFileName);
    except
      on E: Exception do
        LogError('OpenSettingsDialog: LoadFromFile: %s', [E.Message]);
    end;

    FSettingsDialog := TDSciVisualSettingsDialog.Create(nil);
    try
      FSettingsDialog.OwnerWnd := GetDialogOwnerWnd;
      FSettingsDialog.OnApplyConfig := SettingsApplyConfig;
      FSettingsDialog.OnDestroy := SettingsDialogDestroy;
      FSettingsDialog.ShowSettingsModeless(
        ExtractFileDir(FConfigFileName), FConfigFileName, LConfig);
    except
      on E: Exception do
      begin
        LogError('OpenSettingsDialog: [%s] %s', [E.ClassName, E.Message]);
        FreeAndNil(FSettingsDialog);
      end;
    end;
  finally
    LConfig.Free;
  end;
end;

procedure TDOSrcVwrViewerFrame.SettingsApplyConfig(AConfig: TDSciVisualConfig);
begin
  if FDestroying then
    Exit;
  if (FEditor = nil) or not FEditor.HandleAllocated then
    Exit;

  LogInfo('SettingsApplyConfig: saving config to %s', [FConfigFileName]);
  try
    ForceDirectories(ExtractFileDir(FConfigFileName));
    if FileExists(FConfigFileName) then
    begin
      try
        TFile.Copy(FConfigFileName, FConfigFileName + '.bak', True);
      except
        on E: Exception do
          LogError('SettingsApplyConfig: backup failed: %s', [E.Message]);
      end;
    end;
    AConfig.SaveToFile(FConfigFileName);
    LogInfo('SettingsApplyConfig: saved OK');

    { Apply logging settings immediately without waiting for ReloadConfig. }
    SetLogEnabled(AConfig.LogEnabled);
    SetLogLevel(TDOpusPluginLogLevel(EnsureRange(AConfig.LogLevel, 0, 3)));
    SetLogOutput(EnsureRange(AConfig.LogOutput, 0, 1));

    { Reload this viewer's presentation and notify all other active viewers. }
    ReloadConfig;
    NotifyViewersConfigChanged;
  except
    on E: Exception do
      LogError('SettingsApplyConfig: [%s] %s', [E.ClassName, E.Message]);
  end;
end;

procedure TDOSrcVwrViewerFrame.SettingsDialogDestroy(Sender: TObject);
begin
  { The modeless settings dialog auto-freed itself (caFree in OnClose).
    Clear our reference so we don't try to use or free it again. }
  if Sender = FSettingsDialog then
    FSettingsDialog := nil;
end;

procedure TDOSrcVwrViewerFrame.HandleKeyDown(var Key: Word; Shift: TShiftState);
var
  LConfig: TDSciSearchConfig;
begin
  case Key of
    Ord('F'):
      if ssCtrl in Shift then
      begin
        if ssShift in Shift then
          OpenFindDialog
        else
          OpenInlineSearch;
        Key := 0;
      end;

    Ord('S'):
      if ssCtrl in Shift then
      begin
        { Viewer is read-only consume Ctrl+S and Ctrl+Shift+S so they don't
          reach DO's file-save accelerator and open an unwanted Save As dialog. }
        LogInfo('HandleKeyDown: Ctrl+S consumed (viewer is read-only)');
        Key := 0;
      end;

    Ord('G'):
      if (ssCtrl in Shift) and not (ssShift in Shift) and not (ssAlt in Shift) then
      begin
        OpenGotoDialog;
        Key := 0;
      end;

    VK_F3:
      begin
        if FSearchPanel.Visible then
        begin
          { Inline search is ope navigate directly without touching the
            Find dialog.  Calling ExecuteFindDialogAction here would trigger
            EnsureFindDialog, which allocates a hidden FFindDialog whose HWND
            then leaks into IsDialogMessage and steals Tab/Enter/Escape. }
          if ssShift in Shift then
          begin
            if not SelectRelativeSearchResult(-1) then
              SyncFindDialogSummary('Reached beginning');
          end
          else
          begin
            if not SelectRelativeSearchResult(1) then
              SyncFindDialogSummary('Reached end');
          end;
        end
        else
        begin
          if Assigned(FFindDialog) and FFindDialog.Visible then
            LConfig := FFindDialog.SearchConfig
          else if FHasActiveSearchConfig then
            LConfig := FActiveSearchConfig
          else
            LConfig := BuildInlineSearchConfig;

          if ssShift in Shift then
            ExecuteFindDialogAction(Self, LConfig, fdaFindPrevious)
          else
            ExecuteFindDialogAction(Self, LConfig, fdaFindNext);
        end;
        Key := 0;
      end;

    VK_ESCAPE:
      if FSearchPanel.Visible then
      begin
        CloseInlineSearch;
        Key := 0;
      end;
  end;
end;

end.
