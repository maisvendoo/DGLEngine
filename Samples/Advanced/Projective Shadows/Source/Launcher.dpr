program Launcher;

uses
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

var
    Angle : single = 0.0;
    Tree,Rocks,Ape : integer;
    ApeFrame : single =0;
    dec : boolean = false;
    TreeTex, RockTex, ShadowTexTree, ShadowTexApe : cardinal;
    LightPosition : TVertex;
    LightCamera1, LightCamera2 : TCamera;

procedure Init;
begin
Ape:=LoadModel('..\..\Medium\ModelLoading and Animating\Ape.dmd');
Tree:=LoadModel('..\..\Medium\ModelLoading and Animating\Tree.dmd');
Rocks:=LoadModel('..\..\Medium\ModelLoading and Animating\Rocks.dmd');
TreeTex:=LoadTextureFromFile('..\..\Medium\ModelLoading and Animating\Texture.bmp');
RockTex:=LoadTextureFromFile('..\..\Medium\ModelLoading and Animating\Ground.jpg');
ShadowTexTree:=CreateTextureToRenderIn(512,512);
ShadowTexApe:=CreateTextureToRenderIn(512,512);
TextureParametrs(ShadowTexTree,1);
TextureParametrs(ShadowTexApe,1);
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
 LightPosition.Y:=2+sin(Angle/8)/2;
 LightPosition.Z:=cos(Angle/8)*4;

 if IsKeyPressed(Key_Escape) then QuitEngine;

end;

procedure DrawTree(ForShadow : boolean = false);
begin
BeginObj3D;
 Position3D(0,0,-1);
 RotateX(90);
if not ForShadow then
 SetTexture(TreeTex) else
 Color3D($1F1F1F);
 DrawModel(Tree,0,true);
EndObj3D;
end;

procedure DrawApe(ForShadow : boolean = false);
begin
BeginObj3D;
 if not ForShadow then
 Color3D($003162) else
 Color3D($1F1F1F);
 Position3D(-1,-0.95,-2);
 RotateX(90);
 RotateZ(180);
 DrawModel(Ape,round(ApeFrame),true);
EndObj3D;
end;

procedure DrawRocks;
begin
BeginObj3D;
 RotateX(90);
 Scale3D(15);
 Position3D(-0.1,0.0,-0.065);
 SetTexture(RockTex);
 DrawModel(Rocks,0,true);
EndObj3D;
end;

procedure UpdateShadow;
begin
 LightCamera1.Eye:=LightPosition;
 LightCamera2.Eye:=LightPosition;
 DeactiveLight();


//Render Tree Shadow

 LightCamera1.Center.X:=0;
 LightCamera1.Center.Y:=0;
 LightCamera1.Center.Z:=-1;


StartRenderToTexture(ShadowTexTree);
 Begin2D;
 DrawRectangle2D(0,0,800,600,$808080,255,true);
 End2D;
 SetCamera(LightCamera1);
 DrawTree(TRUE);
EndRenderToTexture;

//Render Ape Shadow

 LightCamera2.Center.X:=-1;
 LightCamera2.Center.Y:=-0.95;
 LightCamera2.Center.Z:=-2;


StartRenderToTexture(ShadowTexApe);
 Begin2D;
 DrawRectangle2D(0,0,800,600,$808080,255,true);
 End2D;
 SetCamera(LightCamera2);
 DrawApe(TRUE);
EndRenderToTexture;
end;

procedure Draw;
begin

 UpdateShadow;

 Position3D(0,0,-6);
 RotateX(-10-10*sin(Angle/20));
 RotateY(-150-15*sin(Angle/20));


SetLight(LIGHT0,LightPosition.X,LightPosition.Y,LightPosition.Z,$FFFFFF,30.0,true);

SetupProjector;

PrepareSceneForProjecting;
DrawRocks;
DrawApe;
DrawTree;
EndDrawingProjectedScene;

RenderProjectedTexture(ShadowTexTree,LightCamera1,true);
DrawRocks;
DrawApe;

RenderProjectedTexture(ShadowTexApe,LightCamera2,true);
DrawRocks;
DrawTree;
 
DisableProjector;

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
