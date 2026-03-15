# 📋 Product Requirements Document (PRD)
# Hospital Salary Management System — نظام تسيير رواتب المستشفى

---

## 1. Overview

| Field | Detail |
|---|---|
| **Product Name** | Hospital Salary Management System (HSMS) |
| **Platform** | Windows Desktop (Delphi 11 — FMX / FireMonkey) |
| **Database** | SQLite (local, embedded — no server required) |
| **Language** | French (primary UI) |
| **Target User** | Hospital payroll department (مصلحة الأجور) |
| **Domain** | Algerian Public Hospital — Ministry of Health |
| **Currency** | DZD (Algerian Dinar) |

---

## 2. Problem Statement

Algerian public hospital payroll departments currently manage salaries using **Excel spreadsheets** with complex merged cells, manual formulas, and dozens of separate sheets per staff category. This leads to:

- **Human error** in salary calculations (allowances, tax, deductions)
- **No centralized employee database** — data scattered across sheets
- **No monthly history tracking** — old sheets get overwritten
- **Time-consuming** to generate pay slips and monthly reports
- **Difficult to audit** — no clear trail of changes

---

## 3. Solution

A **native Windows desktop application** built with Delphi 11 (FMX) that:

1. Stores all employee and salary data in a **local SQLite database**
2. **Automates** the 7-step Algerian salary calculation pipeline
3. Generates **printable pay slips** (كشف الراتب) and **monthly payroll sheets** (جدول الرواتب الشهري)
4. Supports all **6 hospital staff departments** with department-specific allowances
5. Maintains **monthly salary history** for auditing and comparison

---

## 4. User Roles

| Role | Access |
|---|---|
| **Admin** (المسؤول) | Full access: employees, salary config, reports, settings |
| **Payroll Officer** (مسؤول الأجور) | Manage employees, run salary calculations, print reports |
| **Viewer** (مشاهد) | View-only access to employee data and reports |

> [!NOTE]
> For V1, a simple password-protected admin login is sufficient. Multi-user auth can come in V2.

---

## 5. Core Features

### 5.1 Employee Management (إدارة الموظفين)

- **Add / Edit / Delete** employees
- Employee fields:
  - Personal: Full name (اللقب + الاسم), Employee ID, National ID
  - Professional: Department, Position/Rank (الرتبة), Hire Date
  - Classification: Class (الصنف 1–20), Index Number (الرقم الاستدلالي), Degree (الدرجة 0–12), Points
- **Filter & Search** by name, department, position, class
- **Department assignment** to one of the 6 categories

### 5.2 Salary Configuration (إعدادات الراتب)

- **Bareme Table** (جدول الأجور): Manage the salary scale — map index numbers to base salary amounts
- **Allowance Definitions**: Configure the 9 allowance types with their codes, amounts, and department applicability:

  | Code | Allowance | Applies To |
  |---|---|---|
  | 1-1-1 | Base Salary (الأجر الأساسي) | All |
  | 2-2-1 | Infection Allowance (تعويض العدوى) | Doctors, Specialists, Paramedical |
  | 3-2-1 | Documentation Allowance (تعويض التوثيق) | Doctors, Specialists, Paramedical |
  | 7-2-1 | Qualification Allowance (تعويض التأهيل) | Doctors, Specialists, Paramedical |
  | 8-2-1 | Supervision Allowance (التأطير) | Doctors, Specialists |
  | 20-2-1 | Health Activity Support (تعويض دعم نشاطات الصحة) | Doctors, Specialists, Paramedical |
  | 20-2-1 | Obstetric Allowance (تعويض التوليد) | Doctors, Specialists, Paramedical |
  | 20-2-1 | Mother & Child Health (صحة الأم والطفل) | Doctors, Specialists, Paramedical |
  | 39-2-1 | Flat Rate Bonus (المنحة الجزافية) | All |

- **IRG Tax Table**: Manage the progressive income tax lookup table
- **Social Security Rate**: Configurable (default 9%)

### 5.3 Monthly Salary Calculation (حساب الراتب الشهري)

The **automated 7-step salary pipeline**:

```
Step 1: base_salary = index_number × bareme_point_value
Step 2: gross_salary = base_salary + Σ(applicable_allowances)
Step 3: social_security = gross_salary × 9%
Step 4: taxable_income = gross_salary − social_security
Step 5: irg_tax = IRG_table_lookup(taxable_income)
Step 6: absence_deduction = (gross_salary / 30) × absent_days
Step 7: net_pay = gross_salary − social_security − irg_tax − absence_deduction
```

- Select **month and year** for calculation
- Input **absent days** per employee for the period
- **Batch calculate** for all employees or per department
- **Preview** before finalizing
- **Lock** finalized months to prevent accidental edits

### 5.4 Pay Slip Generation (كشف الراتب)

- Individual printable pay slip per employee
- Shows:
  - Employee info (name, position, classification)
  - All allowance lines with codes and amounts
  - All deduction lines (social security, IRG, absences)
  - Gross total, net pay
  - Institution header (Ministry of Health / Hospital name)
- **Print to printer** or **Export to PDF**

### 5.5 Monthly Payroll Report (جدول الرواتب الشهري)

- Full monthly payroll table matching the original Excel format
- One sheet per department (or combined)
- Columns: Employee #, Name, Position, Classification, All Allowances, Gross, SS, Taxable, IRG, Absences, Net Pay
- **Page totals** row at bottom
- **Print** or **Export to PDF/Excel**

### 5.6 Dashboard (لوحة التحكم)

- **Total payroll** for current month
- **Employee count** by department
- **Net pay distribution** chart
- **Quick actions**: New employee, Run salary calculation, Print reports

### 5.7 Settings (الإعدادات)

- Institution name and header info (for pay slip headers)
- Database backup/restore
- Working days per month (default: 30)
- Language preference

---

## 6. Database Schema (SQLite)

### Tables

```sql
-- 1. Departments
CREATE TABLE departments (
    id          TEXT PRIMARY KEY,    -- 'doctors', 'paramedical', etc.
    name_ar     TEXT NOT NULL,
    name_en     TEXT NOT NULL
);

-- 2. Employees
CREATE TABLE employees (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_number TEXT UNIQUE,
    last_name       TEXT NOT NULL,       -- اللقب
    first_name      TEXT NOT NULL,       -- الاسم
    national_id     TEXT,
    department_id   TEXT REFERENCES departments(id),
    position_ar     TEXT,                -- الرتبة / الوظيفة
    position_en     TEXT,
    class           INTEGER DEFAULT 1,  -- الصنف (1-20)
    index_number    INTEGER,            -- الرقم الاستدلالي
    degree          INTEGER DEFAULT 0,  -- الدرجة (0-12)
    points          INTEGER DEFAULT 0,  -- عدد النقاط
    hire_date       TEXT,
    is_active       INTEGER DEFAULT 1,
    created_at      TEXT DEFAULT (datetime('now')),
    updated_at      TEXT DEFAULT (datetime('now'))
);

-- 3. Allowance type definitions
CREATE TABLE allowance_types (
    id          TEXT PRIMARY KEY,        -- 'infection_allowance', etc.
    code        TEXT NOT NULL,           -- '2-2-1'
    name_ar     TEXT NOT NULL,
    name_en     TEXT NOT NULL,
    description TEXT,
    is_active   INTEGER DEFAULT 1
);

-- 4. Allowance-to-department mapping
CREATE TABLE allowance_department (
    allowance_id    TEXT REFERENCES allowance_types(id),
    department_id   TEXT REFERENCES departments(id),
    PRIMARY KEY (allowance_id, department_id)
);

-- 5. Employee-specific allowance amounts
CREATE TABLE employee_allowances (
    employee_id     INTEGER REFERENCES employees(id),
    allowance_id    TEXT REFERENCES allowance_types(id),
    amount          REAL DEFAULT 0,
    PRIMARY KEY (employee_id, allowance_id)
);

-- 6. Bareme salary scale
CREATE TABLE bareme (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    class           INTEGER NOT NULL,    -- الصنف
    degree          INTEGER NOT NULL,    -- الدرجة
    index_number    INTEGER NOT NULL,    -- الرقم الاستدلالي
    point_value     REAL NOT NULL,       -- قيمة النقطة
    base_salary     REAL NOT NULL,       -- الأجر الأساسي
    year            INTEGER DEFAULT 2024
);

-- 7. IRG Tax lookup table
CREATE TABLE irg_table (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    income_from     REAL NOT NULL,
    income_to       REAL NOT NULL,
    tax_amount      REAL NOT NULL
);

-- 8. Monthly salary records (finalized)
CREATE TABLE salary_records (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id     INTEGER REFERENCES employees(id),
    month           INTEGER NOT NULL,    -- 1-12
    year            INTEGER NOT NULL,
    days_worked     INTEGER DEFAULT 30,
    absent_days     INTEGER DEFAULT 0,
    base_salary     REAL DEFAULT 0,
    -- Allowances
    infection_allowance       REAL DEFAULT 0,
    documentation_allowance   REAL DEFAULT 0,
    qualification_allowance   REAL DEFAULT 0,
    supervision_allowance     REAL DEFAULT 0,
    health_activity_support   REAL DEFAULT 0,
    obstetric_allowance       REAL DEFAULT 0,
    mother_child_health       REAL DEFAULT 0,
    flat_rate_bonus           REAL DEFAULT 0,
    -- Totals & Deductions
    gross_salary    REAL DEFAULT 0,
    social_security REAL DEFAULT 0,
    taxable_income  REAL DEFAULT 0,
    irg_tax         REAL DEFAULT 0,
    absence_deduction REAL DEFAULT 0,
    net_pay         REAL DEFAULT 0,
    -- Meta
    is_locked       INTEGER DEFAULT 0,
    created_at      TEXT DEFAULT (datetime('now')),
    UNIQUE(employee_id, month, year)
);

-- 9. Application settings
CREATE TABLE settings (
    key     TEXT PRIMARY KEY,
    value   TEXT
);
```

---

## 7. UI Layout (FMX Forms)

| # | Form | Purpose |
|---|---|---|
| 1 | `FrmMain` | Main window — sidebar navigation + content area |
| 2 | `FrmDashboard` | Dashboard with stats cards and charts |
| 3 | `FrmEmployees` | Employee list (grid) + search/filter |
| 4 | `FrmEmployeeEdit` | Employee add/edit dialog |
| 5 | `FrmSalaryCalc` | Monthly salary calculation wizard |
| 6 | `FrmSalaryPreview` | Preview calculated salaries before saving |
| 7 | `FrmPaySlip` | Individual pay slip view/print |
| 8 | `FrmPayrollReport` | Monthly payroll report view/print |
| 9 | `FrmBareme` | Bareme table management |
| 10 | `FrmIRGTable` | IRG tax table management |
| 11 | `FrmAllowances` | Allowance configuration |
| 12 | `FrmSettings` | Application settings |
| 13 | `FrmLogin` | Login dialog |
| 14 | `FrmAbout` | About dialog |

---

## 8. Technology Stack

| Component | Technology |
|---|---|
| **Language** | Object Pascal (Delphi 11 Alexandria) |
| **Framework** | FMX (FireMonkey) for UI |
| **Database** | SQLite 3 via `FireDAC` (TFDConnection, TFDQuery) |
| **Reporting** | FastReport FMX or custom TCanvas-based printing |
| **PDF Export** | Built-in FMX printer support |
| **Charts** | TChart (FMX) for dashboard visualization |
| **Text Direction** | LTR (Left-to-Right) for French UI |

---

## 9. Non-Functional Requirements

| Requirement | Detail |
|---|---|
| **Performance** | Salary calculation for 500+ employees < 2 seconds |
| **Data Safety** | Database backup/restore functionality |
| **Offline** | 100% offline — no internet required |
| **Portability** | Single EXE + SQLite DB file — no installer required |
| **LTR Support** | Standard Left-to-Right French UI layout |
| **Print Quality** | Pay slips must match official government format |

---

## 10. Future Enhancements (V2+)

- Multi-hospital support (different institutions)
- Year-end tax summary reports (كشف سنوي)
- Employee promotion/reclassification history tracking
- Retroactive salary adjustment calculations
- Export to Excel (`.xlsx`)
- Cloud backup option
- Barcode/QR on pay slips for verification

---

## 🛑 Important Development Notes & Fixes
- **FMX RLINK32 Error**: Do **NOT** use inline comments (`//`) or Unicode escaped characters (`#232`, `#233` for French accents) directly inside `.fmx` files. This causes an `[dcc32 Error] E2161 Error: RLINK32: Unsupported 16bit resource` compilation error. 
  - *Fix*: Keep all strings in `.fmx` as standard ASCII. Assign accented texts (é, è) programmatically in the `FormCreate` event using Delphi pascal code.
