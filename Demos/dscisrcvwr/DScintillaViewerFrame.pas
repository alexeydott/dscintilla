///<summmary>
/// DSciSrcVwr - Windows Shell Preview Handler for source code files
///Uses Scintilla control for syntax-highlighted preview for supported files
///</summmary>
{$IFNDEF NO_SHELLACE}
  {$I decShellExtension.inc}
{$ENDIF}

unit DScintillaViewerFrame;

interface

uses
  Windows, Messages, SysUtils, ShellApi, ActiveX, ComObj, ShlObj, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, Menus, System.Generics.Collections,
{$IFDEF NO_SHELLACE}
  // IPreviewHandler base
  DSciPreviewBase,
{$ELSE}
  // ShellACE SDK (http://www.shellace.com/)
  decShellForm, decShellBaseExtension, decShellPreviewExtension, decShellThemes,
{$ENDIF}
  // Scintilla
  DScintilla, DScintillaLogger, DScintillaTypes, DScintillaUtils,
  DScintillaSearchReplaceDLG, DScintillaGotoDLG,
  DScintillaVisualConfig, DScintillaVisualSettingsDLG
{$IFDEF DARK_MODE_EXPERIMENTS}
  , System.Types, DScintillaWinTheme
{$ENDIF}
  ;

type
  TDSciSearchMatch = record
    StartPos: NativeInt;
    EndPos: NativeInt;
  end;

  TSourceCodePreviewExtensionForm = class({$IFDEF NO_SHELLACE}TDSciPreviewExtensionForm{$ELSE}TdecShellPreviewExtensionForm{$ENDIF})
  private const
    cLineNumberMargin = 0;
    cBookmarkMargin = 1;
    cFoldMargin = 2;
    cBookmarkMarker = 2;
    cBookmarkMask = 1 shl cBookmarkMarker;
    cSearchIndicator = 0;
    cOccurrenceIndicator = 1;
    cHighlightSelectionMatchesMessage = WM_APP + 1;
  private
    FEditor: TDScintilla;
    FConfigFileName: string;
    FCurrentFileName: string;
    FHighlightedIdentifier: string;
    // Inline search bar
    FSearchPanel: TPanel;
    FSearchRowPanel: TPanel;
    FSearchOptionsPanel: TPanel;
    FSearchEdit: TEdit;
    FSearchCaseCheck: TCheckBox;
    FSearchWholeWordCheck: TCheckBox;
    FSearchPrevButton: TButton;
    FSearchNextButton: TButton;
    FSearchCloseButton: TButton;
    FSearchStatusLabel: TLabel;
    // Dialogs
{$IFDEF DARK_MODE_EXPERIMENTS}
    // Owner-draw plumbing for theme-aware checkbox rendering
    FOrigOptionsPanelWndProc: TWndMethod;
{$ENDIF}
    // Dialogs
    FFindDialog: TDSciFindDialog;
    FGotoDialog: TDSciGotoDialog;
    FVisualSettingsDialog: TDSciVisualSettingsDialog;
    // Search state
    FSearchMatches: TList<TDSciSearchMatch>;
    FCurrentSearchIndex: Integer;
    FUpdatingSearchControls: Boolean;
    // Context menu
    FContextMenu: TPopupMenu;
{$IFNDEF NO_SHELLACE}
    // Saved HWND during csRecreating
    FSavedHandle: HWND;
{$ENDIF}

    class function ScaleDpi(AValue: Integer): Integer; static;
    procedure InitializeEditor;
    procedure ConfigureEditorSurface;
    procedure ConfigureSearchIndicator;
    procedure ConfigureOccurrenceIndicator;
    procedure ApplyFoldProperties;
    procedure ResolveAndLoadConfig;
    procedure BuildSearchBar;
    procedure BuildContextMenu;
    procedure UpdateLineNumberMarginWidth;

    // Search operations
    procedure ExecuteInlineSearch(AForward: Boolean);
    procedure UpdateSearchHighlights;
    procedure ClearSearchHighlights;
    procedure SelectSearchResult(AIndex: Integer);
    function FindNext(AForward: Boolean; AWrap: Boolean = True): Boolean;
    function BuildSearchFlags(ACaseSensitive, AWholeWord: Boolean): TDSciFindOptionSet;

    // Occurrence highlighting
    procedure ClearOccurrenceHighlights;
    procedure HighlightIdentifierOccurrences(const AIdentifier: string);
    function IsIdentChar(ACh: Char): Boolean;

    // Bookmarks
    procedure ToggleBookmarkAtLine(ALine: NativeInt);

    // Editor event handlers
    procedure EditorDblClick(Sender: TObject);
    procedure EditorMarginClick(ASender: TObject; AModifiers: Integer;
      APosition: NativeInt; AMargin: Integer);
    procedure EditorUpdateUI(ASender: TObject; AUpdated: TDSciUpdateFlagsSet);
    procedure WMHighlightSelectionMatches(var AMessage: TMessage); message cHighlightSelectionMatchesMessage;
    procedure WMDestroy(var AMessage: TWMDestroy); message WM_DESTROY;

    // Dialog lifetime helpers
    procedure CancelAndFreeDialogs;

    // Search bar event handlers
    procedure SearchEditChange(Sender: TObject);
    procedure SearchEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchPrevClick(Sender: TObject);
    procedure SearchNextClick(Sender: TObject);
    procedure SearchCloseClick(Sender: TObject);
    procedure SearchOptionClick(Sender: TObject);

    // Find dialog callback
    procedure DoFindDialogAction(Sender: TObject; const AConfig: TDSciSearchConfig;
      AAction: TDSciFindDialogAction);

    // Context menu handlers
    procedure MenuCopyClick(Sender: TObject);
    procedure MenuCopyHtmlClick(Sender: TObject);
    procedure MenuSelectAllClick(Sender: TObject);
    procedure MenuFindClick(Sender: TObject);
    procedure MenuGotoClick(Sender: TObject);
    procedure MenuFoldAllClick(Sender: TObject);
    procedure MenuUnfoldAllClick(Sender: TObject);
    procedure MenuFoldCurrentClick(Sender: TObject);
    procedure MenuUnfoldCurrentClick(Sender: TObject);
    procedure MenuFoldNestedClick(Sender: TObject);
    procedure MenuUnfoldNestedClick(Sender: TObject);
    procedure MenuSettingsClick(Sender: TObject);

    // Keyboard handling
    procedure HandleKeyDown(var Key: Word; Shift: TShiftState);
    procedure OpenInlineSearch;
    procedure CloseInlineSearch;
    procedure OpenFindDialog;
    procedure OpenGotoDialog;

    // Dialog positioning helper (COM-hosted forms lack proper VCL owner for poOwnerFormCenter)
    procedure CenterFormOverSelf(AForm: TForm);
{$IFDEF DARK_MODE_EXPERIMENTS}
    // Theme-aware search bar coloring
    procedure ApplySearchBarColors;
    procedure WMThemeChanged(var AMessage: TMessage); message WM_THEMECHANGED;
    // Owner-draw for checkboxes (dark mode compatible)
    procedure OptionsPanelWndProc(var AMessage: TMessage);
{$ENDIF}
  protected
    procedure ClearPreview; override;
    function TranslateAccelerator(const AMessage: TMsg): Boolean; override;
{$IFNDEF NO_SHELLACE}
    // Handle preservation during RecreateWnd so Scintilla's internal state
    // (document, undo history) survives VCL handle recreation.
    procedure DestroyWnd; override;
    procedure CreateWnd; override;
{$ENDIF}
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
{$IFDEF DARK_MODE_EXPERIMENTS}
    class function IsWindowsDarkTheme: Boolean;
{$ENDIF}
    procedure LoadPreviewFromStream(AStream: TStream; const AFileName: string = '');
    procedure LoadPreviewFromFile(const AFileName: string);
{$IFNDEF NO_SHELLACE}
    // VCL cavewats
    // WM_ACTIVATE is not sent to WS_CHILD windows so TCustomForm.FActive stays False;
    // bypass inherited SetFocus which would raise EInvalidOperation.
    procedure SetFocus; override;
{$ENDIF}
  end;

const
  SID_TSourceCodePreviewExtension: TCLSID = '{91849BED-E747-45AA-931B-E53CF264B554}';

type
  TSourceCodePreviewExtension = class({$IFDEF NO_SHELLACE}TDSciPreviewExtension{$ELSE}TdecShellPreviewExtension{$ENDIF})
  public
    procedure Initialize; override;
    class function GetClassID: TCLSID; override;
    class function GetDescription: UnicodeString; override;
{$IFDEF NO_SHELLACE}
    class procedure FillProgIDList(AList: TStrings); override;
  protected
    function CreatePreview(AParent: HWND): TDSciPreviewExtensionForm; override;
    procedure LoadPreviewFromStream(AStream: TStream; AOpenMode: DWORD;
      APreview: TDSciPreviewExtensionForm); override;
    procedure LoadPreviewFromFile(const AFileName: UnicodeString; AOpenMode: DWORD;
      APreview: TDSciPreviewExtensionForm); override;
{$ELSE}
  protected
    procedure FillProgIDList(AList: TStrings); override;
    function CreatePreview(AParent: HWND): TdecShellPreviewExtensionForm; override;
    procedure LoadPreviewFromStream(AStream: TStream; AOpenMode: DWORD;
      APreview: TdecShellPreviewExtensionForm); override;
    procedure LoadPreviewFromFile(const AFileName: UnicodeString; AOpenMode: DWORD;
      APreview: TdecShellPreviewExtensionForm); override;
{$ENDIF}
  end;

implementation

uses
  System.Math, Winapi.KnownFolders, System.Win.Registry, VCL.Themes,
  DScintillaDefaultConfig, DScintillaSettings
  ;

{$R *.dfm}

  {$region ' globals & helpers'}
const
  cAppDataDirName = 'dscisrcvwr';
  cConfigFileName = 'dscisrcvwr.config.xml';
  cLogFileName    = 'dscisrcvwr.log';

var
  GCachedExtensions: string = '';
  GConfigDir: string = '';
  GSavedExceptProc: Pointer = nil;

function GetOwnDllDir: string;
var
  LBuf: array[0..MAX_PATH] of Char;
  LModule: HMODULE;
begin
  LModule := FindClassHInstance(TSourceCodePreviewExtensionForm);
  SetString(Result, LBuf, GetModuleFileName(LModule, LBuf, Length(LBuf)));
  Result := ExtractFilePath(Result);
end;

{$IFnDEF NO_SHELLACE}
function ThemedColor(AColor: TColor): TColor;
begin
  Result := TStyleManager.ActiveStyle.GetSystemColor(AColor);
end;
{$ENDIF}

// Returns %USERPROFILE%\AppData\LocalLow via SHGetKnownFolderPath.
// Shell Preview Handlers (Vista+) by default run at Low Integrity Level and can write to
// LocalLow but not to CSIDL_COMMON_APPDATA (C:\ProgramData, Medium IL).
function GetLocalLowPath: string;
var
  LPtr: PWideChar;
begin
  LPtr := nil;
  try
    if SHGetKnownFolderPath(FOLDERID_LocalAppDataLow, 0, 0, LPtr) = S_OK then
      Result := LPtr
    else
    begin
      Result := GetEnvironmentVariable('USERPROFILE');
      if Result <> '' then
        Result := IncludeTrailingPathDelimiter(Result) + 'AppData\LocalLow';
    end;
  finally
    CoTaskMemFree(LPtr);
  end;
end;

function GetConfigDir: string;
var
  LLocalLow: string;
begin
  if GConfigDir = '' then
  begin
    LLocalLow := GetLocalLowPath;
    GConfigDir := IncludeTrailingPathDelimiter(LLocalLow) + cAppDataDirName;
  end;
  Result := GConfigDir;
end;

function GetConfigFilePath: string;
begin
  Result := IncludeTrailingPathDelimiter(GetConfigDir) + cConfigFileName;
end;

function GetLogFilePath: string;
begin
  Result := IncludeTrailingPathDelimiter(GetConfigDir) + cLogFileName;
end;

procedure EnsureConfigFileExists;
begin
  try
    ForceDirectories(GetConfigDir);
    DScintillaDefaultConfig.EnsureDefaultConfigFile(GetConfigFilePath);
  except
    on E: Exception do
      DSciLog('EnsureConfigFileExists: ' + E.Message, cDSciLogError);
  end;
end;

function GetHandledExtensions: string;
var
  LConfig: TDSciVisualConfig;
  LStream: TStream;
begin
  if GCachedExtensions = '' then
  begin
    try
      EnsureConfigFileExists;
    except
      on E: Exception do
        DSciLog('GetHandledExtensions.EnsureConfig: ' + E.Message, cDSciLogError);
    end;
    LConfig := TDSciVisualConfig.Create;
    try
      try
        LConfig.LoadFromFile(GetConfigFilePath);
      except
        on E: Exception do
        begin
          DSciLog('GetHandledExtensions: config file load failed (' + E.Message +
            '), using embedded resource', cDSciLogError);
          LStream := OpenDefaultConfigStream;
          try
            LConfig.LoadFromStream(LStream);
          finally
            LStream.Free;
          end;
        end;
      end;
      GCachedExtensions := LConfig.BuildHandledExtensions;
      DSciLog('GetHandledExtensions: ' + IntToStr(Length(GCachedExtensions)) + ' chars', cDSciLogInfo);
    finally
      LConfig.Free;
    end;
  end;
  Result := GCachedExtensions;
end;

function GetShiftState: TShiftState;
begin
  Result := [];
  if GetKeyState(VK_SHIFT) < 0 then Include(Result, ssShift);
  if GetKeyState(VK_CONTROL) < 0 then Include(Result, ssCtrl);
  if GetKeyState(VK_MENU) < 0 then Include(Result, ssAlt);
end;

type
  TGlobalExceptionHandler = class
    procedure HandleException(Sender: TObject; E: Exception);
  end;

var
  GExceptionHandler: TGlobalExceptionHandler;

procedure TGlobalExceptionHandler.HandleException(Sender: TObject; E: Exception);
begin
  try
    DSciLog(Format('Application.OnException: [%s] %s', [E.ClassName, E.Message]), cDSciLogError);
  except
    // Must never propagate from a DLL
  end;
end;

procedure GlobalExceptProc(ExceptObject: TObject; ExceptAddr: Pointer);
begin
  try
    if ExceptObject is Exception then
      DSciLog(Format('ExceptProc: [%s] %s at %p',
        [ExceptObject.ClassName, Exception(ExceptObject).Message, ExceptAddr]), cDSciLogError)
    else if ExceptObject <> nil then
      DSciLog(Format('ExceptProc: [%s] at %p',
        [ExceptObject.ClassName, ExceptAddr]), cDSciLogError)
    else
      DSciLog(Format('ExceptProc: nil at %p', [ExceptAddr]), cDSciLogError);
  except
    // Must never propagate from a DLL
  end;
end;

// Re-applies the preview handler's fixed logging settings.
// Must be called after every LoadConfigFile because DScintillaSettings overwrites
// the global logger variables (_DSciLogEnabled etc.) from the config model,
// which defaults to logging disabled.
procedure ApplyLoggingSettings;
begin
  SetDSciLogPath(GetLogFilePath);
  SetDSciLogEnabled(True);
  SetDSciLogLevel(cDSciLogDebug);
  SetDSciLogOutput(cDSciOutputFile);
end;

procedure InitializeLogging;
begin
  try
    ForceDirectories(GetConfigDir);
  except
    // Ignore
  end;
  ApplyLoggingSettings;
  DSciLog('=== DSciSrcVwr loaded (PID=' + IntToStr(GetCurrentProcessId) + ') ===', cDSciLogInfo);
end;

procedure InitializeExceptionHandlers;
begin
  GExceptionHandler := TGlobalExceptionHandler.Create;
  if Assigned(Application) then
    Application.OnException := GExceptionHandler.HandleException;
  GSavedExceptProc := System.ExceptProc;
  System.ExceptProc := @GlobalExceptProc;
end;

procedure FinalizeExceptionHandlers;
begin
  System.ExceptProc := GSavedExceptProc;
  if Assigned(Application) and Assigned(GExceptionHandler) then
    Application.OnException := nil;
  FreeAndNil(GExceptionHandler);
end;

{$endregion}

{$region '  TSourceCodePreviewExtensionForm'}
class function TSourceCodePreviewExtensionForm.ScaleDpi(AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, Screen.PixelsPerInch, 96);
end;

procedure TSourceCodePreviewExtensionForm.AfterConstruction;
begin
  inherited;
{$IFDEF DARK_MODE_EXPERIMENTS}
{$IFDEF NO_SHELLACE}
  if IsWindowsDarkTheme then
    EnableImmersiveDarkMode(True)
  else
    EnableImmersiveDarkMode(False);
{$ELSE}
  // Allow dark mode for the whole process so that GetSysColor and common
  // controls return the correct dark/light values for the active Windows theme.
  AllowDarkModeForApp(IsWindowsDarkTheme);
{$ENDIF}
{$ENDIF DARK_MODE_EXPERIMENTS}
  DSciLog('PreviewForm.AfterConstruction', cDSciLogInfo);
  try
    FSearchMatches := TList<TDSciSearchMatch>.Create;
    FCurrentSearchIndex := -1;
    BuildSearchBar;
    BuildContextMenu;
    InitializeEditor;
  except
    on E: Exception do
      DSciLog('PreviewForm.AfterConstruction FAILED: ' + E.Message, cDSciLogError);
  end;
end;

destructor TSourceCodePreviewExtensionForm.Destroy;
begin
  DSciLog('PreviewForm.Destroy', cDSciLogDebug);
  try
    FreeAndNil(FFindDialog);
    FreeAndNil(FGotoDialog);
    FreeAndNil(FSearchMatches);
    FreeAndNil(FContextMenu);
  except
    on E: Exception do
      DSciLog('PreviewForm.Destroy error: ' + E.Message, cDSciLogError);
  end;
  inherited;
end;

procedure TSourceCodePreviewExtensionForm.InitializeEditor;
begin
  FEditor := TDScintilla.Create(Self);
  {$IFDEF WIN64}
  FEditor.DllModule := GetOwnDllDir + 'Scintilla64.dll';
  {$ELSE}
  FEditor.DllModule := GetOwnDllDir + 'Scintilla.dll';
  {$ENDIF}
  DSciLog('DllModule=' + FEditor.DllModule, cDSciLogInfo);

  FEditor.Parent := Self;
  FEditor.Align := alClient;
  FEditor.UseDefaultContextMenu := False;
  FEditor.PopupMenu := FContextMenu;

  // Event handlers
  FEditor.OnDblClick := EditorDblClick;
  FEditor.OnMarginClick := EditorMarginClick;
  FEditor.OnUpdateUI := EditorUpdateUI;

  ConfigureEditorSurface;
  ResolveAndLoadConfig;
  FEditor.ReadOnly := True;
end;

procedure TSourceCodePreviewExtensionForm.ConfigureEditorSurface;
begin
  // Line number margin
  FEditor.MarginTypeN[cLineNumberMargin] := scmtNUMBER;
  FEditor.MarginWidthN[cLineNumberMargin] := ScaleDpi(40);
  FEditor.MarginSensitiveN[cLineNumberMargin] := False;

  // Bookmark margin
  FEditor.MarginTypeN[cBookmarkMargin] := scmtSYMBOL;
  FEditor.MarginWidthN[cBookmarkMargin] := ScaleDpi(16);
  FEditor.MarginMaskN[cBookmarkMargin] := cBookmarkMask;
  FEditor.MarginSensitiveN[cBookmarkMargin] := True;
  FEditor.MarkerDefine(cBookmarkMarker, scmsBOOKMARK);
  FEditor.MarkerSetFore(cBookmarkMarker, clNavy);
  FEditor.MarkerSetBack(cBookmarkMarker, clAqua);

  // Fold margin
  FEditor.MarginTypeN[cFoldMargin] := scmtSYMBOL;
  FEditor.MarginWidthN[cFoldMargin] := ScaleDpi(14);
  FEditor.MarginMaskN[cFoldMargin] := Integer(SC_MASK_FOLDERS);
  FEditor.MarginSensitiveN[cFoldMargin] := True;

  // Fold markers (box-style)
  FEditor.MarkerDefine(SC_MARKNUM_FOLDEROPEN, scmsBOX_MINUS);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDER, scmsBOX_PLUS);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDERSUB, scmsV_LINE);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDERTAIL, scmsL_CORNER);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDEREND, scmsBOX_PLUS_CONNECTED);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDEROPENMID, scmsBOX_MINUS_CONNECTED);
  FEditor.MarkerDefine(SC_MARKNUM_FOLDERMIDTAIL, scmsT_CORNER);

  ApplyFoldProperties;
  ConfigureSearchIndicator;
  ConfigureOccurrenceIndicator;
end;

procedure TSourceCodePreviewExtensionForm.ConfigureSearchIndicator;
begin
  FEditor.IndicStyle[cSearchIndicator] := scisROUND_BOX;
  FEditor.IndicFore[cSearchIndicator] := $0080FF; // Orange highlight
  FEditor.IndicUnder[cSearchIndicator] := False;
  FEditor.IndicSetAlphaValue(cSearchIndicator, 80);
  FEditor.IndicSetOutlineAlphaValue(cSearchIndicator, 200);
end;

procedure TSourceCodePreviewExtensionForm.ConfigureOccurrenceIndicator;
begin
  FEditor.IndicStyle[cOccurrenceIndicator] := scisROUND_BOX;
  FEditor.IndicFore[cOccurrenceIndicator] := $0080FF;
  FEditor.IndicUnder[cOccurrenceIndicator] := True;
  FEditor.IndicSetAlphaValue(cOccurrenceIndicator, 60);
  FEditor.IndicSetOutlineAlphaValue(cOccurrenceIndicator, 180);
end;

procedure TSourceCodePreviewExtensionForm.ApplyFoldProperties;
begin
  FEditor.SetProperty('fold', '1');
  FEditor.SetProperty('fold.compact', '0');
  FEditor.SetProperty('fold.comment', '1');
  FEditor.SetProperty('fold.preprocessor', '1');
end;

procedure TSourceCodePreviewExtensionForm.ResolveAndLoadConfig;
begin
  try
    EnsureConfigFileExists;
    FConfigFileName := GetConfigFilePath;
    FEditor.Settings.LoadConfigFile(FConfigFileName);
    // LoadConfigFile overwrites the global logger state from the config model
    // (defaults to disabled). Re-apply the preview handler's logging settings.
    ApplyLoggingSettings;
    DSciLog('Config loaded: ' + FConfigFileName, cDSciLogInfo);
  except
    on E: Exception do
      DSciLog('ResolveAndLoadConfig: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.BuildSearchBar;
var
  LBtnWidth: Integer;
begin
  LBtnWidth := ScaleDpi(36);

{$IFDEF DARK_MODE_EXPERIMENTS}
  // Use AllowDarkModeForWindow so native Win32 controls (TEdit, TButton, TCheckBox)
  // paint in dark mode, and explicitly set Color/Font.Color for VCL-painted controls
  // (TPanel, TLabel) via ApplySearchBarColors (called on panel open and WM_THEMECHANGED).
{$ENDIF}
  DSciLog('BuildSearchBar', cDSciLogDebug);

  // Outer panel — two rows tall, docked to bottom
  FSearchPanel := TPanel.Create(Self);
  FSearchPanel.Parent := Self;
  FSearchPanel.Align := alBottom;
  FSearchPanel.Height := ScaleDpi(72);
  FSearchPanel.BevelOuter := bvNone;
  FSearchPanel.Visible := False;
  FSearchPanel.ParentColor := True;
  FSearchPanel.ParentFont := True;

  // Row 1 — search edit + Prev/Next/Close buttons
  FSearchRowPanel := TPanel.Create(FSearchPanel);
  FSearchRowPanel.Parent := FSearchPanel;
  FSearchRowPanel.Align := alTop;
  FSearchRowPanel.Height := ScaleDpi(36);
  FSearchRowPanel.BevelOuter := bvNone;
  FSearchRowPanel.Padding.Left := ScaleDpi(6);
  FSearchRowPanel.Padding.Top := ScaleDpi(4);
  FSearchRowPanel.Padding.Right := ScaleDpi(6);

  // With alRight, last-created control is rightmost. Order: prev → next → close.
  FSearchPrevButton := TButton.Create(FSearchRowPanel);
  FSearchPrevButton.Parent := FSearchRowPanel;
  FSearchPrevButton.AlignWithMargins := True;
  FSearchPrevButton.Align := alRight;
  FSearchPrevButton.Width := LBtnWidth;
  FSearchPrevButton.Caption := #$25B2; // ▲
  FSearchPrevButton.Hint := 'Find Previous (Shift+F3)';
  FSearchPrevButton.ShowHint := True;
  FSearchPrevButton.OnClick := SearchPrevClick;

  FSearchNextButton := TButton.Create(FSearchRowPanel);
  FSearchNextButton.Parent := FSearchRowPanel;
  FSearchNextButton.AlignWithMargins := True;
  FSearchNextButton.Align := alRight;
  FSearchNextButton.Width := LBtnWidth;
  FSearchNextButton.Caption := #$25BC; // ▼
  FSearchNextButton.Hint := 'Find Next (F3)';
  FSearchNextButton.ShowHint := True;
  FSearchNextButton.OnClick := SearchNextClick;

  FSearchCloseButton := TButton.Create(FSearchRowPanel);
  FSearchCloseButton.Parent := FSearchRowPanel;
  FSearchCloseButton.AlignWithMargins := True;
  FSearchCloseButton.Align := alRight;
  FSearchCloseButton.Width := LBtnWidth;
  FSearchCloseButton.Caption := #$00D7; // ×
  FSearchCloseButton.Hint := 'Close (Esc)';
  FSearchCloseButton.ShowHint := True;
  FSearchCloseButton.OnClick := SearchCloseClick;

  FSearchEdit := TEdit.Create(FSearchRowPanel);
  FSearchEdit.Parent := FSearchRowPanel;
  FSearchEdit.AlignWithMargins := True;
  FSearchEdit.Align := alClient;
  FSearchEdit.TextHint := 'Search...';
  FSearchEdit.OnChange := SearchEditChange;
  FSearchEdit.OnKeyDown := SearchEditKeyDown;

  // Row 2 — checkboxes (left) + match counter (right)
  FSearchOptionsPanel := TPanel.Create(FSearchPanel);
  FSearchOptionsPanel.Parent := FSearchPanel;
  FSearchOptionsPanel.Align := alClient;
  FSearchOptionsPanel.BevelOuter := bvNone;
  FSearchOptionsPanel.Padding.Left := ScaleDpi(6);
  FSearchOptionsPanel.Padding.Right := ScaleDpi(6);

  FSearchStatusLabel := TLabel.Create(FSearchOptionsPanel);
  FSearchStatusLabel.Parent := FSearchOptionsPanel;
  FSearchStatusLabel.AlignWithMargins := True;
  FSearchStatusLabel.Align := alRight;
  FSearchStatusLabel.Alignment := taRightJustify;
  FSearchStatusLabel.AutoSize := False;
  FSearchStatusLabel.Width := ScaleDpi(90);
  FSearchStatusLabel.Layout := tlCenter;
  FSearchStatusLabel.Caption := '';

  FSearchCaseCheck := TCheckBox.Create(FSearchOptionsPanel);
  FSearchCaseCheck.Parent := FSearchOptionsPanel;
  FSearchCaseCheck.AlignWithMargins := True;
  FSearchCaseCheck.Align := alLeft;
  FSearchCaseCheck.Width := ScaleDpi(100);
  FSearchCaseCheck.Caption := 'Match case';
  FSearchCaseCheck.OnClick := SearchOptionClick;

  FSearchWholeWordCheck := TCheckBox.Create(FSearchOptionsPanel);
  FSearchWholeWordCheck.Parent := FSearchOptionsPanel;
  FSearchWholeWordCheck.AlignWithMargins := True;
  FSearchWholeWordCheck.Align := alLeft;
  FSearchWholeWordCheck.Width := ScaleDpi(110);
  FSearchWholeWordCheck.Caption := 'Whole words';
  FSearchWholeWordCheck.OnClick := SearchOptionClick;

{$IFDEF DARK_MODE_EXPERIMENTS}
  // Use owner-draw so checkboxes paint correctly in both light and dark themes.
  // WM_DRAWITEM is sent to the parent panel; intercept it via a WindowProc hook.
  FOrigOptionsPanelWndProc := FSearchOptionsPanel.WindowProc;
  FSearchOptionsPanel.WindowProc := OptionsPanelWndProc;
  // Replace the AUTOCHECKBOX type bits ($3) with BS_OWNERDRAW ($B)
  SetWindowLong(FSearchCaseCheck.Handle, GWL_STYLE,
    (GetWindowLong(FSearchCaseCheck.Handle, GWL_STYLE) and (not $0F)) or $0B);
  SetWindowLong(FSearchWholeWordCheck.Handle, GWL_STYLE,
    (GetWindowLong(FSearchWholeWordCheck.Handle, GWL_STYLE) and (not $0F)) or $0B);
{$ENDIF}
end;

procedure TSourceCodePreviewExtensionForm.BuildContextMenu;
var
  LItem: TMenuItem;
  LFoldMenu: TMenuItem;
begin
  FContextMenu := TPopupMenu.Create(Self);

  LItem := TMenuItem.Create(FContextMenu);
  LItem.Caption := 'Copy';
  LItem.ShortCut := Menus.ShortCut(Ord('C'), [ssCtrl]);
  LItem.OnClick := MenuCopyClick;
  FContextMenu.Items.Add(LItem);

  LItem := TMenuItem.Create(FContextMenu);
  LItem.Caption := 'Copy as HTML';
  LItem.OnClick := MenuCopyHtmlClick;
  FContextMenu.Items.Add(LItem);

  LItem := TMenuItem.Create(FContextMenu);
  LItem.Caption := 'Select All';
  LItem.ShortCut := Menus.ShortCut(Ord('A'), [ssCtrl]);
  LItem.OnClick := MenuSelectAllClick;
  FContextMenu.Items.Add(LItem);

  LItem := TMenuItem.Create(FContextMenu);
  LItem.Caption := '-';
  FContextMenu.Items.Add(LItem);

  LItem := TMenuItem.Create(FContextMenu);
  LItem.Caption := 'Find...';
  LItem.ShortCut := Menus.ShortCut(Ord('F'), [ssCtrl]);
  LItem.OnClick := MenuFindClick;
  FContextMenu.Items.Add(LItem);

  LItem := TMenuItem.Create(FContextMenu);
  LItem.Caption := 'Go to Line...';
  LItem.ShortCut := Menus.ShortCut(Ord('G'), [ssCtrl]);
  LItem.OnClick := MenuGotoClick;
  FContextMenu.Items.Add(LItem);

  LItem := TMenuItem.Create(FContextMenu);
  LItem.Caption := '-';
  FContextMenu.Items.Add(LItem);

  LFoldMenu := TMenuItem.Create(FContextMenu);
  LFoldMenu.Caption := 'Folding';

  LItem := TMenuItem.Create(LFoldMenu);
  LItem.Caption := 'Fold All';
  LItem.OnClick := MenuFoldAllClick;
  LFoldMenu.Add(LItem);

  LItem := TMenuItem.Create(LFoldMenu);
  LItem.Caption := 'Unfold All';
  LItem.OnClick := MenuUnfoldAllClick;
  LFoldMenu.Add(LItem);

  LItem := TMenuItem.Create(LFoldMenu);
  LItem.Caption := '-';
  LFoldMenu.Add(LItem);

  LItem := TMenuItem.Create(LFoldMenu);
  LItem.Caption := 'Fold Current';
  LItem.OnClick := MenuFoldCurrentClick;
  LFoldMenu.Add(LItem);

  LItem := TMenuItem.Create(LFoldMenu);
  LItem.Caption := 'Unfold Current';
  LItem.OnClick := MenuUnfoldCurrentClick;
  LFoldMenu.Add(LItem);

  LItem := TMenuItem.Create(LFoldMenu);
  LItem.Caption := '-';
  LFoldMenu.Add(LItem);

  LItem := TMenuItem.Create(LFoldMenu);
  LItem.Caption := 'Fold Nested';
  LItem.OnClick := MenuFoldNestedClick;
  LFoldMenu.Add(LItem);

  LItem := TMenuItem.Create(LFoldMenu);
  LItem.Caption := 'Unfold Nested';
  LItem.OnClick := MenuUnfoldNestedClick;
  LFoldMenu.Add(LItem);

  FContextMenu.Items.Add(LFoldMenu);

  LItem := TMenuItem.Create(FContextMenu);
  LItem.Caption := '-';
  FContextMenu.Items.Add(LItem);

  LItem := TMenuItem.Create(FContextMenu);
  LItem.Caption := 'Settings...';
  LItem.OnClick := MenuSettingsClick;
  FContextMenu.Items.Add(LItem);
end;

procedure TSourceCodePreviewExtensionForm.UpdateLineNumberMarginWidth;
var
  LConfig: TObject;
  LLineCount: NativeInt;
  LDigits: Integer;
  LWidth: Integer;
begin
  if not Assigned(FEditor) then Exit;
  // Honour the line-numbering visibility set by ApplyConfigLineNumbering.
  // When line numbers are disabled the settings system sets width=0; do not
  // override that with a computed positive value.
  if FEditor.Settings.GetCurrentConfig(LConfig) and
     not (LConfig as TDSciVisualConfig).LineNumbering then
    Exit;
  try
    LLineCount := FEditor.LineCount;
    LDigits := 1;
    while LLineCount >= 10 do
    begin
      Inc(LDigits);
      LLineCount := LLineCount div 10;
    end;
    if LDigits < 4 then LDigits := 4;
    LWidth := FEditor.TextWidth(STYLE_LINENUMBER, StringOfChar('9', LDigits + 1));
    FEditor.MarginWidthN[cLineNumberMargin] := LWidth;
  except
    on E: Exception do
      DSciLog('UpdateLineNumberMarginWidth: ' + E.Message, cDSciLogError);
  end;
end;

{$IFNDEF NO_SHELLACE}
procedure TSourceCodePreviewExtensionForm.SetFocus;
begin
  // WM_ACTIVATE is not delivered to WS_CHILD windows, so TCustomForm.FActive
  // stays False for a Shell-embedded form (ParentWindow set, no VCL Parent).
  // TCustomForm.SetFocus raises EInvalidOperation (SCannotFocus) when
  // not FActive and not (Visible and Enabled).
  // ShellACE catches this at the COM level, but it is cleaner to avoid it.
  if (Parent = nil) and HandleAllocated then
    Winapi.Windows.SetFocus(Handle)
  else
    inherited SetFocus;
end;

procedure TSourceCodePreviewExtensionForm.DestroyWnd;
begin
  if csRecreating in ControlState then
  begin
    // Detach the window to Application temporarily so child windows (Scintilla)
    // keep their internal state (document content, undo history, etc.).
    // Restored in CreateWnd.
    Winapi.Windows.SetParent(WindowHandle, Application.Handle);
    FSavedHandle := WindowHandle;
    WindowHandle := 0;
  end
  else
  begin
    FSavedHandle := 0;
    inherited DestroyWnd;
  end;
end;

procedure TSourceCodePreviewExtensionForm.CreateWnd;
begin
  if (FSavedHandle <> 0) and IsWindow(FSavedHandle) then
  begin
    WindowHandle := FSavedHandle;
    FSavedHandle := 0;
    if ParentWindow <> 0 then
      Winapi.Windows.SetParent(WindowHandle, ParentWindow)
    else if Parent <> nil then
      Winapi.Windows.SetParent(WindowHandle, Parent.Handle);
    Winapi.Windows.MoveWindow(WindowHandle, Left, Top, Width, Height, True);
    Realign;
  end
  else
    inherited CreateWnd;
end;
{$ENDIF}

procedure TSourceCodePreviewExtensionForm.ClearPreview;
begin
  DSciLog('ClearPreview', cDSciLogDebug);
  try
    // For FFindDialog (modeless): destroy it if visible or stale so that the
    // next open call gets a clean instance. Modeless Show does not use
    // DisableTaskWindows so FreeAndNil is safe here.
    if Assigned(FFindDialog) and (FFindDialog.Visible or not FFindDialog.Enabled) then
    begin
      DSciLog('ClearPreview: destroying stale FFindDialog (Visible=' +
        BoolToStr(FFindDialog.Visible, True) + ' Enabled=' +
        BoolToStr(FFindDialog.Enabled, True) + ')', cDSciLogDebug);
      FreeAndNil(FFindDialog);
    end;
    // For FGotoDialog (modal): do NOT call FreeAndNil while Execute/ShowModal may
    // still be running in this thread's call stack (ClearPreview can be reached
    // via a COM call dispatched by ShowModal's inner message pump). Setting
    // ModalResult exits the modal loop gracefully; OpenGotoDialog's finally block
    // owns the actual Free. Set the field to nil so re-entrancy guards see it gone.
    if Assigned(FGotoDialog) then
    begin
      DSciLog('ClearPreview: cancelling GotoDialog (Visible=' +
        BoolToStr(FGotoDialog.Visible, True) + ' Enabled=' +
        BoolToStr(FGotoDialog.Enabled, True) + ')', cDSciLogDebug);
      FGotoDialog.ModalResult := mrCancel;
      FGotoDialog := nil;
    end;
    // For FVisualSettingsDialog (modal): same pattern as FGotoDialog 
    // signal mrCancel so ShowModal exits; MenuSettingsClick's finally block
    // owns the actual Free.
    if Assigned(FVisualSettingsDialog) then
    begin
      DSciLog('ClearPreview: cancelling VisualSettingsDialog (Visible=' +
        BoolToStr(FVisualSettingsDialog.Visible, True) + ')', cDSciLogDebug);
      FVisualSettingsDialog.ModalResult := mrCancel;
      FVisualSettingsDialog := nil;
    end;
    if Assigned(FEditor) then
    begin
      FEditor.ReadOnly := False;
      FEditor.ClearAll;
      FEditor.ReadOnly := True;
    end;
    FCurrentFileName := '';
    FHighlightedIdentifier := '';
    if Assigned(FSearchMatches) then
      FSearchMatches.Clear;
    FCurrentSearchIndex := -1;
    CloseInlineSearch;
  except
    on E: Exception do
      DSciLog('ClearPreview error: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.LoadPreviewFromFile(const AFileName: string);
begin
  DSciLog('LoadPreviewFromFile: ' + AFileName, cDSciLogInfo);
  try
    FCurrentFileName := AFileName;
    FEditor.ReadOnly := False;
    FEditor.ClearAll;

    if not FEditor.LoadFromFile(AFileName) then
    begin
      DSciLog('LoadPreviewFromFile: LoadFromFile returned False (file may exceed size limit or not exist)', cDSciLogInfo);
      FEditor.ReadOnly := True;
      Exit;
    end;
    FEditor.ReapplyPreferredLanguageSelection;
    FEditor.Colourise(0, -1);

    FEditor.ReadOnly := True;
    FEditor.GotoPos(0);
    UpdateLineNumberMarginWidth;
    ApplyFoldProperties;
    DSciLog('LoadPreviewFromFile OK: ' + IntToStr(FEditor.LineCount) + ' lines', cDSciLogInfo);
  except
    on E: Exception do
    begin
      DSciLog('LoadPreviewFromFile FAILED: ' + E.Message, cDSciLogError);
      FEditor.ReadOnly := True;
    end;
  end;
end;

procedure TSourceCodePreviewExtensionForm.LoadPreviewFromStream(AStream: TStream; const AFileName: string);
var
  LBytes: TBytes;
  LText: string;
  LEncoding: TEncoding;
  LBOMLen: Integer;
  LDetectedEncoding: TDSciFileEncoding;
  LDetectedCodePage: Cardinal;
  LDetectedName: UnicodeString;
  LLimit: Int64;
begin
  DSciLog('LoadPreviewFromStream: size=' + IntToStr(AStream.Size) + ', file=' + AFileName, cDSciLogInfo);
  try
    LLimit := FEditor.GetEffectiveFileSizeLimit;
    if (LLimit > 0) and (AStream.Size > LLimit) then
    begin
      DSciLog(Format('LoadPreviewFromStream: size=%d exceeds limit=%d, aborted.',
        [AStream.Size, LLimit]), cDSciLogInfo);
      FEditor.ReadOnly := True;
      Exit;
    end;
    FCurrentFileName := AFileName;
    FEditor.ReadOnly := False;
    FEditor.ClearAll;
    SetLength(LBytes, AStream.Size);
    if Length(LBytes) > 0 then
    begin
      AStream.Position := 0;
      AStream.ReadBuffer(LBytes[0], Length(LBytes));

      if not ResolveFileEncoding(LBytes, dsfeAutoDetect, LEncoding, LBOMLen,
        LDetectedEncoding, LDetectedCodePage, LDetectedName) then
        raise EInvalidOpException.Create('ResolveFileEncoding failed');

      DSciLog(Format('LoadPreviewFromStream: enc="%s" CP=%d preamble=%d',
        [LDetectedName, LDetectedCodePage, LBOMLen]), cDSciLogInfo);

      LText := LEncoding.GetString(LBytes, LBOMLen, Length(LBytes) - LBOMLen);
      if not TEncoding.IsStandardEncoding(LEncoding) then
        LEncoding.Free;

      FEditor.CodePage := SC_CP_UTF8;
      FEditor.SetText(LText);
    end;

    if FCurrentFileName <> '' then
      FEditor.Settings.ApplyLanguageForFileName(FCurrentFileName);

    FEditor.Colourise(0, -1);
    FEditor.ReadOnly := True;
    FEditor.GotoPos(0);
    UpdateLineNumberMarginWidth;
    ApplyFoldProperties;
    DSciLog('LoadPreviewFromStream OK: ' + IntToStr(FEditor.LineCount) + ' lines', cDSciLogInfo);
  except
    on E: Exception do
    begin
      DSciLog('LoadPreviewFromStream FAILED: ' + E.Message, cDSciLogError);
      FEditor.ReadOnly := True;
    end;
  end;
end;

function TSourceCodePreviewExtensionForm.TranslateAccelerator(const AMessage: TMsg): Boolean;
var
  LKey: Word;
  LShift: TShiftState;
begin
  Result := False;
  try
    // Let TAB pass through to base class for focus navigation
    if (AMessage.message = WM_KEYDOWN) and (AMessage.wParam = VK_TAB) then
      Exit(False);

    // Consume only recognised accelerators (Ctrl+F, F3, Esc, etc.).
    // For all other messages (WM_CHAR, WM_KEYUP, unconsumed WM_KEYDOWN) return
    // False so the host message loop handles TranslateMessage+DispatchMessage
    // exactly once.  Previously calling TranslateMessage+DispatchMessage here
    // AND returning True caused 4× character duplication:
    //   host TranslateMessage (1 WM_CHAR) → our TranslateMessage (2nd WM_CHAR)
    //   × our DispatchMessage + host DispatchMessage per WM_CHAR = 4 inserts.
    if AMessage.message = WM_KEYDOWN then
    begin
      LKey := AMessage.wParam;
      LShift := GetShiftState;
      HandleKeyDown(LKey, LShift);
      if LKey = 0 then
      begin
        DSciLog('[TA] accelerator consumed', cDSciLogDebug);
        Exit(True);
      end;
    end;
  except
    on E: Exception do
      DSciLog('TranslateAccelerator error: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.HandleKeyDown(var Key: Word; Shift: TShiftState);
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
    Ord('G'):
      if ssCtrl in Shift then
      begin
        OpenGotoDialog;
        Key := 0;
      end;
    VK_F3:
      begin
        if ssShift in Shift then
          FindNext(False)
        else
          FindNext(True);
        Key := 0;
      end;
    VK_ESCAPE:
      begin
        if FSearchPanel.Visible then
        begin
          CloseInlineSearch;
          Key := 0;
        end;
      end;
  end;
end;

procedure TSourceCodePreviewExtensionForm.OpenInlineSearch;
var
  LSelText: string;
begin
  try
    LSelText := string(FEditor.GetSelText);
    FSearchPanel.Visible := True;
{$IFDEF DARK_MODE_EXPERIMENTS}
    ApplySearchBarColors;
{$ENDIF}
    if (LSelText <> '') and (Pos(#13, LSelText) = 0) and (Pos(#10, LSelText) = 0) then
    begin
      FUpdatingSearchControls := True;
      try
        FSearchEdit.Text := LSelText;
      finally
        FUpdatingSearchControls := False;
      end;
      UpdateSearchHighlights;
    end;
    FSearchEdit.SetFocus;
    FSearchEdit.SelectAll;
  except
    on E: Exception do
      DSciLog('OpenInlineSearch: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.CloseInlineSearch;
begin
  if Assigned(FSearchPanel) then
    FSearchPanel.Visible := False;
  ClearSearchHighlights;
  if Assigned(FEditor) and FEditor.HandleAllocated then
    FEditor.SetFocus;
end;

procedure TSourceCodePreviewExtensionForm.OpenFindDialog;
begin
  try
    if FFindDialog = nil then
    begin
      FFindDialog := TDSciFindDialog.Create(Self);
      FFindDialog.OnExecuteSearch := DoFindDialogAction;
      FFindDialog.ReadOnly := True;  // preview handler is read-only; disables Replace/ReplaceAll buttons
      // Preview handler runs at Low IL -> programmatic SetActiveWindow/
      // SetForegroundWindow are blocked by Explorer (Medium IL). Setting
      // fsStayOnTop (WS_EX_TOPMOST) makes the dialog visible above Explorer
      // without requiring elevated privileges; user click activates it normally.
      FFindDialog.FormStyle := fsStayOnTop;
    end;
    // Re-center every time the dialog is about to become visible so that
    // Explorer window moves or first-show with unfinalized dimensions both work.
    if not FFindDialog.Visible then
      CenterFormOverSelf(FFindDialog);
    DSciLog('OpenFindDialog: showing (TOPMOST=' +
      BoolToStr(FFindDialog.FormStyle = fsStayOnTop, True) + ')', cDSciLogInfo);
    FFindDialog.Show;
  except
    on E: Exception do
      DSciLog('OpenFindDialog: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.CancelAndFreeDialogs;
begin
  // Called from WMDestroy so that modal loops exit before the HWND is torn down.
  // Without this, ShowModal's EnableTaskWindows call is never reached and the
  // caller thread remains blocked with its windows disabled.
  //
  // For FGotoDialog (modal): set ModalResult so that ShowModal's loop exits on
  // its next iteration, which calls EnableTaskWindows and returns control to
  // OpenGotoDialog's finally block (which does the actual Free).
  // Do NOT Free here the form must outlive the modal loop iteration.
  //
  // For FVisualSettingsDialog (modal): same approach as FGotoDialog.
  //
  // For FFindDialog (modeless): safe to free directly.
  if FGotoDialog <> nil then
  begin
    DSciLog('CancelAndFreeDialogs: cancelling GotoDialog (ModalResult := mrCancel)',
      cDSciLogDebug);
    FGotoDialog.ModalResult := mrCancel;
    FGotoDialog := nil;
  end;
  if FVisualSettingsDialog <> nil then
  begin
    DSciLog('CancelAndFreeDialogs: cancelling VisualSettingsDialog (ModalResult := mrCancel)',
      cDSciLogDebug);
    FVisualSettingsDialog.ModalResult := mrCancel;
    FVisualSettingsDialog := nil;
  end;
  if FFindDialog <> nil then
  begin
    DSciLog('CancelAndFreeDialogs: freeing FindDialog', cDSciLogDebug);
    FreeAndNil(FFindDialog);
  end;
end;

procedure TSourceCodePreviewExtensionForm.WMDestroy(var AMessage: TWMDestroy);
begin
  DSciLog('WMDestroy: cancelling dialogs before HWND teardown', cDSciLogDebug);
  CancelAndFreeDialogs;
  inherited;
end;

procedure TSourceCodePreviewExtensionForm.OpenGotoDialog;
var
  LResult: TDSciGotoResult;
begin
  // Re-entrancy guard: FGotoDialog is non-nil for the entire duration of
  // Execute/ShowModal. A second Ctrl+G (dispatched by the modal message pump)
  // means we are already inside OpenGotoDialog; just surface the dialog.
  if FGotoDialog <> nil then
  begin
    DSciLog('OpenGotoDialog: already open (re-entrant call) -> bringing to front',
      cDSciLogInfo);
    if FGotoDialog.HandleAllocated then
      SetWindowPos(FGotoDialog.Handle, HWND_TOPMOST, 0, 0, 0, 0,
        SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
    Exit;
  end;

  try
    // Create with nil owner so that CancelAndFreeDialogs can signal cancellation
    // (ModalResult := mrCancel) and nil the field without double-freeing: the
    // finally block owns the actual Free. If CancelAndFreeDialogs runs first and
    // nils FGotoDialog, FreeAndNil(nil) is a no-op and the caller (who holds the
    // COM reference) accepts the leak acceptable during forced shutdown.
    FGotoDialog := TDSciGotoDialog.Create(nil);
    // Preview handler runs at Low IL -> programmatic window activation is
    // blocked by Explorer (Medium IL). TOPMOST makes the dialog visible above
    // Explorer without elevated privileges; user click activates it.
    FGotoDialog.FormStyle := fsStayOnTop;
    // Pre-allocate HWND before the first Execute/ShowModal call.
    // Without this, ShowModal creates the handle inside TCustomForm.Show and
    // the immediate CM_ACTIVATE/SetFocus that follows raises
    // 'Cannot focus a disabled or invisible window' in Low-IL context.
    FGotoDialog.HandleNeeded;
    DSciLog('OpenGotoDialog: handle pre-created', cDSciLogInfo);

    CenterFormOverSelf(FGotoDialog);
    DSciLog('OpenGotoDialog: showing dialog', cDSciLogInfo);
    LResult := FGotoDialog.Execute(
      FEditor.LineFromPosition(FEditor.CurrentPos) + 1,
      FEditor.LineCount,
      FEditor.CurrentPos,
      FEditor.TextLength);
  finally
    FreeAndNil(FGotoDialog);
  end;

  if LResult.Accepted then
  begin
    case LResult.Mode of
      dgmLine:     FEditor.GotoLine(LResult.Value - 1);
      dgmPosition: FEditor.GotoPos(LResult.Value);
    end;
    FEditor.SetFocus;
  end;
end;

function TSourceCodePreviewExtensionForm.BuildSearchFlags(ACaseSensitive, AWholeWord: Boolean): TDSciFindOptionSet;
begin
  Result := [];
  if ACaseSensitive then
    Include(Result, scfoMATCH_CASE);
  if AWholeWord then
    Include(Result, scfoWHOLE_WORD);
end;

procedure TSourceCodePreviewExtensionForm.UpdateSearchHighlights;
var
  LQuery: string;
  LFlags: TDSciFindOptionSet;
  LMatch: TDSciSearchMatch;
  LTextLen: NativeInt;
  LMatchStart: NativeInt;
begin
  ClearSearchHighlights;
  if FSearchEdit.Text = '' then
  begin
    FSearchStatusLabel.Caption := '';
    Exit;
  end;

  try
    LQuery := FSearchEdit.Text;
    LFlags := BuildSearchFlags(FSearchCaseCheck.Checked, FSearchWholeWordCheck.Checked);
    LTextLen := FEditor.TextLength;

    FEditor.IndicatorCurrent := cSearchIndicator;
    FEditor.IndicatorValue := 1;
    FEditor.SearchFlags := LFlags;

    LMatchStart := 0;
    while LMatchStart <= LTextLen do
    begin
      FEditor.TargetStart := LMatchStart;
      FEditor.TargetEnd := LTextLen;
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

    if FSearchMatches.Count > 0 then
      FSearchStatusLabel.Caption := IntToStr(FSearchMatches.Count) + ' matches'
    else
      FSearchStatusLabel.Caption := 'No matches';
  except
    on E: Exception do
      DSciLog('UpdateSearchHighlights: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.ClearSearchHighlights;
begin
  if not Assigned(FEditor) then Exit;
  if not Assigned(FSearchMatches) then Exit;
  try
    FEditor.IndicatorCurrent := cSearchIndicator;
    FEditor.IndicatorClearRange(0, FEditor.TextLength);
    FSearchMatches.Clear;
    FCurrentSearchIndex := -1;
  except
    on E: Exception do
      DSciLog('ClearSearchHighlights: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.SelectSearchResult(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= FSearchMatches.Count) then Exit;
  try
    FCurrentSearchIndex := AIndex;
    FEditor.SetSel(FSearchMatches[AIndex].StartPos, FSearchMatches[AIndex].EndPos);
    FEditor.ScrollCaret;
    FSearchStatusLabel.Caption := Format('%d / %d', [AIndex + 1, FSearchMatches.Count]);
  except
    on E: Exception do
      DSciLog('SelectSearchResult: ' + E.Message, cDSciLogError);
  end;
end;

function TSourceCodePreviewExtensionForm.FindNext(AForward: Boolean; AWrap: Boolean): Boolean;
var
  LCaretPos: NativeInt;
  I: Integer;
begin
  Result := False;
  if FSearchMatches.Count = 0 then
  begin
    // If inline search is visible, try executing a search first
    if FSearchPanel.Visible and (FSearchEdit.Text <> '') then
      UpdateSearchHighlights;
    if FSearchMatches.Count = 0 then Exit;
  end;

  LCaretPos := FEditor.CurrentPos;

  if AForward then
  begin
    // Find first match after caret
    for I := 0 to FSearchMatches.Count - 1 do
      if FSearchMatches[I].StartPos >= LCaretPos then
      begin
        SelectSearchResult(I);
        Exit(True);
      end;
    // Wrap
    if AWrap and (FSearchMatches.Count > 0) then
    begin
      SelectSearchResult(0);
      Exit(True);
    end;
  end
  else
  begin
    // Find last match before caret
    for I := FSearchMatches.Count - 1 downto 0 do
      if FSearchMatches[I].EndPos <= LCaretPos then
      begin
        SelectSearchResult(I);
        Exit(True);
      end;
    // Wrap
    if AWrap and (FSearchMatches.Count > 0) then
    begin
      SelectSearchResult(FSearchMatches.Count - 1);
      Exit(True);
    end;
  end;
end;

procedure TSourceCodePreviewExtensionForm.ExecuteInlineSearch(AForward: Boolean);
begin
  UpdateSearchHighlights;
  if FSearchMatches.Count > 0 then
    FindNext(AForward);
end;

function TSourceCodePreviewExtensionForm.IsIdentChar(ACh: Char): Boolean;
begin
  Result := CharInSet(ACh, ['a'..'z', 'A'..'Z', '0'..'9', '_']);
end;

{$IFDEF DARK_MODE_EXPERIMENTS}
class function TSourceCodePreviewExtensionForm.IsWindowsDarkTheme: Boolean;
var
  Reg: TRegistry;
begin
{$IFnDEF NO_SHELLACE}
  Result := False;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize') then
    begin
      if Reg.ValueExists('AppsUseLightTheme') then
        Result := (Reg.ReadInteger('AppsUseLightTheme') = 0);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
{$ELSE}
  Result := DSciPreviewBase.IsWindowsDarkTheme;
{$ENDIF}
end;
{$ENDIF DARK_MODE_EXPERIMENTS}

procedure TSourceCodePreviewExtensionForm.ClearOccurrenceHighlights;
begin
  if not Assigned(FEditor) then Exit;
  try
    FEditor.IndicatorCurrent := cOccurrenceIndicator;
    FEditor.IndicatorClearRange(0, FEditor.TextLength);
    FHighlightedIdentifier := '';
  except
    on E: Exception do
      DSciLog('ClearOccurrenceHighlights: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.HighlightIdentifierOccurrences(const AIdentifier: string);
var
  LPreviousFlags: TDSciFindOptionSet;
  LTextLen: NativeInt;
  LSearchStart: NativeInt;
  LMatchStart: NativeInt;
  LMatchEnd: NativeInt;
begin
  ClearOccurrenceHighlights;
  if AIdentifier = '' then Exit;

  try
    FHighlightedIdentifier := AIdentifier;
    LTextLen := FEditor.TextLength;

    LPreviousFlags := FEditor.SearchFlags;
    try
      FEditor.SearchFlags := [scfoMATCH_CASE, scfoWHOLE_WORD];
      FEditor.IndicatorCurrent := cOccurrenceIndicator;
      FEditor.IndicatorValue := 1;

      LSearchStart := 0;
      while LSearchStart <= LTextLen do
      begin
        FEditor.TargetStart := LSearchStart;
        FEditor.TargetEnd := LTextLen;
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
  except
    on E: Exception do
      DSciLog('HighlightIdentifierOccurrences: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.ToggleBookmarkAtLine(ALine: NativeInt);
begin
  try
    if (FEditor.MarkerGet(ALine) and cBookmarkMask) <> 0 then
      FEditor.MarkerDelete(ALine, cBookmarkMarker)
    else
      FEditor.MarkerAdd(ALine, cBookmarkMarker);
  except
    on E: Exception do
      DSciLog('ToggleBookmarkAtLine: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.EditorDblClick(Sender: TObject);
begin
  // Post a message to handle after double-click selection completes
  PostMessage(Handle, cHighlightSelectionMatchesMessage, 0, 0);
end;

procedure TSourceCodePreviewExtensionForm.WMHighlightSelectionMatches(var AMessage: TMessage);
var
  LSelText: string;
  I: Integer;
  LIsIdent: Boolean;
begin
  try
    LSelText := string(FEditor.GetSelText);
    if LSelText = '' then
    begin
      ClearOccurrenceHighlights;
      Exit;
    end;

    // Check if selection is an identifier
    LIsIdent := True;
    for I := 1 to Length(LSelText) do
      if not IsIdentChar(LSelText[I]) then
      begin
        LIsIdent := False;
        Break;
      end;

    if LIsIdent and (LSelText <> FHighlightedIdentifier) then
      HighlightIdentifierOccurrences(LSelText)
    else if not LIsIdent then
      ClearOccurrenceHighlights;
  except
    on E: Exception do
      DSciLog('WMHighlightSelectionMatches: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.EditorMarginClick(ASender: TObject;
  AModifiers: Integer; APosition: NativeInt; AMargin: Integer);
var
  LLine: NativeInt;
begin
  try
    LLine := FEditor.LineFromPosition(APosition);
    case AMargin of
      cBookmarkMargin:
        ToggleBookmarkAtLine(LLine);
      cFoldMargin:
        FEditor.ToggleFold(LLine);
    end;
  except
    on E: Exception do
      DSciLog('EditorMarginClick: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.EditorUpdateUI(ASender: TObject; AUpdated: TDSciUpdateFlagsSet);
begin
  // Could be used for status updates or bracket matching
end;

procedure TSourceCodePreviewExtensionForm.SearchEditChange(Sender: TObject);
begin
  if FUpdatingSearchControls then Exit;
  UpdateSearchHighlights;
  if FSearchMatches.Count > 0 then
    FindNext(True);
end;

procedure TSourceCodePreviewExtensionForm.SearchEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      begin
        if ssShift in Shift then
          FindNext(False)
        else
          FindNext(True);
        Key := 0;
      end;
    VK_ESCAPE:
      begin
        CloseInlineSearch;
        Key := 0;
      end;
  end;
end;

procedure TSourceCodePreviewExtensionForm.SearchPrevClick(Sender: TObject);
begin
  ExecuteInlineSearch(False);
end;

procedure TSourceCodePreviewExtensionForm.SearchNextClick(Sender: TObject);
begin
  ExecuteInlineSearch(True);
end;

procedure TSourceCodePreviewExtensionForm.SearchCloseClick(Sender: TObject);
begin
  CloseInlineSearch;
end;

procedure TSourceCodePreviewExtensionForm.SearchOptionClick(Sender: TObject);
begin
  if FUpdatingSearchControls then Exit;
{$IFDEF DARK_MODE_EXPERIMENTS}
  // BS_OWNERDRAW disables the native AUTOCHECKBOX toggle; do it manually.
  if Sender is TCheckBox then
  begin
    TCheckBox(Sender).Checked := not TCheckBox(Sender).Checked;
    TCheckBox(Sender).Invalidate;
  end;
{$ENDIF}
  UpdateSearchHighlights;
end;

procedure TSourceCodePreviewExtensionForm.DoFindDialogAction(Sender: TObject; const AConfig: TDSciSearchConfig; AAction: TDSciFindDialogAction);
var
  LQuery: string;
  LFlags: TDSciFindOptionSet;
  LTextLen: NativeInt;
  LMatch: TDSciSearchMatch;
  LMatchStart: NativeInt;
begin
  try
    case AAction of
      fdaFindNext, fdaFindPrevious:
      begin
        ClearSearchHighlights;
        LQuery := AConfig.Query;
        LFlags := [];
        if AConfig.MatchCase then Include(LFlags, scfoMATCH_CASE);
        if AConfig.WholeWord then Include(LFlags, scfoWHOLE_WORD);
        if AConfig.SearchMode = dsmRegularExpression then Include(LFlags, scfoREG_EXP);
        LTextLen := FEditor.TextLength;

        FEditor.IndicatorCurrent := cSearchIndicator;
        FEditor.IndicatorValue := 1;
        FEditor.SearchFlags := LFlags;

        LMatchStart := 0;
        while LMatchStart <= LTextLen do
        begin
          FEditor.TargetStart := LMatchStart;
          FEditor.TargetEnd := LTextLen;
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

        if FSearchMatches.Count > 0 then
          FindNext(AAction = fdaFindNext);
      end;
    end;
  except
    on E: Exception do
      DSciLog('DoFindDialogAction: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.MenuCopyClick(Sender: TObject);
begin
  try
    FEditor.Copy;
  except
    on E: Exception do
      DSciLog('MenuCopyClick: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.MenuCopyHtmlClick(Sender: TObject);
begin
  try
    FEditor.CopySelectionAsHtml;
  except
    on E: Exception do
      DSciLog('MenuCopyHtmlClick: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.MenuSelectAllClick(Sender: TObject);
begin
  try
    FEditor.SelectAll;
  except
    on E: Exception do
      DSciLog('MenuSelectAllClick: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.MenuFindClick(Sender: TObject);
begin
  OpenInlineSearch;
end;

procedure TSourceCodePreviewExtensionForm.MenuGotoClick(Sender: TObject);
begin
  OpenGotoDialog;
end;

procedure TSourceCodePreviewExtensionForm.MenuFoldAllClick(Sender: TObject);
begin
  try
    FEditor.FoldAll(scfaCONTRACT_EVERY_LEVEL);
  except
    on E: Exception do
      DSciLog('MenuFoldAllClick: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.MenuUnfoldAllClick(Sender: TObject);
begin
  try
    FEditor.FoldAll(scfaEXPAND);
  except
    on E: Exception do
      DSciLog('MenuUnfoldAllClick: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.MenuFoldCurrentClick(Sender: TObject);
var
  LLine, LFoldHeaderLine: NativeInt;
  LFoldLevel: Integer;
begin
  try
    LLine := FEditor.LineFromPosition(FEditor.CurrentPos);
    LFoldLevel := FEditor.SendEditor(SCI_GETFOLDLEVEL, WPARAM(LLine), 0);
    if (LFoldLevel and SC_FOLDLEVELHEADERFLAG) <> 0 then
      LFoldHeaderLine := LLine
    else
      LFoldHeaderLine := FEditor.FoldParent[LLine];
    if LFoldHeaderLine >= 0 then
      FEditor.FoldLine(LFoldHeaderLine, scfaCONTRACT);
    DSciLog('MenuFoldCurrentClick: folded header line ' + IntToStr(LFoldHeaderLine), cDSciLogInfo);
  except
    on E: Exception do
      DSciLog('MenuFoldCurrentClick: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.MenuUnfoldCurrentClick(Sender: TObject);
var
  LLine, LFoldHeaderLine: NativeInt;
  LFoldLevel: Integer;
begin
  try
    LLine := FEditor.LineFromPosition(FEditor.CurrentPos);
    LFoldLevel := FEditor.SendEditor(SCI_GETFOLDLEVEL, WPARAM(LLine), 0);
    if (LFoldLevel and SC_FOLDLEVELHEADERFLAG) <> 0 then
      LFoldHeaderLine := LLine
    else
      LFoldHeaderLine := FEditor.FoldParent[LLine];
    if LFoldHeaderLine >= 0 then
      FEditor.FoldLine(LFoldHeaderLine, scfaEXPAND);
    DSciLog('MenuUnfoldCurrentClick: unfolded header line ' + IntToStr(LFoldHeaderLine), cDSciLogInfo);
  except
    on E: Exception do
      DSciLog('MenuUnfoldCurrentClick: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.MenuFoldNestedClick(Sender: TObject);
var
  LLine, LFoldHeaderLine: NativeInt;
  LFoldLevel: Integer;
begin
  try
    LLine := FEditor.LineFromPosition(FEditor.CurrentPos);
    LFoldLevel := FEditor.SendEditor(SCI_GETFOLDLEVEL, WPARAM(LLine), 0);
    if (LFoldLevel and SC_FOLDLEVELHEADERFLAG) <> 0 then
      LFoldHeaderLine := LLine
    else
      LFoldHeaderLine := FEditor.FoldParent[LLine];
    if LFoldHeaderLine >= 0 then
      FEditor.FoldChildren(LFoldHeaderLine, scfaCONTRACT);
    DSciLog('MenuFoldNestedClick: folded children of header line ' + IntToStr(LFoldHeaderLine), cDSciLogInfo);
  except
    on E: Exception do
      DSciLog('MenuFoldNestedClick: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.MenuUnfoldNestedClick(Sender: TObject);
var
  LLine, LFoldHeaderLine: NativeInt;
  LFoldLevel: Integer;
begin
  try
    LLine := FEditor.LineFromPosition(FEditor.CurrentPos);
    LFoldLevel := FEditor.SendEditor(SCI_GETFOLDLEVEL, WPARAM(LLine), 0);
    if (LFoldLevel and SC_FOLDLEVELHEADERFLAG) <> 0 then
      LFoldHeaderLine := LLine
    else
      LFoldHeaderLine := FEditor.FoldParent[LLine];
    if LFoldHeaderLine >= 0 then
      FEditor.FoldChildren(LFoldHeaderLine, scfaEXPAND);
    DSciLog('MenuUnfoldNestedClick: unfolded children of header line ' + IntToStr(LFoldHeaderLine), cDSciLogInfo);
  except
    on E: Exception do
      DSciLog('MenuUnfoldNestedClick: ' + E.Message, cDSciLogError);
  end;
end;

procedure TSourceCodePreviewExtensionForm.CenterFormOverSelf(AForm: TForm);
var
  LOwnerRect: TRect;
begin
  // In the context of the COM host (preview handler), our form is a child of the
  // Explorer preview pane thanks to the CreateParented method. 
	// As it turns out, the poOwnerFormCenter function from the VCL cannot always correctly determine
  // the screen coordinates for the owner form TCustomActiveForm, so we have to manually center the form ourselves.
  if IsWindow(Self.Handle) and GetWindowRect(Self.Handle, LOwnerRect) then
  begin
    AForm.Position := poDesigned;
    AForm.Left := LOwnerRect.Left + ((LOwnerRect.Right - LOwnerRect.Left) - AForm.Width) div 2;
    AForm.Top := LOwnerRect.Top + ((LOwnerRect.Bottom - LOwnerRect.Top) - AForm.Height) div 2;
  end;
end;

procedure TSourceCodePreviewExtensionForm.MenuSettingsClick(Sender: TObject);
var
  LDialog: TDSciVisualSettingsDialog;
  LConfig: TDSciVisualConfig;
  LSettingsDir: string;
begin
  try
    LSettingsDir := ExtractFileDir(FConfigFileName);
    LConfig := TDSciVisualConfig.Create;
    try
      if FileExists(FConfigFileName) then
        LConfig.LoadFromFile(FConfigFileName);
      LDialog := TDSciVisualSettingsDialog.Create(Self);
      try
        LDialog.FormStyle := fsStayOnTop;  // Low IL: appear above Explorer
        CenterFormOverSelf(LDialog);
        FVisualSettingsDialog := LDialog;  // expose to ClearPreview/WMDestroy
        try
          if not LDialog.EditSettings(LSettingsDir, FConfigFileName, LConfig) then
            Exit;
        finally
          FVisualSettingsDialog := nil;
        end;
        ForceDirectories(LSettingsDir);
        LConfig.SaveToFile(FConfigFileName);
        FEditor.Settings.LoadConfigFile(FConfigFileName);
        ApplyLoggingSettings; // Re-apply: see ResolveAndLoadConfig
        if FCurrentFileName <> '' then
        begin
          // ReapplyPreferredLanguageSelection would reset the lexer because
          // TDScintilla.FCurrentFileName is empty for stream-loaded files
          // (only set via BeginLoadFromFile). Use the viewer's FCurrentFileName directly.
          DSciLog('MenuSettingsClick: re-applying language for "' + FCurrentFileName + '"',
            cDSciLogDebug);
          FEditor.Settings.ApplyLanguageForFileName(FCurrentFileName);
          FEditor.RefreshManagedStatusBar;

        end;
        FEditor.Colourise(0, -1);
      finally
        LDialog.Free;
      end;
    finally
      LConfig.Free;
    end;
  except
    on E: Exception do
      DSciLog('MenuSettingsClick: ' + E.Message, cDSciLogError);
  end;
end;

{$IFDEF DARK_MODE_EXPERIMENTS}

var
  _GEnumIsDark: BOOL = False;

function EnumChildSetDarkMode(AWnd: HWND; ALParam: LPARAM): BOOL; stdcall;
const
  BS_TYPEMASK      = $0F;
  BS_PUSHBUTTON    = $00;
  BS_DEFPUSHBUTTON = $01;
var
  LClass: array[0..255] of Char;
  LStyle: LONG;
begin
  GetClassName(AWnd, LClass, Length(LClass));
  // Never touch Scintilla it manages its own colours
  if not SameText(LClass, 'Scintilla') then
  begin
    AllowDarkModeForWindow(AWnd, _GEnumIsDark);
    if SameText(LClass, 'Button') then
    begin
      LStyle := GetWindowLong(AWnd, GWL_STYLE) and BS_TYPEMASK;
      if (LStyle = BS_PUSHBUTTON) or (LStyle = BS_DEFPUSHBUTTON) then
      begin
        // Push buttons: DarkMode_Explorer gives dark bg + white caption.
        if _GEnumIsDark then
          SetWindowTheme_(AWnd, 'DarkMode_Explorer', nil)
        else
          SetWindowTheme_(AWnd, '', nil);
      end
      else
      begin
        // Checkboxes / radio buttons: DarkMode_Explorer on these controls
        // renders them as outlined button frames (wrong).  Dark rendering is
        // driven by AllowDarkModeForWindow (called above) together with the
        // process-level AllowDarkModeForApp call in ApplySearchBarColors.
        // In light mode we reset to the default theme to undo any prior name.
        if not _GEnumIsDark then
          SetWindowTheme_(AWnd, '', nil);
      end;
    end
    else if SameText(LClass, 'Edit') then
    begin
      // Edit controls need DarkMode_CFD for dark background + light caret/text
      if _GEnumIsDark then
        SetWindowTheme_(AWnd, 'DarkMode_CFD', nil)
      else
        SetWindowTheme_(AWnd, '', nil);
    end;
    SendMessage(AWnd, WM_THEMECHANGED, 0, 0);
  end;
  Result := True;
end;

procedure TSourceCodePreviewExtensionForm.ApplySearchBarColors;
var
  LTheme: TWinThemeColors;
begin
  LTheme := GetWinThemeColors;
  DSciLog(Format('[COLOR] ApplySearchBarColors: IsDark=%s Surface=$%X FG=$%X',
    [BoolToStr(LTheme.IsDark, True),
     ColorToRGB(LTheme.Surface), ColorToRGB(LTheme.Foreground)]), cDSciLogDebug);

  // Enable/disable dark mode for the host process this is required for
  // common controls (Button, Edit, CheckBox) to render with dark theme text.
  // In a DLL preview handler context this affects the prevhost.exe process.
  AllowDarkModeForApp(LTheme.IsDark);

  // Apply dark-mode flag to the whole form and every child HWND at once.
  // EnumChildSetDarkMode skips Scintilla and applies SetWindowTheme_ on buttons.
  Self.HandleNeeded;
  AllowDarkModeForWindow(Self.Handle, LTheme.IsDark);
  _GEnumIsDark := LTheme.IsDark;
  EnumChildWindows(Self.Handle, @EnumChildSetDarkMode, 0);

  if LTheme.IsDark then
  begin
    // Setting Self.Color propagates to all VCL-painted controls that have
    // ParentColor=True (TPanel, TCheckBox, TLabel) no need to set each one.
    Self.Color          := LTheme.Surface;
    Self.Font.Color     := LTheme.Foreground;
    // TCheckBox draws its own label; its Color property controls the background
    // of the label area so it must be set explicitly even with ParentColor=True.
    FSearchCaseCheck.Color           := LTheme.Surface;
    FSearchCaseCheck.Font.Color      := LTheme.Foreground;
    FSearchWholeWordCheck.Color      := LTheme.Surface;
    FSearchWholeWordCheck.Font.Color := LTheme.Foreground;
    if Assigned(FSearchStatusLabel) then
      FSearchStatusLabel.Font.Color := LTheme.Foreground;
  end
  else
  begin
    Self.Color      := clBtnFace;
    Self.Font.Color := clWindowText;
    FSearchCaseCheck.ParentColor      := True;
    FSearchCaseCheck.ParentFont       := True;
    FSearchWholeWordCheck.ParentColor := True;
    FSearchWholeWordCheck.ParentFont  := True;
    if Assigned(FSearchStatusLabel) then
    begin
      FSearchStatusLabel.ParentColor := True;
      FSearchStatusLabel.ParentFont  := True;
    end;
  end;

  // Redraw the entire form tree; the owner-draw checkboxes get WM_DRAWITEM
  // when they are invalidated below.
  RedrawWindow(Self.Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_ALLCHILDREN);
  // Force owner-draw checkboxes to repaint with the new theme
  if Assigned(FSearchCaseCheck) and FSearchCaseCheck.HandleAllocated then
    FSearchCaseCheck.Invalidate;
  if Assigned(FSearchWholeWordCheck) and FSearchWholeWordCheck.HandleAllocated then
    FSearchWholeWordCheck.Invalidate;
end;

procedure TSourceCodePreviewExtensionForm.OptionsPanelWndProc(var AMessage: TMessage);
const
  BS_OWNERDRAW_TYPE = $0B;  // button-type value for BS_OWNERDRAW
  ODT_BUTTON        = 4;
  ODS_FOCUS         = $0010;
var
  LDI: PDrawItemStruct;
  LCanvas: TCanvas;
  LBoxW, LBoxH: Integer;
  LBoxRect, LTextRect, LItemRect: TRect;
  LChecked: Boolean;
  LCaption: array[0..255] of Char;
  LTheme: TWinThemeColors;
begin
  if (AMessage.Msg = WM_DRAWITEM) and
     Assigned(FSearchCaseCheck) and Assigned(FSearchWholeWordCheck) then
  begin
    LDI := PDrawItemStruct(AMessage.LParam);
    if (LDI^.CtlType = ODT_BUTTON) and
       ((LDI^.hwndItem = FSearchCaseCheck.Handle) or
        (LDI^.hwndItem = FSearchWholeWordCheck.Handle)) then
    begin
      LTheme   := GetWinThemeColors;
      LChecked := SendMessage(LDI^.hwndItem, BM_GETCHECK, 0, 0) = BST_CHECKED;
      LItemRect := LDI^.rcItem;

      // DPI-aware checkbox square dimensions (matches system checkmark size)
      LBoxW := GetSystemMetrics(SM_CXMENUCHECK);
      LBoxH := GetSystemMetrics(SM_CYMENUCHECK);
      LBoxRect.Left   := LItemRect.Left + 1;
      LBoxRect.Top    := LItemRect.Top + (LItemRect.Bottom - LItemRect.Top - LBoxH) div 2;
      LBoxRect.Right  := LBoxRect.Left + LBoxW;
      LBoxRect.Bottom := LBoxRect.Top  + LBoxH;

      LCanvas := TCanvas.Create;
      try
        LCanvas.Handle := LDI^.hDC;

        // Background
        LCanvas.Brush.Color := LTheme.Surface;
        LCanvas.FillRect(LItemRect);

        if LTheme.IsDark then
        begin
          LCanvas.Pen.Width := 1;
          if LChecked then
          begin
            // Filled with accent blue + white checkmark
            LCanvas.Pen.Color   := $0078D7;
            LCanvas.Brush.Color := $0078D7;
            LCanvas.Rectangle(LBoxRect);
            LCanvas.Pen.Color := clWhite;
            LCanvas.Pen.Width := 2;
            LCanvas.MoveTo(LBoxRect.Left + 2,          LBoxRect.Top  + LBoxH div 2);
            LCanvas.LineTo(LBoxRect.Left + LBoxW div 3, LBoxRect.Bottom - 3);
            LCanvas.LineTo(LBoxRect.Right - 2,          LBoxRect.Top  + 2);
            LCanvas.Pen.Width := 1;
          end
          else
          begin
            // Empty box with gray border on dark surface
            LCanvas.Pen.Color   := $808080;
            LCanvas.Brush.Color := LTheme.Surface;
            LCanvas.Rectangle(LBoxRect);
          end;
          LCanvas.Font.Color := LTheme.Foreground;
        end
        else
        begin
          // Light mode: let the system draw the classic checkbox glyph
          DrawFrameControl(LCanvas.Handle, LBoxRect, DFC_BUTTON,
            DFCS_BUTTONCHECK or (DFCS_CHECKED * Ord(LChecked)));
          LCanvas.Font.Color := clWindowText;
        end;

        // Label text (use font already selected in the DC by the system)
        GetWindowText(LDI^.hwndItem, LCaption, Length(LCaption));
        LTextRect := Rect(LBoxRect.Right + 4, LItemRect.Top,
                          LItemRect.Right,    LItemRect.Bottom);
        LCanvas.Brush.Style := bsClear;
        DrawText(LCanvas.Handle, LCaption, -1, LTextRect,
                 DT_LEFT or DT_VCENTER or DT_SINGLELINE);

        // Focus rectangle
        if (LDI^.itemState and ODS_FOCUS) <> 0 then
          DrawFocusRect(LDI^.hDC, LItemRect);
      finally
        LCanvas.Handle := 0;
        LCanvas.Free;
      end;

      AMessage.Result := 1;
      Exit;
    end;
  end;
  FOrigOptionsPanelWndProc(AMessage);
end;

procedure TSourceCodePreviewExtensionForm.WMThemeChanged(var AMessage: TMessage);
begin
  inherited;
  DSciLog('[COLOR] WM_THEMECHANGED received', cDSciLogDebug);
  if Assigned(FSearchPanel) and FSearchPanel.Visible then
    ApplySearchBarColors;
end;
{$ENDIF DARK_MODE_EXPERIMENTS}

{$endregion}

{$region '  TSourceCodePreviewExtension'}
{ TSourceCodePreviewExtension }
class function TSourceCodePreviewExtension.GetClassID: TCLSID;
begin
  Result := SID_TSourceCodePreviewExtension;
end;

class function TSourceCodePreviewExtension.GetDescription: UnicodeString;
begin
  Result := 'Scintilla Source Code Preview';
end;

procedure TSourceCodePreviewExtension.Initialize;
begin
  inherited Initialize;
  AutoBackgroundColor := False;
  AutoFont := False;
  AutoFontColor := False;
end;

{$IFDEF NO_SHELLACE}
class procedure TSourceCodePreviewExtension.FillProgIDList(AList: TStrings);
{$ELSE}
procedure TSourceCodePreviewExtension.FillProgIDList(AList: TStrings);
{$ENDIF}
var
  LExts: string;
  I, LStart: Integer;
  LExt: string;
begin
  try
    LExts := GetHandledExtensions;
    // Parse semicolon-delimited extension list: ".pas;.dpr;.cpp;..."
    LStart := 1;
    for I := 1 to Length(LExts) do
    begin
      if LExts[I] = ';' then
      begin
        LExt := Copy(LExts, LStart, I - LStart);
        if LExt <> '' then
          AList.Add(UnicodeStringToString(LExt));
        LStart := I + 1;
      end;
    end;
    // Handle trailing segment without semicolon
    if LStart <= Length(LExts) then
    begin
      LExt := Copy(LExts, LStart, MaxInt);
      if LExt <> '' then
        AList.Add(UnicodeStringToString(LExt));
    end;
    DSciLog('FillProgIDList: ' + IntToStr(AList.Count) + ' extensions', cDSciLogInfo);
  except
    on E: Exception do
      DSciLog('FillProgIDList FAILED: ' + E.Message, cDSciLogError);
  end;
end;

function TSourceCodePreviewExtension.CreatePreview(AParent: HWND): {$IFDEF NO_SHELLACE}TDSciPreviewExtensionForm{$ELSE}TdecShellPreviewExtensionForm{$ENDIF};
begin
  DSciLog('CreatePreview: parent=$' + IntToHex(AParent, 8), cDSciLogInfo);
  Result := TSourceCodePreviewExtensionForm.CreateParented(AParent);
end;

procedure TSourceCodePreviewExtension.LoadPreviewFromStream(AStream: TStream;
  AOpenMode: DWORD; APreview: {$IFDEF NO_SHELLACE}TDSciPreviewExtensionForm{$ELSE}TdecShellPreviewExtensionForm{$ENDIF});
begin
  TSourceCodePreviewExtensionForm(APreview).LoadPreviewFromStream(AStream, GetCurrentFileName(True));
end;

procedure TSourceCodePreviewExtension.LoadPreviewFromFile(const AFileName: UnicodeString;
  AOpenMode: DWORD; APreview: {$IFDEF NO_SHELLACE}TDSciPreviewExtensionForm{$ELSE}TdecShellPreviewExtensionForm{$ENDIF});
begin
  TSourceCodePreviewExtensionForm(APreview).LoadPreviewFromFile(AFileName);
end;
{$endregion}

initialization
  InitializeLogging;
  InitializeExceptionHandlers;
  TSourceCodePreviewExtension.Register;

finalization
  DSciLog('=== DSciSrcVwr unloading ===', cDSciLogInfo);
  FinalizeExceptionHandlers;

end.
