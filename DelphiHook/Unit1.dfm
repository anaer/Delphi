object Form1: TForm1
  Left = 309
  Top = 164
  Width = 696
  Height = 480
  Caption = 'Delphi Hook'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Edit1: TEdit
    Left = 32
    Top = 72
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object Button3: TButton
    Left = 32
    Top = 24
    Width = 121
    Height = 25
    Caption = 'Hook'
    TabOrder = 1
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 184
    Top = 24
    Width = 121
    Height = 25
    Caption = 'UnHook'
    TabOrder = 2
    OnClick = Button4Click
  end
end
