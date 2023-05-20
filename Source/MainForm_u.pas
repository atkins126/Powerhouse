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

unit MainForm_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Hash, Vcl.ComCtrls,
  IdHTTP, IdSSLOpenSSL, LoginForm;

type
  TForm1 = class(TForm)
    btnGUID: TButton;
    edtGUID: TEdit;
    edtPassword: TEdit;
    edtHash: TEdit;
    btnHash: TButton;
    redQuestion: TRichEdit;
    btnAsk: TButton;
    redAnswer: TRichEdit;
    procedure btnGUIDClick(Sender: TObject);
    procedure btnHashClick(Sender: TObject);
    function StringToSaltedMD5Hash(const text: string): string;
    procedure btnAskClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnAskClick(Sender: TObject);
const
  APIUrl: string = 'https://api.openai.com/v1/chat/completions';
  APIKey: string = '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';
var
  sQuestion, sAnswer: string;
  IdHTTP: TIdHttp;
  IdSSL: TIdSSLIOHandlerSocketOpenSSL;
  RequestJSON, ResponseJSON: string;
  R: TStream;
begin
  IdSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  IdHTTP := TIdHttp.Create(nil);
  IdHTTP.IOHandler := IdSSL;
  IdHTTP.Request.CustomHeaders.Add('Authorization: Bearer ' + APIKey);
  IdHTTP.Request.ContentType := 'application/json';

  sQuestion := redQuestion.text;
  // RequestJSON := Format('{"prompt": "%s"}', [sQuestion]);

  // RequestJSON := '{"prompt": "What is electricity?"}';
  RequestJSON := 'req.txt';

  // try

  ResponseJSON := IdHTTP.Post(APIUrl, RequestJSON);
  sAnswer := ResponseJSON;
  // except
  // on e: Exception do
  // begin
  // ShowMessage(e.Message);
  // end
  // end;

  redAnswer.Lines.Add(sAnswer);
  R.Free();
end;

procedure TForm1.btnGUIDClick(Sender: TObject);
var
  newGUID: TGUID;
  sHexGUID: string;
begin
  CreateGUID(newGUID);
  sHexGUID := GUIDToString(newGUID);

  sHexGUID := StringReplace(sHexGUID, '{', '', [rfReplaceAll]);
  sHexGUID := StringReplace(sHexGUID, '}', '', [rfReplaceAll]);
  sHexGUID := StringReplace(sHexGUID, '-', '', [rfReplaceAll]);

  edtGUID.text := sHexGUID;
end;

procedure TForm1.btnHashClick(Sender: TObject);
begin
  edtHash.text := StringToSaltedMD5Hash(edtPassword.text);
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
   LoginForm.Form2.Show();
end;

function TForm1.StringToSaltedMD5Hash(const text: string): string;
var
  MD5: THashMD5;
  sHash: string;
begin
  MD5 := THashMD5.Create();
  // Hashing password and then salting it
  sHash := MD5.GetHashString(text);

  // Dynamic salt
  sHash := sHash.Insert(Length(text),
    MD5.GetHashString(IntToStr(Length(text))));
  sHash := MD5.GetHashString(sHash) + '==';

  Result := sHash;
end;

end.
