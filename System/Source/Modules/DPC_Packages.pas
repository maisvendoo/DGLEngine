//----------------------------------------------------------------------------//
//DRON's OpenGl Engine V 1.0 http://dronprogs.mirgames.ru                     //
//                                                                            //
// DPC_packages.pas V 1.0, 11.01.2006                                         //
//                                                                            //
// Module provides loading data from package routines.                        //
//                                                                            //
// Copyright (C) 2005-2006 Korotkov Andrew aka DRON                           //
//                                        base code by 3d[Power](2003)        //
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
unit DPC_Packages;

interface
uses Classes, ZLib, EngineUtils, Variables, SysUtils, Windows;

type  DPC_Header = packed record
        ID : array [0..3] of char;
        salt : cardinal;
        Realsize : cardinal;
        salt1 : cardinal;
        Recordscount : word;
        salt2 : cardinal;
        RecordsOffset : cardinal;
      end;

type  PDPC_Record = ^DPC_Record;
        DPC_Record = packed record
        filename : string[60];
        size, realsize : cardinal;
        offset : cardinal;
      end;

const
  GZBufferSize = 2048;
  crNone=0;
  crFastest=1;
  crDefault=2;
  crMax=3;

var
  GZBuffer: array[1..GZBufferSize]of byte;

function  LoadFromPackage(const Filename,Name : string):TMemoryStream; stdcall;
procedure ExtractFromPackage(const PackageName, Name, DestFilename : string); stdcall;


implementation

function CZIP_DecompressStreamToStream(FSource: TMemoryStream; Size, RealSize: LongInt; var FDest: TMemoryStream): LongInt;
var
  COut: TDecompressionStream;
  i,TotalBlocks: LongInt;
begin
  COut:=TDecompressionStream.Create(FSource);
  TotalBlocks:=RealSize div GZBufferSize;
  if TotalBlocks=0 then
  begin
    COut.Read(GZBuffer,RealSize);
    FDest.Write(GZBuffer,RealSize);
  end else
  begin
    for i:=1 to TotalBlocks do
    begin
      COut.Read(GZBuffer,GZBufferSize);
      FDest.Write(GZBuffer,GZBufferSize);
    end;
    if RealSize-TotalBlocks*GZBufferSize>0 then
    begin
      COut.Read(GZBuffer,RealSize-TotalBlocks*GZBufferSize);
      FDest.Write(GZBuffer,RealSize-TotalBlocks*GZBufferSize);
    end;
  end;
  COut.Free;
end;
{------------------------------------------------------------------}
procedure ExtractFromPackage(const PackageName, Name, DestFilename : string); stdcall;
begin
LoadFromPackage(PackageName, Name).SaveToFile(DestFilename);
end;
{------------------------------------------------------------------}
function LoadFromPackage(const Filename,Name : string):TMemoryStream; stdcall;
var
       OriginalDPC, BlockCompressed, BlockDeCompressed : TMemoryStream;
       DPCHead : DPC_Header;
       List : TstringList;
       i : word;
       DPC_Rec : DPC_Record;
       Offsets,Sizes,RealSizes : array of cardinal;

procedure DeCryptStream (var Stream : TMemoryStream);
begin
        // Mega super puper encryption.
        Stream.Write('xÚ', 2);
        Stream.Position := 0;
end;

begin
result:=nil;

        if not FileExists(Filename) then begin
        MessageBox(0, Pchar('Package file not found "'+Filename+'"!'), 'Error', MB_OK or MB_ICONERROR);
        AddToLogFile(EngineLog,'Package file not found "'+Filename+'"!');
        exit;
        end;

        OriginalDPC := TMemoryStream.Create;
        OriginalDPC.LoadFromFile(Filename);
        OriginalDPC.Read(DPCHead, sizeof(DPCHead));

        if DPCHead.ID <> 'DPC' then begin
        MessageBox(0, Pchar('Invalid DPC or file corrupted "'+Filename+'"!'), 'Error', MB_OK or MB_ICONERROR);
        AddToLogFile(EngineLog,'Invalid DPC or file corrupted "'+Filename+'"!');
        OriginalDPC.Free;
        exit;
        end;

        if OriginalDPC.Size < DPCHead.RecordsOffset then begin
        MessageBox(0, Pchar('Unexpected end of file - file corrupted "'+Filename+'"!'), 'Error', MB_OK or MB_ICONERROR);
        AddToLogFile(EngineLog,'Unexpected end of file - file corrupted "'+Filename+'"!');
        OriginalDPC.Free;
        exit;
        end;

        BlockCompressed := TMemoryStream.Create;
        BlockDeCompressed := TMemoryStream.Create;
        OriginalDPC.Position := DPCHead.RecordsOffset;
        List := TStringList.Create;

          OriginalDPC.Position:=DPCHead.RecordsOffset;
          List.Clear;

             for i := 0 to DPCHead.Recordscount - 1 do begin
             SetLength(Offsets,i+1);
             SetLength(Sizes,i+1);
             SetLength(RealSizes,i+1);
              OriginalDPC.Read(DPC_Rec, SizeOf(DPC_Rec));
             List.Add(DPC_Rec.filename);
             Offsets[i]:=DPC_Rec.offset;
             Sizes[i]:=DPC_Rec.size;
             RealSizes[i]:=DPC_Rec.realsize;
             end;

           for i := 0 to  List.Count - 1 do
             if lowercase(List.Strings[i]) = lowercase(name) then
             begin
              OriginalDPC.Position:=Offsets[i];
               blockcompressed.copyfrom(originaldpc, sizes[i]);

                // decompress _BlockCompressed_
                BlockCompressed.Position := 0;
                DeCryptStream(BlockCompressed);
                BlockDeCompressed.clear;
                CZIP_DecompressStreamToStream(BlockCompressed, Sizes[i], RealSizes[i], BlockDeCompressed);
                BlockDeCompressed.Position := 0;

                result:=TMemoryStream.Create;
                BlockDeCompressed.SaveToStream(result);
                result.Position:=0;

        BlockCompressed.free;
        BlockDeCompressed.free;
        OriginalDPC.free;
        List.Free;
        Exit;

  end;
    MessageBox(0, Pchar('Record "'+name+'" not found in "'+Filename+'"!'), 'Error', MB_OK or MB_ICONERROR);
    AddToLogFile(EngineLog,'Record "'+name+'" not found in "'+Filename+'"!');
end;

end.
