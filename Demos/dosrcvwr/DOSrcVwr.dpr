library DOSrcVwr;

{$R *.res}

uses
  DOSrcVwrExports in 'DOSrcVwrExports.pas',
  DOSrcVwrHost in 'DOSrcVwrHost.pas',
  DOSrcVwrViewerFrame in 'DOSrcVwrViewerFrame.pas',
  DOSrcVwrIdentify in 'DOSrcVwrIdentify.pas',
  DOSrcVwrNotify in 'DOSrcVwrNotify.pas',
  DOSrcVwrRuntime in 'DOSrcVwrRuntime.pas',
  DOSrcVwrLog in 'DOSrcVwrLog.pas',
  DOSrcVwrConfigDlg in 'DOSrcVwrConfigDlg.pas';

exports
  DVP_InitEx,
  DVP_Uninit,
  DVP_USBSafe,
  DVP_IdentifyW name 'DVP_IdentifyW',
  DVP_IdentifyFileW name 'DVP_IdentifyFileW',
  DVP_CreateViewer,
  DVP_Configure,
  DVP_About;

begin
  DOSrcVwrLog.LogInfo('DLL begin block: library loaded');
end.
