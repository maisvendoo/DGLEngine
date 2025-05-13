object Form1: TForm1
  Left = 212
  Top = 287
  Width = 395
  Height = 221
  Caption = 'Render To Panel Sample'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 56
    Top = 160
    Width = 258
    Height = 19
    Caption = #1055#1088#1080#1084#1077#1088' '#1088#1077#1085#1076#1077#1088#1080#1085#1075#1072' '#1085#1072' '#1087#1072#1085#1077#1083#1080
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 387
    Height = 153
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 0
    OnCanResize = Panel1CanResize
  end
  object Button1: TButton
    Left = 328
    Top = 160
    Width = 49
    Height = 25
    Caption = #1042#1099#1093#1086#1076
    TabOrder = 1
    OnClick = Button1Click
  end
  object ApplicationEvents1: TApplicationEvents
    OnIdle = ApplicationEvents1Idle
    OnMessage = ApplicationEvents1Message
    Left = 8
    Top = 8
  end
end
