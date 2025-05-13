program Launcher;

uses
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

var Font : cardinal;

procedure EngineInit;
begin
 Font:=LoadFontFromFile('Font.dft');
end;

procedure Draw;
begin
Begin2D;

DrawText2D(Font,400-GetTextWidth(Font,'Hello WORLD!') div 2,300 - 20 div 2,'Hello WORLD!');

End2D;
end;

procedure Process;
begin

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
