unit FrmEmployees;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.Grid,
  FMX.Grid.Style, FMX.ScrollBox, FMX.Effects, FMX.ListBox;

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
  public
    constructor Create(AOwner: TComponent); override;
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
    
  EmployeeEditForm.ShowModal;
end;

constructor TEmployeesFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  
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
  LblTotalRecords.Text := 'Total: 145 Employés';
  LblPageInfo.Text := 'Page 1 sur 5';
  
  // Populate dummy data for UI UX Demo purposes
  EmployeesGrid.RowCount := 10;
  
  EmployeesGrid.Cells[0, 0] := 'EMP-001';
  EmployeesGrid.Cells[1, 0] := 'BENDJEDDOU Yassine';
  EmployeesGrid.Cells[2, 0] := 'Médical';
  EmployeesGrid.Cells[3, 0] := 'Médecin Spécialiste';
  EmployeesGrid.Cells[4, 0] := 'Classe 16';
  EmployeesGrid.Cells[5, 0] := 'Éditer';
  
  EmployeesGrid.Cells[0, 1] := 'EMP-002';
  EmployeesGrid.Cells[1, 1] := 'BOUROUIS Amina';
  EmployeesGrid.Cells[2, 1] := 'Paramédical';
  EmployeesGrid.Cells[3, 1] := 'Infirmière D.E';
  EmployeesGrid.Cells[4, 1] := 'Classe 11';
  EmployeesGrid.Cells[5, 1] := 'Éditer';
  
  EmployeesGrid.Cells[0, 2] := 'EMP-003';
  EmployeesGrid.Cells[1, 2] := 'MERAH Karim';
  EmployeesGrid.Cells[2, 2] := 'Administration';
  EmployeesGrid.Cells[3, 2] := 'Comptable';
  EmployeesGrid.Cells[4, 2] := 'Classe 10';
  EmployeesGrid.Cells[5, 2] := 'Éditer';
end;

end.
