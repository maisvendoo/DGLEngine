program Launcher;

uses
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

var Angle : single = 0.0;
    Texture,TextureToRender : cardinal;

procedure Init;
begin
Texture:=LoadTextureFromFile('..\Hello World 3D\Texture.bmp');
TextureToRender:=CreateTextureToRenderIn(256,256);
end;

procedure Process;
begin

 Angle:=Angle+0.2;

 if IsKeyPressed(Key_Escape) then QuitEngine;

end;

procedure Draw;
begin

StartRenderToTexture(TextureToRender);

 Begin2D;
 DrawRectangle2D(0,0,800,600,$FF0000,255,true);
 End2d;

 BeginObj3D;
  Position3D(0,0,-2.5);
  RotateX(Angle*3);
  RotateY(-Angle*2);
  RotateZ(Angle*8);
  SetTexture(Texture);
  DrawCube(0.5,0.5,0.5);
 EndObj3D;

EndRenderToTexture;

BeginObj3D;
 Position3D(0,0,-5);
 RotateX(-Angle*2);
 RotateY(Angle);
 SetTexture(TextureToRender);
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
