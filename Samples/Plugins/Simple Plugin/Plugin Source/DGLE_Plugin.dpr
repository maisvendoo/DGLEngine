library DGLE_Plugin;

uses
  Windows,
  Messages,
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R *.res}

var
 Tex : Cardinal;

procedure ChangeTexRes(Size : cardinal); stdcall;
begin
FreeTexture(Tex);
Tex:=CreateTextureToRenderIn(Size,Size);
end;

procedure Init(DGLE_Handle : THandle; EngWinHandle : HWND; ProcessInterval : byte); stdcall;
begin
DGLEngineDLL_Handle:=DGLE_Handle;
InitDGLE_1_0;

Tex:=CreateTextureToRenderIn(128,128);
end;

procedure Free; stdcall;
begin
FreeTexture(Tex);
end;

procedure DrawPre; stdcall;
begin
StartRenderToTexture(Tex);
end;

procedure DrawPost; stdcall;
begin
EndRenderToTexture;
Begin2D;
 DrawTexture2D_Simple(Tex,0,0,GetScreenResX,GetScreenResY);
End2D;
end;

exports
Init,
Free,
DrawPre,
DrawPost,
ChangeTexRes;

begin
end.
