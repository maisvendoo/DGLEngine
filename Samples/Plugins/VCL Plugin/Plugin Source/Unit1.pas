unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DGLEngine_header;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Button1: TButton;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin

  case Combobox1.ItemIndex of
  0: begin WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','ResX','640'); WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','ResY','480'); end;
  1: begin WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','ResX','800'); WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','ResY','600'); end;
  2: begin WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','ResX','1024');WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','ResY','768'); end;
  end;

  case Combobox2.ItemIndex of
  0: WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','PixelDepth','16');
  1: WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','PixelDepth','32');
  end;

  case Combobox3.ItemIndex of
  0: WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','DisplayFrequency','60');
  1: WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','DisplayFrequency','75');
  2: WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','DisplayFrequency','85');
  3: WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','DisplayFrequency','100');
  end;

  if CheckBox1.Checked then WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','VSync','1') else WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','VSync','0');
  if CheckBox2.Checked then WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','Fullscreen','1') else WriteValueToIniFile(ENGINE_INIFILE,'Screen Mode','Fullscreen','0');

  Application.MainForm.Close;
  Application.MainForm.Destroy;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
if fileexists(ENGINE_INIFILE) then
begin
  case strtoint(ReadValueFromIniFile(ENGINE_INIFILE,'Screen Mode','ResX')) of
  640: Combobox1.ItemIndex:=0;
  800: Combobox1.ItemIndex:=1;
  1024:Combobox1.ItemIndex:=2;
  end;

  case strtoint(ReadValueFromIniFile(ENGINE_INIFILE,'Screen Mode','PixelDepth')) of
  16:Combobox2.ItemIndex:=0;
  32:Combobox2.ItemIndex:=1;
  end;

  case strtoint(ReadValueFromIniFile(ENGINE_INIFILE,'Screen Mode','DisplayFrequency')) of
  60:Combobox3.ItemIndex:=0;
  75:Combobox3.ItemIndex:=1;
  85:Combobox3.ItemIndex:=2;
  100:Combobox3.ItemIndex:=3;
  end;

  case strtoint(ReadValueFromIniFile(ENGINE_INIFILE,'Screen Mode','Fullscreen')) of
  0:Checkbox2.Checked:=false;
  1:Checkbox2.Checked:=true;
  end;

  case strtoint(ReadValueFromIniFile(ENGINE_INIFILE,'Screen Mode','VSync')) of
  0:Checkbox1.Checked:=false;
  1:Checkbox1.Checked:=true;
  end;
end;
end;

end.
