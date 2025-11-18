unit ChangePwd;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, Vcl.Menus, Vcl.StdCtrls, cxButtons, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TFChangePwd = class(TForm)
    cbDataBase: TComboBox;
    Label1: TLabel;
    cbUser: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    ePwd: TEdit;
    btChange: TcxButton;
    btClose: TcxButton;
    FDQuery1: TFDQuery;
    FDConnection1: TFDConnection;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure btCloseClick(Sender: TObject);
    procedure cbDataBaseChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btChangeClick(Sender: TObject);
  private
    { Private declarations }
    FSqlServer: String;
  public
    property SqlServer: String read FSqlServer write FSqlServer;
    { Public declarations }

  end;

var
  FChangePwd: TFChangePwd;

implementation

uses BuilderUtils;


{$R *.dfm}



procedure TFChangePwd.btChangeClick(Sender: TObject);
begin
  Edit1.text := Encrypt(cbUser.Text, ePwd.Text, emAes);
  Edit2.text := Decrypt(Edit1.text, ePwd.Text, emAes, True);
end;

procedure TFChangePwd.btCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFChangePwd.cbDataBaseChange(Sender: TObject);
var
  Connection: TFDConnection;
  QueryDB: TFDQuery;
begin
  Connection := TFDConnection.Create(Self);
  QueryDB := TFDQuery.Create(Self);
  try
    Connection.Params.Add('Server=' + FSqlServer);
    Connection.Params.Add('OSAuthent=Yes');
    Connection.Params.Add('Database=' + cbDataBase.Text);
    Connection.Params.Add('DriverID=MSSQL');
    Connection.Connected := True;
    QueryDB.Connection := Connection;
    QueryDB.SQL.Add('Select UserName from cnf_User');
    QueryDB.Open;
    cbUser.Items.Clear;
    while not QueryDB.Eof do
    begin
      cbUser.Items.Add(QueryDB.Fields[0].AsString);
      QueryDB.Next;
    end;
  finally
    QueryDB.Close;
    Connection.Connected := False;
    FreeAndNil(QueryDB);
    FreeAndNil(Connection);
  end;
end;

procedure TFChangePwd.FormShow(Sender: TObject);
var
  Connection: TFDConnection;
  QueryDB: TFDQuery;
  lServerVer, lServer, lSystem: String;
begin
  Connection := TFDConnection.Create(Self);
  QueryDB := TFDQuery.Create(Self);
  try
    Connection.Params.Add('Server=' + FSqlServer);
    Connection.Params.Add('OSAuthent=Yes');
    Connection.Params.Add('Database=master');
    Connection.Params.Add('DriverID=MSSQL');
    Connection.Connected := True;
    QueryDB.Connection := Connection;
    QueryDB.SQL.Add(FDQuery1.SQL.Text);
    QueryDB.Open;
    cbDataBase.Items.Clear;
    while not QueryDB.Eof do
    begin
      cbDataBase.Items.Add(QueryDB.Fields[1].AsString);
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
