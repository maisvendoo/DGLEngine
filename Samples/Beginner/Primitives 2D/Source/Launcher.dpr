program Launcher;

uses
  Windows,
  DGLEngine_header in '..\..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

function Point(X,Y : integer) : Tpoint;
begin
 result.x:=X;
 result.Y:=Y;
end;

function ColorVertex(X,Y,Color : integer) : TColorVertex2D;
begin
 result.X:=X;
 result.Y:=Y;
 result.Color:=Color;
 result.Alpha:=180;
end;

procedure Draw;
begin
Begin2D;

 DrawLine2D(20,40,400,70,$FFFFFF,255,0.5,false);
 DrawLine2D(20,55,400,85,$808080,255,5,true);
 DrawColorLine2D(20,70,400,100,$FF0000,$0000FF);

 DrawRectangle2D(100,150,200,200,$00FF00);
 DrawRectangle2D_Fill_VertexColor(110,160,180,180,$080808,$FFFF00,$00FF00,$FFFFFF,255,255,255,255);

 DrawCircle2D(550,200,100,$FFFFFF);
 DrawCircle2D_Fill(550,200,80,$00FF00,120);

 DrawEllipse2D(point(550,200),200,100,32,$FF0000);
 DrawEllipse2D_Fill(point(550,200),100,200,$0000FF,100);

 DrawPolygon2D([point(250,50),point(375,500),point(200,560),point(125,500)],$FF0000,150);

 DrawPolygon2D_VertexColor([ColorVertex(550,50,$FF0000),ColorVertex(675,500,$00FF00),ColorVertex(425,500,$0000FF)]);

End2D;
end;

begin

 if LoadDGLEngineDLL('..\..\..\System\DGLEngine.dll') then
 begin
  RegProcedure(PROC_DRAW,@Draw);

  SetEngineInitParametrs(800,600,32,85,false,false,false);

  StartEngine;

  FreeDGLEngineDLL;
 end;

end.
