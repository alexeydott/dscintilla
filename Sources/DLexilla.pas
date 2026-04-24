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
 * The Original Code is DLexilla.pas
 *
 * The Initial Developer of the Original Code is Krystian Bigaj.
 *
 * Portions created by the Initial Developer are Copyright (C) 2010-2015
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

unit DLexilla;

interface

uses
  System.Classes, Winapi.Windows, DScintillaTypes, DScintillaCustom;

const
  cDLexillaDll  = cDScintillaDll;

type

{ TDLexilla - deprecated wrapper; delegates to DScintillaBridge singleton }

  TDLexillaLexerFactory = function: TDSciLexer; stdcall;

  TDLexilla = class
  private
    FLexillaDllModule: string;
    procedure SetDllModule(const Value: string);
    function GetLexillaDllHandle: HMODULE;
    class function Utf8PtrToString(Value: PAnsiChar): UnicodeString; static;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateLexer(const LexerName: UnicodeString): TDSciLexer;
    function GetLexerCount: Integer;
    function GetLexerName(const Index: Integer): UnicodeString;
    function GetLexerFactory(const Index: Integer): TDLexillaLexerFactory;
    function LexerNameFromID(LexerID: Integer): UnicodeString;
    function GetLibraryPropertyNames: UnicodeString;
    function GetNameSpace: UnicodeString;
    procedure SetLibraryProperty(const Key, Value: UnicodeString);

    property DllModule: string read FLexillaDllModule write SetDllModule;
    property LexillaDllHandle: HMODULE read GetLexillaDllHandle;
  end;

implementation

{ TDLexilla }

uses
  System.SysUtils, DScintillaBridge;

constructor TDLexilla.Create;
begin
  FLexillaDllModule := cDLexillaDll;
end;

destructor TDLexilla.Destroy;
begin
  inherited;
end;

function TDLexilla.GetLexillaDllHandle: HMODULE;
begin
  // Return whichever handle provides Lexilla exports
  Result := SciBridgeLoader.LexDllHandle;
  if Result = 0 then
    Result := SciBridgeLoader.DllHandle;
end;

procedure TDLexilla.SetDllModule(const Value: string);
{$IFNDEF SCINLILLA_STATIC_LINKING}
var
  lDllModule: string;
{$ENDIF}
begin
{$IFDEF SCINLILLA_STATIC_LINKING}
  FLexillaDllModule := cDLexillaDll;
{$ELSE}
  lDllModule := Trim(Value);
  if lDllModule = '' then
    lDllModule := cDLexillaDll;
  FLexillaDllModule := lDllModule;
  // DLL loading is managed by the bridge singleton
{$ENDIF}
end;

function TDLexilla.CreateLexer(const LexerName: UnicodeString): TDSciLexer;
var
  lLexerName: UTF8String;
begin
  lLexerName := UTF8Encode(LexerName);
  Result := TDSciLexer(SciBridgeLoader.LexCreateLexer(PAnsiChar(lLexerName)));
end;

function TDLexilla.LexerNameFromID(LexerID: Integer): UnicodeString;
begin
  Result := Utf8PtrToString(SciBridgeLoader.LexLexerNameFromID(LexerID));
end;

function TDLexilla.GetLexerCount: Integer;
begin
  Result := SciBridgeLoader.LexGetLexerCount;
end;

function TDLexilla.GetLexerName(const Index: Integer): UnicodeString;
const
  BUFFER_LEN = 1024;
var
  Buffer: array[0..BUFFER_LEN - 1] of AnsiChar;
begin
  if Index < 0 then
    raise EArgumentOutOfRangeException.Create('Index must be non-negative.');

  FillChar(Buffer, SizeOf(Buffer), 0);
  SciBridgeLoader.LexGetLexerName(Cardinal(Index), @Buffer[0], SizeOf(Buffer));
  Result := Utf8PtrToString(@Buffer[0]);
end;

function TDLexilla.GetLexerFactory(const Index: Integer): TDLexillaLexerFactory;
begin
  if Index < 0 then
    raise EArgumentOutOfRangeException.Create('Index must be non-negative.');

  Result := TDLexillaLexerFactory(SciBridgeLoader.LexGetLexerFactory(Cardinal(Index)));
end;

function TDLexilla.GetLibraryPropertyNames: UnicodeString;
begin
  Result := Utf8PtrToString(SciBridgeLoader.LexGetLibraryPropertyNames);
end;

function TDLexilla.GetNameSpace: UnicodeString;
begin
  Result := Utf8PtrToString(SciBridgeLoader.LexGetNameSpace);
end;

procedure TDLexilla.SetLibraryProperty(const Key, Value: UnicodeString);
var
  lKey: UTF8String;
  lValue: UTF8String;
begin
  lKey := UTF8Encode(Key);
  lValue := UTF8Encode(Value);
  SciBridgeLoader.LexSetLibraryProperty(PAnsiChar(lKey), PAnsiChar(lValue));
end;

class function TDLexilla.Utf8PtrToString(Value: PAnsiChar): UnicodeString;
var
  lCharCount: Integer;
begin
  if Value = nil then
    Exit('');

  lCharCount := MultiByteToWideChar(CP_UTF8, 0, Value, -1, nil, 0);
  if lCharCount <= 1 then
    Exit('');

  SetLength(Result, lCharCount - 1);
  MultiByteToWideChar(CP_UTF8, 0, Value, -1, PWideChar(Result), lCharCount);
end;

end.
