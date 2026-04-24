#!/usr/bin/env python3
"""
strip_comdat.py - Strip IMAGE_SCN_LNK_COMDAT flag from COFF OBJ sections.

Delphi's ilink64 does not auto-resolve cross-OBJ references to COMDAT
sections.  By stripping the COMDAT flag, all sections become regular
(always-included) sections whose external symbols are visible for
automatic cross-OBJ resolution.  This eliminates the need for the
ForceLink mechanism entirely.

Safe when ALL cross-OBJ symbols are uniquely defined (no duplicate
COMDAT definitions across OBJ files).

Usage:
    python strip_comdat.py <obj_dir> <bits>
"""

import struct
import sys
import os
import glob

IMAGE_SCN_LNK_COMDAT = 0x00001000


def strip_comdat_in_obj(filepath):
    """Strip COMDAT flag from all section headers in a COFF OBJ file.
    Returns number of sections modified."""
    with open(filepath, "rb") as f:
        data = bytearray(f.read())

    if len(data) < 20:
        return 0

    machine, num_sections = struct.unpack_from("<HH", data, 0)
    # Validate machine type (x64=0x8664, x86=0x14c)
    if machine not in (0x8664, 0x14C):
        return 0

    # Section headers start at offset 20 (after COFF file header).
    # Each section header is 40 bytes.
    modified = 0
    for sec_idx in range(num_sections):
        sec_off = 20 + sec_idx * 40
        if sec_off + 40 > len(data):
            break
        chars = struct.unpack_from("<I", data, sec_off + 36)[0]
        if chars & IMAGE_SCN_LNK_COMDAT:
            chars &= ~IMAGE_SCN_LNK_COMDAT
            struct.pack_into("<I", data, sec_off + 36, chars)
            modified += 1

    if modified > 0:
        with open(filepath, "wb") as f:
            f.write(data)
    return modified


def main():
    if len(sys.argv) < 3:
        print("Usage: strip_comdat.py <obj_dir> <bits>")
        sys.exit(1)

    obj_dir = sys.argv[1]
    bits = sys.argv[2]

    suffix = "%s.obj" % bits
    pattern = os.path.join(obj_dir, "*%s" % suffix)
    files = sorted(glob.glob(pattern))
    if not files:
        print("[ERROR] No *%s files found in %s" % (suffix, obj_dir))
        sys.exit(1)

    total_modified = 0
    total_sections = 0
    for filepath in files:
        count = strip_comdat_in_obj(filepath)
        if count > 0:
            total_sections += count
            total_modified += 1

    print("[INFO] Stripped COMDAT from %d sections across %d/%d OBJ files."
          % (total_sections, total_modified, len(files)))


if __name__ == "__main__":
    main()
