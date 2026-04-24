/*
 * sci_cpprt_stubs.c - C++ runtime stubs for Delphi static linking
 *
 * Provides C++ operator new/delete variants, COM GUIDs, and Embarcadero
 * hooks using exact Itanium ABI mangled names.  Compiled as C so the
 * compiler does NOT re-mangle.  The symbol names match what libc++
 * references at link time.
 *
 * Compile with: bcc64x -c -O2 sci_cpprt_stubs.c
 */

#include <stdlib.h>
#include <malloc.h>

/* ---- operator new / delete ---- */

void* _Znwy(unsigned long long n) { return malloc(n ? n : 1); }
void* _Znay(unsigned long long n) { return malloc(n ? n : 1); }
void  _ZdlPv(void* p) { free(p); }
void  _ZdaPv(void* p) { free(p); }

/* Aligned variants  (align_val_t = size_t on x64) */
void* _ZnwySt11align_val_t(unsigned long long n, unsigned long long a)
    { return _aligned_malloc(n ? n : 1, (size_t)a); }
void* _ZnaySt11align_val_t(unsigned long long n, unsigned long long a)
    { return _aligned_malloc(n ? n : 1, (size_t)a); }
void  _ZdlPvSt11align_val_t(void* p, unsigned long long a)
    { (void)a; _aligned_free(p); }
void  _ZdaPvSt11align_val_t(void* p, unsigned long long a)
    { (void)a; _aligned_free(p); }
void  _ZdaPvySt11align_val_t(void* p, unsigned long long sz, unsigned long long a)
    { (void)sz; (void)a; _aligned_free(p); }

/* Nothrow variants  (const nothrow_t& = pointer in ABI) */
void* _ZnwyRKSt9nothrow_t(unsigned long long n, const void* nt)
    { (void)nt; return malloc(n ? n : 1); }
void* _ZnayRKSt9nothrow_t(unsigned long long n, const void* nt)
    { (void)nt; return malloc(n ? n : 1); }
void  _ZdlPvRKSt9nothrow_t(void* p, const void* nt)
    { (void)nt; free(p); }

/* Aligned + nothrow */
void* _ZnwySt11align_val_tRKSt9nothrow_t(unsigned long long n, unsigned long long a, const void* nt)
    { (void)nt; return _aligned_malloc(n ? n : 1, (size_t)a); }
void* _ZnaySt11align_val_tRKSt9nothrow_t(unsigned long long n, unsigned long long a, const void* nt)
    { (void)nt; return _aligned_malloc(n ? n : 1, (size_t)a); }
void  _ZdaPvSt11align_val_tRKSt9nothrow_t(void* p, unsigned long long a, const void* nt)
    { (void)a; (void)nt; _aligned_free(p); }

/* ---- Embarcadero C++ debug hook ---- */

int __CPPdebugHook = 0;

/* ---- System._RaiseAtExcept stub ---- */
/* Embarcadero's libc++abi calls back into the Delphi RTL for exception
   propagation.  In static-linking mode we stub it out since Scintilla
   catches all its own C++ exceptions internally. */
void _ZN6System14_RaiseAtExceptEPNS_7TObjectEPv(void* obj, void* addr)
{
    (void)obj; (void)addr;
    abort();
}

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
