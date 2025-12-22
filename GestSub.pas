unit GestSub;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtCtrls, Vcl.ComCtrls, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters,
  Vcl.Menus, Vcl.StdCtrls, cxButtons, Vcl.Mask, Vcl.DBCtrls, cxControls,
  cxContainer, cxEdit, dxGDIPlusClasses, cxImage
  , ConfigManager
  , BuildConfigManager, System.ImageList, Vcl.ImgList, cxImageList, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxImageComboBox, cxNavigator, cxDBNavigator
  ;

type
  TFGestSubst = class(TForm)
    PageControl: TPageControl;
    tsPath: TTabSheet;
    tsConfig: TTabSheet;
    Panel1: TPanel;
    DBGrid1: TDBGrid;
    dsMain: TDataSource;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtTag: TDBEdit;
    edtPath: TDBEdit;
    edtDescr: TDBEdit;
    btnFolder: TcxButton;
    Label4: TLabel;
    cxImage1: TcxImage;
    cxButton2: TcxButton;
    cbActive: TDBCheckBox;
    edtBOS: TEdit;
    lBOS: TLabel;
    edtAPPBOS: TEdit;
    Label5: TLabel;
    btnBosPath: TcxButton;
    btnAPPBOSPath: TcxButton;
    Label6: TLabel;
    edtAlone: TEdit;
    btnAlonePath: TcxButton;
    btnSaveConfig: TcxButton;
    chkVerbose: TCheckBox;
    chkCleanFirst: TCheckBox;
    chkShowCompilerOutput: TCheckBox;
    chkDelphiOff: TCheckBox;
    Label7: TLabel;
    edtDriveLetter: TEdit;
    tsBuilder: TTabSheet;
    lbResource: TListBox;
    lresurce: TLabel;
    btnAddRes: TcxButton;
    btnDelRes: TcxButton;
    Panel3: TPanel;
    ednResName: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    ednRedDescr: TEdit;
    Label10: TLabel;
    cbCategory: TComboBox;
    chkEnabled: TCheckBox;
    cbIcon: TComboBox;
    lblIcon: TLabel;
    pnlProjectEdit: TPanel;
    lblProjectPath: TLabel;
    lblTargets: TLabel;
    lblProjectDescription: TLabel;
    edtProjectPath: TEdit;
    cbTargets: TComboBox;
    edtProjectDescription: TEdit;
    btnPathPrj: TcxButton;
    lvProjects: TListBox;
    cxButton1: TcxButton;
    cxButton3: TcxButton;
    cxButton4: TcxButton;
    cxImageComboBox1: TcxImageComboBox;
    cxImageList: TcxImageList;
    Label11: TLabel;
    edtOvwTools: TEdit;
    Label12: TLabel;
    edtXlsConv: TEdit;
    btnXlsConv: TcxButton;
    btnOvwTools: TcxButton;
    DBNavigator: TcxDBNavigator;
    Label13: TLabel;
    edtSQLServer: TEdit;
    Label14: TLabel;
    edtCaseStudio: TEdit;
    btnLogPath: TcxButton;
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure cxButton2Click(Sender: TObject);
    procedure btnFolderClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSaveConfigClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnBosPathClick(Sender: TObject);
    procedure lbResourceClick(Sender: TObject);
    procedure lvProjectsClick(Sender: TObject);
    procedure btnPathPrjClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
  private
    { Private declarations }
    FSelectedTAG: Integer;
    FConfig: TConfigManager;
    FBuild: TBuildConfigManager;
  public
    Constructor Create(AConfig: TConfigManager; ABuild: TBuildConfigManager); Reintroduce;
    Property SelectedTAG: Integer read FSelectedTAG write FSelectedTAG;
    { Public declarations }
  end;

var
  FGestSubst: TFGestSubst;

implementation

uses TrayMainForm;
{$R *.dfm}

procedure TFGestSubst.btnBosPathClick(Sender: TObject);
var
  OpenDialog: TOpenDialog;
begin
  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Title := 'Select .exe file';
    OpenDialog.Filter := 'File (*.exe)|*.exe';
    if OpenDialog.Execute then
    begin
      case TcxButton(sender).Tag of
        1: edtPath.Text   := OpenDialog.FileName;
        2: edtBOS.Text    := OpenDialog.FileName;
        3: edtAPPBOS.Text := OpenDialog.FileName;
        4: edtAlone.Text  := OpenDialog.FileName;
        5: edtOvwTools.Text := OpenDialog.FileName;
        6: edtXlsConv.Text  := OpenDialog.FileName;
        7: edtCaseStudio.Text := OpenDialog.FileName;
      end;
    end;
  finally
    OpenDialog.Free;
  end;
end;

procedure TFGestSubst.btnFolderClick(Sender: TObject);
var
  Dialog: TFileOpenDialog;
begin
  Dialog := TFileOpenDialog.Create(Self);
  try
    Dialog.Title := 'Select folder';
    Dialog.Options := [fdoPickFolders, fdoPathMustExist];

    if Dialog.Execute then
      edtPath.Text := Dialog.FileName;

  finally
    FreeAndNil(Dialog);
  end;
end;

procedure TFGestSubst.btnPathPrjClick(Sender: TObject);
var
  OpenDialog: TOpenDialog;
begin
  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Title := 'Select Project file';
    OpenDialog.Filter := 'Delphi Projects (*.dproj;*.groupproj)|*.dproj;*.groupproj|All Files (*.*)|*.*';
    OpenDialog.DefaultExt := 'dproj';
    if OpenDialog.Execute then
    begin
      edtProjectPath.Text := OpenDialog.FileName;
      if Trim(edtProjectDescription.Text) = '' then
        edtProjectDescription.Text := ChangeFileExt(ExtractFileName(OpenDialog.FileName), '');
    end;
  finally
    OpenDialog.Free;
  end;

end;

procedure TFGestSubst.btnSaveConfigClick(Sender: TObject);
begin
  FConfig.WriteBool('Settings', 'chkVerbose', chkVerbose.Checked);
  FConfig.WriteBool('Settings', 'chkCleanFirst', chkCleanFirst.Checked);
  FConfig.WriteBool('Settings', 'chkShowCompilerOutput', chkShowCompilerOutput.Checked);
  FConfig.WriteBool('Settings', 'chkDelphiOff', chkDelphiOff.Checked);
  FConfig.WriteString('Settings', 'edtDriveLetter', edtDriveLetter.Text);
  var lVersionDrive :=  StringReplace(frmTrayMain.mnuActiveVersion.Caption, '&', '', [rfReplaceAll, rfIgnoreCase]);
  FConfig.WriteString('Settings', 'MapDrive', lVersionDrive);

  FConfig.WriteString('Settings', 'edtBOS', edtBOS.Text);
  FConfig.WriteString('Settings', 'edtAPPBOS', edtAPPBOS.Text);
  FConfig.WriteString('Settings', 'edtAlone', edtAlone.Text);
  FConfig.WriteString('Settings', 'edtOvwTools', edtOvwTools.text);
  FConfig.WriteString('Settings', 'edtXlsConv', edtXlsConv.Text);
  FConfig.WriteString('Settings', 'edtCaseStudio', edtCaseStudio.Text);
  FConfig.WriteString('Settings', 'edtSQLServer', edtSQLServer.Text);

//  FRecConfig := TRecConfig.GetInstance(ledtBOS, ledtAPPBOS, ledtAlone, lOvwTools, lXlsConv, lSqlServer)

  FConfig.SaveToFile;
end;

constructor TFGestSubst.Create(AConfig: TConfigManager; ABuild: TBuildConfigManager);
begin
  inherited Create(Nil);
  FConfig := AConfig;
  FBuild  := ABuild;

end;

procedure TFGestSubst.cxButton2Click(Sender: TObject);
begin
  Close;
end;

procedure TFGestSubst.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Grid: TDBGrid;
  CheckRect: TRect;
  IsChecked: Boolean;
begin
  Grid := Sender as TDBGrid;

  if not (gdSelected in State) then
  begin
    if Grid.DataSource.DataSet.FieldByName('TAG').AsInteger = SelectedTAG then
      Grid.Canvas.Brush.Color := RGB(124, 201, 126)
    else if Grid.DataSource.DataSet.RecNo mod 2 = 0 then
      Grid.Canvas.Brush.Color := RGB(240, 240, 240)
    else
      Grid.Canvas.Brush.Color := clWhite;
  end;

  if Column.FieldName = 'Active' then
  begin
    Grid.Canvas.FillRect(Rect);

    CheckRect.Left := Rect.Left + ((Rect.Right - Rect.Left - 13) div 2);
    CheckRect.Top := Rect.Top + ((Rect.Bottom - Rect.Top - 13) div 2);
    CheckRect.Right := CheckRect.Left + 13;
    CheckRect.Bottom := CheckRect.Top + 13;

    IsChecked := Grid.DataSource.DataSet.FieldByName('ACtive').AsInteger = 1;

    // Disegna il checkbox
    if IsChecked then
      DrawFrameControl(Grid.Canvas.Handle, CheckRect, DFC_BUTTON,
                      DFCS_BUTTONCHECK or DFCS_CHECKED)
    else
      DrawFrameControl(Grid.Canvas.Handle, CheckRect, DFC_BUTTON,
                      DFCS_BUTTONCHECK);
  end
  else
    Grid.DefaultDrawColumnCell(Rect, DataCol, Column, State);

end;

procedure TFGestSubst.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmTrayMain.initializeDrive;
  frmTrayMain.pGestDrive.Visible := False;
  frmTrayMain.pnlMain.Visible := True;
  FConfig.ReloadFromFile;
  frmTrayMain.LoadSettings;
end;

procedure TFGestSubst.FormShow(Sender: TObject);
Var lBuild: TBuildConfiguration;
begin
  FConfig.ReloadFromFile;
  chkVerbose.Checked  := FConfig.ReadBool('Settings', 'chkVerbose', False);
  chkCleanFirst.Checked := FConfig.ReadBool('Settings', 'chkCleanFirst', False);
  chkShowCompilerOutput.Checked := FConfig.ReadBool('Settings', 'chkShowCompilerOutput', False);
  chkDelphiOff.Checked := FConfig.ReadBool('Settings', 'chkDelphiOff', False);
  edtDriveLetter.Text := FConfig.ReadString('Settings', 'edtDriveLetter', 'S');
  edtBOS.Text         := FConfig.ReadString('Settings', 'edtBOS', 's:\work\Bin\Overview.exe');
  edtAPPBOS.Text      := FConfig.ReadString('Settings', 'edtAPPBOS', 'c:\isapi\AppBosServices.exe');
  edtAlone.Text       := FConfig.ReadString('Settings', 'edtAlone', 's:\work\Bin\OverviewStandaloneSrv.exe');
  edtOvwTools.text    := FConfig.ReadString('Settings', 'edtOvwTools', 's:\work\R&D\OvwTools.exe');
  edtXlsConv.Text     := FConfig.ReadString('Settings', 'edtXlsConv', 's:\work\R&D\XslConverter.exe');
  edtCaseStudio.Text  := FConfig.ReadString('Settings', 'edtCaseStudio', 'C:\Program Files (x86)\RKSoft\CASEStudio2\Bin\CASEStud.exe');
  edtSQLServer.Text   := FConfig.ReadString('Settings', 'edtSQLServer', 'localhost');

  lbResource.Items.Clear;

  for lBuild in FBuild.Configurations do
    lbResource.Items.Add(lBuild.Name);

end;

procedure TFGestSubst.lbResourceClick(Sender: TObject);
Var ConPrj: TBuildProject;
begin
  var Config := FBuild.GetConfiguration(lbResource.ItemIndex);
  ednResName.Text  := Config.Name;
  ednRedDescr.Text := Config.Description;
  cbCategory.Text  := Config.Category;

  lvProjects.Items.Clear;
  for ConPrj in Config.Projects do
  begin
    Var lDescr := ConPrj.Description;
    lvProjects.Items.Add(lDescr);
  end;
  if lvProjects.Items.Count > 0 then
  begin
    lvProjects.ItemIndex := 0;
    lvProjectsClick(nil);
  end;
end;

procedure TFGestSubst.lvProjectsClick(Sender: TObject);
Var ConPrj: TBuildProject;
begin
  var Config := FBuild.GetConfiguration(lbResource.ItemIndex);
  ConPrj := Config.Projects[lvProjects.ItemIndex];
  edtProjectPath.Text := ConPrj.ProjectPath;
  edtProjectDescription.Text := ConPrj.Description;
  cbTargets.Text := ConPrj.Targets;
end;

procedure TFGestSubst.PageControlChange(Sender: TObject);
begin
  DBNavigator.Enabled := PageControl.ActivePage = tsPath;
end;

end.
