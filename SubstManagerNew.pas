unit SubstManagerNew;

interface

uses
  Windows, SysUtils, Classes;

type
  TSubstManager = class
  private
    function IsValidDriveLetter(const Letter: Char): Boolean;
    function DriveExists(const DriveLetter: Char): Boolean;
  public
    // Crea un drive virtuale (equivalente a SUBST X: percorso)
    function CreateVirtualDrive(const DriveLetter: Char; const Path: string): Boolean;

    // Rimuove un drive virtuale (equivalente a SUBST X: /D)
    function RemoveVirtualDrive(const DriveLetter: Char): Boolean;

    // Ottiene il percorso associato a un drive virtuale
    function GetVirtualDrivePath(const DriveLetter: Char): string;

    // Lista tutti i drive virtuali attivi
    function ListVirtualDrives: TStringList;

    // Verifica se un drive è virtuale (creato con SUBST)
    function IsVirtualDrive(const DriveLetter: Char): Boolean;
  end;

implementation

{ TSubstManager }

function TSubstManager.IsValidDriveLetter(const Letter: Char): Boolean;
begin
  Result := CharInSet(UpperCase(Letter)[1], ['A'..'Z']);
end;

function TSubstManager.DriveExists(const DriveLetter: Char): Boolean;
var
  DrivesMask: DWORD;
  DriveIndex: Integer;
begin
  Result := False;
  DrivesMask := GetLogicalDrives;
  DriveIndex := Ord(UpperCase(DriveLetter)[1]) - Ord('A');
  if (DriveIndex >= 0) and (DriveIndex <= 25) then
    Result := (DrivesMask and (1 shl DriveIndex)) <> 0;
end;

function TSubstManager.CreateVirtualDrive(const DriveLetter: Char;
  const Path: string): Boolean;
var
  DriveName: string;
  FullPath: string;
  LastError: DWORD;
begin
  Result := False;

  // Verifica validità lettera drive
  if not IsValidDriveLetter(DriveLetter) then
    Exit;

  // Verifica che il percorso esista
  if not DirectoryExists(Path) then
    Exit;

  // Verifica che il drive non esista già
  if DriveExists(DriveLetter) then
    Exit;

  DriveName := UpperCase(DriveLetter) + ':';

  // Formatta correttamente il percorso
  FullPath := ExpandFileName(Path);

  // Rimuovi slash finale se presente
  if (Length(FullPath) > 1) and (FullPath[Length(FullPath)] = '\') then
    Delete(FullPath, Length(FullPath), 1);

  // Per percorsi locali, aggiungi il prefisso \??\
  if (Length(FullPath) >= 3) and (FullPath[2] = ':') and (FullPath[3] = '\') then
    FullPath := '\??\' + FullPath;

  // Crea il mapping del drive
  Result := DefineDosDevice(DDD_RAW_TARGET_PATH, PChar(DriveName), PChar(FullPath));

  // Se fallisce, prova senza il prefisso
  if not Result then
  begin
    LastError := GetLastError;
    if LastError = ERROR_INVALID_PARAMETER then
    begin
      // Riprova senza prefisso
      FullPath := ExpandFileName(Path);
      if (Length(FullPath) > 1) and (FullPath[Length(FullPath)] = '\') then
        Delete(FullPath, Length(FullPath), 1);
      Result := DefineDosDevice(DDD_RAW_TARGET_PATH, PChar(DriveName), PChar(FullPath));
    end;
  end;
end;

function TSubstManager.RemoveVirtualDrive(const DriveLetter: Char): Boolean;
var
  DriveName: string;
begin
  Result := False;

  // Verifica validità lettera drive
  if not IsValidDriveLetter(DriveLetter) then
    Exit;

  // Verifica che il drive esista
  if not DriveExists(DriveLetter) then
    Exit;

  DriveName := UpperCase(DriveLetter) + ':';

  // Rimuove il mapping del drive
  Result := DefineDosDevice(DDD_REMOVE_DEFINITION, PChar(DriveName), nil);
end;

function TSubstManager.GetVirtualDrivePath(const DriveLetter: Char): string;
var
  DriveName: string;
  Buffer: array[0..MAX_PATH-1] of Char;
  ReturnLength: DWORD;
begin
  Result := '';

  if not IsValidDriveLetter(DriveLetter) then
    Exit;

  DriveName := UpperCase(DriveLetter) + ':';

  ReturnLength := QueryDosDevice(PChar(DriveName), Buffer, SizeOf(Buffer));
  if ReturnLength > 0 then
  begin
    Result := string(Buffer);
    // Rimuove il prefisso \??\
    if Pos('\??\', Result) = 1 then
      Delete(Result, 1, 4);
  end;
end;

function TSubstManager.ListVirtualDrives: TStringList;
var
  Drive: Char;
  Path: string;
begin
  Result := TStringList.Create;

  for Drive := 'A' to 'Z' do
  begin
    if IsVirtualDrive(Drive) then
    begin
      Path := GetVirtualDrivePath(Drive);
      if Path <> '' then
        Result.Add(Drive + ': -> ' + Path);
    end;
  end;
end;

function TSubstManager.IsVirtualDrive(const DriveLetter: Char): Boolean;
var
  DriveName: string;
  DriveType: UINT;
  Path: string;
begin
  Result := False;

  if not DriveExists(DriveLetter) then
    Exit;

  DriveName := UpperCase(DriveLetter) + ':\';
  DriveType := GetDriveType(PChar(DriveName));

  // Se il tipo è DRIVE_NO_ROOT_DIR, potrebbe essere un SUBST
  if DriveType = DRIVE_NO_ROOT_DIR then
  begin
    Path := GetVirtualDrivePath(DriveLetter);
    Result := (Path <> '') and DirectoryExists(Path);
  end;
end;

end.
