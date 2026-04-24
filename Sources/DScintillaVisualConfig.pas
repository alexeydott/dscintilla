unit DScintillaVisualConfig;

interface

uses
  System.Classes, System.Generics.Collections,
  Vcl.Graphics,
  DScintillaTypes;

type
  TDSciFoldMarkerStyle = (
    fmsArrow,
    fmsPlusMinus,
    fmsCircleTree,
    fmsBoxTree
  );

  TDSciLineNumberWidthMode = (
    lnwmDynamic,
    lnwmFixed
  );

  TDSciVisualStyleKind = (
    dvskLexer,
    dvskGlobal
  );

  TDSciVisualStyleData = class
  public
    Kind: TDSciVisualStyleKind;
    Name: string;
    StyleID: Integer;
    HasStyleID: Boolean;
    KeywordsID: Integer;
    HasKeywordsID: Boolean;
    HasForeColor: Boolean;
    ForeColor: TColor;
    HasBackColor: Boolean;
    BackColor: TColor;
    FontName: string;
    HasFontStyle: Boolean;
    FontStyle: Integer;
    HasFontSize: Boolean;
    FontSize: Integer;
    EOLFill: Integer;
    HasEOLFill: Boolean;
    KeywordClass: string;
    KeywordsText: string;

    procedure Assign(ASource: TDSciVisualStyleData);
    function Clone: TDSciVisualStyleData;
  end;

  TDSciVisualStyleGroup = class
  private
    FStyles: TObjectList<TDSciVisualStyleData>;
  public
    Name: string;
    Description: string;
    Extensions: string;
    LexerID: Integer;
    HasLexerID: Boolean;

    constructor Create;
    destructor Destroy; override;

    function FindStyle(const AName: string; AKind: TDSciVisualStyleKind): TDSciVisualStyleData;
    function FindStyleByID(AStyleID: Integer; AKind: TDSciVisualStyleKind): TDSciVisualStyleData;
    function EnsureStyle(const AName: string; AKind: TDSciVisualStyleKind): TDSciVisualStyleData;
    procedure Assign(ASource: TDSciVisualStyleGroup);

    property Styles: TObjectList<TDSciVisualStyleData> read FStyles;
  end;

  TDSciVisualStyleModel = class
  private
    FGroups: TObjectList<TDSciVisualStyleGroup>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure Assign(ASource: TDSciVisualStyleModel);
    function Clone: TDSciVisualStyleModel;
    function FindGroup(const AName: string): TDSciVisualStyleGroup;
    function EnsureGroup(const AName: string): TDSciVisualStyleGroup;

    property Groups: TObjectList<TDSciVisualStyleGroup> read FGroups;
  end;

  TDSciVisualConfig = class
  private
    FThemeName: string;
    FHighlightColor: TColor;
    FHighlightAlpha: Byte;
    FHighlightOutlineAlpha: Byte;
    FBackSpaceUnIndents: Boolean;
    FIndentationGuides: TDSciIndentView;
    FWhiteSpaceStyle: TDSciWhiteSpace;
    FWhiteSpaceSize: Integer;
    FUpperLineSpacing: Integer;
    FLowerLineSpacing: Integer;
    FLineNumbering: Boolean;
    FLineNumberWidthMode: TDSciLineNumberWidthMode;
    FLineNumberPaddingLeft: Integer;
    FLineNumberPaddingRight: Integer;
    FTextPaddingLeft: Integer;
    FTextPaddingRight: Integer;
    FBookmarkMarginVisible: Boolean;
    FFoldMarginVisible: Boolean;
    FFoldMarkerStyle: TDSciFoldMarkerStyle;
    FLineWrapping: Boolean;
    FWrapMode: TDSciWrap;
    FWrapVisualFlags: TDSciWrapVisualFlagSet;
    FWrapVisualFlagsLocation: TDSciWrapVisualLocationSet;
    FSmartHighlightStyle: TDSciIndicatorStyle;
    FSmartHighlightFillAlpha: Byte;
    FSmartHighlightOutlineAlpha: Byte;
    FSelectFullLine: Boolean;
    FUseSelectionForeColor: Boolean;
    FSelectionForeColor: TColor;
    FSelectionAlpha: Integer;
    FCaretBeyondLineEndings: Boolean;
    FWrapCursorAtLineStart: Boolean;
    FCaretSticky: TDSciCaretSticky;
    FMultiPaste: Boolean;
    FPasteConvertEndings: Boolean;
    FPrintMagnification: Integer;
    FFoldingLines: Boolean;
    FFoldingText: string;
    FFoldDisplayTextStyle: TDSciFoldDisplayTextStyle;
    FTechnology: TDSciTechnology;
    FFontLocale: string;
    FFontQuality: TDSciFontQuality;
    FTabWidth: Integer;
    FFileSizeLimit: Int64;
    FSearchSync: Boolean;
    FStyleOverrides: TDSciVisualStyleModel;
    FLogEnabled: Boolean;
    FLogLevel: Integer;
    FLogOutput: Integer;
    FShowStatusBar: Boolean;
    FStatusPanelFileVisible: Boolean;
    FStatusPanelPosVisible: Boolean;
    FStatusPanelLexerVisible: Boolean;
    FStatusPanelEncodingVisible: Boolean;
    FStatusPanelThemeVisible: Boolean;
    FStatusPanelLoadVisible: Boolean;
    function GetLineWrapping: Boolean;
    procedure SetLineWrapping(AValue: Boolean);
    procedure SetWrapMode(AValue: TDSciWrap);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ResetDefaults;
    procedure Assign(ASource: TDSciVisualConfig);
    function Clone: TDSciVisualConfig;
    function HasStyleOverrides: Boolean;
    function FindStyleOverride(const ALanguageName, AStyleName: string;
      AKind: TDSciVisualStyleKind): TDSciVisualStyleData;
    function EnsureStyleOverride(const ALanguageName, AStyleName: string;
      AKind: TDSciVisualStyleKind): TDSciVisualStyleData;
    function ResolveLanguageByFileName(const AFileName: string): string;
    function BuildHandledExtensions: string;
    procedure ReplaceStyleModel(ASource: TDSciVisualStyleModel;
      APreserveMetadata: Boolean = True);

    procedure LoadFromFile(const AFileName: string);
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToFile(const AFileName: string);

    property ThemeName: string read FThemeName write FThemeName;
    property HighlightColor: TColor read FHighlightColor write FHighlightColor;
    property HighlightAlpha: Byte read FHighlightAlpha write FHighlightAlpha;
    property HighlightOutlineAlpha: Byte read FHighlightOutlineAlpha write FHighlightOutlineAlpha;
    property BackSpaceUnIndents: Boolean read FBackSpaceUnIndents write FBackSpaceUnIndents;
    property IndentationGuides: TDSciIndentView read FIndentationGuides write FIndentationGuides;
    property WhiteSpaceStyle: TDSciWhiteSpace read FWhiteSpaceStyle write FWhiteSpaceStyle;
    property WhiteSpaceSize: Integer read FWhiteSpaceSize write FWhiteSpaceSize;
    property UpperLineSpacing: Integer read FUpperLineSpacing write FUpperLineSpacing;
    property LowerLineSpacing: Integer read FLowerLineSpacing write FLowerLineSpacing;
    property LineNumbering: Boolean read FLineNumbering write FLineNumbering;
    property LineNumberWidthMode: TDSciLineNumberWidthMode read FLineNumberWidthMode write FLineNumberWidthMode;
    property LineNumberPaddingLeft: Integer read FLineNumberPaddingLeft write FLineNumberPaddingLeft;
    property LineNumberPaddingRight: Integer read FLineNumberPaddingRight write FLineNumberPaddingRight;
    property TextPaddingLeft: Integer read FTextPaddingLeft write FTextPaddingLeft;
    property TextPaddingRight: Integer read FTextPaddingRight write FTextPaddingRight;
    property BookmarkMarginVisible: Boolean read FBookmarkMarginVisible write FBookmarkMarginVisible;
    property FoldMarginVisible: Boolean read FFoldMarginVisible write FFoldMarginVisible;
    property FoldMarkerStyle: TDSciFoldMarkerStyle read FFoldMarkerStyle write FFoldMarkerStyle;
    property LineWrapping: Boolean read GetLineWrapping write SetLineWrapping;
    property WrapMode: TDSciWrap read FWrapMode write SetWrapMode;
    property WrapVisualFlags: TDSciWrapVisualFlagSet read FWrapVisualFlags write FWrapVisualFlags;
    property WrapVisualFlagsLocation: TDSciWrapVisualLocationSet read FWrapVisualFlagsLocation write FWrapVisualFlagsLocation;
    property SmartHighlightStyle: TDSciIndicatorStyle read FSmartHighlightStyle write FSmartHighlightStyle;
    property SmartHighlightFillAlpha: Byte read FSmartHighlightFillAlpha write FSmartHighlightFillAlpha;
    property SmartHighlightOutlineAlpha: Byte read FSmartHighlightOutlineAlpha write FSmartHighlightOutlineAlpha;
    property SelectFullLine: Boolean read FSelectFullLine write FSelectFullLine;
    property UseSelectionForeColor: Boolean read FUseSelectionForeColor write FUseSelectionForeColor;
    property SelectionForeColor: TColor read FSelectionForeColor write FSelectionForeColor;
    property SelectionAlpha: Integer read FSelectionAlpha write FSelectionAlpha;
    property CaretBeyondLineEndings: Boolean read FCaretBeyondLineEndings write FCaretBeyondLineEndings;
    property WrapCursorAtLineStart: Boolean read FWrapCursorAtLineStart write FWrapCursorAtLineStart;
    property CaretSticky: TDSciCaretSticky read FCaretSticky write FCaretSticky;
    property MultiPaste: Boolean read FMultiPaste write FMultiPaste;
    property PasteConvertEndings: Boolean read FPasteConvertEndings write FPasteConvertEndings;
    property PrintMagnification: Integer read FPrintMagnification write FPrintMagnification;
    property FoldingLines: Boolean read FFoldingLines write FFoldingLines;
    property FoldingText: string read FFoldingText write FFoldingText;
    property FoldDisplayTextStyle: TDSciFoldDisplayTextStyle read FFoldDisplayTextStyle write FFoldDisplayTextStyle;
    property Technology: TDSciTechnology read FTechnology write FTechnology;
    property FontLocale: string read FFontLocale write FFontLocale;
    property FontQuality: TDSciFontQuality read FFontQuality write FFontQuality;
    property TabWidth: Integer read FTabWidth write FTabWidth;
    property FileSizeLimit: Int64 read FFileSizeLimit write FFileSizeLimit;
    property SearchSync: Boolean read FSearchSync write FSearchSync;
    property LogEnabled: Boolean read FLogEnabled write FLogEnabled;
    property LogLevel: Integer read FLogLevel write FLogLevel;
    property LogOutput: Integer read FLogOutput write FLogOutput;
    property ShowStatusBar: Boolean read FShowStatusBar write FShowStatusBar;
    property StatusPanelFileVisible: Boolean read FStatusPanelFileVisible write FStatusPanelFileVisible;
    property StatusPanelPosVisible: Boolean read FStatusPanelPosVisible write FStatusPanelPosVisible;
    property StatusPanelLexerVisible: Boolean read FStatusPanelLexerVisible write FStatusPanelLexerVisible;
    property StatusPanelEncodingVisible: Boolean read FStatusPanelEncodingVisible write FStatusPanelEncodingVisible;
    property StatusPanelThemeVisible: Boolean read FStatusPanelThemeVisible write FStatusPanelThemeVisible;
    property StatusPanelLoadVisible: Boolean read FStatusPanelLoadVisible write FStatusPanelLoadVisible;
    property StyleOverrides: TDSciVisualStyleModel read FStyleOverrides;
  end;

  TDSciVisualCatalog = class
  private
    FThemeName: string;
    FModel: TDSciVisualStyleModel;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromConfig(AConfig: TDSciVisualConfig);
    procedure PopulateLanguageNames(AItems: TStrings);
    procedure PopulateThemeNames(AItems: TStrings);
    function FindLanguage(const AName: string): TDSciVisualStyleGroup;
    function BuildEffectiveStyle(const ALanguageName, AStyleName: string;
      AKind: TDSciVisualStyleKind): TDSciVisualStyleData;

    property Model: TDSciVisualStyleModel read FModel;
    property ThemeName: string read FThemeName;
  end;

function LoadThemeStyleModelFromFile(const AFileName: string): TDSciVisualStyleModel;

implementation

uses
  System.IOUtils, System.Math, System.StrUtils, System.SysUtils, System.Variants,
  System.Win.ComObj,
  Winapi.ActiveX, Winapi.Windows,
  Xml.XMLDoc, Xml.XMLIntf, Xml.xmldom, Xml.omnixmldom;

type
  TDSciVisualSortStringList = class(TStringList)
  public
    function CompareStrings(const S1, S2: string): Integer; override;
  end;

function TDSciVisualSortStringList.CompareStrings(const S1, S2: string): Integer;
begin
  if SameText(S1, 'default') then
  begin
    if SameText(S2, 'default') then
      Exit(0);
    Exit(-1);
  end;
  if SameText(S2, 'default') then
    Exit(1);
  Result := inherited CompareStrings(S1, S2);
end;

procedure CheckHRESULT(AResult: HRESULT);
begin
  if Failed(AResult) then
    raise Exception.CreateFmt('HRESULT 0x%x', [Cardinal(AResult)]);
end;

function CreateXmlDocument: IXMLDocument;
var
  lDocument: TXMLDocument;
begin
  lDocument := TXMLDocument.Create(nil);
  lDocument.DOMVendor := GetDOMVendor('Omni XML');
  Result := lDocument;
end;

function IsElementNode(const ANode: IXMLNode): Boolean;
begin
  Result := (ANode <> nil) and (ANode.NodeType = ntElement);
end;

function GetNodeAttribute(const ANode: IXMLNode; const AName: string): string;
var
  lValue: Variant;
begin
  Result := '';
  if not IsElementNode(ANode) then
    Exit;

  lValue := ANode.Attributes[AName];
  if VarIsNull(lValue) or VarIsEmpty(lValue) then
    Exit;

  Result := VarToStr(lValue);
end;

function FindChildNode(const ANode: IXMLNode; const AName: string): IXMLNode;
var
  lChild: IXMLNode;
  lIndex: Integer;
begin
  Result := nil;
  if ANode = nil then
    Exit;

  for lIndex := 0 to ANode.ChildNodes.Count - 1 do
  begin
    lChild := ANode.ChildNodes[lIndex];
    if not IsElementNode(lChild) then
      Continue;
    if SameText(lChild.NodeName, AName) then
      Exit(lChild);
  end;
end;

function ParseOptionalInt(const AValue: string; out AInt: Integer): Boolean;
var
  lValue: string;
begin
  lValue := Trim(AValue);
  if lValue = '' then
    Exit(False);

  if StartsText('0x', lValue) then
    lValue := '$' + Copy(lValue, 3, MaxInt);

  Result := TryStrToInt(lValue, AInt);
end;

function ParseOptionalInt64(const AValue: string; out AInt: Int64): Boolean;
var
  lValue: string;
begin
  lValue := Trim(AValue);
  if lValue = '' then
    Exit(False);

  if StartsText('0x', lValue) then
    lValue := '$' + Copy(lValue, 3, MaxInt);

  Result := TryStrToInt64(lValue, AInt);
end;

function FormatHexInt(AValue: Int64): string;
begin
  Result := '0x' + LowerCase(IntToHex(AValue, 1));
end;

function FormatSetInt(AValue: Integer): string;
begin
  Result := IntToStr(AValue);
end;

function ParseHexColor(const AValue: string; out AColor: TColor): Boolean;
var
  lBlue: Integer;
  lGreen: Integer;
  lRed: Integer;
  lValue: string;
begin
  Result := False;
  lValue := Trim(AValue);
  if Length(lValue) <> 6 then
    Exit;

  Result :=
    TryStrToInt('$' + Copy(lValue, 1, 2), lRed) and
    TryStrToInt('$' + Copy(lValue, 3, 2), lGreen) and
    TryStrToInt('$' + Copy(lValue, 5, 2), lBlue);
  if Result then
    AColor := TColor(RGB(lRed, lGreen, lBlue));
end;

function ColorToHex(AColor: TColor): string;
var
  lColor: COLORREF;
begin
  lColor := ColorToRGB(AColor);
  Result := Format('%.2x%.2x%.2x', [
    GetRValue(lColor),
    GetGValue(lColor),
    GetBValue(lColor)
  ]);
end;

function ParseYesNo(const AValue: string; ADefault: Boolean): Boolean;
begin
  if SameText(Trim(AValue), 'yes') then
    Exit(True);
  if SameText(Trim(AValue), 'no') then
    Exit(False);
  Result := ADefault;
end;

function YesNo(ABool: Boolean): string;
begin
  if ABool then
    Result := 'yes'
  else
    Result := 'no';
end;

function ClampByteAlphaValue(AValue: Integer): Byte;
begin
  Result := Byte(EnsureRange(AValue, 0, 255));
end;

function ClampSelectionAlphaValue(AValue: Integer): Integer;
begin
  Result := EnsureRange(AValue, 0, 256);
end;

function NormalizeExtensionToken(const AValue: string): string;
var
  lToken: string;
begin
  lToken := Trim(AValue);
  if lToken = '' then
    Exit('');

  if ExtractFileExt(lToken) <> '' then
    lToken := ExtractFileExt(lToken)
  else if Pos(PathDelim, lToken) > 0 then
    lToken := ExtractFileExt(lToken);

  if (lToken <> '') and (lToken[1] = '.') then
    Delete(lToken, 1, 1);

  Result := LowerCase(Trim(lToken));
end;

function MatchesExtensions(const AExtensions, AFileName: string): Boolean;
var
  lExtension: string;
  lToken: string;
  lTokens: TStringList;
begin
  Result := False;
  lExtension := NormalizeExtensionToken(AFileName);
  if lExtension = '' then
    Exit;

  lTokens := TStringList.Create;
  try
    lTokens.StrictDelimiter := True;
    lTokens.Delimiter := ' ';
    lTokens.DelimitedText := StringReplace(Trim(AExtensions), #9, ' ', [rfReplaceAll]);
    for lToken in lTokens do
      if SameText(NormalizeExtensionToken(lToken), lExtension) then
        Exit(True);
  finally
    lTokens.Free;
  end;
end;

function CreateStyleData(const AKind: TDSciVisualStyleKind): TDSciVisualStyleData;
begin
  Result := TDSciVisualStyleData.Create;
  Result.Kind := AKind;
end;

function FindKeywordNode(const ANode: IXMLNode): IXMLNode;
begin
  Result := FindChildNode(ANode, 'Keywords');
end;

function InferConfigStyleKind(const AGroupName: string;
  const AStyleNode: IXMLNode): TDSciVisualStyleKind;
var
  lKind: string;
begin
  lKind := Trim(GetNodeAttribute(AStyleNode, 'kind'));
  if SameText(lKind, 'global') then
    Exit(dvskGlobal);
  if SameText(lKind, 'lexer') then
    Exit(dvskLexer);

  if SameText(AGroupName, 'default') and
     not SameText(GetNodeAttribute(AStyleNode, 'name'), 'DEFAULT') and
     not SameText(GetNodeAttribute(AStyleNode, 'name'), 'Global override') then
    Exit(dvskGlobal);

  Result := dvskLexer;
end;

function ParseStyleNode(const ANode: IXMLNode;
  AKind: TDSciVisualStyleKind): TDSciVisualStyleData;
var
  lKeywordNode: IXMLNode;
begin
  Result := CreateStyleData(AKind);
  Result.Name := GetNodeAttribute(ANode, 'name');
  Result.KeywordClass := GetNodeAttribute(ANode, 'keywordClass');
  Result.HasStyleID := ParseOptionalInt(GetNodeAttribute(ANode, 'styleID'), Result.StyleID);
  Result.HasKeywordsID := ParseOptionalInt(GetNodeAttribute(ANode, 'id'), Result.KeywordsID);
  Result.HasForeColor := ParseHexColor(GetNodeAttribute(ANode, 'fgColor'), Result.ForeColor);
  Result.HasBackColor := ParseHexColor(GetNodeAttribute(ANode, 'bgColor'), Result.BackColor);
  Result.FontName := Trim(GetNodeAttribute(ANode, 'fontName'));
  Result.HasFontStyle := ParseOptionalInt(GetNodeAttribute(ANode, 'fontStyle'), Result.FontStyle);
  Result.HasFontSize := ParseOptionalInt(GetNodeAttribute(ANode, 'fontSize'), Result.FontSize);
  Result.HasEOLFill := ParseOptionalInt(GetNodeAttribute(ANode, 'eolFill'), Result.EOLFill);

  lKeywordNode := FindKeywordNode(ANode);
  if lKeywordNode <> nil then
  begin
    Result.KeywordsText := Trim(lKeywordNode.Text);
    if not Result.HasKeywordsID then
      Result.HasKeywordsID := ParseOptionalInt(GetNodeAttribute(lKeywordNode, 'id'),
        Result.KeywordsID);
  end
  else
    Result.KeywordsText := Trim(ANode.Text);
end;

procedure LoadVisualConfigDataFromDocument(const ATarget: TDSciVisualConfig;
  const AXml: IXMLDocument);
var
  lEditorNode: IXMLNode;
  lFileSizeNode: IXMLNode;
  lGroup: TDSciVisualStyleGroup;
  lHighlightNode: IXMLNode;
  lNode: IXMLNode;
  lRoot: IXMLNode;
  lSelectionNode: IXMLNode;
  lRenderingNode: IXMLNode;
  lSmartHighlightNode: IXMLNode;
  lStyleNode: IXMLNode;
  lStylesNode: IXMLNode;
  lThemeNode: IXMLNode;
  lInt64Value: Int64;
  lValue: Integer;
  lIndex: Integer;
  lWordIndex: Integer;
  lWrapModeSpecified: Boolean;
  lStyle: TDSciVisualStyleData;
begin
  ATarget.ResetDefaults;

  lRoot := AXml.DocumentElement;
  if lRoot = nil then
    Exit;

  lThemeNode := FindChildNode(lRoot, 'Theme');
  if lThemeNode <> nil then
    ATarget.FThemeName := Trim(GetNodeAttribute(lThemeNode, 'Name'));

  lHighlightNode := FindChildNode(lRoot, 'Highlight');
  if lHighlightNode <> nil then
  begin
    ParseHexColor(GetNodeAttribute(lHighlightNode, 'Foreground'), ATarget.FHighlightColor);
    if ParseOptionalInt('$' + GetNodeAttribute(lHighlightNode, 'ForegroundAlpha'), lValue) then
      ATarget.FHighlightAlpha := Byte(EnsureRange(lValue, 0, 255));
    if ParseOptionalInt('$' + GetNodeAttribute(lHighlightNode, 'OutlineAlpha'), lValue) then
      ATarget.FHighlightOutlineAlpha := Byte(EnsureRange(lValue, 0, 255));
  end;

  lEditorNode := FindChildNode(lRoot, 'Editor');
  if lEditorNode <> nil then
  begin
    ATarget.FBackSpaceUnIndents := ParseYesNo(
      GetNodeAttribute(lEditorNode, 'BackSpaceUnIndents'), ATarget.FBackSpaceUnIndents);
    if ParseOptionalInt(GetNodeAttribute(lEditorNode, 'IndentationGuides'), lValue) then
      ATarget.FIndentationGuides := TDSciIndentViewFromInt(lValue);
    if ParseOptionalInt(GetNodeAttribute(lEditorNode, 'WhiteSpaceStyle'), lValue) then
      ATarget.FWhiteSpaceStyle := TDSciWhiteSpaceFromInt(lValue);
    if ParseOptionalInt(GetNodeAttribute(lEditorNode, 'WhiteSpaceSize'), lValue) then
      ATarget.FWhiteSpaceSize := lValue;
    if ParseOptionalInt(GetNodeAttribute(lEditorNode, 'UpperLineSpacing'), lValue) then
      ATarget.FUpperLineSpacing := lValue;
    if ParseOptionalInt(GetNodeAttribute(lEditorNode, 'LowerLineSpacing'), lValue) then
      ATarget.FLowerLineSpacing := lValue;
  end;

  lFileSizeNode := FindChildNode(lRoot, 'FileSizeLimit');
  if (lFileSizeNode <> nil) and ParseOptionalInt64(Trim(lFileSizeNode.Text), lInt64Value) then
    ATarget.FFileSizeLimit := Max(Int64(0), lInt64Value);

  lNode := FindChildNode(lRoot, 'LineNumbering');
  if lNode <> nil then
  begin
    ATarget.FLineNumbering := ParseYesNo(GetNodeAttribute(lNode, 'Enabled'),
      ATarget.FLineNumbering);
    if ParseOptionalInt(GetNodeAttribute(lNode, 'WidthMode'), lValue) then
      if lValue in [Ord(Low(TDSciLineNumberWidthMode))..Ord(High(TDSciLineNumberWidthMode))] then
        ATarget.FLineNumberWidthMode := TDSciLineNumberWidthMode(lValue);
    if ParseOptionalInt(GetNodeAttribute(lNode, 'PaddingLeft'), lValue) then
      ATarget.FLineNumberPaddingLeft := Max(0, lValue);
    if ParseOptionalInt(GetNodeAttribute(lNode, 'PaddingRight'), lValue) then
      ATarget.FLineNumberPaddingRight := Max(0, lValue);
  end;

  lNode := FindChildNode(lRoot, 'TextPadding');
  if lNode <> nil then
  begin
    if ParseOptionalInt(GetNodeAttribute(lNode, 'Left'), lValue) then
      ATarget.FTextPaddingLeft := Max(0, lValue);
    if ParseOptionalInt(GetNodeAttribute(lNode, 'Right'), lValue) then
      ATarget.FTextPaddingRight := Max(0, lValue);
  end;

  lNode := FindChildNode(lRoot, 'BookmarkMargin');
  if lNode <> nil then
    ATarget.FBookmarkMarginVisible := ParseYesNo(GetNodeAttribute(lNode, 'Enabled'),
      ATarget.FBookmarkMarginVisible);

  lNode := FindChildNode(lRoot, 'FoldMargin');
  if lNode <> nil then
  begin
    ATarget.FFoldMarginVisible := ParseYesNo(GetNodeAttribute(lNode, 'Enabled'),
      ATarget.FFoldMarginVisible);
    if ParseOptionalInt(GetNodeAttribute(lNode, 'MarkerStyle'), lValue) then
      ATarget.FFoldMarkerStyle := TDSciFoldMarkerStyle(EnsureRange(lValue, 0, Ord(High(TDSciFoldMarkerStyle))));
  end;

  lNode := FindChildNode(lRoot, 'LineWrapping');
  lWrapModeSpecified := False;
  if lNode <> nil then
  begin
    ATarget.FLineWrapping := ParseYesNo(GetNodeAttribute(lNode, 'Enabled'),
      ATarget.FLineWrapping);
    lWrapModeSpecified := ParseOptionalInt(GetNodeAttribute(lNode, 'Mode'), lValue);
    if lWrapModeSpecified then
      ATarget.FWrapMode := TDSciWrapFromInt(lValue);
    if ParseOptionalInt(GetNodeAttribute(lNode, 'VisualFlags'), lValue) then
      ATarget.FWrapVisualFlags := TDSciWrapVisualFlagSetFromInt(lValue);
    if ParseOptionalInt(GetNodeAttribute(lNode, 'VisualFlagsLocation'), lValue) then
      ATarget.FWrapVisualFlagsLocation := TDSciWrapVisualLocationSetFromInt(lValue);
  end;

  if lWrapModeSpecified then
    ATarget.FLineWrapping := ATarget.FWrapMode <> scwNONE
  else if ATarget.FLineWrapping then
    ATarget.FWrapMode := scwWORD
  else
    ATarget.FWrapMode := scwNONE;

  lNode := FindChildNode(lRoot, 'Tabulator');
  if (lNode <> nil) and ParseOptionalInt(GetNodeAttribute(lNode, 'Width'), lValue) then
    ATarget.FTabWidth := Max(1, lValue);

  lNode := FindChildNode(lRoot, 'SearchSync');
  if lNode <> nil then
    ATarget.FSearchSync := ParseYesNo(GetNodeAttribute(lNode, 'Enabled'), ATarget.FSearchSync);

  lSelectionNode := FindChildNode(lRoot, 'Selection');
  if lSelectionNode <> nil then
  begin
    ATarget.FSelectFullLine := ParseYesNo(GetNodeAttribute(lSelectionNode, 'FullLine'),
      ATarget.FSelectFullLine);
    ATarget.FUseSelectionForeColor := ParseYesNo(
      GetNodeAttribute(lSelectionNode, 'UseForeColor'), ATarget.FUseSelectionForeColor);
    ParseHexColor(GetNodeAttribute(lSelectionNode, 'ForeColor'), ATarget.FSelectionForeColor);
    if ParseOptionalInt(GetNodeAttribute(lSelectionNode, 'Alpha'), lValue) then
      ATarget.FSelectionAlpha := ClampSelectionAlphaValue(lValue);
  end;

  lRenderingNode := FindChildNode(lRoot, 'Rendering');
  if lRenderingNode <> nil then
  begin
    if ParseOptionalInt(GetNodeAttribute(lRenderingNode, 'Technology'), lValue) then
      ATarget.FTechnology := TDSciTechnologyFromInt(lValue);
    ATarget.FFontLocale := Trim(GetNodeAttribute(lRenderingNode, 'FontLocale'));
    if ParseOptionalInt(GetNodeAttribute(lRenderingNode, 'FontQuality'), lValue) then
      ATarget.FFontQuality := TDSciFontQualityFromInt(lValue);
  end;

  lSmartHighlightNode := FindChildNode(lRoot, 'SmartHighlighting');
  if lSmartHighlightNode <> nil then
  begin
    if ParseOptionalInt(GetNodeAttribute(lSmartHighlightNode, 'Style'), lValue) then
      ATarget.FSmartHighlightStyle := TDSciIndicatorStyleFromInt(lValue);
    if ParseOptionalInt(GetNodeAttribute(lSmartHighlightNode, 'FillAlpha'), lValue) then
      ATarget.FSmartHighlightFillAlpha := ClampByteAlphaValue(lValue);
    if ParseOptionalInt(GetNodeAttribute(lSmartHighlightNode, 'OutlineAlpha'), lValue) then
      ATarget.FSmartHighlightOutlineAlpha := ClampByteAlphaValue(lValue);
  end;

  lNode := FindChildNode(lRoot, 'Caret');
  if lNode <> nil then
  begin
    ATarget.FCaretBeyondLineEndings := ParseYesNo(
      GetNodeAttribute(lNode, 'BeyondLineEndings'), ATarget.FCaretBeyondLineEndings);
    ATarget.FWrapCursorAtLineStart := ParseYesNo(
      GetNodeAttribute(lNode, 'WrapAtLineStart'), ATarget.FWrapCursorAtLineStart);
    if ParseOptionalInt(GetNodeAttribute(lNode, 'Sticky'), lValue) then
      ATarget.FCaretSticky := TDSciCaretStickyFromInt(lValue);
  end;

  lNode := FindChildNode(lRoot, 'CopyPaste');
  if lNode <> nil then
  begin
    ATarget.FMultiPaste := ParseYesNo(GetNodeAttribute(lNode, 'MultiPaste'),
      ATarget.FMultiPaste);
    ATarget.FPasteConvertEndings := ParseYesNo(
      GetNodeAttribute(lNode, 'ConvertEolOnPaste'), ATarget.FPasteConvertEndings);
  end;

  lNode := FindChildNode(lRoot, 'Printing');
  if (lNode <> nil) and ParseOptionalInt(GetNodeAttribute(lNode, 'Magnification'), lValue) then
    ATarget.FPrintMagnification := lValue;

  lNode := FindChildNode(lRoot, 'CodeFolding');
  if lNode <> nil then
  begin
    ATarget.FFoldingLines := ParseYesNo(GetNodeAttribute(lNode, 'Lines'),
      ATarget.FFoldingLines);
    ATarget.FFoldingText := GetNodeAttribute(lNode, 'Text');
    if ParseOptionalInt(GetNodeAttribute(lNode, 'TextStyle'), lValue) then
      ATarget.FFoldDisplayTextStyle := TDSciFoldDisplayTextStyleFromInt(lValue);
  end;

  lNode := FindChildNode(lRoot, 'Logging');
  if lNode <> nil then
  begin
    ATarget.FLogEnabled := ParseYesNo(GetNodeAttribute(lNode, 'Enabled'), ATarget.FLogEnabled);
    if ParseOptionalInt(GetNodeAttribute(lNode, 'Level'), lValue) then
      ATarget.FLogLevel := EnsureRange(lValue, 0, 3);
    if ParseOptionalInt(GetNodeAttribute(lNode, 'Output'), lValue) then
      ATarget.FLogOutput := EnsureRange(lValue, 0, 1);
    if ParseYesNo(GetNodeAttribute(lNode, 'ToFile'), False) then
    begin
      ATarget.FLogEnabled := True;
      ATarget.FLogOutput := 1;
    end;
  end;

  lNode := FindChildNode(lRoot, 'StatusBar');
  if lNode <> nil then
  begin
    ATarget.FShowStatusBar := ParseYesNo(GetNodeAttribute(lNode, 'Visible'), ATarget.FShowStatusBar);
    ATarget.FStatusPanelFileVisible := ParseYesNo(GetNodeAttribute(lNode, 'PanelFile'), ATarget.FStatusPanelFileVisible);
    ATarget.FStatusPanelPosVisible := ParseYesNo(GetNodeAttribute(lNode, 'PanelPos'), ATarget.FStatusPanelPosVisible);
    ATarget.FStatusPanelLexerVisible := ParseYesNo(GetNodeAttribute(lNode, 'PanelLexer'), ATarget.FStatusPanelLexerVisible);
    ATarget.FStatusPanelEncodingVisible := ParseYesNo(GetNodeAttribute(lNode, 'PanelEncoding'), ATarget.FStatusPanelEncodingVisible);
    ATarget.FStatusPanelThemeVisible := ParseYesNo(GetNodeAttribute(lNode, 'PanelTheme'), ATarget.FStatusPanelThemeVisible);
    ATarget.FStatusPanelLoadVisible := ParseYesNo(GetNodeAttribute(lNode, 'PanelLoad'), ATarget.FStatusPanelLoadVisible);
  end;

  lStylesNode := FindChildNode(lRoot, 'Styles');
  if lStylesNode = nil then
    Exit;

  for lIndex := 0 to lStylesNode.ChildNodes.Count - 1 do
  begin
    lStyleNode := lStylesNode.ChildNodes[lIndex];
    if not IsElementNode(lStyleNode) then
      Continue;
    if not SameText(lStyleNode.NodeName, 'Style') then
      Continue;

    lGroup := ATarget.FStyleOverrides.EnsureGroup(GetNodeAttribute(lStyleNode, 'name'));
    lGroup.Extensions := Trim(GetNodeAttribute(lStyleNode, 'ext'));
    lGroup.Description := Trim(GetNodeAttribute(lStyleNode, 'desc'));
    lGroup.HasLexerID := ParseOptionalInt(GetNodeAttribute(lStyleNode, 'lexer'),
      lGroup.LexerID);

    lNode := FindChildNode(lStyleNode, 'WordStyles');
    if lNode = nil then
      Continue;

    for lWordIndex := 0 to lNode.ChildNodes.Count - 1 do
    begin
      lStyleNode := lNode.ChildNodes[lWordIndex];
      if not IsElementNode(lStyleNode) then
        Continue;
      if not SameText(lStyleNode.NodeName, 'WordStyle') then
        Continue;

      lStyle := ParseStyleNode(lStyleNode, InferConfigStyleKind(lGroup.Name, lStyleNode));
      lGroup.Styles.Add(lStyle);
    end;
  end;
end;

procedure LoadVisualConfigData(const ATarget: TDSciVisualConfig; const AFileName: string);
var
  lInit: HRESULT;
  lStep: string;
  lXml: IXMLDocument;
begin
  try
    lStep := 'reset defaults';
    ATarget.ResetDefaults;
    if not FileExists(AFileName) then
      Exit;

    lStep := 'initialize com';
    lInit := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
    if Failed(lInit) and (lInit <> RPC_E_CHANGED_MODE) then
      CheckHRESULT(lInit);
    try
      lStep := 'create xml document';
      lXml := CreateXmlDocument;
      lStep := 'load xml file';
      lXml.LoadFromFile(AFileName);
      lStep := 'activate xml document';
      lXml.Active := True;
      lStep := 'parse xml';
      LoadVisualConfigDataFromDocument(ATarget, lXml);
    finally
      lXml := nil;
      if (lInit = S_OK) or (lInit = S_FALSE) then
        CoUninitialize;
    end;
  except
    on E: Exception do
      raise Exception.CreateFmt('LoadVisualConfigData %s failed: %s - %s',
        [lStep, E.ClassName, E.Message]);
  end;
end;

procedure LoadVisualConfigDataFromStream(const ATarget: TDSciVisualConfig;
  AStream: TStream);
var
  lInit: HRESULT;
  lStep: string;
  lXml: IXMLDocument;
begin
  if AStream = nil then
    raise EArgumentNilException.Create('AStream');

  try
    lStep := 'initialize com';
    lInit := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
    if Failed(lInit) and (lInit <> RPC_E_CHANGED_MODE) then
      CheckHRESULT(lInit);
    try
      lStep := 'create xml document';
      lXml := CreateXmlDocument;
      lStep := 'load xml stream';
      AStream.Position := 0;
      lXml.LoadFromStream(AStream);
      lStep := 'activate xml document';
      lXml.Active := True;
      lStep := 'parse xml';
      LoadVisualConfigDataFromDocument(ATarget, lXml);
    finally
      lXml := nil;
      if (lInit = S_OK) or (lInit = S_FALSE) then
        CoUninitialize;
    end;
  except
    on E: Exception do
      raise Exception.CreateFmt('LoadVisualConfigDataFromStream %s failed: %s - %s',
        [lStep, E.ClassName, E.Message]);
  end;
end;

procedure OverlayStyle(ATarget, AOverlay: TDSciVisualStyleData);
begin
  if (ATarget = nil) or (AOverlay = nil) then
    Exit;

  ATarget.Kind := AOverlay.Kind;
  if AOverlay.Name <> '' then
    ATarget.Name := AOverlay.Name;
  if AOverlay.HasStyleID then
  begin
    ATarget.StyleID := AOverlay.StyleID;
    ATarget.HasStyleID := True;
  end;
  if AOverlay.HasKeywordsID then
  begin
    ATarget.KeywordsID := AOverlay.KeywordsID;
    ATarget.HasKeywordsID := True;
  end;
  if AOverlay.HasForeColor then
  begin
    ATarget.ForeColor := AOverlay.ForeColor;
    ATarget.HasForeColor := True;
  end;
  if AOverlay.HasBackColor then
  begin
    ATarget.BackColor := AOverlay.BackColor;
    ATarget.HasBackColor := True;
  end;
  if AOverlay.FontName <> '' then
    ATarget.FontName := AOverlay.FontName;
  if AOverlay.HasFontStyle then
  begin
    ATarget.FontStyle := AOverlay.FontStyle;
    ATarget.HasFontStyle := True;
  end;
  if AOverlay.HasFontSize then
  begin
    ATarget.FontSize := AOverlay.FontSize;
    ATarget.HasFontSize := True;
  end;
  if AOverlay.HasEOLFill then
  begin
    ATarget.EOLFill := AOverlay.EOLFill;
    ATarget.HasEOLFill := True;
  end;
  if AOverlay.KeywordClass <> '' then
    ATarget.KeywordClass := AOverlay.KeywordClass;
  if AOverlay.KeywordsText <> '' then
    ATarget.KeywordsText := AOverlay.KeywordsText;
end;

procedure MergeModel(ATarget, AOverlay: TDSciVisualStyleModel);
var
  lExistingStyle: TDSciVisualStyleData;
  lOverlayGroup: TDSciVisualStyleGroup;
  lOverlayStyle: TDSciVisualStyleData;
  lTargetGroup: TDSciVisualStyleGroup;
begin
  if (ATarget = nil) or (AOverlay = nil) then
    Exit;

  for lOverlayGroup in AOverlay.Groups do
  begin
    lTargetGroup := ATarget.EnsureGroup(lOverlayGroup.Name);
    if lOverlayGroup.Description <> '' then
      lTargetGroup.Description := lOverlayGroup.Description;
    if lOverlayGroup.Extensions <> '' then
      lTargetGroup.Extensions := lOverlayGroup.Extensions;
    if lOverlayGroup.HasLexerID then
    begin
      lTargetGroup.LexerID := lOverlayGroup.LexerID;
      lTargetGroup.HasLexerID := True;
    end;

    for lOverlayStyle in lOverlayGroup.Styles do
    begin
      if lOverlayStyle.HasStyleID then
        lExistingStyle := lTargetGroup.FindStyleByID(lOverlayStyle.StyleID, lOverlayStyle.Kind)
      else
        lExistingStyle := nil;
      if lExistingStyle = nil then
        lExistingStyle := lTargetGroup.FindStyle(lOverlayStyle.Name, lOverlayStyle.Kind);
      if lExistingStyle = nil then
        lTargetGroup.Styles.Add(lOverlayStyle.Clone)
      else
        OverlayStyle(lExistingStyle, lOverlayStyle);
    end;
  end;
end;

function LoadThemeStyleModelFromFile(const AFileName: string): TDSciVisualStyleModel;
var
  lGlobalNode: IXMLNode;
  lGroup: TDSciVisualStyleGroup;
  lIndex: Integer;
  lInit: HRESULT;
  lLexerNode: IXMLNode;
  lLexerStylesNode: IXMLNode;
  lNode: IXMLNode;
  lRoot: IXMLNode;
  lStyleIndex: Integer;
  lXml: IXMLDocument;
begin
  if not FileExists(AFileName) then
    raise EFileNotFoundException.CreateFmt('Theme file not found: %s', [AFileName]);

  lInit := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
  if Failed(lInit) and (lInit <> RPC_E_CHANGED_MODE) then
    CheckHRESULT(lInit);
  try
    lXml := CreateXmlDocument;
    lXml.LoadFromFile(AFileName);
    lXml.Active := True;

    Result := TDSciVisualStyleModel.Create;
    try
      lRoot := lXml.DocumentElement;
      lLexerStylesNode := FindChildNode(lRoot, 'LexerStyles');
      if lLexerStylesNode <> nil then
        for lIndex := 0 to lLexerStylesNode.ChildNodes.Count - 1 do
        begin
          lLexerNode := lLexerStylesNode.ChildNodes[lIndex];
          if not IsElementNode(lLexerNode) then
            Continue;
          if not SameText(lLexerNode.NodeName, 'LexerType') then
            Continue;

          lGroup := Result.EnsureGroup(GetNodeAttribute(lLexerNode, 'name'));
          lGroup.Description := GetNodeAttribute(lLexerNode, 'desc');
          lGroup.Extensions := GetNodeAttribute(lLexerNode, 'ext');
          lGroup.HasLexerID := ParseOptionalInt(GetNodeAttribute(lLexerNode, 'lexer'),
            lGroup.LexerID);

          for lStyleIndex := 0 to lLexerNode.ChildNodes.Count - 1 do
          begin
            lNode := lLexerNode.ChildNodes[lStyleIndex];
            if not IsElementNode(lNode) then
              Continue;
            if not SameText(lNode.NodeName, 'WordsStyle') then
              Continue;
            lGroup.Styles.Add(ParseStyleNode(lNode, dvskLexer));
          end;
        end;

      lGlobalNode := FindChildNode(lRoot, 'GlobalStyles');
      if lGlobalNode <> nil then
      begin
        lGroup := Result.EnsureGroup('default');
        if lGroup.Extensions = '' then
          lGroup.Extensions := '*';

        for lIndex := 0 to lGlobalNode.ChildNodes.Count - 1 do
        begin
          lNode := lGlobalNode.ChildNodes[lIndex];
          if not IsElementNode(lNode) then
            Continue;
          if not SameText(lNode.NodeName, 'WidgetStyle') then
            Continue;
          lGroup.Styles.Add(ParseStyleNode(lNode, dvskGlobal));
        end;
      end;
    except
      Result.Free;
      raise;
    end;
  finally
    lNode := nil;
    lLexerNode := nil;
    lLexerStylesNode := nil;
    lGlobalNode := nil;
    lRoot := nil;
    lXml := nil;
    if (lInit = S_OK) or (lInit = S_FALSE) then
      CoUninitialize;
  end;
end;

function WriteStyleNode(AParent: IXMLNode; AStyle: TDSciVisualStyleData;
  const ANodeName: string; AUseNestedKeywords: Boolean = False): IXMLNode;
var
  lKeywordNode: IXMLNode;
begin
  Result := AParent.AddChild(ANodeName);
  if AStyle.Name <> '' then
    Result.Attributes['name'] := AStyle.Name;
  if AStyle.HasStyleID then
    Result.Attributes['styleID'] := AStyle.StyleID;
  if AStyle.HasForeColor then
    Result.Attributes['fgColor'] := ColorToHex(AStyle.ForeColor);
  if AStyle.HasBackColor then
    Result.Attributes['bgColor'] := ColorToHex(AStyle.BackColor);
  if AStyle.FontName <> '' then
    Result.Attributes['fontName'] := AStyle.FontName;
  if AStyle.HasFontStyle then
    Result.Attributes['fontStyle'] := AStyle.FontStyle;
  if AStyle.HasFontSize then
    Result.Attributes['fontSize'] := AStyle.FontSize;
  if AStyle.HasEOLFill then
    Result.Attributes['eolFill'] := AStyle.EOLFill;
  if AStyle.KeywordClass <> '' then
    Result.Attributes['keywordClass'] := AStyle.KeywordClass;
  if AStyle.KeywordsText <> '' then
    if AUseNestedKeywords then
    begin
    lKeywordNode := Result.AddChild('Keywords');
    if AStyle.HasKeywordsID then
      lKeywordNode.Attributes['id'] := AStyle.KeywordsID;
    lKeywordNode.NodeValue := AStyle.KeywordsText;
    end
    else
      Result.NodeValue := AStyle.KeywordsText;
end;

{ TDSciVisualStyleData }

procedure TDSciVisualStyleData.Assign(ASource: TDSciVisualStyleData);
begin
  if ASource = nil then
    Exit;

  Kind := ASource.Kind;
  Name := ASource.Name;
  StyleID := ASource.StyleID;
  HasStyleID := ASource.HasStyleID;
  KeywordsID := ASource.KeywordsID;
  HasKeywordsID := ASource.HasKeywordsID;
  HasForeColor := ASource.HasForeColor;
  ForeColor := ASource.ForeColor;
  HasBackColor := ASource.HasBackColor;
  BackColor := ASource.BackColor;
  FontName := ASource.FontName;
  HasFontStyle := ASource.HasFontStyle;
  FontStyle := ASource.FontStyle;
  HasFontSize := ASource.HasFontSize;
  FontSize := ASource.FontSize;
  EOLFill := ASource.EOLFill;
  HasEOLFill := ASource.HasEOLFill;
  KeywordClass := ASource.KeywordClass;
  KeywordsText := ASource.KeywordsText;
end;

function TDSciVisualStyleData.Clone: TDSciVisualStyleData;
begin
  Result := TDSciVisualStyleData.Create;
  Result.Assign(Self);
end;

{ TDSciVisualStyleGroup }

constructor TDSciVisualStyleGroup.Create;
begin
  inherited Create;
  FStyles := TObjectList<TDSciVisualStyleData>.Create(True);
end;

destructor TDSciVisualStyleGroup.Destroy;
begin
  FStyles.Free;
  inherited Destroy;
end;

procedure TDSciVisualStyleGroup.Assign(ASource: TDSciVisualStyleGroup);
var
  lStyle: TDSciVisualStyleData;
begin
  Name := ASource.Name;
  Description := ASource.Description;
  Extensions := ASource.Extensions;
  LexerID := ASource.LexerID;
  HasLexerID := ASource.HasLexerID;
  FStyles.Clear;
  for lStyle in ASource.Styles do
    FStyles.Add(lStyle.Clone);
end;

function TDSciVisualStyleGroup.FindStyle(const AName: string;
  AKind: TDSciVisualStyleKind): TDSciVisualStyleData;
var
  lStyle: TDSciVisualStyleData;
begin
  Result := nil;
  for lStyle in FStyles do
    if (lStyle.Kind = AKind) and SameText(lStyle.Name, AName) then
      Exit(lStyle);
end;

function TDSciVisualStyleGroup.FindStyleByID(AStyleID: Integer;
  AKind: TDSciVisualStyleKind): TDSciVisualStyleData;
var
  lStyle: TDSciVisualStyleData;
begin
  Result := nil;
  for lStyle in FStyles do
    if (lStyle.Kind = AKind) and lStyle.HasStyleID and (lStyle.StyleID = AStyleID) then
      Exit(lStyle);
end;

function TDSciVisualStyleGroup.EnsureStyle(const AName: string;
  AKind: TDSciVisualStyleKind): TDSciVisualStyleData;
begin
  Result := FindStyle(AName, AKind);
  if Result <> nil then
    Exit;

  Result := CreateStyleData(AKind);
  Result.Name := AName;
  FStyles.Add(Result);
end;

{ TDSciVisualStyleModel }

constructor TDSciVisualStyleModel.Create;
begin
  inherited Create;
  FGroups := TObjectList<TDSciVisualStyleGroup>.Create(True);
end;

destructor TDSciVisualStyleModel.Destroy;
begin
  FGroups.Free;
  inherited Destroy;
end;

procedure TDSciVisualStyleModel.Clear;
begin
  FGroups.Clear;
end;

procedure TDSciVisualStyleModel.Assign(ASource: TDSciVisualStyleModel);
var
  lGroup: TDSciVisualStyleGroup;
  lNewGroup: TDSciVisualStyleGroup;
begin
  Clear;
  if ASource = nil then
    Exit;

  for lGroup in ASource.Groups do
  begin
    lNewGroup := TDSciVisualStyleGroup.Create;
    lNewGroup.Assign(lGroup);
    FGroups.Add(lNewGroup);
  end;
end;

function TDSciVisualStyleModel.Clone: TDSciVisualStyleModel;
begin
  Result := TDSciVisualStyleModel.Create;
  Result.Assign(Self);
end;

function TDSciVisualStyleModel.FindGroup(const AName: string): TDSciVisualStyleGroup;
var
  lGroup: TDSciVisualStyleGroup;
begin
  Result := nil;
  for lGroup in FGroups do
    if SameText(lGroup.Name, AName) then
      Exit(lGroup);
end;

function TDSciVisualStyleModel.EnsureGroup(const AName: string): TDSciVisualStyleGroup;
begin
  Result := FindGroup(AName);
  if Result <> nil then
    Exit;

  Result := TDSciVisualStyleGroup.Create;
  Result.Name := AName;
  FGroups.Add(Result);
end;

function FindMatchingStyle(AGroup: TDSciVisualStyleGroup;
  AStyle: TDSciVisualStyleData): TDSciVisualStyleData;
begin
  Result := nil;
  if (AGroup = nil) or (AStyle = nil) then
    Exit;

  if AStyle.HasStyleID then
  begin
    Result := AGroup.FindStyleByID(AStyle.StyleID, AStyle.Kind);
    if (Result = nil) and (AStyle.Kind = dvskGlobal) then
      Result := AGroup.FindStyleByID(AStyle.StyleID, dvskLexer)
    else if (Result = nil) and (AStyle.Kind = dvskLexer) then
      Result := AGroup.FindStyleByID(AStyle.StyleID, dvskGlobal);
  end;

  if Result = nil then
  begin
    Result := AGroup.FindStyle(AStyle.Name, AStyle.Kind);
    if (Result = nil) and (AStyle.Kind = dvskGlobal) then
      Result := AGroup.FindStyle(AStyle.Name, dvskLexer)
    else if (Result = nil) and (AStyle.Kind = dvskLexer) then
      Result := AGroup.FindStyle(AStyle.Name, dvskGlobal);
  end;
end;

procedure PreserveStyleMetadata(ATarget, ASource: TDSciVisualStyleData);
begin
  if (ATarget = nil) or (ASource = nil) then
    Exit;

  if ASource.HasStyleID and not ATarget.HasStyleID then
  begin
    ATarget.StyleID := ASource.StyleID;
    ATarget.HasStyleID := True;
  end;
  if ASource.KeywordClass <> '' then
    ATarget.KeywordClass := ASource.KeywordClass;
  if ASource.KeywordsText <> '' then
    ATarget.KeywordsText := ASource.KeywordsText;
  if ASource.HasKeywordsID then
  begin
    ATarget.KeywordsID := ASource.KeywordsID;
    ATarget.HasKeywordsID := True;
  end;
  if ASource.HasEOLFill then
  begin
    ATarget.EOLFill := ASource.EOLFill;
    ATarget.HasEOLFill := True;
  end;
end;

procedure PreserveGroupMetadata(ATarget, ASource: TDSciVisualStyleGroup);
begin
  if (ATarget = nil) or (ASource = nil) then
    Exit;

  if ATarget.Description = '' then
    ATarget.Description := ASource.Description;
  if ASource.Extensions <> '' then
    ATarget.Extensions := ASource.Extensions;
  if ASource.HasLexerID then
  begin
    ATarget.LexerID := ASource.LexerID;
    ATarget.HasLexerID := True;
  end;
end;

{ TDSciVisualConfig }

constructor TDSciVisualConfig.Create;
begin
  inherited Create;
  FStyleOverrides := TDSciVisualStyleModel.Create;
  ResetDefaults;
end;

destructor TDSciVisualConfig.Destroy;
begin
  FStyleOverrides.Free;
  inherited Destroy;
end;

procedure TDSciVisualConfig.ResetDefaults;
begin
  FThemeName := '';
  FHighlightColor := RGB($00, $FF, $00);
  FHighlightAlpha := $60;
  FHighlightOutlineAlpha := $FF;
  FBackSpaceUnIndents := False;
  FIndentationGuides := scivNONE;
  FWhiteSpaceStyle := scwsINVISIBLE;
  FWhiteSpaceSize := 1;
  FUpperLineSpacing := 0;
  FLowerLineSpacing := 0;
  FFileSizeLimit := 512 * 1024 * 1024; // 512 MB default; 0 = no limit
  FLineNumbering := True;
  FLineNumberWidthMode := lnwmDynamic;
  FLineNumberPaddingLeft := 4;
  FLineNumberPaddingRight := 4;
  FTextPaddingLeft := 1;
  FTextPaddingRight := 1;
  FBookmarkMarginVisible := True;
  FFoldMarginVisible := True;
  FFoldMarkerStyle := fmsBoxTree;
  FLineWrapping := True;
  FWrapMode := scwWORD;
  FWrapVisualFlags := [];
  FWrapVisualFlagsLocation := [];
  FSmartHighlightStyle := scisSTRAIGHT_BOX;
  FSmartHighlightFillAlpha := $60;
  FSmartHighlightOutlineAlpha := $FF;
  FSelectFullLine := False;
  FUseSelectionForeColor := False;
  FSelectionForeColor := $00FFFF00;
  FSelectionAlpha := 256;
  FCaretBeyondLineEndings := False;
  FWrapCursorAtLineStart := True;
  FCaretSticky := sccsOFF;
  FMultiPaste := False;
  FPasteConvertEndings := True;
  FPrintMagnification := 0;
  FFoldingLines := False;
  FFoldingText := '';
  FFoldDisplayTextStyle := scfdtsHIDDEN;
  FTechnology := sctDIRECT_WRITE_RETAIN;
  FFontLocale := '';
  FFontQuality := scfqQUALITY_LCD_OPTIMIZED;
  FSearchSync := False;
  FTabWidth := 4;
  FLogEnabled := False;
  FLogLevel := 1; // 0=None, 1=Error, 2=Info, 3=Debug
  FLogOutput := 1; // 0=OutputDebugString, 1=File
  FStyleOverrides.Clear;
  FShowStatusBar := False;
  FStatusPanelFileVisible := False;
  FStatusPanelPosVisible := True;
  FStatusPanelLexerVisible := True;
  FStatusPanelEncodingVisible := False;
  FStatusPanelThemeVisible := False;
  FStatusPanelLoadVisible := False;
end;

procedure TDSciVisualConfig.Assign(ASource: TDSciVisualConfig);
begin
  if ASource = nil then
    Exit;

  FThemeName := ASource.ThemeName;
  FHighlightColor := ASource.HighlightColor;
  FHighlightAlpha := ASource.HighlightAlpha;
  FHighlightOutlineAlpha := ASource.HighlightOutlineAlpha;
  FBackSpaceUnIndents := ASource.BackSpaceUnIndents;
  FIndentationGuides := ASource.IndentationGuides;
  FWhiteSpaceStyle := ASource.WhiteSpaceStyle;
  FWhiteSpaceSize := ASource.WhiteSpaceSize;
  FUpperLineSpacing := ASource.UpperLineSpacing;
  FLowerLineSpacing := ASource.LowerLineSpacing;
  FFileSizeLimit := ASource.FileSizeLimit;
  FLineNumbering := ASource.LineNumbering;
  FLineNumberWidthMode := ASource.LineNumberWidthMode;
  FLineNumberPaddingLeft := ASource.LineNumberPaddingLeft;
  FLineNumberPaddingRight := ASource.LineNumberPaddingRight;
  FTextPaddingLeft := ASource.TextPaddingLeft;
  FTextPaddingRight := ASource.TextPaddingRight;
  FBookmarkMarginVisible := ASource.BookmarkMarginVisible;
  FFoldMarginVisible := ASource.FFoldMarginVisible;
  FFoldMarkerStyle := ASource.FFoldMarkerStyle;
  FLineWrapping := ASource.LineWrapping;
  FWrapMode := ASource.WrapMode;
  FWrapVisualFlags := ASource.WrapVisualFlags;
  FWrapVisualFlagsLocation := ASource.WrapVisualFlagsLocation;
  FSmartHighlightStyle := ASource.SmartHighlightStyle;
  FSmartHighlightFillAlpha := ASource.SmartHighlightFillAlpha;
  FSmartHighlightOutlineAlpha := ASource.SmartHighlightOutlineAlpha;
  FSelectFullLine := ASource.SelectFullLine;
  FUseSelectionForeColor := ASource.UseSelectionForeColor;
  FSelectionForeColor := ASource.SelectionForeColor;
  FSelectionAlpha := ASource.SelectionAlpha;
  FCaretBeyondLineEndings := ASource.CaretBeyondLineEndings;
  FWrapCursorAtLineStart := ASource.WrapCursorAtLineStart;
  FCaretSticky := ASource.CaretSticky;
  FMultiPaste := ASource.MultiPaste;
  FPasteConvertEndings := ASource.PasteConvertEndings;
  FPrintMagnification := ASource.PrintMagnification;
  FFoldingLines := ASource.FoldingLines;
  FFoldingText := ASource.FoldingText;
  FFoldDisplayTextStyle := ASource.FoldDisplayTextStyle;
  FTechnology := ASource.Technology;
  FFontLocale := ASource.FontLocale;
  FFontQuality := ASource.FontQuality;
  FSearchSync := ASource.SearchSync;
  FTabWidth := ASource.TabWidth;
  FLogEnabled := ASource.LogEnabled;
  FLogLevel := ASource.LogLevel;
  FLogOutput := ASource.LogOutput;
  FShowStatusBar := ASource.ShowStatusBar;
  FStatusPanelFileVisible := ASource.StatusPanelFileVisible;
  FStatusPanelPosVisible := ASource.StatusPanelPosVisible;
  FStatusPanelLexerVisible := ASource.StatusPanelLexerVisible;
  FStatusPanelEncodingVisible := ASource.StatusPanelEncodingVisible;
  FStatusPanelThemeVisible := ASource.StatusPanelThemeVisible;
  FStatusPanelLoadVisible := ASource.StatusPanelLoadVisible;
  FStyleOverrides.Assign(ASource.StyleOverrides);
end;

function TDSciVisualConfig.GetLineWrapping: Boolean;
begin
  Result := FLineWrapping;
end;

procedure TDSciVisualConfig.SetLineWrapping(AValue: Boolean);
begin
  FLineWrapping := AValue;
  if AValue then
  begin
    if FWrapMode = scwNONE then
      FWrapMode := scwWORD;
  end
  else
    FWrapMode := scwNONE;
end;

procedure TDSciVisualConfig.SetWrapMode(AValue: TDSciWrap);
begin
  FWrapMode := AValue;
  FLineWrapping := AValue <> scwNONE;
end;

function TDSciVisualConfig.Clone: TDSciVisualConfig;
begin
  Result := TDSciVisualConfig.Create;
  Result.Assign(Self);
end;

function TDSciVisualConfig.HasStyleOverrides: Boolean;
begin
  Result := FStyleOverrides.Groups.Count > 0;
end;

function TDSciVisualConfig.FindStyleOverride(const ALanguageName, AStyleName: string;
  AKind: TDSciVisualStyleKind): TDSciVisualStyleData;
var
  lGroup: TDSciVisualStyleGroup;
begin
  lGroup := FStyleOverrides.FindGroup(ALanguageName);
  if lGroup = nil then
    Exit(nil);
  Result := lGroup.FindStyle(AStyleName, AKind);
end;

function TDSciVisualConfig.EnsureStyleOverride(const ALanguageName, AStyleName: string;
  AKind: TDSciVisualStyleKind): TDSciVisualStyleData;
var
  lGroup: TDSciVisualStyleGroup;
begin
  lGroup := FStyleOverrides.EnsureGroup(ALanguageName);
  Result := lGroup.EnsureStyle(AStyleName, AKind);
end;

function TDSciVisualConfig.ResolveLanguageByFileName(const AFileName: string): string;
var
  lGroup: TDSciVisualStyleGroup;
begin
  Result := '';
  for lGroup in FStyleOverrides.Groups do
  begin
    if SameText(lGroup.Name, 'default') then
      Continue;
    if MatchesExtensions(lGroup.Extensions, AFileName) then
      Exit(lGroup.Name);
  end;
end;

function TDSciVisualConfig.BuildHandledExtensions: string;
var
  LGroup: TDSciVisualStyleGroup;
  LTokens, LUnique: TStringList;
  LToken: string;
  I: Integer;
begin
  LUnique := TStringList.Create;
  try
    LUnique.Sorted := True;
    LUnique.Duplicates := dupIgnore;
    LUnique.CaseSensitive := False;

    LTokens := TStringList.Create;
    try
      LTokens.StrictDelimiter := True;
      LTokens.Delimiter := ' ';
      for LGroup in FStyleOverrides.Groups do
      begin
        if Trim(LGroup.Extensions) = '' then
          Continue;
        LTokens.DelimitedText := StringReplace(
          Trim(LGroup.Extensions), #9, ' ', [rfReplaceAll]);
        for LToken in LTokens do
        begin
          if (LToken = '') or (LToken = '*') then
            Continue;
          LUnique.Add(LowerCase(LToken));
        end;
      end;
    finally
      LTokens.Free;
    end;

    Result := '';
    for I := 0 to LUnique.Count - 1 do
      Result := Result + '.' + LUnique[I] + ';';
  finally
    LUnique.Free;
  end;
end;

procedure TDSciVisualConfig.ReplaceStyleModel(ASource: TDSciVisualStyleModel;
  APreserveMetadata: Boolean);
var
  lNewGroup: TDSciVisualStyleGroup;
  lNewModel: TDSciVisualStyleModel;
  lNewStyle: TDSciVisualStyleData;
  lOldGroup: TDSciVisualStyleGroup;
  lOldStyle: TDSciVisualStyleData;
begin
  if ASource = nil then
  begin
    FStyleOverrides.Clear;
    Exit;
  end;

  lNewModel := ASource.Clone;
  try
    if APreserveMetadata then
      for lOldGroup in FStyleOverrides.Groups do
      begin
        lNewGroup := lNewModel.FindGroup(lOldGroup.Name);
        if lNewGroup = nil then
        begin
          lNewGroup := TDSciVisualStyleGroup.Create;
          lNewGroup.Assign(lOldGroup);
          lNewModel.Groups.Add(lNewGroup);
          Continue;
        end;

        PreserveGroupMetadata(lNewGroup, lOldGroup);
        for lOldStyle in lOldGroup.Styles do
        begin
          lNewStyle := FindMatchingStyle(lNewGroup, lOldStyle);
          if lNewStyle <> nil then
            PreserveStyleMetadata(lNewStyle, lOldStyle)
          else
            lNewGroup.Styles.Add(lOldStyle.Clone);
        end;
      end;

    FStyleOverrides.Assign(lNewModel);
  finally
    lNewModel.Free;
  end;
end;

procedure TDSciVisualConfig.LoadFromFile(const AFileName: string);
var
  lConfig: TDSciVisualConfig;
  lStep: string;
begin
  lStep := 'create temp config';
  lConfig := TDSciVisualConfig.Create;
  try
    try
      lStep := 'parse xml';
      LoadVisualConfigData(lConfig, AFileName);
      lStep := 'commit parsed config';
      Assign(lConfig);
    except
      on E: Exception do
        raise Exception.CreateFmt('TDSciVisualConfig.LoadFromFile %s failed: %s - %s',
          [lStep, E.ClassName, E.Message]);
    end;
  finally
    lConfig.Free;
  end;
end;

procedure TDSciVisualConfig.LoadFromStream(AStream: TStream);
var
  lConfig: TDSciVisualConfig;
  lStep: string;
begin
  lStep := 'create temp config';
  lConfig := TDSciVisualConfig.Create;
  try
    try
      lStep := 'parse xml stream';
      LoadVisualConfigDataFromStream(lConfig, AStream);
      lStep := 'commit parsed config';
      Assign(lConfig);
    except
      on E: Exception do
        raise Exception.CreateFmt('TDSciVisualConfig.LoadFromStream %s failed: %s - %s',
          [lStep, E.ClassName, E.Message]);
    end;
  finally
    lConfig.Free;
  end;
end;

procedure TDSciVisualConfig.SaveToFile(const AFileName: string);
var
  lDocument: IXMLDocument;
  lEditorNode: IXMLNode;
  lGroup: TDSciVisualStyleGroup;
  lHighlightNode: IXMLNode;
  lLineNode: IXMLNode;
  lRoot: IXMLNode;
  lSelectionNode: IXMLNode;
  lRenderingNode: IXMLNode;
  lSearchSyncNode: IXMLNode;
  lStatusBarNode: IXMLNode;
  lSmartHighlightNode: IXMLNode;
  lStyleNode: IXMLNode;
  lStylesNode: IXMLNode;
  lStyle: TDSciVisualStyleData;
  lTabNode: IXMLNode;
  lThemeNode: IXMLNode;
  lWordStylesNode: IXMLNode;
begin
  ForceDirectories(ExtractFileDir(AFileName));

  lDocument := CreateXmlDocument;
  lDocument.Active := True;
  lDocument.Encoding := 'UTF-8';
  lDocument.Options := [doNodeAutoIndent];

  lRoot := lDocument.AddChild('Config');

  if FThemeName <> '' then
  begin
    lThemeNode := lRoot.AddChild('Theme');
    lThemeNode.Attributes['Name'] := FThemeName;
  end;

  lHighlightNode := lRoot.AddChild('Highlight');
  lHighlightNode.Attributes['Foreground'] := ColorToHex(FHighlightColor);
  lHighlightNode.Attributes['ForegroundAlpha'] := IntToHex(FHighlightAlpha, 2);
  lHighlightNode.Attributes['OutlineAlpha'] := IntToHex(FHighlightOutlineAlpha, 2);

  lEditorNode := lRoot.AddChild('Editor');
  lEditorNode.Attributes['BackSpaceUnIndents'] := YesNo(FBackSpaceUnIndents);
  lEditorNode.Attributes['IndentationGuides'] := TDSciIndentViewToInt(FIndentationGuides);
  lEditorNode.Attributes['WhiteSpaceStyle'] := TDSciWhiteSpaceToInt(FWhiteSpaceStyle);
  lEditorNode.Attributes['WhiteSpaceSize'] := FWhiteSpaceSize;
  lEditorNode.Attributes['UpperLineSpacing'] := FUpperLineSpacing;
  lEditorNode.Attributes['LowerLineSpacing'] := FLowerLineSpacing;

  lRoot.AddChild('FileSizeLimit').NodeValue := FormatHexInt(FFileSizeLimit);

  lLineNode := lRoot.AddChild('LineNumbering');
  lLineNode.Attributes['Enabled'] := YesNo(FLineNumbering);
  lLineNode.Attributes['WidthMode'] := Ord(FLineNumberWidthMode);
  lLineNode.Attributes['PaddingLeft'] := FLineNumberPaddingLeft;
  lLineNode.Attributes['PaddingRight'] := FLineNumberPaddingRight;

  lLineNode := lRoot.AddChild('TextPadding');
  lLineNode.Attributes['Left'] := FTextPaddingLeft;
  lLineNode.Attributes['Right'] := FTextPaddingRight;

  lLineNode := lRoot.AddChild('BookmarkMargin');
  lLineNode.Attributes['Enabled'] := YesNo(FBookmarkMarginVisible);

  lLineNode := lRoot.AddChild('FoldMargin');
  lLineNode.Attributes['Enabled'] := YesNo(FFoldMarginVisible);
  lLineNode.Attributes['MarkerStyle'] := Ord(FFoldMarkerStyle);

  lLineNode := lRoot.AddChild('LineWrapping');
  lLineNode.Attributes['Enabled'] := YesNo(FWrapMode <> scwNONE);
  lLineNode.Attributes['Mode'] := TDSciWrapToInt(FWrapMode);
  lLineNode.Attributes['VisualFlags'] := FormatSetInt(TDSciWrapVisualFlagSetToInt(FWrapVisualFlags));
  lLineNode.Attributes['VisualFlagsLocation'] := FormatSetInt(
    TDSciWrapVisualLocationSetToInt(FWrapVisualFlagsLocation));

  lTabNode := lRoot.AddChild('Tabulator');
  lTabNode.Attributes['Width'] := FTabWidth;

  lSearchSyncNode := lRoot.AddChild('SearchSync');
  lSearchSyncNode.Attributes['Enabled'] := YesNo(FSearchSync);

  lStatusBarNode := lRoot.AddChild('StatusBar');
  lStatusBarNode.Attributes['Visible'] := YesNo(FShowStatusBar);
  lStatusBarNode.Attributes['PanelFile'] := YesNo(FStatusPanelFileVisible);
  lStatusBarNode.Attributes['PanelPos'] := YesNo(FStatusPanelPosVisible);
  lStatusBarNode.Attributes['PanelLexer'] := YesNo(FStatusPanelLexerVisible);
  lStatusBarNode.Attributes['PanelEncoding'] := YesNo(FStatusPanelEncodingVisible);
  lStatusBarNode.Attributes['PanelTheme'] := YesNo(FStatusPanelThemeVisible);
  lStatusBarNode.Attributes['PanelLoad'] := YesNo(FStatusPanelLoadVisible);

  lSelectionNode := lRoot.AddChild('Selection');
  lSelectionNode.Attributes['FullLine'] := YesNo(FSelectFullLine);
  lSelectionNode.Attributes['UseForeColor'] := YesNo(FUseSelectionForeColor);
  lSelectionNode.Attributes['ForeColor'] := ColorToHex(FSelectionForeColor);
  lSelectionNode.Attributes['Alpha'] := FSelectionAlpha;

  lRenderingNode := lRoot.AddChild('Rendering');
  lRenderingNode.Attributes['Technology'] := TDSciTechnologyToInt(FTechnology);
  lRenderingNode.Attributes['FontLocale'] := FFontLocale;
  lRenderingNode.Attributes['FontQuality'] := TDSciFontQualityToInt(FFontQuality);

  lSmartHighlightNode := lRoot.AddChild('SmartHighlighting');
  lSmartHighlightNode.Attributes['Style'] := TDSciIndicatorStyleToInt(FSmartHighlightStyle);
  lSmartHighlightNode.Attributes['FillAlpha'] := Integer(FSmartHighlightFillAlpha);
  lSmartHighlightNode.Attributes['OutlineAlpha'] := Integer(FSmartHighlightOutlineAlpha);

  lLineNode := lRoot.AddChild('Caret');
  lLineNode.Attributes['BeyondLineEndings'] := YesNo(FCaretBeyondLineEndings);
  lLineNode.Attributes['WrapAtLineStart'] := YesNo(FWrapCursorAtLineStart);
  lLineNode.Attributes['Sticky'] := TDSciCaretStickyToInt(FCaretSticky);

  lLineNode := lRoot.AddChild('CopyPaste');
  lLineNode.Attributes['MultiPaste'] := YesNo(FMultiPaste);
  lLineNode.Attributes['ConvertEolOnPaste'] := YesNo(FPasteConvertEndings);

  lLineNode := lRoot.AddChild('Printing');
  lLineNode.Attributes['Magnification'] := FPrintMagnification;

  lLineNode := lRoot.AddChild('CodeFolding');
  lLineNode.Attributes['Lines'] := YesNo(FFoldingLines);
  lLineNode.Attributes['Text'] := FFoldingText;
  lLineNode.Attributes['TextStyle'] := TDSciFoldDisplayTextStyleToInt(FFoldDisplayTextStyle);

  lLineNode := lRoot.AddChild('Logging');
  lLineNode.Attributes['Enabled'] := YesNo(FLogEnabled);
  lLineNode.Attributes['Level'] := FLogLevel;
  lLineNode.Attributes['Output'] := FLogOutput;

  lStylesNode := lRoot.AddChild('Styles');
  for lGroup in FStyleOverrides.Groups do
  begin
    lStyleNode := lStylesNode.AddChild('Style');
    lStyleNode.Attributes['name'] := lGroup.Name;
    if lGroup.Extensions <> '' then
      lStyleNode.Attributes['ext'] := lGroup.Extensions;
    if lGroup.Description <> '' then
      lStyleNode.Attributes['desc'] := lGroup.Description;
    if lGroup.HasLexerID then
      lStyleNode.Attributes['lexer'] := lGroup.LexerID;

    lWordStylesNode := lStyleNode.AddChild('WordStyles');
    for lStyle in lGroup.Styles do
      WriteStyleNode(lWordStylesNode, lStyle, 'WordStyle', True);
  end;

  lDocument.SaveToFile(AFileName);
end;

{ TDSciVisualCatalog }

constructor TDSciVisualCatalog.Create;
begin
  inherited Create;
  FModel := TDSciVisualStyleModel.Create;
end;

destructor TDSciVisualCatalog.Destroy;
begin
  FModel.Free;
  inherited Destroy;
end;

procedure TDSciVisualCatalog.LoadFromConfig(AConfig: TDSciVisualConfig);
begin
  FThemeName := '';
  FModel.Clear;

  if AConfig = nil then
    Exit;

  FThemeName := Trim(AConfig.ThemeName);
  FModel.Assign(AConfig.StyleOverrides);
end;

procedure TDSciVisualCatalog.PopulateLanguageNames(AItems: TStrings);
var
  lGroup: TDSciVisualStyleGroup;
  lItems: TDSciVisualSortStringList;
begin
  AItems.BeginUpdate;
  try
    AItems.Clear;
    lItems := TDSciVisualSortStringList.Create;
    try
      lItems.Sorted := True;
      for lGroup in FModel.Groups do
        lItems.Add(lGroup.Name);
      AItems.AddStrings(lItems);
    finally
      lItems.Free;
    end;
  finally
    AItems.EndUpdate;
  end;
end;

procedure TDSciVisualCatalog.PopulateThemeNames(AItems: TStrings);
begin
  AItems.BeginUpdate;
  try
    AItems.Clear;
    if FThemeName <> '' then
      AItems.Add(FThemeName)
    else
      AItems.Add('(Embedded defaults)');
  finally
    AItems.EndUpdate;
  end;
end;

function TDSciVisualCatalog.FindLanguage(const AName: string): TDSciVisualStyleGroup;
begin
  Result := FModel.FindGroup(AName);
end;

function TDSciVisualCatalog.BuildEffectiveStyle(const ALanguageName,
  AStyleName: string; AKind: TDSciVisualStyleKind): TDSciVisualStyleData;
var
  lDefaultGroup: TDSciVisualStyleGroup;
  lDefaultStyle: TDSciVisualStyleData;
  lGroup: TDSciVisualStyleGroup;
  lStyle: TDSciVisualStyleData;
begin
  Result := TDSciVisualStyleData.Create;
  Result.Kind := AKind;
  Result.Name := AStyleName;

  lDefaultGroup := FModel.FindGroup('default');
  if lDefaultGroup <> nil then
  begin
    lDefaultStyle := lDefaultGroup.FindStyle('Default Style', dvskGlobal);
    if lDefaultStyle <> nil then
      OverlayStyle(Result, lDefaultStyle);

    lDefaultStyle := lDefaultGroup.FindStyle('DEFAULT', dvskLexer);
    if lDefaultStyle <> nil then
      OverlayStyle(Result, lDefaultStyle);
  end;

  lGroup := FindLanguage(ALanguageName);
  if lGroup <> nil then
  begin
    if not SameText(ALanguageName, 'default') then
    begin
      lDefaultStyle := lGroup.FindStyle('DEFAULT', dvskLexer);
      if lDefaultStyle <> nil then
        OverlayStyle(Result, lDefaultStyle);
    end;

    lStyle := lGroup.FindStyle(AStyleName, AKind);
    if lStyle <> nil then
      OverlayStyle(Result, lStyle);
  end;
end;

end.
