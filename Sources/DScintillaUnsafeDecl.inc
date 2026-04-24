    /// <summary>Retrieve a pointer to a function that processes messages for this Scintilla.</summary>
    function GetDirectFunction: TDScintillaFunction;

    /// <summary>Retrieve a pointer to a function that processes messages for this Scintilla and returns status.</summary>
    function GetDirectStatusFunction: TDScintillaStatusFunction;

    /// <summary>Retrieve a pointer value to use as the first argument when calling
    /// the function returned by GetDirectFunction.</summary>
    function GetDirectPointer: Pointer;

    /// <summary>Retrieve a pointer to the document object.</summary>
    function GetDocPointer: TDSciDocument;

    /// <summary>Change the document object used.</summary>
    procedure SetDocPointer(APointer: TDSciDocument);

    /// <summary>Create a new document object.
    /// Starts with reference count of 1 and not selected into editor.</summary>
    function CreateDocument: TDSciDocument;

    /// <summary>Extend life of document.</summary>
    procedure AddRefDocument(ADoc: TDSciDocument);

    /// <summary>Release a reference to the document, deleting document if it fades to black.</summary>
    procedure ReleaseDocument(ADoc: TDSciDocument);

    /// <summary>Compact the document buffer and return a read-only pointer to the
    /// characters in the document.</summary>
    function GetCharacterPointer: PByte;

    /// <summary>Return a read-only pointer to a range of characters in the document.
    /// May move the gap so that the range is contiguous, but will only move up
    /// to lengthRange bytes.</summary>
    function GetRangePointer(APosition: NativeInt; ARangeLength: NativeInt): Pointer;

    /// <summary>Create an ILoader*.</summary>
    function CreateLoader(ABytes: NativeInt): Pointer;

    /// <summary>Set the lexer from an ILexer*.</summary>
    procedure SetILexer(AIlexer: Pointer);

