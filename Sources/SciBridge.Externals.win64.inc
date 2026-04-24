{
  External declarations for Win64 static linking.
  These satisfy UNDEFINED references from bcc64x-compiled Scintilla objects
  that are NOT covered by System.Win.Crtl or Winapi.Windows.
  Grouped by DLL.
}

{ ---- ucrtbase.dll : UCRT internals ---- }
function  ___mb_cur_max_func: Integer; cdecl; external 'ucrtbase.dll';
function  __acrt_iob_func(index: Integer): Pointer; cdecl; external 'ucrtbase.dll';
function  __pctype_func: Pointer; cdecl; external 'ucrtbase.dll';
function  __stdio_common_vfprintf(options: UInt64; stream: Pointer; fmt: PAnsiChar; locale: Pointer; args: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  __stdio_common_vsscanf(options: UInt64; buf: PAnsiChar; bufSz: NativeUInt; fmt: PAnsiChar; locale: Pointer; args: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  __stdio_common_vswprintf(options: UInt64; buf: PWideChar; bufSz: NativeUInt; fmt: PWideChar; locale: Pointer; args: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  __sys_nerr: PInteger; cdecl; external 'ucrtbase.dll';
procedure _aligned_free(ptr: Pointer); cdecl; external 'ucrtbase.dll';
function  _aligned_malloc(size, alignment: NativeUInt): Pointer; cdecl; external 'ucrtbase.dll';
procedure _assert(msg, filename: PAnsiChar; line: Integer); cdecl; external 'ucrtbase.dll';
function  _configthreadlocale(flag: Integer): Integer; cdecl; external 'ucrtbase.dll';
function  _create_locale(cat: Integer; locale: PAnsiChar): Pointer; cdecl; external 'ucrtbase.dll';
procedure _fpreset; cdecl; external 'ucrtbase.dll';
procedure _free_locale(locale: Pointer); cdecl; external 'ucrtbase.dll';

{ ---- ucrtbase.dll : locale-aware character classification ---- }
function  _isctype_l(c, mask: Integer; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  _iswalpha_l(c: Word; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  _iswcntrl_l(c: Word; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  _iswdigit_l(c: Word; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  _iswlower_l(c: Word; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  _iswprint_l(c: Word; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  _iswpunct_l(c: Word; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  _iswspace_l(c: Word; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  _iswupper_l(c: Word; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  _iswxdigit_l(c: Word; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';

{ ---- ucrtbase.dll : locale-aware string/conversion ---- }
function  _mbtowc_l(pwc: PWideChar; s: PAnsiChar; n: NativeUInt; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  _strcoll_l(s1, s2: PAnsiChar; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  _strdup(s: PAnsiChar): PAnsiChar; cdecl; external 'ucrtbase.dll';
function  _strftime_l(buf: PAnsiChar; mx: NativeUInt; fmt: PAnsiChar; tm, locale: Pointer): NativeUInt; cdecl; external 'ucrtbase.dll';
function  _strtod_l(s: PAnsiChar; endp: PPointer; locale: Pointer): Double; cdecl; external 'ucrtbase.dll';
function  _strtoi64_l(s: PAnsiChar; endp: PPointer; base: Integer; locale: Pointer): Int64; cdecl; external 'ucrtbase.dll';
function  _strtoui64_l(s: PAnsiChar; endp: PPointer; base: Integer; locale: Pointer): UInt64; cdecl; external 'ucrtbase.dll';
function  _strxfrm_l(dst, src: PAnsiChar; n: NativeUInt; locale: Pointer): NativeUInt; cdecl; external 'ucrtbase.dll';
function  _tolower_l(c: Integer; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  _toupper_l(c: Integer; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  _towlower_l(c: Word; locale: Pointer): Word; cdecl; external 'ucrtbase.dll';
function  _towupper_l(c: Word; locale: Pointer): Word; cdecl; external 'ucrtbase.dll';
function  _wcscoll_l(s1, s2: PWideChar; locale: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  _wcsxfrm_l(dst, src: PWideChar; n: NativeUInt; locale: Pointer): NativeUInt; cdecl; external 'ucrtbase.dll';

{ ---- ucrtbase.dll : standard C library ---- }
procedure abort; cdecl; external 'ucrtbase.dll';
{ atexit, sscanf, vfprintf, fprintf: resolved by sci_crt_ucrt_stubs in the combined OBJ }
function  btowc(c: Integer): Word; cdecl; external 'ucrtbase.dll';
function  calloc(num, size: NativeUInt): Pointer; cdecl; external 'ucrtbase.dll';
function  fflush(stream: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  fputc(c: Integer; stream: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  fputs(s: PAnsiChar; stream: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  fwrite(buf: Pointer; size, count: NativeUInt; stream: Pointer): NativeUInt; cdecl; external 'ucrtbase.dll';
function  getenv(name: PAnsiChar): PAnsiChar; cdecl; external 'ucrtbase.dll';
function  localeconv: Pointer; cdecl; external 'ucrtbase.dll';
function  mbrlen(s: PAnsiChar; n: NativeUInt; ps: Pointer): NativeUInt; cdecl; external 'ucrtbase.dll';
function  mbrtowc(pwc: PWideChar; s: PAnsiChar; n: NativeUInt; ps: Pointer): NativeUInt; cdecl; external 'ucrtbase.dll';
function  mbsrtowcs(dst: PWideChar; src: PPointer; n: NativeUInt; ps: Pointer): NativeUInt; cdecl; external 'ucrtbase.dll';
function  setlocale(cat: Integer; locale: PAnsiChar): PAnsiChar; cdecl; external 'ucrtbase.dll';
function  strerror_s(buf: PAnsiChar; bufsz: NativeUInt; errnum: Integer): Integer; cdecl; external 'ucrtbase.dll';
function  strtof(s: PAnsiChar; endp: PPointer): Single; cdecl; external 'ucrtbase.dll';
function  strtol(s: PAnsiChar; endp: PPointer; base: Integer): Integer; cdecl; external 'ucrtbase.dll';
function  strtold(s: PAnsiChar; endp: PPointer): Extended; cdecl; external 'ucrtbase.dll';
function  strtoll(s: PAnsiChar; endp: PPointer; base: Integer): Int64; cdecl; external 'ucrtbase.dll';
function  strtoul(s: PAnsiChar; endp: PPointer; base: Integer): Cardinal; cdecl; external 'ucrtbase.dll';
function  strtoull(s: PAnsiChar; endp: PPointer; base: Integer): UInt64; cdecl; external 'ucrtbase.dll';
function  wcrtomb(s: PAnsiChar; wc: WideChar; ps: Pointer): NativeUInt; cdecl; external 'ucrtbase.dll';
function  wcrtomb_s(retval: PNativeUInt; s: PAnsiChar; smax: NativeUInt; wc: WideChar; ps: Pointer): Integer; cdecl; external 'ucrtbase.dll';
function  wcstod(s: PWideChar; endp: PPointer): Double; cdecl; external 'ucrtbase.dll';
function  wcstof(s: PWideChar; endp: PPointer): Single; cdecl; external 'ucrtbase.dll';
function  wcstol(s: PWideChar; endp: PPointer; base: Integer): Integer; cdecl; external 'ucrtbase.dll';
function  wcstold(s: PWideChar; endp: PPointer): Extended; cdecl; external 'ucrtbase.dll';
function  wcstoll(s: PWideChar; endp: PPointer; base: Integer): Int64; cdecl; external 'ucrtbase.dll';
function  wcstoul(s: PWideChar; endp: PPointer; base: Integer): Cardinal; cdecl; external 'ucrtbase.dll';
function  wcstoull(s: PWideChar; endp: PPointer; base: Integer): UInt64; cdecl; external 'ucrtbase.dll';
function  wctob(c: Word): Integer; cdecl; external 'ucrtbase.dll';

{ ---- ole32.dll ---- }
function  CLSIDFromProgID(lpszProgID: PWideChar; lpclsid: Pointer): HRESULT; stdcall; external 'ole32.dll';
function  CoCreateInstance(const clsid: TGUID; unkOuter: Pointer; ctx: Cardinal; const iid: TGUID; out obj): HRESULT; stdcall; external 'ole32.dll';
function  DoDragDrop(dataObj, dropSource: Pointer; okEffects: Cardinal; out effect: Cardinal): HRESULT; stdcall; external 'ole32.dll';
function  OleInitialize(pvReserved: Pointer): HRESULT; stdcall; external 'ole32.dll';
procedure OleUninitialize; stdcall; external 'ole32.dll';
function  RegisterDragDrop(hwnd: HWND; dropTarget: Pointer): HRESULT; stdcall; external 'ole32.dll';
procedure ReleaseStgMedium(pmedium: Pointer); stdcall; external 'ole32.dll';
function  RevokeDragDrop(hwnd: HWND): HRESULT; stdcall; external 'ole32.dll';

{ ---- oleaut32.dll ---- }
function  SysAllocStringLen(psz: PWideChar; len: Cardinal): Pointer; stdcall; external 'oleaut32.dll';
procedure SysFreeString(bstr: Pointer); stdcall; external 'oleaut32.dll';

{ ---- imm32.dll ---- }
function  ImmEscapeW(hkl: HKL; himc: THandle; uEsc: Cardinal; lpData: Pointer): LRESULT; stdcall; external 'imm32.dll';
function  ImmGetCompositionStringW(himc: THandle; dwIndex: Cardinal; lpBuf: Pointer; dwBufLen: Cardinal): Integer; stdcall; external 'imm32.dll';
function  ImmGetContext(hwnd: HWND): THandle; stdcall; external 'imm32.dll';
function  ImmNotifyIME(himc: THandle; dwAction, dwIndex, dwValue: Cardinal): LongBool; stdcall; external 'imm32.dll';
function  ImmReleaseContext(hwnd: HWND; himc: THandle): LongBool; stdcall; external 'imm32.dll';
function  ImmSetCandidateWindow(himc: THandle; lpCandidate: Pointer): LongBool; stdcall; external 'imm32.dll';
function  ImmSetCompositionFontW(himc: THandle; lplf: Pointer): LongBool; stdcall; external 'imm32.dll';
function  ImmSetCompositionStringW(himc: THandle; dwIndex: Cardinal; lpComp: Pointer; dwCompLen: Cardinal; lpRead: Pointer; dwReadLen: Cardinal): LongBool; stdcall; external 'imm32.dll';
function  ImmSetCompositionWindow(himc: THandle; lpCompForm: Pointer): LongBool; stdcall; external 'imm32.dll';

{ ---- msimg32.dll ---- }
function  GdiAlphaBlend(hdcDest: HDC; xDest, yDest, wDest, hDest: Integer; hdcSrc: HDC; xSrc, ySrc, wSrc, hSrc: Integer; blendFunc: Cardinal): LongBool; stdcall; external 'msimg32.dll' name 'AlphaBlend';

{ ---- user32.dll (monitor functions) ---- }
function  GetMonitorInfoA(hMonitor: THandle; lpmi: Pointer): LongBool; stdcall; external 'user32.dll';
function  MonitorFromPoint(pt: TPoint; dwFlags: Cardinal): THandle; stdcall; external 'user32.dll';
function  MonitorFromRect(lprc: Pointer; dwFlags: Cardinal): THandle; stdcall; external 'user32.dll';
function  MonitorFromWindow(hwnd: HWND; dwFlags: Cardinal): THandle; stdcall; external 'user32.dll';

{ ---- kernel32.dll (RTL unwind / SEH) ---- }
procedure RtlCaptureContext(ContextRecord: Pointer); stdcall; external 'kernel32.dll';
function  RtlLookupFunctionEntry(ControlPc: UInt64; ImageBase: PUInt64; HistoryTable: Pointer): Pointer; stdcall; external 'kernel32.dll';
procedure RtlRestoreContext(ContextRecord, ExceptionRecord: Pointer); stdcall; external 'kernel32.dll';
function  RtlUnwindEx(TargetFrame, TargetIp: Pointer; ExceptionRecord: Pointer; ReturnValue: Pointer; ContextRecord: Pointer; HistoryTable: Pointer): Integer; stdcall; external 'kernel32.dll';
function  RtlVirtualUnwind(HandlerType: Cardinal; ImageBase, ControlPc: UInt64; FunctionEntry: Pointer; ContextRecord: Pointer; HandlerData: PPointer; EstablisherFrame: PUInt64; ContextPointers: Pointer): Pointer; stdcall; external 'kernel32.dll';
