program Launcher;

uses
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

var Angle : single = 0.0;
    Texture1, Texture2 : cardinal;

procedure Init;
begin

Texture1:=LoadTextureFromFile('Tree.jpg');
Texture2:=LoadTextureFromFile('Fog.jpg');

end;

procedure Process;
begin

 Angle:=Angle+0.2;

 if IsKeyPressed(Key_Escape) then QuitEngine;

end;

procedure Draw;
begin

 BeginObj3D;

 Position3D(0,0,-2);
 RotateY(sin(Angle/3)*25);

 ActivateMultitexturingLayer(MTEX_LAYER0);
 SetTexture(Texture1);

 ActivateMultitexturingLayer(MTEX_LAYER1);
 SetMultytexturingLayerOffset(MTEX_LAYER1,-Angle/10,0);
 SetTexture(Texture2);

 ActivateMultitexturingLayer(MTEX_LAYER2);
 SetMultytexturingLayerOffset(MTEX_LAYER2,sin(Angle/4),cos(Angle/6));
 SetTexture(Texture2);

 DrawPlane(2.25,1.7);

 DeactiveMultytexturing;

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
