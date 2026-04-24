unit uSciConfGenImport;

interface

uses
  System.SysUtils,
  DScintillaVisualConfig;

procedure BuildConfigFromLegacySettings(const ASettingsDirectory,
  ASeedConfigFileName, AThemeName: string; const AConfig: TDSciVisualConfig);

implementation

uses
  System.Classes, System.IOUtils, System.Math, System.StrUtils, System.Variants,
  System.Win.ComObj,
  Vcl.Graphics,
  Winapi.ActiveX, Winapi.Windows,
  Xml.XMLDoc, Xml.XMLIntf, Xml.xmldom, Xml.omnixmldom;

type
  TDSciLegacyStyleData = class
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

function ParseYesNo(const AValue: string; ADefault: Boolean): Boolean;
begin
  if SameText(Trim(AValue), 'yes') then
    Exit(True);
  if SameText(Trim(AValue), 'no') then
    Exit(False);
  Result := ADefault;
end;

function ParseHexColor(const AValue: string; out AColor: TColor): Boolean;
var
  lColorValue: Integer;
  lValue: string;
begin
  Result := False;
  lValue := Trim(AValue);
  if lValue = '' then
    Exit;

  if StartsText('0x', lValue) then
    lValue := Copy(lValue, 3, MaxInt);
  if lValue.StartsWith('#') then
    Delete(lValue, 1, 1);

  if not TryStrToInt('$' + lValue, lColorValue) then
    Exit;

  AColor := RGB((lColorValue shr 16) and $FF, (lColorValue shr 8) and $FF, lColorValue and $FF);
  Result := True;
end;

function FindKeywordNode(const ANode: IXMLNode): IXMLNode;
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
    if SameText(lChild.NodeName, 'Keywords') then
      Exit(lChild);
  end;
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

function CreateVisualStyle(const ASource: TDSciLegacyStyleData): TDSciVisualStyleData;
begin
  Result := TDSciVisualStyleData.Create;
  Result.Kind := ASource.Kind;
  Result.Name := ASource.Name;
  Result.StyleID := ASource.StyleID;
  Result.HasStyleID := ASource.HasStyleID;
  Result.KeywordsID := ASource.KeywordsID;
  Result.HasKeywordsID := ASource.HasKeywordsID;
  Result.HasForeColor := ASource.HasForeColor;
  Result.ForeColor := ASource.ForeColor;
  Result.HasBackColor := ASource.HasBackColor;
  Result.BackColor := ASource.BackColor;
  Result.FontName := ASource.FontName;
  Result.HasFontStyle := ASource.HasFontStyle;
  Result.FontStyle := ASource.FontStyle;
  Result.HasFontSize := ASource.HasFontSize;
  Result.FontSize := ASource.FontSize;
  Result.EOLFill := ASource.EOLFill;
  Result.HasEOLFill := ASource.HasEOLFill;
  Result.KeywordClass := ASource.KeywordClass;
  Result.KeywordsText := ASource.KeywordsText;
end;

function ParseStyleNode(const ANode: IXMLNode; AKind: TDSciVisualStyleKind): TDSciLegacyStyleData;
var
  lKeywordNode: IXMLNode;
begin
  Result := TDSciLegacyStyleData.Create;
  Result.Kind := AKind;
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

procedure OverlayStyle(ATarget, AOverlay: TDSciVisualStyleData);
begin
  if (ATarget = nil) or (AOverlay = nil) then
    Exit;

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

procedure MergeLanguageMetadata(ATarget, AMetadata: TDSciVisualStyleModel);
var
  lMetadataGroup: TDSciVisualStyleGroup;
  lTargetGroup: TDSciVisualStyleGroup;
  lTargetName: string;
begin
  if (ATarget = nil) or (AMetadata = nil) then
    Exit;

  for lMetadataGroup in AMetadata.Groups do
  begin
    if SameText(lMetadataGroup.Name, 'normal') then
      lTargetName := 'default'
    else
      lTargetName := lMetadataGroup.Name;

    lTargetGroup := ATarget.FindGroup(lTargetName);
    if lTargetGroup = nil then
      Continue;

    if lMetadataGroup.Description <> '' then
      lTargetGroup.Description := lMetadataGroup.Description;
    if lMetadataGroup.Extensions <> '' then
      lTargetGroup.Extensions := lMetadataGroup.Extensions;
  end;
end;

function ResolveThemeFileName(const ASettingsDirectory, AThemeNameOrFileName: string): string;
var
  lThemeFileName: string;
  lThemesDirectory: string;
begin
  Result := '';
  if Trim(AThemeNameOrFileName) = '' then
    Exit;

  if FileExists(AThemeNameOrFileName) then
    Exit(ExpandFileName(AThemeNameOrFileName));

  lThemeFileName := Trim(AThemeNameOrFileName);
  if ExtractFileExt(lThemeFileName) = '' then
    lThemeFileName := lThemeFileName + '.xml';

  lThemesDirectory := IncludeTrailingPathDelimiter(TPath.Combine(ASettingsDirectory, 'themes'));
  Result := TPath.Combine(lThemesDirectory, lThemeFileName);
  if FileExists(Result) then
    Exit(ExpandFileName(Result));

  raise EFileNotFoundException.CreateFmt('Theme file not found: %s', [AThemeNameOrFileName]);
end;

function LoadStyleModel(const AFileName: string): TDSciVisualStyleModel;
var
  lGlobalNode: IXMLNode;
  lGroup: TDSciVisualStyleGroup;
  lIndex: Integer;
  lInit: HRESULT;
  lLexerNode: IXMLNode;
  lLexerStylesNode: IXMLNode;
  lNode: IXMLNode;
  lRoot: IXMLNode;
  lStyleData: TDSciLegacyStyleData;
  lStyleIndex: Integer;
  lXml: IXMLDocument;
begin
  if not FileExists(AFileName) then
    raise EFileNotFoundException.CreateFmt('Settings file not found: %s', [AFileName]);

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
            if SameText(lNode.NodeName, 'WordsStyle') then
            begin
              lStyleData := ParseStyleNode(lNode, dvskLexer);
              try
                lGroup.Styles.Add(CreateVisualStyle(lStyleData));
              finally
                lStyleData.Free;
              end;
            end;
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
          if SameText(lNode.NodeName, 'WidgetStyle') then
          begin
            lStyleData := ParseStyleNode(lNode, dvskGlobal);
            try
              lGroup.Styles.Add(CreateVisualStyle(lStyleData));
            finally
              lStyleData.Free;
            end;
          end;
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

function LoadLanguageMetadata(const AFileName: string): TDSciVisualStyleModel;
var
  lGroup: TDSciVisualStyleGroup;
  lIndex: Integer;
  lInit: HRESULT;
  lLanguagesNode: IXMLNode;
  lLanguageNode: IXMLNode;
  lRoot: IXMLNode;
  lXml: IXMLDocument;
begin
  if not FileExists(AFileName) then
    raise EFileNotFoundException.CreateFmt('Settings file not found: %s', [AFileName]);

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
      lLanguagesNode := FindChildNode(lRoot, 'Languages');
      if lLanguagesNode <> nil then
        for lIndex := 0 to lLanguagesNode.ChildNodes.Count - 1 do
        begin
          lLanguageNode := lLanguagesNode.ChildNodes[lIndex];
          if not IsElementNode(lLanguageNode) then
            Continue;
          if not SameText(lLanguageNode.NodeName, 'Language') then
            Continue;

          lGroup := Result.EnsureGroup(GetNodeAttribute(lLanguageNode, 'name'));
          lGroup.Extensions := Trim(GetNodeAttribute(lLanguageNode, 'ext'));
        end;
    except
      Result.Free;
      raise;
    end;
  finally
    lLanguageNode := nil;
    lLanguagesNode := nil;
    lRoot := nil;
    lXml := nil;
    if (lInit = S_OK) or (lInit = S_FALSE) then
      CoUninitialize;
  end;
end;

function KeywordClassToIndex(const AKeywordClass: string; ADefaultIndex: Integer): Integer;
var
  lNumber: Integer;
begin
  if StartsText('instre', AKeywordClass) and
     TryStrToInt(Copy(AKeywordClass, Length('instre') + 1, MaxInt), lNumber) then
    Exit(Max(0, lNumber - 1));

  if StartsText('type', AKeywordClass) and
     TryStrToInt(Copy(AKeywordClass, Length('type') + 1, MaxInt), lNumber) then
    Exit(lNumber + 1);

  Result := ADefaultIndex;
end;

procedure MergeLanguageKeywordContent(AModel: TDSciVisualStyleModel; const AFileName: string);
var
  lChildIndex: Integer;
  lGroup: TDSciVisualStyleGroup;
  lIndex: Integer;
  lInit: HRESULT;
  lKeywordIndex: Integer;
  lLanguageName: string;
  lLanguageNode: IXMLNode;
  lLanguagesNode: IXMLNode;
  lNode: IXMLNode;
  lRoot: IXMLNode;
  lStyle: TDSciVisualStyleData;
  lXml: IXMLDocument;
begin
  if (AModel = nil) or not FileExists(AFileName) then
    Exit;

  lInit := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
  if Failed(lInit) and (lInit <> RPC_E_CHANGED_MODE) then
    CheckHRESULT(lInit);
  try
    lXml := CreateXmlDocument;
    lXml.LoadFromFile(AFileName);
    lXml.Active := True;

    lRoot := lXml.DocumentElement;
    lLanguagesNode := FindChildNode(lRoot, 'Languages');
    if lLanguagesNode = nil then
      Exit;

    for lIndex := 0 to lLanguagesNode.ChildNodes.Count - 1 do
    begin
      lLanguageNode := lLanguagesNode.ChildNodes[lIndex];
      if not IsElementNode(lLanguageNode) or
         not SameText(lLanguageNode.NodeName, 'Language') then
        Continue;

      lLanguageName := GetNodeAttribute(lLanguageNode, 'name');
      if SameText(lLanguageName, 'normal') then
        lLanguageName := 'default';

      lGroup := AModel.FindGroup(lLanguageName);
      if lGroup = nil then
        Continue;

      if lGroup.Extensions = '' then
        lGroup.Extensions := Trim(GetNodeAttribute(lLanguageNode, 'ext'));

      lKeywordIndex := 0;
      for lChildIndex := 0 to lLanguageNode.ChildNodes.Count - 1 do
      begin
        lNode := lLanguageNode.ChildNodes[lChildIndex];
        if not IsElementNode(lNode) or not SameText(lNode.NodeName, 'Keywords') then
          Continue;

        for lStyle in lGroup.Styles do
          if SameText(lStyle.KeywordClass, GetNodeAttribute(lNode, 'name')) then
          begin
            lStyle.KeywordsText := Trim(lNode.Text);
            if not StartsText('substyle', lStyle.KeywordClass) then
            begin
              lStyle.KeywordsID := KeywordClassToIndex(lStyle.KeywordClass, lKeywordIndex);
              lStyle.HasKeywordsID := True;
              lKeywordIndex := Max(lKeywordIndex, lStyle.KeywordsID + 1);
            end;
            Break;
          end;
      end;
    end;
  finally
    lNode := nil;
    lLanguageNode := nil;
    lLanguagesNode := nil;
    lRoot := nil;
    lXml := nil;
    if (lInit = S_OK) or (lInit = S_FALSE) then
      CoUninitialize;
  end;
end;

function LoadSeedConfig(const AFileName: string): TDSciVisualConfig;
var
  lColor: TColor;
  lFileSizeNode: IXMLNode;
  lGroup: TDSciVisualStyleGroup;
  lHighlightNode: IXMLNode;
  lInit: HRESULT;
  lNode: IXMLNode;
  lRoot: IXMLNode;
  lStep: string;
  lStyleNode: IXMLNode;
  lStylesNode: IXMLNode;
  lThemeNode: IXMLNode;
  lWordStylesNode: IXMLNode;
  lXml: IXMLDocument;
  lInt64Value: Int64;
  lValue: Integer;
  lIndex: Integer;
  lWordIndex: Integer;
  lStyle: TDSciLegacyStyleData;
begin
  Result := TDSciVisualConfig.Create;
  if not FileExists(AFileName) then
    Exit;

  lInit := RPC_E_CHANGED_MODE;
  try
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

      lStep := 'read root node';
      lRoot := lXml.DocumentElement;
      if lRoot = nil then
        Exit;

      lStep := 'read theme';
      lThemeNode := FindChildNode(lRoot, 'Theme');
      if lThemeNode <> nil then
        Result.ThemeName := Trim(GetNodeAttribute(lThemeNode, 'Name'));

      lStep := 'read highlight';
      lHighlightNode := FindChildNode(lRoot, 'Highlight');
      if lHighlightNode <> nil then
      begin
        if ParseHexColor(GetNodeAttribute(lHighlightNode, 'Foreground'), lColor) then
          Result.HighlightColor := lColor;
        if ParseOptionalInt('$' + GetNodeAttribute(lHighlightNode, 'ForegroundAlpha'),
            lValue) then
          Result.HighlightAlpha := Byte(EnsureRange(lValue, 0, 255));
        if ParseOptionalInt('$' + GetNodeAttribute(lHighlightNode, 'OutlineAlpha'),
            lValue) then
          Result.HighlightOutlineAlpha := Byte(EnsureRange(lValue, 0, 255));
      end;

      lStep := 'read file size limit';
      lFileSizeNode := FindChildNode(lRoot, 'FileSizeLimit');
      if (lFileSizeNode <> nil) and ParseOptionalInt64(Trim(lFileSizeNode.Text), lInt64Value) then
        Result.FileSizeLimit := Max(Int64(0), lInt64Value);

      lStep := 'read line numbering';
      lNode := FindChildNode(lRoot, 'LineNumbering');
      if lNode <> nil then
        Result.LineNumbering := ParseYesNo(GetNodeAttribute(lNode, 'Enabled'),
          Result.LineNumbering);

      lStep := 'read line wrapping';
      lNode := FindChildNode(lRoot, 'LineWrapping');
      if lNode <> nil then
        Result.LineWrapping := ParseYesNo(GetNodeAttribute(lNode, 'Enabled'),
          Result.LineWrapping);

      lStep := 'read tab settings';
      lNode := FindChildNode(lRoot, 'Tabulator');
      if (lNode <> nil) and ParseOptionalInt(GetNodeAttribute(lNode, 'Width'), lValue) then
        Result.TabWidth := Max(1, lValue);

      lStep := 'read search sync';
      lNode := FindChildNode(lRoot, 'SearchSync');
      if lNode <> nil then
        Result.SearchSync := ParseYesNo(GetNodeAttribute(lNode, 'Enabled'),
          Result.SearchSync);

      lStep := 'read style overrides';
      lStylesNode := FindChildNode(lRoot, 'Styles');
      if lStylesNode <> nil then
        for lIndex := 0 to lStylesNode.ChildNodes.Count - 1 do
        begin
          lStyleNode := lStylesNode.ChildNodes[lIndex];
          if not IsElementNode(lStyleNode) or
             not SameText(lStyleNode.NodeName, 'Style') then
            Continue;

          lGroup := Result.StyleOverrides.EnsureGroup(GetNodeAttribute(lStyleNode, 'name'));
          lGroup.Extensions := Trim(GetNodeAttribute(lStyleNode, 'ext'));
          lGroup.Description := Trim(GetNodeAttribute(lStyleNode, 'desc'));
          lGroup.HasLexerID := ParseOptionalInt(GetNodeAttribute(lStyleNode, 'lexer'),
            lGroup.LexerID);

          lWordStylesNode := FindChildNode(lStyleNode, 'WordStyles');
          if lWordStylesNode = nil then
            Continue;

          for lWordIndex := 0 to lWordStylesNode.ChildNodes.Count - 1 do
          begin
            lNode := lWordStylesNode.ChildNodes[lWordIndex];
            if not IsElementNode(lNode) or not SameText(lNode.NodeName, 'WordStyle') then
              Continue;

            lStyle := ParseStyleNode(lNode, InferConfigStyleKind(lGroup.Name, lNode));
            try
              lGroup.Styles.Add(CreateVisualStyle(lStyle));
            finally
              lStyle.Free;
            end;
          end;
        end;
    finally
      lWordStylesNode := nil;
      lThemeNode := nil;
      lStylesNode := nil;
      lStyleNode := nil;
      lRoot := nil;
      lNode := nil;
      lHighlightNode := nil;
      lFileSizeNode := nil;
      lXml := nil;
      if (lInit = S_OK) or (lInit = S_FALSE) then
        CoUninitialize;
    end;
  except
    on E: Exception do
      raise Exception.CreateFmt('LoadSeedConfig %s failed: %s - %s',
        [lStep, E.ClassName, E.Message]);
  end;
end;

procedure CopyMiscSettings(const ASource, ATarget: TDSciVisualConfig);
begin
  if (ASource = nil) or (ATarget = nil) then
    Exit;

  ATarget.ThemeName := ASource.ThemeName;
  ATarget.HighlightColor := ASource.HighlightColor;
  ATarget.HighlightAlpha := ASource.HighlightAlpha;
  ATarget.HighlightOutlineAlpha := ASource.HighlightOutlineAlpha;
  ATarget.LineNumbering := ASource.LineNumbering;
  ATarget.LineWrapping := ASource.LineWrapping;
  ATarget.TabWidth := ASource.TabWidth;
  ATarget.FileSizeLimit := ASource.FileSizeLimit;
  ATarget.SearchSync := ASource.SearchSync;
end;

function LoadBaseModel(const ASettingsDirectory: string): TDSciVisualStyleModel;
var
  lLanguageMetadata: TDSciVisualStyleModel;
begin
  Result := LoadStyleModel(TPath.Combine(ASettingsDirectory, 'stylers.model.xml'));
  try
    lLanguageMetadata := LoadLanguageMetadata(TPath.Combine(ASettingsDirectory, 'langs.model.xml'));
    try
      MergeLanguageMetadata(Result, lLanguageMetadata);
    finally
      lLanguageMetadata.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure BuildConfigFromLegacySettings(const ASettingsDirectory,
  ASeedConfigFileName, AThemeName: string; const AConfig: TDSciVisualConfig);
var
  lImportedModel: TDSciVisualStyleModel;
  lSeedConfig: TDSciVisualConfig;
  lSettingsDirectory: string;
  lStep: string;
  lThemeModel: TDSciVisualStyleModel;
  lThemeName: string;
begin
  if AConfig = nil then
    raise EArgumentNilException.Create('AConfig');

  lSettingsDirectory := IncludeTrailingPathDelimiter(ExpandFileName(ASettingsDirectory));
  if not DirectoryExists(lSettingsDirectory) then
    raise EDirectoryNotFoundException.CreateFmt('Settings directory not found: %s',
      [ASettingsDirectory]);

  try
    lStep := 'load seed config';
    lSeedConfig := LoadSeedConfig(ASeedConfigFileName);
    try
      lStep := 'copy misc settings';
      AConfig.ResetDefaults;
      CopyMiscSettings(lSeedConfig, AConfig);

      lStep := 'resolve theme name';
      lThemeName := Trim(AThemeName);
      if lThemeName = '' then
        lThemeName := Trim(lSeedConfig.ThemeName);
      AConfig.ThemeName := lThemeName;

      lStep := 'load base style model';
      lImportedModel := LoadBaseModel(lSettingsDirectory);
      try
        if lThemeName <> '' then
        begin
          lStep := 'load theme model';
          lThemeModel := LoadStyleModel(ResolveThemeFileName(lSettingsDirectory, lThemeName));
          try
            lStep := 'merge theme model';
            MergeModel(lImportedModel, lThemeModel);
          finally
            lThemeModel.Free;
          end;
        end;

        lStep := 'merge keyword content';
        MergeLanguageKeywordContent(lImportedModel,
          TPath.Combine(lSettingsDirectory, 'langs.model.xml'));

        if lSeedConfig.HasStyleOverrides then
        begin
          lStep := 'merge seed overrides';
          MergeModel(lImportedModel, lSeedConfig.StyleOverrides);
        end;

        lStep := 'commit imported model';
        AConfig.ReplaceStyleModel(lImportedModel, False);
      finally
        lImportedModel.Free;
      end;
    finally
      lSeedConfig.Free;
    end;
  except
    on E: Exception do
      raise Exception.CreateFmt('BuildConfigFromLegacySettings %s failed: %s - %s',
        [lStep, E.ClassName, E.Message]);
  end;
end;

end.
