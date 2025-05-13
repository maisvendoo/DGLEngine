{------------------------------------------------------------------------------}
{    _____      _______   ________   _       _        ________    _            }
{   |  __ \    |   __  | |        | | |     | |     /  _____  \  | |           }
{   | |  \ \   |  |__| | |  ____  | | |\    | |     | |     |_|  | |           }
{   | |  |  |  | ______| | |    | | | |\\   | |     | |          | |           }
{   | |  |  |  | |\\     | |    | | | | \\  | |     | |    ___   | |           }
{   | |  |  |  | | \\    | |____| | | |  \\ | |     | |   |_  |  | |     _     }
{   | |_/  /   | |  \\   |        | | |   \\| |     | |_____| |  | |____| |    }
{   |_____/    |_|   \\  |________| |_|    \|_|     \________/   |________|    }
{                                                                              }
{  DRON's OpenGl Engine V 1.1RC2 http://dronprogs.mirgames.ru                  }
{                                                                              }
{  Date: 30.04.2008                                                            }
{                                                                              }
{ Лицензия: Вы можете свободно использовать этот движок, как в коммерческих,   }
{ так и не коммерческих целях, при соблюдение одного условия, в авторах игры   }
{ должно быть указано, что игра использует DGLEngine и приведен адрес сайта,   }
{ либо отображаться логотип движка при старте программы.                       }
{ В противном случае это будет считаться нарушением авторских прав.            }
{                                                                              }
{------------------------------------------------------------------------------}
unit DGLEngine_header;

interface
uses Windows, Classes, SysUtils, Graphics, OpenGl;

function  LoadDGLEngineDLL(FileName : string) : boolean;
procedure FreeDGLEngineDLL(Terminate : boolean = true);

{***Engine***}
{Module version: 1.01}

{***Процедуры работающие только до старта движка***}
const
//Параметры ID
PROC_DRAW    = $000000;
PROC_PROCESS = $000001;
PROC_INIT    = $000002;
PROC_FREE    = $000003;
var
RegProcedure : procedure (ID: WORD; ProcAdress: pointer); stdcall;
SetEngineInitParametrs : procedure (ResX,ResY,ColorDepth, DisplayFrequency : integer; Fullscreen, VSync, UseEngineSettingsIni : boolean; WriteLog : boolean = true); stdcall;
SetWindowPosition : procedure (Left, Top : integer); stdcall;
EnableStencilBuffer : procedure; stdcall;
SetEngineInifileName : procedure (Name : string); stdcall;
PleaseNoLogo : procedure; stdcall;
SetGameProcessInterval : procedure (Interval : byte); stdcall;
SetCutingPlanes : procedure (ZNear, ZFar : single); stdcall;
SetViewAngle : procedure (Angle : single); stdcall;
SetZBufferDepth : procedure (DepthBits : byte); stdcall;
{***}

StartEngine : procedure; stdcall;
QuitEngine : procedure; stdcall;
EngineVersion : function :shortstring; stdcall;
EngineProcessInterval : function : byte; stdcall;
GetWindowHandle : function : HWND; stdcall;

StartEngine_DrawToPanel : procedure (PanelHandle : HWND); stdcall;
EngineProcessMessages : procedure (var Msg: tagMSG); stdcall;
EngineMainDraw : procedure; stdcall;
UpdateRenderRect : procedure (NewWidth,NewHeight : integer); stdcall;

LoadPlugin : function (FileName : string; DGLE_DLL_Handle : THandle) : string; stdcall;
IsPluginLoaded : function (Name : string) : boolean; stdcall;
GetPluginHandle : function (Name : string) : THandle; stdcall;
FreePlugin : procedure (Name : string); stdcall;

const
ENGINE_INIFILE = 'Settings.ini';
var
ReadValueFromIniFile : function (Filename, Section, Key: string):string; stdcall;
WriteValueToIniFile : procedure (Filename, Section, Key, Value : string); stdcall;

const
ENGINE_LOGFILE = 'DGLEngine_Log.txt';
var
AddToLogFile : procedure (FileName, LogStr:String; IsDate : Boolean = false; IsTime : Boolean = false; FileRewrite : boolean = false);  stdcall;
ApplicationName : procedure (Name : PAnsiChar); stdcall;
PrintScreen : function (Folder : string = '') : integer; stdcall;
GetFPS : function : integer; stdcall;
GetScreenResX : function : integer; stdcall;
GetScreenResY : function : integer; stdcall;
AutoPause : procedure (Enable : boolean); stdcall;
MaxMultiTexturingLayers : function : byte; stdcall;
IsTexCompressionSupported : function : boolean; stdcall;
IsShadowMapsSupported : function : boolean; stdcall;
IsDOT3Supported : function : boolean; stdcall;
IsVShadersSupported : function : boolean; stdcall;
IsPShadersSupported : function : boolean; stdcall;
IsVBOSupported : function : boolean; stdcall;
IsFBOSupported : function : boolean; stdcall;
UseFBO : procedure (Enable : boolean); stdcall;

const
//Параметры Quality
TEXDETAIL_BEST   = $000000;
TEXDETAIL_MEDIUM = $000001;
TEXDETAIL_POOR   = $000002;

//Параметры TransparentColor
TRANSCOLOR_NONE  = -$000001;
TRANSCOLOR_BLACK =  $000000;
TRANSCOLOR_GRAY  =  $808080;
TRANSCOLOR_RED   =  $0000FF;
TRANSCOLOR_AQUA  =  $FFFF00;
TRANSCOLOR_FUSIA =  $FF00FF;
var
LoadTexture : function (BMP : TBitmap; Quality : byte; TransparentColor : integer; ColorTolerance : byte; AlphaMask : TBitmap = nil) : Cardinal; stdcall;
LoadTGATexture : function (Filename : String; var Texture : Cardinal; Stream : TMemoryStream = nil) : Boolean; stdcall;
SetDefaultJPGTransparentColorTolerance : procedure (Tolerance : byte); stdcall;
LoadTextureFromPackage : function (FileName, Name : string; Quality : byte = TEXDETAIL_BEST; TransparentColor : integer = TRANSCOLOR_NONE) : Cardinal;  stdcall;
LoadTextureFromFile : function (FileName: String; Quality : byte = TEXDETAIL_BEST; TransparentColor : integer = TRANSCOLOR_NONE) : Cardinal;  stdcall;
FreeTexture : procedure (Texture : Cardinal); stdcall;

DrawTextureToTexture : procedure (TexSource,TexTarget : Cardinal; X,Y : integer); stdcall;
DrawTextureToTextureTransparentColor : procedure (TexSource, TexTarget : Cardinal; X,Y : integer; Color : Cardinal = $808080); stdcall;
RenderTexToTexFBO : procedure (ToTexture,TexSource,TexTarget : Cardinal; X,Y : integer); stdcall;

UseVBO : procedure (Enable : boolean); stdcall;
TextureCompression : procedure (Enable : boolean); stdcall;
TextureMipMapping : procedure (Enable : boolean); stdcall;
TextureFiltering : procedure (Enable : boolean); stdcall;
const
//Параметры Param
TEXTURE_REPEAT = $000000;
TEXTURE_CLAMP  = $000001;
var
TextureParametrs : procedure (Texture : cardinal; Param : byte); stdcall;

const
//Возвращаемые параметры TextureType
IS_TGA       = $000001;
IS_RGBA      = $000002;
IS_RGB       = $000003;
IS_ALPHA     = $000006;
IS_GEN       = $000004;
IS_SHADOWMAP = $000005;
IS_O3TC      = $000007;
IS_UNLOAD    = $000000;
//Возвращаемый параметр Index
INDEX_UNLOAD = $000000;
type TTextureInfo = record
Index : Cardinal;
Width,Height : integer;
Detail,
TextureType : byte;
end;
var
GetTextureInfo : function (Texture : Cardinal) : TTextureInfo; stdcall;

LoadFontFromFile : function (Filename : string) : Cardinal; stdcall;
FreeFont : procedure (Ident : cardinal); stdcall;

ExtractFromPackage : procedure (const PackageName, Name, DestFilename : string); stdcall;
LoadFromPackage : function (const Filename, Name : string):TMemoryStream; stdcall;

AddTimer : function (Interval : Cardinal; OnTimerProcedure : pointer) : Cardinal; stdcall;
DisableTimer : procedure (Ident : Cardinal); stdcall;
EnableTimer : procedure (Ident : Cardinal); stdcall;
SetTimerInterval : procedure (Ident, Interval : Cardinal); stdcall;

{***Console***}
{Module version: 1.0}

CreateConsole : procedure (Font : Cardinal; Size : real = 1.0; Texture : Cardinal = 0); stdcall;
RegisterCommandProcedure : procedure (ComName : string; ProcAdress : pointer); stdcall;
GetLastComParam : function : string; stdcall;
RegisterCommandValue : procedure (ComName : string; ValueAdress : pointer; MaxValue, MinValue : integer); stdcall;
AddStringToConsole : procedure (Text : string); stdcall;
ClearConsole : procedure; stdcall;
ProcessConsole : procedure; stdcall;
DrawConsole : procedure; stdcall;

{***Graphics 2D***}
{Module version: 1.0}

Begin2D : procedure; stdcall;
End2D : procedure; stdcall;

PutPoint2D : procedure (X,Y,Color : integer; Alpha : integer = 255) ; stdcall;
DrawLine2D : procedure (X1, Y1, X2, Y2, Color : integer; Alpha : integer = 255; LineWidth : real = 1.0; Smooth : boolean = false); stdcall;
DrawColorLine2D : procedure (X1, Y1, X2, Y2, Color1, Color2 : integer; Alpha : integer = 255; LineWidth : real = 1.0; Smooth : boolean = true); stdcall;
DrawRectangle2D : procedure (X, Y, Width, Height, Color : integer; Alpha : integer = 255; Fill : boolean = false); stdcall;
DrawRectangle2D_Fill_VertexColor : procedure (X, Y, Width, Height, Color1, Color2, Color3, Color4, Alpha1, Alpha2, Alpha3, Alpha4 : integer); stdcall;
DrawCircle2D : procedure (X, Y, Radius, Color : integer; Alpha : byte = 255); stdcall;
DrawCircle2D_Fill : procedure (X, Y, Radius, Color : integer; Alpha : byte = 255); stdcall;
DrawEllipse2D : procedure (Center: TPoint; Radius0, Radius1, Vertices: Integer; Color: Cardinal; Alpha: byte=255); stdcall;
DrawEllipse2D_Fill : procedure (Center: TPoint; Radius0, Radius1: Integer; Color: Cardinal; Alpha: byte=255); stdcall;
DrawCircleArc2D : procedure (X, Y, Radius, Angle1, Angle2, Color: Integer; Alpha : byte = 255); stdcall;
DrawPolygon2D : procedure (points : array of Tpoint; Color, Alpha : integer); stdcall;
type TColorVertex2D = record X,Y,Color, Alpha : integer; end;
var
DrawPolygon2D_VertexColor : procedure (points : array of TColorVertex2D); stdcall;

DrawTexture2D_Simple : procedure (Texture : Cardinal; X , Y, ImageWidth, ImageHeight : integer; FlipX : boolean = false; FlipY : boolean = false); stdcall;
DrawTexture2D_Split : procedure (Texture : Cardinal; X , Y, TexWidth, TexHeight : integer; Angle, Alpha, Color : integer; SplitRect : Trect; Scale : single = 1.0; FlipX : boolean = false; FlipY : boolean = false); stdcall;
DrawTexture2D : procedure (Texture : Cardinal; X , Y, ImageWidth, ImageHeight, Angle, Alpha, Color : integer; Diffuse : boolean = false; FlipX : boolean = false; FlipY : boolean = false); stdcall;
DrawTexture2D_VertexColor : procedure (Texture : Cardinal; X , Y, ImageWidth, ImageHeight, Angle, Color1, Color2, Color3, Color4, Alpha1, Alpha2, Alpha3, Alpha4 : integer; FlipX : boolean = false; FlipY : boolean = false); stdcall;

DrawSprite2D_Simple : procedure (Texture : Cardinal; X , Y, ImageWidth, ImageHeight,FramesXCount, FramesYCount, FrameNumber: integer; FlipX : boolean = false; FlipY : boolean = false); stdcall;
DrawSprite2D : procedure (Texture : Cardinal; X , Y, ImageWidth, ImageHeight,FramesXCount, FramesYCount, FrameNumber, Angle, Alpha, Color : integer; Diffuse : boolean = false; FlipX : boolean = false; FlipY : boolean = false); stdcall;
DrawSprite2D_VertexColor : procedure (Texture : Cardinal; X , Y, ImageWidth, ImageHeight,FramesXCount, FramesYCount, FrameNumber, Angle, Color1, Color2, Color3, Color4, Alpha1, Alpha2, Alpha3, Alpha4 : integer; FlipX : boolean = false; FlipY : boolean = false); stdcall;
DrawSprite2D_Tile : procedure (Texture : Cardinal; X, Y, TexWidth, TexHeight, FrameWidth, FrameHeight, FramesXCount, FramesYCount, FrameNumber, Angle, Alpha, Color : integer; Scale : single = 1.0; FlipX : boolean = false; FlipY : boolean = false); stdcall;

DrawText2D : procedure (Font : Cardinal; X,Y : integer; Text : string; Color : integer = $FFFFFF; Alpha : integer = 255; Scale : real = 1.0); stdcall;
GetTextWidth : function (Font : Cardinal; Text : string; Scale : real = 1.0):integer; stdcall;
GetTextHeight : function (Font : Cardinal; Text : string; Scale : real = 1.0):integer; stdcall;

{***Graphics 3D***}
{Module version: 1.1}

BeginObj3D : procedure; stdcall;
EndObj3D : procedure; stdcall;

type
  TVertex = record X, Y, Z: single; end;
  TCamera = record
            Eye    : TVertex;
            Center : TVertex;
            end;
var
SetCamera : procedure (Camera : TCamera); stdcall;
Position3D : procedure (X,Y,Z : single); stdcall;
Scale3D : procedure (Scale : single); stdcall;
RotateX : procedure (Angle : single); stdcall;
RotateY : procedure (Angle : single); stdcall;
RotateZ : procedure (Angle : single); stdcall;
ResetMatrix : procedure; stdcall;

AdductingMatrix3Dto2D : procedure; stdcall;
ReturnStandartMatrix3D : procedure; stdcall;
Position2D : procedure (X,Y : integer); stdcall;

Color3D : procedure (Color:integer; Alpha : byte = 255; Diffuse : boolean= false; MaterialShininess : single = 0.0); stdcall;

const
TEX_BLANK = 0;
var
SetTexture : procedure (Texture : Cardinal); stdcall;
const
  MTEX_LAYER0 = $000000;
  MTEX_LAYER1 = $000001;
  MTEX_LAYER2 = $000002;
  MTEX_LAYER3 = $000003;
  MTEX_LAYER4 = $000004;
  MTEX_LAYER5 = $000005;
var
ActivateMultitexturingLayer : procedure (Layer : Cardinal); stdcall;
SetMultytexturingLayerOffset : procedure (Layer : cardinal; X,Y : single); stdcall;
SetMultytexturingLayerTexCoordMulti : procedure (Layer : cardinal; X,Y : single); stdcall;
DeactiveMultytexturing : procedure; stdcall;

CreateTextureToRenderIn : function (TextureWidth,TextureHeight : integer):Cardinal; stdcall;
StartRenderToTexture : procedure (Texture : Cardinal); stdcall;
EndRenderToTexture : procedure; stdcall;

const
//Параметры ID
  LIGHTS_ALL = -$000001;
  LIGHT0     =  $000000;
  LIGHT1     =  $000001;
  LIGHT2     =  $000002;
  LIGHT3     =  $000003;
  LIGHT4     =  $000004;
  LIGHT5     =  $000005;
  LIGHT6     =  $000006;
  LIGHT7     =  $000007;
  LIGHT8     =  $000008;
  LIGHT9     =  $000009;
//Параметр Radius
  INFINITY   = -$000001;
var
SetLight : procedure (ID : integer = LIGHT0; X : single = 1;Y : single = 0;Z : single = 1; light_Color : integer =$FFFFFF; Radius : single = INFINITY; Visualize : boolean = false; VisualScale : single = 0.1); stdcall;
DeactiveLight : procedure (ID : integer = LIGHTS_ALL); stdcall;

CreateFont3D : function (const Fontname : string):integer; stdcall;
Write3D : procedure (FontIdent: integer; Text: string); stdcall;

const
//Параметры ScaleType
MDL_NO_SCALE               = $000000;
MDL_SCALE_EVERY_FRAME      = $000001;
MDL_SCALE_GL_ONE           = $000002;
MDL_SCALE_BY_LARGEST_FRAME = $000003;

type
TVertex4D = record X, Y, Z, W: single; end;

TTangent = record
bitangent : TVertex;
tangent   : TVertex4D;
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

TMaterial = record
 diffuse : array [0..2] of byte;
 glossiness : single;
 alpha : byte;
 TexFileName, NormalMapFileName, SpecularMapFileName : string[128];
end;

var
LoadModel : function (Filename : string; ScaleType : byte = MDL_SCALE_BY_LARGEST_FRAME; Inverted_Normals : boolean = false) : integer; stdcall;
FreeModel : procedure (ModelIdent : integer); stdcall;
DrawModel : procedure (ModelIdent : integer; Frame : integer = 0; Smooth : boolean = true); stdcall;
ModelFramesCount : function (Modelident : integer):Integer; stdcall;
ModelBoundingBox : function (Modelident,Frame : integer):TVertex; stdcall;
ModelTrianglesCount : function (Modelident,Frame : integer) : Cardinal; stdcall;
ModelMaterial : function (Modelident : integer) : TMaterial; stdcall;
GetModelGeometry : procedure (ModelIdent, Frame : integer; GeometryData : PMeshGeometry); stdcall;
ModelsBump : procedure (Active : boolean); stdcall;

type
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

var
LoadScene : function (FileName, MeshPath, TexPath : string):cardinal; stdcall;
FreeScene : procedure (Ident : cardinal); stdcall;
DrawScene : procedure (Ident : cardinal); stdcall;
SceneBoundingBox : function (Ident : cardinal):TVertex; stdcall;
CollideBoxWithScene : function (Ident : cardinal; BoxPos, BoxSize : Tvertex):boolean; stdcall;
SceneUseMaterial : procedure (Enable : boolean); stdcall;
SceneGetLastCollideObjectIndex : function :integer; stdcall;
SceneObjCount : function ( Ident : cardinal ) : cardinal; stdcall;
GetSceneObjectIdent : function ( SceneIdent : cardinal; ObjName : string ) : integer; stdcall;
SceneSetObjActive : procedure ( SceneIdent, ObjIdent : cardinal; Active : boolean ); stdcall;
SceneSetObj : procedure ( SceneIdent, ObjIdent : cardinal; SceneMesh : TSceneMesh ); stdcall;
SceneGetObj : function ( SceneIdent, ObjIdent : cardinal ) : TSceneMesh; stdcall;

EnableSphereMapping : procedure; stdcall;
DisableSphereMapping : procedure; stdcall;

const
 CULL_NONE  = $000000;
 CULL_FRONT = $000001;
 CULL_BACK  = $000002;
var
CullFace : procedure (Mode : cardinal) ; stdcall;

SetFog : procedure (Color : Integer; Fog_Start, Fog_End : single); stdcall;
DeactiveFog : procedure; stdcall;

DrawAxes : procedure (Length : single = 1.0); stdcall;
DrawPoint : procedure (X,Y,Z : single); stdcall;
DrawLine : procedure (X,Y,Z,X1,Y1,Z1 : single; LineWidth : real = 1.0; Smooth : boolean = true); stdcall;
DrawPlane : procedure (Width,Height : single); stdcall;
type TVertex3D = record X,Y,Z : single; Color, Alpha : integer; TexX, TexY : single; end;
var
DrawPolygon3D : procedure (points : array of TVertex3D); stdcall;
DrawSprite : procedure (Width,Height : single; FramesXCount, FramesYCount, FrameNumber: integer);stdcall;
DrawSprite_BillBoard : procedure (Width,Height : single; FramesXCount, FramesYCount, FrameNumber: integer);stdcall;
DrawCube : procedure (Width,Height,Depth : single); stdcall;
DrawSphere : procedure (Radius : single); stdcall;
DrawCylinder : procedure (Radius,Height : single); stdcall;
DrawEllipse : procedure (Width, Height, Depth : single); stdcall;

{***Advanced 3D****}
{Module version: 1.1}

const
  //Параметры target
  VERTEX_PROGRAM    = $8620;
  FRAGMENT_PROGRAM  = $8804;
var
LoadShader : function (target: Cardinal; shader: string): Cardinal; stdcall;
FreeShader : procedure (Ident : cardinal); stdcall;
const
  //Параметры Ident
  NULL_VERTEX_PROGRAM    = -$000002;
  NULL_FRAGMENT_PROGRAM  = -$000001;
  NULL_PROGRAMS          = -$000003;
var
SetShader : procedure (Ident : integer); stdcall;
GiveShaderParams : procedure (Ident, Index : cardinal; v : TVertex; w : single); stdcall;

Get3DPos : function : TVertex;  stdcall;
Get3DPosFree :function (pX,pY:integer): TVertex; stdcall;
Get2DPos : function (Vertex : TVertex) : TPoint; stdcall;

StartWriteToVideoMemory : function : cardinal; stdcall;
EndWriteToVideoMemory : procedure; stdcall;
FreeFromVideoMemory : procedure (Ident : integer); stdcall;
DrawFromVM : procedure (Ident : integer); stdcall;

CreateAVITexture : function (Filename : string) : integer; stdcall;
FreeAVITexture : procedure (index : integer); stdcall;
SetAviTexture : procedure (index : integer); stdcall;

ClearZBuffer : procedure; stdcall;
ZBuffer : procedure (Active : boolean); stdcall;

RenderProjection : procedure (ProjectTexture : cardinal; DrawScene : pointer; ProjectorOrientation: TCamera; InvertDiffuse : boolean = false); stdcall;
SetupProjector : procedure; stdcall;
DisableProjector : procedure; stdcall;
EndDrawingProjectedScene : procedure; stdcall;
RenderProjectedTexture : procedure (ProjectTexture : Cardinal; ProjectorOrientation: TCamera; InvertDiffuse : boolean = false); stdcall;
PrepareSceneForProjecting : procedure; stdcall;

GiveVShaderTexProjectMatrix : procedure (VShader, StartIdx, Texture : Cardinal; Projector : TCamera); stdcall;

SetShadowRenderAngle : procedure (Angle : cardinal); stdcall;
CreateShadowMap : function (Size : integer):Cardinal; stdcall;
CastShadowMap : procedure (Texture : Cardinal; LightCamera : TCamera); stdcall;

CalculateFrustum : procedure; stdcall;
IsPointInFrustum : function (X,Y,Z : single) : boolean; stdcall;
IsSphereInFrustum : function (X,Y,Z,Radius : single) : boolean; stdcall;
IsBoxInFrustum : function (X,Y,Z,W,H,D : single) : boolean; stdcall;

{***Network****}
{Module version: 1.0}

NET_Init : function : boolean; stdcall;
NET_Free : procedure; stdcall;
NET_Clear : procedure; stdcall;
NET_ClearAPL : procedure; stdcall;
NET_GetExternalIP : function : PChar; stdcall;
NET_GetHost : function : PChar; stdcall;
NET_GetLocalIP : function : PChar; stdcall;
NET_HostToIP : function (Host: PChar): PChar; stdcall;
NET_InitSocket : function (Port: WORD): integer; stdcall;
NET_Write : function (Buf: pointer; Count: integer): boolean; stdcall;
NET_Send : function (IP: PChar; Port: WORD; APL: boolean): integer; stdcall;
NET_Recv : function (Buf: pointer; Count: integer; var IP: PChar; var Port: integer; var RecvBytes: integer): integer; stdcall;
NET_Update : procedure; stdcall;

{***Sound****}
{Module version: 1.0a}

PlayMusic : procedure (Filename : string; Looped : boolean = true); stdcall;
StopMusic : procedure; stdcall;
IsMusicPlaying : function : boolean; stdcall;

DirectSoundInit : procedure; stdcall;
LoadSample : function (Filename : string; FromPackage : boolean = false; Name : string = ''):integer; stdcall;
FreeSample : procedure (Index : integer); stdcall;
PlaySample : procedure (Index : integer); stdcall;
SetSampleVolume : procedure (Index : integer; Volume : byte); stdcall;
SetSample3DPosition : procedure (Index : integer; X,Y,Z : real); stdcall;
GetSample3DPosition : procedure (Index : integer; var X,Y,Z : single); stdcall;

{***Input***}
{Module version: 1.0}

const
MB_LEFT   = $000001;
MB_MIDDLE = $000003;
MB_RIGHT  = $000002;
MB_NONE   = $000000;
var
GetMouseButtonPressed : function : byte; stdcall;
IsLeftMouseButtonPressed : function : boolean; stdcall;
IsRightMouseButtonPressed : function : boolean; stdcall;
GetMousePos : function : Tpoint; stdcall;
IsMouseMoveing : function : boolean; stdcall;
const
WHEEL_DOWN = -$000001;
WHEEL_UP   =  $000001;
WHEEL_NO_ACTION = $000000;
var
MouseWheelDelta : function : integer; stdcall;
StartKeyboardTextInput : procedure; stdcall;
EndKeyboardTextInput : procedure; stdcall;
GetKeyboardText : function : string; stdcall;
const
JOY_MAIN = $000000;
var
Input_JoyDown : function (JoyNum, Button: Byte): boolean; stdcall;
const
JOY_LEFT = $000001;
JOY_RIGHT= $000002;
JOY_UP   = $000003;
JOY_DOWN = $000004;
var
Input_JoyDirections : function (JoyNum, Direction: Byte): boolean; stdcall;

IsKeyPressed : function (Key : integer) : boolean; stdcall;
//Key codes
const
    Key_Escape = 27;
    Key_Tab = 9;
    Key_Backspace = 8;
    Key_Space = 32;
    Key_Enter = 13;
    Key_Shift = 16;
    Key_Control = 17;
    Key_Alt = 18;
    Key_F1 =  112;
    Key_F2 =  113;
    Key_F3 =  114;
    Key_F4 =  115;
    Key_F5 =  116;
    Key_F6 =  117;
    Key_F7 =  118;
    Key_F8 =  119;
    Key_F9 =  120;
    Key_F10 = 121;
    Key_F11 = 122;
    Key_F12 = 123;
    Key_Left = 37;
    Key_Up = 38;
    Key_Right = 39;
    Key_Down = 40;
    Key_0 = 48;
    Key_1 = 49;
    Key_2 = 50;
    Key_3 = 51;
    Key_4 = 52;
    Key_5 = 53;
    Key_6 = 54;
    Key_7 = 55;
    Key_8 = 56;
    Key_9 = 57;
    Key_A = 65;
    Key_B = 66;
    Key_C = 67;
    Key_D = 68;
    Key_E = 69;
    Key_F = 70;
    Key_G = 71;
    Key_H = 72;
    Key_I = 73;
    Key_J = 74;
    Key_K = 75;
    Key_L = 76;
    Key_M = 77;
    Key_N = 78;
    Key_O = 79;
    Key_P = 80;
    Key_Q = 81;
    Key_R = 82;
    Key_S = 83;
    Key_T = 84;
    Key_U = 85;
    Key_V = 86;
    Key_W = 87;
    Key_X = 88;
    Key_Y = 89;
    Key_Z = 90;

var
RenderTexture2D : procedure (Texture : Cardinal; X, Y, FrameWidth, FrameHeight : integer; Color : integer; Alpha : byte; Angle : integer;
Frame : byte = 1; FrameCountX : byte = 1; FrameCountY : byte = 1; ScaleX : glFloat = 1.0; ScaleY : glFloat = 1.0;
Color4 : boolean = false; VColor1: integer = 0; VColor2: integer = 0; VColor3: integer = 0; VColor4: integer = 0; VAlpha1: integer = 0;
 VAlpha2: integer = 0; VAlpha3: integer = 0; VAlpha4: integer = 0; Diffuse : boolean = false; FlipX : boolean = false; FlipY : boolean = false); stdcall;
WriteTextureInfo : procedure (Ind : cardinal; W,H : integer; Det, Typ : byte); stdcall;
CreateTexture : function (Width, Height, Format : Word; pData : Pointer) : Cardinal; stdcall;
_glTexCoord2f : procedure (X,Y : GLFloat; Layer : integer = -1); stdcall;

var
DGLEngineDLL_Handle : THandle;

procedure InitDGLE_1_0;
procedure InitDGLE_1_1;

implementation

procedure InitDGLE_1_1;
begin
  @ModelMaterial:=GetProcAddress(DGLEngineDLL_Handle,'ModelMaterial');
  @IsVBOSupported:=GetProcAddress(DGLEngineDLL_Handle,'IsVBOSupported');
  @UseVBO:=GetProcAddress(DGLEngineDLL_Handle,'UseVBO');
  @GetWindowHandle:=GetProcAddress(DGLEngineDLL_Handle,'GetWindowHandle');
  @LoadScene:=GetProcAddress(DGLEngineDLL_Handle,'LoadScene');
  @FreeScene:=GetProcAddress(DGLEngineDLL_Handle,'FreeScene');
  @DrawScene:=GetProcAddress(DGLEngineDLL_Handle,'DrawScene');
  @SceneBoundingBox:=GetProcAddress(DGLEngineDLL_Handle,'SceneBoundingBox');
  @LoadShader:=GetProcAddress(DGLEngineDLL_Handle,'LoadShader');
  @FreeShader:=GetProcAddress(DGLEngineDLL_Handle,'FreeShader');
  @SetShader:=GetProcAddress(DGLEngineDLL_Handle,'SetShader');
  @GiveShaderParams:=GetProcAddress(DGLEngineDLL_Handle,'GiveShaderParams');
  @CollideBoxWithScene:=GetProcAddress(DGLEngineDLL_Handle,'CollideBoxWithScene');
  @SceneUseMaterial:=GetProcAddress(DGLEngineDLL_Handle,'SceneUseMaterial');
  @CullFace:=GetProcAddress(DGLEngineDLL_Handle,'CullFace');
  @SceneGetLastCollideObjectIndex:=GetProcAddress(DGLEngineDLL_Handle,'SceneGetLastCollideObjectIndex');
  @SceneObjCount:=GetProcAddress(DGLEngineDLL_Handle,'SceneObjCount');
  @GetSceneObjectIdent:=GetProcAddress(DGLEngineDLL_Handle,'GetSceneObjectIdent');
  @SceneSetObjActive:=GetProcAddress(DGLEngineDLL_Handle,'SceneSetObjActive');
  @SceneSetObj:=GetProcAddress(DGLEngineDLL_Handle,'SceneSetObj');
  @SceneGetObj:=GetProcAddress(DGLEngineDLL_Handle,'SceneGetObj');
  @GetModelGeometry:=GetProcAddress(DGLEngineDLL_Handle,'GetModelGeometry');
  @IsFBOSupported:=GetProcAddress(DGLEngineDLL_Handle,'IsFBOSupported');
  @ModelsBump:=GetProcAddress(DGLEngineDLL_Handle,'ModelsBump');
  @RenderTexToTexFBO:=GetProcAddress(DGLEngineDLL_Handle,'RenderTexToTexFBO');
  @GiveVShaderTexProjectMatrix:=GetProcAddress(DGLEngineDLL_Handle,'GiveVShaderTexProjectMatrix');
  @UseFBO:=GetProcAddress(DGLEngineDLL_Handle,'UseFBO');
end;

procedure InitDGLE_1_0;
begin
  @Get3DPosFree:=GetProcAddress(DGLEngineDLL_Handle,'Get3DPosFree');
  @AutoPause:=GetProcAddress(DGLEngineDLL_Handle,'AutoPause');
  @SetDefaultJPGTransparentColorTolerance:=GetProcAddress(DGLEngineDLL_Handle,'SetDefaultJPGTransparentColorTolerance');
  @MaxMultiTexturingLayers:=GetProcAddress(DGLEngineDLL_Handle,'MaxMultiTexturingLayers');
  @IsShadowMapsSupported:=GetProcAddress(DGLEngineDLL_Handle,'IsShadowMapsSupported');
  @IsDOT3Supported:=GetProcAddress(DGLEngineDLL_Handle,'IsDOT3Supported');
  @IsVShadersSupported:=GetProcAddress(DGLEngineDLL_Handle,'IsVShadersSupported');
  @IsPShadersSupported:=GetProcAddress(DGLEngineDLL_Handle,'IsPShadersSupported');
  @FreePlugin:=GetProcAddress(DGLEngineDLL_Handle,'FreePlugin');
  @GetPluginHandle:=GetProcAddress(DGLEngineDLL_Handle,'GetPluginHandle');
  @IsPluginLoaded:=GetProcAddress(DGLEngineDLL_Handle,'IsPluginLoaded');
  @LoadPlugin:=GetProcAddress(DGLEngineDLL_Handle,'LoadPlugin');
  @StartEngine:=GetProcAddress(DGLEngineDLL_Handle,'StartEngine');
  @RegProcedure:=GetProcAddress(DGLEngineDLL_Handle,'RegProcedure');
  @TextureMipMapping:=GetProcAddress(DGLEngineDLL_Handle,'TextureMipMapping');
  @TextureFiltering:=GetProcAddress(DGLEngineDLL_Handle,'TextureFiltering');
  @TextureParametrs:=GetProcAddress(DGLEngineDLL_Handle,'TextureParametrs');
  @AddToLogFile:=GetProcAddress(DGLEngineDLL_Handle,'AddToLogFile');
  @TextureCompression:=GetProcAddress(DGLEngineDLL_Handle,'TextureCompression');
  @EngineMainDraw:=GetProcAddress(DGLEngineDLL_Handle,'EngineMainDraw');
  @EnableStencilBuffer:=GetProcAddress(DGLEngineDLL_Handle,'EnableStencilBuffer');
  @UpdateRenderRect:=GetProcAddress(DGLEngineDLL_Handle,'UpdateRenderRect');
  @StartEngine_DrawToPanel:=GetProcAddress(DGLEngineDLL_Handle,'StartEngine_DrawToPanel');
  @EngineProcessMessages:=GetProcAddress(DGLEngineDLL_Handle,'EngineProcessMessages');
  @ApplicationName:=GetProcAddress(DGLEngineDLL_Handle,'ApplicationName');
  @GetFPS:=GetProcAddress(DGLEngineDLL_Handle,'GetFPS');
  @LoadFontFromFile:=GetProcAddress(DGLEngineDLL_Handle,'LoadFontFromFile');
  @SetWindowPosition:=GetProcAddress(DGLEngineDLL_Handle,'SetWindowPosition');
  @QuitEngine:=GetProcAddress(DGLEngineDLL_Handle,'QuitEngine');
  @PleaseNoLogo:=GetProcAddress(DGLEngineDLL_Handle,'PleaseNoLogo');
  @SetGameProcessInterval:=GetProcAddress(DGLEngineDLL_Handle,'SetGameProcessInterval');
  @ExtractFromPackage:=GetProcAddress(DGLEngineDLL_Handle,'ExtractFromPackage');
  @FreeTexture:=GetProcAddress(DGLEngineDLL_Handle,'FreeTexture');
  @LoadTexture:=GetProcAddress(DGLEngineDLL_Handle,'LoadTexture');
  @LoadTGATexture:=GetProcAddress(DGLEngineDLL_Handle,'LoadTGATexture');
  @LoadTextureFromPackage:=GetProcAddress(DGLEngineDLL_Handle,'LoadTextureFromPackage');
  @LoadTextureFromFile:=GetProcAddress(DGLEngineDLL_Handle,'LoadTextureFromFile');
  @SetEngineInitParametrs:=GetProcAddress(DGLEngineDLL_Handle,'SetEngineInitParametrs');
  @ReadValueFromIniFile:=GetProcAddress(DGLEngineDLL_Handle,'ReadValueFromIniFile');
  @WriteValueToIniFile:=GetProcAddress(DGLEngineDLL_Handle,'WriteValueToIniFile');
  @SetEngineInifileName:=GetProcAddress(DGLEngineDLL_Handle,'SetEngineInifileName');
  @PrintScreen:=GetProcAddress(DGLEngineDLL_Handle,'PrintScreen');
  @GetScreenResX:=GetProcAddress(DGLEngineDLL_Handle,'GetScreenResX');
  @GetScreenResY:=GetProcAddress(DGLEngineDLL_Handle,'GetScreenResY');
  @SetCutingPlanes:=GetProcAddress(DGLEngineDLL_Handle,'SetCutingPlanes');
  @SetViewAngle:=GetProcAddress(DGLEngineDLL_Handle,'SetViewAngle');
  @ClearZBuffer:=GetProcAddress(DGLEngineDLL_Handle,'ClearZBuffer');
  @SetZBufferDepth:=GetProcAddress(DGLEngineDLL_Handle,'SetZBufferDepth');
  @LoadFromPackage:=GetProcAddress(DGLEngineDLL_Handle,'LoadFromPackage');
  @GetTextureInfo:=GetProcAddress(DGLEngineDLL_Handle,'GetTextureInfo');
  @AddTimer:=GetProcAddress(DGLEngineDLL_Handle,'AddTimer');
  @EnableTimer:=GetProcAddress(DGLEngineDLL_Handle,'EnableTimer');
  @DisableTimer:=GetProcAddress(DGLEngineDLL_Handle,'DisableTimer');
  @SetTimerInterval:=GetProcAddress(DGLEngineDLL_Handle,'SetTimerInterval');
  @FreeFont:=GetProcAddress(DGLEngineDLL_Handle,'FreeFont');
  @AddStringToConsole:=GetProcAddress(DGLEngineDLL_Handle,'AddStringToConsole');
  @RegisterCommandProcedure:=GetProcAddress(DGLEngineDLL_Handle,'RegisterCommandProcedure');
  @CreateConsole:=GetProcAddress(DGLEngineDLL_Handle,'CreateConsole');
  @RegisterCommandValue:=GetProcAddress(DGLEngineDLL_Handle,'RegisterCommandValue');
  @ProcessConsole:=GetProcAddress(DGLEngineDLL_Handle,'ProcessConsole');
  @DrawConsole:=GetProcAddress(DGLEngineDLL_Handle,'DrawConsole');
  @ClearConsole:=GetProcAddress(DGLEngineDLL_Handle,'ClearConsole');
  @GetLastComParam:=GetProcAddress(DGLEngineDLL_Handle,'GetLastComParam');
  @Begin2D:=GetProcAddress(DGLEngineDLL_Handle,'Begin2D');
  @End2D:=GetProcAddress(DGLEngineDLL_Handle,'End2D');
  @DrawTexture2D:=GetProcAddress(DGLEngineDLL_Handle,'DrawTexture2D');
  @GetTextHeight:=GetProcAddress(DGLEngineDLL_Handle,'GetTextHeight');
  @DrawTexture2D_Simple:=GetProcAddress(DGLEngineDLL_Handle,'DrawTexture2D_Simple');
  @DrawTexture2D_VertexColor:=GetProcAddress(DGLEngineDLL_Handle,'DrawTexture2D_VertexColor');
  @DrawSprite2D_Simple:=GetProcAddress(DGLEngineDLL_Handle,'DrawSprite2D_Simple');
  @DrawSprite2D:=GetProcAddress(DGLEngineDLL_Handle,'DrawSprite2D');
  @DrawSprite2D_VertexColor:=GetProcAddress(DGLEngineDLL_Handle,'DrawSprite2D_VertexColor');
  @PutPoint2D:=GetProcAddress(DGLEngineDLL_Handle,'PutPoint2D');
  @DrawLine2D:=GetProcAddress(DGLEngineDLL_Handle,'DrawLine2D');
  @DrawRectangle2D:=GetProcAddress(DGLEngineDLL_Handle,'DrawRectangle2D');
  @DrawRectangle2D_Fill_VertexColor:=GetProcAddress(DGLEngineDLL_Handle,'DrawRectangle2D_Fill_VertexColor');
  @DrawCircle2D:=GetProcAddress(DGLEngineDLL_Handle,'DrawCircle2D');
  @DrawEllipse2D:=GetProcAddress(DGLEngineDLL_Handle,'DrawEllipse2D');
  @DrawText2D:=GetProcAddress(DGLEngineDLL_Handle,'DrawText2D');
  @GetTextWidth:=GetProcAddress(DGLEngineDLL_Handle,'GetTextWidth');
  @DrawCircle2D_Fill:=GetProcAddress(DGLEngineDLL_Handle,'DrawCircle2D_Fill');
  @DrawCircleArc2D:=GetProcAddress(DGLEngineDLL_Handle,'DrawCircleArc2D');
  @DrawColorLine2D:=GetProcAddress(DGLEngineDLL_Handle,'DrawColorLine2D');
  @DrawTexture2D_Split:=GetProcAddress(DGLEngineDLL_Handle,'DrawTexture2D_Split');
  @DrawPolygon2D:=GetProcAddress(DGLEngineDLL_Handle,'DrawPolygon2D');
  @DrawSprite2D_Tile:=GetProcAddress(DGLEngineDLL_Handle,'DrawSprite2D_Tile');
  @DrawEllipse2D_Fill:=GetProcAddress(DGLEngineDLL_Handle,'DrawEllipse2D_Fill');
  @DrawPolygon2D_VertexColor:=GetProcAddress(DGLEngineDLL_Handle,'DrawPolygon2D_VertexColor');
  @BeginObj3D:=GetProcAddress(DGLEngineDLL_Handle,'BeginObj3D');
  @EndObj3D:=GetProcAddress(DGLEngineDLL_Handle,'EndObj3D');
  @Position3D:=GetProcAddress(DGLEngineDLL_Handle,'Position3D');
  @Color3D:=GetProcAddress(DGLEngineDLL_Handle,'Color3D');
  @SetShadowRenderAngle:=GetProcAddress(DGLEngineDLL_Handle,'SetShadowRenderAngle');
  @ModelTrianglesCount:=GetProcAddress(DGLEngineDLL_Handle,'ModelTrianglesCount');
  @AdductingMatrix3Dto2D:=GetProcAddress(DGLEngineDLL_Handle,'AdductingMatrix3Dto2D');
  @ReturnStandartMatrix3D:=GetProcAddress(DGLEngineDLL_Handle,'ReturnStandartMatrix3D');
  @DrawAxes:=GetProcAddress(DGLEngineDLL_Handle,'DrawAxes');
  @RotateX:=GetProcAddress(DGLEngineDLL_Handle,'RotateX');
  @RotateY:=GetProcAddress(DGLEngineDLL_Handle,'RotateY');
  @RotateZ:=GetProcAddress(DGLEngineDLL_Handle,'RotateZ');
  @SetTexture:=GetProcAddress(DGLEngineDLL_Handle,'SetTexture');
  @Position2D:=GetProcAddress(DGLEngineDLL_Handle,'Position2D');
  @DrawPlane:=GetProcAddress(DGLEngineDLL_Handle,'DrawPlane');
  @DrawSphere:=GetProcAddress(DGLEngineDLL_Handle,'DrawSphere');
  @DrawCube:=GetProcAddress(DGLEngineDLL_Handle,'DrawCube');
  @DrawLine:=GetProcAddress(DGLEngineDLL_Handle,'DrawLine');
  @Drawpoint:=GetProcAddress(DGLEngineDLL_Handle,'Drawpoint');
  @DrawCylinder:=GetProcAddress(DGLEngineDLL_Handle,'DrawCylinder');
  @CreateFont3D:=GetProcAddress(DGLEngineDLL_Handle,'CreateFont3D');
  @Write3D:=GetProcAddress(DGLEngineDLL_Handle,'Write3D');
  @LoadModel:=GetProcAddress(DGLEngineDLL_Handle,'LoadModel');
  @FreeModel:=GetProcAddress(DGLEngineDLL_Handle,'FreeModel');
  @DrawModel:=GetProcAddress(DGLEngineDLL_Handle,'DrawModel');
  @ModelFramesCount:=GetProcAddress(DGLEngineDLL_Handle,'ModelFramesCount');
  @Scale3D:=GetProcAddress(DGLEngineDLL_Handle,'Scale3D');
  @EnableSphereMapping:=GetProcAddress(DGLEngineDLL_Handle,'EnableSphereMapping');
  @DisableSphereMapping:=GetProcAddress(DGLEngineDLL_Handle,'DisableSphereMapping');
  @SetLight:=GetProcAddress(DGLEngineDLL_Handle,'SetLight');
  @DrawEllipse:=GetProcAddress(DGLEngineDLL_Handle,'DrawEllipse');
  @StartRenderToTexture:=GetProcAddress(DGLEngineDLL_Handle,'StartRenderToTexture');
  @EndRenderToTexture:=GetProcAddress(DGLEngineDLL_Handle,'EndRenderToTexture');
  @CreateTextureToRenderIn:=GetProcAddress(DGLEngineDLL_Handle,'CreateTextureToRenderIn');
  @SetFog:=GetProcAddress(DGLEngineDLL_Handle,'SetFog');
  @DeactiveFog:=GetProcAddress(DGLEngineDLL_Handle,'DeactiveFog');
  @StartWriteToVideoMemory:=GetProcAddress(DGLEngineDLL_Handle,'StartWriteToVideoMemory');
  @EndWriteToVideoMemory:=GetProcAddress(DGLEngineDLL_Handle,'EndWriteToVideoMemory');
  @FreeFromVideoMemory:=GetProcAddress(DGLEngineDLL_Handle,'FreeFromVideoMemory');
  @DrawFromVM:=GetProcAddress(DGLEngineDLL_Handle,'DrawFromVM');
  @DrawSprite:=GetProcAddress(DGLEngineDLL_Handle,'DrawSprite');
  @DrawTextureToTexture:=GetProcAddress(DGLEngineDLL_Handle,'DrawTextureToTexture');
  @SetMultytexturingLayerTexCoordMulti:=GetProcAddress(DGLEngineDLL_Handle,'SetMultytexturingLayerTexCoordMulti');
  @DrawPolygon3D:=GetProcAddress(DGLEngineDLL_Handle,'DrawPolygon3D');
  @CreateAVITexture:=GetProcAddress(DGLEngineDLL_Handle,'CreateAVITexture');
  @FreeAVITexture:=GetProcAddress(DGLEngineDLL_Handle,'FreeAVITexture');
  @SetAviTexture:=GetProcAddress(DGLEngineDLL_Handle,'SetAviTexture');
  @SetCamera:=GetProcAddress(DGLEngineDLL_Handle,'SetCamera');
  @DeactiveLight:=GetProcAddress(DGLEngineDLL_Handle,'DeactiveLight');
  @ModelBoundingBox:=GetProcAddress(DGLEngineDLL_Handle,'ModelBoundingBox');
  @SetupProjector:=GetProcAddress(DGLEngineDLL_Handle,'SetupProjector');
  @DisableProjector:=GetProcAddress(DGLEngineDLL_Handle,'DisableProjector');
  @RenderProjection:=GetProcAddress(DGLEngineDLL_Handle,'RenderProjection');
  @RenderProjectedTexture:=GetProcAddress(DGLEngineDLL_Handle,'RenderProjectedTexture');
  @PrepareSceneForProjecting:=GetProcAddress(DGLEngineDLL_Handle,'PrepareSceneForProjecting');
  @EndDrawingProjectedScene:=GetProcAddress(DGLEngineDLL_Handle,'EndDrawingProjectedScene');
  @Get3DPos:=GetProcAddress(DGLEngineDLL_Handle,'Get3DPos');
  @Get2DPos:=GetProcAddress(DGLEngineDLL_Handle,'Get2DPos');
  @CalculateFrustum:=GetProcAddress(DGLEngineDLL_Handle,'CalculateFrustum');
  @IsPointInFrustum:=GetProcAddress(DGLEngineDLL_Handle,'IsPointInFrustum');
  @IsSphereInFrustum:=GetProcAddress(DGLEngineDLL_Handle,'IsSphereInFrustum');
  @IsBoxInFrustum:=GetProcAddress(DGLEngineDLL_Handle,'IsBoxInFrustum');
  @DrawSprite_BillBoard:=GetProcAddress(DGLEngineDLL_Handle,'DrawSprite_BillBoard');
  @CreateShadowMap:=GetProcAddress(DGLEngineDLL_Handle,'CreateShadowMap');
  @CastShadowMap:=GetProcAddress(DGLEngineDLL_Handle,'CastShadowMap');
  @ActivateMultitexturingLayer:=GetProcAddress(DGLEngineDLL_Handle,'ActivateMultitexturingLayer');
  @DeactiveMultytexturing:=GetProcAddress(DGLEngineDLL_Handle,'DeactiveMultytexturing');
  @SetMultytexturingLayerOffset:=GetProcAddress(DGLEngineDLL_Handle,'SetMultytexturingLayerOffset');
  @DrawTextureToTextureTransparentColor:=GetProcAddress(DGLEngineDLL_Handle,'DrawTextureToTextureTransparentColor');
  @ZBuffer:=GetProcAddress(DGLEngineDLL_Handle,'ZBuffer');
  @ResetMatrix:=GetProcAddress(DGLEngineDLL_Handle,'ResetMatrix');
  @DirectSoundInit:=GetProcAddress(DGLEngineDLL_Handle,'DirectSoundInit');
  @LoadSample:=GetProcAddress(DGLEngineDLL_Handle,'LoadSample');
  @FreeSample:=GetProcAddress(DGLEngineDLL_Handle,'FreeSample');
  @PlaySample:=GetProcAddress(DGLEngineDLL_Handle,'PlaySample');
  @SetSampleVolume:=GetProcAddress(DGLEngineDLL_Handle,'SetSampleVolume');
  @PlayMusic:=GetProcAddress(DGLEngineDLL_Handle,'PlayMusic');
  @StopMusic:=GetProcAddress(DGLEngineDLL_Handle,'StopMusic');
  @SetSample3DPosition:=GetProcAddress(DGLEngineDLL_Handle,'SetSample3DPosition');
  @IsMusicPlaying:=GetProcAddress(DGLEngineDLL_Handle,'IsMusicPlaying');
  @GetSample3DPosition:=GetProcAddress(DGLEngineDLL_Handle,'GetSample3DPosition');
  @GetMousePos:=GetProcAddress(DGLEngineDLL_Handle,'GetMousePos');
  @GetMouseButtonPressed:=GetProcAddress(DGLEngineDLL_Handle,'GetMouseButtonPressed');
  @IsKeyPressed:=GetProcAddress(DGLEngineDLL_Handle,'IsKeyPressed');
  @StartKeyboardTextInput:=GetProcAddress(DGLEngineDLL_Handle,'StartKeyboardTextInput');
  @EndKeyboardTextInput:=GetProcAddress(DGLEngineDLL_Handle,'EndKeyboardTextInput');
  @GetKeyboardText:=GetProcAddress(DGLEngineDLL_Handle,'GetKeyboardText');
  @IsMouseMoveing:=GetProcAddress(DGLEngineDLL_Handle,'IsMouseMoveing');
  @MouseWheelDelta:=GetProcAddress(DGLEngineDLL_Handle,'MouseWheelDelta');
  @Input_JoyDown:=GetProcAddress(DGLEngineDLL_Handle,'Input_JoyDown');
  @Input_JoyDirections:=GetProcAddress(DGLEngineDLL_Handle,'Input_JoyDirections');
  @IsRightMouseButtonPressed:=GetProcAddress(DGLEngineDLL_Handle,'IsRightMouseButtonPressed');
  @IsLeftMouseButtonPressed:=GetProcAddress(DGLEngineDLL_Handle,'IsLeftMouseButtonPressed');
  @NET_Init:=GetProcAddress(DGLEngineDLL_Handle,'NET_Init');
  @NET_Free:=GetProcAddress(DGLEngineDLL_Handle,'NET_Free');
  @NET_Clear:=GetProcAddress(DGLEngineDLL_Handle,'NET_Clear');
  @NET_ClearAPL:=GetProcAddress(DGLEngineDLL_Handle,'NET_ClearAPL');
  @NET_GetExternalIP:=GetProcAddress(DGLEngineDLL_Handle,'NET_GetExternalIP');
  @NET_GetHost:=GetProcAddress(DGLEngineDLL_Handle,'NET_GetHost');
  @NET_GetLocalIP:=GetProcAddress(DGLEngineDLL_Handle,'NET_GetLocalIP');
  @NET_HostToIP:=GetProcAddress(DGLEngineDLL_Handle,'NET_HostToIP');
  @NET_InitSocket:=GetProcAddress(DGLEngineDLL_Handle,'NET_InitSocket');
  @NET_Write:=GetProcAddress(DGLEngineDLL_Handle,'NET_Write');
  @NET_Send:=GetProcAddress(DGLEngineDLL_Handle,'NET_Send');
  @NET_Recv:=GetProcAddress(DGLEngineDLL_Handle,'NET_Recv');
  @NET_Update:=GetProcAddress(DGLEngineDLL_Handle,'NET_Update');
  @RenderTexture2D:=GetProcAddress(DGLEngineDLL_Handle,'RenderTexture2D');
  @WriteTextureInfo:=GetProcAddress(DGLEngineDLL_Handle,'WriteTextureInfo');
  @CreateTexture:=GetProcAddress(DGLEngineDLL_Handle,'CreateTexture');
  @_glTexCoord2f:=GetProcAddress(DGLEngineDLL_Handle,'_glTexCoord2f');
  @IsTexCompressionSupported:=GetProcAddress(DGLEngineDLL_Handle,'IsTexCompressionSupported');
end;

function LoadDGLEngineDLL(FileName : string) : boolean;
var DLL_ver : function : byte; stdcall;
begin
 result:=false;

 if not FileExists(FileName) then
 begin
 MessageBox(0, PChar('DGLEngine DLL ("'+ Filename +'") not found!'), 'DGLEngine header', MB_OK or MB_ICONERROR);
 Exit;
 end;

 DGLEngineDLL_Handle:=LoadLibrary(PChar(Filename));
 if DGLEngineDLL_Handle=0 then
 begin
 MessageBox(0, 'Couldn''t load DGLEngine DLL for unknown reason!', 'DGLEngine header', MB_OK or MB_ICONERROR);
 Exit;
 end;

 @DLL_ver:=GetProcAddress(DGLEngineDLL_Handle,'DLL_ver');

 if @DLL_ver=nil then
 begin
 MessageBox(0, 'Corrupted DGLEngine DLL!', 'DGLEngine header', MB_OK or MB_ICONERROR);
 Exit;
 end;

 if DLL_ver<2 then
 begin
 MessageBox(0, 'Application was compiled for DGLEngine version 1.1!'+#13+'Please, upgrade your DGLEngine DLL.', 'DGLEngine header', MB_OK or MB_ICONERROR);
 Exit;
 end;

 if DLL_ver>=1 then InitDGLE_1_0;
 if DLL_ver>=2 then InitDGLE_1_1;

 result:=true;
end;

procedure FreeDGLEngineDLL(Terminate : boolean = true);
begin

 if Terminate then TerminateProcess(GetCurrentProcess,0)
 else
 if not FreeLibrary(DGLEngineDLL_Handle) then
 begin
 DGLEngineDLL_Handle:=0;
 MessageBox(0, 'Couldn''t free DGLEngine DLL!', 'DGLEngine header', MB_OK or MB_ICONERROR);
 end;

end;

end.

