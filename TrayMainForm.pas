unit TrayMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, System.DateUtils,
  Vcl.Menus, Vcl.AppEvnts, System.IOUtils, Vcl.Buttons, Data.DB,
  Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids, cxGraphics, cxButtons,
  cxLookAndFeels, cxLookAndFeelPainters, System.Generics.Collections
  , SubstManager
  , GestSub
  , ConfigManager
  , BuilderUtils
  , BuildConfigManager
  , SQLServerDetection
  , SoapTestForm
  , ConfigWizardForm, System.ImageList, Vcl.ImgList, cxImageList,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, cxControls, cxContainer, cxEdit,
  cxTextEdit
  ;

type
  TfrmTrayMain = class(TForm)
    pnlMain: TPanel;
    pnlLog: TPanel;
    memoLog: TRichEdit;
    lblLog: TLabel;
    pnlStatus: TPanel;
    lblStatus: TLabel;
    progressBar: TProgressBar;
    lblTime: TLabel;
    progressBarSub: TProgressBar;
    lblProgress: TLabel;
    lblSubProgress: TLabel;
    saveDialog: TSaveDialog;
    pnlConfig: TPanel;
    lblConfig: TLabel;
    cbConfiguration: TComboBox;
    chkVerbose: TCheckBox;
    chkCleanFirst: TCheckBox;
    chkShowCompilerOutput: TCheckBox;
    btnClearLog: TButton;
    btnMenu: TButton;
    TrayIcon: TTrayIcon;
    PopupMenu: TPopupMenu;
    mnuSeparator3: TMenuItem;
    mnuShowWindow: TMenuItem;
    mnuDatabase: TMenuItem;
    mnuSeparator4: TMenuItem;
    mnuVerbose: TMenuItem;
    mnuCleanFirst: TMenuItem;
    mnuShowOutput: TMenuItem;
    mnuSeparator5: TMenuItem;
    mnuClearLog: TMenuItem;
    mnuSaveLog: TMenuItem;
    mnuSeparator6: TMenuItem;
    mnuExit: TMenuItem;
    ApplicationEvents: TApplicationEvents;
    N1: TMenuItem;
    MapDrive: TMenuItem;
    Add1: TMenuItem;
    CDSPath: TClientDataSet;
    N2: TMenuItem;
    Label1: TLabel;
    edtDriveLetter: TEdit;
    lbDrive: TListBox;
    sbDel: TcxButton;
    ldrive: TLabel;
    chkDelphiOff: TCheckBox;
    mnuBOSServices: TMenuItem;
    pGestDrive: TPanel;
    btnSetting: TButton;
    cdsDummy: TClientDataSet;
    mnuActiveVersion: TMenuItem;
    N3: TMenuItem;
    mnuBOS: TMenuItem;
    mnuAPPBOSService: TMenuItem;
    mnuStandAlone1: TMenuItem;
    BuilderItem: TMenuItem;
    mnuUtility: TMenuItem;
    mnuOvwTools: TMenuItem;
    mnuXslConverter: TMenuItem;
    Lock1: TMenuItem;
    cxImageList: TcxImageList;
    SVNGetLockFromS1: TMenuItem;
    SVNUnLockS1: TMenuItem;
    btDBVersion: TcxButton;
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    btSession: TcxButton;
    Memo1: TMemo;
    Iniconfig1: TMenuItem;
    eSession: TEdit;
    APPBOSService1: TMenuItem;
    btXML: TcxButton;
    AutoConvert: TCheckBox;
    btSql: TcxButton;
    brChangePwd: TcxButton;
    gbEditor: TGroupBox;
    Case1: TMenuItem;
    lVersion: TLabel;
    cxButton1: TcxButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormWindowStateChange(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure ApplicationEventsMinimize(Sender: TObject);
    procedure brChangePwdClick(Sender: TObject);
    procedure mnuShowWindowClick(Sender: TObject);
    procedure mnuDebugClick(Sender: TObject);
    procedure mnuReleaseClick(Sender: TObject);
    procedure mnuVerboseClick(Sender: TObject);
    procedure mnuCleanFirstClick(Sender: TObject);
    procedure mnuShowOutputClick(Sender: TObject);
    procedure mnuClearLogClick(Sender: TObject);
    procedure mnuSaveLogClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure btnClearLogClick(Sender: TObject);
    procedure btnMenuClick(Sender: TObject);
    procedure GestSubClick(Sender: TObject);
    procedure sbDelClick(Sender: TObject);
    procedure DrawItemChecked(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure CDSPathAfterPost(DataSet: TDataSet);
    procedure mnuBOSClick(Sender: TObject);
    procedure btDBVersionClick(Sender: TObject);
    procedure cxButton2Click(Sender: TObject);
    procedure Iniconfig1Click(Sender: TObject);
    procedure btSessionClick(Sender: TObject);
    procedure mnuDatabaseClick(Sender: TObject);
    procedure btXMLClick(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
  private
    FStartTime: TDateTime;
    FLogFileName: string;
    FIsBuilding: Boolean;
    FMinimizedToTray: Boolean;
    FSubstManager: TSubstManager;
    FChecked: Integer;
    FDBFile: String;
    FFormGest: TFGestSubst;
    FConfig: TConfigManager;
    FConfigManager: TBuildConfigManager;
    FBuildButtons: TList<TMenuItem>;
    procedure WMDeviceChange(var Msg: TMessage); message WM_DEVICECHANGE;
    procedure ExecuteBuild(AConfig: TBuildConfiguration);
    procedure LogMessage(const Msg: string; MessageType: TLogMessageType = lmtInfo);
    procedure LogCompilerOutput(const Msg: string);
    procedure LogSVNOutput(const Msg: string);
    procedure SetBuildingState(Building: Boolean);
    procedure UpdateStatus(const Status: string);
    function ExecuteMSBuild(const ProjectPath: string; const Targets: string = 'Build'): Boolean;
    procedure InitializeLogging;
    function FormatElapsedTime(StartTime: TDateTime): string;
    function IsImportantCompilerMessage(const Msg: string): Boolean;
    procedure ShowTrayNotification(const Title, Msg: string; IconType: TBalloonFlags = bfInfo);
    procedure HideToTray;
    procedure ShowFromTray;
    procedure UpdateMenuStates;
    procedure TestLogColors;
    procedure mnuDriveClick(Sender: TObject);
    procedure mnuSvnClick(Sender: TObject);
    procedure BuildButtonClick(Sender: TObject);
    function GetDriveLetterFromMask(UnitMask: DWORD): string;
    function GetDelphiProcessID: DWORD;
    procedure SetActive(const ATag: Integer);
    procedure ClearBuildButtons;
    Function Setversion(Const ACaption, AExeName: String): String;
    procedure CreateBuildButton(Config: TBuildConfiguration; Index: Integer);
    procedure SetDriveList;

  public
    FRecConfig: TRecConfig;
    Procedure initializeDrive(ACreate: Boolean = True);
    procedure LoadSettings;
  end;

var
  frmTrayMain: TfrmTrayMain;

implementation

{$R *.dfm}

uses
  Winapi.ShellAPI, System.Win.Registry, TlHelp32, System.UITypes, System.Types,
  System.IniFiles, IniConfig, XmlFormConverter, ChangePwd;

procedure TfrmTrayMain.LoadSettings;
Var
    ledtBOS    : String;
    ledtAPPBOS : String;
    ledtAlone  : String;
    lOvwTools  : String;
    lXlsConv   : String;
    lCaseStudio: String;
    lSqlServer : String;
begin
  chkVerbose.Checked := FConfig.ReadBool('Settings', 'chkVerbose', False);
  chkCleanFirst.Checked := FConfig.ReadBool('Settings', 'chkCleanFirst', False);
  chkShowCompilerOutput.Checked := FConfig.ReadBool('Settings', 'chkShowCompilerOutput', False);
  chkDelphiOff.Checked := FConfig.ReadBool('Settings', 'chkDelphiOff', False);
  edtDriveLetter.Text := FConfig.ReadString('Settings', 'edtDriveLetter', 'S');

  ledtBOS    := FConfig.ReadString('Settings', 'edtBOS', 's:\work\Bin\Overview.exe');
  ledtAPPBOS := FConfig.ReadString('Settings', 'edtAPPBOS', 's:\work\isapi\AppBosServices.exe');
  ledtAlone  := FConfig.ReadString('Settings', 'edtAlone', 's:\work\Bin\OverviewStandaloneSrv.exe');
  lOvwTools  := FConfig.ReadString('Settings', 'edtOvwTools', 's:\work\R&D\OvwTools.exe');
  lXlsConv   := FConfig.ReadString('Settings', 'edtXlsConv', 's:\work\R&D\XslConverter.exe');
  lCaseStudio:= FConfig.ReadString('Settings', 'edtCaseStudio', 'C:\Program Files (x86)\RKSoft\CASEStudio2\Bin\CASEStud.exe');
  lSqlServer := FConfig.ReadString('Settings', 'edtSQLServer', 'LocalHost' );

  FRecConfig := TRecConfig.GetInstance;
  FRecConfig.SetValues(ledtBOS, ledtAPPBOS, ledtAlone, lOvwTools, lXlsConv, lCaseStudio, lSqlServer);

end;

procedure TfrmTrayMain.ClearBuildButtons;
begin
  for var Button in FBuildButtons do
    Button.Free;
  FBuildButtons.Clear;
end;

procedure TfrmTrayMain.CreateBuildButton(Config: TBuildConfiguration; Index: Integer);
var
  lItem: TMenuItem;
  lImg: Integer;
  lIcon: String;
begin
  lItem := TMenuItem.Create(BuilderItem);

  lItem.Caption := Config.Name;

  lItem.Tag := Index;
  lImg := 3;
  lIcon := UpperCase(Config.Icon);
  if lIcon = 'BUILD' then
    lImg := 3
  else if lIcon = 'FAST' then
    lImg := 2
  else if lIcon = 'PACKAGE' then
    lImg := 1
  else if lIcon = 'SERVICES' then
    lImg := 6
  else if lIcon = 'MODULE' then
    lImg := 7;
  lItem.ImageIndex := lImg;
  lItem.OnClick := BuildButtonClick;
  lItem.OnDrawItem := DrawItemChecked;
  BuilderItem.Add(lItem);

  FBuildButtons.Add(lItem);
end;

procedure TfrmTrayMain.btDBVersionClick(Sender: TObject);
var
  Connection: TFDConnection;
  QueryDB: TFDQuery;
  lServerVer, lServer, lSystem: String;
begin
  Connection := TFDConnection.Create(Self);
  QueryDB := TFDQuery.Create(Self);
  try
    Connection.Params.Add('Server=' + FRecConfig.SqlServer);
    Connection.Params.Add('OSAuthent=Yes');
    Connection.Params.Add('Database=master');
    Connection.Params.Add('DriverID=MSSQL');
    Connection.Connected := True;
    QueryDB.Connection := Connection;
    QueryDB.SQL.Add(FDQuery1.SQL.Text);
    QueryDB.Open;
    lServerVer := '║  DataBase: %-17s  -  Version: %-17s  ║';
    lServer    := '║ DataBase version server: %-35s ║';
    lSystem    := '║   %-9s║ %-28s   ║ %-13s  ║';
    LogMessage('╔══════════════════════════════════════════════════════════════╗', lmtSvnConflict);
    LogMessage(Format(lServer, [FRecConfig.SqlServer]), lmtSvnConflict);
    LogMessage('╠════════════╦════════════════════════════════╦════════════════╣', lmtSvnConflict);
    LogMessage('║ System ID  ║       DataBase                 ║    Version     ║', lmtSvnConflict);
    LogMessage('╠════════════╬════════════════════════════════╬════════════════╣', lmtSvnConflict);
    while not QueryDB.Eof do
    begin
      LogMessage(Format(lSystem, [QueryDB.Fields[0].AsString, QueryDB.Fields[1].AsString, QueryDB.Fields[2].AsString]));
      QueryDB.Next;
    end;
    LogMessage('╚════════════╩════════════════ END ═══════════╩════════════════╝');
  finally
    QueryDB.Close;
    Connection.Connected := False;
    FreeAndNil(QueryDB);
    FreeAndNil(Connection);
  end;

end;

procedure TfrmTrayMain.cxButton1Click(Sender: TObject);
Var lFormChange:  TFormSoapTest;
begin
  lFormChange := TFormSoapTest.Create(Nil);
  try
  //  lFormChange.SqlServer := FRecConfig.SqlServer;
    lFormChange.ShowModal;
  finally
    lFormChange.Free;
  end;
end;

procedure TfrmTrayMain.cxButton2Click(Sender: TObject);
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

procedure TfrmTrayMain.FormCreate(Sender: TObject);
  procedure CopiaClientData(Source, Dest: TClientDataSet);
  var
    i: Integer;
    SourceField, DestField: TField;
  begin
    Dest.DisableControls;
    try
      Source.First;
      while not Source.Eof do
      begin
        Dest.Append;
        for i := 0 to Source.FieldCount - 1 do
        begin
          SourceField := Source.Fields[i];
          DestField := Dest.FindField(SourceField.FieldName);

          if Assigned(DestField) and (DestField.DataType = SourceField.DataType) and
            (Uppercase(SourceField.FieldName) <> 'TAG') then
          begin
            DestField.Value := SourceField.Value;
          end;
        end;

        Dest.Post;
        Source.Next;
      end;
    finally
      Dest.EnableControls;
    end;
  end;
begin
  FConfig := TConfigManager.Create;
  FConfigManager := TBuildConfigManager.Create;
  FBuildButtons := TList<TMenuItem>.Create;
  FConfigManager.LoadConfigurations;
  ClearBuildButtons;

  var lConfigCount := FConfigManager.GetConfigurationCount;

  for var i := 0 to lConfigCount - 1 do
  begin
    var lConfig := FConfigManager.GetConfiguration(i);
    if lConfig.Enabled then
      CreateBuildButton(lConfig, i + 100);
  end;

  Caption := 'Choice Builder - Build Manager v3.1';
  TrayIcon.Icon := Application.Icon;
  TrayIcon.Hint := 'Choice Builder - Right Click for menu';
  TrayIcon.PopupMenu := PopupMenu;
  TrayIcon.Visible := True;

  cbConfiguration.Items.AddStrings(['Debug', 'Release']);
  cbConfiguration.ItemIndex := 0; // Default Debug

  FDBFile := GetDocumentsPath + '\ChoiceBuilderPathS.xml';
  if not FileExists(FDBFile) then
  begin
   CDSPath.CreateDataSet;
   cdsDummy.LoadFromFile(GetDocumentsPath + '\PathS.xml');
   cdsDummy.open;
   CopiaClientData(cdsdummy, CDSPath);
   CDSPath.SaveToFile(FDBFile, dfXMLUTF8);
   cdsDummy.Close;
  end;

  CDSPath.FileName := FDBFile; // GetDocumentsPath + '\PathS.xml';

  InitializeLogging;

  FSubstManager := TSubstManager.Create;

  SetBuildingState(False);
  UpdateStatus('Ready');
  UpdateMenuStates;
//                          lServerVer := '║  DataBase: %-17s  -  Version: %-17s  ║';
  FMinimizedToTray := False;
  LogMessage('╔══════════════════════════════════════════════════════════════╗');
  LogMessage('║       Choice Builder System Tray Application Started         ║');
  LogMessage('╠══════════════════════════════════════════════════════════════╣');
  LogMessage(Format('║ Data: %-53s  ║', [DateTimeToStr(Now)]));
  LogMessage(Format('║ User: %-53s  ║', [GetEnvironmentVariable('USERNAME')]));
  LogMessage(Format('║ Computer: %-49s  ║', [GetEnvironmentVariable('COMPUTERNAME')]));
  LogMessage(Format('║ Directory: %-48s  ║', [GetCurrentDir]));
  LoadSettings;
  LogMessage(Format('║ Load settings %-46s ║', ['']));
  LogMessage(Format('║ Loaded %d configuration of build %-27s ║', [lConfigCount, '']));
  FConfig.ReloadFromFile;
  //LoadDB;
  TestLogColors;
 // LogMessage('╚══════════════════════════════════════════════════════════════╝');
  initializeDrive;

  if lbdrive.Items.Count >0 then
    mnuBOSServices.Caption := 'BOS V ' + Setversion('BOS Version : ', FRecConfig.PathBOS);

  lVersion.caption := 'Application Version ' + SetVersion('Application Version : ', ParamStr(0));

end;


Function TfrmTrayMain.Setversion(Const ACaption, AExeName: String): String;
Var BOSVersion: TFileVersionInfo;
begin
  BOSVersion := GetFileVersion(AExeName);
  Result := BOSVersion.Major.ToString + '.' + BOSVersion.Minor.ToString +
            '.' + BOSVersion.Release.ToString + '.' + BOSVersion.Build.ToString;
  LogMessage(ACaption + Result);
end;

procedure TfrmTrayMain.FormDestroy(Sender: TObject);
begin
  LogMessage('Application terminated at: ' + TimeToStr(Now));
  LogMessage('========================================');
  TrayIcon.Visible := False;
  FreeAndNil(FFormGest);
  FreeAndNil(FSubstManager);
  FreeAndNil(FConfig);
  FRecConfig.ReleaseInstance;
  ClearBuildButtons;
  FBuildButtons.Free;
  while FConfigManager.Configurations.Count > 0 do
    FConfigManager.Configurations.Delete(0);
  FConfigManager.Free;
end;

procedure TfrmTrayMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Invece di chiudere, minimizza nella tray
  if not FMinimizedToTray then
  begin
    Action := caNone;
    HideToTray;
//    ShowTrayNotification('Choice Builder', 'Application minimized to system tray');
  end;
end;

procedure TfrmTrayMain.FormWindowStateChange(Sender: TObject);
begin
  if WindowState = wsMinimized then
  begin
    HideToTray;
  end;
end;

procedure TfrmTrayMain.TrayIconDblClick(Sender: TObject);
begin
  ShowFromTray;
end;

procedure TfrmTrayMain.DrawItemChecked(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; Selected: Boolean);
var
  MenuItem: TMenuItem;
  IconRect: TRect;
  TextRect: TRect;
//  Icon: TIcon;
  sText: String;
begin
  MenuItem := TMenuItem(Sender);
  sText := StringReplace(MenuItem.Caption, '&', '', [rfReplaceAll, rfIgnoreCase]);
  if MenuItem.tag = 101 then
    sText := sText + ' (' + MenuItem.Hint + ')';

  // Pulisci il background
  if Selected then
    ACanvas.Brush.Color := clHighlight
  else
    ACanvas.Brush.Color := clMenu;
  ACanvas.FillRect(ARect);

  // Calcola le aree per icona e testo
  IconRect := Rect(ARect.Left + 2, ARect.Top + 2, ARect.Left + 18, ARect.Top + 18);
  TextRect := Rect(ARect.Left + 22, ARect.Top, ARect.Right, ARect.Bottom);

  if Assigned(MenuItem.Bitmap) and not MenuItem.Bitmap.Empty then
    ACanvas.Draw(IconRect.Left, IconRect.Top, MenuItem.Bitmap)
  else if MenuItem.ImageIndex >= 0 then
  begin
    // Se usi un ImageList
    if Assigned(cxImageList) then
      cxImageList.Draw(ACanvas, IconRect.Left, IconRect.Top, MenuItem.ImageIndex);
  end;

  // Disegna il testo
  ACanvas.Brush.Style := bsClear;
  if MenuItem.Checked then
    ACanvas.Brush.Color := RGB(255, 64, 64)
  else
    ACanvas.Brush.Color := clMenu;

  if Selected then
    ACanvas.Font.Color := clHighlight
  else
  begin
    if MenuItem.tag > 99 then
    begin
      var Config := FConfigManager.GetConfiguration(MenuItem.tag - 100);
      if Config.Category = 'Services' then
        ACanvas.Font.Color := clGreen
      else if Config.Category = 'Components' then
        ACanvas.Font.Color := clPurple
      else
        ACanvas.Font.Color := clBlack;
    end
    else
      ACanvas.Font.Color := clMenuText;
  end;
  DrawText(ACanvas.Handle, PChar(sText), -1, TextRect, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
end;

procedure TfrmTrayMain.ApplicationEventsMinimize(Sender: TObject);
begin
  HideToTray;
end;

procedure TfrmTrayMain.brChangePwdClick(Sender: TObject);
Var lFormChange:  TFChangePwd;
begin
  lFormChange := TFChangePwd.Create(Nil);
  try
    lFormChange.SqlServer := FRecConfig.SqlServer;
    lFormChange.ShowModal;
  finally
    lFormChange.Free;
  end;
end;

procedure TfrmTrayMain.HideToTray;
begin
  Hide;
  ShowWindow(Application.Handle, SW_HIDE);
  FMinimizedToTray := True;
end;

procedure TfrmTrayMain.Iniconfig1Click(Sender: TObject);
Var lIniAppConfig: TConfigManager;
    lFileIni: String;
begin
  With TFIniConfig.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

Procedure TfrmTrayMain.SetDriveList;
Var   lDriverList: TStringList;
begin
  lDriverList := TSTringList.Create;
  try
    lbdrive.Items.clear;
    FSubstManager.GetSubstDrivesAsStrings(lDriverList);
    for var I := 0 to lDriverList.Count - 1 do
      lbdrive.Items.Add(lDriverList[i]);
  finally
    FreeAndNil(lDriverList);
  end;
end;

procedure TfrmTrayMain.initializeDrive(ACreate: Boolean = True);
var
  MenuItem, SvnItem, PathItem: TMenuItem;
  lDrive, lPath: String;

begin
  if not CDSPath.Active then
    CDSPath.Open;

  //S: -> C:\Sviluppo\BOS\7.04.BETA
  SetDriveList;

  for var x := 0 to lbdrive.Items.count - 1 do
  begin
    lDrive := lbdrive.Items[x];
    if POS('S: =>', lDrive) > 0 then
    begin
      lPath := Trim(Copy(lDrive, 7, length(lDrive)));
      FChecked := -1;
      if CDSPath.Locate('Path', lPath, [loCaseInsensitive, loPartialKey]) then
      begin
        FChecked := CDSPath.FieldByName('Tag').AsInteger;
      end;
    end;

    LogMessage('>>> Drive mapped: ' + lbdrive.Items[x], lmtDrive);
    ShowTrayNotification('Choice Builder', '>>> Drive mapped: ' + lbdrive.Items[x]);
  end;

  while not (MapDrive.Count = 2) do
    MapDrive.Delete(2);

  Var lOldDrive := '';

  if (lbdrive.Items.count = 0) and ACreate then
    lOldDrive := FConfig.ReadString('Settings', 'MapDrive', '');

  CDSPath.First;
  while not CDSPath.Eof do
  begin
    MenuItem := TMenuItem.Create(MapDrive);
    MenuItem.Caption := CDSPath.FieldByName('Description').AsString;
    MenuItem.Tag := CDSPath.FieldByName('Tag').AsInteger;
    MenuItem.Checked := FChecked = CDSPath.FieldByName('Tag').AsInteger;
    MenuItem.ImageIndex := 5;
    if (lOldDrive <> '') and (lOldDrive = CDSPath.FieldByName('Description').AsString) then
    begin
      MenuItem.Checked := True;
      FSubstManager.CreaDriveConSubst('S', CDSPath.FieldByName('Path').AsString);
    end;

    if MenuItem.Checked then
      mnuActiveVersion.Caption := MenuItem.Caption;
    MenuItem.OnDrawItem := DrawItemChecked;
    MapDrive.Add(MenuItem);

    SvnItem := TMenuItem.Create(MenuItem);
    SvnItem.Caption := 'SVN Update';
    SvnItem.OnClick := mnuSvnClick;
    SvnItem.Tag := CDSPath.FieldByName('Tag').AsInteger;
//    SvnItem.ImageIndex := 5;
    MenuItem.Add(SvnItem);
    PathItem := TMenuItem.Create(MenuItem);
    PathItem.Caption := 'Assign drive S:';
    PathItem.Tag := CDSPath.FieldByName('Tag').AsInteger;
    PathItem.OnClick := mnuDriveClick;
    MenuItem.Add(PathItem);
    CDSPath.Next;
  end;
  if lbdrive.Items.Count =0 then
    SetDriveList;


end;

procedure TfrmTrayMain.ShowFromTray;
begin
  Show;
  ShowWindow(Application.Handle, SW_SHOW);
  WindowState := wsNormal;
  Application.BringToFront;
  FMinimizedToTray := False;
end;

procedure TfrmTrayMain.ShowTrayNotification(const Title, Msg: string; IconType: TBalloonFlags = bfInfo);
begin
  TrayIcon.BalloonTitle := Title;
  TrayIcon.BalloonHint := Msg;
  TrayIcon.BalloonFlags := IconType;
  TrayIcon.ShowBalloonHint;
end;

procedure TfrmTrayMain.UpdateMenuStates;
begin
  mnuVerbose.Checked := chkVerbose.Checked;
  mnuCleanFirst.Checked := chkCleanFirst.Checked;
  mnuShowOutput.Checked := chkShowCompilerOutput.Checked;

end;

procedure TfrmTrayMain.mnuSvnClick(Sender: TObject);
Var
  lResponse: Integer;
  CommandLine: string;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  ExitCode: DWORD;
  PipeRead, PipeWrite: THandle;
  SecurityAttr: TSecurityAttributes;
  Buffer: array[0..4095] of AnsiChar;
  BytesRead: DWORD;
  OutputText: string;
begin
  lResponse := mrYes;
  if GetDelphiProcessID > 0 then
    lResponse := MessageDlg('Warning: Delphi is currently running.' + #13#10 +
                          'Continue anyway?',
                          mtWarning,
                          [mbYes, mbNo],
                          0);

  if (lResponse = mrYes) then
  begin
    if CDSPath.Locate('TAG', TMenuItem(Sender).tag, [loCaseInsensitive, loPartialKey]) then
    begin
      CommandLine := Format('cmd.exe /c svn update %s',
                           [CDSPath.FieldByName('Path').AsString]);

      LogMessage('Executing command: ' + CommandLine);

      ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
      StartupInfo.cb := SizeOf(StartupInfo);
      StartupInfo.wShowWindow := SW_HIDE;
      SecurityAttr.nLength := SizeOf(SecurityAttr);
      SecurityAttr.lpSecurityDescriptor := nil;
      SecurityAttr.bInheritHandle := True;

      if not CreatePipe(PipeRead, PipeWrite, @SecurityAttr, 0) then
      begin
        LogMessage('ERROR: Unable to create pipe for output', lmtError);
        Exit;
      end;

      try
        StartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
        StartupInfo.hStdOutput := PipeWrite;
        StartupInfo.hStdError := PipeWrite;

        if CreateProcess(nil, PChar(CommandLine), nil, nil, True, 0, nil, nil, StartupInfo, ProcessInfo) then
        begin
          try
            CloseHandle(PipeWrite);
            PipeWrite := INVALID_HANDLE_VALUE;

            while WaitForSingleObject(ProcessInfo.hProcess, 50) = WAIT_TIMEOUT do
            begin
              if PeekNamedPipe(PipeRead, nil, 0, nil, @BytesRead, nil) and (BytesRead > 0) then
              begin
                if ReadFile(PipeRead, Buffer, SizeOf(Buffer) - 1, BytesRead, nil) then
                begin
                  Buffer[BytesRead] := #0;
                  OutputText := string(AnsiString(Buffer));

                  while Pos(#13#10, OutputText) > 0 do
                  begin
                    LogSVNOutput(Copy(OutputText, 1, Pos(#13#10, OutputText) - 1));
                    Delete(OutputText, 1, Pos(#13#10, OutputText) + 1);
                  end;
                  if OutputText <> '' then
                    LogSVNOutput(OutputText);
                end;
              end;

              UpdateStatus('Svn... ' + FormatElapsedTime(FStartTime));
              Application.ProcessMessages;
            end;

            while PeekNamedPipe(PipeRead, nil, 0, nil, @BytesRead, nil) and (BytesRead > 0) do
            begin
              if ReadFile(PipeRead, Buffer, SizeOf(Buffer) - 1, BytesRead, nil) then
              begin
                Buffer[BytesRead] := #0;
                OutputText := string(AnsiString(Buffer));

                while Pos(#13#10, OutputText) > 0 do
                begin
                  LogSVNOutput(Copy(OutputText, 1, Pos(#13#10, OutputText) - 1));
                  Delete(OutputText, 1, Pos(#13#10, OutputText) + 1);
                end;
                if OutputText <> '' then
                  LogSVNOutput(OutputText);
              end;
            end;

            GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
            //Result := ExitCode = 0;

            LogMessage('SVN Update complete exit code: ' + IntToStr(ExitCode));

          finally
            CloseHandle(ProcessInfo.hProcess);
            CloseHandle(ProcessInfo.hThread);
          end;
        end
        else
          LogMessage('ERRORE: Unable to start SVN', lmtError);

      finally
        if PipeRead <> INVALID_HANDLE_VALUE then
          CloseHandle(PipeRead);
        if PipeWrite <> INVALID_HANDLE_VALUE then
          CloseHandle(PipeWrite);
      end;
    end;
  end;
end;

procedure TfrmTrayMain.mnuBOSClick(Sender: TObject);
Var lExec: String;

begin
  case TMenuItem(Sender).tag of
    1: lExec := FRecConfig.PathBOS;
    2: lExec := FRecConfig.PathAPPBOS;
    3: lExec := FRecConfig.PathAlone;
    4: lExec := FRecConfig.OvwTools;
    5: lExec := FRecConfig.XlsConv;
    6: lExec := FRecConfig.CaseStudio;
  end;
  RunAndWait(lExec);
end;

procedure TfrmTrayMain.mnuShowWindowClick(Sender: TObject);
begin
  ShowFromTray;
end;

procedure TfrmTrayMain.mnuDatabaseClick(Sender: TObject);
Var MenuItem: TMenuItem;
    Connection: TFDConnection;
    QueryDB: TFDQuery;
    lServerVer, lServer, lSystem: String;
begin
  if mnuDatabase.Count = 0 then
  begin
    Connection := TFDConnection.Create(Self);
    QueryDB := TFDQuery.Create(Self);
    try
      Connection.Params.Add('Server=' + FRecConfig.SqlServer);
      Connection.Params.Add('OSAuthent=Yes');
      Connection.Params.Add('Database=master');
      Connection.Params.Add('DriverID=MSSQL');
      Connection.Connected := True;
      QueryDB.Connection := Connection;
      QueryDB.SQL.Add(FDQuery1.SQL.Text);
      QueryDB.Open;

      while not QueryDB.Eof do
      begin
        MenuItem := TMenuItem.Create(mnuDatabase);
        MenuItem.Caption := QueryDB.Fields[1].AsString;
        MenuItem.Hint   := QueryDB.Fields[2].AsString;
        MenuItem.Tag := 101;
        MenuItem.Checked := False;
        MenuItem.ImageIndex := 5;
        MenuItem.OnDrawItem := DrawItemChecked;
        mnuDatabase.Add(MenuItem);
        QueryDB.Next;
      end;

    finally
      QueryDB.Close;
      Connection.Connected := False;
      FreeAndNil(QueryDB);
      FreeAndNil(Connection);
    end;
  //nic


  end;

end;

procedure TfrmTrayMain.mnuDebugClick(Sender: TObject);
begin
  cbConfiguration.ItemIndex := 0;
  UpdateMenuStates;
end;

function TfrmTrayMain.GetDelphiProcessID: DWORD;
var
  ProcessSnapshot: THandle;
  ProcessEntry: TProcessEntry32;
  ProcessName: string;
begin
  Result := 0;
  ProcessSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);

  if ProcessSnapshot <> INVALID_HANDLE_VALUE then
  try
    ProcessEntry.dwSize := SizeOf(ProcessEntry);

    if Process32First(ProcessSnapshot, ProcessEntry) then
    repeat
      ProcessName := LowerCase(ProcessEntry.szExeFile);

      if (ProcessName = 'bds.exe') or (ProcessName = 'delphi32.exe') then
      begin
        Result := ProcessEntry.th32ProcessID;
        Break;
      end;
    until not Process32Next(ProcessSnapshot, ProcessEntry);

  finally
    CloseHandle(ProcessSnapshot);
  end;
end;


procedure TfrmTrayMain.mnuDriveClick(Sender: TObject);
Var lLetter: Char;
    lResponse: Integer;
    lDelphi, lDelphiOpen: Boolean;
begin
  lResponse := mrYes;
  lDelphiOpen := False;
  lDelphi := GetDelphiProcessID > 0;
  if lDelphi then
    lResponse := MessageDlg('Warning: Delphi is currently running.' + #13#10 +
                          'Continue anyway?',
                          mtWarning,
                          [mbYes, mbNo],
                          0);

  if (lResponse = mrYes) then
  begin
    if lDelphi then
    begin
      LogMessage('=== Delphi running will be killed  ===');
      KillProcessByName('BDS.exe');
      lDelphiOpen := chkDelphiOff.Checked;
    end;

    lLetter := edtDriveLetter.Text[1];
    if CDSPath.Locate('TAG', TMenuItem(Sender).tag, [loCaseInsensitive, loPartialKey]) then
    begin
      FSubstManager.RimuoviDriveConSubst(lLetter);
      FSubstManager.CreaDriveConSubst(lLetter, CDSPath.FieldByName('Path').AsString);
      for Var x := 0 to MapDrive.Count -1 do
        MapDrive.Items[x].Checked := False;

      FChecked := TMenuItem(Sender).tag;
      TMenuItem(Sender).Parent.Checked := True;
      mnuActiveVersion.Caption := TMenuItem(Sender).Parent.Caption;
      SetActive(TMenuItem(Sender).tag);
      var lVersionDrive :=  StringReplace(mnuActiveVersion.Caption, '&', '', [rfReplaceAll, rfIgnoreCase]);
      FConfig.WriteString('Settings', 'MapDrive', lVersionDrive);
      FConfig.SaveToFile;
      ShowTrayNotification('Choice Builder', ' Drive mapped: ' + lLetter + ':  => ' + CDSPath.FieldByName('Path').AsString);
    end;
    SetDriveList;
    Setversion('', FRecConfig.PathBOS);
    if lDelphiOpen and lDelphi then
    begin
      LogMessage('=== Delphi was killed ... now reborn  ===');
      RunAndWait('BDS.exe');
    end;
  end;

end;

procedure TfrmTrayMain.SetActive(Const ATag: Integer);
var
  lBookmark: TBookmark;
begin
  lBookmark := CDSPath.GetBookmark;
  try
    CDSPath.DisableControls;
    CDSPath.First;
    while not CDSPath.eof do
    begin
      CDSPath.Edit;
      if CDSPath.FieldByName('Tag').AsInteger = ATag then
        CDSPath.FieldByName('Active').AsInteger := 1
      else
        CDSPath.FieldByName('Active').AsInteger := 0;
      CDSPath.Post;
      CDSPath.next;
    end;
    CDSPath.GotoBookmark(lBookmark);
  finally
    CDSPath.EnableControls;
  end;
end;

procedure TfrmTrayMain.mnuReleaseClick(Sender: TObject);
begin
  cbConfiguration.ItemIndex := 1;
  UpdateMenuStates;
end;

procedure TfrmTrayMain.mnuVerboseClick(Sender: TObject);
begin
  chkVerbose.Checked := not chkVerbose.Checked;
  UpdateMenuStates;
end;

procedure TfrmTrayMain.sbDelClick(Sender: TObject);
var lDrive: String;
begin
  if lbDrive.ItemIndex > -1 then
  begin
    lDrive := lbDrive.Items[lbDrive.ItemIndex][1];
    FSubstManager.RimuoviDriveConSubst(lDrive);
    SetDriveList;
    initializeDrive(False);
  end;
end;

procedure TfrmTrayMain.mnuCleanFirstClick(Sender: TObject);
begin
  chkCleanFirst.Checked := not chkCleanFirst.Checked;
  UpdateMenuStates;
end;

procedure TfrmTrayMain.mnuShowOutputClick(Sender: TObject);
begin
  chkShowCompilerOutput.Checked := not chkShowCompilerOutput.Checked;
  UpdateMenuStates;
end;

procedure TfrmTrayMain.mnuClearLogClick(Sender: TObject);
begin
  memoLog.Clear;
  LogMessage('Log delete by user');
end;

procedure TfrmTrayMain.mnuSaveLogClick(Sender: TObject);
begin
  saveDialog.FileName := 'build_log_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.txt';
  if saveDialog.Execute then
  begin
    memoLog.Lines.SaveToFile(saveDialog.FileName);
    ShowTrayNotification('Choice Builder', 'Log in: ' + ExtractFileName(saveDialog.FileName));
  end;
end;

procedure TfrmTrayMain.mnuExitClick(Sender: TObject);
begin
  FMinimizedToTray := True;
  Close;
  Application.Terminate;
end;

procedure TfrmTrayMain.btnClearLogClick(Sender: TObject);
begin
  mnuClearLogClick(Sender);
end;

procedure TfrmTrayMain.btnMenuClick(Sender: TObject);
var
  P: TPoint;
begin
  P := btnMenu.ClientToScreen(Point(0, btnMenu.Height));
  // Mostra il popup menu sotto il button
  PopupMenu.Popup(P.X, P.Y);
end;

procedure TfrmTrayMain.btSessionClick(Sender: TObject);
begin
  LogMessage('╔═════════════════════════Session ID═══════════════════════════╗', lmtSvnConflict);
  LogMessage(Format('║ %s %s ║', [eSession.Text, ApplySHA1Hash(eSession.Text)]));
  LogMessage('╚═════════════════════════════ END ════════════════════════════╝', lmtSvnConflict);
end;

procedure TfrmTrayMain.BuildButtonClick(Sender: TObject);
var
  lItem: TMenuItem;
  lConfig: TBuildConfiguration;
begin
  lItem := (Sender as TMenuItem);
  lConfig := FConfigManager.GetConfiguration(lItem.Tag - 100);
  if Assigned(lConfig) then
  begin
    ExecuteBuild(lConfig);
    Setversion('', FRecConfig.PathBOS);
  end;
end;

procedure TfrmTrayMain.btXMLClick(Sender: TObject);
Var lFormConv:  TFConvert;
begin
  lFormConv := TFConvert.Create(Nil);
  try
    if (Sender as TcxButton).Tag = 1 then
    begin
      lFormConv.Caption := 'XML pretty converter';
      lFormConv.XmlMemo.SyntaxStyles := lFormConv.AdvXMLMemoStyler
    end
    else
    begin
      lFormConv.Caption := 'SQL pretty converter';
      lFormConv.XmlMemo.SyntaxStyles := lFormConv.AdvSQLMemoStyler;
    end;
    lFormConv.AutoConvert := AutoConvert.Checked;
    lFormConv.ShowModal;
  finally
    lFormConv.Free;
  end;

end;

procedure TfrmTrayMain.CDSPathAfterPost(DataSet: TDataSet);
begin
  CDSPath.MergeChangeLog;
  CDSPath.SaveToFile(FDBFile, dfXMLUTF8);
end;

procedure TfrmTrayMain.InitializeLogging;
var
  LogDir: string;
begin
  LogDir := TPath.Combine(ExtractFilePath(Application.ExeName), 'logs');
  if not TDirectory.Exists(LogDir) then
    TDirectory.CreateDirectory(LogDir);

  FLogFileName := TPath.Combine(LogDir,
    Format('build_%s.log', [FormatDateTime('yyyymmdd_hhnnss', Now)]));
end;

procedure TfrmTrayMain.LogMessage(const Msg: string; MessageType: TLogMessageType = lmtInfo);
var
  lLogEntry: string;
  lLogFile: TextFile;
  lTextColor: TColor;
  lStartPos: Integer;
  lLineIndex: Integer;
  lLen: Integer;
begin
  lLogEntry := Format('%s - %s', [TimeToStr(Now), Msg]);
  lLen := Pos('-', lLogEntry);

  case MessageType of
    lmtInfo:         lTextColor := clLime;
    lmtWarning:      lTextColor := clMaroon;
    lmtError:        lTextColor := clRed;
    lmtSuccess:      lTextColor := clGreen;
    lmtDrive:        lTextColor := clWhite;
    lmtSvnAdded:     lTextColor := clFuchsia;
    lmtSvnDeleted:   lTextColor := clWebCoral;
    lmtSvnUpdated:   lTextColor := clLime;
    lmtSvnConflict:  lTextColor := clred;
    lmtSvnMerged:    lTextColor := clYellow;
    lmtSvnExisted:   lTextColor := clWhite;
    lmtSvnReplaced:  lTextColor := clMaroon;
  else
    lTextColor := clWhite;
  end;

  lLineIndex := memoLog.Lines.Add(lLogEntry);
  lStartPos := memoLog.Perform(EM_LINEINDEX, lLineIndex, 0);

  memoLog.SelStart := lStartPos;
  memoLog.SelLength := 12;
  memoLog.SelAttributes.Color := clLime;

  memoLog.SelStart := lStartPos + lLen;
  memoLog.SelLength := Length(lLogEntry) - lLen;
  memoLog.SelAttributes.Color := lTextColor;

  memoLog.SelStart := Length(memoLog.Text) - lLen;
  memoLog.SelLength := 0;
  memoLog.Perform(WM_VSCROLL, SB_BOTTOM, 0);

  try
    AssignFile(lLogFile, FLogFileName);
    if FileExists(FLogFileName) then
      Append(lLogFile)
    else
      Rewrite(lLogFile);
    Writeln(lLogFile, lLogEntry);
    CloseFile(lLogFile);
  except
    // todo
  end;

  Application.ProcessMessages;
end;

procedure TfrmTrayMain.LogSVNOutput(const Msg: string);
var
  CleanMsg: string;
begin
{
    A  Added
    D  Deleted
    U  Updated
    C  Conflict
    G  Merged
    E  Existed
    R  Replaced
}
  CleanMsg := Trim(Msg);
  if (Pos('A   ', UpperCase(CleanMsg)) > 0)  then
    LogMessage('   SVN: ' + CleanMsg, lmtSvnAdded)
  else if (Pos('D   ', UpperCase(CleanMsg)) > 0) then
    LogMessage('   SVN: ' + CleanMsg, lmtSvnDeleted)
  else if (Pos('U   ', UpperCase(CleanMsg)) > 0) then
    LogMessage('   SVN: ' + CleanMsg, lmtSvnUpdated)
  else if (Pos('C   ', UpperCase(CleanMsg)) > 0) then
    LogMessage('   SVN: ' + CleanMsg, lmtSvnConflict)
  else if (Pos('G   ', UpperCase(CleanMsg)) > 0) then
    LogMessage('   SVN: ' + CleanMsg, lmtSvnMerged)
  else if (Pos('E   ', UpperCase(CleanMsg)) > 0) then
    LogMessage('   SVN: ' + CleanMsg, lmtSvnExisted)
  else if (Pos('R   ', UpperCase(CleanMsg)) > 0) then
    LogMessage('   SVN: ' + CleanMsg, lmtSvnReplaced)
  else
    LogMessage('>>> SVN: ' + CleanMsg, lmtInfo);
end;

procedure TfrmTrayMain.LogCompilerOutput(const Msg: string);
var
  CleanMsg: string;
begin
  CleanMsg := Trim(Msg);

  if (CleanMsg = '') or
     (Pos('Microsoft (R)', CleanMsg) > 0) or
     (Pos('Copyright (C)', CleanMsg) > 0) or
     (Pos('Build started', CleanMsg) > 0) or
     (Pos('Build succeeded', CleanMsg) > 0) or
     (Pos('Build FAILED', CleanMsg) > 0) then
    Exit;

  if (Pos('compiling', LowerCase(CleanMsg)) > 0) or
     (Pos('linking', LowerCase(CleanMsg)) > 0) then
  begin
    if progressBarSub.Visible then
      progressBarSub.StepIt;
  end;

  // Evidenzia messaggi importanti
  if IsImportantCompilerMessage(CleanMsg) then
  begin
    // Determina il tipo di messaggio in base al contenuto
    if (Pos('error', LowerCase(CleanMsg)) > 0) or (Pos('fatal', LowerCase(CleanMsg)) > 0) or (Pos('failed', LowerCase(CleanMsg)) > 0) then
      LogMessage('>>> COMPILER: ' + CleanMsg, lmtError)
    else if (Pos('warning', LowerCase(CleanMsg)) > 0) then
      LogMessage('>>> COMPILER: ' + CleanMsg, lmtWarning)
    else
      LogMessage('>>> COMPILER: ' + CleanMsg, lmtInfo);
  end
  else
  begin
    LogMessage('    COMPILER: ' + CleanMsg);
  end;
end;

function TfrmTrayMain.IsImportantCompilerMessage(const Msg: string): Boolean;
begin
  Result := (Pos('error', LowerCase(Msg)) > 0) or
            (Pos('warning', LowerCase(Msg)) > 0) or
            (Pos('hint', LowerCase(Msg)) > 0) or
            (Pos('fatal', LowerCase(Msg)) > 0) or
            (Pos('failed', LowerCase(Msg)) > 0) or
            (Pos('succeeded', LowerCase(Msg)) > 0) or
            (Pos('building', LowerCase(Msg)) > 0) or
            (Pos('compiling', LowerCase(Msg)) > 0) or
            (Pos('linking', LowerCase(Msg)) > 0);
end;

procedure TfrmTrayMain.SetBuildingState(Building: Boolean);
begin
  FIsBuilding := Building;

  progressBar.Visible := Building;
  progressBarSub.Visible := Building and chkShowCompilerOutput.Checked;
  lblProgress.Visible := Building;
  lblSubProgress.Visible := Building and chkShowCompilerOutput.Checked;

  if Building then
  begin
    progressBar.Style := pbstNormal;
    progressBar.Position := 0;
    if chkShowCompilerOutput.Checked then
      progressBarSub.Style := pbstMarquee;
    FStartTime := Now;
  end
  else
  begin
    progressBar.Position := 0;
    progressBarSub.Position := 0;
  end;

  cbConfiguration.Enabled := not Building;
  chkVerbose.Enabled := not Building;
  chkCleanFirst.Enabled := not Building;
  chkShowCompilerOutput.Enabled := not Building;
  chkDelphiOff.Enabled := not Building;
  UpdateMenuStates;
end;

procedure TfrmTrayMain.UpdateStatus(const Status: string);
begin
  lblStatus.Caption := Status;
  if FIsBuilding then
    lblTime.Caption := 'Time: ' + FormatElapsedTime(FStartTime)
  else
    lblTime.Caption := '';
  Application.ProcessMessages;
end;

function TfrmTrayMain.GetDriveLetterFromMask(UnitMask: DWORD): string;
var
  i: Integer;
  Mask: DWORD;
begin
  Result := '';
  Mask := 1;

  for i := 0 to 25 do
  begin
    if (UnitMask and Mask) <> 0 then
    begin
      Result := Chr(Ord('A') + i) + ':';
      Break;
    end;
    Mask := Mask shl 1;
  end;
end;

procedure TfrmTrayMain.WMDeviceChange(var Msg: TMessage);
var
  DevBroadcast: PDEV_BROADCAST_VOLUME;
  DriveLetter: string;
begin
  case Msg.WParam of
    DBT_DEVICEARRIVAL:
    begin
      DevBroadcast := PDEV_BROADCAST_VOLUME(Msg.LParam);
      if (DevBroadcast <> nil) and (DevBroadcast^.dbcv_devicetype = DBT_DEVTYP_VOLUME) then
      begin
        DriveLetter := GetDriveLetterFromMask(DevBroadcast^.dbcv_unitmask);
        LogMessage(Format('Drive added: %s', [DriveLetter]), lmtDrive);

        var TargetPath: string;
        if FSubstManager.IsSubstDrive(DriveLetter, TargetPath) then
        begin
          LogMessage(Format('*** DRIVE %s -> %s ***', [DriveLetter, TargetPath]), lmtDrive);
        end;
      end;
    end;

    DBT_DEVICEREMOVECOMPLETE:
    begin
      // Dispositivo/drive rimosso
      DevBroadcast := PDEV_BROADCAST_VOLUME(Msg.LParam);
      if (DevBroadcast <> nil) and (DevBroadcast^.dbcv_devicetype = DBT_DEVTYP_VOLUME) then
      begin
        DriveLetter := GetDriveLetterFromMask(DevBroadcast^.dbcv_unitmask);
        LogMessage(Format('Drive removed: %s', [DriveLetter]), lmtDrive);
      end;
    end;
  end;

  inherited;

end;

function TfrmTrayMain.FormatElapsedTime(StartTime: TDateTime): string;
var
  Elapsed: TDateTime;
  Hours, Minutes, Seconds: Word;
begin
  Elapsed := Now - StartTime;
  Hours := Trunc(Elapsed * 24);
  Minutes := Trunc((Elapsed * 24 * 60)) mod 60;
  Seconds := Trunc((Elapsed * 24 * 60 * 60)) mod 60;
  Result := Format('%.2d:%.2d:%.2d', [Hours, Minutes, Seconds]);
end;

procedure TfrmTrayMain.GestSubClick(Sender: TObject);
begin
  pGestDrive.Width := pnlMain.Width;
  pGestDrive.Height := pnlMain.Height;
  pGestDrive.Top := pnlMain.Top;
  pGestDrive.Left := pnlMain.Left;
  if Not Assigned(FFormGest) then
  begin
    FFormGest := TFGestSubst.Create(FConfig, FConfigManager);
    FFormGest.Parent := pGestDrive;
    FFormGest.Align := alClient;
    FFormGest.Top := 0;
    FFormGest.Left := 0;
    FFormGest.dsMain.DataSet := CDSPath;
    FFormGest.BorderStyle := bsNone;
  end;
  pGestDrive.Visible := True;
  FFormGest.SelectedTAG := FChecked;
  FFormGest.show;

end;

procedure TfrmTrayMain.ExecuteBuild(AConfig: TBuildConfiguration);
var
  ProjectPath, Targets: string;
  Success, lDelphiOpen: Boolean;
  i: Integer;
  BuildDesc: string;
  lDelphiOn, lResponse: Integer;

begin
  if FIsBuilding then Exit;

  LogMessage('=== Check if delphi running:  ===');
  lDelphiOn := GetDelphiProcessID;
  lResponse := mrYes;
  lDelphiOpen := False;
  if chkDelphiOff.Checked then
  begin
    if lDelphiOn <> 0 then
    begin
      LogMessage('=== Delphi running will be killed  ===');
      KillProcessByName('BDS.exe');
      lDelphiOpen := True;
    end;
  end
  else
  begin
    if lDelphiOn <> 0 then
      lResponse := MessageDlg('Warning: Delphi is currently running.' + #13#10 +
                          'Continue anyway?',
                          mtWarning,
                          [mbYes, mbNo],
                          0);
  end;

  if lresponse = mrNo then
    Exit;

  BuildDesc := AConfig.Description;
  SetBuildingState(True);
  Success := True;

  try
    LogMessage('=== START BUILD: ' + BuildDesc + ' ===');
    UpdateStatus('Init build...');
    ShowTrayNotification('Choice Builder', 'Start ' + BuildDesc + '...', bfInfo);

    for i := 0 to High(AConfig.Projects) do
    begin
      ProjectPath := AConfig.Projects[i].projectPath;
      Targets := AConfig.Projects[i].Targets;

      progressBar.Position := i;
      UpdateStatus(Format('Building %d/%d: %s', [i+1, Length(AConfig.Projects), ExtractFileName(ProjectPath)]));
      LogMessage('Build project: ' + ProjectPath + ' (Targets: ' + Targets + ')');

      if not ExecuteMSBuild(ProjectPath, Targets) then
      begin
        Success := False;
        LogMessage('ERRORE: Build failed ' + ProjectPath, lmtError);
        Break;
      end
      else
        LogMessage('SUCCESS: Build competed ' + ProjectPath, lmtSuccess);
    end;

    progressBar.Position := progressBar.Max;

    if Success then
    begin
      LogMessage('SUCCESS: ' + BuildDesc + ' completed successfully', lmtSuccess);
      UpdateStatus('Build completed successfully!');
      ShowTrayNotification('Choice Builder', BuildDesc + ' completed successfully!', bfInfo);
    end
    else
    begin
      UpdateStatus('Build failed!');
      ShowTrayNotification('Choice Builder', BuildDesc + ' failed! check log.', bfError);
    end;

  finally
    LogMessage('Build terminated: ' + FormatElapsedTime(FStartTime));
    LogMessage('========================================');
    SetBuildingState(False);
    if lDelphiOpen then
    begin
      LogMessage('=== Delphi was killed ... now reborn  ===');
      RunAndWait('BDS.exe');
    end;
    UpdateStatus('Ready');
  end;
end;

function TfrmTrayMain.ExecuteMSBuild(const ProjectPath: string; const Targets: string = 'Build'): Boolean;
var
  CommandLine: string;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  ExitCode: DWORD;
  Config: string;
  VerboseFlag: string;
  PipeRead, PipeWrite: THandle;
  SecurityAttr: TSecurityAttributes;
  Buffer: array[0..4095] of AnsiChar;
  BytesRead: DWORD;
  OutputText: string;
begin
  Result := False;

  Config := cbConfiguration.Text;

  if chkShowCompilerOutput.Checked or chkVerbose.Checked then
    VerboseFlag := '/v:n'
  else
    VerboseFlag := '/v:q';

//"C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\rsvars.bat" && msbuild.exe "/t:make" "/p:config=Debug" "s:\work\Source\WebServices\OvwServices\AppBosServices.dproj" /v:q"

  CommandLine := Format('cmd.exe /c "call "C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\rsvars.bat" && ' +
                       'msbuild.exe "/t:%s" "/p:config=%s" "%s" %s"',
                       [Targets, Config, ProjectPath, VerboseFlag]);

  LogMessage('Esecuzione comando: ' + CommandLine);

  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.wShowWindow := SW_HIDE;

  // Se l'utente vuole vedere l'output del compilatore, crea pipe per catturarlo
  if chkShowCompilerOutput.Checked then
  begin
    SecurityAttr.nLength := SizeOf(SecurityAttr);
    SecurityAttr.lpSecurityDescriptor := nil;
    SecurityAttr.bInheritHandle := True;

    if not CreatePipe(PipeRead, PipeWrite, @SecurityAttr, 0) then
    begin
      LogMessage('ERROR: Unable to create pipe for output', lmtError);
      Exit;
    end;

    try
      StartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
      StartupInfo.hStdOutput := PipeWrite;
      StartupInfo.hStdError := PipeWrite;

      // Esegui processo
      if CreateProcess(nil, PChar(CommandLine), nil, nil, True, 0, nil, nil, StartupInfo, ProcessInfo) then
      begin
        try
          CloseHandle(PipeWrite);
          PipeWrite := INVALID_HANDLE_VALUE;


          while WaitForSingleObject(ProcessInfo.hProcess, 50) = WAIT_TIMEOUT do
          begin
            if PeekNamedPipe(PipeRead, nil, 0, nil, @BytesRead, nil) and (BytesRead > 0) then
            begin
              if ReadFile(PipeRead, Buffer, SizeOf(Buffer) - 1, BytesRead, nil) then
              begin
                Buffer[BytesRead] := #0;
                OutputText := string(AnsiString(Buffer));

                while Pos(#13#10, OutputText) > 0 do
                begin
                  LogCompilerOutput(Copy(OutputText, 1, Pos(#13#10, OutputText) - 1));
                  Delete(OutputText, 1, Pos(#13#10, OutputText) + 1);
                end;
                if OutputText <> '' then
                  LogCompilerOutput(OutputText);
              end;
            end;

            UpdateStatus('Building... ' + FormatElapsedTime(FStartTime));
            Application.ProcessMessages;
          end;

          while PeekNamedPipe(PipeRead, nil, 0, nil, @BytesRead, nil) and (BytesRead > 0) do
          begin
            if ReadFile(PipeRead, Buffer, SizeOf(Buffer) - 1, BytesRead, nil) then
            begin
              Buffer[BytesRead] := #0;
              OutputText := string(AnsiString(Buffer));

              while Pos(#13#10, OutputText) > 0 do
              begin
                LogCompilerOutput(Copy(OutputText, 1, Pos(#13#10, OutputText) - 1));
                Delete(OutputText, 1, Pos(#13#10, OutputText) + 1);
              end;
              if OutputText <> '' then
                LogCompilerOutput(OutputText);
            end;
          end;

          GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
          Result := ExitCode = 0;

          LogMessage('Build complete exit code: ' + IntToStr(ExitCode));

        finally
          CloseHandle(ProcessInfo.hProcess);
          CloseHandle(ProcessInfo.hThread);
        end;
      end
      else
        LogMessage('ERRORE: Unable to start MSBuild', lmtError);

    finally
      if PipeRead <> INVALID_HANDLE_VALUE then
        CloseHandle(PipeRead);
      if PipeWrite <> INVALID_HANDLE_VALUE then
        CloseHandle(PipeWrite);
    end;
  end
  else
  begin
    StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
    if CreateProcess(nil, PChar(CommandLine), nil, nil, False, 0, nil, nil, StartupInfo, ProcessInfo) then
    begin
      try
        while WaitForSingleObject(ProcessInfo.hProcess, 100) = WAIT_TIMEOUT do
        begin
          UpdateStatus('Building... ' + FormatElapsedTime(FStartTime));
          Application.ProcessMessages;
        end;

        GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
        Result := ExitCode = 0;

        LogMessage('Build completed exit code: ' + IntToStr(ExitCode));

      finally
        CloseHandle(ProcessInfo.hProcess);
        CloseHandle(ProcessInfo.hThread);
      end;
    end
    else
      LogMessage('ERROR: Unable to start MSBuild', lmtError);
  end;
end;

// Funzione di test per verificare i colori del log
procedure TfrmTrayMain.TestLogColors;
begin
  LogMessage('╠══════════════════════════════════════════════════════════════╣');
  LogMessage('║                     TEST COLORI LOG                          ║');
  LogMessage('╠══════════════════════════════════════════════════════════════╣');
  LogMessage('║ Questo è un messaggio informativo normale                    ║', lmtInfo);
  LogMessage('║ Questo è un messaggio di WARNING                             ║', lmtWarning);
  LogMessage('║ Questo è un messaggio di ERRORE                              ║', lmtError);
  LogMessage('║ Questo è un messaggio di SUCCESSO                            ║', lmtSuccess);
  LogMessage('╠══════════════════════════════════════════════════════════════╣');
  LogMessage('║                     DRIVE MESSAGE                            ║');
  LogMessage('╠══════════════════════════════════════════════════════════════╣');
  LogMessage('║ Questo è un messaggio di MAPPED DRIVE                        ║', lmtDrive);
  LogMessage('╠══════════════════════════════════════════════════════════════╣');
  LogMessage('║                     SVN COLOR MESSAGE                        ║');
  LogMessage('╠══════════════════════════════════════════════════════════════╣');
  LogMessage('║ Questo è un messaggio di SVN Added                           ║', lmtSvnAdded);
  LogMessage('║ Questo è un messaggio di SVN Deleted                         ║', lmtSvnDeleted);
  LogMessage('║ Questo è un messaggio di SVN Updated                         ║', lmtSvnUpdated);
  LogMessage('║ Questo è un messaggio di SVN Conflict                        ║', lmtSvnConflict);
  LogMessage('║ Questo è un messaggio di SVN Merged                          ║', lmtSvnMerged);
  LogMessage('║ Questo è un messaggio di SVN Existed                         ║', lmtSvnExisted);
  LogMessage('║ Questo è un messaggio di SVN Replaced                        ║', lmtSvnReplaced);
  LogMessage('╚═══════════════════════ FINE TEST ════════════════════════════╝');

end;

end.


