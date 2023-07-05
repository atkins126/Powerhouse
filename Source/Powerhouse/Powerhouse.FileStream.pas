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

unit Powerhouse.FileStream;

interface

uses
  System.SysUtils, Winapi.Windows, Powerhouse.Types, Powerhouse.Appliance,
  Powerhouse.Database, Powerhouse.Logger;

type
  PhWriteMode = (Append = 0, Overwrite);

type
  PhFileStream = class
  public
    class function ReadAllText(const path: string): string;

    class procedure WriteAllText(const path, text: string;
      const writeMode: PhWriteMode);

    class procedure CreateFile(const path: string); static;

    class function IsFile(const path: string): bool; static;
    class function IsDir(const dir: string): bool; static;

  private
    class procedure OpenFile(const path: string);
    class procedure CloseFile();

  private
    class var s_File: TextFile;
  end;

implementation

class function PhFileStream.ReadAllText(const path: string): string;
var
  buf, text: string;
begin
  OpenFile(path);

  text := '';
  while not Eof(s_File) do
  begin
    Readln(s_File, buf);
    text := text + buf + #13#10;
  end;

  CloseFile();
  Result := text;
end;

class procedure PhFileStream.WriteAllText(const path, text: string;
  const writeMode: PhWriteMode);
begin
  if not IsFile(path) then
    CreateFile(path);

  OpenFile(path);

  case writeMode of
    Append:
      System.Append(s_File);
    Overwrite:
      System.Rewrite(s_File);
  end;

  Write(s_File, text);
  CloseFile();
end;

class procedure PhFileStream.CreateFile(const path: string);
var
  fileHandle: THandle;
begin
  fileHandle := FileCreate(path);

  if fileHandle = INVALID_HANDLE_VALUE then
    PhLogger.Error('Failed to create file: ' + path);

  FileClose(fileHandle);
end;

class function PhFileStream.IsFile(const path: string): bool;
begin
  Result := FileExists(path);
end;

class function PhFileStream.IsDir(const dir: string): bool;
begin
  Result := DirectoryExists(dir);
end;

class procedure PhFileStream.OpenFile(const path: string);
begin
  AssignFile(s_File, path);
  Reset(s_File);
end;

class procedure PhFileStream.CloseFile();
begin
  Close(s_File);
end;

end.
