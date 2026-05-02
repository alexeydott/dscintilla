/* merge_sections_i386.ld
 *
 * GNU ld linker script for Phase 3.5 of the Delphi Win32 static object build.
 *
 * Problem: After Phase 2 (ld -r) + Phase 3 (coff_sanitize.py), the combined
 * COFF object has 4000+ sections — ex-COMDAT sections were cleared of their
 * COMDAT flags and renamed (e.g. ".text$_ZN..." -> ".text") but NOT merged.
 * dcc32's {$L} linker stops applying IMAGE_REL_I386_DIR32 relocations beyond
 * a few hundred sections, leaving BSS symbols at address 0x00000000 and
 * causing NULL-pointer writes at runtime (e.g. ScintillaWin::Register crash).
 *
 * Fix: a second "ld -m i386pe -r -T merge_sections_i386.ld" pass collects all
 * same-named sections into a single output section per type, reducing the total
 * section count to ~9.  All relocations are recalculated by ld.
 *
 * Usage (called from build-delphi-static-objects-msys2-clang32.cmd Phase 3.5):
 *   ld -m i386pe -r -T merge_sections_i386.ld -o merged.o sanitized.o
 *
 * Sections not listed here are discarded (debug info, .llvm_addrsig, etc.).
 */

OUTPUT_FORMAT(pe-i386)

SECTIONS {
    /* Code — main code plus cold/startup sub-sections */
    .text             : { *(.text .text.*)              }

    /* Read-only data — vtables, string literals, refptr stubs */
    .rdata            : { *(.rdata .rdata.*)            }

    /* Initialised data */
    .data             : { *(.data .data.*)              }

    /* Zero-initialised data — hInstance, global state, etc. */
    .bss              : { *(.bss .bss.*)                }

    /* MinGW/MSVC static-constructor pointer tables */
    .CRT              : { *(.CRT .CRT.*)                }

    /* GCC/MinGW constructor/destructor pointer arrays */
    .ctors            : { *(.ctors .ctors.*)            }
    .dtors            : { *(.dtors .dtors.*)            }

    /* Windows PE import stubs (__imp__XXX@N thunks) */
    .idata            : { *(.idata .idata.*)            }

    /* C++ exception unwind tables — needed for try/catch in Scintilla */
    .eh_frame         : { *(.eh_frame)                  }
    .gcc_except_table : { *(.gcc_except_table)          }

    /* Discard LLVM metadata and linker-directive sections */
    /DISCARD/         : { *(.llvm_addrsig) *(.drectve)  }
}
