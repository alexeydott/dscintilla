#!/usr/bin/env python3
"""
rename_coff_symbols.py - Rename symbols in COFF OBJ files for Delphi compatibility.

Two kinds of renames:
1. Explicit: specific C symbols that collide with Delphi built-ins (round, etc.)
2. C++ mangled: ALL symbols starting with '?' get deterministic MD5-hash names,
   because Delphi's linker cannot parse MSVC C++ name decoration (E1028).

Usage:
    python rename_coff_symbols.py <obj_dir> <bits> [--dry-run]
"""

import struct
import sys
import os
import glob
import hashlib

# Explicit renames for Delphi built-in collisions (case-insensitive linker).
# Only include names that are confirmed to collide with Delphi intrinsics.
# The rename script changes BOTH definitions and references consistently.
EXPLICIT_RENAMES = {
    b"round":    b"_dsci_round",
    b"lround":   b"_dsci_lround",
    b"lroundf":  b"_dsci_lroundf",
    b"roundf":   b"_dsci_roundf",
    b"trunc":    b"_dsci_trunc",
    b"truncf":   b"_dsci_truncf",
}


def cxx_hash_name(name):
    """Deterministic hash-based replacement for a C++ mangled symbol."""
    h = hashlib.md5(name).hexdigest()[:16]
    return f"__cx_{h}".encode()


def read_coff_header(data):
    """Parse COFF file header."""
    if len(data) < 20:
        return None
    machine, num_sections, _, symtab_offset, num_symbols, _, _ = struct.unpack_from(
        "<HHIIIHH", data, 0
    )
    return machine, num_sections, symtab_offset, num_symbols


def get_symbol_name(data, sym_entry, strtab_off):
    """Extract symbol name from an 18-byte COFF symbol entry."""
    first4 = struct.unpack_from("<I", sym_entry, 0)[0]
    if first4 == 0:
        str_offset = struct.unpack_from("<I", sym_entry, 4)[0]
        abs_off = strtab_off + str_offset
        end = data.index(b"\x00", abs_off)
        return bytes(data[abs_off:end]), True, str_offset
    else:
        return bytes(sym_entry[:8]).rstrip(b"\x00"), False, 0


def write_symbol_name(data, entry_off, strtab_off, strtab_size, new_name):
    """Always append new_name to string table and point entry at it."""
    new_off = strtab_size
    data.extend(new_name + b"\x00")
    strtab_size += len(new_name) + 1
    struct.pack_into("<I", data, strtab_off, strtab_size)
    struct.pack_into("<II", data, entry_off, 0, new_off)
    return strtab_size


def rename_symbols_in_obj(filepath, dry_run=False, undef_cxx=None):
    """Rename symbols in a single COFF OBJ file. Returns rename count."""
    with open(filepath, "rb") as f:
        data = bytearray(f.read())

    hdr = read_coff_header(data)
    if hdr is None:
        return 0
    machine, num_sections, symtab_offset, num_symbols = hdr
    if symtab_offset == 0 or num_symbols == 0:
        return 0

    strtab_off = symtab_offset + num_symbols * 18
    if strtab_off + 4 > len(data):
        return 0
    strtab_size = struct.unpack_from("<I", data, strtab_off)[0]

    renames_done = 0
    i = 0
    while i < num_symbols:
        entry_off = symtab_offset + i * 18
        sym_entry = data[entry_off : entry_off + 18]
        if len(sym_entry) < 18:
            break

        name, is_long, str_offset = get_symbol_name(data, sym_entry, strtab_off)
        num_aux = sym_entry[17]

        new_name = None
        if name in EXPLICIT_RENAMES:
            new_name = EXPLICIT_RENAMES[name]
        elif b"?" in name:
            new_name = cxx_hash_name(name)
            # Track UNDEF C++ symbols (section_number==0, storage_class==2=EXTERNAL)
            if undef_cxx is not None:
                sec_num = struct.unpack_from("<h", sym_entry, 12)[0]
                stor_cls = sym_entry[16]
                if sec_num == 0 and stor_cls == 2:
                    undef_cxx[name] = new_name

        if new_name is not None:
            if not dry_run:
                strtab_size = write_symbol_name(
                    data, entry_off, strtab_off, strtab_size, new_name
                )
            renames_done += 1

        i += 1 + num_aux

    if renames_done > 0 and not dry_run:
        with open(filepath, "wb") as f:
            f.write(data)
    return renames_done


def main():
    if len(sys.argv) < 3:
        print("Usage: rename_coff_symbols.py <obj_dir> <bits> [--dry-run]")
        sys.exit(1)

    obj_dir = sys.argv[1]
    bits = sys.argv[2]
    dry_run = "--dry-run" in sys.argv

    suffix = bits + ".obj"
    pattern = os.path.join(obj_dir, f"*{suffix}")
    files = sorted(glob.glob(pattern))
    if not files:
        print(f"No *{suffix} files found in {obj_dir}")
        sys.exit(1)

    # First pass: collect all DEFINED C++ symbols across all OBJs.
    # We need this to identify which UNDEF symbols are truly external
    # (not defined in any OBJ file).
    defined_cxx = set()
    for filepath in files:
        with open(filepath, "rb") as f:
            data = bytearray(f.read())
        hdr = read_coff_header(data)
        if hdr is None:
            continue
        _, _, symtab_offset, num_symbols = hdr
        if symtab_offset == 0 or num_symbols == 0:
            continue
        strtab_off = symtab_offset + num_symbols * 18
        if strtab_off + 4 > len(data):
            continue
        i = 0
        while i < num_symbols:
            entry_off = symtab_offset + i * 18
            sym_entry = data[entry_off : entry_off + 18]
            if len(sym_entry) < 18:
                break
            name, _, _ = get_symbol_name(data, sym_entry, strtab_off)
            num_aux = sym_entry[17]
            sec_num = struct.unpack_from("<h", sym_entry, 12)[0]
            if b"?" in name and sec_num != 0:
                defined_cxx.add(name)
            i += 1 + num_aux

    # Second pass: rename all symbols.
    undef_cxx = {}  # maps original_name -> hashed_name for UNDEF C++ symbols
    total_renames = 0
    for filepath in files:
        count = rename_symbols_in_obj(filepath, dry_run=dry_run, undef_cxx=undef_cxx)
        if count > 0:
            total_renames += count
            if not dry_run:
                print(f"  Renamed {count} symbol(s) in {os.path.basename(filepath)}")

    action = "would rename" if dry_run else "renamed"
    print(f"[INFO] {action} {total_renames} symbol(s) across {len(files)} OBJ files.")

    # Report UNDEF-only C++ symbols (referenced but never defined in any OBJ).
    truly_undef = {k: v for k, v in undef_cxx.items() if k not in defined_cxx}
    if truly_undef:
        print(f"\n[WARN] {len(truly_undef)} C++ UNDEF symbol(s) need external stubs:")
        for orig, hashed in sorted(truly_undef.items(), key=lambda x: x[1]):
            print(f"  {hashed.decode()} <- {orig.decode(errors='replace')[:80]}")


if __name__ == "__main__":
    main()
