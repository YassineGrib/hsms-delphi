unit Model_Department;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client, Data.DB, DM_Database;

type
  TDepartment = class
  private
    FId: string;
    FNameAr: string;
    FNameFr: string;
    FNameEn: string;
  public
    property Id: string read FId write FId;
    property NameAr: string read FNameAr write FNameAr;
    property NameFr: string read FNameFr write FNameFr;
    property NameEn: string read FNameEn write FNameEn;
    
    procedure LoadFromDataset(Dataset: TDataSet);
    class function GetAllDepartments: TObjectList<TDepartment>;
    class function GetDepartmentById(const AId: string): TDepartment;
  end;

implementation

{ TDepartment }

procedure TDepartment.LoadFromDataset(Dataset: TDataSet);
begin
  FId := Dataset.FieldByName('id').AsString;
  FNameAr := Dataset.FieldByName('name_ar').AsString;
  FNameFr := Dataset.FieldByName('name_fr').AsString;
  FNameEn := Dataset.FieldByName('name_en').AsString;
end;

class function TDepartment.GetAllDepartments: TObjectList<TDepartment>;
var
  Q: TFDQuery;
  LList: TObjectList<TDepartment>;
  LDept: TDepartment;
begin
  LList := TObjectList<TDepartment>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    Q.SQL.Text := 'SELECT * FROM departments ORDER BY name_fr';
    Q.Open;
    
    while not Q.Eof do
    begin
      LDept := TDepartment.Create;
      LDept.LoadFromDataset(Q);
      LList.Add(LDept);
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

class function TDepartment.GetDepartmentById(const AId: string): TDepartment;
var
  Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    Q.SQL.Text := 'SELECT * FROM departments WHERE id = :pId LIMIT 1';
    Q.ParamByName('pId').AsString := AId;
    Q.Open;
    
    if not Q.IsEmpty then
    begin
      Result := TDepartment.Create;
      Result.LoadFromDataset(Q);
    end;
  finally
    Q.Free;
  end;
end;

end.
