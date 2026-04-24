unit DScintillaSettings;

interface

uses
  System.Classes;

type
  TDSciSettings = class
  private
    FOwner: TComponent;
    FSettingsDirectory: string;
    FStylersModelFileName: string;
    FLanguagesModelFileName: string;
    FThemeFileName: string;
    FConfigFileName: string;
    FCurrentLanguage: string;
    FLexerLibraryLoadedFor: string;
    FConfigModel: TObject;
    FAutoCompleteModel: TObject;
    FFunctionListModel: TObject;
    FDocumentFunctions: TObject;
    FDocumentFunctionsDirty: Boolean;

    procedure ApplyRenderingOptions;
    procedure ClearLanguageServices;
    procedure RefreshDocumentFunctions;
    procedure ReloadLanguageServices;
    procedure UpdateAutoComplete;
    procedure UpdateCallTip;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;

    procedure Clear;
    procedure LoadConfigFile(const AFileName: string);
    function GetCurrentConfig(var AConfig: TObject): Boolean;
    procedure ApplyLanguage(const ALanguageName: string);
    procedure ApplyLanguageForFileName(const AFileName: string);
    procedure NotifyCharAdded(ACh: Integer);
    procedure NotifyModified;
    procedure NotifyUpdateUI(AUpdated: Integer);
    procedure Reapply;

    function ResolveLanguageNameByFileName(const AFileName: string): string;

    // Legacy stubs --> always raise ENotSupportedException
    procedure LoadSettingsDirectory(const ADir: string);
    procedure LoadStylersModel(const AFileName: string);
    procedure LoadLanguagesModel(const AFileName: string);
    function ResolveThemeFile(const AThemeName: string): string;
    procedure LoadTheme(const AThemeName: string);

    property SettingsDirectory: string read FSettingsDirectory;
    property StylersModelFileName: string read FStylersModelFileName;
    property LanguagesModelFileName: string read FLanguagesModelFileName;
    property ThemeFileName: string read FThemeFileName;
    property ConfigFileName: string read FConfigFileName;
    property CurrentLanguage: string read FCurrentLanguage;
  end;

implementation

uses
  System.Character, System.Generics.Collections, System.IOUtils, System.Math,
  System.StrUtils, System.SysUtils,
  Winapi.Windows,
  Vcl.Graphics,
  DScintilla, DScintillaBridge, DScintillaDefaultConfig, DScintillaLogger,
  DScintillaTypes, DScintillaLanguageServices, DScintillaVisualConfig;

function GetEditorComponent(AOwner: TComponent): TDScintilla;
begin
  if not (AOwner is TDScintilla) then
    raise EInvalidCast.Create('TDSciSettings owner must be TDScintilla.');
  Result := TDScintilla(AOwner);
end;

function GetVisualConfig(AValue: TObject): TDSciVisualConfig;
begin
  if AValue = nil then
    Exit(nil);
  Result := TDSciVisualConfig(AValue);
end;

function GetAutoCompleteModel(AValue: TObject): TDSciAutoCompleteModel;
begin
  if AValue = nil then
    Exit(nil);
  Result := TDSciAutoCompleteModel(AValue);
end;

function GetFunctionListModel(AValue: TObject): TDSciFunctionListModel;
begin
  if AValue = nil then
    Exit(nil);
  Result := TDSciFunctionListModel(AValue);
end;

function GetDocumentFunctions(
  AValue: TObject): TObjectList<TDSciDocumentFunction>;
begin
  if AValue = nil then
    Exit(nil);
  Result := TObjectList<TDSciDocumentFunction>(AValue);
end;

function ResolveEditorDllPath(const AEditor: TDScintilla): string;
var
  lCandidate: string;
begin
  Result := Trim(AEditor.DllModule);
  if Result = '' then
    Exit('');

  if FileExists(Result) then
    Exit(ExpandFileName(Result));

  lCandidate := ExpandFileName(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + Result);
  if FileExists(lCandidate) then
    Result := lCandidate;
end;

function IsSubStyleKeywordClass(const AKeywordClass: string): Boolean;
begin
  Result := StartsText('substyle', AKeywordClass);
end;

function FindConfigStyle(const AGroup: TDSciVisualStyleGroup;
  const AName: string): TDSciVisualStyleData;
begin
  Result := nil;
  if AGroup = nil then
    Exit;

  Result := AGroup.FindStyle(AName, dvskGlobal);
  if Result = nil then
    Result := AGroup.FindStyle(AName, dvskLexer);
end;

function ResolveConfigStyle(const ADefaultGroup, ACurrentGroup: TDSciVisualStyleGroup;
  const AName: string): TDSciVisualStyleData;
begin
  Result := FindConfigStyle(ACurrentGroup, AName);
  if Result = nil then
    Result := FindConfigStyle(ADefaultGroup, AName);
end;

function UsesPlainTextLexer(const AGroup: TDSciVisualStyleGroup): Boolean;
begin
  Result := Assigned(AGroup) and AGroup.HasLexerID and
    (AGroup.LexerID = Integer(sclNULL));
end;

procedure ApplyVisualStyleAttributes(const AEditor: TDScintilla; AStyleID: Integer;
  const AEntry: TDSciVisualStyleData);
begin
  if AEntry = nil then
    Exit;

  if AEntry.HasForeColor then
    AEditor.StyleFore[AStyleID] := AEntry.ForeColor;
  if AEntry.HasBackColor then
    AEditor.StyleBack[AStyleID] := AEntry.BackColor;
  if AEntry.FontName <> '' then
    AEditor.StyleFont[AStyleID] := AEntry.FontName;
  if AEntry.HasFontSize then
    AEditor.StyleSize[AStyleID] := AEntry.FontSize;
  if AEntry.HasFontStyle then
  begin
    AEditor.StyleBold[AStyleID] := (AEntry.FontStyle and 1) <> 0;
    AEditor.StyleItalic[AStyleID] := (AEntry.FontStyle and 2) <> 0;
    AEditor.StyleUnderline[AStyleID] := (AEntry.FontStyle and 4) <> 0;
  end;
end;

procedure ApplyConfigFoldMarkerColours(const AEditor: TDScintilla;
  const AEntry: TDSciVisualStyleData; AOpenOnly: Boolean);
const
  ALL_FOLD_MARKERS: array[0..6] of Integer = (
    SC_MARKNUM_FOLDEREND,
    SC_MARKNUM_FOLDEROPENMID,
    SC_MARKNUM_FOLDERMIDTAIL,
    SC_MARKNUM_FOLDERTAIL,
    SC_MARKNUM_FOLDERSUB,
    SC_MARKNUM_FOLDER,
    SC_MARKNUM_FOLDEROPEN
  );
  OPEN_FOLD_MARKERS: array[0..1] of Integer = (
    SC_MARKNUM_FOLDEROPENMID,
    SC_MARKNUM_FOLDEROPEN
  );
var
  lMarker: Integer;
begin
  if AEntry = nil then
    Exit;

  if AOpenOnly then
    for lMarker in OPEN_FOLD_MARKERS do
    begin
      if AEntry.HasForeColor then
        AEditor.MarkerFore[lMarker] := AEntry.ForeColor;
      if AEntry.HasBackColor then
        AEditor.MarkerBack[lMarker] := AEntry.BackColor;
    end
  else
    for lMarker in ALL_FOLD_MARKERS do
    begin
      if AEntry.HasForeColor then
        AEditor.MarkerFore[lMarker] := AEntry.ForeColor;
      if AEntry.HasBackColor then
        AEditor.MarkerBack[lMarker] := AEntry.BackColor;
    end;
end;

procedure ApplyConfigGlobalStyles(const AEditor: TDScintilla;
  const ADefaultGroup, ACurrentGroup: TDSciVisualStyleGroup);
var
  lStyle: TDSciVisualStyleData;
begin
  lStyle := ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Default Style');
  if lStyle = nil then
    lStyle := ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'DEFAULT');

  AEditor.StyleResetDefault;
  ApplyVisualStyleAttributes(AEditor, STYLE_DEFAULT, lStyle);
  AEditor.StyleClearAll;

  ApplyVisualStyleAttributes(AEditor, STYLE_LINENUMBER,
    ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Line number margin'));
  ApplyVisualStyleAttributes(AEditor, STYLE_BRACELIGHT,
    ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Brace highlight style'));
  ApplyVisualStyleAttributes(AEditor, STYLE_BRACEBAD,
    ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Bad brace colour'));
  ApplyVisualStyleAttributes(AEditor, STYLE_INDENTGUIDE,
    ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Indent guideline style'));
  ApplyConfigFoldMarkerColours(AEditor,
    ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Fold'), False);
  ApplyConfigFoldMarkerColours(AEditor,
    ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Fold active'), True);

  lStyle := ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Current line background colour');
  if (lStyle <> nil) and lStyle.HasBackColor then
  begin
    AEditor.CaretLineVisible := True;
    AEditor.CaretLineBack := lStyle.BackColor;
  end
  else
    AEditor.CaretLineVisible := False;

  lStyle := ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Selected text colour');
  if lStyle <> nil then
  begin
    if lStyle.HasForeColor then
      AEditor.SetSelFore(True, lStyle.ForeColor)
    else
      AEditor.SetSelFore(False, clBlack);

    if lStyle.HasBackColor then
      AEditor.SetSelBack(True, lStyle.BackColor)
    else
      AEditor.SetSelBack(False, clWhite);
  end;

  lStyle := ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Multi-selected text color');
  if lStyle <> nil then
  begin
    if lStyle.HasForeColor then
      AEditor.AdditionalSelFore := lStyle.ForeColor;
    if lStyle.HasBackColor then
      AEditor.AdditionalSelBack := lStyle.BackColor;
  end;

  lStyle := ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Caret colour');
  if (lStyle <> nil) and lStyle.HasForeColor then
    AEditor.CaretFore := lStyle.ForeColor;

  lStyle := ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Multi-edit carets color');
  if (lStyle <> nil) and lStyle.HasForeColor then
    AEditor.AdditionalCaretFore := lStyle.ForeColor;

  lStyle := ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Edge colour');
  if (lStyle <> nil) and lStyle.HasForeColor then
    AEditor.EdgeColour := lStyle.ForeColor;

  lStyle := ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'White space symbol');
  if (lStyle <> nil) and lStyle.HasForeColor then
    AEditor.SetWhitespaceFore(True, lStyle.ForeColor)
  else
    AEditor.SetWhitespaceFore(False, clBlack);

  lStyle := ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Fold margin');
  if lStyle <> nil then
  begin
    if lStyle.HasBackColor then
      AEditor.SetFoldMarginColour(True, lStyle.BackColor)
    else
      AEditor.SetFoldMarginColour(False, clBtnFace);

    if lStyle.HasForeColor then
      AEditor.SetFoldMarginHiColour(True, lStyle.ForeColor)
    else
      AEditor.SetFoldMarginHiColour(False, clBtnFace);
  end;
end;

procedure ApplyConfigDefaultStyle(const AEditor: TDScintilla;
  const ADefaultGroup, ACurrentGroup: TDSciVisualStyleGroup);
var
  lStyle: TDSciVisualStyleData;
begin
  lStyle := ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'Default Style');
  if lStyle = nil then
    lStyle := ResolveConfigStyle(ADefaultGroup, ACurrentGroup, 'DEFAULT');
  ApplyVisualStyleAttributes(AEditor, STYLE_DEFAULT, lStyle);
end;

function FindLineNumberMargin(const AEditor: TDScintilla): Integer;
var
  lMargin: Integer;
begin
  Result := -1;
  for lMargin := 0 to SC_MAX_MARGIN do
    if AEditor.MarginTypeN[lMargin] = scmtNUMBER then
      Exit(lMargin);
end;

function EnsureLineNumberMargin(const AEditor: TDScintilla): Integer;
begin
  Result := FindLineNumberMargin(AEditor);
  if Result >= 0 then
    Exit;

  Result := 0;
  AEditor.MarginTypeN[Result] := scmtNUMBER;
  AEditor.MarginSensitiveN[Result] := False;
end;

function EnsureLineNumberPadMargin(const AEditor: TDScintilla;
  ALineNumMargin: Integer): Integer;
begin
  Result := ALineNumMargin + 1;
  if Result > SC_MAX_MARGIN then
    Exit(-1);
  AEditor.MarginTypeN[Result] := scmtSYMBOL;
  AEditor.MarginMaskN[Result] := 0;
  AEditor.MarginSensitiveN[Result] := False;
end;

procedure ApplyConfigLineNumbering(const AEditor: TDScintilla;
  AEnabled: Boolean; AWidthMode: TDSciLineNumberWidthMode;
  APaddingLeft, APaddingRight: Integer);
const
  cFixedDigits = 6;
var
  lDigits: Integer;
  lMargin: Integer;
  lPadMargin: Integer;
  lSample: string;
  lTextWidth: Integer;
begin
  lMargin := FindLineNumberMargin(AEditor);
  if not AEnabled then
  begin
    if lMargin >= 0 then
    begin
      AEditor.MarginWidthN[lMargin] := 0;
      AEditor.MarginWidthN[lMargin + 1] := 0;
    end;
    Exit;
  end;

  lMargin := EnsureLineNumberMargin(AEditor);
  lPadMargin := EnsureLineNumberPadMargin(AEditor, lMargin);
  case AWidthMode of
    lnwmFixed:
      lDigits := cFixedDigits;
  else
    lDigits := Max(4, Length(IntToStr(Max(Int64(1), AEditor.LineCount))));
  end;
  lSample := StringOfChar('9', lDigits);
  lTextWidth := AEditor.TextWidth(STYLE_LINENUMBER, lSample);
  DSciLog(Format(
    'ApplyConfigLineNumbering margin=%d padMargin=%d padL=%d textW=%d padR=%d',
    [lMargin, lPadMargin, APaddingLeft, lTextWidth, APaddingRight]),
    cDSciLogDebug);
  AEditor.MarginWidthN[lMargin] := APaddingLeft + lTextWidth;
  if lPadMargin >= 0 then
    AEditor.MarginWidthN[lPadMargin] := APaddingRight;
  DSciLog(Format(
    'ApplyConfigLineNumbering readback: margin[%d]=%d pad[%d]=%d',
    [lMargin, AEditor.MarginWidthN[lMargin],
     lPadMargin, AEditor.MarginWidthN[Max(0, lPadMargin)]]),
    cDSciLogDebug);
end;

procedure ApplyConfigTextPadding(const AEditor: TDScintilla;
  ALeft, ARight: Integer);
begin
  DSciLog(Format('[DSCI-SETTINGS] ApplyConfigTextPadding Left=%d Right=%d.',
    [ALeft, ARight]), cDSciLogDebug);
  AEditor.SetMarginLeft(Max(0, ALeft));
  AEditor.SetMarginRight(Max(0, ARight));
end;

function FindFoldMargin(const AEditor: TDScintilla): Integer;
var
  lMargin: Integer;
begin
  Result := -1;
  for lMargin := 0 to SC_MAX_MARGIN do
    if (AEditor.MarginTypeN[lMargin] = scmtSYMBOL) and
       (AEditor.MarginMaskN[lMargin] = Integer(SC_MASK_FOLDERS)) then
      Exit(lMargin);
end;

function EnsureFoldMargin(const AEditor: TDScintilla): Integer;
const
  cDefaultFoldMarginIndex = 2;
begin
  Result := FindFoldMargin(AEditor);
  if Result >= 0 then
    Exit;
  Result := cDefaultFoldMarginIndex;
  AEditor.MarginTypeN[Result] := scmtSYMBOL;
  AEditor.MarginMaskN[Result] := Integer(SC_MASK_FOLDERS);
  AEditor.MarginSensitiveN[Result] := True;
end;

procedure DefineFoldMarkers(const AEditor: TDScintilla; AStyle: TDSciFoldMarkerStyle);
begin
  case AStyle of
    fmsArrow:
      begin
        AEditor.MarkerDefine(SC_MARKNUM_FOLDEROPEN, scmsARROW_DOWN);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDER, scmsARROW);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDERSUB, scmsEMPTY);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDERTAIL, scmsEMPTY);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDEREND, scmsARROW);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDEROPENMID, scmsARROW_DOWN);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDERMIDTAIL, scmsEMPTY);
      end;
    fmsPlusMinus:
      begin
        AEditor.MarkerDefine(SC_MARKNUM_FOLDEROPEN, scmsMINUS);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDER, scmsPLUS);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDERSUB, scmsEMPTY);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDERTAIL, scmsEMPTY);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDEREND, scmsPLUS);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDEROPENMID, scmsMINUS);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDERMIDTAIL, scmsEMPTY);
      end;
    fmsCircleTree:
      begin
        AEditor.MarkerDefine(SC_MARKNUM_FOLDEROPEN, scmsCIRCLE_MINUS);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDER, scmsCIRCLE_PLUS);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDERSUB, scmsV_LINE);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDERTAIL, scmsL_CORNER_CURVE);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDEREND, scmsCIRCLE_PLUS_CONNECTED);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDEROPENMID, scmsCIRCLE_MINUS_CONNECTED);
        AEditor.MarkerDefine(SC_MARKNUM_FOLDERMIDTAIL, scmsT_CORNER_CURVE);
      end;
  else // fmsBoxTree (default)
    begin
      AEditor.MarkerDefine(SC_MARKNUM_FOLDEROPEN, scmsBOX_MINUS);
      AEditor.MarkerDefine(SC_MARKNUM_FOLDER, scmsBOX_PLUS);
      AEditor.MarkerDefine(SC_MARKNUM_FOLDERSUB, scmsV_LINE);
      AEditor.MarkerDefine(SC_MARKNUM_FOLDERTAIL, scmsL_CORNER);
      AEditor.MarkerDefine(SC_MARKNUM_FOLDEREND, scmsBOX_PLUS_CONNECTED);
      AEditor.MarkerDefine(SC_MARKNUM_FOLDEROPENMID, scmsBOX_MINUS_CONNECTED);
      AEditor.MarkerDefine(SC_MARKNUM_FOLDERMIDTAIL, scmsT_CORNER);
    end;
  end;
end;

procedure ApplyConfigFoldMargin(const AEditor: TDScintilla; AEnabled: Boolean;
  AMarkerStyle: TDSciFoldMarkerStyle);
const
  cBaseFoldMarginWidth = 16;
var
  lMargin: Integer;
  lScaledWidth: Integer;
begin
  if not AEnabled then
  begin
    lMargin := FindFoldMargin(AEditor);
    if lMargin >= 0 then
    begin
      DSciLog(Format('Hiding fold margin %d (FoldMarginVisible=False).', [lMargin]));
      AEditor.MarginWidthN[lMargin] := 0;
    end;
    Exit;
  end;
  lMargin := EnsureFoldMargin(AEditor);
  DefineFoldMarkers(AEditor, AMarkerStyle);
  lScaledWidth := MulDiv(cBaseFoldMarginWidth, AEditor.CurrentPPI, 96);
  DSciLog(Format('Showing fold margin %d, width=%d (PPI=%d).',
    [lMargin, lScaledWidth, AEditor.CurrentPPI]));
  AEditor.MarginWidthN[lMargin] := lScaledWidth;
end;

procedure ApplyFoldProperties(const AEditor: TDScintilla);
begin
  AEditor.SetProperty('fold', '1');
  AEditor.SetProperty('fold.compact', '0');
  AEditor.SetProperty('fold.comment', '1');
  AEditor.SetProperty('fold.preprocessor', '1');
  AEditor.SetProperty('fold.html', '1');
  AEditor.SetProperty('fold.xml', '1');
end;

procedure ApplyConfigIndicators(const AEditor: TDScintilla;
  const AConfig: TDSciVisualConfig);
const
  SEARCH_INDICATOR = 0;
  OCCURRENCE_INDICATOR = 1;
begin
  AEditor.IndicSetStyle(SEARCH_INDICATOR, scisROUND_BOX);
  AEditor.IndicSetFore(SEARCH_INDICATOR, AConfig.HighlightColor);
  AEditor.IndicSetUnder(SEARCH_INDICATOR, False);
  AEditor.IndicSetAlphaValue(SEARCH_INDICATOR, AConfig.HighlightAlpha);
  AEditor.IndicSetOutlineAlphaValue(SEARCH_INDICATOR, AConfig.HighlightOutlineAlpha);

  AEditor.IndicSetStyle(OCCURRENCE_INDICATOR, AConfig.SmartHighlightStyle);
  AEditor.IndicSetFore(OCCURRENCE_INDICATOR, AConfig.HighlightColor);
  AEditor.IndicSetUnder(OCCURRENCE_INDICATOR, True);
  AEditor.IndicSetAlphaValue(OCCURRENCE_INDICATOR, AConfig.SmartHighlightFillAlpha);
  AEditor.IndicSetOutlineAlphaValue(OCCURRENCE_INDICATOR,
    AConfig.SmartHighlightOutlineAlpha);
end;

procedure ApplyConfigEditorOptions(const AEditor: TDScintilla;
  const AConfig: TDSciVisualConfig);
var
  lFoldFlags: TDSciFoldFlagSet;
  lVirtualSpace: TDSciVirtualSpaceSet;
begin
  if AConfig = nil then
    Exit;

  AEditor.BackSpaceUnIndents := AConfig.BackSpaceUnIndents;
  AEditor.IndentationGuides := AConfig.IndentationGuides;
  AEditor.ViewWS := AConfig.WhiteSpaceStyle;
  AEditor.WhitespaceSize := AConfig.WhiteSpaceSize;
  AEditor.ExtraAscent := AConfig.UpperLineSpacing;
  AEditor.ExtraDescent := AConfig.LowerLineSpacing;
  AEditor.TabWidth := Max(1, AConfig.TabWidth);
  AEditor.WrapMode := AConfig.WrapMode;
  AEditor.WrapVisualFlags := AConfig.WrapVisualFlags;
  AEditor.WrapVisualFlagsLocation := AConfig.WrapVisualFlagsLocation;

  AEditor.SelEOLFilled := AConfig.SelectFullLine;
  if AConfig.UseSelectionForeColor then
    AEditor.SetSelFore(True, AConfig.SelectionForeColor);
  if not AConfig.UseSelectionForeColor then
    AEditor.SetSelFore(False, AConfig.SelectionForeColor);
  AEditor.SendEditor(SCI_SETSELALPHA, WPARAM(AConfig.SelectionAlpha), 0);
  AEditor.SendEditor(SCI_SETADDITIONALSELALPHA, WPARAM(AConfig.SelectionAlpha), 0);

  lVirtualSpace := AEditor.VirtualSpaceOptions;
  if AConfig.CaretBeyondLineEndings then
    Include(lVirtualSpace, scvsUSER_ACCESSIBLE)
  else
    Exclude(lVirtualSpace, scvsUSER_ACCESSIBLE);

  if AConfig.WrapCursorAtLineStart then
    Exclude(lVirtualSpace, scvsNO_WRAP_LINE_START)
  else
    Include(lVirtualSpace, scvsNO_WRAP_LINE_START);
  AEditor.VirtualSpaceOptions := lVirtualSpace;

  AEditor.CaretSticky := AConfig.CaretSticky;
  if AConfig.MultiPaste then
    AEditor.MultiPaste := scmpEACH
  else
    AEditor.MultiPaste := scmpONCE;
  AEditor.PasteConvertEndings := AConfig.PasteConvertEndings;
  AEditor.PrintMagnification := AConfig.PrintMagnification;

  if AConfig.FoldingLines then
    lFoldFlags := [scffLINE_AFTER_CONTRACTED]
  else
    lFoldFlags := [];
  AEditor.FoldFlags := lFoldFlags;
  AEditor.SetDefaultFoldDisplayText(AConfig.FoldingText);
  AEditor.FoldDisplayTextStyle := AConfig.FoldDisplayTextStyle;
  ApplyConfigFoldMargin(AEditor, AConfig.FoldMarginVisible, AConfig.FoldMarkerStyle);
  AEditor.SendEditor(SCI_SETAUTOMATICFOLD,
    SC_AUTOMATICFOLD_SHOW or SC_AUTOMATICFOLD_CLICK or SC_AUTOMATICFOLD_CHANGE, 0);

  ApplyConfigLineNumbering(AEditor, AConfig.LineNumbering,
    AConfig.LineNumberWidthMode, AConfig.LineNumberPaddingLeft,
    AConfig.LineNumberPaddingRight);
  ApplyConfigTextPadding(AEditor, AConfig.TextPaddingLeft, AConfig.TextPaddingRight);
  ApplyConfigIndicators(AEditor, AConfig);
end;

function IsDirectWriteTechnology(ATechnology: TDSciTechnology): Boolean;
begin
  Result := ATechnology in [sctDIRECT_WRITE, sctDIRECT_WRITE_RETAIN,
    sctDIRECT_WRITE_D_C, sctDIRECT_WRITE_1];
end;

function DetectUserFontLocale: string;
var
  lBuffer: array[0..LOCALE_NAME_MAX_LENGTH] of Char;
begin
  FillChar(lBuffer, SizeOf(lBuffer), 0);
  if GetUserDefaultLocaleName(@lBuffer[0], LOCALE_NAME_MAX_LENGTH) > 0 then
    Result := PChar(@lBuffer[0])
  else
    Result := '';
end;

function TryResolveAdjacentServiceFile(const ABaseDirectory, ASubDirectory,
  ALanguageName: string; out AFileName: string): Boolean;
var
  lCandidate: string;
  lDirectory: string;
begin
  AFileName := '';
  if (Trim(ABaseDirectory) = '') or (Trim(ALanguageName) = '') then
    Exit(False);

  lDirectory := TPath.Combine(ExcludeTrailingPathDelimiter(ABaseDirectory),
    ASubDirectory);
  if not TDirectory.Exists(lDirectory) then
    Exit(False);

  lCandidate := TPath.Combine(lDirectory, ALanguageName + '.xml');
  if FileExists(lCandidate) then
  begin
    AFileName := lCandidate;
    Exit(True);
  end;

  for lCandidate in TDirectory.GetFiles(lDirectory, '*.xml') do
    if SameText(TPath.GetFileNameWithoutExtension(lCandidate), ALanguageName) then
    begin
      AFileName := lCandidate;
      Exit(True);
    end;

  Result := False;
end;

function PositionChar(const AEditor: TDScintilla; APosition: NativeInt): WideChar;
var
  lValue: Integer;
begin
  Result := #0;
  if APosition < 0 then
    Exit;

  lValue := AEditor.GetCharAt(APosition);
  if (lValue < 0) or (lValue > 255) then
    Exit;

  Result := WideChar(AnsiChar(Byte(lValue)));
end;

function IsServiceIdentifierChar(const AModel: TDSciAutoCompleteModel;
  AChar: WideChar): Boolean;
begin
  if AModel <> nil then
    Exit(AModel.IsIdentifierChar(AChar));
  Result := AChar.IsLetterOrDigit or (AChar = '_');
end;

function ExtractIdentifierPrefix(const AEditor: TDScintilla;
  const AModel: TDSciAutoCompleteModel; ACaretPos: NativeInt;
  out AStartPos: NativeInt; out APrefix: string): Boolean;
var
  lPreviousPos: NativeInt;
begin
  APrefix := '';
  AStartPos := ACaretPos;
  if ACaretPos <= 0 then
    Exit(False);

  while AStartPos > 0 do
  begin
    lPreviousPos := AEditor.PositionBefore(AStartPos);
    if lPreviousPos >= AStartPos then
      Break;
    if not IsServiceIdentifierChar(AModel, PositionChar(AEditor, lPreviousPos)) then
      Break;
    AStartPos := lPreviousPos;
  end;

  APrefix := AEditor.GetTextRange(AStartPos, ACaretPos);
  Result := APrefix <> '';
end;

function JoinAutoCompleteItems(AItems: TStrings; ASeparator: Char): string;
var
  lIndex: Integer;
begin
  Result := '';
  if AItems = nil then
    Exit;

  for lIndex := 0 to AItems.Count - 1 do
  begin
    if Result <> '' then
      Result := Result + ASeparator;
    Result := Result + AItems[lIndex];
  end;
end;

function FindDocumentFunction(
  AFunctions: TObjectList<TDSciDocumentFunction>;
  const AName: string): TDSciDocumentFunction;
var
  lEntry: TDSciDocumentFunction;
begin
  Result := nil;
  if AFunctions = nil then
    Exit;

  for lEntry in AFunctions do
    if SameText(lEntry.Name, AName) then
      Exit(lEntry);
end;

function TryFindInvocationContext(const AEditor: TDScintilla;
  const AModel: TDSciAutoCompleteModel; ACaretPos: NativeInt;
  out AFunctionName: string; out AOpenPos: NativeInt;
  out AParameterIndex: Integer): Boolean;
var
  lChar: WideChar;
  lDepth: Integer;
  lParamSeparator: WideChar;
  lPosition: NativeInt;
  lPreviousPos: NativeInt;
  lStartFunction: WideChar;
  lStopFunction: WideChar;
  lTerminal: WideChar;
begin
  AFunctionName := '';
  AOpenPos := INVALID_POSITION;
  AParameterIndex := 0;

  if AModel <> nil then
  begin
    lStartFunction := AModel.StartFunctionChar;
    lStopFunction := AModel.StopFunctionChar;
    lParamSeparator := AModel.ParamSeparatorChar;
    lTerminal := AModel.TerminalChar;
  end
  else
  begin
    lStartFunction := '(';
    lStopFunction := ')';
    lParamSeparator := ',';
    lTerminal := ';';
  end;

  lDepth := 0;
  lPosition := ACaretPos;
  while lPosition > 0 do
  begin
    lPreviousPos := AEditor.PositionBefore(lPosition);
    if lPreviousPos >= lPosition then
      Break;

    case PositionChar(AEditor, lPreviousPos) of
      #10, #13:
        if lDepth = 0 then
          Break;
      else
      begin
        lChar := PositionChar(AEditor, lPreviousPos);
        if lChar = lStopFunction then
          Inc(lDepth)
        else if lChar = lStartFunction then
        begin
          if lDepth = 0 then
          begin
            AOpenPos := lPreviousPos;
            Break;
          end;
          Dec(lDepth);
        end
        else if (lChar = lParamSeparator) and (lDepth = 0) then
          Inc(AParameterIndex)
        else if (lChar = lTerminal) and (lDepth = 0) then
          Break;
      end;
    end;

    lPosition := lPreviousPos;
  end;

  if AOpenPos = INVALID_POSITION then
    Exit(False);

  Result := ExtractIdentifierPrefix(AEditor, AModel, AOpenPos, lPosition,
    AFunctionName) and (Trim(AFunctionName) <> '');
end;

function TryBuildDocumentFunctionCallTip(const AEntry: TDSciDocumentFunction;
  AParameterIndex: Integer; out AText: string; out AHighlightStart,
  AHighlightEnd: Integer): Boolean;
var
  lBracketDepth: Integer;
  lClosePos: Integer;
  lCurrentIndex: Integer;
  lOpenPos: Integer;
  lParameterEnd: Integer;
  lParameterStart: Integer;
  lText: string;
begin
  AText := '';
  AHighlightStart := 0;
  AHighlightEnd := 0;
  if (AEntry = nil) or (Trim(AEntry.Signature) = '') then
    Exit(False);

  lText := Trim(AEntry.Signature);
  if Pos('(', lText) = 0 then
    lText := AEntry.Name + '()';
  AText := lText;

  lOpenPos := Pos('(', lText);
  lClosePos := LastDelimiter(')', lText);
  if (lOpenPos <= 0) or (lClosePos <= lOpenPos) then
    Exit(True);

  lBracketDepth := 0;
  lCurrentIndex := 0;
  lParameterStart := lOpenPos + 1;
  while lParameterStart < lClosePos do
  begin
    lParameterEnd := lParameterStart;
    while lParameterEnd < lClosePos do
    begin
      case lText[lParameterEnd] of
        '(', '[', '{', '<':
          Inc(lBracketDepth);
        ')', ']', '}', '>':
          if lBracketDepth > 0 then
            Dec(lBracketDepth);
        ',':
          if lBracketDepth = 0 then
            Break;
      end;
      Inc(lParameterEnd);
    end;

    if lCurrentIndex = AParameterIndex then
    begin
      while (lParameterStart <= lParameterEnd) and
            CharInSet(lText[lParameterStart], [' ', #9]) do
        Inc(lParameterStart);
      while (lParameterEnd > lParameterStart) and
            CharInSet(lText[lParameterEnd - 1], [' ', #9]) do
        Dec(lParameterEnd);
      AHighlightStart := lParameterStart - 1;
      AHighlightEnd := lParameterEnd - 1;
      Break;
    end;

    Inc(lCurrentIndex);
    lParameterStart := lParameterEnd + 1;
    while (lParameterStart < lClosePos) and
          CharInSet(lText[lParameterStart], [',', ' ', #9]) do
      Inc(lParameterStart);
  end;

  Result := True;
end;

procedure ApplyConfigStyleEntries(const AEditor: TDScintilla;
  const AGroup: TDSciVisualStyleGroup);
var
  lStyle: TDSciVisualStyleData;
begin
  if AGroup = nil then
    Exit;

  for lStyle in AGroup.Styles do
    if lStyle.HasStyleID then
      ApplyVisualStyleAttributes(AEditor, lStyle.StyleID, lStyle);
end;

procedure ResetKeywordsAndIdentifiers(const AEditor: TDScintilla);
var
  lStyleID: Integer;
begin
  for lStyleID := 0 to KEYWORDSET_MAX do
    AEditor.KeyWords[lStyleID] := '';
  for lStyleID := 0 to 255 do
    AEditor.Identifiers[lStyleID] := '';
end;

procedure ApplyConfigKeywords(const AEditor: TDScintilla;
  const AGroup: TDSciVisualStyleGroup);
var
  lKeywordIndex: Integer;
  lStyle: TDSciVisualStyleData;
begin
  ResetKeywordsAndIdentifiers(AEditor);
  if AGroup = nil then
    Exit;

  lKeywordIndex := 0;
  for lStyle in AGroup.Styles do
  begin
    if Trim(lStyle.KeywordsText) = '' then
      Continue;

    if IsSubStyleKeywordClass(lStyle.KeywordClass) then
    begin
      if lStyle.HasStyleID then
        AEditor.Identifiers[lStyle.StyleID] := AnsiString(lStyle.KeywordsText);
      Continue;
    end;

    if lStyle.HasKeywordsID then
      lKeywordIndex := Max(lKeywordIndex, lStyle.KeywordsID);

    if lStyle.HasKeywordsID and (lStyle.KeywordsID <= KEYWORDSET_MAX) then
      AEditor.KeyWords[lStyle.KeywordsID] := lStyle.KeywordsText
    else if lKeywordIndex <= KEYWORDSET_MAX then
      AEditor.KeyWords[lKeywordIndex] := lStyle.KeywordsText;

    Inc(lKeywordIndex);
  end;
end;

constructor TDSciSettings.Create(AOwner: TComponent);
begin
  inherited Create;
  FOwner := AOwner;
  FDocumentFunctionsDirty := True;
end;

destructor TDSciSettings.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TDSciSettings.GetCurrentConfig(var AConfig: TObject): Boolean;
begin
  AConfig := GetVisualConfig(FConfigModel);
  Result := Assigned(AConfig);
end;

procedure TDSciSettings.ApplyRenderingOptions;
var
  lConfig: TDSciVisualConfig;
  lEditor: TDScintilla;
  lFontLocale: string;
  lRequestedTechnology: TDSciTechnology;
begin
  lConfig := GetVisualConfig(FConfigModel);
  if lConfig = nil then
    Exit;

  lEditor := GetEditorComponent(FOwner);
  lRequestedTechnology := lConfig.Technology;
  if lRequestedTechnology = sctDEFAULT then
    lRequestedTechnology := lEditor.DefaultTechnology;

  lEditor.StatusBarVisible := lConfig.ShowStatusBar;
  lEditor.StatusPanelFileVisible := lConfig.StatusPanelFileVisible;
  lEditor.StatusPanelPosVisible := lConfig.StatusPanelPosVisible;
  lEditor.StatusPanelLexerVisible := lConfig.StatusPanelLexerVisible;
  lEditor.StatusPanelEncodingVisible := lConfig.StatusPanelEncodingVisible;
  lEditor.StatusPanelThemeVisible := lConfig.StatusPanelThemeVisible;
  lEditor.StatusPanelLoadVisible := lConfig.StatusPanelLoadVisible;
  lEditor.Technology := lRequestedTechnology;
  lEditor.FontQuality := lConfig.FontQuality;

  if IsDirectWriteTechnology(lEditor.Technology) then
  begin
    lFontLocale := Trim(lConfig.FontLocale);
    if lFontLocale = '' then
      lFontLocale := DetectUserFontLocale;
    if lFontLocale <> '' then
      lEditor.FontLocale := lFontLocale;
  end;
end;

procedure TDSciSettings.ClearLanguageServices;
begin
  FreeAndNil(FDocumentFunctions);
  FreeAndNil(FAutoCompleteModel);
  FreeAndNil(FFunctionListModel);
  FDocumentFunctionsDirty := True;
end;

procedure TDSciSettings.Clear;
begin
  ClearLanguageServices;
  FreeAndNil(FConfigModel);
  FSettingsDirectory := '';
  FStylersModelFileName := '';
  FLanguagesModelFileName := '';
  FThemeFileName := '';
  FConfigFileName := '';
  FCurrentLanguage := '';
  FLexerLibraryLoadedFor := '';
end;

procedure TDSciSettings.LoadConfigFile(const AFileName: string);
var
  lConfig: TDSciVisualConfig;
  lFileName: string;
begin
  lFileName := ExpandFileName(AFileName);
  EnsureDefaultConfigFile(lFileName);
  if not FileExists(lFileName) then
    raise EFileNotFoundException.CreateFmt('Settings file not found: %s', [AFileName]);

  lConfig := TDSciVisualConfig.Create;
  try
    lConfig.LoadFromFile(lFileName);

    FreeAndNil(FConfigModel);
    FConfigModel := lConfig;
    lConfig := nil;

    FConfigFileName := lFileName;
    FSettingsDirectory := IncludeTrailingPathDelimiter(ExtractFilePath(lFileName));
    FStylersModelFileName := '';
    FLanguagesModelFileName := '';
    FThemeFileName := '';
  finally
    lConfig.Free;
  end;

  Reapply;
end;

function TDSciSettings.ResolveLanguageNameByFileName(const AFileName: string): string;
var
  lConfig: TDSciVisualConfig;
begin
  Result := '';
  lConfig := GetVisualConfig(FConfigModel);
  if lConfig <> nil then
    Result := lConfig.ResolveLanguageByFileName(AFileName);
end;

const
  cLegacyApiMsg = 'This legacy API has been removed. Use SciConfGen to generate ' +
    'a consolidated config file and load it with LoadConfigFile instead.';

procedure TDSciSettings.LoadSettingsDirectory(const ADir: string);
begin
  raise ENotSupportedException.Create(cLegacyApiMsg);
end;

procedure TDSciSettings.LoadStylersModel(const AFileName: string);
begin
  raise ENotSupportedException.Create(cLegacyApiMsg);
end;

procedure TDSciSettings.LoadLanguagesModel(const AFileName: string);
begin
  raise ENotSupportedException.Create(cLegacyApiMsg);
end;

function TDSciSettings.ResolveThemeFile(const AThemeName: string): string;
begin
  raise ENotSupportedException.Create(cLegacyApiMsg);
end;

procedure TDSciSettings.LoadTheme(const AThemeName: string);
begin
  raise ENotSupportedException.Create(cLegacyApiMsg);
end;

procedure TDSciSettings.ApplyLanguage(const ALanguageName: string);
begin
  FCurrentLanguage := Trim(ALanguageName);
  Reapply;
end;

procedure TDSciSettings.ApplyLanguageForFileName(const AFileName: string);
var
  lLanguageName: string;
begin
  lLanguageName := ResolveLanguageNameByFileName(AFileName);
  if lLanguageName = '' then
  begin
    DSciLog(Format(
      'No language mapping found for "%s"; falling back to the default/plain lexer.',
      [AFileName]));
    ApplyLanguage('');
    Exit;
  end;

  DSciLog(Format('Resolved language "%s" for "%s".', [lLanguageName, AFileName]));
  ApplyLanguage(lLanguageName);
end;

procedure TDSciSettings.RefreshDocumentFunctions;
var
  lEditor: TDScintilla;
  lModel: TDSciFunctionListModel;
begin
  if not FDocumentFunctionsDirty then
    Exit;

  FreeAndNil(FDocumentFunctions);
  lModel := GetFunctionListModel(FFunctionListModel);
  if lModel = nil then
  begin
    FDocumentFunctionsDirty := False;
    Exit;
  end;

  lEditor := GetEditorComponent(FOwner);
  FDocumentFunctions := lModel.ExtractFunctions(
    lEditor.GetTextRange(0, lEditor.TextLength));
  FDocumentFunctionsDirty := False;
end;

procedure TDSciSettings.ReloadLanguageServices;
var
  lNewAutoCompleteModel: TObject;
  lNewFunctionListModel: TObject;
  lAutoCompleteFile: string;
  lFunctionListFile: string;
begin
  lNewAutoCompleteModel := nil;
  lNewFunctionListModel := nil;
  if (Trim(FSettingsDirectory) <> '') and (Trim(FCurrentLanguage) <> '') then
  begin
    if TryResolveAdjacentServiceFile(FSettingsDirectory, 'autoCompletion',
      FCurrentLanguage, lAutoCompleteFile) then
      try
        lNewAutoCompleteModel := LoadAutoCompleteModelFromFile(lAutoCompleteFile);
      except
        on E: Exception do
        begin
          DSciLog(Format(
            'Skipping invalid autoCompletion sidecar "%s": %s - %s',
            [lAutoCompleteFile, E.ClassName, E.Message]));
          FreeAndNil(lNewAutoCompleteModel);
        end;
      end;

    if TryResolveAdjacentServiceFile(FSettingsDirectory, 'functionList',
      FCurrentLanguage, lFunctionListFile) then
      try
        lNewFunctionListModel := LoadFunctionListModelFromFile(lFunctionListFile);
      except
        on E: Exception do
        begin
          DSciLog(Format(
            'Skipping invalid functionList sidecar "%s": %s - %s',
            [lFunctionListFile, E.ClassName, E.Message]));
          FreeAndNil(lNewFunctionListModel);
        end;
      end;
  end;

  ClearLanguageServices;
  FAutoCompleteModel := lNewAutoCompleteModel;
  FFunctionListModel := lNewFunctionListModel;
  FDocumentFunctionsDirty := True;
end;

procedure TDSciSettings.UpdateAutoComplete;
var
  lDocumentFunctions: TObjectList<TDSciDocumentFunction>;
  lEditor: TDScintilla;
  lEntry: TDSciDocumentFunction;
  lItems: TStringList;
  lModel: TDSciAutoCompleteModel;
  lPrefix: string;
  lStartPos: NativeInt;
begin
  lEditor := GetEditorComponent(FOwner);
  lModel := GetAutoCompleteModel(FAutoCompleteModel);
  if (lModel = nil) and (FFunctionListModel = nil) then
  begin
    if lEditor.AutoCActive then
      lEditor.AutoCCancel;
    Exit;
  end;

  if not ExtractIdentifierPrefix(lEditor, lModel, lEditor.CurrentPos, lStartPos,
    lPrefix) then
  begin
    if lEditor.AutoCActive then
      lEditor.AutoCCancel;
    Exit;
  end;

  lItems := TStringList.Create;
  try
    lItems.Sorted := True;
    lItems.Duplicates := dupIgnore;
    lItems.CaseSensitive := not ((lModel <> nil) and lModel.IgnoreCase);

    if lModel <> nil then
      lModel.CollectMatches(lPrefix, lItems);

    if FFunctionListModel <> nil then
    begin
      RefreshDocumentFunctions;
      lDocumentFunctions := GetDocumentFunctions(FDocumentFunctions);
      if lDocumentFunctions <> nil then
        for lEntry in lDocumentFunctions do
          if StartsText(lPrefix, lEntry.Name) then
            lItems.Add(lEntry.Name);
    end;

    if lItems.Count = 0 then
    begin
      if lEditor.AutoCActive then
        lEditor.AutoCCancel;
      Exit;
    end;

    lEditor.AutoCSetSeparator(' ');
    lEditor.AutoCSetIgnoreCase((lModel <> nil) and lModel.IgnoreCase);
    lEditor.AutoCSetAutoHide(True);
    lEditor.AutoCSetChooseSingle(False);
    lEditor.AutoCSetDropRestOfWord(False);
    lEditor.AutoCShow(Length(lPrefix), JoinAutoCompleteItems(lItems, ' '));
  finally
    lItems.Free;
  end;
end;

procedure TDSciSettings.UpdateCallTip;
var
  lDocumentFunctions: TObjectList<TDSciDocumentFunction>;
  lEditor: TDScintilla;
  lFunctionName: string;
  lHighlightEnd: Integer;
  lHighlightStart: Integer;
  lItem: TDSciAutoCompleteItem;
  lModel: TDSciAutoCompleteModel;
  lOpenPos: NativeInt;
  lParameterIndex: Integer;
  lTipText: string;
begin
  lEditor := GetEditorComponent(FOwner);
  lModel := GetAutoCompleteModel(FAutoCompleteModel);
  if not TryFindInvocationContext(lEditor, lModel, lEditor.CurrentPos,
    lFunctionName, lOpenPos, lParameterIndex) then
  begin
    if lEditor.CallTipActive then
      lEditor.CallTipCancel;
    Exit;
  end;

  lTipText := '';
  lHighlightStart := 0;
  lHighlightEnd := 0;

  if lModel <> nil then
  begin
    lItem := lModel.FindItem(lFunctionName);
    if lItem <> nil then
      lItem.TryBuildCallTip(lParameterIndex, lTipText,
        lHighlightStart, lHighlightEnd);
  end;

  if (lTipText = '') and (FFunctionListModel <> nil) then
  begin
    RefreshDocumentFunctions;
    lDocumentFunctions := GetDocumentFunctions(FDocumentFunctions);
    TryBuildDocumentFunctionCallTip(
      FindDocumentFunction(lDocumentFunctions, lFunctionName), lParameterIndex,
      lTipText, lHighlightStart, lHighlightEnd);
  end;

  if lTipText = '' then
  begin
    if lEditor.CallTipActive then
      lEditor.CallTipCancel;
    Exit;
  end;

  lEditor.CallTipShow(lOpenPos, lTipText);
  lEditor.CallTipSetPosStart(lOpenPos);
  if lHighlightEnd > lHighlightStart then
    lEditor.CallTipSetHlt(lHighlightStart, lHighlightEnd);
end;

procedure TDSciSettings.NotifyCharAdded(ACh: Integer);
var
  lEditor: TDScintilla;
  lModel: TDSciAutoCompleteModel;
  lTypedChar: WideChar;
begin
  lEditor := GetEditorComponent(FOwner);
  lModel := GetAutoCompleteModel(FAutoCompleteModel);
  lTypedChar := WideChar(AnsiChar(Byte(ACh and $FF)));

  if IsServiceIdentifierChar(lModel, lTypedChar) then
    UpdateAutoComplete
  else if lEditor.AutoCActive then
    lEditor.AutoCCancel;

  UpdateCallTip;
end;

procedure TDSciSettings.NotifyModified;
begin
  FDocumentFunctionsDirty := True;
end;

procedure TDSciSettings.NotifyUpdateUI(AUpdated: Integer);
var
  lEditor: TDScintilla;
  lUpdated: TDSciUpdateFlagsSet;
begin
  lUpdated := TDSciUpdateFlagsSetFromInt(AUpdated);
  lEditor := GetEditorComponent(FOwner);
  if lEditor.AutoCActive then
    UpdateAutoComplete;
  if lEditor.CallTipActive then
    UpdateCallTip;
end;

procedure TDSciSettings.Reapply;
var
  lConfig: TDSciVisualConfig;
  lConfigDefaultGroup: TDSciVisualStyleGroup;
  lConfigGroup: TDSciVisualStyleGroup;
  lDllPath: string;
  lEditor: TDScintilla;
  lRequestedLanguage: string;
begin
  lEditor := GetEditorComponent(FOwner);
  if not lEditor.HandleAllocated then
    Exit;

  lConfig := GetVisualConfig(FConfigModel);
  if lConfig = nil then
    Exit;

  _DSciLogEnabled := lConfig.LogEnabled;
  _DSciLogLevel := lConfig.LogLevel;
  _DSciLogOutput := lConfig.LogOutput;

  ApplyRenderingOptions;
  lRequestedLanguage := Trim(FCurrentLanguage);
  DSciLog(Format('Reapply: language="%s", FoldMarginVisible=%s.',
    [lRequestedLanguage, BoolToStr(lConfig.FoldMarginVisible, True)]));
  lConfigDefaultGroup := lConfig.StyleOverrides.FindGroup('default');
  if lRequestedLanguage <> '' then
    lConfigGroup := lConfig.StyleOverrides.FindGroup(lRequestedLanguage)
  else
    lConfigGroup := nil;

  if lRequestedLanguage <> '' then
  begin
    if UsesPlainTextLexer(lConfigGroup) then
    begin
      DSciLog(Format(
        'Keeping the requested language "%s" on the default/plain lexer because config maps it to SCLEX_NULL.',
        [lRequestedLanguage]));
    end
    else
    begin
      lDllPath := ResolveEditorDllPath(lEditor);
      if (lDllPath <> '') and not SameText(FLexerLibraryLoadedFor, lDllPath) then
      begin
        try
          lEditor.LoadLexerLibrary(lDllPath);
          FLexerLibraryLoadedFor := lDllPath;
        except
          FLexerLibraryLoadedFor := '';
        end;
      end;
    end;

    try
      lEditor.SetLexerLanguage(lRequestedLanguage);
    except
      on E: EInvalidOpException do
      begin
        DSciLog(Format(
          'Falling back to the default lexer because "%s" is unavailable: %s',
          [lRequestedLanguage, E.Message]));
        lRequestedLanguage := '';
        FCurrentLanguage := '';
        lConfigGroup := nil;
      end;
    end;
  end;

  ReloadLanguageServices;

  ApplyConfigGlobalStyles(lEditor, lConfigDefaultGroup, lConfigGroup);

  if lRequestedLanguage = '' then
  begin
    DSciLog('Reapply: taking plain-text path > lexer cleared, fold levels destroyed.');
    lEditor.SetLexerLanguage('');
    ResetKeywordsAndIdentifiers(lEditor);
    lEditor.ClearDocumentStyle;
    lEditor.Colourise(0, -1);
    ApplyConfigEditorOptions(lEditor, lConfig);
    lEditor.RefreshManagedStatusBar;
    Exit;
  end;
  ApplyConfigGlobalStyles(lEditor, lConfigDefaultGroup, lConfigGroup);
  ApplyConfigStyleEntries(lEditor, lConfigDefaultGroup);
  ApplyConfigStyleEntries(lEditor, lConfigGroup);
  ApplyConfigKeywords(lEditor, lConfigGroup);
  ApplyFoldProperties(lEditor);
  lEditor.Colourise(0, -1);

  ApplyConfigDefaultStyle(lEditor, lConfigDefaultGroup, lConfigGroup);
  ApplyConfigEditorOptions(lEditor, lConfig);
  lEditor.RefreshManagedStatusBar;
end;

end.
