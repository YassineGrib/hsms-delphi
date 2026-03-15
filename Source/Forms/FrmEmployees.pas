unit FrmEmployees;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.Grid,
  FMX.Grid.Style, FMX.ScrollBox, FMX.Effects, FMX.ListBox, Model_Employee,
  System.Generics.Collections;

type
  TEmployeesFrame = class(TFrame)
    bgRect: TRectangle;
    TopBarLayout: TLayout;
    
    // Top Bar elements
    ShadowTopBar: TShadowEffect;
    TopBarRect: TRectangle;
    LblPageTitle: TLabel;
    SearchEdit: TEdit;
    BtnAddEmployee: TButton;
    FilterComboBox: TComboBox;
    
    // Grid Container
    GridContainerRect: TRectangle;
    ShadowGrid: TShadowEffect;
    
    // The Data Grid
    EmployeesGrid: TStringGrid;
    ColID: TStringColumn;
    ColName: TStringColumn;
    ColDept: TStringColumn;
    ColPosition: TStringColumn;
    ColClass: TStringColumn;
    ColActions: TStringColumn;
    
    // Footer Pagination
    FooterLayout: TLayout;
    LblTotalRecords: TLabel;
    BtnPrevPage: TButton;
    BtnNextPage: TButton;
    LblPageInfo: TLabel;
    
    procedure BtnAddEmployeeClick(Sender: TObject);
    procedure SearchEditChangeTracking(Sender: TObject);
    procedure EmployeesGridCellClick(const Column: TColumn; const Row: Integer);
  private
    FEmployees: TObjectList<TEmployee>;
    procedure LoadEmployees(const AFilter: string = '');
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RefreshData;
  end;

var
  EmployeesFrame: TEmployeesFrame;

implementation

uses
  FrmEmployeeEdit;

{$R *.fmx}

procedure TEmployeesFrame.BtnAddEmployeeClick(Sender: TObject);
begin
  if not Assigned(EmployeeEditForm) then
    Application.CreateForm(TEmployeeEditForm, EmployeeEditForm);
    
  EmployeeEditForm.CurrentEmployeeId := 0; // 0 means insert new
  if EmployeeEditForm.ShowModal = mrOk then
  begin
    RefreshData;
  end;
end;

procedure TEmployeesFrame.SearchEditChangeTracking(Sender: TObject);
begin
  LoadEmployees(SearchEdit.Text);
end;

procedure TEmployeesFrame.EmployeesGridCellClick(const Column: TColumn; const Row: Integer);
var
  Emp: TEmployee;
begin
  // Only trigger if we clicked the "Actions" column (index 5) or maybe just any column to edit
  if not Assigned(FEmployees) or (Row < 0) or (Row >= FEmployees.Count) then Exit;
  
  if Column.Index = 5 then
  begin
    Emp := FEmployees[Row];
    
    if not Assigned(EmployeeEditForm) then
      Application.CreateForm(TEmployeeEditForm, EmployeeEditForm);
      
    EmployeeEditForm.CurrentEmployeeId := Emp.Id;
    if EmployeeEditForm.ShowModal = mrOk then
    begin
      RefreshData;
    end;
  end;
end;

procedure TEmployeesFrame.RefreshData;
begin
  LoadEmployees(SearchEdit.Text);
end;

procedure TEmployeesFrame.LoadEmployees(const AFilter: string);
var
  I: Integer;
  Emp: TEmployee;
begin
  if Assigned(FEmployees) then
    FreeAndNil(FEmployees);
    
  FEmployees := TEmployee.GetAllEmployees(AFilter);
  
  EmployeesGrid.RowCount := FEmployees.Count;
  
  for I := 0 to FEmployees.Count - 1 do
  begin
    Emp := FEmployees[I];
    EmployeesGrid.Cells[0, I] := Emp.EmployeeNumber;
    EmployeesGrid.Cells[1, I] := Emp.FullName;
    EmployeesGrid.Cells[2, I] := Emp.DepartmentId; // We could resolve this to Fr Name later
    EmployeesGrid.Cells[3, I] := Emp.PositionFr;
    EmployeesGrid.Cells[4, I] := 'Classe ' + Emp.GradeClass.ToString;
    EmployeesGrid.Cells[5, I] := 'Éditer';
  end;
  
  LblTotalRecords.Text := 'Total: ' + FEmployees.Count.ToString + ' Employés';
end;

constructor TEmployeesFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEmployees := nil;
  
  // Set accurate French text without accents inside the .fmx
  LblPageTitle.Text := 'Liste des Employés';
  BtnAddEmployee.Text := '+ Ajouter un Employé';
  SearchEdit.TextPrompt := 'Rechercher par nom, matricule...';
  
  // Grid Columns Setup
  ColID.Header := 'Matricule';
  ColName.Header := 'Nom & Prénom';
  ColDept.Header := 'Département';
  ColPosition.Header := 'Fonction';
  ColClass.Header := 'Catégorie';
  ColActions.Header := 'Actions';
  
  // Footer text
  LblPageInfo.Text := 'Page 1 sur 1';
  
  RefreshData;
end;

destructor TEmployeesFrame.Destroy;
begin
  if Assigned(FEmployees) then
    FreeAndNil(FEmployees);
  inherited;
end;

end.
