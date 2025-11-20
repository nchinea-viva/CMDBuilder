unit IniConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  ConfigManager,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, Vcl.Menus, cxButtons, Vcl.ExtCtrls;

type
  TRecIni=record
    Server: String;
    SysID: String;
    DB: String;
  end;

  TFIniConfig = class(TForm)
    eServer: TEdit;
    Label1: TLabel;
    eSysID: TEdit;
    Label2: TLabel;
    eDB: TEdit;
    Label3: TLabel;
    gbConfig: TGroupBox;
    ListView1: TListView;
    Label4: TLabel;
    eActiveServer: TEdit;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    eNewDB: TEdit;
    eNewServer: TEdit;
    eNewSysID: TEdit;
    btnSaveConfig: TcxButton;
    BtnReload: TcxButton;
    pFondo: TPanel;
    btClose: TcxButton;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    eUDPServer: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    eNewUDPServer: TEdit;
    eUDPPort: TEdit;
    Label10: TLabel;
    ckUDPLog: TCheckBox;
    Label11: TLabel;
    eNewUDPPort: TEdit;
    ckNewUDPLog: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnSaveConfigClick(Sender: TObject);
    procedure BtnReloadClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
  private
    FIniAppConfig: TConfigManager;
    procedure CurrentConfig;
    procedure LoadDataBase;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FIniConfig: TFIniConfig;

implementation

{$R *.dfm}
Uses System.IniFiles, TrayMainForm;

procedure TFIniConfig.CurrentConfig;
Var lFileIni: String;
begin
  lFileIni :=  TfrmTrayMain(Self.Owner).FRecConfig.PathAPPBOS;
  lFileIni := ExtractFilePath(lFileIni);
  lFileIni := lFileIni  + 'IsapiSettingsAdvance.ini';
  FIniAppConfig := TConfigManager.Create(lFileIni);
  eServer.Text := FIniAppConfig.ReadString('CONNECTION', 'Server', 'localhost');
  eSysID.Text  := FIniAppConfig.ReadString('CONNECTION', 'SystemId', '');
  eDB.Text     := FIniAppConfig.ReadString('CONNECTION', 'DB', '');
  eUDPServer.Text   := FIniAppConfig.ReadString('LOG', 'UDPServer', '');
  eUDPPort.Text     := FIniAppConfig.ReadInteger('LOG', 'UDPPORT', 23456).ToString;
  ckUDPLog.Checked  := FIniAppConfig.ReadInteger('LOG', 'UDPLog', 0) = 1;
end;

procedure TFIniConfig.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(FIniAppConfig);
end;

procedure TFIniConfig.FormShow(Sender: TObject);
begin
  CurrentConfig;
  eActiveServer.Text := TfrmTrayMain(Self.Owner).FRecConfig.SqlServer;
  LoadDataBase;
end;

procedure TFIniConfig.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Item <> nil then
  begin
    eNewServer.Text := eActiveServer.Text;
    eNewSysID.Text := Item.caption;
    eNewDB.Text := Item.SubItems[0];
  end;
end;

procedure TFIniConfig.btCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFIniConfig.BtnReloadClick(Sender: TObject);
begin
  LoadDataBase;
end;

procedure TFIniConfig.btnSaveConfigClick(Sender: TObject);
begin
  if eNewServer.Text <> '' then
    FIniAppConfig.WriteString('CONNECTION', 'Server', eNewServer.Text);

  if eNewSysID.Text <> '' then
    FIniAppConfig.WriteString('CONNECTION', 'SystemId', eNewSysID.Text);

  if eNewDB.Text <> '' then
    FIniAppConfig.WriteString('CONNECTION', 'DB', eNewDB.Text);

  If eNewUDPServer.Text <> '' then
    FIniAppConfig.WriteString('LOG', 'UDPServer', eNewUDPServer.Text);

  If eNewUDPPort.Text <> '' then
    FIniAppConfig.WriteInteger('LOG', 'UDPPORT', StrToInt(eNewUDPPort.Text));

  FIniAppConfig.WriteInteger('LOG', 'UDPLog', INTEGER(ckNewUDPLog.Checked));
end;

procedure TFIniConfig.LoadDataBase;
var
  Connection: TFDConnection;
  QueryDB: TFDQuery;
  lServerVer, lServer, lSystem: String;
  Item: TListItem;
  I: Integer;
begin
  Connection := TFDConnection.Create(Self);
  QueryDB := TFDQuery.Create(Self);
  try
    Connection.Params.Add('Server=' + eActiveServer.Text);
    Connection.Params.Add('OSAuthent=Yes');
    Connection.Params.Add('Database=master');
    Connection.Params.Add('DriverID=MSSQL');
    Connection.Connected := True;
    QueryDB.Connection := Connection;
    QueryDB.SQL.Add(TfrmTrayMain(Self.Owner).FDQuery1.SQL.Text);
    QueryDB.Open;
    ListView1.Items.Clear;
    while not QueryDB.Eof do
    begin
      Item := ListView1.Items.Add;
      Item.caption := QueryDB.Fields[0].AsString;
      item.SubItems.Add(QueryDB.Fields[1].AsString);
      item.SubItems.Add(QueryDB.Fields[2].AsString);
      QueryDB.Next;
    end;
  finally
    QueryDB.Close;
    Connection.Connected := False;
    FreeAndNil(QueryDB);
    FreeAndNil(Connection);
  end;
end;

end.
