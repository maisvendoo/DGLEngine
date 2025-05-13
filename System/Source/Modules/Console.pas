//----------------------------------------------------------------------------//
//DRON's OpenGl Engine V 1.0 http://dronprogs.mirgames.ru                     //
//                                                                            //
// Console.pas V 1.0, 27.09.2005                                              //
//                                                                            //
// Processing and drawing console.                                            //
//                                                                            //
// Copyright (C) 2005-2006 Korotkov Andrew aka DRON                           //
//                                                                            //
//This program is free software; you can redistribute it and/or               //
//modify it under the terms of the GNU General Public License                 //
//as published by the Free Software Foundation; either version 2              //
//of the License, or any later version.                                       //
//                                                                            //
//This program is distributed in the hope that it will be useful,             //
//but WITHOUT ANY WARRANTY; without even the implied warranty of              //
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               //
//GNU General Public License (http://www.gnu.org/copyleft/gpl.html)           //
//for more details.                                                           //
//----------------------------------------------------------------------------//
unit Console;

interface
uses DrawFunc2D, Variables, SysUtils;

type TConEntery = record
Name : string;
IsComandProc : boolean;
ComandAdres : procedure;
Value : pointer;
MinValue,MaxValue : integer;
end;

var
ConsoleActive : boolean = false;
ConsoleDraw : boolean = false;
ConGoUp : boolean = false;
ConsoleList : array of string;
ConsoleListCount : integer = 0;
Commands : array of TConEntery;
CommandsCount : integer = 0;
CurentString : string = '';
LastCom : string ='';
LastProcvalue : string ='';
ConY, KeyWait : integer;
Texture : integer = 0;
ConFont : Cardinal;
FontScale : real;

procedure AddStringToConsole(Text : string); stdcall;
procedure ClearConsole; stdcall;
procedure RegisterCommandProcedure(ComName : string; ProcAdress : pointer); stdcall;
procedure CreateConsole(Font : Cardinal; Size : real = 1.0; ConTexture : Cardinal = 0); stdcall;
procedure RegisterCommandValue(ComName : string; ValueAdress : pointer; MaxValue, MinValue : integer); stdcall;
procedure ProcessConsole; stdcall;
procedure DrawConsole; stdcall;
function  GetLastComParam : string; stdcall;
function  OnBack : string;

implementation
uses EngineCore;

procedure ComList;
var i : integer;
begin
for i:=0 to CommandsCount-1 do
AddStringToConsole('  >'+Commands[i].Name);
end;
{------------------------------------------------------------------}
procedure ClearConsole; stdcall;
begin
ConsoleListCount:=0;
SetLength(ConsoleList,ConsoleListCount);
AddStringToConsole(VERSION);
end;
{------------------------------------------------------------------}
procedure CreateConsole(Font : Cardinal; Size : real = 1.0; ConTexture : Cardinal = 0); stdcall;
begin
ConsoleActive:=true;
ConFont:=Font;
FontScale:=Size;
KeyWait:=0;
Cony := -1;
Texture:=ConTexture;

RegisterCommandProcedure('cmndlist',@ComList);

AddStringToConsole(ENGINE_LABEL);
end;
{------------------------------------------------------------------}
procedure AddStringToConsole(Text : string); stdcall;
begin
inc(ConsoleListCount);
SetLength(ConsoleList,ConsoleListCount);
ConsoleList[ConsoleListCount-1]:=text;
end;
{------------------------------------------------------------------}
procedure RegisterCommandProcedure(ComName : string; ProcAdress : pointer); stdcall;
begin
inc(CommandsCount);
SetLength(Commands,CommandsCount);
Commands[CommandsCount-1].Name:=ComName;
Commands[CommandsCount-1].IsComandProc:=true;
@Commands[CommandsCount-1].ComandAdres:=ProcAdress;
end;
{------------------------------------------------------------------}
procedure RegisterCommandValue(ComName : string; ValueAdress : pointer; MaxValue, MinValue : integer); stdcall;
begin
inc(CommandsCount);
SetLength(Commands,CommandsCount);
Commands[CommandsCount-1].Name:=ComName;
Commands[CommandsCount-1].IsComandProc:=false;
Commands[CommandsCount-1].Value:=ValueAdress;
Commands[CommandsCount-1].MinValue:=MinValue;
Commands[CommandsCount-1].MaxValue:=MaxValue;
end;
{------------------------------------------------------------------}
procedure OnTab;
var
i,count : integer;

 function CompText(text,ComName : string) : boolean;
 var i : integer;
 begin
 result:=false;
 if text='' then Exit;
 for i:=1 to length(text) do
 if lowercase(text)[i]<>lowercase(ComName)[i] then Exit;
 result:=true;
 end;

begin
count:=0;
for i:=0 to CommandsCount-1 do if CompText(CurentString,Commands[i].Name) then inc(count);

if count=1 then
begin
for i:=0 to CommandsCount-1 do
if CompText(CurentString,Commands[i].Name) then CurentString:=Commands[i].Name+' ';
 end else
for i:=0 to CommandsCount-1 do
if CompText(CurentString,Commands[i].Name) then AddStringToConsole('  >'+Commands[i].Name);

end;
{------------------------------------------------------------------}
function GetLastComParam : string; stdcall;
begin
result:=LastProcvalue;
end;
{------------------------------------------------------------------}
procedure OnEnter;

 function GetCommand : string;
 var i : integer;
 begin
 result:='';

  for i:=1 to length(CurentString) do
  begin
  if CurentString[i]=' ' then exit;
  result:=result+CurentString[i];
  end;

 end;

 function GetCIndex(Name : string):integer;
 var  i : integer;
 begin
 result:=-1;
  for i:=0 to CommandsCount-1 do
   if lowercase(Commands[i].Name)=lowercase(Name) then
   begin
   result:=i;
   Exit;
   end;
 end;

 function GetValue : string;
 var i : integer; onewas : boolean;
 begin
 result:='';
 onewas:=false;

  for i:=1 to length(CurentString) do
  begin
  result:=result+CurentString[i];
  if (not onewas) and (CurentString[i]=' ') then
  begin
  onewas:=true;
  result:='';
  end;
  end;

  if not onewas then result:='';
 end;

var a : integer;
begin

a:=GetCIndex(GetCommand);

 if a<>-1 then
 begin

 if Commands[a].IsComandProc then
 begin

 LastProcvalue:=GetValue;
 Commands[a].ComandAdres;

 end else

 begin
try
  if GetValue='' then AddStringToConsole(uppercase(Commands[a].Name)+' current value is '+inttostr(integer(Commands[a].value^))+' value may vary from '+inttostr(Commands[a].MinValue)+' up to '+inttostr(Commands[a].MaxValue)+'.') else
    if (strtoint(GetValue)>Commands[a].MaxValue) or  (strtoint(GetValue)<Commands[a].MinValue) then
    AddStringToConsole('Value may vary from '+inttostr(Commands[a].MinValue)+' up to '+inttostr(Commands[a].MaxValue)+'.')
    else begin
    integer(Commands[a].value^) := strtoint(GetValue);
    AddStringToConsole(CurentString);
    end;
except
   AddStringToConsole('Error, "'+GetValue+'" is not a valid integer value!');
end;
 end;

 end else  AddStringToConsole('Unknown command "'+CurentString+'"');

LastCom:=CurentString;
CurentString:='';
end;
{------------------------------------------------------------------}
function OnBack : string;
var i : integer;
begin
result:='';
for i:=1 to length(CurentString)-1 do
result:=result+CurentString[i];
end;
{------------------------------------------------------------------}
procedure ProcessConsole; stdcall;
begin

 if ConsoleDraw then
 begin
 inc(KeyWait);

 if not ConGoUp and (ConY< InitResY div 2) then Cony:=Cony+9;

 if ConGoUp then
 begin

 Cony:=Cony-9;

 if Cony<-2 then
 begin
 ConsoleDraw:=false;
 ConGoUp:=false;
 CurentString:='';
 end;

 end;

 if KeyWait>1000 then KeyWait:=14;

  if (IsKeyPressed(13)) and (KeyWait>10) then //Enter
  begin
  KeyWait:=0;
  if CurentString<>'' then OnEnter;
  end;

  if (IsKeyPressed(9)) and (KeyWait>10) then //Tab
  begin
  KeyWait:=0;
  OnTab;
  end;

  if (IsKeyPressed(38)) and (KeyWait>10) then //Up
  begin
  KeyWait:=0;
  if LastCom<>'' then CurentString:=LastCom;
  end;

 end;

end;
{------------------------------------------------------------------}
procedure DrawConsole; stdcall;
var i,a,color : integer;
begin

 if ConsoleDraw then
 begin
 if Texture=0 then color:=$080808 else color:=$FFFFFF;
 DrawTexture2D(Texture,0,0,InitResX,ConY,0,200,Color);
 DrawLine2D(0,cony,InitResX,cony,$FFFFFF,150);
 DrawText2D(ConFont,2,round(cony-GetTextHeight(ConFont,'AÙW',FontScale)-4),'>'+CurentString+'_',$FFFFFF,255,FontScale);
 a:=round(cony/GetTextHeight(ConFont,'AÙW',FontScale));
 a:=ConsoleListCount-a-1;
 if a<0 then a:=0;
 for i:=ConsoleListCount-1 downto a do
 DrawText2D(ConFont,2,round((cony-GetTextHeight(ConFont,ConsoleList[i],FontScale)-6)-(ConsoleListCount-i)*GetTextHeight(ConFont,ConsoleList[i],FontScale)),ConsoleList[i],$FFFFFF,255,FontScale);
 end;

end;

end.
