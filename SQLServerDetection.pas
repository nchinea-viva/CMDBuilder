unit SQLServerDetection;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Win.Registry,
  Winapi.Windows, Winapi.WinSvc, System.Generics.Collections, Data.DB, Data.SqlExpr, Data.DBXMSSQLMetaData;

type
  TSQLServerInstance = record
    Name: string;
    Version: string;
    ServiceName: string;
    Status: string;
  end;

  TSQLServerDetector = class
  private
    FInstances: TArray<TSQLServerInstance>;
    function GetServiceStatus(const ServiceName: string): string;
    function GetSQLServerVersion(const InstanceName: string): string;
  public
    function DetectInstances: Boolean;
    function GetInstanceCount: Integer;
    function GetInstance(Index: Integer): TSQLServerInstance;
    function TestConnection(const ServerName: string; const Database: string = 'master'): Boolean;
    property Instances: TArray<TSQLServerInstance> read FInstances;
  end;

implementation

{ TSQLServerDetector }

function TSQLServerDetector.DetectInstances: Boolean;
var
  Registry: TRegistry;
  KeyList: TStringList;
  i: Integer;
  InstanceName, ServiceName: string;
  Instance: TSQLServerInstance;
  TempList: TList<TSQLServerInstance>;
begin
  Result := False;
  TempList := TList<TSQLServerInstance>.Create;
  try
    Registry := TRegistry.Create(KEY_READ);
    KeyList := TStringList.Create;
    try
      Registry.RootKey := HKEY_LOCAL_MACHINE;

      // Ricerca istanze di SQL Server nel registro
      if Registry.OpenKey('SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL', False) then
      begin
        Registry.GetValueNames(KeyList);
        Registry.CloseKey;

        for i := 0 to KeyList.Count - 1 do
        begin
          InstanceName := KeyList[i];

          // Determina il nome del servizio
          if UpperCase(InstanceName) = 'MSSQLSERVER' then
            ServiceName := 'MSSQLSERVER'
          else
            ServiceName := 'MSSQL$' + InstanceName;

          Instance.Name := InstanceName;
          Instance.ServiceName := ServiceName;
          Instance.Status := GetServiceStatus(ServiceName);
          Instance.Version := GetSQLServerVersion(InstanceName);

          TempList.Add(Instance);
        end;

        Result := TempList.Count > 0;
      end;

      // Controlla anche SQL Server Express LocalDB
      if Registry.OpenKey('SOFTWARE\Microsoft\Microsoft SQL Server Local DB\Installed Versions', False) then
      begin
        Registry.GetKeyNames(KeyList);
        Registry.CloseKey;

        for i := 0 to KeyList.Count - 1 do
        begin
          Instance.Name := 'LocalDB v' + KeyList[i];
          Instance.ServiceName := 'SQL Server LocalDB';
          Instance.Status := 'LocalDB';
          Instance.Version := KeyList[i];

          TempList.Add(Instance);
        end;

        Result := True;
      end;

    finally
      KeyList.Free;
      Registry.Free;
    end;

    // Converti TList in array
    SetLength(FInstances, TempList.Count);
    for i := 0 to TempList.Count - 1 do
      FInstances[i] := TempList[i];

  finally
    TempList.Free;
  end;
end;

function TSQLServerDetector.GetServiceStatus(const ServiceName: string): string;
var
  SCManager, Service: SC_HANDLE;
  ServiceStatus: SERVICE_STATUS;
begin
  Result := 'Sconosciuto';

  SCManager := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
  if SCManager = 0 then Exit;

  try
    Service := OpenService(SCManager, PChar(ServiceName), SERVICE_QUERY_STATUS);
    if Service = 0 then
    begin
      Result := 'Non installato';
      Exit;
    end;

    try
      if QueryServiceStatus(Service, ServiceStatus) then
      begin
        case ServiceStatus.dwCurrentState of
          SERVICE_STOPPED: Result := 'Fermato';
          SERVICE_START_PENDING: Result := 'Avvio in corso';
          SERVICE_STOP_PENDING: Result := 'Arresto in corso';
          SERVICE_RUNNING: Result := 'In esecuzione';
          SERVICE_CONTINUE_PENDING: Result := 'Ripresa in corso';
          SERVICE_PAUSE_PENDING: Result := 'Pausa in corso';
          SERVICE_PAUSED: Result := 'In pausa';
        else
          Result := 'Stato sconosciuto';
        end;
      end;
    finally
      CloseServiceHandle(Service);
    end;
  finally
    CloseServiceHandle(SCManager);
  end;
end;

function TSQLServerDetector.GetSQLServerVersion(const InstanceName: string): string;
var
  Registry: TRegistry;
  KeyPath: string;
begin
  Result := 'Versione sconosciuta';
  Registry := TRegistry.Create(KEY_READ);
  try
    Registry.RootKey := HKEY_LOCAL_MACHINE;

    // Cerca la versione nel registro
    if Registry.OpenKey('SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL', False) then
    begin
      KeyPath := Registry.ReadString(InstanceName);
      Registry.CloseKey;

      if Registry.OpenKey('SOFTWARE\Microsoft\Microsoft SQL Server\' + KeyPath + '\MSSQLServer\CurrentVersion', False) then
      begin
        if Registry.ValueExists('CurrentVersion') then
          Result := Registry.ReadString('CurrentVersion');
        Registry.CloseKey;
      end;
    end;
  finally
    Registry.Free;
  end;
end;

function TSQLServerDetector.GetInstanceCount: Integer;
begin
  Result := Length(FInstances);
end;

function TSQLServerDetector.GetInstance(Index: Integer): TSQLServerInstance;
begin
  if (Index >= 0) and (Index < Length(FInstances)) then
    Result := FInstances[Index]
  else
    raise EArgumentOutOfRangeException.Create('Indice fuori range');
end;

function TSQLServerDetector.TestConnection(const ServerName: string; const Database: string): Boolean;
var
  Connection: TSQLConnection;
begin
  Result := False;
  Connection := TSQLConnection.Create(nil);
  try
    Connection.DriverName := 'MSSQL';
    Connection.LibraryName := 'sqlncli11.dll'; // o sqlncli10.dll per versioni precedenti
    Connection.VendorLib := 'sqlncli11.dll';
    Connection.GetDriverFunc := 'getSQLDriverMSSQL';

    // Configura la connessione
    Connection.Params.Clear;
    Connection.Params.Add('HostName=' + ServerName);
    Connection.Params.Add('Database=' + Database);
    Connection.Params.Add('OS Authentication=True'); // Usa autenticazione Windows
    Connection.LoginPrompt := False;

    try
      Connection.Open;
      Result := Connection.Connected;
      if Connection.Connected then
        Connection.Close;
    except
      on E: Exception do
      begin
        // Ignora l'eccezione, Result rimane False
        Result := False;
      end;
    end;
  finally
    Connection.Free;
  end;
end;

end.

// =============================================================================
// ESEMPIO DI UTILIZZO
// =============================================================================

{
procedure TForm1.Button1Click(Sender: TObject);
var
  Detector: TSQLServerDetector;
  i: Integer;
  Instance: TSQLServerInstance;
  ServerName: string;
begin
  Detector := TSQLServerDetector.Create;
  try
    Memo1.Lines.Clear;
    Memo1.Lines.Add('Ricerca istanze SQL Server in corso...');

    if Detector.DetectInstances then
    begin
      Memo1.Lines.Add('Trovate ' + IntToStr(Detector.GetInstanceCount) + ' istanze:');
      Memo1.Lines.Add('');

      for i := 0 to Detector.GetInstanceCount - 1 do
      begin
        Instance := Detector.GetInstance(i);
        Memo1.Lines.Add('Istanza: ' + Instance.Name);
        Memo1.Lines.Add('Servizio: ' + Instance.ServiceName);
        Memo1.Lines.Add('Stato: ' + Instance.Status);
        Memo1.Lines.Add('Versione: ' + Instance.Version);

        // Test connessione
        if Instance.Name = 'MSSQLSERVER' then
          ServerName := '.'
        else if Instance.Name.StartsWith('LocalDB') then
          ServerName := '(localdb)\MSSQLLocalDB'
        else
          ServerName := '.\' + Instance.Name;

        if Detector.TestConnection(ServerName) then
          Memo1.Lines.Add('Connessione: OK')
        else
          Memo1.Lines.Add('Connessione: FALLITA');

        Memo1.Lines.Add('-------------------');
      end;
    end
    else
    begin
      Memo1.Lines.Add('Nessuna istanza SQL Server trovata.');
    end;
  finally
    Detector.Free;
  end;
end;
}
