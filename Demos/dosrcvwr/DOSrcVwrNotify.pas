unit DOSrcVwrNotify;

interface

uses
  Winapi.Windows,
  DOpusViewerPlugins;

procedure NotifyFocusChange(AViewerWnd, AParentWnd: HWND; AGotFocus: BOOL);
procedure NotifyCleared(AViewerWnd, AParentWnd: HWND);
procedure NotifyCapabilities(AViewerWnd, AParentWnd: HWND; ACapabilities: DWORD);
procedure NotifyStatusText(AViewerWnd, AParentWnd: HWND; AText: LPWSTR);

implementation

uses
  Winapi.Messages,
  System.SysUtils,
  DOSrcVwrLog;

{$R-}{$Q-}
{$WARN BOUNDS_ERROR OFF}

procedure NotifyFocusChange(AViewerWnd, AParentWnd: HWND; AGotFocus: BOOL);
var
  LData: DVPNMFOCUSCHANGE;
begin
  LogDebug('Notify: FocusChange viewer=$%x parent=$%x got=%s',
    [AViewerWnd, AParentWnd, BoolToStr(AGotFocus, True)]);
  LData.hdr.hwndFrom := AViewerWnd;
  LData.hdr.idFrom := 0;
  LData.hdr.code := UINT(DVPN_FOCUSCHANGE);
  LData.fGotFocus := AGotFocus;
  SendMessage(AParentWnd, WM_NOTIFY, 0, LPARAM(@LData));
end;

procedure NotifyCleared(AViewerWnd, AParentWnd: HWND);
var
  LData: NMHDR;
begin
  LogDebug('Notify: Cleared viewer=$%x parent=$%x', [AViewerWnd, AParentWnd]);
  LData.hwndFrom := AViewerWnd;
  LData.idFrom := 0;
  LData.code := UINT(DVPN_CLEARED);
  SendMessage(AParentWnd, WM_NOTIFY, 0, LPARAM(@LData));
end;

procedure NotifyCapabilities(AViewerWnd, AParentWnd: HWND; ACapabilities: DWORD);
var
  LData: DVPNMCAPABILITIES;
  LCode: UINT_PTR;
begin
  LogDebug('Notify: Capabilities viewer=$%x parent=$%x caps=$%x',
    [AViewerWnd, AParentWnd, ACapabilities]);
  FillChar(LData, SizeOf(LData), 0);
  LData.hdr.hwndFrom := AViewerWnd;
  LData.hdr.idFrom := 0;
  LCode := DVPN_CAPABILITIES;
  LData.hdr.code := LCode;
  LData.dwCapabilities := ACapabilities;
  LogDebug('Notify: Capabilities sending WM_NOTIFY code=$%x size=%d',
    [LCode, SizeOf(LData)]);
  SendMessage(AParentWnd, WM_NOTIFY, 0, LPARAM(@LData));
  LogDebug('Notify: Capabilities sent OK');
end;

procedure NotifyStatusText(AViewerWnd, AParentWnd: HWND; AText: LPWSTR);
var
  LData: DVPNMSTATUSTEXT;
begin
  LogDebug('Notify: StatusText viewer=$%x parent=$%x text=%s',
    [AViewerWnd, AParentWnd, string(AText)]);
  LData.hdr.hwndFrom := AViewerWnd;
  LData.hdr.idFrom := 0;
  LData.hdr.code := UINT(DVPN_STATUSTEXT);
  LData.lpszStatusText := AText;
  LData.fUnicode := True;
  SendMessage(AParentWnd, WM_NOTIFY, 0, LPARAM(@LData));
end;

end.
