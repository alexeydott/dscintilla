{* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is DScintillaCustom.pas
 *
 * The Initial Developer of the Original Code is Krystian Bigaj.
 *
 * Portions created by the Initial Developer are Copyright (C) 2010-2015
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * - Michal Gajek
 * - Marko Njezic
 * - Michael Staszewski
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** *}

unit DScintillaCustom;

interface

uses
  Windows, Classes, SysUtils, Controls, Messages, ShellAPI,
  DScintillaTypes;

const
  {$IFDEF WIN64}
  cDScintillaDll  = 'Scintilla64.dll';
  {$ELSE}
  cDScintillaDll  = 'Scintilla.dll';
  {$ENDIF}

type

  TDScintillaWnd = record
    WindowHandle: HWND;
    Visible: Boolean;
  end;

{ TDScintillaCustom }

  TDScintillaMethod = (smWindows, smDirect);

  TDScintillaDirectFunction = TDScintillaFunction;

  TDSciDropFilesEvent = procedure(Sender: TObject; AFiles: TStrings) of object;

  TDScintillaCustom = class(TWinControl)
  private
    const cIndicatorCacheSize = INDICATOR_MAX + 1;
  private
    FSciDllHandle: HMODULE;
    FSciDllModule: String;
    FForceDestroyWindowHandle: Boolean;

    FDirectPointer: Pointer;
    FDirectFunction: TDScintillaDirectFunction;
    FAccessMethod: TDScintillaMethod;
    FOwnerThreadId: DWORD;
    FNativeThreadId: DWORD;

    FStoredWnd: TDScintillaWnd;
    FIndicatorAlphaCache: array[0..cIndicatorCacheSize - 1] of Integer;
    FIndicatorOutlineAlphaCache: array[0..cIndicatorCacheSize - 1] of Integer;
    procedure SetSciDllModule(const Value: String);

    procedure LoadSciLibraryIfNeeded;
    procedure FreeSciLibrary;
    procedure ResetIndicatorAlphaCache;
    procedure ResetDirectAccessState;
    function IsOwnerThread: Boolean;
    function EnsureEditorHandleForCall: HWND;
    function IsCachedIndicatorIndex(AIndex: WPARAM): Boolean;
    function NormalizeIndicatorAlphaValue(AValue: LPARAM): Integer;

    procedure DoStoreWnd;
    procedure DoRestoreWnd(const Params: TCreateParams);

  protected
    procedure CreateWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;

    function IsRecreatingWnd: Boolean;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure DestroyWindowHandle; override;

    procedure WMCreate(var AMessage: TWMCreate); message WM_CREATE;
    procedure WMDestroy(var AMessage: TWMDestroy); message WM_DESTROY;
    procedure WMDropFiles(var AMessage: TMessage); message WM_DROPFILES;
    procedure DoDropFiles(AFiles: TStrings); virtual;

    procedure CMWantSpecialKey(var AMessage: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
    procedure WMEraseBkgnd(var AMessage: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var AMessage: TWMGetDlgCode); message WM_GETDLGCODE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Workaround bugs
    procedure DefaultHandler(var AMessage); override;
    procedure MouseWheelHandler(var AMessage: TMessage); override;
    procedure CacheIndicatorAlpha(AIndicator, AAlpha, AOutlineAlpha: Integer);
    procedure IndicSetAlphaValue(AIndicator, AAlpha: Integer); virtual;
    function IndicGetAlphaValue(AIndicator: Integer): Integer; virtual;
    procedure IndicSetOutlineAlphaValue(AIndicator, AAlpha: Integer); virtual;
    function IndicGetOutlineAlphaValue(AIndicator: Integer): Integer; virtual;

  public
    /// <summary>Sends message to Scintilla control.
    /// For list of commands see DScintillaTypes.pas and documentation at:
    /// http://www.scintilla.org/ScintillaDoc.html</summary>
    function SendEditor(AMessage: UINT; WParam: WPARAM = 0; LParam: LPARAM = 0): LRESULT; virtual;

    /// <summary>Posts a fire-and-forget message to the Scintilla control.
    /// Cross-thread posting requires the editor handle to exist already.</summary>
    function PostEditor(AMessage: UINT; WParam: WPARAM = 0; LParam: LPARAM = 0): Boolean; virtual;

  published

    /// <summary>Name of Scintilla Dll which will be used.
    /// Changing DllModule recreates control!</summary>
    property DllModule: String read FSciDllModule write SetSciDllModule;

    /// <summary>Access method to Scintilla contol. Note from documentation:
    /// On Windows, the message-passing scheme used to communicate
    /// between the container and Scintilla is mediated by the operating system
    /// SendMessage function and can lead to bad performance
    /// when calling intensively.
    ///
    /// By default TDScintilla uses smDirect mode</summary>
    property AccessMethod: TDScintillaMethod read FAccessMethod write FAccessMethod default smDirect;

  published
    // TControl properties
    property Constraints;
    property Enabled;
    property Hint;
    property Anchors;
    property PopupMenu;
    property ShowHint;
    property ParentShowHint;
    property Visible;

    // TWinControl properties
    property Align;
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind;
    property BevelWidth;
    property BorderWidth;
    property Ctl3D;
    property DoubleBuffered;
    property DoubleBufferedMode;
    property ParentCtl3D;
    property ParentDoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property ImeMode;
    property ImeName;
    property TabOrder;
    property TabStop default True;
    {$IF CompilerVersion >= 23}
    property Touch;
    {$IFEND}

    // TControl events
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragOver;
    property OnDragDrop;
    property OnEndDrag;
    property OnMouseDown;

    // OnMouseEnter/OnMouseLeave added in D2006
    {$IF CompilerVersion > 17}
    property OnMouseEnter;
    property OnMouseLeave;
    {$IFEND}
    {$IF CompilerVersion >= 23}
    property OnGesture;
    {$IFEND}
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDrag;

    // TWinControl events
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
  end;

implementation

uses
  DScintillaBridge, DScintillaLogger;

{ TDScintillaCustom }

constructor TDScintillaCustom.Create(AOwner: TComponent);
begin
  FSciDllModule := cDScintillaDll;
  FAccessMethod := smDirect;
  FOwnerThreadId := GetCurrentThreadId;
  ResetIndicatorAlphaCache;

  inherited Create(AOwner);

  // TDScintilla cannot use csAcceptsControls, because painting is performed by
  // scintilla, so it doesn't support non-handle controls (like TLabel)
  ControlStyle := ControlStyle
    + [csOpaque, csClickEvents, csDoubleClicks, csCaptureMouse, csReflector]
    - [csSetCaption, csAcceptsControls];

  Width := 320;
  Height := 240;
  TabStop := True;
end;

destructor TDScintillaCustom.Destroy;
begin
  if IsRecreatingWnd then
  begin
    WindowHandle := FStoredWnd.WindowHandle;
    FStoredWnd.WindowHandle := 0;
  end;

  inherited Destroy;

  FreeSciLibrary;
end;

procedure TDScintillaCustom.SetSciDllModule(const Value: String);
{$IFNDEF SCINLILLA_STATIC_LINKING}
var
  lHadHandle: Boolean;
  lSciDllModule: String;
{$ENDIF}
begin
{$IFDEF SCINLILLA_STATIC_LINKING}
  // Static linking: DLL module cannot be switched at runtime.
  FSciDllModule := cDScintillaDll;
{$ELSE}
  lSciDllModule := Trim(Value);
  if lSciDllModule = '' then
    lSciDllModule := cDScintillaDll;

  if SameText(lSciDllModule, FSciDllModule) then
  begin
    FSciDllModule := lSciDllModule;
    Exit;
  end;

  // _SciBridgeDllPath is updated by DoLoad via GetModuleFileName and holds
  // the canonical full path of the currently loaded module.  This catches
  // the common case where FSciDllModule still has the bare DLL name
  // ('Scintilla64.dll') but the caller supplies an absolute path to the
  // same physical file.  Avoid triggering a needless Unload/reload cycle —
  // reloading the same DLL causes ERROR_DLL_INIT_FAILED (1114) because
  // Scintilla's DllMain is not safe to re-enter after DLL_PROCESS_DETACH.
  if (_SciBridgeDllPath <> '') and SameText(lSciDllModule, _SciBridgeDllPath) then
  begin
    FSciDllModule := lSciDllModule;
    Exit;
  end;

  lHadHandle := HandleAllocated;
  if lHadHandle then
  begin
    FForceDestroyWindowHandle := True;
    try
      DestroyHandle;
    finally
      FForceDestroyWindowHandle := False;
    end;
  end;

  // Unload bridge so next EnsureLoaded picks up the new path
  SciBridgeLoader.Unload;
  FSciDllHandle := 0;
  _SciBridgeDllPath := lSciDllModule;
  FSciDllModule := lSciDllModule;

  if lHadHandle and not (csDestroying in ComponentState) then
    HandleNeeded;
{$ENDIF}
end;

procedure TDScintillaCustom.LoadSciLibraryIfNeeded;
begin
  if FSciDllHandle <> 0 then
    Exit;

{$IFNDEF SCINLILLA_STATIC_LINKING}
  // Push custom DLL module into bridge path before loading
  if not SameText(FSciDllModule, cDScintillaDll) and (FSciDllModule <> '') then
  begin
    if _SciBridgeDllPath = '' then
      _SciBridgeDllPath := FSciDllModule;
  end;
{$ENDIF}

  SciBridgeLoader.EnsureLoaded;
  FSciDllHandle := SciBridgeLoader.DllHandle;
end;

procedure TDScintillaCustom.FreeSciLibrary;
begin
  ResetDirectAccessState;
  FSciDllHandle := 0;
  // DLL lifetime is managed by the bridge singleton — do not FreeLibrary here
end;

procedure TDScintillaCustom.ResetIndicatorAlphaCache;
var
  lIndex: Integer;
begin
  for lIndex := Low(FIndicatorAlphaCache) to High(FIndicatorAlphaCache) do
  begin
    FIndicatorAlphaCache[lIndex] := -1;
    FIndicatorOutlineAlphaCache[lIndex] := -1;
  end;
end;

procedure TDScintillaCustom.ResetDirectAccessState;
begin
  FDirectFunction := nil;
  FDirectPointer := nil;
  FNativeThreadId := 0;
end;

function TDScintillaCustom.IsOwnerThread: Boolean;
begin
  Result := GetCurrentThreadId = FOwnerThreadId;
end;

function TDScintillaCustom.EnsureEditorHandleForCall: HWND;
begin
  if HandleAllocated then
    Exit(WindowHandle);

  if not IsOwnerThread then
    raise EInvalidOperation.CreateFmt(
      '%s handle must be created on the owner thread before cross-thread access. Call HandleNeeded on the owner thread first.',
      [ClassName]
    );

  HandleNeeded;
  Result := WindowHandle;
end;

function TDScintillaCustom.IsCachedIndicatorIndex(AIndex: WPARAM): Boolean;
begin
  Result := NativeInt(AIndex) in [Low(FIndicatorAlphaCache)..High(FIndicatorAlphaCache)];
end;

function TDScintillaCustom.NormalizeIndicatorAlphaValue(AValue: LPARAM): Integer;
begin
  Result := NativeInt(AValue);
  if Result < 0 then
    Result := 0
  else if Result > 255 then
    Result := 255;
end;

procedure TDScintillaCustom.DoStoreWnd;
begin
  FStoredWnd.Visible := Visible;
  FStoredWnd.WindowHandle := WindowHandle;

  // Simulate messages passed by DestroyWindow
  SetWindowPos(WindowHandle, 0, 0, 0, 0, 0,
    SWP_HIDEWINDOW or SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER);
  Windows.SetParent(FStoredWnd.WindowHandle, 0);

  // Self.WindowHandle must be set because of UpdateBounds called from WMWindowPosChanged
  // We cannot set csDestroyingHandle to prevent this isse,
  // as it's a private field of TWinControl.
  // SetParent and SetWindowPos calls WMWindowPosChanged
  WindowHandle := 0;

  // TODO: WNDProc?
end;

procedure TDScintillaCustom.DoRestoreWnd(const Params: TCreateParams);
var
  lFlags: UINT;
begin
  WindowHandle := FStoredWnd.WindowHandle;
  FStoredWnd.WindowHandle:= 0;

  // TODO: WNDProc?

  Windows.SetParent(WindowHandle, Params.WndParent);

  lFlags := SWP_FRAMECHANGED or SWP_NOACTIVATE or SWP_NOCOPYBITS or
    SWP_NOOWNERZORDER or SWP_NOZORDER;
  if FStoredWnd.Visible then
    lFlags := lFlags or SWP_SHOWWINDOW;

  // Restore previous size and position (similar as it's done by CreateWindowEx)
  SetWindowPos(WindowHandle, 0, Params.X, Params.Y, Params.Width, Params.Height, lFlags);
end;

procedure TDScintillaCustom.CreateWnd;
begin
  LoadSciLibraryIfNeeded;
  inherited CreateWnd;
end;

procedure TDScintillaCustom.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  // Subclass Scintilla - WND Class was registred at DLL load proc
  CreateSubClass(Params, 'SCINTILLA');
end;

function TDScintillaCustom.IsRecreatingWnd: Boolean;
begin
  Result := FStoredWnd.WindowHandle <> 0;
end;

procedure TDScintillaCustom.CreateWindowHandle(const Params: TCreateParams);
begin
  if IsRecreatingWnd then
    DoRestoreWnd(Params)
  else
    inherited CreateWindowHandle(Params);
end;

procedure TDScintillaCustom.DestroyWindowHandle;
begin
  if (csDestroying in ComponentState) or (csDesigning in ComponentState) or FForceDestroyWindowHandle then
    inherited DestroyWindowHandle
  else
    DoStoreWnd;
end;

procedure TDScintillaCustom.WMCreate(var AMessage: TWMCreate);
begin
  inherited;

  FDirectFunction := TDScintillaDirectFunction(Windows.SendMessage(
    WindowHandle, SCI_GETDIRECTFUNCTION, 0, 0));
  FDirectPointer := Pointer(Windows.SendMessage(
    WindowHandle, SCI_GETDIRECTPOINTER, 0, 0));

  // Save the current thread ID
  FNativeThreadId := GetWindowThreadProcessId(WindowHandle, nil);

  DragAcceptFiles(WindowHandle, True);
end;

procedure TDScintillaCustom.WMDestroy(var AMessage: TWMDestroy);
begin
  inherited;

  // No longer valid after window destroy
  ResetDirectAccessState;
end;

procedure TDScintillaCustom.WMDropFiles(var AMessage: TMessage);
var
  lDrop: HDROP;
  lCount, I: Integer;
  lLen: Integer;
  lFileName: string;
  lFiles: TStringList;
begin
  lDrop := HDROP(AMessage.WParam);
  lFiles := TStringList.Create;
  try
    lCount := DragQueryFile(lDrop, $FFFFFFFF, nil, 0);
    for I := 0 to lCount - 1 do
    begin
      lLen := DragQueryFile(lDrop, I, nil, 0);
      if lLen > 0 then
      begin
        SetLength(lFileName, lLen);
        DragQueryFile(lDrop, I, PChar(lFileName), lLen + 1);
        lFiles.Add(lFileName);
      end;
    end;
    if lFiles.Count > 0 then
      DoDropFiles(lFiles);
  finally
    lFiles.Free;
    DragFinish(lDrop);
  end;
  AMessage.Result := 0;
end;

procedure TDScintillaCustom.DoDropFiles(AFiles: TStrings);
begin
  // Base implementation — descendants override to fire events
end;

procedure TDScintillaCustom.WMEraseBkgnd(var AMessage: TWmEraseBkgnd);
begin
  // WMEraseBkgnd required when DoubleBuffered=True (Issue 23)
  if (csDesigning in ComponentState) or DoubleBuffered then
    inherited
  else
    // Erase background not performed, prevent flickering
    AMessage.Result := 1;
end;

procedure TDScintillaCustom.CMWantSpecialKey(var AMessage: TCMWantSpecialKey);
begin
  inherited;

  case AMessage.CharCode of
    VK_TAB, VK_RETURN, VK_ESCAPE,
    VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN,
    VK_HOME, VK_END, VK_PRIOR, VK_NEXT,
    VK_INSERT, VK_DELETE:
      AMessage.Result := 1;
  end;
end;

procedure TDScintillaCustom.WMGetDlgCode(var AMessage: TWMGetDlgCode);
begin
  inherited;

  // Allow key-codes like Enter, Tab, Arrows, and other to be passed to Scintilla
  AMessage.Result := AMessage.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
  AMessage.Result := AMessage.Result or DLGC_WANTTAB;
  AMessage.Result := AMessage.Result or DLGC_WANTALLKEYS;
end;

procedure TDScintillaCustom.DefaultHandler(var AMessage);
begin

  // In design mode there is an AV when clicking on control whithout this workaround
  // It's wParam HDC vs. PAINTSTRUCT problem:
  (*
  LRESULT ScintillaWin::WndPaint(uptr_t wParam) {
    ...
    PAINTSTRUCT ps;
    PAINTSTRUCT *pps;

    bool IsOcxCtrl = (wParam != 0); // if wParam != 0, it contains
                     // a PAINSTRUCT* from the OCX
  *)

  if (TMessage(AMessage).Msg = WM_PAINT) and (TWMPaint(AMessage).DC <> 0) then
  begin
    // Issue 23: Painting problems when DoubleBuffered is True
    //
    // VCL sends WM_PAINT with wParam=DC when it wants to paint on specific DC (like when using DoubleBuffered).
    // However Scintilla threats wParam as a PAINTSTRUCT (OCX related problem).
    // Previously there was a workaround to set wParam:=0, because it caused AVs in IDE.
    // Now instead of this workaround simulate painting by WM_PRINTCLIENT, as it expects in wParam=DC.
    // Scintilla handles that message - see: http://sourceforge.net/p/scintilla/feature-requests/173/
    TMessage(AMessage).Msg := WM_PRINTCLIENT;
    // TWMPrintClient(AMessage).DC are same as a TWMPaint(AMessage).DC

    // WM_PRINTCLIENT flags are not used now, but pass at least PRF_CLIENT for
    // possible future changes in Scintilla
    TWMPrintClient(AMessage).Flags := PRF_CLIENT;
  end;

  inherited;
end;

procedure TDScintillaCustom.MouseWheelHandler(var AMessage: TMessage);

  function VCLBugWorkaround_ShiftStateToKeys(AShiftState: TShiftState): Word;
  begin
    // Reverse function for Forms.KeysToShiftState
    // However it doesn't revert MK_XBUTTON1/MK_XBUTTON2
    // but Scintilla as of version 3.25 doesn't use it.
    Result := 0;

    if ssShift in AShiftState then
      Result := Result or MK_SHIFT;
    if ssCtrl in AShiftState then
      Result := Result or MK_CONTROL;
    if ssLeft in AShiftState then
      Result := Result or MK_LBUTTON;
    if ssRight in AShiftState then
      Result := Result or MK_RBUTTON;
    if ssMiddle in AShiftState then
      Result := Result or MK_MBUTTON;
  end;

begin
  inherited MouseWheelHandler(AMessage);

  // If message wasn't handled by OnMouseWheel* events ...
  if AMessage.Result = 0 then
  begin
    // Workaround for : https://code.google.com/p/dscintilla/issues/detail?id=5
    //
    // TControl.WMMouseWheel changes WM_MOUSEWHEEL parameters,
    // but doesn't revert then when passing message down.
    //
    // As a workaround try to revert damage done by TControl.WMMouseWheel:
    //   TCMMouseWheel(Message).ShiftState := KeysToShiftState(Message.Keys);
    // Message might not be complete, because of missing MK_XBUTTON1/MK_XBUTTON2
    // flags, however Scintilla doesn't use them as of today.
    TWMMouseWheel(AMessage).Keys := VCLBugWorkaround_ShiftStateToKeys(TCMMouseWheel(AMessage).ShiftState);

    // Pass it down to TWinControl.DefaultHandler->CallWindowProc(WM_MOUSEWHEEL)->Scintilla
    // and mark it as handled so TControl.WMMouseWheel won't call inherited (which calls DefaultHandler)
    inherited DefaultHandler(AMessage);
    AMessage.Result := 1;
  end;
end;

procedure TDScintillaCustom.CacheIndicatorAlpha(AIndicator, AAlpha,
  AOutlineAlpha: Integer);
begin
  if (AIndicator < Low(FIndicatorAlphaCache)) or
     (AIndicator > High(FIndicatorAlphaCache)) then
    Exit;

  FIndicatorAlphaCache[AIndicator] := NormalizeIndicatorAlphaValue(AAlpha);
  FIndicatorOutlineAlphaCache[AIndicator] := NormalizeIndicatorAlphaValue(AOutlineAlpha);
end;

procedure TDScintillaCustom.IndicSetAlphaValue(AIndicator, AAlpha: Integer);
begin
  CacheIndicatorAlpha(AIndicator, AAlpha, IndicGetOutlineAlphaValue(AIndicator));
  SendEditor(SCI_INDICSETALPHA, AIndicator, AAlpha);
end;

function TDScintillaCustom.IndicGetAlphaValue(AIndicator: Integer): Integer;
begin
  if (AIndicator >= Low(FIndicatorAlphaCache)) and
     (AIndicator <= High(FIndicatorAlphaCache)) and
     (FIndicatorAlphaCache[AIndicator] >= 0) then
    Exit(FIndicatorAlphaCache[AIndicator]);
  Result := SendEditor(SCI_INDICGETALPHA, AIndicator, 0);
end;

procedure TDScintillaCustom.IndicSetOutlineAlphaValue(AIndicator, AAlpha: Integer);
begin
  CacheIndicatorAlpha(AIndicator, IndicGetAlphaValue(AIndicator), AAlpha);
  SendEditor(SCI_INDICSETOUTLINEALPHA, AIndicator, AAlpha);
end;

function TDScintillaCustom.IndicGetOutlineAlphaValue(AIndicator: Integer): Integer;
begin
  if (AIndicator >= Low(FIndicatorOutlineAlphaCache)) and
     (AIndicator <= High(FIndicatorOutlineAlphaCache)) and
     (FIndicatorOutlineAlphaCache[AIndicator] >= 0) then
    Exit(FIndicatorOutlineAlphaCache[AIndicator]);
  Result := SendEditor(SCI_INDICGETOUTLINEALPHA, AIndicator, 0);
end;

function TDScintillaCustom.SendEditor(AMessage: UINT; WParam: WPARAM; LParam: LPARAM): LRESULT;
var
  lCachedValue: Integer;
  lHandle: HWND;
  lIndicatorIndex: Integer;
begin
  if IsCachedIndicatorIndex(WParam) then
  begin
    lIndicatorIndex := NativeInt(WParam);
    case AMessage of
      SCI_INDICSETALPHA:
        FIndicatorAlphaCache[lIndicatorIndex] := NormalizeIndicatorAlphaValue(LParam);
      SCI_INDICSETOUTLINEALPHA:
        FIndicatorOutlineAlphaCache[lIndicatorIndex] := NormalizeIndicatorAlphaValue(LParam);
      SCI_INDICGETALPHA:
        begin
          lCachedValue := FIndicatorAlphaCache[lIndicatorIndex];
          if lCachedValue >= 0 then
            Exit(lCachedValue);
        end;
      SCI_INDICGETOUTLINEALPHA:
        begin
          lCachedValue := FIndicatorOutlineAlphaCache[lIndicatorIndex];
          if lCachedValue >= 0 then
            Exit(lCachedValue);
        end;
    end;
  end;

  lHandle := EnsureEditorHandleForCall;

{ See...http://www.scintilla.org/ScintillaDoc.html#DirectAccess

  Per Documentation direct function is used for speed...

    "On Windows, the message-passing scheme used to communicate between the container
     and Scintilla is mediated by the operating system SendMessage function and can
     lead to bad performance when calling intensively. To avoid this overhead, Scintilla
     provides messages that allow you to call the Scintilla message function directly."

  Also per documentation, SendMessage should be used when called from different thread...

    "While faster, this direct calling will cause problems if performed from a different
     thread to the native thread of the Scintilla window in which case
     SendMessage(hSciWnd, SCI_*, wParam, lParam) should be used to synchronize with the
     window's thread."

  Use SendMessage() when we have too. This is a slight adaptation of the original code which
  is commented out below. }

  if (FAccessMethod = smWindows) or
    (not Assigned(FDirectFunction)) or
    (not Assigned(FDirectPointer)) or
    (Windows.GetCurrentThreadId() <> FNativeThreadId) then
  begin
    Result := Windows.SendMessage(lHandle, AMessage, WParam, LParam);
  end
  else
  begin
    Result := FDirectFunction(FDirectPointer, AMessage, WParam, LParam);
  end;

  if IsCachedIndicatorIndex(WParam) then
  begin
    lIndicatorIndex := NativeInt(WParam);
    case AMessage of
      SCI_INDICSETALPHA:
        if FIndicatorAlphaCache[lIndicatorIndex] < 0 then
          FIndicatorAlphaCache[lIndicatorIndex] := NormalizeIndicatorAlphaValue(LParam);
      SCI_INDICSETOUTLINEALPHA:
        if FIndicatorOutlineAlphaCache[lIndicatorIndex] < 0 then
          FIndicatorOutlineAlphaCache[lIndicatorIndex] := NormalizeIndicatorAlphaValue(LParam);
      SCI_INDICGETALPHA:
        if FIndicatorAlphaCache[lIndicatorIndex] < 0 then
          FIndicatorAlphaCache[lIndicatorIndex] := Result;
      SCI_INDICGETOUTLINEALPHA:
        if FIndicatorOutlineAlphaCache[lIndicatorIndex] < 0 then
          FIndicatorOutlineAlphaCache[lIndicatorIndex] := Result;
    end;
  end;
end;

function TDScintillaCustom.PostEditor(AMessage: UINT; WParam: WPARAM; LParam: LPARAM): Boolean;
begin
  Result := Windows.PostMessage(EnsureEditorHandleForCall, AMessage, WParam, LParam);
end;

end.

