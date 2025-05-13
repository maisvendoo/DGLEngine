//----------------------------------------------------------------------------//
//DRON's OpenGl Engine V 1.0 http://dronprogs.mirgames.ru                     //
//                                                                            //
// EngineUtils.pas V 1.0, 26.01.2006; 1:54                                    //
//                                                                            //
// Simple some utils for system use.                                          //
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
unit EngineUtils;

interface

uses
  SysUtils, Windows, MMSystem,Classes, IniFile, Variables, Graphics;

procedure AddToLogFile(FileName, LogStr:String; IsDate : Boolean = false; IsTime : Boolean = false; FileRewrite : boolean = false);  stdcall;
function  GetCPU: PChar;
function  GetMemory: DWORD;
function  ReadValueFromIniFile(Filename, Section, Key: string):string; stdcall;
procedure WriteValueToIniFile(Filename, Section, Key, Value : string); stdcall;
function  Input_JoyDown(JoyNum, Button: Byte): boolean; stdcall;
function  Input_JoyDirections(JoyNum, Direction: Byte): boolean; stdcall;
function  PrintScreen(Folder : string = '') : integer; stdcall;
function  RectInScreen(X,Y,W,H : integer):boolean;
function  BoolToStr(b : boolean) : string;
function  GetTimer: integer;
function  GetMemoryFree: DWORD;
procedure GetWindowsVersion(var Major : integer;
                            var Minor : integer);

{$IFDEF WIN32}
function GetVersionEx(lpOs : pointer) : BOOL; stdcall;
external 'kernel32' name 'GetVersionExA';
{$ENDIF}

implementation

procedure GetWindowsVersion(var Major : integer;
                            var Minor : integer);
var
{$IFDEF WIN32}
  lpOS, lpOS2 : POsVersionInfo;
{$ELSE}
  l : longint;
{$ENDIF}
begin
{$IFDEF WIN32}
   GetMem(lpOS, SizeOf(TOsVersionInfo));
   lpOs^.dwOSVersionInfoSize := SizeOf(TOsVersionInfo);
   while getVersionEx(lpOS) = false do begin
     GetMem(lpos2, lpos^.dwOSVersionInfoSize + 1);
     lpOs2^.dwOSVersionInfoSize := lpOs^.dwOSVersionInfoSize + 1;
     FreeMem(lpOs, lpOs^.dwOSVersionInfoSize);
     lpOS := lpOs2;
   end;
   Major := lpOs^.dwMajorVersion;
   Minor := lpOs^.dwMinorVersion;
   FreeMem(lpOs, lpOs^.dwOSVersionInfoSize);
{$ELSE}
  l := GetVersion;
  Major := LoByte(LoWord(l));
  Minor := HiByte(LoWord(l));
{$ENDIF}
end;
{------------------------------------------------------------------}
function GetTimer: integer;
var
 T, F : LARGE_INTEGER;
begin
QueryPerformanceFrequency(int64(F));
QueryPerformanceCounter(int64(T));
Result := trunc(1000 * T.QuadPart/F.QuadPart);
end;
{------------------------------------------------------------------}
function BoolToStr(b : boolean) : string;
begin
 if b then result:='On' else result:='Off';
end;
{------------------------------------------------------------------}
function RectInScreen(X,Y,W,H : integer):boolean;
begin
result:=
  (X < InitResX) and
  (X+W > 0) and
  (Y < InitResY) and
  (Y+H > 0) or
  (0 < X+W) and
  (InitResX > X) and
  (0 < InitResY) and
  (Y+H > 0);
end;
{------------------------------------------------------------------}
function PrintScreen(Folder : string = '') : integer; stdcall;
var i : integer; B:TBitmap;
begin
if Folder<>'' then Folder:=Folder+'\';
i:=0;
B:=TBitmap.Create;
B.Width:=CurW;
B.Height:=CurH;
B.PixelFormat:=pf32bit;
bitblt(B.Canvas.Handle,0,0,CurW,CurH,h_DC,0,0,SRCCOPY);
 while fileexists(Folder+'ScreenShot'+inttostr(i)+'.bmp')do inc(i);
B.SaveToFile(Folder+'ScreenShot'+inttostr(i)+'.bmp');
B.Free;
AddToLogFile(EngineLog,'Screenshot saved to:'+Folder+'ScreenShot'+inttostr(i)+'.bmp.');
result:=i;
end;
{------------------------------------------------------------------}
function ReadValueFromIniFile(Filename, Section, Key: string):string; stdcall;
var ini : TIniFile;
begin
result:='';
if fileexists(Filename) then
begin
ini:=TIniFile.Create(Filename);
result:=ini.GetIniSectionKeyValue(Section,Key);
if result='-1' then AddToLogFile(EngineLog,'File "'+Filename+'" is incorrect ini file!');
ini.Free;
end else AddToLogFile(EngineLog,'File "'+Filename+'" not found!');
end;
{------------------------------------------------------------------}
procedure WriteValueToIniFile(Filename, Section, Key, Value : string); stdcall;
var ini : TIniFile;
begin
if fileexists(Filename) then
begin
ini:=TIniFile.Create(Filename);
if not ini.IsIniSection(Section) then ini.CreateIniSection(Section);
ini.SetIniSectionKeyValue(Section,Key,value);
ini.SaveToFile;
ini.Free;
end else AddToLogFile(EngineLog,'File "'+Filename+'" not found!');
end;
{------------------------------------------------------------------}
function GetCPU: PChar;
var
 CPUName : array [0..95] of Char;

 function GetCPUName: integer;
 const
  DelayTime = 500;
 var
  TimerHi : DWORD;
  TimerLo : DWORD;
  PriorityClass : Integer;
  Priority : Integer;
 asm   // name
    mov eax, $80000002
    db $0F, $A2
    mov dword ptr[CPUName], eax
    mov dword ptr[CPUName+4], ebx
    mov dword ptr[CPUName+8], ecx
    mov dword ptr[CPUName+12], edx

    mov eax, $80000003
    db $0F, $A2
    mov dword ptr[CPUName+16], eax
    mov dword ptr[CPUName+20], ebx
    mov dword ptr[CPUName+24], ecx
    mov dword ptr[CPUName+28], edx

    mov eax, $80000004
    db $0F, $A2
    mov dword ptr[CPUName+32], eax
    mov dword ptr[CPUName+36], ebx
    mov dword ptr[CPUName+40], ecx
    mov dword ptr[CPUName+44], edx
 end;
begin
try
 GetCPUName;
 Result := CPUName;
except
 Result := 'Error while detecting CPU!'
end;
Result := PChar(Trim(StrPas(Result)));
end;
{------------------------------------------------------------------}
function GetMemory: DWORD;
var
 memStatus : TMemoryStatus;
begin
memStatus.dwLength := sizeOf(memStatus);
GlobalMemoryStatus(memStatus);
Result := memStatus.dwTotalPhys;
end;
{------------------------------------------------------------------}
function GetMemoryFree: DWORD;
var
 memStatus : TMemoryStatus;
begin
memStatus.dwLength := sizeOf(memStatus);
GlobalMemoryStatus(memStatus);
Result := memStatus.dwAvailPhys;
end;
{------------------------------------------------------------------}
function Input_JoyDown(JoyNum, Button: Byte): boolean; stdcall;
var
 joy: TJoyInfo;
begin
joyGetPos(JoyNum, @joy);
Result := (joy.wbuttons and Button) > 0;
end;
{------------------------------------------------------------------}
function Input_JoyDirections(JoyNum, Direction: Byte): boolean; stdcall;
//1 - xleft, 2 - xrigth, 3 - yup, 4 - ydown
var
 joy: TJoyInfo;
begin
joyGetPos(JoyNum, @joy);

case Direction of
1:Result := joy.wXpos = 0;
2:Result := joy.wXpos = 65535;
3:Result := joy.wYpos = 0;
4:Result := joy.wYpos = 65535;
end;
end;
{------------------------------------------------------------------}
procedure AddToLogFile(FileName, LogStr:String; IsDate : Boolean = false; IsTime : Boolean = false; FileRewrite : boolean = false);  stdcall;
var
  F          : TextFile;
  Dt,Tm, DTm : String;
Begin
  if (not IsWriteLog) and (FileName=EngineLog) then Exit;
  if (not FileExists(FileName)) or (FileRewrite) then
  Begin
  {$I-}
    AssignFile(f,FileName);
    Rewrite(f);
    CloseFile(f);
  {$I+}
  End;
  {$I-}
  AssignFile(f,FileName);
  Append(f);
  Dt:=DateToStr(Now);
  Tm:=TimeToStr(Now);
  if (IsDate) then
    DTm:='['+dt
  else
    DTm:='[';
  if ( (IsDate) and (IsTime)) then
    DTm:=DTm+'|';
  if (IsTime) then
    DTm:=DTm+Tm+'] '
  else
    DTm:=DTm+'] ';
  if ((not IsDate) and (not IsTime)) then
    DTm:='';
  WriteLn(f,DTm+LogStr);
  CloseFile(f);
  {$I+}
End;

end.
