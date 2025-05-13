program Launcher;

uses
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

var Angle : single = 0.0;
    Tex, ProjectTex : cardinal;
    ProjectorOrientation : Tcamera;

procedure Init;
begin

ProjectTex:=LoadTextureFromFile('projector.jpg');
TextureParametrs(ProjectTex,TEXTURE_CLAMP);

Tex:=LoadTextureFromFile('Wall.jpg');

ProjectorOrientation.Eye.X:=0;
ProjectorOrientation.Eye.Y:=0;
ProjectorOrientation.Eye.Z:=20;

ProjectorOrientation.Center.Z:=0;

end;

procedure Process;
begin

 Angle:=Angle+0.2;

 ProjectorOrientation.Center.X:=cos(Angle/4)*3;
 ProjectorOrientation.Center.Y:=sin(Angle/4)*3;

 if IsKeyPressed(Key_Escape) then QuitEngine;

end;

procedure DrawScene;
begin
 BeginObj3D;
 SetTexture(Tex);
 Position3D(0,-10,0);
 RotateX(90);
 DrawPlane(20,20);
 EndObj3D;

 BeginObj3D;
 SetTexture(Tex);
 Position3D(0,10,0);
 RotateX(90);
 DrawPlane(20,20);
 EndObj3D;

 BeginObj3D;
 SetTexture(Tex);
 Position3D(0,0,-10);
 DrawPlane(20,20);
 EndObj3D;

 BeginObj3D;
 SetTexture(Tex);
 Position3D(-10,0,0);
 RotateY(90);
 DrawPlane(20,20);
 EndObj3D;

 BeginObj3D;
 SetTexture(Tex);
 Position3D(10,0,0);
 RotateY(90);
 DrawPlane(20,20);
 EndObj3D;


 BeginObj3D;
 SetTexture(Tex);
 Position3D(5, 1, -2);
 RotateX(Angle);
 RotateY(-Angle);
 drawcube(2,2,2);
 EndObj3D;

 BeginObj3D;
 SetTexture(0);
 Color3D($FF0080);
 Position3D(-1, -3, 5);
 DrawSphere(3);
 EndObj3D;

end;

procedure Draw;
begin

 Position3D(0,0,-28);

 SetupProjector;

 RenderProjection(ProjectTex,@DrawScene,ProjectorOrientation);

 DisableProjector;

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
