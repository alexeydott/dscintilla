unit DScintillaFindDLG deprecated;

{ Backward-compatibility shim — use DScintillaSearchReplaceDLG in new code. }

interface

uses
  DScintillaSearchReplaceDLG;

type
  TDSciSearchMode             = DScintillaSearchReplaceDLG.TDSciSearchMode;
  TDSciSearchConfig           = DScintillaSearchReplaceDLG.TDSciSearchConfig;
  TDSciFindDialogAction       = DScintillaSearchReplaceDLG.TDSciFindDialogAction;
  TDSciFindDialogExecuteEvent = DScintillaSearchReplaceDLG.TDSciFindDialogExecuteEvent;
  TDSciFindDialog             = DScintillaSearchReplaceDLG.TDSciSearchReplaceDialog;

implementation

end.
