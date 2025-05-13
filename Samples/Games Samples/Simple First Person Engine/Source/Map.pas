unit Map;

interface
Uses DGLEngine_Header, SystemUtils;

var
    Wall1,Wall2,Floor,Ceil,Barrel : Cardinal; //“екстуры карты
    PlayerRespawnX,PlayerRespawnY,PlayerX,PlayerY,
    PlayerAngleY,PlayerAngleX : single;

procedure LoadMap (MapFile : string);
procedure DrawMap;
function  CollidePlayerWithMap(X,Y : single) : boolean;

implementation

const
     // ол-во текстур стен, следующа€ по номеру, в данном случае 3 - считаетс€ текстурой пола
     WallTypesCount = 2;
     BlockSideWidth = 0.25; //–азмер стороны блока карты
     PlayerSideWidth = 0.35; //–азмер стороны квадрата дл€ обсчета столкновений с игроком

var MapArray, Objects : array of array of integer;
    MapWidth, MapHeight : integer;

procedure LoadMap (MapFile : string);
var i, j : integer; s : char;
begin
PlayerX:=0;
PlayerY:=0;
PlayerAngleY:=0;
PlayerAngleX:=0;

MapWidth:=strtoint(ReadValueFromIniFile(MapFile,'Header','Width'));
MapHeight:=strtoint(ReadValueFromIniFile(MapFile,'Header','Height'));

AddToLogFile(ENGINE_LOGFILE,'Loading map "'+MapFile +'" '+ inttostr(MapWidth)+'*'+inttostr(MapHeight));

SetLength(MapArray,MapWidth,MapHeight);
SetLength(Objects,MapWidth,MapHeight);

 for i:=0 to MapWidth - 1 do
  for j:=0 to MapHeight -1  do
  Objects[i,j]:=0;

 for i:=0 to MapWidth - 1 do
  for j:=0 to MapHeight -1  do
  begin
  s:=lowercase(ReadValueFromIniFile(MapFile,'Map Data',inttostr(j)))[i+1];
   case s of

   'b': begin
        Objects[i,j]:=1;
        s:=inttostr(WallTypesCount+1)[1];
        end;
   'p': begin
        PlayerRespawnX:=i;
        PlayerRespawnY:=j;
        s:=inttostr(WallTypesCount+1)[1];
        end;

   end;
  MapArray[i,j]:=strtoint(s);
  end;

end;

function CollidePlayerWithMap(X,Y : single) : boolean;
 function CollidePlayerWithBlock(i,j : integer):boolean;
  begin
   if(-PlayerSideWidth < i+BlockSideWidth) and
     (PlayerSideWidth> i-BlockSideWidth) and
     (-PlayerSideWidth < j+BlockSideWidth) and
     (PlayerSideWidth > j-BlockSideWidth) or
     (i-BlockSideWidth < PlayerSideWidth) and
     (i+BlockSideWidth > -PlayerSideWidth) and
     (j-BlockSideWidth < PlayerSideWidth) and
     (j+BlockSideWidth > -PlayerSideWidth) then
     Result := true else
     result:=false;
    end;
var i,j : integer;
begin
result:=false;
 for i:=0 to MapWidth - 1 do
  for j:=0 to MapHeight -1  do
   if ((MapArray[i,j]<>0) and (MapArray[i,j]<=WallTypesCount)) or (Objects[i,j]<>0) then
    if CollidePlayerWithBlock(round(i-PlayerRespawnX+X),round(j-PlayerRespawnY+Y)) then
    begin
    result:=true;
    Exit;
    end;
end;

procedure DrawMap;
var i,j : integer;
begin

 for i:=0 to MapWidth - 1 do
  for j:=0 to MapHeight -1  do
  if MapArray[i,j]<>0 then
   begin
   BeginObj3D;

   if (PlayerAngleX>-90) and  (PlayerAngleX<90) then
   RotateX(PlayerAngleX);

   RotateY(PlayerAngleY);

   Position3D(i-PlayerRespawnX+PlayerX,0,j-PlayerRespawnY+PlayerY);

   case MapArray[i,j] of
   WallTypesCount +1 - WallTypesCount     : SetTexture(Wall1);
   WallTypesCount +1 - WallTypesCount + 1 : SetTexture(Wall2);
   WallTypesCount+1                       : SetTexture(Floor);
   end;

   if MapArray[i,j]>WallTypesCount then
   begin
   //–исуем пол
   Position3D(0,-1,0);
   RotateX(90);
   DrawPlane(1,1);
   //–исуем потолок
   Position3D(0,0,2);
   SetTexture(Ceil);
   DrawPlane(1,1);
   end else
   //“ут можно сильно ускорить работу движка если рисовать не параллелепипеды,
   //а посто плоскости в зависимости от того как этот блок граничит со стенами
   //“ак же можно ускорить за счет FrustumCulling т.е. рисовать только те блоки, что попадают в камеру
   DrawCube(0.5,1,0.5);

   EndObj3D;
   end;

 for i:=0 to MapWidth - 1 do
  for j:=0 to MapHeight -1  do
   if Objects[i,j]<> 0 then
   begin
    BeginObj3D;
    if (PlayerAngleX>-90) and  (PlayerAngleX<90) then
    RotateX(PlayerAngleX);
    RotateY(PlayerAngleY);
    Position3D(i-PlayerRespawnX+PlayerX,-0.63,j-PlayerRespawnY+PlayerY);

    case Objects[i,j] of
    1: SetTexture(Barrel);
    end;

    Color3D($FFFFFF,254);
    DrawSprite_BillBoard(0.75,0.75,1,1,1);

    EndObj3D;
   end;

end;

end.
