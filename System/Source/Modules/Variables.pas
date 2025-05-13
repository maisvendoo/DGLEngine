//----------------------------------------------------------------------------//
//DRON's OpenGl Engine V 1.0 http://dronprogs.mirgames.ru                     //
//                                                                            //
// Variables.pas V 1.0, 15.01.2006                                            //
//                                                                            //
// Simply all engine shared variables and types.                              //
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
unit Variables;

interface
uses Windows,IniFile,OpenGL;

type

TVertex=record X, Y, Z: single; end;

TVertex4D=record X, Y, Z, W: single; end;

TTextureInfo = record
Index : Cardinal;
Width,Height : integer;
Detail, FileType : byte;
end;

TEngTimer = record
Active : boolean;
Interval,Tick : integer;
OnTimer : procedure;
end;

TBox = record
X,Y,W,H : cardinal;
end;

TFontHeader = record
version : byte;
Width,Height : integer;
Buks : array [0..223] of TBox;
end;

TDGLFont = record
Load : boolean;
Width,Height : integer;
Buks : array [0..223] of TBox;
Texture : GLUInt;
end;

TPlugin = record
Name : string;
Loaded : boolean;
Handle: THandle;
Init : procedure (DGLE_Handle : THandle; EngWinHandle : HWND; ProcessInterval : byte); stdcall;
Free : procedure; stdcall;
DrawPre : procedure; stdcall;
DrawPost : procedure; stdcall;
Process : procedure; stdcall;
OnMessage : procedure (var Msg : tagMSG); stdcall;
end;

const
  FPS_TIMER = 1;
  FPS_INTERVAL = 1000;
  PROCESS_TIMER = 2;

  VERSION : shortstring = 'v1.1 RC2,30.04.2008,21:12';

  ENGINE_LABEL = 'DGLEngine Version 1.1 RC2';

  EngineLog = 'DGLEngine_Log.txt';

var
  WND_TITLE : PAnsiChar = ENGINE_LABEL;
  IniFileName : string = 'Settings.ini';
  PROCESS_INTERVAL : byte = 20;
  h_Wnd  : HWND;
  h_DC   : HDC;
  h_RC   : HGLRC;
  ExtFPS : Integer;
  OpenGLInitialized : boolean;
  StartQuitingEngine : boolean = true;
  IsWriteLog : boolean = true;
  UseSettingsIni : boolean = true;

  MultyTexActive : boolean = false;
  DrawToPanel : boolean = FALSE;
  ShowLogo : boolean = TRUE;
  INITStencil : boolean = FALSE;
  InitFullscreen : boolean =  true;
  _TextureCompression : boolean = false;
  _TextureFiltering : boolean = true;
  _AllowAutoPause : boolean = true;
  _UseVBO         : boolean = true;
  _UseFBO         : boolean = true;
  _SceneDontUseMat: boolean = false;
  _frustumcalculated: boolean =false;
  //_NormCubemap : cardinal = 0;  
  MipMapping : boolean = false;
  InitResX : cardinal = 800;
  InitResY : cardinal = 600;
  InitPDepth : integer = 32;
  InitVsync : boolean = false;
  InitFrequency : integer = 60;
  InitZNear : single = 0.5;
  InitZfar : single = 200.0;
  initAngle : single = 45.0;
  InitZBuffer : byte = 24;
  WinX : integer = 0;
  WinY : integer = 0;
  CurW,CurH : integer;

  TexturesInfo : array of TTextureInfo;

  EngTimers : array of TEngTimer;

  DGLFonts : array of TDGLFont;

  Plugins : array of TPlugin;

  glDraw, ProcessGame, LoadTextures, DestroyAll: procedure;

implementation
end.
