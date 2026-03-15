unit FrmLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.Edit, FMX.StdCtrls, FMX.Effects,
  FMX.Ani;

type
  TLoginForm = class(TForm)
    bgRect: TRectangle;
    CardRect: TRectangle;
    ShadowEffect1: TShadowEffect;
    HeaderRect: TRectangle;
    LabelTitle: TLabel;
    LabelIcon: TLabel;
    LabelSubtitle: TLabel;
    EditUser: TEdit;
    EditPass: TEdit;
    BtnLogin: TButton;
    LabelError: TLabel;
    LabelAttempts: TLabel;
    BtnTogglePass: TButton;
    FloatAnimationEntrance: TFloatAnimation;
    FloatAnimationShake: TFloatAnimation;
    procedure FormShow(Sender: TObject);
    procedure BtnLoginClick(Sender: TObject);
    procedure BtnTogglePassClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LoginForm: TLoginForm;

implementation

uses
  FrmMain;

{$R *.fmx}

procedure TLoginForm.BtnLoginClick(Sender: TObject);
begin
  // UI UX purposes only
  if (EditUser.Text = '') or (EditPass.Text = '') then
  begin
    LabelError.Text := 'Veuillez saisir votre nom d''utilisateur et mot de passe.';
    LabelError.Visible := True;
    
    // Trigger Shake animation
    FloatAnimationShake.Start;
  end
  else
  begin
    LabelError.Visible := False;
    
    if not Assigned(MainForm) then
      Application.CreateForm(TMainForm, MainForm);
      
    MainForm.Show;
    Self.Hide;
  end;
end;

procedure TLoginForm.BtnTogglePassClick(Sender: TObject);
begin
  EditPass.Password := not EditPass.Password;
  if EditPass.Password then
    BtnTogglePass.Text := '👁'
  else
    BtnTogglePass.Text := '🔒';
end;

procedure TLoginForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Terminate if the login form is closed
  Application.Terminate;
end;

procedure TLoginForm.FormShow(Sender: TObject);
begin
  // Start the card entrance animation
  FloatAnimationEntrance.Start;
end;

end.
