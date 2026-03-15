unit FrmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts;

type
  TMainForm = class(TForm)
    bgRect: TRectangle;
    SidebarRect: TRectangle;
    TopHeaderRect: TRectangle;
    ContentLayout: TLayout;
    AppTitleLabel: TLabel;
    PageTitleLabel: TLabel;
    ClockLabel: TLabel;
    UserProfileRect: TRectangle;
    UserNameLabel: TLabel;
    UserRoleLabel: TLabel;
    LogoutBtn: TButton;
    SidebarMenuLayout: TLayout;
    
    // Menu Buttons
    BtnDashboard: TButton;
    BtnEmployees: TButton;
    BtnSalary: TButton;
    BtnReports: TButton;
    BtnSettings: TButton;
    TimerClock: TTimer;
    
    procedure FormCreate(Sender: TObject);
    procedure TimerClockTimer(Sender: TObject);
    procedure MenuButtonClick(Sender: TObject);
    procedure LogoutBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure SetActiveMenu(ActiveBtn: TButton);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  FrmDashboard, FrmEmployees, FrmSalaryCalc, FrmBareme, FrmSettings;

{$R *.fmx}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Initialize clock and update immediately
  TimerClock.Enabled := True;
  TimerClockTimer(Self);
  
  // Assign accented strings dynamically to avoid RLINK32 FMX errors
  Self.Caption := 'HSMS - Système de Gestion des Salaires';
  BtnEmployees.Text := 'Gestion Employés';
  BtnReports.Text := 'Grilles & Barèmes';
  BtnSettings.Text := 'Paramètres Généraux';
  
  // Embed the Dashboard Frame inside the Content Layout
  if not Assigned(DashboardFrame) then
    DashboardFrame := TDashboardFrame.Create(Self);
  
  DashboardFrame.Parent := ContentLayout;
  DashboardFrame.Align := TAlignLayout.Client;
  // DashboardFrame is embedded as a child, setting Parent implies it is visible.

  // Set default active menu
  SetActiveMenu(BtnDashboard);
  PageTitleLabel.Text := BtnDashboard.Text;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TMainForm.LogoutBtnClick(Sender: TObject);
begin
  // For UX design, let's terminate or hide when logging out
  Application.Terminate;
end;

procedure TMainForm.MenuButtonClick(Sender: TObject);
var
  Btn: TButton;
begin
  if Sender is TButton then
  begin
    Btn := TButton(Sender);
    SetActiveMenu(Btn);
    PageTitleLabel.Text := Btn.Text;
    
    // Hide active frames
    if Assigned(DashboardFrame) then
      DashboardFrame.Visible := False;
    if Assigned(EmployeesFrame) then
      EmployeesFrame.Visible := False;
    if Assigned(SalaryCalcFrame) then
      SalaryCalcFrame.Visible := False;
    if Assigned(BaremeFrame) then
      BaremeFrame.Visible := False;
    if Assigned(SettingsFrame) then
      SettingsFrame.Visible := False;
    
    // Logic: dynamically load a frame inside ContentLayout based on the button clicked
    if Btn = BtnDashboard then
    begin
      if Assigned(DashboardFrame) then
        DashboardFrame.Visible := True;
    end
    else if Btn = BtnEmployees then
    begin
      if not Assigned(EmployeesFrame) then
      begin
        EmployeesFrame := TEmployeesFrame.Create(Self);
        EmployeesFrame.Parent := ContentLayout;
        EmployeesFrame.Align := TAlignLayout.Client;
      end;
      EmployeesFrame.Visible := True;
    end
    else if Btn = BtnSalary then
    begin
      if not Assigned(SalaryCalcFrame) then
      begin
        SalaryCalcFrame := TSalaryCalcFrame.Create(Self);
        SalaryCalcFrame.Parent := ContentLayout;
        SalaryCalcFrame.Align := TAlignLayout.Client;
      end;
      SalaryCalcFrame.Visible := True;
    end
    else if Btn = BtnReports then
    begin
      // BtnReports now points to Grilles & Barèmes
      if not Assigned(BaremeFrame) then
      begin
        BaremeFrame := TBaremeFrame.Create(Self);
        BaremeFrame.Parent := ContentLayout;
        BaremeFrame.Align := TAlignLayout.Client;
      end;
      BaremeFrame.Visible := True;
    end
    else if Btn = BtnSettings then
    begin
      if not Assigned(SettingsFrame) then
      begin
        SettingsFrame := TSettingsFrame.Create(Self);
        SettingsFrame.Parent := ContentLayout;
        SettingsFrame.Align := TAlignLayout.Client;
      end;
      SettingsFrame.Visible := True;
    end
    else
    begin
       // Future frames will be handled here
    end;
  end;
end;

procedure TMainForm.SetActiveMenu(ActiveBtn: TButton);
var
  I: Integer;
begin
  // Reset typography for all buttons
  for I := 0 to SidebarMenuLayout.ChildrenCount - 1 do
  begin
    if SidebarMenuLayout.Children[I] is TButton then
    begin
      TButton(SidebarMenuLayout.Children[I]).Font.Style := [];
      // If we used custom styles or shapes for active states, we'd reset them here
    end;
  end;
  
  // Highlight the selected button's font to Bold
  ActiveBtn.Font.Style := [TFontStyle.fsBold];
end;

procedure TMainForm.TimerClockTimer(Sender: TObject);
begin
  ClockLabel.Text := FormatDateTime('hh:nn:ss - dd mmm yyyy', Now);
end;

end.
