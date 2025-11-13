unit RegistryReader;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Win.Registry,
  Winapi.Windows;

type
  TRegistryReader = class
  private
    FRegistry: TRegistry;
    FCurrentRootKey: HKEY;
    FCurrentPath: string;
    function GetRootKeyName(RootKey: HKEY): string;
  public
    constructor Create;
    destructor Destroy; override;

    // Gestione chiavi
    function SetRootKey(RootKey: HKEY): Boolean;
    function OpenKey(const KeyPath: string; CanCreate: Boolean = False): Boolean;
    function KeyExists(const KeyPath: string): Boolean;
    procedure CloseKey;

    // Lettura valori
    function ValueExists(const ValueName: string): Boolean;
    function ReadString(const ValueName: string; const DefaultValue: string = ''): string;
    function ReadInteger(const ValueName: string; DefaultValue: Integer = 0): Integer;
    function ReadBool(const ValueName: string; DefaultValue: Boolean = False): Boolean;
    function ReadFloat(const ValueName: string; DefaultValue: Double = 0.0): Double;
    function ReadDateTime(const ValueName: string; DefaultValue: TDateTime = 0): TDateTime;
    function ReadBinaryData(const ValueName: string; var Buffer; BufSize: Integer): Integer;

    // Enumerazione
    function GetValueNames(ValueList: TStrings): Boolean;
    function GetSubKeyNames(KeyList: TStrings): Boolean;

    // Informazioni sui valori
    function GetDataType(const ValueName: string): TRegDataType;
    function GetDataSize(const ValueName: string): Integer;
    function GetDataInfo(const ValueName: string; var DataType: TRegDataType; var DataSize: Integer): Boolean;

    // Utilità
    function GetKeyInfo(var NumSubKeys, MaxSubKeyLen, NumValues, MaxValueLen, MaxDataLen: Integer; var FileTime: TFileTime): Boolean;
    function GetCurrentPath: string;
    function GetCurrentRootKey: HKEY;
    function GetFullPath: string;

    // Proprietà
    property Registry: TRegistry read FRegistry;
    property CurrentRootKey: HKEY read FCurrentRootKey;
    property CurrentPath: string read FCurrentPath;
  end;

  // Classe helper per operazioni comuni
  TRegistryHelper = class
  public
    class function ReadStringValue(RootKey: HKEY; const KeyPath, ValueName: string; const DefaultValue: string = ''): string;
    class function ReadIntegerValue(RootKey: HKEY; const KeyPath, ValueName: string; DefaultValue: Integer = 0): Integer;
    class function ReadBoolValue(RootKey: HKEY; const KeyPath, ValueName: string; DefaultValue: Boolean = False): Boolean;
    class function KeyExists(RootKey: HKEY; const KeyPath: string): Boolean;
    class function ValueExists(RootKey: HKEY; const KeyPath, ValueName: string): Boolean;
    class function GetSubKeys(RootKey: HKEY; const KeyPath: string; KeyList: TStrings): Boolean;
    class function GetValues(RootKey: HKEY; const KeyPath: string; ValueList: TStrings): Boolean;
  end;

implementation

{ TRegistryReader }

constructor TRegistryReader.Create;
begin
  inherited Create;
  FRegistry := TRegistry.Create(KEY_READ);
  FCurrentRootKey := HKEY_LOCAL_MACHINE;
  FCurrentPath := '';
  FRegistry.RootKey := FCurrentRootKey;
end;

destructor TRegistryReader.Destroy;
begin
  FRegistry.Free;
  inherited Destroy;
end;

function TRegistryReader.SetRootKey(RootKey: HKEY): Boolean;
begin
  try
    FCurrentRootKey := RootKey;
    FRegistry.RootKey := RootKey;
    FCurrentPath := '';
    Result := True;
  except
    Result := False;
  end;
end;

function TRegistryReader.OpenKey(const KeyPath: string; CanCreate: Boolean): Boolean;
begin
  try
    Result := FRegistry.OpenKey(KeyPath, CanCreate);
    if Result then
      FCurrentPath := KeyPath;
  except
    Result := False;
  end;
end;

function TRegistryReader.KeyExists(const KeyPath: string): Boolean;
begin
  try
    Result := FRegistry.KeyExists(KeyPath);
  except
    Result := False;
  end;
end;

procedure TRegistryReader.CloseKey;
begin
  FRegistry.CloseKey;
  FCurrentPath := '';
end;

function TRegistryReader.ValueExists(const ValueName: string): Boolean;
begin
  try
    Result := FRegistry.ValueExists(ValueName);
  except
    Result := False;
  end;
end;

function TRegistryReader.ReadString(const ValueName: string; const DefaultValue: string): string;
begin
  try
    if FRegistry.ValueExists(ValueName) then
      Result := FRegistry.ReadString(ValueName)
    else
      Result := DefaultValue;
  except
    Result := DefaultValue;
  end;
end;

function TRegistryReader.ReadInteger(const ValueName: string; DefaultValue: Integer): Integer;
begin
  try
    if FRegistry.ValueExists(ValueName) then
      Result := FRegistry.ReadInteger(ValueName)
    else
      Result := DefaultValue;
  except
    Result := DefaultValue;
  end;
end;

function TRegistryReader.ReadBool(const ValueName: string; DefaultValue: Boolean): Boolean;
begin
  try
    if FRegistry.ValueExists(ValueName) then
      Result := FRegistry.ReadBool(ValueName)
    else
      Result := DefaultValue;
  except
    Result := DefaultValue;
  end;
end;

function TRegistryReader.ReadFloat(const ValueName: string; DefaultValue: Double): Double;
begin
  try
    if FRegistry.ValueExists(ValueName) then
      Result := FRegistry.ReadFloat(ValueName)
    else
      Result := DefaultValue;
  except
    Result := DefaultValue;
  end;
end;

function TRegistryReader.ReadDateTime(const ValueName: string; DefaultValue: TDateTime): TDateTime;
begin
  try
    if FRegistry.ValueExists(ValueName) then
      Result := FRegistry.ReadDateTime(ValueName)
    else
      Result := DefaultValue;
  except
    Result := DefaultValue;
  end;
end;

function TRegistryReader.ReadBinaryData(const ValueName: string; var Buffer; BufSize: Integer): Integer;
begin
  try
    if FRegistry.ValueExists(ValueName) then
      Result := FRegistry.ReadBinaryData(ValueName, Buffer, BufSize)
    else
      Result := 0;
  except
    Result := 0;
  end;
end;

function TRegistryReader.GetValueNames(ValueList: TStrings): Boolean;
begin
  try
    FRegistry.GetValueNames(ValueList);
    Result := True;
  except
    ValueList.Clear;
    Result := False;
  end;
end;

function TRegistryReader.GetSubKeyNames(KeyList: TStrings): Boolean;
begin
  try
    FRegistry.GetKeyNames(KeyList);
    Result := True;
  except
    KeyList.Clear;
    Result := False;
  end;
end;

function TRegistryReader.GetDataType(const ValueName: string): TRegDataType;
begin
  try
    if FRegistry.ValueExists(ValueName) then
      Result := FRegistry.GetDataType(ValueName)
    else
      Result := rdUnknown;
  except
    Result := rdUnknown;
  end;
end;

function TRegistryReader.GetDataSize(const ValueName: string): Integer;
begin
  try
    if FRegistry.ValueExists(ValueName) then
      Result := FRegistry.GetDataSize(ValueName)
    else
      Result := -1;
  except
    Result := -1;
  end;
end;

function TRegistryReader.GetDataInfo(const ValueName: string; var DataType: TRegDataType; var DataSize: Integer): Boolean;
begin
  try
    if FRegistry.ValueExists(ValueName) then
    begin
      DataType := FRegistry.GetDataType(ValueName);
      DataSize := FRegistry.GetDataSize(ValueName);
      Result := True;
    end
    else
    begin
      DataType := rdUnknown;
      DataSize := -1;
      Result := False;
    end;
  except
    DataType := rdUnknown;
    DataSize := -1;
    Result := False;
  end;
end;

function TRegistryReader.GetKeyInfo(var NumSubKeys, MaxSubKeyLen, NumValues, MaxValueLen, MaxDataLen: Integer; var FileTime: TFileTime): Boolean;
Var lRegInfo: TRegKeyInfo;
begin

  lRegInfo.NumSubKeys   := NumSubKeys;
  lRegInfo.MaxSubKeyLen := MaxSubKeyLen;
  lRegInfo.NumValues    := NumValues;
  lRegInfo.MaxValueLen  := MaxValueLen;
  lRegInfo.MaxDataLen   := MaxDataLen;
  lRegInfo.FileTime     := FileTime;


  try
    Result := FRegistry.GetKeyInfo(lRegInfo);
   {
    NumSubKeys
    MaxSubKeyLen
    NumValues
    MaxValueLen
    MaxDataLen
    FileTime); }
  except
    Result := False;
  end;
end;

function TRegistryReader.GetCurrentPath: string;
begin
  Result := FCurrentPath;
end;

function TRegistryReader.GetCurrentRootKey: HKEY;
begin
  Result := FCurrentRootKey;
end;

function TRegistryReader.GetFullPath: string;
begin
  Result := GetRootKeyName(FCurrentRootKey);
  if FCurrentPath <> '' then
    Result := Result + '\' + FCurrentPath;
end;

function TRegistryReader.GetRootKeyName(RootKey: HKEY): string;
begin
  case RootKey of
    HKEY_CLASSES_ROOT: Result := 'HKEY_CLASSES_ROOT';
    HKEY_CURRENT_USER: Result := 'HKEY_CURRENT_USER';
    HKEY_LOCAL_MACHINE: Result := 'HKEY_LOCAL_MACHINE';
    HKEY_USERS: Result := 'HKEY_USERS';
    HKEY_PERFORMANCE_DATA: Result := 'HKEY_PERFORMANCE_DATA';
    HKEY_CURRENT_CONFIG: Result := 'HKEY_CURRENT_CONFIG';
    HKEY_DYN_DATA: Result := 'HKEY_DYN_DATA';
  else
    Result := 'UNKNOWN_ROOT_KEY';
  end;
end;

{ TRegistryHelper }

class function TRegistryHelper.ReadStringValue(RootKey: HKEY; const KeyPath, ValueName: string; const DefaultValue: string): string;
var
  RegReader: TRegistryReader;
begin
  RegReader := TRegistryReader.Create;
  try
    RegReader.SetRootKey(RootKey);
    if RegReader.OpenKey(KeyPath, False) then
      Result := RegReader.ReadString(ValueName, DefaultValue)
    else
      Result := DefaultValue;
  finally
    RegReader.Free;
  end;
end;

class function TRegistryHelper.ReadIntegerValue(RootKey: HKEY; const KeyPath, ValueName: string; DefaultValue: Integer): Integer;
var
  RegReader: TRegistryReader;
begin
  RegReader := TRegistryReader.Create;
  try
    RegReader.SetRootKey(RootKey);
    if RegReader.OpenKey(KeyPath, False) then
      Result := RegReader.ReadInteger(ValueName, DefaultValue)
    else
      Result := DefaultValue;
  finally
    RegReader.Free;
  end;
end;

class function TRegistryHelper.ReadBoolValue(RootKey: HKEY; const KeyPath, ValueName: string; DefaultValue: Boolean): Boolean;
var
  RegReader: TRegistryReader;
begin
  RegReader := TRegistryReader.Create;
  try
    RegReader.SetRootKey(RootKey);
    if RegReader.OpenKey(KeyPath, False) then
      Result := RegReader.ReadBool(ValueName, DefaultValue)
    else
      Result := DefaultValue;
  finally
    RegReader.Free;
  end;
end;

class function TRegistryHelper.KeyExists(RootKey: HKEY; const KeyPath: string): Boolean;
var
  RegReader: TRegistryReader;
begin
  RegReader := TRegistryReader.Create;
  try
    RegReader.SetRootKey(RootKey);
    Result := RegReader.KeyExists(KeyPath);
  finally
    RegReader.Free;
  end;
end;

class function TRegistryHelper.ValueExists(RootKey: HKEY; const KeyPath, ValueName: string): Boolean;
var
  RegReader: TRegistryReader;
begin
  RegReader := TRegistryReader.Create;
  try
    RegReader.SetRootKey(RootKey);
    if RegReader.OpenKey(KeyPath, False) then
      Result := RegReader.ValueExists(ValueName)
    else
      Result := False;
  finally
    RegReader.Free;
  end;
end;

class function TRegistryHelper.GetSubKeys(RootKey: HKEY; const KeyPath: string; KeyList: TStrings): Boolean;
var
  RegReader: TRegistryReader;
begin
  RegReader := TRegistryReader.Create;
  try
    RegReader.SetRootKey(RootKey);
    if RegReader.OpenKey(KeyPath, False) then
      Result := RegReader.GetSubKeyNames(KeyList)
    else
    begin
      KeyList.Clear;
      Result := False;
    end;
  finally
    RegReader.Free;
  end;
end;

class function TRegistryHelper.GetValues(RootKey: HKEY; const KeyPath: string; ValueList: TStrings): Boolean;
var
  RegReader: TRegistryReader;
begin
  RegReader := TRegistryReader.Create;
  try
    RegReader.SetRootKey(RootKey);
    if RegReader.OpenKey(KeyPath, False) then
      Result := RegReader.GetValueNames(ValueList)
    else
    begin
      ValueList.Clear;
      Result := False;
    end;
  finally
    RegReader.Free;
  end;
end;

end.

// =============================================================================
// ESEMPI DI UTILIZZO
// =============================================================================

{
// Esempio 1: Uso base della classe TRegistryReader
procedure Example1;
var
  RegReader: TRegistryReader;
  Version: string;
begin
  RegReader := TRegistryReader.Create;
  try
    RegReader.SetRootKey(HKEY_LOCAL_MACHINE);
    if RegReader.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion', False) then
    begin
      Version := RegReader.ReadString('ProductName', 'Non trovato');
      ShowMessage('Windows: ' + Version);
      RegReader.CloseKey;
    end;
  finally
    RegReader.Free;
  end;
end;

// Esempio 2: Enumerazione chiavi e valori
procedure Example2;
var
  RegReader: TRegistryReader;
  KeyList, ValueList: TStringList;
  i: Integer;
begin
  RegReader := TRegistryReader.Create;
  KeyList := TStringList.Create;
  ValueList := TStringList.Create;
  try
    RegReader.SetRootKey(HKEY_LOCAL_MACHINE);
    if RegReader.OpenKey('SOFTWARE\Microsoft', False) then
    begin
      // Leggi le sottochiavi
      if RegReader.GetSubKeyNames(KeyList) then
      begin
        for i := 0 to KeyList.Count - 1 do
          WriteLn('Chiave: ' + KeyList[i]);
      end;

      // Leggi i valori
      if RegReader.GetValueNames(ValueList) then
      begin
        for i := 0 to ValueList.Count - 1 do
          WriteLn('Valore: ' + ValueList[i]);
      end;

      RegReader.CloseKey;
    end;
  finally
    ValueList.Free;
    KeyList.Free;
    RegReader.Free;
  end;
end;

// Esempio 3: Uso della classe helper per operazioni veloci
procedure Example3;
var
  WindowsVersion: string;
  IsInstalled: Boolean;
  BuildNumber: Integer;
begin
  // Lettura veloce di un valore
  WindowsVersion := TRegistryHelper.ReadStringValue(
    HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows\CurrentVersion',
    'ProductName',
    'Sconosciuto'
  );

  // Verifica esistenza chiave
  IsInstalled := TRegistryHelper.KeyExists(
    HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Office'
  );

  // Lettura valore numerico
  BuildNumber := TRegistryHelper.ReadIntegerValue(
    HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows\CurrentVersion',
    'CurrentBuildNumber',
    0
  );

  ShowMessage(Format('Windows: %s, Build: %d, Office: %s',
    [WindowsVersion, BuildNumber, BoolToStr(IsInstalled, True)]));
end;
}

