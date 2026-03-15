unit DB_Helper;

interface

uses
  System.SysUtils, FireDAC.Comp.Client;

type
  TDBHelper = class
  private
    class var FConnection: TFDConnection;
  public
    class procedure SetConnection(AConn: TFDConnection);
    class function GetConnection: TFDConnection;

    // Settings
    class function GetSettingValue(const AKey: string): string;
    class procedure SetSettingValue(const AKey, AValue: string);
    class function GetSettingAsFloat(const AKey: string): Double;
    class function GetSettingAsInt(const AKey: string): Integer;

    // General utilities
    class function RecordExists(const ATable, AWhereClause: string): Boolean;
    class function CountRecords(const ATable: string; const AWhereClause: string = ''): Integer;
    class function GetNextID(const ATable: string): Integer;
    class function FormatMoney(const AValue: Double): string;
    class function FormatMoneySign(const AValue: Double; AIsDeduction: Boolean = True): string;
    class function HashPassword(const APassword: string): string;
  end;

implementation

uses
  System.Hash;

class procedure TDBHelper.SetConnection(AConn: TFDConnection);
begin
  FConnection := AConn;
end;

class function TDBHelper.GetConnection: TFDConnection;
begin
  Result := FConnection;
end;

class function TDBHelper.GetSettingValue(const AKey: string): string;
var
  Q: TFDQuery;
begin
  Result := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text := 'SELECT value FROM settings WHERE key = :k';
    Q.ParamByName('k').AsString := AKey;
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.FieldByName('value').AsString;
  finally
    Q.Free;
  end;
end;

class procedure TDBHelper.SetSettingValue(const AKey, AValue: string);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text :=
      'INSERT INTO settings (key, value) VALUES (:k, :v) ' +
      'ON CONFLICT(key) DO UPDATE SET value = :v2';
    Q.ParamByName('k').AsString := AKey;
    Q.ParamByName('v').AsString := AValue;
    Q.ParamByName('v2').AsString := AValue;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

class function TDBHelper.GetSettingAsFloat(const AKey: string): Double;
begin
  Result := StrToFloatDef(GetSettingValue(AKey), 0);
end;

class function TDBHelper.GetSettingAsInt(const AKey: string): Integer;
begin
  Result := StrToIntDef(GetSettingValue(AKey), 0);
end;

class function TDBHelper.RecordExists(const ATable, AWhereClause: string): Boolean;
begin
  Result := CountRecords(ATable, AWhereClause) > 0;
end;

class function TDBHelper.CountRecords(const ATable: string; const AWhereClause: string): Integer;
var
  Q: TFDQuery;
  SQL: string;
begin
  Result := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    SQL := 'SELECT COUNT(*) AS cnt FROM ' + ATable;
    if AWhereClause <> '' then
      SQL := SQL + ' WHERE ' + AWhereClause;
    Q.SQL.Text := SQL;
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

class function TDBHelper.GetNextID(const ATable: string): Integer;
var
  Q: TFDQuery;
begin
  Result := 1;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text := 'SELECT MAX(id) AS maxid FROM ' + ATable;
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.FieldByName('maxid').AsInteger + 1;
  finally
    Q.Free;
  end;
end;

class function TDBHelper.FormatMoney(const AValue: Double): string;
begin
  Result := FormatFloat('#,##0.00', AValue) + ' DA';
end;

class function TDBHelper.FormatMoneySign(const AValue: Double; AIsDeduction: Boolean): string;
begin
  if AIsDeduction then
    Result := '- ' + FormatFloat('#,##0.00', AValue) + ' DA'
  else
    Result := '+ ' + FormatFloat('#,##0.00', AValue) + ' DA';
end;

class function TDBHelper.HashPassword(const APassword: string): string;
begin
  Result := THashSHA2.GetHashString(APassword);
end;

end.
