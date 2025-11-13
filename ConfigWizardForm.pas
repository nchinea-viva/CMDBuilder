unit ConfigWizardForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, 
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Buttons, Vcl.Grids,
  System.UITypes, System.Types,
  BuildConfigManager, System.Generics.Collections;

type
  TfrmConfigWizard = class(TForm)
    pnlMain: TPanel;
    PageControl: TPageControl;
    tabGeneral: TTabSheet;
    tabProjects: TTabSheet;
    tabOptions: TTabSheet;
    pnlButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    btnNext: TButton;
    btnPrevious: TButton;
    
    // Tab General
    lblName: TLabel;
    edtName: TEdit;
    lblDescription: TLabel;
    memoDescription: TMemo;
    lblShortcut: TLabel;
    edtShortcut: TEdit;
    lblCategory: TLabel;
    cbCategory: TComboBox;
    lblIcon: TLabel;
    cbIcon: TComboBox;
    chkEnabled: TCheckBox;
    
    // Tab Projects
    lblProjects: TLabel;
    lvProjects: TListView;
    pnlProjectButtons: TPanel;
    btnAddProject: TButton;
    btnEditProject: TButton;
    btnRemoveProject: TButton;
    btnMoveUp: TButton;
    btnMoveDown: TButton;
    
    // Tab Options
    lblConfiguration: TLabel;
    cbConfiguration: TComboBox;
    chkVerbose: TCheckBox;
    chkCleanFirst: TCheckBox;
    chkShowOutput: TCheckBox;
    
    // Project Edit Panel
    pnlProjectEdit: TPanel;
    lblProjectPath: TLabel;
    edtProjectPath: TEdit;
    btnBrowseProject: TButton;
    lblTargets: TLabel;
    cbTargets: TComboBox;
    lblProjectDescription: TLabel;
    edtProjectDescription: TEdit;
    btnSaveProject: TButton;
    btnCancelProject: TButton;
    
    OpenDialog: TOpenDialog;
    
    procedure FormCreate(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPreviousClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure btnAddProjectClick(Sender: TObject);
    procedure btnEditProjectClick(Sender: TObject);
    procedure btnRemoveProjectClick(Sender: TObject);
    procedure btnMoveUpClick(Sender: TObject);
    procedure btnMoveDownClick(Sender: TObject);
    procedure btnBrowseProjectClick(Sender: TObject);
    procedure btnSaveProjectClick(Sender: TObject);
    procedure btnCancelProjectClick(Sender: TObject);
    procedure lvProjectsDblClick(Sender: TObject);
    procedure edtNameChange(Sender: TObject);
  private
    FConfiguration: TBuildConfiguration;
    FEditingProjectIndex: Integer;
    procedure UpdateNavigationButtons;
    Function ValidateCurrentPage: Boolean;
    function ValidateGeneral: Boolean;
    function ValidateProjects: Boolean;
    function ValidateOptions: Boolean;
    procedure LoadProjectsToListView;
    procedure ShowProjectEditPanel(Show: Boolean);
    procedure ClearProjectEditPanel;
    procedure LoadProjectToEditPanel(Index: Integer);
    procedure SaveProjectFromEditPanel;
    function CreateProjectFromEditPanel: TBuildProject;
  public
    function GetConfiguration: TBuildConfiguration;
    procedure LoadConfiguration(Config: TBuildConfiguration);
    procedure UpdateConfiguration(Config: TBuildConfiguration);
  end;

implementation

{$R *.dfm}

procedure TfrmConfigWizard.FormCreate(Sender: TObject);
begin
  Caption := 'Wizard Configurazione Build';
  FConfiguration := TBuildConfiguration.Create;
  FEditingProjectIndex := -1;
  
  // Inizializza combo boxes
  cbCategory.Items.AddStrings(['General', 'Development', 'Release', 'Services', 'Components', 'Testing']);
  cbCategory.ItemIndex := 0;
  
  cbIcon.Items.AddStrings(['build', 'fast', 'release', 'service', 'package', 'module', 'test']);
  cbIcon.ItemIndex := 0;
  
  cbConfiguration.Items.AddStrings(['Debug', 'Release']);
  cbConfiguration.ItemIndex := 0;
  
  cbTargets.Items.AddStrings(['Build', 'Clean;Build', 'make', 'Rebuild']);
  cbTargets.ItemIndex := 0;
  
  // Configura ListView
  lvProjects.ViewStyle := vsReport;
  lvProjects.Columns.Add.Caption := 'Progetto';
  lvProjects.Columns.Add.Caption := 'Targets';
  lvProjects.Columns.Add.Caption := 'Descrizione';
  lvProjects.Columns[0].Width := 200;
  lvProjects.Columns[1].Width := 100;
  lvProjects.Columns[2].Width := 150;
  
  // Imposta valori di default
  chkEnabled.Checked := True;
  chkCleanFirst.Checked := True;
  
  PageControl.ActivePageIndex := 0;
  ShowProjectEditPanel(False);
  UpdateNavigationButtons;
end;

procedure TfrmConfigWizard.UpdateNavigationButtons;
var
  CurrentPage: Integer;
begin
  CurrentPage := PageControl.ActivePageIndex;
  
  btnPrevious.Enabled := CurrentPage > 0;
  btnNext.Enabled := CurrentPage < PageControl.PageCount - 1;
  btnOK.Enabled := CurrentPage = PageControl.PageCount - 1;
end;

procedure TfrmConfigWizard.PageControlChange(Sender: TObject);
begin
  UpdateNavigationButtons;
  ValidateCurrentPage;
end;

procedure TfrmConfigWizard.btnNextClick(Sender: TObject);
begin
  if ValidateCurrentPage then
  begin
    PageControl.ActivePageIndex := PageControl.ActivePageIndex + 1;
    UpdateNavigationButtons;
  end;
end;

procedure TfrmConfigWizard.btnPreviousClick(Sender: TObject);
begin
  PageControl.ActivePageIndex := PageControl.ActivePageIndex - 1;
  UpdateNavigationButtons;
end;

Function TfrmConfigWizard.ValidateCurrentPage: Boolean;
begin

  case PageControl.ActivePageIndex of
    0: Result := ValidateGeneral;
    1: Result := ValidateProjects;
    2: Result := ValidateOptions;
  else
    Result := False;
  end;
end;

function TfrmConfigWizard.ValidateGeneral: Boolean;
begin
  Result := True;
  
  if Trim(edtName.Text) = '' then
  begin
    ShowMessage('Il nome della configurazione è obbligatorio.');
    edtName.SetFocus;
    Result := False;
    Exit;
  end;
  
  if Trim(edtShortcut.Text) = '' then
  begin
    ShowMessage('La scorciatoia è obbligatoria.');
    edtShortcut.SetFocus;
    Result := False;
    Exit;
  end;
  
  if Length(Trim(edtShortcut.Text)) > 1 then
  begin
    ShowMessage('La scorciatoia deve essere un singolo carattere.');
    edtShortcut.SetFocus;
    Result := False;
    Exit;
  end;
end;

function TfrmConfigWizard.ValidateProjects: Boolean;
begin
  Result := True;
  
  if lvProjects.Items.Count = 0 then
  begin
    ShowMessage('Devi aggiungere almeno un progetto alla configurazione.');
    Result := False;
    Exit;
  end;
end;

function TfrmConfigWizard.ValidateOptions: Boolean;
begin
  Result := True;
  // Le opzioni sono sempre valide
end;

procedure TfrmConfigWizard.btnOKClick(Sender: TObject);
begin
  if ValidateCurrentPage then
  begin
    // Salva i dati nella configurazione
    FConfiguration.Name := Trim(edtName.Text);
    FConfiguration.Description := Trim(memoDescription.Text);
    FConfiguration.Shortcut := UpperCase(Trim(edtShortcut.Text));
    FConfiguration.Category := cbCategory.Text;
    FConfiguration.Icon := cbIcon.Text;
    FConfiguration.Enabled := chkEnabled.Checked;
    FConfiguration.Configuration := cbConfiguration.Text;
    FConfiguration.Verbose := chkVerbose.Checked;
    FConfiguration.CleanFirst := chkCleanFirst.Checked;
    FConfiguration.ShowOutput := chkShowOutput.Checked;
    
    ModalResult := mrOk;
  end;
end;

procedure TfrmConfigWizard.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmConfigWizard.LoadProjectsToListView;
var
  i: Integer;
  Item: TListItem;
  Project: TBuildProject;
begin
  lvProjects.Items.Clear;
  
  for i := 0 to High(FConfiguration.Projects) do
  begin
    Project := FConfiguration.Projects[i];
    Item := lvProjects.Items.Add;
    Item.Caption := ExtractFileName(Project.ProjectPath);
    Item.SubItems.Add(Project.Targets);
    Item.SubItems.Add(Project.Description);
    Item.Data := Pointer(i);
  end;
end;

procedure TfrmConfigWizard.ShowProjectEditPanel(Show: Boolean);
begin
  pnlProjectEdit.Visible := Show;
  lvProjects.Enabled := not Show;
  pnlProjectButtons.Enabled := not Show;
end;

procedure TfrmConfigWizard.ClearProjectEditPanel;
begin
  edtProjectPath.Text := '';
  cbTargets.ItemIndex := 0;
  edtProjectDescription.Text := '';
end;

procedure TfrmConfigWizard.LoadProjectToEditPanel(Index: Integer);
var
  Project: TBuildProject;
begin
  if (Index >= 0) and (Index < Length(FConfiguration.Projects)) then
  begin
    Project := FConfiguration.Projects[Index];
    edtProjectPath.Text := Project.ProjectPath;
    cbTargets.Text := Project.Targets;
    edtProjectDescription.Text := Project.Description;
  end;
end;

function TfrmConfigWizard.CreateProjectFromEditPanel: TBuildProject;
begin
  Result.ProjectPath := Trim(edtProjectPath.Text);
  Result.Targets := Trim(cbTargets.Text);
  Result.Description := Trim(edtProjectDescription.Text);
end;

procedure TfrmConfigWizard.SaveProjectFromEditPanel;
var
  Project: TBuildProject;
begin
  Project := CreateProjectFromEditPanel;
  
  if FEditingProjectIndex >= 0 then
  begin
    // Modifica progetto esistente
    FConfiguration.Projects[FEditingProjectIndex] := Project;
  end
  else
  begin
    // Aggiungi nuovo progetto
    FConfiguration.AddProject(Project.ProjectPath, Project.Targets, Project.Description);
  end;
end;

procedure TfrmConfigWizard.btnAddProjectClick(Sender: TObject);
begin
  FEditingProjectIndex := -1;
  ClearProjectEditPanel;
  ShowProjectEditPanel(True);
end;

procedure TfrmConfigWizard.btnEditProjectClick(Sender: TObject);
begin
  if lvProjects.Selected <> nil then
  begin
    FEditingProjectIndex := Integer(lvProjects.Selected.Data);
    LoadProjectToEditPanel(FEditingProjectIndex);
    ShowProjectEditPanel(True);
  end
  else
    ShowMessage('Seleziona un progetto da modificare.');
end;

procedure TfrmConfigWizard.btnRemoveProjectClick(Sender: TObject);
begin
  if lvProjects.Selected <> nil then
  begin
    if MessageDlg('Sei sicuro di voler rimuovere questo progetto?', 
                  mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      FConfiguration.RemoveProject(Integer(lvProjects.Selected.Data));
      LoadProjectsToListView;
    end;
  end
  else
    ShowMessage('Seleziona un progetto da rimuovere.');
end;

procedure TfrmConfigWizard.btnMoveUpClick(Sender: TObject);
var
  Index: Integer;
  TempProject: TBuildProject;
begin
  if lvProjects.Selected <> nil then
  begin
    Index := Integer(lvProjects.Selected.Data);
    if Index > 0 then
    begin
      TempProject := FConfiguration.Projects[Index];
      FConfiguration.Projects[Index] := FConfiguration.Projects[Index - 1];
      FConfiguration.Projects[Index - 1] := TempProject;
      LoadProjectsToListView;
      lvProjects.Items[Index - 1].Selected := True;
    end;
  end;
end;

procedure TfrmConfigWizard.btnMoveDownClick(Sender: TObject);
var
  Index: Integer;
  TempProject: TBuildProject;
begin
  if lvProjects.Selected <> nil then
  begin
    Index := Integer(lvProjects.Selected.Data);
    if Index < High(FConfiguration.Projects) then
    begin
      TempProject := FConfiguration.Projects[Index];
      FConfiguration.Projects[Index] := FConfiguration.Projects[Index + 1];
      FConfiguration.Projects[Index + 1] := TempProject;
      LoadProjectsToListView;
      lvProjects.Items[Index + 1].Selected := True;
    end;
  end;
end;

procedure TfrmConfigWizard.btnBrowseProjectClick(Sender: TObject);
begin
  OpenDialog.Filter := 'Delphi Projects (*.dproj;*.groupproj)|*.dproj;*.groupproj|All Files (*.*)|*.*';
  OpenDialog.DefaultExt := 'dproj';
  
  if OpenDialog.Execute then
  begin
    edtProjectPath.Text := OpenDialog.FileName;
    if Trim(edtProjectDescription.Text) = '' then
      edtProjectDescription.Text := ChangeFileExt(ExtractFileName(OpenDialog.FileName), '');
  end;
end;

procedure TfrmConfigWizard.btnSaveProjectClick(Sender: TObject);
begin
  if Trim(edtProjectPath.Text) = '' then
  begin
    ShowMessage('Il percorso del progetto è obbligatorio.');
    edtProjectPath.SetFocus;
    Exit;
  end;
  
  if Trim(edtProjectDescription.Text) = '' then
  begin
    ShowMessage('La descrizione del progetto è obbligatoria.');
    edtProjectDescription.SetFocus;
    Exit;
  end;
  
  SaveProjectFromEditPanel;
  LoadProjectsToListView;
  ShowProjectEditPanel(False);
end;

procedure TfrmConfigWizard.btnCancelProjectClick(Sender: TObject);
begin
  ShowProjectEditPanel(False);
end;

procedure TfrmConfigWizard.lvProjectsDblClick(Sender: TObject);
begin
  btnEditProjectClick(Sender);
end;

procedure TfrmConfigWizard.edtNameChange(Sender: TObject);
begin
  // Auto-genera shortcut se vuoto
  if (Trim(edtShortcut.Text) = '') and (Length(Trim(edtName.Text)) > 0) then
    edtShortcut.Text := UpperCase(Copy(Trim(edtName.Text), 1, 1));
end;

function TfrmConfigWizard.GetConfiguration: TBuildConfiguration;
begin
  Result := FConfiguration;
end;

procedure TfrmConfigWizard.LoadConfiguration(Config: TBuildConfiguration);
begin
  FConfiguration.Free;
  FConfiguration := TBuildConfiguration.Create;
  
  FConfiguration.Name := Config.Name;
  FConfiguration.Description := Config.Description;
  FConfiguration.Shortcut := Config.Shortcut;
  FConfiguration.Category := Config.Category;
  FConfiguration.Icon := Config.Icon;
  FConfiguration.Enabled := Config.Enabled;
  FConfiguration.Configuration := Config.Configuration;
  FConfiguration.Verbose := Config.Verbose;
  FConfiguration.CleanFirst := Config.CleanFirst;
  FConfiguration.ShowOutput := Config.ShowOutput;
  FConfiguration.Projects := Copy(Config.Projects);
  
  // Carica i dati nei controlli
  edtName.Text := FConfiguration.Name;
  memoDescription.Text := FConfiguration.Description;
  edtShortcut.Text := FConfiguration.Shortcut;
  cbCategory.Text := FConfiguration.Category;
  cbIcon.Text := FConfiguration.Icon;
  chkEnabled.Checked := FConfiguration.Enabled;
  cbConfiguration.Text := FConfiguration.Configuration;
  chkVerbose.Checked := FConfiguration.Verbose;
  chkCleanFirst.Checked := FConfiguration.CleanFirst;
  chkShowOutput.Checked := FConfiguration.ShowOutput;
  
  LoadProjectsToListView;
end;

procedure TfrmConfigWizard.UpdateConfiguration(Config: TBuildConfiguration);
begin
  Config.Name := FConfiguration.Name;
  Config.Description := FConfiguration.Description;
  Config.Shortcut := FConfiguration.Shortcut;
  Config.Category := FConfiguration.Category;
  Config.Icon := FConfiguration.Icon;
  Config.Enabled := FConfiguration.Enabled;
  Config.Configuration := FConfiguration.Configuration;
  Config.Verbose := FConfiguration.Verbose;
  Config.CleanFirst := FConfiguration.CleanFirst;
  Config.ShowOutput := FConfiguration.ShowOutput;
  Config.Projects := Copy(FConfiguration.Projects);
end;

end.



