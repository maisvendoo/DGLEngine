program Launcher;

uses
  Windows,
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

const BLUR_PLUGIN='DGLE_Plugin.dll';

var Tex : Cardinal;
    Angle : single = 0.0;

ChangeTexRes : procedure (Size : cardinal); stdcall;

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
var
Name : string;
begin

Name:=LoadPlugin(BLUR_PLUGIN,DGLEngineDLL_Handle);
@ChangeTexRes:=GetProcAddress(GetPluginHandle(Name),'ChangeTexRes');

Tex:=LoadTextureFromFile('..\..\Beginner\Hello World 3D\Texture.bmp');
end;

procedure Process;
begin
 Angle:=Angle+1.5;
 if IsKeyPressed(Key_Escape) then QuitEngine;

 if IsKeyPressed(Key_F1) then ChangeTexRes(128);
 if IsKeyPressed(Key_F2) then ChangeTexRes(256);
 if IsKeyPressed(Key_F3) then ChangeTexRes(512);

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
