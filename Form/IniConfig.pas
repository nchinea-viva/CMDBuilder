unit IniConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  ConfigManager,RegularExpressions,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, Vcl.Menus, cxButtons, Vcl.ExtCtrls, Vcl.CheckLst;

type
TLogCategories = (
     lcCache    ,lcCustomForm    ,lcDB    ,lcDEBUG    ,lcDevices    ,lcDrivers    ,lcLicense
    ,lcLogin    ,lcModules    ,lcOfflineSync    ,lcOMEAApplication    ,lcPackages    ,lcPayments
    ,lcPromotion    ,lcQueryBuilder    ,lcReport    ,lcResevations    ,lcResourceManagement
    ,lcSale    ,lcSaleBoard    ,lcServices    ,lcShopCart    ,lcStandAlone    ,lcStandard
    ,lcStock    ,lcTickets    ,lcValidity    ,lcXML    ,lcTVM    ,lcDrvJob    ,lcScheduler
    ,lcPerformance    ,lcAccessPoint    ,lcCloseOrder    ,lcWarehouse    ,lcProduct    ,lcRestAPI    ,lcTenderSplit
    ,lcZatca);
  TLogCategoriesHelper = record helper for TLogCategories
    function  ToString: String;
    function  GetColor: TColor;
    function  GetFontColor: TColor;
    procedure SetCategoryDefaultColor(AColor: TColor);
    procedure SetCategoryDefaultFontColor(AColor: TColor);
  end;
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
    Label12: TLabel;
    eCodeSite: TEdit;
    cbCategories: TCheckListBox;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    eLogFolePath: TEdit;
    Label16: TLabel;
    eNewLogFolePath: TEdit;
    btnLogPath: TcxButton;
    OpenDialog1: TOpenDialog;
    ckStackTrace: TCheckBox;
    Label17: TLabel;
    eRedis: TEdit;
    ckNewStackTrace: TCheckBox;
    eNewRedis: TEdit;
    Label18: TLabel;
    Label19: TLabel;
    cbNewFlexCache: TComboBox;
    Label20: TLabel;
    cbFlexCache: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnSaveConfigClick(Sender: TObject);
    procedure BtnReloadClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure btnLogPathClick(Sender: TObject);
    procedure cbCategoriesClickCheck(Sender: TObject);
  private
    FIniAppConfig: TConfigManager;
    FLogCategories: TStringList;
    procedure FillCheckBox;
    function  GetLogCategories: string;
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
Uses System.IniFiles, TrayMainForm, System.StrUtils;

procedure TFIniConfig.FormCreate(Sender: TObject);
begin
  FLogCategories := TStringList.Create;
end;

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
  ckNewUDPLog.Checked  :=  ckUDPLog.Checked;
  eCodeSite.Text    := FIniAppConfig.ReadString('LOGGER', 'CATEGORIES', '');
  ckStackTrace.Checked  := FIniAppConfig.ReadInteger('STACKTRACE', 'ACTIVE', 0) = 1;
  ckNewStackTrace.Checked  := ckStackTrace.Checked;
  eRedis.text       := FIniAppConfig.ReadString('REDIS', 'BaseUrl', '');
  cbFlexCache.ItemIndex := FIniAppConfig.ReadInteger('FLEXIBLECACHE', 'MODE', 0);
  cbNewFlexCache.ItemIndex :=   cbFlexCache.ItemIndex;
  FLogCategories.Delimiter := ',';
  FLogCategories.DelimitedText := TRegEx.Replace(eCodeSite.Text, ' *, *', ',');
end;

procedure TFIniConfig.FillCheckBox;
var
  cat : TLogCategories;
  lIndex: Integer;
begin
  for cat := Low(TLogCategories) to High(TLogCategories) do
  begin
    cbCategories.Items.Add(cat.ToString);
    lIndex := cbCategories.Items.IndexOf(cat.ToString);
    cbCategories.Checked[lIndex] := False;
    if Assigned(FLogCategories) and MatchText(cat.ToString, FLogCategories.ToStringArray) then
      cbCategories.Checked[lIndex] := True;
  end;

end;

procedure TFIniConfig.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(FIniAppConfig);
  FreeAndNil(FLogCategories);
end;

procedure TFIniConfig.FormShow(Sender: TObject);
begin
  CurrentConfig;
  eActiveServer.Text := TfrmTrayMain(Self.Owner).FRecConfig.SqlServer;
  LoadDataBase;
  FillCheckBox;
end;

function TFIniConfig.GetLogCategories: string;
begin
  Result := FLogCategories.CommaText;
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

procedure TFIniConfig.btnLogPathClick(Sender: TObject);
var
  FileOpenDialog: TFileOpenDialog;
begin
  FileOpenDialog := TFileOpenDialog.Create(nil);
  try
    FileOpenDialog.Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem];
    FileOpenDialog.Title := 'Select Folder';
    if FileOpenDialog.Execute then
      eNewLogFolePath.Text   := FileOpenDialog.FileName;
  finally
    FileOpenDialog.Free;
  end;

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

  FIniAppConfig.WriteInteger('LOGGER', 'LOGGER_CODESITE_ACTIVE', Integer(GetLogCategories <> ''));
  FIniAppConfig.WriteString('LOGGER', 'CATEGORIES', GetLogCategories);

  FIniAppConfig.WriteInteger('LOGGER', 'LOGGER_PRO_ACTIVE', Integer(eNewLogFolePath.Text <> ''));
  FIniAppConfig.WriteString('LOGGER','LOG_FILE_PATH', eNewLogFolePath.Text);

  If eNewRedis.Text <> '' then
    FIniAppConfig.WriteString('REDIS', 'BaseUrl', eNewRedis.Text);

  if ckNewStackTrace.Checked <> ckStackTrace.Checked then
    FIniAppConfig.WriteInteger('STACKTRACE', 'ACTIVE', INTEGER(ckNewStackTrace.Checked));

  if cbNewFlexCache.ItemIndex >=0 then
    FIniAppConfig.WriteInteger('FLEXIBLECACHE', 'MODE', cbNewFlexCache.ItemIndex);

  FIniAppConfig.SaveToFile;

  Close;
end;

procedure TFIniConfig.cbCategoriesClickCheck(Sender: TObject);
var
  lIndex: Integer;
  lChecked: Boolean;
  lItemName: String;
begin
  lIndex    := cbCategories.ItemIndex;
  lItemName := cbCategories.Items[lIndex];
  lChecked  := cbCategories.Checked[lIndex];
  if lChecked then
    FLogCategories.Add(cbCategories.Items[lIndex])
  else
  begin
    lIndex := FLogCategories.IndexOf(lItemName);
    if lIndex > -1 then
      FLogCategories.Delete(lIndex);
  end;

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

{ TLogCategoriesHelper }

function TLogCategoriesHelper.GetColor: TColor;
begin
  Result:= clRed;
end;

function TLogCategoriesHelper.GetFontColor: TColor;
begin
  Result:= clBlack;
end;

procedure TLogCategoriesHelper.SetCategoryDefaultColor(AColor: TColor);
begin
//  _CategoryBgColor.AddOrSetValue(Self, AColor);
end;

procedure TLogCategoriesHelper.SetCategoryDefaultFontColor(AColor: TColor);
begin
 // _CategoryFgColor.AddOrSetValue(Self, AColor);
end;

function TLogCategoriesHelper.ToString: String;
begin
  Result:= format( 'NONAME [%d]',[ord(self)]);
  case Self of
    lcCache: Result:= 'CACHE';
    lcCustomForm: Result:= 'CUSTOM FORMS';
    lcDB: Result:= 'DB';
    lcDEBUG: Result:= 'DEBUG';
    lcDevices: Result:= 'DEVICES';
    lcDrivers: Result:= 'DRIVERS';
    lcLicense: Result:= 'LICENCE';
    lcLogin: Result:= 'LOGIN';
    lcModules: Result:= 'MODULES';
    lcOfflineSync: Result:= 'OFFLINE SYNC';
    lcOMEAApplication: Result:= 'OME APPLICATION';
    lcPackages: Result:= 'PACKAGES';
    lcPayments: Result:= 'PAYMENTS';
    lcPromotion: Result:= 'PROMOTIONS';
    lcQueryBuilder: Result:= 'QUERY BUILDER';
    lcReport: Result:= 'REPORTS';
    lcResevations: Result:= 'RESEVATIONS';
    lcResourceManagement: Result:= 'RESOURCE MANAGEMENT';
    lcSale: Result:= 'SALE';
    lcSaleBoard: Result:= 'SALE BOARD';
    lcServices: Result:= 'SERVICES';
    lcShopCart: Result:= 'SHOP CART';
    lcStandAlone: Result:= 'STANDALONE';
    lcStandard: Result:= 'STANDARD';
    lcStock: Result:= 'STOCK';
    lcTickets: Result:= 'TICKETS';
    lcValidity: Result:= 'VALIDITY';
    lcXML: Result:= 'XML';
    lcTVM: Result:= 'TVM';
    lcDrvJob: Result := 'JOB DRIVER';
    lcScheduler: Result := 'SCHEDULER';
    lcPerformance: Result := 'PERFORMANCE';
    lcAccessPoint: Result := 'ACCESS POINT';
    lcCloseOrder:  Result := 'CLOSEORDER';
    lcWarehouse:  Result := 'WAREHOUSE';
    lcProduct:    Result := 'PRODUCT';
    lcRestAPI:    Result := 'REST API';
    lcTenderSplit: Result := 'TENDERSPLIT';
    lcZatca: Result := 'ZATCA';
  end;
end;

end.
