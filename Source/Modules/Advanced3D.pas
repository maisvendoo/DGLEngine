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
TFrustumClass, DrawFunc3D;

type
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

var
 Fonts3D : array of TFont3D;
 FontsCount : integer = 0;
 Avis    : array of TAvi;
 AvisCount : integer = 0;
 ShadowMatrix  : Array[0..15] of glFloat;
 Projecting : boolean = false;
 ShadowRenderAngle : cardinal = 90;
 MoveXcoord, MoveYcoord : GLfloat;


procedure SetClipPlane(PlaneMum : cardinal; Camera : TCamera); stdcall;

implementation

const
  PS: array [0..3] of GLfloat = (1, 0, 0, 0);
  PT: array [0..3] of GLfloat = (0, 1, 0, 0);
  PR: array [0..3] of GLfloat = (0, 0, 1, 0);
  PQ: array [0..3] of GLfloat = (0, 0, 0, 1);

{------------------------------------------------------------------}
procedure SetShadowRenderAngle(Angle : cardinal); stdcall;
begin
ShadowRenderAngle:=Angle;
end;
{------------------------------------------------------------------}
procedure CastShadowMap(Texture : Cardinal; LightCamera : TCamera); stdcall;
begin
if (GL_ARB_shadow) and (GetTextureInfo(Texture).FileType=5) then
begin
 {
 C = C0*C1 + —0*C2*(1 - C1)
 C - output color
 C0 - diffuse texture color (обычна€ текстура)
 C2 - кака€-то константа(прозрачность shadow map)
 C1 - shadow - 0 или 1(т.е. результат сравнени€ глубины фрамента с глубиной
 записаной в shadow map)
  }
  //C = C0*C1 + C2*(1 - C1)
   { glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE_ARB );
    glTexEnvi( GL_TEXTURE_ENV, GL_COMBINE_RGB_ARB, GL_INTERPOLATE_ARB );

    glTexEnvi( GL_TEXTURE_ENV, GL_SOURCE0_RGB_ARB, GL_PREVIOUS_ARB );
    glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND0_RGB_ARB, GL_SRC_COLOR );

    glTexEnvi( GL_TEXTURE_ENV, GL_SOURCE1_RGB_ARB, GL_PRIMARY_COLOR_ARB);
    glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND1_RGB_ARB, GL_SRC_COLOR );

    glTexEnvi( GL_TEXTURE_ENV, GL_SOURCE2_RGB_ARB, GL_TEXTURE);
    glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND2_RGB_ARB, GL_SRC_COLOR);
  }
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
    gluPerspective(ShadowRenderAngle, GetTextureInfo(Texture).Width/GetTextureInfo(Texture).Width, 1, 500);
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

  gluPerspective(initAngle, 1, 1, 1000);

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
