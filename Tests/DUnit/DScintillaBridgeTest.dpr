program DScintillaBridgeTest;

{$APPTYPE CONSOLE}

{$R *.res}
{.$define SCINTILLA_STATIC_LINKING}
uses
  System.SysUtils
  {$IFdef SCINTILLA_STATIC_LINKING}
  ,DScintillaBridge
  {$ENDIF}
  ;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
