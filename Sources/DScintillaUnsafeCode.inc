function TDScintilla.GetDirectFunction: TDScintillaFunction;
begin
  Result := TDScintillaFunction(SendEditor(SCI_GETDIRECTFUNCTION, 0, 0));
end;

function TDScintilla.GetDirectStatusFunction: TDScintillaStatusFunction;
begin
  Result := TDScintillaStatusFunction(SendEditor(SCI_GETDIRECTSTATUSFUNCTION, 0, 0));
end;
function TDScintilla.GetDirectPointer: Pointer;
begin
  Result := Pointer(SendEditor(SCI_GETDIRECTPOINTER, 0, 0));
end;

function TDScintilla.GetDocPointer: TDSciDocument;
begin
  Result := TDSciDocument(SendEditor(SCI_GETDOCPOINTER, 0, 0));
end;

procedure TDScintilla.SetDocPointer(APointer: TDSciDocument);
begin
  if APointer <> nil then
    SendEditor(SCI_SETDOCPOINTER, 0, LPARAM(APointer));
end;

function TDScintilla.CreateDocument: TDSciDocument;
begin
  Result := TDSciDocument(SendEditor(SCI_CREATEDOCUMENT, 0, 0));
end;

procedure TDScintilla.AddRefDocument(ADoc: TDSciDocument);
begin
  if ADoc <>  nil then
    SendEditor(SCI_ADDREFDOCUMENT, 0, LPARAM(ADoc));
end;

procedure TDScintilla.ReleaseDocument(ADoc: TDSciDocument);
begin
  if ADoc <> nil then
    SendEditor(SCI_RELEASEDOCUMENT, 0, LPARAM(ADoc));
end;

function TDScintilla.GetCharacterPointer: PByte;
begin
  Result := PByte(SendEditor(SCI_GETCHARACTERPOINTER, 0, 0));
end;

function TDScintilla.GetRangePointer(APosition: NativeInt; ARangeLength: NativeInt): Pointer;
begin
  Result := Pointer(SendEditor(SCI_GETRANGEPOINTER, APosition, ARangeLength));
end;

function TDScintilla.CreateLoader(ABytes: NativeInt): Pointer;
begin
  Result := Pointer(SendEditor(SCI_CREATELOADER, ABytes, 0));
end;

procedure TDScintilla.SetILexer(AIlexer: Pointer);
begin
  SendEditor(SCI_SETILEXER, 0, LPARAM(NativeInt(AIlexer)));
end;

