unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DGLEngine_header;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Edit1: TEdit;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Nick : string;
implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
if not LoadDGLEngineDLL('..\..\..\System\DGLEngine.dll') then Close;

randomize;
Nick := 'User_' + IntToStr(random(1000));

if not NET_Init then
 begin
 MessageBox(Handle, 'Невозможно инициализировать сетевой протокол', 'Ошибка', MB_ICONHAND);
 Halt;
 end;
NET_InitSocket(21666);
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
NET_Free;
FreeDGLEngineDLL();
end;

procedure TForm1.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
 str : string;
begin
if Key = VK_RETURN then
 begin
 str := '<' + Nick + '>: ' + Edit1.Text;
 Edit1.Text := '';

 NET_Clear;
 NET_Write(@str[1], Length(Str));
 NET_Send(nil, 21666, false);
 end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
 buf  : array [0..255] of Char;
 recv : integer;
 IP   : PChar;
 Port : integer;
begin
while NET_Recv(@buf, 255, IP, Port, recv) > 0 do
 Memo1.Lines.Add(Copy(buf, 1, recv));
end;

end.
