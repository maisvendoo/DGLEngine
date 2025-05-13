program Launcher;

uses
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas',
  Water in 'Water.pas';

{$R Ico.res}
  var Tex,CaveTex : cardinal;
      Cave : integer;
      UP : single = 0.0;

procedure Init;
begin
Tex:=LoadTextureFromFile('Tex.bmp');
CaveTex:=LoadTextureFromFile('..\..\Medium\ModelLoading and Animating\Ground.jpg');
Cave:=LoadModel('..\..\Medium\ModelLoading and Animating\Rocks.dmd');
initWater;
SetFog($080808,0.5,1.5);
end;

procedure Process;
begin
 UP:=UP+0.1;
 ProcessWater;
 if random(40)=10 then CreateRainDrop;
 if IsKeyPressed(Key_Escape) then QuitEngine;
end;

procedure Draw;
begin
 BeginObj3D;
 Position3D(0,-0.2,-0.62);
 RotateX(45);
 SetTexture(CaveTex);
 Scale3D(1.4);
 DrawModel(cave,0,true);
 EndObj3D;

 BeginObj3D;
 EnableSphereMapping;
 SetLight();
 Color3D($FFFFFF,250,true);
 Position3D(0,sin(UP*0.05)*0.025,-0.75);
 RotateX(90+45);
 SetTexture(Tex);
 Scale3D(0.22);
 DrawWater;
 DeactiveLight();
 DisableSphereMapping;
 EndObj3D;
end;

begin

 if LoadDGLEngineDLL('..\..\..\System\DGLEngine.dll') then
 begin
  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@Init);

  SetCutingPlanes(0.05,250.0);

  SetEngineInitParametrs(800,600,32,85,false,false,false);

  StartEngine;

  FreeDGLEngineDLL;
 end;
 
end.
