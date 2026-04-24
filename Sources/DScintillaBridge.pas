unit DScintillaBridge;
{$IFDEF SCINLILLA_STATIC_LINKING}
{ Suppress "declared but never used" hints for force-link anchor symbols.
  Must remain active at unit end — Delphi checks unused symbols there. }
{$HINTS OFF}
{$ENDIF}
(*
  Delphi declarations for statically linked Scintilla + Lexilla objects.

  Assumptions:
  - Scintilla/Lexilla and SciBridge.cpp are built by MSVC for the same target
    (Win32 or Win64) and in the same configuration.
  - Delphi links the emitted .obj files via {$L ...} from the included .inc file.
  - Delphi treats ILexer5* as an opaque Pointer and only passes it to SCI_SETILEXER.

  Notes:
  - Keep the external boundary in plain C. Do not try to describe ILexer5 in Delphi.
  - Replace the external names below if your actual object file uses different symbol
    decoration. Verify with dumpbin /symbols on the built obj\scibridge32.obj or
    obj\scibridge64.obj.
*)

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils, System.SyncObjs,
  DScintillaLogger
  {$IFDEF SCINLILLA_STATIC_LINKING}
  ,System.Win.Crtl{$ENDIF};  // provides memcpy, strlen, malloc, free, etc. to linked C objects

type
  // Direct-call function type exposed by Scintilla through SCI_GETDIRECTFUNCTION,
  // and also by the exported Scintilla_DirectFunction symbol in the Windows build.
  TSciFnDirect = function(ptr: NativeInt; iMessage: Cardinal; wParam: NativeUInt; lParam: NativeInt): NativeInt; stdcall;

const
  // Minimal subset used by the bridge/sample code.
  // Prefer a full generated translation of Scintilla.h for production use.
  SCI_GETDIRECTFUNCTION = 2184;
  SCI_GETDIRECTPOINTER  = 2185;
  SCI_SETILEXER         = 4033;
{$IFDEF SCINLILLA_STATIC_LINKING}
{$IFDEF WIN32}
function SciBridge_RegisterClasses(hInstance: HINST): Boolean; stdcall; external name '_SciBridge_RegisterClasses@4';
function SciBridge_ReleaseResources: Boolean; stdcall; external name '_SciBridge_ReleaseResources@0';
function LexBridge_CreateLexer(name: PAnsiChar): Pointer; stdcall; external name '_LexBridge_CreateLexer@4';
procedure LexBridge_SetLibraryProperty(key, value: PAnsiChar); stdcall; external name '_LexBridge_SetLibraryProperty@8';
function LexBridge_GetLibraryPropertyNames: PAnsiChar; stdcall; external name '_LexBridge_GetLibraryPropertyNames@0';
function LexBridge_LexerNameFromID(identifier: Integer): PAnsiChar; stdcall; external name '_LexBridge_LexerNameFromID@4';
function LexBridge_GetNameSpace: PAnsiChar; stdcall; external name '_LexBridge_GetNameSpace@0';
function LexBridge_AssignLexerByName(hSci: HWND; name: PAnsiChar): LongBool; stdcall; external name '_LexBridge_AssignLexerByName@8';

// Exported by Scintilla's Windows build.
function Scintilla_DirectFunction(ptr: NativeInt; iMessage: Cardinal; wParam: NativeUInt; lParam: NativeInt): NativeInt; stdcall; external name '_Scintilla_DirectFunction@16';
{$ENDIF}

{$IFDEF WIN64}
function SciBridge_RegisterClasses(hInstance: HINST): Boolean; stdcall; external name 'SciBridge_RegisterClasses';
function SciBridge_ReleaseResources: Boolean; stdcall; external name 'SciBridge_ReleaseResources';
function LexBridge_CreateLexer(name: PAnsiChar): Pointer; stdcall; external name 'LexBridge_CreateLexer';
procedure LexBridge_SetLibraryProperty(key, value: PAnsiChar); stdcall; external name 'LexBridge_SetLibraryProperty';
function LexBridge_GetLibraryPropertyNames: PAnsiChar; stdcall; external name 'LexBridge_GetLibraryPropertyNames';
function LexBridge_LexerNameFromID(identifier: Integer): PAnsiChar; stdcall; external name 'LexBridge_LexerNameFromID';
function LexBridge_GetNameSpace: PAnsiChar; stdcall; external name 'LexBridge_GetNameSpace';
function LexBridge_AssignLexerByName(hSci: HWND; name: PAnsiChar): LongBool; stdcall; external name 'LexBridge_AssignLexerByName';

// Exported by Scintilla's Windows build.
function Scintilla_DirectFunction(ptr: NativeInt; iMessage: Cardinal; wParam: NativeUInt; lParam: NativeInt): NativeInt; stdcall; external name 'Scintilla_DirectFunction';
{$ENDIF}
{$ENDIF SCINLILLA_STATIC_LINKING}

const
  {$IFDEF WIN64}
  cSciBridgeDefaultDll = 'Scintilla64.dll';
  {$ELSE}
  cSciBridgeDefaultDll = 'Scintilla.dll';
  {$ENDIF}
  cSciBridgeLexillaDll = 'Lexilla.dll';

{$IFnDEF SCINLILLA_STATIC_LINKING}
const
  cSciBridgeDllPath: string = 'SCI_BRIDGE_DLL_PATH';
var
  _SciBridgeDllPath: string = '';
{$ENDIF}

// Logging is now in DScintillaLogger.pas (canonical names: DSciLog, cDSciLog*,
// _DSciLog*). Legacy SciBridgeLog aliases remain accessible for backward compat.

const
  cSciBridgeLogPath = 'SCI_BRIDGE_LOG_PATH';

type
  // Lexilla export function pointer types (opaque Pointer for ILexer5*)
  TSciBridgeCreateLexer = function(Name: PAnsiChar): Pointer; stdcall;
  TSciBridgeGetLexerCount = function: Integer; stdcall;
  TSciBridgeGetLexerName = procedure(Index: Cardinal; Buffer: PAnsiChar; BufferLength: Integer); stdcall;
  TSciBridgeGetLexerFactory = function(Index: Cardinal): Pointer; stdcall;
  TSciBridgeLexerNameFromID = function(ID: Integer): PAnsiChar; stdcall;
  TSciBridgeGetLibraryPropertyNames = function: PAnsiChar; stdcall;
  TSciBridgeSetLibraryProperty = procedure(Key: PAnsiChar; Value: PAnsiChar); stdcall;
  TSciBridgeGetNameSpace = function: PAnsiChar; stdcall;

  TSciBridgeLoader = class
  private
    FLock: TCriticalSection;
    FSciDllHandle: HMODULE;
    FLexDllHandle: HMODULE;{$IFDEF SCINLILLA_STATIC_LINKING}
    FClassesRegistered: Boolean;{$ENDIF}

    FCreateLexer: TSciBridgeCreateLexer;
    FGetLexerCount: TSciBridgeGetLexerCount;
    FGetLexerName: TSciBridgeGetLexerName;
    FGetLexerFactory: TSciBridgeGetLexerFactory;
    FLexerNameFromID: TSciBridgeLexerNameFromID;
    FGetLibraryPropertyNames: TSciBridgeGetLibraryPropertyNames;
    FSetLibraryProperty: TSciBridgeSetLibraryProperty;
    FGetNameSpace: TSciBridgeGetNameSpace;

    class var FInstance: TSciBridgeLoader;
    procedure DoLoad;
    procedure DoUnload;
    procedure ResetLexillaExports;
  {$IFNDEF SCINLILLA_STATIC_LINKING}
    function ResolveDllPath: string;
    procedure ResolveLexillaExports;
  {$ELSE}
    procedure InitStaticLexillaExports;
  {$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;

    procedure EnsureLoaded;
    procedure Unload;
    function IsLoaded: Boolean;

    // Lexilla API
    function LexCreateLexer(Name: PAnsiChar): Pointer;
    function LexGetLexerCount: Integer;
    procedure LexGetLexerName(Index: Cardinal; Buffer: PAnsiChar; BufferLength: Integer);
    function LexGetLexerFactory(Index: Cardinal): Pointer;
    function LexLexerNameFromID(ID: Integer): PAnsiChar;
    function LexGetLibraryPropertyNames: PAnsiChar;
    procedure LexSetLibraryProperty(Key, Value: PAnsiChar);
    function LexGetNameSpace: PAnsiChar;

    property DllHandle: HMODULE read FSciDllHandle;
    property LexDllHandle: HMODULE read FLexDllHandle;
  end;

function SciBridgeLoader: TSciBridgeLoader;

// Optional helper wrappers.
function SciSend(hSci: HWND; Msg: Cardinal; WParam: NativeUInt = 0; LParam: NativeInt = 0): NativeInt; inline;
function SciGetDirect(hSci: HWND; out DirectFn: TSciFnDirect; out DirectPtr: NativeInt): Boolean;
procedure SciSetLexer(hSci: HWND; Lexer: Pointer);
function SciSetLexerByName(hSci: HWND; const LexerName: AnsiString): Boolean;


implementation

{$IFDEF SCINLILLA_STATIC_LINKING}
{$IFDEF WIN64}
{ Single combined object: all Scintilla/Lexilla sources + C++ runtime stubs +
  libc++/libunwind, partially linked by GNU ld and sanitized by coff_sanitize.py
  so section names, COMDAT symbols, and dollar signs are Delphi-compatible. }
{$L 'obj\sci_combined_bcc64x.o'}
{ External declarations for CRT, UCRT, OLE, IMM, GDI, and SEH functions
  that the bcc64x objects reference but System.Win.Crtl / Winapi.Windows
  do not cover. }
{$I 'SciBridge.Externals.win64.inc'}
{ C++ global constructor calls — Delphi does not process .ctors sections,
  so we declare each _GLOBAL__sub_I_* symbol explicitly and call them. }
{$I 'SciBridge.Ctors.win64.inc'}
{$ELSE}
{$I 'SciBridge.Objects.inc'}
{$ENDIF}
{$ENDIF SCINLILLA_STATIC_LINKING}


{ TSciBridgeLoader }

constructor TSciBridgeLoader.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
end;

destructor TSciBridgeLoader.Destroy;
begin
  DoUnload;
  FLock.Free;
  inherited;
end;

procedure TSciBridgeLoader.ResetLexillaExports;
begin
  FCreateLexer := nil;
  FGetLexerCount := nil;
  FGetLexerName := nil;
  FGetLexerFactory := nil;
  FLexerNameFromID := nil;
  FGetLibraryPropertyNames := nil;
  FSetLibraryProperty := nil;
  FGetNameSpace := nil;
end;

{$IFDEF SCINLILLA_STATIC_LINKING}
procedure TSciBridgeLoader.InitStaticLexillaExports;
begin
  @FCreateLexer := @LexBridge_CreateLexer;
  @FLexerNameFromID := @LexBridge_LexerNameFromID;
  @FGetLibraryPropertyNames := @LexBridge_GetLibraryPropertyNames;
  @FSetLibraryProperty := @LexBridge_SetLibraryProperty;
  @FGetNameSpace := @LexBridge_GetNameSpace;
  // GetLexerCount, GetLexerName, GetLexerFactory not exposed by static bridge
end;
{$ENDIF}

{$IFNDEF SCINLILLA_STATIC_LINKING}
function TSciBridgeLoader.ResolveDllPath: string;
var
  lEnvValue: string;
begin
  // 1. Explicit global path
  if (_SciBridgeDllPath <> '') and FileExists(_SciBridgeDllPath) then
  begin
    DSciLog('[BRIDGE] Using explicit _SciBridgeDllPath: ' + _SciBridgeDllPath, cDSciLogDebug);
    Result := _SciBridgeDllPath;
    Exit;
  end;

  // 2. Environment variable
  lEnvValue := GetEnvironmentVariable(cSciBridgeDllPath);
  if (lEnvValue <> '') and FileExists(lEnvValue) then
  begin
    DSciLog('[BRIDGE] Using env var ' + cSciBridgeDllPath + ': ' + lEnvValue, cDSciLogDebug);
    _SciBridgeDllPath := lEnvValue;
    Result := lEnvValue;
    Exit;
  end;

  // 3. Default DLL name — Windows PATH search
  DSciLog('[BRIDGE] Using default DLL name for PATH search: ' + cSciBridgeDefaultDll, cDSciLogDebug);
  Result := cSciBridgeDefaultDll;
end;

procedure TSciBridgeLoader.ResolveLexillaExports;
var
  lHandle: HMODULE;
begin
  ResetLexillaExports;

  // Step 1: Try Lexilla exports from the already-loaded Scintilla DLL
  @FCreateLexer := GetProcAddress(FSciDllHandle, 'CreateLexer');
  if Assigned(FCreateLexer) then
  begin
    DSciLog('[BRIDGE] Lexilla exports found in Scintilla DLL', cDSciLogInfo);
    lHandle := FSciDllHandle;
  end
  else
  begin
    // Step 2: Try separate Lexilla DLL
    DSciLog('[BRIDGE] Lexilla exports not in Scintilla DLL, trying ' + cSciBridgeLexillaDll, cDSciLogInfo);
    FLexDllHandle := LoadLibrary(PChar(cSciBridgeLexillaDll));
    if FLexDllHandle = 0 then
    begin
      DSciLog('[BRIDGE] WARNING: ' + cSciBridgeLexillaDll + ' not found; lexer support unavailable', cDSciLogError);
      Exit;
    end;
    DSciLog(Format('[BRIDGE] Loaded %s at handle $%x', [cSciBridgeLexillaDll, FLexDllHandle]), cDSciLogInfo);
    lHandle := FLexDllHandle;
    @FCreateLexer := GetProcAddress(lHandle, 'CreateLexer');
  end;

  if not Assigned(FCreateLexer) then
  begin
    DSciLog('[BRIDGE] WARNING: CreateLexer not found in any DLL', cDSciLogError);
    Exit;
  end;

  // Resolve remaining exports from whichever DLL provided CreateLexer
  @FGetLexerCount := GetProcAddress(lHandle, 'GetLexerCount');
  @FGetLexerName := GetProcAddress(lHandle, 'GetLexerName');
  @FGetLexerFactory := GetProcAddress(lHandle, 'GetLexerFactory');
  @FLexerNameFromID := GetProcAddress(lHandle, 'LexerNameFromID');
  @FGetLibraryPropertyNames := GetProcAddress(lHandle, 'GetLibraryPropertyNames');
  @FSetLibraryProperty := GetProcAddress(lHandle, 'SetLibraryProperty');
  @FGetNameSpace := GetProcAddress(lHandle, 'GetNameSpace');
end;
{$ENDIF}

procedure TSciBridgeLoader.DoLoad;
{$IFNDEF SCINLILLA_STATIC_LINKING}
var
  lPath: string;
  lBuf: array[0..MAX_PATH] of Char;
{$ENDIF}
begin
  if FSciDllHandle <> 0 then
    Exit;

  DSciLog('[BRIDGE] DoLoad starting...', cDSciLogInfo);

{$IFDEF SCINLILLA_STATIC_LINKING}
  if not FClassesRegistered then
  begin
    if not SciBridge_RegisterClasses(HInstance) then
      raise Exception.Create('SciBridge_RegisterClasses failed');
    FClassesRegistered := True;
    DSciLog('[BRIDGE] SciBridge_RegisterClasses OK', cDSciLogInfo);
  end;
  FSciDllHandle := HInstance;
  InitStaticLexillaExports;
{$ELSE}
  lPath := ResolveDllPath;
  { Do NOT use SafeLoadLibrary here. SafeLoadLibrary(path) calls
    SetErrorMode(SEM_NOOPENFILEERRORBOX), which clears the host process's
    SEM_FAILCRITICALERRORS flag. In a DO lister thread (no UI pump) that
    makes LoadLibrary silently fail when DLL dependencies can't be found.
    Use LoadLibrary directly — the host's error mode is already correct,
    and 8087 FPU state is irrelevant on x64. }
  FSciDllHandle := LoadLibrary(PChar(lPath));
  if FSciDllHandle = 0 then
  begin
    DSciLog('[BRIDGE] ERROR: LoadLibrary failed for: ' + lPath + ' (Error: '+GetLastError.ToString+')', cDSciLogError);
    RaiseLastOSError;
  end;

  // Update _SciBridgeDllPath with actual loaded module path
  if GetModuleFileName(FSciDllHandle, @lBuf[0], MAX_PATH) > 0 then
    _SciBridgeDllPath := lBuf;
  DSciLog(Format('[BRIDGE] Scintilla loaded at $%x, path: %s', [FSciDllHandle, _SciBridgeDllPath]), cDSciLogInfo);

  // Resolve Lexilla exports: same DLL first, then separate Lexilla.dll
  ResolveLexillaExports;
{$ENDIF}

  DSciLog('[BRIDGE] DoLoad completed', cDSciLogInfo);
end;

procedure TSciBridgeLoader.DoUnload;
begin
  DSciLog('[BRIDGE] DoUnload starting...', cDSciLogInfo);
  ResetLexillaExports;

{$IFDEF SCINLILLA_STATIC_LINKING}
  if FClassesRegistered then
  begin
    SciBridge_ReleaseResources;
    FClassesRegistered := False;
    DSciLog('[BRIDGE] SciBridge_ReleaseResources OK', cDSciLogInfo);
  end;
  FSciDllHandle := 0;
{$ELSE}
  if FLexDllHandle <> 0 then
  begin
    FreeLibrary(FLexDllHandle);
    DSciLog(Format('[BRIDGE] Freed Lexilla DLL handle $%x', [FLexDllHandle]), cDSciLogInfo);
    FLexDllHandle := 0;
  end;

  if FSciDllHandle <> 0 then
  begin
    FreeLibrary(FSciDllHandle);
    DSciLog(Format('[BRIDGE] Freed Scintilla DLL handle $%x', [FSciDllHandle]), cDSciLogInfo);
    FSciDllHandle := 0;
  end;
{$ENDIF}

  DSciLog('[BRIDGE] DoUnload completed', cDSciLogInfo);
end;

procedure TSciBridgeLoader.EnsureLoaded;
begin
  if FSciDllHandle <> 0 then
    Exit;
  FLock.Enter;
  try
    if FSciDllHandle = 0 then
      DoLoad;
  finally
    FLock.Leave;
  end;
end;

procedure TSciBridgeLoader.Unload;
begin
  FLock.Enter;
  try
    DoUnload;
  finally
    FLock.Leave;
  end;
end;

function TSciBridgeLoader.IsLoaded: Boolean;
begin
  Result := FSciDllHandle <> 0;
end;

function TSciBridgeLoader.LexCreateLexer(Name: PAnsiChar): Pointer;
begin
  EnsureLoaded;
  if Assigned(FCreateLexer) then
    Result := FCreateLexer(Name)
  else
    Result := nil;
end;

function TSciBridgeLoader.LexGetLexerCount: Integer;
begin
  EnsureLoaded;
  if Assigned(FGetLexerCount) then
    Result := FGetLexerCount()
  else
    Result := 0;
end;

procedure TSciBridgeLoader.LexGetLexerName(Index: Cardinal; Buffer: PAnsiChar; BufferLength: Integer);
begin
  EnsureLoaded;
  if Assigned(FGetLexerName) then
    FGetLexerName(Index, Buffer, BufferLength)
  else if (Buffer <> nil) and (BufferLength > 0) then
    Buffer^ := #0;
end;

function TSciBridgeLoader.LexGetLexerFactory(Index: Cardinal): Pointer;
begin
  EnsureLoaded;
  if Assigned(FGetLexerFactory) then
    Result := FGetLexerFactory(Index)
  else
    Result := nil;
end;

function TSciBridgeLoader.LexLexerNameFromID(ID: Integer): PAnsiChar;
begin
  EnsureLoaded;
  if Assigned(FLexerNameFromID) then
    Result := FLexerNameFromID(ID)
  else
    Result := nil;
end;

function TSciBridgeLoader.LexGetLibraryPropertyNames: PAnsiChar;
begin
  EnsureLoaded;
  if Assigned(FGetLibraryPropertyNames) then
    Result := FGetLibraryPropertyNames()
  else
    Result := nil;
end;

procedure TSciBridgeLoader.LexSetLibraryProperty(Key, Value: PAnsiChar);
begin
  EnsureLoaded;
  if Assigned(FSetLibraryProperty) then
    FSetLibraryProperty(Key, Value);
end;

function TSciBridgeLoader.LexGetNameSpace: PAnsiChar;
begin
  EnsureLoaded;
  if Assigned(FGetNameSpace) then
    Result := FGetNameSpace()
  else
    Result := nil;
end;

function SciBridgeLoader: TSciBridgeLoader;
begin
  Result := TSciBridgeLoader.FInstance;
end;

function SciSend(hSci: HWND; Msg: Cardinal; WParam: NativeUInt; LParam: NativeInt): NativeInt; inline;
begin
  Result := SendMessage(hSci, Msg, Winapi.Windows.WPARAM(WParam), Winapi.Windows.LPARAM(LParam));
end;

function SciGetDirect(hSci: HWND; out DirectFn: TSciFnDirect; out DirectPtr: NativeInt): Boolean;
begin
  DirectFn := TSciFnDirect(SendMessage(hSci, SCI_GETDIRECTFUNCTION, 0, 0));
  DirectPtr := NativeInt(SendMessage(hSci, SCI_GETDIRECTPOINTER, 0, 0));
  Result := Assigned(DirectFn) and (DirectPtr <> 0);
end;

procedure SciSetLexer(hSci: HWND; Lexer: Pointer);
begin
  SendMessage(hSci, SCI_SETILEXER, 0, LPARAM(Lexer));
end;

function SciSetLexerByName(hSci: HWND; const LexerName: AnsiString): Boolean;
var
  L: Pointer;
begin
  L := SciBridgeLoader.LexCreateLexer(PAnsiChar(LexerName));
  Result := L <> nil;
  if Result then
    SciSetLexer(hSci, L);
end;

{$IFDEF SCINLILLA_STATIC_LINKING}
{$IFDEF WIN64}
procedure SciStatic_RunDestructors; cdecl; external name 'SciStatic_RunDestructors';
{$ENDIF WIN64}
{$ENDIF SCINLILLA_STATIC_LINKING}

initialization
  TSciBridgeLoader.FInstance := TSciBridgeLoader.Create;
{$IFDEF SCINLILLA_STATIC_LINKING}
  DSciLog('=== DScintillaBridge initialization start ===', cDSciLogDebug);
  DSciLog('Calling SciStatic_RunConstructors...', cDSciLogDebug);
{$IFDEF WIN64}
  SciStatic_RunConstructors;
{$ENDIF WIN64}
  DSciLog('SciStatic_RunConstructors completed OK', cDSciLogDebug);
{$ENDIF SCINLILLA_STATIC_LINKING}

finalization
{$IFDEF SCINLILLA_STATIC_LINKING}
  DSciLog('=== DScintillaBridge finalization start ===', cDSciLogDebug);
  DSciLog('Calling SciStatic_RunDestructors...', cDSciLogDebug);
{$IFDEF WIN64}
  SciStatic_RunDestructors;
{$ENDIF WIN64}
  DSciLog('SciStatic_RunDestructors completed OK', cDSciLogDebug);
{$ENDIF SCINLILLA_STATIC_LINKING}
  TSciBridgeLoader.FInstance.Free;
  TSciBridgeLoader.FInstance := nil;

end.
