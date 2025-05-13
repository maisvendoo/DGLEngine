program Demo;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  DGLEngine_header in '..\..\..\System\DGLEngine_header.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
