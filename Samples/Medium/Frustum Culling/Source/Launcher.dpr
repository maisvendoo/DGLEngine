program Launcher;

uses
  SysUtils,
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

const
OVERALL_COUNT = 625;

var
    Angle : single = 0.0;
    Ape : integer;
    ApeFrame : single =0;
    dec : boolean = false;
    Font : Cardinal;
    DrawCount : integer;
    frustum : boolean = true;
    KeyWait : integer = 20;

procedure Init;
begin
Ape:=LoadModel('..\ModelLoading and Animating\Ape.dmd');
Font:=LoadFontFromFile('TimeNewRoman_12.dft');
end;

procedure Process;
begin

if not dec then
  ApeFrame:=ApeFrame+0.25 else
  ApeFrame:=ApeFrame-0.25;

 if Round(ApeFrame)=76 then dec:=true;
 if Round(ApeFrame)=57 then dec:=false;

 Angle:=Angle+0.2;

 if IsKeyPressed(Key_Escape) then QuitEngine;

 if (KeyWait>40) and IsKeyPressed(Key_D) then
 begin
 KeyWait:=0;
 frustum:=not frustum;
 end;

 KeyWait:=KeyWait+1;
end;


procedure DrawApe(X,Y : single);
begin
if not frustum or
(frustum and IsBoxInFrustum(X,-0.95,Y,ModelBoundingBox(Ape,round(ApeFrame)).X,
ModelBoundingBox(Ape,round(ApeFrame)).Z,ModelBoundingBox(Ape,round(ApeFrame)).Y))
 then
begin
inc(DrawCount);
BeginObj3D;
 Color3D($003162);
 Position3D(X,-0.95,Y);
 RotateX(90);
 DrawModel(Ape,round(ApeFrame),true);
EndObj3D;
end;
end;


procedure Draw;
var i, j, d : integer;
begin
SetLight(LIGHT0,sin(angle/10)*5,0.5,cos(angle/10)*5,$FFFFFF,20,true);

RotateY(Angle);
Position3D(-0.4,0,-0.4);

if frustum then
CalculateFrustum;

d:=round(sqrt(OVERALL_COUNT));

DrawCount:=0;

for i:=1 to d do
 for j:=1 to d do
  DrawApe(i - 1 -d div 2,j - 1 - d div 2);

DeactiveLight();

Begin2D;
DrawText2D(Font,0,0,'Draw models: '+inttostr(DrawCount)+'/'+inttostr(OVERALL_COUNT));
DrawText2D(Font,0,15,'Plygons count: '+inttostr(DrawCount*ModelTrianglesCount(Ape,round(ApeFrame))));
DrawText2D(Font,0,30,'Press "D" to disable/enable frustum culling.');
if frustum then DrawText2D(Font,0,45,'Frustum culling is enabled') else DrawText2D(Font,0,45,'Frustum culling is disabled');
DrawText2D(Font,0,60,'FPS: '+inttostr(GetFPS));
End2D;
end;

begin

 if LoadDGLEngineDLL('..\..\..\System\DGLEngine.dll') then
 begin
  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@Init);

  SetEngineInitParametrs(800,600,32,0,true,false,false);

  SetCutingPlanes(0.2,500);

  StartEngine;

  FreeDGLEngineDLL;
 end;

end.
