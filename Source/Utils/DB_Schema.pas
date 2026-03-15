unit DB_Schema;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Comp.Client;

type
  TDBSchema = class
  public
    class procedure CreateAllTables(AConnection: TFDConnection);
    class procedure CreateIndexes(AConnection: TFDConnection);
    class procedure ExecuteSQL(AConnection: TFDConnection; const ASQL: string);
  end;

implementation

class procedure TDBSchema.ExecuteSQL(AConnection: TFDConnection; const ASQL: string);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConnection;
    LQuery.SQL.Text := ASQL;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

class procedure TDBSchema.CreateAllTables(AConnection: TFDConnection);
begin
  // 1. Departments
  ExecuteSQL(AConnection,
    'CREATE TABLE IF NOT EXISTS departments (' +
    '  id       TEXT PRIMARY KEY,' +
    '  name_ar  TEXT NOT NULL,' +
    '  name_fr  TEXT NOT NULL,' +
    '  name_en  TEXT NOT NULL' +
    ')');

  // 2. Users (Auth)
  ExecuteSQL(AConnection,
    'CREATE TABLE IF NOT EXISTS users (' +
    '  id           INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  username     TEXT NOT NULL UNIQUE,' +
    '  password_hash TEXT NOT NULL,' +
    '  full_name    TEXT NOT NULL,' +
    '  role         TEXT NOT NULL DEFAULT ''viewer'',' +  // admin, payroll_officer, viewer
    '  is_active    INTEGER DEFAULT 1,' +
    '  last_login   TEXT,' +
    '  login_attempts INTEGER DEFAULT 0,' +
    '  created_at   TEXT DEFAULT (datetime(''now'')),' +
    '  updated_at   TEXT DEFAULT (datetime(''now''))' +
    ')');

  // 3. Employees
  ExecuteSQL(AConnection,
    'CREATE TABLE IF NOT EXISTS employees (' +
    '  id              INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  employee_number TEXT UNIQUE,' +
    '  last_name       TEXT NOT NULL,' +
    '  first_name      TEXT NOT NULL,' +
    '  national_id     TEXT,' +
    '  department_id   TEXT REFERENCES departments(id),' +
    '  position_ar     TEXT,' +
    '  position_fr     TEXT,' +
    '  class           INTEGER DEFAULT 1,' +
    '  index_number    INTEGER,' +
    '  degree          INTEGER DEFAULT 0,' +
    '  points          INTEGER DEFAULT 0,' +
    '  hire_date       TEXT,' +
    '  is_active       INTEGER DEFAULT 1,' +
    '  created_at      TEXT DEFAULT (datetime(''now'')),' +
    '  updated_at      TEXT DEFAULT (datetime(''now''))' +
    ')');

  // 4. Allowance type definitions
  ExecuteSQL(AConnection,
    'CREATE TABLE IF NOT EXISTS allowance_types (' +
    '  id          TEXT PRIMARY KEY,' +
    '  code        TEXT NOT NULL,' +
    '  name_ar     TEXT NOT NULL,' +
    '  name_fr     TEXT NOT NULL,' +
    '  name_en     TEXT NOT NULL,' +
    '  description TEXT,' +
    '  is_active   INTEGER DEFAULT 1' +
    ')');

  // 5. Allowance-to-department mapping
  ExecuteSQL(AConnection,
    'CREATE TABLE IF NOT EXISTS allowance_department (' +
    '  allowance_id  TEXT REFERENCES allowance_types(id),' +
    '  department_id TEXT REFERENCES departments(id),' +
    '  PRIMARY KEY (allowance_id, department_id)' +
    ')');

  // 6. Employee-specific allowance amounts
  ExecuteSQL(AConnection,
    'CREATE TABLE IF NOT EXISTS employee_allowances (' +
    '  employee_id   INTEGER REFERENCES employees(id),' +
    '  allowance_id  TEXT REFERENCES allowance_types(id),' +
    '  amount        REAL DEFAULT 0,' +
    '  PRIMARY KEY (employee_id, allowance_id)' +
    ')');

  // 7. Bareme salary scale
  ExecuteSQL(AConnection,
    'CREATE TABLE IF NOT EXISTS bareme (' +
    '  id           INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  class        INTEGER NOT NULL,' +
    '  degree       INTEGER NOT NULL,' +
    '  index_number INTEGER NOT NULL,' +
    '  point_value  REAL NOT NULL,' +
    '  base_salary  REAL NOT NULL,' +
    '  year         INTEGER DEFAULT 2024' +
    ')');

  // 8. IRG Tax lookup table
  ExecuteSQL(AConnection,
    'CREATE TABLE IF NOT EXISTS irg_table (' +
    '  id          INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  income_from REAL NOT NULL,' +
    '  income_to   REAL NOT NULL,' +
    '  tax_amount  REAL NOT NULL' +
    ')');

  // 9. Monthly salary records (finalized)
  ExecuteSQL(AConnection,
    'CREATE TABLE IF NOT EXISTS salary_records (' +
    '  id                       INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  employee_id              INTEGER REFERENCES employees(id),' +
    '  month                    INTEGER NOT NULL,' +
    '  year                     INTEGER NOT NULL,' +
    '  days_worked              INTEGER DEFAULT 30,' +
    '  absent_days              INTEGER DEFAULT 0,' +
    '  base_salary              REAL DEFAULT 0,' +
    '  infection_allowance      REAL DEFAULT 0,' +
    '  documentation_allowance  REAL DEFAULT 0,' +
    '  qualification_allowance  REAL DEFAULT 0,' +
    '  supervision_allowance    REAL DEFAULT 0,' +
    '  health_activity_support  REAL DEFAULT 0,' +
    '  obstetric_allowance      REAL DEFAULT 0,' +
    '  mother_child_health      REAL DEFAULT 0,' +
    '  flat_rate_bonus          REAL DEFAULT 0,' +
    '  gross_salary             REAL DEFAULT 0,' +
    '  social_security          REAL DEFAULT 0,' +
    '  taxable_income           REAL DEFAULT 0,' +
    '  irg_tax                  REAL DEFAULT 0,' +
    '  absence_deduction        REAL DEFAULT 0,' +
    '  net_pay                  REAL DEFAULT 0,' +
    '  is_locked                INTEGER DEFAULT 0,' +
    '  created_at               TEXT DEFAULT (datetime(''now'')),' +
    '  UNIQUE(employee_id, month, year)' +
    ')');

  // 10. Application settings
  ExecuteSQL(AConnection,
    'CREATE TABLE IF NOT EXISTS settings (' +
    '  key   TEXT PRIMARY KEY,' +
    '  value TEXT' +
    ')');
end;

class procedure TDBSchema.CreateIndexes(AConnection: TFDConnection);
begin
  ExecuteSQL(AConnection,
    'CREATE INDEX IF NOT EXISTS idx_employees_dept ON employees(department_id)');
  ExecuteSQL(AConnection,
    'CREATE INDEX IF NOT EXISTS idx_salary_emp_month_year ON salary_records(employee_id, month, year)');
  ExecuteSQL(AConnection,
    'CREATE INDEX IF NOT EXISTS idx_salary_month_year ON salary_records(month, year)');
  ExecuteSQL(AConnection,
    'CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)');
end;

end.
