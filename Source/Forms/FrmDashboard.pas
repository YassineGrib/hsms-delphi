unit FrmDashboard;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Effects,
  DB_Helper, FireDAC.Comp.Client, System.DateUtils;

type
  TDashboardFrame = class(TFrame)
    bgRect: TRectangle;
    TopFlowLayout: TFlowLayout;
    
    // Cards
    CardEmployees: TRectangle;
    LblEmployeesTitle: TLabel;
    LblEmployeesValue: TLabel;
    ShadowEmployees: TShadowEffect;
    
    CardPayroll: TRectangle;
    LblPayrollTitle: TLabel;
    LblPayrollValue: TLabel;
    ShadowPayroll: TShadowEffect;
    
    CardDepts: TRectangle;
    LblDeptsTitle: TLabel;
    LblDeptsValue: TLabel;
    ShadowDepts: TShadowEffect;
    
    CardAbsences: TRectangle;
    LblAbsencesTitle: TLabel;
    LblAbsencesValue: TLabel;
    ShadowAbsences: TShadowEffect;
    
    // Main Body section
    MiddleLayout: TLayout;
    MainChartRect: TRectangle;
    LblChartTitle: TLabel;
    ShadowChart: TShadowEffect;
    
    QuickActionsRect: TRectangle;
    LblActionsTitle: TLabel;
    BtnNewEmployee: TButton;
    BtnRunCalc: TButton;
    ShadowActions: TShadowEffect;
    procedure BtnNewEmployeeClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure RefreshData;
  end;

var
  DashboardFrame: TDashboardFrame;

implementation

uses
  FrmEmployeeEdit, FrmEmployees;

{$R *.fmx}

procedure TDashboardFrame.BtnNewEmployeeClick(Sender: TObject);
begin
  if not Assigned(EmployeeEditForm) then
    Application.CreateForm(TEmployeeEditForm, EmployeeEditForm);
    
  EmployeeEditForm.CurrentEmployeeId := 0; // 0 means insert new
  if EmployeeEditForm.ShowModal = mrOk then
  begin
    if Assigned(EmployeesFrame) then
      EmployeesFrame.RefreshData;
  end;
end;

constructor TDashboardFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // Set accurate French text without accents inside the .fmx
  LblEmployeesTitle.Text := 'Total Employés';
  LblDeptsTitle.Text := 'Départements';
  LblChartTitle.Text := 'Répartition des Salaires';
  LblActionsTitle.Text := 'Actions Rapides';
  
  BtnNewEmployee.Text := 'Nouveau Employé';
  BtnRunCalc.Text := 'Lancer le Calcul';
  
  RefreshData;
end;

procedure TDashboardFrame.RefreshData;
var
  Q: TFDQuery;
begin
  LblEmployeesValue.Text := IntToStr(TDBHelper.CountRecords('employees', 'is_active = 1'));
  LblDeptsValue.Text := IntToStr(TDBHelper.CountRecords('departments'));
  
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := TDBHelper.GetConnection;
    // For simplicity we show all-time payroll in dashboard or we can restrict to current month
    Q.SQL.Text := 'SELECT COALESCE(SUM(net_pay), 0) AS total_net, COALESCE(SUM(absent_days), 0) AS total_abs FROM salary_records WHERE year = :y';
    Q.ParamByName('y').AsInteger := YearOf(Now);
    Q.Open;
    
    if not Q.IsEmpty then
    begin
      LblPayrollValue.Text := FormatFloat('#,##0.00', Q.FieldByName('total_net').AsFloat) + ' DZD';
      LblAbsencesValue.Text := IntToStr(Q.FieldByName('total_abs').AsInteger);
    end
    else
    begin
      LblPayrollValue.Text := '0.00 DZD';
      LblAbsencesValue.Text := '0';
    end;
  finally
    Q.Free;
  end;
end;

end.
