unit FrmEmployeeEdit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.ListBox,
  FMX.Effects, Model_Employee;

type
  TEmployeeEditForm = class(TForm)
    bgRect: TRectangle;
    CardRect: TRectangle;
    ShadowCard: TShadowEffect;
    
    TopHeaderLayout: TLayout;
    LblTitle: TLabel;
    BtnClose: TButton;
    
    // Main scrolling content
    ScrollBoxMain: TScrollBox;
    ContentLayout: TLayout;
    
    // Section 1: Personal Data
    RectSection1: TRectangle;
    LblSection1Title: TLabel;
    EditNom: TEdit;
    EditPrenom: TEdit;
    EditNSS: TEdit;
    
    // Section 2: Professional Data
    RectSection2: TRectangle;
    LblSection2Title: TLabel;
    EditMatricule: TEdit;
    ComboDepartement: TComboBox;
    EditFonction: TEdit;
    DateEditEmbauche: TEdit; // Placeholder for TDateEdit logic
    
    // Section 3: Salary Classification
    RectSection3: TRectangle;
    LblSection3Title: TLabel;
    ComboClasse: TComboBox;
    ComboEchelon: TComboBox;
    EditIndice: TEdit;
    
    // Footer actions
    FooterLayout: TLayout;
    BtnCancel: TButton;
    BtnSave: TButton;
    
    procedure FormCreate(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
  private
    FEmployeeId: Integer;
    procedure LoadEmployeeData;
    procedure SaveEmployeeData;
  public
    property CurrentEmployeeId: Integer read FEmployeeId write FEmployeeId;
    procedure FormShow(Sender: TObject);
  end;

var
  EmployeeEditForm: TEmployeeEditForm;

implementation

{$R *.fmx}

procedure TEmployeeEditForm.BtnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TEmployeeEditForm.BtnCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TEmployeeEditForm.BtnSaveClick(Sender: TObject);
begin
  if (EditNom.Text = '') or (EditPrenom.Text = '') then
  begin
    ShowMessage('Veuillez remplir les noms et prénoms obligatoires.');
    Exit;
  end;
  
  SaveEmployeeData;
  ModalResult := mrOk;
end;

procedure TEmployeeEditForm.LoadEmployeeData;
var
  Emp: TEmployee;
begin
  if FEmployeeId > 0 then
  begin
    LblTitle.Text := 'Editer Employé';
    Emp := TEmployee.LoadFromDB(FEmployeeId);
    if Assigned(Emp) then
    begin
      try
        EditNom.Text := Emp.LastName;
        EditPrenom.Text := Emp.FirstName;
        EditNSS.Text := Emp.NationalId;
        EditMatricule.Text := Emp.EmployeeNumber;
        
        // Find Dept in Combo (very basic map for now)
        if Emp.DepartmentId = 'doctors' then ComboDepartement.ItemIndex := 0
        else if Emp.DepartmentId = 'paramedical' then ComboDepartement.ItemIndex := 1
        else if Emp.DepartmentId = 'administrative' then ComboDepartement.ItemIndex := 2
        else if Emp.DepartmentId = 'contractual' then ComboDepartement.ItemIndex := 5
        else ComboDepartement.ItemIndex := -1;
        
        EditFonction.Text := Emp.PositionFr;
        DateEditEmbauche.Text := Emp.HireDate;
        
        ComboClasse.ItemIndex := ComboClasse.Items.IndexOf('Classe ' + Emp.GradeClass.ToString);
        ComboEchelon.ItemIndex := ComboEchelon.Items.IndexOf('Échelon ' + Emp.Degree.ToString);
        EditIndice.Text := Emp.IndexNumber.ToString;
      finally
        Emp.Free;
      end;
    end;
  end
  else
  begin
    LblTitle.Text := 'Nouvel Employé';
    EditNom.Text := '';
    EditPrenom.Text := '';
    EditNSS.Text := '';
    EditMatricule.Text := '';
    ComboDepartement.ItemIndex := -1;
    EditFonction.Text := '';
    DateEditEmbauche.Text := FormatDateTime('yyyy-mm-dd', Now);
    ComboClasse.ItemIndex := -1;
    ComboEchelon.ItemIndex := -1;
    EditIndice.Text := '';
  end;
end;

procedure TEmployeeEditForm.SaveEmployeeData;
var
  Emp: TEmployee;
begin
  if FEmployeeId > 0 then
    Emp := TEmployee.LoadFromDB(FEmployeeId)
  else
    Emp := TEmployee.Create;
    
  if Assigned(Emp) then
  begin
    try
      Emp.LastName := EditNom.Text;
      Emp.FirstName := EditPrenom.Text;
      Emp.NationalId := EditNSS.Text;
      Emp.EmployeeNumber := EditMatricule.Text; // Will auto-gen if empty on insert
      
      case ComboDepartement.ItemIndex of
        0: Emp.DepartmentId := 'doctors';
        1: Emp.DepartmentId := 'paramedical';
        2: Emp.DepartmentId := 'administrative';
        3: Emp.DepartmentId := 'workers';
        4: Emp.DepartmentId := 'workers';
        5: Emp.DepartmentId := 'contractual';
        else Emp.DepartmentId := 'administrative';
      end;
      
      Emp.PositionFr := EditFonction.Text;
      Emp.HireDate := DateEditEmbauche.Text;
      
      if ComboClasse.ItemIndex >= 0 then
        Emp.GradeClass := StrToIntDef(ComboClasse.Selected.Text.Replace('Classe ', ''), 1);
        
      if ComboEchelon.ItemIndex >= 0 then
        Emp.Degree := StrToIntDef(ComboEchelon.Selected.Text.Replace('Échelon ', ''), 0);
        
      Emp.IndexNumber := StrToIntDef(EditIndice.Text, 0);
      
      Emp.Save;
    finally
      Emp.Free;
    end;
  end;
end;

procedure TEmployeeEditForm.FormCreate(Sender: TObject);
begin
  LblTitle.Text := 'Editer Employé';
  LblSection1Title.Text := 'Informations Personnelles';
  LblSection2Title.Text := 'Données Professionnelles';
  LblSection3Title.Text := 'Classification & Salaire';
  
  EditNom.TextPrompt := 'Nom';
  EditPrenom.TextPrompt := 'Prénom';
  EditNSS.TextPrompt := 'N° Sécurité Sociale';
  
  EditMatricule.TextPrompt := 'Matricule (ex: EMP-001)';
  EditFonction.TextPrompt := 'Fonction Occupée';
  DateEditEmbauche.TextPrompt := 'Date d''embauche (JJ/MM/AAAA)';
  
  EditIndice.TextPrompt := 'Point Indiciaire';
  
  BtnCancel.Text := 'Annuler';
  BtnSave.Text := 'Sauvegarder';
  
  // Dummy ComboBox Data Setup
  ComboDepartement.Items.Add('Médecins');
  ComboDepartement.Items.Add('Paramédical');
  ComboDepartement.Items.Add('Administration');
  ComboDepartement.Items.Add('Technique');
  ComboDepartement.Items.Add('Entretien');
  ComboDepartement.Items.Add('Contractuel');
  ComboDepartement.ItemIndex := -1;
  
  ComboClasse.Items.Add('Classe 10');
  ComboClasse.Items.Add('Classe 11');
  ComboClasse.Items.Add('Classe 12');
  ComboClasse.Items.Add('Classe 16');
  ComboClasse.ItemIndex := -1;
  
  ComboEchelon.Items.Add('Échelon 0');
  ComboEchelon.Items.Add('Échelon 1');
  ComboEchelon.Items.Add('Échelon 2');
  ComboEchelon.Items.Add('Échelon 3');
  ComboEchelon.ItemIndex := -1;
end;

procedure TEmployeeEditForm.FormShow(Sender: TObject);
begin
  LoadEmployeeData;
end;

end.
