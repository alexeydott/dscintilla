unit uDSciEditorMain;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils,
  Winapi.Messages, Winapi.Windows,
  Vcl.Controls, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Forms,
  Vcl.Graphics, Vcl.Menus, Vcl.StdCtrls,
  DScintilla, DScintillaLogger, DScintillaTypes, DScintillaUtils,
  DScintillaSearchReplaceDLG,
  DScintillaVisualConfig, DScintillaSaveTextFileDLG;

type
  TDSciSearchMatch = record
    StartPos: NativeInt;
    EndPos: NativeInt;
  end;

  TDSciVisualEditor = class(TDScintilla)
  private
    FBackgroundDocumentLoadCount: Integer;
  protected
    procedure DoLoaderDocumentAttached; override;
  public
    property BackgroundDocumentLoadCount: Integer read FBackgroundDocumentLoadCount;
  end;

  TDSciVisualTestForm = class(TForm)
  private const
    cLineNumberMargin = 0;
    cLineNumPadMargin = 1;
    cBookmarkMargin = 2;
    cFoldMargin = 3;
    cBookmarkMarker = 2;
    cBookmarkMask = 1 shl cBookmarkMarker;
    cFoldMask = -33554432;
    cSearchIndicator = 0;
    cOccurrenceIndicator = 1;
    cHighlightSelectionMatchesMessage = WM_APP + 1;
    cReloadForEncodingChangeMessage = WM_APP + 2;
  private
    FMainMenu: TMainMenu;
    FFileMenu: TMenuItem;
    FOpenSyncMenuItem: TMenuItem;
    FOpenAsyncMenuItem: TMenuItem;
    FSaveMenuItem: TMenuItem;
    FSaveAsMenuItem: TMenuItem;
    FExitMenuItem: TMenuItem;
    FSearchMenu: TMenuItem;
    FInlineFindMenuItem: TMenuItem;
    FFindDialogMenuItem: TMenuItem;
    FReplaceDialogMenuItem: TMenuItem;
    FFindNextMenuItem: TMenuItem;
    FFindPreviousMenuItem: TMenuItem;
    FFoldingMenu: TMenuItem;
    FFoldAllMenuItem: TMenuItem;
    FUnfoldAllMenuItem: TMenuItem;
    FEditMenu: TMenuItem;
    FUndoMenuItem: TMenuItem;
    FRedoMenuItem: TMenuItem;
    FOptionsMenu: TMenuItem;
    FSettingsMenuItem: TMenuItem;
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
    FEditor: TDSciVisualEditor;
    FOpenDialog: TOpenDialog;
    FSaveDialog: TSaveTextFileDialog;
    FFindDialog: TDSciFindDialog;
    FSettingsDirectory: string;
    FConfigFileName: string;
    FEffectiveThemeFileName: string;
    FHighlightedIdentifier: string;
    FActiveSearchConfig: TDSciSearchConfig;
    FHasActiveSearchConfig: Boolean;
    FSearchMatches: TList<TDSciSearchMatch>;
    FCurrentSearchIndex: Integer;
    FUpdatingSearchControls: Boolean;
    FVisualConfig: TDSciVisualConfig;

    procedure BuildUi;
    procedure BuildMainMenu;
    procedure ConfigureEditorSurface;
    procedure ConfigureBookmarkMarker;
    procedure ConfigureFoldMarkers;
    procedure ConfigureOccurrenceIndicator;
    procedure ConfigureSearchIndicator;
    procedure ApplyFoldProperties;
    procedure ApplyConfiguredTheme;
    procedure ReapplyEditorPresentation(const AReason: string);
    procedure ApplyGutterPreferences;
    procedure ApplyVisualPreferences;
    procedure ClearSearchBookmarks;
    procedure ClearOccurrenceHighlights;
    procedure EnsureFindDialog;
    procedure ExecuteFindDialogAction(Sender: TObject; const AConfig: TDSciSearchConfig; AAction: TDSciFindDialogAction);
    procedure ExecuteSearch(const AConfig: TDSciSearchConfig; APreferNearestToCaret: Boolean; ASelectResult: Boolean = True);
    procedure HighlightIdentifierOccurrences(const AIdentifier: string);
    function MarkSearchResultsWithBookmarks: Integer;
    procedure ApplySearchConfigToInlineControls(const AConfig: TDSciSearchConfig);
    procedure EnsureVisualConfigFile;
    procedure LoadSettings;
    procedure LoadVisualConfig;
    procedure OpenFindDialog;
    procedure OpenReplaceDialog;
    procedure OpenInlineSearch;
    procedure CloseInlineSearch;
    procedure OpenSettingsDialog;
    function CanOpenFile(const AFileName: string; out AExpandedFileName: string): Boolean;
    procedure SaveFileTo(const AFileName: string; AEncoding: TDSciFileEncoding);
    procedure EditorFileLoadStateChange(Sender: TObject; const AStatus: TDSciFileLoadStatus);
    procedure EditorDropFiles(Sender: TObject; AFiles: TStrings);
    procedure HandleLoadedFile(const AFileName: string);
    procedure SyncFindDialogSummary(const ASummary: string);
    procedure UpdateLineNumberMarginWidth;
    procedure UpdateSearch(const APreferNearestToCaret: Boolean);
    procedure ClearSearchHighlights;
    procedure SelectSearchResult(AIndex: Integer);
    function SelectRelativeSearchResult(ADelta: Integer; AWrapAround: Boolean = True): Boolean;
    function BuildInlineSearchConfig: TDSciSearchConfig;
    function BuildSynchronizedSearchConfig: TDSciSearchConfig;
    function BuildSearchFlags(const AConfig: TDSciSearchConfig): TDSciFindOptionSet;
    function DecodeExtendedSearchText(const AText: string): string;
    function ExtractSearchWordFromEditorSelection: string;
    function FindNearestSearchResultIndex(ACaretPos: NativeInt): Integer;
    function FindSelectedSearchResultIndex: Integer;
    function IsIdentifierText(const AText: string): Boolean;
    function NormalizeSearchText(const AConfig: TDSciSearchConfig; out AQuery: string): Boolean;
    function ResolveConfigFileName: string;
    function ResolveDefaultGlobalStyle(const AStyleName: string): TDSciVisualStyleData;
    function ResolveSettingsDirectory: string;
    function SameSearchConfig(const ALeft, ARight: TDSciSearchConfig): Boolean;
    function ScaleUi(AValue: Integer): Integer;
    function TryGetSearchRange(const AConfig: TDSciSearchConfig; out AStartPos, AEndPos: NativeInt): Boolean;
    procedure Log(const AMessage: string);
    procedure ToggleBookmarkAtLine(ALine: NativeInt);

    procedure ExitMenuItemClick(Sender: TObject);
    procedure EditMenuClick(Sender: TObject);
    procedure UndoMenuItemClick(Sender: TObject);
    procedure RedoMenuItemClick(Sender: TObject);
    procedure SaveMenuItemClick(Sender: TObject);
    procedure SaveAsMenuItemClick(Sender: TObject);
    procedure FindDialogMenuItemClick(Sender: TObject);
    procedure ReplaceDialogMenuItemClick(Sender: TObject);
    procedure FindNextMenuItemClick(Sender: TObject);
    procedure FindPreviousMenuItemClick(Sender: TObject);
    procedure InlineFindMenuItemClick(Sender: TObject);
    procedure OpenAsyncButtonClick(Sender: TObject);
    procedure OpenSyncButtonClick(Sender: TObject);
    procedure SettingsMenuItemClick(Sender: TObject);
    procedure FoldAllButtonClick(Sender: TObject);
    procedure UnfoldAllButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchEditChange(Sender: TObject);
    procedure SearchOptionClick(Sender: TObject);
    procedure SearchEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchCancelButtonClick(Sender: TObject);
    procedure SearchPrevButtonClick(Sender: TObject);
    procedure SearchNextButtonClick(Sender: TObject);
    procedure EditorDblClick(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditorMarginClick(ASender: TObject; AModifiers: Integer; APosition: NativeInt; AMargin: Integer);
    procedure EditorMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure EditorChanged(Sender: TObject);
    procedure EditorGutterSettings(Sender: TObject);
    procedure EditorInitDefaults(Sender: TObject);
    procedure WMHighlightSelectionMatches(var AMessage: TMessage); message cHighlightSelectionMatchesMessage;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function BeginOpenFile(const AFileName: string): Boolean;
    function OpenFile(const AFileName: string): Boolean;
  end;

var
  DSciVisualTestForm: TDSciVisualTestForm;

implementation

uses
  System.Character, System.IOUtils, System.Math,
  DScintillaDefaultConfig, DScintillaVisualSettingsDLG;

procedure TDSciVisualEditor.DoLoaderDocumentAttached;
begin
  inherited DoLoaderDocumentAttached;
  Inc(FBackgroundDocumentLoadCount);
end;

function MatchSummary(ACount: Integer): string;
begin
  if ACount = 1 then
    Result := '1 match'
  else
    Result := Format('%d matches', [ACount]);
end;

constructor TDSciVisualTestForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  FSearchMatches := TList<TDSciSearchMatch>.Create;
  FCurrentSearchIndex := -1;
  FVisualConfig := TDSciVisualConfig.Create;
  KeyPreview := True;
  OnKeyDown := FormKeyDown;

  AutoScroll := False;
  Caption := 'DScintilla Editor Test';
  Position := poScreenCenter;
  Scaled := True;
  Width := ScaleUi(1200);
  Height := ScaleUi(780);
  Constraints.MinWidth := ScaleUi(900);
  Constraints.MinHeight := ScaleUi(640);

  BuildUi;

  FSettingsDirectory := ResolveSettingsDirectory;
  FConfigFileName := ResolveConfigFileName;
  FEffectiveThemeFileName := TPath.Combine(ExtractFileDir(FConfigFileName), 'DSciVisualTest.effective-theme.xml');
  EnsureVisualConfigFile;
  LoadVisualConfig;
  LoadSettings;
  ApplyVisualPreferences;
  FEditor.RefreshManagedStatusBar;

  if (ParamCount >= 1) and FileExists(ParamStr(1)) then
    OpenFile(ParamStr(1));
end;

procedure TDSciVisualTestForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle and not WS_EX_TOOLWINDOW;
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

destructor TDSciVisualTestForm.Destroy;
begin
  FFindDialog.Free;
  FSaveDialog.Free;
  FVisualConfig.Free;
  FSearchMatches.Free;
  inherited Destroy;
end;

procedure TDSciVisualTestForm.BuildUi;
begin
  BuildMainMenu;

  FSearchPanel := TPanel.Create(Self);
  FSearchPanel.Parent := Self;
  FSearchPanel.Align := alBottom;
  FSearchPanel.BevelOuter := bvNone;
  FSearchPanel.Height := ScaleUi(82);
  FSearchPanel.Visible := False;

  FSearchRowPanel := TPanel.Create(Self);
  FSearchRowPanel.Parent := FSearchPanel;
  FSearchRowPanel.Align := alTop;
  FSearchRowPanel.BevelOuter := bvNone;
  FSearchRowPanel.Height := ScaleUi(42);
  FSearchRowPanel.Padding.Left := ScaleUi(8);
  FSearchRowPanel.Padding.Top := ScaleUi(8);
  FSearchRowPanel.Padding.Right := ScaleUi(8);

  FSearchCancelButton := TButton.Create(Self);
  FSearchCancelButton.Parent := FSearchRowPanel;
  FSearchCancelButton.AlignWithMargins := True;
  FSearchCancelButton.Align := alRight;
  FSearchCancelButton.Caption := 'Cancel';
  FSearchCancelButton.Width := ScaleUi(94);
  FSearchCancelButton.OnClick := SearchCancelButtonClick;

  FSearchPrevButton := TButton.Create(Self);
  FSearchPrevButton.Parent := FSearchRowPanel;
  FSearchPrevButton.AlignWithMargins := True;
  FSearchPrevButton.Align := alRight;
  FSearchPrevButton.Caption := 'Find prev';
  FSearchPrevButton.Width := ScaleUi(96);
  FSearchPrevButton.OnClick := SearchPrevButtonClick;

  FSearchNextButton := TButton.Create(Self);
  FSearchNextButton.Parent := FSearchRowPanel;
  FSearchNextButton.AlignWithMargins := True;
  FSearchNextButton.Align := alRight;
  FSearchNextButton.Caption := 'Find next';
  FSearchNextButton.Width := ScaleUi(96);
  FSearchNextButton.OnClick := SearchNextButtonClick;

  FSearchStatusLabel := TLabel.Create(Self);
  FSearchStatusLabel.Parent := FSearchRowPanel;
  FSearchStatusLabel.AlignWithMargins := True;
  FSearchStatusLabel.Align := alRight;
  FSearchStatusLabel.Alignment := taRightJustify;
  FSearchStatusLabel.AutoSize := False;
  FSearchStatusLabel.Width := ScaleUi(88);
  FSearchStatusLabel.Layout := tlCenter;
  FSearchStatusLabel.Caption := '0 matches';

  FSearchEdit := TEdit.Create(Self);
  FSearchEdit.Parent := FSearchRowPanel;
  FSearchEdit.AlignWithMargins := True;
  FSearchEdit.Align := alClient;
  FSearchEdit.TextHint := 'Search as you type';
  FSearchEdit.OnChange := SearchEditChange;
  FSearchEdit.OnKeyDown := SearchEditKeyDown;

  FSearchOptionsPanel := TPanel.Create(Self);
  FSearchOptionsPanel.Parent := FSearchPanel;
  FSearchOptionsPanel.Align := alClient;
  FSearchOptionsPanel.BevelOuter := bvNone;
  FSearchOptionsPanel.Padding.Left := ScaleUi(8);
  FSearchOptionsPanel.Padding.Right := ScaleUi(8);

  FSearchCaseCheck := TCheckBox.Create(Self);
  FSearchCaseCheck.Parent := FSearchOptionsPanel;
  FSearchCaseCheck.AlignWithMargins := True;
  FSearchCaseCheck.Align := alLeft;
  FSearchCaseCheck.Caption := 'Match case';
  FSearchCaseCheck.Width := ScaleUi(120);
  FSearchCaseCheck.OnClick := SearchOptionClick;

  FSearchWholeWordCheck := TCheckBox.Create(Self);
  FSearchWholeWordCheck.Parent := FSearchOptionsPanel;
  FSearchWholeWordCheck.AlignWithMargins := True;
  FSearchWholeWordCheck.Align := alLeft;
  FSearchWholeWordCheck.Caption := 'Whole words';
  FSearchWholeWordCheck.Width := ScaleUi(128);
  FSearchWholeWordCheck.OnClick := SearchOptionClick;

  FEditor := TDSciVisualEditor.Create(Self);
  FEditor.Parent := Self;
  FEditor.Align := alClient;
  FEditor.OnDblClick := EditorDblClick;
  FEditor.OnKeyDown := EditorKeyDown;
  FEditor.OnMarginClick := EditorMarginClick;
  FEditor.OnMouseDown := EditorMouseDown;
  FEditor.OnChange := EditorChanged;
  FEditor.OnFileLoadStateChange := EditorFileLoadStateChange;
  FEditor.OnDropFiles := EditorDropFiles;
  FEditor.OnInitDefaults := EditorInitDefaults;
  FEditor.OnGutterSettings := EditorGutterSettings;
  FEditor.HandleNeeded;
  ConfigureEditorSurface;

  FOpenDialog := TOpenDialog.Create(Self);
  FOpenDialog.Filter :=
    'All files|*.*|Source files|*.pas;*.dpr;*.dproj;*.inc;*.cpp;*.c;*.h;*.hpp;*.py;*.js;*.ts;*.json;*.xml;*.html;*.css;*.sql|Pascal files|*.pas;*.dpr;*.dproj;*.inc';
  FOpenDialog.Options := [ofFileMustExist, ofPathMustExist, ofEnableSizing];

  FSaveDialog := TSaveTextFileDialog.Create(Self);
end;

procedure TDSciVisualTestForm.BuildMainMenu;
begin
  FMainMenu := TMainMenu.Create(Self);
  Menu := FMainMenu;

  FFileMenu := TMenuItem.Create(Self);
  FFileMenu.Caption := '&File';
  FMainMenu.Items.Add(FFileMenu);

  FOpenSyncMenuItem := TMenuItem.Create(Self);
  FOpenSyncMenuItem.Caption := '&Open...';
  FOpenSyncMenuItem.ShortCut := TextToShortCut('Ctrl+O');
  FOpenSyncMenuItem.OnClick := OpenSyncButtonClick;
  FFileMenu.Add(FOpenSyncMenuItem);

  FOpenAsyncMenuItem := TMenuItem.Create(Self);
  FOpenAsyncMenuItem.Caption := 'Open &Async...';
  FOpenAsyncMenuItem.ShortCut := TextToShortCut('Ctrl+Shift+O');
  FOpenAsyncMenuItem.OnClick := OpenAsyncButtonClick;
  FFileMenu.Add(FOpenAsyncMenuItem);

  FSaveMenuItem := TMenuItem.Create(Self);
  FSaveMenuItem.Caption := '&Save';
  FSaveMenuItem.ShortCut := TextToShortCut('Ctrl+S');
  FSaveMenuItem.OnClick := SaveMenuItemClick;
  FFileMenu.Add(FSaveMenuItem);

  FSaveAsMenuItem := TMenuItem.Create(Self);
  FSaveAsMenuItem.Caption := 'Save &As...';
  FSaveAsMenuItem.ShortCut := TextToShortCut('Ctrl+Shift+S');
  FSaveAsMenuItem.OnClick := SaveAsMenuItemClick;
  FFileMenu.Add(FSaveAsMenuItem);

  FExitMenuItem := TMenuItem.Create(Self);
  FExitMenuItem.Caption := 'E&xit';
  FExitMenuItem.OnClick := ExitMenuItemClick;
  FFileMenu.Add(FExitMenuItem);

  FEditMenu := TMenuItem.Create(Self);
  FEditMenu.Caption := '&Edit';
  FEditMenu.OnClick := EditMenuClick;
  FMainMenu.Items.Add(FEditMenu);

  FUndoMenuItem := TMenuItem.Create(Self);
  FUndoMenuItem.Caption := '&Undo';
  FUndoMenuItem.ShortCut := TextToShortCut('Ctrl+Z');
  FUndoMenuItem.OnClick := UndoMenuItemClick;
  FEditMenu.Add(FUndoMenuItem);

  FRedoMenuItem := TMenuItem.Create(Self);
  FRedoMenuItem.Caption := '&Redo';
  FRedoMenuItem.ShortCut := TextToShortCut('Ctrl+Y');
  FRedoMenuItem.OnClick := RedoMenuItemClick;
  FEditMenu.Add(FRedoMenuItem);

  FSearchMenu := TMenuItem.Create(Self);
  FSearchMenu.Caption := '&Search';
  FMainMenu.Items.Add(FSearchMenu);

  FInlineFindMenuItem := TMenuItem.Create(Self);
  FInlineFindMenuItem.Caption := '&Inline Find';
  FInlineFindMenuItem.ShortCut := TextToShortCut('Ctrl+F');
  FInlineFindMenuItem.OnClick := InlineFindMenuItemClick;
  FSearchMenu.Add(FInlineFindMenuItem);

  FFindDialogMenuItem := TMenuItem.Create(Self);
  FFindDialogMenuItem.Caption := 'Find &Dialog...';
  FFindDialogMenuItem.ShortCut := TextToShortCut('Ctrl+Shift+F');
  FFindDialogMenuItem.OnClick := FindDialogMenuItemClick;
  FSearchMenu.Add(FFindDialogMenuItem);

  FReplaceDialogMenuItem := TMenuItem.Create(Self);
  FReplaceDialogMenuItem.Caption := '&Replace Dialog...';
  FReplaceDialogMenuItem.ShortCut := TextToShortCut('Ctrl+H');
  FReplaceDialogMenuItem.OnClick := ReplaceDialogMenuItemClick;
  FSearchMenu.Add(FReplaceDialogMenuItem);

  FFindNextMenuItem := TMenuItem.Create(Self);
  FFindNextMenuItem.Caption := 'Find &Next';
  FFindNextMenuItem.ShortCut := TextToShortCut('F3');
  FFindNextMenuItem.OnClick := FindNextMenuItemClick;
  FSearchMenu.Add(FFindNextMenuItem);

  FFindPreviousMenuItem := TMenuItem.Create(Self);
  FFindPreviousMenuItem.Caption := 'Find &Previous';
  FFindPreviousMenuItem.ShortCut := TextToShortCut('Shift+F3');
  FFindPreviousMenuItem.OnClick := FindPreviousMenuItemClick;
  FSearchMenu.Add(FFindPreviousMenuItem);

  FFoldingMenu := TMenuItem.Create(Self);
  FFoldingMenu.Caption := '&Folding';
  FMainMenu.Items.Add(FFoldingMenu);

  FFoldAllMenuItem := TMenuItem.Create(Self);
  FFoldAllMenuItem.Caption := 'Fold &All';
  FFoldAllMenuItem.OnClick := FoldAllButtonClick;
  FFoldingMenu.Add(FFoldAllMenuItem);

  FUnfoldAllMenuItem := TMenuItem.Create(Self);
  FUnfoldAllMenuItem.Caption := '&Unfold All';
  FUnfoldAllMenuItem.OnClick := UnfoldAllButtonClick;
  FFoldingMenu.Add(FUnfoldAllMenuItem);

  FOptionsMenu := TMenuItem.Create(Self);
  FOptionsMenu.Caption := '&Options';
  FMainMenu.Items.Add(FOptionsMenu);

  FSettingsMenuItem := TMenuItem.Create(Self);
  FSettingsMenuItem.Caption := '&Editor Settings...';
  FSettingsMenuItem.ShortCut := TextToShortCut('Ctrl+,');
  FSettingsMenuItem.OnClick := SettingsMenuItemClick;
  FOptionsMenu.Add(FSettingsMenuItem);
end;

procedure TDSciVisualTestForm.ConfigureEditorSurface;
begin
  ApplyFoldProperties;
  ConfigureBookmarkMarker;
  ConfigureFoldMarkers;
  ConfigureOccurrenceIndicator;
  ConfigureSearchIndicator;

  FEditor.MarginTypeN[cLineNumberMargin] := scmtNUMBER;
  FEditor.MarginSensitiveN[cLineNumberMargin] := False;
  UpdateLineNumberMarginWidth;

  FEditor.MarginTypeN[cLineNumPadMargin] := scmtSYMBOL;
  FEditor.MarginMaskN[cLineNumPadMargin] := 0;
  FEditor.MarginSensitiveN[cLineNumPadMargin] := False;
  FEditor.MarginWidthN[cLineNumPadMargin] := 0;

  FEditor.MarginTypeN[cBookmarkMargin] := scmtSYMBOL;
  FEditor.MarginMaskN[cBookmarkMargin] := cBookmarkMask;
  FEditor.MarginSensitiveN[cBookmarkMargin] := True;
  FEditor.MarginWidthN[cBookmarkMargin] := ScaleUi(18);

  FEditor.MarginTypeN[cFoldMargin] := scmtSYMBOL;
  FEditor.MarginMaskN[cFoldMargin] := cFoldMask;
  FEditor.MarginSensitiveN[cFoldMargin] := True;
  FEditor.MarginWidthN[cFoldMargin] := ScaleUi(20);
end;

procedure TDSciVisualTestForm.ConfigureBookmarkMarker;
begin
  FEditor.MarkerDefine(cBookmarkMarker, scmsBOOKMARK);
  FEditor.MarkerFore[cBookmarkMarker] := clWhite;
  FEditor.MarkerBack[cBookmarkMarker] := FVisualConfig.HighlightColor;
end;

procedure TDSciVisualTestForm.ConfigureFoldMarkers;
begin
  FEditor.MarkerDefine(SC_MARKNUM_FOLDEROPEN, scmsBOX_MINUS);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDER, scmsBOX_PLUS);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDERSUB, scmsV_LINE);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDERTAIL, scmsL_CORNER);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDEREND, scmsBOX_PLUS_CONNECTED);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDEROPENMID, scmsBOX_MINUS_CONNECTED);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDERMIDTAIL, scmsT_CORNER);
end;

procedure TDSciVisualTestForm.ConfigureOccurrenceIndicator;
begin
  FEditor.IndicStyle[cOccurrenceIndicator] := FVisualConfig.SmartHighlightStyle;
  FEditor.IndicFore[cOccurrenceIndicator] := FVisualConfig.HighlightColor;
  FEditor.IndicUnder[cOccurrenceIndicator] := True;
  FEditor.IndicSetAlphaValue(cOccurrenceIndicator, FVisualConfig.SmartHighlightFillAlpha);
  FEditor.IndicSetOutlineAlphaValue(cOccurrenceIndicator,
    FVisualConfig.SmartHighlightOutlineAlpha);
end;

procedure TDSciVisualTestForm.ConfigureSearchIndicator;
begin
  FEditor.IndicStyle[cSearchIndicator] := scisROUND_BOX;
  FEditor.IndicFore[cSearchIndicator] := FVisualConfig.HighlightColor;
  FEditor.IndicUnder[cSearchIndicator] := False;
  FEditor.IndicSetAlphaValue(cSearchIndicator, FVisualConfig.HighlightAlpha);
  FEditor.IndicSetOutlineAlphaValue(cSearchIndicator,
    FVisualConfig.HighlightOutlineAlpha);
end;

procedure TDSciVisualTestForm.ApplyFoldProperties;
begin
  FEditor.SetProperty('fold', '1');
  FEditor.SetProperty('fold.compact', '1');
  FEditor.SetProperty('fold.comment', '1');
  FEditor.SetProperty('fold.preprocessor', '1');
  FEditor.SetProperty('fold.html', '1');
  FEditor.SetProperty('fold.xml', '1');
end;

procedure TDSciVisualTestForm.SyncFindDialogSummary(const ASummary: string);
begin
  if Assigned(FFindDialog) then
    FFindDialog.SetMatchSummary(ASummary);
end;

procedure TDSciVisualTestForm.EnsureFindDialog;
begin
  if Assigned(FFindDialog) then
    Exit;

  FFindDialog := TDSciFindDialog.Create(Self);
  FFindDialog.OnExecuteSearch := ExecuteFindDialogAction;
end;

procedure TDSciVisualTestForm.ApplySearchConfigToInlineControls(
  const AConfig: TDSciSearchConfig);
begin
  FUpdatingSearchControls := True;
  try
    FSearchEdit.Text := AConfig.Query;
    FSearchCaseCheck.Checked := AConfig.MatchCase;
    FSearchWholeWordCheck.Checked := AConfig.WholeWord;
  finally
    FUpdatingSearchControls := False;
  end;
end;

function TDSciVisualTestForm.BuildSynchronizedSearchConfig: TDSciSearchConfig;
begin
  if Assigned(FFindDialog) and FFindDialog.Visible then
    Exit(FFindDialog.SearchConfig);
  if FSearchPanel.Visible then
    Exit(BuildInlineSearchConfig);
  if FHasActiveSearchConfig then
    Exit(FActiveSearchConfig);
  Result := BuildInlineSearchConfig;
end;

procedure TDSciVisualTestForm.OpenFindDialog;
var
  lConfig: TDSciSearchConfig;
  lSelectedText: string;
begin
  EnsureFindDialog;

  if FVisualConfig.SearchSync then
    lConfig := BuildSynchronizedSearchConfig
  else if FHasActiveSearchConfig then
    lConfig := FActiveSearchConfig
  else
    lConfig := BuildInlineSearchConfig;

  lSelectedText := ExtractSearchWordFromEditorSelection;
  if lSelectedText <> '' then
    lConfig.Query := lSelectedText;

  FFindDialog.ApplySearchConfig(lConfig);
  FFindDialog.SetMatchSummary(FSearchStatusLabel.Caption);
  FFindDialog.Show;
  FFindDialog.BringToFront;
  FFindDialog.FocusSearchText;
end;

procedure TDSciVisualTestForm.OpenReplaceDialog;
var
  lConfig: TDSciSearchConfig;
  lSelectedText: string;
begin
  EnsureFindDialog;

  if FVisualConfig.SearchSync then
    lConfig := BuildSynchronizedSearchConfig
  else if FHasActiveSearchConfig then
    lConfig := FActiveSearchConfig
  else
    lConfig := BuildInlineSearchConfig;

  lSelectedText := ExtractSearchWordFromEditorSelection;
  if lSelectedText <> '' then
    lConfig.Query := lSelectedText;

  FFindDialog.ApplySearchConfig(lConfig);
  FFindDialog.SetMatchSummary(FSearchStatusLabel.Caption);
  FFindDialog.ShowReplaceTab;
  FFindDialog.Show;
  FFindDialog.BringToFront;
  FFindDialog.FocusSearchText;
end;

procedure TDSciVisualTestForm.OpenInlineSearch;
var
  lConfig: TDSciSearchConfig;
  lSelectedText: string;
begin
  if FVisualConfig.SearchSync then
  begin
    lConfig := BuildSynchronizedSearchConfig;
    FSearchPanel.Visible := True;
    ApplySearchConfigToInlineControls(lConfig);
  end;
  FSearchPanel.Visible := True;

  lSelectedText := ExtractSearchWordFromEditorSelection;
  if lSelectedText <> '' then
  begin
    lConfig := BuildInlineSearchConfig;
    lConfig.Query := lSelectedText;
    ApplySearchConfigToInlineControls(lConfig);
  end;

  if Trim(FSearchEdit.Text) <> '' then
    UpdateSearch(True);
  FSearchEdit.SelectAll;
  FSearchEdit.SetFocus;
end;

procedure TDSciVisualTestForm.CloseInlineSearch;
begin
  FSearchPanel.Visible := False;
  FSearchEdit.Clear;
  ClearSearchHighlights;
  FHasActiveSearchConfig := False;
  FEditor.SetFocus;
end;

procedure TDSciVisualTestForm.LoadSettings;
begin
  if not FileExists(FConfigFileName) then
  begin
    Log(Format('Config file not found: %s', [FConfigFileName]));
    Exit;
  end;

  if DirectoryExists(FSettingsDirectory) then
    Log(Format('Loading settings from config "%s" (settings directory: %s)',
      [FConfigFileName, FSettingsDirectory]))
  else
    Log(Format('Loading settings from config "%s" without bundled settings directory',
      [FConfigFileName]));
  FEditor.Settings.LoadConfigFile(FConfigFileName);
end;

function TDSciVisualTestForm.ResolveSettingsDirectory: string;
var
  lSettingsDirectory: string;
begin
  lSettingsDirectory := Trim(GetEnvironmentVariable('DSCI_SETTINGS_DIR'));
  if lSettingsDirectory <> '' then
    Exit(ExpandFileName(lSettingsDirectory));

  if FindCmdLineSwitch('DSCI_SETTINGS_DIR', lSettingsDirectory ) then
    Exit(ExpandFileName(lSettingsDirectory));

  Result := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\settings'));
end;

function TDSciVisualTestForm.ResolveDefaultGlobalStyle(
  const AStyleName: string): TDSciVisualStyleData;
var
  lGroup: TDSciVisualStyleGroup;
begin
  Result := nil;
  lGroup := FVisualConfig.StyleOverrides.FindGroup('default');
  if lGroup = nil then
    Exit;

  Result := lGroup.FindStyle(AStyleName, dvskGlobal);
  if Result = nil then
    Result := lGroup.FindStyle(AStyleName, dvskLexer);
end;

function TDSciVisualTestForm.ResolveConfigFileName: string;
var
  lAppData: string;
  lConfigFile: string;
begin
  lConfigFile := Trim(GetEnvironmentVariable('DSCI_CONFIG_FILE'));
  if lConfigFile <> '' then
    Exit(ExpandFileName(lConfigFile));

  lAppData := GetEnvironmentVariable('APPDATA');
  if lAppData = '' then
    lAppData := ExtractFilePath(ParamStr(0));
  Result := TPath.Combine(lAppData, ResolveSettingsDirectory+'\DScintilla.config.xml');
end;

procedure TDSciVisualTestForm.EnsureVisualConfigFile;
begin
  if EnsureDefaultConfigFile(FConfigFileName) then
    Log(Format('Created visual config %s from embedded defaults', [FConfigFileName]));
end;

procedure TDSciVisualTestForm.LoadVisualConfig;
begin
  if not FileExists(FConfigFileName) then
  begin
    Log(Format('Visual config file not found: %s', [FConfigFileName]));
    Exit;
  end;

  FVisualConfig.LoadFromFile(FConfigFileName);
end;

procedure TDSciVisualTestForm.ApplyConfiguredTheme;
begin
  Log(Format('Applying config "%s"', [FConfigFileName]));
  FEditor.Settings.LoadConfigFile(FConfigFileName);
end;

procedure TDSciVisualTestForm.ReapplyEditorPresentation(const AReason: string);
begin
  ApplyFoldProperties;
  ApplyVisualPreferences;
  if AReason <> '' then
    Log(Format('Reapplied fold and visual state after %s', [AReason]));
end;

procedure TDSciVisualTestForm.ApplyVisualPreferences;
begin
  ConfigureBookmarkMarker;
  ConfigureOccurrenceIndicator;
  ConfigureSearchIndicator;
  ApplyGutterPreferences;
end;

procedure TDSciVisualTestForm.ApplyGutterPreferences;
var
  lBookmarkMarginStyle: TDSciVisualStyleData;
begin
  if FVisualConfig.BookmarkMarginVisible then
    FEditor.MarginWidthN[cBookmarkMargin] := ScaleUi(18)
  else
    FEditor.MarginWidthN[cBookmarkMargin] := 0;

  if FVisualConfig.FoldMarginVisible then
    FEditor.MarginWidthN[cFoldMargin] := ScaleUi(20)
  else
    FEditor.MarginWidthN[cFoldMargin] := 0;

  if FVisualConfig.LineNumbering then
    UpdateLineNumberMarginWidth
  else
  begin
    FEditor.MarginWidthN[cLineNumberMargin] := 0;
    FEditor.MarginWidthN[cLineNumPadMargin] := 0;
  end;

  lBookmarkMarginStyle := ResolveDefaultGlobalStyle('Bookmark margin');
  if (lBookmarkMarginStyle <> nil) and lBookmarkMarginStyle.HasBackColor then
    FEditor.MarginBackN[cBookmarkMargin] := lBookmarkMarginStyle.BackColor
  else
    FEditor.MarginBackN[cBookmarkMargin] := clBtnFace;
end;

procedure TDSciVisualTestForm.OpenSettingsDialog;
var
  lDialog: TDSciVisualSettingsDialog;
begin
  lDialog := TDSciVisualSettingsDialog.Create(Self);
  try
    if not lDialog.EditSettings(FSettingsDirectory, FConfigFileName, FVisualConfig) then
      Exit;

    ForceDirectories(ExtractFileDir(FConfigFileName));
    FVisualConfig.SaveToFile(FConfigFileName);
    ApplyConfiguredTheme;
    if FEditor.CurrentFileName <> '' then
      FEditor.ReapplyPreferredLanguageSelection
    else
      ReapplyEditorPresentation('settings update');
    FEditor.RefreshManagedStatusBar;
  finally
    lDialog.Free;
  end;
end;

function TDSciVisualTestForm.CanOpenFile(const AFileName: string;
  out AExpandedFileName: string): Boolean;
var
  lFileSize: Int64;
begin
  AExpandedFileName := ExpandFileName(AFileName);
  Result := FileExists(AExpandedFileName);
  if not Result then
    Exit;

  lFileSize := TFile.GetSize(AExpandedFileName);
  if (FVisualConfig.FileSizeLimit > 0) and (lFileSize > FVisualConfig.FileSizeLimit) then
  begin
    Log(Format('Skipping %s because its size (%d bytes) exceeds the configured limit (%d bytes)',
      [AExpandedFileName, lFileSize, FVisualConfig.FileSizeLimit]));
    Result := False;
  end;
end;

procedure TDSciVisualTestForm.HandleLoadedFile(const AFileName: string);
begin
  Caption := Format('DScintilla Visual Test - %s',
    [ExtractFileName(FEditor.CurrentFileName)]);
  UpdateLineNumberMarginWidth;
  ClearOccurrenceHighlights;
  if FHasActiveSearchConfig then
    ExecuteSearch(FActiveSearchConfig, False, False)
  else
    UpdateSearch(False);
end;

procedure TDSciVisualTestForm.EditorFileLoadStateChange(Sender: TObject;
  const AStatus: TDSciFileLoadStatus);
begin
  case AStatus.Stage of
    sflsCompleted:
      begin
        Log(Format('Loaded %s via SCI_CREATELOADER (%s)',
          [AStatus.FileName, BoolToStr(AStatus.IsAsync, True)]));
        HandleLoadedFile(AStatus.FileName);
      end;
    sflsFailed:
      Log(Format('Load failed for %s: %s',
        [AStatus.FileName, AStatus.ErrorMessage]));
    sflsCancelled:
      Log(Format('Load cancelled for %s', [AStatus.FileName]));
  end;
end;

procedure TDSciVisualTestForm.EditorDropFiles(Sender: TObject; AFiles: TStrings);
begin
  if AFiles.Count > 0 then
    OpenFile(AFiles[0]);
end;

function TDSciVisualTestForm.OpenFile(const AFileName: string): Boolean;
var
  lFileName: string;
begin
  Result := False;
  if not CanOpenFile(AFileName, lFileName) then
    Exit;

  Log(Format('Opening file %s', [lFileName]));
  ClearSearchBookmarks;
  Result := FEditor.LoadFromFile(lFileName);
end;

function TDSciVisualTestForm.BeginOpenFile(const AFileName: string): Boolean;
var
  lFileName: string;
begin
  Result := False;
  if not CanOpenFile(AFileName, lFileName) then
    Exit;

  Log(Format('Starting background open for %s', [lFileName]));
  ClearSearchBookmarks;
  Result := FEditor.BeginLoadFromFile(lFileName);
  if Result then
    Repaint;
end;

procedure TDSciVisualTestForm.UpdateLineNumberMarginWidth;
var
  lDigits: Integer;
  lSample: string;
  lTextWidth: Integer;
begin
  if not FVisualConfig.LineNumbering then
  begin
    FEditor.MarginWidthN[cLineNumberMargin] := 0;
    FEditor.MarginWidthN[cLineNumPadMargin] := 0;
    Exit;
  end;

  case FVisualConfig.LineNumberWidthMode of
    lnwmFixed:
      lDigits := 6;
  else
    lDigits := Max(4, Length(IntToStr(Max(Int64(1), FEditor.LineCount))));
  end;
  lSample := StringOfChar('9', lDigits);
  lTextWidth := FEditor.TextWidth(STYLE_LINENUMBER, lSample);
{
  DSciLog(Format(
    'UpdateLineNumberMarginWidth padL=%d textW=%d padR=%d',
    [FVisualConfig.LineNumberPaddingLeft, lTextWidth,
     FVisualConfig.LineNumberPaddingRight]), cDSciLogDebug);
}
  FEditor.MarginWidthN[cLineNumberMargin] :=
    FVisualConfig.LineNumberPaddingLeft + lTextWidth;
  FEditor.MarginWidthN[cLineNumPadMargin] :=
    FVisualConfig.LineNumberPaddingRight;
  DSciLog(Format(
    'UpdateLineNumberMarginWidth readback: margin[%d]=%d pad[%d]=%d',
    [cLineNumberMargin, FEditor.MarginWidthN[cLineNumberMargin],
     cLineNumPadMargin, FEditor.MarginWidthN[cLineNumPadMargin]]),
    cDSciLogDebug);
end;

procedure TDSciVisualTestForm.ClearSearchHighlights;
begin
  FEditor.IndicatorCurrent := cSearchIndicator;
  FEditor.IndicatorClearRange(0, FEditor.TextLength);
  FSearchMatches.Clear;
  FCurrentSearchIndex := -1;
end;

procedure TDSciVisualTestForm.ClearSearchBookmarks;
begin
  FEditor.MarkerDeleteAll(cBookmarkMarker);
end;

procedure TDSciVisualTestForm.ClearOccurrenceHighlights;
begin
  FEditor.IndicatorCurrent := cOccurrenceIndicator;
  FEditor.IndicatorClearRange(0, FEditor.TextLength);
  FHighlightedIdentifier := '';
end;

function TDSciVisualTestForm.BuildInlineSearchConfig: TDSciSearchConfig;
begin
  Result.Query := FSearchEdit.Text;
  Result.MatchCase := FSearchCaseCheck.Checked;
  Result.WholeWord := FSearchWholeWordCheck.Checked;
  Result.WrapAround := True;
  Result.InSelection := False;
  Result.SearchMode := dsmNormal;
end;

function TDSciVisualTestForm.BuildSearchFlags(const AConfig: TDSciSearchConfig): TDSciFindOptionSet;
begin
  Result := [];
  if AConfig.MatchCase then
    Include(Result, scfoMATCH_CASE);
  if AConfig.WholeWord then
    Include(Result, scfoWHOLE_WORD);
  if AConfig.SearchMode = dsmRegularExpression then
    Include(Result, scfoREG_EXP);
end;

function TDSciVisualTestForm.DecodeExtendedSearchText(const AText: string): string;
var
  lCharValue: Integer;
  lHexDigits: string;
  lIndex: Integer;
begin
  Result := '';
  lIndex := 1;
  while lIndex <= Length(AText) do
  begin
    if AText[lIndex] <> '\' then
    begin
      Result := Result + AText[lIndex];
      Inc(lIndex);
      Continue;
    end;

    Inc(lIndex);
    if lIndex > Length(AText) then
    begin
      Result := Result + '\';
      Break;
    end;

    case AText[lIndex] of
      'n':
        Result := Result + #10;
      'r':
        Result := Result + #13;
      't':
        Result := Result + #9;
      '0':
        Result := Result + #0;
      '\':
        Result := Result + '\';
      'x', 'X':
        begin
          lHexDigits := '';
          while (lIndex < Length(AText)) and (Length(lHexDigits) < 4) and
            CharInSet(AText[lIndex + 1], ['0'..'9', 'A'..'F', 'a'..'f']) do
          begin
            Inc(lIndex);
            lHexDigits := lHexDigits + AText[lIndex];
          end;

          if (lHexDigits <> '') and TryStrToInt('$' + lHexDigits, lCharValue) then
            Result := Result + Char(lCharValue)
          else
            Result := Result + '\x';
        end;
    else
      Result := Result + AText[lIndex];
    end;

    Inc(lIndex);
  end;
end;

function TDSciVisualTestForm.ExtractSearchWordFromEditorSelection: string;
begin
  Result := Trim(FEditor.GetSelText);
  if (Result = '') or (Pos(#13, Result) > 0) or (Pos(#10, Result) > 0) or
     (Pos(#9, Result) > 0) then
    Result := '';
end;

function TDSciVisualTestForm.IsIdentifierText(const AText: string): Boolean;
var
  lIndex: Integer;
begin
  Result := False;
  if AText = '' then
    Exit;

  if not (AText[1].IsLetter or (AText[1] = '_')) then
    Exit;

  for lIndex := 2 to Length(AText) do
    if not (AText[lIndex].IsLetterOrDigit or (AText[lIndex] = '_')) then
      Exit;

  Result := True;
end;

function TDSciVisualTestForm.NormalizeSearchText(const AConfig: TDSciSearchConfig;
  out AQuery: string): Boolean;
begin
  case AConfig.SearchMode of
    dsmExtended:
      AQuery := DecodeExtendedSearchText(AConfig.Query);
  else
    AQuery := AConfig.Query;
  end;
  Result := True;
end;

function TDSciVisualTestForm.TryGetSearchRange(const AConfig: TDSciSearchConfig;
  out AStartPos, AEndPos: NativeInt): Boolean;
begin
  if AConfig.InSelection then
  begin
    AStartPos := FEditor.SelectionStart;
    AEndPos := FEditor.SelectionEnd;
    Result := AEndPos > AStartPos;
  end
  else
  begin
    AStartPos := 0;
    AEndPos := FEditor.TextLength;
    Result := True;
  end;
end;

function TDSciVisualTestForm.SameSearchConfig(const ALeft, ARight: TDSciSearchConfig): Boolean;
begin
  Result :=
    (ALeft.Query = ARight.Query) and
    (ALeft.MatchCase = ARight.MatchCase) and
    (ALeft.WholeWord = ARight.WholeWord) and
    (ALeft.WrapAround = ARight.WrapAround) and
    (ALeft.InSelection = ARight.InSelection) and
    (ALeft.SearchMode = ARight.SearchMode);
end;

function TDSciVisualTestForm.FindSelectedSearchResultIndex: Integer;
var
  lIndex: Integer;
begin
  Result := -1;
  for lIndex := 0 to FSearchMatches.Count - 1 do
    if (FSearchMatches[lIndex].StartPos = FEditor.SelectionStart) and
       (FSearchMatches[lIndex].EndPos = FEditor.SelectionEnd) then
      Exit(lIndex);
end;

function TDSciVisualTestForm.FindNearestSearchResultIndex(ACaretPos: NativeInt): Integer;
var
  lIndex: Integer;
begin
  Result := -1;
  for lIndex := 0 to FSearchMatches.Count - 1 do
    if (FSearchMatches[lIndex].StartPos <= ACaretPos) and
       (FSearchMatches[lIndex].EndPos >= ACaretPos) then
      Exit(lIndex);

  for lIndex := 0 to FSearchMatches.Count - 1 do
    if FSearchMatches[lIndex].StartPos >= ACaretPos then
      Exit(lIndex);

  if FSearchMatches.Count > 0 then
    Result := 0;
end;

procedure TDSciVisualTestForm.SelectSearchResult(AIndex: Integer);
var
  lMatch: TDSciSearchMatch;
begin
  if (AIndex < 0) or (AIndex >= FSearchMatches.Count) then
    Exit;

  FCurrentSearchIndex := AIndex;
  lMatch := FSearchMatches[AIndex];
  Log(Format('Selecting search result %d of %d at [%d..%d)',
    [AIndex + 1, FSearchMatches.Count, lMatch.StartPos, lMatch.EndPos]));
  FEditor.SetSelection(lMatch.EndPos, lMatch.StartPos);
  FEditor.ScrollCaret;
  FSearchStatusLabel.Caption := Format('%d / %d', [AIndex + 1, FSearchMatches.Count]);
  SyncFindDialogSummary(FSearchStatusLabel.Caption);
end;

function TDSciVisualTestForm.SelectRelativeSearchResult(ADelta: Integer;
  AWrapAround: Boolean): Boolean;
var
  lIndex: Integer;
begin
  Result := False;
  if FSearchMatches.Count = 0 then
    Exit;

  if FCurrentSearchIndex < 0 then
  begin
    lIndex := FindNearestSearchResultIndex(FEditor.CurrentPos)
  end
  else
    lIndex := FCurrentSearchIndex;

  Inc(lIndex, ADelta);
  if AWrapAround then
    lIndex := (lIndex + FSearchMatches.Count) mod FSearchMatches.Count
  else if (lIndex < 0) or (lIndex >= FSearchMatches.Count) then
    Exit;

  SelectSearchResult(lIndex);
  Result := True;
end;

function TDSciVisualTestForm.MarkSearchResultsWithBookmarks: Integer;
var
  lLastLine: NativeInt;
  lLine: NativeInt;
  lMatch: TDSciSearchMatch;
begin
  Result := 0;
  ClearSearchBookmarks;
  lLastLine := -1;
  for lMatch in FSearchMatches do
  begin
    lLine := FEditor.LineFromPosition(lMatch.StartPos);
    if lLine = lLastLine then
      Continue;
    FEditor.MarkerAdd(lLine, cBookmarkMarker);
    lLastLine := lLine;
    Inc(Result);
  end;
  DSciLog(Format('Marked %d bookmark lines from %d search matches',
    [Result, FSearchMatches.Count]), cDSciLogDebug);
end;

procedure TDSciVisualTestForm.ExecuteSearch(const AConfig: TDSciSearchConfig;
  APreferNearestToCaret: Boolean; ASelectResult: Boolean);
var
  lQuery: string;
  lRangeEnd: NativeInt;
  lRangeStart: NativeInt;
  lMatchStart: NativeInt;
  lMatch: TDSciSearchMatch;
  lSelectedIndex: Integer;
begin
  FActiveSearchConfig := AConfig;
  FHasActiveSearchConfig := AConfig.Query <> '';
  if FVisualConfig.SearchSync then
  begin
    ApplySearchConfigToInlineControls(AConfig);
    if Assigned(FFindDialog) and FFindDialog.Visible then
      FFindDialog.ApplySearchConfig(AConfig);
  end;
  ClearSearchHighlights;

  if not NormalizeSearchText(AConfig, lQuery) then
  begin
    FSearchStatusLabel.Caption := '0 matches';
    SyncFindDialogSummary('Invalid search expression');
    Exit;
  end;

  if lQuery = '' then
  begin
    FHasActiveSearchConfig := False;
    Log('Clearing search results');
    FSearchStatusLabel.Caption := '0 matches';
    SyncFindDialogSummary('0 matches');
    Exit;
  end;

  if not TryGetSearchRange(AConfig, lRangeStart, lRangeEnd) then
  begin
    Log('Search in selection requested without an active selection');
    FSearchStatusLabel.Caption := '0 matches';
    SyncFindDialogSummary('Select text first');
    Exit;
  end;

  FEditor.SearchFlags := BuildSearchFlags(AConfig);
  FEditor.IndicatorCurrent := cSearchIndicator;
  FEditor.IndicatorValue := 1;

  lMatchStart := lRangeStart;
  while lMatchStart <= lRangeEnd do
  begin
    FEditor.TargetStart := lMatchStart;
    FEditor.TargetEnd := lRangeEnd;
    lMatch.StartPos := FEditor.SearchInTarget(lQuery);
    if lMatch.StartPos < 0 then
      Break;

    lMatch.EndPos := FEditor.TargetEnd;
    if lMatch.EndPos <= lMatch.StartPos then
      Break;

    FSearchMatches.Add(lMatch);
    FEditor.IndicatorFillRange(lMatch.StartPos, lMatch.EndPos - lMatch.StartPos);
    lMatchStart := lMatch.EndPos;
  end;

  if FSearchMatches.Count = 0 then
  begin
    Log(Format('Search "%s" found no matches', [lQuery]));
    FSearchStatusLabel.Caption := '0 matches';
    SyncFindDialogSummary('0 matches');
    Exit;
  end;

  Log(Format('Search "%s" found %d matches', [lQuery, FSearchMatches.Count]));

  if not ASelectResult then
  begin
    FSearchStatusLabel.Caption := MatchSummary(FSearchMatches.Count);
    SyncFindDialogSummary(FSearchStatusLabel.Caption);
    Exit;
  end;

  if APreferNearestToCaret then
    lSelectedIndex := FindNearestSearchResultIndex(FEditor.CurrentPos)
  else
  begin
    lSelectedIndex := FindSelectedSearchResultIndex;
    if lSelectedIndex < 0 then
      lSelectedIndex := FindNearestSearchResultIndex(FEditor.CurrentPos);
  end;

  SelectSearchResult(lSelectedIndex);
end;

procedure TDSciVisualTestForm.UpdateSearch(const APreferNearestToCaret: Boolean);
begin
  ExecuteSearch(BuildInlineSearchConfig, APreferNearestToCaret);
end;

procedure TDSciVisualTestForm.HighlightIdentifierOccurrences(const AIdentifier: string);
var
  lConfig: TDSciSearchConfig;
  lPreviousFlags: TDSciFindOptionSet;
  lQuery: string;
  lRangeEnd: NativeInt;
  lRangeStart: NativeInt;
  lSearchStart: NativeInt;
  lMatchStart: NativeInt;
  lMatchEnd: NativeInt;
  lOccurrenceCount: Integer;
begin
  ClearOccurrenceHighlights;
  if not IsIdentifierText(AIdentifier) then
    Exit;

  lConfig.Query := AIdentifier;
  lConfig.MatchCase := True;
  lConfig.WholeWord := True;
  lConfig.WrapAround := False;
  lConfig.InSelection := False;
  lConfig.SearchMode := dsmNormal;
  NormalizeSearchText(lConfig, lQuery);

  lRangeStart := 0;
  lRangeEnd := FEditor.TextLength;
  lOccurrenceCount := 0;
  lPreviousFlags := FEditor.SearchFlags;
  try
    FEditor.SearchFlags := BuildSearchFlags(lConfig);
    FEditor.IndicatorCurrent := cOccurrenceIndicator;
    FEditor.IndicatorValue := 1;

    lSearchStart := lRangeStart;
    while lSearchStart <= lRangeEnd do
    begin
      FEditor.TargetStart := lSearchStart;
      FEditor.TargetEnd := lRangeEnd;
      lMatchStart := FEditor.SearchInTarget(lQuery);
      if lMatchStart < 0 then
        Break;

      lMatchEnd := FEditor.TargetEnd;
      if lMatchEnd <= lMatchStart then
        Break;

      FEditor.IndicatorFillRange(lMatchStart, lMatchEnd - lMatchStart);
      lSearchStart := lMatchEnd;
      Inc(lOccurrenceCount);
    end;
  finally
    FEditor.SearchFlags := lPreviousFlags;
  end;

  FHighlightedIdentifier := AIdentifier;
  Log(Format('Highlighted %d occurrences of identifier "%s"', [lOccurrenceCount, AIdentifier]));
end;

function TDSciVisualTestForm.ScaleUi(AValue: Integer): Integer;
begin
  Result := ScaleValue(AValue);
end;

procedure TDSciVisualTestForm.Log(const AMessage: string);
begin
  DSciLog('[VISUAL] ' + AMessage, cDSciLogDebug);
end;

procedure TDSciVisualTestForm.ToggleBookmarkAtLine(ALine: NativeInt);
begin
  if (FEditor.MarkerGet(ALine) and cBookmarkMask) <> 0 then
    FEditor.MarkerDelete(ALine, cBookmarkMarker)
  else
    FEditor.MarkerAdd(ALine, cBookmarkMarker);
end;

procedure TDSciVisualTestForm.ExecuteFindDialogAction(Sender: TObject;
  const AConfig: TDSciSearchConfig; AAction: TDSciFindDialogAction);
var
  lBookmarkCount: Integer;
  lMatchIdx: Integer;
  lNormalizedQuery: string;
  lNormalizedReplace: string;
  lRangeStart: NativeInt;
  lRangeEnd: NativeInt;
  lPos: NativeInt;
  lMatchEnd: NativeInt;
  lNewLen: NativeInt;
  lReplaceCount: Integer;
begin
  EnsureFindDialog;
  FFindDialog.AddSearchHistory(AConfig.Query);

  case AAction of
    fdaFindNext:
      begin
        if FHasActiveSearchConfig and SameSearchConfig(FActiveSearchConfig, AConfig) and
           (FSearchMatches.Count > 0) then
        begin
          if not SelectRelativeSearchResult(1, AConfig.WrapAround) then
            SyncFindDialogSummary('Reached end of search range');
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
            SyncFindDialogSummary('Reached beginning of search range');
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
        if AConfig.InSelection and (FEditor.SelectionStart = FEditor.SelectionEnd) then
          SyncFindDialogSummary('Select text first')
        else
          SyncFindDialogSummary(MatchSummary(FSearchMatches.Count));
      end;

    fdaFindAll:
      begin
        ExecuteSearch(AConfig, False, False);
        if AConfig.InSelection and (FEditor.SelectionStart = FEditor.SelectionEnd) then
          SyncFindDialogSummary('Select text first')
        else if FSearchMatches.Count = 1 then
          SyncFindDialogSummary('1 match highlighted')
        else
          SyncFindDialogSummary(Format('%d matches highlighted', [FSearchMatches.Count]));
      end;

    fdaMarkAllBookmarks:
      begin
        ExecuteSearch(AConfig, False, False);
        if AConfig.InSelection and (FEditor.SelectionStart = FEditor.SelectionEnd) then
          SyncFindDialogSummary('Select text first')
        else
        begin
          lBookmarkCount := MarkSearchResultsWithBookmarks;
          if lBookmarkCount = 1 then
            SyncFindDialogSummary('1 bookmark added')
          else
            SyncFindDialogSummary(Format('%d bookmarks added', [lBookmarkCount]));
        end;
      end;

    fdaReplace:
      begin
        if AConfig.Query = '' then
          Exit;
        FFindDialog.AddReplaceHistory(AConfig.ReplaceText);
        // If the current selection is a known search match, replace it then advance.
        lMatchIdx := FindSelectedSearchResultIndex;
        if lMatchIdx >= 0 then
        begin
          if AConfig.SearchMode = dsmRegularExpression then
          begin
            FEditor.TargetStart := FEditor.SelectionStart;
            FEditor.TargetEnd := FEditor.SelectionEnd;
            FEditor.ReplaceTargetRE(AConfig.ReplaceText);
          end
          else
          begin
            FEditor.TargetStart := FEditor.SelectionStart;
            FEditor.TargetEnd := FEditor.SelectionEnd;
            FEditor.ReplaceTarget(AConfig.ReplaceText);
          end;
        end;
        // Always advance to next match after a replace attempt.
        ExecuteSearch(AConfig, True);
      end;

    fdaReplaceAll:
      begin
        if AConfig.Query = '' then
          Exit;
        FFindDialog.AddReplaceHistory(AConfig.ReplaceText);
        if not NormalizeSearchText(AConfig, lNormalizedQuery) then
        begin
          SyncFindDialogSummary('Invalid search expression');
          Exit;
        end;
        if not TryGetSearchRange(AConfig, lRangeStart, lRangeEnd) then
        begin
          SyncFindDialogSummary('Select text first');
          Exit;
        end;
        if AConfig.SearchMode = dsmExtended then
          lNormalizedReplace := DecodeExtendedSearchText(AConfig.ReplaceText)
        else
          lNormalizedReplace := AConfig.ReplaceText;
        FEditor.SearchFlags := BuildSearchFlags(AConfig);
        lReplaceCount := 0;
        FEditor.BeginUndoAction;
        try
          lPos := lRangeStart;
          while lPos <= lRangeEnd do
          begin
            FEditor.TargetStart := lPos;
            FEditor.TargetEnd := lRangeEnd;
            if FEditor.SearchInTarget(lNormalizedQuery) < 0 then
              Break;
            lMatchEnd := FEditor.TargetEnd;
            if lMatchEnd <= lPos then
              Break;
            if AConfig.SearchMode = dsmRegularExpression then
              lNewLen := FEditor.ReplaceTargetRE(lNormalizedReplace)
            else
              lNewLen := FEditor.ReplaceTarget(lNormalizedReplace);
            Inc(lReplaceCount);
            lPos := FEditor.TargetEnd;
            if AConfig.InSelection then
              lRangeEnd := lRangeEnd + lNewLen - (lMatchEnd - (lPos - lNewLen));
          end;
        finally
          FEditor.EndUndoAction;
        end;
        ClearSearchHighlights;
        FHasActiveSearchConfig := False;
        if lReplaceCount = 1 then
          SyncFindDialogSummary('1 replacement made')
        else
          SyncFindDialogSummary(Format('%d replacements made', [lReplaceCount]));
      end;
  end;
end;

procedure TDSciVisualTestForm.ExitMenuItemClick(Sender: TObject);
begin
  Close;
end;

procedure TDSciVisualTestForm.SaveFileTo(const AFileName: string;
  AEncoding: TDSciFileEncoding);
begin
  DSciLog(Format('[DSciEditor] Saving file "%s" encoding=%s.',
    [AFileName, DSciFileEncodingDisplayName(AEncoding)]), cDSciLogDebug);
  if FEditor.SaveToFile(AFileName, AEncoding) then
  begin
    Caption := ExtractFileName(AFileName) + ' - DSciEditor';
    DSciLog('[DSciEditor] File saved successfully.', cDSciLogDebug);
  end
  else
    ShowMessage('Failed to save file: ' + AFileName);
end;

procedure TDSciVisualTestForm.SaveMenuItemClick(Sender: TObject);
begin
  DSciLog('[DSciEditor] SaveMenuItemClick.', cDSciLogDebug);
  if FEditor.CurrentFileName <> '' then
    SaveFileTo(FEditor.CurrentFileName, FEditor.FileLoadStatus.Encoding)
  else
    SaveAsMenuItemClick(Sender);
end;

procedure TDSciVisualTestForm.SaveAsMenuItemClick(Sender: TObject);
begin
  DSciLog('[DSciEditor] SaveAsMenuItemClick.', cDSciLogDebug);
  FSaveDialog.FileName := FEditor.CurrentFileName;
  FSaveDialog.InitialEncoding := FEditor.FileLoadStatus.Encoding;
  if FSaveDialog.Execute(Handle) then
    SaveFileTo(FSaveDialog.FileName, FSaveDialog.SelectedEncoding);
end;

procedure TDSciVisualTestForm.EditMenuClick(Sender: TObject);
begin
  FUndoMenuItem.Enabled := FEditor.CanUndo;
  FRedoMenuItem.Enabled := FEditor.CanRedo;
end;

procedure TDSciVisualTestForm.UndoMenuItemClick(Sender: TObject);
begin
  Log(Format('Undo triggered (CanUndo=%s, UndoActions=%d)',
    [BoolToStr(FEditor.CanUndo, True), FEditor.UndoActions]));
  if FEditor.CanUndo then
    FEditor.Undo;
end;

procedure TDSciVisualTestForm.RedoMenuItemClick(Sender: TObject);
begin
  Log(Format('Redo triggered (CanRedo=%s)', [BoolToStr(FEditor.CanRedo, True)]));
  if FEditor.CanRedo then
    FEditor.Redo;
end;

procedure TDSciVisualTestForm.OpenSyncButtonClick(Sender: TObject);
begin
  if FOpenDialog.Execute(Handle) then
    OpenFile(FOpenDialog.FileName);
end;

procedure TDSciVisualTestForm.OpenAsyncButtonClick(Sender: TObject);
begin
  if FOpenDialog.Execute(Handle) then
    BeginOpenFile(FOpenDialog.FileName);
end;

procedure TDSciVisualTestForm.FindDialogMenuItemClick(Sender: TObject);
begin
  OpenFindDialog;
end;

procedure TDSciVisualTestForm.ReplaceDialogMenuItemClick(Sender: TObject);
begin
  OpenReplaceDialog;
end;

procedure TDSciVisualTestForm.FoldAllButtonClick(Sender: TObject);
begin
  FEditor.FoldAll(scfaCONTRACT_EVERY_LEVEL);
end;

procedure TDSciVisualTestForm.UnfoldAllButtonClick(Sender: TObject);
begin
  FEditor.FoldAll(scfaEXPAND);
end;

procedure TDSciVisualTestForm.InlineFindMenuItemClick(Sender: TObject);
begin
  OpenInlineSearch;
end;

procedure TDSciVisualTestForm.FindNextMenuItemClick(Sender: TObject);
var
  lConfig: TDSciSearchConfig;
begin
  if Assigned(FFindDialog) and FFindDialog.Visible then
    lConfig := FFindDialog.SearchConfig
  else if FHasActiveSearchConfig then
    lConfig := FActiveSearchConfig
  else
    lConfig := BuildInlineSearchConfig;
  ExecuteFindDialogAction(Self, lConfig, fdaFindNext);
end;

procedure TDSciVisualTestForm.FindPreviousMenuItemClick(Sender: TObject);
var
  lConfig: TDSciSearchConfig;
begin
  if Assigned(FFindDialog) and FFindDialog.Visible then
    lConfig := FFindDialog.SearchConfig
  else if FHasActiveSearchConfig then
    lConfig := FActiveSearchConfig
  else
    lConfig := BuildInlineSearchConfig;
  ExecuteFindDialogAction(Self, lConfig, fdaFindPrevious);
end;

procedure TDSciVisualTestForm.SettingsMenuItemClick(Sender: TObject);
begin
  OpenSettingsDialog;
end;

procedure TDSciVisualTestForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  lConfig: TDSciSearchConfig;
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

    Ord('H'):
      if (ssCtrl in Shift) and not (ssShift in Shift) then
      begin
        OpenReplaceDialog;
        Key := 0;
      end;

    VK_F3:
      begin
        if Assigned(FFindDialog) and FFindDialog.Visible then
          lConfig := FFindDialog.SearchConfig
        else if FHasActiveSearchConfig then
          lConfig := FActiveSearchConfig
        else
          lConfig := BuildInlineSearchConfig;

        if ssShift in Shift then
          ExecuteFindDialogAction(Self, lConfig, fdaFindPrevious)
        else
          ExecuteFindDialogAction(Self, lConfig, fdaFindNext);
        Key := 0;
      end;
  end;
end;

procedure TDSciVisualTestForm.SearchEditChange(Sender: TObject);
begin
  if FUpdatingSearchControls then
    Exit;
  UpdateSearch(True);
end;

procedure TDSciVisualTestForm.SearchOptionClick(Sender: TObject);
begin
  if FUpdatingSearchControls then
    Exit;
  UpdateSearch(True);
end;

procedure TDSciVisualTestForm.SearchEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TDSciVisualTestForm.SearchCancelButtonClick(Sender: TObject);
begin
  CloseInlineSearch;
end;

procedure TDSciVisualTestForm.SearchPrevButtonClick(Sender: TObject);
begin
  SelectRelativeSearchResult(-1);
end;

procedure TDSciVisualTestForm.SearchNextButtonClick(Sender: TObject);
begin
  SelectRelativeSearchResult(1);
end;

procedure TDSciVisualTestForm.EditorDblClick(Sender: TObject);
begin
  PostMessage(Handle, cHighlightSelectionMatchesMessage, 0, 0);
end;

procedure TDSciVisualTestForm.EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if not (Key in [VK_SHIFT, VK_CONTROL, VK_MENU]) then
    ClearOccurrenceHighlights;
end;

procedure TDSciVisualTestForm.EditorMarginClick(ASender: TObject; AModifiers: Integer; APosition: NativeInt; AMargin: Integer);
var
  lLine: NativeInt;
begin
  lLine := FEditor.LineFromPosition(APosition);
  if AMargin = cBookmarkMargin then
  begin
    ToggleBookmarkAtLine(lLine);
    Exit;
  end;

  if AMargin = cFoldMargin then
    FEditor.ToggleFold(lLine);
end;

procedure TDSciVisualTestForm.EditorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ClearOccurrenceHighlights;
end;

procedure TDSciVisualTestForm.EditorChanged(Sender: TObject);
begin
  UpdateLineNumberMarginWidth;
  ClearOccurrenceHighlights;
  if FHasActiveSearchConfig then
    ExecuteSearch(FActiveSearchConfig, False, False);
end;

procedure TDSciVisualTestForm.EditorGutterSettings(Sender: TObject);
begin
  OpenSettingsDialog;
end;

procedure TDSciVisualTestForm.EditorInitDefaults(Sender: TObject);
begin
 ConfigureEditorSurface;
  ApplyVisualPreferences;
end;

procedure TDSciVisualTestForm.WMHighlightSelectionMatches(var AMessage: TMessage);
var
  lQuery: string;
begin
  lQuery := ExtractSearchWordFromEditorSelection;
  if not IsIdentifierText(lQuery) then
    Exit;

  HighlightIdentifierOccurrences(lQuery);
  FEditor.SetFocus;
end;

end.
