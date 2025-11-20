unit BuilderUtils;

interface

uses
  Windows, System.SysUtils, System.Classes, System.Types, LbCipher,
  Winapi.ShellAPI, System.UITypes, System.IOUtils, DECCipher, DECHash, DECFmt,
  DECUtil;

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

  TOtnEncryptionMode = (emAes);
  TOtnEncryptionParams = record
    CipherClass: TDECCipherClass;
    CipherMode: TCipherMode;
    HashClass: TDECHashClass;
    TextFormat: TDECFormatClass;
    KDFIndex: LongWord;
  end;


  TRecConfig = Class
  Private
    FPathBOS    : String;
    FPathAPPBOS : String;
    FPathAlone  : String;
    FOvwTools   : String;
    FXlsConv    : String;
    FCaseStudio : String;
    FSqlServer: String;
    class var FInstance: TRecConfig;
    Constructor Create(APathBOS, APathAPPBOS, APathAlone, AOvwTools, AXlsConv, ACaseStudio, ASqlServer: String); Reintroduce;
  public

    Destructor Destroy;
    class function GetInstance: TRecConfig;overload;
    class function GetInstance(APathBOS, APathAPPBOS, APathAlone, AOvwTools, AXlsConv, ACaseStudio, ASqlServer: String): TRecConfig; overload;
    function SetValues(APathBOS, APathAPPBOS, APathAlone, AOvwTools, AXlsConv, ACaseStudio, ASqlServer: String): TRecConfig;
    class procedure ReleaseInstance;

    Property PathBOS    : String read FPathBOS write FPathBOS;
    Property PathAPPBOS : String read FPathAPPBOS write FPathAPPBOS;
    Property PathAlone  : String read FPathAlone write FPathAlone;
    Property OvwTools   : String read FOvwTools write FOvwTools;
    Property XlsConv    : String read FXlsConv write FXlsConv;
    Property CaseStudio : String read FCaseStudio write FCaseStudio;
    Property SqlServer  : String read FSqlServer write FSqlServer;
  end;

  function KillProcessByName(const ProcessName: string): Boolean;
  function GetFileVersion(const FileName: string): TFileVersionInfo;
  function Encode64(S: string): string;
  function ApplySHA1Hash(sMessage: string): string;
  function RunAndWait(const AppName: string): Boolean;
  function GetDocumentsPath: string;
  function Encrypt(const AText, APassword: string; AMode: TOtnEncryptionMode): string;
  function Decrypt(const AText, APassword: string; AMode: TOtnEncryptionMode; ReturnEmptyStringifError: Boolean = False): string;

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

function GetEncDecParams(AMode: TOtnEncryptionMode): TOtnEncryptionParams;
begin
  case AMode of
    emAes:
      begin
        Result.CipherClass := TCipher_Rijndael;
        Result.CipherMode := cmCBCx;
        Result.HashClass := THash_Whirlpool;
        Result.TextFormat := TFormat_Mime64;
        Result.KDFIndex := 1;
      end;
  else
    raise Exception.Create('Unhandled encryption mode "' + IntToStr(Integer(AMode)) + '"');
  end;
end;


function Encrypt(const AText, APassword: string; AMode: TOtnEncryptionMode): string;
var
  Params: TOtnEncryptionParams;
  Cipher: TDECCipher;
  Salt, Data, Pass: Binary;
begin
  Params := GetEncDecParams(AMode);
  Cipher := ValidCipher(Params.CipherClass).Create;
  try
    Salt := RandomBinary(16);
    Pass := ValidHash(Params.HashClass).KDFx(APassword[1], Length(APassword) * SizeOf(APassword[1]), Salt[1], Length(Salt), Cipher.Context.KeySize, TFormat_Copy, Params.KDFIndex);
    Cipher.Mode := Params.CipherMode;
    Cipher.Init(Pass);
    SetLength(Data, Length(AText) * SizeOf(AText[1]));
    Cipher.Encode(AText[1], Data[1], Length(Data));
    Result := ValidFormat(Params.TextFormat).Encode(Salt + Data + Cipher.CalcMAC);
  finally
    Cipher.Free;
    ProtectBinary(Salt);
    ProtectBinary(Data);
    ProtectBinary(Pass);
  end;
end;

function Decrypt(const AText, APassword: string; AMode: TOtnEncryptionMode; ReturnEmptyStringifError: Boolean = False): string;
var
  Params: TOtnEncryptionParams;
  Cipher: TDECCipher;
  Salt, Data, Check, Pass: Binary;
  Len: Integer;
  procedure __ManageError();
  begin
    if ReturnEmptyStringifError then
      Result:= ''
    else
      raise Exception.Create('Invalid Decryption Password');
  end;
begin
  Params := GetEncDecParams(AMode);
  Cipher := ValidCipher(Params.CipherClass).Create;
  try
    Try
      Salt := ValidFormat(Params.TextFormat).Decode(AText);
      Len := Length(Salt) - 16 - Cipher.Context.BufferSize;
      Data := System.Copy(Salt, 17, Len);
      Check := System.Copy(Salt, Len + 17, Cipher.Context.BufferSize);
      SetLength(Salt, 16);
      Pass := ValidHash(Params.HashClass).KDFx(APassword[1], Length(APassword) * SizeOf(APassword[1]), Salt[1], Length(Salt), Cipher.Context.KeySize, TFormat_Copy, Params.KDFIndex);
      Cipher.Mode := Params.CipherMode;
      Cipher.Init(Pass);
      SetLength(Result, Len div SizeOf(AText[1]));
      Cipher.Decode(Data[1], Result[1], Len);
      if Check <> Cipher.CalcMAC then
        __ManageError;
    Except
      On E: Exception Do
      begin
        __ManageError;
      end;
    End;
  finally
    Cipher.Free;
    ProtectBinary(Salt);
    ProtectBinary(Data);
    ProtectBinary(Check);
    ProtectBinary(Pass);
  end;
end;

{ TRecConfig }

constructor TRecConfig.Create(APathBOS, APathAPPBOS, APathAlone, AOvwTools,
  AXlsConv, ACaseStudio, ASqlServer: String);
begin
  Inherited Create;
  FPathBOS    := APathBOS;
  FPathAPPBOS := APathAPPBOS;
  FPathAlone  := APathAlone;
  FOvwTools   := AOvwTools;
  FXlsConv    := AXlsConv;
  FCaseStudio := ACaseStudio;
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
    FInstance := TRecConfig.Create('', '', '', '', '', '', '');
  Result := FInstance;
end;

class function TRecConfig.GetInstance(APathBOS, APathAPPBOS, APathAlone, AOvwTools, AXlsConv, ACaseStudio, ASqlServer: String): TRecConfig;
begin
  if FInstance = nil then
    FInstance := TRecConfig.Create(APathBOS, APathAPPBOS, APathAlone, AOvwTools, AXlsConv, ACaseStudio, ASqlServer);
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
  AOvwTools, AXlsConv, ACaseStudio, ASqlServer: String): TRecConfig;
begin
  FPathBOS    := APathBOS;
  FPathAPPBOS := APathAPPBOS;
  FPathAlone  := APathAlone;
  FOvwTools   := AOvwTools;
  FXlsConv    := AXlsConv;
  FCaseStudio := ACaseStudio;
  FSqlServer  := ASqlServer;
end;



end.
