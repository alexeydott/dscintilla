unit TestDScintillaTyped;

interface

uses
  Forms, Menus, System.Generics.Collections, System.Types, TestFramework,
  DScintilla, DScintillaTypes, DLexilla;

type
  TDScintillaAccess = class(TDScintilla)
  private
    FContextMenuShowCount: Integer;
    FLastBraceHighlightPos: NativeInt;
    FLastBraceMatchPos: NativeInt;
    FLastContextMenu: TPopupMenu;
    FLastContextMenuPoint: TPoint;
  protected
    procedure ApplyBraceHighlight(AHighlightPos, AMatchPos: NativeInt); override;
    procedure ShowContextMenu(APopupMenu: TPopupMenu; const AScreenPoint: TPoint); override;
  public
    function DispatchNotificationForTest(ACode: Cardinal): Boolean;
    function DispatchCharAddedForTest(ACh: Integer): Boolean;
    function DispatchModifiedForTest(AModificationType: Integer = 0): Boolean;
    function DispatchUpdateUIForTest(AUpdated: Integer = 0): Boolean;
    procedure ResetBraceHighlightForTest;
    procedure ResetContextMenuForTest;
    property ContextMenuShowCount: Integer read FContextMenuShowCount;
    property LastBraceHighlightPos: NativeInt read FLastBraceHighlightPos;
    property LastBraceMatchPos: NativeInt read FLastBraceMatchPos;
    property LastContextMenu: TPopupMenu read FLastContextMenu;
    property LastContextMenuPoint: TPoint read FLastContextMenuPoint;
  end;

  TFileLoadRecorder = class
  private
    FStatuses: TList<TDSciFileLoadStatus>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure HandleFileLoadState(Sender: TObject; const AStatus: TDSciFileLoadStatus);
    function HasStage(AStage: TDSciFileLoadStage): Boolean;
    property Statuses: TList<TDSciFileLoadStatus> read FStatuses;
  end;

  TTestDScintillaTyped = class(TTestCase)
  strict private
    FForm: TForm;
    FScintilla: TDScintilla;
    FFocusInCount: Integer;
    FFocusOutCount: Integer;
    procedure HandleFocusIn(Sender: TObject);
    procedure HandleFocusOut(Sender: TObject);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestDoubleBufferedRoundTrip;
    procedure TestModernVCLPublishedSurface;
    procedure TestDefaultTabStop;
    procedure TestParentDoubleBufferedInheritance;
    procedure TestCrossThreadFirstCallWithoutHandleFails;
    procedure TestCrossThreadSendEditorUsesMessageFallback;
    procedure TestPostEditorQueuesNoResultCommand;
    procedure TestDllModuleReload;
    procedure TestFocusNotifications;
    procedure TestGeneratedSurfaceHidesUnsafeApi;
    procedure TestGeneratedPropertiesIncludeXmlDocumentation;
    procedure TestGeneratedPublicPropertiesKeepSparseSetterPairs;
    procedure TestLexerLanguagePublicApi;
    procedure TestLexillaRawExportCall;
    procedure TestLexillaStringApiUsesSharedDll;
    procedure TestSettingsConfigFileActivatesLexerForNamedLanguage;
    procedure TestSettingsResolveLanguageByExtension;
    procedure TestSettingsLegacyImportApisRaiseNotSupported;
    procedure TestSettingsConfigSurvivesRecreateWnd;
    procedure TestSettingsClearLanguageResetsLexerState;
    procedure TestSettingsConfigFileAppliesEditorOptions;
    procedure TestSettingsConfigFileCompatibility;
    procedure TestSettingsConfigFileLoadFailureKeepsPreviousConfig;
    procedure TestSettingsMissingConfigFileCreatesEmbeddedDefault;
    procedure TestSettingsUnknownExtensionFallsBackToDefault;
    procedure TestSettingsConfigFilePersistsAndAppliesRenderingOptions;
    procedure TestSettingsUnavailableHtmlLexerFallsBackToDefault;
    procedure TestSettingsConfigAutoCompletionLoadsFromAdjacentFolder;
    procedure TestSettingsConfigFunctionListShowsCallTipFromAdjacentFolder;
    procedure TestSettingsRealCppFunctionListExtractsFunctions;
    procedure TestSettingsMalformedSidecarsDoNotAbortConfigApply;
    procedure TestAssignedPopupMenuCanBeEnabledOrDisabled;
    procedure TestAssignedPopupMenuStaysHiddenOverMarginArea;
    procedure TestAutoBraceHighlightTracksCaret;
    procedure TestCopyWithFormattingPlacesCfHtmlOnClipboard;
    procedure TestDefaultTechnologyUsesDirectWriteRetain;
    procedure TestBeginLoadFromFileReportsProgressAndCompletes;
    procedure TestKeyboardContextMenuUsesCaretLocation;
    procedure TestLoadFromFileLoadsTextSynchronously;
    procedure TestLoadFromFileEnablesUndoAfterEdit;
    procedure TestBeginLoadFromFileEnablesUndoAfterEdit;
    procedure TestLoadFromFileSizeLimitRejectsOversizedFile;
    procedure TestBeginLoadFromFileSizeLimitRejectsOversizedFile;
    procedure TestLoadFromFileZeroLimitMeansNoLimit;
    procedure TestWindowsEditCommandsRouteToScintilla;
    procedure TestWantsSpecialKeysForScintillaKeyboardCommands;
    procedure TestTextRoundTrip;
    procedure TestTypedEnumProperties;
    procedure TestEnumSetProperties;
    procedure TestStyleCharacterSetRoundTrip;
    procedure TestMarkerLayerRoundTrip;
    procedure TestPropertyLookup;
    procedure TestSettingsThemeXmlsAreWellFormed;
  end;

implementation

uses
  Classes, Clipbrd, Controls, Generics.Collections, Graphics, IOUtils, SyncObjs,
  SysUtils, TypInfo,
  DScintillaLanguageServices,
  DScintillaLogger,
  DScintillaVisualConfig,
  Windows, Messages;

function TDScintillaAccess.DispatchNotificationForTest(ACode: Cardinal): Boolean;
var
  lNotification: TDSciSCNotification;
begin
  FillChar(lNotification, SizeOf(lNotification), 0);
  lNotification.NotifyHeader.code := ACode;
  Result := DoSCNotification(lNotification);
end;

function TDScintillaAccess.DispatchCharAddedForTest(ACh: Integer): Boolean;
var
  lNotification: TDSciSCNotification;
begin
  FillChar(lNotification, SizeOf(lNotification), 0);
  lNotification.NotifyHeader.code := SCN_CHARADDED;
  lNotification.ch := ACh;
  Result := DoSCNotification(lNotification);
end;

function TDScintillaAccess.DispatchModifiedForTest(
  AModificationType: Integer): Boolean;
var
  lNotification: TDSciSCNotification;
begin
  FillChar(lNotification, SizeOf(lNotification), 0);
  lNotification.NotifyHeader.code := SCN_MODIFIED;
  lNotification.modificationType := AModificationType;
  Result := DoSCNotification(lNotification);
end;

function TDScintillaAccess.DispatchUpdateUIForTest(AUpdated: Integer): Boolean;
var
  lNotification: TDSciSCNotification;
begin
  FillChar(lNotification, SizeOf(lNotification), 0);
  lNotification.NotifyHeader.code := SCN_UPDATEUI;
  lNotification.updated := AUpdated;
  Result := DoSCNotification(lNotification);
end;

procedure TDScintillaAccess.ApplyBraceHighlight(AHighlightPos,
  AMatchPos: NativeInt);
begin
  FLastBraceHighlightPos := AHighlightPos;
  FLastBraceMatchPos := AMatchPos;
  inherited ApplyBraceHighlight(AHighlightPos, AMatchPos);
end;

procedure TDScintillaAccess.ResetBraceHighlightForTest;
begin
  FLastBraceHighlightPos := INVALID_POSITION;
  FLastBraceMatchPos := INVALID_POSITION;
end;

procedure TDScintillaAccess.ResetContextMenuForTest;
begin
  FContextMenuShowCount := 0;
  FLastContextMenu := nil;
  FLastContextMenuPoint := Point(-1, -1);
end;

procedure TDScintillaAccess.ShowContextMenu(APopupMenu: TPopupMenu;
  const AScreenPoint: TPoint);
begin
  FLastContextMenu := APopupMenu;
  FLastContextMenuPoint := AScreenPoint;
  Inc(FContextMenuShowCount);
end;

constructor TFileLoadRecorder.Create;
begin
  inherited Create;
  FStatuses := TList<TDSciFileLoadStatus>.Create;
end;

destructor TFileLoadRecorder.Destroy;
begin
  FStatuses.Free;
  inherited Destroy;
end;

procedure TFileLoadRecorder.HandleFileLoadState(Sender: TObject;
  const AStatus: TDSciFileLoadStatus);
begin
  FStatuses.Add(AStatus);
end;

function TFileLoadRecorder.HasStage(AStage: TDSciFileLoadStage): Boolean;
var
  lStatus: TDSciFileLoadStatus;
begin
  Result := False;
  for lStatus in FStatuses do
    if lStatus.Stage = AStage then
      Exit(True);
end;

procedure TTestDScintillaTyped.HandleFocusIn(Sender: TObject);
begin
  Inc(FFocusInCount);
end;

procedure TTestDScintillaTyped.HandleFocusOut(Sender: TObject);
begin
  Inc(FFocusOutCount);
end;

function ResolveSharedDllPath(AScintilla: TDScintilla): string;
begin
  Result := ExpandFileName(ExtractFilePath(ParamStr(0)) + AScintilla.DllModule);
end;

function ResolveSettingsDir: string;
begin
  Result := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..\settings');
end;

function ResolveSourceFile(const ARelativePath: string): string;
begin
  Result := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..\' + ARelativePath);
end;

function WaitForEventWithMessagePump(AEvent: TEvent; ATimeoutMs: Cardinal): Boolean;
var
  lStartTick: Cardinal;
begin
  lStartTick := GetTickCount;
  repeat
    if AEvent.WaitFor(10) = wrSignaled then
      Exit(True);

    Application.ProcessMessages;
    Sleep(1);
  until GetTickCount - lStartTick >= ATimeoutMs;

  Result := False;
end;

function TrySetClipboardText(const AText: string; ATimeoutMs: Cardinal = 1000): Boolean;
var
  lStartTick: Cardinal;
begin
  lStartTick := GetTickCount;
  repeat
    try
      Clipboard.AsText := AText;
      Exit(True);
    except
      on EClipboardException do
      begin
        Application.ProcessMessages;
        Sleep(10);
      end;
    end;
  until GetTickCount - lStartTick >= ATimeoutMs;

  Result := False;
end;

function TryGetClipboardText(out AText: string; ATimeoutMs: Cardinal = 1000): Boolean;
var
  lStartTick: Cardinal;
begin
  lStartTick := GetTickCount;
  repeat
    try
      AText := Clipboard.AsText;
      Exit(True);
    except
      on EClipboardException do
      begin
        Application.ProcessMessages;
        Sleep(10);
      end;
    end;
  until GetTickCount - lStartTick >= ATimeoutMs;

  AText := '';
  Result := False;
end;

function CreateWritableTempDir: string;
var
  lBaseDir: string;
begin
  lBaseDir := Trim(TPath.GetTempPath);
  if lBaseDir = '' then
    lBaseDir := TPath.Combine(ExtractFilePath(ParamStr(0)), 'temp');
  ForceDirectories(lBaseDir);
  Result := TPath.Combine(lBaseDir, TPath.GetRandomFileName);
  ForceDirectories(Result);
end;

function ContextMenuLParam(const APoint: TPoint): LPARAM;
begin
  Result := LPARAM((LongWord(Word(SmallInt(APoint.X))) and $FFFF) or
    (LongWord(Word(SmallInt(APoint.Y))) shl 16));
end;

function TryGetClipboardHtml(out AHtml: UTF8String; ATimeoutMs: Cardinal = 1000): Boolean;
var
  lData: THandle;
  lFormat: UINT;
  lPtr: PAnsiChar;
  lSize: NativeUInt;
  lStartTick: Cardinal;
begin
  lFormat := RegisterClipboardFormat('HTML Format');
  lStartTick := GetTickCount;
  repeat
    if not OpenClipboard(0) then
    begin
      Application.ProcessMessages;
      Sleep(10);
      Continue;
    end;
    try
      if not IsClipboardFormatAvailable(lFormat) then
      begin
        AHtml := '';
      end
      else
      begin
        lData := GetClipboardData(lFormat);
        if lData <> 0 then
        begin
          lSize := GlobalSize(lData);
          lPtr := GlobalLock(lData);
          if lPtr <> nil then
          begin
            try
              if (lSize > 0) and (lPtr[lSize - 1] = #0) then
                SetString(AHtml, lPtr, lSize - 1)
              else
                SetString(AHtml, lPtr, lSize);
              Exit(True);
            finally
              GlobalUnlock(lData);
            end;
          end;
        end;
      end;
    finally
      CloseClipboard;
    end;

    Application.ProcessMessages;
    Sleep(10);
  until GetTickCount - lStartTick >= ATimeoutMs;

  AHtml := '';
  Result := False;
end;

function FindMenuItemByCaption(APopupMenu: TPopupMenu;
  const ACaption: string): TMenuItem;
var
  lIndex: Integer;
begin
  Result := nil;
  if APopupMenu = nil then
    Exit;

  for lIndex := 0 to APopupMenu.Items.Count - 1 do
    if SameText(APopupMenu.Items[lIndex].Caption, ACaption) then
      Exit(APopupMenu.Items[lIndex]);
end;

procedure TTestDScintillaTyped.SetUp;
begin
  FForm := TForm.Create(nil);
  FForm.Visible := False;
  FForm.Width := 320;
  FForm.Height := 200;

  FScintilla := TDScintillaAccess.Create(FForm);
  FScintilla.Parent := FForm;
  FScintilla.Align := alClient;

  FForm.HandleNeeded;
  FScintilla.HandleNeeded;
  TDScintillaAccess(FScintilla).ResetBraceHighlightForTest;
  TDScintillaAccess(FScintilla).ResetContextMenuForTest;
end;

procedure TTestDScintillaTyped.TearDown;
begin
  FreeAndNil(FScintilla);
  FreeAndNil(FForm);
end;

procedure TTestDScintillaTyped.TestDoubleBufferedRoundTrip;
begin
  FScintilla.ParentDoubleBuffered := False;
  FScintilla.DoubleBuffered := True;
  Check(FScintilla.DoubleBuffered);

  FScintilla.DoubleBuffered := False;
  Check(not FScintilla.DoubleBuffered);
end;

procedure TTestDScintillaTyped.TestModernVCLPublishedSurface;

  procedure CheckPublishedProperty(const AName: string);
  begin
    Check(GetPropInfo(FScintilla.ClassInfo, AName) <> nil,
      Format('Published property "%s" expected on %s', [AName, FScintilla.ClassName]));
  end;

begin
  CheckPublishedProperty('Constraints');
  CheckPublishedProperty('Enabled');
  CheckPublishedProperty('Hint');
  CheckPublishedProperty('ShowHint');
  CheckPublishedProperty('ParentShowHint');
  CheckPublishedProperty('Visible');
  CheckPublishedProperty('DoubleBuffered');
  CheckPublishedProperty('DoubleBufferedMode');
  CheckPublishedProperty('ParentDoubleBuffered');
  CheckPublishedProperty('DragCursor');
  CheckPublishedProperty('DragKind');
  CheckPublishedProperty('DragMode');
  CheckPublishedProperty('ImeMode');
  CheckPublishedProperty('ImeName');
  CheckPublishedProperty('TabOrder');
  CheckPublishedProperty('TabStop');
  CheckPublishedProperty('OnEndDrag');
  CheckPublishedProperty('OnStartDrag');
  {$IF CompilerVersion >= 23}
  CheckPublishedProperty('Touch');
  CheckPublishedProperty('OnGesture');
  {$IFEND}
end;

procedure TTestDScintillaTyped.TestDefaultTabStop;
begin
  Check(FScintilla.TabStop, 'TDScintilla should behave like a focusable editor control');
end;

procedure TTestDScintillaTyped.TestParentDoubleBufferedInheritance;
begin
  FForm.DoubleBuffered := True;
  FScintilla.ParentDoubleBuffered := True;
  Check(FScintilla.DoubleBuffered);

  FForm.DoubleBuffered := False;
  Check(not FScintilla.DoubleBuffered);
end;

procedure TTestDScintillaTyped.TestCrossThreadFirstCallWithoutHandleFails;
var
  lForm: TForm;
  lScintilla: TDScintilla;
  lDone: TEvent;
  lThread: TThread;
  lErrorMessage: string;
begin
  lForm := TForm.Create(nil);
  try
    lScintilla := TDScintilla.Create(lForm);
    try
      lScintilla.Parent := lForm;
      lDone := TEvent.Create(nil, True, False, '');
      try
        lThread := TThread.CreateAnonymousThread(
          procedure
          begin
            try
              lScintilla.SendEditor(SCI_GETTEXTLENGTH, 0, 0);
            except
              on E: Exception do
                lErrorMessage := E.Message;
            end;
            lDone.SetEvent;
          end
        );
        try
          lThread.FreeOnTerminate := False;
          lThread.Start;
          if not WaitForEventWithMessagePump(lDone, 5000) then
            Fail('Worker thread did not finish the first-call test');
          lThread.WaitFor;
        finally
          lThread.Free;
        end;
      finally
        lDone.Free;
      end;

      Check(Pos('owner thread', LowerCase(lErrorMessage)) > 0,
        'First cross-thread call without a handle should fail with an owner-thread contract error');
      Check(not lScintilla.HandleAllocated, 'Failed cross-thread access must not create the handle');
    finally
      lScintilla.Free;
    end;
  finally
    lForm.Free;
  end;
end;

procedure TTestDScintillaTyped.TestCrossThreadSendEditorUsesMessageFallback;
const
  SampleText = 'cross-thread smoke';
var
  lDone: TEvent;
  lThread: TThread;
  lResult: NativeInt;
  lErrorMessage: string;
begin
  FScintilla.SetText(SampleText);
  lDone := TEvent.Create(nil, True, False, '');
  try
    lThread := TThread.CreateAnonymousThread(
      procedure
      begin
        try
          lResult := FScintilla.SendEditor(SCI_GETTEXTLENGTH, 0, 0);
        except
          on E: Exception do
            lErrorMessage := E.ClassName + ': ' + E.Message;
        end;
        lDone.SetEvent;
      end
    );
    try
      lThread.FreeOnTerminate := False;
      lThread.Start;
      if not WaitForEventWithMessagePump(lDone, 5000) then
        Fail('Worker thread did not complete cross-thread SendEditor');
      lThread.WaitFor;
    finally
      lThread.Free;
    end;
  finally
    lDone.Free;
  end;

  CheckEquals('', lErrorMessage);
  CheckEquals(Length(SampleText), Integer(lResult));
end;

procedure TTestDScintillaTyped.TestPostEditorQueuesNoResultCommand;
var
  lDone: TEvent;
  lThread: TThread;
  lPosted: Boolean;
  lStartTick: Cardinal;
begin
  FScintilla.Zoom := 0;

  lDone := TEvent.Create(nil, True, False, '');
  try
    lThread := TThread.CreateAnonymousThread(
      procedure
      begin
        lPosted := FScintilla.PostEditor(SCI_SETZOOM, 3, 0);
        lDone.SetEvent;
      end
    );
    try
      lThread.FreeOnTerminate := False;
      lThread.Start;
      if not WaitForEventWithMessagePump(lDone, 5000) then
        Fail('Worker thread did not return from PostEditor');
      lThread.WaitFor;
    finally
      lThread.Free;
    end;
  finally
    lDone.Free;
  end;

  Check(lPosted, 'PostEditor should succeed for an allocated editor handle');

  lStartTick := GetTickCount;
  repeat
    Application.ProcessMessages;
    if FScintilla.Zoom = 3 then
      Break;
    Sleep(1);
  until GetTickCount - lStartTick >= 5000;

  CheckEquals(3, FScintilla.Zoom);
end;

procedure TTestDScintillaTyped.TestDllModuleReload;
var
  lDllPath: string;
begin
  lDllPath := ResolveSharedDllPath(FScintilla);
  Check(FileExists(lDllPath), 'Scintilla DLL must be next to the test runner');

  FScintilla.DllModule := lDllPath;
  FScintilla.HandleNeeded;

  FScintilla.SetText('dll reload smoke');
  CheckEquals('dll reload smoke', FScintilla.GetText);
  CheckEquals(lDllPath, FScintilla.DllModule);
end;

procedure TTestDScintillaTyped.TestLexerLanguagePublicApi;
var
  lDllPath: string;
  lPropInfo: PPropInfo;
begin
  lDllPath := ResolveSharedDllPath(FScintilla);
  Check(FileExists(lDllPath), 'Scintilla DLL must be next to the test runner');

  FScintilla.DllModule := lDllPath;
  FScintilla.LoadLexerLibrary(lDllPath);

  lPropInfo := GetPropInfo(FScintilla.ClassInfo, 'LexerLanguage');
  Check(lPropInfo <> nil, 'LexerLanguage property must be published');
  Check(lPropInfo^.SetProc <> nil, 'LexerLanguage property must be writable');

  FScintilla.LexerLanguage := 'cpp';
  CheckEquals('cpp', FScintilla.LexerLanguage);
end;

procedure TTestDScintillaTyped.TestFocusNotifications;
begin
  FFocusInCount := 0;
  FFocusOutCount := 0;
  FScintilla.OnFocusIn := HandleFocusIn;
  FScintilla.OnFocusOut := HandleFocusOut;

  Check(TDScintillaAccess(FScintilla).DispatchNotificationForTest(SCN_FOCUSIN));
  Check(TDScintillaAccess(FScintilla).DispatchNotificationForTest(SCN_FOCUSOUT));

  CheckEquals(1, FFocusInCount);
  CheckEquals(1, FFocusOutCount);
end;

procedure TTestDScintillaTyped.TestGeneratedSurfaceHidesUnsafeApi;
var
  lPublicProps: string;
  lMethods: string;
begin
  lPublicProps := TFile.ReadAllText(ResolveSourceFile('source\DScintillaPublicPropertiesDecl.inc'), TEncoding.UTF8);
  lMethods := TFile.ReadAllText(ResolveSourceFile('source\DScintillaMethodsDecl.inc'), TEncoding.UTF8);

  CheckEquals(0, Pos('property DirectFunction:', lPublicProps));
  CheckEquals(0, Pos('property DirectStatusFunction:', lPublicProps));
  CheckEquals(0, Pos('property DirectPointer:', lPublicProps));
  CheckEquals(0, Pos('property DocPointer:', lPublicProps));
  CheckEquals(0, Pos('property CharacterPointer:', lPublicProps));
  CheckEquals(0, Pos('property RangePointer[', lPublicProps));
  CheckEquals(0, Pos('property ILexer:', lPublicProps));
  CheckEquals(0, Pos('function CreateDocument', lMethods));
  CheckEquals(0, Pos('procedure AddRefDocument', lMethods));
  CheckEquals(0, Pos('procedure ReleaseDocument', lMethods));
  CheckEquals(0, Pos('function CreateLoader', lMethods));
end;

procedure TTestDScintillaTyped.TestGeneratedPropertiesIncludeXmlDocumentation;
var
  lPublicProps: string;
  lPublishedProps: string;
begin
  lPublicProps := TFile.ReadAllText(ResolveSourceFile('source\DScintillaPublicPropertiesDecl.inc'), TEncoding.UTF8);
  lPublishedProps := TFile.ReadAllText(ResolveSourceFile('source\DScintillaPublishedPropertiesDecl.inc'), TEncoding.UTF8);

  Check(Pos('property MarginSensitiveN', lPublicProps) > 0, 'Expected public property sample was not generated');
  Check(Pos('/// <summary>Retrieve the mouse click sensitivity of a margin.</summary>', lPublicProps) > 0,
    'Public generated properties should keep XML documentation');
  Check(Pos('property ReadOnly', lPublishedProps) > 0, 'Expected published property sample was not generated');
  Check(Pos('/// <summary>In read-only mode?</summary>', lPublishedProps) > 0,
    'Published generated properties should keep XML documentation');
end;

procedure TTestDScintillaTyped.TestGeneratedPublicPropertiesKeepSparseSetterPairs;
var
  lPublicProps: string;
  lPublishedProps: string;
begin
  lPublicProps := TFile.ReadAllText(
    ResolveSourceFile('source\DScintillaPublicPropertiesDecl.inc'),
    TEncoding.UTF8);
  lPublishedProps := TFile.ReadAllText(
    ResolveSourceFile('source\DScintillaPublishedPropertiesDecl.inc'),
    TEncoding.UTF8);

  Check(Pos('property MarginLeft: Integer read GetMarginLeft write SetMarginLeft default 1;', lPublishedProps) > 0,
    'Sparse setter signatures like SetMarginLeft(, value) should still generate a full read/write property');
  Check(Pos('property MarginRight: Integer read GetMarginRight write SetMarginRight default 1;', lPublishedProps) > 0,
    'Sparse setter signatures like SetMarginRight(, value) should still generate a full read/write property');
  CheckEquals(0, Pos('property MarginLeft:', lPublicProps),
    'MarginLeft should not degrade into a read-only public property when the setter uses a sparse iface signature');
  CheckEquals(0, Pos('property MarginRight:', lPublicProps),
    'MarginRight should not degrade into a read-only public property when the setter uses a sparse iface signature');
end;

procedure TTestDScintillaTyped.TestLexillaRawExportCall;
type
  TGetNameSpaceProc = function: PAnsiChar; stdcall;
var
  lDllPath: string;
  lHandle: HMODULE;
  lProc: TGetNameSpaceProc;
  lPtr: PAnsiChar;
begin
  lDllPath := ResolveSharedDllPath(FScintilla);
  lHandle := SafeLoadLibrary(lDllPath);
  if lHandle = 0 then
    RaiseLastOSError;
  try
    @lProc := GetProcAddress(lHandle, 'GetNameSpace');
    Check(Assigned(lProc), 'GetNameSpace export missing');

    lPtr := lProc();
    Check(lPtr <> nil, 'GetNameSpace should return a valid ANSI pointer');
    CheckEquals('lexilla', string(UTF8String(AnsiString(lPtr))));
  finally
    FreeLibrary(lHandle);
  end;
end;

procedure TTestDScintillaTyped.TestLexillaStringApiUsesSharedDll;
var
  lDllPath: string;
  lLexilla: TDLexilla;
  lLexerName: UnicodeString;
  lStep: string;
begin
  try
    lStep := 'resolve shared dll path';
    lDllPath := ResolveSharedDllPath(FScintilla);

    lStep := 'switch scintilla dll module';
    FScintilla.DllModule := lDllPath;

    lStep := 'get lexilla bridge';
    lLexilla := FScintilla.Lexilla;
    CheckEquals(lDllPath, lLexilla.DllModule);

    lStep := 'get namespace';
    CheckEquals('lexilla', lLexilla.GetNameSpace);

    lStep := 'get library property names';
    CheckEquals('', lLexilla.GetLibraryPropertyNames);

    lStep := 'get lexer count';
    Check(lLexilla.GetLexerCount > 0);

    lStep := 'get lexer name';
    lLexerName := lLexilla.GetLexerName(0);
    Check(lLexerName <> '');

    lStep := 'lookup deprecated lexer name';
    CheckEquals('', lLexilla.LexerNameFromID(-1));

    lStep := 'set library property';
    lLexilla.SetLibraryProperty('definitions.directory', '');
  except
    on E: Exception do
      raise Exception.CreateFmt('%s failed: %s - %s', [lStep, E.ClassName, E.Message]);
  end;
end;

procedure TTestDScintillaTyped.TestSettingsResolveLanguageByExtension;
var
  lConfigFileName: string;
begin
  lConfigFileName := TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml');
  Check(FileExists(lConfigFileName), 'DScintilla.config.xml must exist');

  FScintilla.Settings.LoadConfigFile(lConfigFileName);
  CheckEquals('cpp', FScintilla.Settings.ResolveLanguageNameByFileName('sample.cpp'));

  FScintilla.Settings.ApplyLanguageForFileName('sample.cpp');
  CheckEquals('cpp', FScintilla.Settings.CurrentLanguage);
end;

procedure TTestDScintillaTyped.TestSettingsConfigFileActivatesLexerForNamedLanguage;
begin
  FScintilla.Settings.LoadConfigFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
  FScintilla.Settings.ApplyLanguage('cpp');
  FScintilla.SetText('int value = 0;');
  FScintilla.Colourise(0, -1);

  CheckEquals('cpp', FScintilla.LexerLanguage);
  CheckEquals(16, FScintilla.StyleAt[0],
    'Config-backed language activation should still initialize the lexer');
end;

procedure TTestDScintillaTyped.TestSettingsLegacyImportApisRaiseNotSupported;
var
  lLanguagesFileName: string;
  lSettingsDir: string;
  lStylersFileName: string;
begin
  lSettingsDir := ResolveSettingsDir;
  lStylersFileName := TPath.Combine(lSettingsDir, 'stylers.model.xml');
  lLanguagesFileName := TPath.Combine(lSettingsDir, 'langs.model.xml');

  try
    FScintilla.Settings.LoadSettingsDirectory(lSettingsDir);
    Fail('LoadSettingsDirectory should reject legacy settings directories at runtime');
  except
    on E: ENotSupportedException do
      Check(Pos('SciConfGen', E.Message) > 0,
        'Legacy import errors should direct callers to SciConfGen');
  end;

  try
    FScintilla.Settings.LoadStylersModel(lStylersFileName);
    Fail('LoadStylersModel should reject legacy styler imports at runtime');
  except
    on E: ENotSupportedException do
      Check(Pos('SciConfGen', E.Message) > 0,
        'Legacy import errors should direct callers to SciConfGen');
  end;

  try
    FScintilla.Settings.LoadLanguagesModel(lLanguagesFileName);
    Fail('LoadLanguagesModel should reject legacy language imports at runtime');
  except
    on E: ENotSupportedException do
      Check(Pos('SciConfGen', E.Message) > 0,
        'Legacy import errors should direct callers to SciConfGen');
  end;

  try
    FScintilla.Settings.ResolveThemeFile('Monokai');
    Fail('ResolveThemeFile should reject legacy theme lookups at runtime');
  except
    on E: ENotSupportedException do
      Check(Pos('SciConfGen', E.Message) > 0,
        'Legacy import errors should direct callers to SciConfGen');
  end;

  try
    FScintilla.Settings.LoadTheme('Monokai');
    Fail('LoadTheme should reject legacy theme imports at runtime');
  except
    on E: ENotSupportedException do
      Check(Pos('SciConfGen', E.Message) > 0,
        'Legacy import errors should direct callers to SciConfGen');
  end;
end;

procedure TTestDScintillaTyped.TestSettingsConfigSurvivesRecreateWnd;
begin
  FScintilla.Settings.LoadConfigFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
  FScintilla.Settings.ApplyLanguage('cpp');

  FScintilla.Perform(CM_RECREATEWND, 0, 0);
  FScintilla.HandleNeeded;

  CheckEquals('cpp', FScintilla.Settings.CurrentLanguage);
  CheckEquals(Integer(TColor(RGB($FF, $FF, $FA))), Integer(FScintilla.StyleFore[STYLE_DEFAULT]));
  CheckEquals(Integer(TColor(RGB($17, $20, $24))), Integer(FScintilla.StyleBack[STYLE_DEFAULT]));
end;

procedure TTestDScintillaTyped.TestSettingsClearLanguageResetsLexerState;
begin
  FScintilla.Settings.LoadConfigFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
  FScintilla.Settings.ApplyLanguage('cpp');
  FScintilla.SetText('int value = 0;');
  FScintilla.Colourise(0, -1);
  CheckEquals('cpp', FScintilla.LexerLanguage);
  CheckEquals(16, FScintilla.StyleAt[0]);

  FScintilla.Settings.ApplyLanguage('');

  CheckEquals('', FScintilla.Settings.CurrentLanguage);
  CheckEquals('', FScintilla.LexerLanguage);
  Check(FScintilla.StyleAt[0] <> 16, 'Clearing language should drop lexer styling');
end;

procedure TTestDScintillaTyped.TestSettingsConfigFileAppliesEditorOptions;
var
  lConfigFileName: string;
begin
  lConfigFileName := TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml');
  Check(FileExists(lConfigFileName), 'DScintilla.config.xml must exist');

  FScintilla.Settings.LoadConfigFile(lConfigFileName);

  CheckEquals(4, FScintilla.TabWidth);
  CheckEquals(Ord(scwWORD), Ord(FScintilla.WrapMode));
  CheckEquals(Ord(scmtNUMBER), Ord(FScintilla.MarginTypeN[0]));
  Check(FScintilla.MarginWidthN[0] > 0,
    'LoadConfigFile should enable a visible line-number margin without extra host code');

  CheckEquals(Ord(scisROUND_BOX), Ord(FScintilla.IndicGetStyle(0)));
  CheckEquals(Ord(scisSTRAIGHT_BOX), Ord(FScintilla.IndicGetStyle(1)));
  CheckEquals(Integer(TColor(RGB($00, $FF, $00))), Integer(FScintilla.IndicGetFore(0)));
  CheckEquals(Integer(TColor(RGB($00, $FF, $00))), Integer(FScintilla.IndicGetFore(1)));
  Check(not FScintilla.IndicGetUnder(0), 'Search indicator should draw over the text');
  Check(FScintilla.IndicGetUnder(1), 'Occurrence indicator should draw under the text');
  CheckEquals($60, Integer(FScintilla.IndicGetAlphaValue(0)),
    'Search indicator fill alpha should come from config');
  CheckEquals($FF, Integer(FScintilla.IndicGetOutlineAlphaValue(0)),
    'Search indicator outline alpha should come from config');
  CheckEquals($60, Integer(FScintilla.IndicGetAlphaValue(1)),
    'Smart highlight fill alpha should preserve the raw extSettings value');
  CheckEquals($FF, Integer(FScintilla.IndicGetOutlineAlphaValue(1)),
    'Smart highlight outline alpha should preserve the raw extSettings value');
  CheckEquals(256, Integer(FScintilla.SendEditor(SCI_GETSELALPHA, 0, 0)),
    'Selection alpha should preserve the config integer value');
  CheckEquals(256, Integer(FScintilla.SendEditor(SCI_GETADDITIONALSELALPHA, 0, 0)),
    'Additional selection alpha should track the same config value');
end;

procedure TTestDScintillaTyped.TestSettingsConfigFileCompatibility;
const
  SampleText = 'int value = 0; return value;';
var
  lConfigFileName: string;
begin
  lConfigFileName := TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml');
  Check(FileExists(lConfigFileName), 'DScintilla.config.xml must exist');

  FScintilla.Settings.LoadConfigFile(lConfigFileName);
  CheckEquals(lConfigFileName, FScintilla.Settings.ConfigFileName);
  CheckEquals('cpp', FScintilla.Settings.ResolveLanguageNameByFileName('sample.cpp'));

  FScintilla.Settings.ApplyLanguageForFileName('sample.cpp');
  CheckEquals('cpp', FScintilla.Settings.CurrentLanguage);
  CheckEquals(Integer(TColor(RGB($FF, $FF, $FA))), Integer(FScintilla.StyleFore[STYLE_DEFAULT]));
  CheckEquals(Integer(TColor(RGB($17, $20, $24))), Integer(FScintilla.StyleBack[STYLE_DEFAULT]));

  FScintilla.SetText(SampleText);
  FScintilla.Colourise(0, -1);
  CheckEquals(16, FScintilla.StyleAt[0], 'Config-backed settings should activate the lexer');
end;

procedure TTestDScintillaTyped.TestSettingsConfigFileLoadFailureKeepsPreviousConfig;
var
  lConfigFileName: string;
  lInvalidConfigFileName: string;
  lOriginalConfigFileName: string;
begin
  lConfigFileName := TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml');
  Check(FileExists(lConfigFileName), 'DScintilla.config.xml must exist');

  FScintilla.Settings.LoadConfigFile(lConfigFileName);
  FScintilla.Settings.ApplyLanguageForFileName('sample.cpp');
  lOriginalConfigFileName := FScintilla.Settings.ConfigFileName;

  lInvalidConfigFileName := TPath.Combine(CreateWritableTempDir,
    Format('dsci-invalid-config-%d-%d.xml', [GetCurrentProcessId, GetTickCount]));
  TFile.WriteAllText(lInvalidConfigFileName, '<Config><Styles><Broken></Config>', TEncoding.UTF8);
  try
    try
      FScintilla.Settings.LoadConfigFile(lInvalidConfigFileName);
      Fail('Invalid config XML must raise an exception');
    except
      on E: Exception do
        Check(E.Message <> '', 'Exception message must be preserved for invalid config XML');
    end;

    CheckEquals(lOriginalConfigFileName, FScintilla.Settings.ConfigFileName);
    CheckEquals('cpp', FScintilla.Settings.ResolveLanguageNameByFileName('sample.cpp'));
    CheckEquals(Integer(TColor(RGB($FF, $FF, $FA))), Integer(FScintilla.StyleFore[STYLE_DEFAULT]));
    CheckEquals(Integer(TColor(RGB($17, $20, $24))), Integer(FScintilla.StyleBack[STYLE_DEFAULT]));
  finally
    if FileExists(lInvalidConfigFileName) then
      SysUtils.DeleteFile(lInvalidConfigFileName);
  end;
end;

procedure TTestDScintillaTyped.TestSettingsMissingConfigFileCreatesEmbeddedDefault;
var
  lConfigFileName: string;
  lTempDirectory: string;
begin
  lTempDirectory := CreateWritableTempDir;
  try
    lConfigFileName := TPath.Combine(lTempDirectory, 'user-defined.config.xml');
    Check(not FileExists(lConfigFileName), 'Test precondition: config file should not exist yet');

    FScintilla.Settings.LoadConfigFile(lConfigFileName);

    Check(FileExists(lConfigFileName),
      'LoadConfigFile should create a missing config from embedded defaults');
    CheckEquals(ExpandFileName(lConfigFileName), FScintilla.Settings.ConfigFileName);
    CheckEquals(4, FScintilla.TabWidth);
    CheckEquals('cpp', FScintilla.Settings.ResolveLanguageNameByFileName('sample.cpp'));
    CheckEquals(Integer(TColor(RGB($17, $20, $24))), Integer(FScintilla.StyleBack[STYLE_DEFAULT]));
  finally
    if DirectoryExists(lTempDirectory) then
      TDirectory.Delete(lTempDirectory, True);
  end;
end;

procedure TTestDScintillaTyped.TestSettingsUnknownExtensionFallsBackToDefault;
begin
  FScintilla.Settings.LoadConfigFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));
  FScintilla.Settings.ApplyLanguage('cpp');
  CheckEquals('cpp', FScintilla.Settings.CurrentLanguage);

  try
    FScintilla.Settings.ApplyLanguageForFileName('book.fb2');
  except
    on E: Exception do
      Fail(Format(
        'Unknown file extensions should fall back to the default/plain lexer instead of raising: %s - %s',
        [E.ClassName, E.Message]));
  end;

  CheckEquals('', FScintilla.Settings.CurrentLanguage,
    'Unknown file extensions should clear the active language and use the default/plain lexer');
  CheckEquals('', FScintilla.LexerLanguage,
    'Unknown file extensions should leave the editor on the default/plain lexer');
end;

procedure TTestDScintillaTyped.TestSettingsConfigFilePersistsAndAppliesRenderingOptions;
var
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lReloadedConfig: TDSciVisualConfig;
  lTempDirectory: string;
begin
  lTempDirectory := CreateWritableTempDir;
  try
    lConfigFileName := TPath.Combine(lTempDirectory, 'rendering.config.xml');
    TFile.Copy(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'),
      lConfigFileName, True);

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(lConfigFileName);
      lConfig.Technology := sctDIRECT_WRITE_RETAIN;
      lConfig.FontLocale := 'en-US';
      lConfig.FontQuality := scfqQUALITY_ANTIALIASED;
      lConfig.SaveToFile(lConfigFileName);
    finally
      lConfig.Free;
    end;

    lReloadedConfig := TDSciVisualConfig.Create;
    try
      lReloadedConfig.LoadFromFile(lConfigFileName);
      CheckEquals(Ord(sctDIRECT_WRITE_RETAIN), Ord(lReloadedConfig.Technology));
      CheckEquals('en-US', lReloadedConfig.FontLocale);
      CheckEquals(Ord(scfqQUALITY_ANTIALIASED), Ord(lReloadedConfig.FontQuality));
    finally
      lReloadedConfig.Free;
    end;

    FScintilla.Settings.LoadConfigFile(lConfigFileName);
    CheckEquals(Ord(sctDIRECT_WRITE_RETAIN), Ord(FScintilla.Technology));
    CheckEquals(Ord(scfqQUALITY_ANTIALIASED), Ord(FScintilla.FontQuality));
    CheckEquals('en-US', FScintilla.FontLocale);
  finally
    if DirectoryExists(lTempDirectory) then
      TDirectory.Delete(lTempDirectory, True);
  end;
end;

procedure TTestDScintillaTyped.TestSettingsUnavailableHtmlLexerFallsBackToDefault;
var
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lHtmlGroup: TDSciVisualStyleGroup;
  lMissingGroup: TDSciVisualStyleGroup;
  lTempDirectory: string;
begin
  lTempDirectory := CreateWritableTempDir;
  try
    lConfigFileName := TPath.Combine(lTempDirectory, 'missing-html-lexer.config.xml');

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.LoadFromFile(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'));

      lHtmlGroup := lConfig.StyleOverrides.FindGroup('html');
      if lHtmlGroup <> nil then
        lHtmlGroup.Extensions := '.html-disabled';

      lMissingGroup := lConfig.StyleOverrides.EnsureGroup('html_missing_test');
      lMissingGroup.Extensions := '.html';
      lConfig.SaveToFile(lConfigFileName);
    finally
      lConfig.Free;
    end;

    FScintilla.Settings.LoadConfigFile(lConfigFileName);
    FScintilla.SetText('<html><body>fallback</body></html>');
    FScintilla.Colourise(0, -1);

    try
      FScintilla.Settings.ApplyLanguageForFileName('sample.html');
    except
      on E: Exception do
        Fail(Format(
          'Unavailable HTML lexer should fall back to the default lexer instead of raising: %s - %s',
          [E.ClassName, E.Message]));
    end;

    CheckEquals('', FScintilla.Settings.CurrentLanguage,
      'Settings should clear CurrentLanguage after falling back from an unavailable HTML lexer');
    CheckEquals('', FScintilla.LexerLanguage,
      'Fallback from an unavailable HTML lexer should leave the editor on the default/plain lexer');
    Check(FScintilla.StyleAt[0] <> 16,
      'Fallback to the default/plain lexer should not leave HTML lexer styling behind');
  finally
    if DirectoryExists(lTempDirectory) then
      TDirectory.Delete(lTempDirectory, True);
  end;
end;

procedure TTestDScintillaTyped.TestSettingsConfigAutoCompletionLoadsFromAdjacentFolder;
const
  AutoCompleteXml =
    '<?xml version="1.0" encoding="UTF-8"?>' + sLineBreak +
    '<NotepadPlus>' + sLineBreak +
    '  <AutoComplete language="C++">' + sLineBreak +
    '    <Environment ignoreCase="no" startFunc="(" stopFunc=")" paramSeparator="," terminal=";" additionalWordChar="" />' + sLineBreak +
    '    <KeyWord name="printf" func="yes">' + sLineBreak +
    '      <Overload retVal="int">' + sLineBreak +
    '        <Param name="const char *format" />' + sLineBreak +
    '      </Overload>' + sLineBreak +
    '    </KeyWord>' + sLineBreak +
    '  </AutoComplete>' + sLineBreak +
    '</NotepadPlus>';
var
  lAccess: TDScintillaAccess;
  lAutoCompleteDirectory: string;
  lConfigFileName: string;
  lTempDirectory: string;
begin
  lTempDirectory := CreateWritableTempDir;
  try
    lConfigFileName := TPath.Combine(lTempDirectory, 'DScintilla.config.xml');
    TFile.Copy(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'),
      lConfigFileName, True);

    lAutoCompleteDirectory := TPath.Combine(lTempDirectory, 'autoCompletion');
    ForceDirectories(lAutoCompleteDirectory);
    TFile.WriteAllText(TPath.Combine(lAutoCompleteDirectory, 'cpp.xml'),
      AutoCompleteXml, TEncoding.UTF8);

    FScintilla.Settings.LoadConfigFile(lConfigFileName);
    FScintilla.Settings.ApplyLanguage('cpp');

    FScintilla.SetText('printf');
    FScintilla.CurrentPos := 3;
    FScintilla.Anchor := 3;

    lAccess := TDScintillaAccess(FScintilla);
    Check(lAccess.DispatchCharAddedForTest(Ord('i')),
      'SCN_CHARADDED should remain handled after config-backed autocomplete loads');
    Check(FScintilla.AutoCActive,
      'Typing a configured prefix should open Scintilla autocomplete');
    CheckEquals('printf', FScintilla.AutoCGetCurrentText);
  finally
    if DirectoryExists(lTempDirectory) then
      TDirectory.Delete(lTempDirectory, True);
  end;
end;

procedure TTestDScintillaTyped.TestSettingsConfigFunctionListShowsCallTipFromAdjacentFolder;
const
  SampleText =
    'int add(int a, int b) {' + sLineBreak +
    '  return a + b;' + sLineBreak +
    '}' + sLineBreak + sLineBreak +
    'add(';
var
  lAccess: TDScintillaAccess;
  lConfigFileName: string;
  lFunctionListDirectory: string;
  lTempDirectory: string;
begin
  lTempDirectory := CreateWritableTempDir;
  try
    lConfigFileName := TPath.Combine(lTempDirectory, 'DScintilla.config.xml');
    TFile.Copy(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'),
      lConfigFileName, True);

    lFunctionListDirectory := TPath.Combine(lTempDirectory, 'functionList');
    ForceDirectories(lFunctionListDirectory);
    TFile.Copy(TPath.Combine(ResolveSettingsDir, 'functionList\cpp.xml'),
      TPath.Combine(lFunctionListDirectory, 'cpp.xml'), True);

    FScintilla.Settings.LoadConfigFile(lConfigFileName);
    FScintilla.Settings.ApplyLanguage('cpp');
    FScintilla.SetText(SampleText);
    FScintilla.CurrentPos := FScintilla.TextLength;
    FScintilla.Anchor := FScintilla.CurrentPos;

    lAccess := TDScintillaAccess(FScintilla);
    Check(lAccess.DispatchModifiedForTest,
      'SCN_MODIFIED should keep document-function cache in sync');
    Check(lAccess.DispatchCharAddedForTest(Ord('(')),
      'SCN_CHARADDED should drive call tips for functionList-backed functions');
    Check(FScintilla.CallTipActive,
      'Typing an opening parenthesis for a discovered document function should show a call tip');
  finally
    if DirectoryExists(lTempDirectory) then
      TDirectory.Delete(lTempDirectory, True);
  end;
end;

procedure TTestDScintillaTyped.TestSettingsRealCppFunctionListExtractsFunctions;
const
  SampleText =
    'int add(int a, int b) {' + sLineBreak +
    '  return a + b;' + sLineBreak +
    '}';
var
  lFoundFunction: TDSciDocumentFunction;
  lFunction: TDSciDocumentFunction;
  lFunctions: TObjectList<TDSciDocumentFunction>;
  lModel: TDSciFunctionListModel;
begin
  lModel := LoadFunctionListModelFromFile(
    TPath.Combine(ResolveSettingsDir, 'functionList\cpp.xml'));
  try
    lFunctions := lModel.ExtractFunctions(SampleText);
    try
      Check(lFunctions.Count > 0,
        'Shipped cpp.xml should extract at least one function from a trivial C++ sample');

      lFoundFunction := nil;
      for lFunction in lFunctions do
        if SameText(lFunction.Name, 'add') then
        begin
          lFoundFunction := lFunction;
          Break;
        end;

      Check(lFoundFunction <> nil,
        'Shipped cpp.xml should extract the function name from a trivial C++ sample');
      CheckEquals('int add(int a, int b)', lFoundFunction.Signature,
        'Function signatures extracted from shipped cpp.xml should be normalized for call tips');
      CheckEquals(0, Pos('{', lFoundFunction.Signature),
        'Normalized function signatures should not include an opening brace');
    finally
      lFunctions.Free;
    end;
  finally
    lModel.Free;
  end;
end;

procedure TTestDScintillaTyped.TestSettingsMalformedSidecarsDoNotAbortConfigApply;
var
  lAutoCompleteDirectory: string;
  lConfigFileName: string;
  lFunctionListDirectory: string;
  lTempDirectory: string;
begin
  lTempDirectory := CreateWritableTempDir;
  try
    lConfigFileName := TPath.Combine(lTempDirectory, 'DScintilla.config.xml');
    TFile.Copy(TPath.Combine(ResolveSettingsDir, 'DScintilla.config.xml'),
      lConfigFileName, True);

    lAutoCompleteDirectory := TPath.Combine(lTempDirectory, 'autoCompletion');
    ForceDirectories(lAutoCompleteDirectory);
    TFile.WriteAllText(TPath.Combine(lAutoCompleteDirectory, 'cpp.xml'),
      '<NotepadPlus><AutoComplete><Broken></NotepadPlus>', TEncoding.UTF8);

    lFunctionListDirectory := TPath.Combine(lTempDirectory, 'functionList');
    ForceDirectories(lFunctionListDirectory);
    TFile.WriteAllText(TPath.Combine(lFunctionListDirectory, 'cpp.xml'),
      '<NotepadPlus><functionList><Broken></NotepadPlus>', TEncoding.UTF8);

    FScintilla.Settings.LoadConfigFile(lConfigFileName);
    FScintilla.Settings.ApplyLanguage('cpp');
    FScintilla.SetText('int value = 0;');
    FScintilla.Colourise(0, -1);

    CheckEquals('cpp', FScintilla.LexerLanguage,
      'Malformed optional sidecars must not stop config-backed language activation');
    CheckEquals(16, FScintilla.StyleAt[0],
      'Malformed optional sidecars must not prevent lexer styling from being applied');
    CheckEquals(Integer(TColor(RGB($17, $20, $24))),
      Integer(FScintilla.StyleBack[STYLE_DEFAULT]),
      'Malformed optional sidecars must not prevent editor config application');
  finally
    if DirectoryExists(lTempDirectory) then
      TDirectory.Delete(lTempDirectory, True);
  end;
end;

procedure TTestDScintillaTyped.TestAssignedPopupMenuCanBeEnabledOrDisabled;
var
  lAccess: TDScintillaAccess;
  lPoint: TPoint;
  lPopupMenu: TPopupMenu;
begin
  lAccess := TDScintillaAccess(FScintilla);
  lPopupMenu := TPopupMenu.Create(nil);
  try
    lPopupMenu.Items.Add(NewItem('Custom', 0, False, True, nil, 0, ''));
    FScintilla.PopupMenu := lPopupMenu;
    FScintilla.UseDefaultContextMenu := False;
    FScintilla.UseAssignedPopupMenu := True;
    FScintilla.Margins := 1;
    FScintilla.MarginWidthN[0] := 24;
    lAccess.ResetContextMenuForTest;

    lPoint := FScintilla.ClientToScreen(Point(40, 10));
    FScintilla.Perform(WM_CONTEXTMENU, FScintilla.Handle, ContextMenuLParam(lPoint));
    CheckEquals(1, lAccess.ContextMenuShowCount,
      'Assigned PopupMenu should open when custom popup support stays enabled');
    Check(lAccess.LastContextMenu = lPopupMenu,
      'TDScintilla should choose the assigned PopupMenu when custom popup support is enabled');

    FScintilla.UseAssignedPopupMenu := False;
    FScintilla.Perform(WM_CONTEXTMENU, FScintilla.Handle, ContextMenuLParam(lPoint));
    CheckEquals(1, lAccess.ContextMenuShowCount,
      'Assigned PopupMenu should stay suppressed when custom popup support is disabled');
  finally
    FScintilla.PopupMenu := nil;
    lPopupMenu.Free;
  end;
end;

procedure TTestDScintillaTyped.TestAssignedPopupMenuStaysHiddenOverMarginArea;
var
  lAccess: TDScintillaAccess;
  lPoint: TPoint;
  lPopupMenu: TPopupMenu;
begin
  lAccess := TDScintillaAccess(FScintilla);
  lPopupMenu := TPopupMenu.Create(nil);
  try
    lPopupMenu.Items.Add(NewItem('Custom', 0, False, True, nil, 0, ''));
    FScintilla.PopupMenu := lPopupMenu;
    FScintilla.UseDefaultContextMenu := False;
    FScintilla.UseAssignedPopupMenu := True;
    FScintilla.Margins := 1;
    FScintilla.MarginWidthN[0] := 24;
    lAccess.ResetContextMenuForTest;

    lPoint := FScintilla.ClientToScreen(Point(8, 10));
    FScintilla.Perform(WM_CONTEXTMENU, FScintilla.Handle, ContextMenuLParam(lPoint));
    CheckEquals(0, lAccess.ContextMenuShowCount,
      'Assigned popup menu should stay hidden when right-click starts inside the margin area');
  finally
    FScintilla.PopupMenu := nil;
    lPopupMenu.Free;
  end;
end;

procedure TTestDScintillaTyped.TestAutoBraceHighlightTracksCaret;
const
  SampleText = 'call(foo)';
var
  lAccess: TDScintillaAccess;
  lOpenPos: NativeInt;
  lClosePos: NativeInt;
begin
  lAccess := TDScintillaAccess(FScintilla);
  FScintilla.SetText(SampleText);

  lOpenPos := Pos('(', SampleText) - 1;
  lClosePos := Pos(')', SampleText) - 1;
  Check(lOpenPos >= 0, 'Sample text should contain an opening brace');
  Check(lClosePos >= 0, 'Sample text should contain a closing brace');

  lAccess.ResetBraceHighlightForTest;
  FScintilla.CurrentPos := lOpenPos;
  FScintilla.Anchor := lOpenPos;
  Check(lAccess.DispatchNotificationForTest(SCN_UPDATEUI),
    'SCN_UPDATEUI should be handled by TDScintilla');
  CheckEquals(lOpenPos, lAccess.LastBraceHighlightPos,
    'Auto brace highlighting should track the brace at the caret');
  CheckEquals(lClosePos, lAccess.LastBraceMatchPos,
    'Auto brace highlighting should resolve the matching brace');

  FScintilla.AutoBraceHighlight := False;
  lAccess.ResetBraceHighlightForTest;
  lAccess.DispatchNotificationForTest(SCN_UPDATEUI);
  CheckEquals(INVALID_POSITION, lAccess.LastBraceHighlightPos,
    'Disabling AutoBraceHighlight should clear automatic brace highlighting');
  CheckEquals(INVALID_POSITION, lAccess.LastBraceMatchPos,
    'Disabling AutoBraceHighlight should stop calculating brace matches');
end;

procedure TTestDScintillaTyped.TestDefaultTechnologyUsesDirectWriteRetain;
begin
  CheckEquals(Ord(sctDIRECT_WRITE_RETAIN), Ord(FScintilla.DefaultTechnology),
    'DirectWrite retain should be the default rendering technology');
  CheckEquals(Ord(sctDIRECT_WRITE_RETAIN), Ord(FScintilla.Technology),
    'The live editor should initialize with DirectWrite retain technology');
end;

procedure TTestDScintillaTyped.TestBeginLoadFromFileReportsProgressAndCompletes;
var
  lContent: string;
  lFileName: string;
  lRecorder: TFileLoadRecorder;
  lStartTick: Cardinal;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  lRecorder := TFileLoadRecorder.Create;
  try
    lFileName := TPath.Combine(lTempDir, 'async-load.txt');
    lContent := StringOfChar('A', 256 * 1024) + sLineBreak +
      StringOfChar('B', 256 * 1024);
    TFile.WriteAllText(lFileName, lContent, TEncoding.UTF8);

    FScintilla.OnFileLoadStateChange := lRecorder.HandleFileLoadState;
    Check(FScintilla.BeginLoadFromFile(lFileName),
      'BeginLoadFromFile should start asynchronous document loading');

    lStartTick := GetTickCount;
    while not (FScintilla.FileLoadStatus.Stage in [sflsCompleted, sflsFailed, sflsCancelled]) and
      (GetTickCount - lStartTick < 10000) do
    begin
      Application.ProcessMessages;
      Sleep(5);
    end;

    CheckEquals(Ord(sflsCompleted), Ord(FScintilla.FileLoadStatus.Stage),
      'Asynchronous file loading should complete successfully');
    CheckEquals(lContent, FScintilla.GetText,
      'Asynchronous file loading should preserve the decoded document text');
    Check(lRecorder.HasStage(sflsPreparing),
      'Async file loading should report the preparing stage');
    Check(lRecorder.HasStage(sflsReading),
      'Async file loading should report file-read progress');
    Check(lRecorder.HasStage(sflsLoading),
      'Async file loading should report loader population progress');
    Check(lRecorder.HasStage(sflsCompleted),
      'Async file loading should publish a completed state');
    Check(not FScintilla.IsFileLoading,
      'IsFileLoading should reset after asynchronous completion');
  finally
    lRecorder.Free;
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDScintillaTyped.TestCopyWithFormattingPlacesCfHtmlOnClipboard;
var
  lAccess: TDScintillaAccess;
  lHtml: UTF8String;
  lMenuItem: TMenuItem;
  lPlainText: string;
  lPoint: TPoint;
begin
  Check(TrySetClipboardText(''),
    'Test precondition failed: clipboard should be writable for CF_HTML checks');

  lAccess := TDScintillaAccess(FScintilla);
  FScintilla.StyleFore[STYLE_DEFAULT] := TColor(RGB($12, $34, $56));
  FScintilla.StyleBack[STYLE_DEFAULT] := TColor(RGB($F8, $F0, $E8));
  FScintilla.StyleFont[STYLE_DEFAULT] := 'Consolas';
  FScintilla.StyleSize[STYLE_DEFAULT] := 11;
  FScintilla.StyleClearAll;
  FScintilla.SetText('alpha beta');
  FScintilla.SetSel(0, 5);
  FScintilla.UseAssignedPopupMenu := False;
  FScintilla.UseDefaultContextMenu := True;
  lAccess.ResetContextMenuForTest;

  lPoint := FScintilla.ClientToScreen(Point(40, 10));
  FScintilla.Perform(WM_CONTEXTMENU, FScintilla.Handle, ContextMenuLParam(lPoint));
  lMenuItem := FindMenuItemByCaption(lAccess.LastContextMenu, 'Copy with formatting');
  Check(lMenuItem <> nil,
    'Default context menu should expose a "Copy with formatting" item');
  Check(lMenuItem.Enabled,
    '"Copy with formatting" should be enabled for a non-empty selection');

  lMenuItem.Click;
  Check(TryGetClipboardText(lPlainText),
    'Clipboard text should remain readable after HTML copy');
  CheckEquals('alpha', lPlainText,
    'Copy with formatting should also publish the plain selected text');

  Check(TryGetClipboardHtml(lHtml),
    'Copy with formatting should publish HTML Format clipboard data');
  Check(Pos('StartHTML:', string(lHtml)) > 0,
    'CF_HTML payload should include the standard StartHTML header');
  Check(Pos('<!--StartFragment-->', string(lHtml)) > 0,
    'CF_HTML payload should include the StartFragment marker');
  Check(Pos('<span style="color:#123456;', string(lHtml)) > 0,
    'CF_HTML payload should preserve the foreground color of the current style');
  Check(Pos('font-family:''Consolas'';', string(lHtml)) > 0,
    'CF_HTML payload should preserve the style font family');
  Check(Pos('alpha', string(lHtml)) > 0,
    'CF_HTML payload should contain the selected text fragment');
end;

procedure TTestDScintillaTyped.TestKeyboardContextMenuUsesCaretLocation;
var
  lAccess: TDScintillaAccess;
  lExpectedPoint: TPoint;
  lPopupMenu: TPopupMenu;
begin
  lAccess := TDScintillaAccess(FScintilla);
  lPopupMenu := TPopupMenu.Create(nil);
  try
    lPopupMenu.Items.Add(NewItem('Custom', 0, False, True, nil, 0, ''));
    FScintilla.PopupMenu := lPopupMenu;
    FScintilla.UseDefaultContextMenu := False;
    FScintilla.UseAssignedPopupMenu := True;
    FScintilla.Margins := 1;
    FScintilla.MarginWidthN[0] := 24;
    FScintilla.SetText('alpha');
    FScintilla.CurrentPos := 3;
    FScintilla.Anchor := 3;
    lAccess.ResetContextMenuForTest;

    FScintilla.Perform(WM_CONTEXTMENU, FScintilla.Handle, LPARAM(-1));
    CheckEquals(1, lAccess.ContextMenuShowCount,
      'Keyboard context menu should still open on the text area');

    lExpectedPoint := FScintilla.ClientToScreen(Point(
      FScintilla.PointXFromPosition(FScintilla.CurrentPos),
      FScintilla.PointYFromPosition(FScintilla.CurrentPos) +
        (FScintilla.TextHeight(FScintilla.LineFromPosition(FScintilla.CurrentPos)) div 2)));
    CheckEquals(lExpectedPoint.X, lAccess.LastContextMenuPoint.X,
      'Keyboard context menu should anchor to the caret X position');
    CheckEquals(lExpectedPoint.Y, lAccess.LastContextMenuPoint.Y,
      'Keyboard context menu should anchor to the caret Y position');
  finally
    FScintilla.PopupMenu := nil;
    lPopupMenu.Free;
  end;
end;

procedure TTestDScintillaTyped.TestLoadFromFileLoadsTextSynchronously;
var
  lContent: string;
  lFileName: string;
  lRecorder: TFileLoadRecorder;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  lRecorder := TFileLoadRecorder.Create;
  try
    lFileName := TPath.Combine(lTempDir, 'sync-load.txt');
    lContent := 'line one' + sLineBreak + 'line two';
    TFile.WriteAllText(lFileName, lContent, TEncoding.UTF8);

    FScintilla.OnFileLoadStateChange := lRecorder.HandleFileLoadState;
    Check(FScintilla.LoadFromFile(lFileName),
      'LoadFromFile should keep a synchronous loading API');
    CheckEquals(lContent, FScintilla.GetText,
      'Synchronous file loading should preserve the decoded document text');
    Check(lRecorder.HasStage(sflsReading),
      'Synchronous file loading should report file-read progress');
    Check(lRecorder.HasStage(sflsLoading),
      'Synchronous file loading should report loader population progress');
    Check(lRecorder.HasStage(sflsCompleted),
      'Synchronous file loading should publish a completed state');
    CheckEquals(Ord(sflsCompleted), Ord(FScintilla.FileLoadStatus.Stage),
      'Synchronous file loading should finish in the completed state');
  finally
    lRecorder.Free;
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDScintillaTyped.TestLoadFromFileEnablesUndoAfterEdit;
var
  lContent: string;
  lFileName: string;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  try
    lFileName := TPath.Combine(lTempDir, 'undo-sync.txt');
    lContent := 'original content';
    TFile.WriteAllText(lFileName, lContent, TEncoding.UTF8);

    Check(FScintilla.LoadFromFile(lFileName),
      'LoadFromFile should succeed');
    Check(FScintilla.UndoCollection,
      'UndoCollection must be True after LoadFromFile so user edits can be undone');
    Check(not FScintilla.CanUndo,
      'CanUndo should be False immediately after loading (clean state)');

    FScintilla.InsertText(0, 'EDIT: ');
    Check(FScintilla.CanUndo,
      'CanUndo must be True after editing a synchronously loaded document');

    FScintilla.Undo;
    CheckEquals(lContent, FScintilla.GetText,
      'Undo after synchronous file load should restore the original content');
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDScintillaTyped.TestBeginLoadFromFileEnablesUndoAfterEdit;
var
  lContent: string;
  lFileName: string;
  lStartTick: Cardinal;
  lTempDir: string;
begin
  lTempDir := CreateWritableTempDir;
  try
    lFileName := TPath.Combine(lTempDir, 'undo-async.txt');
    lContent := 'async original';
    TFile.WriteAllText(lFileName, lContent, TEncoding.UTF8);

    Check(FScintilla.BeginLoadFromFile(lFileName),
      'BeginLoadFromFile should start asynchronous loading');

    lStartTick := GetTickCount;
    while not (FScintilla.FileLoadStatus.Stage in [sflsCompleted, sflsFailed, sflsCancelled]) and
      (GetTickCount - lStartTick < 10000) do
    begin
      Application.ProcessMessages;
      Sleep(5);
    end;

    CheckEquals(Ord(sflsCompleted), Ord(FScintilla.FileLoadStatus.Stage),
      'Async file loading should complete before testing undo');
    Check(FScintilla.UndoCollection,
      'UndoCollection must be True after BeginLoadFromFile so user edits can be undone');
    Check(not FScintilla.CanUndo,
      'CanUndo should be False immediately after async loading (clean state)');

    FScintilla.InsertText(0, 'EDIT: ');
    Check(FScintilla.CanUndo,
      'CanUndo must be True after editing an asynchronously loaded document');

    FScintilla.Undo;
    CheckEquals(lContent, FScintilla.GetText,
      'Undo after async file load should restore the original content');
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDScintillaTyped.TestWindowsEditCommandsRouteToScintilla;
const
  SampleText = 'alpha beta';
var
  lClipboardText: string;
begin
  Check(TrySetClipboardText(''),
    'Test precondition failed: clipboard should be writable for edit-command routing checks');
  FScintilla.SetText(SampleText);
  FScintilla.SetSel(0, 5);

  FScintilla.Perform(WM_COPY, 0, 0);
  Check(TryGetClipboardText(lClipboardText),
    'WM_COPY verification requires readable clipboard contents');
  CheckEquals('alpha', lClipboardText,
    'WM_COPY should route to the Scintilla selection copy command');

  FScintilla.Perform(WM_CUT, 0, 0);
  CheckEquals(' beta', FScintilla.GetText,
    'WM_CUT should route to the Scintilla cut command');

  FScintilla.SetSel(0, 0);
  FScintilla.Perform(WM_PASTE, 0, 0);
  CheckEquals('alpha beta', FScintilla.GetText,
    'WM_PASTE should route to the Scintilla paste command');

  FScintilla.SetSel(0, 5);
  FScintilla.Perform(WM_CLEAR, 0, 0);
  CheckEquals(' beta', FScintilla.GetText,
    'WM_CLEAR should route to the Scintilla delete-selection command');

  FScintilla.Perform(WM_UNDO, 0, 0);
  CheckEquals('alpha beta', FScintilla.GetText,
    'WM_UNDO should route to the Scintilla undo command');
end;

procedure TTestDScintillaTyped.TestWantsSpecialKeysForScintillaKeyboardCommands;
begin
  CheckEquals(1, FScintilla.Perform(CM_WANTSPECIALKEY, VK_TAB, 0),
    'TDScintilla should request TAB so Scintilla keyboard commands can handle it');
  CheckEquals(1, FScintilla.Perform(CM_WANTSPECIALKEY, VK_RETURN, 0),
    'TDScintilla should request ENTER so Scintilla keyboard commands can handle it');
  CheckEquals(1, FScintilla.Perform(CM_WANTSPECIALKEY, VK_LEFT, 0),
    'TDScintilla should request arrow keys so Scintilla keyboard commands can handle them');
  Check((FScintilla.Perform(WM_GETDLGCODE, 0, 0) and DLGC_WANTTAB) <> 0,
    'WM_GETDLGCODE should continue requesting TAB delivery');
  Check((FScintilla.Perform(WM_GETDLGCODE, 0, 0) and DLGC_WANTARROWS) <> 0,
    'WM_GETDLGCODE should continue requesting arrow-key delivery');
end;

procedure TTestDScintillaTyped.TestTextRoundTrip;
const
  SampleText = 'typed api smoke test';
begin
  FScintilla.SetText(SampleText);
  CheckEquals(SampleText, FScintilla.GetText);
end;

procedure TTestDScintillaTyped.TestTypedEnumProperties;
begin
  FScintilla.EOLMode := sceolLF;
  CheckEquals(Ord(sceolLF), Ord(FScintilla.EOLMode));

  FScintilla.ViewWS := scwsVISIBLE_ALWAYS;
  CheckEquals(Ord(scwsVISIBLE_ALWAYS), Ord(FScintilla.ViewWS));

  Check(TDSciLexerIdFromInt(SCLEX_GDSCRIPT) = sclGDSCRIPT);
  Check(TDSciLexerIdFromInt(SCLEX_NIX) = sclNIX);
  Check(TDSciLexerIdFromInt(SCLEX_ESCSEQ) = sclESCSEQ);
end;

procedure TTestDScintillaTyped.TestEnumSetProperties;
begin
  FScintilla.SearchFlags := [scfoMATCH_CASE, scfoWHOLE_WORD];
  Check(FScintilla.SearchFlags = [scfoMATCH_CASE, scfoWHOLE_WORD]);
end;

procedure TTestDScintillaTyped.TestStyleCharacterSetRoundTrip;
begin
  FScintilla.StyleCharacterSet[0] := sccsDEFAULT;
  CheckEquals(Ord(sccsDEFAULT), Ord(FScintilla.StyleCharacterSet[0]));
end;

procedure TTestDScintillaTyped.TestMarkerLayerRoundTrip;
begin
  FScintilla.MarkerLayer[0] := sclOVER_TEXT;
  CheckEquals(Ord(sclOVER_TEXT), Ord(FScintilla.MarkerLayer[0]));
end;

procedure TTestDScintillaTyped.TestPropertyLookup;
begin
  CheckEquals('lexilla', FScintilla.Lexilla.GetNameSpace);
end;

procedure TTestDScintillaTyped.TestSettingsThemeXmlsAreWellFormed;
var
  lFiles: TStringDynArray;
  lFileName: string;
  lModel: TDSciVisualStyleModel;
  lThemesDir: string;
  lRootCandidate: string;
begin
  // Regression: bare & in XML attribute values (e.g. name="BUILIN FUNC & TYPE")
  // causes an "white space does not allowed here" parse error in OmniXML.
  // All theme XML files shipped under settings/themes/ must be well-formed XML.
  lThemesDir := TPath.Combine(ResolveSettingsDir, 'themes');
  if TDirectory.Exists(lThemesDir) then
  begin
    lFiles := TDirectory.GetFiles(lThemesDir, '*.xml');
    for lFileName in lFiles do
    begin
      lModel := nil;
      try
        lModel := LoadThemeStyleModelFromFile(lFileName);
        DSciLog(Format('Theme XML loaded OK: %s', [ExtractFileName(lFileName)]));
      except
        on E: Exception do
          Fail(Format('Theme XML parse failed for %s: %s - %s',
            [ExtractFileName(lFileName), E.ClassName, E.Message]));
      end;
      lModel.Free;
    end;
  end;

  // Regression guard for settings/Dracula.xml which had a bare & on line 909.
  lRootCandidate := TPath.Combine(ResolveSettingsDir, 'Dracula.xml');
  if FileExists(lRootCandidate) then
  begin
    lModel := nil;
    try
      lModel := LoadThemeStyleModelFromFile(lRootCandidate);
      DSciLog(Format('Theme XML loaded OK: %s', [ExtractFileName(lRootCandidate)]));
    except
      on E: Exception do
        Fail(Format('[Settings/Dracula.xml parse failed: %s - %s',
          [E.ClassName, E.Message]));
    end;
    lModel.Free;
  end;
end;

procedure TTestDScintillaTyped.TestLoadFromFileSizeLimitRejectsOversizedFile;
var
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lFileName: string;
  lRecorder: TFileLoadRecorder;
  lTempDir: string;
begin
  // Regression: IsFileSizeWithinLimit must block LoadFromFile when limit is exceeded.
  lTempDir := CreateWritableTempDir;
  lRecorder := TFileLoadRecorder.Create;
  try
    lConfigFileName := TPath.Combine(lTempDir, 'tiny-limit.config.xml');
    lFileName := TPath.Combine(lTempDir, 'oversized.txt');

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.FileSizeLimit := 8;
      lConfig.SaveToFile(lConfigFileName);
    finally
      lConfig.Free;
    end;

    TFile.WriteAllText(lFileName, 'This text is much larger than 8 bytes.', TEncoding.UTF8);
    FScintilla.Settings.LoadConfigFile(lConfigFileName);
    FScintilla.OnFileLoadStateChange := lRecorder.HandleFileLoadState;

    Check(not FScintilla.LoadFromFile(lFileName),
      'LoadFromFile must return False when file size exceeds FileSizeLimit');
    CheckEquals(Ord(sflsFailed), Ord(FScintilla.FileLoadStatus.Stage),
      'FileLoadStatus must be sflsFailed when size limit rejects the load');
    CheckEquals(0, FScintilla.TextLength,
      'Editor must remain empty when file size exceeds the configured limit');
  finally
    lRecorder.Free;
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDScintillaTyped.TestBeginLoadFromFileSizeLimitRejectsOversizedFile;
var
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lFileName: string;
  lRecorder: TFileLoadRecorder;
  lTempDir: string;
begin
  // Regression: IsFileSizeWithinLimit must block BeginLoadFromFile synchronously
  // before the async thread is created; no thread should start.
  lTempDir := CreateWritableTempDir;
  lRecorder := TFileLoadRecorder.Create;
  try
    lConfigFileName := TPath.Combine(lTempDir, 'tiny-limit-async.config.xml');
    lFileName := TPath.Combine(lTempDir, 'oversized-async.txt');

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.FileSizeLimit := 8;
      lConfig.SaveToFile(lConfigFileName);
    finally
      lConfig.Free;
    end;

    TFile.WriteAllText(lFileName, 'This text is much larger than 8 bytes.', TEncoding.UTF8);
    FScintilla.Settings.LoadConfigFile(lConfigFileName);
    FScintilla.OnFileLoadStateChange := lRecorder.HandleFileLoadState;

    Check(not FScintilla.BeginLoadFromFile(lFileName),
      'BeginLoadFromFile must return False when file size exceeds FileSizeLimit');
    CheckEquals(Ord(sflsFailed), Ord(FScintilla.FileLoadStatus.Stage),
      'FileLoadStatus must be sflsFailed when size limit rejects the async load');
    Check(not FScintilla.IsFileLoading,
      'IsFileLoading must be False after a size-limit rejection (no async thread started)');
    CheckEquals(0, FScintilla.TextLength,
      'Editor must remain empty when async load is rejected by size limit');
  finally
    lRecorder.Free;
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

procedure TTestDScintillaTyped.TestLoadFromFileZeroLimitMeansNoLimit;
var
  lConfig: TDSciVisualConfig;
  lConfigFileName: string;
  lContent: string;
  lFileName: string;
  lTempDir: string;
begin
  // Regression: FileSizeLimit = 0 must mean no limit - any file size is accepted.
  lTempDir := CreateWritableTempDir;
  try
    lConfigFileName := TPath.Combine(lTempDir, 'no-limit.config.xml');
    lFileName := TPath.Combine(lTempDir, 'any-size.txt');
    lContent := 'some content that would exceed a very small limit';

    lConfig := TDSciVisualConfig.Create;
    try
      lConfig.FileSizeLimit := 0;
      lConfig.SaveToFile(lConfigFileName);
    finally
      lConfig.Free;
    end;

    TFile.WriteAllText(lFileName, lContent, TEncoding.UTF8);
    FScintilla.Settings.LoadConfigFile(lConfigFileName);

    Check(FScintilla.LoadFromFile(lFileName),
      'LoadFromFile must succeed when FileSizeLimit is 0 (no limit)');
    CheckEquals(Ord(sflsCompleted), Ord(FScintilla.FileLoadStatus.Stage),
      'FileLoadStatus must be sflsCompleted when limit is 0 regardless of file size');
  finally
    if DirectoryExists(lTempDir) then
      TDirectory.Delete(lTempDir, True);
  end;
end;

initialization
  RegisterTest(TTestDScintillaTyped.Suite);

end.