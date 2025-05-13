{=======================================================}
{       TFrustumClass.pas                               }
{=======================================================}
{                                                       }
{       2002 by Sascha Willems                          }
{       visit http://www.delphigl.de                    }
{                                                       }
{=======================================================}
unit TFrustumClass;

interface

uses
 SysUtils,
 OpenGL;

type
 TFrustum = object
   Frustum : array[0..5,0..3] of Single;
   function IsPointWithin(const pX, pY, pZ : Single) : Boolean;
   function IsSphereWithin(const pX, pY, pZ, pRadius : Single) : Boolean;
   function IsBoxWithin(const pX, pY, pZ, pB, pH, pT : Single) : Boolean;
   procedure Calculate;
  end;

const
 Right  = 0;
 Left   = 1;
 Bottom = 2;
 Top    = 3;
 Back   = 4;
 Front  = 5;
 A      = 0;
 B      = 1;
 C      = 2;
 D      = 3;

var
 Frustum : TFrustum;

implementation

procedure NormalizePlane(var pFrustum : TFrustum;pPlane : Integer);
var
 Magnitude : Single;
begin
Magnitude := Sqrt(Sqr(pFrustum.Frustum[pPlane][A])+Sqr(pFrustum.Frustum[pPlane][B])+Sqr(pFrustum.Frustum[pPlane][C]));
pFrustum.Frustum[pPlane][A] := pFrustum.Frustum[pPlane][A]/Magnitude;
pFrustum.Frustum[pPlane][B] := pFrustum.Frustum[pPlane][B]/Magnitude;
pFrustum.Frustum[pPlane][C] := pFrustum.Frustum[pPlane][C]/Magnitude;
pFrustum.Frustum[pPlane][D] := pFrustum.Frustum[pPlane][D]/Magnitude;
end;

procedure TFrustum.Calculate;
var
 ProjM, ModM, Clip : array[0..15] of Single;
begin
glGetFloatv(GL_PROJECTION_MATRIX, @ProjM);
glGetFloatv(GL_MODELVIEW_MATRIX, @ModM);
Clip[ 0] := ModM[ 0]*ProjM[ 0] + ModM[ 1]*ProjM[ 4] + ModM[ 2]*ProjM[ 8] + ModM[ 3]*ProjM[12];
Clip[ 1] := ModM[ 0]*ProjM[ 1] + ModM[ 1]*ProjM[ 5] + ModM[ 2]*ProjM[ 9] + ModM[ 3]*ProjM[13];
Clip[ 2] := ModM[ 0]*ProjM[ 2] + ModM[ 1]*ProjM[ 6] + ModM[ 2]*ProjM[10] + ModM[ 3]*ProjM[14];
Clip[ 3] := ModM[ 0]*ProjM[ 3] + ModM[ 1]*ProjM[ 7] + ModM[ 2]*ProjM[11] + ModM[ 3]*ProjM[15];
Clip[ 4] := ModM[ 4]*ProjM[ 0] + ModM[ 5]*ProjM[ 4] + ModM[ 6]*ProjM[ 8] + ModM[ 7]*ProjM[12];
Clip[ 5] := ModM[ 4]*ProjM[ 1] + ModM[ 5]*ProjM[ 5] + ModM[ 6]*ProjM[ 9] + ModM[ 7]*ProjM[13];
Clip[ 6] := ModM[ 4]*ProjM[ 2] + ModM[ 5]*ProjM[ 6] + ModM[ 6]*ProjM[10] + ModM[ 7]*ProjM[14];
Clip[ 7] := ModM[ 4]*ProjM[ 3] + ModM[ 5]*ProjM[ 7] + ModM[ 6]*ProjM[11] + ModM[ 7]*ProjM[15];
Clip[ 8] := ModM[ 8]*ProjM[ 0] + ModM[ 9]*ProjM[ 4] + ModM[10]*ProjM[ 8] + ModM[11]*ProjM[12];
Clip[ 9] := ModM[ 8]*ProjM[ 1] + ModM[ 9]*ProjM[ 5] + ModM[10]*ProjM[ 9] + ModM[11]*ProjM[13];
Clip[10] := ModM[ 8]*ProjM[ 2] + ModM[ 9]*ProjM[ 6] + ModM[10]*ProjM[10] + ModM[11]*ProjM[14];
Clip[11] := ModM[ 8]*ProjM[ 3] + ModM[ 9]*ProjM[ 7] + ModM[10]*ProjM[11] + ModM[11]*ProjM[15];
Clip[12] := ModM[12]*ProjM[ 0] + ModM[13]*ProjM[ 4] + ModM[14]*ProjM[ 8] + ModM[15]*ProjM[12];
Clip[13] := ModM[12]*ProjM[ 1] + ModM[13]*ProjM[ 5] + ModM[14]*ProjM[ 9] + ModM[15]*ProjM[13];
Clip[14] := ModM[12]*ProjM[ 2] + ModM[13]*ProjM[ 6] + ModM[14]*ProjM[10] + ModM[15]*ProjM[14];
Clip[15] := ModM[12]*ProjM[ 3] + ModM[13]*ProjM[ 7] + ModM[14]*ProjM[11] + ModM[15]*ProjM[15];

Frustum[Right][A] := clip[ 3] - clip[ 0];
Frustum[Right][B] := clip[ 7] - clip[ 4];
Frustum[Right][C] := clip[11] - clip[ 8];
Frustum[Right][D] := clip[15] - clip[12];
NormalizePlane(self, Right);

Frustum[Left][A] := clip[ 3] + clip[ 0];
Frustum[Left][B] := clip[ 7] + clip[ 4];
Frustum[Left][C] := clip[11] + clip[ 8];
Frustum[Left][D] := clip[15] + clip[12];
NormalizePlane(self, Left);

Frustum[Bottom][A] := clip[ 3] + clip[ 1];
Frustum[Bottom][B] := clip[ 7] + clip[ 5];
Frustum[Bottom][C] := clip[11] + clip[ 9];
Frustum[Bottom][D] := clip[15] + clip[13];
NormalizePlane(self, Bottom);

Frustum[Top][A] := clip[ 3] - clip[ 1];
Frustum[Top][B] := clip[ 7] - clip[ 5];
Frustum[Top][C] := clip[11] - clip[ 9];
Frustum[Top][D] := clip[15] - clip[13];
NormalizePlane(self, Top);

Frustum[Back][A] := clip[ 3] - clip[ 2];
Frustum[Back][B] := clip[ 7] - clip[ 6];
Frustum[Back][C] := clip[11] - clip[10];
Frustum[Back][D] := clip[15] - clip[14];
NormalizePlane(self, Back);

Frustum[Front][A] := clip[ 3] + clip[ 2];
Frustum[Front][B] := clip[ 7] + clip[ 6];
Frustum[Front][C] := clip[11] + clip[10];
Frustum[Front][D] := clip[15] + clip[14];
NormalizePlane(self, Front);
end;

function TFrustum.IsPointWithin(const pX, pY, pZ : Single) : Boolean;
var
 i : Integer;
begin
Result := true;
for i := 0 to 5 do
 if (Frustum[i][A]*pX + Frustum[i][B]*pY + Frustum[i][C]*pZ + Frustum[i][D]) <= 0 then
  begin
  Result := False;
  exit;
  end;
end;

function TFrustum.IsSphereWithin(const pX, pY, pZ, pRadius : Single) : Boolean;
var
 i : Integer;
begin
Result := true;
for i := 0 to 5 do
 if (Frustum[i][A]*pX + Frustum[i][B]*pY + Frustum[i][C]*pZ + Frustum[i][D]) <= -pRadius then
  begin
  Result := False;
  exit;
  end;
end;

function TFrustum.IsBoxWithin(const pX, pY, pZ, pB, pH, pT : Single) : Boolean;
var
 i : Integer;
begin
Result := true;
for i := 0 to 5 do
 begin
 if (Frustum[i][A]*(pX-pB) + Frustum[i][B]*(pY-pH) + Frustum[i][C]*(pZ-pT) + Frustum[i][D]>0) then
  continue;
 if (Frustum[i][A]*(px+pB) + Frustum[i][B]*(py-pH) + Frustum[i][C]*(pz-pT) + Frustum[i][D]>0) then
  continue;
 if (Frustum[i][A]*(px-pB) + Frustum[i][B]*(py+pH) + Frustum[i][C]*(pz-pT) + Frustum[i][D]>0) then
  continue;
 if (Frustum[i][A]*(px+pB) + Frustum[i][B]*(py+pH) + Frustum[i][C]*(pz-pT) + Frustum[i][D]>0) then
  continue;
 if (Frustum[i][A]*(px-pB) + Frustum[i][B]*(py-pH) + Frustum[i][C]*(pz+pT) + Frustum[i][D]>0) then
  continue;
 if (Frustum[i][A]*(px+pB) + Frustum[i][B]*(py-pH) + Frustum[i][C]*(pz+pT) + Frustum[i][D]>0) then
  continue;
 if (Frustum[i][A]*(px-pB) + Frustum[i][B]*(py+pH) + Frustum[i][C]*(pz+pT) + Frustum[i][D]>0) then
  continue;
 if (Frustum[i][A]*(px+pB) + Frustum[i][B]*(py+pH) + Frustum[i][C]*(pz+pT) + Frustum[i][D]>0) then
  continue;
 Result := False;
 end;
end;


end.
