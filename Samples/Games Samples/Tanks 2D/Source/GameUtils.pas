unit GameUtils;

interface

type TRect=record X,Y,Width,Height : integer; end;
     TCircle=record X,Y,Radius : integer; end;

function IntToStr(Num : Integer) : String;
function StrToInt(const S: string): Integer;
function PointInRect(X1,Y1,X,Y,Width,Height : integer):boolean;
function Cos256(i: Integer): Double;
function Sin256(i: Integer): Double;
function CinC(C1 , C2 : Tcircle):boolean;
function PointInC(X,Y : integer; C : TCircle):boolean;
function Circle (X,Y,Radius : integer) : TCircle;
function Distance(X1,Y1,X2,Y2 : integer) : integer;

var
CosinTable: array[0..255] of Double;

implementation

function Distance(X1,Y1,X2,Y2 : integer) : integer;
begin
result:=round(sqrt((X2-X1)*(X2-X1)+(Y2-Y1)*(Y2-Y1)));
end;
//-----------------------------------------------------------------------------------------
function Circle (X,Y,Radius : integer) : TCircle;
begin
result.X:=X;
result.Y:=Y;
result.Radius:=Radius;
end;
//-----------------------------------------------------------------------------------------
function PointInC(X,Y : integer; C : TCircle):boolean;
begin
result:=sqrt((c.X-X)*(c.X-X)+(c.Y-Y)*(c.Y-Y))<=c.Radius;
end;
//-----------------------------------------------------------------------------------------
function CinC(C1 , C2 : Tcircle):boolean;
begin
result:=sqrt((c2.X-c1.X)*(c2.X-c1.X)+(c2.Y-c1.Y)*(c2.Y-c1.Y))<=c1.Radius+c2.Radius;
end;
//-----------------------------------------------------------------------------------------
function PointInRect(X1,Y1,X,Y,Width,Height : integer):boolean;
begin
result:=(X1>X) and (X1<X+width) and (Y1>Y) and (Y1<Y+Height);
end;
//-----------------------------------------------------------------------------------------
function IntToStr(Num : Integer) : String;
begin
  Str(Num, result);
end;
//-----------------------------------------------------------------------------------------
function StrToInt(const S: string): Integer;
var
  E: Integer;
begin
  Val(S, Result, E);
end;
//-----------------------------------------------------------------------------------------
procedure InitCosinTable;
var
  i: Integer;
begin
  for i:=0 to 255 do
    CosinTable[i] := Cos((i/256)*2*3.14);
end;
//-----------------------------------------------------------------------------------------
function Cos256(i: Integer): Double;
begin
  Result := CosinTable[i and 255];
end;
//-----------------------------------------------------------------------------------------
function Sin256(i: Integer): Double;
begin
  Result := CosinTable[(i+192) and 255];
end;

initialization
InitCosinTable;

end.
