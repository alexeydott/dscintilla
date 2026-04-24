program DScintillaTest;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  TestDSciVisualUi in 'TestDSciVisualUi.pas',
  TestDScintillaTyped in 'TestDScintillaTyped.pas',
  DScintillaTypes in '..\..\source\DScintillaTypes.pas',
  DScintillaUtils in '..\..\source\DScintillaUtils.pas',
  DScintillaCustom in '..\..\source\DScintillaCustom.pas',
  DScintillaBridge in '..\..\source\DScintillaBridge.pas',
  DScintillaLogger in '..\..\source\DScintillaLogger.pas',
  DScintilla in '..\..\source\DScintilla.pas',
  DLexilla in '..\..\source\DLexilla.pas',
  DScintillaFindDLG in '..\..\source\DScintillaFindDLG.pas',
  DScintillaVisualConfig in '..\..\source\DScintillaVisualConfig.pas',
  DScintillaVisualSettingsDLG in '..\..\source\DScintillaVisualSettingsDLG.pas',
  uDSciVisualTestMain in '..\Visual\uDSciVisualTestMain.pas',
  Forms,
  TestFramework,
  {$IFNDEF CONSOLE_TESTRUNNER}
  GUITestRunner,
  {$ENDIF}
  TextTestRunner;

{R *.RES}

begin
  Application.Initialize;
  {$IFDEF CONSOLE_TESTRUNNER}
  TextTestRunner.RunRegisteredTests;
  {$ELSE}
  if IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;
  {$ENDIF}
end.

