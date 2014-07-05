object frmClient: TfrmClient
  Left = 288
  Top = 196
  Width = 604
  Height = 480
  Caption = 'frmClient'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object img1: TImage
    Left = 248
    Top = 168
    Width = 105
    Height = 105
  end
  object ddd: TPageControl
    Left = 0
    Top = 0
    Width = 596
    Height = 446
    ActivePage = TabSheet2
    Align = alClient
    TabOrder = 0
    object ts4: TTabSheet
      Caption = '命令执行'
      ImageIndex = 3
      object pnl6: TPanel
        Left = 464
        Top = 0
        Width = 124
        Height = 418
        Align = alRight
        Caption = 'pnl6'
        TabOrder = 0
        object btnKillProcess: TButton
          Left = 14
          Top = 32
          Width = 75
          Height = 25
          Caption = '执行'
          TabOrder = 0
          OnClick = btnKillProcessClick
        end
        object btnDelete: TButton
          Left = 14
          Top = 64
          Width = 75
          Height = 25
          Caption = '删除'
          TabOrder = 1
          OnClick = btnDeleteClick
        end
      end
      object pnl7: TPanel
        Left = 0
        Top = 0
        Width = 464
        Height = 418
        Align = alClient
        Caption = 'pnl7'
        TabOrder = 1
        object lstCmd: TListBox
          Left = 1
          Top = 73
          Width = 462
          Height = 344
          Align = alClient
          Columns = 1
          ItemHeight = 13
          TabOrder = 0
          OnClick = lstCmdClick
        end
        object pnl8: TPanel
          Left = 1
          Top = 1
          Width = 462
          Height = 72
          Align = alTop
          Caption = 'pnl8'
          TabOrder = 1
          object lblCommandList: TLabel
            Left = 2
            Top = 56
            Width = 60
            Height = 13
            Caption = '历史命令：'
          end
          object lblCommand: TLabel
            Left = 10
            Top = 8
            Width = 36
            Height = 13
            Caption = '命令：'
          end
          object edtParam: TEdit
            Left = 32
            Top = 24
            Width = 369
            Height = 21
            TabOrder = 0
            Text = 'edtParam'
          end
        end
      end
    end
    object ts5: TTabSheet
      Caption = '快捷菜单'
      ImageIndex = 4
      OnShow = ts5Show
      object pnl9: TPanel
        Left = 0
        Top = 0
        Width = 588
        Height = 418
        Align = alClient
        Caption = 'pnl9'
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'TabSheet2'
      ImageIndex = 7
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 588
        Height = 41
        Align = alTop
        Caption = 'Panel2'
        TabOrder = 0
        object Button4: TButton
          Left = 16
          Top = 8
          Width = 75
          Height = 25
          Caption = 'Button4'
          TabOrder = 0
          OnClick = Button4Click
        end
        object Button5: TButton
          Left = 96
          Top = 8
          Width = 75
          Height = 25
          Caption = 'URL编码解码'
          TabOrder = 1
          OnClick = Button5Click
        end
        object Button2: TButton
          Left = 176
          Top = 8
          Width = 75
          Height = 25
          Caption = '获取程序图片'
          TabOrder = 2
          OnClick = Button2Click
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 41
        Width = 588
        Height = 377
        Align = alClient
        Caption = 'Panel2'
        TabOrder = 1
        object Button3: TButton
          Left = 176
          Top = 8
          Width = 75
          Height = 25
          Caption = '数据库导入导出'
          TabOrder = 0
          OnClick = Button3Click
        end
        object Button1: TButton
          Left = 176
          Top = 48
          Width = 75
          Height = 25
          Caption = '后台服务测试'
          TabOrder = 1
          OnClick = Button1Click
        end
        object Button6: TButton
          Left = 152
          Top = 88
          Width = 75
          Height = 25
          Caption = '邮件测试'
          TabOrder = 2
          OnClick = Button6Click
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
  object frmstrg1: TFormStorage
    StoredValues = <>
    Left = 567
    Top = 227
  end
  object rxtrycn1: TRxTrayIcon
    Icon.Data = {
      0000010001001010000001000800680500001600000028000000100000002000
      0000010008000000000000000000000000000000000000000000000000000000
      00002020200040404000CFCFCF00DFDFDF00B0B0B00090909000BFBFBF00C0C0
      C000A0A0A000F7F7F700AFAFAF005F5F5F00707090000000BF00404060008080
      8000606060002020800070707000000040000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000010913000000000000000000000000
      0000010801000000000001140000000007000108010000000001120E02000001
      070707031000000001120E0F000000000101010308130001120E0F0000000000
      00000001030802120E0F00000000000000000000010C120E0F00000000000000
      0000000001120E0D130100000000001011000001120E0F030813010100000108
      0501020D0E0F000107050304060001070305060B0200000001080C0203010001
      07080900000000000108000A0101000001040501000000000103060000000000
      000103030100000000010201000000000000010202000000000000000000E3FF
      0000E1FF000091F1000081E1000080C30000C0070000F80F0000FC1F00009C0F
      0000080100000080000001C0000083C00000C3C30000E1E30000F1FF0000}
    OnClick = rxtrycn1Click
    Left = 567
    Top = 254
  end
  object apvnts1: TAppEvents
    OnMinimize = apvnts1Minimize
    OnRestore = apvnts1Restore
    Left = 567
    Top = 200
  end
  object dlgOpen1: TOpenDialog
    Left = 4
    Top = 248
  end
  object dlgSave1: TSaveDialog
    Left = 4
    Top = 224
  end
  object il1: TImageList
    Left = 4
    Top = 272
  end
end
