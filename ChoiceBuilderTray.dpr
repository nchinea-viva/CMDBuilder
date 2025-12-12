program ChoiceBuilderTray;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  Windows,
  TrayMainForm in 'TrayMainForm.pas' {frmTrayMain},
  SubstManager in 'SubstManager.pas',
  GestSub in 'GestSub.pas' {FGestSubst},
  ConfigManager in 'ConfigManager.pas',
  BuilderUtils in 'BuilderUtils.pas',
  BuildConfigManager in 'BuildConfigManager.pas',
  ConfigWizardForm in 'ConfigWizardForm.pas' {frmConfigWizard},
  Unit1 in 'Unit1.pas',
  SQLServerDetection in 'SQLServerDetection.pas',
  RegistryReader in 'RegistryReader.pas',
  IniConfig in 'IniConfig.pas' {FIniConfig},
  XmlFormConverter in 'XmlFormConverter.pas' {FConvert},
  XMLMultirefConverter in 'XMLMultirefConverter.pas',
  SQLPrettyPrint in 'SQLPrettyPrint.pas',
  SQLFormatter in 'SQLFormatter.pas',
  ChangePwd in 'ChangePwd.pas' {FChangePwd},
  ASN1 in 'Encryption\Part_I\ASN1.pas',
  CPU in 'Encryption\Part_I\CPU.pas',
  CRC in 'Encryption\Part_I\CRC.pas',
  DECCipher in 'Encryption\Part_I\DECCipher.pas',
  DECData in 'Encryption\Part_I\DECData.pas',
  DECFmt in 'Encryption\Part_I\DECFmt.pas',
  DECHash in 'Encryption\Part_I\DECHash.pas',
  DECRandom in 'Encryption\Part_I\DECRandom.pas',
  DECUtil in 'Encryption\Part_I\DECUtil.pas',
  SyntaxHighlighter in 'SyntaxHighlighter.pas';

{$R *.res}
var
  lMutexHandle: THandle;
  lWaitResult: DWORD;

begin

  lMutexHandle := CreateMutex(nil, False, 'ChoiceBuilder_2025');
  if lMutexHandle = 0 then
  begin
    MessageBox(0, 'Error create mutex! application stop', 'Errore', MB_OK);
    Exit;
  end;

  lWaitResult := WaitForSingleObject(lMutexHandle, 0);
  case lWaitResult of
    WAIT_OBJECT_0:
      begin
        // Mutex acquisito con successo
      end;

    WAIT_ABANDONED:
      begin
        // Il mutex era abbandonato, ma ora è nostro
        // Possiamo continuare
        MessageBox(0, 'The previous instance did not close properly',
                   'Information', MB_OK or MB_ICONWARNING);
      end;

    WAIT_TIMEOUT:
      begin
        // Un'altra istanza sta usando il mutex
        MessageBox(0, 'The application is already running!',
                   'Warning', MB_OK or MB_ICONWARNING);
        CloseHandle(lMutexHandle);
        Exit;
      end;

    WAIT_FAILED:
      begin
        MessageBox(0, 'Error waiting for mutex!', 'Error', MB_OK);
        CloseHandle(lMutexHandle);
        Exit;
      end;
  end;

  try
    Application.Initialize;
    ReportMemoryLeaksOnShutdown := True;
    Application.MainFormOnTaskbar := False; // Non mostrare nella taskbar
    Application.Title := 'Choice Builder - System Tray Build Manager';
    Application.CreateForm(TfrmTrayMain, frmTrayMain);
    Application.Run;
  finally
    ReleaseMutex(lMutexHandle);
    CloseHandle(lMutexHandle);
  end;
end.


