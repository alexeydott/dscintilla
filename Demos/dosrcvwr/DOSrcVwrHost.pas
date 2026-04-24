unit DOSrcVwrHost;

interface

uses
  Winapi.Windows,
  DOpusViewerPlugins;

function HandleCreateViewer(AParentWnd: HWND; ARect: PRECT;
  AFlags: DWORD): HWND;
function HandleConfigure(AParentWnd: HWND; ANotifyWnd: HWND;
  ANotifyData: DWORD): HWND;
function HandleAbout(AParentWnd: HWND): HWND;

{ Posts DVPLUGINMSG_REINITIALIZE to every active viewer window.
  Thread-safe; safe to call from any thread (uses PostMessage). }
procedure NotifyViewersConfigChanged;

implementation

uses
  System.SysUtils, System.Classes, System.SyncObjs,
  System.Generics.Collections,
  Winapi.Messages,
  Vcl.Controls,
  DOSrcVwrLog,
  DOSrcVwrConfigDlg,
  DOSrcVwrViewerFrame,
  DOSrcVwrNotify;

var
  GViewerHandles: TList<HWND>;
  GViewerLock: TCriticalSection;

{$R-}{$Q-}

{ Each CreateViewer call creates a TDOSrcVwrViewerFrame (a VCL control parented
  to the Opus window). We subclass the VCL window to intercept DVPLUGINMSG
  messages sent by Opus via SendMessage.
  Per-HWND storage of the original WndProc via SetProp/GetProp allows
  multiple simultaneous viewer windows. }

const
  cOldWndProcProp = 'DOSrcVwrOldWndProc';
  { Custom message: route config dialog creation to the viewer's UI thread.
    DOpus calls DVP_Configure from short-lived worker threads; VCL forms
    created/destroyed on non-main threads corrupt Screen.FForms and heap. }
  WM_DOSRCVWR_SHOWCONFIG = WM_USER + 201;

type
  PConfigDialogRequest = ^TConfigDialogRequest;
  TConfigDialogRequest = record
    ParentWnd: HWND;
    NotifyWnd: HWND;
    NotifyData: DWORD;
    ResultHWND: HWND;
  end;

procedure RegisterViewerHandle(AWnd: HWND);
begin
  GViewerLock.Enter;
  try
    if GViewerHandles.IndexOf(AWnd) < 0 then
      GViewerHandles.Add(AWnd);
  finally
    GViewerLock.Leave;
  end;
end;

procedure UnregisterViewerHandle(AWnd: HWND);
begin
  GViewerLock.Enter;
  try
    GViewerHandles.Remove(AWnd);
  finally
    GViewerLock.Leave;
  end;
end;

procedure NotifyViewersConfigChanged;
var
  LHandles: TArray<HWND>;
  I: Integer;
begin
  GViewerLock.Enter;
  try
    LHandles := GViewerHandles.ToArray;
  finally
    GViewerLock.Leave;
  end;
  LogInfo('NotifyViewersConfigChanged: %d viewer(s)', [Length(LHandles)]);
  for I := 0 to High(LHandles) do
  begin
    if IsWindow(LHandles[I]) then
    begin
      LogInfo('NotifyViewersConfigChanged: posting REINITIALIZE to $%x', [LHandles[I]]);
      PostMessage(LHandles[I], DVPLUGINMSG_REINITIALIZE, 0, 0);
    end;
  end;
end;

function ViewerFrameFromHandle(AWnd: HWND): TDOSrcVwrViewerFrame;
var
  LCtrl: TWinControl;
begin
  LCtrl := FindControl(AWnd);
  if LCtrl is TDOSrcVwrViewerFrame then
    Result := TDOSrcVwrViewerFrame(LCtrl)
  else
    Result := nil;
end;

function DVPMsgName(AMsg: UINT): string;
begin
  case AMsg of
    DVPLUGINMSG_LOADW:           Result := 'LOADW';
    DVPLUGINMSG_CLEAR:           Result := 'CLEAR';
    DVPLUGINMSG_RESIZE:          Result := 'RESIZE';
    DVPLUGINMSG_GETCAPABILITIES: Result := 'GETCAPABILITIES';
    DVPLUGINMSG_SELECTALL:       Result := 'SELECTALL';
    DVPLUGINMSG_TESTSELECTION:   Result := 'TESTSELECTION';
    DVPLUGINMSG_COPYSELECTION:   Result := 'COPYSELECTION';
    DVPLUGINMSG_SETABORTEVENT:   Result := 'SETABORTEVENT';
    DVPLUGINMSG_REINITIALIZE:    Result := 'REINITIALIZE';
    DVPLUGINMSG_REDRAW:          Result := 'REDRAW';
    DVPLUGINMSG_MOUSEWHEEL:      Result := 'MOUSEWHEEL';
    DVPLUGINMSG_TRANSLATEACCEL:  Result := 'TRANSLATEACCEL';
    DVPLUGINMSG_ISDLGMESSAGE:    Result := 'ISDLGMESSAGE';
    WM_SETFOCUS:                 Result := 'WM_SETFOCUS';
    WM_KILLFOCUS:                Result := 'WM_KILLFOCUS';
    WM_DESTROY:                  Result := 'WM_DESTROY';
  else
    Result := Format('$%x', [AMsg]);
  end;
end;

function ViewerWndProc(AWnd: HWND; AMsg: UINT; AWParam: WPARAM;
  ALParam: LPARAM): LRESULT; stdcall;
var
  LFrame: TDOSrcVwrViewerFrame;
  LFileName: PWideChar;
  LStatusBuf: array[0..511] of WideChar;
  LOldProc: Pointer;
  LAccelMsg: PMsg;
  LKey: Word;
  LShift: TShiftState;
  LFindDlgHwnd: HWND;
begin
  LOldProc := Pointer(GetProp(AWnd, cOldWndProcProp));
  LFrame := ViewerFrameFromHandle(AWnd);

  LogDebug('WndProc: HWND=$%x msg=%s wP=$%x lP=$%x frame=%p',
    [AWnd, DVPMsgName(AMsg), AWParam, ALParam, Pointer(LFrame)]);

  try
    case AMsg of
      DVPLUGINMSG_LOADW:
      begin
        LFileName := PWideChar(ALParam);
        LogInfo('WndProc.LOADW: file=%s frame=%p', [string(LFileName), Pointer(LFrame)]);
        if (LFrame <> nil) and (LFileName <> nil) then
        begin
          LogInfo('WndProc.LOADW: calling LoadFile...');
          if LFrame.LoadFile(string(LFileName)) then
          begin
            StrPLCopy(@LStatusBuf[0], ExtractFileName(string(LFileName)), Length(LStatusBuf));
            NotifyStatusText(AWnd, LFrame.ParentOpusWnd, @LStatusBuf[0]);
            LogInfo('WndProc.LOADW: loaded OK');
            Result := 1;
          end
          else
          begin
            LogError('WndProc.LOADW: LoadFile returned false');
            Result := 0;
          end;
        end
        else
          Result := 0;
        Exit;
      end;

      DVPLUGINMSG_CLEAR:
      begin
        if LFrame <> nil then
        begin
          LFrame.ClearContent;
          NotifyCleared(AWnd, LFrame.ParentOpusWnd);
        end;
        Result := 1;
        Exit;
      end;

      DVPLUGINMSG_RESIZE:
      begin
        // wParam = MAKELONG(left, top), lParam = MAKELONG(width, height)
        if LFrame <> nil then
          LFrame.SetBounds(
            SmallInt(LoWord(AWParam)), SmallInt(HiWord(AWParam)),
            SmallInt(LoWord(ALParam)), SmallInt(HiWord(ALParam)));
        Result := 1;
        Exit;
      end;

      DVPLUGINMSG_GETCAPABILITIES:
      begin
        Result := LRESULT(
          VPCAPABILITY_COPYSELECTION or
          VPCAPABILITY_SELECTALL or
          VPCAPABILITY_WANTFOCUS or
          VPCAPABILITY_CANTRACKFOCUS or
          VPCAPABILITY_HASDIALOGS or
          VPCAPABILITY_HASACCELERATORS);
        Exit;
      end;

      DVPLUGINMSG_SELECTALL:
      begin
        if LFrame <> nil then
          LFrame.Editor.SelectAll;
        Result := 1;
        Exit;
      end;

      DVPLUGINMSG_TESTSELECTION:
      begin
        if (LFrame <> nil) and (LFrame.Editor.SelectionStart <> LFrame.Editor.SelectionEnd) then
          Result := 1
        else
          Result := 0;
        Exit;
      end;

      DVPLUGINMSG_COPYSELECTION:
      begin
        if LFrame <> nil then
          LFrame.Editor.Copy;
        Result := 1;
        Exit;
      end;

      DVPLUGINMSG_SETABORTEVENT:
      begin
        if LFrame <> nil then
          LFrame.AbortEvent := THandle(ALParam);
        Result := 1;
        Exit;
      end;

      DVPLUGINMSG_REINITIALIZE:
      begin
        if LFrame <> nil then
        begin
          LFrame.ReloadConfig;
          LogInfo('Viewer reinitializing after config change');
        end;
        Result := 1;
        Exit;
      end;

      WM_DOSRCVWR_SHOWCONFIG:
      begin
        LogInfo('WndProc.SHOWCONFIG: running config dialog on UI thread');
        if ALParam <> 0 then
        begin
          with PConfigDialogRequest(ALParam)^ do
            ResultHWND := ShowConfigureDialog(ParentWnd, NotifyWnd, NotifyData);
        end;
        Result := 1;
        Exit;
      end;

      DVPLUGINMSG_REDRAW:
      begin
        if LFrame <> nil then
          LFrame.Invalidate;
        Result := 1;
        Exit;
      end;

      DVPLUGINMSG_MOUSEWHEEL:
      begin
        if LFrame <> nil then
          SendMessage(LFrame.Editor.Handle, WM_MOUSEWHEEL, AWParam, ALParam);
        Result := 1;
        Exit;
      end;

      DVPLUGINMSG_TRANSLATEACCEL:
      begin
        LogInfo('WndProc.TRANSLATEACCEL: frame=%p lP=$%x', [Pointer(LFrame), ALParam]);
        if (LFrame <> nil) and (ALParam <> 0) then
        begin
          LAccelMsg := PMsg(ALParam);
          LogInfo('WndProc.TRANSLATEACCEL: msg=$%x wP=$%x', [LAccelMsg^.message, LAccelMsg^.wParam]);
          if LAccelMsg^.message = WM_KEYDOWN then
          begin
            LKey := Word(LAccelMsg^.wParam);
            LShift := [];
            if GetKeyState(VK_CONTROL) < 0 then
              Include(LShift, ssCtrl);
            if GetKeyState(VK_SHIFT) < 0 then
              Include(LShift, ssShift);
            LogInfo('WndProc.TRANSLATEACCEL: key=$%x ctrl=%d shift=%d',
              [LKey, Ord(ssCtrl in LShift), Ord(ssShift in LShift)]);
            LFrame.HandleKeyDown(LKey, LShift);
            if LKey = 0 then
            begin
              LogInfo('WndProc.TRANSLATEACCEL: handled (key consumed)');
              Result := 1;
              Exit;
            end;
          end;
        end;
        Result := 0;
        Exit;
      end;

      DVPLUGINMSG_ISDLGMESSAGE:
      begin
        // Only handle messages for the modeless Find dialog.
        // Do NOT call IsDialogMessage on the main frame — it causes
        // infinite message loops in a non-dialog VCL control.
        if (LFrame <> nil) and (ALParam <> 0) then
        begin
          LFindDlgHwnd := LFrame.FindDialogHandle;
          if (LFindDlgHwnd <> 0) and
             IsDialogMessage(LFindDlgHwnd, PMsg(ALParam)^) then
          begin
            Result := 1;
            Exit;
          end;
        end;
        Result := 0;
        Exit;
      end;

      WM_SETFOCUS:
      begin
        if LFrame <> nil then
          NotifyFocusChange(AWnd, LFrame.ParentOpusWnd, True);
      end;

      WM_KILLFOCUS:
      begin
        if LFrame <> nil then
        begin
          { Suppress got=False when focus moves to our own Find dialog (or any
            of its child controls). Notifying Opus in this case triggers a
            Z-order adjustment that buries the dialog behind the DO frame.
            Mirrors the ownership model used by ShowConfigureDialog. }
          LFindDlgHwnd := LFrame.FindDialogHandle;
          if (LFindDlgHwnd = 0) or
             ((HWND(AWParam) <> LFindDlgHwnd) and
              not IsChild(LFindDlgHwnd, HWND(AWParam))) then
            NotifyFocusChange(AWnd, LFrame.ParentOpusWnd, False)
          else
            LogDebug('WndProc.KILLFOCUS: suppressed got=False (focus→FindDlg $%x)',
              [AWParam]);
        end;
      end;

      WM_DESTROY:
      begin
        { Cancel and free all open dialogs FIRST so that:
          (a) any active ShowModal loop exits and calls EnableTaskWindows,
          (b) the caller thread is unblocked before the viewer is torn down.
          Must be done while LFrame is still registered (non-nil). }
        if LFrame <> nil then
          LFrame.CancelAndFreeDialogs;
        UnregisterViewerHandle(AWnd);
        RemoveProp(AWnd, cOldWndProcProp);
        if LOldProc <> nil then
          SetWindowLongPtr(AWnd, GWL_WNDPROC, NativeInt(LOldProc));
        LogInfo('Viewer window destroying');
      end;
    end;
  except
    on E: Exception do
      LogError('WndProc EXCEPTION: [%s] %s (msg=%s)', [E.ClassName, E.Message, DVPMsgName(AMsg)]);
  end;

  Result := CallWindowProc(LOldProc, AWnd, AMsg, AWParam, ALParam);
end;

function HandleCreateViewer(AParentWnd: HWND; ARect: PRECT;
  AFlags: DWORD): HWND;
var
  LFrame: TDOSrcVwrViewerFrame;
begin
  LogInfo('HandleCreateViewer: enter Parent=$%x Flags=$%x', [AParentWnd, AFlags]);
  try
    if ARect <> nil then
      LogInfo('HandleCreateViewer: rect=(%d,%d,%d,%d)',
        [ARect^.Left, ARect^.Top, ARect^.Right, ARect^.Bottom])
    else
      LogInfo('HandleCreateViewer: rect=nil');

    LogInfo('HandleCreateViewer: creating TDOSrcVwrViewerFrame...');
    LFrame := TDOSrcVwrViewerFrame.CreateForOpus(AParentWnd, ARect, AFlags);
    Result := LFrame.Handle;
    LogInfo('HandleCreateViewer: frame created HWND=$%x', [Result]);

    // Subclass the VCL window to intercept DVPLUGINMSG messages.
    LogInfo('HandleCreateViewer: subclassing WndProc...');
    SetProp(Result, cOldWndProcProp,
      THandle(GetWindowLongPtr(Result, GWL_WNDPROC)));
    SetWindowLongPtr(Result, GWL_WNDPROC, NativeInt(@ViewerWndProc));
    RegisterViewerHandle(Result);
    LogInfo('HandleCreateViewer: subclassed OK');

    // Notify Opus that we have focus/capabilities
    LogInfo('HandleCreateViewer: notifying capabilities...');
    NotifyCapabilities(Result, AParentWnd,
      VPCAPABILITY_COPYSELECTION or
      VPCAPABILITY_SELECTALL or
      VPCAPABILITY_WANTFOCUS or
      VPCAPABILITY_CANTRACKFOCUS or
      VPCAPABILITY_HASDIALOGS or
      VPCAPABILITY_HASACCELERATORS);

    LogInfo('HandleCreateViewer: done => $%x', [Result]);
  except
    on E: Exception do
    begin
      LogError('HandleCreateViewer FAILED: %s', [E.Message]);
      Result := 0;
    end;
  end;
end;

function HandleConfigure(AParentWnd: HWND; ANotifyWnd: HWND;
  ANotifyData: DWORD): HWND;
var
  LViewerWnd: HWND;
  LReq: TConfigDialogRequest;
begin
  LogInfo('HandleConfigure: enter Parent=$%x Notify=$%x Data=$%x',
    [AParentWnd, ANotifyWnd, ANotifyData]);

  { Try to route dialog creation to a viewer's UI thread.
    VCL forms must be created/destroyed on the thread that owns the
    message loop; DOpus calls DVP_Configure from short-lived worker threads
    that are NOT the UI thread.  SendMessage blocks this worker thread
    until the viewer processes the request on the correct thread. }
  LViewerWnd := 0;
  GViewerLock.Enter;
  try
    if GViewerHandles.Count > 0 then
      LViewerWnd := GViewerHandles[0];
  finally
    GViewerLock.Leave;
  end;

  if (LViewerWnd <> 0) and IsWindow(LViewerWnd) then
  begin
    LogInfo('HandleConfigure: routing to viewer UI thread via $%x', [LViewerWnd]);
    LReq.ParentWnd := AParentWnd;
    LReq.NotifyWnd := ANotifyWnd;
    LReq.NotifyData := ANotifyData;
    LReq.ResultHWND := 0;
    SendMessage(LViewerWnd, WM_DOSRCVWR_SHOWCONFIG, 0, LPARAM(@LReq));
    Result := LReq.ResultHWND;
  end
  else
  begin
    LogInfo('HandleConfigure: no viewer — running on caller thread (fallback)');
    Result := DOSrcVwrConfigDlg.ShowConfigureDialog(AParentWnd, ANotifyWnd, ANotifyData);
  end;

  LogInfo('HandleConfigure: done => $%x', [Result]);
end;

function HandleAbout(AParentWnd: HWND): HWND;
begin
  LogInfo('HandleAbout: enter Parent=$%x', [AParentWnd]);
  Result := DOSrcVwrConfigDlg.ShowAboutDialog(AParentWnd);
  LogInfo('HandleAbout: done => $%x', [Result]);
end;

initialization
  GViewerHandles := TList<HWND>.Create;
  GViewerLock := TCriticalSection.Create;

finalization
  FreeAndNil(GViewerLock);
  FreeAndNil(GViewerHandles);

end.