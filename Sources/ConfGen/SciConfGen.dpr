program SciConfGen;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  uSciConfGenImport in 'uSciConfGenImport.pas',
  uSciConfGenRunner in 'uSciConfGenRunner.pas';

begin
  try
    RunSciConfGen;
  except
    on E: Exception do
    begin
      Writeln('ERROR ' + E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
