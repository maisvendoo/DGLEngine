program Launcher;

uses
  SysUtils, Math, Windows, OpenGL,
  DGLEngine_header in '..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

const
SHADOW_ALPHA = 0.40;

var Font, Scene : cardinal;
Pos : Tvertex;
CamA_X,CamA_Y : single;
OldMouse : TPoint;
back,down,front,left,right,up : array [0..1] of cardinal;
TexGrass : cardinal;
Teapot : cardinal;

LightMovment : single = 200;
LightCamera : TCamera;

function vertex (x,y,z : single) : Tvertex; inline;
begin
  result.X:=x;
  result.Y:=y;
  result.Z:=z;
end;

procedure DrawBackground;
begin
  BeginObj3D;
  SetTexture(TexGrass);
  Position3D(-1250,0,0);
  DrawPlane(5000,1500);
 EndObj3D;
end;

procedure DrawSphereMappedObj(shadow : boolean);
begin
 BeginObj3D;
 if not shadow then Color3D($FFFFFF);//Нельзя использовать Color3D при рендеринге теней
 Position3D(-250,0,35);
 RotateX(LightMovment*20);
 RotateY(LightMovment*50);
 Scale3D(20);
 SetTexture(up[1]);
 EnableSphereMapping;
 DrawModel(Teapot);
 DisableSphereMapping;
 EndObj3D;
end;

procedure RenderShadows(PlanePos, PlaneSize : TVertex);
  procedure generateShadowMatrix(var ShadowMatrix : Array of glFloat; const normal, point : TVertex; lightX, lightY, lightZ, lightW : glFloat);
  var d, dot : Real;
  begin
    d := -normal.X*point.X - normal.Y*point.Y - normal.Z*point.Z;
    dot :=normal.X*lightX  + normal.Y*lightY + normal.Z*lightZ + d*lightW;

    ShadowMatrix[0]  := -lightX*normal.X + dot;
    ShadowMatrix[4]  := -lightX*normal.Y;
    ShadowMatrix[8]  := -lightX*normal.Z;
    ShadowMatrix[12] := -lightX*d;
    ShadowMatrix[1]  := -lightY*normal.X;
    ShadowMatrix[5]  := -lightY*normal.Y + dot;
    ShadowMatrix[9]  := -lightY*normal.Z;
    ShadowMatrix[13] := -lightY*d;
    ShadowMatrix[2]  := -lightZ*normal.X;
    ShadowMatrix[6]  := -lightZ*normal.Y;
    ShadowMatrix[10] := -lightZ*normal.Z + dot;
    ShadowMatrix[14] := -lightZ*d;
    ShadowMatrix[3]  := -lightW*normal.X;
    ShadowMatrix[7]  := -lightW*normal.Y;
    ShadowMatrix[11] := -lightW*normal.Z;
    ShadowMatrix[15] := -lightW*d + dot;
  end;
var
ShadowMatrix  : Array[0..15] of glFloat;
RoomNormal, RoomPoints : TVertex;
begin

  glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
  glDepthMask(GL_FALSE);

  glClear(GL_STENCIL_BUFFER_BIT);
  glEnable(GL_STENCIL_TEST);

  glStencilFunc(GL_ALWAYS, 1, 1);

  glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);

  glPushMatrix();
    Position3D(PlanePos.X,PlanePos.Y,PlanePos.Z);
    DrawPlane(PlaneSize.X,PlaneSize.Y);
  glPopMatrix();

 glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
 glDepthMask(GL_TRUE);

 glStencilFunc(GL_EQUAL, 1, 1);

 glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);

 //Рисуем плоскость на которой будут тени
 //Тут смело можно рисовать сколько угодно плоскостей (с отключенным ZBuffer'ом) или использовать мультитекстурирование

 DrawBackground;

			glPushMatrix();

				glColor4f(0.0, 0.0, 0.0, 0.5);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
				glDisable(GL_TEXTURE_2D);
				glDisable(GL_LIGHTING);
				glDisable(GL_DEPTH_TEST);
				glEnable(GL_BLEND);
				glStencilOp(GL_KEEP, GL_KEEP, GL_INCR);


	    roomNormal.X := 0.0; roomNormal.Y := 0.0; roomNormal.Z := 1.0;
      roomPoints.X := PlanePos.X; roomPoints.Y := PlanePos.Y; roomPoints.Z := PlanePos.Z;

      generateShadowMatrix( ShadowMatrix, roomNormal, roomPoints, LightCamera.Eye.X, LightCamera.Eye.Y, LightCamera.Eye.Z, 1.0);
      glMultMatrixf(@ShadowMatrix);

        SceneUseMaterial(false);
        DrawScene(Scene);
        DrawSphereMappedObj(true);

				glEnable(GL_TEXTURE_2D);
				glEnable(GL_DEPTH_TEST);
				glDisable(GL_BLEND);
				glEnable(GL_LIGHTING);
			glPopMatrix();

 glDisable(GL_STENCIL_TEST);

end;

procedure EngineInit;
var p : TPoint;
i : integer;
m : TSceneMesh;
begin
 Pos:=vertex(-500,0,20);
 CamA_X:=0; CamA_Y:=0;

 LightCamera.Eye:=vertex(2800,-2200,2200);
 LightCamera.Center:=vertex(-1200,0,0);

 SetCursorPos(GetScreenResX div 2,GetScreenResY div 2);
 Getcursorpos(p);
 OldMouse:=p;

 Font:=LoadFontFromFile('..\..\Samples\Medium\Frustum Culling\TimeNewRoman_12.dft');

 TexGrass:=LoadTextureFromFile('Data\grass.jpg');

 Teapot:=LoadModel('..\Scenes_Simple\Data\meshs\Teapot01.dmd');

 back[0]:=LoadModel('Data\skybox\back.dmd',MDL_NO_SCALE);
 back[1]:=LoadTextureFromFile('Data\skybox\back.jpg');
 TextureParametrs(back[1],TEXTURE_CLAMP);

 front[0]:=LoadModel('Data\skybox\front.dmd',MDL_NO_SCALE);
 front[1]:=LoadTextureFromFile('Data\skybox\front.jpg');
 TextureParametrs(front[1],TEXTURE_CLAMP);

 down[0]:=LoadModel('Data\skybox\down.dmd',MDL_NO_SCALE);
 down[1]:=LoadTextureFromFile('Data\skybox\down.jpg');
 TextureParametrs(down[1],TEXTURE_CLAMP);

 up[0]:=LoadModel('Data\skybox\up.dmd',MDL_NO_SCALE);
 up[1]:=LoadTextureFromFile('Data\skybox\up.jpg');
 TextureParametrs(up[1],TEXTURE_CLAMP);

 right[0]:=LoadModel('Data\skybox\right.dmd',MDL_NO_SCALE);
 right[1]:=LoadTextureFromFile('Data\skybox\right.jpg');
 TextureParametrs(right[1],TEXTURE_CLAMP);

 left[0]:=LoadModel('Data\skybox\left.dmd',MDL_NO_SCALE);
 left[1]:=LoadTextureFromFile('Data\skybox\left.jpg');
 TextureParametrs(left[1],TEXTURE_CLAMP);

 TextureMipMapping(true);
 Scene:=LoadScene('Data\zavod.dsc','Data\meshs','Data\maps');
 TextureMipMapping(false);

 //Этот цикл устанавливает всем материалам сцены цвет в белый
 for i := 0 to SceneObjCount(Scene) - 1 do
 begin
   m:=SceneGetObj(Scene,i);
   m.Material.diffuse[0]:=255;
   m.Material.diffuse[1]:=255;
   m.Material.diffuse[2]:=255;
   m.MeshSmooth:=false; //отключаем сглаживание мешей дабы освещение не бажило
   SceneSetObj(Scene,i,m);
 end;

end;

procedure Draw;
begin

 Color3D($FFFFFF);

 BeginObj3D;//Skybox )
 Scale3D(0.25);
 RotateX(CamA_X+90);
 RotateZ(CamA_Y);
 SetTexture(back[1]);
 DrawModel(back[0]);
 SetTexture(front[1]);
 DrawModel(front[0]);
 SetTexture(down[1]);
 DrawModel(down[0]);
 SetTexture(up[1]);
 DrawModel(up[0]);
 SetTexture(right[1]);
 DrawModel(right[0]);
 SetTexture(left[1]);
 DrawModel(left[0]);
 EndObj3D;

 ClearZBuffer;

 RotateX(CamA_X+90);
 RotateZ(CamA_Y);
 Position3D(-Pos.X,-Pos.Y,-Pos.Z);


 SetLight(LIGHT0,LightCamera.Eye.X,LightCamera.Eye.Y,LightCamera.Eye.Z,$FFFFFF,INFINITY,true,20);
 SetLight(LIGHT1,pos.X,pos.Y,pos.Z,$FFFFFF,1000);

 RenderShadows(vertex(-1250,0,0),vertex(5000,1500,0));

 //После расчета фрустума уже нельзя вызывать глобальные трансформации мира
 CalculateFrustum;

 SceneUseMaterial(true);
 CullFace(CULL_BACK);
 DrawScene(Scene);
 DrawSphereMappedObj(false);
 CullFace(CULL_NONE);

 DeactiveLight();

Begin2D;
 DrawText2D(Font,20,20,'FPS: '+IntToStr(GetFPS),$00FF00,180,4);
End2D;
end;

procedure Process;
var
v, old : Tvertex;
begin

 LightMovment:=LightMovment+0.005;
 LightCamera.Eye:=vertex(cos(LightMovment*1.5)*1000-1800,sin(LightMovment)*1000-1200,-tan(LightMovment/20)*200+2200);

 //Задаем размеры игрока что бы расчитать столкновения со сценой
 v:=vertex(5,5,10);

 if IsKeyPressed(Key_D) or IsKeyPressed(Key_Left) then
 begin
 old:=pos;

 pos.X:=pos.X+2*sin(degtorad(CamA_Y + 90));
 if CollideBoxWithScene(Scene,pos,v) then Pos.X:=old.X;
 
 pos.Y:=pos.Y-2*cos(degtorad(CamA_Y + 90));
 if CollideBoxWithScene(Scene,pos,v) then Pos.Y:=old.Y;

 end;

 if IsKeyPressed(Key_A) or IsKeyPressed(Key_Right) then
 begin
 old:=pos;

 pos.X:=pos.X-2*sin(degtorad(CamA_Y + 90));
 if CollideBoxWithScene(Scene,pos,v) then Pos.X:=old.X;

 pos.Y:=pos.Y+2*cos(degtorad(CamA_Y + 90));
 if CollideBoxWithScene(Scene,pos,v) then Pos.Y:=old.Y;
 
 end;

 if IsKeyPressed(Key_S) or IsKeyPressed(Key_Up) then
 begin
 old:=pos;

 pos.X:=pos.X-2*cos(degtorad(CamA_Y + 90));
 if CollideBoxWithScene(Scene,pos,v) then Pos.X:=old.X;
 
 pos.Y:=pos.Y-2*sin(degtorad(CamA_Y + 90));
 if CollideBoxWithScene(Scene,pos,v) then Pos.Y:=old.Y;
 
 end;

 if IsKeyPressed(Key_W) or IsKeyPressed(Key_Down) then
 begin
 old:=pos;

 pos.X:=pos.X+2*cos(degtorad(CamA_Y + 90));
 if CollideBoxWithScene(Scene,pos,v) then Pos.X:=old.X;
 
 pos.Y:=pos.Y+2*sin(degtorad(CamA_Y + 90));
 if CollideBoxWithScene(Scene,pos,v) then Pos.Y:=old.Y;
 
 end;

 CamA_Y:=CamA_Y-(GetMousePos.X-OldMouse.X)/2;
 CamA_X:=CamA_X-(GetMousePos.Y-OldMouse.Y)/2;

 OldMouse:=GetMousePos;

 if GetMousePos.X=GetScreenResX-1 then
 begin
 OldMouse.X:=-1;
 SetCursorPos(0,GetMousePos.Y);
 end;
 if GetMousePos.X=0 then
 begin
 OldMouse.X:=GetScreenResX;
 SetCursorPos(GetScreenResX,GetMousePos.Y);
 end;

 if GetMousePos.Y=GetScreenResY-1 then
 begin
 OldMouse.Y:=-1;
 SetCursorPos(GetMousePos.X,0);
 end;
 if GetMousePos.Y=0 then
 begin
 OldMouse.Y:=GetScreenResY;
 SetCursorPos(GetMousePos.X,GetScreenResY);
 end;

 if IsKeyPressed(Key_Escape) then
 QuitEngine;

end;


begin
 if LoadDGLEngineDLL('..\..\System\DGLEngine.dll') then
 begin
  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@EngineInit);

  SetEngineInitParametrs(1024,768,32,0,true,false,false);
  SetCutingPlanes(1.0,8000.0);
  EnableStencilBuffer;
  StartEngine;

  FreeDGLEngineDLL;
 end;

end.
