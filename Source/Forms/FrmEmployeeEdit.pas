unit FrmEmployeeEdit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.ListBox,
  FMX.Effects;

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
    { Private declarations }
  public
    { Public declarations }
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
  // TODO: Add actual validation logic later
  // Simulate validation issue for UX preview:
  if (EditNom.Text = '') or (EditMatricule.Text = '') then
  begin
    ShowMessage('Veuillez remplir les champs obligatoires.');
    Exit;
  end;
  
  ModalResult := mrOk;
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

end.
