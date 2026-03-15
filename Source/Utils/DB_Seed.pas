unit DB_Seed;

interface

uses
  System.SysUtils, FireDAC.Comp.Client;

type
  TDBSeed = class
  public
    class procedure SeedAll(AConnection: TFDConnection);
  private
    class procedure SeedDepartments(AConnection: TFDConnection);
    class procedure SeedAllowanceTypes(AConnection: TFDConnection);
    class procedure SeedAllowanceDepartmentMapping(AConnection: TFDConnection);
    class procedure SeedSettings(AConnection: TFDConnection);
    class procedure SeedDefaultAdmin(AConnection: TFDConnection);
    class procedure SeedIRGTable(AConnection: TFDConnection);
    class function TableIsEmpty(AConnection: TFDConnection; const ATable: string): Boolean;
    class procedure ExecInsert(AConnection: TFDConnection; const ASQL: string);
  end;

implementation

uses
  System.Hash;

class function TDBSeed.TableIsEmpty(AConnection: TFDConnection; const ATable: string): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text := 'SELECT COUNT(*) AS cnt FROM ' + ATable;
    Q.Open;
    Result := Q.FieldByName('cnt').AsInteger = 0;
  finally
    Q.Free;
  end;
end;

class procedure TDBSeed.ExecInsert(AConnection: TFDConnection; const ASQL: string);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text := ASQL;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

class procedure TDBSeed.SeedAll(AConnection: TFDConnection);
begin
  SeedDepartments(AConnection);
  SeedAllowanceTypes(AConnection);
  SeedAllowanceDepartmentMapping(AConnection);
  SeedSettings(AConnection);
  SeedDefaultAdmin(AConnection);
  SeedIRGTable(AConnection);
end;

class procedure TDBSeed.SeedDepartments(AConnection: TFDConnection);
begin
  if not TableIsEmpty(AConnection, 'departments') then Exit;

  ExecInsert(AConnection, 'INSERT INTO departments (id, name_ar, name_fr, name_en) VALUES ' +
    '(''doctors'',        ''أطباء'',           ''Médecins'',                       ''Doctors'')');
  ExecInsert(AConnection, 'INSERT INTO departments (id, name_ar, name_fr, name_en) VALUES ' +
    '(''specialists'', ''ممارس متخصص'', ''Praticiens Specialistes'', ''Specialist Practitioners'')');
  ExecInsert(AConnection, 'INSERT INTO departments (id, name_ar, name_fr, name_en) VALUES ' +
    '(''paramedical'', ''شبه طبي'', ''Personnel Para-Medical'', ''Paramedical Staff'')');
  ExecInsert(AConnection, 'INSERT INTO departments (id, name_ar, name_fr, name_en) VALUES ' +
    '(''administrative'', ''إداري'',           ''Personnel Administratif'',         ''Administrative Staff'')');
  ExecInsert(AConnection, 'INSERT INTO departments (id, name_ar, name_fr, name_en) VALUES ' +
    '(''contractual'',    ''متعاقدين'',        ''Contractuels'',                    ''Contractual Workers'')');
  ExecInsert(AConnection, 'INSERT INTO departments (id, name_ar, name_fr, name_en) VALUES ' +
    '(''workers'',        ''عمال'',            ''Ouvriers / Personnel de Soutien'', ''Workers / Support Staff'')');
end;

class procedure TDBSeed.SeedAllowanceTypes(AConnection: TFDConnection);
begin
  if not TableIsEmpty(AConnection, 'allowance_types') then Exit;

  ExecInsert(AConnection,
    'INSERT INTO allowance_types (id, code, name_ar, name_fr, name_en) VALUES ' +
    '(''base_salary'', ''1-1-1'', ''الأجر الأساسي'', ''Salaire de Base'', ''Base Salary'')');

  ExecInsert(AConnection,
    'INSERT INTO allowance_types (id, code, name_ar, name_fr, name_en) VALUES ' +
    '(''infection_allowance'', ''2-2-1'', ''تعويض العدوى'', ' +
    '''Indemnité de Contagion'', ''Infection Allowance'')');

  ExecInsert(AConnection,
    'INSERT INTO allowance_types (id, code, name_ar, name_fr, name_en) VALUES ' +
    '(''documentation_allowance'', ''3-2-1'', ''تعويض التوثيق'', ' +
    '''Indemnité de Documentation'', ''Documentation Allowance'')');

  ExecInsert(AConnection,
    'INSERT INTO allowance_types (id, code, name_ar, name_fr, name_en) VALUES ' +
    '(''qualification_allowance'', ''7-2-1'', ''تعويض التأهيل'', ' +
    '''Indemnité de Qualification'', ''Qualification Allowance'')');

  ExecInsert(AConnection,
    'INSERT INTO allowance_types (id, code, name_ar, name_fr, name_en) VALUES ' +
    '(''supervision_allowance'', ''8-2-1'', ''التأطير'', ' +
    '''Indemnite d''''Encadrement'', ''Supervision Allowance'')');

  ExecInsert(AConnection,
    'INSERT INTO allowance_types (id, code, name_ar, name_fr, name_en) VALUES ' +
    '(''health_activity_support'', ''20-2-1'', ''تعويض دعم نشاطات الصحة'', ' +
    '''Indemnite de Soutien aux Activites de Sante'', ''Health Activity Support'')');

  ExecInsert(AConnection,
    'INSERT INTO allowance_types (id, code, name_ar, name_fr, name_en) VALUES ' +
    '(''obstetric_allowance'', ''20-2-1'', ''تعويض الإلزام لعلاجات التوليد'', ' +
    '''Indemnite Obstetrique et Sante Reproductive'', ''Obstetric Allowance'')');

  ExecInsert(AConnection,
    'INSERT INTO allowance_types (id, code, name_ar, name_fr, name_en) VALUES ' +
    '(''mother_child_health'', ''20-2-1'', ''تعويض دعم صحة الأم والطفل'', ' +
    '''Indemnite de Soutien Sante Mere-Enfant'', ''Mother and Child Health'')');

  ExecInsert(AConnection,
    'INSERT INTO allowance_types (id, code, name_ar, name_fr, name_en) VALUES ' +
    '(''flat_rate_bonus'', ''39-2-1'', ''المنحة الجزافية'', ' +
    '''Prime Forfaitaire'', ''Flat Rate Bonus'')');
end;

class procedure TDBSeed.SeedAllowanceDepartmentMapping(AConnection: TFDConnection);
begin
  if not TableIsEmpty(AConnection, 'allowance_department') then Exit;

  // base_salary -> all
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''base_salary'', ''doctors'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''base_salary'', ''specialists'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''base_salary'', ''paramedical'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''base_salary'', ''administrative'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''base_salary'', ''contractual'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''base_salary'', ''workers'')');

  // infection_allowance -> doctors, specialists, paramedical
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''infection_allowance'', ''doctors'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''infection_allowance'', ''specialists'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''infection_allowance'', ''paramedical'')');

  // documentation_allowance -> doctors, specialists, paramedical
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''documentation_allowance'', ''doctors'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''documentation_allowance'', ''specialists'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''documentation_allowance'', ''paramedical'')');

  // qualification_allowance -> doctors, specialists, paramedical
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''qualification_allowance'', ''doctors'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''qualification_allowance'', ''specialists'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''qualification_allowance'', ''paramedical'')');

  // supervision_allowance -> doctors, specialists only
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''supervision_allowance'', ''doctors'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''supervision_allowance'', ''specialists'')');

  // health_activity_support -> doctors, specialists, paramedical
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''health_activity_support'', ''doctors'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''health_activity_support'', ''specialists'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''health_activity_support'', ''paramedical'')');

  // obstetric_allowance -> doctors, specialists, paramedical
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''obstetric_allowance'', ''doctors'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''obstetric_allowance'', ''specialists'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''obstetric_allowance'', ''paramedical'')');

  // mother_child_health -> doctors, specialists, paramedical
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''mother_child_health'', ''doctors'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''mother_child_health'', ''specialists'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''mother_child_health'', ''paramedical'')');

  // flat_rate_bonus -> all
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''flat_rate_bonus'', ''doctors'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''flat_rate_bonus'', ''specialists'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''flat_rate_bonus'', ''paramedical'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''flat_rate_bonus'', ''administrative'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''flat_rate_bonus'', ''contractual'')');
  ExecInsert(AConnection, 'INSERT INTO allowance_department VALUES (''flat_rate_bonus'', ''workers'')');
end;

class procedure TDBSeed.SeedSettings(AConnection: TFDConnection);
begin
  if not TableIsEmpty(AConnection, 'settings') then Exit;

  ExecInsert(AConnection, 'INSERT INTO settings VALUES (''institution_name_ar'', ''المؤسسة العمومية الاستشفائية'')');
  ExecInsert(AConnection, 'INSERT INTO settings VALUES (''institution_name_fr'', ''Établissement Public Hospitalier'')');
  ExecInsert(AConnection, 'INSERT INTO settings VALUES (''institution_name_en'', ''Public Hospital Establishment'')');
  ExecInsert(AConnection, 'INSERT INTO settings VALUES (''ministry_ar'', ''وزارة الصحة'')');
  ExecInsert(AConnection, 'INSERT INTO settings VALUES (''ministry_fr'', ''Ministère de la Santé'')');
  ExecInsert(AConnection, 'INSERT INTO settings VALUES (''directorate'', ''-'')');
  ExecInsert(AConnection, 'INSERT INTO settings VALUES (''wilaya'', ''-'')');
  ExecInsert(AConnection, 'INSERT INTO settings VALUES (''working_days_per_month'', ''30'')');
  ExecInsert(AConnection, 'INSERT INTO settings VALUES (''social_security_rate'', ''0.09'')');
  ExecInsert(AConnection, 'INSERT INTO settings VALUES (''current_bareme_year'', ''2024'')');
  ExecInsert(AConnection, 'INSERT INTO settings VALUES (''app_language'', ''fr'')');
  ExecInsert(AConnection, 'INSERT INTO settings VALUES (''db_version'', ''1'')');
end;

class procedure TDBSeed.SeedDefaultAdmin(AConnection: TFDConnection);
var
  Hash: string;
begin
  if not TableIsEmpty(AConnection, 'users') then Exit;

  // Default admin password: "admin" — SHA256 hashed
  Hash := THashSHA2.GetHashString('admin');

  ExecInsert(AConnection,
    'INSERT INTO users (username, password_hash, full_name, role) VALUES ' +
    '(''admin'', ''' + Hash + ''', ''Administrateur'', ''admin'')');
end;

class procedure TDBSeed.SeedIRGTable(AConnection: TFDConnection);
begin
  if not TableIsEmpty(AConnection, 'irg_table') then Exit;

  // Algerian IRG progressive brackets for salaried employees (monthly)
  // These are the main bracket thresholds — can be extended with full table
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (0, 10000, 0)');
  // For 10001-30000: 20% of amount above 10000
  // For 30001-120000: 4000 + 30% of amount above 30000
  // For 120001+: 31000 + 35% of amount above 120000
  // Representative bracket entries stored for range lookup:
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (10001, 10500, 100)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (10501, 11000, 200)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (11001, 11500, 300)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (11501, 12000, 400)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (12001, 15000, 1000)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (15001, 20000, 2000)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (20001, 25000, 3000)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (25001, 30000, 4000)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (30001, 40000, 7000)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (40001, 50000, 10000)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (50001, 60000, 13000)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (60001, 70000, 16000)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (70001, 80000, 19000)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (80001, 90000, 22000)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (90001, 100000, 25000)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (100001, 120000, 31000)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (120001, 150000, 41500)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (150001, 200000, 52000)');
  ExecInsert(AConnection, 'INSERT INTO irg_table (income_from, income_to, tax_amount) VALUES (200001, 999999999, 75000)');
end;

end.
