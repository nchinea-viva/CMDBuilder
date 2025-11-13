unit BuildConfigManager;

interface

uses
  System.Classes, System.SysUtils, System.JSON, System.IOUtils,
  System.Generics.Collections;

type
  TBuildProject = record
    ProjectPath: string;
    Targets: string;
    Description: string;
  end;

  TBuildConfiguration = class
  private
    FName: string;
    FDescription: string;
    FShortcut: string;
    FProjects: TArray<TBuildProject>;
    FConfiguration: string; // Debug/Release
    FVerbose: Boolean;
    FCleanFirst: Boolean;
    FShowOutput: Boolean;
    FEnabled: Boolean;
    FIcon: string;
    FCategory: string;
  public
    constructor Create;
    procedure AddProject(const ProjectPath, Targets, Description: string);
    procedure RemoveProject(Index: Integer);
    function ToJSON: TJSONObject;
    procedure FromJSON(JSONObj: TJSONObject);

    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property Shortcut: string read FShortcut write FShortcut;
    property Projects: TArray<TBuildProject> read FProjects write FProjects;
    property Configuration: string read FConfiguration write FConfiguration;
    property Verbose: Boolean read FVerbose write FVerbose;
    property CleanFirst: Boolean read FCleanFirst write FCleanFirst;
    property ShowOutput: Boolean read FShowOutput write FShowOutput;
    property Enabled: Boolean read FEnabled write FEnabled;
    property Icon: string read FIcon write FIcon;
    property Category: string read FCategory write FCategory;
  end;

  TBuildConfigManager = class
  private
    FConfigurations: TObjectList<TBuildConfiguration>;
    FConfigFile: string;
    FConfigDir: string;
    procedure CreateDefaultConfigurations;
    function GetConfigFilePath: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadConfigurations;
    procedure SaveConfigurations;
    procedure AddConfiguration(Config: TBuildConfiguration);
    procedure RemoveConfiguration(Index: Integer);
    function GetConfiguration(Index: Integer): TBuildConfiguration;
    function GetConfigurationByName(const Name: string): TBuildConfiguration;
    function GetConfigurationCount: Integer;
    procedure ResetToDefaults;

    property Configurations: TObjectList<TBuildConfiguration> read FConfigurations;
    property ConfigFile: string read FConfigFile;
  end;

implementation

{ TBuildConfiguration }

constructor TBuildConfiguration.Create;
begin
  inherited;
  FConfiguration := 'Debug';
  FVerbose := False;
  FCleanFirst := True;
  FShowOutput := False;
  FEnabled := True;
  FIcon := 'build';
  FCategory := 'General';
  SetLength(FProjects, 0);
end;

procedure TBuildConfiguration.AddProject(const ProjectPath, Targets, Description: string);
var
  NewProject: TBuildProject;
begin
  NewProject.ProjectPath := ProjectPath;
  NewProject.Targets := Targets;
  NewProject.Description := Description;

  SetLength(FProjects, Length(FProjects) + 1);
  FProjects[High(FProjects)] := NewProject;
end;

procedure TBuildConfiguration.RemoveProject(Index: Integer);
var
  i: Integer;
begin
  if (Index >= 0) and (Index < Length(FProjects)) then
  begin
    for i := Index to High(FProjects) - 1 do
      FProjects[i] := FProjects[i + 1];
    SetLength(FProjects, Length(FProjects) - 1);
  end;
end;

function TBuildConfiguration.ToJSON: TJSONObject;
var
  JSONProjects: TJSONArray;
  JSONProject: TJSONObject;
  i: Integer;
begin
  Result := TJSONObject.Create;

  Result.AddPair('name', FName);
  Result.AddPair('description', FDescription);
  Result.AddPair('shortcut', FShortcut);
  Result.AddPair('configuration', FConfiguration);
  Result.AddPair('verbose', TJSONBool.Create(FVerbose));
  Result.AddPair('cleanFirst', TJSONBool.Create(FCleanFirst));
  Result.AddPair('showOutput', TJSONBool.Create(FShowOutput));
  Result.AddPair('enabled', TJSONBool.Create(FEnabled));
  Result.AddPair('icon', FIcon);
  Result.AddPair('category', FCategory);

  JSONProjects := TJSONArray.Create;
  for i := 0 to High(FProjects) do
  begin
    JSONProject := TJSONObject.Create;
    JSONProject.AddPair('projectPath', FProjects[i].ProjectPath);
    JSONProject.AddPair('targets', FProjects[i].Targets);
    JSONProject.AddPair('description', FProjects[i].Description);
    JSONProjects.AddElement(JSONProject);
  end;
  Result.AddPair('projects', JSONProjects);
end;

procedure TBuildConfiguration.FromJSON(JSONObj: TJSONObject);
var
  JSONProjects: TJSONArray;
  JSONProject: TJSONObject;
  i: Integer;
  Project: TBuildProject;
begin
  FName := JSONObj.GetValue('name').Value;
  FDescription := JSONObj.GetValue('description').Value;
  FShortcut := JSONObj.GetValue('shortcut').Value;
  FConfiguration := JSONObj.GetValue('configuration').Value;
  FVerbose := (JSONObj.GetValue('verbose') as TJSONBool).AsBoolean;
  FCleanFirst := (JSONObj.GetValue('cleanFirst') as TJSONBool).AsBoolean;
  FShowOutput := (JSONObj.GetValue('showOutput') as TJSONBool).AsBoolean;
  FEnabled := (JSONObj.GetValue('enabled') as TJSONBool).AsBoolean;
  FIcon := JSONObj.GetValue('icon').Value;
  FCategory := JSONObj.GetValue('category').Value;

  JSONProjects := JSONObj.GetValue('projects') as TJSONArray;
  SetLength(FProjects, JSONProjects.Count);

  for i := 0 to JSONProjects.Count - 1 do
  begin
    JSONProject := JSONProjects.Items[i] as TJSONObject;
    Project.ProjectPath := JSONProject.GetValue('projectPath').Value;
    Project.Targets := JSONProject.GetValue('targets').Value;
    Project.Description := JSONProject.GetValue('description').Value;
    FProjects[i] := Project;
  end;
end;

{ TBuildConfigManager }

constructor TBuildConfigManager.Create;
begin
  inherited;
  FConfigurations := TObjectList<TBuildConfiguration>.Create(True);
  FConfigDir := TPath.Combine(ExtractFilePath(ParamStr(0)), 'configs');
  FConfigFile := GetConfigFilePath;

  if not TDirectory.Exists(FConfigDir) then
    TDirectory.CreateDirectory(FConfigDir);
end;

destructor TBuildConfigManager.Destroy;
begin
  FConfigurations.Free;
  inherited;
end;

function TBuildConfigManager.GetConfigFilePath: string;
begin
  Result := TPath.Combine(FConfigDir, 'build_configurations.json');
end;

procedure TBuildConfigManager.LoadConfigurations;
var
  JSONText: string;
  JSONObj: TJSONObject;
  JSONArray: TJSONArray;
  JSONConfig: TJSONObject;
  Config: TBuildConfiguration;
  i: Integer;
begin
  FConfigurations.Clear;

  if not TFile.Exists(FConfigFile) then
  begin
    CreateDefaultConfigurations;
    SaveConfigurations;
    Exit;
  end;

  try
    JSONText := TFile.ReadAllText(FConfigFile, TEncoding.UTF8);
    JSONObj := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;

    if Assigned(JSONObj) then
    try
      JSONArray := JSONObj.GetValue('configurations') as TJSONArray;

      for i := 0 to JSONArray.Count - 1 do
      begin
        JSONConfig := JSONArray.Items[i] as TJSONObject;
        Config := TBuildConfiguration.Create;
        Config.FromJSON(JSONConfig);
        FConfigurations.Add(Config);
      end;

    finally
      JSONObj.Free;
    end;
  except
    on E: Exception do
    begin
      // Se c'è un errore nel file, ricrea le configurazioni di default
      FConfigurations.Clear;
      CreateDefaultConfigurations;
      SaveConfigurations;
    end;
  end;
end;

procedure TBuildConfigManager.SaveConfigurations;
var
  JSONObj: TJSONObject;
  JSONArray: TJSONArray;
  i: Integer;
  JSONText: string;
begin
  JSONObj := TJSONObject.Create;
  try
    JSONObj.AddPair('version', '1.0');
    JSONObj.AddPair('created', DateTimeToStr(Now));

    JSONArray := TJSONArray.Create;
    for i := 0 to FConfigurations.Count - 1 do
    begin
      JSONArray.AddElement(FConfigurations[i].ToJSON);
    end;
    JSONObj.AddPair('configurations', JSONArray);

    JSONText := JSONObj.Format;
    TFile.WriteAllText(FConfigFile, JSONText, TEncoding.UTF8);
  finally
    JSONObj.Free;
  end;
end;

procedure TBuildConfigManager.CreateDefaultConfigurations;
var
  Config: TBuildConfiguration;
begin
  // Fast Build
  Config := TBuildConfiguration.Create;
  Config.Name := 'Super Fast Build';
  Config.Description := 'Build veloce senza clean per sviluppo rapido';
  Config.Shortcut := 'F';
  Config.Configuration := 'Debug';
  Config.CleanFirst := False;
  Config.Category := 'Development';
  Config.Icon := 'fast';
  Config.AddProject('S:\work\Source\Modules\OvwPackages.groupproj', 'make', 'Packages principali');
  Config.AddProject('S:\work\Source\Modules\OvwModules.groupproj', 'make', 'Moduli applicazione');
  FConfigurations.Add(Config);

  // Normal Build
  Config := TBuildConfiguration.Create;
  Config.Name := 'Normal Build';
  Config.Description := 'Build completo con clean per rilascio';
  Config.Shortcut := 'N';
  Config.Configuration := 'Debug';
  Config.CleanFirst := True;
  Config.Category := 'Development';
  Config.Icon := 'build';
  Config.AddProject('S:\work\Source\Modules\OvwPackages.groupproj', 'Clean;Build', 'Packages principali');
  Config.AddProject('S:\work\Source\Modules\OvwModules.groupproj', 'Clean;Build', 'Moduli applicazione');
  FConfigurations.Add(Config);

  // Package Only
  Config := TBuildConfiguration.Create;
  Config.Name := 'Build Package';
  Config.Description := 'Compila solo i packages';
  Config.Shortcut := 'P';
  Config.Configuration := 'Debug';
  Config.Category := 'Components';
  Config.Icon := 'package';
  Config.AddProject('S:\work\Source\Modules\OvwPackages.groupproj', 'Clean;Build', 'Packages Delphi');
  FConfigurations.Add(Config);

  // Modules Only
  Config := TBuildConfiguration.Create;
  Config.Name := 'Build Modules';
  Config.Description := 'Compila solo i moduli applicazione';
  Config.Shortcut := 'M';
  Config.Configuration := 'Debug';
  Config.Category := 'Components';
  Config.Icon := 'module';
  Config.AddProject('S:\work\Source\Modules\OvwModules.groupproj', 'Clean;Build', 'Moduli applicazione');
  FConfigurations.Add(Config);

  // Services
  Config := TBuildConfiguration.Create;
  Config.Name := 'Build Services';
  Config.Description := 'Compila tutti i servizi';
  Config.Shortcut := 'S';
  Config.Configuration := 'Debug';
  Config.Category := 'Services';
  Config.Icon := 'service';
  Config.AddProject('s:\work\Source\WebServices\OvwServices\AppBosServices.dproj', 'make', 'Servizio AppBos');
  Config.AddProject('s:\work\Source\WebServices\OvwServices\BosServices.dproj', 'Clean;Build', 'Servizio ISAPI');
  FConfigurations.Add(Config);

  // Release Build
  Config := TBuildConfiguration.Create;
  Config.Name := 'Release Build';
  Config.Description := 'Build completo in modalità Release';
  Config.Shortcut := 'R';
  Config.Configuration := 'Release';
  Config.CleanFirst := True;
  Config.Category := 'Release';
  Config.Icon := 'release';
  Config.AddProject('S:\work\Source\Modules\OvwPackages.groupproj', 'Clean;Build', 'Packages Release');
  Config.AddProject('S:\work\Source\Modules\OvwModules.groupproj', 'Clean;Build', 'Moduli Release');
  FConfigurations.Add(Config);
end;

procedure TBuildConfigManager.AddConfiguration(Config: TBuildConfiguration);
begin
  FConfigurations.Add(Config);
end;

procedure TBuildConfigManager.RemoveConfiguration(Index: Integer);
begin
  if (Index >= 0) and (Index < FConfigurations.Count) then
    FConfigurations.Delete(Index);
end;

function TBuildConfigManager.GetConfiguration(Index: Integer): TBuildConfiguration;
begin
  Result := nil;
  if (Index >= 0) and (Index < FConfigurations.Count) then
    Result := FConfigurations[Index]
  else
    raise Exception.Create('Invalid Index');
end;

function TBuildConfigManager.GetConfigurationByName(const Name: string): TBuildConfiguration;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FConfigurations.Count - 1 do
  begin
    if SameText(FConfigurations[i].Name, Name) then
    begin
      Result := FConfigurations[i];
      Break;
    end;
  end;
end;

function TBuildConfigManager.GetConfigurationCount: Integer;
begin
  Result := FConfigurations.Count;
end;

procedure TBuildConfigManager.ResetToDefaults;
begin
  FConfigurations.Clear;
  CreateDefaultConfigurations;
  SaveConfigurations;
end;

end.
