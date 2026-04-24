{* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is DScintillaTypes.pas
 *
 * The Initial Developer of the Original Code is Krystian Bigaj.
 *
 * Portions created by the Initial Developer are Copyright (C) 2010-2014
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * - Michal Gajek
 * - Marko Njezic
 * - Michael Staszewski
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** *}

unit DScintillaTypes;

interface

uses
  Windows;

type

// Native(U)Int types under D2007-D2009 are buggy.
// I'm not sure about, D2010-XE, but they are 32bit only.
{$IF CompilerVersion < 23}
  NativeInt = Integer;
  NativeUInt = Cardinal;
{$IFEND}

{$IF CompilerVersion < 20}
  UnicodeString = WideString;
{$IFEND}

{$IF CompilerVersion < 18.5}
  TBytes = array of Byte;
{$IFEND}

{ TDSciSendEditor }

  TDSciSendEditor = function(AMessage: UINT;
    WParam: WPARAM = 0; LParam: LPARAM = 0): LRESULT of object;

{ TDSciLexer }

  TDSciLexer = type Pointer;

{ TDSciDocument }

  TDSciDocument = type Pointer;

{ TDScintilla direct function types }

  TDScintillaFunction = function(APointer: Pointer; AMessage: Integer;
    WParam: WPARAM; LParam: LPARAM): LRESULT; cdecl;
  TDScintillaStatusFunction = function(APointer: Pointer; AMessage: Integer;
    WParam: WPARAM; LParam: LPARAM; var AStatus: Integer): LRESULT; cdecl;

{ TDSciCell }

  TDSciChar = AnsiChar;
  TDSciChars = array of TDSciChar;

  TDSciStyle = Byte;
  TDSciStyles = array of TDSciStyle;

  TDSciCell = packed record
    charByte: TDSciChar;
    styleByte: TDSciStyle;
  end;

  TDSciCells = array of TDSciCell;

{ TDSciCharacterRange }

  TDSciCharacterRange = record
    cpMin: Long;
    cpMax: Long;
  end;

{ TDSciCharacterRangeFull }

  TDSciCharacterRangeFull = record
    cpMin: NativeInt;
    cpMax: NativeInt;
  end;

{ TDSciTextRange }

  PDSciTextRange = ^TDSciTextRange;
  TDSciTextRange = record
    chrg: TDSciCharacterRange;
    lpstrText: PAnsiChar;
  end;

{ TDSciTextRangeFull }

  PDSciTextRangeFull = ^TDSciTextRangeFull;
  TDSciTextRangeFull = record
    chrg: TDSciCharacterRangeFull;
    lpstrText: PAnsiChar;
  end;

{ TDSciTextToFind }

  PDSciTextToFind = ^TDSciTextToFind;
  TDSciTextToFind = record
    chrg: TDSciCharacterRange;
    lpstrText: PAnsiChar;
    chrgText: TDSciCharacterRange;
  end;

{ TDSciTextToFindFull }

  PDSciTextToFindFull = ^TDSciTextToFindFull;
  TDSciTextToFindFull = record
    chrg: TDSciCharacterRangeFull;
    lpstrText: PAnsiChar;
    chrgText: TDSciCharacterRangeFull;
  end;

{ TDSciRangeToFormat }

  PDSciRangeToFormat = ^TDSciRangeToFormat;
  TDSciRangeToFormat = record
    hdc: HDC;                         // The HDC (device context) we print to
    hdcTarget: HDC;                   // The HDC we use for measuring (may be same as hdc)
    rc: TRect;                        // Rectangle in which to print
    rcPage: TRect;                    // Physically printable page size
    chrg: TDSciCharacterRange;        // Range of characters to print
  end;

{ TDSciRangeToFormatFull }

  PDSciRangeToFormatFull = ^TDSciRangeToFormatFull;
  TDSciRangeToFormatFull = record
    hdc: HDC;                         // The HDC (device context) we print to
    hdcTarget: HDC;                   // The HDC we use for measuring (may be same as hdc)
    rc: TRect;                        // Rectangle in which to print
    rcPage: TRect;                    // Physically printable page size
    chrg: TDSciCharacterRangeFull;    // Range of characters to print
  end;

{ TDSciSCNotification }

  TDSciNotifyHeader = TNMHdr;

  PDSciSCNotification = ^TDSciSCNotification;
  TDSciSCNotification = record
    NotifyHeader: TDSciNotifyHeader;
    position: NativeInt;
    // SCN_STYLENEEDED, SCN_DOUBLECLICK, SCN_MODIFIED, SCN_MARGINCLICK,
    // SCN_NEEDSHOWN, SCN_DWELLSTART, SCN_DWELLEND, SCN_CALLTIPCLICK,
    // SCN_HOTSPOTCLICK, SCN_HOTSPOTDOUBLECLICK, SCN_HOTSPOTRELEASECLICK,
    // SCN_INDICATORCLICK, SCN_INDICATORRELEASE,
    // SCN_USERLISTSELECTION, SCN_AUTOCSELECTION

    ch: Integer;
    // SCN_CHARADDED, SCN_KEY, SCN_AUTOCCOMPLETED, SCN_AUTOCSELECTION
    // SCN_USERLISTSELECTION
    modifiers: Integer;
    // SCN_KEY, SCN_DOUBLECLICK, SCN_HOTSPOTCLICK, SCN_HOTSPOTDOUBLECLICK,
    // SCN_HOTSPOTRELEASECLICK, SCN_INDICATORCLICK, SCN_INDICATORRELEASE

    modificationType: Integer;          // SCN_MODIFIED
    text: PAnsiChar;                    // SCN_MODIFIED, SCN_USERLISTSELECTION, SCN_AUTOCSELECTION, SCN_URIDROPPED
    length: NativeInt;                  // SCN_MODIFIED
    linesAdded: NativeInt;              // SCN_MODIFIED
    message: Integer;                   // SCN_MACRORECORD
    wParam: NativeUInt;                 // SCN_MACRORECORD
    lParam: NativeInt;                  // SCN_MACRORECORD
    line: NativeInt;                    // SCN_MODIFIED
    foldLevelNow: Integer;              // SCN_MODIFIED
    foldLevelPrev: Integer;             // SCN_MODIFIED
    margin: Integer;                    // SCN_MARGINCLICK
    listType: Integer;                  // SCN_USERLISTSELECTION
    x: Integer;                         // SCN_DWELLSTART, SCN_DWELLEND
    y: Integer;                         // SCN_DWELLSTART, SCN_DWELLEND
    token: Integer;                     // SCN_MODIFIED with SC_MOD_CONTAINER
    annotationLinesAdded: NativeInt;    // SCN_MODIFIED with SC_MOD_CHANGEANNOTATION
    updated: Integer;	                  // SCN_UPDATEUI
    listCompletionMethod: Integer;      // SCN_AUTOCSELECTION, SCN_AUTOCCOMPLETED, SCN_USERLISTSELECTION
    characterSource: Integer;           // SCN_CHARADDED
  end;

{ TDSciFileEncoding }

  TDSciFileEncoding = (
    dsfeAutoDetect,
    dsfeAnsi,
    dsfeUtf8,
    dsfeUtf8Bom,
    dsfeUtf16BEBom,
    dsfeUtf16LEBom,
    dsfeOther
  );

{ TDSciFileLoadStage }

  TDSciFileLoadStage = (
    sflsIdle,
    sflsPreparing,
    sflsReading,
    sflsDecoding,
    sflsLoading,
    sflsAttaching,
    sflsCompleted,
    sflsFailed,
    sflsCancelled
  );

{ TDSciFileLoadStatus }

  TDSciFileLoadStatus = record
    FileName: UnicodeString;
    Stage: TDSciFileLoadStage;
    BytesRead: Int64;
    TotalBytes: Int64;
    ErrorMessage: UnicodeString;
    IsAsync: Boolean;
    Encoding: TDSciFileEncoding;
    EncodingCodePage: Cardinal;
    EncodingName: UnicodeString;
  end;

  TDSciFileLoadStateEvent = procedure(Sender: TObject;
    const AStatus: TDSciFileLoadStatus) of object;

// <scigen-types>

  TDSciWhiteSpace = (
    scwsINVISIBLE,                          /// <summary>SCWS_INVISIBLE = 0
    scwsVISIBLE_ALWAYS,                     /// <summary>SCWS_VISIBLEALWAYS = 1
    scwsVISIBLE_AFTER_INDENT,               /// <summary>SCWS_VISIBLEAFTERINDENT = 2
    scwsVISIBLE_ONLY_IN_INDENT              /// <summary>SCWS_VISIBLEONLYININDENT = 3
  );

  TDSciTabDrawMode = (
    sctdmLONG_ARROW,                        /// <summary>SCTD_LONGARROW = 0
    sctdmSTRIKE_OUT,                        /// <summary>SCTD_STRIKEOUT = 1
    sctdmCONTROL_CHAR                       /// <summary>SCTD_CONTROLCHAR = 2
  );

  TDSciEndOfLine = (
    sceolCR_LF,                             /// <summary>SC_EOL_CRLF = 0
    sceolCR,                                /// <summary>SC_EOL_CR = 1
    sceolLF                                 /// <summary>SC_EOL_LF = 2
  );

  TDSciIMEInteraction = (
    scimeiWINDOWED,                         /// <summary>SC_IME_WINDOWED = 0
    scimeiINLINE                            /// <summary>SC_IME_INLINE = 1
  );

  TDSciAlpha = (
    scaTRANSPARENT,                         /// <summary>SC_ALPHA_TRANSPARENT = 0
    scaOPAQUE,                              /// <summary>SC_ALPHA_OPAQUE = 255
    scaNO_ALPHA                             /// <summary>SC_ALPHA_NOALPHA = 256
  );

  TDSciCursorShape = (
    sccsNORMAL,                             /// <summary>SC_CURSORNORMAL = -1
    sccsARROW,                              /// <summary>SC_CURSORARROW = 2
    sccsWAIT,                               /// <summary>SC_CURSORWAIT = 4
    sccsREVERSE_ARROW                       /// <summary>SC_CURSORREVERSEARROW = 7
  );

  TDSciMarkerSymbol = (
    scmsCIRCLE,                             /// <summary>SC_MARK_CIRCLE = 0
    scmsROUND_RECT,                         /// <summary>SC_MARK_ROUNDRECT = 1
    scmsARROW,                              /// <summary>SC_MARK_ARROW = 2
    scmsSMALL_RECT,                         /// <summary>SC_MARK_SMALLRECT = 3
    scmsSHORT_ARROW,                        /// <summary>SC_MARK_SHORTARROW = 4
    scmsEMPTY,                              /// <summary>SC_MARK_EMPTY = 5
    scmsARROW_DOWN,                         /// <summary>SC_MARK_ARROWDOWN = 6
    scmsMINUS,                              /// <summary>SC_MARK_MINUS = 7
    scmsPLUS,                               /// <summary>SC_MARK_PLUS = 8
    scmsV_LINE,                             /// <summary>SC_MARK_VLINE = 9
    scmsL_CORNER,                           /// <summary>SC_MARK_LCORNER = 10
    scmsT_CORNER,                           /// <summary>SC_MARK_TCORNER = 11
    scmsBOX_PLUS,                           /// <summary>SC_MARK_BOXPLUS = 12
    scmsBOX_PLUS_CONNECTED,                 /// <summary>SC_MARK_BOXPLUSCONNECTED = 13
    scmsBOX_MINUS,                          /// <summary>SC_MARK_BOXMINUS = 14
    scmsBOX_MINUS_CONNECTED,                /// <summary>SC_MARK_BOXMINUSCONNECTED = 15
    scmsL_CORNER_CURVE,                     /// <summary>SC_MARK_LCORNERCURVE = 16
    scmsT_CORNER_CURVE,                     /// <summary>SC_MARK_TCORNERCURVE = 17
    scmsCIRCLE_PLUS,                        /// <summary>SC_MARK_CIRCLEPLUS = 18
    scmsCIRCLE_PLUS_CONNECTED,              /// <summary>SC_MARK_CIRCLEPLUSCONNECTED = 19
    scmsCIRCLE_MINUS,                       /// <summary>SC_MARK_CIRCLEMINUS = 20
    scmsCIRCLE_MINUS_CONNECTED,             /// <summary>SC_MARK_CIRCLEMINUSCONNECTED = 21
    scmsBACKGROUND,                         /// <summary>SC_MARK_BACKGROUND = 22
    scmsDOT_DOT_DOT,                        /// <summary>SC_MARK_DOTDOTDOT = 23
    scmsARROWS,                             /// <summary>SC_MARK_ARROWS = 24
    scmsPIXMAP,                             /// <summary>SC_MARK_PIXMAP = 25
    scmsFULL_RECT,                          /// <summary>SC_MARK_FULLRECT = 26
    scmsLEFT_RECT,                          /// <summary>SC_MARK_LEFTRECT = 27
    scmsAVAILABLE,                          /// <summary>SC_MARK_AVAILABLE = 28
    scmsUNDERLINE,                          /// <summary>SC_MARK_UNDERLINE = 29
    scmsRGBA_IMAGE,                         /// <summary>SC_MARK_RGBAIMAGE = 30
    scmsBOOKMARK,                           /// <summary>SC_MARK_BOOKMARK = 31
    scmsVERTICAL_BOOKMARK,                  /// <summary>SC_MARK_VERTICALBOOKMARK = 32
    scmsBAR,                                /// <summary>SC_MARK_BAR = 33
    scmsCHARACTER                           /// <summary>SC_MARK_CHARACTER = 10000
  );

  TDSciMarkerOutline = (
    scmoHISTORY_REVERTED_TO_ORIGIN,         /// <summary>SC_MARKNUM_HISTORY_REVERTED_TO_ORIGIN = 21
    scmoHISTORY_SAVED,                      /// <summary>SC_MARKNUM_HISTORY_SAVED = 22
    scmoHISTORY_MODIFIED,                   /// <summary>SC_MARKNUM_HISTORY_MODIFIED = 23
    scmoHISTORY_REVERTED_TO_MODIFIED,       /// <summary>SC_MARKNUM_HISTORY_REVERTED_TO_MODIFIED = 24
    scmoFOLDER_END,                         /// <summary>SC_MARKNUM_FOLDEREND = 25
    scmoFOLDER_OPEN_MID,                    /// <summary>SC_MARKNUM_FOLDEROPENMID = 26
    scmoFOLDER_MID_TAIL,                    /// <summary>SC_MARKNUM_FOLDERMIDTAIL = 27
    scmoFOLDER_TAIL,                        /// <summary>SC_MARKNUM_FOLDERTAIL = 28
    scmoFOLDER_SUB,                         /// <summary>SC_MARKNUM_FOLDERSUB = 29
    scmoFOLDER,                             /// <summary>SC_MARKNUM_FOLDER = 30
    scmoFOLDER_OPEN                         /// <summary>SC_MARKNUM_FOLDEROPEN = 31
  );

  TDSciMarginType = (
    scmtSYMBOL,                             /// <summary>SC_MARGIN_SYMBOL = 0
    scmtNUMBER,                             /// <summary>SC_MARGIN_NUMBER = 1
    scmtBACK,                               /// <summary>SC_MARGIN_BACK = 2
    scmtFORE,                               /// <summary>SC_MARGIN_FORE = 3
    scmtTEXT,                               /// <summary>SC_MARGIN_TEXT = 4
    scmtR_TEXT,                             /// <summary>SC_MARGIN_RTEXT = 5
    scmtCOLOUR                              /// <summary>SC_MARGIN_COLOUR = 6
  );

  TDSciStylesCommon = (
    scscDEFAULT,                            /// <summary>STYLE_DEFAULT = 32
    scscLINE_NUMBER,                        /// <summary>STYLE_LINENUMBER = 33
    scscBRACE_LIGHT,                        /// <summary>STYLE_BRACELIGHT = 34
    scscBRACE_BAD,                          /// <summary>STYLE_BRACEBAD = 35
    scscCONTROL_CHAR,                       /// <summary>STYLE_CONTROLCHAR = 36
    scscINDENT_GUIDE,                       /// <summary>STYLE_INDENTGUIDE = 37
    scscCALL_TIP,                           /// <summary>STYLE_CALLTIP = 38
    scscFOLD_DISPLAY_TEXT,                  /// <summary>STYLE_FOLDDISPLAYTEXT = 39
    scscLAST_PREDEFINED,                    /// <summary>STYLE_LASTPREDEFINED = 39
    scscMAX                                 /// <summary>STYLE_MAX = 255
  );

  TDSciCharacterSet = (
    sccsANSI,                               /// <summary>SC_CHARSET_ANSI = 0
    sccsDEFAULT,                            /// <summary>SC_CHARSET_DEFAULT = 1
    sccsBALTIC,                             /// <summary>SC_CHARSET_BALTIC = 186
    sccsCHINESE_BIG5,                       /// <summary>SC_CHARSET_CHINESEBIG5 = 136
    sccsEAST_EUROPE,                        /// <summary>SC_CHARSET_EASTEUROPE = 238
    sccsG_B_2312,                           /// <summary>SC_CHARSET_GB2312 = 134
    sccsGREEK,                              /// <summary>SC_CHARSET_GREEK = 161
    sccsHANGUL,                             /// <summary>SC_CHARSET_HANGUL = 129
    sccsMAC,                                /// <summary>SC_CHARSET_MAC = 77
    sccsOEM,                                /// <summary>SC_CHARSET_OEM = 255
    sccsRUSSIAN,                            /// <summary>SC_CHARSET_RUSSIAN = 204
    sccsOEM_866,                            /// <summary>SC_CHARSET_OEM866 = 866
    sccsCYRILLIC,                           /// <summary>SC_CHARSET_CYRILLIC = 1251
    sccsSHIFT_JIS,                          /// <summary>SC_CHARSET_SHIFTJIS = 128
    sccsSYMBOL,                             /// <summary>SC_CHARSET_SYMBOL = 2
    sccsTURKISH,                            /// <summary>SC_CHARSET_TURKISH = 162
    sccsJOHAB,                              /// <summary>SC_CHARSET_JOHAB = 130
    sccsHEBREW,                             /// <summary>SC_CHARSET_HEBREW = 177
    sccsARABIC,                             /// <summary>SC_CHARSET_ARABIC = 178
    sccsVIETNAMESE,                         /// <summary>SC_CHARSET_VIETNAMESE = 163
    sccsTHAI,                               /// <summary>SC_CHARSET_THAI = 222
    sccsISO_8859_15                         /// <summary>SC_CHARSET_8859_15 = 1000
  );

  TDSciCaseVisible = (
    sccvMIXED,                              /// <summary>SC_CASE_MIXED = 0
    sccvUPPER,                              /// <summary>SC_CASE_UPPER = 1
    sccvLOWER,                              /// <summary>SC_CASE_LOWER = 2
    sccvCAMEL                               /// <summary>SC_CASE_CAMEL = 3
  );

  TDSciFontWeight = (
    scfwNORMAL,                             /// <summary>SC_WEIGHT_NORMAL = 400
    scfwSEMI_BOLD,                          /// <summary>SC_WEIGHT_SEMIBOLD = 600
    scfwBOLD                                /// <summary>SC_WEIGHT_BOLD = 700
  );

  TDSciFontStretch = (
    scfsULTRA_CONDENSED,                    /// <summary>SC_STRETCH_ULTRA_CONDENSED = 1
    scfsEXTRA_CONDENSED,                    /// <summary>SC_STRETCH_EXTRA_CONDENSED = 2
    scfsCONDENSED,                          /// <summary>SC_STRETCH_CONDENSED = 3
    scfsSEMI_CONDENSED,                     /// <summary>SC_STRETCH_SEMI_CONDENSED = 4
    scfsNORMAL,                             /// <summary>SC_STRETCH_NORMAL = 5
    scfsSEMI_EXPANDED,                      /// <summary>SC_STRETCH_SEMI_EXPANDED = 6
    scfsEXPANDED,                           /// <summary>SC_STRETCH_EXPANDED = 7
    scfsEXTRA_EXPANDED,                     /// <summary>SC_STRETCH_EXTRA_EXPANDED = 8
    scfsULTRA_EXPANDED                      /// <summary>SC_STRETCH_ULTRA_EXPANDED = 9
  );

  TDSciElement = (
    sceLIST,                                /// <summary>SC_ELEMENT_LIST = 0
    sceLIST_BACK,                           /// <summary>SC_ELEMENT_LIST_BACK = 1
    sceLIST_SELECTED,                       /// <summary>SC_ELEMENT_LIST_SELECTED = 2
    sceLIST_SELECTED_BACK,                  /// <summary>SC_ELEMENT_LIST_SELECTED_BACK = 3
    sceSELECTION_TEXT,                      /// <summary>SC_ELEMENT_SELECTION_TEXT = 10
    sceSELECTION_BACK,                      /// <summary>SC_ELEMENT_SELECTION_BACK = 11
    sceSELECTION_ADDITIONAL_TEXT,           /// <summary>SC_ELEMENT_SELECTION_ADDITIONAL_TEXT = 12
    sceSELECTION_ADDITIONAL_BACK,           /// <summary>SC_ELEMENT_SELECTION_ADDITIONAL_BACK = 13
    sceSELECTION_SECONDARY_TEXT,            /// <summary>SC_ELEMENT_SELECTION_SECONDARY_TEXT = 14
    sceSELECTION_SECONDARY_BACK,            /// <summary>SC_ELEMENT_SELECTION_SECONDARY_BACK = 15
    sceSELECTION_INACTIVE_TEXT,             /// <summary>SC_ELEMENT_SELECTION_INACTIVE_TEXT = 16
    sceSELECTION_INACTIVE_BACK,             /// <summary>SC_ELEMENT_SELECTION_INACTIVE_BACK = 17
    sceSELECTION_INACTIVE_ADDITIONAL_TEXT,  /// <summary>SC_ELEMENT_SELECTION_INACTIVE_ADDITIONAL_TEXT = 18
    sceSELECTION_INACTIVE_ADDITIONAL_BACK,  /// <summary>SC_ELEMENT_SELECTION_INACTIVE_ADDITIONAL_BACK = 19
    sceCARET,                               /// <summary>SC_ELEMENT_CARET = 40
    sceCARET_ADDITIONAL,                    /// <summary>SC_ELEMENT_CARET_ADDITIONAL = 41
    sceCARET_LINE_BACK,                     /// <summary>SC_ELEMENT_CARET_LINE_BACK = 50
    sceWHITE_SPACE,                         /// <summary>SC_ELEMENT_WHITE_SPACE = 60
    sceWHITE_SPACE_BACK,                    /// <summary>SC_ELEMENT_WHITE_SPACE_BACK = 61
    sceHOT_SPOT_ACTIVE,                     /// <summary>SC_ELEMENT_HOT_SPOT_ACTIVE = 70
    sceHOT_SPOT_ACTIVE_BACK,                /// <summary>SC_ELEMENT_HOT_SPOT_ACTIVE_BACK = 71
    sceFOLD_LINE,                           /// <summary>SC_ELEMENT_FOLD_LINE = 80
    sceHIDDEN_LINE                          /// <summary>SC_ELEMENT_HIDDEN_LINE = 81
  );

  TDSciLayer = (
    sclBASE,                                /// <summary>SC_LAYER_BASE = 0
    sclUNDER_TEXT,                          /// <summary>SC_LAYER_UNDER_TEXT = 1
    sclOVER_TEXT                            /// <summary>SC_LAYER_OVER_TEXT = 2
  );

  TDSciIndicatorStyle = (
    scisPLAIN,                              /// <summary>INDIC_PLAIN = 0
    scisSQUIGGLE,                           /// <summary>INDIC_SQUIGGLE = 1
    scisT_T,                                /// <summary>INDIC_TT = 2
    scisDIAGONAL,                           /// <summary>INDIC_DIAGONAL = 3
    scisSTRIKE,                             /// <summary>INDIC_STRIKE = 4
    scisHIDDEN,                             /// <summary>INDIC_HIDDEN = 5
    scisBOX,                                /// <summary>INDIC_BOX = 6
    scisROUND_BOX,                          /// <summary>INDIC_ROUNDBOX = 7
    scisSTRAIGHT_BOX,                       /// <summary>INDIC_STRAIGHTBOX = 8
    scisDASH,                               /// <summary>INDIC_DASH = 9
    scisDOTS,                               /// <summary>INDIC_DOTS = 10
    scisSQUIGGLE_LOW,                       /// <summary>INDIC_SQUIGGLELOW = 11
    scisDOT_BOX,                            /// <summary>INDIC_DOTBOX = 12
    scisSQUIGGLE_PIXMAP,                    /// <summary>INDIC_SQUIGGLEPIXMAP = 13
    scisCOMPOSITION_THICK,                  /// <summary>INDIC_COMPOSITIONTHICK = 14
    scisCOMPOSITION_THIN,                   /// <summary>INDIC_COMPOSITIONTHIN = 15
    scisFULL_BOX,                           /// <summary>INDIC_FULLBOX = 16
    scisTEXT_FORE,                          /// <summary>INDIC_TEXTFORE = 17
    scisPOINT,                              /// <summary>INDIC_POINT = 18
    scisPOINT_CHARACTER,                    /// <summary>INDIC_POINTCHARACTER = 19
    scisGRADIENT,                           /// <summary>INDIC_GRADIENT = 20
    scisGRADIENT_CENTRE,                    /// <summary>INDIC_GRADIENTCENTRE = 21
    scisPOINT_TOP,                          /// <summary>INDIC_POINT_TOP = 22
    scisCONTAINER,                          /// <summary>INDIC_CONTAINER = 8
    scisIME,                                /// <summary>INDIC_IME = 32
    scisIME_MAX,                            /// <summary>INDIC_IME_MAX = 35
    scisMAX                                 /// <summary>INDIC_MAX = 35
  );

  TDSciIndicatorNumbers = (
    scinCONTAINER,                          /// <summary>INDICATOR_CONTAINER = 8
    scinIME,                                /// <summary>INDICATOR_IME = 32
    scinIME_MAX,                            /// <summary>INDICATOR_IME_MAX = 35
    scinHISTORY_REVERTED_TO_ORIGIN_INSERTION,/// <summary>INDICATOR_HISTORY_REVERTED_TO_ORIGIN_INSERTION = 36
    scinHISTORY_REVERTED_TO_ORIGIN_DELETION,/// <summary>INDICATOR_HISTORY_REVERTED_TO_ORIGIN_DELETION = 37
    scinHISTORY_SAVED_INSERTION,            /// <summary>INDICATOR_HISTORY_SAVED_INSERTION = 38
    scinHISTORY_SAVED_DELETION,             /// <summary>INDICATOR_HISTORY_SAVED_DELETION = 39
    scinHISTORY_MODIFIED_INSERTION,         /// <summary>INDICATOR_HISTORY_MODIFIED_INSERTION = 40
    scinHISTORY_MODIFIED_DELETION,          /// <summary>INDICATOR_HISTORY_MODIFIED_DELETION = 41
    scinHISTORY_REVERTED_TO_MODIFIED_INSERTION,/// <summary>INDICATOR_HISTORY_REVERTED_TO_MODIFIED_INSERTION = 42
    scinHISTORY_REVERTED_TO_MODIFIED_DELETION,/// <summary>INDICATOR_HISTORY_REVERTED_TO_MODIFIED_DELETION = 43
    scinMAX                                 /// <summary>INDICATOR_MAX = 43
  );

  TDSciIndicValue = (
    scivBIT,                                /// <summary>SC_INDICVALUEBIT = $1000000
    scivMASK                                /// <summary>SC_INDICVALUEMASK = $FFFFFF
  );

  TDSciIndicFlag = (
    scifNONE,                               /// <summary>SC_INDICFLAG_NONE = 0
    scifVALUE_FORE                          /// <summary>SC_INDICFLAG_VALUEFORE = 1
  );

  TDSciAutoCompleteOption = (
    scacoNORMAL,                            /// <summary>SC_AUTOCOMPLETE_NORMAL = 0
    scacoFIXED_SIZE,                        /// <summary>SC_AUTOCOMPLETE_FIXED_SIZE = 1
    scacoSELECT_FIRST_ITEM                  /// <summary>SC_AUTOCOMPLETE_SELECT_FIRST_ITEM = 2
  );

  TDSciIndentView = (
    scivNONE,                               /// <summary>SC_IV_NONE = 0
    scivREAL,                               /// <summary>SC_IV_REAL = 1
    scivLOOK_FORWARD,                       /// <summary>SC_IV_LOOKFORWARD = 2
    scivLOOK_BOTH                           /// <summary>SC_IV_LOOKBOTH = 3
  );

  TDSciPrintOption = (
    scpoNORMAL,                             /// <summary>SC_PRINT_NORMAL = 0
    scpoINVERT_LIGHT,                       /// <summary>SC_PRINT_INVERTLIGHT = 1
    scpoBLACK_ON_WHITE,                     /// <summary>SC_PRINT_BLACKONWHITE = 2
    scpoCOLOUR_ON_WHITE,                    /// <summary>SC_PRINT_COLOURONWHITE = 3
    scpoCOLOUR_ON_WHITE_DEFAULT_B_G,        /// <summary>SC_PRINT_COLOURONWHITEDEFAULTBG = 4
    scpoSCREEN_COLOURS                      /// <summary>SC_PRINT_SCREENCOLOURS = 5
  );

  TDSciFindOption = (
    scfoWHOLE_WORD,                         /// <summary>SCFIND_WHOLEWORD = $2
    scfoMATCH_CASE,                         /// <summary>SCFIND_MATCHCASE = $4
    scfoWORD_START,                         /// <summary>SCFIND_WORDSTART = $00100000
    scfoREG_EXP,                            /// <summary>SCFIND_REGEXP = $00200000
    scfoPOSIX,                              /// <summary>SCFIND_POSIX = $00400000
    scfoCXX11_REG_EX                        /// <summary>SCFIND_CXX11REGEX = $00800000
  );
  TDSciFindOptionSet = set of TDSciFindOption;

  TDSciChangeHistoryOption = (
    scchoDISABLED,                          /// <summary>SC_CHANGE_HISTORY_DISABLED = 0
    scchoENABLED,                           /// <summary>SC_CHANGE_HISTORY_ENABLED = 1
    scchoMARKERS,                           /// <summary>SC_CHANGE_HISTORY_MARKERS = 2
    scchoINDICATORS                         /// <summary>SC_CHANGE_HISTORY_INDICATORS = 4
  );

  TDSciUndoSelectionHistoryOption = (
    scushoDISABLED,                         /// <summary>SC_UNDO_SELECTION_HISTORY_DISABLED = 0
    scushoENABLED,                          /// <summary>SC_UNDO_SELECTION_HISTORY_ENABLED = 1
    scushoSCROLL                            /// <summary>SC_UNDO_SELECTION_HISTORY_SCROLL = 2
  );

  TDSciFoldLevel = (
    scflBASE,                               /// <summary>SC_FOLDLEVELBASE = $400
    scflWHITE_FLAG,                         /// <summary>SC_FOLDLEVELWHITEFLAG = $1000
    scflHEADER_FLAG,                        /// <summary>SC_FOLDLEVELHEADERFLAG = $2000
    scflNUMBER_MASK                         /// <summary>SC_FOLDLEVELNUMBERMASK = $0FFF
  );
  TDSciFoldLevelSet = set of TDSciFoldLevel;

  TDSciFoldDisplayTextStyle = (
    scfdtsHIDDEN,                           /// <summary>SC_FOLDDISPLAYTEXT_HIDDEN = 0
    scfdtsSTANDARD,                         /// <summary>SC_FOLDDISPLAYTEXT_STANDARD = 1
    scfdtsBOXED                             /// <summary>SC_FOLDDISPLAYTEXT_BOXED = 2
  );

  TDSciFoldAction = (
    scfaCONTRACT,                           /// <summary>SC_FOLDACTION_CONTRACT = 0
    scfaEXPAND,                             /// <summary>SC_FOLDACTION_EXPAND = 1
    scfaTOGGLE,                             /// <summary>SC_FOLDACTION_TOGGLE = 2
    scfaCONTRACT_EVERY_LEVEL                /// <summary>SC_FOLDACTION_CONTRACT_EVERY_LEVEL = 4
  );

  TDSciAutomaticFold = (
    scafNONE,                               /// <summary>SC_AUTOMATICFOLD_NONE = $0000
    scafSHOW,                               /// <summary>SC_AUTOMATICFOLD_SHOW = $0001
    scafCLICK,                              /// <summary>SC_AUTOMATICFOLD_CLICK = $0002
    scafCHANGE                              /// <summary>SC_AUTOMATICFOLD_CHANGE = $0004
  );

  TDSciFoldFlag = (
    scffLINE_BEFORE_EXPANDED,               /// <summary>SC_FOLDFLAG_LINEBEFORE_EXPANDED = $0002
    scffLINE_BEFORE_CONTRACTED,             /// <summary>SC_FOLDFLAG_LINEBEFORE_CONTRACTED = $0004
    scffLINE_AFTER_EXPANDED,                /// <summary>SC_FOLDFLAG_LINEAFTER_EXPANDED = $0008
    scffLINE_AFTER_CONTRACTED,              /// <summary>SC_FOLDFLAG_LINEAFTER_CONTRACTED = $0010
    scffLEVEL_NUMBERS,                      /// <summary>SC_FOLDFLAG_LEVELNUMBERS = $0040
    scffLINE_STATE                          /// <summary>SC_FOLDFLAG_LINESTATE = $0080
  );
  TDSciFoldFlagSet = set of TDSciFoldFlag;

  TDSciIdleStyling = (
    scisNONE,                               /// <summary>SC_IDLESTYLING_NONE = 0
    scisTO_VISIBLE,                         /// <summary>SC_IDLESTYLING_TOVISIBLE = 1
    scisAFTER_VISIBLE,                      /// <summary>SC_IDLESTYLING_AFTERVISIBLE = 2
    scisALL                                 /// <summary>SC_IDLESTYLING_ALL = 3
  );

  TDSciWrap = (
    scwNONE,                                /// <summary>SC_WRAP_NONE = 0
    scwWORD,                                /// <summary>SC_WRAP_WORD = 1
    scwCHAR,                                /// <summary>SC_WRAP_CHAR = 2
    scwWHITE_SPACE                          /// <summary>SC_WRAP_WHITESPACE = 3
  );

  TDSciWrapVisualFlag = (
    scwvfEND,                               /// <summary>SC_WRAPVISUALFLAG_END = $0001
    scwvfSTART,                             /// <summary>SC_WRAPVISUALFLAG_START = $0002
    scwvfMARGIN                             /// <summary>SC_WRAPVISUALFLAG_MARGIN = $0004
  );
  TDSciWrapVisualFlagSet = set of TDSciWrapVisualFlag;

  TDSciWrapVisualLocation = (
    scwvlEND_BY_TEXT,                       /// <summary>SC_WRAPVISUALFLAGLOC_END_BY_TEXT = $0001
    scwvlSTART_BY_TEXT                      /// <summary>SC_WRAPVISUALFLAGLOC_START_BY_TEXT = $0002
  );
  TDSciWrapVisualLocationSet = set of TDSciWrapVisualLocation;

  TDSciWrapIndentMode = (
    scwimFIXED,                             /// <summary>SC_WRAPINDENT_FIXED = 0
    scwimSAME,                              /// <summary>SC_WRAPINDENT_SAME = 1
    scwimINDENT,                            /// <summary>SC_WRAPINDENT_INDENT = 2
    scwimDEEP_INDENT                        /// <summary>SC_WRAPINDENT_DEEPINDENT = 3
  );

  TDSciLineCache = (
    sclcNONE,                               /// <summary>SC_CACHE_NONE = 0
    sclcCARET,                              /// <summary>SC_CACHE_CARET = 1
    sclcPAGE,                               /// <summary>SC_CACHE_PAGE = 2
    sclcDOCUMENT                            /// <summary>SC_CACHE_DOCUMENT = 3
  );

  TDSciPhasesDraw = (
    scpdONE,                                /// <summary>SC_PHASES_ONE = 0
    scpdTWO,                                /// <summary>SC_PHASES_TWO = 1
    scpdMULTIPLE                            /// <summary>SC_PHASES_MULTIPLE = 2
  );

  TDSciFontQuality = (
    scfqQUALITY_MASK,                       /// <summary>SC_EFF_QUALITY_MASK = $F
    scfqQUALITY_DEFAULT,                    /// <summary>SC_EFF_QUALITY_DEFAULT = 0
    scfqQUALITY_NON_ANTIALIASED,            /// <summary>SC_EFF_QUALITY_NON_ANTIALIASED = 1
    scfqQUALITY_ANTIALIASED,                /// <summary>SC_EFF_QUALITY_ANTIALIASED = 2
    scfqQUALITY_LCD_OPTIMIZED               /// <summary>SC_EFF_QUALITY_LCD_OPTIMIZED = 3
  );

  TDSciMultiPaste = (
    scmpONCE,                               /// <summary>SC_MULTIPASTE_ONCE = 0
    scmpEACH                                /// <summary>SC_MULTIPASTE_EACH = 1
  );

  TDSciAccessibility = (
    scaDISABLED,                            /// <summary>SC_ACCESSIBILITY_DISABLED = 0
    scaENABLED                              /// <summary>SC_ACCESSIBILITY_ENABLED = 1
  );

  TDSciEdgeVisualStyle = (
    scevsNONE,                              /// <summary>EDGE_NONE = 0
    scevsLINE,                              /// <summary>EDGE_LINE = 1
    scevsBACKGROUND,                        /// <summary>EDGE_BACKGROUND = 2
    scevsMULTI_LINE                         /// <summary>EDGE_MULTILINE = 3
  );

  TDSciPopUp = (
    scpuNEVER,                              /// <summary>SC_POPUP_NEVER = 0
    scpuALL,                                /// <summary>SC_POPUP_ALL = 1
    scpuTEXT                                /// <summary>SC_POPUP_TEXT = 2
  );

  TDSciDocumentOption = (
    scdoDEFAULT,                            /// <summary>SC_DOCUMENTOPTION_DEFAULT = 0
    scdoSTYLES_NONE,                        /// <summary>SC_DOCUMENTOPTION_STYLES_NONE = $1
    scdoTEXT_LARGE                          /// <summary>SC_DOCUMENTOPTION_TEXT_LARGE = $100
  );

  TDSciStatus = (
    scsOK,                                  /// <summary>SC_STATUS_OK = 0
    scsFAILURE,                             /// <summary>SC_STATUS_FAILURE = 1
    scsBAD_ALLOC,                           /// <summary>SC_STATUS_BADALLOC = 2
    scsWARN_START,                          /// <summary>SC_STATUS_WARN_START = 1000
    scsREG_EX                               /// <summary>SC_STATUS_WARN_REGEX = 1001
  );

  TDSciVisiblePolicy = (
    scvpSLOP,                               /// <summary>VISIBLE_SLOP = $01
    scvpSTRICT                              /// <summary>VISIBLE_STRICT = $04
  );
  TDSciVisiblePolicySet = set of TDSciVisiblePolicy;

  TDSciCaretPolicy = (
    sccpSLOP,                               /// <summary>CARET_SLOP = $01
    sccpSTRICT,                             /// <summary>CARET_STRICT = $04
    sccpJUMPS,                              /// <summary>CARET_JUMPS = $10
    sccpEVEN                                /// <summary>CARET_EVEN = $08
  );
  TDSciCaretPolicySet = set of TDSciCaretPolicy;

  TDSciSelectionMode = (
    scsmSTREAM,                             /// <summary>SC_SEL_STREAM = 0
    scsmRECTANGLE,                          /// <summary>SC_SEL_RECTANGLE = 1
    scsmLINES,                              /// <summary>SC_SEL_LINES = 2
    scsmTHIN                                /// <summary>SC_SEL_THIN = 3
  );

  TDSciCaseInsensitiveBehaviour = (
    sccibRESPECT_CASE,                      /// <summary>SC_CASEINSENSITIVEBEHAVIOUR_RESPECTCASE = 0
    sccibIGNORE_CASE                        /// <summary>SC_CASEINSENSITIVEBEHAVIOUR_IGNORECASE = 1
  );

  TDSciMultiAutoComplete = (
    scmacONCE,                              /// <summary>SC_MULTIAUTOC_ONCE = 0
    scmacEACH                               /// <summary>SC_MULTIAUTOC_EACH = 1
  );

  TDSciOrdering = (
    scoPRE_SORTED,                          /// <summary>SC_ORDER_PRESORTED = 0
    scoPERFORM_SORT,                        /// <summary>SC_ORDER_PERFORMSORT = 1
    scoCUSTOM                               /// <summary>SC_ORDER_CUSTOM = 2
  );

  TDSciCaretSticky = (
    sccsOFF,                                /// <summary>SC_CARETSTICKY_OFF = 0
    sccsON,                                 /// <summary>SC_CARETSTICKY_ON = 1
    sccsWHITE_SPACE                         /// <summary>SC_CARETSTICKY_WHITESPACE = 2
  );

  TDSciCaretStyle = (
    sccsINVISIBLE,                          /// <summary>CARETSTYLE_INVISIBLE = 0
    sccsLINE,                               /// <summary>CARETSTYLE_LINE = 1
    sccsBLOCK,                              /// <summary>CARETSTYLE_BLOCK = 2
    sccsOVERSTRIKE_BAR,                     /// <summary>CARETSTYLE_OVERSTRIKE_BAR = 0
    sccsOVERSTRIKE_BLOCK,                   /// <summary>CARETSTYLE_OVERSTRIKE_BLOCK = $10
    sccsCURSES,                             /// <summary>CARETSTYLE_CURSES = $20
    sccsINS_MASK,                           /// <summary>CARETSTYLE_INS_MASK = $F
    sccsBLOCK_AFTER                         /// <summary>CARETSTYLE_BLOCK_AFTER = $100
  );

  TDSciMarginOption = (
    scmoNONE,                               /// <summary>SC_MARGINOPTION_NONE = 0
    scmoSUB_LINE_SELECT                     /// <summary>SC_MARGINOPTION_SUBLINESELECT = 1
  );

  TDSciAnnotationVisible = (
    scavHIDDEN,                             /// <summary>ANNOTATION_HIDDEN = 0
    scavSTANDARD,                           /// <summary>ANNOTATION_STANDARD = 1
    scavBOXED,                              /// <summary>ANNOTATION_BOXED = 2
    scavINDENTED                            /// <summary>ANNOTATION_INDENTED = 3
  );

  TDSciUndoFlags = (
    scufMAY_COALESCE                        /// <summary>UNDO_MAY_COALESCE = 1
  );
  TDSciUndoFlagsSet = set of TDSciUndoFlags;

  TDSciVirtualSpace = (
    scvsRECTANGULAR_SELECTION,              /// <summary>SCVS_RECTANGULARSELECTION = 1
    scvsUSER_ACCESSIBLE,                    /// <summary>SCVS_USERACCESSIBLE = 2
    scvsNO_WRAP_LINE_START                  /// <summary>SCVS_NOWRAPLINESTART = 4
  );
  TDSciVirtualSpaceSet = set of TDSciVirtualSpace;

  TDSciTechnology = (
    sctDEFAULT,                             /// <summary>SC_TECHNOLOGY_DEFAULT = 0
    sctDIRECT_WRITE,                        /// <summary>SC_TECHNOLOGY_DIRECTWRITE = 1
    sctDIRECT_WRITE_RETAIN,                 /// <summary>SC_TECHNOLOGY_DIRECTWRITERETAIN = 2
    sctDIRECT_WRITE_D_C,                    /// <summary>SC_TECHNOLOGY_DIRECTWRITEDC = 3
    sctDIRECT_WRITE_1                       /// <summary>SC_TECHNOLOGY_DIRECT_WRITE_1 = 4
  );

  TDSciLineEndType = (
    scletDEFAULT,                           /// <summary>SC_LINE_END_TYPE_DEFAULT = 0
    scletUNICODE                            /// <summary>SC_LINE_END_TYPE_UNICODE = 1
  );

  TDSciRepresentationAppearance = (
    scra_PLAIN,                             /// <summary>SC_REPRESENTATION_PLAIN = 0
    scra_BLOB,                              /// <summary>SC_REPRESENTATION_BLOB = 1
    scra_COLOUR                             /// <summary>SC_REPRESENTATION_COLOUR = $10
  );

  TDSciEOLAnnotationVisible = (
    sceolavHIDDEN,                          /// <summary>EOLANNOTATION_HIDDEN = $0
    sceolavSTANDARD,                        /// <summary>EOLANNOTATION_STANDARD = $1
    sceolavBOXED,                           /// <summary>EOLANNOTATION_BOXED = $2
    sceolavSTADIUM,                         /// <summary>EOLANNOTATION_STADIUM = $100
    sceolavFLAT_CIRCLE,                     /// <summary>EOLANNOTATION_FLAT_CIRCLE = $101
    sceolavANGLE_CIRCLE,                    /// <summary>EOLANNOTATION_ANGLE_CIRCLE = $102
    sceolavCIRCLE_FLAT,                     /// <summary>EOLANNOTATION_CIRCLE_FLAT = $110
    sceolavFLATS,                           /// <summary>EOLANNOTATION_FLATS = $111
    sceolavANGLE_FLAT,                      /// <summary>EOLANNOTATION_ANGLE_FLAT = $112
    sceolavCIRCLE_ANGLE,                    /// <summary>EOLANNOTATION_CIRCLE_ANGLE = $120
    sceolavFLAT_ANGLE,                      /// <summary>EOLANNOTATION_FLAT_ANGLE = $121
    sceolavANGLES                           /// <summary>EOLANNOTATION_ANGLES = $122
  );

  TDSciSupports = (
    scsLINE_DRAWS_FINAL,                    /// <summary>SC_SUPPORTS_LINE_DRAWS_FINAL = 0
    scsPIXEL_DIVISIONS,                     /// <summary>SC_SUPPORTS_PIXEL_DIVISIONS = 1
    scsFRACTIONAL_STROKE_WIDTH,             /// <summary>SC_SUPPORTS_FRACTIONAL_STROKE_WIDTH = 2
    scsTRANSLUCENT_STROKE,                  /// <summary>SC_SUPPORTS_TRANSLUCENT_STROKE = 3
    scsPIXEL_MODIFICATION,                  /// <summary>SC_SUPPORTS_PIXEL_MODIFICATION = 4
    scsTHREAD_SAFE_MEASURE_WIDTHS           /// <summary>SC_SUPPORTS_THREAD_SAFE_MEASURE_WIDTHS = 5
  );

  TDSciLineCharacterIndexType = (
    sclcitNONE,                             /// <summary>SC_LINECHARACTERINDEX_NONE = 0
    sclcitUTF32,                            /// <summary>SC_LINECHARACTERINDEX_UTF32 = 1
    sclcitUTF16                             /// <summary>SC_LINECHARACTERINDEX_UTF16 = 2
  );

  TDSciTypeProperty = (
    sctpBOOLEAN,                            /// <summary>SC_TYPE_BOOLEAN = 0
    sctpINTEGER,                            /// <summary>SC_TYPE_INTEGER = 1
    sctpSTRING                              /// <summary>SC_TYPE_STRING = 2
  );

  TDSciModificationFlags = (
    scmfINSERT_TEXT,                        /// <summary>SC_MOD_INSERTTEXT = $1
    scmfDELETE_TEXT,                        /// <summary>SC_MOD_DELETETEXT = $2
    scmfCHANGE_STYLE,                       /// <summary>SC_MOD_CHANGESTYLE = $4
    scmfCHANGE_FOLD,                        /// <summary>SC_MOD_CHANGEFOLD = $8
    scmfUSER,                               /// <summary>SC_PERFORMED_USER = $10
    scmfUNDO,                               /// <summary>SC_PERFORMED_UNDO = $20
    scmfREDO,                               /// <summary>SC_PERFORMED_REDO = $40
    scmfMULTI_STEP_UNDO_REDO,               /// <summary>SC_MULTISTEPUNDOREDO = $80
    scmfLAST_STEP_IN_UNDO_REDO,             /// <summary>SC_LASTSTEPINUNDOREDO = $100
    scmfCHANGE_MARKER,                      /// <summary>SC_MOD_CHANGEMARKER = $200
    scmfBEFORE_INSERT,                      /// <summary>SC_MOD_BEFOREINSERT = $400
    scmfBEFORE_DELETE,                      /// <summary>SC_MOD_BEFOREDELETE = $800
    scmfMULTILINE_UNDO_REDO,                /// <summary>SC_MULTILINEUNDOREDO = $1000
    scmfSTART_ACTION,                       /// <summary>SC_STARTACTION = $2000
    scmfCHANGE_INDICATOR,                   /// <summary>SC_MOD_CHANGEINDICATOR = $4000
    scmfCHANGE_LINE_STATE,                  /// <summary>SC_MOD_CHANGELINESTATE = $8000
    scmfCHANGE_MARGIN,                      /// <summary>SC_MOD_CHANGEMARGIN = $10000
    scmfCHANGE_ANNOTATION,                  /// <summary>SC_MOD_CHANGEANNOTATION = $20000
    scmfCONTAINER,                          /// <summary>SC_MOD_CONTAINER = $40000
    scmfLEXER_STATE,                        /// <summary>SC_MOD_LEXERSTATE = $80000
    scmfINSERT_CHECK,                       /// <summary>SC_MOD_INSERTCHECK = $100000
    scmfCHANGE_TAB_STOPS,                   /// <summary>SC_MOD_CHANGETABSTOPS = $200000
    scmfCHANGE_E_O_L_ANNOTATION,            /// <summary>SC_MOD_CHANGEEOLANNOTATION = $400000
    scmfEVENT_MASK_ALL                      /// <summary>SC_MODEVENTMASKALL = $7FFFFF
  );
  TDSciModificationFlagsSet = set of TDSciModificationFlags;

  TDSciUpdate = (
    scuNONE,                                /// <summary>SC_UPDATE_NONE = $0
    scuCONTENT,                             /// <summary>SC_UPDATE_CONTENT = $1
    scuSELECTION,                           /// <summary>SC_UPDATE_SELECTION = $2
    scuV_SCROLL,                            /// <summary>SC_UPDATE_V_SCROLL = $4
    scuH_SCROLL                             /// <summary>SC_UPDATE_H_SCROLL = $8
  );

  TDSciFocusChange = (
    scfcCHANGE,                             /// <summary>SCEN_CHANGE = 768
    scfcSETFOCUS,                           /// <summary>SCEN_SETFOCUS = 512
    scfcKILLFOCUS                           /// <summary>SCEN_KILLFOCUS = 256
  );

  TDSciKeys = (
    sckDOWN,                                /// <summary>SCK_DOWN = 300
    sckUP,                                  /// <summary>SCK_UP = 301
    sckLEFT,                                /// <summary>SCK_LEFT = 302
    sckRIGHT,                               /// <summary>SCK_RIGHT = 303
    sckHOME,                                /// <summary>SCK_HOME = 304
    sckEND,                                 /// <summary>SCK_END = 305
    sckPRIOR,                               /// <summary>SCK_PRIOR = 306
    sckNEXT,                                /// <summary>SCK_NEXT = 307
    sckDELETE,                              /// <summary>SCK_DELETE = 308
    sckINSERT,                              /// <summary>SCK_INSERT = 309
    sckESCAPE,                              /// <summary>SCK_ESCAPE = 7
    sckBACK,                                /// <summary>SCK_BACK = 8
    sckTAB,                                 /// <summary>SCK_TAB = 9
    sckRETURN,                              /// <summary>SCK_RETURN = 13
    sckADD,                                 /// <summary>SCK_ADD = 310
    sckSUBTRACT,                            /// <summary>SCK_SUBTRACT = 311
    sckDIVIDE,                              /// <summary>SCK_DIVIDE = 312
    sckWIN,                                 /// <summary>SCK_WIN = 313
    sckR_WIN,                               /// <summary>SCK_RWIN = 314
    sckMENU                                 /// <summary>SCK_MENU = 315
  );

  TDSciKeyMod = (
    sckmSHIFT,                              /// <summary>SCMOD_SHIFT = 1
    sckmCTRL,                               /// <summary>SCMOD_CTRL = 2
    sckmALT,                                /// <summary>SCMOD_ALT = 4
    sckmSUPER,                              /// <summary>SCMOD_SUPER = 8
    sckmMETA                                /// <summary>SCMOD_META = 16
  );
  TDSciKeyModSet = set of TDSciKeyMod;

  TDSciCompletionMethods = (
    sccmFILL_UP,                            /// <summary>SC_AC_FILLUP = 1
    sccmDOUBLE_CLICK,                       /// <summary>SC_AC_DOUBLECLICK = 2
    sccmTAB,                                /// <summary>SC_AC_TAB = 3
    sccmNEWLINE,                            /// <summary>SC_AC_NEWLINE = 4
    sccmCOMMAND,                            /// <summary>SC_AC_COMMAND = 5
    sccmSINGLE_CHOICE                       /// <summary>SC_AC_SINGLE_CHOICE = 6
  );

  TDSciCharacterSource = (
    sccsDIRECT_INPUT,                       /// <summary>SC_CHARACTERSOURCE_DIRECT_INPUT = 0
    sccsTENTATIVE_INPUT,                    /// <summary>SC_CHARACTERSOURCE_TENTATIVE_INPUT = 1
    sccsIME_RESULT                          /// <summary>SC_CHARACTERSOURCE_IME_RESULT = 2
  );

  TDSciBidirectional = (
    scbDISABLED,                            /// <summary>SC_BIDIRECTIONAL_DISABLED = 0
    scbL2R,                                 /// <summary>SC_BIDIRECTIONAL_L2R = 1
    scbR2L                                  /// <summary>SC_BIDIRECTIONAL_R2L = 2
  );

  TDSciLexerId = (
    sclCONTAINER,                           /// <summary>SCLEX_CONTAINER = 0
    sclNULL,                                /// <summary>SCLEX_NULL = 1
    sclPYTHON,                              /// <summary>SCLEX_PYTHON = 2
    sclCPP,                                 /// <summary>SCLEX_CPP = 3
    sclHTML,                                /// <summary>SCLEX_HTML = 4
    sclXML,                                 /// <summary>SCLEX_XML = 5
    sclPERL,                                /// <summary>SCLEX_PERL = 6
    sclSQL,                                 /// <summary>SCLEX_SQL = 7
    sclVB,                                  /// <summary>SCLEX_VB = 8
    sclPROPERTIES,                          /// <summary>SCLEX_PROPERTIES = 9
    sclERRORLIST,                           /// <summary>SCLEX_ERRORLIST = 10
    sclMAKEFILE,                            /// <summary>SCLEX_MAKEFILE = 11
    sclBATCH,                               /// <summary>SCLEX_BATCH = 12
    sclXCODE,                               /// <summary>SCLEX_XCODE = 13
    sclLATEX,                               /// <summary>SCLEX_LATEX = 14
    sclLUA,                                 /// <summary>SCLEX_LUA = 15
    sclDIFF,                                /// <summary>SCLEX_DIFF = 16
    sclCONF,                                /// <summary>SCLEX_CONF = 17
    sclPASCAL,                              /// <summary>SCLEX_PASCAL = 18
    sclAVE,                                 /// <summary>SCLEX_AVE = 19
    sclADA,                                 /// <summary>SCLEX_ADA = 20
    sclLISP,                                /// <summary>SCLEX_LISP = 21
    sclRUBY,                                /// <summary>SCLEX_RUBY = 22
    sclEIFFEL,                              /// <summary>SCLEX_EIFFEL = 23
    sclEIFFELKW,                            /// <summary>SCLEX_EIFFELKW = 24
    sclTCL,                                 /// <summary>SCLEX_TCL = 25
    sclNNCRONTAB,                           /// <summary>SCLEX_NNCRONTAB = 26
    sclBULLANT,                             /// <summary>SCLEX_BULLANT = 27
    sclVBSCRIPT,                            /// <summary>SCLEX_VBSCRIPT = 28
    sclBAAN,                                /// <summary>SCLEX_BAAN = 31
    sclMATLAB,                              /// <summary>SCLEX_MATLAB = 32
    sclSCRIPTOL,                            /// <summary>SCLEX_SCRIPTOL = 33
    sclASM,                                 /// <summary>SCLEX_ASM = 34
    sclCPPNOCASE,                           /// <summary>SCLEX_CPPNOCASE = 35
    sclFORTRAN,                             /// <summary>SCLEX_FORTRAN = 36
    sclF77,                                 /// <summary>SCLEX_F77 = 37
    sclCSS,                                 /// <summary>SCLEX_CSS = 38
    sclPOV,                                 /// <summary>SCLEX_POV = 39
    sclLOUT,                                /// <summary>SCLEX_LOUT = 40
    sclESCRIPT,                             /// <summary>SCLEX_ESCRIPT = 41
    sclPS,                                  /// <summary>SCLEX_PS = 42
    sclNSIS,                                /// <summary>SCLEX_NSIS = 43
    sclMMIXAL,                              /// <summary>SCLEX_MMIXAL = 44
    sclCLW,                                 /// <summary>SCLEX_CLW = 45
    sclCLWNOCASE,                           /// <summary>SCLEX_CLWNOCASE = 46
    sclLOT,                                 /// <summary>SCLEX_LOT = 47
    sclYAML,                                /// <summary>SCLEX_YAML = 48
    sclTEX,                                 /// <summary>SCLEX_TEX = 49
    sclMETAPOST,                            /// <summary>SCLEX_METAPOST = 50
    sclPOWERBASIC,                          /// <summary>SCLEX_POWERBASIC = 51
    sclFORTH,                               /// <summary>SCLEX_FORTH = 52
    sclERLANG,                              /// <summary>SCLEX_ERLANG = 53
    sclOCTAVE,                              /// <summary>SCLEX_OCTAVE = 54
    sclMSSQL,                               /// <summary>SCLEX_MSSQL = 55
    sclVERILOG,                             /// <summary>SCLEX_VERILOG = 56
    sclKIX,                                 /// <summary>SCLEX_KIX = 57
    sclGUI4CLI,                             /// <summary>SCLEX_GUI4CLI = 58
    sclSPECMAN,                             /// <summary>SCLEX_SPECMAN = 59
    sclAU3,                                 /// <summary>SCLEX_AU3 = 60
    sclAPDL,                                /// <summary>SCLEX_APDL = 61
    sclBASH,                                /// <summary>SCLEX_BASH = 62
    sclASN1,                                /// <summary>SCLEX_ASN1 = 63
    sclVHDL,                                /// <summary>SCLEX_VHDL = 64
    sclCAML,                                /// <summary>SCLEX_CAML = 65
    sclBLITZBASIC,                          /// <summary>SCLEX_BLITZBASIC = 66
    sclPUREBASIC,                           /// <summary>SCLEX_PUREBASIC = 67
    sclHASKELL,                             /// <summary>SCLEX_HASKELL = 68
    sclPHPSCRIPT,                           /// <summary>SCLEX_PHPSCRIPT = 69
    sclTADS3,                               /// <summary>SCLEX_TADS3 = 70
    sclREBOL,                               /// <summary>SCLEX_REBOL = 71
    sclSMALLTALK,                           /// <summary>SCLEX_SMALLTALK = 72
    sclFLAGSHIP,                            /// <summary>SCLEX_FLAGSHIP = 73
    sclCSOUND,                              /// <summary>SCLEX_CSOUND = 74
    sclFREEBASIC,                           /// <summary>SCLEX_FREEBASIC = 75
    sclINNOSETUP,                           /// <summary>SCLEX_INNOSETUP = 76
    sclOPAL,                                /// <summary>SCLEX_OPAL = 77
    sclSPICE,                               /// <summary>SCLEX_SPICE = 78
    sclD,                                   /// <summary>SCLEX_D = 79
    sclCMAKE,                               /// <summary>SCLEX_CMAKE = 80
    sclGAP,                                 /// <summary>SCLEX_GAP = 81
    sclPLM,                                 /// <summary>SCLEX_PLM = 82
    sclPROGRESS,                            /// <summary>SCLEX_PROGRESS = 83
    sclABAQUS,                              /// <summary>SCLEX_ABAQUS = 84
    sclASYMPTOTE,                           /// <summary>SCLEX_ASYMPTOTE = 85
    sclR,                                   /// <summary>SCLEX_R = 86
    sclMAGIK,                               /// <summary>SCLEX_MAGIK = 87
    sclPOWERSHELL,                          /// <summary>SCLEX_POWERSHELL = 88
    sclMYSQL,                               /// <summary>SCLEX_MYSQL = 89
    sclPO,                                  /// <summary>SCLEX_PO = 90
    sclTAL,                                 /// <summary>SCLEX_TAL = 91
    sclCOBOL,                               /// <summary>SCLEX_COBOL = 92
    sclTACL,                                /// <summary>SCLEX_TACL = 93
    sclSORCUS,                              /// <summary>SCLEX_SORCUS = 94
    sclPOWERPRO,                            /// <summary>SCLEX_POWERPRO = 95
    sclNIMROD,                              /// <summary>SCLEX_NIMROD = 96
    sclSML,                                 /// <summary>SCLEX_SML = 97
    sclMARKDOWN,                            /// <summary>SCLEX_MARKDOWN = 98
    sclTXT2TAGS,                            /// <summary>SCLEX_TXT2TAGS = 99
    sclA68K,                                /// <summary>SCLEX_A68K = 100
    sclMODULA,                              /// <summary>SCLEX_MODULA = 101
    sclCOFFEESCRIPT,                        /// <summary>SCLEX_COFFEESCRIPT = 102
    sclTCMD,                                /// <summary>SCLEX_TCMD = 103
    sclAVS,                                 /// <summary>SCLEX_AVS = 104
    sclECL,                                 /// <summary>SCLEX_ECL = 105
    sclOSCRIPT,                             /// <summary>SCLEX_OSCRIPT = 106
    sclVISUALPROLOG,                        /// <summary>SCLEX_VISUALPROLOG = 107
    sclLITERATEHASKELL,                     /// <summary>SCLEX_LITERATEHASKELL = 108
    sclSTTXT,                               /// <summary>SCLEX_STTXT = 109
    sclKVIRC,                               /// <summary>SCLEX_KVIRC = 110
    sclRUST,                                /// <summary>SCLEX_RUST = 111
    sclDMAP,                                /// <summary>SCLEX_DMAP = 112
    sclAS,                                  /// <summary>SCLEX_AS = 113
    sclDMIS,                                /// <summary>SCLEX_DMIS = 114
    sclREGISTRY,                            /// <summary>SCLEX_REGISTRY = 115
    sclBIBTEX,                              /// <summary>SCLEX_BIBTEX = 116
    sclSREC,                                /// <summary>SCLEX_SREC = 117
    sclIHEX,                                /// <summary>SCLEX_IHEX = 118
    sclTEHEX,                               /// <summary>SCLEX_TEHEX = 119
    sclJSON,                                /// <summary>SCLEX_JSON = 120
    sclEDIFACT,                             /// <summary>SCLEX_EDIFACT = 121
    sclINDENT,                              /// <summary>SCLEX_INDENT = 122
    sclMAXIMA,                              /// <summary>SCLEX_MAXIMA = 123
    sclSTATA,                               /// <summary>SCLEX_STATA = 124
    sclSAS,                                 /// <summary>SCLEX_SAS = 125
    sclNIM,                                 /// <summary>SCLEX_NIM = 126
    sclCIL,                                 /// <summary>SCLEX_CIL = 127
    sclX12,                                 /// <summary>SCLEX_X12 = 128
    sclDATAFLEX,                            /// <summary>SCLEX_DATAFLEX = 129
    sclHOLLYWOOD,                           /// <summary>SCLEX_HOLLYWOOD = 130
    sclRAKU,                                /// <summary>SCLEX_RAKU = 131
    sclFSHARP,                              /// <summary>SCLEX_FSHARP = 132
    sclJULIA,                               /// <summary>SCLEX_JULIA = 133
    sclASCIIDOC,                            /// <summary>SCLEX_ASCIIDOC = 134
    sclGDSCRIPT,                            /// <summary>SCLEX_GDSCRIPT = 135
    sclTOML,                                /// <summary>SCLEX_TOML = 136
    sclTROFF,                               /// <summary>SCLEX_TROFF = 137
    sclDART,                                /// <summary>SCLEX_DART = 138
    sclZIG,                                 /// <summary>SCLEX_ZIG = 139
    sclNIX,                                 /// <summary>SCLEX_NIX = 140
    sclSINEX,                               /// <summary>SCLEX_SINEX = 141
    sclESCSEQ,                              /// <summary>SCLEX_ESCSEQ = 142
    sclAUTOMATIC                            /// <summary>SCLEX_AUTOMATIC = 1000
  );


// </scigen-types>

const

{ Scintilla event codes }

  SCN_STYLENEEDED           = 2000;
  SCN_CHARADDED             = 2001;
  SCN_SAVEPOINTREACHED      = 2002;
  SCN_SAVEPOINTLEFT         = 2003;
  SCN_MODIFYATTEMPTRO       = 2004;
  //# GTK+ Specific to work around focus and accelerator problems:
  //evt void Key           =2005(int ch, int modifiers)
  //evt void DoubleClick   =2006(void)
  SCN_UPDATEUI              = 2007;
  SCN_MODIFIED              = 2008;
  SCN_MACRORECORD           = 2009;
  SCN_MARGINCLICK           = 2010;
  SCN_NEEDSHOWN             = 2011;
  SCN_PAINTED               = 2013;
  SCN_USERLISTSELECTION     = 2014;
  // Only on the GTK+ version
  // SCN_URIDROPPED         = 2015;
  SCN_DWELLSTART            = 2016;
  SCN_DWELLEND              = 2017;
  SCN_ZOOM                  = 2018;
  SCN_HOTSPOTCLICK          = 2019;
  SCN_HOTSPOTDOUBLECLICK    = 2020;
  SCN_CALLTIPCLICK          = 2021;
  SCN_AUTOCSELECTION        = 2022;
  SCN_INDICATORCLICK        = 2023;
  SCN_INDICATORRELEASE      = 2024;
  SCN_AUTOCCANCELLED        = 2025;
  SCN_AUTOCCHARDELETED      = 2026;
  SCN_HOTSPOTRELEASECLICK   = 2027;
  SCN_FOCUSIN               = 2028;
  SCN_FOCUSOUT              = 2029;
  SCN_AUTOCCOMPLETED        = 2030;
  SCN_MARGINRIGHTCLICK      = 2031;
  SCN_AUTOCSELECTIONCHANGE  = 2032;

const

{ Scintilla consts and method codes }

// <scigen>

  INVALID_POSITION = -1;

  /// <summary>Define start of Scintilla messages to be greater than all Windows edit (EM_*) messages
  /// as many EM_ messages can be used although that use is deprecated.</summary>
  SCI_START = 2000;
  SCI_OPTIONAL_START = 3000;
  SCI_LEXER_START = 4000;

  /// <summary>Add text to the document at current position.</summary>
  SCI_ADDTEXT = 2001;

  /// <summary>Add array of cells to document.</summary>
  SCI_ADDSTYLEDTEXT = 2002;

  /// <summary>Insert string at a position.</summary>
  SCI_INSERTTEXT = 2003;

  /// <summary>Change the text that is being inserted in response to SC_MOD_INSERTCHECK</summary>
  SCI_CHANGEINSERTION = 2672;

  /// <summary>Delete all text in the document.</summary>
  SCI_CLEARALL = 2004;

  /// <summary>Delete a range of text in the document.</summary>
  SCI_DELETERANGE = 2645;

  /// <summary>Set all style bytes to 0, remove all folding information.</summary>
  SCI_CLEARDOCUMENTSTYLE = 2005;

  /// <summary>Returns the number of bytes in the document.</summary>
  SCI_GETLENGTH = 2006;

  /// <summary>Returns the character byte at the position.</summary>
  SCI_GETCHARAT = 2007;

  /// <summary>Returns the position of the caret.</summary>
  SCI_GETCURRENTPOS = 2008;

  /// <summary>Returns the position of the opposite end of the selection to the caret.</summary>
  SCI_GETANCHOR = 2009;

  /// <summary>Returns the style byte at the position.</summary>
  SCI_GETSTYLEAT = 2010;

  /// <summary>Returns the unsigned style byte at the position.</summary>
  SCI_GETSTYLEINDEXAT = 2038;

  /// <summary>Redoes the next action on the undo history.</summary>
  SCI_REDO = 2011;

  /// <summary>Choose between collecting actions into the undo
  /// history and discarding them.</summary>
  SCI_SETUNDOCOLLECTION = 2012;

  /// <summary>Select all the text in the document.</summary>
  SCI_SELECTALL = 2013;

  /// <summary>Remember the current position in the undo history as the position
  /// at which the document was saved.</summary>
  SCI_SETSAVEPOINT = 2014;

  /// <summary>Retrieve a buffer of cells.
  /// Returns the number of bytes in the buffer not including terminating NULs.</summary>
  SCI_GETSTYLEDTEXT = 2015;

  /// <summary>Retrieve a buffer of cells that can be past 2GB.
  /// Returns the number of bytes in the buffer not including terminating NULs.</summary>
  SCI_GETSTYLEDTEXTFULL = 2778;

  /// <summary>Are there any redoable actions in the undo history?</summary>
  SCI_CANREDO = 2016;

  /// <summary>Retrieve the line number at which a particular marker is located.</summary>
  SCI_MARKERLINEFROMHANDLE = 2017;

  /// <summary>Delete a marker.</summary>
  SCI_MARKERDELETEHANDLE = 2018;

  /// <summary>Retrieve marker handles of a line</summary>
  SCI_MARKERHANDLEFROMLINE = 2732;

  /// <summary>Retrieve marker number of a marker handle</summary>
  SCI_MARKERNUMBERFROMLINE = 2733;

  /// <summary>Is undo history being collected?</summary>
  SCI_GETUNDOCOLLECTION = 2019;

  SCWS_INVISIBLE = 0;
  SCWS_VISIBLEALWAYS = 1;
  SCWS_VISIBLEAFTERINDENT = 2;
  SCWS_VISIBLEONLYININDENT = 3;

  /// <summary>Are white space characters currently visible?
  /// Returns one of SCWS_* constants.</summary>
  SCI_GETVIEWWS = 2020;

  /// <summary>Make white space characters invisible, always visible or visible outside indentation.</summary>
  SCI_SETVIEWWS = 2021;

  SCTD_LONGARROW = 0;
  SCTD_STRIKEOUT = 1;
  SCTD_CONTROLCHAR = 2;

  /// <summary>Retrieve the current tab draw mode.
  /// Returns one of SCTD_* constants.</summary>
  SCI_GETTABDRAWMODE = 2698;

  /// <summary>Set how tabs are drawn when visible.</summary>
  SCI_SETTABDRAWMODE = 2699;

  /// <summary>Find the position from a point within the window.</summary>
  SCI_POSITIONFROMPOINT = 2022;

  /// <summary>Find the position from a point within the window but return
  /// INVALID_POSITION if not close to text.</summary>
  SCI_POSITIONFROMPOINTCLOSE = 2023;

  /// <summary>Set caret to start of a line and ensure it is visible.</summary>
  SCI_GOTOLINE = 2024;

  /// <summary>Set caret to a position and ensure it is visible.</summary>
  SCI_GOTOPOS = 2025;

  /// <summary>Set the selection anchor to a position. The anchor is the opposite
  /// end of the selection from the caret.</summary>
  SCI_SETANCHOR = 2026;

  /// <summary>Retrieve the text of the line containing the caret.
  /// Returns the index of the caret on the line.
  /// Result is NUL-terminated.</summary>
  SCI_GETCURLINE = 2027;

  /// <summary>Retrieve the position of the last correctly styled character.</summary>
  SCI_GETENDSTYLED = 2028;

  SC_EOL_CRLF = 0;
  SC_EOL_CR = 1;
  SC_EOL_LF = 2;

  /// <summary>Convert all line endings in the document to one mode.</summary>
  SCI_CONVERTEOLS = 2029;

  /// <summary>Retrieve the current end of line mode - one of CRLF, CR, or LF.</summary>
  SCI_GETEOLMODE = 2030;

  /// <summary>Set the current end of line mode.</summary>
  SCI_SETEOLMODE = 2031;

  /// <summary>Set the current styling position to start.
  /// The unused parameter is no longer used and should be set to 0.</summary>
  SCI_STARTSTYLING = 2032;

  /// <summary>Change style from current styling position for length characters to a style
  /// and move the current styling position to after this newly styled segment.</summary>
  SCI_SETSTYLING = 2033;

  /// <summary>Is drawing done first into a buffer or direct to the screen?</summary>
  SCI_GETBUFFEREDDRAW = 2034;

  /// <summary>If drawing is buffered then each line of text is drawn into a bitmap buffer
  /// before drawing it to the screen to avoid flicker.</summary>
  SCI_SETBUFFEREDDRAW = 2035;

  /// <summary>Change the visible size of a tab to be a multiple of the width of a space character.</summary>
  SCI_SETTABWIDTH = 2036;

  /// <summary>Retrieve the visible size of a tab.</summary>
  SCI_GETTABWIDTH = 2121;

  /// <summary>Set the minimum visual width of a tab.</summary>
  SCI_SETTABMINIMUMWIDTH = 2724;

  /// <summary>Get the minimum visual width of a tab.</summary>
  SCI_GETTABMINIMUMWIDTH = 2725;

  /// <summary>Clear explicit tabstops on a line.</summary>
  SCI_CLEARTABSTOPS = 2675;

  /// <summary>Add an explicit tab stop for a line.</summary>
  SCI_ADDTABSTOP = 2676;

  /// <summary>Find the next explicit tab stop position on a line after a position.</summary>
  SCI_GETNEXTTABSTOP = 2677;

  /// <summary>The SC_CP_UTF8 value can be used to enter Unicode mode.
  /// This is the same value as CP_UTF8 in Windows</summary>
  SC_CP_UTF8 = 65001;

  /// <summary>Set the code page used to interpret the bytes of the document as characters.
  /// The SC_CP_UTF8 value can be used to enter Unicode mode.</summary>
  SCI_SETCODEPAGE = 2037;

  /// <summary>Set the locale for displaying text.</summary>
  SCI_SETFONTLOCALE = 2760;

  /// <summary>Get the locale for displaying text.</summary>
  SCI_GETFONTLOCALE = 2761;

  SC_IME_WINDOWED = 0;
  SC_IME_INLINE = 1;

  /// <summary>Is the IME displayed in a window or inline?</summary>
  SCI_GETIMEINTERACTION = 2678;

  /// <summary>Choose to display the IME in a window or inline.</summary>
  SCI_SETIMEINTERACTION = 2679;

  SC_ALPHA_TRANSPARENT = 0;
  SC_ALPHA_OPAQUE = 255;
  SC_ALPHA_NOALPHA = 256;

  SC_CURSORNORMAL = -1;
  SC_CURSORARROW = 2;
  SC_CURSORWAIT = 4;
  SC_CURSORREVERSEARROW = 7;

  MARKER_MAX = 31;
  SC_MARK_CIRCLE = 0;
  SC_MARK_ROUNDRECT = 1;
  SC_MARK_ARROW = 2;
  SC_MARK_SMALLRECT = 3;
  SC_MARK_SHORTARROW = 4;
  SC_MARK_EMPTY = 5;
  SC_MARK_ARROWDOWN = 6;
  SC_MARK_MINUS = 7;
  SC_MARK_PLUS = 8;

  /// <summary>Shapes used for outlining column.</summary>
  SC_MARK_VLINE = 9;
  SC_MARK_LCORNER = 10;
  SC_MARK_TCORNER = 11;
  SC_MARK_BOXPLUS = 12;
  SC_MARK_BOXPLUSCONNECTED = 13;
  SC_MARK_BOXMINUS = 14;
  SC_MARK_BOXMINUSCONNECTED = 15;
  SC_MARK_LCORNERCURVE = 16;
  SC_MARK_TCORNERCURVE = 17;
  SC_MARK_CIRCLEPLUS = 18;
  SC_MARK_CIRCLEPLUSCONNECTED = 19;
  SC_MARK_CIRCLEMINUS = 20;
  SC_MARK_CIRCLEMINUSCONNECTED = 21;

  /// <summary>Invisible mark that only sets the line background colour.</summary>
  SC_MARK_BACKGROUND = 22;
  SC_MARK_DOTDOTDOT = 23;
  SC_MARK_ARROWS = 24;
  SC_MARK_PIXMAP = 25;
  SC_MARK_FULLRECT = 26;
  SC_MARK_LEFTRECT = 27;
  SC_MARK_AVAILABLE = 28;
  SC_MARK_UNDERLINE = 29;
  SC_MARK_RGBAIMAGE = 30;
  SC_MARK_BOOKMARK = 31;
  SC_MARK_VERTICALBOOKMARK = 32;
  SC_MARK_BAR = 33;

  SC_MARK_CHARACTER = 10000;

  /// <summary>Markers used for outlining and change history columns.</summary>
  SC_MARKNUM_HISTORY_REVERTED_TO_ORIGIN = 21;
  SC_MARKNUM_HISTORY_SAVED = 22;
  SC_MARKNUM_HISTORY_MODIFIED = 23;
  SC_MARKNUM_HISTORY_REVERTED_TO_MODIFIED = 24;
  SC_MARKNUM_FOLDEREND = 25;
  SC_MARKNUM_FOLDEROPENMID = 26;
  SC_MARKNUM_FOLDERMIDTAIL = 27;
  SC_MARKNUM_FOLDERTAIL = 28;
  SC_MARKNUM_FOLDERSUB = 29;
  SC_MARKNUM_FOLDER = 30;
  SC_MARKNUM_FOLDEROPEN = 31;

  SC_MASK_HISTORY = $01E00000;

  /// <summary>SC_MASK_FOLDERS doesn't go in an enumeration as larger than max 32-bit positive integer</summary>
  SC_MASK_FOLDERS = $FE000000;

  /// <summary>Set the symbol used for a particular marker number.</summary>
  SCI_MARKERDEFINE = 2040;

  /// <summary>Set the foreground colour used for a particular marker number.</summary>
  SCI_MARKERSETFORE = 2041;

  /// <summary>Set the background colour used for a particular marker number.</summary>
  SCI_MARKERSETBACK = 2042;

  /// <summary>Set the background colour used for a particular marker number when its folding block is selected.</summary>
  SCI_MARKERSETBACKSELECTED = 2292;

  /// <summary>Set the foreground colour used for a particular marker number.</summary>
  SCI_MARKERSETFORETRANSLUCENT = 2294;

  /// <summary>Set the background colour used for a particular marker number.</summary>
  SCI_MARKERSETBACKTRANSLUCENT = 2295;

  /// <summary>Set the background colour used for a particular marker number when its folding block is selected.</summary>
  SCI_MARKERSETBACKSELECTEDTRANSLUCENT = 2296;

  /// <summary>Set the width of strokes used in .01 pixels so 50  = 1/2 pixel width.</summary>
  SCI_MARKERSETSTROKEWIDTH = 2297;

  /// <summary>Enable/disable highlight for current folding block (smallest one that contains the caret)</summary>
  SCI_MARKERENABLEHIGHLIGHT = 2293;

  /// <summary>Add a marker to a line, returning an ID which can be used to find or delete the marker.</summary>
  SCI_MARKERADD = 2043;

  /// <summary>Delete a marker from a line.</summary>
  SCI_MARKERDELETE = 2044;

  /// <summary>Delete all markers with a particular number from all lines.</summary>
  SCI_MARKERDELETEALL = 2045;

  /// <summary>Get a bit mask of all the markers set on a line.</summary>
  SCI_MARKERGET = 2046;

  /// <summary>Find the next line at or after lineStart that includes a marker in mask.
  /// Return -1 when no more lines.</summary>
  SCI_MARKERNEXT = 2047;

  /// <summary>Find the previous line before lineStart that includes a marker in mask.</summary>
  SCI_MARKERPREVIOUS = 2048;

  /// <summary>Define a marker from a pixmap.</summary>
  SCI_MARKERDEFINEPIXMAP = 2049;

  /// <summary>Add a set of markers to a line.</summary>
  SCI_MARKERADDSET = 2466;

  /// <summary>Set the alpha used for a marker that is drawn in the text area, not the margin.</summary>
  SCI_MARKERSETALPHA = 2476;

  /// <summary>Get the layer used for a marker that is drawn in the text area, not the margin.</summary>
  SCI_MARKERGETLAYER = 2734;

  /// <summary>Set the layer used for a marker that is drawn in the text area, not the margin.</summary>
  SCI_MARKERSETLAYER = 2735;

  SC_MAX_MARGIN = 4;

  SC_MARGIN_SYMBOL = 0;
  SC_MARGIN_NUMBER = 1;
  SC_MARGIN_BACK = 2;
  SC_MARGIN_FORE = 3;
  SC_MARGIN_TEXT = 4;
  SC_MARGIN_RTEXT = 5;
  SC_MARGIN_COLOUR = 6;

  /// <summary>Set a margin to be either numeric or symbolic.</summary>
  SCI_SETMARGINTYPEN = 2240;

  /// <summary>Retrieve the type of a margin.</summary>
  SCI_GETMARGINTYPEN = 2241;

  /// <summary>Set the width of a margin to a width expressed in pixels.</summary>
  SCI_SETMARGINWIDTHN = 2242;

  /// <summary>Retrieve the width of a margin in pixels.</summary>
  SCI_GETMARGINWIDTHN = 2243;

  /// <summary>Set a mask that determines which markers are displayed in a margin.</summary>
  SCI_SETMARGINMASKN = 2244;

  /// <summary>Retrieve the marker mask of a margin.</summary>
  SCI_GETMARGINMASKN = 2245;

  /// <summary>Make a margin sensitive or insensitive to mouse clicks.</summary>
  SCI_SETMARGINSENSITIVEN = 2246;

  /// <summary>Retrieve the mouse click sensitivity of a margin.</summary>
  SCI_GETMARGINSENSITIVEN = 2247;

  /// <summary>Set the cursor shown when the mouse is inside a margin.</summary>
  SCI_SETMARGINCURSORN = 2248;

  /// <summary>Retrieve the cursor shown in a margin.</summary>
  SCI_GETMARGINCURSORN = 2249;

  /// <summary>Set the background colour of a margin. Only visible for SC_MARGIN_COLOUR.</summary>
  SCI_SETMARGINBACKN = 2250;

  /// <summary>Retrieve the background colour of a margin</summary>
  SCI_GETMARGINBACKN = 2251;

  /// <summary>Allocate a non-standard number of margins.</summary>
  SCI_SETMARGINS = 2252;

  /// <summary>How many margins are there?.</summary>
  SCI_GETMARGINS = 2253;

  /// <summary>Styles in range 32..39 are predefined for parts of the UI and are not used as normal styles.</summary>
  STYLE_DEFAULT = 32;
  STYLE_LINENUMBER = 33;
  STYLE_BRACELIGHT = 34;
  STYLE_BRACEBAD = 35;
  STYLE_CONTROLCHAR = 36;
  STYLE_INDENTGUIDE = 37;
  STYLE_CALLTIP = 38;
  STYLE_FOLDDISPLAYTEXT = 39;
  STYLE_LASTPREDEFINED = 39;
  STYLE_MAX = 255;

  /// <summary>Character set identifiers are used in StyleSetCharacterSet.
  /// The values are the same as the Windows *_CHARSET values.</summary>
  SC_CHARSET_ANSI = 0;
  SC_CHARSET_DEFAULT = 1;
  SC_CHARSET_BALTIC = 186;
  SC_CHARSET_CHINESEBIG5 = 136;
  SC_CHARSET_EASTEUROPE = 238;
  SC_CHARSET_GB2312 = 134;
  SC_CHARSET_GREEK = 161;
  SC_CHARSET_HANGUL = 129;
  SC_CHARSET_MAC = 77;
  SC_CHARSET_OEM = 255;
  SC_CHARSET_RUSSIAN = 204;
  SC_CHARSET_OEM866 = 866;
  SC_CHARSET_CYRILLIC = 1251;
  SC_CHARSET_SHIFTJIS = 128;
  SC_CHARSET_SYMBOL = 2;
  SC_CHARSET_TURKISH = 162;
  SC_CHARSET_JOHAB = 130;
  SC_CHARSET_HEBREW = 177;
  SC_CHARSET_ARABIC = 178;
  SC_CHARSET_VIETNAMESE = 163;
  SC_CHARSET_THAI = 222;
  SC_CHARSET_8859_15 = 1000;

  /// <summary>Clear all the styles and make equivalent to the global default style.</summary>
  SCI_STYLECLEARALL = 2050;

  /// <summary>Set the foreground colour of a style.</summary>
  SCI_STYLESETFORE = 2051;

  /// <summary>Set the background colour of a style.</summary>
  SCI_STYLESETBACK = 2052;

  /// <summary>Set a style to be bold or not.</summary>
  SCI_STYLESETBOLD = 2053;

  /// <summary>Set a style to be italic or not.</summary>
  SCI_STYLESETITALIC = 2054;

  /// <summary>Set the size of characters of a style.</summary>
  SCI_STYLESETSIZE = 2055;

  /// <summary>Set the font of a style.</summary>
  SCI_STYLESETFONT = 2056;

  /// <summary>Set a style to have its end of line filled or not.</summary>
  SCI_STYLESETEOLFILLED = 2057;

  /// <summary>Reset the default style to its state at startup</summary>
  SCI_STYLERESETDEFAULT = 2058;

  /// <summary>Set a style to be underlined or not.</summary>
  SCI_STYLESETUNDERLINE = 2059;

  SC_CASE_MIXED = 0;
  SC_CASE_UPPER = 1;
  SC_CASE_LOWER = 2;
  SC_CASE_CAMEL = 3;

  /// <summary>Get the foreground colour of a style.</summary>
  SCI_STYLEGETFORE = 2481;

  /// <summary>Get the background colour of a style.</summary>
  SCI_STYLEGETBACK = 2482;

  /// <summary>Get is a style bold or not.</summary>
  SCI_STYLEGETBOLD = 2483;

  /// <summary>Get is a style italic or not.</summary>
  SCI_STYLEGETITALIC = 2484;

  /// <summary>Get the size of characters of a style.</summary>
  SCI_STYLEGETSIZE = 2485;

  /// <summary>Get the font of a style.
  /// Returns the length of the fontName
  /// Result is NUL-terminated.</summary>
  SCI_STYLEGETFONT = 2486;

  /// <summary>Get is a style to have its end of line filled or not.</summary>
  SCI_STYLEGETEOLFILLED = 2487;

  /// <summary>Get is a style underlined or not.</summary>
  SCI_STYLEGETUNDERLINE = 2488;

  /// <summary>Get is a style mixed case, or to force upper or lower case.</summary>
  SCI_STYLEGETCASE = 2489;

  /// <summary>Get the character get of the font in a style.</summary>
  SCI_STYLEGETCHARACTERSET = 2490;

  /// <summary>Get is a style visible or not.</summary>
  SCI_STYLEGETVISIBLE = 2491;

  /// <summary>Get is a style changeable or not (read only).
  /// Experimental feature, currently buggy.</summary>
  SCI_STYLEGETCHANGEABLE = 2492;

  /// <summary>Get is a style a hotspot or not.</summary>
  SCI_STYLEGETHOTSPOT = 2493;

  /// <summary>Set a style to be mixed case, or to force upper or lower case.</summary>
  SCI_STYLESETCASE = 2060;

  SC_FONT_SIZE_MULTIPLIER = 100;

  /// <summary>Set the size of characters of a style. Size is in points multiplied by 100.</summary>
  SCI_STYLESETSIZEFRACTIONAL = 2061;

  /// <summary>Get the size of characters of a style in points multiplied by 100</summary>
  SCI_STYLEGETSIZEFRACTIONAL = 2062;

  SC_WEIGHT_NORMAL = 400;
  SC_WEIGHT_SEMIBOLD = 600;
  SC_WEIGHT_BOLD = 700;

  /// <summary>Set the weight of characters of a style.</summary>
  SCI_STYLESETWEIGHT = 2063;

  /// <summary>Get the weight of characters of a style.</summary>
  SCI_STYLEGETWEIGHT = 2064;

  /// <summary>Set the character set of the font in a style.</summary>
  SCI_STYLESETCHARACTERSET = 2066;

  /// <summary>Set a style to be a hotspot or not.</summary>
  SCI_STYLESETHOTSPOT = 2409;

  /// <summary>Indicate that a style may be monospaced over ASCII graphics characters which enables optimizations.</summary>
  SCI_STYLESETCHECKMONOSPACED = 2254;

  /// <summary>Get whether a style may be monospaced.</summary>
  SCI_STYLEGETCHECKMONOSPACED = 2255;

  SC_STRETCH_ULTRA_CONDENSED = 1;
  SC_STRETCH_EXTRA_CONDENSED = 2;
  SC_STRETCH_CONDENSED = 3;
  SC_STRETCH_SEMI_CONDENSED = 4;
  SC_STRETCH_NORMAL = 5;
  SC_STRETCH_SEMI_EXPANDED = 6;
  SC_STRETCH_EXPANDED = 7;
  SC_STRETCH_EXTRA_EXPANDED = 8;
  SC_STRETCH_ULTRA_EXPANDED = 9;

  /// <summary>Set the stretch of characters of a style.</summary>
  SCI_STYLESETSTRETCH = 2258;

  /// <summary>Get the stretch of characters of a style.</summary>
  SCI_STYLEGETSTRETCH = 2259;

  /// <summary>Set the invisible representation for a style.</summary>
  SCI_STYLESETINVISIBLEREPRESENTATION = 2256;

  /// <summary>Get the invisible representation for a style.</summary>
  SCI_STYLEGETINVISIBLEREPRESENTATION = 2257;

  SC_ELEMENT_LIST = 0;
  SC_ELEMENT_LIST_BACK = 1;
  SC_ELEMENT_LIST_SELECTED = 2;
  SC_ELEMENT_LIST_SELECTED_BACK = 3;
  SC_ELEMENT_SELECTION_TEXT = 10;
  SC_ELEMENT_SELECTION_BACK = 11;
  SC_ELEMENT_SELECTION_ADDITIONAL_TEXT = 12;
  SC_ELEMENT_SELECTION_ADDITIONAL_BACK = 13;
  SC_ELEMENT_SELECTION_SECONDARY_TEXT = 14;
  SC_ELEMENT_SELECTION_SECONDARY_BACK = 15;
  SC_ELEMENT_SELECTION_INACTIVE_TEXT = 16;
  SC_ELEMENT_SELECTION_INACTIVE_BACK = 17;
  SC_ELEMENT_SELECTION_INACTIVE_ADDITIONAL_TEXT = 18;
  SC_ELEMENT_SELECTION_INACTIVE_ADDITIONAL_BACK = 19;
  SC_ELEMENT_CARET = 40;
  SC_ELEMENT_CARET_ADDITIONAL = 41;
  SC_ELEMENT_CARET_LINE_BACK = 50;
  SC_ELEMENT_WHITE_SPACE = 60;
  SC_ELEMENT_WHITE_SPACE_BACK = 61;
  SC_ELEMENT_HOT_SPOT_ACTIVE = 70;
  SC_ELEMENT_HOT_SPOT_ACTIVE_BACK = 71;
  SC_ELEMENT_FOLD_LINE = 80;
  SC_ELEMENT_HIDDEN_LINE = 81;

  /// <summary>Set the colour of an element. Translucency (alpha) may or may not be significant
  /// and this may depend on the platform. The alpha byte should commonly be 0xff for opaque.</summary>
  SCI_SETELEMENTCOLOUR = 2753;

  /// <summary>Get the colour of an element.</summary>
  SCI_GETELEMENTCOLOUR = 2754;

  /// <summary>Use the default or platform-defined colour for an element.</summary>
  SCI_RESETELEMENTCOLOUR = 2755;

  /// <summary>Get whether an element has been set by SetElementColour.
  /// When false, a platform-defined or default colour is used.</summary>
  SCI_GETELEMENTISSET = 2756;

  /// <summary>Get whether an element supports translucency.</summary>
  SCI_GETELEMENTALLOWSTRANSLUCENT = 2757;

  /// <summary>Get the colour of an element.</summary>
  SCI_GETELEMENTBASECOLOUR = 2758;

  /// <summary>Set the foreground colour of the main and additional selections and whether to use this setting.</summary>
  SCI_SETSELFORE = 2067;

  /// <summary>Set the background colour of the main and additional selections and whether to use this setting.</summary>
  SCI_SETSELBACK = 2068;

  /// <summary>Get the alpha of the selection.</summary>
  SCI_GETSELALPHA = 2477;

  /// <summary>Set the alpha of the selection.</summary>
  SCI_SETSELALPHA = 2478;

  /// <summary>Is the selection end of line filled?</summary>
  SCI_GETSELEOLFILLED = 2479;

  /// <summary>Set the selection to have its end of line filled or not.</summary>
  SCI_SETSELEOLFILLED = 2480;

  SC_LAYER_BASE = 0;
  SC_LAYER_UNDER_TEXT = 1;
  SC_LAYER_OVER_TEXT = 2;

  /// <summary>Get the layer for drawing selections</summary>
  SCI_GETSELECTIONLAYER = 2762;

  /// <summary>Set the layer for drawing selections: either opaquely on base layer or translucently over text</summary>
  SCI_SETSELECTIONLAYER = 2763;

  /// <summary>Get the layer of the background of the line containing the caret.</summary>
  SCI_GETCARETLINELAYER = 2764;

  /// <summary>Set the layer of the background of the line containing the caret.</summary>
  SCI_SETCARETLINELAYER = 2765;

  /// <summary>Get only highlighting subline instead of whole line.</summary>
  SCI_GETCARETLINEHIGHLIGHTSUBLINE = 2773;

  /// <summary>Set only highlighting subline instead of whole line.</summary>
  SCI_SETCARETLINEHIGHLIGHTSUBLINE = 2774;

  /// <summary>Set the foreground colour of the caret.</summary>
  SCI_SETCARETFORE = 2069;

  /// <summary>When key+modifier combination keyDefinition is pressed perform sciCommand.</summary>
  SCI_ASSIGNCMDKEY = 2070;

  /// <summary>When key+modifier combination keyDefinition is pressed do nothing.</summary>
  SCI_CLEARCMDKEY = 2071;

  /// <summary>Drop all key mappings.</summary>
  SCI_CLEARALLCMDKEYS = 2072;

  /// <summary>Set the styles for a segment of the document.</summary>
  SCI_SETSTYLINGEX = 2073;

  /// <summary>Set a style to be visible or not.</summary>
  SCI_STYLESETVISIBLE = 2074;

  /// <summary>Get the time in milliseconds that the caret is on and off.</summary>
  SCI_GETCARETPERIOD = 2075;

  /// <summary>Get the time in milliseconds that the caret is on and off. 0 = steady on.</summary>
  SCI_SETCARETPERIOD = 2076;

  /// <summary>Set the set of characters making up words for when moving or selecting by word.
  /// First sets defaults like SetCharsDefault.</summary>
  SCI_SETWORDCHARS = 2077;

  /// <summary>Get the set of characters making up words for when moving or selecting by word.
  /// Returns the number of characters</summary>
  SCI_GETWORDCHARS = 2646;

  /// <summary>Set the number of characters to have directly indexed categories</summary>
  SCI_SETCHARACTERCATEGORYOPTIMIZATION = 2720;

  /// <summary>Get the number of characters to have directly indexed categories</summary>
  SCI_GETCHARACTERCATEGORYOPTIMIZATION = 2721;

  /// <summary>Start a sequence of actions that is undone and redone as a unit.
  /// May be nested.</summary>
  SCI_BEGINUNDOACTION = 2078;

  /// <summary>End a sequence of actions that is undone and redone as a unit.</summary>
  SCI_ENDUNDOACTION = 2079;

  /// <summary>Is an undo sequence active?</summary>
  SCI_GETUNDOSEQUENCE = 2799;

  /// <summary>How many undo actions are in the history?</summary>
  SCI_GETUNDOACTIONS = 2790;

  /// <summary>Set action as the save point</summary>
  SCI_SETUNDOSAVEPOINT = 2791;

  /// <summary>Which action is the save point?</summary>
  SCI_GETUNDOSAVEPOINT = 2792;

  /// <summary>Set action as the detach point</summary>
  SCI_SETUNDODETACH = 2793;

  /// <summary>Which action is the detach point?</summary>
  SCI_GETUNDODETACH = 2794;

  /// <summary>Set action as the tentative point</summary>
  SCI_SETUNDOTENTATIVE = 2795;

  /// <summary>Which action is the tentative point?</summary>
  SCI_GETUNDOTENTATIVE = 2796;

  /// <summary>Set action as the current point</summary>
  SCI_SETUNDOCURRENT = 2797;

  /// <summary>Which action is the current point?</summary>
  SCI_GETUNDOCURRENT = 2798;

  /// <summary>Push one action onto undo history with no text</summary>
  SCI_PUSHUNDOACTIONTYPE = 2800;

  /// <summary>Set the text and length of the most recently pushed action</summary>
  SCI_CHANGELASTUNDOACTIONTEXT = 2801;

  /// <summary>What is the type of an action?</summary>
  SCI_GETUNDOACTIONTYPE = 2802;

  /// <summary>What is the position of an action?</summary>
  SCI_GETUNDOACTIONPOSITION = 2803;

  /// <summary>What is the text of an action?</summary>
  SCI_GETUNDOACTIONTEXT = 2804;

  /// <summary>Indicator style enumeration and some constants</summary>
  INDIC_PLAIN = 0;
  INDIC_SQUIGGLE = 1;
  INDIC_TT = 2;
  INDIC_DIAGONAL = 3;
  INDIC_STRIKE = 4;
  INDIC_HIDDEN = 5;
  INDIC_BOX = 6;
  INDIC_ROUNDBOX = 7;
  INDIC_STRAIGHTBOX = 8;
  INDIC_DASH = 9;
  INDIC_DOTS = 10;
  INDIC_SQUIGGLELOW = 11;
  INDIC_DOTBOX = 12;
  INDIC_SQUIGGLEPIXMAP = 13;
  INDIC_COMPOSITIONTHICK = 14;
  INDIC_COMPOSITIONTHIN = 15;
  INDIC_FULLBOX = 16;
  INDIC_TEXTFORE = 17;
  INDIC_POINT = 18;
  INDIC_POINTCHARACTER = 19;
  INDIC_GRADIENT = 20;
  INDIC_GRADIENTCENTRE = 21;
  INDIC_POINT_TOP = 22;

  /// <summary>INDIC_CONTAINER, INDIC_IME, INDIC_IME_MAX, and INDIC_MAX are indicator numbers,
  /// not IndicatorStyles so should not really be in the INDIC_ enumeration.
  /// They are redeclared in IndicatorNumbers INDICATOR_.</summary>
  INDIC_CONTAINER = 8;
  INDIC_IME = 32;
  INDIC_IME_MAX = 35;
  INDIC_MAX = 35;

  INDICATOR_CONTAINER = 8;
  INDICATOR_IME = 32;
  INDICATOR_IME_MAX = 35;
  INDICATOR_HISTORY_REVERTED_TO_ORIGIN_INSERTION = 36;
  INDICATOR_HISTORY_REVERTED_TO_ORIGIN_DELETION = 37;
  INDICATOR_HISTORY_SAVED_INSERTION = 38;
  INDICATOR_HISTORY_SAVED_DELETION = 39;
  INDICATOR_HISTORY_MODIFIED_INSERTION = 40;
  INDICATOR_HISTORY_MODIFIED_DELETION = 41;
  INDICATOR_HISTORY_REVERTED_TO_MODIFIED_INSERTION = 42;
  INDICATOR_HISTORY_REVERTED_TO_MODIFIED_DELETION = 43;
  INDICATOR_MAX = 43;

  /// <summary>Set an indicator to plain, squiggle or TT.</summary>
  SCI_INDICSETSTYLE = 2080;

  /// <summary>Retrieve the style of an indicator.</summary>
  SCI_INDICGETSTYLE = 2081;

  /// <summary>Set the foreground colour of an indicator.</summary>
  SCI_INDICSETFORE = 2082;

  /// <summary>Retrieve the foreground colour of an indicator.</summary>
  SCI_INDICGETFORE = 2083;

  /// <summary>Set an indicator to draw under text or over(default).</summary>
  SCI_INDICSETUNDER = 2510;

  /// <summary>Retrieve whether indicator drawn under or over text.</summary>
  SCI_INDICGETUNDER = 2511;

  /// <summary>Set a hover indicator to plain, squiggle or TT.</summary>
  SCI_INDICSETHOVERSTYLE = 2680;

  /// <summary>Retrieve the hover style of an indicator.</summary>
  SCI_INDICGETHOVERSTYLE = 2681;

  /// <summary>Set the foreground hover colour of an indicator.</summary>
  SCI_INDICSETHOVERFORE = 2682;

  /// <summary>Retrieve the foreground hover colour of an indicator.</summary>
  SCI_INDICGETHOVERFORE = 2683;

  SC_INDICVALUEBIT = $1000000;
  SC_INDICVALUEMASK = $FFFFFF;

  SC_INDICFLAG_NONE = 0;
  SC_INDICFLAG_VALUEFORE = 1;

  /// <summary>Set the attributes of an indicator.</summary>
  SCI_INDICSETFLAGS = 2684;

  /// <summary>Retrieve the attributes of an indicator.</summary>
  SCI_INDICGETFLAGS = 2685;

  /// <summary>Set the stroke width of an indicator in hundredths of a pixel.</summary>
  SCI_INDICSETSTROKEWIDTH = 2751;

  /// <summary>Retrieve the stroke width of an indicator.</summary>
  SCI_INDICGETSTROKEWIDTH = 2752;

  /// <summary>Set the foreground colour of all whitespace and whether to use this setting.</summary>
  SCI_SETWHITESPACEFORE = 2084;

  /// <summary>Set the background colour of all whitespace and whether to use this setting.</summary>
  SCI_SETWHITESPACEBACK = 2085;

  /// <summary>Set the size of the dots used to mark space characters.</summary>
  SCI_SETWHITESPACESIZE = 2086;

  /// <summary>Get the size of the dots used to mark space characters.</summary>
  SCI_GETWHITESPACESIZE = 2087;

  /// <summary>Used to hold extra styling information for each line.</summary>
  SCI_SETLINESTATE = 2092;

  /// <summary>Retrieve the extra styling information for a line.</summary>
  SCI_GETLINESTATE = 2093;

  /// <summary>Retrieve the last line number that has line state.</summary>
  SCI_GETMAXLINESTATE = 2094;

  /// <summary>Is the background of the line containing the caret in a different colour?</summary>
  SCI_GETCARETLINEVISIBLE = 2095;

  /// <summary>Display the background of the line containing the caret in a different colour.</summary>
  SCI_SETCARETLINEVISIBLE = 2096;

  /// <summary>Get the colour of the background of the line containing the caret.</summary>
  SCI_GETCARETLINEBACK = 2097;

  /// <summary>Set the colour of the background of the line containing the caret.</summary>
  SCI_SETCARETLINEBACK = 2098;

  /// <summary>Retrieve the caret line frame width.
  /// Width = 0 means this option is disabled.</summary>
  SCI_GETCARETLINEFRAME = 2704;

  /// <summary>Display the caret line framed.
  /// Set width != 0 to enable this option and width = 0 to disable it.</summary>
  SCI_SETCARETLINEFRAME = 2705;

  /// <summary>Set a style to be changeable or not (read only).
  /// Experimental feature, currently buggy.</summary>
  SCI_STYLESETCHANGEABLE = 2099;

  /// <summary>Display a auto-completion list.
  /// The lengthEntered parameter indicates how many characters before
  /// the caret should be used to provide context.</summary>
  SCI_AUTOCSHOW = 2100;

  /// <summary>Remove the auto-completion list from the screen.</summary>
  SCI_AUTOCCANCEL = 2101;

  /// <summary>Is there an auto-completion list visible?</summary>
  SCI_AUTOCACTIVE = 2102;

  /// <summary>Retrieve the position of the caret when the auto-completion list was displayed.</summary>
  SCI_AUTOCPOSSTART = 2103;

  /// <summary>User has selected an item so remove the list and insert the selection.</summary>
  SCI_AUTOCCOMPLETE = 2104;

  /// <summary>Define a set of character that when typed cancel the auto-completion list.</summary>
  SCI_AUTOCSTOPS = 2105;

  /// <summary>Change the separator character in the string setting up an auto-completion list.
  /// Default is space but can be changed if items contain space.</summary>
  SCI_AUTOCSETSEPARATOR = 2106;

  /// <summary>Retrieve the auto-completion list separator character.</summary>
  SCI_AUTOCGETSEPARATOR = 2107;

  /// <summary>Select the item in the auto-completion list that starts with a string.</summary>
  SCI_AUTOCSELECT = 2108;

  /// <summary>Should the auto-completion list be cancelled if the user backspaces to a
  /// position before where the box was created.</summary>
  SCI_AUTOCSETCANCELATSTART = 2110;

  /// <summary>Retrieve whether auto-completion cancelled by backspacing before start.</summary>
  SCI_AUTOCGETCANCELATSTART = 2111;

  /// <summary>Define a set of characters that when typed will cause the autocompletion to
  /// choose the selected item.</summary>
  SCI_AUTOCSETFILLUPS = 2112;

  /// <summary>Should a single item auto-completion list automatically choose the item.</summary>
  SCI_AUTOCSETCHOOSESINGLE = 2113;

  /// <summary>Retrieve whether a single item auto-completion list automatically choose the item.</summary>
  SCI_AUTOCGETCHOOSESINGLE = 2114;

  /// <summary>Set whether case is significant when performing auto-completion searches.</summary>
  SCI_AUTOCSETIGNORECASE = 2115;

  /// <summary>Retrieve state of ignore case flag.</summary>
  SCI_AUTOCGETIGNORECASE = 2116;

  /// <summary>Display a list of strings and send notification when user chooses one.</summary>
  SCI_USERLISTSHOW = 2117;

  /// <summary>Set whether or not autocompletion is hidden automatically when nothing matches.</summary>
  SCI_AUTOCSETAUTOHIDE = 2118;

  /// <summary>Retrieve whether or not autocompletion is hidden automatically when nothing matches.</summary>
  SCI_AUTOCGETAUTOHIDE = 2119;

  /// <summary>Define option flags for autocompletion lists</summary>
  SC_AUTOCOMPLETE_NORMAL = 0;

  /// <summary>Win32 specific:</summary>
  SC_AUTOCOMPLETE_FIXED_SIZE = 1;

  /// <summary>Always select the first item in the autocompletion list:</summary>
  SC_AUTOCOMPLETE_SELECT_FIRST_ITEM = 2;

  /// <summary>Set autocompletion options.</summary>
  SCI_AUTOCSETOPTIONS = 2638;

  /// <summary>Retrieve autocompletion options.</summary>
  SCI_AUTOCGETOPTIONS = 2639;

  /// <summary>Set whether or not autocompletion deletes any word characters
  /// after the inserted text upon completion.</summary>
  SCI_AUTOCSETDROPRESTOFWORD = 2270;

  /// <summary>Retrieve whether or not autocompletion deletes any word characters
  /// after the inserted text upon completion.</summary>
  SCI_AUTOCGETDROPRESTOFWORD = 2271;

  /// <summary>Register an XPM image for use in autocompletion lists.</summary>
  SCI_REGISTERIMAGE = 2405;

  /// <summary>Clear all the registered XPM images.</summary>
  SCI_CLEARREGISTEREDIMAGES = 2408;

  /// <summary>Retrieve the auto-completion list type-separator character.</summary>
  SCI_AUTOCGETTYPESEPARATOR = 2285;

  /// <summary>Change the type-separator character in the string setting up an auto-completion list.
  /// Default is '?' but can be changed if items contain '?'.</summary>
  SCI_AUTOCSETTYPESEPARATOR = 2286;

  /// <summary>Set the maximum width, in characters, of auto-completion and user lists.
  /// Set to 0 to autosize to fit longest item, which is the default.</summary>
  SCI_AUTOCSETMAXWIDTH = 2208;

  /// <summary>Get the maximum width, in characters, of auto-completion and user lists.</summary>
  SCI_AUTOCGETMAXWIDTH = 2209;

  /// <summary>Set the maximum height, in rows, of auto-completion and user lists.
  /// The default is 5 rows.</summary>
  SCI_AUTOCSETMAXHEIGHT = 2210;

  /// <summary>Set the maximum height, in rows, of auto-completion and user lists.</summary>
  SCI_AUTOCGETMAXHEIGHT = 2211;

  /// <summary>Set the style number used for auto-completion and user lists fonts.</summary>
  SCI_AUTOCSETSTYLE = 2109;

  /// <summary>Get the style number used for auto-completion and user lists fonts.</summary>
  SCI_AUTOCGETSTYLE = 2120;

  /// <summary>Set the scale factor in percent for auto-completion list images.</summary>
  SCI_AUTOCSETIMAGESCALE = 2815;

  /// <summary>Get the scale factor in percent for auto-completion list images.</summary>
  SCI_AUTOCGETIMAGESCALE = 2816;

  /// <summary>Set the number of spaces used for one level of indentation.</summary>
  SCI_SETINDENT = 2122;

  /// <summary>Retrieve indentation size.</summary>
  SCI_GETINDENT = 2123;

  /// <summary>Indentation will only use space characters if useTabs is false, otherwise
  /// it will use a combination of tabs and spaces.</summary>
  SCI_SETUSETABS = 2124;

  /// <summary>Retrieve whether tabs will be used in indentation.</summary>
  SCI_GETUSETABS = 2125;

  /// <summary>Change the indentation of a line to a number of columns.</summary>
  SCI_SETLINEINDENTATION = 2126;

  /// <summary>Retrieve the number of columns that a line is indented.</summary>
  SCI_GETLINEINDENTATION = 2127;

  /// <summary>Retrieve the position before the first non indentation character on a line.</summary>
  SCI_GETLINEINDENTPOSITION = 2128;

  /// <summary>Retrieve the column number of a position, taking tab width into account.</summary>
  SCI_GETCOLUMN = 2129;

  /// <summary>Count characters between two positions.</summary>
  SCI_COUNTCHARACTERS = 2633;

  /// <summary>Count code units between two positions.</summary>
  SCI_COUNTCODEUNITS = 2715;

  /// <summary>Show or hide the horizontal scroll bar.</summary>
  SCI_SETHSCROLLBAR = 2130;

  /// <summary>Is the horizontal scroll bar visible?</summary>
  SCI_GETHSCROLLBAR = 2131;

  SC_IV_NONE = 0;
  SC_IV_REAL = 1;
  SC_IV_LOOKFORWARD = 2;
  SC_IV_LOOKBOTH = 3;

  /// <summary>Show or hide indentation guides.</summary>
  SCI_SETINDENTATIONGUIDES = 2132;

  /// <summary>Are the indentation guides visible?</summary>
  SCI_GETINDENTATIONGUIDES = 2133;

  /// <summary>Set the highlighted indentation guide column.
  /// 0 = no highlighted guide.</summary>
  SCI_SETHIGHLIGHTGUIDE = 2134;

  /// <summary>Get the highlighted indentation guide column.</summary>
  SCI_GETHIGHLIGHTGUIDE = 2135;

  /// <summary>Get the position after the last visible characters on a line.</summary>
  SCI_GETLINEENDPOSITION = 2136;

  /// <summary>Get the code page used to interpret the bytes of the document as characters.</summary>
  SCI_GETCODEPAGE = 2137;

  /// <summary>Get the foreground colour of the caret.</summary>
  SCI_GETCARETFORE = 2138;

  /// <summary>In read-only mode?</summary>
  SCI_GETREADONLY = 2140;

  /// <summary>Sets the position of the caret.</summary>
  SCI_SETCURRENTPOS = 2141;

  /// <summary>Sets the position that starts the selection - this becomes the anchor.</summary>
  SCI_SETSELECTIONSTART = 2142;

  /// <summary>Returns the position at the start of the selection.</summary>
  SCI_GETSELECTIONSTART = 2143;

  /// <summary>Sets the position that ends the selection - this becomes the caret.</summary>
  SCI_SETSELECTIONEND = 2144;

  /// <summary>Returns the position at the end of the selection.</summary>
  SCI_GETSELECTIONEND = 2145;

  /// <summary>Set caret to a position, while removing any existing selection.</summary>
  SCI_SETEMPTYSELECTION = 2556;

  /// <summary>Sets the print magnification added to the point size of each style for printing.</summary>
  SCI_SETPRINTMAGNIFICATION = 2146;

  /// <summary>Returns the print magnification.</summary>
  SCI_GETPRINTMAGNIFICATION = 2147;

  /// <summary>PrintColourMode - use same colours as screen.
  /// with the exception of line number margins, which use a white background</summary>
  SC_PRINT_NORMAL = 0;

  /// <summary>PrintColourMode - invert the light value of each style for printing.</summary>
  SC_PRINT_INVERTLIGHT = 1;

  /// <summary>PrintColourMode - force black text on white background for printing.</summary>
  SC_PRINT_BLACKONWHITE = 2;

  /// <summary>PrintColourMode - text stays coloured, but all background is forced to be white for printing.</summary>
  SC_PRINT_COLOURONWHITE = 3;

  /// <summary>PrintColourMode - only the default-background is forced to be white for printing.</summary>
  SC_PRINT_COLOURONWHITEDEFAULTBG = 4;

  /// <summary>PrintColourMode - use same colours as screen, including line number margins.</summary>
  SC_PRINT_SCREENCOLOURS = 5;

  /// <summary>Modify colours when printing for clearer printed text.</summary>
  SCI_SETPRINTCOLOURMODE = 2148;

  /// <summary>Returns the print colour mode.</summary>
  SCI_GETPRINTCOLOURMODE = 2149;

  SCFIND_NONE = $0;
  SCFIND_WHOLEWORD = $2;
  SCFIND_MATCHCASE = $4;
  SCFIND_WORDSTART = $00100000;
  SCFIND_REGEXP = $00200000;
  SCFIND_POSIX = $00400000;
  SCFIND_CXX11REGEX = $00800000;

  /// <summary>Find some text in the document.</summary>
  SCI_FINDTEXT = 2150;

  /// <summary>Find some text in the document.</summary>
  SCI_FINDTEXTFULL = 2196;

  /// <summary>Draw the document into a display context such as a printer.</summary>
  SCI_FORMATRANGE = 2151;

  /// <summary>Draw the document into a display context such as a printer.</summary>
  SCI_FORMATRANGEFULL = 2777;

  SC_CHANGE_HISTORY_DISABLED = 0;
  SC_CHANGE_HISTORY_ENABLED = 1;
  SC_CHANGE_HISTORY_MARKERS = 2;
  SC_CHANGE_HISTORY_INDICATORS = 4;

  /// <summary>Enable or disable change history.</summary>
  SCI_SETCHANGEHISTORY = 2780;

  /// <summary>Report change history status.</summary>
  SCI_GETCHANGEHISTORY = 2781;

  SC_UNDO_SELECTION_HISTORY_DISABLED = 0;
  SC_UNDO_SELECTION_HISTORY_ENABLED = 1;
  SC_UNDO_SELECTION_HISTORY_SCROLL = 2;

  /// <summary>Enable or disable undo selection history.</summary>
  SCI_SETUNDOSELECTIONHISTORY = 2782;

  /// <summary>Report undo selection history status.</summary>
  SCI_GETUNDOSELECTIONHISTORY = 2783;

  /// <summary>Set selection from serialized form.</summary>
  SCI_SETSELECTIONSERIALIZED = 2784;

  /// <summary>Retrieve serialized form of selection.</summary>
  SCI_GETSELECTIONSERIALIZED = 2785;

  /// <summary>Retrieve the display line at the top of the display.</summary>
  SCI_GETFIRSTVISIBLELINE = 2152;

  /// <summary>Retrieve the contents of a line.
  /// Returns the length of the line.</summary>
  SCI_GETLINE = 2153;

  /// <summary>Returns the number of lines in the document. There is always at least one.</summary>
  SCI_GETLINECOUNT = 2154;

  /// <summary>Enlarge the number of lines allocated.</summary>
  SCI_ALLOCATELINES = 2089;

  /// <summary>Sets the size in pixels of the left margin.</summary>
  SCI_SETMARGINLEFT = 2155;

  /// <summary>Returns the size in pixels of the left margin.</summary>
  SCI_GETMARGINLEFT = 2156;

  /// <summary>Sets the size in pixels of the right margin.</summary>
  SCI_SETMARGINRIGHT = 2157;

  /// <summary>Returns the size in pixels of the right margin.</summary>
  SCI_GETMARGINRIGHT = 2158;

  /// <summary>Is the document different from when it was last saved?</summary>
  SCI_GETMODIFY = 2159;

  /// <summary>Select a range of text.</summary>
  SCI_SETSEL = 2160;

  /// <summary>Retrieve the selected text.
  /// Return the length of the text.
  /// Result is NUL-terminated.</summary>
  SCI_GETSELTEXT = 2161;

  /// <summary>Retrieve a range of text.
  /// Return the length of the text.</summary>
  SCI_GETTEXTRANGE = 2162;

  /// <summary>Retrieve a range of text that can be past 2GB.
  /// Return the length of the text.</summary>
  SCI_GETTEXTRANGEFULL = 2039;

  /// <summary>Draw the selection either highlighted or in normal (non-highlighted) style.</summary>
  SCI_HIDESELECTION = 2163;

  /// <summary>Is the selection visible or hidden?</summary>
  SCI_GETSELECTIONHIDDEN = 2088;

  /// <summary>Retrieve the x value of the point in the window where a position is displayed.</summary>
  SCI_POINTXFROMPOSITION = 2164;

  /// <summary>Retrieve the y value of the point in the window where a position is displayed.</summary>
  SCI_POINTYFROMPOSITION = 2165;

  /// <summary>Retrieve the line containing a position.</summary>
  SCI_LINEFROMPOSITION = 2166;

  /// <summary>Retrieve the position at the start of a line.</summary>
  SCI_POSITIONFROMLINE = 2167;

  /// <summary>Scroll horizontally and vertically.</summary>
  SCI_LINESCROLL = 2168;

  /// <summary>Scroll vertically with allowance for wrapping.</summary>
  SCI_SCROLLVERTICAL = 2817;

  /// <summary>Ensure the caret is visible.</summary>
  SCI_SCROLLCARET = 2169;

  /// <summary>Scroll the argument positions and the range between them into view giving
  /// priority to the primary position then the secondary position.
  /// This may be used to make a search match visible.</summary>
  SCI_SCROLLRANGE = 2569;

  /// <summary>Replace the selected text with the argument text.</summary>
  SCI_REPLACESEL = 2170;

  /// <summary>Set to read only or read write.</summary>
  SCI_SETREADONLY = 2171;

  /// <summary>Null operation.</summary>
  SCI_NULL = 2172;

  /// <summary>Will a paste succeed?</summary>
  SCI_CANPASTE = 2173;

  /// <summary>Are there any undoable actions in the undo history?</summary>
  SCI_CANUNDO = 2174;

  /// <summary>Delete the undo history.</summary>
  SCI_EMPTYUNDOBUFFER = 2175;

  /// <summary>Undo one action in the undo history.</summary>
  SCI_UNDO = 2176;

  /// <summary>Cut the selection to the clipboard.</summary>
  SCI_CUT = 2177;

  /// <summary>Copy the selection to the clipboard.</summary>
  SCI_COPY = 2178;

  /// <summary>Paste the contents of the clipboard into the document replacing the selection.</summary>
  SCI_PASTE = 2179;

  /// <summary>Clear the selection.</summary>
  SCI_CLEAR = 2180;

  /// <summary>Replace the contents of the document with the argument text.</summary>
  SCI_SETTEXT = 2181;

  /// <summary>Retrieve all the text in the document.
  /// Returns number of characters retrieved.
  /// Result is NUL-terminated.</summary>
  SCI_GETTEXT = 2182;

  /// <summary>Retrieve the number of characters in the document.</summary>
  SCI_GETTEXTLENGTH = 2183;

  /// <summary>Retrieve a pointer to a function that processes messages for this Scintilla.</summary>
  SCI_GETDIRECTFUNCTION = 2184;

  /// <summary>Retrieve a pointer to a function that processes messages for this Scintilla and returns status.</summary>
  SCI_GETDIRECTSTATUSFUNCTION = 2772;

  /// <summary>Retrieve a pointer value to use as the first argument when calling
  /// the function returned by GetDirectFunction.</summary>
  SCI_GETDIRECTPOINTER = 2185;

  /// <summary>Set to overtype (true) or insert mode.</summary>
  SCI_SETOVERTYPE = 2186;

  /// <summary>Returns true if overtype mode is active otherwise false is returned.</summary>
  SCI_GETOVERTYPE = 2187;

  /// <summary>Set the width of the insert mode caret.</summary>
  SCI_SETCARETWIDTH = 2188;

  /// <summary>Returns the width of the insert mode caret.</summary>
  SCI_GETCARETWIDTH = 2189;

  /// <summary>Sets the position that starts the target which is used for updating the
  /// document without affecting the scroll position.</summary>
  SCI_SETTARGETSTART = 2190;

  /// <summary>Get the position that starts the target.</summary>
  SCI_GETTARGETSTART = 2191;

  /// <summary>Sets the virtual space of the target start</summary>
  SCI_SETTARGETSTARTVIRTUALSPACE = 2728;

  /// <summary>Get the virtual space of the target start</summary>
  SCI_GETTARGETSTARTVIRTUALSPACE = 2729;

  /// <summary>Sets the position that ends the target which is used for updating the
  /// document without affecting the scroll position.</summary>
  SCI_SETTARGETEND = 2192;

  /// <summary>Get the position that ends the target.</summary>
  SCI_GETTARGETEND = 2193;

  /// <summary>Sets the virtual space of the target end</summary>
  SCI_SETTARGETENDVIRTUALSPACE = 2730;

  /// <summary>Get the virtual space of the target end</summary>
  SCI_GETTARGETENDVIRTUALSPACE = 2731;

  /// <summary>Sets both the start and end of the target in one call.</summary>
  SCI_SETTARGETRANGE = 2686;

  /// <summary>Retrieve the text in the target.</summary>
  SCI_GETTARGETTEXT = 2687;

  /// <summary>Make the target range start and end be the same as the selection range start and end.</summary>
  SCI_TARGETFROMSELECTION = 2287;

  /// <summary>Sets the target to the whole document.</summary>
  SCI_TARGETWHOLEDOCUMENT = 2690;

  /// <summary>Replace the target text with the argument text.
  /// Text is counted so it can contain NULs.
  /// Returns the length of the replacement text.</summary>
  SCI_REPLACETARGET = 2194;

  /// <summary>Replace the target text with the argument text after \d processing.
  /// Text is counted so it can contain NULs.
  /// Looks for \d where d is between 1 and 9 and replaces these with the strings
  /// matched in the last search operation which were surrounded by \( and \).
  /// Returns the length of the replacement text including any change
  /// caused by processing the \d patterns.</summary>
  SCI_REPLACETARGETRE = 2195;

  /// <summary>Replace the target text with the argument text but ignore prefix and suffix that
  /// are the same as current.</summary>
  SCI_REPLACETARGETMINIMAL = 2779;

  /// <summary>Search for a counted string in the target and set the target to the found
  /// range. Text is counted so it can contain NULs.
  /// Returns start of found range or -1 for failure in which case target is not moved.</summary>
  SCI_SEARCHINTARGET = 2197;

  /// <summary>Set the search flags used by SearchInTarget.</summary>
  SCI_SETSEARCHFLAGS = 2198;

  /// <summary>Get the search flags used by SearchInTarget.</summary>
  SCI_GETSEARCHFLAGS = 2199;

  /// <summary>Show a call tip containing a definition near position pos.</summary>
  SCI_CALLTIPSHOW = 2200;

  /// <summary>Remove the call tip from the screen.</summary>
  SCI_CALLTIPCANCEL = 2201;

  /// <summary>Is there an active call tip?</summary>
  SCI_CALLTIPACTIVE = 2202;

  /// <summary>Retrieve the position where the caret was before displaying the call tip.</summary>
  SCI_CALLTIPPOSSTART = 2203;

  /// <summary>Set the start position in order to change when backspacing removes the calltip.</summary>
  SCI_CALLTIPSETPOSSTART = 2214;

  /// <summary>Highlight a segment of the definition.</summary>
  SCI_CALLTIPSETHLT = 2204;

  /// <summary>Set the background colour for the call tip.</summary>
  SCI_CALLTIPSETBACK = 2205;

  /// <summary>Set the foreground colour for the call tip.</summary>
  SCI_CALLTIPSETFORE = 2206;

  /// <summary>Set the foreground colour for the highlighted part of the call tip.</summary>
  SCI_CALLTIPSETFOREHLT = 2207;

  /// <summary>Enable use of STYLE_CALLTIP and set call tip tab size in pixels.</summary>
  SCI_CALLTIPUSESTYLE = 2212;

  /// <summary>Set position of calltip, above or below text.</summary>
  SCI_CALLTIPSETPOSITION = 2213;

  /// <summary>Find the display line of a document line taking hidden lines into account.</summary>
  SCI_VISIBLEFROMDOCLINE = 2220;

  /// <summary>Find the document line of a display line taking hidden lines into account.</summary>
  SCI_DOCLINEFROMVISIBLE = 2221;

  /// <summary>The number of display lines needed to wrap a document line</summary>
  SCI_WRAPCOUNT = 2235;

  SC_FOLDLEVELNONE = $0;
  SC_FOLDLEVELBASE = $400;
  SC_FOLDLEVELWHITEFLAG = $1000;
  SC_FOLDLEVELHEADERFLAG = $2000;
  SC_FOLDLEVELNUMBERMASK = $0FFF;

  /// <summary>Set the fold level of a line.
  /// This encodes an integer level along with flags indicating whether the
  /// line is a header and whether it is effectively white space.</summary>
  SCI_SETFOLDLEVEL = 2222;

  /// <summary>Retrieve the fold level of a line.</summary>
  SCI_GETFOLDLEVEL = 2223;

  /// <summary>Find the last child line of a header line.</summary>
  SCI_GETLASTCHILD = 2224;

  /// <summary>Find the parent line of a child line.</summary>
  SCI_GETFOLDPARENT = 2225;

  /// <summary>Make a range of lines visible.</summary>
  SCI_SHOWLINES = 2226;

  /// <summary>Make a range of lines invisible.</summary>
  SCI_HIDELINES = 2227;

  /// <summary>Is a line visible?</summary>
  SCI_GETLINEVISIBLE = 2228;

  /// <summary>Are all lines visible?</summary>
  SCI_GETALLLINESVISIBLE = 2236;

  /// <summary>Show the children of a header line.</summary>
  SCI_SETFOLDEXPANDED = 2229;

  /// <summary>Is a header line expanded?</summary>
  SCI_GETFOLDEXPANDED = 2230;

  /// <summary>Switch a header line between expanded and contracted.</summary>
  SCI_TOGGLEFOLD = 2231;

  /// <summary>Switch a header line between expanded and contracted and show some text after the line.</summary>
  SCI_TOGGLEFOLDSHOWTEXT = 2700;

  SC_FOLDDISPLAYTEXT_HIDDEN = 0;
  SC_FOLDDISPLAYTEXT_STANDARD = 1;
  SC_FOLDDISPLAYTEXT_BOXED = 2;

  /// <summary>Set the style of fold display text.</summary>
  SCI_FOLDDISPLAYTEXTSETSTYLE = 2701;

  /// <summary>Get the style of fold display text.</summary>
  SCI_FOLDDISPLAYTEXTGETSTYLE = 2707;

  /// <summary>Set the default fold display text.</summary>
  SCI_SETDEFAULTFOLDDISPLAYTEXT = 2722;

  /// <summary>Get the default fold display text.</summary>
  SCI_GETDEFAULTFOLDDISPLAYTEXT = 2723;

  SC_FOLDACTION_CONTRACT = 0;
  SC_FOLDACTION_EXPAND = 1;
  SC_FOLDACTION_TOGGLE = 2;
  SC_FOLDACTION_CONTRACT_EVERY_LEVEL = 4;

  /// <summary>Expand or contract a fold header.</summary>
  SCI_FOLDLINE = 2237;

  /// <summary>Expand or contract a fold header and its children.</summary>
  SCI_FOLDCHILDREN = 2238;

  /// <summary>Expand a fold header and all children. Use the level argument instead of the line's current level.</summary>
  SCI_EXPANDCHILDREN = 2239;

  /// <summary>Expand or contract all fold headers.</summary>
  SCI_FOLDALL = 2662;

  /// <summary>Ensure a particular line is visible by expanding any header line hiding it.</summary>
  SCI_ENSUREVISIBLE = 2232;

  SC_AUTOMATICFOLD_NONE = $0000;
  SC_AUTOMATICFOLD_SHOW = $0001;
  SC_AUTOMATICFOLD_CLICK = $0002;
  SC_AUTOMATICFOLD_CHANGE = $0004;

  /// <summary>Set automatic folding behaviours.</summary>
  SCI_SETAUTOMATICFOLD = 2663;

  /// <summary>Get automatic folding behaviours.</summary>
  SCI_GETAUTOMATICFOLD = 2664;

  SC_FOLDFLAG_NONE = $0000;
  SC_FOLDFLAG_LINEBEFORE_EXPANDED = $0002;
  SC_FOLDFLAG_LINEBEFORE_CONTRACTED = $0004;
  SC_FOLDFLAG_LINEAFTER_EXPANDED = $0008;
  SC_FOLDFLAG_LINEAFTER_CONTRACTED = $0010;
  SC_FOLDFLAG_LEVELNUMBERS = $0040;
  SC_FOLDFLAG_LINESTATE = $0080;

  /// <summary>Set some style options for folding.</summary>
  SCI_SETFOLDFLAGS = 2233;

  /// <summary>Ensure a particular line is visible by expanding any header line hiding it.
  /// Use the currently set visibility policy to determine which range to display.</summary>
  SCI_ENSUREVISIBLEENFORCEPOLICY = 2234;

  /// <summary>Sets whether a tab pressed when caret is within indentation indents.</summary>
  SCI_SETTABINDENTS = 2260;

  /// <summary>Does a tab pressed when caret is within indentation indent?</summary>
  SCI_GETTABINDENTS = 2261;

  /// <summary>Sets whether a backspace pressed when caret is within indentation unindents.</summary>
  SCI_SETBACKSPACEUNINDENTS = 2262;

  /// <summary>Does a backspace pressed when caret is within indentation unindent?</summary>
  SCI_GETBACKSPACEUNINDENTS = 2263;

  SC_TIME_FOREVER = 10000000;

  /// <summary>Sets the time the mouse must sit still to generate a mouse dwell event.</summary>
  SCI_SETMOUSEDWELLTIME = 2264;

  /// <summary>Retrieve the time the mouse must sit still to generate a mouse dwell event.</summary>
  SCI_GETMOUSEDWELLTIME = 2265;

  /// <summary>Get position of start of word.</summary>
  SCI_WORDSTARTPOSITION = 2266;

  /// <summary>Get position of end of word.</summary>
  SCI_WORDENDPOSITION = 2267;

  /// <summary>Is the range start..end considered a word?</summary>
  SCI_ISRANGEWORD = 2691;

  SC_IDLESTYLING_NONE = 0;
  SC_IDLESTYLING_TOVISIBLE = 1;
  SC_IDLESTYLING_AFTERVISIBLE = 2;
  SC_IDLESTYLING_ALL = 3;

  /// <summary>Sets limits to idle styling.</summary>
  SCI_SETIDLESTYLING = 2692;

  /// <summary>Retrieve the limits to idle styling.</summary>
  SCI_GETIDLESTYLING = 2693;

  SC_WRAP_NONE = 0;
  SC_WRAP_WORD = 1;
  SC_WRAP_CHAR = 2;
  SC_WRAP_WHITESPACE = 3;

  /// <summary>Sets whether text is word wrapped.</summary>
  SCI_SETWRAPMODE = 2268;

  /// <summary>Retrieve whether text is word wrapped.</summary>
  SCI_GETWRAPMODE = 2269;

  SC_WRAPVISUALFLAG_NONE = $0000;
  SC_WRAPVISUALFLAG_END = $0001;
  SC_WRAPVISUALFLAG_START = $0002;
  SC_WRAPVISUALFLAG_MARGIN = $0004;

  /// <summary>Set the display mode of visual flags for wrapped lines.</summary>
  SCI_SETWRAPVISUALFLAGS = 2460;

  /// <summary>Retrive the display mode of visual flags for wrapped lines.</summary>
  SCI_GETWRAPVISUALFLAGS = 2461;

  SC_WRAPVISUALFLAGLOC_DEFAULT = $0000;
  SC_WRAPVISUALFLAGLOC_END_BY_TEXT = $0001;
  SC_WRAPVISUALFLAGLOC_START_BY_TEXT = $0002;

  /// <summary>Set the location of visual flags for wrapped lines.</summary>
  SCI_SETWRAPVISUALFLAGSLOCATION = 2462;

  /// <summary>Retrive the location of visual flags for wrapped lines.</summary>
  SCI_GETWRAPVISUALFLAGSLOCATION = 2463;

  /// <summary>Set the start indent for wrapped lines.</summary>
  SCI_SETWRAPSTARTINDENT = 2464;

  /// <summary>Retrive the start indent for wrapped lines.</summary>
  SCI_GETWRAPSTARTINDENT = 2465;

  SC_WRAPINDENT_FIXED = 0;
  SC_WRAPINDENT_SAME = 1;
  SC_WRAPINDENT_INDENT = 2;
  SC_WRAPINDENT_DEEPINDENT = 3;

  /// <summary>Sets how wrapped sublines are placed. Default is fixed.</summary>
  SCI_SETWRAPINDENTMODE = 2472;

  /// <summary>Retrieve how wrapped sublines are placed. Default is fixed.</summary>
  SCI_GETWRAPINDENTMODE = 2473;

  SC_CACHE_NONE = 0;
  SC_CACHE_CARET = 1;
  SC_CACHE_PAGE = 2;
  SC_CACHE_DOCUMENT = 3;

  /// <summary>Sets the degree of caching of layout information.</summary>
  SCI_SETLAYOUTCACHE = 2272;

  /// <summary>Retrieve the degree of caching of layout information.</summary>
  SCI_GETLAYOUTCACHE = 2273;

  /// <summary>Sets the document width assumed for scrolling.</summary>
  SCI_SETSCROLLWIDTH = 2274;

  /// <summary>Retrieve the document width assumed for scrolling.</summary>
  SCI_GETSCROLLWIDTH = 2275;

  /// <summary>Sets whether the maximum width line displayed is used to set scroll width.</summary>
  SCI_SETSCROLLWIDTHTRACKING = 2516;

  /// <summary>Retrieve whether the scroll width tracks wide lines.</summary>
  SCI_GETSCROLLWIDTHTRACKING = 2517;

  /// <summary>Measure the pixel width of some text in a particular style.
  /// NUL terminated text argument.
  /// Does not handle tab or control characters.</summary>
  SCI_TEXTWIDTH = 2276;

  /// <summary>Sets the scroll range so that maximum scroll position has
  /// the last line at the bottom of the view (default).
  /// Setting this to false allows scrolling one page below the last line.</summary>
  SCI_SETENDATLASTLINE = 2277;

  /// <summary>Retrieve whether the maximum scroll position has the last
  /// line at the bottom of the view.</summary>
  SCI_GETENDATLASTLINE = 2278;

  /// <summary>Retrieve the height of a particular line of text in pixels.</summary>
  SCI_TEXTHEIGHT = 2279;

  /// <summary>Show or hide the vertical scroll bar.</summary>
  SCI_SETVSCROLLBAR = 2280;

  /// <summary>Is the vertical scroll bar visible?</summary>
  SCI_GETVSCROLLBAR = 2281;

  /// <summary>Append a string to the end of the document without changing the selection.</summary>
  SCI_APPENDTEXT = 2282;

  SC_PHASES_ONE = 0;
  SC_PHASES_TWO = 1;
  SC_PHASES_MULTIPLE = 2;

  /// <summary>How many phases is drawing done in?</summary>
  SCI_GETPHASESDRAW = 2673;

  /// <summary>In one phase draw, text is drawn in a series of rectangular blocks with no overlap.
  /// In two phase draw, text is drawn in a series of lines allowing runs to overlap horizontally.
  /// In multiple phase draw, each element is drawn over the whole drawing area, allowing text
  /// to overlap from one line to the next.</summary>
  SCI_SETPHASESDRAW = 2674;

  SC_EFF_QUALITY_MASK = $F;
  SC_EFF_QUALITY_DEFAULT = 0;
  SC_EFF_QUALITY_NON_ANTIALIASED = 1;
  SC_EFF_QUALITY_ANTIALIASED = 2;
  SC_EFF_QUALITY_LCD_OPTIMIZED = 3;

  /// <summary>Choose the quality level for text from the FontQuality enumeration.</summary>
  SCI_SETFONTQUALITY = 2611;

  /// <summary>Retrieve the quality level for text.</summary>
  SCI_GETFONTQUALITY = 2612;

  /// <summary>Scroll so that a display line is at the top of the display.</summary>
  SCI_SETFIRSTVISIBLELINE = 2613;

  SC_MULTIPASTE_ONCE = 0;
  SC_MULTIPASTE_EACH = 1;

  /// <summary>Change the effect of pasting when there are multiple selections.</summary>
  SCI_SETMULTIPASTE = 2614;

  /// <summary>Retrieve the effect of pasting when there are multiple selections.</summary>
  SCI_GETMULTIPASTE = 2615;

  /// <summary>Retrieve the value of a tag from a regular expression search.
  /// Result is NUL-terminated.</summary>
  SCI_GETTAG = 2616;

  /// <summary>Join the lines in the target.</summary>
  SCI_LINESJOIN = 2288;

  /// <summary>Split the lines in the target into lines that are less wide than pixelWidth
  /// where possible.</summary>
  SCI_LINESSPLIT = 2289;

  /// <summary>Set one of the colours used as a chequerboard pattern in the fold margin</summary>
  SCI_SETFOLDMARGINCOLOUR = 2290;

  /// <summary>Set the other colour used as a chequerboard pattern in the fold margin</summary>
  SCI_SETFOLDMARGINHICOLOUR = 2291;

  SC_ACCESSIBILITY_DISABLED = 0;
  SC_ACCESSIBILITY_ENABLED = 1;

  /// <summary>Enable or disable accessibility.</summary>
  SCI_SETACCESSIBILITY = 2702;

  /// <summary>Report accessibility status.</summary>
  SCI_GETACCESSIBILITY = 2703;

  /// <summary>Move caret down one line.</summary>
  SCI_LINEDOWN = 2300;

  /// <summary>Move caret down one line extending selection to new caret position.</summary>
  SCI_LINEDOWNEXTEND = 2301;

  /// <summary>Move caret up one line.</summary>
  SCI_LINEUP = 2302;

  /// <summary>Move caret up one line extending selection to new caret position.</summary>
  SCI_LINEUPEXTEND = 2303;

  /// <summary>Move caret left one character.</summary>
  SCI_CHARLEFT = 2304;

  /// <summary>Move caret left one character extending selection to new caret position.</summary>
  SCI_CHARLEFTEXTEND = 2305;

  /// <summary>Move caret right one character.</summary>
  SCI_CHARRIGHT = 2306;

  /// <summary>Move caret right one character extending selection to new caret position.</summary>
  SCI_CHARRIGHTEXTEND = 2307;

  /// <summary>Move caret left one word.</summary>
  SCI_WORDLEFT = 2308;

  /// <summary>Move caret left one word extending selection to new caret position.</summary>
  SCI_WORDLEFTEXTEND = 2309;

  /// <summary>Move caret right one word.</summary>
  SCI_WORDRIGHT = 2310;

  /// <summary>Move caret right one word extending selection to new caret position.</summary>
  SCI_WORDRIGHTEXTEND = 2311;

  /// <summary>Move caret to first position on line.</summary>
  SCI_HOME = 2312;

  /// <summary>Move caret to first position on line extending selection to new caret position.</summary>
  SCI_HOMEEXTEND = 2313;

  /// <summary>Move caret to last position on line.</summary>
  SCI_LINEEND = 2314;

  /// <summary>Move caret to last position on line extending selection to new caret position.</summary>
  SCI_LINEENDEXTEND = 2315;

  /// <summary>Move caret to first position in document.</summary>
  SCI_DOCUMENTSTART = 2316;

  /// <summary>Move caret to first position in document extending selection to new caret position.</summary>
  SCI_DOCUMENTSTARTEXTEND = 2317;

  /// <summary>Move caret to last position in document.</summary>
  SCI_DOCUMENTEND = 2318;

  /// <summary>Move caret to last position in document extending selection to new caret position.</summary>
  SCI_DOCUMENTENDEXTEND = 2319;

  /// <summary>Move caret one page up.</summary>
  SCI_PAGEUP = 2320;

  /// <summary>Move caret one page up extending selection to new caret position.</summary>
  SCI_PAGEUPEXTEND = 2321;

  /// <summary>Move caret one page down.</summary>
  SCI_PAGEDOWN = 2322;

  /// <summary>Move caret one page down extending selection to new caret position.</summary>
  SCI_PAGEDOWNEXTEND = 2323;

  /// <summary>Switch from insert to overtype mode or the reverse.</summary>
  SCI_EDITTOGGLEOVERTYPE = 2324;

  /// <summary>Cancel any modes such as call tip or auto-completion list display.</summary>
  SCI_CANCEL = 2325;

  /// <summary>Delete the selection or if no selection, the character before the caret.</summary>
  SCI_DELETEBACK = 2326;

  /// <summary>If selection is empty or all on one line replace the selection with a tab character.
  /// If more than one line selected, indent the lines.</summary>
  SCI_TAB = 2327;

  /// <summary>Indent the current and selected lines.</summary>
  SCI_LINEINDENT = 2813;

  /// <summary>If selection is empty or all on one line dedent the line if caret is at start, else move caret.
  /// If more than one line selected, dedent the lines.</summary>
  SCI_BACKTAB = 2328;

  /// <summary>Dedent the current and selected lines.</summary>
  SCI_LINEDEDENT = 2814;

  /// <summary>Insert a new line, may use a CRLF, CR or LF depending on EOL mode.</summary>
  SCI_NEWLINE = 2329;

  /// <summary>Insert a Form Feed character.</summary>
  SCI_FORMFEED = 2330;

  /// <summary>Move caret to before first visible character on line.
  /// If already there move to first character on line.</summary>
  SCI_VCHOME = 2331;

  /// <summary>Like VCHome but extending selection to new caret position.</summary>
  SCI_VCHOMEEXTEND = 2332;

  /// <summary>Magnify the displayed text by increasing the sizes by 1 point.</summary>
  SCI_ZOOMIN = 2333;

  /// <summary>Make the displayed text smaller by decreasing the sizes by 1 point.</summary>
  SCI_ZOOMOUT = 2334;

  /// <summary>Delete the word to the left of the caret.</summary>
  SCI_DELWORDLEFT = 2335;

  /// <summary>Delete the word to the right of the caret.</summary>
  SCI_DELWORDRIGHT = 2336;

  /// <summary>Delete the word to the right of the caret, but not the trailing non-word characters.</summary>
  SCI_DELWORDRIGHTEND = 2518;

  /// <summary>Cut the line containing the caret.</summary>
  SCI_LINECUT = 2337;

  /// <summary>Delete the line containing the caret.</summary>
  SCI_LINEDELETE = 2338;

  /// <summary>Switch the current line with the previous.</summary>
  SCI_LINETRANSPOSE = 2339;

  /// <summary>Reverse order of selected lines.</summary>
  SCI_LINEREVERSE = 2354;

  /// <summary>Duplicate the current line.</summary>
  SCI_LINEDUPLICATE = 2404;

  /// <summary>Transform the selection to lower case.</summary>
  SCI_LOWERCASE = 2340;

  /// <summary>Transform the selection to upper case.</summary>
  SCI_UPPERCASE = 2341;

  /// <summary>Scroll the document down, keeping the caret visible.</summary>
  SCI_LINESCROLLDOWN = 2342;

  /// <summary>Scroll the document up, keeping the caret visible.</summary>
  SCI_LINESCROLLUP = 2343;

  /// <summary>Delete the selection or if no selection, the character before the caret.
  /// Will not delete the character before at the start of a line.</summary>
  SCI_DELETEBACKNOTLINE = 2344;

  /// <summary>Move caret to first position on display line.</summary>
  SCI_HOMEDISPLAY = 2345;

  /// <summary>Move caret to first position on display line extending selection to
  /// new caret position.</summary>
  SCI_HOMEDISPLAYEXTEND = 2346;

  /// <summary>Move caret to last position on display line.</summary>
  SCI_LINEENDDISPLAY = 2347;

  /// <summary>Move caret to last position on display line extending selection to new
  /// caret position.</summary>
  SCI_LINEENDDISPLAYEXTEND = 2348;

  /// <summary>Like Home but when word-wrap is enabled goes first to start of display line
  /// HomeDisplay, then to start of document line Home.</summary>
  SCI_HOMEWRAP = 2349;

  /// <summary>Like HomeExtend but when word-wrap is enabled extends first to start of display line
  /// HomeDisplayExtend, then to start of document line HomeExtend.</summary>
  SCI_HOMEWRAPEXTEND = 2450;

  /// <summary>Like LineEnd but when word-wrap is enabled goes first to end of display line
  /// LineEndDisplay, then to start of document line LineEnd.</summary>
  SCI_LINEENDWRAP = 2451;

  /// <summary>Like LineEndExtend but when word-wrap is enabled extends first to end of display line
  /// LineEndDisplayExtend, then to start of document line LineEndExtend.</summary>
  SCI_LINEENDWRAPEXTEND = 2452;

  /// <summary>Like VCHome but when word-wrap is enabled goes first to start of display line
  /// VCHomeDisplay, then behaves like VCHome.</summary>
  SCI_VCHOMEWRAP = 2453;

  /// <summary>Like VCHomeExtend but when word-wrap is enabled extends first to start of display line
  /// VCHomeDisplayExtend, then behaves like VCHomeExtend.</summary>
  SCI_VCHOMEWRAPEXTEND = 2454;

  /// <summary>Copy the line containing the caret.</summary>
  SCI_LINECOPY = 2455;

  /// <summary>Move the caret inside current view if it's not there already.</summary>
  SCI_MOVECARETINSIDEVIEW = 2401;

  /// <summary>How many characters are on a line, including end of line characters?</summary>
  SCI_LINELENGTH = 2350;

  /// <summary>Highlight the characters at two positions.</summary>
  SCI_BRACEHIGHLIGHT = 2351;

  /// <summary>Use specified indicator to highlight matching braces instead of changing their style.</summary>
  SCI_BRACEHIGHLIGHTINDICATOR = 2498;

  /// <summary>Highlight the character at a position indicating there is no matching brace.</summary>
  SCI_BRACEBADLIGHT = 2352;

  /// <summary>Use specified indicator to highlight non matching brace instead of changing its style.</summary>
  SCI_BRACEBADLIGHTINDICATOR = 2499;

  /// <summary>Find the position of a matching brace or INVALID_POSITION if no match.
  /// The maxReStyle must be 0 for now. It may be defined in a future release.</summary>
  SCI_BRACEMATCH = 2353;

  /// <summary>Similar to BraceMatch, but matching starts at the explicit start position.</summary>
  SCI_BRACEMATCHNEXT = 2369;

  /// <summary>Are the end of line characters visible?</summary>
  SCI_GETVIEWEOL = 2355;

  /// <summary>Make the end of line characters visible or invisible.</summary>
  SCI_SETVIEWEOL = 2356;

  /// <summary>Retrieve a pointer to the document object.</summary>
  SCI_GETDOCPOINTER = 2357;

  /// <summary>Change the document object used.</summary>
  SCI_SETDOCPOINTER = 2358;

  /// <summary>Set which document modification events are sent to the container.</summary>
  SCI_SETMODEVENTMASK = 2359;

  EDGE_NONE = 0;
  EDGE_LINE = 1;
  EDGE_BACKGROUND = 2;
  EDGE_MULTILINE = 3;

  /// <summary>Retrieve the column number which text should be kept within.</summary>
  SCI_GETEDGECOLUMN = 2360;

  /// <summary>Set the column number of the edge.
  /// If text goes past the edge then it is highlighted.</summary>
  SCI_SETEDGECOLUMN = 2361;

  /// <summary>Retrieve the edge highlight mode.</summary>
  SCI_GETEDGEMODE = 2362;

  /// <summary>The edge may be displayed by a line (EDGE_LINE/EDGE_MULTILINE) or by highlighting text that
  /// goes beyond it (EDGE_BACKGROUND) or not displayed at all (EDGE_NONE).</summary>
  SCI_SETEDGEMODE = 2363;

  /// <summary>Retrieve the colour used in edge indication.</summary>
  SCI_GETEDGECOLOUR = 2364;

  /// <summary>Change the colour used in edge indication.</summary>
  SCI_SETEDGECOLOUR = 2365;

  /// <summary>Add a new vertical edge to the view.</summary>
  SCI_MULTIEDGEADDLINE = 2694;

  /// <summary>Clear all vertical edges.</summary>
  SCI_MULTIEDGECLEARALL = 2695;

  /// <summary>Get multi edge positions.</summary>
  SCI_GETMULTIEDGECOLUMN = 2749;

  /// <summary>Sets the current caret position to be the search anchor.</summary>
  SCI_SEARCHANCHOR = 2366;

  /// <summary>Find some text starting at the search anchor.
  /// Does not ensure the selection is visible.</summary>
  SCI_SEARCHNEXT = 2367;

  /// <summary>Find some text starting at the search anchor and moving backwards.
  /// Does not ensure the selection is visible.</summary>
  SCI_SEARCHPREV = 2368;

  /// <summary>Retrieves the number of lines completely visible.</summary>
  SCI_LINESONSCREEN = 2370;

  SC_POPUP_NEVER = 0;
  SC_POPUP_ALL = 1;
  SC_POPUP_TEXT = 2;

  /// <summary>Set whether a pop up menu is displayed automatically when the user presses
  /// the wrong mouse button on certain areas.</summary>
  SCI_USEPOPUP = 2371;

  /// <summary>Is the selection rectangular? The alternative is the more common stream selection.</summary>
  SCI_SELECTIONISRECTANGLE = 2372;

  /// <summary>Set the zoom level. This number of points is added to the size of all fonts.
  /// It may be positive to magnify or negative to reduce.</summary>
  SCI_SETZOOM = 2373;

  /// <summary>Retrieve the zoom level.</summary>
  SCI_GETZOOM = 2374;

  SC_DOCUMENTOPTION_DEFAULT = 0;
  SC_DOCUMENTOPTION_STYLES_NONE = $1;
  SC_DOCUMENTOPTION_TEXT_LARGE = $100;

  /// <summary>Create a new document object.
  /// Starts with reference count of 1 and not selected into editor.</summary>
  SCI_CREATEDOCUMENT = 2375;

  /// <summary>Extend life of document.</summary>
  SCI_ADDREFDOCUMENT = 2376;

  /// <summary>Release a reference to the document, deleting document if it fades to black.</summary>
  SCI_RELEASEDOCUMENT = 2377;

  /// <summary>Get which document options are set.</summary>
  SCI_GETDOCUMENTOPTIONS = 2379;

  /// <summary>Get which document modification events are sent to the container.</summary>
  SCI_GETMODEVENTMASK = 2378;

  /// <summary>Set whether command events are sent to the container.</summary>
  SCI_SETCOMMANDEVENTS = 2717;

  /// <summary>Get whether command events are sent to the container.</summary>
  SCI_GETCOMMANDEVENTS = 2718;

  /// <summary>Change internal focus flag.</summary>
  SCI_SETFOCUS = 2380;

  /// <summary>Get internal focus flag.</summary>
  SCI_GETFOCUS = 2381;

  SC_STATUS_OK = 0;
  SC_STATUS_FAILURE = 1;
  SC_STATUS_BADALLOC = 2;
  SC_STATUS_WARN_START = 1000;
  SC_STATUS_WARN_REGEX = 1001;

  /// <summary>Change error status - 0 = OK.</summary>
  SCI_SETSTATUS = 2382;

  /// <summary>Get error status.</summary>
  SCI_GETSTATUS = 2383;

  /// <summary>Set whether the mouse is captured when its button is pressed.</summary>
  SCI_SETMOUSEDOWNCAPTURES = 2384;

  /// <summary>Get whether mouse gets captured.</summary>
  SCI_GETMOUSEDOWNCAPTURES = 2385;

  /// <summary>Set whether the mouse wheel can be active outside the window.</summary>
  SCI_SETMOUSEWHEELCAPTURES = 2696;

  /// <summary>Get whether mouse wheel can be active outside the window.</summary>
  SCI_GETMOUSEWHEELCAPTURES = 2697;

  /// <summary>Sets the cursor to one of the SC_CURSOR* values.</summary>
  SCI_SETCURSOR = 2386;

  /// <summary>Get cursor type.</summary>
  SCI_GETCURSOR = 2387;

  /// <summary>Change the way control characters are displayed:
  /// If symbol is &lt; 32, keep the drawn way, else, use the given character.</summary>
  SCI_SETCONTROLCHARSYMBOL = 2388;

  /// <summary>Get the way control characters are displayed.</summary>
  SCI_GETCONTROLCHARSYMBOL = 2389;

  /// <summary>Move to the previous change in capitalisation.</summary>
  SCI_WORDPARTLEFT = 2390;

  /// <summary>Move to the previous change in capitalisation extending selection
  /// to new caret position.</summary>
  SCI_WORDPARTLEFTEXTEND = 2391;

  /// <summary>Move to the change next in capitalisation.</summary>
  SCI_WORDPARTRIGHT = 2392;

  /// <summary>Move to the next change in capitalisation extending selection
  /// to new caret position.</summary>
  SCI_WORDPARTRIGHTEXTEND = 2393;

  /// <summary>Constants for use with SetVisiblePolicy, similar to SetCaretPolicy.</summary>
  VISIBLE_SLOP = $01;
  VISIBLE_STRICT = $04;

  /// <summary>Set the way the display area is determined when a particular line
  /// is to be moved to by Find, FindNext, GotoLine, etc.</summary>
  SCI_SETVISIBLEPOLICY = 2394;

  /// <summary>Delete back from the current position to the start of the line.</summary>
  SCI_DELLINELEFT = 2395;

  /// <summary>Delete forwards from the current position to the end of the line.</summary>
  SCI_DELLINERIGHT = 2396;

  /// <summary>Set the xOffset (ie, horizontal scroll position).</summary>
  SCI_SETXOFFSET = 2397;

  /// <summary>Get the xOffset (ie, horizontal scroll position).</summary>
  SCI_GETXOFFSET = 2398;

  /// <summary>Set the last x chosen value to be the caret x position.</summary>
  SCI_CHOOSECARETX = 2399;

  /// <summary>Set the focus to this Scintilla widget.</summary>
  SCI_GRABFOCUS = 2400;

  /// <summary>Caret policy, used by SetXCaretPolicy and SetYCaretPolicy.
  /// If CARET_SLOP is set, we can define a slop value: caretSlop.
  /// This value defines an unwanted zone (UZ) where the caret is... unwanted.
  /// This zone is defined as a number of pixels near the vertical margins,
  /// and as a number of lines near the horizontal margins.
  /// By keeping the caret away from the edges, it is seen within its context,
  /// so it is likely that the identifier that the caret is on can be completely seen,
  /// and that the current line is seen with some of the lines following it which are
  /// often dependent on that line.</summary>
  CARET_SLOP = $01;

  /// <summary>If CARET_STRICT is set, the policy is enforced... strictly.
  /// The caret is centred on the display if slop is not set,
  /// and cannot go in the UZ if slop is set.</summary>
  CARET_STRICT = $04;

  /// <summary>If CARET_JUMPS is set, the display is moved more energetically
  /// so the caret can move in the same direction longer before the policy is applied again.</summary>
  CARET_JUMPS = $10;

  /// <summary>If CARET_EVEN is not set, instead of having symmetrical UZs,
  /// the left and bottom UZs are extended up to right and top UZs respectively.
  /// This way, we favour the displaying of useful information: the beginning of lines,
  /// where most code reside, and the lines after the caret, eg. the body of a function.</summary>
  CARET_EVEN = $08;

  /// <summary>Set the way the caret is kept visible when going sideways.
  /// The exclusion zone is given in pixels.</summary>
  SCI_SETXCARETPOLICY = 2402;

  /// <summary>Set the way the line the caret is on is kept visible.
  /// The exclusion zone is given in lines.</summary>
  SCI_SETYCARETPOLICY = 2403;

  /// <summary>Set printing to line wrapped (SC_WRAP_WORD) or not line wrapped (SC_WRAP_NONE).</summary>
  SCI_SETPRINTWRAPMODE = 2406;

  /// <summary>Is printing line wrapped?</summary>
  SCI_GETPRINTWRAPMODE = 2407;

  /// <summary>Set a fore colour for active hotspots.</summary>
  SCI_SETHOTSPOTACTIVEFORE = 2410;

  /// <summary>Get the fore colour for active hotspots.</summary>
  SCI_GETHOTSPOTACTIVEFORE = 2494;

  /// <summary>Set a back colour for active hotspots.</summary>
  SCI_SETHOTSPOTACTIVEBACK = 2411;

  /// <summary>Get the back colour for active hotspots.</summary>
  SCI_GETHOTSPOTACTIVEBACK = 2495;

  /// <summary>Enable / Disable underlining active hotspots.</summary>
  SCI_SETHOTSPOTACTIVEUNDERLINE = 2412;

  /// <summary>Get whether underlining for active hotspots.</summary>
  SCI_GETHOTSPOTACTIVEUNDERLINE = 2496;

  /// <summary>Limit hotspots to single line so hotspots on two lines don't merge.</summary>
  SCI_SETHOTSPOTSINGLELINE = 2421;

  /// <summary>Get the HotspotSingleLine property</summary>
  SCI_GETHOTSPOTSINGLELINE = 2497;

  /// <summary>Move caret down one paragraph (delimited by empty lines).</summary>
  SCI_PARADOWN = 2413;

  /// <summary>Extend selection down one paragraph (delimited by empty lines).</summary>
  SCI_PARADOWNEXTEND = 2414;

  /// <summary>Move caret up one paragraph (delimited by empty lines).</summary>
  SCI_PARAUP = 2415;

  /// <summary>Extend selection up one paragraph (delimited by empty lines).</summary>
  SCI_PARAUPEXTEND = 2416;

  /// <summary>Given a valid document position, return the previous position taking code
  /// page into account. Returns 0 if passed 0.</summary>
  SCI_POSITIONBEFORE = 2417;

  /// <summary>Given a valid document position, return the next position taking code
  /// page into account. Maximum value returned is the last position in the document.</summary>
  SCI_POSITIONAFTER = 2418;

  /// <summary>Given a valid document position, return a position that differs in a number
  /// of characters. Returned value is always between 0 and last position in document.</summary>
  SCI_POSITIONRELATIVE = 2670;

  /// <summary>Given a valid document position, return a position that differs in a number
  /// of UTF-16 code units. Returned value is always between 0 and last position in document.
  /// The result may point half way (2 bytes) inside a non-BMP character.</summary>
  SCI_POSITIONRELATIVECODEUNITS = 2716;

  /// <summary>Copy a range of text to the clipboard. Positions are clipped into the document.</summary>
  SCI_COPYRANGE = 2419;

  /// <summary>Copy argument text to the clipboard.</summary>
  SCI_COPYTEXT = 2420;

  SC_SEL_STREAM = 0;
  SC_SEL_RECTANGLE = 1;
  SC_SEL_LINES = 2;
  SC_SEL_THIN = 3;

  /// <summary>Set the selection mode to stream (SC_SEL_STREAM) or rectangular (SC_SEL_RECTANGLE/SC_SEL_THIN) or
  /// by lines (SC_SEL_LINES).</summary>
  SCI_SETSELECTIONMODE = 2422;

  /// <summary>Set the selection mode to stream (SC_SEL_STREAM) or rectangular (SC_SEL_RECTANGLE/SC_SEL_THIN) or
  /// by lines (SC_SEL_LINES) without changing MoveExtendsSelection.</summary>
  SCI_CHANGESELECTIONMODE = 2659;

  /// <summary>Get the mode of the current selection.</summary>
  SCI_GETSELECTIONMODE = 2423;

  /// <summary>Set whether or not regular caret moves will extend or reduce the selection.</summary>
  SCI_SETMOVEEXTENDSSELECTION = 2719;

  /// <summary>Get whether or not regular caret moves will extend or reduce the selection.</summary>
  SCI_GETMOVEEXTENDSSELECTION = 2706;

  /// <summary>Retrieve the position of the start of the selection at the given line (INVALID_POSITION if no selection on this line).</summary>
  SCI_GETLINESELSTARTPOSITION = 2424;

  /// <summary>Retrieve the position of the end of the selection at the given line (INVALID_POSITION if no selection on this line).</summary>
  SCI_GETLINESELENDPOSITION = 2425;

  /// <summary>Move caret down one line, extending rectangular selection to new caret position.</summary>
  SCI_LINEDOWNRECTEXTEND = 2426;

  /// <summary>Move caret up one line, extending rectangular selection to new caret position.</summary>
  SCI_LINEUPRECTEXTEND = 2427;

  /// <summary>Move caret left one character, extending rectangular selection to new caret position.</summary>
  SCI_CHARLEFTRECTEXTEND = 2428;

  /// <summary>Move caret right one character, extending rectangular selection to new caret position.</summary>
  SCI_CHARRIGHTRECTEXTEND = 2429;

  /// <summary>Move caret to first position on line, extending rectangular selection to new caret position.</summary>
  SCI_HOMERECTEXTEND = 2430;

  /// <summary>Move caret to before first visible character on line.
  /// If already there move to first character on line.
  /// In either case, extend rectangular selection to new caret position.</summary>
  SCI_VCHOMERECTEXTEND = 2431;

  /// <summary>Move caret to last position on line, extending rectangular selection to new caret position.</summary>
  SCI_LINEENDRECTEXTEND = 2432;

  /// <summary>Move caret one page up, extending rectangular selection to new caret position.</summary>
  SCI_PAGEUPRECTEXTEND = 2433;

  /// <summary>Move caret one page down, extending rectangular selection to new caret position.</summary>
  SCI_PAGEDOWNRECTEXTEND = 2434;

  /// <summary>Move caret to top of page, or one page up if already at top of page.</summary>
  SCI_STUTTEREDPAGEUP = 2435;

  /// <summary>Move caret to top of page, or one page up if already at top of page, extending selection to new caret position.</summary>
  SCI_STUTTEREDPAGEUPEXTEND = 2436;

  /// <summary>Move caret to bottom of page, or one page down if already at bottom of page.</summary>
  SCI_STUTTEREDPAGEDOWN = 2437;

  /// <summary>Move caret to bottom of page, or one page down if already at bottom of page, extending selection to new caret position.</summary>
  SCI_STUTTEREDPAGEDOWNEXTEND = 2438;

  /// <summary>Move caret left one word, position cursor at end of word.</summary>
  SCI_WORDLEFTEND = 2439;

  /// <summary>Move caret left one word, position cursor at end of word, extending selection to new caret position.</summary>
  SCI_WORDLEFTENDEXTEND = 2440;

  /// <summary>Move caret right one word, position cursor at end of word.</summary>
  SCI_WORDRIGHTEND = 2441;

  /// <summary>Move caret right one word, position cursor at end of word, extending selection to new caret position.</summary>
  SCI_WORDRIGHTENDEXTEND = 2442;

  /// <summary>Set the set of characters making up whitespace for when moving or selecting by word.
  /// Should be called after SetWordChars.</summary>
  SCI_SETWHITESPACECHARS = 2443;

  /// <summary>Get the set of characters making up whitespace for when moving or selecting by word.</summary>
  SCI_GETWHITESPACECHARS = 2647;

  /// <summary>Set the set of characters making up punctuation characters
  /// Should be called after SetWordChars.</summary>
  SCI_SETPUNCTUATIONCHARS = 2648;

  /// <summary>Get the set of characters making up punctuation characters</summary>
  SCI_GETPUNCTUATIONCHARS = 2649;

  /// <summary>Reset the set of characters for whitespace and word characters to the defaults.</summary>
  SCI_SETCHARSDEFAULT = 2444;

  /// <summary>Get currently selected item position in the auto-completion list</summary>
  SCI_AUTOCGETCURRENT = 2445;

  /// <summary>Get currently selected item text in the auto-completion list
  /// Returns the length of the item text
  /// Result is NUL-terminated.</summary>
  SCI_AUTOCGETCURRENTTEXT = 2610;

  SC_CASEINSENSITIVEBEHAVIOUR_RESPECTCASE = 0;
  SC_CASEINSENSITIVEBEHAVIOUR_IGNORECASE = 1;

  /// <summary>Set auto-completion case insensitive behaviour to either prefer case-sensitive matches or have no preference.</summary>
  SCI_AUTOCSETCASEINSENSITIVEBEHAVIOUR = 2634;

  /// <summary>Get auto-completion case insensitive behaviour.</summary>
  SCI_AUTOCGETCASEINSENSITIVEBEHAVIOUR = 2635;

  SC_MULTIAUTOC_ONCE = 0;
  SC_MULTIAUTOC_EACH = 1;

  /// <summary>Change the effect of autocompleting when there are multiple selections.</summary>
  SCI_AUTOCSETMULTI = 2636;

  /// <summary>Retrieve the effect of autocompleting when there are multiple selections.</summary>
  SCI_AUTOCGETMULTI = 2637;

  SC_ORDER_PRESORTED = 0;
  SC_ORDER_PERFORMSORT = 1;
  SC_ORDER_CUSTOM = 2;

  /// <summary>Set the way autocompletion lists are ordered.</summary>
  SCI_AUTOCSETORDER = 2660;

  /// <summary>Get the way autocompletion lists are ordered.</summary>
  SCI_AUTOCGETORDER = 2661;

  /// <summary>Enlarge the document to a particular size of text bytes.</summary>
  SCI_ALLOCATE = 2446;

  /// <summary>Returns the target converted to UTF8.
  /// Return the length in bytes.</summary>
  SCI_TARGETASUTF8 = 2447;

  /// <summary>Set the length of the utf8 argument for calling EncodedFromUTF8.
  /// Set to -1 and the string will be measured to the first nul.</summary>
  SCI_SETLENGTHFORENCODE = 2448;

  /// <summary>Translates a UTF8 string into the document encoding.
  /// Return the length of the result in bytes.
  /// On error return 0.</summary>
  SCI_ENCODEDFROMUTF8 = 2449;

  /// <summary>Find the position of a column on a line taking into account tabs and
  /// multi-byte characters. If beyond end of line, return line end position.</summary>
  SCI_FINDCOLUMN = 2456;

  SC_CARETSTICKY_OFF = 0;
  SC_CARETSTICKY_ON = 1;
  SC_CARETSTICKY_WHITESPACE = 2;

  /// <summary>Can the caret preferred x position only be changed by explicit movement commands?</summary>
  SCI_GETCARETSTICKY = 2457;

  /// <summary>Stop the caret preferred x position changing when the user types.</summary>
  SCI_SETCARETSTICKY = 2458;

  /// <summary>Switch between sticky and non-sticky: meant to be bound to a key.</summary>
  SCI_TOGGLECARETSTICKY = 2459;

  /// <summary>Enable/Disable convert-on-paste for line endings</summary>
  SCI_SETPASTECONVERTENDINGS = 2467;

  /// <summary>Get convert-on-paste setting</summary>
  SCI_GETPASTECONVERTENDINGS = 2468;

  /// <summary>Replace the selection with text like a rectangular paste.</summary>
  SCI_REPLACERECTANGULAR = 2771;

  /// <summary>Duplicate the selection. If selection empty duplicate the line containing the caret.</summary>
  SCI_SELECTIONDUPLICATE = 2469;

  /// <summary>Set background alpha of the caret line.</summary>
  SCI_SETCARETLINEBACKALPHA = 2470;

  /// <summary>Get the background alpha of the caret line.</summary>
  SCI_GETCARETLINEBACKALPHA = 2471;

  CARETSTYLE_INVISIBLE = 0;
  CARETSTYLE_LINE = 1;
  CARETSTYLE_BLOCK = 2;
  CARETSTYLE_OVERSTRIKE_BAR = 0;
  CARETSTYLE_OVERSTRIKE_BLOCK = $10;
  CARETSTYLE_CURSES = $20;
  CARETSTYLE_INS_MASK = $F;
  CARETSTYLE_BLOCK_AFTER = $100;

  /// <summary>Set the style of the caret to be drawn.</summary>
  SCI_SETCARETSTYLE = 2512;

  /// <summary>Returns the current style of the caret.</summary>
  SCI_GETCARETSTYLE = 2513;

  /// <summary>Set the indicator used for IndicatorFillRange and IndicatorClearRange</summary>
  SCI_SETINDICATORCURRENT = 2500;

  /// <summary>Get the current indicator</summary>
  SCI_GETINDICATORCURRENT = 2501;

  /// <summary>Set the value used for IndicatorFillRange</summary>
  SCI_SETINDICATORVALUE = 2502;

  /// <summary>Get the current indicator value</summary>
  SCI_GETINDICATORVALUE = 2503;

  /// <summary>Turn a indicator on over a range.</summary>
  SCI_INDICATORFILLRANGE = 2504;

  /// <summary>Turn a indicator off over a range.</summary>
  SCI_INDICATORCLEARRANGE = 2505;

  /// <summary>Are any indicators present at pos?</summary>
  SCI_INDICATORALLONFOR = 2506;

  /// <summary>What value does a particular indicator have at a position?</summary>
  SCI_INDICATORVALUEAT = 2507;

  /// <summary>Where does a particular indicator start?</summary>
  SCI_INDICATORSTART = 2508;

  /// <summary>Where does a particular indicator end?</summary>
  SCI_INDICATOREND = 2509;

  /// <summary>Set number of entries in position cache</summary>
  SCI_SETPOSITIONCACHE = 2514;

  /// <summary>How many entries are allocated to the position cache?</summary>
  SCI_GETPOSITIONCACHE = 2515;

  /// <summary>Set maximum number of threads used for layout</summary>
  SCI_SETLAYOUTTHREADS = 2775;

  /// <summary>Get maximum number of threads used for layout</summary>
  SCI_GETLAYOUTTHREADS = 2776;

  /// <summary>Copy the selection, if selection empty copy the line with the caret</summary>
  SCI_COPYALLOWLINE = 2519;

  /// <summary>Cut the selection, if selection empty cut the line with the caret</summary>
  SCI_CUTALLOWLINE = 2810;

  /// <summary>Set the string to separate parts when copying a multiple selection.</summary>
  SCI_SETCOPYSEPARATOR = 2811;

  /// <summary>Get the string to separate parts when copying a multiple selection.</summary>
  SCI_GETCOPYSEPARATOR = 2812;

  /// <summary>Compact the document buffer and return a read-only pointer to the
  /// characters in the document.</summary>
  SCI_GETCHARACTERPOINTER = 2520;

  /// <summary>Return a read-only pointer to a range of characters in the document.
  /// May move the gap so that the range is contiguous, but will only move up
  /// to lengthRange bytes.</summary>
  SCI_GETRANGEPOINTER = 2643;

  /// <summary>Return a position which, to avoid performance costs, should not be within
  /// the range of a call to GetRangePointer.</summary>
  SCI_GETGAPPOSITION = 2644;

  /// <summary>Set the alpha fill colour of the given indicator.</summary>
  SCI_INDICSETALPHA = 2523;

  /// <summary>Get the alpha fill colour of the given indicator.</summary>
  SCI_INDICGETALPHA = 2524;

  /// <summary>Set the alpha outline colour of the given indicator.</summary>
  SCI_INDICSETOUTLINEALPHA = 2558;

  /// <summary>Get the alpha outline colour of the given indicator.</summary>
  SCI_INDICGETOUTLINEALPHA = 2559;

  /// <summary>Set extra ascent for each line</summary>
  SCI_SETEXTRAASCENT = 2525;

  /// <summary>Get extra ascent for each line</summary>
  SCI_GETEXTRAASCENT = 2526;

  /// <summary>Set extra descent for each line</summary>
  SCI_SETEXTRADESCENT = 2527;

  /// <summary>Get extra descent for each line</summary>
  SCI_GETEXTRADESCENT = 2528;

  /// <summary>Which symbol was defined for markerNumber with MarkerDefine</summary>
  SCI_MARKERSYMBOLDEFINED = 2529;

  /// <summary>Set the text in the text margin for a line</summary>
  SCI_MARGINSETTEXT = 2530;

  /// <summary>Get the text in the text margin for a line</summary>
  SCI_MARGINGETTEXT = 2531;

  /// <summary>Set the style number for the text margin for a line</summary>
  SCI_MARGINSETSTYLE = 2532;

  /// <summary>Get the style number for the text margin for a line</summary>
  SCI_MARGINGETSTYLE = 2533;

  /// <summary>Set the style in the text margin for a line</summary>
  SCI_MARGINSETSTYLES = 2534;

  /// <summary>Get the styles in the text margin for a line</summary>
  SCI_MARGINGETSTYLES = 2535;

  /// <summary>Clear the margin text on all lines</summary>
  SCI_MARGINTEXTCLEARALL = 2536;

  /// <summary>Get the start of the range of style numbers used for margin text</summary>
  SCI_MARGINSETSTYLEOFFSET = 2537;

  /// <summary>Get the start of the range of style numbers used for margin text</summary>
  SCI_MARGINGETSTYLEOFFSET = 2538;

  SC_MARGINOPTION_NONE = 0;
  SC_MARGINOPTION_SUBLINESELECT = 1;

  /// <summary>Set the margin options.</summary>
  SCI_SETMARGINOPTIONS = 2539;

  /// <summary>Get the margin options.</summary>
  SCI_GETMARGINOPTIONS = 2557;

  /// <summary>Set the annotation text for a line</summary>
  SCI_ANNOTATIONSETTEXT = 2540;

  /// <summary>Get the annotation text for a line</summary>
  SCI_ANNOTATIONGETTEXT = 2541;

  /// <summary>Set the style number for the annotations for a line</summary>
  SCI_ANNOTATIONSETSTYLE = 2542;

  /// <summary>Get the style number for the annotations for a line</summary>
  SCI_ANNOTATIONGETSTYLE = 2543;

  /// <summary>Set the annotation styles for a line</summary>
  SCI_ANNOTATIONSETSTYLES = 2544;

  /// <summary>Get the annotation styles for a line</summary>
  SCI_ANNOTATIONGETSTYLES = 2545;

  /// <summary>Get the number of annotation lines for a line</summary>
  SCI_ANNOTATIONGETLINES = 2546;

  /// <summary>Clear the annotations from all lines</summary>
  SCI_ANNOTATIONCLEARALL = 2547;

  ANNOTATION_HIDDEN = 0;
  ANNOTATION_STANDARD = 1;
  ANNOTATION_BOXED = 2;
  ANNOTATION_INDENTED = 3;

  /// <summary>Set the visibility for the annotations for a view</summary>
  SCI_ANNOTATIONSETVISIBLE = 2548;

  /// <summary>Get the visibility for the annotations for a view</summary>
  SCI_ANNOTATIONGETVISIBLE = 2549;

  /// <summary>Get the start of the range of style numbers used for annotations</summary>
  SCI_ANNOTATIONSETSTYLEOFFSET = 2550;

  /// <summary>Get the start of the range of style numbers used for annotations</summary>
  SCI_ANNOTATIONGETSTYLEOFFSET = 2551;

  /// <summary>Release all extended (&gt;255) style numbers</summary>
  SCI_RELEASEALLEXTENDEDSTYLES = 2552;

  /// <summary>Allocate some extended (&gt;255) style numbers and return the start of the range</summary>
  SCI_ALLOCATEEXTENDEDSTYLES = 2553;

  UNDO_NONE = 0;
  UNDO_MAY_COALESCE = 1;

  /// <summary>Add a container action to the undo stack</summary>
  SCI_ADDUNDOACTION = 2560;

  /// <summary>Find the position of a character from a point within the window.</summary>
  SCI_CHARPOSITIONFROMPOINT = 2561;

  /// <summary>Find the position of a character from a point within the window.
  /// Return INVALID_POSITION if not close to text.</summary>
  SCI_CHARPOSITIONFROMPOINTCLOSE = 2562;

  /// <summary>Set whether switching to rectangular mode while selecting with the mouse is allowed.</summary>
  SCI_SETMOUSESELECTIONRECTANGULARSWITCH = 2668;

  /// <summary>Whether switching to rectangular mode while selecting with the mouse is allowed.</summary>
  SCI_GETMOUSESELECTIONRECTANGULARSWITCH = 2669;

  /// <summary>Set whether multiple selections can be made</summary>
  SCI_SETMULTIPLESELECTION = 2563;

  /// <summary>Whether multiple selections can be made</summary>
  SCI_GETMULTIPLESELECTION = 2564;

  /// <summary>Set whether typing can be performed into multiple selections</summary>
  SCI_SETADDITIONALSELECTIONTYPING = 2565;

  /// <summary>Whether typing can be performed into multiple selections</summary>
  SCI_GETADDITIONALSELECTIONTYPING = 2566;

  /// <summary>Set whether additional carets will blink</summary>
  SCI_SETADDITIONALCARETSBLINK = 2567;

  /// <summary>Whether additional carets will blink</summary>
  SCI_GETADDITIONALCARETSBLINK = 2568;

  /// <summary>Set whether additional carets are visible</summary>
  SCI_SETADDITIONALCARETSVISIBLE = 2608;

  /// <summary>Whether additional carets are visible</summary>
  SCI_GETADDITIONALCARETSVISIBLE = 2609;

  /// <summary>How many selections are there?</summary>
  SCI_GETSELECTIONS = 2570;

  /// <summary>Is every selected range empty?</summary>
  SCI_GETSELECTIONEMPTY = 2650;

  /// <summary>Clear selections to a single empty stream selection</summary>
  SCI_CLEARSELECTIONS = 2571;

  /// <summary>Set a simple selection</summary>
  SCI_SETSELECTION = 2572;

  /// <summary>Add a selection</summary>
  SCI_ADDSELECTION = 2573;

  /// <summary>Find the selection index for a point. -1 when not at a selection.</summary>
  SCI_SELECTIONFROMPOINT = 2474;

  /// <summary>Drop one selection</summary>
  SCI_DROPSELECTIONN = 2671;

  /// <summary>Set the main selection</summary>
  SCI_SETMAINSELECTION = 2574;

  /// <summary>Which selection is the main selection</summary>
  SCI_GETMAINSELECTION = 2575;

  /// <summary>Set the caret position of the nth selection.</summary>
  SCI_SETSELECTIONNCARET = 2576;

  /// <summary>Return the caret position of the nth selection.</summary>
  SCI_GETSELECTIONNCARET = 2577;

  /// <summary>Set the anchor position of the nth selection.</summary>
  SCI_SETSELECTIONNANCHOR = 2578;

  /// <summary>Return the anchor position of the nth selection.</summary>
  SCI_GETSELECTIONNANCHOR = 2579;

  /// <summary>Set the virtual space of the caret of the nth selection.</summary>
  SCI_SETSELECTIONNCARETVIRTUALSPACE = 2580;

  /// <summary>Return the virtual space of the caret of the nth selection.</summary>
  SCI_GETSELECTIONNCARETVIRTUALSPACE = 2581;

  /// <summary>Set the virtual space of the anchor of the nth selection.</summary>
  SCI_SETSELECTIONNANCHORVIRTUALSPACE = 2582;

  /// <summary>Return the virtual space of the anchor of the nth selection.</summary>
  SCI_GETSELECTIONNANCHORVIRTUALSPACE = 2583;

  /// <summary>Sets the position that starts the selection - this becomes the anchor.</summary>
  SCI_SETSELECTIONNSTART = 2584;

  /// <summary>Returns the position at the start of the selection.</summary>
  SCI_GETSELECTIONNSTART = 2585;

  /// <summary>Returns the virtual space at the start of the selection.</summary>
  SCI_GETSELECTIONNSTARTVIRTUALSPACE = 2726;

  /// <summary>Sets the position that ends the selection - this becomes the currentPosition.</summary>
  SCI_SETSELECTIONNEND = 2586;

  /// <summary>Returns the virtual space at the end of the selection.</summary>
  SCI_GETSELECTIONNENDVIRTUALSPACE = 2727;

  /// <summary>Returns the position at the end of the selection.</summary>
  SCI_GETSELECTIONNEND = 2587;

  /// <summary>Set the caret position of the rectangular selection.</summary>
  SCI_SETRECTANGULARSELECTIONCARET = 2588;

  /// <summary>Return the caret position of the rectangular selection.</summary>
  SCI_GETRECTANGULARSELECTIONCARET = 2589;

  /// <summary>Set the anchor position of the rectangular selection.</summary>
  SCI_SETRECTANGULARSELECTIONANCHOR = 2590;

  /// <summary>Return the anchor position of the rectangular selection.</summary>
  SCI_GETRECTANGULARSELECTIONANCHOR = 2591;

  /// <summary>Set the virtual space of the caret of the rectangular selection.</summary>
  SCI_SETRECTANGULARSELECTIONCARETVIRTUALSPACE = 2592;

  /// <summary>Return the virtual space of the caret of the rectangular selection.</summary>
  SCI_GETRECTANGULARSELECTIONCARETVIRTUALSPACE = 2593;

  /// <summary>Set the virtual space of the anchor of the rectangular selection.</summary>
  SCI_SETRECTANGULARSELECTIONANCHORVIRTUALSPACE = 2594;

  /// <summary>Return the virtual space of the anchor of the rectangular selection.</summary>
  SCI_GETRECTANGULARSELECTIONANCHORVIRTUALSPACE = 2595;

  SCVS_NONE = 0;
  SCVS_RECTANGULARSELECTION = 1;
  SCVS_USERACCESSIBLE = 2;
  SCVS_NOWRAPLINESTART = 4;

  /// <summary>Set options for virtual space behaviour.</summary>
  SCI_SETVIRTUALSPACEOPTIONS = 2596;

  /// <summary>Return options for virtual space behaviour.</summary>
  SCI_GETVIRTUALSPACEOPTIONS = 2597;

  SCI_SETRECTANGULARSELECTIONMODIFIER = 2598;

  /// <summary>Get the modifier key used for rectangular selection.</summary>
  SCI_GETRECTANGULARSELECTIONMODIFIER = 2599;

  /// <summary>Set the foreground colour of additional selections.
  /// Must have previously called SetSelFore with non-zero first argument for this to have an effect.</summary>
  SCI_SETADDITIONALSELFORE = 2600;

  /// <summary>Set the background colour of additional selections.
  /// Must have previously called SetSelBack with non-zero first argument for this to have an effect.</summary>
  SCI_SETADDITIONALSELBACK = 2601;

  /// <summary>Set the alpha of the selection.</summary>
  SCI_SETADDITIONALSELALPHA = 2602;

  /// <summary>Get the alpha of the selection.</summary>
  SCI_GETADDITIONALSELALPHA = 2603;

  /// <summary>Set the foreground colour of additional carets.</summary>
  SCI_SETADDITIONALCARETFORE = 2604;

  /// <summary>Get the foreground colour of additional carets.</summary>
  SCI_GETADDITIONALCARETFORE = 2605;

  /// <summary>Set the main selection to the next selection.</summary>
  SCI_ROTATESELECTION = 2606;

  /// <summary>Swap that caret and anchor of the main selection.</summary>
  SCI_SWAPMAINANCHORCARET = 2607;

  /// <summary>Add the next occurrence of the main selection to the set of selections as main.
  /// If the current selection is empty then select word around caret.</summary>
  SCI_MULTIPLESELECTADDNEXT = 2688;

  /// <summary>Add each occurrence of the main selection in the target to the set of selections.
  /// If the current selection is empty then select word around caret.</summary>
  SCI_MULTIPLESELECTADDEACH = 2689;

  /// <summary>Indicate that the internal state of a lexer has changed over a range and therefore
  /// there may be a need to redraw.</summary>
  SCI_CHANGELEXERSTATE = 2617;

  /// <summary>Find the next line at or after lineStart that is a contracted fold header line.
  /// Return -1 when no more lines.</summary>
  SCI_CONTRACTEDFOLDNEXT = 2618;

  /// <summary>Centre current line in window.</summary>
  SCI_VERTICALCENTRECARET = 2619;

  /// <summary>Move the selected lines up one line, shifting the line above after the selection</summary>
  SCI_MOVESELECTEDLINESUP = 2620;

  /// <summary>Move the selected lines down one line, shifting the line below before the selection</summary>
  SCI_MOVESELECTEDLINESDOWN = 2621;

  /// <summary>Set the identifier reported as idFrom in notification messages.</summary>
  SCI_SETIDENTIFIER = 2622;

  /// <summary>Get the identifier.</summary>
  SCI_GETIDENTIFIER = 2623;

  /// <summary>Set the width for future RGBA image data.</summary>
  SCI_RGBAIMAGESETWIDTH = 2624;

  /// <summary>Set the height for future RGBA image data.</summary>
  SCI_RGBAIMAGESETHEIGHT = 2625;

  /// <summary>Set the scale factor in percent for future RGBA image data.</summary>
  SCI_RGBAIMAGESETSCALE = 2651;

  /// <summary>Define a marker from RGBA data.
  /// It has the width and height from RGBAImageSetWidth/Height</summary>
  SCI_MARKERDEFINERGBAIMAGE = 2626;

  /// <summary>Register an RGBA image for use in autocompletion lists.
  /// It has the width and height from RGBAImageSetWidth/Height</summary>
  SCI_REGISTERRGBAIMAGE = 2627;

  /// <summary>Scroll to start of document.</summary>
  SCI_SCROLLTOSTART = 2628;

  /// <summary>Scroll to end of document.</summary>
  SCI_SCROLLTOEND = 2629;

  SC_TECHNOLOGY_DEFAULT = 0;
  SC_TECHNOLOGY_DIRECTWRITE = 1;
  SC_TECHNOLOGY_DIRECTWRITERETAIN = 2;
  SC_TECHNOLOGY_DIRECTWRITEDC = 3;
  SC_TECHNOLOGY_DIRECT_WRITE_1 = 4;

  /// <summary>Set the technology used.</summary>
  SCI_SETTECHNOLOGY = 2630;

  /// <summary>Get the tech.</summary>
  SCI_GETTECHNOLOGY = 2631;

  /// <summary>Create an ILoader*.</summary>
  SCI_CREATELOADER = 2632;

  /// <summary>On macOS, show a find indicator.</summary>
  SCI_FINDINDICATORSHOW = 2640;

  /// <summary>On macOS, flash a find indicator, then fade out.</summary>
  SCI_FINDINDICATORFLASH = 2641;

  /// <summary>On macOS, hide the find indicator.</summary>
  SCI_FINDINDICATORHIDE = 2642;

  /// <summary>Move caret to before first visible character on display line.
  /// If already there move to first character on display line.</summary>
  SCI_VCHOMEDISPLAY = 2652;

  /// <summary>Like VCHomeDisplay but extending selection to new caret position.</summary>
  SCI_VCHOMEDISPLAYEXTEND = 2653;

  /// <summary>Is the caret line always visible?</summary>
  SCI_GETCARETLINEVISIBLEALWAYS = 2654;

  /// <summary>Sets the caret line to always visible.</summary>
  SCI_SETCARETLINEVISIBLEALWAYS = 2655;

  /// <summary>Line end types which may be used in addition to LF, CR, and CRLF
  /// SC_LINE_END_TYPE_UNICODE includes U+2028 Line Separator,
  /// U+2029 Paragraph Separator, and U+0085 Next Line</summary>
  SC_LINE_END_TYPE_DEFAULT = 0;
  SC_LINE_END_TYPE_UNICODE = 1;

  /// <summary>Set the line end types that the application wants to use. May not be used if incompatible with lexer or encoding.</summary>
  SCI_SETLINEENDTYPESALLOWED = 2656;

  /// <summary>Get the line end types currently allowed.</summary>
  SCI_GETLINEENDTYPESALLOWED = 2657;

  /// <summary>Get the line end types currently recognised. May be a subset of the allowed types due to lexer limitation.</summary>
  SCI_GETLINEENDTYPESACTIVE = 2658;

  /// <summary>Set the way a character is drawn.</summary>
  SCI_SETREPRESENTATION = 2665;

  /// <summary>Get the way a character is drawn.
  /// Result is NUL-terminated.</summary>
  SCI_GETREPRESENTATION = 2666;

  /// <summary>Remove a character representation.</summary>
  SCI_CLEARREPRESENTATION = 2667;

  /// <summary>Clear representations to default.</summary>
  SCI_CLEARALLREPRESENTATIONS = 2770;

  /// <summary>Can draw representations in various ways</summary>
  SC_REPRESENTATION_PLAIN = 0;
  SC_REPRESENTATION_BLOB = 1;
  SC_REPRESENTATION_COLOUR = $10;

  /// <summary>Set the appearance of a representation.</summary>
  SCI_SETREPRESENTATIONAPPEARANCE = 2766;

  /// <summary>Get the appearance of a representation.</summary>
  SCI_GETREPRESENTATIONAPPEARANCE = 2767;

  /// <summary>Set the colour of a representation.</summary>
  SCI_SETREPRESENTATIONCOLOUR = 2768;

  /// <summary>Get the colour of a representation.</summary>
  SCI_GETREPRESENTATIONCOLOUR = 2769;

  /// <summary>Set the end of line annotation text for a line</summary>
  SCI_EOLANNOTATIONSETTEXT = 2740;

  /// <summary>Get the end of line annotation text for a line</summary>
  SCI_EOLANNOTATIONGETTEXT = 2741;

  /// <summary>Set the style number for the end of line annotations for a line</summary>
  SCI_EOLANNOTATIONSETSTYLE = 2742;

  /// <summary>Get the style number for the end of line annotations for a line</summary>
  SCI_EOLANNOTATIONGETSTYLE = 2743;

  /// <summary>Clear the end of annotations from all lines</summary>
  SCI_EOLANNOTATIONCLEARALL = 2744;

  EOLANNOTATION_HIDDEN = $0;
  EOLANNOTATION_STANDARD = $1;
  EOLANNOTATION_BOXED = $2;
  EOLANNOTATION_STADIUM = $100;
  EOLANNOTATION_FLAT_CIRCLE = $101;
  EOLANNOTATION_ANGLE_CIRCLE = $102;
  EOLANNOTATION_CIRCLE_FLAT = $110;
  EOLANNOTATION_FLATS = $111;
  EOLANNOTATION_ANGLE_FLAT = $112;
  EOLANNOTATION_CIRCLE_ANGLE = $120;
  EOLANNOTATION_FLAT_ANGLE = $121;
  EOLANNOTATION_ANGLES = $122;

  /// <summary>Set the visibility for the end of line annotations for a view</summary>
  SCI_EOLANNOTATIONSETVISIBLE = 2745;

  /// <summary>Get the visibility for the end of line annotations for a view</summary>
  SCI_EOLANNOTATIONGETVISIBLE = 2746;

  /// <summary>Get the start of the range of style numbers used for end of line annotations</summary>
  SCI_EOLANNOTATIONSETSTYLEOFFSET = 2747;

  /// <summary>Get the start of the range of style numbers used for end of line annotations</summary>
  SCI_EOLANNOTATIONGETSTYLEOFFSET = 2748;

  SC_SUPPORTS_LINE_DRAWS_FINAL = 0;
  SC_SUPPORTS_PIXEL_DIVISIONS = 1;
  SC_SUPPORTS_FRACTIONAL_STROKE_WIDTH = 2;
  SC_SUPPORTS_TRANSLUCENT_STROKE = 3;
  SC_SUPPORTS_PIXEL_MODIFICATION = 4;
  SC_SUPPORTS_THREAD_SAFE_MEASURE_WIDTHS = 5;

  /// <summary>Get whether a feature is supported</summary>
  SCI_SUPPORTSFEATURE = 2750;

  SC_LINECHARACTERINDEX_NONE = 0;
  SC_LINECHARACTERINDEX_UTF32 = 1;
  SC_LINECHARACTERINDEX_UTF16 = 2;

  /// <summary>Retrieve line character index state.</summary>
  SCI_GETLINECHARACTERINDEX = 2710;

  /// <summary>Request line character index be created or its use count increased.</summary>
  SCI_ALLOCATELINECHARACTERINDEX = 2711;

  /// <summary>Decrease use count of line character index and remove if 0.</summary>
  SCI_RELEASELINECHARACTERINDEX = 2712;

  /// <summary>Retrieve the document line containing a position measured in index units.</summary>
  SCI_LINEFROMINDEXPOSITION = 2713;

  /// <summary>Retrieve the position measured in index units at the start of a document line.</summary>
  SCI_INDEXPOSITIONFROMLINE = 2714;

  /// <summary>Get whether drag-and-drop is enabled or disabled</summary>
  SCI_GETDRAGDROPENABLED = 2818;

  /// <summary>Enable or disable drag-and-drop</summary>
  SCI_SETDRAGDROPENABLED = 2819;

  /// <summary>Start notifying the container of all key presses and commands.</summary>
  SCI_STARTRECORD = 3001;

  /// <summary>Stop notifying the container of all key presses and commands.</summary>
  SCI_STOPRECORD = 3002;

  /// <summary>Retrieve the lexing language of the document.</summary>
  SCI_GETLEXER = 4002;

  /// <summary>Colourise a segment of the document using the current lexing language.</summary>
  SCI_COLOURISE = 4003;

  /// <summary>Set up a value that may be used by a lexer for some optional feature.</summary>
  SCI_SETPROPERTY = 4004;

  /// <summary>Maximum value of keywordSet parameter of SetKeyWords.</summary>
  KEYWORDSET_MAX = 8;

  /// <summary>Set up the key words used by the lexer.</summary>
  SCI_SETKEYWORDS = 4005;

  /// <summary>Retrieve a "property" value previously set with SetProperty.
  /// Result is NUL-terminated.</summary>
  SCI_GETPROPERTY = 4008;

  /// <summary>Retrieve a "property" value previously set with SetProperty,
  /// with "$()" variable replacement on returned buffer.
  /// Result is NUL-terminated.</summary>
  SCI_GETPROPERTYEXPANDED = 4009;

  /// <summary>Retrieve a "property" value previously set with SetProperty,
  /// interpreted as an int AFTER any "$()" variable replacement.</summary>
  SCI_GETPROPERTYINT = 4010;

  /// <summary>Retrieve the name of the lexer.
  /// Return the length of the text.
  /// Result is NUL-terminated.</summary>
  SCI_GETLEXERLANGUAGE = 4012;

  /// <summary>For private communication between an application and a known lexer.</summary>
  SCI_PRIVATELEXERCALL = 4013;

  /// <summary>Retrieve a '\n' separated list of properties understood by the current lexer.
  /// Result is NUL-terminated.</summary>
  SCI_PROPERTYNAMES = 4014;

  SC_TYPE_BOOLEAN = 0;
  SC_TYPE_INTEGER = 1;
  SC_TYPE_STRING = 2;

  /// <summary>Retrieve the type of a property.</summary>
  SCI_PROPERTYTYPE = 4015;

  /// <summary>Describe a property.
  /// Result is NUL-terminated.</summary>
  SCI_DESCRIBEPROPERTY = 4016;

  /// <summary>Retrieve a '\n' separated list of descriptions of the keyword sets understood by the current lexer.
  /// Result is NUL-terminated.</summary>
  SCI_DESCRIBEKEYWORDSETS = 4017;

  /// <summary>Bit set of LineEndType enumertion for which line ends beyond the standard
  /// LF, CR, and CRLF are supported by the lexer.</summary>
  SCI_GETLINEENDTYPESSUPPORTED = 4018;

  /// <summary>Allocate a set of sub styles for a particular base style, returning start of range</summary>
  SCI_ALLOCATESUBSTYLES = 4020;

  /// <summary>The starting style number for the sub styles associated with a base style</summary>
  SCI_GETSUBSTYLESSTART = 4021;

  /// <summary>The number of sub styles associated with a base style</summary>
  SCI_GETSUBSTYLESLENGTH = 4022;

  /// <summary>For a sub style, return the base style, else return the argument.</summary>
  SCI_GETSTYLEFROMSUBSTYLE = 4027;

  /// <summary>For a secondary style, return the primary style, else return the argument.</summary>
  SCI_GETPRIMARYSTYLEFROMSTYLE = 4028;

  /// <summary>Free allocated sub styles</summary>
  SCI_FREESUBSTYLES = 4023;

  /// <summary>Set the identifiers that are shown in a particular style</summary>
  SCI_SETIDENTIFIERS = 4024;

  /// <summary>Where styles are duplicated by a feature such as active/inactive code
  /// return the distance between the two types.</summary>
  SCI_DISTANCETOSECONDARYSTYLES = 4025;

  /// <summary>Get the set of base styles that can be extended with sub styles
  /// Result is NUL-terminated.</summary>
  SCI_GETSUBSTYLEBASES = 4026;

  /// <summary>Retrieve the number of named styles for the lexer.</summary>
  SCI_GETNAMEDSTYLES = 4029;

  /// <summary>Retrieve the name of a style.
  /// Result is NUL-terminated.</summary>
  SCI_NAMEOFSTYLE = 4030;

  /// <summary>Retrieve a ' ' separated list of style tags like "literal quoted string".
  /// Result is NUL-terminated.</summary>
  SCI_TAGSOFSTYLE = 4031;

  /// <summary>Retrieve a description of a style.
  /// Result is NUL-terminated.</summary>
  SCI_DESCRIPTIONOFSTYLE = 4032;

  /// <summary>Set the lexer from an ILexer*.</summary>
  SCI_SETILEXER = 4033;

  /// <summary>Notifications
  /// Type of modification and the action which caused the modification.
  /// These are defined as a bit mask to make it easy to specify which notifications are wanted.
  /// One bit is set from each of SC_MOD_* and SC_PERFORMED_*.</summary>
  SC_MOD_NONE = $0;
  SC_MOD_INSERTTEXT = $1;
  SC_MOD_DELETETEXT = $2;
  SC_MOD_CHANGESTYLE = $4;
  SC_MOD_CHANGEFOLD = $8;
  SC_PERFORMED_USER = $10;
  SC_PERFORMED_UNDO = $20;
  SC_PERFORMED_REDO = $40;
  SC_MULTISTEPUNDOREDO = $80;
  SC_LASTSTEPINUNDOREDO = $100;
  SC_MOD_CHANGEMARKER = $200;
  SC_MOD_BEFOREINSERT = $400;
  SC_MOD_BEFOREDELETE = $800;
  SC_MULTILINEUNDOREDO = $1000;
  SC_STARTACTION = $2000;
  SC_MOD_CHANGEINDICATOR = $4000;
  SC_MOD_CHANGELINESTATE = $8000;
  SC_MOD_CHANGEMARGIN = $10000;
  SC_MOD_CHANGEANNOTATION = $20000;
  SC_MOD_CONTAINER = $40000;
  SC_MOD_LEXERSTATE = $80000;
  SC_MOD_INSERTCHECK = $100000;
  SC_MOD_CHANGETABSTOPS = $200000;
  SC_MOD_CHANGEEOLANNOTATION = $400000;
  SC_MODEVENTMASKALL = $7FFFFF;

  SC_UPDATE_NONE = $0;
  SC_UPDATE_CONTENT = $1;
  SC_UPDATE_SELECTION = $2;
  SC_UPDATE_V_SCROLL = $4;
  SC_UPDATE_H_SCROLL = $8;

  /// <summary>For compatibility, these go through the COMMAND notification rather than NOTIFY
  /// and should have had exactly the same values as the EN_* constants.
  /// Unfortunately the SETFOCUS and KILLFOCUS are flipped over from EN_*
  /// As clients depend on these constants, this will not be changed.</summary>
  SCEN_CHANGE = 768;
  SCEN_SETFOCUS = 512;
  SCEN_KILLFOCUS = 256;

  SCK_DOWN = 300;
  SCK_UP = 301;
  SCK_LEFT = 302;
  SCK_RIGHT = 303;
  SCK_HOME = 304;
  SCK_END = 305;
  SCK_PRIOR = 306;
  SCK_NEXT = 307;
  SCK_DELETE = 308;
  SCK_INSERT = 309;
  SCK_ESCAPE = 7;
  SCK_BACK = 8;
  SCK_TAB = 9;
  SCK_RETURN = 13;
  SCK_ADD = 310;
  SCK_SUBTRACT = 311;
  SCK_DIVIDE = 312;
  SCK_WIN = 313;
  SCK_RWIN = 314;
  SCK_MENU = 315;

  SCMOD_NORM = 0;
  SCMOD_SHIFT = 1;
  SCMOD_CTRL = 2;
  SCMOD_ALT = 4;
  SCMOD_SUPER = 8;
  SCMOD_META = 16;

  SC_AC_FILLUP = 1;
  SC_AC_DOUBLECLICK = 2;
  SC_AC_TAB = 3;
  SC_AC_NEWLINE = 4;
  SC_AC_COMMAND = 5;
  SC_AC_SINGLE_CHOICE = 6;

  /// <summary>characterSource for SCN_CHARADDED
  /// Direct input characters.</summary>
  SC_CHARACTERSOURCE_DIRECT_INPUT = 0;

  /// <summary>IME (inline mode) or dead key tentative input characters.</summary>
  SC_CHARACTERSOURCE_TENTATIVE_INPUT = 1;

  /// <summary>IME (either inline or windowed mode) full composited string.</summary>
  SC_CHARACTERSOURCE_IME_RESULT = 2;

  SC_BIDIRECTIONAL_DISABLED = 0;
  SC_BIDIRECTIONAL_L2R = 1;
  SC_BIDIRECTIONAL_R2L = 2;

  /// <summary>Retrieve bidirectional text display state.</summary>
  SCI_GETBIDIRECTIONAL = 2708;

  /// <summary>Set bidirectional text display state.</summary>
  SCI_SETBIDIRECTIONAL = 2709;

  /// <summary>Divide each styling byte into lexical class bits (default: 5) and indicator
  /// bits (default: 3). If a lexer requires more than 32 lexical states, then this
  /// is used to expand the possible states.</summary>
  SCI_SETSTYLEBITS = 2090;

  /// <summary>Retrieve number of bits in style bytes used to hold the lexical state.</summary>
  SCI_GETSTYLEBITS = 2091;

  /// <summary>Retrieve the number of bits the current lexer needs for styling.</summary>
  SCI_GETSTYLEBITSNEEDED = 4011;

  /// <summary>Always interpret keyboard input as Unicode</summary>
  SCI_SETKEYSUNICODE = 2521;

  /// <summary>Are keys always interpreted as Unicode?</summary>
  SCI_GETKEYSUNICODE = 2522;

  /// <summary>Is drawing done in two phases with backgrounds drawn before foregrounds?</summary>
  SCI_GETTWOPHASEDRAW = 2283;

  /// <summary>In twoPhaseDraw mode, drawing is performed in two phases, first the background
  /// and then the foreground. This avoids chopping off characters that overlap the next run.</summary>
  SCI_SETTWOPHASEDRAW = 2284;

  INDIC0_MASK = $20;
  INDIC1_MASK = $40;
  INDIC2_MASK = $80;
  INDICS_MASK = $E0;
  /// <summary>For SciLexer.h</summary>
  SCLEX_CONTAINER = 0;
  SCLEX_NULL = 1;
  SCLEX_PYTHON = 2;
  SCLEX_CPP = 3;
  SCLEX_HTML = 4;
  SCLEX_XML = 5;
  SCLEX_PERL = 6;
  SCLEX_SQL = 7;
  SCLEX_VB = 8;
  SCLEX_PROPERTIES = 9;
  SCLEX_ERRORLIST = 10;
  SCLEX_MAKEFILE = 11;
  SCLEX_BATCH = 12;
  SCLEX_XCODE = 13;
  SCLEX_LATEX = 14;
  SCLEX_LUA = 15;
  SCLEX_DIFF = 16;
  SCLEX_CONF = 17;
  SCLEX_PASCAL = 18;
  SCLEX_AVE = 19;
  SCLEX_ADA = 20;
  SCLEX_LISP = 21;
  SCLEX_RUBY = 22;
  SCLEX_EIFFEL = 23;
  SCLEX_EIFFELKW = 24;
  SCLEX_TCL = 25;
  SCLEX_NNCRONTAB = 26;
  SCLEX_BULLANT = 27;
  SCLEX_VBSCRIPT = 28;
  SCLEX_BAAN = 31;
  SCLEX_MATLAB = 32;
  SCLEX_SCRIPTOL = 33;
  SCLEX_ASM = 34;
  SCLEX_CPPNOCASE = 35;
  SCLEX_FORTRAN = 36;
  SCLEX_F77 = 37;
  SCLEX_CSS = 38;
  SCLEX_POV = 39;
  SCLEX_LOUT = 40;
  SCLEX_ESCRIPT = 41;
  SCLEX_PS = 42;
  SCLEX_NSIS = 43;
  SCLEX_MMIXAL = 44;
  SCLEX_CLW = 45;
  SCLEX_CLWNOCASE = 46;
  SCLEX_LOT = 47;
  SCLEX_YAML = 48;
  SCLEX_TEX = 49;
  SCLEX_METAPOST = 50;
  SCLEX_POWERBASIC = 51;
  SCLEX_FORTH = 52;
  SCLEX_ERLANG = 53;
  SCLEX_OCTAVE = 54;
  SCLEX_MSSQL = 55;
  SCLEX_VERILOG = 56;
  SCLEX_KIX = 57;
  SCLEX_GUI4CLI = 58;
  SCLEX_SPECMAN = 59;
  SCLEX_AU3 = 60;
  SCLEX_APDL = 61;
  SCLEX_BASH = 62;
  SCLEX_ASN1 = 63;
  SCLEX_VHDL = 64;
  SCLEX_CAML = 65;
  SCLEX_BLITZBASIC = 66;
  SCLEX_PUREBASIC = 67;
  SCLEX_HASKELL = 68;
  SCLEX_PHPSCRIPT = 69;
  SCLEX_TADS3 = 70;
  SCLEX_REBOL = 71;
  SCLEX_SMALLTALK = 72;
  SCLEX_FLAGSHIP = 73;
  SCLEX_CSOUND = 74;
  SCLEX_FREEBASIC = 75;
  SCLEX_INNOSETUP = 76;
  SCLEX_OPAL = 77;
  SCLEX_SPICE = 78;
  SCLEX_D = 79;
  SCLEX_CMAKE = 80;
  SCLEX_GAP = 81;
  SCLEX_PLM = 82;
  SCLEX_PROGRESS = 83;
  SCLEX_ABAQUS = 84;
  SCLEX_ASYMPTOTE = 85;
  SCLEX_R = 86;
  SCLEX_MAGIK = 87;
  SCLEX_POWERSHELL = 88;
  SCLEX_MYSQL = 89;
  SCLEX_PO = 90;
  SCLEX_TAL = 91;
  SCLEX_COBOL = 92;
  SCLEX_TACL = 93;
  SCLEX_SORCUS = 94;
  SCLEX_POWERPRO = 95;
  SCLEX_NIMROD = 96;
  SCLEX_SML = 97;
  SCLEX_MARKDOWN = 98;
  SCLEX_TXT2TAGS = 99;
  SCLEX_A68K = 100;
  SCLEX_MODULA = 101;
  SCLEX_COFFEESCRIPT = 102;
  SCLEX_TCMD = 103;
  SCLEX_AVS = 104;
  SCLEX_ECL = 105;
  SCLEX_OSCRIPT = 106;
  SCLEX_VISUALPROLOG = 107;
  SCLEX_LITERATEHASKELL = 108;
  SCLEX_STTXT = 109;
  SCLEX_KVIRC = 110;
  SCLEX_RUST = 111;
  SCLEX_DMAP = 112;
  SCLEX_AS = 113;
  SCLEX_DMIS = 114;
  SCLEX_REGISTRY = 115;
  SCLEX_BIBTEX = 116;
  SCLEX_SREC = 117;
  SCLEX_IHEX = 118;
  SCLEX_TEHEX = 119;
  SCLEX_JSON = 120;
  SCLEX_EDIFACT = 121;
  SCLEX_INDENT = 122;
  SCLEX_MAXIMA = 123;
  SCLEX_STATA = 124;
  SCLEX_SAS = 125;
  SCLEX_NIM = 126;
  SCLEX_CIL = 127;
  SCLEX_X12 = 128;
  SCLEX_DATAFLEX = 129;
  SCLEX_HOLLYWOOD = 130;
  SCLEX_RAKU = 131;
  SCLEX_FSHARP = 132;
  SCLEX_JULIA = 133;
  SCLEX_ASCIIDOC = 134;
  SCLEX_GDSCRIPT = 135;
  SCLEX_TOML = 136;
  SCLEX_TROFF = 137;
  SCLEX_DART = 138;
  SCLEX_ZIG = 139;
  SCLEX_NIX = 140;
  SCLEX_SINEX = 141;
  SCLEX_ESCSEQ = 142;

  /// <summary>When a lexer specifies its language as SCLEX_AUTOMATIC it receives a
  /// value assigned in sequence from SCLEX_AUTOMATIC+1.</summary>
  SCLEX_AUTOMATIC = 1000;

  /// <summary>Lexical states for SCLEX_PYTHON</summary>
  SCE_P_DEFAULT = 0;
  SCE_P_COMMENTLINE = 1;
  SCE_P_NUMBER = 2;
  SCE_P_STRING = 3;
  SCE_P_CHARACTER = 4;
  SCE_P_WORD = 5;
  SCE_P_TRIPLE = 6;
  SCE_P_TRIPLEDOUBLE = 7;
  SCE_P_CLASSNAME = 8;
  SCE_P_DEFNAME = 9;
  SCE_P_OPERATOR = 10;
  SCE_P_IDENTIFIER = 11;
  SCE_P_COMMENTBLOCK = 12;
  SCE_P_STRINGEOL = 13;
  SCE_P_WORD2 = 14;
  SCE_P_DECORATOR = 15;
  SCE_P_FSTRING = 16;
  SCE_P_FCHARACTER = 17;
  SCE_P_FTRIPLE = 18;
  SCE_P_FTRIPLEDOUBLE = 19;
  SCE_P_ATTRIBUTE = 20;

  /// <summary>Lexical states for SCLEX_CPP
  /// Lexical states for SCLEX_BULLANT
  /// Lexical states for SCLEX_TACL
  /// Lexical states for SCLEX_TAL</summary>
  SCE_C_DEFAULT = 0;
  SCE_C_COMMENT = 1;
  SCE_C_COMMENTLINE = 2;
  SCE_C_COMMENTDOC = 3;
  SCE_C_NUMBER = 4;
  SCE_C_WORD = 5;
  SCE_C_STRING = 6;
  SCE_C_CHARACTER = 7;
  SCE_C_UUID = 8;
  SCE_C_PREPROCESSOR = 9;
  SCE_C_OPERATOR = 10;
  SCE_C_IDENTIFIER = 11;
  SCE_C_STRINGEOL = 12;
  SCE_C_VERBATIM = 13;
  SCE_C_REGEX = 14;
  SCE_C_COMMENTLINEDOC = 15;
  SCE_C_WORD2 = 16;
  SCE_C_COMMENTDOCKEYWORD = 17;
  SCE_C_COMMENTDOCKEYWORDERROR = 18;
  SCE_C_GLOBALCLASS = 19;
  SCE_C_STRINGRAW = 20;
  SCE_C_TRIPLEVERBATIM = 21;
  SCE_C_HASHQUOTEDSTRING = 22;
  SCE_C_PREPROCESSORCOMMENT = 23;
  SCE_C_PREPROCESSORCOMMENTDOC = 24;
  SCE_C_USERLITERAL = 25;
  SCE_C_TASKMARKER = 26;
  SCE_C_ESCAPESEQUENCE = 27;

  /// <summary>Lexical states for SCLEX_COBOL</summary>
  SCE_COBOL_DEFAULT = 0;
  SCE_COBOL_COMMENT = 1;
  SCE_COBOL_COMMENTLINE = 2;
  SCE_COBOL_COMMENTDOC = 3;
  SCE_COBOL_NUMBER = 4;
  SCE_COBOL_WORD = 5;
  SCE_COBOL_STRING = 6;
  SCE_COBOL_CHARACTER = 7;
  SCE_COBOL_WORD3 = 8;
  SCE_COBOL_PREPROCESSOR = 9;
  SCE_COBOL_OPERATOR = 10;
  SCE_COBOL_IDENTIFIER = 11;
  SCE_COBOL_WORD2 = 16;

  /// <summary>Lexical states for SCLEX_D</summary>
  SCE_D_DEFAULT = 0;
  SCE_D_COMMENT = 1;
  SCE_D_COMMENTLINE = 2;
  SCE_D_COMMENTDOC = 3;
  SCE_D_COMMENTNESTED = 4;
  SCE_D_NUMBER = 5;
  SCE_D_WORD = 6;
  SCE_D_WORD2 = 7;
  SCE_D_WORD3 = 8;
  SCE_D_TYPEDEF = 9;
  SCE_D_STRING = 10;
  SCE_D_STRINGEOL = 11;
  SCE_D_CHARACTER = 12;
  SCE_D_OPERATOR = 13;
  SCE_D_IDENTIFIER = 14;
  SCE_D_COMMENTLINEDOC = 15;
  SCE_D_COMMENTDOCKEYWORD = 16;
  SCE_D_COMMENTDOCKEYWORDERROR = 17;
  SCE_D_STRINGB = 18;
  SCE_D_STRINGR = 19;
  SCE_D_WORD5 = 20;
  SCE_D_WORD6 = 21;
  SCE_D_WORD7 = 22;

  /// <summary>Lexical states for SCLEX_TCL</summary>
  SCE_TCL_DEFAULT = 0;
  SCE_TCL_COMMENT = 1;
  SCE_TCL_COMMENTLINE = 2;
  SCE_TCL_NUMBER = 3;
  SCE_TCL_WORD_IN_QUOTE = 4;
  SCE_TCL_IN_QUOTE = 5;
  SCE_TCL_OPERATOR = 6;
  SCE_TCL_IDENTIFIER = 7;
  SCE_TCL_SUBSTITUTION = 8;
  SCE_TCL_SUB_BRACE = 9;
  SCE_TCL_MODIFIER = 10;
  SCE_TCL_EXPAND = 11;
  SCE_TCL_WORD = 12;
  SCE_TCL_WORD2 = 13;
  SCE_TCL_WORD3 = 14;
  SCE_TCL_WORD4 = 15;
  SCE_TCL_WORD5 = 16;
  SCE_TCL_WORD6 = 17;
  SCE_TCL_WORD7 = 18;
  SCE_TCL_WORD8 = 19;
  SCE_TCL_COMMENT_BOX = 20;
  SCE_TCL_BLOCK_COMMENT = 21;

  /// <summary>Lexical states for SCLEX_HTML, SCLEX_XML</summary>
  SCE_H_DEFAULT = 0;
  SCE_H_TAG = 1;
  SCE_H_TAGUNKNOWN = 2;
  SCE_H_ATTRIBUTE = 3;
  SCE_H_ATTRIBUTEUNKNOWN = 4;
  SCE_H_NUMBER = 5;
  SCE_H_DOUBLESTRING = 6;
  SCE_H_SINGLESTRING = 7;
  SCE_H_OTHER = 8;
  SCE_H_COMMENT = 9;
  SCE_H_ENTITY = 10;

  /// <summary>XML and ASP</summary>
  SCE_H_TAGEND = 11;
  SCE_H_XMLSTART = 12;
  SCE_H_XMLEND = 13;
  SCE_H_SCRIPT = 14;
  SCE_H_ASP = 15;
  SCE_H_ASPAT = 16;
  SCE_H_CDATA = 17;
  SCE_H_QUESTION = 18;

  /// <summary>More HTML</summary>
  SCE_H_VALUE = 19;

  /// <summary>X-Code, ASP.NET, JSP</summary>
  SCE_H_XCCOMMENT = 20;

  /// <summary>SGML</summary>
  SCE_H_SGML_DEFAULT = 21;
  SCE_H_SGML_COMMAND = 22;
  SCE_H_SGML_1ST_PARAM = 23;
  SCE_H_SGML_DOUBLESTRING = 24;
  SCE_H_SGML_SIMPLESTRING = 25;
  SCE_H_SGML_ERROR = 26;
  SCE_H_SGML_SPECIAL = 27;
  SCE_H_SGML_ENTITY = 28;
  SCE_H_SGML_COMMENT = 29;
  SCE_H_SGML_1ST_PARAM_COMMENT = 30;
  SCE_H_SGML_BLOCK_DEFAULT = 31;

  /// <summary>Embedded Javascript</summary>
  SCE_HJ_START = 40;
  SCE_HJ_DEFAULT = 41;
  SCE_HJ_COMMENT = 42;
  SCE_HJ_COMMENTLINE = 43;
  SCE_HJ_COMMENTDOC = 44;
  SCE_HJ_NUMBER = 45;
  SCE_HJ_WORD = 46;
  SCE_HJ_KEYWORD = 47;
  SCE_HJ_DOUBLESTRING = 48;
  SCE_HJ_SINGLESTRING = 49;
  SCE_HJ_SYMBOLS = 50;
  SCE_HJ_STRINGEOL = 51;
  SCE_HJ_REGEX = 52;
  SCE_HJ_TEMPLATELITERAL = 53;

  /// <summary>ASP Javascript</summary>
  SCE_HJA_START = 55;
  SCE_HJA_DEFAULT = 56;
  SCE_HJA_COMMENT = 57;
  SCE_HJA_COMMENTLINE = 58;
  SCE_HJA_COMMENTDOC = 59;
  SCE_HJA_NUMBER = 60;
  SCE_HJA_WORD = 61;
  SCE_HJA_KEYWORD = 62;
  SCE_HJA_DOUBLESTRING = 63;
  SCE_HJA_SINGLESTRING = 64;
  SCE_HJA_SYMBOLS = 65;
  SCE_HJA_STRINGEOL = 66;
  SCE_HJA_REGEX = 67;
  SCE_HJA_TEMPLATELITERAL = 68;

  /// <summary>Embedded VBScript</summary>
  SCE_HB_START = 70;
  SCE_HB_DEFAULT = 71;
  SCE_HB_COMMENTLINE = 72;
  SCE_HB_NUMBER = 73;
  SCE_HB_WORD = 74;
  SCE_HB_STRING = 75;
  SCE_HB_IDENTIFIER = 76;
  SCE_HB_STRINGEOL = 77;

  /// <summary>ASP VBScript</summary>
  SCE_HBA_START = 80;
  SCE_HBA_DEFAULT = 81;
  SCE_HBA_COMMENTLINE = 82;
  SCE_HBA_NUMBER = 83;
  SCE_HBA_WORD = 84;
  SCE_HBA_STRING = 85;
  SCE_HBA_IDENTIFIER = 86;
  SCE_HBA_STRINGEOL = 87;

  /// <summary>Embedded Python</summary>
  SCE_HP_START = 90;
  SCE_HP_DEFAULT = 91;
  SCE_HP_COMMENTLINE = 92;
  SCE_HP_NUMBER = 93;
  SCE_HP_STRING = 94;
  SCE_HP_CHARACTER = 95;
  SCE_HP_WORD = 96;
  SCE_HP_TRIPLE = 97;
  SCE_HP_TRIPLEDOUBLE = 98;
  SCE_HP_CLASSNAME = 99;
  SCE_HP_DEFNAME = 100;
  SCE_HP_OPERATOR = 101;
  SCE_HP_IDENTIFIER = 102;

  /// <summary>PHP</summary>
  SCE_HPHP_COMPLEX_VARIABLE = 104;

  /// <summary>ASP Python</summary>
  SCE_HPA_START = 105;
  SCE_HPA_DEFAULT = 106;
  SCE_HPA_COMMENTLINE = 107;
  SCE_HPA_NUMBER = 108;
  SCE_HPA_STRING = 109;
  SCE_HPA_CHARACTER = 110;
  SCE_HPA_WORD = 111;
  SCE_HPA_TRIPLE = 112;
  SCE_HPA_TRIPLEDOUBLE = 113;
  SCE_HPA_CLASSNAME = 114;
  SCE_HPA_DEFNAME = 115;
  SCE_HPA_OPERATOR = 116;
  SCE_HPA_IDENTIFIER = 117;

  /// <summary>PHP</summary>
  SCE_HPHP_DEFAULT = 118;
  SCE_HPHP_HSTRING = 119;
  SCE_HPHP_SIMPLESTRING = 120;
  SCE_HPHP_WORD = 121;
  SCE_HPHP_NUMBER = 122;
  SCE_HPHP_VARIABLE = 123;
  SCE_HPHP_COMMENT = 124;
  SCE_HPHP_COMMENTLINE = 125;
  SCE_HPHP_HSTRING_VARIABLE = 126;
  SCE_HPHP_OPERATOR = 127;

  /// <summary>Lexical states for SCLEX_PERL</summary>
  SCE_PL_DEFAULT = 0;
  SCE_PL_ERROR = 1;
  SCE_PL_COMMENTLINE = 2;
  SCE_PL_POD = 3;
  SCE_PL_NUMBER = 4;
  SCE_PL_WORD = 5;
  SCE_PL_STRING = 6;
  SCE_PL_CHARACTER = 7;
  SCE_PL_PUNCTUATION = 8;
  SCE_PL_PREPROCESSOR = 9;
  SCE_PL_OPERATOR = 10;
  SCE_PL_IDENTIFIER = 11;
  SCE_PL_SCALAR = 12;
  SCE_PL_ARRAY = 13;
  SCE_PL_HASH = 14;
  SCE_PL_SYMBOLTABLE = 15;
  SCE_PL_VARIABLE_INDEXER = 16;
  SCE_PL_REGEX = 17;
  SCE_PL_REGSUBST = 18;
  SCE_PL_LONGQUOTE = 19;
  SCE_PL_BACKTICKS = 20;
  SCE_PL_DATASECTION = 21;
  SCE_PL_HERE_DELIM = 22;
  SCE_PL_HERE_Q = 23;
  SCE_PL_HERE_QQ = 24;
  SCE_PL_HERE_QX = 25;
  SCE_PL_STRING_Q = 26;
  SCE_PL_STRING_QQ = 27;
  SCE_PL_STRING_QX = 28;
  SCE_PL_STRING_QR = 29;
  SCE_PL_STRING_QW = 30;
  SCE_PL_POD_VERB = 31;
  SCE_PL_SUB_PROTOTYPE = 40;
  SCE_PL_FORMAT_IDENT = 41;
  SCE_PL_FORMAT = 42;
  SCE_PL_STRING_VAR = 43;
  SCE_PL_XLAT = 44;
  SCE_PL_REGEX_VAR = 54;
  SCE_PL_REGSUBST_VAR = 55;
  SCE_PL_BACKTICKS_VAR = 57;
  SCE_PL_HERE_QQ_VAR = 61;
  SCE_PL_HERE_QX_VAR = 62;
  SCE_PL_STRING_QQ_VAR = 64;
  SCE_PL_STRING_QX_VAR = 65;
  SCE_PL_STRING_QR_VAR = 66;

  /// <summary>Lexical states for SCLEX_RUBY</summary>
  SCE_RB_DEFAULT = 0;
  SCE_RB_ERROR = 1;
  SCE_RB_COMMENTLINE = 2;
  SCE_RB_POD = 3;
  SCE_RB_NUMBER = 4;
  SCE_RB_WORD = 5;
  SCE_RB_STRING = 6;
  SCE_RB_CHARACTER = 7;
  SCE_RB_CLASSNAME = 8;
  SCE_RB_DEFNAME = 9;
  SCE_RB_OPERATOR = 10;
  SCE_RB_IDENTIFIER = 11;
  SCE_RB_REGEX = 12;
  SCE_RB_GLOBAL = 13;
  SCE_RB_SYMBOL = 14;
  SCE_RB_MODULE_NAME = 15;
  SCE_RB_INSTANCE_VAR = 16;
  SCE_RB_CLASS_VAR = 17;
  SCE_RB_BACKTICKS = 18;
  SCE_RB_DATASECTION = 19;
  SCE_RB_HERE_DELIM = 20;
  SCE_RB_HERE_Q = 21;
  SCE_RB_HERE_QQ = 22;
  SCE_RB_HERE_QX = 23;
  SCE_RB_STRING_Q = 24;
  SCE_RB_STRING_QQ = 25;
  SCE_RB_STRING_QX = 26;
  SCE_RB_STRING_QR = 27;
  SCE_RB_STRING_QW = 28;
  SCE_RB_WORD_DEMOTED = 29;
  SCE_RB_STDIN = 30;
  SCE_RB_STDOUT = 31;
  SCE_RB_STDERR = 40;
  SCE_RB_STRING_W = 41;
  SCE_RB_STRING_I = 42;
  SCE_RB_STRING_QI = 43;
  SCE_RB_STRING_QS = 44;
  SCE_RB_UPPER_BOUND = 45;

  /// <summary>Lexical states for SCLEX_VB, SCLEX_VBSCRIPT, SCLEX_POWERBASIC, SCLEX_BLITZBASIC, SCLEX_PUREBASIC, SCLEX_FREEBASIC</summary>
  SCE_B_DEFAULT = 0;
  SCE_B_COMMENT = 1;
  SCE_B_NUMBER = 2;
  SCE_B_KEYWORD = 3;
  SCE_B_STRING = 4;
  SCE_B_PREPROCESSOR = 5;
  SCE_B_OPERATOR = 6;
  SCE_B_IDENTIFIER = 7;
  SCE_B_DATE = 8;
  SCE_B_STRINGEOL = 9;
  SCE_B_KEYWORD2 = 10;
  SCE_B_KEYWORD3 = 11;
  SCE_B_KEYWORD4 = 12;
  SCE_B_CONSTANT = 13;
  SCE_B_ASM = 14;
  SCE_B_LABEL = 15;
  SCE_B_ERROR = 16;
  SCE_B_HEXNUMBER = 17;
  SCE_B_BINNUMBER = 18;
  SCE_B_COMMENTBLOCK = 19;
  SCE_B_DOCLINE = 20;
  SCE_B_DOCBLOCK = 21;
  SCE_B_DOCKEYWORD = 22;

  /// <summary>Lexical states for SCLEX_PROPERTIES</summary>
  SCE_PROPS_DEFAULT = 0;
  SCE_PROPS_COMMENT = 1;
  SCE_PROPS_SECTION = 2;
  SCE_PROPS_ASSIGNMENT = 3;
  SCE_PROPS_DEFVAL = 4;
  SCE_PROPS_KEY = 5;

  /// <summary>Lexical states for SCLEX_LATEX</summary>
  SCE_L_DEFAULT = 0;
  SCE_L_COMMAND = 1;
  SCE_L_TAG = 2;
  SCE_L_MATH = 3;
  SCE_L_COMMENT = 4;
  SCE_L_TAG2 = 5;
  SCE_L_MATH2 = 6;
  SCE_L_COMMENT2 = 7;
  SCE_L_VERBATIM = 8;
  SCE_L_SHORTCMD = 9;
  SCE_L_SPECIAL = 10;
  SCE_L_CMDOPT = 11;
  SCE_L_ERROR = 12;

  /// <summary>Lexical states for SCLEX_LUA</summary>
  SCE_LUA_DEFAULT = 0;
  SCE_LUA_COMMENT = 1;
  SCE_LUA_COMMENTLINE = 2;
  SCE_LUA_COMMENTDOC = 3;
  SCE_LUA_NUMBER = 4;
  SCE_LUA_WORD = 5;
  SCE_LUA_STRING = 6;
  SCE_LUA_CHARACTER = 7;
  SCE_LUA_LITERALSTRING = 8;
  SCE_LUA_PREPROCESSOR = 9;
  SCE_LUA_OPERATOR = 10;
  SCE_LUA_IDENTIFIER = 11;
  SCE_LUA_STRINGEOL = 12;
  SCE_LUA_WORD2 = 13;
  SCE_LUA_WORD3 = 14;
  SCE_LUA_WORD4 = 15;
  SCE_LUA_WORD5 = 16;
  SCE_LUA_WORD6 = 17;
  SCE_LUA_WORD7 = 18;
  SCE_LUA_WORD8 = 19;
  SCE_LUA_LABEL = 20;

  /// <summary>Lexical states for SCLEX_ERRORLIST</summary>
  SCE_ERR_DEFAULT = 0;
  SCE_ERR_PYTHON = 1;
  SCE_ERR_GCC = 2;
  SCE_ERR_MS = 3;
  SCE_ERR_CMD = 4;
  SCE_ERR_BORLAND = 5;
  SCE_ERR_PERL = 6;
  SCE_ERR_NET = 7;
  SCE_ERR_LUA = 8;
  SCE_ERR_CTAG = 9;
  SCE_ERR_DIFF_CHANGED = 10;
  SCE_ERR_DIFF_ADDITION = 11;
  SCE_ERR_DIFF_DELETION = 12;
  SCE_ERR_DIFF_MESSAGE = 13;
  SCE_ERR_PHP = 14;
  SCE_ERR_ELF = 15;
  SCE_ERR_IFC = 16;
  SCE_ERR_IFORT = 17;
  SCE_ERR_ABSF = 18;
  SCE_ERR_TIDY = 19;
  SCE_ERR_JAVA_STACK = 20;
  SCE_ERR_VALUE = 21;
  SCE_ERR_GCC_INCLUDED_FROM = 22;
  SCE_ERR_ESCSEQ = 23;
  SCE_ERR_ESCSEQ_UNKNOWN = 24;
  SCE_ERR_GCC_EXCERPT = 25;
  SCE_ERR_BASH = 26;
  SCE_ERR_ES_BLACK = 40;
  SCE_ERR_ES_RED = 41;
  SCE_ERR_ES_GREEN = 42;
  SCE_ERR_ES_BROWN = 43;
  SCE_ERR_ES_BLUE = 44;
  SCE_ERR_ES_MAGENTA = 45;
  SCE_ERR_ES_CYAN = 46;
  SCE_ERR_ES_GRAY = 47;
  SCE_ERR_ES_DARK_GRAY = 48;
  SCE_ERR_ES_BRIGHT_RED = 49;
  SCE_ERR_ES_BRIGHT_GREEN = 50;
  SCE_ERR_ES_YELLOW = 51;
  SCE_ERR_ES_BRIGHT_BLUE = 52;
  SCE_ERR_ES_BRIGHT_MAGENTA = 53;
  SCE_ERR_ES_BRIGHT_CYAN = 54;
  SCE_ERR_ES_WHITE = 55;

  /// <summary>Lexical states for SCLEX_BATCH</summary>
  SCE_BAT_DEFAULT = 0;
  SCE_BAT_COMMENT = 1;
  SCE_BAT_WORD = 2;
  SCE_BAT_LABEL = 3;
  SCE_BAT_HIDE = 4;
  SCE_BAT_COMMAND = 5;
  SCE_BAT_IDENTIFIER = 6;
  SCE_BAT_OPERATOR = 7;
  SCE_BAT_AFTER_LABEL = 8;

  /// <summary>Lexical states for SCLEX_TCMD</summary>
  SCE_TCMD_DEFAULT = 0;
  SCE_TCMD_COMMENT = 1;
  SCE_TCMD_WORD = 2;
  SCE_TCMD_LABEL = 3;
  SCE_TCMD_HIDE = 4;
  SCE_TCMD_COMMAND = 5;
  SCE_TCMD_IDENTIFIER = 6;
  SCE_TCMD_OPERATOR = 7;
  SCE_TCMD_ENVIRONMENT = 8;
  SCE_TCMD_EXPANSION = 9;
  SCE_TCMD_CLABEL = 10;

  /// <summary>Lexical states for SCLEX_MAKEFILE</summary>
  SCE_MAKE_DEFAULT = 0;
  SCE_MAKE_COMMENT = 1;
  SCE_MAKE_PREPROCESSOR = 2;
  SCE_MAKE_IDENTIFIER = 3;
  SCE_MAKE_OPERATOR = 4;
  SCE_MAKE_TARGET = 5;
  SCE_MAKE_IDEOL = 9;

  /// <summary>Lexical states for SCLEX_DIFF</summary>
  SCE_DIFF_DEFAULT = 0;
  SCE_DIFF_COMMENT = 1;
  SCE_DIFF_COMMAND = 2;
  SCE_DIFF_HEADER = 3;
  SCE_DIFF_POSITION = 4;
  SCE_DIFF_DELETED = 5;
  SCE_DIFF_ADDED = 6;
  SCE_DIFF_CHANGED = 7;
  SCE_DIFF_PATCH_ADD = 8;
  SCE_DIFF_PATCH_DELETE = 9;
  SCE_DIFF_REMOVED_PATCH_ADD = 10;
  SCE_DIFF_REMOVED_PATCH_DELETE = 11;

  /// <summary>Lexical states for SCLEX_CONF (Apache Configuration Files Lexer)</summary>
  SCE_CONF_DEFAULT = 0;
  SCE_CONF_COMMENT = 1;
  SCE_CONF_NUMBER = 2;
  SCE_CONF_IDENTIFIER = 3;
  SCE_CONF_EXTENSION = 4;
  SCE_CONF_PARAMETER = 5;
  SCE_CONF_STRING = 6;
  SCE_CONF_OPERATOR = 7;
  SCE_CONF_IP = 8;
  SCE_CONF_DIRECTIVE = 9;

  /// <summary>Lexical states for SCLEX_AVE, Avenue</summary>
  SCE_AVE_DEFAULT = 0;
  SCE_AVE_COMMENT = 1;
  SCE_AVE_NUMBER = 2;
  SCE_AVE_WORD = 3;
  SCE_AVE_STRING = 6;
  SCE_AVE_ENUM = 7;
  SCE_AVE_STRINGEOL = 8;
  SCE_AVE_IDENTIFIER = 9;
  SCE_AVE_OPERATOR = 10;
  SCE_AVE_WORD1 = 11;
  SCE_AVE_WORD2 = 12;
  SCE_AVE_WORD3 = 13;
  SCE_AVE_WORD4 = 14;
  SCE_AVE_WORD5 = 15;
  SCE_AVE_WORD6 = 16;

  /// <summary>Lexical states for SCLEX_ADA</summary>
  SCE_ADA_DEFAULT = 0;
  SCE_ADA_WORD = 1;
  SCE_ADA_IDENTIFIER = 2;
  SCE_ADA_NUMBER = 3;
  SCE_ADA_DELIMITER = 4;
  SCE_ADA_CHARACTER = 5;
  SCE_ADA_CHARACTEREOL = 6;
  SCE_ADA_STRING = 7;
  SCE_ADA_STRINGEOL = 8;
  SCE_ADA_LABEL = 9;
  SCE_ADA_COMMENTLINE = 10;
  SCE_ADA_ILLEGAL = 11;

  /// <summary>Lexical states for SCLEX_BAAN</summary>
  SCE_BAAN_DEFAULT = 0;
  SCE_BAAN_COMMENT = 1;
  SCE_BAAN_COMMENTDOC = 2;
  SCE_BAAN_NUMBER = 3;
  SCE_BAAN_WORD = 4;
  SCE_BAAN_STRING = 5;
  SCE_BAAN_PREPROCESSOR = 6;
  SCE_BAAN_OPERATOR = 7;
  SCE_BAAN_IDENTIFIER = 8;
  SCE_BAAN_STRINGEOL = 9;
  SCE_BAAN_WORD2 = 10;
  SCE_BAAN_WORD3 = 11;
  SCE_BAAN_WORD4 = 12;
  SCE_BAAN_WORD5 = 13;
  SCE_BAAN_WORD6 = 14;
  SCE_BAAN_WORD7 = 15;
  SCE_BAAN_WORD8 = 16;
  SCE_BAAN_WORD9 = 17;
  SCE_BAAN_TABLEDEF = 18;
  SCE_BAAN_TABLESQL = 19;
  SCE_BAAN_FUNCTION = 20;
  SCE_BAAN_DOMDEF = 21;
  SCE_BAAN_FUNCDEF = 22;
  SCE_BAAN_OBJECTDEF = 23;
  SCE_BAAN_DEFINEDEF = 24;

  /// <summary>Lexical states for SCLEX_LISP</summary>
  SCE_LISP_DEFAULT = 0;
  SCE_LISP_COMMENT = 1;
  SCE_LISP_NUMBER = 2;
  SCE_LISP_KEYWORD = 3;
  SCE_LISP_KEYWORD_KW = 4;
  SCE_LISP_SYMBOL = 5;
  SCE_LISP_STRING = 6;
  SCE_LISP_STRINGEOL = 8;
  SCE_LISP_IDENTIFIER = 9;
  SCE_LISP_OPERATOR = 10;
  SCE_LISP_SPECIAL = 11;
  SCE_LISP_MULTI_COMMENT = 12;

  /// <summary>Lexical states for SCLEX_EIFFEL and SCLEX_EIFFELKW</summary>
  SCE_EIFFEL_DEFAULT = 0;
  SCE_EIFFEL_COMMENTLINE = 1;
  SCE_EIFFEL_NUMBER = 2;
  SCE_EIFFEL_WORD = 3;
  SCE_EIFFEL_STRING = 4;
  SCE_EIFFEL_CHARACTER = 5;
  SCE_EIFFEL_OPERATOR = 6;
  SCE_EIFFEL_IDENTIFIER = 7;
  SCE_EIFFEL_STRINGEOL = 8;

  /// <summary>Lexical states for SCLEX_NNCRONTAB (nnCron crontab Lexer)</summary>
  SCE_NNCRONTAB_DEFAULT = 0;
  SCE_NNCRONTAB_COMMENT = 1;
  SCE_NNCRONTAB_TASK = 2;
  SCE_NNCRONTAB_SECTION = 3;
  SCE_NNCRONTAB_KEYWORD = 4;
  SCE_NNCRONTAB_MODIFIER = 5;
  SCE_NNCRONTAB_ASTERISK = 6;
  SCE_NNCRONTAB_NUMBER = 7;
  SCE_NNCRONTAB_STRING = 8;
  SCE_NNCRONTAB_ENVIRONMENT = 9;
  SCE_NNCRONTAB_IDENTIFIER = 10;

  /// <summary>Lexical states for SCLEX_FORTH (Forth Lexer)</summary>
  SCE_FORTH_DEFAULT = 0;
  SCE_FORTH_COMMENT = 1;
  SCE_FORTH_COMMENT_ML = 2;
  SCE_FORTH_IDENTIFIER = 3;
  SCE_FORTH_CONTROL = 4;
  SCE_FORTH_KEYWORD = 5;
  SCE_FORTH_DEFWORD = 6;
  SCE_FORTH_PREWORD1 = 7;
  SCE_FORTH_PREWORD2 = 8;
  SCE_FORTH_NUMBER = 9;
  SCE_FORTH_STRING = 10;
  SCE_FORTH_LOCALE = 11;

  /// <summary>Lexical states for SCLEX_MATLAB</summary>
  SCE_MATLAB_DEFAULT = 0;
  SCE_MATLAB_COMMENT = 1;
  SCE_MATLAB_COMMAND = 2;
  SCE_MATLAB_NUMBER = 3;
  SCE_MATLAB_KEYWORD = 4;

  /// <summary>single quoted string</summary>
  SCE_MATLAB_STRING = 5;
  SCE_MATLAB_OPERATOR = 6;
  SCE_MATLAB_IDENTIFIER = 7;
  SCE_MATLAB_DOUBLEQUOTESTRING = 8;

  /// <summary>Lexical states for SCLEX_MAXIMA</summary>
  SCE_MAXIMA_OPERATOR = 0;
  SCE_MAXIMA_COMMANDENDING = 1;
  SCE_MAXIMA_COMMENT = 2;
  SCE_MAXIMA_NUMBER = 3;
  SCE_MAXIMA_STRING = 4;
  SCE_MAXIMA_COMMAND = 5;
  SCE_MAXIMA_VARIABLE = 6;
  SCE_MAXIMA_UNKNOWN = 7;

  /// <summary>Lexical states for SCLEX_SCRIPTOL</summary>
  SCE_SCRIPTOL_DEFAULT = 0;
  SCE_SCRIPTOL_WHITE = 1;
  SCE_SCRIPTOL_COMMENTLINE = 2;
  SCE_SCRIPTOL_PERSISTENT = 3;
  SCE_SCRIPTOL_CSTYLE = 4;
  SCE_SCRIPTOL_COMMENTBLOCK = 5;
  SCE_SCRIPTOL_NUMBER = 6;
  SCE_SCRIPTOL_STRING = 7;
  SCE_SCRIPTOL_CHARACTER = 8;
  SCE_SCRIPTOL_STRINGEOL = 9;
  SCE_SCRIPTOL_KEYWORD = 10;
  SCE_SCRIPTOL_OPERATOR = 11;
  SCE_SCRIPTOL_IDENTIFIER = 12;
  SCE_SCRIPTOL_TRIPLE = 13;
  SCE_SCRIPTOL_CLASSNAME = 14;
  SCE_SCRIPTOL_PREPROCESSOR = 15;

  /// <summary>Lexical states for SCLEX_ASM, SCLEX_AS</summary>
  SCE_ASM_DEFAULT = 0;
  SCE_ASM_COMMENT = 1;
  SCE_ASM_NUMBER = 2;
  SCE_ASM_STRING = 3;
  SCE_ASM_OPERATOR = 4;
  SCE_ASM_IDENTIFIER = 5;
  SCE_ASM_CPUINSTRUCTION = 6;
  SCE_ASM_MATHINSTRUCTION = 7;
  SCE_ASM_REGISTER = 8;
  SCE_ASM_DIRECTIVE = 9;
  SCE_ASM_DIRECTIVEOPERAND = 10;
  SCE_ASM_COMMENTBLOCK = 11;
  SCE_ASM_CHARACTER = 12;
  SCE_ASM_STRINGEOL = 13;
  SCE_ASM_EXTINSTRUCTION = 14;
  SCE_ASM_COMMENTDIRECTIVE = 15;

  /// <summary>Lexical states for SCLEX_FORTRAN</summary>
  SCE_F_DEFAULT = 0;
  SCE_F_COMMENT = 1;
  SCE_F_NUMBER = 2;
  SCE_F_STRING1 = 3;
  SCE_F_STRING2 = 4;
  SCE_F_STRINGEOL = 5;
  SCE_F_OPERATOR = 6;
  SCE_F_IDENTIFIER = 7;
  SCE_F_WORD = 8;
  SCE_F_WORD2 = 9;
  SCE_F_WORD3 = 10;
  SCE_F_PREPROCESSOR = 11;
  SCE_F_OPERATOR2 = 12;
  SCE_F_LABEL = 13;
  SCE_F_CONTINUATION = 14;

  /// <summary>Lexical states for SCLEX_CSS</summary>
  SCE_CSS_DEFAULT = 0;
  SCE_CSS_TAG = 1;
  SCE_CSS_CLASS = 2;
  SCE_CSS_PSEUDOCLASS = 3;
  SCE_CSS_UNKNOWN_PSEUDOCLASS = 4;
  SCE_CSS_OPERATOR = 5;
  SCE_CSS_IDENTIFIER = 6;
  SCE_CSS_UNKNOWN_IDENTIFIER = 7;
  SCE_CSS_VALUE = 8;
  SCE_CSS_COMMENT = 9;
  SCE_CSS_ID = 10;
  SCE_CSS_IMPORTANT = 11;
  SCE_CSS_DIRECTIVE = 12;
  SCE_CSS_DOUBLESTRING = 13;
  SCE_CSS_SINGLESTRING = 14;
  SCE_CSS_IDENTIFIER2 = 15;
  SCE_CSS_ATTRIBUTE = 16;
  SCE_CSS_IDENTIFIER3 = 17;
  SCE_CSS_PSEUDOELEMENT = 18;
  SCE_CSS_EXTENDED_IDENTIFIER = 19;
  SCE_CSS_EXTENDED_PSEUDOCLASS = 20;
  SCE_CSS_EXTENDED_PSEUDOELEMENT = 21;
  SCE_CSS_GROUP_RULE = 22;
  SCE_CSS_VARIABLE = 23;

  /// <summary>Lexical states for SCLEX_POV</summary>
  SCE_POV_DEFAULT = 0;
  SCE_POV_COMMENT = 1;
  SCE_POV_COMMENTLINE = 2;
  SCE_POV_NUMBER = 3;
  SCE_POV_OPERATOR = 4;
  SCE_POV_IDENTIFIER = 5;
  SCE_POV_STRING = 6;
  SCE_POV_STRINGEOL = 7;
  SCE_POV_DIRECTIVE = 8;
  SCE_POV_BADDIRECTIVE = 9;
  SCE_POV_WORD2 = 10;
  SCE_POV_WORD3 = 11;
  SCE_POV_WORD4 = 12;
  SCE_POV_WORD5 = 13;
  SCE_POV_WORD6 = 14;
  SCE_POV_WORD7 = 15;
  SCE_POV_WORD8 = 16;

  /// <summary>Lexical states for SCLEX_LOUT</summary>
  SCE_LOUT_DEFAULT = 0;
  SCE_LOUT_COMMENT = 1;
  SCE_LOUT_NUMBER = 2;
  SCE_LOUT_WORD = 3;
  SCE_LOUT_WORD2 = 4;
  SCE_LOUT_WORD3 = 5;
  SCE_LOUT_WORD4 = 6;
  SCE_LOUT_STRING = 7;
  SCE_LOUT_OPERATOR = 8;
  SCE_LOUT_IDENTIFIER = 9;
  SCE_LOUT_STRINGEOL = 10;

  /// <summary>Lexical states for SCLEX_ESCRIPT</summary>
  SCE_ESCRIPT_DEFAULT = 0;
  SCE_ESCRIPT_COMMENT = 1;
  SCE_ESCRIPT_COMMENTLINE = 2;
  SCE_ESCRIPT_COMMENTDOC = 3;
  SCE_ESCRIPT_NUMBER = 4;
  SCE_ESCRIPT_WORD = 5;
  SCE_ESCRIPT_STRING = 6;
  SCE_ESCRIPT_OPERATOR = 7;
  SCE_ESCRIPT_IDENTIFIER = 8;
  SCE_ESCRIPT_BRACE = 9;
  SCE_ESCRIPT_WORD2 = 10;
  SCE_ESCRIPT_WORD3 = 11;

  /// <summary>Lexical states for SCLEX_PS</summary>
  SCE_PS_DEFAULT = 0;
  SCE_PS_COMMENT = 1;
  SCE_PS_DSC_COMMENT = 2;
  SCE_PS_DSC_VALUE = 3;
  SCE_PS_NUMBER = 4;
  SCE_PS_NAME = 5;
  SCE_PS_KEYWORD = 6;
  SCE_PS_LITERAL = 7;
  SCE_PS_IMMEVAL = 8;
  SCE_PS_PAREN_ARRAY = 9;
  SCE_PS_PAREN_DICT = 10;
  SCE_PS_PAREN_PROC = 11;
  SCE_PS_TEXT = 12;
  SCE_PS_HEXSTRING = 13;
  SCE_PS_BASE85STRING = 14;
  SCE_PS_BADSTRINGCHAR = 15;

  /// <summary>Lexical states for SCLEX_NSIS</summary>
  SCE_NSIS_DEFAULT = 0;
  SCE_NSIS_COMMENT = 1;
  SCE_NSIS_STRINGDQ = 2;
  SCE_NSIS_STRINGLQ = 3;
  SCE_NSIS_STRINGRQ = 4;
  SCE_NSIS_FUNCTION = 5;
  SCE_NSIS_VARIABLE = 6;
  SCE_NSIS_LABEL = 7;
  SCE_NSIS_USERDEFINED = 8;
  SCE_NSIS_SECTIONDEF = 9;
  SCE_NSIS_SUBSECTIONDEF = 10;
  SCE_NSIS_IFDEFINEDEF = 11;
  SCE_NSIS_MACRODEF = 12;
  SCE_NSIS_STRINGVAR = 13;
  SCE_NSIS_NUMBER = 14;
  SCE_NSIS_SECTIONGROUP = 15;
  SCE_NSIS_PAGEEX = 16;
  SCE_NSIS_FUNCTIONDEF = 17;
  SCE_NSIS_COMMENTBOX = 18;

  /// <summary>Lexical states for SCLEX_MMIXAL</summary>
  SCE_MMIXAL_LEADWS = 0;
  SCE_MMIXAL_COMMENT = 1;
  SCE_MMIXAL_LABEL = 2;
  SCE_MMIXAL_OPCODE = 3;
  SCE_MMIXAL_OPCODE_PRE = 4;
  SCE_MMIXAL_OPCODE_VALID = 5;
  SCE_MMIXAL_OPCODE_UNKNOWN = 6;
  SCE_MMIXAL_OPCODE_POST = 7;
  SCE_MMIXAL_OPERANDS = 8;
  SCE_MMIXAL_NUMBER = 9;
  SCE_MMIXAL_REF = 10;
  SCE_MMIXAL_CHAR = 11;
  SCE_MMIXAL_STRING = 12;
  SCE_MMIXAL_REGISTER = 13;
  SCE_MMIXAL_HEX = 14;
  SCE_MMIXAL_OPERATOR = 15;
  SCE_MMIXAL_SYMBOL = 16;
  SCE_MMIXAL_INCLUDE = 17;

  /// <summary>Lexical states for SCLEX_CLW</summary>
  SCE_CLW_DEFAULT = 0;
  SCE_CLW_LABEL = 1;
  SCE_CLW_COMMENT = 2;
  SCE_CLW_STRING = 3;
  SCE_CLW_USER_IDENTIFIER = 4;
  SCE_CLW_INTEGER_CONSTANT = 5;
  SCE_CLW_REAL_CONSTANT = 6;
  SCE_CLW_PICTURE_STRING = 7;
  SCE_CLW_KEYWORD = 8;
  SCE_CLW_COMPILER_DIRECTIVE = 9;
  SCE_CLW_RUNTIME_EXPRESSIONS = 10;
  SCE_CLW_BUILTIN_PROCEDURES_FUNCTION = 11;
  SCE_CLW_STRUCTURE_DATA_TYPE = 12;
  SCE_CLW_ATTRIBUTE = 13;
  SCE_CLW_STANDARD_EQUATE = 14;
  SCE_CLW_ERROR = 15;
  SCE_CLW_DEPRECATED = 16;

  /// <summary>Lexical states for SCLEX_LOT</summary>
  SCE_LOT_DEFAULT = 0;
  SCE_LOT_HEADER = 1;
  SCE_LOT_BREAK = 2;
  SCE_LOT_SET = 3;
  SCE_LOT_PASS = 4;
  SCE_LOT_FAIL = 5;
  SCE_LOT_ABORT = 6;

  /// <summary>Lexical states for SCLEX_YAML</summary>
  SCE_YAML_DEFAULT = 0;
  SCE_YAML_COMMENT = 1;
  SCE_YAML_IDENTIFIER = 2;
  SCE_YAML_KEYWORD = 3;
  SCE_YAML_NUMBER = 4;
  SCE_YAML_REFERENCE = 5;
  SCE_YAML_DOCUMENT = 6;
  SCE_YAML_TEXT = 7;
  SCE_YAML_ERROR = 8;
  SCE_YAML_OPERATOR = 9;

  /// <summary>Lexical states for SCLEX_TEX</summary>
  SCE_TEX_DEFAULT = 0;
  SCE_TEX_SPECIAL = 1;
  SCE_TEX_GROUP = 2;
  SCE_TEX_SYMBOL = 3;
  SCE_TEX_COMMAND = 4;
  SCE_TEX_TEXT = 5;
  SCE_METAPOST_DEFAULT = 0;
  SCE_METAPOST_SPECIAL = 1;
  SCE_METAPOST_GROUP = 2;
  SCE_METAPOST_SYMBOL = 3;
  SCE_METAPOST_COMMAND = 4;
  SCE_METAPOST_TEXT = 5;
  SCE_METAPOST_EXTRA = 6;

  /// <summary>Lexical states for SCLEX_ERLANG</summary>
  SCE_ERLANG_DEFAULT = 0;
  SCE_ERLANG_COMMENT = 1;
  SCE_ERLANG_VARIABLE = 2;
  SCE_ERLANG_NUMBER = 3;
  SCE_ERLANG_KEYWORD = 4;
  SCE_ERLANG_STRING = 5;
  SCE_ERLANG_OPERATOR = 6;
  SCE_ERLANG_ATOM = 7;
  SCE_ERLANG_FUNCTION_NAME = 8;
  SCE_ERLANG_CHARACTER = 9;
  SCE_ERLANG_MACRO = 10;
  SCE_ERLANG_RECORD = 11;
  SCE_ERLANG_PREPROC = 12;
  SCE_ERLANG_NODE_NAME = 13;
  SCE_ERLANG_COMMENT_FUNCTION = 14;
  SCE_ERLANG_COMMENT_MODULE = 15;
  SCE_ERLANG_COMMENT_DOC = 16;
  SCE_ERLANG_COMMENT_DOC_MACRO = 17;
  SCE_ERLANG_ATOM_QUOTED = 18;
  SCE_ERLANG_MACRO_QUOTED = 19;
  SCE_ERLANG_RECORD_QUOTED = 20;
  SCE_ERLANG_NODE_NAME_QUOTED = 21;
  SCE_ERLANG_BIFS = 22;
  SCE_ERLANG_MODULES = 23;
  SCE_ERLANG_MODULES_ATT = 24;
  SCE_ERLANG_UNKNOWN = 31;

  /// <summary>Lexical states for SCLEX_OCTAVE are identical to MatLab
  /// Lexical states for SCLEX_JULIA</summary>
  SCE_JULIA_DEFAULT = 0;
  SCE_JULIA_COMMENT = 1;
  SCE_JULIA_NUMBER = 2;
  SCE_JULIA_KEYWORD1 = 3;
  SCE_JULIA_KEYWORD2 = 4;
  SCE_JULIA_KEYWORD3 = 5;
  SCE_JULIA_CHAR = 6;
  SCE_JULIA_OPERATOR = 7;
  SCE_JULIA_BRACKET = 8;
  SCE_JULIA_IDENTIFIER = 9;
  SCE_JULIA_STRING = 10;
  SCE_JULIA_SYMBOL = 11;
  SCE_JULIA_MACRO = 12;
  SCE_JULIA_STRINGINTERP = 13;
  SCE_JULIA_DOCSTRING = 14;
  SCE_JULIA_STRINGLITERAL = 15;
  SCE_JULIA_COMMAND = 16;
  SCE_JULIA_COMMANDLITERAL = 17;
  SCE_JULIA_TYPEANNOT = 18;
  SCE_JULIA_LEXERROR = 19;
  SCE_JULIA_KEYWORD4 = 20;
  SCE_JULIA_TYPEOPERATOR = 21;

  /// <summary>Lexical states for SCLEX_MSSQL</summary>
  SCE_MSSQL_DEFAULT = 0;
  SCE_MSSQL_COMMENT = 1;
  SCE_MSSQL_LINE_COMMENT = 2;
  SCE_MSSQL_NUMBER = 3;
  SCE_MSSQL_STRING = 4;
  SCE_MSSQL_OPERATOR = 5;
  SCE_MSSQL_IDENTIFIER = 6;
  SCE_MSSQL_VARIABLE = 7;
  SCE_MSSQL_COLUMN_NAME = 8;
  SCE_MSSQL_STATEMENT = 9;
  SCE_MSSQL_DATATYPE = 10;
  SCE_MSSQL_SYSTABLE = 11;
  SCE_MSSQL_GLOBAL_VARIABLE = 12;
  SCE_MSSQL_FUNCTION = 13;
  SCE_MSSQL_STORED_PROCEDURE = 14;
  SCE_MSSQL_DEFAULT_PREF_DATATYPE = 15;
  SCE_MSSQL_COLUMN_NAME_2 = 16;

  /// <summary>Lexical states for SCLEX_VERILOG</summary>
  SCE_V_DEFAULT = 0;
  SCE_V_COMMENT = 1;
  SCE_V_COMMENTLINE = 2;
  SCE_V_COMMENTLINEBANG = 3;
  SCE_V_NUMBER = 4;
  SCE_V_WORD = 5;
  SCE_V_STRING = 6;
  SCE_V_WORD2 = 7;
  SCE_V_WORD3 = 8;
  SCE_V_PREPROCESSOR = 9;
  SCE_V_OPERATOR = 10;
  SCE_V_IDENTIFIER = 11;
  SCE_V_STRINGEOL = 12;
  SCE_V_USER = 19;
  SCE_V_COMMENT_WORD = 20;
  SCE_V_INPUT = 21;
  SCE_V_OUTPUT = 22;
  SCE_V_INOUT = 23;
  SCE_V_PORT_CONNECT = 24;

  /// <summary>Lexical states for SCLEX_KIX</summary>
  SCE_KIX_DEFAULT = 0;
  SCE_KIX_COMMENT = 1;
  SCE_KIX_STRING1 = 2;
  SCE_KIX_STRING2 = 3;
  SCE_KIX_NUMBER = 4;
  SCE_KIX_VAR = 5;
  SCE_KIX_MACRO = 6;
  SCE_KIX_KEYWORD = 7;
  SCE_KIX_FUNCTIONS = 8;
  SCE_KIX_OPERATOR = 9;
  SCE_KIX_COMMENTSTREAM = 10;
  SCE_KIX_IDENTIFIER = 31;

  /// <summary>Lexical states for SCLEX_GUI4CLI</summary>
  SCE_GC_DEFAULT = 0;
  SCE_GC_COMMENTLINE = 1;
  SCE_GC_COMMENTBLOCK = 2;
  SCE_GC_GLOBAL = 3;
  SCE_GC_EVENT = 4;
  SCE_GC_ATTRIBUTE = 5;
  SCE_GC_CONTROL = 6;
  SCE_GC_COMMAND = 7;
  SCE_GC_STRING = 8;
  SCE_GC_OPERATOR = 9;

  /// <summary>Lexical states for SCLEX_SPECMAN</summary>
  SCE_SN_DEFAULT = 0;
  SCE_SN_CODE = 1;
  SCE_SN_COMMENTLINE = 2;
  SCE_SN_COMMENTLINEBANG = 3;
  SCE_SN_NUMBER = 4;
  SCE_SN_WORD = 5;
  SCE_SN_STRING = 6;
  SCE_SN_WORD2 = 7;
  SCE_SN_WORD3 = 8;
  SCE_SN_PREPROCESSOR = 9;
  SCE_SN_OPERATOR = 10;
  SCE_SN_IDENTIFIER = 11;
  SCE_SN_STRINGEOL = 12;
  SCE_SN_REGEXTAG = 13;
  SCE_SN_SIGNAL = 14;
  SCE_SN_USER = 19;

  /// <summary>Lexical states for SCLEX_AU3</summary>
  SCE_AU3_DEFAULT = 0;
  SCE_AU3_COMMENT = 1;
  SCE_AU3_COMMENTBLOCK = 2;
  SCE_AU3_NUMBER = 3;
  SCE_AU3_FUNCTION = 4;
  SCE_AU3_KEYWORD = 5;
  SCE_AU3_MACRO = 6;
  SCE_AU3_STRING = 7;
  SCE_AU3_OPERATOR = 8;
  SCE_AU3_VARIABLE = 9;
  SCE_AU3_SENT = 10;
  SCE_AU3_PREPROCESSOR = 11;
  SCE_AU3_SPECIAL = 12;
  SCE_AU3_EXPAND = 13;
  SCE_AU3_COMOBJ = 14;
  SCE_AU3_UDF = 15;

  /// <summary>Lexical states for SCLEX_APDL</summary>
  SCE_APDL_DEFAULT = 0;
  SCE_APDL_COMMENT = 1;
  SCE_APDL_COMMENTBLOCK = 2;
  SCE_APDL_NUMBER = 3;
  SCE_APDL_STRING = 4;
  SCE_APDL_OPERATOR = 5;
  SCE_APDL_WORD = 6;
  SCE_APDL_PROCESSOR = 7;
  SCE_APDL_COMMAND = 8;
  SCE_APDL_SLASHCOMMAND = 9;
  SCE_APDL_STARCOMMAND = 10;
  SCE_APDL_ARGUMENT = 11;
  SCE_APDL_FUNCTION = 12;

  /// <summary>Lexical states for SCLEX_BASH</summary>
  SCE_SH_DEFAULT = 0;
  SCE_SH_ERROR = 1;
  SCE_SH_COMMENTLINE = 2;
  SCE_SH_NUMBER = 3;
  SCE_SH_WORD = 4;
  SCE_SH_STRING = 5;
  SCE_SH_CHARACTER = 6;
  SCE_SH_OPERATOR = 7;
  SCE_SH_IDENTIFIER = 8;
  SCE_SH_SCALAR = 9;
  SCE_SH_PARAM = 10;
  SCE_SH_BACKTICKS = 11;
  SCE_SH_HERE_DELIM = 12;
  SCE_SH_HERE_Q = 13;

  /// <summary>Lexical states for SCLEX_ASN1</summary>
  SCE_ASN1_DEFAULT = 0;
  SCE_ASN1_COMMENT = 1;
  SCE_ASN1_IDENTIFIER = 2;
  SCE_ASN1_STRING = 3;
  SCE_ASN1_OID = 4;
  SCE_ASN1_SCALAR = 5;
  SCE_ASN1_KEYWORD = 6;
  SCE_ASN1_ATTRIBUTE = 7;
  SCE_ASN1_DESCRIPTOR = 8;
  SCE_ASN1_TYPE = 9;
  SCE_ASN1_OPERATOR = 10;

  /// <summary>Lexical states for SCLEX_VHDL</summary>
  SCE_VHDL_DEFAULT = 0;
  SCE_VHDL_COMMENT = 1;
  SCE_VHDL_COMMENTLINEBANG = 2;
  SCE_VHDL_NUMBER = 3;
  SCE_VHDL_STRING = 4;
  SCE_VHDL_OPERATOR = 5;
  SCE_VHDL_IDENTIFIER = 6;
  SCE_VHDL_STRINGEOL = 7;
  SCE_VHDL_KEYWORD = 8;
  SCE_VHDL_STDOPERATOR = 9;
  SCE_VHDL_ATTRIBUTE = 10;
  SCE_VHDL_STDFUNCTION = 11;
  SCE_VHDL_STDPACKAGE = 12;
  SCE_VHDL_STDTYPE = 13;
  SCE_VHDL_USERWORD = 14;
  SCE_VHDL_BLOCK_COMMENT = 15;

  /// <summary>Lexical states for SCLEX_CAML</summary>
  SCE_CAML_DEFAULT = 0;
  SCE_CAML_IDENTIFIER = 1;
  SCE_CAML_TAGNAME = 2;
  SCE_CAML_KEYWORD = 3;
  SCE_CAML_KEYWORD2 = 4;
  SCE_CAML_KEYWORD3 = 5;
  SCE_CAML_LINENUM = 6;
  SCE_CAML_OPERATOR = 7;
  SCE_CAML_NUMBER = 8;
  SCE_CAML_CHAR = 9;
  SCE_CAML_WHITE = 10;
  SCE_CAML_STRING = 11;
  SCE_CAML_COMMENT = 12;
  SCE_CAML_COMMENT1 = 13;
  SCE_CAML_COMMENT2 = 14;
  SCE_CAML_COMMENT3 = 15;

  /// <summary>Lexical states for SCLEX_HASKELL</summary>
  SCE_HA_DEFAULT = 0;
  SCE_HA_IDENTIFIER = 1;
  SCE_HA_KEYWORD = 2;
  SCE_HA_NUMBER = 3;
  SCE_HA_STRING = 4;
  SCE_HA_CHARACTER = 5;
  SCE_HA_CLASS = 6;
  SCE_HA_MODULE = 7;
  SCE_HA_CAPITAL = 8;
  SCE_HA_DATA = 9;
  SCE_HA_IMPORT = 10;
  SCE_HA_OPERATOR = 11;
  SCE_HA_INSTANCE = 12;
  SCE_HA_COMMENTLINE = 13;
  SCE_HA_COMMENTBLOCK = 14;
  SCE_HA_COMMENTBLOCK2 = 15;
  SCE_HA_COMMENTBLOCK3 = 16;
  SCE_HA_PRAGMA = 17;
  SCE_HA_PREPROCESSOR = 18;
  SCE_HA_STRINGEOL = 19;
  SCE_HA_RESERVED_OPERATOR = 20;
  SCE_HA_LITERATE_COMMENT = 21;
  SCE_HA_LITERATE_CODEDELIM = 22;

  /// <summary>Lexical states of SCLEX_TADS3</summary>
  SCE_T3_DEFAULT = 0;
  SCE_T3_X_DEFAULT = 1;
  SCE_T3_PREPROCESSOR = 2;
  SCE_T3_BLOCK_COMMENT = 3;
  SCE_T3_LINE_COMMENT = 4;
  SCE_T3_OPERATOR = 5;
  SCE_T3_KEYWORD = 6;
  SCE_T3_NUMBER = 7;
  SCE_T3_IDENTIFIER = 8;
  SCE_T3_S_STRING = 9;
  SCE_T3_D_STRING = 10;
  SCE_T3_X_STRING = 11;
  SCE_T3_LIB_DIRECTIVE = 12;
  SCE_T3_MSG_PARAM = 13;
  SCE_T3_HTML_TAG = 14;
  SCE_T3_HTML_DEFAULT = 15;
  SCE_T3_HTML_STRING = 16;
  SCE_T3_USER1 = 17;
  SCE_T3_USER2 = 18;
  SCE_T3_USER3 = 19;
  SCE_T3_BRACE = 20;

  /// <summary>Lexical states for SCLEX_REBOL</summary>
  SCE_REBOL_DEFAULT = 0;
  SCE_REBOL_COMMENTLINE = 1;
  SCE_REBOL_COMMENTBLOCK = 2;
  SCE_REBOL_PREFACE = 3;
  SCE_REBOL_OPERATOR = 4;
  SCE_REBOL_CHARACTER = 5;
  SCE_REBOL_QUOTEDSTRING = 6;
  SCE_REBOL_BRACEDSTRING = 7;
  SCE_REBOL_NUMBER = 8;
  SCE_REBOL_PAIR = 9;
  SCE_REBOL_TUPLE = 10;
  SCE_REBOL_BINARY = 11;
  SCE_REBOL_MONEY = 12;
  SCE_REBOL_ISSUE = 13;
  SCE_REBOL_TAG = 14;
  SCE_REBOL_FILE = 15;
  SCE_REBOL_EMAIL = 16;
  SCE_REBOL_URL = 17;
  SCE_REBOL_DATE = 18;
  SCE_REBOL_TIME = 19;
  SCE_REBOL_IDENTIFIER = 20;
  SCE_REBOL_WORD = 21;
  SCE_REBOL_WORD2 = 22;
  SCE_REBOL_WORD3 = 23;
  SCE_REBOL_WORD4 = 24;
  SCE_REBOL_WORD5 = 25;
  SCE_REBOL_WORD6 = 26;
  SCE_REBOL_WORD7 = 27;
  SCE_REBOL_WORD8 = 28;

  /// <summary>Lexical states for SCLEX_SQL</summary>
  SCE_SQL_DEFAULT = 0;
  SCE_SQL_COMMENT = 1;
  SCE_SQL_COMMENTLINE = 2;
  SCE_SQL_COMMENTDOC = 3;
  SCE_SQL_NUMBER = 4;
  SCE_SQL_WORD = 5;
  SCE_SQL_STRING = 6;
  SCE_SQL_CHARACTER = 7;
  SCE_SQL_SQLPLUS = 8;
  SCE_SQL_SQLPLUS_PROMPT = 9;
  SCE_SQL_OPERATOR = 10;
  SCE_SQL_IDENTIFIER = 11;
  SCE_SQL_SQLPLUS_COMMENT = 13;
  SCE_SQL_COMMENTLINEDOC = 15;
  SCE_SQL_WORD2 = 16;
  SCE_SQL_COMMENTDOCKEYWORD = 17;
  SCE_SQL_COMMENTDOCKEYWORDERROR = 18;
  SCE_SQL_USER1 = 19;
  SCE_SQL_USER2 = 20;
  SCE_SQL_USER3 = 21;
  SCE_SQL_USER4 = 22;
  SCE_SQL_QUOTEDIDENTIFIER = 23;
  SCE_SQL_QOPERATOR = 24;

  /// <summary>Lexical states for SCLEX_SMALLTALK</summary>
  SCE_ST_DEFAULT = 0;
  SCE_ST_STRING = 1;
  SCE_ST_NUMBER = 2;
  SCE_ST_COMMENT = 3;
  SCE_ST_SYMBOL = 4;
  SCE_ST_BINARY = 5;
  SCE_ST_BOOL = 6;
  SCE_ST_SELF = 7;
  SCE_ST_SUPER = 8;
  SCE_ST_NIL = 9;
  SCE_ST_GLOBAL = 10;
  SCE_ST_RETURN = 11;
  SCE_ST_SPECIAL = 12;
  SCE_ST_KWSEND = 13;
  SCE_ST_ASSIGN = 14;
  SCE_ST_CHARACTER = 15;
  SCE_ST_SPEC_SEL = 16;

  /// <summary>Lexical states for SCLEX_FLAGSHIP (clipper)</summary>
  SCE_FS_DEFAULT = 0;
  SCE_FS_COMMENT = 1;
  SCE_FS_COMMENTLINE = 2;
  SCE_FS_COMMENTDOC = 3;
  SCE_FS_COMMENTLINEDOC = 4;
  SCE_FS_COMMENTDOCKEYWORD = 5;
  SCE_FS_COMMENTDOCKEYWORDERROR = 6;
  SCE_FS_KEYWORD = 7;
  SCE_FS_KEYWORD2 = 8;
  SCE_FS_KEYWORD3 = 9;
  SCE_FS_KEYWORD4 = 10;
  SCE_FS_NUMBER = 11;
  SCE_FS_STRING = 12;
  SCE_FS_PREPROCESSOR = 13;
  SCE_FS_OPERATOR = 14;
  SCE_FS_IDENTIFIER = 15;
  SCE_FS_DATE = 16;
  SCE_FS_STRINGEOL = 17;
  SCE_FS_CONSTANT = 18;
  SCE_FS_WORDOPERATOR = 19;
  SCE_FS_DISABLEDCODE = 20;
  SCE_FS_DEFAULT_C = 21;
  SCE_FS_COMMENTDOC_C = 22;
  SCE_FS_COMMENTLINEDOC_C = 23;
  SCE_FS_KEYWORD_C = 24;
  SCE_FS_KEYWORD2_C = 25;
  SCE_FS_NUMBER_C = 26;
  SCE_FS_STRING_C = 27;
  SCE_FS_PREPROCESSOR_C = 28;
  SCE_FS_OPERATOR_C = 29;
  SCE_FS_IDENTIFIER_C = 30;
  SCE_FS_STRINGEOL_C = 31;

  /// <summary>Lexical states for SCLEX_CSOUND</summary>
  SCE_CSOUND_DEFAULT = 0;
  SCE_CSOUND_COMMENT = 1;
  SCE_CSOUND_NUMBER = 2;
  SCE_CSOUND_OPERATOR = 3;
  SCE_CSOUND_INSTR = 4;
  SCE_CSOUND_IDENTIFIER = 5;
  SCE_CSOUND_OPCODE = 6;
  SCE_CSOUND_HEADERSTMT = 7;
  SCE_CSOUND_USERKEYWORD = 8;
  SCE_CSOUND_COMMENTBLOCK = 9;
  SCE_CSOUND_PARAM = 10;
  SCE_CSOUND_ARATE_VAR = 11;
  SCE_CSOUND_KRATE_VAR = 12;
  SCE_CSOUND_IRATE_VAR = 13;
  SCE_CSOUND_GLOBAL_VAR = 14;
  SCE_CSOUND_STRINGEOL = 15;

  /// <summary>Lexical states for SCLEX_INNOSETUP</summary>
  SCE_INNO_DEFAULT = 0;
  SCE_INNO_COMMENT = 1;
  SCE_INNO_KEYWORD = 2;
  SCE_INNO_PARAMETER = 3;
  SCE_INNO_SECTION = 4;
  SCE_INNO_PREPROC = 5;
  SCE_INNO_INLINE_EXPANSION = 6;
  SCE_INNO_COMMENT_PASCAL = 7;
  SCE_INNO_KEYWORD_PASCAL = 8;
  SCE_INNO_KEYWORD_USER = 9;
  SCE_INNO_STRING_DOUBLE = 10;
  SCE_INNO_STRING_SINGLE = 11;
  SCE_INNO_IDENTIFIER = 12;

  /// <summary>Lexical states for SCLEX_OPAL</summary>
  SCE_OPAL_SPACE = 0;
  SCE_OPAL_COMMENT_BLOCK = 1;
  SCE_OPAL_COMMENT_LINE = 2;
  SCE_OPAL_INTEGER = 3;
  SCE_OPAL_KEYWORD = 4;
  SCE_OPAL_SORT = 5;
  SCE_OPAL_STRING = 6;
  SCE_OPAL_PAR = 7;
  SCE_OPAL_BOOL_CONST = 8;
  SCE_OPAL_DEFAULT = 32;

  /// <summary>Lexical states for SCLEX_SPICE</summary>
  SCE_SPICE_DEFAULT = 0;
  SCE_SPICE_IDENTIFIER = 1;
  SCE_SPICE_KEYWORD = 2;
  SCE_SPICE_KEYWORD2 = 3;
  SCE_SPICE_KEYWORD3 = 4;
  SCE_SPICE_NUMBER = 5;
  SCE_SPICE_DELIMITER = 6;
  SCE_SPICE_VALUE = 7;
  SCE_SPICE_COMMENTLINE = 8;

  /// <summary>Lexical states for SCLEX_CMAKE</summary>
  SCE_CMAKE_DEFAULT = 0;
  SCE_CMAKE_COMMENT = 1;
  SCE_CMAKE_STRINGDQ = 2;
  SCE_CMAKE_STRINGLQ = 3;
  SCE_CMAKE_STRINGRQ = 4;
  SCE_CMAKE_COMMANDS = 5;
  SCE_CMAKE_PARAMETERS = 6;
  SCE_CMAKE_VARIABLE = 7;
  SCE_CMAKE_USERDEFINED = 8;
  SCE_CMAKE_WHILEDEF = 9;
  SCE_CMAKE_FOREACHDEF = 10;
  SCE_CMAKE_IFDEFINEDEF = 11;
  SCE_CMAKE_MACRODEF = 12;
  SCE_CMAKE_STRINGVAR = 13;
  SCE_CMAKE_NUMBER = 14;

  /// <summary>Lexical states for SCLEX_GAP</summary>
  SCE_GAP_DEFAULT = 0;
  SCE_GAP_IDENTIFIER = 1;
  SCE_GAP_KEYWORD = 2;
  SCE_GAP_KEYWORD2 = 3;
  SCE_GAP_KEYWORD3 = 4;
  SCE_GAP_KEYWORD4 = 5;
  SCE_GAP_STRING = 6;
  SCE_GAP_CHAR = 7;
  SCE_GAP_OPERATOR = 8;
  SCE_GAP_COMMENT = 9;
  SCE_GAP_NUMBER = 10;
  SCE_GAP_STRINGEOL = 11;

  /// <summary>Lexical state for SCLEX_PLM</summary>
  SCE_PLM_DEFAULT = 0;
  SCE_PLM_COMMENT = 1;
  SCE_PLM_STRING = 2;
  SCE_PLM_NUMBER = 3;
  SCE_PLM_IDENTIFIER = 4;
  SCE_PLM_OPERATOR = 5;
  SCE_PLM_CONTROL = 6;
  SCE_PLM_KEYWORD = 7;

  /// <summary>Lexical state for SCLEX_PROGRESS</summary>
  SCE_ABL_DEFAULT = 0;
  SCE_ABL_NUMBER = 1;
  SCE_ABL_WORD = 2;
  SCE_ABL_STRING = 3;
  SCE_ABL_CHARACTER = 4;
  SCE_ABL_PREPROCESSOR = 5;
  SCE_ABL_OPERATOR = 6;
  SCE_ABL_IDENTIFIER = 7;
  SCE_ABL_BLOCK = 8;
  SCE_ABL_END = 9;
  SCE_ABL_COMMENT = 10;
  SCE_ABL_TASKMARKER = 11;
  SCE_ABL_LINECOMMENT = 12;
  SCE_ABL_ANNOTATION = 13;
  SCE_ABL_TYPEDANNOTATION = 14;

  /// <summary>Lexical states for SCLEX_ABAQUS</summary>
  SCE_ABAQUS_DEFAULT = 0;
  SCE_ABAQUS_COMMENT = 1;
  SCE_ABAQUS_COMMENTBLOCK = 2;
  SCE_ABAQUS_NUMBER = 3;
  SCE_ABAQUS_STRING = 4;
  SCE_ABAQUS_OPERATOR = 5;
  SCE_ABAQUS_WORD = 6;
  SCE_ABAQUS_PROCESSOR = 7;
  SCE_ABAQUS_COMMAND = 8;
  SCE_ABAQUS_SLASHCOMMAND = 9;
  SCE_ABAQUS_STARCOMMAND = 10;
  SCE_ABAQUS_ARGUMENT = 11;
  SCE_ABAQUS_FUNCTION = 12;

  /// <summary>Lexical states for SCLEX_ASYMPTOTE</summary>
  SCE_ASY_DEFAULT = 0;
  SCE_ASY_COMMENT = 1;
  SCE_ASY_COMMENTLINE = 2;
  SCE_ASY_NUMBER = 3;
  SCE_ASY_WORD = 4;
  SCE_ASY_STRING = 5;
  SCE_ASY_CHARACTER = 6;
  SCE_ASY_OPERATOR = 7;
  SCE_ASY_IDENTIFIER = 8;
  SCE_ASY_STRINGEOL = 9;
  SCE_ASY_COMMENTLINEDOC = 10;
  SCE_ASY_WORD2 = 11;

  /// <summary>Lexical states for SCLEX_R</summary>
  SCE_R_DEFAULT = 0;
  SCE_R_COMMENT = 1;
  SCE_R_KWORD = 2;
  SCE_R_BASEKWORD = 3;
  SCE_R_OTHERKWORD = 4;
  SCE_R_NUMBER = 5;
  SCE_R_STRING = 6;
  SCE_R_STRING2 = 7;
  SCE_R_OPERATOR = 8;
  SCE_R_IDENTIFIER = 9;
  SCE_R_INFIX = 10;
  SCE_R_INFIXEOL = 11;
  SCE_R_BACKTICKS = 12;
  SCE_R_RAWSTRING = 13;
  SCE_R_RAWSTRING2 = 14;
  SCE_R_ESCAPESEQUENCE = 15;

  /// <summary>Lexical state for SCLEX_MAGIK</summary>
  SCE_MAGIK_DEFAULT = 0;
  SCE_MAGIK_COMMENT = 1;
  SCE_MAGIK_HYPER_COMMENT = 16;
  SCE_MAGIK_STRING = 2;
  SCE_MAGIK_CHARACTER = 3;
  SCE_MAGIK_NUMBER = 4;
  SCE_MAGIK_IDENTIFIER = 5;
  SCE_MAGIK_OPERATOR = 6;
  SCE_MAGIK_FLOW = 7;
  SCE_MAGIK_CONTAINER = 8;
  SCE_MAGIK_BRACKET_BLOCK = 9;
  SCE_MAGIK_BRACE_BLOCK = 10;
  SCE_MAGIK_SQBRACKET_BLOCK = 11;
  SCE_MAGIK_UNKNOWN_KEYWORD = 12;
  SCE_MAGIK_KEYWORD = 13;
  SCE_MAGIK_PRAGMA = 14;
  SCE_MAGIK_SYMBOL = 15;

  /// <summary>Lexical state for SCLEX_POWERSHELL</summary>
  SCE_POWERSHELL_DEFAULT = 0;
  SCE_POWERSHELL_COMMENT = 1;
  SCE_POWERSHELL_STRING = 2;
  SCE_POWERSHELL_CHARACTER = 3;
  SCE_POWERSHELL_NUMBER = 4;
  SCE_POWERSHELL_VARIABLE = 5;
  SCE_POWERSHELL_OPERATOR = 6;
  SCE_POWERSHELL_IDENTIFIER = 7;
  SCE_POWERSHELL_KEYWORD = 8;
  SCE_POWERSHELL_CMDLET = 9;
  SCE_POWERSHELL_ALIAS = 10;
  SCE_POWERSHELL_FUNCTION = 11;
  SCE_POWERSHELL_USER1 = 12;
  SCE_POWERSHELL_COMMENTSTREAM = 13;
  SCE_POWERSHELL_HERE_STRING = 14;
  SCE_POWERSHELL_HERE_CHARACTER = 15;
  SCE_POWERSHELL_COMMENTDOCKEYWORD = 16;

  /// <summary>Lexical state for SCLEX_MYSQL</summary>
  SCE_MYSQL_DEFAULT = 0;
  SCE_MYSQL_COMMENT = 1;
  SCE_MYSQL_COMMENTLINE = 2;
  SCE_MYSQL_VARIABLE = 3;
  SCE_MYSQL_SYSTEMVARIABLE = 4;
  SCE_MYSQL_KNOWNSYSTEMVARIABLE = 5;
  SCE_MYSQL_NUMBER = 6;
  SCE_MYSQL_MAJORKEYWORD = 7;
  SCE_MYSQL_KEYWORD = 8;
  SCE_MYSQL_DATABASEOBJECT = 9;
  SCE_MYSQL_PROCEDUREKEYWORD = 10;
  SCE_MYSQL_STRING = 11;
  SCE_MYSQL_SQSTRING = 12;
  SCE_MYSQL_DQSTRING = 13;
  SCE_MYSQL_OPERATOR = 14;
  SCE_MYSQL_FUNCTION = 15;
  SCE_MYSQL_IDENTIFIER = 16;
  SCE_MYSQL_QUOTEDIDENTIFIER = 17;
  SCE_MYSQL_USER1 = 18;
  SCE_MYSQL_USER2 = 19;
  SCE_MYSQL_USER3 = 20;
  SCE_MYSQL_HIDDENCOMMAND = 21;
  SCE_MYSQL_PLACEHOLDER = 22;

  /// <summary>Lexical state for SCLEX_PO</summary>
  SCE_PO_DEFAULT = 0;
  SCE_PO_COMMENT = 1;
  SCE_PO_MSGID = 2;
  SCE_PO_MSGID_TEXT = 3;
  SCE_PO_MSGSTR = 4;
  SCE_PO_MSGSTR_TEXT = 5;
  SCE_PO_MSGCTXT = 6;
  SCE_PO_MSGCTXT_TEXT = 7;
  SCE_PO_FUZZY = 8;
  SCE_PO_PROGRAMMER_COMMENT = 9;
  SCE_PO_REFERENCE = 10;
  SCE_PO_FLAGS = 11;
  SCE_PO_MSGID_TEXT_EOL = 12;
  SCE_PO_MSGSTR_TEXT_EOL = 13;
  SCE_PO_MSGCTXT_TEXT_EOL = 14;
  SCE_PO_ERROR = 15;

  /// <summary>Lexical states for SCLEX_PASCAL</summary>
  SCE_PAS_DEFAULT = 0;
  SCE_PAS_IDENTIFIER = 1;
  SCE_PAS_COMMENT = 2;
  SCE_PAS_COMMENT2 = 3;
  SCE_PAS_COMMENTLINE = 4;
  SCE_PAS_PREPROCESSOR = 5;
  SCE_PAS_PREPROCESSOR2 = 6;
  SCE_PAS_NUMBER = 7;
  SCE_PAS_HEXNUMBER = 8;
  SCE_PAS_WORD = 9;
  SCE_PAS_STRING = 10;
  SCE_PAS_STRINGEOL = 11;
  SCE_PAS_CHARACTER = 12;
  SCE_PAS_OPERATOR = 13;
  SCE_PAS_ASM = 14;

  /// <summary>Lexical state for SCLEX_SORCUS</summary>
  SCE_SORCUS_DEFAULT = 0;
  SCE_SORCUS_COMMAND = 1;
  SCE_SORCUS_PARAMETER = 2;
  SCE_SORCUS_COMMENTLINE = 3;
  SCE_SORCUS_STRING = 4;
  SCE_SORCUS_STRINGEOL = 5;
  SCE_SORCUS_IDENTIFIER = 6;
  SCE_SORCUS_OPERATOR = 7;
  SCE_SORCUS_NUMBER = 8;
  SCE_SORCUS_CONSTANT = 9;

  /// <summary>Lexical state for SCLEX_POWERPRO</summary>
  SCE_POWERPRO_DEFAULT = 0;
  SCE_POWERPRO_COMMENTBLOCK = 1;
  SCE_POWERPRO_COMMENTLINE = 2;
  SCE_POWERPRO_NUMBER = 3;
  SCE_POWERPRO_WORD = 4;
  SCE_POWERPRO_WORD2 = 5;
  SCE_POWERPRO_WORD3 = 6;
  SCE_POWERPRO_WORD4 = 7;
  SCE_POWERPRO_DOUBLEQUOTEDSTRING = 8;
  SCE_POWERPRO_SINGLEQUOTEDSTRING = 9;
  SCE_POWERPRO_LINECONTINUE = 10;
  SCE_POWERPRO_OPERATOR = 11;
  SCE_POWERPRO_IDENTIFIER = 12;
  SCE_POWERPRO_STRINGEOL = 13;
  SCE_POWERPRO_VERBATIM = 14;
  SCE_POWERPRO_ALTQUOTE = 15;
  SCE_POWERPRO_FUNCTION = 16;

  /// <summary>Lexical states for SCLEX_SML</summary>
  SCE_SML_DEFAULT = 0;
  SCE_SML_IDENTIFIER = 1;
  SCE_SML_TAGNAME = 2;
  SCE_SML_KEYWORD = 3;
  SCE_SML_KEYWORD2 = 4;
  SCE_SML_KEYWORD3 = 5;
  SCE_SML_LINENUM = 6;
  SCE_SML_OPERATOR = 7;
  SCE_SML_NUMBER = 8;
  SCE_SML_CHAR = 9;
  SCE_SML_STRING = 11;
  SCE_SML_COMMENT = 12;
  SCE_SML_COMMENT1 = 13;
  SCE_SML_COMMENT2 = 14;
  SCE_SML_COMMENT3 = 15;

  /// <summary>Lexical state for SCLEX_MARKDOWN</summary>
  SCE_MARKDOWN_DEFAULT = 0;
  SCE_MARKDOWN_LINE_BEGIN = 1;
  SCE_MARKDOWN_STRONG1 = 2;
  SCE_MARKDOWN_STRONG2 = 3;
  SCE_MARKDOWN_EM1 = 4;
  SCE_MARKDOWN_EM2 = 5;
  SCE_MARKDOWN_HEADER1 = 6;
  SCE_MARKDOWN_HEADER2 = 7;
  SCE_MARKDOWN_HEADER3 = 8;
  SCE_MARKDOWN_HEADER4 = 9;
  SCE_MARKDOWN_HEADER5 = 10;
  SCE_MARKDOWN_HEADER6 = 11;
  SCE_MARKDOWN_PRECHAR = 12;
  SCE_MARKDOWN_ULIST_ITEM = 13;
  SCE_MARKDOWN_OLIST_ITEM = 14;
  SCE_MARKDOWN_BLOCKQUOTE = 15;
  SCE_MARKDOWN_STRIKEOUT = 16;
  SCE_MARKDOWN_HRULE = 17;
  SCE_MARKDOWN_LINK = 18;
  SCE_MARKDOWN_CODE = 19;
  SCE_MARKDOWN_CODE2 = 20;
  SCE_MARKDOWN_CODEBK = 21;

  /// <summary>Lexical state for SCLEX_TXT2TAGS</summary>
  SCE_TXT2TAGS_DEFAULT = 0;
  SCE_TXT2TAGS_LINE_BEGIN = 1;
  SCE_TXT2TAGS_STRONG1 = 2;
  SCE_TXT2TAGS_STRONG2 = 3;
  SCE_TXT2TAGS_EM1 = 4;
  SCE_TXT2TAGS_EM2 = 5;
  SCE_TXT2TAGS_HEADER1 = 6;
  SCE_TXT2TAGS_HEADER2 = 7;
  SCE_TXT2TAGS_HEADER3 = 8;
  SCE_TXT2TAGS_HEADER4 = 9;
  SCE_TXT2TAGS_HEADER5 = 10;
  SCE_TXT2TAGS_HEADER6 = 11;
  SCE_TXT2TAGS_PRECHAR = 12;
  SCE_TXT2TAGS_ULIST_ITEM = 13;
  SCE_TXT2TAGS_OLIST_ITEM = 14;
  SCE_TXT2TAGS_BLOCKQUOTE = 15;
  SCE_TXT2TAGS_STRIKEOUT = 16;
  SCE_TXT2TAGS_HRULE = 17;
  SCE_TXT2TAGS_LINK = 18;
  SCE_TXT2TAGS_CODE = 19;
  SCE_TXT2TAGS_CODE2 = 20;
  SCE_TXT2TAGS_CODEBK = 21;
  SCE_TXT2TAGS_COMMENT = 22;
  SCE_TXT2TAGS_OPTION = 23;
  SCE_TXT2TAGS_PREPROC = 24;
  SCE_TXT2TAGS_POSTPROC = 25;

  /// <summary>Lexical states for SCLEX_A68K</summary>
  SCE_A68K_DEFAULT = 0;
  SCE_A68K_COMMENT = 1;
  SCE_A68K_NUMBER_DEC = 2;
  SCE_A68K_NUMBER_BIN = 3;
  SCE_A68K_NUMBER_HEX = 4;
  SCE_A68K_STRING1 = 5;
  SCE_A68K_OPERATOR = 6;
  SCE_A68K_CPUINSTRUCTION = 7;
  SCE_A68K_EXTINSTRUCTION = 8;
  SCE_A68K_REGISTER = 9;
  SCE_A68K_DIRECTIVE = 10;
  SCE_A68K_MACRO_ARG = 11;
  SCE_A68K_LABEL = 12;
  SCE_A68K_STRING2 = 13;
  SCE_A68K_IDENTIFIER = 14;
  SCE_A68K_MACRO_DECLARATION = 15;
  SCE_A68K_COMMENT_WORD = 16;
  SCE_A68K_COMMENT_SPECIAL = 17;
  SCE_A68K_COMMENT_DOXYGEN = 18;

  /// <summary>Lexical states for SCLEX_MODULA</summary>
  SCE_MODULA_DEFAULT = 0;
  SCE_MODULA_COMMENT = 1;
  SCE_MODULA_DOXYCOMM = 2;
  SCE_MODULA_DOXYKEY = 3;
  SCE_MODULA_KEYWORD = 4;
  SCE_MODULA_RESERVED = 5;
  SCE_MODULA_NUMBER = 6;
  SCE_MODULA_BASENUM = 7;
  SCE_MODULA_FLOAT = 8;
  SCE_MODULA_STRING = 9;
  SCE_MODULA_STRSPEC = 10;
  SCE_MODULA_CHAR = 11;
  SCE_MODULA_CHARSPEC = 12;
  SCE_MODULA_PROC = 13;
  SCE_MODULA_PRAGMA = 14;
  SCE_MODULA_PRGKEY = 15;
  SCE_MODULA_OPERATOR = 16;
  SCE_MODULA_BADSTR = 17;

  /// <summary>Lexical states for SCLEX_COFFEESCRIPT</summary>
  SCE_COFFEESCRIPT_DEFAULT = 0;
  SCE_COFFEESCRIPT_COMMENT = 1;
  SCE_COFFEESCRIPT_COMMENTLINE = 2;
  SCE_COFFEESCRIPT_COMMENTDOC = 3;
  SCE_COFFEESCRIPT_NUMBER = 4;
  SCE_COFFEESCRIPT_WORD = 5;
  SCE_COFFEESCRIPT_STRING = 6;
  SCE_COFFEESCRIPT_CHARACTER = 7;
  SCE_COFFEESCRIPT_UUID = 8;
  SCE_COFFEESCRIPT_PREPROCESSOR = 9;
  SCE_COFFEESCRIPT_OPERATOR = 10;
  SCE_COFFEESCRIPT_IDENTIFIER = 11;
  SCE_COFFEESCRIPT_STRINGEOL = 12;
  SCE_COFFEESCRIPT_VERBATIM = 13;
  SCE_COFFEESCRIPT_REGEX = 14;
  SCE_COFFEESCRIPT_COMMENTLINEDOC = 15;
  SCE_COFFEESCRIPT_WORD2 = 16;
  SCE_COFFEESCRIPT_COMMENTDOCKEYWORD = 17;
  SCE_COFFEESCRIPT_COMMENTDOCKEYWORDERROR = 18;
  SCE_COFFEESCRIPT_GLOBALCLASS = 19;
  SCE_COFFEESCRIPT_STRINGRAW = 20;
  SCE_COFFEESCRIPT_TRIPLEVERBATIM = 21;
  SCE_COFFEESCRIPT_COMMENTBLOCK = 22;
  SCE_COFFEESCRIPT_VERBOSE_REGEX = 23;
  SCE_COFFEESCRIPT_VERBOSE_REGEX_COMMENT = 24;
  SCE_COFFEESCRIPT_INSTANCEPROPERTY = 25;

  /// <summary>Lexical states for SCLEX_AVS</summary>
  SCE_AVS_DEFAULT = 0;
  SCE_AVS_COMMENTBLOCK = 1;
  SCE_AVS_COMMENTBLOCKN = 2;
  SCE_AVS_COMMENTLINE = 3;
  SCE_AVS_NUMBER = 4;
  SCE_AVS_OPERATOR = 5;
  SCE_AVS_IDENTIFIER = 6;
  SCE_AVS_STRING = 7;
  SCE_AVS_TRIPLESTRING = 8;
  SCE_AVS_KEYWORD = 9;
  SCE_AVS_FILTER = 10;
  SCE_AVS_PLUGIN = 11;
  SCE_AVS_FUNCTION = 12;
  SCE_AVS_CLIPPROP = 13;
  SCE_AVS_USERDFN = 14;

  /// <summary>Lexical states for SCLEX_ECL</summary>
  SCE_ECL_DEFAULT = 0;
  SCE_ECL_COMMENT = 1;
  SCE_ECL_COMMENTLINE = 2;
  SCE_ECL_NUMBER = 3;
  SCE_ECL_STRING = 4;
  SCE_ECL_WORD0 = 5;
  SCE_ECL_OPERATOR = 6;
  SCE_ECL_CHARACTER = 7;
  SCE_ECL_UUID = 8;
  SCE_ECL_PREPROCESSOR = 9;
  SCE_ECL_UNKNOWN = 10;
  SCE_ECL_IDENTIFIER = 11;
  SCE_ECL_STRINGEOL = 12;
  SCE_ECL_VERBATIM = 13;
  SCE_ECL_REGEX = 14;
  SCE_ECL_COMMENTLINEDOC = 15;
  SCE_ECL_WORD1 = 16;
  SCE_ECL_COMMENTDOCKEYWORD = 17;
  SCE_ECL_COMMENTDOCKEYWORDERROR = 18;
  SCE_ECL_WORD2 = 19;
  SCE_ECL_WORD3 = 20;
  SCE_ECL_WORD4 = 21;
  SCE_ECL_WORD5 = 22;
  SCE_ECL_COMMENTDOC = 23;
  SCE_ECL_ADDED = 24;
  SCE_ECL_DELETED = 25;
  SCE_ECL_CHANGED = 26;
  SCE_ECL_MOVED = 27;

  /// <summary>Lexical states for SCLEX_OSCRIPT</summary>
  SCE_OSCRIPT_DEFAULT = 0;
  SCE_OSCRIPT_LINE_COMMENT = 1;
  SCE_OSCRIPT_BLOCK_COMMENT = 2;
  SCE_OSCRIPT_DOC_COMMENT = 3;
  SCE_OSCRIPT_PREPROCESSOR = 4;
  SCE_OSCRIPT_NUMBER = 5;
  SCE_OSCRIPT_SINGLEQUOTE_STRING = 6;
  SCE_OSCRIPT_DOUBLEQUOTE_STRING = 7;
  SCE_OSCRIPT_CONSTANT = 8;
  SCE_OSCRIPT_IDENTIFIER = 9;
  SCE_OSCRIPT_GLOBAL = 10;
  SCE_OSCRIPT_KEYWORD = 11;
  SCE_OSCRIPT_OPERATOR = 12;
  SCE_OSCRIPT_LABEL = 13;
  SCE_OSCRIPT_TYPE = 14;
  SCE_OSCRIPT_FUNCTION = 15;
  SCE_OSCRIPT_OBJECT = 16;
  SCE_OSCRIPT_PROPERTY = 17;
  SCE_OSCRIPT_METHOD = 18;

  /// <summary>Lexical states for SCLEX_VISUALPROLOG</summary>
  SCE_VISUALPROLOG_DEFAULT = 0;
  SCE_VISUALPROLOG_KEY_MAJOR = 1;
  SCE_VISUALPROLOG_KEY_MINOR = 2;
  SCE_VISUALPROLOG_KEY_DIRECTIVE = 3;
  SCE_VISUALPROLOG_COMMENT_BLOCK = 4;
  SCE_VISUALPROLOG_COMMENT_LINE = 5;
  SCE_VISUALPROLOG_COMMENT_KEY = 6;
  SCE_VISUALPROLOG_COMMENT_KEY_ERROR = 7;
  SCE_VISUALPROLOG_IDENTIFIER = 8;
  SCE_VISUALPROLOG_VARIABLE = 9;
  SCE_VISUALPROLOG_ANONYMOUS = 10;
  SCE_VISUALPROLOG_NUMBER = 11;
  SCE_VISUALPROLOG_OPERATOR = 12;
  SCE_VISUALPROLOG_UNUSED1 = 13;
  SCE_VISUALPROLOG_UNUSED2 = 14;
  SCE_VISUALPROLOG_UNUSED3 = 15;
  SCE_VISUALPROLOG_STRING_QUOTE = 16;
  SCE_VISUALPROLOG_STRING_ESCAPE = 17;
  SCE_VISUALPROLOG_STRING_ESCAPE_ERROR = 18;
  SCE_VISUALPROLOG_UNUSED4 = 19;
  SCE_VISUALPROLOG_STRING = 20;
  SCE_VISUALPROLOG_UNUSED5 = 21;
  SCE_VISUALPROLOG_STRING_EOL = 22;
  SCE_VISUALPROLOG_EMBEDDED = 23;
  SCE_VISUALPROLOG_PLACEHOLDER = 24;

  /// <summary>Lexical states for SCLEX_STTXT</summary>
  SCE_STTXT_DEFAULT = 0;
  SCE_STTXT_COMMENT = 1;
  SCE_STTXT_COMMENTLINE = 2;
  SCE_STTXT_KEYWORD = 3;
  SCE_STTXT_TYPE = 4;
  SCE_STTXT_FUNCTION = 5;
  SCE_STTXT_FB = 6;
  SCE_STTXT_NUMBER = 7;
  SCE_STTXT_HEXNUMBER = 8;
  SCE_STTXT_PRAGMA = 9;
  SCE_STTXT_OPERATOR = 10;
  SCE_STTXT_CHARACTER = 11;
  SCE_STTXT_STRING1 = 12;
  SCE_STTXT_STRING2 = 13;
  SCE_STTXT_STRINGEOL = 14;
  SCE_STTXT_IDENTIFIER = 15;
  SCE_STTXT_DATETIME = 16;
  SCE_STTXT_VARS = 17;
  SCE_STTXT_PRAGMAS = 18;

  /// <summary>Lexical states for SCLEX_KVIRC</summary>
  SCE_KVIRC_DEFAULT = 0;
  SCE_KVIRC_COMMENT = 1;
  SCE_KVIRC_COMMENTBLOCK = 2;
  SCE_KVIRC_STRING = 3;
  SCE_KVIRC_WORD = 4;
  SCE_KVIRC_KEYWORD = 5;
  SCE_KVIRC_FUNCTION_KEYWORD = 6;
  SCE_KVIRC_FUNCTION = 7;
  SCE_KVIRC_VARIABLE = 8;
  SCE_KVIRC_NUMBER = 9;
  SCE_KVIRC_OPERATOR = 10;
  SCE_KVIRC_STRING_FUNCTION = 11;
  SCE_KVIRC_STRING_VARIABLE = 12;

  /// <summary>Lexical states for SCLEX_RUST</summary>
  SCE_RUST_DEFAULT = 0;
  SCE_RUST_COMMENTBLOCK = 1;
  SCE_RUST_COMMENTLINE = 2;
  SCE_RUST_COMMENTBLOCKDOC = 3;
  SCE_RUST_COMMENTLINEDOC = 4;
  SCE_RUST_NUMBER = 5;
  SCE_RUST_WORD = 6;
  SCE_RUST_WORD2 = 7;
  SCE_RUST_WORD3 = 8;
  SCE_RUST_WORD4 = 9;
  SCE_RUST_WORD5 = 10;
  SCE_RUST_WORD6 = 11;
  SCE_RUST_WORD7 = 12;
  SCE_RUST_STRING = 13;
  SCE_RUST_STRINGR = 14;
  SCE_RUST_CHARACTER = 15;
  SCE_RUST_OPERATOR = 16;
  SCE_RUST_IDENTIFIER = 17;
  SCE_RUST_LIFETIME = 18;
  SCE_RUST_MACRO = 19;
  SCE_RUST_LEXERROR = 20;
  SCE_RUST_BYTESTRING = 21;
  SCE_RUST_BYTESTRINGR = 22;
  SCE_RUST_BYTECHARACTER = 23;
  SCE_RUST_CSTRING = 24;
  SCE_RUST_CSTRINGR = 25;

  /// <summary>Lexical states for SCLEX_DMAP</summary>
  SCE_DMAP_DEFAULT = 0;
  SCE_DMAP_COMMENT = 1;
  SCE_DMAP_NUMBER = 2;
  SCE_DMAP_STRING1 = 3;
  SCE_DMAP_STRING2 = 4;
  SCE_DMAP_STRINGEOL = 5;
  SCE_DMAP_OPERATOR = 6;
  SCE_DMAP_IDENTIFIER = 7;
  SCE_DMAP_WORD = 8;
  SCE_DMAP_WORD2 = 9;
  SCE_DMAP_WORD3 = 10;

  /// <summary>Lexical states for SCLEX_DMIS</summary>
  SCE_DMIS_DEFAULT = 0;
  SCE_DMIS_COMMENT = 1;
  SCE_DMIS_STRING = 2;
  SCE_DMIS_NUMBER = 3;
  SCE_DMIS_KEYWORD = 4;
  SCE_DMIS_MAJORWORD = 5;
  SCE_DMIS_MINORWORD = 6;
  SCE_DMIS_UNSUPPORTED_MAJOR = 7;
  SCE_DMIS_UNSUPPORTED_MINOR = 8;
  SCE_DMIS_LABEL = 9;

  /// <summary>Lexical states for SCLEX_REGISTRY</summary>
  SCE_REG_DEFAULT = 0;
  SCE_REG_COMMENT = 1;
  SCE_REG_VALUENAME = 2;
  SCE_REG_STRING = 3;
  SCE_REG_HEXDIGIT = 4;
  SCE_REG_VALUETYPE = 5;
  SCE_REG_ADDEDKEY = 6;
  SCE_REG_DELETEDKEY = 7;
  SCE_REG_ESCAPED = 8;
  SCE_REG_KEYPATH_GUID = 9;
  SCE_REG_STRING_GUID = 10;
  SCE_REG_PARAMETER = 11;
  SCE_REG_OPERATOR = 12;

  /// <summary>Lexical state for SCLEX_BIBTEX</summary>
  SCE_BIBTEX_DEFAULT = 0;
  SCE_BIBTEX_ENTRY = 1;
  SCE_BIBTEX_UNKNOWN_ENTRY = 2;
  SCE_BIBTEX_KEY = 3;
  SCE_BIBTEX_PARAMETER = 4;
  SCE_BIBTEX_VALUE = 5;
  SCE_BIBTEX_COMMENT = 6;

  /// <summary>Lexical state for SCLEX_SREC</summary>
  SCE_HEX_DEFAULT = 0;
  SCE_HEX_RECSTART = 1;
  SCE_HEX_RECTYPE = 2;
  SCE_HEX_RECTYPE_UNKNOWN = 3;
  SCE_HEX_BYTECOUNT = 4;
  SCE_HEX_BYTECOUNT_WRONG = 5;
  SCE_HEX_NOADDRESS = 6;
  SCE_HEX_DATAADDRESS = 7;
  SCE_HEX_RECCOUNT = 8;
  SCE_HEX_STARTADDRESS = 9;
  SCE_HEX_ADDRESSFIELD_UNKNOWN = 10;
  SCE_HEX_EXTENDEDADDRESS = 11;
  SCE_HEX_DATA_ODD = 12;
  SCE_HEX_DATA_EVEN = 13;
  SCE_HEX_DATA_UNKNOWN = 14;
  SCE_HEX_DATA_EMPTY = 15;
  SCE_HEX_CHECKSUM = 16;
  SCE_HEX_CHECKSUM_WRONG = 17;
  SCE_HEX_GARBAGE = 18;

  /// <summary>Lexical state for SCLEX_IHEX (shared with Srec)
  /// Lexical state for SCLEX_TEHEX (shared with Srec)
  /// Lexical states for SCLEX_JSON</summary>
  SCE_JSON_DEFAULT = 0;
  SCE_JSON_NUMBER = 1;
  SCE_JSON_STRING = 2;
  SCE_JSON_STRINGEOL = 3;
  SCE_JSON_PROPERTYNAME = 4;
  SCE_JSON_ESCAPESEQUENCE = 5;
  SCE_JSON_LINECOMMENT = 6;
  SCE_JSON_BLOCKCOMMENT = 7;
  SCE_JSON_OPERATOR = 8;
  SCE_JSON_URI = 9;
  SCE_JSON_COMPACTIRI = 10;
  SCE_JSON_KEYWORD = 11;
  SCE_JSON_LDKEYWORD = 12;
  SCE_JSON_ERROR = 13;
  SCE_EDI_DEFAULT = 0;
  SCE_EDI_SEGMENTSTART = 1;
  SCE_EDI_SEGMENTEND = 2;
  SCE_EDI_SEP_ELEMENT = 3;
  SCE_EDI_SEP_COMPOSITE = 4;
  SCE_EDI_SEP_RELEASE = 5;
  SCE_EDI_UNA = 6;
  SCE_EDI_UNH = 7;
  SCE_EDI_BADSEGMENT = 8;

  /// <summary>Lexical states for SCLEX_STATA</summary>
  SCE_STATA_DEFAULT = 0;
  SCE_STATA_COMMENT = 1;
  SCE_STATA_COMMENTLINE = 2;
  SCE_STATA_COMMENTBLOCK = 3;
  SCE_STATA_NUMBER = 4;
  SCE_STATA_OPERATOR = 5;
  SCE_STATA_IDENTIFIER = 6;
  SCE_STATA_STRING = 7;
  SCE_STATA_TYPE = 8;
  SCE_STATA_WORD = 9;
  SCE_STATA_GLOBAL_MACRO = 10;
  SCE_STATA_MACRO = 11;

  /// <summary>Lexical states for SCLEX_SAS</summary>
  SCE_SAS_DEFAULT = 0;
  SCE_SAS_COMMENT = 1;
  SCE_SAS_COMMENTLINE = 2;
  SCE_SAS_COMMENTBLOCK = 3;
  SCE_SAS_NUMBER = 4;
  SCE_SAS_OPERATOR = 5;
  SCE_SAS_IDENTIFIER = 6;
  SCE_SAS_STRING = 7;
  SCE_SAS_TYPE = 8;
  SCE_SAS_WORD = 9;
  SCE_SAS_GLOBAL_MACRO = 10;
  SCE_SAS_MACRO = 11;
  SCE_SAS_MACRO_KEYWORD = 12;
  SCE_SAS_BLOCK_KEYWORD = 13;
  SCE_SAS_MACRO_FUNCTION = 14;
  SCE_SAS_STATEMENT = 15;

  /// <summary>Lexical states for SCLEX_NIM</summary>
  SCE_NIM_DEFAULT = 0;
  SCE_NIM_COMMENT = 1;
  SCE_NIM_COMMENTDOC = 2;
  SCE_NIM_COMMENTLINE = 3;
  SCE_NIM_COMMENTLINEDOC = 4;
  SCE_NIM_NUMBER = 5;
  SCE_NIM_STRING = 6;
  SCE_NIM_CHARACTER = 7;
  SCE_NIM_WORD = 8;
  SCE_NIM_TRIPLE = 9;
  SCE_NIM_TRIPLEDOUBLE = 10;
  SCE_NIM_BACKTICKS = 11;
  SCE_NIM_FUNCNAME = 12;
  SCE_NIM_STRINGEOL = 13;
  SCE_NIM_NUMERROR = 14;
  SCE_NIM_OPERATOR = 15;
  SCE_NIM_IDENTIFIER = 16;

  /// <summary>Lexical states for SCLEX_CIL</summary>
  SCE_CIL_DEFAULT = 0;
  SCE_CIL_COMMENT = 1;
  SCE_CIL_COMMENTLINE = 2;
  SCE_CIL_WORD = 3;
  SCE_CIL_WORD2 = 4;
  SCE_CIL_WORD3 = 5;
  SCE_CIL_STRING = 6;
  SCE_CIL_LABEL = 7;
  SCE_CIL_OPERATOR = 8;
  SCE_CIL_IDENTIFIER = 9;
  SCE_CIL_STRINGEOL = 10;

  /// <summary>Lexical states for SCLEX_X12</summary>
  SCE_X12_DEFAULT = 0;
  SCE_X12_BAD = 1;
  SCE_X12_ENVELOPE = 2;
  SCE_X12_FUNCTIONGROUP = 3;
  SCE_X12_TRANSACTIONSET = 4;
  SCE_X12_SEGMENTHEADER = 5;
  SCE_X12_SEGMENTEND = 6;
  SCE_X12_SEP_ELEMENT = 7;
  SCE_X12_SEP_SUBELEMENT = 8;

  /// <summary>Lexical states for SCLEX_DATAFLEX</summary>
  SCE_DF_DEFAULT = 0;
  SCE_DF_IDENTIFIER = 1;
  SCE_DF_METATAG = 2;
  SCE_DF_IMAGE = 3;
  SCE_DF_COMMENTLINE = 4;
  SCE_DF_PREPROCESSOR = 5;
  SCE_DF_PREPROCESSOR2 = 6;
  SCE_DF_NUMBER = 7;
  SCE_DF_HEXNUMBER = 8;
  SCE_DF_WORD = 9;
  SCE_DF_STRING = 10;
  SCE_DF_STRINGEOL = 11;
  SCE_DF_SCOPEWORD = 12;
  SCE_DF_OPERATOR = 13;
  SCE_DF_ICODE = 14;

  /// <summary>Lexical states for SCLEX_HOLLYWOOD</summary>
  SCE_HOLLYWOOD_DEFAULT = 0;
  SCE_HOLLYWOOD_COMMENT = 1;
  SCE_HOLLYWOOD_COMMENTBLOCK = 2;
  SCE_HOLLYWOOD_NUMBER = 3;
  SCE_HOLLYWOOD_KEYWORD = 4;
  SCE_HOLLYWOOD_STDAPI = 5;
  SCE_HOLLYWOOD_PLUGINAPI = 6;
  SCE_HOLLYWOOD_PLUGINMETHOD = 7;
  SCE_HOLLYWOOD_STRING = 8;
  SCE_HOLLYWOOD_STRINGBLOCK = 9;
  SCE_HOLLYWOOD_PREPROCESSOR = 10;
  SCE_HOLLYWOOD_OPERATOR = 11;
  SCE_HOLLYWOOD_IDENTIFIER = 12;
  SCE_HOLLYWOOD_CONSTANT = 13;
  SCE_HOLLYWOOD_HEXNUMBER = 14;

  /// <summary>Lexical states for SCLEX_RAKU</summary>
  SCE_RAKU_DEFAULT = 0;
  SCE_RAKU_ERROR = 1;
  SCE_RAKU_COMMENTLINE = 2;
  SCE_RAKU_COMMENTEMBED = 3;
  SCE_RAKU_POD = 4;
  SCE_RAKU_CHARACTER = 5;
  SCE_RAKU_HEREDOC_Q = 6;
  SCE_RAKU_HEREDOC_QQ = 7;
  SCE_RAKU_STRING = 8;
  SCE_RAKU_STRING_Q = 9;
  SCE_RAKU_STRING_QQ = 10;
  SCE_RAKU_STRING_Q_LANG = 11;
  SCE_RAKU_STRING_VAR = 12;
  SCE_RAKU_REGEX = 13;
  SCE_RAKU_REGEX_VAR = 14;
  SCE_RAKU_ADVERB = 15;
  SCE_RAKU_NUMBER = 16;
  SCE_RAKU_PREPROCESSOR = 17;
  SCE_RAKU_OPERATOR = 18;
  SCE_RAKU_WORD = 19;
  SCE_RAKU_FUNCTION = 20;
  SCE_RAKU_IDENTIFIER = 21;
  SCE_RAKU_TYPEDEF = 22;
  SCE_RAKU_MU = 23;
  SCE_RAKU_POSITIONAL = 24;
  SCE_RAKU_ASSOCIATIVE = 25;
  SCE_RAKU_CALLABLE = 26;
  SCE_RAKU_GRAMMAR = 27;
  SCE_RAKU_CLASS = 28;

  /// <summary>Lexical states for SCLEX_FSHARP</summary>
  SCE_FSHARP_DEFAULT = 0;
  SCE_FSHARP_KEYWORD = 1;
  SCE_FSHARP_KEYWORD2 = 2;
  SCE_FSHARP_KEYWORD3 = 3;
  SCE_FSHARP_KEYWORD4 = 4;
  SCE_FSHARP_KEYWORD5 = 5;
  SCE_FSHARP_IDENTIFIER = 6;
  SCE_FSHARP_QUOT_IDENTIFIER = 7;
  SCE_FSHARP_COMMENT = 8;
  SCE_FSHARP_COMMENTLINE = 9;
  SCE_FSHARP_PREPROCESSOR = 10;
  SCE_FSHARP_LINENUM = 11;
  SCE_FSHARP_OPERATOR = 12;
  SCE_FSHARP_NUMBER = 13;
  SCE_FSHARP_CHARACTER = 14;
  SCE_FSHARP_STRING = 15;
  SCE_FSHARP_VERBATIM = 16;
  SCE_FSHARP_QUOTATION = 17;
  SCE_FSHARP_ATTRIBUTE = 18;
  SCE_FSHARP_FORMAT_SPEC = 19;

  /// <summary>Lexical states for SCLEX_ASCIIDOC</summary>
  SCE_ASCIIDOC_DEFAULT = 0;
  SCE_ASCIIDOC_STRONG1 = 1;
  SCE_ASCIIDOC_STRONG2 = 2;
  SCE_ASCIIDOC_EM1 = 3;
  SCE_ASCIIDOC_EM2 = 4;
  SCE_ASCIIDOC_HEADER1 = 5;
  SCE_ASCIIDOC_HEADER2 = 6;
  SCE_ASCIIDOC_HEADER3 = 7;
  SCE_ASCIIDOC_HEADER4 = 8;
  SCE_ASCIIDOC_HEADER5 = 9;
  SCE_ASCIIDOC_HEADER6 = 10;
  SCE_ASCIIDOC_ULIST_ITEM = 11;
  SCE_ASCIIDOC_OLIST_ITEM = 12;
  SCE_ASCIIDOC_BLOCKQUOTE = 13;
  SCE_ASCIIDOC_LINK = 14;
  SCE_ASCIIDOC_CODEBK = 15;
  SCE_ASCIIDOC_PASSBK = 16;
  SCE_ASCIIDOC_COMMENT = 17;
  SCE_ASCIIDOC_COMMENTBK = 18;
  SCE_ASCIIDOC_LITERAL = 19;
  SCE_ASCIIDOC_LITERALBK = 20;
  SCE_ASCIIDOC_ATTRIB = 21;
  SCE_ASCIIDOC_ATTRIBVAL = 22;
  SCE_ASCIIDOC_MACRO = 23;

  /// <summary>Lexical states for SCLEX_GDSCRIPT</summary>
  SCE_GD_DEFAULT = 0;
  SCE_GD_COMMENTLINE = 1;
  SCE_GD_NUMBER = 2;
  SCE_GD_STRING = 3;
  SCE_GD_CHARACTER = 4;
  SCE_GD_WORD = 5;
  SCE_GD_TRIPLE = 6;
  SCE_GD_TRIPLEDOUBLE = 7;
  SCE_GD_CLASSNAME = 8;
  SCE_GD_FUNCNAME = 9;
  SCE_GD_OPERATOR = 10;
  SCE_GD_IDENTIFIER = 11;
  SCE_GD_COMMENTBLOCK = 12;
  SCE_GD_STRINGEOL = 13;
  SCE_GD_WORD2 = 14;
  SCE_GD_ANNOTATION = 15;
  SCE_GD_NODEPATH = 16;

  /// <summary>Lexical states for SCLEX_TOML</summary>
  SCE_TOML_DEFAULT = 0;
  SCE_TOML_COMMENT = 1;
  SCE_TOML_IDENTIFIER = 2;
  SCE_TOML_KEYWORD = 3;
  SCE_TOML_NUMBER = 4;
  SCE_TOML_TABLE = 5;
  SCE_TOML_KEY = 6;
  SCE_TOML_ERROR = 7;
  SCE_TOML_OPERATOR = 8;
  SCE_TOML_STRING_SQ = 9;
  SCE_TOML_STRING_DQ = 10;
  SCE_TOML_TRIPLE_STRING_SQ = 11;
  SCE_TOML_TRIPLE_STRING_DQ = 12;
  SCE_TOML_ESCAPECHAR = 13;
  SCE_TOML_DATETIME = 14;
  SCE_TOML_STRINGEOL = 15;

  /// <summary>Lexical states for SCLEX_TROFF</summary>
  SCE_TROFF_DEFAULT = 0;
  SCE_TROFF_REQUEST = 1;
  SCE_TROFF_COMMAND = 2;
  SCE_TROFF_NUMBER = 3;
  SCE_TROFF_OPERATOR = 4;
  SCE_TROFF_STRING = 5;
  SCE_TROFF_COMMENT = 6;
  SCE_TROFF_IGNORE = 7;
  SCE_TROFF_ESCAPE_STRING = 8;
  SCE_TROFF_ESCAPE_MACRO = 9;
  SCE_TROFF_ESCAPE_FONT = 10;
  SCE_TROFF_ESCAPE_NUMBER = 11;
  SCE_TROFF_ESCAPE_COLOUR = 12;
  SCE_TROFF_ESCAPE_GLYPH = 13;
  SCE_TROFF_ESCAPE_ENV = 14;
  SCE_TROFF_ESCAPE_SUPPRESSION = 15;
  SCE_TROFF_ESCAPE_SIZE = 16;
  SCE_TROFF_ESCAPE_TRANSPARENT = 17;
  SCE_TROFF_ESCAPE_ISVALID = 18;
  SCE_TROFF_ESCAPE_DRAW = 19;
  SCE_TROFF_ESCAPE_MOVE = 20;
  SCE_TROFF_ESCAPE_HEIGHT = 21;
  SCE_TROFF_ESCAPE_OVERSTRIKE = 22;
  SCE_TROFF_ESCAPE_SLANT = 23;
  SCE_TROFF_ESCAPE_WIDTH = 24;
  SCE_TROFF_ESCAPE_VSPACING = 25;
  SCE_TROFF_ESCAPE_DEVICE = 26;
  SCE_TROFF_ESCAPE_NOMOVE = 27;

  /// <summary>Lexical states for SCLEX_DART</summary>
  SCE_DART_DEFAULT = 0;
  SCE_DART_COMMENTLINE = 1;
  SCE_DART_COMMENTLINEDOC = 2;
  SCE_DART_COMMENTBLOCK = 3;
  SCE_DART_COMMENTBLOCKDOC = 4;
  SCE_DART_STRING_SQ = 5;
  SCE_DART_STRING_DQ = 6;
  SCE_DART_TRIPLE_STRING_SQ = 7;
  SCE_DART_TRIPLE_STRING_DQ = 8;
  SCE_DART_RAWSTRING_SQ = 9;
  SCE_DART_RAWSTRING_DQ = 10;
  SCE_DART_TRIPLE_RAWSTRING_SQ = 11;
  SCE_DART_TRIPLE_RAWSTRING_DQ = 12;
  SCE_DART_ESCAPECHAR = 13;
  SCE_DART_IDENTIFIER = 14;
  SCE_DART_IDENTIFIER_STRING = 15;
  SCE_DART_OPERATOR = 16;
  SCE_DART_OPERATOR_STRING = 17;
  SCE_DART_SYMBOL_IDENTIFIER = 18;
  SCE_DART_SYMBOL_OPERATOR = 19;
  SCE_DART_NUMBER = 20;
  SCE_DART_KEY = 21;
  SCE_DART_METADATA = 22;
  SCE_DART_KW_PRIMARY = 23;
  SCE_DART_KW_SECONDARY = 24;
  SCE_DART_KW_TERTIARY = 25;
  SCE_DART_KW_TYPE = 26;
  SCE_DART_STRINGEOL = 27;

  /// <summary>Lexical states for SCLEX_ZIG</summary>
  SCE_ZIG_DEFAULT = 0;
  SCE_ZIG_COMMENTLINE = 1;
  SCE_ZIG_COMMENTLINEDOC = 2;
  SCE_ZIG_COMMENTLINETOP = 3;
  SCE_ZIG_NUMBER = 4;
  SCE_ZIG_OPERATOR = 5;
  SCE_ZIG_CHARACTER = 6;
  SCE_ZIG_STRING = 7;
  SCE_ZIG_MULTISTRING = 8;
  SCE_ZIG_ESCAPECHAR = 9;
  SCE_ZIG_IDENTIFIER = 10;
  SCE_ZIG_FUNCTION = 11;
  SCE_ZIG_BUILTIN_FUNCTION = 12;
  SCE_ZIG_KW_PRIMARY = 13;
  SCE_ZIG_KW_SECONDARY = 14;
  SCE_ZIG_KW_TERTIARY = 15;
  SCE_ZIG_KW_TYPE = 16;
  SCE_ZIG_IDENTIFIER_STRING = 17;
  SCE_ZIG_STRINGEOL = 18;

  /// <summary>Lexical states for SCLEX_NIX</summary>
  SCE_NIX_DEFAULT = 0;
  SCE_NIX_COMMENTLINE = 1;
  SCE_NIX_COMMENTBLOCK = 2;
  SCE_NIX_STRING = 3;
  SCE_NIX_STRING_MULTILINE = 4;
  SCE_NIX_ESCAPECHAR = 5;
  SCE_NIX_IDENTIFIER = 6;
  SCE_NIX_OPERATOR = 7;
  SCE_NIX_OPERATOR_STRING = 8;
  SCE_NIX_NUMBER = 9;
  SCE_NIX_KEY = 10;
  SCE_NIX_PATH = 11;
  SCE_NIX_KEYWORD1 = 12;
  SCE_NIX_KEYWORD2 = 13;
  SCE_NIX_KEYWORD3 = 14;
  SCE_NIX_KEYWORD4 = 15;
  SCE_NIX_STRINGEOL = 16;

  /// <summary>Lexical states for SCLEX_SINEX</summary>
  SCE_SINEX_DEFAULT = 0;
  SCE_SINEX_COMMENTLINE = 1;
  SCE_SINEX_BLOCK_START = 2;
  SCE_SINEX_BLOCK_END = 3;
  SCE_SINEX_DATE = 4;
  SCE_SINEX_NUMBER = 5;

  /// <summary>Lexical states for SCLEX_ESCSEQ</summary>
  SCE_ESCSEQ_DEFAULT = 0;
  SCE_ESCSEQ_BLACK_DEFAULT = 1;
  SCE_ESCSEQ_RED_DEFAULT = 2;
  SCE_ESCSEQ_GREEN_DEFAULT = 3;
  SCE_ESCSEQ_YELLOW_DEFAULT = 4;
  SCE_ESCSEQ_BLUE_DEFAULT = 5;
  SCE_ESCSEQ_MAGENTA_DEFAULT = 6;
  SCE_ESCSEQ_CYAN_DEFAULT = 7;
  SCE_ESCSEQ_WHITE_DEFAULT = 8;
  SCE_ESCSEQ_DEFAULT_BLACK = 9;
  SCE_ESCSEQ_BLACK_BLACK = 10;
  SCE_ESCSEQ_RED_BLACK = 11;
  SCE_ESCSEQ_GREEN_BLACK = 12;
  SCE_ESCSEQ_YELLOW_BLACK = 13;
  SCE_ESCSEQ_BLUE_BLACK = 14;
  SCE_ESCSEQ_MAGENTA_BLACK = 15;
  SCE_ESCSEQ_CYAN_BLACK = 16;
  SCE_ESCSEQ_WHITE_BLACK = 17;
  SCE_ESCSEQ_DEFAULT_RED = 18;
  SCE_ESCSEQ_BLACK_RED = 19;
  SCE_ESCSEQ_RED_RED = 20;
  SCE_ESCSEQ_GREEN_RED = 21;
  SCE_ESCSEQ_YELLOW_RED = 22;
  SCE_ESCSEQ_BLUE_RED = 23;
  SCE_ESCSEQ_MAGENTA_RED = 24;
  SCE_ESCSEQ_CYAN_RED = 25;
  SCE_ESCSEQ_WHITE_RED = 26;
  SCE_ESCSEQ_DEFAULT_GREEN = 27;
  SCE_ESCSEQ_BLACK_GREEN = 28;
  SCE_ESCSEQ_RED_GREEN = 29;
  SCE_ESCSEQ_GREEN_GREEN = 30;
  SCE_ESCSEQ_YELLOW_GREEN = 40;
  SCE_ESCSEQ_BLUE_GREEN = 41;
  SCE_ESCSEQ_MAGENTA_GREEN = 42;
  SCE_ESCSEQ_CYAN_GREEN = 43;
  SCE_ESCSEQ_WHITE_GREEN = 44;
  SCE_ESCSEQ_DEFAULT_YELLOW = 45;
  SCE_ESCSEQ_BLACK_YELLOW = 46;
  SCE_ESCSEQ_RED_YELLOW = 47;
  SCE_ESCSEQ_GREEN_YELLOW = 48;
  SCE_ESCSEQ_YELLOW_YELLOW = 49;
  SCE_ESCSEQ_BLUE_YELLOW = 50;
  SCE_ESCSEQ_MAGENTA_YELLOW = 51;
  SCE_ESCSEQ_CYAN_YELLOW = 52;
  SCE_ESCSEQ_WHITE_YELLOW = 53;
  SCE_ESCSEQ_DEFAULT_BLUE = 54;
  SCE_ESCSEQ_BLACK_BLUE = 55;
  SCE_ESCSEQ_RED_BLUE = 56;
  SCE_ESCSEQ_GREEN_BLUE = 57;
  SCE_ESCSEQ_YELLOW_BLUE = 58;
  SCE_ESCSEQ_BLUE_BLUE = 59;
  SCE_ESCSEQ_MAGENTA_BLUE = 60;
  SCE_ESCSEQ_CYAN_BLUE = 61;
  SCE_ESCSEQ_WHITE_BLUE = 62;
  SCE_ESCSEQ_DEFAULT_MAGENTA = 63;
  SCE_ESCSEQ_BLACK_MAGENTA = 64;
  SCE_ESCSEQ_RED_MAGENTA = 65;
  SCE_ESCSEQ_GREEN_MAGENTA = 66;
  SCE_ESCSEQ_YELLOW_MAGENTA = 67;
  SCE_ESCSEQ_BLUE_MAGENTA = 68;
  SCE_ESCSEQ_MAGENTA_MAGENTA = 69;
  SCE_ESCSEQ_CYAN_MAGENTA = 70;
  SCE_ESCSEQ_WHITE_MAGENTA = 71;
  SCE_ESCSEQ_DEFAULT_CYAN = 72;
  SCE_ESCSEQ_BLACK_CYAN = 73;
  SCE_ESCSEQ_RED_CYAN = 74;
  SCE_ESCSEQ_GREEN_CYAN = 75;
  SCE_ESCSEQ_YELLOW_CYAN = 76;
  SCE_ESCSEQ_BLUE_CYAN = 77;
  SCE_ESCSEQ_MAGENTA_CYAN = 78;
  SCE_ESCSEQ_CYAN_CYAN = 79;
  SCE_ESCSEQ_WHITE_CYAN = 80;
  SCE_ESCSEQ_DEFAULT_WHITE = 81;
  SCE_ESCSEQ_BLACK_WHITE = 82;
  SCE_ESCSEQ_RED_WHITE = 83;
  SCE_ESCSEQ_GREEN_WHITE = 84;
  SCE_ESCSEQ_YELLOW_WHITE = 85;
  SCE_ESCSEQ_BLUE_WHITE = 86;
  SCE_ESCSEQ_MAGENTA_WHITE = 87;
  SCE_ESCSEQ_CYAN_WHITE = 88;
  SCE_ESCSEQ_WHITE_WHITE = 89;
  SCE_ESCSEQ_BOLD_DEFAULT = 90;
  SCE_ESCSEQ_BOLD_BLACK_DEFAULT = 91;
  SCE_ESCSEQ_BOLD_RED_DEFAULT = 92;
  SCE_ESCSEQ_BOLD_GREEN_DEFAULT = 93;
  SCE_ESCSEQ_BOLD_YELLOW_DEFAULT = 94;
  SCE_ESCSEQ_BOLD_BLUE_DEFAULT = 95;
  SCE_ESCSEQ_BOLD_MAGENTA_DEFAULT = 96;
  SCE_ESCSEQ_BOLD_CYAN_DEFAULT = 97;
  SCE_ESCSEQ_BOLD_WHITE_DEFAULT = 98;
  SCE_ESCSEQ_BOLD_DEFAULT_BLACK = 99;
  SCE_ESCSEQ_BOLD_BLACK_BLACK = 100;
  SCE_ESCSEQ_BOLD_RED_BLACK = 101;
  SCE_ESCSEQ_BOLD_GREEN_BLACK = 102;
  SCE_ESCSEQ_BOLD_YELLOW_BLACK = 103;
  SCE_ESCSEQ_BOLD_BLUE_BLACK = 104;
  SCE_ESCSEQ_BOLD_MAGENTA_BLACK = 105;
  SCE_ESCSEQ_BOLD_CYAN_BLACK = 106;
  SCE_ESCSEQ_BOLD_WHITE_BLACK = 107;
  SCE_ESCSEQ_BOLD_DEFAULT_RED = 108;
  SCE_ESCSEQ_BOLD_BLACK_RED = 109;
  SCE_ESCSEQ_BOLD_RED_RED = 110;
  SCE_ESCSEQ_BOLD_GREEN_RED = 111;
  SCE_ESCSEQ_BOLD_YELLOW_RED = 112;
  SCE_ESCSEQ_BOLD_BLUE_RED = 113;
  SCE_ESCSEQ_BOLD_MAGENTA_RED = 114;
  SCE_ESCSEQ_BOLD_CYAN_RED = 115;
  SCE_ESCSEQ_BOLD_WHITE_RED = 116;
  SCE_ESCSEQ_BOLD_DEFAULT_GREEN = 117;
  SCE_ESCSEQ_BOLD_BLACK_GREEN = 118;
  SCE_ESCSEQ_BOLD_RED_GREEN = 119;
  SCE_ESCSEQ_BOLD_GREEN_GREEN = 120;
  SCE_ESCSEQ_BOLD_YELLOW_GREEN = 121;
  SCE_ESCSEQ_BOLD_BLUE_GREEN = 122;
  SCE_ESCSEQ_BOLD_MAGENTA_GREEN = 123;
  SCE_ESCSEQ_BOLD_CYAN_GREEN = 124;
  SCE_ESCSEQ_BOLD_WHITE_GREEN = 125;
  SCE_ESCSEQ_BOLD_DEFAULT_YELLOW = 126;
  SCE_ESCSEQ_BOLD_BLACK_YELLOW = 127;
  SCE_ESCSEQ_BOLD_RED_YELLOW = 128;
  SCE_ESCSEQ_BOLD_GREEN_YELLOW = 129;
  SCE_ESCSEQ_BOLD_YELLOW_YELLOW = 130;
  SCE_ESCSEQ_BOLD_BLUE_YELLOW = 131;
  SCE_ESCSEQ_BOLD_MAGENTA_YELLOW = 132;
  SCE_ESCSEQ_BOLD_CYAN_YELLOW = 133;
  SCE_ESCSEQ_BOLD_WHITE_YELLOW = 134;
  SCE_ESCSEQ_BOLD_DEFAULT_BLUE = 135;
  SCE_ESCSEQ_BOLD_BLACK_BLUE = 136;
  SCE_ESCSEQ_BOLD_RED_BLUE = 137;
  SCE_ESCSEQ_BOLD_GREEN_BLUE = 138;
  SCE_ESCSEQ_BOLD_YELLOW_BLUE = 139;
  SCE_ESCSEQ_BOLD_BLUE_BLUE = 140;
  SCE_ESCSEQ_BOLD_MAGENTA_BLUE = 141;
  SCE_ESCSEQ_BOLD_CYAN_BLUE = 142;
  SCE_ESCSEQ_BOLD_WHITE_BLUE = 143;
  SCE_ESCSEQ_BOLD_DEFAULT_MAGENTA = 144;
  SCE_ESCSEQ_BOLD_BLACK_MAGENTA = 145;
  SCE_ESCSEQ_BOLD_RED_MAGENTA = 146;
  SCE_ESCSEQ_BOLD_GREEN_MAGENTA = 147;
  SCE_ESCSEQ_BOLD_YELLOW_MAGENTA = 148;
  SCE_ESCSEQ_BOLD_BLUE_MAGENTA = 149;
  SCE_ESCSEQ_BOLD_MAGENTA_MAGENTA = 150;
  SCE_ESCSEQ_BOLD_CYAN_MAGENTA = 151;
  SCE_ESCSEQ_BOLD_WHITE_MAGENTA = 152;
  SCE_ESCSEQ_BOLD_DEFAULT_CYAN = 153;
  SCE_ESCSEQ_BOLD_BLACK_CYAN = 154;
  SCE_ESCSEQ_BOLD_RED_CYAN = 155;
  SCE_ESCSEQ_BOLD_GREEN_CYAN = 156;
  SCE_ESCSEQ_BOLD_YELLOW_CYAN = 157;
  SCE_ESCSEQ_BOLD_BLUE_CYAN = 158;
  SCE_ESCSEQ_BOLD_MAGENTA_CYAN = 159;
  SCE_ESCSEQ_BOLD_CYAN_CYAN = 160;
  SCE_ESCSEQ_BOLD_WHITE_CYAN = 161;
  SCE_ESCSEQ_BOLD_DEFAULT_WHITE = 162;
  SCE_ESCSEQ_BOLD_BLACK_WHITE = 163;
  SCE_ESCSEQ_BOLD_RED_WHITE = 164;
  SCE_ESCSEQ_BOLD_GREEN_WHITE = 165;
  SCE_ESCSEQ_BOLD_YELLOW_WHITE = 166;
  SCE_ESCSEQ_BOLD_BLUE_WHITE = 167;
  SCE_ESCSEQ_BOLD_MAGENTA_WHITE = 168;
  SCE_ESCSEQ_BOLD_CYAN_WHITE = 169;
  SCE_ESCSEQ_BOLD_WHITE_WHITE = 170;
  SCE_ESCSEQ_IDENTIFIER = 171;
  SCE_ESCSEQ_UNKNOWN = 172;
  /// <summary>Set the lexing language of the document.</summary>
  SCI_SETLEXERLANGUAGE = 4006;

  /// <summary>Load an external lexer library.</summary>
  SCI_LOADLEXERLIBRARY = 4007;

// </scigen>

type
  TDSciUpdateFlagsSet = set of TDSciUpdate;

// <scigen-enum-func-decl>

function TDSciWhiteSpaceToInt(AEnum: TDSciWhiteSpace): Integer;
function TDSciWhiteSpaceFromInt(AEnum: Integer): TDSciWhiteSpace;
function TDSciTabDrawModeToInt(AEnum: TDSciTabDrawMode): Integer;
function TDSciTabDrawModeFromInt(AEnum: Integer): TDSciTabDrawMode;
function TDSciEndOfLineToInt(AEnum: TDSciEndOfLine): Integer;
function TDSciEndOfLineFromInt(AEnum: Integer): TDSciEndOfLine;
function TDSciIMEInteractionToInt(AEnum: TDSciIMEInteraction): Integer;
function TDSciIMEInteractionFromInt(AEnum: Integer): TDSciIMEInteraction;
function TDSciAlphaToInt(AEnum: TDSciAlpha): Integer;
function TDSciAlphaFromInt(AEnum: Integer): TDSciAlpha;
function TDSciCursorShapeToInt(AEnum: TDSciCursorShape): Integer;
function TDSciCursorShapeFromInt(AEnum: Integer): TDSciCursorShape;
function TDSciMarkerSymbolToInt(AEnum: TDSciMarkerSymbol): Integer;
function TDSciMarkerSymbolFromInt(AEnum: Integer): TDSciMarkerSymbol;
function TDSciMarkerOutlineToInt(AEnum: TDSciMarkerOutline): Integer;
function TDSciMarkerOutlineFromInt(AEnum: Integer): TDSciMarkerOutline;
function TDSciMarginTypeToInt(AEnum: TDSciMarginType): Integer;
function TDSciMarginTypeFromInt(AEnum: Integer): TDSciMarginType;
function TDSciStylesCommonToInt(AEnum: TDSciStylesCommon): Integer;
function TDSciStylesCommonFromInt(AEnum: Integer): TDSciStylesCommon;
function TDSciCharacterSetToInt(AEnum: TDSciCharacterSet): Integer;
function TDSciCharacterSetFromInt(AEnum: Integer): TDSciCharacterSet;
function TDSciCaseVisibleToInt(AEnum: TDSciCaseVisible): Integer;
function TDSciCaseVisibleFromInt(AEnum: Integer): TDSciCaseVisible;
function TDSciFontWeightToInt(AEnum: TDSciFontWeight): Integer;
function TDSciFontWeightFromInt(AEnum: Integer): TDSciFontWeight;
function TDSciFontStretchToInt(AEnum: TDSciFontStretch): Integer;
function TDSciFontStretchFromInt(AEnum: Integer): TDSciFontStretch;
function TDSciElementToInt(AEnum: TDSciElement): Integer;
function TDSciElementFromInt(AEnum: Integer): TDSciElement;
function TDSciLayerToInt(AEnum: TDSciLayer): Integer;
function TDSciLayerFromInt(AEnum: Integer): TDSciLayer;
function TDSciIndicatorStyleToInt(AEnum: TDSciIndicatorStyle): Integer;
function TDSciIndicatorStyleFromInt(AEnum: Integer): TDSciIndicatorStyle;
function TDSciIndicatorNumbersToInt(AEnum: TDSciIndicatorNumbers): Integer;
function TDSciIndicatorNumbersFromInt(AEnum: Integer): TDSciIndicatorNumbers;
function TDSciIndicValueToInt(AEnum: TDSciIndicValue): Integer;
function TDSciIndicValueFromInt(AEnum: Integer): TDSciIndicValue;
function TDSciIndicFlagToInt(AEnum: TDSciIndicFlag): Integer;
function TDSciIndicFlagFromInt(AEnum: Integer): TDSciIndicFlag;
function TDSciAutoCompleteOptionToInt(AEnum: TDSciAutoCompleteOption): Integer;
function TDSciAutoCompleteOptionFromInt(AEnum: Integer): TDSciAutoCompleteOption;
function TDSciIndentViewToInt(AEnum: TDSciIndentView): Integer;
function TDSciIndentViewFromInt(AEnum: Integer): TDSciIndentView;
function TDSciPrintOptionToInt(AEnum: TDSciPrintOption): Integer;
function TDSciPrintOptionFromInt(AEnum: Integer): TDSciPrintOption;
function TDSciFindOptionToInt(AEnum: TDSciFindOption): Integer;
function TDSciFindOptionFromInt(AEnum: Integer): TDSciFindOption;
function TDSciFindOptionSetToInt(AEnum: TDSciFindOptionSet): Integer;
function TDSciFindOptionSetFromInt(AEnum: Integer): TDSciFindOptionSet;
function TDSciChangeHistoryOptionToInt(AEnum: TDSciChangeHistoryOption): Integer;
function TDSciChangeHistoryOptionFromInt(AEnum: Integer): TDSciChangeHistoryOption;
function TDSciUndoSelectionHistoryOptionToInt(AEnum: TDSciUndoSelectionHistoryOption): Integer;
function TDSciUndoSelectionHistoryOptionFromInt(AEnum: Integer): TDSciUndoSelectionHistoryOption;
function TDSciFoldLevelToInt(AEnum: TDSciFoldLevel): Integer;
function TDSciFoldLevelFromInt(AEnum: Integer): TDSciFoldLevel;
function TDSciFoldLevelSetToInt(AEnum: TDSciFoldLevelSet): Integer;
function TDSciFoldLevelSetFromInt(AEnum: Integer): TDSciFoldLevelSet;
function TDSciFoldDisplayTextStyleToInt(AEnum: TDSciFoldDisplayTextStyle): Integer;
function TDSciFoldDisplayTextStyleFromInt(AEnum: Integer): TDSciFoldDisplayTextStyle;
function TDSciFoldActionToInt(AEnum: TDSciFoldAction): Integer;
function TDSciFoldActionFromInt(AEnum: Integer): TDSciFoldAction;
function TDSciAutomaticFoldToInt(AEnum: TDSciAutomaticFold): Integer;
function TDSciAutomaticFoldFromInt(AEnum: Integer): TDSciAutomaticFold;
function TDSciFoldFlagToInt(AEnum: TDSciFoldFlag): Integer;
function TDSciFoldFlagFromInt(AEnum: Integer): TDSciFoldFlag;
function TDSciFoldFlagSetToInt(AEnum: TDSciFoldFlagSet): Integer;
function TDSciFoldFlagSetFromInt(AEnum: Integer): TDSciFoldFlagSet;
function TDSciIdleStylingToInt(AEnum: TDSciIdleStyling): Integer;
function TDSciIdleStylingFromInt(AEnum: Integer): TDSciIdleStyling;
function TDSciWrapToInt(AEnum: TDSciWrap): Integer;
function TDSciWrapFromInt(AEnum: Integer): TDSciWrap;
function TDSciWrapVisualFlagToInt(AEnum: TDSciWrapVisualFlag): Integer;
function TDSciWrapVisualFlagFromInt(AEnum: Integer): TDSciWrapVisualFlag;
function TDSciWrapVisualFlagSetToInt(AEnum: TDSciWrapVisualFlagSet): Integer;
function TDSciWrapVisualFlagSetFromInt(AEnum: Integer): TDSciWrapVisualFlagSet;
function TDSciWrapVisualLocationToInt(AEnum: TDSciWrapVisualLocation): Integer;
function TDSciWrapVisualLocationFromInt(AEnum: Integer): TDSciWrapVisualLocation;
function TDSciWrapVisualLocationSetToInt(AEnum: TDSciWrapVisualLocationSet): Integer;
function TDSciWrapVisualLocationSetFromInt(AEnum: Integer): TDSciWrapVisualLocationSet;
function TDSciWrapIndentModeToInt(AEnum: TDSciWrapIndentMode): Integer;
function TDSciWrapIndentModeFromInt(AEnum: Integer): TDSciWrapIndentMode;
function TDSciLineCacheToInt(AEnum: TDSciLineCache): Integer;
function TDSciLineCacheFromInt(AEnum: Integer): TDSciLineCache;
function TDSciPhasesDrawToInt(AEnum: TDSciPhasesDraw): Integer;
function TDSciPhasesDrawFromInt(AEnum: Integer): TDSciPhasesDraw;
function TDSciFontQualityToInt(AEnum: TDSciFontQuality): Integer;
function TDSciFontQualityFromInt(AEnum: Integer): TDSciFontQuality;
function TDSciMultiPasteToInt(AEnum: TDSciMultiPaste): Integer;
function TDSciMultiPasteFromInt(AEnum: Integer): TDSciMultiPaste;
function TDSciAccessibilityToInt(AEnum: TDSciAccessibility): Integer;
function TDSciAccessibilityFromInt(AEnum: Integer): TDSciAccessibility;
function TDSciEdgeVisualStyleToInt(AEnum: TDSciEdgeVisualStyle): Integer;
function TDSciEdgeVisualStyleFromInt(AEnum: Integer): TDSciEdgeVisualStyle;
function TDSciPopUpToInt(AEnum: TDSciPopUp): Integer;
function TDSciPopUpFromInt(AEnum: Integer): TDSciPopUp;
function TDSciDocumentOptionToInt(AEnum: TDSciDocumentOption): Integer;
function TDSciDocumentOptionFromInt(AEnum: Integer): TDSciDocumentOption;
function TDSciStatusToInt(AEnum: TDSciStatus): Integer;
function TDSciStatusFromInt(AEnum: Integer): TDSciStatus;
function TDSciVisiblePolicyToInt(AEnum: TDSciVisiblePolicy): Integer;
function TDSciVisiblePolicyFromInt(AEnum: Integer): TDSciVisiblePolicy;
function TDSciVisiblePolicySetToInt(AEnum: TDSciVisiblePolicySet): Integer;
function TDSciVisiblePolicySetFromInt(AEnum: Integer): TDSciVisiblePolicySet;
function TDSciCaretPolicyToInt(AEnum: TDSciCaretPolicy): Integer;
function TDSciCaretPolicyFromInt(AEnum: Integer): TDSciCaretPolicy;
function TDSciCaretPolicySetToInt(AEnum: TDSciCaretPolicySet): Integer;
function TDSciCaretPolicySetFromInt(AEnum: Integer): TDSciCaretPolicySet;
function TDSciSelectionModeToInt(AEnum: TDSciSelectionMode): Integer;
function TDSciSelectionModeFromInt(AEnum: Integer): TDSciSelectionMode;
function TDSciCaseInsensitiveBehaviourToInt(AEnum: TDSciCaseInsensitiveBehaviour): Integer;
function TDSciCaseInsensitiveBehaviourFromInt(AEnum: Integer): TDSciCaseInsensitiveBehaviour;
function TDSciMultiAutoCompleteToInt(AEnum: TDSciMultiAutoComplete): Integer;
function TDSciMultiAutoCompleteFromInt(AEnum: Integer): TDSciMultiAutoComplete;
function TDSciOrderingToInt(AEnum: TDSciOrdering): Integer;
function TDSciOrderingFromInt(AEnum: Integer): TDSciOrdering;
function TDSciCaretStickyToInt(AEnum: TDSciCaretSticky): Integer;
function TDSciCaretStickyFromInt(AEnum: Integer): TDSciCaretSticky;
function TDSciCaretStyleToInt(AEnum: TDSciCaretStyle): Integer;
function TDSciCaretStyleFromInt(AEnum: Integer): TDSciCaretStyle;
function TDSciMarginOptionToInt(AEnum: TDSciMarginOption): Integer;
function TDSciMarginOptionFromInt(AEnum: Integer): TDSciMarginOption;
function TDSciAnnotationVisibleToInt(AEnum: TDSciAnnotationVisible): Integer;
function TDSciAnnotationVisibleFromInt(AEnum: Integer): TDSciAnnotationVisible;
function TDSciUndoFlagsToInt(AEnum: TDSciUndoFlags): Integer;
function TDSciUndoFlagsFromInt(AEnum: Integer): TDSciUndoFlags;
function TDSciUndoFlagsSetToInt(AEnum: TDSciUndoFlagsSet): Integer;
function TDSciUndoFlagsSetFromInt(AEnum: Integer): TDSciUndoFlagsSet;
function TDSciVirtualSpaceToInt(AEnum: TDSciVirtualSpace): Integer;
function TDSciVirtualSpaceFromInt(AEnum: Integer): TDSciVirtualSpace;
function TDSciVirtualSpaceSetToInt(AEnum: TDSciVirtualSpaceSet): Integer;
function TDSciVirtualSpaceSetFromInt(AEnum: Integer): TDSciVirtualSpaceSet;
function TDSciTechnologyToInt(AEnum: TDSciTechnology): Integer;
function TDSciTechnologyFromInt(AEnum: Integer): TDSciTechnology;
function TDSciLineEndTypeToInt(AEnum: TDSciLineEndType): Integer;
function TDSciLineEndTypeFromInt(AEnum: Integer): TDSciLineEndType;
function TDSciRepresentationAppearanceToInt(AEnum: TDSciRepresentationAppearance): Integer;
function TDSciRepresentationAppearanceFromInt(AEnum: Integer): TDSciRepresentationAppearance;
function TDSciEOLAnnotationVisibleToInt(AEnum: TDSciEOLAnnotationVisible): Integer;
function TDSciEOLAnnotationVisibleFromInt(AEnum: Integer): TDSciEOLAnnotationVisible;
function TDSciSupportsToInt(AEnum: TDSciSupports): Integer;
function TDSciSupportsFromInt(AEnum: Integer): TDSciSupports;
function TDSciLineCharacterIndexTypeToInt(AEnum: TDSciLineCharacterIndexType): Integer;
function TDSciLineCharacterIndexTypeFromInt(AEnum: Integer): TDSciLineCharacterIndexType;
function TDSciTypePropertyToInt(AEnum: TDSciTypeProperty): Integer;
function TDSciTypePropertyFromInt(AEnum: Integer): TDSciTypeProperty;
function TDSciModificationFlagsToInt(AEnum: TDSciModificationFlags): Integer;
function TDSciModificationFlagsFromInt(AEnum: Integer): TDSciModificationFlags;
function TDSciModificationFlagsSetToInt(AEnum: TDSciModificationFlagsSet): Integer;
function TDSciModificationFlagsSetFromInt(AEnum: Integer): TDSciModificationFlagsSet;
function TDSciUpdateToInt(AEnum: TDSciUpdate): Integer;
function TDSciUpdateFromInt(AEnum: Integer): TDSciUpdate;
function TDSciUpdateFlagsSetToInt(AEnum: TDSciUpdateFlagsSet): Integer;
function TDSciUpdateFlagsSetFromInt(AEnum: Integer): TDSciUpdateFlagsSet;
function TDSciFocusChangeToInt(AEnum: TDSciFocusChange): Integer;
function TDSciFocusChangeFromInt(AEnum: Integer): TDSciFocusChange;
function TDSciKeysToInt(AEnum: TDSciKeys): Integer;
function TDSciKeysFromInt(AEnum: Integer): TDSciKeys;
function TDSciKeyModToInt(AEnum: TDSciKeyMod): Integer;
function TDSciKeyModFromInt(AEnum: Integer): TDSciKeyMod;
function TDSciKeyModSetToInt(AEnum: TDSciKeyModSet): Integer;
function TDSciKeyModSetFromInt(AEnum: Integer): TDSciKeyModSet;
function TDSciCompletionMethodsToInt(AEnum: TDSciCompletionMethods): Integer;
function TDSciCompletionMethodsFromInt(AEnum: Integer): TDSciCompletionMethods;
function TDSciCharacterSourceToInt(AEnum: TDSciCharacterSource): Integer;
function TDSciCharacterSourceFromInt(AEnum: Integer): TDSciCharacterSource;
function TDSciBidirectionalToInt(AEnum: TDSciBidirectional): Integer;
function TDSciBidirectionalFromInt(AEnum: Integer): TDSciBidirectional;
function TDSciLexerIdToInt(AEnum: TDSciLexerId): Integer;
function TDSciLexerIdFromInt(AEnum: Integer): TDSciLexerId;

// </scigen-enum-func-decl>

type
{ TDScintilla events - http://www.scintilla.org/ScintillaDoc.html#Notifications }

  TDSciNotificationEvent = procedure(ASender: TObject; const ASCN: TDSciSCNotification; var AHandled: Boolean) of object;

  TDSciStyleNeededEvent = procedure(ASender: TObject; APosition: NativeInt) of object;
  TDSciCharAddedEvent = procedure(ASender: TObject; ACh: Integer) of object;
  TDSciSavePointReachedEvent = procedure(ASender: TObject) of object;
  TDSciSavePointLeftEvent = procedure(ASender: TObject) of object;
  TDSciModifyAttemptROEvent = procedure(ASender: TObject) of object;
  // # GTK+ Specific to work around focus and accelerator problems:
  // evt  Key=2005(Integer ch; Integer modifiers)
  // evt  DoubleClick=2006()
  TDSciUpdateUIEvent = procedure(ASender: TObject; AUpdated: TDSciUpdateFlagsSet) of object;
  TDSciModifiedEvent = procedure(ASender: TObject; APosition: NativeInt; AModificationType: Integer;
    AText: UnicodeString; ALength: NativeInt; ALinesAdded: NativeInt; ALine: NativeInt;
    AFoldLevelNow: Integer; AFoldLevelPrev: Integer) of object;
  TDSciModified2Event = procedure(ASender: TObject; APosition: NativeInt; AModificationType: Integer;
    AText: UnicodeString; ALength: NativeInt; ALinesAdded: NativeInt; ALine: NativeInt;
    AFoldLevelNow: Integer; AFoldLevelPrev: Integer;
    AToken: Integer; AAnnotationLinesAdded: NativeInt) of object;
  TDSciMacroRecordEvent = procedure(ASender: TObject; AMessage: Integer; AWParam: NativeInt; ALParam: NativeUInt) of object;
  TDSciMarginClickEvent = procedure(ASender: TObject; AModifiers: Integer; APosition: NativeInt; AMargin: Integer) of object;
  TDSciNeedShownEvent = procedure(ASender: TObject; APosition: NativeInt; ALength: NativeInt) of object;
  TDSciPaintedEvent = procedure(ASender: TObject) of object;
  TDSciUserListSelectionEvent = procedure(ASender: TObject; AListType: Integer; AText: UnicodeString) of object;
  TDSciUserListSelection2Event = procedure(ASender: TObject; AListType: Integer; AText: UnicodeString; APosition: NativeInt) of object;
  TDSciDwellStartEvent = procedure(ASender: TObject; APosition, X, Y: Integer) of object;
  TDSciDwellEndEvent = procedure(ASender: TObject; APosition, X, Y: Integer) of object;
  TDSciZoomEvent = procedure(ASender: TObject) of object;
  TDSciHotSpotClickEvent = procedure(ASender: TObject; AModifiers: Integer; APosition: NativeInt) of object;
  TDSciHotSpotDoubleClickEvent = procedure(ASender: TObject; AModifiers: Integer; APosition: NativeInt) of object;
  TDSciHotSpotReleaseClickEvent = procedure(ASender: TObject; AModifiers: Integer; APosition: NativeInt) of object;
  TDSciCallTipClickEvent = procedure(ASender: TObject; APosition: NativeInt) of object;
  TDSciAutoCSelectionEvent = procedure(ASender: TObject; AText: UnicodeString; APosition: NativeInt) of object;
  TDSciIndicatorClickEvent = procedure(ASender: TObject; AModifiers: Integer; APosition: NativeInt) of object;
  TDSciIndicatorReleaseEvent = procedure(ASender: TObject; AModifiers: Integer; APosition: NativeInt) of object;
  TDSciAutoCCancelledEvent = procedure(ASender: TObject) of object;
  TDSciAutoCCharDeletedEvent = procedure(ASender: TObject) of object;

implementation

// <scigen-enum-func-code>

function TDSciWhiteSpaceToInt(AEnum: TDSciWhiteSpace): Integer;
begin
  case AEnum of
  scwsINVISIBLE:                          /// <summary>SCWS_INVISIBLE = 0
    Result := 0;
  scwsVISIBLE_ALWAYS:                     /// <summary>SCWS_VISIBLEALWAYS = 1
    Result := 1;
  scwsVISIBLE_AFTER_INDENT:               /// <summary>SCWS_VISIBLEAFTERINDENT = 2
    Result := 2;
  scwsVISIBLE_ONLY_IN_INDENT:             /// <summary>SCWS_VISIBLEONLYININDENT = 3
    Result := 3;
  else
    Result := 0;
  end;
end;

function TDSciWhiteSpaceFromInt(AEnum: Integer): TDSciWhiteSpace;
begin
  case AEnum of
  0:
    Result := scwsINVISIBLE;                          /// <summary>SCWS_INVISIBLE = 0
  1:
    Result := scwsVISIBLE_ALWAYS;                     /// <summary>SCWS_VISIBLEALWAYS = 1
  2:
    Result := scwsVISIBLE_AFTER_INDENT;               /// <summary>SCWS_VISIBLEAFTERINDENT = 2
  3:
    Result := scwsVISIBLE_ONLY_IN_INDENT;             /// <summary>SCWS_VISIBLEONLYININDENT = 3
  else
    Result := scwsINVISIBLE;                          /// <summary>SCWS_INVISIBLE = 0;
  end;
end;

function TDSciTabDrawModeToInt(AEnum: TDSciTabDrawMode): Integer;
begin
  case AEnum of
  sctdmLONG_ARROW:                        /// <summary>SCTD_LONGARROW = 0
    Result := 0;
  sctdmSTRIKE_OUT:                        /// <summary>SCTD_STRIKEOUT = 1
    Result := 1;
  sctdmCONTROL_CHAR:                      /// <summary>SCTD_CONTROLCHAR = 2
    Result := 2;
  else
    Result := 0;
  end;
end;

function TDSciTabDrawModeFromInt(AEnum: Integer): TDSciTabDrawMode;
begin
  case AEnum of
  0:
    Result := sctdmLONG_ARROW;                        /// <summary>SCTD_LONGARROW = 0
  1:
    Result := sctdmSTRIKE_OUT;                        /// <summary>SCTD_STRIKEOUT = 1
  2:
    Result := sctdmCONTROL_CHAR;                      /// <summary>SCTD_CONTROLCHAR = 2
  else
    Result := sctdmLONG_ARROW;                        /// <summary>SCTD_LONGARROW = 0;
  end;
end;

function TDSciEndOfLineToInt(AEnum: TDSciEndOfLine): Integer;
begin
  case AEnum of
  sceolCR_LF:                             /// <summary>SC_EOL_CRLF = 0
    Result := 0;
  sceolCR:                                /// <summary>SC_EOL_CR = 1
    Result := 1;
  sceolLF:                                /// <summary>SC_EOL_LF = 2
    Result := 2;
  else
    Result := 0;
  end;
end;

function TDSciEndOfLineFromInt(AEnum: Integer): TDSciEndOfLine;
begin
  case AEnum of
  0:
    Result := sceolCR_LF;                             /// <summary>SC_EOL_CRLF = 0
  1:
    Result := sceolCR;                                /// <summary>SC_EOL_CR = 1
  2:
    Result := sceolLF;                                /// <summary>SC_EOL_LF = 2
  else
    Result := sceolCR_LF;                             /// <summary>SC_EOL_CRLF = 0;
  end;
end;

function TDSciIMEInteractionToInt(AEnum: TDSciIMEInteraction): Integer;
begin
  case AEnum of
  scimeiWINDOWED:                         /// <summary>SC_IME_WINDOWED = 0
    Result := 0;
  scimeiINLINE:                           /// <summary>SC_IME_INLINE = 1
    Result := 1;
  else
    Result := 0;
  end;
end;

function TDSciIMEInteractionFromInt(AEnum: Integer): TDSciIMEInteraction;
begin
  case AEnum of
  0:
    Result := scimeiWINDOWED;                         /// <summary>SC_IME_WINDOWED = 0
  1:
    Result := scimeiINLINE;                           /// <summary>SC_IME_INLINE = 1
  else
    Result := scimeiWINDOWED;                         /// <summary>SC_IME_WINDOWED = 0;
  end;
end;

function TDSciAlphaToInt(AEnum: TDSciAlpha): Integer;
begin
  case AEnum of
  scaTRANSPARENT:                         /// <summary>SC_ALPHA_TRANSPARENT = 0
    Result := 0;
  scaOPAQUE:                              /// <summary>SC_ALPHA_OPAQUE = 255
    Result := 255;
  scaNO_ALPHA:                            /// <summary>SC_ALPHA_NOALPHA = 256
    Result := 256;
  else
    Result := 0;
  end;
end;

function TDSciAlphaFromInt(AEnum: Integer): TDSciAlpha;
begin
  case AEnum of
  0:
    Result := scaTRANSPARENT;                         /// <summary>SC_ALPHA_TRANSPARENT = 0
  255:
    Result := scaOPAQUE;                              /// <summary>SC_ALPHA_OPAQUE = 255
  256:
    Result := scaNO_ALPHA;                            /// <summary>SC_ALPHA_NOALPHA = 256
  else
    Result := scaTRANSPARENT;                         /// <summary>SC_ALPHA_TRANSPARENT = 0;
  end;
end;

function TDSciCursorShapeToInt(AEnum: TDSciCursorShape): Integer;
begin
  case AEnum of
  sccsNORMAL:                             /// <summary>SC_CURSORNORMAL = -1
    Result := -1;
  sccsARROW:                              /// <summary>SC_CURSORARROW = 2
    Result := 2;
  sccsWAIT:                               /// <summary>SC_CURSORWAIT = 4
    Result := 4;
  sccsREVERSE_ARROW:                      /// <summary>SC_CURSORREVERSEARROW = 7
    Result := 7;
  else
    Result := -1;
  end;
end;

function TDSciCursorShapeFromInt(AEnum: Integer): TDSciCursorShape;
begin
  case AEnum of
  -1:
    Result := sccsNORMAL;                             /// <summary>SC_CURSORNORMAL = -1
  2:
    Result := sccsARROW;                              /// <summary>SC_CURSORARROW = 2
  4:
    Result := sccsWAIT;                               /// <summary>SC_CURSORWAIT = 4
  7:
    Result := sccsREVERSE_ARROW;                      /// <summary>SC_CURSORREVERSEARROW = 7
  else
    Result := sccsNORMAL;                             /// <summary>SC_CURSORNORMAL = -1;
  end;
end;

function TDSciMarkerSymbolToInt(AEnum: TDSciMarkerSymbol): Integer;
begin
  case AEnum of
  scmsCIRCLE:                             /// <summary>SC_MARK_CIRCLE = 0
    Result := 0;
  scmsROUND_RECT:                         /// <summary>SC_MARK_ROUNDRECT = 1
    Result := 1;
  scmsARROW:                              /// <summary>SC_MARK_ARROW = 2
    Result := 2;
  scmsSMALL_RECT:                         /// <summary>SC_MARK_SMALLRECT = 3
    Result := 3;
  scmsSHORT_ARROW:                        /// <summary>SC_MARK_SHORTARROW = 4
    Result := 4;
  scmsEMPTY:                              /// <summary>SC_MARK_EMPTY = 5
    Result := 5;
  scmsARROW_DOWN:                         /// <summary>SC_MARK_ARROWDOWN = 6
    Result := 6;
  scmsMINUS:                              /// <summary>SC_MARK_MINUS = 7
    Result := 7;
  scmsPLUS:                               /// <summary>SC_MARK_PLUS = 8
    Result := 8;
  scmsV_LINE:                             /// <summary>SC_MARK_VLINE = 9
    Result := 9;
  scmsL_CORNER:                           /// <summary>SC_MARK_LCORNER = 10
    Result := 10;
  scmsT_CORNER:                           /// <summary>SC_MARK_TCORNER = 11
    Result := 11;
  scmsBOX_PLUS:                           /// <summary>SC_MARK_BOXPLUS = 12
    Result := 12;
  scmsBOX_PLUS_CONNECTED:                 /// <summary>SC_MARK_BOXPLUSCONNECTED = 13
    Result := 13;
  scmsBOX_MINUS:                          /// <summary>SC_MARK_BOXMINUS = 14
    Result := 14;
  scmsBOX_MINUS_CONNECTED:                /// <summary>SC_MARK_BOXMINUSCONNECTED = 15
    Result := 15;
  scmsL_CORNER_CURVE:                     /// <summary>SC_MARK_LCORNERCURVE = 16
    Result := 16;
  scmsT_CORNER_CURVE:                     /// <summary>SC_MARK_TCORNERCURVE = 17
    Result := 17;
  scmsCIRCLE_PLUS:                        /// <summary>SC_MARK_CIRCLEPLUS = 18
    Result := 18;
  scmsCIRCLE_PLUS_CONNECTED:              /// <summary>SC_MARK_CIRCLEPLUSCONNECTED = 19
    Result := 19;
  scmsCIRCLE_MINUS:                       /// <summary>SC_MARK_CIRCLEMINUS = 20
    Result := 20;
  scmsCIRCLE_MINUS_CONNECTED:             /// <summary>SC_MARK_CIRCLEMINUSCONNECTED = 21
    Result := 21;
  scmsBACKGROUND:                         /// <summary>SC_MARK_BACKGROUND = 22
    Result := 22;
  scmsDOT_DOT_DOT:                        /// <summary>SC_MARK_DOTDOTDOT = 23
    Result := 23;
  scmsARROWS:                             /// <summary>SC_MARK_ARROWS = 24
    Result := 24;
  scmsPIXMAP:                             /// <summary>SC_MARK_PIXMAP = 25
    Result := 25;
  scmsFULL_RECT:                          /// <summary>SC_MARK_FULLRECT = 26
    Result := 26;
  scmsLEFT_RECT:                          /// <summary>SC_MARK_LEFTRECT = 27
    Result := 27;
  scmsAVAILABLE:                          /// <summary>SC_MARK_AVAILABLE = 28
    Result := 28;
  scmsUNDERLINE:                          /// <summary>SC_MARK_UNDERLINE = 29
    Result := 29;
  scmsRGBA_IMAGE:                         /// <summary>SC_MARK_RGBAIMAGE = 30
    Result := 30;
  scmsBOOKMARK:                           /// <summary>SC_MARK_BOOKMARK = 31
    Result := 31;
  scmsVERTICAL_BOOKMARK:                  /// <summary>SC_MARK_VERTICALBOOKMARK = 32
    Result := 32;
  scmsBAR:                                /// <summary>SC_MARK_BAR = 33
    Result := 33;
  scmsCHARACTER:                          /// <summary>SC_MARK_CHARACTER = 10000
    Result := 10000;
  else
    Result := 0;
  end;
end;

function TDSciMarkerSymbolFromInt(AEnum: Integer): TDSciMarkerSymbol;
begin
  case AEnum of
  0:
    Result := scmsCIRCLE;                             /// <summary>SC_MARK_CIRCLE = 0
  1:
    Result := scmsROUND_RECT;                         /// <summary>SC_MARK_ROUNDRECT = 1
  2:
    Result := scmsARROW;                              /// <summary>SC_MARK_ARROW = 2
  3:
    Result := scmsSMALL_RECT;                         /// <summary>SC_MARK_SMALLRECT = 3
  4:
    Result := scmsSHORT_ARROW;                        /// <summary>SC_MARK_SHORTARROW = 4
  5:
    Result := scmsEMPTY;                              /// <summary>SC_MARK_EMPTY = 5
  6:
    Result := scmsARROW_DOWN;                         /// <summary>SC_MARK_ARROWDOWN = 6
  7:
    Result := scmsMINUS;                              /// <summary>SC_MARK_MINUS = 7
  8:
    Result := scmsPLUS;                               /// <summary>SC_MARK_PLUS = 8
  9:
    Result := scmsV_LINE;                             /// <summary>SC_MARK_VLINE = 9
  10:
    Result := scmsL_CORNER;                           /// <summary>SC_MARK_LCORNER = 10
  11:
    Result := scmsT_CORNER;                           /// <summary>SC_MARK_TCORNER = 11
  12:
    Result := scmsBOX_PLUS;                           /// <summary>SC_MARK_BOXPLUS = 12
  13:
    Result := scmsBOX_PLUS_CONNECTED;                 /// <summary>SC_MARK_BOXPLUSCONNECTED = 13
  14:
    Result := scmsBOX_MINUS;                          /// <summary>SC_MARK_BOXMINUS = 14
  15:
    Result := scmsBOX_MINUS_CONNECTED;                /// <summary>SC_MARK_BOXMINUSCONNECTED = 15
  16:
    Result := scmsL_CORNER_CURVE;                     /// <summary>SC_MARK_LCORNERCURVE = 16
  17:
    Result := scmsT_CORNER_CURVE;                     /// <summary>SC_MARK_TCORNERCURVE = 17
  18:
    Result := scmsCIRCLE_PLUS;                        /// <summary>SC_MARK_CIRCLEPLUS = 18
  19:
    Result := scmsCIRCLE_PLUS_CONNECTED;              /// <summary>SC_MARK_CIRCLEPLUSCONNECTED = 19
  20:
    Result := scmsCIRCLE_MINUS;                       /// <summary>SC_MARK_CIRCLEMINUS = 20
  21:
    Result := scmsCIRCLE_MINUS_CONNECTED;             /// <summary>SC_MARK_CIRCLEMINUSCONNECTED = 21
  22:
    Result := scmsBACKGROUND;                         /// <summary>SC_MARK_BACKGROUND = 22
  23:
    Result := scmsDOT_DOT_DOT;                        /// <summary>SC_MARK_DOTDOTDOT = 23
  24:
    Result := scmsARROWS;                             /// <summary>SC_MARK_ARROWS = 24
  25:
    Result := scmsPIXMAP;                             /// <summary>SC_MARK_PIXMAP = 25
  26:
    Result := scmsFULL_RECT;                          /// <summary>SC_MARK_FULLRECT = 26
  27:
    Result := scmsLEFT_RECT;                          /// <summary>SC_MARK_LEFTRECT = 27
  28:
    Result := scmsAVAILABLE;                          /// <summary>SC_MARK_AVAILABLE = 28
  29:
    Result := scmsUNDERLINE;                          /// <summary>SC_MARK_UNDERLINE = 29
  30:
    Result := scmsRGBA_IMAGE;                         /// <summary>SC_MARK_RGBAIMAGE = 30
  31:
    Result := scmsBOOKMARK;                           /// <summary>SC_MARK_BOOKMARK = 31
  32:
    Result := scmsVERTICAL_BOOKMARK;                  /// <summary>SC_MARK_VERTICALBOOKMARK = 32
  33:
    Result := scmsBAR;                                /// <summary>SC_MARK_BAR = 33
  10000:
    Result := scmsCHARACTER;                          /// <summary>SC_MARK_CHARACTER = 10000
  else
    Result := scmsCIRCLE;                             /// <summary>SC_MARK_CIRCLE = 0;
  end;
end;

function TDSciMarkerOutlineToInt(AEnum: TDSciMarkerOutline): Integer;
begin
  case AEnum of
  scmoHISTORY_REVERTED_TO_ORIGIN:         /// <summary>SC_MARKNUM_HISTORY_REVERTED_TO_ORIGIN = 21
    Result := 21;
  scmoHISTORY_SAVED:                      /// <summary>SC_MARKNUM_HISTORY_SAVED = 22
    Result := 22;
  scmoHISTORY_MODIFIED:                   /// <summary>SC_MARKNUM_HISTORY_MODIFIED = 23
    Result := 23;
  scmoHISTORY_REVERTED_TO_MODIFIED:       /// <summary>SC_MARKNUM_HISTORY_REVERTED_TO_MODIFIED = 24
    Result := 24;
  scmoFOLDER_END:                         /// <summary>SC_MARKNUM_FOLDEREND = 25
    Result := 25;
  scmoFOLDER_OPEN_MID:                    /// <summary>SC_MARKNUM_FOLDEROPENMID = 26
    Result := 26;
  scmoFOLDER_MID_TAIL:                    /// <summary>SC_MARKNUM_FOLDERMIDTAIL = 27
    Result := 27;
  scmoFOLDER_TAIL:                        /// <summary>SC_MARKNUM_FOLDERTAIL = 28
    Result := 28;
  scmoFOLDER_SUB:                         /// <summary>SC_MARKNUM_FOLDERSUB = 29
    Result := 29;
  scmoFOLDER:                             /// <summary>SC_MARKNUM_FOLDER = 30
    Result := 30;
  scmoFOLDER_OPEN:                        /// <summary>SC_MARKNUM_FOLDEROPEN = 31
    Result := 31;
  else
    Result := 21;
  end;
end;

function TDSciMarkerOutlineFromInt(AEnum: Integer): TDSciMarkerOutline;
begin
  case AEnum of
  21:
    Result := scmoHISTORY_REVERTED_TO_ORIGIN;         /// <summary>SC_MARKNUM_HISTORY_REVERTED_TO_ORIGIN = 21
  22:
    Result := scmoHISTORY_SAVED;                      /// <summary>SC_MARKNUM_HISTORY_SAVED = 22
  23:
    Result := scmoHISTORY_MODIFIED;                   /// <summary>SC_MARKNUM_HISTORY_MODIFIED = 23
  24:
    Result := scmoHISTORY_REVERTED_TO_MODIFIED;       /// <summary>SC_MARKNUM_HISTORY_REVERTED_TO_MODIFIED = 24
  25:
    Result := scmoFOLDER_END;                         /// <summary>SC_MARKNUM_FOLDEREND = 25
  26:
    Result := scmoFOLDER_OPEN_MID;                    /// <summary>SC_MARKNUM_FOLDEROPENMID = 26
  27:
    Result := scmoFOLDER_MID_TAIL;                    /// <summary>SC_MARKNUM_FOLDERMIDTAIL = 27
  28:
    Result := scmoFOLDER_TAIL;                        /// <summary>SC_MARKNUM_FOLDERTAIL = 28
  29:
    Result := scmoFOLDER_SUB;                         /// <summary>SC_MARKNUM_FOLDERSUB = 29
  30:
    Result := scmoFOLDER;                             /// <summary>SC_MARKNUM_FOLDER = 30
  31:
    Result := scmoFOLDER_OPEN;                        /// <summary>SC_MARKNUM_FOLDEROPEN = 31
  else
    Result := scmoHISTORY_REVERTED_TO_ORIGIN;         /// <summary>SC_MARKNUM_HISTORY_REVERTED_TO_ORIGIN = 21;
  end;
end;

function TDSciMarginTypeToInt(AEnum: TDSciMarginType): Integer;
begin
  case AEnum of
  scmtSYMBOL:                             /// <summary>SC_MARGIN_SYMBOL = 0
    Result := 0;
  scmtNUMBER:                             /// <summary>SC_MARGIN_NUMBER = 1
    Result := 1;
  scmtBACK:                               /// <summary>SC_MARGIN_BACK = 2
    Result := 2;
  scmtFORE:                               /// <summary>SC_MARGIN_FORE = 3
    Result := 3;
  scmtTEXT:                               /// <summary>SC_MARGIN_TEXT = 4
    Result := 4;
  scmtR_TEXT:                             /// <summary>SC_MARGIN_RTEXT = 5
    Result := 5;
  scmtCOLOUR:                             /// <summary>SC_MARGIN_COLOUR = 6
    Result := 6;
  else
    Result := 0;
  end;
end;

function TDSciMarginTypeFromInt(AEnum: Integer): TDSciMarginType;
begin
  case AEnum of
  0:
    Result := scmtSYMBOL;                             /// <summary>SC_MARGIN_SYMBOL = 0
  1:
    Result := scmtNUMBER;                             /// <summary>SC_MARGIN_NUMBER = 1
  2:
    Result := scmtBACK;                               /// <summary>SC_MARGIN_BACK = 2
  3:
    Result := scmtFORE;                               /// <summary>SC_MARGIN_FORE = 3
  4:
    Result := scmtTEXT;                               /// <summary>SC_MARGIN_TEXT = 4
  5:
    Result := scmtR_TEXT;                             /// <summary>SC_MARGIN_RTEXT = 5
  6:
    Result := scmtCOLOUR;                             /// <summary>SC_MARGIN_COLOUR = 6
  else
    Result := scmtSYMBOL;                             /// <summary>SC_MARGIN_SYMBOL = 0;
  end;
end;

function TDSciStylesCommonToInt(AEnum: TDSciStylesCommon): Integer;
begin
  case AEnum of
  scscDEFAULT:                            /// <summary>STYLE_DEFAULT = 32
    Result := 32;
  scscLINE_NUMBER:                        /// <summary>STYLE_LINENUMBER = 33
    Result := 33;
  scscBRACE_LIGHT:                        /// <summary>STYLE_BRACELIGHT = 34
    Result := 34;
  scscBRACE_BAD:                          /// <summary>STYLE_BRACEBAD = 35
    Result := 35;
  scscCONTROL_CHAR:                       /// <summary>STYLE_CONTROLCHAR = 36
    Result := 36;
  scscINDENT_GUIDE:                       /// <summary>STYLE_INDENTGUIDE = 37
    Result := 37;
  scscCALL_TIP:                           /// <summary>STYLE_CALLTIP = 38
    Result := 38;
  scscFOLD_DISPLAY_TEXT:                  /// <summary>STYLE_FOLDDISPLAYTEXT = 39
    Result := 39;
  scscLAST_PREDEFINED:                    /// <summary>STYLE_LASTPREDEFINED = 39
    Result := 39;
  scscMAX:                                /// <summary>STYLE_MAX = 255
    Result := 255;
  else
    Result := 32;
  end;
end;

function TDSciStylesCommonFromInt(AEnum: Integer): TDSciStylesCommon;
begin
  case AEnum of
  32:
    Result := scscDEFAULT;                            /// <summary>STYLE_DEFAULT = 32
  33:
    Result := scscLINE_NUMBER;                        /// <summary>STYLE_LINENUMBER = 33
  34:
    Result := scscBRACE_LIGHT;                        /// <summary>STYLE_BRACELIGHT = 34
  35:
    Result := scscBRACE_BAD;                          /// <summary>STYLE_BRACEBAD = 35
  36:
    Result := scscCONTROL_CHAR;                       /// <summary>STYLE_CONTROLCHAR = 36
  37:
    Result := scscINDENT_GUIDE;                       /// <summary>STYLE_INDENTGUIDE = 37
  38:
    Result := scscCALL_TIP;                           /// <summary>STYLE_CALLTIP = 38
  39:
    Result := scscFOLD_DISPLAY_TEXT;                  /// <summary>STYLE_FOLDDISPLAYTEXT = 39
  255:
    Result := scscMAX;                                /// <summary>STYLE_MAX = 255
  else
    Result := scscDEFAULT;                            /// <summary>STYLE_DEFAULT = 32;
  end;
end;

function TDSciCharacterSetToInt(AEnum: TDSciCharacterSet): Integer;
begin
  case AEnum of
  sccsANSI:                               /// <summary>SC_CHARSET_ANSI = 0
    Result := 0;
  sccsDEFAULT:                            /// <summary>SC_CHARSET_DEFAULT = 1
    Result := 1;
  sccsBALTIC:                             /// <summary>SC_CHARSET_BALTIC = 186
    Result := 186;
  sccsCHINESE_BIG5:                       /// <summary>SC_CHARSET_CHINESEBIG5 = 136
    Result := 136;
  sccsEAST_EUROPE:                        /// <summary>SC_CHARSET_EASTEUROPE = 238
    Result := 238;
  sccsG_B_2312:                           /// <summary>SC_CHARSET_GB2312 = 134
    Result := 134;
  sccsGREEK:                              /// <summary>SC_CHARSET_GREEK = 161
    Result := 161;
  sccsHANGUL:                             /// <summary>SC_CHARSET_HANGUL = 129
    Result := 129;
  sccsMAC:                                /// <summary>SC_CHARSET_MAC = 77
    Result := 77;
  sccsOEM:                                /// <summary>SC_CHARSET_OEM = 255
    Result := 255;
  sccsRUSSIAN:                            /// <summary>SC_CHARSET_RUSSIAN = 204
    Result := 204;
  sccsOEM_866:                            /// <summary>SC_CHARSET_OEM866 = 866
    Result := 866;
  sccsCYRILLIC:                           /// <summary>SC_CHARSET_CYRILLIC = 1251
    Result := 1251;
  sccsSHIFT_JIS:                          /// <summary>SC_CHARSET_SHIFTJIS = 128
    Result := 128;
  sccsSYMBOL:                             /// <summary>SC_CHARSET_SYMBOL = 2
    Result := 2;
  sccsTURKISH:                            /// <summary>SC_CHARSET_TURKISH = 162
    Result := 162;
  sccsJOHAB:                              /// <summary>SC_CHARSET_JOHAB = 130
    Result := 130;
  sccsHEBREW:                             /// <summary>SC_CHARSET_HEBREW = 177
    Result := 177;
  sccsARABIC:                             /// <summary>SC_CHARSET_ARABIC = 178
    Result := 178;
  sccsVIETNAMESE:                         /// <summary>SC_CHARSET_VIETNAMESE = 163
    Result := 163;
  sccsTHAI:                               /// <summary>SC_CHARSET_THAI = 222
    Result := 222;
  sccsISO_8859_15:                        /// <summary>SC_CHARSET_8859_15 = 1000
    Result := 1000;
  else
    Result := 0;
  end;
end;

function TDSciCharacterSetFromInt(AEnum: Integer): TDSciCharacterSet;
begin
  case AEnum of
  0:
    Result := sccsANSI;                               /// <summary>SC_CHARSET_ANSI = 0
  1:
    Result := sccsDEFAULT;                            /// <summary>SC_CHARSET_DEFAULT = 1
  186:
    Result := sccsBALTIC;                             /// <summary>SC_CHARSET_BALTIC = 186
  136:
    Result := sccsCHINESE_BIG5;                       /// <summary>SC_CHARSET_CHINESEBIG5 = 136
  238:
    Result := sccsEAST_EUROPE;                        /// <summary>SC_CHARSET_EASTEUROPE = 238
  134:
    Result := sccsG_B_2312;                           /// <summary>SC_CHARSET_GB2312 = 134
  161:
    Result := sccsGREEK;                              /// <summary>SC_CHARSET_GREEK = 161
  129:
    Result := sccsHANGUL;                             /// <summary>SC_CHARSET_HANGUL = 129
  77:
    Result := sccsMAC;                                /// <summary>SC_CHARSET_MAC = 77
  255:
    Result := sccsOEM;                                /// <summary>SC_CHARSET_OEM = 255
  204:
    Result := sccsRUSSIAN;                            /// <summary>SC_CHARSET_RUSSIAN = 204
  866:
    Result := sccsOEM_866;                            /// <summary>SC_CHARSET_OEM866 = 866
  1251:
    Result := sccsCYRILLIC;                           /// <summary>SC_CHARSET_CYRILLIC = 1251
  128:
    Result := sccsSHIFT_JIS;                          /// <summary>SC_CHARSET_SHIFTJIS = 128
  2:
    Result := sccsSYMBOL;                             /// <summary>SC_CHARSET_SYMBOL = 2
  162:
    Result := sccsTURKISH;                            /// <summary>SC_CHARSET_TURKISH = 162
  130:
    Result := sccsJOHAB;                              /// <summary>SC_CHARSET_JOHAB = 130
  177:
    Result := sccsHEBREW;                             /// <summary>SC_CHARSET_HEBREW = 177
  178:
    Result := sccsARABIC;                             /// <summary>SC_CHARSET_ARABIC = 178
  163:
    Result := sccsVIETNAMESE;                         /// <summary>SC_CHARSET_VIETNAMESE = 163
  222:
    Result := sccsTHAI;                               /// <summary>SC_CHARSET_THAI = 222
  1000:
    Result := sccsISO_8859_15;                        /// <summary>SC_CHARSET_8859_15 = 1000
  else
    Result := sccsANSI;                               /// <summary>SC_CHARSET_ANSI = 0;
  end;
end;

function TDSciCaseVisibleToInt(AEnum: TDSciCaseVisible): Integer;
begin
  case AEnum of
  sccvMIXED:                              /// <summary>SC_CASE_MIXED = 0
    Result := 0;
  sccvUPPER:                              /// <summary>SC_CASE_UPPER = 1
    Result := 1;
  sccvLOWER:                              /// <summary>SC_CASE_LOWER = 2
    Result := 2;
  sccvCAMEL:                              /// <summary>SC_CASE_CAMEL = 3
    Result := 3;
  else
    Result := 0;
  end;
end;

function TDSciCaseVisibleFromInt(AEnum: Integer): TDSciCaseVisible;
begin
  case AEnum of
  0:
    Result := sccvMIXED;                              /// <summary>SC_CASE_MIXED = 0
  1:
    Result := sccvUPPER;                              /// <summary>SC_CASE_UPPER = 1
  2:
    Result := sccvLOWER;                              /// <summary>SC_CASE_LOWER = 2
  3:
    Result := sccvCAMEL;                              /// <summary>SC_CASE_CAMEL = 3
  else
    Result := sccvMIXED;                              /// <summary>SC_CASE_MIXED = 0;
  end;
end;

function TDSciFontWeightToInt(AEnum: TDSciFontWeight): Integer;
begin
  case AEnum of
  scfwNORMAL:                             /// <summary>SC_WEIGHT_NORMAL = 400
    Result := 400;
  scfwSEMI_BOLD:                          /// <summary>SC_WEIGHT_SEMIBOLD = 600
    Result := 600;
  scfwBOLD:                               /// <summary>SC_WEIGHT_BOLD = 700
    Result := 700;
  else
    Result := 400;
  end;
end;

function TDSciFontWeightFromInt(AEnum: Integer): TDSciFontWeight;
begin
  case AEnum of
  400:
    Result := scfwNORMAL;                             /// <summary>SC_WEIGHT_NORMAL = 400
  600:
    Result := scfwSEMI_BOLD;                          /// <summary>SC_WEIGHT_SEMIBOLD = 600
  700:
    Result := scfwBOLD;                               /// <summary>SC_WEIGHT_BOLD = 700
  else
    Result := scfwNORMAL;                             /// <summary>SC_WEIGHT_NORMAL = 400;
  end;
end;

function TDSciFontStretchToInt(AEnum: TDSciFontStretch): Integer;
begin
  case AEnum of
  scfsULTRA_CONDENSED:                    /// <summary>SC_STRETCH_ULTRA_CONDENSED = 1
    Result := 1;
  scfsEXTRA_CONDENSED:                    /// <summary>SC_STRETCH_EXTRA_CONDENSED = 2
    Result := 2;
  scfsCONDENSED:                          /// <summary>SC_STRETCH_CONDENSED = 3
    Result := 3;
  scfsSEMI_CONDENSED:                     /// <summary>SC_STRETCH_SEMI_CONDENSED = 4
    Result := 4;
  scfsNORMAL:                             /// <summary>SC_STRETCH_NORMAL = 5
    Result := 5;
  scfsSEMI_EXPANDED:                      /// <summary>SC_STRETCH_SEMI_EXPANDED = 6
    Result := 6;
  scfsEXPANDED:                           /// <summary>SC_STRETCH_EXPANDED = 7
    Result := 7;
  scfsEXTRA_EXPANDED:                     /// <summary>SC_STRETCH_EXTRA_EXPANDED = 8
    Result := 8;
  scfsULTRA_EXPANDED:                     /// <summary>SC_STRETCH_ULTRA_EXPANDED = 9
    Result := 9;
  else
    Result := 1;
  end;
end;

function TDSciFontStretchFromInt(AEnum: Integer): TDSciFontStretch;
begin
  case AEnum of
  1:
    Result := scfsULTRA_CONDENSED;                    /// <summary>SC_STRETCH_ULTRA_CONDENSED = 1
  2:
    Result := scfsEXTRA_CONDENSED;                    /// <summary>SC_STRETCH_EXTRA_CONDENSED = 2
  3:
    Result := scfsCONDENSED;                          /// <summary>SC_STRETCH_CONDENSED = 3
  4:
    Result := scfsSEMI_CONDENSED;                     /// <summary>SC_STRETCH_SEMI_CONDENSED = 4
  5:
    Result := scfsNORMAL;                             /// <summary>SC_STRETCH_NORMAL = 5
  6:
    Result := scfsSEMI_EXPANDED;                      /// <summary>SC_STRETCH_SEMI_EXPANDED = 6
  7:
    Result := scfsEXPANDED;                           /// <summary>SC_STRETCH_EXPANDED = 7
  8:
    Result := scfsEXTRA_EXPANDED;                     /// <summary>SC_STRETCH_EXTRA_EXPANDED = 8
  9:
    Result := scfsULTRA_EXPANDED;                     /// <summary>SC_STRETCH_ULTRA_EXPANDED = 9
  else
    Result := scfsULTRA_CONDENSED;                    /// <summary>SC_STRETCH_ULTRA_CONDENSED = 1;
  end;
end;

function TDSciElementToInt(AEnum: TDSciElement): Integer;
begin
  case AEnum of
  sceLIST:                                /// <summary>SC_ELEMENT_LIST = 0
    Result := 0;
  sceLIST_BACK:                           /// <summary>SC_ELEMENT_LIST_BACK = 1
    Result := 1;
  sceLIST_SELECTED:                       /// <summary>SC_ELEMENT_LIST_SELECTED = 2
    Result := 2;
  sceLIST_SELECTED_BACK:                  /// <summary>SC_ELEMENT_LIST_SELECTED_BACK = 3
    Result := 3;
  sceSELECTION_TEXT:                      /// <summary>SC_ELEMENT_SELECTION_TEXT = 10
    Result := 10;
  sceSELECTION_BACK:                      /// <summary>SC_ELEMENT_SELECTION_BACK = 11
    Result := 11;
  sceSELECTION_ADDITIONAL_TEXT:           /// <summary>SC_ELEMENT_SELECTION_ADDITIONAL_TEXT = 12
    Result := 12;
  sceSELECTION_ADDITIONAL_BACK:           /// <summary>SC_ELEMENT_SELECTION_ADDITIONAL_BACK = 13
    Result := 13;
  sceSELECTION_SECONDARY_TEXT:            /// <summary>SC_ELEMENT_SELECTION_SECONDARY_TEXT = 14
    Result := 14;
  sceSELECTION_SECONDARY_BACK:            /// <summary>SC_ELEMENT_SELECTION_SECONDARY_BACK = 15
    Result := 15;
  sceSELECTION_INACTIVE_TEXT:             /// <summary>SC_ELEMENT_SELECTION_INACTIVE_TEXT = 16
    Result := 16;
  sceSELECTION_INACTIVE_BACK:             /// <summary>SC_ELEMENT_SELECTION_INACTIVE_BACK = 17
    Result := 17;
  sceSELECTION_INACTIVE_ADDITIONAL_TEXT:  /// <summary>SC_ELEMENT_SELECTION_INACTIVE_ADDITIONAL_TEXT = 18
    Result := 18;
  sceSELECTION_INACTIVE_ADDITIONAL_BACK:  /// <summary>SC_ELEMENT_SELECTION_INACTIVE_ADDITIONAL_BACK = 19
    Result := 19;
  sceCARET:                               /// <summary>SC_ELEMENT_CARET = 40
    Result := 40;
  sceCARET_ADDITIONAL:                    /// <summary>SC_ELEMENT_CARET_ADDITIONAL = 41
    Result := 41;
  sceCARET_LINE_BACK:                     /// <summary>SC_ELEMENT_CARET_LINE_BACK = 50
    Result := 50;
  sceWHITE_SPACE:                         /// <summary>SC_ELEMENT_WHITE_SPACE = 60
    Result := 60;
  sceWHITE_SPACE_BACK:                    /// <summary>SC_ELEMENT_WHITE_SPACE_BACK = 61
    Result := 61;
  sceHOT_SPOT_ACTIVE:                     /// <summary>SC_ELEMENT_HOT_SPOT_ACTIVE = 70
    Result := 70;
  sceHOT_SPOT_ACTIVE_BACK:                /// <summary>SC_ELEMENT_HOT_SPOT_ACTIVE_BACK = 71
    Result := 71;
  sceFOLD_LINE:                           /// <summary>SC_ELEMENT_FOLD_LINE = 80
    Result := 80;
  sceHIDDEN_LINE:                         /// <summary>SC_ELEMENT_HIDDEN_LINE = 81
    Result := 81;
  else
    Result := 0;
  end;
end;

function TDSciElementFromInt(AEnum: Integer): TDSciElement;
begin
  case AEnum of
  0:
    Result := sceLIST;                                /// <summary>SC_ELEMENT_LIST = 0
  1:
    Result := sceLIST_BACK;                           /// <summary>SC_ELEMENT_LIST_BACK = 1
  2:
    Result := sceLIST_SELECTED;                       /// <summary>SC_ELEMENT_LIST_SELECTED = 2
  3:
    Result := sceLIST_SELECTED_BACK;                  /// <summary>SC_ELEMENT_LIST_SELECTED_BACK = 3
  10:
    Result := sceSELECTION_TEXT;                      /// <summary>SC_ELEMENT_SELECTION_TEXT = 10
  11:
    Result := sceSELECTION_BACK;                      /// <summary>SC_ELEMENT_SELECTION_BACK = 11
  12:
    Result := sceSELECTION_ADDITIONAL_TEXT;           /// <summary>SC_ELEMENT_SELECTION_ADDITIONAL_TEXT = 12
  13:
    Result := sceSELECTION_ADDITIONAL_BACK;           /// <summary>SC_ELEMENT_SELECTION_ADDITIONAL_BACK = 13
  14:
    Result := sceSELECTION_SECONDARY_TEXT;            /// <summary>SC_ELEMENT_SELECTION_SECONDARY_TEXT = 14
  15:
    Result := sceSELECTION_SECONDARY_BACK;            /// <summary>SC_ELEMENT_SELECTION_SECONDARY_BACK = 15
  16:
    Result := sceSELECTION_INACTIVE_TEXT;             /// <summary>SC_ELEMENT_SELECTION_INACTIVE_TEXT = 16
  17:
    Result := sceSELECTION_INACTIVE_BACK;             /// <summary>SC_ELEMENT_SELECTION_INACTIVE_BACK = 17
  18:
    Result := sceSELECTION_INACTIVE_ADDITIONAL_TEXT;  /// <summary>SC_ELEMENT_SELECTION_INACTIVE_ADDITIONAL_TEXT = 18
  19:
    Result := sceSELECTION_INACTIVE_ADDITIONAL_BACK;  /// <summary>SC_ELEMENT_SELECTION_INACTIVE_ADDITIONAL_BACK = 19
  40:
    Result := sceCARET;                               /// <summary>SC_ELEMENT_CARET = 40
  41:
    Result := sceCARET_ADDITIONAL;                    /// <summary>SC_ELEMENT_CARET_ADDITIONAL = 41
  50:
    Result := sceCARET_LINE_BACK;                     /// <summary>SC_ELEMENT_CARET_LINE_BACK = 50
  60:
    Result := sceWHITE_SPACE;                         /// <summary>SC_ELEMENT_WHITE_SPACE = 60
  61:
    Result := sceWHITE_SPACE_BACK;                    /// <summary>SC_ELEMENT_WHITE_SPACE_BACK = 61
  70:
    Result := sceHOT_SPOT_ACTIVE;                     /// <summary>SC_ELEMENT_HOT_SPOT_ACTIVE = 70
  71:
    Result := sceHOT_SPOT_ACTIVE_BACK;                /// <summary>SC_ELEMENT_HOT_SPOT_ACTIVE_BACK = 71
  80:
    Result := sceFOLD_LINE;                           /// <summary>SC_ELEMENT_FOLD_LINE = 80
  81:
    Result := sceHIDDEN_LINE;                         /// <summary>SC_ELEMENT_HIDDEN_LINE = 81
  else
    Result := sceLIST;                                /// <summary>SC_ELEMENT_LIST = 0;
  end;
end;

function TDSciLayerToInt(AEnum: TDSciLayer): Integer;
begin
  case AEnum of
  sclBASE:                                /// <summary>SC_LAYER_BASE = 0
    Result := 0;
  sclUNDER_TEXT:                          /// <summary>SC_LAYER_UNDER_TEXT = 1
    Result := 1;
  sclOVER_TEXT:                           /// <summary>SC_LAYER_OVER_TEXT = 2
    Result := 2;
  else
    Result := 0;
  end;
end;

function TDSciLayerFromInt(AEnum: Integer): TDSciLayer;
begin
  case AEnum of
  0:
    Result := sclBASE;                                /// <summary>SC_LAYER_BASE = 0
  1:
    Result := sclUNDER_TEXT;                          /// <summary>SC_LAYER_UNDER_TEXT = 1
  2:
    Result := sclOVER_TEXT;                           /// <summary>SC_LAYER_OVER_TEXT = 2
  else
    Result := sclBASE;                                /// <summary>SC_LAYER_BASE = 0;
  end;
end;

function TDSciIndicatorStyleToInt(AEnum: TDSciIndicatorStyle): Integer;
begin
  case AEnum of
  scisPLAIN:                              /// <summary>INDIC_PLAIN = 0
    Result := 0;
  scisSQUIGGLE:                           /// <summary>INDIC_SQUIGGLE = 1
    Result := 1;
  scisT_T:                                /// <summary>INDIC_TT = 2
    Result := 2;
  scisDIAGONAL:                           /// <summary>INDIC_DIAGONAL = 3
    Result := 3;
  scisSTRIKE:                             /// <summary>INDIC_STRIKE = 4
    Result := 4;
  scisHIDDEN:                             /// <summary>INDIC_HIDDEN = 5
    Result := 5;
  scisBOX:                                /// <summary>INDIC_BOX = 6
    Result := 6;
  scisROUND_BOX:                          /// <summary>INDIC_ROUNDBOX = 7
    Result := 7;
  scisSTRAIGHT_BOX:                       /// <summary>INDIC_STRAIGHTBOX = 8
    Result := 8;
  scisDASH:                               /// <summary>INDIC_DASH = 9
    Result := 9;
  scisDOTS:                               /// <summary>INDIC_DOTS = 10
    Result := 10;
  scisSQUIGGLE_LOW:                       /// <summary>INDIC_SQUIGGLELOW = 11
    Result := 11;
  scisDOT_BOX:                            /// <summary>INDIC_DOTBOX = 12
    Result := 12;
  scisSQUIGGLE_PIXMAP:                    /// <summary>INDIC_SQUIGGLEPIXMAP = 13
    Result := 13;
  scisCOMPOSITION_THICK:                  /// <summary>INDIC_COMPOSITIONTHICK = 14
    Result := 14;
  scisCOMPOSITION_THIN:                   /// <summary>INDIC_COMPOSITIONTHIN = 15
    Result := 15;
  scisFULL_BOX:                           /// <summary>INDIC_FULLBOX = 16
    Result := 16;
  scisTEXT_FORE:                          /// <summary>INDIC_TEXTFORE = 17
    Result := 17;
  scisPOINT:                              /// <summary>INDIC_POINT = 18
    Result := 18;
  scisPOINT_CHARACTER:                    /// <summary>INDIC_POINTCHARACTER = 19
    Result := 19;
  scisGRADIENT:                           /// <summary>INDIC_GRADIENT = 20
    Result := 20;
  scisGRADIENT_CENTRE:                    /// <summary>INDIC_GRADIENTCENTRE = 21
    Result := 21;
  scisPOINT_TOP:                          /// <summary>INDIC_POINT_TOP = 22
    Result := 22;
  scisCONTAINER:                          /// <summary>INDIC_CONTAINER = 8
    Result := 8;
  scisIME:                                /// <summary>INDIC_IME = 32
    Result := 32;
  scisIME_MAX:                            /// <summary>INDIC_IME_MAX = 35
    Result := 35;
  scisMAX:                                /// <summary>INDIC_MAX = 35
    Result := 35;
  else
    Result := 0;
  end;
end;

function TDSciIndicatorStyleFromInt(AEnum: Integer): TDSciIndicatorStyle;
begin
  case AEnum of
  0:
    Result := scisPLAIN;                              /// <summary>INDIC_PLAIN = 0
  1:
    Result := scisSQUIGGLE;                           /// <summary>INDIC_SQUIGGLE = 1
  2:
    Result := scisT_T;                                /// <summary>INDIC_TT = 2
  3:
    Result := scisDIAGONAL;                           /// <summary>INDIC_DIAGONAL = 3
  4:
    Result := scisSTRIKE;                             /// <summary>INDIC_STRIKE = 4
  5:
    Result := scisHIDDEN;                             /// <summary>INDIC_HIDDEN = 5
  6:
    Result := scisBOX;                                /// <summary>INDIC_BOX = 6
  7:
    Result := scisROUND_BOX;                          /// <summary>INDIC_ROUNDBOX = 7
  8:
    Result := scisSTRAIGHT_BOX;                       /// <summary>INDIC_STRAIGHTBOX = 8
  9:
    Result := scisDASH;                               /// <summary>INDIC_DASH = 9
  10:
    Result := scisDOTS;                               /// <summary>INDIC_DOTS = 10
  11:
    Result := scisSQUIGGLE_LOW;                       /// <summary>INDIC_SQUIGGLELOW = 11
  12:
    Result := scisDOT_BOX;                            /// <summary>INDIC_DOTBOX = 12
  13:
    Result := scisSQUIGGLE_PIXMAP;                    /// <summary>INDIC_SQUIGGLEPIXMAP = 13
  14:
    Result := scisCOMPOSITION_THICK;                  /// <summary>INDIC_COMPOSITIONTHICK = 14
  15:
    Result := scisCOMPOSITION_THIN;                   /// <summary>INDIC_COMPOSITIONTHIN = 15
  16:
    Result := scisFULL_BOX;                           /// <summary>INDIC_FULLBOX = 16
  17:
    Result := scisTEXT_FORE;                          /// <summary>INDIC_TEXTFORE = 17
  18:
    Result := scisPOINT;                              /// <summary>INDIC_POINT = 18
  19:
    Result := scisPOINT_CHARACTER;                    /// <summary>INDIC_POINTCHARACTER = 19
  20:
    Result := scisGRADIENT;                           /// <summary>INDIC_GRADIENT = 20
  21:
    Result := scisGRADIENT_CENTRE;                    /// <summary>INDIC_GRADIENTCENTRE = 21
  22:
    Result := scisPOINT_TOP;                          /// <summary>INDIC_POINT_TOP = 22
  32:
    Result := scisIME;                                /// <summary>INDIC_IME = 32
  35:
    Result := scisIME_MAX;                            /// <summary>INDIC_IME_MAX = 35
  else
    Result := scisPLAIN;                              /// <summary>INDIC_PLAIN = 0;
  end;
end;

function TDSciIndicatorNumbersToInt(AEnum: TDSciIndicatorNumbers): Integer;
begin
  case AEnum of
  scinCONTAINER:                          /// <summary>INDICATOR_CONTAINER = 8
    Result := 8;
  scinIME:                                /// <summary>INDICATOR_IME = 32
    Result := 32;
  scinIME_MAX:                            /// <summary>INDICATOR_IME_MAX = 35
    Result := 35;
  scinHISTORY_REVERTED_TO_ORIGIN_INSERTION:/// <summary>INDICATOR_HISTORY_REVERTED_TO_ORIGIN_INSERTION = 36
    Result := 36;
  scinHISTORY_REVERTED_TO_ORIGIN_DELETION:/// <summary>INDICATOR_HISTORY_REVERTED_TO_ORIGIN_DELETION = 37
    Result := 37;
  scinHISTORY_SAVED_INSERTION:            /// <summary>INDICATOR_HISTORY_SAVED_INSERTION = 38
    Result := 38;
  scinHISTORY_SAVED_DELETION:             /// <summary>INDICATOR_HISTORY_SAVED_DELETION = 39
    Result := 39;
  scinHISTORY_MODIFIED_INSERTION:         /// <summary>INDICATOR_HISTORY_MODIFIED_INSERTION = 40
    Result := 40;
  scinHISTORY_MODIFIED_DELETION:          /// <summary>INDICATOR_HISTORY_MODIFIED_DELETION = 41
    Result := 41;
  scinHISTORY_REVERTED_TO_MODIFIED_INSERTION:/// <summary>INDICATOR_HISTORY_REVERTED_TO_MODIFIED_INSERTION = 42
    Result := 42;
  scinHISTORY_REVERTED_TO_MODIFIED_DELETION:/// <summary>INDICATOR_HISTORY_REVERTED_TO_MODIFIED_DELETION = 43
    Result := 43;
  scinMAX:                                /// <summary>INDICATOR_MAX = 43
    Result := 43;
  else
    Result := 8;
  end;
end;

function TDSciIndicatorNumbersFromInt(AEnum: Integer): TDSciIndicatorNumbers;
begin
  case AEnum of
  8:
    Result := scinCONTAINER;                          /// <summary>INDICATOR_CONTAINER = 8
  32:
    Result := scinIME;                                /// <summary>INDICATOR_IME = 32
  35:
    Result := scinIME_MAX;                            /// <summary>INDICATOR_IME_MAX = 35
  36:
    Result := scinHISTORY_REVERTED_TO_ORIGIN_INSERTION;/// <summary>INDICATOR_HISTORY_REVERTED_TO_ORIGIN_INSERTION = 36
  37:
    Result := scinHISTORY_REVERTED_TO_ORIGIN_DELETION;/// <summary>INDICATOR_HISTORY_REVERTED_TO_ORIGIN_DELETION = 37
  38:
    Result := scinHISTORY_SAVED_INSERTION;            /// <summary>INDICATOR_HISTORY_SAVED_INSERTION = 38
  39:
    Result := scinHISTORY_SAVED_DELETION;             /// <summary>INDICATOR_HISTORY_SAVED_DELETION = 39
  40:
    Result := scinHISTORY_MODIFIED_INSERTION;         /// <summary>INDICATOR_HISTORY_MODIFIED_INSERTION = 40
  41:
    Result := scinHISTORY_MODIFIED_DELETION;          /// <summary>INDICATOR_HISTORY_MODIFIED_DELETION = 41
  42:
    Result := scinHISTORY_REVERTED_TO_MODIFIED_INSERTION;/// <summary>INDICATOR_HISTORY_REVERTED_TO_MODIFIED_INSERTION = 42
  43:
    Result := scinHISTORY_REVERTED_TO_MODIFIED_DELETION;/// <summary>INDICATOR_HISTORY_REVERTED_TO_MODIFIED_DELETION = 43
  else
    Result := scinCONTAINER;                          /// <summary>INDICATOR_CONTAINER = 8;
  end;
end;

function TDSciIndicValueToInt(AEnum: TDSciIndicValue): Integer;
begin
  case AEnum of
  scivBIT:                                /// <summary>SC_INDICVALUEBIT = $1000000
    Result := $1000000;
  scivMASK:                               /// <summary>SC_INDICVALUEMASK = $FFFFFF
    Result := $FFFFFF;
  else
    Result := $1000000;
  end;
end;

function TDSciIndicValueFromInt(AEnum: Integer): TDSciIndicValue;
begin
  case AEnum of
  $1000000:
    Result := scivBIT;                                /// <summary>SC_INDICVALUEBIT = $1000000
  $FFFFFF:
    Result := scivMASK;                               /// <summary>SC_INDICVALUEMASK = $FFFFFF
  else
    Result := scivBIT;                                /// <summary>SC_INDICVALUEBIT = $1000000;
  end;
end;

function TDSciIndicFlagToInt(AEnum: TDSciIndicFlag): Integer;
begin
  case AEnum of
  scifNONE:                               /// <summary>SC_INDICFLAG_NONE = 0
    Result := 0;
  scifVALUE_FORE:                         /// <summary>SC_INDICFLAG_VALUEFORE = 1
    Result := 1;
  else
    Result := 0;
  end;
end;

function TDSciIndicFlagFromInt(AEnum: Integer): TDSciIndicFlag;
begin
  case AEnum of
  0:
    Result := scifNONE;                               /// <summary>SC_INDICFLAG_NONE = 0
  1:
    Result := scifVALUE_FORE;                         /// <summary>SC_INDICFLAG_VALUEFORE = 1
  else
    Result := scifNONE;                               /// <summary>SC_INDICFLAG_NONE = 0;
  end;
end;

function TDSciAutoCompleteOptionToInt(AEnum: TDSciAutoCompleteOption): Integer;
begin
  case AEnum of
  scacoNORMAL:                            /// <summary>SC_AUTOCOMPLETE_NORMAL = 0
    Result := 0;
  scacoFIXED_SIZE:                        /// <summary>SC_AUTOCOMPLETE_FIXED_SIZE = 1
    Result := 1;
  scacoSELECT_FIRST_ITEM:                 /// <summary>SC_AUTOCOMPLETE_SELECT_FIRST_ITEM = 2
    Result := 2;
  else
    Result := 0;
  end;
end;

function TDSciAutoCompleteOptionFromInt(AEnum: Integer): TDSciAutoCompleteOption;
begin
  case AEnum of
  0:
    Result := scacoNORMAL;                            /// <summary>SC_AUTOCOMPLETE_NORMAL = 0
  1:
    Result := scacoFIXED_SIZE;                        /// <summary>SC_AUTOCOMPLETE_FIXED_SIZE = 1
  2:
    Result := scacoSELECT_FIRST_ITEM;                 /// <summary>SC_AUTOCOMPLETE_SELECT_FIRST_ITEM = 2
  else
    Result := scacoNORMAL;                            /// <summary>SC_AUTOCOMPLETE_NORMAL = 0;
  end;
end;

function TDSciIndentViewToInt(AEnum: TDSciIndentView): Integer;
begin
  case AEnum of
  scivNONE:                               /// <summary>SC_IV_NONE = 0
    Result := 0;
  scivREAL:                               /// <summary>SC_IV_REAL = 1
    Result := 1;
  scivLOOK_FORWARD:                       /// <summary>SC_IV_LOOKFORWARD = 2
    Result := 2;
  scivLOOK_BOTH:                          /// <summary>SC_IV_LOOKBOTH = 3
    Result := 3;
  else
    Result := 0;
  end;
end;

function TDSciIndentViewFromInt(AEnum: Integer): TDSciIndentView;
begin
  case AEnum of
  0:
    Result := scivNONE;                               /// <summary>SC_IV_NONE = 0
  1:
    Result := scivREAL;                               /// <summary>SC_IV_REAL = 1
  2:
    Result := scivLOOK_FORWARD;                       /// <summary>SC_IV_LOOKFORWARD = 2
  3:
    Result := scivLOOK_BOTH;                          /// <summary>SC_IV_LOOKBOTH = 3
  else
    Result := scivNONE;                               /// <summary>SC_IV_NONE = 0;
  end;
end;

function TDSciPrintOptionToInt(AEnum: TDSciPrintOption): Integer;
begin
  case AEnum of
  scpoNORMAL:                             /// <summary>SC_PRINT_NORMAL = 0
    Result := 0;
  scpoINVERT_LIGHT:                       /// <summary>SC_PRINT_INVERTLIGHT = 1
    Result := 1;
  scpoBLACK_ON_WHITE:                     /// <summary>SC_PRINT_BLACKONWHITE = 2
    Result := 2;
  scpoCOLOUR_ON_WHITE:                    /// <summary>SC_PRINT_COLOURONWHITE = 3
    Result := 3;
  scpoCOLOUR_ON_WHITE_DEFAULT_B_G:        /// <summary>SC_PRINT_COLOURONWHITEDEFAULTBG = 4
    Result := 4;
  scpoSCREEN_COLOURS:                     /// <summary>SC_PRINT_SCREENCOLOURS = 5
    Result := 5;
  else
    Result := 0;
  end;
end;

function TDSciPrintOptionFromInt(AEnum: Integer): TDSciPrintOption;
begin
  case AEnum of
  0:
    Result := scpoNORMAL;                             /// <summary>SC_PRINT_NORMAL = 0
  1:
    Result := scpoINVERT_LIGHT;                       /// <summary>SC_PRINT_INVERTLIGHT = 1
  2:
    Result := scpoBLACK_ON_WHITE;                     /// <summary>SC_PRINT_BLACKONWHITE = 2
  3:
    Result := scpoCOLOUR_ON_WHITE;                    /// <summary>SC_PRINT_COLOURONWHITE = 3
  4:
    Result := scpoCOLOUR_ON_WHITE_DEFAULT_B_G;        /// <summary>SC_PRINT_COLOURONWHITEDEFAULTBG = 4
  5:
    Result := scpoSCREEN_COLOURS;                     /// <summary>SC_PRINT_SCREENCOLOURS = 5
  else
    Result := scpoNORMAL;                             /// <summary>SC_PRINT_NORMAL = 0;
  end;
end;

function TDSciFindOptionToInt(AEnum: TDSciFindOption): Integer;
begin
  case AEnum of
  scfoWHOLE_WORD:                         /// <summary>SCFIND_WHOLEWORD = $2
    Result := $2;
  scfoMATCH_CASE:                         /// <summary>SCFIND_MATCHCASE = $4
    Result := $4;
  scfoWORD_START:                         /// <summary>SCFIND_WORDSTART = $00100000
    Result := $00100000;
  scfoREG_EXP:                            /// <summary>SCFIND_REGEXP = $00200000
    Result := $00200000;
  scfoPOSIX:                              /// <summary>SCFIND_POSIX = $00400000
    Result := $00400000;
  scfoCXX11_REG_EX:                       /// <summary>SCFIND_CXX11REGEX = $00800000
    Result := $00800000;
  else
    Result := $2;
  end;
end;

function TDSciFindOptionFromInt(AEnum: Integer): TDSciFindOption;
begin
  case AEnum of
  $2:
    Result := scfoWHOLE_WORD;                         /// <summary>SCFIND_WHOLEWORD = $2
  $4:
    Result := scfoMATCH_CASE;                         /// <summary>SCFIND_MATCHCASE = $4
  $00100000:
    Result := scfoWORD_START;                         /// <summary>SCFIND_WORDSTART = $00100000
  $00200000:
    Result := scfoREG_EXP;                            /// <summary>SCFIND_REGEXP = $00200000
  $00400000:
    Result := scfoPOSIX;                              /// <summary>SCFIND_POSIX = $00400000
  $00800000:
    Result := scfoCXX11_REG_EX;                       /// <summary>SCFIND_CXX11REGEX = $00800000
  else
    Result := scfoWHOLE_WORD;                         /// <summary>SCFIND_WHOLEWORD = $2;
  end;
end;

function TDSciFindOptionSetToInt(AEnum: TDSciFindOptionSet): Integer;
var
  lEnum: TDSciFindOption;
begin
  Result := 0;

  for lEnum in AEnum do
    Result := Result or TDSciFindOptionToInt(lEnum);
end;

function TDSciFindOptionSetFromInt(AEnum: Integer): TDSciFindOptionSet;
var
  lEnum: TDSciFindOption;
begin
  Result := [];

  for lEnum := Low(TDSciFindOption) to High(TDSciFindOption) do
    if AEnum and TDSciFindOptionToInt(lEnum) <> 0 then
      Include(Result, lEnum);
end;

function TDSciChangeHistoryOptionToInt(AEnum: TDSciChangeHistoryOption): Integer;
begin
  case AEnum of
  scchoDISABLED:                          /// <summary>SC_CHANGE_HISTORY_DISABLED = 0
    Result := 0;
  scchoENABLED:                           /// <summary>SC_CHANGE_HISTORY_ENABLED = 1
    Result := 1;
  scchoMARKERS:                           /// <summary>SC_CHANGE_HISTORY_MARKERS = 2
    Result := 2;
  scchoINDICATORS:                        /// <summary>SC_CHANGE_HISTORY_INDICATORS = 4
    Result := 4;
  else
    Result := 0;
  end;
end;

function TDSciChangeHistoryOptionFromInt(AEnum: Integer): TDSciChangeHistoryOption;
begin
  case AEnum of
  0:
    Result := scchoDISABLED;                          /// <summary>SC_CHANGE_HISTORY_DISABLED = 0
  1:
    Result := scchoENABLED;                           /// <summary>SC_CHANGE_HISTORY_ENABLED = 1
  2:
    Result := scchoMARKERS;                           /// <summary>SC_CHANGE_HISTORY_MARKERS = 2
  4:
    Result := scchoINDICATORS;                        /// <summary>SC_CHANGE_HISTORY_INDICATORS = 4
  else
    Result := scchoDISABLED;                          /// <summary>SC_CHANGE_HISTORY_DISABLED = 0;
  end;
end;

function TDSciUndoSelectionHistoryOptionToInt(AEnum: TDSciUndoSelectionHistoryOption): Integer;
begin
  case AEnum of
  scushoDISABLED:                         /// <summary>SC_UNDO_SELECTION_HISTORY_DISABLED = 0
    Result := 0;
  scushoENABLED:                          /// <summary>SC_UNDO_SELECTION_HISTORY_ENABLED = 1
    Result := 1;
  scushoSCROLL:                           /// <summary>SC_UNDO_SELECTION_HISTORY_SCROLL = 2
    Result := 2;
  else
    Result := 0;
  end;
end;

function TDSciUndoSelectionHistoryOptionFromInt(AEnum: Integer): TDSciUndoSelectionHistoryOption;
begin
  case AEnum of
  0:
    Result := scushoDISABLED;                         /// <summary>SC_UNDO_SELECTION_HISTORY_DISABLED = 0
  1:
    Result := scushoENABLED;                          /// <summary>SC_UNDO_SELECTION_HISTORY_ENABLED = 1
  2:
    Result := scushoSCROLL;                           /// <summary>SC_UNDO_SELECTION_HISTORY_SCROLL = 2
  else
    Result := scushoDISABLED;                         /// <summary>SC_UNDO_SELECTION_HISTORY_DISABLED = 0;
  end;
end;

function TDSciFoldLevelToInt(AEnum: TDSciFoldLevel): Integer;
begin
  case AEnum of
  scflBASE:                               /// <summary>SC_FOLDLEVELBASE = $400
    Result := $400;
  scflWHITE_FLAG:                         /// <summary>SC_FOLDLEVELWHITEFLAG = $1000
    Result := $1000;
  scflHEADER_FLAG:                        /// <summary>SC_FOLDLEVELHEADERFLAG = $2000
    Result := $2000;
  scflNUMBER_MASK:                        /// <summary>SC_FOLDLEVELNUMBERMASK = $0FFF
    Result := $0FFF;
  else
    Result := $400;
  end;
end;

function TDSciFoldLevelFromInt(AEnum: Integer): TDSciFoldLevel;
begin
  case AEnum of
  $400:
    Result := scflBASE;                               /// <summary>SC_FOLDLEVELBASE = $400
  $1000:
    Result := scflWHITE_FLAG;                         /// <summary>SC_FOLDLEVELWHITEFLAG = $1000
  $2000:
    Result := scflHEADER_FLAG;                        /// <summary>SC_FOLDLEVELHEADERFLAG = $2000
  $0FFF:
    Result := scflNUMBER_MASK;                        /// <summary>SC_FOLDLEVELNUMBERMASK = $0FFF
  else
    Result := scflBASE;                               /// <summary>SC_FOLDLEVELBASE = $400;
  end;
end;

function TDSciFoldLevelSetToInt(AEnum: TDSciFoldLevelSet): Integer;
var
  lEnum: TDSciFoldLevel;
begin
  Result := 0;

  for lEnum in AEnum do
    Result := Result or TDSciFoldLevelToInt(lEnum);
end;

function TDSciFoldLevelSetFromInt(AEnum: Integer): TDSciFoldLevelSet;
var
  lEnum: TDSciFoldLevel;
begin
  Result := [];

  for lEnum := Low(TDSciFoldLevel) to High(TDSciFoldLevel) do
    if AEnum and TDSciFoldLevelToInt(lEnum) <> 0 then
      Include(Result, lEnum);
end;

function TDSciFoldDisplayTextStyleToInt(AEnum: TDSciFoldDisplayTextStyle): Integer;
begin
  case AEnum of
  scfdtsHIDDEN:                           /// <summary>SC_FOLDDISPLAYTEXT_HIDDEN = 0
    Result := 0;
  scfdtsSTANDARD:                         /// <summary>SC_FOLDDISPLAYTEXT_STANDARD = 1
    Result := 1;
  scfdtsBOXED:                            /// <summary>SC_FOLDDISPLAYTEXT_BOXED = 2
    Result := 2;
  else
    Result := 0;
  end;
end;

function TDSciFoldDisplayTextStyleFromInt(AEnum: Integer): TDSciFoldDisplayTextStyle;
begin
  case AEnum of
  0:
    Result := scfdtsHIDDEN;                           /// <summary>SC_FOLDDISPLAYTEXT_HIDDEN = 0
  1:
    Result := scfdtsSTANDARD;                         /// <summary>SC_FOLDDISPLAYTEXT_STANDARD = 1
  2:
    Result := scfdtsBOXED;                            /// <summary>SC_FOLDDISPLAYTEXT_BOXED = 2
  else
    Result := scfdtsHIDDEN;                           /// <summary>SC_FOLDDISPLAYTEXT_HIDDEN = 0;
  end;
end;

function TDSciFoldActionToInt(AEnum: TDSciFoldAction): Integer;
begin
  case AEnum of
  scfaCONTRACT:                           /// <summary>SC_FOLDACTION_CONTRACT = 0
    Result := 0;
  scfaEXPAND:                             /// <summary>SC_FOLDACTION_EXPAND = 1
    Result := 1;
  scfaTOGGLE:                             /// <summary>SC_FOLDACTION_TOGGLE = 2
    Result := 2;
  scfaCONTRACT_EVERY_LEVEL:               /// <summary>SC_FOLDACTION_CONTRACT_EVERY_LEVEL = 4
    Result := 4;
  else
    Result := 0;
  end;
end;

function TDSciFoldActionFromInt(AEnum: Integer): TDSciFoldAction;
begin
  case AEnum of
  0:
    Result := scfaCONTRACT;                           /// <summary>SC_FOLDACTION_CONTRACT = 0
  1:
    Result := scfaEXPAND;                             /// <summary>SC_FOLDACTION_EXPAND = 1
  2:
    Result := scfaTOGGLE;                             /// <summary>SC_FOLDACTION_TOGGLE = 2
  4:
    Result := scfaCONTRACT_EVERY_LEVEL;               /// <summary>SC_FOLDACTION_CONTRACT_EVERY_LEVEL = 4
  else
    Result := scfaCONTRACT;                           /// <summary>SC_FOLDACTION_CONTRACT = 0;
  end;
end;

function TDSciAutomaticFoldToInt(AEnum: TDSciAutomaticFold): Integer;
begin
  case AEnum of
  scafNONE:                               /// <summary>SC_AUTOMATICFOLD_NONE = $0000
    Result := $0000;
  scafSHOW:                               /// <summary>SC_AUTOMATICFOLD_SHOW = $0001
    Result := $0001;
  scafCLICK:                              /// <summary>SC_AUTOMATICFOLD_CLICK = $0002
    Result := $0002;
  scafCHANGE:                             /// <summary>SC_AUTOMATICFOLD_CHANGE = $0004
    Result := $0004;
  else
    Result := $0000;
  end;
end;

function TDSciAutomaticFoldFromInt(AEnum: Integer): TDSciAutomaticFold;
begin
  case AEnum of
  $0000:
    Result := scafNONE;                               /// <summary>SC_AUTOMATICFOLD_NONE = $0000
  $0001:
    Result := scafSHOW;                               /// <summary>SC_AUTOMATICFOLD_SHOW = $0001
  $0002:
    Result := scafCLICK;                              /// <summary>SC_AUTOMATICFOLD_CLICK = $0002
  $0004:
    Result := scafCHANGE;                             /// <summary>SC_AUTOMATICFOLD_CHANGE = $0004
  else
    Result := scafNONE;                               /// <summary>SC_AUTOMATICFOLD_NONE = $0000;
  end;
end;

function TDSciFoldFlagToInt(AEnum: TDSciFoldFlag): Integer;
begin
  case AEnum of
  scffLINE_BEFORE_EXPANDED:               /// <summary>SC_FOLDFLAG_LINEBEFORE_EXPANDED = $0002
    Result := $0002;
  scffLINE_BEFORE_CONTRACTED:             /// <summary>SC_FOLDFLAG_LINEBEFORE_CONTRACTED = $0004
    Result := $0004;
  scffLINE_AFTER_EXPANDED:                /// <summary>SC_FOLDFLAG_LINEAFTER_EXPANDED = $0008
    Result := $0008;
  scffLINE_AFTER_CONTRACTED:              /// <summary>SC_FOLDFLAG_LINEAFTER_CONTRACTED = $0010
    Result := $0010;
  scffLEVEL_NUMBERS:                      /// <summary>SC_FOLDFLAG_LEVELNUMBERS = $0040
    Result := $0040;
  scffLINE_STATE:                         /// <summary>SC_FOLDFLAG_LINESTATE = $0080
    Result := $0080;
  else
    Result := $0002;
  end;
end;

function TDSciFoldFlagFromInt(AEnum: Integer): TDSciFoldFlag;
begin
  case AEnum of
  $0002:
    Result := scffLINE_BEFORE_EXPANDED;               /// <summary>SC_FOLDFLAG_LINEBEFORE_EXPANDED = $0002
  $0004:
    Result := scffLINE_BEFORE_CONTRACTED;             /// <summary>SC_FOLDFLAG_LINEBEFORE_CONTRACTED = $0004
  $0008:
    Result := scffLINE_AFTER_EXPANDED;                /// <summary>SC_FOLDFLAG_LINEAFTER_EXPANDED = $0008
  $0010:
    Result := scffLINE_AFTER_CONTRACTED;              /// <summary>SC_FOLDFLAG_LINEAFTER_CONTRACTED = $0010
  $0040:
    Result := scffLEVEL_NUMBERS;                      /// <summary>SC_FOLDFLAG_LEVELNUMBERS = $0040
  $0080:
    Result := scffLINE_STATE;                         /// <summary>SC_FOLDFLAG_LINESTATE = $0080
  else
    Result := scffLINE_BEFORE_EXPANDED;               /// <summary>SC_FOLDFLAG_LINEBEFORE_EXPANDED = $0002;
  end;
end;

function TDSciFoldFlagSetToInt(AEnum: TDSciFoldFlagSet): Integer;
var
  lEnum: TDSciFoldFlag;
begin
  Result := 0;

  for lEnum in AEnum do
    Result := Result or TDSciFoldFlagToInt(lEnum);
end;

function TDSciFoldFlagSetFromInt(AEnum: Integer): TDSciFoldFlagSet;
var
  lEnum: TDSciFoldFlag;
begin
  Result := [];

  for lEnum := Low(TDSciFoldFlag) to High(TDSciFoldFlag) do
    if AEnum and TDSciFoldFlagToInt(lEnum) <> 0 then
      Include(Result, lEnum);
end;

function TDSciIdleStylingToInt(AEnum: TDSciIdleStyling): Integer;
begin
  case AEnum of
  scisNONE:                               /// <summary>SC_IDLESTYLING_NONE = 0
    Result := 0;
  scisTO_VISIBLE:                         /// <summary>SC_IDLESTYLING_TOVISIBLE = 1
    Result := 1;
  scisAFTER_VISIBLE:                      /// <summary>SC_IDLESTYLING_AFTERVISIBLE = 2
    Result := 2;
  scisALL:                                /// <summary>SC_IDLESTYLING_ALL = 3
    Result := 3;
  else
    Result := 0;
  end;
end;

function TDSciIdleStylingFromInt(AEnum: Integer): TDSciIdleStyling;
begin
  case AEnum of
  0:
    Result := scisNONE;                               /// <summary>SC_IDLESTYLING_NONE = 0
  1:
    Result := scisTO_VISIBLE;                         /// <summary>SC_IDLESTYLING_TOVISIBLE = 1
  2:
    Result := scisAFTER_VISIBLE;                      /// <summary>SC_IDLESTYLING_AFTERVISIBLE = 2
  3:
    Result := scisALL;                                /// <summary>SC_IDLESTYLING_ALL = 3
  else
    Result := scisNONE;                               /// <summary>SC_IDLESTYLING_NONE = 0;
  end;
end;

function TDSciWrapToInt(AEnum: TDSciWrap): Integer;
begin
  case AEnum of
  scwNONE:                                /// <summary>SC_WRAP_NONE = 0
    Result := 0;
  scwWORD:                                /// <summary>SC_WRAP_WORD = 1
    Result := 1;
  scwCHAR:                                /// <summary>SC_WRAP_CHAR = 2
    Result := 2;
  scwWHITE_SPACE:                         /// <summary>SC_WRAP_WHITESPACE = 3
    Result := 3;
  else
    Result := 0;
  end;
end;

function TDSciWrapFromInt(AEnum: Integer): TDSciWrap;
begin
  case AEnum of
  0:
    Result := scwNONE;                                /// <summary>SC_WRAP_NONE = 0
  1:
    Result := scwWORD;                                /// <summary>SC_WRAP_WORD = 1
  2:
    Result := scwCHAR;                                /// <summary>SC_WRAP_CHAR = 2
  3:
    Result := scwWHITE_SPACE;                         /// <summary>SC_WRAP_WHITESPACE = 3
  else
    Result := scwNONE;                                /// <summary>SC_WRAP_NONE = 0;
  end;
end;

function TDSciWrapVisualFlagToInt(AEnum: TDSciWrapVisualFlag): Integer;
begin
  case AEnum of
  scwvfEND:                               /// <summary>SC_WRAPVISUALFLAG_END = $0001
    Result := $0001;
  scwvfSTART:                             /// <summary>SC_WRAPVISUALFLAG_START = $0002
    Result := $0002;
  scwvfMARGIN:                            /// <summary>SC_WRAPVISUALFLAG_MARGIN = $0004
    Result := $0004;
  else
    Result := $0001;
  end;
end;

function TDSciWrapVisualFlagFromInt(AEnum: Integer): TDSciWrapVisualFlag;
begin
  case AEnum of
  $0001:
    Result := scwvfEND;                               /// <summary>SC_WRAPVISUALFLAG_END = $0001
  $0002:
    Result := scwvfSTART;                             /// <summary>SC_WRAPVISUALFLAG_START = $0002
  $0004:
    Result := scwvfMARGIN;                            /// <summary>SC_WRAPVISUALFLAG_MARGIN = $0004
  else
    Result := scwvfEND;                               /// <summary>SC_WRAPVISUALFLAG_END = $0001;
  end;
end;

function TDSciWrapVisualFlagSetToInt(AEnum: TDSciWrapVisualFlagSet): Integer;
var
  lEnum: TDSciWrapVisualFlag;
begin
  Result := 0;

  for lEnum in AEnum do
    Result := Result or TDSciWrapVisualFlagToInt(lEnum);
end;

function TDSciWrapVisualFlagSetFromInt(AEnum: Integer): TDSciWrapVisualFlagSet;
var
  lEnum: TDSciWrapVisualFlag;
begin
  Result := [];

  for lEnum := Low(TDSciWrapVisualFlag) to High(TDSciWrapVisualFlag) do
    if AEnum and TDSciWrapVisualFlagToInt(lEnum) <> 0 then
      Include(Result, lEnum);
end;

function TDSciWrapVisualLocationToInt(AEnum: TDSciWrapVisualLocation): Integer;
begin
  case AEnum of
  scwvlEND_BY_TEXT:                       /// <summary>SC_WRAPVISUALFLAGLOC_END_BY_TEXT = $0001
    Result := $0001;
  scwvlSTART_BY_TEXT:                     /// <summary>SC_WRAPVISUALFLAGLOC_START_BY_TEXT = $0002
    Result := $0002;
  else
    Result := $0001;
  end;
end;

function TDSciWrapVisualLocationFromInt(AEnum: Integer): TDSciWrapVisualLocation;
begin
  case AEnum of
  $0001:
    Result := scwvlEND_BY_TEXT;                       /// <summary>SC_WRAPVISUALFLAGLOC_END_BY_TEXT = $0001
  $0002:
    Result := scwvlSTART_BY_TEXT;                     /// <summary>SC_WRAPVISUALFLAGLOC_START_BY_TEXT = $0002
  else
    Result := scwvlEND_BY_TEXT;                       /// <summary>SC_WRAPVISUALFLAGLOC_END_BY_TEXT = $0001;
  end;
end;

function TDSciWrapVisualLocationSetToInt(AEnum: TDSciWrapVisualLocationSet): Integer;
var
  lEnum: TDSciWrapVisualLocation;
begin
  Result := 0;

  for lEnum in AEnum do
    Result := Result or TDSciWrapVisualLocationToInt(lEnum);
end;

function TDSciWrapVisualLocationSetFromInt(AEnum: Integer): TDSciWrapVisualLocationSet;
var
  lEnum: TDSciWrapVisualLocation;
begin
  Result := [];

  for lEnum := Low(TDSciWrapVisualLocation) to High(TDSciWrapVisualLocation) do
    if AEnum and TDSciWrapVisualLocationToInt(lEnum) <> 0 then
      Include(Result, lEnum);
end;

function TDSciWrapIndentModeToInt(AEnum: TDSciWrapIndentMode): Integer;
begin
  case AEnum of
  scwimFIXED:                             /// <summary>SC_WRAPINDENT_FIXED = 0
    Result := 0;
  scwimSAME:                              /// <summary>SC_WRAPINDENT_SAME = 1
    Result := 1;
  scwimINDENT:                            /// <summary>SC_WRAPINDENT_INDENT = 2
    Result := 2;
  scwimDEEP_INDENT:                       /// <summary>SC_WRAPINDENT_DEEPINDENT = 3
    Result := 3;
  else
    Result := 0;
  end;
end;

function TDSciWrapIndentModeFromInt(AEnum: Integer): TDSciWrapIndentMode;
begin
  case AEnum of
  0:
    Result := scwimFIXED;                             /// <summary>SC_WRAPINDENT_FIXED = 0
  1:
    Result := scwimSAME;                              /// <summary>SC_WRAPINDENT_SAME = 1
  2:
    Result := scwimINDENT;                            /// <summary>SC_WRAPINDENT_INDENT = 2
  3:
    Result := scwimDEEP_INDENT;                       /// <summary>SC_WRAPINDENT_DEEPINDENT = 3
  else
    Result := scwimFIXED;                             /// <summary>SC_WRAPINDENT_FIXED = 0;
  end;
end;

function TDSciLineCacheToInt(AEnum: TDSciLineCache): Integer;
begin
  case AEnum of
  sclcNONE:                               /// <summary>SC_CACHE_NONE = 0
    Result := 0;
  sclcCARET:                              /// <summary>SC_CACHE_CARET = 1
    Result := 1;
  sclcPAGE:                               /// <summary>SC_CACHE_PAGE = 2
    Result := 2;
  sclcDOCUMENT:                           /// <summary>SC_CACHE_DOCUMENT = 3
    Result := 3;
  else
    Result := 0;
  end;
end;

function TDSciLineCacheFromInt(AEnum: Integer): TDSciLineCache;
begin
  case AEnum of
  0:
    Result := sclcNONE;                               /// <summary>SC_CACHE_NONE = 0
  1:
    Result := sclcCARET;                              /// <summary>SC_CACHE_CARET = 1
  2:
    Result := sclcPAGE;                               /// <summary>SC_CACHE_PAGE = 2
  3:
    Result := sclcDOCUMENT;                           /// <summary>SC_CACHE_DOCUMENT = 3
  else
    Result := sclcNONE;                               /// <summary>SC_CACHE_NONE = 0;
  end;
end;

function TDSciPhasesDrawToInt(AEnum: TDSciPhasesDraw): Integer;
begin
  case AEnum of
  scpdONE:                                /// <summary>SC_PHASES_ONE = 0
    Result := 0;
  scpdTWO:                                /// <summary>SC_PHASES_TWO = 1
    Result := 1;
  scpdMULTIPLE:                           /// <summary>SC_PHASES_MULTIPLE = 2
    Result := 2;
  else
    Result := 0;
  end;
end;

function TDSciPhasesDrawFromInt(AEnum: Integer): TDSciPhasesDraw;
begin
  case AEnum of
  0:
    Result := scpdONE;                                /// <summary>SC_PHASES_ONE = 0
  1:
    Result := scpdTWO;                                /// <summary>SC_PHASES_TWO = 1
  2:
    Result := scpdMULTIPLE;                           /// <summary>SC_PHASES_MULTIPLE = 2
  else
    Result := scpdONE;                                /// <summary>SC_PHASES_ONE = 0;
  end;
end;

function TDSciFontQualityToInt(AEnum: TDSciFontQuality): Integer;
begin
  case AEnum of
  scfqQUALITY_MASK:                       /// <summary>SC_EFF_QUALITY_MASK = $F
    Result := $F;
  scfqQUALITY_DEFAULT:                    /// <summary>SC_EFF_QUALITY_DEFAULT = 0
    Result := 0;
  scfqQUALITY_NON_ANTIALIASED:            /// <summary>SC_EFF_QUALITY_NON_ANTIALIASED = 1
    Result := 1;
  scfqQUALITY_ANTIALIASED:                /// <summary>SC_EFF_QUALITY_ANTIALIASED = 2
    Result := 2;
  scfqQUALITY_LCD_OPTIMIZED:              /// <summary>SC_EFF_QUALITY_LCD_OPTIMIZED = 3
    Result := 3;
  else
    Result := $F;
  end;
end;

function TDSciFontQualityFromInt(AEnum: Integer): TDSciFontQuality;
begin
  case AEnum of
  $F:
    Result := scfqQUALITY_MASK;                       /// <summary>SC_EFF_QUALITY_MASK = $F
  0:
    Result := scfqQUALITY_DEFAULT;                    /// <summary>SC_EFF_QUALITY_DEFAULT = 0
  1:
    Result := scfqQUALITY_NON_ANTIALIASED;            /// <summary>SC_EFF_QUALITY_NON_ANTIALIASED = 1
  2:
    Result := scfqQUALITY_ANTIALIASED;                /// <summary>SC_EFF_QUALITY_ANTIALIASED = 2
  3:
    Result := scfqQUALITY_LCD_OPTIMIZED;              /// <summary>SC_EFF_QUALITY_LCD_OPTIMIZED = 3
  else
    Result := scfqQUALITY_MASK;                       /// <summary>SC_EFF_QUALITY_MASK = $F;
  end;
end;

function TDSciMultiPasteToInt(AEnum: TDSciMultiPaste): Integer;
begin
  case AEnum of
  scmpONCE:                               /// <summary>SC_MULTIPASTE_ONCE = 0
    Result := 0;
  scmpEACH:                               /// <summary>SC_MULTIPASTE_EACH = 1
    Result := 1;
  else
    Result := 0;
  end;
end;

function TDSciMultiPasteFromInt(AEnum: Integer): TDSciMultiPaste;
begin
  case AEnum of
  0:
    Result := scmpONCE;                               /// <summary>SC_MULTIPASTE_ONCE = 0
  1:
    Result := scmpEACH;                               /// <summary>SC_MULTIPASTE_EACH = 1
  else
    Result := scmpONCE;                               /// <summary>SC_MULTIPASTE_ONCE = 0;
  end;
end;

function TDSciAccessibilityToInt(AEnum: TDSciAccessibility): Integer;
begin
  case AEnum of
  scaDISABLED:                            /// <summary>SC_ACCESSIBILITY_DISABLED = 0
    Result := 0;
  scaENABLED:                             /// <summary>SC_ACCESSIBILITY_ENABLED = 1
    Result := 1;
  else
    Result := 0;
  end;
end;

function TDSciAccessibilityFromInt(AEnum: Integer): TDSciAccessibility;
begin
  case AEnum of
  0:
    Result := scaDISABLED;                            /// <summary>SC_ACCESSIBILITY_DISABLED = 0
  1:
    Result := scaENABLED;                             /// <summary>SC_ACCESSIBILITY_ENABLED = 1
  else
    Result := scaDISABLED;                            /// <summary>SC_ACCESSIBILITY_DISABLED = 0;
  end;
end;

function TDSciEdgeVisualStyleToInt(AEnum: TDSciEdgeVisualStyle): Integer;
begin
  case AEnum of
  scevsNONE:                              /// <summary>EDGE_NONE = 0
    Result := 0;
  scevsLINE:                              /// <summary>EDGE_LINE = 1
    Result := 1;
  scevsBACKGROUND:                        /// <summary>EDGE_BACKGROUND = 2
    Result := 2;
  scevsMULTI_LINE:                        /// <summary>EDGE_MULTILINE = 3
    Result := 3;
  else
    Result := 0;
  end;
end;

function TDSciEdgeVisualStyleFromInt(AEnum: Integer): TDSciEdgeVisualStyle;
begin
  case AEnum of
  0:
    Result := scevsNONE;                              /// <summary>EDGE_NONE = 0
  1:
    Result := scevsLINE;                              /// <summary>EDGE_LINE = 1
  2:
    Result := scevsBACKGROUND;                        /// <summary>EDGE_BACKGROUND = 2
  3:
    Result := scevsMULTI_LINE;                        /// <summary>EDGE_MULTILINE = 3
  else
    Result := scevsNONE;                              /// <summary>EDGE_NONE = 0;
  end;
end;

function TDSciPopUpToInt(AEnum: TDSciPopUp): Integer;
begin
  case AEnum of
  scpuNEVER:                              /// <summary>SC_POPUP_NEVER = 0
    Result := 0;
  scpuALL:                                /// <summary>SC_POPUP_ALL = 1
    Result := 1;
  scpuTEXT:                               /// <summary>SC_POPUP_TEXT = 2
    Result := 2;
  else
    Result := 0;
  end;
end;

function TDSciPopUpFromInt(AEnum: Integer): TDSciPopUp;
begin
  case AEnum of
  0:
    Result := scpuNEVER;                              /// <summary>SC_POPUP_NEVER = 0
  1:
    Result := scpuALL;                                /// <summary>SC_POPUP_ALL = 1
  2:
    Result := scpuTEXT;                               /// <summary>SC_POPUP_TEXT = 2
  else
    Result := scpuNEVER;                              /// <summary>SC_POPUP_NEVER = 0;
  end;
end;

function TDSciDocumentOptionToInt(AEnum: TDSciDocumentOption): Integer;
begin
  case AEnum of
  scdoDEFAULT:                            /// <summary>SC_DOCUMENTOPTION_DEFAULT = 0
    Result := 0;
  scdoSTYLES_NONE:                        /// <summary>SC_DOCUMENTOPTION_STYLES_NONE = $1
    Result := $1;
  scdoTEXT_LARGE:                         /// <summary>SC_DOCUMENTOPTION_TEXT_LARGE = $100
    Result := $100;
  else
    Result := 0;
  end;
end;

function TDSciDocumentOptionFromInt(AEnum: Integer): TDSciDocumentOption;
begin
  case AEnum of
  0:
    Result := scdoDEFAULT;                            /// <summary>SC_DOCUMENTOPTION_DEFAULT = 0
  $1:
    Result := scdoSTYLES_NONE;                        /// <summary>SC_DOCUMENTOPTION_STYLES_NONE = $1
  $100:
    Result := scdoTEXT_LARGE;                         /// <summary>SC_DOCUMENTOPTION_TEXT_LARGE = $100
  else
    Result := scdoDEFAULT;                            /// <summary>SC_DOCUMENTOPTION_DEFAULT = 0;
  end;
end;

function TDSciStatusToInt(AEnum: TDSciStatus): Integer;
begin
  case AEnum of
  scsOK:                                  /// <summary>SC_STATUS_OK = 0
    Result := 0;
  scsFAILURE:                             /// <summary>SC_STATUS_FAILURE = 1
    Result := 1;
  scsBAD_ALLOC:                           /// <summary>SC_STATUS_BADALLOC = 2
    Result := 2;
  scsWARN_START:                          /// <summary>SC_STATUS_WARN_START = 1000
    Result := 1000;
  scsREG_EX:                              /// <summary>SC_STATUS_WARN_REGEX = 1001
    Result := 1001;
  else
    Result := 0;
  end;
end;

function TDSciStatusFromInt(AEnum: Integer): TDSciStatus;
begin
  case AEnum of
  0:
    Result := scsOK;                                  /// <summary>SC_STATUS_OK = 0
  1:
    Result := scsFAILURE;                             /// <summary>SC_STATUS_FAILURE = 1
  2:
    Result := scsBAD_ALLOC;                           /// <summary>SC_STATUS_BADALLOC = 2
  1000:
    Result := scsWARN_START;                          /// <summary>SC_STATUS_WARN_START = 1000
  1001:
    Result := scsREG_EX;                              /// <summary>SC_STATUS_WARN_REGEX = 1001
  else
    Result := scsOK;                                  /// <summary>SC_STATUS_OK = 0;
  end;
end;

function TDSciVisiblePolicyToInt(AEnum: TDSciVisiblePolicy): Integer;
begin
  case AEnum of
  scvpSLOP:                               /// <summary>VISIBLE_SLOP = $01
    Result := $01;
  scvpSTRICT:                             /// <summary>VISIBLE_STRICT = $04
    Result := $04;
  else
    Result := $01;
  end;
end;

function TDSciVisiblePolicyFromInt(AEnum: Integer): TDSciVisiblePolicy;
begin
  case AEnum of
  $01:
    Result := scvpSLOP;                               /// <summary>VISIBLE_SLOP = $01
  $04:
    Result := scvpSTRICT;                             /// <summary>VISIBLE_STRICT = $04
  else
    Result := scvpSLOP;                               /// <summary>VISIBLE_SLOP = $01;
  end;
end;

function TDSciVisiblePolicySetToInt(AEnum: TDSciVisiblePolicySet): Integer;
var
  lEnum: TDSciVisiblePolicy;
begin
  Result := 0;

  for lEnum in AEnum do
    Result := Result or TDSciVisiblePolicyToInt(lEnum);
end;

function TDSciVisiblePolicySetFromInt(AEnum: Integer): TDSciVisiblePolicySet;
var
  lEnum: TDSciVisiblePolicy;
begin
  Result := [];

  for lEnum := Low(TDSciVisiblePolicy) to High(TDSciVisiblePolicy) do
    if AEnum and TDSciVisiblePolicyToInt(lEnum) <> 0 then
      Include(Result, lEnum);
end;

function TDSciCaretPolicyToInt(AEnum: TDSciCaretPolicy): Integer;
begin
  case AEnum of
  sccpSLOP:                               /// <summary>CARET_SLOP = $01
    Result := $01;
  sccpSTRICT:                             /// <summary>CARET_STRICT = $04
    Result := $04;
  sccpJUMPS:                              /// <summary>CARET_JUMPS = $10
    Result := $10;
  sccpEVEN:                               /// <summary>CARET_EVEN = $08
    Result := $08;
  else
    Result := $01;
  end;
end;

function TDSciCaretPolicyFromInt(AEnum: Integer): TDSciCaretPolicy;
begin
  case AEnum of
  $01:
    Result := sccpSLOP;                               /// <summary>CARET_SLOP = $01
  $04:
    Result := sccpSTRICT;                             /// <summary>CARET_STRICT = $04
  $10:
    Result := sccpJUMPS;                              /// <summary>CARET_JUMPS = $10
  $08:
    Result := sccpEVEN;                               /// <summary>CARET_EVEN = $08
  else
    Result := sccpSLOP;                               /// <summary>CARET_SLOP = $01;
  end;
end;

function TDSciCaretPolicySetToInt(AEnum: TDSciCaretPolicySet): Integer;
var
  lEnum: TDSciCaretPolicy;
begin
  Result := 0;

  for lEnum in AEnum do
    Result := Result or TDSciCaretPolicyToInt(lEnum);
end;

function TDSciCaretPolicySetFromInt(AEnum: Integer): TDSciCaretPolicySet;
var
  lEnum: TDSciCaretPolicy;
begin
  Result := [];

  for lEnum := Low(TDSciCaretPolicy) to High(TDSciCaretPolicy) do
    if AEnum and TDSciCaretPolicyToInt(lEnum) <> 0 then
      Include(Result, lEnum);
end;

function TDSciSelectionModeToInt(AEnum: TDSciSelectionMode): Integer;
begin
  case AEnum of
  scsmSTREAM:                             /// <summary>SC_SEL_STREAM = 0
    Result := 0;
  scsmRECTANGLE:                          /// <summary>SC_SEL_RECTANGLE = 1
    Result := 1;
  scsmLINES:                              /// <summary>SC_SEL_LINES = 2
    Result := 2;
  scsmTHIN:                               /// <summary>SC_SEL_THIN = 3
    Result := 3;
  else
    Result := 0;
  end;
end;

function TDSciSelectionModeFromInt(AEnum: Integer): TDSciSelectionMode;
begin
  case AEnum of
  0:
    Result := scsmSTREAM;                             /// <summary>SC_SEL_STREAM = 0
  1:
    Result := scsmRECTANGLE;                          /// <summary>SC_SEL_RECTANGLE = 1
  2:
    Result := scsmLINES;                              /// <summary>SC_SEL_LINES = 2
  3:
    Result := scsmTHIN;                               /// <summary>SC_SEL_THIN = 3
  else
    Result := scsmSTREAM;                             /// <summary>SC_SEL_STREAM = 0;
  end;
end;

function TDSciCaseInsensitiveBehaviourToInt(AEnum: TDSciCaseInsensitiveBehaviour): Integer;
begin
  case AEnum of
  sccibRESPECT_CASE:                      /// <summary>SC_CASEINSENSITIVEBEHAVIOUR_RESPECTCASE = 0
    Result := 0;
  sccibIGNORE_CASE:                       /// <summary>SC_CASEINSENSITIVEBEHAVIOUR_IGNORECASE = 1
    Result := 1;
  else
    Result := 0;
  end;
end;

function TDSciCaseInsensitiveBehaviourFromInt(AEnum: Integer): TDSciCaseInsensitiveBehaviour;
begin
  case AEnum of
  0:
    Result := sccibRESPECT_CASE;                      /// <summary>SC_CASEINSENSITIVEBEHAVIOUR_RESPECTCASE = 0
  1:
    Result := sccibIGNORE_CASE;                       /// <summary>SC_CASEINSENSITIVEBEHAVIOUR_IGNORECASE = 1
  else
    Result := sccibRESPECT_CASE;                      /// <summary>SC_CASEINSENSITIVEBEHAVIOUR_RESPECTCASE = 0;
  end;
end;

function TDSciMultiAutoCompleteToInt(AEnum: TDSciMultiAutoComplete): Integer;
begin
  case AEnum of
  scmacONCE:                              /// <summary>SC_MULTIAUTOC_ONCE = 0
    Result := 0;
  scmacEACH:                              /// <summary>SC_MULTIAUTOC_EACH = 1
    Result := 1;
  else
    Result := 0;
  end;
end;

function TDSciMultiAutoCompleteFromInt(AEnum: Integer): TDSciMultiAutoComplete;
begin
  case AEnum of
  0:
    Result := scmacONCE;                              /// <summary>SC_MULTIAUTOC_ONCE = 0
  1:
    Result := scmacEACH;                              /// <summary>SC_MULTIAUTOC_EACH = 1
  else
    Result := scmacONCE;                              /// <summary>SC_MULTIAUTOC_ONCE = 0;
  end;
end;

function TDSciOrderingToInt(AEnum: TDSciOrdering): Integer;
begin
  case AEnum of
  scoPRE_SORTED:                          /// <summary>SC_ORDER_PRESORTED = 0
    Result := 0;
  scoPERFORM_SORT:                        /// <summary>SC_ORDER_PERFORMSORT = 1
    Result := 1;
  scoCUSTOM:                              /// <summary>SC_ORDER_CUSTOM = 2
    Result := 2;
  else
    Result := 0;
  end;
end;

function TDSciOrderingFromInt(AEnum: Integer): TDSciOrdering;
begin
  case AEnum of
  0:
    Result := scoPRE_SORTED;                          /// <summary>SC_ORDER_PRESORTED = 0
  1:
    Result := scoPERFORM_SORT;                        /// <summary>SC_ORDER_PERFORMSORT = 1
  2:
    Result := scoCUSTOM;                              /// <summary>SC_ORDER_CUSTOM = 2
  else
    Result := scoPRE_SORTED;                          /// <summary>SC_ORDER_PRESORTED = 0;
  end;
end;

function TDSciCaretStickyToInt(AEnum: TDSciCaretSticky): Integer;
begin
  case AEnum of
  sccsOFF:                                /// <summary>SC_CARETSTICKY_OFF = 0
    Result := 0;
  sccsON:                                 /// <summary>SC_CARETSTICKY_ON = 1
    Result := 1;
  sccsWHITE_SPACE:                        /// <summary>SC_CARETSTICKY_WHITESPACE = 2
    Result := 2;
  else
    Result := 0;
  end;
end;

function TDSciCaretStickyFromInt(AEnum: Integer): TDSciCaretSticky;
begin
  case AEnum of
  0:
    Result := sccsOFF;                                /// <summary>SC_CARETSTICKY_OFF = 0
  1:
    Result := sccsON;                                 /// <summary>SC_CARETSTICKY_ON = 1
  2:
    Result := sccsWHITE_SPACE;                        /// <summary>SC_CARETSTICKY_WHITESPACE = 2
  else
    Result := sccsOFF;                                /// <summary>SC_CARETSTICKY_OFF = 0;
  end;
end;

function TDSciCaretStyleToInt(AEnum: TDSciCaretStyle): Integer;
begin
  case AEnum of
  sccsINVISIBLE:                          /// <summary>CARETSTYLE_INVISIBLE = 0
    Result := 0;
  sccsLINE:                               /// <summary>CARETSTYLE_LINE = 1
    Result := 1;
  sccsBLOCK:                              /// <summary>CARETSTYLE_BLOCK = 2
    Result := 2;
  sccsOVERSTRIKE_BAR:                     /// <summary>CARETSTYLE_OVERSTRIKE_BAR = 0
    Result := 0;
  sccsOVERSTRIKE_BLOCK:                   /// <summary>CARETSTYLE_OVERSTRIKE_BLOCK = $10
    Result := $10;
  sccsCURSES:                             /// <summary>CARETSTYLE_CURSES = $20
    Result := $20;
  sccsINS_MASK:                           /// <summary>CARETSTYLE_INS_MASK = $F
    Result := $F;
  sccsBLOCK_AFTER:                        /// <summary>CARETSTYLE_BLOCK_AFTER = $100
    Result := $100;
  else
    Result := 0;
  end;
end;

function TDSciCaretStyleFromInt(AEnum: Integer): TDSciCaretStyle;
begin
  case AEnum of
  0:
    Result := sccsINVISIBLE;                          /// <summary>CARETSTYLE_INVISIBLE = 0
  1:
    Result := sccsLINE;                               /// <summary>CARETSTYLE_LINE = 1
  2:
    Result := sccsBLOCK;                              /// <summary>CARETSTYLE_BLOCK = 2
  $10:
    Result := sccsOVERSTRIKE_BLOCK;                   /// <summary>CARETSTYLE_OVERSTRIKE_BLOCK = $10
  $20:
    Result := sccsCURSES;                             /// <summary>CARETSTYLE_CURSES = $20
  $F:
    Result := sccsINS_MASK;                           /// <summary>CARETSTYLE_INS_MASK = $F
  $100:
    Result := sccsBLOCK_AFTER;                        /// <summary>CARETSTYLE_BLOCK_AFTER = $100
  else
    Result := sccsINVISIBLE;                          /// <summary>CARETSTYLE_INVISIBLE = 0;
  end;
end;

function TDSciMarginOptionToInt(AEnum: TDSciMarginOption): Integer;
begin
  case AEnum of
  scmoNONE:                               /// <summary>SC_MARGINOPTION_NONE = 0
    Result := 0;
  scmoSUB_LINE_SELECT:                    /// <summary>SC_MARGINOPTION_SUBLINESELECT = 1
    Result := 1;
  else
    Result := 0;
  end;
end;

function TDSciMarginOptionFromInt(AEnum: Integer): TDSciMarginOption;
begin
  case AEnum of
  0:
    Result := scmoNONE;                               /// <summary>SC_MARGINOPTION_NONE = 0
  1:
    Result := scmoSUB_LINE_SELECT;                    /// <summary>SC_MARGINOPTION_SUBLINESELECT = 1
  else
    Result := scmoNONE;                               /// <summary>SC_MARGINOPTION_NONE = 0;
  end;
end;

function TDSciAnnotationVisibleToInt(AEnum: TDSciAnnotationVisible): Integer;
begin
  case AEnum of
  scavHIDDEN:                             /// <summary>ANNOTATION_HIDDEN = 0
    Result := 0;
  scavSTANDARD:                           /// <summary>ANNOTATION_STANDARD = 1
    Result := 1;
  scavBOXED:                              /// <summary>ANNOTATION_BOXED = 2
    Result := 2;
  scavINDENTED:                           /// <summary>ANNOTATION_INDENTED = 3
    Result := 3;
  else
    Result := 0;
  end;
end;

function TDSciAnnotationVisibleFromInt(AEnum: Integer): TDSciAnnotationVisible;
begin
  case AEnum of
  0:
    Result := scavHIDDEN;                             /// <summary>ANNOTATION_HIDDEN = 0
  1:
    Result := scavSTANDARD;                           /// <summary>ANNOTATION_STANDARD = 1
  2:
    Result := scavBOXED;                              /// <summary>ANNOTATION_BOXED = 2
  3:
    Result := scavINDENTED;                           /// <summary>ANNOTATION_INDENTED = 3
  else
    Result := scavHIDDEN;                             /// <summary>ANNOTATION_HIDDEN = 0;
  end;
end;

function TDSciUndoFlagsToInt(AEnum: TDSciUndoFlags): Integer;
begin
  case AEnum of
  scufMAY_COALESCE:                       /// <summary>UNDO_MAY_COALESCE = 1
    Result := 1;
  else
    Result := 1;
  end;
end;

function TDSciUndoFlagsFromInt(AEnum: Integer): TDSciUndoFlags;
begin
  case AEnum of
  1:
    Result := scufMAY_COALESCE;                       /// <summary>UNDO_MAY_COALESCE = 1
  else
    Result := scufMAY_COALESCE;                       /// <summary>UNDO_MAY_COALESCE = 1;
  end;
end;

function TDSciUndoFlagsSetToInt(AEnum: TDSciUndoFlagsSet): Integer;
var
  lEnum: TDSciUndoFlags;
begin
  Result := 0;

  for lEnum in AEnum do
    Result := Result or TDSciUndoFlagsToInt(lEnum);
end;

function TDSciUndoFlagsSetFromInt(AEnum: Integer): TDSciUndoFlagsSet;
var
  lEnum: TDSciUndoFlags;
begin
  Result := [];

  for lEnum := Low(TDSciUndoFlags) to High(TDSciUndoFlags) do
    if AEnum and TDSciUndoFlagsToInt(lEnum) <> 0 then
      Include(Result, lEnum);
end;

function TDSciVirtualSpaceToInt(AEnum: TDSciVirtualSpace): Integer;
begin
  case AEnum of
  scvsRECTANGULAR_SELECTION:              /// <summary>SCVS_RECTANGULARSELECTION = 1
    Result := 1;
  scvsUSER_ACCESSIBLE:                    /// <summary>SCVS_USERACCESSIBLE = 2
    Result := 2;
  scvsNO_WRAP_LINE_START:                 /// <summary>SCVS_NOWRAPLINESTART = 4
    Result := 4;
  else
    Result := 1;
  end;
end;

function TDSciVirtualSpaceFromInt(AEnum: Integer): TDSciVirtualSpace;
begin
  case AEnum of
  1:
    Result := scvsRECTANGULAR_SELECTION;              /// <summary>SCVS_RECTANGULARSELECTION = 1
  2:
    Result := scvsUSER_ACCESSIBLE;                    /// <summary>SCVS_USERACCESSIBLE = 2
  4:
    Result := scvsNO_WRAP_LINE_START;                 /// <summary>SCVS_NOWRAPLINESTART = 4
  else
    Result := scvsRECTANGULAR_SELECTION;              /// <summary>SCVS_RECTANGULARSELECTION = 1;
  end;
end;

function TDSciVirtualSpaceSetToInt(AEnum: TDSciVirtualSpaceSet): Integer;
var
  lEnum: TDSciVirtualSpace;
begin
  Result := 0;

  for lEnum in AEnum do
    Result := Result or TDSciVirtualSpaceToInt(lEnum);
end;

function TDSciVirtualSpaceSetFromInt(AEnum: Integer): TDSciVirtualSpaceSet;
var
  lEnum: TDSciVirtualSpace;
begin
  Result := [];

  for lEnum := Low(TDSciVirtualSpace) to High(TDSciVirtualSpace) do
    if AEnum and TDSciVirtualSpaceToInt(lEnum) <> 0 then
      Include(Result, lEnum);
end;

function TDSciTechnologyToInt(AEnum: TDSciTechnology): Integer;
begin
  case AEnum of
  sctDEFAULT:                             /// <summary>SC_TECHNOLOGY_DEFAULT = 0
    Result := 0;
  sctDIRECT_WRITE:                        /// <summary>SC_TECHNOLOGY_DIRECTWRITE = 1
    Result := 1;
  sctDIRECT_WRITE_RETAIN:                 /// <summary>SC_TECHNOLOGY_DIRECTWRITERETAIN = 2
    Result := 2;
  sctDIRECT_WRITE_D_C:                    /// <summary>SC_TECHNOLOGY_DIRECTWRITEDC = 3
    Result := 3;
  sctDIRECT_WRITE_1:                      /// <summary>SC_TECHNOLOGY_DIRECT_WRITE_1 = 4
    Result := 4;
  else
    Result := 0;
  end;
end;

function TDSciTechnologyFromInt(AEnum: Integer): TDSciTechnology;
begin
  case AEnum of
  0:
    Result := sctDEFAULT;                             /// <summary>SC_TECHNOLOGY_DEFAULT = 0
  1:
    Result := sctDIRECT_WRITE;                        /// <summary>SC_TECHNOLOGY_DIRECTWRITE = 1
  2:
    Result := sctDIRECT_WRITE_RETAIN;                 /// <summary>SC_TECHNOLOGY_DIRECTWRITERETAIN = 2
  3:
    Result := sctDIRECT_WRITE_D_C;                    /// <summary>SC_TECHNOLOGY_DIRECTWRITEDC = 3
  4:
    Result := sctDIRECT_WRITE_1;                      /// <summary>SC_TECHNOLOGY_DIRECT_WRITE_1 = 4
  else
    Result := sctDEFAULT;                             /// <summary>SC_TECHNOLOGY_DEFAULT = 0;
  end;
end;

function TDSciLineEndTypeToInt(AEnum: TDSciLineEndType): Integer;
begin
  case AEnum of
  scletDEFAULT:                           /// <summary>SC_LINE_END_TYPE_DEFAULT = 0
    Result := 0;
  scletUNICODE:                           /// <summary>SC_LINE_END_TYPE_UNICODE = 1
    Result := 1;
  else
    Result := 0;
  end;
end;

function TDSciLineEndTypeFromInt(AEnum: Integer): TDSciLineEndType;
begin
  case AEnum of
  0:
    Result := scletDEFAULT;                           /// <summary>SC_LINE_END_TYPE_DEFAULT = 0
  1:
    Result := scletUNICODE;                           /// <summary>SC_LINE_END_TYPE_UNICODE = 1
  else
    Result := scletDEFAULT;                           /// <summary>SC_LINE_END_TYPE_DEFAULT = 0;
  end;
end;

function TDSciRepresentationAppearanceToInt(AEnum: TDSciRepresentationAppearance): Integer;
begin
  case AEnum of
  scra_PLAIN:                             /// <summary>SC_REPRESENTATION_PLAIN = 0
    Result := 0;
  scra_BLOB:                              /// <summary>SC_REPRESENTATION_BLOB = 1
    Result := 1;
  scra_COLOUR:                            /// <summary>SC_REPRESENTATION_COLOUR = $10
    Result := $10;
  else
    Result := 0;
  end;
end;

function TDSciRepresentationAppearanceFromInt(AEnum: Integer): TDSciRepresentationAppearance;
begin
  case AEnum of
  0:
    Result := scra_PLAIN;                             /// <summary>SC_REPRESENTATION_PLAIN = 0
  1:
    Result := scra_BLOB;                              /// <summary>SC_REPRESENTATION_BLOB = 1
  $10:
    Result := scra_COLOUR;                            /// <summary>SC_REPRESENTATION_COLOUR = $10
  else
    Result := scra_PLAIN;                             /// <summary>SC_REPRESENTATION_PLAIN = 0;
  end;
end;

function TDSciEOLAnnotationVisibleToInt(AEnum: TDSciEOLAnnotationVisible): Integer;
begin
  case AEnum of
  sceolavHIDDEN:                          /// <summary>EOLANNOTATION_HIDDEN = $0
    Result := $0;
  sceolavSTANDARD:                        /// <summary>EOLANNOTATION_STANDARD = $1
    Result := $1;
  sceolavBOXED:                           /// <summary>EOLANNOTATION_BOXED = $2
    Result := $2;
  sceolavSTADIUM:                         /// <summary>EOLANNOTATION_STADIUM = $100
    Result := $100;
  sceolavFLAT_CIRCLE:                     /// <summary>EOLANNOTATION_FLAT_CIRCLE = $101
    Result := $101;
  sceolavANGLE_CIRCLE:                    /// <summary>EOLANNOTATION_ANGLE_CIRCLE = $102
    Result := $102;
  sceolavCIRCLE_FLAT:                     /// <summary>EOLANNOTATION_CIRCLE_FLAT = $110
    Result := $110;
  sceolavFLATS:                           /// <summary>EOLANNOTATION_FLATS = $111
    Result := $111;
  sceolavANGLE_FLAT:                      /// <summary>EOLANNOTATION_ANGLE_FLAT = $112
    Result := $112;
  sceolavCIRCLE_ANGLE:                    /// <summary>EOLANNOTATION_CIRCLE_ANGLE = $120
    Result := $120;
  sceolavFLAT_ANGLE:                      /// <summary>EOLANNOTATION_FLAT_ANGLE = $121
    Result := $121;
  sceolavANGLES:                          /// <summary>EOLANNOTATION_ANGLES = $122
    Result := $122;
  else
    Result := $0;
  end;
end;

function TDSciEOLAnnotationVisibleFromInt(AEnum: Integer): TDSciEOLAnnotationVisible;
begin
  case AEnum of
  $0:
    Result := sceolavHIDDEN;                          /// <summary>EOLANNOTATION_HIDDEN = $0
  $1:
    Result := sceolavSTANDARD;                        /// <summary>EOLANNOTATION_STANDARD = $1
  $2:
    Result := sceolavBOXED;                           /// <summary>EOLANNOTATION_BOXED = $2
  $100:
    Result := sceolavSTADIUM;                         /// <summary>EOLANNOTATION_STADIUM = $100
  $101:
    Result := sceolavFLAT_CIRCLE;                     /// <summary>EOLANNOTATION_FLAT_CIRCLE = $101
  $102:
    Result := sceolavANGLE_CIRCLE;                    /// <summary>EOLANNOTATION_ANGLE_CIRCLE = $102
  $110:
    Result := sceolavCIRCLE_FLAT;                     /// <summary>EOLANNOTATION_CIRCLE_FLAT = $110
  $111:
    Result := sceolavFLATS;                           /// <summary>EOLANNOTATION_FLATS = $111
  $112:
    Result := sceolavANGLE_FLAT;                      /// <summary>EOLANNOTATION_ANGLE_FLAT = $112
  $120:
    Result := sceolavCIRCLE_ANGLE;                    /// <summary>EOLANNOTATION_CIRCLE_ANGLE = $120
  $121:
    Result := sceolavFLAT_ANGLE;                      /// <summary>EOLANNOTATION_FLAT_ANGLE = $121
  $122:
    Result := sceolavANGLES;                          /// <summary>EOLANNOTATION_ANGLES = $122
  else
    Result := sceolavHIDDEN;                          /// <summary>EOLANNOTATION_HIDDEN = $0;
  end;
end;

function TDSciSupportsToInt(AEnum: TDSciSupports): Integer;
begin
  case AEnum of
  scsLINE_DRAWS_FINAL:                    /// <summary>SC_SUPPORTS_LINE_DRAWS_FINAL = 0
    Result := 0;
  scsPIXEL_DIVISIONS:                     /// <summary>SC_SUPPORTS_PIXEL_DIVISIONS = 1
    Result := 1;
  scsFRACTIONAL_STROKE_WIDTH:             /// <summary>SC_SUPPORTS_FRACTIONAL_STROKE_WIDTH = 2
    Result := 2;
  scsTRANSLUCENT_STROKE:                  /// <summary>SC_SUPPORTS_TRANSLUCENT_STROKE = 3
    Result := 3;
  scsPIXEL_MODIFICATION:                  /// <summary>SC_SUPPORTS_PIXEL_MODIFICATION = 4
    Result := 4;
  scsTHREAD_SAFE_MEASURE_WIDTHS:          /// <summary>SC_SUPPORTS_THREAD_SAFE_MEASURE_WIDTHS = 5
    Result := 5;
  else
    Result := 0;
  end;
end;

function TDSciSupportsFromInt(AEnum: Integer): TDSciSupports;
begin
  case AEnum of
  0:
    Result := scsLINE_DRAWS_FINAL;                    /// <summary>SC_SUPPORTS_LINE_DRAWS_FINAL = 0
  1:
    Result := scsPIXEL_DIVISIONS;                     /// <summary>SC_SUPPORTS_PIXEL_DIVISIONS = 1
  2:
    Result := scsFRACTIONAL_STROKE_WIDTH;             /// <summary>SC_SUPPORTS_FRACTIONAL_STROKE_WIDTH = 2
  3:
    Result := scsTRANSLUCENT_STROKE;                  /// <summary>SC_SUPPORTS_TRANSLUCENT_STROKE = 3
  4:
    Result := scsPIXEL_MODIFICATION;                  /// <summary>SC_SUPPORTS_PIXEL_MODIFICATION = 4
  5:
    Result := scsTHREAD_SAFE_MEASURE_WIDTHS;          /// <summary>SC_SUPPORTS_THREAD_SAFE_MEASURE_WIDTHS = 5
  else
    Result := scsLINE_DRAWS_FINAL;                    /// <summary>SC_SUPPORTS_LINE_DRAWS_FINAL = 0;
  end;
end;

function TDSciLineCharacterIndexTypeToInt(AEnum: TDSciLineCharacterIndexType): Integer;
begin
  case AEnum of
  sclcitNONE:                             /// <summary>SC_LINECHARACTERINDEX_NONE = 0
    Result := 0;
  sclcitUTF32:                            /// <summary>SC_LINECHARACTERINDEX_UTF32 = 1
    Result := 1;
  sclcitUTF16:                            /// <summary>SC_LINECHARACTERINDEX_UTF16 = 2
    Result := 2;
  else
    Result := 0;
  end;
end;

function TDSciLineCharacterIndexTypeFromInt(AEnum: Integer): TDSciLineCharacterIndexType;
begin
  case AEnum of
  0:
    Result := sclcitNONE;                             /// <summary>SC_LINECHARACTERINDEX_NONE = 0
  1:
    Result := sclcitUTF32;                            /// <summary>SC_LINECHARACTERINDEX_UTF32 = 1
  2:
    Result := sclcitUTF16;                            /// <summary>SC_LINECHARACTERINDEX_UTF16 = 2
  else
    Result := sclcitNONE;                             /// <summary>SC_LINECHARACTERINDEX_NONE = 0;
  end;
end;

function TDSciTypePropertyToInt(AEnum: TDSciTypeProperty): Integer;
begin
  case AEnum of
  sctpBOOLEAN:                            /// <summary>SC_TYPE_BOOLEAN = 0
    Result := 0;
  sctpINTEGER:                            /// <summary>SC_TYPE_INTEGER = 1
    Result := 1;
  sctpSTRING:                             /// <summary>SC_TYPE_STRING = 2
    Result := 2;
  else
    Result := 0;
  end;
end;

function TDSciTypePropertyFromInt(AEnum: Integer): TDSciTypeProperty;
begin
  case AEnum of
  0:
    Result := sctpBOOLEAN;                            /// <summary>SC_TYPE_BOOLEAN = 0
  1:
    Result := sctpINTEGER;                            /// <summary>SC_TYPE_INTEGER = 1
  2:
    Result := sctpSTRING;                             /// <summary>SC_TYPE_STRING = 2
  else
    Result := sctpBOOLEAN;                            /// <summary>SC_TYPE_BOOLEAN = 0;
  end;
end;

function TDSciModificationFlagsToInt(AEnum: TDSciModificationFlags): Integer;
begin
  case AEnum of
  scmfINSERT_TEXT:                        /// <summary>SC_MOD_INSERTTEXT = $1
    Result := $1;
  scmfDELETE_TEXT:                        /// <summary>SC_MOD_DELETETEXT = $2
    Result := $2;
  scmfCHANGE_STYLE:                       /// <summary>SC_MOD_CHANGESTYLE = $4
    Result := $4;
  scmfCHANGE_FOLD:                        /// <summary>SC_MOD_CHANGEFOLD = $8
    Result := $8;
  scmfUSER:                               /// <summary>SC_PERFORMED_USER = $10
    Result := $10;
  scmfUNDO:                               /// <summary>SC_PERFORMED_UNDO = $20
    Result := $20;
  scmfREDO:                               /// <summary>SC_PERFORMED_REDO = $40
    Result := $40;
  scmfMULTI_STEP_UNDO_REDO:               /// <summary>SC_MULTISTEPUNDOREDO = $80
    Result := $80;
  scmfLAST_STEP_IN_UNDO_REDO:             /// <summary>SC_LASTSTEPINUNDOREDO = $100
    Result := $100;
  scmfCHANGE_MARKER:                      /// <summary>SC_MOD_CHANGEMARKER = $200
    Result := $200;
  scmfBEFORE_INSERT:                      /// <summary>SC_MOD_BEFOREINSERT = $400
    Result := $400;
  scmfBEFORE_DELETE:                      /// <summary>SC_MOD_BEFOREDELETE = $800
    Result := $800;
  scmfMULTILINE_UNDO_REDO:                /// <summary>SC_MULTILINEUNDOREDO = $1000
    Result := $1000;
  scmfSTART_ACTION:                       /// <summary>SC_STARTACTION = $2000
    Result := $2000;
  scmfCHANGE_INDICATOR:                   /// <summary>SC_MOD_CHANGEINDICATOR = $4000
    Result := $4000;
  scmfCHANGE_LINE_STATE:                  /// <summary>SC_MOD_CHANGELINESTATE = $8000
    Result := $8000;
  scmfCHANGE_MARGIN:                      /// <summary>SC_MOD_CHANGEMARGIN = $10000
    Result := $10000;
  scmfCHANGE_ANNOTATION:                  /// <summary>SC_MOD_CHANGEANNOTATION = $20000
    Result := $20000;
  scmfCONTAINER:                          /// <summary>SC_MOD_CONTAINER = $40000
    Result := $40000;
  scmfLEXER_STATE:                        /// <summary>SC_MOD_LEXERSTATE = $80000
    Result := $80000;
  scmfINSERT_CHECK:                       /// <summary>SC_MOD_INSERTCHECK = $100000
    Result := $100000;
  scmfCHANGE_TAB_STOPS:                   /// <summary>SC_MOD_CHANGETABSTOPS = $200000
    Result := $200000;
  scmfCHANGE_E_O_L_ANNOTATION:            /// <summary>SC_MOD_CHANGEEOLANNOTATION = $400000
    Result := $400000;
  scmfEVENT_MASK_ALL:                     /// <summary>SC_MODEVENTMASKALL = $7FFFFF
    Result := $7FFFFF;
  else
    Result := $1;
  end;
end;

function TDSciModificationFlagsFromInt(AEnum: Integer): TDSciModificationFlags;
begin
  case AEnum of
  $1:
    Result := scmfINSERT_TEXT;                        /// <summary>SC_MOD_INSERTTEXT = $1
  $2:
    Result := scmfDELETE_TEXT;                        /// <summary>SC_MOD_DELETETEXT = $2
  $4:
    Result := scmfCHANGE_STYLE;                       /// <summary>SC_MOD_CHANGESTYLE = $4
  $8:
    Result := scmfCHANGE_FOLD;                        /// <summary>SC_MOD_CHANGEFOLD = $8
  $10:
    Result := scmfUSER;                               /// <summary>SC_PERFORMED_USER = $10
  $20:
    Result := scmfUNDO;                               /// <summary>SC_PERFORMED_UNDO = $20
  $40:
    Result := scmfREDO;                               /// <summary>SC_PERFORMED_REDO = $40
  $80:
    Result := scmfMULTI_STEP_UNDO_REDO;               /// <summary>SC_MULTISTEPUNDOREDO = $80
  $100:
    Result := scmfLAST_STEP_IN_UNDO_REDO;             /// <summary>SC_LASTSTEPINUNDOREDO = $100
  $200:
    Result := scmfCHANGE_MARKER;                      /// <summary>SC_MOD_CHANGEMARKER = $200
  $400:
    Result := scmfBEFORE_INSERT;                      /// <summary>SC_MOD_BEFOREINSERT = $400
  $800:
    Result := scmfBEFORE_DELETE;                      /// <summary>SC_MOD_BEFOREDELETE = $800
  $1000:
    Result := scmfMULTILINE_UNDO_REDO;                /// <summary>SC_MULTILINEUNDOREDO = $1000
  $2000:
    Result := scmfSTART_ACTION;                       /// <summary>SC_STARTACTION = $2000
  $4000:
    Result := scmfCHANGE_INDICATOR;                   /// <summary>SC_MOD_CHANGEINDICATOR = $4000
  $8000:
    Result := scmfCHANGE_LINE_STATE;                  /// <summary>SC_MOD_CHANGELINESTATE = $8000
  $10000:
    Result := scmfCHANGE_MARGIN;                      /// <summary>SC_MOD_CHANGEMARGIN = $10000
  $20000:
    Result := scmfCHANGE_ANNOTATION;                  /// <summary>SC_MOD_CHANGEANNOTATION = $20000
  $40000:
    Result := scmfCONTAINER;                          /// <summary>SC_MOD_CONTAINER = $40000
  $80000:
    Result := scmfLEXER_STATE;                        /// <summary>SC_MOD_LEXERSTATE = $80000
  $100000:
    Result := scmfINSERT_CHECK;                       /// <summary>SC_MOD_INSERTCHECK = $100000
  $200000:
    Result := scmfCHANGE_TAB_STOPS;                   /// <summary>SC_MOD_CHANGETABSTOPS = $200000
  $400000:
    Result := scmfCHANGE_E_O_L_ANNOTATION;            /// <summary>SC_MOD_CHANGEEOLANNOTATION = $400000
  $7FFFFF:
    Result := scmfEVENT_MASK_ALL;                     /// <summary>SC_MODEVENTMASKALL = $7FFFFF
  else
    Result := scmfINSERT_TEXT;                        /// <summary>SC_MOD_INSERTTEXT = $1;
  end;
end;

function TDSciModificationFlagsSetToInt(AEnum: TDSciModificationFlagsSet): Integer;
var
  lEnum: TDSciModificationFlags;
begin
  Result := 0;

  for lEnum in AEnum do
    Result := Result or TDSciModificationFlagsToInt(lEnum);
end;

function TDSciModificationFlagsSetFromInt(AEnum: Integer): TDSciModificationFlagsSet;
var
  lEnum: TDSciModificationFlags;
begin
  Result := [];

  for lEnum := Low(TDSciModificationFlags) to High(TDSciModificationFlags) do
    if AEnum and TDSciModificationFlagsToInt(lEnum) <> 0 then
      Include(Result, lEnum);
end;

function TDSciUpdateToInt(AEnum: TDSciUpdate): Integer;
begin
  case AEnum of
  scuNONE:                                /// <summary>SC_UPDATE_NONE = $0
    Result := $0;
  scuCONTENT:                             /// <summary>SC_UPDATE_CONTENT = $1
    Result := $1;
  scuSELECTION:                           /// <summary>SC_UPDATE_SELECTION = $2
    Result := $2;
  scuV_SCROLL:                            /// <summary>SC_UPDATE_V_SCROLL = $4
    Result := $4;
  scuH_SCROLL:                            /// <summary>SC_UPDATE_H_SCROLL = $8
    Result := $8;
  else
    Result := $0;
  end;
end;

function TDSciUpdateFromInt(AEnum: Integer): TDSciUpdate;
begin
  case AEnum of
  $0:
    Result := scuNONE;                                /// <summary>SC_UPDATE_NONE = $0
  $1:
    Result := scuCONTENT;                             /// <summary>SC_UPDATE_CONTENT = $1
  $2:
    Result := scuSELECTION;                           /// <summary>SC_UPDATE_SELECTION = $2
  $4:
    Result := scuV_SCROLL;                            /// <summary>SC_UPDATE_V_SCROLL = $4
  $8:
    Result := scuH_SCROLL;                            /// <summary>SC_UPDATE_H_SCROLL = $8
  else
    Result := scuNONE;                                /// <summary>SC_UPDATE_NONE = $0;
  end;
end;

function TDSciUpdateFlagsSetToInt(AEnum: TDSciUpdateFlagsSet): Integer;
var
  lEnum: TDSciUpdate;
begin
  Result := 0;

  for lEnum in AEnum do
    Result := Result or TDSciUpdateToInt(lEnum);
end;

function TDSciUpdateFlagsSetFromInt(AEnum: Integer): TDSciUpdateFlagsSet;
var
  lEnum: TDSciUpdate;
begin
  Result := [];

  for lEnum := Low(TDSciUpdate) to High(TDSciUpdate) do
    if AEnum and TDSciUpdateToInt(lEnum) <> 0 then
      Include(Result, lEnum);
end;

function TDSciFocusChangeToInt(AEnum: TDSciFocusChange): Integer;
begin
  case AEnum of
  scfcCHANGE:                             /// <summary>SCEN_CHANGE = 768
    Result := 768;
  scfcSETFOCUS:                           /// <summary>SCEN_SETFOCUS = 512
    Result := 512;
  scfcKILLFOCUS:                          /// <summary>SCEN_KILLFOCUS = 256
    Result := 256;
  else
    Result := 768;
  end;
end;

function TDSciFocusChangeFromInt(AEnum: Integer): TDSciFocusChange;
begin
  case AEnum of
  768:
    Result := scfcCHANGE;                             /// <summary>SCEN_CHANGE = 768
  512:
    Result := scfcSETFOCUS;                           /// <summary>SCEN_SETFOCUS = 512
  256:
    Result := scfcKILLFOCUS;                          /// <summary>SCEN_KILLFOCUS = 256
  else
    Result := scfcCHANGE;                             /// <summary>SCEN_CHANGE = 768;
  end;
end;

function TDSciKeysToInt(AEnum: TDSciKeys): Integer;
begin
  case AEnum of
  sckDOWN:                                /// <summary>SCK_DOWN = 300
    Result := 300;
  sckUP:                                  /// <summary>SCK_UP = 301
    Result := 301;
  sckLEFT:                                /// <summary>SCK_LEFT = 302
    Result := 302;
  sckRIGHT:                               /// <summary>SCK_RIGHT = 303
    Result := 303;
  sckHOME:                                /// <summary>SCK_HOME = 304
    Result := 304;
  sckEND:                                 /// <summary>SCK_END = 305
    Result := 305;
  sckPRIOR:                               /// <summary>SCK_PRIOR = 306
    Result := 306;
  sckNEXT:                                /// <summary>SCK_NEXT = 307
    Result := 307;
  sckDELETE:                              /// <summary>SCK_DELETE = 308
    Result := 308;
  sckINSERT:                              /// <summary>SCK_INSERT = 309
    Result := 309;
  sckESCAPE:                              /// <summary>SCK_ESCAPE = 7
    Result := 7;
  sckBACK:                                /// <summary>SCK_BACK = 8
    Result := 8;
  sckTAB:                                 /// <summary>SCK_TAB = 9
    Result := 9;
  sckRETURN:                              /// <summary>SCK_RETURN = 13
    Result := 13;
  sckADD:                                 /// <summary>SCK_ADD = 310
    Result := 310;
  sckSUBTRACT:                            /// <summary>SCK_SUBTRACT = 311
    Result := 311;
  sckDIVIDE:                              /// <summary>SCK_DIVIDE = 312
    Result := 312;
  sckWIN:                                 /// <summary>SCK_WIN = 313
    Result := 313;
  sckR_WIN:                               /// <summary>SCK_RWIN = 314
    Result := 314;
  sckMENU:                                /// <summary>SCK_MENU = 315
    Result := 315;
  else
    Result := 300;
  end;
end;

function TDSciKeysFromInt(AEnum: Integer): TDSciKeys;
begin
  case AEnum of
  300:
    Result := sckDOWN;                                /// <summary>SCK_DOWN = 300
  301:
    Result := sckUP;                                  /// <summary>SCK_UP = 301
  302:
    Result := sckLEFT;                                /// <summary>SCK_LEFT = 302
  303:
    Result := sckRIGHT;                               /// <summary>SCK_RIGHT = 303
  304:
    Result := sckHOME;                                /// <summary>SCK_HOME = 304
  305:
    Result := sckEND;                                 /// <summary>SCK_END = 305
  306:
    Result := sckPRIOR;                               /// <summary>SCK_PRIOR = 306
  307:
    Result := sckNEXT;                                /// <summary>SCK_NEXT = 307
  308:
    Result := sckDELETE;                              /// <summary>SCK_DELETE = 308
  309:
    Result := sckINSERT;                              /// <summary>SCK_INSERT = 309
  7:
    Result := sckESCAPE;                              /// <summary>SCK_ESCAPE = 7
  8:
    Result := sckBACK;                                /// <summary>SCK_BACK = 8
  9:
    Result := sckTAB;                                 /// <summary>SCK_TAB = 9
  13:
    Result := sckRETURN;                              /// <summary>SCK_RETURN = 13
  310:
    Result := sckADD;                                 /// <summary>SCK_ADD = 310
  311:
    Result := sckSUBTRACT;                            /// <summary>SCK_SUBTRACT = 311
  312:
    Result := sckDIVIDE;                              /// <summary>SCK_DIVIDE = 312
  313:
    Result := sckWIN;                                 /// <summary>SCK_WIN = 313
  314:
    Result := sckR_WIN;                               /// <summary>SCK_RWIN = 314
  315:
    Result := sckMENU;                                /// <summary>SCK_MENU = 315
  else
    Result := sckDOWN;                                /// <summary>SCK_DOWN = 300;
  end;
end;

function TDSciKeyModToInt(AEnum: TDSciKeyMod): Integer;
begin
  case AEnum of
  sckmSHIFT:                              /// <summary>SCMOD_SHIFT = 1
    Result := 1;
  sckmCTRL:                               /// <summary>SCMOD_CTRL = 2
    Result := 2;
  sckmALT:                                /// <summary>SCMOD_ALT = 4
    Result := 4;
  sckmSUPER:                              /// <summary>SCMOD_SUPER = 8
    Result := 8;
  sckmMETA:                               /// <summary>SCMOD_META = 16
    Result := 16;
  else
    Result := 1;
  end;
end;

function TDSciKeyModFromInt(AEnum: Integer): TDSciKeyMod;
begin
  case AEnum of
  1:
    Result := sckmSHIFT;                              /// <summary>SCMOD_SHIFT = 1
  2:
    Result := sckmCTRL;                               /// <summary>SCMOD_CTRL = 2
  4:
    Result := sckmALT;                                /// <summary>SCMOD_ALT = 4
  8:
    Result := sckmSUPER;                              /// <summary>SCMOD_SUPER = 8
  16:
    Result := sckmMETA;                               /// <summary>SCMOD_META = 16
  else
    Result := sckmSHIFT;                              /// <summary>SCMOD_SHIFT = 1;
  end;
end;

function TDSciKeyModSetToInt(AEnum: TDSciKeyModSet): Integer;
var
  lEnum: TDSciKeyMod;
begin
  Result := 0;

  for lEnum in AEnum do
    Result := Result or TDSciKeyModToInt(lEnum);
end;

function TDSciKeyModSetFromInt(AEnum: Integer): TDSciKeyModSet;
var
  lEnum: TDSciKeyMod;
begin
  Result := [];

  for lEnum := Low(TDSciKeyMod) to High(TDSciKeyMod) do
    if AEnum and TDSciKeyModToInt(lEnum) <> 0 then
      Include(Result, lEnum);
end;

function TDSciCompletionMethodsToInt(AEnum: TDSciCompletionMethods): Integer;
begin
  case AEnum of
  sccmFILL_UP:                            /// <summary>SC_AC_FILLUP = 1
    Result := 1;
  sccmDOUBLE_CLICK:                       /// <summary>SC_AC_DOUBLECLICK = 2
    Result := 2;
  sccmTAB:                                /// <summary>SC_AC_TAB = 3
    Result := 3;
  sccmNEWLINE:                            /// <summary>SC_AC_NEWLINE = 4
    Result := 4;
  sccmCOMMAND:                            /// <summary>SC_AC_COMMAND = 5
    Result := 5;
  sccmSINGLE_CHOICE:                      /// <summary>SC_AC_SINGLE_CHOICE = 6
    Result := 6;
  else
    Result := 1;
  end;
end;

function TDSciCompletionMethodsFromInt(AEnum: Integer): TDSciCompletionMethods;
begin
  case AEnum of
  1:
    Result := sccmFILL_UP;                            /// <summary>SC_AC_FILLUP = 1
  2:
    Result := sccmDOUBLE_CLICK;                       /// <summary>SC_AC_DOUBLECLICK = 2
  3:
    Result := sccmTAB;                                /// <summary>SC_AC_TAB = 3
  4:
    Result := sccmNEWLINE;                            /// <summary>SC_AC_NEWLINE = 4
  5:
    Result := sccmCOMMAND;                            /// <summary>SC_AC_COMMAND = 5
  6:
    Result := sccmSINGLE_CHOICE;                      /// <summary>SC_AC_SINGLE_CHOICE = 6
  else
    Result := sccmFILL_UP;                            /// <summary>SC_AC_FILLUP = 1;
  end;
end;

function TDSciCharacterSourceToInt(AEnum: TDSciCharacterSource): Integer;
begin
  case AEnum of
  sccsDIRECT_INPUT:                       /// <summary>SC_CHARACTERSOURCE_DIRECT_INPUT = 0
    Result := 0;
  sccsTENTATIVE_INPUT:                    /// <summary>SC_CHARACTERSOURCE_TENTATIVE_INPUT = 1
    Result := 1;
  sccsIME_RESULT:                         /// <summary>SC_CHARACTERSOURCE_IME_RESULT = 2
    Result := 2;
  else
    Result := 0;
  end;
end;

function TDSciCharacterSourceFromInt(AEnum: Integer): TDSciCharacterSource;
begin
  case AEnum of
  0:
    Result := sccsDIRECT_INPUT;                       /// <summary>SC_CHARACTERSOURCE_DIRECT_INPUT = 0
  1:
    Result := sccsTENTATIVE_INPUT;                    /// <summary>SC_CHARACTERSOURCE_TENTATIVE_INPUT = 1
  2:
    Result := sccsIME_RESULT;                         /// <summary>SC_CHARACTERSOURCE_IME_RESULT = 2
  else
    Result := sccsDIRECT_INPUT;                       /// <summary>SC_CHARACTERSOURCE_DIRECT_INPUT = 0;
  end;
end;

function TDSciBidirectionalToInt(AEnum: TDSciBidirectional): Integer;
begin
  case AEnum of
  scbDISABLED:                            /// <summary>SC_BIDIRECTIONAL_DISABLED = 0
    Result := 0;
  scbL2R:                                 /// <summary>SC_BIDIRECTIONAL_L2R = 1
    Result := 1;
  scbR2L:                                 /// <summary>SC_BIDIRECTIONAL_R2L = 2
    Result := 2;
  else
    Result := 0;
  end;
end;

function TDSciBidirectionalFromInt(AEnum: Integer): TDSciBidirectional;
begin
  case AEnum of
  0:
    Result := scbDISABLED;                            /// <summary>SC_BIDIRECTIONAL_DISABLED = 0
  1:
    Result := scbL2R;                                 /// <summary>SC_BIDIRECTIONAL_L2R = 1
  2:
    Result := scbR2L;                                 /// <summary>SC_BIDIRECTIONAL_R2L = 2
  else
    Result := scbDISABLED;                            /// <summary>SC_BIDIRECTIONAL_DISABLED = 0;
  end;
end;

function TDSciLexerIdToInt(AEnum: TDSciLexerId): Integer;
begin
  case AEnum of
  sclCONTAINER:                           /// <summary>SCLEX_CONTAINER = 0
    Result := 0;
  sclNULL:                                /// <summary>SCLEX_NULL = 1
    Result := 1;
  sclPYTHON:                              /// <summary>SCLEX_PYTHON = 2
    Result := 2;
  sclCPP:                                 /// <summary>SCLEX_CPP = 3
    Result := 3;
  sclHTML:                                /// <summary>SCLEX_HTML = 4
    Result := 4;
  sclXML:                                 /// <summary>SCLEX_XML = 5
    Result := 5;
  sclPERL:                                /// <summary>SCLEX_PERL = 6
    Result := 6;
  sclSQL:                                 /// <summary>SCLEX_SQL = 7
    Result := 7;
  sclVB:                                  /// <summary>SCLEX_VB = 8
    Result := 8;
  sclPROPERTIES:                          /// <summary>SCLEX_PROPERTIES = 9
    Result := 9;
  sclERRORLIST:                           /// <summary>SCLEX_ERRORLIST = 10
    Result := 10;
  sclMAKEFILE:                            /// <summary>SCLEX_MAKEFILE = 11
    Result := 11;
  sclBATCH:                               /// <summary>SCLEX_BATCH = 12
    Result := 12;
  sclXCODE:                               /// <summary>SCLEX_XCODE = 13
    Result := 13;
  sclLATEX:                               /// <summary>SCLEX_LATEX = 14
    Result := 14;
  sclLUA:                                 /// <summary>SCLEX_LUA = 15
    Result := 15;
  sclDIFF:                                /// <summary>SCLEX_DIFF = 16
    Result := 16;
  sclCONF:                                /// <summary>SCLEX_CONF = 17
    Result := 17;
  sclPASCAL:                              /// <summary>SCLEX_PASCAL = 18
    Result := 18;
  sclAVE:                                 /// <summary>SCLEX_AVE = 19
    Result := 19;
  sclADA:                                 /// <summary>SCLEX_ADA = 20
    Result := 20;
  sclLISP:                                /// <summary>SCLEX_LISP = 21
    Result := 21;
  sclRUBY:                                /// <summary>SCLEX_RUBY = 22
    Result := 22;
  sclEIFFEL:                              /// <summary>SCLEX_EIFFEL = 23
    Result := 23;
  sclEIFFELKW:                            /// <summary>SCLEX_EIFFELKW = 24
    Result := 24;
  sclTCL:                                 /// <summary>SCLEX_TCL = 25
    Result := 25;
  sclNNCRONTAB:                           /// <summary>SCLEX_NNCRONTAB = 26
    Result := 26;
  sclBULLANT:                             /// <summary>SCLEX_BULLANT = 27
    Result := 27;
  sclVBSCRIPT:                            /// <summary>SCLEX_VBSCRIPT = 28
    Result := 28;
  sclBAAN:                                /// <summary>SCLEX_BAAN = 31
    Result := 31;
  sclMATLAB:                              /// <summary>SCLEX_MATLAB = 32
    Result := 32;
  sclSCRIPTOL:                            /// <summary>SCLEX_SCRIPTOL = 33
    Result := 33;
  sclASM:                                 /// <summary>SCLEX_ASM = 34
    Result := 34;
  sclCPPNOCASE:                           /// <summary>SCLEX_CPPNOCASE = 35
    Result := 35;
  sclFORTRAN:                             /// <summary>SCLEX_FORTRAN = 36
    Result := 36;
  sclF77:                                 /// <summary>SCLEX_F77 = 37
    Result := 37;
  sclCSS:                                 /// <summary>SCLEX_CSS = 38
    Result := 38;
  sclPOV:                                 /// <summary>SCLEX_POV = 39
    Result := 39;
  sclLOUT:                                /// <summary>SCLEX_LOUT = 40
    Result := 40;
  sclESCRIPT:                             /// <summary>SCLEX_ESCRIPT = 41
    Result := 41;
  sclPS:                                  /// <summary>SCLEX_PS = 42
    Result := 42;
  sclNSIS:                                /// <summary>SCLEX_NSIS = 43
    Result := 43;
  sclMMIXAL:                              /// <summary>SCLEX_MMIXAL = 44
    Result := 44;
  sclCLW:                                 /// <summary>SCLEX_CLW = 45
    Result := 45;
  sclCLWNOCASE:                           /// <summary>SCLEX_CLWNOCASE = 46
    Result := 46;
  sclLOT:                                 /// <summary>SCLEX_LOT = 47
    Result := 47;
  sclYAML:                                /// <summary>SCLEX_YAML = 48
    Result := 48;
  sclTEX:                                 /// <summary>SCLEX_TEX = 49
    Result := 49;
  sclMETAPOST:                            /// <summary>SCLEX_METAPOST = 50
    Result := 50;
  sclPOWERBASIC:                          /// <summary>SCLEX_POWERBASIC = 51
    Result := 51;
  sclFORTH:                               /// <summary>SCLEX_FORTH = 52
    Result := 52;
  sclERLANG:                              /// <summary>SCLEX_ERLANG = 53
    Result := 53;
  sclOCTAVE:                              /// <summary>SCLEX_OCTAVE = 54
    Result := 54;
  sclMSSQL:                               /// <summary>SCLEX_MSSQL = 55
    Result := 55;
  sclVERILOG:                             /// <summary>SCLEX_VERILOG = 56
    Result := 56;
  sclKIX:                                 /// <summary>SCLEX_KIX = 57
    Result := 57;
  sclGUI4CLI:                             /// <summary>SCLEX_GUI4CLI = 58
    Result := 58;
  sclSPECMAN:                             /// <summary>SCLEX_SPECMAN = 59
    Result := 59;
  sclAU3:                                 /// <summary>SCLEX_AU3 = 60
    Result := 60;
  sclAPDL:                                /// <summary>SCLEX_APDL = 61
    Result := 61;
  sclBASH:                                /// <summary>SCLEX_BASH = 62
    Result := 62;
  sclASN1:                                /// <summary>SCLEX_ASN1 = 63
    Result := 63;
  sclVHDL:                                /// <summary>SCLEX_VHDL = 64
    Result := 64;
  sclCAML:                                /// <summary>SCLEX_CAML = 65
    Result := 65;
  sclBLITZBASIC:                          /// <summary>SCLEX_BLITZBASIC = 66
    Result := 66;
  sclPUREBASIC:                           /// <summary>SCLEX_PUREBASIC = 67
    Result := 67;
  sclHASKELL:                             /// <summary>SCLEX_HASKELL = 68
    Result := 68;
  sclPHPSCRIPT:                           /// <summary>SCLEX_PHPSCRIPT = 69
    Result := 69;
  sclTADS3:                               /// <summary>SCLEX_TADS3 = 70
    Result := 70;
  sclREBOL:                               /// <summary>SCLEX_REBOL = 71
    Result := 71;
  sclSMALLTALK:                           /// <summary>SCLEX_SMALLTALK = 72
    Result := 72;
  sclFLAGSHIP:                            /// <summary>SCLEX_FLAGSHIP = 73
    Result := 73;
  sclCSOUND:                              /// <summary>SCLEX_CSOUND = 74
    Result := 74;
  sclFREEBASIC:                           /// <summary>SCLEX_FREEBASIC = 75
    Result := 75;
  sclINNOSETUP:                           /// <summary>SCLEX_INNOSETUP = 76
    Result := 76;
  sclOPAL:                                /// <summary>SCLEX_OPAL = 77
    Result := 77;
  sclSPICE:                               /// <summary>SCLEX_SPICE = 78
    Result := 78;
  sclD:                                   /// <summary>SCLEX_D = 79
    Result := 79;
  sclCMAKE:                               /// <summary>SCLEX_CMAKE = 80
    Result := 80;
  sclGAP:                                 /// <summary>SCLEX_GAP = 81
    Result := 81;
  sclPLM:                                 /// <summary>SCLEX_PLM = 82
    Result := 82;
  sclPROGRESS:                            /// <summary>SCLEX_PROGRESS = 83
    Result := 83;
  sclABAQUS:                              /// <summary>SCLEX_ABAQUS = 84
    Result := 84;
  sclASYMPTOTE:                           /// <summary>SCLEX_ASYMPTOTE = 85
    Result := 85;
  sclR:                                   /// <summary>SCLEX_R = 86
    Result := 86;
  sclMAGIK:                               /// <summary>SCLEX_MAGIK = 87
    Result := 87;
  sclPOWERSHELL:                          /// <summary>SCLEX_POWERSHELL = 88
    Result := 88;
  sclMYSQL:                               /// <summary>SCLEX_MYSQL = 89
    Result := 89;
  sclPO:                                  /// <summary>SCLEX_PO = 90
    Result := 90;
  sclTAL:                                 /// <summary>SCLEX_TAL = 91
    Result := 91;
  sclCOBOL:                               /// <summary>SCLEX_COBOL = 92
    Result := 92;
  sclTACL:                                /// <summary>SCLEX_TACL = 93
    Result := 93;
  sclSORCUS:                              /// <summary>SCLEX_SORCUS = 94
    Result := 94;
  sclPOWERPRO:                            /// <summary>SCLEX_POWERPRO = 95
    Result := 95;
  sclNIMROD:                              /// <summary>SCLEX_NIMROD = 96
    Result := 96;
  sclSML:                                 /// <summary>SCLEX_SML = 97
    Result := 97;
  sclMARKDOWN:                            /// <summary>SCLEX_MARKDOWN = 98
    Result := 98;
  sclTXT2TAGS:                            /// <summary>SCLEX_TXT2TAGS = 99
    Result := 99;
  sclA68K:                                /// <summary>SCLEX_A68K = 100
    Result := 100;
  sclMODULA:                              /// <summary>SCLEX_MODULA = 101
    Result := 101;
  sclCOFFEESCRIPT:                        /// <summary>SCLEX_COFFEESCRIPT = 102
    Result := 102;
  sclTCMD:                                /// <summary>SCLEX_TCMD = 103
    Result := 103;
  sclAVS:                                 /// <summary>SCLEX_AVS = 104
    Result := 104;
  sclECL:                                 /// <summary>SCLEX_ECL = 105
    Result := 105;
  sclOSCRIPT:                             /// <summary>SCLEX_OSCRIPT = 106
    Result := 106;
  sclVISUALPROLOG:                        /// <summary>SCLEX_VISUALPROLOG = 107
    Result := 107;
  sclLITERATEHASKELL:                     /// <summary>SCLEX_LITERATEHASKELL = 108
    Result := 108;
  sclSTTXT:                               /// <summary>SCLEX_STTXT = 109
    Result := 109;
  sclKVIRC:                               /// <summary>SCLEX_KVIRC = 110
    Result := 110;
  sclRUST:                                /// <summary>SCLEX_RUST = 111
    Result := 111;
  sclDMAP:                                /// <summary>SCLEX_DMAP = 112
    Result := 112;
  sclAS:                                  /// <summary>SCLEX_AS = 113
    Result := 113;
  sclDMIS:                                /// <summary>SCLEX_DMIS = 114
    Result := 114;
  sclREGISTRY:                            /// <summary>SCLEX_REGISTRY = 115
    Result := 115;
  sclBIBTEX:                              /// <summary>SCLEX_BIBTEX = 116
    Result := 116;
  sclSREC:                                /// <summary>SCLEX_SREC = 117
    Result := 117;
  sclIHEX:                                /// <summary>SCLEX_IHEX = 118
    Result := 118;
  sclTEHEX:                               /// <summary>SCLEX_TEHEX = 119
    Result := 119;
  sclJSON:                                /// <summary>SCLEX_JSON = 120
    Result := 120;
  sclEDIFACT:                             /// <summary>SCLEX_EDIFACT = 121
    Result := 121;
  sclINDENT:                              /// <summary>SCLEX_INDENT = 122
    Result := 122;
  sclMAXIMA:                              /// <summary>SCLEX_MAXIMA = 123
    Result := 123;
  sclSTATA:                               /// <summary>SCLEX_STATA = 124
    Result := 124;
  sclSAS:                                 /// <summary>SCLEX_SAS = 125
    Result := 125;
  sclNIM:                                 /// <summary>SCLEX_NIM = 126
    Result := 126;
  sclCIL:                                 /// <summary>SCLEX_CIL = 127
    Result := 127;
  sclX12:                                 /// <summary>SCLEX_X12 = 128
    Result := 128;
  sclDATAFLEX:                            /// <summary>SCLEX_DATAFLEX = 129
    Result := 129;
  sclHOLLYWOOD:                           /// <summary>SCLEX_HOLLYWOOD = 130
    Result := 130;
  sclRAKU:                                /// <summary>SCLEX_RAKU = 131
    Result := 131;
  sclFSHARP:                              /// <summary>SCLEX_FSHARP = 132
    Result := 132;
  sclJULIA:                               /// <summary>SCLEX_JULIA = 133
    Result := 133;
  sclASCIIDOC:                            /// <summary>SCLEX_ASCIIDOC = 134
    Result := 134;
  sclGDSCRIPT:                            /// <summary>SCLEX_GDSCRIPT = 135
    Result := 135;
  sclTOML:                                /// <summary>SCLEX_TOML = 136
    Result := 136;
  sclTROFF:                               /// <summary>SCLEX_TROFF = 137
    Result := 137;
  sclDART:                                /// <summary>SCLEX_DART = 138
    Result := 138;
  sclZIG:                                 /// <summary>SCLEX_ZIG = 139
    Result := 139;
  sclNIX:                                 /// <summary>SCLEX_NIX = 140
    Result := 140;
  sclSINEX:                               /// <summary>SCLEX_SINEX = 141
    Result := 141;
  sclESCSEQ:                              /// <summary>SCLEX_ESCSEQ = 142
    Result := 142;
  sclAUTOMATIC:                           /// <summary>SCLEX_AUTOMATIC = 1000
    Result := 1000;
  else
    Result := 0;
  end;
end;

function TDSciLexerIdFromInt(AEnum: Integer): TDSciLexerId;
begin
  case AEnum of
  0:
    Result := sclCONTAINER;                           /// <summary>SCLEX_CONTAINER = 0
  1:
    Result := sclNULL;                                /// <summary>SCLEX_NULL = 1
  2:
    Result := sclPYTHON;                              /// <summary>SCLEX_PYTHON = 2
  3:
    Result := sclCPP;                                 /// <summary>SCLEX_CPP = 3
  4:
    Result := sclHTML;                                /// <summary>SCLEX_HTML = 4
  5:
    Result := sclXML;                                 /// <summary>SCLEX_XML = 5
  6:
    Result := sclPERL;                                /// <summary>SCLEX_PERL = 6
  7:
    Result := sclSQL;                                 /// <summary>SCLEX_SQL = 7
  8:
    Result := sclVB;                                  /// <summary>SCLEX_VB = 8
  9:
    Result := sclPROPERTIES;                          /// <summary>SCLEX_PROPERTIES = 9
  10:
    Result := sclERRORLIST;                           /// <summary>SCLEX_ERRORLIST = 10
  11:
    Result := sclMAKEFILE;                            /// <summary>SCLEX_MAKEFILE = 11
  12:
    Result := sclBATCH;                               /// <summary>SCLEX_BATCH = 12
  13:
    Result := sclXCODE;                               /// <summary>SCLEX_XCODE = 13
  14:
    Result := sclLATEX;                               /// <summary>SCLEX_LATEX = 14
  15:
    Result := sclLUA;                                 /// <summary>SCLEX_LUA = 15
  16:
    Result := sclDIFF;                                /// <summary>SCLEX_DIFF = 16
  17:
    Result := sclCONF;                                /// <summary>SCLEX_CONF = 17
  18:
    Result := sclPASCAL;                              /// <summary>SCLEX_PASCAL = 18
  19:
    Result := sclAVE;                                 /// <summary>SCLEX_AVE = 19
  20:
    Result := sclADA;                                 /// <summary>SCLEX_ADA = 20
  21:
    Result := sclLISP;                                /// <summary>SCLEX_LISP = 21
  22:
    Result := sclRUBY;                                /// <summary>SCLEX_RUBY = 22
  23:
    Result := sclEIFFEL;                              /// <summary>SCLEX_EIFFEL = 23
  24:
    Result := sclEIFFELKW;                            /// <summary>SCLEX_EIFFELKW = 24
  25:
    Result := sclTCL;                                 /// <summary>SCLEX_TCL = 25
  26:
    Result := sclNNCRONTAB;                           /// <summary>SCLEX_NNCRONTAB = 26
  27:
    Result := sclBULLANT;                             /// <summary>SCLEX_BULLANT = 27
  28:
    Result := sclVBSCRIPT;                            /// <summary>SCLEX_VBSCRIPT = 28
  31:
    Result := sclBAAN;                                /// <summary>SCLEX_BAAN = 31
  32:
    Result := sclMATLAB;                              /// <summary>SCLEX_MATLAB = 32
  33:
    Result := sclSCRIPTOL;                            /// <summary>SCLEX_SCRIPTOL = 33
  34:
    Result := sclASM;                                 /// <summary>SCLEX_ASM = 34
  35:
    Result := sclCPPNOCASE;                           /// <summary>SCLEX_CPPNOCASE = 35
  36:
    Result := sclFORTRAN;                             /// <summary>SCLEX_FORTRAN = 36
  37:
    Result := sclF77;                                 /// <summary>SCLEX_F77 = 37
  38:
    Result := sclCSS;                                 /// <summary>SCLEX_CSS = 38
  39:
    Result := sclPOV;                                 /// <summary>SCLEX_POV = 39
  40:
    Result := sclLOUT;                                /// <summary>SCLEX_LOUT = 40
  41:
    Result := sclESCRIPT;                             /// <summary>SCLEX_ESCRIPT = 41
  42:
    Result := sclPS;                                  /// <summary>SCLEX_PS = 42
  43:
    Result := sclNSIS;                                /// <summary>SCLEX_NSIS = 43
  44:
    Result := sclMMIXAL;                              /// <summary>SCLEX_MMIXAL = 44
  45:
    Result := sclCLW;                                 /// <summary>SCLEX_CLW = 45
  46:
    Result := sclCLWNOCASE;                           /// <summary>SCLEX_CLWNOCASE = 46
  47:
    Result := sclLOT;                                 /// <summary>SCLEX_LOT = 47
  48:
    Result := sclYAML;                                /// <summary>SCLEX_YAML = 48
  49:
    Result := sclTEX;                                 /// <summary>SCLEX_TEX = 49
  50:
    Result := sclMETAPOST;                            /// <summary>SCLEX_METAPOST = 50
  51:
    Result := sclPOWERBASIC;                          /// <summary>SCLEX_POWERBASIC = 51
  52:
    Result := sclFORTH;                               /// <summary>SCLEX_FORTH = 52
  53:
    Result := sclERLANG;                              /// <summary>SCLEX_ERLANG = 53
  54:
    Result := sclOCTAVE;                              /// <summary>SCLEX_OCTAVE = 54
  55:
    Result := sclMSSQL;                               /// <summary>SCLEX_MSSQL = 55
  56:
    Result := sclVERILOG;                             /// <summary>SCLEX_VERILOG = 56
  57:
    Result := sclKIX;                                 /// <summary>SCLEX_KIX = 57
  58:
    Result := sclGUI4CLI;                             /// <summary>SCLEX_GUI4CLI = 58
  59:
    Result := sclSPECMAN;                             /// <summary>SCLEX_SPECMAN = 59
  60:
    Result := sclAU3;                                 /// <summary>SCLEX_AU3 = 60
  61:
    Result := sclAPDL;                                /// <summary>SCLEX_APDL = 61
  62:
    Result := sclBASH;                                /// <summary>SCLEX_BASH = 62
  63:
    Result := sclASN1;                                /// <summary>SCLEX_ASN1 = 63
  64:
    Result := sclVHDL;                                /// <summary>SCLEX_VHDL = 64
  65:
    Result := sclCAML;                                /// <summary>SCLEX_CAML = 65
  66:
    Result := sclBLITZBASIC;                          /// <summary>SCLEX_BLITZBASIC = 66
  67:
    Result := sclPUREBASIC;                           /// <summary>SCLEX_PUREBASIC = 67
  68:
    Result := sclHASKELL;                             /// <summary>SCLEX_HASKELL = 68
  69:
    Result := sclPHPSCRIPT;                           /// <summary>SCLEX_PHPSCRIPT = 69
  70:
    Result := sclTADS3;                               /// <summary>SCLEX_TADS3 = 70
  71:
    Result := sclREBOL;                               /// <summary>SCLEX_REBOL = 71
  72:
    Result := sclSMALLTALK;                           /// <summary>SCLEX_SMALLTALK = 72
  73:
    Result := sclFLAGSHIP;                            /// <summary>SCLEX_FLAGSHIP = 73
  74:
    Result := sclCSOUND;                              /// <summary>SCLEX_CSOUND = 74
  75:
    Result := sclFREEBASIC;                           /// <summary>SCLEX_FREEBASIC = 75
  76:
    Result := sclINNOSETUP;                           /// <summary>SCLEX_INNOSETUP = 76
  77:
    Result := sclOPAL;                                /// <summary>SCLEX_OPAL = 77
  78:
    Result := sclSPICE;                               /// <summary>SCLEX_SPICE = 78
  79:
    Result := sclD;                                   /// <summary>SCLEX_D = 79
  80:
    Result := sclCMAKE;                               /// <summary>SCLEX_CMAKE = 80
  81:
    Result := sclGAP;                                 /// <summary>SCLEX_GAP = 81
  82:
    Result := sclPLM;                                 /// <summary>SCLEX_PLM = 82
  83:
    Result := sclPROGRESS;                            /// <summary>SCLEX_PROGRESS = 83
  84:
    Result := sclABAQUS;                              /// <summary>SCLEX_ABAQUS = 84
  85:
    Result := sclASYMPTOTE;                           /// <summary>SCLEX_ASYMPTOTE = 85
  86:
    Result := sclR;                                   /// <summary>SCLEX_R = 86
  87:
    Result := sclMAGIK;                               /// <summary>SCLEX_MAGIK = 87
  88:
    Result := sclPOWERSHELL;                          /// <summary>SCLEX_POWERSHELL = 88
  89:
    Result := sclMYSQL;                               /// <summary>SCLEX_MYSQL = 89
  90:
    Result := sclPO;                                  /// <summary>SCLEX_PO = 90
  91:
    Result := sclTAL;                                 /// <summary>SCLEX_TAL = 91
  92:
    Result := sclCOBOL;                               /// <summary>SCLEX_COBOL = 92
  93:
    Result := sclTACL;                                /// <summary>SCLEX_TACL = 93
  94:
    Result := sclSORCUS;                              /// <summary>SCLEX_SORCUS = 94
  95:
    Result := sclPOWERPRO;                            /// <summary>SCLEX_POWERPRO = 95
  96:
    Result := sclNIMROD;                              /// <summary>SCLEX_NIMROD = 96
  97:
    Result := sclSML;                                 /// <summary>SCLEX_SML = 97
  98:
    Result := sclMARKDOWN;                            /// <summary>SCLEX_MARKDOWN = 98
  99:
    Result := sclTXT2TAGS;                            /// <summary>SCLEX_TXT2TAGS = 99
  100:
    Result := sclA68K;                                /// <summary>SCLEX_A68K = 100
  101:
    Result := sclMODULA;                              /// <summary>SCLEX_MODULA = 101
  102:
    Result := sclCOFFEESCRIPT;                        /// <summary>SCLEX_COFFEESCRIPT = 102
  103:
    Result := sclTCMD;                                /// <summary>SCLEX_TCMD = 103
  104:
    Result := sclAVS;                                 /// <summary>SCLEX_AVS = 104
  105:
    Result := sclECL;                                 /// <summary>SCLEX_ECL = 105
  106:
    Result := sclOSCRIPT;                             /// <summary>SCLEX_OSCRIPT = 106
  107:
    Result := sclVISUALPROLOG;                        /// <summary>SCLEX_VISUALPROLOG = 107
  108:
    Result := sclLITERATEHASKELL;                     /// <summary>SCLEX_LITERATEHASKELL = 108
  109:
    Result := sclSTTXT;                               /// <summary>SCLEX_STTXT = 109
  110:
    Result := sclKVIRC;                               /// <summary>SCLEX_KVIRC = 110
  111:
    Result := sclRUST;                                /// <summary>SCLEX_RUST = 111
  112:
    Result := sclDMAP;                                /// <summary>SCLEX_DMAP = 112
  113:
    Result := sclAS;                                  /// <summary>SCLEX_AS = 113
  114:
    Result := sclDMIS;                                /// <summary>SCLEX_DMIS = 114
  115:
    Result := sclREGISTRY;                            /// <summary>SCLEX_REGISTRY = 115
  116:
    Result := sclBIBTEX;                              /// <summary>SCLEX_BIBTEX = 116
  117:
    Result := sclSREC;                                /// <summary>SCLEX_SREC = 117
  118:
    Result := sclIHEX;                                /// <summary>SCLEX_IHEX = 118
  119:
    Result := sclTEHEX;                               /// <summary>SCLEX_TEHEX = 119
  120:
    Result := sclJSON;                                /// <summary>SCLEX_JSON = 120
  121:
    Result := sclEDIFACT;                             /// <summary>SCLEX_EDIFACT = 121
  122:
    Result := sclINDENT;                              /// <summary>SCLEX_INDENT = 122
  123:
    Result := sclMAXIMA;                              /// <summary>SCLEX_MAXIMA = 123
  124:
    Result := sclSTATA;                               /// <summary>SCLEX_STATA = 124
  125:
    Result := sclSAS;                                 /// <summary>SCLEX_SAS = 125
  126:
    Result := sclNIM;                                 /// <summary>SCLEX_NIM = 126
  127:
    Result := sclCIL;                                 /// <summary>SCLEX_CIL = 127
  128:
    Result := sclX12;                                 /// <summary>SCLEX_X12 = 128
  129:
    Result := sclDATAFLEX;                            /// <summary>SCLEX_DATAFLEX = 129
  130:
    Result := sclHOLLYWOOD;                           /// <summary>SCLEX_HOLLYWOOD = 130
  131:
    Result := sclRAKU;                                /// <summary>SCLEX_RAKU = 131
  132:
    Result := sclFSHARP;                              /// <summary>SCLEX_FSHARP = 132
  133:
    Result := sclJULIA;                               /// <summary>SCLEX_JULIA = 133
  134:
    Result := sclASCIIDOC;                            /// <summary>SCLEX_ASCIIDOC = 134
  135:
    Result := sclGDSCRIPT;                            /// <summary>SCLEX_GDSCRIPT = 135
  136:
    Result := sclTOML;                                /// <summary>SCLEX_TOML = 136
  137:
    Result := sclTROFF;                               /// <summary>SCLEX_TROFF = 137
  138:
    Result := sclDART;                                /// <summary>SCLEX_DART = 138
  139:
    Result := sclZIG;                                 /// <summary>SCLEX_ZIG = 139
  140:
    Result := sclNIX;                                 /// <summary>SCLEX_NIX = 140
  141:
    Result := sclSINEX;                               /// <summary>SCLEX_SINEX = 141
  142:
    Result := sclESCSEQ;                              /// <summary>SCLEX_ESCSEQ = 142
  1000:
    Result := sclAUTOMATIC;                           /// <summary>SCLEX_AUTOMATIC = 1000
  else
    Result := sclCONTAINER;                           /// <summary>SCLEX_CONTAINER = 0;
  end;
end;


// </scigen-enum-func-code>


end.



