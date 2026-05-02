#!/usr/bin/env python3
"""
gen_winapi_patch.py - Generate sci_winapi_patches.h for Win32 static IAT patching.

Reads the combined Win32 OBJ and MinGW import libraries to build a table of
__imp__ slots (type I = true IAT stubs) that need runtime patching.

Usage: python gen_winapi_patch.py [--nm <path>] [--obj <path>] [--out <path>]

The generated header is included by SciBridge.cpp to implement
SciBridge_PatchImports(pfLoadLibraryA, pfGetProcAddress).
"""

import subprocess
import re
import sys
import os
import argparse
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
DEFAULT_NM  = r"D:\msys64\mingw32\bin\nm.exe"
DEFAULT_OBJ = str(SCRIPT_DIR.parent / "source" / "obj" / "sci_combined_clang32.o")
DEFAULT_OUT = str(SCRIPT_DIR / "sci_winapi_patches.h")
MINGW_LIB   = r"D:\msys64\mingw32\lib"

# DLLs (in priority order) and their import library names.
DLL_LIBS = [
    ("imm32.dll",    "libimm32.a"),
    ("oleaut32.dll", "liboleaut32.a"),
    ("ole32.dll",    "libole32.a"),
    ("advapi32.dll", "libadvapi32.a"),
    ("gdi32.dll",    "libgdi32.a"),
    ("user32.dll",   "libuser32.a"),
    ("kernel32.dll", "libkernel32.a"),
    ("msvcrt.dll",   "libmsvcrt.a"),
]


def run_nm(nm_path: str, path: str) -> list[str]:
    result = subprocess.run(
        [nm_path, path],
        capture_output=True, text=True, errors="replace"
    )
    return result.stdout.splitlines()


def build_dll_map(nm_path: str, lib_dir: str) -> dict[str, str]:
    """Return {asm_sym_name -> dll_name} for all __imp__ type-I symbols."""
    sym_map: dict[str, str] = {}
    for dll_name, lib_file in DLL_LIBS:
        lib_path = os.path.join(lib_dir, lib_file)
        if not os.path.exists(lib_path):
            print(f"WARNING: import lib not found: {lib_path}", file=sys.stderr)
            continue
        for line in run_nm(nm_path, lib_path):
            m = re.search(r"\bI\s+(__imp__\S+)", line)
            if m:
                sym = m.group(1)
                if sym not in sym_map:          # first DLL wins
                    sym_map[sym] = dll_name
    return sym_map


def get_obj_imp_syms(nm_path: str, obj_path: str) -> list[tuple[str, str]]:
    """Return [(asm_sym, func_name)] for type-I __imp__ symbols in the OBJ."""
    results = []
    seen = set()
    for line in run_nm(nm_path, obj_path):
        m = re.search(r"\bI\s+(__imp__(\S+?)(?:@\d+)?)\s*$", line)
        if m:
            asm_sym  = m.group(0).split()[-1]          # full asm symbol
            # strip __imp__ prefix, strip optional @N suffix → GetProcAddress name
            raw = asm_sym[len("__imp__"):]
            func_name = re.sub(r"@\d+$", "", raw)
            if asm_sym not in seen:
                seen.add(asm_sym)
                results.append((asm_sym, func_name))
    results.sort(key=lambda t: t[0].lower())
    return results


def sym_to_c_ident(asm_sym: str) -> str:
    """Convert __imp__Name@N to a valid C identifier: imp_Name."""
    raw = asm_sym[len("__imp__"):]
    raw = re.sub(r"@\d+$", "", raw)           # strip @N
    ident = "imp_" + re.sub(r"\W", "_", raw)  # replace non-word chars
    return ident


def generate(nm_path: str, obj_path: str, lib_dir: str, out_path: str) -> None:
    print(f"Building DLL symbol map from {lib_dir} ...", file=sys.stderr)
    dll_map = build_dll_map(nm_path, lib_dir)
    print(f"  {len(dll_map)} symbols mapped", file=sys.stderr)

    print(f"Reading OBJ type-I __imp__ symbols from {obj_path} ...", file=sys.stderr)
    syms = get_obj_imp_syms(nm_path, obj_path)
    print(f"  {len(syms)} IAT stubs to patch", file=sys.stderr)

    # Collect unique DLLs in stable order
    dll_order = [dll for dll, _ in DLL_LIBS]
    dll_index: dict[str, int] = {dll: i for i, dll in enumerate(dll_order)}

    missing: list[str] = []

    lines = []
    lines.append("/*")
    lines.append(" * sci_winapi_patches.h — GENERATED — do not edit by hand.")
    lines.append(" * Regenerate with:  python c_src/gen_winapi_patch.py")
    lines.append(" * Win32 IAT patch table for SciBridge_PatchImports().")
    lines.append(" * Each entry maps a __imp__ slot (unpatched by PE loader) to its")
    lines.append(" * DLL and exported function name so Delphi can patch them at startup.")
    lines.append(" */")
    lines.append("#pragma once")
    lines.append("")
    lines.append("/* ---------- extern declarations using GCC/Clang __asm__ alias ---------- */")
    lines.append("")

    for asm_sym, func_name in syms:
        c_ident = sym_to_c_ident(asm_sym)
        if dll_map.get(asm_sym) is None:
            missing.append(asm_sym)
        lines.append(f'extern void* {c_ident} __asm__("{asm_sym}");')

    lines.append("")
    lines.append("/* ---------- patch table ------------------------------------------- */")
    lines.append("")
    lines.append("typedef struct { unsigned char dll_idx; const char* func_name; void** slot; } SciImpPatch;")
    lines.append("")
    lines.append("/* DLL index order (matches dll_names[] in SciBridge_PatchImports): */")
    for i, dll in enumerate(dll_order):
        lines.append(f"/* {i}: {dll} */")
    lines.append("")
    lines.append("static const SciImpPatch sci_imp_patches[] = {")

    for asm_sym, func_name in syms:
        dll = dll_map.get(asm_sym, "msvcrt.dll")   # fallback to msvcrt
        idx = dll_index.get(dll, len(dll_order) - 1)
        c_ident = sym_to_c_ident(asm_sym)
        lines.append(f'    {{ {idx}, "{func_name}", (void**)&{c_ident} }},  /* {dll} */')

    lines.append("};")
    lines.append("")
    lines.append(f"static const int SCI_IMP_PATCH_COUNT = {len(syms)};")
    lines.append("")

    header = "\n".join(lines)

    with open(out_path, "w", encoding="utf-8") as f:
        f.write(header)

    print(f"Written: {out_path}", file=sys.stderr)
    if missing:
        print(f"WARNING: {len(missing)} symbols not found in any DLL mapping — defaulted to msvcrt.dll:", file=sys.stderr)
        for s in missing:
            print(f"  {s}", file=sys.stderr)


def main():
    ap = argparse.ArgumentParser(description="Generate sci_winapi_patches.h")
    ap.add_argument("--nm",  default=DEFAULT_NM,  help="Path to nm.exe")
    ap.add_argument("--obj", default=DEFAULT_OBJ, help="Path to sci_combined_clang32.o")
    ap.add_argument("--lib", default=MINGW_LIB,   help="MinGW32 lib directory")
    ap.add_argument("--out", default=DEFAULT_OUT, help="Output header path")
    args = ap.parse_args()

    if not os.path.exists(args.nm):
        print(f"ERROR: nm not found: {args.nm}", file=sys.stderr)
        sys.exit(1)
    if not os.path.exists(args.obj):
        print(f"ERROR: OBJ not found: {args.obj}", file=sys.stderr)
        sys.exit(1)

    generate(args.nm, args.obj, args.lib, args.out)


if __name__ == "__main__":
    main()
