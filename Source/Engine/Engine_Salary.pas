unit Engine_Salary;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  Model_Employee, Model_SalaryRecord, Model_Allowance,
  Engine_Bareme, Engine_IRG, DB_Helper;

type
  TEngineSalary = class
  public
    // Step-by-step 7-stage Algerian Pipeline computation
    class function CalculateSalary(
      AEmployeeId: Integer;
      AMonth, AYear: Integer;
      AAbsentDays: Integer = 0;
      AWorkingDays: Integer = 30): TSalaryRecord;
  end;

implementation

{ TEngineSalary }

class function TEngineSalary.CalculateSalary(AEmployeeId, AMonth, AYear, AAbsentDays, AWorkingDays: Integer): TSalaryRecord;
var
  Emp: TEmployee;
  Rec: TSalaryRecord;
  Allowances: TObjectList<TEmployeeAllowance>;
  AItem: TEmployeeAllowance;
  i: Integer;
  VGross, VSSRate, VSSAmt, VTaxable, VIrg, VAbsDeduct, VNet: Double;
begin
  Emp := TEmployee.LoadFromDB(AEmployeeId);
  if not Assigned(Emp) then
    raise Exception.CreateFmt('Employee with ID %d not found.', [AEmployeeId]);
    
  Rec := TSalaryRecord.Create;
  Allowances := nil;
  try
    Rec.EmployeeId := AEmployeeId;
    Rec.Month := AMonth;
    Rec.Year := AYear;
    Rec.DaysWorked := AWorkingDays;
    Rec.AbsentDays := AAbsentDays;
    
    // Step 1: Base Salary Lookup from Bareme
    Rec.BaseSalary := TEngineBareme.GetBaseSalary(Emp.GradeClass, Emp.Degree, AYear);
    
    // Step 2: Fetch and map employee allowances
    VGross := Rec.BaseSalary;
    Allowances := TEmployeeAllowance.GetEmployeeAllowances(AEmployeeId);
    
    for i := 0 to Allowances.Count - 1 do
    begin
      AItem := Allowances[i];
      VGross := VGross + AItem.Amount;
      
      // Map known system allowance IDs into the fixed columns structure
      if AItem.AllowanceId = 'infection_allowance' then
        Rec.InfectionAllowance := AItem.Amount
      else if AItem.AllowanceId = 'documentation_allowance' then
        Rec.DocumentationAllowance := AItem.Amount
      else if AItem.AllowanceId = 'qualification_allowance' then
        Rec.QualificationAllowance := AItem.Amount
      else if AItem.AllowanceId = 'supervision_allowance' then
        Rec.SupervisionAllowance := AItem.Amount
      else if AItem.AllowanceId = 'health_activity_support' then
        Rec.HealthActivitySupport := AItem.Amount
      else if AItem.AllowanceId = 'obstetric_allowance' then
        Rec.ObstetricAllowance := AItem.Amount
      else if AItem.AllowanceId = 'mother_child_health' then
        Rec.MotherChildHealth := AItem.Amount
      else if AItem.AllowanceId = 'flat_rate_bonus' then
        Rec.FlatRateBonus := AItem.Amount;
    end;
    
    Rec.GrossSalary := VGross;
    
    // Step 3: Social Security
    VSSRate := TDBHelper.GetSettingAsFloat('social_security_rate');
    if VSSRate = 0 then VSSRate := 0.09;
    VSSAmt := VGross * VSSRate;
    Rec.SocialSecurity := VSSAmt;
    
    // Step 4: Taxable Income
    VTaxable := VGross - VSSAmt;
    Rec.TaxableIncome := VTaxable;
    
    // Step 5: IRG Tax
    VIrg := TEngineIRG.CalculateIRG(VTaxable);
    Rec.IrgTax := VIrg;
    
    // Step 6: Absence Deduction
    if (AAbsentDays > 0) and (AWorkingDays > 0) then
      VAbsDeduct := (VGross / AWorkingDays) * AAbsentDays
    else
      VAbsDeduct := 0;
    Rec.AbsenceDeduction := VAbsDeduct;
    
    // Step 7: Net Pay
    VNet := VGross - VSSAmt - VIrg - VAbsDeduct;
    Rec.NetPay := VNet;
    
    Result := Rec;
    
  except
    Rec.Free;
    Emp.Free;
    if Assigned(Allowances) then Allowances.Free;
    raise;
  end;
  
  Emp.Free;
  if Assigned(Allowances) then Allowances.Free;
end;

end.
