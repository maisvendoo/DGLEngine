program Launcher;

uses
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

var
    Angle : single = 0.0;
    Tree,Rocks,Ape : integer;
    ApeFrame : single =0;
    dec : boolean = false;
    TreeTex, RockTex : cardinal;

procedure Init;
begin
Ape:=LoadModel('Ape.dmd');
Tree:=LoadModel('Tree.dmd');
Rocks:=LoadModel('Rocks.dmd');
TreeTex:=LoadTextureFromFile('Texture.bmp');
RockTex:=LoadTextureFromFile('Ground.jpg');
end;

procedure Process;
begin

if not dec then
 ApeFrame:=ApeFrame+0.25 else
  ApeFrame:=ApeFrame-0.25;

 if Round(ApeFrame)=76 then dec:=true;
 if Round(ApeFrame)=57 then dec:=false;

 Angle:=Angle+0.2;

 if IsKeyPressed(Key_Escape) then QuitEngine;

end;

procedure Draw;
begin
 Position3D(0,0,-6);
 RotateX(-10-10*sin(Angle/20));
 RotateY(-150-15*sin(Angle/20));

BeginObj3D;
 Position3D(0,0,-1);
 RotateX(90);
 SetTexture(TreeTex);
 DrawModel(Tree,0,true);
EndObj3D;

BeginObj3D;
 SetLight(LIGHT0,-2,0,-2);
 Color3D($003162);
 Position3D(-1,-0.95,-2);
 RotateX(90);
 RotateZ(180);
 DrawModel(Ape,round(ApeFrame),true);
 DeactiveLight();
EndObj3D;

BeginObj3D;
 RotateX(90);
 Scale3D(15);
 Position3D(-0.1,0.0,-0.065);
 SetTexture(RockTex);
 DrawModel(Rocks,0,true);
EndObj3D;

end;

begin

 if LoadDGLEngineDLL('..\..\..\System\DGLEngine.dll') then
 begin
  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@Init);

  SetEngineInitParametrs(800,600,32,85,false,false,false);

  StartEngine;

  FreeDGLEngineDLL;
 end;

end.
