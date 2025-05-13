program Launcher;

uses
  Classes, SysUtils, Windows,
  DGLEngine_header in '..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

{
Не пугайтесь, что кода много :) На самом деле заюзать бампаминг на моделе черезвычайно просто,
я захламил код дебаговыми отрисовками и демонстрацией 2-х моделей и 2-х типов освещения,
сам же бампмапинг занимает 10 строк кода :)
}
const
ShowNormals    = TRUE;
ShowTangent    = TRUE;
ShowBiTangent  = TRUE;

var
ShowDebug  : boolean = false;
Plane  : boolean = false;
VertLighting : boolean = false;
Texture, NormalMap, SpecularMap,
mdl_Tor,mdl_Plane,
PixelShader, VertexShader : cardinal;
Angle : single = 0.0;

LightPos : TVertex;

mesh_geometry_tor, mesh_geometry_plane: TMeshGeometry;

function v_add_anddiv(v1, v2 : TVertex; n : single) : Tvertex; inline;
begin
  result.X:=v1.X+v2.X/n;
  result.Y:=v1.Y+v2.Y/n;
  result.Z:=v1.Z+v2.Z/n;
end;

function vertex(x,y,z : single) : TVertex; inline;
begin
result.X:=x;
result.Y:=y;
result.Z:=z;
end;

procedure DrawDebugVectors; //Ф-я дебага выводит направление расчитанных нормалей, тангент и битангент
var i : integer; TempV : TVertex; m : TMeshGeometry;
begin
if Plane then m := mesh_geometry_plane else m:=mesh_geometry_tor;
for i:=0 to m.VerticesCount-1 do
with m do begin

 BeginObj3D;
 SetTexture(0);

    if ShowTangent then
     begin
     Color3D($00FF00);
     TempV := v_add_anddiv(Vertices[i],vertex(Tangents[i].tangent.X,Tangents[i].tangent.Y,Tangents[i].tangent.Z),5);
     DrawLine(Vertices[i].X,Vertices[i].Y,Vertices[i].Z,TempV.X,TempV.Y,TempV.Z,1,false);
     end;

    if ShowBiTangent then
     begin
     Color3D($0000FF);
     TempV := v_add_anddiv(Vertices[i], Tangents[i].bitangent,3);
     DrawLine(Vertices[i].X,Vertices[i].Y,Vertices[i].Z,TempV.X,TempV.Y,TempV.Z,1,false);
     end;

    if ShowNormals then
     begin
     Color3D($FF0000);
     TempV := v_add_anddiv(Vertices[i],Normals[i],5);
     DrawLine(Vertices[i].X,Vertices[i].Y,Vertices[i].Z,TempV.X,TempV.Y,TempV.Z,1,false);
     end;

 EndObj3D;

end;
end;

procedure EngineInit;
var
S : TStringList;
begin

  if not IsVShadersSupported or not IsPShadersSupported then //Если нет шейдеров, то никакого бампмаппа мы не увидим увы
  begin
    MessageBox(0,PChar('No Shaders - No Love!'+#13+'Shader Model 2.0 requerd.'),'Attention', MB_OK or MB_ICONINFORMATION);
    VertLighting:=true;
  end;

 s:=TStringList.Create;

 s.LoadFromFile('Data\bump_pixel_shader.txt');
 PixelShader:=LoadShader(FRAGMENT_PROGRAM,s.Text);

 s.LoadFromFile('Data\bump_vertex_shader.txt');
 VertexShader:=LoadShader(VERTEX_PROGRAM,s.Text);

 s.Free;

 mdl_Plane:=LoadModel('Data\Plane.dmd',MDL_NO_SCALE);
 mdl_Tor:=LoadModel('Data\Torus.dmd',MDL_NO_SCALE);//Модель лучше масштабировать и центрировать заранее при экспорте

 GetModelGeometry(mdl_Tor,0,@mesh_geometry_tor);//Вот так можно получить информацию о геометрии модели
 GetModelGeometry(mdl_Plane,0,@mesh_geometry_Plane);

 TextureMipMapping(true);
 Texture:=LoadTextureFromFile('Data\'+ModelMaterial(mdl_Tor).TexFileName);
 NormalMap:=LoadTextureFromFile('Data\'+ModelMaterial(mdl_Tor).NormalMapFileName);
 SpecularMap:=LoadTextureFromFile('Data\'+ModelMaterial(mdl_Tor).SpecularMapFileName);

 CullFace(CULL_BACK);

end;

procedure Draw;
begin

if not PLANE then
begin
Position3D(0.0,0.0,-2.5);
RotateX(sin(Angle/150)*30);
RotateY(cos(Angle/150)*30);
end else
begin
Position3D(0.0,0.0,-60);
RotateX(25+sin(Angle/100)*30);
end;

if not VertLighting then
begin
SetShader(VertexShader);
GiveShaderParams(VertexShader,0,vertex(LightPos.X,LightPos.Y,LightPos.Z),0);
//Что бы правильно считать блики надо передавать положение камеры
//Ее можно либо расчитать, либо прикинуть "на глазок" как я :)
if not PLANE then
GiveShaderParams(VertexShader,1,vertex(1,1,2.5),0)
else
GiveShaderParams(VertexShader,1,vertex(1,10,60),0);

SetShader(PixelShader);
// ambient (4-й параметр степень затенения, первые три - игнорируются)
GiveShaderParams(PixelShader,0,vertex(0,0,0),0.2);


ActivateMultitexturingLayer(MTEX_LAYER0);
SetTexture(Texture);
ActivateMultitexturingLayer(MTEX_LAYER1);
SetTexture(NormalMap);
ActivateMultitexturingLayer(MTEX_LAYER2);
SetTexture(SpecularMap);
ActivateMultitexturingLayer(MTEX_LAYER0);

ModelsBump(true);//Сообщаем движку что дальше все модели надо выводить с 4 текстурными координатами на вершину используя расчитанные тангенгты и битангенты

end else
begin
SetLight(LIGHT0,LightPos.X,LightPos.Y,LightPos.Z);
SetTexture(Texture);
end;

if not PLANE then
begin
RotateX(45);
DrawModel(mdl_tor);
end else
DrawModel(mdl_plane);

ModelsBump(false);//Отключаем режим бампмапинга

if not VertLighting then
begin
SetShader(NULL_PROGRAMS);
ActivateMultitexturingLayer(MTEX_LAYER0);
SetTexture(TEX_BLANK);
ActivateMultitexturingLayer(MTEX_LAYER1);
SetTexture(TEX_BLANK);
ActivateMultitexturingLayer(MTEX_LAYER2);
SetTexture(TEX_BLANK);
ActivateMultitexturingLayer(MTEX_LAYER0);
end else
begin
DeactiveLight();
SetTexture(0);
end;


if ShowDebug then
begin
  DrawDebugVectors;
  DrawAxes(0.2);
end;
BeginObj3D;
Position3D(LightPos.X,LightPos.Y,LightPos.Z);
if not PLANE then
DrawSphere(0.025)
else
DrawSphere(1);

EndObj3D;

end;

procedure Process;
begin

  ApplicationName(PChar('FPS: ['+IntToStr(getfps)+'] F1/F2 - вкл./выкл.отрисовку тангент и нормалей; F3/F4 - плоскость/тор; F5/F6 - vertex/per-pixel lighting'));

  if not PLANE then
  LightPos:=vertex(cos(Angle/10)*0.7+0.7,0,sin(Angle/10))
  else
  LightPos:=vertex(cos(Angle/10)*15,sin(Angle/10)*15,6);

 Angle:=Angle+0.2;

 if IsKeyPressed(Key_F1) then ShowDebug:=true;
 if IsKeyPressed(Key_F2) then ShowDebug:=false;

 if IsKeyPressed(Key_F3) then Plane:=true;
 if IsKeyPressed(Key_F4) then Plane:=false;

 if IsKeyPressed(Key_F5) then VertLighting:=true;
 if IsKeyPressed(Key_F6) then VertLighting:=false;

 if IsKeyPressed(Key_Escape) then
 QuitEngine;

end;


begin
 if LoadDGLEngineDLL('..\..\System\DGLEngine.dll') then
 begin
  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@EngineInit);

  SetEngineInitParametrs(800,600,32,85,false,false,false);

  StartEngine;

  FreeDGLEngineDLL;
 end;

end.
