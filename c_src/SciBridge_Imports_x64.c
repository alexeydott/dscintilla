/*
 * SciBridge_Imports_x64.c  (AUTO-GENERATED � DO NOT EDIT)
 *
 * Writable __imp_* pointers + direct API thunks for Delphi static linking.
 * See build-delphi-static-objects.cmd for compilation command.
 */

typedef int (__stdcall *FARPROC)();
typedef void *HMODULE;
typedef HMODULE (__stdcall *PFN_GetModuleHandle)(const char *);
typedef FARPROC (__stdcall *PFN_GetProcAddress)(HMODULE, const char *);

/* ---- writable import pointers ---- */

/* kernel32 */
FARPROC __imp_AcquireSRWLockExclusive = 0;
FARPROC __imp_DebugBreak = 0;
FARPROC __imp_FreeLibrary = 0;
FARPROC __imp_GetCurrentProcess = 0;
FARPROC __imp_GetCurrentThreadId = 0;
FARPROC __imp_GetLocaleInfoA = 0;
FARPROC __imp_GetModuleHandleA = 0;
FARPROC __imp_GetModuleHandleW = 0;
FARPROC __imp_GetProcAddress = 0;
FARPROC __imp_GetProcessHeap = 0;
FARPROC __imp_GetSystemInfo = 0;
FARPROC __imp_GetSystemTimeAsFileTime = 0;
FARPROC __imp_GetTickCount = 0;
FARPROC __imp_GlobalAlloc = 0;
FARPROC __imp_GlobalLock = 0;
FARPROC __imp_GlobalSize = 0;
FARPROC __imp_GlobalUnlock = 0;
FARPROC __imp_HeapAlloc = 0;
FARPROC __imp_HeapFree = 0;
FARPROC __imp_HeapReAlloc = 0;
FARPROC __imp_InitializeConditionVariable = 0;
FARPROC __imp_InitializeSRWLock = 0;
FARPROC __imp_LCMapStringW = 0;
FARPROC __imp_LoadLibraryExA = 0;
FARPROC __imp_LoadLibraryExW = 0;
FARPROC __imp_MsgWaitForMultipleObjects = 0;
FARPROC __imp_MulDiv = 0;
FARPROC __imp_MultiByteToWideChar = 0;
FARPROC __imp_OutputDebugStringA = 0;
FARPROC __imp_QueryPerformanceCounter = 0;
FARPROC __imp_QueryPerformanceFrequency = 0;
FARPROC __imp_ReleaseSRWLockExclusive = 0;
FARPROC __imp_Sleep = 0;
FARPROC __imp_SleepConditionVariableSRW = 0;
FARPROC __imp_TerminateProcess = 0;
FARPROC __imp_TryAcquireSRWLockExclusive = 0;
FARPROC __imp_WakeAllConditionVariable = 0;
FARPROC __imp_WakeConditionVariable = 0;
FARPROC __imp_WideCharToMultiByte = 0;
FARPROC __imp___std_init_once_begin_initialize = 0;
FARPROC __imp___std_init_once_complete = 0;

/* user32 */
FARPROC __imp_AdjustWindowRectEx = 0;
FARPROC __imp_AppendMenuA = 0;
FARPROC __imp_BeginPaint = 0;
FARPROC __imp_CallWindowProcA = 0;
FARPROC __imp_ClientToScreen = 0;
FARPROC __imp_CloseClipboard = 0;
FARPROC __imp_CreateCaret = 0;
FARPROC __imp_CreateIconIndirect = 0;
FARPROC __imp_CreatePopupMenu = 0;
FARPROC __imp_CreateWindowExA = 0;
FARPROC __imp_CreateWindowExW = 0;
FARPROC __imp_DefWindowProcA = 0;
FARPROC __imp_DestroyCaret = 0;
FARPROC __imp_DestroyCursor = 0;
FARPROC __imp_DestroyMenu = 0;
FARPROC __imp_DestroyWindow = 0;
FARPROC __imp_EmptyClipboard = 0;
FARPROC __imp_EndPaint = 0;
FARPROC __imp_FillRect = 0;
FARPROC __imp_FrameRect = 0;
FARPROC __imp_GetAncestor = 0;
FARPROC __imp_GetCaretBlinkTime = 0;
FARPROC __imp_GetClientRect = 0;
FARPROC __imp_GetClipboardData = 0;
FARPROC __imp_GetCursorPos = 0;
FARPROC __imp_GetDC = 0;
FARPROC __imp_GetDlgCtrlID = 0;
FARPROC __imp_GetDoubleClickTime = 0;
FARPROC __imp_GetKeyState = 0;
FARPROC __imp_GetKeyboardLayout = 0;
FARPROC __imp_GetMessageTime = 0;
FARPROC __imp_GetMonitorInfoA = 0;
FARPROC __imp_GetParent = 0;
FARPROC __imp_GetScrollInfo = 0;
FARPROC __imp_GetSysColor = 0;
FARPROC __imp_GetSystemMetrics = 0;
FARPROC __imp_GetUpdateRgn = 0;
FARPROC __imp_GetWindowLongA = 0;
FARPROC __imp_GetWindowLongPtrA = 0;
FARPROC __imp_GetWindowRect = 0;
FARPROC __imp_HideCaret = 0;
FARPROC __imp_InvalidateRect = 0;
FARPROC __imp_IsChild = 0;
FARPROC __imp_IsClipboardFormatAvailable = 0;
FARPROC __imp_KillTimer = 0;
FARPROC __imp_LoadCursorA = 0;
FARPROC __imp_MapWindowPoints = 0;
FARPROC __imp_MessageBoxA = 0;
FARPROC __imp_MonitorFromPoint = 0;
FARPROC __imp_MonitorFromRect = 0;
FARPROC __imp_MonitorFromWindow = 0;
FARPROC __imp_NotifyWinEvent = 0;
FARPROC __imp_OpenClipboard = 0;
FARPROC __imp_PostMessageA = 0;
FARPROC __imp_PtInRect = 0;
FARPROC __imp_RedrawWindow = 0;
FARPROC __imp_RegisterClassExA = 0;
FARPROC __imp_RegisterClassExW = 0;
FARPROC __imp_RegisterClipboardFormatW = 0;
FARPROC __imp_ReleaseCapture = 0;
FARPROC __imp_ReleaseDC = 0;
FARPROC __imp_ScreenToClient = 0;
FARPROC __imp_SendMessageA = 0;
FARPROC __imp_SetCapture = 0;
FARPROC __imp_SetCaretPos = 0;
FARPROC __imp_SetClipboardData = 0;
FARPROC __imp_SetCursor = 0;
FARPROC __imp_SetFocus = 0;
FARPROC __imp_SetScrollInfo = 0;
FARPROC __imp_SetTimer = 0;
FARPROC __imp_SetWindowLongPtrA = 0;
FARPROC __imp_SetWindowPos = 0;
FARPROC __imp_ShowCaret = 0;
FARPROC __imp_ShowWindow = 0;
FARPROC __imp_SystemParametersInfoA = 0;
FARPROC __imp_TrackMouseEvent = 0;
FARPROC __imp_TrackPopupMenu = 0;
FARPROC __imp_UnregisterClassA = 0;
FARPROC __imp_ValidateRect = 0;

/* gdi32 */
FARPROC __imp_BitBlt = 0;
FARPROC __imp_CombineRgn = 0;
FARPROC __imp_CreateBitmap = 0;
FARPROC __imp_CreateCompatibleBitmap = 0;
FARPROC __imp_CreateCompatibleDC = 0;
FARPROC __imp_CreateDIBSection = 0;
FARPROC __imp_CreateFontIndirectW = 0;
FARPROC __imp_CreatePatternBrush = 0;
FARPROC __imp_CreatePen = 0;
FARPROC __imp_CreateRectRgn = 0;
FARPROC __imp_CreateRectRgnIndirect = 0;
FARPROC __imp_CreateSolidBrush = 0;
FARPROC __imp_DeleteDC = 0;
FARPROC __imp_DeleteObject = 0;
FARPROC __imp_Ellipse = 0;
FARPROC __imp_ExtCreatePen = 0;
FARPROC __imp_ExtTextOutA = 0;
FARPROC __imp_ExtTextOutW = 0;
FARPROC __imp_GetDeviceCaps = 0;
FARPROC __imp_GetObjectW = 0;
FARPROC __imp_GetTextExtentExPointA = 0;
FARPROC __imp_GetTextExtentExPointW = 0;
FARPROC __imp_GetTextExtentPoint32A = 0;
FARPROC __imp_GetTextExtentPoint32W = 0;
FARPROC __imp_GetTextMetricsA = 0;
FARPROC __imp_IntersectClipRect = 0;
FARPROC __imp_LineTo = 0;
FARPROC __imp_MoveToEx = 0;
FARPROC __imp_Polygon = 0;
FARPROC __imp_Polyline = 0;
FARPROC __imp_RestoreDC = 0;
FARPROC __imp_RoundRect = 0;
FARPROC __imp_SaveDC = 0;
FARPROC __imp_SelectObject = 0;
FARPROC __imp_SetBkColor = 0;
FARPROC __imp_SetBkMode = 0;
FARPROC __imp_SetTextAlign = 0;
FARPROC __imp_SetTextColor = 0;

/* msimg32 */
FARPROC __imp_GdiAlphaBlend = 0;

/* ole32 */
FARPROC __imp_CLSIDFromProgID = 0;
FARPROC __imp_CoCreateInstance = 0;
FARPROC __imp_DoDragDrop = 0;
FARPROC __imp_OleInitialize = 0;
FARPROC __imp_OleUninitialize = 0;
FARPROC __imp_RegisterDragDrop = 0;
FARPROC __imp_ReleaseStgMedium = 0;
FARPROC __imp_RevokeDragDrop = 0;

/* oleaut32 */
FARPROC __imp_SysAllocStringLen = 0;
FARPROC __imp_SysFreeString = 0;

/* advapi32 */
FARPROC __imp_RegCloseKey = 0;
FARPROC __imp_RegOpenKeyExW = 0;
FARPROC __imp_RegQueryValueExW = 0;


/* Linker pseudo-symbol */
unsigned char __ImageBase = 0;

/* CRT concurrency stubs */
void __cdecl _Cnd_register_at_thread_exit(void *p) { (void)p; }
void __cdecl _Cnd_unregister_at_thread_exit(void *p) { (void)p; }

/* IMM function thunks resolved at init */
static FARPROC s_ImmEscapeW = 0;
static FARPROC s_ImmGetCompositionStringW = 0;
static FARPROC s_ImmGetContext = 0;
static FARPROC s_ImmNotifyIME = 0;
static FARPROC s_ImmReleaseContext = 0;
static FARPROC s_ImmSetCandidateWindow = 0;
static FARPROC s_ImmSetCompositionFontW = 0;
static FARPROC s_ImmSetCompositionStringW = 0;
static FARPROC s_ImmSetCompositionWindow = 0;

__int64 __stdcall ImmEscapeW(__int64 a, __int64 b, __int64 c, __int64 d) {
    typedef __int64 (__stdcall *fn_t)(__int64,__int64,__int64,__int64);
    return ((fn_t)s_ImmEscapeW)(a,b,c,d);
}
__int64 __stdcall ImmGetCompositionStringW(__int64 a, __int64 b, __int64 c, __int64 d) {
    typedef __int64 (__stdcall *fn_t)(__int64,__int64,__int64,__int64);
    return ((fn_t)s_ImmGetCompositionStringW)(a,b,c,d);
}
__int64 __stdcall ImmGetContext(__int64 a, __int64 b, __int64 c, __int64 d) {
    typedef __int64 (__stdcall *fn_t)(__int64,__int64,__int64,__int64);
    return ((fn_t)s_ImmGetContext)(a,b,c,d);
}
__int64 __stdcall ImmNotifyIME(__int64 a, __int64 b, __int64 c, __int64 d) {
    typedef __int64 (__stdcall *fn_t)(__int64,__int64,__int64,__int64);
    return ((fn_t)s_ImmNotifyIME)(a,b,c,d);
}
__int64 __stdcall ImmReleaseContext(__int64 a, __int64 b, __int64 c, __int64 d) {
    typedef __int64 (__stdcall *fn_t)(__int64,__int64,__int64,__int64);
    return ((fn_t)s_ImmReleaseContext)(a,b,c,d);
}
__int64 __stdcall ImmSetCandidateWindow(__int64 a, __int64 b, __int64 c, __int64 d) {
    typedef __int64 (__stdcall *fn_t)(__int64,__int64,__int64,__int64);
    return ((fn_t)s_ImmSetCandidateWindow)(a,b,c,d);
}
__int64 __stdcall ImmSetCompositionFontW(__int64 a, __int64 b, __int64 c, __int64 d) {
    typedef __int64 (__stdcall *fn_t)(__int64,__int64,__int64,__int64);
    return ((fn_t)s_ImmSetCompositionFontW)(a,b,c,d);
}
__int64 __stdcall ImmSetCompositionStringW(__int64 a, __int64 b, __int64 c, __int64 d) {
    typedef __int64 (__stdcall *fn_t)(__int64,__int64,__int64,__int64);
    return ((fn_t)s_ImmSetCompositionStringW)(a,b,c,d);
}
__int64 __stdcall ImmSetCompositionWindow(__int64 a, __int64 b, __int64 c, __int64 d) {
    typedef __int64 (__stdcall *fn_t)(__int64,__int64,__int64,__int64);
    return ((fn_t)s_ImmSetCompositionWindow)(a,b,c,d);
}

/* ---- initialization ---- */

void __cdecl SciBridge_ResolveImports(
    PFN_GetModuleHandle pGMH,
    PFN_GetProcAddress  pGPA)
{
    HMODULE h_kernel32 = pGMH("kernel32.dll");
    HMODULE h_user32 = pGMH("user32.dll");
    HMODULE h_gdi32 = pGMH("gdi32.dll");
    HMODULE h_msimg32 = pGMH("msimg32.dll");
    HMODULE h_ole32 = pGMH("ole32.dll");
    HMODULE h_oleaut32 = pGMH("oleaut32.dll");
    HMODULE h_advapi32 = pGMH("advapi32.dll");

    __imp_RegCloseKey = pGPA(h_advapi32, "RegCloseKey");
    __imp_RegOpenKeyExW = pGPA(h_advapi32, "RegOpenKeyExW");
    __imp_RegQueryValueExW = pGPA(h_advapi32, "RegQueryValueExW");
    __imp_BitBlt = pGPA(h_gdi32, "BitBlt");
    __imp_CombineRgn = pGPA(h_gdi32, "CombineRgn");
    __imp_CreateBitmap = pGPA(h_gdi32, "CreateBitmap");
    __imp_CreateCompatibleBitmap = pGPA(h_gdi32, "CreateCompatibleBitmap");
    __imp_CreateCompatibleDC = pGPA(h_gdi32, "CreateCompatibleDC");
    __imp_CreateDIBSection = pGPA(h_gdi32, "CreateDIBSection");
    __imp_CreateFontIndirectW = pGPA(h_gdi32, "CreateFontIndirectW");
    __imp_CreatePatternBrush = pGPA(h_gdi32, "CreatePatternBrush");
    __imp_CreatePen = pGPA(h_gdi32, "CreatePen");
    __imp_CreateRectRgn = pGPA(h_gdi32, "CreateRectRgn");
    __imp_CreateRectRgnIndirect = pGPA(h_gdi32, "CreateRectRgnIndirect");
    __imp_CreateSolidBrush = pGPA(h_gdi32, "CreateSolidBrush");
    __imp_DeleteDC = pGPA(h_gdi32, "DeleteDC");
    __imp_DeleteObject = pGPA(h_gdi32, "DeleteObject");
    __imp_Ellipse = pGPA(h_gdi32, "Ellipse");
    __imp_ExtCreatePen = pGPA(h_gdi32, "ExtCreatePen");
    __imp_ExtTextOutA = pGPA(h_gdi32, "ExtTextOutA");
    __imp_ExtTextOutW = pGPA(h_gdi32, "ExtTextOutW");
    __imp_GetDeviceCaps = pGPA(h_gdi32, "GetDeviceCaps");
    __imp_GetObjectW = pGPA(h_gdi32, "GetObjectW");
    __imp_GetTextExtentExPointA = pGPA(h_gdi32, "GetTextExtentExPointA");
    __imp_GetTextExtentExPointW = pGPA(h_gdi32, "GetTextExtentExPointW");
    __imp_GetTextExtentPoint32A = pGPA(h_gdi32, "GetTextExtentPoint32A");
    __imp_GetTextExtentPoint32W = pGPA(h_gdi32, "GetTextExtentPoint32W");
    __imp_GetTextMetricsA = pGPA(h_gdi32, "GetTextMetricsA");
    __imp_IntersectClipRect = pGPA(h_gdi32, "IntersectClipRect");
    __imp_LineTo = pGPA(h_gdi32, "LineTo");
    __imp_MoveToEx = pGPA(h_gdi32, "MoveToEx");
    __imp_Polygon = pGPA(h_gdi32, "Polygon");
    __imp_Polyline = pGPA(h_gdi32, "Polyline");
    __imp_RestoreDC = pGPA(h_gdi32, "RestoreDC");
    __imp_RoundRect = pGPA(h_gdi32, "RoundRect");
    __imp_SaveDC = pGPA(h_gdi32, "SaveDC");
    __imp_SelectObject = pGPA(h_gdi32, "SelectObject");
    __imp_SetBkColor = pGPA(h_gdi32, "SetBkColor");
    __imp_SetBkMode = pGPA(h_gdi32, "SetBkMode");
    __imp_SetTextAlign = pGPA(h_gdi32, "SetTextAlign");
    __imp_SetTextColor = pGPA(h_gdi32, "SetTextColor");
    __imp_AcquireSRWLockExclusive = pGPA(h_kernel32, "AcquireSRWLockExclusive");
    __imp_DebugBreak = pGPA(h_kernel32, "DebugBreak");
    __imp_FreeLibrary = pGPA(h_kernel32, "FreeLibrary");
    __imp_GetCurrentProcess = pGPA(h_kernel32, "GetCurrentProcess");
    __imp_GetCurrentThreadId = pGPA(h_kernel32, "GetCurrentThreadId");
    __imp_GetLocaleInfoA = pGPA(h_kernel32, "GetLocaleInfoA");
    __imp_GetModuleHandleA = pGPA(h_kernel32, "GetModuleHandleA");
    __imp_GetModuleHandleW = pGPA(h_kernel32, "GetModuleHandleW");
    __imp_GetProcAddress = pGPA(h_kernel32, "GetProcAddress");
    __imp_GetProcessHeap = pGPA(h_kernel32, "GetProcessHeap");
    __imp_GetSystemInfo = pGPA(h_kernel32, "GetSystemInfo");
    __imp_GetSystemTimeAsFileTime = pGPA(h_kernel32, "GetSystemTimeAsFileTime");
    __imp_GetTickCount = pGPA(h_kernel32, "GetTickCount");
    __imp_GlobalAlloc = pGPA(h_kernel32, "GlobalAlloc");
    __imp_GlobalLock = pGPA(h_kernel32, "GlobalLock");
    __imp_GlobalSize = pGPA(h_kernel32, "GlobalSize");
    __imp_GlobalUnlock = pGPA(h_kernel32, "GlobalUnlock");
    __imp_HeapAlloc = pGPA(h_kernel32, "HeapAlloc");
    __imp_HeapFree = pGPA(h_kernel32, "HeapFree");
    __imp_HeapReAlloc = pGPA(h_kernel32, "HeapReAlloc");
    __imp_InitializeConditionVariable = pGPA(h_kernel32, "InitializeConditionVariable");
    __imp_InitializeSRWLock = pGPA(h_kernel32, "InitializeSRWLock");
    __imp_LCMapStringW = pGPA(h_kernel32, "LCMapStringW");
    __imp_LoadLibraryExA = pGPA(h_kernel32, "LoadLibraryExA");
    __imp_LoadLibraryExW = pGPA(h_kernel32, "LoadLibraryExW");
    __imp_MsgWaitForMultipleObjects = pGPA(h_kernel32, "MsgWaitForMultipleObjects");
    __imp_MulDiv = pGPA(h_kernel32, "MulDiv");
    __imp_MultiByteToWideChar = pGPA(h_kernel32, "MultiByteToWideChar");
    __imp_OutputDebugStringA = pGPA(h_kernel32, "OutputDebugStringA");
    __imp_QueryPerformanceCounter = pGPA(h_kernel32, "QueryPerformanceCounter");
    __imp_QueryPerformanceFrequency = pGPA(h_kernel32, "QueryPerformanceFrequency");
    __imp_ReleaseSRWLockExclusive = pGPA(h_kernel32, "ReleaseSRWLockExclusive");
    __imp_Sleep = pGPA(h_kernel32, "Sleep");
    __imp_SleepConditionVariableSRW = pGPA(h_kernel32, "SleepConditionVariableSRW");
    __imp_TerminateProcess = pGPA(h_kernel32, "TerminateProcess");
    __imp_TryAcquireSRWLockExclusive = pGPA(h_kernel32, "TryAcquireSRWLockExclusive");
    __imp_WakeAllConditionVariable = pGPA(h_kernel32, "WakeAllConditionVariable");
    __imp_WakeConditionVariable = pGPA(h_kernel32, "WakeConditionVariable");
    __imp_WideCharToMultiByte = pGPA(h_kernel32, "WideCharToMultiByte");
    __imp___std_init_once_begin_initialize = pGPA(h_kernel32, "InitOnceBeginInitialize");
    __imp___std_init_once_begin_initialize = pGPA(h_kernel32, "InitOnceBeginInitialize");
    __imp___std_init_once_complete = pGPA(h_kernel32, "InitOnceComplete");
    __imp___std_init_once_complete = pGPA(h_kernel32, "InitOnceComplete");
    __imp_GdiAlphaBlend = pGPA(h_msimg32, "GdiAlphaBlend");
    __imp_CLSIDFromProgID = pGPA(h_ole32, "CLSIDFromProgID");
    __imp_CoCreateInstance = pGPA(h_ole32, "CoCreateInstance");
    __imp_DoDragDrop = pGPA(h_ole32, "DoDragDrop");
    __imp_OleInitialize = pGPA(h_ole32, "OleInitialize");
    __imp_OleUninitialize = pGPA(h_ole32, "OleUninitialize");
    __imp_RegisterDragDrop = pGPA(h_ole32, "RegisterDragDrop");
    __imp_ReleaseStgMedium = pGPA(h_ole32, "ReleaseStgMedium");
    __imp_RevokeDragDrop = pGPA(h_ole32, "RevokeDragDrop");
    __imp_SysAllocStringLen = pGPA(h_oleaut32, "SysAllocStringLen");
    __imp_SysFreeString = pGPA(h_oleaut32, "SysFreeString");
    __imp_AdjustWindowRectEx = pGPA(h_user32, "AdjustWindowRectEx");
    __imp_AppendMenuA = pGPA(h_user32, "AppendMenuA");
    __imp_BeginPaint = pGPA(h_user32, "BeginPaint");
    __imp_CallWindowProcA = pGPA(h_user32, "CallWindowProcA");
    __imp_ClientToScreen = pGPA(h_user32, "ClientToScreen");
    __imp_CloseClipboard = pGPA(h_user32, "CloseClipboard");
    __imp_CreateCaret = pGPA(h_user32, "CreateCaret");
    __imp_CreateIconIndirect = pGPA(h_user32, "CreateIconIndirect");
    __imp_CreatePopupMenu = pGPA(h_user32, "CreatePopupMenu");
    __imp_CreateWindowExA = pGPA(h_user32, "CreateWindowExA");
    __imp_CreateWindowExW = pGPA(h_user32, "CreateWindowExW");
    __imp_DefWindowProcA = pGPA(h_user32, "DefWindowProcA");
    __imp_DestroyCaret = pGPA(h_user32, "DestroyCaret");
    __imp_DestroyCursor = pGPA(h_user32, "DestroyCursor");
    __imp_DestroyMenu = pGPA(h_user32, "DestroyMenu");
    __imp_DestroyWindow = pGPA(h_user32, "DestroyWindow");
    __imp_EmptyClipboard = pGPA(h_user32, "EmptyClipboard");
    __imp_EndPaint = pGPA(h_user32, "EndPaint");
    __imp_FillRect = pGPA(h_user32, "FillRect");
    __imp_FrameRect = pGPA(h_user32, "FrameRect");
    __imp_GetAncestor = pGPA(h_user32, "GetAncestor");
    __imp_GetCaretBlinkTime = pGPA(h_user32, "GetCaretBlinkTime");
    __imp_GetClientRect = pGPA(h_user32, "GetClientRect");
    __imp_GetClipboardData = pGPA(h_user32, "GetClipboardData");
    __imp_GetCursorPos = pGPA(h_user32, "GetCursorPos");
    __imp_GetDC = pGPA(h_user32, "GetDC");
    __imp_GetDlgCtrlID = pGPA(h_user32, "GetDlgCtrlID");
    __imp_GetDoubleClickTime = pGPA(h_user32, "GetDoubleClickTime");
    __imp_GetKeyState = pGPA(h_user32, "GetKeyState");
    __imp_GetKeyboardLayout = pGPA(h_user32, "GetKeyboardLayout");
    __imp_GetMessageTime = pGPA(h_user32, "GetMessageTime");
    __imp_GetMonitorInfoA = pGPA(h_user32, "GetMonitorInfoA");
    __imp_GetParent = pGPA(h_user32, "GetParent");
    __imp_GetScrollInfo = pGPA(h_user32, "GetScrollInfo");
    __imp_GetSysColor = pGPA(h_user32, "GetSysColor");
    __imp_GetSystemMetrics = pGPA(h_user32, "GetSystemMetrics");
    __imp_GetUpdateRgn = pGPA(h_user32, "GetUpdateRgn");
    __imp_GetWindowLongA = pGPA(h_user32, "GetWindowLongA");
    __imp_GetWindowLongPtrA = pGPA(h_user32, "GetWindowLongPtrA");
    __imp_GetWindowRect = pGPA(h_user32, "GetWindowRect");
    __imp_HideCaret = pGPA(h_user32, "HideCaret");
    __imp_InvalidateRect = pGPA(h_user32, "InvalidateRect");
    __imp_IsChild = pGPA(h_user32, "IsChild");
    __imp_IsClipboardFormatAvailable = pGPA(h_user32, "IsClipboardFormatAvailable");
    __imp_KillTimer = pGPA(h_user32, "KillTimer");
    __imp_LoadCursorA = pGPA(h_user32, "LoadCursorA");
    __imp_MapWindowPoints = pGPA(h_user32, "MapWindowPoints");
    __imp_MessageBoxA = pGPA(h_user32, "MessageBoxA");
    __imp_MonitorFromPoint = pGPA(h_user32, "MonitorFromPoint");
    __imp_MonitorFromRect = pGPA(h_user32, "MonitorFromRect");
    __imp_MonitorFromWindow = pGPA(h_user32, "MonitorFromWindow");
    __imp_NotifyWinEvent = pGPA(h_user32, "NotifyWinEvent");
    __imp_OpenClipboard = pGPA(h_user32, "OpenClipboard");
    __imp_PostMessageA = pGPA(h_user32, "PostMessageA");
    __imp_PtInRect = pGPA(h_user32, "PtInRect");
    __imp_RedrawWindow = pGPA(h_user32, "RedrawWindow");
    __imp_RegisterClassExA = pGPA(h_user32, "RegisterClassExA");
    __imp_RegisterClassExW = pGPA(h_user32, "RegisterClassExW");
    __imp_RegisterClipboardFormatW = pGPA(h_user32, "RegisterClipboardFormatW");
    __imp_ReleaseCapture = pGPA(h_user32, "ReleaseCapture");
    __imp_ReleaseDC = pGPA(h_user32, "ReleaseDC");
    __imp_ScreenToClient = pGPA(h_user32, "ScreenToClient");
    __imp_SendMessageA = pGPA(h_user32, "SendMessageA");
    __imp_SetCapture = pGPA(h_user32, "SetCapture");
    __imp_SetCaretPos = pGPA(h_user32, "SetCaretPos");
    __imp_SetClipboardData = pGPA(h_user32, "SetClipboardData");
    __imp_SetCursor = pGPA(h_user32, "SetCursor");
    __imp_SetFocus = pGPA(h_user32, "SetFocus");
    __imp_SetScrollInfo = pGPA(h_user32, "SetScrollInfo");
    __imp_SetTimer = pGPA(h_user32, "SetTimer");
    __imp_SetWindowLongPtrA = pGPA(h_user32, "SetWindowLongPtrA");
    __imp_SetWindowPos = pGPA(h_user32, "SetWindowPos");
    __imp_ShowCaret = pGPA(h_user32, "ShowCaret");
    __imp_ShowWindow = pGPA(h_user32, "ShowWindow");
    __imp_SystemParametersInfoA = pGPA(h_user32, "SystemParametersInfoA");
    __imp_TrackMouseEvent = pGPA(h_user32, "TrackMouseEvent");
    __imp_TrackPopupMenu = pGPA(h_user32, "TrackPopupMenu");
    __imp_UnregisterClassA = pGPA(h_user32, "UnregisterClassA");
    __imp_ValidateRect = pGPA(h_user32, "ValidateRect");

    {
        HMODULE h_imm = pGMH("imm32.dll");
        if (!h_imm) {
            typedef HMODULE (__stdcall *PFN_LL)(const char *, HMODULE, unsigned);
            PFN_LL pLoadLib = (PFN_LL)pGPA(h_kernel32, "LoadLibraryExA");
            if (pLoadLib) h_imm = pLoadLib("imm32.dll", 0, 0);
        }
        if (h_imm) {
            s_ImmEscapeW = pGPA(h_imm, "ImmEscapeW");
            s_ImmGetCompositionStringW = pGPA(h_imm, "ImmGetCompositionStringW");
            s_ImmGetContext = pGPA(h_imm, "ImmGetContext");
            s_ImmNotifyIME = pGPA(h_imm, "ImmNotifyIME");
            s_ImmReleaseContext = pGPA(h_imm, "ImmReleaseContext");
            s_ImmSetCandidateWindow = pGPA(h_imm, "ImmSetCandidateWindow");
            s_ImmSetCompositionFontW = pGPA(h_imm, "ImmSetCompositionFontW");
            s_ImmSetCompositionStringW = pGPA(h_imm, "ImmSetCompositionStringW");
            s_ImmSetCompositionWindow = pGPA(h_imm, "ImmSetCompositionWindow");
        }
    }
}
