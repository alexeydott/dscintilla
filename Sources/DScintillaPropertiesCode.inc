function TDScintilla.GetLength: NativeInt;
begin
  Result := SendEditor(SCI_GETLENGTH, 0, 0);
end;

function TDScintilla.GetCharAt(APos: NativeInt): Integer;
begin
  Result := SendEditor(SCI_GETCHARAT, WPARAM(APos), 0);
end;

function TDScintilla.GetCurrentPos: NativeInt;
begin
  Result := SendEditor(SCI_GETCURRENTPOS, 0, 0);
end;

function TDScintilla.GetAnchor: NativeInt;
begin
  Result := SendEditor(SCI_GETANCHOR, 0, 0);
end;

function TDScintilla.GetStyleAt(APos: NativeInt): Integer;
begin
  Result := SendEditor(SCI_GETSTYLEAT, WPARAM(APos), 0);
end;

function TDScintilla.GetStyleIndexAt(APos: NativeInt): Integer;
begin
  Result := SendEditor(SCI_GETSTYLEINDEXAT, WPARAM(APos), 0);
end;

procedure TDScintilla.SetUndoCollection(ACollectUndo: Boolean);
begin
  SendEditor(SCI_SETUNDOCOLLECTION, WPARAM(Ord(ACollectUndo)), 0);
end;

function TDScintilla.GetUndoCollection: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETUNDOCOLLECTION, 0, 0));
end;

function TDScintilla.GetViewWS: TDSciWhiteSpace;
begin
  Result := TDSciWhiteSpaceFromInt(SendEditor(SCI_GETVIEWWS, 0, 0));
end;

procedure TDScintilla.SetViewWS(AViewWS: TDSciWhiteSpace);
begin
  SendEditor(SCI_SETVIEWWS, WPARAM(TDSciWhiteSpaceToInt(AViewWS)), 0);
end;

function TDScintilla.GetTabDrawMode: TDSciTabDrawMode;
begin
  Result := TDSciTabDrawModeFromInt(SendEditor(SCI_GETTABDRAWMODE, 0, 0));
end;

procedure TDScintilla.SetTabDrawMode(ATabDrawMode: TDSciTabDrawMode);
begin
  SendEditor(SCI_SETTABDRAWMODE, WPARAM(TDSciTabDrawModeToInt(ATabDrawMode)), 0);
end;

procedure TDScintilla.SetAnchor(AAnchor: NativeInt);
begin
  SendEditor(SCI_SETANCHOR, WPARAM(AAnchor), 0);
end;

function TDScintilla.GetEndStyled: NativeInt;
begin
  Result := SendEditor(SCI_GETENDSTYLED, 0, 0);
end;

function TDScintilla.GetEOLMode: TDSciEndOfLine;
begin
  Result := TDSciEndOfLineFromInt(SendEditor(SCI_GETEOLMODE, 0, 0));
end;

procedure TDScintilla.SetEOLMode(AEolMode: TDSciEndOfLine);
begin
  SendEditor(SCI_SETEOLMODE, WPARAM(TDSciEndOfLineToInt(AEolMode)), 0);
end;

function TDScintilla.GetBufferedDraw: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETBUFFEREDDRAW, 0, 0));
end;

procedure TDScintilla.SetBufferedDraw(ABuffered: Boolean);
begin
  SendEditor(SCI_SETBUFFEREDDRAW, WPARAM(Ord(ABuffered)), 0);
end;

procedure TDScintilla.SetTabWidth(ATabWidth: Integer);
begin
  SendEditor(SCI_SETTABWIDTH, WPARAM(ATabWidth), 0);
end;

function TDScintilla.GetTabWidth: Integer;
begin
  Result := SendEditor(SCI_GETTABWIDTH, 0, 0);
end;

procedure TDScintilla.SetTabMinimumWidth(APixels: Integer);
begin
  SendEditor(SCI_SETTABMINIMUMWIDTH, WPARAM(APixels), 0);
end;

function TDScintilla.GetTabMinimumWidth: Integer;
begin
  Result := SendEditor(SCI_GETTABMINIMUMWIDTH, 0, 0);
end;

procedure TDScintilla.SetCodePage(ACodePage: Integer);
begin
  SendEditor(SCI_SETCODEPAGE, WPARAM(ACodePage), 0);
end;

procedure TDScintilla.SetFontLocale(const ALocaleName: UnicodeString);
begin
  FHelper.SetText(SCI_SETFONTLOCALE, 0, ALocaleName);
end;
function TDScintilla.GetFontLocale: UnicodeString;
begin
  FHelper.GetText(SCI_GETFONTLOCALE, 0, Result);
end;
function TDScintilla.GetIMEInteraction: TDSciIMEInteraction;
begin
  Result := TDSciIMEInteractionFromInt(SendEditor(SCI_GETIMEINTERACTION, 0, 0));
end;

procedure TDScintilla.SetIMEInteraction(AImeInteraction: TDSciIMEInteraction);
begin
  SendEditor(SCI_SETIMEINTERACTION, WPARAM(TDSciIMEInteractionToInt(AImeInteraction)), 0);
end;

procedure TDScintilla.MarkerSetFore(AMarkerNumber: Integer; AFore: TColor);
begin
  SendEditor(SCI_MARKERSETFORE, WPARAM(AMarkerNumber), LPARAM(Integer(AFore)));
end;

procedure TDScintilla.MarkerSetBack(AMarkerNumber: Integer; ABack: TColor);
begin
  SendEditor(SCI_MARKERSETBACK, WPARAM(AMarkerNumber), LPARAM(Integer(ABack)));
end;

procedure TDScintilla.MarkerSetBackSelected(AMarkerNumber: Integer; ABack: TColor);
begin
  SendEditor(SCI_MARKERSETBACKSELECTED, WPARAM(AMarkerNumber), LPARAM(Integer(ABack)));
end;

procedure TDScintilla.MarkerSetForeTranslucent(AMarkerNumber: Integer; AFore: TDSciColourAlpha);
begin
  SendEditor(SCI_MARKERSETFORETRANSLUCENT, WPARAM(AMarkerNumber), LPARAM(Integer(AFore)));
end;

procedure TDScintilla.MarkerSetBackTranslucent(AMarkerNumber: Integer; ABack: TDSciColourAlpha);
begin
  SendEditor(SCI_MARKERSETBACKTRANSLUCENT, WPARAM(AMarkerNumber), LPARAM(Integer(ABack)));
end;

procedure TDScintilla.MarkerSetBackSelectedTranslucent(AMarkerNumber: Integer; ABack: TDSciColourAlpha);
begin
  SendEditor(SCI_MARKERSETBACKSELECTEDTRANSLUCENT, WPARAM(AMarkerNumber), LPARAM(Integer(ABack)));
end;

procedure TDScintilla.MarkerSetStrokeWidth(AMarkerNumber: Integer; AHundredths: Integer);
begin
  SendEditor(SCI_MARKERSETSTROKEWIDTH, WPARAM(AMarkerNumber), LPARAM(AHundredths));
end;

procedure TDScintilla.MarkerSetAlpha(AMarkerNumber: Integer; AAlpha: TDSciAlpha);
begin
  SendEditor(SCI_MARKERSETALPHA, WPARAM(AMarkerNumber), LPARAM(TDSciAlphaToInt(AAlpha)));
end;

function TDScintilla.MarkerGetLayer(AMarkerNumber: Integer): TDSciLayer;
begin
  Result := TDSciLayerFromInt(SendEditor(SCI_MARKERGETLAYER, WPARAM(AMarkerNumber), 0));
end;

procedure TDScintilla.MarkerSetLayer(AMarkerNumber: Integer; ALayer: TDSciLayer);
begin
  SendEditor(SCI_MARKERSETLAYER, WPARAM(AMarkerNumber), LPARAM(TDSciLayerToInt(ALayer)));
end;

procedure TDScintilla.SetMarginTypeN(AMargin: Integer; AMarginType: TDSciMarginType);
begin
  SendEditor(SCI_SETMARGINTYPEN, WPARAM(AMargin), LPARAM(TDSciMarginTypeToInt(AMarginType)));
end;

function TDScintilla.GetMarginTypeN(AMargin: Integer): TDSciMarginType;
begin
  Result := TDSciMarginTypeFromInt(SendEditor(SCI_GETMARGINTYPEN, WPARAM(AMargin), 0));
end;

procedure TDScintilla.SetMarginWidthN(AMargin: Integer; APixelWidth: Integer);
begin
  SendEditor(SCI_SETMARGINWIDTHN, WPARAM(AMargin), LPARAM(APixelWidth));
end;

function TDScintilla.GetMarginWidthN(AMargin: Integer): Integer;
begin
  Result := SendEditor(SCI_GETMARGINWIDTHN, WPARAM(AMargin), 0);
end;

procedure TDScintilla.SetMarginMaskN(AMargin: Integer; AMask: Integer);
begin
  SendEditor(SCI_SETMARGINMASKN, WPARAM(AMargin), LPARAM(AMask));
end;

function TDScintilla.GetMarginMaskN(AMargin: Integer): Integer;
begin
  Result := SendEditor(SCI_GETMARGINMASKN, WPARAM(AMargin), 0);
end;

procedure TDScintilla.SetMarginSensitiveN(AMargin: Integer; ASensitive: Boolean);
begin
  SendEditor(SCI_SETMARGINSENSITIVEN, WPARAM(AMargin), LPARAM(Ord(ASensitive)));
end;

function TDScintilla.GetMarginSensitiveN(AMargin: Integer): Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETMARGINSENSITIVEN, WPARAM(AMargin), 0));
end;

procedure TDScintilla.SetMarginCursorN(AMargin: Integer; ACursor: TDSciCursorShape);
begin
  SendEditor(SCI_SETMARGINCURSORN, WPARAM(AMargin), LPARAM(TDSciCursorShapeToInt(ACursor)));
end;

function TDScintilla.GetMarginCursorN(AMargin: Integer): TDSciCursorShape;
begin
  Result := TDSciCursorShapeFromInt(SendEditor(SCI_GETMARGINCURSORN, WPARAM(AMargin), 0));
end;

procedure TDScintilla.SetMarginBackN(AMargin: Integer; ABack: TColor);
begin
  SendEditor(SCI_SETMARGINBACKN, WPARAM(AMargin), LPARAM(Integer(ABack)));
end;

function TDScintilla.GetMarginBackN(AMargin: Integer): TColor;
begin
  Result := TColor(SendEditor(SCI_GETMARGINBACKN, WPARAM(AMargin), 0));
end;

procedure TDScintilla.SetMargins(AMargins: Integer);
begin
  SendEditor(SCI_SETMARGINS, WPARAM(AMargins), 0);
end;

function TDScintilla.GetMargins: Integer;
begin
  Result := SendEditor(SCI_GETMARGINS, 0, 0);
end;

procedure TDScintilla.StyleSetFore(AStyle: Integer; AFore: TColor);
begin
  SendEditor(SCI_STYLESETFORE, WPARAM(AStyle), LPARAM(Integer(AFore)));
end;

procedure TDScintilla.StyleSetBack(AStyle: Integer; ABack: TColor);
begin
  SendEditor(SCI_STYLESETBACK, WPARAM(AStyle), LPARAM(Integer(ABack)));
end;

procedure TDScintilla.StyleSetBold(AStyle: Integer; ABold: Boolean);
begin
  SendEditor(SCI_STYLESETBOLD, WPARAM(AStyle), LPARAM(Ord(ABold)));
end;

procedure TDScintilla.StyleSetItalic(AStyle: Integer; AItalic: Boolean);
begin
  SendEditor(SCI_STYLESETITALIC, WPARAM(AStyle), LPARAM(Ord(AItalic)));
end;

procedure TDScintilla.StyleSetSize(AStyle: Integer; ASizePoints: Integer);
begin
  SendEditor(SCI_STYLESETSIZE, WPARAM(AStyle), LPARAM(ASizePoints));
end;

procedure TDScintilla.StyleSetFont(AStyle: Integer; const AFontName: UnicodeString);
begin
  SendEditor(SCI_STYLESETFONT, AStyle, LPARAM(AnsiString(AFontName)));
end;

procedure TDScintilla.StyleSetEOLFilled(AStyle: Integer; AEolFilled: Boolean);
begin
  SendEditor(SCI_STYLESETEOLFILLED, WPARAM(AStyle), LPARAM(Ord(AEolFilled)));
end;

procedure TDScintilla.StyleSetUnderline(AStyle: Integer; AUnderline: Boolean);
begin
  SendEditor(SCI_STYLESETUNDERLINE, WPARAM(AStyle), LPARAM(Ord(AUnderline)));
end;

function TDScintilla.StyleGetFore(AStyle: Integer): TColor;
begin
  Result := TColor(SendEditor(SCI_STYLEGETFORE, WPARAM(AStyle), 0));
end;

function TDScintilla.StyleGetBack(AStyle: Integer): TColor;
begin
  Result := TColor(SendEditor(SCI_STYLEGETBACK, WPARAM(AStyle), 0));
end;

function TDScintilla.StyleGetBold(AStyle: Integer): Boolean;
begin
  Result := Boolean(SendEditor(SCI_STYLEGETBOLD, WPARAM(AStyle), 0));
end;

function TDScintilla.StyleGetItalic(AStyle: Integer): Boolean;
begin
  Result := Boolean(SendEditor(SCI_STYLEGETITALIC, WPARAM(AStyle), 0));
end;

function TDScintilla.StyleGetSize(AStyle: Integer): Integer;
begin
  Result := SendEditor(SCI_STYLEGETSIZE, WPARAM(AStyle), 0);
end;

function TDScintilla.StyleGetFont(AStyle: Integer): UnicodeString;
begin
  FHelper.GetText(SCI_STYLEGETFONT, AStyle, Result);
end;

function TDScintilla.StyleGetEOLFilled(AStyle: Integer): Boolean;
begin
  Result := Boolean(SendEditor(SCI_STYLEGETEOLFILLED, WPARAM(AStyle), 0));
end;

function TDScintilla.StyleGetUnderline(AStyle: Integer): Boolean;
begin
  Result := Boolean(SendEditor(SCI_STYLEGETUNDERLINE, WPARAM(AStyle), 0));
end;

function TDScintilla.StyleGetCase(AStyle: Integer): TDSciCaseVisible;
begin
  Result := TDSciCaseVisibleFromInt(SendEditor(SCI_STYLEGETCASE, WPARAM(AStyle), 0));
end;

function TDScintilla.StyleGetCharacterSet(AStyle: Integer): TDSciCharacterSet;
begin
  Result := TDSciCharacterSetFromInt(SendEditor(SCI_STYLEGETCHARACTERSET, WPARAM(AStyle), 0));
end;

function TDScintilla.StyleGetVisible(AStyle: Integer): Boolean;
begin
  Result := Boolean(SendEditor(SCI_STYLEGETVISIBLE, WPARAM(AStyle), 0));
end;

function TDScintilla.StyleGetChangeable(AStyle: Integer): Boolean;
begin
  Result := Boolean(SendEditor(SCI_STYLEGETCHANGEABLE, WPARAM(AStyle), 0));
end;

function TDScintilla.StyleGetHotSpot(AStyle: Integer): Boolean;
begin
  Result := Boolean(SendEditor(SCI_STYLEGETHOTSPOT, WPARAM(AStyle), 0));
end;

procedure TDScintilla.StyleSetCase(AStyle: Integer; ACaseVisible: TDSciCaseVisible);
begin
  SendEditor(SCI_STYLESETCASE, WPARAM(AStyle), LPARAM(TDSciCaseVisibleToInt(ACaseVisible)));
end;

procedure TDScintilla.StyleSetSizeFractional(AStyle: Integer; ASizeHundredthPoints: Integer);
begin
  SendEditor(SCI_STYLESETSIZEFRACTIONAL, WPARAM(AStyle), LPARAM(ASizeHundredthPoints));
end;

function TDScintilla.StyleGetSizeFractional(AStyle: Integer): Integer;
begin
  Result := SendEditor(SCI_STYLEGETSIZEFRACTIONAL, WPARAM(AStyle), 0);
end;

procedure TDScintilla.StyleSetWeight(AStyle: Integer; AWeight: TDSciFontWeight);
begin
  SendEditor(SCI_STYLESETWEIGHT, WPARAM(AStyle), LPARAM(TDSciFontWeightToInt(AWeight)));
end;

function TDScintilla.StyleGetWeight(AStyle: Integer): TDSciFontWeight;
begin
  Result := TDSciFontWeightFromInt(SendEditor(SCI_STYLEGETWEIGHT, WPARAM(AStyle), 0));
end;

procedure TDScintilla.StyleSetCharacterSet(AStyle: Integer; ACharacterSet: TDSciCharacterSet);
begin
  SendEditor(SCI_STYLESETCHARACTERSET, WPARAM(AStyle), LPARAM(TDSciCharacterSetToInt(ACharacterSet)));
end;

procedure TDScintilla.StyleSetHotSpot(AStyle: Integer; AHotspot: Boolean);
begin
  SendEditor(SCI_STYLESETHOTSPOT, WPARAM(AStyle), LPARAM(Ord(AHotspot)));
end;

procedure TDScintilla.StyleSetCheckMonospaced(AStyle: Integer; ACheckMonospaced: Boolean);
begin
  SendEditor(SCI_STYLESETCHECKMONOSPACED, WPARAM(AStyle), LPARAM(Ord(ACheckMonospaced)));
end;

function TDScintilla.StyleGetCheckMonospaced(AStyle: Integer): Boolean;
begin
  Result := Boolean(SendEditor(SCI_STYLEGETCHECKMONOSPACED, WPARAM(AStyle), 0));
end;

procedure TDScintilla.StyleSetStretch(AStyle: Integer; AStretch: TDSciFontStretch);
begin
  SendEditor(SCI_STYLESETSTRETCH, WPARAM(AStyle), LPARAM(TDSciFontStretchToInt(AStretch)));
end;

function TDScintilla.StyleGetStretch(AStyle: Integer): TDSciFontStretch;
begin
  Result := TDSciFontStretchFromInt(SendEditor(SCI_STYLEGETSTRETCH, WPARAM(AStyle), 0));
end;

procedure TDScintilla.StyleSetInvisibleRepresentation(AStyle: Integer; const ARepresentation: UnicodeString);
begin
  FHelper.SetText(SCI_STYLESETINVISIBLEREPRESENTATION, AStyle, ARepresentation);
end;
function TDScintilla.StyleGetInvisibleRepresentation(AStyle: Integer): UnicodeString;
begin
  FHelper.GetText(SCI_STYLEGETINVISIBLEREPRESENTATION, AStyle, Result);
end;
procedure TDScintilla.SetElementColour(AElement: TDSciElement; AColourElement: TDSciColourAlpha);
begin
  SendEditor(SCI_SETELEMENTCOLOUR, WPARAM(TDSciElementToInt(AElement)), LPARAM(Integer(AColourElement)));
end;

function TDScintilla.GetElementColour(AElement: TDSciElement): TDSciColourAlpha;
begin
  Result := TDSciColourAlpha(Integer(SendEditor(SCI_GETELEMENTCOLOUR, WPARAM(TDSciElementToInt(AElement)), 0)));
end;

function TDScintilla.GetElementIsSet(AElement: TDSciElement): Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETELEMENTISSET, WPARAM(TDSciElementToInt(AElement)), 0));
end;

function TDScintilla.GetElementAllowsTranslucent(AElement: TDSciElement): Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETELEMENTALLOWSTRANSLUCENT, WPARAM(TDSciElementToInt(AElement)), 0));
end;

function TDScintilla.GetElementBaseColour(AElement: TDSciElement): TDSciColourAlpha;
begin
  Result := TDSciColourAlpha(Integer(SendEditor(SCI_GETELEMENTBASECOLOUR, WPARAM(TDSciElementToInt(AElement)), 0)));
end;

function TDScintilla.GetSelAlpha: TDSciAlpha;
begin
  Result := TDSciAlphaFromInt(SendEditor(SCI_GETSELALPHA, 0, 0));
end;

procedure TDScintilla.SetSelAlpha(AAlpha: TDSciAlpha);
begin
  SendEditor(SCI_SETSELALPHA, WPARAM(TDSciAlphaToInt(AAlpha)), 0);
end;

function TDScintilla.GetSelEOLFilled: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETSELEOLFILLED, 0, 0));
end;

procedure TDScintilla.SetSelEOLFilled(AFilled: Boolean);
begin
  SendEditor(SCI_SETSELEOLFILLED, WPARAM(Ord(AFilled)), 0);
end;

function TDScintilla.GetSelectionLayer: TDSciLayer;
begin
  Result := TDSciLayerFromInt(SendEditor(SCI_GETSELECTIONLAYER, 0, 0));
end;

procedure TDScintilla.SetSelectionLayer(ALayer: TDSciLayer);
begin
  SendEditor(SCI_SETSELECTIONLAYER, WPARAM(TDSciLayerToInt(ALayer)), 0);
end;

function TDScintilla.GetCaretLineLayer: TDSciLayer;
begin
  Result := TDSciLayerFromInt(SendEditor(SCI_GETCARETLINELAYER, 0, 0));
end;

procedure TDScintilla.SetCaretLineLayer(ALayer: TDSciLayer);
begin
  SendEditor(SCI_SETCARETLINELAYER, WPARAM(TDSciLayerToInt(ALayer)), 0);
end;

function TDScintilla.GetCaretLineHighlightSubLine: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETCARETLINEHIGHLIGHTSUBLINE, 0, 0));
end;

procedure TDScintilla.SetCaretLineHighlightSubLine(ASubLine: Boolean);
begin
  SendEditor(SCI_SETCARETLINEHIGHLIGHTSUBLINE, WPARAM(Ord(ASubLine)), 0);
end;

procedure TDScintilla.SetCaretFore(AFore: TColor);
begin
  SendEditor(SCI_SETCARETFORE, WPARAM(Integer(AFore)), 0);
end;

procedure TDScintilla.StyleSetVisible(AStyle: Integer; AVisible: Boolean);
begin
  SendEditor(SCI_STYLESETVISIBLE, WPARAM(AStyle), LPARAM(Ord(AVisible)));
end;

function TDScintilla.GetCaretPeriod: Integer;
begin
  Result := SendEditor(SCI_GETCARETPERIOD, 0, 0);
end;

procedure TDScintilla.SetCaretPeriod(APeriodMilliseconds: Integer);
begin
  SendEditor(SCI_SETCARETPERIOD, WPARAM(APeriodMilliseconds), 0);
end;

procedure TDScintilla.SetWordChars(const ACharacters: AnsiString);
begin
  FHelper.SetTextA(SCI_SETWORDCHARS, 0, ACharacters);
end;

function TDScintilla.GetWordChars: AnsiString;
begin
  FHelper.GetTextA(SCI_GETWORDCHARS, 0, Result);
end;

procedure TDScintilla.SetCharacterCategoryOptimization(ACountCharacters: Integer);
begin
  SendEditor(SCI_SETCHARACTERCATEGORYOPTIMIZATION, WPARAM(ACountCharacters), 0);
end;

function TDScintilla.GetCharacterCategoryOptimization: Integer;
begin
  Result := SendEditor(SCI_GETCHARACTERCATEGORYOPTIMIZATION, 0, 0);
end;

function TDScintilla.GetUndoSequence: Integer;
begin
  Result := SendEditor(SCI_GETUNDOSEQUENCE, 0, 0);
end;

function TDScintilla.GetUndoActions: Integer;
begin
  Result := SendEditor(SCI_GETUNDOACTIONS, 0, 0);
end;

procedure TDScintilla.SetUndoSavePoint(AAction: Integer);
begin
  SendEditor(SCI_SETUNDOSAVEPOINT, WPARAM(AAction), 0);
end;

function TDScintilla.GetUndoSavePoint: Integer;
begin
  Result := SendEditor(SCI_GETUNDOSAVEPOINT, 0, 0);
end;

procedure TDScintilla.SetUndoDetach(AAction: Integer);
begin
  SendEditor(SCI_SETUNDODETACH, WPARAM(AAction), 0);
end;

function TDScintilla.GetUndoDetach: Integer;
begin
  Result := SendEditor(SCI_GETUNDODETACH, 0, 0);
end;

procedure TDScintilla.SetUndoTentative(AAction: Integer);
begin
  SendEditor(SCI_SETUNDOTENTATIVE, WPARAM(AAction), 0);
end;

function TDScintilla.GetUndoTentative: Integer;
begin
  Result := SendEditor(SCI_GETUNDOTENTATIVE, 0, 0);
end;

procedure TDScintilla.SetUndoCurrent(AAction: Integer);
begin
  SendEditor(SCI_SETUNDOCURRENT, WPARAM(AAction), 0);
end;

function TDScintilla.GetUndoCurrent: Integer;
begin
  Result := SendEditor(SCI_GETUNDOCURRENT, 0, 0);
end;

function TDScintilla.GetUndoActionType(AAction: Integer): Integer;
begin
  Result := SendEditor(SCI_GETUNDOACTIONTYPE, WPARAM(AAction), 0);
end;

function TDScintilla.GetUndoActionPosition(AAction: Integer): NativeInt;
begin
  Result := SendEditor(SCI_GETUNDOACTIONPOSITION, WPARAM(AAction), 0);
end;

function TDScintilla.GetUndoActionText(AAction: Integer): UnicodeString;
begin
  FHelper.GetText(SCI_GETUNDOACTIONTEXT, AAction, Result);
end;
procedure TDScintilla.IndicSetStyle(AIndicator: Integer; AIndicatorStyle: TDSciIndicatorStyle);
begin
  SendEditor(SCI_INDICSETSTYLE, WPARAM(AIndicator), LPARAM(TDSciIndicatorStyleToInt(AIndicatorStyle)));
end;

function TDScintilla.IndicGetStyle(AIndicator: Integer): TDSciIndicatorStyle;
begin
  Result := TDSciIndicatorStyleFromInt(SendEditor(SCI_INDICGETSTYLE, WPARAM(AIndicator), 0));
end;

procedure TDScintilla.IndicSetFore(AIndicator: Integer; AFore: TColor);
begin
  SendEditor(SCI_INDICSETFORE, WPARAM(AIndicator), LPARAM(Integer(AFore)));
end;

function TDScintilla.IndicGetFore(AIndicator: Integer): TColor;
begin
  Result := TColor(SendEditor(SCI_INDICGETFORE, WPARAM(AIndicator), 0));
end;

procedure TDScintilla.IndicSetUnder(AIndicator: Integer; AUnder: Boolean);
begin
  SendEditor(SCI_INDICSETUNDER, WPARAM(AIndicator), LPARAM(Ord(AUnder)));
end;

function TDScintilla.IndicGetUnder(AIndicator: Integer): Boolean;
begin
  Result := Boolean(SendEditor(SCI_INDICGETUNDER, WPARAM(AIndicator), 0));
end;

procedure TDScintilla.IndicSetHoverStyle(AIndicator: Integer; AIndicatorStyle: TDSciIndicatorStyle);
begin
  SendEditor(SCI_INDICSETHOVERSTYLE, WPARAM(AIndicator), LPARAM(TDSciIndicatorStyleToInt(AIndicatorStyle)));
end;

function TDScintilla.IndicGetHoverStyle(AIndicator: Integer): TDSciIndicatorStyle;
begin
  Result := TDSciIndicatorStyleFromInt(SendEditor(SCI_INDICGETHOVERSTYLE, WPARAM(AIndicator), 0));
end;

procedure TDScintilla.IndicSetHoverFore(AIndicator: Integer; AFore: TColor);
begin
  SendEditor(SCI_INDICSETHOVERFORE, WPARAM(AIndicator), LPARAM(Integer(AFore)));
end;

function TDScintilla.IndicGetHoverFore(AIndicator: Integer): TColor;
begin
  Result := TColor(SendEditor(SCI_INDICGETHOVERFORE, WPARAM(AIndicator), 0));
end;

procedure TDScintilla.IndicSetFlags(AIndicator: Integer; AFlags: TDSciIndicFlag);
begin
  SendEditor(SCI_INDICSETFLAGS, WPARAM(AIndicator), LPARAM(TDSciIndicFlagToInt(AFlags)));
end;

function TDScintilla.IndicGetFlags(AIndicator: Integer): TDSciIndicFlag;
begin
  Result := TDSciIndicFlagFromInt(SendEditor(SCI_INDICGETFLAGS, WPARAM(AIndicator), 0));
end;

procedure TDScintilla.IndicSetStrokeWidth(AIndicator: Integer; AHundredths: Integer);
begin
  SendEditor(SCI_INDICSETSTROKEWIDTH, WPARAM(AIndicator), LPARAM(AHundredths));
end;

function TDScintilla.IndicGetStrokeWidth(AIndicator: Integer): Integer;
begin
  Result := SendEditor(SCI_INDICGETSTROKEWIDTH, WPARAM(AIndicator), 0);
end;

procedure TDScintilla.SetWhitespaceSize(ASize: Integer);
begin
  SendEditor(SCI_SETWHITESPACESIZE, WPARAM(ASize), 0);
end;

function TDScintilla.GetWhitespaceSize: Integer;
begin
  Result := SendEditor(SCI_GETWHITESPACESIZE, 0, 0);
end;

procedure TDScintilla.SetLineState(ALine: NativeInt; AState: Integer);
begin
  SendEditor(SCI_SETLINESTATE, WPARAM(ALine), LPARAM(AState));
end;

function TDScintilla.GetLineState(ALine: NativeInt): Integer;
begin
  Result := SendEditor(SCI_GETLINESTATE, WPARAM(ALine), 0);
end;

function TDScintilla.GetMaxLineState: Integer;
begin
  Result := SendEditor(SCI_GETMAXLINESTATE, 0, 0);
end;

function TDScintilla.GetCaretLineVisible: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETCARETLINEVISIBLE, 0, 0));
end;

procedure TDScintilla.SetCaretLineVisible(AShow: Boolean);
begin
  SendEditor(SCI_SETCARETLINEVISIBLE, WPARAM(Ord(AShow)), 0);
end;

function TDScintilla.GetCaretLineBack: TColor;
begin
  Result := TColor(SendEditor(SCI_GETCARETLINEBACK, 0, 0));
end;

procedure TDScintilla.SetCaretLineBack(ABack: TColor);
begin
  SendEditor(SCI_SETCARETLINEBACK, WPARAM(Integer(ABack)), 0);
end;

function TDScintilla.GetCaretLineFrame: Integer;
begin
  Result := SendEditor(SCI_GETCARETLINEFRAME, 0, 0);
end;

procedure TDScintilla.SetCaretLineFrame(AWidth: Integer);
begin
  SendEditor(SCI_SETCARETLINEFRAME, WPARAM(AWidth), 0);
end;

procedure TDScintilla.StyleSetChangeable(AStyle: Integer; AChangeable: Boolean);
begin
  SendEditor(SCI_STYLESETCHANGEABLE, WPARAM(AStyle), LPARAM(Ord(AChangeable)));
end;

procedure TDScintilla.AutoCSetSeparator(ASeparatorCharacter: AnsiChar);
begin
  SendEditor(SCI_AUTOCSETSEPARATOR, Integer(ASeparatorCharacter), 0);
end;

function TDScintilla.AutoCGetSeparator: AnsiChar;
begin
  Result := AnsiChar(SendEditor(SCI_AUTOCGETSEPARATOR, 0, 0));
end;

procedure TDScintilla.AutoCSetCancelAtStart(ACancel: Boolean);
begin
  SendEditor(SCI_AUTOCSETCANCELATSTART, WPARAM(Ord(ACancel)), 0);
end;

function TDScintilla.AutoCGetCancelAtStart: Boolean;
begin
  Result := Boolean(SendEditor(SCI_AUTOCGETCANCELATSTART, 0, 0));
end;

procedure TDScintilla.AutoCSetFillUps(const ACharacterSet: UnicodeString);
begin
  FHelper.SetText(SCI_AUTOCSETFILLUPS, 0, ACharacterSet);
end;

procedure TDScintilla.AutoCSetChooseSingle(AChooseSingle: Boolean);
begin
  SendEditor(SCI_AUTOCSETCHOOSESINGLE, WPARAM(Ord(AChooseSingle)), 0);
end;

function TDScintilla.AutoCGetChooseSingle: Boolean;
begin
  Result := Boolean(SendEditor(SCI_AUTOCGETCHOOSESINGLE, 0, 0));
end;

procedure TDScintilla.AutoCSetIgnoreCase(AIgnoreCase: Boolean);
begin
  SendEditor(SCI_AUTOCSETIGNORECASE, WPARAM(Ord(AIgnoreCase)), 0);
end;

function TDScintilla.AutoCGetIgnoreCase: Boolean;
begin
  Result := Boolean(SendEditor(SCI_AUTOCGETIGNORECASE, 0, 0));
end;

procedure TDScintilla.AutoCSetAutoHide(AAutoHide: Boolean);
begin
  SendEditor(SCI_AUTOCSETAUTOHIDE, WPARAM(Ord(AAutoHide)), 0);
end;

function TDScintilla.AutoCGetAutoHide: Boolean;
begin
  Result := Boolean(SendEditor(SCI_AUTOCGETAUTOHIDE, 0, 0));
end;

procedure TDScintilla.AutoCSetOptions(AOptions: TDSciAutoCompleteOption);
begin
  SendEditor(SCI_AUTOCSETOPTIONS, WPARAM(TDSciAutoCompleteOptionToInt(AOptions)), 0);
end;

function TDScintilla.AutoCGetOptions: TDSciAutoCompleteOption;
begin
  Result := TDSciAutoCompleteOptionFromInt(SendEditor(SCI_AUTOCGETOPTIONS, 0, 0));
end;

procedure TDScintilla.AutoCSetDropRestOfWord(ADropRestOfWord: Boolean);
begin
  SendEditor(SCI_AUTOCSETDROPRESTOFWORD, WPARAM(Ord(ADropRestOfWord)), 0);
end;

function TDScintilla.AutoCGetDropRestOfWord: Boolean;
begin
  Result := Boolean(SendEditor(SCI_AUTOCGETDROPRESTOFWORD, 0, 0));
end;

function TDScintilla.AutoCGetTypeSeparator: AnsiChar;
begin
  Result := AnsiChar(SendEditor(SCI_AUTOCGETTYPESEPARATOR, 0, 0));
end;

procedure TDScintilla.AutoCSetTypeSeparator(ASeparatorCharacter: AnsiChar);
begin
  SendEditor(SCI_AUTOCSETTYPESEPARATOR, Integer(ASeparatorCharacter), 0);
end;

procedure TDScintilla.AutoCSetMaxWidth(ACharacterCount: Integer);
begin
  SendEditor(SCI_AUTOCSETMAXWIDTH, WPARAM(ACharacterCount), 0);
end;

function TDScintilla.AutoCGetMaxWidth: Integer;
begin
  Result := SendEditor(SCI_AUTOCGETMAXWIDTH, 0, 0);
end;

procedure TDScintilla.AutoCSetMaxHeight(ARowCount: Integer);
begin
  SendEditor(SCI_AUTOCSETMAXHEIGHT, WPARAM(ARowCount), 0);
end;

function TDScintilla.AutoCGetMaxHeight: Integer;
begin
  Result := SendEditor(SCI_AUTOCGETMAXHEIGHT, 0, 0);
end;

procedure TDScintilla.AutoCSetStyle(AStyle: Integer);
begin
  SendEditor(SCI_AUTOCSETSTYLE, WPARAM(AStyle), 0);
end;

function TDScintilla.AutoCGetStyle: Integer;
begin
  Result := SendEditor(SCI_AUTOCGETSTYLE, 0, 0);
end;

procedure TDScintilla.AutoCSetImageScale(AScalePercent: Integer);
begin
  SendEditor(SCI_AUTOCSETIMAGESCALE, WPARAM(AScalePercent), 0);
end;

function TDScintilla.AutoCGetImageScale: Integer;
begin
  Result := SendEditor(SCI_AUTOCGETIMAGESCALE, 0, 0);
end;

procedure TDScintilla.SetIndent(AIndentSize: Integer);
begin
  SendEditor(SCI_SETINDENT, WPARAM(AIndentSize), 0);
end;

function TDScintilla.GetIndent: Integer;
begin
  Result := SendEditor(SCI_GETINDENT, 0, 0);
end;

procedure TDScintilla.SetUseTabs(AUseTabs: Boolean);
begin
  SendEditor(SCI_SETUSETABS, WPARAM(Ord(AUseTabs)), 0);
end;

function TDScintilla.GetUseTabs: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETUSETABS, 0, 0));
end;

procedure TDScintilla.SetLineIndentation(ALine: NativeInt; AIndentation: Integer);
begin
  SendEditor(SCI_SETLINEINDENTATION, WPARAM(ALine), LPARAM(AIndentation));
end;

function TDScintilla.GetLineIndentation(ALine: NativeInt): Integer;
begin
  Result := SendEditor(SCI_GETLINEINDENTATION, WPARAM(ALine), 0);
end;

function TDScintilla.GetLineIndentPosition(ALine: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_GETLINEINDENTPOSITION, WPARAM(ALine), 0);
end;

function TDScintilla.GetColumn(APos: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_GETCOLUMN, WPARAM(APos), 0);
end;

procedure TDScintilla.SetHScrollBar(AVisible: Boolean);
begin
  SendEditor(SCI_SETHSCROLLBAR, WPARAM(Ord(AVisible)), 0);
end;

function TDScintilla.GetHScrollBar: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETHSCROLLBAR, 0, 0));
end;

procedure TDScintilla.SetIndentationGuides(AIndentView: TDSciIndentView);
begin
  SendEditor(SCI_SETINDENTATIONGUIDES, WPARAM(TDSciIndentViewToInt(AIndentView)), 0);
end;

function TDScintilla.GetIndentationGuides: TDSciIndentView;
begin
  Result := TDSciIndentViewFromInt(SendEditor(SCI_GETINDENTATIONGUIDES, 0, 0));
end;

procedure TDScintilla.SetHighlightGuide(AColumn: NativeInt);
begin
  SendEditor(SCI_SETHIGHLIGHTGUIDE, WPARAM(AColumn), 0);
end;

function TDScintilla.GetHighlightGuide: NativeInt;
begin
  Result := SendEditor(SCI_GETHIGHLIGHTGUIDE, 0, 0);
end;

function TDScintilla.GetLineEndPosition(ALine: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_GETLINEENDPOSITION, WPARAM(ALine), 0);
end;

function TDScintilla.GetCodePage: Integer;
begin
  Result := SendEditor(SCI_GETCODEPAGE, 0, 0);
end;

function TDScintilla.GetCaretFore: TColor;
begin
  Result := TColor(SendEditor(SCI_GETCARETFORE, 0, 0));
end;

function TDScintilla.GetReadOnly: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETREADONLY, 0, 0));
end;

procedure TDScintilla.SetCurrentPos(ACaret: NativeInt);
begin
  SendEditor(SCI_SETCURRENTPOS, WPARAM(ACaret), 0);
end;

procedure TDScintilla.SetSelectionStart(AAnchor: NativeInt);
begin
  SendEditor(SCI_SETSELECTIONSTART, WPARAM(AAnchor), 0);
end;

function TDScintilla.GetSelectionStart: NativeInt;
begin
  Result := SendEditor(SCI_GETSELECTIONSTART, 0, 0);
end;

procedure TDScintilla.SetSelectionEnd(ACaret: NativeInt);
begin
  SendEditor(SCI_SETSELECTIONEND, WPARAM(ACaret), 0);
end;

function TDScintilla.GetSelectionEnd: NativeInt;
begin
  Result := SendEditor(SCI_GETSELECTIONEND, 0, 0);
end;

procedure TDScintilla.SetPrintMagnification(AMagnification: Integer);
begin
  SendEditor(SCI_SETPRINTMAGNIFICATION, WPARAM(AMagnification), 0);
end;

function TDScintilla.GetPrintMagnification: Integer;
begin
  Result := SendEditor(SCI_GETPRINTMAGNIFICATION, 0, 0);
end;

procedure TDScintilla.SetPrintColourMode(AMode: TDSciPrintOption);
begin
  SendEditor(SCI_SETPRINTCOLOURMODE, WPARAM(TDSciPrintOptionToInt(AMode)), 0);
end;

function TDScintilla.GetPrintColourMode: TDSciPrintOption;
begin
  Result := TDSciPrintOptionFromInt(SendEditor(SCI_GETPRINTCOLOURMODE, 0, 0));
end;

procedure TDScintilla.SetChangeHistory(AChangeHistory: TDSciChangeHistoryOption);
begin
  SendEditor(SCI_SETCHANGEHISTORY, WPARAM(TDSciChangeHistoryOptionToInt(AChangeHistory)), 0);
end;

function TDScintilla.GetChangeHistory: TDSciChangeHistoryOption;
begin
  Result := TDSciChangeHistoryOptionFromInt(SendEditor(SCI_GETCHANGEHISTORY, 0, 0));
end;

procedure TDScintilla.SetUndoSelectionHistory(AUndoSelectionHistory: TDSciUndoSelectionHistoryOption);
begin
  SendEditor(SCI_SETUNDOSELECTIONHISTORY, WPARAM(TDSciUndoSelectionHistoryOptionToInt(AUndoSelectionHistory)), 0);
end;

function TDScintilla.GetUndoSelectionHistory: TDSciUndoSelectionHistoryOption;
begin
  Result := TDSciUndoSelectionHistoryOptionFromInt(SendEditor(SCI_GETUNDOSELECTIONHISTORY, 0, 0));
end;

procedure TDScintilla.SetSelectionSerialized(const ASelectionString: UnicodeString);
begin
  FHelper.SetText(SCI_SETSELECTIONSERIALIZED, 0, ASelectionString);
end;
function TDScintilla.GetSelectionSerialized: UnicodeString;
begin
  FHelper.GetText(SCI_GETSELECTIONSERIALIZED, 0, Result);
end;
function TDScintilla.GetFirstVisibleLine: NativeInt;
begin
  Result := SendEditor(SCI_GETFIRSTVISIBLELINE, 0, 0);
end;

function TDScintilla.GetLineCount: NativeInt;
begin
  Result := SendEditor(SCI_GETLINECOUNT, 0, 0);
end;

procedure TDScintilla.AllocateLines(ALines: NativeInt);
begin
  SendEditor(SCI_ALLOCATELINES, WPARAM(ALines), 0);
end;

procedure TDScintilla.SetMarginLeft(APixelWidth: Integer);
begin
  SendEditor(SCI_SETMARGINLEFT, 0, LPARAM(APixelWidth));
end;

function TDScintilla.GetMarginLeft: Integer;
begin
  Result := SendEditor(SCI_GETMARGINLEFT, 0, 0);
end;

procedure TDScintilla.SetMarginRight(APixelWidth: Integer);
begin
  SendEditor(SCI_SETMARGINRIGHT, 0, LPARAM(APixelWidth));
end;

function TDScintilla.GetMarginRight: Integer;
begin
  Result := SendEditor(SCI_GETMARGINRIGHT, 0, 0);
end;

function TDScintilla.GetModify: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETMODIFY, 0, 0));
end;

function TDScintilla.GetSelectionHidden: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETSELECTIONHIDDEN, 0, 0));
end;

procedure TDScintilla.SetReadOnly(AReadOnly: Boolean);
begin
  SendEditor(SCI_SETREADONLY, WPARAM(Ord(AReadOnly)), 0);
end;

function TDScintilla.GetTextLength: NativeInt;
begin
  Result := SendEditor(SCI_GETTEXTLENGTH, 0, 0);
end;

procedure TDScintilla.SetOvertype(AOverType: Boolean);
begin
  SendEditor(SCI_SETOVERTYPE, WPARAM(Ord(AOverType)), 0);
end;

function TDScintilla.GetOvertype: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETOVERTYPE, 0, 0));
end;

procedure TDScintilla.SetCaretWidth(APixelWidth: Integer);
begin
  SendEditor(SCI_SETCARETWIDTH, WPARAM(APixelWidth), 0);
end;

function TDScintilla.GetCaretWidth: Integer;
begin
  Result := SendEditor(SCI_GETCARETWIDTH, 0, 0);
end;

procedure TDScintilla.SetTargetStart(AStart: NativeInt);
begin
  SendEditor(SCI_SETTARGETSTART, WPARAM(AStart), 0);
end;

function TDScintilla.GetTargetStart: NativeInt;
begin
  Result := SendEditor(SCI_GETTARGETSTART, 0, 0);
end;

procedure TDScintilla.SetTargetStartVirtualSpace(ASpace: NativeInt);
begin
  SendEditor(SCI_SETTARGETSTARTVIRTUALSPACE, WPARAM(ASpace), 0);
end;

function TDScintilla.GetTargetStartVirtualSpace: NativeInt;
begin
  Result := SendEditor(SCI_GETTARGETSTARTVIRTUALSPACE, 0, 0);
end;

procedure TDScintilla.SetTargetEnd(AEnd: NativeInt);
begin
  SendEditor(SCI_SETTARGETEND, WPARAM(AEnd), 0);
end;

function TDScintilla.GetTargetEnd: NativeInt;
begin
  Result := SendEditor(SCI_GETTARGETEND, 0, 0);
end;

procedure TDScintilla.SetTargetEndVirtualSpace(ASpace: NativeInt);
begin
  SendEditor(SCI_SETTARGETENDVIRTUALSPACE, WPARAM(ASpace), 0);
end;

function TDScintilla.GetTargetEndVirtualSpace: NativeInt;
begin
  Result := SendEditor(SCI_GETTARGETENDVIRTUALSPACE, 0, 0);
end;

function TDScintilla.GetTargetText: UnicodeString;
begin
  FHelper.GetText(SCI_GETTARGETTEXT, 0, Result);
end;
procedure TDScintilla.SetSearchFlags(ASearchFlags: TDSciFindOptionSet);
begin
  SendEditor(SCI_SETSEARCHFLAGS, WPARAM(TDSciFindOptionSetToInt(ASearchFlags)), 0);
end;

function TDScintilla.GetSearchFlags: TDSciFindOptionSet;
begin
  Result := TDSciFindOptionSetFromInt(SendEditor(SCI_GETSEARCHFLAGS, 0, 0));
end;

function TDScintilla.CallTipPosStart: NativeInt;
begin
  Result := SendEditor(SCI_CALLTIPPOSSTART, 0, 0);
end;

procedure TDScintilla.CallTipSetPosStart(APosStart: NativeInt);
begin
  SendEditor(SCI_CALLTIPSETPOSSTART, WPARAM(APosStart), 0);
end;

procedure TDScintilla.CallTipSetBack(ABack: TColor);
begin
  SendEditor(SCI_CALLTIPSETBACK, WPARAM(Integer(ABack)), 0);
end;

procedure TDScintilla.CallTipSetFore(AFore: TColor);
begin
  SendEditor(SCI_CALLTIPSETFORE, WPARAM(Integer(AFore)), 0);
end;

procedure TDScintilla.CallTipSetForeHlt(AFore: TColor);
begin
  SendEditor(SCI_CALLTIPSETFOREHLT, WPARAM(Integer(AFore)), 0);
end;

procedure TDScintilla.CallTipUseStyle(ATabSize: Integer);
begin
  SendEditor(SCI_CALLTIPUSESTYLE, WPARAM(ATabSize), 0);
end;

procedure TDScintilla.CallTipSetPosition(AAbove: Boolean);
begin
  SendEditor(SCI_CALLTIPSETPOSITION, WPARAM(Ord(AAbove)), 0);
end;

procedure TDScintilla.SetFoldLevel(ALine: NativeInt; ALevel: TDSciFoldLevel);
begin
  SendEditor(SCI_SETFOLDLEVEL, WPARAM(ALine), LPARAM(TDSciFoldLevelToInt(ALevel)));
end;

function TDScintilla.GetFoldLevel(ALine: NativeInt): TDSciFoldLevel;
begin
  Result := TDSciFoldLevelFromInt(SendEditor(SCI_GETFOLDLEVEL, WPARAM(ALine), 0));
end;

function TDScintilla.GetLastChild(ALine: NativeInt; ALevel: TDSciFoldLevel): NativeInt;
begin
  Result := SendEditor(SCI_GETLASTCHILD, WPARAM(ALine), LPARAM(TDSciFoldLevelToInt(ALevel)));
end;

function TDScintilla.GetFoldParent(ALine: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_GETFOLDPARENT, WPARAM(ALine), 0);
end;

function TDScintilla.GetLineVisible(ALine: NativeInt): Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETLINEVISIBLE, WPARAM(ALine), 0));
end;

function TDScintilla.GetAllLinesVisible: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETALLLINESVISIBLE, 0, 0));
end;

procedure TDScintilla.SetFoldExpanded(ALine: NativeInt; AExpanded: Boolean);
begin
  SendEditor(SCI_SETFOLDEXPANDED, WPARAM(ALine), LPARAM(Ord(AExpanded)));
end;

function TDScintilla.GetFoldExpanded(ALine: NativeInt): Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETFOLDEXPANDED, WPARAM(ALine), 0));
end;

procedure TDScintilla.FoldDisplayTextSetStyle(AStyle: TDSciFoldDisplayTextStyle);
begin
  SendEditor(SCI_FOLDDISPLAYTEXTSETSTYLE, WPARAM(TDSciFoldDisplayTextStyleToInt(AStyle)), 0);
end;

function TDScintilla.FoldDisplayTextGetStyle: TDSciFoldDisplayTextStyle;
begin
  Result := TDSciFoldDisplayTextStyleFromInt(SendEditor(SCI_FOLDDISPLAYTEXTGETSTYLE, 0, 0));
end;

procedure TDScintilla.SetAutomaticFold(AAutomaticFold: TDSciAutomaticFold);
begin
  SendEditor(SCI_SETAUTOMATICFOLD, WPARAM(TDSciAutomaticFoldToInt(AAutomaticFold)), 0);
end;

function TDScintilla.GetAutomaticFold: TDSciAutomaticFold;
begin
  Result := TDSciAutomaticFoldFromInt(SendEditor(SCI_GETAUTOMATICFOLD, 0, 0));
end;

procedure TDScintilla.SetFoldFlags(AFlags: TDSciFoldFlagSet);
begin
  SendEditor(SCI_SETFOLDFLAGS, WPARAM(TDSciFoldFlagSetToInt(AFlags)), 0);
end;

procedure TDScintilla.SetTabIndents(ATabIndents: Boolean);
begin
  SendEditor(SCI_SETTABINDENTS, WPARAM(Ord(ATabIndents)), 0);
end;

function TDScintilla.GetTabIndents: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETTABINDENTS, 0, 0));
end;

procedure TDScintilla.SetBackSpaceUnIndents(ABsUnIndents: Boolean);
begin
  SendEditor(SCI_SETBACKSPACEUNINDENTS, WPARAM(Ord(ABsUnIndents)), 0);
end;

function TDScintilla.GetBackSpaceUnIndents: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETBACKSPACEUNINDENTS, 0, 0));
end;

procedure TDScintilla.SetMouseDwellTime(APeriodMilliseconds: Integer);
begin
  SendEditor(SCI_SETMOUSEDWELLTIME, WPARAM(APeriodMilliseconds), 0);
end;

function TDScintilla.GetMouseDwellTime: Integer;
begin
  Result := SendEditor(SCI_GETMOUSEDWELLTIME, 0, 0);
end;

procedure TDScintilla.SetIdleStyling(AIdleStyling: TDSciIdleStyling);
begin
  SendEditor(SCI_SETIDLESTYLING, WPARAM(TDSciIdleStylingToInt(AIdleStyling)), 0);
end;

function TDScintilla.GetIdleStyling: TDSciIdleStyling;
begin
  Result := TDSciIdleStylingFromInt(SendEditor(SCI_GETIDLESTYLING, 0, 0));
end;

procedure TDScintilla.SetWrapMode(AWrapMode: TDSciWrap);
begin
  SendEditor(SCI_SETWRAPMODE, WPARAM(TDSciWrapToInt(AWrapMode)), 0);
end;

function TDScintilla.GetWrapMode: TDSciWrap;
begin
  Result := TDSciWrapFromInt(SendEditor(SCI_GETWRAPMODE, 0, 0));
end;

procedure TDScintilla.SetWrapVisualFlags(AWrapVisualFlags: TDSciWrapVisualFlagSet);
begin
  SendEditor(SCI_SETWRAPVISUALFLAGS, WPARAM(TDSciWrapVisualFlagSetToInt(AWrapVisualFlags)), 0);
end;

function TDScintilla.GetWrapVisualFlags: TDSciWrapVisualFlagSet;
begin
  Result := TDSciWrapVisualFlagSetFromInt(SendEditor(SCI_GETWRAPVISUALFLAGS, 0, 0));
end;

procedure TDScintilla.SetWrapVisualFlagsLocation(AWrapVisualFlagsLocation: TDSciWrapVisualLocationSet);
begin
  SendEditor(SCI_SETWRAPVISUALFLAGSLOCATION, WPARAM(TDSciWrapVisualLocationSetToInt(AWrapVisualFlagsLocation)), 0);
end;

function TDScintilla.GetWrapVisualFlagsLocation: TDSciWrapVisualLocationSet;
begin
  Result := TDSciWrapVisualLocationSetFromInt(SendEditor(SCI_GETWRAPVISUALFLAGSLOCATION, 0, 0));
end;

procedure TDScintilla.SetWrapStartIndent(AIndent: Integer);
begin
  SendEditor(SCI_SETWRAPSTARTINDENT, WPARAM(AIndent), 0);
end;

function TDScintilla.GetWrapStartIndent: Integer;
begin
  Result := SendEditor(SCI_GETWRAPSTARTINDENT, 0, 0);
end;

procedure TDScintilla.SetWrapIndentMode(AWrapIndentMode: TDSciWrapIndentMode);
begin
  SendEditor(SCI_SETWRAPINDENTMODE, WPARAM(TDSciWrapIndentModeToInt(AWrapIndentMode)), 0);
end;

function TDScintilla.GetWrapIndentMode: TDSciWrapIndentMode;
begin
  Result := TDSciWrapIndentModeFromInt(SendEditor(SCI_GETWRAPINDENTMODE, 0, 0));
end;

procedure TDScintilla.SetLayoutCache(ACacheMode: TDSciLineCache);
begin
  SendEditor(SCI_SETLAYOUTCACHE, WPARAM(TDSciLineCacheToInt(ACacheMode)), 0);
end;

function TDScintilla.GetLayoutCache: TDSciLineCache;
begin
  Result := TDSciLineCacheFromInt(SendEditor(SCI_GETLAYOUTCACHE, 0, 0));
end;

procedure TDScintilla.SetScrollWidth(APixelWidth: Integer);
begin
  SendEditor(SCI_SETSCROLLWIDTH, WPARAM(APixelWidth), 0);
end;

function TDScintilla.GetScrollWidth: Integer;
begin
  Result := SendEditor(SCI_GETSCROLLWIDTH, 0, 0);
end;

procedure TDScintilla.SetScrollWidthTracking(ATracking: Boolean);
begin
  SendEditor(SCI_SETSCROLLWIDTHTRACKING, WPARAM(Ord(ATracking)), 0);
end;

function TDScintilla.GetScrollWidthTracking: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETSCROLLWIDTHTRACKING, 0, 0));
end;

procedure TDScintilla.SetEndAtLastLine(AEndAtLastLine: Boolean);
begin
  SendEditor(SCI_SETENDATLASTLINE, WPARAM(Ord(AEndAtLastLine)), 0);
end;

function TDScintilla.GetEndAtLastLine: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETENDATLASTLINE, 0, 0));
end;

procedure TDScintilla.SetVScrollBar(AVisible: Boolean);
begin
  SendEditor(SCI_SETVSCROLLBAR, WPARAM(Ord(AVisible)), 0);
end;

function TDScintilla.GetVScrollBar: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETVSCROLLBAR, 0, 0));
end;

function TDScintilla.GetPhasesDraw: TDSciPhasesDraw;
begin
  Result := TDSciPhasesDrawFromInt(SendEditor(SCI_GETPHASESDRAW, 0, 0));
end;

procedure TDScintilla.SetPhasesDraw(APhases: TDSciPhasesDraw);
begin
  SendEditor(SCI_SETPHASESDRAW, WPARAM(TDSciPhasesDrawToInt(APhases)), 0);
end;

procedure TDScintilla.SetFontQuality(AFontQuality: TDSciFontQuality);
begin
  SendEditor(SCI_SETFONTQUALITY, WPARAM(TDSciFontQualityToInt(AFontQuality)), 0);
end;

function TDScintilla.GetFontQuality: TDSciFontQuality;
begin
  Result := TDSciFontQualityFromInt(SendEditor(SCI_GETFONTQUALITY, 0, 0));
end;

procedure TDScintilla.SetFirstVisibleLine(ADisplayLine: NativeInt);
begin
  SendEditor(SCI_SETFIRSTVISIBLELINE, WPARAM(ADisplayLine), 0);
end;

procedure TDScintilla.SetMultiPaste(AMultiPaste: TDSciMultiPaste);
begin
  SendEditor(SCI_SETMULTIPASTE, WPARAM(TDSciMultiPasteToInt(AMultiPaste)), 0);
end;

function TDScintilla.GetMultiPaste: TDSciMultiPaste;
begin
  Result := TDSciMultiPasteFromInt(SendEditor(SCI_GETMULTIPASTE, 0, 0));
end;

function TDScintilla.GetTag(ATagNumber: Integer): UnicodeString;
begin
  FHelper.GetText(SCI_GETTAG, ATagNumber, Result);
end;

procedure TDScintilla.SetAccessibility(AAccessibility: TDSciAccessibility);
begin
  SendEditor(SCI_SETACCESSIBILITY, WPARAM(TDSciAccessibilityToInt(AAccessibility)), 0);
end;

function TDScintilla.GetAccessibility: TDSciAccessibility;
begin
  Result := TDSciAccessibilityFromInt(SendEditor(SCI_GETACCESSIBILITY, 0, 0));
end;

function TDScintilla.GetViewEOL: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETVIEWEOL, 0, 0));
end;

procedure TDScintilla.SetViewEOL(AVisible: Boolean);
begin
  SendEditor(SCI_SETVIEWEOL, WPARAM(Ord(AVisible)), 0);
end;

procedure TDScintilla.SetModEventMask(AEventMask: TDSciModificationFlagsSet);
begin
  SendEditor(SCI_SETMODEVENTMASK, WPARAM(TDSciModificationFlagsSetToInt(AEventMask)), 0);
end;

function TDScintilla.GetEdgeColumn: NativeInt;
begin
  Result := SendEditor(SCI_GETEDGECOLUMN, 0, 0);
end;

procedure TDScintilla.SetEdgeColumn(AColumn: NativeInt);
begin
  SendEditor(SCI_SETEDGECOLUMN, WPARAM(AColumn), 0);
end;

function TDScintilla.GetEdgeMode: TDSciEdgeVisualStyle;
begin
  Result := TDSciEdgeVisualStyleFromInt(SendEditor(SCI_GETEDGEMODE, 0, 0));
end;

procedure TDScintilla.SetEdgeMode(AEdgeMode: TDSciEdgeVisualStyle);
begin
  SendEditor(SCI_SETEDGEMODE, WPARAM(TDSciEdgeVisualStyleToInt(AEdgeMode)), 0);
end;

function TDScintilla.GetEdgeColour: TColor;
begin
  Result := TColor(SendEditor(SCI_GETEDGECOLOUR, 0, 0));
end;

procedure TDScintilla.SetEdgeColour(AEdgeColour: TColor);
begin
  SendEditor(SCI_SETEDGECOLOUR, WPARAM(Integer(AEdgeColour)), 0);
end;

function TDScintilla.GetMultiEdgeColumn(AWhich: Integer): NativeInt;
begin
  Result := SendEditor(SCI_GETMULTIEDGECOLUMN, WPARAM(AWhich), 0);
end;

function TDScintilla.LinesOnScreen: NativeInt;
begin
  Result := SendEditor(SCI_LINESONSCREEN, 0, 0);
end;

function TDScintilla.SelectionIsRectangle: Boolean;
begin
  Result := Boolean(SendEditor(SCI_SELECTIONISRECTANGLE, 0, 0));
end;

procedure TDScintilla.SetZoom(AZoomInPoints: Integer);
begin
  SendEditor(SCI_SETZOOM, WPARAM(AZoomInPoints), 0);
end;

function TDScintilla.GetZoom: Integer;
begin
  Result := SendEditor(SCI_GETZOOM, 0, 0);
end;

function TDScintilla.GetDocumentOptions: TDSciDocumentOption;
begin
  Result := TDSciDocumentOptionFromInt(SendEditor(SCI_GETDOCUMENTOPTIONS, 0, 0));
end;

function TDScintilla.GetModEventMask: TDSciModificationFlagsSet;
begin
  Result := TDSciModificationFlagsSetFromInt(SendEditor(SCI_GETMODEVENTMASK, 0, 0));
end;

procedure TDScintilla.SetCommandEvents(ACommandEvents: Boolean);
begin
  SendEditor(SCI_SETCOMMANDEVENTS, WPARAM(Ord(ACommandEvents)), 0);
end;

function TDScintilla.GetCommandEvents: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETCOMMANDEVENTS, 0, 0));
end;

procedure TDScintilla.SetFocus(AFocus: Boolean);
begin
  SendEditor(SCI_SETFOCUS, Ord(AFocus), 0);
end;

function TDScintilla.GetFocus: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETFOCUS, 0, 0));
end;

procedure TDScintilla.SetStatus(AStatus: TDSciStatus);
begin
  SendEditor(SCI_SETSTATUS, WPARAM(TDSciStatusToInt(AStatus)), 0);
end;

function TDScintilla.GetStatus: TDSciStatus;
begin
  Result := TDSciStatusFromInt(SendEditor(SCI_GETSTATUS, 0, 0));
end;

procedure TDScintilla.SetMouseDownCaptures(ACaptures: Boolean);
begin
  SendEditor(SCI_SETMOUSEDOWNCAPTURES, WPARAM(Ord(ACaptures)), 0);
end;

function TDScintilla.GetMouseDownCaptures: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETMOUSEDOWNCAPTURES, 0, 0));
end;

procedure TDScintilla.SetMouseWheelCaptures(ACaptures: Boolean);
begin
  SendEditor(SCI_SETMOUSEWHEELCAPTURES, WPARAM(Ord(ACaptures)), 0);
end;

function TDScintilla.GetMouseWheelCaptures: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETMOUSEWHEELCAPTURES, 0, 0));
end;

procedure TDScintilla.SetCursor(ACursorType: TDSciCursorShape);
begin
  SendEditor(SCI_SETCURSOR, WPARAM(TDSciCursorShapeToInt(ACursorType)), 0);
end;

function TDScintilla.GetCursor: TDSciCursorShape;
begin
  Result := TDSciCursorShapeFromInt(SendEditor(SCI_GETCURSOR, 0, 0));
end;

procedure TDScintilla.SetControlCharSymbol(ASymbol: Integer);
begin
  SendEditor(SCI_SETCONTROLCHARSYMBOL, WPARAM(ASymbol), 0);
end;

function TDScintilla.GetControlCharSymbol: Integer;
begin
  Result := SendEditor(SCI_GETCONTROLCHARSYMBOL, 0, 0);
end;

procedure TDScintilla.SetXOffset(AXOffset: Integer);
begin
  SendEditor(SCI_SETXOFFSET, WPARAM(AXOffset), 0);
end;

function TDScintilla.GetXOffset: Integer;
begin
  Result := SendEditor(SCI_GETXOFFSET, 0, 0);
end;

procedure TDScintilla.SetPrintWrapMode(AWrapMode: TDSciWrap);
begin
  SendEditor(SCI_SETPRINTWRAPMODE, WPARAM(TDSciWrapToInt(AWrapMode)), 0);
end;

function TDScintilla.GetPrintWrapMode: TDSciWrap;
begin
  Result := TDSciWrapFromInt(SendEditor(SCI_GETPRINTWRAPMODE, 0, 0));
end;

procedure TDScintilla.SetHotspotActiveFore(AUseSetting: Boolean; AFore: TColor);
begin
  SendEditor(SCI_SETHOTSPOTACTIVEFORE, WPARAM(Ord(AUseSetting)), LPARAM(Integer(AFore)));
end;

function TDScintilla.GetHotspotActiveFore: TColor;
begin
  Result := TColor(SendEditor(SCI_GETHOTSPOTACTIVEFORE, 0, 0));
end;

procedure TDScintilla.SetHotspotActiveBack(AUseSetting: Boolean; ABack: TColor);
begin
  SendEditor(SCI_SETHOTSPOTACTIVEBACK, WPARAM(Ord(AUseSetting)), LPARAM(Integer(ABack)));
end;

function TDScintilla.GetHotspotActiveBack: TColor;
begin
  Result := TColor(SendEditor(SCI_GETHOTSPOTACTIVEBACK, 0, 0));
end;

procedure TDScintilla.SetHotspotActiveUnderline(AUnderline: Boolean);
begin
  SendEditor(SCI_SETHOTSPOTACTIVEUNDERLINE, WPARAM(Ord(AUnderline)), 0);
end;

function TDScintilla.GetHotspotActiveUnderline: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETHOTSPOTACTIVEUNDERLINE, 0, 0));
end;

procedure TDScintilla.SetHotspotSingleLine(ASingleLine: Boolean);
begin
  SendEditor(SCI_SETHOTSPOTSINGLELINE, WPARAM(Ord(ASingleLine)), 0);
end;

function TDScintilla.GetHotspotSingleLine: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETHOTSPOTSINGLELINE, 0, 0));
end;

procedure TDScintilla.SetSelectionMode(ASelectionMode: TDSciSelectionMode);
begin
  SendEditor(SCI_SETSELECTIONMODE, WPARAM(TDSciSelectionModeToInt(ASelectionMode)), 0);
end;

function TDScintilla.GetSelectionMode: TDSciSelectionMode;
begin
  Result := TDSciSelectionModeFromInt(SendEditor(SCI_GETSELECTIONMODE, 0, 0));
end;

procedure TDScintilla.SetMoveExtendsSelection(AMoveExtendsSelection: Boolean);
begin
  SendEditor(SCI_SETMOVEEXTENDSSELECTION, WPARAM(Ord(AMoveExtendsSelection)), 0);
end;

function TDScintilla.GetMoveExtendsSelection: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETMOVEEXTENDSSELECTION, 0, 0));
end;

procedure TDScintilla.SetWhitespaceChars(const ACharacters: UnicodeString);
begin
  FHelper.SetText(SCI_SETWHITESPACECHARS, 0, ACharacters);
end;

function TDScintilla.GetWhitespaceChars: UnicodeString;
begin
  FHelper.GetText(SCI_GETWHITESPACECHARS, 0, Result);
end;

procedure TDScintilla.SetPunctuationChars(const ACharacters: AnsiString);
begin
  FHelper.SetTextA(SCI_SETPUNCTUATIONCHARS, 0, ACharacters);
end;

function TDScintilla.GetPunctuationChars: AnsiString;
begin
  FHelper.GetTextA(SCI_GETPUNCTUATIONCHARS, 0, Result);
end;

function TDScintilla.AutoCGetCurrent: Integer;
begin
  Result := SendEditor(SCI_AUTOCGETCURRENT, 0, 0);
end;

function TDScintilla.AutoCGetCurrentText: UnicodeString;
begin
  FHelper.GetText(SCI_AUTOCGETCURRENTTEXT, 0, Result);
end;

procedure TDScintilla.AutoCSetCaseInsensitiveBehaviour(ABehaviour: TDSciCaseInsensitiveBehaviour);
begin
  SendEditor(SCI_AUTOCSETCASEINSENSITIVEBEHAVIOUR, WPARAM(TDSciCaseInsensitiveBehaviourToInt(ABehaviour)), 0);
end;

function TDScintilla.AutoCGetCaseInsensitiveBehaviour: TDSciCaseInsensitiveBehaviour;
begin
  Result := TDSciCaseInsensitiveBehaviourFromInt(SendEditor(SCI_AUTOCGETCASEINSENSITIVEBEHAVIOUR, 0, 0));
end;

procedure TDScintilla.AutoCSetMulti(AMulti: TDSciMultiAutoComplete);
begin
  SendEditor(SCI_AUTOCSETMULTI, WPARAM(TDSciMultiAutoCompleteToInt(AMulti)), 0);
end;

function TDScintilla.AutoCGetMulti: TDSciMultiAutoComplete;
begin
  Result := TDSciMultiAutoCompleteFromInt(SendEditor(SCI_AUTOCGETMULTI, 0, 0));
end;

procedure TDScintilla.AutoCSetOrder(AOrder: TDSciOrdering);
begin
  SendEditor(SCI_AUTOCSETORDER, WPARAM(TDSciOrderingToInt(AOrder)), 0);
end;

function TDScintilla.AutoCGetOrder: TDSciOrdering;
begin
  Result := TDSciOrderingFromInt(SendEditor(SCI_AUTOCGETORDER, 0, 0));
end;

function TDScintilla.GetCaretSticky: TDSciCaretSticky;
begin
  Result := TDSciCaretStickyFromInt(SendEditor(SCI_GETCARETSTICKY, 0, 0));
end;

procedure TDScintilla.SetCaretSticky(AUseCaretStickyBehaviour: TDSciCaretSticky);
begin
  SendEditor(SCI_SETCARETSTICKY, WPARAM(TDSciCaretStickyToInt(AUseCaretStickyBehaviour)), 0);
end;

procedure TDScintilla.SetPasteConvertEndings(AConvert: Boolean);
begin
  SendEditor(SCI_SETPASTECONVERTENDINGS, WPARAM(Ord(AConvert)), 0);
end;

function TDScintilla.GetPasteConvertEndings: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETPASTECONVERTENDINGS, 0, 0));
end;

procedure TDScintilla.SetCaretLineBackAlpha(AAlpha: TDSciAlpha);
begin
  SendEditor(SCI_SETCARETLINEBACKALPHA, WPARAM(TDSciAlphaToInt(AAlpha)), 0);
end;

function TDScintilla.GetCaretLineBackAlpha: TDSciAlpha;
begin
  Result := TDSciAlphaFromInt(SendEditor(SCI_GETCARETLINEBACKALPHA, 0, 0));
end;

procedure TDScintilla.SetCaretStyle(ACaretStyle: TDSciCaretStyle);
begin
  SendEditor(SCI_SETCARETSTYLE, WPARAM(TDSciCaretStyleToInt(ACaretStyle)), 0);
end;

function TDScintilla.GetCaretStyle: TDSciCaretStyle;
begin
  Result := TDSciCaretStyleFromInt(SendEditor(SCI_GETCARETSTYLE, 0, 0));
end;

procedure TDScintilla.SetIndicatorCurrent(AIndicator: Integer);
begin
  SendEditor(SCI_SETINDICATORCURRENT, WPARAM(AIndicator), 0);
end;

function TDScintilla.GetIndicatorCurrent: Integer;
begin
  Result := SendEditor(SCI_GETINDICATORCURRENT, 0, 0);
end;

procedure TDScintilla.SetIndicatorValue(AValue: Integer);
begin
  SendEditor(SCI_SETINDICATORVALUE, WPARAM(AValue), 0);
end;

function TDScintilla.GetIndicatorValue: Integer;
begin
  Result := SendEditor(SCI_GETINDICATORVALUE, 0, 0);
end;

procedure TDScintilla.SetPositionCache(ASize: Integer);
begin
  SendEditor(SCI_SETPOSITIONCACHE, WPARAM(ASize), 0);
end;

function TDScintilla.GetPositionCache: Integer;
begin
  Result := SendEditor(SCI_GETPOSITIONCACHE, 0, 0);
end;

procedure TDScintilla.SetLayoutThreads(AThreads: Integer);
begin
  SendEditor(SCI_SETLAYOUTTHREADS, WPARAM(AThreads), 0);
end;

function TDScintilla.GetLayoutThreads: Integer;
begin
  Result := SendEditor(SCI_GETLAYOUTTHREADS, 0, 0);
end;

procedure TDScintilla.SetCopySeparator(const ASeparator: UnicodeString);
begin
  FHelper.SetText(SCI_SETCOPYSEPARATOR, 0, ASeparator);
end;
function TDScintilla.GetCopySeparator: UnicodeString;
begin
  FHelper.GetText(SCI_GETCOPYSEPARATOR, 0, Result);
end;
function TDScintilla.GetGapPosition: NativeInt;
begin
  Result := SendEditor(SCI_GETGAPPOSITION, 0, 0);
end;

procedure TDScintilla.IndicSetAlpha(AIndicator: Integer; AAlpha: TDSciAlpha);
begin
  SendEditor(SCI_INDICSETALPHA, WPARAM(AIndicator), LPARAM(TDSciAlphaToInt(AAlpha)));
end;

function TDScintilla.IndicGetAlpha(AIndicator: Integer): TDSciAlpha;
begin
  Result := TDSciAlphaFromInt(SendEditor(SCI_INDICGETALPHA, WPARAM(AIndicator), 0));
end;

procedure TDScintilla.IndicSetOutlineAlpha(AIndicator: Integer; AAlpha: TDSciAlpha);
begin
  SendEditor(SCI_INDICSETOUTLINEALPHA, WPARAM(AIndicator), LPARAM(TDSciAlphaToInt(AAlpha)));
end;

function TDScintilla.IndicGetOutlineAlpha(AIndicator: Integer): TDSciAlpha;
begin
  Result := TDSciAlphaFromInt(SendEditor(SCI_INDICGETOUTLINEALPHA, WPARAM(AIndicator), 0));
end;

procedure TDScintilla.SetExtraAscent(AExtraAscent: Integer);
begin
  SendEditor(SCI_SETEXTRAASCENT, WPARAM(AExtraAscent), 0);
end;

function TDScintilla.GetExtraAscent: Integer;
begin
  Result := SendEditor(SCI_GETEXTRAASCENT, 0, 0);
end;

procedure TDScintilla.SetExtraDescent(AExtraDescent: Integer);
begin
  SendEditor(SCI_SETEXTRADESCENT, WPARAM(AExtraDescent), 0);
end;

function TDScintilla.GetExtraDescent: Integer;
begin
  Result := SendEditor(SCI_GETEXTRADESCENT, 0, 0);
end;

procedure TDScintilla.MarginSetText(ALine: NativeInt; const AText: UnicodeString);
begin
  FHelper.SetText(SCI_MARGINSETTEXT, ALine, AText);
end;

function TDScintilla.MarginGetText(ALine: NativeInt): UnicodeString;
begin
  FHelper.GetText(SCI_MARGINGETTEXT, ALine, Result);
end;

procedure TDScintilla.MarginSetStyle(ALine: NativeInt; AStyle: Integer);
begin
  SendEditor(SCI_MARGINSETSTYLE, WPARAM(ALine), LPARAM(AStyle));
end;

function TDScintilla.MarginGetStyle(ALine: NativeInt): Integer;
begin
  Result := SendEditor(SCI_MARGINGETSTYLE, WPARAM(ALine), 0);
end;

procedure TDScintilla.MarginSetStyles(ALine: NativeInt; const AStyles: TDSciStyles);
begin
  SendEditor(SCI_MARGINSETSTYLES, ALine, LPARAM(AStyles));
end;

function TDScintilla.MarginGetStyles(ALine: NativeInt): TDSciStyles;
begin
  SetLength(Result, SendEditor(SCI_MARGINGETSTYLES, ALine));
  if Length(Result) > 0 then
    SendEditor(SCI_MARGINGETSTYLES, ALine, LPARAM(@Result[0]));
end;

procedure TDScintilla.MarginSetStyleOffset(AStyle: Integer);
begin
  SendEditor(SCI_MARGINSETSTYLEOFFSET, WPARAM(AStyle), 0);
end;

function TDScintilla.MarginGetStyleOffset: Integer;
begin
  Result := SendEditor(SCI_MARGINGETSTYLEOFFSET, 0, 0);
end;

procedure TDScintilla.SetMarginOptions(AMarginOptions: TDSciMarginOption);
begin
  SendEditor(SCI_SETMARGINOPTIONS, WPARAM(TDSciMarginOptionToInt(AMarginOptions)), 0);
end;

function TDScintilla.GetMarginOptions: TDSciMarginOption;
begin
  Result := TDSciMarginOptionFromInt(SendEditor(SCI_GETMARGINOPTIONS, 0, 0));
end;

procedure TDScintilla.AnnotationSetText(ALine: NativeInt; const AText: UnicodeString);
begin
  FHelper.SetText(SCI_ANNOTATIONSETTEXT, ALine, AText);
end;

function TDScintilla.AnnotationGetText(ALine: NativeInt): UnicodeString;
begin
  FHelper.GetText(SCI_ANNOTATIONGETTEXT, ALine, Result);
end;
procedure TDScintilla.AnnotationSetStyle(ALine: NativeInt; AStyle: Integer);
begin
  SendEditor(SCI_ANNOTATIONSETSTYLE, WPARAM(ALine), LPARAM(AStyle));
end;

function TDScintilla.AnnotationGetStyle(ALine: NativeInt): Integer;
begin
  Result := SendEditor(SCI_ANNOTATIONGETSTYLE, WPARAM(ALine), 0);
end;

procedure TDScintilla.AnnotationSetStyles(ALine: NativeInt; const AStyles: TDSciStyles);
begin
  SendEditor(SCI_ANNOTATIONSETSTYLES, ALine, LPARAM(AStyles));
end;

function TDScintilla.AnnotationGetStyles(ALine: NativeInt): TDSciStyles;
begin
  SetLength(Result, SendEditor(SCI_ANNOTATIONGETSTYLES, ALine));
  if Length(Result) > 0 then
    SendEditor(SCI_ANNOTATIONGETSTYLES, ALine, LPARAM(@Result[0]));
end;

function TDScintilla.AnnotationGetLines(ALine: NativeInt): Integer;
begin
  Result := SendEditor(SCI_ANNOTATIONGETLINES, WPARAM(ALine), 0);
end;

procedure TDScintilla.AnnotationSetVisible(AVisible: TDSciAnnotationVisible);
begin
  SendEditor(SCI_ANNOTATIONSETVISIBLE, WPARAM(TDSciAnnotationVisibleToInt(AVisible)), 0);
end;

function TDScintilla.AnnotationGetVisible: TDSciAnnotationVisible;
begin
  Result := TDSciAnnotationVisibleFromInt(SendEditor(SCI_ANNOTATIONGETVISIBLE, 0, 0));
end;

procedure TDScintilla.AnnotationSetStyleOffset(AStyle: Integer);
begin
  SendEditor(SCI_ANNOTATIONSETSTYLEOFFSET, WPARAM(AStyle), 0);
end;

function TDScintilla.AnnotationGetStyleOffset: Integer;
begin
  Result := SendEditor(SCI_ANNOTATIONGETSTYLEOFFSET, 0, 0);
end;

procedure TDScintilla.SetMouseSelectionRectangularSwitch(AMouseSelectionRectangularSwitch: Boolean);
begin
  SendEditor(SCI_SETMOUSESELECTIONRECTANGULARSWITCH, WPARAM(Ord(AMouseSelectionRectangularSwitch)), 0);
end;

function TDScintilla.GetMouseSelectionRectangularSwitch: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETMOUSESELECTIONRECTANGULARSWITCH, 0, 0));
end;

procedure TDScintilla.SetMultipleSelection(AMultipleSelection: Boolean);
begin
  SendEditor(SCI_SETMULTIPLESELECTION, WPARAM(Ord(AMultipleSelection)), 0);
end;

function TDScintilla.GetMultipleSelection: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETMULTIPLESELECTION, 0, 0));
end;

procedure TDScintilla.SetAdditionalSelectionTyping(AAdditionalSelectionTyping: Boolean);
begin
  SendEditor(SCI_SETADDITIONALSELECTIONTYPING, WPARAM(Ord(AAdditionalSelectionTyping)), 0);
end;

function TDScintilla.GetAdditionalSelectionTyping: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETADDITIONALSELECTIONTYPING, 0, 0));
end;

procedure TDScintilla.SetAdditionalCaretsBlink(AAdditionalCaretsBlink: Boolean);
begin
  SendEditor(SCI_SETADDITIONALCARETSBLINK, WPARAM(Ord(AAdditionalCaretsBlink)), 0);
end;

function TDScintilla.GetAdditionalCaretsBlink: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETADDITIONALCARETSBLINK, 0, 0));
end;

procedure TDScintilla.SetAdditionalCaretsVisible(AAdditionalCaretsVisible: Boolean);
begin
  SendEditor(SCI_SETADDITIONALCARETSVISIBLE, WPARAM(Ord(AAdditionalCaretsVisible)), 0);
end;

function TDScintilla.GetAdditionalCaretsVisible: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETADDITIONALCARETSVISIBLE, 0, 0));
end;

function TDScintilla.GetSelections: Integer;
begin
  Result := SendEditor(SCI_GETSELECTIONS, 0, 0);
end;

function TDScintilla.GetSelectionEmpty: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETSELECTIONEMPTY, 0, 0));
end;

procedure TDScintilla.SetMainSelection(ASelection: Integer);
begin
  SendEditor(SCI_SETMAINSELECTION, WPARAM(ASelection), 0);
end;

function TDScintilla.GetMainSelection: Integer;
begin
  Result := SendEditor(SCI_GETMAINSELECTION, 0, 0);
end;

procedure TDScintilla.SetSelectionNCaret(ASelection: Integer; APos: NativeInt);
begin
  if (ASelection >= 0) and (ASelection < GetSelections) then
    SendEditor(SCI_SETSELECTIONNCARET, ASelection, APos);
end;

function TDScintilla.GetSelectionNCaret(ASelection: Integer): NativeInt;
begin
  if (ASelection >= 0) and (ASelection < GetSelections) then
    Result := SendEditor(SCI_GETSELECTIONNCARET, ASelection, 0)
  else
    Result := INVALID_POSITION;
end;

procedure TDScintilla.SetSelectionNAnchor(ASelection: Integer; APosAnchor: NativeInt);
begin
  if (ASelection >= 0) and (ASelection < GetSelections) then
    SendEditor(SCI_SETSELECTIONNANCHOR, ASelection, APosAnchor);
end;

function TDScintilla.GetSelectionNAnchor(ASelection: Integer): NativeInt;
begin
  if (ASelection >= 0) and (ASelection < GetSelections) then
    Result := SendEditor(SCI_GETSELECTIONNANCHOR, ASelection, 0)
  else
    Result := INVALID_POSITION;
end;

procedure TDScintilla.SetSelectionNCaretVirtualSpace(ASelection: Integer; ASpace: NativeInt);
begin
  if (ASelection >= 0) and (ASelection < GetSelections) then
    SendEditor(SCI_SETSELECTIONNCARETVIRTUALSPACE, ASelection, ASpace);
end;

function TDScintilla.GetSelectionNCaretVirtualSpace(ASelection: Integer): NativeInt;
begin
  if (ASelection >= 0) and (ASelection < GetSelections) then
    Result := SendEditor(SCI_GETSELECTIONNCARETVIRTUALSPACE, ASelection, 0)
  else
    Result := INVALID_POSITION;
end;

procedure TDScintilla.SetSelectionNAnchorVirtualSpace(ASelection: Integer; ASpace: NativeInt);
begin
  if (ASelection >= 0) and (ASelection < GetSelections) then
    SendEditor(SCI_SETSELECTIONNANCHORVIRTUALSPACE, ASelection, ASpace);
end;

function TDScintilla.GetSelectionNAnchorVirtualSpace(ASelection: Integer): NativeInt;
begin
  if (ASelection >= 0) and (ASelection < GetSelections) then
    Result := SendEditor(SCI_GETSELECTIONNANCHORVIRTUALSPACE, ASelection, 0)
  else
    Result := INVALID_POSITION;
end;

procedure TDScintilla.SetSelectionNStart(ASelection: Integer; APos: NativeInt);
begin
  if (ASelection >= 0) and (ASelection < GetSelections) then
    SendEditor(SCI_SETSELECTIONNSTART, ASelection, APos);
end;

function TDScintilla.GetSelectionNStart(ASelection: Integer): NativeInt;
begin
  if (ASelection >= 0) and (ASelection < GetSelections) then
    Result := SendEditor(SCI_GETSELECTIONNSTART, ASelection, 0)
  else
    Result := INVALID_POSITION;
end;

function TDScintilla.GetSelectionNStartVirtualSpace(ASelection: Integer): NativeInt;
begin
  Result := SendEditor(SCI_GETSELECTIONNSTARTVIRTUALSPACE, WPARAM(ASelection), 0);
end;

procedure TDScintilla.SetSelectionNEnd(ASelection: Integer; APos: NativeInt);
begin
  if (ASelection >= 0) and (ASelection < GetSelections) then
    SendEditor(SCI_SETSELECTIONNEND, ASelection, APos);
end;

function TDScintilla.GetSelectionNEndVirtualSpace(ASelection: Integer): NativeInt;
begin
  Result := SendEditor(SCI_GETSELECTIONNENDVIRTUALSPACE, WPARAM(ASelection), 0);
end;

function TDScintilla.GetSelectionNEnd(ASelection: Integer): NativeInt;
begin
  if (ASelection >= 0) and (ASelection < GetSelections) then
    Result := SendEditor(SCI_GETSELECTIONNEND, ASelection, 0)
  else
    Result := INVALID_POSITION;
end;

procedure TDScintilla.SetRectangularSelectionCaret(ACaret: NativeInt);
begin
  SendEditor(SCI_SETRECTANGULARSELECTIONCARET, WPARAM(ACaret), 0);
end;

function TDScintilla.GetRectangularSelectionCaret: NativeInt;
begin
  Result := SendEditor(SCI_GETRECTANGULARSELECTIONCARET, 0, 0);
end;

procedure TDScintilla.SetRectangularSelectionAnchor(AAnchor: NativeInt);
begin
  SendEditor(SCI_SETRECTANGULARSELECTIONANCHOR, WPARAM(AAnchor), 0);
end;

function TDScintilla.GetRectangularSelectionAnchor: NativeInt;
begin
  Result := SendEditor(SCI_GETRECTANGULARSELECTIONANCHOR, 0, 0);
end;

procedure TDScintilla.SetRectangularSelectionCaretVirtualSpace(ASpace: NativeInt);
begin
  SendEditor(SCI_SETRECTANGULARSELECTIONCARETVIRTUALSPACE, WPARAM(ASpace), 0);
end;

function TDScintilla.GetRectangularSelectionCaretVirtualSpace: NativeInt;
begin
  Result := SendEditor(SCI_GETRECTANGULARSELECTIONCARETVIRTUALSPACE, 0, 0);
end;

procedure TDScintilla.SetRectangularSelectionAnchorVirtualSpace(ASpace: NativeInt);
begin
  SendEditor(SCI_SETRECTANGULARSELECTIONANCHORVIRTUALSPACE, WPARAM(ASpace), 0);
end;

function TDScintilla.GetRectangularSelectionAnchorVirtualSpace: NativeInt;
begin
  Result := SendEditor(SCI_GETRECTANGULARSELECTIONANCHORVIRTUALSPACE, 0, 0);
end;

procedure TDScintilla.SetVirtualSpaceOptions(AVirtualSpaceOptions: TDSciVirtualSpaceSet);
begin
  SendEditor(SCI_SETVIRTUALSPACEOPTIONS, WPARAM(TDSciVirtualSpaceSetToInt(AVirtualSpaceOptions)), 0);
end;

function TDScintilla.GetVirtualSpaceOptions: TDSciVirtualSpaceSet;
begin
  Result := TDSciVirtualSpaceSetFromInt(SendEditor(SCI_GETVIRTUALSPACEOPTIONS, 0, 0));
end;

procedure TDScintilla.SetRectangularSelectionModifier(AModifier: TDSciKeyModSet);
begin
  SendEditor(SCI_SETRECTANGULARSELECTIONMODIFIER, WPARAM(TDSciKeyModSetToInt(AModifier)), 0);
end;

function TDScintilla.GetRectangularSelectionModifier: TDSciKeyModSet;
begin
  Result := TDSciKeyModSetFromInt(SendEditor(SCI_GETRECTANGULARSELECTIONMODIFIER, 0, 0));
end;

procedure TDScintilla.SetAdditionalSelFore(AFore: TColor);
begin
  SendEditor(SCI_SETADDITIONALSELFORE, WPARAM(Integer(AFore)), 0);
end;

procedure TDScintilla.SetAdditionalSelBack(ABack: TColor);
begin
  SendEditor(SCI_SETADDITIONALSELBACK, WPARAM(Integer(ABack)), 0);
end;

procedure TDScintilla.SetAdditionalSelAlpha(AAlpha: TDSciAlpha);
begin
  SendEditor(SCI_SETADDITIONALSELALPHA, WPARAM(TDSciAlphaToInt(AAlpha)), 0);
end;

function TDScintilla.GetAdditionalSelAlpha: TDSciAlpha;
begin
  Result := TDSciAlphaFromInt(SendEditor(SCI_GETADDITIONALSELALPHA, 0, 0));
end;

procedure TDScintilla.SetAdditionalCaretFore(AFore: TColor);
begin
  SendEditor(SCI_SETADDITIONALCARETFORE, WPARAM(Integer(AFore)), 0);
end;

function TDScintilla.GetAdditionalCaretFore: TColor;
begin
  Result := TColor(SendEditor(SCI_GETADDITIONALCARETFORE, 0, 0));
end;

procedure TDScintilla.SetIdentifier(AIdentifier: Integer);
begin
  SendEditor(SCI_SETIDENTIFIER, WPARAM(AIdentifier), 0);
end;

function TDScintilla.GetIdentifier: Integer;
begin
  Result := SendEditor(SCI_GETIDENTIFIER, 0, 0);
end;

procedure TDScintilla.RGBAImageSetWidth(AWidth: Integer);
begin
  SendEditor(SCI_RGBAIMAGESETWIDTH, WPARAM(AWidth), 0);
end;

procedure TDScintilla.RGBAImageSetHeight(AHeight: Integer);
begin
  SendEditor(SCI_RGBAIMAGESETHEIGHT, WPARAM(AHeight), 0);
end;

procedure TDScintilla.RGBAImageSetScale(AScalePercent: Integer);
begin
  SendEditor(SCI_RGBAIMAGESETSCALE, WPARAM(AScalePercent), 0);
end;

procedure TDScintilla.SetTechnology(ATechnology: TDSciTechnology);
begin
  SendEditor(SCI_SETTECHNOLOGY, WPARAM(TDSciTechnologyToInt(ATechnology)), 0);
end;

function TDScintilla.GetTechnology: TDSciTechnology;
begin
  Result := TDSciTechnologyFromInt(SendEditor(SCI_GETTECHNOLOGY, 0, 0));
end;

function TDScintilla.GetCaretLineVisibleAlways: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETCARETLINEVISIBLEALWAYS, 0, 0));
end;

procedure TDScintilla.SetCaretLineVisibleAlways(AAlwaysVisible: Boolean);
begin
  SendEditor(SCI_SETCARETLINEVISIBLEALWAYS, WPARAM(Ord(AAlwaysVisible)), 0);
end;

procedure TDScintilla.SetLineEndTypesAllowed(ALineEndBitSet: TDSciLineEndType);
begin
  SendEditor(SCI_SETLINEENDTYPESALLOWED, WPARAM(TDSciLineEndTypeToInt(ALineEndBitSet)), 0);
end;

function TDScintilla.GetLineEndTypesAllowed: TDSciLineEndType;
begin
  Result := TDSciLineEndTypeFromInt(SendEditor(SCI_GETLINEENDTYPESALLOWED, 0, 0));
end;

function TDScintilla.GetLineEndTypesActive: TDSciLineEndType;
begin
  Result := TDSciLineEndTypeFromInt(SendEditor(SCI_GETLINEENDTYPESACTIVE, 0, 0));
end;

procedure TDScintilla.SetRepresentation(AEncodedCharacter: AnsiString; ARepresentation: AnsiString);
begin
  FHelper.SetTextA(SCI_SETREPRESENTATION, Integer(FHelper.GetPtrFromAStr(AEncodedCharacter)), ARepresentation);
end;

function TDScintilla.GetRepresentation(AEncodedCharacter: AnsiString): AnsiString;
begin
  FHelper.GetTextA(SCI_GETREPRESENTATION, Integer(FHelper.GetPtrFromAStr(AEncodedCharacter)), Result);
end;

procedure TDScintilla.SetRepresentationAppearance(AEncodedCharacter: UnicodeString; AAppearance: TDSciRepresentationAppearance);
begin
  SendEditor(SCI_SETREPRESENTATIONAPPEARANCE, WPARAM(AEncodedCharacter), LPARAM(TDSciRepresentationAppearanceToInt(AAppearance)));
end;

function TDScintilla.GetRepresentationAppearance(AEncodedCharacter: UnicodeString): TDSciRepresentationAppearance;
begin
  Result := TDSciRepresentationAppearanceFromInt(SendEditor(SCI_GETREPRESENTATIONAPPEARANCE, WPARAM(AEncodedCharacter), 0));
end;

procedure TDScintilla.SetRepresentationColour(AEncodedCharacter: UnicodeString; AColour: TDSciColourAlpha);
begin
  SendEditor(SCI_SETREPRESENTATIONCOLOUR, WPARAM(AEncodedCharacter), LPARAM(Integer(AColour)));
end;

function TDScintilla.GetRepresentationColour(AEncodedCharacter: UnicodeString): TDSciColourAlpha;
begin
  Result := TDSciColourAlpha(Integer(SendEditor(SCI_GETREPRESENTATIONCOLOUR, WPARAM(AEncodedCharacter), 0)));
end;

procedure TDScintilla.EOLAnnotationSetText(ALine: NativeInt; const AText: UnicodeString);
begin
  FHelper.SetText(SCI_EOLANNOTATIONSETTEXT, ALine, AText);
end;
function TDScintilla.EOLAnnotationGetText(ALine: NativeInt): UnicodeString;
begin
  FHelper.GetText(SCI_EOLANNOTATIONGETTEXT, ALine, Result);
end;
procedure TDScintilla.EOLAnnotationSetStyle(ALine: NativeInt; AStyle: Integer);
begin
  SendEditor(SCI_EOLANNOTATIONSETSTYLE, WPARAM(ALine), LPARAM(AStyle));
end;

function TDScintilla.EOLAnnotationGetStyle(ALine: NativeInt): Integer;
begin
  Result := SendEditor(SCI_EOLANNOTATIONGETSTYLE, WPARAM(ALine), 0);
end;

procedure TDScintilla.EOLAnnotationSetVisible(AVisible: TDSciEOLAnnotationVisible);
begin
  SendEditor(SCI_EOLANNOTATIONSETVISIBLE, WPARAM(TDSciEOLAnnotationVisibleToInt(AVisible)), 0);
end;

function TDScintilla.EOLAnnotationGetVisible: TDSciEOLAnnotationVisible;
begin
  Result := TDSciEOLAnnotationVisibleFromInt(SendEditor(SCI_EOLANNOTATIONGETVISIBLE, 0, 0));
end;

procedure TDScintilla.EOLAnnotationSetStyleOffset(AStyle: Integer);
begin
  SendEditor(SCI_EOLANNOTATIONSETSTYLEOFFSET, WPARAM(AStyle), 0);
end;

function TDScintilla.EOLAnnotationGetStyleOffset: Integer;
begin
  Result := SendEditor(SCI_EOLANNOTATIONGETSTYLEOFFSET, 0, 0);
end;

function TDScintilla.SupportsFeature(AFeature: TDSciSupports): Boolean;
begin
  Result := Boolean(SendEditor(SCI_SUPPORTSFEATURE, WPARAM(TDSciSupportsToInt(AFeature)), 0));
end;

function TDScintilla.GetLineCharacterIndex: TDSciLineCharacterIndexType;
begin
  Result := TDSciLineCharacterIndexTypeFromInt(SendEditor(SCI_GETLINECHARACTERINDEX, 0, 0));
end;

function TDScintilla.GetDragDropEnabled: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETDRAGDROPENABLED, 0, 0));
end;

procedure TDScintilla.SetDragDropEnabled(ADragDropEnabled: Boolean);
begin
  SendEditor(SCI_SETDRAGDROPENABLED, WPARAM(Ord(ADragDropEnabled)), 0);
end;

function TDScintilla.GetLexer: TDSciLexerId;
begin
  Result := TDSciLexerIdFromInt(SendEditor(SCI_GETLEXER, 0, 0));
end;

procedure TDScintilla.SetProperty(const AKey: UnicodeString; const AValue: UnicodeString);
begin
  if AKey <> '' then
    SendEditor(SCI_SETPROPERTY, WPARAM(AnsiString(AKey)), LPARAM(AnsiString(AValue)));
end;

procedure TDScintilla.SetKeyWords(AKeywordSet: Integer; const AKeyWords: UnicodeString);
begin
  FHelper.SetText(SCI_SETKEYWORDS, AKeywordSet, AKeyWords);
end;

function TDScintilla.GetProperty(const AKey: UnicodeString): UnicodeString;
begin
  if AKey = '' then
    Result := ''
  else
    FHelper.GetText(SCI_GETPROPERTY, LPARAM(AnsiString(AKey)), Result);
end;

function TDScintilla.GetPropertyExpanded(AKey: UnicodeString): UnicodeString;
begin
  if AKey = '' then
    Result := ''
  else
    FHelper.GetText(SCI_GETPROPERTYEXPANDED, LPARAM(AnsiString(AKey)), Result);
end;

function TDScintilla.GetPropertyInt(AKey: UnicodeString; ADefault: Integer): Integer;
begin
  if AKey = '' then
    Result := ADefault
  else
    Result := SendEditor(SCI_GETPROPERTYINT, WPARAM(AnsiString(AKey)), ADefault);
end;

function TDScintilla.GetLexerLanguage: UnicodeString;
begin
  FHelper.GetText(SCI_GETLEXERLANGUAGE, 0, Result);
  if (Result = '') and (FActiveLexerLanguage <> '') then
    Result := FActiveLexerLanguage;
end;

function TDScintilla.GetLineEndTypesSupported: TDSciLineEndType;
begin
  Result := TDSciLineEndTypeFromInt(SendEditor(SCI_GETLINEENDTYPESSUPPORTED, 0, 0));
end;

function TDScintilla.GetSubStylesStart(AStyleBase: Integer): Integer;
begin
  Result := SendEditor(SCI_GETSUBSTYLESSTART, WPARAM(AStyleBase), 0);
end;

function TDScintilla.GetSubStylesLength(AStyleBase: Integer): Integer;
begin
  Result := SendEditor(SCI_GETSUBSTYLESLENGTH, WPARAM(AStyleBase), 0);
end;

function TDScintilla.GetStyleFromSubStyle(ASubStyle: Integer): Integer;
begin
  Result := SendEditor(SCI_GETSTYLEFROMSUBSTYLE, WPARAM(ASubStyle), 0);
end;

function TDScintilla.GetPrimaryStyleFromStyle(AStyle: Integer): Integer;
begin
  Result := SendEditor(SCI_GETPRIMARYSTYLEFROMSTYLE, WPARAM(AStyle), 0);
end;

procedure TDScintilla.SetIdentifiers(AStyle: Integer; const AIdentifiers: AnsiString);
begin
  FHelper.SetTextA(SCI_SETIDENTIFIERS, AStyle, AIdentifiers);
end;

function TDScintilla.DistanceToSecondaryStyles: Integer;
begin
  Result := SendEditor(SCI_DISTANCETOSECONDARYSTYLES, 0, 0);
end;

function TDScintilla.GetSubStyleBases: UnicodeString;
begin
  FHelper.GetText(SCI_GETSUBSTYLEBASES, 0, Result);
end;

function TDScintilla.GetNamedStyles: Integer;
begin
  Result := SendEditor(SCI_GETNAMEDSTYLES, 0, 0);
end;

function TDScintilla.GetBidirectional: TDSciBidirectional;
begin
  Result := TDSciBidirectionalFromInt(SendEditor(SCI_GETBIDIRECTIONAL, 0, 0));
end;

procedure TDScintilla.SetBidirectional(ABidirectional: TDSciBidirectional);
begin
  SendEditor(SCI_SETBIDIRECTIONAL, WPARAM(TDSciBidirectionalToInt(ABidirectional)), 0);
end;

procedure TDScintilla.SetStyleBits(ABits: Integer);
begin
  SendEditor(SCI_SETSTYLEBITS, WPARAM(ABits), 0);
end;

function TDScintilla.GetStyleBits: Integer;
begin
  Result := SendEditor(SCI_GETSTYLEBITS, 0, 0);
end;

function TDScintilla.GetStyleBitsNeeded: Integer;
begin
  Result := SendEditor(SCI_GETSTYLEBITSNEEDED, 0, 0);
end;

procedure TDScintilla.SetKeysUnicode(AKeysUnicode: Boolean);
begin
  SendEditor(SCI_SETKEYSUNICODE, WPARAM(Ord(AKeysUnicode)), 0);
end;

function TDScintilla.GetKeysUnicode: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETKEYSUNICODE, 0, 0));
end;

function TDScintilla.GetTwoPhaseDraw: Boolean;
begin
  Result := Boolean(SendEditor(SCI_GETTWOPHASEDRAW, 0, 0));
end;

procedure TDScintilla.SetTwoPhaseDraw(ATwoPhase: Boolean);
begin
  SendEditor(SCI_SETTWOPHASEDRAW, WPARAM(Ord(ATwoPhase)), 0);
end;

procedure TDScintilla.SetLexerLanguage(const ALanguage: UnicodeString);
var
  lConfigGroup: TDSciVisualStyleGroup;
  lConfigObject: TObject;
  lDllPath: string;
  lLexilla: TDLexilla;
  lLexer: TDSciLexer;
  lRuntimeLanguage: UnicodeString;
  lResolvedLanguage: UnicodeString;
begin
  FRequestedLexerLanguage := Trim(ALanguage);
  lRuntimeLanguage := FRequestedLexerLanguage;
  if FRequestedLexerLanguage = '' then
  begin
    FActiveLexerLanguage := '';
    SetILexer(nil);
    Exit;
  end;

  lConfigGroup := nil;
  lConfigObject := nil;
  lDllPath := ResolveDllModulePath;
  lLexilla := Lexilla;
  if lDllPath <> '' then
    lLexilla.DllModule := lDllPath;

  if Assigned(FSettings) and FSettings.GetCurrentConfig(lConfigObject) and
    (lConfigObject is TDSciVisualConfig) then
    lConfigGroup := TDSciVisualConfig(lConfigObject).StyleOverrides.FindGroup(
      FRequestedLexerLanguage);

  if (lConfigGroup <> nil) and lConfigGroup.HasLexerID then
    if lConfigGroup.LexerID = Integer(sclNULL) then
    begin
      DSciLog('Keeping requested language "' +
        string(FRequestedLexerLanguage) +
        '" on the plain/null runtime lexer because config maps it to SCLEX_NULL.',
        cSciBridgeLogInfo);
      FActiveLexerLanguage := '';
      SetILexer(nil);
      Exit;
    end
    else
      try
        lResolvedLanguage := Trim(lLexilla.LexerNameFromID(lConfigGroup.LexerID));
        if lResolvedLanguage <> '' then
        begin
          if not SameText(lResolvedLanguage, lRuntimeLanguage) then
            DSciLog('Mapping requested language "' +
              string(FRequestedLexerLanguage) + '" to runtime lexer "' +
              string(lResolvedLanguage) + '" from LexerID ' +
              IntToStr(lConfigGroup.LexerID) + '.', cSciBridgeLogInfo);
          lRuntimeLanguage := lResolvedLanguage;
        end;
      except
        on E: Exception do
          DSciLog('Could not resolve runtime lexer for "' +
            string(FRequestedLexerLanguage) + '" from LexerID ' +
            IntToStr(lConfigGroup.LexerID) + ': ' + E.Message, cSciBridgeLogError);
      end;

  // SCI_SETLEXERLANGUAGE (4006) and SCI_LOADLEXERLIBRARY (4007) were
  // removed in Scintilla 5.x and are silently ignored.  Always create a fresh
  // lexer instance via Lexilla.CreateLexer so the editor receives the requested
  // lexer reliably on every call — not only the first time.  Callers (Reapply)
  // re-apply fold properties and Colourise after this, so the new instance is
  // fully configured before the user sees it.
  DSciLog('Creating lexer "' + string(lRuntimeLanguage) +
    '" via Lexilla.CreateLexer.', cSciBridgeLogInfo);
  lLexer := lLexilla.CreateLexer(lRuntimeLanguage);
  if Pointer(lLexer) = nil then
    raise EInvalidOpException.Create('Lexilla lexer "' +
      string(lRuntimeLanguage) + '" is not available.');
  SetILexer(Pointer(lLexer));
  FActiveLexerLanguage := lRuntimeLanguage;
end;

