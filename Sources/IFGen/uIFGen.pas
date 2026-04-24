{-----------------------------------------------------------------------------
 Unit Name: uIFGen
 Author:    Krystian
 Date:      28-lis-2009
 Purpose:
 History:
-----------------------------------------------------------------------------}

unit uIFGen;

interface

uses
  Classes, SysUtils, Generics.Collections;

type
  TSciGen = class
  public
    type
      TConstItem = record
        ConstName: String;
        ConstValue: String;
        ConstAlias: String;
      end;

      TConstsList = TList<TConstItem>;

      TCodeItem = class;
      TCodeList = class;

      TCodeParam = class
      private
        FIdx: Integer;
        function GetParamType: String;
      public
        Owner: TCodeItem;
        IsSet: Boolean;
        FParamType: String;
        ParamName: String;

        constructor Create(AOwner: TCodeItem; AIdx: Integer);

        property ParamType: String read GetParamType write FParamType;
      end;

      TSciEnums = TList<String>;

      TSciEnumVals = TList<TConstItem>;

      TCodeType = (ctFunc, ctProc, ctGet, ctSet, ctEnu);
      TCodeItem = class
      private
        function GetReturnType: String;
      public
        FReturnType: String;

        Owner: TCodeList;
        CodeType: TCodeType;
        ItemName: String;
        ItemIndex: String;
        ConstName: String;

        EnumNames: TSciEnums;
        EnumVals: TSciEnumVals;

        Param1: TCodeParam;
        Param2: TCodeParam;

        Doc: String;

        property ReturnType: String read GetReturnType write FReturnType;

        function GetPropertyName: String;

        function GetEnumItemName: String;

        function GetEnumPrefix: String;
        function GetEnumNameVal(AIndex: Integer; AChar1: Char = ' '; AChar2: Char = ','): String;

        function IsEnum(AName: String): String;
        function AddEnumValue(AItem: TConstItem): Boolean;

        constructor Create(AOwner: TCodeList);
        destructor Destroy; override;
      end;

      TCodePropItem = record
        GetCode: TCodeItem;
        SetCode: TCodeItem;

        ItemName: String;
      end;

      TCodeList = class(TList<TCodeItem>)
        procedure Notify(const Item: TCodeItem; Action: TCollectionNotification); override;
      end;
      TCodeProps = TDictionary<String, TCodePropItem>;
  private
    function GetCodeParams(const ACodeItem: TCodeItem): String;
    function TryResolveEnumType(const AType: String; out AResolvedType: String;
      out AIsSet: Boolean): Boolean;
  public
    FLastEnum: TCodeItem;

    ConstDef: String;

    EnumsDef: String;
    EnumsCodeDef: String;
    EnumsCodeDecl: String;
    EnumNames: TStringList;

    ProtectedDef: String;
    PublicDef: String;
    PublishedDef: String;
    UnsafeDef: String;
    PublicPropertesDef: String;
    PublishedPropertesDef: String;

    ProtectedCode: String;
    UnsafeCode: String;
    PublicCode: String;

    Consts: TConstsList;
    Code: TCodeList;
    Props: TCodeProps;


    constructor Create;
    destructor Destroy; override;

    procedure SecondPass;
    procedure AddCodeItem(const ACodeItem: TCodeItem; AAddDoc: Boolean = True);

    class function GetValue(AName, AFeature: String): String;
    class procedure SetValue(AName, AFeature, AValue: String);

    class function GetIsCustomFile(AName: String): Boolean;
    class function NormalizeTypeName(const AType: String): String;
  end;

function GetDelphiCode(ASciIFaceFile, ASciIFaceFileCustom: String): TSciGen; overload;
function GetDelphiCode(const ASciIFaceFiles: array of String;
  ASciIFaceFileCustom: String): TSciGen; overload;

function GetCustomFile(AName: String): String;
procedure SetIFGenBaseDir(const ADir: String);

procedure _SaveFS;

implementation

uses
  Windows, StrUtils, Character;

const
  rsCustomsCode = 'CustomCode\%s';
  rsFeaturesFile = '!FeaturesCfg.txt';

var
  _FeatureSL: TStringList;
  _IFGenBaseDir: String;
  _FeatureSLLoaded: Boolean;

function GetIFGenBaseDir: String;
begin
  if _IFGenBaseDir = '' then
    Result := IncludeTrailingPathDelimiter(GetCurrentDir)
  else
    Result := _IFGenBaseDir;
end;

procedure SetIFGenBaseDir(const ADir: String);
begin
  if ADir = '' then
    _IFGenBaseDir := IncludeTrailingPathDelimiter(GetCurrentDir)
  else
    _IFGenBaseDir := IncludeTrailingPathDelimiter(ExpandFileName(ADir));

  _FeatureSL.Clear;
  _FeatureSLLoaded := False;
end;

function GetCustomFile(AName: String): String;
begin
  Result := ExpandFileName(GetIFGenBaseDir + Format(rsCustomsCode, [AName]));
end;

class function TSciGen.NormalizeTypeName(const AType: String): String;
begin
  Result := AType;

  if SameText(Result, 'TKBScintillaFunction') then
    Exit('TDScintillaFunction');

  if SameText(Result, 'TKBScintillaStatusFunction') then
    Exit('TDScintillaStatusFunction');

  if SameText(Result, 'TKBSciLexer') then
    Exit('TDSciLexerId');

  if SameText(Result, 'TKBSciUndoActionFlags') then
    Exit('UndoFlags');

  if SameText(Result, 'TKBSciUndoActionFlagsSet') then
    Exit('UndoFlagsSet');

  if StartsText('TKBSci', Result) then
    Exit(Copy(Result, Length('TKBSci') + 1, MaxInt));

  if SameText(Result, 'String') or
    SameText(Result, 'Char') or
    SameText(Result, 'Pointer') or
    SameText(Result, 'UnicodeString') or
    SameText(Result, 'AnsiString') or
    SameText(Result, 'AnsiChar') or
    SameText(Result, 'Boolean') or
    SameText(Result, 'Integer') or
    SameText(Result, 'NativeInt') or
    SameText(Result, 'TColor') or
    SameText(Result, 'PByte') or
    StartsText('PDSci', Result) or
    StartsText('TDSci', Result) or
    StartsText('TDScintilla', Result)
  then
    Exit(Result);

  if (Result <> '') and CharInSet(Result[1], ['A'..'Z']) then
    Exit('TDSci' + Result);
end;

procedure EnsureFeaturesLoaded;
var
  lFeaturesFile: String;
begin
  if _FeatureSLLoaded then
    Exit;

  _FeatureSL.Clear;
  lFeaturesFile := GetCustomFile(rsFeaturesFile);
  if FileExists(lFeaturesFile) then
    _FeatureSL.LoadFromFile(lFeaturesFile);

  _FeatureSLLoaded := True;
end;

function GetDelphiCode(ASciIFaceFile, ASciIFaceFileCustom: String): TSciGen;
begin
  Result := GetDelphiCode([ASciIFaceFile], ASciIFaceFileCustom);
end;

function GetDelphiCode(const ASciIFaceFiles: array of String;
  ASciIFaceFileCustom: String): TSciGen;
type
  TTokenType = (ttNull, ttSpace, ttString, ttInt, ttHex, ttBraceOpen, ttBraceClose, ttEqual, ttComma,
    ttComment, ttDocComment);

  TTokenTypes = set of TTokenType;
var
  lIn: TStringList;
  lRes: TSciGen;
  lIFaceFile: String;

  lLine: String;
  lLineIdx: Integer;

  lToken: String;
  lTokenType: TTokenType;
  lTokenIdx: Integer;
  lLastLineVar: Boolean;

  lDocComment: String;

  function NextLine: Boolean;
  begin
    Result := lLineIdx < lIn.Count;

    if Result then
    begin
      lLine := lIn[lLineIdx];
      Inc(lLineIdx);

      lTokenIdx := 1;
      lTokenType := ttNull;
      lToken := '';
    end;
  end;

  function NextTokenWS: Boolean;
  var
    lStart: Integer;

    procedure SetToken(AType: TTokenType; ASingleChar: Boolean = False);
    begin
      if ASingleChar then
        Inc(lTokenIdx);

      lTokenType := AType;
      lToken := Copy(lLine, lStart, lTokenIdx - lStart);
    end;

  begin
    Result := lTokenIdx <= Length(lLine);

    if not Result then
    begin
      lToken := '';
      lTokenType := ttNull;
    end else
    begin
      lStart := lTokenIdx;

      case lLine[lTokenIdx] of
      ' ', #9:
        begin
          while (lTokenIdx <= Length(lLine)) and CharInSet(lLine[lTokenIdx], [' ', #9]) do
            Inc(lTokenIdx);

          SetToken(ttSpace);
        end;

      ',':
        SetToken(ttComma, True);

      '(':
        SetToken(ttBraceOpen, True);

      ')':
        SetToken(ttBraceClose, True);

      '=':
        SetToken(ttEqual, True);

      'a'..'z', 'A'..'Z':
        begin
          while (lTokenIdx <= Length(lLine)) and CharInSet(lLine[lTokenIdx], ['a'..'z', 'A'..'Z', '_', '0'..'9']) do
            Inc(lTokenIdx);

          SetToken(ttString);
        end;

      '-', '0'..'9':
        begin
          Inc(lTokenIdx);
          if (lTokenIdx <= Length(lLine)) and (lLine[lTokenIdx] = 'x') then
          begin
            Inc(lTokenIdx);
            lStart := lTokenIdx;

            while (lTokenIdx <= Length(lLine)) and CharInSet(lLine[lTokenIdx], ['0'..'9', 'a'..'f', 'A'..'F']) do
              Inc(lTokenIdx);

            SetToken(ttHex);
            lToken := '$' + lToken;
          end else
          begin
            while (lTokenIdx <= Length(lLine)) and CharInSet(lLine[lTokenIdx], ['0'..'9']) do
              Inc(lTokenIdx);

            SetToken(ttInt);
          end;
        end;

      '#':
        begin
          Inc(lTokenIdx);

          if lTokenIdx > Length(lLine) then
            raise Exception.Create('Parser: Unexpected # end!');

          case lLine[lTokenIdx] of
          '#':
            begin
              Inc(lTokenIdx, 2);
              lStart := lTokenIdx;

              lTokenIdx := Length(lLine) + 1;
              SetToken(ttComment);
            end;

          '!':
            begin
              Inc(lTokenIdx, 2);
              lStart := lTokenIdx;

              lTokenIdx := Length(lLine) + 1;
              SetToken(ttComment);
            end;

          ' ':
            begin
              Inc(lTokenIdx);
              lStart := lTokenIdx;

              lTokenIdx := Length(lLine) + 1;
              SetToken(ttDocComment);
            end;
          else
            begin
              lStart := lTokenIdx;

              lTokenIdx := Length(lLine) + 1;
              SetToken(ttDocComment);
            end;
          end;

        end;
      else
        raise Exception.Create('Parser: Unexpected next char!');
      end;
    end;
  end;

  function NextToken: Boolean;
  begin
    repeat
      Result := NextTokenWS;

      if not Result then
        Break;
    until not (lTokenType in [ttSpace]);
  end;

  procedure ExceptToken(ATokens: TTokenTypes; AMoveNext: Boolean = True);
  begin
    if AMoveNext and not NextToken then
      if not (ttNull in ATokens) then
        raise Exception.Create('EOL!');

    if not (lTokenType in ATokens) then
      raise Exception.CreateFmt('Unexpected token "%s"', [lToken]);
  end;

  procedure SkipLine;
  begin
    while NextToken do
      ;
  end;

  procedure ParseCat;
  begin
    SkipLine;
  end;

  function GetDoc(AIndent: Integer; AClearDoc: Boolean): String;
  var
    lSL: TStringList;
    lIndent: String;
    lDocIdx: Integer;
  begin
    if lDocComment = '' then
      Exit('');

    lSL := TStringList.Create;
    try
      lIndent := StringOfChar(' ', AIndent);

      lSL.Text := lDocComment;
      if AClearDoc then
        lDocComment := '';

      Result := '';
      for lDocIdx := 0 to lSL.Count - 1 do
      begin
        Result := Result + lIndent + lSL[lDocIdx];

        if lDocIdx = lSL.Count - 1 then
          Result := Result + '</summary>';

        Result := Result + sLineBreak;
      end;


    finally
      lSL.Free;
    end;
  end;

  procedure AddConst(AName, AValue: String; AClearDoc: Boolean; ADocIndent: Integer);
  var
    lConts: TSciGen.TConstItem;
    lContsStr: String;
  begin
    lConts.ConstName := AName;
    lConts.ConstValue := AValue;
    lConts.ConstAlias := '';

    lRes.Consts.Add(lConts);

    if lLastLineVar and (lDocComment <> '') then
      lRes.ConstDef := lRes.ConstDef + sLineBreak;

    lRes.ConstDef := lRes.ConstDef + GetDoc(ADocIndent, AClearDoc);
    lContsStr := Format('  %s = %s;%s', [lConts.ConstName, lConts.ConstValue, sLineBreak]);

//    OutputDebugString(PChar(lContsStr));
    lRes.ConstDef := lRes.ConstDef + lContsStr;

    if lRes.FLastEnum <> nil then
      lRes.FLastEnum.AddEnumValue(lConts);

    lLastLineVar := True;
  end;

  procedure ParseVal;
  var
    lName, lValue: String;
  begin
    ExceptToken([ttString]);
    lName := lToken;

    ExceptToken([ttEqual]);

    ExceptToken([ttInt, ttHex]);
    lValue := lToken;

    AddConst(lName, lValue, True, 2);
  end;

  procedure ParseAlias;
  var
    lName: String;
    lAlias: String;
    lConstIdx: Integer;
    lCodeIdx: Integer;
    lEnumIdx: Integer;
    lConstItem: TSciGen.TConstItem;
  begin
    ExceptToken([ttString]);
    lName := lToken;

    ExceptToken([ttEqual]);

    ExceptToken([ttString]);
    lAlias := lToken;

    for lConstIdx := 0 to lRes.Consts.Count - 1 do
      if SameText(lRes.Consts[lConstIdx].ConstName, lName) then
      begin
        lConstItem := lRes.Consts[lConstIdx];
        lConstItem.ConstAlias := lAlias;
        lRes.Consts[lConstIdx] := lConstItem;
      end;

    for lCodeIdx := 0 to lRes.Code.Count - 1 do
      if lRes.Code[lCodeIdx].CodeType = ctEnu then
        for lEnumIdx := 0 to lRes.Code[lCodeIdx].EnumVals.Count - 1 do
          if SameText(lRes.Code[lCodeIdx].EnumVals[lEnumIdx].ConstName, lName) then
          begin
            lConstItem := lRes.Code[lCodeIdx].EnumVals[lEnumIdx];
            lConstItem.ConstAlias := lAlias;
            lRes.Code[lCodeIdx].EnumVals[lEnumIdx] := lConstItem;
          end;
  end;

  procedure ParseCode;
  var
    lCodeItem: TSciGen.TCodeItem;
    lType: string;

    procedure ReadParam(ATokenType: TTokenType; var AParam: TSciGen.TCodeParam);
    begin
      NextToken;
      AParam.IsSet := lTokenType = ttString;
      if AParam.IsSet then
      begin
        AParam.ParamType := lToken;

        ExceptToken([ttString]);
        AParam.ParamName := lToken;
        AParam.ParamName[1] := UpCase(AParam.ParamName[1]);
        AParam.ParamName := 'A' + AParam.ParamName;

        ExceptToken([ATokenType]);
      end else
        ExceptToken([ATokenType], False);
    end;

  begin

    lType := lToken;

    ExceptToken([ttString]);
    lCodeItem := TSciGen.TCodeItem.Create(lRes.Code);
    lCodeItem.ReturnType := lToken;

    if lType = 'get' then
      lCodeItem.CodeType := ctGet
    else
      if lType = 'set' then
        lCodeItem.CodeType := ctSet
      else
        if lType = 'fun' then
        begin

          if lCodeItem.ReturnType = 'void' then
            lCodeItem.CodeType := ctProc
          else
            lCodeItem.CodeType := ctFunc;

        end;

    ExceptToken([ttString]);
    lCodeItem.ItemName := lToken;

    ExceptToken([ttEqual]);

    ExceptToken([ttInt]);
    lCodeItem.ItemIndex := lToken;
    lCodeItem.ConstName := Format('SCI_%s', [UpperCase(lCodeItem.ItemName)]);

    if lCodeItem.ItemIndex <> '0' then
      AddConst(lCodeItem.ConstName, lCodeItem.ItemIndex, False, 2);

    ExceptToken([ttBraceOpen]);

    ReadParam(ttComma, lCodeItem.Param1);
    ReadParam(ttBraceClose, lCodeItem.Param2);

    lCodeItem.Doc := GetDoc(4, True);
    lRes.AddCodeItem(lCodeItem);
  end;

  procedure ParseEnum;
  var
    lCodeItem: TSciGen.TCodeItem;
  begin
    lCodeItem := TSciGen.TCodeItem.Create(lRes.Code);
    lCodeItem.CodeType := ctEnu;

    ExceptToken([ttString]);
    lCodeItem.ItemName := lToken;

    ExceptToken([ttEqual]);
    ExceptToken([ttString]);

    repeat
      lCodeItem.EnumNames.Add(lToken);

      ExceptToken([ttString, ttNull]);
    until lTokenType <> ttString;

    lRes.AddCodeItem(lCodeItem);
  end;

  function cleanHTML(s: String): String;
  begin
    s := StringReplace(s, '&', '&amp;', [rfReplaceAll]);
    s := StringReplace(s, '<', '&lt;', [rfReplaceAll]);
    s := StringReplace(s, '>', '&gt;', [rfReplaceAll]);
    Result := s;
  end;

  procedure ParseLine;
  begin
    if not NextToken then
    begin
      lDocComment := '';

      if lLastLineVar then
      begin
        lRes.ConstDef := lRes.ConstDef + sLineBreak;

        lLastLineVar := False;
      end;
    end else
      case lTokenType of
      ttComment:
        ; // ignore

      ttDocComment:
        if lDocComment = '' then
          lDocComment := lDocComment + '/// <summary>' + cleanHTML(lToken) + sLineBreak
        else
          lDocComment := lDocComment + '/// ' + cleanHTML(lToken) + sLineBreak;

      ttString:
        if lToken = 'cat' then
          ParseCat
        else if lToken = 'val' then
          ParseVal
        else if lToken = 'enu' then
          ParseEnum
        else if lToken = 'ali' then
          ParseAlias
        else if lToken = 'lex' then
          // todo:
        else if lToken = 'evt' then
          // todo:
        else if (lToken = 'fun') or (lToken = 'get') or (lToken = 'set') then
          ParseCode
        else
          ; // ignore future feature types
      end;

    SkipLine;
  end;

  procedure ParseFile(AFileName: String);
  begin
    if (AFileName = '') or not FileExists(AFileName) then
      Exit;

    lLine := '';
    lLineIdx := 0;

    lToken := '';
    lTokenType := ttNull;
    lTokenIdx := 1;

    lLastLineVar := False;

    lIn.LoadFromFile(AFileName);

    while NextLine do
      ParseLine;

  end;

begin
  Result := TSciGen.Create;
  try
    lRes := Result;

    lIn := TStringList.Create;
    try
      for lIFaceFile in ASciIFaceFiles do
        ParseFile(lIFaceFile);
      ParseFile(ASciIFaceFileCustom);

      Result.SecondPass;
    finally
      lIn.Free;
    end;
  except
    Result.Free;

    raise;
  end;
end;

{ TSciIFace }

function TransType(AType: String): String;
begin
  AType := TSciGen.NormalizeTypeName(AType);

  if SameText(AType, 'int') or SameText(AType, 'keymod') then
    Result := 'Integer'
  else
  if SameText(AType, 'position') or SameText(AType, 'line') then
    Result := 'NativeInt'
  else
  if SameText(AType, 'stringresult') then
    Result := 'PAnsiChar'
  else
  if SameText(AType, 'string') or SameText(AType, 'String') then
    Result := 'UnicodeString'
  else
  if SameText(AType, 'char') or SameText(AType, 'Char') then
    Result := 'AnsiChar'
  else
  if SameText(AType, 'pointer') or SameText(AType, 'Pointer') then
    Result := 'Pointer'
  else
  if SameText(AType, 'textrange') then
    Result := 'PDSciTextRange'
  else
  if SameText(AType, 'textrangefull') then
    Result := 'PDSciTextRangeFull'
  else
  if SameText(AType, 'formatrange') then
    Result := 'PDSciRangeToFormat'
  else
  if SameText(AType, 'formatrangefull') then
    Result := 'PDSciRangeToFormatFull'
  else
  if SameText(AType, 'findtext') then
    Result := 'PDSciTextToFind'
  else
  if SameText(AType, 'findtextfull') then
    Result := 'PDSciTextToFindFull'
  else
  if SameText(AType, 'colour') then
    Result := 'TColor'
  else
  if SameText(AType, 'colouralpha') then
    Result := 'TDSciColourAlpha'
  else
  if SameText(AType, 'bool') then
    Result := 'Boolean'
  else
  if SameText(AType, 'cell') then
    Result := 'TDSciCell'
  else
  if SameText(AType, 'cells') then
    Result := 'TDSciCells'
  else
    Result := AType;
//    raise Exception.CreateFmt('Type "%s" must by custom-handled!');
end;

function TSciGen.GetCodeParams(const ACodeItem: TCodeItem): String;

  function GetParamStr(AParam: TCodeParam): String;
  begin
    Result := Format('%s: %s', [AParam.ParamName, TransType(AParam.ParamType)]);
  end;

begin
  if not ACodeItem.Param1.IsSet and not ACodeItem.Param2.IsSet then
    Exit('');

  if ACodeItem.Param1.IsSet and ACodeItem.Param2.IsSet then
    Exit(Format('(%s; %s)', [
      GetParamStr(ACodeItem.Param1),
      GetParamStr(ACodeItem.Param2)
    ]));

  if ACodeItem.Param1.IsSet then
    Exit(Format('(%s)', [GetParamStr(ACodeItem.Param1)]));

  if ACodeItem.Param2.IsSet then
    Exit(Format('(%s)', [GetParamStr(ACodeItem.Param2)]));
end;

function TSciGen.TryResolveEnumType(const AType: String; out AResolvedType: String;
  out AIsSet: Boolean): Boolean;
var
  lBaseType: String;
  lCodeItem: TCodeItem;

  function IsKnownNonEnumType(const AName: String): Boolean;
  begin
    Result :=
      SameText(AName, 'TDSciDocument') or
      SameText(AName, 'TDSciColourAlpha') or
      SameText(AName, 'TDSciChar') or
      SameText(AName, 'TDSciChars') or
      SameText(AName, 'TDSciStyle') or
      SameText(AName, 'TDSciStyles') or
      SameText(AName, 'TDSciCell') or
      SameText(AName, 'TDSciCells') or
      SameText(AName, 'TDSciCharacterRange') or
      SameText(AName, 'TDSciCharacterRangeFull') or
      SameText(AName, 'TDSciTextRange') or
      SameText(AName, 'TDSciTextRangeFull') or
      SameText(AName, 'TDSciTextToFind') or
      SameText(AName, 'TDSciTextToFindFull') or
      SameText(AName, 'TDSciRangeToFormat') or
      SameText(AName, 'TDSciRangeToFormatFull') or
      SameText(AName, 'TDSciSCNotification');
  end;

  function IsExactEnumType(const AName: String): Boolean;
  var
    lItem: TCodeItem;
  begin
    Result := False;
    for lItem in Code do
      if (lItem.CodeType = ctEnu) and
        (SameText(lItem.ItemName, AName) or SameText(lItem.GetEnumItemName, AName))
      then
        Exit(True);
  end;
begin
  AResolvedType := NormalizeTypeName(AType);
  AIsSet := False;

  if AResolvedType = '' then
    Exit(False);

  if EndsText('Set', AResolvedType) and not IsExactEnumType(AResolvedType) then
  begin
    AIsSet := True;
    lBaseType := Copy(AResolvedType, 1, Length(AResolvedType) - Length('Set'));
  end
  else
    lBaseType := AResolvedType;

  if SameText(lBaseType, 'Pointer') or
    SameText(lBaseType, 'String') or
    SameText(lBaseType, 'Char') or
    SameText(lBaseType, 'UnicodeString') or
    SameText(lBaseType, 'AnsiString') or
    SameText(lBaseType, 'AnsiChar') or
    SameText(lBaseType, 'Integer') or
    StartsText('TDScintilla', lBaseType)
  then
    Exit(False);

  Result := False;
  for lCodeItem in Code do
    if (lCodeItem.CodeType = ctEnu) and
      (SameText(lCodeItem.ItemName, lBaseType) or SameText(lCodeItem.GetEnumItemName, lBaseType))
    then
    begin
      lBaseType := lCodeItem.GetEnumItemName;
      Result := True;
      Break;
    end;

  if (not Result) and StartsText('TDSci', lBaseType) and not IsKnownNonEnumType(lBaseType) then
    Result := True;

  if not Result then
    Exit;

  if AIsSet and (GetValue(Copy(lBaseType, Length('TDSci') + 1, MaxInt), 'EnumSet') <> '1') then
    Exit(False);

  AResolvedType := lBaseType;
  if AIsSet then
    AResolvedType := AResolvedType + 'Set';
end;

class function TSciGen.GetIsCustomFile(AName: String): Boolean;
begin
  Result := FileExists(GetCustomFile(AName));
end;

class function TSciGen.GetValue(AName, AFeature: String): String;
var
  lVal: String;
  lSL: TStringList;
begin
  EnsureFeaturesLoaded;

  lVal := _FeatureSL.Values[AName];
  if lVal = '' then
    Exit('');

  lSL := TStringList.Create;
  try
    lSL.Delimiter := '|';
    lSL.StrictDelimiter := True;
    lSL.NameValueSeparator := '~';

    lSL.DelimitedText := lVal;

    Result := lSL.Values[AFeature];

  finally
    lSL.Free;
  end;
end;

procedure TSciGen.SecondPass;
var
  lItem: TCodeItem;
  lIdx: Integer;
  lProp: TPair<String, TCodePropItem>;
  lPubDef: string;
  lEnum: String;
  lSeenEnumValues: TStringList;

  function GetIsDisabledCode: String;
  begin
    if GetValue(lItem.ItemName, 'Disabled') = '1' then
      Result := '// '
    else
      Result := '';
  end;

  function GetAccessorParamCount(ACode: TCodeItem): Integer; forward;
  function GetDefinedAccessorParam(ACode: TCodeItem;
    AIndex: Integer): TCodeParam; forward;

  function GetReturnProp: String;
  begin
    if lProp.Value.GetCode <> nil then
      Result := TransType(lProp.Value.GetCode.ReturnType)
    else
      if lProp.Value.SetCode <> nil then
        Result := TransType(
          GetDefinedAccessorParam(lProp.Value.SetCode,
            GetAccessorParamCount(lProp.Value.SetCode)).ParamType)
      else
        RaiseLastOSError;

  end;

  function GetAccessorParamCount(ACode: TCodeItem): Integer;
  begin
    Result := 0;
    if (ACode <> nil) and ACode.Param1.IsSet then
      Inc(Result);
    if (ACode <> nil) and ACode.Param2.IsSet then
      Inc(Result);
  end;

  function GetAccessorParam(ACode: TCodeItem; AIndex: Integer): TCodeParam;
  begin
    case AIndex of
      1:
        Result := ACode.Param1;
      2:
        Result := ACode.Param2;
    else
      raise ERangeError.CreateFmt('Unsupported property parameter index: %d', [AIndex]);
    end;
  end;

  function GetDefinedAccessorParam(ACode: TCodeItem; AIndex: Integer): TCodeParam;
  var
    lLogicalIndex: Integer;
  begin
    // Scintilla iface setters may omit the first native slot and place the only
    // Delphi-visible value into Param2, for example SetMarginLeft(, int pixelWidth).
    lLogicalIndex := 0;

    if (ACode <> nil) and ACode.Param1.IsSet then
    begin
      Inc(lLogicalIndex);
      if lLogicalIndex = AIndex then
        Exit(ACode.Param1);
    end;

    if (ACode <> nil) and ACode.Param2.IsSet then
    begin
      Inc(lLogicalIndex);
      if lLogicalIndex = AIndex then
        Exit(ACode.Param2);
    end;

    raise ERangeError.CreateFmt(
      'Unsupported logical property parameter index: %d', [AIndex]);
  end;

  function IsReservedPropertyName(const AName: String): Boolean;
  begin
    Result := SameText(AName, 'Property') or SameText(AName, 'Length');
  end;

  function IsCompatibleProperty: Boolean;
  var
    lGetCount: Integer;
    lSetCount: Integer;
    lIdx: Integer;
  begin
    Result := False;

    if IsReservedPropertyName(lProp.Value.ItemName) then
      Exit;

    if Assigned(lProp.Value.GetCode) and SameText(lProp.Value.ItemName, lProp.Value.GetCode.ItemName) then
      Exit;

    if Assigned(lProp.Value.SetCode) and SameText(lProp.Value.ItemName, lProp.Value.SetCode.ItemName) then
      Exit;

    lGetCount := GetAccessorParamCount(lProp.Value.GetCode);
    lSetCount := GetAccessorParamCount(lProp.Value.SetCode);

    if Assigned(lProp.Value.GetCode) and Assigned(lProp.Value.SetCode) then
    begin
      if (lGetCount = 0) and (lSetCount = 1) then
        Exit(SameText(
          TransType(lProp.Value.GetCode.ReturnType),
          TransType(GetDefinedAccessorParam(lProp.Value.SetCode, lSetCount).ParamType)
        ));

      if lSetCount <> lGetCount + 1 then
        Exit;

      for lIdx := 1 to lGetCount do
        if not SameText(
          TransType(GetDefinedAccessorParam(lProp.Value.GetCode, lIdx).ParamType),
          TransType(GetDefinedAccessorParam(lProp.Value.SetCode, lIdx).ParamType)
        ) then
          Exit;

      Exit(SameText(
        TransType(lProp.Value.GetCode.ReturnType),
        TransType(GetDefinedAccessorParam(lProp.Value.SetCode, lSetCount).ParamType)
      ));
    end;

    if Assigned(lProp.Value.GetCode) then
      Exit(lGetCount <= 2);

    if Assigned(lProp.Value.SetCode) then
      Exit((lSetCount >= 1) and (lSetCount <= 2));
  end;

  function GetReadProp: String;
  begin
    if lProp.Value.GetCode = nil then
      Result := ''
    else
      Result := Format(' read %s', [lProp.Value.GetCode.ItemName]);
  end;

  function GetWriteProp: String;
  begin
    if lProp.Value.SetCode = nil then
      Result := ''
    else
      Result := Format(' write %s', [lProp.Value.SetCode.ItemName]);
  end;

  function GetDefaultProp: String;
  var
    lDef: String;
  begin
    if not IsCompatibleProperty then
      Exit('');

    if lProp.Value.GetCode = nil then
      Exit('');

    lDef := GetValue(lProp.Value.GetCode.ItemName, 'DefaultValue');

    if lDef = '' then
      Result := ''
    else
      Result := Format(' default %s', [lDef]);
  end;

  function GetPropParam: String;
  var
    lCode: TCodeItem;
    lParamCount: Integer;
    lLastValueIndex: Integer;
    lParam1: TCodeParam;
    lParam2: TCodeParam;
  begin
    Result := '';

    if not IsCompatibleProperty then
      Exit;

    if Assigned(lProp.Value.GetCode) then
    begin
      lCode := lProp.Value.GetCode;
      lParamCount := GetAccessorParamCount(lCode);
    end
    else
    begin
      lCode := lProp.Value.SetCode;
      lParamCount := GetAccessorParamCount(lCode) - 1;
    end;

    if lParamCount <= 0 then
      Exit;

    lLastValueIndex := lParamCount;
    lParam1 := GetDefinedAccessorParam(lCode, 1);

    if lParamCount = 1 then
      Exit(Format('[%s: %s]', [
        lParam1.ParamName,
        TransType(lParam1.ParamType)
      ]));

    lParam2 := GetDefinedAccessorParam(lCode, lLastValueIndex);
    Result := Format('[%s: %s; %s: %s]', [
      lParam1.ParamName,
      TransType(lParam1.ParamType),
      lParam2.ParamName,
      TransType(lParam2.ParamType)
    ]);

  end;

  function GetPropFeature(const AFeature: String): String;
  begin
    Result := '';

    if Assigned(lProp.Value.GetCode) then
      Result := GetValue(lProp.Value.GetCode.ItemName, AFeature);

    if (Result = '') and Assigned(lProp.Value.SetCode) then
      Result := GetValue(lProp.Value.SetCode.ItemName, AFeature);
  end;

  function IsPublicProp: Boolean;
  begin
    if not IsCompatibleProperty then
      Exit(False);

    Result := (lProp.Value.GetCode = nil) or
      (GetPropParam <> '')
      {lProp.Value.GetCode.Param1.IsSet or
      lProp.Value.GetCode.Param2.IsSet};

    if not Result then
      Result := GetValue(lProp.Value.GetCode.ItemName, 'ForcePublicProp') = '1';
  end;

  function IsHiddenProperty: Boolean;
  begin
    Result := GetPropFeature('HideProperty') = '1';
  end;

  function GetPropertyDoc: String;
  begin
    Result := '';

    if Assigned(lProp.Value.GetCode) and (Trim(lProp.Value.GetCode.Doc) <> '') then
      Exit(lProp.Value.GetCode.Doc);

    if Assigned(lProp.Value.SetCode) and (Trim(lProp.Value.SetCode.Doc) <> '') then
      Exit(lProp.Value.SetCode.Doc);
  end;

  procedure AddEnumCode(S: String);
  begin
    EnumsCodeDecl := EnumsCodeDecl + GetIsDisabledCode + S + sLineBreak;
  end;

begin


  for lItem in Self.Code do
    if lItem.CodeType = ctEnu then
    begin
      EnumsDef := EnumsDef + Format('  %s%s = (%s', [
          GetIsDisabledCode, lItem.GetEnumItemName, sLineBreak
        ]);

      EnumNames.Add(lItem.GetEnumItemName);



      // <ENUM CODE - To Int>
      lEnum := Format('%sfunction %sToInt(AEnum: %s): Integer;%s', [
        GetIsDisabledCode, lItem.GetEnumItemName, lItem.GetEnumItemName, sLineBreak
      ]);
      EnumsCodeDef := EnumsCodeDef + lEnum;

      AddEnumCode(Trim(lEnum));
      AddEnumCode(       'begin');
      AddEnumCode(       '  case AEnum of');

      for lIdx := 0 to lItem.EnumVals.Count - 1 do
      begin
        AddEnumCode(Format('  %s', [lItem.GetEnumNameVal(lIdx, ':', ':')]));
        AddEnumCode(Format('    Result := %s;', [lItem.EnumVals[lIdx].ConstValue]));
      end;

      AddEnumCode(       '  else');
      AddEnumCode(Format('    Result := %s;', [lItem.EnumVals[0].ConstValue]));
      AddEnumCode(       '  end;');

      AddEnumCode(      'end;');
      AddEnumCode(      '');
      // </ENUM CODE>



      // <ENUM CODE - From Int>
      lEnum := Format('%sfunction %sFromInt(AEnum: Integer): %s;%s', [
        GetIsDisabledCode, lItem.GetEnumItemName, lItem.GetEnumItemName, sLineBreak
      ]);
      EnumsCodeDef := EnumsCodeDef + lEnum;

      AddEnumCode(Trim(lEnum));
      AddEnumCode(       'begin');
      AddEnumCode(       '  case AEnum of');

      lSeenEnumValues := TStringList.Create;
      try
        lSeenEnumValues.CaseSensitive := False;
        lSeenEnumValues.Sorted := False;
        lSeenEnumValues.Duplicates := dupIgnore;

        for lIdx := 0 to lItem.EnumVals.Count - 1 do
          if lSeenEnumValues.IndexOf(lItem.EnumVals[lIdx].ConstValue) < 0 then
          begin
            lSeenEnumValues.Add(lItem.EnumVals[lIdx].ConstValue);
            AddEnumCode(Format('  %s:', [lItem.EnumVals[lIdx].ConstValue]));
            AddEnumCode(Format('    Result := %s', [lItem.GetEnumNameVal(lIdx, ';', ';')]));
          end;
      finally
        lSeenEnumValues.Free;
      end;

      AddEnumCode(       '  else');
      AddEnumCode(Format('    Result := %s;', [lItem.GetEnumNameVal(0, ';', ';')]));
      AddEnumCode(       '  end;');

      AddEnumCode(       'end;');
      AddEnumCode(       '');
      // </ENUM CODE>

      for lIdx := 0 to lItem.EnumVals.Count - 1 do
        EnumsDef := EnumsDef + Format('  %s  %s%s', [
          GetIsDisabledCode, lItem.GetEnumNameVal(lIdx), sLineBreak]);

      EnumsDef := EnumsDef + Format('  %s);%s', [
          GetIsDisabledCode,  sLineBreak
        ]);

      if GetValue(lItem.ItemName, 'EnumSet') = '1' then
      begin
        EnumsDef := EnumsDef + Format('  %s%sSet = set of %s;%s', [
            GetIsDisabledCode, lItem.GetEnumItemName, lItem.GetEnumItemName, sLineBreak
          ]);

        EnumNames.Add(lItem.GetEnumItemName + 'Set');

        // <ENUM SET CODE - To Int>
        lEnum := Format('%sfunction %sSetToInt(AEnum: %sSet): Integer;%s', [
          GetIsDisabledCode, lItem.GetEnumItemName, lItem.GetEnumItemName, sLineBreak
        ]);
        EnumsCodeDef := EnumsCodeDef + lEnum;

        AddEnumCode(Trim(lEnum));
        AddEnumCode(       'var');
        AddEnumCode(Format('  lEnum: %s;', [lItem.GetEnumItemName]));
        AddEnumCode(       'begin');
        AddEnumCode(       '  Result := 0;');
        AddEnumCode(       '');
        AddEnumCode(       '  for lEnum in AEnum do');
        AddEnumCode(Format('    Result := Result or %sToInt(lEnum);', [lItem.GetEnumItemName]));
        AddEnumCode(       'end;');
        AddEnumCode(       '');
        // </ENUM STE CODE>

        // <ENUM SET CODE - From Int>
        lEnum := Format('%sfunction %sSetFromInt(AEnum: Integer): %sSet;%s', [
          GetIsDisabledCode, lItem.GetEnumItemName, lItem.GetEnumItemName, sLineBreak
        ]);
        EnumsCodeDef := EnumsCodeDef + lEnum;

        AddEnumCode(Trim(lEnum));
        AddEnumCode(       'var');
        AddEnumCode(Format('  lEnum: %s;', [lItem.GetEnumItemName]));
        AddEnumCode(       'begin');
        AddEnumCode(       '  Result := [];');
        AddEnumCode(       '');
        AddEnumCode(Format('  for lEnum := Low(%s) to High(%s) do', [lItem.GetEnumItemName, lItem.GetEnumItemName]));
        AddEnumCode(Format('    if AEnum and %sToInt(lEnum) <> 0 then', [lItem.GetEnumItemName]));
        AddEnumCode(       '      Include(Result, lEnum);');
        AddEnumCode(       'end;');
        AddEnumCode(       '');
        // </ENUM SET CODE>
      end;

      EnumsDef := EnumsDef + sLineBreak;
    end;

  for lProp in Props do
  begin
    if not IsCompatibleProperty then
      Continue;

    if IsHiddenProperty then
      Continue;

    lPubDef :=
        GetPropertyDoc +
        Format('    %sproperty %s%s: %s%s%s%s;%s', [
          GetIsDisabledCode,
          lProp.Value.ItemName,
          GetPropParam,
          GetReturnProp,
          GetReadProp,
          GetWriteProp,
          GetDefaultProp,
          sLineBreak
        ]);

    if IsPublicProp then
      PublicPropertesDef := PublicPropertesDef + lPubDef
    else
      PublishedPropertesDef := PublishedPropertesDef + lPubDef;

  end;
end;

class procedure TSciGen.SetValue(AName, AFeature, AValue: String);
var
  lSL: TStringList;
begin
  EnsureFeaturesLoaded;

  lSL := TStringList.Create;
  try
    lSL.Delimiter := '|';
    lSL.StrictDelimiter := True;
    lSL.NameValueSeparator := '~';

    lSL.DelimitedText := _FeatureSL.Values[AName];

    lSL.Values[AFeature] := AValue;

    _FeatureSL.Values[AName] := lSL.DelimitedText;

  finally
    lSL.Free;
  end;
end;

procedure TSciGen.AddCodeItem(const ACodeItem: TCodeItem; AAddDoc: Boolean);
var
  lNameParams: String;
  lDef, lCode: String;
  lCustomFile: string;
  lCustomStr: TStringList;
  lCustomStrIdx: Integer;
  lProperty: TCodePropItem;

  procedure ApplyCustomSignature(const ASignature: String);
  var
    lSignature: String;
    lParamsText: String;
    lParamType: String;
    lParamNames: TStringList;
    lParamChunks: TStringList;
    lChunk: String;
    lName: String;
    lOpenIdx: Integer;
    lCloseIdx: Integer;
    lColonIdx: Integer;

    procedure ClearParam(AParam: TCodeParam);
    begin
      AParam.IsSet := False;
      AParam.FParamType := '';
      AParam.ParamName := '';
    end;

    procedure AssignParam(AParam: TCodeParam; const AName, AType: String);
    begin
      AParam.IsSet := True;
      AParam.ParamName := Trim(AName);
      AParam.FParamType := Trim(AType);
    end;

    procedure AddParam(const AName, AType: String);
    begin
      if not ACodeItem.Param1.IsSet then
        AssignParam(ACodeItem.Param1, AName, AType)
      else if not ACodeItem.Param2.IsSet then
        AssignParam(ACodeItem.Param2, AName, AType);
    end;

  begin
    lSignature := Trim(ASignature);
    if lSignature = '' then
      Exit;

    ClearParam(ACodeItem.Param1);
    ClearParam(ACodeItem.Param2);

    if StartsText('function ', lSignature) then
    begin
      lColonIdx := LastDelimiter(':', lSignature);
      if lColonIdx > 0 then
      begin
        ACodeItem.FReturnType := Trim(Copy(lSignature, lColonIdx + 1, MaxInt));
        if (ACodeItem.FReturnType <> '') and
          (ACodeItem.FReturnType[Length(ACodeItem.FReturnType)] = ';')
        then
          Delete(ACodeItem.FReturnType, Length(ACodeItem.FReturnType), 1);
      end;
    end
    else if StartsText('procedure ', lSignature) then
      ACodeItem.FReturnType := 'void';

    lOpenIdx := Pos('(', lSignature);
    if lOpenIdx = 0 then
      Exit;

    lCloseIdx := LastDelimiter(')', lSignature);
    if lCloseIdx <= lOpenIdx then
      Exit;

    lParamsText := Copy(lSignature, lOpenIdx + 1, lCloseIdx - lOpenIdx - 1);
    if Trim(lParamsText) = '' then
      Exit;

    lParamChunks := TStringList.Create;
    lParamNames := TStringList.Create;
    try
      lParamChunks.Delimiter := ';';
      lParamChunks.StrictDelimiter := True;
      lParamChunks.DelimitedText := lParamsText;

      lParamNames.Delimiter := ',';
      lParamNames.StrictDelimiter := True;

      for lChunk in lParamChunks do
      begin
        lSignature := Trim(lChunk);
        if StartsText('const ', lSignature) then
          Delete(lSignature, 1, Length('const '))
        else if StartsText('var ', lSignature) then
          Delete(lSignature, 1, Length('var '))
        else if StartsText('out ', lSignature) then
          Delete(lSignature, 1, Length('out '))
        else if StartsText('constref ', lSignature) then
          Delete(lSignature, 1, Length('constref '));

        lColonIdx := LastDelimiter(':', lSignature);
        if lColonIdx = 0 then
          Continue;

        lParamType := Trim(Copy(lSignature, lColonIdx + 1, MaxInt));
        lParamNames.DelimitedText := Copy(lSignature, 1, lColonIdx - 1);

        for lName in lParamNames do
          AddParam(Trim(lName), lParamType);
      end;
    finally
      lParamNames.Free;
      lParamChunks.Free;
    end;
  end;

  function GetSendParamValue(AParam: TCodeParam): String;
  var
    lEnumType: String;
    lIsEnumSet: Boolean;
  begin
    if not AParam.IsSet then
      Exit('0');

    if TryResolveEnumType(AParam.ParamType, lEnumType, lIsEnumSet) then
      Exit(Format('%sToInt(%s)', [lEnumType, AParam.ParamName]));

    if SameText(AParam.ParamType, 'bool') then
      Result := Format('Ord(%s)', [AParam.ParamName])
    else
    if SameText(AParam.ParamType, 'colour') or SameText(AParam.ParamType, 'colouralpha') then
      Result := Format('Integer(%s)', [AParam.ParamName])
    else
    if SameText(AParam.ParamType, 'pointer') or SameText(AParam.ParamType, 'Pointer') then
      Result := Format('NativeInt(%s)', [AParam.ParamName])
    else
      Result := AParam.ParamName;
  end;

  function GetSendParamStr(AParam: TCodeParam): String;
  var
    lCastType: String;
  begin
    if not AParam.IsSet then
      Exit('0');

    if AParam.FIdx = 1 then
      lCastType := 'WPARAM'
    else
      lCastType := 'LPARAM';

    Result := Format('%s(%s)', [lCastType, GetSendParamValue(AParam)]);
  end;

  function GetSend: String;
  begin
    Result := Format('SendEditor(%s, %s, %s)', [
      ACodeItem.ConstName,
      GetSendParamStr(ACodeItem.Param1),
      GetSendParamStr(ACodeItem.Param2)
    ]);
  end;

  function GetSendRet: String;
  var
    lEnumType: String;
    lIsEnumSet: Boolean;
  begin
    if TryResolveEnumType(ACodeItem.ReturnType, lEnumType, lIsEnumSet) then
      Result := Format('%sFromInt(%s)', [lEnumType, GetSend])
    else
    if SameText(ACodeItem.ReturnType, 'bool') then
      Result := Format('Boolean(%s)', [GetSend])
    else
    if SameText(ACodeItem.ReturnType, 'colour') then
      Result := Format('TColor(%s)', [GetSend])
    else
    if SameText(ACodeItem.ReturnType, 'colouralpha') then
      Result := Format('TDSciColourAlpha(Integer(%s))', [GetSend])
    else
    if SameText(ACodeItem.ReturnType, 'pointer') or SameText(ACodeItem.ReturnType, 'Pointer') then
      Result := Format('Pointer(%s)', [GetSend])
    else
      Result := GetSend;
  end;

  function GetIsDisabledCode: String;
  begin
    if GetValue(ACodeItem.ItemName, 'Disabled') = '1' then
      Result := '// '
    else
      Result := '';
  end;

  function IsForceProtected: Boolean;
  begin
    Result := GetValue(ACodeItem.ItemName, 'ForceProtected') = '1';
  end;

begin
  Code.Add(ACodeItem);

  if ACodeItem.CodeType = ctEnu then
  begin
    FLastEnum := ACodeItem;
  end;

  if AAddDoc then
    lDef := ACodeItem.Doc
  else
    lDef := '';

  lCode := '';

  lCustomFile := GetCustomFile(ACodeItem.ItemName);
  if FileExists(lCustomFile) then
  begin

    lCustomStr := TStringList.Create;
    try
      lCustomStr.LoadFromFile(lCustomFile);
      ApplyCustomSignature(lCustomStr[0]);

      lDef := lDef + '    ' + GetIsDisabledCode + lCustomStr[0] + sLineBreak + sLineBreak;
      lCustomStr.Delete(0);

      for lCustomStrIdx := 0 to lCustomStr.Count - 1 do
        lCustomStr[lCustomStrIdx] := GetIsDisabledCode + lCustomStr[lCustomStrIdx];

      lCode := Format(lCustomStr.Text, ['%s']);
    finally
      lCustomStr.Free;
    end;

  end else
  begin
    lNameParams := Format('%s%s',
      [ACodeItem.ItemName, GetCodeParams(ACodeItem)]);

    case ACodeItem.CodeType of
    ctProc, ctSet:
      begin
        lDef := lDef + Format('    %sprocedure %s;%s%s', [
            GetIsDisabledCode, lNameParams, sLineBreak, sLineBreak
          ]);

        lCode := lCode + Format('%sprocedure %%s.%s;%s', [
            GetIsDisabledCode, lNameParams, sLineBreak
          ]);

        lCode := lCode + GetIsDisabledCode + 'begin' + sLineBreak;

        lCode := lCode + GetIsDisabledCode + Format('  %s;', [GetSend]) + sLineBreak;

        lCode := lCode + GetIsDisabledCode + 'end;' + sLineBreak + sLineBreak;
      end;

    ctFunc, ctGet:
      begin
        lDef := lDef + Format('    %sfunction %s: %s;%s%s', [
            GetIsDisabledCode, lNameParams, TransType(ACodeItem.ReturnType), sLineBreak, sLineBreak
          ]);

        lCode := lCode + Format('%sfunction %%s.%s: %s;%s', [
          GetIsDisabledCode, lNameParams, TransType(ACodeItem.ReturnType), sLineBreak
        ]);

        lCode := lCode + GetIsDisabledCode + 'begin' + sLineBreak;
        lCode := lCode + GetIsDisabledCode + Format('  Result := %s;', [GetSendRet]) + sLineBreak;
        lCode := lCode + GetIsDisabledCode + 'end;' + sLineBreak + sLineBreak;
      end;

    end;
  end;

  if ACodeItem.CodeType in [ctGet, ctSet] then
  begin
    if not Props.TryGetValue(ACodeItem.GetPropertyName, lProperty) then
    begin
      lProperty.GetCode := nil;
      lProperty.SetCode := nil;
      lProperty.ItemName := ACodeItem.GetPropertyName;
    end;

    case ACodeItem.CodeType of
    ctGet:
      lProperty.GetCode := ACodeItem;

    ctSet:
      lProperty.SetCode := ACodeItem;
    end;

    Props.AddOrSetValue(ACodeItem.GetPropertyName, lProperty);
  end;

  case ACodeItem.CodeType of
  ctProc, ctFunc:
    begin
      if IsForceProtected then
      begin
        UnsafeDef := UnsafeDef + lDef;
        UnsafeCode := UnsafeCode + lCode;
      end
      else
      begin
        PublicDef := PublicDef + lDef;
        PublicCode := PublicCode + lCode;
      end;
    end;

  ctSet, ctGet:
    begin
      if IsForceProtected then
      begin
        UnsafeDef := UnsafeDef + lDef;
        UnsafeCode := UnsafeCode + lCode;
      end
      else
      begin
        ProtectedDef := ProtectedDef + lDef;
        ProtectedCode := ProtectedCode + lCode;
      end;
    end;
  end;
end;

constructor TSciGen.Create;
begin
  Consts := TConstsList.Create;
  Code := TCodeList.Create;
  Props := TCodeProps.Create;
  EnumNames := TStringList.Create;
end;

destructor TSciGen.Destroy;
begin
  EnumNames.Free;
  Consts.Free;
  Code.Free;
  Props.Free;

  inherited Destroy;
end;

procedure _SaveFS;
begin
  if not _FeatureSLLoaded then
    Exit;

  _FeatureSL.SaveToFile(GetCustomFile(rsFeaturesFile));
end;

{ TSciGen.TCodeList }

procedure TSciGen.TCodeList.Notify(const Item: TCodeItem;
  Action: TCollectionNotification);
begin
  inherited;

  if Action = cnRemoved then
    if Item.Owner = Self then
      Item.Free;
end;

{ TSciGen.TCodeItem }

function TSciGen.TCodeItem.AddEnumValue(AItem: TConstItem): Boolean;
var
  lPrefix: String;
begin
  lPrefix := IsEnum(AItem.ConstName);

  Result := lPrefix <> '';

  if Result then
  begin
    if (TSciGen.GetValue(ItemName, 'EnumSet') = '1') and
      (StrToInt(AItem.ConstValue) = 0)
    then
      Exit;

    EnumVals.Add(AItem);
  end;
end;

constructor TSciGen.TCodeItem.Create(AOwner: TCodeList);
begin
  inherited Create;

  Owner := AOwner;
  EnumVals := TSciEnumVals.Create;
  EnumNames := TSciEnums.Create;

  Param1 := TCodeParam.Create(Self, 1);
  Param2 := TCodeParam.Create(Self, 2);
end;

destructor TSciGen.TCodeItem.Destroy;
begin
  EnumNames.Free;
  EnumVals.Free;

  inherited Destroy;
end;

function TSciGen.TCodeItem.GetEnumItemName: String;
begin
  if SameText(ItemName, 'Lexer') then
    Exit('TDSciLexerId');

  Result := 'TDSci' + ItemName;
end;

function TSciGen.TCodeItem.GetEnumNameVal(AIndex: Integer; AChar1: Char = ' '; AChar2: Char = ','): String;
var
  lEnumValueName: String;
begin
  if EnumVals[AIndex].ConstAlias <> '' then
    lEnumValueName := EnumVals[AIndex].ConstAlias
  else
    lEnumValueName := Copy(
      EnumVals[AIndex].ConstName,
      Length(IsEnum(EnumVals[AIndex].ConstName)) + 1,
      MaxInt
    );

  Result :=
    GetEnumPrefix +
    lEnumValueName +
    IfThen(AIndex = EnumVals.Count - 1, AChar1, AChar2);

  Result :=
    Result +
    StringOfChar(' ', 40 - Length(Result)) +
    Format('/// <summary>%s = %s%</summary>', [EnumVals[AIndex].ConstName, EnumVals[AIndex].ConstValue]);
end;

function TSciGen.TCodeItem.GetEnumPrefix: String;
var
  lIdx: Integer;
begin
  if CodeType <> ctEnu then
    RaiseLastOSError; // :[=hahaha], boring day...

  Result := 'sc';

  for lIdx := 1 to Length(ItemName) - 1 do
    if TCharacter.IsUpper(ItemName[lIdx]) then
      Result := Result + ItemName[lIdx];

  Result := LowerCase(Result);
end;

function TSciGen.TCodeItem.GetPropertyName: String;
begin
  case CodeType of
  ctGet:
    begin
      Result := ItemName;
      Delete(Result, Pos('Get', ItemName), 3);
    end;

  ctSet:
    begin
      Result := ItemName;
      Delete(Result, Pos('Set', ItemName), 3);
    end;
  else
    RaiseLastOSError;
  end;
end;

function TSciGen.TCodeItem.GetReturnType: String;
var
  lTypeName: String;
  lIsSet: Boolean;
  lCodeItem: TCodeItem;
begin
  lTypeName := TSciGen.NormalizeTypeName(TSciGen.GetValue(ItemName, 'ReturnEnum'));

  if lTypeName = '' then
    lTypeName := TSciGen.NormalizeTypeName(FReturnType);

  Result := lTypeName;

  if Result = '' then
    Exit;

  lIsSet := EndsText('Set', Result);
  if lIsSet then
    Delete(Result, Length(Result) - Length('Set') + 1, Length('Set'));

  for lCodeItem in Owner do
    if (lCodeItem.CodeType = ctEnu) and
      (SameText(lCodeItem.ItemName, Result) or SameText(lCodeItem.GetEnumItemName, Result))
    then
    begin
      Result := lCodeItem.GetEnumItemName;
      if lIsSet then
        Result := Result + 'Set';
      Exit;
    end;

  Result := lTypeName;
end;

function TSciGen.TCodeItem.IsEnum(AName: String): String;
var
  lName: String;
begin
  for lName in EnumNames do
    if SameText(lName, LeftStr(AName, Length(lName))) then
      Exit(lName);

  Result := '';
end;

{ TSciGen.TCodeParam }

constructor TSciGen.TCodeParam.Create(AOwner: TCodeItem; AIdx: Integer);
begin
  inherited Create;

  Owner := AOwner;
  FIdx := AIdx;
end;

function TSciGen.TCodeParam.GetParamType: String;
var
  lTypeName: String;
  lIsSet: Boolean;
  lCodeItem: TCodeItem;
begin
  lTypeName := TSciGen.NormalizeTypeName(
    TSciGen.GetValue(Owner.ItemName, Format('Param%dEnum', [FIdx]))
  );

  if lTypeName = '' then
    lTypeName := TSciGen.NormalizeTypeName(FParamType);

  Result := lTypeName;

  if Result = '' then
    Exit;

  lIsSet := EndsText('Set', Result);
  if lIsSet then
    Delete(Result, Length(Result) - Length('Set') + 1, Length('Set'));

  for lCodeItem in Owner.Owner do
    if (lCodeItem.CodeType = ctEnu) and
      (SameText(lCodeItem.ItemName, Result) or SameText(lCodeItem.GetEnumItemName, Result))
    then
    begin
      Result := lCodeItem.GetEnumItemName;
      if lIsSet then
        Result := Result + 'Set';
      Exit;
    end;

  Result := lTypeName;
end;

initialization
  _FeatureSL := TStringList.Create;
  SetIFGenBaseDir(ExtractFilePath(ParamStr(0)));

finalization
  _SaveFS;
  _FeatureSL.Free;

end.

