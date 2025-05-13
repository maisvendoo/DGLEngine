//DGLEngine Dinamic Linking Header for Plugins
//V 1.0
//Author: DRON
unit DGLE_Plugin_header;

interface
uses Windows, Classes;

const
ENGINE_LOGFILE = 'DGLEngine_Log.txt';
var
AddToLogFile : procedure (FileName, LogStr:String; IsDate : Boolean = false; IsTime : Boolean = false; FileRewrite : boolean = false);  stdcall;
GetFPS : function : integer; stdcall;
const
ENGINE_INIFILE = 'Settings.ini';
var
ReadValueFromIniFile : function (Filename, Section, Key: string):string; stdcall;
WriteValueToIniFile : procedure (Filename, Section, Key, Value : string); stdcall;
const
TEXDETAIL_BEST   = 0;
TEXDETAIL_SMOOTH = 1;
TEXDETAIL_MEDIUM = 2;
TEXDETAIL_POOR   = 3;
var
LoadTexture : function (Filename: String; var Texture: Cardinal; Detail : byte = TEXDETAIL_BEST; BMPTransparentColor : cardinal = $808080) : Boolean;  stdcall;
ExtractFromPackage : procedure (const PackageName, Name, DestFilename : string); stdcall;
LoadFromPackage : function (const Filename, Name : string):TMemoryStream; stdcall;
LoadTextureFromPackage : function (Filename, Name : string; var Texture: Cardinal; Detail : byte = TEXDETAIL_BEST; BMPTransparentColor : cardinal = $808080) : boolean;  stdcall;
FreeTexture : procedure (Texture : Cardinal); stdcall;
TextureCompression : procedure (Enable : boolean); stdcall;
const
IS_TGA       = 1;
IS_BMP       = 2;
IS_JPG       = 3;
IS_GEN       = 4;
IS_UNLOAD    = 0;
INDEX_UNLOAD = 0;
type TTextureInfo = record
Index : Cardinal;
Width,Height : integer;
Detail,
TextureType : byte;
end;
var
GetTextureInfo : function (Texture : Cardinal) : TTextureInfo; stdcall;
AddTimer : function (Interval : Cardinal; OnTimerProcedure : pointer) : Cardinal; stdcall;
DisableTimer : procedure (Ident : Cardinal); stdcall;
EnableTimer : procedure (Ident : Cardinal); stdcall;
SetTimerInterval : procedure (Ident, Interval : Cardinal); stdcall;
LoadFontFromFile : function (Filename : string) : Cardinal; stdcall;
FreeFont : procedure (Ident : cardinal); stdcall;

RegisterCommandProcedure : procedure (ComName : string; ProcAdress : pointer); stdcall;
GetLastComParam : function : string; stdcall;
RegisterCommandValue : procedure (ComName : string; ValueAdress : pointer; MaxValue, MinValue : integer); stdcall;
AddStringToConsole : procedure (Text : string); stdcall;

Begin2D : procedure; stdcall;
End2D : procedure; stdcall;
PutPoint2D : procedure (X,Y,Color : integer; Alpha : integer = 255) ; stdcall;
DrawLine2D : procedure (X1, Y1, X2, Y2, Color : integer; Alpha : integer = 255; LineWidth : real = 1.0; Smooth : boolean = false); stdcall;
DrawColorLine2D : procedure (X1, Y1, X2, Y2, Color1, Color2 : integer; Alpha : integer = 255; LineWidth : real = 1.0; Smooth : boolean = true); stdcall;
DrawRectangle2D : procedure(X, Y, Width, Height, Color : integer; Alpha : integer = 255; Fill : boolean = false); stdcall;
DrawRectangle2D_Fill_VertexColor : procedure(X, Y, Width, Height, Color1, Color2, Color3, Color4, Alpha1, Alpha2, Alpha3, Alpha4 : integer); stdcall;
DrawCircle2D : procedure(X, Y, Radius, Color : integer; Alpha : byte = 255); stdcall;
DrawCircle2D_Fill : procedure(X, Y, Radius, Color : integer; Alpha : byte = 255); stdcall;
DrawEllipse2D : procedure(Center: TPoint; Radius0, Radius1, Vertices: Integer; Color: Cardinal; Alpha: byte=255); stdcall;
DrawEllipse2D_Fill : procedure(Center: TPoint; Radius0, Radius1: Integer; Color: Cardinal; Alpha: byte=255); stdcall;
DrawCircleArc2D : procedure(X, Y, Radius, Angle1, Angle2, Color: Integer; Alpha : byte = 255); stdcall;
DrawPolygon2D : procedure(points : array of Tpoint; Color, Alpha : integer); stdcall;
type TColorVertex2D = record X,Y,Color, Alpha : integer; end;
var
DrawPolygon2D_VertexColor : procedure(points : array of TColorVertex2D); stdcall;
DrawTexture2D_Simple : procedure(Texture : Cardinal; X , Y, ImageWidth, ImageHeight : integer; FlipX : boolean = false; FlipY : boolean = false); stdcall;
DrawTexture2D_Split : procedure(Texture : Cardinal; X , Y, TexWidth, TexHeight : integer; Angle, Alpha, Color : integer; SplitRect : Trect; Scale : single = 1.0; FlipX : boolean = false; FlipY : boolean = false); stdcall;
DrawTexture2D : procedure(Texture : Cardinal; X , Y, ImageWidth, ImageHeight, Angle, Alpha, Color : integer; Diffuse : boolean = false; FlipX : boolean = false; FlipY : boolean = false); stdcall;
DrawTexture2D_VertexColor : procedure(Texture : Cardinal; X , Y, ImageWidth, ImageHeight, Color1, Color2, Color3, Color4, Alpha1, Alpha2, Alpha3, Alpha4 : integer; FlipX : boolean = false; FlipY : boolean = false); stdcall;
DrawSprite2D_Simple : procedure (Texture : Cardinal; X , Y, ImageWidth, ImageHeight,FramesXCount, FramesYCount, FrameNumber: integer; FlipX : boolean = false; FlipY : boolean = false); stdcall;
DrawSprite2D : procedure (Texture : Cardinal; X , Y, ImageWidth, ImageHeight,FramesXCount, FramesYCount, FrameNumber, Angle, Alpha, Color : integer; Diffuse : boolean = false; FlipX : boolean = false; FlipY : boolean = false); stdcall;
DrawSprite2D_VertexColor : procedure (Texture : Cardinal; X , Y, ImageWidth, ImageHeight,FramesXCount, FramesYCount, FrameNumber, Color1, Color2, Color3, Color4, Alpha1, Alpha2, Alpha3, Alpha4 : integer; FlipX : boolean = false; FlipY : boolean = false);
DrawSprite2D_Tile : procedure (Texture : Cardinal; X, Y, TexWidth, TexHeight, FrameWidth, FrameHeight, FramesXCount, FramesYCount, FrameNumber, Angle, Alpha, Color : integer; Scale : single = 1.0; FlipX : boolean = false; FlipY : boolean = false); stdcall;
DrawText2D : procedure (Font : Cardinal; X,Y : integer; Text : string; Color : integer = $FFFFFF; Alpha : integer = 255; Scale : real = 1.0); stdcall;
GetTextWidth : function (Font : Cardinal; Text : string; Scale : real = 1.0):integer; stdcall;
GetTextHeight : function (Font : Cardinal; Text : string; Scale : real = 1.0):integer; stdcall;
CreateSystemFont2D : function (Face: PChar; Width, Height: integer): cardinal; stdcall;
FreeSystemFont2D : procedure (Font: cardinal); stdcall;
SystemTextOut2D : procedure (Font: cardinal; const Text: string; X, Y: integer; Color : integer = $FFFFFF; Alpha : byte = 255); stdcall;

BeginObj3D : procedure; stdcall;
EndObj3D : procedure; stdcall;
type
  TVertex = record X, Y, Z: single; end;
  TCamera = record
            Eye    : TVertex;
            Center : TVertex;
            end;
var
SetCamera : procedure(Camera : TCamera); stdcall;
Position3D : procedure(X,Y,Z : single); stdcall;
Scale3D : procedure(Scale : single); stdcall;
RotateX : procedure(Angle : single); stdcall;
RotateY : procedure(Angle : single); stdcall;
RotateZ : procedure(Angle : single); stdcall;
Color3D : procedure(Color:integer; Alpha : byte = 255; Diffuse : boolean= false; MaterialShininess : single = 0.0); stdcall;
const
TEX_BLANK = 0;
var
SetTexture : procedure(Texture : Cardinal); stdcall;
const
  LIGHTS_ALL = -1;
  LIGHT0     =  0;
  LIGHT1     =  1;
  LIGHT2     =  2;
  LIGHT3     =  3;
  LIGHT4     =  4;
  LIGHT5     =  5;
  LIGHT6     =  6;
  LIGHT7     =  7;
  LIGHT8     =  8;
  LIGHT9     =  9;
var
SetLight : procedure(ID : integer = LIGHT0; X : single = 1;Y : single = 0;Z : single = 1; light_Color : integer =$FFFFFF; Visualize : boolean = false; VisualScale : single = 0.1); stdcall;
DeactiveLight : procedure(ID : integer = LIGHTS_ALL); stdcall;
AdductingMatrix3Dto2D : procedure; stdcall;
ReturnStandartMatrix3D : procedure; stdcall;
Position2D : procedure(X,Y : integer); stdcall;
CreateFont3D : function(const Fontname : string):integer; stdcall;
Write3D : procedure(FontIdent: integer; Text: string); stdcall;
const
MDL_NO_SCALE               = 0;
MDL_SCALE_EVERY_FRAME      = 1;
MDL_SCALE_GL_ONE           = 2;
MDL_SCALE_BY_LARGEST_FRAME = 3;
var
LoadModel : function (Filename : string; ScaleType : byte = MDL_SCALE_BY_LARGEST_FRAME) : integer; stdcall;
FreeModel : procedure(ModelIdent : integer); stdcall;
DrawModel : procedure(ModelIdent : integer; Frame : integer = 0; Smooth : boolean = true); stdcall;
ModelFramesCount : function(Modelident : integer):Integer; stdcall;
ModelBoundingBox : function (Modelident,Frame : integer):TVertex; stdcall;
ModelTrianglesCount : function (Modelident,Frame : integer) : Cardinal; stdcall;
EnableSphereMapping : procedure; stdcall;
DisableSphereMapping : procedure; stdcall;
SetFog : procedure(Color : Integer; Fog_Start, Fog_End : single); stdcall;
DeactiveFog : procedure; stdcall;
DrawBumpMappedPlane : procedure(Tex, BumpTex : Cardinal; LightX, LightY : single); stdcall;
DrawAxes : procedure(Length : single = 1.0); stdcall;
DrawPoint : procedure(X,Y,Z : single); stdcall;
DrawLine : procedure(X,Y,Z,X1,Y1,Z1 : single; LineWidth : real = 1.0; Smooth : boolean = true); stdcall;
DrawPlane : procedure(Width,Height : single); stdcall;
type TVertex3D = record X,Y,Z : single; Color, Alpha : integer; TexX, TexY : single; end;
var
DrawPolygon3D : procedure(points : array of TVertex3D); stdcall;
DrawSprite : procedure(Width,Height : single; FramesXCount, FramesYCount, FrameNumber: integer);stdcall;
DrawSprite_BillBoard : procedure(Width,Height : single; FramesXCount, FramesYCount, FrameNumber: integer);stdcall;
DrawCube : procedure(Width,Height,Depth : single); stdcall;
DrawSphere : procedure(Radius : single); stdcall;
DrawCylinder : procedure(Radius,Height : single); stdcall;
DrawEllipse : procedure(Width, Height, Depth : single); stdcall;
DrawSky : procedure(Up,Down,Left,Right,Front,Back : Cardinal); stdcall;

Get3DPos :function : TVertex;  stdcall;
Get2DPos : function (Vertex : TVertex) : TPoint; stdcall;
StartWriteToVideoMemory : function : cardinal; stdcall;
EndWriteToVideoMemory : procedure; stdcall;
FreeFromVideoMemory : procedure(Ident : integer); stdcall;
DrawFromVM : procedure(Ident : integer); stdcall;
CreateAVITexture : function(Filename : string) : integer; stdcall;
FreeAVITexture : procedure(index : integer); stdcall;
SetAviTexture : procedure(index : integer); stdcall;
RenderShadowsToPlane : procedure(LightID : integer; ShadowCasterProc : pointer; PlaneCenter : TVertex; PLaneWidth, PlaneHeight : single; PlaneTexture : Cardinal; PlaneXTexturesCount : integer = 1; PlaneYTexturesCount : integer = 1);stdcall;
ClearZBuffer : procedure; stdcall;
PrepareProjectTexture : procedure(Texture : cardinal);stdcall;
SetupProjector : procedure; stdcall;
DisableProjector : procedure; stdcall;
RenderProjection : procedure(ProjectTexture : cardinal; DrawScene : pointer; ProjectorOrientation: TCamera; Diffuse : boolean = true); stdcall;
EndDrawingProjectedScene : procedure; stdcall;
RenderProjectedTexture : procedure(ProjectTexture : Cardinal; ProjectorOrientation: TCamera; Diffuse : boolean = true); stdcall;
PrepareSceneForProjecting : procedure; stdcall;
CreateTextureToRenderIn : function(TextureWidth,TextureHeight : integer):Cardinal; stdcall;
StartRenderToTexture : procedure(Texture : Cardinal); stdcall;
EndRenderToTexture : procedure; stdcall;
CalculateFrustum : procedure; stdcall;
IsPointInFrustum : function(X,Y,Z : single) : boolean; stdcall;
IsSphereInFrustum : function(X,Y,Z,Radius : single) : boolean; stdcall;
IsBoxInFrustum : function(X,Y,Z,W,H,D : single) : boolean; stdcall;

DirectSoundInit : procedure; stdcall;
PlayMusic : procedure(Filename : string; Looped : boolean = true); stdcall;
StopMusic : procedure; stdcall;
IsMusicPlaying :function: boolean; stdcall;
LoadSample : function(Filename : string; FromPackage : boolean = false; Name : string = ''):integer; stdcall;
FreeSample : procedure(Index : integer); stdcall;
PlaySample : procedure(Index : integer); stdcall;
SetSampleVolume : procedure(Index : integer; Volume : byte); stdcall;
SetSample3DPosition : procedure(Index : integer; X,Y,Z : real); stdcall;
GetSample3DPosition : procedure(Index : integer; var X,Y,Z : single); stdcall;

IsKeyPressed : function(Key : integer) : boolean; stdcall;
const
MB_LEFT  =1;
MB_MIDDLE=3;
MB_RIGHT =2;
var
GetMouseButtonPressed :function: byte; stdcall;
IsLeftMouseButtonPressed :function: boolean; stdcall;
IsRightMouseButtonPressed :function: boolean; stdcall;
GetMousePos :function: Tpoint; stdcall;
IsMouseMoveing :function: boolean; stdcall;
StartKeyboardTextInput : procedure; stdcall;
EndKeyboardTextInput : procedure; stdcall;
GetKeyboardText :function: string; stdcall;
Input_JoyDown:function(JoyNum, Button: Byte): boolean; stdcall;
Input_JoyDirections:function(JoyNum, Direction: Byte): boolean; stdcall;

NET_Init :function: boolean; stdcall;
NET_Free :procedure; stdcall;
NET_Clear :procedure; stdcall;
NET_ClearAPL :procedure; stdcall;
NET_GetExternalIP :function: PChar; stdcall;
NET_GetHost :function: PChar; stdcall;
NET_GetLocalIP :function: PChar; stdcall;
NET_HostToIP :function(Host: PChar): PChar; stdcall;
NET_InitSocket :function(Port: WORD): integer; stdcall;
NET_Write :function(Buf: pointer; Count: integer): boolean; stdcall;
NET_Send :function(IP: PChar; Port: WORD; APL: boolean): integer; stdcall;
NET_Recv :function(Buf: pointer; Count: integer; var IP: PChar; var Port: integer; var RecvBytes: integer): integer; stdcall;
NET_Update : procedure; stdcall;

//Exclusive functions exports for plugin

RenderTexture2D : procedure (Texture : Cardinal; X, Y, FrameWidth, FrameHeight : integer; Color : integer; Alpha : byte; Angle : integer;
Frame : byte = 1; FrameCountX : byte = 1; FrameCountY : byte = 1; ScaleX : single = 1.0; ScaleY : single = 1.0; Color4 : boolean = false;
VColor1: integer = 0; VColor2: integer = 0; VColor3: integer = 0; VColor4: integer = 0;
VAlpha1: integer = 0; VAlpha2: integer = 0; VAlpha3: integer = 0; VAlpha4: integer = 0;
Diffuse : boolean = false; FlipX : boolean = false; FlipY : boolean = false); stdcall;

const
//Typ parametrs
IS_TGA       = 1;
IS_BMP       = 2;
IS_JPG       = 3;
IS_GEN       = 4;
IS_UNLOAD    = 0;
INDEX_UNLOAD = 0;
//Det parametrs
TEXDETAIL_BEST   = 0;
TEXDETAIL_SMOOTH = 1;
TEXDETAIL_MEDIUM = 2;
TEXDETAIL_POOR   = 3;
var
WriteTextureInfo : procedure (Ind : cardinal; W,H : integer; Det, Typ : byte); stdcall;

const
//Texture formats
TEX_ALPHA = $1906;
TEX_RGB   = $1907;
TEX_RGBA  = $1908;
var
CreateTexture : function (Width, Height, Format : Word; pData : Pointer) : Cardinal; stdcall;

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


procedure InitDGLEngineHeader (const Adr : array of pointer); stdcall;

implementation

procedure InitDGLEngineHeader (const Adr : array of pointer); stdcall;
begin
@AddToLogFile             :=Adr[0];
@GetFPS                   :=Adr[1];
@ReadValueFromIniFile     :=Adr[2];
@WriteValueToIniFile      :=Adr[3];
@LoadTexture              :=Adr[4];
@ExtractFromPackage       :=Adr[5];
@LoadFromPackage          :=Adr[6];
@LoadTextureFromPackage   :=Adr[7];
@FreeTexture              :=Adr[8];
@TextureCompression       :=Adr[9];
@GetTextureInfo           :=Adr[10];
@AddTimer                 :=Adr[11];
@DisableTimer             :=Adr[12];
@EnableTimer              :=Adr[13];
@SetTimerInterval         :=Adr[14];
@LoadFontFromFile         :=Adr[15];
@FreeFont                 :=Adr[16];
@RegisterCommandProcedure :=Adr[17];
@GetLastComParam          :=Adr[18];
@RegisterCommandValue     :=Adr[19];
@AddStringToConsole       :=Adr[20];
@Begin2D                  :=Adr[21];
@End2D                    :=Adr[22];
@PutPoint2D               :=Adr[23];
@DrawLine2D               :=Adr[24];
@DrawColorLine2D          :=Adr[25];
@DrawRectangle2D          :=Adr[26];
@DrawRectangle2D_Fill_VertexColor :=Adr[27];
@DrawCircle2D             :=Adr[28];
@DrawCircle2D_Fill        :=Adr[29];
@DrawEllipse2D            :=Adr[30];
@DrawEllipse2D_Fill       :=Adr[31];
@DrawCircleArc2D          :=Adr[32];
@DrawPolygon2D            :=Adr[33];
@DrawPolygon2D_VertexColor:=Adr[34];
@DrawTexture2D_Simple     :=Adr[35];
@DrawTexture2D_Split      :=Adr[36];
@DrawTexture2D            :=Adr[37];
@DrawTexture2D_VertexColor:=Adr[38];
@DrawSprite2D_Simple      :=Adr[39];
@DrawSprite2D             :=Adr[40];
@DrawSprite2D_VertexColor :=Adr[41];
@DrawSprite2D_Tile        :=Adr[42];
@DrawText2D               :=Adr[43];
@GetTextWidth             :=Adr[44];
@GetTextHeight            :=Adr[45];
@CreateSystemFont2D       :=Adr[46];
@FreeSystemFont2D         :=Adr[47];
@SystemTextOut2D          :=Adr[48];
@BeginObj3D               :=Adr[49];
@EndObj3D                 :=Adr[50];
@SetCamera                :=Adr[51];
@Position3D               :=Adr[52];
@Scale3D                  :=Adr[53];
@RotateX                  :=Adr[54];
@RotateY                  :=Adr[55];
@RotateZ                  :=Adr[56];
@Color3D                  :=Adr[57];
@SetTexture               :=Adr[58];
@SetLight                 :=Adr[59];
@DeactiveLight            :=Adr[60];
@AdductingMatrix3Dto2D    :=Adr[61];
@ReturnStandartMatrix3D   :=Adr[62];
@Position2D               :=Adr[63];
@CreateFont3D             :=Adr[64];
@Write3D                  :=Adr[65];
@LoadModel                :=Adr[66];
@FreeModel                :=Adr[67];
@DrawModel                :=Adr[68];
@ModelFramesCount         :=Adr[69];
@ModelBoundingBox         :=Adr[70];
@ModelTrianglesCount      :=Adr[71];
@EnableSphereMapping      :=Adr[72];
@DisableSphereMapping     :=Adr[73];
@SetFog                   :=Adr[74];
@DeactiveFog              :=Adr[75];
@DrawBumpMappedPlane      :=Adr[76];
@DrawAxes                 :=Adr[77];
@DrawPoint                :=Adr[78];
@DrawLine                 :=Adr[79];
@DrawPlane                :=Adr[80];
@DrawPolygon3D            :=Adr[81];
@DrawSprite               :=Adr[82];
@DrawCube                 :=Adr[83];
@DrawSphere               :=Adr[84];
@DrawCylinder             :=Adr[85];
@DrawEllipse              :=Adr[86];
@DrawSky                  :=Adr[87];
@Get3DPos                 :=Adr[88];
@Get2DPos                 :=Adr[89];
@StartWriteToVideoMemory  :=Adr[90];
@EndWriteToVideoMemory    :=Adr[91];
@FreeFromVideoMemory      :=Adr[92];
@DrawFromVM               :=Adr[93];
@CreateAVITexture         :=Adr[94];
@FreeAVITexture           :=Adr[95];
@SetAviTexture            :=Adr[96];
@RenderShadowsToPlane     :=Adr[97];
@ClearZBuffer             :=Adr[98];
@PrepareProjectTexture    :=Adr[99];
@SetupProjector           :=Adr[100];
@DisableProjector         :=Adr[101];
@RenderProjection         :=Adr[102];
@EndDrawingProjectedScene :=Adr[103];
@RenderProjectedTexture   :=Adr[104];
@PrepareSceneForProjecting:=Adr[105];
@CreateTextureToRenderIn  :=Adr[106];
@StartRenderToTexture     :=Adr[107];
@EndRenderToTexture       :=Adr[108];
@CalculateFrustum         :=Adr[109];
@IsPointInFrustum         :=Adr[110];
@IsSphereInFrustum        :=Adr[111];
@IsBoxInFrustum           :=Adr[112];
@DirectSoundInit          :=Adr[113];
@PlayMusic                :=Adr[114];
@StopMusic                :=Adr[115];
@IsMusicPlaying           :=Adr[116];
@LoadSample               :=Adr[117];
@FreeSample               :=Adr[118];
@PlaySample               :=Adr[119];
@SetSampleVolume          :=Adr[120];
@SetSample3DPosition      :=Adr[121];
@GetSample3DPosition      :=Adr[122];
@IsKeyPressed             :=Adr[123];
@GetMouseButtonPressed    :=Adr[124];
@IsLeftMouseButtonPressed :=Adr[125];
@IsRightMouseButtonPressed:=Adr[126];
@GetMousePos              :=Adr[127];
@IsMouseMoveing           :=Adr[128];
@StartKeyboardTextInput   :=Adr[129];
@EndKeyboardTextInput     :=Adr[130];
@GetKeyboardText          :=Adr[131];
@Input_JoyDown            :=Adr[132];
@Input_JoyDirections      :=Adr[133];
@NET_Init                 :=Adr[134];
@NET_Free                 :=Adr[135];
@NET_Clear                :=Adr[136];
@NET_ClearAPL             :=Adr[137];
@NET_GetExternalIP        :=Adr[138];
@NET_GetHost              :=Adr[139];
@NET_GetLocalIP           :=Adr[140];
@NET_HostToIP             :=Adr[141];
@NET_InitSocket           :=Adr[142];
@NET_Write                :=Adr[143];
@NET_Send                 :=Adr[144];
@NET_Recv                 :=Adr[145];
@NET_Update               :=Adr[146];
@DrawSprite_BillBoard     :=Adr[147];
@RenderTexture2D          :=Adr[148];
@WriteTextureInfo         :=Adr[149];
@CreateTexture            :=Adr[150];
end;

end.
