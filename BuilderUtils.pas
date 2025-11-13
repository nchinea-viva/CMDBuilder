unit BuilderUtils;

interface

uses
  Windows, System.SysUtils, System.Classes, System.Types, LbCipher,
  Winapi.ShellAPI, System.UITypes, System.IOUtils;

const
  DBT_DEVICEARRIVAL = $8000;
  DBT_DEVICEREMOVECOMPLETE = $8004;
  DBT_DEVTYP_VOLUME = $00000002;
  CODES64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

type
  TFileVersionInfo = record
    Major: Word;
    Minor: Word;
    Release: Word;
    Build: Word;
    CompanyName: string;
    FileDescription: string;
    FileVersion: string;
    ProductName: string;
    ProductVersion: string;
    Copyright: string;
  end;
  TBuildType = (btFastBuild, btNormalBuild, btPackage, btModules, btAppBos,
                btStandAlone, btIsapi, btBPL, btNoIsapi, btBOSBase, btBOSBaseUI);

  TLogMessageType = (lmtInfo, lmtWarning, lmtError, lmtSuccess, lmtDrive,
                     lmtSvnAdded, lmtSvnDeleted, lmtSvnUpdated, lmtSvnConflict,
                     lmtSvnMerged, lmtSvnExisted, lmtSvnReplaced);

  PDEV_BROADCAST_VOLUME = ^DEV_BROADCAST_VOLUME;
  DEV_BROADCAST_VOLUME = packed record
    dbcv_size: DWORD;
    dbcv_devicetype: DWORD;
    dbcv_reserved: DWORD;
    dbcv_unitmask: DWORD;
    dbcv_flags: WORD;
  end;

  TCompilePath = Array of String;

  TRecConfig = Class
  Private
    FPathBOS    : String;
    FPathAPPBOS : String;
    FPathAlone  : String;
    FOvwTools  : String;
    FXlsConv   : String;
    FSqlServer: String;
    class var FInstance: TRecConfig;
    Constructor Create(APathBOS, APathAPPBOS, APathAlone, AOvwTools, AXlsConv, ASqlServer: String); Reintroduce;
  public

    Destructor Destroy;
    class function GetInstance: TRecConfig;overload;
    class function GetInstance(APathBOS, APathAPPBOS, APathAlone, AOvwTools, AXlsConv, ASqlServer: String): TRecConfig; overload;
    function SetValues(APathBOS, APathAPPBOS, APathAlone, AOvwTools, AXlsConv, ASqlServer: String): TRecConfig;
    class procedure ReleaseInstance;

    Property PathBOS    : String read FPathBOS write FPathBOS;
    Property PathAPPBOS : String read FPathAPPBOS write FPathAPPBOS;
    Property PathAlone  : String read FPathAlone write FPathAlone;
    Property OvwTools   : String read FOvwTools write FOvwTools;
    Property XlsConv    : String read FXlsConv write FXlsConv;
    Property SqlServer  : String read FSqlServer write FSqlServer;
  end;

  function KillProcessByName(const ProcessName: string): Boolean;
  function GetFileVersion(const FileName: string): TFileVersionInfo;
  function Encode64(S: string): string;
  function ApplySHA1Hash(sMessage: string): string;
  function RunAndWait(const AppName: string): Boolean;
  function GetDocumentsPath: string;

implementation

function RunAndWait(const AppName: string): Boolean;
begin
  Result := ShellExecute(0, 'open', PChar(AppName), '', nil, SW_SHOWNORMAL) > 32;
end;

function GetDocumentsPath: string;
begin
  Result := TPath.GetDocumentsPath;
end;

function Encode64(S: string): string;
var
  i: Integer;
  a: Integer;
  x: Integer;
  b: Integer;
begin
  Result := '';
  a := 0;
  b := 0;
  for i := 1 to Length(s) do
  begin
    x := Ord(s[i]);
    b := b * 256 + x;
    a := a + 8;
    while a >= 6 do
    begin
      a := a - 6;
      x := b div (1 shl a);
      b := b mod (1 shl a);
      Result := Result + Codes64[x + 1];
    end;
  end;
  if a > 0 then
  begin
    x := b shl (6 - a);
    Result := Result + Codes64[x + 1];
  end;
end;

function ApplySHA1Hash(sMessage: string): string;
var
  TempResult: TSHA1Digest;
  bLoop: byte;
  lEncoding: TEncoding;
  lBytes: TBytes;
begin
  lEncoding := TEncoding.ANSI;
  lBytes := lEncoding.GetBytes(sMessage);
  FillChar(Result, SizeOf(Result), #0);
  FillChar(TempResult, SizeOf(TempResult), #0);
  TSHA1.StringHashSHA1(TempResult, lBytes);
  for bLoop := 0 to 19 do
    Result := Result + chr(TempResult[bLoop]);
  Result := Encode64(Result);
end;

function KillProcessByName(const ProcessName: string): Boolean;
var
  Command: string;
begin
  Command := 'taskkill /f /im ' + ProcessName;
  Result := WinExec(PAnsiChar(AnsiString(Command)), SW_HIDE) > 31;
end;

function GetFileVersion(const FileName: string): TFileVersionInfo;
var
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  FI: PVSFixedFileInfo;
  VerSize: DWORD;

  function GetStringFileInfo(const Key: string): string;
  var
    Buffer: PChar;
    BufSize: DWORD;
  begin
    Result := '';
    if VerQueryValue(VerBuf, PChar('\StringFileInfo\040904B0\' + Key),
                     Pointer(Buffer), BufSize) then
      Result := Buffer;
  end;

begin
  FillChar(Result, SizeOf(Result), 0);

  InfoSize := GetFileVersionInfoSize(PChar(FileName), Wnd);
  if InfoSize = 0 then Exit;

  GetMem(VerBuf, InfoSize);
  try
    if not GetFileVersionInfo(PChar(FileName), Wnd, InfoSize, VerBuf) then Exit;

    // Ottieni versione numerica
    if VerQueryValue(VerBuf, '\', Pointer(FI), VerSize) then
    begin
      Result.Major := LongRec(FI.dwFileVersionMS).Hi;
      Result.Minor := LongRec(FI.dwFileVersionMS).Lo;
      Result.Release := LongRec(FI.dwFileVersionLS).Hi;
      Result.Build := LongRec(FI.dwFileVersionLS).Lo;
    end;

    // Ottieni informazioni stringa
    Result.CompanyName := GetStringFileInfo('CompanyName');
    Result.FileDescription := GetStringFileInfo('FileDescription');
    Result.FileVersion := GetStringFileInfo('FileVersion');
    Result.ProductName := GetStringFileInfo('ProductName');
    Result.ProductVersion := GetStringFileInfo('ProductVersion');
    Result.Copyright := GetStringFileInfo('LegalCopyright');

  finally
    FreeMem(VerBuf, InfoSize);
  end;
end;

{ TRecConfig }

constructor TRecConfig.Create(APathBOS, APathAPPBOS, APathAlone, AOvwTools,
  AXlsConv, ASqlServer: String);
begin
  Inherited Create;
  FPathBOS    := APathBOS;
  FPathAPPBOS := APathAPPBOS;
  FPathAlone  := APathAlone;
  FOvwTools   := AOvwTools;
  FXlsConv    := AXlsConv;
  FSqlServer  := ASqlServer;
end;

destructor TRecConfig.Destroy;
begin
  FInstance := nil;
  inherited Destroy;
end;

class function TRecConfig.GetInstance: TRecConfig;
begin
  if FInstance = nil then
    FInstance := TRecConfig.Create('', '', '', '', '', '');
  Result := FInstance;
end;

class function TRecConfig.GetInstance(APathBOS, APathAPPBOS, APathAlone, AOvwTools, AXlsConv, ASqlServer: String): TRecConfig;
begin
  if FInstance = nil then
    FInstance := TRecConfig.Create(APathBOS, APathAPPBOS, APathAlone, AOvwTools, AXlsConv, ASqlServer);
  Result := FInstance;
end;

class procedure TRecConfig.ReleaseInstance;
begin
  if FInstance <> nil then
  begin
    FInstance.Free;
    FInstance := nil;
  end;
end;

function TRecConfig.SetValues(APathBOS, APathAPPBOS, APathAlone,
  AOvwTools, AXlsConv, ASqlServer: String): TRecConfig;
begin
  FPathBOS    := APathBOS;
  FPathAPPBOS := APathAPPBOS;
  FPathAlone  := APathAlone;
  FOvwTools   := AOvwTools;
  FXlsConv    := AXlsConv;
  FSqlServer  := ASqlServer;
end;

end.
