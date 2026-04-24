unit uIFGenRunner;

interface

uses
  Classes, SysUtils, uIFGen;

type
  TSciGenPaths = record
    IFGenDir: String;
    ScintillaIFaceFile: String;
    LexicalStylesIFaceFile: String;
    CustomIFaceFile: String;
    TypesFile: String;
    ApiFile: String;
    ApiIncPrefix: String;
  end;

function ResolveSciGenPaths(const AStartDir: String): TSciGenPaths;
function GenerateScintillaSources(const APaths: TSciGenPaths): TSciGen;

implementation

resourcestring
  rsTKBScintilla = 'TDScintilla';

function NormalizeDir(const ADir: String): String;
begin
  if ADir = '' then
    Result := IncludeTrailingPathDelimiter(GetCurrentDir)
  else
    Result := IncludeTrailingPathDelimiter(ExpandFileName(ADir));
end;

function FindIFGenDir(const AStartDir: String): String;
var
  lDir: String;
  lParentDir: String;
begin
  lDir := NormalizeDir(AStartDir);

  repeat
    if FileExists(lDir + 'Scintilla.iface') and DirectoryExists(lDir + 'CustomCode') then
      Exit(lDir);

    lParentDir := IncludeTrailingPathDelimiter(ExtractFileDir(ExcludeTrailingPathDelimiter(lDir)));
    if SameText(lParentDir, lDir) then
      Break;

    lDir := lParentDir;
  until False;

  raise Exception.CreateFmt('Unable to locate IFGen directory from "%s".', [AStartDir]);
end;

function ResolveSciGenPaths(const AStartDir: String): TSciGenPaths;
var
  lIFGenDir: String;
  lSourceDir: String;
begin
  lIFGenDir := FindIFGenDir(AStartDir);
  lSourceDir := NormalizeDir(lIFGenDir + '..');

  Result.IFGenDir := lIFGenDir;
  Result.ScintillaIFaceFile := lIFGenDir + 'Scintilla.iface';
  Result.LexicalStylesIFaceFile := lIFGenDir + 'LexicalStyles.iface';
  Result.CustomIFaceFile := lIFGenDir + 'DScintilla.iface';
  Result.TypesFile := lSourceDir + 'DScintillaTypes.pas';
  Result.ApiFile := lSourceDir + 'DScintilla.pas';
  Result.ApiIncPrefix := lSourceDir + 'DScintilla';
end;

function ReplaceMarker(AList: TStrings; const AMarkerLineBegin, AMarkerLineEnd: String; ACode: String): Boolean;
var
  lStartIdx: Integer;
  lEndIdx: Integer;
begin
  lStartIdx := 0;
  while (lStartIdx < AList.Count) and (Trim(AList[lStartIdx]) <> AMarkerLineBegin) do
    Inc(lStartIdx);

  Result := lStartIdx < AList.Count;
  if not Result then
    Exit;

  lEndIdx := lStartIdx + 1;
  while (lEndIdx < AList.Count) and (Trim(AList[lEndIdx]) <> AMarkerLineEnd) do
    Inc(lEndIdx);

  Result := lEndIdx < AList.Count;
  if not Result then
    Exit;

  while lEndIdx - lStartIdx > 1 do
  begin
    AList.Delete(lStartIdx + 1);
    Dec(lEndIdx);
  end;

  ACode := StringReplace(ACode, '%s', rsTKBScintilla, [rfReplaceAll]);
  AList.Insert(lStartIdx + 1, '');
  AList.Insert(lStartIdx + 2, ACode);
end;

procedure SaveStringToFile(const AFileName, ACode: String);
begin
  with TStringStream.Create(StringReplace(ACode, '%s', rsTKBScintilla, [rfReplaceAll])) do
  try
    SaveToFile(AFileName);
  finally
    Free;
  end;
end;

function GenerateScintillaSources(const APaths: TSciGenPaths): TSciGen;
var
  lFile: TStringList;
begin
  SetIFGenBaseDir(APaths.IFGenDir);

  Result := GetDelphiCode(
    [APaths.ScintillaIFaceFile, APaths.LexicalStylesIFaceFile],
    APaths.CustomIFaceFile
  );
  try
    lFile := TStringList.Create;
    try
      lFile.LoadFromFile(APaths.TypesFile);
      ReplaceMarker(lFile, '// <scigen-types>', '// </scigen-types>', Result.EnumsDef);
      ReplaceMarker(lFile, '// <scigen>', '// </scigen>', Result.ConstDef);
      ReplaceMarker(lFile, '// <scigen-enum-func-decl>', '// </scigen-enum-func-decl>', Result.EnumsCodeDef);
      ReplaceMarker(lFile, '// <scigen-enum-func-code>', '// </scigen-enum-func-code>', Result.EnumsCodeDecl);
      lFile.SaveToFile(APaths.TypesFile);
    finally
      lFile.Free;
    end;

    SaveStringToFile(APaths.ApiIncPrefix + 'PropertiesDecl.inc', Result.ProtectedDef);
    SaveStringToFile(APaths.ApiIncPrefix + 'MethodsDecl.inc', Result.PublicDef);
    SaveStringToFile(APaths.ApiIncPrefix + 'UnsafeDecl.inc', Result.UnsafeDef);
    SaveStringToFile(APaths.ApiIncPrefix + 'PublicPropertiesDecl.inc', Result.PublicPropertesDef);
    SaveStringToFile(APaths.ApiIncPrefix + 'PublishedPropertiesDecl.inc', Result.PublishedPropertesDef);
    SaveStringToFile(APaths.ApiIncPrefix + 'PropertiesCode.inc', Result.ProtectedCode);
    SaveStringToFile(APaths.ApiIncPrefix + 'UnsafeCode.inc', Result.UnsafeCode);
    SaveStringToFile(APaths.ApiIncPrefix + 'MethodsCode.inc', Result.PublicCode);
  except
    Result.Free;
    raise;
  end;
end;

end.
