-- =========================================================
-- HSMS — Hospital Salary Management System
-- Système de Gestion des Salaires Hospitaliers
-- =========================================================
-- SQLite Database Schema — Version 1.0
-- Init script for reference and manual DB creation
-- =========================================================

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;
PRAGMA encoding = 'UTF-8';

-- ---------------------------------------------------------
-- 1. DEPARTMENTS (القسم / Département)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS departments (
    id       TEXT PRIMARY KEY,    -- 'doctors', 'paramedical', etc.
    name_ar  TEXT NOT NULL,       -- Arabic name
    name_fr  TEXT NOT NULL,       -- French name (UI primary)
    name_en  TEXT NOT NULL        -- English name
);

-- ---------------------------------------------------------
-- 2. USERS (Authentication & Roles)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    username       TEXT NOT NULL UNIQUE,
    password_hash  TEXT NOT NULL,         -- SHA-256 hash
    full_name      TEXT NOT NULL,
    role           TEXT NOT NULL DEFAULT 'viewer',
                                          -- 'admin' | 'payroll_officer' | 'viewer'
    is_active      INTEGER DEFAULT 1,
    last_login     TEXT,                  -- ISO 8601 datetime
    login_attempts INTEGER DEFAULT 0,     -- max 5 before lockout
    created_at     TEXT DEFAULT (datetime('now')),
    updated_at     TEXT DEFAULT (datetime('now'))
);

-- ---------------------------------------------------------
-- 3. EMPLOYEES (الموظفين / Employés)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS employees (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_number TEXT UNIQUE,
    last_name       TEXT NOT NULL,       -- اللقب / Nom
    first_name      TEXT NOT NULL,       -- الاسم / Prénom
    national_id     TEXT,               -- رقم التعريف الوطني
    department_id   TEXT REFERENCES departments(id),
    position_ar     TEXT,               -- الرتبة / الوظيفة
    position_fr     TEXT,               -- Poste / Grade (French)
    class           INTEGER DEFAULT 1,  -- الصنف (1-20 / Catégorie)
    index_number    INTEGER,            -- الرقم الاستدلالي / Indice
    degree          INTEGER DEFAULT 0,  -- الدرجة (0-12 / Échelon)
    points          INTEGER DEFAULT 0,  -- عدد النقاط
    hire_date       TEXT,               -- YYYY-MM-DD
    is_active       INTEGER DEFAULT 1,
    created_at      TEXT DEFAULT (datetime('now')),
    updated_at      TEXT DEFAULT (datetime('now'))
);

-- ---------------------------------------------------------
-- 4. ALLOWANCE TYPES (أنواع التعويضات / Types d'Indemnités)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS allowance_types (
    id          TEXT PRIMARY KEY,   -- 'infection_allowance', etc.
    code        TEXT NOT NULL,      -- '2-2-1'
    name_ar     TEXT NOT NULL,
    name_fr     TEXT NOT NULL,      -- (UI primary)
    name_en     TEXT NOT NULL,
    description TEXT,
    is_active   INTEGER DEFAULT 1
);

-- ---------------------------------------------------------
-- 5. ALLOWANCE ↔ DEPARTMENT MAPPING
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS allowance_department (
    allowance_id  TEXT REFERENCES allowance_types(id),
    department_id TEXT REFERENCES departments(id),
    PRIMARY KEY (allowance_id, department_id)
);

-- ---------------------------------------------------------
-- 6. EMPLOYEE ALLOWANCE AMOUNTS
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS employee_allowances (
    employee_id   INTEGER REFERENCES employees(id) ON DELETE CASCADE,
    allowance_id  TEXT    REFERENCES allowance_types(id),
    amount        REAL DEFAULT 0,
    PRIMARY KEY (employee_id, allowance_id)
);

-- ---------------------------------------------------------
-- 7. BAREME SALARY SCALE (جدول الأجور / Grille Salariale)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS bareme (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    class        INTEGER NOT NULL,    -- الصنف / Catégorie
    degree       INTEGER NOT NULL,    -- الدرجة / Échelon
    index_number INTEGER NOT NULL,    -- الرقم الاستدلالي / Indice
    point_value  REAL NOT NULL,       -- قيمة النقطة / Valeur du Point
    base_salary  REAL NOT NULL,       -- الأجر الأساسي / Salaire de Base
    year         INTEGER DEFAULT 2024
);

-- ---------------------------------------------------------
-- 8. IRG TAX LOOKUP TABLE (جدول الضريبة / Barème IRG)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS irg_table (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    income_from REAL NOT NULL,
    income_to   REAL NOT NULL,
    tax_amount  REAL NOT NULL
);

-- ---------------------------------------------------------
-- 9. MONTHLY SALARY RECORDS (سجلات الرواتب / Bulletins de Paie)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS salary_records (
    id                       INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id              INTEGER REFERENCES employees(id),
    month                    INTEGER NOT NULL,    -- 1-12
    year                     INTEGER NOT NULL,
    days_worked              INTEGER DEFAULT 30,
    absent_days              INTEGER DEFAULT 0,
    -- Earnings
    base_salary              REAL DEFAULT 0,
    infection_allowance      REAL DEFAULT 0,
    documentation_allowance  REAL DEFAULT 0,
    qualification_allowance  REAL DEFAULT 0,
    supervision_allowance    REAL DEFAULT 0,
    health_activity_support  REAL DEFAULT 0,
    obstetric_allowance      REAL DEFAULT 0,
    mother_child_health      REAL DEFAULT 0,
    flat_rate_bonus          REAL DEFAULT 0,
    -- Totals & Deductions
    gross_salary             REAL DEFAULT 0,  -- Salaire Brut
    social_security          REAL DEFAULT 0,  -- CNAS (9%)
    taxable_income           REAL DEFAULT 0,  -- Revenu Imposable
    irg_tax                  REAL DEFAULT 0,  -- IRG
    absence_deduction        REAL DEFAULT 0,  -- Retenue Absences
    net_pay                  REAL DEFAULT 0,  -- Salaire Net
    -- Meta
    is_locked                INTEGER DEFAULT 0,
    created_at               TEXT DEFAULT (datetime('now')),
    UNIQUE(employee_id, month, year)
);

-- ---------------------------------------------------------
-- 10. APPLICATION SETTINGS
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS settings (
    key   TEXT PRIMARY KEY,
    value TEXT
);

-- ---------------------------------------------------------
-- INDEXES
-- ---------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_employees_dept
    ON employees(department_id);

CREATE INDEX IF NOT EXISTS idx_salary_emp_month_year
    ON salary_records(employee_id, month, year);

CREATE INDEX IF NOT EXISTS idx_salary_month_year
    ON salary_records(month, year);

CREATE INDEX IF NOT EXISTS idx_users_username
    ON users(username);

-- ---------------------------------------------------------
-- DEFAULT SEED DATA
-- ---------------------------------------------------------

-- Departments
INSERT OR IGNORE INTO departments (id, name_ar, name_fr, name_en) VALUES
  ('doctors',        'أطباء',           'Médecins',                       'Doctors'),
  ('specialists',    'ممارس متخصص',     'Praticiens Spécialistes',         'Specialist Practitioners'),
  ('paramedical',    'شبه طبي',         'Personnel Para-Médical',          'Paramedical Staff'),
  ('administrative', 'إداري',           'Personnel Administratif',         'Administrative Staff'),
  ('contractual',    'متعاقدين',        'Contractuels',                    'Contractual Workers'),
  ('workers',        'عمال',            'Ouvriers / Personnel de Soutien', 'Workers / Support Staff');

-- Default Settings
INSERT OR IGNORE INTO settings (key, value) VALUES
  ('institution_name_fr',    'Établissement Public Hospitalier'),
  ('institution_name_ar',    'المؤسسة العمومية الاستشفائية'),
  ('ministry_fr',            'Ministère de la Santé'),
  ('working_days_per_month', '30'),
  ('social_security_rate',   '0.09'),
  ('current_bareme_year',    '2024'),
  ('app_language',           'fr'),
  ('db_version',             '1');

-- Default Admin User (password: "admin" — SHA-256 hashed)
-- SHA-256 of "admin" = 8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918
INSERT OR IGNORE INTO users (username, password_hash, full_name, role) VALUES
  ('admin',
   '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
   'Administrateur',
   'admin');

-- =========================================================
-- IRG Tax Brackets (Algérie — Revenus Salariaux Mensuels)
-- =========================================================
INSERT OR IGNORE INTO irg_table (income_from, income_to, tax_amount) VALUES
  (0,       10000,       0),
  (10001,   15000,    1000),
  (15001,   20000,    2000),
  (20001,   25000,    3000),
  (25001,   30000,    4000),
  (30001,   40000,    7000),
  (40001,   50000,   10000),
  (50001,   60000,   13000),
  (60001,   70000,   16000),
  (70001,   80000,   19000),
  (80001,   90000,   22000),
  (90001,  100000,   25000),
  (100001, 120000,   31000),
  (120001, 150000,   41500),
  (150001, 200000,   52000),
  (200001, 999999999, 75000);
