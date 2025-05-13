program Launcher;

uses
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

var Floor, Blood : cardinal;

procedure EngineInit;
begin
 Floor:=LoadTextureFromFile('Back.jpg');
 Blood:=LoadTextureFromFile('Blood.bmp');
end;

procedure Draw;
begin
Begin2D;

 DrawTexture2D_Simple(Floor,0,0,800,600);

End2D;
end;

procedure Process;
begin

 if random(25)=12 then DrawTextureToTextureTransparentColor(Blood,Floor,random(512),random(512),TRANSCOLOR_AQUA);

 if IsKeyPressed(Key_Escape) then
 QuitEngine;

end;


begin

 if LoadDGLEngineDLL('..\..\..\System\DGLEngine.dll') then
 begin
  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@EngineInit);

  SetEngineInitParametrs(800,600,32,85,false,false,false);

  StartEngine;

  FreeDGLEngineDLL;
 end;

end.
