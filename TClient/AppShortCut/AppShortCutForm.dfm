object frmAppShortCut: TfrmAppShortCut
  Left = 205
  Top = 114
  Width = 537
  Height = 264
  Caption = 'frmAppShortCut'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 529
    Height = 230
    Align = alClient
    TabOrder = 0
    object imgIcon: TImage
      Left = 144
      Top = 88
      Width = 105
      Height = 105
    end
    object imgBmp: TImage
      Left = 280
      Top = 88
      Width = 105
      Height = 105
    end
    object lblIcon: TLabel
      Left = 179
      Top = 72
      Width = 26
      Height = 13
      Caption = 'ICON'
    end
    object lblBmp: TLabel
      Left = 325
      Top = 72
      Width = 20
      Height = 13
      Caption = 'BMP'
    end
    object btnGetIcon: TButton
      Left = 11
      Top = 24
      Width = 75
      Height = 25
      Anchors = [akTop]
      Caption = 'ªÒ»°Õº±Í'
      TabOrder = 0
      OnClick = btnGetIconClick
    end
    object edtAppPath: TEdit
      Left = 104
      Top = 24
      Width = 401
      Height = 21
      TabOrder = 1
      OnDblClick = edtAppPathDblClick
    end
  end
  object dlgOpen1: TOpenDialog
    Left = 4
    Top = 104
  end
  object il1: TImageList
    Left = 4
    Top = 136
  end
end
