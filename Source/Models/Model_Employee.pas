unit Model_Employee;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client, Data.DB, DM_Database;

type
  TEmployee = class
  private
    FId: Integer;
    FEmployeeNumber: string;
    FLastName: string;
    FFirstName: string;
    FNationalId: string;
    FDepartmentId: string;
    FPositionAr: string;
    FPositionFr: string;
    FGradeClass: Integer;
    FIndexNumber: Integer;
    FDegree: Integer;
    FPoints: Integer;
    FHireDate: string;
    FIsActive: Boolean;
  public
    constructor Create;
    
    // Properties mapping to database fields
    property Id: Integer read FId write FId;
    property EmployeeNumber: string read FEmployeeNumber write FEmployeeNumber;
    property LastName: string read FLastName write FLastName;
    property FirstName: string read FFirstName write FFirstName;
    property NationalId: string read FNationalId write FNationalId;
    property DepartmentId: string read FDepartmentId write FDepartmentId;
    property PositionAr: string read FPositionAr write FPositionAr;
    property PositionFr: string read FPositionFr write FPositionFr;
    property GradeClass: Integer read FGradeClass write FGradeClass;
    property IndexNumber: Integer read FIndexNumber write FIndexNumber;
    property Degree: Integer read FDegree write FDegree;
    property Points: Integer read FPoints write FPoints;
    property HireDate: string read FHireDate write FHireDate;
    property IsActive: Boolean read FIsActive write FIsActive;
    
    // CRUD Operations
    function Save: Boolean;
    function Delete: Boolean;
    procedure LoadFromDataset(Dataset: TDataSet);
    class function LoadFromDB(AId: Integer): TEmployee;
    class function GetAllEmployees(const ASearchFilter: string = ''): TObjectList<TEmployee>;
    class function GenerateNextMatricule: string;
    
    // Helper functionality
    function FullName: string;
  end;

implementation

{ TEmployee }

constructor TEmployee.Create;
begin
  FId := 0;
  FEmployeeNumber := '';
  FLastName := '';
  FFirstName := '';
  FNationalId := '';
  FDepartmentId := '';
  FPositionAr := '';
  FPositionFr := '';
  FGradeClass := 1;
  FIndexNumber := 0;
  FDegree := 0;
  FPoints := 0;
  FHireDate := FormatDateTime('yyyy-mm-dd', Now);
  FIsActive := True;
end;

function TEmployee.FullName: string;
begin
  Result := FLastName + ' ' + FFirstName;
end;

procedure TEmployee.LoadFromDataset(Dataset: TDataSet);
begin
  FId := Dataset.FieldByName('id').AsInteger;
  FEmployeeNumber := Dataset.FieldByName('employee_number').AsString;
  FLastName := Dataset.FieldByName('last_name').AsString;
  FFirstName := Dataset.FieldByName('first_name').AsString;
  FNationalId := Dataset.FieldByName('national_id').AsString;
  FDepartmentId := Dataset.FieldByName('department_id').AsString;
  FPositionAr := Dataset.FieldByName('position_ar').AsString;
  FPositionFr := Dataset.FieldByName('position_fr').AsString;
  FGradeClass := Dataset.FieldByName('class').AsInteger;
  FIndexNumber := Dataset.FieldByName('index_number').AsInteger;
  FDegree := Dataset.FieldByName('degree').AsInteger;
  FPoints := Dataset.FieldByName('points').AsInteger;
  FHireDate := Dataset.FieldByName('hire_date').AsString;
  FIsActive := Dataset.FieldByName('is_active').AsInteger = 1;
end;

class function TEmployee.LoadFromDB(AId: Integer): TEmployee;
var
  Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    Q.SQL.Text := 'SELECT * FROM employees WHERE id = :pId LIMIT 1';
    Q.ParamByName('pId').AsInteger := AId;
    Q.Open;
    
    if not Q.IsEmpty then
    begin
      Result := TEmployee.Create;
      Result.LoadFromDataset(Q);
    end;
  finally
    Q.Free;
  end;
end;

class function TEmployee.GetAllEmployees(const ASearchFilter: string): TObjectList<TEmployee>;
var
  Q: TFDQuery;
  LList: TObjectList<TEmployee>;
  LEmp: TEmployee;
  SQLStr: string;
begin
  LList := TObjectList<TEmployee>.Create(True); // Owns objects
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    SQLStr := 'SELECT * FROM employees WHERE is_active = 1 ';
    
    if ASearchFilter <> '' then
    begin
      SQLStr := SQLStr + ' AND (last_name LIKE :Filter OR first_name LIKE :Filter OR employee_number LIKE :Filter) ';
    end;
    
    SQLStr := SQLStr + ' ORDER BY last_name, first_name';
    Q.SQL.Text := SQLStr;
    
    if ASearchFilter <> '' then
    begin
      Q.ParamByName('Filter').AsString := '%' + ASearchFilter + '%';
    end;
    
    Q.Open;
    while not Q.Eof do
    begin
      LEmp := TEmployee.Create;
      LEmp.LoadFromDataset(Q);
      LList.Add(LEmp);
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

class function TEmployee.GenerateNextMatricule: string;
var
  Q: TFDQuery;
  MaxCount: Integer;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    Q.SQL.Text := 'SELECT COUNT(*) as Total FROM employees';
    Q.Open;
    MaxCount := Q.FieldByName('Total').AsInteger + 1;
    Result := 'EMP-' + Format('%.3d', [MaxCount]);
  finally
    Q.Free;
  end;
end;

function TEmployee.Save: Boolean;
var
  Q: TFDQuery;
begin
  Result := False;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    
    if FId = 0 then
    begin
      // Insert new
      if FEmployeeNumber = '' then
        FEmployeeNumber := GenerateNextMatricule;
        
      Q.SQL.Text := 
        'INSERT INTO employees ' +
        '(employee_number, last_name, first_name, national_id, department_id, ' +
        'position_ar, position_fr, class, index_number, degree, points, hire_date, is_active) ' +
        'VALUES ' +
        '(:pNum, :pLast, :pFirst, :pNat, :pDept, :pPosAr, :pPosFr, :pClass, :pIdx, :pDeg, :pPts, :pHire, :pAct); ' +
        'SELECT last_insert_rowid() AS new_id;';
    end
    else
    begin
      // Update existing
      Q.SQL.Text := 
        'UPDATE employees SET ' +
        'employee_number = :pNum, last_name = :pLast, first_name = :pFirst, ' +
        'national_id = :pNat, department_id = :pDept, position_ar = :pPosAr, ' +
        'position_fr = :pPosFr, class = :pClass, index_number = :pIdx, ' +
        'degree = :pDeg, points = :pPts, hire_date = :pHire, is_active = :pAct ' +
        'WHERE id = :pId';
      Q.ParamByName('pId').AsInteger := FId;
    end;
    
    // Common Params
    Q.ParamByName('pNum').AsString := FEmployeeNumber;
    Q.ParamByName('pLast').AsString := FLastName;
    Q.ParamByName('pFirst').AsString := FFirstName;
    Q.ParamByName('pNat').AsString := FNationalId;
    Q.ParamByName('pDept').AsString := FDepartmentId;
    Q.ParamByName('pPosAr').AsString := FPositionAr;
    Q.ParamByName('pPosFr').AsString := FPositionFr;
    Q.ParamByName('pClass').AsInteger := FGradeClass;
    Q.ParamByName('pIdx').AsInteger := FIndexNumber;
    Q.ParamByName('pDeg').AsInteger := FDegree;
    Q.ParamByName('pPts').AsInteger := FPoints;
    Q.ParamByName('pHire').AsString := FHireDate;
    
    if FIsActive then
      Q.ParamByName('pAct').AsInteger := 1
    else
      Q.ParamByName('pAct').AsInteger := 0;

    if FId = 0 then
    begin
      Q.Open;
      FId := Q.FieldByName('new_id').AsInteger;
    end
    else
    begin
      Q.ExecSQL;
    end;
    Result := True;
  finally
    Q.Free;
  end;
end;

function TEmployee.Delete: Boolean;
var
  Q: TFDQuery;
begin
  Result := False;
  if FId = 0 then Exit; // Not saved yet
  
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    // We do a soft delete based on schema: is_active = 0
    // Actually PRD/DB uses is_active
    Q.SQL.Text := 'UPDATE employees SET is_active = 0, updated_at = datetime(''now'') WHERE id = :pId';
    Q.ParamByName('pId').AsInteger := FId;
    Q.ExecSQL;
    FIsActive := False;
    Result := True;
  finally
    Q.Free;
  end;
end;

end.
