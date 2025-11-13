unit SubstCompleteManager;

interface

uses
  Windows, SysUtils, Classes;

type
  TSubstDriveInfo = record
    DriveLetter: Char;
    TargetPath: string;
  end;

  TSubstManager = class
  private
    function ExecuteCommandAndGetOutput(const Command: string): string;
    function ParseSubstOutput(const Output: string): TArray<TSubstDriveInfo>;
  public
    // Crea un drive virtuale usando il comando SUBST
    function CreateSubstDrive(const DriveLetter: Char; const Path: string): Boolean;

    // Rimuove un drive virtuale
    function RemoveSubstDrive(const DriveLetter: Char): Boolean;

    // Ottiene la lista completa dei drive SUBST
    function GetSubstDrivesList: TArray<TSubstDriveInfo>;

    // Ottiene la lista come stringhe formattate
    function GetSubstDrivesAsStrings: TStringList;

    // Verifica se un drive specifico è un SUBST
    function IsSubstDrive(const DriveLetter: Char): Boolean;

    // Ottiene il percorso di destinazione di un drive SUBST
    function GetSubstDrivePath(const DriveLetter: Char): string;
  end;

implementation

uses
  System.Generics.Collections;
{ TSubstManager }

function TSubstManager.ExecuteCommandAndGetOutput(const Command: string): string;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  SecurityAttr: TSecurityAttributes;
  hReadPipe, hWritePipe: THandle;
  Buffer: array[0..4095] of AnsiChar;
  BytesRead: DWORD;
  Output: AnsiString;
begin
  Result := '';

  // Crea pipe per catturare l'output
  SecurityAttr.nLength := SizeOf(SecurityAttr);
  SecurityAttr.bInheritHandle := True;
  SecurityAttr.lpSecurityDescriptor := nil;

  if not CreatePipe(hReadPipe, hWritePipe, @SecurityAttr, 0) then
    Exit;

  try
    // Configura StartupInfo
    FillChar(StartupInfo, SizeOf(StartupInfo), 0);
    StartupInfo.cb := SizeOf(StartupInfo);
    StartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    StartupInfo.wShowWindow := SW_HIDE;
    StartupInfo.hStdOutput := hWritePipe;
    StartupInfo.hStdError := hWritePipe;

    // Esegui il comando
    if CreateProcess(nil, PChar(Command), nil, nil, True, 0, nil, nil,
                     StartupInfo, ProcessInfo) then
    try
      CloseHandle(hWritePipe);
      hWritePipe := 0;

      // Leggi l'output
      Output := '';
      repeat
        if not ReadFile(hReadPipe, Buffer, SizeOf(Buffer), BytesRead, nil) then
          Break;
        if BytesRead > 0 then
          Output := Output + Copy(AnsiString(Buffer), 1, BytesRead);
      until BytesRead = 0;

      // Aspetta che il processo finisca
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
          // Estrai la lettera del drive
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

    // Converti in array
    SetLength(Result, DriveList.Count);
    for i := 0 to DriveList.Count - 1 do
      Result[i] := DriveList[i];

  finally
    DriveList.Free;
  end;
end;

function TSubstManager.CreateSubstDrive(const DriveLetter: Char; const Path: string): Boolean;
var
  Command: string;
  Output: string;
begin
  if not DirectoryExists(Path) then
  begin
    Result := False;
    Exit;
  end;

  Command := Format('cmd.exe /c subst %s: "%s"', [UpCase(DriveLetter), Path]);
  Output := ExecuteCommandAndGetOutput(Command);

  // SUBST non restituisce output se ha successo
  Result := Trim(Output) = '';
end;

function TSubstManager.RemoveSubstDrive(const DriveLetter: Char): Boolean;
var
  Command: string;
  Output: string;
begin
  Command := Format('cmd.exe /c subst %s: /d', [UpCase(DriveLetter)]);
  Output := ExecuteCommandAndGetOutput(Command);

  // SUBST non restituisce output se ha successo
  Result := Trim(Output) = '';
end;

function TSubstManager.GetSubstDrivesList: TArray<TSubstDriveInfo>;
var
  Output: string;
begin
  Output := ExecuteCommandAndGetOutput('cmd.exe /c subst');
  Result := ParseSubstOutput(Output);
end;

function TSubstManager.GetSubstDrivesAsStrings: TStringList;
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
      Result.Add(Format('%s: -> %s', [
        DrivesList[i].DriveLetter,
        DrivesList[i].TargetPath
      ]));
    end;
  end;
end;

function TSubstManager.IsSubstDrive(const DriveLetter: Char): Boolean;
var
  DrivesList: TArray<TSubstDriveInfo>;
  i: Integer;
begin
  Result := False;
  DrivesList := GetSubstDrivesList;

  for i := 0 to High(DrivesList) do
  begin
    if UpCase(DrivesList[i].DriveLetter) = UpCase(DriveLetter) then
    begin
      Result := True;
      Break;
    end;
  end;
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

end.
