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
 * The Original Code is DScintilla.pas
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

unit DScintilla;

interface

uses
  SysUtils, IOUtils, Types, Math, Classes, Windows,
  Messages, Graphics, Controls, Menus, ComCtrls, Forms, Clipbrd,
  DScintillaCustom, DScintillaTypes, DScintillaUtils, DLexilla,
  DScintillaSettings
  ;

type
{ TDScintilla }

  // XE2+
  {$IF CompilerVersion >= 23}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  {$IFEND}

  TDScintilla = class(TDScintillaCustom)
  private
    const cStatusPanelLexer = 0;
    const cStatusPanelPos = 1;
    const cStatusPanelTheme = 2;
    const cStatusPanelFile = 3;
    const cStatusPanelLoad = 4;
    const cStatusPanelEncoding = 5;
    const cStatusPanelCount = 6;
    const cStatusLexerMenuAutoHint = '<auto>';
    const cStatusLexerMenuPlainHint = '<plain>';
  private
    FAutoBraceHighlight: Boolean;
    FCurrentFileName: UnicodeString;
    FDefaultContextMenu: TPopupMenu;
    FDefaultContextMenuEnabled: Boolean;
    FDefaultMenuCopy: TMenuItem;
    FDefaultMenuCopyWithFormatting: TMenuItem;
    FDefaultMenuCut: TMenuItem;
    FDefaultMenuDelete: TMenuItem;
    FDefaultMenuPaste: TMenuItem;
    FDefaultMenuSelectAll: TMenuItem;
    FDefaultMenuFolding: TMenuItem;
    FDefaultMenuFoldAll: TMenuItem;
    FDefaultMenuUnfoldAll: TMenuItem;
    FDefaultMenuFoldCurrent: TMenuItem;
    FDefaultMenuUnfoldCurrent: TMenuItem;
    FDefaultMenuFoldNested: TMenuItem;
    FDefaultMenuUnfoldNested: TMenuItem;
    FDefaultMenuUndo: TMenuItem;
    FGutterContextMenu: TPopupMenu;
    FGutterMenuSettings: TMenuItem;
    FGutterMenuLexer: TMenuItem;
    FGutterMenuEncoding: TMenuItem;
    FGutterMenuTheme: TMenuItem;
    FContextMenuShownByRButton: Boolean;
    FDefaultTechnology: TDSciTechnology;
    FLexilla: TDLexilla;
    FSettings: TDSciSettings;
    FActiveLexerLanguage: UnicodeString;
    FRequestedLexerLanguage: UnicodeString;
    FUseAssignedPopupMenu: Boolean;

    FHelper: TDSciHelper;
    FLines: TDSciLines;

    FFileLoadSequence: Cardinal;
    FFileLoadEncoding: TDSciFileEncoding;
    FFileLoadStatus: TDSciFileLoadStatus;
    FFileLoadThread: TThread;
    FInitDefaultsDelayed: Boolean;
    FPreferredFileEncoding: TDSciFileEncoding;
    FStatusBar: TStatusBar;
    FStatusBarEncodingPopup: TPopupMenu;
    FStatusBarLexerPopup: TPopupMenu;
    FStatusBarThemePopup: TPopupMenu;
    FStatusBarVisible: Boolean;
    FStatusPanelFileVisible: Boolean;
    FStatusPanelPosVisible: Boolean;
    FStatusPanelLexerVisible: Boolean;
    FStatusPanelEncodingVisible: Boolean;
    FStatusPanelThemeVisible: Boolean;
    FStatusPanelLoadVisible: Boolean;
    FUseAutomaticLexerSelection: Boolean;

    FOnInitDefaults: TNotifyEvent;
    FOnStoreDocState: TNotifyEvent;
    FOnRestoreDocState: TNotifyEvent;
    FOnFocusIn: TNotifyEvent;
    FOnFocusOut: TNotifyEvent;

    FOnChange: TNotifyEvent;
    FOnSCNotificationEvent: TDSciNotificationEvent;

    FOnUpdateUI: TDSciUpdateUIEvent;
    FOnSavePointReached: TDSciSavePointReachedEvent;
    FOnZoom: TDSciZoomEvent;
    FOnUserListSelection: TDSciUserListSelectionEvent;
    FOnUserListSelection2: TDSciUserListSelection2Event;
    FOnDwellEnd: TDSciDwellEndEvent;
    FOnPainted: TDSciPaintedEvent;
    FOnModifyAttemptRO: TDSciModifyAttemptROEvent;
    FOnAutoCCharDeleted: TDSciAutoCCharDeletedEvent;
    FOnAutoCCancelled: TDSciAutoCCancelledEvent;
    FOnModified: TDSciModifiedEvent;
    FOnModified2: TDSciModified2Event;
    FOnStyleNeeded: TDSciStyleNeededEvent;
    FOnSavePointLeft: TDSciSavePointLeftEvent;
    FOnIndicatorRelease: TDSciIndicatorReleaseEvent;
    FOnNeedShown: TDSciNeedShownEvent;
    FOnMacroRecord: TDSciMacroRecordEvent;
    FOnCharAdded: TDSciCharAddedEvent;
    FOnCallTipClick: TDSciCallTipClickEvent;
    FOnHotSpotClick: TDSciHotSpotClickEvent;
    FOnMarginClick: TDSciMarginClickEvent;
    FOnHotSpotDoubleClick: TDSciHotSpotDoubleClickEvent;
    FOnHotSpotReleaseClick: TDSciHotSpotReleaseClickEvent;
    FOnDwellStart: TDSciDwellStartEvent;
    FOnIndicatorClick: TDSciIndicatorClickEvent;
    FOnAutoCSelection: TDSciAutoCSelectionEvent;
    FOnFileLoadStateChange: TDSciFileLoadStateEvent;
    FOnDropFiles: TDSciDropFilesEvent;
    FOnGutterSettings: TNotifyEvent;

    function GetLexilla: TDLexilla;
    function GetIsFileLoading: Boolean;
    function GetStatusBarComponentOwner: TComponent;
    function GetStatusBarHost: TWinControl;
    function GetStatusBarPanelAt(X: Integer): Integer;
    function GetStatusThemeName: UnicodeString;
    function ResolveDllModulePath: string;
    function ActiveContextMenu: TPopupMenu;
    function CanReloadFileForEncodingChange(
      const AFileName: UnicodeString): Boolean;
    function ContextMenuClientPoint(const AMessage: TWMContextMenu): TPoint;
    function ContextMenuScreenPoint(const AMessage: TWMContextMenu): TPoint;
    function IsBraceChar(AChar: Integer): Boolean;
    function CreateFileLoader(ATotalBytes: Int64): Pointer;
    function IsFileSizeWithinLimit(AFileSize: Int64): Boolean;
    function IsTerminalFileLoadStage(AStage: TDSciFileLoadStage): Boolean;
    function NeverCancelFileLoad: Boolean;
    function TryDecodeFileText(const AFileName: UnicodeString;
      ARequestedEncoding: TDSciFileEncoding; out AText: UnicodeString;
      out ADetectedEncoding: TDSciFileEncoding;
      out ADetectedCodePage: Cardinal;
      out ADetectedEncodingName: UnicodeString): Boolean;

    procedure ApplyPreferredLanguageSelection(const ALogReason: UnicodeString);
    procedure AttachLoadedDocument(ALoader: Pointer; ADocument: TDSciDocument;
      const AFileName: UnicodeString; AIsAsync: Boolean;
      AEncoding: TDSciFileEncoding; AEncodingCodePage: Cardinal;
      const AEncodingName: UnicodeString);
    procedure BuildDefaultContextMenu;
    procedure BuildStatusBarMenus;
    function BuildHtmlClipboardData(const AHtmlFragment: UnicodeString): UTF8String;
    function BuildSelectionHtmlClipboard(out APlainText: UnicodeString;
      out AHtmlData: UTF8String): Boolean;
    function BuildStatusBarPositionText: UnicodeString;
    function ColorToHtml(AColor: TColor): UnicodeString;
    procedure CreateStatusBarIfNeeded;
    procedure DefaultContextMenuClick(Sender: TObject);
    procedure DefaultContextMenuPopup(Sender: TObject);
    procedure DestroyStatusBar;
    procedure GutterContextMenuPopup(Sender: TObject);
    procedure GutterMenuSettingsClick(Sender: TObject);
    function EscapeHtmlText(const AText: UnicodeString): UnicodeString;
    procedure RebuildStatusBarEncodingMenu;
    procedure RebuildStatusBarLexerMenu;
    procedure RebuildStatusBarThemeMenu;
    procedure ReloadCurrentFileForEncodingChange;
    procedure RefreshStatusBar;
    procedure RefreshStatusBarVisibility;
    procedure SetLines(const Value: TDSciLines);
    procedure SetAutoBraceHighlight(const Value: Boolean);
    procedure SetDefaultContextMenuEnabled(const Value: Boolean);
    procedure SetDefaultTechnology(const Value: TDSciTechnology);
    procedure SetPreferredFileEncoding(const Value: TDSciFileEncoding);
    procedure SetStatusBarVisible(const Value: Boolean);
    procedure SetUseAssignedPopupMenu(const Value: Boolean);
    procedure SetClipboardHtml(const APlainText: UnicodeString;
      const AHtmlData: UTF8String);
    procedure SetClipboardTextData(const APlainText: UnicodeString);
    procedure SetClipboardUtf8Data(AFormat: UINT; const AData: UTF8String);
    procedure SetFileLoadStatus(const AStatus: TDSciFileLoadStatus);
    procedure ReportSynchronousFileLoadStage(AStage: TDSciFileLoadStage;
      ABytesRead, ATotalBytes: Int64; const AErrorMessage: UnicodeString;
      AEncoding: TDSciFileEncoding; AEncodingCodePage: Cardinal;
      const AEncodingName: UnicodeString);
    procedure StatusBarEncodingMenuItemClick(Sender: TObject);
    procedure StatusBarLexerMenuItemClick(Sender: TObject);
    procedure StatusBarThemeMenuItemClick(Sender: TObject);
    procedure StatusBarContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure StatusBarMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function StyleToHtmlCss(AStyle: Integer): UnicodeString;
    procedure FinalizeFileLoadThread;
    procedure FlushPendingFileLoadMessages;

  strict protected
    {$I DScintillaUnsafeDecl.inc}

  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure Loaded; override;

    /// <summary>Initializes Scintilla control after creating or recreating window</summary>
    procedure InitDefaults; virtual;
    procedure DoInitDefaults;

    /// <summary>Handles SCEN_CHANGE message from Scintilla</summary>
    procedure CNCommand(var AMessage: TWMCommand); message CN_COMMAND;

    /// <summary>Handles notification messages from Scintilla</summary>
    procedure CNNotify(var AMessage: TWMNotify); message CN_NOTIFY; // Thanks to Marko Njezic there is no need to patch Scintilla anymore :)
    procedure CMVisibleChanged(var AMessage: TMessage); message CM_VISIBLECHANGED;
    procedure WMClear(var AMessage: TMessage); message WM_CLEAR;
    procedure WMCopy(var AMessage: TMessage); message WM_COPY;
    procedure WMContextMenu(var AMessage: TWMContextMenu); message WM_CONTEXTMENU;
    procedure WMRButtonUp(var AMessage: TWMRButtonUp); message WM_RBUTTONUP;
    procedure WMCut(var AMessage: TMessage); message WM_CUT;
    procedure WMPaste(var AMessage: TMessage); message WM_PASTE;
    procedure WMDSciFileLoadAttach(var AMessage: TMessage); message WM_APP + 201;
    procedure WMDSciReloadForEncodingChange(var AMessage: TMessage); message WM_APP + 202;
    procedure WMDSciFileLoadStatus(var AMessage: TMessage); message WM_APP + 200;
    procedure WMUndo(var AMessage: TMessage); message WM_UNDO;

    procedure ApplyBraceHighlight(AHighlightPos, AMatchPos: NativeInt); virtual;
    procedure DoFileLoadStateChange(const AStatus: TDSciFileLoadStatus); virtual;
    procedure DoLoaderDocumentAttached; virtual;

    procedure DoNeedShown(const ASCNotification: TDSciSCNotification); virtual;
    procedure DoDropFiles(AFiles: TStrings); override;
    function DoSCNotification(const ASCNotification: TDSciSCNotification): Boolean; virtual;
    procedure DoUpdateUI(AFlags: TDSciUpdateFlagsSet); virtual;
    procedure ShowContextMenu(APopupMenu: TPopupMenu; const AScreenPoint: TPoint); virtual;
    procedure UpdateBraceHighlighting; virtual;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  public

    // -------------------------------------------------------------------------
    // Scintilla methods -------------------------------------------------------
    // -------------------------------------------------------------------------

    {$I DScintillaMethodsDecl.inc}

  public

    // -------------------------------------------------------------------------
    // Scintilla properties ----------------------------------------------------
    // -------------------------------------------------------------------------

    {$I DScintillaPropertiesDecl.inc}
    {$I DScintillaPublicPropertiesDecl.inc}

    /// <summary>Calls TWinControl.SetFocus</summary>
    procedure SetFocus; reintroduce; overload;

    procedure CancelLoadFromFile(AWait: Boolean = True);
    function BeginLoadFromFile(const AFileName: UnicodeString): Boolean; overload;
    function BeginLoadFromFile(const AFileName: UnicodeString;
      AEncoding: TDSciFileEncoding): Boolean; overload;
    procedure CopySelectionAsHtml;
    procedure EnsureRangeVisible(APosStart, APosEnd: Integer);
    function LoadFromFile(const AFileName: UnicodeString): Boolean; overload;
    function LoadFromFile(const AFileName: UnicodeString;
      AEncoding: TDSciFileEncoding): Boolean; overload;
    function SaveToFile(const AFileName: UnicodeString): Boolean; overload;
    function SaveToFile(const AFileName: UnicodeString;
      AEncoding: TDSciFileEncoding): Boolean; overload;
    procedure ReapplyPreferredLanguageSelection;
    procedure RefreshManagedStatusBar;
    function GetEffectiveFileSizeLimit: Int64;
    function IsPointInMarginArea(const AClientPoint: TPoint): Boolean;

    property CurrentFileName: UnicodeString read FCurrentFileName;
    property FileLoadStatus: TDSciFileLoadStatus read FFileLoadStatus;
    property FileLoadEncoding: TDSciFileEncoding read FFileLoadEncoding;
    property IsFileLoading: Boolean read GetIsFileLoading;
    property Lexilla: TDLexilla read GetLexilla;
    property PreferredFileEncoding: TDSciFileEncoding
      read FPreferredFileEncoding write SetPreferredFileEncoding;
    property Settings: TDSciSettings read FSettings;
    property StatusBar: TStatusBar read FStatusBar;
    property StatusPanelFileVisible: Boolean read FStatusPanelFileVisible write FStatusPanelFileVisible;
    property StatusPanelPosVisible: Boolean read FStatusPanelPosVisible write FStatusPanelPosVisible;
    property StatusPanelLexerVisible: Boolean read FStatusPanelLexerVisible write FStatusPanelLexerVisible;
    property StatusPanelEncodingVisible: Boolean read FStatusPanelEncodingVisible write FStatusPanelEncodingVisible;
    property StatusPanelThemeVisible: Boolean read FStatusPanelThemeVisible write FStatusPanelThemeVisible;
    property StatusPanelLoadVisible: Boolean read FStatusPanelLoadVisible write FStatusPanelLoadVisible;

  published

    {$I DScintillaPublishedPropertiesDecl.inc}

    property Lines: TDSciLines read FLines write SetLines;
    property AutoBraceHighlight: Boolean read FAutoBraceHighlight
      write SetAutoBraceHighlight default True;
    property UseAssignedPopupMenu: Boolean read FUseAssignedPopupMenu
      write SetUseAssignedPopupMenu default True;
    property UseDefaultContextMenu: Boolean read FDefaultContextMenuEnabled
      write SetDefaultContextMenuEnabled default True;
    property DefaultTechnology: TDSciTechnology read FDefaultTechnology
      write SetDefaultTechnology default sctDIRECT_WRITE_RETAIN;
    property StatusBarVisible: Boolean read FStatusBarVisible
      write SetStatusBarVisible default False;

    // Called after when window is created or recreated
    property OnInitDefaults: TNotifyEvent read FOnInitDefaults write FOnInitDefaults;
    // Called when "Settings..." is clicked in the gutter context menu
    property OnGutterSettings: TNotifyEvent read FOnGutterSettings write FOnGutterSettings;

    // Deprecated
    property OnStoreDocState: TNotifyEvent read FOnStoreDocState write FOnStoreDocState;
    property OnRestoreDocState: TNotifyEvent read FOnRestoreDocState write FOnRestoreDocState;

    // Scintilla events - see documentation at http://www.scintilla.org/ScintillaDoc.html#Notifications

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnSCNotificationEvent: TDSciNotificationEvent read FOnSCNotificationEvent write FOnSCNotificationEvent;
    property OnFocusIn: TNotifyEvent read FOnFocusIn write FOnFocusIn;
    property OnFocusOut: TNotifyEvent read FOnFocusOut write FOnFocusOut;

    property OnStyleNeeded: TDSciStyleNeededEvent read FOnStyleNeeded write FOnStyleNeeded;
    property OnCharAdded: TDSciCharAddedEvent read FOnCharAdded write FOnCharAdded;
    property OnSavePointReached: TDSciSavePointReachedEvent read FOnSavePointReached write FOnSavePointReached;
    property OnSavePointLeft: TDSciSavePointLeftEvent read FOnSavePointLeft write FOnSavePointLeft;
    property OnModifyAttemptRO: TDSciModifyAttemptROEvent read FOnModifyAttemptRO write FOnModifyAttemptRO;
    property OnUpdateUI: TDSciUpdateUIEvent read FOnUpdateUI write FOnUpdateUI;
    property OnModified: TDSciModifiedEvent read FOnModified write FOnModified; // deprecated - use OnModified2
    property OnModified2: TDSciModified2Event read FOnModified2 write FOnModified2;
    property OnMacroRecord: TDSciMacroRecordEvent read FOnMacroRecord write FOnMacroRecord;
    property OnMarginClick: TDSciMarginClickEvent read FOnMarginClick write FOnMarginClick;

    // Note: if you are using OnNeedShown, then you must perform similar task as in DoNeedShown
    // In general you need to call EnsureRangeVisible(...)
    // See: https://code.google.com/p/dscintilla/issues/detail?id=4
    property OnNeedShown: TDSciNeedShownEvent read FOnNeedShown write FOnNeedShown;
    property OnPainted: TDSciPaintedEvent read FOnPainted write FOnPainted;
    property OnUserListSelection: TDSciUserListSelectionEvent read FOnUserListSelection write FOnUserListSelection; // deprecated - use OnUserListSelection2
    property OnUserListSelection2: TDSciUserListSelection2Event read FOnUserListSelection2 write FOnUserListSelection2;
    property OnDwellStart: TDSciDwellStartEvent read FOnDwellStart write FOnDwellStart;
    property OnDwellEnd: TDSciDwellEndEvent read FOnDwellEnd write FOnDwellEnd;
    property OnZoom: TDSciZoomEvent read FOnZoom write FOnZoom;
    property OnHotSpotClick: TDSciHotSpotClickEvent read FOnHotSpotClick write FOnHotSpotClick;
    property OnHotSpotDoubleClick: TDSciHotSpotDoubleClickEvent read FOnHotSpotDoubleClick write FOnHotSpotDoubleClick;
    property OnHotSpotReleaseClick: TDSciHotSpotReleaseClickEvent read FOnHotSpotReleaseClick write FOnHotSpotReleaseClick;
    property OnCallTipClick: TDSciCallTipClickEvent read FOnCallTipClick write FOnCallTipClick;
    property OnAutoCSelection: TDSciAutoCSelectionEvent read FOnAutoCSelection write FOnAutoCSelection;
    property OnIndicatorClick: TDSciIndicatorClickEvent read FOnIndicatorClick write FOnIndicatorClick;
    property OnIndicatorRelease: TDSciIndicatorReleaseEvent read FOnIndicatorRelease write FOnIndicatorRelease;
    property OnAutoCCancelled: TDSciAutoCCancelledEvent read FOnAutoCCancelled write FOnAutoCCancelled;
    property OnAutoCCharDeleted: TDSciAutoCCharDeletedEvent read FOnAutoCCharDeleted write FOnAutoCCharDeleted;
    property OnFileLoadStateChange: TDSciFileLoadStateEvent
      read FOnFileLoadStateChange write FOnFileLoadStateChange;
    property OnDropFiles: TDSciDropFilesEvent read FOnDropFiles write FOnDropFiles;
  end;

implementation

uses
  DScintillaBridge, DScintillaDefaultConfig, DScintillaLogger,
  DScintillaVisualConfig;

{ TDScintilla }

const
  cDSciFileLoadStatusMessage = WM_APP + 200;
  cDSciFileLoadAttachMessage = WM_APP + 201;
  cDSciReloadForEncodingChangeMessage = WM_APP + 202;
  cDefaultContextMenuTagUndo = 1;
  cDefaultContextMenuTagCut = 2;
  cDefaultContextMenuTagCopy = 3;
  cDefaultContextMenuTagCopyWithFormatting = 4;
  cDefaultContextMenuTagPaste = 5;
  cDefaultContextMenuTagDelete = 6;
  cDefaultContextMenuTagSelectAll = 7;
  cDefaultContextMenuTagFoldAll = 10;
  cDefaultContextMenuTagUnfoldAll = 11;
  cDefaultContextMenuTagFoldCurrent = 12;
  cDefaultContextMenuTagUnfoldCurrent = 13;
  cDefaultContextMenuTagFoldNested = 14;
  cDefaultContextMenuTagUnfoldNested = 15;
  cHtmlClipboardFormatName = 'HTML Format';

type
  TDSciLoaderReleaseProc = function(ALoader: Pointer): Integer; stdcall;
  TDSciLoaderAddDataProc = function(ALoader: Pointer; const AData: Pointer;
    ALength: NativeInt): Integer; stdcall;
  TDSciLoaderConvertProc = function(ALoader: Pointer): TDSciDocument; stdcall;
  PDSciLoaderVTable = ^TDSciLoaderVTable;
  TDSciLoaderVTable = record
    Release: TDSciLoaderReleaseProc;
    AddData: TDSciLoaderAddDataProc;
    ConvertToDocument: TDSciLoaderConvertProc;
  end;

  TDSciFileLoadReporter = procedure(AStage: TDSciFileLoadStage;
    ABytesRead, ATotalBytes: Int64; const AErrorMessage: UnicodeString;
    AEncoding: TDSciFileEncoding; AEncodingCodePage: Cardinal;
    const AEncodingName: UnicodeString) of object;
  TDSciCancelCheck = function: Boolean of object;

  TDSciFileLoadStatusPayload = class
  public
    Sequence: Cardinal;
    Status: TDSciFileLoadStatus;
  end;

  TDSciFileLoadAttachPayload = class
  public
    Sequence: Cardinal;
    FileName: UnicodeString;
    Loader: Pointer;
    Document: TDSciDocument;
    IsAsync: Boolean;
    Encoding: TDSciFileEncoding;
    EncodingCodePage: Cardinal;
    EncodingName: UnicodeString;
  end;

  TDSciAsyncFileLoadThread = class(TThread)
  private
    FEncoding: TDSciFileEncoding;
    FFileName: UnicodeString;
    FLoader: Pointer;
    FSequence: Cardinal;
    FTargetHandle: HWND;
    function IsCancelled: Boolean;
    function PostAttachPayload(APayload: TDSciFileLoadAttachPayload): Boolean;
    function PostStatusPayload(APayload: TDSciFileLoadStatusPayload): Boolean;
    procedure ReleaseLoader;
    procedure ReportLoadStage(AStage: TDSciFileLoadStage;
      ABytesRead, ATotalBytes: Int64; const AErrorMessage: UnicodeString;
      AEncoding: TDSciFileEncoding; AEncodingCodePage: Cardinal;
      const AEncodingName: UnicodeString);
  protected
    procedure Execute; override;
  public
    constructor Create(ATargetHandle: HWND; const AFileName: UnicodeString;
      ALoader: Pointer; ASequence: Cardinal; AEncoding: TDSciFileEncoding);
    destructor Destroy; override;
  end;

var
  gHtmlClipboardFormat: UINT;

function IsDirectWriteTechnology(ATechnology: TDSciTechnology): Boolean;
begin
  Result := ATechnology in [sctDIRECT_WRITE, sctDIRECT_WRITE_RETAIN,
    sctDIRECT_WRITE_D_C, sctDIRECT_WRITE_1];
end;

function DetectUserFontLocale: UnicodeString;
var
  lBuffer: array[0..LOCALE_NAME_MAX_LENGTH] of Char;
begin
  FillChar(lBuffer, SizeOf(lBuffer), 0);
  if GetUserDefaultLocaleName(@lBuffer[0], LOCALE_NAME_MAX_LENGTH) > 0 then
    Result := PChar(@lBuffer[0])
  else
    Result := '';
end;

function LoaderVTable(ALoader: Pointer): PDSciLoaderVTable;
begin
  if ALoader = nil then
    Exit(nil);
  Result := PDSciLoaderVTable(PPointer(ALoader)^);
end;

function MakeFileLoadStatus(const AFileName: UnicodeString;
  AStage: TDSciFileLoadStage; ABytesRead, ATotalBytes: Int64;
  const AErrorMessage: UnicodeString; AIsAsync: Boolean;
  AEncoding: TDSciFileEncoding = dsfeAutoDetect; AEncodingCodePage: Cardinal = 0;
  const AEncodingName: UnicodeString = ''): TDSciFileLoadStatus;
begin
  Result.FileName := AFileName;
  Result.Stage := AStage;
  Result.BytesRead := ABytesRead;
  Result.TotalBytes := ATotalBytes;
  Result.ErrorMessage := AErrorMessage;
  Result.IsAsync := AIsAsync;
  Result.Encoding := AEncoding;
  Result.EncodingCodePage := AEncodingCodePage;
  Result.EncodingName := AEncodingName;
end;

function FileLoadStageName(AStage: TDSciFileLoadStage): UnicodeString;
begin
  case AStage of
    sflsIdle:
      Result := 'idle';
    sflsPreparing:
      Result := 'preparing';
    sflsReading:
      Result := 'reading';
    sflsDecoding:
      Result := 'decoding';
    sflsLoading:
      Result := 'loading';
    sflsAttaching:
      Result := 'attaching';
    sflsCompleted:
      Result := 'completed';
    sflsFailed:
      Result := 'failed';
    sflsCancelled:
      Result := 'cancelled';
  else
    Result := 'unknown';
  end;
end;

procedure ReleaseLoaderPointer(ALoader: Pointer);
var
  lLoaderVTable: PDSciLoaderVTable;
begin
  lLoaderVTable := LoaderVTable(ALoader);
  if (ALoader <> nil) and (lLoaderVTable <> nil) then
    lLoaderVTable.Release(ALoader);
end;

function RunFileLoadToLoader(const AFileName: UnicodeString; ALoader: Pointer;
  ARequestedEncoding: TDSciFileEncoding; AIsAsync: Boolean;
  AReporter: TDSciFileLoadReporter; ACancelCheck: TDSciCancelCheck;
  out ADocument: TDSciDocument; out ADetectedEncoding: TDSciFileEncoding;
  out ADetectedCodePage: Cardinal; out ADetectedEncodingName: UnicodeString): Boolean;
const
  cBackgroundChunkSize = 64 * 1024;
var
  lDetectedCodePage: Cardinal;
  lDetectedEncoding: TDSciFileEncoding;
  lDetectedEncodingName: UnicodeString;
  lBytes: TBytes;
  lChunkLength: Integer;
  lEncoding: TEncoding;
  lFileSize: Int64;
  lLoaderVTable: PDSciLoaderVTable;
  lOffset: Integer;
  lPreambleSize: Integer;
  lReadCount: Integer;
  lStatus: Integer;
  lStream: TFileStream;
  lText: UnicodeString;
  lUtf8Bytes: TBytes;
  lUtf8Length: Integer;

  function IsCancelled: Boolean;
  begin
    Result := Assigned(ACancelCheck) and ACancelCheck();
  end;

  procedure ReportStage(AStage: TDSciFileLoadStage; ABytesRead, ATotalBytes: Int64;
    const AErrorMessage: UnicodeString = ''; AEncoding: TDSciFileEncoding = dsfeAutoDetect;
    AEncodingCodePage: Cardinal = 0; const AEncodingName: UnicodeString = '');
  begin
    if Assigned(AReporter) then
      AReporter(AStage, ABytesRead, ATotalBytes, AErrorMessage,
        AEncoding, AEncodingCodePage, AEncodingName);
  end;

  function AddBytesToLoader(const ASourceBytes: TBytes; AStartOffset: Integer): Boolean;
  begin
    lUtf8Length := Max(0, Length(ASourceBytes) - AStartOffset);
    ReportStage(sflsLoading, 0, lUtf8Length, '', lDetectedEncoding,
      lDetectedCodePage, lDetectedEncodingName);

    lOffset := AStartOffset;
    while lOffset < Length(ASourceBytes) do
    begin
      if IsCancelled then
      begin
        ReportStage(sflsCancelled, lOffset - AStartOffset, lUtf8Length, '',
          lDetectedEncoding, lDetectedCodePage, lDetectedEncodingName);
        Exit(False);
      end;

      lChunkLength := Min(cBackgroundChunkSize, Length(ASourceBytes) - lOffset);
      lStatus := lLoaderVTable.AddData(ALoader, @ASourceBytes[lOffset], lChunkLength);
      if lStatus <> SC_STATUS_OK then
        raise EInvalidOpException.CreateFmt(
          'Loader AddData failed with status %d.', [lStatus]);
      Inc(lOffset, lChunkLength);
      ReportStage(sflsLoading, lOffset - AStartOffset, lUtf8Length, '',
        lDetectedEncoding, lDetectedCodePage, lDetectedEncodingName);
    end;

    Result := True;
  end;
begin
  ADetectedEncoding := dsfeAutoDetect;
  ADetectedCodePage := 0;
  ADetectedEncodingName := '';
  ADocument := nil;
  lLoaderVTable := LoaderVTable(ALoader);
  if ALoader = nil then
  begin
    ReportStage(sflsFailed, 0, 0, 'SCI_CREATELOADER returned nil.',
      ARequestedEncoding, DSciFileEncodingCodePage(ARequestedEncoding),
      DSciFileEncodingDisplayName(ARequestedEncoding));
    Exit(False);
  end;
  if lLoaderVTable = nil then
  begin
    ReportStage(sflsFailed, 0, 0, 'Loader vtable is unavailable.',
      ARequestedEncoding, DSciFileEncodingCodePage(ARequestedEncoding),
      DSciFileEncodingDisplayName(ARequestedEncoding));
    Exit(False);
  end;

  try
    ReportStage(sflsPreparing, 0, 0, '', ARequestedEncoding,
      DSciFileEncodingCodePage(ARequestedEncoding),
      DSciFileEncodingDisplayName(ARequestedEncoding));
    if IsCancelled then
    begin
      ReportStage(sflsCancelled, 0, 0, '', ARequestedEncoding,
        DSciFileEncodingCodePage(ARequestedEncoding),
        DSciFileEncodingDisplayName(ARequestedEncoding));
      Exit(False);
    end;

    lStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
    try
      lFileSize := lStream.Size;
      if lFileSize > MaxInt then
        raise EInvalidOpException.CreateFmt(
          'LoadFromFile supports files up to %d bytes.', [MaxInt]);

      SetLength(lBytes, Integer(lFileSize));
      lOffset := 0;
      while lOffset < Length(lBytes) do
      begin
        if IsCancelled then
        begin
          ReportStage(sflsCancelled, lOffset, lFileSize, '', ARequestedEncoding,
            DSciFileEncodingCodePage(ARequestedEncoding),
            DSciFileEncodingDisplayName(ARequestedEncoding));
          Exit(False);
        end;

        lReadCount := lStream.Read(lBytes[lOffset],
          Min(cBackgroundChunkSize, Length(lBytes) - lOffset));
        if lReadCount <= 0 then
          Break;
        Inc(lOffset, lReadCount);
        ReportStage(sflsReading, lOffset, lFileSize, '', ARequestedEncoding,
          DSciFileEncodingCodePage(ARequestedEncoding),
          DSciFileEncodingDisplayName(ARequestedEncoding));
      end;

      if lOffset <> Length(lBytes) then
        raise EReadError.CreateFmt(
          'Expected to read %d bytes but only received %d bytes.',
          [Length(lBytes), lOffset]);
    finally
      lStream.Free;
    end;

    if IsCancelled then
    begin
      ReportStage(sflsCancelled, lFileSize, lFileSize, '', ARequestedEncoding,
        DSciFileEncodingCodePage(ARequestedEncoding),
        DSciFileEncodingDisplayName(ARequestedEncoding));
      Exit(False);
    end;

    if not ResolveFileEncoding(lBytes, ARequestedEncoding, lEncoding,
      lPreambleSize, lDetectedEncoding, lDetectedCodePage, lDetectedEncodingName) then
      raise EInvalidOpException.Create('Unable to resolve file encoding.');

    ADetectedEncoding := lDetectedEncoding;
    ADetectedCodePage := lDetectedCodePage;
    ADetectedEncodingName := lDetectedEncodingName;

    try
      if lEncoding <> TEncoding.UTF8 then
      begin
        ReportStage(sflsDecoding, 0, lFileSize, '', lDetectedEncoding,
          lDetectedCodePage, lDetectedEncodingName);
        if Length(lBytes) = 0 then
          lText := ''
        else
          lText := lEncoding.GetString(lBytes, lPreambleSize,
            Length(lBytes) - lPreambleSize);
        lUtf8Bytes := TEncoding.UTF8.GetBytes(lText);
        if not AddBytesToLoader(lUtf8Bytes, 0) then
          Exit(False);
      end
      else
      begin
        if not AddBytesToLoader(lBytes, lPreambleSize) then
          Exit(False);
      end;
    finally
      if not TEncoding.IsStandardEncoding(lEncoding) then
        lEncoding.Free;
    end;

    if IsCancelled then
    begin
      ReportStage(sflsCancelled, lUtf8Length, lUtf8Length, '', lDetectedEncoding,
        lDetectedCodePage, lDetectedEncodingName);
      Exit(False);
    end;

    ADocument := lLoaderVTable.ConvertToDocument(ALoader);
    if ADocument = nil then
      raise EInvalidOpException.Create('Loader ConvertToDocument returned nil.');

    ReportStage(sflsAttaching, lUtf8Length, lUtf8Length, '', lDetectedEncoding,
      lDetectedCodePage, lDetectedEncodingName);
    Result := True;
  except
    on E: Exception do
    begin
      ReportStage(sflsFailed, 0, 0, E.Message, ADetectedEncoding,
        ADetectedCodePage, ADetectedEncodingName);
      Result := False;
    end;
  end;
end;

function HtmlClipboardFormat: UINT;
begin
  if gHtmlClipboardFormat = 0 then
    gHtmlClipboardFormat := RegisterClipboardFormat(cHtmlClipboardFormatName);
  Result := gHtmlClipboardFormat;
end;

{ TDSciAsyncFileLoadThread }

constructor TDSciAsyncFileLoadThread.Create(ATargetHandle: HWND;
  const AFileName: UnicodeString; ALoader: Pointer; ASequence: Cardinal;
  AEncoding: TDSciFileEncoding);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FEncoding := AEncoding;
  FTargetHandle := ATargetHandle;
  FFileName := AFileName;
  FLoader := ALoader;
  FSequence := ASequence;
end;

destructor TDSciAsyncFileLoadThread.Destroy;
begin
  ReleaseLoader;
  inherited Destroy;
end;

function TDSciAsyncFileLoadThread.IsCancelled: Boolean;
begin
  Result := Terminated;
end;

function TDSciAsyncFileLoadThread.PostAttachPayload(
  APayload: TDSciFileLoadAttachPayload): Boolean;
begin
  Result := (FTargetHandle <> 0) and
    PostMessage(FTargetHandle, cDSciFileLoadAttachMessage, 0,
      LPARAM(APayload));
end;

function TDSciAsyncFileLoadThread.PostStatusPayload(
  APayload: TDSciFileLoadStatusPayload): Boolean;
begin
  Result := (FTargetHandle <> 0) and
    PostMessage(FTargetHandle, cDSciFileLoadStatusMessage, 0,
      LPARAM(APayload));
end;

procedure TDSciAsyncFileLoadThread.ReleaseLoader;
begin
  if FLoader <> nil then
  begin
    ReleaseLoaderPointer(FLoader);
    FLoader := nil;
  end;
end;

procedure TDSciAsyncFileLoadThread.ReportLoadStage(AStage: TDSciFileLoadStage;
  ABytesRead, ATotalBytes: Int64; const AErrorMessage: UnicodeString;
  AEncoding: TDSciFileEncoding; AEncodingCodePage: Cardinal;
  const AEncodingName: UnicodeString);
var
  lPayload: TDSciFileLoadStatusPayload;
begin
  lPayload := TDSciFileLoadStatusPayload.Create;
  lPayload.Sequence := FSequence;
  lPayload.Status := MakeFileLoadStatus(FFileName, AStage, ABytesRead,
    ATotalBytes, AErrorMessage, True, AEncoding, AEncodingCodePage,
    AEncodingName);
  if not PostStatusPayload(lPayload) then
    lPayload.Free;
end;

procedure TDSciAsyncFileLoadThread.Execute;
var
  lAttachPayload: TDSciFileLoadAttachPayload;
  lDetectedCodePage: Cardinal;
  lDetectedEncoding: TDSciFileEncoding;
  lDetectedEncodingName: UnicodeString;
  lDocument: TDSciDocument;
begin
  lDocument := nil;
  if not RunFileLoadToLoader(FFileName, FLoader, FEncoding, True,
    ReportLoadStage, IsCancelled, lDocument, lDetectedEncoding,
    lDetectedCodePage, lDetectedEncodingName) then
    Exit;

  lAttachPayload := TDSciFileLoadAttachPayload.Create;
  lAttachPayload.Sequence := FSequence;
  lAttachPayload.FileName := FFileName;
  lAttachPayload.Loader := FLoader;
  lAttachPayload.Document := lDocument;
  lAttachPayload.IsAsync := True;
  lAttachPayload.Encoding := lDetectedEncoding;
  lAttachPayload.EncodingCodePage := lDetectedCodePage;
  lAttachPayload.EncodingName := lDetectedEncodingName;

  FLoader := nil;
  if not PostAttachPayload(lAttachPayload) then
  begin
    ReleaseLoaderPointer(lAttachPayload.Loader);
    lAttachPayload.Free;
  end;
end;

constructor TDScintilla.Create(AOwner: TComponent);
begin
  FAutoBraceHighlight := True;
  FDefaultContextMenuEnabled := True;
  FUseAssignedPopupMenu := True;
  FDefaultTechnology := sctDIRECT_WRITE_RETAIN;
  FFileLoadEncoding := dsfeAutoDetect;
  FFileLoadStatus := MakeFileLoadStatus('', sflsIdle, 0, 0, '', False);
  FPreferredFileEncoding := dsfeAutoDetect;
  FStatusBar := nil;
  FStatusBarVisible := False;
  FStatusPanelFileVisible := False;
  FStatusPanelPosVisible := True;
  FStatusPanelLexerVisible := True;
  FStatusPanelEncodingVisible := False;
  FStatusPanelThemeVisible := False;
  FStatusPanelLoadVisible := False;
  FUseAutomaticLexerSelection := True;
  FSettings := TDSciSettings.Create(Self);
  FHelper := TDSciHelper.Create(SendEditor);
  FLines := TDSciLines.Create(FHelper);

  inherited Create(AOwner);
  BuildDefaultContextMenu;
end;

destructor TDScintilla.Destroy;
begin
  CancelLoadFromFile(True);
  DestroyStatusBar;
  inherited Destroy;
  FreeAndNil(FSettings);
  FreeAndNil(FLines);
  FreeAndNil(FHelper);
  FreeAndNil(FLexilla);
end;

procedure TDScintilla.SetLines(const Value: TDSciLines);
begin
  FLines.Assign(Value);
end;

function TDScintilla.GetIsFileLoading: Boolean;
begin
  Result := (FFileLoadStatus.Stage <> sflsIdle) and
    not IsTerminalFileLoadStage(FFileLoadStatus.Stage);
end;

function TDScintilla.CreateFileLoader(ATotalBytes: Int64): Pointer;
begin
  if ATotalBytes < 0 then
    ATotalBytes := 0;
  if ATotalBytes > High(NativeInt) then
    ATotalBytes := High(NativeInt);
  Result := CreateLoader(ATotalBytes);
end;

function TDScintilla.IsFileSizeWithinLimit(AFileSize: Int64): Boolean;
var
  lConfig: TDSciVisualConfig;
  lConfigObject: TObject;
  lLimit: Int64;
begin
  lConfig := nil;
  if Assigned(FSettings) and FSettings.GetCurrentConfig(lConfigObject) and
    (lConfigObject is TDSciVisualConfig) then
    lConfig := TDSciVisualConfig(lConfigObject);
  lLimit := 0;
  if lConfig <> nil then
    lLimit := lConfig.FileSizeLimit;
  if lLimit <= 0 then
    Exit(True);
  Result := AFileSize <= lLimit;
  if not Result then
    DSciLog(Format(
      '[DSCI] File size (%d bytes) exceeds configured limit (%d bytes), load rejected.',
      [AFileSize, lLimit]), cDSciLogInfo);
end;

function TDScintilla.GetEffectiveFileSizeLimit: Int64;
var
  lConfig: TDSciVisualConfig;
  lConfigObject: TObject;
begin
  lConfig := nil;
  if Assigned(FSettings) and FSettings.GetCurrentConfig(lConfigObject) and
    (lConfigObject is TDSciVisualConfig) then
    lConfig := TDSciVisualConfig(lConfigObject);
  if (lConfig = nil) or (lConfig.FileSizeLimit <= 0) then
    Result := 0
  else
    Result := lConfig.FileSizeLimit;
end;

function TDScintilla.IsTerminalFileLoadStage(
  AStage: TDSciFileLoadStage): Boolean;
begin
  Result := AStage in [sflsCompleted, sflsFailed, sflsCancelled];
end;

function TDScintilla.NeverCancelFileLoad: Boolean;
begin
  Result := False;
end;

procedure TDScintilla.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation <> opRemove then
    Exit;

  if AComponent = FStatusBar then
    FStatusBar := nil
  else if AComponent = FStatusBarEncodingPopup then
    FStatusBarEncodingPopup := nil
  else if AComponent = FStatusBarLexerPopup then
    FStatusBarLexerPopup := nil
  else if AComponent = FStatusBarThemePopup then
    FStatusBarThemePopup := nil;
end;

function TDScintilla.GetStatusBarComponentOwner: TComponent;
begin
  // Keep companion UI owned by the editor so the editor can free or rebuild it
  // without depending on external form-destruction order.
  Result := Self;
end;

function TDScintilla.GetStatusBarHost: TWinControl;
begin
  Result := Parent;
end;

function TDScintilla.GetStatusThemeName: UnicodeString;
var
  lConfigObject: TObject;
begin
  Result := '';
  if Assigned(FSettings) and FSettings.GetCurrentConfig(lConfigObject) and
    (lConfigObject is TDSciVisualConfig) then
    Result := Trim(TDSciVisualConfig(lConfigObject).ThemeName);
end;

function TDScintilla.CanReloadFileForEncodingChange(
  const AFileName: UnicodeString): Boolean;
var
  lConfig: TDSciVisualConfig;
  lConfigObject: TObject;
  lFileSize: Int64;
begin
  Result := FileExists(AFileName);
  if not Result then
    Exit;

  lConfig := nil;
  if Assigned(FSettings) and FSettings.GetCurrentConfig(lConfigObject) and
    (lConfigObject is TDSciVisualConfig) then
    lConfig := TDSciVisualConfig(lConfigObject);

  if (lConfig <> nil) and (lConfig.FileSizeLimit > 0) then
  begin
    lFileSize := TFile.GetSize(AFileName);
    Result := lFileSize <= lConfig.FileSizeLimit;
    if not Result then
      DSciLog(Format(
        '[DSCI-STATUS] Skipping encoding reload for "%s" because the file size (%d bytes) exceeds the configured limit (%d bytes).',
        [AFileName, lFileSize, lConfig.FileSizeLimit]), cDSciLogInfo);
  end;
end;

function TDScintilla.TryDecodeFileText(const AFileName: UnicodeString;
  ARequestedEncoding: TDSciFileEncoding; out AText: UnicodeString;
  out ADetectedEncoding: TDSciFileEncoding; out ADetectedCodePage: Cardinal;
  out ADetectedEncodingName: UnicodeString): Boolean;
var
  lBytes: TBytes;
  lEncoding: TEncoding;
  lPreambleSize: Integer;
begin
  AText := '';
  ADetectedEncoding := dsfeAutoDetect;
  ADetectedCodePage := 0;
  ADetectedEncodingName := '';

  lBytes := TFile.ReadAllBytes(AFileName);
  if not ResolveFileEncoding(lBytes, ARequestedEncoding, lEncoding,
    lPreambleSize, ADetectedEncoding, ADetectedCodePage,
    ADetectedEncodingName) then
    Exit(False);

  try
    if Length(lBytes) = 0 then
      AText := ''
    else
      AText := lEncoding.GetString(lBytes, lPreambleSize,
        Length(lBytes) - lPreambleSize);
  finally
    if not TEncoding.IsStandardEncoding(lEncoding) then
      lEncoding.Free;
  end;
  Result := True;
end;

procedure TDScintilla.BuildStatusBarMenus;

  procedure AssignOwnedComponentName(AComponent: TComponent;
    const ABaseName: string);
  var
    lCandidate: string;
    lIndex: Integer;
    lOwner: TComponent;
  begin
    lOwner := GetStatusBarComponentOwner;
    if (AComponent = nil) or (lOwner = nil) or (ABaseName = '') or
      (AComponent.Name <> '') then
      Exit;

    if lOwner.FindComponent(ABaseName) = nil then
    begin
      AComponent.Name := ABaseName;
      Exit;
    end;

    lIndex := 1;
    repeat
      lCandidate := Format('%s%d', [ABaseName, lIndex]);
      Inc(lIndex);
    until lOwner.FindComponent(lCandidate) = nil;
    AComponent.Name := lCandidate;
  end;

var
  lOwner: TComponent;
begin
  lOwner := GetStatusBarComponentOwner;

  if FStatusBarEncodingPopup = nil then
  begin
    FStatusBarEncodingPopup := TPopupMenu.Create(lOwner);
    FStatusBarEncodingPopup.AutoPopup := False;
    AssignOwnedComponentName(FStatusBarEncodingPopup, 'StatusEncodingPopupMenu');
  end;

  if FStatusBarLexerPopup = nil then
  begin
    FStatusBarLexerPopup := TPopupMenu.Create(lOwner);
    FStatusBarLexerPopup.AutoPopup := False;
    AssignOwnedComponentName(FStatusBarLexerPopup, 'StatusLexerPopupMenu');
  end;

  if FStatusBarThemePopup = nil then
  begin
    FStatusBarThemePopup := TPopupMenu.Create(lOwner);
    FStatusBarThemePopup.AutoPopup := False;
    AssignOwnedComponentName(FStatusBarThemePopup, 'StatusThemePopupMenu');
  end;
end;

procedure TDScintilla.CreateStatusBarIfNeeded;
var
  lHost: TWinControl;
  lIndex: Integer;
begin
  if csDestroying in ComponentState then
    Exit;

  lHost := GetStatusBarHost;
  if lHost = nil then
    Exit;

  if FStatusBar = nil then
  begin
    FStatusBar := TStatusBar.Create(Self);
    // Keep the Scintilla HWND as the editor surface and host the status UI
    // as a sibling control under the same parent.
    FStatusBar.Parent := lHost;
    FStatusBar.Align := alBottom;
    FStatusBar.Height := MulDiv(19, Screen.PixelsPerInch, 96);
    FStatusBar.OnMouseUp := StatusBarMouseUp;
    FStatusBar.OnContextPopup := StatusBarContextPopup;
    for lIndex := 0 to cStatusPanelCount - 1 do
      FStatusBar.Panels.Add;
    // Initial widths are placeholder values; RefreshStatusBar distributes
    // the available space evenly among visible panels on first call.
    FStatusBar.Panels[cStatusPanelLexer].Width := 80;
    FStatusBar.Panels[cStatusPanelPos].Width := 80;
    FStatusBar.Panels[cStatusPanelTheme].Width := 80;
    FStatusBar.Panels[cStatusPanelFile].Width := 80;
    FStatusBar.Panels[cStatusPanelLoad].Width := 80;
    FStatusBar.Panels[cStatusPanelEncoding].Width := 80;
    DSciLog('[VISUAL] Created managed TDScintilla status bar.', cDSciLogDebug);
  end
  else if FStatusBar.Parent <> lHost then
    FStatusBar.Parent := lHost;

  BuildStatusBarMenus;
  RefreshStatusBarVisibility;
end;

procedure TDScintilla.DestroyStatusBar;
begin
  FreeAndNil(FStatusBarEncodingPopup);
  FreeAndNil(FStatusBarLexerPopup);
  FreeAndNil(FStatusBarThemePopup);

  if Assigned(FStatusBar) then
  begin
    FStatusBar.Parent := nil;
    FreeAndNil(FStatusBar);
  end;

end;

function TDScintilla.GetStatusBarPanelAt(X: Integer): Integer;
var
  lIndex: Integer;
  lLeft: Integer;
  lRight: Integer;
begin
  Result := -1;
  if FStatusBar = nil then
    Exit;

  lLeft := 0;
  for lIndex := 0 to FStatusBar.Panels.Count - 1 do
  begin
    if lIndex = FStatusBar.Panels.Count - 1 then
      lRight := FStatusBar.ClientWidth
    else
      lRight := lLeft + FStatusBar.Panels[lIndex].Width;
    if (X >= lLeft) and (X < lRight) then
      Exit(lIndex);
    lLeft := lRight;
  end;
end;

procedure TDScintilla.RebuildStatusBarEncodingMenu;
const
  cMenuEncodings: array[0..5] of TDSciFileEncoding = (
    dsfeAutoDetect,
    dsfeAnsi,
    dsfeUtf8,
    dsfeUtf8Bom,
    dsfeUtf16BEBom,
    dsfeUtf16LEBom
  );
var
  lEncoding: TDSciFileEncoding;
  lItem: TMenuItem;
begin
  BuildStatusBarMenus;
  if FStatusBarEncodingPopup = nil then
    Exit;

  FStatusBarEncodingPopup.Items.Clear;
  for lEncoding in cMenuEncodings do
  begin
    lItem := TMenuItem.Create(FStatusBarEncodingPopup);
    lItem.Caption := DSciFileEncodingDisplayName(lEncoding);
    lItem.Tag := Ord(lEncoding);
    lItem.RadioItem := True;
    lItem.AutoCheck := False;
    lItem.Checked := lEncoding = FPreferredFileEncoding;
    lItem.OnClick := StatusBarEncodingMenuItemClick;
    FStatusBarEncodingPopup.Items.Add(lItem);
  end;
end;

procedure TDScintilla.RebuildStatusBarLexerMenu;
var
  lBucketCaption: string;
  lBucketItem: TMenuItem;
  lConfig: TDSciVisualConfig;
  lConfigObject: TObject;
  lGroup: TDSciVisualStyleGroup;
  lItem: TMenuItem;
  lLanguages: TStringList;
  lName: string;
  lTopLevelIndex: Integer;
  lUpperName: string;

  function EnsureBucketItem(const ABucketCaption: string): TMenuItem;
  var
    lIndex: Integer;
    lMenuItem: TMenuItem;
  begin
    for lIndex := 0 to FStatusBarLexerPopup.Items.Count - 1 do
    begin
      lMenuItem := FStatusBarLexerPopup.Items[lIndex];
      if SameText(lMenuItem.Caption, ABucketCaption) and (lMenuItem.Count > 0) then
        Exit(lMenuItem);
    end;

    Result := TMenuItem.Create(FStatusBarLexerPopup);
    Result.Caption := ABucketCaption;
    FStatusBarLexerPopup.Items.Add(Result);
  end;

begin
  BuildStatusBarMenus;
  if FStatusBarLexerPopup = nil then
    Exit;

  FStatusBarLexerPopup.Items.Clear;

  lItem := TMenuItem.Create(FStatusBarLexerPopup);
  lItem.Caption := 'Automatic (by file name)';
  lItem.Hint := cStatusLexerMenuAutoHint;
  lItem.RadioItem := True;
  lItem.AutoCheck := False;
  lItem.Checked := FUseAutomaticLexerSelection;
  lItem.OnClick := StatusBarLexerMenuItemClick;
  FStatusBarLexerPopup.Items.Add(lItem);

  lItem := TMenuItem.Create(FStatusBarLexerPopup);
  lItem.Caption := 'Plain text';
  lItem.Hint := cStatusLexerMenuPlainHint;
  lItem.RadioItem := True;
  lItem.AutoCheck := False;
  lItem.Checked := (not FUseAutomaticLexerSelection) and
    (Trim(FRequestedLexerLanguage) = '');
  lItem.OnClick := StatusBarLexerMenuItemClick;
  FStatusBarLexerPopup.Items.Add(lItem);

  lItem := TMenuItem.Create(FStatusBarLexerPopup);
  lItem.Caption := '-';
  FStatusBarLexerPopup.Items.Add(lItem);

  lConfig := nil;
  if Assigned(FSettings) and FSettings.GetCurrentConfig(lConfigObject) and
    (lConfigObject is TDSciVisualConfig) then
    lConfig := TDSciVisualConfig(lConfigObject);
  if lConfig = nil then
    Exit;

  lLanguages := TStringList.Create;
  try
    lLanguages.Sorted := True;
    lLanguages.Duplicates := dupIgnore;
    for lGroup in lConfig.StyleOverrides.Groups do
      if not SameText(lGroup.Name, 'default') then
        lLanguages.Add(lGroup.Name);

    for lName in lLanguages do
    begin
      lUpperName := SysUtils.UpperCase(Trim(lName));
      if (lUpperName <> '') and CharInSet(lUpperName[1], ['A'..'Z']) then
        lBucketCaption := lUpperName[1]
      else
        lBucketCaption := '#';

      lBucketItem := EnsureBucketItem(lBucketCaption);
      lItem := TMenuItem.Create(lBucketItem);
      lItem.Caption := lName;
      lItem.Hint := lName;
      lItem.RadioItem := True;
      lItem.AutoCheck := False;
      lItem.Checked := (not FUseAutomaticLexerSelection) and
        SameText(FRequestedLexerLanguage, lName);
      lItem.OnClick := StatusBarLexerMenuItemClick;
      lBucketItem.Add(lItem);
    end;

    for lTopLevelIndex := 0 to FStatusBarLexerPopup.Items.Count - 1 do
    begin
      lItem := FStatusBarLexerPopup.Items[lTopLevelIndex];
      if lItem.Count > 0 then
        lItem.Caption := Sysutils.UpperCase(lItem.Caption);
    end;
  finally
    lLanguages.Free;
  end;
end;

procedure TDScintilla.RebuildStatusBarThemeMenu;
const
  cThemeMenuEmbeddedHint = '<embedded>';
var
  lConfig: TDSciVisualConfig;
  lConfigDir: string;
  lConfigObject: TObject;
  lCurrentTheme: string;
  lItem: TMenuItem;
  lThemeDir: string;
  lThemeFileName: string;
  lThemeName: string;
  lThemeNames: TStringList;
begin
  BuildStatusBarMenus;
  if FStatusBarThemePopup = nil then
    Exit;

  FStatusBarThemePopup.Items.Clear;

  lConfig := nil;
  if Assigned(FSettings) and FSettings.GetCurrentConfig(lConfigObject) and
    (lConfigObject is TDSciVisualConfig) then
    lConfig := TDSciVisualConfig(lConfigObject);

  lCurrentTheme := '';
  if lConfig <> nil then
    lCurrentTheme := Trim(lConfig.ThemeName);

  lConfigDir := '';
  if Trim(FSettings.ConfigFileName) <> '' then
    lConfigDir := ExtractFileDir(FSettings.ConfigFileName);

  lThemeDir := '';
  if lConfigDir <> '' then
  begin
    lThemeDir := ExpandFileName(TPath.Combine(lConfigDir, 'themes'));
    if not DirectoryExists(lThemeDir) then
      lThemeDir := '';
  end;

  lItem := TMenuItem.Create(FStatusBarThemePopup);
  lItem.Caption := '(Embedded defaults)';
  lItem.Hint := cThemeMenuEmbeddedHint;
  lItem.RadioItem := True;
  lItem.AutoCheck := False;
  lItem.Checked := lCurrentTheme = '';
  lItem.OnClick := StatusBarThemeMenuItemClick;
  FStatusBarThemePopup.Items.Add(lItem);

  if lThemeDir = '' then
    Exit;

  lThemeNames := TStringList.Create;
  try
    lThemeNames.CaseSensitive := False;
    lThemeNames.Sorted := True;
    lThemeNames.Duplicates := dupIgnore;

    for lThemeFileName in TDirectory.GetFiles(lThemeDir, '*.xml') do
    begin
      lThemeName := ChangeFileExt(ExtractFileName(lThemeFileName), '');
      if Trim(lThemeName) <> '' then
        lThemeNames.Add(lThemeName);
    end;

    if lThemeNames.Count = 0 then
      Exit;

    lItem := TMenuItem.Create(FStatusBarThemePopup);
    lItem.Caption := '-';
    FStatusBarThemePopup.Items.Add(lItem);

    for lThemeName in lThemeNames do
    begin
      lItem := TMenuItem.Create(FStatusBarThemePopup);
      lItem.Caption := lThemeName;
      lItem.Hint := lThemeName;
      lItem.RadioItem := True;
      lItem.AutoCheck := False;
      lItem.Checked := SameText(lCurrentTheme, lThemeName);
      lItem.OnClick := StatusBarThemeMenuItemClick;
      FStatusBarThemePopup.Items.Add(lItem);
    end;
  finally
    lThemeNames.Free;
  end;
end;

procedure TDScintilla.RefreshStatusBarVisibility;
var
  lHost: TWinControl;
begin
  if FStatusBar = nil then
    Exit;

  lHost := GetStatusBarHost;
  if (lHost <> nil) and (FStatusBar.Parent <> lHost) then
    FStatusBar.Parent := lHost;

  FStatusBar.Visible := FStatusBarVisible and Visible and
    (FStatusBar.Parent <> nil);
end;

function TDScintilla.BuildStatusBarPositionText: UnicodeString;
var
  lCaretPos: NativeInt;
  lCol: NativeInt;
  lLine: NativeInt;
  lSelChars: NativeInt;
  lSelEnd: NativeInt;
  lSelLines: NativeInt;
  lSelStart: NativeInt;
begin
  Result := 'Ln 1, Col 1';
  if not HandleAllocated or (csDestroying in ComponentState) then
    Exit;

  lCaretPos := Max(0, CurrentPos);
  lLine := LineFromPosition(lCaretPos) + 1;
  lCol := GetColumn(lCaretPos) + 1;
  Result := Format('Ln %d, Col %d', [lLine, lCol]);

  if SelectionEmpty then
    Exit;

  lSelStart := SelectionStart;
  lSelEnd := SelectionEnd;
  lSelChars := CountCharacters(lSelStart, lSelEnd);
  Dec(lSelEnd);
  if lSelEnd < lSelStart then
    lSelEnd := lSelStart;
  lSelLines := LineFromPosition(lSelEnd) - LineFromPosition(lSelStart) + 1;
  Result := Result + Format(' Sel %d|%d', [lSelChars, lSelLines]);
end;

procedure TDScintilla.RefreshStatusBar;
var
  lLoadStatus: TDSciFileLoadStatus;
  lFileText, lThemeName, lLexerText, lEncodingName, lStatusText, lLoadText: UnicodeString;
  lCanvas: TCanvas;
  lTextWidths: array[0..cStatusPanelCount - 1] of Integer;
  lTotalTextWidth, lVisibleCount, lAvail, lExtra, lRemainder, lLastVisible, lIndex: Integer;
begin
  CreateStatusBarIfNeeded;
  if FStatusBar = nil then
    Exit;

  if FCurrentFileName = '' then
    lFileText := 'File: <none>'
  else
    lFileText := 'File: ' + FCurrentFileName;

  if FPreferredFileEncoding <> dsfeAutoDetect then
    lEncodingName := DSciFileEncodingDisplayName(FPreferredFileEncoding)
  else
  begin
    lEncodingName := Trim(FFileLoadStatus.EncodingName);
    if lEncodingName = '' then
      lEncodingName := DSciFileEncodingDisplayName(FPreferredFileEncoding);
  end;

  lEncodingName := 'Encoding: ' + lEncodingName;

  lThemeName := GetStatusThemeName;
  if lThemeName = '' then
    lThemeName := 'base styles';
  lThemeName := 'Theme: ' + lThemeName;

  lLoadStatus := FFileLoadStatus;
  case lLoadStatus.Stage of
    sflsIdle:
      lLoadText := 'Load: idle';
    sflsPreparing:
      lLoadText := 'Load: preparing';
    sflsReading:
      lLoadText := Format('Load: reading %d/%d KB',
        [lLoadStatus.BytesRead div 1024, Max(1, lLoadStatus.TotalBytes div 1024)]);
    sflsDecoding:
      lLoadText := 'Load: decoding';
    sflsLoading:
      lLoadText := Format('Load: building %d/%d KB',
        [lLoadStatus.BytesRead div 1024, Max(1, lLoadStatus.TotalBytes div 1024)]);
    sflsAttaching:
      lLoadText := 'Load: attaching';
    sflsCompleted:
      lLoadText := 'Load: ready';
    sflsFailed:
      if Trim(lLoadStatus.ErrorMessage) = '' then
        lLoadText := 'Load: failed'
      else
        lLoadText := 'Load: failed - ' + Trim(lLoadStatus.ErrorMessage);
    sflsCancelled:
      lLoadText := 'Load: cancelled';
  end;

  if Settings.CurrentLanguage = '' then
    lLexerText := 'Lexer: plain text'
  else
    lLexerText := 'Lexer: ' + Settings.CurrentLanguage;

  lStatusText := BuildStatusBarPositionText;

  // Measure text widths for each visible panel
  lCanvas := FStatusBar.Canvas;
  FillChar(lTextWidths, SizeOf(lTextWidths), 0);
  lVisibleCount := 0;
  lTotalTextWidth := 0;

  if FStatusPanelLexerVisible then
  begin
    lTextWidths[cStatusPanelLexer] := lCanvas.TextWidth(lLexerText + '_');
    Inc(lVisibleCount);
    Inc(lTotalTextWidth, lTextWidths[cStatusPanelLexer]);
  end;

  if FStatusPanelPosVisible then
  begin
    lTextWidths[cStatusPanelPos] := lCanvas.TextWidth(lStatusText + '___');
    Inc(lVisibleCount);
    Inc(lTotalTextWidth, lTextWidths[cStatusPanelPos]);
  end;

  if FStatusPanelThemeVisible then
  begin
    lTextWidths[cStatusPanelTheme] := lCanvas.TextWidth(lThemeName + '_');
    Inc(lVisibleCount);
    Inc(lTotalTextWidth, lTextWidths[cStatusPanelTheme]);
  end;

  if FStatusPanelFileVisible then
  begin
    lTextWidths[cStatusPanelFile] := lCanvas.TextWidth(lFileText + '_');
    Inc(lVisibleCount);
    Inc(lTotalTextWidth, lTextWidths[cStatusPanelFile]);
  end;

  if FStatusPanelLoadVisible then
  begin
    lTextWidths[cStatusPanelLoad] := lCanvas.TextWidth(lLoadText + '_');
    Inc(lVisibleCount);
    Inc(lTotalTextWidth, lTextWidths[cStatusPanelLoad]);
  end;

  if FStatusPanelEncodingVisible then
  begin
    lTextWidths[cStatusPanelEncoding] := lCanvas.TextWidth(lEncodingName + '_');
    Inc(lVisibleCount);
    Inc(lTotalTextWidth, lTextWidths[cStatusPanelEncoding]);
  end;

  // Distribute remaining space evenly among visible panels 
  // Find the rightmost visible panel (it absorbs integer division remainder).
  lLastVisible := -1;
  for lIndex := cStatusPanelCount - 1 downto 0 do
    if lTextWidths[lIndex] > 0 then
    begin
      lLastVisible := lIndex;
      Break;
    end;

  if lVisibleCount > 0 then
  begin
    lAvail := Max(0, FStatusBar.ClientWidth - lTotalTextWidth);
    lExtra := lAvail div lVisibleCount;
    lRemainder := lAvail - lExtra * lVisibleCount;
  end
  else
  begin
    lExtra := 0;
    lRemainder := 0;
  end;

  // Apply widths and texts
  if FStatusPanelLexerVisible then
  begin
    FStatusBar.Panels[cStatusPanelLexer].Width :=
      lTextWidths[cStatusPanelLexer] + lExtra +
      IfThen(cStatusPanelLexer = lLastVisible, lRemainder);
    FStatusBar.Panels[cStatusPanelLexer].Text := lLexerText;
  end
  else
  begin
    FStatusBar.Panels[cStatusPanelLexer].Width := 0;
    FStatusBar.Panels[cStatusPanelLexer].Text := '';
  end;

  if FStatusPanelPosVisible then
  begin
    FStatusBar.Panels[cStatusPanelPos].Width :=
      lTextWidths[cStatusPanelPos] + lExtra +
      IfThen(cStatusPanelPos = lLastVisible, lRemainder);
    FStatusBar.Panels[cStatusPanelPos].Text := lStatusText;
  end
  else
  begin
    FStatusBar.Panels[cStatusPanelPos].Width := 0;
    FStatusBar.Panels[cStatusPanelPos].Text := '';
  end;

  if FStatusPanelThemeVisible then
  begin
    FStatusBar.Panels[cStatusPanelTheme].Width :=
      lTextWidths[cStatusPanelTheme] + lExtra +
      IfThen(cStatusPanelTheme = lLastVisible, lRemainder);
    FStatusBar.Panels[cStatusPanelTheme].Text := lThemeName;
  end
  else
  begin
    FStatusBar.Panels[cStatusPanelTheme].Width := 0;
    FStatusBar.Panels[cStatusPanelTheme].Text := '';
  end;

  if FStatusPanelFileVisible then
  begin
    FStatusBar.Panels[cStatusPanelFile].Width :=
      lTextWidths[cStatusPanelFile] + lExtra +
      IfThen(cStatusPanelFile = lLastVisible, lRemainder);
    FStatusBar.Panels[cStatusPanelFile].Text := lFileText;
  end
  else
  begin
    FStatusBar.Panels[cStatusPanelFile].Width := 0;
    FStatusBar.Panels[cStatusPanelFile].Text := '';
  end;

  if FStatusPanelLoadVisible then
  begin
    FStatusBar.Panels[cStatusPanelLoad].Width :=
      lTextWidths[cStatusPanelLoad] + lExtra +
      IfThen(cStatusPanelLoad = lLastVisible, lRemainder);
    FStatusBar.Panels[cStatusPanelLoad].Text := lLoadText;
  end
  else
  begin
    FStatusBar.Panels[cStatusPanelLoad].Width := 0;
    FStatusBar.Panels[cStatusPanelLoad].Text := '';
  end;

  if FStatusPanelEncodingVisible then
  begin
    FStatusBar.Panels[cStatusPanelEncoding].Width :=
      lTextWidths[cStatusPanelEncoding] + lExtra +
      IfThen(cStatusPanelEncoding = lLastVisible, lRemainder);
    FStatusBar.Panels[cStatusPanelEncoding].Text := lEncodingName;
  end
  else
  begin
    FStatusBar.Panels[cStatusPanelEncoding].Width := 0;
    FStatusBar.Panels[cStatusPanelEncoding].Text := '';
  end;
end;

procedure TDScintilla.SetPreferredFileEncoding(const Value: TDSciFileEncoding);
begin
  if FPreferredFileEncoding = Value then
  begin
    RefreshStatusBar;
    Exit;
  end;

  FPreferredFileEncoding := Value;
  DSciLog(Format('[DSCI-STATUS] Selected file encoding %s.',
    [DSciFileEncodingDisplayName(FPreferredFileEncoding)]), cDSciLogInfo);
  RebuildStatusBarEncodingMenu;
  RefreshStatusBar;
  if FCurrentFileName <> '' then
  begin
    DSciLog(Format(
      '[DSCI-STATUS] Queueing a synchronous reload for "%s" after encoding change.',
      [FCurrentFileName]), cDSciLogInfo);
    if HandleAllocated then
      PostMessage(Handle, cDSciReloadForEncodingChangeMessage, 0, 0)
    else
      ReloadCurrentFileForEncodingChange;
  end;
end;

procedure TDScintilla.SetStatusBarVisible(const Value: Boolean);
begin
  if FStatusBarVisible = Value then
  begin
    RefreshStatusBarVisibility;
    Exit;
  end;

  FStatusBarVisible := Value;
  CreateStatusBarIfNeeded;
  RefreshStatusBarVisibility;
  RefreshStatusBar;
end;

procedure TDScintilla.ApplyPreferredLanguageSelection(
  const ALogReason: UnicodeString);
var
  lReason: UnicodeString;
begin
  lReason := Trim(ALogReason);
  if lReason = '' then
    lReason := 'status update';

  if FUseAutomaticLexerSelection then
  begin
    if FCurrentFileName <> '' then
    begin
      DSciLog(Format(
        '[DSCI-STATUS] Applying automatic lexer selection for "%s" after %s.',
        [FCurrentFileName, lReason]), cDSciLogInfo);
      FSettings.ApplyLanguageForFileName(FCurrentFileName);
    end
    else
    begin
      DSciLog(Format(
        '[DSCI-STATUS] Resetting to the default/plain lexer after %s because no file is loaded.',
        [lReason]), cDSciLogInfo);
      FSettings.ApplyLanguage('');
    end;
  end
  else
  begin
    if Trim(FRequestedLexerLanguage) = '' then
      DSciLog(Format(
        '[DSCI-STATUS] Applying the plain-text lexer after %s.', [lReason]), cDSciLogInfo)
    else
      DSciLog(Format(
        '[DSCI-STATUS] Applying manual lexer "%s" after %s.',
        [FRequestedLexerLanguage, lReason]), cDSciLogInfo);
    FSettings.ApplyLanguage(FRequestedLexerLanguage);
  end;

  RebuildStatusBarLexerMenu;
  RefreshStatusBar;
end;

procedure TDScintilla.ReloadCurrentFileForEncodingChange;
var
  lDetectedCodePage: Cardinal;
  lDetectedEncoding: TDSciFileEncoding;
  lDetectedEncodingName: UnicodeString;
  lExpandedFileName: UnicodeString;
  lFileSize: Int64;
  lText: UnicodeString;
begin
  if Trim(FCurrentFileName) = '' then
  begin
    RefreshStatusBar;
    Exit;
  end;

  lExpandedFileName := ExpandFileName(FCurrentFileName);
  if not CanReloadFileForEncodingChange(lExpandedFileName) then
  begin
    RefreshStatusBar;
    Exit;
  end;

  lFileSize := TFile.GetSize(lExpandedFileName);
  try
    SetFileLoadStatus(MakeFileLoadStatus(lExpandedFileName, sflsPreparing, 0,
      lFileSize, '', False, FPreferredFileEncoding,
      DSciFileEncodingCodePage(FPreferredFileEncoding),
      DSciFileEncodingDisplayName(FPreferredFileEncoding)));

    if not TryDecodeFileText(lExpandedFileName, FPreferredFileEncoding, lText,
      lDetectedEncoding, lDetectedCodePage, lDetectedEncodingName) then
      raise EInvalidOpException.Create(
        'Unable to decode the file using the selected encoding.');

    SetFileLoadStatus(MakeFileLoadStatus(lExpandedFileName, sflsLoading,
      lFileSize, lFileSize, '', False, lDetectedEncoding,
      lDetectedCodePage, lDetectedEncodingName));

    SetText(lText);
    EmptyUndoBuffer;
    SetSavePoint;
    FCurrentFileName := lExpandedFileName;
    ApplyPreferredLanguageSelection('encoding reload');
    SetFileLoadStatus(MakeFileLoadStatus(lExpandedFileName, sflsCompleted,
      lFileSize, lFileSize, '', False, lDetectedEncoding,
      lDetectedCodePage, lDetectedEncodingName));
  except
    on E: Exception do
    begin
      DSciLog(Format(
        '[DSCI-STATUS] Encoding reload failed for "%s": %s - %s',
        [lExpandedFileName, E.ClassName, E.Message]), cDSciLogError);
      SetFileLoadStatus(MakeFileLoadStatus(lExpandedFileName, sflsFailed, 0,
        lFileSize, E.Message, False, FPreferredFileEncoding,
        DSciFileEncodingCodePage(FPreferredFileEncoding),
        DSciFileEncodingDisplayName(FPreferredFileEncoding)));
    end;
  end;
end;

procedure TDScintilla.StatusBarEncodingMenuItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    PreferredFileEncoding := TDSciFileEncoding(TMenuItem(Sender).Tag);
end;

procedure TDScintilla.StatusBarLexerMenuItemClick(Sender: TObject);
var
  lItem: TMenuItem;
begin
  if not (Sender is TMenuItem) then
    Exit;

  lItem := TMenuItem(Sender);
  if SameText(lItem.Hint, cStatusLexerMenuAutoHint) then
  begin
    FUseAutomaticLexerSelection := True;
    FRequestedLexerLanguage := '';
  end
  else if SameText(lItem.Hint, cStatusLexerMenuPlainHint) then
  begin
    FUseAutomaticLexerSelection := False;
    FRequestedLexerLanguage := '';
  end
  else
  begin
    FUseAutomaticLexerSelection := False;
    FRequestedLexerLanguage := lItem.Hint;
  end;

  RebuildStatusBarLexerMenu;
  ApplyPreferredLanguageSelection('status bar selection');
end;

procedure TDScintilla.StatusBarThemeMenuItemClick(Sender: TObject);
const
  cThemeMenuEmbeddedHint = '<embedded>';
var
  lConfig: TDSciVisualConfig;
  lConfigObject: TObject;
  lDefaultConfig: TDSciVisualConfig;
  lDefaultStream: TResourceStream;
  lItem: TMenuItem;
  lThemeDir: string;
  lThemeFile: string;
  lThemeModel: TDSciVisualStyleModel;
  lThemeName: string;
begin
  if not (Sender is TMenuItem) then
    Exit;

  lItem := TMenuItem(Sender);
  lConfig := nil;
  if Assigned(FSettings) and FSettings.GetCurrentConfig(lConfigObject) and
    (lConfigObject is TDSciVisualConfig) then
    lConfig := TDSciVisualConfig(lConfigObject);
  if lConfig = nil then
    Exit;

  if SameText(lItem.Hint, cThemeMenuEmbeddedHint) then
  begin
    lDefaultStream := DScintillaDefaultConfig.OpenDefaultConfigStream;
    try
      lDefaultConfig := TDSciVisualConfig.Create;
      try
        lDefaultConfig.LoadFromStream(lDefaultStream);
        lConfig.ReplaceStyleModel(lDefaultConfig.StyleOverrides, True);
        lConfig.ThemeName := '';
      finally
        lDefaultConfig.Free;
      end;
    finally
      lDefaultStream.Free;
    end;
  end
  else
  begin
    lThemeName := Trim(lItem.Hint);
    if lThemeName = '' then
      Exit;

    lThemeDir := '';
    if Trim(FSettings.ConfigFileName) <> '' then
      lThemeDir := ExpandFileName(
        TPath.Combine(ExtractFileDir(FSettings.ConfigFileName), 'themes'));

    lThemeFile := TPath.Combine(lThemeDir, lThemeName + '.xml');
    if not FileExists(lThemeFile) then
      lThemeFile := TPath.Combine(lThemeDir, lThemeName);
    if not FileExists(lThemeFile) then
    begin
      DSciLog(Format('[THEME] Theme file not found: %s', [lThemeName]), cDSciLogError);
      Exit;
    end;

    lThemeModel := LoadThemeStyleModelFromFile(lThemeFile);
    try
      lConfig.ReplaceStyleModel(lThemeModel, True);
      lConfig.ThemeName := lThemeName;
    finally
      lThemeModel.Free;
    end;
  end;

  if Trim(FSettings.ConfigFileName) <> '' then
  begin
    ForceDirectories(ExtractFileDir(FSettings.ConfigFileName));
    lConfig.SaveToFile(FSettings.ConfigFileName);
  end;

  FSettings.Reapply;
  if FCurrentFileName <> '' then
    ReapplyPreferredLanguageSelection
  else
    RefreshStatusBar;
end;

procedure TDScintilla.StatusBarContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  // Suppress WM_CONTEXTMENU propagation from StatusBar to the parent window.
  // Without this, TWinControl.DefaultHandler forwards the message to the parent
  // causing a second popup menu when the control uses ParentWindow.
  Handled := True;
end;

procedure TDScintilla.StatusBarMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lScreenPoint: TPoint;
begin
  if (Button <> mbRight) or (FStatusBar = nil) then
    Exit;

  lScreenPoint := FStatusBar.ClientToScreen(Point(X, Y));
  case GetStatusBarPanelAt(X) of
    cStatusPanelLexer:
      begin
        RebuildStatusBarLexerMenu;
        FStatusBarLexerPopup.Popup(lScreenPoint.X, lScreenPoint.Y);
      end;
    cStatusPanelEncoding:
      begin
        RebuildStatusBarEncodingMenu;
        FStatusBarEncodingPopup.Popup(lScreenPoint.X, lScreenPoint.Y);
      end;
    cStatusPanelTheme:
      begin
        RebuildStatusBarThemeMenu;
        if (FStatusBarThemePopup <> nil) and (FStatusBarThemePopup.Items.Count > 1) then
          FStatusBarThemePopup.Popup(lScreenPoint.X, lScreenPoint.Y);
      end;
  end;
end;

procedure TDScintilla.DoFileLoadStateChange(const AStatus: TDSciFileLoadStatus);
begin
  if Assigned(FOnFileLoadStateChange) then
    FOnFileLoadStateChange(Self, AStatus);
end;

procedure TDScintilla.DoDropFiles(AFiles: TStrings);
begin
  if Assigned(FOnDropFiles) then
    FOnDropFiles(Self, AFiles);
end;

procedure TDScintilla.DoLoaderDocumentAttached;
begin
end;

procedure TDScintilla.SetFileLoadStatus(const AStatus: TDSciFileLoadStatus);
begin
  FFileLoadStatus := AStatus;
  FFileLoadEncoding := AStatus.Encoding;
  if AStatus.Stage in [sflsPreparing, sflsCompleted, sflsFailed, sflsCancelled] then
    DSciLog(Format('[DSCI-LOAD] %s "%s" (%s)',
      [FileLoadStageName(AStatus.Stage), AStatus.FileName,
       BoolToStr(AStatus.IsAsync, True)]), cDSciLogInfo);
  RefreshStatusBar;
  DoFileLoadStateChange(AStatus);
end;

procedure TDScintilla.ReportSynchronousFileLoadStage(AStage: TDSciFileLoadStage;
  ABytesRead, ATotalBytes: Int64; const AErrorMessage: UnicodeString;
  AEncoding: TDSciFileEncoding; AEncodingCodePage: Cardinal;
  const AEncodingName: UnicodeString);
begin
  SetFileLoadStatus(MakeFileLoadStatus(FFileLoadStatus.FileName, AStage,
    ABytesRead, ATotalBytes, AErrorMessage, False, AEncoding,
    AEncodingCodePage, AEncodingName));
end;

procedure TDScintilla.FinalizeFileLoadThread;
var
  lThread: TThread;
begin
  lThread := FFileLoadThread;
  FFileLoadThread := nil;
  if lThread <> nil then
  begin
    lThread.WaitFor;
    lThread.Free;
  end;
end;

procedure TDScintilla.FlushPendingFileLoadMessages;
var
  lAttachPayload: TDSciFileLoadAttachPayload;
  lMessage: TMsg;
  lStatusPayload: TDSciFileLoadStatusPayload;
begin
  if not HandleAllocated then
    Exit;

  while PeekMessage(lMessage, Handle, cDSciFileLoadStatusMessage,
    cDSciFileLoadAttachMessage, PM_REMOVE) do
  begin
    case lMessage.message of
      cDSciFileLoadStatusMessage:
        begin
          lStatusPayload := TDSciFileLoadStatusPayload(Pointer(lMessage.lParam));
          lStatusPayload.Free;
        end;
      cDSciFileLoadAttachMessage:
        begin
          lAttachPayload := TDSciFileLoadAttachPayload(Pointer(lMessage.lParam));
          ReleaseLoaderPointer(lAttachPayload.Loader);
          lAttachPayload.Free;
        end;
    end;
  end;
end;

procedure TDScintilla.CancelLoadFromFile(AWait: Boolean);
var
  lThread: TThread;
begin
  lThread := FFileLoadThread;
  if lThread = nil then
    Exit;

  lThread.Terminate;
  if AWait then
  begin
    FinalizeFileLoadThread;
    FlushPendingFileLoadMessages;
    if not IsTerminalFileLoadStage(FFileLoadStatus.Stage) then
      SetFileLoadStatus(MakeFileLoadStatus(FFileLoadStatus.FileName,
        sflsCancelled, FFileLoadStatus.BytesRead, FFileLoadStatus.TotalBytes,
        '', True, FFileLoadStatus.Encoding, FFileLoadStatus.EncodingCodePage,
        FFileLoadStatus.EncodingName));
  end;
end;

procedure TDScintilla.AttachLoadedDocument(ALoader: Pointer;
  ADocument: TDSciDocument; const AFileName: UnicodeString; AIsAsync: Boolean;
  AEncoding: TDSciFileEncoding; AEncodingCodePage: Cardinal;
  const AEncodingName: UnicodeString);
begin
  try
    SetDocPointer(ADocument);
    // SCI_CREATELOADER disables undo collection for load performance.
    // Re-enable it now so user edits after file open are tracked.
    SetUndoCollection(True);
    DSciLog('AttachLoadedDocument: undo collection re-enabled after SCI_CREATELOADER attach', cDSciLogDebug);
    EmptyUndoBuffer;
    SetSavePoint;
    DoLoaderDocumentAttached;
    FCurrentFileName := ExpandFileName(AFileName);
    ApplyPreferredLanguageSelection('file load');
    SetFileLoadStatus(MakeFileLoadStatus(AFileName, sflsCompleted,
      FFileLoadStatus.TotalBytes, FFileLoadStatus.TotalBytes, '', AIsAsync,
      AEncoding, AEncodingCodePage, AEncodingName));
  finally
    ReleaseLoaderPointer(ALoader);
  end;
end;

function TDScintilla.LoadFromFile(const AFileName: UnicodeString): Boolean;
begin
  DSciLog(Format(
    '[DSCI] LoadFromFile using preferred encoding %s for "%s".',
    [DSciFileEncodingDisplayName(PreferredFileEncoding), AFileName]), cDSciLogDebug);
  Result := LoadFromFile(AFileName, PreferredFileEncoding);
end;

function TDScintilla.LoadFromFile(const AFileName: UnicodeString;
  AEncoding: TDSciFileEncoding): Boolean;
var
  lDetectedCodePage: Cardinal;
  lDetectedEncoding: TDSciFileEncoding;
  lDetectedEncodingName: UnicodeString;
  lDocument: TDSciDocument;
  lExpandedFileName: UnicodeString;
  lFileSize: Int64;
  lLoader: Pointer;
begin
  CancelLoadFromFile(True);
  FlushPendingFileLoadMessages;
  Inc(FFileLoadSequence);

  lExpandedFileName := ExpandFileName(AFileName);
  SetFileLoadStatus(MakeFileLoadStatus(lExpandedFileName, sflsIdle, 0, 0, '',
    False, AEncoding, DSciFileEncodingCodePage(AEncoding),
    DSciFileEncodingDisplayName(AEncoding)));
  if not FileExists(lExpandedFileName) then
  begin
    SetFileLoadStatus(MakeFileLoadStatus(lExpandedFileName, sflsFailed, 0, 0,
      'File not found.', False, AEncoding, DSciFileEncodingCodePage(AEncoding),
      DSciFileEncodingDisplayName(AEncoding)));
    Exit(False);
  end;

  lFileSize := TFile.GetSize(lExpandedFileName);
  if not IsFileSizeWithinLimit(lFileSize) then
  begin
    SetFileLoadStatus(MakeFileLoadStatus(lExpandedFileName, sflsFailed, 0,
      lFileSize, Format('File size (%d bytes) exceeds the configured limit.', [lFileSize]),
      False, AEncoding, DSciFileEncodingCodePage(AEncoding),
      DSciFileEncodingDisplayName(AEncoding)));
    Exit(False);
  end;
  lLoader := CreateFileLoader(lFileSize);
  if lLoader = nil then
  begin
    SetFileLoadStatus(MakeFileLoadStatus(lExpandedFileName, sflsFailed, 0,
      lFileSize, 'SCI_CREATELOADER returned nil.', False, AEncoding,
      DSciFileEncodingCodePage(AEncoding), DSciFileEncodingDisplayName(AEncoding)));
    Exit(False);
  end;

  lDocument := nil;
  Result := RunFileLoadToLoader(lExpandedFileName, lLoader, AEncoding, False,
    ReportSynchronousFileLoadStage, NeverCancelFileLoad, lDocument,
    lDetectedEncoding, lDetectedCodePage, lDetectedEncodingName);
  if not Result then
  begin
    ReleaseLoaderPointer(lLoader);
    Exit(False);
  end;

  AttachLoadedDocument(lLoader, lDocument, lExpandedFileName, False,
    lDetectedEncoding, lDetectedCodePage, lDetectedEncodingName);
end;

procedure TDScintilla.ReapplyPreferredLanguageSelection;
begin
  ApplyPreferredLanguageSelection('manual reapply');
end;

function TDScintilla.SaveToFile(const AFileName: UnicodeString): Boolean;
var
  lEncoding: TDSciFileEncoding;
begin
  lEncoding := FFileLoadStatus.Encoding;
  if lEncoding in [dsfeAutoDetect, dsfeOther] then
    lEncoding := dsfeUtf8;
  DSciLog(Format(
    '[DSCI] SaveToFile using detected encoding %s for "%s".',
    [DSciFileEncodingDisplayName(lEncoding), AFileName]), cDSciLogDebug);
  Result := SaveToFile(AFileName, lEncoding);
end;

function TDScintilla.SaveToFile(const AFileName: UnicodeString;
  AEncoding: TDSciFileEncoding): Boolean;
var
  lBom: TBytes;
  lBytes: TBytes;
  lExpandedFileName: UnicodeString;
  lStream: TFileStream;
  lText: UnicodeString;
begin
  Result := False;
  lExpandedFileName := ExpandFileName(AFileName);
  DSciLog(Format(
    '[DSCI] SaveToFile encoding=%s file="%s".',
    [DSciFileEncodingDisplayName(AEncoding), lExpandedFileName]), cDSciLogDebug);

  lText := GetText;

  case AEncoding of
    dsfeUtf8:
    begin
      lBytes := TEncoding.UTF8.GetBytes(lText);
      lBom := nil;
    end;
    dsfeUtf8Bom:
    begin
      lBytes := TEncoding.UTF8.GetBytes(lText);
      lBom := TEncoding.UTF8.GetPreamble;
    end;
    dsfeAnsi:
    begin
      lBytes := TEncoding.ANSI.GetBytes(lText);
      lBom := nil;
    end;
    dsfeUtf16LEBom:
    begin
      lBytes := TEncoding.Unicode.GetBytes(lText);
      lBom := TEncoding.Unicode.GetPreamble;
    end;
    dsfeUtf16BEBom:
    begin
      lBytes := TEncoding.BigEndianUnicode.GetBytes(lText);
      lBom := TEncoding.BigEndianUnicode.GetPreamble;
    end;
  else
    lBytes := TEncoding.UTF8.GetBytes(lText);
    lBom := nil;
  end;

  try
    lStream := TFileStream.Create(lExpandedFileName, fmCreate);
    try
      if Length(lBom) > 0 then
        lStream.WriteBuffer(lBom[0], Length(lBom));
      if Length(lBytes) > 0 then
        lStream.WriteBuffer(lBytes[0], Length(lBytes));
    finally
      lStream.Free;
    end;
  except
    on E: Exception do
    begin
      DSciLog(Format('[DSCI] SaveToFile error: %s.', [E.Message]), cDSciLogError);
      Exit;
    end;
  end;

  SetSavePoint;
  FCurrentFileName := lExpandedFileName;
  DSciLog(Format(
    '[DSCI] SaveToFile completed: %d bytes written to "%s".',
    [Length(lBom) + Length(lBytes), lExpandedFileName]), cDSciLogDebug);
  Result := True;
end;

procedure TDScintilla.RefreshManagedStatusBar;
begin
  RefreshStatusBar;
end;

function TDScintilla.BeginLoadFromFile(const AFileName: UnicodeString): Boolean;
begin
  DSciLog(Format(
    '[DSCI] BeginLoadFromFile using preferred encoding %s for "%s".',
    [DSciFileEncodingDisplayName(PreferredFileEncoding), AFileName]), cDSciLogDebug);
  Result := BeginLoadFromFile(AFileName, PreferredFileEncoding);
end;

function TDScintilla.BeginLoadFromFile(const AFileName: UnicodeString;
  AEncoding: TDSciFileEncoding): Boolean;
var
  lExpandedFileName: UnicodeString;
  lFileSize: Int64;
  lLoader: Pointer;
begin
  CancelLoadFromFile(True);
  FlushPendingFileLoadMessages;

  lExpandedFileName := ExpandFileName(AFileName);
  if not FileExists(lExpandedFileName) then
  begin
    SetFileLoadStatus(MakeFileLoadStatus(lExpandedFileName, sflsFailed, 0, 0,
      'File not found.', True, AEncoding, DSciFileEncodingCodePage(AEncoding),
      DSciFileEncodingDisplayName(AEncoding)));
    Exit(False);
  end;

  lFileSize := TFile.GetSize(lExpandedFileName);
  if not IsFileSizeWithinLimit(lFileSize) then
  begin
    SetFileLoadStatus(MakeFileLoadStatus(lExpandedFileName, sflsFailed, 0,
      lFileSize, Format('File size (%d bytes) exceeds the configured limit.', [lFileSize]),
      True, AEncoding, DSciFileEncodingCodePage(AEncoding),
      DSciFileEncodingDisplayName(AEncoding)));
    Exit(False);
  end;
  lLoader := CreateFileLoader(lFileSize);
  if lLoader = nil then
  begin
    SetFileLoadStatus(MakeFileLoadStatus(lExpandedFileName, sflsFailed, 0,
      lFileSize, 'SCI_CREATELOADER returned nil.', True, AEncoding,
      DSciFileEncodingCodePage(AEncoding), DSciFileEncodingDisplayName(AEncoding)));
    Exit(False);
  end;

  Inc(FFileLoadSequence);
  SetFileLoadStatus(MakeFileLoadStatus(lExpandedFileName, sflsPreparing, 0,
    lFileSize, '', True, AEncoding, DSciFileEncodingCodePage(AEncoding),
    DSciFileEncodingDisplayName(AEncoding)));
  FFileLoadThread := TDSciAsyncFileLoadThread.Create(Handle, lExpandedFileName,
    lLoader, FFileLoadSequence, AEncoding);
  FFileLoadThread.Start;
  Result := True;
end;

procedure TDScintilla.BuildDefaultContextMenu;

  function AddDefaultMenuItem(const ACaption: string; ATag: Integer): TMenuItem;
  begin
    Result := TMenuItem.Create(FDefaultContextMenu);
    Result.Caption := ACaption;
    Result.Tag := ATag;
    Result.OnClick := DefaultContextMenuClick;
    FDefaultContextMenu.Items.Add(Result);
  end;

  procedure AddSeparator;
  var
    lSeparator: TMenuItem;
  begin
    lSeparator := TMenuItem.Create(FDefaultContextMenu);
    lSeparator.Caption := '-';
    FDefaultContextMenu.Items.Add(lSeparator);
  end;

begin
  FDefaultContextMenu := TPopupMenu.Create(Self);
  FDefaultContextMenu.AutoPopup := False;
  FDefaultContextMenu.OnPopup := DefaultContextMenuPopup;

  FDefaultMenuUndo := AddDefaultMenuItem('Undo', cDefaultContextMenuTagUndo);
  AddSeparator;
  FDefaultMenuCut := AddDefaultMenuItem('Cut', cDefaultContextMenuTagCut);
  FDefaultMenuCopy := AddDefaultMenuItem('Copy', cDefaultContextMenuTagCopy);
  FDefaultMenuCopyWithFormatting := AddDefaultMenuItem('Copy with formatting',
    cDefaultContextMenuTagCopyWithFormatting);
  FDefaultMenuPaste := AddDefaultMenuItem('Paste', cDefaultContextMenuTagPaste);
  FDefaultMenuDelete := AddDefaultMenuItem('Delete', cDefaultContextMenuTagDelete);
  AddSeparator;
  FDefaultMenuSelectAll := AddDefaultMenuItem('Select All', cDefaultContextMenuTagSelectAll);

  AddSeparator;

  FDefaultMenuFolding := TMenuItem.Create(FDefaultContextMenu);
  FDefaultMenuFolding.Caption := 'Folding';
  FDefaultContextMenu.Items.Add(FDefaultMenuFolding);

  FDefaultMenuFoldAll := TMenuItem.Create(FDefaultContextMenu);
  FDefaultMenuFoldAll.Caption := 'Fold All';
  FDefaultMenuFoldAll.Tag := cDefaultContextMenuTagFoldAll;
  FDefaultMenuFoldAll.OnClick := DefaultContextMenuClick;
  FDefaultMenuFolding.Add(FDefaultMenuFoldAll);

  FDefaultMenuUnfoldAll := TMenuItem.Create(FDefaultContextMenu);
  FDefaultMenuUnfoldAll.Caption := 'Unfold All';
  FDefaultMenuUnfoldAll.Tag := cDefaultContextMenuTagUnfoldAll;
  FDefaultMenuUnfoldAll.OnClick := DefaultContextMenuClick;
  FDefaultMenuFolding.Add(FDefaultMenuUnfoldAll);

  FDefaultMenuFolding.NewBottomLine;

  FDefaultMenuFoldCurrent := TMenuItem.Create(FDefaultContextMenu);
  FDefaultMenuFoldCurrent.Caption := 'Fold Current';
  FDefaultMenuFoldCurrent.Tag := cDefaultContextMenuTagFoldCurrent;
  FDefaultMenuFoldCurrent.OnClick := DefaultContextMenuClick;
  FDefaultMenuFolding.Add(FDefaultMenuFoldCurrent);

  FDefaultMenuUnfoldCurrent := TMenuItem.Create(FDefaultContextMenu);
  FDefaultMenuUnfoldCurrent.Caption := 'Unfold Current';
  FDefaultMenuUnfoldCurrent.Tag := cDefaultContextMenuTagUnfoldCurrent;
  FDefaultMenuUnfoldCurrent.OnClick := DefaultContextMenuClick;
  FDefaultMenuFolding.Add(FDefaultMenuUnfoldCurrent);

  FDefaultMenuFolding.NewBottomLine;

  FDefaultMenuFoldNested := TMenuItem.Create(FDefaultContextMenu);
  FDefaultMenuFoldNested.Caption := 'Fold Nested';
  FDefaultMenuFoldNested.Tag := cDefaultContextMenuTagFoldNested;
  FDefaultMenuFoldNested.OnClick := DefaultContextMenuClick;
  FDefaultMenuFolding.Add(FDefaultMenuFoldNested);

  FDefaultMenuUnfoldNested := TMenuItem.Create(FDefaultContextMenu);
  FDefaultMenuUnfoldNested.Caption := 'Unfold Nested';
  FDefaultMenuUnfoldNested.Tag := cDefaultContextMenuTagUnfoldNested;
  FDefaultMenuUnfoldNested.OnClick := DefaultContextMenuClick;
  FDefaultMenuFolding.Add(FDefaultMenuUnfoldNested);

  // Gutter context menu
  FGutterContextMenu := TPopupMenu.Create(Self);
  FGutterContextMenu.AutoPopup := False;
  FGutterContextMenu.OnPopup := GutterContextMenuPopup;

  FGutterMenuSettings := TMenuItem.Create(FGutterContextMenu);
  FGutterMenuSettings.Caption := 'Settings...';
  FGutterMenuSettings.OnClick := GutterMenuSettingsClick;
  FGutterContextMenu.Items.Add(FGutterMenuSettings);

  FGutterContextMenu.Items.NewBottomLine;

  FGutterMenuLexer := TMenuItem.Create(FGutterContextMenu);
  FGutterMenuLexer.Caption := 'Lexer';
  FGutterContextMenu.Items.Add(FGutterMenuLexer);

  FGutterMenuEncoding := TMenuItem.Create(FGutterContextMenu);
  FGutterMenuEncoding.Caption := 'Encoding';
  FGutterContextMenu.Items.Add(FGutterMenuEncoding);

  FGutterMenuTheme := TMenuItem.Create(FGutterContextMenu);
  FGutterMenuTheme.Caption := 'Theme';
  FGutterContextMenu.Items.Add(FGutterMenuTheme);
end;

function TDScintilla.ActiveContextMenu: TPopupMenu;
begin
  Result := nil;

  if FUseAssignedPopupMenu and (PopupMenu <> nil) and PopupMenu.AutoPopup then
    Exit(PopupMenu);

  if FDefaultContextMenuEnabled then
    Result := FDefaultContextMenu;
end;

function TDScintilla.ContextMenuScreenPoint(
  const AMessage: TWMContextMenu): TPoint;
begin
  Result := ClientToScreen(ContextMenuClientPoint(AMessage));
end;

function TDScintilla.ContextMenuClientPoint(const AMessage: TWMContextMenu): TPoint;
var
  lCaretPos: NativeInt;
  lLine: NativeInt;
  lLineHeight: Integer;
  lMarginIndex: Integer;
  lTextAreaStart: Integer;
begin
  Result := SmallPointToPoint(AMessage.Pos);
  if (Result.X >= 0) and (Result.Y >= 0) then
  begin
    Windows.ScreenToClient(Handle, Result);
    Exit;
  end;

  lTextAreaStart := MarginLeft;
  for lMarginIndex := 0 to Margins - 1 do
    Inc(lTextAreaStart, Max(0, MarginWidthN[lMarginIndex]));

  lCaretPos := CurrentPos;
  if lCaretPos < 0 then
    lCaretPos := 0;
  lLine := LineFromPosition(lCaretPos);
  lLineHeight := Max(1, TextHeight(lLine));

  Result.X := PointXFromPosition(lCaretPos);
  Result.Y := PointYFromPosition(lCaretPos) + (lLineHeight div 2);
  if Result.X < lTextAreaStart then
    Result.X := lTextAreaStart + Max(4, MarginRight div 2);
  if Result.Y < 0 then
    Result.Y := Max(4, Height div 4);
end;

function TDScintilla.IsPointInMarginArea(const AClientPoint: TPoint): Boolean;
var
  lMarginIndex: Integer;
  lMarginStart: Integer;
  lMarginWidth: Integer;
begin
  lMarginStart := GetMarginLeft;
  lMarginWidth := 0;
  for lMarginIndex := 0 to Margins - 1 do
    Inc(lMarginWidth, Max(0, MarginWidthN[lMarginIndex]));

  Result := (lMarginWidth > 0) and
    (AClientPoint.X >= lMarginStart) and
    (AClientPoint.X < (lMarginStart + lMarginWidth));
end;

function TDScintilla.IsBraceChar(AChar: Integer): Boolean;
begin
  case AChar of
    Ord('('), Ord(')'), Ord('['), Ord(']'),
    Ord('{'), Ord('}'), Ord('<'), Ord('>'):
      Result := True;
  else
    Result := False;
  end;
end;

function TDScintilla.ColorToHtml(AColor: TColor): UnicodeString;
var
  lRgb: COLORREF;
begin
  lRgb := ColorToRGB(AColor);
  Result := Format('#%.2x%.2x%.2x',
    [GetRValue(lRgb), GetGValue(lRgb), GetBValue(lRgb)]);
end;

function TDScintilla.EscapeHtmlText(const AText: UnicodeString): UnicodeString;
var
  lChar: Char;
begin
  Result := '';
  for lChar in AText do
    case lChar of
      '&':
        Result := Result + '&amp;';
      '<':
        Result := Result + '&lt;';
      '>':
        Result := Result + '&gt;';
      '"':
        Result := Result + '&quot;';
    else
      Result := Result + lChar;
    end;
end;

function TDScintilla.StyleToHtmlCss(AStyle: Integer): UnicodeString;
  procedure AppendCss(const AName, AValue: UnicodeString);
  begin
    if Result <> '' then
      Result := Result + ' ';
    Result := Result + AName + ':' + AValue + ';';
  end;

var
  lFontSize: Integer;
  lFontName: UnicodeString;
begin
  Result := '';
  AppendCss('color', ColorToHtml(StyleFore[AStyle]));
  AppendCss('background-color', ColorToHtml(StyleBack[AStyle]));

  lFontName := Trim(StyleFont[AStyle]);
  if lFontName <> '' then
    AppendCss('font-family', QuotedStr(StringReplace(lFontName, '''', '&#39;', [rfReplaceAll])));

  lFontSize := StyleSize[AStyle];
  if lFontSize > 0 then
    AppendCss('font-size', Format('%dpt', [lFontSize]));

  if StyleBold[AStyle] or (StyleWeight[AStyle] >= scfwSEMI_BOLD) then
    AppendCss('font-weight', 'bold')
  else
    AppendCss('font-weight', 'normal');

  if StyleItalic[AStyle] then
    AppendCss('font-style', 'italic')
  else
    AppendCss('font-style', 'normal');

  if StyleUnderline[AStyle] then
    AppendCss('text-decoration', 'underline')
  else
    AppendCss('text-decoration', 'none');
end;

function TDScintilla.BuildHtmlClipboardData(
  const AHtmlFragment: UnicodeString): UTF8String;
const
  cStartFragmentMarker = '<!--StartFragment-->';
  cEndFragmentMarker = '<!--EndFragment-->';
  cHeaderTemplate =
    'Version:1.0'#13#10 +
    'StartHTML:%.10d'#13#10 +
    'EndHTML:%.10d'#13#10 +
    'StartFragment:%.10d'#13#10 +
    'EndFragment:%.10d'#13#10 +
    'StartSelection:%.10d'#13#10 +
    'EndSelection:%.10d'#13#10;
var
  lEndFragment: Integer;
  lEndHtml: Integer;
  lHeader: AnsiString;
  lHtml: UTF8String;
  lStartFragment: Integer;
  lStartHtml: Integer;
begin
  lHeader := AnsiString(Format(cHeaderTemplate, [0, 0, 0, 0, 0, 0]));
  lHtml := UTF8String('<html><body>' + cStartFragmentMarker) +
    UTF8String(AHtmlFragment) +
    UTF8String(cEndFragmentMarker + '</body></html>');

  lStartHtml := Length(lHeader);
  lStartFragment := lStartHtml +
    Pos(UTF8String(cStartFragmentMarker), lHtml) - 1 + Length(cStartFragmentMarker);
  lEndFragment := lStartHtml + Pos(UTF8String(cEndFragmentMarker), lHtml) - 1;
  lEndHtml := lStartHtml + Length(lHtml);

  lHeader := AnsiString(Format(cHeaderTemplate,
    [lStartHtml, lEndHtml, lStartFragment, lEndFragment,
     lStartFragment, lEndFragment]));
  Result := UTF8String(lHeader) + lHtml;
end;

function TDScintilla.BuildSelectionHtmlClipboard(out APlainText: UnicodeString;
  out AHtmlData: UTF8String): Boolean;
var
  lFragment: UnicodeString;
  lPos: NativeInt;
  lRunEnd: NativeInt;
  lRunStart: NativeInt;
  lStyle: Integer;
begin
  APlainText := '';
  AHtmlData := '';
  Result := False;

  lRunStart := SelectionStart;
  lRunEnd := SelectionEnd;
  if lRunEnd <= lRunStart then
    Exit;

  APlainText := GetTextRange(lRunStart, lRunEnd);
  lFragment := Format('<pre style="margin:0; white-space:pre-wrap; tab-size:%d;">',
    [TabWidth]);

  lPos := lRunStart;
  while lPos < lRunEnd do
  begin
    lRunStart := lPos;
    lStyle := StyleAt[lRunStart];
    lPos := PositionAfter(lPos);
    if (lPos <= lRunStart) or (lPos > lRunEnd) then
      lPos := lRunEnd;

    while lPos < lRunEnd do
    begin
      if StyleAt[lPos] <> lStyle then
        Break;
      lPos := PositionAfter(lPos);
      if lPos <= lRunStart then
      begin
        lPos := lRunEnd;
        Break;
      end;
    end;

    lFragment := lFragment + Format('<span style="%s">%s</span>',
      [StyleToHtmlCss(lStyle), EscapeHtmlText(GetTextRange(lRunStart, lPos))]);
  end;

  lFragment := lFragment + '</pre>';
  AHtmlData := BuildHtmlClipboardData(lFragment);
  Result := True;
end;

procedure TDScintilla.SetClipboardTextData(const APlainText: UnicodeString);
var
  lData: HGLOBAL;
  lSize: NativeUInt;
  lTarget: PWideChar;
begin
  lSize := (Length(APlainText) + 1) * SizeOf(Char);
  lData := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT, lSize);
  if lData = 0 then
    RaiseLastOSError;
  try
    lTarget := GlobalLock(lData);
    if lTarget = nil then
      RaiseLastOSError;
    try
      if Length(APlainText) > 0 then
        Move(PChar(APlainText)^, lTarget^, Length(APlainText) * SizeOf(Char));
      lTarget[Length(APlainText)] := #0;
    finally
      GlobalUnlock(lData);
    end;

    if Windows.SetClipboardData(CF_UNICODETEXT, lData) = 0 then
      RaiseLastOSError;
    lData := 0;
  finally
    if lData <> 0 then
      GlobalFree(lData);
  end;
end;

procedure TDScintilla.SetClipboardUtf8Data(AFormat: UINT; const AData: UTF8String);
var
  lBuffer: Pointer;
  lData: HGLOBAL;
begin
  lData := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT, Length(AData) + 1);
  if lData = 0 then
    RaiseLastOSError;
  try
    lBuffer := GlobalLock(lData);
    if lBuffer = nil then
      RaiseLastOSError;
    try
      if Length(AData) > 0 then
        Move(PAnsiChar(AData)^, lBuffer^, Length(AData));
      PByte(NativeUInt(lBuffer) + NativeUInt(Length(AData)))^ := 0;
    finally
      GlobalUnlock(lData);
    end;

    if Windows.SetClipboardData(AFormat, lData) = 0 then
      RaiseLastOSError;
    lData := 0;
  finally
    if lData <> 0 then
      GlobalFree(lData);
  end;
end;

procedure TDScintilla.SetClipboardHtml(const APlainText: UnicodeString;
  const AHtmlData: UTF8String);
begin
  Clipboard.Open;
  try
    Clipboard.Clear;
    SetClipboardTextData(APlainText);
    SetClipboardUtf8Data(HtmlClipboardFormat, AHtmlData);
  finally
    Clipboard.Close;
  end;
end;

procedure TDScintilla.CopySelectionAsHtml;
var
  lHtmlData: UTF8String;
  lPlainText: UnicodeString;
begin
  if not BuildSelectionHtmlClipboard(lPlainText, lHtmlData) then
    Exit;
  SetClipboardHtml(lPlainText, lHtmlData);
end;

procedure TDScintilla.DefaultContextMenuClick(Sender: TObject);
var
  lCurLine, lFoldHeaderLine: NativeInt;
  lLevel: Integer;
begin
  if not (Sender is TMenuItem) then
    Exit;

  case TMenuItem(Sender).Tag of
    cDefaultContextMenuTagUndo:
      Undo;
    cDefaultContextMenuTagCut:
      Cut;
    cDefaultContextMenuTagCopy:
      Copy;
    cDefaultContextMenuTagCopyWithFormatting:
      CopySelectionAsHtml;
    cDefaultContextMenuTagPaste:
      Paste;
    cDefaultContextMenuTagDelete:
      Clear;
    cDefaultContextMenuTagSelectAll:
      SelectAll;
    cDefaultContextMenuTagFoldAll:
      FoldAll(scfaCONTRACT_EVERY_LEVEL);
    cDefaultContextMenuTagUnfoldAll:
      FoldAll(scfaEXPAND);
    cDefaultContextMenuTagFoldCurrent,
    cDefaultContextMenuTagUnfoldCurrent,
    cDefaultContextMenuTagFoldNested,
    cDefaultContextMenuTagUnfoldNested:
    begin
      lCurLine := LineFromPosition(CurrentPos);
      lLevel := SendEditor(SCI_GETFOLDLEVEL, WPARAM(lCurLine), 0);
      if (lLevel and SC_FOLDLEVELHEADERFLAG) <> 0 then
        lFoldHeaderLine := lCurLine
      else
        lFoldHeaderLine := FoldParent[lCurLine];

      if lFoldHeaderLine >= 0 then
      begin
        case TMenuItem(Sender).Tag of
          cDefaultContextMenuTagFoldCurrent:
            FoldLine(lFoldHeaderLine, scfaCONTRACT);
          cDefaultContextMenuTagUnfoldCurrent:
            FoldLine(lFoldHeaderLine, scfaEXPAND);
          cDefaultContextMenuTagFoldNested:
            FoldChildren(lFoldHeaderLine, scfaCONTRACT);
          cDefaultContextMenuTagUnfoldNested:
            FoldChildren(lFoldHeaderLine, scfaEXPAND);
        end;
      end;
    end;
  end;
end;

procedure TDScintilla.DefaultContextMenuPopup(Sender: TObject);
var
  lCurLine, lFoldHeaderLine: NativeInt;
  lHasFolds, lHasCurrentFold: Boolean;
  lLevel: Integer;
begin
  FDefaultMenuUndo.Enabled := CanUndo and not ReadOnly;
  FDefaultMenuCut.Enabled := (not SelectionEmpty) and not ReadOnly;
  FDefaultMenuCopy.Enabled := not SelectionEmpty;
  FDefaultMenuCopyWithFormatting.Enabled := not SelectionEmpty;
  FDefaultMenuPaste.Enabled := CanPaste and not ReadOnly;
  FDefaultMenuDelete.Enabled := (not SelectionEmpty) and not ReadOnly;
  FDefaultMenuSelectAll.Enabled := TextLength > 0;

  lHasFolds := TextLength > 0;
  lHasCurrentFold := False;

  if lHasFolds then
  begin
    lCurLine := LineFromPosition(CurrentPos);
    lLevel := SendEditor(SCI_GETFOLDLEVEL, WPARAM(lCurLine), 0);
    if (lLevel and SC_FOLDLEVELHEADERFLAG) <> 0 then
      lFoldHeaderLine := lCurLine
    else
      lFoldHeaderLine := FoldParent[lCurLine];
    lHasCurrentFold := lFoldHeaderLine >= 0;
  end;

  FDefaultMenuFolding.Visible := lHasFolds;
  FDefaultMenuFoldAll.Enabled := lHasFolds;
  FDefaultMenuUnfoldAll.Enabled := lHasFolds;
  FDefaultMenuFoldCurrent.Enabled := lHasCurrentFold;
  FDefaultMenuUnfoldCurrent.Enabled := lHasCurrentFold;
  FDefaultMenuFoldNested.Enabled := lHasCurrentFold;
  FDefaultMenuUnfoldNested.Enabled := lHasCurrentFold;
end;

procedure TDScintilla.GutterContextMenuPopup(Sender: TObject);

  procedure CloneMenuItems(ASource: TPopupMenu; ATarget: TMenuItem);
  var
    lClone: TMenuItem;
    lIndex: Integer;
    lSrc: TMenuItem;
    lSubClone: TMenuItem;
    lSubIndex: Integer;
  begin
    ATarget.Clear;
    if ASource = nil then
      Exit;
    for lIndex := 0 to ASource.Items.Count - 1 do
    begin
      lSrc := ASource.Items[lIndex];
      lClone := TMenuItem.Create(ATarget);
      lClone.Caption := lSrc.Caption;
      lClone.Hint := lSrc.Hint;
      lClone.Tag := lSrc.Tag;
      lClone.RadioItem := lSrc.RadioItem;
      lClone.AutoCheck := lSrc.AutoCheck;
      lClone.Checked := lSrc.Checked;
      lClone.OnClick := lSrc.OnClick;
      // Clone one level of sub-items (buckets)
      for lSubIndex := 0 to lSrc.Count - 1 do
      begin
        lSubClone := TMenuItem.Create(lClone);
        lSubClone.Caption := lSrc.Items[lSubIndex].Caption;
        lSubClone.Hint := lSrc.Items[lSubIndex].Hint;
        lSubClone.Tag := lSrc.Items[lSubIndex].Tag;
        lSubClone.RadioItem := lSrc.Items[lSubIndex].RadioItem;
        lSubClone.AutoCheck := lSrc.Items[lSubIndex].AutoCheck;
        lSubClone.Checked := lSrc.Items[lSubIndex].Checked;
        lSubClone.OnClick := lSrc.Items[lSubIndex].OnClick;
        lClone.Add(lSubClone);
      end;
      ATarget.Add(lClone);
    end;
  end;

begin
  FGutterMenuSettings.Visible := Assigned(FOnGutterSettings);

  RebuildStatusBarLexerMenu;
  CloneMenuItems(FStatusBarLexerPopup, FGutterMenuLexer);

  RebuildStatusBarEncodingMenu;
  CloneMenuItems(FStatusBarEncodingPopup, FGutterMenuEncoding);

  RebuildStatusBarThemeMenu;
  if (FStatusBarThemePopup <> nil) and (FStatusBarThemePopup.Items.Count > 1) then
  begin
    CloneMenuItems(FStatusBarThemePopup, FGutterMenuTheme);
    FGutterMenuTheme.Visible := True;
  end
  else
    FGutterMenuTheme.Visible := False;
end;

procedure TDScintilla.GutterMenuSettingsClick(Sender: TObject);
begin
  if Assigned(FOnGutterSettings) then
    FOnGutterSettings(Self);
end;

procedure TDScintilla.SetAutoBraceHighlight(const Value: Boolean);
begin
  if FAutoBraceHighlight = Value then
    Exit;

  FAutoBraceHighlight := Value;
  if not FAutoBraceHighlight and HandleAllocated then
    ApplyBraceHighlight(INVALID_POSITION, INVALID_POSITION);
end;

procedure TDScintilla.SetDefaultContextMenuEnabled(const Value: Boolean);
begin
  FDefaultContextMenuEnabled := Value;
end;

procedure TDScintilla.SetDefaultTechnology(const Value: TDSciTechnology);
begin
  if FDefaultTechnology = Value then
    Exit;

  FDefaultTechnology := Value;
  if HandleAllocated then
    Technology := FDefaultTechnology;
end;

procedure TDScintilla.SetUseAssignedPopupMenu(const Value: Boolean);
begin
  FUseAssignedPopupMenu := Value;
end;

function TDScintilla.GetLexilla: TDLexilla;
begin
  if FLexilla = nil then
    FLexilla := TDLexilla.Create;
  FLexilla.DllModule := DllModule;
  Result := FLexilla;
end;

function TDScintilla.ResolveDllModulePath: string;
var
  lCandidate: string;
begin
  Result := Trim(DllModule);
  if Result = '' then
    Exit('');

  if FileExists(Result) then
    Exit(ExpandFileName(Result));

  lCandidate := ExpandFileName(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + Result);
  if FileExists(lCandidate) then
    Result := lCandidate;
end;

procedure TDScintilla.CreateWnd;
var
  lIsRecreating: Boolean;
begin
  lIsRecreating := IsRecreatingWnd;

  inherited CreateWnd;
  CreateStatusBarIfNeeded;

  if FLexilla <> nil then
    FLexilla.DllModule := DllModule;

  if not lIsRecreating then
  begin
    // Set UTF8 early, so Lines with non ANSI char loads from .dfm correctly
    // Later in InitDefaults/OnInitDefaults can be overwritten
    SetCodePage(SC_CP_UTF8);

    // Delay calling DoInitDefaults when loading component from .dfm
    // OnInitDefaults might not be set yet, so you can miss this event
    FInitDefaultsDelayed := csLoading in ComponentState;
    if not FInitDefaultsDelayed then
      DoInitDefaults;
  end;
end;

procedure TDScintilla.DestroyWnd;
begin
  CancelLoadFromFile(True);
  FlushPendingFileLoadMessages;
  RefreshStatusBarVisibility;
  inherited DestroyWnd;
end;

procedure TDScintilla.Loaded;
begin
  inherited Loaded;
  RefreshStatusBarVisibility;

  if FInitDefaultsDelayed then
  begin
    FInitDefaultsDelayed := False;
    DoInitDefaults;
  end;
end;

procedure TDScintilla.InitDefaults;
var
  lFontLocale: UnicodeString;
begin
  // By default set UTF8 mode
  SetCodePage(SC_CP_UTF8);
  UsePopUp(scpuNEVER);
  if FDefaultTechnology <> sctDEFAULT then
    Technology := FDefaultTechnology;
  FontQuality := scfqQUALITY_LCD_OPTIMIZED;
  if IsDirectWriteTechnology(Technology) then
  begin
    lFontLocale := DetectUserFontLocale;
    if lFontLocale <> '' then
      FontLocale := lFontLocale;
  end;
end;

procedure TDScintilla.DoInitDefaults;
begin
  InitDefaults;
  FSettings.Reapply;
  RefreshStatusBar;
  RebuildStatusBarLexerMenu;
  RebuildStatusBarEncodingMenu;

  { If anywhere in the parent control hierarchy a reparenting operation
    is performed, this can lead to the Scintilla handle being destroyed
    (and later recreated). This in turn leads to loss of styles etc.,
    which is pretty bad. This event gives the caller a chance to
    reinitialize all that stuff. }
  if Assigned(OnInitDefaults) then
    OnInitDefaults(Self);
end;

procedure TDScintilla.CMVisibleChanged(var AMessage: TMessage);
begin
  inherited;
  RefreshStatusBarVisibility;
end;

procedure TDScintilla.WMDSciReloadForEncodingChange(var AMessage: TMessage);
begin
  ReloadCurrentFileForEncodingChange;
  AMessage.Result := 1;
end;

procedure TDScintilla.CNNotify(var AMessage: TWMNotify);
begin
  if HandleAllocated and (AMessage.NMHdr^.hwndFrom = Self.Handle) then
    DoSCNotification(PDSciSCNotification(AMessage.NMHdr)^)
  else
    inherited;
end;

procedure TDScintilla.CNCommand(var AMessage: TWMCommand);
begin
  if AMessage.NotifyCode = SCEN_CHANGE then
  begin
    if Assigned(OnChange) then
      OnChange(Self);
  end else
    inherited;
end;

procedure TDScintilla.WMClear(var AMessage: TMessage);
begin
  Clear;
  AMessage.Result := 1;
end;

procedure TDScintilla.WMCopy(var AMessage: TMessage);
begin
  Copy;
  AMessage.Result := 1;
end;

procedure TDScintilla.WMContextMenu(var AMessage: TWMContextMenu);
var
  lClientPoint: TPoint;
  lHandled: Boolean;
  lMenu: TPopupMenu;
  lPoint: TPoint;
begin
  // If WMRButtonUp already showed the popup for this click, suppress duplicate.
  if FContextMenuShownByRButton then
  begin
    FContextMenuShownByRButton := False;
    AMessage.Result := 1;
    Exit;
  end;

  lClientPoint := ContextMenuClientPoint(AMessage);
  lPoint := ContextMenuScreenPoint(AMessage);
  lHandled := False;
  DoContextPopup(lPoint, lHandled);
  if lHandled then
  begin
    AMessage.Result := 1;
    Exit;
  end;

  lMenu := ActiveContextMenu;
  if (lMenu <> nil) and not IsPointInMarginArea(lClientPoint) then
    ShowContextMenu(lMenu, lPoint)
  else if IsPointInMarginArea(lClientPoint) and (FGutterContextMenu <> nil) then
    ShowContextMenu(FGutterContextMenu, lPoint);

  AMessage.Result := 1;
end;

procedure TDScintilla.WMRButtonUp(var AMessage: TWMRButtonUp);
var
  lClientPoint: TPoint;
  lScreenPoint: TPoint;
  lHandled: Boolean;
  lMenu: TPopupMenu;
begin
  lClientPoint := SmallPointToPoint(AMessage.Pos);
  lScreenPoint := ClientToScreen(lClientPoint);

  lHandled := False;
  DoContextPopup(lScreenPoint, lHandled);
  if not lHandled then
  begin
    lMenu := ActiveContextMenu;
    if (lMenu <> nil) and not IsPointInMarginArea(lClientPoint) then
      ShowContextMenu(lMenu, lScreenPoint)
    else if IsPointInMarginArea(lClientPoint) and (FGutterContextMenu <> nil) then
      ShowContextMenu(FGutterContextMenu, lScreenPoint);
  end;

  // Suppress the subsequent WM_CONTEXTMENU that the system generates from
  // WM_RBUTTONUP via DefWindowProc - the popup was already shown above.
  FContextMenuShownByRButton := True;
  inherited;
end;

procedure TDScintilla.WMCut(var AMessage: TMessage);
begin
  Cut;
  AMessage.Result := 1;
end;

procedure TDScintilla.WMPaste(var AMessage: TMessage);
begin
  Paste;
  AMessage.Result := 1;
end;

procedure TDScintilla.WMDSciFileLoadStatus(var AMessage: TMessage);
var
  lPayload: TDSciFileLoadStatusPayload;
begin
  lPayload := TDSciFileLoadStatusPayload(Pointer(AMessage.LParam));
  try
    if (lPayload <> nil) and (lPayload.Sequence = FFileLoadSequence) then
    begin
      SetFileLoadStatus(lPayload.Status);
      if IsTerminalFileLoadStage(lPayload.Status.Stage) then
        FinalizeFileLoadThread;
    end;
  finally
    lPayload.Free;
  end;
end;

procedure TDScintilla.WMDSciFileLoadAttach(var AMessage: TMessage);
var
  lPayload: TDSciFileLoadAttachPayload;
begin
  lPayload := TDSciFileLoadAttachPayload(Pointer(AMessage.LParam));
  try
    if lPayload = nil then
      Exit;

    if lPayload.Sequence <> FFileLoadSequence then
      Exit;

    try
      AttachLoadedDocument(lPayload.Loader, lPayload.Document, lPayload.FileName,
        lPayload.IsAsync, lPayload.Encoding, lPayload.EncodingCodePage,
        lPayload.EncodingName);
      lPayload.Loader := nil;
    except
      on E: Exception do
        SetFileLoadStatus(MakeFileLoadStatus(lPayload.FileName, sflsFailed, 0,
          0, E.Message, lPayload.IsAsync, lPayload.Encoding,
          lPayload.EncodingCodePage, lPayload.EncodingName));
    end;
    FinalizeFileLoadThread;
  finally
    ReleaseLoaderPointer(lPayload.Loader);
    lPayload.Free;
  end;
end;

procedure TDScintilla.WMUndo(var AMessage: TMessage);
begin
  Undo;
  AMessage.Result := 1;
end;

procedure TDScintilla.ApplyBraceHighlight(AHighlightPos,
  AMatchPos: NativeInt);
begin
  if AHighlightPos < 0 then
  begin
    BraceBadLight(INVALID_POSITION);
    BraceHighlight(INVALID_POSITION, INVALID_POSITION);
    HighlightGuide := 0;
    Exit;
  end;

  if AMatchPos >= 0 then
  begin
    BraceBadLight(INVALID_POSITION);
    BraceHighlight(AHighlightPos, AMatchPos);
    HighlightGuide := Min(GetColumn(AHighlightPos), GetColumn(AMatchPos));
  end
  else
  begin
    BraceHighlight(INVALID_POSITION, INVALID_POSITION);
    BraceBadLight(AHighlightPos);
    HighlightGuide := 0;
  end;
end;

procedure TDScintilla.DoNeedShown(const ASCNotification: TDSciSCNotification);
begin
  if Assigned(FOnNeedShown) then
    FOnNeedShown(Self, ASCNotification.position, ASCNotification.length)
  else
  begin
    // Fix for: https://code.google.com/p/dscintilla/issues/detail?id=4
    //
    // SciTE does same thing: scite/src/SciTEBase.cxx ... case SCN_NEEDSHOWN: { ...
    // Also docs tells that it need to be done:
    // http://www.scintilla.org/ScintillaDoc.html#SCN_NEEDSHOWN
    EnsureRangeVisible(ASCNotification.position, ASCNotification.position + ASCNotification.length);
  end;
end;

procedure TDScintilla.ShowContextMenu(APopupMenu: TPopupMenu;
  const AScreenPoint: TPoint);
begin
  if APopupMenu = nil then
    Exit;

  APopupMenu.PopupComponent := Self;
  APopupMenu.Popup(AScreenPoint.X, AScreenPoint.Y);
end;

procedure TDScintilla.UpdateBraceHighlighting;
var
  lBracePos: NativeInt;
  lMatchPos: NativeInt;
begin
  lBracePos := CurrentPos;
  if (lBracePos >= 0) and not IsBraceChar(GetCharAt(lBracePos)) then
    Dec(lBracePos);

  if (lBracePos < 0) or not IsBraceChar(GetCharAt(lBracePos)) then
  begin
    ApplyBraceHighlight(INVALID_POSITION, INVALID_POSITION);
    Exit;
  end;

  lMatchPos := BraceMatch(lBracePos, 0);
  ApplyBraceHighlight(lBracePos, lMatchPos);
end;

function TDScintilla.DoSCNotification(const ASCNotification: TDSciSCNotification): Boolean;
begin
  Result := False;

  if Assigned(FOnSCNotificationEvent) then
    FOnSCNotificationEvent(Self, ASCNotification, Result);

  if Result then
    Exit;

  Result := True;

  case ASCNotification.NotifyHeader.code of
  SCN_STYLENEEDED:
    if Assigned(FOnStyleNeeded) then
      FOnStyleNeeded(Self, ASCNotification.position);

  SCN_CHARADDED:
    begin
      FSettings.NotifyCharAdded(ASCNotification.ch);
      if Assigned(FOnCharAdded) then
        FOnCharAdded(Self, ASCNotification.ch);
    end;

  SCN_SAVEPOINTREACHED:
    if Assigned(FOnSavePointReached) then
      FOnSavePointReached(Self);

  SCN_SAVEPOINTLEFT:
    if Assigned(FOnSavePointLeft) then
      FOnSavePointLeft(Self);

  SCN_MODIFYATTEMPTRO:
    if Assigned(FOnModifyAttemptRO) then
      FOnModifyAttemptRO(Self);

  SCN_UPDATEUI:
    begin
      if FAutoBraceHighlight then
        UpdateBraceHighlighting
      else
        ApplyBraceHighlight(INVALID_POSITION, INVALID_POSITION);

      FSettings.NotifyUpdateUI(ASCNotification.updated);
      DoUpdateUI(TDSciUpdateFlagsSetFromInt(ASCNotification.updated));
    end;

  SCN_FOCUSIN:
    if Assigned(FOnFocusIn) then
      FOnFocusIn(Self);

  SCN_FOCUSOUT:
    if Assigned(FOnFocusOut) then
      FOnFocusOut(Self);

  SCN_MODIFIED:
    begin
      FSettings.NotifyModified;
      if Assigned(FOnModified) then
        FOnModified(Self, ASCNotification.position, ASCNotification.modificationType,
          FHelper.GetStrFromPtr(ASCNotification.text), ASCNotification.length,
          ASCNotification.linesAdded, ASCNotification.line,
          ASCNotification.foldLevelNow, ASCNotification.foldLevelPrev);

      if Assigned(FOnModified2) then
        FOnModified2(Self, ASCNotification.position, ASCNotification.modificationType,
          FHelper.GetStrFromPtr(ASCNotification.text), ASCNotification.length,
          ASCNotification.linesAdded, ASCNotification.line,
          ASCNotification.foldLevelNow, ASCNotification.foldLevelPrev,
          ASCNotification.token, ASCNotification.annotationLinesAdded);
    end;

  SCN_MACRORECORD:
    if Assigned(FOnMacroRecord) then
      FOnMacroRecord(Self, ASCNotification.message, ASCNotification.wParam,
        ASCNotification.lParam);

  SCN_MARGINCLICK:
    if Assigned(FOnMarginClick) then
      FOnMarginClick(Self, ASCNotification.modifiers,
        ASCNotification.position, ASCNotification.margin);

  SCN_NEEDSHOWN:
    DoNeedShown(ASCNotification);

  SCN_PAINTED:
    if Assigned(FOnPainted) then
      FOnPainted(Self);

  SCN_USERLISTSELECTION:
    begin
      if Assigned(FOnUserListSelection) then
        FOnUserListSelection(Self, ASCNotification.listType,
          FHelper.GetStrFromPtr(ASCNotification.text));

      if Assigned(FOnUserListSelection2) then
        FOnUserListSelection2(Self, ASCNotification.listType,
          FHelper.GetStrFromPtr(ASCNotification.text),
          ASCNotification.position);
    end;

  SCN_DWELLSTART:
    if Assigned(FOnDwellStart) then
      FOnDwellStart(Self, ASCNotification.position, ASCNotification.x, ASCNotification.y);

  SCN_DWELLEND:
    if Assigned(FOnDwellEnd) then
      FOnDwellEnd(Self, ASCNotification.position, ASCNotification.x, ASCNotification.y);

  SCN_ZOOM:
    if Assigned(FOnZoom) then
      FOnZoom(Self);

  SCN_HOTSPOTCLICK:
    if Assigned(FOnHotSpotClick) then
      FOnHotSpotClick(Self, ASCNotification.modifiers, ASCNotification.position);

  SCN_HOTSPOTDOUBLECLICK:
    if Assigned(FOnHotSpotDoubleClick) then
      FOnHotSpotDoubleClick(Self, ASCNotification.modifiers, ASCNotification.position);

  SCN_HOTSPOTRELEASECLICK:
    if Assigned(FOnHotSpotReleaseClick) then
      FOnHotSpotReleaseClick(Self, ASCNotification.modifiers, ASCNotification.position);

  SCN_CALLTIPCLICK:
    if Assigned(FOnCallTipClick) then
      FOnCallTipClick(Self, ASCNotification.position);

  SCN_AUTOCSELECTION:
    if Assigned(FOnAutoCSelection) then
      FOnAutoCSelection(Self, FHelper.GetStrFromPtr(ASCNotification.text),
        ASCNotification.lParam);

  SCN_INDICATORCLICK:
    if Assigned(FOnIndicatorClick) then
      FOnIndicatorClick(Self, ASCNotification.modifiers, ASCNotification.position);

  SCN_INDICATORRELEASE:
    if Assigned(FOnIndicatorRelease) then
      FOnIndicatorRelease(Self, ASCNotification.modifiers, ASCNotification.position);

  SCN_AUTOCCANCELLED:
    if Assigned(FOnAutoCCancelled) then
      FOnAutoCCancelled(Self);

  SCN_AUTOCCHARDELETED:
    if Assigned(FOnAutoCCharDeleted) then
      FOnAutoCCharDeleted(Self);
  else
    Result := False;
  end;
end;

procedure TDScintilla.DoUpdateUI(AFlags: TDSciUpdateFlagsSet);
begin
  if (csDestroying in ComponentState) then
    Exit;

  if (AFlags * [scuCONTENT, scuSELECTION] <> []) and Assigned(FStatusBar) and
    FStatusBarVisible and FStatusPanelPosVisible then
    RefreshStatusBar;

  if Assigned(FOnUpdateUI) then
    FOnUpdateUI(Self, AFlags);
end;

// -----------------------------------------------------------------------------
// Scintilla methods -----------------------------------------------------------
// -----------------------------------------------------------------------------

{$I DScintillaMethodsCode.inc}
{$I DScintillaUnsafeCode.inc}

// -----------------------------------------------------------------------------
// Scintilla properties --------------------------------------------------------
// -----------------------------------------------------------------------------

{$I DScintillaPropertiesCode.inc}

procedure TDScintilla.SetFocus;
begin
  inherited SetFocus;
end;

procedure TDScintilla.EnsureRangeVisible(APosStart, APosEnd: Integer);
var
  lLineStart, lLineEnd, lLine: Integer;
begin
  lLineStart := LineFromPosition(Min(APosStart, APosEnd));
  lLineEnd := LineFromPosition(Max(APosStart, APosEnd));

  for lLine := lLineStart to lLineEnd do
    EnsureVisible(lLine);
end;

end.

