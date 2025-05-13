program Launcher;

uses
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

var
    Angle : single = 0.0;
    Tree,Rocks,Ape : integer;
    ApeFrame : single =0;
    dec : boolean = false;
    TreeTex, RockTex, ShadowTex : cardinal;
    LightPosition : TVertex;
    LightCamera : TCamera;

procedure Init;
begin
Ape:=LoadModel('..\..\Medium\ModelLoading and Animating\Ape.dmd');
Tree:=LoadModel('..\..\Medium\ModelLoading and Animating\Tree.dmd');
Rocks:=LoadModel('..\..\Medium\ModelLoading and Animating\Rocks.dmd');
TreeTex:=LoadTextureFromFile('..\..\Medium\ModelLoading and Animating\Texture.bmp');
RockTex:=LoadTextureFromFile('..\..\Medium\ModelLoading and Animating\Ground.jpg');

ActivateMultitexturingLayer(MTEX_LAYER1);
ShadowTex:=CreateShadowMap(512);
ActivateMultitexturingLayer(MTEX_LAYER0);
end;

procedure Process;
begin

if not dec then
  ApeFrame:=ApeFrame+0.25 else
  ApeFrame:=ApeFrame-0.25;

 if Round(ApeFrame)=76 then dec:=true;
 if Round(ApeFrame)=57 then dec:=false;

 Angle:=Angle+0.2;

 LightPosition.X:=sin(Angle/8)*4;
 LightPosition.Y:=3+sin(Angle/8)/2;
 LightPosition.Z:=cos(Angle/8)*4;

 if IsKeyPressed(Key_Escape) then QuitEngine;
end;

procedure RenderScene;
begin

BeginObj3D;
 Position3D(0,0,-1);
 RotateX(90);
 SetTexture(TreeTex);
 DrawModel(Tree,0,true);
EndObj3D;

BeginObj3D;
 Color3D($003162);
 Position3D(-0.5,-0.95,-2);
 RotateX(90);
 RotateZ(180);
 DrawModel(Ape,round(ApeFrame),true);
EndObj3D;
end;


procedure UpdateShadow;
begin
ActivateMultitexturingLayer(MTEX_LAYER1);

 LightCamera.Eye:=LightPosition;

 LightCamera.Center.X:=0;
 LightCamera.Center.Y:=0;
 LightCamera.Center.Z:=0;

 StartRenderToTexture(ShadowTex);
  SetCamera(LightCamera);
  RenderScene;
 EndRenderToTexture;

ActivateMultitexturingLayer(MTEX_LAYER0);
end;

procedure Draw;
begin

 UpdateShadow;

 Position3D(0,0,-6);
 RotateX(-10-10*sin(Angle/20));
 RotateY(-150-15*sin(Angle/20));


 SetLight(LIGHT0,LightPosition.X,LightPosition.Y,LightPosition.Z,$FFFFFF,40,true);

 ActivateMultitexturingLayer(MTEX_LAYER1);
 CastShadowMap(ShadowTex,LightCamera);
 ActivateMultitexturingLayer(MTEX_LAYER0);

 BeginObj3D;
  RotateX(90);
  Scale3D(15);
  Position3D(-0.1,0.0,-0.065);
  SetTexture(RockTex);
  DrawModel(Rocks,0,true);
 EndObj3D;

 RenderScene;
 ActivateMultitexturingLayer(MTEX_LAYER1);
 DisableProjector;
 ActivateMultitexturingLayer(MTEX_LAYER0);

DeactiveLight();
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
