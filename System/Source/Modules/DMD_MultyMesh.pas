//----------------------------------------------------------------------------//
//DRON's OpenGl Engine V 1.0 http://dronprogs.mirgames.ru                     //
//                                                                            //
// GL_Mesh_DMD.pas V 1.1, 13.04.2008                                          //
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
  Classes, OpenGL, Math, Variables;

var
    bump_active   : boolean = false;

Type
    TTangent = record
    bitangent : TVertex;
    tangent   : TVertex4D;
    end;

    PGLVertex = ^TGLVertex;
    TGLVertex = record
       x,y,z : single;
    end;

    TGLVertex2 = record
     u,v : GLFloat;
    end;

    TMaterial = record
    diffuse : array [0..2] of byte;
    glossiness : single;
    alpha : byte;
    TexFileName, NormalMapFileName, SpecularMapFileName : string[128];
    end;

    PGLVector = ^TGLVector;
    TGLVector = array[0..2] of GLFloat;

    PGLFace = ^TGLFace;
    TGLFace = array[0..2] of GLUInt;

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

      Tangent : array of TTangent;

      //Для VBO
      V_Buff:cardinal;
      F_Buff:cardinal;
      AllVertiches:cardinal;
      invbo : boolean;

      public
      procedure CalcNormals(Inverted : boolean);
      procedure CalcSmoothNormals;
      procedure Draw(Smooth,Textured : Boolean);
      procedure CalcTangents;
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

      Material : TMaterial;
      MaterialPresented : Boolean;

      public
      procedure LoadFromFile( const FileName : String;Inverted : boolean );
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
function vertex(x,y,z : single) : TVertex; inline;
begin
result.X:=x;
result.Y:=y;
result.Z:=z;
end;
function vertex4D(x,y,z,w : single) : TVertex4D; inline;
begin
result.X:=x;
result.Y:=y;
result.Z:=z;
result.W:=w;
end;
function add(v_1,v_2 : TVertex) : Tvertex; inline;
begin
result.X:=v_1.X+v_2.X;
result.Y:=v_1.Y+v_2.Y;
result.Z:=v_1.Z+v_2.Z;
end;
function cross(v_1,v_2 : Tvertex) : Tvertex; inline;
var r,s : single;
begin
r := v_1.y * v_2.z - v_1.z * v_2.y;
s := v_1.z * v_2.x - v_1.x * v_2.z;
result.z := v_1.x * v_2.y - v_1.y * v_2.x;
result.x := r;
result.y := s;
end;
function DotProduct(v1,v2 : TVertex) : single;  inline; overload;
begin
result:=v1.X*v2.X+v1.Y*v2.Y+v1.Z*v2.Z;
end;
function DotProduct(v : TVertex; x,y,z,w : single) : single; inline; overload;
begin
result:=v.X*x+v.Y*y+v.Z*z+w;
end;
function Normalize(v : Tvertex) : TVertex; inline;
var len : single;
begin
 len := sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z);
 Result.X:=v.X/len;
 Result.Y:=v.Y/len;
 Result.Z:=v.Z/len;
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
procedure TGLMesh.CalcTangents;
var
i : integer;
v1, v2, v3, w1, w2, w3, sdir, tdir, n, t, temp, temp2 : TVertex;
wrkFace : TGLFace;
x1,x2,y1,y2,z1,z2,s1,s2,t1,t2,r,dot,d : single;
tan1, tan2 : array of TVertex;
begin
SetLength(tangent,VertexCount);
SetLength(tan1,VertexCount);
SetLength(tan2,VertexCount);

for i := 0 to VertexCount - 1 do
begin
 tan1[i]:=vertex(0,0,0);
 tan2[i]:=vertex(0,0,0);
 tangent[i].bitangent:=vertex(0,0,0);
 tangent[i].tangent:=vertex4D(0,0,0,0);
end;

for i := 0 to FacesCount - 1 do
 begin
  wrkFace := Faces[i];

  v1 := vertex(Vertices[wrkFace[0]].x,Vertices[wrkFace[0]].y,Vertices[wrkFace[0]].z);
  v2 := vertex(Vertices[wrkFace[1]].x,Vertices[wrkFace[1]].y,Vertices[wrkFace[1]].z);
  v3 := vertex(Vertices[wrkFace[2]].x,Vertices[wrkFace[2]].y,Vertices[wrkFace[2]].z);

  
  w1 := vertex(Parent.TexVertices[wrkFace[0]].x,Parent.TexVertices[wrkFace[0]].y,Parent.TexVertices[wrkFace[0]].z);
  w2 := vertex(Parent.TexVertices[wrkFace[1]].x,Parent.TexVertices[wrkFace[1]].y,Parent.TexVertices[wrkFace[1]].z);
  w3 := vertex(Parent.TexVertices[wrkFace[2]].x,Parent.TexVertices[wrkFace[2]].y,Parent.TexVertices[wrkFace[2]].z);


  x1 := v2.x - v1.x;
  x2 := v3.x - v1.x;
  y1 := v2.y - v1.y;
  y2 := v3.y - v1.y;
  z1 := v2.z - v1.z;
  z2 := v3.z - v1.z;

  s1 := w2.x - w1.x;
  s2 := w3.x - w1.x;
  t1 := w2.y - w1.y;
  t2 := w3.y - w1.y;

  d := (s1 * t2 - s2 * t1);
  if abs(d)<0.00001 then d:=1.0;

  r := 1.0 / d;

  sdir := vertex((t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r,(t2 * z1 - t1 * z2) * r);
  tdir := vertex((s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r,(s1 * z2 - s2 * z1) * r);

  tan1[wrkFace[0]]:=add(tan1[wrkFace[0]],sdir);
  tan1[wrkFace[1]]:=add(tan1[wrkFace[1]],sdir);
  tan1[wrkFace[2]]:=add(tan1[wrkFace[2]],sdir);

  tan2[wrkFace[0]]:=add(tan2[wrkFace[0]],tdir);
  tan2[wrkFace[1]]:=add(tan2[wrkFace[1]],tdir);
  tan2[wrkFace[2]]:=add(tan2[wrkFace[2]],tdir);

 end;

for i := 0 to VertexCount - 1 do
 begin

   n:=vertex(SmoothNormals[i].x,SmoothNormals[i].y,SmoothNormals[i].z);
   t:=tan1[i];

   dot:=DotProduct(n,t);
   temp2:=vertex(n.X*dot,n.Y*dot,n.Z*dot);

   Temp:=vertex(t.X-temp2.X,t.Y-temp2.Y,t.Z-temp2.Z);

   Temp:=Normalize(Temp);

   tangent[i].bitangent:=cross(n, Temp);

   tangent[i].tangent:=vertex4D(Temp.X,Temp.Y,Temp.Z,0.0);

   if (DotProduct(Cross(n, t),tan2[i]))<0 then
   tangent[i].tangent.W:=-1.0 else tangent[i].tangent.W:=1.0;

 end;

end;
{------------------------------------------------------------------}
procedure TGLMesh.CalcNormals(Inverted : boolean);
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

     if Inverted then
     begin
     wrkVector.x :=- (nx / wrki);
     wrkVector.y :=- (ny / wrki);
     wrkVector.z :=- (nz / wrki);
     end else
     begin
     wrkVector.x := nx / wrki;
     wrkVector.y := ny / wrki;
     wrkVector.z := nz / wrki;
     end;
     FasetNormals[i] := wrkVector;
  end;
end;
{------------------------------------------------------------------}
procedure TGLMesh.Draw(Smooth, Textured: Boolean);
var
   i : Integer;
   Face,TexFace : TGLFace;
   TexVertex : TGLVertex;
   draw_vbo : boolean;
begin

if bump_active then
 begin
 if not Textured then Exit;
 if not Smooth then Smooth:=true;
 end;

if invbo then
begin
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState( GL_NORMAL_ARRAY);

  glBindBufferARB   (GL_ARRAY_BUFFER_ARB,V_Buff);
  glBindBufferARB   (GL_ELEMENT_ARRAY_BUFFER_ARB,F_Buff);

  if not Smooth then
  glNormalPointer   (GL_FLOAT,0,Pointer(AllVertiches*SizeOf(TGLVertex)))
  else
  glNormalPointer   (GL_FLOAT,0,Pointer(AllVertiches*SizeOf(TGLVertex)*2));

  glVertexPointer   (3,GL_FLOAT,0,nil);

  if Parent.TexturePresent then
  begin

  if MultyTexActive then glClientActiveTextureARB(GL_TEXTURE0_ARB);

  glEnableClientState( GL_TEXTURE_COORD_ARRAY );
  glTexCoordPointer (2,GL_FLOAT,0,Pointer(AllVertiches*SizeOf(TGLVertex)*3));

  if MultyTexActive and bump_active then
  begin
  glClientActiveTextureARB(GL_TEXTURE1_ARB);
  glEnableClientState( GL_TEXTURE_COORD_ARRAY );
  glTexCoordPointer (3,GL_FLOAT,0,Pointer(AllVertiches*(SizeOf(TGLVertex)*3+SizeOf(TGLVertex2))));
  glClientActiveTextureARB(GL_TEXTURE2_ARB);
  glEnableClientState( GL_TEXTURE_COORD_ARRAY );
  glTexCoordPointer (3,GL_FLOAT,0,Pointer(AllVertiches*(SizeOf(TGLVertex)*4+SizeOf(TGLVertex2))));
  glClientActiveTextureARB(GL_TEXTURE3_ARB);
  glEnableClientState( GL_TEXTURE_COORD_ARRAY );
  glTexCoordPointer (3,GL_FLOAT,0,Pointer(AllVertiches*(SizeOf(TGLVertex)*5+SizeOf(TGLVertex2))));
  end;
  end;

  glDrawElements(GL_Triangles,FacesCount*3,GL_UNSIGNED_INT,nil);

  if Parent.TexturePresent then
  begin
  if MultyTexActive then
  begin
  glClientActiveTextureARB(GL_TEXTURE1_ARB);
  glDisableClientState( GL_TEXTURE_COORD_ARRAY );
  glClientActiveTextureARB(GL_TEXTURE2_ARB);
  glDisableClientState( GL_TEXTURE_COORD_ARRAY );
  glClientActiveTextureARB(GL_TEXTURE3_ARB);
  glDisableClientState( GL_TEXTURE_COORD_ARRAY );
  glClientActiveTextureARB(GL_TEXTURE0_ARB);
  end;
  if MultyTexActive then glClientActiveTextureARB(GL_TEXTURE0_ARB);
  glDisableClientState( GL_TEXTURE_COORD_ARRAY );
  end;

  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState( GL_NORMAL_ARRAY);

end else
begin
glBegin(GL_TRIANGLES);
  for i := 0 to FacesCount - 1 do begin
      Face := Faces[i];
      if Smooth then begin
        glNormal3fv(@SmoothNormals[Face[0]]);
        if Textured then begin
           TexFace := Parent.TexFaces[i];
           TexVertex := Parent.TexVertices[TexFace[0]];
           if not bump_active then
           _glTexCoord2f(TexVertex.x,1-TexVertex.y)
           else
           begin
            _glTexCoord2f(TexVertex.x,1-TexVertex.y,0);
            _glTexCoord3f(Tangent[Face[0]].bitangent.x,Tangent[Face[0]].bitangent.y,Tangent[Face[0]].bitangent.z,1);
            _glTexCoord3f(Tangent[Face[0]].tangent.x,Tangent[Face[0]].tangent.y,Tangent[Face[0]].tangent.z,2);
            _glTexCoord3f(SmoothNormals[Face[0]].x,SmoothNormals[Face[0]].y,SmoothNormals[Face[0]].z,3);
           end;
        end;
        glVertex3fv(@Vertices[Face[0]]);
        glNormal3fv(@SmoothNormals[Face[1]]);
        if Textured then begin
           TexFace := Parent.TexFaces[i];
           TexVertex := Parent.TexVertices[TexFace[1]];
           if not bump_active then
           _glTexCoord2f(TexVertex.x,1-TexVertex.y)
           else
           begin
            _glTexCoord2f(TexVertex.x,1-TexVertex.y,0);
            _glTexCoord3f(Tangent[Face[1]].bitangent.x,Tangent[Face[1]].bitangent.y,Tangent[Face[1]].bitangent.z,1);
            _glTexCoord3f(Tangent[Face[1]].tangent.x,Tangent[Face[1]].tangent.y,Tangent[Face[1]].tangent.z,2);
            _glTexCoord3f(SmoothNormals[Face[1]].x,SmoothNormals[Face[1]].y,SmoothNormals[Face[1]].z,3);
           end;
        end;
        glVertex3fv(@Vertices[Face[1]]);
        glNormal3fv(@SmoothNormals[Face[2]]);
        if Textured then begin
           TexFace := Parent.TexFaces[i];
           TexVertex := Parent.TexVertices[TexFace[2]];
           if not bump_active then
           _glTexCoord2f(TexVertex.x,1-TexVertex.y)
           else
           begin
            _glTexCoord2f(TexVertex.x,1-TexVertex.y,0);
            _glTexCoord3f(Tangent[Face[2]].bitangent.x,Tangent[Face[2]].bitangent.y,Tangent[Face[2]].bitangent.z,1);
            _glTexCoord3f(Tangent[Face[2]].tangent.x,Tangent[Face[2]].tangent.y,Tangent[Face[2]].tangent.z,2);
            _glTexCoord3f(SmoothNormals[Face[2]].x,SmoothNormals[Face[2]].y,SmoothNormals[Face[2]].z,3);
           end;
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
  end;
glEnd;
end;
end;
{------------------------------------------------------------------}
destructor TGLMesh.Destroy;
begin
   if invbo then
   begin
    glDeleteBuffersARB(1,@V_Buff);
    glDeleteBuffersARB(1,@F_Buff);
   end
   else
   begin
   FreeMem(FasetNormals,FacesCount*SizeOf(TGLVector));
   end;

   FreeMem(Vertices,VertexCount*SizeOf(TGLVertex));
   FreeMem(SmoothNormals,VertexCount*SizeOf(TGLVertex));
   FreeMem(Faces,FacesCount*SizeOf(TGLFace));

   Tangent:=nil;

end;
{------------------------------------------------------------------}
procedure TGLMultyMesh.LoadFromFile( const FileName : String;Inverted : boolean );
var

   ResData:array of TGLVertex; // массивы для VBO
   ResNorm:array of TGLVertex;
   ResNormSmooth:array of TGLVertex;
   biTangentTEX,TangentTEX,NormalTEX :array of TGLVertex;
   ResTCrd:array of TGLVertex2;
   VBOVertexCounter : cardinal;

   OverallMaxVertex : single;
   f : TextFile;
   S : String;
   procedure ReadNextMesh(AParent : TGLMultyMesh);
     var
        i,j : Integer;
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

          NextMesh.CalcNormals(Inverted);
          ReadLn(f,S);
          ReadLn(f,S);
          if s='Smooth normals:' then
          begin
            for i := 0 to NextMesh.VertexCount - 1 do
            begin
              Readln(f,Vertex.x,Vertex.y,Vertex.z);
              NextMesh.SmoothNormals[i] := Vertex;
            end;
          end else
          NextMesh.CalcSmoothNormals;


   NextMesh.Parent := AParent;


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

   if not AParent.TexturePresent then SetLength(NextMesh.Tangent,0) else
    NextMesh.CalcTangents;

   if GL_ARB_vertex_buffer_object and _UseVBO then //Задаем VBO
   begin
    with NextMesh do
    begin
       SetLength (ResData,FacesCount*3);
       SetLength (ResNorm,FacesCount*3);
       SetLength (ResNormSmooth,FacesCount*3);
       SetLength (ResTCrd,FacesCount*3);
       SetLength (biTangentTEX,FacesCount*3);
       SetLength (TangentTEX,FacesCount*3);
       SetLength (NormalTEX,FacesCount*3);

       VBOVertexCounter:=0;
       for i:=0 to FacesCount-1 do
        for j := 0 to 2 do
        begin
         // Формируем треугольник
         ResData[VBOVertexCounter]:=Vertices[Faces[i][j]];
         ResNorm[VBOVertexCounter]:= FasetNormals[i];
         ResNormSmooth[VBOVertexCounter]:=SmoothNormals[Faces[i][j]];
         if AParent.TexturePresent then
         begin

         ResTCrd[VBOVertexCounter].u:=AParent.TexVertices[AParent.TexFaces[i][j]].x;
         ResTCrd[VBOVertexCounter].v:=1-AParent.TexVertices[AParent.TexFaces[i][j]].y;

         biTangentTEX[VBOVertexCounter].x:=Tangent[Faces[i][j]].bitangent.x;
         biTangentTEX[VBOVertexCounter].y:=Tangent[Faces[i][j]].bitangent.y;
         biTangentTEX[VBOVertexCounter].z:=Tangent[Faces[i][j]].bitangent.z;

         TangentTEX[VBOVertexCounter].x:=Tangent[Faces[i][j]].tangent.x;
         TangentTEX[VBOVertexCounter].y:=Tangent[Faces[i][j]].tangent.y;
         TangentTEX[VBOVertexCounter].z:=Tangent[Faces[i][j]].tangent.z;

         NormalTEX[VBOVertexCounter].x:=SmoothNormals[Faces[i][j]].x;
         NormalTEX[VBOVertexCounter].y:=SmoothNormals[Faces[i][j]].y;
         NormalTEX[VBOVertexCounter].z:=SmoothNormals[Faces[i][j]].z;

         end;
         Faces[i][j]:=VBOVertexCounter;
         inc(VBOVertexCounter);
        end;

      AllVertiches:=VBOVertexCounter;

        glGenBuffersARB(1, @V_Buff);
        glBindBufferARB(GL_ARRAY_BUFFER_ARB,V_Buff);

        if AParent.TexturePresent then
        glBufferDataARB(GL_ARRAY_BUFFER_ARB,AllVertiches*(SizeOf(TGLVertex)*3+SizeOf(TGLVertex2)+SizeOf(TGLVertex)*3), nil, GL_STATIC_DRAW_ARB)
        else
        glBufferDataARB(GL_ARRAY_BUFFER_ARB,AllVertiches*(SizeOf(TGLVertex)*3), nil, GL_STATIC_DRAW_ARB);

        glBufferSubDataARB(GL_ARRAY_BUFFER_ARB, 0,AllVertiches*SizeOf(TGLVertex),@ResData [0]);
        glBufferSubDataARB(GL_ARRAY_BUFFER_ARB,AllVertiches*SizeOf(TGLVertex),AllVertiches*SizeOf(TGLVertex),@ResNorm [0]);
        glBufferSubDataARB(GL_ARRAY_BUFFER_ARB,AllVertiches*SizeOf(TGLVertex)*2,AllVertiches*SizeOf(TGLVertex),@ResNormSmooth [0]);

        if AParent.TexturePresent then
        begin
        glBufferSubDataARB(GL_ARRAY_BUFFER_ARB,AllVertiches*SizeOf(TGLVertex)*3,AllVertiches*SizeOf(TGLVertex2),@ResTCrd [0]);

        glBufferSubDataARB(GL_ARRAY_BUFFER_ARB,AllVertiches*(SizeOf(TGLVertex)*3+SizeOf(TGLVertex2)),AllVertiches*SizeOf(TGLVertex),@biTangentTEX [0]);
        glBufferSubDataARB(GL_ARRAY_BUFFER_ARB,AllVertiches*(SizeOf(TGLVertex)*3+SizeOf(TGLVertex2)+SizeOf(TGLVertex)),AllVertiches*SizeOf(TGLVertex),@TangentTEX [0]);
        glBufferSubDataARB(GL_ARRAY_BUFFER_ARB,AllVertiches*(SizeOf(TGLVertex)*3+SizeOf(TGLVertex2)+SizeOf(TGLVertex)*2),AllVertiches*SizeOf(TGLVertex),@NormalTEX [0]);
        end;

        glGenBuffersARB(1,@F_Buff);
        glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB,F_Buff);
        glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER_ARB,Sizeof(TGLFace)*FacesCount, Faces,GL_STATIC_DRAW_ARB);

       ResData := nil;
       ResNorm := nil;
       ResTCrd := nil;
       ResNormSmooth:= nil;
       biTangentTEX := nil;
       TangentTEX := nil;
       NormalTEX  := nil;

        FreeMem(FasetNormals,FacesCount*SizeOf(TGLVector));

      invbo:=true;
    end;
   end else NextMesh.invbo:=false;

 Meshes.Add(NextMesh);
 end;

   procedure ReadMaterial;
   var
   r,g,b : single;
   begin
    MaterialPresented := true;
    Readln(f,S);
    Readln(f,r,g,b);
    Material.diffuse[0]:=trunc(r);
    Material.diffuse[1]:=trunc(g);
    Material.diffuse[2]:=trunc(b);
    Readln(f,S);
    Readln(f,S);
    Readln(f,S);
    Readln(f,S);
    Readln(f,S);
    Readln(f,Material.glossiness);
    Readln(f,S);
    Readln(f,r);
    Material.alpha := trunc(255/100*r);
    Readln(f,S);
    Readln(f,Material.TexFileName);
    Readln(f,S);
    Readln(f,Material.NormalMapFileName);
    Readln(f,S);
    Readln(f,Material.SpecularMapFileName);
   end;

   procedure ReadTextureBlock;
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
   fAllScale:=1.0;
   OverallMaxVertex:=0.0;
   MaterialPresented:=false;
   Meshes := TList.Create;
   AssignFile(f,FileName);
   Reset(f);
   While not Eof(f) do begin
     Readln(f,S);
     if S = 'New Texture:' then ReadTextureBlock;
   end;
   Reset(f);
   While not Eof(f) do begin
     Readln(f,S);
     if S = 'New object' then ReadNextMesh(Self);
     if S = 'Material:' then ReadMaterial;
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
  TexturePresent:=false;
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
