unit DScintillaLogger;
(*
  Centralised diagnostic logger for the DScintilla component suite.

  Every unit that needs to emit trace / diagnostic messages should use this
  unit and call DSciLog instead of OutputDebugString directly.  The output
  destination (OutputDebugString or a log file) and verbosity are controlled
  by the global variables below and can be wired to the visual-config model
  at runtime.
*)

interface

uses
  Winapi.Windows, System.SysUtils;

const
  cDSciLogNone  = 0;
  cDSciLogError = 1;
  cDSciLogInfo  = 2;
  cDSciLogDebug = 3;

  cDSciOutputODS  = 0;   // OutputDebugString
  cDSciOutputFile = 1;   // Append to log file

  // Legacy aliases
  cSciBridgeLogNone  = cDSciLogNone;
  cSciBridgeLogError = cDSciLogError;
  cSciBridgeLogInfo  = cDSciLogInfo;
  cSciBridgeLogDebug = cDSciLogDebug;
  cSciBridgeOutputODS  = cDSciOutputODS;
  cSciBridgeOutputFile = cDSciOutputFile;

var
  _DSciLogEnabled: Boolean = False;
  _DSciLogLevel: Integer   = cDSciLogError;
  _DSciLogOutput: Integer  = cDSciOutputFile;
  _DSciLogPath: string;

procedure DSciLog(const Msg: string; ALevel: Integer = cDSciLogDebug);
procedure SciBridgeLog(const Msg: string; ALevel: Integer = cDSciLogDebug); deprecated;

function  GetDSciLogEnabled: Boolean;
procedure SetDSciLogEnabled(AValue: Boolean);
function  GetDSciLogLevel: Integer;
procedure SetDSciLogLevel(AValue: Integer);
function  GetDSciLogOutput: Integer;
procedure SetDSciLogOutput(AValue: Integer);
function  GetDSciLogPath: string;
procedure SetDSciLogPath(const AValue: string);

// Legacy read-only aliases (backward compatibility)
function _SciBridgeLogEnabled: Boolean;
function _SciBridgeLogLevel: Integer;
function _SciBridgeLogOutput: Integer;

implementation

procedure DSciLog(const Msg: string; ALevel: Integer);
var
  F: TextFile;
  Line: string;
begin
  if not _DSciLogEnabled then
    Exit;
  if ALevel > _DSciLogLevel then
    Exit;
  Line := FormatDateTime('hh:nn:ss.zzz', Now) + ' ' + Msg;
  case _DSciLogOutput of
    cDSciOutputFile:
      begin
        if _DSciLogPath = '' then
          _DSciLogPath := ExtractFilePath(ParamStr(0)) + 'dsci_debug.log';
        AssignFile(F, _DSciLogPath);
        {$I-}
        if FileExists(_DSciLogPath) then
          Append(F)
        else
          Rewrite(F);
        if IOResult = 0 then
        begin
          WriteLn(F, Line);
          CloseFile(F);
        end;
        {$I+}
      end;
  else
    begin
      if IsConsole then
        Writeln(Line)
      else
        OutputDebugString(PChar(Line));
    end;
  end;
end;

procedure SciBridgeLog(const Msg: string; ALevel: Integer);
begin
  DSciLog(Msg, ALevel);
end;

function GetDSciLogEnabled: Boolean;
begin
  Result := _DSciLogEnabled;
end;

procedure SetDSciLogEnabled(AValue: Boolean);
begin
  _DSciLogEnabled := AValue;
end;

function GetDSciLogLevel: Integer;
begin
  Result := _DSciLogLevel;
end;

procedure SetDSciLogLevel(AValue: Integer);
begin
  _DSciLogLevel := AValue;
end;

function GetDSciLogOutput: Integer;
begin
  Result := _DSciLogOutput;
end;

procedure SetDSciLogOutput(AValue: Integer);
begin
  _DSciLogOutput := AValue;
end;

function GetDSciLogPath: string;
begin
  Result := _DSciLogPath;
end;

procedure SetDSciLogPath(const AValue: string);
begin
  _DSciLogPath := AValue;
end;

function _SciBridgeLogEnabled: Boolean;
begin
  Result := _DSciLogEnabled;
end;

function _SciBridgeLogLevel: Integer;
begin
  Result := _DSciLogLevel;
end;

function _SciBridgeLogOutput: Integer;
begin
  Result := _DSciLogOutput;
end;

end.
