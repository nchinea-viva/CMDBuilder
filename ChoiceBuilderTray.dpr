program ChoiceBuilderTray;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
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

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := False; // Non mostrare nella taskbar
  Application.Title := 'Choice Builder - System Tray Build Manager';
  Application.CreateForm(TfrmTrayMain, frmTrayMain);
  // frmTrayMain.HideToTray;
  Application.Run;
end.


