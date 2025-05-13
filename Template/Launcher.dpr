program Launcher;

uses
  DGLEngine_header in 'DGLEngine_header.pas';

{$R Ico.res}

procedure EngineFree;
begin
//
end;

procedure EngineInit;
begin
//
end;

procedure Draw;
begin
//
end;

procedure Process;
begin
//
end;


begin

 if LoadDGLEngineDLL('DGLEngine.dll') then
 begin

  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@EngineInit);
  RegProcedure(PROC_FREE,@EngineFree);

  SetEngineInitParametrs(800,600,32,85,false,false,false);

  StartEngine;

  FreeDGLEngineDLL('Launcher.exe');

 end;

end.
