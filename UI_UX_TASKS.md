# 🎨 UI / UX Implementation Tasks
# System de Gestion des Salaires de l'Hôpital (HSMS) — Delphi 11 FMX

> **Reference**: [PRD.md](file:///c:/Users/Yassi/Documents/Embarcadero/Studio/Projects/hsms/PRD.md)
> **Goal**: Define all user interface and user experience design tasks for the modern French UI of the HSMS application.

---

## 🎨 Theme & Design System Strategy
Before building specific screens, we must establish a consistent modern, premium design system.
- **Color Palette**: Deep Navy (`#0A192F`), White (`#FFFFFF`), Soft Blue/Grey (`#A8B2D1`), Primary Action Blue (`#112240` / `#64FFDA`).
- **Typography**: Clean Sans-Serif fonts (like Segoe UI or Roboto).
- **Language**: French throughout the entire application.
- **Direction**: LTR (Left-to-Right layout).

---

## 📱 Phase 1: Core Foundation & Layout

### Task UX.1 ✅ 🔴 — Design System Colors & Fonts setup
- [x] Define global colour constants in a shared utility/data module or stylebook.
- [x] Set up a custom `TStyleBook` specifically for rounded buttons, beautiful edits, and cards.
- [x] Ensure all FMX shapes and rectangles use anti-aliasing.

### Task UX.2 ✅ 🔴 — Splash & Login Screens Setup
- [x] **Splash Screen (`FrmSplash`)**: Deep Navy background, white title, fade animation, loading circle.
- [x] **Login Screen (`FrmLogin`)**: Floating white card, shadow effect, entrance animation, input box error shaking.
- [ ] **Next**: Wire up realistic login backend checks.

### Task UX.3 ✅ 🔴 — Main Application Layout (`FrmMain`)
- [x] **Sidebar (Left)**: Fixed 220px width, deep navy (`#112240`). Includes navigation buttons with hover indicators (e.g., small vertical bar highlight).
- [x] **Top Header**: White background, containing current Page Title, Date/Time, and User Profile indicator.
- [x] **Content Area**: Light grey/white workspace where frames/tabs load dynamically.

---

## 🖥 Phase 2: Navigation & Core Screens

### Task UX.4 ✅ 🔴 — Dashboard Screen (`FrmDashboard`)
- [x] **Layout**: Masonry or grid layout using `TFlowLayout`.
- [x] **Stat Cards**: 4 premium cards (Total Employees, Total Payroll, Departments, Absences). White background, rounded corners (Radius 8), soft drop shadow.
- [x] **Chart Area**: Implement a clean `TChart` showing salary distribution by department. Flat, modern bar/pie charts with custom colors.
- [x] **Quick Actions**: Prominent buttons (e.g., "Nouveau Employé", "Lancer le Calcul", "Paramètres").

### Task UX.5 ✅ 🔴 — Employee List Screen (`FrmEmployees`)
- [x] **Top Bar**: Search bar (rounded with magnifying glass icon), Filter Dropdown, and "Ajouter un Employé" primary button aligned Right.
- [x] **Data Grid**: Modern custom-styled `TStringGrid` or a `TListView` displaying employees.
  - Hide grid lines, alternate row colors subtly (light grey / white).
  - Hover effects on rows.
- [x] **Pagination/Footer**: Details showing "X / Y Employés".

### Task UX.6 ✅ 🟡 — Employee Edit/Add Dialog (`FrmEmployeeEdit`)
- [x] **Presentation**: Modal window or sliding right-side sheet.
- [x] **Form Styling**: Clean `TEdit` controls with placeholder text (`TextPrompt`). Grouped blocks (Personal Data, Professional Data, Allowances) separated by subtle lines.
- [x] **Validation Feedback**: Inline red text for missing/invalid fields instead of generic message boxes.

---

## 🚀 Phase 3: Salary Calculation Wizard

### Task UX.7 ✅ 🔴 — Salary Calculation Flow (`FrmSalaryCalc`)
- [x] **Step Indicator**: Visual progress bar indicating steps (e.g., 1. Sélection mois -> 2. Saisie Absences -> 3. Prévisualisation -> 4. Validation).
- [x] **Month Selector**: Clean combo-boxes or custom visually appealing month cards.
- [x] **Absences Input**: Easy-to-use grid where inputting numbers is extremely fast (keyboard navigable).

### Task UX.8 ✅ 🔴 — Pay Slip Preview (`FrmPaySlip`)
- [x] **Visual Hierarchy**: Clearly separated "Gains" (Rubriques Soumises) and "Retenues".
- [x] **Print Layout Mode**: An on-screen view that perfectly mimics the A4 printed paper to provide confidence before printing.
- [x] **Export Options**: floating buttons for "Imprimer" (Print) and "Exporter PDF" with matching icons.

---

## 🛠 Phase 4: Configuration & Settings

### Task UX.9 ✅ 🟡 — Bareme & IRG Management (`FrmBareme` / `FrmIRGTable`)
- [x] **Data Handling UI**: Large, easily scannable data grids for configuration tables.
- [x] **Editable Cells**: Double-click to edit with instant visual feedback (flash green lightly on save).

### Task UX.10 ✅ 🟢 — Global App Settings (`FrmSettings`)
- [x] **Tabbed Interface**: "Général", "Impression", "Base de données", "Utilisateur".
- [x] **Action Items**: "Sauvegarder" and "Restaurer" with clear progress bars and success animations.

---

### UX Animation & Polish Checklist
- [ ] **Transitions**: All major screen switches in `FrmMain` should use a quick 0.2s fade.
- [ ] **Hover Effects**: All clickable items (Buttons, Side-menu items, Grid rows) must change state on mouse hover.
- [ ] **Icons**: Use consistent FontIcon or standardized SVGs (e.g., Material Design Icons or FontAwesome) for uniformity. 
- [ ] **Typography Scale**: 
  - Main Titles: 24pt Bold
  - Section Headers: 18pt Semi-Bold
  - Body Text: 14pt Regular
  - Labels: 12pt light grey

---

## 🛑 Important Development Notes & Fixes
- **FMX RLINK32 Error**: Do **NOT** use inline comments (`//`) or Unicode escaped characters (`#232`, `#233` for French accents) directly inside `.fmx` files. This causes an `[dcc32 Error] E2161 Error: RLINK32: Unsupported 16bit resource` compilation error. 
  - *Fix*: Keep all strings in `.fmx` as standard ASCII. Assign accented texts (é, è) programmatically in the `FormCreate` event using Delphi pascal code.
