{ ----------------------------------------------------------------------------
  MIT License

  Copyright (c) 2023 Adam Foflonker

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
  ---------------------------------------------------------------------------- }

unit Powerhouse.Forms.Login;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Powerhouse.Database, Powerhouse.Appliance, Powerhouse.User,
  Powerhouse.JsonSerializer, Powerhouse.Logger, Powerhouse.Forms.Home;

type
  TPhfLogin = class(TForm)
    edtUsername: TEdit;
    pnlLogin: TPanel;
    edtPassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lnkForgotPassword: TLinkLabel;
    btnLogin: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;

var
  g_LoginForm: TPhfLogin;

implementation

{$R *.dfm}

procedure TPhfLogin.FormCreate(Sender: TObject);
begin
  g_Database := PhDatabase.Create('Assets/PowerhouseDb.mdb');
end;

procedure TPhfLogin.FormShow(Sender: TObject);
begin
  g_HomeForm.Disable();
end;

procedure TPhfLogin.btnLoginClick(Sender: TObject);
var
  userName, pswd: string;
  userFound: boolean;
  newUser: PhUser;
begin
  userName := edtUsername.Text;
  pswd := edtPassword.Text;

  with g_Database do
  begin
    TblUsers.First();

    while not TblUsers.Eof do
    begin
      userFound := (userName = TblUsers[TBL_FIELD_NAME_USERS_USERNAME]) or
        (userName = TblUsers[TBL_FIELD_NAME_USERS_EMAIL_ADDRESS]);
      if userFound then
        break;

      TblUsers.Next();
    end;

    if userFound then
    begin
      newUser := PhUser.Create(TblUsers[TBL_FIELD_NAME_USERS_PK]);

      if newUser.CheckPassword(pswd) then
      begin
        g_CurrentUser := newUser;
        PhLogger.Info('Welcome %s %s!', [g_CurrentUser.GetForenames(),
          g_CurrentUser.GetSurname()]);

        g_HomeForm.Enable(@Self);
        // Self.Hide();
        // TODO: Load appliances from JSON
        // TODO: Perform post-login stuff
      end
      else
      begin
        PhLogger.Error('Incorrect password!');
        edtPassword.SetFocus();
      end;
    end
    else
    begin
      PhLogger.Error('Username or email address not found');
      edtUsername.SetFocus();
    end;

    TblUsers.First();
  end;
end;

end.
