program DSciEditor;

uses
  {$IFDEF EurekaLog}
  EMemLeaks,
  EResLeaks,
  EDebugJCL,
  EDebugExports,
  EFixSafeCallException,
  EMapWin32,
  EAppVCL,
  EDialogWinAPIEurekaLogDetailed,
  EDialogWinAPIStepsToReproduce,
  ExceptionLog7,
  {$ENDIF EurekaLog}
  Vcl.Forms,
  DScintillaLogger,
  uDSciEditorMain in 'uDSciEditorMain.pas';

{$R *.res}

begin
{$ifdef debug}
  _DSciLogEnabled := true;
  _DSciLogLevel := cDSciLogDebug;
  _DSciLogOutput := cDSciOutputFile;
  //_DSciLogPath := '..\settings\DSciEditor.debug.log';
{$endif}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDSciVisualTestForm, DSciVisualTestForm);
  Application.Run;
end.




