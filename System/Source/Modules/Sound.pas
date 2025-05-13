//----------------------------------------------------------------------------//
//DRON's OpenGl Engine V 1.0 http://dronprogs.mirgames.ru                     //
//                                                                            //
// Sound.pas V 1.0a, 17.04.2008                                                //
//                                                                            //
// This module provides all sound and music routines.                         //
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
unit Sound;

interface
uses Windows, DirectX, MMSystem, Variables, EngineUtils, Classes, SysUtils, DPC_packages;

type
TSampleData = record
Data : pointer;
DataSize : longword;
end;

TWav_Header = record
riff : array [0..3] of char;
filesize : longword;
rifftype : array [0..3] of char;
chunk_id1 : array [0..3] of char;
chunksize1 : longword;
wFormatTag : word;
nChannels  : word;
nSamplesPerSec : longword;
nAvgBytesPerSec : longword;
nBlockAlign : word;
wBitsPerSample : word;
chunk_id2 : array [0..3] of char;
chunksize2 : longword;
end;

pSStype = ^TSStype;
TSStype = record
Active : boolean;
SpS: Integer; Bit: Word; Stereo:Boolean; Seconds: integer;
Volume : integer;
X,Y,Z : real;
Sample : TSampleData;
end;

var
   DirectSound          : IDirectSound;
   DirectSoundBuffer    : IDirectSoundBuffer;
   SoundsList           : array of TSStype;
   SListCount           : integer = 0;
   Buffers              : array of IDirectSoundBuffer;
   Buffers3D            : array of IDirectSound3DBuffer;
   BuffersCount         : integer = 0;
   FDeviceID            : WORD;
   DX                   : boolean = false;
   LoopMusic            : boolean;

   procedure DirectSoundInit; stdcall;
   function  LoadSample(Filename : string; FromStream : boolean = false; Name : string = ''):integer; stdcall;
   procedure FreeSample(Index : integer); stdcall;
   procedure FreeSound;
   procedure Mci_loop;
   procedure PlaySample(Index : integer); stdcall;
   procedure SetSampleVolume(Index : integer; Volume : byte); stdcall;
   procedure PlayMusic(Filename : string; Looped : boolean = true); stdcall;
   procedure StopMusic; stdcall;
   function  IsMusicPlaying : boolean; stdcall;
   procedure SetSample3DPosition(Index : integer; X,Y,Z : real); stdcall;
   procedure GetSample3DPosition(Index : integer; var X,Y,Z : real); stdcall;

implementation

procedure Mci_loop;
var
SeekParm: TMCI_Seek_Parms;
StatusParm: TMCI_Status_Parms;
PlayParm: TMCI_Play_Parms;
FError, Length, position : longint;
begin
 if (LoopMusic) and (FDeviceID<>0) then
 begin

  StatusParm.dwItem := mci_Status_Length;
  FError := mciSendCommand( FDeviceID, mci_Status, mci_Wait or mci_Status_Item, Longint(@StatusParm));
  Length := StatusParm.dwReturn;

  StatusParm.dwItem := mci_Status_Position;
  FError := mciSendCommand( FDeviceID, mci_Status, mci_Wait or mci_Status_Item, Longint(@StatusParm));
  position := StatusParm.dwReturn;

  if position>=length then
  begin
  FError := mciSendCommand( FDeviceID, mci_Seek, mci_Seek_To_Start, Longint(@SeekParm));

  PlayParm.dwCallback := h_Wnd;
  FError := mciSendCommand( FDeviceID, mci_Play, 0, Longint(@PlayParm));
  end;
 end;
end;
{------------------------------------------------------------------}
function IsMusicPlaying : boolean; stdcall;
var
StatusParm: TMCI_Status_Parms;
FError, Length, position : longint;
begin
result:=false;
 if (FDeviceID<>0) then
 begin
  result:=true;
  StatusParm.dwItem := mci_Status_Length;
  FError := mciSendCommand( FDeviceID, mci_Status, mci_Wait or mci_Status_Item, Longint(@StatusParm));
  Length := StatusParm.dwReturn;

  StatusParm.dwItem := mci_Status_Position;
  FError := mciSendCommand( FDeviceID, mci_Status, mci_Wait or mci_Status_Item, Longint(@StatusParm));
  position := StatusParm.dwReturn;

  if position>=length then result:=false;
 end;

end;
{------------------------------------------------------------------}
procedure PlayMusic(Filename : string; Looped : boolean = true); stdcall;
var
  OpenParm: TMCI_Open_Parms;
  PlayParm: TMCI_Play_Parms;
  FError : longint;
begin
if fileexists(Filename) then
begin
LoopMusic:=Looped;
FillChar(OpenParm, SizeOf(TMCI_Open_Parms), 0);
OpenParm.dwCallback := 0;
OpenParm.lpstrElementName := PChar(Filename);
FError := mciSendCommand(0, mci_Open, MCI_OPEN_ELEMENT, Longint(@OpenParm));
if FError <> 0 then AddToLogFile(EngineLog,'Error while openning MCI device!');
FDeviceID := OpenParm.wDeviceID;
PlayParm.dwCallback := h_Wnd;
FError := mciSendCommand( FDeviceID, mci_Play, 0, Longint(@PlayParm));
if FError <> 0 then
AddToLogFile(EngineLog,'MCI device opened.');
end else  AddToLogFile(EngineLog,'File "'+ Filename +'" not found!');
end;
{------------------------------------------------------------------}
procedure StopMusic; stdcall;
var
GenParm: TMCI_Generic_Parms;
FError : longint;
begin
GenParm.dwCallback := h_Wnd;
FError:=mciSendCommand( FDeviceID, mci_Stop, 0, Longint(@GenParm));
if FError <> 0 then AddToLogFile(EngineLog,'Error while stoping MCI device!');
mciSendCommand( FDeviceID, mci_Close, 0, Longint(@GenParm));
FDeviceID:=0;
end;
{------------------------------------------------------------------}
procedure DirectSoundInit; stdcall;
var BufferDesc  : DSBUFFERDESC;
    PCM         : TWaveFormatEx;
begin
if not DX then
begin
if DirectSoundCreate(nil, DirectSound, nil) <> DS_OK then
  AddToLogFile(EngineLog,'Failed to create IDirectSound object!');

FillChar(BufferDesc, SizeOf(DSBUFFERDESC),0);
FillChar(PCM, SizeOf(TWaveFormatEx),0);
with BufferDesc do
begin
  PCM.wFormatTag:=WAVE_FORMAT_PCM;
  PCM.nChannels:=2;
  PCM.nSamplesPerSec:=44100;
  PCM.nBlockAlign:=4;
  PCM.nAvgBytesPerSec:=PCM.nSamplesPerSec * PCM.nBlockAlign;
  PCM.wBitsPerSample:=16;
  PCM.cbSize:=0;
  dwSize:=SizeOf(DSBUFFERDESC);
  dwFlags:=DSBCAPS_PRIMARYBUFFER;
  dwBufferBytes:=0;
  lpwfxFormat:=nil;
end;
if DirectSound.SetCooperativeLevel(h_Wnd,DSSCL_PRIORITY) <> DS_OK  then
AddToLogFile(EngineLog,'Unable to set Cooperative Level!');

if DirectSound.CreateSoundBuffer(BufferDesc,DirectSoundBuffer,nil) <> DS_OK then
AddToLogFile(EngineLog,'Create Sound Buffer failed!');

if DirectSoundBuffer.SetFormat(PCM) <> DS_OK then
AddToLogFile(EngineLog,'Unable to Set Format PCM!');
DX:=true;
AddToLogFile(EngineLog,'Direct Sound has been initialized.');
end;
end;
{------------------------------------------------------------------}
function GetWavData(Name: PChar; frompack : boolean; ename : string; index : integer):TSampleData;
var Data     : PChar;
    FName    : TMemoryStream;
    DataSize : DWord;
    Chunk    : String[4];
    Pos      : Integer;
    header   : TWav_Header;
 begin
 FName:=TMemoryStream.Create;

  if frompack then
  FName.CopyFrom(LoadFromPackage(Name,ename),0) else
  FName.LoadFromFile(Name);

  FName.Position:=0;
  FName.Read(Header, sizeof (TWav_Header) );

  SoundsList[index].SpS:=header.nSamplesPerSec;
  SoundsList[index].Bit:=Header.wBitsPerSample;
 if Header.nChannels=1 then SoundsList[index].Stereo:=false else
 if Header.nChannels=2 then SoundsList[index].Stereo:=true;
  SoundsList[index].Seconds:=trunc( ( Header.chunksize2 )/( Header.nChannels*Header.nSamplesPerSec*Header.wBitsPerSample/8) ) + 1;

  FName.Position:=0;

Pos:=24;
SetLength(Chunk,4);
repeat
  FName.Seek(Pos, soFromBeginning);
  FName.Read(Chunk[1],4);
  Inc(Pos);
until Chunk = 'data';
FName.Seek(Pos+3, soFromBeginning);
FName.Read(DataSize, SizeOf(DWord));
GetMem(Data,DataSize);
FName.Read(Data^, DataSize);
FName.Free;

result.Data:=Data;
result.DataSize:=DataSize;

if frompack then AddToLogFile(EngineLog,'Sound "'+ename+'" (~'+inttostr(SoundsList[index].Seconds)+' sec.) loaded successfully from package "'+Name+'".') else
AddToLogFile(EngineLog,'Sound "'+Name+'" (~'+inttostr(SoundsList[index].Seconds)+' sec.) loaded successfully.');
end;
{------------------------------------------------------------------}
procedure CreateWriteSecondaryBuffer(var Buffer: IDirectSoundBuffer;
                                          SamplesPerSec: Integer;
                                          Bits: Word;
                                          isStereo:Boolean;
                                          Time: integer);
   var BufferDesc  : DSBUFFERDESC;
       PCM         : TWaveFormatEx;
begin
FillChar(BufferDesc, SizeOf(DSBUFFERDESC),0);
FillChar(PCM, SizeOf(TWaveFormatEx),0);
with BufferDesc do
begin
  PCM.wFormatTag:=WAVE_FORMAT_PCM;
  if isStereo then PCM.nChannels:=2 else PCM.nChannels:=1;
  PCM.nSamplesPerSec:=SamplesPerSec;
  PCM.nBlockAlign:=(Bits div 8)*PCM.nChannels;
  PCM.nAvgBytesPerSec:=PCM.nSamplesPerSec * PCM.nBlockAlign;
  PCM.wBitsPerSample:=Bits;
  PCM.cbSize:=0;
  dwSize:=SizeOf(DSBUFFERDESC);
  dwFlags:=DSBCAPS_STATIC or DSBCAPS_CTRL3D or DSBCAPS_CTRLVOLUME;
  dwBufferBytes:=Time*PCM.nAvgBytesPerSec;
  lpwfxFormat:=@PCM;
end;
if DirectSound.CreateSoundBuffer(BufferDesc,Buffer,nil) <> DS_OK then
AddToLogFile(EngineLog,'Create Sound Buffer failed!');
//buffer.SetFrequency(Freq);  //This sets playing sample speed
end;
{------------------------------------------------------------------}
procedure WriteDataToBuffer(Buffer: IDirectSoundBuffer;
                                 OffSet: DWord; var SoundData;
                                 SoundBytes: DWord);
   var AudioPtr1,AudioPtr2     : Pointer;
    AudioBytes1,AudioBytes2 : DWord;
    h : HResult;
    Temp : Pointer;
begin
  H:=Buffer.Lock(OffSet, SoundBytes, AudioPtr1, AudioBytes1,
              AudioPtr2, AudioBytes2, 0);
  if H = DSERR_BUFFERLOST  then
  begin
   Buffer.Restore;
   if Buffer.Lock(OffSet, SoundBytes, AudioPtr1, AudioBytes1,
                  AudioPtr2, AudioBytes2, 0) <> DS_OK then
                  AddToLogFile(EngineLog,'Unable to Lock Sound Buffer!');

  end else
  if H <> DS_OK then AddToLogFile(EngineLog,'Unable to Lock Sound Buffer!');
  Temp:=@SoundData;
  Move(Temp^, AudioPtr1^, AudioBytes1);
  if AudioPtr2 <> nil then
  begin
   Temp:=@SoundData; Inc(Integer(Temp), AudioBytes1);
   Move(Temp^, AudioPtr2^, AudioBytes2);
  end;
  if Buffer.UnLock(AudioPtr1, AudioBytes1,AudioPtr2, AudioBytes2) <> DS_OK
   then AddToLogFile(EngineLog,'Unable to UnLock Sound Buffer!');;
end;
{------------------------------------------------------------------}
procedure SetSecondary3DBuffer(Index : integer; var Buffer: IDirectSoundBuffer;
                               var _3DBuffer: IDirectSound3DBuffer);
 begin
 if Buffer.QueryInterface(IID_IDirectSound3DBuffer, _3DBuffer) <> DS_OK then
   AddToLogFile(EngineLog,'Failed to create IDirectSound3D object!');
 if _3DBuffer.SetPosition(SoundsList[Index].X,SoundsList[Index].Y,SoundsList[Index].Z,0) <> DS_OK then
   AddToLogFile(EngineLog,'Failed to set IDirectSound3D Position!');
end;
{------------------------------------------------------------------}
function  LoadSample(Filename : string; FromStream : boolean = false; Name : string = ''):integer; stdcall;
var i: integer;
begin
if fileexists(Filename) then
begin
if SListCount>0 then
for i:=0 to SListCount-1 do
 if not SoundsList[i].Active then
 begin
 result:=i;
 SoundsList[i].Active:=true;
 SoundsList[i].Sample:=GetWavData(Pchar(Filename),FromStream,Name,i);
 SoundsList[i].Volume:=0;
 SoundsList[i].X:=0;
 SoundsList[i].Y:=0;
 SoundsList[i].Z:=0;
 Exit;
 end;

 SListCount:=SListCount+1;
 SetLength(SoundsList,SListCount);
 result:=SListCount-1;
 SoundsList[result].Active:=true;
 SoundsList[result].Sample:=GetWavData(PChar(Filename),FromStream,Name,result);
 SoundsList[result].Volume:=0;
 SoundsList[result].X:=0;
 SoundsList[result].Y:=0;
 SoundsList[result].Z:=0;

 end else AddToLogFile(EngineLog,'File not found "'+Filename+'".');
end;
{------------------------------------------------------------------}
procedure FreeSample(Index : integer); stdcall;
begin
if (Index < 0) or (Index > SListCount - 1) then exit;
 if SoundsList[Index].Active then
 begin
 SoundsList[Index].Active:=false;
 FreeMem(SoundsList[Index].Sample.Data);
 SoundsList[Index].Sample.Data:=nil;
 if Index=SListCount-1 then
  begin
  SetLength(SoundsList,SListCount-1);
  dec(SListCount);
  end;
 end;
end;
{------------------------------------------------------------------}
procedure FreeSound;
var i : integer;
GenParm: TMCI_Generic_Parms;
begin
if FDeviceID <> 0 then
begin
GenParm.dwCallback := h_Wnd;
mciSendCommand( FDeviceID, mci_Close, 0, Longint(@GenParm));
end;

if DX then
begin

for i:=0 to BuffersCount-1 do
begin
 Buffers[i]:=nil;
 Buffers3D[i]:=nil;
end;

DirectSoundBuffer:=nil;
if SListCount<>0 then
 for i:=0 to SListCount-1 do
 FreeSample(i);
 AddToLogFile(EngineLog,'Direct Sound has been freed and closed.');
 end;

end;
{------------------------------------------------------------------}
procedure SetSampleVolume(Index : integer; Volume : byte); stdcall;
begin
SoundsList[Index].Volume:=(Volume-100)*100;
end;
{------------------------------------------------------------------}
procedure SetSample3DPosition(Index : integer; X,Y,Z : real); stdcall;
begin
SoundsList[Index].X:=X;
SoundsList[Index].Y:=Y;
SoundsList[Index].Z:=Z;
end;
{------------------------------------------------------------------}
procedure GetSample3DPosition(Index : integer; var X,Y,Z : real); stdcall;
begin
X:=SoundsList[Index].X;
Y:=SoundsList[Index].Y;
Z:=SoundsList[Index].Z;
end;
{------------------------------------------------------------------}
procedure PlaySample(Index : integer); stdcall;
var i: integer; hr,status:cardinal;
begin
if (Index<0) or (Index > SListCount-1) then exit;
if BuffersCount > 0 then
for i:=0 to BuffersCount-1 do
begin
 hr:=Buffers[i].GetStatus(status);
 if  (hr = DS_OK) and
     (Status and DSBSTATUS_PLAYING = 0)  then
 begin
 Buffers[i]:=nil;
 CreateWriteSecondaryBuffer(Buffers[i],SoundsList[Index].sps,SoundsList[Index].bit,SoundsList[Index].stereo,SoundsList[Index].seconds);
 SetSecondary3DBuffer(Index,Buffers[i],Buffers3D[i]);
 WriteDataToBuffer(Buffers[i],0,SoundsList[Index].Sample.Data^,SoundsList[Index].Sample.DataSize);
 if Buffers[i].SetVolume(SoundsList[Index].Volume)<> DS_OK then AddToLogFile(EngineLog,'Couldn''t set volume of sample '+inttostr(Index)+'!');
 if Buffers[i].Play(0,0,0) <> DS_OK then AddToLogFile(EngineLog,'Couldn''t play sample '+inttostr(Index)+'!');
 Exit;
 end;
end;

 BuffersCount:=BuffersCount+1;
 SetLength(Buffers,BuffersCount);
 SetLength(Buffers3D,BuffersCount);
 CreateWriteSecondaryBuffer(Buffers[BuffersCount-1],SoundsList[Index].sps,SoundsList[Index].bit,SoundsList[Index].stereo,SoundsList[Index].seconds);
 SetSecondary3DBuffer(Index,Buffers[BuffersCount-1],Buffers3D[BuffersCount-1]);
 WriteDataToBuffer(Buffers[BuffersCount-1],0,SoundsList[Index].Sample.Data^,SoundsList[Index].Sample.DataSize);
 if Buffers[BuffersCount-1].SetVolume(SoundsList[Index].Volume) <> DS_OK then AddToLogFile(EngineLog,'Couldn''t set volume of sample '+inttostr(Index)+'!');
 if Buffers[BuffersCount-1].Play(0,0,0) <> DS_OK then AddToLogFile(EngineLog,'Couldn''t play sample '+inttostr(Index)+'!');
end;

end.
