//----------------------------------------------------------------------------//
//DRON's OpenGl Engine V 1.0 http://dronprogs.mirgames.ru                     //
//                                                                            //
// Draw3DUtils.pas V 1.0, 15.01.2006; 13:51                                   //
//                                                                            //
// This module provides some advanced 3D drawing routines and effects.        //
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
unit Advanced3D;

interface
uses OpenGl, Graphics, Windows, Variables, VFW, Textures, SysUtils, EngineUtils,
TFrustumClass, DrawFunc3D, Classes;

type

  TShader = record
            target, glident, uid : cardinal;
            end;

  TFontSize3D  = record
                 fBoxX, fBoxY : single;
                 end;

  TFont3D = record
            List : glUint;
            gFontSizes      : array[0..1023] of TFontSize3D;
            end;

  TAvi = record
           Loaded : boolean;
           VidTexture : glUint;

           AVIFile    : PAviFile;
           AVIStream  : PAviStream;
           AVIInfo    : TAVIFileInfo;
           StreamInfo : TAVIStreamInfo;

           ActiveFrame : Integer;
           AVIStart    : DWord;
           AVILength   : DWord;
           FrameData   : Pointer;
           GetFramePointer : Pointer;
         end;

function  CreateFont3D(const Fontname : string):integer; stdcall;
procedure Write3D(FontIdent: integer; Text: string); stdcall;
function  StartWriteToVideoMemory : cardinal; stdcall;
procedure EndWriteToVideoMemory; stdcall;
procedure FreeFromVideoMemory(Ident : integer); stdcall;
procedure DrawFromVM(Ident : integer); stdcall;
function  CreateAVITexture(Filename : string) : integer; stdcall;
procedure FreeAVITexture(index : integer); stdcall;
function  SetAviTexture(index : integer) : GLUInt stdcall;
procedure SetupProjector; stdcall;
procedure DisableProjector; stdcall;
procedure RenderProjection(ProjectTexture : GluInt; DrawScene : pointer; ProjectorOrientation: TCamera; Diffuse : boolean = false); stdcall;
procedure RenderProjectedTexture(ProjectTexture : GluInt; ProjectorOrientation: TCamera; Diffuse : boolean = false); stdcall;
procedure PrepareSceneForProjecting; stdcall;
procedure EndDrawingProjectedScene; stdcall;
function  Get3DPos : TVertex;  stdcall;
function  Get2DPos(Vertex : TVertex) : TPoint; stdcall;
procedure CastShadowMap(Texture : Cardinal; LightCamera : TCamera); stdcall;
procedure SetShadowRenderAngle(Angle : cardinal); stdcall;
function  Get3DPosFree(px,py:integer): TVertex; stdcall;
function  LoadShader(target: Cardinal; shader: string): Cardinal; stdcall;
procedure FreeShader(Ident : cardinal); stdcall;
procedure SetShader(Ident : integer); stdcall;
procedure GiveShaderParams(Ident, Index : cardinal; v : TVertex; w : single); stdcall;
procedure GiveVShaderTexProjectMatrix(VShader, StartIdx, Texture : Cardinal; Projector : TCamera); stdcall;

var
 Fonts3D : array of TFont3D;
 FontsCount : integer = 0;
 Avis    : array of TAvi;
 AvisCount : integer = 0;
 ShadowMatrix  : Array[0..15] of glFloat;
 Projecting : boolean = false;
 ShadowRenderAngle : cardinal = 90;
 MoveXcoord, MoveYcoord : GLfloat;

 Shaders : array of TShader;
 ShadersCount : cardinal = 0;
 OverallCount : cardinal = 0;

procedure SetClipPlane(PlaneMum : cardinal; Camera : TCamera); stdcall;

implementation

const
  PS: array [0..3] of GLfloat = (1, 0, 0, 0);
  PT: array [0..3] of GLfloat = (0, 1, 0, 0);
  PR: array [0..3] of GLfloat = (0, 0, 1, 0);
  PQ: array [0..3] of GLfloat = (0, 0, 0, 1);

{------------------------------------------------------------------}
procedure GiveShaderParams(Ident, Index : cardinal; v : TVertex; w : single); stdcall;
var
i : integer;
begin
if ShadersCount>0 then
  for i := 0 to ShadersCount - 1 do
    if Ident=Shaders[i].uid then
    begin
      glProgramLocalParameter4fARB(Shaders[i].target,Index,v.X,v.Y,v.Z,w);
      Exit;
    end;
end;
{------------------------------------------------------------------}
procedure FreeShader(Ident : cardinal); stdcall;
var i : integer;
t : TShader;
begin
  if ShadersCount>0 then
  for i := 0 to ShadersCount - 1 do
  if Ident=Shaders[i].uid then
  begin
    glDeleteProgramsARB(1,@Shaders[i].glident);
    if ShadersCount>1 then
    begin
     t:=Shaders[ShadersCount-1];
     Shaders[i]:=t;
    end;
    SetLength(Shaders,ShadersCount-1);
    ShadersCount:=ShadersCount-1;
    Exit;
  end;
end;
{------------------------------------------------------------------}
procedure SetShader(Ident : integer); stdcall;
var i : integer;
begin
 case ident of
 -3: begin
      glDisable(GL_VERTEX_PROGRAM_ARB);
      glDisable(GL_FRAGMENT_PROGRAM_ARB);
     end;
 -2: glDisable(GL_VERTEX_PROGRAM_ARB);
 -1: glDisable(GL_FRAGMENT_PROGRAM_ARB);
 else
 if ShadersCount>0 then
   for i := 0 to ShadersCount - 1 do
    if Ident=Shaders[i].uid then
     begin
      glEnable(Shaders[i].target);
      glBindProgramARB(Shaders[i].target, Shaders[i].glident);
      Exit;
     end;
 end;
end;
{------------------------------------------------------------------}
function LoadShader(target: Cardinal; shader : string): Cardinal; stdcall;
var
  err: String;
  i: GLint;
  s: GLuint;
begin
if (GL_ARB_fragment_program and (GL_FRAGMENT_PROGRAM_ARB = target))
or (GL_ARB_vertex_program and (GL_VERTEX_PROGRAM_ARB = target)) then
begin

  OverallCount:=OverallCount+1;
  ShadersCount:=ShadersCount+1;
  SetLength(Shaders,ShadersCount);
  Shaders[ShadersCount-1].target:=target;
  Shaders[ShadersCount-1].uid:=OverallCount;

  glGenProgramsARB(1, @s);
  glBindProgramARB(target, s);
  glProgramStringARB(target, GL_PROGRAM_FORMAT_ASCII_ARB, Length(shader), PChar(shader));

  err := PChar(glGetString(GL_PROGRAM_ERROR_STRING_ARB));
  if err <> '' then
  begin
    glGetIntegerv(GL_PROGRAM_ERROR_POSITION_ARB, @i);
    MessageBox(0, PChar('Shader program contains errors:' + #10#10 + err +
    #10#10 + ' (pos '+IntToStr(i)+')'), PChar('Shader Unit'), MB_OK or MB_ICONERROR);
    AddToLogFile(EngineLog,'Shader program contains errors:' + #10#10 + err +
    #10#10 + ' (pos '+IntToStr(i)+')');
  end;

  Shaders[ShadersCount-1].glident:=s;
  Result := Shaders[ShadersCount-1].uid;
end else
  result:=0;
end;
{------------------------------------------------------------------}
procedure SetShadowRenderAngle(Angle : cardinal); stdcall;
begin
ShadowRenderAngle:=Angle;
end;
{------------------------------------------------------------------}
procedure GiveVShaderTexProjectMatrix(VShader, StartIdx, Texture : Cardinal; Projector : TCamera); stdcall;
{Че то с ней не то, тестовая ф-я исключительно}
procedure mult_m(m1,m2 : array of GLfloat; var m : array of GLfloat);
begin
		m[0] := m1[0]*m2[0] + m1[4]*m2[1] + m1[8]*m2[2] + m1[12]*m2[3];
		m[1] := m1[1]*m2[0] + m1[5]*m2[1] + m1[9]*m2[2] + m1[13]*m2[3];
		m[2] := m1[2]*m2[0] + m1[6]*m2[1] + m1[10]*m2[2] + m1[14]*m2[3];
		m[3] := m1[3]*m2[0] + m1[7]*m2[1] + m1[11]*m2[2] + m1[15]*m2[3];

		m[4] := m1[0]*m2[4] + m1[4]*m2[5] + m1[8]*m2[6] + m1[12]*m2[7];
		m[5] := m1[1]*m2[4] + m1[5]*m2[5] + m1[9]*m2[6] + m1[13]*m2[7];
		m[6] := m1[2]*m2[4] + m1[6]*m2[5] + m1[10]*m2[6] + m1[14]*m2[7];
		m[7] := m1[3]*m2[4] + m1[7]*m2[5] + m1[11]*m2[6] + m1[15]*m2[7];

		m[8] := m1[0]*m2[8] + m1[4]*m2[9] + m1[8]*m2[10] + m1[12]*m2[11];
		m[9] := m1[1]*m2[8] + m1[5]*m2[9] + m1[9]*m2[10] + m1[13]*m2[11];
		m[10]:= m1[2]*m2[8] + m1[6]*m2[9] + m1[10]*m2[10] + m1[14]*m2[11];
		m[11]:= m1[3]*m2[8] + m1[7]*m2[9] + m1[11]*m2[10] + m1[15]*m2[11];

		m[12]:= m1[0]*m2[12] + m1[4]*m2[13] + m1[8]*m2[14] + m1[12]*m2[15];
		m[13]:= m1[1]*m2[12] + m1[5]*m2[13] + m1[9]*m2[14] + m1[13]*m2[15];
		m[14]:= m1[2]*m2[12] + m1[6]*m2[13] + m1[10]*m2[14] + m1[14]*m2[15];
		m[15]:= m1[3]*m2[12] + m1[7]*m2[13] + m1[11]*m2[14] + m1[15]*m2[15];
end;
var proj_matrix, temp, model_matrix,res_matrix, half_matrix : array [0..15] of GLfloat;
begin
if GL_ARB_vertex_program then
begin
  glBindTexture(GL_TEXTURE_2D,Texture);

  glMatrixMode(GL_PROJECTION);
  glPushMatrix();
   glLoadIdentity();
   if GetTextureInfo(Texture).FileType=5 then
   gluPerspective(ShadowRenderAngle, GetTextureInfo(Texture).Width/GetTextureInfo(Texture).Height, InitZNear, InitZFar)
   else
   gluPerspective(initAngle, GetTextureInfo(Texture).Width/GetTextureInfo(Texture).Height, InitZNear, InitZFar);
	 glGetFloatv(GL_PROJECTION_MATRIX,@proj_matrix);
  glPopMatrix();

  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
   glLoadIdentity();
   gluLookAt(Projector.Eye.X,Projector.Eye.Y,Projector.Eye.Z,Projector.Center.X,Projector.Center.Y,Projector.Center.Z,0,1,0);
 	 glGetFloatv(GL_MODELVIEW_MATRIX,@model_matrix);
  glPopMatrix();

  half_matrix[0]:=0.5;
  half_matrix[1]:=0;
  half_matrix[2]:=0;
  half_matrix[3]:=0;
  half_matrix[4]:=0;
  half_matrix[5]:=0.5;
  half_matrix[6]:=0;
  half_matrix[7]:=0;
  half_matrix[8]:=0;
  half_matrix[9]:=0;
  half_matrix[10]:=0.5;
  half_matrix[11]:=0;
  half_matrix[12]:=0.5;
  half_matrix[13]:=0.5;
  half_matrix[14]:=0.5;
  half_matrix[15]:=1.0;

  mult_m(half_matrix,proj_matrix,temp);

  mult_m(temp,model_matrix,res_matrix);

  glProgramLocalParameter4fARB(GL_VERTEX_PROGRAM_ARB,StartIdx,  res_matrix[0], res_matrix[4], res_matrix[8], res_matrix[12]);
  glProgramLocalParameter4fARB(GL_VERTEX_PROGRAM_ARB,StartIdx+1,res_matrix[1], res_matrix[5], res_matrix[9], res_matrix[13]);
  glProgramLocalParameter4fARB(GL_VERTEX_PROGRAM_ARB,StartIdx+2,res_matrix[2], res_matrix[6], res_matrix[10],res_matrix[14]);
  glProgramLocalParameter4fARB(GL_VERTEX_PROGRAM_ARB,StartIdx+3,res_matrix[3], res_matrix[7], res_matrix[11],res_matrix[15]);

end;
end;
{------------------------------------------------------------------}
procedure CastShadowMap(Texture : Cardinal; LightCamera : TCamera); stdcall;
begin
if (GL_ARB_shadow) and (GetTextureInfo(Texture).FileType=5) then
begin
 glPushMatrix();

  glBindTexture(GL_TEXTURE_2D, Texture);

  glEnable(GL_TEXTURE_GEN_S);
  glEnable(GL_TEXTURE_GEN_T);
  glEnable(GL_TEXTURE_GEN_R);
  glEnable(GL_TEXTURE_GEN_Q);
  glTexGenfv(GL_S, GL_EYE_PLANE, @PS);
  glTexGenfv(GL_T, GL_EYE_PLANE, @PT);
  glTexGenfv(GL_R, GL_EYE_PLANE, @PR);
  glTexGenfv(GL_Q, GL_EYE_PLANE, @PQ);

   glMatrixMode(GL_TEXTURE);
   glLoadIdentity;
    glTranslatef(0.5, 0.5, 0.5);
    glScalef(0.5, 0.5, 0.5);
    gluPerspective(ShadowRenderAngle, GetTextureInfo(Texture).Width/GetTextureInfo(Texture).Width, InitZNear, InitZFar);
    SetCamera(LightCamera);
  glMatrixMode(GL_MODELVIEW);
end;
end;
{------------------------------------------------------------------}
function  Get3DPosFree (px,py:integer): TVertex; stdcall;
var
	viewp  : TGLVectori4;
	modelM : TGLMatrixd4;
	projectM: TGLMatrixd4;
  res       : array[0..2] of GLDouble;
	winZ,winY : Single;
begin
	winZ:=0;

  glGetDoublev(GL_MODELVIEW_MATRIX, @modelM );
	glGetDoublev(GL_PROJECTION_MATRIX, @projectM );
	glGetIntegerv(GL_VIEWPORT, @viewp );

  winY := viewp[3]-py-1;

	glReadPixels(px, Round(winY), 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, @winZ );
	gluUnProject(px, winY, winZ, modelM, projectM, viewp, @Res[0], @Res[1], @Res[2]);

  result.X:=Res[0];
  result.Y:=Res[1];
  result.Z:=Res[2];


end;
{------------------------------------------------------------------}
function Get3DPos : TVertex;  stdcall;
var
	viewp  : TGLVectori4;
	modelM : TGLMatrixd4;
	projectM: TGLMatrixd4;
  res       : array[0..2] of GLDouble;
	winZ,winY : Single;
begin
	winZ:=0;

  glGetDoublev(GL_MODELVIEW_MATRIX, @modelM );
	glGetDoublev(GL_PROJECTION_MATRIX, @projectM );
	glGetIntegerv(GL_VIEWPORT, @viewp );

  winY := viewp[3] - round(MoveYcoord) - 1;

	glReadPixels(round(MoveXcoord), Round(winY), 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, @winZ );
	gluUnProject(round(MoveXcoord), winY, winZ, modelM, projectM, viewp, @Res[0], @Res[1], @Res[2]);

  result.X:=Res[0];
  result.Y:=Res[1];
  result.Z:=Res[2];
end;
{------------------------------------------------------------------}
function Get2DPos(Vertex : TVertex) : TPoint; stdcall;
var
	viewp  : TGLVectori4;
	modelM : TGLMatrixd4;
	projectM: TGLMatrixd4;
	winZ,winY, WinX : GLdouble;
  coord : array [0..2] of GLDouble;
begin
  glGetDoublev(GL_MODELVIEW_MATRIX, @modelM );
	glGetDoublev(GL_PROJECTION_MATRIX, @projectM );
	glGetIntegerv(GL_VIEWPORT, @viewp );

  coord[0]:=Vertex.X;
  coord[1]:=Vertex.Y;
  coord[2]:=Vertex.Z;

  gluProject(coord[0],coord[1],coord[2],modelM, projectM, viewp,@winX,@winY,@winZ);

  result.X:=round(WinX);
  result.Y:=viewp[3] - round(WinY) - 1;
end;
{------------------------------------------------------------------}
procedure SetClipPlane(PlaneMum : cardinal; Camera : TCamera); stdcall;
var
len : GLDouble;
Plane : array [0..3] of GLDouble;
begin
  Plane[0]:=-(Camera.Eye.X-Camera.Center.X);
  Plane[1]:=-(Camera.Eye.Y-Camera.Center.Y);
  Plane[2]:=-(Camera.Eye.Z-Camera.Center.Z);

  len:=sqrt(Plane[0]*Plane[0]+Plane[1]*Plane[1]+Plane[2]*Plane[2]);

  Plane[0]:=Plane[0]/len;
  Plane[1]:=Plane[1]/len;
  Plane[2]:=Plane[2]/len;

  Plane[3]:=-(Plane[0]*Camera.Eye.X + Plane[1]*Camera.Eye.Y + Plane[2]*Camera.Eye.Z);

  glClipPlane(GL_CLIP_PLANE0+PlaneMum,@Plane);
  glEnable(GL_CLIP_PLANE0+PlaneMum);
end;
{------------------------------------------------------------------}
procedure DisableProjector; stdcall;
begin
glPopMatrix();
glDisable(GL_TEXTURE_GEN_S);
glDisable(GL_TEXTURE_GEN_T);
glDisable(GL_TEXTURE_GEN_R);
glDisable(GL_TEXTURE_GEN_Q);

  glMatrixMode(GL_TEXTURE);
  glLoadIdentity;
  glMatrixMode(GL_MODELVIEW);

glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
glDisable(GL_BLEND);
glDisable(GL_CLIP_PLANE0);
if GetTextureInfo(CurTexture).FileType=5 then glDisable(GL_ALPHA_TEST);
glBindTexture(GL_TEXTURE_2D, 0);
Projecting:=false;
end;
{------------------------------------------------------------------}
procedure PrepareSceneForProjecting; stdcall;
begin
glTexGenfv(GL_S, GL_EYE_PLANE, @PS);
glTexGenfv(GL_T, GL_EYE_PLANE, @PT);
glTexGenfv(GL_R, GL_EYE_PLANE, @PR);
glTexGenfv(GL_Q, GL_EYE_PLANE, @PQ);

glBlendFunc(GL_ONE, GL_ZERO);
glDisable(GL_TEXTURE_GEN_S);
glDisable(GL_TEXTURE_GEN_T);
glDisable(GL_TEXTURE_GEN_R);
glDisable(GL_TEXTURE_GEN_Q);
glEnable(GL_LIGHTING);

 glMatrixMode(GL_TEXTURE);
  glPushMatrix;
  glLoadIdentity;
 glMatrixMode(GL_MODELVIEW);
end;
{------------------------------------------------------------------}
procedure EndDrawingProjectedScene; stdcall;
begin
 glMatrixMode(GL_TEXTURE);
   glPopMatrix;
 glMatrixMode(GL_MODELVIEW);
end;
{------------------------------------------------------------------}
procedure RenderProjectedTexture(ProjectTexture : GluInt; ProjectorOrientation: TCamera; Diffuse : boolean = false); stdcall;
begin
 glDisable(GL_LIGHTING);
 glEnable(GL_TEXTURE_GEN_S);
 glEnable(GL_TEXTURE_GEN_T);
 glEnable(GL_TEXTURE_GEN_R);
 glEnable(GL_TEXTURE_GEN_Q);

 if Diffuse then
 glBlendFunc(GL_DST_COLOR, GL_SRC_COLOR) else
 glBlendFunc(GL_SRC_ALPHA, GL_ONE);

 glBindTexture(GL_TEXTURE_2D, ProjectTexture);
 Projecting:=true;

  glMatrixMode(GL_TEXTURE);
    glPopMatrix;
    glPushMatrix;
  SetCamera(ProjectorOrientation);
  glMatrixMode(GL_MODELVIEW);

  SetClipPlane(0,ProjectorOrientation);
end;
{------------------------------------------------------------------}
procedure RenderProjection(ProjectTexture : GluInt; DrawScene : pointer; ProjectorOrientation: TCamera; Diffuse : boolean = false); stdcall;
var proc : procedure;
begin
@proc:=DrawScene;
glPushMatrix();

glTexGenfv(GL_S, GL_EYE_PLANE, @PS);
glTexGenfv(GL_T, GL_EYE_PLANE, @PT);
glTexGenfv(GL_R, GL_EYE_PLANE, @PR);
glTexGenfv(GL_Q, GL_EYE_PLANE, @PQ);

glBlendFunc(GL_ONE, GL_ZERO);
glDisable(GL_TEXTURE_GEN_S);
glDisable(GL_TEXTURE_GEN_T);
glDisable(GL_TEXTURE_GEN_R);
glDisable(GL_TEXTURE_GEN_Q);
glEnable(GL_LIGHTING);

 glMatrixMode(GL_TEXTURE);
  glPushMatrix;
  glLoadIdentity;
 glMatrixMode(GL_MODELVIEW);

 proc;

 glMatrixMode(GL_TEXTURE);
   glPopMatrix;
 glMatrixMode(GL_MODELVIEW);

 glDisable(GL_LIGHTING);
 glEnable(GL_TEXTURE_GEN_S);
 glEnable(GL_TEXTURE_GEN_T);
 glEnable(GL_TEXTURE_GEN_R);
 glEnable(GL_TEXTURE_GEN_Q);

 if Diffuse then
 glBlendFunc(GL_DST_COLOR, GL_SRC_COLOR) else
 glBlendFunc(GL_SRC_ALPHA, GL_ONE);

 SetTexture(ProjectTexture);
 Projecting:=true;

  glMatrixMode(GL_TEXTURE);
    glPopMatrix;
    glPushMatrix;
  SetCamera(ProjectorOrientation);
  glMatrixMode(GL_MODELVIEW);

  SetClipPlane(0,ProjectorOrientation);

  proc;

glPopMatrix();
end;
{------------------------------------------------------------------}
procedure SetupProjector; stdcall;
begin
  glEnable(GL_BLEND);

  glEnable(GL_TEXTURE_GEN_S);
  glEnable(GL_TEXTURE_GEN_T);
  glEnable(GL_TEXTURE_GEN_R);
  glEnable(GL_TEXTURE_GEN_Q);

  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR);
  glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR);
  glTexGeni(GL_R, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR);
  glTexGeni(GL_Q, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR);

  glMatrixMode(GL_TEXTURE);
  glLoadIdentity;
  glTranslatef(0.5, 0.5, 0);
  glScalef(0.5, 0.5, 1);

  gluPerspective(initAngle, 1.0, InitZNear, InitZfar);

  glMatrixMode(GL_MODELVIEW);

end;
{------------------------------------------------------------------}
procedure FreeAVITexture(index : integer); stdcall;
begin
  AVIStreamRelease(Avis[index].AVIStream);
  AVIFileClose(Avis[index].AVIFile);
  AVIFileExit;
  glDeletetextures(1,@Avis[index].VidTexture);
  Avis[index].Loaded:=false;
end;
{------------------------------------------------------------------}
function SetAviTexture(index : integer) : GLUInt stdcall;
 procedure SwapRGB(data : Pointer; size : Integer);
 asm
   mov ebx, eax    // data
   mov ecx, edx    // Size

 @@loop :
   mov al,[ebx+0]  // Red						// Loads Value At ebx Into al
   mov ah,[ebx+2]  // Blue					// Loads Value At ebx+2 Into ah
   mov [ebx+2],al										// Stores Value In al At ebx+2
   mov [ebx+0],ah										// Stores Value In ah At ebx

   add ebx,3										   	// Moves Through The Data By 3 Bytes
   dec ecx											  	// Decreases Our Loop Counter
   jnz @@loop
 end;
var Frame : Integer;
    AVIElapsedTime : DWord;
    BMP : ^TBITMAPINFOHEADER;
begin
 glBindTexture(GL_TEXTURE_2D, Avis[index].VidTexture);

  AVIElapsedTime :=GetTickCount() - Avis[index].AVIStart;
  if AVIElapsedTime > Avis[index].AVILength-1 then
  begin
    Avis[index].AVIStart :=GetTickCount();
    AVIElapsedTime :=0;
  end;

  Frame :=AVIStreamTimeToSample(Avis[index].AVIStream, AVIElapsedTime);
  if Frame <> Avis[index].ActiveFrame then
  begin
    Avis[index].ActiveFrame :=Frame;

    BMP := AVIStreamGetFrame(Avis[index].GetFramePointer, frame);
    Avis[index].FrameData := Pointer(Cardinal(BMP) + BMP.biSize + BMP.biClrUsed*sizeof(RGBQUAD));

    DrawDibDraw(0, H_DC, 0, 0, Avis[index].AviInfo.dwWidth, Avis[index].AviInfo.dwHeight, @BMP, Avis[index].FrameData, 0, 0, Avis[index].AVIInfo.dwWidth, Avis[index].AVIInfo.dwHeight, 0);

    SwapRGB(Avis[index].FrameData, Avis[index].AviInfo.dwWidth*Avis[index].AviInfo.dwHeight);

    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, Avis[index].AviInfo.dwWidth, Avis[index].AviInfo.dwHeight, GL_RGB, GL_UNSIGNED_BYTE, Avis[index].Framedata);

    result:=Avis[index].VidTexture;

  end;
end;
{------------------------------------------------------------------}
function CreateAVITexture(Filename : string) : integer; stdcall;
begin
if fileexists(filename) then
begin
result:=0;
inc(AvisCount);
SetLength(Avis,AvisCount);

AVIFileInit;

  if AVIFileOpen(Avis[AvisCount-1].AviFile, PChar(FileName), OF_READ or OF_SHARE_DENY_WRITE, nil) = 0 then
  begin
    AVIFileInfo(Avis[AvisCount-1].AVIFile, @Avis[AvisCount-1].AVIInfo, SizeOf(Avis[AvisCount-1].AviInfo));
    AVIStreamOpenFromFile(Avis[AvisCount-1].AVIStream, PChar(FileName), streamtypeVIDEO, 0, OF_READ, nil);
    AVIStreamInfo(Avis[AvisCount-1].AVIStream, @Avis[AvisCount-1].StreamInfo, SizeOf(Avis[AvisCount-1].StreamInfo));
    Avis[AvisCount-1].AVILength :=AVIStreamLengthTime(Avis[AvisCount-1].AVIStream);
    GetMem(Avis[AvisCount-1].FrameData, Avis[AvisCount-1].AVIInfo.dwWidth*Avis[AvisCount-1].AVIInfo.dwHeight*3);

    Avis[AvisCount-1].GetFramePointer :=AVIStreamGetFrameOpen(Avis[AvisCount-1].AVIStream, nil);

    Avis[AvisCount-1].VidTexture :=CreateTexture(Avis[AvisCount-1].AviInfo.dwWidth, Avis[AvisCount-1].AviInfo.dwHeight, GL_RGB, Avis[AvisCount-1].FrameData);
    Avis[AvisCount-1].ActiveFrame :=-1;
    Avis[AvisCount-1].AVIStart :=GetTickCount();
    Avis[AvisCount-1].Loaded:=true;
    result:=AvisCount-1;
  end
  else
  begin
  MessageBox(0, 'Failed To Open The AVI Stream!', 'Error', MB_OK OR  MB_ICONEXCLAMATION);
  AddToLogFile(EngineLog,'Failed To Open The AVI Stream!');
  end;
end else AddToLogFile(EngineLog,'File "'+ Filename +'" not found!');
end;
{------------------------------------------------------------------}
function StartWriteToVideoMemory : cardinal; stdcall;
begin
result := glGenLists(1);
glNewList(result, GL_COMPILE);
end;
{------------------------------------------------------------------}
procedure EndWriteToVideoMemory; stdcall;
begin
glEndList();
end;
{------------------------------------------------------------------}
procedure FreeFromVideoMemory(Ident : integer); stdcall;
begin
glDeleteLists(Ident,1);
end;
{------------------------------------------------------------------}
procedure DrawFromVM(Ident : integer); stdcall;
begin
glCallList(Ident);
end;
{------------------------------------------------------------------}
procedure Write3D(FontIdent: integer; Text: string); stdcall;
var
  i  : integer;
  lX : single;
begin
 lX:=0;
    for i:= 1 to Length(Text) do lX:=lX-Fonts3D[FontIdent].gFontSizes[Ord(Text[i])].fBoxX;
    lx:=lx/1.5;

  glPushMatrix();

    glTranslatef(lX, 0, 0);

    glEnable(GL_TEXTURE_GEN_S);
    glEnable(GL_TEXTURE_GEN_T);

      glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
      glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);

      glListBase(Fonts3D[FontIdent].List);

      glCallLists(Length(Text),GL_UNSIGNED_BYTE,@Text[1]);

    glDisable(GL_TEXTURE_GEN_S);
    glDisable(GL_TEXTURE_GEN_T);

  glPopMatrix();
end;
{------------------------------------------------------------------}
function CreateFont3D(const Fontname : string):integer; stdcall;
var
  lFont : TFont;
begin
  lFont:= TFont.Create();

  lFont.Name:= Fontname;

  SelectObject(h_DC, lFont.Handle);

  inc(Fontscount);
   SetLength(Fonts3D,Fontscount);
   result:=Fontscount-1;


  Fonts3D[result].List:= glGenLists(256);
  wglUseFontOutlines(h_DC,0,256,Fonts3D[result].List,0.0,0.2,WGL_FONT_POLYGONS,@Fonts3D[result].gFontSizes);

  lFont.Free();

end;

end.
