object Form1: TForm1
  Left = 623
  Top = 512
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'DGLEngine Setup'
  ClientHeight = 146
  ClientWidth = 244
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 241
    Height = 97
    Caption = 'Screen'
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 24
      Width = 54
      Height = 13
      Caption = 'Resolution:'
    end
    object Label2: TLabel
      Left = 112
      Top = 24
      Width = 47
      Height = 13
      Caption = 'Bit depth:'
    end
    object Label3: TLabel
      Left = 176
      Top = 24
      Width = 55
      Height = 13
      Caption = 'Frequency:'
    end
    object ComboBox1: TComboBox
      Left = 8
      Top = 40
      Width = 97
      Height = 19
      Style = csOwnerDrawFixed
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = '640X480'
      Items.Strings = (
        '640X480'
        '800X600'
        '1024x768')
    end
    object ComboBox2: TComboBox
      Left = 112
      Top = 40
      Width = 57
      Height = 19
      Style = csOwnerDrawFixed
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 1
      Text = '16Bit'
      Items.Strings = (
        '16Bit'
        '32Bit')
    end
    object ComboBox3: TComboBox
      Left = 176
      Top = 40
      Width = 57
      Height = 19
      Style = csOwnerDrawFixed
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 2
      Text = '60Hz'
      Items.Strings = (
        '60Hz'
        '75Hz'
        '85Hz'
        '100Hz')
    end
    object CheckBox1: TCheckBox
      Left = 8
      Top = 72
      Width = 89
      Height = 17
      Caption = 'VSync'
      TabOrder = 3
    end
    object CheckBox2: TCheckBox
      Left = 120
      Top = 72
      Width = 105
      Height = 17
      Caption = 'Fullscreen'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
  end
  object Button1: TButton
    Left = 80
    Top = 112
    Width = 81
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = Button1Click
  end
end
