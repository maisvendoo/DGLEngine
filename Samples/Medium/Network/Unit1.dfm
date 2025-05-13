object Form1: TForm1
  Left = 215
  Top = 127
  Width = 640
  Height = 480
  Caption = 'Network module demo'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 632
    Height = 410
    Align = alClient
    ReadOnly = True
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 410
    Width = 632
    Height = 41
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      632
      41)
    object Edit1: TEdit
      Left = 8
      Top = 8
      Width = 617
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnKeyDown = Edit1KeyDown
    end
  end
  object Timer1: TTimer
    Interval = 50
    OnTimer = Timer1Timer
    Left = 8
    Top = 8
  end
end
