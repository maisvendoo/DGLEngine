library DGLE_Plugin;

uses
  Windows,
  Messages,
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R *.res}


procedure Init(DGLE_Handle : THandle; EngWinHandle : HWND; ProcessInterval : byte); stdcall;
begin
DGLEngineDLL_Handle:=DGLE_Handle;
InitDGLE_1_0;

Application.Initialize;
Application.CreateForm(TForm1, Form1);
  Application.Run;
end;


exports
Init;

begin
end.
