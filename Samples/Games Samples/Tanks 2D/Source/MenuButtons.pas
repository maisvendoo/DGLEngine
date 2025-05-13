unit MenuButtons;

interface
uses DGLEngine_header, Windows, GameUtils;

type
TGLTextButton = class
X,Y : integer;
Font, Tex : cardinal;
Text : string;
proc : procedure;
public
 constructor Create;
 procedure   Process;
 procedure   Draw;
private
 R : Trect;
 MDown,adec,onbut : boolean;
 Alpha : integer;
end;

procedure Null;

implementation

//------------------------------------------------------------------------------
constructor TGLTextButton.Create;
begin
Alpha:=50;
MDown:=false;
adec:=false;
onbut:=false;
end;
//------------------------------------------------------------------------------
procedure TGLTextButton.Process;
begin
R.X:=X;
R.Y:=Y;
R.Width:=GetTextWidth(Font,Text);
R.Height:=36;

 if PointInRect(GetMousePos.X,GetMousePos.Y,R.X,R.Y,R.Width,R.Height) then
 begin
 onbut:=true;
 if Mdown and (GetMouseButtonPressed<>MB_LEFT)  then proc;
 if GetMouseButtonPressed=MB_LEFT then Mdown:=true;
 if adec then Alpha:=Alpha-5 else Alpha:=Alpha+5;
 if Alpha>160 then adec:=true;
 if Alpha<5 then adec:=false;
 end else
 begin
 Mdown:=false;
 onbut:=false;
 adec:=false;
 if Alpha>5 then Alpha:=Alpha-5;
 end;

end;
//------------------------------------------------------------------------------
procedure TGLTextButton.Draw;
var Color: integer;
begin

if Alpha>0 then DrawTexture2D(Tex,X-20,Y-GetTextHeight(Font,Text) div 3,GetTextWidth(Font,Text)+40,62,0,Alpha,$FFFF00,true);

if onbut then
if MDown then Color:=$462300 else Color:=$D26900
 else
Color:=$804000;

DrawText2D(Font,X,Y,Text,Color);
end;
//------------------------------------------------------------------------------
procedure Null;
begin
//
end;

end.
