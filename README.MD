## DScintilla

A completely rewritten Delphi/VCL wrapper for the Scintilla text editor, providing integration with lexers and generated API bindings.

## Key Features

- **Native VCL component** - `TDScintilla` is still derived from `TWinControl` with full design-time support
- **Generated API** - methods and properties automatically generated from Scintilla `.iface` definitions using the reworked IFGen utility
- **XML-based themes and settings** - applying editor configurations, syntax themes, and language selection from XML directories (themes compatible with Notepad++)
- **Combined Scintilla + Lexilla DLL** - A single DLL containing export functions for both the editor and the lexer
- **Reusable dialog boxes** - Ready-to-use “Find,” “Go To,” and “Visual Settings” dialog boxes
- **Streaming file loading** - Asynchronous file loading with automatic encoding detection
- **Autocomplete and function lists** - XML-based language services for code hints (Notepad++ compatible)

http://www.scintilla.org/ScintillaDownload.html
http://www.scintilla.org/ScintillaRelated.html
http://www.scintilla.org/ScintillaDoc.html

