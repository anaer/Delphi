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
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 862
    Height = 466
    ActivePage = TabSheet2
    Align = alClient
    TabOrder = 0
    object TabSheet2: TTabSheet
      Caption = 'TabSheet2'
      ImageIndex = 1
      object pnl10: TPanel
        Left = 0
        Top = 0
        Width = 854
        Height = 41
        Align = alTop
        TabOrder = 0
        object btn5: TButton
          Left = 8
          Top = 8
          Width = 75
          Height = 25
          Caption = '查询'
          TabOrder = 0
          OnClick = btn5Click
        end
      end
      object pnl4: TPanel
        Left = 0
        Top = 41
        Width = 854
        Height = 397
        Align = alClient
        Caption = 'pnl4'
        TabOrder = 1
        object dbgrd1: TDBGrid
          Left = 1
          Top = 1
          Width = 852
          Height = 395
          Align = alClient
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -11
          TitleFont.Name = 'Tahoma'
          TitleFont.Style = []
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
      ImageIndex = 1
      object pnl2: TPanel
        Left = 0
        Top = 0
        Width = 854
        Height = 97
        Align = alTop
        Caption = 'pnl2'
        TabOrder = 0
        object lbl_svrname: TLabel
          Left = 16
          Top = 32
          Width = 48
          Height = 13
          Caption = '服务名：'
        end
        object lbl_param: TLabel
          Left = 28
          Top = 53
          Width = 36
          Height = 13
          Caption = '参数：'
        end
        object lbl_result: TLabel
          Left = 28
          Top = 74
          Width = 36
          Height = 13
          Caption = '结果：'
        end
        object edt_svrname: TEdit
          Left = 64
          Top = 24
          Width = 121
          Height = 21
          TabOrder = 0
          Text = 'sv_gather'
        end
        object edt_param: TEdit
          Left = 64
          Top = 51
          Width = 337
          Height = 21
          TabOrder = 1
          Text = 'param'
        end
        object btn_ok: TButton
          Left = 430
          Top = 45
          Width = 75
          Height = 25
          Caption = '调用'
          TabOrder = 2
          OnClick = btn_okClick
        end
      end
      object pnl3: TPanel
        Left = 0
        Top = 97
        Width = 854
        Height = 341
        Align = alClient
        Caption = 'pnl3'
        TabOrder = 1
        object redt_result: TRichEdit
          Left = 1
          Top = 1
          Width = 852
          Height = 339
          Align = alClient
          Font.Charset = GB2312_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          Lines.Strings = (
            'redt1')
          ParentFont = False
          TabOrder = 0
        end
      end
    end
  end
  object qry1: TQuery
    DatabaseName = 'openfund'
    RequestLive = True
    SQL.Strings = (
      'select * from HSI_USER')
    Left = 567
    Top = 308
  end
  object ds1: TDataSource
    DataSet = qry1
    Left = 567
    Top = 281
  end
end
