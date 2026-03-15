unit FrmBareme;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.Grid,
  FMX.Grid.Style, FMX.TabControl, FMX.Effects, System.Rtti, FMX.ScrollBox,
  FireDAC.Comp.Client, DB_Helper;

type
  TBaremeFrame = class(TFrame)
    bgRect: TRectangle;
    
    // Header
    TopBarLayout: TLayout;
    TopBarRect: TRectangle;
    ShadowTopBar: TShadowEffect;
    LblPageTitle: TLabel;
    LblPageDesc: TLabel;
    
    // Tab Control for different configuration tables
    TabConfig: TTabControl;
    TabPointIndiciaire: TTabItem;
    TabIRG: TTabItem;
    TabRubriques: TTabItem;
    
    // --- Point Indiciaire Tab Content ---
    PanelPointInd: TLayout;
    TopPointInd: TLayout;
    LblCurrentPoint: TLabel;
    BtnEditPoint: TButton;
    
    GridClasses: TStringGrid;
    ColClasse: TStringColumn;
    ColDesignation: TStringColumn;
    ColIndiceMin: TStringColumn;
    
    // --- IRG Tab Content ---
    PanelIRG: TLayout;
    GridIRG: TStringGrid;
    ColTrancheIRG: TStringColumn;
    ColMinIRG: TStringColumn;
    ColMaxIRG: TStringColumn;
    ColTauxIRG: TStringColumn;
    ColAbattementIRG: TStringColumn;
    
    // --- Rubriques Tab Content ---
    PanelRubriques: TLayout;
    TopRubriques: TLayout;
    BtnAddRubrique: TButton;
    
    GridRubriques: TStringGrid;
    ColRubCode: TStringColumn;
    ColRubLibelle: TStringColumn;
    ColRubType: TStringColumn;
    ColRubTaux: TStringColumn;
    ColRubCotisable: TCheckColumn;
    ColRubImposable: TCheckColumn;
    
  public
    constructor Create(AOwner: TComponent); override;
  private
    procedure SetupTexts;
    procedure LoadData;
  end;

var
  BaremeFrame: TBaremeFrame;

implementation

{$R *.fmx}

constructor TBaremeFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetupTexts;
  LoadData;
end;

procedure TBaremeFrame.SetupTexts;
begin
  LblPageTitle.Text := 'Baremes et Configurations';
  LblPageDesc.Text := 'Gestion des grilles salariales, du bareme IRG et des rubriques de paie.';
  
  TabPointIndiciaire.Text := 'Grille Indiciaire';
  TabIRG.Text := 'Bareme I.R.G';
  TabRubriques.Text := 'Rubriques (Gains/Retenues)';
  
  LblCurrentPoint.Text := 'Valeur Actuelle du Point Indiciaire : 45.00 DZD';
  BtnEditPoint.Text := 'Modifier Valeur du Point';
  
  BtnAddRubrique.Text := '+ Nouvelle Rubrique';
  
  // Setup Grids Headers
  ColClasse.Header := 'Classe / Catégorie';
  ColDesignation.Header := 'Désignation';
  ColIndiceMin.Header := 'Indice Minimal';
  
  ColTrancheIRG.Header := 'Tranche';
  ColMinIRG.Header := 'De (DZD)';
  ColMaxIRG.Header := 'A (DZD)';
  ColTauxIRG.Header := 'Taux (%)';
  ColAbattementIRG.Header := 'Abattement';
  
  ColRubCode.Header := 'Code';
  ColRubLibelle.Header := 'Libellé';
  ColRubType.Header := 'Type';
  ColRubTaux.Header := 'Taux Fixe (%)';
  ColRubCotisable.Header := 'Soumis SS';
  ColRubImposable.Header := 'Soumis IRG';
end;

procedure TBaremeFrame.LoadData;
var
  Q: TFDQuery;
  RowIdx: Integer;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := TDBHelper.GetConnection;
    
    // 1. Bareme (Classes Overview)
    Q.SQL.Text := 'SELECT class, MIN(index_number) as min_idx FROM bareme GROUP BY class ORDER BY class';
    Q.Open;
    GridClasses.RowCount := 0;
    RowIdx := 0;
    while not Q.Eof do
    begin
      GridClasses.RowCount := GridClasses.RowCount + 1;
      GridClasses.Cells[0, RowIdx] := 'Classe ' + Q.FieldByName('class').AsString;
      GridClasses.Cells[1, RowIdx] := 'Echelon 0';
      GridClasses.Cells[2, RowIdx] := Q.FieldByName('min_idx').AsString;
      Inc(RowIdx);
      Q.Next;
    end;
    Q.Close;
    
    // 2. IRG
    Q.SQL.Text := 'SELECT * FROM irg_table ORDER BY income_from';
    Q.Open;
    GridIRG.RowCount := 0;
    RowIdx := 0;
    while not Q.Eof do
    begin
      GridIRG.RowCount := GridIRG.RowCount + 1;
      GridIRG.Cells[0, RowIdx] := 'Tranche ' + IntToStr(RowIdx + 1);
      GridIRG.Cells[1, RowIdx] := FormatFloat('0.00', Q.FieldByName('income_from').AsFloat);
      GridIRG.Cells[2, RowIdx] := FormatFloat('0.00', Q.FieldByName('income_to').AsFloat);
      GridIRG.Cells[3, RowIdx] := '-';
      GridIRG.Cells[4, RowIdx] := FormatFloat('0.00', Q.FieldByName('tax_amount').AsFloat);
      Inc(RowIdx);
      Q.Next;
    end;
    Q.Close;
    
    // 3. Rubriques (Allowances)
    Q.SQL.Text := 'SELECT * FROM allowance_types ORDER BY code';
    Q.Open;
    GridRubriques.RowCount := 0;
    RowIdx := 0;
    while not Q.Eof do
    begin
      GridRubriques.RowCount := GridRubriques.RowCount + 1;
      GridRubriques.Cells[0, RowIdx] := Q.FieldByName('code').AsString;
      GridRubriques.Cells[1, RowIdx] := Q.FieldByName('name_fr').AsString;
      GridRubriques.Cells[2, RowIdx] := 'Rubrique';
      GridRubriques.Cells[3, RowIdx] := '-';
      Inc(RowIdx);
      Q.Next;
    end;
    Q.Close;
    
  finally
    Q.Free;
  end;
end;

end.
