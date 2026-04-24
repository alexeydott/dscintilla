program SciIFGenCmd;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  uIFGen in 'uIFGen.pas',
  uIFGenRunner in 'uIFGenRunner.pas';

procedure WriteUsage;
begin
  Writeln('Usage: SciIFGenCmd.exe [path-to-IFGen]');
end;

var
  lStartDir: String;
  lPaths: TSciGenPaths;
  lSciGen: TSciGen;
begin
  try
    if (ParamCount > 0) and SameText(ParamStr(1), '--help') then
    begin
      WriteUsage;
      Halt(0);
    end;

    if ParamCount > 0 then
      lStartDir := ParamStr(1)
    else
      lStartDir := ExtractFilePath(ParamStr(0));

    lPaths := ResolveSciGenPaths(lStartDir);
    lSciGen := GenerateScintillaSources(lPaths);
    try
      Writeln('Generated Delphi API from: ' + lPaths.ScintillaIFaceFile);
      if FileExists(lPaths.LexicalStylesIFaceFile) then
        Writeln('Included lexical styles from: ' + lPaths.LexicalStylesIFaceFile);
      Writeln('Updated: ' + lPaths.TypesFile);
      Writeln('Updated: ' + lPaths.ApiIncPrefix + 'MethodsDecl.inc');
      Writeln('Updated: ' + lPaths.ApiIncPrefix + 'MethodsCode.inc');
      Writeln('Updated: ' + lPaths.ApiIncPrefix + 'PropertiesDecl.inc');
      Writeln('Updated: ' + lPaths.ApiIncPrefix + 'PropertiesCode.inc');
      Writeln('Updated: ' + lPaths.ApiIncPrefix + 'UnsafeDecl.inc');
      Writeln('Updated: ' + lPaths.ApiIncPrefix + 'UnsafeCode.inc');
      Writeln('Updated: ' + lPaths.ApiIncPrefix + 'PublicPropertiesDecl.inc');
      Writeln('Updated: ' + lPaths.ApiIncPrefix + 'PublishedPropertiesDecl.inc');
    finally
      lSciGen.Free;
    end;
  except
    on E: Exception do
    begin
      Writeln('ERROR ' + E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
