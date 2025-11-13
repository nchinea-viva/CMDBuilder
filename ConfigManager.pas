unit ConfigManager;

interface

uses
  System.SysUtils, System.IniFiles, System.Classes
  , BuilderUtils
  ;

type
  TConfigManager = class
  private
    FIniFile: TIniFile;
    FFileName: string;
    function GetFileName: string;

  public
    constructor Create(const AFileName: string = '');
    destructor Destroy; override;

    property FileName: string read GetFileName;

    procedure WriteString(const Section, Key, Value: string);
    function ReadString(const Section, Key: string; const DefaultValue: string = ''): string;

    procedure WriteInteger(const Section, Key: string; Value: Integer);
    function ReadInteger(const Section, Key: string; DefaultValue: Integer = 0): Integer;

    procedure WriteBool(const Section, Key: string; Value: Boolean);
    function ReadBool(const Section, Key: string; DefaultValue: Boolean = False): Boolean;

    procedure DeleteKey(const Section, Key: string);
    procedure DeleteSection(const Section: string);
    function SectionExists(const Section: string): Boolean;
    function KeyExists(const Section, Key: string): Boolean;
    procedure GetSections(Strings: TStrings);
    procedure GetKeys(const Section: string; Strings: TStrings);

    procedure SaveToFile;
    procedure ReloadFromFile;

    function FileExists: Boolean;
  end;

implementation

{ TConfigManager }

constructor TConfigManager.Create(const AFileName: string = '');
begin
  inherited Create;

  // Se non viene specificato un nome file, usa il nome dell'applicazione
  if AFileName = '' then
    FFileName := ChangeFileExt(ParamStr(0), '.ini')
  else
    FFileName := AFileName;

  FIniFile := TIniFile.Create(FFileName);
end;

destructor TConfigManager.Destroy;
begin
  FreeAndNil(FIniFile);
  inherited Destroy;
end;

function TConfigManager.GetFileName: string;
begin
  Result := FFileName;
end;

procedure TConfigManager.WriteString(const Section, Key, Value: string);
begin
  FIniFile.WriteString(Section, Key, Value);
end;

function TConfigManager.ReadString(const Section, Key: string; const DefaultValue: string = ''): string;
begin
  Result := FIniFile.ReadString(Section, Key, DefaultValue);
end;

procedure TConfigManager.WriteInteger(const Section, Key: string; Value: Integer);
begin
  FIniFile.WriteInteger(Section, Key, Value);
end;

function TConfigManager.ReadInteger(const Section, Key: string; DefaultValue: Integer = 0): Integer;
begin
  Result := FIniFile.ReadInteger(Section, Key, DefaultValue);
end;

procedure TConfigManager.WriteBool(const Section, Key: string; Value: Boolean);
begin
  FIniFile.WriteBool(Section, Key, Value);
end;

function TConfigManager.ReadBool(const Section, Key: string; DefaultValue: Boolean = False): Boolean;
begin
  Result := FIniFile.ReadBool(Section, Key, DefaultValue);
end;

procedure TConfigManager.DeleteKey(const Section, Key: string);
begin
  FIniFile.DeleteKey(Section, Key);
end;

procedure TConfigManager.DeleteSection(const Section: string);
begin
  FIniFile.EraseSection(Section);
end;

function TConfigManager.SectionExists(const Section: string): Boolean;
begin
  Result := FIniFile.SectionExists(Section);
end;

function TConfigManager.KeyExists(const Section, Key: string): Boolean;
begin
  Result := FIniFile.ValueExists(Section, Key);
end;

procedure TConfigManager.GetSections(Strings: TStrings);
begin
  FIniFile.ReadSections(Strings);
end;

procedure TConfigManager.GetKeys(const Section: string; Strings: TStrings);
begin
  FIniFile.ReadSectionValues(Section, Strings);
end;

procedure TConfigManager.SaveToFile;
begin
  FIniFile.UpdateFile;
end;

procedure TConfigManager.ReloadFromFile;
begin
  FreeAndNil(FIniFile);
  FIniFile := TIniFile.Create(FFileName);
end;

function TConfigManager.FileExists: Boolean;
begin
  Result := System.SysUtils.FileExists(FFileName);
end;

end.
