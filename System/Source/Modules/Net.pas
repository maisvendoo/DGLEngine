(*************************************)
(* Network module v0.1               *)
(*************************************)
(* Created by XProger                *)
(* mail : XProger@list.ru            *)
(* site : http://XProger.mirgames.ru *)
(*************************************)
unit Net;

interface

uses Winsock, Windows;

function  NET_Init: boolean; stdcall;
procedure NET_Free; stdcall;
procedure NET_Clear; stdcall;
procedure NET_ClearAPL; stdcall;
function  NET_GetExternalIP: PChar; stdcall;
function  NET_GetHost: PChar; stdcall;
function  NET_GetLocalIP: PChar; stdcall;
function  NET_HostToIP(Host: PChar): PChar; stdcall;
function  NET_InitSocket(Port: WORD): integer; stdcall;
function  NET_Write(Buf: pointer; Count: integer): boolean; stdcall;
function  NET_Send(IP: PChar; Port: WORD; APL: boolean): integer; stdcall;
function  NET_Recv(Buf: pointer; Count: integer; var IP: PChar; var Port: integer; var RecvBytes: integer): integer; stdcall;
procedure NET_Update; stdcall;

implementation

const
 MaxBufLen  = 65507;
 APLreglen  = 128;

type
 TByteArray = array [0..1024] of Byte;
 PByteArray = ^TByteArray;

 TAPLpacket = record
  trys : Byte;
  UID  : WORD;
  Time : DWORD;
  Size : WORD;
  Port : WORD;
  IP   : string;
  Data : PByteArray;
 end;
 PAPLpacket = ^TAPLpacket;

 TAPLreg = record
  UID  : WORD;
  Port : WORD;
  IP   : string;
 end;

var
 NET_Ready   : boolean = false;
 NET_Buf     : PByteArray;
 NET_BufLen  : integer;
 NET_Socket  : integer = -1;

 NET_APLtime : DWORD = 3000;
 NET_APLs    : array of PAPLpacket;
 NET_APLUID  : WORD = 5;
 NET_trys    : Byte = 4;

 APLreg     : array [0..APLreglen - 1] of TAPLreg;
 regseek    : integer = 0;

var
 NET_tmpBuf : PByteArray;

function StrPas(str: PChar): string;
begin
Result := str;
end;

procedure NET_Free; stdcall;
begin
if NET_Ready then
 begin
 if NET_Socket > 0 then
  CloseSocket(NET_Socket);
 NET_Socket := -1;
 FreeMem(NET_Buf);
 FreeMem(NET_tmpBuf);
 NET_Buf    := nil;
 NET_tmpBuf := nil;
 NET_APLs   := nil;
 WSACleanup;
 NET_Ready := false;
 end;
end;

procedure NET_Clear; stdcall;
begin
NET_BufLen := 1;
end;

procedure NET_ClearAPL; stdcall;
var
 i : integer;
begin
for i := 0 to Length(NET_APLs) - 1 do
 begin
 FreeMem(NET_APLs[i]^.Data);
 Dispose(NET_APLs[i]);
 NET_APLs[i] := nil;
 end;
NET_APLs := nil;
end;

function NET_Init: boolean; stdcall;
var
 winsock_version : WORD;
 winsock_data    : WSADATA;
 error, i        : integer;
begin
Result := false;
NET_Free;
NET_Ready := false;
winsock_version := MAKEWORD(1, 1);
error := WSAStartup(winsock_version, winsock_data);
if error <> 0 then
 Exit;

NET_Ready := true;
NET_Clear;

for i := 0 to Length(NET_APLs) - 1 do
 if NET_APLs[i] <> nil then
  begin
  FreeMem(NET_APLs[i]^.Data);
  Dispose(NET_APLs[i]);
  end;

NET_Socket := -1;
NET_APLs   := nil;
NET_APLUID := 1;

if NET_Buf = nil then
 GetMem(NET_Buf, MaxBufLen);
if NET_tmpBuf = nil then
 GetMem(NET_tmpBuf, MaxBufLen);

Result := true;
end;

function NET_InitSocket(Port: WORD): integer; stdcall;
var
 sock    : integer;
 flag    : integer;
 i       : integer;
 address : sockaddr_in;
begin
Result := 0;
i    := 1;
flag := 1;

if NET_Socket > 0 then
 CloseSocket(NET_Socket);


sock := socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
if sock = -1 then
 Exit;

if ioctlsocket(sock, FIONBIO, flag) = -1 then
 Exit;

setsockopt(sock, SOL_SOCKET, SO_BROADCAST, PChar(@i), SizeOf(i));

address.sin_addr.S_addr := INADDR_ANY;
address.sin_port        := htons(Port);
address.sin_family      := AF_INET;

if bind(sock, address, sizeof(address)) = -1 then
 begin
 CloseSocket(sock);
 Exit;
 end;

Result := sock;

NET_Socket := sock;
end;

function NET_GetLocalIP: PChar; stdcall;
var
 Error     : DWORD;
 HostEntry : PHostEnt;
 Address   : In_Addr;
 Buffer    : array [0..63] of Char;
begin
GetHostName(Buffer, SizeOf(Buffer));
HostEntry := gethostbyname(Buffer);
Error := GetLastError;
if Error = 0 then
 begin
 Address := PInAddr(HostEntry^.h_addr_list^)^;
 Result  := inet_ntoa(Address);
 end
else
 Result := '';
end;

function NET_GetExternalIP: PChar; stdcall;
type
 TaPInAddr = array [0..10] of PInAddr;
 PaPInAddr = ^TaPInAddr;
var
 phe           : PHostEnt;
 p             : PaPInAddr;
 Buffer        : array [0..63] of Char;
begin
Result := nil;
GetHostName(Buffer, SizeOf(Buffer));
phe := GetHostByName(buffer);
if phe = nil then
 Exit;
p := PaPInAddr(phe^.h_addr_list);
if p^[1] <> nil then
 Result := inet_ntoa(p^[1]^);
end;

function NET_HostToIP(Host: PChar): PChar; stdcall;
type
 TaPInAddr = array [0..10] of PInAddr;
 PaPInAddr = ^TaPInAddr;
var
 phe           : PHostEnt;
 p             : PaPInAddr;
begin
Result := nil;
phe := gethostbyname(Host);
if phe = nil then
 Exit;
p := PaPInAddr(phe^.h_addr_list);
if p^[0] <> nil then
 Result := inet_ntoa(p^[0]^);
end;

function NET_GetHost: PChar; stdcall;
var
  phe    : PHostEnt;
  Buffer : array[0..63] of Char;
begin
Result := '';
GetHostName(Buffer, SizeOf(Buffer));
phe := GetHostByName(buffer);
if phe = nil then
 Exit;
Result := phe^.h_name;
end;

function NET_Write(Buf: pointer; Count: integer): boolean; stdcall;
var
 i : integer;
begin
Result := false;
if (not NET_Ready) or (NET_Socket <= 0) then Exit;
if Count <= 0 then Exit;

if NET_BufLen + Count < MaxBufLen then
 begin
 for i := Net_BufLen to Net_BufLen + Count - 1 do
  NET_Buf[i] := PByteArray(buf)[i - Net_BufLen];
 NET_BufLen := NET_BufLen + Count;
 Result := true;
 end;
end;

function NET_Recv(Buf: pointer; Count: integer; var IP: PChar; var Port: integer; var RecvBytes: integer): integer; stdcall;
var
 from    : sockaddr_in;
 i       : integer;
 UID     : DWORD;
 s       : string;
begin
Result := 0;
if (not NET_Ready) or (NET_Socket <= 0) then Exit;
if (Count <= 0) or (Count > MaxBufLen) then Exit;
i := SizeOf(from);
Result := recvfrom(NET_Socket, NET_tmpBuf[0], Count, 0, from, i);
if Result <= 0 then
 begin
 Result    := -1;
 RecvBytes := Result;
 Exit;
 end;

dec(Result);
if Result > 0 then
 begin
 IP   := inet_ntoa(from.sin_addr);
 Port := ntohs(from.sin_port);

 case NET_tmpBuf[0] of
  0 : Move(NET_tmpBuf[1], PByteArray(buf)[0], Result);
  1 : begin
      Move(NET_tmpBuf[1], UID, 2);
      s := StrPas(IP);
      for i := 0 to Length(NET_APLs) - 1 do
       if (NET_APLs[i].UID  = UID) and
          (NET_APLs[i].Port = Port) and
          (NET_APLs[i].IP   = s) then
        begin
        NET_APLs[i].trys := 255;
        break;
        end;
      Result := NET_Recv(Buf, Count, IP, Port, RecvBytes);
      end;
  2 : begin
      dec(Result, 2);

      Move(NET_tmpBuf[1], UID, 2);

      NET_tmpBuf[0] := 1;
      i := SendTo(NET_Socket, NET_tmpBuf[0], 3, 0, from, SizeOf(from));

      for i := 0 to APLreglen - 1 do
       if (APLreg[i].UID = UID) and
          (APLreg[i].Port = Port) and
          (APLreg[i].IP = StrPas(IP)) then
        begin
        Result := NET_Recv(Buf, Count, IP, Port, RecvBytes);
        Exit;
        end;

      Move(NET_tmpBuf[3], PByteArray(Buf)[0], Result);

      APLreg[regseek].UID  := UID;
      APLreg[regseek].Port := Port;
      APLreg[regseek].IP   := StrPas(IP);
      inc(regseek);
      if regseek >= APLreglen then
       regseek := 0;
      end;
  end;
 end;
RecvBytes := Result;
end;

function NET_Send(IP: PChar; Port: WORD; APL: boolean): integer; stdcall;
var
 address   : sockaddr_in;
 APLpacket : PAPLpacket;
begin
Result := 0;
if (not NET_Ready) or (NET_Socket <= 0) then Exit;

address.sin_family      := AF_INET;
address.sin_port        := htons(Port);
if IP <> nil then
 address.sin_addr.S_addr := inet_addr(IP)
else
 address.sin_addr.S_addr := INADDR_BROADCAST;
FillChar(address.sin_zero, SizeOf(address.sin_zero), 0);

if not APL or (IP = nil) then
 begin
 NET_Buf[0] := 0;
 Result := SendTo(NET_Socket, NET_Buf[0], NET_BufLen, 0, address, SizeOf(address));
 end
else
 begin
 inc(NET_APLUID);
 if NET_APLUID < 5 then
  NET_APLUID := 5;

 New(APLpacket);
 APLpacket^.trys := 1;
 APLpacket^.UID  := NET_APLUID;
 APLpacket^.Time := GetTickCount;
 APLpacket^.Size := NET_BufLen;
 APLpacket^.Port := Port;
 APLpacket^.IP   := StrPas(IP);
 GetMem(APLpacket^.Data, NET_BufLen + 2);

 APLpacket^.Data[0] := 2;
 Move(APLpacket^.UID, APLpacket^.Data[1], 2);
 Move(NET_Buf[1], APLpacket^.Data[3], NET_BufLen - 1);

 SetLength(NET_APLs, Length(NET_APLs) + 1);
 NET_APLs[Length(NET_APLs) - 1] := APLpacket;
 Result := SendTo(NET_Socket, APLpacket^.Data[0], NET_BufLen + 2, 0, address, SizeOf(address));
 end;
end;

procedure NET_Update; stdcall;
var
 i, j    : integer;
 t       : DWORD;
 address : sockaddr_in;
begin
if not NET_Ready then Exit;
t := GetTickCount;
for i := 0 to Length(NET_APLs) - 1 do
 begin
 if t - NET_APLs[i]^.Time > NET_APLtime then
  with NET_APLs[i]^ do
   begin
   address.sin_family      := AF_INET;
   address.sin_port        := htons(Port);
   address.sin_addr.S_addr := inet_addr(PChar(IP));
   FillChar(address.sin_zero, SizeOf(address.sin_zero), 0);
   inc(trys);
   Time := t;
   SendTo(NET_Socket, Data^, Size, 0, address, SizeOf(address));
   end;

 if NET_APLs[i]^.trys >= NET_trys then
  begin
  FreeMem(NET_APLs[i]^.Data);
  Dispose(NET_APLs[i]);
  NET_APLs[i] := nil;
  end
 end;
i := 0;
while i < Length(NET_APLs) do
 if NET_APLs[i] = nil then
  begin
  for j := i to Length(NET_APLs) - 2 do
   NET_APLs[j] := NET_APLs[j + 1];
  SetLength(NET_APLs, Length(NET_APLs) - 1);
  end
 else
  inc(i);
end;


end.
