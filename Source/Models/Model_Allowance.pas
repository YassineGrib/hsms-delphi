unit Model_Allowance;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client, Data.DB, DM_Database;

type
  TAllowanceType = class
  private
    FId: string;
    FCode: string;
    FNameAr: string;
    FNameFr: string;
    FNameEn: string;
    FDescription: string;
    FIsActive: Boolean;
  public
    property Id: string read FId write FId;
    property Code: string read FCode write FCode;
    property NameAr: string read FNameAr write FNameAr;
    property NameFr: string read FNameFr write FNameFr;
    property NameEn: string read FNameEn write FNameEn;
    property Description: string read FDescription write FDescription;
    property IsActive: Boolean read FIsActive write FIsActive;
    
    procedure LoadFromDataset(Dataset: TDataSet);
    class function GetAllAllowanceTypes: TObjectList<TAllowanceType>;
    class function GetByDepartment(const ADepartmentId: string): TObjectList<TAllowanceType>;
  end;

  TEmployeeAllowance = class
  private
    FEmployeeId: Integer;
    FAllowanceId: string;
    FAmount: Double;
  public
    property EmployeeId: Integer read FEmployeeId write FEmployeeId;
    property AllowanceId: string read FAllowanceId write FAllowanceId;
    property Amount: Double read FAmount write FAmount;
    
    procedure Save;
    class function GetEmployeeAllowances(const AEmployeeId: Integer): TObjectList<TEmployeeAllowance>;
  end;

implementation

{ TAllowanceType }

procedure TAllowanceType.LoadFromDataset(Dataset: TDataSet);
begin
  FId := Dataset.FieldByName('id').AsString;
  FCode := Dataset.FieldByName('code').AsString;
  FNameAr := Dataset.FieldByName('name_ar').AsString;
  FNameFr := Dataset.FieldByName('name_fr').AsString;
  FNameEn := Dataset.FieldByName('name_en').AsString;
  FDescription := Dataset.FieldByName('description').AsString;
  FIsActive := Dataset.FieldByName('is_active').AsInteger = 1;
end;

class function TAllowanceType.GetAllAllowanceTypes: TObjectList<TAllowanceType>;
var
  Q: TFDQuery;
  LList: TObjectList<TAllowanceType>;
  LItem: TAllowanceType;
begin
  LList := TObjectList<TAllowanceType>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    Q.SQL.Text := 'SELECT * FROM allowance_types WHERE is_active = 1 ORDER BY code';
    Q.Open;
    
    while not Q.Eof do
    begin
      LItem := TAllowanceType.Create;
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

class function TAllowanceType.GetByDepartment(const ADepartmentId: string): TObjectList<TAllowanceType>;
var
  Q: TFDQuery;
  LList: TObjectList<TAllowanceType>;
  LItem: TAllowanceType;
begin
  LList := TObjectList<TAllowanceType>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    Q.SQL.Text := 
      'SELECT a.* FROM allowance_types a ' +
      'JOIN allowance_department ad ON a.id = ad.allowance_id ' +
      'WHERE ad.department_id = :pDeptId AND a.is_active = 1 ' +
      'ORDER BY a.code';
    Q.ParamByName('pDeptId').AsString := ADepartmentId;
    Q.Open;
    
    while not Q.Eof do
    begin
      LItem := TAllowanceType.Create;
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

{ TEmployeeAllowance }

procedure TEmployeeAllowance.Save;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    // UPSERT basically (Insert or Replace)
    Q.SQL.Text := 
      'INSERT INTO employee_allowances (employee_id, allowance_id, amount) ' +
      'VALUES (:pEmpId, :pAllId, :pAmt) ' +
      'ON CONFLICT(employee_id, allowance_id) DO UPDATE SET amount = :pAmt';
      
    Q.ParamByName('pEmpId').AsInteger := FEmployeeId;
    Q.ParamByName('pAllId').AsString := FAllowanceId;
    Q.ParamByName('pAmt').AsFloat := FAmount;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

class function TEmployeeAllowance.GetEmployeeAllowances(const AEmployeeId: Integer): TObjectList<TEmployeeAllowance>;
var
  Q: TFDQuery;
  LList: TObjectList<TEmployeeAllowance>;
  LItem: TEmployeeAllowance;
begin
  LList := TObjectList<TEmployeeAllowance>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    Q.SQL.Text := 'SELECT * FROM employee_allowances WHERE employee_id = :pEmpId';
    Q.ParamByName('pEmpId').AsInteger := AEmployeeId;
    Q.Open;
    
    while not Q.Eof do
    begin
      LItem := TEmployeeAllowance.Create;
      LItem.EmployeeId := Q.FieldByName('employee_id').AsInteger;
      LItem.AllowanceId := Q.FieldByName('allowance_id').AsString;
      LItem.Amount := Q.FieldByName('amount').AsFloat;
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
