procedure TDScintilla.AddText(const AText: UnicodeString);
begin
  FHelper.SetTextLen(SCI_ADDTEXT, AText);
end;

procedure TDScintilla.AddStyledText(const ACells: TDSciCells);
begin
  SendEditor(SCI_ADDSTYLEDTEXT, System.Length(ACells) * 2, LPARAM(ACells));
end;

procedure TDScintilla.InsertText(APos: NativeInt; const AText: UnicodeString);
begin
  FHelper.SetText(SCI_INSERTTEXT, APos, AText);
end;

procedure TDScintilla.ChangeInsertion(const AText: UnicodeString);
begin
  FHelper.SetTextLen(SCI_CHANGEINSERTION, AText);
end;

procedure TDScintilla.ClearAll;
begin
  SendEditor(SCI_CLEARALL, 0, 0);
end;

procedure TDScintilla.DeleteRange(AStart: NativeInt; ALengthDelete: NativeInt);
begin
  SendEditor(SCI_DELETERANGE, WPARAM(AStart), LPARAM(ALengthDelete));
end;

procedure TDScintilla.ClearDocumentStyle;
begin
  SendEditor(SCI_CLEARDOCUMENTSTYLE, 0, 0);
end;

procedure TDScintilla.Redo;
begin
  SendEditor(SCI_REDO, 0, 0);
end;

procedure TDScintilla.SelectAll;
begin
  SendEditor(SCI_SELECTALL, 0, 0);
end;

procedure TDScintilla.SetSavePoint;
begin
  SendEditor(SCI_SETSAVEPOINT, 0, 0);
end;

function TDScintilla.GetStyledText(AStart, AEnd: NativeInt): TDSciCells;
var
  lRange: TDSciTextRange;
begin
  if AStart >= AEnd then
  begin
    SetLength(Result, 0);
    Exit;
  end;

  SetLength(Result, AEnd - AStart + 1{nul});

  lRange.chrg.cpMin := AStart;
  lRange.chrg.cpMax := AEnd;
  lRange.lpstrText := @Result[0];

  SendEditor(SCI_GETSTYLEDTEXT, 0, LPARAM(@lRange));
end;

function TDScintilla.GetStyledTextFull(AStart, AEnd: NativeInt): TDSciCells;
var
  lRange: TDSciTextRangeFull;
begin
  if AStart >= AEnd then
  begin
    SetLength(Result, 0);
    Exit;
  end;

  SetLength(Result, AEnd - AStart + 1{nul});

  lRange.chrg.cpMin := AStart;
  lRange.chrg.cpMax := AEnd;
  lRange.lpstrText := @Result[0];

  SendEditor(SCI_GETSTYLEDTEXTFULL, 0, LPARAM(@lRange));
end;
function TDScintilla.CanRedo: Boolean;
begin
  Result := Boolean(SendEditor(SCI_CANREDO, 0, 0));
end;

function TDScintilla.MarkerLineFromHandle(AMarkerHandle: Integer): NativeInt;
begin
  Result := SendEditor(SCI_MARKERLINEFROMHANDLE, WPARAM(AMarkerHandle), 0);
end;

procedure TDScintilla.MarkerDeleteHandle(AMarkerHandle: Integer);
begin
  SendEditor(SCI_MARKERDELETEHANDLE, WPARAM(AMarkerHandle), 0);
end;

function TDScintilla.MarkerHandleFromLine(ALine: NativeInt; AWhich: Integer): Integer;
begin
  Result := SendEditor(SCI_MARKERHANDLEFROMLINE, WPARAM(ALine), LPARAM(AWhich));
end;

function TDScintilla.MarkerNumberFromLine(ALine: NativeInt; AWhich: Integer): Integer;
begin
  Result := SendEditor(SCI_MARKERNUMBERFROMLINE, WPARAM(ALine), LPARAM(AWhich));
end;

function TDScintilla.PositionFromPoint(AX: Integer; AY: Integer): NativeInt;
begin
  Result := SendEditor(SCI_POSITIONFROMPOINT, WPARAM(AX), LPARAM(AY));
end;

function TDScintilla.PositionFromPointClose(AX: Integer; AY: Integer): NativeInt;
begin
  Result := SendEditor(SCI_POSITIONFROMPOINTCLOSE, WPARAM(AX), LPARAM(AY));
end;

procedure TDScintilla.GotoLine(ALine: NativeInt);
begin
  SendEditor(SCI_GOTOLINE, WPARAM(ALine), 0);
end;

procedure TDScintilla.GotoPos(ACaret: NativeInt);
begin
  SendEditor(SCI_GOTOPOS, WPARAM(ACaret), 0);
end;

function TDScintilla.GetCurLine(var AText: UnicodeString): NativeInt;
begin
  Result := FHelper.GetTextLen(SCI_GETCURLINE, AText);
end;

procedure TDScintilla.ConvertEOLs(AEolMode: TDSciEndOfLine);
begin
  SendEditor(SCI_CONVERTEOLS, WPARAM(TDSciEndOfLineToInt(AEolMode)), 0);
end;

procedure TDScintilla.StartStyling(AStart: NativeInt; AUnused: Integer);
begin
  SendEditor(SCI_STARTSTYLING, WPARAM(AStart), LPARAM(AUnused));
end;

procedure TDScintilla.SetStyling(ALength: NativeInt; AStyle: Integer);
begin
  SendEditor(SCI_SETSTYLING, WPARAM(ALength), LPARAM(AStyle));
end;

procedure TDScintilla.ClearTabStops(ALine: NativeInt);
begin
  SendEditor(SCI_CLEARTABSTOPS, WPARAM(ALine), 0);
end;

procedure TDScintilla.AddTabStop(ALine: NativeInt; AX: Integer);
begin
  SendEditor(SCI_ADDTABSTOP, WPARAM(ALine), LPARAM(AX));
end;

function TDScintilla.GetNextTabStop(ALine: NativeInt; AX: Integer): Integer;
begin
  Result := SendEditor(SCI_GETNEXTTABSTOP, WPARAM(ALine), LPARAM(AX));
end;

procedure TDScintilla.MarkerDefine(AMarkerNumber: Integer; AMarkerSymbol: TDSciMarkerSymbol);
begin
  SendEditor(SCI_MARKERDEFINE, WPARAM(AMarkerNumber), LPARAM(TDSciMarkerSymbolToInt(AMarkerSymbol)));
end;

procedure TDScintilla.MarkerEnableHighlight(AEnabled: Boolean);
begin
  SendEditor(SCI_MARKERENABLEHIGHLIGHT, WPARAM(Ord(AEnabled)), 0);
end;

function TDScintilla.MarkerAdd(ALine: NativeInt; AMarkerNumber: Integer): Integer;
begin
  Result := SendEditor(SCI_MARKERADD, WPARAM(ALine), LPARAM(AMarkerNumber));
end;

procedure TDScintilla.MarkerDelete(ALine: NativeInt; AMarkerNumber: Integer);
begin
  SendEditor(SCI_MARKERDELETE, WPARAM(ALine), LPARAM(AMarkerNumber));
end;

procedure TDScintilla.MarkerDeleteAll(AMarkerNumber: Integer);
begin
  SendEditor(SCI_MARKERDELETEALL, WPARAM(AMarkerNumber), 0);
end;

function TDScintilla.MarkerGet(ALine: NativeInt): Integer;
begin
  Result := SendEditor(SCI_MARKERGET, WPARAM(ALine), 0);
end;

function TDScintilla.MarkerNext(ALineStart: NativeInt; AMarkerMask: Integer): NativeInt;
begin
  Result := SendEditor(SCI_MARKERNEXT, WPARAM(ALineStart), LPARAM(AMarkerMask));
end;

function TDScintilla.MarkerPrevious(ALineStart: NativeInt; AMarkerMask: Integer): NativeInt;
begin
  Result := SendEditor(SCI_MARKERPREVIOUS, WPARAM(ALineStart), LPARAM(AMarkerMask));
end;

procedure TDScintilla.MarkerDefinePixmap(AMarkerNumber: Integer; const APixmap: TBytes);
begin
  SendEditor(SCI_MARKERDEFINEPIXMAP, AMarkerNumber, LPARAM(APixmap));
end;

procedure TDScintilla.MarkerAddSet(ALine: NativeInt; AMarkerSet: Integer);
begin
  SendEditor(SCI_MARKERADDSET, WPARAM(ALine), LPARAM(AMarkerSet));
end;

procedure TDScintilla.StyleClearAll;
begin
  SendEditor(SCI_STYLECLEARALL, 0, 0);
end;

procedure TDScintilla.StyleResetDefault;
begin
  SendEditor(SCI_STYLERESETDEFAULT, 0, 0);
end;

procedure TDScintilla.ResetElementColour(AElement: TDSciElement);
begin
  SendEditor(SCI_RESETELEMENTCOLOUR, WPARAM(TDSciElementToInt(AElement)), 0);
end;

procedure TDScintilla.SetSelFore(AUseSetting: Boolean; AFore: TColor);
begin
  SendEditor(SCI_SETSELFORE, WPARAM(Ord(AUseSetting)), LPARAM(Integer(AFore)));
end;

procedure TDScintilla.SetSelBack(AUseSetting: Boolean; ABack: TColor);
begin
  SendEditor(SCI_SETSELBACK, WPARAM(Ord(AUseSetting)), LPARAM(Integer(ABack)));
end;

procedure TDScintilla.AssignCmdKey(AKeyDefinition: Integer; ASciCommand: Integer);
begin
  SendEditor(SCI_ASSIGNCMDKEY, WPARAM(AKeyDefinition), LPARAM(ASciCommand));
end;

procedure TDScintilla.ClearCmdKey(AKeyDefinition: Integer);
begin
  SendEditor(SCI_CLEARCMDKEY, WPARAM(AKeyDefinition), 0);
end;

procedure TDScintilla.ClearAllCmdKeys;
begin
  SendEditor(SCI_CLEARALLCMDKEYS, 0, 0);
end;

procedure TDScintilla.SetStylingEx(const AStyles: TDSciStyles);
begin
  SendEditor(SCI_SETSTYLINGEX, System.Length(AStyles), LPARAM(AStyles));
end;

procedure TDScintilla.BeginUndoAction;
begin
  SendEditor(SCI_BEGINUNDOACTION, 0, 0);
end;

procedure TDScintilla.EndUndoAction;
begin
  SendEditor(SCI_ENDUNDOACTION, 0, 0);
end;

procedure TDScintilla.PushUndoActionType(AType: Integer; APos: NativeInt);
begin
  SendEditor(SCI_PUSHUNDOACTIONTYPE, WPARAM(AType), LPARAM(APos));
end;

procedure TDScintilla.ChangeLastUndoActionText(const AText: UnicodeString);
begin
  FHelper.SetTextLen(SCI_CHANGELASTUNDOACTIONTEXT, AText);
end;
procedure TDScintilla.SetWhitespaceFore(AUseSetting: Boolean; AFore: TColor);
begin
  SendEditor(SCI_SETWHITESPACEFORE, WPARAM(Ord(AUseSetting)), LPARAM(Integer(AFore)));
end;

procedure TDScintilla.SetWhitespaceBack(AUseSetting: Boolean; ABack: TColor);
begin
  SendEditor(SCI_SETWHITESPACEBACK, WPARAM(Ord(AUseSetting)), LPARAM(Integer(ABack)));
end;

procedure TDScintilla.AutoCShow(ALenEntered: NativeInt; const AItemList: UnicodeString);
begin
  FHelper.SetText(SCI_AUTOCSHOW, ALenEntered, AItemList);
end;

procedure TDScintilla.AutoCCancel;
begin
  SendEditor(SCI_AUTOCCANCEL, 0, 0);
end;

function TDScintilla.AutoCActive: Boolean;
begin
  Result := Boolean(SendEditor(SCI_AUTOCACTIVE, 0, 0));
end;

function TDScintilla.AutoCPosStart: NativeInt;
begin
  Result := SendEditor(SCI_AUTOCPOSSTART, 0, 0);
end;

procedure TDScintilla.AutoCComplete;
begin
  SendEditor(SCI_AUTOCCOMPLETE, 0, 0);
end;

procedure TDScintilla.AutoCStops(const ACharacterSet: UnicodeString);
begin
  FHelper.SetText(SCI_AUTOCSTOPS, 0, ACharacterSet);
end;

procedure TDScintilla.AutoCSelect(const AText: UnicodeString);
begin
  FHelper.SetText(SCI_AUTOCSELECT, 0, AText);
end;

procedure TDScintilla.UserListShow(AListType: Integer; const AItemList: UnicodeString);
begin
  FHelper.SetText(SCI_USERLISTSHOW, AListType, AItemList);
end;

procedure TDScintilla.RegisterImage(AType: Integer; const AXpmData: TBytes);
begin
  if Length(AXpmData) > 0 then
    SendEditor(SCI_REGISTERIMAGE, AType, LPARAM(@AXpmData[0]));
end;

procedure TDScintilla.ClearRegisteredImages;
begin
  SendEditor(SCI_CLEARREGISTEREDIMAGES, 0, 0);
end;

function TDScintilla.CountCharacters(AStart: NativeInt; AEnd: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_COUNTCHARACTERS, WPARAM(AStart), LPARAM(AEnd));
end;

function TDScintilla.CountCodeUnits(AStart: NativeInt; AEnd: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_COUNTCODEUNITS, WPARAM(AStart), LPARAM(AEnd));
end;

procedure TDScintilla.SetEmptySelection(ACaret: NativeInt);
begin
  SendEditor(SCI_SETEMPTYSELECTION, WPARAM(ACaret), 0);
end;

function TDScintilla.FindText(AFlags: Integer; const AText: UnicodeString; var ARange: TDSciCharacterRange): NativeInt;
var
  lRange: TDSciTextToFind;
begin
  lRange.chrg := ARange;
  if SendEditor(SCI_GETCODEPAGE) = SC_CP_UTF8 then
  begin
    lRange.lpstrText := PAnsiChar(UnicodeStringToUTF8(AText));
    Result := SendEditor(SCI_FINDTEXT, AFlags, LPARAM(@lRange));
  end else
  begin
    lRange.lpstrText := PAnsiChar(AnsiString(AText));
    Result := SendEditor(SCI_FINDTEXT, AFlags, LPARAM(@lRange));
  end;

  if Result > INVALID_POSITION then
    ARange := lRange.chrgText;
end;

function TDScintilla.FindTextFull(AFlags: Integer; const AText: UnicodeString; var ARange: TDSciCharacterRangeFull): NativeInt;
var
  lRange: TDSciTextToFindFull;
begin
  lRange.chrg := ARange;
  if SendEditor(SCI_GETCODEPAGE) = SC_CP_UTF8 then
  begin
    lRange.lpstrText := PAnsiChar(UnicodeStringToUTF8(AText));
    Result := SendEditor(SCI_FINDTEXTFULL, AFlags, LPARAM(@lRange));
  end else
  begin
    lRange.lpstrText := PAnsiChar(AnsiString(AText));
    Result := SendEditor(SCI_FINDTEXTFULL, AFlags, LPARAM(@lRange));
  end;

  if Result > INVALID_POSITION then
    ARange := lRange.chrgText;
end;
function TDScintilla.FormatRange(ADraw: Boolean; var AFr: TDSciRangeToFormat): NativeInt;
begin
  Result := SendEditor(SCI_FORMATRANGE, Ord(ADraw), LPARAM(@AFr));
end;

function TDScintilla.FormatRangeFull(ADraw: Boolean; var AFr: TDSciRangeToFormatFull): NativeInt;
begin
  Result := SendEditor(SCI_FORMATRANGEFULL, Ord(ADraw), LPARAM(@AFr));
end;
function TDScintilla.GetLine(ALine: NativeInt): UnicodeString;
begin
  FHelper.GetText(SCI_GETLINE, ALine, Result);
end;

procedure TDScintilla.SetSel(AAnchor: NativeInt; ACaret: NativeInt);
begin
  SendEditor(SCI_SETSEL, WPARAM(AAnchor), LPARAM(ACaret));
end;

function TDScintilla.GetSelText: UnicodeString;
begin
  FHelper.GetText(SCI_GETSELTEXT, 0, Result);
end;

function TDScintilla.GetTextRange(AStart, AEnd: NativeInt): UnicodeString;
var
  lRange: TDSciTextRange;
  lChars: TDSciChars;
  lActualLength: NativeInt;
begin
  Result := '';

  if AEnd = -1 then
    AEnd := GetLength
  else
    if AEnd > GetLength then
      Exit;

  if (AStart < 0) or (AEnd < 0) or (AStart >= AEnd) then
    Exit;

  SetLength(lChars, AEnd - AStart + 1); // to handle case when text is zero-terminated, as per the Scintilla docs for SCI_GETTEXTRANGE

  lRange.chrg.cpMin := AStart;
  lRange.chrg.cpMax := AEnd;
  lRange.lpstrText := @lChars[0];

  lActualLength := SendEditor(SCI_GETTEXTRANGE, 0, LPARAM(@lRange));
  lChars[lActualLength] := #0;

  Result := FHelper.GetStrFromPtr(@lChars[0]);
end;

function TDScintilla.GetTextRangeFull(AStart, AEnd: NativeInt): UnicodeString;
var
  lRange: TDSciTextRangeFull;
  lChars: TDSciChars;
  lActualLength: NativeInt;
begin
  Result := '';

  if AEnd = -1 then
    AEnd := GetLength
  else
    if AEnd > GetLength then
      Exit;

  if (AStart < 0) or (AEnd < 0) or (AStart >= AEnd) then
    Exit;

  SetLength(lChars, AEnd - AStart + 1);

  lRange.chrg.cpMin := AStart;
  lRange.chrg.cpMax := AEnd;
  lRange.lpstrText := @lChars[0];

  lActualLength := SendEditor(SCI_GETTEXTRANGEFULL, 0, LPARAM(@lRange));
  lChars[lActualLength] := #0;

  Result := FHelper.GetStrFromPtr(@lChars[0]);
end;
procedure TDScintilla.HideSelection(AHide: Boolean);
begin
  SendEditor(SCI_HIDESELECTION, WPARAM(Ord(AHide)), 0);
end;

function TDScintilla.PointXFromPosition(APos: NativeInt): Integer;
begin
  Result := SendEditor(SCI_POINTXFROMPOSITION, 0, LPARAM(APos));
end;

function TDScintilla.PointYFromPosition(APos: NativeInt): Integer;
begin
  Result := SendEditor(SCI_POINTYFROMPOSITION, 0, LPARAM(APos));
end;

function TDScintilla.LineFromPosition(APos: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_LINEFROMPOSITION, WPARAM(APos), 0);
end;

function TDScintilla.PositionFromLine(ALine: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_POSITIONFROMLINE, WPARAM(ALine), 0);
end;

procedure TDScintilla.LineScroll(AColumns: NativeInt; ALines: NativeInt);
begin
  SendEditor(SCI_LINESCROLL, WPARAM(AColumns), LPARAM(ALines));
end;

procedure TDScintilla.ScrollVertical(ADocLine: NativeInt; ASubLine: NativeInt);
begin
  SendEditor(SCI_SCROLLVERTICAL, WPARAM(ADocLine), LPARAM(ASubLine));
end;

procedure TDScintilla.ScrollCaret;
begin
  SendEditor(SCI_SCROLLCARET, 0, 0);
end;

procedure TDScintilla.ScrollRange(ASecondary: NativeInt; APrimary: NativeInt);
begin
  SendEditor(SCI_SCROLLRANGE, WPARAM(ASecondary), LPARAM(APrimary));
end;

procedure TDScintilla.ReplaceSel(const AText: UnicodeString);
begin
  FHelper.SetText(SCI_REPLACESEL, 0, AText);
end;

procedure TDScintilla.Null;
begin
  SendEditor(SCI_NULL, 0, 0);
end;

function TDScintilla.CanPaste: Boolean;
begin
  Result := Boolean(SendEditor(SCI_CANPASTE, 0, 0));
end;

function TDScintilla.CanUndo: Boolean;
begin
  Result := Boolean(SendEditor(SCI_CANUNDO, 0, 0));
end;

procedure TDScintilla.EmptyUndoBuffer;
begin
  SendEditor(SCI_EMPTYUNDOBUFFER, 0, 0);
end;

procedure TDScintilla.Undo;
begin
  SendEditor(SCI_UNDO, 0, 0);
end;

procedure TDScintilla.Cut;
begin
  SendEditor(SCI_CUT, 0, 0);
end;

procedure TDScintilla.Copy;
begin
  SendEditor(SCI_COPY, 0, 0);
end;

procedure TDScintilla.Paste;
begin
  SendEditor(SCI_PASTE, 0, 0);
end;

procedure TDScintilla.Clear;
begin
  SendEditor(SCI_CLEAR, 0, 0);
end;

procedure TDScintilla.SetText(const AText: UnicodeString);
begin
  FHelper.SetTextLen(SCI_SETTEXT, AText);
end;

function TDScintilla.GetText: UnicodeString;
begin
  FHelper.GetTextLen(SCI_GETTEXT, Result);
end;

procedure TDScintilla.SetTargetRange(AStart: NativeInt; AEnd: NativeInt);
begin
  SendEditor(SCI_SETTARGETRANGE, WPARAM(AStart), LPARAM(AEnd));
end;

procedure TDScintilla.TargetFromSelection;
begin
  SendEditor(SCI_TARGETFROMSELECTION, 0, 0);
end;

procedure TDScintilla.TargetWholeDocument;
begin
  SendEditor(SCI_TARGETWHOLEDOCUMENT, 0, 0);
end;

function TDScintilla.ReplaceTarget(const AText: UnicodeString): NativeInt;
begin
  Result := FHelper.SetTextLen(SCI_REPLACETARGET, AText);
end;

function TDScintilla.ReplaceTargetRE(const AText: UnicodeString): NativeInt;
begin
  Result := FHelper.SetTextLen(SCI_REPLACETARGETRE, AText);
end;

function TDScintilla.ReplaceTargetMinimal(const AText: UnicodeString): NativeInt;
begin
  Result := FHelper.SetTextLen(SCI_REPLACETARGETMINIMAL, AText);
end;
function TDScintilla.SearchInTarget(const AText: UnicodeString): NativeInt;
begin
  Result := FHelper.SetTextLen(SCI_SEARCHINTARGET, AText);
end;

procedure TDScintilla.CallTipShow(APos: NativeInt; const ADefinition: UnicodeString);
begin
  if ADefinition = '' then
    CallTipCancel
  else
    FHelper.SetText(SCI_CALLTIPSHOW, APos, ADefinition);
end;

procedure TDScintilla.CallTipCancel;
begin
  SendEditor(SCI_CALLTIPCANCEL, 0, 0);
end;

function TDScintilla.CallTipActive: Boolean;
begin
  Result := Boolean(SendEditor(SCI_CALLTIPACTIVE, 0, 0));
end;

procedure TDScintilla.CallTipSetHlt(AHighlightStart: NativeInt; AHighlightEnd: NativeInt);
begin
  SendEditor(SCI_CALLTIPSETHLT, WPARAM(AHighlightStart), LPARAM(AHighlightEnd));
end;

function TDScintilla.VisibleFromDocLine(ADocLine: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_VISIBLEFROMDOCLINE, WPARAM(ADocLine), 0);
end;

function TDScintilla.DocLineFromVisible(ADisplayLine: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_DOCLINEFROMVISIBLE, WPARAM(ADisplayLine), 0);
end;

function TDScintilla.WrapCount(ADocLine: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_WRAPCOUNT, WPARAM(ADocLine), 0);
end;

procedure TDScintilla.ShowLines(ALineStart: NativeInt; ALineEnd: NativeInt);
begin
  SendEditor(SCI_SHOWLINES, WPARAM(ALineStart), LPARAM(ALineEnd));
end;

procedure TDScintilla.HideLines(ALineStart: NativeInt; ALineEnd: NativeInt);
begin
  SendEditor(SCI_HIDELINES, WPARAM(ALineStart), LPARAM(ALineEnd));
end;

procedure TDScintilla.ToggleFold(ALine: NativeInt);
begin
  SendEditor(SCI_TOGGLEFOLD, WPARAM(ALine), 0);
end;

procedure TDScintilla.ToggleFoldShowText(ALine: NativeInt; AText: UnicodeString);
begin
  SendEditor(SCI_TOGGLEFOLDSHOWTEXT, WPARAM(ALine), LPARAM(AText));
end;

procedure TDScintilla.SetDefaultFoldDisplayText(AText: UnicodeString);
begin
  SendEditor(SCI_SETDEFAULTFOLDDISPLAYTEXT, 0, LPARAM(AText));
end;

function TDScintilla.GetDefaultFoldDisplayText(AText: PAnsiChar): Integer;
begin
  Result := SendEditor(SCI_GETDEFAULTFOLDDISPLAYTEXT, 0, LPARAM(AText));
end;

procedure TDScintilla.FoldLine(ALine: NativeInt; AAction: TDSciFoldAction);
begin
  SendEditor(SCI_FOLDLINE, WPARAM(ALine), LPARAM(TDSciFoldActionToInt(AAction)));
end;

procedure TDScintilla.FoldChildren(ALine: NativeInt; AAction: TDSciFoldAction);
begin
  SendEditor(SCI_FOLDCHILDREN, WPARAM(ALine), LPARAM(TDSciFoldActionToInt(AAction)));
end;

procedure TDScintilla.ExpandChildren(ALine: NativeInt; ALevel: TDSciFoldLevel);
begin
  SendEditor(SCI_EXPANDCHILDREN, WPARAM(ALine), LPARAM(TDSciFoldLevelToInt(ALevel)));
end;

procedure TDScintilla.FoldAll(AAction: TDSciFoldAction);
begin
  SendEditor(SCI_FOLDALL, WPARAM(TDSciFoldActionToInt(AAction)), 0);
end;

procedure TDScintilla.EnsureVisible(ALine: NativeInt);
begin
  SendEditor(SCI_ENSUREVISIBLE, WPARAM(ALine), 0);
end;

procedure TDScintilla.EnsureVisibleEnforcePolicy(ALine: NativeInt);
begin
  SendEditor(SCI_ENSUREVISIBLEENFORCEPOLICY, WPARAM(ALine), 0);
end;

function TDScintilla.WordStartPosition(APos: NativeInt; AOnlyWordCharacters: Boolean): NativeInt;
begin
  Result := SendEditor(SCI_WORDSTARTPOSITION, WPARAM(APos), LPARAM(Ord(AOnlyWordCharacters)));
end;

function TDScintilla.WordEndPosition(APos: NativeInt; AOnlyWordCharacters: Boolean): NativeInt;
begin
  Result := SendEditor(SCI_WORDENDPOSITION, WPARAM(APos), LPARAM(Ord(AOnlyWordCharacters)));
end;

function TDScintilla.IsRangeWord(AStart: NativeInt; AEnd: NativeInt): Boolean;
begin
  Result := Boolean(SendEditor(SCI_ISRANGEWORD, WPARAM(AStart), LPARAM(AEnd)));
end;

function TDScintilla.TextWidth(AStyle: Integer; const AText: UnicodeString): Integer;
begin
  Result := FHelper.SetText(SCI_TEXTWIDTH, AStyle, AText);
end;

function TDScintilla.TextHeight(ALine: NativeInt): Integer;
begin
  Result := SendEditor(SCI_TEXTHEIGHT, WPARAM(ALine), 0);
end;

procedure TDScintilla.AppendText(const AText: UnicodeString);
begin
  FHelper.SetTextLen(SCI_APPENDTEXT, AText);
end;

procedure TDScintilla.LinesJoin;
begin
  SendEditor(SCI_LINESJOIN, 0, 0);
end;

procedure TDScintilla.LinesSplit(APixelWidth: Integer);
begin
  SendEditor(SCI_LINESSPLIT, WPARAM(APixelWidth), 0);
end;

procedure TDScintilla.SetFoldMarginColour(AUseSetting: Boolean; ABack: TColor);
begin
  SendEditor(SCI_SETFOLDMARGINCOLOUR, WPARAM(Ord(AUseSetting)), LPARAM(Integer(ABack)));
end;

procedure TDScintilla.SetFoldMarginHiColour(AUseSetting: Boolean; AFore: TColor);
begin
  SendEditor(SCI_SETFOLDMARGINHICOLOUR, WPARAM(Ord(AUseSetting)), LPARAM(Integer(AFore)));
end;

procedure TDScintilla.LineDown;
begin
  SendEditor(SCI_LINEDOWN, 0, 0);
end;

procedure TDScintilla.LineDownExtend;
begin
  SendEditor(SCI_LINEDOWNEXTEND, 0, 0);
end;

procedure TDScintilla.LineUp;
begin
  SendEditor(SCI_LINEUP, 0, 0);
end;

procedure TDScintilla.LineUpExtend;
begin
  SendEditor(SCI_LINEUPEXTEND, 0, 0);
end;

procedure TDScintilla.CharLeft;
begin
  SendEditor(SCI_CHARLEFT, 0, 0);
end;

procedure TDScintilla.CharLeftExtend;
begin
  SendEditor(SCI_CHARLEFTEXTEND, 0, 0);
end;

procedure TDScintilla.CharRight;
begin
  SendEditor(SCI_CHARRIGHT, 0, 0);
end;

procedure TDScintilla.CharRightExtend;
begin
  SendEditor(SCI_CHARRIGHTEXTEND, 0, 0);
end;

procedure TDScintilla.WordLeft;
begin
  SendEditor(SCI_WORDLEFT, 0, 0);
end;

procedure TDScintilla.WordLeftExtend;
begin
  SendEditor(SCI_WORDLEFTEXTEND, 0, 0);
end;

procedure TDScintilla.WordRight;
begin
  SendEditor(SCI_WORDRIGHT, 0, 0);
end;

procedure TDScintilla.WordRightExtend;
begin
  SendEditor(SCI_WORDRIGHTEXTEND, 0, 0);
end;

procedure TDScintilla.Home;
begin
  SendEditor(SCI_HOME, 0, 0);
end;

procedure TDScintilla.HomeExtend;
begin
  SendEditor(SCI_HOMEEXTEND, 0, 0);
end;

procedure TDScintilla.LineEnd;
begin
  SendEditor(SCI_LINEEND, 0, 0);
end;

procedure TDScintilla.LineEndExtend;
begin
  SendEditor(SCI_LINEENDEXTEND, 0, 0);
end;

procedure TDScintilla.DocumentStart;
begin
  SendEditor(SCI_DOCUMENTSTART, 0, 0);
end;

procedure TDScintilla.DocumentStartExtend;
begin
  SendEditor(SCI_DOCUMENTSTARTEXTEND, 0, 0);
end;

procedure TDScintilla.DocumentEnd;
begin
  SendEditor(SCI_DOCUMENTEND, 0, 0);
end;

procedure TDScintilla.DocumentEndExtend;
begin
  SendEditor(SCI_DOCUMENTENDEXTEND, 0, 0);
end;

procedure TDScintilla.PageUp;
begin
  SendEditor(SCI_PAGEUP, 0, 0);
end;

procedure TDScintilla.PageUpExtend;
begin
  SendEditor(SCI_PAGEUPEXTEND, 0, 0);
end;

procedure TDScintilla.PageDown;
begin
  SendEditor(SCI_PAGEDOWN, 0, 0);
end;

procedure TDScintilla.PageDownExtend;
begin
  SendEditor(SCI_PAGEDOWNEXTEND, 0, 0);
end;

procedure TDScintilla.EditToggleOvertype;
begin
  SendEditor(SCI_EDITTOGGLEOVERTYPE, 0, 0);
end;

procedure TDScintilla.Cancel;
begin
  SendEditor(SCI_CANCEL, 0, 0);
end;

procedure TDScintilla.DeleteBack;
begin
  SendEditor(SCI_DELETEBACK, 0, 0);
end;

procedure TDScintilla.Tab;
begin
  SendEditor(SCI_TAB, 0, 0);
end;

procedure TDScintilla.LineIndent;
begin
  SendEditor(SCI_LINEINDENT, 0, 0);
end;

procedure TDScintilla.BackTab;
begin
  SendEditor(SCI_BACKTAB, 0, 0);
end;

procedure TDScintilla.LineDedent;
begin
  SendEditor(SCI_LINEDEDENT, 0, 0);
end;

procedure TDScintilla.NewLine;
begin
  SendEditor(SCI_NEWLINE, 0, 0);
end;

procedure TDScintilla.FormFeed;
begin
  SendEditor(SCI_FORMFEED, 0, 0);
end;

procedure TDScintilla.VCHome;
begin
  SendEditor(SCI_VCHOME, 0, 0);
end;

procedure TDScintilla.VCHomeExtend;
begin
  SendEditor(SCI_VCHOMEEXTEND, 0, 0);
end;

procedure TDScintilla.ZoomIn;
begin
  SendEditor(SCI_ZOOMIN, 0, 0);
end;

procedure TDScintilla.ZoomOut;
begin
  SendEditor(SCI_ZOOMOUT, 0, 0);
end;

procedure TDScintilla.DelWordLeft;
begin
  SendEditor(SCI_DELWORDLEFT, 0, 0);
end;

procedure TDScintilla.DelWordRight;
begin
  SendEditor(SCI_DELWORDRIGHT, 0, 0);
end;

procedure TDScintilla.DelWordRightEnd;
begin
  SendEditor(SCI_DELWORDRIGHTEND, 0, 0);
end;

procedure TDScintilla.LineCut;
begin
  SendEditor(SCI_LINECUT, 0, 0);
end;

procedure TDScintilla.LineDelete;
begin
  SendEditor(SCI_LINEDELETE, 0, 0);
end;

procedure TDScintilla.LineTranspose;
begin
  SendEditor(SCI_LINETRANSPOSE, 0, 0);
end;

procedure TDScintilla.LineReverse;
begin
  SendEditor(SCI_LINEREVERSE, 0, 0);
end;

procedure TDScintilla.LineDuplicate;
begin
  SendEditor(SCI_LINEDUPLICATE, 0, 0);
end;

procedure TDScintilla.LowerCase;
begin
  SendEditor(SCI_LOWERCASE, 0, 0);
end;

procedure TDScintilla.UpperCase;
begin
  SendEditor(SCI_UPPERCASE, 0, 0);
end;

procedure TDScintilla.LineScrollDown;
begin
  SendEditor(SCI_LINESCROLLDOWN, 0, 0);
end;

procedure TDScintilla.LineScrollUp;
begin
  SendEditor(SCI_LINESCROLLUP, 0, 0);
end;

procedure TDScintilla.DeleteBackNotLine;
begin
  SendEditor(SCI_DELETEBACKNOTLINE, 0, 0);
end;

procedure TDScintilla.HomeDisplay;
begin
  SendEditor(SCI_HOMEDISPLAY, 0, 0);
end;

procedure TDScintilla.HomeDisplayExtend;
begin
  SendEditor(SCI_HOMEDISPLAYEXTEND, 0, 0);
end;

procedure TDScintilla.LineEndDisplay;
begin
  SendEditor(SCI_LINEENDDISPLAY, 0, 0);
end;

procedure TDScintilla.LineEndDisplayExtend;
begin
  SendEditor(SCI_LINEENDDISPLAYEXTEND, 0, 0);
end;

procedure TDScintilla.HomeWrap;
begin
  SendEditor(SCI_HOMEWRAP, 0, 0);
end;

procedure TDScintilla.HomeWrapExtend;
begin
  SendEditor(SCI_HOMEWRAPEXTEND, 0, 0);
end;

procedure TDScintilla.LineEndWrap;
begin
  SendEditor(SCI_LINEENDWRAP, 0, 0);
end;

procedure TDScintilla.LineEndWrapExtend;
begin
  SendEditor(SCI_LINEENDWRAPEXTEND, 0, 0);
end;

procedure TDScintilla.VCHomeWrap;
begin
  SendEditor(SCI_VCHOMEWRAP, 0, 0);
end;

procedure TDScintilla.VCHomeWrapExtend;
begin
  SendEditor(SCI_VCHOMEWRAPEXTEND, 0, 0);
end;

procedure TDScintilla.LineCopy;
begin
  SendEditor(SCI_LINECOPY, 0, 0);
end;

procedure TDScintilla.MoveCaretInsideView;
begin
  SendEditor(SCI_MOVECARETINSIDEVIEW, 0, 0);
end;

function TDScintilla.LineLength(ALine: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_LINELENGTH, WPARAM(ALine), 0);
end;

procedure TDScintilla.BraceHighlight(APosA: NativeInt; APosB: NativeInt);
begin
  SendEditor(SCI_BRACEHIGHLIGHT, WPARAM(APosA), LPARAM(APosB));
end;

procedure TDScintilla.BraceHighlightIndicator(AUseSetting: Boolean; AIndicator: Integer);
begin
  SendEditor(SCI_BRACEHIGHLIGHTINDICATOR, WPARAM(Ord(AUseSetting)), LPARAM(AIndicator));
end;

procedure TDScintilla.BraceBadLight(APos: NativeInt);
begin
  SendEditor(SCI_BRACEBADLIGHT, WPARAM(APos), 0);
end;

procedure TDScintilla.BraceBadLightIndicator(AUseSetting: Boolean; AIndicator: Integer);
begin
  SendEditor(SCI_BRACEBADLIGHTINDICATOR, WPARAM(Ord(AUseSetting)), LPARAM(AIndicator));
end;

function TDScintilla.BraceMatch(APos: NativeInt; AMaxReStyle: Integer): NativeInt;
begin
  Result := SendEditor(SCI_BRACEMATCH, WPARAM(APos), LPARAM(AMaxReStyle));
end;

function TDScintilla.BraceMatchNext(APos: NativeInt; AStartPos: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_BRACEMATCHNEXT, WPARAM(APos), LPARAM(AStartPos));
end;

procedure TDScintilla.MultiEdgeAddLine(AColumn: NativeInt; AEdgeColour: TColor);
begin
  SendEditor(SCI_MULTIEDGEADDLINE, WPARAM(AColumn), LPARAM(Integer(AEdgeColour)));
end;

procedure TDScintilla.MultiEdgeClearAll;
begin
  SendEditor(SCI_MULTIEDGECLEARALL, 0, 0);
end;

procedure TDScintilla.SearchAnchor;
begin
  SendEditor(SCI_SEARCHANCHOR, 0, 0);
end;

function TDScintilla.SearchNext(AFlags: Integer; const AText: UnicodeString): NativeInt;
begin
  Result := FHelper.SetText(SCI_SEARCHNEXT, AFlags, AText);
end;

function TDScintilla.SearchPrev(AFlags: Integer; const AText: UnicodeString): NativeInt;
begin
  Result := FHelper.SetText(SCI_SEARCHPREV, AFlags, AText);
end;

procedure TDScintilla.UsePopUp(APopUpMode: TDSciPopUp);
begin
  SendEditor(SCI_USEPOPUP, WPARAM(TDSciPopUpToInt(APopUpMode)), 0);
end;

procedure TDScintilla.WordPartLeft;
begin
  SendEditor(SCI_WORDPARTLEFT, 0, 0);
end;

procedure TDScintilla.WordPartLeftExtend;
begin
  SendEditor(SCI_WORDPARTLEFTEXTEND, 0, 0);
end;

procedure TDScintilla.WordPartRight;
begin
  SendEditor(SCI_WORDPARTRIGHT, 0, 0);
end;

procedure TDScintilla.WordPartRightExtend;
begin
  SendEditor(SCI_WORDPARTRIGHTEXTEND, 0, 0);
end;

procedure TDScintilla.SetVisiblePolicy(AVisiblePolicy: TDSciVisiblePolicySet; AVisibleSlop: Integer);
begin
  SendEditor(SCI_SETVISIBLEPOLICY, WPARAM(TDSciVisiblePolicySetToInt(AVisiblePolicy)), LPARAM(AVisibleSlop));
end;

procedure TDScintilla.DelLineLeft;
begin
  SendEditor(SCI_DELLINELEFT, 0, 0);
end;

procedure TDScintilla.DelLineRight;
begin
  SendEditor(SCI_DELLINERIGHT, 0, 0);
end;

procedure TDScintilla.ChooseCaretX;
begin
  SendEditor(SCI_CHOOSECARETX, 0, 0);
end;

procedure TDScintilla.GrabFocus;
begin
  SendEditor(SCI_GRABFOCUS, 0, 0);
end;

procedure TDScintilla.SetXCaretPolicy(ACaretPolicy: TDSciCaretPolicySet; ACaretSlop: Integer);
begin
  SendEditor(SCI_SETXCARETPOLICY, WPARAM(TDSciCaretPolicySetToInt(ACaretPolicy)), LPARAM(ACaretSlop));
end;

procedure TDScintilla.SetYCaretPolicy(ACaretPolicy: TDSciCaretPolicySet; ACaretSlop: Integer);
begin
  SendEditor(SCI_SETYCARETPOLICY, WPARAM(TDSciCaretPolicySetToInt(ACaretPolicy)), LPARAM(ACaretSlop));
end;

procedure TDScintilla.ParaDown;
begin
  SendEditor(SCI_PARADOWN, 0, 0);
end;

procedure TDScintilla.ParaDownExtend;
begin
  SendEditor(SCI_PARADOWNEXTEND, 0, 0);
end;

procedure TDScintilla.ParaUp;
begin
  SendEditor(SCI_PARAUP, 0, 0);
end;

procedure TDScintilla.ParaUpExtend;
begin
  SendEditor(SCI_PARAUPEXTEND, 0, 0);
end;

function TDScintilla.PositionBefore(APos: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_POSITIONBEFORE, WPARAM(APos), 0);
end;

function TDScintilla.PositionAfter(APos: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_POSITIONAFTER, WPARAM(APos), 0);
end;

function TDScintilla.PositionRelative(APos: NativeInt; ARelative: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_POSITIONRELATIVE, WPARAM(APos), LPARAM(ARelative));
end;

function TDScintilla.PositionRelativeCodeUnits(APos: NativeInt; ARelative: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_POSITIONRELATIVECODEUNITS, WPARAM(APos), LPARAM(ARelative));
end;

procedure TDScintilla.CopyRange(AStart: NativeInt; AEnd: NativeInt);
begin
  SendEditor(SCI_COPYRANGE, WPARAM(AStart), LPARAM(AEnd));
end;

procedure TDScintilla.CopyText(const AText: UnicodeString);
begin
  FHelper.SetTextLen(SCI_COPYTEXT, AText);
end;
procedure TDScintilla.ChangeSelectionMode(ASelectionMode: TDSciSelectionMode);
begin
  SendEditor(SCI_CHANGESELECTIONMODE, WPARAM(TDSciSelectionModeToInt(ASelectionMode)), 0);
end;

function TDScintilla.GetLineSelStartPosition(ALine: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_GETLINESELSTARTPOSITION, WPARAM(ALine), 0);
end;

function TDScintilla.GetLineSelEndPosition(ALine: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_GETLINESELENDPOSITION, WPARAM(ALine), 0);
end;

procedure TDScintilla.LineDownRectExtend;
begin
  SendEditor(SCI_LINEDOWNRECTEXTEND, 0, 0);
end;

procedure TDScintilla.LineUpRectExtend;
begin
  SendEditor(SCI_LINEUPRECTEXTEND, 0, 0);
end;

procedure TDScintilla.CharLeftRectExtend;
begin
  SendEditor(SCI_CHARLEFTRECTEXTEND, 0, 0);
end;

procedure TDScintilla.CharRightRectExtend;
begin
  SendEditor(SCI_CHARRIGHTRECTEXTEND, 0, 0);
end;

procedure TDScintilla.HomeRectExtend;
begin
  SendEditor(SCI_HOMERECTEXTEND, 0, 0);
end;

procedure TDScintilla.VCHomeRectExtend;
begin
  SendEditor(SCI_VCHOMERECTEXTEND, 0, 0);
end;

procedure TDScintilla.LineEndRectExtend;
begin
  SendEditor(SCI_LINEENDRECTEXTEND, 0, 0);
end;

procedure TDScintilla.PageUpRectExtend;
begin
  SendEditor(SCI_PAGEUPRECTEXTEND, 0, 0);
end;

procedure TDScintilla.PageDownRectExtend;
begin
  SendEditor(SCI_PAGEDOWNRECTEXTEND, 0, 0);
end;

procedure TDScintilla.StutteredPageUp;
begin
  SendEditor(SCI_STUTTEREDPAGEUP, 0, 0);
end;

procedure TDScintilla.StutteredPageUpExtend;
begin
  SendEditor(SCI_STUTTEREDPAGEUPEXTEND, 0, 0);
end;

procedure TDScintilla.StutteredPageDown;
begin
  SendEditor(SCI_STUTTEREDPAGEDOWN, 0, 0);
end;

procedure TDScintilla.StutteredPageDownExtend;
begin
  SendEditor(SCI_STUTTEREDPAGEDOWNEXTEND, 0, 0);
end;

procedure TDScintilla.WordLeftEnd;
begin
  SendEditor(SCI_WORDLEFTEND, 0, 0);
end;

procedure TDScintilla.WordLeftEndExtend;
begin
  SendEditor(SCI_WORDLEFTENDEXTEND, 0, 0);
end;

procedure TDScintilla.WordRightEnd;
begin
  SendEditor(SCI_WORDRIGHTEND, 0, 0);
end;

procedure TDScintilla.WordRightEndExtend;
begin
  SendEditor(SCI_WORDRIGHTENDEXTEND, 0, 0);
end;

procedure TDScintilla.SetCharsDefault;
begin
  SendEditor(SCI_SETCHARSDEFAULT, 0, 0);
end;

procedure TDScintilla.Allocate(ABytes: NativeInt);
begin
  SendEditor(SCI_ALLOCATE, WPARAM(ABytes), 0);
end;

function TDScintilla.TargetAsUTF8: UTF8String;
var
  lText: AnsiString;
begin
  FHelper.GetTextA(SCI_TARGETASUTF8, 0, lText);
  Result := UTF8String(lText);
end;
procedure TDScintilla.SetLengthForEncode(ABytes: NativeInt);
begin
  SendEditor(SCI_SETLENGTHFORENCODE, WPARAM(ABytes), 0);
end;

function TDScintilla.EncodedFromUTF8(const AUtf8: UTF8String): AnsiString;
begin
  FHelper.GetTextA(SCI_ENCODEDFROMUTF8, AnsiString(AUtf8), Result);
end;
function TDScintilla.FindColumn(ALine: NativeInt; AColumn: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_FINDCOLUMN, WPARAM(ALine), LPARAM(AColumn));
end;

procedure TDScintilla.ToggleCaretSticky;
begin
  SendEditor(SCI_TOGGLECARETSTICKY, 0, 0);
end;

procedure TDScintilla.ReplaceRectangular(ALength: NativeInt; AText: UnicodeString);
begin
  SendEditor(SCI_REPLACERECTANGULAR, WPARAM(ALength), LPARAM(AText));
end;

procedure TDScintilla.SelectionDuplicate;
begin
  SendEditor(SCI_SELECTIONDUPLICATE, 0, 0);
end;

procedure TDScintilla.IndicatorFillRange(AStart: NativeInt; ALengthFill: NativeInt);
begin
  SendEditor(SCI_INDICATORFILLRANGE, WPARAM(AStart), LPARAM(ALengthFill));
end;

procedure TDScintilla.IndicatorClearRange(AStart: NativeInt; ALengthClear: NativeInt);
begin
  SendEditor(SCI_INDICATORCLEARRANGE, WPARAM(AStart), LPARAM(ALengthClear));
end;

function TDScintilla.IndicatorAllOnFor(APos: NativeInt): Integer;
begin
  Result := SendEditor(SCI_INDICATORALLONFOR, WPARAM(APos), 0);
end;

function TDScintilla.IndicatorValueAt(AIndicator: Integer; APos: NativeInt): Integer;
begin
  Result := SendEditor(SCI_INDICATORVALUEAT, WPARAM(AIndicator), LPARAM(APos));
end;

function TDScintilla.IndicatorStart(AIndicator: Integer; APos: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_INDICATORSTART, WPARAM(AIndicator), LPARAM(APos));
end;

function TDScintilla.IndicatorEnd(AIndicator: Integer; APos: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_INDICATOREND, WPARAM(AIndicator), LPARAM(APos));
end;

procedure TDScintilla.CopyAllowLine;
begin
  SendEditor(SCI_COPYALLOWLINE, 0, 0);
end;

procedure TDScintilla.CutAllowLine;
begin
  SendEditor(SCI_CUTALLOWLINE, 0, 0);
end;

function TDScintilla.MarkerSymbolDefined(AMarkerNumber: Integer): TDSciMarkerSymbol;
begin
  Result := TDSciMarkerSymbolFromInt(SendEditor(SCI_MARKERSYMBOLDEFINED, WPARAM(AMarkerNumber), 0));
end;

procedure TDScintilla.MarginTextClearAll;
begin
  SendEditor(SCI_MARGINTEXTCLEARALL, 0, 0);
end;

procedure TDScintilla.AnnotationClearAll;
begin
  SendEditor(SCI_ANNOTATIONCLEARALL, 0, 0);
end;

procedure TDScintilla.ReleaseAllExtendedStyles;
begin
  SendEditor(SCI_RELEASEALLEXTENDEDSTYLES, 0, 0);
end;

function TDScintilla.AllocateExtendedStyles(ANumberStyles: Integer): Integer;
begin
  Result := SendEditor(SCI_ALLOCATEEXTENDEDSTYLES, WPARAM(ANumberStyles), 0);
end;

procedure TDScintilla.AddUndoAction(AToken: Integer; AFlags: TDSciUndoFlagsSet);
begin
  SendEditor(SCI_ADDUNDOACTION, WPARAM(AToken), LPARAM(TDSciUndoFlagsSetToInt(AFlags)));
end;

function TDScintilla.CharPositionFromPoint(AX: Integer; AY: Integer): NativeInt;
begin
  Result := SendEditor(SCI_CHARPOSITIONFROMPOINT, WPARAM(AX), LPARAM(AY));
end;

function TDScintilla.CharPositionFromPointClose(AX: Integer; AY: Integer): NativeInt;
begin
  Result := SendEditor(SCI_CHARPOSITIONFROMPOINTCLOSE, WPARAM(AX), LPARAM(AY));
end;

procedure TDScintilla.ClearSelections;
begin
  SendEditor(SCI_CLEARSELECTIONS, 0, 0);
end;

procedure TDScintilla.SetSelection(ACaret: NativeInt; AAnchor: NativeInt);
begin
  SendEditor(SCI_SETSELECTION, WPARAM(ACaret), LPARAM(AAnchor));
end;

procedure TDScintilla.AddSelection(ACaret: NativeInt; AAnchor: NativeInt);
begin
  SendEditor(SCI_ADDSELECTION, WPARAM(ACaret), LPARAM(AAnchor));
end;

function TDScintilla.SelectionFromPoint(AX: Integer; AY: Integer): Integer;
begin
  Result := SendEditor(SCI_SELECTIONFROMPOINT, WPARAM(AX), LPARAM(AY));
end;

procedure TDScintilla.DropSelectionN(ASelection: Integer);
begin
  SendEditor(SCI_DROPSELECTIONN, WPARAM(ASelection), 0);
end;

procedure TDScintilla.RotateSelection;
begin
  SendEditor(SCI_ROTATESELECTION, 0, 0);
end;

procedure TDScintilla.SwapMainAnchorCaret;
begin
  SendEditor(SCI_SWAPMAINANCHORCARET, 0, 0);
end;

procedure TDScintilla.MultipleSelectAddNext;
begin
  SendEditor(SCI_MULTIPLESELECTADDNEXT, 0, 0);
end;

procedure TDScintilla.MultipleSelectAddEach;
begin
  SendEditor(SCI_MULTIPLESELECTADDEACH, 0, 0);
end;

function TDScintilla.ChangeLexerState(AStart: NativeInt; AEnd: NativeInt): Integer;
begin
  Result := SendEditor(SCI_CHANGELEXERSTATE, WPARAM(AStart), LPARAM(AEnd));
end;

function TDScintilla.ContractedFoldNext(ALineStart: NativeInt): NativeInt;
begin
  Result := SendEditor(SCI_CONTRACTEDFOLDNEXT, WPARAM(ALineStart), 0);
end;

procedure TDScintilla.VerticalCentreCaret;
begin
  SendEditor(SCI_VERTICALCENTRECARET, 0, 0);
end;

procedure TDScintilla.MoveSelectedLinesUp;
begin
  SendEditor(SCI_MOVESELECTEDLINESUP, 0, 0);
end;

procedure TDScintilla.MoveSelectedLinesDown;
begin
  SendEditor(SCI_MOVESELECTEDLINESDOWN, 0, 0);
end;

procedure TDScintilla.MarkerDefineRGBAImage(AMarkerNumber: Integer; APixels: UnicodeString);
begin
  SendEditor(SCI_MARKERDEFINERGBAIMAGE, WPARAM(AMarkerNumber), LPARAM(APixels));
end;

procedure TDScintilla.RegisterRGBAImage(AType: Integer; APixels: UnicodeString);
begin
  SendEditor(SCI_REGISTERRGBAIMAGE, WPARAM(AType), LPARAM(APixels));
end;

procedure TDScintilla.ScrollToStart;
begin
  SendEditor(SCI_SCROLLTOSTART, 0, 0);
end;

procedure TDScintilla.ScrollToEnd;
begin
  SendEditor(SCI_SCROLLTOEND, 0, 0);
end;

// procedure TDScintilla.FindIndicatorShow(AStart: NativeInt; AEnd: NativeInt);
// begin
//   SendEditor(SCI_FINDINDICATORSHOW, WPARAM(AStart), LPARAM(AEnd));
// end;

// procedure TDScintilla.FindIndicatorFlash(AStart: NativeInt; AEnd: NativeInt);
// begin
//   SendEditor(SCI_FINDINDICATORFLASH, WPARAM(AStart), LPARAM(AEnd));
// end;

// procedure TDScintilla.FindIndicatorHide;
// begin
//   SendEditor(SCI_FINDINDICATORHIDE, 0, 0);
// end;

procedure TDScintilla.VCHomeDisplay;
begin
  SendEditor(SCI_VCHOMEDISPLAY, 0, 0);
end;

procedure TDScintilla.VCHomeDisplayExtend;
begin
  SendEditor(SCI_VCHOMEDISPLAYEXTEND, 0, 0);
end;

procedure TDScintilla.ClearRepresentation(AEncodedCharacter: AnsiString);
begin
  SendEditor(SCI_CLEARREPRESENTATION, Integer(FHelper.GetPtrFromAStr(AEncodedCharacter)), 0);
end;

procedure TDScintilla.ClearAllRepresentations;
begin
  SendEditor(SCI_CLEARALLREPRESENTATIONS, 0, 0);
end;

procedure TDScintilla.EOLAnnotationClearAll;
begin
  SendEditor(SCI_EOLANNOTATIONCLEARALL, 0, 0);
end;

procedure TDScintilla.AllocateLineCharacterIndex(ALineCharacterIndex: TDSciLineCharacterIndexType);
begin
  SendEditor(SCI_ALLOCATELINECHARACTERINDEX, WPARAM(TDSciLineCharacterIndexTypeToInt(ALineCharacterIndex)), 0);
end;

procedure TDScintilla.ReleaseLineCharacterIndex(ALineCharacterIndex: TDSciLineCharacterIndexType);
begin
  SendEditor(SCI_RELEASELINECHARACTERINDEX, WPARAM(TDSciLineCharacterIndexTypeToInt(ALineCharacterIndex)), 0);
end;

function TDScintilla.LineFromIndexPosition(APos: NativeInt; ALineCharacterIndex: TDSciLineCharacterIndexType): NativeInt;
begin
  Result := SendEditor(SCI_LINEFROMINDEXPOSITION, WPARAM(APos), LPARAM(TDSciLineCharacterIndexTypeToInt(ALineCharacterIndex)));
end;

function TDScintilla.IndexPositionFromLine(ALine: NativeInt; ALineCharacterIndex: TDSciLineCharacterIndexType): NativeInt;
begin
  Result := SendEditor(SCI_INDEXPOSITIONFROMLINE, WPARAM(ALine), LPARAM(TDSciLineCharacterIndexTypeToInt(ALineCharacterIndex)));
end;

procedure TDScintilla.StartRecord;
begin
  SendEditor(SCI_STARTRECORD, 0, 0);
end;

procedure TDScintilla.StopRecord;
begin
  SendEditor(SCI_STOPRECORD, 0, 0);
end;

procedure TDScintilla.Colourise(AStart: NativeInt; AEnd: NativeInt);
begin
  SendEditor(SCI_COLOURISE, WPARAM(AStart), LPARAM(AEnd));
end;

function TDScintilla.PrivateLexerCall(AOperation: Integer; APointer: Pointer): Pointer;
begin
  Result := Pointer(SendEditor(SCI_PRIVATELEXERCALL, WPARAM(AOperation), LPARAM(NativeInt(APointer))));
end;

function TDScintilla.PropertyNames: UnicodeString;
begin
  FHelper.GetText(SCI_PROPERTYNAMES, 0, Result);
end;

function TDScintilla.PropertyType(AName: UnicodeString): Integer;
begin
  if AName = '' then
    Result := -1
  else
    Result := SendEditor(SCI_PROPERTYTYPE, LPARAM(UnicodeStringToUTF8(AName)), 0);
end;

function TDScintilla.DescribeProperty(AName: UnicodeString): UnicodeString;
begin
  if AName = '' then
    Result := ''
  else
    FHelper.GetText(SCI_DESCRIBEPROPERTY, LPARAM(UnicodeStringToUTF8(AName)), Result);
end;

function TDScintilla.DescribeKeyWordSets: UnicodeString;
begin
  FHelper.GetText(SCI_DESCRIBEKEYWORDSETS, 0, Result);
end;

function TDScintilla.AllocateSubStyles(AStyleBase: Integer; ANumberStyles: Integer): Integer;
begin
  Result := SendEditor(SCI_ALLOCATESUBSTYLES, WPARAM(AStyleBase), LPARAM(ANumberStyles));
end;

procedure TDScintilla.FreeSubStyles;
begin
  SendEditor(SCI_FREESUBSTYLES, 0, 0);
end;

function TDScintilla.NameOfStyle(AStyle: Integer; AName: PAnsiChar): Integer;
begin
  Result := SendEditor(SCI_NAMEOFSTYLE, WPARAM(AStyle), LPARAM(AName));
end;

function TDScintilla.TagsOfStyle(AStyle: Integer; ATags: PAnsiChar): Integer;
begin
  Result := SendEditor(SCI_TAGSOFSTYLE, WPARAM(AStyle), LPARAM(ATags));
end;

function TDScintilla.DescriptionOfStyle(AStyle: Integer; ADescription: PAnsiChar): Integer;
begin
  Result := SendEditor(SCI_DESCRIPTIONOFSTYLE, WPARAM(AStyle), LPARAM(ADescription));
end;

procedure TDScintilla.LoadLexerLibrary(const APath: UnicodeString);
begin
  SendEditor(SCI_LOADLEXERLIBRARY, 0, LPARAM(AnsiString(APath)));
end;

