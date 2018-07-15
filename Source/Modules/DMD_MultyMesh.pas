//----------------------------------------------------------------------------//
//DRON's OpenGl Engine V 1.0 http://dronprogs.mirgames.ru                     //
//                                                                            //
// GL_Mesh_DMD.pas V 1.0, 11.01.2006                                          //
//                                                                            //
// This module contains main engine animated mesh class.                      //
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
unit DMD_MultyMesh;

interface
uses
  Classes, OpenGL, Math;

Type
    PGLVertex = ^TGLVertex;
    TGLVertex = record
       x,y,z : GLFloat;
    end;

    PGLVector = ^TGLVector;
    TGLVector = array[0..2] of GLFloat;

    PGLFace = ^TGLFace;
    TGLFace = array[0..2] of GLInt;

    PGLVertexArray = ^TGLVertexArray;
    TGLVertexArray = array[Word] of TGLVertex;

    PGLFacesArray = ^TGLFacesArray;
    TGLFacesArray = array[word] of TGLFace;

    TGLMultyMesh = class;

    TGLMesh = class
      Vertices : PGLVertexArray;
      Faces : PGLFacesArray;
      FasetNormals : PGLVertexArray;
      SmoothNormals : PGLVertexArray;
      Width,Height,Depth : GLFloat;
      VertexCount : Integer;
      FacesCount : Integer;
      fExtent,fExtentX,fExtentY,fExtentZ : GLFloat;
      ScaleType : byte;
      Parent : TGLMultyMesh;
      public
      procedure CalcNormals;
      procedure CalcSmoothNormals;
      procedure Draw(Smooth,Textured : Boolean);
      destructor Destroy; override;
    end;

    TGLMultyMesh = class
      Meshes : TList;
      CurrentFrame : Integer;
      fExtent,fExtentX,fExtentY,fExtentZ : GLFloat;
      ScaleType : byte;
      fSmooth : Boolean;
      fAllScale : GLFloat;
      TexVertices : PGLVertexArray;
      TexFaces : PGLFacesArray;
      TexVCount, TexFCount : Integer;
      TexturePresent : Boolean;
      public
      procedure LoadFromFile( const FileName : String );
      procedure Draw;
      constructor Create;
      destructor Destroy; override;
      published
    end;

    function Max(v1,v2:GLFloat):GLFloat;
    function Min(v1,v2:GLFloat) : GLFloat;

implementation
uses DrawFunc3D;
{------------------------------------------------------------------}
function Max(v1,v2:GLFloat) : GLFloat;
begin
  if v1 >= v2 then result := v1
  else result := v2;
end;
function Min(v1,v2:GLFloat) : GLFloat;
begin
  if v1 <= v2 then result := v1
  else result := v2;
end;
{------------------------------------------------------------------}
procedure TGLMesh.CalcSmoothNormals;
var i, j : integer;
Face : TGLFace;
length : single;
begin
 for i:=0 to VertexCount - 1 do
  begin
   SmoothNormals[i].X:=0;
   SmoothNormals[i].Y:=0;
   SmoothNormals[i].Z:=0;
  end;

 for i:=0 to FacesCount-1 do
 begin
 Face := Faces[i];
  for j:=0 to 2 do
   begin
   SmoothNormals[Face[j]].X:=SmoothNormals[Face[j]].X+FasetNormals[i].X;
   SmoothNormals[Face[j]].Y:=SmoothNormals[Face[j]].Y+FasetNormals[i].Y;
   SmoothNormals[Face[j]].Z:=SmoothNormals[Face[j]].Z+FasetNormals[i].Z;
   end;
 end;

 for i:=0 to VertexCount - 1 do
  begin
   length:=sqrt(sqr(SmoothNormals[i].X) + sqr(SmoothNormals[i].Y) + sqr(SmoothNormals[i].Z));
   SmoothNormals[i].X:=SmoothNormals[i].X/length;
   SmoothNormals[i].Y:=SmoothNormals[i].Y/length;
   SmoothNormals[i].Z:=SmoothNormals[i].Z/length;
  end;
end;
{------------------------------------------------------------------}
procedure TGLMesh.CalcNormals;
var
  i : Integer;
  wrki, vx1, vy1, vz1, vx2, vy2, vz2 : GLfloat;
  nx, ny, nz : GLfloat;
  wrkVector : TGLVertex;
  wrkVector1, wrkVector2, wrkVector3 : TGLVertex;
  wrkFace : TGLFace;
begin
  For i := 0 to FacesCount - 1 do begin
     wrkFace := Faces[i];
     wrkVector1 := Vertices[wrkFace[0]];
     wrkVector2 := Vertices[wrkFace[1]];
     wrkVector3 := Vertices[wrkFace[2]];

     vx1 := wrkVector1.x - wrkVector2.x;
     vy1 := wrkVector1.y - wrkVector2.y;
     vz1 := wrkVector1.z - wrkVector2.z;

     vx2 := wrkVector2.x - wrkVector3.x;
     vy2 := wrkVector2.y - wrkVector3.y;
     vz2 := wrkVector2.z - wrkVector3.z;

     nx := vy1 * vz2 - vz1 * vy2;
     ny := vz1 * vx2 - vx1 * vz2;
     nz := vx1 * vy2 - vy1 * vx2;

     wrki := sqrt (nx * nx + ny * ny + nz * nz);

     wrkVector.x := nx / wrki;
     wrkVector.y := ny / wrki;
     wrkVector.z := nz / wrki;

     FasetNormals[i] := wrkVector;
  end;
end;
{------------------------------------------------------------------}
procedure TGLMesh.Draw(Smooth, Textured: Boolean);
var
   i : Integer;
   Face,TexFace : TGLFace;
   TexVertex : TGLVertex;
begin
  for i := 0 to FacesCount - 1 do begin
    glBegin(GL_TRIANGLES);
      Face := Faces[i];
      if Smooth then begin
        glNormal3fv(@SmoothNormals[Face[0]]);
        if Textured then begin
           TexFace := Parent.TexFaces[i];
           TexVertex := Parent.TexVertices[TexFace[0]];
           _glTexCoord2f(TexVertex.x,1-TexVertex.y);
        end;
        glVertex3fv(@Vertices[Face[0]]);
        glNormal3fv(@SmoothNormals[Face[1]]);
        if Textured then begin
           TexFace := Parent.TexFaces[i];
           TexVertex := Parent.TexVertices[TexFace[1]];
           _glTexCoord2f(TexVertex.x,1-TexVertex.y);
        end;
        glVertex3fv(@Vertices[Face[1]]);
        glNormal3fv(@SmoothNormals[Face[2]]);
        if Textured then begin
           TexFace := Parent.TexFaces[i];
           TexVertex := Parent.TexVertices[TexFace[2]];
           _glTexCoord2f(TexVertex.x,1-TexVertex.y);
        end;
        glVertex3fv(@Vertices[Face[2]]);
      end else begin
        glNormal3fv(@FasetNormals[i]);
        if Textured then begin
           TexFace := Parent.TexFaces[i];
           TexVertex := Parent.TexVertices[TexFace[0]];
           _glTexCoord2f(TexVertex.x,1-TexVertex.y);
        end;
        glVertex3fv(@Vertices[Face[0]]);
        if Textured then begin
           TexFace := Parent.TexFaces[i];
           TexVertex := Parent.TexVertices[TexFace[1]];
           _glTexCoord2f(TexVertex.x,1-TexVertex.y);
        end;
        glVertex3fv(@Vertices[Face[1]]);
        if Textured then begin
           TexFace := Parent.TexFaces[i];
           TexVertex := Parent.TexVertices[TexFace[2]];
           _glTexCoord2f(TexVertex.x,1-TexVertex.y);
        end;
        glVertex3fv(@Vertices[Face[2]]);
      end;
    glEnd;
  end;
end;
{------------------------------------------------------------------}
destructor TGLMesh.Destroy;
begin
   FreeMem(Vertices,VertexCount*SizeOf(TGLVertex));
   FreeMem(SmoothNormals,VertexCount*SizeOf(TGLVertex));
   FreeMem(Faces,FacesCount*SizeOf(TGLFace));
   FreeMem(FasetNormals,FacesCount*SizeOf(TGLVector));
end;
{------------------------------------------------------------------}
procedure TGLMultyMesh.LoadFromFile;
var
   OverallMaxVertex : single;
   f : TextFile;
   S : String;
   procedure ReadNextMesh(AParent : TGLMultyMesh);
     var
        i : Integer;
   	Vertex : TGLVertex;
   	Face : TGLFace;
   	MaxVertex,MaxVertexX,MaxVertexY,MaxVertexZ : GLFloat;
        NextMesh : TGLMesh;

    MinX,MinY,MinZ,MaxX,MaxY,MaxZ :GLFloat;
     begin
        NextMesh := TGLMesh.Create;
        repeat
          ReadLn(f, S);
        until (S = 'numverts numfaces') or eof(f);
        Readln(f,NextMesh.VertexCount,NextMesh.FacesCount);
        GetMem(NextMesh.Vertices,NextMesh.VertexCount*SizeOf(TGLVertex));
        GetMem(NextMesh.SmoothNormals,NextMesh.VertexCount*SizeOf(TGLVector));
        GetMem(NextMesh.Faces,NextMesh.FacesCount*SizeOf(TGLFace));
        GetMem(NextMesh.FasetNormals,NextMesh.FacesCount*SizeOf(TGLVector));

        ReadLn(f,S);

        for i := 0 to NextMesh.VertexCount - 1 do
          begin
            Readln(f,Vertex.x,Vertex.y,Vertex.z);
            NextMesh.Vertices[i] := Vertex;
          end;

        ReadLn(f,S);
        ReadLn(f,S);

        for i := 0 to NextMesh.FacesCount - 1 do
          begin
            Readln(f,Face[0],Face[1],Face[2]);
            Face[0] := Face[0] - 1;
            Face[1] := Face[1] - 1;
            Face[2] := Face[2] - 1;
            NextMesh.Faces[i] := Face;
          end;

          NextMesh.CalcNormals;
          NextMesh.CalcSmoothNormals;

   MinX:=0.0;
   MinY:=0.0;
   MinZ:=0.0;
   MaxX:=0.0;
   MaxY:=0.0;
   MaxZ:=0.0;

   for i:=0 to NextMesh.VertexCount - 1 do
   begin
   MinX:=Min(MinX,NextMesh.Vertices[i].x);
   MinY:=Min(MinY,NextMesh.Vertices[i].Y);
   MinZ:=Min(MinZ,NextMesh.Vertices[i].Z);

   MaxX:=Max(MaxX,NextMesh.Vertices[i].x);
   MaxY:=Max(MaxY,NextMesh.Vertices[i].Y);
   MaxZ:=Max(MaxZ,NextMesh.Vertices[i].Z);
   end;

   NextMesh.Width := MaxX - MinX;
   NextMesh.Height:= MaxY - MinY;
   NextMesh.Depth := MaxZ - MinZ;

   MaxVertex := 0;

   for i := 0 to NextMesh.VertexCount - 1 do
     begin
       OverallMaxVertex := Max(OverallMaxVertex,NextMesh.Vertices[i].x);
       OverallMaxVertex := Max(OverallMaxVertex,NextMesh.Vertices[i].y);
       OverallMaxVertex := Max(OverallMaxVertex,NextMesh.Vertices[i].z);
     end;

   for i := 0 to NextMesh.VertexCount - 1 do
     begin
       MaxVertex := Max(MaxVertex,NextMesh.Vertices[i].x);
       MaxVertex := Max(MaxVertex,NextMesh.Vertices[i].y);
       MaxVertex := Max(MaxVertex,NextMesh.Vertices[i].z);
     end;
   NextMesh.fExtent := 1/MaxVertex;

   MaxVertexX := 0; MaxVertexY := 0; MaxVertexZ := 0;
   for i := 0 to NextMesh.VertexCount - 1 do
     begin
       MaxVertexX := Max(MaxVertexX,NextMesh.Vertices[i].x);
       MaxVertexY := Max(MaxVertexY,NextMesh.Vertices[i].y);
       MaxVertexZ := Max(MaxVertexZ,NextMesh.Vertices[i].z);
     end;
   NextMesh.fExtentX := 1/MaxVertexX; NextMesh.fExtentY := 1/MaxVertexY; NextMesh.fExtentZ := 1/MaxVertexZ;

 NextMesh.Parent := AParent;
 Meshes.Add(NextMesh);
     end;

   Procedure ReadTextureBlock;
   var
      i : Integer;
      Vertex : TGLVertex;
      Face : TGLFace;
   begin
     Readln(f,S);
     Readln(f,TexVCount,TexFCount);

     if Assigned(TexVertices) then FreeMem(TexVertices);
     if Assigned(TexFaces) then FreeMem(TexFaces);

     GetMem(TexVertices,TexVCount*SizeOf(TGLVertex));
     GetMem(TexFaces,TexFCount*SizeOf(TGLFace));

     Readln(f,S);

     if S <> 'Texture vertices:' then begin
       TexturePresent := False;
       Exit;
     end;

     for i := 0 to TexVCount - 1 do begin
       Readln(f,Vertex.x,Vertex.y,Vertex.z);
       TexVertices[i] := Vertex;
     end;

     Readln(f,S);
     Readln(f,S);

     for i := 0 to TexFCount - 1 do begin
       Readln(f,Face[0],Face[1],Face[2]);
       Face[0] := Face[0] - 1;
       Face[1] := Face[1] - 1;
       Face[2] := Face[2] - 1;
       TexFaces[i] := Face;
     end;

     TexturePresent := True;
   end;

begin
   fAllScale:=0.0;
   OverallMaxVertex:=0.0;
   Meshes := TList.Create;
   AssignFile(f,FileName);
   Reset(f);
   While not Eof(f) do begin
     Readln(f,S);
     if S = 'New object' then ReadNextMesh(Self);
     if S = 'New Texture:' then ReadTextureBlock;
   end;
   CloseFile(f);
   fAllScale:=1/OverallMaxVertex;
end;
{------------------------------------------------------------------}
procedure TGLMultyMesh.Draw;
begin
glPushMatrix();

   case ScaleType of
   1: begin
       fExtent := TGLMesh(Meshes.Items[CurrentFrame]).fExtent;
       glScalef(fExtent,fExtent,fExtent);
      end;
   2: begin
       fExtentX := TGLMesh(Meshes.Items[CurrentFrame]).fExtentX;
       fExtentY := TGLMesh(Meshes.Items[CurrentFrame]).fExtentY;
       fExtentZ := TGLMesh(Meshes.Items[CurrentFrame]).fExtentZ;
       glScalef(fExtentX,fExtentY,fExtentZ);
      end;
    3: glScalef(fAllScale,fAllScale,fAllScale);
   end;//case

  TGLMesh(Meshes.Items[CurrentFrame]).Draw(fSmooth,TexturePresent);

glPopMatrix();
end;
{------------------------------------------------------------------}
constructor TGLMultyMesh.Create;
begin
  CurrentFrame := 0;
end;
{------------------------------------------------------------------}
destructor TGLMultyMesh.Destroy;
Var i : Integer;
begin
  for i := 0 to Meshes.Count - 1 do
      TGLMesh(Meshes.Items[i]).Destroy;
  Meshes.Free;
  TexVertices:=nil;
  TexFaces:=nil;
end;

end.
