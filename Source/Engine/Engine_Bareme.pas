unit Engine_Bareme;

interface

uses
  System.SysUtils, System.Classes, Data.DB, FireDAC.Comp.Client, DM_Database;

type
  TBaremeInfo = record
    ClassNum: Integer;
    Degree: Integer;
    IndexNumber: Integer;
    PointValue: Double;
    BaseSalary: Double;
  end;

  TEngineBareme = class
  public
    class function GetBaremeInfo(AClass, ADegree: Integer; AYear: Integer = 2024): TBaremeInfo;
    class function GetBaseSalary(AClass, ADegree: Integer; AYear: Integer = 2024): Double;
  end;

implementation

{ TEngineBareme }

class function TEngineBareme.GetBaremeInfo(AClass, ADegree: Integer; AYear: Integer): TBaremeInfo;
var
  Q: TFDQuery;
begin
  // Set defaults in case not found in DB
  Result.ClassNum := AClass;
  Result.Degree := ADegree;
  Result.IndexNumber := 0;
  Result.PointValue := 45.0; // Standard Algerian point value
  Result.BaseSalary := 0;
  
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    Q.SQL.Text := 'SELECT * FROM bareme WHERE class = :pClass AND degree = :pDeg AND year = :pYear LIMIT 1';
    Q.ParamByName('pClass').AsInteger := AClass;
    Q.ParamByName('pDeg').AsInteger := ADegree;
    Q.ParamByName('pYear').AsInteger := AYear;
    Q.Open;
    
    if not Q.IsEmpty then
    begin
      Result.IndexNumber := Q.FieldByName('index_number').AsInteger;
      Result.PointValue := Q.FieldByName('point_value').AsFloat;
      Result.BaseSalary := Q.FieldByName('base_salary').AsFloat;
    end
    else
    begin
      // Fallback rough estimation if db isn't fully seeded
      Result.IndexNumber := (AClass * 50) + (ADegree * 20);
      Result.BaseSalary := Result.IndexNumber * Result.PointValue;
    end;
  finally
    Q.Free;
  end;
end;

class function TEngineBareme.GetBaseSalary(AClass, ADegree: Integer; AYear: Integer): Double;
begin
  Result := GetBaremeInfo(AClass, ADegree, AYear).BaseSalary;
end;

end.
