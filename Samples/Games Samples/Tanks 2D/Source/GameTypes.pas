unit GameTypes;

interface
uses Windows, GameUtils, Game, DGLEngine_header, math;

type
TTank = record
Active : boolean;
X, Y, OldX,OldY ,Angle, TurellAngle, Lifes, ShootWait : integer;
Collision : TCircle;
PlayerV : real;
end;

TBullet = record
Active : boolean;
X,Y,Angle : integer;
Collision : TCircle;
end;

TRock = record
Collision : TCircle;
end;

TEXplo = record
Active : boolean;
X,Y : integer;
Frame : real;
end;

TDeadTank = record
Active : boolean;
X,Y,TAngle,Angle,wait : integer;
Px,Py,Tx,Ty : real;
end;

var
Tanks  : array [0..1] of TTank;
Bullets : array [0..20] of TBullet;
Rocks : array [0..3] of TRock;
Explos : array [0..10] of TExplo;
Deads : array [0..1] of TDeadTank;
Realistic : integer = 1;

procedure DrawTank;
procedure MoveTank;
procedure CreaTeBullet(TankIndex : integer);
procedure DrawBullets;
procedure MoveBullets;
procedure DrawRock;
procedure CreateExplo(x,y : integer);
procedure MoveExplos;
procedure DrawExplos;
procedure MoveEnemy;
procedure SetPlayer;
Procedure SetEnemy;
procedure CreateDead(TankIndex : integer);
procedure DoMoveDead;
procedure DoDrawDead;

var EnemyAi : integer = 0;

implementation
uses Lightning;

function SoundPos(x,y : integer):Tpoint;
begin
result.X:=(x-Tanks[0].X) div 80;
result.Y:=(y-Tanks[0].Y) div 60;
end;

procedure DoDrawDead;
var i,color : integer;
begin
for i:=0 to 1 do
if Deads[i].Active then
begin
if i<>0 then color:=$0000FF  else color:=$FFFFFF;
DrawTexture2D(korpus,Deads[i].X+10,Deads[i].Y+10,64,128,deads[i].Angle,150-Deads[i].wait,$000000);
DrawTexture2D(korpus,deads[i].X,deads[i].Y,64,128,deads[i].Angle,200-Deads[i].wait,color);
DrawTexture2D(pushka,round(deads[i].TX),round(deads[i].TY),64,128,deads[i].TAngle,200-Deads[i].wait,color);
end;
end;

procedure DoMoveDead;
var i : integer;
begin
for i:=0 to 1 do
 if Deads[i].Active then
 begin

 if Deads[i].wait=0 then
begin
 Deads[i].TX:=Deads[i].TX+Deads[i].Px;
 Deads[i].TY:=Deads[i].TY+Deads[i].PY;
 if Deads[i].Px>0 then Deads[i].Px:=Deads[i].Px-0.4 else Deads[i].Px:=Deads[i].Px+0.4;
 if Deads[i].Py>0 then Deads[i].Py:=Deads[i].Py-0.4 else Deads[i].Py:=Deads[i].Py+0.4;

 if round( Deads[i].Px+ Deads[i].Py)=0 then
  Deads[i].wait:=Deads[i].wait+1;

end else
begin
 Deads[i].wait:=Deads[i].wait+1;
 if Deads[i].wait=60 then
 case i of
 0 : SetPlayer;
 1 : SetEnemy;
 end;

 if Deads[i].wait>140 then Deads[i].Active:=false;
end;

 end;

end;

procedure CreateDead(TankIndex : integer);
 function Sign:integer;
 begin
 case random(2) of
 0:result:=1;
 1:result:=-1;
 end;
 end;
begin
Deads[TankIndex].wait:=0;
Tanks[TankIndex].Active:=false;
Deads[TankIndex].Active:=true;
Deads[TankIndex].Angle:=Tanks[TankIndex].Angle;
Deads[TankIndex].X:=Tanks[TankIndex].X;
Deads[TankIndex].Y:=Tanks[TankIndex].Y;
Deads[TankIndex].TX:=Tanks[TankIndex].X;
Deads[TankIndex].TY:=Tanks[TankIndex].Y;
Deads[TankIndex].TAngle:=Tanks[TankIndex].TurellAngle;
Deads[TankIndex].Px:=sign*(random(8)+5);
Deads[TankIndex].Py:=sign*(random(8)+5);
end;

procedure SetPlayer;
begin
 Tanks[0].Active:=true;
 Tanks[0].X:=400;
 Tanks[0].Y:=300;
 Tanks[0].TurellAngle:=0;
 Tanks[0].Lifes:=100;
 Tanks[0].ShootWait:=0;
 Tanks[0].PlayerV:=0;
end;

Procedure SetEnemy;
begin
 Tanks[1].Active:=true;
 Tanks[1].X:=500;
 Tanks[1].Y:=400;
 Tanks[1].TurellAngle:=0;
 Tanks[1].Lifes:=100;
 Tanks[1].ShootWait:=0;
 Tanks[1].PlayerV:=0;
end;

procedure CreateExplo(x,y : integer);
var i : integer;
begin
for i:=0 to 10 do
if not Explos[i].Active then
begin
Explos[i].Active:=true;
Explos[i].X:=x;
Explos[i].Y:=y;
Explos[i].Frame:=1.0;
SetSample3DPosition(ExploSound,SoundPos(x,y).X,SoundPos(x,y).Y,0);
PlaySample(ExploSound);
Exit;
end;
end;

procedure MoveExplos;
var i : integer;
begin
for i:=0 to 10 do

if Explos[i].Active then
begin
Explos[i].Frame:=Explos[i].Frame+0.5;
if round(Explos[i].Frame)>16 then Explos[i].Active:=false;
Processvertex(Circle(Explos[i].X,Explos[i].Y,120-round(Explos[i].Frame*3.5)));
end;

end;

procedure DrawExplos;
var i : integer;
begin
for i:=0 to 10 do
if Explos[i].Active then
DrawSprite2D(Explosion,Explos[i].X-64,Explos[i].Y-64,128,128,4,4,round(Explos[i].Frame),0,255,$FFFFFF,true);
end;

procedure MoveEnemy;
var i : integer;
begin
if Tanks[0].Active then
Tanks[1].TurellAngle:=trunc(RadToDeg(ArcTan2(Tanks[0].Y+64-(Tanks[1].Y+64), Tanks[0].X+32-(Tanks[1].X+32))))+90;

 if (Tanks[1].ShootWait>20+40*Realistic) and (Tanks[0].Active) then
 begin
 Tanks[1].ShootWait:=0;
 CreaTeBullet(1);
 end;

 Tanks[1].OldX:=Tanks[1].X;
 Tanks[1].OldY:=Tanks[1].Y;

 Tanks[1].X:=Tanks[1].X+Trunc( cos256(Tanks[1].Angle*256 div 360 + 64)*Tanks[1].PlayerV );
 Tanks[1].Y:=Tanks[1].Y+Trunc( sin256(Tanks[1].Angle*256 div 360 + 64)*Tanks[1].PlayerV );

 i:=random(13);
 case i of
 1:EnemyAi:=1;
 2:EnemyAi:=0;
 4:EnemyAi:=2;
 end;

 if (Tanks[1].X<10) or
  (Tanks[1].X+32>790) or
  (Tanks[1].y<10) or
  (Tanks[1].y+64>590) then EnemyAi:=2;


 case EnemyAi of
 1:Tanks[1].Angle:=Tanks[1].Angle-5;
 2:Tanks[1].Angle:=Tanks[1].Angle+5;
 end;

 Tanks[1].PlayerV:=Tanks[1].PlayerV-0.3;
 if Tanks[1].PlayerV<-8 then Tanks[1].PlayerV:=-8;
 Tanks[1].X:=Tanks[1].X+Trunc( cos256(Tanks[1].Angle*256 div 360 + 64)*-5 );
 Tanks[1].Y:=Tanks[1].Y+Trunc( sin256(Tanks[1].Angle*256 div 360 + 64)*-5 );

end;


procedure DrawRock;
var i : integer;
begin
for i:=0 to 3 do
begin
DrawTexture2D(TexRock,Rocks[i].Collision.X-32+5,Rocks[i].Collision.Y-32+5,64,64,0,150,$000000);
DrawTexture2D_Simple(TexRock,Rocks[i].Collision.X-32,Rocks[i].Collision.Y-32,64,64);
end;
end;

procedure CreaTeBullet(TankIndex : integer);
var i : integer;
begin
 for i:=0 to 20 do
 if not Bullets[i].Active then
 begin
 Bullets[i].Active:=true;
 Bullets[i].Angle:=Tanks[TankIndex].TurellAngle-180;
 Bullets[i].X:=Tanks[TankIndex].X+32+Trunc( cos256((Tanks[TankIndex].TurellAngle-180)*256 div 360 + 64)*45 );
 Bullets[i].Y:=(Tanks[TankIndex].Y+64)+Trunc( sin256((Tanks[TankIndex].TurellAngle-180)*256 div 360 + 64)*45 );
 if TankIndex<>0 then
 SetSample3DPosition(RocketSound,SoundPos(Bullets[i].X,Bullets[i].Y).X,SoundPos(Bullets[i].X,Bullets[i].Y).Y,0)
 else  SetSample3DPosition(RocketSound,0,0,0);
 PlaySample(RocketSound);
 Exit;
 end;
end;

procedure MoveBullets;
var i,a : integer;
begin

 for i:=0 to 20 do
 if Bullets[i].Active then
 begin
 Bullets[i].X:=Bullets[i].X+Trunc( cos256(Bullets[i].Angle*256 div 360 + 64)*20 );
 Bullets[i].Y:=Bullets[i].Y+Trunc( sin256(Bullets[i].Angle*256 div 360 + 64)*20 );
 Bullets[i].Collision.X:=Bullets[i].X;
 Bullets[i].Collision.Y:=Bullets[i].Y;
 Bullets[i].Collision.Radius:=8;

 for a:=0 to 3 do
   if CinC(Bullets[i].Collision,Rocks[a].Collision)  then
   begin
   Bullets[i].Active:=false;
   CreateExplo(Bullets[i].X,Bullets[i].Y);
   end;

 for a:=0 to 1 do
   if CinC(Bullets[i].Collision,Tanks[a].Collision)  then
   begin
   Bullets[i].Active:=false;
   CreateExplo(Bullets[i].X,Bullets[i].Y);
   if Realistic=1 then  Tanks[a].PlayerV:=Tanks[a].PlayerV/1.5;

   if a=0 then Tanks[0].Lifes:=Tanks[0].Lifes-25-Realistic*25 else Tanks[1].Lifes:=Tanks[1].Lifes-25-Realistic*25;
   end;

   Processvertex(Circle(Bullets[i].X,Bullets[i].Y,64));

 if not PointInRect(Bullets[i].X,Bullets[i].Y,0,0,800,600) then Bullets[i].Active:=false;
 end;

end;

procedure DrawBullets;
var i : integer;
begin
 for i:=0 to 20 do
 if Bullets[i].Active then
     begin
     DrawTexture2D(Texturelight,Bullets[i].X+8-64,Bullets[i].Y+8-64,128,128,0,150,$1654F8,true);
     DrawTexture2D(bullet,Bullets[i].X,Bullets[i].Y,16,16,Bullets[i].Angle+90,255,$FFFFFF);
     end;
end;

procedure DrawTank;
var i,color : integer;
begin
for i:=0 to 1 do
if Tanks[i].Active then
begin
if i<>0 then color:=$0000FF  else color:=$FFFFFF;
DrawTexture2D(korpus,Tanks[i].X+10,Tanks[i].Y+10,64,128,Tanks[i].Angle,150,$000000);
DrawTexture2D(korpus,Tanks[i].X,Tanks[i].Y,64,128,Tanks[i].Angle,255,color);
DrawTexture2D(pushka,Tanks[i].X+5,Tanks[i].Y+5,64,128,Tanks[i].TurellAngle,150,$000000);
DrawTexture2D(pushka,Tanks[i].X,Tanks[i].Y,64,128,Tanks[i].TurellAngle,255,color);
end;
end;

procedure MoveTank;
var i,a : integer;
begin
for i:=0 to 1 do
if Tanks[i].Active then
begin

if Tanks[i].Lifes<=0 then
begin
case i of
0:inc(FragsE);
1:inc(Frags);
end;
CreateDead(i);
end;

if Tanks[i].X+28>800 then
begin
Tanks[i].X:=800-28;
Tanks[i].PlayerV:=-Tanks[i].PlayerV;
end;

if Tanks[i].X+28<0 then
begin
Tanks[i].X:=-28;
Tanks[i].PlayerV:=-Tanks[i].PlayerV;
end;

if Tanks[i].Y+42>600 then
begin
Tanks[i].Y:=600-42;
Tanks[i].PlayerV:=-Tanks[i].PlayerV;
end;

if Tanks[i].Y+42<0 then
begin
Tanks[i].Y:=-42;
Tanks[i].PlayerV:=-Tanks[i].PlayerV;
end;

Tanks[i].Collision.X:=Tanks[i].X+32;
Tanks[i].Collision.Y:=Tanks[i].Y+64;
Tanks[i].Collision.Radius:=30;

Processvertex(Circle(Tanks[i].Collision.X,Tanks[i].Collision.Y,114));

for a:=0 to 3 do
if CinC(Tanks[i].Collision,Rocks[a].Collision) then
begin
Tanks[i].X:=Tanks[i].OldX;
Tanks[i].Y:=Tanks[i].OldY;
Tanks[i].PlayerV:=-Tanks[i].PlayerV;
if i=1 then EnemyAi:=1;
end;

for a:=0 to 1 do
if (a<>i) and (CinC(Tanks[i].Collision,Tanks[a].Collision)) then
begin
Tanks[i].X:=Tanks[i].OldX;
Tanks[i].Y:=Tanks[i].OldY;
Tanks[i].PlayerV:=-Tanks[i].PlayerV;
end;

Tanks[i].ShootWait:=Tanks[i].ShootWait+1;
end;
end;

end.
