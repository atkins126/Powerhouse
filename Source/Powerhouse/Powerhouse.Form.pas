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

unit Powerhouse.Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  PhFormPtr = ^PhForm;

  PhForm = class(TForm)
  public
    procedure Enable(); virtual; abstract;
    procedure Disable(); virtual; abstract;

    class procedure TransitionForms(const oldForm, newForm: PhFormPtr);
      overload;
    procedure TransitionForms(const newForm: PhFormPtr); overload;

    procedure Quit();

    function GetParentForm(): PhFormPtr;
    procedure SetParentForm(parentPtr: PhFormPtr);

  protected
    m_Parent: PhFormPtr;
  end;

implementation

class procedure PhForm.TransitionForms(const oldForm, newForm: PhFormPtr);
begin
  oldForm.Disable();

  newForm.SetParentForm(oldForm);
  newForm.Enable();
end;

procedure PhForm.TransitionForms(const newForm: PhFormPtr);
begin
  TransitionForms(@Self, newForm);
end;

function PhForm.GetParentForm(): PhFormPtr;
begin
  Result := m_Parent;
end;

procedure PhForm.SetParentForm(parentPtr: PhFormPtr);
begin
  m_Parent := parentPtr;
end;

procedure PhForm.Quit();
var
  myPID: DWORD;
  myHandle: THandle;
begin
  myPID := GetCurrentProcessId();
  myHandle := OpenProcess(PROCESS_TERMINATE, false, myPID);

  TerminateProcess(myHandle, 0);
  CloseHandle(myHandle);
end;

end.