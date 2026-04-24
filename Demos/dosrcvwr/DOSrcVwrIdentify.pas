unit DOSrcVwrIdentify;

interface

uses
  Winapi.Windows,
  DOpusViewerPlugins;

function HandleIdentify(APluginInfo: LPVIEWERPLUGININFOW): BOOL;
function HandleIdentifyFile(AWnd: HWND; AFileName: LPWSTR;
  AFileInfo: LPVIEWERPLUGINFILEINFOW; AAbortEvent: THandle): BOOL;

implementation

uses
  System.Classes, System.SysUtils,
  DScintillaDefaultConfig, DScintillaVisualConfig,
  DOSrcVwrRuntime,
  DOSrcVwrLog,
  DOSrcVwrVersion;

const
  // {C7F1A3E0-5B2D-4E8A-9F01-D6A8B3C4E5F7}
  cPluginGUID: TGUID = '{C7F1A3E0-5B2D-4E8A-9F01-D6A8B3C4E5F7}';

var
  GCachedExtensions: string = '';

{ Builds the extension list dynamically from the Scintilla config file
  by iterating all <Style ext="..."> entries. Creates the config file
  from the embedded default resource if it does not exist yet.
  The result is cached so the XML is only parsed once. }
function GetHandledExtensions: string;
var
  LConfig: TDSciVisualConfig;
  LStream: TResourceStream;
begin
  if GCachedExtensions = '' then
  begin
    // Ensure config directory and file exist
    try
      PluginHelper.EnsureConfigFile;
    except
      on E: Exception do
        LogError('GetHandledExtensions: EnsureConfigFile: %s', [E.Message]);
    end;

    LConfig := TDSciVisualConfig.Create;
    try
      try
        LConfig.LoadFromFile(PluginHelper.ConfigFile);
        LogInfo('GetHandledExtensions: loaded from %s', [PluginHelper.ConfigFile]);
      except
        on E: Exception do
        begin
          LogError('GetHandledExtensions: LoadFromFile failed (%s), using embedded resource',
            [E.Message]);
          LStream := OpenDefaultConfigStream;
          try
            LConfig.LoadFromStream(LStream);
          finally
            LStream.Free;
          end;
        end;
      end;
      GCachedExtensions := LConfig.BuildHandledExtensions;
      LogInfo('GetHandledExtensions: %d chars, %d groups',
        [Length(GCachedExtensions), LConfig.StyleOverrides.Groups.Count]);
    finally
      LConfig.Free;
    end;
  end;

  Result := GCachedExtensions;
end;

function HandleIdentify(APluginInfo: LPVIEWERPLUGININFOW): BOOL;
var
  LExts: string;
begin
  if APluginInfo = nil then
    Exit(False);

  APluginInfo^.dwFlags :=
    DVPFIF_ExtensionsOnly or     // identify by extension only, no content sniffing
    DVPFIF_CanConfigure or       // we export DVP_Configure
//    DVPFIF_CanShowAbout or     // we export DVP_About, but we use the DO "About" dialog box, which contains more information and looks much nicer.
    DVPFIF_NoThumbnails or       // no bitmap thumbnail support
    DVPFIF_ZeroBytesOk or        // zero-byte source files are fine
    DVPFIF_NoFileInformation or  // we don't provide extended file info
    DVPFIF_UseVersionResource    // version comes from DOSrcVwr.dll VERSIONINFO
    ;
  APluginInfo^.dwVersionHigh := PluginVersionHigh;
  APluginInfo^.dwVersionLow := PluginVersionLow;
  LogInfo('HandleIdentify: advertising version resource %s',
    [PluginVersionText]);
  LogInfo('HandleIdentify: metadata prepared (descLen=%d, url=%s)',
    [Length(cPluginDescription), cPluginHomepageURL]);

  if (APluginInfo^.lpszHandleExts <> nil) then
  begin
    LExts := GetHandledExtensions;
    LogInfo('HandleIdentify: exts length=%d, buffer=%d',
      [Length(LExts), APluginInfo^.cchHandleExtsMax]);
    // SDK: "you can change the address of lpszHandleExts to point to your own buffer"
    // Our GCachedExtensions lives for the DLL lifetime, so the pointer stays valid.
    APluginInfo^.lpszHandleExts := PWideChar(LExts);
  end;

  if (APluginInfo^.lpszName <> nil) and (APluginInfo^.cchNameMax > 1) then
    StrPLCopy(APluginInfo^.lpszName, cPluginName, APluginInfo^.cchNameMax - 1);

  if (APluginInfo^.lpszDescription <> nil) and (APluginInfo^.cchDescriptionMax > 1) then
    StrPLCopy(APluginInfo^.lpszDescription, cPluginDescription, APluginInfo^.cchDescriptionMax - 1);

  if (APluginInfo^.lpszCopyright <> nil) and (APluginInfo^.cchCopyrightMax > 1) then
    StrPLCopy(APluginInfo^.lpszCopyright, cPluginCopyrightNotice, APluginInfo^.cchCopyrightMax - 1);

  if (APluginInfo^.lpszURL <> nil) and (APluginInfo^.cchURLMax > 1) then
    StrPLCopy(APluginInfo^.lpszURL, cPluginHomepageURL, APluginInfo^.cchURLMax - 1);

  APluginInfo^.dwlMinFileSize := 0;
  APluginInfo^.dwlMaxFileSize := 0;
  APluginInfo^.dwlMinPreviewFileSize := 0;
  APluginInfo^.dwlMaxPreviewFileSize := 0;

  APluginInfo^.uiMajorFileType := Ord(DVPMajorType_Text);
  APluginInfo^.idPlugin := cPluginGUID;

  if APluginInfo^.cbSize >= SizeOf(TVIEWERPLUGININFOWV4) then
    APluginInfo^.dwInitFlags := 0;

  LogInfo('HandleIdentify: filled OK (cbSize=%d, flags=$%x)', [APluginInfo^.cbSize, APluginInfo^.dwFlags]);
  Result := True;
end;

function HandleIdentifyFile(AWnd: HWND; AFileName: LPWSTR;
  AFileInfo: LPVIEWERPLUGINFILEINFOW; AAbortEvent: THandle): BOOL;
var
  LExt: string;
begin
  if (AFileName = nil) or (AFileInfo = nil) then
    Exit(False);

  // Honor abort event from Directory Opus
  if (AAbortEvent <> 0) and (WaitForSingleObject(AAbortEvent, 0) = WAIT_OBJECT_0) then
  begin
    LogDebug('DVP_IdentifyFileW: aborted');
    Exit(False);
  end;

  LExt := LowerCase(ExtractFileExt(string(AFileName)));
  if LExt = '' then
    Exit(False);

  // Accept any file with a recognized source-code extension.
  // The extension check is redundant when DVPFIF_ExtensionsOnly is set
  // (Opus pre-filters), but provides defense-in-depth.
  if Pos(LExt + ';', GetHandledExtensions) > 0 then
  begin
    AFileInfo^.dwFlags := DVPFI_CanReturnViewer;
    AFileInfo^.wMajorType := Ord(DVPMajorType_Text);
    AFileInfo^.wMinorType := 0;
    if AFileInfo^.cbSize >= SizeOf(VIEWERPLUGINFILEINFOW) then
      AFileInfo^.iTypeHint := Ord(DVPFITypeHint_PlainText);
    LogDebug('DVP_IdentifyFileW: accepted ' + string(AFileName));
    Result := True;
  end
  else
  begin
    LogDebug('DVP_IdentifyFileW: rejected ' + string(AFileName));
    Result := False;
  end;
end;

end.
