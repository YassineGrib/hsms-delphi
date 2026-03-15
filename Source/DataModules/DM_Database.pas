unit DM_Database;

{
  Module de base de donnees SQLite — HSMS
  ========================================
  Classe pure (pas de TDataModule) pour eviter le streaming FMX.
  Cree TFDConnection et TFDPhysSQLiteDriverLink par code.
}

interface

uses
  System.SysUtils, System.Classes, System.IOUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys, FireDAC.Phys.Intf,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLiteWrapper.Stat,  // static link — no sqlite3.dll needed
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet,
  FireDAC.FMXUI.Wait;  // registers the FMX wait-cursor so FireDAC doesn't block

type
  TDMDatabase = class(TObject)
  private
    FConnection:  TFDConnection;
    FDriverLink:  TFDPhysSQLiteDriverLink;
    FDBPath:      string;
    procedure InitializeDatabase;
  public
    constructor Create;
    destructor  Destroy; override;

    function  NewQuery(const ASQL: string): TFDQuery;
    procedure ExecSQL(const ASQL: string);

    property Connection: TFDConnection read FConnection;
    property DBPath:     string        read FDBPath;
  end;

var
  DMDatabase: TDMDatabase;

implementation

uses
  DB_Schema, DB_Seed, DB_Helper;

constructor TDMDatabase.Create;
begin
  inherited Create;

  FDriverLink := TFDPhysSQLiteDriverLink.Create(nil);
  FDriverLink.VendorLib := '';  // use static wrapper (no external DLL)

  FConnection             := TFDConnection.Create(nil);
  FConnection.LoginPrompt := False;

  InitializeDatabase;
end;

destructor TDMDatabase.Destroy;
begin
  if Assigned(FConnection) then
  begin
    if FConnection.Connected then
      FConnection.Close;
    FreeAndNil(FConnection);
  end;
  FreeAndNil(FDriverLink);
  inherited;
end;

procedure TDMDatabase.InitializeDatabase;
begin
  FDBPath := TPath.Combine(
    TPath.GetDirectoryName(ParamStr(0)), 'hsms.db');

  FConnection.Params.Clear;
  FConnection.Params.Add('DriverID=SQLite');
  FConnection.Params.Add('Database=' + FDBPath);
  FConnection.Params.Add('LockingMode=Normal');
  FConnection.Params.Add('Synchronous=Normal');
  FConnection.Params.Add('OpenMode=CreateUTF8');

  try
    FConnection.Open;

    ExecSQL('PRAGMA foreign_keys = ON');
    ExecSQL('PRAGMA journal_mode = WAL');

    TDBSchema.CreateAllTables(FConnection);
    TDBSchema.CreateIndexes(FConnection);
    TDBSeed.SeedAll(FConnection);

    TDBHelper.SetConnection(FConnection);

  except
    on E: Exception do
      raise Exception.CreateFmt(
        'Erreur de connexion a la base de donnees: %s', [E.Message]);
  end;
end;

function TDMDatabase.NewQuery(const ASQL: string): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FConnection;
  Result.SQL.Text   := ASQL;
  Result.Open;
end;

procedure TDMDatabase.ExecSQL(const ASQL: string);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnection;
    Q.SQL.Text   := ASQL;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
