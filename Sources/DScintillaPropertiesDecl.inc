    /// <summary>Returns the number of bytes in the document.</summary>
    function GetLength: NativeInt;

    /// <summary>Returns the character byte at the position.</summary>
    function GetCharAt(APos: NativeInt): Integer;

    /// <summary>Returns the position of the caret.</summary>
    function GetCurrentPos: NativeInt;

    /// <summary>Returns the position of the opposite end of the selection to the caret.</summary>
    function GetAnchor: NativeInt;

    /// <summary>Returns the style byte at the position.</summary>
    function GetStyleAt(APos: NativeInt): Integer;

    /// <summary>Returns the unsigned style byte at the position.</summary>
    function GetStyleIndexAt(APos: NativeInt): Integer;

    /// <summary>Choose between collecting actions into the undo
    /// history and discarding them.</summary>
    procedure SetUndoCollection(ACollectUndo: Boolean);

    /// <summary>Is undo history being collected?</summary>
    function GetUndoCollection: Boolean;

    /// <summary>Are white space characters currently visible?
    /// Returns one of SCWS_* constants.</summary>
    function GetViewWS: TDSciWhiteSpace;

    /// <summary>Make white space characters invisible, always visible or visible outside indentation.</summary>
    procedure SetViewWS(AViewWS: TDSciWhiteSpace);

    /// <summary>Retrieve the current tab draw mode.
    /// Returns one of SCTD_* constants.</summary>
    function GetTabDrawMode: TDSciTabDrawMode;

    /// <summary>Set how tabs are drawn when visible.</summary>
    procedure SetTabDrawMode(ATabDrawMode: TDSciTabDrawMode);

    /// <summary>Set the selection anchor to a position. The anchor is the opposite
    /// end of the selection from the caret.</summary>
    procedure SetAnchor(AAnchor: NativeInt);

    /// <summary>Retrieve the position of the last correctly styled character.</summary>
    function GetEndStyled: NativeInt;

    /// <summary>Retrieve the current end of line mode - one of CRLF, CR, or LF.</summary>
    function GetEOLMode: TDSciEndOfLine;

    /// <summary>Set the current end of line mode.</summary>
    procedure SetEOLMode(AEolMode: TDSciEndOfLine);

    /// <summary>Is drawing done first into a buffer or direct to the screen?</summary>
    function GetBufferedDraw: Boolean;

    /// <summary>If drawing is buffered then each line of text is drawn into a bitmap buffer
    /// before drawing it to the screen to avoid flicker.</summary>
    procedure SetBufferedDraw(ABuffered: Boolean);

    /// <summary>Change the visible size of a tab to be a multiple of the width of a space character.</summary>
    procedure SetTabWidth(ATabWidth: Integer);

    /// <summary>Retrieve the visible size of a tab.</summary>
    function GetTabWidth: Integer;

    /// <summary>Set the minimum visual width of a tab.</summary>
    procedure SetTabMinimumWidth(APixels: Integer);

    /// <summary>Get the minimum visual width of a tab.</summary>
    function GetTabMinimumWidth: Integer;

    /// <summary>Set the code page used to interpret the bytes of the document as characters.
    /// The SC_CP_UTF8 value can be used to enter Unicode mode.</summary>
    procedure SetCodePage(ACodePage: Integer);

    /// <summary>Set the locale for displaying text.</summary>
    procedure SetFontLocale(const ALocaleName: UnicodeString);

    /// <summary>Get the locale for displaying text.</summary>
    function GetFontLocale: UnicodeString;

    /// <summary>Is the IME displayed in a window or inline?</summary>
    function GetIMEInteraction: TDSciIMEInteraction;

    /// <summary>Choose to display the IME in a window or inline.</summary>
    procedure SetIMEInteraction(AImeInteraction: TDSciIMEInteraction);

    /// <summary>Set the foreground colour used for a particular marker number.</summary>
    procedure MarkerSetFore(AMarkerNumber: Integer; AFore: TColor);

    /// <summary>Set the background colour used for a particular marker number.</summary>
    procedure MarkerSetBack(AMarkerNumber: Integer; ABack: TColor);

    /// <summary>Set the background colour used for a particular marker number when its folding block is selected.</summary>
    procedure MarkerSetBackSelected(AMarkerNumber: Integer; ABack: TColor);

    /// <summary>Set the foreground colour used for a particular marker number.</summary>
    procedure MarkerSetForeTranslucent(AMarkerNumber: Integer; AFore: TDSciColourAlpha);

    /// <summary>Set the background colour used for a particular marker number.</summary>
    procedure MarkerSetBackTranslucent(AMarkerNumber: Integer; ABack: TDSciColourAlpha);

    /// <summary>Set the background colour used for a particular marker number when its folding block is selected.</summary>
    procedure MarkerSetBackSelectedTranslucent(AMarkerNumber: Integer; ABack: TDSciColourAlpha);

    /// <summary>Set the width of strokes used in .01 pixels so 50  = 1/2 pixel width.</summary>
    procedure MarkerSetStrokeWidth(AMarkerNumber: Integer; AHundredths: Integer);

    /// <summary>Set the alpha used for a marker that is drawn in the text area, not the margin.</summary>
    procedure MarkerSetAlpha(AMarkerNumber: Integer; AAlpha: TDSciAlpha);

    /// <summary>Get the layer used for a marker that is drawn in the text area, not the margin.</summary>
    function MarkerGetLayer(AMarkerNumber: Integer): TDSciLayer;

    /// <summary>Set the layer used for a marker that is drawn in the text area, not the margin.</summary>
    procedure MarkerSetLayer(AMarkerNumber: Integer; ALayer: TDSciLayer);

    /// <summary>Set a margin to be either numeric or symbolic.</summary>
    procedure SetMarginTypeN(AMargin: Integer; AMarginType: TDSciMarginType);

    /// <summary>Retrieve the type of a margin.</summary>
    function GetMarginTypeN(AMargin: Integer): TDSciMarginType;

    /// <summary>Set the width of a margin to a width expressed in pixels.</summary>
    procedure SetMarginWidthN(AMargin: Integer; APixelWidth: Integer);

    /// <summary>Retrieve the width of a margin in pixels.</summary>
    function GetMarginWidthN(AMargin: Integer): Integer;

    /// <summary>Set a mask that determines which markers are displayed in a margin.</summary>
    procedure SetMarginMaskN(AMargin: Integer; AMask: Integer);

    /// <summary>Retrieve the marker mask of a margin.</summary>
    function GetMarginMaskN(AMargin: Integer): Integer;

    /// <summary>Make a margin sensitive or insensitive to mouse clicks.</summary>
    procedure SetMarginSensitiveN(AMargin: Integer; ASensitive: Boolean);

    /// <summary>Retrieve the mouse click sensitivity of a margin.</summary>
    function GetMarginSensitiveN(AMargin: Integer): Boolean;

    /// <summary>Set the cursor shown when the mouse is inside a margin.</summary>
    procedure SetMarginCursorN(AMargin: Integer; ACursor: TDSciCursorShape);

    /// <summary>Retrieve the cursor shown in a margin.</summary>
    function GetMarginCursorN(AMargin: Integer): TDSciCursorShape;

    /// <summary>Set the background colour of a margin. Only visible for SC_MARGIN_COLOUR.</summary>
    procedure SetMarginBackN(AMargin: Integer; ABack: TColor);

    /// <summary>Retrieve the background colour of a margin</summary>
    function GetMarginBackN(AMargin: Integer): TColor;

    /// <summary>Allocate a non-standard number of margins.</summary>
    procedure SetMargins(AMargins: Integer);

    /// <summary>How many margins are there?.</summary>
    function GetMargins: Integer;

    /// <summary>Set the foreground colour of a style.</summary>
    procedure StyleSetFore(AStyle: Integer; AFore: TColor);

    /// <summary>Set the background colour of a style.</summary>
    procedure StyleSetBack(AStyle: Integer; ABack: TColor);

    /// <summary>Set a style to be bold or not.</summary>
    procedure StyleSetBold(AStyle: Integer; ABold: Boolean);

    /// <summary>Set a style to be italic or not.</summary>
    procedure StyleSetItalic(AStyle: Integer; AItalic: Boolean);

    /// <summary>Set the size of characters of a style.</summary>
    procedure StyleSetSize(AStyle: Integer; ASizePoints: Integer);

    /// <summary>Set the font of a style.</summary>
    procedure StyleSetFont(AStyle: Integer; const AFontName: UnicodeString);

    /// <summary>Set a style to have its end of line filled or not.</summary>
    procedure StyleSetEOLFilled(AStyle: Integer; AEolFilled: Boolean);

    /// <summary>Set a style to be underlined or not.</summary>
    procedure StyleSetUnderline(AStyle: Integer; AUnderline: Boolean);

    /// <summary>Get the foreground colour of a style.</summary>
    function StyleGetFore(AStyle: Integer): TColor;

    /// <summary>Get the background colour of a style.</summary>
    function StyleGetBack(AStyle: Integer): TColor;

    /// <summary>Get is a style bold or not.</summary>
    function StyleGetBold(AStyle: Integer): Boolean;

    /// <summary>Get is a style italic or not.</summary>
    function StyleGetItalic(AStyle: Integer): Boolean;

    /// <summary>Get the size of characters of a style.</summary>
    function StyleGetSize(AStyle: Integer): Integer;

    /// <summary>Get the font of a style.
    /// Returns the length of the fontName
    /// Result is NUL-terminated.</summary>
    function StyleGetFont(AStyle: Integer): UnicodeString;

    /// <summary>Get is a style to have its end of line filled or not.</summary>
    function StyleGetEOLFilled(AStyle: Integer): Boolean;

    /// <summary>Get is a style underlined or not.</summary>
    function StyleGetUnderline(AStyle: Integer): Boolean;

    /// <summary>Get is a style mixed case, or to force upper or lower case.</summary>
    function StyleGetCase(AStyle: Integer): TDSciCaseVisible;

    /// <summary>Get the character get of the font in a style.</summary>
    function StyleGetCharacterSet(AStyle: Integer): TDSciCharacterSet;

    /// <summary>Get is a style visible or not.</summary>
    function StyleGetVisible(AStyle: Integer): Boolean;

    /// <summary>Get is a style changeable or not (read only).
    /// Experimental feature, currently buggy.</summary>
    function StyleGetChangeable(AStyle: Integer): Boolean;

    /// <summary>Get is a style a hotspot or not.</summary>
    function StyleGetHotSpot(AStyle: Integer): Boolean;

    /// <summary>Set a style to be mixed case, or to force upper or lower case.</summary>
    procedure StyleSetCase(AStyle: Integer; ACaseVisible: TDSciCaseVisible);

    /// <summary>Set the size of characters of a style. Size is in points multiplied by 100.</summary>
    procedure StyleSetSizeFractional(AStyle: Integer; ASizeHundredthPoints: Integer);

    /// <summary>Get the size of characters of a style in points multiplied by 100</summary>
    function StyleGetSizeFractional(AStyle: Integer): Integer;

    /// <summary>Set the weight of characters of a style.</summary>
    procedure StyleSetWeight(AStyle: Integer; AWeight: TDSciFontWeight);

    /// <summary>Get the weight of characters of a style.</summary>
    function StyleGetWeight(AStyle: Integer): TDSciFontWeight;

    /// <summary>Set the character set of the font in a style.</summary>
    procedure StyleSetCharacterSet(AStyle: Integer; ACharacterSet: TDSciCharacterSet);

    /// <summary>Set a style to be a hotspot or not.</summary>
    procedure StyleSetHotSpot(AStyle: Integer; AHotspot: Boolean);

    /// <summary>Indicate that a style may be monospaced over ASCII graphics characters which enables optimizations.</summary>
    procedure StyleSetCheckMonospaced(AStyle: Integer; ACheckMonospaced: Boolean);

    /// <summary>Get whether a style may be monospaced.</summary>
    function StyleGetCheckMonospaced(AStyle: Integer): Boolean;

    /// <summary>Set the stretch of characters of a style.</summary>
    procedure StyleSetStretch(AStyle: Integer; AStretch: TDSciFontStretch);

    /// <summary>Get the stretch of characters of a style.</summary>
    function StyleGetStretch(AStyle: Integer): TDSciFontStretch;

    /// <summary>Set the invisible representation for a style.</summary>
    procedure StyleSetInvisibleRepresentation(AStyle: Integer; const ARepresentation: UnicodeString);

    /// <summary>Get the invisible representation for a style.</summary>
    function StyleGetInvisibleRepresentation(AStyle: Integer): UnicodeString;

    /// <summary>Set the colour of an element. Translucency (alpha) may or may not be significant
    /// and this may depend on the platform. The alpha byte should commonly be 0xff for opaque.</summary>
    procedure SetElementColour(AElement: TDSciElement; AColourElement: TDSciColourAlpha);

    /// <summary>Get the colour of an element.</summary>
    function GetElementColour(AElement: TDSciElement): TDSciColourAlpha;

    /// <summary>Get whether an element has been set by SetElementColour.
    /// When false, a platform-defined or default colour is used.</summary>
    function GetElementIsSet(AElement: TDSciElement): Boolean;

    /// <summary>Get whether an element supports translucency.</summary>
    function GetElementAllowsTranslucent(AElement: TDSciElement): Boolean;

    /// <summary>Get the colour of an element.</summary>
    function GetElementBaseColour(AElement: TDSciElement): TDSciColourAlpha;

    /// <summary>Get the alpha of the selection.</summary>
    function GetSelAlpha: TDSciAlpha;

    /// <summary>Set the alpha of the selection.</summary>
    procedure SetSelAlpha(AAlpha: TDSciAlpha);

    /// <summary>Is the selection end of line filled?</summary>
    function GetSelEOLFilled: Boolean;

    /// <summary>Set the selection to have its end of line filled or not.</summary>
    procedure SetSelEOLFilled(AFilled: Boolean);

    /// <summary>Get the layer for drawing selections</summary>
    function GetSelectionLayer: TDSciLayer;

    /// <summary>Set the layer for drawing selections: either opaquely on base layer or translucently over text</summary>
    procedure SetSelectionLayer(ALayer: TDSciLayer);

    /// <summary>Get the layer of the background of the line containing the caret.</summary>
    function GetCaretLineLayer: TDSciLayer;

    /// <summary>Set the layer of the background of the line containing the caret.</summary>
    procedure SetCaretLineLayer(ALayer: TDSciLayer);

    /// <summary>Get only highlighting subline instead of whole line.</summary>
    function GetCaretLineHighlightSubLine: Boolean;

    /// <summary>Set only highlighting subline instead of whole line.</summary>
    procedure SetCaretLineHighlightSubLine(ASubLine: Boolean);

    /// <summary>Set the foreground colour of the caret.</summary>
    procedure SetCaretFore(AFore: TColor);

    /// <summary>Set a style to be visible or not.</summary>
    procedure StyleSetVisible(AStyle: Integer; AVisible: Boolean);

    /// <summary>Get the time in milliseconds that the caret is on and off.</summary>
    function GetCaretPeriod: Integer;

    /// <summary>Get the time in milliseconds that the caret is on and off. 0 = steady on.</summary>
    procedure SetCaretPeriod(APeriodMilliseconds: Integer);

    /// <summary>Set the set of characters making up words for when moving or selecting by word.
    /// First sets defaults like SetCharsDefault.</summary>
    procedure SetWordChars(const ACharacters: AnsiString);

    /// <summary>Get the set of characters making up words for when moving or selecting by word.
    /// Returns the number of characters</summary>
    function GetWordChars: AnsiString;

    /// <summary>Set the number of characters to have directly indexed categories</summary>
    procedure SetCharacterCategoryOptimization(ACountCharacters: Integer);

    /// <summary>Get the number of characters to have directly indexed categories</summary>
    function GetCharacterCategoryOptimization: Integer;

    /// <summary>Is an undo sequence active?</summary>
    function GetUndoSequence: Integer;

    /// <summary>How many undo actions are in the history?</summary>
    function GetUndoActions: Integer;

    /// <summary>Set action as the save point</summary>
    procedure SetUndoSavePoint(AAction: Integer);

    /// <summary>Which action is the save point?</summary>
    function GetUndoSavePoint: Integer;

    /// <summary>Set action as the detach point</summary>
    procedure SetUndoDetach(AAction: Integer);

    /// <summary>Which action is the detach point?</summary>
    function GetUndoDetach: Integer;

    /// <summary>Set action as the tentative point</summary>
    procedure SetUndoTentative(AAction: Integer);

    /// <summary>Which action is the tentative point?</summary>
    function GetUndoTentative: Integer;

    /// <summary>Set action as the current point</summary>
    procedure SetUndoCurrent(AAction: Integer);

    /// <summary>Which action is the current point?</summary>
    function GetUndoCurrent: Integer;

    /// <summary>What is the type of an action?</summary>
    function GetUndoActionType(AAction: Integer): Integer;

    /// <summary>What is the position of an action?</summary>
    function GetUndoActionPosition(AAction: Integer): NativeInt;

    /// <summary>What is the text of an action?</summary>
    function GetUndoActionText(AAction: Integer): UnicodeString;

    /// <summary>Set an indicator to plain, squiggle or TT.</summary>
    procedure IndicSetStyle(AIndicator: Integer; AIndicatorStyle: TDSciIndicatorStyle);

    /// <summary>Retrieve the style of an indicator.</summary>
    function IndicGetStyle(AIndicator: Integer): TDSciIndicatorStyle;

    /// <summary>Set the foreground colour of an indicator.</summary>
    procedure IndicSetFore(AIndicator: Integer; AFore: TColor);

    /// <summary>Retrieve the foreground colour of an indicator.</summary>
    function IndicGetFore(AIndicator: Integer): TColor;

    /// <summary>Set an indicator to draw under text or over(default).</summary>
    procedure IndicSetUnder(AIndicator: Integer; AUnder: Boolean);

    /// <summary>Retrieve whether indicator drawn under or over text.</summary>
    function IndicGetUnder(AIndicator: Integer): Boolean;

    /// <summary>Set a hover indicator to plain, squiggle or TT.</summary>
    procedure IndicSetHoverStyle(AIndicator: Integer; AIndicatorStyle: TDSciIndicatorStyle);

    /// <summary>Retrieve the hover style of an indicator.</summary>
    function IndicGetHoverStyle(AIndicator: Integer): TDSciIndicatorStyle;

    /// <summary>Set the foreground hover colour of an indicator.</summary>
    procedure IndicSetHoverFore(AIndicator: Integer; AFore: TColor);

    /// <summary>Retrieve the foreground hover colour of an indicator.</summary>
    function IndicGetHoverFore(AIndicator: Integer): TColor;

    /// <summary>Set the attributes of an indicator.</summary>
    procedure IndicSetFlags(AIndicator: Integer; AFlags: TDSciIndicFlag);

    /// <summary>Retrieve the attributes of an indicator.</summary>
    function IndicGetFlags(AIndicator: Integer): TDSciIndicFlag;

    /// <summary>Set the stroke width of an indicator in hundredths of a pixel.</summary>
    procedure IndicSetStrokeWidth(AIndicator: Integer; AHundredths: Integer);

    /// <summary>Retrieve the stroke width of an indicator.</summary>
    function IndicGetStrokeWidth(AIndicator: Integer): Integer;

    /// <summary>Set the size of the dots used to mark space characters.</summary>
    procedure SetWhitespaceSize(ASize: Integer);

    /// <summary>Get the size of the dots used to mark space characters.</summary>
    function GetWhitespaceSize: Integer;

    /// <summary>Used to hold extra styling information for each line.</summary>
    procedure SetLineState(ALine: NativeInt; AState: Integer);

    /// <summary>Retrieve the extra styling information for a line.</summary>
    function GetLineState(ALine: NativeInt): Integer;

    /// <summary>Retrieve the last line number that has line state.</summary>
    function GetMaxLineState: Integer;

    /// <summary>Is the background of the line containing the caret in a different colour?</summary>
    function GetCaretLineVisible: Boolean;

    /// <summary>Display the background of the line containing the caret in a different colour.</summary>
    procedure SetCaretLineVisible(AShow: Boolean);

    /// <summary>Get the colour of the background of the line containing the caret.</summary>
    function GetCaretLineBack: TColor;

    /// <summary>Set the colour of the background of the line containing the caret.</summary>
    procedure SetCaretLineBack(ABack: TColor);

    /// <summary>Retrieve the caret line frame width.
    /// Width = 0 means this option is disabled.</summary>
    function GetCaretLineFrame: Integer;

    /// <summary>Display the caret line framed.
    /// Set width != 0 to enable this option and width = 0 to disable it.</summary>
    procedure SetCaretLineFrame(AWidth: Integer);

    /// <summary>Set a style to be changeable or not (read only).
    /// Experimental feature, currently buggy.</summary>
    procedure StyleSetChangeable(AStyle: Integer; AChangeable: Boolean);

    /// <summary>Change the separator character in the string setting up an auto-completion list.
    /// Default is space but can be changed if items contain space.</summary>
    procedure AutoCSetSeparator(ASeparatorCharacter: AnsiChar);

    /// <summary>Retrieve the auto-completion list separator character.</summary>
    function AutoCGetSeparator: AnsiChar;

    /// <summary>Should the auto-completion list be cancelled if the user backspaces to a
    /// position before where the box was created.</summary>
    procedure AutoCSetCancelAtStart(ACancel: Boolean);

    /// <summary>Retrieve whether auto-completion cancelled by backspacing before start.</summary>
    function AutoCGetCancelAtStart: Boolean;

    /// <summary>Define a set of characters that when typed will cause the autocompletion to
    /// choose the selected item.</summary>
    procedure AutoCSetFillUps(const ACharacterSet: UnicodeString);

    /// <summary>Should a single item auto-completion list automatically choose the item.</summary>
    procedure AutoCSetChooseSingle(AChooseSingle: Boolean);

    /// <summary>Retrieve whether a single item auto-completion list automatically choose the item.</summary>
    function AutoCGetChooseSingle: Boolean;

    /// <summary>Set whether case is significant when performing auto-completion searches.</summary>
    procedure AutoCSetIgnoreCase(AIgnoreCase: Boolean);

    /// <summary>Retrieve state of ignore case flag.</summary>
    function AutoCGetIgnoreCase: Boolean;

    /// <summary>Set whether or not autocompletion is hidden automatically when nothing matches.</summary>
    procedure AutoCSetAutoHide(AAutoHide: Boolean);

    /// <summary>Retrieve whether or not autocompletion is hidden automatically when nothing matches.</summary>
    function AutoCGetAutoHide: Boolean;

    /// <summary>Set autocompletion options.</summary>
    procedure AutoCSetOptions(AOptions: TDSciAutoCompleteOption);

    /// <summary>Retrieve autocompletion options.</summary>
    function AutoCGetOptions: TDSciAutoCompleteOption;

    /// <summary>Set whether or not autocompletion deletes any word characters
    /// after the inserted text upon completion.</summary>
    procedure AutoCSetDropRestOfWord(ADropRestOfWord: Boolean);

    /// <summary>Retrieve whether or not autocompletion deletes any word characters
    /// after the inserted text upon completion.</summary>
    function AutoCGetDropRestOfWord: Boolean;

    /// <summary>Retrieve the auto-completion list type-separator character.</summary>
    function AutoCGetTypeSeparator: AnsiChar;

    /// <summary>Change the type-separator character in the string setting up an auto-completion list.
    /// Default is '?' but can be changed if items contain '?'.</summary>
    procedure AutoCSetTypeSeparator(ASeparatorCharacter: AnsiChar);

    /// <summary>Set the maximum width, in characters, of auto-completion and user lists.
    /// Set to 0 to autosize to fit longest item, which is the default.</summary>
    procedure AutoCSetMaxWidth(ACharacterCount: Integer);

    /// <summary>Get the maximum width, in characters, of auto-completion and user lists.</summary>
    function AutoCGetMaxWidth: Integer;

    /// <summary>Set the maximum height, in rows, of auto-completion and user lists.
    /// The default is 5 rows.</summary>
    procedure AutoCSetMaxHeight(ARowCount: Integer);

    /// <summary>Set the maximum height, in rows, of auto-completion and user lists.</summary>
    function AutoCGetMaxHeight: Integer;

    /// <summary>Set the style number used for auto-completion and user lists fonts.</summary>
    procedure AutoCSetStyle(AStyle: Integer);

    /// <summary>Get the style number used for auto-completion and user lists fonts.</summary>
    function AutoCGetStyle: Integer;

    /// <summary>Set the scale factor in percent for auto-completion list images.</summary>
    procedure AutoCSetImageScale(AScalePercent: Integer);

    /// <summary>Get the scale factor in percent for auto-completion list images.</summary>
    function AutoCGetImageScale: Integer;

    /// <summary>Set the number of spaces used for one level of indentation.</summary>
    procedure SetIndent(AIndentSize: Integer);

    /// <summary>Retrieve indentation size.</summary>
    function GetIndent: Integer;

    /// <summary>Indentation will only use space characters if useTabs is false, otherwise
    /// it will use a combination of tabs and spaces.</summary>
    procedure SetUseTabs(AUseTabs: Boolean);

    /// <summary>Retrieve whether tabs will be used in indentation.</summary>
    function GetUseTabs: Boolean;

    /// <summary>Change the indentation of a line to a number of columns.</summary>
    procedure SetLineIndentation(ALine: NativeInt; AIndentation: Integer);

    /// <summary>Retrieve the number of columns that a line is indented.</summary>
    function GetLineIndentation(ALine: NativeInt): Integer;

    /// <summary>Retrieve the position before the first non indentation character on a line.</summary>
    function GetLineIndentPosition(ALine: NativeInt): NativeInt;

    /// <summary>Retrieve the column number of a position, taking tab width into account.</summary>
    function GetColumn(APos: NativeInt): NativeInt;

    /// <summary>Show or hide the horizontal scroll bar.</summary>
    procedure SetHScrollBar(AVisible: Boolean);

    /// <summary>Is the horizontal scroll bar visible?</summary>
    function GetHScrollBar: Boolean;

    /// <summary>Show or hide indentation guides.</summary>
    procedure SetIndentationGuides(AIndentView: TDSciIndentView);

    /// <summary>Are the indentation guides visible?</summary>
    function GetIndentationGuides: TDSciIndentView;

    /// <summary>Set the highlighted indentation guide column.
    /// 0 = no highlighted guide.</summary>
    procedure SetHighlightGuide(AColumn: NativeInt);

    /// <summary>Get the highlighted indentation guide column.</summary>
    function GetHighlightGuide: NativeInt;

    /// <summary>Get the position after the last visible characters on a line.</summary>
    function GetLineEndPosition(ALine: NativeInt): NativeInt;

    /// <summary>Get the code page used to interpret the bytes of the document as characters.</summary>
    function GetCodePage: Integer;

    /// <summary>Get the foreground colour of the caret.</summary>
    function GetCaretFore: TColor;

    /// <summary>In read-only mode?</summary>
    function GetReadOnly: Boolean;

    /// <summary>Sets the position of the caret.</summary>
    procedure SetCurrentPos(ACaret: NativeInt);

    /// <summary>Sets the position that starts the selection - this becomes the anchor.</summary>
    procedure SetSelectionStart(AAnchor: NativeInt);

    /// <summary>Returns the position at the start of the selection.</summary>
    function GetSelectionStart: NativeInt;

    /// <summary>Sets the position that ends the selection - this becomes the caret.</summary>
    procedure SetSelectionEnd(ACaret: NativeInt);

    /// <summary>Returns the position at the end of the selection.</summary>
    function GetSelectionEnd: NativeInt;

    /// <summary>Sets the print magnification added to the point size of each style for printing.</summary>
    procedure SetPrintMagnification(AMagnification: Integer);

    /// <summary>Returns the print magnification.</summary>
    function GetPrintMagnification: Integer;

    /// <summary>Modify colours when printing for clearer printed text.</summary>
    procedure SetPrintColourMode(AMode: TDSciPrintOption);

    /// <summary>Returns the print colour mode.</summary>
    function GetPrintColourMode: TDSciPrintOption;

    /// <summary>Enable or disable change history.</summary>
    procedure SetChangeHistory(AChangeHistory: TDSciChangeHistoryOption);

    /// <summary>Report change history status.</summary>
    function GetChangeHistory: TDSciChangeHistoryOption;

    /// <summary>Enable or disable undo selection history.</summary>
    procedure SetUndoSelectionHistory(AUndoSelectionHistory: TDSciUndoSelectionHistoryOption);

    /// <summary>Report undo selection history status.</summary>
    function GetUndoSelectionHistory: TDSciUndoSelectionHistoryOption;

    /// <summary>Set selection from serialized form.</summary>
    procedure SetSelectionSerialized(const ASelectionString: UnicodeString);

    /// <summary>Retrieve serialized form of selection.</summary>
    function GetSelectionSerialized: UnicodeString;

    /// <summary>Retrieve the display line at the top of the display.</summary>
    function GetFirstVisibleLine: NativeInt;

    /// <summary>Returns the number of lines in the document. There is always at least one.</summary>
    function GetLineCount: NativeInt;

    /// <summary>Enlarge the number of lines allocated.</summary>
    procedure AllocateLines(ALines: NativeInt);

    /// <summary>Sets the size in pixels of the left margin.</summary>
    procedure SetMarginLeft(APixelWidth: Integer);

    /// <summary>Returns the size in pixels of the left margin.</summary>
    function GetMarginLeft: Integer;

    /// <summary>Sets the size in pixels of the right margin.</summary>
    procedure SetMarginRight(APixelWidth: Integer);

    /// <summary>Returns the size in pixels of the right margin.</summary>
    function GetMarginRight: Integer;

    /// <summary>Is the document different from when it was last saved?</summary>
    function GetModify: Boolean;

    /// <summary>Is the selection visible or hidden?</summary>
    function GetSelectionHidden: Boolean;

    /// <summary>Set to read only or read write.</summary>
    procedure SetReadOnly(AReadOnly: Boolean);

    /// <summary>Retrieve the number of characters in the document.</summary>
    function GetTextLength: NativeInt;

    /// <summary>Set to overtype (true) or insert mode.</summary>
    procedure SetOvertype(AOverType: Boolean);

    /// <summary>Returns true if overtype mode is active otherwise false is returned.</summary>
    function GetOvertype: Boolean;

    /// <summary>Set the width of the insert mode caret.</summary>
    procedure SetCaretWidth(APixelWidth: Integer);

    /// <summary>Returns the width of the insert mode caret.</summary>
    function GetCaretWidth: Integer;

    /// <summary>Sets the position that starts the target which is used for updating the
    /// document without affecting the scroll position.</summary>
    procedure SetTargetStart(AStart: NativeInt);

    /// <summary>Get the position that starts the target.</summary>
    function GetTargetStart: NativeInt;

    /// <summary>Sets the virtual space of the target start</summary>
    procedure SetTargetStartVirtualSpace(ASpace: NativeInt);

    /// <summary>Get the virtual space of the target start</summary>
    function GetTargetStartVirtualSpace: NativeInt;

    /// <summary>Sets the position that ends the target which is used for updating the
    /// document without affecting the scroll position.</summary>
    procedure SetTargetEnd(AEnd: NativeInt);

    /// <summary>Get the position that ends the target.</summary>
    function GetTargetEnd: NativeInt;

    /// <summary>Sets the virtual space of the target end</summary>
    procedure SetTargetEndVirtualSpace(ASpace: NativeInt);

    /// <summary>Get the virtual space of the target end</summary>
    function GetTargetEndVirtualSpace: NativeInt;

    /// <summary>Retrieve the text in the target.</summary>
    function GetTargetText: UnicodeString;

    /// <summary>Set the search flags used by SearchInTarget.</summary>
    procedure SetSearchFlags(ASearchFlags: TDSciFindOptionSet);

    /// <summary>Get the search flags used by SearchInTarget.</summary>
    function GetSearchFlags: TDSciFindOptionSet;

    /// <summary>Retrieve the position where the caret was before displaying the call tip.</summary>
    function CallTipPosStart: NativeInt;

    /// <summary>Set the start position in order to change when backspacing removes the calltip.</summary>
    procedure CallTipSetPosStart(APosStart: NativeInt);

    /// <summary>Set the background colour for the call tip.</summary>
    procedure CallTipSetBack(ABack: TColor);

    /// <summary>Set the foreground colour for the call tip.</summary>
    procedure CallTipSetFore(AFore: TColor);

    /// <summary>Set the foreground colour for the highlighted part of the call tip.</summary>
    procedure CallTipSetForeHlt(AFore: TColor);

    /// <summary>Enable use of STYLE_CALLTIP and set call tip tab size in pixels.</summary>
    procedure CallTipUseStyle(ATabSize: Integer);

    /// <summary>Set position of calltip, above or below text.</summary>
    procedure CallTipSetPosition(AAbove: Boolean);

    /// <summary>Set the fold level of a line.
    /// This encodes an integer level along with flags indicating whether the
    /// line is a header and whether it is effectively white space.</summary>
    procedure SetFoldLevel(ALine: NativeInt; ALevel: TDSciFoldLevel);

    /// <summary>Retrieve the fold level of a line.</summary>
    function GetFoldLevel(ALine: NativeInt): TDSciFoldLevel;

    /// <summary>Find the last child line of a header line.</summary>
    function GetLastChild(ALine: NativeInt; ALevel: TDSciFoldLevel): NativeInt;

    /// <summary>Find the parent line of a child line.</summary>
    function GetFoldParent(ALine: NativeInt): NativeInt;

    /// <summary>Is a line visible?</summary>
    function GetLineVisible(ALine: NativeInt): Boolean;

    /// <summary>Are all lines visible?</summary>
    function GetAllLinesVisible: Boolean;

    /// <summary>Show the children of a header line.</summary>
    procedure SetFoldExpanded(ALine: NativeInt; AExpanded: Boolean);

    /// <summary>Is a header line expanded?</summary>
    function GetFoldExpanded(ALine: NativeInt): Boolean;

    /// <summary>Set the style of fold display text.</summary>
    procedure FoldDisplayTextSetStyle(AStyle: TDSciFoldDisplayTextStyle);

    /// <summary>Get the style of fold display text.</summary>
    function FoldDisplayTextGetStyle: TDSciFoldDisplayTextStyle;

    /// <summary>Set automatic folding behaviours.</summary>
    procedure SetAutomaticFold(AAutomaticFold: TDSciAutomaticFold);

    /// <summary>Get automatic folding behaviours.</summary>
    function GetAutomaticFold: TDSciAutomaticFold;

    /// <summary>Set some style options for folding.</summary>
    procedure SetFoldFlags(AFlags: TDSciFoldFlagSet);

    /// <summary>Sets whether a tab pressed when caret is within indentation indents.</summary>
    procedure SetTabIndents(ATabIndents: Boolean);

    /// <summary>Does a tab pressed when caret is within indentation indent?</summary>
    function GetTabIndents: Boolean;

    /// <summary>Sets whether a backspace pressed when caret is within indentation unindents.</summary>
    procedure SetBackSpaceUnIndents(ABsUnIndents: Boolean);

    /// <summary>Does a backspace pressed when caret is within indentation unindent?</summary>
    function GetBackSpaceUnIndents: Boolean;

    /// <summary>Sets the time the mouse must sit still to generate a mouse dwell event.</summary>
    procedure SetMouseDwellTime(APeriodMilliseconds: Integer);

    /// <summary>Retrieve the time the mouse must sit still to generate a mouse dwell event.</summary>
    function GetMouseDwellTime: Integer;

    /// <summary>Sets limits to idle styling.</summary>
    procedure SetIdleStyling(AIdleStyling: TDSciIdleStyling);

    /// <summary>Retrieve the limits to idle styling.</summary>
    function GetIdleStyling: TDSciIdleStyling;

    /// <summary>Sets whether text is word wrapped.</summary>
    procedure SetWrapMode(AWrapMode: TDSciWrap);

    /// <summary>Retrieve whether text is word wrapped.</summary>
    function GetWrapMode: TDSciWrap;

    /// <summary>Set the display mode of visual flags for wrapped lines.</summary>
    procedure SetWrapVisualFlags(AWrapVisualFlags: TDSciWrapVisualFlagSet);

    /// <summary>Retrive the display mode of visual flags for wrapped lines.</summary>
    function GetWrapVisualFlags: TDSciWrapVisualFlagSet;

    /// <summary>Set the location of visual flags for wrapped lines.</summary>
    procedure SetWrapVisualFlagsLocation(AWrapVisualFlagsLocation: TDSciWrapVisualLocationSet);

    /// <summary>Retrive the location of visual flags for wrapped lines.</summary>
    function GetWrapVisualFlagsLocation: TDSciWrapVisualLocationSet;

    /// <summary>Set the start indent for wrapped lines.</summary>
    procedure SetWrapStartIndent(AIndent: Integer);

    /// <summary>Retrive the start indent for wrapped lines.</summary>
    function GetWrapStartIndent: Integer;

    /// <summary>Sets how wrapped sublines are placed. Default is fixed.</summary>
    procedure SetWrapIndentMode(AWrapIndentMode: TDSciWrapIndentMode);

    /// <summary>Retrieve how wrapped sublines are placed. Default is fixed.</summary>
    function GetWrapIndentMode: TDSciWrapIndentMode;

    /// <summary>Sets the degree of caching of layout information.</summary>
    procedure SetLayoutCache(ACacheMode: TDSciLineCache);

    /// <summary>Retrieve the degree of caching of layout information.</summary>
    function GetLayoutCache: TDSciLineCache;

    /// <summary>Sets the document width assumed for scrolling.</summary>
    procedure SetScrollWidth(APixelWidth: Integer);

    /// <summary>Retrieve the document width assumed for scrolling.</summary>
    function GetScrollWidth: Integer;

    /// <summary>Sets whether the maximum width line displayed is used to set scroll width.</summary>
    procedure SetScrollWidthTracking(ATracking: Boolean);

    /// <summary>Retrieve whether the scroll width tracks wide lines.</summary>
    function GetScrollWidthTracking: Boolean;

    /// <summary>Sets the scroll range so that maximum scroll position has
    /// the last line at the bottom of the view (default).
    /// Setting this to false allows scrolling one page below the last line.</summary>
    procedure SetEndAtLastLine(AEndAtLastLine: Boolean);

    /// <summary>Retrieve whether the maximum scroll position has the last
    /// line at the bottom of the view.</summary>
    function GetEndAtLastLine: Boolean;

    /// <summary>Show or hide the vertical scroll bar.</summary>
    procedure SetVScrollBar(AVisible: Boolean);

    /// <summary>Is the vertical scroll bar visible?</summary>
    function GetVScrollBar: Boolean;

    /// <summary>How many phases is drawing done in?</summary>
    function GetPhasesDraw: TDSciPhasesDraw;

    /// <summary>In one phase draw, text is drawn in a series of rectangular blocks with no overlap.
    /// In two phase draw, text is drawn in a series of lines allowing runs to overlap horizontally.
    /// In multiple phase draw, each element is drawn over the whole drawing area, allowing text
    /// to overlap from one line to the next.</summary>
    procedure SetPhasesDraw(APhases: TDSciPhasesDraw);

    /// <summary>Choose the quality level for text from the FontQuality enumeration.</summary>
    procedure SetFontQuality(AFontQuality: TDSciFontQuality);

    /// <summary>Retrieve the quality level for text.</summary>
    function GetFontQuality: TDSciFontQuality;

    /// <summary>Scroll so that a display line is at the top of the display.</summary>
    procedure SetFirstVisibleLine(ADisplayLine: NativeInt);

    /// <summary>Change the effect of pasting when there are multiple selections.</summary>
    procedure SetMultiPaste(AMultiPaste: TDSciMultiPaste);

    /// <summary>Retrieve the effect of pasting when there are multiple selections.</summary>
    function GetMultiPaste: TDSciMultiPaste;

    /// <summary>Retrieve the value of a tag from a regular expression search.
    /// Result is NUL-terminated.</summary>
    function GetTag(ATagNumber: Integer): UnicodeString;

    /// <summary>Enable or disable accessibility.</summary>
    procedure SetAccessibility(AAccessibility: TDSciAccessibility);

    /// <summary>Report accessibility status.</summary>
    function GetAccessibility: TDSciAccessibility;

    /// <summary>Are the end of line characters visible?</summary>
    function GetViewEOL: Boolean;

    /// <summary>Make the end of line characters visible or invisible.</summary>
    procedure SetViewEOL(AVisible: Boolean);

    /// <summary>Set which document modification events are sent to the container.</summary>
    procedure SetModEventMask(AEventMask: TDSciModificationFlagsSet);

    /// <summary>Retrieve the column number which text should be kept within.</summary>
    function GetEdgeColumn: NativeInt;

    /// <summary>Set the column number of the edge.
    /// If text goes past the edge then it is highlighted.</summary>
    procedure SetEdgeColumn(AColumn: NativeInt);

    /// <summary>Retrieve the edge highlight mode.</summary>
    function GetEdgeMode: TDSciEdgeVisualStyle;

    /// <summary>The edge may be displayed by a line (EDGE_LINE/EDGE_MULTILINE) or by highlighting text that
    /// goes beyond it (EDGE_BACKGROUND) or not displayed at all (EDGE_NONE).</summary>
    procedure SetEdgeMode(AEdgeMode: TDSciEdgeVisualStyle);

    /// <summary>Retrieve the colour used in edge indication.</summary>
    function GetEdgeColour: TColor;

    /// <summary>Change the colour used in edge indication.</summary>
    procedure SetEdgeColour(AEdgeColour: TColor);

    /// <summary>Get multi edge positions.</summary>
    function GetMultiEdgeColumn(AWhich: Integer): NativeInt;

    /// <summary>Retrieves the number of lines completely visible.</summary>
    function LinesOnScreen: NativeInt;

    /// <summary>Is the selection rectangular? The alternative is the more common stream selection.</summary>
    function SelectionIsRectangle: Boolean;

    /// <summary>Set the zoom level. This number of points is added to the size of all fonts.
    /// It may be positive to magnify or negative to reduce.</summary>
    procedure SetZoom(AZoomInPoints: Integer);

    /// <summary>Retrieve the zoom level.</summary>
    function GetZoom: Integer;

    /// <summary>Get which document options are set.</summary>
    function GetDocumentOptions: TDSciDocumentOption;

    /// <summary>Get which document modification events are sent to the container.</summary>
    function GetModEventMask: TDSciModificationFlagsSet;

    /// <summary>Set whether command events are sent to the container.</summary>
    procedure SetCommandEvents(ACommandEvents: Boolean);

    /// <summary>Get whether command events are sent to the container.</summary>
    function GetCommandEvents: Boolean;

    /// <summary>Change internal focus flag.</summary>
    procedure SetFocus(AFocus: Boolean); reintroduce; overload;

    /// <summary>Get internal focus flag.</summary>
    function GetFocus: Boolean;

    /// <summary>Change error status - 0 = OK.</summary>
    procedure SetStatus(AStatus: TDSciStatus);

    /// <summary>Get error status.</summary>
    function GetStatus: TDSciStatus;

    /// <summary>Set whether the mouse is captured when its button is pressed.</summary>
    procedure SetMouseDownCaptures(ACaptures: Boolean);

    /// <summary>Get whether mouse gets captured.</summary>
    function GetMouseDownCaptures: Boolean;

    /// <summary>Set whether the mouse wheel can be active outside the window.</summary>
    procedure SetMouseWheelCaptures(ACaptures: Boolean);

    /// <summary>Get whether mouse wheel can be active outside the window.</summary>
    function GetMouseWheelCaptures: Boolean;

    /// <summary>Sets the cursor to one of the SC_CURSOR* values.</summary>
    procedure SetCursor(ACursorType: TDSciCursorShape);

    /// <summary>Get cursor type.</summary>
    function GetCursor: TDSciCursorShape;

    /// <summary>Change the way control characters are displayed:
    /// If symbol is &lt; 32, keep the drawn way, else, use the given character.</summary>
    procedure SetControlCharSymbol(ASymbol: Integer);

    /// <summary>Get the way control characters are displayed.</summary>
    function GetControlCharSymbol: Integer;

    /// <summary>Set the xOffset (ie, horizontal scroll position).</summary>
    procedure SetXOffset(AXOffset: Integer);

    /// <summary>Get the xOffset (ie, horizontal scroll position).</summary>
    function GetXOffset: Integer;

    /// <summary>Set printing to line wrapped (SC_WRAP_WORD) or not line wrapped (SC_WRAP_NONE).</summary>
    procedure SetPrintWrapMode(AWrapMode: TDSciWrap);

    /// <summary>Is printing line wrapped?</summary>
    function GetPrintWrapMode: TDSciWrap;

    /// <summary>Set a fore colour for active hotspots.</summary>
    procedure SetHotspotActiveFore(AUseSetting: Boolean; AFore: TColor);

    /// <summary>Get the fore colour for active hotspots.</summary>
    function GetHotspotActiveFore: TColor;

    /// <summary>Set a back colour for active hotspots.</summary>
    procedure SetHotspotActiveBack(AUseSetting: Boolean; ABack: TColor);

    /// <summary>Get the back colour for active hotspots.</summary>
    function GetHotspotActiveBack: TColor;

    /// <summary>Enable / Disable underlining active hotspots.</summary>
    procedure SetHotspotActiveUnderline(AUnderline: Boolean);

    /// <summary>Get whether underlining for active hotspots.</summary>
    function GetHotspotActiveUnderline: Boolean;

    /// <summary>Limit hotspots to single line so hotspots on two lines don't merge.</summary>
    procedure SetHotspotSingleLine(ASingleLine: Boolean);

    /// <summary>Get the HotspotSingleLine property</summary>
    function GetHotspotSingleLine: Boolean;

    /// <summary>Set the selection mode to stream (SC_SEL_STREAM) or rectangular (SC_SEL_RECTANGLE/SC_SEL_THIN) or
    /// by lines (SC_SEL_LINES).</summary>
    procedure SetSelectionMode(ASelectionMode: TDSciSelectionMode);

    /// <summary>Get the mode of the current selection.</summary>
    function GetSelectionMode: TDSciSelectionMode;

    /// <summary>Set whether or not regular caret moves will extend or reduce the selection.</summary>
    procedure SetMoveExtendsSelection(AMoveExtendsSelection: Boolean);

    /// <summary>Get whether or not regular caret moves will extend or reduce the selection.</summary>
    function GetMoveExtendsSelection: Boolean;

    /// <summary>Set the set of characters making up whitespace for when moving or selecting by word.
    /// Should be called after SetWordChars.</summary>
    procedure SetWhitespaceChars(const ACharacters: UnicodeString);

    /// <summary>Get the set of characters making up whitespace for when moving or selecting by word.</summary>
    function GetWhitespaceChars: UnicodeString;

    /// <summary>Set the set of characters making up punctuation characters
    /// Should be called after SetWordChars.</summary>
    procedure SetPunctuationChars(const ACharacters: AnsiString);

    /// <summary>Get the set of characters making up punctuation characters</summary>
    function GetPunctuationChars: AnsiString;

    /// <summary>Get currently selected item position in the auto-completion list</summary>
    function AutoCGetCurrent: Integer;

    /// <summary>Get currently selected item text in the auto-completion list
    /// Returns the length of the item text
    /// Result is NUL-terminated.</summary>
    function AutoCGetCurrentText: UnicodeString;

    /// <summary>Set auto-completion case insensitive behaviour to either prefer case-sensitive matches or have no preference.</summary>
    procedure AutoCSetCaseInsensitiveBehaviour(ABehaviour: TDSciCaseInsensitiveBehaviour);

    /// <summary>Get auto-completion case insensitive behaviour.</summary>
    function AutoCGetCaseInsensitiveBehaviour: TDSciCaseInsensitiveBehaviour;

    /// <summary>Change the effect of autocompleting when there are multiple selections.</summary>
    procedure AutoCSetMulti(AMulti: TDSciMultiAutoComplete);

    /// <summary>Retrieve the effect of autocompleting when there are multiple selections.</summary>
    function AutoCGetMulti: TDSciMultiAutoComplete;

    /// <summary>Set the way autocompletion lists are ordered.</summary>
    procedure AutoCSetOrder(AOrder: TDSciOrdering);

    /// <summary>Get the way autocompletion lists are ordered.</summary>
    function AutoCGetOrder: TDSciOrdering;

    /// <summary>Can the caret preferred x position only be changed by explicit movement commands?</summary>
    function GetCaretSticky: TDSciCaretSticky;

    /// <summary>Stop the caret preferred x position changing when the user types.</summary>
    procedure SetCaretSticky(AUseCaretStickyBehaviour: TDSciCaretSticky);

    /// <summary>Enable/Disable convert-on-paste for line endings</summary>
    procedure SetPasteConvertEndings(AConvert: Boolean);

    /// <summary>Get convert-on-paste setting</summary>
    function GetPasteConvertEndings: Boolean;

    /// <summary>Set background alpha of the caret line.</summary>
    procedure SetCaretLineBackAlpha(AAlpha: TDSciAlpha);

    /// <summary>Get the background alpha of the caret line.</summary>
    function GetCaretLineBackAlpha: TDSciAlpha;

    /// <summary>Set the style of the caret to be drawn.</summary>
    procedure SetCaretStyle(ACaretStyle: TDSciCaretStyle);

    /// <summary>Returns the current style of the caret.</summary>
    function GetCaretStyle: TDSciCaretStyle;

    /// <summary>Set the indicator used for IndicatorFillRange and IndicatorClearRange</summary>
    procedure SetIndicatorCurrent(AIndicator: Integer);

    /// <summary>Get the current indicator</summary>
    function GetIndicatorCurrent: Integer;

    /// <summary>Set the value used for IndicatorFillRange</summary>
    procedure SetIndicatorValue(AValue: Integer);

    /// <summary>Get the current indicator value</summary>
    function GetIndicatorValue: Integer;

    /// <summary>Set number of entries in position cache</summary>
    procedure SetPositionCache(ASize: Integer);

    /// <summary>How many entries are allocated to the position cache?</summary>
    function GetPositionCache: Integer;

    /// <summary>Set maximum number of threads used for layout</summary>
    procedure SetLayoutThreads(AThreads: Integer);

    /// <summary>Get maximum number of threads used for layout</summary>
    function GetLayoutThreads: Integer;

    /// <summary>Set the string to separate parts when copying a multiple selection.</summary>
    procedure SetCopySeparator(const ASeparator: UnicodeString);

    /// <summary>Get the string to separate parts when copying a multiple selection.</summary>
    function GetCopySeparator: UnicodeString;

    /// <summary>Return a position which, to avoid performance costs, should not be within
    /// the range of a call to GetRangePointer.</summary>
    function GetGapPosition: NativeInt;

    /// <summary>Set the alpha fill colour of the given indicator.</summary>
    procedure IndicSetAlpha(AIndicator: Integer; AAlpha: TDSciAlpha);

    /// <summary>Get the alpha fill colour of the given indicator.</summary>
    function IndicGetAlpha(AIndicator: Integer): TDSciAlpha;

    /// <summary>Set the alpha outline colour of the given indicator.</summary>
    procedure IndicSetOutlineAlpha(AIndicator: Integer; AAlpha: TDSciAlpha);

    /// <summary>Get the alpha outline colour of the given indicator.</summary>
    function IndicGetOutlineAlpha(AIndicator: Integer): TDSciAlpha;

    /// <summary>Set extra ascent for each line</summary>
    procedure SetExtraAscent(AExtraAscent: Integer);

    /// <summary>Get extra ascent for each line</summary>
    function GetExtraAscent: Integer;

    /// <summary>Set extra descent for each line</summary>
    procedure SetExtraDescent(AExtraDescent: Integer);

    /// <summary>Get extra descent for each line</summary>
    function GetExtraDescent: Integer;

    /// <summary>Set the text in the text margin for a line</summary>
    procedure MarginSetText(ALine: NativeInt; const AText: UnicodeString);

    /// <summary>Get the text in the text margin for a line</summary>
    function MarginGetText(ALine: NativeInt): UnicodeString;

    /// <summary>Set the style number for the text margin for a line</summary>
    procedure MarginSetStyle(ALine: NativeInt; AStyle: Integer);

    /// <summary>Get the style number for the text margin for a line</summary>
    function MarginGetStyle(ALine: NativeInt): Integer;

    /// <summary>Set the style in the text margin for a line</summary>
    procedure MarginSetStyles(ALine: NativeInt; const AStyles: TDSciStyles);

    /// <summary>Get the styles in the text margin for a line</summary>
    function MarginGetStyles(ALine: NativeInt): TDSciStyles;

    /// <summary>Get the start of the range of style numbers used for margin text</summary>
    procedure MarginSetStyleOffset(AStyle: Integer);

    /// <summary>Get the start of the range of style numbers used for margin text</summary>
    function MarginGetStyleOffset: Integer;

    /// <summary>Set the margin options.</summary>
    procedure SetMarginOptions(AMarginOptions: TDSciMarginOption);

    /// <summary>Get the margin options.</summary>
    function GetMarginOptions: TDSciMarginOption;

    /// <summary>Set the annotation text for a line</summary>
    procedure AnnotationSetText(ALine: NativeInt; const AText: UnicodeString); overload;

    /// <summary>Get the annotation text for a line</summary>
    function AnnotationGetText(ALine: NativeInt): UnicodeString;

    /// <summary>Set the style number for the annotations for a line</summary>
    procedure AnnotationSetStyle(ALine: NativeInt; AStyle: Integer);

    /// <summary>Get the style number for the annotations for a line</summary>
    function AnnotationGetStyle(ALine: NativeInt): Integer;

    /// <summary>Set the annotation styles for a line</summary>
    procedure AnnotationSetStyles(ALine: NativeInt; const AStyles: TDSciStyles);

    /// <summary>Get the annotation styles for a line</summary>
    function AnnotationGetStyles(ALine: NativeInt): TDSciStyles;

    /// <summary>Get the number of annotation lines for a line</summary>
    function AnnotationGetLines(ALine: NativeInt): Integer;

    /// <summary>Set the visibility for the annotations for a view</summary>
    procedure AnnotationSetVisible(AVisible: TDSciAnnotationVisible);

    /// <summary>Get the visibility for the annotations for a view</summary>
    function AnnotationGetVisible: TDSciAnnotationVisible;

    /// <summary>Get the start of the range of style numbers used for annotations</summary>
    procedure AnnotationSetStyleOffset(AStyle: Integer);

    /// <summary>Get the start of the range of style numbers used for annotations</summary>
    function AnnotationGetStyleOffset: Integer;

    /// <summary>Set whether switching to rectangular mode while selecting with the mouse is allowed.</summary>
    procedure SetMouseSelectionRectangularSwitch(AMouseSelectionRectangularSwitch: Boolean);

    /// <summary>Whether switching to rectangular mode while selecting with the mouse is allowed.</summary>
    function GetMouseSelectionRectangularSwitch: Boolean;

    /// <summary>Set whether multiple selections can be made</summary>
    procedure SetMultipleSelection(AMultipleSelection: Boolean);

    /// <summary>Whether multiple selections can be made</summary>
    function GetMultipleSelection: Boolean;

    /// <summary>Set whether typing can be performed into multiple selections</summary>
    procedure SetAdditionalSelectionTyping(AAdditionalSelectionTyping: Boolean);

    /// <summary>Whether typing can be performed into multiple selections</summary>
    function GetAdditionalSelectionTyping: Boolean;

    /// <summary>Set whether additional carets will blink</summary>
    procedure SetAdditionalCaretsBlink(AAdditionalCaretsBlink: Boolean);

    /// <summary>Whether additional carets will blink</summary>
    function GetAdditionalCaretsBlink: Boolean;

    /// <summary>Set whether additional carets are visible</summary>
    procedure SetAdditionalCaretsVisible(AAdditionalCaretsVisible: Boolean);

    /// <summary>Whether additional carets are visible</summary>
    function GetAdditionalCaretsVisible: Boolean;

    /// <summary>How many selections are there?</summary>
    function GetSelections: Integer;

    /// <summary>Is every selected range empty?</summary>
    function GetSelectionEmpty: Boolean;

    /// <summary>Set the main selection</summary>
    procedure SetMainSelection(ASelection: Integer);

    /// <summary>Which selection is the main selection</summary>
    function GetMainSelection: Integer;

    /// <summary>Set the caret position of the nth selection.</summary>
    procedure SetSelectionNCaret(ASelection: Integer; APos: NativeInt);

    /// <summary>Return the caret position of the nth selection.</summary>
    function GetSelectionNCaret(ASelection: Integer): NativeInt;

    /// <summary>Set the anchor position of the nth selection.</summary>
    procedure SetSelectionNAnchor(ASelection: Integer; APosAnchor: NativeInt);

    /// <summary>Return the anchor position of the nth selection.</summary>
    function GetSelectionNAnchor(ASelection: Integer): NativeInt;

    /// <summary>Set the virtual space of the caret of the nth selection.</summary>
    procedure SetSelectionNCaretVirtualSpace(ASelection: Integer; ASpace: NativeInt);

    /// <summary>Return the virtual space of the caret of the nth selection.</summary>
    function GetSelectionNCaretVirtualSpace(ASelection: Integer): NativeInt;

    /// <summary>Set the virtual space of the anchor of the nth selection.</summary>
    procedure SetSelectionNAnchorVirtualSpace(ASelection: Integer; ASpace: NativeInt);

    /// <summary>Return the virtual space of the anchor of the nth selection.</summary>
    function GetSelectionNAnchorVirtualSpace(ASelection: Integer): NativeInt;

    /// <summary>Sets the position that starts the selection - this becomes the anchor.</summary>
    procedure SetSelectionNStart(ASelection: Integer; APos: NativeInt);

    /// <summary>Returns the position at the start of the selection.</summary>
    function GetSelectionNStart(ASelection: Integer): NativeInt;

    /// <summary>Returns the virtual space at the start of the selection.</summary>
    function GetSelectionNStartVirtualSpace(ASelection: Integer): NativeInt;

    /// <summary>Sets the position that ends the selection - this becomes the currentPosition.</summary>
    procedure SetSelectionNEnd(ASelection: Integer; APos: NativeInt);

    /// <summary>Returns the virtual space at the end of the selection.</summary>
    function GetSelectionNEndVirtualSpace(ASelection: Integer): NativeInt;

    /// <summary>Returns the position at the end of the selection.</summary>
    function GetSelectionNEnd(ASelection: Integer): NativeInt;

    /// <summary>Set the caret position of the rectangular selection.</summary>
    procedure SetRectangularSelectionCaret(ACaret: NativeInt);

    /// <summary>Return the caret position of the rectangular selection.</summary>
    function GetRectangularSelectionCaret: NativeInt;

    /// <summary>Set the anchor position of the rectangular selection.</summary>
    procedure SetRectangularSelectionAnchor(AAnchor: NativeInt);

    /// <summary>Return the anchor position of the rectangular selection.</summary>
    function GetRectangularSelectionAnchor: NativeInt;

    /// <summary>Set the virtual space of the caret of the rectangular selection.</summary>
    procedure SetRectangularSelectionCaretVirtualSpace(ASpace: NativeInt);

    /// <summary>Return the virtual space of the caret of the rectangular selection.</summary>
    function GetRectangularSelectionCaretVirtualSpace: NativeInt;

    /// <summary>Set the virtual space of the anchor of the rectangular selection.</summary>
    procedure SetRectangularSelectionAnchorVirtualSpace(ASpace: NativeInt);

    /// <summary>Return the virtual space of the anchor of the rectangular selection.</summary>
    function GetRectangularSelectionAnchorVirtualSpace: NativeInt;

    /// <summary>Set options for virtual space behaviour.</summary>
    procedure SetVirtualSpaceOptions(AVirtualSpaceOptions: TDSciVirtualSpaceSet);

    /// <summary>Return options for virtual space behaviour.</summary>
    function GetVirtualSpaceOptions: TDSciVirtualSpaceSet;

    procedure SetRectangularSelectionModifier(AModifier: TDSciKeyModSet);

    /// <summary>Get the modifier key used for rectangular selection.</summary>
    function GetRectangularSelectionModifier: TDSciKeyModSet;

    /// <summary>Set the foreground colour of additional selections.
    /// Must have previously called SetSelFore with non-zero first argument for this to have an effect.</summary>
    procedure SetAdditionalSelFore(AFore: TColor);

    /// <summary>Set the background colour of additional selections.
    /// Must have previously called SetSelBack with non-zero first argument for this to have an effect.</summary>
    procedure SetAdditionalSelBack(ABack: TColor);

    /// <summary>Set the alpha of the selection.</summary>
    procedure SetAdditionalSelAlpha(AAlpha: TDSciAlpha);

    /// <summary>Get the alpha of the selection.</summary>
    function GetAdditionalSelAlpha: TDSciAlpha;

    /// <summary>Set the foreground colour of additional carets.</summary>
    procedure SetAdditionalCaretFore(AFore: TColor);

    /// <summary>Get the foreground colour of additional carets.</summary>
    function GetAdditionalCaretFore: TColor;

    /// <summary>Set the identifier reported as idFrom in notification messages.</summary>
    procedure SetIdentifier(AIdentifier: Integer);

    /// <summary>Get the identifier.</summary>
    function GetIdentifier: Integer;

    /// <summary>Set the width for future RGBA image data.</summary>
    procedure RGBAImageSetWidth(AWidth: Integer);

    /// <summary>Set the height for future RGBA image data.</summary>
    procedure RGBAImageSetHeight(AHeight: Integer);

    /// <summary>Set the scale factor in percent for future RGBA image data.</summary>
    procedure RGBAImageSetScale(AScalePercent: Integer);

    /// <summary>Set the technology used.</summary>
    procedure SetTechnology(ATechnology: TDSciTechnology);

    /// <summary>Get the tech.</summary>
    function GetTechnology: TDSciTechnology;

    /// <summary>Is the caret line always visible?</summary>
    function GetCaretLineVisibleAlways: Boolean;

    /// <summary>Sets the caret line to always visible.</summary>
    procedure SetCaretLineVisibleAlways(AAlwaysVisible: Boolean);

    /// <summary>Set the line end types that the application wants to use. May not be used if incompatible with lexer or encoding.</summary>
    procedure SetLineEndTypesAllowed(ALineEndBitSet: TDSciLineEndType);

    /// <summary>Get the line end types currently allowed.</summary>
    function GetLineEndTypesAllowed: TDSciLineEndType;

    /// <summary>Get the line end types currently recognised. May be a subset of the allowed types due to lexer limitation.</summary>
    function GetLineEndTypesActive: TDSciLineEndType;

    /// <summary>Set the way a character is drawn.</summary>
    procedure SetRepresentation(AEncodedCharacter: AnsiString; ARepresentation: AnsiString);

    /// <summary>Get the way a character is drawn.
    /// Result is NUL-terminated.</summary>
    function GetRepresentation(AEncodedCharacter: AnsiString): AnsiString;

    /// <summary>Set the appearance of a representation.</summary>
    procedure SetRepresentationAppearance(AEncodedCharacter: UnicodeString; AAppearance: TDSciRepresentationAppearance);

    /// <summary>Get the appearance of a representation.</summary>
    function GetRepresentationAppearance(AEncodedCharacter: UnicodeString): TDSciRepresentationAppearance;

    /// <summary>Set the colour of a representation.</summary>
    procedure SetRepresentationColour(AEncodedCharacter: UnicodeString; AColour: TDSciColourAlpha);

    /// <summary>Get the colour of a representation.</summary>
    function GetRepresentationColour(AEncodedCharacter: UnicodeString): TDSciColourAlpha;

    /// <summary>Set the end of line annotation text for a line</summary>
    procedure EOLAnnotationSetText(ALine: NativeInt; const AText: UnicodeString);

    /// <summary>Get the end of line annotation text for a line</summary>
    function EOLAnnotationGetText(ALine: NativeInt): UnicodeString;

    /// <summary>Set the style number for the end of line annotations for a line</summary>
    procedure EOLAnnotationSetStyle(ALine: NativeInt; AStyle: Integer);

    /// <summary>Get the style number for the end of line annotations for a line</summary>
    function EOLAnnotationGetStyle(ALine: NativeInt): Integer;

    /// <summary>Set the visibility for the end of line annotations for a view</summary>
    procedure EOLAnnotationSetVisible(AVisible: TDSciEOLAnnotationVisible);

    /// <summary>Get the visibility for the end of line annotations for a view</summary>
    function EOLAnnotationGetVisible: TDSciEOLAnnotationVisible;

    /// <summary>Get the start of the range of style numbers used for end of line annotations</summary>
    procedure EOLAnnotationSetStyleOffset(AStyle: Integer);

    /// <summary>Get the start of the range of style numbers used for end of line annotations</summary>
    function EOLAnnotationGetStyleOffset: Integer;

    /// <summary>Get whether a feature is supported</summary>
    function SupportsFeature(AFeature: TDSciSupports): Boolean;

    /// <summary>Retrieve line character index state.</summary>
    function GetLineCharacterIndex: TDSciLineCharacterIndexType;

    /// <summary>Get whether drag-and-drop is enabled or disabled</summary>
    function GetDragDropEnabled: Boolean;

    /// <summary>Enable or disable drag-and-drop</summary>
    procedure SetDragDropEnabled(ADragDropEnabled: Boolean);

    /// <summary>Retrieve the lexing language of the document.</summary>
    function GetLexer: TDSciLexerId;

    /// <summary>Set up a value that may be used by a lexer for some optional feature.</summary>
    procedure SetProperty(const AKey: UnicodeString; const AValue: UnicodeString);

    /// <summary>Set up the key words used by the lexer.</summary>
    procedure SetKeyWords(AKeywordSet: Integer; const AKeyWords: UnicodeString);

    /// <summary>Retrieve a "property" value previously set with SetProperty.
    /// Result is NUL-terminated.</summary>
    function GetProperty(const AKey: UnicodeString): UnicodeString;

    /// <summary>Retrieve a "property" value previously set with SetProperty,
    /// with "$()" variable replacement on returned buffer.
    /// Result is NUL-terminated.</summary>
    function GetPropertyExpanded(AKey: UnicodeString): UnicodeString;

    /// <summary>Retrieve a "property" value previously set with SetProperty,
    /// interpreted as an int AFTER any "$()" variable replacement.</summary>
    function GetPropertyInt(AKey: UnicodeString; ADefault: Integer): Integer;

    /// <summary>Retrieve the name of the lexer.
    /// Return the length of the text.
    /// Result is NUL-terminated.</summary>
    function GetLexerLanguage: UnicodeString;

    /// <summary>Bit set of LineEndType enumertion for which line ends beyond the standard
    /// LF, CR, and CRLF are supported by the lexer.</summary>
    function GetLineEndTypesSupported: TDSciLineEndType;

    /// <summary>The starting style number for the sub styles associated with a base style</summary>
    function GetSubStylesStart(AStyleBase: Integer): Integer;

    /// <summary>The number of sub styles associated with a base style</summary>
    function GetSubStylesLength(AStyleBase: Integer): Integer;

    /// <summary>For a sub style, return the base style, else return the argument.</summary>
    function GetStyleFromSubStyle(ASubStyle: Integer): Integer;

    /// <summary>For a secondary style, return the primary style, else return the argument.</summary>
    function GetPrimaryStyleFromStyle(AStyle: Integer): Integer;

    /// <summary>Set the identifiers that are shown in a particular style</summary>
    procedure SetIdentifiers(AStyle: Integer; const AIdentifiers: AnsiString);

    /// <summary>Where styles are duplicated by a feature such as active/inactive code
    /// return the distance between the two types.</summary>
    function DistanceToSecondaryStyles: Integer;

    /// <summary>Get the set of base styles that can be extended with sub styles
    /// Result is NUL-terminated.</summary>
    function GetSubStyleBases: UnicodeString;

    /// <summary>Retrieve the number of named styles for the lexer.</summary>
    function GetNamedStyles: Integer;

    /// <summary>Retrieve bidirectional text display state.</summary>
    function GetBidirectional: TDSciBidirectional;

    /// <summary>Set bidirectional text display state.</summary>
    procedure SetBidirectional(ABidirectional: TDSciBidirectional);

    /// <summary>Divide each styling byte into lexical class bits (default: 5) and indicator
    /// bits (default: 3). If a lexer requires more than 32 lexical states, then this
    /// is used to expand the possible states.</summary>
    procedure SetStyleBits(ABits: Integer);

    /// <summary>Retrieve number of bits in style bytes used to hold the lexical state.</summary>
    function GetStyleBits: Integer;

    /// <summary>Retrieve the number of bits the current lexer needs for styling.</summary>
    function GetStyleBitsNeeded: Integer;

    /// <summary>Always interpret keyboard input as Unicode</summary>
    procedure SetKeysUnicode(AKeysUnicode: Boolean);

    /// <summary>Are keys always interpreted as Unicode?</summary>
    function GetKeysUnicode: Boolean;

    /// <summary>Is drawing done in two phases with backgrounds drawn before foregrounds?</summary>
    function GetTwoPhaseDraw: Boolean;

    /// <summary>In twoPhaseDraw mode, drawing is performed in two phases, first the background
    /// and then the foreground. This avoids chopping off characters that overlap the next run.</summary>
    procedure SetTwoPhaseDraw(ATwoPhase: Boolean);

    /// <summary>Set the lexing language of the document.</summary>
    procedure SetLexerLanguage(const ALanguage: UnicodeString);

