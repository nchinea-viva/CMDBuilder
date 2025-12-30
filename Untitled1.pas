
{***************************************************************************}
{                                                                           }
{                             XML Data Binding                              }
{                                                                           }
{         Generated on: 24/06/2020 16:27:54                                 }
{       Generated from: C:\Users\Federico Caramella\Desktop\Untitled1.xml   }
{   Settings stored in: C:\Users\Federico Caramella\Desktop\Untitled1.xdb   }
{                                                                           }
{***************************************************************************}

unit Untitled1;

interface

uses Xml.xmldom, Xml.XMLDoc, Xml.XMLIntf;

type

{ Forward Decls }

  IXMLProjectType = interface;
  IXMLPropertyGroupType = interface;
  IXMLItemGroupType = interface;
  IXMLProjectsType = interface;
  IXMLProjectExtensionsType = interface;
  IXMLBorlandProjectType = interface;
  IXMLTargetType = interface;
  IXMLTargetTypeList = interface;
  IXMLMSBuildType = interface;
  IXMLCallTargetType = interface;
  IXMLImportType = interface;

{ IXMLProjectType }

  IXMLProjectType = interface(IXMLNode)
    ['{C563DE40-503C-40F7-8587-00F4B01C0EB6}']
    { Property Accessors }
    function Get_Xmlns: UnicodeString;
    function Get_PropertyGroup: IXMLPropertyGroupType;
    function Get_ItemGroup: IXMLItemGroupType;
    function Get_ProjectExtensions: IXMLProjectExtensionsType;
    function Get_Target: IXMLTargetTypeList;
    function Get_Import: IXMLImportType;
    procedure Set_Xmlns(Value: UnicodeString);
    { Methods & Properties }
    property Xmlns: UnicodeString read Get_Xmlns write Set_Xmlns;
    property PropertyGroup: IXMLPropertyGroupType read Get_PropertyGroup;
    property ItemGroup: IXMLItemGroupType read Get_ItemGroup;
    property ProjectExtensions: IXMLProjectExtensionsType read Get_ProjectExtensions;
    property Target: IXMLTargetTypeList read Get_Target;
    property Import: IXMLImportType read Get_Import;
  end;

{ IXMLPropertyGroupType }

  IXMLPropertyGroupType = interface(IXMLNode)
    ['{6E892232-0EA4-4FA8-9E6E-7141F38ADC03}']
    { Property Accessors }
    function Get_ProjectGuid: UnicodeString;
    procedure Set_ProjectGuid(Value: UnicodeString);
    { Methods & Properties }
    property ProjectGuid: UnicodeString read Get_ProjectGuid write Set_ProjectGuid;
  end;

{ IXMLItemGroupType }

  IXMLItemGroupType = interface(IXMLNodeCollection)
    ['{B2809211-7FD2-4886-BD12-87F89AEE8F82}']
    { Property Accessors }
    function Get_Projects(Index: Integer): IXMLProjectsType;
    { Methods & Properties }
    function Add: IXMLProjectsType;
    function Insert(const Index: Integer): IXMLProjectsType;
    property Projects[Index: Integer]: IXMLProjectsType read Get_Projects; default;
  end;

{ IXMLProjectsType }

  IXMLProjectsType = interface(IXMLNode)
    ['{92109BD0-3F30-4E0C-9B10-B8BB28B7EF4E}']
    { Property Accessors }
    function Get_Include: UnicodeString;
    function Get_Dependencies: UnicodeString;
    procedure Set_Include(Value: UnicodeString);
    procedure Set_Dependencies(Value: UnicodeString);
    { Methods & Properties }
    property Include: UnicodeString read Get_Include write Set_Include;
    property Dependencies: UnicodeString read Get_Dependencies write Set_Dependencies;
  end;

{ IXMLProjectExtensionsType }

  IXMLProjectExtensionsType = interface(IXMLNode)
    ['{F421E7DE-E46C-449C-87DD-EDDA462C0AB0}']
    { Property Accessors }
    function Get_BorlandPersonality: UnicodeString;
    function Get_BorlandProjectType: UnicodeString;
    function Get_BorlandProject: IXMLBorlandProjectType;
    procedure Set_BorlandPersonality(Value: UnicodeString);
    procedure Set_BorlandProjectType(Value: UnicodeString);
    { Methods & Properties }
    property BorlandPersonality: UnicodeString read Get_BorlandPersonality write Set_BorlandPersonality;
    property BorlandProjectType: UnicodeString read Get_BorlandProjectType write Set_BorlandProjectType;
    property BorlandProject: IXMLBorlandProjectType read Get_BorlandProject;
  end;

{ IXMLBorlandProjectType }

  IXMLBorlandProjectType = interface(IXMLNode)
    ['{A9A1F18E-374A-4A4E-AE63-153BCC06C48A}']
    { Property Accessors }
    function Get_DefaultPersonality: UnicodeString;
    procedure Set_DefaultPersonality(Value: UnicodeString);
    { Methods & Properties }
    property DefaultPersonality: UnicodeString read Get_DefaultPersonality write Set_DefaultPersonality;
  end;

{ IXMLTargetType }

  IXMLTargetType = interface(IXMLNode)
    ['{48FB1A55-A185-4DE4-A914-223953F503A7}']
    { Property Accessors }
    function Get_Name: UnicodeString;
    function Get_MSBuild: IXMLMSBuildType;
    function Get_CallTarget: IXMLCallTargetType;
    procedure Set_Name(Value: UnicodeString);
    { Methods & Properties }
    property Name: UnicodeString read Get_Name write Set_Name;
    property MSBuild: IXMLMSBuildType read Get_MSBuild;
    property CallTarget: IXMLCallTargetType read Get_CallTarget;
  end;

{ IXMLTargetTypeList }

  IXMLTargetTypeList = interface(IXMLNodeCollection)
    ['{9CE28225-A1AD-4EB0-A8F7-2A8926248E98}']
    { Methods & Properties }
    function Add: IXMLTargetType;
    function Insert(const Index: Integer): IXMLTargetType;

    function Get_Item(Index: Integer): IXMLTargetType;
    property Items[Index: Integer]: IXMLTargetType read Get_Item; default;
  end;

{ IXMLMSBuildType }

  IXMLMSBuildType = interface(IXMLNode)
    ['{AFCA4CEF-B868-4AE3-B719-98D336FF1847}']
    { Property Accessors }
    function Get_Projects: UnicodeString;
    function Get_Targets: UnicodeString;
    procedure Set_Projects(Value: UnicodeString);
    procedure Set_Targets(Value: UnicodeString);
    { Methods & Properties }
    property Projects: UnicodeString read Get_Projects write Set_Projects;
    property Targets: UnicodeString read Get_Targets write Set_Targets;
  end;

{ IXMLCallTargetType }

  IXMLCallTargetType = interface(IXMLNode)
    ['{ED265A8D-EAE9-4516-9F93-936F1571217E}']
    { Property Accessors }
    function Get_Targets: UnicodeString;
    procedure Set_Targets(Value: UnicodeString);
    { Methods & Properties }
    property Targets: UnicodeString read Get_Targets write Set_Targets;
  end;

{ IXMLImportType }

  IXMLImportType = interface(IXMLNode)
    ['{9D8B0F11-C44F-49C8-B0CE-3580906A0DEA}']
    { Property Accessors }
    function Get_Project: UnicodeString;
    function Get_Condition: UnicodeString;
    procedure Set_Project(Value: UnicodeString);
    procedure Set_Condition(Value: UnicodeString);
    { Methods & Properties }
    property Project: UnicodeString read Get_Project write Set_Project;
    property Condition: UnicodeString read Get_Condition write Set_Condition;
  end;

{ Forward Decls }

  TXMLProjectType = class;
  TXMLPropertyGroupType = class;
  TXMLItemGroupType = class;
  TXMLProjectsType = class;
  TXMLProjectExtensionsType = class;
  TXMLBorlandProjectType = class;
  TXMLTargetType = class;
  TXMLTargetTypeList = class;
  TXMLMSBuildType = class;
  TXMLCallTargetType = class;
  TXMLImportType = class;

{ TXMLProjectType }

  TXMLProjectType = class(TXMLNode, IXMLProjectType)
  private
    FTarget: IXMLTargetTypeList;
  protected
    { IXMLProjectType }
    function Get_Xmlns: UnicodeString;
    function Get_PropertyGroup: IXMLPropertyGroupType;
    function Get_ItemGroup: IXMLItemGroupType;
    function Get_ProjectExtensions: IXMLProjectExtensionsType;
    function Get_Target: IXMLTargetTypeList;
    function Get_Import: IXMLImportType;
    procedure Set_Xmlns(Value: UnicodeString);
  public
    procedure AfterConstruction; override;
  end;

{ TXMLPropertyGroupType }

  TXMLPropertyGroupType = class(TXMLNode, IXMLPropertyGroupType)
  protected
    { IXMLPropertyGroupType }
    function Get_ProjectGuid: UnicodeString;
    procedure Set_ProjectGuid(Value: UnicodeString);
  end;

{ TXMLItemGroupType }

  TXMLItemGroupType = class(TXMLNodeCollection, IXMLItemGroupType)
  protected
    { IXMLItemGroupType }
    function Get_Projects(Index: Integer): IXMLProjectsType;
    function Add: IXMLProjectsType;
    function Insert(const Index: Integer): IXMLProjectsType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLProjectsType }

  TXMLProjectsType = class(TXMLNode, IXMLProjectsType)
  protected
    { IXMLProjectsType }
    function Get_Include: UnicodeString;
    function Get_Dependencies: UnicodeString;
    procedure Set_Include(Value: UnicodeString);
    procedure Set_Dependencies(Value: UnicodeString);
  end;

{ TXMLProjectExtensionsType }

  TXMLProjectExtensionsType = class(TXMLNode, IXMLProjectExtensionsType)
  protected
    { IXMLProjectExtensionsType }
    function Get_BorlandPersonality: UnicodeString;
    function Get_BorlandProjectType: UnicodeString;
    function Get_BorlandProject: IXMLBorlandProjectType;
    procedure Set_BorlandPersonality(Value: UnicodeString);
    procedure Set_BorlandProjectType(Value: UnicodeString);
  public
    procedure AfterConstruction; override;
  end;

{ TXMLBorlandProjectType }

  TXMLBorlandProjectType = class(TXMLNode, IXMLBorlandProjectType)
  protected
    { IXMLBorlandProjectType }
    function Get_DefaultPersonality: UnicodeString;
    procedure Set_DefaultPersonality(Value: UnicodeString);
  end;

{ TXMLTargetType }

  TXMLTargetType = class(TXMLNode, IXMLTargetType)
  protected
    { IXMLTargetType }
    function Get_Name: UnicodeString;
    function Get_MSBuild: IXMLMSBuildType;
    function Get_CallTarget: IXMLCallTargetType;
    procedure Set_Name(Value: UnicodeString);
  public
    procedure AfterConstruction; override;
  end;

{ TXMLTargetTypeList }

  TXMLTargetTypeList = class(TXMLNodeCollection, IXMLTargetTypeList)
  protected
    { IXMLTargetTypeList }
    function Add: IXMLTargetType;
    function Insert(const Index: Integer): IXMLTargetType;

    function Get_Item(Index: Integer): IXMLTargetType;
  end;

{ TXMLMSBuildType }

  TXMLMSBuildType = class(TXMLNode, IXMLMSBuildType)
  protected
    { IXMLMSBuildType }
    function Get_Projects: UnicodeString;
    function Get_Targets: UnicodeString;
    procedure Set_Projects(Value: UnicodeString);
    procedure Set_Targets(Value: UnicodeString);
  end;

{ TXMLCallTargetType }

  TXMLCallTargetType = class(TXMLNode, IXMLCallTargetType)
  protected
    { IXMLCallTargetType }
    function Get_Targets: UnicodeString;
    procedure Set_Targets(Value: UnicodeString);
  end;

{ TXMLImportType }

  TXMLImportType = class(TXMLNode, IXMLImportType)
  protected
    { IXMLImportType }
    function Get_Project: UnicodeString;
    function Get_Condition: UnicodeString;
    procedure Set_Project(Value: UnicodeString);
    procedure Set_Condition(Value: UnicodeString);
  end;

{ Global Functions }

function GetProject(Doc: IXMLDocument): IXMLProjectType;
function LoadProject(const FileName: string): IXMLProjectType;
function NewProject: IXMLProjectType;

const
  TargetNamespace = 'http://schemas.microsoft.com/developer/msbuild/2003';

implementation

uses Xml.xmlutil;

{ Global Functions }

function GetProject(Doc: IXMLDocument): IXMLProjectType;
begin
  Result := Doc.GetDocBinding('Project', TXMLProjectType, TargetNamespace) as IXMLProjectType;
end;

function LoadProject(const FileName: string): IXMLProjectType;
begin
  Result := LoadXMLDocument(FileName).GetDocBinding('Project', TXMLProjectType, TargetNamespace) as IXMLProjectType;
end;

function NewProject: IXMLProjectType;
begin
  Result := NewXMLDocument.GetDocBinding('Project', TXMLProjectType, TargetNamespace) as IXMLProjectType;
end;

{ TXMLProjectType }

procedure TXMLProjectType.AfterConstruction;
begin
  RegisterChildNode('PropertyGroup', TXMLPropertyGroupType);
  RegisterChildNode('ItemGroup', TXMLItemGroupType);
  RegisterChildNode('ProjectExtensions', TXMLProjectExtensionsType);
  RegisterChildNode('Target', TXMLTargetType);
  RegisterChildNode('Import', TXMLImportType);
  FTarget := CreateCollection(TXMLTargetTypeList, IXMLTargetType, 'Target') as IXMLTargetTypeList;
  inherited;
end;

function TXMLProjectType.Get_Xmlns: UnicodeString;
begin
  Result := AttributeNodes['xmlns'].Text;
end;

procedure TXMLProjectType.Set_Xmlns(Value: UnicodeString);
begin
  SetAttribute('xmlns', Value);
end;

function TXMLProjectType.Get_PropertyGroup: IXMLPropertyGroupType;
begin
  Result := ChildNodes['PropertyGroup'] as IXMLPropertyGroupType;
end;

function TXMLProjectType.Get_ItemGroup: IXMLItemGroupType;
begin
  Result := ChildNodes['ItemGroup'] as IXMLItemGroupType;
end;

function TXMLProjectType.Get_ProjectExtensions: IXMLProjectExtensionsType;
begin
  Result := ChildNodes['ProjectExtensions'] as IXMLProjectExtensionsType;
end;

function TXMLProjectType.Get_Target: IXMLTargetTypeList;
begin
  Result := FTarget;
end;

function TXMLProjectType.Get_Import: IXMLImportType;
begin
  Result := ChildNodes['Import'] as IXMLImportType;
end;

{ TXMLPropertyGroupType }

function TXMLPropertyGroupType.Get_ProjectGuid: UnicodeString;
begin
  Result := ChildNodes['ProjectGuid'].Text;
end;

procedure TXMLPropertyGroupType.Set_ProjectGuid(Value: UnicodeString);
begin
  ChildNodes['ProjectGuid'].NodeValue := Value;
end;

{ TXMLItemGroupType }

procedure TXMLItemGroupType.AfterConstruction;
begin
  RegisterChildNode('Projects', TXMLProjectsType);
  ItemTag := 'Projects';
  ItemInterface := IXMLProjectsType;
  inherited;
end;

function TXMLItemGroupType.Get_Projects(Index: Integer): IXMLProjectsType;
begin
  Result := List[Index] as IXMLProjectsType;
end;

function TXMLItemGroupType.Add: IXMLProjectsType;
begin
  Result := AddItem(-1) as IXMLProjectsType;
end;

function TXMLItemGroupType.Insert(const Index: Integer): IXMLProjectsType;
begin
  Result := AddItem(Index) as IXMLProjectsType;
end;

{ TXMLProjectsType }

function TXMLProjectsType.Get_Include: UnicodeString;
begin
  Result := AttributeNodes['Include'].Text;
end;

procedure TXMLProjectsType.Set_Include(Value: UnicodeString);
begin
  SetAttribute('Include', Value);
end;

function TXMLProjectsType.Get_Dependencies: UnicodeString;
begin
  Result := ChildNodes['Dependencies'].Text;
end;

procedure TXMLProjectsType.Set_Dependencies(Value: UnicodeString);
begin
  ChildNodes['Dependencies'].NodeValue := Value;
end;

{ TXMLProjectExtensionsType }

procedure TXMLProjectExtensionsType.AfterConstruction;
begin
  RegisterChildNode('BorlandProject', TXMLBorlandProjectType);
  inherited;
end;

function TXMLProjectExtensionsType.Get_BorlandPersonality: UnicodeString;
begin
  Result := ChildNodes['Borland.Personality'].Text;
end;

procedure TXMLProjectExtensionsType.Set_BorlandPersonality(Value: UnicodeString);
begin
  ChildNodes['Borland.Personality'].NodeValue := Value;
end;

function TXMLProjectExtensionsType.Get_BorlandProjectType: UnicodeString;
begin
  Result := ChildNodes['Borland.ProjectType'].Text;
end;

procedure TXMLProjectExtensionsType.Set_BorlandProjectType(Value: UnicodeString);
begin
  ChildNodes['Borland.ProjectType'].NodeValue := Value;
end;

function TXMLProjectExtensionsType.Get_BorlandProject: IXMLBorlandProjectType;
begin
  Result := ChildNodes['BorlandProject'] as IXMLBorlandProjectType;
end;

{ TXMLBorlandProjectType }

function TXMLBorlandProjectType.Get_DefaultPersonality: UnicodeString;
begin
  Result := ChildNodes['Default.Personality'].Text;
end;

procedure TXMLBorlandProjectType.Set_DefaultPersonality(Value: UnicodeString);
begin
  ChildNodes['Default.Personality'].NodeValue := Value;
end;

{ TXMLTargetType }

procedure TXMLTargetType.AfterConstruction;
begin
  RegisterChildNode('MSBuild', TXMLMSBuildType);
  RegisterChildNode('CallTarget', TXMLCallTargetType);
  inherited;
end;

function TXMLTargetType.Get_Name: UnicodeString;
begin
  Result := AttributeNodes['Name'].Text;
end;

procedure TXMLTargetType.Set_Name(Value: UnicodeString);
begin
  SetAttribute('Name', Value);
end;

function TXMLTargetType.Get_MSBuild: IXMLMSBuildType;
begin
  Result := ChildNodes['MSBuild'] as IXMLMSBuildType;
end;

function TXMLTargetType.Get_CallTarget: IXMLCallTargetType;
begin
  Result := ChildNodes['CallTarget'] as IXMLCallTargetType;
end;

{ TXMLTargetTypeList }

function TXMLTargetTypeList.Add: IXMLTargetType;
begin
  Result := AddItem(-1) as IXMLTargetType;
end;

function TXMLTargetTypeList.Insert(const Index: Integer): IXMLTargetType;
begin
  Result := AddItem(Index) as IXMLTargetType;
end;

function TXMLTargetTypeList.Get_Item(Index: Integer): IXMLTargetType;
begin
  Result := List[Index] as IXMLTargetType;
end;

{ TXMLMSBuildType }

function TXMLMSBuildType.Get_Projects: UnicodeString;
begin
  Result := AttributeNodes['Projects'].Text;
end;

procedure TXMLMSBuildType.Set_Projects(Value: UnicodeString);
begin
  SetAttribute('Projects', Value);
end;

function TXMLMSBuildType.Get_Targets: UnicodeString;
begin
  Result := AttributeNodes['Targets'].Text;
end;

procedure TXMLMSBuildType.Set_Targets(Value: UnicodeString);
begin
  SetAttribute('Targets', Value);
end;

{ TXMLCallTargetType }

function TXMLCallTargetType.Get_Targets: UnicodeString;
begin
  Result := AttributeNodes['Targets'].Text;
end;

procedure TXMLCallTargetType.Set_Targets(Value: UnicodeString);
begin
  SetAttribute('Targets', Value);
end;

{ TXMLImportType }

function TXMLImportType.Get_Project: UnicodeString;
begin
  Result := AttributeNodes['Project'].Text;
end;

procedure TXMLImportType.Set_Project(Value: UnicodeString);
begin
  SetAttribute('Project', Value);
end;

function TXMLImportType.Get_Condition: UnicodeString;
begin
  Result := AttributeNodes['Condition'].Text;
end;

procedure TXMLImportType.Set_Condition(Value: UnicodeString);
begin
  SetAttribute('Condition', Value);
end;

end.