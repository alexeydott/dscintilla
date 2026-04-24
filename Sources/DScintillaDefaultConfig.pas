unit DScintillaDefaultConfig;

interface

uses
  System.Classes;

const
  DSCI_DEFAULT_CONFIG_FILE_NAME = 'DScintilla.config.xml';
  DSCI_DEFAULT_CONFIG_RESOURCE_NAME = 'DSCI_DEFAULT_CONFIG';

function OpenDefaultConfigStream: TResourceStream;
function EnsureDefaultConfigFile(const AFileName: string): Boolean;
procedure SaveDefaultConfigToFile(const AFileName: string);

implementation

uses
  System.IOUtils, System.SysUtils, Winapi.Windows;

{$R DScintillaDefaultConfig.res}

function OpenDefaultConfigStream: TResourceStream;
begin
  Result := TResourceStream.Create(HInstance, DSCI_DEFAULT_CONFIG_RESOURCE_NAME, RT_RCDATA);
end;

procedure SaveDefaultConfigToFile(const AFileName: string);
var
  lDirectory: string;
  lStream: TResourceStream;
begin
  if Trim(AFileName) = '' then
    raise EArgumentException.Create('AFileName must not be empty.');

  lDirectory := ExtractFileDir(AFileName);
  if lDirectory <> '' then
    ForceDirectories(lDirectory);

  lStream := OpenDefaultConfigStream;
  try
    lStream.SaveToFile(AFileName);
  finally
    lStream.Free;
  end;
end;

function EnsureDefaultConfigFile(const AFileName: string): Boolean;
begin
  Result := not FileExists(AFileName);
  if Result then
    SaveDefaultConfigToFile(AFileName);
end;

end.
