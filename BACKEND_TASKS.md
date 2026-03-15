# ⚙️ Full Backend & Database Tasks
# Hospital Salary Management System (HSMS)

> **Goal**: Complete the Delphi SQLite backend by building data models, calculation engines, and wrapping up all DB-to-UI bindings.

---

## 🟢 Phase 1: Core Data Models
Create the Pascal representation of the remaining SQLite tables with CRUD functions.

- [x] **Task 1.1: `Model_Department.pas` & `Model_Allowance.pas`**
  - CRUD for loading allowance types, mapping to departments, and managing employee-specific allowances (`employee_allowances`).
- [x] **Task 1.2: `Model_SalaryRecord.pas`**
  - `TSalaryRecord` to save finalized monthly calculations. Methods: `Save`, `LoadByEmployeeMonth`, `GetRecordsByMonth`.

---

## 🟡 Phase 2: Engine Rules
Implement the decoupled business logic required for the ALgerian 7-Step Salary Pipeline.

- [x] **Task 2.1: `Engine_Bareme.pas`**
  - Query the `bareme` table by `Class` and `Degree` to fetch `Index_Number` and `Base_Salary`.
- [x] **Task 2.2: `Engine_IRG.pas`**
  - Implement progressive tax calculation `GetIRGTax(TaxableIncome: Double)` matching the `irg_table` brackets.
- [x] **Task 2.3: `Engine_Salary.pas`**
  - Orchestrate the 7-Step Pipeline: compute gross, social security (9%), IRG, absence deductions, and Net Pay. Generate a `TSalaryRecord` instance in memory.

---

## 🔴 Phase 3: UI-To-Backend Integration
Connect the UI forms created in the previous phase to the Database and Engines.

- [ ] **Task 3.1: FrmSalaryCalc**
  - Wire up the "Calculer" button to query active Employees, feed them through `Engine_Salary`, display the grid preview, and Save to `salary_records`.
- [ ] **Task 3.2: FrmPaySlip**
  - Fetch a finalized `salary_record` from the database. Map its fields to the `FrmPaySlip` UI labels dynamically (Gross, IRG, SS, Details).
- [ ] **Task 3.3: FrmDashboard**
  - Replace dummy statistics with actual `COUNT(id)` for Employees/Departments, and `SUM(net_pay)` for total Payroll.
- [ ] **Task 3.4: FrmBareme & FrmSettings**
  - Connect settings toggles to the DB and allow updating the Bareme records and IRG brackets.

---

## 🟣 Phase 4: Data Printing & Reporting
- [ ] **Task 4.1: Pay Slip Printing**
  - Implement canvas printing (or FMX printer support) specifically for `FrmPaySlip`.
- [ ] **Task 4.2: Export to Spreadsheet/PDF (Optional)**
  - Add CSV/PDF export routines for the Monthly Payroll Report Grid.

---
**Status Updates**: Use `[x]` as we finish each sub-task to track progress.
