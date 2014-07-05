object Form1: TForm1
  Left = 205
  Top = 130
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
  OnCreate = FormCreate
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
    object ListView1: TListView
      Left = 7
      Top = 67
      Width = 466
      Height = 302
      Columns = <
        item
        end
        item
        end
        item
        end>
      RowSelect = True
      TabOrder = 0
      OnColumnClick = ListView1ColumnClick
      OnCustomDrawItem = ListView1CustomDrawItem
    end
    object Button2: TButton
      Left = 166
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Query'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button1: TButton
      Left = 80
      Top = 16
      Width = 75
      Height = 25
      Caption = 'DBCreate'
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button3: TButton
      Left = 512
      Top = 128
      Width = 75
      Height = 25
      Caption = 'иорф'
      TabOrder = 3
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 512
      Top = 168
      Width = 75
      Height = 25
      Caption = 'обрф'
      TabOrder = 4
      OnClick = Button4Click
    end
  end
end
