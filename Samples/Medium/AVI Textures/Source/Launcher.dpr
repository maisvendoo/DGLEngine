program Launcher;

uses
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

var AVI_ident : integer;
    AngleX, AngleY : single;

procedure EngineInit;
begin
AVI_ident:=CreateAVITexture('Video.avi');
AngleX:=0; AngleY:=0;
end;

procedure Draw;
begin
 BeginObj3D;

  SetAviTexture(AVI_ident);

  Position3D(0,0,-1);
  RotateX(180);

  DrawPlane(1.15,1);

  RotateX(-180);

  ClearZBuffer;

  Position3D(0,0,-6);

  RotateX(AngleX);
  RotateY(AngleY);

  DrawCube(1,1,1);

 EndObj3D;

end;

procedure Process;
begin
AngleY:=AngleY+0.5;
AngleX:=AngleX+0.2;

 if IsKeyPressed(Key_Escape) then
 begin
 FreeAVITexture(AVI_ident);
 QuitEngine;
 end;

end;


begin

 if LoadDGLEngineDLL('..\..\..\System\DGLEngine.dll') then
 begin
  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@EngineInit);

  SetEngineInitParametrs(800,600,32,85,false,false,false);

  StartEngine;

  FreeDGLEngineDLL;
 end;

end.
