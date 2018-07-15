//----------------------------------------------------------------------------//
//DRON's OpenGl Engine V 1.0 http://dronprogs.mirgames.ru                     //
//                                                                            //
// DGLEngine.dpr V 1.0, 25.01.2006                                            //
//                                                                            //
// Engine Delphi project file.                                                //
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
// To DO:                                                                     //
//   1)Use GL_ARB_texture_env_combine to set texture combine between          //
//     multy tex. layers.                                                     //
//   2)Make ShadowMaps transparent.                                           //
//   3)DOT3 bump mapping.                                                     //
//   4)fragment programs.                                                     //
//----------------------------------------------------------------------------//

library DGLEngine;

uses
  EngineUtils in 'Modules\EngineUtils.pas',
  OpenGL in 'Modules\Headers\OpenGL.pas',
  IniFile in 'Modules\IniFile.pas',
  DrawFunc2D in 'Modules\DrawFunc2D.pas',
  Textures in 'Modules\Textures.pas',
  Variables in 'Modules\Variables.pas',
  DPC_Packages in 'Modules\DPC_Packages.pas',
  Console in 'Modules\Console.pas',
  DrawFunc3D in 'Modules\DrawFunc3D.pas',
  Sound in 'Modules\Sound.pas',
  Net in 'Modules\Net.pas',
  DirectX in 'Modules\Headers\DirectX.pas',
  Advanced3D in 'Modules\Advanced3D.pas',
  DMD_MultyMesh in 'Modules\DMD_MultyMesh.pas',
  Vfw in 'Modules\Headers\Vfw.pas',
  TFrustumClass in 'Modules\TFrustumClass.pas',
  EngineCore in 'Modules\EngineCore.pas';

//Function needed for engine header
function DLL_ver : byte; stdcall;
begin
result:=1;
end;

exports
//UnDocumented
SetClipPlane,
DLL_ver,
RenderTexture2D,
WriteTextureInfo,
CreateTexture,
_glTexCoord2f,
//Engine
EngineProcessInterval,
EngineVersion,
AutoPause,
SetDefaultJPGTransparentColorTolerance,
MaxMultiTexturingLayers,
IsShadowMapsSupported,
IsDOT3Supported,
IsTexCompressionSupported,
IsVShadersSupported,
IsPShadersSupported,
FreePlugin,
GetPluginHandle,
IsPluginLoaded,
LoadPlugin,
StartEngine,
RegProcedure,
TextureMipMapping,
TextureFiltering,
TextureParametrs,
AddToLogFile,
TextureCompression,
EngineMainDraw,
EnableStencilBuffer,
UpdateRenderRect,
StartEngine_DrawToPanel,
EngineProcessMessages,
ApplicationName,
GetFPS,
LoadFontFromFile,
SetWindowPosition,
QuitEngine,
PleaseNoLogo,
SetGameProcessInterval,
ExtractFromPackage,
FreeTexture,
LoadTexture,
LoadTGATexture,
LoadTextureFromPackage,
LoadTextureFromFile,
SetEngineInitParametrs,
ReadValueFromIniFile,
WriteValueToIniFile,
SetEngineInifileName,
PrintScreen,
GetScreenResX,
GetScreenResY,
SetCutingPlanes,
SetViewAngle,
ClearZBuffer,
SetZBufferDepth,
LoadFromPackage,
GetTextureInfo,
AddTimer,
EnableTimer,
DisableTimer,
SetTimerInterval,
FreeFont,
//Console
AddStringToConsole,
RegisterCommandProcedure,
CreateConsole,
RegisterCommandValue,
ProcessConsole,
DrawConsole,
ClearConsole,
GetLastComParam,
//Graphics 2D
Begin2D,
End2D,
DrawTexture2D,
GetTextHeight,
DrawTexture2D_Simple,
DrawTexture2D_VertexColor,
DrawSprite2D_Simple,
DrawSprite2D,
DrawSprite2D_VertexColor,
PutPoint2D,
DrawLine2D,
DrawRectangle2D,
DrawRectangle2D_Fill_VertexColor,
DrawCircle2D,
DrawEllipse2D,
DrawText2D,
GetTextWidth,
DrawCircle2D_Fill,
DrawCircleArc2D,
DrawColorLine2D,
DrawTexture2D_Split,
DrawPolygon2D,
DrawSprite2D_Tile,
DrawEllipse2D_Fill,
DrawPolygon2D_VertexColor,
//Graphics 3D
BeginObj3D,
EndObj3D,
Position3D,
Color3D,
SetShadowRenderAngle,
ModelTrianglesCount,
AdductingMatrix3Dto2D,
ReturnStandartMatrix3D,
DrawAxes,
RotateX,
RotateY,
RotateZ,
SetTexture,
Position2D,
DrawPlane,
DrawSphere,
DrawCube,
DrawLine,
Drawpoint,
DrawCylinder,
CreateFont3D,
Write3D,
LoadModel,
FreeModel,
DrawModel,
ModelFramesCount,
Scale3D,
EnableSphereMapping,
DisableSphereMapping,
SetLight,
DrawEllipse,
StartRenderToTexture,
EndRenderToTexture,
CreateTextureToRenderIn,
SetFog,
DeactiveFog,
StartWriteToVideoMemory,
EndWriteToVideoMemory,
FreeFromVideoMemory,
DrawFromVM,
DrawSprite,
DrawTextureToTexture,
SetMultytexturingLayerTexCoordMulti,
DrawPolygon3D,
CreateAVITexture,
FreeAVITexture,
SetAviTexture,
SetCamera,
DeactiveLight,
ModelBoundingBox,
SetupProjector,
DisableProjector,
RenderProjection,
RenderProjectedTexture,
PrepareSceneForProjecting,
EndDrawingProjectedScene,
Get3DPos,
Get2DPos,
Get3DPosFree,
CalculateFrustum,
IsPointInFrustum,
IsSphereInFrustum,
IsBoxInFrustum,
DrawSprite_BillBoard,
CreateShadowMap,
CastShadowMap,
ActivateMultitexturingLayer,
DeactiveMultytexturing,
SetMultytexturingLayerOffset,
DrawTextureToTextureTransparentColor,
ZBuffer,
ResetMatrix,
//Sound
DirectSoundInit,
LoadSample,
FreeSample,
PlaySample,
SetSampleVolume,
PlayMusic,
StopMusic,
SetSample3DPosition,
IsMusicPlaying,
GetSample3DPosition,
//Input
GetMousePos,
GetMouseButtonPressed,
IsKeyPressed,
StartKeyboardTextInput,
EndKeyboardTextInput,
GetKeyboardText,
IsMouseMoveing,
MouseWheelDelta,
Input_JoyDown,
Input_JoyDirections,
IsRightMouseButtonPressed,
IsLeftMouseButtonPressed,
//Network
NET_Init,
NET_Free,
NET_Clear,
NET_ClearAPL,
NET_GetExternalIP,
NET_GetHost,
NET_GetLocalIP,
NET_HostToIP,
NET_InitSocket,
NET_Write,
NET_Send,
NET_Recv,
NET_Update;

begin
  Randomize;
  @glDraw:=nil;
  @ProcessGame:=nil;
  @LoadTextures:=nil;
  @DestroyAll:=nil;
  SetLength(TexturesInfo,0);
  SetLength(EngTimers,0);
  SetLength(DGLFonts,0);
  SetLength(Plugins,0);
end.
