unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, AppEvnts, DGLEngine_header;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Button1: TButton;
    ApplicationEvents1: TApplicationEvents;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Panel1CanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure DrawScene;
begin
BeginObj3D;
 SetLight();
 Position3D(0,0,-2);
 DrawSphere(0.5);
 DeactiveLight();
EndObj3D;
end;

procedure TForm1.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
begin
EngineMainDraw;
end;

procedure TForm1.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
EngineProcessMessages(Msg);
end;

procedure TForm1.Panel1CanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
UpdateRenderRect(NewWidth,NewHeight);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
LoadDGLEngineDLL('..\..\..\System\DGLEngine.dll');

RegProcedure(PROC_DRAW,@DrawScene);

SetEngineInitParametrs(Panel1.Width,Panel1.Height,32,0,FALSE,FALSE,FALSE,FALSE);

StartEngine_DrawToPanel(Panel1.Handle);

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
QuitEngine;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
Close;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
FreeDGLEngineDLL;
end;

end.
