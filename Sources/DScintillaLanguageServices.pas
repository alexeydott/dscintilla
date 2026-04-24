unit DScintillaLanguageServices;

interface

uses
  System.Classes, System.Generics.Collections;

type
  TDSciDocumentFunction = class
  public
    Name: string;
    Signature: string;
  end;

  TDSciAutoCompleteOverload = class
  private
    FParameters: TStringList;
  public
    ReturnValue: string;

    constructor Create;
    destructor Destroy; override;

    function TryBuildCallTip(const AName: string; AParameterIndex: Integer;
      out AText: string; out AHighlightStart: Integer;
      out AHighlightEnd: Integer): Boolean;

    property Parameters: TStringList read FParameters;
  end;

  TDSciAutoCompleteItem = class
  private
    FOverloads: TObjectList<TDSciAutoCompleteOverload>;
  public
    Name: string;
    IsFunction: Boolean;

    constructor Create;
    destructor Destroy; override;

    function TryBuildCallTip(AParameterIndex: Integer; out AText: string;
      out AHighlightStart: Integer; out AHighlightEnd: Integer): Boolean;

    property Overloads: TObjectList<TDSciAutoCompleteOverload> read FOverloads;
  end;

  TDSciAutoCompleteModel = class
  private
    FItems: TObjectList<TDSciAutoCompleteItem>;
  public
    LanguageName: string;
    IgnoreCase: Boolean;
    StartFunctionChar: WideChar;
    StopFunctionChar: WideChar;
    ParamSeparatorChar: WideChar;
    TerminalChar: WideChar;
    AdditionalWordChars: string;

    constructor Create;
    destructor Destroy; override;

    procedure CollectMatches(const APrefix: string; AItems: TStrings);
    function FindItem(const AName: string): TDSciAutoCompleteItem;
    function IsIdentifierChar(AChar: WideChar): Boolean;

    property Items: TObjectList<TDSciAutoCompleteItem> read FItems;
  end;

  TDSciFunctionPattern = class
  private
    FNameExpressions: TStringList;
  public
    MainExpression: string;

    constructor Create;
    destructor Destroy; override;

    property NameExpressions: TStringList read FNameExpressions;
  end;

  TDSciFunctionListModel = class
  private
    FPatterns: TObjectList<TDSciFunctionPattern>;
  public
    LanguageName: string;
    CommentExpression: string;

    constructor Create;
    destructor Destroy; override;

    function ExtractFunctions(const AText: string): TObjectList<TDSciDocumentFunction>;

    property Patterns: TObjectList<TDSciFunctionPattern> read FPatterns;
  end;

function LoadAutoCompleteModelFromFile(const AFileName: string): TDSciAutoCompleteModel;
function LoadFunctionListModelFromFile(const AFileName: string): TDSciFunctionListModel;

implementation

uses
  System.Character, System.StrUtils, System.SysUtils, System.RegularExpressions,
  System.Variants,
  Winapi.Windows,
  Xml.XMLDoc, Xml.XMLIntf, Xml.xmldom, Xml.omnixmldom,
  DScintillaLogger;

procedure LogFix(const AMessage: string);
begin
  DSciLog('' + AMessage, cDSciLogDebug);
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

function FindChildNode(const AParent: IXMLNode; const AName: string): IXMLNode;
var
  lIndex: Integer;
  lNode: IXMLNode;
begin
  Result := nil;
  if not IsElementNode(AParent) then
    Exit;

  for lIndex := 0 to AParent.ChildNodes.Count - 1 do
  begin
    lNode := AParent.ChildNodes[lIndex];
    if IsElementNode(lNode) and SameText(lNode.NodeName, AName) then
      Exit(lNode);
  end;
end;

function FindFirstDescendantNode(const AParent: IXMLNode;
  const AName: string): IXMLNode;
var
  lIndex: Integer;
  lNode: IXMLNode;
begin
  Result := nil;
  if not IsElementNode(AParent) then
    Exit;

  for lIndex := 0 to AParent.ChildNodes.Count - 1 do
  begin
    lNode := AParent.ChildNodes[lIndex];
    if not IsElementNode(lNode) then
      Continue;
    if SameText(lNode.NodeName, AName) then
      Exit(lNode);

    Result := FindFirstDescendantNode(lNode, AName);
    if Result <> nil then
      Exit;
  end;
end;

function JoinStrings(AItems: TStrings; const ASeparator: string): string;
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

function NormalizeWhitespace(const AText: string): string;
var
  lChar: Char;
  lLastWasSpace: Boolean;
begin
  Result := '';
  lLastWasSpace := False;
  for lChar in AText do
    if CharInSet(lChar, [#9, #10, #13, ' ']) then
    begin
      if not lLastWasSpace then
      begin
        Result := Result + ' ';
        lLastWasSpace := True;
      end;
    end
    else
    begin
      Result := Result + lChar;
      lLastWasSpace := False;
    end;
  Result := Trim(Result);
end;

function NormalizeFunctionSignature(const AText: string): string;
begin
  Result := NormalizeWhitespace(AText);
  while (Result <> '') and CharInSet(Result[Length(Result)], ['{', '}', ';']) do
    Delete(Result, Length(Result), 1);
  Result := Trim(Result);
end;

function CleanupFunctionName(const AName: string): string;
var
  lPos: Integer;
begin
  Result := NormalizeWhitespace(AName);
  lPos := Pos('(', Result);
  if lPos > 0 then
    Result := Trim(Copy(Result, 1, lPos - 1));
  while (Result <> '') and CharInSet(Result[Length(Result)], ['{', '}', ';']) do
    Delete(Result, Length(Result), 1);
  Result := Trim(Result);
end;

procedure CollectFunctionNodes(const AParent: IXMLNode;
  APatterns: TObjectList<TDSciFunctionPattern>);
var
  lFunctionNameNode: IXMLNode;
  lIndex: Integer;
  lNameIndex: Integer;
  lNode: IXMLNode;
  lPattern: TDSciFunctionPattern;
begin
  if not IsElementNode(AParent) then
    Exit;

  for lIndex := 0 to AParent.ChildNodes.Count - 1 do
  begin
    lNode := AParent.ChildNodes[lIndex];
    if not IsElementNode(lNode) then
      Continue;

    if SameText(lNode.NodeName, 'function') then
    begin
      lPattern := TDSciFunctionPattern.Create;
      lPattern.MainExpression := GetNodeAttribute(lNode, 'mainExpr');
      lFunctionNameNode := FindChildNode(lNode, 'functionName');
      if lFunctionNameNode = nil then
        lFunctionNameNode := FindChildNode(lNode, 'className');
      if lFunctionNameNode <> nil then
        for lNameIndex := 0 to lFunctionNameNode.ChildNodes.Count - 1 do
          if IsElementNode(lFunctionNameNode.ChildNodes[lNameIndex]) and
             (SameText(lFunctionNameNode.ChildNodes[lNameIndex].NodeName, 'nameExpr') or
              SameText(lFunctionNameNode.ChildNodes[lNameIndex].NodeName, 'funcNameExpr')) then
            lPattern.NameExpressions.Add(
              GetNodeAttribute(lFunctionNameNode.ChildNodes[lNameIndex], 'expr'));

      if (Trim(lPattern.MainExpression) <> '') and (lPattern.NameExpressions.Count > 0) then
        APatterns.Add(lPattern)
      else
        lPattern.Free;
    end;

    CollectFunctionNodes(lNode, APatterns);
  end;
end;

function SafeMatchCollection(const AText, APattern: string;
  out AMatches: TMatchCollection): Boolean;
begin
  Result := False;
  try
    AMatches := TRegEx.Matches(AText, APattern);
    Result := True;
  except
    on E: Exception do
      LogFix(Format('Regex "%s" is not supported: %s', [Copy(APattern, 1, 80), E.Message]));
  end;
end;

function SafeReplaceRegex(const AText, APattern, AReplacement: string): string;
begin
  Result := AText;
  try
    Result := TRegEx.Replace(AText, APattern, AReplacement);
  except
    on E: Exception do
      LogFix(Format('Regex replace "%s" failed: %s', [Copy(APattern, 1, 80), E.Message]));
  end;
end;

function TryExtractPatternName(const APattern: TDSciFunctionPattern;
  const ASnippet: string; out AName: string): Boolean;
var
  lExpr: string;
  lMatch: TMatch;
begin
  Result := False;
  AName := '';
  if APattern = nil then
    Exit;

  for lExpr in APattern.NameExpressions do
  begin
    try
      lMatch := TRegEx.Match(ASnippet, lExpr);
    except
      on E: Exception do
      begin
        LogFix(Format('Function name regex "%s" is not supported: %s',
          [Copy(lExpr, 1, 80), E.Message]));
        Continue;
      end;
    end;

    if lMatch.Success then
    begin
      AName := CleanupFunctionName(lMatch.Value);
      if AName <> '' then
        Exit(True);
    end;
  end;
end;

constructor TDSciAutoCompleteOverload.Create;
begin
  inherited Create;
  FParameters := TStringList.Create;
end;

destructor TDSciAutoCompleteOverload.Destroy;
begin
  FParameters.Free;
  inherited Destroy;
end;

function TDSciAutoCompleteOverload.TryBuildCallTip(const AName: string;
  AParameterIndex: Integer; out AText: string; out AHighlightStart,
  AHighlightEnd: Integer): Boolean;
var
  lIndex: Integer;
  lPrefix: string;
  lSignature: string;
begin
  AHighlightStart := 0;
  AHighlightEnd := 0;

  lPrefix := '';
  if Trim(ReturnValue) <> '' then
    lPrefix := Trim(ReturnValue) + ' ';
  lPrefix := lPrefix + AName + '(';
  lSignature := JoinStrings(FParameters, ', ');
  AText := lPrefix + lSignature + ')';

  if (AParameterIndex >= 0) and (AParameterIndex < FParameters.Count) then
  begin
    AHighlightStart := Length(lPrefix);
    for lIndex := 0 to AParameterIndex - 1 do
      Inc(AHighlightStart, Length(FParameters[lIndex]) + 2);
    AHighlightEnd := AHighlightStart + Length(FParameters[AParameterIndex]);
  end;

  Result := True;
end;

constructor TDSciAutoCompleteItem.Create;
begin
  inherited Create;
  FOverloads := TObjectList<TDSciAutoCompleteOverload>.Create(True);
end;

destructor TDSciAutoCompleteItem.Destroy;
begin
  FOverloads.Free;
  inherited Destroy;
end;

function TDSciAutoCompleteItem.TryBuildCallTip(AParameterIndex: Integer;
  out AText: string; out AHighlightStart, AHighlightEnd: Integer): Boolean;
var
  lBestOverload: TDSciAutoCompleteOverload;
  lOverload: TDSciAutoCompleteOverload;
begin
  Result := False;
  AText := '';
  AHighlightStart := 0;
  AHighlightEnd := 0;

  if not IsFunction then
    Exit;

  lBestOverload := nil;
  for lOverload in FOverloads do
    if (lBestOverload = nil) or
       ((lOverload.Parameters.Count > AParameterIndex) and
        ((lBestOverload.Parameters.Count <= AParameterIndex) or
         (lOverload.Parameters.Count < lBestOverload.Parameters.Count))) then
      lBestOverload := lOverload;

  if lBestOverload = nil then
  begin
    AText := Name + '()';
    Exit(True);
  end;

  Result := lBestOverload.TryBuildCallTip(Name, AParameterIndex, AText,
    AHighlightStart, AHighlightEnd);
end;

constructor TDSciAutoCompleteModel.Create;
begin
  inherited Create;
  FItems := TObjectList<TDSciAutoCompleteItem>.Create(True);
  StartFunctionChar := '(';
  StopFunctionChar := ')';
  ParamSeparatorChar := ',';
  TerminalChar := ';';
end;

destructor TDSciAutoCompleteModel.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TDSciAutoCompleteModel.CollectMatches(const APrefix: string;
  AItems: TStrings);
var
  lItem: TDSciAutoCompleteItem;
  lPrefix: string;
begin
  if AItems = nil then
    Exit;

  lPrefix := APrefix;
  for lItem in FItems do
    if (lPrefix = '') or
       (IgnoreCase and StartsText(lPrefix, lItem.Name)) or
       ((not IgnoreCase) and StartsStr(lPrefix, lItem.Name)) then
      AItems.Add(lItem.Name);
end;

function TDSciAutoCompleteModel.FindItem(const AName: string): TDSciAutoCompleteItem;
var
  lItem: TDSciAutoCompleteItem;
begin
  Result := nil;
  for lItem in FItems do
    if (IgnoreCase and SameText(lItem.Name, AName)) or
       ((not IgnoreCase) and SameStr(lItem.Name, AName)) then
      Exit(lItem);
end;

function TDSciAutoCompleteModel.IsIdentifierChar(AChar: WideChar): Boolean;
begin
  Result := AChar.IsLetterOrDigit or (AChar = '_') or
    (Pos(string(AChar), AdditionalWordChars) > 0);
end;

constructor TDSciFunctionPattern.Create;
begin
  inherited Create;
  FNameExpressions := TStringList.Create;
end;

destructor TDSciFunctionPattern.Destroy;
begin
  FNameExpressions.Free;
  inherited Destroy;
end;

constructor TDSciFunctionListModel.Create;
begin
  inherited Create;
  FPatterns := TObjectList<TDSciFunctionPattern>.Create(True);
end;

destructor TDSciFunctionListModel.Destroy;
begin
  FPatterns.Free;
  inherited Destroy;
end;

function TDSciFunctionListModel.ExtractFunctions(
  const AText: string): TObjectList<TDSciDocumentFunction>;
var
  lEntry: TDSciDocumentFunction;
  lFunctionName: string;
  lMatch: TMatch;
  lMatches: TMatchCollection;
  lPattern: TDSciFunctionPattern;
  lSanitizedText: string;
  lSeen: TStringList;
  lSignature: string;
begin
  Result := TObjectList<TDSciDocumentFunction>.Create(True);
  lSeen := TStringList.Create;
  try
    lSeen.Sorted := True;
    lSeen.CaseSensitive := False;
    lSeen.Duplicates := dupIgnore;

    lSanitizedText := AText;
    if Trim(CommentExpression) <> '' then
      lSanitizedText := SafeReplaceRegex(lSanitizedText, CommentExpression, ' ');

    for lPattern in FPatterns do
    begin
      if Trim(lPattern.MainExpression) = '' then
        Continue;
      if not SafeMatchCollection(lSanitizedText, lPattern.MainExpression, lMatches) then
        Continue;

      for lMatch in lMatches do
      begin
        lSignature := NormalizeFunctionSignature(lMatch.Value);
        if (lSignature = '') or
           (not TryExtractPatternName(lPattern, lMatch.Value, lFunctionName)) then
          Continue;

        if lSeen.IndexOf(lFunctionName + '|' + lSignature) >= 0 then
          Continue;
        lSeen.Add(lFunctionName + '|' + lSignature);

        lEntry := TDSciDocumentFunction.Create;
        lEntry.Name := lFunctionName;
        lEntry.Signature := lSignature;
        Result.Add(lEntry);
      end;
    end;
  finally
    lSeen.Free;
  end;
end;

function LoadAutoCompleteModelFromFile(
  const AFileName: string): TDSciAutoCompleteModel;
var
  lAutoCompleteNode: IXMLNode;
  lDocument: IXMLDocument;
  lEnvironmentNode: IXMLNode;
  lIndex: Integer;
  lItem: TDSciAutoCompleteItem;
  lKeyWordNode: IXMLNode;
  lOverload: TDSciAutoCompleteOverload;
  lOverloadIndex: Integer;
  lOverloadNode: IXMLNode;
  lParamIndex: Integer;
  lParamNode: IXMLNode;
begin
  Result := TDSciAutoCompleteModel.Create;
  try
    lDocument := CreateXmlDocument;
    lDocument.LoadFromFile(AFileName);
    lDocument.Active := True;

    lAutoCompleteNode := FindFirstDescendantNode(lDocument.DocumentElement, 'AutoComplete');
    if lAutoCompleteNode = nil then
      Exit;

    Result.LanguageName := GetNodeAttribute(lAutoCompleteNode, 'language');
    lEnvironmentNode := FindChildNode(lAutoCompleteNode, 'Environment');
    if lEnvironmentNode <> nil then
    begin
      Result.IgnoreCase := SameText(GetNodeAttribute(lEnvironmentNode, 'ignoreCase'), 'yes');
      if GetNodeAttribute(lEnvironmentNode, 'startFunc') <> '' then
        Result.StartFunctionChar := GetNodeAttribute(lEnvironmentNode, 'startFunc')[1];
      if GetNodeAttribute(lEnvironmentNode, 'stopFunc') <> '' then
        Result.StopFunctionChar := GetNodeAttribute(lEnvironmentNode, 'stopFunc')[1];
      if GetNodeAttribute(lEnvironmentNode, 'paramSeparator') <> '' then
        Result.ParamSeparatorChar := GetNodeAttribute(lEnvironmentNode, 'paramSeparator')[1];
      if GetNodeAttribute(lEnvironmentNode, 'terminal') <> '' then
        Result.TerminalChar := GetNodeAttribute(lEnvironmentNode, 'terminal')[1];
      Result.AdditionalWordChars := GetNodeAttribute(lEnvironmentNode, 'additionalWordChar');
    end;

    for lIndex := 0 to lAutoCompleteNode.ChildNodes.Count - 1 do
    begin
      lKeyWordNode := lAutoCompleteNode.ChildNodes[lIndex];
      if not IsElementNode(lKeyWordNode) or not SameText(lKeyWordNode.NodeName, 'KeyWord') then
        Continue;

      lItem := TDSciAutoCompleteItem.Create;
      lItem.Name := GetNodeAttribute(lKeyWordNode, 'name');
      lItem.IsFunction := SameText(GetNodeAttribute(lKeyWordNode, 'func'), 'yes');
      if Trim(lItem.Name) = '' then
      begin
        lItem.Free;
        Continue;
      end;

      for lOverloadIndex := 0 to lKeyWordNode.ChildNodes.Count - 1 do
      begin
        lOverloadNode := lKeyWordNode.ChildNodes[lOverloadIndex];
        if not IsElementNode(lOverloadNode) or not SameText(lOverloadNode.NodeName, 'Overload') then
          Continue;

        lOverload := TDSciAutoCompleteOverload.Create;
        lOverload.ReturnValue := GetNodeAttribute(lOverloadNode, 'retVal');
        for lParamIndex := 0 to lOverloadNode.ChildNodes.Count - 1 do
        begin
          lParamNode := lOverloadNode.ChildNodes[lParamIndex];
          if IsElementNode(lParamNode) and SameText(lParamNode.NodeName, 'Param') then
            lOverload.Parameters.Add(GetNodeAttribute(lParamNode, 'name'));
        end;
        lItem.Overloads.Add(lOverload);
      end;

      Result.Items.Add(lItem);
    end;
  except
    Result.Free;
    raise;
  end;
end;

function LoadFunctionListModelFromFile(
  const AFileName: string): TDSciFunctionListModel;
var
  lDocument: IXMLDocument;
  lParserNode: IXMLNode;
begin
  Result := TDSciFunctionListModel.Create;
  try
    lDocument := CreateXmlDocument;
    lDocument.LoadFromFile(AFileName);
    lDocument.Active := True;

    lParserNode := FindFirstDescendantNode(lDocument.DocumentElement, 'parser');
    if lParserNode = nil then
      Exit;

    Result.LanguageName := GetNodeAttribute(lParserNode, 'displayName');
    Result.CommentExpression := GetNodeAttribute(lParserNode, 'commentExpr');
    CollectFunctionNodes(lParserNode, Result.Patterns);
  except
    Result.Free;
    raise;
  end;
end;

end.
