    /// <summary>Retrieve the mouse click sensitivity of a margin.</summary>
    property MarginSensitiveN[AMargin: Integer]: Boolean read GetMarginSensitiveN write SetMarginSensitiveN;
    /// <summary>Return the virtual space of the anchor of the nth selection.</summary>
    property SelectionNAnchorVirtualSpace[ASelection: Integer]: NativeInt read GetSelectionNAnchorVirtualSpace write SetSelectionNAnchorVirtualSpace;
    /// <summary>Get whether an element has been set by SetElementColour.
    /// When false, a platform-defined or default colour is used.</summary>
    property ElementIsSet[AElement: TDSciElement]: Boolean read GetElementIsSet;
    /// <summary>Set the width for future RGBA image data.</summary>
    property RGBAImageWidth: Integer write RGBAImageSetWidth;
    /// <summary>Set the background colour of additional selections.
    /// Must have previously called SetSelBack with non-zero first argument for this to have an effect.</summary>
    property AdditionalSelBack: TColor write SetAdditionalSelBack;
    /// <summary>Get the size of characters of a style.</summary>
    property StyleSize[AStyle: Integer]: Integer read StyleGetSize write StyleSetSize;
    /// <summary>Get the background colour of a style.</summary>
    property StyleBack[AStyle: Integer]: TColor read StyleGetBack write StyleSetBack;
    /// <summary>Returns the virtual space at the end of the selection.</summary>
    property SelectionNEndVirtualSpace[ASelection: Integer]: NativeInt read GetSelectionNEndVirtualSpace;
    /// <summary>Get the xOffset (ie, horizontal scroll position).</summary>
    property XOffset: Integer read GetXOffset write SetXOffset;
    /// <summary>Set the foreground colour of additional selections.
    /// Must have previously called SetSelFore with non-zero first argument for this to have an effect.</summary>
    property AdditionalSelFore: TColor write SetAdditionalSelFore;
    /// <summary>Set the width of strokes used in .01 pixels so 50  = 1/2 pixel width.</summary>
    property MarkerStrokeWidth[AMarkerNumber: Integer]: Integer write MarkerSetStrokeWidth;
    /// <summary>Get is a style bold or not.</summary>
    property StyleBold[AStyle: Integer]: Boolean read StyleGetBold write StyleSetBold;
    /// <summary>Get is a style visible or not.</summary>
    property StyleVisible[AStyle: Integer]: Boolean read StyleGetVisible write StyleSetVisible;
    /// <summary>Set the identifiers that are shown in a particular style</summary>
    property Identifiers[AStyle: Integer]: AnsiString write SetIdentifiers;
    /// <summary>Get the style number for the annotations for a line</summary>
    property AnnotationStyle[ALine: NativeInt]: Integer read AnnotationGetStyle write AnnotationSetStyle;
    /// <summary>Returns the unsigned style byte at the position.</summary>
    property StyleIndexAt[APos: NativeInt]: Integer read GetStyleIndexAt;
    /// <summary>Is a header line expanded?</summary>
    property FoldExpanded[ALine: NativeInt]: Boolean read GetFoldExpanded write SetFoldExpanded;
    /// <summary>Returns the virtual space at the start of the selection.</summary>
    property SelectionNStartVirtualSpace[ASelection: Integer]: NativeInt read GetSelectionNStartVirtualSpace;
    /// <summary>Set the alpha used for a marker that is drawn in the text area, not the margin.</summary>
    property MarkerAlpha[AMarkerNumber: Integer]: TDSciAlpha write MarkerSetAlpha;
    /// <summary>Retrieve the number of columns that a line is indented.</summary>
    property LineIndentation[ALine: NativeInt]: Integer read GetLineIndentation write SetLineIndentation;
    /// <summary>Get the character get of the font in a style.</summary>
    property StyleCharacterSet[AStyle: Integer]: TDSciCharacterSet read StyleGetCharacterSet write StyleSetCharacterSet;
    /// <summary>Retrieve the width of a margin in pixels.</summary>
    property MarginWidthN[AMargin: Integer]: Integer read GetMarginWidthN write SetMarginWidthN;
    /// <summary>Which selection is the main selection</summary>
    property MainSelection: Integer read GetMainSelection write SetMainSelection;
    /// <summary>Return the virtual space of the caret of the nth selection.</summary>
    property SelectionNCaretVirtualSpace[ASelection: Integer]: NativeInt read GetSelectionNCaretVirtualSpace write SetSelectionNCaretVirtualSpace;
    /// <summary>What is the position of an action?</summary>
    property UndoActionPosition[AAction: Integer]: NativeInt read GetUndoActionPosition;
    /// <summary>Is the document different from when it was last saved?</summary>
    property Modify: Boolean read GetModify;
    /// <summary>Set the height for future RGBA image data.</summary>
    property RGBAImageHeight: Integer write RGBAImageSetHeight;
    /// <summary>Get whether a style may be monospaced.</summary>
    property StyleCheckMonospaced[AStyle: Integer]: Boolean read StyleGetCheckMonospaced write StyleSetCheckMonospaced;
    /// <summary>Returns the position of the opposite end of the selection to the caret.</summary>
    property Anchor: NativeInt read GetAnchor write SetAnchor;
    /// <summary>Retrieve the foreground hover colour of an indicator.</summary>
    property IndicHoverFore[AIndicator: Integer]: TColor read IndicGetHoverFore write IndicSetHoverFore;
    /// <summary>Returns the position at the start of the selection.</summary>
    property SelectionStart: NativeInt read GetSelectionStart write SetSelectionStart;
    /// <summary>Set the background colour for the call tip.</summary>
    property CallTipBack: TColor write CallTipSetBack;
    /// <summary>Retrieve the marker mask of a margin.</summary>
    property MarginMaskN[AMargin: Integer]: Integer read GetMarginMaskN write SetMarginMaskN;
    /// <summary>Retrieve the number of bits the current lexer needs for styling.</summary>
    property StyleBitsNeeded: Integer read GetStyleBitsNeeded;
    /// <summary>Get the mode of the current selection.</summary>
    property SelectionMode: TDSciSelectionMode read GetSelectionMode write SetSelectionMode;
    /// <summary>Find the last child line of a header line.</summary>
    property LastChild[ALine: NativeInt; ALevel: TDSciFoldLevel]: NativeInt read GetLastChild;
    /// <summary>Retrieve the position of the last correctly styled character.</summary>
    property EndStyled: NativeInt read GetEndStyled;
    /// <summary>Get the foreground colour of a style.</summary>
    property StyleFore[AStyle: Integer]: TColor read StyleGetFore write StyleSetFore;
    /// <summary>Retrieve the column number of a position, taking tab width into account.</summary>
    property Column[APos: NativeInt]: NativeInt read GetColumn;
    /// <summary>Get the colour of an element.</summary>
    property ElementBaseColour[AElement: TDSciElement]: TDSciColourAlpha read GetElementBaseColour;
    /// <summary>Get the size of characters of a style in points multiplied by 100</summary>
    property StyleSizeFractional[AStyle: Integer]: Integer read StyleGetSizeFractional write StyleSetSizeFractional;
    /// <summary>Retrieve the cursor shown in a margin.</summary>
    property MarginCursorN[AMargin: Integer]: TDSciCursorShape read GetMarginCursorN write SetMarginCursorN;
    /// <summary>What is the type of an action?</summary>
    property UndoActionType[AAction: Integer]: Integer read GetUndoActionType;
    /// <summary>Get is a style to have its end of line filled or not.</summary>
    property StyleEOLFilled[AStyle: Integer]: Boolean read StyleGetEOLFilled write StyleSetEOLFilled;
    /// <summary>Returns the position at the start of the selection.</summary>
    property SelectionNStart[ASelection: Integer]: NativeInt read GetSelectionNStart write SetSelectionNStart;
    /// <summary>Retrieve the number of characters in the document.</summary>
    property TextLength: NativeInt read GetTextLength;
    /// <summary>Set the background colour used for a particular marker number when its folding block is selected.</summary>
    property MarkerBackSelectedTranslucent[AMarkerNumber: Integer]: TDSciColourAlpha write MarkerSetBackSelectedTranslucent;
    /// <summary>Get the position that ends the target.</summary>
    property TargetEnd: NativeInt read GetTargetEnd write SetTargetEnd;
    /// <summary>Retrieve the stroke width of an indicator.</summary>
    property IndicStrokeWidth[AIndicator: Integer]: Integer read IndicGetStrokeWidth write IndicSetStrokeWidth;
    /// <summary>The number of sub styles associated with a base style</summary>
    property SubStylesLength[AStyleBase: Integer]: Integer read GetSubStylesLength;
    /// <summary>Retrieve whether indicator drawn under or over text.</summary>
    property IndicUnder[AIndicator: Integer]: Boolean read IndicGetUnder write IndicSetUnder;
    /// <summary>Get is a style mixed case, or to force upper or lower case.</summary>
    property StyleCase[AStyle: Integer]: TDSciCaseVisible read StyleGetCase write StyleSetCase;
    /// <summary>Get whether an element supports translucency.</summary>
    property ElementAllowsTranslucent[AElement: TDSciElement]: Boolean read GetElementAllowsTranslucent;
    /// <summary>Return the anchor position of the rectangular selection.</summary>
    property RectangularSelectionAnchor: NativeInt read GetRectangularSelectionAnchor write SetRectangularSelectionAnchor;
    /// <summary>Get the position that starts the target.</summary>
    property TargetStart: NativeInt read GetTargetStart write SetTargetStart;
    /// <summary>Return the virtual space of the caret of the rectangular selection.</summary>
    property RectangularSelectionCaretVirtualSpace: NativeInt read GetRectangularSelectionCaretVirtualSpace write SetRectangularSelectionCaretVirtualSpace;
    /// <summary>Get the style number for the end of line annotations for a line</summary>
    property EOLAnnotationStyle[ALine: NativeInt]: Integer read EOLAnnotationGetStyle write EOLAnnotationSetStyle;
    /// <summary>Get the weight of characters of a style.</summary>
    property StyleWeight[AStyle: Integer]: TDSciFontWeight read StyleGetWeight write StyleSetWeight;
    /// <summary>Retrieve the hover style of an indicator.</summary>
    property IndicHoverStyle[AIndicator: Integer]: TDSciIndicatorStyle read IndicGetHoverStyle write IndicSetHoverStyle;
    /// <summary>What is the text of an action?</summary>
    property UndoActionText[AAction: Integer]: UnicodeString read GetUndoActionText;
    /// <summary>Set position of calltip, above or below text.</summary>
    property CallTipPosition: Boolean write CallTipSetPosition;
    /// <summary>For a secondary style, return the primary style, else return the argument.</summary>
    property PrimaryStyleFromStyle[AStyle: Integer]: Integer read GetPrimaryStyleFromStyle;
    /// <summary>Retrieve the style of an indicator.</summary>
    property IndicStyle[AIndicator: Integer]: TDSciIndicatorStyle read IndicGetStyle write IndicSetStyle;
    /// <summary>Return the caret position of the nth selection.</summary>
    property SelectionNCaret[ASelection: Integer]: NativeInt read GetSelectionNCaret write SetSelectionNCaret;
    /// <summary>Retrieve a "property" value previously set with SetProperty,
    /// with "$()" variable replacement on returned buffer.
    /// Result is NUL-terminated.</summary>
    property PropertyExpanded[AKey: UnicodeString]: UnicodeString read GetPropertyExpanded;
    /// <summary>Get multi edge positions.</summary>
    property MultiEdgeColumn[AWhich: Integer]: NativeInt read GetMultiEdgeColumn;
    /// <summary>Set the foreground colour used for a particular marker number.</summary>
    property MarkerFore[AMarkerNumber: Integer]: TColor write MarkerSetFore;
    /// <summary>The starting style number for the sub styles associated with a base style</summary>
    property SubStylesStart[AStyleBase: Integer]: Integer read GetSubStylesStart;
    /// <summary>Get is a style underlined or not.</summary>
    property StyleUnderline[AStyle: Integer]: Boolean read StyleGetUnderline write StyleSetUnderline;
    /// <summary>Get the stretch of characters of a style.</summary>
    property StyleStretch[AStyle: Integer]: TDSciFontStretch read StyleGetStretch write StyleSetStretch;
    /// <summary>Return the virtual space of the anchor of the rectangular selection.</summary>
    property RectangularSelectionAnchorVirtualSpace: NativeInt read GetRectangularSelectionAnchorVirtualSpace write SetRectangularSelectionAnchorVirtualSpace;
    /// <summary>For a sub style, return the base style, else return the argument.</summary>
    property StyleFromSubStyle[ASubStyle: Integer]: Integer read GetStyleFromSubStyle;
    /// <summary>Get internal focus flag.</summary>
    property Focus: Boolean read GetFocus write SetFocus;
    /// <summary>Retrieve the fold level of a line.</summary>
    property FoldLevel[ALine: NativeInt]: TDSciFoldLevel read GetFoldLevel write SetFoldLevel;
    /// <summary>Get the alpha outline colour of the given indicator.</summary>
    property IndicOutlineAlpha[AIndicator: Integer]: TDSciAlpha read IndicGetOutlineAlpha write IndicSetOutlineAlpha;
    /// <summary>Retrieve the extra styling information for a line.</summary>
    property LineState[ALine: NativeInt]: Integer read GetLineState write SetLineState;
    /// <summary>Retrieve a "property" value previously set with SetProperty,
    /// interpreted as an int AFTER any "$()" variable replacement.</summary>
    property PropertyInt[AKey: UnicodeString; ADefault: Integer]: Integer read GetPropertyInt;
    /// <summary>Retrieve the last line number that has line state.</summary>
    property MaxLineState: Integer read GetMaxLineState;
    /// <summary>Retrieve the attributes of an indicator.</summary>
    property IndicFlags[AIndicator: Integer]: TDSciIndicFlag read IndicGetFlags write IndicSetFlags;
    /// <summary>Returns the position at the end of the selection.</summary>
    property SelectionEnd: NativeInt read GetSelectionEnd write SetSelectionEnd;
    /// <summary>Return the caret position of the rectangular selection.</summary>
    property RectangularSelectionCaret: NativeInt read GetRectangularSelectionCaret write SetRectangularSelectionCaret;
    /// <summary>Get error status.</summary>
    property Status: TDSciStatus read GetStatus write SetStatus;
    /// <summary>Retrieve the type of a margin.</summary>
    property MarginTypeN[AMargin: Integer]: TDSciMarginType read GetMarginTypeN write SetMarginTypeN;
    /// <summary>Returns the character byte at the position.</summary>
    property CharAt[APos: NativeInt]: Integer read GetCharAt;
    /// <summary>Retrieve the display line at the top of the display.</summary>
    property FirstVisibleLine: NativeInt read GetFirstVisibleLine write SetFirstVisibleLine;
    /// <summary>Get is a style a hotspot or not.</summary>
    property StyleHotSpot[AStyle: Integer]: Boolean read StyleGetHotSpot write StyleSetHotSpot;
    /// <summary>Retrieve the background colour of a margin</summary>
    property MarginBackN[AMargin: Integer]: TColor read GetMarginBackN write SetMarginBackN;
    /// <summary>Set the background colour used for a particular marker number.</summary>
    property MarkerBack[AMarkerNumber: Integer]: TColor write MarkerSetBack;
    /// <summary>Get the colour of a representation.</summary>
    property RepresentationColour[AEncodedCharacter: UnicodeString]: TDSciColourAlpha read GetRepresentationColour write SetRepresentationColour;
    /// <summary>Set the foreground colour for the call tip.</summary>
    property CallTipFore: TColor write CallTipSetFore;
    /// <summary>Returns the position at the end of the selection.</summary>
    property SelectionNEnd[ASelection: Integer]: NativeInt read GetSelectionNEnd write SetSelectionNEnd;
    /// <summary>Get the styles in the text margin for a line</summary>
    property MarginStyles[ALine: NativeInt]: TDSciStyles read MarginGetStyles write MarginSetStyles;
    /// <summary>Get the alpha fill colour of the given indicator.</summary>
    property IndicAlpha[AIndicator: Integer]: TDSciAlpha read IndicGetAlpha write IndicSetAlpha;
    /// <summary>Set some style options for folding.</summary>
    property FoldFlags: TDSciFoldFlagSet write SetFoldFlags;
    /// <summary>Is a line visible?</summary>
    property LineVisible[ALine: NativeInt]: Boolean read GetLineVisible;
    /// <summary>Get is a style changeable or not (read only).
    /// Experimental feature, currently buggy.</summary>
    property StyleChangeable[AStyle: Integer]: Boolean read StyleGetChangeable write StyleSetChangeable;
    /// <summary>Get the invisible representation for a style.</summary>
    property StyleInvisibleRepresentation[AStyle: Integer]: UnicodeString read StyleGetInvisibleRepresentation write StyleSetInvisibleRepresentation;
    /// <summary>Get the appearance of a representation.</summary>
    property RepresentationAppearance[AEncodedCharacter: UnicodeString]: TDSciRepresentationAppearance read GetRepresentationAppearance write SetRepresentationAppearance;
    /// <summary>Get the text in the text margin for a line</summary>
    property MarginText[ALine: NativeInt]: UnicodeString read MarginGetText write MarginSetText;
    /// <summary>Returns the number of lines in the document. There is always at least one.</summary>
    property LineCount: NativeInt read GetLineCount;
    /// <summary>Set the background colour used for a particular marker number when its folding block is selected.</summary>
    property MarkerBackSelected[AMarkerNumber: Integer]: TColor write MarkerSetBackSelected;
    /// <summary>Get the position after the last visible characters on a line.</summary>
    property LineEndPosition[ALine: NativeInt]: NativeInt read GetLineEndPosition;
    /// <summary>Retrieve the value of a tag from a regular expression search.
    /// Result is NUL-terminated.</summary>
    property Tag[ATagNumber: Integer]: UnicodeString read GetTag;
    /// <summary>Get the end of line annotation text for a line</summary>
    property EOLAnnotationText[ALine: NativeInt]: UnicodeString read EOLAnnotationGetText write EOLAnnotationSetText;
    /// <summary>Return the anchor position of the nth selection.</summary>
    property SelectionNAnchor[ASelection: Integer]: NativeInt read GetSelectionNAnchor write SetSelectionNAnchor;
    /// <summary>Retrieve the position before the first non indentation character on a line.</summary>
    property LineIndentPosition[ALine: NativeInt]: NativeInt read GetLineIndentPosition;
    /// <summary>Define a set of characters that when typed will cause the autocompletion to
    /// choose the selected item.</summary>
    property AutoCFillUps: UnicodeString write AutoCSetFillUps;
    /// <summary>Get the style number for the text margin for a line</summary>
    property MarginStyle[ALine: NativeInt]: Integer read MarginGetStyle write MarginSetStyle;
    /// <summary>Get the layer used for a marker that is drawn in the text area, not the margin.</summary>
    property MarkerLayer[AMarkerNumber: Integer]: TDSciLayer read MarkerGetLayer write MarkerSetLayer;
    /// <summary>Set up the key words used by the lexer.</summary>
    property KeyWords[AKeywordSet: Integer]: UnicodeString write SetKeyWords;
    /// <summary>Set the foreground colour used for a particular marker number.</summary>
    property MarkerForeTranslucent[AMarkerNumber: Integer]: TDSciColourAlpha write MarkerSetForeTranslucent;
    /// <summary>Returns the position of the caret.</summary>
    property CurrentPos: NativeInt read GetCurrentPos write SetCurrentPos;
    /// <summary>Get the annotation styles for a line</summary>
    property AnnotationStyles[ALine: NativeInt]: TDSciStyles read AnnotationGetStyles write AnnotationSetStyles;
    /// <summary>Get the annotation text for a line</summary>
    property AnnotationText[ALine: NativeInt]: UnicodeString read AnnotationGetText write AnnotationSetText;
    /// <summary>Get the number of annotation lines for a line</summary>
    property AnnotationLines[ALine: NativeInt]: Integer read AnnotationGetLines;
    /// <summary>Set the background colour used for a particular marker number.</summary>
    property MarkerBackTranslucent[AMarkerNumber: Integer]: TDSciColourAlpha write MarkerSetBackTranslucent;
    /// <summary>Set the foreground colour for the highlighted part of the call tip.</summary>
    property CallTipForeHlt: TColor write CallTipSetForeHlt;
    /// <summary>Returns the style byte at the position.</summary>
    property StyleAt[APos: NativeInt]: Integer read GetStyleAt;
    /// <summary>Get the font of a style.
    /// Returns the length of the fontName
    /// Result is NUL-terminated.</summary>
    property StyleFont[AStyle: Integer]: UnicodeString read StyleGetFont write StyleSetFont;
    /// <summary>Find the parent line of a child line.</summary>
    property FoldParent[ALine: NativeInt]: NativeInt read GetFoldParent;
    /// <summary>Set the scale factor in percent for future RGBA image data.</summary>
    property RGBAImageScale: Integer write RGBAImageSetScale;
    /// <summary>Get the way a character is drawn.
    /// Result is NUL-terminated.</summary>
    property Representation[AEncodedCharacter: AnsiString]: AnsiString read GetRepresentation write SetRepresentation;
    /// <summary>Retrieve the foreground colour of an indicator.</summary>
    property IndicFore[AIndicator: Integer]: TColor read IndicGetFore write IndicSetFore;
    /// <summary>Get is a style italic or not.</summary>
    property StyleItalic[AStyle: Integer]: Boolean read StyleGetItalic write StyleSetItalic;
    /// <summary>Get the colour of an element.</summary>
    property ElementColour[AElement: TDSciElement]: TDSciColourAlpha read GetElementColour write SetElementColour;
