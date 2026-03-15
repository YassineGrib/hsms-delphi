unit FrmDashboard;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Effects;

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
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  DashboardFrame: TDashboardFrame;

implementation

{$R *.fmx}

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
end;

end.
