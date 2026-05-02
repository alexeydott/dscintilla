/*
 * sci_winapi_patches.h — GENERATED — do not edit by hand.
 * Regenerate with:  python c_src/gen_winapi_patch.py
 * Win32 IAT patch table for SciBridge_PatchImports().
 * Each entry maps a __imp__ slot (unpatched by PE loader) to its
 * DLL and exported function name so Delphi can patch them at startup.
 */
#pragma once

/* ---------- extern declarations using GCC/Clang __asm__ alias ---------- */

extern void* imp___iob_func __asm__("__imp____iob_func");
extern void* imp___p___mb_cur_max __asm__("__imp____p___mb_cur_max");
extern void* imp___p__pctype __asm__("__imp____p__pctype");
extern void* imp__assert __asm__("__imp___assert");
extern void* imp__beginthreadex __asm__("__imp___beginthreadex");
extern void* imp__endthreadex __asm__("__imp___endthreadex");
extern void* imp__errno __asm__("__imp___errno");
extern void* imp__isctype_l __asm__("__imp___isctype_l");
extern void* imp__iswalpha_l __asm__("__imp___iswalpha_l");
extern void* imp__iswcntrl_l __asm__("__imp___iswcntrl_l");
extern void* imp__iswdigit_l __asm__("__imp___iswdigit_l");
extern void* imp__iswlower_l __asm__("__imp___iswlower_l");
extern void* imp__iswprint_l __asm__("__imp___iswprint_l");
extern void* imp__iswpunct_l __asm__("__imp___iswpunct_l");
extern void* imp__iswspace_l __asm__("__imp___iswspace_l");
extern void* imp__iswupper_l __asm__("__imp___iswupper_l");
extern void* imp__iswxdigit_l __asm__("__imp___iswxdigit_l");
extern void* imp__lock __asm__("__imp___lock");
extern void* imp__mbtowc_l __asm__("__imp___mbtowc_l");
extern void* imp__sscanf_l __asm__("__imp___sscanf_l");
extern void* imp__strcoll_l __asm__("__imp___strcoll_l");
extern void* imp__strdup __asm__("__imp___strdup");
extern void* imp__strtod_l __asm__("__imp___strtod_l");
extern void* imp__strtoi64_l __asm__("__imp___strtoi64_l");
extern void* imp__strtoui64_l __asm__("__imp___strtoui64_l");
extern void* imp__strxfrm_l __asm__("__imp___strxfrm_l");
extern void* imp__sys_nerr __asm__("__imp___sys_nerr");
extern void* imp__tolower_l __asm__("__imp___tolower_l");
extern void* imp__toupper_l __asm__("__imp___toupper_l");
extern void* imp__towlower_l __asm__("__imp___towlower_l");
extern void* imp__towupper_l __asm__("__imp___towupper_l");
extern void* imp__unlock __asm__("__imp___unlock");
extern void* imp__vsnprintf __asm__("__imp___vsnprintf");
extern void* imp__wcscoll_l __asm__("__imp___wcscoll_l");
extern void* imp__wcsxfrm_l __asm__("__imp___wcsxfrm_l");
extern void* imp_abort __asm__("__imp__abort");
extern void* imp_AcquireSRWLockExclusive __asm__("__imp__AcquireSRWLockExclusive@4");
extern void* imp_AdjustWindowRectEx __asm__("__imp__AdjustWindowRectEx@16");
extern void* imp_AppendMenuA __asm__("__imp__AppendMenuA@16");
extern void* imp_atoi __asm__("__imp__atoi");
extern void* imp_BeginPaint __asm__("__imp__BeginPaint@8");
extern void* imp_BitBlt __asm__("__imp__BitBlt@36");
extern void* imp_calloc __asm__("__imp__calloc");
extern void* imp_CallWindowProcA __asm__("__imp__CallWindowProcA@20");
extern void* imp_ClientToScreen __asm__("__imp__ClientToScreen@8");
extern void* imp_CloseClipboard __asm__("__imp__CloseClipboard@0");
extern void* imp_CloseHandle __asm__("__imp__CloseHandle@4");
extern void* imp_CLSIDFromProgID __asm__("__imp__CLSIDFromProgID@8");
extern void* imp_CoCreateInstance __asm__("__imp__CoCreateInstance@20");
extern void* imp_CombineRgn __asm__("__imp__CombineRgn@16");
extern void* imp_CreateBitmap __asm__("__imp__CreateBitmap@20");
extern void* imp_CreateCaret __asm__("__imp__CreateCaret@16");
extern void* imp_CreateCompatibleBitmap __asm__("__imp__CreateCompatibleBitmap@12");
extern void* imp_CreateCompatibleDC __asm__("__imp__CreateCompatibleDC@4");
extern void* imp_CreateDIBSection __asm__("__imp__CreateDIBSection@24");
extern void* imp_CreateEventA __asm__("__imp__CreateEventA@16");
extern void* imp_CreateFontIndirectW __asm__("__imp__CreateFontIndirectW@4");
extern void* imp_CreateIconIndirect __asm__("__imp__CreateIconIndirect@4");
extern void* imp_CreatePatternBrush __asm__("__imp__CreatePatternBrush@4");
extern void* imp_CreatePen __asm__("__imp__CreatePen@12");
extern void* imp_CreatePopupMenu __asm__("__imp__CreatePopupMenu@0");
extern void* imp_CreateRectRgn __asm__("__imp__CreateRectRgn@16");
extern void* imp_CreateRectRgnIndirect __asm__("__imp__CreateRectRgnIndirect@4");
extern void* imp_CreateSemaphoreA __asm__("__imp__CreateSemaphoreA@16");
extern void* imp_CreateSolidBrush __asm__("__imp__CreateSolidBrush@4");
extern void* imp_CreateWindowExA __asm__("__imp__CreateWindowExA@48");
extern void* imp_CreateWindowExW __asm__("__imp__CreateWindowExW@48");
extern void* imp_DebugBreak __asm__("__imp__DebugBreak@0");
extern void* imp_DefWindowProcA __asm__("__imp__DefWindowProcA@16");
extern void* imp_DeleteCriticalSection __asm__("__imp__DeleteCriticalSection@4");
extern void* imp_DeleteDC __asm__("__imp__DeleteDC@4");
extern void* imp_DeleteObject __asm__("__imp__DeleteObject@4");
extern void* imp_DestroyCaret __asm__("__imp__DestroyCaret@0");
extern void* imp_DestroyCursor __asm__("__imp__DestroyCursor@4");
extern void* imp_DestroyMenu __asm__("__imp__DestroyMenu@4");
extern void* imp_DestroyWindow __asm__("__imp__DestroyWindow@4");
extern void* imp_DoDragDrop __asm__("__imp__DoDragDrop@16");
extern void* imp_DuplicateHandle __asm__("__imp__DuplicateHandle@28");
extern void* imp_Ellipse __asm__("__imp__Ellipse@20");
extern void* imp_EmptyClipboard __asm__("__imp__EmptyClipboard@0");
extern void* imp_EndPaint __asm__("__imp__EndPaint@8");
extern void* imp_EnterCriticalSection __asm__("__imp__EnterCriticalSection@4");
extern void* imp_ExtCreatePen __asm__("__imp__ExtCreatePen@20");
extern void* imp_ExtTextOutA __asm__("__imp__ExtTextOutA@32");
extern void* imp_ExtTextOutW __asm__("__imp__ExtTextOutW@32");
extern void* imp_FillRect __asm__("__imp__FillRect@12");
extern void* imp_FlsAlloc __asm__("__imp__FlsAlloc@4");
extern void* imp_FlsGetValue __asm__("__imp__FlsGetValue@4");
extern void* imp_FlsSetValue __asm__("__imp__FlsSetValue@8");
extern void* imp_FormatMessageA __asm__("__imp__FormatMessageA@28");
extern void* imp_fprintf __asm__("__imp__fprintf");
extern void* imp_fputc __asm__("__imp__fputc");
extern void* imp_fputwc __asm__("__imp__fputwc");
extern void* imp_FrameRect __asm__("__imp__FrameRect@12");
extern void* imp_free __asm__("__imp__free");
extern void* imp_FreeLibrary __asm__("__imp__FreeLibrary@4");
extern void* imp_GdiAlphaBlend __asm__("__imp__GdiAlphaBlend@44");
extern void* imp_GetAncestor __asm__("__imp__GetAncestor@8");
extern void* imp_getc __asm__("__imp__getc");
extern void* imp_GetCaretBlinkTime __asm__("__imp__GetCaretBlinkTime@0");
extern void* imp_GetClientRect __asm__("__imp__GetClientRect@8");
extern void* imp_GetClipboardData __asm__("__imp__GetClipboardData@4");
extern void* imp_GetCurrentProcess __asm__("__imp__GetCurrentProcess@0");
extern void* imp_GetCurrentProcessId __asm__("__imp__GetCurrentProcessId@0");
extern void* imp_GetCurrentThread __asm__("__imp__GetCurrentThread@0");
extern void* imp_GetCurrentThreadId __asm__("__imp__GetCurrentThreadId@0");
extern void* imp_GetCursorPos __asm__("__imp__GetCursorPos@4");
extern void* imp_GetDC __asm__("__imp__GetDC@4");
extern void* imp_GetDeviceCaps __asm__("__imp__GetDeviceCaps@8");
extern void* imp_GetDlgCtrlID __asm__("__imp__GetDlgCtrlID@4");
extern void* imp_GetDoubleClickTime __asm__("__imp__GetDoubleClickTime@0");
extern void* imp_GetHandleInformation __asm__("__imp__GetHandleInformation@8");
extern void* imp_GetKeyboardLayout __asm__("__imp__GetKeyboardLayout@4");
extern void* imp_GetKeyState __asm__("__imp__GetKeyState@4");
extern void* imp_GetLastError __asm__("__imp__GetLastError@0");
extern void* imp_GetLocaleInfoA __asm__("__imp__GetLocaleInfoA@16");
extern void* imp_GetMessageTime __asm__("__imp__GetMessageTime@0");
extern void* imp_GetModuleHandleA __asm__("__imp__GetModuleHandleA@4");
extern void* imp_GetModuleHandleW __asm__("__imp__GetModuleHandleW@4");
extern void* imp_GetMonitorInfoA __asm__("__imp__GetMonitorInfoA@8");
extern void* imp_GetObjectW __asm__("__imp__GetObjectW@12");
extern void* imp_GetParent __asm__("__imp__GetParent@4");
extern void* imp_GetProcAddress __asm__("__imp__GetProcAddress@8");
extern void* imp_GetProcessAffinityMask __asm__("__imp__GetProcessAffinityMask@12");
extern void* imp_GetScrollInfo __asm__("__imp__GetScrollInfo@12");
extern void* imp_GetSysColor __asm__("__imp__GetSysColor@4");
extern void* imp_GetSystemInfo __asm__("__imp__GetSystemInfo@4");
extern void* imp_GetSystemMetrics __asm__("__imp__GetSystemMetrics@4");
extern void* imp_GetSystemTimeAsFileTime __asm__("__imp__GetSystemTimeAsFileTime@4");
extern void* imp_GetTextExtentExPointA __asm__("__imp__GetTextExtentExPointA@28");
extern void* imp_GetTextExtentExPointW __asm__("__imp__GetTextExtentExPointW@28");
extern void* imp_GetTextExtentPoint32A __asm__("__imp__GetTextExtentPoint32A@16");
extern void* imp_GetTextExtentPoint32W __asm__("__imp__GetTextExtentPoint32W@16");
extern void* imp_GetTextMetricsA __asm__("__imp__GetTextMetricsA@8");
extern void* imp_GetThreadContext __asm__("__imp__GetThreadContext@8");
extern void* imp_GetThreadId __asm__("__imp__GetThreadId@4");
extern void* imp_GetThreadPriority __asm__("__imp__GetThreadPriority@4");
extern void* imp_GetTickCount __asm__("__imp__GetTickCount@0");
extern void* imp_GetUpdateRgn __asm__("__imp__GetUpdateRgn@12");
extern void* imp_GetWindowLongA __asm__("__imp__GetWindowLongA@8");
extern void* imp_GetWindowRect __asm__("__imp__GetWindowRect@8");
extern void* imp_GlobalAlloc __asm__("__imp__GlobalAlloc@8");
extern void* imp_GlobalLock __asm__("__imp__GlobalLock@4");
extern void* imp_GlobalSize __asm__("__imp__GlobalSize@4");
extern void* imp_GlobalUnlock __asm__("__imp__GlobalUnlock@4");
extern void* imp_HideCaret __asm__("__imp__HideCaret@4");
extern void* imp_ImmEscapeW __asm__("__imp__ImmEscapeW@16");
extern void* imp_ImmGetCompositionStringW __asm__("__imp__ImmGetCompositionStringW@16");
extern void* imp_ImmGetContext __asm__("__imp__ImmGetContext@4");
extern void* imp_ImmNotifyIME __asm__("__imp__ImmNotifyIME@16");
extern void* imp_ImmReleaseContext __asm__("__imp__ImmReleaseContext@8");
extern void* imp_ImmSetCandidateWindow __asm__("__imp__ImmSetCandidateWindow@8");
extern void* imp_ImmSetCompositionFontW __asm__("__imp__ImmSetCompositionFontW@8");
extern void* imp_ImmSetCompositionStringW __asm__("__imp__ImmSetCompositionStringW@24");
extern void* imp_ImmSetCompositionWindow __asm__("__imp__ImmSetCompositionWindow@8");
extern void* imp_InitializeCriticalSection __asm__("__imp__InitializeCriticalSection@4");
extern void* imp_InitOnceExecuteOnce __asm__("__imp__InitOnceExecuteOnce@16");
extern void* imp_IntersectClipRect __asm__("__imp__IntersectClipRect@20");
extern void* imp_InvalidateRect __asm__("__imp__InvalidateRect@12");
extern void* imp_isalnum __asm__("__imp__isalnum");
extern void* imp_isalpha __asm__("__imp__isalpha");
extern void* imp_IsChild __asm__("__imp__IsChild@8");
extern void* imp_IsClipboardFormatAvailable __asm__("__imp__IsClipboardFormatAvailable@4");
extern void* imp_IsDBCSLeadByteEx __asm__("__imp__IsDBCSLeadByteEx@8");
extern void* imp_IsDebuggerPresent __asm__("__imp__IsDebuggerPresent@0");
extern void* imp_isdigit __asm__("__imp__isdigit");
extern void* imp_isgraph __asm__("__imp__isgraph");
extern void* imp_islower __asm__("__imp__islower");
extern void* imp_IsProcessorFeaturePresent __asm__("__imp__IsProcessorFeaturePresent@4");
extern void* imp_ispunct __asm__("__imp__ispunct");
extern void* imp_isspace __asm__("__imp__isspace");
extern void* imp_isupper __asm__("__imp__isupper");
extern void* imp_iswctype __asm__("__imp__iswctype");
extern void* imp_isxdigit __asm__("__imp__isxdigit");
extern void* imp_KillTimer __asm__("__imp__KillTimer@8");
extern void* imp_LCMapStringW __asm__("__imp__LCMapStringW@24");
extern void* imp_LeaveCriticalSection __asm__("__imp__LeaveCriticalSection@4");
extern void* imp_LineTo __asm__("__imp__LineTo@12");
extern void* imp_LoadCursorA __asm__("__imp__LoadCursorA@8");
extern void* imp_LoadLibraryExA __asm__("__imp__LoadLibraryExA@12");
extern void* imp_LoadLibraryExW __asm__("__imp__LoadLibraryExW@12");
extern void* imp_LoadLibraryW __asm__("__imp__LoadLibraryW@4");
extern void* imp_localeconv __asm__("__imp__localeconv");
extern void* imp_LocalFree __asm__("__imp__LocalFree@4");
extern void* imp_longjmp __asm__("__imp__longjmp");
extern void* imp_malloc __asm__("__imp__malloc");
extern void* imp_MapWindowPoints __asm__("__imp__MapWindowPoints@16");
extern void* imp_memchr __asm__("__imp__memchr");
extern void* imp_memcmp __asm__("__imp__memcmp");
extern void* imp_memcpy __asm__("__imp__memcpy");
extern void* imp_memmove __asm__("__imp__memmove");
extern void* imp_memset __asm__("__imp__memset");
extern void* imp_MessageBoxA __asm__("__imp__MessageBoxA@16");
extern void* imp_MonitorFromPoint __asm__("__imp__MonitorFromPoint@12");
extern void* imp_MonitorFromRect __asm__("__imp__MonitorFromRect@8");
extern void* imp_MonitorFromWindow __asm__("__imp__MonitorFromWindow@8");
extern void* imp_MoveToEx __asm__("__imp__MoveToEx@16");
extern void* imp_MsgWaitForMultipleObjects __asm__("__imp__MsgWaitForMultipleObjects@20");
extern void* imp_MulDiv __asm__("__imp__MulDiv@12");
extern void* imp_MultiByteToWideChar __asm__("__imp__MultiByteToWideChar@24");
extern void* imp_NotifyWinEvent __asm__("__imp__NotifyWinEvent@16");
extern void* imp_OleInitialize __asm__("__imp__OleInitialize@4");
extern void* imp_OleUninitialize __asm__("__imp__OleUninitialize@0");
extern void* imp_OpenClipboard __asm__("__imp__OpenClipboard@4");
extern void* imp_OpenProcess __asm__("__imp__OpenProcess@12");
extern void* imp_OutputDebugStringA __asm__("__imp__OutputDebugStringA@4");
extern void* imp_Polygon __asm__("__imp__Polygon@12");
extern void* imp_Polyline __asm__("__imp__Polyline@12");
extern void* imp_PostMessageA __asm__("__imp__PostMessageA@16");
extern void* imp_PtInRect __asm__("__imp__PtInRect@12");
extern void* imp_QueryPerformanceCounter __asm__("__imp__QueryPerformanceCounter@4");
extern void* imp_QueryPerformanceFrequency __asm__("__imp__QueryPerformanceFrequency@4");
extern void* imp_RaiseException __asm__("__imp__RaiseException@16");
extern void* imp_realloc __asm__("__imp__realloc");
extern void* imp_RedrawWindow __asm__("__imp__RedrawWindow@16");
extern void* imp_RegCloseKey __asm__("__imp__RegCloseKey@4");
extern void* imp_RegisterClassExA __asm__("__imp__RegisterClassExA@4");
extern void* imp_RegisterClassExW __asm__("__imp__RegisterClassExW@4");
extern void* imp_RegisterClipboardFormatW __asm__("__imp__RegisterClipboardFormatW@4");
extern void* imp_RegisterDragDrop __asm__("__imp__RegisterDragDrop@8");
extern void* imp_RegOpenKeyExW __asm__("__imp__RegOpenKeyExW@20");
extern void* imp_RegQueryValueExW __asm__("__imp__RegQueryValueExW@24");
extern void* imp_ReleaseCapture __asm__("__imp__ReleaseCapture@0");
extern void* imp_ReleaseDC __asm__("__imp__ReleaseDC@8");
extern void* imp_ReleaseSemaphore __asm__("__imp__ReleaseSemaphore@12");
extern void* imp_ReleaseSRWLockExclusive __asm__("__imp__ReleaseSRWLockExclusive@4");
extern void* imp_ReleaseStgMedium __asm__("__imp__ReleaseStgMedium@4");
extern void* imp_ResetEvent __asm__("__imp__ResetEvent@4");
extern void* imp_RestoreDC __asm__("__imp__RestoreDC@8");
extern void* imp_ResumeThread __asm__("__imp__ResumeThread@4");
extern void* imp_RevokeDragDrop __asm__("__imp__RevokeDragDrop@4");
extern void* imp_RoundRect __asm__("__imp__RoundRect@28");
extern void* imp_SaveDC __asm__("__imp__SaveDC@4");
extern void* imp_ScreenToClient __asm__("__imp__ScreenToClient@8");
extern void* imp_SelectObject __asm__("__imp__SelectObject@8");
extern void* imp_SendMessageA __asm__("__imp__SendMessageA@16");
extern void* imp_SetBkColor __asm__("__imp__SetBkColor@8");
extern void* imp_SetBkMode __asm__("__imp__SetBkMode@8");
extern void* imp_SetCapture __asm__("__imp__SetCapture@4");
extern void* imp_SetCaretPos __asm__("__imp__SetCaretPos@8");
extern void* imp_SetClipboardData __asm__("__imp__SetClipboardData@8");
extern void* imp_SetCursor __asm__("__imp__SetCursor@4");
extern void* imp_SetEvent __asm__("__imp__SetEvent@4");
extern void* imp_SetFocus __asm__("__imp__SetFocus@4");
extern void* imp_SetLastError __asm__("__imp__SetLastError@4");
extern void* imp_setlocale __asm__("__imp__setlocale");
extern void* imp_SetProcessAffinityMask __asm__("__imp__SetProcessAffinityMask@8");
extern void* imp_SetScrollInfo __asm__("__imp__SetScrollInfo@16");
extern void* imp_SetTextAlign __asm__("__imp__SetTextAlign@8");
extern void* imp_SetTextColor __asm__("__imp__SetTextColor@8");
extern void* imp_SetThreadContext __asm__("__imp__SetThreadContext@8");
extern void* imp_SetThreadPriority __asm__("__imp__SetThreadPriority@8");
extern void* imp_SetTimer __asm__("__imp__SetTimer@16");
extern void* imp_SetWindowLongA __asm__("__imp__SetWindowLongA@12");
extern void* imp_SetWindowPos __asm__("__imp__SetWindowPos@28");
extern void* imp_ShowCaret __asm__("__imp__ShowCaret@4");
extern void* imp_ShowWindow __asm__("__imp__ShowWindow@8");
extern void* imp_Sleep __asm__("__imp__Sleep@4");
extern void* imp_SleepConditionVariableSRW __asm__("__imp__SleepConditionVariableSRW@16");
extern void* imp_strchr __asm__("__imp__strchr");
extern void* imp_strcmp __asm__("__imp__strcmp");
extern void* imp_strcpy __asm__("__imp__strcpy");
extern void* imp_strdup __asm__("__imp__strdup");
extern void* imp_strerror __asm__("__imp__strerror");
extern void* imp_strftime __asm__("__imp__strftime");
extern void* imp_strlen __asm__("__imp__strlen");
extern void* imp_strncmp __asm__("__imp__strncmp");
extern void* imp_strncpy __asm__("__imp__strncpy");
extern void* imp_strstr __asm__("__imp__strstr");
extern void* imp_strtol __asm__("__imp__strtol");
extern void* imp_strtoul __asm__("__imp__strtoul");
extern void* imp_SuspendThread __asm__("__imp__SuspendThread@4");
extern void* imp_SwitchToThread __asm__("__imp__SwitchToThread@0");
extern void* imp_SysAllocStringLen __asm__("__imp__SysAllocStringLen@8");
extern void* imp_SysFreeString __asm__("__imp__SysFreeString@4");
extern void* imp_SystemParametersInfoA __asm__("__imp__SystemParametersInfoA@16");
extern void* imp_TerminateProcess __asm__("__imp__TerminateProcess@8");
extern void* imp_TlsAlloc __asm__("__imp__TlsAlloc@0");
extern void* imp_TlsGetValue __asm__("__imp__TlsGetValue@4");
extern void* imp_TlsSetValue __asm__("__imp__TlsSetValue@8");
extern void* imp_tolower __asm__("__imp__tolower");
extern void* imp_toupper __asm__("__imp__toupper");
extern void* imp_TrackMouseEvent __asm__("__imp__TrackMouseEvent@4");
extern void* imp_TrackPopupMenu __asm__("__imp__TrackPopupMenu@28");
extern void* imp_TryAcquireSRWLockExclusive __asm__("__imp__TryAcquireSRWLockExclusive@4");
extern void* imp_TryEnterCriticalSection __asm__("__imp__TryEnterCriticalSection@4");
extern void* imp_ungetc __asm__("__imp__ungetc");
extern void* imp_UnregisterClassA __asm__("__imp__UnregisterClassA@8");
extern void* imp_ValidateRect __asm__("__imp__ValidateRect@8");
extern void* imp_WaitForMultipleObjects __asm__("__imp__WaitForMultipleObjects@16");
extern void* imp_WaitForSingleObject __asm__("__imp__WaitForSingleObject@8");
extern void* imp_WaitForSingleObjectEx __asm__("__imp__WaitForSingleObjectEx@12");
extern void* imp_WakeAllConditionVariable __asm__("__imp__WakeAllConditionVariable@4");
extern void* imp_WakeConditionVariable __asm__("__imp__WakeConditionVariable@4");
extern void* imp_wcrtomb_s __asm__("__imp__wcrtomb_s");
extern void* imp_wcslen __asm__("__imp__wcslen");
extern void* imp_wcstol __asm__("__imp__wcstol");
extern void* imp_wcstoul __asm__("__imp__wcstoul");
extern void* imp_WideCharToMultiByte __asm__("__imp__WideCharToMultiByte@32");
extern void* imp_write __asm__("__imp__write");

/* ---------- patch table ------------------------------------------- */

typedef struct { unsigned char dll_idx; const char* func_name; void** slot; } SciImpPatch;

/* DLL index order (matches dll_names[] in SciBridge_PatchImports): */
/* 0: imm32.dll */
/* 1: oleaut32.dll */
/* 2: ole32.dll */
/* 3: advapi32.dll */
/* 4: gdi32.dll */
/* 5: user32.dll */
/* 6: kernel32.dll */
/* 7: msvcrt.dll */

static const SciImpPatch sci_imp_patches[] = {
    { 7, "__iob_func", (void**)&imp___iob_func },  /* msvcrt.dll */
    { 7, "__p___mb_cur_max", (void**)&imp___p___mb_cur_max },  /* msvcrt.dll */
    { 7, "__p__pctype", (void**)&imp___p__pctype },  /* msvcrt.dll */
    { 7, "_assert", (void**)&imp__assert },  /* msvcrt.dll */
    { 7, "_beginthreadex", (void**)&imp__beginthreadex },  /* msvcrt.dll */
    { 7, "_endthreadex", (void**)&imp__endthreadex },  /* msvcrt.dll */
    { 7, "_errno", (void**)&imp__errno },  /* msvcrt.dll */
    { 7, "_isctype_l", (void**)&imp__isctype_l },  /* msvcrt.dll */
    { 7, "_iswalpha_l", (void**)&imp__iswalpha_l },  /* msvcrt.dll */
    { 7, "_iswcntrl_l", (void**)&imp__iswcntrl_l },  /* msvcrt.dll */
    { 7, "_iswdigit_l", (void**)&imp__iswdigit_l },  /* msvcrt.dll */
    { 7, "_iswlower_l", (void**)&imp__iswlower_l },  /* msvcrt.dll */
    { 7, "_iswprint_l", (void**)&imp__iswprint_l },  /* msvcrt.dll */
    { 7, "_iswpunct_l", (void**)&imp__iswpunct_l },  /* msvcrt.dll */
    { 7, "_iswspace_l", (void**)&imp__iswspace_l },  /* msvcrt.dll */
    { 7, "_iswupper_l", (void**)&imp__iswupper_l },  /* msvcrt.dll */
    { 7, "_iswxdigit_l", (void**)&imp__iswxdigit_l },  /* msvcrt.dll */
    { 7, "_lock", (void**)&imp__lock },  /* msvcrt.dll */
    { 7, "_mbtowc_l", (void**)&imp__mbtowc_l },  /* msvcrt.dll */
    { 7, "_sscanf_l", (void**)&imp__sscanf_l },  /* msvcrt.dll */
    { 7, "_strcoll_l", (void**)&imp__strcoll_l },  /* msvcrt.dll */
    { 7, "_strdup", (void**)&imp__strdup },  /* msvcrt.dll */
    { 7, "_strtod_l", (void**)&imp__strtod_l },  /* msvcrt.dll */
    { 7, "_strtoi64_l", (void**)&imp__strtoi64_l },  /* msvcrt.dll */
    { 7, "_strtoui64_l", (void**)&imp__strtoui64_l },  /* msvcrt.dll */
    { 7, "_strxfrm_l", (void**)&imp__strxfrm_l },  /* msvcrt.dll */
    { 7, "_sys_nerr", (void**)&imp__sys_nerr },  /* msvcrt.dll */
    { 7, "_tolower_l", (void**)&imp__tolower_l },  /* msvcrt.dll */
    { 7, "_toupper_l", (void**)&imp__toupper_l },  /* msvcrt.dll */
    { 7, "_towlower_l", (void**)&imp__towlower_l },  /* msvcrt.dll */
    { 7, "_towupper_l", (void**)&imp__towupper_l },  /* msvcrt.dll */
    { 7, "_unlock", (void**)&imp__unlock },  /* msvcrt.dll */
    { 7, "_vsnprintf", (void**)&imp__vsnprintf },  /* msvcrt.dll */
    { 7, "_wcscoll_l", (void**)&imp__wcscoll_l },  /* msvcrt.dll */
    { 7, "_wcsxfrm_l", (void**)&imp__wcsxfrm_l },  /* msvcrt.dll */
    { 7, "abort", (void**)&imp_abort },  /* msvcrt.dll */
    { 6, "AcquireSRWLockExclusive", (void**)&imp_AcquireSRWLockExclusive },  /* kernel32.dll */
    { 5, "AdjustWindowRectEx", (void**)&imp_AdjustWindowRectEx },  /* user32.dll */
    { 5, "AppendMenuA", (void**)&imp_AppendMenuA },  /* user32.dll */
    { 7, "atoi", (void**)&imp_atoi },  /* msvcrt.dll */
    { 5, "BeginPaint", (void**)&imp_BeginPaint },  /* user32.dll */
    { 4, "BitBlt", (void**)&imp_BitBlt },  /* gdi32.dll */
    { 7, "calloc", (void**)&imp_calloc },  /* msvcrt.dll */
    { 5, "CallWindowProcA", (void**)&imp_CallWindowProcA },  /* user32.dll */
    { 5, "ClientToScreen", (void**)&imp_ClientToScreen },  /* user32.dll */
    { 5, "CloseClipboard", (void**)&imp_CloseClipboard },  /* user32.dll */
    { 6, "CloseHandle", (void**)&imp_CloseHandle },  /* kernel32.dll */
    { 2, "CLSIDFromProgID", (void**)&imp_CLSIDFromProgID },  /* ole32.dll */
    { 2, "CoCreateInstance", (void**)&imp_CoCreateInstance },  /* ole32.dll */
    { 4, "CombineRgn", (void**)&imp_CombineRgn },  /* gdi32.dll */
    { 4, "CreateBitmap", (void**)&imp_CreateBitmap },  /* gdi32.dll */
    { 5, "CreateCaret", (void**)&imp_CreateCaret },  /* user32.dll */
    { 4, "CreateCompatibleBitmap", (void**)&imp_CreateCompatibleBitmap },  /* gdi32.dll */
    { 4, "CreateCompatibleDC", (void**)&imp_CreateCompatibleDC },  /* gdi32.dll */
    { 4, "CreateDIBSection", (void**)&imp_CreateDIBSection },  /* gdi32.dll */
    { 6, "CreateEventA", (void**)&imp_CreateEventA },  /* kernel32.dll */
    { 4, "CreateFontIndirectW", (void**)&imp_CreateFontIndirectW },  /* gdi32.dll */
    { 5, "CreateIconIndirect", (void**)&imp_CreateIconIndirect },  /* user32.dll */
    { 4, "CreatePatternBrush", (void**)&imp_CreatePatternBrush },  /* gdi32.dll */
    { 4, "CreatePen", (void**)&imp_CreatePen },  /* gdi32.dll */
    { 5, "CreatePopupMenu", (void**)&imp_CreatePopupMenu },  /* user32.dll */
    { 4, "CreateRectRgn", (void**)&imp_CreateRectRgn },  /* gdi32.dll */
    { 4, "CreateRectRgnIndirect", (void**)&imp_CreateRectRgnIndirect },  /* gdi32.dll */
    { 6, "CreateSemaphoreA", (void**)&imp_CreateSemaphoreA },  /* kernel32.dll */
    { 4, "CreateSolidBrush", (void**)&imp_CreateSolidBrush },  /* gdi32.dll */
    { 5, "CreateWindowExA", (void**)&imp_CreateWindowExA },  /* user32.dll */
    { 5, "CreateWindowExW", (void**)&imp_CreateWindowExW },  /* user32.dll */
    { 6, "DebugBreak", (void**)&imp_DebugBreak },  /* kernel32.dll */
    { 5, "DefWindowProcA", (void**)&imp_DefWindowProcA },  /* user32.dll */
    { 6, "DeleteCriticalSection", (void**)&imp_DeleteCriticalSection },  /* kernel32.dll */
    { 4, "DeleteDC", (void**)&imp_DeleteDC },  /* gdi32.dll */
    { 4, "DeleteObject", (void**)&imp_DeleteObject },  /* gdi32.dll */
    { 5, "DestroyCaret", (void**)&imp_DestroyCaret },  /* user32.dll */
    { 5, "DestroyCursor", (void**)&imp_DestroyCursor },  /* user32.dll */
    { 5, "DestroyMenu", (void**)&imp_DestroyMenu },  /* user32.dll */
    { 5, "DestroyWindow", (void**)&imp_DestroyWindow },  /* user32.dll */
    { 2, "DoDragDrop", (void**)&imp_DoDragDrop },  /* ole32.dll */
    { 6, "DuplicateHandle", (void**)&imp_DuplicateHandle },  /* kernel32.dll */
    { 4, "Ellipse", (void**)&imp_Ellipse },  /* gdi32.dll */
    { 5, "EmptyClipboard", (void**)&imp_EmptyClipboard },  /* user32.dll */
    { 5, "EndPaint", (void**)&imp_EndPaint },  /* user32.dll */
    { 6, "EnterCriticalSection", (void**)&imp_EnterCriticalSection },  /* kernel32.dll */
    { 4, "ExtCreatePen", (void**)&imp_ExtCreatePen },  /* gdi32.dll */
    { 4, "ExtTextOutA", (void**)&imp_ExtTextOutA },  /* gdi32.dll */
    { 4, "ExtTextOutW", (void**)&imp_ExtTextOutW },  /* gdi32.dll */
    { 5, "FillRect", (void**)&imp_FillRect },  /* user32.dll */
    { 6, "FlsAlloc", (void**)&imp_FlsAlloc },  /* kernel32.dll */
    { 6, "FlsGetValue", (void**)&imp_FlsGetValue },  /* kernel32.dll */
    { 6, "FlsSetValue", (void**)&imp_FlsSetValue },  /* kernel32.dll */
    { 6, "FormatMessageA", (void**)&imp_FormatMessageA },  /* kernel32.dll */
    { 7, "fprintf", (void**)&imp_fprintf },  /* msvcrt.dll */
    { 7, "fputc", (void**)&imp_fputc },  /* msvcrt.dll */
    { 7, "fputwc", (void**)&imp_fputwc },  /* msvcrt.dll */
    { 5, "FrameRect", (void**)&imp_FrameRect },  /* user32.dll */
    { 7, "free", (void**)&imp_free },  /* msvcrt.dll */
    { 6, "FreeLibrary", (void**)&imp_FreeLibrary },  /* kernel32.dll */
    { 4, "GdiAlphaBlend", (void**)&imp_GdiAlphaBlend },  /* gdi32.dll */
    { 5, "GetAncestor", (void**)&imp_GetAncestor },  /* user32.dll */
    { 7, "getc", (void**)&imp_getc },  /* msvcrt.dll */
    { 5, "GetCaretBlinkTime", (void**)&imp_GetCaretBlinkTime },  /* user32.dll */
    { 5, "GetClientRect", (void**)&imp_GetClientRect },  /* user32.dll */
    { 5, "GetClipboardData", (void**)&imp_GetClipboardData },  /* user32.dll */
    { 6, "GetCurrentProcess", (void**)&imp_GetCurrentProcess },  /* kernel32.dll */
    { 6, "GetCurrentProcessId", (void**)&imp_GetCurrentProcessId },  /* kernel32.dll */
    { 6, "GetCurrentThread", (void**)&imp_GetCurrentThread },  /* kernel32.dll */
    { 6, "GetCurrentThreadId", (void**)&imp_GetCurrentThreadId },  /* kernel32.dll */
    { 5, "GetCursorPos", (void**)&imp_GetCursorPos },  /* user32.dll */
    { 5, "GetDC", (void**)&imp_GetDC },  /* user32.dll */
    { 4, "GetDeviceCaps", (void**)&imp_GetDeviceCaps },  /* gdi32.dll */
    { 5, "GetDlgCtrlID", (void**)&imp_GetDlgCtrlID },  /* user32.dll */
    { 5, "GetDoubleClickTime", (void**)&imp_GetDoubleClickTime },  /* user32.dll */
    { 6, "GetHandleInformation", (void**)&imp_GetHandleInformation },  /* kernel32.dll */
    { 5, "GetKeyboardLayout", (void**)&imp_GetKeyboardLayout },  /* user32.dll */
    { 5, "GetKeyState", (void**)&imp_GetKeyState },  /* user32.dll */
    { 6, "GetLastError", (void**)&imp_GetLastError },  /* kernel32.dll */
    { 6, "GetLocaleInfoA", (void**)&imp_GetLocaleInfoA },  /* kernel32.dll */
    { 5, "GetMessageTime", (void**)&imp_GetMessageTime },  /* user32.dll */
    { 6, "GetModuleHandleA", (void**)&imp_GetModuleHandleA },  /* kernel32.dll */
    { 6, "GetModuleHandleW", (void**)&imp_GetModuleHandleW },  /* kernel32.dll */
    { 5, "GetMonitorInfoA", (void**)&imp_GetMonitorInfoA },  /* user32.dll */
    { 4, "GetObjectW", (void**)&imp_GetObjectW },  /* gdi32.dll */
    { 5, "GetParent", (void**)&imp_GetParent },  /* user32.dll */
    { 6, "GetProcAddress", (void**)&imp_GetProcAddress },  /* kernel32.dll */
    { 6, "GetProcessAffinityMask", (void**)&imp_GetProcessAffinityMask },  /* kernel32.dll */
    { 5, "GetScrollInfo", (void**)&imp_GetScrollInfo },  /* user32.dll */
    { 5, "GetSysColor", (void**)&imp_GetSysColor },  /* user32.dll */
    { 6, "GetSystemInfo", (void**)&imp_GetSystemInfo },  /* kernel32.dll */
    { 5, "GetSystemMetrics", (void**)&imp_GetSystemMetrics },  /* user32.dll */
    { 6, "GetSystemTimeAsFileTime", (void**)&imp_GetSystemTimeAsFileTime },  /* kernel32.dll */
    { 4, "GetTextExtentExPointA", (void**)&imp_GetTextExtentExPointA },  /* gdi32.dll */
    { 4, "GetTextExtentExPointW", (void**)&imp_GetTextExtentExPointW },  /* gdi32.dll */
    { 4, "GetTextExtentPoint32A", (void**)&imp_GetTextExtentPoint32A },  /* gdi32.dll */
    { 4, "GetTextExtentPoint32W", (void**)&imp_GetTextExtentPoint32W },  /* gdi32.dll */
    { 4, "GetTextMetricsA", (void**)&imp_GetTextMetricsA },  /* gdi32.dll */
    { 6, "GetThreadContext", (void**)&imp_GetThreadContext },  /* kernel32.dll */
    { 6, "GetThreadId", (void**)&imp_GetThreadId },  /* kernel32.dll */
    { 6, "GetThreadPriority", (void**)&imp_GetThreadPriority },  /* kernel32.dll */
    { 6, "GetTickCount", (void**)&imp_GetTickCount },  /* kernel32.dll */
    { 5, "GetUpdateRgn", (void**)&imp_GetUpdateRgn },  /* user32.dll */
    { 5, "GetWindowLongA", (void**)&imp_GetWindowLongA },  /* user32.dll */
    { 5, "GetWindowRect", (void**)&imp_GetWindowRect },  /* user32.dll */
    { 6, "GlobalAlloc", (void**)&imp_GlobalAlloc },  /* kernel32.dll */
    { 6, "GlobalLock", (void**)&imp_GlobalLock },  /* kernel32.dll */
    { 6, "GlobalSize", (void**)&imp_GlobalSize },  /* kernel32.dll */
    { 6, "GlobalUnlock", (void**)&imp_GlobalUnlock },  /* kernel32.dll */
    { 5, "HideCaret", (void**)&imp_HideCaret },  /* user32.dll */
    { 0, "ImmEscapeW", (void**)&imp_ImmEscapeW },  /* imm32.dll */
    { 0, "ImmGetCompositionStringW", (void**)&imp_ImmGetCompositionStringW },  /* imm32.dll */
    { 0, "ImmGetContext", (void**)&imp_ImmGetContext },  /* imm32.dll */
    { 0, "ImmNotifyIME", (void**)&imp_ImmNotifyIME },  /* imm32.dll */
    { 0, "ImmReleaseContext", (void**)&imp_ImmReleaseContext },  /* imm32.dll */
    { 0, "ImmSetCandidateWindow", (void**)&imp_ImmSetCandidateWindow },  /* imm32.dll */
    { 0, "ImmSetCompositionFontW", (void**)&imp_ImmSetCompositionFontW },  /* imm32.dll */
    { 0, "ImmSetCompositionStringW", (void**)&imp_ImmSetCompositionStringW },  /* imm32.dll */
    { 0, "ImmSetCompositionWindow", (void**)&imp_ImmSetCompositionWindow },  /* imm32.dll */
    { 6, "InitializeCriticalSection", (void**)&imp_InitializeCriticalSection },  /* kernel32.dll */
    { 6, "InitOnceExecuteOnce", (void**)&imp_InitOnceExecuteOnce },  /* kernel32.dll */
    { 4, "IntersectClipRect", (void**)&imp_IntersectClipRect },  /* gdi32.dll */
    { 5, "InvalidateRect", (void**)&imp_InvalidateRect },  /* user32.dll */
    { 7, "isalnum", (void**)&imp_isalnum },  /* msvcrt.dll */
    { 7, "isalpha", (void**)&imp_isalpha },  /* msvcrt.dll */
    { 5, "IsChild", (void**)&imp_IsChild },  /* user32.dll */
    { 5, "IsClipboardFormatAvailable", (void**)&imp_IsClipboardFormatAvailable },  /* user32.dll */
    { 6, "IsDBCSLeadByteEx", (void**)&imp_IsDBCSLeadByteEx },  /* kernel32.dll */
    { 6, "IsDebuggerPresent", (void**)&imp_IsDebuggerPresent },  /* kernel32.dll */
    { 7, "isdigit", (void**)&imp_isdigit },  /* msvcrt.dll */
    { 7, "isgraph", (void**)&imp_isgraph },  /* msvcrt.dll */
    { 7, "islower", (void**)&imp_islower },  /* msvcrt.dll */
    { 6, "IsProcessorFeaturePresent", (void**)&imp_IsProcessorFeaturePresent },  /* kernel32.dll */
    { 7, "ispunct", (void**)&imp_ispunct },  /* msvcrt.dll */
    { 7, "isspace", (void**)&imp_isspace },  /* msvcrt.dll */
    { 7, "isupper", (void**)&imp_isupper },  /* msvcrt.dll */
    { 7, "iswctype", (void**)&imp_iswctype },  /* msvcrt.dll */
    { 7, "isxdigit", (void**)&imp_isxdigit },  /* msvcrt.dll */
    { 5, "KillTimer", (void**)&imp_KillTimer },  /* user32.dll */
    { 6, "LCMapStringW", (void**)&imp_LCMapStringW },  /* kernel32.dll */
    { 6, "LeaveCriticalSection", (void**)&imp_LeaveCriticalSection },  /* kernel32.dll */
    { 4, "LineTo", (void**)&imp_LineTo },  /* gdi32.dll */
    { 5, "LoadCursorA", (void**)&imp_LoadCursorA },  /* user32.dll */
    { 6, "LoadLibraryExA", (void**)&imp_LoadLibraryExA },  /* kernel32.dll */
    { 6, "LoadLibraryExW", (void**)&imp_LoadLibraryExW },  /* kernel32.dll */
    { 6, "LoadLibraryW", (void**)&imp_LoadLibraryW },  /* kernel32.dll */
    { 7, "localeconv", (void**)&imp_localeconv },  /* msvcrt.dll */
    { 6, "LocalFree", (void**)&imp_LocalFree },  /* kernel32.dll */
    { 7, "longjmp", (void**)&imp_longjmp },  /* msvcrt.dll */
    { 7, "malloc", (void**)&imp_malloc },  /* msvcrt.dll */
    { 5, "MapWindowPoints", (void**)&imp_MapWindowPoints },  /* user32.dll */
    { 7, "memchr", (void**)&imp_memchr },  /* msvcrt.dll */
    { 7, "memcmp", (void**)&imp_memcmp },  /* msvcrt.dll */
    { 7, "memcpy", (void**)&imp_memcpy },  /* msvcrt.dll */
    { 7, "memmove", (void**)&imp_memmove },  /* msvcrt.dll */
    { 7, "memset", (void**)&imp_memset },  /* msvcrt.dll */
    { 5, "MessageBoxA", (void**)&imp_MessageBoxA },  /* user32.dll */
    { 5, "MonitorFromPoint", (void**)&imp_MonitorFromPoint },  /* user32.dll */
    { 5, "MonitorFromRect", (void**)&imp_MonitorFromRect },  /* user32.dll */
    { 5, "MonitorFromWindow", (void**)&imp_MonitorFromWindow },  /* user32.dll */
    { 4, "MoveToEx", (void**)&imp_MoveToEx },  /* gdi32.dll */
    { 5, "MsgWaitForMultipleObjects", (void**)&imp_MsgWaitForMultipleObjects },  /* user32.dll */
    { 6, "MulDiv", (void**)&imp_MulDiv },  /* kernel32.dll */
    { 6, "MultiByteToWideChar", (void**)&imp_MultiByteToWideChar },  /* kernel32.dll */
    { 5, "NotifyWinEvent", (void**)&imp_NotifyWinEvent },  /* user32.dll */
    { 2, "OleInitialize", (void**)&imp_OleInitialize },  /* ole32.dll */
    { 2, "OleUninitialize", (void**)&imp_OleUninitialize },  /* ole32.dll */
    { 5, "OpenClipboard", (void**)&imp_OpenClipboard },  /* user32.dll */
    { 6, "OpenProcess", (void**)&imp_OpenProcess },  /* kernel32.dll */
    { 6, "OutputDebugStringA", (void**)&imp_OutputDebugStringA },  /* kernel32.dll */
    { 4, "Polygon", (void**)&imp_Polygon },  /* gdi32.dll */
    { 4, "Polyline", (void**)&imp_Polyline },  /* gdi32.dll */
    { 5, "PostMessageA", (void**)&imp_PostMessageA },  /* user32.dll */
    { 5, "PtInRect", (void**)&imp_PtInRect },  /* user32.dll */
    { 6, "QueryPerformanceCounter", (void**)&imp_QueryPerformanceCounter },  /* kernel32.dll */
    { 6, "QueryPerformanceFrequency", (void**)&imp_QueryPerformanceFrequency },  /* kernel32.dll */
    { 6, "RaiseException", (void**)&imp_RaiseException },  /* kernel32.dll */
    { 7, "realloc", (void**)&imp_realloc },  /* msvcrt.dll */
    { 5, "RedrawWindow", (void**)&imp_RedrawWindow },  /* user32.dll */
    { 3, "RegCloseKey", (void**)&imp_RegCloseKey },  /* advapi32.dll */
    { 5, "RegisterClassExA", (void**)&imp_RegisterClassExA },  /* user32.dll */
    { 5, "RegisterClassExW", (void**)&imp_RegisterClassExW },  /* user32.dll */
    { 5, "RegisterClipboardFormatW", (void**)&imp_RegisterClipboardFormatW },  /* user32.dll */
    { 2, "RegisterDragDrop", (void**)&imp_RegisterDragDrop },  /* ole32.dll */
    { 3, "RegOpenKeyExW", (void**)&imp_RegOpenKeyExW },  /* advapi32.dll */
    { 3, "RegQueryValueExW", (void**)&imp_RegQueryValueExW },  /* advapi32.dll */
    { 5, "ReleaseCapture", (void**)&imp_ReleaseCapture },  /* user32.dll */
    { 5, "ReleaseDC", (void**)&imp_ReleaseDC },  /* user32.dll */
    { 6, "ReleaseSemaphore", (void**)&imp_ReleaseSemaphore },  /* kernel32.dll */
    { 6, "ReleaseSRWLockExclusive", (void**)&imp_ReleaseSRWLockExclusive },  /* kernel32.dll */
    { 2, "ReleaseStgMedium", (void**)&imp_ReleaseStgMedium },  /* ole32.dll */
    { 6, "ResetEvent", (void**)&imp_ResetEvent },  /* kernel32.dll */
    { 4, "RestoreDC", (void**)&imp_RestoreDC },  /* gdi32.dll */
    { 6, "ResumeThread", (void**)&imp_ResumeThread },  /* kernel32.dll */
    { 2, "RevokeDragDrop", (void**)&imp_RevokeDragDrop },  /* ole32.dll */
    { 4, "RoundRect", (void**)&imp_RoundRect },  /* gdi32.dll */
    { 4, "SaveDC", (void**)&imp_SaveDC },  /* gdi32.dll */
    { 5, "ScreenToClient", (void**)&imp_ScreenToClient },  /* user32.dll */
    { 4, "SelectObject", (void**)&imp_SelectObject },  /* gdi32.dll */
    { 5, "SendMessageA", (void**)&imp_SendMessageA },  /* user32.dll */
    { 4, "SetBkColor", (void**)&imp_SetBkColor },  /* gdi32.dll */
    { 4, "SetBkMode", (void**)&imp_SetBkMode },  /* gdi32.dll */
    { 5, "SetCapture", (void**)&imp_SetCapture },  /* user32.dll */
    { 5, "SetCaretPos", (void**)&imp_SetCaretPos },  /* user32.dll */
    { 5, "SetClipboardData", (void**)&imp_SetClipboardData },  /* user32.dll */
    { 5, "SetCursor", (void**)&imp_SetCursor },  /* user32.dll */
    { 6, "SetEvent", (void**)&imp_SetEvent },  /* kernel32.dll */
    { 5, "SetFocus", (void**)&imp_SetFocus },  /* user32.dll */
    { 6, "SetLastError", (void**)&imp_SetLastError },  /* kernel32.dll */
    { 7, "setlocale", (void**)&imp_setlocale },  /* msvcrt.dll */
    { 6, "SetProcessAffinityMask", (void**)&imp_SetProcessAffinityMask },  /* kernel32.dll */
    { 5, "SetScrollInfo", (void**)&imp_SetScrollInfo },  /* user32.dll */
    { 4, "SetTextAlign", (void**)&imp_SetTextAlign },  /* gdi32.dll */
    { 4, "SetTextColor", (void**)&imp_SetTextColor },  /* gdi32.dll */
    { 6, "SetThreadContext", (void**)&imp_SetThreadContext },  /* kernel32.dll */
    { 6, "SetThreadPriority", (void**)&imp_SetThreadPriority },  /* kernel32.dll */
    { 5, "SetTimer", (void**)&imp_SetTimer },  /* user32.dll */
    { 5, "SetWindowLongA", (void**)&imp_SetWindowLongA },  /* user32.dll */
    { 5, "SetWindowPos", (void**)&imp_SetWindowPos },  /* user32.dll */
    { 5, "ShowCaret", (void**)&imp_ShowCaret },  /* user32.dll */
    { 5, "ShowWindow", (void**)&imp_ShowWindow },  /* user32.dll */
    { 6, "Sleep", (void**)&imp_Sleep },  /* kernel32.dll */
    { 6, "SleepConditionVariableSRW", (void**)&imp_SleepConditionVariableSRW },  /* kernel32.dll */
    { 7, "strchr", (void**)&imp_strchr },  /* msvcrt.dll */
    { 7, "strcmp", (void**)&imp_strcmp },  /* msvcrt.dll */
    { 7, "strcpy", (void**)&imp_strcpy },  /* msvcrt.dll */
    { 7, "strdup", (void**)&imp_strdup },  /* msvcrt.dll */
    { 7, "strerror", (void**)&imp_strerror },  /* msvcrt.dll */
    { 7, "strftime", (void**)&imp_strftime },  /* msvcrt.dll */
    { 7, "strlen", (void**)&imp_strlen },  /* msvcrt.dll */
    { 7, "strncmp", (void**)&imp_strncmp },  /* msvcrt.dll */
    { 7, "strncpy", (void**)&imp_strncpy },  /* msvcrt.dll */
    { 7, "strstr", (void**)&imp_strstr },  /* msvcrt.dll */
    { 7, "strtol", (void**)&imp_strtol },  /* msvcrt.dll */
    { 7, "strtoul", (void**)&imp_strtoul },  /* msvcrt.dll */
    { 6, "SuspendThread", (void**)&imp_SuspendThread },  /* kernel32.dll */
    { 6, "SwitchToThread", (void**)&imp_SwitchToThread },  /* kernel32.dll */
    { 1, "SysAllocStringLen", (void**)&imp_SysAllocStringLen },  /* oleaut32.dll */
    { 1, "SysFreeString", (void**)&imp_SysFreeString },  /* oleaut32.dll */
    { 5, "SystemParametersInfoA", (void**)&imp_SystemParametersInfoA },  /* user32.dll */
    { 6, "TerminateProcess", (void**)&imp_TerminateProcess },  /* kernel32.dll */
    { 6, "TlsAlloc", (void**)&imp_TlsAlloc },  /* kernel32.dll */
    { 6, "TlsGetValue", (void**)&imp_TlsGetValue },  /* kernel32.dll */
    { 6, "TlsSetValue", (void**)&imp_TlsSetValue },  /* kernel32.dll */
    { 7, "tolower", (void**)&imp_tolower },  /* msvcrt.dll */
    { 7, "toupper", (void**)&imp_toupper },  /* msvcrt.dll */
    { 5, "TrackMouseEvent", (void**)&imp_TrackMouseEvent },  /* user32.dll */
    { 5, "TrackPopupMenu", (void**)&imp_TrackPopupMenu },  /* user32.dll */
    { 6, "TryAcquireSRWLockExclusive", (void**)&imp_TryAcquireSRWLockExclusive },  /* kernel32.dll */
    { 6, "TryEnterCriticalSection", (void**)&imp_TryEnterCriticalSection },  /* kernel32.dll */
    { 7, "ungetc", (void**)&imp_ungetc },  /* msvcrt.dll */
    { 5, "UnregisterClassA", (void**)&imp_UnregisterClassA },  /* user32.dll */
    { 5, "ValidateRect", (void**)&imp_ValidateRect },  /* user32.dll */
    { 6, "WaitForMultipleObjects", (void**)&imp_WaitForMultipleObjects },  /* kernel32.dll */
    { 6, "WaitForSingleObject", (void**)&imp_WaitForSingleObject },  /* kernel32.dll */
    { 6, "WaitForSingleObjectEx", (void**)&imp_WaitForSingleObjectEx },  /* kernel32.dll */
    { 6, "WakeAllConditionVariable", (void**)&imp_WakeAllConditionVariable },  /* kernel32.dll */
    { 6, "WakeConditionVariable", (void**)&imp_WakeConditionVariable },  /* kernel32.dll */
    { 7, "wcrtomb_s", (void**)&imp_wcrtomb_s },  /* msvcrt.dll */
    { 7, "wcslen", (void**)&imp_wcslen },  /* msvcrt.dll */
    { 7, "wcstol", (void**)&imp_wcstol },  /* msvcrt.dll */
    { 7, "wcstoul", (void**)&imp_wcstoul },  /* msvcrt.dll */
    { 6, "WideCharToMultiByte", (void**)&imp_WideCharToMultiByte },  /* kernel32.dll */
    { 7, "write", (void**)&imp_write },  /* msvcrt.dll */
};

static const int SCI_IMP_PATCH_COUNT = 300;
