unit DOSrcVwrVersion;

interface

uses
  Winapi.Windows;

const
  cPluginVersionMajor = 1;
  cPluginVersionMinor = 0;
  cPluginVersionRelease = 0;
  cPluginVersionBuild = 0;
  cPluginName = 'Source Code Viewer';
  cPluginAboutTitle = 'DOSrcVwr';
  cPluginDescription = 'Scintilla-based source code viewer for DOpus';
  cPluginCopyrightNotice = '(c) 2024-2026 alexey.t';
  cPluginHomepageURL = 'https://github.com/alexeydott/DScintilla/tree/master/Demos/dosrcvwr';

function PluginVersionHigh: DWORD;
function PluginVersionLow: DWORD;
function PluginVersionText: string;

implementation

uses
  System.SysUtils;

function GetFileVersion(const AFileName: string; var AMajor, AMinor, ARelease, ABuild: Cardinal): Boolean;
var
  FileName: string;
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  FI: PVSFixedFileInfo;
  VerSize: DWORD;
begin
  Result := False;
  FileName := AFileName;
  UniqueString(FileName);
  InfoSize := GetFileVersionInfoSize(PChar(FileName), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(FileName), Wnd, InfoSize, VerBuf) then
        if VerQueryValue(VerBuf, '\', Pointer(FI), VerSize) then
        begin
          AMajor := HiWord(FI.dwFileVersionMS);
          AMinor := LoWord(FI.dwFileVersionMS);
          ARelease := HiWord(FI.dwFileVersionLS);
          ABuild := LoWord(FI.dwFileVersionLS);
          Result:= True;
        end;
    finally
      FreeMem(VerBuf);
    end;
  end;
end;

var
  GVerMajor:   Cardinal = cPluginVersionMajor;
  GVerMinor:   Cardinal = cPluginVersionMinor;
  GVerRelease: Cardinal = cPluginVersionRelease;
  GVerBuild:   Cardinal = cPluginVersionBuild;

function PluginVersionHigh: DWORD;
begin
  Result := (DWORD(GVerMajor) shl 16) or DWORD(GVerMinor);
end;

function PluginVersionLow: DWORD;
begin
  Result := (DWORD(GVerRelease) shl 16) or DWORD(GVerBuild);
end;

function PluginVersionText: string;
begin
  Result := Format('%d.%d.%d.%d', [GVerMajor, GVerMinor, GVerRelease, GVerBuild]);
end;

initialization
  var LBuf: array[0..MAX_PATH] of Char;
  var LMajor, LMinor, LRelease, LBuild: Cardinal;
  if (GetModuleFileName(HInstance, LBuf, Length(LBuf)) > 0) and
     GetFileVersion(string(LBuf), LMajor, LMinor, LRelease, LBuild) then
  begin
    GVerMajor   := LMajor;
    GVerMinor   := LMinor;
    GVerRelease := LRelease;
    GVerBuild   := LBuild;
  end;
end.
