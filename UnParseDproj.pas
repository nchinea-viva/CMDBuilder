unit UnParseDproj;

interface

uses
  System.Sysutils,
  Winapi.Ole2,
  Xml.XMLIntf,
  Xml.XMLDoc;

type

  TDprojParser = class
    private
      FXMLDocument: IXMLDocument;
      FDprojFile: string;
      FVersionString: string;
      FMajor: string;
      FMinor: string;
      FRelease: string;
      FBuild: string;
      procedure SetDprojFile(const Value: string);
      procedure SetVersionString(const Value: string);
    public
      property DprojFile: string read FDprojFile write SetDprojFile;
      property Major: string read FMajor write FMajor;
      property Minor: string read FMinor write FMinor;
      property Release: string read FRelease write FRelease;
      property Build: string read FBuild write FBuild;
      property VersionString: string read FVersionString write SetVersionString;
      procedure ChangeVersion(AdditionalInfo: string);
      constructor Create;
      destructor Destroy; override;
  end;

implementation

{ TDprojParser }

procedure TDprojParser.ChangeVersion(AdditionalInfo: string);
var
  Project, Node, VerInfo_Keys ,
  VerInfo_MinorVer,
  VerInfo_MajorVer,
  VerInfo_Release,
  VerInfo_Build : IXMLNode;
  I, J, K: Integer;
  Keys_String: String;
  Keys : TArray<string>;
  Version: TArray<string>;
begin
  try
    FXMLDocument.LoadFromFile(DprojFile);
    Project := FXMLDocument.ChildNodes.First;
    J := Project.ChildNodes.Count - 1;
    for I := 0 to J do
    begin
      Node := Project.ChildNodes.Nodes[I];
      VerInfo_Keys := Node.ChildNodes.FindNode('VerInfo_Keys');
      if VerInfo_Keys <> nil then
        begin
        Keys_String := VerInfo_Keys.NodeValue;
        Keys := Keys_String.Split([';']);
        for K := 0 to Length(Keys) - 1  do
          begin
            Version := Keys[K].Split(['=']);
            if Version[0]= 'FileVersion' then
              Keys[K] := 'FileVersion='+FVersionString;
            if Version[0]= 'ProductVersion' then
              Keys[K] := 'ProductVersion='+FVersionString;
            if Version[0]= 'ProductName' then
            begin
              if AdditionalInfo <> '' then
                Keys[K] := 'ProductName=BOS ' + AdditionalInfo + ' Compiled in Date: ' + DateToStr(Now);
            end;
          end;
        Keys_String := '';
        for K := 0 to Length(Keys) - 1 do
          Keys_String := Keys_String + Keys[K] + ';';
        Keys_String := Keys_String.Substring(0,Keys_String.Length -1);
        VerInfo_Keys.NodeValue := Keys_String;
        end;

      VerInfo_MajorVer := Node.ChildNodes.FindNode('VerInfo_MajorVer');
      if VerInfo_MajorVer <> nil then
      begin
        VerInfo_MajorVer.NodeValue := Major;
      end;
      VerInfo_MinorVer := Node.ChildNodes.FindNode('VerInfo_MinorVer');
      if VerInfo_MinorVer <> nil then
      begin
        VerInfo_MinorVer.NodeValue := Minor;
      end;
      VerInfo_Release := Node.ChildNodes.FindNode('VerInfo_Release');
      if VerInfo_Release <> nil then
      begin
        VerInfo_Release.NodeValue := Release;
      end;
      VerInfo_Build := Node.ChildNodes.FindNode('VerInfo_Build');
      if VerInfo_Build <> nil then
      begin
        VerInfo_Build.NodeValue := Build;
      end;
    end;



    FXMLDocument.SaveToFile(Dprojfile);
  except
  end;
end;

constructor TDprojParser.Create;
begin
  FXMLDocument := TXMLDocument.Create(nil);
  FXMLDocument.ParseOptions := FXMLDocument.ParseOptions+[poPreserveWhiteSpace];
end;

destructor TDprojParser.Destroy;
begin
end;

procedure TDprojParser.SetDprojFile(const Value: string);
begin
  FDprojFile := Value;
end;

procedure TDprojParser.SetVersionString(const Value: string);
begin
  FVersionString := Value;
end;

initialization
  CoInitialize(nil);

end.
