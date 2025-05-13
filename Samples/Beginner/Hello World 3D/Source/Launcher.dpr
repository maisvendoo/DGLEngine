program Launcher;

uses
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

var Font3D : integer;
    Angle : single = 0.0;
    Texture : cardinal;

procedure Init;
begin

Font3D:=CreateFont3D('Areal');

Texture:=LoadTextureFromFile('Texture.bmp');

end;

procedure Process;
begin

 Angle:=Angle+0.2;

 if IsKeyPressed(Key_Escape) then QuitEngine;

end;

procedure Draw;
begin

BeginObj3D;
 Position3D(0.0,2,-10);
 RotateY(sin(Angle)*2);
 DrawAxes;
 SetLight(1,0,0.3);
 Write3D(Font3D,'Привет Мир!');
 DeactiveLight();
EndObj3D;

BeginObj3D;
 Position3D(0,0,-5);
 RotateX(Angle*2);
 RotateY(-Angle);
 RotateZ(Angle*5);
 DrawAxes;
 SetTexture(Texture);
 DrawCube(0.5,0.5,0.5);
EndObj3D;

end;

begin

 if LoadDGLEngineDLL('..\..\..\System\DGLEngine.dll') then
 begin
  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@Init);

  SetEngineInitParametrs(800,600,32,85,false,false,false);

  StartEngine;

  FreeDGLEngineDLL;
 end;

end.
