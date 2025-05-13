unit Lightning;
interface
 uses GameTypes, GameUtils, DGLEngine_header;

 type TvertexAlpha  = record A1,A2,A3,A4 : byte; end;

 var
 vertexses : array[0..39,0..29] of TvertexAlpha;

 Light : integer = 1;//есть/нет освещение

procedure Processvertex(Circ : Tcircle);
procedure Drawvertex;
procedure Resetvertexses;

implementation

procedure Resetvertexses;
var j, i : integer;
begin
if Light=1 then
for i:=0 to 39 do
 for j:=0 to 29 do
 begin
 vertexses[i,j].A1:=150;
 vertexses[i,j].A2:=150;
 vertexses[i,j].A3:=150;
 vertexses[i,j].A4:=150;
 end;

 end;
procedure Drawvertex;
var i,j : integer;
begin
if Light=1 then
for i:=0 to 39 do
 for j:=0 to 29 do
 DrawRectangle2D_Fill_vertexColor(i*20,j*20,20,20,$000000,$000000,$000000,$000000,
 vertexses[i,j].A1,vertexses[i,j].A2,vertexses[i,j].A3,vertexses[i,j].A4);
 end;

procedure Processvertex(Circ : Tcircle);
var j,i : integer;
Circ2 : Tcircle;
begin
if Light=1 then
for i:=0 to 39 do
 for j:=0 to 29 do
 begin
  if PointInC(i*20,j*20,Circ) then vertexses[i,j].A1:=75;
  if PointInC(i*20+20,j*20,Circ) then vertexses[i,j].A2:=75;
  if PointInC(i*20+20,j*20+20,Circ) then vertexses[i,j].A3:=75;
  if PointInC(i*20,j*20+20,Circ) then vertexses[i,j].A4:=75;
  Circ2:=Circle(Circ.X,Circ.Y,round(Circ.Radius / 1.5));
  if PointInC(i*20,j*20,Circ2) then vertexses[i,j].A1:=37;
  if PointInC(i*20+20,j*20,Circ2) then vertexses[i,j].A2:=37;
  if PointInC(i*20+20,j*20+20,Circ2) then vertexses[i,j].A3:=37;
  if PointInC(i*20,j*20+20,Circ2) then vertexses[i,j].A4:=37;
   Circ2:=Circle(Circ.X,Circ.Y,round(Circ.Radius /2));
  if PointInC(i*20,j*20,Circ2) then vertexses[i,j].A1:=0;
  if PointInC(i*20+20,j*20,Circ2) then vertexses[i,j].A2:=0;
  if PointInC(i*20+20,j*20+20,Circ2) then vertexses[i,j].A3:=0;
  if PointInC(i*20,j*20+20,Circ2) then vertexses[i,j].A4:=0;
 end;
end;

end.
