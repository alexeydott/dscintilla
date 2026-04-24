unit DScintillaWinTheme;

{
  DScintillaWinTheme — Windows system theme color wrapper
  --------------------------------------------------------
  Uses Windows.UI.ViewManagement.UISettings (WinRT, Windows 10+) via a
  raw COM-vtable approach and dynamic loading of combase.dll, so the unit
  has zero hard dependencies on WinRT headers or the WinRT import library.

  Reference:
    https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/ui/
    apply-windows-themes

  Fallback:
    On systems where WinRT (combase.dll / RoActivateInstance) is unavailable,
    the unit falls back to registry-based detection (AppsUseLightTheme) and
    hard-coded symmetric defaults for Background/Foreground.

  Key design decisions
  --------------------
  * IsWinDarkMode uses the Microsoft-recommended Foreground luminance formula:
      dark mode ↔ (5*G + 2*R + B) > (8*128)   [foreground is "light"]
    This is identical to what the C++/WinRT sample in the MS docs does.
  * Surface color = Background.Lightened(40).
    UISettings.Background is pure black in dark mode; adding +40 to every
    channel yields ~#282828, a typical dark-surface tone used by Windows
    applications (Notepad, Explorer panels, etc.).
  * Accent colours come straight from UISettings; they already carry correct
    light/dark variants through uctAccentLight1 / uctAccentDark1.
}

{$IFDEF WIN64}
{$ALIGN 8}
{$ELSE}
{$ALIGN 4}
{$ENDIF}

interface

uses
  Windows, Graphics;

type
  { UIColorType — mirrors Windows.UI.ViewManagement.UIColorType }
  TUIColorType = (
    uctBackground   = 0,
    uctForeground   = 1,
    uctAccentDark3  = 2,
    uctAccentDark2  = 3,
    uctAccentDark1  = 4,
    uctAccent       = 5,
    uctAccentLight1 = 6,
    uctAccentLight2 = 7,
    uctAccentLight3 = 8,
    uctComplement   = 9
  );

  { ABI-compatible Windows.UI.Color struct (A,R,G,B byte order) }
  TWinUIColor = packed record
    A: Byte;
    R: Byte;
    G: Byte;
    B: Byte;

    { Convert to Delphi TColor / COLORREF (0x00BBGGRR) }
    function ToTColor: TColor;

    { Microsoft perceived-brightness formula: (5*G + 2*R + B) > (8*128).
      Returns True when the colour is perceived as "light". }
    function IsLight: Boolean;

    { Return a brightened copy with each channel capped at 255 }
    function Lightened(Amount: Byte): TWinUIColor;
  end;

  { Complete theme colour snapshot returned by GetWinThemeColors }
  TWinThemeColors = record
    Background:   TColor; // #000000 in dark mode, #FFFFFF in light mode
    Foreground:   TColor; // #FFFFFF in dark mode, #000000 in light mode
    Surface:      TColor; // Background + 40 brightness offset (~#282828 dark)
    Accent:       TColor; // Windows accent colour
    AccentLight1: TColor; // Lighter accent variant
    AccentDark1:  TColor; // Darker accent variant
    IsDark:       Boolean;
  end;

{ Returns the full system theme colour snapshot.
  Falls back gracefully when WinRT is unavailable. }
function GetWinThemeColors: TWinThemeColors;

{ Get a single UIColorType value from UISettings.GetColorValue.
  Returns a sensible default when the call fails. }
function GetWinUIColor(AColorType: TUIColorType): TWinUIColor;

{ True when dark mode is active.
  Uses the Microsoft-recommended formula applied to the Foreground colour. }
function IsWinDarkMode: Boolean;

implementation

uses
  SysUtils, System.Win.Registry;

{ ---- WinRT minimal COM vtable types -------------------------------------------

  We need two raw vtable layouts:

  TComBaseVtbl    -- returned by RoActivateInstance; we only need QI + Release
                    (slots 0-2 of IUnknown).

  TUISettings3Vtbl -- the IUISettings3 interface we QI for:
    IID = 03021BE4-5254-4781-8194-5168F7D06D7B
    Vtable slots:
      0  IUnknown::QueryInterface
      1  IUnknown::AddRef
      2  IUnknown::Release
      3  IInspectable::GetIids
      4  IInspectable::GetRuntimeClassName
      5  IInspectable::GetTrustLevel
      6  IUISettings3::GetColorValue         <-- we use this
      7  IUISettings3::ColorValuesChanged    <-- placeholder
}

type
  HSTRING = Pointer;

  { Minimal vtable for a COM object -- covers only IUnknown (QI/AddRef/Release) }
  TComBaseVtbl = record
    QueryInterface: function(AThis: Pointer; const IID: TGUID;
                             var ppvObject: Pointer): HRESULT; stdcall;
    AddRef:         function(AThis: Pointer): UInt32; stdcall;
    Release:        function(AThis: Pointer): UInt32; stdcall;
  end;
  PComBaseVtbl = ^TComBaseVtbl;
  TComBaseObj  = record Vtbl: PComBaseVtbl; end;
  PComBaseObj  = ^TComBaseObj;

  { Full vtable for IUISettings3 (slots 0-7) }
  TUISettings3Vtbl = record
    { IUnknown }
    QueryInterface:      function(AThis: Pointer; const IID: TGUID;
                                  var ppvObject: Pointer): HRESULT; stdcall;
    AddRef:              function(AThis: Pointer): UInt32; stdcall;
    Release:             function(AThis: Pointer): UInt32; stdcall;
    { IInspectable — not called, but must be present for correct slot offsets }
    _GetIids:            Pointer; // slot 3
    _GetRuntimeClass:    Pointer; // slot 4
    _GetTrustLevel:      Pointer; // slot 5
    { IUISettings3 }
    GetColorValue:       function(AThis: Pointer; colorType: Integer;
                                  out color: TWinUIColor): HRESULT; stdcall;
    _ColorValuesChanged: Pointer; // slot 7 -- unused
  end;
  PUISettings3Vtbl = ^TUISettings3Vtbl;
  TUISettings3Obj  = record Vtbl: PUISettings3Vtbl; end;
  PUISettings3Obj  = ^TUISettings3Obj;

const
  IID_IUISettings3: TGUID = '{03021BE4-5254-4781-8194-5168F7D06D7B}';
  CLSID_UISettings = 'Windows.UI.ViewManagement.UISettings';

var
  _ComBaseLib: HMODULE = 0;

  _RoActivateInstance: function(
    activatableClassId: HSTRING;
    var instance: PComBaseObj): HRESULT; stdcall;

  _WindowsCreateString: function(
    sourceString: PWideChar;
    length: UINT32;
    var outStr: HSTRING): HRESULT; stdcall;

  _WindowsDeleteString: function(
    str: HSTRING): HRESULT; stdcall;

  _WinRTAvailable: Integer; // -1 = not probed, 0 = unavailable, 1 = available

procedure EnsureWinRT;
begin
  if _WinRTAvailable >= 0 then Exit;
  _WinRTAvailable := 0;
  _ComBaseLib := LoadLibrary('combase.dll');
  if _ComBaseLib = 0 then Exit;
  @_RoActivateInstance  := GetProcAddress(_ComBaseLib, 'RoActivateInstance');
  @_WindowsCreateString := GetProcAddress(_ComBaseLib, 'WindowsCreateString');
  @_WindowsDeleteString := GetProcAddress(_ComBaseLib, 'WindowsDeleteString');
  if Assigned(_RoActivateInstance)
     and Assigned(_WindowsCreateString)
     and Assigned(_WindowsDeleteString)
  then
    _WinRTAvailable := 1;
end;

{ Calls UISettings.GetColorValue(colorType) via WinRT.
  Returns True and fills AColor on success. }
function TryWinRTGetColor(AColorType: Integer; out AColor: TWinUIColor): Boolean;
var
  LHStr:      HSTRING;
  LInspect:   PComBaseObj;
  LSettings:  PUISettings3Obj;
  LSettingsP: Pointer;
  LIID:       TGUID;
begin
  Result  := False;
  FillChar(AColor, SizeOf(AColor), 0);
  EnsureWinRT;
  if _WinRTAvailable <> 1 then Exit;
  LHStr     := nil;
  LInspect  := nil;
  LSettings := nil;
  try
    if _WindowsCreateString(CLSID_UISettings, Length(CLSID_UISettings), LHStr) <> S_OK then Exit;
    if _RoActivateInstance(LHStr, LInspect) <> S_OK then Exit;
    LIID       := IID_IUISettings3;
    LSettingsP := nil;
    if LInspect.Vtbl.QueryInterface(LInspect, LIID, LSettingsP) <> S_OK then Exit;
    LSettings := PUISettings3Obj(LSettingsP);
    Result := LSettings.Vtbl.GetColorValue(LSettings, AColorType, AColor) = S_OK;
  finally
    if Assigned(LSettings) then
      LSettings.Vtbl.Release(LSettings);
    if Assigned(LInspect) then
      LInspect.Vtbl.Release(LInspect);
    if LHStr <> nil then
      _WindowsDeleteString(LHStr);
  end;
end;

{ Registry fallback: read AppsUseLightTheme }
function RegistryIsDarkMode: Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize') then
    begin
      if Reg.ValueExists('AppsUseLightTheme') then
        Result := Reg.ReadInteger('AppsUseLightTheme') = 0;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

{ ── TWinUIColor ─────────────────────────────────────────────────────────── }

function TWinUIColor.ToTColor: TColor;
begin
  { COLORREF = 0x00BBGGRR, identical to Windows.RGB(R,G,B) }
  Result := TColor(R or (G shl 8) or (B shl 16));
end;

function TWinUIColor.IsLight: Boolean;
begin
  { Microsoft perceived-brightness formula:
      (5*G + 2*R + B) > (8 * 128)
    Source: https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/
    ui/apply-windows-themes#determine-if-dark-mode-is-enabled }
  Result := (5 * Integer(G) + 2 * Integer(R) + Integer(B)) > (8 * 128);
end;

function TWinUIColor.Lightened(Amount: Byte): TWinUIColor;
  function Cap(V: Integer): Byte; inline;
  begin
    if V > 255 then Result := 255 else Result := Byte(V);
  end;
begin
  Result.A := A;
  Result.R := Cap(Integer(R) + Amount);
  Result.G := Cap(Integer(G) + Amount);
  Result.B := Cap(Integer(B) + Amount);
end;

{ ── Public API ─────────────────────────────────────────────────────────── }

function GetWinUIColor(AColorType: TUIColorType): TWinUIColor;
var
  LDark: Boolean;
begin
  if TryWinRTGetColor(Ord(AColorType), Result) then Exit;
  { WinRT unavailable — symmetric registry-based fallback }
  LDark := RegistryIsDarkMode;
  FillChar(Result, SizeOf(Result), 0);
  Result.A := 255;
  case AColorType of
    uctBackground:
      if LDark then begin Result.R := 0;   Result.G := 0;   Result.B := 0;   end
      else           begin Result.R := 255; Result.G := 255; Result.B := 255; end;
    uctForeground:
      if LDark then begin Result.R := 255; Result.G := 255; Result.B := 255; end
      else           begin Result.R := 0;   Result.G := 0;   Result.B := 0;   end;
  else
    Result.R := 128; Result.G := 128; Result.B := 128;
  end;
end;

function IsWinDarkMode: Boolean;
begin
  { MS docs: "if the foreground is light, dark mode is enabled" }
  Result := GetWinUIColor(uctForeground).IsLight;
end;

function GetWinThemeColors: TWinThemeColors;
var
  LBG, LFG, LAcc, LAccL1, LAccD1: TWinUIColor;
begin
  LBG    := GetWinUIColor(uctBackground);
  LFG    := GetWinUIColor(uctForeground);
  LAcc   := GetWinUIColor(uctAccent);
  LAccL1 := GetWinUIColor(uctAccentLight1);
  LAccD1 := GetWinUIColor(uctAccentDark1);

  Result.Background   := LBG.ToTColor;
  Result.Foreground   := LFG.ToTColor;
  { Surface = Background lightened by 40.
    In dark mode: #000000 + 40 = #282828 (typical Windows dark-surface tone).
    In light mode: #FFFFFF + 40 = #FFFFFF (clamps at 255 — stays white). }
  Result.Surface      := LBG.Lightened(40).ToTColor;
  Result.Accent       := LAcc.ToTColor;
  Result.AccentLight1 := LAccL1.ToTColor;
  Result.AccentDark1  := LAccD1.ToTColor;
  Result.IsDark       := LFG.IsLight;
end;

initialization
  _WinRTAvailable := -1;
  _ComBaseLib     := 0;

finalization
  if _ComBaseLib <> 0 then
  begin
    FreeLibrary(_ComBaseLib);
    _ComBaseLib := 0;
  end;

end.
