unit SystemUtils;

interface

function StrToInt(const S: string): Integer;
function LowerCase(const S: string): string;
function IntToStr(Num : Integer) : String;
function DegToRad(const Degrees: Extended): Extended;

function SetCursorPos(X, Y: Integer): boolean; stdcall; external 'user32.dll';

implementation

function DegToRad(const Degrees: Extended): Extended;
begin
  Result := Degrees * (PI / 180);
end;

function IntToStr(Num : Integer) : String;
begin
  Str(Num, result);
end;

function StrToInt(const S: string): Integer;
 var
  E: Integer;
 begin
  Val(S, Result, E);
 end;

function LowerCase(const S: string): string;
var
  Ch: Char;
  L: Integer;
  Source, Dest: PChar;
begin
  L := Length(S);
  SetLength(Result, L);
  Source := Pointer(S);
  Dest := Pointer(Result);
  while L <> 0 do
  begin
    Ch := Source^;
    if (Ch >= 'A') and (Ch <= 'Z') then Inc(Ch, 32);
    Dest^ := Ch;
    Inc(Source);
    Inc(Dest);
    Dec(L);
  end;
end;

end.
