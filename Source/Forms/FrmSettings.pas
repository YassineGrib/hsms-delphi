unit FrmSettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.TabControl, FMX.Edit,
  FMX.Ani, FMX.Effects;

type
  TSettingsFrame = class(TFrame)
    bgRect: TRectangle;
    
    TopBarLayout: TLayout;
    TopBarRect: TRectangle;
    ShadowTopBar: TShadowEffect;
    LblPageTitle: TLabel;
    LblPageDesc: TLabel;
    
    TabSettings: TTabControl;
    TabGeneral: TTabItem;
    TabPrint: TTabItem;
    TabDatabase: TTabItem;
    TabUser: TTabItem;
    
    // Database Tab Content
    PanelDatabase: TLayout;
    LblDbTitle: TLabel;
    EditDbPath: TEdit;
    BtnSelectDb: TButton;
    
    LayoutDbActions: TLayout;
    BtnBackup: TButton;
    BtnRestore: TButton;
    
    // Progress Bar and Animations for DB Backup/Restore
    ProgressBarDB: TProgressBar;
    LblProgress: TLabel;
    TimerProgress: TTimer;
    
    procedure BtnBackupClick(Sender: TObject);
    procedure TimerProgressTimer(Sender: TObject);
    procedure BtnRestoreClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  private
    procedure SetupTexts;
  end;

var
  SettingsFrame: TSettingsFrame;

implementation

{$R *.fmx}

constructor TSettingsFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetupTexts;
  ProgressBarDB.Visible := False;
  LblProgress.Visible := False;
end;

procedure TSettingsFrame.BtnBackupClick(Sender: TObject);
begin
  ProgressBarDB.Value := 0;
  ProgressBarDB.Visible := True;
  LblProgress.Text := 'Sauvegarde en cours...';
  LblProgress.Visible := True;
  TimerProgress.Enabled := True;
end;

procedure TSettingsFrame.BtnRestoreClick(Sender: TObject);
begin
  ProgressBarDB.Value := 0;
  ProgressBarDB.Visible := True;
  LblProgress.Text := 'Restauration en cours...';
  LblProgress.Visible := True;
  TimerProgress.Enabled := True;
end;

procedure TSettingsFrame.SetupTexts;
begin
  LblPageTitle.Text := 'Parametres Generaux';
  LblPageDesc.Text := 'Configuration globale du systeme HSMS.';
  
  TabGeneral.Text := 'General';
  TabPrint.Text := 'Impression';
  TabDatabase.Text := 'Base de donnees';
  TabUser.Text := 'Utilisateur';
  
  LblDbTitle.Text := 'Chemin de la Base de donnees SQLite';
  EditDbPath.Text := 'C:\HSMS\Database\hsms_data.db';
  BtnSelectDb.Text := 'Parcourir...';
  
  BtnBackup.Text := 'Sauvegarder la base de donnees';
  BtnRestore.Text := 'Restaurer une sauvegarde';
end;

procedure TSettingsFrame.TimerProgressTimer(Sender: TObject);
begin
  if ProgressBarDB.Value < 100 then
  begin
    ProgressBarDB.Value := ProgressBarDB.Value + 10;
  end
  else
  begin
    TimerProgress.Enabled := False;
    ProgressBarDB.Visible := False;
    LblProgress.Text := 'Operation terminee avec succes !';
    ShowMessage(LblProgress.Text);
  end;
end;

end.
