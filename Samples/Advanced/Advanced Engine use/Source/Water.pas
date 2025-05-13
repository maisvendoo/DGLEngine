unit Water;

interface
uses OpenGL, DGLEngine_header;

procedure DrawWater;
procedure InitWater;
procedure CreateRainDrop;
procedure ProcessWater;

implementation
type TGLCoord = Record
       X, Y, Z : glFloat;
     end;

const GridSize = 63;

var
  RainInterval : Integer;
  Viscosity : glFloat;
  Position : Array[0..GridSize, 0..GridSize] of glFloat;
  Velocity : Array[0..GridSize, 0..GridSize] of glFloat;

  Vertex : Array[0..GridSize, 0..GridSize] of TglCoord;
  Normals:array [0..GridSize, 0..GridSize] of TglCoord;

procedure InitWater;
var I, J : Integer;
begin
 Viscosity :=0.96;
  For I :=0 to GridSize do
  begin
    For J :=0 to GridSize do
    begin
      Position[I, J] :=0;
      Velocity[I, J] :=0;
    end;
  end;
end;

procedure CreateRainDrop;
begin
  Velocity[random(GridSize-3)+2, random(GridSize-3)+2] :=1060;
end;

procedure ProcessWater;
var
 I, J : Integer;
    VectLength : glFloat;
begin
  For I :=2 to GridSize-2 do
    For J :=2 to GridSize-2 do
      Velocity[I, J] := Velocity[I, J] + (Position[I, J] -
              (4*(Position[I-1,J] + Position[I+1,J] + Position[I,J-1] + Position[I,J+1]) +
              Position[I-1,J-1] + Position[I+1,J-1] + Position[I-1,J+1] + Position[I+1,J+1])/25) / 7;

  For I:=2 to GridSize-2 do
    For J:=2 to GridSize-2 do
    Begin
      Position[I, J] := Position[I, J] - Velocity[I,J];
      Velocity[I, J] := Velocity[I, J] * Viscosity;
    End;

  For I :=0 to GridSize do
    For J :=0 to GridSize do
    begin
      Vertex[I, J].X :=(I - GridSize/2)/GridSize*5;
      Vertex[I, J].Y :=(Position[I, J] / 1024)/GridSize*3;
      Vertex[I, J].Z :=(J - GridSize/2)/GridSize*5;
    end;

  For I :=0 to GridSize do
  begin
    For J :=0 to GridSize do
    begin
      If (I > 0) and (J > 0) and (I < GridSize) and (J < GridSize) then
      begin
        with Normals[I, J] do
        begin
          X := Position[I+1, J] - Position[I-1,J];
          Y := -2048;
          Z := Position[I, J+1] - Position[I, J-1];

          VectLength :=sqrt(x*x + y*y + z*z);
          if VectLength <> 0 then
          begin
            X :=X/VectLength;
            Y :=Y/VectLength;
            Z :=Z/VectLength;
          end;
        end;
      end
      else
      begin
        Normals[I, J].X :=0;
        Normals[I, J].Y :=1;
        Normals[I, J].Z :=0;
      end;
    end;
  end;
end;

procedure DrawWater;
var I, J : Integer;
begin
  For J :=0 to GridSize-1 do
  begin
    glBegin(GL_QUAD_STRIP);
      for I :=0 to GridSize do
      begin
        glNormal3fv(@Normals[I, J+1]);
        glVertex3fv(@Vertex[I, J+1]);
        glNormal3fv(@Normals[I, J]);
        glVertex3fv(@Vertex[I, J]);
      end;
    glEnd;
  end;
end;


end.
