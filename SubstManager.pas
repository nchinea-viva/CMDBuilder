unit SubstManager;

interface

uses
  Windows, SysUtils, Classes;

type
  TSubstDriveInfo = record
    DriveLetter: Char;
    TargetPath: string;
  end;


type
  TSubstManager = class
  private
    function IsValidDriveLetter(const Letter: Char): Boolean;
    function DriveExists(const DriveLetter: Char): Boolean;
    function ExecuteCommandAndGetOutput(const Command: string): string;
    function ParseSubstOutput(const Output: string): TArray<TSubstDriveInfo>;
  public
    function CreateVirtualDrive(const DriveLetter: Char; const Path: string): Boolean;
    function RemoveVirtualDrive(const DriveLetter: Char): Boolean;
    function GetVirtualDrivePath(const DriveLetter: Char): string;
    function ListVirtualDrives: TStringList;
    function IsVirtualDrive(const DriveLetter: Char): Boolean;

    function CreaDriveConSubst(const ADriveLetter: Char; APath: string): Boolean;
    function RimuoviDriveConSubst(const Lettera: string): Boolean;
    function GetSubstDrivesList: TArray<TSubstDriveInfo>;
    Procedure GetSubstDrivesAsStrings(var aDriveList: TStringList);
    function GetSubstDrivesAsStrings2: TStringList;
    function IsSubstDrive(const DriveLetter: string; out TargetPath: string): Boolean;
    function GetSubstDrivePath(const DriveLetter: Char): string;
  end;

implementation

uses
  System.Generics.Collections;
{ TSubstManager }

function TSubstManager.RimuoviDriveConSubst(const Lettera: string): Boolean;
var
  Comando: string;
  ExitCode: DWORD;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  Result := False;

  Comando := Format('cmd.exe /c subst %s: /d', [UpperCase(Lettera)]);

  FillChar(StartupInfo, SizeOf(StartupInfo), 0);
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE;

  if CreateProcess(nil, PChar(Comando), nil, nil, False, 0, nil, nil,
                   StartupInfo, ProcessInfo) then
  begin
    try
      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);

      if GetExitCodeProcess(ProcessInfo.hProcess, ExitCode) then
        Result := (ExitCode = 0);
    finally
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
    end;
  end;
end;

function TSubstManager.IsSubstDrive(const DriveLetter: string; out TargetPath: string): Boolean;
var
  DriveType: UINT;
  Buffer: array[0..MAX_PATH] of Char;
  ReturnLength: DWORD;
  DeviceName: string;
begin
  Result := False;
  TargetPath := '';

  if Length(DriveLetter) < 2 then Exit;

  // Verifica il tipo di drive
  DriveType := GetDriveType(PChar(DriveLetter + '\'));

  if DriveType = DRIVE_FIXED then
  begin
    FillChar(Buffer, SizeOf(Buffer), 0);
    ReturnLength := QueryDosDevice(PChar(Copy(DriveLetter, 1, 2)),
                                   Buffer, MAX_PATH);

    if ReturnLength > 0 then
    begin
      DeviceName := string(Buffer);

      // Se il target inizia con \??\, è un SUBST
      if Pos('\??\', DeviceName) = 1 then
      begin
        Result := True;
        TargetPath := Copy(DeviceName, 5, Length(DeviceName) - 4);
      end;
    end;
  end;
end;

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


function TSubstManager.ExecuteCommandAndGetOutput(const Command: string): string;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  SecurityAttr: TSecurityAttributes;
  hReadPipe, hWritePipe: THandle;
//  Buffer: array[0..4095] of AnsiChar;
//  BytesRead: DWORD;
  Output: AnsiString;
begin
  Result := '';

  SecurityAttr.nLength := SizeOf(SecurityAttr);
  SecurityAttr.bInheritHandle := True;
  SecurityAttr.lpSecurityDescriptor := nil;

  if not CreatePipe(hReadPipe, hWritePipe, @SecurityAttr, 0) then
    Exit;

  try
    FillChar(StartupInfo, SizeOf(StartupInfo), 0);
    StartupInfo.cb := SizeOf(StartupInfo);
    // Esegui il comando
    if CreateProcess(nil, PChar(Command), nil, nil, True, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
    try
      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);

      Result := string(Output);

    finally
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
    end;

  finally
    if hReadPipe <> 0 then CloseHandle(hReadPipe);
    if hWritePipe <> 0 then CloseHandle(hWritePipe);
  end;

end;

function TSubstManager.CreateVirtualDrive(const DriveLetter: Char;
  const Path: string): Boolean;
var
  DriveName: string;
  FullPath: string;
begin
  Result := False;

  if not IsValidDriveLetter(DriveLetter) then
    Exit;

  if not DirectoryExists(Path) then
    Exit;

  if DriveExists(DriveLetter) then
    Exit;

  DriveName := UpperCase(DriveLetter) + ':';
  FullPath := ExpandFileName(Path);

  Result := DefineDosDevice(DDD_RAW_TARGET_PATH, PChar(DriveName), PChar(FullPath));
end;

function TSubstManager.CreaDriveConSubst(const ADriveLetter: Char; APath: string): Boolean;
var
  Command: string;
  Output: string;
begin
  if not DirectoryExists(APath) then
  begin
    Result := False;
    Exit;
  end;

  Command := Format('cmd.exe /c subst %s: "%s"', [UpCase(ADriveLetter), APath]);
  Output := ExecuteCommandAndGetOutput(Command);
  Result := Trim(Output) = '';
end;


function TSubstManager.RemoveVirtualDrive(const DriveLetter: Char): Boolean;
var
  DriveName: string;
begin
  Result := False;

  if not IsValidDriveLetter(DriveLetter) then
    Exit;

  if not DriveExists(DriveLetter) then
    Exit;

  DriveName := UpperCase(DriveLetter) + ':';

  Result := DefineDosDevice(DDD_REMOVE_DEFINITION, PChar(DriveName), nil);
end;

function TSubstManager.GetSubstDrivePath(const DriveLetter: Char): string;
var
  DrivesList: TArray<TSubstDriveInfo>;
  i: Integer;
begin
  Result := '';
  DrivesList := GetSubstDrivesList;

  for i := 0 to High(DrivesList) do
  begin
    if UpCase(DrivesList[i].DriveLetter) = UpCase(DriveLetter) then
    begin
      Result := DrivesList[i].TargetPath;
      Break;
    end;
  end;
end;

Procedure TSubstManager.GetSubstDrivesAsStrings(var aDriveList: TStringList);
var
  Drives: array[0..255] of Char;
  Drive: string;
  Target: array[0..MAX_PATH] of Char;
  i: Integer;
begin
  GetLogicalDriveStrings(SizeOf(Drives), Drives);

  i := 0;
  while Drives[i] <> #0 do
  begin
    Drive := PChar(@Drives[i]);
    Drive := Copy(Drive, 1, 2); // Es: "C:"

    if QueryDosDevice(PChar(Drive), Target, SizeOf(Target)) > 0 then
    begin
      // Se inizia con "\??\" è probabilmente un SUBST
      if Pos('\??\', string(Target)) = 1 then
      begin
        aDriveList.Add(Drive + ' => ' + Copy(string(Target), 5, Length(string(Target))));
      end;
    end;

    while Drives[i] <> #0 do Inc(i);
    Inc(i);
  end;
end;

function TSubstManager.GetSubstDrivesAsStrings2: TStringList;
var
  DrivesList: TArray<TSubstDriveInfo>;
  i: Integer;
begin
  Result := TStringList.Create;
  DrivesList := GetSubstDrivesList;

  if Length(DrivesList) = 0 then
    Result.Add('Nessun drive SUBST trovato')
  else
  begin
    for i := 0 to High(DrivesList) do
    begin
      Result.Add(Format('%s: => %s', [
        DrivesList[i].DriveLetter,
        DrivesList[i].TargetPath
      ]));
    end;
  end;
end;

function TSubstManager.GetSubstDrivesList: TArray<TSubstDriveInfo>;
var
  Output: string;
begin
  Output := ExecuteCommandAndGetOutput('cmd.exe /c subst');
  Result := ParseSubstOutput(Output);
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
        Result.Add(Drive + ': => ' + Path);
    end;
  end;
end;

function TSubstManager.ParseSubstOutput(const Output: string): TArray<TSubstDriveInfo>;
var
  Lines: TStringList;
  i, ArrowPos: Integer;
  Line: string;
  DriveInfo: TSubstDriveInfo;
  DriveList: TList<TSubstDriveInfo>;
begin
  DriveList := TList<TSubstDriveInfo>.Create;
  try
    Lines := TStringList.Create;
    try
      Lines.Text := Output;

      for i := 0 to Lines.Count - 1 do
      begin
        Line := Trim(Lines[i]);
        if Line = '' then Continue;

        // Formato tipico: "Z:\: => C:\MiaCartella"
        ArrowPos := Pos(': => ', Line);
        if ArrowPos > 0 then
        begin
          if Length(Line) >= 1 then
          begin
            DriveInfo.DriveLetter := UpCase(Line[1]);
            DriveInfo.TargetPath := Trim(Copy(Line, ArrowPos + 5, Length(Line)));
            DriveList.Add(DriveInfo);
          end;
        end;
      end;

    finally
      Lines.Free;
    end;

    SetLength(Result, DriveList.Count);
    for i := 0 to DriveList.Count - 1 do
      Result[i] := DriveList[i];

  finally
    DriveList.Free;
  end;

end;

Function TSubstManager.IsVirtualDrive(const DriveLetter: Char): Boolean;
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
