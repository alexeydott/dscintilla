## DScintilla

A completely rewritten Delphi/VCL wrapper for the Scintilla text editor, providing integration with lexers and generated API bindings.

## Foreword
Initially, my goal was to create a simple tool for viewing source files for personal use (I always felt that something was missing from the existing options). But, as often happens, one task led to another, and then another, and so on... In the end, I had to rewrite about 80% of the source code from the original project. 
In my opinion, the final result is quite competitive and can be used in other projects.

## Features
- **Its still VCL component** - `TDScintilla` derived from `TWinControl` with full design-time support
- **Fresh API** - methods and properties automatically generated from latest (now 5.6.1) Scintilla `.iface` definitions using the reworked IFGen utility
- **Reusable dialog boxes** - Ready-to-use `Find and Replace`, `Go To`, and `Visual Settings` dialog boxes
- **2 ways files loading** - Synchronous / Asynchronous file loading with automatic encoding detection (used [chsdet](https://github.com/alexeydott/chsdet/) library)
- **Themes suppors** - Applying editor configurations, syntax themes, and language selection from XML directories (themes compatible with Notepad++)
- **Autocomplete and function lists** - Bundled language services for code hints (Notepad++ compatible, just copy npp `autoCompletion` & `functionList` folders next to control the settings file)
- **Combined Scintilla + Lexilla DLL** - Bundled a single DLL containing export functions for both the editor and the lexer
- **Static linking** - experimental version with static linking of the Scinlilla&Lexilla code directly 
    for more information and examples see SCINТILLA_STATIC_LINKING in ./demos/dscieditor/

## [Scintilla documentation](scintilla.org/ScintillaDoc.html)

