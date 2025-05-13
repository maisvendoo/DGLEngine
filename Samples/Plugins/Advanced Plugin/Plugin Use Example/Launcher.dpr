program Launcher;

uses
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

const BLUR_PLUGIN='DGLE_Blur.dll';

procedure blur_RegisterDrawProcedure(BlurObjDraw, BackDraw : pointer); stdcall; external BLUR_PLUGIN;
procedure blur_Activate(Enable : boolean); stdcall; external BLUR_PLUGIN;
procedure blur_Textures(Count : cardinal); stdcall; external BLUR_PLUGIN;

var Tex : Cardinal;
    Angle : single = 0.0;

procedure Draw;
begin
BeginObj3D;

 Position3D(0,0,-10);
 RotateX(Angle);
 RotateY(Angle*2);
 RotateZ(Angle/2);

 SetTexture(Tex);
 Position3D(-1.5,0,0);
 DrawCube(1,1,1);
 Position3D(3,0,0);
 DrawCube(1,1,1);

EndObj3D;
end;

procedure Init;
begin
LoadPlugin(BLUR_PLUGIN,DGLEngineDLL_Handle);
blur_RegisterDrawProcedure(@Draw,nil);

Tex:=LoadTextureFromFile('..\..\Beginner\Hello World 3D\Texture.bmp');
end;

procedure Process;
begin
 Angle:=Angle+1.5;
 if IsKeyPressed(Key_Escape) then QuitEngine;
 if IsKeyPressed(Key_D) then blur_Activate(FALSE);
 if IsKeyPressed(Key_E) then blur_Activate(TRUE);
end;


begin

 if LoadDGLEngineDLL('..\..\..\System\DGLEngine.dll') then
 begin
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@Init);

  SetEngineInitParametrs(800,600,32,85,false,false,false);

  StartEngine;

  FreeDGLEngineDLL;
 end;

end.
