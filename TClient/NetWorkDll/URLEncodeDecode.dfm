object Form1: TForm1
  Left = 205
  Top = 114
  Width = 870
  Height = 500
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 862
    Height = 466
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 0
    object Memo1: TMemo
      Left = 56
      Top = 16
      Width = 441
      Height = 97
      Lines.Strings = (
        'Memo1')
      TabOrder = 0
    end
    object Button2: TButton
      Left = 56
      Top = 120
      Width = 75
      Height = 25
      Caption = 'utf8±àÂë'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Memo2: TMemo
      Left = 56
      Top = 152
      Width = 441
      Height = 105
      Lines.Strings = (
        'Memo1')
      TabOrder = 2
    end
    object Button3: TButton
      Left = 56
      Top = 264
      Width = 75
      Height = 25
      Caption = 'utf8½âÂë'
      TabOrder = 3
      OnClick = Button3Click
    end
    object Memo3: TMemo
      Left = 56
      Top = 296
      Width = 441
      Height = 97
      Lines.Strings = (
        'Memo1')
      TabOrder = 4
    end
  end
end
