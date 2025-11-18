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
    FDCommand: TFDCommand;
    Edit3: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure cbDataBaseChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btChangeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FSqlServer: String;
    FConnection: TFDConnection;
    Procedure SetConnection(Const AServer, ADataBase: String);
  public
    property Connection: TFDConnection read FConnection write FConnection;
    property SqlServer: String read FSqlServer write FSqlServer;
    { Public declarations }

  end;

var
  FChangePwd: TFChangePwd;

implementation

uses BuilderUtils;


{$R *.dfm}



procedure TFChangePwd.FormCreate(Sender: TObject);
begin
  Connection := TFDConnection.Create(Self);
end;

procedure TFChangePwd.btChangeClick(Sender: TObject);
Var lUserId: Integer;
begin
  lUserId := Integer(cbUser.Items.Objects[cbUser.ItemIndex]);

  Edit3.text := 'User id = ' + lUserId.ToString;
  Edit1.text := Encrypt(cbUser.Text, ePwd.Text, emAes);
  Edit2.text := Decrypt(Edit1.text, ePwd.Text, emAes, True);
  SetConnection(FSqlServer, cbDataBase.Text);
  FDCommand.CommandText.Add('Update cnf_user set UserPassword ='''+ Edit1.text +''' where UserId='+lUserId.ToString);
  FDCommand.Connection := Connection;
  FDCommand.Execute;

end;

procedure TFChangePwd.btCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFChangePwd.cbDataBaseChange(Sender: TObject);
var
  QueryDB: TFDQuery;

begin
  QueryDB := TFDQuery.Create(Self);
  try
    SetConnection(FSqlServer, cbDataBase.Text);
    QueryDB.Connection := Connection;
    QueryDB.SQL.Add('Select UserId, UserCode from cnf_User');
    QueryDB.Open;
    cbUser.Items.Clear;
    while not QueryDB.Eof do
    begin
      cbUser.Items.AddObject(QueryDB.Fields[1].AsString, TObject(QueryDB.Fields[0].AsInteger));
      QueryDB.Next;
    end;
  finally
    QueryDB.Close;
    FreeAndNil(QueryDB);
  end;
end;

procedure TFChangePwd.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Connection.Connected := False;
  FreeAndNil(Connection);
end;

procedure TFChangePwd.FormShow(Sender: TObject);
var
  QueryDB: TFDQuery;
  lServerVer, lServer, lSystem: String;
begin
  QueryDB := TFDQuery.Create(Self);
  try
    SetConnection(FSqlServer, 'master');
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
    FreeAndNil(QueryDB);
  end;
end;

procedure TFChangePwd.SetConnection(const AServer, ADataBase: String);
begin
  Connection.Connected := False;
  Connection.Params.Clear;
  Connection.Params.Add('Server=' + AServer);
  Connection.Params.Add('OSAuthent=Yes');
  Connection.Params.Add('Database=' + ADataBase);
  Connection.Params.Add('DriverID=MSSQL');
  Connection.Connected := True;
end;

end.
