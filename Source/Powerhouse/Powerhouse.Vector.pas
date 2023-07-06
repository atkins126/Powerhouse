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

unit Powerhouse.Vector;

interface

uses
  System.SysUtils, System.Generics.Defaults, System.Math, Powerhouse.Types;

type
  PhVector<_Ty> = class
  public
    constructor Create(const capacity: uint64); overload;
    constructor Create(); overload;
    destructor Destroy(); override;

    procedure EmplaceBack(const value: _Ty);
    procedure PushBack(const value: _Ty);
    procedure PopBack();

    procedure Resize(const newSize: uint64);
    procedure Reserve(const newCapacity: uint64);
    procedure Clear();

    function Empty(): bool; inline;
    function Size(): uint64; inline;
    function Capacity(): uint64; inline;

    function Front(): _Ty;
    function Back(): _Ty;

    function At(const index: uint32): _Ty;

  private
    function GetItem(const index: uint32): _Ty;
    procedure SetItem(const index: uint32; const value: _Ty);

  public
    property Items[const index: uint32]: _Ty read GetItem
      write SetItem; default;

  private type
    Iterator = record
    public
      constructor Create(vector: PhVector<_Ty>; index: int);

      function MoveNext(): bool;

      function GetCurrent(): _Ty;
      property Current: _Ty read GetCurrent;

    private
      m_Vector: PhVector<_Ty>;
      m_Index: int;
    end;

  public
    function GetEnumerator(): Iterator;

  private
    function GetCapacity(): uint64;
    procedure SetCapacity(const newCapacity: uint64);

    procedure Grow();

  private
    m_Data: TArray<_Ty>;
    m_Size: uint64;
  end;

implementation

constructor PhVector<_Ty>.Create(const capacity: uint64);
begin
  m_Size := 0;
  SetCapacity(capacity);
end;

constructor PhVector<_Ty>.Create();
begin
  m_Size := 0;
  SetCapacity(1);
end;

destructor PhVector<_Ty>.Destroy();
begin
  inherited;

  Clear();
end;

procedure PhVector<_Ty>.EmplaceBack(const value: _Ty);
begin
  if m_Size = GetCapacity() then
    Grow();

  m_Data[m_Size] := value;
  Inc(m_Size);
end;

procedure PhVector<_Ty>.PushBack(const value: _Ty);
begin
  EmplaceBack(value);
end;

procedure PhVector<_Ty>.PopBack();
begin
  if m_Size > 0 then
  begin
    Dec(m_Size);
    m_Data[m_size] := Default (_Ty);
  end;
end;

procedure PhVector<_Ty>.Resize(const newSize: uint64);
begin
  if newSize > m_Size then
  begin
    if newSize > GetCapacity() then
      SetCapacity(newSize);

    while m_Size < newSize do
    begin
      m_Data[m_Size] := Default (_Ty);
      Inc(m_Size);
    end;
  end
  else if newSize < m_Size then
  begin
    while m_Size > newSize do
    begin
      Dec(m_Size);
      m_Data[m_Size] := Default (_Ty);
    end;

    SetCapacity(newSize);
  end;
end;

procedure PhVector<_Ty>.Reserve(const newCapacity: uint64);
begin
  if newCapacity > GetCapacity() then
    SetCapacity(newCapacity);
end;

procedure PhVector<_Ty>.Clear();
begin
  while m_Size > 0 do
    PopBack();

  SetCapacity(0);
end;

function PhVector<_Ty>.Empty(): bool;
begin
  Result := m_Size = 0;
end;

function PhVector<_Ty>.Size(): uint64;
begin
  Result := m_Size;
end;

function PhVector<_Ty>.Capacity(): uint64;
begin
  Result := GetCapacity();
end;

function PhVector<_Ty>.Front(): _Ty;
begin
  if m_Size > 0 then
    Result := m_Data[0]
  else
    raise EListError.Create('Cannot get Front of an empty vector!');
end;

function PhVector<_Ty>.Back(): _Ty;
begin
  if m_Size > 0 then
    Result := m_Data[m_Size - 1]
  else
    raise EListError.Create('Cannot get Back of an empty vector!');
end;

function PhVector<_Ty>.At(const index: uint32): _Ty;
begin
  Result := GetItem(index);
end;

function PhVector<_Ty>.GetItem(const index: uint32): _Ty;
begin
  if (index > m_Size) then
    raise EArgumentOutOfRangeException.Create('Index was out of range!');

  Result := m_Data[index];
end;

procedure PhVector<_Ty>.SetItem(const index: uint32; const value: _Ty);
begin
  if (index > m_Size) then
    raise EArgumentOutOfRangeException.Create('Index was out of range!');

  m_Data[index] := value;
end;

constructor PhVector<_Ty>.Iterator.Create(vector: PhVector<_Ty>; index: int);
begin
  m_Vector := vector;
  m_Index := index;
end;

function PhVector<_Ty>.Iterator.MoveNext(): bool;
begin
  if m_Index <> -1 then
    Result := m_Index < (m_Vector.Size() - 1)
  else
    Result := true;

  if Result then
    Inc(m_Index);
end;

function PhVector<_Ty>.Iterator.GetCurrent(): _Ty;
begin
  Result := m_Vector[m_Index];
end;

function PhVector<_Ty>.GetEnumerator(): Iterator;
begin
  Result := Iterator.Create(Self, -1);
end;

function PhVector<_Ty>.GetCapacity(): uint64;
begin
  Result := Length(m_Data);
end;

procedure PhVector<_Ty>.SetCapacity(const newCapacity: uint64);
begin
  if newCapacity <> GetCapacity then
  begin
    SetLength(m_Data, newCapacity);
    m_Size := Min(m_Size, newCapacity);
  end;
end;

procedure PhVector<_Ty>.Grow();
var
  newCapacity: int64;
begin
  if GetCapacity() < 64 then
    newCapacity := GetCapacity() * 2
  else
    newCapacity := GetCapacity() + (GetCapacity() div 4);

  SetCapacity(newCapacity);
end;

end.
