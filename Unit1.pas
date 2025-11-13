unit Unit1;

interface
uses
  FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Stan.Async, FireDAC.DApt, System.SysUtils;

procedure QueryTableInAllDatabases(const TableName, QuerySQL: string);
procedure QueryTableInAllDatabasesWithCheck(const TableName, SelectFields: string);
procedure CollectDataFromAllDatabases(const TableName, SelectFields: string; ResultDataSet: TFDMemTable);

implementation

// Versione base: query su una tabella specifica in tutti i DB
procedure QueryTableInAllDatabases(const TableName, QuerySQL: string);
var
  Connection: TFDConnection;
  QueryDB, QueryTable: TFDQuery;
  DatabaseName: string;
begin
//  Connection := TFDConnection.Create(nil);
//  QueryDB := TFDQuery.Create(nil);
//  QueryTable := TFDQuery.Create(nil);
//  try
//    // Configurazione connessione
//    Connection.DriverName := 'MSSQL';
//    Connection.Params.Add('Server=localhost');
//    Connection.Params.Add('Database=master');
//    Connection.Params.Add('OSAuthent=Yes');
//    Connection.Connected := True;
//
//    QueryDB.Connection := Connection;
//    QueryTable.Connection := Connection;
//
//    // Ottieni tutti i database (esclude quelli di sistema)
//    QueryDB.SQL.Text := 'SELECT name FROM sys.databases WHERE database_id > 4 AND state = 0 ORDER BY name';
//    QueryDB.Open;
//
//    while not QueryDB.Eof do
//    begin
//      DatabaseName := QueryDB.FieldByName('name').AsString;
//
//      try
//        // Costruisci la query per il database specifico
//        QueryTable.SQL.Text := Format('USE [%s]; %s', [DatabaseName, QuerySQL]);
//        QueryTable.Open;
//
//        ShowMessage(Format('Database: %s - Righe trovate: %d',
//          [DatabaseName, QueryTable.RecordCount]));
//
//        // Elabora i risultati per questo database
//        while not QueryTable.Eof do
//        begin
//          // Qui puoi elaborare i dati specifici
//          // Esempio: ShowMessage(QueryTable.Fields[0].AsString);
//          QueryTable.Next;
//        end;
//
//        QueryTable.Close;
//
//      except
//        on E: Exception do
//          ShowMessage(Format('Errore nel database %s: %s', [DatabaseName, E.Message]));
//      end;
//
//      QueryDB.Next;
//    end;
//
//  finally
//    QueryTable.Free;
//    QueryDB.Free;
//    Connection.Free;
//  end;
end;

// Versione avanzata: controlla se la tabella esiste prima di fare la query
procedure QueryTableInAllDatabasesWithCheck(const TableName, SelectFields: string);
var
  Connection: TFDConnection;
  QueryDB, QueryCheck, QueryTable: TFDQuery;
  DatabaseName, FullSQL: string;
begin
//  Connection := TFDConnection.Create(nil);
//  QueryDB := TFDQuery.Create(nil);
//  QueryCheck := TFDQuery.Create(nil);
//  QueryTable := TFDQuery.Create(nil);
//  try
//    Connection.DriverName := 'MSSQL';
//    Connection.Params.Add('Server=localhost');
//    Connection.Params.Add('Database=master');
//    Connection.Params.Add('OSAuthent=Yes');
//    Connection.Connected := True;
//
//    QueryDB.Connection := Connection;
//    QueryCheck.Connection := Connection;
//    QueryTable.Connection := Connection;
//
//    // Ottieni tutti i database utente
//    QueryDB.SQL.Text := 'SELECT name FROM sys.databases WHERE database_id > 4 AND state = 0 ORDER BY name';
//    QueryDB.Open;
//
//    while not QueryDB.Eof do
//    begin
//      DatabaseName := QueryDB.FieldByName('name').AsString;
//
//      try
//        // Verifica se la tabella esiste nel database
//        QueryCheck.SQL.Text := Format(
//          'SELECT COUNT(*) as TableExists FROM [%s].INFORMATION_SCHEMA.TABLES ' +
//          'WHERE TABLE_NAME = ''%s''', [DatabaseName, TableName]);
//        QueryCheck.Open;
//
//        if QueryCheck.FieldByName('TableExists').AsInteger > 0 then
//        begin
//          // La tabella esiste, esegui la query
//          FullSQL := Format('SELECT %s FROM [%s].dbo.[%s]',
//            [SelectFields, DatabaseName, TableName]);
//
//          QueryTable.SQL.Text := FullSQL;
//          QueryTable.Open;
//
//          ShowMessage(Format('Database: %s - Tabella: %s - Righe: %d',
//            [DatabaseName, TableName, QueryTable.RecordCount]));
//
//          // Elabora i risultati
//          while not QueryTable.Eof do
//          begin
//            // Processa i dati qui
//            QueryTable.Next;
//          end;
//
//          QueryTable.Close;
//        end
//        else
//        begin
//          ShowMessage(Format('Tabella %s non trovata nel database %s', [TableName, DatabaseName]));
//        end;
//
//        QueryCheck.Close;
//
//      except
//        on E: Exception do
//          ShowMessage(Format('Errore nel database %s: %s', [DatabaseName, E.Message]));
//      end;
//
//      QueryDB.Next;
//    end;
//
//  finally
//    QueryTable.Free;
//    QueryCheck.Free;
//    QueryDB.Free;
//    Connection.Free;
//  end;
end;

// Versione per raccogliere risultati in un dataset unificato
procedure CollectDataFromAllDatabases(const TableName, SelectFields: string;
  ResultDataSet: TFDMemTable);
var
  Connection: TFDConnection;
  QueryDB, QueryTable: TFDQuery;
  DatabaseName: string;
  i: Integer;
begin
//  Connection := TFDConnection.Create(nil);
//  QueryDB := TFDQuery.Create(nil);
//  QueryTable := TFDQuery.Create(nil);
//  try
//    Connection.DriverName := 'MSSQL';
//    Connection.Params.Add('Server=localhost');
//    Connection.Params.Add('Database=master');
//    Connection.Params.Add('OSAuthent=Yes');
//    Connection.Connected := True;
//
//    QueryDB.Connection := Connection;
//    QueryTable.Connection := Connection;
//
//    // Prepara il MemTable risultato
//    if not ResultDataSet.Active then
//    begin
//      // Aggiungi campo per il nome database
//      ResultDataSet.FieldDefs.Add('DatabaseName', ftString, 100);
//      // Qui dovresti aggiungere gli altri campi in base alla tua tabella
//      ResultDataSet.CreateDataSet;
//    end;
//
//    QueryDB.SQL.Text := 'SELECT name FROM sys.databases WHERE database_id > 4 AND state = 0 ORDER BY name';
//    QueryDB.Open;
//
//    while not QueryDB.Eof do
//    begin
//      DatabaseName := QueryDB.FieldByName('name').AsString;
//
//      try
//        QueryTable.SQL.Text := Format('SELECT %s FROM [%s].dbo.[%s]',
//          [SelectFields, DatabaseName, TableName]);
//        QueryTable.Open;
//
//        // Copia i dati nel MemTable
//        while not QueryTable.Eof do
//        begin
//          ResultDataSet.Append;
//          ResultDataSet.FieldByName('DatabaseName').AsString := DatabaseName;
//
//          // Copia gli altri campi
//          for i := 0 to QueryTable.FieldCount - 1 do
//          begin
//            if ResultDataSet.FindField(QueryTable.Fields[i].FieldName) <> nil then
//              ResultDataSet.FieldByName(QueryTable.Fields[i].FieldName).Value :=
//                QueryTable.Fields[i].Value;
//          end;
//
//          ResultDataSet.Post;
//          QueryTable.Next;
//        end;
//
//        QueryTable.Close;
//
//      except
//        on E: Exception do
//          ShowMessage(Format('Errore nel database %s: %s', [DatabaseName, E.Message]));
//      end;
//
//      QueryDB.Next;
//    end;
//
//  finally
//    QueryTable.Free;
//    QueryDB.Free;
//    Connection.Free;
//  end;
end;

// Esempio di utilizzo
procedure EsempioUtilizzo;
var
  MemTable: TFDMemTable;
begin
  // Esempio 1: Query semplice su tutti i DB
  QueryTableInAllDatabases('Users', 'SELECT COUNT(*) FROM Users');

  // Esempio 2: Con controllo esistenza tabella
  QueryTableInAllDatabasesWithCheck('Products', 'ProductID, ProductName, Price');

  // Esempio 3: Raccolta dati unificata
  MemTable := TFDMemTable.Create(nil);
  try
    CollectDataFromAllDatabases('Customers', 'CustomerID, CustomerName', MemTable);
    // Ora MemTable contiene tutti i dati da tutti i database
  finally
    MemTable.Free;
  end;
end;

// Query con JOIN tra database (esempio avanzato)
procedure CrossDatabaseQuery;
var
  Connection: TFDConnection;
  Query: TFDQuery;
begin
//  Connection := TFDConnection.Create(nil);
//  Query := TFDQuery.Create(nil);
//  try
//    Connection.DriverName := 'MSSQL';
//    Connection.Params.Add('Server=localhost');
//    Connection.Params.Add('Database=master');
//    Connection.Params.Add('OSAuthent=Yes');
//    Connection.Connected := True;
//
//    Query.Connection := Connection;
//
//    // Esempio di query che unisce dati da più database
//    Query.SQL.Text :=
//      'SELECT ' +
//      '  db.name as DatabaseName, ' +
//      '  t.TABLE_NAME as TableName, ' +
//      '  t.TABLE_TYPE as TableType ' +
//      'FROM sys.databases db ' +
//      'CROSS APPLY ( ' +
//      '  SELECT TABLE_NAME, TABLE_TYPE ' +
//      '  FROM [' + '''' + ' + db.name + ' + '''' + '].INFORMATION_SCHEMA.TABLES ' +
//      '  WHERE TABLE_NAME = ''Users'' ' +
//      ') t ' +
//      'WHERE db.database_id > 4 AND db.state = 0';
//
//    Query.Open;
//
//    while not Query.Eof do
//    begin
//      ShowMessage(Format('Database: %s, Tabella: %s',
//        [Query.FieldByName('DatabaseName').AsString,
//         Query.FieldByName('TableName').AsString]));
//      Query.Next;
//    end;
//
//  finally
//    Query.Free;
//    Connection.Free;
//  end;
end;

end.
