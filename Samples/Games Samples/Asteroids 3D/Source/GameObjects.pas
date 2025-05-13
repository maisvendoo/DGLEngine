unit GameObjects;

interface
uses DGLEngine_header,GameUtils,Math,Windows;

    type TGameObj = packed record
    Active : boolean;
    X,Y,Angle,X_Old,Y_Old,Width,Height : integer;
    Velocity, Angle2, Scale, Frame : real;
    Colision : TCircle;
    end;

procedure DrawShip;
procedure SetShips;
procedure ProcessShips;
procedure ProcessControls;
procedure CreateAsteroids(X,Y : integer;Scale : real);
procedure DrawAsteroids;
procedure ProcessAsteroids;
procedure ProcessBlaster;
procedure DrawBlaster;
procedure CreateExplo(X,Y : Integer; Scale : single);
procedure ProcessExplo;
procedure DrawExplo;

var
    ShipTex,Specular,AsterTex, BlasterTex, ExplTex : cardinal;
    ExploSound,ShotSound,BreakSound : integer;
    ShipModel, Asteroid : integer;

    ShootWait : integer = 0;
implementation
var
    Ship : TGameObj;

    Asteroids : array of TGameObj;
    AsteroidsCount : integer = 0;

    Blaster : array of TGameObj;
    BlasterCount : integer = 0;

    Explo : array of TGameObj;
    ExploCount : integer = 0;


procedure CreateExplo(X,Y : Integer; Scale : single);

 function SoundPos(x,y : integer):Tpoint;
 begin
 result.X:=(x-Ship.X) div 80;
 result.Y:=(y-Ship.Y) div 60;
 end;

 procedure crExplo(a : integer);
 begin
  Explo[a].Active:=true;
  Explo[a].X:=round(x-32*scale);
  Explo[a].Y:=round(y-32*scale);
  Explo[a].Width:=round(64*Scale);
  Explo[a].Height:=round(64*Scale);
  Explo[a].Frame:=1;
  SetSample3DPosition(ExploSound,SoundPos(x,y).X,SoundPos(x,y).Y,0);
  PlaySample(ExploSound);
 end;
var i : integer;
begin
if ExploCount<>0 then
 for i:=0 to ExploCount-1 do
  if not Explo[i].Active then
  begin
  CrExplo(i);
  Exit;
  end;

 inc(ExploCount);
 SetLength(Explo,ExploCount);
 CrExplo(ExploCount-1);

end;

procedure ProcessExplo;
var i : integer;
begin
if ExploCount>0 then
 for i:=0 to ExploCount-1 do
  if Explo[i].Active then
  begin
   Explo[i].Frame:=Explo[i].Frame+0.65;
   if round(Explo[i].Frame)>12 then Explo[i].Active:=false;
  end;
end;

procedure DrawExplo;
var i : integer;
begin
if ExploCount>0 then
 for i:=0 to ExploCount-1 do
  if Explo[i].Active then
   DrawSprite2D(ExplTex,Explo[i].X,Explo[i].Y,Explo[i].Width,Explo[i].Height,
                1,12,round(Explo[i].Frame),0,250,$FFFFFF,true);
end;

//-----------------------------------------------------------------------------------------
procedure CreateBlaster(X,Y,Angle : integer );
 procedure CrBlaster(a : integer);
 begin
 Blaster[a].Active:=true;
 Blaster[a].X:=X-32;
 Blaster[a].Y:=Y-32;
 Blaster[a].Angle:=Angle;
 Blaster[a].Angle2:=0;
 Blaster[a].Colision:=Circle(Blaster[a].X+32,Blaster[a].Y+32,32);
 PlaySample(ShotSound);
 end;
var  i : integer;
begin
if BlasterCount<>0 then
 for i:=0 to BlasterCount-1 do
  if not Blaster[i].Active then
  begin
  CrBlaster(i);
  Exit;
  end;

 inc(BlasterCount);
 SetLength(Blaster,BlasterCount);
 CrBlaster(BlasterCount-1);

end;

procedure DrawBlaster;
var i : integer;
begin
if BlasterCount>0 then
 for i:=0 to BlasterCount-1 do
  if Blaster[i].Active then
   DrawTexture2D(BlasterTex,Blaster[i].X,Blaster[i].Y,64,64,round(Blaster[i].Angle2),220,$0000FF,true);
end;

procedure ProcessBlaster;
var i,f,a,g : integer;
begin
if BlasterCount>0 then
 for i:=0 to BlasterCount-1 do
  if Blaster[i].Active then
  begin
  Blaster[i].X:=Blaster[i].X+Trunc( cos(degtorad(Blaster[i].Angle + 90))*20 );
  Blaster[i].Y:=Blaster[i].Y+Trunc( sin(degtorad(Blaster[i].Angle + 90))*20 );

  Blaster[i].Angle2:=Blaster[i].Angle2+10;

  if Blaster[i].X>=840 then Blaster[i].Active:=false;
  if Blaster[i].X<=-40 then Blaster[i].Active:=false;
  if Blaster[i].Y>=640 then Blaster[i].Active:=false;
  if Blaster[i].Y<=-40 then Blaster[i].Active:=false;

  Blaster[i].Colision:=Circle(Blaster[i].X+32,Blaster[i].Y+32,32);

   for f:=0 to AsteroidsCount-1 do
  if Asteroids[f].Active then
   if CinC(Blaster[i].Colision,Asteroids[f].Colision) then
     begin
     Blaster[i].Active:=false;
     Asteroids[f].X:=Asteroids[f].X_Old;
     Asteroids[f].Y:=Asteroids[f].Y_Old;
     Asteroids[f].Active:=false;

     CreateExplo(Asteroids[f].X,Asteroids[f].Y,Asteroids[f].Scale*9);

      if Asteroids[f].scale>0.09 then
      begin
       g:=trunc(Asteroids[f].scale*8);
       if g=0 then g:=1;
       for a:=0 to g do
        CreateAsteroids(Asteroids[f].X,Asteroids[f].Y,Asteroids[f].scale/1.5);
        Exit;
      end;
     end;

  end;
end;
//-----------------------------------------------------------------------------------------
procedure CreateAsteroids(X,Y : integer; Scale : real);
 procedure CrAster(a : integer);
 begin
 Asteroids[a].Active:=true;
 Asteroids[a].X:=X;
 Asteroids[a].Y:=Y;
 Asteroids[a].Angle:=random(360);
 Asteroids[a].Scale:=Scale;
 Asteroids[a].Velocity:=0.5/Asteroids[a].Scale;
 Asteroids[a].Angle2:=0;
 Asteroids[a].Colision:=Circle(Asteroids[a].X,Asteroids[a].Y,130);
 end;
var  i : integer;
begin
if AsteroidsCount<>0 then
 for i:=0 to AsteroidsCount-1 do
  if not Asteroids[i].Active then
  begin
  CrAster(i);
  Exit;
  end;

 inc(AsteroidsCount);
 SetLength(Asteroids,AsteroidsCount);
 CrAster(AsteroidsCount-1);

end;

procedure ProcessAsteroids;
var i : integer;
begin
 for i:=0 to AsteroidsCount-1 do
  if Asteroids[i].Active then
  begin
  Asteroids[i].Angle2:=Asteroids[i].Angle2+Asteroids[i].Velocity/1.5;

  Asteroids[i].X_Old:=Asteroids[i].X;
  Asteroids[i].Y_Old:=Asteroids[i].Y;

  Asteroids[i].X:=Asteroids[i].X+Trunc( cos(degtorad(Asteroids[i].Angle + 90))*Asteroids[i].Velocity );
  Asteroids[i].Y:=Asteroids[i].Y+Trunc( sin(degtorad(Asteroids[i].Angle + 90))*Asteroids[i].Velocity );

  if Asteroids[i].X>=840 then Asteroids[i].X:=-39;
  if Asteroids[i].X<=-40 then Asteroids[i].X:=839;
  if Asteroids[i].Y>=640 then Asteroids[i].Y:=-39;
  if Asteroids[i].Y<=-40 then Asteroids[i].Y:=639;

  Asteroids[i].Colision:=Circle(Asteroids[i].X,Asteroids[i].Y,round(100*Asteroids[i].Scale));
  end;
end;

procedure DrawAsteroids;
var i : integer;
begin
 for i:=0 to AsteroidsCount-1 do
  if Asteroids[i].Active then
  begin
  BeginObj3D;
  SetLight(1,1,1);
  Position2D(Asteroids[i].X,Asteroids[i].Y);
  RotateZ(-Asteroids[i].Angle2/4);
  RotateY(Asteroids[i].Angle2/2);
  RotateX(Asteroids[i].Angle2);
  Scale3D(Asteroids[i].Scale);
  SetTexture(AsterTex);
  DrawModel(Asteroid,0,true);
  DeactiveLight();
  EndObj3D;
  end;
end;
//-----------------------------------------------------------------------------------------

procedure SetShips;
begin
 Ship.X:=400;
 Ship.Y:=300;
 Ship.X_Old:=400;
 Ship.Y_Old:=300;
 Ship.Angle:=0;
 Ship.Angle2:=0;
 Ship.Velocity:=0;
 Ship.Colision:=Circle(Ship.X,Ship.Y,23);
end;

procedure DrawShip;
begin
BeginObj3D;

  Position2D(Ship.X,Ship.Y);

  RotateZ(Ship.Angle+180);
  RotateY(sin(Ship.Angle2)*15);

  Scale3D(0.2);

  SetTexture(ShipTex);

  DrawModel(ShipModel,0,false);

 EnableSphereMapping;

  SetLight(1,1,1);

  Scale3D(1.015);

  Color3D($FFFFFF,130, true);

  SetTexture(Specular);

  DrawModel(ShipModel,0,true);

 DisableSphereMapping;

 DeactiveLight();

EndObj3D;
end;

procedure ProcessControls;
begin
inc(ShootWait);

  Ship.X_Old:=Ship.X;
  Ship.Y_Old:=Ship.Y;

 if (IsKeyPressed(Key_Space)) and (ShootWait>17) then
 begin
 ShootWait:=0;
 CreateBlaster(Ship.X,Ship.Y,Ship.Angle+180);
 end;

 if IsKeyPressed(Key_Left) then Ship.Angle:=Ship.Angle-5;
 if IsKeyPressed(Key_Right) then Ship.Angle:=Ship.Angle+5;
 if Ship.Angle=360 then Ship.Angle:=0;
 if Ship.Angle=-5 then Ship.Angle:=355;

 if IsKeyPressed(Key_Up) then
 begin
 Ship.Velocity:=Ship.Velocity-0.2;
 if Ship.Velocity<-9 then Ship.Velocity:=-9;
 Ship.X:=Ship.X+Trunc( cos(degtorad(Ship.Angle + 90))*-3 );
 Ship.Y:=Ship.Y+Trunc( sin(degtorad(Ship.Angle + 90))*-3 );
 Exit;
 end;
 if IsKeyPressed(Key_Down) then
 begin
 Ship.Velocity:=Ship.Velocity+0.2;
 if Ship.Velocity>9 then Ship.Velocity:=9;
 Ship.X:=Ship.X+Trunc( cos(degtorad(Ship.Angle + 90))*3 );
 Ship.Y:=Ship.Y+Trunc( sin(degtorad(Ship.Angle + 90))*3 );
 Exit;
 end;

 if Ship.Velocity<0 then
  Ship.Velocity:=Ship.Velocity+0.1 else
  Ship.Velocity:=Ship.Velocity-0.1;

end;

procedure ProcessShips;
var i : integer;
begin
 Ship.X:=Ship.X+Trunc( cos(degtorad(Ship.Angle + 90))*Ship.Velocity );
 Ship.Y:=Ship.Y+Trunc( sin(degtorad(Ship.Angle + 90))*Ship.Velocity );

 Ship.Angle2:=Ship.Angle2+0.15;

 Ship.Colision.X:=Ship.X;
 Ship.Colision.Y:=Ship.Y;

 if Ship.X>=820 then Ship.X:=-19;
 if Ship.X<=-20 then Ship.X:=781;
 if Ship.Y>=620 then Ship.Y:=-19;
 if Ship.Y<=-20 then Ship.Y:=581;

 for i:=0 to AsteroidsCount-1 do
  if Asteroids[i].Active then
   if CinC(Ship.Colision,Asteroids[i].Colision) then
     begin
     PlaySample(BreakSound);
     Ship.X:=Ship.X_Old;
     Ship.Y:=Ship.Y_Old;
     Asteroids[i].X:=Asteroids[i].X_Old;
     Asteroids[i].Y:=Asteroids[i].Y_Old;
     Asteroids[i].Angle:=Ship.Angle;
     Asteroids[i].Velocity:=-Asteroids[i].Velocity;
     Ship.Velocity:=-(Ship.Velocity+Asteroids[i].Velocity)/2;
     end;

end;

end.
