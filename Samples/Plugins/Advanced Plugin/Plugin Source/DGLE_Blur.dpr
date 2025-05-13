library DGLE_Blur;

uses
  Windows,
  Messages,
  OpenGl;

{$R *.res}

var PluginLoaded : boolean = false;
    BlurTex : glUint;
    Frames : Integer;
    Enabled : boolean = true;
    DrawProcedure, BgDraw : procedure;

GetScreenResX : function : integer; stdcall;
GetScreenResY : function : integer; stdcall;

type PGLuint = ^Cardinal;
procedure glDeleteTextures(n: integer; const textures: PGLuint); stdcall; external opengl32;
procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;
procedure glGenTextures(n: GLsizei; var textures: GLuint); stdcall; external opengl32;
procedure glCopyTexImage2D(target: GLEnum; level: GLint; internalFormat: GLEnum; x, y: GLint; width, height: GLsizei; border: GLint); stdcall; external opengl32;

procedure CreateBlurTexture;
var pData: Pointer;
begin
  GetMem(pData, 512*512*3);

  glGenTextures(1, BlurTex);
  glBindTexture(GL_TEXTURE_2D, BlurTex);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 512, 512, 0, GL_RGB, GL_UNSIGNED_BYTE, pData);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

  FreeMem(pData);
end;

procedure blur_RegisterDrawProcedure(BlurObjDraw, BackDraw : pointer); stdcall;
begin
@DrawProcedure:=BlurObjDraw;
@BgDraw:=BackDraw;
end;

procedure blur_Activate(Enable : boolean); stdcall;
begin
Enabled:=Enable;
end;

procedure blur_Textures(Count : cardinal); stdcall;
begin
if Count>20 then Count:=20;
Frames:=Count;
end;

procedure Init(DGLE_Handle : THandle; EngWinHandle : HWND; ProcessInterval : byte); stdcall;
begin

 @GetScreenResX:=GetProcAddress(DGLE_Handle,'GetScreenResX');
 @GetScreenResY:=GetProcAddress(DGLE_Handle,'GetScreenResY');

 Frames :=10;
 CreateBlurTexture;
 PluginLoaded:=true;
end;

procedure Free; stdcall;
begin
glDeleteTextures(1,@BlurTex);
PluginLoaded:=false;
end;

procedure RenderScene(Width,Height : cardinal);
begin
if Enabled then
begin
  glPushMatrix();
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA,GL_ONE);

    glColor4f(1.0, 1.0, 1.0, 1 - 1/frames);

    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
      glLoadIdentity();
      glOrtho( 0, Width, Height, 0, 0, 1);
      glMatrixMode(GL_MODELVIEW);
      glLoadIdentity();

      glBindTexture(GL_TEXTURE_2D, blurTex);
      glBegin(GL_QUADS);
        glTexCoord2f(0.0, 1.0);  glVertex2f(0, 0);
        glTexCoord2f(0.0, 0.0);  glVertex2f(0, Height);
        glTexCoord2f(1.0, 0.0);  glVertex2f(Width, Height);
        glTexCoord2f(1.0, 1.0);  glVertex2f(Width, 0);
      glEnd();

      glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);

    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);

  glPopMatrix();
end;

  if @DrawProcedure<>nil then DrawProcedure;

end;

procedure DrawPost; stdcall;
begin
 glPushMatrix();

if Enabled then
 begin
  glViewport(0, 0, 512, 512);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity();

  RenderScene(GetScreenResX,GetScreenResY);

  glBindTexture(GL_TEXTURE_2D, blurTex);
  glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, 512, 512, 0);

  glViewport(0, 0, GetScreenResX, GetScreenResY);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
 end;

 glPopMatrix();

  if @BgDraw<>nil then BgDraw;
  RenderScene(GetScreenResX,GetScreenResY);

end;

procedure OnMessage(var Msg : tagMSG); stdcall;
begin
 if Msg.message=WM_KEYUP then
 begin

  if Msg.wParam=119{F8} then
  begin
  inc(Frames);
  if Frames >0 then Enabled:=true;
  if Frames = 21 then Frames :=20;
  end;

  if Msg.wParam=120{F9} then
  begin
  dec(Frames);
  if Frames = 0 then
  begin
  Enabled:=false;
  Frames :=1;
  end;
  end;

 end;
end;

exports
Init,
Free,
DrawPost,
OnMessage,

blur_RegisterDrawProcedure,
blur_Activate,
blur_Textures;

begin
BgDraw:=nil;
DrawProcedure:=nil;
end.
