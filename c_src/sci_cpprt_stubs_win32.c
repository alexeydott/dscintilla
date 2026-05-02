/*
 * sci_cpprt_stubs_win32.c - C++ runtime stubs for Win32 Delphi static linking
 *
 * Win32 variant of sci_cpprt_stubs.c.  On i686, size_t is unsigned int (ABI
 * encoding 'j'), so operator new/delete symbols differ from Win64 ('y').
 *
 * Compile with: clang -c -O2 sci_cpprt_stubs_win32.c
 */

#include <stdlib.h>
#include <malloc.h>

/* ---- operator new / delete (size_t = unsigned int on i686) ---- */

void* _Znwj(unsigned int n)  { return malloc(n ? n : 1); }
void* _Znaj(unsigned int n)  { return malloc(n ? n : 1); }
void  _ZdlPv(void* p)        { free(p); }
void  _ZdaPv(void* p)        { free(p); }

/* Sized delete */
void  _ZdlPvj(void* p, unsigned int sz)  { (void)sz; free(p); }
void  _ZdaPvj(void* p, unsigned int sz)  { (void)sz; free(p); }

/* Aligned variants (align_val_t = size_t = unsigned int on i686) */
void* _ZnwjSt11align_val_t(unsigned int n, unsigned int a)
    { return _aligned_malloc(n ? n : 1, (size_t)a); }
void* _ZnajSt11align_val_t(unsigned int n, unsigned int a)
    { return _aligned_malloc(n ? n : 1, (size_t)a); }
void  _ZdlPvSt11align_val_t(void* p, unsigned int a)
    { (void)a; _aligned_free(p); }
void  _ZdaPvSt11align_val_t(void* p, unsigned int a)
    { (void)a; _aligned_free(p); }
void  _ZdaPvjSt11align_val_t(void* p, unsigned int sz, unsigned int a)
    { (void)sz; (void)a; _aligned_free(p); }

/* Nothrow variants */
void* _ZnwjRKSt9nothrow_t(unsigned int n, const void* nt)
    { (void)nt; return malloc(n ? n : 1); }
void* _ZnajRKSt9nothrow_t(unsigned int n, const void* nt)
    { (void)nt; return malloc(n ? n : 1); }
void  _ZdlPvRKSt9nothrow_t(void* p, const void* nt)
    { (void)nt; free(p); }

/* ---- COM interface GUIDs referenced by Scintilla OLE drag-drop ---- */

typedef struct { unsigned long d1; unsigned short d2, d3; unsigned char d4[8]; } SGUID;

const SGUID IID_IUnknown       = {0x00000000,0x0000,0x0000,{0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46}};
const SGUID IID_IDropSource    = {0x00000121,0x0000,0x0000,{0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46}};
const SGUID IID_IDropTarget    = {0x00000122,0x0000,0x0000,{0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46}};
const SGUID IID_IDataObject    = {0x0000010E,0x0000,0x0000,{0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46}};
const SGUID IID_IEnumFORMATETC = {0x00000103,0x0000,0x0000,{0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46}};

/* ---- IsEqualGUID (inline in Windows headers, extern in MinGW) ---- */

int IsEqualGUID(const SGUID* a, const SGUID* b)
{
    const unsigned char *pa = (const unsigned char*)a;
    const unsigned char *pb = (const unsigned char*)b;
    int i;
    for (i = 0; i < 16; i++)
        if (pa[i] != pb[i]) return 0;
    return 1;
}

int __CPPdebugHook = 0;
