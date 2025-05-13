library DGLE_Plugin;

uses
  Windows,
  Messages,
  DGLEngine_header in 'DGLEngine_header.pas';

{$R *.res}

var
PluginLoaded : boolean = false;

procedure SampleProc; stdcall;
begin
//Пример пользовательской экспортируемой процедуры
end;

//Вызывается сразу после загрузки плагина движком
procedure Init(DGLE_Handle : THandle; EngWinHandle : HWND; ProcessInterval : byte); stdcall;
begin
//Получаем адреса для процедур движка из той ДЛЛ движка которая грузит плагин
DGLEngineDLL_Handle:=DGLE_Handle;
InitDGLE_1_0;

PluginLoaded:=true;
end;

//Вызывается при отключении плагина
procedure Free; stdcall;
begin

PluginLoaded:=false;
end;

//Вызывается в цикле отрисовки движка, до вызова процедуры из EXE
procedure DrawPre; stdcall;
begin
//
end;

//Вызывается в цикле отрисовки движка, после вызова процедуры из EXE
procedure DrawPost; stdcall;
begin
//
end;

//Вызывается на процессе движка, до вызова процесса из EXE
procedure Process; stdcall;
begin
//
end;

//Обработчик сообщений поступающих окну движка, вызывается до вызова обработчика сообщений самого движка
procedure OnMessage(var Msg : tagMSG); stdcall;
begin
 if Msg.message=WM_KEYUP then
  if Msg.wParam=119{F8} then ;
end;

exports
//Системные экспортируемые процедуры
Init,
Free,
DrawPre,
DrawPost,
Process,
OnMessage,


//Пользовательская экспортируемая функция/процедура
SampleProc;

begin
//Системная инициализации плагина, вызывается до процедуры INIT и если плагин имеет статические функции, то до старта движка
end.
