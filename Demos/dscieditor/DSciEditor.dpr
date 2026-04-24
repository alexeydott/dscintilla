program DSciEditor;

uses
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



