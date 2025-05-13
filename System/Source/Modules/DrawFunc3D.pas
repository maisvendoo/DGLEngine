//----------------------------------------------------------------------------//
//DRON's OpenGl Engine V 1.0 http://dronprogs.mirgames.ru                     //
//                                                                            //
// GLDrawFunc3D.pas V 1.1, 13.04.2008                                         //
//                                                                            //
// This module provides all basic 3D graphics routines.                       //
//                                                                            //
// Copyright (C) 2005-2006 Korotkov Andrew aka DRON                           //
//                                                                            //
//This program is free software; you can redistribute it and/or               //
//modify it under the terms of the GNU General Public License                 //
//as published by the Free Software Foundation; either version 2              //
//of the License, or any later version.                                       //
//                                                                            //
//This program is distributed in the hope that it will be useful,             //
//but WITHOUT ANY WARRANTY; without even the implied warranty of              //
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               //
//GNU General Public License (http://www.gnu.org/copyleft/gpl.html)           //
//for more details.                                                           //
//----------------------------------------------------------------------------//
unit DrawFunc3D;
interface
uses OpenGL, Variables, Windows,TFrustumClass, EngineUtils, SysUtils, DMD_MultyMesh,
     Textures, DPC_Packages;

type TVertex3D = record X,Y,Z : single; Color, Alpha : integer; TexX, TexY : single; end;

     TCamera = record
          Eye    : TVertex;
          Center : TVertex;
          end;

     TObj3DInfo = record
          Texture : cardinal;
          Color : Array [1..4] of GLFloat;
          Projecting : boolean;
          end;

      TSceneMesh = record
          Active      : boolean;
          Name        : string[128];
          Pos         : Tvertex;
          Scale       : single;
          Material    : TMaterial;
          Texture     : cardinal;
          DoBump      : boolean;
          BumpTexture : cardinal;
          SpecTexture : cardinal;
          MeshFrame   : cardinal;
          MeshSmooth  : boolean;
          Mesh        : cardinal;
          end;

      TMeshGeometry = record
          VerticesCount, FacesCount : cardinal;
          Vertices, Normals : array of TVertex;
          Tangents : array of TTangent;
          Faces : array of array[0..2] of cardinal;
          TextureVertices : array of TVertex;
          TextureFaces : array of array[0..2] of cardinal;
          end;
      PMeshGeometry = ^TMeshGeometry;

procedure BeginObj3D; stdcall;
procedure EndObj3D; stdcall;
procedure Position3D(X,Y,Z : single); stdcall;
procedure Position2D(X,Y : integer); stdcall;
procedure SetTexture(Texture : gluint); stdcall;
procedure Color3D(Color:integer; Alpha : byte; Diffuse : boolean; MaterialShininess : single); stdcall;
procedure AdductingMatrix3Dto2D; stdcall;
procedure ReturnStandartMatrix3D; stdcall;
procedure DrawAxes(Length : single = 1.0); stdcall;
procedure RotateX(Angle : single); stdcall;
procedure RotateY(Angle : single); stdcall;
procedure RotateZ(Angle : single); stdcall;
procedure Scale3D(Scale : single); stdcall;
procedure DrawPlane(Width,Height : single); stdcall;
procedure DrawSphere(Radius : single); stdcall;
procedure DrawLine(X,Y,Z,X1,Y1,Z1 : single; LineWidth : real = 1.0; Smooth : boolean = true); stdcall;
procedure DrawPoint(X,Y,Z : single); stdcall;
function  LoadModel(Filename : string; ScaleType : byte; NormalInv : boolean) : integer; stdcall;
procedure FreeModel(ModelIdent : integer); stdcall;
procedure DrawModel(ModelIdent, Frame : integer; Smooth : boolean); stdcall;
procedure GetModelGeometry(ModelIdent, Frame : integer; GeometryData : PMeshGeometry); stdcall;
procedure EnableSphereMapping; stdcall;
procedure DisableSphereMapping; stdcall;
procedure SetLight(ID : integer; X,Y,Z : single; LightColor : integer; Radius : single; Visualize : boolean; Scale : single); stdcall;
procedure DrawEllipse(Width,Height,Depth : single); stdcall;
function  CreateTextureToRenderIn(TextureWidth,TextureHeight : integer):GlUint; stdcall;
procedure StartRenderToTexture(Texture : GlUint); stdcall;
procedure EndRenderToTexture; stdcall;
procedure DrawSprite(Width,Height : single; FramesXCount, FramesYCount, FrameNumber: integer);stdcall;
procedure DrawCylinder(Radius,Height : single); stdcall;
procedure DrawPolygon3D(points : array of TVertex3D); stdcall;
function  ModelFramesCount(Modelident : integer):Integer; stdcall;
procedure DeactiveLight(ID : integer); stdcall;
function  ModelBoundingBox(Modelident,Frame : integer):TVertex; stdcall;
function  ModelTrianglesCount(Modelident,Frame : integer) : Cardinal; stdcall;
procedure DrawSprite_BillBoard(Width,Height : single; FramesXCount, FramesYCount, FrameNumber: integer);stdcall;
procedure ActivateMultitexturingLayer(Layer : Cardinal); stdcall;
procedure DeactiveMultytexturing; stdcall;
procedure SetMultytexturingLayerOffset(Layer : cardinal; X,Y : single); stdcall;
procedure ClearZBuffer; stdcall;
procedure DrawCube(Width,Height,Depth : single); stdcall;
procedure SetFog(Color : Integer; Fog_Start, Fog_End : single); stdcall;
procedure DeactiveFog; stdcall;
procedure SetCamera(Camera : TCamera); stdcall;
procedure CalculateFrustum; stdcall;
function  IsPointInFrustum(X,Y,Z : single) : boolean; stdcall;
function  IsSphereInFrustum(X,Y,Z,Radius : single) : boolean; stdcall;
function  IsBoxInFrustum(X,Y,Z,W,H,D : single) : boolean; stdcall;
procedure ZBuffer(Active : boolean); stdcall;
procedure ResetMatrix; stdcall;
procedure DrawTextureToTexture(TexSource,TexTarget : GluInt; X,Y : integer); stdcall;
procedure SetMultytexturingLayerTexCoordMulti(Layer : cardinal; X,Y : single); stdcall;
procedure DrawTextureToTextureTransparentColor(TexSource,TexTarget : GluInt; X,Y : integer; Color : Cardinal); stdcall;
function  ModelMaterial(Modelident : integer) : TMaterial; stdcall;
procedure CullFace(Mode : cardinal); stdcall;
procedure ModelsBump(Active : boolean); stdcall;
procedure RenderTexToTexFBO(ToTexture,TexSource,TexTarget : GluInt; X,Y : integer); stdcall;

function  LoadScene(FileName, MeshPath, TexPath : string):cardinal; stdcall;
procedure FreeScene(Ident : cardinal); stdcall;
procedure DrawScene(Ident : cardinal); stdcall;
function  SceneBoundingBox(Ident : cardinal):TVertex; stdcall;
function  CollideBoxWithScene(Ident : cardinal; BoxPos, BoxSize : Tvertex):boolean; stdcall;
function  SceneGetLastCollideObjectIndex:integer; stdcall;
function  SceneObjCount( Ident : cardinal ) : cardinal; stdcall;
function  GetSceneObjectIdent( SceneIdent : cardinal; ObjName : string ) : integer; stdcall;
procedure SceneSetObjActive( SceneIdent, ObjIdent : cardinal; Active : boolean ); stdcall;
procedure SceneSetObj( SceneIdent, ObjIdent : cardinal; SceneMesh : TSceneMesh ); stdcall;
function  SceneGetObj( SceneIdent, ObjIdent : cardinal ) : TSceneMesh; stdcall;

procedure FreeEng;
procedure InitEng;

function  GETLIGHT(ID: integer) : integer;
procedure _glTexCoord2f(X,Y : GLFloat; Layer : integer = -1); stdcall;
procedure _glTexCoord3f(X,Y,Z : GLFloat; Layer : integer = -1);

var
LightsOn : array [0..20] of boolean;
QuadraticObject : PGLUQuadricObj;
SphereDL : glUint;
RenderTTWidth,RenderTTHeight : integer;
In2DWeAre : boolean = false;
CurTexture : cardinal = 0;

LastCollide : integer = -1;

Obj3DInfo : array of TObj3DInfo;
InBlock : boolean = false;

CantRenderInFBO : boolean;
fbo_frame : cardinal = 0;
fbo_depth : cardinal = 0;
fbo_w, fbo_h, fbo_z : cardinal;
fbo2 : cardinal;

implementation
uses Advanced3D, DrawFunc2D;

type TAMesh = record
Ident : cardinal;
Mesh : TGLMultyMesh;
end;

TScene = record
 uid : cardinal;
 Models : array of TSceneMesh;
end;

var
 RenderedTex : GlUint;
 MultyCoordOffset : array [1..5] of array [0..3] of GLfloat;

 Meshs : array of TAMesh;
 MeshsCount : cardinal = 0;
 OverAllMeshUsed :cardinal = 0;

 Scenes : array of TScene;
 ScenesCount : cardinal = 0;
 ScenesOverall : cardinal = 0;

 mat_shininess : GLfloat = 0.0;

 light_ambient : array [0..3] of GLfloat = ( 0.0, 0.0, 0.0, 1.0 );
 light_diffuse : array [0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );
 light_specular : array [0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );
 mat_specular : array [0..3] of GLfloat = ( 0.0, 0.0, 0.0, 1.0 );

{System------------------------------------------------------------------------}
function vertex(x,y,z : single) : TVertex; inline;
begin
result.X:=x;
result.Y:=y;
result.Z:=z;
end;
{------------------------------------------------------------------}
function GETLIGHT(ID: integer) : integer;
begin
 result:=GL_LIGHT0+ID;
end;
{------------------------------------------------------------------}
procedure _glTexCoord2f(X,Y : GLFloat; Layer : integer = -1); stdcall;
var i : cardinal;
begin

 if MultyTexActive then
 begin
  if Layer=-1 then
  begin
   glMultiTexCoord2fARB(GL_TEXTURE0_ARB,X,Y);
  for i:=1 to 5 do
   glMultiTexCoord2fARB(GL_TEXTURE0_ARB+i, (X+MultyCoordOffset[i][0])*MultyCoordOffset[i][2],
    (Y+MultyCoordOffset[i][1])*MultyCoordOffset[i][3]);
  end else glMultiTexCoord2fARB(GL_TEXTURE0_ARB+Layer,X,Y);
 end else glTexCoord2f(x,y);

end;
{------------------------------------------------------------------}
procedure _glTexCoord3f(X,Y,Z : GLFloat; Layer : integer = -1);
var i : cardinal;
begin

 if MultyTexActive then
 begin
  if Layer=-1 then
  begin
   glMultiTexCoord3fARB(GL_TEXTURE0_ARB,X,Y,Z);
  for i:=1 to 5 do
   glMultiTexCoord3fARB(GL_TEXTURE0_ARB+i, (X+MultyCoordOffset[i][0])*MultyCoordOffset[i][2],
    (Y+MultyCoordOffset[i][1])*MultyCoordOffset[i][3],0);
  end else glMultiTexCoord3fARB(GL_TEXTURE0_ARB+Layer,X,Y,Z);
 end else glTexCoord3f(x,y,z);

end;
{------------------------------------------------------------------}
procedure CullFace(Mode : cardinal); stdcall;
begin
  case mode of
  0:glDisable(GL_CULL_FACE);
  1:
  begin
  glEnable(GL_CULL_FACE);
  glCullFace(GL_FRONT);
  end;
  2:
  begin
  glEnable(GL_CULL_FACE);
  glCullFace(GL_BACK);
  end;
  end;
end;
{------------------------------------------------------------------}
procedure InitFBO(Texw, texh, ZBuf : cardinal);
var comp : integer;
begin
 if GL_EXT_framebuffer_object and
 (
 ((fbo_w<>Texw) or (fbo_h<>Texh)) or (fbo_z<>ZBuf) or ((fbo_frame=0) or (fbo_depth=0))
 )then
  begin

  fbo_w := Texw;
  fbo_h := Texh;

  if fbo_frame <> 0 then glDeleteFramebuffersEXT(1, @fbo_frame);
  if fbo_depth <> 0 then glDeleteRenderbuffersEXT(1, @fbo_depth);

  glGenFramebuffersEXT(1, @fbo_frame);
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo_frame);

  glGenRenderbuffersEXT(1, @fbo_depth);
  glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, fbo_depth);

  case ZBuf of
  16:comp:=GL_DEPTH_COMPONENT16_ARB;
  24:comp:=GL_DEPTH_COMPONENT24_ARB;
  32:comp:=GL_DEPTH_COMPONENT32_ARB;
  else
  begin
    AddToLogFile(EngineLog,'ZBuffer depth is incirrect');
    comp:=GL_DEPTH_COMPONENT24_ARB;
  end;
  end;

  glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, comp, Texw, Texh);
 	glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, fbo_depth);
  glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, 0);

  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
  end;
end;
{------------------------------------------------------------------}
procedure InitEng;

   procedure CreateSphere(CX, CY, CZ, Radius : glFloat; N : Integer);  // N = precision
    var I, J : Integer;
        theta1,theta2,theta3 : glFloat;
        X, Y, Z, px, py, pz : glFloat;
    begin
      SphereDL :=glGenLists(1);
      glNewList(SphereDL, GL_COMPILE);

        if Radius < 0 then Radius :=-Radius;
        if n < 0 then n := -n;
        if (n < 4) OR (Radius <= 0) then
        begin
          glBegin(GL_POINTS);
            glVertex3f(CX, CY, CZ);
          glEnd();
          exit;
        end;

        for J :=0 to N DIV 2 -1 do
        begin
          theta1 := J*2*PI/N - PI/2;
          theta2 := (J+1)*2*PI/n - PI/2;
          glBegin(GL_QUAD_STRIP);
            For I :=0 to N do
            begin
              theta3 := i*2*PI/N;
              x := cos(theta2) * cos(theta3);
              y := sin(theta2);
              z := cos(theta2) * sin(theta3);
              px := CX + Radius*x;
              py := CY + Radius*y;
              pz := CZ + Radius*z;

              glNormal3f(X, Y, Z);
              _glTexCoord2f(1-I/n, 2*(J+1)/n);
              glVertex3f(px,py,pz);

              X := cos(theta1) * cos(theta3);
              Y := sin(theta1);
              Z := cos(theta1) * sin(theta3);
              px := CX + Radius*X;
              py := CY + Radius*Y;
              pz := CZ + Radius*Z;

              glNormal3f(X, Y, Z);
              _glTexCoord2f(1-i/n, 2*j/n);
              glVertex3f(px,py,pz);
            end;
          glEnd();
        end;
      glEndList();
    end;

var i : integer;
begin

if GL_ARB_multitexture then
begin

 for i:=1 to 5 do
 begin
  glActiveTextureARB(GL_TEXTURE0_ARB+i);
  glBindTexture(GL_TEXTURE_2D, 0);

  MultyCoordOffset[i][0]:=0.0;
  MultyCoordOffset[i][1]:=0.0;
  MultyCoordOffset[i][2]:=1.0;
  MultyCoordOffset[i][3]:=1.0;
 end;

 glActiveTextureARB(GL_TEXTURE0_ARB);
 glEnable(GL_TEXTURE_2D);
 glBindTexture(GL_TEXTURE_2D, 0);

end;

for i:=0 to 20 do
 LightsOn[i]:=False;

CreateSphere(0, 0, 0, 1, 48);

QuadraticObject := gluNewQuadric;
gluQuadricNormals(QuadraticObject, GLU_SMOOTH);

//_NormCubemap:=GenerateNormalisationCubeMap;

fbo_frame:=0;
fbo_depth:=0;
fbo_w:=0;
fbo_h:=0;
fbo_z:=0;

if GL_EXT_framebuffer_object then
glGenFramebuffersEXT(1, @fbo2);

end;
{------------------------------------------------------------------}
procedure FreeEng;
var i : integer;
Count : cardinal;
begin

gluDeleteQuadric(QuadraticObject);

glDeleteLists(SphereDL,1);

//glDeleteTextures(1, @_NormCubemap);

if GL_EXT_framebuffer_object then
begin
glDeleteFramebuffersEXT(1, @fbo2);
if fbo_frame<>0 then
glDeleteFramebuffersEXT(1, @fbo_frame);
if fbo_depth<>0 then
glDeleteRenderbuffersEXT(1, @fbo_depth);
end;

Obj3DInfo:=nil;

Count:=0;

if AvisCount<>0 then
 for i:=0 to AvisCount-1 do
  if Avis[i].loaded then
  begin
   FreeAVITexture(i);
   inc(Count);
  end;

if Count<>0 then   AddToLogFile(EngineLog,inttostr(Count)+' AVI textures has been freed.');
Count:=0;

Avis:=nil;

if FontsCount>0 then
for i:=0 to FontsCount-1 do
 begin
 glDeleteLists(Fonts3D[i].List,256);
 inc(Count);
 end;

if Count<>0 then AddToLogFile(EngineLog,inttostr(Count)+' 3D Fonts has been freed.');
Count:=0;

Fonts3D:=nil;

if ScenesCount>0 then
 for i:=0 to ScenesCount-1 do
  begin
  FreeScene(Scenes[i].uid);
  inc(Count);
  end;

if Count<>0 then AddToLogFile(EngineLog,inttostr(Count)+' Scenes has been freed.');
Count:=0;

Scenes:=nil;

if ShadersCount>0 then
 for i:=0 to ShadersCount-1 do
  begin
  glDeleteProgramsARB(1,@Shaders[i].glident);
  inc(Count);
  end;

if Count<>0 then AddToLogFile(EngineLog,inttostr(Count)+' Shaders has been freed.');
Count:=0;

Shaders:=nil;

if MeshsCount>0 then
 for i:=0 to MeshsCount-1 do
  begin
  Meshs[i].Mesh.Free;
  inc(Count);
  end;

if Count<>0 then AddToLogFile(EngineLog,inttostr(Count)+' Models has been freed.');
Count:=0;

Meshs:=nil;

if ShowLogo then FreeTexture(Logo);

if length(TexturesInfo)>0 then
 for i:=0 to length(TexturesInfo)-1 do
  begin
  glDeletetextures(1,@TexturesInfo[i].Index);
  inc(Count);
  end;

if Count<>0 then AddToLogFile(EngineLog,inttostr(Count)+' Textures has been freed.');
Count:=0;

TexturesInfo:=nil;

if length(DGLFonts)>0 then
for i:=0 to length(DGLFonts)-1 do
 if DGLFonts[i].Load then
  begin
  glDeletetextures(1,@DGLFonts[i].Texture);
  inc(Count);
  end;

if Count<>0 then AddToLogFile(EngineLog,inttostr(Count)+' Fonts has been freed.');

DGLFonts:=nil;
end;
{Scenes -----------------------------------------------------------------------}
procedure SceneSetObjActive( SceneIdent, ObjIdent : cardinal; Active : boolean ); stdcall;
var i : integer;
begin
if ScenesCount>0 then
 for i := 0 to ScenesCount - 1 do
  if SceneIdent=Scenes[i].uid then
  begin
    Scenes[i].Models[ObjIdent].Active:=Active;
    Exit;
  end;
end;
{------------------------------------------------------------------}
procedure SceneSetObj( SceneIdent, ObjIdent : cardinal; SceneMesh : TSceneMesh ); stdcall;
var i : integer;
begin
if ScenesCount>0 then
 for i := 0 to ScenesCount - 1 do
  if SceneIdent=Scenes[i].uid then
  begin
    Scenes[i].Models[ObjIdent]:= SceneMesh;
    Exit;
  end;
end;
{------------------------------------------------------------------}
function SceneGetObj( SceneIdent, ObjIdent : cardinal ) : TSceneMesh; stdcall;
var i : integer;
begin
if ScenesCount>0 then
 for i := 0 to ScenesCount - 1 do
  if SceneIdent=Scenes[i].uid then
  begin
    result:=Scenes[i].Models[ObjIdent];
    Exit;
  end;
end;
{------------------------------------------------------------------}
function GetSceneObjectIdent( SceneIdent : cardinal; ObjName : string ) : integer; stdcall;
var i,j : integer;
begin
result:=-1;
if ScenesCount>0 then
 for i := 0 to ScenesCount - 1 do
  if SceneIdent=Scenes[i].uid then
  begin
    result:=-1;
    if length(Scenes[i].Models)>0 then
    for j := 0 to length(Scenes[i].Models) - 1 do
     if ObjName = Scenes[i].Models[j].Name then
     begin
       result:=j;
       Exit;
     end;
    Exit;
  end;
end;
{------------------------------------------------------------------}
function SceneGetLastCollideObjectIndex:integer; stdcall;
begin
  result:=LastCollide;
end;
{------------------------------------------------------------------}
function SceneObjCount( Ident : cardinal ) : cardinal; stdcall;
var i : integer;
begin
result:=0;
if ScenesCount>0 then
 for i := 0 to ScenesCount - 1 do
  if Ident=Scenes[i].uid then
  begin
    result:=length(Scenes[i].Models);
    Exit;
  end;
end;
{------------------------------------------------------------------}
function CollideBoxWithScene(Ident : cardinal; BoxPos, BoxSize : Tvertex):boolean; stdcall;

  type
  TPhysicsBoundBox = record
  Min, Max: TVertex;
  end;

  function BoundBoxIntersect(const BoundBox, WithBoundBox: TPhysicsBoundBox): boolean;
  begin                      
   Result :=
    ((BoundBox.Max.x >= WithBoundBox.Min.x) and
    (BoundBox.Min.x <= WithBoundBox.Max.x)) and
    ((BoundBox.Max.y >= WithBoundBox.Min.y) and
    (BoundBox.Min.y <= WithBoundBox.Max.y)) and
    ((BoundBox.Max.z >= WithBoundBox.Min.z) and
    (BoundBox.Min.z <= WithBoundBox.Max.z));
  end;

  function PhysicsBoundBox (minx, miny, minz, maxx, maxy, maxz : single):TPhysicsBoundBox; inline;
  begin
   result.Min.X:=minx;
   result.Min.Y:=miny;
   result.Min.Z:=minz;
   result.Max.X:=maxx;
   result.Max.Y:=maxy;
   result.Max.Z:=maxz;
  end;

  var
  i,j : integer;
  mbound : Tvertex;
  cur,cur2 : TPhysicsBoundBox;
begin
 result := false;

 cur := PhysicsBoundBox(BoxPos.X-BoxSize.X/2,BoxPos.Y-BoxSize.Y/2,BoxPos.Z-BoxSize.Z/2,
                        BoxPos.X+BoxSize.X/2,BoxPos.Y+BoxSize.Y/2,BoxPos.Z+BoxSize.Z/2);

 LastCollide:=-1;

 if ScenesCount>0 then
 for j := 0 to ScenesCount - 1 do
 if Ident=Scenes[j].uid then
 begin
 if length(Scenes[j].Models)>0 then
  for i := 0 to length(Scenes[j].Models) - 1 do
  if Scenes[j].Models[i].Active then
  begin

   mbound:=ModelBoundingBox(Scenes[j].models[i].Mesh,0);

   with Scenes[j].models[i] do
   cur2 := PhysicsBoundBox(
   Pos.X-(mbound.X*Scale)/2,Pos.Y-(mbound.Y*Scale)/2,Pos.Z-(mbound.Z*Scale)/2,
   Pos.X+(mbound.X*Scale)/2,Pos.Y+(mbound.Y*Scale)/2,Pos.Z+(mbound.Z*Scale)/2
   );

   if BoundBoxIntersect(cur,cur2) then
   begin
     result:=true;
     LastCollide:=i;
     Exit;
   end;

  end;

 Exit;
 end;
end;
{------------------------------------------------------------------}
function LoadScene(FileName, MeshPath, TexPath : string):cardinal; stdcall;
var
F : textfile;
s : string;
MeshFromPak, TxtFromPak : boolean;

procedure ReadEntity;
var
t : TSceneMesh;
i : integer;
a,b,c : single;
found : boolean;
begin
 Readln(f,S);
 Readln(f,S);
 Readln(f,S);
 Readln(f,S);
 t.Name:=s;
 if not MeshFromPak then
 t.Mesh:=LoadModel(MeshPath+'\'+s+'.dmd',0,false)
 else
 begin
  ExtractFromPackage(MeshPath,s+'.dmd','temp.dmd');
  t.Mesh:=LoadModel('temp.dmd',0,false);
  DeleteFile('temp.dmd');
 end;
 Readln(f,S);
 Readln(f,a,b,c);
 t.Pos.X:=a;
 t.Pos.Y:=b;
 t.Pos.Z:=c;
 Readln(f,S);
 Readln(f,t.Scale);
 t.Material:=ModelMaterial(t.Mesh);

 if t.Material.TexFileName<>'None' then
 begin

 found:=false;

 if length(Scenes[ScenesCount-1].Models)-1>0 then
  for i := 0 to length(Scenes[ScenesCount-1].Models)-1 do
   if t.Material.TexFileName=Scenes[ScenesCount-1].Models[i].Material.TexFileName then
   begin
     t.Texture:=Scenes[ScenesCount-1].Models[i].Texture;
     found:=true;
     break;
   end;

  if not found then
    if not TxtFromPak then
    t.Texture:=LoadTextureFromFile(TexPath+'\'+t.Material.TexFileName,0,-1)
    else
    t.Texture:=LoadTextureFromPackage(TexPath,t.Material.TexFileName,0,-1);

 end else t.Texture:=0;

 if t.Material.NormalMapFileName<>'None' then
 begin

 found:=false;

 if length(Scenes[ScenesCount-1].Models)-1>0 then
  for i := 0 to length(Scenes[ScenesCount-1].Models)-1 do
   if t.Material.NormalMapFileName=Scenes[ScenesCount-1].Models[i].Material.NormalMapFileName then
   begin
     t.BumpTexture:=Scenes[ScenesCount-1].Models[i].BumpTexture;
     found:=true;
     break;
   end;

  if not found then
    if not TxtFromPak then
    t.BumpTexture:=LoadTextureFromFile(TexPath+'\'+t.Material.NormalMapFileName,0,-1)
    else
    t.BumpTexture:=LoadTextureFromPackage(TexPath,t.Material.NormalMapFileName,0,-1);

 end else t.BumpTexture:=0;

 if t.Material.SpecularMapFileName<>'None' then
 begin

 found:=false;

 if length(Scenes[ScenesCount-1].Models)-1>0 then
  for i := 0 to length(Scenes[ScenesCount-1].Models)-1 do
   if t.Material.SpecularMapFileName=Scenes[ScenesCount-1].Models[i].Material.SpecularMapFileName then
   begin
     t.SpecTexture:=Scenes[ScenesCount-1].Models[i].SpecTexture;
     found:=true;
     break;
   end;

  if not found then
    if not TxtFromPak then
    t.SpecTexture:=LoadTextureFromFile(TexPath+'\'+t.Material.SpecularMapFileName,0,-1)
    else
    t.SpecTexture:=LoadTextureFromPackage(TexPath,t.Material.SpecularMapFileName,0,-1);

 end else t.SpecTexture:=0;

 t.Active:=true;
 t.DoBump:=false;
 t.MeshSmooth:=true;
 t.MeshFrame:=0;

 SetLength(Scenes[ScenesCount-1].Models,length(Scenes[ScenesCount-1].Models)+1);
 Scenes[ScenesCount-1].Models[length(Scenes[ScenesCount-1].Models)-1]:=t;

end;

begin
if fileexists(FileName) then
begin
    TxtFromPak  := copy(Uppercase(TexPath), length(TexPath)-3, 4) = '.DPC';
    MeshFromPak := copy(Uppercase(MeshPath), length(MeshPath)-3, 4) = '.DPC';

    SetLength(Scenes,ScenesCount+1);
    ScenesCount:=ScenesCount+1;
    ScenesOverall:=ScenesOverall+1;
    Scenes[ScenesCount-1].uid:=ScenesOverall;
    SetLength(Scenes[ScenesCount-1].Models,0);
   AssignFile(f,FileName);
   Reset(f);
   while not Eof(f) do begin
     Readln(f,S);
     if S = 'Entity()' then ReadEntity;
   end;
   CloseFile(F);
   result:=ScenesOverall;
end else
begin
AddToLogFile(EngineLog,'"'+FileName+'" scene file not found.');
result:=0;
end;
end;
{------------------------------------------------------------------}
procedure FreeScene(Ident : cardinal); stdcall;
var i,j : integer;
t : TScene;
begin
 if ScenesCount>0 then
  for i := 0 to ScenesCount - 1 do
  if Ident=Scenes[i].uid then
  begin

    if length(Scenes[i].Models)>0 then
    for j := 0 to length(Scenes[i].Models) - 1 do
    begin
      FreeModel(Scenes[i].Models[j].Mesh);
      if Scenes[i].Models[j].Texture<>0 then
      FreeTexture(Scenes[i].Models[j].Texture);
      if Scenes[i].Models[j].BumpTexture<>0 then
      FreeTexture(Scenes[i].Models[j].BumpTexture);
      if Scenes[i].Models[j].SpecTexture<>0 then
      FreeTexture(Scenes[i].Models[j].SpecTexture);
    end;

    if ScenesCount>1 then
    begin

      t.uid:=Scenes[ScenesCount-1].uid;
      SetLength(t.Models,length(Scenes[ScenesCount-1].Models));
      if length(Scenes[ScenesCount-1].Models)>0 then
       for j := 0 to length(t.Models) - 1 do
        t.Models[j]:=Scenes[ScenesCount-1].Models[j];

      Scenes[i].uid:=t.uid;
       SetLength(Scenes[i].Models,length(t.Models));
      if length(t.Models)>0 then
       for j := 0 to length(t.Models) - 1 do
        Scenes[i].Models[j]:=t.Models[j];

    end;

    ScenesCount:=ScenesCount-1;
    SetLength(Scenes,ScenesCount);

    Exit;
  end;
end;
{------------------------------------------------------------------}
procedure DrawScene(Ident : cardinal);stdcall;
var i,j : integer;
t : Tvertex; alpha : byte; atest : boolean;
begin
if ScenesCount>0 then
for j := 0 to ScenesCount - 1 do
if Ident=Scenes[j].uid then
begin
if not _SceneDontUseMat then
BeginObj3D;
 if length(Scenes[j].Models)>0 then
  for i := 0 to length(Scenes[j].Models) - 1 do
   begin
   t:=ModelBoundingBox(Scenes[j].Models[i].Mesh,0);
   if (not _frustumcalculated or IsBoxInFrustum(Scenes[j].Models[i].Pos.X,Scenes[j].Models[i].Pos.Y,Scenes[j].Models[i].Pos.Z,
      t.X*Scenes[j].Models[i].Scale,t.y*Scenes[j].Models[i].Scale,t.z*Scenes[j].Models[i].Scale)) and Scenes[j].Models[i].Active
   then
    begin
     glPushMatrix();

      glTranslatef(Scenes[j].Models[i].Pos.X,Scenes[j].Models[i].Pos.Y,Scenes[j].Models[i].Pos.Z);
      glScalef(Scenes[j].Models[i].Scale,Scenes[j].Models[i].Scale,Scenes[j].Models[i].Scale);

      atest:=false;

      if not _SceneDontUseMat then
      begin

      if not Scenes[j].Models[i].DoBump or (Scenes[j].Models[i].DoBump and(Scenes[j].Models[i].BumpTexture=0)) then
      glBindTexture(GL_TEXTURE_2D,Scenes[j].Models[i].Texture)
      else
      begin
        ActivateMultitexturingLayer(0);
        glBindTexture(GL_TEXTURE_2D,Scenes[j].Models[i].Texture);
        ActivateMultitexturingLayer(1);
        glBindTexture(GL_TEXTURE_2D,Scenes[j].Models[i].BumpTexture);
        ActivateMultitexturingLayer(2);
        glBindTexture(GL_TEXTURE_2D,Scenes[j].Models[i].SpecTexture);
        ActivateMultitexturingLayer(0);
        glEnable(GL_VERTEX_PROGRAM_ARB);
        glEnable(GL_FRAGMENT_PROGRAM_ARB);
        bump_active:=true;
      end;

      if Scenes[j].Models[i].Material.alpha>252 then alpha:=255 else
      if (Scenes[j].Models[i].Material.alpha<255) and (Scenes[j].Models[i].Material.alpha>220) then
      begin
      atest:=true;
      alpha:=255;
      glEnable(GL_ALPHA_TEST);
      glAlphaFunc(GL_GREATER, 0.3);
      end else alpha:=Scenes[j].Models[i].Material.alpha;

      Color3D(RGB(Scenes[j].Models[i].Material.diffuse[0],Scenes[j].Models[i].Material.diffuse[1],Scenes[j].Models[i].Material.diffuse[2]),
      alpha,false,Scenes[j].Models[i].Material.glossiness);

      end;

      DrawModel(Scenes[j].Models[i].Mesh,Scenes[j].Models[i].MeshFrame,Scenes[j].Models[i].MeshSmooth);

      if not _SceneDontUseMat then
      begin

      if atest then glDisable(GL_ALPHA_TEST);
      if Scenes[j].Models[i].DoBump and (Scenes[j].Models[i].BumpTexture<>0) then
      begin
        ActivateMultitexturingLayer(0);
        glBindTexture(GL_TEXTURE_2D,0);
        ActivateMultitexturingLayer(1);
        glBindTexture(GL_TEXTURE_2D,0);
        ActivateMultitexturingLayer(2);
        glBindTexture(GL_TEXTURE_2D,0);
        ActivateMultitexturingLayer(0);
        glDisable(GL_VERTEX_PROGRAM_ARB);
        glDisable(GL_FRAGMENT_PROGRAM_ARB); 
        bump_active:=false;
      end;

      end;

     glPopMatrix();
    end;
   end;
if not _SceneDontUseMat then
EndObj3D;
Exit;
end;
end;
{------------------------------------------------------------------}
function SceneBoundingBox(Ident : cardinal):TVertex; stdcall;
var i, j : integer;
min, max, mbound : Tvertex;
begin

result.X:=0;
result.Y:=0;
result.Z:=0;

if ScenesCount>0 then
for j := 0 to ScenesCount - 1 do
if Ident=Scenes[j].uid then
begin

min:=result;
max:=result;

 if length(Scenes[j].Models)>0 then
  for i := 0 to length(Scenes[j].Models) - 1 do
  with Scenes[j].Models[i] do
  begin

   mbound:=ModelBoundingBox(Mesh,0);

   if max.X<mbound.X+Pos.X then max.X:=mbound.X+Pos.X;
   if max.Y<mbound.Y+Pos.Y then max.Y:=mbound.Y+Pos.Y;
   if max.Z<mbound.Z+Pos.Z then max.Z:=mbound.Z+Pos.Z;

   if min.X>mbound.X+Pos.X then min.X:=mbound.X+Pos.X;
   if min.Y>mbound.Y+Pos.Y then min.Y:=mbound.Y+Pos.Y;
   if min.Z>mbound.Z+Pos.Z then min.Z:=mbound.Z+Pos.Z;

  end;

  result.X:=max.X-min.X;
  result.Y:=max.Y-min.Y;
  result.Z:=max.Z-min.Z;
Exit;
end;
end;
{3D Multy Mesh (models)--------------------------------------------------------}
procedure ModelsBump(Active : boolean); stdcall;
begin
bump_active:=Active;
end;
{------------------------------------------------------------------}
function ModelMaterial(Modelident : integer) : TMaterial; stdcall;
var i : integer; s : TMaterial;
begin
if MeshsCount<>0 then
for i:=0 to MeshsCount-1 do
 if Meshs[i].Ident=ModelIdent then
 begin
  if Meshs[i].Mesh.MaterialPresented then
  result:=Meshs[i].Mesh.Material else
  begin
  s.diffuse[0]:=255;
  s.diffuse[1]:=255;
  s.diffuse[2]:=255;
  s.glossiness:=10;
  s.alpha:=255;
  s.TexFileName:='None';
  s.NormalMapFileName:='None';
  s.SpecularMapFileName:='None';
  result:=s;
  end;
  Exit;
 end;
end;
{------------------------------------------------------------------}
procedure  GetModelGeometry(ModelIdent, Frame : integer; GeometryData : PMeshGeometry); stdcall;
var i,j : integer;
begin
if MeshsCount<>0 then
for i:=0 to MeshsCount-1 do
 if Meshs[i].Ident=ModelIdent then
 with GeometryData^ do
 begin

   VerticesCount:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).VertexCount;
   FacesCount:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).FacesCount;

   SetLength(Vertices,VerticesCount);
   SetLength(Normals,VerticesCount);
   SetLength(TextureVertices,VerticesCount);
   SetLength(Tangents,length(TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Tangent));

   for j := 0 to VerticesCount - 1 do
    begin

    Vertices[j]:=vertex(TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Vertices[j].x,TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Vertices[j].y,TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Vertices[j].z);

    case Meshs[i].Mesh.ScaleType of
    1:
    begin
      Vertices[j].X:=Vertices[j].X*TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).fExtent;
      Vertices[j].Y:=Vertices[j].Y*TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).fExtent;
      Vertices[j].Z:=Vertices[j].Z*TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).fExtent;
    end;
    2:
    begin
      Vertices[j].X:=Vertices[j].X*TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).fExtentX;
      Vertices[j].Y:=Vertices[j].Y*TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).fExtentY;
      Vertices[j].Z:=Vertices[j].Z*TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).fExtentZ;
    end;
    3:
    begin
      Vertices[j].X:=Vertices[j].X*Meshs[i].Mesh.fAllScale;
      Vertices[j].Y:=Vertices[j].Y*Meshs[i].Mesh.fAllScale;
      Vertices[j].Z:=Vertices[j].Z*Meshs[i].Mesh.fAllScale;
    end;
    end;

     Normals[j]:=vertex(TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).SmoothNormals[j].x,TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).SmoothNormals[j].y,TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).SmoothNormals[j].z);
     TextureVertices[j]:=vertex(Meshs[i].Mesh.TexVertices[j].x,Meshs[i].Mesh.TexVertices[j].y,Meshs[i].Mesh.TexVertices[j].z);

     if length(Tangents)>0 then
     Tangents[j]:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Tangent[j];

    end;

   SetLength(Faces,FacesCount);
   if Meshs[i].Mesh.TexturePresent then
   SetLength(TextureFaces,FacesCount) else
   SetLength(TextureFaces,0);

   for j := 0 to VerticesCount - 1 do
    begin
     Faces[j][0]:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Faces[j][0];
     Faces[j][1]:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Faces[j][1];
     Faces[j][2]:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Faces[j][2];
     if Meshs[i].Mesh.TexturePresent then
     begin
     TextureFaces[j][0]:=Meshs[i].Mesh.TexFaces[j][0];
     TextureFaces[j][1]:=Meshs[i].Mesh.TexFaces[j][1];
     TextureFaces[j][2]:=Meshs[i].Mesh.TexFaces[j][2];
     end;
    end;

  Exit;
 end;
end;
{------------------------------------------------------------------}
function ModelTrianglesCount(Modelident,Frame : integer) : Cardinal; stdcall;
var i : integer;
begin
result:=0;
if MeshsCount<>0 then
for i:=0 to MeshsCount-1 do
 if Meshs[i].Ident=ModelIdent then
 begin
  result:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).FacesCount;
  Exit;
 end;
end;
{------------------------------------------------------------------}
function ModelBoundingBox(Modelident,Frame : integer):TVertex; stdcall;
var i : integer;
begin
if MeshsCount<>0 then
for i:=0 to MeshsCount-1 do
 if Meshs[i].Ident=ModelIdent then
 begin

    if Frame>Meshs[i].Mesh.Meshes.Count-1 then Frame:=0;
    case Meshs[i].Mesh.ScaleType of
    1:begin
    result.x:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Width*TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).fExtent;
    result.y:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Height*TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).fExtent;
    result.z:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Depth*TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).fExtent;
    end;
    2:begin
    result.x:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Width*TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).fExtentX;
    result.y:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Height*TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).fExtentY;
    result.z:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Depth*TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).fExtentZ;
    end;
    3:begin
    result.x:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Width*Meshs[i].Mesh.fAllScale;
    result.y:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Height*Meshs[i].Mesh.fAllScale;
    result.z:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Depth*Meshs[i].Mesh.fAllScale;
    end;
    else
    begin
    result.x:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Width;
    result.y:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Height;
    result.z:=TGLMesh(Meshs[i].Mesh.Meshes.Items[Frame]).Depth;
    end;
    end;//case

 Exit;
 end;

end;
{------------------------------------------------------------------}
function ModelFramesCount(Modelident : integer):Integer; stdcall;
var i : integer;
begin
result:=0;
if MeshsCount<>0 then
for i:=0 to MeshsCount-1 do
 if Meshs[i].Ident=ModelIdent then
 begin
 result:=Meshs[i].Mesh.Meshes.Count;
 Exit;
 end;
end;
{------------------------------------------------------------------}
function LoadModel(Filename : string; ScaleType : byte; NormalInv : boolean) : integer; stdcall;
begin
 if fileexists(Filename) then
 begin
 inc(OverAllMeshUsed);

 SetLength(Meshs,MeshsCount+1);
 result:=OverAllMeshUsed;

 try
 Meshs[MeshsCount].Ident:=OverAllMeshUsed;
 Meshs[MeshsCount].Mesh:=TGLMultyMesh.Create;
 Meshs[MeshsCount].Mesh.LoadFromFile(Filename,NormalInv);
 Meshs[MeshsCount].Mesh.ScaleType := ScaleType;
 Meshs[MeshsCount].Mesh.fSmooth:= false;
 inc(MeshsCount);
 except
 AddToLogFile(EngineLog,'Model "'+ Filename +'" not loaded. May be file corrupted or wrong file.');
 result:=0;
 Exit;
 end;
 AddToLogFile(EngineLog,'Model "'+ Filename +'" loaded successfully.');
 end else
 begin
 AddToLogFile(EngineLog,'Model file "'+ Filename +'" not found!');
 //MessageBox(0, PChar('Model file "'+ Filename +'" not found!'), PChar('Draw3D Unit'), MB_OK or MB_ICONERROR);
 result:=0;
 end;
end;
{------------------------------------------------------------------}
procedure DrawModel(ModelIdent, Frame : integer; Smooth : boolean); stdcall;
var i : cardinal;
begin
if MeshsCount<>0 then
for i:=0 to MeshsCount-1 do
 if Meshs[i].Ident=ModelIdent then
 begin
 Meshs[i].Mesh.fSmooth:=Smooth;
 if (Meshs[i].Mesh.Meshes.Count>1) and (Frame<Meshs[i].Mesh.Meshes.Count) and
 (Frame>0) then
 Meshs[i].Mesh.CurrentFrame:=Frame else Meshs[i].Mesh.CurrentFrame:=0;
 Meshs[i].Mesh.Draw;
 Exit;
 end;
end;
{------------------------------------------------------------------}
procedure FreeModel(ModelIdent : integer); stdcall;
var i : cardinal;
T : TAMesh;
begin
for i:=0 to MeshsCount-1 do
 if Meshs[i].Ident=ModelIdent then
 begin

 Meshs[i].Mesh.Free;

 if MeshsCount>1 then
 begin
 T:=Meshs[MeshsCount-1];
 Meshs[i]:=T;
 end;

 SetLength(Meshs,MeshsCount-1);
 dec(MeshsCount);

 Exit;
 end;
end;
{Other 3D routines-------------------------------------------------------------}
procedure BeginObj3D; stdcall;
begin
   InBlock:=true;
   SetLength(Obj3DInfo,length(Obj3DInfo)+1);
   Obj3DInfo[length(Obj3DInfo)-1].Texture:=curTexture;
   Obj3DInfo[length(Obj3DInfo)-1].Projecting:=Projecting;
   glGetFloatv(GL_CURRENT_COLOR, @Obj3DInfo[length(Obj3DInfo)-1].Color);

  if Projecting then
  glEnable(GL_BLEND);

  glPushMatrix();
end;
{------------------------------------------------------------------}
procedure EndObj3D; stdcall;
begin
  glPopMatrix();
  glcolor4f(Obj3DInfo[length(Obj3DInfo)-1].Color[1],Obj3DInfo[length(Obj3DInfo)-1].Color[2],Obj3DInfo[length(Obj3DInfo)-1].Color[3],Obj3DInfo[length(Obj3DInfo)-1].Color[4]);
  SetTexture(Obj3DInfo[length(Obj3DInfo)-1].Texture);
  Projecting:=Obj3DInfo[length(Obj3DInfo)-1].Projecting;
  SetLength(Obj3DInfo,length(Obj3DInfo)-1);
  if not Projecting then
  begin
  glDisable(GL_TEXTURE_GEN_S);
  glDisable(GL_TEXTURE_GEN_T);
  end;
  glDisable(GL_BLEND);
  InBlock:=false;
end;
{------------------------------------------------------------------}
procedure CalculateFrustum; stdcall;
begin
_frustumcalculated:=true;
Frustum.Calculate;
end;
{------------------------------------------------------------------}
function IsPointInFrustum(X,Y,Z : single) : boolean; stdcall;
begin
result:=Frustum.IsPointWithin(X,Y,Z);
end;
{------------------------------------------------------------------}
function IsSphereInFrustum(X,Y,Z,Radius : single) : boolean; stdcall;
begin
result:=Frustum.IsSphereWithin(X,Y,Z,Radius);
end;
{------------------------------------------------------------------}
function IsBoxInFrustum(X,Y,Z,W,H,D : single) : boolean; stdcall;
begin
result:=Frustum.IsBoxWithin(X,Y,Z,W,H,D);
end;
{------------------------------------------------------------------}
procedure SetMultytexturingLayerOffset(Layer : cardinal; X,Y : single); stdcall;
begin
 MultyCoordOffset[Layer][0]:=X;
 MultyCoordOffset[Layer][1]:=Y;
end;
{------------------------------------------------------------------}
procedure SetMultytexturingLayerTexCoordMulti(Layer : cardinal; X,Y : single); stdcall;
begin
 MultyCoordOffset[Layer][2]:=X;
 MultyCoordOffset[Layer][3]:=Y;
end;
{------------------------------------------------------------------}
procedure DrawPolygon3D(points : array of TVertex3D); stdcall;
var i : integer;
begin
 glBegin(GL_POLYGON);
  for i:=0 to Length(points)-1 do
   begin
   glcolor4ub(GetRValue(points[i].Color),GetGValue(points[i].Color),GetBValue(points[i].Color),points[i].Alpha);
   _glTexCoord2f(points[i].TexX,points[i].TexY);
   glVertex3f(points[i].X,points[i].Y,points[i].Z);
   end;
 glEnd;
end;
{------------------------------------------------------------------}
function CreateTextureToRenderIn(TextureWidth,TextureHeight : integer):GlUint; stdcall;
begin
  result:=CreateRenderTex(TextureWidth,TextureHeight);
end;
{------------------------------------------------------------------}
procedure SetCamera(Camera : TCamera); stdcall;
begin
gluLookAt(Camera.Eye.X,Camera.Eye.Y,Camera.Eye.Z,Camera.Center.X,Camera.Center.Y,Camera.Center.Z,0,1,0);
end;
{------------------------------------------------------------------}
procedure ClearZBuffer; stdcall;
begin
glClear(GL_DEPTH_BUFFER_BIT);
end;
{------------------------------------------------------------------}
procedure ZBuffer(Active : boolean); stdcall;
begin
if Active then glEnable(GL_DEPTH_TEST) else glDisable(GL_DEPTH_TEST);
end;
{------------------------------------------------------------------}
procedure ResetMatrix; stdcall;
begin
glLoadIdentity();
end;
{------------------------------------------------------------------}
procedure SetFog(Color : Integer; Fog_Start, Fog_End : single); stdcall;
var fogColor : Array [0..3] of GLFloat;
begin
 fogColor[0]:=GetRValue(Color)/255;
 fogColor[1]:=GetGValue(Color)/255;
 fogColor[2]:=GetBValue(Color)/255;
 fogColor[3]:=1.0;
 glEnable(GL_FOG);
 glFogi  (GL_FOG_MODE, GL_LINEAR);
 glHint  (GL_FOG_HINT, GL_DONT_CARE);
 glFogf  (GL_FOG_START, Fog_Start);
 glFogf  (GL_FOG_END, Fog_End);
 glFogfv (GL_FOG_COLOR, @fogColor);
end;
{------------------------------------------------------------------}
procedure DeactiveFog; stdcall;
begin
 glDisable(GL_FOG);
end;
{------------------------------------------------------------------}
procedure DrawCylinder(Radius,Height : single); stdcall;
begin
  gluCylinder(QuadraticObject, Radius, Radius, Height, 24, 1);
  gluQuadricOrientation(QuadraticObject, GLU_INSIDE);
  gluDisk(QuadraticObject, 0, Radius, 24, 1);
  gluQuadricOrientation(QuadraticObject, GLU_OUTSIDE);
  glTranslatef(0, 0, Height);
  gluDisk(QuadraticObject, 0, Radius, 24, 1);
end;
{------------------------------------------------------------------}
procedure DrawSphere(Radius : single); stdcall;
begin
glPushMatrix();
glScalef(Radius,Radius,Radius);
glCallList(SphereDL);
glPopMatrix();
end;
{------------------------------------------------------------------}
procedure DrawEllipse(Width,Height,Depth : single); stdcall;
begin
glPushMatrix();
glScalef(Width,Height,Depth);
glCallList(SphereDL);
glPopMatrix();
end;
{------------------------------------------------------------------}
procedure DrawPlane(Width,Height : single); stdcall;
begin
glBegin(GL_QUADS);
 glNormal3f( 0.0, 0.0, 1.0);
 _glTexCoord2f(0,1);
 glVertex2f(-Width/2,-Height/2);
 _glTexCoord2f(1,1);
 glVertex2f(Width/2, -Height/2);
 _glTexCoord2f(1,0);
 glVertex2f(Width/2,  Height/2);
 _glTexCoord2f(0,0);
 glVertex2f(-Width/2, Height/2);
glEnd;
end;
{------------------------------------------------------------------}
procedure DrawSprite(Width,Height : single; FramesXCount, FramesYCount, FrameNumber: integer);stdcall;
var imgWidth, imgHeight : glfloat; XFrame, YFrame : byte;
begin
  if FramesXCount=0 then FramesXCount:=1;
  if FramesYCount=0 then FramesYCount:=1;

  imgWidth:=1.0/FramesXCount;
  imgHeight:=1.0/FramesYCount;

  YFrame:=(FrameNumber div FramesXCount)+1;
  if FrameNumber mod FramesXCount = 0 then YFrame:=YFrame-1;
  XFrame:=FrameNumber - (YFrame-1)*FramesXCount;

  XFrame:=XFrame-1;
  YFrame:=YFrame-1;

      glBegin(GL_QUADS);
        glNormal3f( 0.0, 0.0, 1.0);
        _glTexCoord2f(imgWidth*XFrame, imgHeight*YFrame);
        glVertex2f(-Width/2,-Height/2);

        _glTexCoord2f(imgWidth*XFrame+imgWidth, imgHeight*YFrame);
        glVertex2f(Width/2, -Height/2);

        _glTexCoord2f(imgWidth*XFrame+imgWidth, imgHeight*YFrame+imgHeight);
        glVertex2f( Width/2,  Height/2);

        _glTexCoord2f(imgWidth*XFrame, imgHeight*YFrame+imgHeight);
        glVertex2f(-Width/2,  Height/2);
      glEnd;

end;
{------------------------------------------------------------------}
procedure DrawSprite_BillBoard(Width,Height : single; FramesXCount, FramesYCount, FrameNumber: integer);stdcall;
var imgWidth, imgHeight : glfloat; XFrame, YFrame : byte;
m : TGLMatrixd4;
v : array [0..3] of TVertex;
length : single;
begin
  if FramesXCount=0 then FramesXCount:=1;
  if FramesYCount=0 then FramesYCount:=1;

  imgWidth:=1.0/FramesXCount;
  imgHeight:=1.0/FramesYCount;

  YFrame:=(FrameNumber div FramesXCount)+1;
  if FrameNumber mod FramesXCount = 0 then YFrame:=YFrame-1;
  XFrame:=FrameNumber - (YFrame-1)*FramesXCount;

  XFrame:=XFrame-1;
  YFrame:=YFrame-1;

  glGetDoublev(GL_MODELVIEW_MATRIX, @m );

  Width:=Width/1.41;
  Height:=Height/1.41;

  v[0].X:=-m[0][0]-m[0][1];
  v[0].Y:=-m[1][0]-m[1][1];
  v[0].Z:=-m[2][0]-m[2][1];

  length:=sqrt(sqr(v[0].X) + sqr(v[0].Y) + sqr(v[0].Z));
  v[0].X:=v[0].X/length*Width;
  v[0].Y:=v[0].Y/length*Height;
  v[0].Z:=v[0].Z/length*Width;

  v[1].X:=m[0][0]-m[0][1];
  v[1].Y:=m[1][0]-m[1][1];
  v[1].Z:=m[2][0]-m[2][1];

  length:=sqrt(sqr(v[1].X) + sqr(v[1].Y) + sqr(v[1].Z));
  v[1].X:=v[1].X/length*Width;
  v[1].Y:=v[1].Y/length*Height;
  v[1].Z:=v[1].Z/length*Width;

  v[2].X:=m[0][0]+m[0][1];
  v[2].Y:=m[1][0]+m[1][1];
  v[2].Z:=m[2][0]+m[2][1];

  length:=sqrt(sqr(v[2].X) + sqr(v[2].Y) + sqr(v[2].Z));
  v[2].X:=v[2].X/length*Width;
  v[2].Y:=v[2].Y/length*Height;
  v[2].Z:=v[2].Z/length*Width;

  v[3].X:=-m[0][0]+m[0][1];
  v[3].Y:=-m[1][0]+m[1][1];
  v[3].Z:=-m[2][0]+m[2][1];

  length:=sqrt(sqr(v[3].X) + sqr(v[3].Y) + sqr(v[3].Z));
  v[3].X:=v[3].X/length*Width;
  v[3].Y:=v[3].Y/length*Height;
  v[3].Z:=v[3].Z/length*Width;

      glBegin(GL_QUADS);
        glNormal3f( 0.0, 0.0, 1.0);
        _glTexCoord2f(imgWidth*XFrame, imgHeight*YFrame);
        glVertex3fv(@v[0]);

        _glTexCoord2f(imgWidth*XFrame+imgWidth, imgHeight*YFrame);
        glVertex3fv(@v[1]);

        _glTexCoord2f(imgWidth*XFrame+imgWidth, imgHeight*YFrame+imgHeight);
        glVertex3fv(@v[2]);

        _glTexCoord2f(imgWidth*XFrame, imgHeight*YFrame+imgHeight);
        glVertex3fv(@v[3]);
      glEnd;

end;
{------------------------------------------------------------------}
procedure DrawTextureToTexture(TexSource,TexTarget : GluInt; X,Y : integer); stdcall;
var
pBits : pByteArray;
begin
GetMem(pBits,GetTextureInfo(TexSource).Width*GetTextureInfo(TexSource).Height*3);
glBindTexture(GL_TEXTURE_2D, TexSource);
glGetTexImage(GL_TEXTURE_2D,0,GL_RGB,GL_UNSIGNED_BYTE,pBits);
glBindTexture(GL_TEXTURE_2D, TexTarget);
glTexParameterf(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, 0);
glTexSubImage2D(GL_TEXTURE_2D,0,X,Y,GetTextureInfo(TexSource).Width,GetTextureInfo(TexSource).Height,GL_RGB,GL_UNSIGNED_BYTE,pBits);
glBindTexture(GL_TEXTURE_2D, 0);
FreeMem(pBits);
end;
{------------------------------------------------------------------}
procedure RenderTexToTexFBO(ToTexture,TexSource,TexTarget : GluInt; X,Y : integer); stdcall;
var
w, h, w1, h1 : cardinal;
begin
if GL_EXT_framebuffer_object and _UseFBO then
begin
w:=GetTextureInfo(TexTarget).Width;
h:=GetTextureInfo(TexTarget).Height;

w1:=GetTextureInfo(TexSource).Width;
h1:=GetTextureInfo(TexSource).Height;

if (GetTextureInfo(ToTexture).Width<>w) or (GetTextureInfo(ToTexture).Height<>h) then Exit;

glPushMatrix();
glViewport(0, 0, w, h);
glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo2);
glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, ToTexture, 0);
if glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT) <> GL_FRAMEBUFFER_COMPLETE_EXT then
begin
glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
DrawTextureToTexture(TexSource,TexTarget,x,y);
DrawTextureToTexture(TexTarget,ToTexture,0,0);
AddToLogFile(EngineLog,'Faild to "RenderTexToTexFBO". Error in FBO initialization.');
Exit;
end;
glLoadIdentity();
glClear(GL_COLOR_BUFFER_BIT);
glMatrixMode(GL_PROJECTION);
glPushMatrix;
glLoadIdentity;
gluOrtho2D(0,w,0,h);
glMatrixMode(GL_MODELVIEW);
glPushMatrix;
glLoadIdentity;

glEnable(GL_ALPHA_TEST);
glAlphaFunc(GL_GREATER, 0.1);

glBindTexture(GL_TEXTURE_2D,TexTarget);

  glBegin(GL_QUADS);
    glTexCoord2f(0,0);
    glVertex2f(0,0);
    glTexCoord2f(1,0);
    glVertex2f(w,0);
    glTexCoord2f(1,1);
    glVertex2f(w,h);
    glTexCoord2f(0,1);
    glVertex2f(0,h);
   glEnd;

if TexSource<>0 then
begin
glBindTexture(GL_TEXTURE_2D,TexSource);

  glBegin(GL_QUADS);
    glTexCoord2f(0,0);
    glVertex2f(X,Y);
    glTexCoord2f(1,0);
    glVertex2f(X+W1,Y);
    glTexCoord2f(1,1);
    glVertex2f(X+W1,Y+H1);
    glTexCoord2f(0,1);
    glVertex2f(X,Y+H1);
   glEnd;
end;

glBindTexture(GL_TEXTURE_2D,0);
glDisable(GL_ALPHA_TEST);

glPopMatrix;
glMatrixMode(GL_PROJECTION);
glPopMatrix;
glMatrixMode(GL_MODELVIEW);
glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, 0, 0);
glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
glViewport(0, 0, CurW, CurH);
glPopMatrix();
glBindTexture(GL_TEXTURE_2D, 0);
glClear(GL_COLOR_BUFFER_BIT);
end;
end;
{------------------------------------------------------------------}
procedure DrawTextureToTextureTransparentColor(TexSource,TexTarget : GluInt; X,Y : integer; Color : Cardinal); stdcall;
type
TRGB = record
  R, G, B : Byte;
 end;
var c : TRGB;
pBits : pByteArray;
i,line : integer;
w, h : cardinal;
begin
w:=GetTextureInfo(TexSource).Width;
h:=GetTextureInfo(TexSource).Height;
GetMem(pBits,w*h*3);
glBindTexture(GL_TEXTURE_2D, TexSource);
glGetTexImage(GL_TEXTURE_2D,0,GL_RGB,GL_UNSIGNED_BYTE,pBits);
glBindTexture(GL_TEXTURE_2D, TexTarget);
glTexParameterf(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, 0);
line:=0;
for i:=0 to ((w*h*3) div 3)-1 do
 if not ((pBits[i*3]=GetRvalue(Color)) and (pBits[i*3+1]=GetGvalue(Color)) and (pBits[i*3+2]=GetBvalue(Color))) then
 begin
 if i-w*line > w then line:=line+1;
 c.R:=pBits[i*3];
 c.G:=pBits[i*3+1];
 c.B:=pBits[i*3+2];
 glTexSubImage2D(GL_TEXTURE_2D,0,X+(i-line*w),Y+line,1,1,GL_RGB,GL_UNSIGNED_BYTE,@c);
 end;
glBindTexture(GL_TEXTURE_2D, 0);
FreeMem(pBits);
end;
{------------------------------------------------------------------}
procedure DeactiveLight(ID : integer); stdcall;
var i : integer;
begin
if ID = -1 then
 begin
   for i:=0 to 20 do
   begin
    LightsOn[i]:=False;
    glDisable(GETLIGHT(i));
   end;
  glDisable(GL_LIGHTING);
 end else
 begin
  glDisable(GETLIGHT(ID));
  LightsOn[ID]:=FALSE;
 end;
end;
{------------------------------------------------------------------}
procedure SetLight(ID : integer; X,Y,Z : single; LightColor : integer; Radius : single; Visualize : boolean; Scale : single); stdcall;
var
Color : Array [1..4] of GLFloat;
LightPos : Array [0..3] of GLfloat;
begin

if (ID = -1) or (ID>GL_MAX_LIGHTS) then Exit;

  LightPos[0]:=X;
  LightPos[1]:=Y;
  LightPos[2]:=Z;
  LightPos[3]:=1;

  glLightfv(GETLIGHT(ID), GL_POSITION, @LightPos);

  light_diffuse[0]:=GetRValue(LightColor)/255;
  light_diffuse[1]:=GetGValue(LightColor)/255;
  light_diffuse[2]:=GetBValue(LightColor)/255;
  light_diffuse[3]:=1.0;

  light_specular[0]:=GetRValue(LightColor)/255;
  light_specular[1]:=GetGValue(LightColor)/255;
  light_specular[2]:=GetBValue(LightColor)/255;
  light_specular[3]:=1.0;

  glMaterialfv(GL_FRONT,  GL_SPECULAR, @mat_specular);

  glLightfv(GETLIGHT(ID), GL_AMBIENT,  @light_ambient);
  glLightfv(GETLIGHT(ID), GL_DIFFUSE,  @light_diffuse);
  glLightfv(GETLIGHT(ID), GL_SPECULAR, @light_specular);

  if radius<0 then
  begin
  glLightf(GETLIGHT(ID), GL_CONSTANT_ATTENUATION, 1.0);
  glLightf(GETLIGHT(ID), GL_LINEAR_ATTENUATION, 0);
  end else
  begin
  glLightf(GETLIGHT(ID), GL_CONSTANT_ATTENUATION, 0);
  glLightf(GETLIGHT(ID), GL_LINEAR_ATTENUATION, 10/radius);
  end;

if Visualize then
 begin
  glGetFloatv(GL_CURRENT_COLOR, @Color);
   glDisable(GL_LIGHTING);
   glDisable(GL_TEXTURE_2D);
   glPointSize(Scale);
   glBegin(GL_POINTS);
   glColor3f(light_diffuse[0],light_diffuse[1],light_diffuse[2]);
   glVertex3f(X,Y,Z);
   glEnd();
   glPointSize(1.0);
   glEnable(GL_TEXTURE_2D);
  glcolor4f(Color[1],Color[2],Color[3],Color[4]);
 end;

  glEnable(GL_LIGHTING);
  glEnable(GETLIGHT(ID));
  LightsOn[ID]:=TRUE;
end;
{------------------------------------------------------------------}
procedure Position3D(X,Y,Z : single); stdcall;
begin
if not In2DWeAre then
glTranslatef(x,y,z);
end;
{------------------------------------------------------------------}
procedure Scale3D(Scale : single); stdcall;
begin
glScalef(Scale,Scale,Scale);
end;
{------------------------------------------------------------------}
procedure SetTexture(Texture : gluint); stdcall;
begin
if not Projecting then
begin
 if not InBlock then CurTexture:=Texture;
 glBindTexture(GL_TEXTURE_2D, Texture);
end;
end;
{------------------------------------------------------------------}
procedure ActivateMultitexturingLayer(Layer : Cardinal); stdcall;
begin
 if GL_ARB_multitexture then
 begin
 glActiveTextureARB(GL_TEXTURE0_ARB+Layer);
 glEnable(GL_TEXTURE_2D);
 MultyTexActive:=true;
 end;
end;
{------------------------------------------------------------------}
procedure DeactiveMultytexturing; stdcall;
var i : integer;
begin
 if GL_ARB_multitexture then
 begin
  for i:=0 to 5 do
   begin
   glActiveTextureARB(GL_TEXTURE0_ARB+i);
   if i<>0 then
   glDisable(GL_TEXTURE_2D);
   SetTexture(0);
   end;
   glActiveTextureARB(GL_TEXTURE0_ARB);
 end;
end;
{------------------------------------------------------------------}
procedure Position2D(X,Y : integer); stdcall;
begin
if In2DWeAre then
glTranslatef((4.42/InitResX)*X,-(3.314/InitResY)*Y,0.0);
end;
{------------------------------------------------------------------}
procedure Color3D(Color:integer; Alpha : byte; Diffuse : boolean; MaterialShininess : single); stdcall;
begin
mat_shininess:=MaterialShininess;
glMaterialfv(GL_FRONT, GL_SHININESS, @mat_shininess);

 if Alpha<>255 then
 begin
 GlEnable(GL_Blend);

 if not Projecting then
   if not Diffuse then
     glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
      else
        glBlendFunc(GL_SRC_ALPHA, GL_ONE);

 end;

 if Alpha=254 then Alpha:=255;

glcolor4ub(GetRValue(Color),GetGValue(Color),GetBValue(Color),Alpha);

end;
{------------------------------------------------------------------}
procedure AdductingMatrix3Dto2D; stdcall;
begin
  glPushMatrix;
  glLoadIdentity;
  glTranslatef(-2.210,1.657,-4.000);
  In2DWeAre:=TRUE;
    //on screen matrix width  4.42
    //                 height 3.314
end;
{------------------------------------------------------------------}
procedure ReturnStandartMatrix3D; stdcall;
begin
  glPopMatrix;
  In2DWeAre:=FALSE;
end;
{------------------------------------------------------------------}
procedure RotateX(Angle : single); stdcall;
begin
glRotatef(Angle,-1,0,0);
end;
{------------------------------------------------------------------}
procedure RotateY(Angle : single); stdcall;
begin
glRotatef(Angle,0,-1,0);
end;
{------------------------------------------------------------------}
procedure RotateZ(Angle : single); stdcall;
begin
glRotatef(Angle,0,0,-1);
end;
{------------------------------------------------------------------}
procedure DrawLine(X,Y,Z,X1,Y1,Z1 : single; LineWidth : real = 1.0; Smooth : boolean = true); stdcall;
begin
 if Smooth then
  begin
  glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
  glEnable(GL_LINE_SMOOTH);
  glEnable(GL_BLEND);
  end;
 glLineWidth(LineWidth);
  glBegin(GL_LINES);
    glVertex3f(X,Y,Z);
    glVertex3f(X1,Y1,Z1);
  glEnd;
 if Smooth then
  begin
  glDisable(GL_LINE_SMOOTH);
  glDisable(GL_BLEND);
  end;
end;
{------------------------------------------------------------------}
procedure DrawPoint(X,Y,Z : single); stdcall;
begin
 glBegin(GL_POINTS);
    glVertex3f(X,Y,Z);
 glEnd;
end;
{------------------------------------------------------------------}
procedure EnableSphereMapping; stdcall;
begin
  glTexGenf(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
  glTexGenf(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
  glEnable(GL_TEXTURE_GEN_S);
  glEnable(GL_TEXTURE_GEN_T);
end;
{------------------------------------------------------------------}
procedure DisableSphereMapping; stdcall;
begin
 glDisable(GL_TEXTURE_GEN_S);
 glDisable(GL_TEXTURE_GEN_T);
end;
{------------------------------------------------------------------}
procedure StartRenderToTexture(Texture : GlUint); stdcall;
var
b : BYTEBOOL;
mode : Integer;
begin

  RenderTTWidth:=GetTextureInfo(Texture).Width;
  RenderTTHeight:=GetTextureInfo(Texture).Height;
  RenderedTex:=Texture;

glPushMatrix();

  glViewport(0, 0, RenderTTWidth, RenderTTHeight);

  if GetTextureInfo(Texture).FileType=5 then
  begin
  glDisable(GL_TEXTURE_2D);
  glDisable(GL_LIGHTING);
  glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
  glGetBooleanv(GL_CULL_FACE,@b);
  glGetIntegerv(GL_CULL_FACE_MODE,@mode);
  if b and (mode=GL_FRONT) then
  //glPolygonOffset(4.5, 3.25)
  glPolygonOffset(0.5, 0.25)
  else
  glPolygonOffset(5, 4);
  glEnable(GL_POLYGON_OFFSET_FILL);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(ShadowRenderAngle, RenderTTWidth/RenderTTWidth, InitZNear, InitZFar);
  glMatrixMode(GL_MODELVIEW);
  end;


  if GL_EXT_framebuffer_object and _UseFBO then
  begin
   InitFBO(RenderTTWidth,RenderTTHeight,InitZBuffer);
   glBindTexture(GL_TEXTURE_2D, 0);
   glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo_frame);
    if GetTextureInfo(RenderedTex).FileType=5 then
    begin
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_TEXTURE_2D, RenderedTex, 0);
    glDrawBuffer(GL_NONE);
    end else
    begin
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, RenderedTex, 0);
    glDrawBuffer(GL_FRONT);
    end;
   CantRenderInFBO:=false;
   if glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT) <> GL_FRAMEBUFFER_COMPLETE_EXT then
   begin
   CantRenderInFBO:=true;
   glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
   end;

  end;

 glLoadIdentity();
 if GetTextureInfo(RenderedTex).FileType=5 then
 glClear(GL_DEPTH_BUFFER_BIT)
 else
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

end;
{------------------------------------------------------------------}
procedure EndRenderToTexture; stdcall;
var i : integer;
begin


   if GL_EXT_framebuffer_object and _UseFBO and not CantRenderInFBO then
   begin
   if GetTextureInfo(RenderedTex).FileType=5 then
   glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_TEXTURE_2D, 0, 0)
   else
   glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, 0, 0);
   glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
   end else
   begin
   glBindTexture(GL_TEXTURE_2D, RenderedTex);
   if GetTextureInfo(RenderedTex).FileType=5 then
   glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, 0, 0, RenderTTWidth, RenderTTHeight, 0)
   else
   glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, RenderTTWidth, RenderTTHeight, 0);
   end;

   glViewport(0, 0, CurW, CurH);


   if GetTextureInfo(RenderedTex).FileType=5 then
   begin
    for i:=0 to 20 do
      if LightsOn[i] then glEnable(GL_LIGHTING);
   glEnable(GL_TEXTURE_2D);
   glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
   glDisable(GL_POLYGON_OFFSET_FILL);
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity;
   gluPerspective(initAngle, CurW/CurH, InitZNear, InitZFar);
   glMatrixMode(GL_MODELVIEW);
   end;

glPopMatrix();
glBindTexture(GL_TEXTURE_2D, 0);
if GetTextureInfo(RenderedTex).FileType=5 then
glClear(GL_DEPTH_BUFFER_BIT)
else
glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
end;
{------------------------------------------------------------------}
procedure DrawAxes(Length : single = 1.0); stdcall;
var
Color : Array [1..4] of GLFloat;
begin
 glGetFloatv(GL_CURRENT_COLOR, @Color);

glBegin (GL_LINES);
 glColor3f(1,0,0);
 glVertex3f(0,0,0);
 glVertex3f(Length,0,0);
 glColor3f(0,1,0);
 glVertex3f(0,0,0);
 glVertex3f(0,Length,0);
 glColor3f(0,0,1);
 glVertex3f(0,0,0);
 glVertex3f(0,0,Length);
glEnd;

 glcolor4f(Color[1],Color[2],Color[3],Color[4]);
end;
{------------------------------------------------------------------}
procedure DrawCube(Width,Height,Depth : single); stdcall;
begin
glPushMatrix();
    glScalef(Width,Height,Depth);
    glBegin(GL_QUADS);
      // Front Face
      glNormal3f( 0.0, 0.0, 1.0);
      _glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);
      _glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);
      _glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0,  1.0);
      _glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0,  1.0);
      // Back Face
      glNormal3f( 0.0, 0.0,-1.0);
      _glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0, -1.0);
      _glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);
      _glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);
      _glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0, -1.0);
      // Top Face
      glNormal3f( 0.0, 1.0, 0.0);
      _glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);
      _glTexCoord2f(0.0, 0.0); glVertex3f(-1.0,  1.0,  1.0);
      _glTexCoord2f(1.0, 0.0); glVertex3f( 1.0,  1.0,  1.0);
      _glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);
      // Bottom Face
      glNormal3f( 0.0,-1.0, 0.0);
      _glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, -1.0, -1.0);
      _glTexCoord2f(0.0, 1.0); glVertex3f( 1.0, -1.0, -1.0);
      _glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);
      _glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);
      // Right face
      glNormal3f( 1.0, 0.0, 0.0);
      _glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0, -1.0);
      _glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);
      _glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0,  1.0);
      _glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);
      // Left Face
      glNormal3f(-1.0, 0.0, 0.0);
      _glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, -1.0);
      _glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);
      _glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0,  1.0);
      _glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);
    glEnd();
glPopMatrix();
end;

end.
