## DScintilla

A completely rewritten Delphi/VCL wrapper for the Scintilla text editor, providing integration with lexers and generated API bindings.

## Foreword
My initial goal was to create a simple tool for viewing source files for personal use (in existing always seemed to be missing something). But as often happens, one task led to another, and in the end, I had to rewrite about 80% of the source code from the original project. In my opinion, the final result is quite competitive and can be used in other projects. 

## Features
- **Native VCL component** - `TDScintilla` derived from `TWinControl` with full design-time support
- **Generated API** - methods and properties automatically generated from latest (now 5.6.1) Scintilla `.iface` definitions using the reworked IFGen utility
- **XML-based themes and settings** - applying editor configurations, syntax themes, and language selection from XML directories (themes compatible with Notepad++)
- **Reusable dialog boxes** - Ready-to-use `Find and Replace`, `Go To`, and `Visual Settings` dialog boxes
- **Streaming file loading** - Asynchronous file loading with automatic encoding detection (used [chsdet](https://github.com/alexeydott/chsdet/) library)
- **Autocomplete and function lists** - XML-based language services for code hints (Notepad++ compatible)
- **Combined Scintilla + Lexilla DLL** - Bundled a single DLL containing export functions for both the editor and the lexer
- **Static linking** - experimental version (x64 only at this time) with static linking of the Scinlilla&Lexilla code directly 
    for more information and examples see SCINТILLA_STATIC_LINKING in ./demos/dscieditor/

##Scintilla documentation
http://www.scintilla.org/ScintillaDoc.html

