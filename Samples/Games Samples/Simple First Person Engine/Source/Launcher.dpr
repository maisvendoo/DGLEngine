program Launcher;

uses
  Windows,
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas',
  Map in 'Map.pas',
  SystemUtils in 'SystemUtils.pas';

{$R Ico.res}

const MouseSensivity=0.15;

var
Shotgun, Font : Cardinal;
OldMouse : TPoint;
Health : integer = 100;

procedure Init;
begin
TextureMipMapping(true);
Wall1:=LoadTextureFromFile('Data\Textures\Wall1.jpg');
Wall2:=LoadTextureFromFile('Data\Textures\Wall2.jpg');
Floor:=LoadTextureFromFile('Data\Textures\Floor.jpg');
Ceil:=LoadTextureFromFile('Data\Textures\ceiling.jpg');
Shotgun:=LoadTextureFromFile('Data\Textures\Shotgun.bmp',TEXDETAIL_BEST,TRANSCOLOR_GRAY);
Barrel:=LoadTextureFromFile('Data\Textures\Barrel.bmp',TEXDETAIL_BEST,$C0C0C0);
Font:=LoadFontFromFile('Data\Font.dft');

LoadMap('Data\Maps\TestMap.txt');

SetFog($000000,25.0,70.0);
end;

procedure Process;
var Delta : integer;
wX,wY : single;
begin
 Delta:=OldMouse.X-GetMousePos.X;
 if Delta<>0 then PlayerAngleY:=PlayerAngleY+Delta*MouseSensivity;
 Delta:=0;
 
 OldMouse:=GetMousePos;

 if GetMousePos.X=GetScreenResX-1 then
 begin
 OldMouse.X:=-1;
 SetCursorPos(0,GetMousePos.Y);
 end;
 if GetMousePos.X=0 then
 begin
 OldMouse.X:=GetScreenResX;
 SetCursorPos(GetScreenResX,GetMousePos.Y);
 end;

{Система координат игрока если смотреть на карту сверху
   0__________ X
   |
   |
   |
   |Y

}


 if IsKeyPressed(Key_D) then
 begin
 wX:=0.1*sin(degtorad(PlayerAngleY + 90));
 wY:=0.1*cos(degtorad(PlayerAngleY + 90));
 if CollidePlayerWithMap(PlayerX-wX, PlayerY) then wX:=0;
 if CollidePlayerWithMap(PlayerX, PlayerY-wY) then wY:=0;
 PlayerX:=PlayerX-wX;
 PlayerY:=PlayerY-wY;
 end;

 if IsKeyPressed(Key_A) then
 begin
 wX:=0.1*sin(degtorad(PlayerAngleY + 90));
 wY:=0.1*cos(degtorad(PlayerAngleY + 90));
 if CollidePlayerWithMap(PlayerX+wX, PlayerY) then wX:=0;
 if CollidePlayerWithMap(PlayerX, PlayerY+wY) then wY:=0;
 PlayerX:=PlayerX+wX;
 PlayerY:=PlayerY+wY;
 end;

 if IsKeyPressed(Key_W) then
 begin
 wX:=0.1*cos(degtorad(PlayerAngleY + 90));
 wY:=0.1*sin(degtorad(PlayerAngleY + 90));
 if CollidePlayerWithMap(PlayerX-wX, PlayerY) then wX:=0;
 if CollidePlayerWithMap(PlayerX, PlayerY+wY) then wY:=0;
 PlayerX:=PlayerX-wX;
 PlayerY:=PlayerY+wY;
 end;

 if IsKeyPressed(Key_S) then
 begin
 wX:=0.1*cos(degtorad(PlayerAngleY + 90));
 wY:=0.1*sin(degtorad(PlayerAngleY + 90));
 if CollidePlayerWithMap(PlayerX+wX, PlayerY) then wX:=0;
 if CollidePlayerWithMap(PlayerX, PlayerY-wY) then wY:=0;
 PlayerX:=PlayerX+wX;
 PlayerY:=PlayerY-wY;
 end;

 if IsKeyPressed(Key_Escape) then QuitEngine;

end;

procedure Draw;
begin
 Scale3D(10);

 DrawMap;

Begin2D;
DrawTexture2D_Simple(Shotgun,
round((GetScreenResX - 326)+cos(PlayerX)*20),round(( GetScreenResY-192)+sin(PlayerY)*20),256,256);
DrawText2D(Font,(GetScreenResX  - GetTextWidth(Font,'+')) div 2,(GetScreenResY - GetTextHeight(Font,'+')) div 2,'+',$0000FF);
DrawCircle2D(GetScreenResX div 2,GetScreenResY div 2,15,$0000FF);
DrawText2D(Font,20,GetScreenResY - 64,'Health '+inttostr(Health),$0000FF,150);
End2D;
end;

begin
 if LoadDGLEngineDLL('..\..\..\System\DGLEngine.dll') then
 begin
  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@Init);

  ApplicationName('My DOOM');
  SetGameProcessInterval(33);

  SetCutingPlanes(0.05,70.5);
  SetViewAngle(90.0);

  SetEngineInitParametrs(800,600,32,0,true,false,false);

  StartEngine;

  FreeDGLEngineDLL('Launcher.exe');
 end;

end.
