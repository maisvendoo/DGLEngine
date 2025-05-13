unit Game;

interface
uses DGLEngine_header, GameUtils, Math, MenuButtons;

type
  TGameScene=(gsNone,gsMenu,gsGame);

var
    FScene: TGameScene;
    FNextScene: TGameScene;


    procedure StartScene(Scene: TGameScene);
    procedure EndScene;
    procedure StartSceneMenu;
    procedure ProcessSceneMenu;
    procedure DrawSceneMenu;
    procedure EndSceneMenu;
    procedure StartSceneGame;
    procedure ProcessSceneGame;
    procedure DrawSceneGame;
    procedure EndSceneGame;

var
TankLogo, TankBig, Korpus,Pricel, Pushka, Font, Explosion, Cursor, bg, bullet, texrock, Texturelight : Cardinal;
DrawFPS : integer = 0; //Вывдить ли FPS 0 - нет 1 - да
Frags,FragsE : integer;
Pause : integer = 0;
ExploSound, RocketSound, FightSound : integer;

Start, Quit : TGLTextButton;

implementation
uses GameTypes, Lightning;

procedure EndScene;
begin
 case FScene of
 gsMenu    : EndSceneMenu;
 gsGame    : EndSceneGame;
 end;
end;

procedure StartScene(Scene: TGameScene);
begin
EndScene;
FScene := Scene;
 case FScene of
 gsMenu    : StartSceneMenu;
 gsGame    : StartSceneGame;
 end;
end;

procedure StartSceneMenu;
 procedure StartGm;
 begin
 StartScene(gsGame)
 end;
begin

 TankLogo:=LoadTextureFromPackage('Textures.dpc','TLogo.bmp',TEXDETAIL_BEST,TRANSCOLOR_GRAY);
 Cursor:=LoadTextureFromPackage('Textures.dpc','Cursor.bmp',TEXDETAIL_BEST,TRANSCOLOR_GRAY);
 TankBig:=LoadTextureFromPackage('Textures.dpc','TankBig.bmp',TEXDETAIL_BEST,TRANSCOLOR_GRAY);
 Texturelight:=LoadTextureFromPackage('Textures.dpc','light.jpg');

 AddToLogFile('Log.txt','Textures for menu loaded!');

 Start:=TGLTextButton.Create;
 Start.Font:=Font;
 Start.Tex:=Texturelight;
 Start.Text:='Start BOT Match';
 Start.X:=(GetScreenResX - GetTextWidth(Font,Start.Text)) div 2;
 Start.Y:= 450;
 @Start.proc:=@StartGm;

 Quit:=TGLTextButton.Create;
 Quit.Font:=Font;
 Quit.Tex:=Texturelight;
 Quit.Text:='Quit';
 Quit.X:=(GetScreenResX - GetTextWidth(Font,Quit.Text)) div 2;
 Quit.Y:= 510;
 @Quit.proc:=@QuitEngine;

end;

procedure StartSceneGame;
var i : integer;
begin
 Texturelight:=LoadTextureFromPackage('Textures.dpc','light.jpg');
 Korpus:=LoadTextureFromPackage('Textures.dpc','Korpus.bmp',TEXDETAIL_BEST,TRANSCOLOR_GRAY);
 Pushka:=LoadTextureFromPackage('Textures.dpc','Pushka.bmp',TEXDETAIL_BEST,TRANSCOLOR_GRAY);
 Explosion:=LoadTextureFromPackage('Textures.dpc','Explo.bmp');
 bg:=LoadTextureFromPackage('Textures.dpc','Grass.jpg');
 bullet:=LoadTextureFromPackage('Textures.dpc','Bullet.bmp',TEXDETAIL_BEST,TRANSCOLOR_GRAY);
 texrock:=LoadTextureFromPackage('Textures.dpc','Rock.bmp',TEXDETAIL_BEST,TRANSCOLOR_GRAY);
 pricel:=LoadTextureFromPackage('Textures.dpc','pricel.bmp',TEXDETAIL_BEST,TRANSCOLOR_GRAY);

 AddToLogFile('Log.txt','Textures for game loaded!');

 Frags:=0;
 FragsE:=0;

SetPlayer;
SetEnemy;

 Rocks[0].Collision.X:=140;
 Rocks[0].Collision.Y:=90;
 Rocks[0].Collision.Radius:=25;

 Rocks[1].Collision.X:=400;
 Rocks[1].Collision.Y:=490;
 Rocks[1].Collision.Radius:=25;

 Rocks[2].Collision.X:=600;
 Rocks[2].Collision.Y:=200;
 Rocks[2].Collision.Radius:=25;

 Rocks[3].Collision.X:=200;
 Rocks[3].Collision.Y:=340;
 Rocks[3].Collision.Radius:=25;

 for i:=0 to 1 do
 Deads[i].Active:=false;

 for i:=0 to 20 do
 Bullets[i].Active:=false;

 for i:=0 to 10 do
 Explos[i].Active:=false;

 PlaySample(FightSound);
end;

procedure EndSceneMenu;
begin
 FreeTexture(TankLogo);
 FreeTexture(Cursor);
 FreeTexture(TankBig);
 FreeTexture(texturelight);

Start.Free;
Quit.Free;
end;

procedure EndSceneGame;
begin
 FreeTexture(Korpus);
 FreeTexture(Pushka);
 FreeTexture(Explosion);
 FreeTexture(bg);
 FreeTexture(bullet);
 FreeTexture(texrock);
 FreeTexture(texturelight);
 FreeTexture(pricel);
end;

procedure ProcessSceneMenu;
begin

Start.Process;
Quit.Process;

end;

procedure DrawSceneMenu;
var Color : integer;
begin

DrawText2D(Font,400-GetTextWidth(Font,'Танчики',2) div 2,100,'Танчики',$008000,160,2);
DrawTexture2D_Simple(TankLogo,400-GetTextWidth(Font,'Танчики',2) div 2 - 75 ,90,128,64);
DrawTexture2D_Simple(TankLogo,400+GetTextWidth(Font,'Танчики',2) div 2 -5 ,90,128,64);

DrawTexture2D_Simple(TankBig,400-469 div 2,300-308 div 2,512,512);

Start.Draw;
Quit.Draw;

DrawTexture2D_Simple(Cursor,GetMousePos.X,GetMousePos.Y,64,64);
end;

procedure FillBgr;
begin
DrawTexture2D_Simple(Bg,0,0,400,300);
DrawTexture2D_Simple(Bg,400,0,400,300);
DrawTexture2D_Simple(Bg,0,300,400,300);
DrawTexture2D_Simple(Bg,400,300,400,300);
end;

procedure PlayerControls;
begin
Tanks[0].TurellAngle:=trunc(RadToDeg(ArcTan2(GetMousePos.Y-(Tanks[0].Y+64), GetMousePos.X-(Tanks[0].X+32))))+90;

if (GetMouseButtonPressed=MB_LEFT) and (Tanks[0].ShootWait>20+40*Realistic) then
begin
Tanks[0].ShootWait:=0;
CreaTeBullet(0);
end;

if IsKeyPressed(Key_D) then Tanks[0].Angle:=Tanks[0].Angle+5;

if IsKeyPressed(Key_A) then Tanks[0].Angle:=Tanks[0].Angle-5;

Tanks[0].OldX:=Tanks[0].X;
Tanks[0].OldY:=Tanks[0].Y;

Tanks[0].X:=Tanks[0].X+Trunc( cos256(Tanks[0].Angle*256 div 360 + 64)*Tanks[0].PlayerV );
Tanks[0].Y:=Tanks[0].Y+Trunc( sin256(Tanks[0].Angle*256 div 360 + 64)*Tanks[0].PlayerV );

if IsKeyPressed(Key_W) then
begin
Tanks[0].PlayerV:=Tanks[0].PlayerV-0.3;
if Tanks[0].PlayerV<-8 then Tanks[0].PlayerV:=-8;
Tanks[0].X:=Tanks[0].X+Trunc( cos256(Tanks[0].Angle*256 div 360 + 64)*-5 );
Tanks[0].Y:=Tanks[0].Y+Trunc( sin256(Tanks[0].Angle*256 div 360 + 64)*-5 );
Exit;
end;

if IsKeyPressed(Key_S) then
begin
Tanks[0].PlayerV:=Tanks[0].PlayerV+0.15;
if Tanks[0].PlayerV>8 then Tanks[0].PlayerV:=8;
Tanks[0].X:=Tanks[0].X+Trunc( cos256(Tanks[0].Angle*256 div 360 + 64)*3 );
Tanks[0].Y:=Tanks[0].Y+Trunc( sin256(Tanks[0].Angle*256 div 360 + 64)*3 );
Exit;
end;

if Tanks[0].PlayerV>0 then
Tanks[0].PlayerV:=Tanks[0].PlayerV-0.3 else
Tanks[0].PlayerV:=Tanks[0].PlayerV+0.3;

end;

procedure ProcessSceneGame;
begin
ResetVertexses;
if Tanks[0].Lifes>0 then PlayerControls;
if Tanks[1].Lifes>0 then MoveEnemy;
DoMoveDead;
MoveTank;
MoveBullets;
MoveExplos;
end;

procedure DrawSceneGame;
begin
FillBgr;
DrawRock;
DoDrawDead;
DrawTank;
DrawBullets;
DrawExplos;
DrawVertex;

DrawText2D(Font,0,0,'Твои фраги:'+inttostr(Frags)+' Его фраги:'+inttostr(FragsE),$0000FF,159,0.7);

DrawTexture2D_Simple(Pricel,GetMousePos.X-8,GetMousePos.Y-8,16,16);
end;


end.
