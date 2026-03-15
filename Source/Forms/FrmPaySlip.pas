unit FrmPaySlip;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Grid, FMX.Grid.Style,
  FMX.Effects, System.Rtti, FMX.ScrollBox, Model_SalaryRecord, Model_Employee, DB_Helper;

type
  TPaySlipFrame = class(TFrame)
    bgRect: TRectangle;
    
    // Top actions
    TopActionsLayout: TLayout;
    BtnPrint: TButton;
    BtnExportPDF: TButton;
    
    // Scrollable area for A4 paper
    ScrollBoxMain: TScrollBox;
    
    // A4 Paper Background
    PaperRect: TRectangle;
    ShadowPaper: TShadowEffect;
    
    // Header
    HeaderLayout: TLayout;
    LblHospitalName: TLabel;
    LblPaySlipTitle: TLabel;
    LblDateParams: TLabel;
    
    // Employee Info
    EmpInfoLayout: TLayout;
    RectEmpInfoBox: TRectangle;
    LblEmpNameInfo: TLabel;
    LblEmpMatricule: TLabel;
    LblEmpFunction: TLabel;
    LblEmpSS: TLabel;
    
    // Data Grid (Gains & Retenues)
    GridContainer: TLayout;
    GridPay: TStringGrid;
    ColCode: TStringColumn;
    ColLibelle: TStringColumn;
    ColBase: TStringColumn;
    ColTaux: TStringColumn;
    ColGain: TStringColumn;
    ColRetenue: TStringColumn;
    
    // Bottom Summary
    FooterLayout: TLayout;
    RectNetToPayBox: TRectangle;
    LblNetTitle: TLabel;
    LblNetValue: TLabel;
    LblNetWords: TLabel;
    
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadRecord(ASalaryRecord: TSalaryRecord);
  end;

var
  PaySlipFrame: TPaySlipFrame;

implementation

{$R *.fmx}

constructor TPaySlipFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // Setup texts programmatically
  BtnPrint.Text := 'Imprimer (Impression Fictive)';
  BtnExportPDF.Text := 'Exporter PDF';
  
  LblHospitalName.Text := 'HOPITAL CENTRAL DE REFERENCE';
  LblPaySlipTitle.Text := 'BULLETIN DE PAIE';
  LblDateParams.Text := 'Période: Mars 2024';
  
  LblEmpNameInfo.Text := 'Nom & Prénom : BENDJEDDOU Yassine';
  LblEmpMatricule.Text := 'Matricule : EMP-001';
  LblEmpFunction.Text := 'Fonction : Médecin Spécialiste Principal';
  LblEmpSS.Text := 'N° Sécurité Sociale : 12 3456 7890 12';
  
  // Grid Columns Header Setup
  ColCode.Header := 'Code';
  ColLibelle.Header := 'Désignation';
  ColBase.Header := 'Base';
  ColTaux.Header := 'Taux/Nbr';
  ColGain.Header := 'Gains (Rubriques)';
  ColRetenue.Header := 'Retenues';
  
  GridPay.RowCount := 5;
  // Base Salary
  GridPay.Cells[0, 0] := '101';
  GridPay.Cells[1, 0] := 'Salaire de Base';
  GridPay.Cells[2, 0] := '45 000.00';
  GridPay.Cells[3, 0] := '30';
  GridPay.Cells[4, 0] := '45 000.00';
  GridPay.Cells[5, 0] := '';
  
  // IEP
  GridPay.Cells[0, 1] := '102';
  GridPay.Cells[1, 1] := 'Prime d''Expérience (IEP)';
  GridPay.Cells[2, 1] := '45 000.00';
  GridPay.Cells[3, 1] := '5%';
  GridPay.Cells[4, 1] := '2 250.00';
  GridPay.Cells[5, 1] := '';
  
  // Retenue Securite Sociale
  GridPay.Cells[0, 2] := '801';
  GridPay.Cells[1, 2] := 'Retenue S.S (Sécurité Sociale)';
  GridPay.Cells[2, 2] := '47 250.00';
  GridPay.Cells[3, 2] := '9%';
  GridPay.Cells[4, 2] := '';
  GridPay.Cells[5, 2] := '4 252.50';
  
  // IRG
  GridPay.Cells[0, 3] := '802';
  GridPay.Cells[1, 3] := 'Retenue I.R.G';
  GridPay.Cells[2, 3] := '42 997.50';
  GridPay.Cells[3, 3] := '';
  GridPay.Cells[4, 3] := '';
  GridPay.Cells[5, 3] := '5 120.00';
  
  // Total Row
  GridPay.Cells[0, 4] := '';
  GridPay.Cells[1, 4] := 'TOTAUX GENERAUX';
  GridPay.Cells[2, 4] := '';
  GridPay.Cells[3, 4] := '';
  GridPay.Cells[4, 4] := '47 250.00';
  GridPay.Cells[5, 4] := '9 372.50';
  
  LblNetTitle.Text := 'Net a Payer (+)';
  LblNetValue.Text := '0.00 DZD';
  LblNetWords.Text := 'Arrêté le présent bulletin à la somme de : ...';
end;

procedure TPaySlipFrame.LoadRecord(ASalaryRecord: TSalaryRecord);
var
  Emp: TEmployee;
  RowIdx: Integer;
  
  // Add Row Helper string
  procedure AddRow(const Code, Libelle, Base, Taux, Gain, Retenue: string);
  begin
    GridPay.RowCount := GridPay.RowCount + 1;
    GridPay.Cells[0, RowIdx] := Code;
    GridPay.Cells[1, RowIdx] := Libelle;
    GridPay.Cells[2, RowIdx] := Base;
    GridPay.Cells[3, RowIdx] := Taux;
    GridPay.Cells[4, RowIdx] := Gain;
    GridPay.Cells[5, RowIdx] := Retenue;
    Inc(RowIdx);
  end;

begin
  if not Assigned(ASalaryRecord) then Exit;
  
  Emp := TEmployee.LoadFromDB(ASalaryRecord.EmployeeId);
  if Assigned(Emp) then
  begin
    try
      // Header
      LblHospitalName.Text := TDBHelper.GetSettingValue('institution_name_fr');
      if LblHospitalName.Text = '' then 
        LblHospitalName.Text := 'HOPITAL CENTRAL DE REFERENCE';
        
      LblDateParams.Text := 'Période : ' + FormatDateTime('mmmm yyyy', EncodeDate(ASalaryRecord.Year, ASalaryRecord.Month, 1));
      
      // Employee
      LblEmpNameInfo.Text := 'Nom & Prénom : ' + Emp.FullName;
      LblEmpMatricule.Text := 'Matricule : ' + Emp.EmployeeNumber;
      LblEmpFunction.Text := 'Fonction : ' + Emp.PositionFr;
      LblEmpSS.Text := 'N° Sécurité Sociale : ' + Emp.NationalId;
      
      // Grid Clear
      GridPay.RowCount := 0;
      RowIdx := 0;
      
      // Base
      AddRow('101', 'Salaire de Base', FormatFloat('0.00', ASalaryRecord.BaseSalary), '30', FormatFloat('0.00', ASalaryRecord.BaseSalary), '');
      
      // Earnings (Allowances)
      if ASalaryRecord.InfectionAllowance > 0 then
        AddRow('202', 'Indemnité de Contagion', '', '', FormatFloat('0.00', ASalaryRecord.InfectionAllowance), '');
      if ASalaryRecord.DocumentationAllowance > 0 then
        AddRow('302', 'Indemnité de Documentation', '', '', FormatFloat('0.00', ASalaryRecord.DocumentationAllowance), '');
      if ASalaryRecord.QualificationAllowance > 0 then
        AddRow('702', 'Indemnité de Qualification', '', '', FormatFloat('0.00', ASalaryRecord.QualificationAllowance), '');
      if ASalaryRecord.SupervisionAllowance > 0 then
        AddRow('802', 'Indemnité d''Encadrement', '', '', FormatFloat('0.00', ASalaryRecord.SupervisionAllowance), '');
      if ASalaryRecord.HealthActivitySupport > 0 then
        AddRow('212', 'Soutien Activités de Santé', '', '', FormatFloat('0.00', ASalaryRecord.HealthActivitySupport), '');
      if ASalaryRecord.FlatRateBonus > 0 then
        AddRow('390', 'Prime Forfaitaire', '', '', FormatFloat('0.00', ASalaryRecord.FlatRateBonus), '');
        
      // Deductions
      AddRow('801', 'Retenue S.S (Sécurité Sociale)', FormatFloat('0.00', ASalaryRecord.GrossSalary), '9%', '', FormatFloat('0.00', ASalaryRecord.SocialSecurity));
      AddRow('802', 'Retenue I.R.G', FormatFloat('0.00', ASalaryRecord.TaxableIncome), '', '', FormatFloat('0.00', ASalaryRecord.IrgTax));
      
      if ASalaryRecord.AbsenceDeduction > 0 then
        AddRow('805', 'Retenue Absences', '', IntToStr(ASalaryRecord.AbsentDays) + ' J', '', FormatFloat('0.00', ASalaryRecord.AbsenceDeduction));
        
      // Totals
      AddRow('', 'TOTAUX GENERAUX', '', '', FormatFloat('0.00', ASalaryRecord.GrossSalary), FormatFloat('0.00', ASalaryRecord.SocialSecurity + ASalaryRecord.IrgTax + ASalaryRecord.AbsenceDeduction));
      
      // Footer
      LblNetValue.Text := FormatFloat('#,##0.00', ASalaryRecord.NetPay) + ' DZD';
      // In a real app we'd convert numbers to french words.
      LblNetWords.Text := 'Arrêté le présent bulletin à la somme de : ' + FormatFloat('0.00', ASalaryRecord.NetPay) + ' DA.';
      
    finally
      Emp.Free;
    end;
  end;
end;

end.
