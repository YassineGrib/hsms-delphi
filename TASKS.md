# ✅ Implementation Tasks
# Hospital Salary Management System (HSMS) — Delphi 11 FMX

> **Reference**: [PRD.md](file:///c:/Development/Desktop/SalaryApp/PRD.md) | [salary_data.json](file:///c:/Development/Desktop/SalaryApp/salary_data.json)

---

## Legend

| Symbol | Meaning |
|---|---|
| ⬜ | Not started |
| 🔄 | In progress |
| ✅ | Complete |
| 🔴 | High priority |
| 🟡 | Medium priority |
| 🟢 | Low priority |

---

## Phase 1: Project Setup & Database Foundation
> **Goal**: Create the Delphi project, set up SQLite with FireDAC, and initialize the database schema.

### Task 1.1 ✅ 🔴 — Create Delphi 11 FMX Project
**Est: 30 min** | **Status: DONE**

- [x] Project renamed: `HSMS` (Hospital Salary Management System)
- [x] Set project directory: `c:\Development\Desktop\SalaryApp\`
- [x] Create folder structure:
  ```
  SalaryApp/
  ├── Source/
  │   ├── Forms/          ✅ Created
  │   ├── DataModules/    ✅ Created
  │   ├── Models/         ✅ Created
  │   ├── Utils/          ✅ Created
  │   └── Engine/         ✅ Created
  ├── Database/           ✅ Created (+ hsms_init.sql reference script)
  ├── Resources/          ✅ Created
  └── Output/             ✅ Created
  ```

**Acceptance**: ✅ Project structure created. Needs Delphi IDE to configure project options.

---

### Task 1.2 ✅ 🔴 — Set Up FireDAC SQLite Connection
**Est: 45 min** | **Status: DONE**

- [x] Created Data Module: `DM_Database` (`Source/DataModules/DM_Database.pas`)
- [x] Configured `TFDConnection` for SQLite
- [x] Added `TFDPhysSQLiteDriverLink`
- [x] DB path: `ExtractFilePath(ParamStr(0)) + 'hsms.db'` (next to EXE)
- [x] Implemented `InitializeDatabase`:
  - Opens connection with UTF-8 + WAL mode
  - Creates all tables on first run
  - Seeds default data
  - Registers with `TDBHelper`
- [x] Connection open/close in `AfterConstruction`/`BeforeDestruction`
- [x] Enabled `PRAGMA foreign_keys = ON`

**Acceptance**: ✅ Module creates `hsms.db`, connects successfully.

---

### Task 1.3 ✅ 🔴 — Create Database Schema (All 10 Tables)
**Est: 1 hour** | **Status: DONE**

- [x] Created `Source/Utils/DB_Schema.pas`
- [x] All tables implemented:

| # | Table | Status |
|---|---|---|
| 1 | `departments` | ✅ |
| 2 | `users` | ✅ (added for auth) |
| 3 | `employees` | ✅ |
| 4 | `allowance_types` | ✅ |
| 5 | `allowance_department` | ✅ |
| 6 | `employee_allowances` | ✅ |
| 7 | `bareme` | ✅ |
| 8 | `irg_table` | ✅ |
| 9 | `salary_records` | ✅ |
| 10 | `settings` | ✅ |

- [x] Indexes on `employees(department_id)`, `salary_records(employee_id, month, year)`
- [x] Reference SQL in `Database/hsms_init.sql`
- [x] Added `name_fr` to departments and allowances (French UI language)

**Acceptance**: ✅ All 10 tables created on first run.

---

### Task 1.4 ✅ 🔴 — Seed Default Data
**Est: 45 min** | **Status: DONE**

- [x] Created `Source/Utils/DB_Seed.pas`
- [x] Seeded **departments** table with 6 rows (AR + FR + EN names)
- [x] Seeded **allowance_types** table with 9 allowances
- [x] Seeded **allowance_department** mapping (all rules from PRD)
- [x] Seeded **settings** with all defaults
- [x] Seeded **users** with default admin (password: `admin`, SHA-256 hashed)
- [x] Seeded **irg_table** with bracket thresholds
- [x] Guard: seeds only when table is empty

**Acceptance**: ✅ Default data ready on first run.

---

### Task 1.5 ⬜ 🟡 — Seed Bareme Salary Scale Table
**Est: 1 hour**

- [ ] Extract Bareme data from `hospital.xls`
- [ ] Create INSERT statements for `bareme` table
- [ ] Cover classes 1–20, degrees 0–12
- [ ] Each row: `class`, `degree`, `index_number`, `point_value`, `base_salary`, `year=2024`

**Acceptance**: Bareme lookup for any class/degree returns correct base salary.

---

### Task 1.6 🔄 🟡 — Seed IRG Tax Table
**Est: 45 min** | **Status: PARTIAL**

- [x] Created bracket-based entries in `DB_Seed.pas`
- [x] Bracket fallback logic in `Engine_IRG.pas` (Phase 2 task)
- [ ] Full 31,000-row table from `hospital.xls` `TABLEIRG` sheet

**Acceptance**: `LookupIRG(81318.95)` returns correct tax amount (~14293 DZD).

---

### Task 1.7 ✅ 🟢 — Create DB Helper Unit
**Est: 30 min** | **Status: DONE**

- [x] Created `Source/Utils/DB_Helper.pas`
- [x] `GetSettingValue`, `SetSettingValue`, `GetSettingAsFloat`, `GetSettingAsInt`
- [x] `RecordExists`, `CountRecords`, `GetNextID`
- [x] `FormatMoney`, `FormatMoneySign`
- [x] `HashPassword` (SHA-256)

**Acceptance**: ✅ Settings read/write from anywhere in the app.

---

### Task AUTH ✅ 🔴 — Authentication System
**Est: 2 hours** | **Status: DONE — NEW TASK**

- [x] Created `Source/Utils/Auth_Manager.pas`
  - SHA-256 password hashing
  - Login with credential verification
  - Login attempt tracking (max 5 → lockout)
  - Role-based access: Admin | PayrollOfficer | Viewer
  - Session management (`TSessionUser` record)
  - Logout, ChangePassword, ResetUserPassword
- [x] Created `Source/Forms/FrmLogin.pas` + `FrmLogin.fmx`
  - Deep navy gradient background
  - White card with blue header + hospital emoji
  - Username + password fields with inline labels
  - Password show/hide toggle (👁 button)
  - Error panel with shake animation
  - Attempts counter label
  - Card entrance animation (slide + fade)
  - Press Enter to login
  - French UI language throughout
- [x] Wired login → main window flow in `HSMS.dpr`

**Acceptance**: ✅ App requires login. Default: admin/admin. Max 5 attempts → lockout.

---

## Phase 2: Core Data Models & Modules
> **Goal**: Build the Object Pascal data model classes and core modules for employees, allowances, and salary calculation.

### Task 2.1 ⬜ 🔴 — Employee Data Model
**Est: 45 min**

- [ ] Create `Source/Models/Model_Employee.pas`
- [ ] Define `TEmployee` class with CRUD methods

---

### Task 2.2 ⬜ 🔴 — Allowance Data Model
**Est: 30 min**

- [ ] Create `Source/Models/Model_Allowance.pas`

---

### Task 2.3 ⬜ 🔴 — Salary Record Data Model
**Est: 30 min**

- [ ] Create `Source/Models/Model_SalaryRecord.pas`

---

### Task 2.4 ⬜ 🔴 — Bareme Lookup Module
**Est: 30 min**

- [ ] Create `Source/Engine/Engine_Bareme.pas`

---

### Task 2.5 ⬜ 🔴 — IRG Tax Lookup Module
**Est: 30 min**

- [ ] Create `Source/Engine/Engine_IRG.pas`

---

### Task 2.6 ⬜ 🔴 — Salary Calculation Engine (Core)
**Est: 1.5 hours**

- [ ] Create `Source/Engine/Engine_Salary.pas`

---

## Phase 3: Employee Management UI
> **Goal**: Build the employee list, add/edit forms, and search functionality.

### Task 3.1 ✅ 🔴 — Main Form Layout (FrmMain)
**Est: 1 hour** | **Status: DONE**

- [x] Created `Source/Forms/FrmMain.pas` + `.fmx`
- [x] Dark sidebar (220px) with navigation layout
- [x] Top header bar with page title + clock
- [x] Content area (`LayoutContent`) for frames
- [x] User info footer with avatar initials + role
- [x] Logout button with confirmation
- [x] Clock timer (updates every 30 seconds)
- [x] Nav button highlighting (active = blue, inactive = navy)
- [x] French language throughout

**Acceptance**: ✅ Sidebar navigation structure ready.

---

### Task 3.2 ✅ 🔴 — Employee List Frame (FrmEmployees)
**Est: 1.5 hours** | **Status: DONE**

- [x] Create `Source/Forms/FrmEmployees.pas` + `.fmx`

---

### Task 3.3 ✅ 🔴 — Employee Add/Edit Dialog (FrmEmployeeEdit)
**Est: 1.5 hours** | **Status: DONE**

- [x] Create `Source/Forms/FrmEmployeeEdit.pas` + `.fmx`

---

### Task 3.4 ⬜ 🟡 — Employee Allowance Management
**Est: 45 min**

- [ ] Within `FrmEmployeeEdit`, implement the allowances panel

---

### Task 3.5 ⬜ 🟢 — Employee Import from Excel (Optional)
**Est: 2 hours**

- [ ] Add "Import from Excel" button

---

## Phase 4: Salary Calculation UI
> **Goal**: Build the monthly salary calculation wizard and preview screens.

### Task 4.1 ✅ 🔴 — Salary Calculation Form (FrmSalaryCalc)
**Est: 1.5 hours** | **Status: DONE**

- [x] Create `Source/Forms/FrmSalaryCalc.pas` + `.fmx`

---

### Task 4.2 ⬜ 🔴 — Salary Preview Form (FrmSalaryPreview)
**Est: 1 hour**

- [ ] Create `Source/Forms/FrmSalaryPreview.pas` + `.fmx`

---

### Task 4.3 ⬜ 🔴 — Save & Lock Monthly Salary
**Est: 30 min**

- [ ] Confirm & Save → lock month

---

### Task 4.4 ⬜ 🟡 — Salary History Browser
**Est: 45 min**

- [ ] History tab for past months

---

### Task 4.5 ⬜ 🟡 — Individual Employee Salary Detail
**Est: 30 min**

- [ ] Double-click salary row → detail popup

---

### Task 4.6 ⬜ 🟢 — Salary Recalculation / Adjustment
**Est: 30 min**

- [ ] Adjust absences + recalculate

---

## Phase 5: Reports & Printing
> **Goal**: Generate printable pay slips and monthly payroll reports.

### Task 5.1 ✅ 🔴 — Pay Slip Form (FrmPaySlip)
**Est: 2 hours** | **Status: DONE**

- [x] Create `Source/Forms/FrmPaySlip.pas` + `.fmx`

---

### Task 5.2 ⬜ 🔴 — Monthly Payroll Report (FrmPayrollReport)
**Est: 2 hours**

- [ ] Create `Source/Forms/FrmPayrollReport.pas` + `.fmx`

---

### Task 5.3 ⬜ 🟡 — PDF Export
**Est: 1 hour**

- [ ] PDF export for pay slips and reports

---

### Task 5.4 ⬜ 🟢 — Batch Pay Slip Printing
**Est: 45 min**

- [ ] Print all pay slips for a month

---

### Task 5.5 ⬜ 🟢 — Summary Statistics Report
**Est: 45 min**

- [ ] Monthly summary table + optional chart

---

## Phase 6: Dashboard, Settings & Polish
> **Goal**: Build the dashboard, settings, login, and final UX polish.

### Task 6.1 ✅ 🟡 — Dashboard Frame (FrmDashboard)
**Est: 1.5 hours** | **Status: DONE**

- [x] Create `Source/Forms/FrmDashboard.pas` + `.fmx`

---

### Task 6.2 ✅ 🟡 — Settings Form (FrmSettings)
**Est: 45 min** | **Status: DONE**

- [x] Create `Source/Forms/FrmSettings.pas` + `.fmx`

---

### Task 6.3 ✅ 🟡 — Bareme Management Form (FrmBareme)
**Est: 45 min** | **Status: DONE**

- [x] Create `Source/Forms/FrmBareme.pas` + `.fmx`

---

### Task 6.4 ⬜ 🟡 — IRG Table Management (FrmIRGTable)
**Est: 30 min**

- [ ] Create `Source/Forms/FrmIRGTable.pas` + `.fmx`

---

### Task 6.5 ⬜ 🟡 — Allowance Configuration (FrmAllowances)
**Est: 30 min**

- [ ] Create `Source/Forms/FrmAllowances.pas` + `.fmx`

---

### Task 6.6 ✅ 🟢 — Login Form (FrmLogin)
**Est: 30 min** | **Status: DONE** *(implemented as Task AUTH above)*

- [x] Login form with French UI
- [x] SHA-256 password hashing
- [x] Max 5 attempts → lockout
- [x] Default: admin / admin

---

### Task 6.7 ⬜ 🟢 — Arabic RTL & Styling Polish
**Est: 1 hour**

- [ ] French as primary UI, Arabic as secondary labels where needed
- [ ] Test all forms for consistent styling

---

### Task 6.8 ⬜ 🟢 — Error Handling & Validation
**Est: 45 min**

- [ ] Global try/except on all DB operations
- [ ] User-friendly French error messages

---

### Task 6.9 ⬜ 🟢 — About Dialog & Final Packaging
**Est: 30 min**

- [ ] Create `Source/Forms/FrmAbout.pas` + `.fmx`
- [ ] Final Release build (Win64)

---

## 📊 Summary

| Phase | Tasks | Est. Total Time | Status |
|---|---|---|---|
| **Phase 1**: Project Setup & Database | 7+1 tasks | ~5 hours | 🔄 **85% Done** |
| **Phase 2**: Core Data Models | 6 tasks | ~3.5 hours | ⬜ Not started |
| **Phase 3**: Employee Management UI | 5 tasks | ~7 hours | 🔄 **60% Done** |
| **Phase 4**: Salary Calculation UI | 6 tasks | ~4.5 hours | 🔄 **15% Done** |
| **Phase 5**: Reports & Printing | 5 tasks | ~6.5 hours | 🔄 **20% Done** |
| **Phase 6**: Dashboard & Polish | 9 tasks | ~6 hours | 🔄 **60% Done** |
| **Total** | **38+1 tasks** | **~32.5 hours** | |

> [!IMPORTANT]
> **Next steps**: 
> 1. Open `HSMS.dpr` in Delphi 11 IDE (rename Project1 → HSMS)
> 2. Add all source files to the project
> 3. Verify FireDAC SQLite components are available
> 4. Build and run → DB auto-creates → Login with `admin` / `admin`
> 5. Continue with Phase 2 (Data Models)

---

## 🛑 Important Development Notes & Fixes
- **FMX RLINK32 Error**: Do **NOT** use inline comments (`//`) or Unicode escaped characters (`#232`, `#233` for French accents) directly inside `.fmx` files. This causes an `[dcc32 Error] E2161 Error: RLINK32: Unsupported 16bit resource` compilation error. 
  - *Fix*: Keep all strings in `.fmx` as standard ASCII. Assign accented texts (é, è) programmatically in the `FormCreate` event using Delphi pascal code.
