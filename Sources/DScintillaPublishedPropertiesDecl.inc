    /// <summary>Get the set of base styles that can be extended with sub styles
    /// Result is NUL-terminated.</summary>
    property SubStyleBases: UnicodeString read GetSubStyleBases;
    /// <summary>Retrieve the current tab draw mode.
    /// Returns one of SCTD_* constants.</summary>
    property TabDrawMode: TDSciTabDrawMode read GetTabDrawMode write SetTabDrawMode;
    /// <summary>Retrieve the caret line frame width.
    /// Width = 0 means this option is disabled.</summary>
    property CaretLineFrame: Integer read GetCaretLineFrame write SetCaretLineFrame;
    /// <summary>Which action is the save point?</summary>
    property UndoSavePoint: Integer read GetUndoSavePoint write SetUndoSavePoint;
    /// <summary>Get the size of the dots used to mark space characters.</summary>
    property WhitespaceSize: Integer read GetWhitespaceSize write SetWhitespaceSize;
    /// <summary>In read-only mode?</summary>
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    /// <summary>Retrieve the visible size of a tab.</summary>
    property TabWidth: Integer read GetTabWidth write SetTabWidth default 8;
    /// <summary>Is every selected range empty?</summary>
    property SelectionEmpty: Boolean read GetSelectionEmpty;
    /// <summary>Get the start of the range of style numbers used for annotations</summary>
    property AnnotationStyleOffset: Integer read AnnotationGetStyleOffset write AnnotationSetStyleOffset default 0;
    /// <summary>Retrieve whether the maximum scroll position has the last
    /// line at the bottom of the view.</summary>
    property EndAtLastLine: Boolean read GetEndAtLastLine write SetEndAtLastLine default True;
    /// <summary>Get whether mouse gets captured.</summary>
    property MouseDownCaptures: Boolean read GetMouseDownCaptures write SetMouseDownCaptures default True;
    /// <summary>Get the alpha of the selection.</summary>
    property SelAlpha: TDSciAlpha read GetSelAlpha write SetSelAlpha default scaNO_ALPHA;
    /// <summary>Which action is the current point?</summary>
    property UndoCurrent: Integer read GetUndoCurrent write SetUndoCurrent;
    /// <summary>Get the number of characters to have directly indexed categories</summary>
    property CharacterCategoryOptimization: Integer read GetCharacterCategoryOptimization write SetCharacterCategoryOptimization;
    /// <summary>Is the IME displayed in a window or inline?</summary>
    property IMEInteraction: TDSciIMEInteraction read GetIMEInteraction write SetIMEInteraction;
    /// <summary>Get the layer of the background of the line containing the caret.</summary>
    property CaretLineLayer: TDSciLayer read GetCaretLineLayer write SetCaretLineLayer;
    /// <summary>Get cursor type.</summary>
    property Cursor: TDSciCursorShape read GetCursor write SetCursor default sccsNORMAL;
    /// <summary>Get the way autocompletion lists are ordered.</summary>
    property AutoCOrder: TDSciOrdering read AutoCGetOrder write AutoCSetOrder;
    /// <summary>Report change history status.</summary>
    property ChangeHistory: TDSciChangeHistoryOption read GetChangeHistory write SetChangeHistory;
    /// <summary>Get the line end types currently recognised. May be a subset of the allowed types due to lexer limitation.</summary>
    property LineEndTypesActive: TDSciLineEndType read GetLineEndTypesActive;
    /// <summary>Set the maximum height, in rows, of auto-completion and user lists.</summary>
    property AutoCMaxHeight: Integer read AutoCGetMaxHeight write AutoCSetMaxHeight default 5;
    /// <summary>Retrieve the zoom level.</summary>
    property Zoom: Integer read GetZoom write SetZoom default 0;
    /// <summary>Retrieve the lexing language of the document.</summary>
    property Lexer: TDSciLexerId read GetLexer;
    /// <summary>Get currently selected item position in the auto-completion list</summary>
    property AutoCCurrent: Integer read AutoCGetCurrent;
    /// <summary>Are keys always interpreted as Unicode?</summary>
    property KeysUnicode: Boolean read GetKeysUnicode write SetKeysUnicode default False;
    /// <summary>Are white space characters currently visible?
    /// Returns one of SCWS_* constants.</summary>
    property ViewWS: TDSciWhiteSpace read GetViewWS write SetViewWS default scwsINVISIBLE;
    /// <summary>Get the style number used for auto-completion and user lists fonts.</summary>
    property AutoCStyle: Integer read AutoCGetStyle write AutoCSetStyle;
    /// <summary>Retrieve the number of named styles for the lexer.</summary>
    property NamedStyles: Integer read GetNamedStyles;
    /// <summary>Retrieve whether or not autocompletion deletes any word characters
    /// after the inserted text upon completion.</summary>
    property AutoCDropRestOfWord: Boolean read AutoCGetDropRestOfWord write AutoCSetDropRestOfWord default False;
    /// <summary>Get the visibility for the annotations for a view</summary>
    property AnnotationVisible: TDSciAnnotationVisible read AnnotationGetVisible write AnnotationSetVisible default scavHIDDEN;
    /// <summary>Get the time in milliseconds that the caret is on and off.</summary>
    property CaretPeriod: Integer read GetCaretPeriod write SetCaretPeriod default 500;
    /// <summary>Get the way control characters are displayed.</summary>
    property ControlCharSymbol: Integer read GetControlCharSymbol write SetControlCharSymbol default 0;
    /// <summary>Get only highlighting subline instead of whole line.</summary>
    property CaretLineHighlightSubLine: Boolean read GetCaretLineHighlightSubLine write SetCaretLineHighlightSubLine;
    /// <summary>Get whether or not regular caret moves will extend or reduce the selection.</summary>
    property MoveExtendsSelection: Boolean read GetMoveExtendsSelection write SetMoveExtendsSelection;
    /// <summary>Retrieve the limits to idle styling.</summary>
    property IdleStyling: TDSciIdleStyling read GetIdleStyling write SetIdleStyling;
    /// <summary>Retrieve how wrapped sublines are placed. Default is fixed.</summary>
    property WrapIndentMode: TDSciWrapIndentMode read GetWrapIndentMode write SetWrapIndentMode default scwimFIXED;
    /// <summary>Is the vertical scroll bar visible?</summary>
    property VScrollBar: Boolean read GetVScrollBar write SetVScrollBar default True;
    /// <summary>Get auto-completion case insensitive behaviour.</summary>
    property AutoCCaseInsensitiveBehaviour: TDSciCaseInsensitiveBehaviour read AutoCGetCaseInsensitiveBehaviour write AutoCSetCaseInsensitiveBehaviour;
    /// <summary>Retrieve whether text is word wrapped.</summary>
    property WrapMode: TDSciWrap read GetWrapMode write SetWrapMode default scwNONE;
    /// <summary>Return a position which, to avoid performance costs, should not be within
    /// the range of a call to GetRangePointer.</summary>
    property GapPosition: NativeInt read GetGapPosition;
    /// <summary>Get whether drag-and-drop is enabled or disabled</summary>
    property DragDropEnabled: Boolean read GetDragDropEnabled write SetDragDropEnabled;
    /// <summary>Get the foreground colour of additional carets.</summary>
    property AdditionalCaretFore: TColor read GetAdditionalCaretFore write SetAdditionalCaretFore default $7F7F7F;
    /// <summary>Get the background alpha of the caret line.</summary>
    property CaretLineBackAlpha: TDSciAlpha read GetCaretLineBackAlpha write SetCaretLineBackAlpha default scaNO_ALPHA;
    /// <summary>Get the HotspotSingleLine property</summary>
    property HotspotSingleLine: Boolean read GetHotspotSingleLine write SetHotspotSingleLine default True;
    /// <summary>Retrieve indentation size.</summary>
    property Indent: Integer read GetIndent write SetIndent default 0;
    /// <summary>Get the string to separate parts when copying a multiple selection.</summary>
    property CopySeparator: UnicodeString read GetCopySeparator write SetCopySeparator;
    /// <summary>Get the modifier key used for rectangular selection.</summary>
    property RectangularSelectionModifier: TDSciKeyModSet read GetRectangularSelectionModifier write SetRectangularSelectionModifier default [];
    /// <summary>Is the selection end of line filled?</summary>
    property SelEOLFilled: Boolean read GetSelEOLFilled write SetSelEOLFilled default False;
    /// <summary>Bit set of LineEndType enumertion for which line ends beyond the standard
    /// LF, CR, and CRLF are supported by the lexer.</summary>
    property LineEndTypesSupported: TDSciLineEndType read GetLineEndTypesSupported;
    /// <summary>Get the set of characters making up punctuation characters</summary>
    property PunctuationChars: AnsiString read GetPunctuationChars write SetPunctuationChars;
    /// <summary>Is the selection visible or hidden?</summary>
    property SelectionHidden: Boolean read GetSelectionHidden;
    /// <summary>Retrieve the effect of pasting when there are multiple selections.</summary>
    property MultiPaste: TDSciMultiPaste read GetMultiPaste write SetMultiPaste;
    /// <summary>Get the set of characters making up words for when moving or selecting by word.
    /// Returns the number of characters</summary>
    property WordChars: AnsiString read GetWordChars write SetWordChars;
    /// <summary>Get the maximum width, in characters, of auto-completion and user lists.</summary>
    property AutoCMaxWidth: Integer read AutoCGetMaxWidth write AutoCSetMaxWidth default 0;
    /// <summary>Whether switching to rectangular mode while selecting with the mouse is allowed.</summary>
    property MouseSelectionRectangularSwitch: Boolean read GetMouseSelectionRectangularSwitch write SetMouseSelectionRectangularSwitch;
    /// <summary>Get which document modification events are sent to the container.</summary>
    property ModEventMask: TDSciModificationFlagsSet read GetModEventMask write SetModEventMask default [scmfINSERT_TEXT, scmfDELETE_TEXT, scmfCHANGE_STYLE, scmfCHANGE_FOLD, scmfUSER, scmfUNDO, scmfREDO, scmfMULTI_STEP_UNDO_REDO, scmfCHANGE_MARKER, scmfBEFORE_INSERT, scmfBEFORE_DELETE, scmfCHANGE_INDICATOR, scmfCHANGE_LINE_STATE, scmfCHANGE_MARGIN, scmfCHANGE_ANNOTATION, scmfCONTAINER];
    /// <summary>Get the start of the range of style numbers used for end of line annotations</summary>
    property EOLAnnotationStyleOffset: Integer read EOLAnnotationGetStyleOffset write EOLAnnotationSetStyleOffset;
    /// <summary>How many margins are there?.</summary>
    property Margins: Integer read GetMargins write SetMargins;
    /// <summary>Returns true if overtype mode is active otherwise false is returned.</summary>
    property Overtype: Boolean read GetOvertype write SetOvertype default False;
    /// <summary>Returns the print colour mode.</summary>
    property PrintColourMode: TDSciPrintOption read GetPrintColourMode write SetPrintColourMode default scpoNORMAL;
    /// <summary>Returns the size in pixels of the left margin.</summary>
    property MarginLeft: Integer read GetMarginLeft write SetMarginLeft default 1;
    /// <summary>Get extra ascent for each line</summary>
    property ExtraAscent: Integer read GetExtraAscent write SetExtraAscent default 0;
    /// <summary>Whether multiple selections can be made</summary>
    property MultipleSelection: Boolean read GetMultipleSelection write SetMultipleSelection default False;
    /// <summary>Returns the width of the insert mode caret.</summary>
    property CaretWidth: Integer read GetCaretWidth write SetCaretWidth default 1;
    /// <summary>Is the caret line always visible?</summary>
    property CaretLineVisibleAlways: Boolean read GetCaretLineVisibleAlways write SetCaretLineVisibleAlways;
    /// <summary>Get the scale factor in percent for auto-completion list images.</summary>
    property AutoCImageScale: Integer read AutoCGetImageScale write AutoCSetImageScale;
    /// <summary>Can the caret preferred x position only be changed by explicit movement commands?</summary>
    property CaretSticky: TDSciCaretSticky read GetCaretSticky write SetCaretSticky default sccsOFF;
    /// <summary>Get whether underlining for active hotspots.</summary>
    property HotspotActiveUnderline: Boolean read GetHotspotActiveUnderline write SetHotspotActiveUnderline default True;
    /// <summary>Retrive the display mode of visual flags for wrapped lines.</summary>
    property WrapVisualFlags: TDSciWrapVisualFlagSet read GetWrapVisualFlags write SetWrapVisualFlags default [];
    /// <summary>Retrieve the auto-completion list type-separator character.</summary>
    property AutoCTypeSeparator: AnsiChar read AutoCGetTypeSeparator write AutoCSetTypeSeparator default '?';
    /// <summary>Retrieve whether the scroll width tracks wide lines.</summary>
    property ScrollWidthTracking: Boolean read GetScrollWidthTracking write SetScrollWidthTracking default False;
    /// <summary>Retrieve line character index state.</summary>
    property LineCharacterIndex: TDSciLineCharacterIndexType read GetLineCharacterIndex;
    /// <summary>Does a tab pressed when caret is within indentation indent?</summary>
    property TabIndents: Boolean read GetTabIndents write SetTabIndents default True;
    /// <summary>Is printing line wrapped?</summary>
    property PrintWrapMode: TDSciWrap read GetPrintWrapMode write SetPrintWrapMode default scwWORD;
    /// <summary>Get the code page used to interpret the bytes of the document as characters.</summary>
    property CodePage: Integer read GetCodePage write SetCodePage default 0;
    /// <summary>Retrieve the text in the target.</summary>
    property TargetText: UnicodeString read GetTargetText;
    /// <summary>Retrieve the colour used in edge indication.</summary>
    property EdgeColour: TColor read GetEdgeColour write SetEdgeColour default clSilver;
    /// <summary>Retrive the start indent for wrapped lines.</summary>
    property WrapStartIndent: Integer read GetWrapStartIndent write SetWrapStartIndent default 0;
    /// <summary>How many undo actions are in the history?</summary>
    property UndoActions: Integer read GetUndoActions;
    /// <summary>How many entries are allocated to the position cache?</summary>
    property PositionCache: Integer read GetPositionCache write SetPositionCache default 1024;
    /// <summary>Which action is the tentative point?</summary>
    property UndoTentative: Integer read GetUndoTentative write SetUndoTentative;
    /// <summary>Retrieve whether tabs will be used in indentation.</summary>
    property UseTabs: Boolean read GetUseTabs write SetUseTabs default True;
    /// <summary>Retrieve state of ignore case flag.</summary>
    property AutoCIgnoreCase: Boolean read AutoCGetIgnoreCase write AutoCSetIgnoreCase default False;
    /// <summary>Get the identifier.</summary>
    property Identifier: Integer read GetIdentifier write SetIdentifier;
    /// <summary>Retrieve the time the mouse must sit still to generate a mouse dwell event.</summary>
    property MouseDwellTime: Integer read GetMouseDwellTime write SetMouseDwellTime default SC_TIME_FOREVER;
    /// <summary>Retrieve serialized form of selection.</summary>
    property SelectionSerialized: UnicodeString read GetSelectionSerialized write SetSelectionSerialized;
    /// <summary>Is an undo sequence active?</summary>
    property UndoSequence: Integer read GetUndoSequence;
    /// <summary>Returns the size in pixels of the right margin.</summary>
    property MarginRight: Integer read GetMarginRight write SetMarginRight default 1;
    /// <summary>Retrieve whether or not autocompletion is hidden automatically when nothing matches.</summary>
    property AutoCAutoHide: Boolean read AutoCGetAutoHide write AutoCSetAutoHide default True;
    /// <summary>Get automatic folding behaviours.</summary>
    property AutomaticFold: TDSciAutomaticFold read GetAutomaticFold write SetAutomaticFold;
    /// <summary>Retrieve the quality level for text.</summary>
    property FontQuality: TDSciFontQuality read GetFontQuality write SetFontQuality;
    /// <summary>Get the tech.</summary>
    property Technology: TDSciTechnology read GetTechnology write SetTechnology;
    /// <summary>Retrieve the current end of line mode - one of CRLF, CR, or LF.</summary>
    property EOLMode: TDSciEndOfLine read GetEOLMode write SetEOLMode default sceolCR_LF;
    /// <summary>Get convert-on-paste setting</summary>
    property PasteConvertEndings: Boolean read GetPasteConvertEndings write SetPasteConvertEndings default True;
    /// <summary>Get the virtual space of the target start</summary>
    property TargetStartVirtualSpace: NativeInt read GetTargetStartVirtualSpace write SetTargetStartVirtualSpace;
    /// <summary>Retrieve the degree of caching of layout information.</summary>
    property LayoutCache: TDSciLineCache read GetLayoutCache write SetLayoutCache default sclcCARET;
    /// <summary>Are all lines visible?</summary>
    property AllLinesVisible: Boolean read GetAllLinesVisible;
    /// <summary>Retrieve the edge highlight mode.</summary>
    property EdgeMode: TDSciEdgeVisualStyle read GetEdgeMode write SetEdgeMode default scevsNONE;
    /// <summary>Retrieve number of bits in style bytes used to hold the lexical state.</summary>
    property StyleBits: Integer read GetStyleBits write SetStyleBits default 5;
    /// <summary>Return options for virtual space behaviour.</summary>
    property VirtualSpaceOptions: TDSciVirtualSpaceSet read GetVirtualSpaceOptions write SetVirtualSpaceOptions default [];
    /// <summary>Get the search flags used by SearchInTarget.</summary>
    property SearchFlags: TDSciFindOptionSet read GetSearchFlags write SetSearchFlags default [];
    /// <summary>Get the minimum visual width of a tab.</summary>
    property TabMinimumWidth: Integer read GetTabMinimumWidth write SetTabMinimumWidth;
    /// <summary>Whether typing can be performed into multiple selections</summary>
    property AdditionalSelectionTyping: Boolean read GetAdditionalSelectionTyping write SetAdditionalSelectionTyping default False;
    /// <summary>Get the layer for drawing selections</summary>
    property SelectionLayer: TDSciLayer read GetSelectionLayer write SetSelectionLayer;
    /// <summary>How many phases is drawing done in?</summary>
    property PhasesDraw: TDSciPhasesDraw read GetPhasesDraw write SetPhasesDraw;
    /// <summary>Get currently selected item text in the auto-completion list
    /// Returns the length of the item text
    /// Result is NUL-terminated.</summary>
    property AutoCCurrentText: UnicodeString read AutoCGetCurrentText;
    /// <summary>How many selections are there?</summary>
    property Selections: Integer read GetSelections;
    /// <summary>Is drawing done in two phases with backgrounds drawn before foregrounds?</summary>
    property TwoPhaseDraw: Boolean read GetTwoPhaseDraw write SetTwoPhaseDraw default True;
    /// <summary>Get the locale for displaying text.</summary>
    property FontLocale: UnicodeString read GetFontLocale write SetFontLocale;
    /// <summary>Report undo selection history status.</summary>
    property UndoSelectionHistory: TDSciUndoSelectionHistoryOption read GetUndoSelectionHistory write SetUndoSelectionHistory;
    /// <summary>Is the background of the line containing the caret in a different colour?</summary>
    property CaretLineVisible: Boolean read GetCaretLineVisible write SetCaretLineVisible default False;
    /// <summary>Get whether mouse wheel can be active outside the window.</summary>
    property MouseWheelCaptures: Boolean read GetMouseWheelCaptures write SetMouseWheelCaptures;
    /// <summary>Retrieve the name of the lexer.
    /// Return the length of the text.
    /// Result is NUL-terminated.</summary>
    property LexerLanguage: UnicodeString read GetLexerLanguage write SetLexerLanguage;
    /// <summary>Get maximum number of threads used for layout</summary>
    property LayoutThreads: Integer read GetLayoutThreads write SetLayoutThreads;
    /// <summary>Returns the current style of the caret.</summary>
    property CaretStyle: TDSciCaretStyle read GetCaretStyle write SetCaretStyle default sccsLINE;
    /// <summary>Get extra descent for each line</summary>
    property ExtraDescent: Integer read GetExtraDescent write SetExtraDescent default 0;
    /// <summary>Is drawing done first into a buffer or direct to the screen?</summary>
    property BufferedDraw: Boolean read GetBufferedDraw write SetBufferedDraw default True;
    /// <summary>Retrieve the document width assumed for scrolling.</summary>
    property ScrollWidth: Integer read GetScrollWidth write SetScrollWidth default 2000;
    /// <summary>Get the colour of the background of the line containing the caret.</summary>
    property CaretLineBack: TColor read GetCaretLineBack write SetCaretLineBack default clYellow;
    /// <summary>Get whether command events are sent to the container.</summary>
    property CommandEvents: Boolean read GetCommandEvents write SetCommandEvents;
    /// <summary>Get the current indicator</summary>
    property IndicatorCurrent: Integer read GetIndicatorCurrent write SetIndicatorCurrent;
    /// <summary>Get the set of characters making up whitespace for when moving or selecting by word.</summary>
    property WhitespaceChars: UnicodeString read GetWhitespaceChars write SetWhitespaceChars;
    /// <summary>Report accessibility status.</summary>
    property Accessibility: TDSciAccessibility read GetAccessibility write SetAccessibility;
    /// <summary>Retrieve autocompletion options.</summary>
    property AutoCOptions: TDSciAutoCompleteOption read AutoCGetOptions write AutoCSetOptions;
    /// <summary>Retrieve whether auto-completion cancelled by backspacing before start.</summary>
    property AutoCCancelAtStart: Boolean read AutoCGetCancelAtStart write AutoCSetCancelAtStart default True;
    /// <summary>Is undo history being collected?</summary>
    property UndoCollection: Boolean read GetUndoCollection write SetUndoCollection default True;
    /// <summary>Get the style of fold display text.</summary>
    property FoldDisplayTextStyle: TDSciFoldDisplayTextStyle read FoldDisplayTextGetStyle write FoldDisplayTextSetStyle;
    /// <summary>Get the line end types currently allowed.</summary>
    property LineEndTypesAllowed: TDSciLineEndType read GetLineEndTypesAllowed write SetLineEndTypesAllowed;
    /// <summary>Get the foreground colour of the caret.</summary>
    property CaretFore: TColor read GetCaretFore write SetCaretFore default clBlack;
    /// <summary>Get the margin options.</summary>
    property MarginOptions: TDSciMarginOption read GetMarginOptions write SetMarginOptions;
    /// <summary>Retrieve the effect of autocompleting when there are multiple selections.</summary>
    property AutoCMulti: TDSciMultiAutoComplete read AutoCGetMulti write AutoCSetMulti;
    /// <summary>Get the virtual space of the target end</summary>
    property TargetEndVirtualSpace: NativeInt read GetTargetEndVirtualSpace write SetTargetEndVirtualSpace;
    /// <summary>Does a backspace pressed when caret is within indentation unindent?</summary>
    property BackSpaceUnIndents: Boolean read GetBackSpaceUnIndents write SetBackSpaceUnIndents default False;
    /// <summary>Whether additional carets are visible</summary>
    property AdditionalCaretsVisible: Boolean read GetAdditionalCaretsVisible write SetAdditionalCaretsVisible;
    /// <summary>Retrieve the auto-completion list separator character.</summary>
    property AutoCSeparator: AnsiChar read AutoCGetSeparator write AutoCSetSeparator default ' ';
    /// <summary>Get the current indicator value</summary>
    property IndicatorValue: Integer read GetIndicatorValue write SetIndicatorValue;
    /// <summary>Whether additional carets will blink</summary>
    property AdditionalCaretsBlink: Boolean read GetAdditionalCaretsBlink write SetAdditionalCaretsBlink default True;
    /// <summary>Retrive the location of visual flags for wrapped lines.</summary>
    property WrapVisualFlagsLocation: TDSciWrapVisualLocationSet read GetWrapVisualFlagsLocation write SetWrapVisualFlagsLocation default [];
    /// <summary>Returns the print magnification.</summary>
    property PrintMagnification: Integer read GetPrintMagnification write SetPrintMagnification default 0;
    /// <summary>Retrieve bidirectional text display state.</summary>
    property Bidirectional: TDSciBidirectional read GetBidirectional write SetBidirectional;
    /// <summary>Get the visibility for the end of line annotations for a view</summary>
    property EOLAnnotationVisible: TDSciEOLAnnotationVisible read EOLAnnotationGetVisible write EOLAnnotationSetVisible;
    /// <summary>Get the highlighted indentation guide column.</summary>
    property HighlightGuide: NativeInt read GetHighlightGuide write SetHighlightGuide default 0;
    /// <summary>Get the start of the range of style numbers used for margin text</summary>
    property MarginStyleOffset: Integer read MarginGetStyleOffset write MarginSetStyleOffset default 0;
    /// <summary>Are the end of line characters visible?</summary>
    property ViewEOL: Boolean read GetViewEOL write SetViewEOL default False;
    /// <summary>Retrieve the column number which text should be kept within.</summary>
    property EdgeColumn: NativeInt read GetEdgeColumn write SetEdgeColumn default 0;
    /// <summary>Is the horizontal scroll bar visible?</summary>
    property HScrollBar: Boolean read GetHScrollBar write SetHScrollBar default True;
    /// <summary>Get which document options are set.</summary>
    property DocumentOptions: TDSciDocumentOption read GetDocumentOptions;
    /// <summary>Get the alpha of the selection.</summary>
    property AdditionalSelAlpha: TDSciAlpha read GetAdditionalSelAlpha write SetAdditionalSelAlpha default scaNO_ALPHA;
    /// <summary>Are the indentation guides visible?</summary>
    property IndentationGuides: TDSciIndentView read GetIndentationGuides write SetIndentationGuides default scivNONE;
    /// <summary>Retrieve whether a single item auto-completion list automatically choose the item.</summary>
    property AutoCChooseSingle: Boolean read AutoCGetChooseSingle write AutoCSetChooseSingle default False;
    /// <summary>Which action is the detach point?</summary>
    property UndoDetach: Integer read GetUndoDetach write SetUndoDetach;
