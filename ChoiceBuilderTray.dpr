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
  SQLPrettyPrint in 'SQLPrettyPrint.pas';

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := False; // Non mostrare nella taskbar
  Application.Title := 'Choice Builder - System Tray Build Manager';
  Application.CreateForm(TfrmTrayMain, frmTrayMain);
  Application.CreateForm(TFConvert, FConvert);
  // frmTrayMain.HideToTray;
  Application.Run;
end.


