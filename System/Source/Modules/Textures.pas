//----------------------------------------------------------------------------//
//DRON's OpenGl Engine V 1.0 http://dronprogs.mirgames.ru                     //
//                                                                            //
// Textures.pas V 1.1, 29.04.2008                                             //
//                                                                            //
// This module provides all texture loading and creating routines.            //
//                                                                            //
// Based on code by Jan Horn                                                  //
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
unit Textures;

interface

uses
  Windows,
  OpenGL,
  Graphics,
  JPEG,
  Classes,
  SysUtils,
  EngineUtils,
  Variables,
  DPC_packages;


procedure FreeTexture(Texture : TGLuint); stdcall;
function  GetTextureInfo(Texture : Cardinal) : TTextureInfo; stdcall;
function  CreateTexture(Width, Height, Format : Word; pData : Pointer) : Cardinal; stdcall;
function  CreateRenderTex(Width, Height : integer) : GluInt;
procedure WriteTextureInfo(Ind : cardinal; W,H : integer; Det, Typ : byte); stdcall;
function  LoadFontFromFile(Filename : string) : Cardinal; stdcall;
procedure FreeFont(Ident : cardinal); stdcall;
function  CreateShadowMap(Size : integer):GLUInt; stdcall;
procedure TextureParametrs(Texture : TGluint; Param : byte); stdcall;

function  LoadTexture(BMP : TBitmap; Quality : byte; TransparentColor : integer; ColorTolerance : byte = 0; AlphaMask : TBitmap = nil) : TGLuint; stdcall;
function  LoadTGATexture(Filename : String; var Texture : TGLuint; Stream : TMemoryStream = nil) : Boolean; stdcall;
function  LoadTextureFromPackage(FileName, Name : string; Detail : byte; TransparentColor : integer) : TGLuint;  stdcall;
function  LoadTextureFromFile(FileName: String; Detail : byte; TransparentColor : integer) : TGLuint;  stdcall;
procedure SetDefaultJPGTransparentColorTolerance(Tolerance : byte); stdcall;

//function GetNormalisationCubeMap : cardinal; stdcall;
//function GenerateNormalisationCubeMap : cardinal;

procedure LoadLogo;

var
Logo : Gluint;
DefJPGTolerance : byte = 15;
const
LOGO_SIZE = 128;
implementation
uses DrawFunc3D;

procedure SetDefaultJPGTransparentColorTolerance(Tolerance : byte); stdcall;
begin
DefJPGTolerance:=Tolerance;
end;
{------------------------------------------------------------------}
procedure LoadLogo;
 function Birthday : boolean;
  var s : string;
  begin
  s:=DateToStr(Now);
  if (s[1]='3') and (s[2]='0') and  (s[3]='.') and (s[4]='0') and (s[5]='5') then
  result:=true else result:=false;
  end;
var
ResourceStream : TResourceStream;
B : TBitmap; b_day : boolean;
begin
b_day:=Birthday;
if b_day then ShowLogo:=true;
if ShowLogo then
begin
if b_day then ResourceStream :=TResourceStream.Create(hInstance, 'BIRTH', 'LOGO') else
 if random(2)=1 then
  ResourceStream :=TResourceStream.Create(hInstance, 'DGLE_LOGO2', 'LOGO') else
   ResourceStream :=TResourceStream.Create(hInstance, 'DGLE_LOGO', 'LOGO');
B := TBitmap.Create;
B.LoadFromStream(ResourceStream);
ResourceStream.Free;
Logo:=LoadTexture(B,0,$FFFF00);
B.Free;
end;
end;
{------------------------------------------------------------------}
procedure FreeFont(Ident : cardinal); stdcall;
begin
DGLFonts[Ident].Load:=false;
glDeletetextures(1,@DGLFonts[Ident].Texture);
end;
{------------------------------------------------------------------}
function LoadFontFromFile(Filename : string) : Cardinal; stdcall;
var
pBits : pByteArray;
i : integer;
F : file;
FontHeader : TFontHeader;
begin
if fileexists(Filename) then
begin
setlength(DGLFonts,length(DGLFonts)+1);

 AssignFile(F,FileName);
 Reset(F,1);
 BlockRead(F, FontHeader, sizeof(FontHeader));

 if FontHeader.version<>1 then
 begin
 MessageBox(0, PChar('Incorrect font("'+ Filename +'") version!'), PChar('FONT Unit'), MB_OK or MB_ICONERROR);
 AddToLogFile(EngineLog,'Incorrect font("'+ Filename +'") version!');
 result:=0;
 Exit;
 end;

 GetMem(pBits,FontHeader.Width*FontHeader.Height);
 BlockRead(F, pBits[0], sizeof(byte)*FontHeader.Width*FontHeader.Height);
 CloseFile(F);

 DGLFonts[length(DGLFonts)-1].Load:=true;
 DGLFonts[length(DGLFonts)-1].Width:=FontHeader.Width;
 DGLFonts[length(DGLFonts)-1].Height:=FontHeader.Height;

 for i:=0 to 223 do
 DGLFonts[length(DGLFonts)-1].Buks[i]:=FontHeader.Buks[i];

DGLFonts[length(DGLFonts)-1].texture:=CreateTexture(FontHeader.Width,FontHeader.Height,GL_ALPHA,pBits);

FreeMem(pBits);

result:=length(DGLFonts)-1;

AddToLogFile(EngineLog,'Font "'+ Filename +'" loaded successfully.');

end else
begin
setlength(DGLFonts,length(DGLFonts)+1);
DGLFonts[length(DGLFonts)-1].Load:=false;
result:=length(DGLFonts)-1;
MessageBox(0, PChar('File "'+ Filename +'" not found!'), PChar('FONT Unit'), MB_OK or MB_ICONERROR);
AddToLogFile(EngineLog,'File "'+ Filename +'" not found!');
end;
end;
{------------------------------------------------------------------}
function GetTextureInfo(Texture : Cardinal) : TTextureInfo; stdcall;
var i : integer;
begin
if length(TexturesInfo)<>0 then
 for i:=0 to length(TexturesInfo)-1 do
  if TexturesInfo[i].Index=Texture then
   begin
   result:=TexturesInfo[i];
   Exit;
   end;
 result.Index:=0;
 result.Width:=0;
 result.Height:=0;
 result.Detail:=0;
 result.FileType:=0;
end;
{------------------------------------------------------------------}
procedure WriteTextureInfo(Ind : cardinal; W,H : integer; Det, Typ : byte); stdcall;
begin
 SetLength(TexturesInfo,length(TexturesInfo)+1);
 TexturesInfo[length(TexturesInfo)-1].Index:=ind;
 TexturesInfo[length(TexturesInfo)-1].Width:=W;
 TexturesInfo[length(TexturesInfo)-1].Height:=H;
 TexturesInfo[length(TexturesInfo)-1].Detail:=Det;
 TexturesInfo[length(TexturesInfo)-1].FileType:=Typ;
end;
{------------------------------------------------------------------}
procedure FreeTexture(Texture : TGLuint); stdcall;
var i : integer;
begin

if length(TexturesInfo)<>0 then
  for i:=0 to length(TexturesInfo)-1 do
   if TexturesInfo[i].Index=Texture then
     begin
     glDeleteTextures(1,@TexturesInfo[i].Index);
     if length(TexturesInfo)>1 then
     TexturesInfo[i]:=TexturesInfo[length(TexturesInfo)-1];
     SetLength(TexturesInfo,length(TexturesInfo)-1);
     Exit;
     end;
     
end;
{------------------------------------------------------------------}
function CreateRenderTex(Width, Height : integer) : GluInt;
var
  Texture : GLuint;
begin
  glGenTextures(1, @Texture);
  glBindTexture(GL_TEXTURE_2D, Texture);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  if GL_EXT_framebuffer_object then
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, Width, Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0)
  else
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, Width, Height, 0, GL_RGB, GL_UNSIGNED_BYTE, 0);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  WriteTextureInfo(Texture,Width,Height,0,4);
  result:=Texture;
  glBindTexture(GL_TEXTURE_2D, 0);
end;
{------------------------------------------------------------------}
{
function GetNormalisationCubeMap : cardinal; stdcall;
begin
  result:=_NormCubemap;
end;
}
{------------------------------------------------------------------}
{
function GenerateNormalisationCubeMap : cardinal;
const
 Offset   = 0.5;
 Size     = 32;
 HalfSize = Size div 2;
var
 Data       : array[0..Size-1,0..Size-1,0..2] of Byte;
 TempVector : TVertex;
 i,j,CFace  : Integer;
 len : single;
begin
if GL_ARB_texture_cube_map then
begin
glGenTextures(1, @result);
glBindTexture(GL_TEXTURE_CUBE_MAP_ARB, result);

for CFace := 0 to 5 do
 begin
 for i := 0 to High(Data) do
  for j := 0 to High(Data[i]) do
   begin
   case GL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB+CFace of
    GL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB : begin
                                         TempVector.x := HalfSize;
                                         TempVector.y := -(j+Offset-HalfSize);
                                         TempVector.z := -(i+Offset-HalfSize);
                                         end;
    GL_TEXTURE_CUBE_MAP_NEGATIVE_X_ARB : begin
                                         TempVector.x := -HalfSize;
                                         TempVector.y := -(j+Offset-HalfSize);
                                         TempVector.z := i+Offset-HalfSize;
                                         end;
    GL_TEXTURE_CUBE_MAP_POSITIVE_Y_ARB : begin
                                         TempVector.x := i+Offset-HalfSize;
                                         TempVector.y := HalfSize;
                                         TempVector.z := j+Offset-HalfSize;
                                         end;
    GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_ARB : begin
                                         TempVector.x := i+Offset-HalfSize;
                                         TempVector.y := -HalfSize;
                                         TempVector.z := -(j+Offset-HalfSize);
                                         end;
    GL_TEXTURE_CUBE_MAP_POSITIVE_Z_ARB : begin
                                         TempVector.x := i+Offset-HalfSize;
                                         TempVector.y := -(j+Offset-HalfSize);
                                         TempVector.z := HalfSize;
                                         end;
    GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_ARB : begin
                                         TempVector.x := -(i+Offset-HalfSize);
                                         TempVector.y := -(j+Offset-HalfSize);
                                         TempVector.z := -HalfSize;
                                         end;
    end;

   len := sqrt(TempVector.X*TempVector.X+TempVector.Y*TempVector.Y+TempVector.Z*TempVector.Z);
   TempVector.X:=TempVector.X/len;
   TempVector.Y:=TempVector.Y/len;
   TempVector.Z:=TempVector.Z/len;

   TempVector.X:=TempVector.X*0.5;
   TempVector.Y:=TempVector.Y*0.5;
   TempVector.Z:=TempVector.Z*0.5;

   TempVector.X:=TempVector.X+0.5;
   TempVector.Y:=TempVector.Y+0.5;
   TempVector.Z:=TempVector.Z+0.5;

   Data[j,i,0] := Round(TempVector.x*255);
   Data[j,i,1] := Round(TempVector.y*255);
   Data[j,i,2] := Round(TempVector.z*255);
   end;
 glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB+CFace, 0, GL_RGBA8, Size, Size, 0, GL_RGB, GL_UNSIGNED_BYTE, @Data);
 end;

glTexParameteri(GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
glTexParameteri(GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexParameteri(GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
glTexParameteri(GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
glTexParameteri(GL_TEXTURE_CUBE_MAP_ARB, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);

glBindTexture(GL_TEXTURE_CUBE_MAP_ARB, 0);

//WriteTextureInfo(result, Size, Size, 0, 4);
end else result:=0;
end;
}
{------------------------------------------------------------------}
function CreateShadowMap(Size : integer):GLUInt; stdcall;
var
  Texture : GLuint; comp : integer;
begin
 if GL_ARB_depth_texture then
 begin

 glGenTextures(1, @Texture);
 glBindTexture(GL_TEXTURE_2D, Texture);

  case InitZBuffer of
  16:comp:=GL_DEPTH_COMPONENT16_ARB;
  24:comp:=GL_DEPTH_COMPONENT24_ARB;
  32:comp:=GL_DEPTH_COMPONENT32_ARB;
  else comp:=GL_DEPTH_COMPONENT24_ARB;
  end;

 glTexImage2D(GL_TEXTURE_2D, 0, comp, Size, Size, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_BYTE, 0);
 WriteTextureInfo(Texture,Size,Size,0,5);
 glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_2D, GL_DEPTH_TEXTURE_MODE_ARB, GL_LUMINANCE);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE_ARB, GL_COMPARE_R_TO_TEXTURE_ARB);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC_ARB, GL_LEQUAL);
 if GL_ARB_shadow_ambient then glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FAIL_VALUE_ARB, 0.2);
 glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR);
 glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR);
 glTexGeni(GL_R, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR);
 result :=Texture;
 glBindTexture(GL_TEXTURE_2D, 0);

 end else result:=CreateRenderTex(2,2);
end;
{------------------------------------------------------------------}
function CreateTexture(Width, Height, Format : Word; pData : Pointer) : Cardinal; stdcall;

 function GetNearestCorrectSize(Size : Word) : Word;
 begin
  if Size> 4096 then result:=4096;
  if Size<=4096 then result:=4096;
  if Size<=2048 then result:=2048;
  if Size<=1024 then result:=1024;
  if Size<=512  then result:=512;
  if Size<=256  then result:=256;
  if Size<=128  then result:=128;
  if Size<=64   then result:=64;
  if Size<=32   then result:=32;
  if Size<=16   then result:=16;
  if Size<=8    then result:=8;
  if Size<=4    then result:=4;
  if Size<=2    then result:=2;
 end;

 function IsCorrectSize(Size : Word) : boolean;
 begin
  result:= (Size=2) or (Size=4) or (Size=8) or (Size=16) or (Size=32) or (Size=64) or (Size=128) or
  (Size=256) or (Size=512) or (Size=1024) or (Size=2048) or (Size=4096);
 end;

var
  Texture : GLuint;
  pData2 : pointer;
  Format2, WOld, HOld : Word;
  NeedResize : boolean;
  i : integer;
begin

  if not GL_ARB_texture_non_power_of_two then
  begin
  NeedResize:=not (IsCorrectSize(Width) and IsCorrectSize(Height));

  if NeedResize then
  begin
  AddToLogFile(EngineLog,'Texture is being scaled to nearest suitable size.');

  WOld:=Width;
  HOld:=Height;

  Width:=GetNearestCorrectSize(Width);
  Height:=GetNearestCorrectSize(Height);

  case Format of
  GL_RGB  : GetMem(pData2,Width*Height*3);
  GL_RGBA : GetMem(pData2,Width*Height*4);
  GL_ALPHA: GetMem(pData2,Width*Height);
  end; //case

   gluScaleImage(Format, WOld, HOld, GL_UNSIGNED_BYTE, pData, Width, Height, GL_UNSIGNED_BYTE, pData2);

  end;
  end else NeedResize:=false;

  glGetIntegerv(GL_MAX_TEXTURE_SIZE,@i);

  if (Width>i) or (Height>i) then
  begin
  AddToLogFile(EngineLog,'Your card does not support such big textures!');
  WOld:=Width;
  HOld:=Height;
  if Width>i then Width:=i;
  if Height>i then Height:=i;
  AddToLogFile(EngineLog,'Texture is being rescaled.');
  gluScaleImage(Format, WOld, HOld, GL_UNSIGNED_BYTE, pData, Width, Height, GL_UNSIGNED_BYTE, pData2);
  end;

  glGenTextures(1, @Texture);
  glBindTexture(GL_TEXTURE_2D, Texture);

  if GL_ARB_texture_compression and _TextureCompression then
  case Format of
  GL_RGB  : Format2:=GL_COMPRESSED_RGB_ARB;
  GL_RGBA : Format2:=GL_COMPRESSED_RGBA_ARB;
  GL_ALPHA: Format2:=GL_COMPRESSED_ALPHA_ARB;
  end else Format2:=Format;

  if not NeedResize then

    if MipMapping then
    gluBuild2DMipmaps(GL_TEXTURE_2D, Format2, Width, Height, Format, GL_UNSIGNED_BYTE, pData)
    else
    glTexImage2D(GL_TEXTURE_2D, 0, Format2, Width, Height, 0, Format, GL_UNSIGNED_BYTE, pData)

    else

    if MipMapping then
    gluBuild2DMipmaps(GL_TEXTURE_2D, Format2, Width, Height, Format, GL_UNSIGNED_BYTE, pData2)
    else
    glTexImage2D(GL_TEXTURE_2D, 0, Format2, Width, Height, 0, Format, GL_UNSIGNED_BYTE, pData2);

  if NeedResize then FreeMem(pData2);

  if MipMapping then
  begin

   if _TextureFiltering then
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR)
     else glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST_MIPMAP_NEAREST);

  end else
  begin

  if _TextureFiltering then
   glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR) else
   glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);

  end;

  if _TextureFiltering then
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR) else
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);

  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

  result :=Texture;
  glBindTexture(GL_TEXTURE_2D, 0);
end;
{------------------------------------------------------------------}
procedure TextureParametrs(Texture : TGluint; Param : byte); stdcall;
begin
 glBindTexture(GL_TEXTURE_2D, Texture);
 case param of
 0:
 begin
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_REPEAT);
 end;
 1:
 begin
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
 end;
 end;//case
 glBindTexture(GL_TEXTURE_2D, 0);
end;
{------------------------------------------------------------------}
function LoadTGATexture(Filename : String; var Texture : TGLuint; Stream : TMemoryStream = nil) : Boolean; stdcall;
var
  TGAHeader : packed record
    FileType     : Byte;
    ColorMapType : Byte;
    ImageType    : Byte;
    ColorMapSpec : Array[0..4] of Byte;
    OrigX  : Array [0..1] of Byte;
    OrigY  : Array [0..1] of Byte;
    Width  : Array [0..1] of Byte;
    Height : Array [0..1] of Byte;
    BPP    : Byte;
    ImageInfo : Byte;
  end;
  TGAFile   : File;
  bytesRead : Integer;
  image     : Pointer;
  CompImage : Pointer;
  Width, Height : Integer;
  ColorDepth    : Integer;
  ImageSize     : Integer;
  BufferIndex : Integer;
  currentByte : Integer;
  CurrentPixel : Integer;
  I : Integer;
  Front: ^Byte;
  Back: ^Byte;
  Temp: Byte;

  procedure CopySwapPixel(const Source, Destination : Pointer);
  asm
    push ebx
    mov bl,[eax+0]
    mov bh,[eax+1]
    mov [edx+2],bl
    mov [edx+1],bh
    mov bl,[eax+2]
    mov bh,[eax+3]
    mov [edx+0],bl
    mov [edx+3],bh
    pop ebx
  end;

begin

  result :=FALSE;
  GetMem(Image, 0);

 if Stream<>nil then
 begin
  Stream.ReadBuffer(TGAHeader, SizeOf(TGAHeader));
  result :=TRUE;
 end else
 if fileexists(Filename) then
  begin
  AssignFile(TGAFile, Filename);
  Reset(TGAFile, 1);
  BlockRead(TGAFile, TGAHeader, SizeOf(TGAHeader));
  result :=TRUE;
  end else
    begin
      MessageBox(0, PChar('File "'+ Filename +'" not found!'), PChar('TGA Unit'), MB_OK or MB_ICONERROR);
      AddToLogFile(EngineLog,'File "'+ Filename +'" not found!');
      Exit;
    end;

  if Result = TRUE then
  begin
    Result :=FALSE;

    if (TGAHeader.ImageType <> 2) and (TGAHeader.ImageType <> 10) then
    begin
      Result := False;
      if Stream=nil then
      CloseFile(tgaFile);
      MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Only 24 and 32bit TGA supported.'), PChar('TGA Unit'), MB_OK or MB_ICONERROR);
      AddToLogFile(EngineLog,'Couldn''t load "'+ Filename +'". Only 24 and 32bit TGA supported.');
      Exit;
    end;

    if TGAHeader.ColorMapType <> 0 then
    begin
      Result := False;
      if Stream=nil then
      CloseFile(TGAFile);
      MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Colormapped TGA files not supported.'), PChar('TGA Unit'), MB_OK or MB_ICONERROR);
      AddToLogFile(EngineLog,'Couldn''t load "'+ Filename +'". Colormapped TGA files not supported.');
      Exit;
    end;

    Width  := TGAHeader.Width[0]  + TGAHeader.Width[1]  * 256;
    Height := TGAHeader.Height[0] + TGAHeader.Height[1] * 256;
    ColorDepth := TGAHeader.BPP;
    ImageSize  := Width*Height*(ColorDepth div 8);

    if ColorDepth < 24 then
    begin
      Result := False;
      if Stream=nil then
      CloseFile(TGAFile);
      MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Only 24 bit TGA files supported.'), PChar('TGA Unit'), MB_OK or MB_ICONERROR);
      AddToLogFile(EngineLog,'Couldn''t load "'+ Filename +'". Only 24 bit TGA files supported.');
      Exit;
    end;

    GetMem(Image, ImageSize);

    if TGAHeader.ImageType = 2 then
      if Stream<>nil then
      begin

       try
       Stream.ReadBuffer(Image^, ImageSize);
       except
        result:=false;
        MessageBox(0, PChar('Couldn''t read stream "'+ Filename +'"!'), PChar('TGA Unit'), MB_OK or MB_ICONERROR);
        AddToLogFile(EngineLog,'Couldn''t read stream "'+ Filename +'"!');
        Exit;
       end;

      end else
      begin
      BlockRead(TGAFile, image^, ImageSize, bytesRead);
      if bytesRead <> ImageSize then
       begin
        Result := False;
        CloseFile(TGAFile);
        MessageBox(0, PChar('Couldn''t read file "'+ Filename +'"!'), PChar('TGA Unit'), MB_OK or MB_ICONERROR);
        AddToLogFile(EngineLog,'Couldn''t read file "'+ Filename +'"!');
        Exit;
       end;
      end;
    end;

 if TGAHeader.ImageType = 2 then
 begin
  if TGAHeader.BPP = 24 then
  begin
    for I :=0 to Width * Height - 1 do
    begin
      Front := Pointer(Integer(Image) + I*3);
      Back := Pointer(Integer(Image) + I*3 + 2);
      Temp := Front^;
      Front^ := Back^;
      Back^ := Temp;
    end;
    Texture :=CreateTexture(Width, Height, GL_RGB, Image);
  end
  else
  begin
    for I :=0 to Width * Height - 1 do
    begin
      Front := Pointer(Integer(Image) + I*4);
      Back := Pointer(Integer(Image) + I*4 + 2);
      Temp := Front^;
      Front^ := Back^;
      Back^ := Temp;
    end;
    Texture :=CreateTexture(Width, Height, GL_RGBA, Image);
  end;
 end;

    if TGAHeader.ImageType = 10 then
    begin
      ColorDepth :=ColorDepth DIV 8;
      CurrentByte :=0;
      CurrentPixel :=0;
      BufferIndex :=0;

      if Stream<>nil then
      begin

       try
       GetMem(CompImage, Stream.Size-sizeOf(TGAHeader));
       Stream.ReadBuffer(CompImage^, Stream.Size-sizeOf(TGAHeader));
       except
        result:=false;
        MessageBox(0, PChar('Couldn''t read stream "'+ Filename +'"!'), PChar('TGA Unit'), MB_OK or MB_ICONERROR);
        AddToLogFile(EngineLog,'Couldn''t read stream "'+ Filename +'"!');
        Exit;
       end;

      end else
      begin
        GetMem(CompImage, FileSize(TGAFile)-sizeOf(TGAHeader));
        BlockRead(TGAFile, CompImage^, FileSize(TGAFile)-sizeOf(TGAHeader), BytesRead);
        if bytesRead <> FileSize(TGAFile)-sizeOf(TGAHeader) then
        begin
          Result := False;
          CloseFile(TGAFile);
          MessageBox(0, PChar('Couldn''t read file "'+ Filename +'"!'), PChar('TGA Unit'), MB_OK or MB_ICONERROR);
          AddToLogFile(EngineLog,'Couldn''t read file "'+ Filename +'"!');
          Exit;
        end;
       end;

      repeat
        Front := Pointer(Integer(CompImage) + BufferIndex);
        Inc(BufferIndex);
        if Front^ < 128 then
        begin
          For I := 0 to Front^ do
          begin
            CopySwapPixel(Pointer(Integer(CompImage)+BufferIndex+I*ColorDepth), Pointer(Integer(image)+CurrentByte));
            CurrentByte := CurrentByte + ColorDepth;
            inc(CurrentPixel);
          end;
          BufferIndex :=BufferIndex + (Front^+1)*ColorDepth
        end
        else
        begin
          For I := 0 to Front^ -128 do
          begin
            CopySwapPixel(Pointer(Integer(CompImage)+BufferIndex), Pointer(Integer(image)+CurrentByte));
            CurrentByte := CurrentByte + ColorDepth;
            inc(CurrentPixel);
          end;
          BufferIndex :=BufferIndex + ColorDepth
        end;
      until CurrentPixel >= Width*Height;

      if ColorDepth = 3 then
        Texture :=CreateTexture(Width, Height, GL_RGB, Image)
      else
        Texture :=CreateTexture(Width, Height, GL_RGBA, Image);
    end;

  WriteTextureInfo(Texture,Width,Height,0,1);

  if Stream=nil then
  CloseFile(TGAFile);

  Result :=TRUE;
  FreeMem(Image);
end;
{------------------------------------------------------------------}
function LoadTexture(BMP : TBitmap{if nil then GL_ALPHA}; Quality : byte; TransparentColor : integer{if -1 then GL_RGB else GL_RGBA}; ColorTolerance : byte = 0{%}; AlphaMask : TBitmap = nil) : TGLuint; stdcall;
type
TRGB = array [0..1] of record
Blue, Green, Red : Byte;
end;
var
    p,am : ^TRGB;
    idx : integer;
    B2 : TBitmap;
    i,j : Integer;
    Width,
    Height, ow,oh : Integer;
    pBits : pByteArray;
    Detail : real;
begin
  result:=0;

  if (BMP=nil) and (AlphaMask=nil) then Exit;

  case Quality of
  1:Detail:=0.50;
  2:Detail:=0.25;
  else Detail:=1.0;
  end; //case

  if AlphaMask<>nil then
  begin

  AlphaMask.PixelFormat := pf24bit;

  oW := AlphaMask.Width;
  oH := AlphaMask.Height;
  end;

  if BMP<>nil then
  begin

  BMP.PixelFormat := pf24bit;

  oW := BMP.Width;
  oH := BMP.Height;
  end;

  if Quality<>0 then
  begin

  B2:=TBitmap.Create;

  B2.Width:=round(BMP.Width*Detail);
  B2.Height:=round(BMP.Height*Detail);
  B2.PixelFormat:=pf24bit;

  SetStretchBltMode(B2.Canvas.Handle, COLORONCOLOR);

  if BMP<>nil then
  begin
  StretchBlt(B2.Canvas.Handle, 0,0,B2.Width,B2.Height,BMP.Canvas.Handle, 0,0,BMP.Width,BMP.Height,SRCCOPY );

  BMP.Height:=B2.Height;
  BMP.Width:=B2.Width;

  BitBlt(BMP.Canvas.Handle,0,0,BMP.Width,BMP.Height,B2.Canvas.Handle,0,0,SRCCOPY);
  end;

  if AlphaMask<>nil then
  begin
  StretchBlt(B2.Canvas.Handle, 0,0,B2.Width,B2.Height,AlphaMask.Canvas.Handle, 0,0,AlphaMask.Width,AlphaMask.Height,SRCCOPY );

  AlphaMask.Height:=B2.Height;
  AlphaMask.Width:=B2.Width;

  BitBlt(AlphaMask.Canvas.Handle,0,0,AlphaMask.Width,AlphaMask.Height,B2.Canvas.Handle,0,0,SRCCOPY);
  end;

  B2.Free;
  end;

  if BMP<>nil then
  begin
  Width := BMP.Width;
  Height :=BMP.Height;
  end else
  begin
  Width := AlphaMask.Width;
  Height :=AlphaMask.Height;
  end;

 if (BMP=nil) and (AlphaMask<>nil) then
 begin

 GetMem(pBits,Width*Height);

  for j := 0 to Height - 1 do
  begin
  am:= AlphaMask.ScanLine[j];
   for i := 0 to Width - 1 do
    pBits[i]:=GetRValue(am[i].Red); //Any color is suitable for alpha mask
  end;

  result := CreateTexture(Width,Height,GL_ALPHA,pbits);
  WriteTextureInfo(result,ow,oh,Quality,6);

 end else
 begin

 if (TransparentColor<>-1) or (AlphaMask<>nil) then
 begin

 GetMem(pBits,Width*Height*4);

 ColorTolerance:=round(255/100*ColorTolerance);
 idx := 0;
 for j := 0 to Height - 1 do
 begin
 p := BMP.ScanLine[j];
 if AlphaMask<>nil then
 am:= AlphaMask.ScanLine[j];
 for i := 0 to Width - 1 do
 with p[ i ] do
 begin
 pBits[idx]   := Red;
 pBits[idx+1] := Green;
 pBits[idx+2] := Blue;

 if AlphaMask=nil then
 begin
     if (abs(Red-GetRValue(TransparentColor))<=ColorTolerance)   and
        (abs(Green-GetGValue(TransparentColor))<=ColorTolerance) and
        (abs(Blue-GetBValue(TransparentColor))<=ColorTolerance)
      then
     pBits[idx + 3] := 0
     else
     pBits[idx + 3] := 255;
 end else
 pBits[idx + 3] := GetRValue(am[i].Red); //Any color is suitable for alpha mask

 idx := idx + 4;
 end;
 end;
  result := CreateTexture(Width,Height,GL_RGBA,pbits);
  WriteTextureInfo(result,ow,oh,Quality,2);

 end else
 begin
 GetMem(pBits,Width*Height*3);

 idx := 0;
 for j := 0 to Height - 1 do
 begin
 p := BMP.ScanLine[j];
 for i := 0 to Width - 1 do
 with p[ i ] do
 begin
 pBits[idx]   := Red;
 pBits[idx+1] := Green;
 pBits[idx+2] := Blue;
 idx := idx + 3;
 end;
 end;
  result := CreateTexture(Width,Height,GL_RGB,pbits);
  WriteTextureInfo(result,ow,oh,Quality,3);
 end;
end;

  FreeMem(pbits);
end;
{------------------------------------------------------------------}
function LoadJPGTexture(Filename: String;Quality : byte; TransparentColor : integer; ColorTolerance : byte; FromPackage : boolean = false; Name : string = ''; OnlyAlpha : boolean = false ): GLUint;
var
  BMP : TBitmap;
  JPG : TJPEGImage;
begin
  result :=0;

  JPG:=TJPEGImage.Create;

  if FromPackage then
  try
  JPG.LoadFromStream(LoadFromPackage(Filename,Name));
  except
      MessageBox(0, PChar('Couldn''t load JPG from stream!'), PChar('JPG Unit'), MB_OK or MB_ICONERROR);
      AddToLogFile(EngineLog,'Couldn''t load JPG from stream!');
      Exit;
  end else
    try
      JPG.LoadFromFile(Filename);
    except
      //MessageBox(0, PChar('Couldn''t load JPG "'+ Filename +'"!'), PChar('JPG Unit'), MB_OK or MB_ICONERROR);
      AddToLogFile(EngineLog,'Couldn''t load JPG "'+ Filename +'"!');
      Exit;
    end;

  BMP:=TBitmap.Create;
  BMP.pixelformat:=pf24bit;
  BMP.width:=JPG.width;
  BMP.height:=JPG.height;
  BMP.canvas.draw(0,0,JPG);

  if not OnlyAlpha then
  result:=LoadTexture(BMP,Quality,TransparentColor,ColorTolerance) else
  result:=LoadTexture(nil,Quality,TransparentColor,ColorTolerance,BMP);

  JPG.Free;
  BMP.Free;
end;
{------------------------------------------------------------------}
function LoadO3TCTexture(Filename: String; FromPackage : boolean = false; Name : string = ''): GLUint;
type
TO3TC_Header = record
	_O,_3,_T,_C : char;
	header_size : cardinal;
	version : cardinal;
end;
TO3TC_Chunk_Header = record
	chunk_header_size : cardinal;
	reserved1 : cardinal;
	size : cardinal;
	reserved2:cardinal;
	// Pixel format:
	// - O3_TC_RGB_S3TC_DXT1 = 1
	// - O3_TC_RGBA_S3TC_DXT5 = 4
	// - O3_TC_ATI3DC_ATI2N = 16
	internal_pixel_format : cardinal;
	width : cardinal;
	height: cardinal;
	depth : cardinal;
	num_mipmaps : cardinal;
	texture_name : array [0..127] of char;
	texture_id : cardinal;
end;
var
s     : TMemoryStream;
h     : TO3TC_Header;
ch    : TO3TC_Chunk_Header;
data  : pByteArray;
size, mip, blockSize, width, height : integer;
format : cardinal;
Texture : Gluint;
begin
result :=0;

if not GL_ARB_texture_compression then Exit;

s := TMemoryStream.Create;

  if FromPackage then
  try
  s.LoadFromStream(LoadFromPackage(Filename,Name));
  except
      MessageBox(0, PChar('Couldn''t load O3TC from stream!'), PChar('O3TC Unit'), MB_OK or MB_ICONERROR);
      AddToLogFile(EngineLog,'Couldn''t load O3TC from stream!');
      s.Free;
      Exit;
  end else
    try
      s.LoadFromFile(Filename);
    except
      //MessageBox(0, PChar('Couldn''t load O3TC "'+ Filename +'"!'), PChar('O3TC Unit'), MB_OK or MB_ICONERROR);
      AddToLogFile(EngineLog,'Couldn''t load O3TC "'+ Filename +'"!');
      s.Free;
      Exit;
    end;

    s.Seek(4,soFromBeginning);
    s.Read(h,SizeOf(TO3TC_Header));

    if (h._O<>'O')and(h._3<>'3')and(h._T<>'T')and(h._C<>'C') then
    begin
    MessageBox(0, PChar('Couldn''t load O3TC "'+ Filename +'"! Wrong O3TC header.'), PChar('O3TC Unit'), MB_OK or MB_ICONERROR);
    AddToLogFile(EngineLog,'Couldn''t load O3TC "'+ Filename +'"! Wrong O3TC header.');
    s.Free;
    Exit;
    end;

    s.Read(ch,SizeOf(TO3TC_Chunk_Header));


  if ch.internal_pixel_format = 1 then
  begin
   blockSize := 8;
   format    := GL_COMPRESSED_RGB_S3TC_DXT1_EXT;
  end;

  if ch.internal_pixel_format = 4 then
  begin
   blockSize := 16;
   format    := GL_COMPRESSED_RGBA_S3TC_DXT5_EXT;
  end;

  if ch.internal_pixel_format = 16 then
  begin
  MessageBox(0, PChar('Couldn''t load O3TC "'+ Filename +'"! "O3_TC_ATI3DC_ATI2N" format is not supported by engine.'), PChar('O3TC Unit'), MB_OK or MB_ICONERROR);
  AddToLogFile(EngineLog,'Couldn''t load O3TC "'+ Filename +'"! "O3_TC_ATI3DC_ATI2N" format is not supported by engine.');
  s.Free;
  Exit;
  end;

  glGenTextures(1, @Texture);
  glBindTexture(GL_TEXTURE_2D, Texture);

  width := ch.width;
  height:= ch.height;
  size  := 0;

  for mip := 0 to ch.num_mipmaps - 1 do
  begin

  size := ((width+3) div 4)*((height+3) div 4) * blockSize;

  GetMem(data,size);

  s.Read(data^,size);

  glCompressedTexImage2D(GL_TEXTURE_2D,mip,format,width,height,0,size,data);

  FreeMem(data);

	width := width div 2;
	height:= height div 2;
  end;

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 0 );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, ch.num_mipmaps );

 	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );

	glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );

  result:=Texture;

  WriteTextureInfo(result,ch.width,ch.height,0,7);

  glBindTexture(GL_TEXTURE_2D, 0);

s.Free;
end;
{------------------------------------------------------------------}
function LoadBMPTexture(Filename: String;Quality : byte; TransparentColor : integer; ColorTolerance : byte; FromPackage : boolean = false; Name : string = ''; OnlyAlpha : boolean = false ): GLUint;
var
  BMP : TBitmap;
begin
  result :=0;

  BMP:=TBitmap.Create;

  if FromPackage then
  try
  BMP.LoadFromStream(LoadFromPackage(Filename,Name));
  except
      MessageBox(0, PChar('Couldn''t load BMP from stream!'), PChar('BMP Unit'), MB_OK or MB_ICONERROR);
      AddToLogFile(EngineLog,'Couldn''t load BMP from stream!');
      Exit;
  end else
    try
      BMP.LoadFromFile(Filename);
    except
      //MessageBox(0, PChar('Couldn''t load BMP "'+ Filename +'"!'), PChar('BMP Unit'), MB_OK or MB_ICONERROR);
      AddToLogFile(EngineLog,'Couldn''t load BMP "'+ Filename +'"!');
      Exit;
    end;

  if not OnlyAlpha then
  result:=LoadTexture(BMP,Quality,TransparentColor,ColorTolerance) else
  result:=LoadTexture(nil,Quality,TransparentColor,ColorTolerance,BMP);

  BMP.Free;
end;
{------------------------------------------------------------------}
function LoadTextureFromPackage(FileName, Name : string; Detail : byte; TransparentColor : integer) : TGLuint;  stdcall;
var
S : TMemoryStream;
begin
if copy(Uppercase(name), length(name)-3, 4) = '.BMP' then Result := LoadBMPTexture(FileName,Detail,TransparentColor,0,true,Name);
if copy(Uppercase(name), length(name)-3, 4) = '.JPG' then Result := LoadJPGTexture(FileName,Detail,TransparentColor,DefJPGTolerance,true,Name);
if copy(Uppercase(name), length(name)-3, 4) = 'O3TC' then Result := LoadO3TCTexture(FileName,true,Name);
if copy(Uppercase(name), length(name)-3, 4) = '.TGA' then
  begin
    S:=TMemoryStream.Create;
    S.LoadFromStream(LoadFromPackage(Filename,Name));
    LoadTGATexture(Name,result,S);
    S.Free;
  end;
if Result<>0 then AddToLogFile(EngineLog,'Texture "'+Name+'" loaded successfully from package "'+Filename+'".') else
AddToLogFile(EngineLog,'Texture "'+Name+'" loaded with errors from package "'+Filename+'"!');
end;
{------------------------------------------------------------------}
function LoadTextureFromFile(FileName: String; Detail : byte; TransparentColor : integer) : TGLuint;  stdcall;
begin
if copy(Uppercase(filename), length(filename)-3, 4) = '.BMP' then Result := LoadBMPTexture(FileName,Detail,TransparentColor,0);
if copy(Uppercase(filename), length(filename)-3, 4) = '.JPG' then Result := LoadJPGTexture(FileName,Detail,TransparentColor,DefJPGTolerance);
if copy(Uppercase(filename), length(filename)-3, 4) = 'O3TC' then Result := LoadO3TCTexture(FileName);
if copy(Uppercase(filename), length(filename)-3, 4) = '.TGA' then LoadTGATexture(FileName,result,nil);
if Result<>0 then AddToLogFile(EngineLog,'Texture "'+ Filename +'" loaded successfully.') else
AddToLogFile(EngineLog,'Texture "'+ Filename +'" loaded with errors!');
end;

end.
