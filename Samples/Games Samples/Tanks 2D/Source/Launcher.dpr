program Launcher;

uses
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas',
  Game in 'Game.pas',
  GameUtils in 'GameUtils.pas',
  GameTypes in 'GameTypes.pas',
  Lightning in 'Lightning.pas',
  Windows,
  MenuButtons in 'MenuButtons.pas';

{$R Ico.res}

procedure EngineInit;
begin
 Font:=LoadFontFromFile('Areal_20.dft');

 CreateConsole(Font,0.7);

 RegisterCommandProcedure('quit',@QuitEngine);

 RegisterCommandValue('drawfps',@DrawFps,1,0);
 RegisterCommandValue('lightning',@Light,1,0);
 RegisterCommandValue('pause',@pause,1,0);
 RegisterCommandValue('realistic',@realistic,1,0);

 DirectSoundInit;

 RocketSound:=LoadSample('sounds.dpc',true,'rocket.wav');
 ExploSound:=LoadSample('sounds.dpc',true,'expl.wav');
 FightSound:=LoadSample('sounds.dpc',true,'fight.wav');

 ExtractFromPackage('Sounds.dpc','music.mid','music.mid');

 PlayMusic('Music.mid');

 StartScene(gsMenu);
end;

procedure Draw;
begin
Begin2D;

 case FScene of
  gsMenu:DrawSceneMenu;
  gsGame:DrawSceneGame;
 end;

if DrawFPS=1 then DrawText2D(Font,GetScreenResX-GetTextWidth(Font,'FPS:'+inttostr(GetFPS),0.7)-10,0,'FPS:'+inttostr(GetFPS),$FFFFFF,255,0.7);

DrawConsole;

End2D;
end;

procedure Process;
begin
ProcessConsole;

 if (IsKeyPressed(Key_Escape)) and (FScene<>gsMenu) then StartScene(gsMenu);

  case FScene of
  gsMenu:ProcessSceneMenu;
  gsGame: if pause<>1 then ProcessSceneGame;
  end;

  if FNextScene<>gsNone then
  begin
  StartScene(FNextScene);
  FNextScene := gsNone;
  end;

end;


begin

 if LoadDGLEngineDLL('..\..\..\System\DGLEngine.dll') then
 begin
  ApplicationName('Tanchiks V 1.0');

  AddToLogFile('Log.txt','Game started',true,true,true);

  SetGameProcessInterval(33);

  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@EngineInit);

  SetEngineInitParametrs(800,600,32,0,true,false,false);

  StartEngine;


  DeleteFile('Music.mid');

  AddToLogFile('Log.txt','Game quit',false,true,false);

  FreeDGLEngineDLL('Launcher.exe');

 end;

end.
