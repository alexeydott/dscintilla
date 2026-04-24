library DSciSrcVwr;

{$IFNDEF NO_SHELLACE}
{$I decShellExtension.inc}
{$ENDIF}

uses
  {$IFDEF EurekaLog}
  EMemLeaks,
  EResLeaks,
  EDebugJCL,
  EDebugExports,
  EFixSafeCallException,
  EMapWin32,
  EAppNonVisual,
  ExceptionLog7,
  {$ENDIF EurekaLog}
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

