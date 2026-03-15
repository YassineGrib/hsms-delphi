program hsms;

uses
  System.StartUpCopy,
  FMX.Forms,
  FrmSplash in 'Source\Forms\FrmSplash.pas' {SplashForm},
  FrmLogin in 'Source\Forms\FrmLogin.pas' {LoginForm},
  FrmDashboard in 'Source\Forms\FrmDashboard.pas' {DashboardFrame: TFrame},
  FrmEmployees in 'Source\Forms\FrmEmployees.pas' {EmployeesFrame: TFrame},
  FrmEmployeeEdit in 'Source\Forms\FrmEmployeeEdit.pas' {EmployeeEditForm},
  FrmSalaryCalc in 'Source\Forms\FrmSalaryCalc.pas' {SalaryCalcFrame: TFrame},
  FrmPaySlip in 'Source\Forms\FrmPaySlip.pas' {PaySlipFrame: TFrame},
  FrmBareme in 'Source\Forms\FrmBareme.pas' {BaremeFrame: TFrame},
  FrmSettings in 'Source\Forms\FrmSettings.pas' {SettingsFrame: TFrame},
  Model_Employee in 'Source\Models\Model_Employee.pas',
  Model_Department in 'Source\Models\Model_Department.pas',
  Model_Allowance in 'Source\Models\Model_Allowance.pas',
  Model_SalaryRecord in 'Source\Models\Model_SalaryRecord.pas',
  Engine_Bareme in 'Source\Engine\Engine_Bareme.pas',
  Engine_IRG in 'Source\Engine\Engine_IRG.pas',
  Engine_Salary in 'Source\Engine\Engine_Salary.pas',
  FrmMain in 'Source\Forms\FrmMain.pas' {MainForm},
  DM_Database in 'Source\DataModules\DM_Database.pas' {DMDatabase: TDataModule},
  DB_Helper in 'Source\Utils\DB_Helper.pas',
  DB_Schema in 'Source\Utils\DB_Schema.pas',
  DB_Seed in 'Source\Utils\DB_Seed.pas',
  Auth_Manager in 'Source\Utils\Auth_Manager.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  DMDatabase := TDMDatabase.Create; // Create Data Module instance
  try
    Application.CreateForm(TSplashForm, SplashForm);
    Application.Run;
  finally
    DMDatabase.Free;
  end;
end.
