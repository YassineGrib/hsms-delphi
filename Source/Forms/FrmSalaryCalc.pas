unit FrmSalaryCalc;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox, FMX.Edit,
  FMX.Grid, FMX.Grid.Style, FMX.Effects, System.Rtti, FMX.ScrollBox,
  Model_Employee, Model_SalaryRecord, Engine_Salary, System.Generics.Collections;

type
  TSalaryCalcFrame = class(TFrame)
    bgRect: TRectangle;
    
    // Header
    TopBarLayout: TLayout;
    TopBarRect: TRectangle;
    ShadowTopBar: TShadowEffect;
    LblPageTitle: TLabel;
    
    // Step Indicator
    StepsContainer: TLayout;
    LblStep1: TLabel;
    LblStep2: TLabel;
    LblStep3: TLabel;
    LblStep4: TLabel;
    LineStep1: TLine;
    LineStep2: TLine;
    LineStep3: TLine;
    
    // Main Content Area
    MainContentRect: TRectangle;
    ShadowMainContent: TShadowEffect;
    
    // Step 1 Content: Paramètres Initiaux (Mois)
    Step1Layout: TLayout;
    LblSelectMonth: TLabel;
    ComboMonth: TComboBox;
    ComboYear: TComboBox;
    BtnNextToStep2: TButton;
    
    // Step 2 Content: Saisie Absences (Grid)
    Step2Layout: TLayout;
    AbsenceGrid: TStringGrid;
    ColID: TStringColumn;
    ColName: TStringColumn;
    ColDept: TStringColumn;
    ColAbsDays: TIntegerColumn;
    BtnBackToStep1: TButton;
    BtnNextToStep3: TButton;
    LblAbsenceTitle: TLabel;
    
    // Step 3 Content: Previsualisation (PaySlip embed)
    Step3Layout: TLayout;
    Step3TopBar: TLayout;
    BtnBackToStep2: TButton;
    BtnFinish: TButton;
    
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  private
    FEmployees: TObjectList<TEmployee>;
    FCalculatedRecords: TObjectList<TSalaryRecord>;
    procedure SetupTexts;
    procedure ShowStep(StepIndex: Integer);
    procedure LoadEmployeesForAbsence;
    procedure RunCalculation;
    
    procedure BtnNextToStep2Click(Sender: TObject);
    procedure BtnBackToStep1Click(Sender: TObject);
    procedure BtnNextToStep3Click(Sender: TObject);
    procedure BtnBackToStep2Click(Sender: TObject);
    procedure BtnFinishClick(Sender: TObject);
  end;

var
  SalaryCalcFrame: TSalaryCalcFrame;

implementation

uses FrmPaySlip;

{$R *.fmx}

constructor TSalaryCalcFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetupTexts;
  ShowStep(1); // Start at step 1
  
  // Setup Grid
  ColID.Header := 'Matricule';
  ColName.Header := 'Nom & Prénom';
  ColDept.Header := 'Département';
  ColAbsDays.Header := 'Absences (Jours)';
  
  AbsenceGrid.RowCount := 0;
  
  // Wire up events dynamically
  BtnNextToStep2.OnClick := BtnNextToStep2Click;
  BtnBackToStep1.OnClick := BtnBackToStep1Click;
  BtnNextToStep3.OnClick := BtnNextToStep3Click;
  BtnBackToStep2.OnClick := BtnBackToStep2Click;
  BtnFinish.OnClick := BtnFinishClick;
  
  // Embed the PaySlip into Step3Layout
  if Assigned(Step3Layout) and not Assigned(PaySlipFrame) then
  begin
    PaySlipFrame := TPaySlipFrame.Create(Self);
    PaySlipFrame.Parent := Step3Layout;
    PaySlipFrame.Align := TAlignLayout.Client;
  end;
end;

destructor TSalaryCalcFrame.Destroy;
begin
  if Assigned(FEmployees) then FEmployees.Free;
  if Assigned(FCalculatedRecords) then FCalculatedRecords.Free;
  inherited;
end;

procedure TSalaryCalcFrame.LoadEmployeesForAbsence;
var
  i: Integer;
begin
  if Assigned(FEmployees) then FreeAndNil(FEmployees);
  FEmployees := TEmployee.GetAllEmployees();
  
  AbsenceGrid.RowCount := FEmployees.Count;
  for i := 0 to FEmployees.Count - 1 do
  begin
    AbsenceGrid.Cells[0, i] := FEmployees[i].EmployeeNumber;
    AbsenceGrid.Cells[1, i] := FEmployees[i].FullName;
    AbsenceGrid.Cells[2, i] := FEmployees[i].DepartmentId;
    AbsenceGrid.Cells[3, i] := '0'; // default absent days
  end;
end;

procedure TSalaryCalcFrame.RunCalculation;
var
  M, Y, AbsDays, i: Integer;
  Rec: TSalaryRecord;
begin
  M := ComboMonth.ItemIndex + 1; // Jan = 1
  Y := StrToIntDef(ComboYear.Selected.Text, 2024);
  
  if Assigned(FCalculatedRecords) then FreeAndNil(FCalculatedRecords);
  FCalculatedRecords := TObjectList<TSalaryRecord>.Create(True);
  
  for i := 0 to FEmployees.Count - 1 do
  begin
    AbsDays := StrToIntDef(AbsenceGrid.Cells[3, i], 0);
    // Calculate via Engine
    Rec := TEngineSalary.CalculateSalary(FEmployees[i].Id, M, Y, AbsDays, 30);
    Rec.Save; // Auto inserts or updates
    FCalculatedRecords.Add(Rec);
  end;
end;

procedure TSalaryCalcFrame.BtnBackToStep1Click(Sender: TObject);
begin
  ShowStep(1);
end;

procedure TSalaryCalcFrame.BtnNextToStep2Click(Sender: TObject);
begin
  LoadEmployeesForAbsence;
  ShowStep(2);
end;

procedure TSalaryCalcFrame.BtnNextToStep3Click(Sender: TObject);
begin
  RunCalculation;
  ShowStep(3);
end;

procedure TSalaryCalcFrame.BtnBackToStep2Click(Sender: TObject);
begin
  ShowStep(2);
end;

procedure TSalaryCalcFrame.BtnFinishClick(Sender: TObject);
begin
  ShowMessage('Facturation Terminée et Sauvegardée !');
  ShowStep(1); // Reset wizard
end;

procedure TSalaryCalcFrame.SetupTexts;
begin
  LblPageTitle.Text := 'Calcul des Salaires';
  
  LblStep1.Text := '1. Selection Mois';
  LblStep2.Text := '2. Saisie Absences';
  LblStep3.Text := '3. Previsualisation';
  LblStep4.Text := '4. Validation';
  
  // Step 1 UI
  LblSelectMonth.Text := 'Selectionner la periode de paie :';
  BtnNextToStep2.Text := 'Suivant (Absences) >';
  
  ComboMonth.Items.Add('Janvier');
  ComboMonth.Items.Add('Fevrier');
  ComboMonth.Items.Add('Mars');
  ComboMonth.Items.Add('Avril');
  ComboMonth.Items.Add('Mai');
  ComboMonth.Items.Add('Juin');
  ComboMonth.ItemIndex := 2; // Mars
  
  ComboYear.Items.Add('2023');
  ComboYear.Items.Add('2024');
  ComboYear.ItemIndex := 1; // 2024
  
  // Step 2 UI
  LblAbsenceTitle.Text := 'Saisie des absences (Double-cliquez pour editer)';
  BtnBackToStep1.Text := '< Retour';
  BtnNextToStep3.Text := 'Suivant (Visualiser) >';
  
  // Step 3 UI
  BtnBackToStep2.Text := '< Retour';
  BtnFinish.Text := 'Valider et Cloturer le mois';
end;

procedure TSalaryCalcFrame.ShowStep(StepIndex: Integer);
begin
  // Hide all steps
  Step1Layout.Visible := False;
  Step2Layout.Visible := False;
  Step3Layout.Visible := False;
  
  // Reset Step styles
  LblStep1.Font.Style := [];
  LblStep2.Font.Style := [];
  LblStep3.Font.Style := [];
  LblStep4.Font.Style := [];
  
  LblStep1.TextSettings.FontColor := $FFA8B2D1;
  LblStep2.TextSettings.FontColor := $FFA8B2D1;
  LblStep3.TextSettings.FontColor := $FFA8B2D1;
  LblStep4.TextSettings.FontColor := $FFA8B2D1;
  
  // Highlight current step
  case StepIndex of
    1: 
      begin
        Step1Layout.Visible := True;
        LblStep1.Font.Style := [TFontStyle.fsBold];
        LblStep1.TextSettings.FontColor := $FF112240;
      end;
    2: 
      begin
        Step2Layout.Visible := True;
        LblStep2.Font.Style := [TFontStyle.fsBold];
        LblStep2.TextSettings.FontColor := $FF112240;
      end;
    3:
      begin
        Step3Layout.Visible := True;
        LblStep3.Font.Style := [TFontStyle.fsBold];
        LblStep3.TextSettings.FontColor := $FF112240;
      end;
  end;
end;

end.
