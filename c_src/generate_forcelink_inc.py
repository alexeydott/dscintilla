#!/usr/bin/env python3
"""
generate_forcelink_inc.py - Analyze COFF OBJ cross-references for Delphi.

Delphi's smart linker does not resolve OBJ-to-OBJ symbol references
automatically.  Every symbol needed between OBJ files must have an
explicit Delphi `external` declaration.  This script scans all OBJ
files, discovers cross-OBJ references, and generates a Pascal include
file declaring them.

Usage:
    python generate_forcelink_inc.py <obj_dir> <bits> <output_inc>
"""

import struct
import sys
import os
import glob
import hashlib

# Same rename map as rename_coff_symbols.py to compute effective names.
EXPLICIT_RENAMES = {
    "round": "_dsci_round",
    "lround": "_dsci_lround",
    "lroundf": "_dsci_lroundf",
    "roundf": "_dsci_roundf",
    "trunc": "_dsci_trunc",
    "truncf": "_dsci_truncf",
}

# Symbols already declared in DScintillaBridge.pas — do not duplicate.
DELPHI_DECLARED = {
    "SciBridge_RegisterClasses",
    "SciBridge_ReleaseResources",
    "LexBridge_CreateLexer",
    "LexBridge_SetLibraryProperty",
    "LexBridge_GetLibraryPropertyNames",
    "LexBridge_LexerNameFromID",
    "LexBridge_GetNameSpace",
    "LexBridge_AssignLexerByName",
    "Scintilla_DirectFunction",
    "SciBridge_ResolveImports",
}


def cxx_hash_name(raw_bytes):
    """Must match rename_coff_symbols.py exactly."""
    h = hashlib.md5(raw_bytes).hexdigest()[:16]
    return "__cx_%s" % h


def effective_name(name):
    """Return the post-rename effective name for a raw symbol."""
    if name in EXPLICIT_RENAMES:
        return EXPLICIT_RENAMES[name]
    if "?" in name:
        return cxx_hash_name(name.encode())
    return name


def read_coff_header(data):
    if len(data) < 20:
        return None
    machine, num_sections, _, symtab_offset, num_symbols, _, _ = struct.unpack_from(
        "<HHIIIHH", data, 0
    )
    return machine, num_sections, symtab_offset, num_symbols


def get_symbol_name(data, sym_entry, strtab_off):
    first4 = struct.unpack_from("<I", sym_entry, 0)[0]
    if first4 == 0:
        str_offset = struct.unpack_from("<I", sym_entry, 4)[0]
        abs_off = strtab_off + str_offset
        end = data.index(b"\x00", abs_off)
        return data[abs_off:end].decode("ascii", errors="replace")
    else:
        return sym_entry[:8].rstrip(b"\x00").decode("ascii", errors="replace")


def scan_obj_files(obj_dir, bits):
    """Return (all_defined, all_undef) dicts mapping effective_name -> set of obj filenames."""
    suffix = "%s.obj" % bits
    pattern = os.path.join(obj_dir, "*%s" % suffix)
    files = sorted(glob.glob(pattern))
    if not files:
        print("[ERROR] No *%s files found in %s" % (suffix, obj_dir))
        sys.exit(1)

    all_defined = {}
    all_undef = {}

    for filepath in files:
        fname = os.path.basename(filepath)
        with open(filepath, "rb") as f:
            data = f.read()

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

            name = get_symbol_name(data, sym_entry, strtab_off)
            num_aux = sym_entry[17]
            sec_num = struct.unpack_from("<h", sym_entry, 12)[0]
            stor_cls = sym_entry[16]

            # IMAGE_SYM_CLASS_EXTERNAL=2, IMAGE_SYM_CLASS_WEAK_EXTERNAL=105
            if stor_cls in (2, 105):
                eff = effective_name(name)
                if sec_num == 0:
                    all_undef.setdefault(eff, set()).add(fname)
                else:
                    all_defined.setdefault(eff, set()).add(fname)

            i += 1 + num_aux

    return all_defined, all_undef


def make_safe_identifier(sym):
    """Convert a COFF symbol name into a valid Delphi identifier."""
    return sym.replace("?", "Q").replace("@", "A").replace("$", "D").replace(".", "_")


def main():
    if len(sys.argv) < 4:
        print("Usage: generate_forcelink_inc.py <obj_dir> <bits> <output_inc>")
        sys.exit(1)

    obj_dir = sys.argv[1]
    bits = sys.argv[2]
    output_inc = sys.argv[3]

    all_defined, all_undef = scan_obj_files(obj_dir, bits)

    # Cross-OBJ: UNDEF somewhere, DEFINED somewhere (possibly same or different OBJ).
    cross_obj = set()
    truly_undef = set()
    for sym in all_undef:
        if sym in all_defined:
            cross_obj.add(sym)
        else:
            truly_undef.add(sym)

    cross_obj -= DELPHI_DECLARED

    if truly_undef:
        print("[WARN] %d truly undefined symbols (no definition in any OBJ):" % len(truly_undef))
        for sym in sorted(truly_undef):
            print("  %s" % sym)

    # Generate Delphi include file.
    lines = [
        "{ Auto-generated by generate_forcelink_inc.py — DO NOT EDIT. }",
        "{ Cross-OBJ + weak external declarations: %d }" % len(cross_obj),
        "",
    ]
    for sym in sorted(cross_obj):
        safe = make_safe_identifier(sym)
        lines.append("procedure _fl_%s; cdecl; external name '%s';" % (safe, sym))

    with open(output_inc, "w") as f:
        f.write("\n".join(lines) + "\n")

    print(
        "[INFO] Generated %s with %d declarations (%d truly undefined)"
        % (output_inc, len(cross_obj), len(truly_undef))
    )
    return 0 if not truly_undef else 1


if __name__ == "__main__":
    sys.exit(main())
