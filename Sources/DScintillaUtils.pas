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
 * The Original Code is DScintillaUtils.pas
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

unit DScintillaUtils;

{$IF CompilerVersion < 20}
  {$DEFINE DSCI_JCLWIDESTRINGS}
{$IFEND}

interface

uses
  Graphics, DScintillaTypes,

{$IF Defined(DSCI_JCLWIDESTRINGS)}
  JclWideStrings,
{$IFEND}

  SysUtils, Classes, Windows, Math;

const
  cDSciNull: AnsiChar = #0;

type

{ TDSciUnicodeStrings }

{$IF Defined(DSCI_JCLWIDESTRINGS)}
  TDSciUnicodeStrings = class(JclWideStrings.TJclWideStrings)
  public
    procedure LoadFromFile(const FileName: TFileName;
      WideFileOptions: TWideFileOptions = [foAnsiFile]); override;
    procedure LoadFromStream(Stream: TStream;
      WideFileOptions: TWideFileOptions = [foAnsiFile]); override;

    procedure SaveToFile(const FileName: TFileName;
      WideFileOptions: TWideFileOptions = [foAnsiFile]); override;
    procedure SaveToStream(Stream: TStream;
      WideFileOptions: TWideFileOptions = [foAnsiFile]); override;
  end;
{$ELSE}
  TDSciUnicodeStrings = TStrings;
{$IFEND}

{ TDSciHelper }

  TDSciHelper = class
  private
    FSendEditor: TDSciSendEditor;
  public
    constructor Create(ASendEditor: TDSciSendEditor);

    function SendEditor(AMessage: UINT;
      WParam: WPARAM = 0; LParam: LPARAM = 0): LRESULT;

    function IsUTF8: Boolean;

    function GetStrFromPtr(ABuf: PAnsiChar): UnicodeString;
    function GetStrFromPtrA(ABuf: PAnsiChar): AnsiString;
    function GetPtrFromAStr(AStr: AnsiString): PAnsiChar;

    function GetText(AMessage: Integer; AWParam: WPARAM; var AText: UnicodeString): Integer; overload;
    function GetText(AMessage: Integer; AWParam: UnicodeString; var AText: UnicodeString): Integer; overload;
    function GetTextA(AMessage: Integer; AWParam: WPARAM; var AText: AnsiString): Integer; overload;
    function GetTextA(AMessage: Integer; AWParam: AnsiString; var AText: AnsiString): Integer; overload;
    function SetText(AMessage: Integer; AWParam: WPARAM; const AText: UnicodeString): Integer; overload;
    function SetText(AMessage: Integer; AWParam: UnicodeString; const AText: UnicodeString): Integer; overload;
    function SetTextA(AMessage: Integer; AWParam: WPARAM; const AText: AnsiString): Integer; overload;
    function SetTextA(AMessage: Integer; AWParam: AnsiString; const AText: AnsiString): Integer; overload;
    function GetTextLen(AMessage: Integer; var AText: UnicodeString): NativeInt;
    function SetTextLen(AMessage: Integer; const AText: UnicodeString): NativeInt;

    function SetTargetLine(ALine: Integer): Boolean;
  end;

{ TDSciLines }

  TDSciLines = class(TDSciUnicodeStrings)
  protected
    FHelper: TDSciHelper;
{$IFDEF DSCI_JCLWIDESTRINGS}
    FLastGetP: UnicodeString;
{$ENDIF}

    function GetTextStr: UnicodeString; override;
    procedure SetTextStr(const AValue: UnicodeString); override;

    function GetCount: Integer; override;

{$IFDEF DSCI_JCLWIDESTRINGS}
    // DON'T CALL GetP DIRECTLY
    // After second call, pointer from first call is invalid!
    function GetP(AIndex: Integer): PWideString; override;
    function Get(AIndex: Integer): UnicodeString;
{$ELSE}
    function Get(AIndex: Integer): UnicodeString; override;
{$ENDIF}

    procedure Put(AIndex: Integer; const AString: UnicodeString); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;

    procedure SetUpdateState(Updating: Boolean); override;

  public
    constructor Create(AHelper: TDSciHelper);
    procedure Clear; override;

{$IF CompilerVersion > 19}
    procedure LoadFromFileUTF8(const AFileName: UnicodeString); virtual;
    procedure LoadFromStreamUTF8(AStream: TStream); virtual;

    procedure SaveToFileUTF8(const AFileName: UnicodeString;
      APreamble: Boolean = False); virtual;
    procedure SaveToStreamUTF8(AStream: TStream;
      APreamble: Boolean = False); virtual;
{$IFEND}

    procedure Delete(AIndex: Integer); override;
{$IFDEF DSCI_JCLWIDESTRINGS}
    procedure InsertObject(AIndex: Integer; const AString: UnicodeString;
      AObject: TObject); override;
{$ELSE}
    procedure Insert(AIndex: Integer; const AString: UnicodeString); override;
{$ENDIF}
  end;

{ TDSciColourAlpha }
  TDSciColourAlpha = record
    Color: TColor;
    Alpha: Byte;
    class operator Explicit(ColorAlpha: TDSciColourAlpha): Integer;
    class operator Explicit(Value: Integer): TDSciColourAlpha;
    class operator Implicit(ColorAlpha: TDSciColourAlpha): Integer;
    class operator Implicit(Value: Integer): TDSciColourAlpha;
  end;

{$IF CompilerVersion > 19}
type
  // Compiler 'magic' will do conversion
  UnicodeStringToUTF8 = UTF8String;
{$ELSE}
function UTF8ToUnicodeString(const S: PAnsiChar): UnicodeString;
function UnicodeStringToUTF8(const S: UnicodeString): UTF8String;
{$IFEND}

function IsValidUtf8Bytes(const ABytes: TBytes; AOffset, ACount: Integer): Boolean;
function DSciFileEncodingDisplayName(AEncoding: TDSciFileEncoding): UnicodeString;
function DSciFileEncodingCodePage(AEncoding: TDSciFileEncoding): Cardinal;
function ResolveFileEncoding(const ABytes: TBytes; ARequestedEncoding: TDSciFileEncoding;
  out AEncoding: TEncoding; out APreambleSize: Integer;
  out ADetectedEncoding: TDSciFileEncoding; out ADetectedCodePage: Cardinal;
  out ADetectedName: UnicodeString): Boolean;

implementation

uses
{$ifdef DScintilla_USE_chsdet}
  ChsDet.Fluent,
{$endif}
  DScintillaLogger;

{$ifdef DScintilla_USE_chsdet}
const
  cChsDetMaxSampleBytes = 65536;
  cChsDetChunkBytes     = 4096;
  cChsDetMinConfidence  = 0.5;
{$endif}

function ByteIsUtf8Continuation(AValue: Byte): Boolean; inline;
begin
  Result := (AValue and $C0) = $80;
end;

function IsValidUtf8Bytes(const ABytes: TBytes; AOffset, ACount: Integer): Boolean;
var
  lB0: Byte;
  lB1: Byte;
  lB2: Byte;
  lB3: Byte;
  lIndex: Integer;
  lLimit: Integer;
begin
  Result := True;
  lIndex := AOffset;
  lLimit := AOffset + Max(0, ACount);
  while lIndex < lLimit do
  begin
    lB0 := ABytes[lIndex];
    if lB0 < $80 then
    begin
      Inc(lIndex);
      Continue;
    end;

    if (lB0 >= $C2) and (lB0 <= $DF) then
    begin
      if lIndex + 1 >= lLimit then
        Exit(False);
      if not ByteIsUtf8Continuation(ABytes[lIndex + 1]) then
        Exit(False);
      Inc(lIndex, 2);
      Continue;
    end;

    if (lB0 >= $E0) and (lB0 <= $EF) then
    begin
      if lIndex + 2 >= lLimit then
        Exit(False);
      lB1 := ABytes[lIndex + 1];
      lB2 := ABytes[lIndex + 2];
      if not ByteIsUtf8Continuation(lB2) then
        Exit(False);
      case lB0 of
        $E0:
          if not InRange(lB1, $A0, $BF) then
            Exit(False);
        $ED:
          if not InRange(lB1, $80, $9F) then
            Exit(False);
      else
        if not ByteIsUtf8Continuation(lB1) then
          Exit(False);
      end;
      Inc(lIndex, 3);
      Continue;
    end;

    if (lB0 >= $F0) and (lB0 <= $F4) then
    begin
      if lIndex + 3 >= lLimit then
        Exit(False);
      lB1 := ABytes[lIndex + 1];
      lB2 := ABytes[lIndex + 2];
      lB3 := ABytes[lIndex + 3];
      if not ByteIsUtf8Continuation(lB2) or
         not ByteIsUtf8Continuation(lB3) then
        Exit(False);
      case lB0 of
        $F0:
          if not InRange(lB1, $90, $BF) then
            Exit(False);
        $F4:
          if not InRange(lB1, $80, $8F) then
            Exit(False);
      else
        if not ByteIsUtf8Continuation(lB1) then
          Exit(False);
      end;
      Inc(lIndex, 4);
      Continue;
    end;

    Exit(False);
  end;
end;

function DSciFileEncodingDisplayName(AEncoding: TDSciFileEncoding): UnicodeString;
begin
  case AEncoding of
    dsfeAutoDetect:
      Result := 'Automatic detection';
    dsfeAnsi:
      Result := 'ANSI';
    dsfeUtf8:
      Result := 'UTF-8';
    dsfeUtf8Bom:
      Result := 'UTF-8 with BOM';
    dsfeUtf16BEBom:
      Result := 'UTF-16 BE with BOM';
    dsfeUtf16LEBom:
      Result := 'UTF-16 LE with BOM';
  else
    Result := 'Other';
  end;
end;

function DSciFileEncodingCodePage(AEncoding: TDSciFileEncoding): Cardinal;
begin
  case AEncoding of
    dsfeAnsi:
      Result := Cardinal(TEncoding.ANSI.CodePage);
    dsfeUtf8,
    dsfeUtf8Bom:
      Result := Cardinal(TEncoding.UTF8.CodePage);
    dsfeUtf16BEBom:
      Result := Cardinal(TEncoding.BigEndianUnicode.CodePage);
    dsfeUtf16LEBom:
      Result := Cardinal(TEncoding.Unicode.CodePage);
  else
    Result := 0;
  end;
end;

function ResolveFileEncoding(const ABytes: TBytes; ARequestedEncoding: TDSciFileEncoding;
  out AEncoding: TEncoding; out APreambleSize: Integer;
  out ADetectedEncoding: TDSciFileEncoding; out ADetectedCodePage: Cardinal;
  out ADetectedName: UnicodeString): Boolean;
var
  lDetectedBomEncoding: TEncoding;
  {$ifdef DScintilla_USE_chsdet}
  lChsResult: TChsDetectionResult;
  lChsEncoding: TEncoding;
  {$endif}
begin
  Result := True;
  AEncoding := nil;
  APreambleSize := 0;
  ADetectedEncoding := dsfeOther;
  ADetectedCodePage := 0;
  ADetectedName := '';

  case ARequestedEncoding of
    dsfeAnsi:
      begin
        AEncoding := TEncoding.ANSI;
        ADetectedEncoding := dsfeAnsi;
      end;
    dsfeUtf8,
    dsfeUtf8Bom:
      begin
        AEncoding := TEncoding.UTF8;
        ADetectedEncoding := ARequestedEncoding;
        APreambleSize := TEncoding.GetBufferEncoding(ABytes, lDetectedBomEncoding, nil);
        if not ((lDetectedBomEncoding <> nil) and
          (lDetectedBomEncoding.CodePage = TEncoding.UTF8.CodePage)) then
          APreambleSize := 0;
      end;
    dsfeUtf16BEBom:
      begin
        AEncoding := TEncoding.BigEndianUnicode;
        ADetectedEncoding := dsfeUtf16BEBom;
        APreambleSize := TEncoding.GetBufferEncoding(ABytes, lDetectedBomEncoding, nil);
        if not ((lDetectedBomEncoding <> nil) and
          (lDetectedBomEncoding.CodePage = TEncoding.BigEndianUnicode.CodePage)) then
          APreambleSize := 0;
      end;
    dsfeUtf16LEBom:
      begin
        AEncoding := TEncoding.Unicode;
        ADetectedEncoding := dsfeUtf16LEBom;
        APreambleSize := TEncoding.GetBufferEncoding(ABytes, lDetectedBomEncoding, nil);
        if not ((lDetectedBomEncoding <> nil) and
          (lDetectedBomEncoding.CodePage = TEncoding.Unicode.CodePage)) then
          APreambleSize := 0;
      end;
  else
    lDetectedBomEncoding := nil;
    APreambleSize := TEncoding.GetBufferEncoding(ABytes, lDetectedBomEncoding, nil);
    if (APreambleSize > 0) and (lDetectedBomEncoding <> nil) then
    begin
      AEncoding := lDetectedBomEncoding;
      if lDetectedBomEncoding.CodePage = TEncoding.UTF8.CodePage then
        ADetectedEncoding := dsfeUtf8Bom
      else if lDetectedBomEncoding.CodePage = TEncoding.BigEndianUnicode.CodePage then
        ADetectedEncoding := dsfeUtf16BEBom
      else if lDetectedBomEncoding.CodePage = TEncoding.Unicode.CodePage then
        ADetectedEncoding := dsfeUtf16LEBom
      else
        ADetectedEncoding := dsfeOther;
    end
    else
    begin
      APreambleSize := 0;
      {$ifdef DScintilla_USE_chsdet}
      begin
        var lChsDetector := TChsDetect.New;
        var lFeedOffset := 0;
        while (lFeedOffset < Length(ABytes)) and
              (lFeedOffset < cChsDetMaxSampleBytes) and
              not lChsDetector.IsDone do
        begin
          var lFeedCount := Min(cChsDetChunkBytes,
            Min(Length(ABytes), cChsDetMaxSampleBytes) - lFeedOffset);
          lChsDetector.Feed(ABytes, lFeedOffset, lFeedCount);
          Inc(lFeedOffset, lFeedCount);
        end;
        lChsResult := lChsDetector.Detect;
      end;
      if (not lChsResult.IsUnknown) and (lChsResult.Confidence >= cChsDetMinConfidence) then
      begin
        lChsEncoding := nil;
        if lChsResult.GetEncoding(lChsEncoding) and (lChsEncoding <> nil) then
        begin
          AEncoding := lChsEncoding;
          if AEncoding.CodePage = TEncoding.UTF8.CodePage then
            ADetectedEncoding := dsfeUtf8
          else
            ADetectedEncoding := dsfeOther;
          DSciLog(Format('[DSCI-LOAD] chsdet: detected "%s" (CodePage=%d, Confidence=%.0f%%).',
            [lChsResult.Name, lChsResult.CodePage, lChsResult.Confidence * 100]), cDSciLogDebug);
        end;
      end;
      {$endif}
      if AEncoding = nil then
      begin
        if IsValidUtf8Bytes(ABytes, 0, Length(ABytes)) then
        begin
          AEncoding := TEncoding.UTF8;
          ADetectedEncoding := dsfeUtf8;
        end
        else
        begin
          AEncoding := TEncoding.ANSI;
          ADetectedEncoding := dsfeAnsi;
        end;
      end;
    end;
  end;

  if AEncoding = nil then
    Exit(False);

  if ADetectedEncoding = dsfeOther then
  begin
    ADetectedCodePage := Cardinal(AEncoding.CodePage);
    ADetectedName := Trim(AEncoding.EncodingName);
    if ADetectedName = '' then
      ADetectedName := Format('Code page %d', [AEncoding.CodePage]);
  end
  else
  begin
    ADetectedCodePage := DSciFileEncodingCodePage(ADetectedEncoding);
    ADetectedName := DSciFileEncodingDisplayName(ADetectedEncoding);
  end;
end;

{$IF CompilerVersion < 20}
function _strlenA(lpString: PAnsiChar): Integer; stdcall;
  external 'kernel32.dll' name 'lstrlenA';

function UTF8ToUnicodeString(const S: PAnsiChar): UnicodeString;
var
  lLen: Integer;
  lUStr: UnicodeString;
begin
  Result := '';
  if S = '' then
    Exit;

  lLen := _strlenA(S);
  SetLength(lUStr, lLen);

  lLen := Utf8ToUnicode(PWideChar(lUStr), lLen + 1, S, lLen);
  if lLen > 0 then
    SetLength(lUStr, lLen - 1)
  else
    lUStr := '';
  Result := lUStr;
end;

function UnicodeStringToUTF8(const S: UnicodeString): UTF8String;
begin
  Result := UTF8Encode(S);
end;
{$IFEND}

{ TDSciUnicodeStrings }

{$IF Defined(DSCI_JCLWIDESTRINGS)}

procedure TDSciUnicodeStrings.LoadFromFile(const FileName: TFileName;
  WideFileOptions: TWideFileOptions);
begin
  inherited LoadFromFile(FileName, WideFileOptions);
end;

procedure TDSciUnicodeStrings.LoadFromStream(Stream: TStream;
  WideFileOptions: TWideFileOptions);
begin
  inherited LoadFromStream(Stream, WideFileOptions);
end;

procedure TDSciUnicodeStrings.SaveToFile(const FileName: TFileName;
  WideFileOptions: TWideFileOptions);
begin
  inherited SaveToFile(FileName, WideFileOptions);
end;

procedure TDSciUnicodeStrings.SaveToStream(Stream: TStream;
  WideFileOptions: TWideFileOptions);
begin
  inherited SaveToStream(Stream, WideFileOptions);
end;

{$IFEND}

{ TDSciHelper }

constructor TDSciHelper.Create(ASendEditor: TDSciSendEditor);
begin
  FSendEditor := ASendEditor;

  inherited Create;
end;

function TDSciHelper.SendEditor(AMessage: UINT; WParam: WPARAM; LParam: LPARAM): LRESULT;
begin
  Result := FSendEditor(AMessage, WParam, LParam);
end;

function TDSciHelper.IsUTF8: Boolean;
begin
  Result := SendEditor(SCI_GETCODEPAGE) = SC_CP_UTF8;
end;

function TDSciHelper.GetPtrFromAStr(AStr: AnsiString): PAnsiChar;
begin
  if AStr = '' then
    Result := @cDSciNull
  else
    Result := PAnsiChar(AStr);
end;

function TDSciHelper.GetStrFromPtr(ABuf: PAnsiChar): UnicodeString;
begin
  if ABuf = nil then
    Result := ''
  else
    if IsUTF8 then
      Result := UTF8ToUnicodeString(ABuf)
    else
      Result:= UnicodeString(ABuf);
end;

function TDSciHelper.GetStrFromPtrA(ABuf: PAnsiChar): AnsiString;
begin
  if ABuf = nil then
    Result := ''
  else
    Result:= AnsiString(ABuf);
end;

function TDSciHelper.GetText(AMessage: Integer; AWParam: WPARAM;
  var AText: UnicodeString): Integer;
var
  lBuf: PAnsiChar;
begin
  lBuf := AllocMem(SendEditor(AMessage, AWParam) + 1);
  try
    Result := SendEditor(AMessage, AWParam, LPARAM(lBuf));
    AText := GetStrFromPtr(lBuf);
  finally
    FreeMem(lBuf);
  end;
end;

function TDSciHelper.GetText(AMessage: Integer; AWParam: UnicodeString;
  var AText: UnicodeString): Integer;
begin
  if AWParam = '' then
    Result := GetText(AMessage, WPARAM(@cDSciNull), AText)
  else
    if IsUTF8 then
      Result := GetText(AMessage, WPARAM(UnicodeStringToUTF8(AWParam)), AText)
    else
      Result := GetText(AMessage, WPARAM(AnsiString(AWParam)), AText);
end;

function TDSciHelper.GetTextA(AMessage: Integer; AWParam: WPARAM;
  var AText: AnsiString): Integer;
var
  lBuf: PAnsiChar;
begin
  lBuf := AllocMem(SendEditor(AMessage, AWParam) + 1);
  try
    Result := SendEditor(AMessage, AWParam, LPARAM(lBuf));
    AText := GetStrFromPtrA(lBuf);
  finally
    FreeMem(lBuf);
  end;
end;

function TDSciHelper.GetTextA(AMessage: Integer; AWParam: AnsiString;
  var AText: AnsiString): Integer;
begin
  if AWParam = '' then
    Result := GetTextA(AMessage, WPARAM(@cDSciNull), AText)
  else
    Result := GetTextA(AMessage, WPARAM(AWParam), AText);
end;

function TDSciHelper.SetText(AMessage: Integer; AWParam: WPARAM;
  const AText: UnicodeString): Integer;
begin
  if AText = '' then
    Result := SendEditor(AMessage, AWParam, LPARAM(@cDSciNull))
  else
    if IsUTF8 then
      Result := SendEditor(AMessage, AWParam, LPARAM(UnicodeStringToUTF8(AText)))
    else
      Result := SendEditor(AMessage, AWParam, LPARAM(AnsiString(AText)));
end;

function TDSciHelper.SetText(AMessage: Integer; AWParam: UnicodeString;
  const AText: UnicodeString): Integer;
begin
  if AWParam = '' then
    Result := SetText(AMessage, WParam(@cDSciNull), AText)
  else
    if IsUTF8 then
      Result := SetText(AMessage, WPARAM(UnicodeStringToUTF8(AWParam)), AText)
    else
      Result := SetText(AMessage, WPARAM(AnsiString(AWParam)), AText);
end;

function TDSciHelper.SetTextA(AMessage: Integer; AWParam: WPARAM;
  const AText: AnsiString): Integer;
begin
  if AText = '' then
    Result := SendEditor(AMessage, AWParam, LPARAM(@cDSciNull))
  else
    Result := SendEditor(AMessage, AWParam, LPARAM(AText));
end;

function TDSciHelper.SetTextA(AMessage: Integer; AWParam: AnsiString;
  const AText: AnsiString): Integer;
begin
  if AWParam = '' then
    Result := SetTextA(AMessage, WPARAM(@cDSciNull), AText)
  else
    Result := SetTextA(AMessage, WPARAM(AWParam), AText);
end;

function TDSciHelper.GetTextLen(AMessage: Integer;
  var AText: UnicodeString): NativeInt;
var
  lBuf: PAnsiChar;
  lLen: NativeInt;
begin
  lLen := SendEditor(AMessage);

  lBuf := AllocMem(lLen + 1);
  try
    Result := SendEditor(AMessage, lLen + 1, LPARAM(lBuf));
    AText := GetStrFromPtr(lBuf);
  finally
    FreeMem(lBuf);
  end;
end;

function TDSciHelper.SetTextLen(AMessage: Integer;
  const AText: UnicodeString): NativeInt;
var
  lUTF8: UTF8String;
  lAnsi: AnsiString;
begin
  if AText = '' then
    Result := SendEditor(AMessage, 0, LPARAM(@cDSciNull))
  else
    if IsUTF8 then
    begin
      lUTF8 := UnicodeStringToUTF8(AText);
      Result := SendEditor(AMessage, System.Length(lUTF8), LPARAM(lUTF8));
    end else
    begin
      lAnsi := AnsiString(AText);
      Result := SendEditor(AMessage, System.Length(lAnsi), LPARAM(lAnsi));
    end;
end;

function TDSciHelper.SetTargetLine(ALine: Integer): Boolean;
var
  lLineStart, lLineEnd: Integer;
begin
  Result := False;

  lLineStart := SendEditor(SCI_POSITIONFROMLINE, ALine);
  if lLineStart = INVALID_POSITION then
    Exit;

  if (lLineStart = SendEditor(SCI_GETLENGTH)) and (ALine > 0) then
  begin
    lLineEnd := lLineStart;
    lLineStart := SendEditor(SCI_GETLINEENDPOSITION, ALine - 1);
  end else
    lLineEnd := lLineStart + SendEditor(SCI_LINELENGTH, ALine);

  if lLineEnd = INVALID_POSITION then
    Exit;

  SendEditor(SCI_SETTARGETSTART, lLineStart);
  SendEditor(SCI_SETTARGETEND, lLineEnd);

  Result := True;
end;

{ TDSciLines }

constructor TDSciLines.Create(AHelper: TDSciHelper);
begin
  FHelper := AHelper;

  inherited Create;
end;

function TDSciLines.GetTextStr: UnicodeString;
var
  lBuf: PAnsiChar;
  lLen: NativeInt;
begin
  lLen := FHelper.SendEditor(SCI_GETLENGTH);

  lBuf := AllocMem(lLen + 1);
  try
    FHelper.SendEditor(SCI_GETTEXT, lLen + 1, NativeInt(lBuf));
    Result := FHelper.GetStrFromPtr(lBuf);
  finally
    FreeMem(lBuf);
  end;
end;

procedure TDSciLines.SetTextStr(const AValue: UnicodeString);
begin
  FHelper.SetText(SCI_SETTEXT, 0, AValue);
end;

function TDSciLines.GetCount: Integer;
begin
  Result := FHelper.SendEditor(SCI_GETLINECOUNT);

  if Result = 1 then
    if FHelper.SendEditor(SCI_GETLENGTH) = 0 then
      Result := 0;
end;

{$IFDEF DSCI_JCLWIDESTRINGS}
function TDSciLines.GetP(AIndex: Integer): PWideString;
begin
  FLastGetP := Get(AIndex);
  Result := @FLastGetP;
end;
{$ENDIF}

function TDSciLines.Get(AIndex: Integer): UnicodeString;
var
  lBuf: PAnsiChar;
  lTextRange: TDSciTextRange;
begin
  Result := '';

  lTextRange.chrg.cpMin := FHelper.SendEditor(SCI_POSITIONFROMLINE, AIndex);
  lTextRange.chrg.cpMax := FHelper.SendEditor(SCI_GETLINEENDPOSITION, AIndex);

  if (lTextRange.chrg.cpMin = INVALID_POSITION) or (lTextRange.chrg.cpMax = INVALID_POSITION) then
    Exit;

  lBuf := AllocMem(lTextRange.chrg.cpMax - lTextRange.chrg.cpMin  + 1);
  try
    lTextRange.lpstrText := PAnsiChar(lBuf);
    FHelper.SendEditor(SCI_GETTEXTRANGE, 0, NativeInt(@lTextRange));
    Result := FHelper.GetStrFromPtr(lBuf);
  finally
    FreeMem(lBuf);
  end;
end;

procedure TDSciLines.Put(AIndex: Integer; const AString: UnicodeString);
begin
  if FHelper.SetTargetLine(AIndex) then
    FHelper.SetTextLen(SCI_REPLACETARGET, AString);
end;

procedure TDSciLines.PutObject(Index: Integer; AObject: TObject);
begin
  // Objects in TDSciLines are not supported
end;

procedure TDSciLines.SetUpdateState(Updating: Boolean);
begin
  if Updating then
    FHelper.SendEditor(SCI_BEGINUNDOACTION)
  else
    FHelper.SendEditor(SCI_ENDUNDOACTION);
end;

procedure TDSciLines.Clear;
begin
  FHelper.SendEditor(SCI_CLEARALL);
end;

{$IF CompilerVersion > 19}
procedure TDSciLines.LoadFromFileUTF8(const AFileName: UnicodeString);
begin
  LoadFromFile(AFileName, TEncoding.UTF8);
end;

procedure TDSciLines.LoadFromStreamUTF8(AStream: TStream);
begin
  LoadFromStream(AStream, TEncoding.UTF8);
end;

procedure TDSciLines.SaveToFileUTF8(const AFileName: UnicodeString;
  APreamble: Boolean);
var
  lStream: TStream;
begin
  lStream := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStreamUTF8(lStream, APreamble);
  finally
    lStream.Free;
  end;
end;

procedure TDSciLines.SaveToStreamUTF8(AStream: TStream; APreamble: Boolean);
var
  lBuffer: TBytes;
begin
  if APreamble then
    SaveToStream(AStream, TEncoding.UTF8)
  else
  begin
    lBuffer := TEncoding.UTF8.GetBytes(GetTextStr);
    if Length(lBuffer) > 0 then
      AStream.WriteBuffer(lBuffer[0], Length(lBuffer));
  end;
end;
{$IFEND}

procedure TDSciLines.Delete(AIndex: Integer);
begin
  if FHelper.SetTargetLine(AIndex) then
    FHelper.SendEditor(SCI_REPLACETARGET, 0, 0);
end;

{$IFDEF DSCI_JCLWIDESTRINGS}
procedure TDSciLines.InsertObject(AIndex: Integer; const AString: UnicodeString;
  AObject: TObject);
{$ELSE}
procedure TDSciLines.Insert(AIndex: Integer; const AString: UnicodeString);
{$ENDIF}
var
  lEOL: UnicodeString;
  lLinePos: Integer;
begin
  lLinePos := FHelper.SendEditor(SCI_POSITIONFROMLINE, AIndex);

  if lLinePos = INVALID_POSITION then
    Exit;

  case FHelper.SendEditor(SCI_GETEOLMODE) of
  SC_EOL_CRLF:
    lEOL := #13#10;

  SC_EOL_CR:
    lEOL := #13;

  SC_EOL_LF:
    lEOL := #10;
  else
    lEOL := sLineBreak;
  end;

  FHelper.SendEditor(SCI_SETTARGETSTART, lLinePos);
  FHelper.SendEditor(SCI_SETTARGETEND, lLinePos);

  if lLinePos = FHelper.SendEditor(SCI_GETLENGTH) then
  begin

    if lLinePos = 0 then
      FHelper.SetTextLen(SCI_REPLACETARGET, AString)
    else
      FHelper.SetTextLen(SCI_REPLACETARGET, lEOL + AString);

  end else
    FHelper.SetTextLen(SCI_REPLACETARGET, AString + lEOL);
end;

{ TDSciColourAlpha }

class operator TDSciColourAlpha.Explicit(ColorAlpha: TDSciColourAlpha): Integer;
begin
  Result := (ColorAlpha.Alpha shl 24) + ColorAlpha.Color;
end;

class operator TDSciColourAlpha.Explicit(Value: Integer): TDSciColourAlpha;
begin
  Result.Alpha := Value shr 24;
  Result.Color := Value and $00FFFFFF;
end;

class operator TDSciColourAlpha.Implicit(ColorAlpha: TDSciColourAlpha): Integer;
begin
  Result := Integer(ColorAlpha);
end;

class operator TDSciColourAlpha.Implicit(Value: Integer): TDSciColourAlpha;
begin
  Result := TDSciColourAlpha(Value);
end;

end.
