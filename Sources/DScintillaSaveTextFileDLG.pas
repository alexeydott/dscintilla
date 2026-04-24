unit DScintillaSaveTextFileDLG;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  System.Classes, System.SysUtils,
  Vcl.Dialogs,
  DScintilla, DScintillaTypes;

type
  /// <summary>
  /// Save-file dialog that lets the user choose both a file path and a text
  /// encoding.  The encoding is surfaced through the dialog's file-type filter
  /// so that no custom template is required.
  /// </summary>
  TSaveTextFileDialog = class
  private const
    // Filter-index values (1-based, as returned by TSaveDialog.FilterIndex)
    cFilterIndexUtf8    = 1;
    cFilterIndexUtf8Bom = 2;
    cFilterIndexAnsi    = 3;
    cFilterIndexUtf16LE = 4;
    cFilterIndexUtf16BE = 5;
  private
    FDialog: TSaveDialog;
    FSelectedEncoding: TDSciFileEncoding;
    function GetDefaultExt: string;
    function GetFileName: string;
    procedure SetFileName(const AValue: string);
    function GetInitialDir: string;
    procedure SetDefaultExt(const AValue: string);
    procedure SetInitialDir(const AValue: string);
    function FilterIndexToEncoding(AIndex: Integer): TDSciFileEncoding;
    function EncodingToFilterIndex(AEncoding: TDSciFileEncoding): Integer;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;

    /// <summary>Shows the dialog. Returns True when the user confirmed.</summary>
    function Execute(AParentHandle: THandle = 0): Boolean;

    property DefaultExt: string read GetDefaultExt write SetDefaultExt;
    property FileName: string read GetFileName write SetFileName;
    property InitialDir: string read GetInitialDir write SetInitialDir;

    /// <summary>
    /// Pre-selects the encoding in the filter list before the dialog is shown.
    /// Has no effect after Execute has been called.
    /// </summary>
    property InitialEncoding: TDSciFileEncoding write FSelectedEncoding;

    /// <summary>
    /// The encoding chosen by the user.  Valid only after a successful Execute.
    /// </summary>
    property SelectedEncoding: TDSciFileEncoding read FSelectedEncoding;

    /// <summary>
    /// Native dialog for custom actions
    /// </summary>
    property NativeDialog: TSaveDialog read FDialog;
  end;

implementation

constructor TSaveTextFileDialog.Create(AOwner: TComponent);
begin
  inherited Create;
  FSelectedEncoding := dsfeUtf8Bom;
  FDialog := TSaveDialog.Create(AOwner);
  FDialog.Filter :=
    'UTF-8 (*.*)|*.*|' +
    'UTF-8 with BOM (*.*)|*.*|' +
    'ANSI (*.*)|*.*|' +
    'UTF-16 LE with BOM (*.*)|*.*|' +
    'UTF-16 BE with BOM (*.*)|*.*';
  FDialog.Options := [ofOverwritePrompt, ofPathMustExist, ofEnableSizing];
end;

destructor TSaveTextFileDialog.Destroy;
begin
  FDialog.Free;
  inherited Destroy;
end;

function TSaveTextFileDialog.GetDefaultExt: string;
begin
  Result := FDialog.DefaultExt;
end;

function TSaveTextFileDialog.GetFileName: string;
begin
  Result := FDialog.FileName;
end;

procedure TSaveTextFileDialog.SetFileName(const AValue: string);
begin
  FDialog.FileName := AValue;
end;

function TSaveTextFileDialog.GetInitialDir: string;
begin
  Result := FDialog.InitialDir;
end;

procedure TSaveTextFileDialog.SetDefaultExt(const AValue: string);
begin
  FDialog.DefaultExt := AValue;
end;

procedure TSaveTextFileDialog.SetInitialDir(const AValue: string);
begin
  FDialog.InitialDir := AValue;
end;

function TSaveTextFileDialog.FilterIndexToEncoding(
  AIndex: Integer): TDSciFileEncoding;
begin
  case AIndex of
    cFilterIndexUtf8:    Result := dsfeUtf8;
    cFilterIndexUtf8Bom: Result := dsfeUtf8Bom;
    cFilterIndexAnsi:    Result := dsfeAnsi;
    cFilterIndexUtf16LE: Result := dsfeUtf16LEBom;
    cFilterIndexUtf16BE: Result := dsfeUtf16BEBom;
  else
    Result := dsfeUtf8;
  end;
end;

function TSaveTextFileDialog.EncodingToFilterIndex(
  AEncoding: TDSciFileEncoding): Integer;
begin
  case AEncoding of
    dsfeUtf8:      Result := cFilterIndexUtf8;
    dsfeUtf8Bom:   Result := cFilterIndexUtf8Bom;
    dsfeAnsi:      Result := cFilterIndexAnsi;
    dsfeUtf16LEBom: Result := cFilterIndexUtf16LE;
    dsfeUtf16BEBom: Result := cFilterIndexUtf16BE;
  else
    Result := cFilterIndexUtf8;
  end;
end;

function TSaveTextFileDialog.Execute(AParentHandle: THandle): Boolean;
begin
  FDialog.FilterIndex := EncodingToFilterIndex(FSelectedEncoding);
  if AParentHandle <> 0 then
    Result := FDialog.Execute(AParentHandle)
  else
    Result := FDialog.Execute;
  if Result then
    FSelectedEncoding := FilterIndexToEncoding(FDialog.FilterIndex);
end;

end.
