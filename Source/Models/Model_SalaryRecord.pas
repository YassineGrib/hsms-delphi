unit Model_SalaryRecord;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client, Data.DB, DM_Database;

type
  TSalaryRecord = class
  private
    FId: Integer;
    FEmployeeId: Integer;
    FMonth: Integer;
    FYear: Integer;
    FDaysWorked: Integer;
    FAbsentDays: Integer;
    
    // Earnings
    FBaseSalary: Double;
    FInfectionAllowance: Double;
    FDocumentationAllowance: Double;
    FQualificationAllowance: Double;
    FSupervisionAllowance: Double;
    FHealthActivitySupport: Double;
    FObstetricAllowance: Double;
    FMotherChildHealth: Double;
    FFlatRateBonus: Double;
    
    // Totals & Deductions
    FGrossSalary: Double;
    FSocialSecurity: Double;
    FTaxableIncome: Double;
    FIrgTax: Double;
    FAbsenceDeduction: Double;
    FNetPay: Double;
    
    // Meta
    FIsLocked: Boolean;
    FCreatedAt: string;
  public
    constructor Create;
    
    property Id: Integer read FId write FId;
    property EmployeeId: Integer read FEmployeeId write FEmployeeId;
    property Month: Integer read FMonth write FMonth;
    property Year: Integer read FYear write FYear;
    property DaysWorked: Integer read FDaysWorked write FDaysWorked;
    property AbsentDays: Integer read FAbsentDays write FAbsentDays;
    
    property BaseSalary: Double read FBaseSalary write FBaseSalary;
    property InfectionAllowance: Double read FInfectionAllowance write FInfectionAllowance;
    property DocumentationAllowance: Double read FDocumentationAllowance write FDocumentationAllowance;
    property QualificationAllowance: Double read FQualificationAllowance write FQualificationAllowance;
    property SupervisionAllowance: Double read FSupervisionAllowance write FSupervisionAllowance;
    property HealthActivitySupport: Double read FHealthActivitySupport write FHealthActivitySupport;
    property ObstetricAllowance: Double read FObstetricAllowance write FObstetricAllowance;
    property MotherChildHealth: Double read FMotherChildHealth write FMotherChildHealth;
    property FlatRateBonus: Double read FFlatRateBonus write FFlatRateBonus;
    
    property GrossSalary: Double read FGrossSalary write FGrossSalary;
    property SocialSecurity: Double read FSocialSecurity write FSocialSecurity;
    property TaxableIncome: Double read FTaxableIncome write FTaxableIncome;
    property IrgTax: Double read FIrgTax write FIrgTax;
    property AbsenceDeduction: Double read FAbsenceDeduction write FAbsenceDeduction;
    property NetPay: Double read FNetPay write FNetPay;
    
    property IsLocked: Boolean read FIsLocked write FIsLocked;
    property CreatedAt: string read FCreatedAt write FCreatedAt;
    
    // CRUD
    function Save: Boolean;
    procedure LoadFromDataset(Dataset: TDataSet);
    
    // Static loading
    class function LoadByEmployeeMonth(const AEmployeeId, AMonth, AYear: Integer): TSalaryRecord;
    class function GetRecordsByMonth(const AMonth, AYear: Integer): TObjectList<TSalaryRecord>;
  end;

implementation

{ TSalaryRecord }

constructor TSalaryRecord.Create;
begin
  FId := 0;
  FEmployeeId := 0;
  FMonth := 0;
  FYear := 0;
  FDaysWorked := 30;
  FAbsentDays := 0;
  
  FBaseSalary := 0;
  FInfectionAllowance := 0;
  FDocumentationAllowance := 0;
  FQualificationAllowance := 0;
  FSupervisionAllowance := 0;
  FHealthActivitySupport := 0;
  FObstetricAllowance := 0;
  FMotherChildHealth := 0;
  FFlatRateBonus := 0;
  
  FGrossSalary := 0;
  FSocialSecurity := 0;
  FTaxableIncome := 0;
  FIrgTax := 0;
  FAbsenceDeduction := 0;
  FNetPay := 0;
  
  FIsLocked := False;
  FCreatedAt := '';
end;

procedure TSalaryRecord.LoadFromDataset(Dataset: TDataSet);
begin
  FId := Dataset.FieldByName('id').AsInteger;
  FEmployeeId := Dataset.FieldByName('employee_id').AsInteger;
  FMonth := Dataset.FieldByName('month').AsInteger;
  FYear := Dataset.FieldByName('year').AsInteger;
  FDaysWorked := Dataset.FieldByName('days_worked').AsInteger;
  FAbsentDays := Dataset.FieldByName('absent_days').AsInteger;
  
  FBaseSalary := Dataset.FieldByName('base_salary').AsFloat;
  FInfectionAllowance := Dataset.FieldByName('infection_allowance').AsFloat;
  FDocumentationAllowance := Dataset.FieldByName('documentation_allowance').AsFloat;
  FQualificationAllowance := Dataset.FieldByName('qualification_allowance').AsFloat;
  FSupervisionAllowance := Dataset.FieldByName('supervision_allowance').AsFloat;
  FHealthActivitySupport := Dataset.FieldByName('health_activity_support').AsFloat;
  FObstetricAllowance := Dataset.FieldByName('obstetric_allowance').AsFloat;
  FMotherChildHealth := Dataset.FieldByName('mother_child_health').AsFloat;
  FFlatRateBonus := Dataset.FieldByName('flat_rate_bonus').AsFloat;
  
  FGrossSalary := Dataset.FieldByName('gross_salary').AsFloat;
  FSocialSecurity := Dataset.FieldByName('social_security').AsFloat;
  FTaxableIncome := Dataset.FieldByName('taxable_income').AsFloat;
  FIrgTax := Dataset.FieldByName('irg_tax').AsFloat;
  FAbsenceDeduction := Dataset.FieldByName('absence_deduction').AsFloat;
  FNetPay := Dataset.FieldByName('net_pay').AsFloat;
  
  FIsLocked := Dataset.FieldByName('is_locked').AsInteger = 1;
  FCreatedAt := Dataset.FieldByName('created_at').AsString;
end;

function TSalaryRecord.Save: Boolean;
var
  Q: TFDQuery;
begin
  Result := False;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    
    Q.SQL.Text := 
      'INSERT INTO salary_records ' +
      '(employee_id, month, year, days_worked, absent_days, base_salary, ' +
      'infection_allowance, documentation_allowance, qualification_allowance, supervision_allowance, ' +
      'health_activity_support, obstetric_allowance, mother_child_health, flat_rate_bonus, ' +
      'gross_salary, social_security, taxable_income, irg_tax, absence_deduction, net_pay, is_locked) ' +
      'VALUES ' +
      '(:pEmp, :pMonth, :pYear, :pDays, :pAbs, :pBase, ' +
      ':pInf, :pDoc, :pQual, :pSup, :pHealth, :pObst, :pMother, :pFlat, ' +
      ':pGross, :pSS, :pTaxable, :pIrg, :pAbsDed, :pNet, :pLocked) ' +
      'ON CONFLICT(employee_id, month, year) DO UPDATE SET ' +
      'days_worked=:pDays, absent_days=:pAbs, base_salary=:pBase, ' +
      'infection_allowance=:pInf, documentation_allowance=:pDoc, qualification_allowance=:pQual, ' +
      'supervision_allowance=:pSup, health_activity_support=:pHealth, obstetric_allowance=:pObst, ' +
      'mother_child_health=:pMother, flat_rate_bonus=:pFlat, ' +
      'gross_salary=:pGross, social_security=:pSS, taxable_income=:pTaxable, ' +
      'irg_tax=:pIrg, absence_deduction=:pAbsDed, net_pay=:pNet, is_locked=:pLocked; ' +
      'SELECT id FROM salary_records WHERE employee_id=:pEmp AND month=:pMonth AND year=:pYear;';
      
    Q.ParamByName('pEmp').AsInteger := FEmployeeId;
    Q.ParamByName('pMonth').AsInteger := FMonth;
    Q.ParamByName('pYear').AsInteger := FYear;
    Q.ParamByName('pDays').AsInteger := FDaysWorked;
    Q.ParamByName('pAbs').AsInteger := FAbsentDays;
    
    Q.ParamByName('pBase').AsFloat := FBaseSalary;
    Q.ParamByName('pInf').AsFloat := FInfectionAllowance;
    Q.ParamByName('pDoc').AsFloat := FDocumentationAllowance;
    Q.ParamByName('pQual').AsFloat := FQualificationAllowance;
    Q.ParamByName('pSup').AsFloat := FSupervisionAllowance;
    Q.ParamByName('pHealth').AsFloat := FHealthActivitySupport;
    Q.ParamByName('pObst').AsFloat := FObstetricAllowance;
    Q.ParamByName('pMother').AsFloat := FMotherChildHealth;
    Q.ParamByName('pFlat').AsFloat := FFlatRateBonus;
    
    Q.ParamByName('pGross').AsFloat := FGrossSalary;
    Q.ParamByName('pSS').AsFloat := FSocialSecurity;
    Q.ParamByName('pTaxable').AsFloat := FTaxableIncome;
    Q.ParamByName('pIrg').AsFloat := FIrgTax;
    Q.ParamByName('pAbsDed').AsFloat := FAbsenceDeduction;
    Q.ParamByName('pNet').AsFloat := FNetPay;
    
    if FIsLocked then
      Q.ParamByName('pLocked').AsInteger := 1
    else
      Q.ParamByName('pLocked').AsInteger := 0;

    Q.Open; // Because of SELECT id at the end
    if not Q.IsEmpty then
    begin
      FId := Q.FieldByName('id').AsInteger;
      Result := True;
    end;
  finally
    Q.Free;
  end;
end;

class function TSalaryRecord.LoadByEmployeeMonth(const AEmployeeId, AMonth, AYear: Integer): TSalaryRecord;
var
  Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    Q.SQL.Text := 'SELECT * FROM salary_records WHERE employee_id = :pEmp AND month = :pMonth AND year = :pYear LIMIT 1';
    Q.ParamByName('pEmp').AsInteger := AEmployeeId;
    Q.ParamByName('pMonth').AsInteger := AMonth;
    Q.ParamByName('pYear').AsInteger := AYear;
    Q.Open;
    
    if not Q.IsEmpty then
    begin
      Result := TSalaryRecord.Create;
      Result.LoadFromDataset(Q);
    end;
  finally
    Q.Free;
  end;
end;

class function TSalaryRecord.GetRecordsByMonth(const AMonth, AYear: Integer): TObjectList<TSalaryRecord>;
var
  Q: TFDQuery;
  LList: TObjectList<TSalaryRecord>;
  LItem: TSalaryRecord;
begin
  LList := TObjectList<TSalaryRecord>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    Q.SQL.Text := 'SELECT * FROM salary_records WHERE month = :pMonth AND year = :pYear ORDER BY id';
    Q.ParamByName('pMonth').AsInteger := AMonth;
    Q.ParamByName('pYear').AsInteger := AYear;
    Q.Open;
    
    while not Q.Eof do
    begin
      LItem := TSalaryRecord.Create;
      LItem.LoadFromDataset(Q);
      LList.Add(LItem);
      Q.Next;
    end;
    Result := LList;
  except
    LList.Free;
    Q.Free;
    raise;
  end;
  Q.Free;
end;

end.
