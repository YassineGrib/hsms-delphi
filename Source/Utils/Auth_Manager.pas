unit Auth_Manager;

{
  Auth_Manager — Gestion de l'authentification HSMS
  ===================================================
  Gère la connexion/déconnexion, les rôles, et la session utilisateur.
  Rôles : admin | payroll_officer | viewer
}

interface

uses
  System.SysUtils, FireDAC.Comp.Client;

type
  TUserRole = (urNone, urViewer, urPayrollOfficer, urAdmin);

  TSessionUser = record
    ID: Integer;
    Username: string;
    FullName: string;
    Role: TUserRole;
    IsLoggedIn: Boolean;
    function RoleLabel: string;
    function CanEdit: Boolean;
    function CanAdmin: Boolean;
  end;

  TAuthResult = (arSuccess, arInvalidCredentials, arAccountLocked, arAccountDisabled, arError);

  TAuthManager = class
  private
    class var FCurrentUser: TSessionUser;
    class var FMaxLoginAttempts: Integer;
    class function RoleFromString(const ARole: string): TUserRole;
    class function HashPassword(const APassword: string): string;
    class procedure IncrementLoginAttempts(AConnection: TFDConnection; const AUsername: string);
    class procedure ResetLoginAttempts(AConnection: TFDConnection; const AUsername: string);
    class procedure UpdateLastLogin(AConnection: TFDConnection; const AUsername: string);
  public
    class constructor Create;
    class function Login(AConnection: TFDConnection;
                        const AUsername, APassword: string): TAuthResult;
    class procedure Logout;
    class function ChangePassword(AConnection: TFDConnection;
                                 const AOldPassword, ANewPassword: string): Boolean;
    class function ResetUserPassword(AConnection: TFDConnection;
                                    const AUsername, ANewPassword: string): Boolean;
    class function CurrentUser: TSessionUser;
    class function IsLoggedIn: Boolean;
  end;

implementation

uses
  System.Hash;

{ TSessionUser }

function TSessionUser.RoleLabel: string;
begin
  case Role of
    urAdmin:          Result := 'Administrateur';
    urPayrollOfficer: Result := 'Responsable Paie';
    urViewer:         Result := 'Observateur';
  else
    Result := 'Inconnu';
  end;
end;

function TSessionUser.CanEdit: Boolean;
begin
  Result := Role in [urAdmin, urPayrollOfficer];
end;

function TSessionUser.CanAdmin: Boolean;
begin
  Result := Role = urAdmin;
end;

{ TAuthManager }

class constructor TAuthManager.Create;
begin
  FMaxLoginAttempts := 5;
  FCurrentUser.IsLoggedIn := False;
  FCurrentUser.Role := urNone;
end;

class function TAuthManager.RoleFromString(const ARole: string): TUserRole;
begin
  if ARole = 'admin' then
    Result := urAdmin
  else if ARole = 'payroll_officer' then
    Result := urPayrollOfficer
  else if ARole = 'viewer' then
    Result := urViewer
  else
    Result := urNone;
end;

class function TAuthManager.HashPassword(const APassword: string): string;
begin
  Result := THashSHA2.GetHashString(APassword);
end;

class procedure TAuthManager.IncrementLoginAttempts(AConnection: TFDConnection;
  const AUsername: string);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text :=
      'UPDATE users SET login_attempts = login_attempts + 1 ' +
      'WHERE username = :u';
    Q.ParamByName('u').AsString := AUsername;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

class procedure TAuthManager.ResetLoginAttempts(AConnection: TFDConnection;
  const AUsername: string);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text :=
      'UPDATE users SET login_attempts = 0 WHERE username = :u';
    Q.ParamByName('u').AsString := AUsername;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

class procedure TAuthManager.UpdateLastLogin(AConnection: TFDConnection;
  const AUsername: string);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text :=
      'UPDATE users SET last_login = datetime(''now''), login_attempts = 0 ' +
      'WHERE username = :u';
    Q.ParamByName('u').AsString := AUsername;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

class function TAuthManager.Login(AConnection: TFDConnection;
  const AUsername, APassword: string): TAuthResult;
var
  Q: TFDQuery;
  StoredHash, InputHash: string;
  Attempts, IsActive: Integer;
begin
  Result := arError;

  if (AUsername = '') or (APassword = '') then
  begin
    Result := arInvalidCredentials;
    Exit;
  end;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text :=
      'SELECT id, username, password_hash, full_name, role, ' +
      '       is_active, login_attempts ' +
      'FROM users WHERE username = :u';
    Q.ParamByName('u').AsString := LowerCase(Trim(AUsername));
    Q.Open;

    if Q.IsEmpty then
    begin
      Result := arInvalidCredentials;
      Exit;
    end;

    IsActive := Q.FieldByName('is_active').AsInteger;
    if IsActive = 0 then
    begin
      Result := arAccountDisabled;
      Exit;
    end;

    Attempts := Q.FieldByName('login_attempts').AsInteger;
    if Attempts >= FMaxLoginAttempts then
    begin
      Result := arAccountLocked;
      Exit;
    end;

    StoredHash := Q.FieldByName('password_hash').AsString;
    InputHash := HashPassword(APassword);

    if StoredHash <> InputHash then
    begin
      IncrementLoginAttempts(AConnection, AUsername);
      Result := arInvalidCredentials;
      Exit;
    end;

    // Success — populate session
    FCurrentUser.ID := Q.FieldByName('id').AsInteger;
    FCurrentUser.Username := Q.FieldByName('username').AsString;
    FCurrentUser.FullName := Q.FieldByName('full_name').AsString;
    FCurrentUser.Role := RoleFromString(Q.FieldByName('role').AsString);
    FCurrentUser.IsLoggedIn := True;

    UpdateLastLogin(AConnection, AUsername);
    Result := arSuccess;

  finally
    Q.Free;
  end;
end;

class procedure TAuthManager.Logout;
begin
  FCurrentUser.IsLoggedIn := False;
  FCurrentUser.Role := urNone;
  FCurrentUser.ID := 0;
  FCurrentUser.Username := '';
  FCurrentUser.FullName := '';
end;

class function TAuthManager.ChangePassword(AConnection: TFDConnection;
  const AOldPassword, ANewPassword: string): Boolean;
var
  Q: TFDQuery;
  StoredHash, OldHash, NewHash: string;
begin
  Result := False;
  if not FCurrentUser.IsLoggedIn then Exit;
  if Length(ANewPassword) < 4 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text := 'SELECT password_hash FROM users WHERE id = :id';
    Q.ParamByName('id').AsInteger := FCurrentUser.ID;
    Q.Open;

    if Q.IsEmpty then Exit;

    StoredHash := Q.FieldByName('password_hash').AsString;
    OldHash := HashPassword(AOldPassword);

    if StoredHash <> OldHash then Exit;

    NewHash := HashPassword(ANewPassword);
    Q.Close;
    Q.SQL.Text :=
      'UPDATE users SET password_hash = :h, updated_at = datetime(''now'') ' +
      'WHERE id = :id';
    Q.ParamByName('h').AsString := NewHash;
    Q.ParamByName('id').AsInteger := FCurrentUser.ID;
    Q.ExecSQL;
    Result := True;

  finally
    Q.Free;
  end;
end;

class function TAuthManager.ResetUserPassword(AConnection: TFDConnection;
  const AUsername, ANewPassword: string): Boolean;
var
  Q: TFDQuery;
  NewHash: string;
begin
  Result := False;
  if not FCurrentUser.CanAdmin then Exit;
  if Length(ANewPassword) < 4 then Exit;

  NewHash := HashPassword(ANewPassword);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;
    Q.SQL.Text :=
      'UPDATE users SET password_hash = :h, login_attempts = 0, ' +
      '  updated_at = datetime(''now'') WHERE username = :u';
    Q.ParamByName('h').AsString := NewHash;
    Q.ParamByName('u').AsString := AUsername;
    Q.ExecSQL;
    Result := Q.RowsAffected > 0;
  finally
    Q.Free;
  end;
end;

class function TAuthManager.CurrentUser: TSessionUser;
begin
  Result := FCurrentUser;
end;

class function TAuthManager.IsLoggedIn: Boolean;
begin
  Result := FCurrentUser.IsLoggedIn;
end;

end.
