library DSciSrcVwr;

{$IFNDEF NO_SHELLACE}
{$I decShellExtension.inc}
{$ENDIF}

uses
  ComServ,
  DScintillaViewerFrame in 'DScintillaViewerFrame.pas' {SourceCodePreviewExtensionForm};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  {$IFDEF SUPPORTS_PERUSERREGISTRATION}
  DllInstall,
  {$ENDIF}
  DllRegisterServer,
  DllUnregisterServer;

{$R *.res}

begin
end.


