unit Engine_IRG;

interface

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, DM_Database;

type
  TEngineIRG = class
  public
    class function CalculateIRG(const ATaxableIncome: Double): Double;
  end;

implementation

{ TEngineIRG }

class function TEngineIRG.CalculateIRG(const ATaxableIncome: Double): Double;
var
  Q: TFDQuery;
begin
  Result := 0;
  if ATaxableIncome <= 0 then Exit;
  
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DMDatabase.Connection;
    // Find the bracket where taxable income falls
    Q.SQL.Text := 
      'SELECT tax_amount FROM irg_table ' +
      'WHERE :pIncome >= income_from AND :pIncome <= income_to ' +
      'ORDER BY income_from DESC LIMIT 1';
      
    Q.ParamByName('pIncome').AsFloat := ATaxableIncome;
    Q.Open;
    
    if not Q.IsEmpty then
    begin
      Result := Q.FieldByName('tax_amount').AsFloat;
    end
    else
    begin
      // Fallback to highest bracket if exceeds the table
      Q.Close;
      Q.SQL.Text := 'SELECT tax_amount FROM irg_table ORDER BY income_to DESC LIMIT 1';
      Q.Open;
      if not Q.IsEmpty then
        Result := Q.FieldByName('tax_amount').AsFloat;
    end;
  finally
    Q.Free;
  end;
end;

end.
