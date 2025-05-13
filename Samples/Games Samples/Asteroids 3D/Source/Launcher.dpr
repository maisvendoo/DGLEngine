program Launcher;

uses
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas',
  GameUtils in '..\..\Tanks 2D\Source\GameUtils.pas',
  GameObjects in 'GameObjects.pas';

{$R Ico.res}

var
    Font, Earth, Space, Clouds : cardinal;

    FPS : string;

    EarthAngle : single = 0;

procedure Draw;
begin

Begin2D;
 DrawTexture2D_Simple(Space,0,0,800,600);
End2D;

BeginObj3D;
 SetLight();
 Position3D(0.0,0.0,-5.1);
 RotateY(-EarthAngle);

 SetTexture(Earth);

 DrawSphere(1);

 Color3D($FFFFFF,100);

 RotateY(EarthAngle*1.5);
 RotateX(-EarthAngle/1.5);
 RotateZ(EarthAngle/1.5);

 SetTexture(Clouds);

 DrawSphere(1.03);
 DeactiveLight();
EndObj3D;

AdductingMatrix3Dto2D;

  DrawShip;
  DrawAsteroids;

ReturnStandartMatrix3D;

Begin2D;

 DrawBlaster;
 DrawExplo;

 DrawText2D(Font,0,0,FPS);

 DrawConsole;

End2D;

end;

procedure EngineInit;
begin

Font:=LoadFontFromFile('Data\Font_Lucida12.dft');
ShipTex:=LoadTextureFromFile('Data\Textures\Ship.bmp');
Earth:=LoadTextureFromFile('Data\Textures\Earth.jpg');
Space:=LoadTextureFromFile('Data\Textures\Space.bmp');
Clouds:=LoadTextureFromFile('Data\Textures\Clouds.jpg');
Specular:=LoadTextureFromFile('Data\Textures\Reflection.bmp');
AsterTex:=LoadTextureFromFile('Data\Textures\Asteroid.bmp');
BlasterTex:=LoadTextureFromFile('Data\Textures\Shot.bmp');
ExplTex:=LoadTextureFromFile('Data\Textures\Aexplode.jpg');

DirectSoundInit;

ExploSound:=LoadSample('Data\Sounds\medium_explosion.wav');
ShotSound:=LoadSample('Data\Sounds\fire_missile.wav');
BreakSound:=LoadSample('Data\Sounds\asteroid_breakup.wav');


ShipModel:=LoadModel('Data\Models\Ship.dmd');
Asteroid:=LoadModel('Data\Models\Asteroid.dmd');

CreateConsole(Font,0.7);

RegisterCommandProcedure('quit',@QuitEngine);

SetShips;

CreateAsteroids(100,100,0.7);
end;


procedure Process;
begin
if IsKeyPressed(Key_Escape) then QuitEngine;
ProcessConsole;

FPS:='FPS: '+inttostr(GetFPS);

EarthAngle:=EarthAngle+0.3;

ProcessControls;
ProcessAsteroids;
ProcessShips;
ProcessBlaster;
ProcessExplo;

end;


begin
 randomize;

 if LoadDGLEngineDLL('..\..\..\System\DGLEngine.dll') then
 begin
  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@EngineInit);

  SetEngineInitParametrs(800,600,32,0,true,false,false);

  StartEngine;

  FreeDGLEngineDLL('Launcher.exe');
 end;

end.
