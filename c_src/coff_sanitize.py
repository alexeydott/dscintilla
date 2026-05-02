"""COFF sanitizer for Delphi dcc32/dcc64 compatibility.

Fixes dcc32/dcc64 issues with C++ COFF objects compiled by bcc64x/MinGW:

1. Resolves COMDAT symbol duplication: when a symbol is both DEFINED and
   UNDEFINED (from ld -r preserving COMDAT semantics), patches UNDEFINED
   entries to point to the DEFINED section/value — fixes E2065.
2. Flattens COMDAT section names: `.text$_ZN...` -> `.text`
   (dcc32/dcc64 does not understand the `$` section-group convention)
3. Clears IMAGE_SCN_LNK_COMDAT flag from section characteristics
4. Replaces remaining `$` (0x24) with `_` (0x5F) in symbol names
5. Truncates symbol names > MAX_NAME chars with MD5 hash suffix
6. Promotes C++ global constructor symbols to EXTERNAL so Delphi can
   reference them for initialization:
   - Win64 (bcc64x): _GLOBAL__sub_I_*, _GLOBAL__I_*, SciStatic_RunDestructors
   - Win32 (MinGW i686): __GLOBAL__sub_I_*, _SciStatic_RunDestructors

Uses in-place byte replacement to preserve all offsets and relocations.
"""
import struct
import sys
import hashlib

MAX_NAME = 200  # dcc64 limit appears to be ~255; use 200 for safety
IMAGE_SCN_LNK_COMDAT = 0x00001000
IMAGE_SYM_CLASS_EXTERNAL = 2
IMAGE_SYM_CLASS_STATIC = 3

# Base section names that use COMDAT `$` grouping in MinGW COFF
COMDAT_BASES = {
    b'.text':   b'.text\x00\x00\x00',   # 8 bytes padded
    b'.rdata':  b'.rdata\x00\x00',
    b'.data':   b'.data\x00\x00\x00',
    b'.bss':    b'.bss\x00\x00\x00\x00',
    b'.pdata':  b'.pdata\x00\x00',
    b'.xdata':  b'.xdata\x00\x00',
    b'.CRT':    b'.CRT\x00\x00\x00\x00',
    b'.tls':    b'.tls\x00\x00\x00\x00',
    b'.debug':  b'.debug\x00\x00',
    b'.idata':  b'.idata\x00\x00',
}


def _hash_suffix(name_bytes):
    """Create a short hash suffix from the full original name."""
    return hashlib.md5(name_bytes).hexdigest()[:16]


def _get_sym_name(data, sym_off, strtab_off):
    """Read symbol name from either short (inline) or long (string table) form."""
    first4 = struct.unpack_from('<I', data, sym_off)[0]
    if first4 == 0:
        # Long name: second 4 bytes are offset into string table
        str_offset = struct.unpack_from('<I', data, sym_off + 4)[0]
        return _get_string(data, strtab_off, str_offset)
    else:
        # Short name: inline 8 bytes
        name = bytes(data[sym_off:sym_off + 8])
        return name.rstrip(b'\x00')


def _get_string(data, strtab_off, offset):
    """Read a null-terminated string from the string table."""
    pos = strtab_off + offset
    end = pos
    while end < len(data) and data[end] != 0:
        end += 1
    return bytes(data[pos:end])


def _set_string(data, strtab_off, offset, new_bytes):
    """Overwrite a string-table entry in place (must fit in original space)."""
    pos = strtab_off + offset
    for i, b in enumerate(new_bytes):
        data[pos + i] = b
    data[pos + len(new_bytes)] = 0  # null terminator


def _comdat_base(name):
    """If `name` is a COMDAT section (e.g. `.text$_ZN...`), return the base."""
    for base in COMDAT_BASES:
        if name == base:
            return None  # already clean
        if name.startswith(base + b'$') or name.startswith(base + b'._'):
            return base
    return None


def sanitize_coff(in_path, out_path):
    with open(in_path, 'rb') as f:
        data = bytearray(f.read())

    print(f'File size: {len(data)} bytes')

    # Parse COFF header (20 bytes)
    machine, num_sections, timestamp, sym_table_off, num_symbols, \
        opt_hdr_size, characteristics = struct.unpack_from('<HHIIIHH', data, 0)
    print(f'Machine: 0x{machine:04X}, Sections: {num_sections}, Symbols: {num_symbols}')
    print(f'Symbol table offset: {sym_table_off}')

    # String table immediately follows symbol table
    strtab_off = sym_table_off + num_symbols * 18
    strtab_size = struct.unpack_from('<I', data, strtab_off)[0]
    print(f'String table offset: {strtab_off}, size: {strtab_size}')

    stats = {
        'undefs_resolved': 0,
        'sec_flattened': 0,
        'comdat_cleared': 0,
        'dollar_short_sym': 0,
        'dollar_strtab': 0,
        'names_truncated': 0,
    }

    sec_hdr_start = 20 + opt_hdr_size

    # ================================================================
    # PASS 0: Resolve COMDAT symbol duplication
    # ld -r preserves UNDEFINED refs alongside DEFINED COMDAT symbols.
    # Patch each UNDEFINED entry to match the DEFINED section/value.
    #
    # This handles two cases:
    #  a) EXTERNAL (cls=2) undefs — present in both Win32 and Win64 COFF
    #  b) STATIC (cls=3) undefs  — present in Win32 MinGW COFF only; these are
    #     COMDAT section-anchor symbols (.text$_ZNFoo with sec=0) left over after
    #     GNU ld -r resolves duplicate COMDAT sections. dcc32 crashes (F2084 AV)
    #     when it encounters STATIC symbols with sec_num==0, so we resolve them
    #     here against the matching STATIC DEFINED entry.
    # ================================================================
    # Build map: symbol_name -> (section_number, value) for BOTH EXTERNAL and STATIC
    defined = {}
    i = 0
    while i < num_symbols:
        sym_off = sym_table_off + i * 18
        sec_num = struct.unpack_from('<h', data, sym_off + 12)[0]  # signed int16
        storage_class = data[sym_off + 16]
        num_aux = data[sym_off + 17]
        if sec_num > 0 and storage_class in (IMAGE_SYM_CLASS_EXTERNAL, IMAGE_SYM_CLASS_STATIC):
            name = _get_sym_name(data, sym_off, strtab_off)
            value = struct.unpack_from('<I', data, sym_off + 8)[0]
            if name not in defined:
                defined[name] = (sec_num, value)
        i += 1 + num_aux

    # Patch UNDEFINED entries (both EXTERNAL and STATIC) that have a known definition
    i = 0
    while i < num_symbols:
        sym_off = sym_table_off + i * 18
        sec_num = struct.unpack_from('<h', data, sym_off + 12)[0]
        storage_class = data[sym_off + 16]
        num_aux = data[sym_off + 17]
        if sec_num == 0 and storage_class in (IMAGE_SYM_CLASS_EXTERNAL, IMAGE_SYM_CLASS_STATIC):
            name = _get_sym_name(data, sym_off, strtab_off)
            if name in defined:
                def_sec, def_val = defined[name]
                struct.pack_into('<I', data, sym_off + 8, def_val)
                struct.pack_into('<h', data, sym_off + 12, def_sec)
                stats['undefs_resolved'] += 1
        i += 1 + num_aux

    print(f'COMDAT undefs resolved (EXTERNAL+STATIC): {stats["undefs_resolved"]}')

    # ================================================================
    # PASS 1: Flatten COMDAT section names and clear COMDAT flags
    # ================================================================
    for i in range(num_sections):
        hdr_off = sec_hdr_start + i * 40
        name_field = bytes(data[hdr_off:hdr_off + 8])
        chars_off = hdr_off + 36
        chars = struct.unpack_from('<I', data, chars_off)[0]

        sec_name = None
        is_long_name = False

        if name_field[0:1] == b'/' and name_field[1:2] != b'/':
            # Long name: /offset into string table
            offset_str = name_field[1:8].rstrip(b'\x00').decode('ascii')
            try:
                str_offset = int(offset_str)
                sec_name = _get_string(data, strtab_off, str_offset)
                is_long_name = True
            except ValueError:
                continue
        else:
            # Short name (inline in 8-byte field)
            sec_name = name_field.rstrip(b'\x00')

        if sec_name is None:
            continue

        base = _comdat_base(sec_name)
        if base is not None:
            # Replace section name with base name
            padded = COMDAT_BASES[base]
            # Write inline 8-byte name directly into section header
            data[hdr_off:hdr_off + 8] = padded
            if is_long_name:
                # Also null-out the string table entry to avoid stale refs
                _set_string(data, strtab_off, str_offset, base)
            stats['sec_flattened'] += 1

        # Clear COMDAT flag if set
        if chars & IMAGE_SCN_LNK_COMDAT:
            chars &= ~IMAGE_SCN_LNK_COMDAT
            struct.pack_into('<I', data, chars_off, chars)
            stats['comdat_cleared'] += 1

    print(f'Sections flattened: {stats["sec_flattened"]}')
    print(f'COMDAT flags cleared: {stats["comdat_cleared"]}')

    # ================================================================
    # PASS 1.5: Strip .pdata/.xdata (SEH exception handling tables)
    #
    # Delphi's linker does not properly process Win64 SEH unwind info.
    # Corrupt .pdata/.xdata causes RtlUnwindEx to loop infinitely when
    # any exception is raised inside statically linked C++ code.
    # Neutralize these sections: zero raw data, clear relocations, and
    # rename so the Windows loader never finds them.
    # ================================================================
    SEH_STRIP = {b'.pdata', b'.xdata'}
    stats['seh_stripped'] = 0

    for i in range(num_sections):
        hdr_off = sec_hdr_start + i * 40
        name_field = bytes(data[hdr_off:hdr_off + 8]).rstrip(b'\x00')

        if name_field not in SEH_STRIP:
            continue

        # Zero-fill raw data
        raw_size = struct.unpack_from('<I', data, hdr_off + 16)[0]
        raw_ptr = struct.unpack_from('<I', data, hdr_off + 20)[0]
        if raw_ptr > 0 and raw_size > 0:
            data[raw_ptr:raw_ptr + raw_size] = b'\x00' * raw_size

        # Clear SizeOfRawData, relocations, characteristics
        struct.pack_into('<I', data, hdr_off + 16, 0)      # SizeOfRawData = 0
        struct.pack_into('<H', data, hdr_off + 32, 0)      # NumberOfRelocations = 0
        struct.pack_into('<I', data, hdr_off + 36, 0)      # Characteristics = 0

        # Rename to .dead so neither the linker nor the OS recognizes it
        data[hdr_off:hdr_off + 8] = b'.dead\x00\x00\x00'
        stats['seh_stripped'] += 1

    print(f'SEH sections stripped: {stats["seh_stripped"]}')

    # ================================================================
    # PASS 1.75: Fix infinite-loop stubs from GNU ld partial link
    #
    # GNU ld -r creates two kinds of unresolvable-function stubs:
    #   1. `EB FE`           — jmp $-2  (2-byte short jump to self)
    #   2. `E9 00 00 00 00`  — jmp rel32 with a self-referencing REL32
    #                          relocation that resolves to jmp $-5
    # Both produce infinite loops at runtime.  Replace with real x86-64
    # implementations for known CRT math functions, and neutralise the
    # self-referencing relocations for the E9 pattern.
    # ================================================================

    # x86-64 SSE4.1 replacement code (Windows x64 ABI: double/float in
    # xmm0; double/float return in xmm0; long return in eax).
    #
    # roundsd xmm0, xmm0, imm8 = 66 0F 3A 0B C0 <imm8>; ret = C3
    # roundss xmm0, xmm0, imm8 = 66 0F 3A 0A C0 <imm8>; ret = C3
    # cvtsd2si eax, xmm0        = F2 0F 2D C0;            ret = C3
    # cvtss2si eax, xmm0        = F3 0F 2D C0;            ret = C3
    #
    # imm8 mode bits: [3]=suppress precision exception  [1:0]=rounding
    #   0x09 = floor (toward -inf)    0x0A = ceil (toward +inf)
    #   0x0B = trunc (toward zero)    0x08 = nearest even
    #
    # Win32 (i386 cdecl) x87 FPU patches for lround/lroundf:
    #   arg at [esp+4] (double=8B, float=4B), long return in EAX.
    #   Sequence: sub esp,4 | fldl/flds [esp+8] | frndint | fistpl [esp]
    #             | pop eax | ret    (14 bytes, fits in 16-byte slot)
    STUB_PATCHES = {
        # Win64 (x86-64 ABI) -------------------------------------------------
        b'round':   bytes([0x66, 0x0F, 0x3A, 0x0B, 0xC0, 0x08, 0xC3]),
        b'roundf':  bytes([0x66, 0x0F, 0x3A, 0x0A, 0xC0, 0x08, 0xC3]),
        b'lround':  bytes([0xF2, 0x0F, 0x2D, 0xC0, 0xC3]),
        b'lroundf': bytes([0xF3, 0x0F, 0x2D, 0xC0, 0xC3]),
        b'trunc':   bytes([0x66, 0x0F, 0x3A, 0x0B, 0xC0, 0x0B, 0xC3]),
        b'floor':   bytes([0x66, 0x0F, 0x3A, 0x0B, 0xC0, 0x09, 0xC3]),
        b'floorf':  bytes([0x66, 0x0F, 0x3A, 0x0A, 0xC0, 0x09, 0xC3]),
        b'ceil':    bytes([0x66, 0x0F, 0x3A, 0x0B, 0xC0, 0x0A, 0xC3]),
        b'ceilf':   bytes([0x66, 0x0F, 0x3A, 0x0A, 0xC0, 0x0A, 0xC3]),
        # Win32 (i386 cdecl) — underscore-prefixed, x87 FPU implementation --
        # _lround(double): sub esp,4 | fldl [esp+8] | frndint |
        #                  fistpl [esp] | pop eax | ret
        b'_lround':  bytes([
            0x83, 0xEC, 0x04,            # sub  esp, 4
            0xDD, 0x44, 0x24, 0x08,      # fldl [esp+8]  (double arg)
            0xD9, 0xFC,                  # frndint
            0xDB, 0x1C, 0x24,            # fistpl [esp]
            0x58,                        # pop  eax
            0xC3,                        # ret
        ]),
        # _lroundf(float): sub esp,4 | flds [esp+8] | frndint |
        #                  fistpl [esp] | pop eax | ret
        b'_lroundf': bytes([
            0x83, 0xEC, 0x04,            # sub  esp, 4
            0xD9, 0x44, 0x24, 0x08,      # flds [esp+8]  (float arg)
            0xD9, 0xFC,                  # frndint
            0xDB, 0x1C, 0x24,            # fistpl [esp]
            0x58,                        # pop  eax
            0xC3,                        # ret
        ]),
    }

    # Find .text section raw data pointer and relocation table
    text_raw_ptr = None
    text_sec_idx = None
    text_reloc_ptr = None
    text_num_relocs = 0
    for si in range(num_sections):
        hdr = sec_hdr_start + si * 40
        sname = bytes(data[hdr:hdr + 8]).rstrip(b'\x00')
        if sname == b'.text':
            text_raw_ptr = struct.unpack_from('<I', data, hdr + 20)[0]
            text_sec_idx = si + 1  # 1-based section number
            text_reloc_ptr = struct.unpack_from('<I', data, hdr + 24)[0]
            text_num_relocs = struct.unpack_from('<H', data, hdr + 32)[0]
            break

    # Build lookup: for each (sym_index) that has a self-referencing
    # REL32 relocation (i.e. the reloc VA = sym_value + 1), record
    # the relocation entry file offset so we can neutralise it.
    self_reloc_offsets = {}  # sym_index -> reloc entry file offset
    if text_reloc_ptr is not None:
        for ri in range(text_num_relocs):
            roff = text_reloc_ptr + ri * 10
            va = struct.unpack_from('<I', data, roff)[0]
            sym_idx = struct.unpack_from('<I', data, roff + 4)[0]
            rtype = struct.unpack_from('<H', data, roff + 8)[0]
            if rtype == 4:  # IMAGE_REL_AMD64_REL32
                s_off = sym_table_off + sym_idx * 18
                s_value = struct.unpack_from('<I', data, s_off + 8)[0]
                s_secnum = struct.unpack_from('<h', data, s_off + 12)[0]
                if s_secnum == text_sec_idx and s_value == va - 1:
                    self_reloc_offsets[sym_idx] = roff

    stats['stubs_fixed'] = 0
    if text_raw_ptr is not None:
        i = 0
        while i < num_symbols:
            sym_off = sym_table_off + i * 18
            value = struct.unpack_from('<I', data, sym_off + 8)[0]
            secnum = struct.unpack_from('<h', data, sym_off + 12)[0]
            naux = data[sym_off + 17]

            if secnum == text_sec_idx:
                file_pos = text_raw_ptr + value
                is_eb_fe = (file_pos + 2 <= len(data)
                            and data[file_pos] == 0xEB and data[file_pos + 1] == 0xFE)
                is_e9_self = (file_pos + 5 <= len(data)
                              and data[file_pos] == 0xE9 and i in self_reloc_offsets)

                if is_eb_fe or is_e9_self:
                    sym_name = _get_sym_name(data, sym_off, strtab_off)
                    patch = STUB_PATCHES.get(sym_name)
                    stub_kind = 'EB_FE' if is_eb_fe else 'E9_self'
                    if patch is not None:
                        data[file_pos:file_pos + len(patch)] = patch
                        # NOP-fill remainder of the 16-byte slot
                        for k in range(len(patch), 16):
                            if file_pos + k < len(data):
                                data[file_pos + k] = 0x90  # NOP
                        # Neutralise self-referencing relocation for E9 stubs
                        if is_e9_self:
                            roff = self_reloc_offsets[i]
                            struct.pack_into('<I', data, roff, 0)       # VA = 0
                            struct.pack_into('<I', data, roff + 4, 0)   # sym = 0
                            struct.pack_into('<H', data, roff + 8, 0)   # type = ABSOLUTE (nop)
                        stats['stubs_fixed'] += 1
                        print(f'  Patched stub [{stub_kind}]: {sym_name.decode()} at .text+{value:#06x}')
                    else:
                        print(f'  WARNING: unknown stub [{stub_kind}]: {sym_name.decode()} at .text+{value:#06x}')

            i += 1 + naux

    print(f'Infinite-loop stubs patched: {stats["stubs_fixed"]}')

    # ================================================================
    # PASS 1.8: Canonicalize duplicate math-function symbol definitions
    #
    # Problem (Win32 / i386 COFF):
    #   Scintilla sources compiled by Clang32 without -fno-builtin emit
    #   global EXTERNAL _floor / _ceil / _trunc / _round stubs as PLT-like
    #   thunks.  These stubs appear in the COFF symbol table AFTER shim32's
    #   real definitions.  dcc32 uses "last wins" semantics for duplicate
    #   EXTERNAL symbols, so it resolves `_floor` to the late-index stub.
    #   The stub's own DISP32 relocation also references `_floor` → dcc32
    #   resolves that to the SAME stub → displacement = -5 → E9 FB FF FF FF
    #   = infinite self-loop at runtime.
    #
    # Fix:
    #   For every symbol whose name is in MATH_SYMS_{I386,AMD64} and which
    #   has a LATER table index than the first occurrence, overwrite its
    #   VALUE with the first occurrence's value.  Now every occurrence of
    #   `_floor` in the table points to shim32's real implementation at 0x50.
    #   Regardless of which symbol dcc32 "wins" with, it resolves to real code.
    #   The DISP32 reloc inside the stub also resolves to real code → the stub
    #   becomes a harmless trampoline to the shim32 implementation.
    # ================================================================

    # Win32 i386 cdecl (underscore-prefixed)
    MATH_SYMS_I386 = {
        b'_floor', b'_floorf', b'_ceil', b'_ceilf',
        b'_round', b'_roundf', b'_trunc', b'_truncf',
        b'_lround', b'_lroundf',
    }
    # Win64 x86-64 (no prefix)
    MATH_SYMS_AMD64 = {
        b'floor', b'floorf', b'ceil', b'ceilf',
        b'round', b'roundf', b'trunc', b'truncf',
        b'lround', b'lroundf',
    }
    ALL_MATH_SYMS = MATH_SYMS_I386 | MATH_SYMS_AMD64

    # First pass: find the first (lowest-index) definition for each math symbol
    first_math_def = {}  # name -> (value, secnum)
    i = 0
    while i < num_symbols:
        sym_off = sym_table_off + i * 18
        secnum  = struct.unpack_from('<h', data, sym_off + 12)[0]
        scl     = data[sym_off + 16]
        naux    = data[sym_off + 17]
        if secnum > 0 and scl == IMAGE_SYM_CLASS_EXTERNAL:
            name = _get_sym_name(data, sym_off, strtab_off)
            if name in ALL_MATH_SYMS and name not in first_math_def:
                value = struct.unpack_from('<I', data, sym_off + 8)[0]
                first_math_def[name] = (value, secnum)
        i += 1 + naux

    # Second pass: overwrite duplicates to match the first definition
    math_dedup_count = 0
    i = 0
    while i < num_symbols:
        sym_off = sym_table_off + i * 18
        secnum  = struct.unpack_from('<h', data, sym_off + 12)[0]
        scl     = data[sym_off + 16]
        naux    = data[sym_off + 17]
        if secnum > 0 and scl == IMAGE_SYM_CLASS_EXTERNAL:
            name = _get_sym_name(data, sym_off, strtab_off)
            if name in first_math_def:
                canon_val, canon_sec = first_math_def[name]
                cur_val = struct.unpack_from('<I', data, sym_off + 8)[0]
                if cur_val != canon_val:
                    struct.pack_into('<I', data, sym_off + 8, canon_val)
                    struct.pack_into('<h', data, sym_off + 12, canon_sec)
                    math_dedup_count += 1
        i += 1 + naux

    if math_dedup_count:
        print(f'Math symbol duplicates canonicalized: {math_dedup_count}')

    # ================================================================
    # PASS 2: Replace $ in short symbol names (inline 8-byte field)
    # ================================================================
    for i in range(num_symbols):
        sym_off = sym_table_off + i * 18
        first4 = struct.unpack_from('<I', data, sym_off)[0]
        if first4 != 0:
            # Short name (inline)
            for k in range(8):
                if data[sym_off + k] == 0x24:
                    data[sym_off + k] = 0x5F
                    stats['dollar_short_sym'] += 1

    print(f'Short symbol $ replacements: {stats["dollar_short_sym"]}')

    # ================================================================
    # PASS 3: Replace $ and truncate in string table
    # ================================================================
    st_start = strtab_off + 4
    st_end = strtab_off + strtab_size

    # First: replace all $ with _ in string table
    for j in range(st_start, st_end):
        if data[j] == 0x24:
            data[j] = 0x5F
            stats['dollar_strtab'] += 1

    print(f'String table $ replacements: {stats["dollar_strtab"]}')

    # Second: truncate long strings
    j = st_start
    while j < st_end:
        str_start = j
        while j < st_end and data[j] != 0:
            j += 1
        str_len = j - str_start
        if str_len > MAX_NAME:
            orig = bytes(data[str_start:str_start + str_len])
            h = _hash_suffix(orig)
            prefix_len = MAX_NAME - 18  # 2 ("_H") + 16 (hash)
            new_name = orig[:prefix_len] + b'_H' + h.encode('ascii')
            for k in range(len(new_name)):
                data[str_start + k] = new_name[k]
            data[str_start + len(new_name)] = 0
            for k in range(str_start + len(new_name) + 1, str_start + str_len):
                data[k] = 0
            stats['names_truncated'] += 1
        j += 1  # skip null

    print(f'Names truncated: {stats["names_truncated"]}')

    # ================================================================
    # PASS 4: Promote C++ global constructor/destructor symbols to EXTERNAL
    # bcc64x/MinGW emits constructor and destructor helper symbols as STATIC.
    # Delphi cannot reference STATIC symbols via `external name '...'`.
    # Promote them to EXTERNAL so DScintillaBridge can call them.
    #
    # Win64 (bcc64x, x86-64-w64-windows-gnu):
    #   _GLOBAL__sub_I_*, _GLOBAL__I_*, SciStatic_RunDestructors
    # Win32 (MinGW i686, i686-w64-windows-gnu):
    #   __GLOBAL__sub_I_*, _SciStatic_RunDestructors
    #   (Win32 cdecl adds one leading underscore to all C symbols)
    # ================================================================
    stats['ctors_promoted'] = 0
    i = 0
    while i < num_symbols:
        sym_off = sym_table_off + i * 18
        sec_num = struct.unpack_from('<h', data, sym_off + 12)[0]
        storage_class = data[sym_off + 16]
        num_aux = data[sym_off + 17]
        if sec_num > 0 and storage_class == IMAGE_SYM_CLASS_STATIC:
            name = _get_sym_name(data, sym_off, strtab_off)
            if (name.startswith(b'_GLOBAL__sub_I_')    # Win64 bcc64x
                    or name.startswith(b'_GLOBAL__I_')  # Win64 bcc64x alternate
                    or name.startswith(b'__GLOBAL__sub_I_')  # Win32 MinGW i686
                    or name == b'SciStatic_RunDestructors'   # Win64
                    or name == b'_SciStatic_RunDestructors'):  # Win32
                data[sym_off + 16] = IMAGE_SYM_CLASS_EXTERNAL
                stats['ctors_promoted'] += 1
        i += 1 + num_aux

    print(f'Ctors promoted to EXTERNAL: {stats["ctors_promoted"]}')

    # ================================================================
    # Verification pass
    # ================================================================
    # Check section names for remaining $
    bad_sections = 0
    for i in range(num_sections):
        hdr_off = sec_hdr_start + i * 40
        name_field = bytes(data[hdr_off:hdr_off + 8])
        if 0x24 in name_field:
            bad_sections += 1
    # Check string table for remaining $
    remaining_dollar = sum(1 for j in range(st_start, st_end) if data[j] == 0x24)
    # Check for remaining long strings
    remaining_long = 0
    j = st_start
    while j < st_end:
        str_start = j
        while j < st_end and data[j] != 0:
            j += 1
        if j - str_start > MAX_NAME:
            remaining_long += 1
        j += 1
    print(f'Verification: section_$={bad_sections}, strtab_$={remaining_dollar}, long={remaining_long}')

    with open(out_path, 'wb') as f:
        f.write(data)

    print(f'Written: {out_path} ({len(data)} bytes)')
    return stats


if __name__ == '__main__':
    in_path = sys.argv[1] if len(sys.argv) > 1 else r'D:\projects\externals\dsci\source\obj\sci_combined_bcc64x.o'
    out_path = sys.argv[2] if len(sys.argv) > 2 else r'D:\projects\externals\dsci\source\obj\sci_combined_bcc64x_clean.o'
    sanitize_coff(in_path, out_path)
