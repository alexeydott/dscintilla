#!/usr/bin/env python3
"""
verify_math_syms.py — Win32 COFF math-symbol integrity check

Validates that the sci_combined_clang32.o produced by
build-delphi-static-objects-msys2-clang32.cmd is free of the
"dcc32 last-wins picks a stub" infinite-loop hazard:

  1. All occurrences of each math function symbol in the COFF symbol
     table must have the SAME value (address within .text).  If any
     duplicate has a different value a stub escaped canonicalization.

  2. The code bytes at each math symbol's address must NOT begin with
       EB FE         (jmp $-2  — 2-byte self-loop)
       E9 FB FF FF FF (jmp $-5  — 5-byte self-loop after DISP32 reloc)
     Either pattern means an infinite-loop stub would be called at runtime.

Usage:
    python verify_math_syms.py  [path-to-obj]

Default path: ..\\source\\obj\\sci_combined_clang32.o
              (relative to the script's directory, i.e. c_src/)

Exit codes:
    0  — all checks passed
    1  — one or more checks failed
"""

import struct
import sys
import os


# ── COFF constants ────────────────────────────────────────────────────────────
IMAGE_SYM_CLASS_EXTERNAL = 2


# ── Math symbols to validate (Win32 i386, underscore-prefixed) ─────────────
MATH_SYMS_I386 = {
    b'_floor', b'_floorf', b'_ceil', b'_ceilf',
    b'_round', b'_roundf', b'_trunc', b'_truncf',
    b'_lround', b'_lroundf',
}
# Win64 x86-64 (no prefix) — also checked when present
MATH_SYMS_AMD64 = {
    b'floor', b'floorf', b'ceil', b'ceilf',
    b'round', b'roundf', b'trunc', b'truncf',
    b'lround', b'lroundf',
}
ALL_MATH_SYMS = MATH_SYMS_I386 | MATH_SYMS_AMD64

# Byte sequences that indicate an infinite self-loop
STUB_PATTERNS = [
    (b'\xEB\xFE',                  'EB FE  (jmp $-2 self-loop)'),
    (b'\xE9\xFB\xFF\xFF\xFF',      'E9 FB FF FF FF  (jmp $-5 self-loop)'),
    (b'\xE9\x00\x00\x00\x00',      'E9 00 00 00 00  (unpatched PLT stub)'),
    (b'\xEB\x00',                  'EB 00  (jmp $+0 nop-loop variant)'),
]


# ── COFF helpers ──────────────────────────────────────────────────────────────

def _get_string(data, strtab_off, offset):
    end = strtab_off + offset
    while end < len(data) and data[end] != 0:
        end += 1
    return bytes(data[strtab_off + offset:end])


def _get_sym_name(data, sym_off, strtab_off):
    first4 = struct.unpack_from('<I', data, sym_off)[0]
    if first4 == 0:
        # Long name: bytes 4-7 = offset into string table
        str_offset = struct.unpack_from('<I', data, sym_off + 4)[0]
        return _get_string(data, strtab_off, str_offset)
    else:
        # Short name: inline 8 bytes, null-padded
        return bytes(data[sym_off:sym_off + 8]).rstrip(b'\x00')


# ── Main verification ─────────────────────────────────────────────────────────

def verify(obj_path):
    if not os.path.exists(obj_path):
        print(f'ERROR: OBJ not found: {obj_path}')
        return False

    with open(obj_path, 'rb') as f:
        data = bytearray(f.read())

    print(f'Verifying: {obj_path}  ({len(data)} bytes)')

    machine    = struct.unpack_from('<H', data, 0)[0]
    num_sec    = struct.unpack_from('<H', data, 2)[0]
    sym_off    = struct.unpack_from('<I', data, 8)[0]
    num_sym    = struct.unpack_from('<I', data, 12)[0]

    strtab_off = sym_off + num_sym * 18
    sec_hdr    = 20  # COFF header is 20 bytes (no optional header for OBJ)

    print(f'  Machine: {machine:#06x}  Sections: {num_sec}  Symbols: {num_sym}')

    # ── Locate .text section to read code bytes ───────────────────────────────
    text_raw_ptr  = None
    text_sec_idx  = None
    for si in range(num_sec):
        h = sec_hdr + si * 40
        sname = bytes(data[h:h + 8]).rstrip(b'\x00')
        if sname == b'.text':
            text_raw_ptr = struct.unpack_from('<I', data, h + 20)[0]
            text_sec_idx = si + 1  # 1-based
            break

    if text_raw_ptr is None:
        print('  WARNING: no .text section found — skipping code-byte checks')

    # ── Collect all definitions of each math symbol ───────────────────────────
    sym_defs = {}   # name -> [(index, value)]
    i = 0
    while i < num_sym:
        s = sym_off + i * 18
        secnum = struct.unpack_from('<h', data, s + 12)[0]
        scl    = data[s + 16]
        naux   = data[s + 17]
        if secnum > 0 and scl == IMAGE_SYM_CLASS_EXTERNAL:
            name = _get_sym_name(data, s, strtab_off)
            if name in ALL_MATH_SYMS:
                val = struct.unpack_from('<I', data, s + 8)[0]
                sym_defs.setdefault(name, []).append((i, val))
        i += 1 + naux

    # ── CHECK 1: no duplicate values ──────────────────────────────────────────
    failures = 0
    seen_syms = set()

    print(f'\n  Checking {len(sym_defs)} math symbol(s) found in OBJ:')

    for name in sorted(sym_defs):
        defs = sym_defs[name]
        seen_syms.add(name)
        values = {v for _, v in defs}
        status = 'OK' if len(values) == 1 else 'FAIL'
        if status == 'FAIL':
            failures += 1
        print(f'    {name.decode():<14}  {len(defs)} occurrence(s)  '
              f'values={[hex(v) for _,v in defs]}  [{status}]')
        if status == 'FAIL':
            print(f'      ↳ DUPLICATE VALUES: stub escaped coff_sanitize canonicalization!')

    # ── CHECK 2: no stub byte patterns at any definition address ─────────────
    if text_raw_ptr is not None:
        for name in sorted(sym_defs):
            for idx, val in sym_defs[name]:
                fp = text_raw_ptr + val
                for pattern, desc in STUB_PATTERNS:
                    n = len(pattern)
                    if fp + n <= len(data) and bytes(data[fp:fp + n]) == pattern:
                        print(f'  FAIL: {name.decode()} at .text+{val:#010x}  '
                              f'→  {desc}')
                        failures += 1
                        break

    # ── Summary ───────────────────────────────────────────────────────────────
    print()
    if failures == 0:
        print(f'  PASSED — all {len(sym_defs)} math symbols are clean (no stubs, no duplicates)')
        return True
    else:
        print(f'  FAILED — {failures} issue(s) detected (see above)')
        return False


if __name__ == '__main__':
    default_obj = os.path.join(
        os.path.dirname(__file__), '..', 'source', 'obj', 'sci_combined_clang32.o')
    obj_path = sys.argv[1] if len(sys.argv) > 1 else default_obj
    ok = verify(os.path.normpath(obj_path))
    sys.exit(0 if ok else 1)
