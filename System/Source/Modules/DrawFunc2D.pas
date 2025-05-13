//----------------------------------------------------------------------------//
//DRON's OpenGl Engine V 1.0 http://dronprogs.mirgames.ru                     //
//                                                                            //
// GLDrawFunc.pas V 1.0, 27.01.2006; 14:40                                    //
//                                                                            //
// This module provides all 2D graphics routines.                             //
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
unit DrawFunc2D;
interface
uses OpenGl,Variables, Windows, EngineUtils, DrawFunc3D;

type TColorVertex2D = record X,Y,Color, Alpha : integer; end;

procedure Begin2D; stdcall;
procedure End2D; stdcall;
procedure DrawTexture2D_Simple(Texture : TGLUint; X , Y, FrameWidth, FrameHeight : integer; FlipX : boolean = false; FlipY : boolean = false); stdcall;
procedure DrawTexture2D(Texture : TGLUint; X , Y, FrameWidth, FrameHeight, Angle, Alpha, Color : integer; Diffuse : boolean = false; FlipX : boolean = false; FlipY : boolean = false); stdcall;
procedure DrawTexture2D_VertexColor(Texture : TGLUint; X , Y, FrameWidth, FrameHeight,Angle, Color1, Color2, Color3, Color4, Alpha1, Alpha2, Alpha3, Alpha4 : integer; FlipX : boolean = false; FlipY : boolean = false); stdcall;
procedure DrawSprite2D_Simple(Texture : TGLUint; X , Y, FrameWidth, FrameHeight,FramesXCount, FramesYCount, FrameNumber: integer; FlipX : boolean = false; FlipY : boolean = false); stdcall;
procedure DrawSprite2D(Texture : TGLUint; X , Y, FrameWidth, FrameHeight,FramesXCount, FramesYCount, FrameNumber, Angle, Alpha, Color : integer; Diffuse : boolean = false; FlipX : boolean = false; FlipY : boolean = false); stdcall;
procedure DrawSprite2D_VertexColor(Texture : TGLUint; X , Y, FrameWidth, FrameHeight,FramesXCount, FramesYCount, FrameNumber, Angle, Color1, Color2, Color3, Color4, Alpha1, Alpha2, Alpha3, Alpha4 : integer; FlipX : boolean = false; FlipY : boolean = false); stdcall;
procedure PutPoint2D(X,Y,Color,Alpha : integer) ; stdcall;
procedure DrawLine2D(X1, Y1, X2, Y2, Color : integer; Alpha : integer = 255; LineWidth : real = 1.0; Smooth : boolean = true); stdcall;
procedure DrawCircle2D(X, Y, Radius, Color : integer; Alpha : byte = 255); stdcall;
procedure DrawRectangle2D(X, Y, Width, Height, Color, Alpha : integer; Fill : boolean = false); stdcall;
procedure DrawRectangle2D_Fill_VertexColor(X, Y, Width, Height, Color1, Color2, Color3, Color4, Alpha1, Alpha2, Alpha3, Alpha4 : integer); stdcall;
procedure DrawText2D(Font : Cardinal; X,Y : integer; Text : string; Color : integer; Alpha : integer = 255; Scale : real = 1.0); stdcall;
function  GetTextWidth(Font : Cardinal; Text : string; Scale : real = 1.0):integer; stdcall;
procedure DrawEllipse2D(Center: TPoint; Radius0, Radius1, Vertices: Integer; Color: Cardinal; Alpha: byte=255); stdcall;
procedure DrawCircle2D_Fill(Xpos, Ypos, Radius, Color : integer; Alpha : byte = 255); stdcall;
procedure DrawCircleArc2D(Xpos, Ypos, Radius, Angle1, Angle2, Color: Integer; Alpha : byte = 255); stdcall;
procedure DrawColorLine2D(X1, Y1, X2, Y2, Color1, Color2 : integer; Alpha : integer = 255; LineWidth : real = 1.0; Smooth : boolean = true); stdcall;
procedure DrawTexture2D_Split(Texture : TGLUint; X , Y, FrameWidth, FrameHeight : integer; Angle, Alpha, Color : integer; SplitRect : Trect; Scale : single = 1.0; FlipX : boolean = false; FlipY : boolean = false); stdcall;
procedure DrawPolygon2D(points : array of Tpoint; Color, Alpha : integer); stdcall;
procedure DrawSprite2D_Tile(Texture : TGLUint; X, Y, Width, Height, FrameWidth, FrameHeight, FramesXCount, FramesYCount, FrameNumber, Angle, Alpha, Color : integer; Scale : single = 1.0; FlipX : boolean = false; FlipY : boolean = false); stdcall;
procedure DrawEllipse2D_Fill(Center: TPoint; Radius0, Radius1: Integer; Color: Cardinal; Alpha: byte=255); stdcall;
procedure DrawPolygon2D_VertexColor(points : array of TColorVertex2D); stdcall;
function  GetTextHeight(Font : Cardinal; Text : string; Scale : real = 1.0):integer; stdcall;

procedure RenderTexture2D(Texture : TGluint; X, Y, FrameWidth, FrameHeight : integer; Color : integer; Alpha : byte; Angle : integer;
Frame : byte = 1; FrameCountX : byte = 1; FrameCountY : byte = 1; ScaleX : glFloat = 1.0; ScaleY : glFloat = 1.0;
Color4 : boolean = false; VColor1: integer = 0; VColor2: integer = 0; VColor3: integer = 0; VColor4: integer = 0; VAlpha1: integer = 0;
 VAlpha2: integer = 0; VAlpha3: integer = 0; VAlpha4: integer = 0; Diffuse : boolean = false; FlipX : boolean = false; FlipY : boolean = false); stdcall;

var
LColor : Array [1..4] of GLFloat;

implementation

procedure Begin2D; stdcall;
begin
  if MultyTexActive then DeactiveMultytexturing;
  glGetFloatv(GL_CURRENT_COLOR, @LColor);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_LIGHTING);
  glMatrixMode(GL_PROJECTION);
  glPushMatrix;
  glLoadIdentity;
  gluOrtho2D(0,InitResX,InitResY,0);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix;
  glLoadIdentity;
end;
{------------------------------------------------------------------}
procedure End2D; stdcall;
begin
  glPopMatrix;
  glMatrixMode(GL_PROJECTION);
  glPopMatrix;
  glMatrixMode(GL_MODELVIEW);
  glEnable(GL_DEPTH_TEST);
  glcolor4f(LColor[1],LColor[2],LColor[3],LColor[4]);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
end;
{------------------------------------------------------------------}
procedure RenderTexture2D(Texture : TGluint; X, Y, FrameWidth, FrameHeight : integer; Color : integer; Alpha : byte; Angle : integer;
Frame : byte = 1; FrameCountX : byte = 1; FrameCountY : byte = 1; ScaleX : glFloat = 1.0; ScaleY : glFloat = 1.0;
Color4 : boolean = false; VColor1: integer = 0; VColor2: integer = 0; VColor3: integer = 0; VColor4: integer = 0; VAlpha1: integer = 0;
 VAlpha2: integer = 0; VAlpha3: integer = 0; VAlpha4: integer = 0; Diffuse : boolean = false; FlipX : boolean = false; FlipY : boolean = false); stdcall;
var imgWidth, imgHeight : glfloat; XFrame, YFrame : byte;
sprite : boolean;
begin
if RectInScreen(X,Y,FrameWidth,FrameHeight) then
begin
  glEnable(GL_BLEND);
  if not Diffuse then
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA) else
  glBlendFunc(GL_SRC_ALPHA, GL_ONE);

  glBindTexture(GL_TEXTURE_2D, Texture);

glPushMatrix;

glTranslatef(X+FrameWidth/2,Y+FrameHeight/2,0);

if trunc(ScaleX+ScaleY)<>2 then glScalef(ScaleX,ScaleY,1);

if not Color4 then glcolor4ub(GetRValue(Color),GetGValue(Color),GetBValue(Color),Alpha);

if angle<>0 then  glrotatef(Angle,0,0,1);

 if Frame+FrameCountX+FrameCountY=3 then  sprite:=false else sprite:=true;

 if sprite then
 begin
  imgWidth:=1.0/FrameCountX;
  imgHeight:=1.0/FrameCountY;

  YFrame:=(Frame div FrameCountX)+1;
  if Frame mod FrameCountX = 0 then YFrame:=YFrame-1;
  XFrame:=Frame - (YFrame-1)*FrameCountX;

  XFrame:=XFrame-1;
  YFrame:=YFrame-1;

      glBegin(GL_QUADS);
       if Color4 then glcolor4ub(GetRValue(VColor1),GetGValue(VColor1),GetBValue(VColor1),VAlpha1);
        if FlipX then begin
                       if FlipY then glTexCoord2f(imgWidth*XFrame+imgWidth, imgHeight*YFrame+imgHeight)
                       else glTexCoord2f(imgWidth*XFrame+imgWidth, imgHeight*YFrame);
                      end else
        begin
        if FlipY then glTexCoord2f(imgWidth*XFrame, imgHeight*YFrame+imgHeight)
        else glTexCoord2f(imgWidth*XFrame, imgHeight*YFrame);
        end;
        glVertex2f(-FrameWidth/2,-FrameHeight/2);


       if Color4 then glcolor4ub(GetRValue(VColor2),GetGValue(VColor2),GetBValue(VColor2),VAlpha2);
        if FlipX then begin
                       if FlipY then glTexCoord2f(imgWidth*XFrame, imgHeight*YFrame+imgHeight)
                       else glTexCoord2f(imgWidth*XFrame, imgHeight*YFrame);
                      end else
        begin
        if FlipY then glTexCoord2f(imgWidth*XFrame+imgWidth, imgHeight*YFrame+imgHeight)
        else glTexCoord2f(imgWidth*XFrame+imgWidth, imgHeight*YFrame);
        end;
        glVertex2f(FrameWidth/2, -FrameHeight/2);


       if Color4 then glcolor4ub(GetRValue(VColor3),GetGValue(VColor3),GetBValue(VColor3),VAlpha3);
        if FlipX then begin
                       if FlipY then glTexCoord2f(imgWidth*XFrame, imgHeight*YFrame)
                       else glTexCoord2f(imgWidth*XFrame, imgHeight*YFrame+imgHeight);
                      end else
        begin
        if FlipY then glTexCoord2f(imgWidth*XFrame+imgWidth, imgHeight*YFrame)
        else glTexCoord2f(imgWidth*XFrame+imgWidth, imgHeight*YFrame+imgHeight);
        end;
        glVertex2f( FrameWidth/2,  FrameHeight/2);

       if Color4 then glcolor4ub(GetRValue(VColor4),GetGValue(VColor4),GetBValue(VColor4),VAlpha4);
        if FlipX then begin
                       if FlipY then glTexCoord2f(imgWidth*XFrame+imgWidth, imgHeight*YFrame)
                       else glTexCoord2f(imgWidth*XFrame+imgWidth, imgHeight*YFrame+imgHeight)
                      end else
        begin
        if FlipY then glTexCoord2f(imgWidth*XFrame, imgHeight*YFrame)
        else glTexCoord2f(imgWidth*XFrame, imgHeight*YFrame+imgHeight);
        end;
        glVertex2f(-FrameWidth/2,  FrameHeight/2);
      glEnd;
  end else
  begin
      glBegin(GL_QUADS);
       if Color4 then glcolor4ub(GetRValue(VColor1),GetGValue(VColor1),GetBValue(VColor1),VAlpha1);
        if FlipX then begin
                      if FlipY then glTexCoord2f(1, 1)
                      else glTexCoord2f(1, 0);
                      end else
        begin
        if FlipY then glTexCoord2f(0, 1)
        else glTexCoord2f(0, 0);
        end;
        glVertex2f(-FrameWidth/2,-FrameHeight/2);


       if Color4 then glcolor4ub(GetRValue(VColor2),GetGValue(VColor2),GetBValue(VColor2),VAlpha2);
        if FlipX then begin
                      if FlipY then glTexCoord2f(0, 1)
                      else glTexCoord2f(0, 0);
                      end else
        begin
        if FlipY then glTexCoord2f(1, 1)
        else glTexCoord2f(1, 0);
        end;
        glVertex2f(FrameWidth/2, -FrameHeight/2);

       if Color4 then glcolor4ub(GetRValue(VColor3),GetGValue(VColor3),GetBValue(VColor3),VAlpha3);
        if FlipX then begin
                      if FlipY then glTexCoord2f(0, 0)
                      else glTexCoord2f(0, 1);
                      end else
        begin
        if FlipY then glTexCoord2f(1, 0)
        else glTexCoord2f(1, 1);
        end;
        glVertex2f( FrameWidth/2,  FrameHeight/2);

       if Color4 then glcolor4ub(GetRValue(VColor4),GetGValue(VColor4),GetBValue(VColor4),VAlpha4);
        if FlipX then begin
                      if FlipY then glTexCoord2f(1, 0)
                      else glTexCoord2f(1, 1);
                      end else
        begin
        if FlipY then glTexCoord2f(0, 0)
        else glTexCoord2f(0, 1);
        end;
        glVertex2f(-FrameWidth/2,  FrameHeight/2);
      glEnd;
  end;

glPopMatrix;

   glDisable(GL_BLEND);
   glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
   glBindTexture(GL_TEXTURE_2D, 0);
end;
end;
{------------------------------------------------------------------}
procedure DrawTexture2D_Split(Texture : TGLUint; X , Y, FrameWidth, FrameHeight : integer; Angle, Alpha, Color : integer; SplitRect : Trect; Scale : single = 1.0; FlipX : boolean = false; FlipY : boolean = false); stdcall;
var w,h : integer;
begin
w:=SplitRect.Right-SplitRect.Left;
h:=SplitRect.Bottom-SplitRect.Top;
if RectInScreen(X,Y,w,h) then
begin
   glEnable(GL_BLEND);
   glBindTexture(GL_TEXTURE_2D, Texture);

glPushMatrix;

glTranslatef(X+w/2,Y+h/2,0);

  if angle<>0 then  glrotatef(Angle,0,0,1);

  glcolor4ub(GetRValue(Color),GetGValue(Color),GetBValue(Color),Alpha);

      glBegin(GL_QUADS);
        if FlipX then begin
                      if FlipY then glTexCoord2f(((100/FrameWidth)*SplitRect.Right)/100, ((100/FrameHeight)*SplitRect.Bottom)/100)
                      else glTexCoord2f(((100/FrameWidth)*SplitRect.Right)/100, ((100/FrameHeight)*SplitRect.Top)/100);
                      end else
        begin
        if FlipY then glTexCoord2f(((100/FrameWidth)*SplitRect.Left)/100, ((100/FrameHeight)*SplitRect.Bottom)/100)
        else
        glTexCoord2f(((100/FrameWidth)*SplitRect.Left)/100, ((100/FrameHeight)*SplitRect.Top)/100);
        end;
        glVertex2f(-w/2*Scale,-h/2*Scale);
        if FlipX then begin
                      if FlipY then glTexCoord2f(((100/FrameWidth)*SplitRect.Left)/100, ((100/FrameHeight)*SplitRect.Bottom)/100)
                      else glTexCoord2f(((100/FrameWidth)*SplitRect.Left)/100, ((100/FrameHeight)*SplitRect.Top)/100);
                      end else
        begin
        if FlipY then glTexCoord2f(((100/FrameWidth)*SplitRect.Right)/100, ((100/FrameHeight)*SplitRect.Bottom)/100)
        else
        glTexCoord2f(((100/FrameWidth)*SplitRect.Right)/100, ((100/FrameHeight)*SplitRect.Top)/100);
        end;
        glVertex2f(w/2*Scale, -h/2*Scale);
        if FlipX then begin
                      if FlipY then glTexCoord2f(((100/FrameWidth)*SplitRect.Left)/100, ((100/FrameHeight)*SplitRect.Top)/100)
                      else glTexCoord2f(((100/FrameWidth)*SplitRect.Left)/100, ((100/FrameHeight)*SplitRect.Bottom)/100);
                      end else
        begin
        if FlipY then glTexCoord2f(((100/FrameWidth)*SplitRect.Right)/100, ((100/FrameHeight)*SplitRect.Top)/100)
        else
        glTexCoord2f(((100/FrameWidth)*SplitRect.Right)/100, ((100/FrameHeight)*SplitRect.Bottom)/100);
        end;
        glVertex2f( w/2*Scale,  h/2*Scale);
        if FlipX then begin
                      if FlipY then glTexCoord2f(((100/FrameWidth)*SplitRect.Right)/100, ((100/FrameHeight)*SplitRect.Top)/100)
                      else glTexCoord2f(((100/FrameWidth)*SplitRect.Right)/100, ((100/FrameHeight)*SplitRect.Bottom)/100);
                      end else
        begin
        if FlipY then glTexCoord2f(((100/FrameWidth)*SplitRect.Left)/100, ((100/FrameHeight)*SplitRect.Top)/100)
        else
        glTexCoord2f(((100/FrameWidth)*SplitRect.Left)/100, ((100/FrameHeight)*SplitRect.Bottom)/100);
        end;
        glVertex2f(-w/2*Scale,  h/2*Scale);
      glEnd;

glPopMatrix;

   glDisable(GL_BLEND);
   glBindTexture(GL_TEXTURE_2D, 0);
end;
end;
{------------------------------------------------------------------}
procedure DrawSprite2D_Tile(Texture : TGLUint; X, Y, Width, Height, FrameWidth, FrameHeight, FramesXCount, FramesYCount, FrameNumber, Angle, Alpha, Color : integer; Scale : single = 1.0; FlipX : boolean = false; FlipY : boolean = false); stdcall;
 function Bounds(X,Y,Width,Height : integer):TRect;
 begin
 result.Left:=X;
 result.Top:=Y;
 result.Right:=X+Width;
 result.Bottom:=Y+Height;
 end;
var XFrame,YFrame : byte;
begin

  YFrame:=(FrameNumber div FramesXCount)+1;
  if FrameNumber mod FramesXCount = 0 then YFrame:=YFrame-1;

  XFrame:=FrameNumber - (YFrame-1)*FramesXCount;

  XFrame:=XFrame-1;
  YFrame:=YFrame-1;

 DrawTexture2D_Split(Texture,X,Y,Width,Height,Angle,Alpha,Color,bounds(XFrame*FrameWidth,YFrame*FrameHeight,FrameWidth,FrameHeight),Scale,FlipX,FlipY);
end;
{------------------------------------------------------------------}
procedure DrawTexture2D_Simple(Texture : TGLUint; X , Y, FrameWidth, FrameHeight : integer; FlipX : boolean = false; FlipY : boolean = false); stdcall;
begin
RenderTexture2D(Texture,X,Y,FrameWidth, FrameHeight,$FFFFFF,255,0,1,1,1,1,1,false,0,0,0,0,0,0,0,0,false,FlipX,FlipY);
end;
{------------------------------------------------------------------}
procedure DrawTexture2D(Texture : TGLUint; X , Y, FrameWidth, FrameHeight, Angle, Alpha, Color : integer; Diffuse : boolean = false; FlipX : boolean = false; FlipY : boolean = false); stdcall;
begin
RenderTexture2D(Texture,X,Y,FrameWidth, FrameHeight,Color,Alpha,Angle,1,1,1,1,1,false,0,0,0,0,0,0,0,0,Diffuse,FlipX,FlipY);
end;
{------------------------------------------------------------------}
procedure DrawTexture2D_VertexColor(Texture : TGLUint; X , Y, FrameWidth, FrameHeight,Angle, Color1, Color2, Color3, Color4, Alpha1, Alpha2, Alpha3, Alpha4 : integer; FlipX : boolean = false; FlipY : boolean = false ); stdcall;
begin
RenderTexture2D(Texture,X,Y,FrameWidth, FrameHeight,$FFFFFF,255,Angle,1,1,1,1,1,true,Color1,Color2,Color3,Color4,Alpha1,Alpha2,Alpha3,Alpha4,false,FlipX,FlipY);
end;
{------------------------------------------------------------------}
procedure DrawSprite2D_Simple(Texture : TGLUint; X , Y, FrameWidth, FrameHeight,FramesXCount, FramesYCount, FrameNumber: integer; FlipX : boolean = false; FlipY : boolean = false); stdcall;
begin
if FramesXCount=0 then FramesXCount:=1;
if FramesYCount=0 then FramesYCount:=1;
RenderTexture2D(Texture,X,Y,FrameWidth,FrameHeight,$FFFFFF,255,0,FrameNumber,FramesXCount,FramesYCount,1,1,false,0,0,0,0,0,0,0,0,false,FlipX,FlipY);
end;
{------------------------------------------------------------------}
procedure DrawSprite2D(Texture : TGLUint; X , Y, FrameWidth, FrameHeight,FramesXCount, FramesYCount, FrameNumber, Angle, Alpha, Color : integer; Diffuse : boolean = false; FlipX : boolean = false; FlipY : boolean = false); stdcall;
begin
if FramesXCount=0 then FramesXCount:=1;
if FramesYCount=0 then FramesYCount:=1;
RenderTexture2D(Texture,X,Y,FrameWidth, FrameHeight,Color,Alpha,Angle,FrameNumber,FramesXCount,FramesYCount,1,1,false,0,0,0,0,0,0,0,0,Diffuse,FlipX,FlipY);
end;
{------------------------------------------------------------------}
procedure DrawSprite2D_VertexColor(Texture : TGLUint; X , Y, FrameWidth, FrameHeight,FramesXCount, FramesYCount, FrameNumber,Angle, Color1, Color2, Color3, Color4, Alpha1, Alpha2, Alpha3, Alpha4 : integer; FlipX : boolean = false; FlipY : boolean = false); stdcall;
begin
if FramesXCount=0 then FramesXCount:=1;
if FramesYCount=0 then FramesYCount:=1;
RenderTexture2D(Texture,X,Y,FrameWidth, FrameHeight,$FFFFFF,255,0,FrameNumber,FramesXCount,FramesYCount,1,1,true,Color1,Color2,Color3,Color4,Alpha1,Alpha2,Alpha3,Alpha4,false,FlipX,FlipY);
end;
{------------------------------------------------------------------}
procedure PutPoint2D(X,Y,Color,Alpha : integer) ; stdcall;
begin
  glDisable(GL_TEXTURE_2D);
 if Alpha<>255 then
  glEnable(GL_BLEND);


 glcolor4ub(GetRValue(Color),GetGValue(Color),GetBValue(Color),Alpha);
 glBegin(GL_POINTS);
 glVertex2f(X,Y);
 glEnd;

 if Alpha<>255 then
  glDisable(GL_BLEND);
  glEnable(GL_TEXTURE_2D);
end;
{------------------------------------------------------------------}
procedure DrawPolygon2D(points : array of Tpoint; Color, Alpha : integer); stdcall;
var i : integer;
begin
glDisable(GL_TEXTURE_2D);
glEnable(GL_BLEND);

 glBegin(GL_POLYGON);
 glcolor4ub(GetRValue(Color),GetGValue(Color),GetBValue(Color),Alpha);
  for i:=0 to Length(points)-1 do
   glVertex2f(points[i].X,points[i].Y);
 glEnd;

glDisable(GL_BLEND);
glEnable(GL_TEXTURE_2D);
end;
{------------------------------------------------------------------}
procedure DrawPolygon2D_VertexColor(points : array of TColorVertex2D); stdcall;
var i : integer;
begin
glDisable(GL_TEXTURE_2D);
glEnable(GL_BLEND);


 glBegin(GL_POLYGON);
  for i:=0 to Length(points)-1 do
   begin
   glcolor4ub(GetRValue(points[i].Color),GetGValue(points[i].Color),GetBValue(points[i].Color),points[i].Alpha);
   glVertex2f(points[i].X,points[i].Y);
   end;
 glEnd;

glDisable(GL_BLEND);
glEnable(GL_TEXTURE_2D);
end;
{------------------------------------------------------------------}
procedure RenderLine2D(X1, Y1, X2, Y2, Color1, Color2 , Alpha : integer; LineWidth : real; Smooth : boolean);
begin
glDisable(GL_TEXTURE_2D);
if Smooth or (Alpha<>255) then glEnable(GL_BLEND);
if Smooth then
 begin
  glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
  glEnable(GL_LINE_SMOOTH);
 end;

glLineWidth(LineWidth);

  glBegin(GL_LINES);
   glcolor4ub(GetRValue(Color1),GetGValue(Color1),GetBValue(Color1),Alpha);
   glVertex2f(X1,Y1);
   glcolor4ub(GetRValue(Color2),GetGValue(Color2),GetBValue(Color2),Alpha);
   glVertex2f(X2,Y2);
  glEnd;

glEnable(GL_TEXTURE_2D);
if Smooth then glDisable(GL_LINE_SMOOTH);
if Smooth or (Alpha<>255) then glDisable(GL_BLEND);
end;
{------------------------------------------------------------------}
procedure DrawLine2D(X1, Y1, X2, Y2, Color : integer; Alpha : integer = 255; LineWidth : real = 1.0; Smooth : boolean = true); stdcall;
begin
 RenderLine2D(X1,Y1,X2,Y2,Color,Color,Alpha,LineWidth,Smooth);
end;
{------------------------------------------------------------------}
procedure DrawColorLine2D(X1, Y1, X2, Y2, Color1, Color2 : integer; Alpha : integer = 255; LineWidth : real = 1.0; Smooth : boolean = true); stdcall;
begin
 RenderLine2D(X1,Y1,X2,Y2,Color1,Color2,Alpha,LineWidth,Smooth);
end;
{------------------------------------------------------------------}
procedure DrawRectangle2D_Fill_VertexColor(X, Y, Width, Height, Color1, Color2, Color3, Color4, Alpha1, Alpha2, Alpha3, Alpha4 : integer); stdcall;
begin
glDisable(GL_TEXTURE_2D);

 if Alpha1+Alpha2+Alpha3+Alpha4<>1020 then
  glEnable(GL_BLEND);

   glBegin(GL_QUADS);
    glcolor4ub(GetRValue(Color1),GetGValue(Color1),GetBValue(Color1),Alpha1);
    glVertex2f(X,Y);
    glcolor4ub(GetRValue(Color2),GetGValue(Color2),GetBValue(Color2),Alpha2);
    glVertex2f(X+Width,Y);
    glcolor4ub(GetRValue(Color3),GetGValue(Color3),GetBValue(Color3),Alpha3);
    glVertex2f(X+Width,Y+Height);
    glcolor4ub(GetRValue(Color4),GetGValue(Color4),GetBValue(Color4),Alpha4);
    glVertex2f(X,Y+Height);
   glEnd;

 if Alpha1+Alpha2+Alpha3+Alpha4<>1020 then
 glDisable(GL_BLEND);

 glEnable(GL_TEXTURE_2D);
end;
{------------------------------------------------------------------}
procedure DrawRectangle2D(X, Y, Width, Height, Color, Alpha : integer; Fill : boolean = false); stdcall;
begin
glDisable(GL_TEXTURE_2D);

if Alpha<>255 then
glEnable(GL_BLEND);

 if fill then
 begin

  glcolor4ub(GetRValue(Color),GetGValue(Color),GetBValue(Color),Alpha);
   glBegin(GL_QUADS);
    glVertex2f(X,Y);
    glVertex2f(X+Width,Y);
    glVertex2f(X+Width,Y+Height);
    glVertex2f(X,Y+Height);
   glEnd;

 end else
 begin

  glcolor4ub(GetRValue(Color),GetGValue(Color),GetBValue(Color),Alpha);
   glBegin(GL_LINES);
    glVertex2f(X,Y);
    glVertex2f(X+Width+1,Y);

    glVertex2f(X+Width,Y);
    glVertex2f(X+Width,Y+Height);

    glVertex2f(X+Width,Y+Height);
    glVertex2f(X,Y+Height);

    glVertex2f(X,Y+Height);
    glVertex2f(X,Y);
   glEnd;

 end;
if Alpha<>255 then
glDisable(GL_BLEND);
glEnable(GL_TEXTURE_2D);
end;
{------------------------------------------------------------------}
procedure DrawCircleArc2D(Xpos, Ypos, Radius, Angle1, Angle2, Color: Integer; Alpha : byte = 255); stdcall;
const
 Pi2 = Pi * 2;
var
 OverPi2: Boolean;
 DAngle: Single;
 x, y, ox,oy: Integer;
 Ang1, Ang2: Single;
begin
 Ang1:= Angle1 * Pi / 128;
 Ang2:= Angle2 * Pi / 128;

 Radius:= Abs(Radius);
 DAngle:= 22 / (Pi2 * Radius);
 if (Ang1 > Ang2) then OverPi2:= True else OverPi2:= False;

 ox:=Round(Xpos + Cos(Ang1) * Radius);
 oy:=Round(Ypos - Sin(Ang1) * Radius);

 while (Ang1 <= Ang2) do
  begin
   x:= Round(Xpos + Cos(Ang1) * Radius);
   if (x >= 0)and(x < InitResX) then
    begin
     y:= Round(Ypos - Sin(Ang1) * Radius);
     if (y >= 0)and(y < InitResY) then
     begin
     DrawLine2D(ox,oy,x,y,Color,Alpha,1,false);
     ox:=x;
     oy:=y;
     end;
    end;

   Ang1:= Ang1 + DAngle;
   if (OverPi2)and(Ang1 > Pi2) then
    begin
     Ang1:= Ang1 - Pi2;
     OverPi2:= False;
    end;
  end;
end;
{------------------------------------------------------------------}
procedure DrawEllipse2D_Fill(Center: TPoint; Radius0, Radius1: Integer; Color: Cardinal; Alpha: byte=255); stdcall;
begin
glDisable(GL_TEXTURE_2D);
glPushMatrix();
 if Alpha<>255 then
 glEnable(GL_BLEND);
 glcolor4ub(GetRValue(Color),GetGValue(Color),GetBValue(Color),Alpha);
 glTranslatef(Center.X, Center.Y, 0);
 glScalef(1,Radius1/Radius0,1);
 gluDisk(QuadraticObject, 0, Radius0, 24, 1);
 if Alpha<>255 then
 glDisable(GL_BLEND);
glPopMatrix();
glEnable(GL_TEXTURE_2D);
end;
{------------------------------------------------------------------}
procedure DrawCircle2D_Fill(Xpos, Ypos, Radius, Color : integer; Alpha : byte = 255); stdcall;
begin
glDisable(GL_TEXTURE_2D);
glPushMatrix();
 if Alpha<>255 then
 glEnable(GL_BLEND);
glcolor4ub(GetRValue(Color),GetGValue(Color),GetBValue(Color),Alpha);
 glTranslatef(XPos, YPos, 0);
 gluDisk(QuadraticObject, 0, Radius, 24, 1);
 if Alpha<>255 then
 glDisable(GL_BLEND);
GlPopMatrix();
glEnable(GL_TEXTURE_2D);
end;
{------------------------------------------------------------------}
procedure DrawCircle2D(X, Y, Radius, Color : integer; Alpha : byte = 255); stdcall;
const
 Pi2 = Pi * 2;
var
 w: Word;
 S: Single;
 _x, _y: Integer;
begin
 Radius:= Abs(Radius);

 S:= Pi2 * Radius;
 W:= 0;

 while (w <= S) do
  begin
   _x:= Round(X + Radius * Cos(Pi2 * w / s));
   _y:= Round(Y - Radius * Sin(Pi2 * w / s));
  if (_X>0) and (_Y>0) and (_X<InitResX) and (_Y<InitResY) then
   PutPoint2D(_X,_Y,Color,Alpha);
   Inc(w);
 end;
end;
{------------------------------------------------------------------}
procedure DrawEllipse2D(Center: TPoint; Radius0, Radius1, Vertices: Integer; Color: Cardinal; Alpha: byte=255); stdcall;
const
 Pi2 = Pi * 2.0;
var
 i: Integer;
 Pt0, Pt1: TPoint;
 Alpha0, Alpha1: Real;
begin
 for i:= 0 to Vertices - 1 do
  begin
   Alpha0:= i * Pi2 / Vertices;
   Alpha1:= (i + 1) * Pi2 / Vertices;

   Pt0.X:= Center.X + Round(Cos(Alpha0) * Radius0);
   Pt0.Y:= Center.Y + Round(Sin(Alpha0) * Radius1);
   Pt1.X:= Center.X + Round(Cos(Alpha1) * Radius0);
   Pt1.Y:= Center.Y + Round(Sin(Alpha1) * Radius1);

   DrawLine2D(Pt0.X,Pt0.Y,Pt1.X,Pt1.Y,Color,Alpha);

  end;
end;
{------------------------------------------------------------------}
procedure DrawText2D(Font : Cardinal; X,Y : integer; Text : string; Color : integer; Alpha : integer = 255; Scale : real = 1.0); stdcall;
var i : integer;
s : string;
Bukrect : TRect;
begin
if DGLFonts[Font].Load then
begin
 s:='';
 for i:=1 to length(Text) do
  begin
   Bukrect.Left:=DGLFonts[Font].Buks[ord(Text[i])-32].X;
   Bukrect.Top:=DGLFonts[Font].Buks[ord(Text[i])-32].Y;
   Bukrect.Right:=Bukrect.Left+DGLFonts[Font].Buks[ord(Text[i])-32].W;
   Bukrect.Bottom:=Bukrect.Top+DGLFonts[Font].Buks[ord(Text[i])-32].H;
   DrawTexture2D_Split(DGLFonts[Font].Texture,X+GetTextWidth(Font,s,Scale),Y,DGLFonts[Font].Width,DGLFonts[Font].Height,0,Alpha,Color,Bukrect,Scale);
   s:=s+text[i];
  end;
end;
end;
{------------------------------------------------------------------}
function GetTextWidth(Font : Cardinal; Text : string; Scale : real = 1.0):integer; stdcall;
var i : integer;
r : integer;
begin
if not DGLFonts[Font].Load then
begin
result:=0;
Exit;
end;
 if text='' then
  begin
  result:=0;
  Exit;
 end;
r:=0;
for i:=1 to length(Text) do
 r:=r+DGLFonts[Font].Buks[ord(Text[i])-32].W;
result:=round(r*Scale);
end;
{------------------------------------------------------------------}
function GetTextHeight(Font : Cardinal; Text : string; Scale : real = 1.0):integer; stdcall;
var i : integer;
r : integer;
 function Max(v1,v2 : integer):integer;
 begin
  if v1>=v2 then result:=v1 else result:=v2;
 end;
begin
if not DGLFonts[Font].Load then
begin
result:=0;
Exit;
end;
 if text='' then
  begin
  result:=0;
  Exit;
 end;
r:=0;
for i:=1 to length(Text) do
 r:=max(DGLFonts[Font].Buks[ord(Text[i])-32].H,r);
result:=round(r*Scale);
end;

end.
